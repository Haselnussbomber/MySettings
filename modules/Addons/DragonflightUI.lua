local addonName = ...;
local maskHover = "Interface\\Addons\\"..addonName.."\\media\\minimap-mask";
local maskDefault = "Interface\\ChatFrame\\ChatFrameBackground";

EventUtil.ContinueOnAddOnLoaded("DragonflightUI", function()
	local minimapModule = LibStub('AceAddon-3.0'):GetAddon('DragonflightUI'):GetModule("Minimap");
	hooksecurefunc(minimapModule.SubMinimap, "Update", function(submodule)
		MinimapCompassTexture:Hide();
		submodule.MinimapBorderSquare:Hide();
		Minimap:SetMaskTexture(maskHover);
	end);

	Minimap:HookScript("OnEnter", function()
		Minimap:SetMaskTexture(maskDefault);
	end);

	Minimap:HookScript("OnLeave", function()
		Minimap:SetMaskTexture(maskHover);
	end);

	BagsBar:Hide();
end);
