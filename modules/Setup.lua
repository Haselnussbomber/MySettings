SLASH_SETUP1 = "/setup";
SlashCmdList["SETUP"] = function()
	-- Minimap Tracking
	local trackingTextures = {
		136025, -- Mineraliensuche
		136456, -- Flugmeister
		237607, -- Niedrigstufige Quests

		136452, -- Auktionator
		136453, -- Bankier
		3852099, -- Barbier
		136458, -- Gastwirt
		136459, -- Briefkasten
		136465, -- Reparieren
		1598183, -- Transmogrifizierer
		524051, -- Fokusziel
	};
	local count = C_Minimap.GetNumTrackingTypes();
	for id=1, count do
		local _, texture, active = C_Minimap.GetTrackingInfo(id);
		if (tContains(trackingTextures, texture) and not active) then
			C_Minimap.SetTracking(id, true);
		end
	end

	-- UI Layout
	C_EditMode.SetActiveLayout(3);
	C_EditMode.OnEditModeExit();

	-- Kui Nameplates
	if (KuiNameplatesCoreCharacterSaved) then
		KuiNameplatesCoreCharacterSaved["profile"] = "MyProfile";
	end

	if (ACP) then
		ACP:DisableAll_OnClick();
		ACP:LoadSet(1);
	end

	-- /reflux switch MyProfile
	SlashCmdList["REFLUX"]("switch MyProfile"); -- reloads ui!
end;
