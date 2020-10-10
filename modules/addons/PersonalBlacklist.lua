local _, addon = ...

local module = addon:NewModule("PersonalBlacklist", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED")
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "PersonalBlacklist") then
		return
	end

	self:UnregisterEvent("ADDON_LOADED")

	C_Timer.After(1, function()
		local PBL = LibStub("AceAddon-3.0"):GetAddon("PBL")
		PBL.db.profile.minimap.hide = false
		PBL:CommandThePBL()
	end)
end
