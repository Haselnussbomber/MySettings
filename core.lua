local addonName, addon = ...;

MySettings = LibStub("AceAddon-3.0"):NewAddon(addon, addonName);

MySettings:SetDefaultModuleLibraries("AceEvent-3.0");

addon.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
addon.IsBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC;
addon.IsMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE;
