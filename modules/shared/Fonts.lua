local _, addon = ...

local SegoeUISemibold = [[Interface\Addons\SharedMedia_MyMedia\font\seguisb.ttf]]
local RobotoRegular = [[Interface\Addons\SharedMedia_MyMedia\font\Roboto-Regular.ttf]]

local function SetFont(frame, font)
	local _, fontHeight, fontFlags = frame:GetFont()
	frame:SetFont(font, fontHeight, fontFlags)
end

C_Timer.After(3, function()
	SetFont(ZoneTextString, SegoeUISemibold)
	SetFont(SubZoneTextString, SegoeUISemibold)
	SetFont(PVPInfoTextString, SegoeUISemibold)
	SetFont(PVPArenaTextString, SegoeUISemibold)

	SetFont(FramerateLabel, RobotoRegular)
	SetFont(FramerateText, RobotoRegular)
	FramerateLabel:SetText("FPS:")

	if (addon.IsMainline) then
		SetFont(QuestFont, SegoeUISemibold)
	end
end)
