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

local module = addon:RegisterModule("ChatFilterAddonLoginMessages")
module:RegisterEvent("LOADING_SCREEN_DISABLED")

function module:LOADING_SCREEN_DISABLED()
    self:UnregisterEvent("LOADING_SCREEN_DISABLED")

    shouldShutUp = function() return false end
end
