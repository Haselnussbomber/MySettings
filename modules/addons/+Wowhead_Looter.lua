local _, addon = ...;

local module = addon:NewModule("Wowhead_Looter");

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED");
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "+Wowhead_Looter") then
		return;
	end

	self:UnregisterEvent("ADDON_LOADED");

	if (wlMinimapButton) then
		wlMinimapButton:SetShown(false);
		wlSetting.minimap = false;
	end
end
