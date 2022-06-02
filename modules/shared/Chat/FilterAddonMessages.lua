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

local enabled = true;

DEFAULT_CHAT_FRAME.AddMessage = function(self, message, r, g, b, ...)
	if (enabled) then
		for _, v in ipairs(addonMessages) do
			if (clearString(message):find(v)) then
				return; -- filter
			end
		end
	end

	orig_DEFAULT_CHAT_FRAME_AddMessage(self, message, r, g, b, ...);
end

local module = addon:NewModule("FilterAddonMessages");

function module:OnInitialize()
	self:RegisterEvent("LOADING_SCREEN_DISABLED");
end

function module:LOADING_SCREEN_DISABLED()
	self:UnregisterEvent("LOADING_SCREEN_DISABLED");

	C_Timer.After(30, function()
		-- if AddMessage is replaced with the original function, the timestamp hook will be removed
		enabled = false;
	end);
end
