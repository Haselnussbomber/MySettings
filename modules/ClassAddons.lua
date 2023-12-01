local _, classFilename = UnitClass("player");

local function LoadAddOnSafe(name)
	if (C_AddOns.IsAddOnLoaded(name)) then
		return;
	end

	local loadable = select(4, C_AddOns.GetAddOnInfo(name));
	if (not loadable) then
		return;
	end

	C_AddOns.LoadAddOn(name);
end

-- addon already auto-disables when not monk
if (classFilename == "MONK") then
	LoadAddOnSafe("SilenceBanLu");
end

-- only my druid is night fae
if (classFilename == "DRUID") then
	LoadAddOnSafe("SoulshapeJournal");
else
	C_AddOns.DisableAddOn("SoulshapeJournal");
end
