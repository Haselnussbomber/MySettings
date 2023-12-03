-- https://us.forums.blizzard.com/en/wow/t/1518446/23
EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", function()
	local activities = C_PerksActivities.GetTrackedPerksActivities();
	if activities and activities.trackedIDs then
		for _, id in next, activities.trackedIDs do
			C_PerksActivities.RemoveTrackedPerksActivity(id);
		end
	end
end);
