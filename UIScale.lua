local f = CreateFrame("Frame");

f:RegisterEvent("PLAYER_ENTERING_WORLD");

f:SetScript("OnEvent", function(self, event)
	f:UnregisterAllEvents();

	UIParent:SetScale(0.515); -- 0.5 * 1.03

	if ElvUIParent then
		ElvUIParent:SetSize(UIParent:GetSize());
	end
end);
