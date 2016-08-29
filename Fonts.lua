local SegoeUISemibold = [[Interface\Addons\SharedMedia_MyMedia\font\seguisb.ttf]];
local RobotoRegular = [[Interface\Addons\SharedMedia_MyMedia\font\Roboto-Regular.ttf]];

local function SetFont(frame, font)
	local fontName, fontHeight, fontFlags = frame:GetFont();
	frame:SetFont(font, fontHeight, fontFlags);
end

C_Timer.After(5, function()
	SetFont(ZoneTextString, SegoeUISemibold);
	SetFont(SubZoneTextString, SegoeUISemibold);
	SetFont(PVPInfoTextString, SegoeUISemibold);
	SetFont(PVPArenaTextString, SegoeUISemibold);

	SetFont(FramerateLabel, RobotoRegular);
	SetFont(FramerateText, RobotoRegular);

	SetFont(QuestFont, SegoeUISemibold);
end);
