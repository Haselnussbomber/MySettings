local function resize()
	WorldMapFrame:SetScale(1.15);
end

hooksecurefunc("WorldMap_ToggleSizeUp", resize);
hooksecurefunc("WorldMap_ToggleSizeDown", resize);

local original_WorldMapZoomOutButton_OnClick = WorldMapZoomOutButton_OnClick;

local redirectIds = {
	-- Order Halls
	[1044] = 1007, -- Temple of Five Dawns (Monk) -> Broken Isles
	[1048] = 1007, -- Emerald Dreamway (Druid) -> Broken Isles
	[1040] = 1007, -- Netherlight Temple (Priest) -> Broken Isles

	-- Raids
	[1088] = 1007, -- Nighthold -> Broken Isles
	[1114] = 1007, -- Trial of Valor -> Broken Isles

	-- World
	[37] = 689, -- Northern Stranglethorn -> Stranglethorn Vale
	[673] = 689, -- The Cape of Stranglethorn -> Stranglethorn Vale
};

WorldMapZoomOutButton_OnClick = function()
	local overrideId = redirectIds[GetCurrentMapAreaID()] or nil;

	if overrideId then
		SetMapByID(overrideId);
		return
	end

	original_WorldMapZoomOutButton_OnClick();
end
