local addonName, addon = ...;

local Module = {
	name = "cvars",
	events = { "PLAYER_ENTERING_WORLD", "ADDON_LOADED" }
};

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

	-- Tutorials
	lastVoidStorageTutorial = 3, -- #voidStorageTutorials from AddOns\Blizzard_VoidStorageUI\Blizzard_VoidStorageUI.lua
	orderHallMissionTutorial = 0x000F0004, -- seenAllTutorials from AddOns\Blizzard_GarrisonUI\Blizzard_OrderHallMissionUI.lua
};

local tutorialFrameBits = {
	LE_FRAME_TUTORIAL_BRAWL,
	LE_FRAME_TUTORIAL_REPUTATION_EXALTED_PLUS,
	LE_FRAME_TUTORIAL_ARTIFACT_APPEARANCE_TAB,
	LE_FRAME_TUTORIAL_ARTIFACT_KNOWLEDGE,
	LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH,
	LE_FRAME_TUTORIAL_BAG_SETTINGS,
	LE_FRAME_TUTORIAL_BAG_SLOTS_AUTHENTICATOR,
	LE_FRAME_TUTORIAL_BONUS_ROLL_ENCOUNTER_JOURNAL_LINK,
	LE_FRAME_TUTORIAL_BOOSTED_SPELL_BOOK,
	--LE_FRAME_TUTORIAL_BOUNTY_FINISHED,
	--LE_FRAME_TUTORIAL_BOUNTY_INTRO,
	LE_FRAME_TUTORIAL_CLEAN_UP_BAGS,
	LE_FRAME_TUTORIAL_FRIENDS_LIST_QUICK_JOIN,
	LE_FRAME_TUTORIAL_GAME_TIME_AUCTION_HOUSE,
	LE_FRAME_TUTORIAL_GARRISON_BUILDING,
	LE_FRAME_TUTORIAL_GARRISON_LANDING,
	LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY,
	LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL_LEVEL,
	LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL_TAB,
	LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL,
	LE_FRAME_TUTORIAL_LFG_LIST,
	LE_FRAME_TUTORIAL_PET_JOURNAL,
	LE_FRAME_TUTORIAL_PROFESSIONS,
	LE_FRAME_TUTORIAL_REAGENT_BANK_UNLOCK,
	LE_FRAME_TUTORIAL_SPEC,
	LE_FRAME_TUTORIAL_SPELLBOOK,
	LE_FRAME_TUTORIAL_TALENT,
	LE_FRAME_TUTORIAL_TOYBOX_FAVORITE,
	LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING,
	LE_FRAME_TUTORIAL_TOYBOX,
	--LE_FRAME_TUTORIAL_TRADESKILL_RANK_STAR,
	--LE_FRAME_TUTORIAL_TRADESKILL_UNLEARNED_TAB,
	LE_FRAME_TUTORIAL_TRANSMOG_JOURNAL_TAB,
	LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK,
	LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN,
	LE_FRAME_TUTORIAL_TRANSMOG_SETS_TAB,
	LE_FRAME_TUTORIAL_TRANSMOG_SETS_VENDOR_TAB,
	LE_FRAME_TUTORIAL_TRANSMOG_SPECS_BUTTON,
	LE_FRAME_TUTORIAL_TRIAL_BANKED_XP,
	LE_FRAME_TUTORIAL_WORLD_MAP_FRAME,
};

function Module:PLAYER_ENTERING_WORLD()
	for cvar, value in pairs(cvars) do
		local current = tostring(GetCVar(cvar));
		if (current ~= value) then
			SetCVar(cvar, value);
		end
	end

	for cvar, value in pairs(tutorialFrameBits) do
		if (not GetCVarBitfield("closedInfoFrames", cvar)) then
			SetCVarBitfield("closedInfoFrames", cvar, true);
		end
	end
end

function Module:ADDON_LOADED(addon)
	if (addon == "Blizzard_CombatText") then
		-- Combat Text (incoming)
		CombatText:Hide();
	end
end

addon:Register(Module);
