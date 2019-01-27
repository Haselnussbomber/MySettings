local _, addon = ...

addon:RegisterAddonFix("TradeSkillMaster", function()
	GameTooltip_OnTooltipAddMoney = function() end
end)
