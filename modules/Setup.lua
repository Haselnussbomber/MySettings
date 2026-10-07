_G["SLASH_SETUP1"] = "/setup";
SlashCmdList["SETUP"] = function()
	-- Enable all tinimap tracking types
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		C_Minimap.SetTracking(index, true);
	end

	-- Enable UI Layout
	local layoutInfo = C_EditMode.GetLayouts();
	for index, layoutInfo in ipairs(layoutInfo.layouts) do
		if layoutInfo.layoutName == "MyProfile" then
			C_EditMode.SetActiveLayout(#EditModePresetLayoutManager.presetLayoutInfo + index);
			C_EditMode.OnEditModeExit();
			break;
		end
	end

	-- Sort bags from top to bottom
	C_Container.SetInsertItemsLeftToRight(true);
	C_Container.SetSortBagsRightToLeft(true);

	-- Enable additional action bars
	Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", true);
	Settings.SetValue("PROXY_SHOW_ACTIONBAR_3", true);
	Settings.SetValue("PROXY_SHOW_ACTIONBAR_4", true);

	-- Kui Nameplates
	if (KuiNameplatesCoreCharacterSaved) then
		KuiNameplatesCoreCharacterSaved["profile"] = "MyProfile";
	end

	if (ACP) then
		ACP:DisableAll_OnClick();
		ACP:LoadSet(1);
	end

	-- /reflux switch MyProfile
	if (SlashCmdList["REFLUX"]) then
		SlashCmdList["REFLUX"]("switch MyProfile"); -- reloads ui!
	end
end;
