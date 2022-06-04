local REGEX_YOU_LOOT_MONEY = "^"..YOU_LOOT_MONEY:gsub("%%s", "(.*)") .."$"; -- "Ihr plündert %s" -> "Ihr plündert (.*)"
local REGEX_GOLD_AMOUNT    = "^"..GOLD_AMOUNT:gsub("%%d", "(%%d+)")  .."$"; -- "%d Gold"   -> "^(%d+) Gold$"
local REGEX_SILVER_AMOUNT  = "^"..SILVER_AMOUNT:gsub("%%d", "(%%d+)").."$"; -- "%d Silber" -> "^(%d+) Silber$"
local REGEX_COPPER_AMOUNT  = "^"..COPPER_AMOUNT:gsub("%%d", "(%%d+)").."$"; -- "%d Kupfer" -> "^(%d+) Kupfer$"

local YOU_LOOT_MONEY = YOU_LOOT_MONEY;
local replacers = {
	[REGEX_GOLD_AMOUNT] = GOLD_AMOUNT_TEXTURE,
	[REGEX_SILVER_AMOUNT] = SILVER_AMOUNT_TEXTURE,
	[REGEX_COPPER_AMOUNT] = COPPER_AMOUNT_TEXTURE,
};

ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", function(self, event, message, ...)
	local match = message:match(REGEX_YOU_LOOT_MONEY);
	if (not match) then
			return false;
	end

	local splitted = { string.split(",", match) };
	for index, val in next, splitted do
		val = val:trim(); -- important to trim away the space after comma

		for regex, textureTemplate in next, replacers do
			match = val:match(regex);
			if (match) then
				splitted[index] = textureTemplate:format(match, 0, 0);
			end
		end
	end

	message = YOU_LOOT_MONEY:format(table.concat(splitted, " "));

	return false, message, ...;
end);
