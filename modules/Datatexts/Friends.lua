local addonName, _ = ...;
local name = ("%s_%s"):format(addonName, "Friends");
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local dataObject = ldb:NewDataObject(name);
local frame = CreateFrame("Frame", name .. "_Frame");
local nameFormatConnected = "|T%s:0|t %s, %s"
local nameFormatNotConnected = "|T%s:0|t %s"
FrameUtil.RegisterFrameForEvents(frame, { "FRIENDLIST_UPDATE" });

function dataObject:OnTooltipShow()
	self:ClearLines();
	self:AddLine(FRIENDS);

	for i = 1, C_FriendList.GetNumFriends() do
		local friendInfo = C_FriendList.GetFriendInfoByIndex(i);
		local icon = not friendInfo.connected and FRIENDS_TEXTURE_OFFLINE or
			friendInfo.afk and FRIENDS_TEXTURE_AFK or
			friendInfo.dnd and FRIENDS_TEXTURE_DND or
			FRIENDS_TEXTURE_ONLINE;

		if (friendInfo.connected) then
			self:AddLine(nameFormatConnected:format(icon, friendInfo.name, format(FRIENDS_LEVEL_TEMPLATE, friendInfo.level, friendInfo.className)), FRIENDS_WOW_NAME_COLOR.r, FRIENDS_WOW_NAME_COLOR.g, FRIENDS_WOW_NAME_COLOR.b);
		else
			self:AddLine(nameFormatNotConnected:format(icon, friendInfo.name), FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		end
	end
end

function dataObject:OnClick(button)
	if (FriendsFrame:IsVisible()) then
		HideUIPanel(FriendsFrame);
	else
		ShowUIPanel(FriendsFrame);
	end
end

local function Update()
	local numFriends = C_FriendList.GetNumFriends();
	local numOnline = 0;

	for i = 1, numFriends do
		local friendInfo = C_FriendList.GetFriendInfoByIndex(i);
		numOnline = numOnline + (friendInfo.connected and 1 or 0);
	end

	dataObject.text = ("%d/%d"):format(numOnline, numFriends);
end

frame:SetScript("OnEvent", Update);

FrameUtil.RegisterUpdateFunction(frame, 5, Update);

Update();
