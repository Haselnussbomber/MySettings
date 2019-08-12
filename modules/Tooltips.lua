if (WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC) then
    return
end

local SELL_PRICE_TEXT = format("%s:", SELL_PRICE)
local SELL_PRICE_TEXT_STACK = format("%s for %%d:", SELL_PRICE)

local function SellPriceHook(tooltip)
    if MerchantFrame:IsShown() then
        return
    end

	local itemLink = select(2, tooltip:GetItem())
	if not itemLink then
        return
    end

    local itemSellPrice = select(11, GetItemInfo(itemLink))
    if not itemSellPrice or itemSellPrice == 0 then
        return
    end

    local container = GetMouseFocus()
    local count = container.count
    if not count then
        count = (container.Count and container.Count:GetText())
    end
    if not count then
        count = container.Quantity and container.Quantity:GetText()
    end
    if not count then
        local button = container:GetName() and (container:GetName() .. "Count")
        count = button and _G[button] and _G[button]:GetText()
    end
    count = tonumber(count or 1)

    SetTooltipMoney(tooltip, itemSellPrice, nil, SELL_PRICE_TEXT)

    if count > 1 then
        SetTooltipMoney(tooltip, itemSellPrice * count, nil, SELL_PRICE_TEXT_STACK:format(count))
    end
end

GameTooltip:HookScript("OnTooltipSetItem", SellPriceHook)
ItemRefTooltip:HookScript("OnTooltipSetItem", SellPriceHook)
