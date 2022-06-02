local _, classFilename = UnitClass("player");

local function LoadAddOnSafe(name)
  if (IsAddOnLoaded(name)) then
    return;
  end

  local loadable = select(4, GetAddOnInfo(name));
  if (not loadable) then
    return;
  end

  LoadAddOn(name);
end

-- addon already auto-disables when not monk
if (classFilename == "MONK") then
  LoadAddOnSafe("SilenceBanLu");
end

-- only my druid is night fae
if (classFilename == "DRUID") then
  LoadAddOnSafe("SoulshapeJournal");
else
  DisableAddOn("SoulshapeJournal");
end
