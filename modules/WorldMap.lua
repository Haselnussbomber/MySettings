local resize = function()
	WorldMapFrame:SetScale(1.15)
end

hooksecurefunc("WorldMap_ToggleSizeUp", resize)
hooksecurefunc("WorldMap_ToggleSizeDown", resize)

hooksecurefunc("WorldMapZoomOutButton_OnClick", function()
	local areaID = GetCurrentMapAreaID();

	-- monk order hall or emerald dreamway
	if (areaID == 1044 or areaID == 1048) then
		SetMapByID(1007); -- broken isles
	end
end)
