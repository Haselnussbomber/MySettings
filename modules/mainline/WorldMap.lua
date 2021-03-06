if (not IsAddOnLoaded("Blizzard_WorldMap")) then
	LoadAddOn("Blizzard_WorldMap");
end

-- hide tutorial button
WorldMapFrame.BorderFrame.Tutorial:Hide();
WorldMapFrame.BorderFrame.Tutorial:HookScript("OnShow", WorldMapFrame.BorderFrame.Tutorial.Hide);

-- scale world map
local scale = 1.25;
WorldMapFrame:SetScale(scale);

-- fix cursor position
WorldMapFrame.ScrollContainer.GetCursorPosition = function()
	local currentX, currentY = GetCursorPosition();
	local effectiveScale = WorldMapFrame:GetEffectiveScale();
	return currentX / effectiveScale, currentY / effectiveScale;
end;

-- handle minimize/maximize
hooksecurefunc(WorldMapFrame, "Maximize", function()
	WorldMapFrame:SetScale(1);
end);

hooksecurefunc(WorldMapFrame, "Minimize", function()
	WorldMapFrame:SetScale(scale);
end);
