local addonName, addon = ...;
local name = ("%s_%s"):format(addonName, "WeaponSkill");
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local dataObject = ldb:NewDataObject(name);
local WeaponSkillTitle = "Waffenfertigkeiten"
local frame = CreateFrame("Frame", name .. "_Frame");

FrameUtil.RegisterFrameForEvents(frame, { "PLAYER_EQUIPMENT_CHANGED", "SKILL_LINES_CHANGED", "CHARACTER_POINTS_CHANGED" });

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
				if (skillName == C_Item.GetItemSubClassInfo(Enum.ItemClass.Weapon, subClassID)) then
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
