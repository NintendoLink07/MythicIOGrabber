
local addonName, miog = ...
local wticc = WrapTextInColorCode

local selectedExpansion, defaultGroup, defaultActivity = nil, nil, nil

local addedInstances = {}

local playstyles = {
	Enum.LFGEntryPlaystyle.None,
	Enum.LFGEntryPlaystyle.Standard,
	Enum.LFGEntryPlaystyle.Casual,
	Enum.LFGEntryPlaystyle.Hardcore
}

local generalPlaystyles = {
	Enum.LFGEntryGeneralPlaystyle.Learning,
	Enum.LFGEntryGeneralPlaystyle.FunRelaxed,
	Enum.LFGEntryGeneralPlaystyle.FunSerious,
	Enum.LFGEntryGeneralPlaystyle.Expert,

}

local function setUpRatingLevels(entryCreation)
	local score = C_ChallengeMode.GetOverallDungeonScore()

	local lowest = miog.round3(score, 50)

	local scoreTable = {}
	scoreTable[1] = lowest - 200
	scoreTable[2] = lowest - 150
	scoreTable[3] = lowest - 100
	scoreTable[4] = lowest - 50
	scoreTable[5] = lowest

	if(scoreTable[5] ~= score) then
		scoreTable[6] = score

	end

	local selectedValue

	entryCreation.Rating.DropDown:SetupMenu(function(dropdown, rootDescription)
		local clearButton = rootDescription:CreateButton(CLEAR_ALL, function()
			selectedValue = nil
			miog.EntryCreation.Rating:SetText("")

		end)

		for k, v in ipairs(scoreTable) do
			if(v >= 0) then
				local button = rootDescription:CreateRadio(v, function(value) return value == selectedValue end, function(value)
					selectedValue = value
					miog.EntryCreation.Rating:SetText(selectedValue)
		
				end, v)
			end
	
		end
	end)
end

local function setUpItemLevels(entryCreation)
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
	local itemLevelTable = {}

	local lowest = miog.round3(avgItemLevelEquipped, 5)

	itemLevelTable[1] = lowest - 20
	itemLevelTable[2] = lowest - 15
	itemLevelTable[3] = lowest - 10
	itemLevelTable[4] = lowest - 5
	itemLevelTable[5] = lowest

	if(itemLevelTable[5] ~= miog.round(avgItemLevelEquipped, 0)) then
		itemLevelTable[6] = miog.round(avgItemLevelEquipped, 0)
	end
		
	local selectedValue

	entryCreation.ItemLevel.DropDown:SetupMenu(function(dropdown, rootDescription)
		local clearButton = rootDescription:CreateButton(CLEAR_ALL, function()
			selectedValue = nil
			miog.EntryCreation.ItemLevel:SetText("")

		end)

		for k, v in ipairs(itemLevelTable) do
			if(v >= 0) then
				local button = rootDescription:CreateRadio(v, function(value) return value == selectedValue end, function(value)
					selectedValue = value
					miog.EntryCreation.ItemLevel:SetText(selectedValue)
		
				end, v)
			end
	
		end
	end)
end

local function setUpPlaystyleDropDown()
	miog.EntryCreation.PlaystyleDropDown:SetupMenu(function(dropdown, rootDescription)
		if(LFGListFrame.EntryCreation.selectedActivity) then
			local activityInfo = miog:GetActivityInfo(LFGListFrame.EntryCreation.selectedActivity)
		
			for k, playstyleInfo in ipairs(generalPlaystyles) do
				local activityButton = rootDescription:CreateRadio(C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.None, playstyleInfo, activityInfo), function(playstyle) return playstyle == LFGListFrame.EntryCreation.selectedPlaystyle end, function(playstyle)
					LFGListEntryCreation_OnPlayStyleSelectedInternal(LFGListFrame.EntryCreation, playstyle)
		
				end, playstyleInfo)
			end
		end
	end)
	
	LFGListEntryCreation_OnPlayStyleSelectedInternal(LFGListFrame.EntryCreation, playstyles[1])
end

local function setUpDifficultyDropDown()
	miog.EntryCreation.DifficultyDropDown:SetupMenu(function(dropdown, rootDescription)
		local unsortedActivities = C_LFGList.GetAvailableActivities(LFGListFrame.EntryCreation.selectedCategory, LFGListFrame.EntryCreation.selectedGroup);
		local activities = {}

		unsortedActivities = unsortedActivities and #unsortedActivities > 0 and unsortedActivities or miog:GetGroupInfo(LFGListFrame.EntryCreation.selectedGroup).activities

		if(LFGListFrame.EntryCreation.selectedCategory == 2 or LFGListFrame.EntryCreation.selectedCategory == 3) then
			local numOfActivities = #unsortedActivities

			for k, v in ipairs(unsortedActivities) do
				activities[k] = unsortedActivities[numOfActivities - k + 1]

			end

		else
			activities = unsortedActivities

		end

		for k, v in ipairs(activities) do
			local activityInfo = miog:GetActivityInfo(v)

			if(activityInfo.abbreviatedName) then
				local activityButton = rootDescription:CreateRadio(activityInfo.shortName, function(data) return data.activityID == LFGListFrame.EntryCreation.selectedActivity end, function(data)
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, activityInfo.groupFinderActivityGroupID, v)

				end, {activityID = v, groupID = activityInfo.groupFinderActivityGroupID})
			end
		end

		if(miog.EntryCreation.ActivityDropDown:IsShown() == false) then
			local activityButton = rootDescription:CreateRadio("More...", nil, function()
				LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, LFGListFrame.CategorySelection.selectedCategory, nil, LFGListFrame.EntryCreation.selectedFilters)
				
			end)
		end
	end)
end

--[[local function setUpDifficultyDropDown()
	miog.EntryCreation.DifficultyDropDown:SetupMenu(function(dropdown, rootDescription)
		local groupDB = miog:GetGroupInfo(LFGListFrame.EntryCreation.selectedGroup);

		if(groupDB) then
			local unsortedActivities = groupDB.activities
			local activities = {}

			if(LFGListFrame.EntryCreation.selectedCategory == 2 or LFGListFrame.EntryCreation.selectedCategory == 3) then
				local numOfActivities = #unsortedActivities

				for k, v in ipairs(unsortedActivities) do
					activities[k] = unsortedActivities[numOfActivities - k + 1]

				end

			else
				activities = unsortedActivities

			end

			for k, v in ipairs(activities) do
				local activityInfo = miog:GetActivityInfo(v)

				if(activityInfo.shortName) then
					local activityButton = rootDescription:CreateRadio(activityInfo.shortName, function(data) return data.activityID == LFGListFrame.EntryCreation.selectedActivity end, function(data)
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, activityInfo.groupFinderActivityGroupID, v)

					end, {activityID = v, groupID = activityInfo.groupFinderActivityGroupID})
				end
			end

			if(miog.EntryCreation.ActivityDropDown:IsShown() == false) then
				local activityButton = rootDescription:CreateRadio("More...", nil, function()
					LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, LFGListFrame.CategorySelection.selectedCategory, nil, LFGListFrame.EntryCreation.selectedFilters)
					
				end)
			end
		end
	end)

	
end]]

function LFGListEntryCreation_SetTitleFromActivityInfo(self)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if(not self.selectedActivity or not self.selectedGroup or not self.selectedCategory) then
		return;
	end
	local activityID = activeEntryInfo and activeEntryInfo.activityIDs[1] or (self.selectedActivity or 0);
	local activityInfo = miog:GetActivityInfo(activityID)
	if((activityInfo and activityInfo.isMythicPlusActivity) or not C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity)) then
		--Is protected, first showed up in 11.0.2
		--C_LFGList.SetEntryTitle(self.selectedActivity, self.selectedGroup, self.selectedPlaystyle);
	end
end

local function addActivityListToDropdown(list, rootDescription)
	for k, v in ipairs(list) do
		local activityButton = rootDescription:CreateRadio(v.name, function(data) return (data.groupID > 0 and data.groupID == LFGListFrame.EntryCreation.selectedGroup or data.activityID == LFGListFrame.EntryCreation.selectedActivity) and selectedExpansion == nil end, function(data)
			selectedExpansion = nil

			LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, v.groupID, v.activityID)
		end, v)

		local activityInfo = miog:GetActivityInfo(v.activityID)

		if(activityInfo) then
			activityButton:AddInitializer(function(button, description, menu)
				local leftTexture = button:AttachTexture();
				leftTexture:SetSize(16, 16);
				leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
				leftTexture:SetTexture(activityInfo.icon);

				button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

				return button.fontString:GetUnboundedStringWidth() + 18 + 5
			end)
		end

		if(not defaultGroup and not defaultActivity and k == 1) then
			defaultGroup = v.groupID
			defaultActivity = v.activityID
		end
	end
end

local function addExpansionHeadersToDropdown(rootDescription)
	if(LFGListFrame.CategorySelection.selectedCategory == 2 or LFGListFrame.CategorySelection.selectedCategory == 3 and LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
		local allExpansionsGroups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, Enum.LFGListFilter.PvE)
		local expansionGroupList = {}

		local expansionButtonList = {}

		local currentTier = EJ_GetNumTiers() - 1

		local hasOneOfCurrentTier = false
	
		for _, y in ipairs(allExpansionsGroups) do
			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, y)
			local activityID = activities[#activities]
			local activityInfo = miog:GetActivityInfo(activityID)

			if(activityInfo.tier == currentTier) then
				hasOneOfCurrentTier = true

			end

			tinsert(expansionGroupList, {name = miog:GetActivityGroupName(activityID), activityID = activityID, groupID = y, tier = activityInfo.tier, icon = activityInfo.icon})

		end
		
		local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, 0, 6)

		for _, activityID in ipairs(activities) do
			local activityInfo = miog:GetActivityInfo(activityID)

			if(activityInfo.tier == i) then
				tinsert(expansionGroupList, {name = activityInfo.instanceName, activityID = activityID, groupID = 0})

			end
		end

		if(not hasOneOfCurrentTier) then
			local groupsDone = {}

			for _, activityID in ipairs(miog.manualData.activity) do
				local activityInfo = miog:GetActivityInfo(activityID)
				
				if(not groupsDone[activityInfo.groupFinderActivityGroupID]) then
					if(activityInfo.tier == currentTier and activityInfo.isRaid ~= true) then
						tinsert(expansionGroupList, {name = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID), activityID = activityID, groupID = activityInfo.groupFinderActivityGroupID, tier = activityInfo.tier, icon = activityInfo.icon})

					end

					groupsDone[activityInfo.groupFinderActivityGroupID] = true
				end
			end
		end

		table.sort(expansionGroupList, function(k1, k2)
			return k1.name < k2.name
		end)

		for i = 1, EJ_GetNumTiers() - 1, 1 do
			local expansionInfo = GetExpansionDisplayInfo(i-1)
			local expansionButton = rootDescription:CreateRadio(miog.TIER_INFO[i].name, function(index) return index == selectedExpansion end, function(index) end, i)
	
			expansionButton:AddInitializer(function(button, description, menu)
				local leftTexture = button:AttachTexture();
				leftTexture:SetSize(16, 16);
				leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
				leftTexture:SetTexture(expansionInfo.logo);

				button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

				return button.fontString:GetUnboundedStringWidth() + 18 + 5
			end)

			tinsert(expansionButtonList, expansionButton)
		end

		local currGroup, currActivity, currExp

		for k, v in ipairs(expansionGroupList) do
			local activityButton = expansionButtonList[v.tier]:CreateRadio(v.name, function(data) return (data.groupID > 0 and data.groupID == LFGListFrame.EntryCreation.selectedGroup or data.activityID == LFGListFrame.EntryCreation.selectedActivity) and selectedExpansion == i end, function(data)
				selectedExpansion = i

				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, v.groupID, v.activityID)

			end, v)

			activityButton:AddInitializer(function(button, description, menu)
				local leftTexture = button:AttachTexture();
				leftTexture:SetSize(16, 16);
				leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
				leftTexture:SetTexture(v.icon);

				button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

				return button.fontString:GetUnboundedStringWidth() + 18 + 5
			end)

			if(k == 1) then
				currGroup = v.groupID
				currActivity = v.activityID
				currExp = v.tier
				
			end
		end

		if(not selectedExpansion and not defaultGroup and not defaultActivity) then
			defaultGroup = currGroup
			defaultActivity = currActivity
			selectedExpansion = currExp
			
		end
	end
end

hooksecurefunc("LFGListSearchPanel_SetCategory", function()
	defaultGroup, defaultActivity, selectedExpansion = nil, nil, nil
end)

local function gatherAllActivities(dropdown, rootDescription)
	if(LFGListFrame.CategorySelection.selectedCategory == 1 or LFGListFrame.CategorySelection.selectedCategory == 6) then
		local activityList = {}
		local groups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, LFGListFrame.CategorySelection.selectedFilters)

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
			local activityID = activities[#activities]

			tinsert(activityList, {index = v, name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, groupID = v})
		end

		addActivityListToDropdown(activityList, rootDescription)

	elseif(LFGListFrame.CategorySelection.selectedCategory == 2) then
		local mythicPlusTable = {}
		local currentExpansionDungeons = {}

		local seasonGroups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.Recommended))
		
		for k, v in ipairs(seasonGroups) do
			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
			local activityID = activities[#activities]

			tinsert(mythicPlusTable, {index = k, name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, groupID = v})
		end

		table.sort(mythicPlusTable, function(k1, k2)
			return k1.name < k2.name
		end)
		
		rootDescription:CreateTitle("Seasonal Mythic+ Dungeons")
		addActivityListToDropdown(mythicPlusTable, rootDescription)
		rootDescription:CreateDivider();

		local currentExpansionGroups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE))

		for k, v in ipairs(currentExpansionGroups) do
			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
			local activityID = activities[#activities]

			tinsert(currentExpansionDungeons, {index = k, name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, groupID = v})
		end

		table.sort(currentExpansionDungeons, function(k1, k2)
			return k1.name < k2.name
		end)
		
		rootDescription:CreateTitle(miog.TIER_INFO[EJ_GetNumTiers() - 1].name .. " Dungeons")
		addActivityListToDropdown(currentExpansionDungeons, rootDescription)
		rootDescription:CreateDivider();

		addExpansionHeadersToDropdown(rootDescription)

	elseif(LFGListFrame.CategorySelection.selectedCategory == 3) then
		local raidList = {}

		if(LFGListFrame.CategorySelection.selectedFilters ~= Enum.LFGListFilter.NotRecommended) then
			local groups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.CategorySelection.selectedFilters);

			for k, v in ipairs(groups) do
				local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
				local activityID = activities[#activities]

				tinsert(raidList, {index = k, name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, groupID = v})
			end

			local worldBossActivity = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, 0, 5)

			for k, activityID in ipairs(worldBossActivity) do
				local activityInfo = miog:GetActivityInfo(activityID)

				tinsert(raidList, {index = k, name = activityInfo.shortName, activityID = activityID, groupID = 0})
			end
			
			addActivityListToDropdown(raidList, rootDescription)

		elseif(LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
			addExpansionHeadersToDropdown(rootDescription)
			
		end
	elseif(LFGListFrame.CategorySelection.selectedCategory == 121) then
		local delvesTable = {}

		local groups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.CategorySelection.selectedFilters);
		
		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
			local activityID = activities[#activities]

			tinsert(delvesTable, {index = k, name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, groupID = v})
		end

		addActivityListToDropdown(delvesTable, rootDescription)

	elseif(LFGListFrame.CategorySelection.selectedCategory == 4 or LFGListFrame.CategorySelection.selectedCategory == 7 or LFGListFrame.CategorySelection.selectedCategory == 8 or LFGListFrame.CategorySelection.selectedCategory == 9) then
		local pvpTable = {}

		local pvpActivities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, 0, LFGListFrame.CategorySelection.selectedFilters);

		for k, activityID in ipairs(pvpActivities) do
			local activityInfo = miog:GetActivityInfo(activityID)

			tinsert(pvpTable, {index = k, name = activityInfo.mapName, activityID = activityID, groupID = 0})
		end

		addActivityListToDropdown(pvpTable, rootDescription)

	end

	local activityButton = rootDescription:CreateRadio("More...", function() end, function()
		LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, LFGListFrame.CategorySelection.selectedCategory, nil, LFGListFrame.CategorySelection.selectedFilters)

	end)
end

local function updateEntryCreation()
	local entryCreation = miog.EntryCreation
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(LFGListFrame.EntryCreation.selectedCategory);
	local activityInfo = miog:GetActivityInfo(LFGListFrame.EntryCreation.selectedActivity)
	local groupName = C_LFGList.GetActivityGroupInfo(LFGListFrame.EntryCreation.selectedGroup);
	
	setUpDifficultyDropDown()
	
	entryCreation.ActivityDropDown:SetShown((groupName or activityInfo.shortName) and not categoryInfo.autoChooseActivity);
	entryCreation.DifficultyDropDown:SetShown(activityInfo and not categoryInfo.autoChooseActivity and LFGListFrame.EntryCreation.selectedGroup and LFGListFrame.EntryCreation.selectedGroup > 0);

	local shouldShowPlayStyleDropdown = (categoryInfo.showPlaystyleDropdown) and activityInfo and (activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity or activityInfo.isCurrentRaidActivity or activityInfo.isMythicActivity);
	local shouldShowCrossFactionToggle = (categoryInfo.allowCrossFaction);
	local shouldDisableCrossFactionToggle = (categoryInfo.allowCrossFaction) and not (activityInfo.allowCrossFaction);

	if(shouldShowPlayStyleDropdown) then
		setUpPlaystyleDropDown()

	end

	entryCreation.PlaystyleDropDown:SetShown(shouldShowPlayStyleDropdown);

	local _, localizedFaction = UnitFactionGroup("player");
	entryCreation.CrossFaction:SetShown(shouldShowCrossFactionToggle)
	entryCreation.CrossFaction:SetEnabled(not shouldDisableCrossFactionToggle)
	entryCreation.CrossFaction:SetChecked(shouldDisableCrossFactionToggle)
	entryCreation.CrossFactionString:SetShown(shouldShowCrossFactionToggle)

	entryCreation.Rating:SetShown(activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity);
	entryCreation.RatingString:SetShown(entryCreation.Rating:IsShown());

	if ( activityInfo.ilvlSuggestion ~= 0 ) then
		entryCreation.ItemLevel.instructions = format(LFG_LIST_RECOMMENDED_ILVL, activityInfo.ilvlSuggestion);
	else
		entryCreation.ItemLevel.instructions = LFG_LIST_ITEM_LEVEL_INSTR_SHORT;
	end

	entryCreation.ItemLevel:ClearAllPoints();
	entryCreation.ItemLevel:SetShown(not activityInfo.isPvpActivity);
	entryCreation.ItemLevelString:SetShown(entryCreation.ItemLevel:IsShown())

	if(entryCreation.Rating:IsShown()) then
		entryCreation.ItemLevel:SetPoint("LEFT", entryCreation.Rating, "RIGHT", 10, 0)

	else
		entryCreation.ItemLevel:SetPoint(entryCreation.Rating:GetPoint())

	end

	if(C_LFGList.HasActiveEntryInfo()) then
		local entryInfo = C_LFGList.GetActiveEntryInfo()

		entryCreation.PrivateGroup:SetChecked(entryInfo.privateGroup)
		entryCreation.ItemLevel:SetText(entryInfo.requiredItemLevel)
		entryCreation.Rating:SetText(entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating or "")

	end

	if(activityInfo) then
		if(miog.isMIOGHQLoaded()) then
			entryCreation.Background:SetVertTile(false)
			entryCreation.Background:SetHorizTile(false)
			entryCreation.Background:SetTexture(activityInfo.horizontal, "CLAMP", "CLAMP")

		else
			entryCreation.Background:SetVertTile(true)
			entryCreation.Background:SetHorizTile(true)
			entryCreation.Background:SetTexture(activityInfo.horizontal, "MIRROR", "MIRROR")

		end

	else
		entryCreation.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/cave.png")

	end
end

hooksecurefunc("LFGListEntryCreation_Select", function(_, filters, categoryID, groupID, activityID)
	updateEntryCreation()
end)

local function selectKeystoneOrFirst()
	-- set to currently listed group if one is found
	if(C_LFGList.HasActiveEntryInfo()) then
		local entryInfo = C_LFGList.GetActiveEntryInfo()
		local activityInfo = miog:GetActivityInfo(entryInfo.activityIDs[1])

		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, activityInfo.categoryID, activityInfo.groupFinderActivityGroupID, entryInfo.activityIDs[1])
		return
	end

	-- set to keystone if one is found
	if(LFGListFrame.CategorySelection.selectedCategory == 2) then
		local regularActivityID, regularGroupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones

		if(regularActivityID) then
			LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, regularGroupID, regularActivityID)
			return

		else
			local timewalkingActivityID, timewalkingGroupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true)  -- Check for a timewalking keystone.

			if(timewalkingActivityID) then
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, timewalkingGroupID, timewalkingActivityID)
				return
			end
		end
	end

	if(defaultActivity) then
		-- set to first group found in all activities // default
		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, defaultGroup and defaultGroup > 0 and defaultGroup or nil, defaultActivity)
		
	end
end

local function initializeActivityDropdown()
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(LFGListFrame.CategorySelection.selectedCategory);

	miog.EntryCreation.CategoryName:SetText(categoryInfo.name)

	local keepOldData = not categoryInfo.preferCurrentArea and LFGListFrame.EntryCreation.selectedCategory == LFGListFrame.CategorySelection.selectedCategory and LFGListFrame.baseFilters == LFGListFrame.EntryCreation.baseFilters and LFGListFrame.EntryCreation.selectedFilters == LFGListFrame.CategorySelection.selectedFilters;
	LFGListEntryCreation_SetBaseFilters(LFGListFrame.EntryCreation, LFGListFrame.baseFilters);
	if ( not keepOldData ) then
		LFGListEntryCreation_Clear(LFGListFrame.EntryCreation);
		--LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters, LFGListFrame.CategorySelection.selectedCategory);
	end
	--LFGListEntryCreation_Clear(LFGListFrame.EntryCreation)

	miog.EntryCreation.ActivityDropDown:GenerateMenu()
	
	selectKeystoneOrFirst()
end

miog.initializeActivityDropdown = initializeActivityDropdown

function LFGListEntryCreationActivityFinder_Accept(self)
	if ( self.selectedActivity ) then
		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, self.selectedActivity);
	end
	self:Hide();
end

function LFGListEntryCreation_UpdateValidState(self)
	if(self.selectedActivity) then
		local errorText;

		local activityInfo = miog:GetActivityInfo(self.selectedActivity)
		local maxNumPlayers = activityInfo and  activityInfo.maxNumPlayers or 0;
		local mythicPlusDisableActivity = not C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity) and (activityInfo.isMythicPlusActivity and not C_LFGList.GetKeystoneForActivity(self.selectedActivity));
		if ( maxNumPlayers > 0 and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) >= maxNumPlayers ) then
			errorText = string.format(LFG_LIST_TOO_MANY_FOR_ACTIVITY, maxNumPlayers);
		elseif (mythicPlusDisableActivity) then
			errorText = LFG_AUTHENTICATOR_BUTTON_MYTHIC_PLUS_TOOLTIP;
		elseif ( LFGListEntryCreation_GetSanitizedName(self) == "" ) then
			errorText = LFG_LIST_MUST_HAVE_NAME;
		end

		LFGListEntryCreation_UpdateAuthenticatedState(self);

		LFGListFrame.EntryCreation.ListGroupButton.DisableStateClickButton:SetShown(mythicPlusDisableActivity);
		LFGListFrame.EntryCreation.ListGroupButton:SetEnabled(not errorText and not mythicPlusDisableActivity);
		LFGListFrame.EntryCreation.ListGroupButton.errorText = errorText;
	end
end

function LFGListEntryCreation_UpdateAuthenticatedState(self)
	local isAuthenticated = C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity);
	LFGListFrame.EntryCreation.Description.EditBox:SetEnabled(isAuthenticated);
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local isQuestListing = activeEntryInfo and activeEntryInfo.questID or nil;
	LFGListFrame.EntryCreation.Name:SetEnabled(isAuthenticated and not isQuestListing);
	LFGListFrame.EntryCreation.VoiceChat.EditBox:SetEnabled(isAuthenticated)
end

function AddSeasonalInstances(categoryID, rootDescription)
	local seasonalInstances = C_LFGList.GetAvailableActivityGroups(categoryID, Enum.LFGListFilter.CurrentSeason)

	for k, v in ipairs(seasonalInstances) do
		local activities = C_LFGList.GetAvailableActivities(categoryID, v)
		local activityID = activities[#activities]

		rootDescription:CreateRadio(C_LFGList.GetActivityGroupInfo(v), function(data) return selectedGroup == data.groupID end, function(data)
			selectedGroup = data.groupID
			LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, categoryID, data.groupID, data.activityID)

		end, {activityID = activityID, groupID = v})

		addedInstances[v] = true
	end
end

local function addIconInitializer(button, icon)
	if(icon) then
		button:AddInitializer(function(selfButton)
			local leftTexture = selfButton:AttachTexture();
			leftTexture:SetSize(16, 16);
			leftTexture:SetPoint("LEFT", selfButton, "LEFT", 16, 0);
			leftTexture:SetTexture(icon);

			selfButton.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

			return selfButton.fontString:GetUnboundedStringWidth() + 18 + 5
		end)
	end
end

local function setupActivities(dropdown, rootDescription)
	local categoryID = LFGListFrame.CategorySelection.selectedCategory

	if(categoryID == 1 or categoryID == 6) then
		local groups = C_LFGList.GetAvailableActivityGroups(categoryID, LFGListFrame.CategorySelection.selectedFilters)

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(categoryID, v)

			local groupButton = rootDescription:CreateButton(C_LFGList.GetActivityGroupInfo(v))

			for x, activityID in ipairs(activities) do
				local activityInfo = miog:GetActivityInfo(activityID)

				local activityButton = groupButton:CreateRadio(activityInfo.fullName, function(data) return LFGListFrame.EntryCreation.selectedGroup == data.groupID end, function(data)
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, categoryID, data.groupID, data.activityID)

				end, {activityID = activityID, groupID = v})

				addIconInitializer(activityButton, activityInfo.icon)
			end
		end
	elseif(categoryID == 2) then
		local seasonGroups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, Enum.LFGListFilter.CurrentSeason)
		
		for k, v in ipairs(seasonGroups) do
			local groupInfo = miog:GetGroupInfo(v)
			local activityID = groupInfo.highestDifficultyActivityID

			local activityButton = rootDescription:CreateRadio(C_LFGList.GetActivityGroupInfo(v), function(data) return LFGListFrame.EntryCreation.selectedGroup == data.groupID end, function(data)
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, categoryID, data.groupID, data.activityID)

			end, {activityID = activityID, groupID = v})
		end

		--[[table.sort(mythicPlusTable, function(k1, k2)
			return k1.name < k2.name
		end)
		
		rootDescription:CreateTitle("Seasonal Mythic+ Dungeons")
		addActivityListToDropdown(mythicPlusTable, rootDescription)
		rootDescription:CreateDivider();

		local currentExpansionGroups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE))

		for k, v in ipairs(currentExpansionGroups) do
			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
			local activityID = activities[#activities]

			tinsert(currentExpansionDungeons, {index = k, name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, groupID = v})
		end

		table.sort(currentExpansionDungeons, function(k1, k2)
			return k1.name < k2.name
		end)
		
		rootDescription:CreateTitle(miog.TIER_INFO[EJ_GetNumTiers() - 1].name .. " Dungeons")
		addActivityListToDropdown(currentExpansionDungeons, rootDescription)
		rootDescription:CreateDivider();

		addExpansionHeadersToDropdown(rootDescription)]]

	elseif(LFGListFrame.CategorySelection.selectedCategory == 3) then
		local raidList = {}

		if(LFGListFrame.CategorySelection.selectedFilters ~= Enum.LFGListFilter.NotRecommended) then
			local groups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.CategorySelection.selectedFilters);

			for k, v in ipairs(groups) do
				local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
				local activityID = activities[#activities]

				tinsert(raidList, {index = k, name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, groupID = v})
			end

			local worldBossActivity = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, 0, 5)

			for k, activityID in ipairs(worldBossActivity) do
				local activityInfo = miog:GetActivityInfo(activityID)

				tinsert(raidList, {index = k, name = activityInfo.shortName, activityID = activityID, groupID = 0})
			end
			
			addActivityListToDropdown(raidList, rootDescription)

		elseif(LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
			addExpansionHeadersToDropdown(rootDescription)
			
		end
	elseif(LFGListFrame.CategorySelection.selectedCategory == 121) then
		local delvesTable = {}

		local groups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.CategorySelection.selectedFilters);
		
		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
			local activityID = activities[#activities]

			tinsert(delvesTable, {index = k, name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, groupID = v})
		end

		addActivityListToDropdown(delvesTable, rootDescription)

	elseif(LFGListFrame.CategorySelection.selectedCategory == 4 or LFGListFrame.CategorySelection.selectedCategory == 7 or LFGListFrame.CategorySelection.selectedCategory == 8 or LFGListFrame.CategorySelection.selectedCategory == 9) then
		local pvpTable = {}

		local pvpActivities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, 0, LFGListFrame.CategorySelection.selectedFilters);

		for k, activityID in ipairs(pvpActivities) do
			local activityInfo = miog:GetActivityInfo(activityID)

			tinsert(pvpTable, {index = k, name = activityInfo.mapName, activityID = activityID, groupID = 0})
		end

		addActivityListToDropdown(pvpTable, rootDescription)

	end

	local activityButton = rootDescription:CreateRadio("More...", function() end, function()
		LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, LFGListFrame.CategorySelection.selectedCategory, nil, LFGListFrame.CategorySelection.selectedFilters)

	end)
end

miog.createEntryCreation = function()
	local entryCreation = CreateFrame("Frame", "MythicIOGrabber_EntryCreation", miog.Plugin.InsertFrame, "MIOG_EntryCreation") ---@class Frame
	entryCreation:GetParent().EntryCreation = entryCreation

	entryCreation.Border:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	entryCreation.selectedActivity = 0

	entryCreation.ActivityDropDown:SetDefaultText("Select an activity")
	entryCreation.DifficultyDropDown:SetDefaultText("Select a difficulty")
	entryCreation.PlaystyleDropDown:SetDefaultText("Select a playstyle")

    entryCreation.ActivityDropDown:SetupMenu(gatherAllActivities)

	local selectedGroup, selectedActivity

	--entryCreation.ActivityDropDown:SetupMenu(function(dropdown, rootDescription)
		--setupActivities(dropdown, rootDescription)
		--[[local currentCategory = LFGListFrame.CategorySelection.selectedCategory

		if(currentCategory) then
			addedInstances = {}

			local isRaid = currentCategory == 3
			local categoryName = C_LFGList.GetLfgCategoryInfo(currentCategory).name

			AddSeasonalInstances(currentCategory, rootDescription)

			if(currentCategory == 2) then
				local expansionDungeons = C_LFGList.GetAvailableActivityGroups(currentCategory, Enum.LFGListFilter.CurrentExpansion)

				rootDescription:CreateSpacer()

				local expansionName = miog.TIER_INFO[EJ_GetNumTiers() - 1].name .. " "

				if(#expansionDungeons > 0) then
					rootDescription:CreateTitle(expansionName .. DUNGEONS)

					for k, v in ipairs(expansionDungeons) do
						if(not addedInstances[v]) then
							local activities = C_LFGList.GetAvailableActivities(currentCategory, v)
							local activityID = activities[#activities]

							rootDescription:CreateRadio(C_LFGList.GetActivityGroupInfo(v), function(data) return selectedGroup == data.groupID end, function(data)
								selectedGroup = data.groupID
								LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, data.groupID, data.activityID)

							end, {activityID = activityID, groupID = v})

							addedInstances[v] = true
						end
					end

				else
					rootDescription:CreateTitle(expansionName .. CHALLENGES)

					local list = miog:GetUnlistedActivities()

					table.sort(list, function(k1, k2)
						return k1.isMythicPlusActivity and not k2.isMythicPlusActivity

					end)

					local addedHeader = false

					for _, v in ipairs(list) do
						if(not v.isRaid and (v.isMythicPlusActivity and v.redirectedDifficultyID == 8 or v.isMythicActivity and v.redirectedDifficultyID == 23)) then
							local groupID = v.groupFinderActivityGroupID

							if(not addedInstances[groupID]) then
								if(v.isMythicActivity and not addedHeader) then
									rootDescription:CreateTitle(expansionName .. DUNGEONS)
									addedHeader = true

								end

								rootDescription:CreateRadio(C_LFGList.GetActivityGroupInfo(groupID), function(data) return selectedGroup == data.groupID end, function(data)
									selectedGroup = data.groupID
									LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, data.groupID, data.activityID)

								end, {activityID = v.activityID, groupID = groupID})

								addedInstances[groupID] = true
							end
						end
					end
				end

				rootDescription:CreateSpacer()
			end

			if(isRaid or isDungeon) then
				rootDescription:CreateTitle(categoryName)

				local expansionButtons = {}

				for i = 1, EJ_GetNumTiers() - 2, 1 do
					local expansionInfo = GetExpansionDisplayInfo(i-1)
					expansionButtons[i] = rootDescription:CreateRadio(miog.TIER_INFO[i].name, function(index) return index == selectedExpansion end, function(index) end, i)
					expansionButtons[i]:AddInitializer(function(button, description, menu)
						local leftTexture = button:AttachTexture();
						leftTexture:SetSize(16, 16);
						leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
						leftTexture:SetTexture(expansionInfo.logo);

						button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

						return button.fontString:GetUnboundedStringWidth() + 18 + 5
					end)
				end

				local allExpansionActivities = C_LFGList.GetAvailableActivities(currentCategory, nil, Enum.LFGListFilter.PvE)
				local addedActivities = {}

				for _, activityID in ipairs(allExpansionActivities) do
					local activityInfo = miog:GetActivityInfo(activityID)
					local groupID = activityInfo.groupFinderActivityGroupID
					local name

					if(groupID ~= 0) then
						local groupInfo = miog:GetGroupInfo(groupID)
						activityID = groupInfo.highestDifficultyActivityID or activityID
						name = C_LFGList.GetActivityGroupInfo(groupID)

					else
						groupID = nil
						name = activityInfo.instanceName

					end

					if(not addedActivities[activityID]) then
						if(activityInfo.tier) then
							local activityButton = expansionButtons[activityInfo.tier]:CreateRadio(name, function(data) return not selectedGroup and selectedActivity == data.activityID end, function(data)
								selectedActivity = data.activityID
								LFGListEntryCreation_Select(LFGListFrame.EntryCreation, isRaid and Enum.LFGListFilter.NotRecommended or LFGListFrame.EntryCreation.selectedFilters, currentCategory, data.groupID, data.activityID)

							end, {activityID = activityID, groupID = groupID})

							activityButton:AddInitializer(function(button, description, menu)
								local leftTexture = button:AttachTexture();
								leftTexture:SetSize(16, 16);
								leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
								leftTexture:SetTexture(activityInfo.icon);

								button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

								return button.fontString:GetUnboundedStringWidth() + 18 + 5
							end)

							addedActivities[activityID] = true
						end
					end
				end
			end
		end]]
	--end)

	local nameField = LFGListFrame.EntryCreation.Name
	nameField:ClearAllPoints()
	nameField:SetAutoFocus(false)
	nameField:SetParent(entryCreation)
	nameField:SetSize(entryCreation:GetWidth() - 15, 25)
	--nameField:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -80)
	nameField:SetPoint(entryCreation.Name:GetPoint())
	entryCreation.Name = nameField
	entryCreation.NameString:SetPoint("BOTTOMLEFT", nameField, "TOPLEFT", -5, 0)

	local descriptionField = LFGListFrame.EntryCreation.Description
	descriptionField:ClearAllPoints()
	descriptionField:SetParent(entryCreation)
	descriptionField:SetSize(entryCreation:GetWidth() - 20, 50)
	descriptionField:SetPoint("TOPLEFT", entryCreation.Name, "BOTTOMLEFT", 0, -20)
	entryCreation.Description = descriptionField
	
	entryCreation.Rating:SetPoint("TOPLEFT", entryCreation.Description, "BOTTOMLEFT", 0, -20)
	
	local voiceChat = LFGListFrame.EntryCreation.VoiceChat
	--voiceChat.CheckButton:SetNormalTexture("checkbox-minimal")
	--voiceChat.CheckButton:SetPushedTexture("checkbox-minimal")
	--voiceChat.CheckButton:SetCheckedTexture("checkmark-minimal")
	--voiceChat.CheckButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	voiceChat.CheckButton:Hide()
	voiceChat.Label:Hide()
	voiceChat.EditBox:ClearAllPoints()
	voiceChat.EditBox:SetPoint("LEFT", entryCreation.VoiceChat, "LEFT")
	--voiceChat:SetPoint("LEFT", frame.VoiceChat, "LEFT", -6, 0)
	voiceChat:ClearAllPoints()
	voiceChat:SetParent(entryCreation)
	
	--miogDropdown.List:MarkDirty()
	--miogDropdown:MarkDirty()

	entryCreation.StartGroup:SetPoint("RIGHT", miog.Plugin.FooterBar, "RIGHT")
	entryCreation.StartGroup:SetScript("OnClick", function()
		miog.listGroup()
	end)

	entryCreation:SetScript("OnShow", function(self)
		if(C_LFGList.HasActiveEntryInfo()) then
			--LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)
			self.StartGroup:SetText("Update")

		else
			--LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, false)
			self.StartGroup:SetText("Start Group")

		end
	end)

	local activityFinder = LFGListFrame.EntryCreation.ActivityFinder
	activityFinder:ClearAllPoints()
	activityFinder:SetParent(entryCreation)
	activityFinder:SetPoint("TOPLEFT", entryCreation, "TOPLEFT")
	activityFinder:SetPoint("BOTTOMRIGHT", entryCreation, "BOTTOMRIGHT")
	activityFinder:SetFrameStrata("DIALOG")

	setUpItemLevels(entryCreation)
	setUpRatingLevels(entryCreation)

	return entryCreation
end