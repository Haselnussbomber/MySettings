local _, addon = ...
local modf = math.modf
local InCombatLockdown = InCombatLockdown
local GetInventoryItemDurability = GetInventoryItemDurability
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemInfo = GetItemInfo

local LibItemUpgradeInfo = LibStub("LibItemUpgradeInfo-1.0")

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
}

local levelColors = {
	[0] = "|cffff0000",
	[1] = "|cff00ff00",
	[2] = "|cffffff88",
}

local function GetItemLevel(slot)
	local itemLink = GetInventoryItemLink("player", slot)
	if not itemLink then
		return nil
	end
	local itemLevel = select(4, GetItemInfo(itemLink))
	if not itemLevel then
		return nil
	end
	return tonumber(itemLevel)
end

local function GetAverageItemLevel()
	local itemCount, totalItemLevel = 0, 0

	for k in pairs(slots) do
		local slot = GetInventorySlotInfo(k)
		local itemLevel = GetItemLevel(slot)
		if itemLevel then
			itemCount = itemCount + 1
			totalItemLevel = totalItemLevel + itemLevel
		end
	end

	return totalItemLevel / itemCount
end

-- http://www.wowwiki.com/ColorGradient
local function ColorGradient(perc, ...)
	if perc >= 1 then
		return select(select('#', ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = select('#', ...) / 3
	local segment, relperc = modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1+(r2-r1)*relperc, g1+(g2-g1)*relperc, b1+(b2-b1)*relperc
end

local module = addon:NewModule("PaperDoll", "AceEvent-3.0", "AceTimer-3.0")

function module:OnInitialize()
	PaperDollFrame:HookScript("OnShow", function() module:OnEvent("PaperDollFrame_OnShow") end)
	local fontFileName = GameFontNormal:GetFont()

	for k, showDurability in pairs(slots) do
		local frame = _G["Character" .. k]

		frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY")
		frame.ItemLevel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
		frame.ItemLevel:SetFont(fontFileName, 12, "THINOUTLINE")

		if showDurability then
			frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY")
			frame.DurabilityInfo:SetPoint("TOP", frame, "TOP", 0, -4)
			frame.DurabilityInfo:SetFont(fontFileName, 12, "THINOUTLINE")
		end
	end

	module:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "OnEvent")
	module:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "OnEvent")

	self.locked = false
	self.initialized = true
end

function module:Update()
	local avgEquipItemLevel = GetAverageItemLevel()

	for k, showDurability in pairs(slots) do
		local frame = _G["Character" .. k]
		local slot = GetInventorySlotInfo(k)

		frame.ItemLevel:SetText("")

		local itemLink = GetInventoryItemLink("player", slot)
		local itemLevel = LibItemUpgradeInfo:GetUpgradedItemLevel(itemLink)
		if itemLevel and avgEquipItemLevel then
			local color = 2
			if itemLevel < avgEquipItemLevel - 10 then
				color = 0
			elseif itemLevel > avgEquipItemLevel + 10 then
				color = 1
			end

			frame.ItemLevel:SetFormattedText("%s%d|r", levelColors[color], itemLevel)
		end

		if showDurability then
			frame.DurabilityInfo:SetText("")

			local current, maximum = GetInventoryItemDurability(slot)
			if current and maximum then
				local perc = current / maximum

				local r, g, b = ColorGradient(
					perc,
					1, 0, 0,
					1, 1, 0,
					0, 1, 0
				)
				local color = CreateColor(r, g, b)
				local text = color:WrapTextInColorCode(("%.0f%%"):format(perc * 100))
				frame.DurabilityInfo:SetText(text)
			end
		end
	end

	self.locked = false
end

function module:OnEvent()
	if not self.initialized or self.locked or InCombatLockdown() then
		return
	end

	self.locked = true
	self:ScheduleTimer("Update", 0.1)
end
