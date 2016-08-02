C_Timer.After(3, function()
	SetCVar("enableFloatingCombatText", 1)
	SetCVar("floatingCombatTextCombatDamage", 1)              -- Schaden
	SetCVar("floatingCombatTextCombatLogPeriodicSpells", 1)   -- Schaden über Zeit
	SetCVar("floatingCombatTextPetMeleeDamage", 1)            -- Begleiterschaden

	SetCVar("floatingCombatTextCombatHealing", 1)             -- Healing
	SetCVar("floatingCombatTextCombatHealingAbsorbTarget", 1) -- Schilde
	SetCVar("floatingCombatTextFriendlyHealers", 1)           -- Namen verbündeter Heiler
end)
