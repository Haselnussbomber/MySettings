local _, addon = ...;

local module = addon:NewModule("BadBoy_Ignore");

function module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED");
end

function module:ADDON_LOADED(_, addonName)
	if (addonName ~= "BadBoy_Ignore") then
		return;
	end

	self:UnregisterEvent("ADDON_LOADED");

	-- Unit Popup Button
	UnitPopupButtons["BBI"] = {
		text = function(dropdownMenu)
			local key = dropdownMenu.name .. "-" .. (dropdownMenu.server or CURRENT_SERVER);
			return "BadBoy: " .. (BADBOY_IGNORE[key] and IGNORE_REMOVE or IGNORE);
		end
	};
	table.insert(UnitPopupMenus["FRIEND"], #(UnitPopupMenus["FRIEND"])-1, "BBI");

	local CURRENT_NAME, CURRENT_SERVER;

	hooksecurefunc("UnitPopup_ShowMenu", function(self, which)
		if (which == "FRIEND" and UIDROPDOWNMENU_MENU_LEVEL == 1) then
			CURRENT_NAME, CURRENT_SERVER = self.name, self.server;
		end
	end);

	hooksecurefunc("UnitPopup_OnClick", function(self)
		local name, server = UIDROPDOWNMENU_INIT_MENU.name, UIDROPDOWNMENU_INIT_MENU.server;
		if (not server) then
			return;
		end

		if (name == CURRENT_NAME and not server) then
			server = CURRENT_SERVER;
		end

		if (self.value == "BBI") then
			local key = name .. "-" .. server;
			if (BADBOY_IGNORE[key]) then
				BADBOY_IGNORE[key] = nil;
				print("|cFF33FF99BadBoy_Ignore:|r Removed " .. GetPlayerLink(key, name) .. " from ignore list");
			else
				BADBOY_IGNORE[key] = true;
				print("|cFF33FF99BadBoy_Ignore:|r Added " .. GetPlayerLink(key, name) .. " to ignore list");
			end
		end
	end);
end
