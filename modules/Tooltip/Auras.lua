local AURA_SIZE = 20;
local AURA_MAX_ROWS = 2;

local currentGuid;
local auras = {};

local function Reset(self)
	currentGuid = nil;
	for _, aura in pairs(auras) do
		aura:Hide();
	end
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
		if (not name or not iconTexture or auraFrameIndex / aurasPerRow > AURA_MAX_ROWS) then
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

	UpdateAuras(unit);
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnUnit);
GameTooltip:HookScript("OnTooltipCleared", Reset);

-- handle unit updates
local f = CreateFrame("frame");
f:RegisterEvent("UNIT_AURA");
f:SetScript("OnEvent", function(self, event, unit, ...)
	if (event == "UNIT_AURA" and currentGuid == UnitGUID(unit)) then
		UpdateAuras(unit);
	end
end);
