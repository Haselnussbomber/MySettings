if (WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC) then
    return
end

local curXP = UnitXP("player")
local curMaxXP = UnitXPMax("player")
local remaining = 0
local function calcxpgain(new)
	if new > curXP then
		local d = new-curXP
		curXP = new
		return d
	else
		local d = curMaxXP-curXP+new
		curXP = new
		curMaxXP = UnitXPMax("player")
		return d
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:SetScript("OnEvent", function(self, event, ...)
	local xp = UnitXP("player")
	local xpMax = UnitXPMax("player")
	local gained = calcxpgain(xp)
	remaining = xpMax-xp
	local mobs = math.ceil(remaining/gained)

	print(string.format("|cff6f6fffErfahrung erhalten: %d (%d verbleibend, noch %dx)", gained, remaining, mobs))
end)
