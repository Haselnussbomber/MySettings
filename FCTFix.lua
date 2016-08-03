C_Timer.After(3, function()
	SetCVar("enableFloatingCombatText", 1)
	SetCVar("floatingCombatTextCombatDamage", 1)              -- Schaden
	SetCVar("floatingCombatTextCombatLogPeriodicSpells", 1)   -- Schaden über Zeit
	SetCVar("floatingCombatTextPetMeleeDamage", 1)            -- Begleiterschaden

	SetCVar("floatingCombatTextCombatHealing", 1)             -- Healing
	SetCVar("floatingCombatTextCombatHealingAbsorbTarget", 1) -- Schilde
	SetCVar("floatingCombatTextFriendlyHealers", 1)           -- Namen verbündeter Heiler

	-- from HideHealingText <https://mods.curse.com/addons/wow/hidehealingtext>
	COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"]["show"]        = nil;
	COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL_CRIT"]["show"]   = nil;
	COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL_ABSORB"]["show"] = nil;
	COMBAT_TEXT_TYPE_INFO["HEAL"]["show"]                 = nil;
	COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"]["show"]            = nil;
	COMBAT_TEXT_TYPE_INFO["HEAL_ABSORB"]["show"]          = nil;
	COMBAT_TEXT_TYPE_INFO["HEAL_CRIT_ABSORB"]["show"]     = nil;
end)
