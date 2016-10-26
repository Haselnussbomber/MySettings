C_Timer.After(3, function()
	--------------------------
	-- Floating Combat Text --
	--------------------------

	SetCVar("enableFloatingCombatText", 1)
	SetCVar("floatingCombatTextCombatDamage", 1)              -- Damage
	SetCVar("floatingCombatTextCombatLogPeriodicSpells", 1)   -- Damage over Time
	SetCVar("floatingCombatTextPetMeleeDamage", 1)            -- Pet Damage
	SetCVar("floatingCombatTextCombatHealing", 1)             -- Healing
	SetCVar("floatingCombatTextCombatHealingAbsorbTarget", 1) -- Shields
	SetCVar("floatingCombatTextFriendlyHealers", 1)           -- Healer Names

	-- from HideHealingText <https://mods.curse.com/addons/wow/hidehealingtext>
	COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"]["show"]        = nil;
	COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL_CRIT"]["show"]   = nil;
	COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL_ABSORB"]["show"] = nil;
	COMBAT_TEXT_TYPE_INFO["HEAL"]["show"]                 = nil;
	COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"]["show"]            = nil;
	COMBAT_TEXT_TYPE_INFO["HEAL_ABSORB"]["show"]          = nil;
	COMBAT_TEXT_TYPE_INFO["HEAL_CRIT_ABSORB"]["show"]     = nil;
end)
