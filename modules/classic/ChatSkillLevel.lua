local function ConvertFormat(fmt)
	-- remove non-English format params like "%1$s"
	local find = string.gsub(fmt, "%%%d%$", "%%")

	-- remove any special characters with escaped versions
	find = string.gsub(find, "([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")

	-- finally replace standard "%s" and "%d"
	find = string.gsub(find, "%%s", "(.+)")
	find = string.gsub(find, "%%d", "(%%d+)")
	return find
end

local pattern = ConvertFormat(ERR_SKILL_UP_SI)

local function filter(_, _, msg, ...)
	local start, _, prof, rank = string.find(msg, pattern)

	if start then
		local numSkills = GetNumSkillLines();
		for i=1, numSkills do
			local skillName, _, _, _, _, _, skillMaxRank = GetSkillLineInfo(i);
			if skillName == prof then
				msg = string.gsub(msg, rank, rank.."/"..skillMaxRank)
			end
		end
	end

	return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SKILL", filter)
