local _, addon = ...

addon:RegisterAddonFix("+Wowhead_Looter", function()
	if (wlMinimapButton) then
		wlMinimapButton:SetShown(false)
        wlSetting.minimap = false
	end
end)
