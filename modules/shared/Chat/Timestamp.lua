local _, addon = ...;

local date = date;

local function AddMessage(chat, text, ...)
	local id = chat:GetID();
	if (id and text) then
		if (IsAddOnLoaded("ElvUI")) then
			text = ("|cff%02x%02x%02x|Hcpl:%s|h[%s]|h|r %s"):format(245, 245, 245, id, date("%X"), text);
		else
			text = ("|cff%02x%02x%02x[%s]|r %s"):format(245, 245, 245, date("%X"), text);
		end
	end
	return chat:OriginalAddMessage(text, ...);
end

-- adds timestamp. clickable to copy text if ElvUI is loaded
local module = addon:NewModule("ChatTimestamp", "AceEvent-3.0");

function module:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_CHAT_WINDOWS");
end

function module:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");

	-- inject timestamp link
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame"..i];
		if (cf ~= COMBATLOG) then
			cf.OriginalAddMessage = cf.AddMessage;
			cf.AddMessage = AddMessage;
		end
	end
end

function module:UPDATE_CHAT_WINDOWS()
	self:UnregisterEvent("UPDATE_CHAT_WINDOWS");

	-- reset chat colors, channels, font-sizes
	ResetChatWindows();
	FCF_SetChatWindowFontSize(nil, ChatFrame1, 12);
	FCF_SetChatWindowFontSize(nil, ChatFrame2, 12);

	-- activate color name by class in all channels
	for _, v in ipairs(CHAT_CONFIG_CHAT_LEFT) do
		local info = ChatTypeGroup[v.type];
		if (info) then
			for _, value in pairs(info) do
				SetChatColorNameByClass(value:gsub("^CHAT_MSG_", ""), true);
			end
		end
	end

	for i=1, MAX_WOW_CHAT_CHANNELS do
		SetChatColorNameByClass("CHANNEL"..i, true);
	end

	ChatFrame1:SetMaxLines(1024);
end
