local addonName = ...;
local maskHover = "Interface\\Addons\\"..addonName.."\\media\\minimap-mask";
local maskDefault = "Interface\\ChatFrame\\ChatFrameBackground";

MinimapCompassTexture:Hide();

Minimap:SetMaskTexture(maskHover);

Minimap:HookScript("OnEnter", function()
	Minimap:SetMaskTexture(maskDefault);
end);

Minimap:HookScript("OnLeave", function()
	Minimap:SetMaskTexture(maskHover);
end);

-- move up
MinimapCluster.MinimapContainer.Minimap:ClearAllPoints();
MinimapCluster.MinimapContainer.Minimap:SetPoint("CENTER", MinimapCluster.MinimapContainer, -6, 22);

-- make this smaller
-- ExpansionLandingPageMinimapButton:SetScale(0.8);
-- ExpansionLandingPageMinimapButton:ClearAllPoints();
-- ExpansionLandingPageMinimapButton:SetPoint("BOTTOMLEFT", MinimapBackdrop, 20, 30);
