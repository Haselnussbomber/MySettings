local playerGUID = UnitGUID("player");

ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_LOOT", function(self, event, ...)
	local senderGUID = select(12, ...);
	if (senderGUID == playerGUID) then
		return false;
	end

	local message = ...;
	local link = message:match("|Hitem:.-|h.-|h");
	if (not link) then
		return false;
	end

	local _, _, itemRarity = C_Item.GetItemInfo(link);
	return itemRarity == Enum.ItemQuality.Poor;
end);
