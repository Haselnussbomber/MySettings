local _, addon = ...;

local GameTooltip = GameTooltip;
local ItemRefTooltip = ItemRefTooltip;

local DEFAULT_COLOR = CreateColor(0.2, 0.6, 1);

local itemTooltips = {
	GameTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
};
local textLeft = {};
for _, frame in pairs(itemTooltips) do
	for i = 1, 4 do
		local frameName = frame:GetName().."TextLeft"..i;
		if _G[frameName] then
			textLeft[frameName] = _G[frameName];
		end
	end
end

local conduits = {};
for i = 1, 284 do -- last id of https://wow.tools/dbc/?dbc=soulbindconduititem
	local x = C_Soulbinds.GetConduitSpellID(i, 1);
	if (x) then
		local name = GetSpellInfo(x);
		conduits[i] = { name = name, id = i, spellid = x };
	end
end

local function getConduit(name)
	for _,v in pairs(conduits) do
		if (v and v.name == name) then
			return v.id;
		end
	end
end

local function AddLine(self, text, color)
	local r, g, b = (color or DEFAULT_COLOR):GetRGB();
	local numLines = self:NumLines();

	for i = 1, numLines do
		local frameName = self:GetName().."TextLeft"..i;
		local line = textLeft[frameName] or _G[frameName];
		if (line:GetText() == text) then -- line already exists
			return;
		end
	end

	self:AddLine(text, r, g, b);
end

local function AddConduitInfo(self, id, itemName)
	if (C_Soulbinds.IsItemConduitByItemInfo(id)) then
		local conduitID = getConduit(itemName);
		if (conduitID) then
			local collectionData = C_Soulbinds.GetConduitCollectionData(conduitID);
			if (collectionData) then
				AddLine(self, ("Collected ItemLevel: %d"):format(collectionData.conduitItemLevel));
			end
		end
	end
end

local function AddRuneforgeLegendaryInfo(self, id)
	local runeforgePowerID = addon.RuneforgeLegendaryGetPowerIDByUnlockItemID(id);
	if (runeforgePowerID) then
		local _, _, classID = UnitClass("player");
		local specID = GetSpecializationInfo(GetSpecialization());
		local powers = C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant(classID, specID, nil, Enum.RuneforgePowerFilter.All);
		local learned = false;
		AddLine(self, " ");
		for _, power in pairs(powers) do
			if (power == runeforgePowerID) then
				AddLine(self, ALREADY_LEARNED, GREEN_FONT_COLOR);
				learned = true;
				break;
			end
		end
		if (not learned) then
			AddLine(self, TRADE_SKILLS_UNLEARNED_TAB, RED_FONT_COLOR);
		end
	end
end

local function OnTooltipSetItemHook(self)
	local itemName, itemLink = self:GetItem();
	if (not itemLink) then
		return;
	end

	local id = GetItemInfoInstant(itemLink);
	if (not id or id == 0) then
		return;
	end

	if (addon.IsMainline) then
		AddLine(self, ("ItemID: %d"):format(id));

		if (self:GetName() == "GameTooltip") then
			AddConduitInfo(self, id, itemName);
			AddRuneforgeLegendaryInfo(self, id);
		end
	else
		local iLvl = GetDetailedItemLevelInfo(id);
		AddLine(self, ("ItemID: %d, ItemLevel: %d"):format(id, iLvl));
	end

	-- trigger redraw to fit new line, but only if tooltip was visible
	if (self:IsVisible()) then
		self:Show();
	end
end

for _, frame in pairs(itemTooltips) do
	frame:HookScript("OnTooltipSetItem", OnTooltipSetItemHook);
end


-- aura/buff/debuff ids
local function setAuraTooltipFunction(self, unit, slotNumber, auraType)
	local casterUnit, _, _, id = select(7, UnitAura(unit, slotNumber, auraType));
	if (not id or id == 0) then
		return;
	end

	if (UnitExists(casterUnit)) then
		AddLine(self, ("Spell: %d, Caster: %s"):format(id, UnitName(casterUnit) or UNKNOWNOBJECT));
	else
		AddLine(self, ("Spell: %d"):format(id));
	end

	if (self:IsVisible()) then
		self:Show();
	end
end
hooksecurefunc(GameTooltip, "SetUnitAura", setAuraTooltipFunction);
hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HELPFUL") end);
hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HARMFUL") end);


-- spell ids
local function SetItemRefHook(link)
	local id = tonumber(link:match("spell:(%d+)"));
	if (not id or id == 0) then
		return;
	end

	AddLine(ItemRefTooltip, ("Spell: %d"):format(id));

	if (ItemRefTooltip:IsVisible()) then
		ItemRefTooltip:Show();
	end
end

hooksecurefunc("SetItemRef", SetItemRefHook);

local function OnTooltipSetSpellHook(self)
	local _, id = self:GetSpell();
	if (not id) then
		return;
	end

	AddLine(self, ("Spell: %d"):format(id));

	if (self:IsVisible()) then
		self:Show();
	end
end

GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpellHook);


-- quest ids
if (QuestMapLogTitleButton_OnEnter) then
	local function QuestMapLogTitleButtonOnEnterHook(self)
		if (not self.questID or self.questLogIndex) then
			return;
		end

		local info = C_QuestLog.GetInfo(self.questLogIndex);
		if (not info) then
			return;
		end

		AddLine(GameTooltip, ("QuestID: %d, QuestLevel: %d"):format(self.questID, info.level));

		if (GameTooltip:IsVisible()) then
			GameTooltip:Show();
		end
	end

	hooksecurefunc("QuestMapLogTitleButton_OnEnter", QuestMapLogTitleButtonOnEnterHook);
end


-- currencies
if (GameTooltip.SetCurrencyToken) then
	local function SetCurrencyTokenHook(self, index)
		local id = tonumber(string.match(C_CurrencyInfo.GetCurrencyListLink(index), "currency:(%d+)"));
		if (not id or id == 0) then
			return;
		end

		AddLine(self, ("CurrencyID: %d"):format(id));

		if (self:IsVisible()) then
			self:Show();
		end
	end

	hooksecurefunc(GameTooltip, "SetCurrencyToken", SetCurrencyTokenHook);
end


-- mawpower
if (addon.IsMainline) then
	local function SetHyperlinkHook(self, link)
		local id = tonumber(link:match("mawpower:(%d+)"));
		if (not id or id == 0) then
			return;
		end

		local spellID = addon.GetMawPowerSpellID(id);
		if (spellID) then
			AddLine(self, ("ID: %d, Spell: %d"):format(id, spellID));
		else
			AddLine(self, ("ID: %d"):format(id));
		end

		if (self:IsVisible()) then
			self:Show();
		end
	end

	hooksecurefunc(GameTooltip, "SetHyperlink", SetHyperlinkHook);
end
