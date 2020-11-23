local _, addon = ...

local module = addon:NewModule("MinimalArchaeology", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED")
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "MinimalArchaeology") then
		return
	end

	self:UnregisterEvent("ADDON_LOADED")

	C_Timer.After(1, function()
		local Companion = MinArchCompanion

		local cooldown = CreateFrame("Cooldown", "$parentCooldown", Companion.surveyButton, "CooldownFrameTemplate");
		cooldown:SetAllPoints(Companion.surveyButton);
		cooldown:SetFrameStrata("TOOLTIP");

		Companion.events.SPELL_UPDATE_COOLDOWN = function()
			local start, duration, enable, modRate = GetSpellCooldown(SURVEY_SPELL_ID);
			CooldownFrame_Set(cooldown, start, duration, enable, false, modRate);
		end

		Companion:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	end)
end
