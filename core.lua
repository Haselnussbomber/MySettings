local addonName, addon = ...;

MySettings = LibStub("AceAddon-3.0"):NewAddon(addon, addonName);

MySettings:SetDefaultModuleLibraries("AceEvent-3.0");
