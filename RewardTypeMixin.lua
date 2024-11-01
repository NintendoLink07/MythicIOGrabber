local addonName, miog = ...
local wticc = WrapTextInColorCode

RewardTypeMixin = {}

function RewardTypeMixin:OnLoad()

end

function RewardTypeMixin:GetNumOfCompletedActivities()
    local highestSlot = self.activities[1].progress >= self.activities[1].threshold
    local middleSlot = self.activities[2].progress >= self.activities[2].threshold
    local lowestSlot = self.activities[3].progress >= self.activities[3].threshold

    return lowestSlot and 3 or middleSlot and 2 or highestSlot and 1 or 0
end

function RewardTypeMixin:SetHighestCurrentActivity()
    local threshold1 = self.activities[1].progress >= self.activities[1].threshold
    local threshold2 = self.activities[2].progress >= self.activities[2].threshold
    local threshold3 = self.activities[3].progress >= self.activities[3].threshold

    self.highestSlot = threshold1 and 1 or threshold2 and 2 or threshold3 and 1 or 1
    self.farthestSlot = threshold3 and 3 or threshold2 and 2 or threshold1 and 1 or 1
    self.info = self.activities[self.highestSlot]
end

function RewardTypeMixin:GetHighestActivity()
    return self.activities[self.highestSlot]

end

function RewardTypeMixin:GetNextHigherActivity()
    if(self.farthestSlot < 3) then
        return self.activities[self.farthestSlot + 1]

    end
end

function RewardTypeMixin:GetFarthestActivity(includeLocked)
    return self.activities[includeLocked and #self.activities or self.farthestSlot]

end

function RewardTypeMixin:SetInfo(activities)
    self.activities = activities

    self:SetHighestCurrentActivity()
end

local function EncountersSort(left, right)
	if left.instanceID ~= right.instanceID then
		return left.instanceID < right.instanceID;
	end
	local leftCompleted = left.bestDifficulty > 0;
	local rightCompleted = right.bestDifficulty > 0;
	if leftCompleted ~= rightCompleted then
		return leftCompleted;
	end
	return left.uiOrder < right.uiOrder;
end

function RewardTypeMixin:GetRaidName()
    local encounters = C_WeeklyRewards.GetActivityEncounterInfo(self.info.type, self.info.index);
    if encounters then
        table.sort(encounters, EncountersSort);
        if encounters[1] then
            local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounters[1].encounterID);
            local instanceName = EJ_GetInstanceInfo(instanceID);
            return instanceName;
        end
    end
end

function RewardTypeMixin:AddUpgradeDataToTooltip(enum)
    local farthestCompletedActivity = self:GetFarthestActivity()
    local currentDifficultyID = farthestCompletedActivity.level;
    local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(farthestCompletedActivity.activityTierID, farthestCompletedActivity.level);

    local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(farthestCompletedActivity.id);
	local itemLevel, upgradeItemLevel, preview, sparse;
	if itemLink then
		itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink);
	end
	if upgradeItemLink then
		upgradeItemLevel, preview, sparse = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);
	end

    if hasData then
        upgradeItemLevel = nextItemLevel;
    else
        if(enum == Enum.WeeklyRewardChestThresholdType.Activities) then
            nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(farthestCompletedActivity.level);

        else
            nextLevel = farthestCompletedActivity.level + 1;

        end
    end

    if upgradeItemLevel then
        GameTooltip_AddBlankLineToTooltip(GameTooltip);
        GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);

        if(enum == Enum.WeeklyRewardChestThresholdType.Activities) then
            GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC_SHORT, nextLevel));

        elseif(enum == Enum.WeeklyRewardChestThresholdType.Raid) then
            local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(currentDifficultyID);
            if nextDifficultyID then
                local difficultyName = DifficultyUtil.GetDifficultyName(nextDifficultyID);
            
                GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_RAID, difficultyName));
            end
        else
            GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_WORLD, nextLevel));

        end
    end
end

function RewardTypeMixin:HasHighestRewardBeenUnlocked(info)
    local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(info.id);

	local itemLevel, upgradeItemLevel;
	if itemLink then
		itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink);

	end
	if upgradeItemLink then
		upgradeItemLevel = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);

	end

    if itemLevel then
        if not upgradeItemLevel then
            return true
        end

        return false, upgradeItemLevel
    end

    return false
end

function RewardTypeMixin:OnEnter()
    GameTooltip:SetOwner(self)

    local highestItem, highestUpgrade = C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.info.id)
    local highestILvl = C_Item.GetDetailedItemLevelInfo(highestItem)
    local highestUpgradeIlvl = C_Item.GetDetailedItemLevelInfo(highestUpgrade)
    local farthestCompletedActivity = self:GetFarthestActivity()
    local farthestActivity = self:GetFarthestActivity(true)

    GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);

    local hasRewards = C_WeeklyRewards.HasAvailableRewards();
    local canShowPreviewItem = self.unlocked and not C_WeeklyRewards.CanClaimRewards();
    local numOfCompletedActivities = self:GetNumOfCompletedActivities()

    if(hasRewards) then
        GameTooltip_AddBlankLineToTooltip(GameTooltip);
        GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR);
    end

    local difficultyID = C_WeeklyRewards.GetDifficultyIDForActivityTier(self.info.activityTierID)

    if(difficultyID == DifficultyUtil.ID.DungeonHeroic) then
        GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_HEROIC, highestILvl), GREEN_FONT_COLOR);

    elseif(difficultyID == DifficultyUtil.ID.DungeonChallenge) then
        GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_MYTHIC, highestILvl, self.info.level), GREEN_FONT_COLOR);

    elseif(difficultyID == DifficultyUtil.ID.PrimaryRaidLFR or difficultyID == DifficultyUtil.ID.PrimaryRaidNormal or difficultyID == DifficultyUtil.ID.PrimaryRaidHeroic or difficultyID == DifficultyUtil.ID.PrimaryRaidMythic) then
        GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, highestILvl, self.info.level), GREEN_FONT_COLOR);

    elseif(difficultyID == 0) then
        GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_WORLD, highestILvl, self.info.level), GREEN_FONT_COLOR);

    elseif(self.info.type == Enum.WeeklyRewardChestThresholdType.Raid and self.info.activityTierID == 0 and self.info.level > 0) then
        GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, highestILvl, DifficultyUtil.GetDifficultyName(self.info.level)), GREEN_FONT_COLOR);

    end

    if(self.info.type == Enum.WeeklyRewardChestThresholdType.Activities) then
        if(numOfCompletedActivities == 0) then
            GameTooltip_AddBlankLineToTooltip(GameTooltip);
            GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);

        elseif(numOfCompletedActivities ~= 3) then
            local globalString;

            if(numOfCompletedActivities == 1) then	-- 2nd box in this row
                globalString = GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST;

            else	-- 3rd box
                globalString = GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;

            end

            local nextActivity = self:GetNextHigherActivity()

            GameTooltip_AddBlankLineToTooltip(GameTooltip);
            GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivity.threshold - nextActivity.progress));

            if(self.info.progress > 0) then
                GameTooltip_AddBlankLineToTooltip(GameTooltip);

                local lowestLevel = WeeklyRewardsUtil.GetLowestLevelInTopDungeonRuns(farthestCompletedActivity.threshold);
                if lowestLevel == WeeklyRewardsUtil.HeroicLevel then
                    GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_CURRENT_LEVEL_HEROIC:format(farthestCompletedActivity.threshold));
                else
                    GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_CURRENT_LEVEL_MYTHIC:format(farthestCompletedActivity.threshold, lowestLevel));
                end

                GameTooltip_AddBlankLineToTooltip(GameTooltip);

                local runHistory = C_MythicPlus.GetRunHistory(false, true);
                GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, #runHistory));
                if #runHistory > 0 then
                    local comparison = function(entry1, entry2)
                        if ( entry1.level == entry2.level ) then
                            return entry1.mapChallengeModeID < entry2.mapChallengeModeID;
                        else
                            return entry1.level > entry2.level;
                        end
                    end
                    table.sort(runHistory, comparison);

                    for i = 1, #runHistory do
                        local runInfo = runHistory[i];
                        local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID);
                        GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name));
                    end
                end

                local missingRuns = farthestActivity.threshold - #runHistory;

                if missingRuns > 0 then
                    local numHeroic, numMythic, numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns();

                    while numMythic > 0 and missingRuns > 0 do
                        GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_MYTHIC:format(WeeklyRewardsUtil.MythicLevel));
                        numMythic = numMythic - 1;
                        missingRuns = missingRuns - 1;
                    end

                    while numHeroic > 0 and missingRuns > 0 do
                        GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_HEROIC);
                        numHeroic = numHeroic - 1;
                        missingRuns = missingRuns - 1;
                    end

                    while missingRuns > 0 do
                        missingRuns = missingRuns - 1

                        GameTooltip_AddColoredLine(GameTooltip, string.format(DASH_WITH_TEXT, "Run #" .. farthestActivity.threshold - missingRuns), DISABLED_FONT_COLOR);
                    end
                end
            end
        end

    elseif self.info.type == Enum.WeeklyRewardChestThresholdType.Raid then
        if(farthestCompletedActivity.progress < farthestCompletedActivity.threshold) then
            if farthestCompletedActivity.progress == 0 then
                GameTooltip_AddNormalLine(GameTooltip, string.format(GREAT_VAULT_REWARDS_RAID_INCOMPLETE, farthestCompletedActivity.threshold - farthestCompletedActivity.progress, self:GetRaidName()));
            else
                GameTooltip_AddNormalLine(GameTooltip, string.format(GREAT_VAULT_REWARDS_RAID_INPROGRESS, farthestActivity.threshold - farthestActivity.progress, self:GetRaidName()));
            end
        end

        local encounters = C_WeeklyRewards.GetActivityEncounterInfo(self.info.type, self.info.index);
        if encounters then
            GameTooltip_AddBlankLineToTooltip(GameTooltip);
            table.sort(encounters, EncountersSort);

            local lastInstanceID = nil;
            for index, encounter in ipairs(encounters) do
                local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounter.encounterID);
                if instanceID ~= lastInstanceID then
                    if lastInstanceID then
                        GameTooltip_AddBlankLineToTooltip(GameTooltip);
                    end

                    local instanceName = EJ_GetInstanceInfo(instanceID);
                    GameTooltip_AddHighlightLine(GameTooltip, instanceName);
                    lastInstanceID = instanceID;
                end
                if name then
                    if encounter.bestDifficulty > 0 then
                        local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty) or miog.DIFFICULTY_ID_INFO[encounter.bestDifficulty].name
                        GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETED_ENCOUNTER, name, completedDifficultyName), miog.DIFFICULTY_ID_TO_COLOR[encounter.bestDifficulty]);
                    else
                        GameTooltip_AddColoredLine(GameTooltip, string.format(DASH_WITH_TEXT, name), DISABLED_FONT_COLOR);
                    end
                end
            end
        end

    elseif self.info.type == Enum.WeeklyRewardChestThresholdType.World then
        local nextHigherActivity = self:GetNextHigherActivity()
        if numOfCompletedActivities == 0 then
            GameTooltip_AddNormalLine(GameTooltip, string.format(GREAT_VAULT_REWARDS_WORLD_INCOMPLETE, self.info.threshold - self.info.progress));

        elseif numOfCompletedActivities == 1 then
            GameTooltip_AddNormalLine(GameTooltip, string.format(GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST, nextHigherActivity.threshold - nextHigherActivity.progress));

        elseif numOfCompletedActivities == 2 then
            GameTooltip_AddNormalLine(GameTooltip, string.format(GREAT_VAULT_REWARDS_WORLD_COMPLETED_SECOND, nextHigherActivity.threshold - nextHigherActivity.progress));

        end
    elseif self.info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
        if(ConquestFrame and not ConquestFrame_HasActiveSeason()) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip_AddDisabledLine(GameTooltip, UNAVAILABLE);
            GameTooltip_AddNormalLine(GameTooltip, CONQUEST_REQUIRES_PVP_SEASON);
            GameTooltip:Show();
            return;
        end
    
        local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress();
        local unlocksCompleted = weeklyProgress.unlocksCompleted or 0;

        GameTooltip_AddNormalLine(GameTooltip, "Honor earned: " .. weeklyProgress.progress .. "/" .. weeklyProgress.maxProgress);
        GameTooltip_AddBlankLineToTooltip(GameTooltip);
    
        local maxUnlocks = weeklyProgress.maxUnlocks or 3;
        local description;
        if unlocksCompleted > 0 then
            description = RATED_PVP_WEEKLY_VAULT_TOOLTIP:format(unlocksCompleted, maxUnlocks);

        else
            description = RATED_PVP_WEEKLY_VAULT_TOOLTIP_NO_REWARDS:format(unlocksCompleted, maxUnlocks);

        end

        GameTooltip_AddNormalLine(GameTooltip, description);
    
    end
    
    self:AddUpgradeDataToTooltip(self.info.type)

    GameTooltip_AddBlankLineToTooltip(GameTooltip);

    for i = 1, #self.activities, 1 do
        local item, upgrade = C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.activities[i].id)
        local itemLevel = C_Item.GetDetailedItemLevelInfo(item)

        GameTooltip_AddNormalLine(GameTooltip, string.format("Slot %d: ", i) .. (itemLevel or "Locked"))

    end

    GameTooltip_AddBlankLineToTooltip(GameTooltip);
    GameTooltip_AddNormalLine(GameTooltip, string.format("%s/%s rewards unlocked.", numOfCompletedActivities, 3))

    GameTooltip:Show()
end