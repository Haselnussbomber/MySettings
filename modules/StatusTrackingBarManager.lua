local _, addon = ...

if WOW_PROJECT_ID == WOW_PROJECT_CAMELOT then
	EventUtil.RegisterOnceFrameEventAndCallback("EDIT_MODE_LAYOUTS_UPDATED", function(layoutInfo, reconcileLayouts)
		MainStatusTrackingBarContainer:SetSize(MainActionBar:GetWidth(), STATUS_BAR_MANAGER_HEIGHT);
		StatusTrackingBarManager:CheckForLayoutChange();
		StatusTrackingBarManager:UpdateBarVisuals(true);
	end);
else
	StatusTrackingBarManager:Hide();
end
