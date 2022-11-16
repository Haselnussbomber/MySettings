local C_Item = C_Item;
local GetItemSpell = GetItemSpell;

local spell2anima = {
	[347555] = 3,
	[345706] = 5,
	[336327] = 35,
	[336456] = 250,
};

ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", function(self, event, message, ...)
	local link = message:match("|Hitem:.-|h.-|h");
	if (not link) then
		return false;
	end

	if (not C_Item.IsAnimaItemByID(link)) then
		return false;
	end

	local _, spellID = GetItemSpell(link);
	if (not spell2anima[spellID]) then
		return false;
	end

	message = message:gsub("(|c%x+|Hitem:.-|h.-|h|rx?(%d*))", function(a, b)
		return a .. " (" .. tonumber(b ~= "" and b or 1) * spell2anima[spellID] .. " Anima)";
	end)

	return false, message, ...;
end);
