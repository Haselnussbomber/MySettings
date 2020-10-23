SLASH_SETUP1 = "/setup"
SlashCmdList["SETUP"] = function()
	-- AutoTurnIn
	if (AutoTurnInCharacterDB) then
	AutoTurnInCharacterDB["all"] = 3
	AutoTurnInCharacterDB["showrewardtext"] = false
	end

	-- Kui Nameplates
	KuiNameplatesCoreCharacterSaved["profile"] = "MyProfile"

	-- /reflux switch MyProfile
	SlashCmdList["REFLUX"]("switch MyProfile") -- reloads ui!
end
