local _, addon = ...;

local module = addon:NewModule("ElvUIShamanClassColor");

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED");
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "ElvUI") then
		return;
	end

	self:UnregisterEvent("ADDON_LOADED");

	local color = CreateColor(0.0, 0.44, 0.87); -- #0070DE
	color.colorStr = color:GenerateHexColor();
	RAID_CLASS_COLORS["SHAMAN"] = color;
end
