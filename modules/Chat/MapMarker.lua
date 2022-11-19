local function replacer(link, linkData)
	local mapID, x, y = linkData:match("^(%d+):(%d+):(%d+)$");
	local mapInfo = C_Map.GetMapInfo(mapID);
	if (mapInfo) then
		return link:gsub("|a [^%]]+", ("|a %s: %.2f, %.2f"):format(mapInfo.name, x/100, y/100));
	end
	return link;
end

local function filter(_, _, msg, ...)
	return false, msg:gsub("(|?%x*|Hworldmap:(.-)|h.-|h|?r?)", replacer), ...;
end

for k in pairs(getmetatable(ChatTypeInfo).__index) do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..k, filter);
end
