local _, addon = ...

addon:RegisterAddonFix("VuhDo", function()
	if (VuhDoMinimapButton) then
		VuhDoMinimapButton:SetShown(false)
	end
end)
