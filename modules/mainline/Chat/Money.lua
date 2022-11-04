-- "Ihr plündert %s" -> "Ihr plündert (.*)"
local REGEX_YOU_LOOT_MONEY = YOU_LOOT_MONEY:gsub("%%s", "(.*)");

-- "Erhalten: |cffffffff%s|r" -> "Erhalten: |cffffffff(.*)|r"
local REGEX_GENERIC_MONEY_GAINED_RECEIPT = GENERIC_MONEY_GAINED_RECEIPT:gsub("%%s", "(.*)");

-- "Erhalten: %s." -> "Erhalten: (.*)%."
local REGEX_ERR_QUEST_REWARD_MONEY_S = ERR_QUEST_REWARD_MONEY_S:gsub("%.", "%%."):gsub("%%s", "(.*)");

-- "Euer Anteil an der Beute ist %s." -> "Euer Anteil an der Beute ist (.*)%."
local REGEX_LOOT_MONEY_SPLIT = LOOT_MONEY_SPLIT:gsub("%.", "%%."):gsub("%%s", "(.*)");

-- "%d Gold" -> "([%d,]+) Gold"
local REGEX_GOLD_AMOUNT = GOLD_AMOUNT:gsub("%%d", "([%%d,]+)");

-- "%d Silber" -> "([%d,]+) Silber"
local REGEX_SILVER_AMOUNT = SILVER_AMOUNT:gsub("%%d", "([%%d,]+)");

-- "%d Kupfer" -> "([%d,]+) Kupfer"
local REGEX_COPPER_AMOUNT = COPPER_AMOUNT:gsub("%%d", "([%%d,]+)");

local replacers = {
	{ REGEX_GOLD_AMOUNT, GOLD_AMOUNT_TEXTURE },
	{ REGEX_SILVER_AMOUNT, SILVER_AMOUNT_TEXTURE },
	{ REGEX_COPPER_AMOUNT, COPPER_AMOUNT_TEXTURE },
};

local function filter(self, event, message, ...)
	local match = message:match(REGEX_YOU_LOOT_MONEY);
	local format = YOU_LOOT_MONEY;
	if (not match) then
		match = message:match(REGEX_GENERIC_MONEY_GAINED_RECEIPT);
		format = GENERIC_MONEY_GAINED_RECEIPT;
	end
	if (not match) then
		match = message:match(REGEX_ERR_QUEST_REWARD_MONEY_S);
		format = ERR_QUEST_REWARD_MONEY_S;
	end
	if (not match) then
		match = message:match(REGEX_LOOT_MONEY_SPLIT);
		format = LOOT_MONEY_SPLIT;
	end
	if (not match) then
		return false;
	end

	local parts = {};
	local text = match;
	for _, v in ipairs(replacers) do
		match = text:match(v[1]);
		if (match) then
			table.insert(parts, v[2]:format(match, 0, 0));
		end
	end

	message = format:format(table.concat(parts, " "));

	return false, message, ...;
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filter);
