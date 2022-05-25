local _, addon = ...;

local GameTooltip = GameTooltip;
local ItemRefTooltip = ItemRefTooltip;

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
for i = 1, 284 do -- las id of https://wow.tools/dbc/?dbc=soulbindconduititem
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

local function AddLine(self, text)
	local numLines = self:NumLines();

	for i = 1, numLines do
		local frameName = self:GetName().."TextLeft"..i;
		local line = textLeft[frameName] or _G[frameName];
		if (line:GetText() == text) then -- line already exists
			return;
		end
	end

	self:AddLine(text, 0.2, 0.6, 1);
end

local setItemHook = function(self)
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

		if (self:GetName() == "GameTooltip" and C_Soulbinds.IsItemConduitByItemInfo(id)) then
			local conduitID = getConduit(itemName);
			if (conduitID) then
				local collectionData = C_Soulbinds.GetConduitCollectionData(conduitID);
				if (collectionData) then
					AddLine(self, ("Collected ItemLevel: %d"):format(collectionData.conduitItemLevel));
				end
			end
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
	frame:HookScript("OnTooltipSetItem", setItemHook);
end


-- aura/buff/debuff ids
local setAuraTooltipFunction = function(self, unit, slotNumber, auraType)
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
hooksecurefunc("SetItemRef", function(link)
	local id = tonumber(link:match("spell:(%d+)"));
	if (not id or id == 0) then
		return;
	end

	AddLine(ItemRefTooltip, ("Spell: %d"):format(id));

	if (ItemRefTooltip:IsVisible()) then
		ItemRefTooltip:Show();
	end
end);

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local _, id = self:GetSpell();
	if (not id) then
		return;
	end

	AddLine(self, ("Spell: %d"):format(id));

	if (self:IsVisible()) then
		self:Show();
	end
end);


-- quest ids
if (QuestMapLogTitleButton_OnEnter) then
	hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
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
	end);
end


-- currencies
if (GameTooltip.SetCurrencyToken) then
	hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
		local id = tonumber(string.match(C_CurrencyInfo.GetCurrencyListLink(index), "currency:(%d+)"));
		if (not id or id == 0) then
			return;
		end

		AddLine(self, ("CurrencyID: %d"):format(id));

		if (self:IsVisible()) then
			self:Show();
		end
	end);
end


-- mawpower
if (addon.IsMainline) then
	hooksecurefunc(GameTooltip, "SetHyperlink", function(self, link)
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
	end);
end
