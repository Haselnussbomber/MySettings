EventRegistry:RegisterFrameEventAndCallback("QUEST_COMPLETE", function()
	-- default first button when no item has a sell value.
	local choice, price = 1, 0;
	local num = GetNumQuestChoices();

	if (num <= 0) then
		return; -- no choices, quick exit
	end

	for index = 1, num do
		local link = GetQuestItemLink("choice", index);
		if (link) then
			local itemSellPrice = select(11, GetItemInfo(link));
			if (itemSellPrice and itemSellPrice > price) then
				price = itemSellPrice;
				choice = index;
			end
		end
	end

	QuestInfoItem_OnClick(QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, choice));
end);
