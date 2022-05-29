local _, addon = ...;

local module = addon:NewModule("FarmHud");

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED");
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "FarmHud") then
		return;
	end

	self:UnregisterEvent("ADDON_LOADED");

	SLASH_FARMHUD1 = "/farmhud";
	SlashCmdList["FARMHUD"] = function()
		FarmHud:Toggle();
	end
end
