local function shouldShow(link)
	local _, _, itemRarity, iLevel, _, _, _, _, equipSlot = GetItemInfo(link);

	return (
		IsEquippableItem(link)
		and itemRarity > Enum.ItemQuality.Common
		and not ( itemRarity == Enum.ItemQuality.Heirloom and iLevel == 1 )
		and equipSlot ~= "INVTYPE_TABARD"
		and equipSlot ~= "INVTYPE_BAG"
		and equipSlot ~= "INVTYPE_BODY"
	);
end

local function replacer(link)
	if (not shouldShow(link)) then
		return link;
	end

	local effectiveItemLevel = GetDetailedItemLevelInfo(link);
	if (effectiveItemLevel) then
		return link .. " (" .. effectiveItemLevel .. ")";
	end

	return link;
end

local function filter(_, _, msg, ...)
	return false, string.gsub(msg, "|?%x*|Hitem:.-|h.-|h|?r?", replacer), ...;
end

for k in pairs(getmetatable(ChatTypeInfo).__index) do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..k, filter);
end
