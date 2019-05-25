local _, addon = ...

local GetCVar = GetCVar
local SetCVar = SetCVar
local GetCVarBitfield = GetCVarBitfield
local SetCVarBitfield = SetCVarBitfield

local Module = {
	name = "cvars",
	events = { "PLAYER_ENTERING_WORLD", "ADDON_LOADED" }
}

local cvars = {
	-- Camera
	cameraDistanceMaxZoomFactor = "3.4", -- https://www.wowinterface.com/downloads/info24927-MaxCamClassic.html
	cameraPitchMoveSpeed = "45",
	cameraPitchSmoothSpeed = "45",
	cameraSmoothStyle = "0",
	cameraSmoothTrackingStyle = "2",
	cameraYawMoveSpeed = "90",
	cameraYawSmoothSpeed = "170",

	-- Interface
	alwaysCompareItems = "1",
	autoLootDefault = "1",
	deselectOnClick = "1",
	enableFloatingCombatText = "1",
	interactOnLeftClick = "0",
	nameplateShowAll = "1",

	-- Chat
	chatBubblesParty = "0",
	profanityFilter = "0",
	removeChatDelay = "1", -- disable hover delay

	-- Tutorials
	addFriendInfoShown = 1,
	pendingInviteInfoShown = 1,
	showTokenFrame = 1,
	showTutorials = 0,
	talentFrameShown = 1,

	-- Graphics
	componentTextureLevel = "0",
	--outlineEngineMode = "2", -- what does it do?
	projectedTextures = "1",
	--RAIDoutlineEngineMode = "2", -- what does it do?

	-- Sound
	Sound_EnableErrorSpeech = "0",
	Sound_EnableMusic = "0",
	Sound_EnableSoundWhenGameIsInBG = "1",
}

if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
	-- Interface
	cvars.autoDismountFlying = "1";
	cvars.nameplateShowSelf = "0";

	-- Sound
	cvars.Sound_EnableDSPEffects = "0";

	-- Tutorials
	cvars.showNPETutorials = 0;

	-- Tutorials from AddOns\Blizzard_VoidStorageUI\Blizzard_VoidStorageUI.lua (#voidStorageTutorials)
	cvars.lastVoidStorageTutorial = 3;

	-- Tutorials from AddOns\Blizzard_GarrisonUI\Blizzard_OrderHallMissionUI.lua (seenAllTutorials)
	cvars.orderHallMissionTutorial = 0x000F0004;

	-- Tutorials from AddOns\Blizzard_GarrisonUI\Blizzard_GarrisonShipyardUI.lua
	cvars.shipyardMissionTutorialFirst = 1;
	cvars.shipyardMissionTutorialBlockade = 1;
	cvars.shipyardMissionTutorialAreaBuff = 1;
	cvars.dangerousShipyardMissionWarningAlreadyShown = 1;
else
	cvars.instantQuestText = 1;
	cvars.nameplateMaxDistance = "80";

	-- Action Bars (uvars)
	SHOW_MULTI_ACTIONBAR_1 = 1;
	SHOW_MULTI_ACTIONBAR_2 = 1;
	SHOW_MULTI_ACTIONBAR_3 = 1;
	SHOW_MULTI_ACTIONBAR_4 = 1;
	ALWAYS_SHOW_MULTIBARS = 1;
	InterfaceOptions_UpdateMultiActionBars();
end

function Module:PLAYER_ENTERING_WORLD()
    Module.PLAYER_ENTERING_WORLD = nil

	for cvar, value in pairs(cvars) do
		local current = tostring(GetCVar(cvar))
		if (current ~= value) then
			SetCVar(cvar, value)
		end
	end

	if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
		for key, value in pairs(_G) do
			if (string.sub(key, 0, 18) == "LE_FRAME_TUTORIAL_" and not GetCVarBitfield("closedInfoFrames", value)) then
				SetCVarBitfield("closedInfoFrames", value, true)
			end
		end
	end
end

function Module:ADDON_LOADED(arg1)
	if (arg1 == "Blizzard_CombatText") then
		Module.ADDON_LOADED = nil

		-- Combat Text (incoming)
		CombatText:Hide()
	end
end

addon:Register(Module)
