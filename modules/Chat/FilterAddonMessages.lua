local orig_DEFAULT_CHAT_FRAME_AddMessage = DEFAULT_CHAT_FRAME.AddMessage;

local function clearString(str)
	return str:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "");
end

local addonMessages = {
	"Wowhead Looter loaded",
	"Wowhead Looter geladen",
	"ALL THE THINGS.* loaded successfully",
	"ALL THE THINGS Profile: .*",
	"TRP3",
	"Details!",
	"FleecingTip",
	"AAP Loaded",
	"%[RareScanner%]: loaded",
	"Capping is missing locale for",
	"%[Attune%] v%.?%d+",
	"BagSync: %[v%d+%.%d+%] /bgs, /bagsync",
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


EventUtil.RegisterOnceFrameEventAndCallback("LOADING_SCREEN_DISABLED", function()
	C_Timer.After(30, function()
		-- if AddMessage is replaced with the original function, the timestamp hook will be removed
		enabled = false;
	end);
end);
