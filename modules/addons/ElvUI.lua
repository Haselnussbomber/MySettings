local _, addon = ...

addon.addons.ElvUI = {}

addon:RegisterAddonFix("ElvUI", function()
	for _, v in ipairs(addon.addons.ElvUI) do
		if (v and type(v) == 'function') then
			v()
		end
	end
end)
