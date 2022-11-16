local date = date;

local timestampColor = CreateColor(245 / 255, 245 / 255, 245 / 255);

local function TimestampedAddMessageWrapper(frame)
	local orig_AddMessage = frame.AddMessage;
	return function(self, text, ...)
		local id = self:GetID();
		if (id and text) then
			local timestamp = ("|Hcpl:%d|h[%s]|h"):format(id, date("%X"));
			text = timestampColor:WrapTextInColorCode(timestamp) .. " " .. text;
		end
		return orig_AddMessage(self, text, ...);
	end
end

-- inject timestamp link
for i = 1, NUM_CHAT_WINDOWS do
	local cf = _G["ChatFrame"..i];
	if (cf ~= COMBATLOG) then
		cf.AddMessage = TimestampedAddMessageWrapper(cf);
	end
end
