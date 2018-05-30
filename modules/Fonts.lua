local addonName, addon = ...;

local SegoeUISemibold = [[Interface\Addons\SharedMedia_MyMedia\font\seguisb.ttf]];
local RobotoRegular = [[Interface\Addons\SharedMedia_MyMedia\font\Roboto-Regular.ttf]];

local function SetFont(frame, font)
	local fontName, fontHeight, fontFlags = frame:GetFont();
	frame:SetFont(font, fontHeight, fontFlags);
end

local Module = {
	name = "fonts",
	events = { "PLAYER_ENTERING_WORLD" }
};

function Module:PLAYER_ENTERING_WORLD()
	C_Timer.After(3, function()
		SetFont(ZoneTextString, SegoeUISemibold);
		SetFont(SubZoneTextString, SegoeUISemibold);
		SetFont(PVPInfoTextString, SegoeUISemibold);
		SetFont(PVPArenaTextString, SegoeUISemibold);

		SetFont(FramerateLabel, RobotoRegular);
		SetFont(FramerateText, RobotoRegular);

		SetFont(QuestFont, SegoeUISemibold);
	end);
end

addon:Register(Module);
