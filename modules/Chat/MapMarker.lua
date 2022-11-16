local match = string.match;
local gsub = string.gsub;
local GetMapInfo = C_Map.GetMapInfo;

local function replacer(link, linkData)
	local mapID, x, y = match(linkData, "^(%d+):(%d+):(%d+)$");
	local mapInfo = GetMapInfo(mapID);
	if (mapInfo) then
		return gsub(link, "|a [^%]]+", ("|a %s: %.2f, %.2f"):format(mapInfo.name, x/100, y/100));
	end
	return link;
end

local function filter(_, _, msg, ...)
	return false, gsub(msg, "(|?%x*|Hworldmap:(.-)|h.-|h|?r?)", replacer), ...;
end

for k in pairs(getmetatable(ChatTypeInfo).__index) do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..k, filter);
end
