local addonName, addon = ...;

MySettings = LibStub("AceAddon-3.0"):NewAddon(addon, addonName);

MySettings:SetDefaultModuleLibraries("AceEvent-3.0");

function MySettings:OnInitialize()
  self.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
  self.IsBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC;
  self.IsMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE;
end
