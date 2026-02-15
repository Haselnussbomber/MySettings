local addonName, _ = ...;
local name = ("%s_%s"):format(addonName, "Clock");
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local dataObject = ldb:NewDataObject(name);
local timeFormat = "%02d:%02d";

local function FormatTime(isServerTime)
	if (isServerTime) then
		return timeFormat:format(GetGameTime());
	end

	local dateTable = date("*t");
	return timeFormat:format(dateTable["hour"], dateTable["min"]);
end

function dataObject:OnTooltipShow()
	self:ClearLines();
	self:AddLine(TIMEMANAGER_TITLE);
	self:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, FormatTime(), 1, 1, 1);
	self:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, FormatTime(true), 1, 1, 1);
end

function dataObject:OnClick(button)
	TimeManager_Toggle();
end

local frame = CreateFrame("Frame", name .. "_Frame");

FrameUtil.RegisterUpdateFunction(frame, 0.1, function ()
	dataObject.text = FormatTime();
end);
