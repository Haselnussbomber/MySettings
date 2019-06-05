local addonName, addon = ...

local lower = string.lower
local IsAddOnLoaded = IsAddOnLoaded

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceTimer-3.0")

local modules = {}
addon.addons = {}

function addon:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
end

local function timerCallback(key)
	return function(...)
		if (modules[key] and modules[key].OnUpdate) then
			modules[key]:OnUpdate(...)
		end
	end
end

function addon:Register(obj)
	modules[obj.name] = obj

	if (obj.events) then
		for key in pairs(obj.events) do
			self:RegisterEvent(obj.events[key], "OnEvent")
		end
	end

	if (obj.updateTimer) then
		modules.timer = self:ScheduleRepeatingTimer(timerCallback(obj.name), obj.updateTimer)
	end
end

function addon:Unregister(obj)
	for i, v in ipairs(modules) do
		if (v.name == obj.name) then
			table.remove(modules, i)
			break
		end
	end
end

function addon:OnEvent(event, ...)
	for key in pairs(modules) do
		if (modules[key]) then
			if (modules[key][event]) then
				modules[key][event](self, ...)
			end
			if (modules[key].OnEvent) then
				modules[key]:OnEvent(event, ...)
			end
		end
	end
end

function addon:RegisterAddonFix(name, func)
	local module = {
		name = "addonfixes-" .. lower(name),
		events = { "PLAYER_ENTERING_WORLD", "ADDON_LOADED" }
	}

	function module:ADDON_LOADED(arg1)
		if (arg1 == name) then
			module:Fix()
		end
	end

	function module:PLAYER_ENTERING_WORLD()
		if (IsAddOnLoaded(name)) then
			module:Fix()
		end
	end

	function module:Fix()
		if (not module.fixed) then
			func(module)
			module.fixed = true
			addon:Unregister(module)
		end
	end

	addon:Register(module)
end
