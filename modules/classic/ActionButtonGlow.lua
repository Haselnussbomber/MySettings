local _, addon = ...;

local C_ActionBar = C_ActionBar;
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS;
local ActionButton_ShowOverlayGlow = ActionButton_ShowOverlayGlow;
local ActionButton_HideOverlayGlow = ActionButton_HideOverlayGlow;

local UnitExists = UnitExists;
local UnitCanAttack = UnitCanAttack;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitHealth = UnitHealth;
local UnitHealthMax = UnitHealthMax;

local playerClass = select(2, UnitClass("player"));

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
	local fn = visible and ActionButton_ShowOverlayGlow or ActionButton_HideOverlayGlow;
	local actionList = C_ActionBar.FindSpellActionButtons(spellId);
	if (actionList and #actionList > 0) then
		for _, actionID in ipairs(actionList) do
			for _, barName in pairs(ACTION_BAR_TYPES) do
				for i = 1, NUM_ACTIONBAR_BUTTONS do
					local button = _G[barName .. "Button" .. i];
					if (button and button.action == actionID) then
						fn(button);
					end
				end
			end
		end
	end
end

local spells = {};

-- Paladin
if (playerClass == "PALADIN") then
	-- Hammer of Wrath
	local hammerOfWrath = function()
		return (
			UnitExists("target")
			and UnitCanAttack("player", "target")
			and not UnitIsDeadOrGhost("target")
			and (UnitHealth("target") / UnitHealthMax("target")) < 0.2
		);
	end
	spells[24275] = hammerOfWrath; -- Rank 1
	spells[24274] = hammerOfWrath; -- Rank 2
	spells[24239] = hammerOfWrath; -- Rank 3
end

local module = addon:NewModule("ActionButtonGlow");

function module:OnInitialize()
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE", "Update");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "ResetSlot");
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "Update");
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "Update");
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "Update");
	self:RegisterEvent("UNIT_HEALTH", "Update");
end

function module:Update()
	for spellID, fn in pairs(spells) do
		SetGlow(spellID, fn());
	end
end

function module:ResetSlot(event, arg1)
	for _, barName in pairs(ACTION_BAR_TYPES) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local button = _G[barName .. "Button" .. i];
			if (button and (arg1 == 0 or arg1 == tonumber(button.action))) then
				ClearNewActionHighlight(button.action, true);
				ActionButton_StopFlash(button);
			end
		end
	end

	self:Update();
end
