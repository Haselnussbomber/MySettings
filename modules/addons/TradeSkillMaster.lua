local _, addon = ...;

addon:RegisterAddonFix("TradeSkillMaster", function(module)
	GameTooltip_OnTooltipAddMoney = function() end;
end);
