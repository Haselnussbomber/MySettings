local _, addon = ...

local module = addon:NewModule("Details", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED")
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "Details") then
		return
	end

	self:UnregisterEvent("ADDON_LOADED")

	GameMenuButtonLogout:HookScript("OnClick", function(self)
		Details:ResetSegmentData();
	end)

	GameMenuButtonQuit:HookScript("OnClick", function(self)
		Details:ResetSegmentData();
	end)
end
