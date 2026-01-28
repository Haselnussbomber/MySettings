-- https://www.reddit.com/r/WowUI/comments/1qk96mg/otherfixworkaroundhidden_tracked_quests_caused_60/o18at2z/
EventUtil.ContinueOnPlayerLogin(function()
    local numShownEntries, numQuests = C_QuestLog.GetNumQuestLogEntries();
    if (numShownEntries <= numQuests) then
        return;
    end

    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local quest = C_QuestLog.GetInfo(i);

        if quest and quest.isHidden then
            C_QuestLog.RemoveQuestWatch(i);
        end
    end
end)
