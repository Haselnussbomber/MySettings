local addonName, addon = ...;

local playerGuild = GetGuildInfo("player");
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

local defaultTextColor = CreateColorFromHexString("ffc0c0c0");
local defaultBorderColor = CreateColor(0.25, 0.25, 0.25, 1);
local ctx = {};

local healthBar = CreateFrame("STATUSBAR", nil, GameTooltip, "TooltipStatusBarTemplate");
local powerBar = CreateFrame("STATUSBAR", nil, GameTooltip, "TooltipStatusBarTemplate");

local function getTextLeft(index)
	return _G["GameTooltipTextLeft"..index];
end
local function getDifficultyColor(unit)
	local canAttack = UnitCanAttack(unit, "player") or UnitCanAttack("player", unit);
	if (canAttack) then
		local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit);
		local color = GetDifficultyColor(difficulty);
		return CreateColor(color.r, color.g, color.b);
	end
	return defaultTextColor;
end

local function UpdateTooltip(self)
	if (C_PetBattles.IsInBattle()) then
		return;
	end

	local unit = addon.GetTooltipUnit(self);
	if (not unit) then
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
	local nameColor;

	if (UnitIsPlayer(unit)) then
		ctx.race = UnitRace(unit);
		ctx.reactionColor = addon.GetUnitReactionColor(unit);
		ctx.reactionText = addon.GetUnitReactionText(unit);

		local className, classFilename, classID = UnitClass(unit);
		local guild, guildRank = GetGuildInfo(unit);

		nameColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];

		-- name line
		do
			local tbl = {};

			-- name
			table.insert(tbl, nameColor:WrapTextInColorCode(pvpName or name));

			-- realm
			if (realm) then
				table.insert(tbl, "- " .. realm);
			end

			-- status (DC/AFK/DND)
			local status = (not UnitIsConnected(unit) and "<DC>") or (UnitIsAFK(unit) and "<AFK>") or (UnitIsDND(unit) and "<DND>");
			if (status) then
				table.insert(tbl, status);
			end

			-- target
			local unittarget = unit.."target";
			if (UnitExists(unittarget)) then
				table.insert(tbl, defaultTextColor:WrapTextInColorCode(":"));

				if (UnitIsUnit(unittarget, "player")) then
					table.insert(tbl, "<<YOU>>");
				else
					local name, realm = UnitName(unittarget);
					local pvpName = UnitPVPName(unittarget);
					local _, classFilename = UnitClass(unittarget);
					local targetNameColor = RAID_CLASS_COLORS["PRIEST"];

					if (UnitIsDead(unittarget) or not UnitIsConnected(unittarget)) then
						targetNameColor = defaultTextColor;
					elseif (UnitIsPlayer(unittarget)) then
						targetNameColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
					else
						targetNameColor = addon.GetUnitReactionColor(unittarget);
					end

					table.insert(tbl, targetNameColor:WrapTextInColorCode("[" .. (pvpName or name) .. "]"));
				end
			end

			GameTooltipTextLeft1:SetText(table.concat(tbl, " "));
		end

		-- guild line
		if (guild) then
			local guildColor = (guild == playerGuild and "|cffff32ff") or "|cff0080cc";
			GameTooltipTextLeft2:SetFormattedText("%s<%s> |cffc0c0c0%s", guildColor, guild, guildRank);
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

			getTextLeft(guild and 3 or 2):SetText(table.concat(tbl, " "));
		end
	else -- NPCs
		if (ctx.guid) then
			if (ctx.guid ~= guid) then
				local line = getTextLeft(infoLineOffset);
				local text = line:GetText();
				if (text and text ~= "" and text ~= " " and not text:find(TT_LevelMatch) and not text:find(TT_NPCGuild)) then
					ctx.npcGuild = text;
				else
					ctx.npcGuild = nil;
				end
			end
		end

		ctx.reactionColor = addon.GetUnitReactionColor(unit);
		ctx.reactionText = addon.GetUnitReactionText(unit);
		nameColor = defaultBorderColor;

		-- name line
		GameTooltipTextLeft1:SetText(ctx.reactionColor:WrapTextInColorCode(pvpName or name));

		-- guild line
		if (ctx.npcGuild) then
			GameTooltipTextLeft2:SetFormattedText("%s<%s>", ctx.reactionColor:GenerateHexColorMarkup(), ctx.npcGuild);
		end

		-- info line
		do
			local tbl = {};

			-- level
			table.insert(tbl, difficultyColor:WrapTextInColorCode(levelText));

			-- class
			className = UnitCreatureFamily(unit) or UnitCreatureType(unit);
			if (not className) then
				className = UNKNOWN;
			end
			table.insert(tbl, className);

			getTextLeft(ctx.npcGuild and 3 or 2):SetText(table.concat(tbl, " "));
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
				local line = getTextLeft(self:NumLines());
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
	self:SetBackdropBorderColor(nameColor:GetRGB());
end

GameTooltip:HookScript("OnTooltipSetUnit", UpdateTooltip);

--hooksecurefunc("GameTooltip_ShowStatusBar", GameTooltip_ClearStatusBars);
--hooksecurefunc("GameTooltip_OnHide", SharedTooltip_ClearInsertedFrames);

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
