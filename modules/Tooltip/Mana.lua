local function OnSpell(self)
	if (self:IsForbidden()) then
		return;
	end

	local powerMax = UnitPowerMax("player", Enum.PowerType.Mana);
	if (powerMax <= 0) then
		return;
	end

	local numLines = self:NumLines();
	for i = 1, numLines do
		local line = _G[self:GetName().."TextLeft"..i];
		local text = line:GetText();
		if (text) then
			local power = tonumber(text:match("(%d+) Mana") or 0);
			if (power > 0) then
				local percent = tonumber(power) / powerMax * 100;
				line:SetText(string.format("%s (%.2f%%)", text, percent));
				self:Show();
				return;
			end
		end
	end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnSpell);
