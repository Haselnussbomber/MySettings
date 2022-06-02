local Enum = Enum;
local GetItemInfo = GetItemInfo;
local playerGUID = UnitGUID("player");

ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", function(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	if (arg12 == playerGUID) then
		return false;
	end

	local link = arg1:match("|Hitem:.-|h.-|h");
	if (not link) then
		return false;
	end

	local _, _, itemRarity = GetItemInfo(link);
	return itemRarity == Enum.ItemQuality.Poor;
end);
