local addonName, addon = ...;

addon.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
addon.IsBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC;
addon.IsMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE;

MySettings = LibStub("AceAddon-3.0"):NewAddon(addon, addonName);
