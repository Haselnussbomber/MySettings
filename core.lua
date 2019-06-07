local addonName, addon = ...

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceTimer-3.0")

addon.modules = {}
addon.registeredEvents = {}

function addon:OnEvent(event, ...)
	for _, module in pairs(self.modules) do
		if (module[event]) then
			module[event](module, ...)
		end
		if (module.OnEvent) then
			module:OnEvent(event, ...)
		end
	end
end

function addon:Register(module)
	local events = module:GetEvents()
	for _, event in pairs(events) do
		if (not self.registeredEvents[event]) then
			self:RegisterEvent(event, "OnEvent")
			self.registeredEvents[event] = 0
		end
		self.registeredEvents[event] = self.registeredEvents[event] + 1
	end

	table.insert(self.modules, module)
end

function addon:Unregister(module)
	local events = module:GetEvents()
	for _, event in pairs(events) do
		if (self.registeredEvents[event]) then
			self.registeredEvents[event] = self.registeredEvents[event] - 1
			if (self.registeredEvents[event] == 0) then
				self:UnregisterEvent(event)
				self.registeredEvents[event] = nil
			end
		end
	end

	tDeleteItem(self.modules, module)
end


local ModuleMixin = {}

function ModuleMixin:OnCreate(name)
	self.name = ("%d-%s"):format(#addon.modules, string.lower(name))
	self.events = {"PLAYER_ENTERING_WORLD"}
end

function ModuleMixin:GetEvents()
	return self.events
end

function ModuleMixin:RegisterEvent(name)
	if (not tIndexOf(self.events, name)) then
		table.insert(self.events, name)
	end
end

function ModuleMixin:UnregisterEvent(name)
	tDeleteItem(self.events, name)
end


local AddonFixMixin = CreateFromMixins(ModuleMixin)

function AddonFixMixin:OnCreate(name, func)
	ModuleMixin.OnCreate(self, name)
	self.addon = name
	self.func = func
	self:RegisterEvent("ADDON_LOADED")
end

function AddonFixMixin:ADDON_LOADED(arg1)
	if (arg1 == self.addon) then
		self:func()
		addon:Unregister(self)
	end
end


function addon:RegisterModule(name)
	local module = CreateFromMixins(ModuleMixin)
	module:OnCreate(name)
	self:Register(module)
	return module
end

function addon:RegisterAddonFix(name, func)
	if (IsAddOnLoaded(name)) then
		func()
		return
	end

	local module = CreateFromMixins(AddonFixMixin)
	module:OnCreate(name, func)
	self:Register(module)
	return module
end
