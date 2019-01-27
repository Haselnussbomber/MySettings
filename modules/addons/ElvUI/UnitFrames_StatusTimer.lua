local _, addon = ...

tinsert(addon.addons.ElvUI, function()
    local ElvUF = ElvUI.oUF

	local statustimer = ElvUF.Tags.Methods.statustimer
	ElvUF.Tags.Methods.statustimer = function(unit)
		local output = statustimer(unit)
		if (output) then
			return "|r\n" .. output
		end
	end
end)
