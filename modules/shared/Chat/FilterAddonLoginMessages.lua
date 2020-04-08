local _, addon = ...

local orig_DEFAULT_CHAT_FRAME_AddMessage = DEFAULT_CHAT_FRAME.AddMessage

local function clearString(str)
	str = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
	str = string.gsub(str, "|r", "")
	return str
end

local messages = {
	"Wowhead Looter loaded",
	"Wowhead Looter geladen",
	"ALL THE THINGS.* loaded successfully",
	"TRP3",
	"Details!",
	"FleecingTip",
	"AAP Loaded",
	"%[RareScanner%]: loaded",
	"Capping is missing locale for"
}

local function shouldShutUp(message)
	for _, v in ipairs(messages) do
		if (string.find(clearString(message), v)) then
			return true
		end
	end
	return false
end

DEFAULT_CHAT_FRAME.AddMessage = function(self, message, r, g, b, ...)
	if (not shouldShutUp(message)) then
		orig_DEFAULT_CHAT_FRAME_AddMessage(self, message, r, g, b, ...)
	end
end

local module = addon:NewModule("ChatFilterAddonLoginMessages", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterEvent("LOADING_SCREEN_DISABLED")
end

function module:LOADING_SCREEN_DISABLED()
	self:UnregisterEvent("LOADING_SCREEN_DISABLED")

	C_Timer.After(30, function()
		shouldShutUp = function() return false end
	end)
end
