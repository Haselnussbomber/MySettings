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
	cameraDistanceMaxZoomFactor = "2.6", -- https://blue.mmo-champion.com/topic/777685-zoom-slider-missing-on-ptr/
	cameraPitchMoveSpeed = "45",
	cameraPitchSmoothSpeed = "45",
	cameraSmoothStyle = "0",
	cameraSmoothTrackingStyle = "2",
	cameraYawMoveSpeed = "90",
	cameraYawSmoothSpeed = "170",

	-- Interface
	alwaysCompareItems = "1",
	autoDismountFlying = "1",
	autoLootDefault = "1",
	deselectOnClick = "1",
	enableFloatingCombatText = "1",
	interactOnLeftClick = "0",
	nameplateShowAll = "1",
	nameplateShowSelf = "0",

	-- Chat
	chatBubblesParty = "0",
	profanityFilter = "0",
	removeChatDelay = "1", -- disable hover delay

	-- Tutorials
	addFriendInfoShown = 1,
	pendingInviteInfoShown = 1,
	showNPETutorials = 0,
	showTokenFrame = 1,
	showTutorials = 0,
	talentFrameShown = 1,

	-- Graphics
	componentTextureLevel = "0",
	--outlineEngineMode = "2", -- what does it do?
	projectedTextures = "1",
	--RAIDoutlineEngineMode = "2", -- what does it do?

	-- Sound
	Sound_EnableDSPEffects = "0",
	Sound_EnableErrorSpeech = "0",
	Sound_EnableMusic = "0",
	Sound_EnableSoundWhenGameIsInBG = "1",

	-- Tutorials from AddOns\Blizzard_VoidStorageUI\Blizzard_VoidStorageUI.lua (#voidStorageTutorials)
	lastVoidStorageTutorial = 3,

	-- Tutorials from AddOns\Blizzard_GarrisonUI\Blizzard_OrderHallMissionUI.lua (seenAllTutorials)
	orderHallMissionTutorial = 0x000F0004,

	-- Tutorials from AddOns\Blizzard_GarrisonUI\Blizzard_GarrisonShipyardUI.lua
	shipyardMissionTutorialFirst = 1,
	shipyardMissionTutorialBlockade = 1,
	shipyardMissionTutorialAreaBuff = 1,
	dangerousShipyardMissionWarningAlreadyShown = 1,
}

function Module:PLAYER_ENTERING_WORLD()
    Module.PLAYER_ENTERING_WORLD = nil

	for cvar, value in pairs(cvars) do
		local current = tostring(GetCVar(cvar))
		if (current ~= value) then
			SetCVar(cvar, value)
		end
	end

	for key, value in pairs(_G) do
		if (string.sub(key, 0, 18) == "LE_FRAME_TUTORIAL_" and not GetCVarBitfield("closedInfoFrames", value)) then
			SetCVarBitfield("closedInfoFrames", value, true)
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
