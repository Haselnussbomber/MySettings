local lastFactionId = 0;
local lastStanding = 0;
local ticks = 0; -- in seconds

C_Timer.NewTicker(1, function()
	local watchedFactionData = C_Reputation.GetWatchedFactionData();
	if not watchedFactionData or watchedFactionData.factionID == 0 then
		return;
	end

	-- faction or value change
	if (lastFactionId ~= watchedFactionData.factionID or lastStanding ~= watchedFactionData.currentStanding) then
		lastFactionId = watchedFactionData.factionID;
		lastStanding = watchedFactionData.currentStanding;
		ticks = 0;
		return;
	end

	if (ticks > 4) then
		if (lastFactionId ~= 0) then
			C_Reputation.SetWatchedFactionByID(0);
			lastFactionId = 0;
			lastStanding = 0;
		end

		ticks = 0;
	else
		ticks = ticks + 1;
	end
end);
