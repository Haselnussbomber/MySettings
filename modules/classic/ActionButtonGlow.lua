if (WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC) then
    return
end

local C_ActionBar = C_ActionBar
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local ActionButton_ShowOverlayGlow = ActionButton_ShowOverlayGlow
local ActionButton_HideOverlayGlow = ActionButton_HideOverlayGlow

local UnitExists = UnitExists
local UnitCanAttack = UnitCanAttack
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

local _, addon = ...
local playerClass = select(2, UnitClass("player"))

-- original by: https://gist.github.com/Konctantin/66d729abdb9379e79e7eff3a5060475d
local ACTION_BAR_TYPES = {
	"Action",
	"MultiBarBottomLeft",
	"MultiBarBottomRight",
	"MultiBarRight",
	"MultiBarLeft",
	-- Addons
	"DominosAction",
};

local function SetGlow(spellId, visible)
	local fn = visible and ActionButton_ShowOverlayGlow or ActionButton_HideOverlayGlow
    local actionList = C_ActionBar.FindSpellActionButtons(spellId)
	for _, actionID in ipairs(actionList) do
		for _, barName in pairs(ACTION_BAR_TYPES) do
			for i = 1, NUM_ACTIONBAR_BUTTONS do
				local button = _G[barName .. "Button" .. i]
				if button and button.action == actionID then
					fn(button)
				end
			end
		end
	end
end

local spells = {}

-- Paladin
if playerClass == "PALADIN" then
	-- Hammer of Wrath
	spells[24275] = function()
		return (
			UnitExists("target")
			and UnitCanAttack("player", "target")
			and not UnitIsDeadOrGhost("target")
			and (UnitHealth("target") / UnitHealthMax("target")) < 0.2
		)
	end
end

local module = addon:NewModule("ActionButtonGlow", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE", "Update")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "Update")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "Update")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "Update")
	self:RegisterEvent("UNIT_HEALTH", "Update")
end

function module.Update()
	for spellID, fn in pairs(spells) do
		SetGlow(spellID, fn())
	end
end
