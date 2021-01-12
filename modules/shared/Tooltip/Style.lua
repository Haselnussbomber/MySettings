local addonName, addon = ...;
local combineTables = addon.combineTables;

TOOLTIP_BACKDROP_STYLE_DEFAULT = {
	bgFile = "Interface/Buttons/WHITE8X8",
	edgeFile = "Interface/Addons/SharedMedia_MyMedia/border/Caith2.tga",
	tile = false,
	tileEdge = false,
	edgeSize = 10,
	insets = { left = 1, right = 1, top = 1, bottom = 1 },
	backdropColor = CreateColor(0.07, 0.07, 0.07, 0.9),
	backdropBorderColor = CreateColor(0.25, 0.25, 0.25, 1)
};

GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM = combineTables(TOOLTIP_BACKDROP_STYLE_DEFAULT, {
	overlayAtlasTop = "AzeriteTooltip-Topper";
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = 1;
	overlayAtlasBottom = "AzeriteTooltip-Bottom";
	overlayAtlasBottomYOffset = 2;
});

GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM = combineTables(TOOLTIP_BACKDROP_STYLE_DEFAULT, {
	overlayAtlasTop = "Nzoth-tooltip-topper";
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = -2;
});

GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY = combineTables(TOOLTIP_BACKDROP_STYLE_DEFAULT, {
	overlayAtlasTop = "Maw-tooltip-topper";
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = -2;
});


-- border colors
local handlers = {};

function handlers.item(self, id)
	local _, itemLink;
	if (id) then
		_, itemLink = GetItemInfo(id);
	else
		_, itemLink = self:GetItem();
	end
	if (not itemLink) then
		return;
	end
	local _, _, itemRarity = GetItemInfo(itemLink);
	local _, _, hyperLinkString = ExtractHyperlinkString(itemLink);
	local linkType = ExtractLinkData(hyperLinkString);
	if (linkType == "keystone") then
		itemRarity = 4;
	end
	local r, g, b = GetItemQualityColor(itemRarity or 0);
	self:SetBackdropBorderColor(r, g, b, 1);
end

function handlers.spell(self, id)
	self:SetBackdropBorderColor(1, 1, 1, 1);
end

function handlers.macro(self)
	self:SetBackdropBorderColor(1, 1, 1, 1);
end

function handlers.summonpet(self, id)
	local _, _, _, _, rarity = C_PetJournal.GetPetStats(id);
	if (rarity) then
		local r, g, b = GetItemQualityColor(rarity - 1);
		self:SetBackdropBorderColor(r, g, b, 1);
		-- TODO: color name
	end
end

function handlers.summonmount(self)
	self:SetBackdropBorderColor(1, 1, 1, 1);
end


-- handle action bars
hooksecurefunc(GameTooltip, "SetAction", function(self, slot)
	local actionType, id, subType = GetActionInfo(slot);
	if (handlers[actionType]) then
		handlers[actionType](self, id, subType);
	end
end);


-- handle items
local itemTooltips = {
	GameTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
}
for _, frame in pairs(itemTooltips) do
	SharedTooltip_SetBackdropStyle(frame, TOOLTIP_BACKDROP_STYLE_DEFAULT); -- OnLoad
	frame:HookScript("OnTooltipSetItem", handlers.item);
end


-- handle spells
GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local _, id = self:GetSpell();
	if (id) then
		handlers.spell(self, id);
	end
end);


-- handle shapeshift/auras
hooksecurefunc(GameTooltip, "SetShapeshift", function(self, id)
	if (id) then
		handlers.spell(self, id);
	end
end);


-- reposition anchor
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, 0);

	-- reset border color here, because it's basically called every time
	tooltip:SetBackdropBorderColor(0.25, 0.25, 0.25);
end);


-- always hide default status bars
GameTooltipStatusBar:HookScript("OnShow", GameTooltipStatusBar.Hide);
