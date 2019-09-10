local realmName = GetRealmName()

local Struct_BNGetFriendInfo = {
	[1] = "bnetIDAccount",
	[2] = "accountName",
	[3] = "battleTag",
	[4] = "isBattleTagPresence",
	[5] = "characterName",
	[6] = "bnetIDGameAccount",
	[7] = "client",
	[8] = "isOnline",
	[9] = "lastOnline",
	[10] = "isAFK",
	[11] = "isDND",
	[12] = "messageText",
	[13] = "noteText",
	[14] = "isRIDFriend",
	[15] = "messageTime",
	[16] = "canSoR",
	[17] = "isReferAFriend",
	[18] = "canSummonFriend"
}

local Struct_BNGetFriendGameAccountInfo = {
	[1] = "hasFocus",
	[2] = "characterName",
	[3] = "client",
	[4] = "realmName",
	[5] = "realmID",
	[6] = "faction",
	[7] = "race",
	[8] = "class",
	[9] = "guild",
	[10] = "zoneName",
	[11] = "level",
	[12] = "gameText",
	[13] = "broadcastText",
	[14] = "broadcastTime",
	[15] = "canSoR",
	[16] = "bnetIDGameAccount",
	[17] = "presenceID",
	[18] = "unknown1",
	[19] = "unknown2",
	[20] = "characterGUID",
	[21] = "wowProjectID"
}

local classNameToFile = {}
for i = 1, 20 do
	local info = C_CreatureInfo.GetClassInfo(i)
	if info then
		classNameToFile[info.className] = info.classFile
	end
end

local function GetFriendInfoFromBattleNet(id)
	local data = {}
	data.id = id

	local friendInfo = {BNGetFriendInfo(id)}
	for index, name in ipairs(Struct_BNGetFriendInfo) do
		data[name] = friendInfo[index]
	end

	data.gameAccounts = {}
	local numGameAccounts = BNGetNumFriendGameAccounts(id)
	for i = 1, numGameAccounts do
		local gameInfo = {}

		local friendGameInfo = {BNGetFriendGameAccountInfo(id, i)}
		for index, name in ipairs(Struct_BNGetFriendGameAccountInfo) do
			gameInfo[name] = friendGameInfo[index]
		end

		gameInfo.className = gameInfo.class
		gameInfo.class = classNameToFile[gameInfo.className]

		table.insert(data.gameAccounts, gameInfo)
	end

	return data
end

local function GetFriendInfoFromWow(id)
	local data = C_FriendList.GetFriendInfoByIndex(id)

	data.id = id
	data.class = classNameToFile[data.className]

	return data
end

local function GetColor(data, buttonType, field)
	local value = data[field]

	if field == "level" then
		local level = tonumber(value, 10)

		if level then
			local color = GetQuestDifficultyColor(level)
			return CreateColor(color.r, color.g, color.b):GenerateHexColor()
		end
	end

	if field == "class" and RAID_CLASS_COLORS[value] then
		return RAID_CLASS_COLORS[value]:GenerateHexColor()
	end

	local offline = not data[buttonType == FRIENDS_BUTTON_TYPE_BNET and "isOnline" or "connected"]
	if offline then
		return FRIENDS_GRAY_COLOR:GenerateHexColor()
	elseif buttonType == FRIENDS_BUTTON_TYPE_BNET then
		return FRIENDS_BNET_NAME_COLOR:GenerateHexColor()
	else
		return FRIENDS_WOW_NAME_COLOR:GenerateHexColor()
	end
end

local function GetFirstWowGameAccount(data)
	for _, account in ipairs(data.gameAccounts) do
		if account.client == BNET_CLIENT_WOW then
			return account
		end
	end
end

local function hook(self)
	local button = self:GetParent()
	local buttonType, id = button.buttonType, button.id

	if buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local data = GetFriendInfoFromBattleNet(id)
		if not data.isOnline then
			return
		end

		local wowData = GetFirstWowGameAccount(data)

		if wowData then
			local characterName = BNet_GetValidatedCharacterName(data.characterName, data.battleTag, data.client)

			if wowData.realmName ~= realmName then
				characterName = characterName .. YELLOW_FONT_COLOR:WrapTextInColorCode(CANNOT_COOPERATE_LABEL)
			end

			self:origSetText(("|c%sL%s %s%s%s (|c%s%s|r)"):format(
				GetColor(wowData, buttonType, "level"), wowData.level,
				FRIENDS_BNET_NAME_COLOR_CODE, data.accountName, FONT_COLOR_CODE_CLOSE,
				GetColor(wowData, buttonType, "class"), characterName
			))
		end
	elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local data = GetFriendInfoFromWow(id)

		if not data.connected then
			return
		end

		self:origSetText(("|c%sL%d |c%s%s"):format(
			GetColor(data, buttonType, "level"), data.level,
			GetColor(data, buttonType, "class"), data.name
		))
	end
end

for _, button in ipairs(FriendsFrameFriendsScrollFrame.buttons) do
	button.name.origSetText = button.name.SetText
	hooksecurefunc(button.name, "SetText", hook);
end
