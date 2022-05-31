local date = date;

local timestampColor = CreateColor(245 / 255, 245 / 255, 245 / 255);

local function AddMessage(chat, text, ...)
	local id = chat:GetID();
	if (id and text) then
		local timestamp = ("|Hcpl:%d|h[%s]|h"):format(id, date("%X"));
		text = timestampColor:WrapTextInColorCode(timestamp) .. " " .. text;
	end
	return chat:OriginalAddMessage(text, ...);
end

-- inject timestamp link
for i = 1, NUM_CHAT_WINDOWS do
	local cf = _G["ChatFrame"..i];
	if (cf ~= COMBATLOG) then
		cf.OriginalAddMessage = cf.AddMessage;
		cf.AddMessage = AddMessage;
	end
end
