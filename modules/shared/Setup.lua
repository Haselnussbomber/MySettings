SLASH_SETUP1 = "/setup"
SlashCmdList["SETUP"] = function()
	-- Minimap Tracking
	local trackingTextures = {
		136025, -- Mineraliensuche
		136456, -- Flugmeister
		237607, -- Niedrigstufige Quests

		136452, -- Auktionator
		136453, -- Bankier
		3852099, -- Barbier
		136458, -- Gastwirt
		136459, -- Briefkasten
		136465, -- Reparieren
		1598183, -- Transmogrifizierer
		524051, -- Fokusziel
	}
	local count = GetNumTrackingTypes();
	for id=1, count do
		local _, texture, active = GetTrackingInfo(id);
		if tContains(trackingTextures, texture) and not active then
			SetTracking(id, true);
		end
	end

	-- AutoTurnIn
	if (AutoTurnInCharacterDB) then
		AutoTurnInCharacterDB["all"] = 3
		AutoTurnInCharacterDB["showrewardtext"] = false
	end

	if (AAP1) then
		AAP1[AAP.Realm][AAP.Name]["Settings"] = {
			["LockArrow"] = 0,
			["Scale"] = 0.84,
			["AutoRepair"] = 0,
			["Greetings3"] = 0,
			["ChooseQuests"] = 0,
			["AutoGossip"] = 1,
			["Hide"] = 0,
			["ShowMap10s"] = 0,
			["ShowGroup"] = 1,
			["OrderListScale"] = 1,
			["WQs"] = 0,
			["leftLiz"] = 150,
			["BannerShow"] = 0,
			["topLiz"] = -150,
			["arrowtop"] = -851.5444946289062,
			["AutoAccept"] = 1,
			["CutScene"] = 1,
			["left"] = 1905.580810546875,
			["ShowBlobs"] = 1,
			["Greetings2"] = 1,
			["AutoHandIn"] = 1,
			["ArrowFPS"] = 2,
			["Lock"] = 0,
			["Hcampleft"] = 150,
			["Partytop"] = -300,
			["Greetings"] = 0,
			["ShowQList"] = 1,
			["ArrowScale"] = 0.98,
			["AutoShareQ"] = 0,
			["ShowArrow"] = 1,
			["Hcamptop"] = -150,
			["Partyleft"] = 853.3333984375,
			["MiniMapBlobAlpha"] = 1,
			["alpha"] = 1,
			["AutoHandInChoice"] = 0,
			["top"] = -274.5350341796875,
			["ShowMapBlobs"] = 1,
			["QuestButtonDetatch"] = 0,
			["ShowQuestListOrder"] = 0,
			["QuestButtons"] = 1,
			["DisableHeirloomWarning"] = 0,
			["arrowleft"] = 1271.580200195313,
			["AutoVendor"] = 0,
		}
	end

	-- Kui Nameplates
	KuiNameplatesCoreCharacterSaved["profile"] = "MyProfile"

	-- /reflux switch MyProfile
	SlashCmdList["REFLUX"]("switch MyProfile") -- reloads ui!
end
