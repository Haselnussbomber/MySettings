local addonName, addon = ...;

local module = addon:NewModule("ElvUIMinimap", "AceEvent-3.0");

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED");
end

function module:ADDON_LOADED(_, _addonName)
	if (_addonName ~= "ElvUI") then
		return;
	end

	self:UnregisterEvent("ADDON_LOADED");

	local E = ElvUI[1];
	local Minimap = Minimap;

	local maskHover = "Interface\\Addons\\"..addonName.."\\media\\minimap-mask";
	local maskDefault = "Interface\\ChatFrame\\ChatFrameBackground";

	local fn;

	fn = function()
		if (not Minimap.location) then
			C_Timer.After(1, fn);
			return;
		end

		E.db.general.minimap.locationText = 'MOUSEOVER';
		Minimap.location:Hide();

		Minimap:SetMaskTexture(maskHover);
		Minimap.backdrop:Hide();

		Minimap:HookScript("OnEnter", function()
			Minimap:SetMaskTexture(maskDefault);
			Minimap.backdrop:Show();
		end);

		Minimap:HookScript("OnLeave", function()
			Minimap:SetMaskTexture(maskHover);
			Minimap.backdrop:Hide();
		end);

		if (addon.IsClassic) then
			MinimapToggleButton:Hide();
		end
	end

	fn();
end
