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

local BAR_MARGIN_X = 8;
local BAR_SPACING = 5;

local colorDefaultText = CreateColorFromHexString("ffc0c0c0");
local colorDefaultBorder = CreateColor(0.25, 0.25, 0.25, 1);
local colorGuild = CreateColorFromHexString("ff0080cc");
local colorSameGuild = CreateColorFromHexString("ffff32ff");

local ctx = {};

local healthBar = CreateFrame("STATUSBAR", nil, GameTooltip);
local powerBar = CreateFrame("STATUSBAR", nil, GameTooltip);

local bars = {
	healthBar,
	powerBar,
}
for _, bar in pairs(bars) do
	bar:SetSize(0, 15);
	bar:SetStatusBarTexture([[Interface\Addons\SharedMedia_MyMedia\statusbar\Smoothv2.tga]]);

	bar.bg = bar:CreateTexture(nil, "BACKGROUND");
	bar.bg:SetColorTexture(0.3, 0.3, 0.3, 0.6);
	bar.bg:SetAllPoints();

	bar.text = bar:CreateFontString(nil, "ARTWORK");
	bar.text:SetPoint("CENTER");
	bar.text:SetTextColor(1, 1, 1);
	--bar.text:SetFont([[Interface\Addons\SharedMedia_MyMedia\font\museosans_500.ttf]], 12, "OUTLINE");
	bar.text:SetFont([[Interface\Addons\SharedMedia_MyMedia\font\Roboto-Medium.ttf]], 11, "OUTLINE");
	bar.text:SetShadowColor(0, 0, 0, 0.5);
	bar.text:SetShadowOffset(0.8, -0.8);
end

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
	self:SetBackdropBorderColor(colorDefaultBorder:GetRGB());
	healthBar:Hide();
	powerBar:Hide();
end

local function FormatValue(val)
	if (val < 10000) then
		return tostring(floor(val));
	elseif (val < 1000000) then
		return ("%.1fk"):format(val / 1000);
	elseif (val < 1000000000) then
		return ("%.2fm"):format(val / 1000000);
	else
		return ("%.2fg"):format(val / 1000000000);
	end
end

local function UpdateStatusBars(unit, hasPower)
	local cur = UnitHealth(unit);
	local max = UnitHealthMax(unit);

	healthBar:SetMinMaxValues(0, max);
	healthBar:SetValue(cur);
	healthBar.text:SetFormattedText("%s / %s (%.0f%%)", FormatValue(cur), FormatValue(max), cur / max * 100);

	local _, classFilename = UnitClass(unit);
	local classColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
	healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b);

	local minWidth = healthBar.text:GetStringWidth() + BAR_SPACING * 4;

	if (hasPower) then
		local powerType = UnitPowerType(unit);

		cur = UnitPower(unit, powerType);
		max = UnitPowerMax(unit, powerType);

		powerBar:SetMinMaxValues(0, max);
		powerBar:SetValue(cur);
		powerBar.text:SetFormattedText("%s / %s (%.0f%%)", FormatValue(cur), FormatValue(max), cur / max * 100);

		minWidth = math.max(minWidth, healthBar.text:GetStringWidth() + BAR_SPACING * 4);

		if (powerType == 0) then
			powerBar:SetStatusBarColor(0.3, 0.55, 0.9);
		else
			local powerColor = PowerBarColor[powerType or 5];
			powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b);
		end
	end

	GameTooltip:SetMinimumWidth(minWidth);
end

local function OnTooltipSetUnit(self)
	if (C_PetBattles.IsInBattle()) then
		return;
	end

	local _, unit = self:GetUnit();
	if (not unit) then
		local mouseFocus = GetMouseFocus();
		unit = mouseFocus and mouseFocus.GetAttribute and mouseFocus:GetAttribute("unit");
	end
	if (not unit or (UnitExists("mouseover") and UnitIsUnit(unit, "mouseover"))) then
		unit = "mouseover";
	end
	if (not UnitExists(unit)) then
		Reset(self);
		return;
	end

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

		local className, classFilename = UnitClass(unit);
		local classColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
		self:SetBackdropBorderColor(classColor:GetRGB());

		-- name line
		do
			local tbl = {};

			-- name
			local playerFlag = ""
			local mentorshipStatus = C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit(unit))
			if (mentorshipStatus == Enum.PlayerMentorshipStatus.Mentor) then
				playerFlag = "|A:newplayerchat-chaticon-guide:0:0:0:0|a "; -- NPEV2_CHAT_USER_TAG_GUIDE
			elseif (mentorshipStatus == Enum.PlayerMentorshipStatus.Newcomer) then
				playerFlag = NPEV2_CHAT_USER_TAG_NEWCOMER .. " ";
			end
			local fullName = pvpName or name;
			if (realm) then
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
					table.insert(tbl, "<<YOU>>");
				else
					local name, realm = UnitName(unittarget);
					local pvpName = UnitPVPName(unittarget);
					local _, classFilename = UnitClass(unittarget);
					local targetClassColor = RAID_CLASS_COLORS["PRIEST"];

					if (UnitIsDead(unittarget) or not UnitIsConnected(unittarget)) then
						targetClassColor = colorDefaultText;
					elseif (UnitIsPlayer(unittarget)) then
						targetClassColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
					else
						targetClassColor = addon.GetUnitReactionColor(unittarget);
					end

					table.insert(tbl, classColor:WrapTextInColorCode("[") ..
						targetClassColor:WrapTextInColorCode(pvpName or name) ..
						classColor:WrapTextInColorCode("]"));
				end
			end

			GameTooltipTextLeft1:SetText(table.concat(tbl, " "));
		end

		-- guild line
		local guild, guildRank = GetGuildInfo(unit);
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
				table.insert(tbl, classColor:WrapTextInColorCode(className));
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

				if (ctx.npcGuildLineIndex == 0 and ctx.npcLevelLineIndex == 0 and i > 1 and not text:find(TT_NPCGuild) and not text:find(TT_LevelMatch)) then
					ctx.npcGuildLineIndex = i;
				end

				if (ctx.npcLevelLineIndex == 0 and i > ctx.npcGuildLineIndex and text:find(TT_LevelMatch)) then
					ctx.npcLevelLineIndex = i;
				end
			end
		end

		ctx.reactionColor = addon.GetUnitReactionColor(unit);
		ctx.reactionText = addon.GetUnitReactionText(unit);
		--self:SetBackdropBorderColor(ctx.reactionColor:GetRGB());
		self:SetBackdropBorderColor(colorDefaultBorder:GetRGB());

		-- name line
		GameTooltipTextLeft1:SetText(ctx.reactionColor:WrapTextInColorCode(name));

		-- level line
		if (ctx.npcLevelLineIndex > 0) then
			local tbl = {};

			-- level
			table.insert(tbl, difficultyColor:WrapTextInColorCode(levelText));

			-- race
			table.insert(tbl, UnitCreatureFamily(unit) or UnitCreatureType(unit) or UNKNOWN);

			local line = getTextLeft(self, ctx.npcLevelLineIndex);
			line:SetTextColor(1, 1, 1, 1);
			line:SetText(table.concat(tbl, " "));
		end

		-- guild line
		if (ctx.npcGuildLineIndex > 0) then
			local text = ctx.npcOriginalLines[ctx.npcGuildLineIndex];
			if (text) then
				local line = getTextLeft(self, ctx.npcGuildLineIndex);
				line:SetTextColor(ctx.reactionColor:GetRGB());
				line:SetFormattedText("<%s>", text);
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
				self:AddLine(("Targeted By (|cffffffff%d|r): %s"):format(#targetedByList, table.concat(targetedByList, ", ")));
			end
		end
	end

	-- Add status bars
	if (not healthBar:IsShown() or (ctx.guid and ctx.guid ~= guid) or not ctx.guid) then
		local hasPower = UnitPowerMax(unit) > 0;

		GameTooltip_AddBlankLinesToTooltip(self, hasPower and 3 or 2);
		local lastLine = getTextLeft(self, self:NumLines() - (hasPower and 2 or 1));
		self:Show();
		local point, relativeTo, relativePoint, xOfs, yOfs = lastLine:GetPoint("TOP");
		if (point) then
			UpdateStatusBars(unit, hasPower);

			healthBar:ClearAllPoints();
			healthBar:SetPoint("LEFT", self, "LEFT", BAR_MARGIN_X, 0);
			healthBar:SetPoint("RIGHT", self, "RIGHT", -BAR_MARGIN_X, 0);
			healthBar:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs - (hasPower and 5 or 8));
			healthBar:Show();

			if (hasPower) then
				powerBar:ClearAllPoints();
				powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -BAR_SPACING);
				powerBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, -BAR_SPACING);
				powerBar:Show();
			end
		end
	end

	ctx.guid = guid;
	self:Show(); -- to trigger size update
end

C_Timer.After(1, function()
	GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit);
end);
GameTooltip:HookScript("OnTooltipCleared", Reset);

-- handle unit updates
local f = CreateFrame("frame");
f:RegisterEvent("UNIT_HEALTH");
f:RegisterEvent("UNIT_MAXHEALTH");
f:RegisterEvent("UNIT_DISPLAYPOWER");
f:RegisterEvent("UNIT_POWER_UPDATE");
f:RegisterEvent("UNIT_MAXPOWER");
f:RegisterEvent("UNIT_NAME_UPDATE");
--f:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
f:SetScript("OnEvent", function(self, event, unit, ...)
	if ((event == "UNIT_HEALTH" or
		event == "UNIT_MAXHEALTH" or
		event == "UNIT_DISPLAYPOWER" or
		event == "UNIT_POWER_UPDATE" or
		event == "UNIT_MAXPOWER") and ctx.guid and ctx.guid == UnitGUID(unit)) then
		UpdateStatusBars(unit, UnitPowerMax(unit) > 0);
		return;
	end
	if (event == "UNIT_NAME_UPDATE") then
		OnTooltipSetUnit(GameTooltip);
	end
end);
