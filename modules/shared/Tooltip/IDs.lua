local function AddLine(self, text)
	self:AddLine(text, 0.2, 0.6, 1);
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
		AddLine(self, ("ItemID: %d"):format(id))
	end
end
for _, frame in pairs(itemTooltips) do
	ItemRefTooltip:HookScript("OnTooltipSetItem", setItemHook)
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
hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("spell:(%d+)"))
	if (id) then
		AddLine(self, ("Spell: %d"):format(id))
	end
end)
GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local name, id = self:GetSpell()
	if (id) then
		AddLine(self, ("Spell: %d"):format(id))
	end
end)


-- quest ids
hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
	if (self.questID) and (self.questLogIndex) then
		local info = C_QuestLog.GetInfo(self.questLogIndex);
		AddLine(GameTooltip, ("QuestID: %d, QuestLevel: %d"):format(self.questID, info.level))
	end
end)
