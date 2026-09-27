local _, playerClass = UnitClass("player");
local classColor = RAID_CLASS_COLORS[playerClass];

local healthBar = PlayerFrame_GetHealthBar();

healthBar:GetStatusBarTexture():SetDesaturated(true);

hooksecurefunc("UnitFrameHealthBar_Update", function(bar)
    if bar == healthBar and classColor then
        bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b);
    end
end);
