local cur = 0;
local max = 0;

local frame = CreateFrame("Frame");

frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_XP_UPDATE");

frame:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		cur = UnitXP("player");
		max = UnitXPMax("player");
	end

	if (event == "PLAYER_XP_UPDATE") then
		local new_cur = UnitXP("player");
		local new_max = UnitXPMax("player");
		local gained = 0;

		if (new_max > max) then
			-- special calculation on level up
			gained = (max - cur) + new_cur;
		else
			gained = new_cur - cur;
		end

		cur = new_cur;
		max = new_max;

		local remaining = max - cur;

		if (gained > 0 and remaining > 0) then
			local mobs = math.ceil(remaining / gained);
			print(string.format("|cff6f6fffErfahrung erhalten: %d (%d verbleibend, noch %dx)", gained, remaining, mobs));
		end
	end
end);
