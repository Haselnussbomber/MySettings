EventUtil.ContinueOnAddOnLoaded("Details", function()
	GameMenuButtonLogout:HookScript("OnClick", function()
		Details:ResetSegmentData();
	end);

	GameMenuButtonQuit:HookScript("OnClick", function()
		Details:ResetSegmentData();
	end);
end);
