local systemMessages = {
	"Es sind .* neue Spielercharaktere in den letzten .* Minuten beigetreten! Vergesst nicht, nachzufragen, wenn Ihr etwas wissen möchtet", -- NPEV2_CHAT_BATCH_JOIN_MESSAGE
};

ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, message, ...)
	for _, v in ipairs(systemMessages) do
		if (message:find(v)) then
			return true;
		end
	end
	return false;
end);
