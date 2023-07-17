EventUtil.ContinueOnAddOnLoaded("AppearanceTooltip", function()
	-- same as in ../Tooltip/Style.lua
	local tooltip = AppearanceTooltipTooltip;

	if (not tooltip.SetBackdrop) then
		_G.Mixin(tooltip, _G.BackdropTemplateMixin);
		tooltip:HookScript('OnSizeChanged', tooltip.OnBackdropSizeChanged);
	end

	local edgeSize = 0.52 / UIParent:GetScale();

	tooltip:SetBackdrop({
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		bgFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize = edgeSize
	});

	tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.8);
	tooltip:SetBackdropBorderColor(0.8, 0.8, 0.8);

	tooltip:HookScript("OnShow", function(tooltip, parent)
		if (tooltip.NineSlice) then
			tooltip.NineSlice:Hide();
		end
	end);

	for _, key in ipairs({ "model", "modelZoomed", modelWeapon }) do
		tooltip[key]:ClearAllPoints();
		tooltip[key]:SetPoint("TOPLEFT", tooltip, "TOPLEFT", edgeSize, -edgeSize)
		tooltip[key]:SetPoint("BOTTOMRIGHT", tooltip, "BOTTOMRIGHT", -edgeSize, edgeSize * 2)
	end
end);
