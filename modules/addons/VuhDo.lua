local _, addon = ...;

addon:RegisterAddonFix("VuhDo", function(module)
	if VuhDoMinimapButton then
		VuhDoMinimapButton:SetShown(false);
	end
end);
