local _, addon = ...;

local textureFormat = "|T%s:12|t";

local handlers = {};

handlers["(|c%x+|Hitem:(.-)|h.-|h|r)"] = function(link, linkData)
	local itemId = linkData:match("^%d+");
	local texture = GetItemIcon(itemId);
	if (texture) then
		return textureFormat:format(texture) .. link;
	end
	return link;
end

handlers["(|cnIQ%d+:.-|Hitem:(.-)|h.-|h|r)"] = function(link, linkData)
	local itemId = linkData:match("^%d+");
	local texture = GetItemIcon(itemId);
	if (texture) then
		return textureFormat:format(texture) .. link;
	end
	return link;
end

handlers["(|c%x+|Hspell:(.-)|h.-|h|r)"] = function(link, linkData)
	local spellId = linkData:match("^%d+");
	local spellInfo = C_Spell.GetSpellInfo(spellId);
	if (spellInfo) then
		return textureFormat:format(spellInfo.iconID) .. link;
	end
	return link;
end

handlers["(|c%x+|Hachievement:(.-)|h.-|h|r)"] = function(link, linkData)
	local achievementId = linkData:match("^%d+");
	local texture = select(10, GetAchievementInfo(achievementId));
	if (texture) then
		return textureFormat:format(texture) .. link;
	end
	return link;
end

handlers["(|c%x+|Hbattlepet:(.-)|h.-|h|r)"] = function(link)
	-- copied from Interface/FrameXML/DressUpFrames.lua (8.0.1)
	local _, _, _, _, speciesIDString, _, _, _, _, _, battlePetID = strsplit(":|H", link);
	local speciesID, _, _, _, _, _, _, _, texture = C_PetJournal.GetPetInfoByPetID(battlePetID);
	if (speciesID== tonumber(speciesIDString) and texture) then
		return textureFormat:format(texture) .. link;
	else
		_, texture = C_PetJournal.GetPetInfoBySpeciesID(tonumber(speciesIDString));
		if (texture) then
			return textureFormat:format(texture) .. link;
		end
	end
	return link;
end

handlers["(|c%x+|Hcurrency:(.-)|h.-|h|r)"] = function(link, linkData)
	local currencyId = linkData:match("^%d+");
	local texture = C_CurrencyInfo.GetCurrencyInfo(currencyId).iconFileID;
	if (texture) then
		return textureFormat:format(texture) .. link;
	end
	return link;
end

-- |cff71d5ff|Hmawpower:1177|h[Strahlende Essenz]|h|r
handlers["(|c%x+|Hmawpower:(%d+)|h.-|h|r)"] = function(link, id)
	local spellID = addon.GetMawPowerSpellID(tonumber(id));
	if (spellID) then
		local spellInfo = C_Spell.GetSpellInfo(spellID);
		if (spellInfo) then
			return textureFormat:format(spellInfo.iconID) .. link;
		end
	end
	return link;
end

local function filter(_, _, msg, ...)
	for pattern, replacer in pairs(handlers) do
		msg = msg:gsub(pattern, replacer);
	end

	return false, msg, ...;
end

for k in pairs(getmetatable(ChatTypeInfo).__index) do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..k, filter);
end
