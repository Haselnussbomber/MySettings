EventUtil.ContinueOnAddOnLoaded("FarmHud", function()
	SLASH_FARMHUD1 = "/farmhud";
	SlashCmdList["FARMHUD"] = function()
		FarmHud:Toggle();
	end
end);
