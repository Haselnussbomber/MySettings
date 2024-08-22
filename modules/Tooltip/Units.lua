local TT_LevelMatch = "^"..TOOLTIP_UNIT_LEVEL:gsub("%%[^s ]*s",".+");
local TT_NPCGuild = "^|c[^<]+";
local classifications = {
	elite = "Elite %s",
	rare = "Rare %s",
	trivial = "~%s ",
	normal = "%s",
	minus = "-%s ",
	rareelite = "Rare-Elite %s",
	worldboss = "Boss %s",
};

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

local function getUnitReactionIndex(unit)
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

local function getUnitReactionColor(unit)
	return reactionColors[getUnitReactionIndex(unit)];
end

local function getUnitReactionText(unit)
	return reactionTexts[getUnitReactionIndex(unit)];
end

local colorDefaultText = CreateColorFromHexString("ffc0c0c0");
local colorDefaultBorder = CreateColorFromHexString("ff404040");
local colorGuild = CreateColorFromHexString("ff0080cc");
local colorSameGuild = CreateColorFromHexString("ffff32ff");

local currentGuid;

local function getTextLeft(self, index)
	return _G[self:GetName() .. "TextLeft" .. index];
end

local function getDifficultyColor(unit)
	local canAttack = UnitCanAttack(unit, "player") or UnitCanAttack("player", unit);
	if (canAttack) then
		local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit);
		local color = GetDifficultyColor(difficulty);
		return CreateColor(color.r, color.g, color.b);
	end
	return colorDefaultText;
end

local function Reset(self)
	currentGuid = nil;
	if (self.SetBackdropBorderColor) then
		self:SetBackdropBorderColor(colorDefaultBorder:GetRGB());
	end
end

local function OnUnit(tooltip)
	if (C_PetBattles and C_PetBattles.IsInBattle()) then
		return;
	end

	local _, unit, guid = TooltipUtil.GetDisplayedUnit(tooltip);
	if (not unit) then
		Reset(tooltip);
		return;
	end

	currentGuid = guid;

	local name, realm = UnitName(unit);
	local pvpName = UnitPVPName(unit);
	local level = UnitLevel(unit) or -1;
	local difficultyColor = getDifficultyColor(unit);
	local levelText = (classifications[UnitClassification(unit) or ""] or "%s?"):format(level == -1 and "??" or level);

	if (UnitIsPlayer(unit)) then
		local race = UnitRace(unit);
		local reactionColor = getUnitReactionColor(unit);
		local reactionText = getUnitReactionText(unit);

		local className, classFilename = UnitClass(unit);
		local classColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
		if (tooltip.SetBackdropBorderColor) then
			tooltip:SetBackdropBorderColor(classColor:GetRGB());
		end

		-- name line
		do
			local tbl = {};

			-- name
			local playerFlag = "";
			local mentorshipStatus = C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit(unit));
			if (mentorshipStatus == Enum.PlayerMentorshipStatus.Mentor) then
				playerFlag = "|A:newplayerchat-chaticon-guide:0:0:0:0|a "; -- NPEV2_CHAT_USER_TAG_GUIDE
			elseif (mentorshipStatus == Enum.PlayerMentorshipStatus.Newcomer) then
				playerFlag = NPEV2_CHAT_USER_TAG_NEWCOMER .. " ";
			end
			local fullName = pvpName ~= "" and pvpName or name;
			if (realm and realm ~= "" and realm ~= " ") then
				fullName = fullName .. " - " .. realm;
			end
			table.insert(tbl, playerFlag .. classColor:WrapTextInColorCode(fullName));

			-- status (DC/AFK/DND)
			local status = (not UnitIsConnected(unit) and "<DC>") or (UnitIsAFK(unit) and "<AFK>") or (UnitIsDND(unit) and "<DND>");
			if (status) then
				table.insert(tbl, status);
			end

			-- target
			local unittarget = unit.."target";
			if (UnitExists(unittarget)) then
				table.insert(tbl, colorDefaultText:WrapTextInColorCode(":"));

				if (UnitIsUnit(unittarget, "player")) then
					table.insert(tbl, WHITE_FONT_COLOR:WrapTextInColorCode("<<YOU>>"));
				else
					local name = UnitName(unittarget);
					local pvpName = UnitPVPName(unittarget);
					local _, classFilename = UnitClass(unittarget);
					local targetClassColor = RAID_CLASS_COLORS["PRIEST"];

					if (UnitIsDead(unittarget) or not UnitIsConnected(unittarget)) then
						targetClassColor = colorDefaultText;
					elseif (UnitIsPlayer(unittarget)) then
						targetClassColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
					else
						targetClassColor = getUnitReactionColor(unittarget);
					end

					table.insert(tbl, classColor:WrapTextInColorCode("[") ..
						targetClassColor:WrapTextInColorCode(pvpName ~= "" and pvpName or name) ..
						classColor:WrapTextInColorCode("]"));
				end
			end

			tooltip.TextLeft1:SetText(table.concat(tbl, " "));
		end

		-- guild line
		local guild, guildRank = GetGuildInfo(unit);
		if (guild) then
			local playerGuild = GetGuildInfo("player");
			local guildColor = (guild == playerGuild and colorSameGuild) or colorGuild;
			tooltip.TextLeft2:SetFormattedText("%s<%s>%s %s", guildColor:GenerateHexColorMarkup(), guild, FONT_COLOR_CODE_CLOSE, colorDefaultText:WrapTextInColorCode(guildRank));
		end

		-- info line
		do
			local tbl = {};

			-- level
			table.insert(tbl, difficultyColor:WrapTextInColorCode(levelText));

			-- race
			if (race) then
				table.insert(tbl, race);
			end

			-- reaction
			if (reaction) then
				table.insert(tbl, reactionColor:WrapTextInColorCode(reactionText));
			end

			getTextLeft(tooltip, guild and 3 or 2):SetText(table.concat(tbl, " "));
		end

		do
			local specClassLine = getTextLeft(tooltip, guild and 4 or 3);
			local specClassText = specClassLine:GetText():gsub(className, classColor:WrapTextInColorCode(className));
			specClassLine:SetText(specClassText);
		end
	else -- NPCs
		local npcNumLines = tooltip:NumLines();
		local npcOriginalLines = {};
		local npcGuildLineIndex = 0;
		local npcLevelLineIndex = 0;

		for i = 1, npcNumLines do
			local text = getTextLeft(tooltip, i):GetText();
			npcOriginalLines[i] = text;

			if (npcGuildLineIndex == 0 and npcLevelLineIndex == 0 and i > 1 and not text:find(TT_NPCGuild) and not text:find(TT_LevelMatch)) then
				npcGuildLineIndex = i;
			end

			if (npcLevelLineIndex == 0 and i > npcGuildLineIndex and text:find(TT_LevelMatch)) then
				npcLevelLineIndex = i;
			end
		end

		local reactionColor = getUnitReactionColor(unit);
		--tooltip.NineSlice:SetBorderColor(reactionColor:GetRGB());
		if (tooltip.SetBackdropBorderColor) then
			tooltip:SetBackdropBorderColor(colorDefaultBorder:GetRGB());
		end

		-- name line
		tooltip.TextLeft1:SetText(reactionColor:WrapTextInColorCode(name));

		-- level line
		if (npcLevelLineIndex > 0) then
			local tbl = {};

			-- level
			table.insert(tbl, difficultyColor:WrapTextInColorCode(levelText));

			-- race
			table.insert(tbl, UnitCreatureFamily(unit) or UnitCreatureType(unit) or UNKNOWN);

			local line = getTextLeft(tooltip, npcLevelLineIndex);
			line:SetTextColor(1, 1, 1, 1);
			line:SetText(table.concat(tbl, " "));
		end

		-- guild line
		if (npcGuildLineIndex > 0) then
			local text = npcOriginalLines[npcGuildLineIndex];
			if (text) then
				local line = getTextLeft(tooltip, npcGuildLineIndex);
				line:SetTextColor(reactionColor:GetRGB());
				line:SetFormattedText("<%s>", text);
			end
		end
	end

	-- Add "Targeted by" line
	do
		local numGroup = GetNumGroupMembers();
		if (numGroup and numGroup > 1) then
			local targetedByList = {};

			local inRaid = IsInRaid();
			for i = 1, numGroup do
				local groupUnit = (inRaid and "raid"..i or "party"..i);
				if (UnitIsUnit(groupUnit.."target", unit) and not UnitIsUnit(groupUnit, "player")) then
					local _, _, classID = UnitClass(groupUnit);
					local classInfo = C_CreatureInfo.GetClassInfo(classID);
					if (classInfo) then
						local classColorInfo = RAID_CLASS_COLORS[classInfo.classFile];
						table.insert(targetedByList, WrapTextInColorCode(UnitName(groupUnit), classColorInfo.colorStr));
					end
				end
			end

			if (#targetedByList > 0) then
				local firstLine = ("Targeted by (|cffffffff%d|r): "):format(#targetedByList);
				local players = {};
				for i = 1, #targetedByList do
					table.insert(players, targetedByList[i]);
					if (#players == 5) then
						tooltip:AddLine(firstLine .. table.concat(players, ", "));
						firstLine = "";
						players = {};
					end
				end
				if (#players > 0) then
					tooltip:AddLine(firstLine .. table.concat(players, ", "));
				end
			end
		end
	end

	tooltip:Show(); -- to trigger size update
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnUnit);
GameTooltip:HookScript("OnTooltipCleared", Reset);

-- handle unit updates
local f = CreateFrame("frame");
f:RegisterEvent("UNIT_NAME_UPDATE");
f:SetScript("OnEvent", function(self, event, unit, ...)
	if (event == "UNIT_NAME_UPDATE") then
		OnUnit(GameTooltip);
	end
end);
