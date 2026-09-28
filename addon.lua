local addonName, addon = ...
local family = C_AddOns.GetAddOnMetadata(addonName, "X-Family")
local game = C_AddOns.GetAddOnMetadata(addonName, "X-Game")

addon.IsForever = family == "Mainline" and game == "Camelot";
