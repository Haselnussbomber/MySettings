local playerMessages = {
	"^Ich könnte .* gebrauchen, wenn du es nicht willst%.$",
	"^May I please have .* if you don't need it%?$",
	"^Es sind .* neue Spielercharaktere in den letzten .* Minuten beigetreten! Vergesst nicht, nachzufragen, wenn Ihr etwas wissen möchtet.$", -- NPEV2_CHAT_BATCH_JOIN_MESSAGE
};

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(self, event, ...)
	local message = ...;
	for _, v in ipairs(playerMessages) do
		if (message:find(v)) then
			return true;
		end
	end
	return false;
end);
