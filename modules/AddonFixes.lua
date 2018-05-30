local addonName, addon = ...;

local Module = {
	name = "addonfixes",
	events = { "ADDON_LOADED" }
};

function Module:ADDON_LOADED(addon)
	-- hide vendor price when TSM is active
	if (addon == "TradeSkillMaster") then
		GameTooltip_OnTooltipAddMoney = function() end;
	end

	-- hide vuhdo minimap button
	if (addon == "VuhDo" and VuhDoMinimapButton) then
		VuhDoMinimapButton:SetShown(false);
	end
end

local unitStatus = {};
local statustimer = ElvUF.Tags.Methods['statustimer'];
ElvUF.Tags.Methods['statustimer'] = function(unit)
	local output = statustimer(unit);
	if (output) then
		return "|r\n" .. output;
	end
end

addon:Register(Module);
