local addonName, miog = ...
local wticc = WrapTextInColorCode

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_EventReceiver")

miog.openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

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

local function resetCategoryFrame(_, frame)
	frame:Hide()
	frame.layoutIndex = nil
	frame.categoryID = nil
	frame.filters = nil
	frame.Title:SetText("")
	frame.BackgroundImage:SetTexture(nil)
	frame:SetScript("OnEnter", nil)
	frame:SetScript("OnLeave", nil)
	frame:SetScript("OnClick", nil)
end

local function startNewGroup(categoryFrame)
	LFGListEntryCreation_ClearAutoCreateMode(LFGListFrame.EntryCreation);

	--local isDifferentCategory = LFGListFrame.CategorySelection.selectedCategory ~= categoryFrame.categoryID
	--local isSeparateCategory = C_LFGList.GetLfgCategoryInfo(categoryFrame.categoryID).separateRecommended

	LFGListFrame.CategorySelection.selectedCategory = categoryFrame.categoryID
	LFGListFrame.CategorySelection.selectedFilters = categoryFrame.filters

	LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryFrame.categoryID, categoryFrame.filters, LFGListFrame.baseFilters)

	LFGListEntryCreation_SetBaseFilters(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters)
	--LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters, LFGListFrame.CategorySelection.selectedCategory);
	
	miog.initializeActivityDropdown()
end

miog.startNewGroup = startNewGroup

local function findGroup(categoryFrame)
	LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)
	
	LFGListFrame.CategorySelection.selectedCategory = categoryFrame.categoryID
	LFGListFrame.CategorySelection.selectedFilters = categoryFrame.filters

	LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryFrame.categoryID, categoryFrame.filters, LFGListFrame.baseFilters)

	LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
end

local function createPVEFrameReplacement()
	local pveFrame2 = CreateFrame("Frame", "MythicIOGrabber_PVEFrameReplacement", UIParent, "MIOG_MainFrameTemplate")
	pveFrame2:SetSize(PVEFrame:GetWidth(), PVEFrame:GetHeight())

	miog.pveFrame2 = pveFrame2
	miog.MainTab = pveFrame2.TabFramesPanel.MainTab
	miog.Teleports = pveFrame2.TabFramesPanel.Teleports
	

	if(pveFrame2:GetPoint() == nil) then
		pveFrame2:SetPoint(PVEFrame:GetPoint())
	end

	miog.createFrameBorder(pveFrame2, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local setup = false
	
	pveFrame2:HookScript("OnShow", function(selfPVEFrame)
		C_MythicPlus.RequestCurrentAffixes()
		C_MythicPlus.RequestMapInfo()
		
		--C_Calendar.CloseEvent()
		--C_Calendar.OpenCalendar()

		if(not setup) then
			miog.updateCurrencies()

			setup = true
		end

		--miog.updateProgressData()

		miog.MainTab.QueueInformation.LastGroup.Text:SetText("Last group: " .. MIOG_SavedSettings.lastGroup.value)
		
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

		if(miog.F.CURRENT_SEASON and miog.F.CURRENT_SEASON == 12) then
			if(#miog.F.AWAKENED_MAPS == 1) then
				miog.MainTab.Information.Awakened.Text:SetTextColor(1,1,1,1)
				miog.MainTab.Information.Awakened.Text:SetText(miog.MAP_INFO[miog.F.AWAKENED_MAPS[1]].name)
				miog.MainTab.Information.Awakened.Icon:SetTexture(nil)
				miog.MainTab.Information.Awakened.Icon:SetAtlas(miog.MAP_INFO[miog.F.AWAKENED_MAPS[1]].awakenedIcon .. "-large")

			elseif(#miog.F.AWAKENED_MAPS > 1) then
				miog.MainTab.Information.Awakened.Text:SetTextColor(1,1,1,1)
				miog.MainTab.Information.Awakened.Text:SetText("All raids awakened")
				miog.MainTab.Information.Awakened.Icon:SetTexture(nil)
				miog.MainTab.Information.Awakened.Icon:SetAtlas(miog.MAP_INFO[miog.F.AWAKENED_MAPS[1]].awakenedIcon .. "-large")

			else
				miog.MainTab.Information.Awakened.Text:SetTextColor(1,0,0,1)
				miog.MainTab.Information.Awakened.Text:SetText("No awakened raids")

			end
		end
		
		for frameIndex = 1, 3, 1 do
			local activities = C_WeeklyRewards.GetActivities(frameIndex)

			local firstThreshold = activities[1].progress >= activities[1].threshold
			local secondThreshold = activities[2].progress >= activities[2].threshold
			local thirdThreshold = activities[3].progress >= activities[3].threshold
			local currentColor = thirdThreshold and miog.CLRSCC.green or secondThreshold and miog.CLRSCC.yellow or firstThreshold and miog.CLRSCC.orange or miog.CLRSCC.red
			local dimColor = {CreateColorFromHexString(currentColor):GetRGB()}
			dimColor[4] = 0.1

			local currentFrame = frameIndex == 1 and miog.MainTab.Information.MPlusStatus or frameIndex == 2 and miog.MainTab.Information.HonorStatus or miog.MainTab.Information.RaidStatus

			currentFrame:SetMinMaxValues(0, activities[3].threshold)
			currentFrame.info = (thirdThreshold or secondThreshold) and activities[3] or firstThreshold and activities[2] or activities[1]
			currentFrame.activities = activities
			currentFrame.unlocked = currentFrame.info.progress >= currentFrame.info.threshold;

			local activities1Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[1].id))
			local activities2Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[2].id))
			local activities3Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[3].id))
			
			miog.VAULT_PROGRESS[frameIndex] = {activities1Lvl, activities2Lvl, activities3Lvl}

			currentFrame:SetStatusBarColor(CreateColorFromHexString(currentColor):GetRGBA())
			miog.createFrameWithBackgroundAndBorder(currentFrame, 1, unpack(dimColor))

			currentFrame:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);

				if self.info then
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

						if(itemLevel) then
							local currentDifficultyName = DifficultyUtil.GetDifficultyName(currentDifficultyID);
							GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, itemLevel, currentDifficultyName));
							GameTooltip_AddBlankLineToTooltip(GameTooltip);
						end
						
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
										local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty);
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
					end

					GameTooltip_AddBlankLineToTooltip(GameTooltip);
					GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);

					GameTooltip:Show()

				end
			end)

			currentFrame:SetValue(activities[3].progress)

			currentFrame.Text:SetText((activities[3].progress <= activities[3].threshold and activities[3].progress or activities[3].threshold) .. "/" .. activities[3].threshold .. " " .. (frameIndex == 1 and "Dungeons" or frameIndex == 2 and "Honor" or frameIndex == 3 and "Bosses" or ""))
			currentFrame.Text:SetTextColor(CreateColorFromHexString(not firstThreshold and currentColor or "FFFFFFFF"):GetRGBA())
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
	miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:OnLoad()
	miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:SetListAnchorToTopleft()
	miog.MPlusStatistics.ScrollFrame.Rows.accountChars = {}
	miog.MPlusStatistics.DungeonColumns.Dungeons = {}

	miog.PVPStatistics = pveFrame2.TabFramesPanel.PVPStatistics
	miog.PVPStatistics.BracketColumns.Brackets = {}
	miog.PVPStatistics.ScrollFrame.Rows.accountChars = {}

	miog.RaidStatistics = pveFrame2.TabFramesPanel.RaidStatistics
	miog.RaidStatistics.RaidColumns.Raids = {}
	miog.RaidStatistics.ScrollFrame.Rows.accountChars = {}

	local r,g,b = CreateColorFromHexString(miog.CLRSCC.black):GetRGB()

	for i = 1, 6, 1 do
		local currentFrame = miog.MainTab.Information.Currency[tostring(i)]

		miog.createFrameBorder(currentFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		currentFrame:SetBackdropColor(r, g, b, 0.8)

	end

	pveFrame2.TitleBar.Expand:SetScript("OnClick", function()

		MIOG_SavedSettings.frameExtended.value = not MIOG_SavedSettings.frameExtended.value

		if(MIOG_SavedSettings.frameExtended.value == true) then
			miog.Plugin:SetHeight(miog.Plugin.extendedHeight)

		elseif(MIOG_SavedSettings.frameExtended.value == false) then
			miog.Plugin:SetHeight(miog.Plugin.standardHeight)

		end
	end)

	pveFrame2.TitleBar.RaiderIOLoaded:SetText(WrapTextInColorCode("NO R.IO", miog.CLRSCC["red"]))
	pveFrame2.TitleBar.RaiderIOLoaded:SetShown(not miog.F.IS_RAIDERIO_LOADED)

	local queueRolePanel = miog.MainTab.QueueInformation.RolePanel
	local leader, tank, healer, damager = LFDQueueFrame_GetRoles()

	local function setRoles()
		SetLFGRoles(queueRolePanel.Leader.Checkbox:GetChecked(), queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())

	end

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

	PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")

	local queueDropDown = miog.MainTab.QueueInformation.DropDown
	queueDropDown:OnLoad()
	queueDropDown:SetText("Choose a queue")
	miog.MainTab.QueueInformation.Panel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local offset = 35 + 20
	local _, _, _, tabSlots = GetSpellTabInfo(1)

	local formatter = CreateFromMixins(SecondsFormatterMixin)
	formatter:Init(3600, SecondsFormatter.Abbreviation.OneLetter)

	--[[for i = 1, tabSlots, 1 do
		local spellType, id

		local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player)
		spellType, id = spellBookItemInfo.itemType, spellBookItemInfo.actionID]]

	local lastExpansionFrames = {}

	for index, info in ipairs(miog.TELEPORT_FLYOUT_IDS) do
		--if(spellType == "FLYOUT" or spellType == 4) then
			local name, description, numSlots, isKnown = GetFlyoutInfo(info.id)

			--print(name, id)

			--if(string.find(name, "Hero's Path")) then
			local expansionInfo = GetExpansionDisplayInfo(info.expansion)

			local logoFrame = miog.Teleports[tostring(info.expansion)]

			if(logoFrame and expansionInfo) then
				logoFrame.Texture:SetTexture(expansionInfo.logo)

				local expNameTable = {}

				for k = 1, numSlots, 1 do
					local flyoutSpellID, _, spellKnown, spellName, _ = GetFlyoutSlotInfo(info.id, k)

					table.insert(expNameTable, {name = spellName, desc = C_Spell.GetSpellDescription(flyoutSpellID), spellID = flyoutSpellID, known = spellKnown})
				end

				table.sort(expNameTable, function(k1, k2)
					return k1.desc < k2.desc
				end)

				for k, v in ipairs(expNameTable) do
					local spellInfo = C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(v.spellID) or C_SpellBook.GetSpellInfo(v.spellID)
					local tpButton = CreateFrame("Button", nil, miog.Teleports, "MIOG_TeleportButtonTemplate")
					tpButton:SetNormalTexture(spellInfo.iconID)
					tpButton:GetNormalTexture():SetDesaturated(not v.known)
					tpButton:SetPoint("LEFT", lastExpansionFrames[info.expansion] or logoFrame, "RIGHT", lastExpansionFrames[info.expansion] and k == 1 and 18 or 3, 0)

					lastExpansionFrames[info.expansion] = tpButton

					if(v.known) then
						local myCooldown = tpButton.Cooldown
						
						tpButton:HookScript("OnShow", function()
							local start, duration, _, modrate = GetSpellCooldown(v.spellID)
							myCooldown:SetCooldown(start, duration, modrate)

							local secondsLeft = duration - (GetTime() - start)
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
			--end
		--end
	end

	miog.pveFrame2.categoryFramePool = CreateFramePool("Button", miog.pveFrame2.CategoryHoverFrame, "MIOG_MenuButtonTemplate", resetCategoryFrame)
	miog.pveFrame2.TitleBar.CreateGroup.Text:SetText("Create")
	miog.pveFrame2.TitleBar.CreateGroup.setupFunction = function(self)
		startNewGroup(self)

		LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.EntryCreation);

		PanelTemplates_SetTab(miog.pveFrame2, 1)

		if(miog.pveFrame2.selectedTabFrame) then
			miog.pveFrame2.selectedTabFrame:Hide()
		end

		miog.pveFrame2.TabFramesPanel.MainTab:Show()
		miog.pveFrame2.selectedTabFrame = miog.pveFrame2.TabFramesPanel.MainTab
	end

	miog.pveFrame2.TitleBar.FindGroup.Text:SetText("Find")
	miog.pveFrame2.TitleBar.FindGroup.setupFunction = function(self)
		findGroup(self)

		LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)

		PanelTemplates_SetTab(miog.pveFrame2, 1)

		if(miog.pveFrame2.selectedTabFrame) then
			miog.pveFrame2.selectedTabFrame:Hide()
		end

		miog.pveFrame2.TabFramesPanel.MainTab:Show()
		miog.pveFrame2.selectedTabFrame = miog.pveFrame2.TabFramesPanel.MainTab
	end

	miog.pveFrame2.TitleBar.DungeonJournal.Text:SetText("Journal")
	miog.pveFrame2.TitleBar.DungeonJournal:SetScript("OnClick", function()
		miog.setActivePanel(nil, "AdventureJournal")

		PanelTemplates_SetTab(miog.pveFrame2, 1)

		if(miog.pveFrame2.selectedTabFrame) then
			miog.pveFrame2.selectedTabFrame:Hide()
		end

		miog.pveFrame2.TabFramesPanel.MainTab:Show()
		miog.pveFrame2.selectedTabFrame = miog.pveFrame2.TabFramesPanel.MainTab
	end)

	miog.pveFrame2.TitleBar.RaiderIOChecker.Text:SetText("IO")
	miog.pveFrame2.TitleBar.RaiderIOChecker:SetScript("OnClick", function()
		miog.setActivePanel(nil, "RaiderIOChecker")

		PanelTemplates_SetTab(miog.pveFrame2, 1)

		if(miog.pveFrame2.selectedTabFrame) then
			miog.pveFrame2.selectedTabFrame:Hide()
		end

		miog.pveFrame2.TabFramesPanel.MainTab:Show()
		miog.pveFrame2.selectedTabFrame = miog.pveFrame2.TabFramesPanel.MainTab
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
