EventUtil.ContinueOnAddOnLoaded("BadBoy_Ignore", function()
	local UnitPopupBadBoyIgnoreButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

	function UnitPopupBadBoyIgnoreButtonMixin:GetButtonName()
		return "BBI";
	end

	function UnitPopupBadBoyIgnoreButtonMixin:GetText()
		local fullName = UnitPopupSharedUtil.GetFullPlayerName();
		return "BadBoy: " .. (BADBOY_IGNORE[fullName] and IGNORE_REMOVE or IGNORE);
	end

	function UnitPopupBadBoyIgnoreButtonMixin:CanShow()
		return true;
	end

	function UnitPopupBadBoyIgnoreButtonMixin:OnClick()
		local fullName = UnitPopupSharedUtil.GetFullPlayerName();
		if (BADBOY_IGNORE[fullName]) then
			BADBOY_IGNORE[fullName] = nil;
			print("|cFF33FF99BadBoy_Ignore:|r Removed " .. GetPlayerLink(fullName, fullName) .. " from ignore list");
		else
			BADBOY_IGNORE[fullName] = true;
			print("|cFF33FF99BadBoy_Ignore:|r Added " .. GetPlayerLink(fullName, fullName) .. " to ignore list");
		end
	end

	function UnitPopupBadBoyIgnoreButtonMixin:IsEnabled()
		if UnitPopupSharedUtil.IsInGroupWithPlayer() then
			return false;
		end
		return true;
	end

	local orig_UnitPopupMenuFriend_GetMenuButtons = UnitPopupMenuFriend.GetMenuButtons;
	UnitPopupMenuFriend.GetMenuButtons = function()
		local tbl = orig_UnitPopupMenuFriend_GetMenuButtons();
		table.insert(tbl, tIndexOf(tbl, UnitPopupIgnoreButtonMixin) + 1, UnitPopupBadBoyIgnoreButtonMixin);
		return tbl;
	end
end);
