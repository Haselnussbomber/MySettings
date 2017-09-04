local addonName, addon = ...

local Module = {
	name = "addonfixes",
	events = { "PLAYER_ENTERING_WORLD" }
}

function Module:OnEvent()
	C_Timer.After(5, function()

		-- hide vendor price when TSM is active
		if IsAddOnLoaded("TradeSkillMaster") then
			GameTooltip_OnTooltipAddMoney = function() end
		end

		-- hide vuhdo minimap button
		if IsAddOnLoaded("VuhDo") and VuhDoMinimapButton then
			VuhDoMinimapButton:SetShown(false);
		end

	end)
end

addon:Register(Module)
