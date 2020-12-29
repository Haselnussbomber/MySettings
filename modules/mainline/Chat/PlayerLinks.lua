-- replace names in loot messages with colored player links

if (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE) then
	return
end

-- multiple first!
local strings = {
	LOOT_ITEM_MULTIPLE,            -- %s erhält Beute: %sx%d.
	LOOT_ITEM,                     -- %s bekommt Beute: %s.
	LOOT_ITEM_BONUS_ROLL_MULTIPLE, -- %s erhält Bonusbeute: %sx%d.
	LOOT_ITEM_BONUS_ROLL,          -- %s erhält Bonusbeute: %s.
	LOOT_ITEM_PUSHED_MULTIPLE,     -- %s erhält den Gegenstand: %sx%d.
	LOOT_ITEM_PUSHED,              -- %s erhält den Gegenstand: %s.
	CREATED_ITEM_MULTIPLE,         -- %s stellt her: %sx%d.
	CREATED_ITEM,                  -- %s stellt her: %s.
};

for i=1,#strings do
	strings[i] = strings[i]:gsub("%.$", "%%."):gsub("(%%[sd])", "(.*)");
end

local filter = function(_, _, text, ...)
	local numGroup = GetNumGroupMembers();

	if (numGroup and numGroup > 1) then
		local inRaid = IsInRaid();

		for i=1,#strings do
			local match = text:match(strings[i]);
			if (match) then
				for i = 1, numGroup do
					local groupUnit = inRaid and ("raid"..i) or ("party"..i);
					if (UnitExists(groupUnit)) then
						local name, server = UnitNameUnmodified(groupUnit);
						if ((server and (name.."-"..server) == match) or name == match) then
							local _, _, classID = UnitClass(groupUnit);
							local classInfo = C_CreatureInfo.GetClassInfo(classID);
							local classColorInfo = RAID_CLASS_COLORS[classInfo.classFile];
							text = text:gsub(
								match:gsub("%-", "%%-"),
								GetPlayerLink(
									server and (name.."-"..server) or name,
									WrapTextInColorCode(match, classColorInfo.colorStr)
								)
							);
							return false, text, ...;
						end
					end
				end
				break;
			end
		end
	end

	return false, text, ...;
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", filter);
