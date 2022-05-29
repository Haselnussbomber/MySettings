local _, addon = ...;

local orig_DEFAULT_CHAT_FRAME_AddMessage = DEFAULT_CHAT_FRAME.AddMessage;

local function clearString(str)
	return str:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");
end

local addonMessages = {
	"Wowhead Looter loaded",
	"Wowhead Looter geladen",
	"ALL THE THINGS.* loaded successfully",
	"TRP3",
	"Details!",
	"FleecingTip",
	"AAP Loaded",
	"%[RareScanner%]: loaded",
	"Capping is missing locale for",
	"%[Attune%] v%.?%d+"
};

local playerMessages = {
	"^Ich könnte .* gebrauchen, wenn du es nicht willst%.$",
	"^May I please have .* if you don't need it%?$"
};

local function isFiltered(tbl, message)
	for _, v in ipairs(tbl) do
		if (string.find(clearString(message), v)) then
			return true;
		end
	end
	return false;
end

DEFAULT_CHAT_FRAME.AddMessage = function(self, message, r, g, b, ...)
	if (not isFiltered(addonMessages, message) and not isFiltered(playerMessages, message)) then
		orig_DEFAULT_CHAT_FRAME_AddMessage(self, message, r, g, b, ...);
	end
end

local module = addon:NewModule("FilterAddonMessages");

function module:OnInitialize()
	self:RegisterEvent("LOADING_SCREEN_DISABLED");
end

function module:LOADING_SCREEN_DISABLED()
	self:UnregisterEvent("LOADING_SCREEN_DISABLED");

	C_Timer.After(30, function()
		addonMessages = {};
	end);
end
