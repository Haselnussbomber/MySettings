GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM.padding = nil;

local physicalWidth, physicalHeight = GetPhysicalScreenSize()
local resolution = format('%dx%d', physicalWidth, physicalHeight)
local perfect = 768 / physicalHeight
local scale = perfect / UIParent:GetScale()

-- setup backdrop
for _, tooltip in next, {
	_G.ItemRefTooltip,
	_G.ItemRefShoppingTooltip1,
	_G.ItemRefShoppingTooltip2,
	_G.AutoCompleteBox,
	_G.FriendsTooltip,
	_G.EmbeddedItemTooltip,
	_G.ReputationParagonTooltip,
	_G.GameTooltip,
	_G.WorldMapTooltip,
	_G.ShoppingTooltip1,
	_G.ShoppingTooltip2,
	_G.QuickKeybindTooltip,
} do
	if (not tooltip.SetBackdrop) then
		_G.Mixin(tooltip, _G.BackdropTemplateMixin);
		tooltip:HookScript('OnSizeChanged', tooltip.OnBackdropSizeChanged);
	end
	
	tooltip:SetBackdrop({
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		bgFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize = scale
	});

	tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.8);
end

hooksecurefunc("SharedTooltip_SetBackdropStyle", function(tooltip, parent)
	if (tooltip.NineSlice) then
		tooltip.NineSlice:Hide();
	end
end);

-- reposition anchor
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, 0);
end);

local itemDataLoadedCancelFunc;

local function OnTooltip(tooltip)
	if (itemDataLoadedCancelFunc) then
		itemDataLoadedCancelFunc();
		itemDataLoadedCancelFunc = nil;
	end

	if (tooltip.SetBackdropBorderColor) then
		tooltip:SetBackdropBorderColor(1, 1, 1, 1);
	end
end

local function handleItemLink(tooltip, itemLink)
	if (not itemLink) then
		return;
	end
	local _, _, itemRarity = GetItemInfo(itemLink);
	local linkType = LinkUtil.ExtractLink(itemLink);
	if (linkType == "keystone") then
		itemRarity = 4;
	end
	local r, g, b = GetItemQualityColor(itemRarity or 0);
	tooltip:SetBackdropBorderColor(r, g, b, 1);
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
		local tooltipData = TooltipComparisonManager:GetComparisonItemData(displayedItem);
		if (not tooltipData) then
			return;
		end

		TooltipUtil.SurfaceArgs(tooltipData);

		if (tooltipData.hyperlink) then
			handleItemLink(tooltip, tooltipData.hyperlink);
		elseif (tooltipData.guid) then
			handleItemLink(tooltip, C_Item.GetItemLinkByGUID(tooltipData.guid));
		elseif (tooltipData.id) then
			local item = Item:CreateFromItemID(tooltipData.id);
			itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
				handleItemLink(tooltip, item:GetItemLink());
			end);
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
		tooltip:SetBackdropBorderColor(r, g, b, 1);
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
