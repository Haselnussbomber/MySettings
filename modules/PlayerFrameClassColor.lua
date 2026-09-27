local healthBar = PlayerFrame_GetHealthBar();
local healthLossBar = PlayerFrame_GetHealthBarContainer().PlayerFrameHealthBarAnimatedLoss;

local _, playerClass = UnitClass("player");
local classColor = RAID_CLASS_COLORS[playerClass];

healthBar:GetStatusBarTexture():SetDesaturated(true);
healthLossBar:GetStatusBarTexture():SetDesaturated(true);

hooksecurefunc("UnitFrameHealthBar_Update", function(bar)
    if bar == healthBar and classColor then
        bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b);
        healthLossBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b);
    end
end);
