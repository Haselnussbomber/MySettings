local addonName, _ = ...;
local name = ("%s_%s"):format(addonName, "Mail");
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local dataObject = ldb:NewDataObject(name);
local frame = CreateFrame("Frame", name .. "_Frame");

FrameUtil.RegisterFrameForEvents(frame, { "MAIL_INBOX_UPDATE", "MAIL_SHOW" });

local function Update()
	if (HasNewMail()) then
		dataObject.text = "new mail";
	else
		dataObject.text = "";
	end
end

frame:SetScript("OnEvent", function (event)
	if (event == "MAIL_SHOW") then
		dataObject.text = "";
	end

	if (event == "UPDATE_PENDING_MAIL") then
		Update();
	end
end);

FrameUtil.RegisterUpdateFunction(frame, 5, Update);

Update();
