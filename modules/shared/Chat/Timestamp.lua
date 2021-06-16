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
