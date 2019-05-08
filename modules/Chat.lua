local _, addon = ...

local date = date

-- adds clickable timestamp to copy text
local Module = {
	name = "chat",
	events = { "PLAYER_ENTERING_WORLD", "UPDATE_CHAT_WINDOWS" }
}

local function AddMessage(chat, text, ...)
	local id = chat:GetID()
    if not id or not text then
        return chat:OriginalAddMessage(text, ...)
    end
    local link = "|cff%02x%02x%02x|Hcpl:%s|h[%s]|h|r"
    text = link:format(245, 245, 245, id, date("%X")) .. " " .. text
    return chat:OriginalAddMessage(text, ...)
end

function Module.PLAYER_ENTERING_WORLD()
    Module.PLAYER_ENTERING_WORLD = nil

    -- inject timestamp link
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G[format("ChatFrame%d", i)]
		if cf ~= COMBATLOG then
            cf.OriginalAddMessage = cf.AddMessage
            cf.AddMessage = AddMessage
		end
	end
end

function Module.UPDATE_CHAT_WINDOWS()
    Module.UPDATE_CHAT_WINDOWS = nil

    -- reset chat colors, channels, font-sizes
    ResetChatWindows()
    FCF_SetChatWindowFontSize(nil, ChatFrame1, 12)
    FCF_SetChatWindowFontSize(nil, ChatFrame2, 12)

    -- activate color name by class in all channels
    for i, v in ipairs(CHAT_CONFIG_CHAT_LEFT) do
        local info = ChatTypeGroup[v.type]
        if (info) then
            for key, value in pairs(info) do
                SetChatColorNameByClass(strsub(value, 10), true) -- fix: GUILD_MOTD => D
            end
        end
    end

    for i=1, MAX_WOW_CHAT_CHANNELS do
        SetChatColorNameByClass("CHANNEL"..i, true)
    end

    ChatFrame1:SetMaxLines(1024)
end

addon:Register(Module)
