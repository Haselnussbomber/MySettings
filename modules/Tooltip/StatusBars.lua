local healthBar = CreateFrame("STATUSBAR", nil, GameTooltip);
local powerBar = CreateFrame("STATUSBAR", nil, GameTooltip);

local BAR_MARGIN_X = 8;
local BAR_SPACING = 5;

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

local currentGuid;

local function Reset(self)
	currentGuid = nil;
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

	if (not healthBar:IsShown()) then
		local hasPower = UnitPowerMax(unit) > 0;

		GameTooltip_AddBlankLinesToTooltip(tooltip, hasPower and 3 or 2);
		local lastLine = _G[tooltip:GetName() .. "TextLeft" .. (tooltip:NumLines() - (hasPower and 2 or 1))];
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
f:SetScript("OnEvent", function(self, event, unit, ...)
	if (currentGuid == UnitGUID(unit)) then
		UpdateStatusBars(unit, UnitPowerMax(unit) > 0);
	end
end);
