local _, addon = ...;

if (not CreateColorFromHexString) then
	local function ExtractColorValueFromHex(str, index)
		return tonumber(str:sub(index, index + 1), 16) / 255;
	end
	function CreateColorFromHexString(hexColor)
		if (#hexColor == 8) then
			local a, r, g, b = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5), ExtractColorValueFromHex(hexColor, 7);
			return CreateColor(r, g, b, a);
		else
			error("CreateColorFromHexString input must be hexadecimal digits in this format: AARRGGBB.");
		end
	end
end

local reactionColors = {
	[1] = CreateColorFromHexString("ffc0c0c0"), -- Tapped
	[2] = CreateColorFromHexString("ffff0000"), -- Hostile
	[3] = CreateColorFromHexString("ffff7f00"), -- Caution
	[4] = CreateColorFromHexString("ffffff00"), -- Neutral
	[5] = CreateColorFromHexString("ff00ff00"), -- Friendly NPC or PvP Player
	[6] = CreateColorFromHexString("ff25c1eb"), -- Friendly Player
	[7] = CreateColorFromHexString("ff808080"), -- Dead
};

local reactionTexts = {
	"Tapped",					-- No localized string of this
	FACTION_STANDING_LABEL2,	-- Hostile
	FACTION_STANDING_LABEL3,	-- Unfriendly (Caution)
	FACTION_STANDING_LABEL4,	-- Neutral
	FACTION_STANDING_LABEL5,	-- Friendly
	FACTION_STANDING_LABEL5,	-- Friendly (Exalted)
	DEAD,						-- Dead
};

function addon.GetUnitReactionIndex(unit)
	-- Deadies
	if (UnitIsDead(unit)) then
		return 7;
	end

	-- Players
	if (UnitIsPlayer(unit) or UnitPlayerControlled(unit)) then
		if (UnitCanAttack(unit, "player")) then
			return UnitCanAttack("player", unit) and 2 or 3;
		elseif (UnitCanAttack("player", unit)) then
			return 4;
		elseif (UnitIsPVP(unit) and not UnitIsPVPSanctuary(unit) and not UnitIsPVPSanctuary("player")) then
			return 5;
		else
			return 6;
		end
	end

	-- Tapped
	if (UnitIsTapDenied(unit) and not UnitPlayerControlled(unit)) then
		return 1;
	end

	-- Others
	local reaction = UnitReaction(unit, "player") or 3;
	return (reaction > 5 and 5) or (reaction < 2 and 2) or reaction;
end

function addon.GetUnitReactionColor(unit)
	return reactionColors[addon.GetUnitReactionIndex(unit)];
end

function addon.GetUnitReactionText(unit)
	return reactionTexts[addon.GetUnitReactionIndex(unit)];
end

local conduits = {};
for i = 1, 284 do -- last id of https://wow.tools/dbc/?dbc=soulbindconduititem
	local x = C_Soulbinds.GetConduitSpellID(i, 1);
	if (x) then
		local name = GetSpellInfo(x);
		conduits[i] = { name = name, id = i, spellid = x };
	end
end

function addon.getConduitIDByName(name)
	for _,v in pairs(conduits) do
		if (v and v.name == name) then
			return v.id;
		end
	end
end
