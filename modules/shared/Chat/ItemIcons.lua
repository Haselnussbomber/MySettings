local _, addon = ...

local match = string.match
local gsub = string.gsub

local textureFormat = "|T%s:12|t"

local handlers = {
	["(|c%x+|Hitem:(.-)|h.-|h|?r)"] = function(link, linkData)
		local itemId = match(linkData, "^%d+")
		local texture = GetItemIcon(itemId)
		if (texture) then
			return textureFormat:format(texture) .. link
		end
		return link
	end,

	["(|c%x+|Hspell:(.-)|h.-|h|?r)"] = function(link, linkData)
		local spellId = match(linkData, "^%d+")
		local texture = select(3, GetSpellInfo(spellId))
		if (texture) then
			return textureFormat:format(texture) .. link
		end
		return link
	end,
}

if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
	handlers["(|c%x+|Hachievement:(.-)|h.-|h|?r)"] = function(link, linkData)
		local achievementId = match(linkData, "^%d+")
		local texture = select(10, GetAchievementInfo(achievementId))
		if (texture) then
			return textureFormat:format(texture) .. link
		end
		return link
	end

	handlers["(|c%x+|Hbattlepet:(.-)|h.-|h|?r)"] = function(link)
		-- copied from Interface/FrameXML/DressUpFrames.lua (8.0.1)
		local _, _, _, _, speciesIDString, _, _, _, _, _, battlePetID = strsplit(":|H", link)
		local speciesID, _, _, _, _, _, _, _, texture = C_PetJournal.GetPetInfoByPetID(battlePetID)
		if (speciesID== tonumber(speciesIDString) and texture ) then
			return textureFormat:format(texture) .. link
		else
			_, texture = C_PetJournal.GetPetInfoBySpeciesID(tonumber(speciesIDString))
			if (texture) then
				return textureFormat:format(texture) .. link
			end
		end
		return link
	end

	handlers["(|c%x+|Hcurrency:(.-)|h.-|h|?r)"] = function(link, linkData)
		local currencyId = match(linkData, "^%d+")
		local texture = C_CurrencyInfo.GetCurrencyInfo(currencyId).iconFileID
		if (texture) then
			return textureFormat:format(texture) .. link
		end
		return link
	end

	-- |cff71d5ff|Hmawpower:1177|h[Strahlende Essenz]|h|r
	handlers["(|c%x+|Hmawpower:(%d+)|h.-|h|r)"] = function(link, id)
		local spellID = addon.GetMawPowerSpellID(id)
		if (spellID) then
			local texture = select(3, GetSpellInfo(spellID))
			if (texture) then
				return textureFormat:format(texture) .. link
			end
		end
		return link
	end
end

local function filter(_, _, msg, ...)
	for pattern, replacer in pairs(handlers) do
		msg = gsub(msg, pattern, replacer)
	end

	return false, msg, ...
end

for k in pairs(getmetatable(ChatTypeInfo).__index) do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..k, filter)
end
