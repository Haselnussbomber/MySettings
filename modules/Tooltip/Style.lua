-- reposition anchor
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, 0);

	-- reset border color here, because it's basically called every time
	tooltip.NineSlice:SetBorderColor(0.25, 0.25, 0.25);
end);

local function OnGeneric(tooltip)
	tooltip.NineSlice:SetBorderColor(1, 1, 1, 1);
end

local function handleItemLink(tooltip, itemLink)
	local _, _, itemRarity = GetItemInfo(itemLink);
	local linkType = LinkUtil.ExtractLink(itemLink);
	if (linkType == "keystone") then
		itemRarity = 4;
	end
	local r, g, b = GetItemQualityColor(itemRarity or 0);
	tooltip.NineSlice:SetBorderColor(r, g, b, 1);
end

local function OnItem(tooltip)
	if (not (tooltip == GameTooltip or tooltip == ItemRefTooltip)) then
		return;
	end

	local _, itemLink = tooltip:GetItem();
	if (itemLink) then
		handleItemLink(tooltip, itemLink);
	end
end

local function OnToy(tooltip)
	local tooltipData = tooltip:GetTooltipData();
	local itemID = tooltipData.args[2].intVal;
	local itemLink = C_ToyBox.GetToyLink(itemID);
	handleItemLink(tooltip, itemLink);
end

local function OnPet(tooltip)
	local _, _, _, _, rarity = C_PetJournal.GetPetStats(id); -- not sure yet
	if (rarity) then
		local r, g, b = GetItemQualityColor(rarity - 1);
		tooltip.NineSlice:SetBorderColor(r, g, b, 1);
		-- TODO: color name
	end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnGeneric);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, OnGeneric);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, OnGeneric);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItem);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, OnToy);
--TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.BattlePet, OnPet);

-- always hide default status bars
GameTooltipStatusBar:HookScript("OnShow", GameTooltipStatusBar.Hide);
