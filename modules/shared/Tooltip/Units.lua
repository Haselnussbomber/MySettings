local addonName, addon = ...;

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
local reactionTexts = {
	"Tapped",					-- No localized string of this
	FACTION_STANDING_LABEL2,	-- Hostile
	FACTION_STANDING_LABEL3,	-- Unfriendly (Caution)
	FACTION_STANDING_LABEL4,	-- Neutral
	FACTION_STANDING_LABEL5,	-- Friendly
	FACTION_STANDING_LABEL5,	-- Friendly (Exalted)
	DEAD,						-- Dead
};

local colorDefaultText = CreateColorFromHexString("ffc0c0c0");
local colorDefaultBorder = CreateColor(0.25, 0.25, 0.25, 1);
local colorGuild = CreateColorFromHexString("ff0080cc");
local colorSameGuild = CreateColorFromHexString("ffff32ff");

local ctx = {};

local healthBar = CreateFrame("STATUSBAR", nil, GameTooltip, "TooltipStatusBarTemplate");
local powerBar = CreateFrame("STATUSBAR", nil, GameTooltip, "TooltipStatusBarTemplate");

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

local function UpdateTooltip(self)
	if (C_PetBattles.IsInBattle()) then
		return;
	end

	local borderColor = colorDefaultBorder;

	local unit = addon.GetTooltipUnit(self);
	if (not unit) then
		self:SetBackdropBorderColor(borderColor:GetRGB()); -- no unit => just reset border colors
		return;
	end

	local colorBlindOffset = (addon.isColorBlind and UnitIsVisible(unit) and 1 or 0);
	local infoLineOffset = 2 + colorBlindOffset;

	local guid = UnitGUID(unit);
	local name, realm = UnitName(unit);
	local pvpName = UnitPVPName(unit);
	local level = UnitLevel(unit) or -1;
	local difficultyColor = getDifficultyColor(unit);
	local levelText = (classifications[UnitClassification(unit) or ""] or "%s?"):format(level == -1 and "??" or level);

	if (UnitIsPlayer(unit)) then
		ctx.race = UnitRace(unit);
		ctx.reactionColor = addon.GetUnitReactionColor(unit);
		ctx.reactionText = addon.GetUnitReactionText(unit);

		local className, classFilename, classID = UnitClass(unit);
		local guild, guildRank = GetGuildInfo(unit);

		local nameColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
		borderColor = nameColor;

		-- name line
		do
			local tbl = {};

			-- name
			local fullName = pvpName or name;
			if (realm) then
				fullName = fullName .. " - " .. realm;
			end
			table.insert(tbl, nameColor:WrapTextInColorCode(fullName));

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
					table.insert(tbl, "<<YOU>>");
				else
					local name, realm = UnitName(unittarget);
					local pvpName = UnitPVPName(unittarget);
					local _, classFilename = UnitClass(unittarget);
					local targetNameColor = RAID_CLASS_COLORS["PRIEST"];

					if (UnitIsDead(unittarget) or not UnitIsConnected(unittarget)) then
						targetNameColor = colorDefaultText;
					elseif (UnitIsPlayer(unittarget)) then
						targetNameColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
					else
						targetNameColor = addon.GetUnitReactionColor(unittarget);
					end

					table.insert(tbl, nameColor:WrapTextInColorCode("[") ..
						targetNameColor:WrapTextInColorCode("[" .. (pvpName or name) .. "]") ..
						nameColor:WrapTextInColorCode("]"));
				end
			end

			GameTooltipTextLeft1:SetText(table.concat(tbl, " "));
		end

		-- guild line
		if (guild) then
			local playerGuild = GetGuildInfo("player");
			local guildColor = (guild == playerGuild and colorSameGuild) or colorGuild;
			GameTooltipTextLeft2:SetFormattedText("%s<%s>%s %s", guildColor:GenerateHexColorMarkup(), guild, FONT_COLOR_CODE_CLOSE, colorDefaultText:WrapTextInColorCode(guildRank));
		end

		-- info line
		do
			local tbl = {};

			-- level
			table.insert(tbl, difficultyColor:WrapTextInColorCode(levelText));

			-- race
			if (ctx.race) then
				table.insert(tbl, ctx.race);
			end

			-- class
			if (className) then
				table.insert(tbl, nameColor:WrapTextInColorCode(className));
			end

			-- reaction
			if (ctx.reaction) then
				table.insert(tbl, ctx.reactionColor:WrapTextInColorCode(ctx.reactionText));
			end

			getTextLeft(self, guild and 3 or 2):SetText(table.concat(tbl, " "));
		end
	else -- NPCs
		if ((ctx.guid and ctx.guid ~= guid) or not ctx.guid or ctx.npcNumLines == 0) then
			ctx.npcNumLines = self:NumLines();
			ctx.npcOriginalLines = {};
			ctx.npcGuildLineIndex = 0;
			ctx.npcLevelLineIndex = 0;

			for i = 1, ctx.npcNumLines do
				local text = getTextLeft(self, i):GetText();
				ctx.npcOriginalLines[i] = text;

				if (text:find(TT_NPCGuild)) then
					ctx.npcGuildLineIndex = i;
				end

				if (text:find(TT_LevelMatch)) then
					ctx.npcLevelLineIndex = i;
				end
			end
		end

		ctx.reactionColor = addon.GetUnitReactionColor(unit);
		ctx.reactionText = addon.GetUnitReactionText(unit);
		borderColor = ctx.reactionColor;

		-- name line
		GameTooltipTextLeft1:SetText(ctx.reactionColor:WrapTextInColorCode(name));

		-- level line
		if (ctx.npcLevelLineIndex > 0) then
			local tbl = {};

			-- level
			table.insert(tbl, difficultyColor:WrapTextInColorCode(levelText));

			-- class
			table.insert(tbl, UnitCreatureFamily(unit) or UnitCreatureType(unit) or UNKNOWN);

			local line = getTextLeft(self, ctx.npcLevelLineIndex);
			line:SetTextColor(1, 1, 1, 1);
			line:SetText(table.concat(tbl, " "));
		end

		-- guild line
		if (ctx.npcGuildLineIndex > 0) then
			local text = ctx.npcOriginalLines[ctx.npcGuildLineIndex];
			if (text) then
				local color = ctx.reactionColor:GenerateHexColorMarkup();
				local line = getTextLeft(self, ctx.npcGuildLineIndex);
				line:SetFormattedText("%s<%s>", color, text);
			end
		end
	end

	-- Add "Targeted By" line
	do
		local numGroup = GetNumGroupMembers();
		if (numGroup and numGroup > 1) then
			local targetedByList = {};

			local inRaid = IsInRaid();
			for i = 1, numGroup do
				local unit = (inRaid and "raid"..i or "party"..i);
				if (UnitIsUnit(unit.."target", unit) and not UnitIsUnit(unit, "player")) then
					local _, _, classID = UnitClass(unit);
					local classInfo = C_CreatureInfo.GetClassInfo(classID);
					local classColorInfo = RAID_CLASS_COLORS[classInfo.classFile];
					table.insert(targetedByList, WrapTextInColorCode(UnitName(unit), classColorInfo.colorStr));
				end
			end

			if (#targetedByList > 0) then
				GameTooltip_AddBlankLinesToTooltip(self, 1);
				local line = getTextLeft(self, self:NumLines());
				line:SetFormattedText("Targeted By (|cffffffff%d|r): %s", #targetedByList, table.concat(targetedByList, ", "));
			end
		end
	end
--[[
	SharedTooltip_ClearInsertedFrames(self)

	do
		local health = UnitHealth(unit);
		local healthMax = UnitHealthMax(unit);
		local healthPercent = math.floor((health/healthMax) * 100);

		healthBar.Text:SetText(health .. " / " .. healthMax .. " (" .. (healthPercent) .. "%)");
		healthBar:SetMinMaxValues(0, healthMax);
		healthBar:SetValue(health);
		healthBar:SetSize(self:GetWidth(), 16);

		GameTooltip_InsertFrame(self, healthBar);
	end
]]--

	ctx.guid = guid;
	self:SetBackdropBorderColor(borderColor:GetRGB());
	self:Show(); -- to trigger size update
end

GameTooltip:HookScript("OnTooltipSetUnit", UpdateTooltip);
GameTooltip:HookScript("OnTooltipCleared", UpdateTooltip);

-- hooksecurefunc("SharedTooltip_SetDefaultAnchor", UpdateTooltip);

-- handle target updates
local f = CreateFrame("frame");
f:RegisterEvent("VARIABLES_LOADED");
f:RegisterEvent("UNIT_HEALTH");
f:RegisterEvent("UNIT_MAXHEALTH");
f:RegisterEvent("UNIT_DISPLAYPOWER");
f:RegisterEvent("UNIT_NAME_UPDATE");
f:RegisterEvent("UNIT_TARGET");
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
f:SetScript("OnEvent", function(self, event, unit)
	if (event == "VARIABLES_LOADED") then
		addon.isColorBlind = GetCVar("colorblindMode") == "1";
	else
		UpdateTooltip(GameTooltip);
	end
end);
