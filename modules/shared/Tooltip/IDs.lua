local _, addon = ...

local function AddLine(self, text)
	local numLines = self:NumLines();
	local lineExists = false;
	for i = 1, numLines do
		local line = _G[self:GetName().."TextLeft"..i];
		local lineText = line:GetText();
		if (lineText == text) then
			lineExists = true;
		end
	end

	if (not lineExists) then
		self:AddLine(text, 0.2, 0.6, 1);
		self:Show();
	end
end

-- item ids
local itemTooltips = {
	GameTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
}
local setItemHook = function(self)
	local _, itemLink = self:GetItem();
	if (itemLink) then
		local id = GetItemInfoInstant(itemLink);
		if (id) then
			AddLine(self, ("ItemID: %d"):format(id))
		end
	end
end
for _, frame in pairs(itemTooltips) do
	frame:HookScript("OnTooltipSetItem", setItemHook)
end


-- aura/buff/debuff ids
local setAuraTooltipFunction = function(self, unit, slotNumber, auraType)
	local casterUnit, _, _, id = select(7, UnitAura(unit, slotNumber, auraType))
	if (id) then
		if (UnitExists(casterUnit)) then
			AddLine(self, ("Spell: %d, Caster: %s"):format(id, UnitName(casterUnit) or UNKNOWNOBJECT))
		else
			AddLine(self, ("Spell: %d"):format(id))
		end
	end
end
hooksecurefunc(GameTooltip, "SetUnitAura", setAuraTooltipFunction)
hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HELPFUL") end)
hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HARMFUL") end)


-- spell ids
hooksecurefunc("SetItemRef", function(link)
	local id = tonumber(link:match("spell:(%d+)"))
	if (id) then
		AddLine(ItemRefTooltip, ("Spell: %d"):format(id))
	end
end)
GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local name, id = self:GetSpell()
	if (id) then
		AddLine(self, ("Spell: %d"):format(id))
	end
end)


-- quest ids
if QuestMapLogTitleButton_OnEnter then
	hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
		if (self.questID) and (self.questLogIndex) then
			local info = C_QuestLog.GetInfo(self.questLogIndex);
			AddLine(GameTooltip, ("QuestID: %d, QuestLevel: %d"):format(self.questID, info.level))
		end
	end)
end


-- currencies
if GameTooltip.SetCurrencyToken then
	hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
		local id = tonumber(string.match(C_CurrencyInfo.GetCurrencyListLink(index), "currency:(%d+)"))
		if (id) then
			AddLine(GameTooltip, ("CurrencyID: %d"):format(id))
		end
	end)
end


-- mawpower
if (addon.IsMainline) then
	hooksecurefunc(GameTooltip, "SetHyperlink", function(self, link)
		local id = tonumber(link:match("mawpower:(%d+)"))
		if (id) then
			local spellID = addon.GetMawPowerSpellID(id)
			if (spellID) then
				AddLine(self, ("ID: %d, Spell: %d"):format(id, spellID))
			else
				AddLine(self, ("ID: %d"):format(id))
			end
		end
	end)
end
