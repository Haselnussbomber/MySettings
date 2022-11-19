local function ResetHeight(tooltip)
	tooltip.TextLeft1:SetHeight(0);
end

local function ShowIcon(tooltip, iconID)
	if (not iconID) then
		return;
	end

	local icon = CreateTextureMarkup(iconID, 64, 64, 24, 24, 0, 1, 0, 1);
	tooltip.TextRight1:SetFormattedText("%s  %s", tooltip.TextRight1:GetText() or "", icon);
	tooltip.TextRight1:Show();

	local leftHeight = tooltip.TextLeft1:GetHeight();
	local rightHeight = tooltip.TextRight1:GetHeight() * 0.8;
	if (leftHeight < rightHeight) then
		tooltip.TextLeft1:SetHeight(rightHeight);
	end
end

local function OnSpell(tooltip)
	local _, spellID = tooltip:GetSpell();
	local _, _, spellIcon = GetSpellInfo(spellID);
	ShowIcon(tooltip, spellIcon);
end

local function OnMount(tooltip)
	local tooltipData = tooltip:GetTooltipData();
	local _, _, icon = C_MountJournal.GetMountInfoByID(tooltipData.id);
	ShowIcon(tooltip, icon);
end

local function OnItem(tooltip)
	if (not (tooltip == GameTooltip or tooltip == ItemRefTooltip)) then
		return;
	end

	local tooltipData = tooltip:GetTooltipData();
	ShowIcon(tooltip, C_Item.GetItemIconByID(tooltipData.id));
end

local function OnToy(tooltip)
	local tooltipData = tooltip:GetTooltipData();
	ShowIcon(tooltip, C_Item.GetItemIconByID(tooltipData.id));
end

local function OnCurrency(tooltip)
	local tooltipData = tooltip:GetTooltipData();
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(tooltipData.id);
	ShowIcon(tooltip, currencyInfo and currencyInfo.iconFileID);
end

TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, ResetHeight);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnSpell);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, OnMount);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItem);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, OnToy);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, OnCurrency);

-- TODO: macro

-- LinkWrangler support
do
	local _, addon = ...;

	local module = addon:NewModule("LinkWrangler");

	function module:OnInitialize()
		self:RegisterEvent("ADDON_LOADED");
	end

	function module:ADDON_LOADED(_, addonName)
		if (addonName ~= "LinkWrangler") then
			return;
		end

		self:UnregisterEvent("ADDON_LOADED");

		local function callback(tooltip, link)
			local linkType, linkData = LinkUtil.SplitLinkData(link);
			if (linkType == "item") then
				ShowIcon(tooltip, Item:CreateFromItemLink(link):GetItemIcon());
			end
		end

		LinkWrangler.RegisterCallback("MySettings", callback, "show");
	end
end
