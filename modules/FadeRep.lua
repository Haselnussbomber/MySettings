local lastId = 0;
local lastValue = 0;
local ticks = 0; -- in seconds

C_Timer.NewTicker(1, function()
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo();
	if (not name) then
		return;
	end

	-- faction or value change
	if (lastId ~= factionID or lastValue ~= value) then
		lastId = factionID;
		lastValue = value;
		ticks = 0;
		return;
	end

	if (ticks > 4) then
		if (lastId ~= 0) then
			SetWatchedFactionIndex(0);
			lastId = 0;
			lastValue = 0;
		end

		ticks = 0;
	else
		ticks = ticks + 1;
	end
end);
