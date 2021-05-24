local playerRealmName = GetRealmName()

local function GetLevelColor(level)
	local color = GetQuestDifficultyColor(level)
	return CreateColor(color.r, color.g, color.b):GenerateHexColor()
end

local function GetClassName(localizedClassName)
	for key, value in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if value == localizedClassName then
			return key
		end
	end

	for key, value in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		if value == localizedClassName then
			return key
		end
	end

	return localizedClassName
end

local function GetClassColor(className)
	if (not className) then
		return RAID_CLASS_COLORS["PRIEST"]
	end

	className = GetClassName(className)
	if (not className) then
		return RAID_CLASS_COLORS["PRIEST"]
	end

	return (RAID_CLASS_COLORS[className]):GenerateHexColor()
end

local function GetBNGetFriendInfo(id)
	local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client = BNGetFriendInfo(id)
	local obj = {
		accountName = accountName,
		battleTag = battleTag,
	}

	if (bnetIDGameAccount) then
		local _, characterName, client, realmName, _, _, _, class, _, zoneName, level, _, _, _, online, _, _, _, _, _, wowProjectID = BNGetGameAccountInfo(bnetIDGameAccount)
		obj.gameAccountInfo = {
			areaName = zoneName,
			characterLevel = level,
			characterName = characterName,
			className = class,
			clientProgram = client,
			isOnline = online,
			realmName = realmName,
			wowProjectID = wowProjectID,
		}
	end

	return obj
end

hooksecurefunc("FriendsFrame_UpdateFriendButton", function(self)
	local buttonType, id = self.buttonType, self.id
	
	if buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = BNGetFriendInfo and GetBNGetFriendInfo(id) or C_BattleNet.GetFriendAccountInfo(id)

		if not accountInfo or not accountInfo.gameAccountInfo or not accountInfo.gameAccountInfo.isOnline then
			return
		end

		local client = accountInfo.gameAccountInfo.clientProgram or accountInfo.clientProgram or ""

		if client == BNET_CLIENT_WOW then
			local realmName = accountInfo.gameAccountInfo.realmName or ""
			local level = accountInfo.gameAccountInfo.characterLevel or 0
			local class = accountInfo.gameAccountInfo.className or ""
			local wowProjectID = accountInfo.gameAccountInfo.wowProjectID or 0

			local characterName = BNet_GetValidatedCharacterName(
				accountInfo.gameAccountInfo.characterName or "",
				accountInfo.battleTag or "",
				client
			)

			if realmName ~= playerRealmName then
				characterName = characterName .. YELLOW_FONT_COLOR:WrapTextInColorCode(CANNOT_COOPERATE_LABEL)
			end

			self.name:SetText(("|c%sL%s %s%s%s (|c%s%s|r)"):format(
				GetLevelColor(level), level,
				FRIENDS_BNET_NAME_COLOR_CODE, accountInfo.accountName, FONT_COLOR_CODE_CLOSE,
				GetClassColor(class), characterName
			))

			if wowProjectID == WOW_PROJECT_CLASSIC then
				self.info:SetText(("Classic Era: %s"):format(accountInfo.gameAccountInfo.areaName or UNKNOWN))
			end

			if wowProjectID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
				self.info:SetText(("Burning Crusade Classic: %s"):format(accountInfo.gameAccountInfo.areaName or UNKNOWN))
			end
		end

		return
	end

	if buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local data = C_FriendList.GetFriendInfoByIndex(id)

		if not data.connected then
			return
		end

		self.name:SetText(("|c%sL%d |c%s%s"):format(
			GetLevelColor(data.level), data.level,
			GetClassColor(data.className), data.name
		))
	end
end)
