local _, addon = ...;

local module = addon:NewModule("Dominos");

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED");
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "Dominos") then
		return;
	end

	self:UnregisterEvent("ADDON_LOADED");
	
	local QueueStatusBarModule = Dominos:GetModule("QueueStatusBar");
	QueueStatusBarModule.Load = function() end;
	QueueStatusBarModule:Unload();

	QueueStatusButton:SetFrameStrata("HIGH");
end
