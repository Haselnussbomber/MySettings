SLASH_SETUP1 = "/setup"
SlashCmdList["SETUP"] = function()
	-- AutoTurnIn
	AutoTurnInCharacterDB["all"] = 3
	AutoTurnInCharacterDB["showrewardtext"] = false

	-- Kui Nameplates
	KuiNameplatesCoreCharacterSaved["profile"] = "MyProfile"

	-- /reflux switch MyProfile
	SlashCmdList["REFLUX"]("switch MyProfile") -- reloads ui!
end
