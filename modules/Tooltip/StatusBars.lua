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

local abbrevData = {
	breakpointData = {
		{
			breakpoint = 1e12,
			abbreviation = "B",
			significandDivisor = 1e10,
			fractionDivisor = 100,
			abbreviationIsGlobal = false,
		},
		{
			breakpoint = 1e11,
			abbreviation = "B",
			significandDivisor = 1e9,
			fractionDivisor = 1,
			abbreviationIsGlobal = false,
		},
		{
			breakpoint = 1e10,
			abbreviation = "B",
			significandDivisor = 1e8,
			fractionDivisor = 10,
			abbreviationIsGlobal = false,
		},
		{
			breakpoint = 1e9,
			abbreviation = "B",
			significandDivisor = 1e7,
			fractionDivisor = 100,
			abbreviationIsGlobal = false,
		},
		{
			breakpoint = 1e8,
			abbreviation = "M",
			significandDivisor = 1e6,
			fractionDivisor = 1,
			abbreviationIsGlobal = false,
		},
		{
			breakpoint = 1e7,
			abbreviation = "M",
			significandDivisor = 1e5,
			fractionDivisor = 10,
			abbreviationIsGlobal = false,
		},
		{
			breakpoint = 1e6,
			abbreviation = "M",
			significandDivisor = 1e4,
			fractionDivisor = 100,
			abbreviationIsGlobal = false,
		},
		{
			breakpoint = 1e5,
			abbreviation = "K",
			significandDivisor = 1000,
			fractionDivisor = 1,
			abbreviationIsGlobal = false,
		},
		{
			breakpoint = 1e4,
			abbreviation = "K",
			significandDivisor = 100,
			fractionDivisor = 10,
			abbreviationIsGlobal = false,
		},
	},
}

local function FormatValue(val)
	return AbbreviateNumbers(val, abbrevData);
end

local function UpdateStatusBars(unit)
	local cur = UnitHealth(unit);
	local max = UnitHealthMax(unit);
	local per = UnitHealthPercent(unit, nil, CurveConstants.ScaleTo100);

	healthBar:SetMinMaxValues(0, max);
	healthBar:SetValue(cur);
	healthBar.text:SetFormattedText("%s / %s (%d%%)", FormatValue(cur), FormatValue(max), per);

	local _, classFilename = UnitClass(unit);
	local classColor = RAID_CLASS_COLORS[classFilename] or RAID_CLASS_COLORS["PRIEST"];
	healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b);

	local powerType = UnitPowerType(unit);

	cur = UnitPower(unit, powerType);
	max = UnitPowerMax(unit, powerType);
	per = UnitPowerPercent(unit, powerType, nil, CurveConstants.ScaleTo100);

	powerBar:SetMinMaxValues(0, max);
	powerBar:SetValue(cur);
	powerBar.text:SetFormattedText("%s / %s (%d%%)", FormatValue(cur), FormatValue(max), per);
	if (powerType == 0) then
		powerBar:SetStatusBarColor(0.3, 0.55, 0.9);
	else
		local powerColor = PowerBarColor[powerType or 5];
		powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b);
	end
end

local function OnUnit(tooltip)
	if (C_PetBattles and C_PetBattles.IsInBattle()) then
		return;
	end

	local _, unit, guid = TooltipUtil.GetDisplayedUnit(tooltip);
	if (issecretvalue(unit) or issecretvalue(guid) or not unit) then
		Reset(tooltip);
		return;
	end

	currentGuid = guid;

	if (not healthBar:IsShown()) then
		GameTooltip_AddBlankLinesToTooltip(tooltip, 3);
		local lastLine = _G[tooltip:GetName() .. "TextLeft" .. (tooltip:NumLines() - 2)];
		tooltip:Show();

		UpdateStatusBars(unit);

		healthBar:ClearAllPoints();
		healthBar:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, 8);
		healthBar:SetPoint("TOPRIGHT", tooltip, "RIGHT", -10, 8);
		healthBar:Show();

		powerBar:ClearAllPoints();
		powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -BAR_SPACING);
		powerBar:SetPoint("TOPRIGHT", healthBar, "BOTTOMRIGHT", 0, -BAR_SPACING);
		powerBar:Show();
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
	if (InCombatLockdown()) then
		Reset(GameTooltip);
		return;
	end

	local guid = UnitGUID(unit);
	if (issecretvalue(guid) or issecretvalue(currentGuid)) then
		Reset(GameTooltip);
		return;
	end

	if (currentGuid == guid) then
		UpdateStatusBars(unit);
	end
end);
