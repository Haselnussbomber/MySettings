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
	"BetterBags integration enabled",
	"BetterBags: Masque integration enabled",
	"Endeavor Tracker: Loaded!",
	"Housing Codex: .* decor collected",
};

local enabled = true;

local function shouldFilter(message)
	if (not enabled or not message) then
		return false;
	end

	local clean = C_StringUtil.StripHyperlinks(message, false, false, false, false, false);
	for _, pattern in ipairs(addonMessages) do
		if (clean:find(pattern)) then
			return true;
		end
	end

	return false;
end

local originalPrint = _G.print;
_G.print = function(...)
	local message = select(1, ...);
	if (shouldFilter(message)) then
		return;
	end

	originalPrint(...);
end

local originalAddMessage = DEFAULT_CHAT_FRAME.AddMessage
DEFAULT_CHAT_FRAME.AddMessage = function(self, message, ...)
	if (shouldFilter(message)) then
		return;
	end

	originalAddMessage(self, message, ...);
end

EventUtil.RegisterOnceFrameEventAndCallback("LOADING_SCREEN_DISABLED", function()
	C_Timer.After(30, function()
		-- if AddMessage is replaced with the original function, the timestamp hook will be removed
		enabled = false;
	end);
end);
