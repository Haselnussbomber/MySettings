local _, addon = ...

if addon.IsForever then
	EventUtil.RegisterOnceFrameEventAndCallback("EDIT_MODE_LAYOUTS_UPDATED", function(layoutInfo, reconcileLayouts)
		MainStatusTrackingBarContainer:SetSize(MainActionBar:GetWidth(), STATUS_BAR_MANAGER_HEIGHT);
		StatusTrackingBarManager:CheckForLayoutChange();
		StatusTrackingBarManager:UpdateBarVisuals(true);
	end);
else
	StatusTrackingBarManager:Hide();
end
