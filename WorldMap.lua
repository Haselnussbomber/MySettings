local resize = function()
	WorldMapFrame:SetScale(1.15)
end

hooksecurefunc("WorldMap_ToggleSizeUp", resize)
hooksecurefunc("WorldMap_ToggleSizeDown", resize)
