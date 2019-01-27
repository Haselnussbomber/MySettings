local _, screenHeight = GetPhysicalScreenSize()
local uiScale = GetCVar("uiScale")
local mult = 768/screenHeight/uiScale

GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.edgeFile = "Interface\\BUTTONS\\WHITE8X8.blp"
GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.edgeSize = mult
GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.tileSize = mult
GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.insets = { left = mult, right = mult, top = mult, bottom = mult }