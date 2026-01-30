MerchantFrame:HookScript("OnShow", function(self)
	-- repair
	local repairAllCost, canRepair = GetRepairAllCost();
	if (canRepair and repairAllCost > 0 and CanMerchantRepair()) then
		RepairAllItems();
		print("Repariert für " .. GetMoneyString(repairAllCost));
		PlaySound(SOUNDKIT.ITEM_REPAIR);
	end

	C_MerchantFrame.SellAllJunkItems();
end);
