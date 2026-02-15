local _, addon = ...;

local classNameLookup = {};

for classFilename, localizedName in pairs(LOCALIZED_CLASS_NAMES_MALE) do
    classNameLookup[localizedName] = classFilename;
end

for classFilename, localizedName in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
    classNameLookup[localizedName] = classFilename;
end

-- http://wowwiki.wikia.com/wiki/ColorGradient
function addon:ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...);
		return CreateColor(r, g, b, 1);
	elseif perc <= 0 then
		local r, g, b = ...;
		return CreateColor(r, g, b, 1);
	end

	local num = select('#', ...) / 3;

	local segment, relperc = math.modf(perc*(num-1));
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...);

	return CreateColor(r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc, 1);
end

function addon:GetClassColorByLocalizedName(name)
    local classFilename = classNameLookup[name];
    return classFilename and RAID_CLASS_COLORS[classFilename] or NORMAL_FONT_COLOR;
end
