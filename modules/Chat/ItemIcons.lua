local _, addon = ...;

local textureFormat = "|T%s:12|t";

local handlers = {};

handlers["item"] = function(linkOptions)
	local itemId = tonumber(linkOptions:match("^%d+"));
	local _, icon = C_PetJournal.GetPetInfoByItemID(itemId);
	return icon or GetItemIcon(itemId);
end

handlers["spell"] = function(linkOptions)
	local spellId = tonumber(linkOptions:match("^%d+"));
	return C_Spell.GetSpellTexture(spellId);
end

handlers["achievement"] = function(linkOptions)
	local achievementId = tonumber(linkOptions:match("^%d+"));
	return select(10, GetAchievementInfo(achievementId));
end

handlers["battlepet"] = function(linkOptions)
	local speciesId = tonumber(linkOptions:match("^%d+"));
	return select(2, C_PetJournal.GetPetInfoBySpeciesID(speciesId));
end

handlers["currency"] = function(linkOptions)
	local currencyId = tonumber(linkOptions:match("^%d+"));
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyId);
	return currencyInfo and currencyInfo.iconFileID;
end

handlers["mawpower"] = function(linkOptions)
	local id = tonumber(linkOptions:match("^%d+"));
	local spellId = addon.GetMawPowerSpellID(id);
	return spellId and C_Spell.GetSpellTexture(spellId);
end

handlers["mount"] = function(linkOptions)
	local spellId = tonumber(linkOptions:match("^%d+"));
	return C_Spell.GetSpellTexture(spellId);
end

local function filter(_, _, msg, ...)
	-- pattern from LinkUtil.ExtractLink, but non-greedy and without displayText
	msg = msg:gsub([[(|H([^:]-):([^|]-)|h.-|h)]], function (link, linkType, linkOptions)
		if (handlers[linkType]) then
			local icon = handlers[linkType](linkOptions);
			if (icon) then
				return textureFormat:format(icon) .. link;
			end
		end
		return link;
	end);

	return false, msg, ...;
end

for k in pairs(getmetatable(ChatTypeInfo).__index) do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..k, filter);
end
