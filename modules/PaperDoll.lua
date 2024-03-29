local slots = {
	["HeadSlot"] = true,
	["NeckSlot"] = false,
	["ShoulderSlot"] = true,
	["BackSlot"] = false,
	["ChestSlot"] = true,
	["WristSlot"] = true,
	["MainHandSlot"] = true,
	["SecondaryHandSlot"] = true,
	["HandsSlot"] = true,
	["WaistSlot"] = true,
	["LegsSlot"] = true,
	["FeetSlot"] = true,
	["Finger0Slot"] = false,
	["Finger1Slot"] = false,
	["Trinket0Slot"] = false,
	["Trinket1Slot"] = false,
};

local levelColors = {
	[0] = "|cffff0000",
	[1] = "|cff00ff00",
	[2] = "|cffffff88",
};

-- http://www.wowwiki.com/ColorGradient
local function ColorGradient(perc, ...)
	if (perc >= 1) then
		return select(select('#', ...) - 2, ...);
	elseif (perc <= 0) then
		return ...;
	end

	local num = select('#', ...) / 3;
	local segment, relperc = math.modf(perc*(num-1));
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...);

	return r1+(r2-r1)*relperc, g1+(g2-g1)*relperc, b1+(b2-b1)*relperc;
end

local fontFileName = GameFontNormal:GetFont();

for k, showDurability in pairs(slots) do
	local frame = _G["Character" .. k];

	frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY");
	frame.ItemLevel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1);
	frame.ItemLevel:SetFont(fontFileName, 12, "THINOUTLINE");

	if (showDurability) then
		frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY");
		frame.DurabilityInfo:SetPoint("TOP", frame, "TOP", 0, -4);
		frame.DurabilityInfo:SetFont(fontFileName, 12, "THINOUTLINE");
	end
end

local function update()
	if (InCombatLockdown()) then
		return;
	end

	local avgEquipItemLevel = select(2, GetAverageItemLevel());

	for k, showDurability in pairs(slots) do
		local frame = _G["Character" .. k];
		local slot = GetInventorySlotInfo(k);

		frame.ItemLevel:SetText("");

		local itemLoc = ItemLocation:CreateFromEquipmentSlot(slot);
		if (itemLoc:IsValid()) then
			local itemLevel = C_Item.GetCurrentItemLevel(itemLoc);
			if (itemLevel) then
				if (avgEquipItemLevel) then
					local color = 2;
					if (itemLevel < avgEquipItemLevel - 10) then
						color = 0;
					elseif (itemLevel > avgEquipItemLevel + 10) then
						color = 1;
					end

					frame.ItemLevel:SetFormattedText("%s%d|r", levelColors[color], itemLevel);
				else
					frame.ItemLevel:SetFormattedText("%d", itemLevel);
				end
			end
		end

		if (showDurability) then
			frame.DurabilityInfo:SetText("");

			local current, maximum = GetInventoryItemDurability(slot);
			if (current and maximum) then
				local perc = current / maximum;

				local r, g, b = ColorGradient(
					perc,
					1, 0, 0,
					1, 1, 0,
					0, 1, 0
				);
				local color = CreateColor(r, g, b);
				local text = color:WrapTextInColorCode(("%.0f%%"):format(perc * 100));
				frame.DurabilityInfo:SetText(text);
			end
		end
	end
end

local timer;

local function onEvent()
	if (timer) then
		timer:Cancel();
		timer = nil;
	end

	timer = C_Timer.After(0.1, update);
end

PaperDollFrame:HookScript("OnShow", onEvent);
EventRegistry:RegisterFrameEventAndCallback("PLAYER_EQUIPMENT_CHANGED", onEvent);
EventRegistry:RegisterFrameEventAndCallback("UPDATE_INVENTORY_DURABILITY", onEvent);
