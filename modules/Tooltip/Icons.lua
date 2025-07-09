local addonName = ...;

local function ShowIcon(tooltip, iconID)
	if (not iconID or not tooltip.TextLeft1 or not tooltip.TextRight1) then
		return;
	end

	local fakeicon = CreateTextureMarkup("Interface\\Addons\\"..addonName.."\\media\\transparent-64x64", 64, 64, 1, 22, 0, 1, 0, 1);
	tooltip.TextLeft1:SetFormattedText("%s%s", fakeicon, tooltip.TextLeft1:GetText() or "");
	tooltip.TextLeft1:Show();

	local icon = CreateTextureMarkup(iconID, 64, 64, 22, 22, 0, 1, 0, 1);
	tooltip.TextRight1:SetFormattedText("%s  %s", tooltip.TextRight1:GetText() or "", icon);
	tooltip.TextRight1:Show();
end

local function OnSpell(tooltip)
	local _, spellID = tooltip:GetSpell();
	local spellInfo = C_Spell.GetSpellInfo(spellID);
	ShowIcon(tooltip, spellInfo.iconID);
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

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnSpell);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, OnMount);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItem);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, OnToy);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, OnCurrency);

-- TODO: macro

-- LinkWrangler support
EventUtil.ContinueOnAddOnLoaded("LinkWrangler", function()
	local function callback(tooltip, link)
		local linkType, linkData = LinkUtil.SplitLinkData(link);
		if (linkType == "item") then
			ShowIcon(tooltip, Item:CreateFromItemLink(link):GetItemIcon());
		end
	end

	LinkWrangler.RegisterCallback("MySettings", callback, "show");
end);
