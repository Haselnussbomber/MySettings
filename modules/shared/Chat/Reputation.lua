local CollapseFactionHeader = CollapseFactionHeader
local ExpandFactionHeader = ExpandFactionHeader
local GetFactionInfo = GetFactionInfo
local GetFactionInfoByID = GetFactionInfoByID
local GetNumFactions = GetNumFactions
local FACTION_STANDING_LABEL8 = FACTION_STANDING_LABEL8
local format = string.format

local textColor = "|cFFABD6F4"
local repColors = {}
for i, color in ipairs(FACTION_BAR_COLORS) do
	repColors[i] = CreateColor(color.r, color.g, color.b):GenerateHexColorMarkup()
end

local factions = {}
local function loadFactions()
	local numFactions = GetNumFactions()
	for i = 1, numFactions do
		local name, _, _, _, _, _, _, _, isHeader, _, _, _, _, factionID = GetFactionInfo(i)
		if isHeader == false then
			factions[name] = factionID
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", loadFactions)

local function replacer(message)
	local name, delta, change = message:match("Euer Ruf mit der Fraktion '(.*)' hat sich um (%d+) (%w+)")
	if not name then
		return message
	end

	local changeColor = "|cFF42FF42+"
	delta = tonumber(delta)
	if change == "verschlechtert" then
		delta = -delta
		changeColor = "|cFFFF4242-"
	end

	if factions[name] == nil then
		loadFactions()
		if factions[name] == nil then
			-- NOTE: if we get here, something is wrong. Probably found a new faction.
			return format("|cFF9B8900Neue Fraktion! %s%s %s%d", textColor, name, changeColor, delta)
		end
	end

	local _, _, standingID, bottomValue, topValue, earnedValue = GetFactionInfoByID(factions[name])
	local repStanding = _G["FACTION_STANDING_LABEL" .. standingID]
	if repStanding == FACTION_STANDING_LABEL8 then
		-- This is a paragon reward message.
		-- We need to subtrack from earned value till we are less than the topValue.
		while earnedValue > topValue do
			earnedValue = earnedValue - topValue
		end
	end

	local absDelta = math.abs(delta)
	local absTopValue = math.abs(topValue)
	local absBottomValue = math.abs(bottomValue)
	local repColor = repColors[standingID]
	local perDelta = math.floor(absDelta * 100 / (absTopValue - absBottomValue) * 10 + 0.5) / 10
	if perDelta == 0 then
		perDelta = tonumber(format("%.2f", math.floor(absDelta * 100 / (absTopValue - absBottomValue) * 100 + 0.5) / 100))
	end

	local msg
	if repStanding == FACTION_STANDING_LABEL8 then
		msg = format("%s%s%s schon %s%s%s.", textColor, name, textColor, repColor, repStanding, textColor)
	else
		local perTotal = math.floor(earnedValue * 100 / (absTopValue - absBottomValue) * 10 + 0.5) / 10
		if delta < 0 then
			perTotal = 100 - perTotal
		end
		msg =
			format(
			"%s%s %s%s (%s%%) %s- %s%s%s %d (%s%%)",
			textColor,
			name,
			changeColor,
			delta,
			perDelta,
			textColor,
			repColor,
			repStanding,
			textColor,
			(earnedValue - bottomValue),
			perTotal
		)
	end
	return msg
end

local function filter(_, _, message, ...)
	return false, replacer(message), ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", filter)
