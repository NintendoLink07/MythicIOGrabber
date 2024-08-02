
local addonName, miog = ...
local wticc = WrapTextInColorCode

local playstyles = {
	Enum.LFGEntryPlaystyle.Standard,
	Enum.LFGEntryPlaystyle.Casual,
	Enum.LFGEntryPlaystyle.Hardcore
}

local function setUpRatingLevels()
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

	for k, v in ipairs(scoreTable) do
		if(v >= 0) then
			local info = {}

			info.text = v
			info.value = v
			info.checked = false
			info.func = function() miog.EntryCreation.Rating:SetText(v) end

			miog.EntryCreation.Rating.DropDown:CreateEntryFrame(info)
		end
		
	end
end

local function setUpItemLevels()
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

	for k, v in ipairs(itemLevelTable) do
		if(v >= 0) then
			local info = {}

			info.text = v
			info.value = v
			info.checked = false
			info.func = function() miog.EntryCreation.ItemLevel:SetText(v) end

			miog.EntryCreation.ItemLevel.DropDown:CreateEntryFrame(info)
		end

	end
end

local function createPlaystyleEntry(playstyle, activityInfo, playstyleDropDown)
    local info = {
        entryType = "option",
        text = C_LFGList.GetPlaystyleString(playstyle, activityInfo),
        value = playstyle,
        checked = false,
        func = function() LFGListEntryCreation_OnPlayStyleSelectedInternal(LFGListFrame.EntryCreation, playstyle) end
    }
    playstyleDropDown:CreateEntryFrame(info)
end

local function setUpPlaystyleDropDown()
    miog.EntryCreation.PlaystyleDropDown:ResetDropDown()

    local activityInfo = C_LFGList.GetActivityInfoTable(LFGListFrame.EntryCreation.selectedActivity)

    for _, playstyle in ipairs(playstyles) do
        createPlaystyleEntry(playstyle, activityInfo, miog.EntryCreation.PlaystyleDropDown)
    end
end

local function setUpDifficultyDropDown(categoryID, groupID, filters)
	local frame = miog.EntryCreation
	frame.DifficultyDropDown:ResetDropDown()

	local unsortedActivities = C_LFGList.GetAvailableActivities(categoryID or LFGListFrame.EntryCreation.selectedCategory, groupID or LFGListFrame.EntryCreation.selectedGroup, filters or LFGListFrame.EntryCreation.selectedFilters);
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
		local info = {}

		local activityID = v;
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
		local shortName = activityInfo and activityInfo.shortName

		if(shortName) then

			info.entryType = "option"
			info.index = k
			info.text = shortName
			info.value = activityID

			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.EntryCreation.selectedFilters), LFGListFrame.EntryCreation.selectedCategory, activityInfo.groupFinderActivityGroupID, activityID)
			end

			frame.DifficultyDropDown:CreateEntryFrame(info)
		end
	end

	if(miog.EntryCreation.ActivityDropDown:IsShown() == false) then
		local info = {}
		info.entryType = "option"
		info.index = 100000
		info.text = "More..."
		info.func = function()
			LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, categoryID, nil, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters))
		end

		frame.DifficultyDropDown:CreateEntryFrame(info)
	end
end

local function setUpEntryCreation()
	local frame = miog.EntryCreation

	local activityDropDown = frame.ActivityDropDown
	local playstyleDropDown = frame.PlaystyleDropDown
	local difficultyDropDown = frame.DifficultyDropDown
	local crossFaction = frame.CrossFaction

	local self = LFGListFrame.EntryCreation

	local categoryInfo = C_LFGList.GetLfgCategoryInfo(self.selectedCategory);
	local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity);
	local groupName = C_LFGList.GetActivityGroupInfo(self.selectedGroup);

	activityDropDown:SetShown((groupName or activityInfo.shortName) and not categoryInfo.autoChooseActivity)

	if(activityDropDown:IsShown() == false and activityDropDown:IsShown() == true) then
		difficultyDropDown:Hide()

	else
		difficultyDropDown:SetShown(not categoryInfo.autoChooseActivity)

	end

	local shouldShowPlayStyleDropdown = (categoryInfo.showPlaystyleDropdown) and (activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity or activityInfo.isCurrentRaidActivity or activityInfo.isMythicActivity);
	local shouldShowCrossFactionToggle = (categoryInfo.allowCrossFaction);
	local shouldDisableCrossFactionToggle = (categoryInfo.allowCrossFaction) and not (activityInfo.allowCrossFaction);

	if(shouldShowPlayStyleDropdown) then
		setUpPlaystyleDropDown()
		playstyleDropDown:Enable()

	elseif(not shouldShowPlayStyleDropdown) then
		miog.EntryCreation.selectedPlaystyle = nil
		playstyleDropDown:Disable()

	end

	playstyleDropDown:SetShown(shouldShowPlayStyleDropdown);

	local _, localizedFaction = UnitFactionGroup("player");
	crossFaction:SetShown(shouldShowCrossFactionToggle)
	crossFaction:SetEnabled(not shouldDisableCrossFactionToggle)
	crossFaction:SetChecked(shouldDisableCrossFactionToggle)
	frame.CrossFactionString:SetShown(shouldShowCrossFactionToggle)

	frame.Rating:SetShown(activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity);
	frame.RatingString:SetShown(frame.Rating:IsShown());

	if ( activityInfo.ilvlSuggestion ~= 0 ) then
		frame.ItemLevel.instructions = format(LFG_LIST_RECOMMENDED_ILVL, activityInfo.ilvlSuggestion);
	else
		frame.ItemLevel.instructions = LFG_LIST_ITEM_LEVEL_INSTR_SHORT;
	end

	frame.ItemLevel:ClearAllPoints();
	frame.ItemLevel:SetShown(not activityInfo.isPvpActivity);
	frame.ItemLevelString:SetShown(frame.ItemLevel:IsShown())

	if(frame.Rating:IsShown()) then
		frame.ItemLevel:SetPoint("LEFT", frame.Rating, "RIGHT", 10, 0)

	else
		frame.ItemLevel:SetPoint(frame.Rating:GetPoint())

	end

	setUpDifficultyDropDown()

	local activitySuccess = activityDropDown:SelectFirstFrameWithValue(self.selectedActivity)

	difficultyDropDown:SelectFirstFrameWithValue(self.selectedActivity)
	playstyleDropDown:SelectFirstFrameWithValue(self.selectedPlaystyle)

	if(miog.ACTIVITY_INFO[self.selectedActivity]) then
		frame.Background:SetTexture(miog.ACTIVITY_INFO[self.selectedActivity].horizontal)

	else
		frame.Background:SetTexture(nil)

	end

	miog.EntryCreation.ActivityDropDown.List:MarkDirty()

	if(C_LFGList.HasActiveEntryInfo()) then
		local entryInfo = C_LFGList.GetActiveEntryInfo()

		miog.EntryCreation.PrivateGroup:SetChecked(entryInfo.privateGroup)
		miog.EntryCreation.ItemLevel:SetText(entryInfo.requiredItemLevel)
		miog.EntryCreation.Rating:SetText(entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating or "")

	end

end

hooksecurefunc("LFGListEntryCreation_Select", function(_, filters, categoryID, groupID, activityID)
	setUpEntryCreation()
end)

local function gatherGroupsAndActivitiesForCategory(categoryID)
	local activityDropDown = miog.EntryCreation.ActivityDropDown
	activityDropDown:ResetDropDown()

	local firstGroupID

	local selectedFilters = LFGListFrame.CategorySelection.selectedFilters or LFGListFrame.EntryCreation.selectedFilters

	local customFilters = categoryID == 1 and 4 or selectedFilters ~= 2 and Enum.LFGListFilter.Recommended or Enum.LFGListFilter.NotRecommended

	local borFilters = bit.bor(LFGListFrame.EntryCreation.baseFilters, customFilters)

	if(categoryID == 2 or categoryID == 3 and selectedFilters == Enum.LFGListFilter.NotRecommended) then
		local expansionTable = {}

		activityDropDown:CreateSeparator(9999)

		for i = 1, GetNumExpansions() - (1 + (categoryID == 3 and 1 or 0)), 1 do
			local expansionInfo = GetExpansionDisplayInfo(i - 1)

			local expInfo = {}
			expInfo.entryType = "arrow"
			expInfo.index = i - 1 + 10000
			expInfo.text = miog.EXPANSION_INFO[i][1]
			expInfo.icon = expansionInfo and expansionInfo.logo

			expansionTable[#expansionTable+1] = expInfo
		end

		for k, v in ipairs(expansionTable) do
			activityDropDown:CreateEntryFrame(v)

		end
	end

	if(categoryID == 1 or categoryID == 6) then
		local questingCustomTable = {}
		local groups = C_LFGList.GetAvailableActivityGroups(categoryID, borFilters)

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(categoryID, v)

			local activityID = activities[#activities] -- LAST LAYOUT INDEX FRAME

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
			local info = {}

			info.entryType = "option"
			info.index = activityInfo.groupFinderActivityGroupID
			info.text = C_LFGList.GetActivityGroupInfo(v)
			info.value = activityID
			info.activities = activities
			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters), categoryID, v, activityID)

			end

			info.icon = miog.ACTIVITY_INFO[activityID].icon
			info.mapID = miog.ACTIVITY_INFO[activityID].mapID

			questingCustomTable[#questingCustomTable+1] = info


			if(k == 1) then
				firstGroupID = groups[1]
			end
		end

		for k, v in ipairs(questingCustomTable) do
			activityDropDown:CreateEntryFrame(v)

		end
	elseif(categoryID == 2) then

		local mythicPlusTable = {}
		local currentExpansionDungeons = {}
		local legacyDungeonsTable = {}

		local seasonGroups = C_LFGList.GetAvailableActivityGroups(categoryID, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE))

		for k, v in ipairs(seasonGroups) do
			local activities = C_LFGList.GetAvailableActivities(categoryID, v)
			local activityID = activities[#activities]

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
			local info = {}

			info.entryType = "option"
			info.index = activityInfo.groupFinderActivityGroupID
			info.text = C_LFGList.GetActivityGroupInfo(v)
			info.value = activityID
			info.activities = activities
			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, v, activityID)

			end

			info.icon = miog.ACTIVITY_INFO[activityID].icon
			info.mapID = miog.ACTIVITY_INFO[activityID].mapID

			if(not firstGroupID and k == 1) then
				firstGroupID = v
			end

			mythicPlusTable[#mythicPlusTable+1] = info
		end

		table.sort(mythicPlusTable, function(k1, k2)
			return k1.text < k2.text
		end)

		activityDropDown:CreateTextLine(-1, nil, "Seasonal Mythic+ Dungeons")

		for k, v in ipairs(mythicPlusTable) do
			v.index = k
			activityDropDown:CreateEntryFrame(v)

		end

		local currentExpansionGroups = C_LFGList.GetAvailableActivityGroups(categoryID, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE))

		if(currentExpansionGroups and #currentExpansionGroups > 0) then
			activityDropDown:CreateSeparator(9)
			
		end

		for k, v in ipairs(currentExpansionGroups) do
			local activities = C_LFGList.GetAvailableActivities(categoryID, v)
			local activityID = activities[#activities]

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
			local info = {}

			info.entryType = "option"
			info.index = activityInfo.groupFinderActivityGroupID
			info.text = C_LFGList.GetActivityGroupInfo(v)
			info.value = activityID
			info.activities = activities
			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, v, activityID)

			end

			info.icon = miog.ACTIVITY_INFO[activityID].icon
			info.mapID = miog.ACTIVITY_INFO[activityID].mapID

			if(not firstGroupID and k == 1) then
				firstGroupID = v
			end

			currentExpansionDungeons[#currentExpansionDungeons+1] = info

		end

		table.sort(mythicPlusTable, function(k1, k2)
			return k1.text < k2.text
		end)

		for k, v in ipairs(currentExpansionDungeons) do
			activityDropDown:CreateEntryFrame(v)

		end
		
		local allExpansionsGroups = C_LFGList.GetAvailableActivityGroups(categoryID, Enum.LFGListFilter.PvE)

		local maxExpansions = GetNumExpansions() - 1

		for k, v in ipairs(allExpansionsGroups) do
			local activities = C_LFGList.GetAvailableActivities(categoryID, v)
			local activityID = activities[#activities]

			if(miog.ACTIVITY_INFO[activityID].expansionLevel < maxExpansions) then
				local info = {}
				info.icon = miog.ACTIVITY_INFO[activityID].icon

				info.parentIndex = miog.ACTIVITY_INFO[activityID].expansionLevel + 10000
				info.entryType = "option"
				info.mapID = miog.ACTIVITY_INFO[activityID].mapID
				info.text = C_LFGList.GetActivityGroupInfo(v)
				info.activities = activities

				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

				info.value = activityID
				info.func = function()
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, v, activityID)

				end

				if(not firstGroupID and k == 1) then
					firstGroupID = v
				end

				legacyDungeonsTable[#legacyDungeonsTable+1] = info
			end

		end

		local activities = C_LFGList.GetAvailableActivities(categoryID, 0, 6)

		for activityIndex, activityID in ipairs(activities) do
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
				local info = {}

				info.entryType = "option"
				info.parentIndex = miog.ACTIVITY_INFO[activityID].expansionLevel + 10000
				info.mapID = miog.ACTIVITY_INFO[activityID].mapID
				info.text = activityInfo.shortName
				info.value = activityID
				--info.activities = activities
				info.func = function()
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, 0, activityID)

				end
				info.icon = miog.ACTIVITY_INFO[activityID].icon

				if(not firstGroupID and activityIndex == 1) then
					firstGroupID = activityID
				end

				legacyDungeonsTable[#legacyDungeonsTable+1] = info
		end

		table.sort(legacyDungeonsTable, function(k1, k2)
			return k1.text < k2.text
		end)

		for k, v in ipairs(legacyDungeonsTable) do
			activityDropDown:CreateEntryFrame(v)

		end
	elseif(categoryID == 3) then
		local currentRaidTable = {}
		local legacyRaidTable = {}

		if(selectedFilters ~= Enum.LFGListFilter.NotRecommended) then
			local groups = C_LFGList.GetAvailableActivityGroups(categoryID, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or borFilters);

			for k, v in ipairs(groups) do
				local activities = C_LFGList.GetAvailableActivities(categoryID, v)
				local activityID = activities[#activities]

				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
				local info = {}

				info.entryType = "option"
				info.index = activityInfo.groupFinderActivityGroupID
				info.text = C_LFGList.GetActivityGroupInfo(v)
				info.value = activityID
				info.activities = activities
				info.func = function()
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, v, activityID)

				end
				info.icon = miog.ACTIVITY_INFO[activityID].icon
				info.mapID = miog.ACTIVITY_INFO[activityID].mapID

				currentRaidTable[#currentRaidTable+1] = info

				if(k == 1) then
					firstGroupID = groups[1]
				end
			end

			local worldBossActivity = C_LFGList.GetAvailableActivities(categoryID, 0, 5)

			for k, activityID in ipairs(worldBossActivity) do
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

				local info = {}
				info.entryType = "option"
				info.index = 5000
				info.text = activityInfo.fullName
				info.value = activityID
				info.activities = worldBossActivity

				info.func = function()
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, activityInfo.groupFinderActivityGroupID, activityID)

				end

				info.icon = miog.ACTIVITY_INFO[activityID].icon
				info.mapID = miog.ACTIVITY_INFO[activityID].mapID

				currentRaidTable[#currentRaidTable+1] = info

				if(k == 1) then
					firstGroupID = groups[1]
				end
			end
			----
			-- /dump Enum.LFGListFilter
			----

		elseif(selectedFilters == Enum.LFGListFilter.NotRecommended) then

			local activities = C_LFGList.GetAvailableActivities(categoryID, 0, 6)

			for activityIndex, activityID in ipairs(activities) do
				if(miog.ACTIVITY_INFO[activityID]) then
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
					local info = {}

					info.entryType = "option"
					info.index = activityIndex
					info.parentIndex = miog.ACTIVITY_INFO[activityID].expansionLevel + 10000
					info.text = activityInfo.fullName
					info.value = activityID
					info.activities = {activityID}
					info.func = function()
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, 0, activityID)

					end

					info.mapID = miog.ACTIVITY_INFO[activityID].mapID
					info.icon = miog.ACTIVITY_INFO[activityID].icon

					legacyRaidTable[#legacyRaidTable+1] = info

					if(activityIndex == 1) then
						firstGroupID = activityInfo.groupFinderActivityGroupID
					end

				end
			end

			local groups = C_LFGList.GetAvailableActivityGroups(categoryID, bit.bor(Enum.LFGListFilter.NotRecommended, Enum.LFGListFilter.PvE));
			--local groups = C_LFGList.GetAvailableActivityGroups(categoryID, borFilters)

			for k, v in ipairs(groups) do
				local activities = C_LFGList.GetAvailableActivities(categoryID, v)
				local activityID = activities[#activities]
	
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
				local info = {}
	
				info.entryType = "option"
				info.index = activityInfo.groupFinderActivityGroupID
				info.text = C_LFGList.GetActivityGroupInfo(v)
				info.value = activityID
				info.activities = activities
				info.func = function()
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, v, activityID)
	
				end
				info.icon = miog.ACTIVITY_INFO[activityID].icon
				info.mapID = miog.ACTIVITY_INFO[activityID].mapID
	
				info.parentIndex = miog.ACTIVITY_INFO[activityID].expansionLevel + 10000
				legacyRaidTable[#legacyRaidTable+1] = info
	
				if(k == 1) then
					firstGroupID = groups[1]
				end
			end
		end

		for k, v in ipairs(currentRaidTable) do
			activityDropDown:CreateEntryFrame(v)

		end

		for k, v in ipairs(legacyRaidTable) do
			activityDropDown:CreateEntryFrame(v)

		end

	elseif(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
		local pvpTable = {}

		local pvpActivities = C_LFGList.GetAvailableActivities(categoryID, 0, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters));
		firstGroupID = 0

		for _, v in ipairs(pvpActivities) do
			local activityID = v

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

			local info = {}
			info.entryType = "option"
			info.text = activityInfo.fullName
			info.value = activityID
			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, 0, activityID)
			end

			local mapID = miog.retrieveMapIDFromGFID(activityInfo.groupFinderActivityGroupID)

			if(mapID) then
				info.icon = miog.MAP_INFO[mapID].icon
			end

			pvpTable[#pvpTable+1] = info
		end

		for k, v in ipairs(pvpTable) do
			activityDropDown:CreateEntryFrame(v)

		end

	end

	local listTable = {}

	activityDropDown:CreateSeparator(99999)

	local info = {}
	info.entryType = "option"
	info.index = 100000
	info.text = "More..."
	info.func = function()
		LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, categoryID, nil, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters))
	end

	listTable[#listTable+1] = info

	for k, v in ipairs(listTable) do
		activityDropDown:CreateEntryFrame(v)

	end

	if(C_LFGList.HasActiveEntryInfo()) then
		local entryInfo = C_LFGList.GetActiveEntryInfo()
		local activityInfo = C_LFGList.GetActivityInfoTable(entryInfo.activityID)

		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters), activityInfo, activityInfo.groupFinderActivityGroupID, entryInfo.activityID)

	else
		if(categoryID == 2) then
			local regularActivityID, regularGroupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones

			if(regularActivityID) then
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters), categoryID, regularGroupID, regularActivityID)

			else
				local timewalkingActivityID, timewalkingGroupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true)  -- Check for a timewalking keystone.

				if(timewalkingActivityID) then
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters), categoryID, timewalkingGroupID, timewalkingActivityID)

				else
					local firstFrame = activityDropDown:GetFrameAtLayoutIndex(1)
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters), categoryID, firstGroupID, firstFrame and firstFrame.value or nil)

				end
			end
		else
			local firstFrame = activityDropDown:GetFrameAtLayoutIndex(1)

			if(firstFrame and not firstFrame.value) then
				firstFrame = activityDropDown:GetFirstChildFrameFromLayoutFrame(1)

			end

			LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters), categoryID, firstGroupID, firstFrame and firstFrame.value or nil)

		end
	end
end

function LFGListEntryCreationActivityFinder_Accept(self)
	if ( self.selectedActivity ) then
		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, self.selectedActivity);
	end
	self:Hide();
end

local function initializeActivityDropdown()
	local categoryID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory or 0

	local frame = miog.EntryCreation

	local activityDropDown = frame.ActivityDropDown
	activityDropDown:ResetDropDown()

	gatherGroupsAndActivitiesForCategory(categoryID)

	miog.EntryCreation.ActivityDropDown.List:MarkDirty()
end

miog.initializeActivityDropdown = initializeActivityDropdown

function LFGListEntryCreation_UpdateValidState(self)
	local errorText;
	local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity)
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

function LFGListEntryCreation_UpdateAuthenticatedState(self)
	local isAuthenticated = C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity);
	LFGListFrame.EntryCreation.Description.EditBox:SetEnabled(isAuthenticated);
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local isQuestListing = activeEntryInfo and activeEntryInfo.questID or nil;
	LFGListFrame.EntryCreation.Name:SetEnabled(isAuthenticated and not isQuestListing);
	LFGListFrame.EntryCreation.VoiceChat.EditBox:SetEnabled(isAuthenticated)
end

miog.createEntryCreation = function()
	local frame = CreateFrame("Frame", "MythicIOGrabber_EntryCreation", miog.Plugin.InsertFrame, "MIOG_EntryCreation") ---@class Frame
	frame:GetParent().EntryCreation = frame
	miog.EntryCreation = frame

	--miog.createFrameBorder(miog.EntryCreation.Background, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	miog.EntryCreation.Border:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	frame.selectedActivity = 0

	local activityDropDown = frame.ActivityDropDown
	activityDropDown:OnLoad()

	local difficultyDropDown = frame.DifficultyDropDown
	difficultyDropDown:OnLoad()

	local playstyleDropDown = frame.PlaystyleDropDown
	playstyleDropDown:OnLoad()

	local nameField = LFGListFrame.EntryCreation.Name
	nameField:ClearAllPoints()
	nameField:SetAutoFocus(false)
	nameField:SetParent(frame)
	nameField:SetSize(frame:GetWidth() - 15, 25)
	--nameField:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -80)
	nameField:SetPoint(frame.Name:GetPoint())
	frame.Name = nameField
	frame.NameString:SetPoint("BOTTOMLEFT", nameField, "TOPLEFT", -5, 0)

	local descriptionField = LFGListFrame.EntryCreation.Description
	descriptionField:ClearAllPoints()
	descriptionField:SetParent(frame)
	descriptionField:SetSize(frame:GetWidth() - 20, 50)
	descriptionField:SetPoint("TOPLEFT", frame.Name, "BOTTOMLEFT", 0, -20)
	frame.Description = descriptionField
	
	frame.Rating:SetPoint("TOPLEFT", frame.Description, "BOTTOMLEFT", 0, -20)
	
	local voiceChat = LFGListFrame.EntryCreation.VoiceChat
	--voiceChat.CheckButton:SetNormalTexture("checkbox-minimal")
	--voiceChat.CheckButton:SetPushedTexture("checkbox-minimal")
	--voiceChat.CheckButton:SetCheckedTexture("checkmark-minimal")
	--voiceChat.CheckButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	voiceChat.CheckButton:Hide()
	voiceChat.Label:Hide()
	voiceChat.EditBox:ClearAllPoints()
	voiceChat.EditBox:SetPoint("LEFT", frame.VoiceChat, "LEFT")
	--voiceChat:SetPoint("LEFT", frame.VoiceChat, "LEFT", -6, 0)
	voiceChat:ClearAllPoints()
	voiceChat:SetParent(frame)
	
	--miogDropdown.List:MarkDirty()
	--miogDropdown:MarkDirty()

	miog.EntryCreation.StartGroup:SetPoint("RIGHT", miog.Plugin.FooterBar, "RIGHT")
	miog.EntryCreation.StartGroup:SetScript("OnClick", function()
		miog.listGroup()
	end)

	frame:HookScript("OnShow", function(self)
		if(C_LFGList.HasActiveEntryInfo()) then
			LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)
			self.StartGroup:SetText("Update")

		else
			LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, false)
			self.StartGroup:SetText("Start Group")

		end
	end)

	frame:HookScript("OnHide", function(self)
		self.ActivityDropDown.List:Hide()
		self.DifficultyDropDown.List:Hide()
		self.PlaystyleDropDown.List:Hide()
	end)

	local activityFinder = LFGListFrame.EntryCreation.ActivityFinder
	activityFinder:ClearAllPoints()
	activityFinder:SetParent(frame)
	activityFinder:SetPoint("TOPLEFT", frame, "TOPLEFT")
	activityFinder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	activityFinder:SetFrameStrata("DIALOG")

	frame.ItemLevel.DropDown.Selected:Hide()
	frame.ItemLevel.DropDown.Button:Show()
	frame.ItemLevel.DropDown:OnLoad()
	setUpItemLevels()

	frame.Rating.DropDown.Selected:Hide()
	frame.Rating.DropDown.Button:Show()
	frame.Rating.DropDown:OnLoad()
	setUpRatingLevels()
end