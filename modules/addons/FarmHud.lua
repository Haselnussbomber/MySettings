local _, addon = ...

local module = addon:NewModule("FarmHud", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED")
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "FarmHud") then
		return
	end

	self:UnregisterEvent("ADDON_LOADED")

	SLASH_FARMHUD1 = "/farmhud"
	SlashCmdList["FARMHUD"] = function(msg)
		FarmHud:Toggle()
	end
end
