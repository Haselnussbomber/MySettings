C_Timer.After(5, function()

	-- hide vendor price when TSM is active
	if IsAddOnLoaded("TradeSkillMaster") then
		GameTooltip_OnTooltipAddMoney = function() end
	end

end);
