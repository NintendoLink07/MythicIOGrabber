BetterWeeklyActivitiesMixin = {}

local formatString1 = "%d. "

local incompleteStrings = {
	[1] = {
		GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE,
		GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST,
		GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND,
	},
	[3] = {
		GREAT_VAULT_REWARDS_RAID_INCOMPLETE,
		GREAT_VAULT_REWARDS_RAID_INPROGRESS,
		GREAT_VAULT_REWARDS_RAID_INPROGRESS
	},
	[6] = {
		GREAT_VAULT_REWARDS_WORLD_INCOMPLETE,
		GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST,
		GREAT_VAULT_REWARDS_WORLD_COMPLETED_SECOND
	}
}

local raidDifficultyToIndex = {
    [17] = 1,
    [14] = 2,
    [15] = 3,
    [16] = 4,
	[233] = 4,
}

function BetterWeeklyActivitiesMixin:OnLoad()

end

function BetterWeeklyActivitiesMixin:GetAllItemlevels()
    local table = {}

    for i = 1, 3, 1 do
        local item = self.exampleRewardsData[i][1]

        local ilvl = C_Item.GetDetailedItemLevelInfo(item)

        if(ilvl) then
            tinsert(table, ilvl)

        end
    end
    
    return table
end

function BetterWeeklyActivitiesMixin:GetActivityWithFurthestUnlock()
	return self.activities[max(self:GetNumOfUnlocks(), 1)]

end

function BetterWeeklyActivitiesMixin:GetActivityForProgressInfo()
	return self.progressInfo

end

function BetterWeeklyActivitiesMixin:AddWorldRunsToTooltip()
	local desiredRuns = self.progressInfo.threshold
	if desiredRuns <= 0 then
		return
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, self.progressInfo.threshold))
	
	-- Comes sorted in descending difficulty
	local combineSharedDifficulty = true
	local activityTierProgress = self.worldHistory

	-- For Delves, difficulty is the tier and numPoints is the number of completions.
	-- We loop on number of completions and print a line for each, until we hit the desiredRuns or have no remaining progress.
	for _, tierProgress in ipairs(activityTierProgress) do
		local numRuns = math.min(tierProgress.numPoints, desiredRuns)
		if numRuns <= 0 then
			return
		end
		desiredRuns = desiredRuns - numRuns

		-- Difficulties above 1 are guaranteed to be Delves and get a Delve-specific string, otherwise they get a generic string.
		-- This will need to change if the assumption of World activities capping at difficulty 1 does not hold.
		if tierProgress.difficulty > 1 then
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_DELVE_TIER_INFO, tierProgress.difficulty, numRuns))
		else
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_DELVE_TIER_AND_WORLD_INFO, tierProgress.difficulty, numRuns))
		end
	end
end

function BetterWeeklyActivitiesMixin:CheckForItemLevels(link1, link2)
	local itemLevel, upgradeItemLevel

	if(link1) then
		itemLevel = C_Item.GetDetailedItemLevelInfo(link1)

	end

	if(link2) then
		upgradeItemLevel = C_Item.GetDetailedItemLevelInfo(link2)

	end

	return itemLevel, upgradeItemLevel
end

function BetterWeeklyActivitiesMixin:HandlePreviewTooltip()
    for k, v in ipairs(self.activities) do
		local unlocked = v.progress >= v.threshold
        local itemLink, upgradeItemLink = self.exampleRewardsData[v.index][1], self.exampleRewardsData[v.index][2]

        local itemLevel, upgradeItemLevel = self:CheckForItemLevels(itemLink, upgradeItemLink)
		
		GameTooltip_AddBlankLineToTooltip(GameTooltip)

		local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(v.activityTierID, v.level)

		local rewardsItemLevelString = ""

		if(v.type == 1) then
			if hasData then
				upgradeItemLevel = nextItemLevel

			else
				nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(v.level)

			end

			local isHeroicLevel = self:IsCompletedAtHeroicLevel(v.activityTierID)

            if isHeroicLevel then
				rewardsItemLevelString = string.format(WEEKLY_REWARDS_ITEM_LEVEL_HEROIC, itemLevel)

            else
				rewardsItemLevelString = string.format(WEEKLY_REWARDS_ITEM_LEVEL_MYTHIC, itemLevel, v.level)

            end
		elseif(v.type == 3) then
			local currentDifficultyName = DifficultyUtil.GetDifficultyName(v.level)

			if(currentDifficultyName) then
				rewardsItemLevelString = string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, itemLevel, currentDifficultyName)

			end

		elseif(v.type == 6) then
			if hasData then
				upgradeItemLevel = nextItemLevel

			else
				nextLevel = v.level + 1

			end

			rewardsItemLevelString = string.format(WEEKLY_REWARDS_ITEM_LEVEL_WORLD, itemLevel, v.level)
		end

		GameTooltip_AddNormalLine(GameTooltip, string.format(formatString1, v.index) .. (unlocked and rewardsItemLevelString or LOCKED))

		if(upgradeItemLevel) then
			GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR)

			if(v.type == 1) then
                if v.threshold == 1 then
                    if isHeroicLevel then
                        GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_COMPLETE_HEROIC_SHORT)
                    else
                        GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC_SHORT, nextLevel))
                    end
                else
                    GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC, nextLevel, v.threshold))
                end
			elseif(v.type == 3) then
				local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(v.level)

				if nextDifficultyID then
					local difficultyName = DifficultyUtil.GetDifficultyName(nextDifficultyID)
					GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_RAID, difficultyName))

				end

			elseif(v.type == 6) then
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_WORLD, nextLevel))

			end

		elseif(itemLevel) then
			GameTooltip_AddColoredLine(GameTooltip, WEEKLY_REWARDS_MAXED_REWARD, GREEN_FONT_COLOR)

		else
			self:AddIncompleteInfo(v.index, v.progress)
			
		end

	end
end

function BetterWeeklyActivitiesMixin:AddTopRunsToTooltip()
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, self.progressInfo.threshold))

	local runHistory = self.runHistory
	if #runHistory > 0 then
		local comparison = function(entry1, entry2)
			if ( entry1.level == entry2.level ) then
				return entry1.mapChallengeModeID < entry2.mapChallengeModeID
			else
				return entry1.level > entry2.level
			end
		end
		table.sort(runHistory, comparison)
		for i = 1, self.progressInfo.threshold do
			if runHistory[i] then
				local runInfo = runHistory[i]
				local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID)
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name))
			end
		end
	end

	local missingRuns = self.progressInfo.threshold - #runHistory
	if missingRuns > 0 then
		local numHeroic, numMythic, numMythicPlus = self.numHeroic, self.numMythic, self.numMythicPlus
        
		while numMythic > 0 and missingRuns > 0 do
			GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_MYTHIC:format(WeeklyRewardsUtil.MythicLevel))
			numMythic = numMythic - 1
			missingRuns = missingRuns - 1
		end
		while numHeroic > 0 and missingRuns > 0 do
			GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_HEROIC)
			numHeroic = numHeroic - 1
			missingRuns = missingRuns - 1
		end
	end
end

function BetterWeeklyActivitiesMixin:IsCompletedAtHeroicLevel(activityTierID)
	local difficultyID = C_WeeklyRewards.GetDifficultyIDForActivityTier(activityTierID or self.info.activityTierID)
	return difficultyID == DifficultyUtil.ID.DungeonHeroic
end

function BetterWeeklyActivitiesMixin:AddIncompleteInfo(index, progress)
	local description = incompleteStrings[self.type][index]

	GameTooltip_AddHighlightLine(GameTooltip, string.format(description, self.activities[index].threshold - progress));
end

local function EncountersSort(left, right)
	if left.instanceID ~= right.instanceID then
		return left.instanceID < right.instanceID
	end
	local leftCompleted = left.bestDifficulty > 0
	local rightCompleted = right.bestDifficulty > 0
	if leftCompleted ~= rightCompleted then
		return leftCompleted
	end
	return left.uiOrder < right.uiOrder
end

function BetterWeeklyActivitiesMixin:AddRaidCompletionInfoToGameTooltip()
    local encounters = self.raidEncounterData[max(self:GetNumOfUnlocks(), 1)]

	if encounters then
		table.sort(encounters, EncountersSort)
		local lastInstanceID = nil
		for index, encounter in ipairs(encounters) do
			local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounter.encounterID)
			if instanceID ~= lastInstanceID then
				local instanceName = EJ_GetInstanceInfo(instanceID)
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_ENCOUNTER_LIST, instanceName))
				lastInstanceID = instanceID
			end
			if name then
				if encounter.bestDifficulty > 0 then
					local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty)

                    local colorIndex = raidDifficultyToIndex[encounter.bestDifficulty]
                    local difficultyColor = _G["ITEM_QUALITY_COLORS"][colorIndex]

					GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETED_ENCOUNTER, name, completedDifficultyName), difficultyColor and difficultyColor.color or GRAY_FONT_COLOR)
				else
					GameTooltip_AddColoredLine(GameTooltip, string.format(DASH_WITH_TEXT, name), DISABLED_FONT_COLOR)
				end
			end
		end
	end
end

function BetterWeeklyActivitiesMixin:GetProgress()
    return self.progressInfo.progress > self.progressInfo.threshold and self.progressInfo.threshold or self.progressInfo.progress

end

function BetterWeeklyActivitiesMixin:GetProgressPercentage()
    return self:GetProgress() / self.progressInfo.threshold

end

function BetterWeeklyActivitiesMixin:HasProgress()
	return self:GetProgress() > 0
end

function BetterWeeklyActivitiesMixin:GetNumOfUnlocks()
	local unlocks = 0

	for k, v in ipairs(self.activities) do
		if(v.progress >= v.threshold) then
			unlocks = unlocks + 1

		end
	end

	return unlocks
end

function BetterWeeklyActivitiesMixin:IsFullyUnlocked()
	return self:GetNumOfUnlocks() == 3
	
end

function BetterWeeklyActivitiesMixin:IsPartiallyUnlocked()
	return self:GetNumOfUnlocks() > 0

end

function BetterWeeklyActivitiesMixin:CanShowPreviewItemTooltip()
	return self:IsPartiallyUnlocked() and not C_WeeklyRewards.CanClaimRewards()
	
end

function BetterWeeklyActivitiesMixin:OnEnter(selfFrame, ...)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);

	local itemLink1, itemLink2, itemLink3 = self.exampleRewardsData[1][1], self.exampleRewardsData[2][1], self.exampleRewardsData[3][1]

	if(itemLink1 ~= "" and not C_Item.GetDetailedItemLevelInfo(itemLink1) or itemLink2 ~= "" and not C_Item.GetDetailedItemLevelInfo(itemLink2) or itemLink3 ~= "" and not C_Item.GetDetailedItemLevelInfo(itemLink3)) then
		GameTooltip_AddErrorLine(GameTooltip, RETRIEVING_ITEM_INFO)
		self.UpdateTooltip = self.OnEnter

	else
		self.UpdateTooltip = nil
		
		if self:CanShowPreviewItemTooltip() then
			GameTooltip_SetTitle(GameTooltip, WEEKLY_REWARDS_CURRENT_REWARD)

			self:HandlePreviewTooltip()

			if self.type == Enum.WeeklyRewardChestThresholdType.Raid then
				self:AddRaidCompletionInfoToGameTooltip()

			elseif self.type == Enum.WeeklyRewardChestThresholdType.Activities then
				self:AddTopRunsToTooltip()

			elseif self.type == Enum.WeeklyRewardChestThresholdType.World then
				self:AddWorldRunsToTooltip()

			end

		else
			GameTooltip_SetTitle(GameTooltip, WEEKLY_REWARDS_UNLOCK_REWARD);

			self:AddIncompleteInfo(1, self:GetProgress())

			-- only for tracks that don't have their first unlock after doing their first activity
			if self.type == Enum.WeeklyRewardChestThresholdType.Raid then
				self:AddRaidCompletionInfoToGameTooltip()

			elseif self.type == Enum.WeeklyRewardChestThresholdType.World then
				self:AddWorldRunsToTooltip()

			end
		end

	end

	GameTooltip:Show()
end

function BetterWeeklyActivitiesMixin:SetOnlyActivities(activities)
	self.type = activities[1].type

	if(self.type == Enum.WeeklyRewardChestThresholdType.Activities) then
    	self.runHistory = C_MythicPlus.GetRunHistory(false, true)
		self.numHeroic, self.numMythic, self.numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns()

	elseif(self.type == Enum.WeeklyRewardChestThresholdType.Raid) then
		self.raidEncounterData = {
			C_WeeklyRewards.GetActivityEncounterInfo(self.type, 1),
			C_WeeklyRewards.GetActivityEncounterInfo(self.type, 2),
			C_WeeklyRewards.GetActivityEncounterInfo(self.type, 3)
		}

	elseif(self.type == Enum.WeeklyRewardChestThresholdType.World) then
		self.worldHistory = C_WeeklyRewards.GetSortedProgressForActivity(Enum.WeeklyRewardChestThresholdType.World, true)

	end

	self.exampleRewardsData = {
		[1] = {C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[1].id)},
		[2] = {C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[2].id)},
		[3] = {C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[3].id)},
	}

	self.activities = activities
	self.progressInfo = activities[3]
end

function BetterWeeklyActivitiesMixin:SetInfo(greatVaultData, type)
	self.greatVaultData = greatVaultData
	self.type = type

    self.runHistory = greatVaultData.runHistory
	self.worldHistory = greatVaultData.worldHistory
    self.raidEncounterData = greatVaultData.raidEncounterData[type]
	self.exampleRewardsData = greatVaultData.exampleRewardsData[type]
	self.numHeroic, self.numMythic, self.numMythicPlus = greatVaultData.numHeroic, greatVaultData.numMythic, greatVaultData.numMythicPlus
	

	self.activities = self.greatVaultData.activities[type]
	self.progressInfo = self.greatVaultData.activities[type][3]

	self.Text:SetText(self:GetProgress() .. "/" .. self.progressInfo.threshold)

end