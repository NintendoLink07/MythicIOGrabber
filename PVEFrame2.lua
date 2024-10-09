local addonName, miog = ...
local wticc = WrapTextInColorCode

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_EventReceiver")

miog.openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

local function openSearchPanel(categoryID, filters, dontSearch)
	LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)

	LFGListFrame.CategorySelection.selectedCategory = categoryID
	LFGListFrame.CategorySelection.selectedFilters = filters

	LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryID, filters, LFGListFrame.baseFilters)

	if(not dontSearch) then
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)

	else
		miog.SearchPanel.Status:Hide()

	end
	
	LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
end

miog.openSearchPanel = openSearchPanel

local function createCategoryButtons(categoryID, type, rootDescription)
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)

	for i = 1, categoryInfo.separateRecommended and 2 or 1, 1 do
		local categoryButton = rootDescription:CreateButton(i == 1 and categoryInfo.name or LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, true), function()
			local filters = i == 2 and categoryInfo.separateRecommended and Enum.LFGListFilter.NotRecommended or categoryID == 1 and 4 or Enum.LFGListFilter.Recommended

			--categoryFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], nil, "CLAMPTOBLACKADDITIVE")

			if(type == "search") then
				openSearchPanel(categoryID, filters)

			else
				LFGListEntryCreation_ClearAutoCreateMode(LFGListFrame.EntryCreation);
			
				LFGListFrame.CategorySelection.selectedCategory = categoryID
				LFGListFrame.CategorySelection.selectedFilters = filters
			
				LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryID, filters, LFGListFrame.baseFilters)
			
				LFGListEntryCreation_SetBaseFilters(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters)
				
				miog.initializeActivityDropdown()
				LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.EntryCreation);

			end
		
			PanelTemplates_SetTab(miog.pveFrame2, 1)
	
			if(miog.pveFrame2.selectedTabFrame) then
				miog.pveFrame2.selectedTabFrame:Hide()
			end
	
			miog.pveFrame2.TabFramesPanel.MainTab:Show()
			miog.pveFrame2.selectedTabFrame = miog.pveFrame2.TabFramesPanel.MainTab
		end)

		categoryButton:SetTooltip(function(tooltip, elementDescription)
			local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();
			if(not canUse) then
				GameTooltip_SetTitle(tooltip, failureReason);
			end
		end)
		MIOG_CB = categoryButton
	end
end


local function CanShowPreviewItemTooltip(self)
	return self.unlocked and not C_WeeklyRewards.CanClaimRewards();
end

local function IsCompletedAtHeroicLevel(self)
	local difficultyID = C_WeeklyRewards.GetDifficultyIDForActivityTier(self.info.activityTierID);
	return difficultyID == DifficultyUtil.ID.DungeonHeroic;
end

local function AddTopRunsToTooltip(self)
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, self.info.threshold));

	local runHistory = C_MythicPlus.GetRunHistory(false, true);
	if #runHistory > 0 then
		local comparison = function(entry1, entry2)
			if ( entry1.level == entry2.level ) then
				return entry1.mapChallengeModeID < entry2.mapChallengeModeID;
			else
				return entry1.level > entry2.level;
			end
		end
		table.sort(runHistory, comparison);
		for i = 1, self.info.threshold do
			if runHistory[i] then
				local runInfo = runHistory[i];
				local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID);
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name));
			end
		end
	end

	local missingRuns = self.info.threshold - #runHistory;
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
	end
end

local function HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel, nextLevel, self)
	local isHeroicLevel = IsCompletedAtHeroicLevel(self);
	if isHeroicLevel then
		GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_HEROIC, itemLevel));
	else
		GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_MYTHIC, itemLevel, self.info.level));
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	if upgradeItemLevel then
		GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
		if self.info.threshold == 1 then
			if isHeroicLevel then
				GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_COMPLETE_HEROIC_SHORT);
			else
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC_SHORT, nextLevel));
			end
		else
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC, nextLevel, self.info.threshold));
			AddTopRunsToTooltip(self);
		end
	end
end

local function ShowIncompleteMythicTooltip(self)
	--GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);
	--GameTooltip_SetTitle(GameTooltip, WEEKLY_REWARDS_UNLOCK_REWARD);

	if self.info.index == 1 then	-- 1st box in this row
		GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);
	else
		local globalString;
		if self.info.index == 2 then	-- 2nd box in this row
			globalString = GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST;
		else	-- 3rd box
			globalString = GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
		end
		GameTooltip_AddNormalLine(GameTooltip, globalString:format(self.info.threshold - self.info.progress));
		if self.info.progress > 0 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			local lowestLevel = WeeklyRewardsUtil.GetLowestLevelInTopDungeonRuns(self.info.threshold);
			if lowestLevel == WeeklyRewardsUtil.HeroicLevel then
				GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_CURRENT_LEVEL_HEROIC:format(self.info.threshold));
			else
				GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_CURRENT_LEVEL_MYTHIC:format(self.info.threshold, lowestLevel));
			end
			AddTopRunsToTooltip(self);
		end
	end
	GameTooltip:Show();
end

local function setRoles()
	local queueRolePanel = miog.MainTab.QueueInformation.RolePanel
	
	SetLFGRoles(queueRolePanel.Leader.Checkbox:GetChecked(), queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
	SetPVPRoles(queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())

end

local function createPVEFrameReplacement()
	local pveFrame2 = CreateFrame("Frame", "MythicIOGrabber_PVEFrameReplacement", UIParent, "MIOG_MainFrameTemplate")
	pveFrame2:SetSize(PVEFrame:GetWidth(), PVEFrame:GetHeight())

	miog.pveFrame2 = pveFrame2
	miog.MainTab = pveFrame2.TabFramesPanel.MainTab
	miog.Teleports = pveFrame2.TabFramesPanel.Teleports
	
	LFGListFrame.SearchPanel.results = LFGListFrame.SearchPanel.results or {}
	LFGListFrame.SearchPanel.applications = LFGListFrame.SearchPanel.applications or {}

	if(pveFrame2:GetPoint() == nil) then
		pveFrame2:SetPoint(PVEFrame:GetPoint())
	end

	miog.createFrameBorder(pveFrame2, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local setup = false
	
	pveFrame2:HookScript("OnShow", function(selfPVEFrame)
		C_MythicPlus.RequestMapInfo()
		C_MythicPlus.RequestCurrentAffixes()

		if(not setup) then
			miog.updateCurrencies()

			setup = true
		end
		
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year);

		C_Calendar.OpenCalendar();

		--miog.updateProgressData()

		miog.MainTab.QueueInformation.LastGroup.Text:SetText("Last group: " .. MIOG_NewSettings.lastGroup)
		
		if(miog.F.CURRENT_SEASON == nil or miog.F.PREVIOUS_SEASON == nil) then
			local currentSeason = C_MythicPlus.GetCurrentSeason()

			miog.F.CURRENT_SEASON = currentSeason
			miog.F.PREVIOUS_SEASON = currentSeason - 1
		end

		miog.F.CURRENT_REGION = miog.F.CURRENT_REGION or miog.C.REGIONS[GetCurrentRegion()]

		local regularActivityID, regularGroupID, regularLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones

		if(regularActivityID) then
			miog.MainTab.Information.Keystone.Text:SetText("+" .. regularLevel .. " " .. C_LFGList.GetActivityGroupInfo(regularGroupID))
			miog.MainTab.Information.Keystone.Text:SetTextColor(miog.createCustomColorForRating(regularLevel * 130):GetRGBA())
			
		else
			local timewalkingActivityID, timewalkingGroupID, timewalkingLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true)  -- Check for a timewalking keystone.

			if(timewalkingActivityID) then
				miog.MainTab.Information.Keystone.Text:SetText("+" .. timewalkingLevel .. " " .. C_LFGList.GetActivityGroupInfo(timewalkingGroupID))
				miog.MainTab.Information.Keystone.Text:SetTextColor(miog.createCustomColorForRating(timewalkingLevel * 130):GetRGBA())
				
			else
				miog.MainTab.Information.Keystone.Text:SetText("NO KEYSTONE")
				miog.MainTab.Information.Keystone.Text:SetTextColor(1, 0, 0, 1)
			
			end
		end

		miog.MainTab.QueueInformation.Requeue:SetScript("OnClick", function()
			miog.requeue()
		end)

		--[[if(miog.F.CURRENT_SEASON and miog.F.CURRENT_SEASON == 12) then
			if(#miog.F.AWAKENED_MAPS == 1) then
				miog.MainTab.Information.Awakened.Text:SetTextColor(1,1,1,1)
				miog.MainTab.Information.Awakened.Text:SetText(miog.MAP_INFO[miog.F.AWAKENED_MAPS[1] ].name)
				miog.MainTab.Information.Awakened.Icon:SetTexture(nil)
				miog.MainTab.Information.Awakened.Icon:SetAtlas(miog.MAP_INFO[miog.F.AWAKENED_MAPS[1] ].awakenedIcon .. "-large")

			elseif(#miog.F.AWAKENED_MAPS > 1) then
				miog.MainTab.Information.Awakened.Text:SetTextColor(1,1,1,1)
				miog.MainTab.Information.Awakened.Text:SetText("All raids awakened")
				miog.MainTab.Information.Awakened.Icon:SetTexture(nil)
				miog.MainTab.Information.Awakened.Icon:SetAtlas(miog.MAP_INFO[miog.F.AWAKENED_MAPS[1] ].awakenedIcon .. "-large")

			else
				miog.MainTab.Information.Awakened.Text:SetTextColor(1,0,0,1)
				miog.MainTab.Information.Awakened.Text:SetText("No awakened raids")

			end
		end]]

		local activityIndices = {
			Enum.WeeklyRewardChestThresholdType.Activities, -- m+
			Enum.WeeklyRewardChestThresholdType.Raid, -- raid
			Enum.WeeklyRewardChestThresholdType.World, -- world/delves
		}
		
		for k, v in ipairs(activityIndices) do
			local activities = C_WeeklyRewards.GetActivities(v)

			if(activities[k]) then
				local firstThreshold = activities[1].progress >= activities[1].threshold
				local secondThreshold = activities[2].progress >= activities[2].threshold
				local thirdThreshold = activities[3].progress >= activities[3].threshold
				local currentColor = thirdThreshold and miog.CLRSCC.green or secondThreshold and miog.CLRSCC.yellow or firstThreshold and miog.CLRSCC.orange or miog.CLRSCC.red
				local dimColor = {CreateColorFromHexString(currentColor):GetRGB()}
				dimColor[4] = 0.1

				local currentFrame = k == 1 and miog.MainTab.Information.MPlusStatus or k == 2 and miog.MainTab.Information.RaidStatus or miog.MainTab.Information.WorldStatus

				currentFrame:SetMinMaxValues(0, activities[3].threshold)
				currentFrame.info = (thirdThreshold or secondThreshold) and activities[3] or firstThreshold and activities[2] or activities[1]
				currentFrame.activities = activities
				currentFrame.unlocked = currentFrame.info.progress >= currentFrame.info.threshold;
				
				currentFrame:SetStatusBarColor(CreateColorFromHexString(currentColor):GetRGBA())
				miog.createFrameWithBackgroundAndBorder(currentFrame, 1, unpack(dimColor))

				currentFrame:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);

					if self.info then

						local activities1Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[1].id))
						local activities2Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[2].id))
						local activities3Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[3].id))
						
						miog.VAULT_PROGRESS[k] = {activities1Lvl, activities2Lvl, activities3Lvl}

						local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.info.id);

						local itemLevel, upgradeItemLevel, previewLevel, sparse;
						if itemLink then
							itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
						end
						if upgradeItemLink then
							upgradeItemLevel, previewLevel, sparse = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);
						end

						local canShow = CanShowPreviewItemTooltip(self)
						
						GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);
						GameTooltip_AddBlankLineToTooltip(GameTooltip);
					
						local hasRewards = C_WeeklyRewards.HasAvailableRewards();

						if hasRewards then
							GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR);
							GameTooltip_AddBlankLineToTooltip(GameTooltip);
						end

						if self.info.type == Enum.WeeklyRewardChestThresholdType.Activities then
							if(canShow) then
								local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(self.info.activityTierID, self.info.level);
								if hasData then
									upgradeItemLevel = nextItemLevel;
								else
									nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(self.info.level);
								end
								
								HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel, nextLevel, self);

							else
								ShowIncompleteMythicTooltip(self);
								GameTooltip_AddBlankLineToTooltip(GameTooltip);

							end

							GameTooltip_AddNormalLine(GameTooltip, "Slot 1: " .. (activities1Lvl or "N/A"))
							GameTooltip_AddNormalLine(GameTooltip, "Slot 2: " .. (activities2Lvl or "N/A"))
							GameTooltip_AddNormalLine(GameTooltip, "Slot 3: " .. (activities3Lvl or "N/A"))

							GameTooltip_AddBlankLineToTooltip(GameTooltip);
							
							GameTooltip_AddNormalLine(GameTooltip, string.format("%s/%s rewards unlocked.", thirdThreshold and 3 or secondThreshold and 2 or firstThreshold and 1 or 0, 3))

						elseif self.info.type == Enum.WeeklyRewardChestThresholdType.Raid then
							local currentDifficultyID = self.info.level;

							--[[if(itemLevel) then
								local currentDifficultyName = DifficultyUtil.GetDifficultyName(currentDifficultyID);
								GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, itemLevel, currentDifficultyName));
								GameTooltip_AddBlankLineToTooltip(GameTooltip);
							end]]
							
							if upgradeItemLevel then
								local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(currentDifficultyID);
								local difficultyName = DifficultyUtil.GetDifficultyName(nextDifficultyID);
								GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
								GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_RAID, difficultyName));
							end
				
							local encounters = C_WeeklyRewards.GetActivityEncounterInfo(self.info.type, self.info.index);
							if encounters then
								table.sort(encounters, function(left, right)
									if left.instanceID ~= right.instanceID then
										return left.instanceID < right.instanceID;
									end
									local leftCompleted = left.bestDifficulty > 0;
									local rightCompleted = right.bestDifficulty > 0;
									if leftCompleted ~= rightCompleted then
										return leftCompleted;
									end
									return left.uiOrder < right.uiOrder;
								end)
								local lastInstanceID = nil;
								for index, encounter in ipairs(encounters) do
									local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounter.encounterID);
									if instanceID ~= lastInstanceID then
										local instanceName = EJ_GetInstanceInfo(instanceID);
										GameTooltip_AddBlankLineToTooltip(GameTooltip);
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
							
							GameTooltip_AddBlankLineToTooltip(GameTooltip);

							GameTooltip_AddNormalLine(GameTooltip, "Slot 1: " .. (activities1Lvl or "N/A"))
							GameTooltip_AddNormalLine(GameTooltip, "Slot 2: " .. (activities2Lvl or "N/A"))
							GameTooltip_AddNormalLine(GameTooltip, "Slot 3: " .. (activities3Lvl or "N/A"))

							GameTooltip_AddBlankLineToTooltip(GameTooltip);
							GameTooltip_AddNormalLine(GameTooltip, string.format("%s/%s rewards unlocked.", thirdThreshold and 3 or secondThreshold and 2 or firstThreshold and 1 or 0, 3))

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
						
							--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
							--GameTooltip:Show();
						elseif self.info.type == Enum.WeeklyRewardChestThresholdType.World then
							local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(self.info.activityTierID, self.info.level);
							if hasData then
								upgradeItemLevel = nextItemLevel;

							else
								nextLevel = self.info.level + 1;

							end

							GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_WORLD, itemLevel, self.info.level));
	
							GameTooltip_AddBlankLineToTooltip(GameTooltip);
							if upgradeItemLevel then
								GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
								GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_WORLD, nextLevel));
							end

							GameTooltip_AddNormalLine(GameTooltip, "Slot 1: " .. (activities1Lvl or "N/A"))
							GameTooltip_AddNormalLine(GameTooltip, "Slot 2: " .. (activities2Lvl or "N/A"))
							GameTooltip_AddNormalLine(GameTooltip, "Slot 3: " .. (activities3Lvl or "N/A"))

							GameTooltip_AddBlankLineToTooltip(GameTooltip);
							
							GameTooltip_AddNormalLine(GameTooltip, string.format("%s/%s rewards unlocked.", thirdThreshold and 3 or secondThreshold and 2 or firstThreshold and 1 or 0, 3))
						end

						GameTooltip_AddBlankLineToTooltip(GameTooltip);

						GameTooltip:Show()

					end
				end)

				currentFrame:SetValue(activities[3].progress)

				currentFrame.Text:SetText((activities[3].progress <= activities[3].threshold and activities[3].progress or activities[3].threshold) .. "/" .. activities[3].threshold .. " " .. (k == 1 and "Dungeons" or k == 2 and "Bosses" or k == 3 and "World" or ""))
				currentFrame.Text:SetTextColor(CreateColorFromHexString(not firstThreshold and currentColor or "FFFFFFFF"):GetRGBA())
			end
		end
	end)

	hooksecurefunc("PVEFrame_ToggleFrame", function()
		HideUIPanel(PVEFrame)

		if(miog.pveFrame2:IsVisible()) then
			HideUIPanel(miog.pveFrame2)

		else
			ShowUIPanel(miog.pveFrame2)
			
		end
	end)
	--miog.pveFrame2.TitleBar.Expand:SetParent(miog.Plugin)

	if(miog.F.IS_RAIDERIO_LOADED) then
		miog.pveFrame2.TitleBar.RaiderIOLoaded:Hide()
	end

    miog.MPlusStatistics = pveFrame2.TabFramesPanel.MPlusStatistics
	miog.MPlusStatistics:OnLoad(1)

	miog.RaidStatistics = pveFrame2.TabFramesPanel.RaidStatistics
	miog.RaidStatistics:OnLoad(2)

	miog.PVPStatistics = pveFrame2.TabFramesPanel.PVPStatistics
	miog.PVPStatistics:OnLoad(3)

	--miog.RaidStatistics.RaidColumns.Raids = {}
	--miog.RaidStatistics.ScrollFrame.Rows.accountChars = {}

	miog.LockoutCheck = pveFrame2.TabFramesPanel.LockoutCheck

	local r,g,b = CreateColorFromHexString(miog.CLRSCC.black):GetRGB()

	for i = 1, 6, 1 do
		local currentFrame = miog.MainTab.Information.Currency[tostring(i)]

		miog.createFrameBorder(currentFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		currentFrame:SetBackdropColor(r, g, b, 0.8)

	end

	pveFrame2.TitleBar.RaiderIOLoaded:SetText(WrapTextInColorCode("NO R.IO", miog.CLRSCC["red"]))
	pveFrame2.TitleBar.RaiderIOLoaded:SetShown(not miog.F.IS_RAIDERIO_LOADED)

	local queueRolePanel = miog.MainTab.QueueInformation.RolePanel
	local leader, tank, healer, damager = LFDQueueFrame_GetRoles()

	queueRolePanel.Leader.Checkbox:SetChecked(leader)
	queueRolePanel.Leader.Checkbox:SetScript("OnClick", function(self)
		setRoles()
	end)

	queueRolePanel.Tank.Checkbox:SetChecked(tank)
	queueRolePanel.Tank.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["TANK"])
	queueRolePanel.Tank.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["TANK"])
	queueRolePanel.Tank.Checkbox:SetScript("OnClick", function(self)
		setRoles()
	end)

	queueRolePanel.Healer.Checkbox:SetChecked(healer)
	queueRolePanel.Healer.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["HEALER"])
	queueRolePanel.Healer.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["HEALER"])
	queueRolePanel.Healer.Checkbox:SetScript("OnClick", function(self)
		setRoles()
	end)

	queueRolePanel.Damager.Checkbox:SetChecked(damager)
	queueRolePanel.Damager.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["DAMAGER"])
	queueRolePanel.Damager.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["DAMAGER"])
	queueRolePanel.Damager.Checkbox:SetScript("OnClick", function(self)
		setRoles()
	end)
	
	setRoles()

	PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")

	local queueDropDown = miog.MainTab.QueueInformation.DropDown
	queueDropDown:OnLoad()
	queueDropDown:SetText("Select an activity")
	miog.MainTab.QueueInformation.Panel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local formatter = CreateFromMixins(SecondsFormatterMixin)
	formatter:Init(3600, SecondsFormatter.Abbreviation.OneLetter)

	local function addTeleportButtons()
		local lastExpansionFrames = {}

		for index, info in ipairs(miog.TELEPORT_FLYOUT_IDS) do
			local name, description, numSlots, isKnown = GetFlyoutInfo(info.id)

			local expansionInfo = GetExpansionDisplayInfo(info.expansion)

			local logoFrame = miog.Teleports[tostring(info.expansion)]

			if(logoFrame and expansionInfo) then
				logoFrame.Texture:SetTexture(expansionInfo.logo)

				local expNameTable = {}

				for k = 1, numSlots, 1 do
					local flyoutSpellID, _, spellKnown, spellName, _ = GetFlyoutSlotInfo(info.id, k)
					local desc = C_Spell.GetSpellDescription(flyoutSpellID)
					local tableIndex = #expNameTable + 1

					expNameTable[tableIndex] = {name = spellName, desc = desc, spellID = flyoutSpellID, known = spellKnown}

					if(desc == "") then
						local spell = Spell:CreateFromSpellID(flyoutSpellID)
						spell:ContinueOnSpellLoad(function()
							addTeleportButtons()

						end)

						return false

					end
				end

				table.sort(expNameTable, function(k1, k2)
					return k1.desc < k2.desc
				end)

				for k, v in ipairs(expNameTable) do
					local spellInfo = C_Spell.GetSpellInfo(v.spellID)
					local tpButton = CreateFrame("Button", nil, miog.Teleports, "MIOG_TeleportButtonTemplate")
					tpButton:SetNormalTexture(spellInfo.iconID)
					tpButton:GetNormalTexture():SetDesaturated(not v.known)
					tpButton:SetPoint("LEFT", lastExpansionFrames[info.expansion] or logoFrame, "RIGHT", lastExpansionFrames[info.expansion] and k == 1 and 18 or 3, 0)

					lastExpansionFrames[info.expansion] = tpButton

					if(v.known) then
						local myCooldown = tpButton.Cooldown
						
						tpButton:HookScript("OnShow", function()
							
							local spellCooldownInfo = C_Spell.GetSpellCooldown(v.spellID)
							--local start, duration, _, modrate = GetSpellCooldown(v.spellID)
							myCooldown:SetCooldown(spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.modRate)

							local secondsLeft = spellCooldownInfo.duration - (GetTime() - spellCooldownInfo.startTime)
							local text = secondsLeft > 0 and WrapTextInColorCode("Remaining CD: " .. formatter:Format(secondsLeft), miog.CLRSCC.red) or WrapTextInColorCode("Ready", miog.CLRSCC.green)

							miog.Teleports.Remaining:SetText(text)
						end)

						tpButton:SetHighlightAtlas("communities-create-avatar-border-hover")
						tpButton:SetAttribute("type", "spell")
						tpButton:SetAttribute("spell", spellInfo.name)
						tpButton:RegisterForClicks("LeftButtonDown")
					end

					local spell = Spell:CreateFromSpellID(v.spellID)
					spell:ContinueOnSpellLoad(function()
						tpButton:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
							GameTooltip_AddHighlightLine(GameTooltip, v.name)
							GameTooltip:AddLine(spell:GetSpellDescription())
							GameTooltip:Show()
						end)
					end)

					tpButton:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)
				end
			end
		end
	end

	addTeleportButtons()
	
	miog.pveFrame2.TitleBar.CreateGroupButton.Text:SetText("Create")
	miog.pveFrame2.TitleBar.CreateGroupButton:SetScript("OnClick", function(selfButton)
		local currentMenu = MenuUtil.CreateContextMenu(miog.pveFrame2.TitleBar.CreateGroupButton, function(ownerRegion, rootDescription)
	
			rootDescription:CreateTitle("Create Groups");

			for _, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
				createCategoryButtons(categoryID, "entry", rootDescription)

			end
			rootDescription:SetTag("MIOG_FINDGROUP")
		end)

		currentMenu:SetPoint("TOPLEFT", selfButton, "BOTTOMLEFT")
	end)

	miog.pveFrame2.TitleBar.FindGroupButton.Text:SetText("Find")
	miog.pveFrame2.TitleBar.FindGroupButton:SetScript("OnClick", function(selfButton)
		local currentMenu = MenuUtil.CreateContextMenu(miog.pveFrame2.TitleBar.FindGroupButton, function(ownerRegion, rootDescription)
	
			rootDescription:CreateTitle("Find Groups");
			
			local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();

			for _, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
				createCategoryButtons(categoryID, "search", rootDescription, canUse)

			end
			rootDescription:SetTag("MIOG_FINDGROUP")
		end)

		currentMenu:SetPoint("TOPLEFT", selfButton, "BOTTOMLEFT")
	end)

	local function setCustomActivePanel(name)
		miog.setActivePanel(nil, name)

		PanelTemplates_SetTab(miog.pveFrame2, 1)

		if(miog.pveFrame2.selectedTabFrame) then
			miog.pveFrame2.selectedTabFrame:Hide()
		end

		miog.pveFrame2.TabFramesPanel.MainTab:Show()
		miog.pveFrame2.selectedTabFrame = miog.pveFrame2.TabFramesPanel.MainTab
	end

	miog.pveFrame2.TitleBar.MoreButton.Text:SetText("More")
	miog.pveFrame2.TitleBar.MoreButton:SetScript("OnClick", function(self)
		local currentMenu = MenuUtil.CreateContextMenu(miog.pveFrame2.TitleBar.MoreButton, function(ownerRegion, rootDescription)
			rootDescription:CreateTitle("More");
			rootDescription:CreateButton("Adventure Journal", function() setCustomActivePanel("AdventureJournal") end)
			rootDescription:CreateButton("DropChecker", function() setCustomActivePanel("DropChecker") end)
			rootDescription:CreateButton("RaiderIOChecker", function() setCustomActivePanel("RaiderIOChecker") end)
			rootDescription:SetTag("MIOG_MORE")
		end)

		currentMenu:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	end)
end

miog.createPVEFrameReplacement = createPVEFrameReplacement

eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
eventReceiver:RegisterEvent("PLAYER_LOGIN")
eventReceiver:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
eventReceiver:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
eventReceiver:RegisterEvent("PLAYER_REGEN_DISABLED")
eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")
eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
eventReceiver:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
eventReceiver:RegisterEvent("ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED")
--eventReceiver:RegisterEvent("Menu.OpenMenuTag")



eventReceiver:SetScript("OnEvent", miog.OnEvent)

--[[

scriptReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
scriptReceiver:RegisterEvent("GROUP_JOINED")
scriptReceiver:RegisterEvent("GROUP_LEFT")
scriptReceiver:RegisterEvent("INSPECT_READY")
scriptReceiver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")


scriptReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
scriptReceiver:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
scriptReceiver:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
scriptReceiver:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
scriptReceiver:RegisterEvent("BATTLEFIELDS_SHOW")
scriptReceiver:RegisterEvent("LFG_UPDATE")
scriptReceiver:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
scriptReceiver:RegisterEvent("LFG_LOCK_INFO_RECEIVED")

]]
