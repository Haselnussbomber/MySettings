local function hook(self)
	local powerMax = UnitPowerMax("player", Enum.PowerType.Mana)
	if powerMax <= 0 then
		return
	end

	local numLines = self:NumLines()
	for i = 1, numLines do
		local line = _G[self:GetName().."TextLeft"..i]
		local text = line:GetText()
		local power = tonumber(text:match("(%d+) Mana") or 0)
		if power > 0 then
			local percent = tonumber(power) / powerMax * 100
			line:SetText(string.format("%s (%.2f%%)", text, percent))
			return
		end
	end
end

hooksecurefunc(GameTooltip, "SetAction", hook)
hooksecurefunc(GameTooltip, "SetSpellBookItem", hook)
hooksecurefunc(GameTooltip, "SetSpellByID", hook)

if (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then
	C_Timer.After(3, function()
		if WhatsTrainingTooltip then
			hooksecurefunc(WhatsTrainingTooltip, "SetSpellByID", hook)
		end
	end)
end
