local _, addon = ...;

addon:RegisterAddonFix("ElvUI", function(module)
	local statustimer = ElvUF.Tags.Methods.statustimer;

	ElvUF.Tags.Methods.statustimer = function(unit)
		local output = statustimer(unit);
		if (output) then
			return "|r\n" .. output;
		end
	end
end);
