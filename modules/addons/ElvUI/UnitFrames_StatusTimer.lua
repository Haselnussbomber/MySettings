local _, addon = ...

local module = addon:NewModule("ElvUIStatusTimer", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED")
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "ElvUI") then
		return
	end

	self:UnregisterEvent("ADDON_LOADED")

	local ElvUF = ElvUI.oUF

	local statustimer = ElvUF.Tags.Methods.statustimer
	ElvUF.Tags.Methods.statustimer = function(unit)
		local output = statustimer(unit)
		if (output) then
			return "|r\n" .. output
		end
	end
end
