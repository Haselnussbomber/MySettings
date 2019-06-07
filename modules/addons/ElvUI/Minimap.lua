local addonName, addon = ...

addon:RegisterAddonFix("ElvUI", function()
	local E = ElvUI[1]

	local maskHover = "Interface\\Addons\\"..addonName.."\\media\\minimap-mask"
	local maskDefault = "Interface\\ChatFrame\\ChatFrameBackground"

	E.db.general.minimap.locationText = 'MOUSEOVER'
	Minimap.location:Hide()

	Minimap:SetMaskTexture(maskHover)
	Minimap.backdrop:Hide()

	Minimap:HookScript("OnEnter", function()
		Minimap:SetMaskTexture(maskDefault)
		Minimap.backdrop:Show()
	end);

	Minimap:HookScript("OnLeave", function()
		Minimap:SetMaskTexture(maskHover)
		Minimap.backdrop:Hide()
	end)
end)
