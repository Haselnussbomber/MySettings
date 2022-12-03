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

local BAR_MARGIN_X = 8;
local BAR_SPACING = 5;

local AURA_SIZE = 20;
local AURA_MAX_ROWS = 2;

local colorDefaultText = CreateColorFromHexString("ffc0c0c0");
local colorDefaultBorder = CreateColorFromHexString("ff404040");
local colorGuild = CreateColorFromHexString("ff0080cc");
local colorSameGuild = CreateColorFromHexString("ffff32ff");

local currentGuid;

local auras = {};

local healthBar = CreateFrame("STATUSBAR", nil, GameTooltip);
local powerBar = CreateFrame("STATUSBAR", nil, GameTooltip);

local bars = {
	healthBar,
	powerBar,
};
for _, bar in pairs(bars) do
	bar:SetSize(150, 15);
	bar:SetStatusBarTexture("Interface\\Addons\\SharedMedia_MyMedia\\statusbar\\Smoothv2.tga");

	bar.bg = bar:CreateTexture(nil, "BACKGROUND");
	bar.bg:SetColorTexture(0.3, 0.3, 0.3, 0.6);
	bar.bg:SetAllPoints();

	bar.text = bar:CreateFontString(nil, "ARTWORK");
	bar.text:SetPoint("CENTER", 0, 0);
	bar.text:SetTextColor(1, 1, 1);
	bar.text:SetFont("Interface\\Addons\\SharedMedia_MyMedia\\font\\Roboto-Medium.ttf", 11, "OUTLINE");
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
	currentGuid = nil;
	self.NineSlice:SetBorderColor(colorDefaultBorder:GetRGB());
	healthBar:Hide();
	powerBar:Hide();
	for _, aura in pairs(auras) do
		aura:Hide();
	end
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

local function CreateAuraFrame(parent)
	local aura = CreateFrame("Frame", nil, parent);
	aura:SetSize(AURA_SIZE, AURA_SIZE);

	aura.count = aura:CreateFontString(nil, "OVERLAY");
	aura.count:SetPoint("BOTTOMRIGHT", 1, 0);
	aura.count:SetFont(GameFontNormal:GetFont(), (AURA_SIZE / 2), "OUTLINE");

	aura.icon = aura:CreateTexture(nil, "BACKGROUND");
	aura.icon:SetAllPoints();
	aura.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93);

	aura.cooldown = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate");
	aura.cooldown:SetReverse(1);
	aura.cooldown:SetAllPoints();
	aura.cooldown:SetFrameLevel(aura:GetFrameLevel());
	--aura.cooldown.noCooldownCount = cfg.noCooldownCount or nil;

	aura.border = aura:CreateTexture(nil, "OVERLAY");
	aura.border:SetPoint("TOPLEFT", -1, 1);
	aura.border:SetPoint("BOTTOMRIGHT", 1, -1);
	aura.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays");
	aura.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625);

	auras[#auras + 1] = aura;
	return aura;
end

local function DisplayAuras(unit, auraType, auraOffset)
	local aurasPerRow = floor((GameTooltip:GetWidth() - 4) / (AURA_SIZE + 1));
	local xOffsetBasis = (auraType == "HELPFUL" and 1 or -1);

	local queryIndex = 1;
	local auraFrameIndex = auraOffset;

	local horzAnchor1 = (auraType == "HELPFUL" and "LEFT" or "RIGHT");
	local horzAnchor2 = (auraType == "HELPFUL" and "RIGHT" or "LEFT");

	-- query auras
	while (true) do
		local name, iconTexture, count, debuffType, duration, endTime, casterUnit = UnitAura(unit, queryIndex, auraType);
		if (not name) or (not iconTexture) or (auraFrameIndex / aurasPerRow > AURA_MAX_ROWS) then
			break;
		end

		local aura = auras[auraFrameIndex] or CreateAuraFrame(GameTooltip);

		-- anchor it
		aura:ClearAllPoints();
		if ((auraFrameIndex - 1) % aurasPerRow == 0) or (auraFrameIndex == auraOffset) then
			-- new aura line
			local x = xOffsetBasis * 2;
			local y = (AURA_SIZE + 1) * floor((auraFrameIndex - 1) / aurasPerRow) + 1;
			aura:SetPoint("TOP"..horzAnchor1, GameTooltip, "BOTTOM"..horzAnchor1, x, -y);
		else
			-- anchor to last
			aura:SetPoint(horzAnchor1, auras[auraFrameIndex - 1], horzAnchor2, xOffsetBasis, 0);
		end

		-- cooldown
		if (duration and duration > 0 and endTime and endTime > 0) then
			aura.cooldown:SetCooldown(endTime - duration, duration);
		else
			aura.cooldown:Hide();
		end

		-- texture + count
		aura.icon:SetTexture(iconTexture);
		aura.count:SetText(count and count > 1 and count or "");

		-- border for debuffs
		if (auraType == "HARMFUL") then
			local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
			aura.border:SetVertexColor(color.r, color.g, color.b);
			aura.border:Show();
		else
			aura.border:Hide();
		end

		aura:Show();
		auraFrameIndex = auraFrameIndex + 1;
		queryIndex = queryIndex + 1;
	end

	-- return the number of auras displayed
	return (auraFrameIndex - auraOffset);
end

local auraCount = 1;
local function UpdateAuras(unit)
	auraCount = 1;
	auraCount = auraCount + DisplayAuras(unit, "HELPFUL", auraCount);
	auraCount = auraCount + DisplayAuras(unit, "HARMFUL", auraCount);
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
		tooltip.NineSlice:SetBorderColor(classColor:GetRGB());

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
			local fullName = pvpName or name;
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
						targetClassColor:WrapTextInColorCode(pvpName or name) ..
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

			-- class
			if (className) then
				table.insert(tbl, classColor:WrapTextInColorCode(className));
			end

			-- reaction
			if (reaction) then
				table.insert(tbl, reactionColor:WrapTextInColorCode(reactionText));
			end

			getTextLeft(tooltip, guild and 3 or 2):SetText(table.concat(tbl, " "));
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
		tooltip.NineSlice:SetBorderColor(colorDefaultBorder:GetRGB());

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

	-- Add status bars
	if (not healthBar:IsShown()) then
		local hasPower = UnitPowerMax(unit) > 0;

		GameTooltip_AddBlankLinesToTooltip(tooltip, hasPower and 3 or 2);
		local lastLine = getTextLeft(tooltip, tooltip:NumLines() - (hasPower and 2 or 1));
		tooltip:Show();

		UpdateStatusBars(unit, hasPower);

		healthBar:ClearAllPoints();
		healthBar:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, hasPower and 8 or 5);
		healthBar:SetPoint("TOPRIGHT", tooltip, "RIGHT", -10, hasPower and 8 or 5);
		healthBar:Show();

		if (hasPower) then
			powerBar:ClearAllPoints();
			powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -BAR_SPACING);
			powerBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, -BAR_SPACING);
			powerBar:Show();
		end
	end

	tooltip:Show(); -- to trigger size update
	UpdateAuras(unit);
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnUnit);
GameTooltip:HookScript("OnTooltipCleared", Reset);

-- handle unit updates
local f = CreateFrame("frame");
f:RegisterEvent("UNIT_HEALTH");
f:RegisterEvent("UNIT_MAXHEALTH");
f:RegisterEvent("UNIT_DISPLAYPOWER");
f:RegisterEvent("UNIT_POWER_UPDATE");
f:RegisterEvent("UNIT_MAXPOWER");
f:RegisterEvent("UNIT_NAME_UPDATE");
f:RegisterEvent("UNIT_AURA");
f:SetScript("OnEvent", function(self, event, unit, ...)
	if ((event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER") and currentGuid == UnitGUID(unit)) then
		UpdateStatusBars(unit, UnitPowerMax(unit) > 0);
	end

	if (event == "UNIT_AURA" and currentGuid == UnitGUID(unit)) then
		UpdateAuras(unit);
	end

	if (event == "UNIT_NAME_UPDATE") then
		OnUnit(GameTooltip);
	end
end);
