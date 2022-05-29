local _, addon = ...;

local playerRealm = GetRealmName();

local module = addon:NewModule("PlayerLinks");
module.players = {};

local function processGUID(guid)
	if (not guid or module.players[guid]) then
		return;
	end

	local _, englishClass, _, _, _, name, realm = GetPlayerInfoByGUID(guid);
	if (realm == "") then
		realm = playerRealm;
	end

	module.players[guid] = {
		name = name,
		realm = realm,
		color = RAID_CLASS_COLORS[englishClass].colorStr
	};
end

local function getPlayerLink(player)
	local fullname = player.name .. "-" .. player.realm;
	local relativename = player.name;
	if (player.realm ~= playerRealm) then
		relativename = relativename .. "-" .. player.realm;
	end
	return GetPlayerLink(fullname, WrapTextInColorCode(relativename, player.color));
end

function module:OnInitialize()
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
end

function module:GROUP_ROSTER_UPDATE()
	local numGroup = GetNumGroupMembers();
	if (numGroup and numGroup > 1) then
		local inRaid = IsInRaid();
		for i = 1, numGroup do
			local groupUnit = inRaid and ("raid"..i) or ("party"..i);
			if (UnitExists(groupUnit)) then
				processGUID(UnitGUID(groupUnit));
			end
		end
	end
end

local filter = function(_, event, ...)
	processGUID(select(12, ...));

	local text = ...;
	local words = {};

	for word in text:gmatch("([^%s]+)") do
		table.insert(words, word);
	end

	for i = 1, #words do
		local word = words[i];

		for _, player in pairs(module.players) do
			local fullname = player.name .. "-" .. player.realm;
			if (word == fullname or word == player.name) then
				words[i] = getPlayerLink(player);
			end
		end
	end

	return false, table.concat(words, " "), select(2, ...);
end

for k in pairs(getmetatable(ChatTypeInfo).__index) do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..k, filter);
end
