local _, addon = ...

tinsert(addon.addons.ElvUI, function()
	local E = ElvUI[1]
	local LO = E:GetModule("Layout")
	local CH = E:GetModule("Chat")

	hooksecurefunc(LO, "CreateChatButtonPanel", function()
		ChatButtonHolder:Show()
	end)

	hooksecurefunc(CH, "Initialize", function()
		ElvUIChatHeadFrame:Hide()
	end)
end)
