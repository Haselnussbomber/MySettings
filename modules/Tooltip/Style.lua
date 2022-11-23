-- reposition anchor
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, 0);

	-- reset border color here, because it's basically called every time
	tooltip.NineSlice:SetBorderColor(0.25, 0.25, 0.25);
end);

local function OnTooltip(tooltip)
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
	if (tooltip == GameTooltip or tooltip == ItemRefTooltip) then
		local _, itemLink = tooltip:GetItem();
		if (itemLink) then
			handleItemLink(tooltip, itemLink);
		end
	elseif (tooltip == ShoppingTooltip1 or tooltip == ShoppingTooltip2) then
		local isPrimaryTooltip = tooltip == ShoppingTooltip1;
		local displayedItem = isPrimaryTooltip and TooltipComparisonManager.compareInfo.item or TooltipComparisonManager:GetSecondaryItem();
		local itemData = TooltipComparisonManager:GetComparisonItemData(displayedItem);
		if not itemData then
			return;
		end

		TooltipUtil.SurfaceArgs(itemData);

		if (itemData.hyperlink) then
			handleItemLink(tooltip, itemData.hyperlink);
		elseif (itemData.guid) then
			handleItemLink(tooltip, C_Item.GetItemLinkByGUID(itemData.guid));
		elseif (itemData.id) then
			handleItemLink(tooltip, Item:CreateFromItemID(itemData.id):GetItemLink());
		end
	end
end

local function OnToy(tooltip)
	local tooltipData = tooltip:GetTooltipData();
	local itemLink = C_ToyBox.GetToyLink(tooltipData.id);
	handleItemLink(tooltip, itemLink);
end

--[[ doesn't do anything (yet?)
local function OnPet(tooltip)
	local tooltipData = tooltip:GetTooltipData();
	local _, _, _, _, rarity = C_PetJournal.GetPetStats(tooltipData.id);
	if (rarity) then
		local r, g, b = GetItemQualityColor(rarity - 1);
		tooltip.NineSlice:SetBorderColor(r, g, b, 1);
		tooltip.TextRight1:SetText(CreateColor(r, g, b):WrapTextInColorCode(tooltip.TextRight1:GetText()));
	end
end
]]--

TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, OnTooltip);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItem);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, OnToy);
--TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.BattlePet, OnPet);

-- always hide default status bars
GameTooltipStatusBar:HookScript("OnShow", GameTooltipStatusBar.Hide);
