local addonName, addon = ...;
local name = ("%s_%s"):format(addonName, "WeaponSkill");
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local dataObject = ldb:NewDataObject(name);
local WeaponSkillTitle = "Waffenfertigkeiten"
local frame = CreateFrame("Frame", name .. "_Frame");

FrameUtil.RegisterFrameForEvents(frame, { "PLAYER_EQUIPMENT_CHANGED", "SKILL_LINES_CHANGED", "CHARACTER_POINTS_CHANGED" });

-- Add more from here if needed https://github.com/Questie/Questie/blob/80ff80/Localization/Translations/WeaponSkills.lua

local weaponSkillLocales = {};

if GetLocale() == "deDE" then
	weaponSkillLocales = {
		[Enum.ItemWeaponSubclass.Axe1H] = "Äxte",
		[Enum.ItemWeaponSubclass.Axe2H] = "Zweihandäxte",
		[Enum.ItemWeaponSubclass.Bows] = "Bögen",
		[Enum.ItemWeaponSubclass.Guns] = "Schusswaffen",
		[Enum.ItemWeaponSubclass.Mace1H] = "Streitkolben",
		[Enum.ItemWeaponSubclass.Mace2H] = "Zweihandstreitkolben",
		[Enum.ItemWeaponSubclass.Polearm] = "Stangenwaffen",
		[Enum.ItemWeaponSubclass.Sword1H] = "Schwerter",
		[Enum.ItemWeaponSubclass.Sword2H] = "Zweihandschwerter",
		-- [Enum.ItemWeaponSubclass.Warglaive] = "",
		[Enum.ItemWeaponSubclass.Staff] = "Stäbe",
		-- [Enum.ItemWeaponSubclass.Bearclaw] = "",
		-- [Enum.ItemWeaponSubclass.Catclaw] = "",
		-- [Enum.ItemWeaponSubclass.Unarmed] = "",
		-- [Enum.ItemWeaponSubclass.Generic] = "",
		[Enum.ItemWeaponSubclass.Dagger] = "Dolche",
		[Enum.ItemWeaponSubclass.Thrown] = "Wurfwaffen",
		-- [Enum.ItemWeaponSubclass.Obsolete3] = "",
		[Enum.ItemWeaponSubclass.Crossbow] = "Armbrüste",
		-- [Enum.ItemWeaponSubclass.Wand] = "",
		-- [Enum.ItemWeaponSubclass.Fishingpole] = "",

		-- Faustwaffen?
	};
else
	-- probably not correct, but i don't play with the english client
	weaponSkillLocales = {
		[Enum.ItemWeaponSubclass.Axe1H] = "One-Handed Axes",
		[Enum.ItemWeaponSubclass.Axe2H] = "Two-Handed Axes",
		[Enum.ItemWeaponSubclass.Bows] = "Bows",
		[Enum.ItemWeaponSubclass.Guns] = "Guns",
		[Enum.ItemWeaponSubclass.Mace1H] = "One-Handed Maces",
		[Enum.ItemWeaponSubclass.Mace2H] = "Two-Handed Maces",
		[Enum.ItemWeaponSubclass.Polearm] = "Polearms",
		[Enum.ItemWeaponSubclass.Sword1H] = "One-Handed Swords",
		[Enum.ItemWeaponSubclass.Sword2H] = "Two-Handed Swords",
		-- [Enum.ItemWeaponSubclass.Warglaive] = "",
		[Enum.ItemWeaponSubclass.Staff] = "Staves",
		-- [Enum.ItemWeaponSubclass.Bearclaw] = "",
		-- [Enum.ItemWeaponSubclass.Catclaw] = "",
		-- [Enum.ItemWeaponSubclass.Unarmed] = "",
		-- [Enum.ItemWeaponSubclass.Generic] = "",
		[Enum.ItemWeaponSubclass.Dagger] = "Daggers",
		[Enum.ItemWeaponSubclass.Thrown] = "Thrown",
		-- [Enum.ItemWeaponSubclass.Obsolete3] = "",
		[Enum.ItemWeaponSubclass.Crossbow] = "Crossbows",
		-- [Enum.ItemWeaponSubclass.Wand] = "",
		-- [Enum.ItemWeaponSubclass.Fishingpole] = "",

		-- Fist Weapons?
	};
end

function dataObject:OnTooltipShow()
	self:ClearLines();
	self:AddLine(WeaponSkillTitle);

	local isWeaponSkills = false;
	for i = 1, GetNumSkillLines() do
		local skillName, header, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i);
		if (header) then
			isWeaponSkills = skillName == WeaponSkillTitle;
		else
			if (isWeaponSkills) then
				self:AddDoubleLine(skillName, ("%d/%d"):format(skillRank, skillMaxRank), 1, 1, 1);
			end
		end
	end
end

function dataObject:OnClick(button)
	if (CharacterFrame:IsVisible()) then
		HideUIPanel(CharacterFrame);
	else
		ShowUIPanel(CharacterFrame);
		local button = CharacterFrameTab4;
		PanelTemplates_Tab_OnClick(button, CharacterFrame);
		CharacterFrameTab_OnClick(button);
	end
end

local function Update()
	local itemLink = GetInventoryItemLink("player", INVSLOT_MAINHAND);
	local texture = GetInventoryItemTexture("player", INVSLOT_MAINHAND);
	if (not itemLink or not texture) then
		dataObject.icon = "";
		dataObject.text = "";
		return;
	end

	local classID, subClassID = select(6, C_Item.GetItemInfoInstant(itemLink));
	if (not classID or not subClassID or classID ~= Enum.ItemClass.Weapon) then
		dataObject.icon = "";
		dataObject.text = "";
		return;
	end

	local isWeaponSkills = false;
	for i = 1, GetNumSkillLines() do
		local skillName, header, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i);
		if (header) then
			isWeaponSkills = skillName == WeaponSkillTitle;
		else
			if (isWeaponSkills) then
				-- local subclassName = C_Item.GetItemSubClassInfo(Enum.ItemClass.Weapon, subClassID);
				if (weaponSkillLocales[subClassID] and skillName == weaponSkillLocales[subClassID]) then
					local color = addon:ColorGradient(skillRank / skillMaxRank, 1,0,0, 1,1,0, 0,1,0);
					dataObject.icon = texture;
					dataObject.text = color:WrapTextInColorCode(("%d/%d"):format(skillRank, skillMaxRank));
					return;
				end
			end
		end
	end

	dataObject.icon = "";
	dataObject.text = "";
end

frame:SetScript("OnEvent", Update);

FrameUtil.RegisterUpdateFunction(frame, 5, Update);

Update();
