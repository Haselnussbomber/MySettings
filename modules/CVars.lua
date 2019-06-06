local _, addon = ...

local SetCVar = SetCVar -- from SharedXML/Util.lua
local GetCVarBitfield = C_CVar.GetCVarBitfield
local SetCVarBitfield = C_CVar.SetCVarBitfield

local Module = {
	name = "cvars",
	events = { "PLAYER_ENTERING_WORLD", "ADDON_LOADED" }
}

function Module:PLAYER_ENTERING_WORLD()
    Module.PLAYER_ENTERING_WORLD = nil

	-- see https://wow.gamepedia.com/Console_variables/Complete_list
	-- cameraDistanceMaxZoomFactor calculation by https://www.wowinterface.com/downloads/info24927-MaxCamClassic.html

	-- Camera
	SetCVar("cameraPitchMoveSpeed", 45)
	SetCVar("cameraSmoothStyle", 0)         -- Never adjust camera.
	SetCVar("cameraSmoothTrackingStyle", 0) -- Never adjust camera. (for click to move)
	SetCVar("cameraYawMoveSpeed", 90)

	-- Interface
	SetCVar("alwaysCompareItems", true)
	SetCVar("autoLootDefault", true)
	SetCVar("deselectOnClick", true)
	SetCVar("enableFloatingCombatText", true)
	SetCVar("interactOnLeftClick", false)
	SetCVar("nameplateShowAll", true)

	-- Chat
	SetCVar("chatBubblesParty", false)
	SetCVar("profanityFilter", false)

	-- Tutorials
	SetCVar("addFriendInfoShown", true)
	SetCVar("pendingInviteInfoShown", true)
	SetCVar("showTokenFrame", true)
	SetCVar("showTutorials", false)
	SetCVar("talentFrameShown", true)

	-- Graphics
	SetCVar("componentTextureLevel", 0) -- higher resolution for gear
	SetCVar("projectedTextures", true)
	--[[
	SetCVar("outlineEngineMode", 2)     -- TODO: 2? default is 0 - off. weird
	SetCVar("RAIDoutlineEngineMode", 2) -- TODO: 2? default is 0 - off. weird
	--]]

	-- Sound
	SetCVar("Sound_EnableErrorSpeech", false)
	SetCVar("Sound_EnableMusic", false)
	SetCVar("Sound_EnableSoundWhenGameIsInBG", true)

	if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
		-- Camera
		SetCVar("cameraDistanceMaxZoomFactor", 39 / 15)

		-- Interface
		SetCVar("autoDismountFlying", true)
		SetCVar("nameplateShowSelf", false) -- class ressource bar

		-- Tutorials
		SetCVar("showNPETutorials", false)

		-- Tutorials from AddOns\Blizzard_VoidStorageUI\Blizzard_VoidStorageUI.lua (#voidStorageTutorials)
		SetCVar("lastVoidStorageTutorial", 3)

		-- Tutorials from AddOns\Blizzard_GarrisonUI\Blizzard_OrderHallMissionUI.lua (seenAllTutorials)
		SetCVar("orderHallMissionTutorial", "0x000F0004")

		-- Tutorials from AddOns\Blizzard_GarrisonUI\Blizzard_GarrisonShipyardUI.lua
		SetCVar("shipyardMissionTutorialFirst", true)
		SetCVar("shipyardMissionTutorialBlockade", true)
		SetCVar("shipyardMissionTutorialAreaBuff", true)
		SetCVar("dangerousShipyardMissionWarningAlreadyShown", true)

		-- more Tutorials
		for key, value in pairs(_G) do
			if (string.sub(key, 0, 18) == "LE_FRAME_TUTORIAL_" and not GetCVarBitfield("closedInfoFrames", value)) then
				SetCVarBitfield("closedInfoFrames", value, true)
			end
		end
	else -- CLASSIC
		-- Camera
		SetCVar("cameraDistanceMaxZoomFactor", 50 / 15)

		-- Interface
		SetCVar("instantQuestText", true)

		-- Action Bars (uvars)
		SHOW_MULTI_ACTIONBAR_1 = 1
		SHOW_MULTI_ACTIONBAR_2 = 1
		SHOW_MULTI_ACTIONBAR_3 = 1
		SHOW_MULTI_ACTIONBAR_4 = 1
		ALWAYS_SHOW_MULTIBARS = 1
		InterfaceOptions_UpdateMultiActionBars()
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
