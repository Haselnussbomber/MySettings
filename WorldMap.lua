local resize = function()
	WorldMapFrame:SetScale(1.15)
end

hooksecurefunc("WorldMap_ToggleSizeUp", resize)
hooksecurefunc("WorldMap_ToggleSizeDown", resize)

hooksecurefunc("WorldMapZoomOutButton_OnClick", function()
	if (GetCurrentMapAreaID() == 1044) then
		SetMapZoom(WORLDMAP_AZEROTH_ID);
	end
end)
