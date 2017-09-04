local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceTimer-3.0")

local modules = {}

function addon:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
end

function addon:Register(obj)
	modules[obj.name] = obj

	if obj.events then
		for key in pairs(obj.events) do
			self:RegisterEvent(obj.events[key], "OnEvent")
		end
	end

	if obj.updateTimer then
		modules.timer = self:ScheduleRepeatingTimer(timerCallback(obj.name), obj.updateTimer)
	end
end

function addon:OnEvent(...)
	for key in pairs(modules) do
		if modules[key] and modules[key].OnEvent then
			modules[key]:OnEvent(...)
		end
	end
end

function timerCallback(key)
	return function(...)
		if modules[key] and modules[key].OnUpdate then
			modules[key]:OnUpdate(...)
		end
	end
end
