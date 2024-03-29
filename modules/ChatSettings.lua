EventUtil.RegisterOnceFrameEventAndCallback("UPDATE_CHAT_WINDOWS", function()
	-- activate color name by class in all channels
	for _, v in ipairs(CHAT_CONFIG_CHAT_LEFT) do
		local info = ChatTypeGroup[v.type];
		if (info) then
			for _, value in pairs(info) do
				SetChatColorNameByClass(value:gsub("^CHAT_MSG_", ""), true);
			end
		end
	end

	for i=1, MAX_WOW_CHAT_CHANNELS do
		SetChatColorNameByClass("CHANNEL"..i, true);
	end
end);
