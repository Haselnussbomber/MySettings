local REGEX_YOU_LOOT_MONEY = "^"..YOU_LOOT_MONEY:gsub("%%s", "(.*)") .."$"; -- "Ihr plündert %s" -> "Ihr plündert (.*)"
local REGEX_GOLD_AMOUNT    = "^"..GOLD_AMOUNT:gsub("%%d", "(%%d+)")  .."$"; -- "%d Gold"   -> "^(%d+) Gold$"
local REGEX_SILVER_AMOUNT  = "^"..SILVER_AMOUNT:gsub("%%d", "(%%d+)").."$"; -- "%d Silber" -> "^(%d+) Silber$"
local REGEX_COPPER_AMOUNT  = "^"..COPPER_AMOUNT:gsub("%%d", "(%%d+)").."$"; -- "%d Kupfer" -> "^(%d+) Kupfer$"

local YOU_LOOT_MONEY = YOU_LOOT_MONEY;
local GOLD_AMOUNT_TEXTURE = GOLD_AMOUNT_TEXTURE;
local SILVER_AMOUNT_TEXTURE = SILVER_AMOUNT_TEXTURE;
local COPPER_AMOUNT_TEXTURE = COPPER_AMOUNT_TEXTURE;

ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", function(self, event, message, ...)
	local match = message:match(REGEX_YOU_LOOT_MONEY);
	if (not match) then
			return false;
	end

	local split = { string.split(",", match) };
	for k, v in next, split do
		v = v:trim(); -- important to trim away the space after comma

		match = v:match(REGEX_GOLD_AMOUNT);
		if (match) then
			split[k] = GOLD_AMOUNT_TEXTURE:format(match);
		end

		match = v:match(REGEX_SILVER_AMOUNT);
		if (match) then
			split[k] = SILVER_AMOUNT_TEXTURE:format(match);
		end

		match = v:match(REGEX_COPPER_AMOUNT);
		if (match) then
			split[k] = COPPER_AMOUNT_TEXTURE:format(match);
		end
	end

	message = YOU_LOOT_MONEY:format(table.concat(split, " "));

	return false, message, ...;
end);
