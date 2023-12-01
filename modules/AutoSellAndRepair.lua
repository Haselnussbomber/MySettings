MerchantFrame:HookScript("OnShow", function(self)
	-- repair
	local repairAllCost, canRepair = GetRepairAllCost();
	if (canRepair and repairAllCost > 0 and CanMerchantRepair()) then
		RepairAllItems();
		print("Repariert für " .. GetMoneyString(repairAllCost));
		PlaySound(SOUNDKIT.ITEM_REPAIR);
	end

	-- disabled until next patch
	-- C_MerchantFrame.SellAllJunkItems();

	-- sell grays (copied from ElvUI)
	for bagID = 0, 4 do
		for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
			local info = C_Container.GetContainerItemInfo(bagID, slotID);
			if (info) then
				local itemLink = info.hyperlink;
				if (itemLink and not info.hasNoValue) then
					local _, _, rarity, _, _, _, _, _, _, _, itemPrice, classID, _, bindType = GetItemInfo(itemLink);

					if (rarity and rarity == 0
						and (classID ~= 12 or bindType ~= 4) -- Quest can be classID:12 or bindType:4
						and (not C_TransmogCollection.GetItemInfo(itemLink) or C_TransmogCollection.PlayerHasTransmogByItemInfo(itemLink))) then -- skip transmogable items
						C_Container.UseContainerItem(bagID, slotID);
					end
				end
			end
		end
	end
end);
