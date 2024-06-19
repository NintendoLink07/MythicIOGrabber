local addonName, miog = ...
local wticc = WrapTextInColorCode

local function createPlaystyleEntry(playstyle, activityInfo, playstyleDropDown)
    local info = {
        entryType = "option",
        text = C_LFGList.GetPlaystyleString(playstyle, activityInfo),
        value = playstyle,
        checked = false,
        func = function() LFGListEntryCreation_OnPlayStyleSelected(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.PlayStyleDropdown, playstyle) end
    }
    playstyleDropDown:CreateEntryFrame(info)
end

local function setUpPlaystyleDropDown()
    miog.EntryCreation.PlaystyleDropDown:ResetDropDown()

    local activityInfo = C_LFGList.GetActivityInfoTable(LFGListFrame.EntryCreation.selectedActivity)
    local playstyles = {
        Enum.LFGEntryPlaystyle.Standard,
        Enum.LFGEntryPlaystyle.Casual,
        Enum.LFGEntryPlaystyle.Hardcore
    }

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

	---@diagnostic disable-next-line: undefined-field
	local activityDropDown = frame.ActivityDropDown

	---@diagnostic disable-next-line: undefined-field
	local playstyleDropDown = frame.PlaystyleDropDown

	---@diagnostic disable-next-line: undefined-field
	local difficultyDropDown = frame.DifficultyDropDown

	---@diagnostic disable-next-line: undefined-field
	local crossFaction = frame.CrossFaction

	local self = LFGListFrame.EntryCreation

	local categoryInfo = C_LFGList.GetLfgCategoryInfo(self.selectedCategory);
	local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity);
	local groupName = C_LFGList.GetActivityGroupInfo(self.selectedGroup);

	activityDropDown:SetShown((groupName or activityInfo.shortName) and not categoryInfo.autoChooseActivity)

	if(self.ActivityDropDown:IsShown() == false and activityDropDown:IsShown() == true) then
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

		for i = 0, GetNumExpansions() - (2 + (categoryID == 3 and (IsPlayerAtEffectiveMaxLevel() and 0 or 1) or 0)), 1 do
			local expansionInfo = GetExpansionDisplayInfo(i)

			local expInfo = {}
			expInfo.entryType = "arrow"
			expInfo.index = i + 10000
			expInfo.text = miog.EXPANSION_INFO[i + 1][1]
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

		activityDropDown:CreateSeparator(9)

		local currentExpansionGroups = C_LFGList.GetAvailableActivityGroups(categoryID, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE))

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

		--local allExpansionsGroups = C_LFGList.GetAvailableActivityGroups(categoryID)

		
		local allExpansionsGroups = C_LFGList.GetAvailableActivityGroups(categoryID, bit.bor(Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE))

		local maxExpansions = GetNumExpansions() - 1

		for k, v in ipairs(allExpansionsGroups) do
			local activities = C_LFGList.GetAvailableActivities(categoryID, v)
			local activityID = activities[#activities]

			--if(miog.ACTIVITY_INFO[activityID].expansionLevel == i) then
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
		--[[else
			local groups = C_LFGList.GetAvailableActivityGroups(categoryID, borFilters)

			for k, v in ipairs(groups) do
				local activities = C_LFGList.GetAvailableActivities(categoryID, v)
				local activityID = activities[#activities]

				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

				local info = {}

				for activityIndex, difficultyActivityID in ipairs(activities) do
					local difficultyActivityInfo = C_LFGList.GetActivityInfoTable(difficultyActivityID)

					if(difficultyActivityInfo.isMythicPlusActivity) then
						info.sort = "mplus"

					end
				end

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

				if(k == 1) then
					firstGroupID = groups[1]
				end

				if(info.sort == "mplus") then
					mythicPlusTable[#mythicPlusTable+1] = info

				else
					currentExpansionDungeons[#currentExpansionDungeons+1] = info

				end
			end

			table.sort(mythicPlusTable, function(k1, k2)
				return k1.text < k2.text
			end)

			activityDropDown:CreateTextLine(-1, nil, "Seasonal Mythic+ Dungeons")

			for k, v in ipairs(mythicPlusTable) do
				v.index = k
				activityDropDown:CreateEntryFrame(v)

			end

			activityDropDown:CreateSeparator(9)

			for k, v in ipairs(currentExpansionDungeons) do
				activityDropDown:CreateEntryFrame(v)

			end

			groups = C_LFGList.GetAvailableActivityGroups(categoryID)

			local maxExpansions = GetNumExpansions() - 1

			for k, v in ipairs(groups) do
				local activities = C_LFGList.GetAvailableActivities(categoryID, v)
				local activityID = activities[#activities] -- SET TO HIGHEST DIFFICULTY

				if(miog.ACTIVITY_INFO[activityID].expansionLevel < maxExpansions) then
					local info = {}
					info.icon = miog.ACTIVITY_INFO[activityID].icon

					info.parentIndex = miog.ACTIVITY_INFO[activityID].expansionLevel + 10000
					info.entryType = "option"
					info.mapID = miog.ACTIVITY_INFO[activityID].mapID
					info.text = C_LFGList.GetActivityGroupInfo(v)
					info.value = activityID
					info.activities = activities
					info.func = function()
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, selectedFilters), categoryID, v, activityID)
					end

					legacyDungeonsTable[#legacyDungeonsTable+1] = info
				end

			end

		end]]

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

		--local groups = C_LFGList.GetAvailableActivityGroups(categoryID, borFilters)

		if(selectedFilters ~= Enum.LFGListFilter.NotRecommended) then
			local groups = C_LFGList.GetAvailableActivityGroups(categoryID, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE) or borFilters);

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

local function setActivePanel(_, panel)
	if(panel == LFGListFrame.ApplicationViewer) then
		miog.F.ACTIVE_PANEL = "applicationViewer"
		miog.SearchPanel:Hide()
		miog.EntryCreation:Hide()
		miog.Plugin:Show()
		miog.ApplicationViewer:Show()

		if(miog.AdventureJournal) then
			miog.AdventureJournal:Hide()
		end

		if(not miog.F.LITE_MODE) then
			miog.pveFrame2:Show()

		else
			LFGListFrame.ApplicationViewer:Hide()

		end

		if(UnitIsGroupLeader("player")) then
			miog.ApplicationViewer.Delist:Show()
			miog.ApplicationViewer.Edit:Show()

		else
			miog.ApplicationViewer.Delist:Hide()
			miog.ApplicationViewer.Edit:Hide()
			
		end

		if(MIOG_SavedSettings.activeSidePanel.value == "filter") then
			miog.Plugin.ButtonPanel:Hide()
			miog.FilterPanel.Lock:Hide()

			miog.FilterPanel:Show()

		elseif(MIOG_SavedSettings.activeSidePanel.value == "invites") then
			miog.Plugin.ButtonPanel:Hide()
			miog.LastInvites:Show()

		end

		miog.setupFiltersForActivePanel()

	elseif(panel == LFGListFrame.SearchPanel) then
		miog.F.ACTIVE_PANEL = "searchPanel"
		miog.ApplicationViewer:Hide()
		miog.EntryCreation:Hide()
		miog.Plugin:Show()
		miog.SearchPanel:Show()

		if(miog.AdventureJournal) then
			miog.AdventureJournal:Hide()
		end

		if(not miog.F.LITE_MODE) then
			miog.pveFrame2:Show()

		else
			LFGListFrame.SearchPanel:Hide()
		end

		if(MIOG_SavedSettings.activeSidePanel.value == "filter") then
			miog.Plugin.ButtonPanel:Hide()
			miog.FilterPanel.Lock:Hide()

			miog.FilterPanel:Show()

		elseif(MIOG_SavedSettings.activeSidePanel.value == "invites") then
			miog.Plugin.ButtonPanel:Hide()
			miog.LastInvites:Show()

		end

		if(miog.UPDATED_DUNGEON_FILTERS ~= true) then
			miog.updateDungeonCheckboxes()

		end

		if(miog.UPDATED_RAID_FILTERS ~= true) then
			miog.updateRaidCheckboxes()
		end

		miog.setupFiltersForActivePanel()

	elseif(panel == LFGListFrame.EntryCreation) then
		miog.ApplicationViewer:Hide()
		miog.SearchPanel:Hide()

		if(miog.AdventureJournal) then
			miog.AdventureJournal:Hide()
		end

		miog.Plugin:Show()
		miog.EntryCreation:Show()

		miog.FilterPanel.Lock:Show()

		if(not miog.F.LITE_MODE) then
			miog.pveFrame2:Show()

		else
			LFGListFrame.EntryCreation:Hide()
			miog.initializeActivityDropdown()

		end

	elseif(panel == "AdventureJournal") then
		miog.ApplicationViewer:Hide()
		miog.SearchPanel:Hide()
		miog.EntryCreation:Hide()

		miog.Plugin:Show()

		if(miog.AdventureJournal) then
			miog.AdventureJournal:Show()
		end

		miog.FilterPanel.Lock:Show()

	else
		miog.Plugin:Hide()
		miog.FilterPanel.Lock:Show()
	end
end

miog.setActivePanel = setActivePanel

miog.createFrames = function()
	EncounterJournal_LoadUI()
	EJ_SelectInstance(1207)

	C_EncounterJournal.OnOpen = miog.dummyFunction

	local settingsButton = CreateFrame("Button")
	settingsButton:SetSize(20, 20)
	settingsButton:SetNormalTexture("Interface/Addons/MythicIOGrabber/res/infoIcons/settingGear.png")
	settingsButton:SetScript("OnClick", function()
		Settings.OpenToCategory("MythicIOGrabber")
	end)

	if(miog.F.LITE_MODE == true) then
		miog.Plugin = CreateFrame("Frame", "MythicIOGrabber_PluginFrame", LFGListFrame, "MIOG_Plugin")
		miog.Plugin:SetPoint("TOPLEFT", PVEFrameLeftInset, "TOPRIGHT")
		miog.Plugin:SetSize(LFGListFrame:GetWidth(), LFGListFrame:GetHeight() - PVEFrame.TitleContainer:GetHeight() - 7)
		miog.Plugin:SetFrameStrata("HIGH")

		settingsButton:SetParent(PVEFrame)
		settingsButton:SetFrameStrata("HIGH")
		settingsButton:SetPoint("RIGHT", PVEFrameCloseButton, "LEFT", -2, 0)
	else
		miog.createPVEFrameReplacement()
		miog.Plugin = CreateFrame("Frame", "MythicIOGrabber_PluginFrame", miog.MainTab, "MIOG_Plugin")
		miog.Plugin:SetPoint("TOPLEFT", miog.MainTab.QueueInformation, "TOPRIGHT", 0, 0)
		miog.Plugin:SetPoint("TOPRIGHT", miog.MainTab, "TOPRIGHT", 0, 0)
		miog.Plugin:SetHeight(miog.pveFrame2:GetHeight() - miog.pveFrame2.TitleBar:GetHeight() - 5)

		miog.createFrameBorder(miog.Plugin, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		miog.Plugin:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

		miog.createFrameBorder(miog.MainTab.QueueInformation.LastGroup, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

		local r,g,b = CreateColorFromHexString(miog.CLRSCC.black):GetRGB()

		miog.MainTab.QueueInformation.LastGroup:SetBackdropColor(r, g, b, 0.9)

		PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")

		settingsButton:SetParent(miog.pveFrame2.TitleBar)
		settingsButton:SetPoint("RIGHT", miog.pveFrame2.TitleBar.CloseButton, "LEFT", -2, 0)

		miog.pveFrame2.TitleBar.Expand:SetPoint("RIGHT", settingsButton, "LEFT", -2, 0)
	end

	miog.Plugin:SetScript("OnEnter", function()
	
	end)
	
	miog.Plugin.ButtonPanel.FilterButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		miog.Plugin.ButtonPanel:Hide()

		miog.LastInvites:Hide()
		miog.FilterPanel:Show()

		MIOG_SavedSettings.activeSidePanel.value = "filter"

		if(LFGListFrame.activePanel ~= LFGListFrame.SearchPanel and LFGListFrame.activePanel ~= LFGListFrame.ApplicationViewer) then
			miog.FilterPanel.Lock:Show()

		else
			miog.FilterPanel.Lock:Hide()
		
		end
	end)

	miog.Plugin.ButtonPanel.LastInvitesButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		miog.Plugin.ButtonPanel:Hide()

		MIOG_SavedSettings.activeSidePanel.value = "invites"

		miog.LastInvites:Show()
		miog.FilterPanel:Hide()
	end)

	miog.createFrameBorder(miog.Plugin.ButtonPanel.FilterButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.Plugin.ButtonPanel.FilterButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.createFrameBorder(miog.Plugin.ButtonPanel.LastInvitesButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.Plugin.ButtonPanel.LastInvitesButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local standardWidth = miog.Plugin:GetWidth()

	miog.Plugin.Resize:SetScript("OnDragStart", function(self, button)
		self:GetParent():StartSizing()
	end)

	miog.Plugin.Resize:SetScript("OnDragStop", function(self)
		self:GetParent():StopMovingOrSizing()
	
		MIOG_SavedSettings.frameManuallyResized.value = miog.Plugin:GetHeight()

		if(MIOG_SavedSettings.frameManuallyResized.value > miog.Plugin.standardHeight) then
			MIOG_SavedSettings.frameExtended.value = true
			miog.Plugin.extendedHeight = MIOG_SavedSettings.frameManuallyResized.value

		end
	end)

	miog.Plugin.standardHeight = miog.Plugin:GetHeight()
	miog.Plugin.extendedHeight = MIOG_SavedSettings.frameManuallyResized and MIOG_SavedSettings.frameManuallyResized.value > 0 and MIOG_SavedSettings.frameManuallyResized.value or miog.Plugin.standardHeight * 1.5

	miog.Plugin:SetResizeBounds(standardWidth, miog.Plugin.standardHeight, standardWidth, GetScreenHeight() * 0.67)

	miog.Plugin:SetHeight(MIOG_SavedSettings.frameExtended.value and miog.Plugin.extendedHeight or miog.Plugin.standardHeight)

	miog.createFrameBorder(miog.Plugin.FooterBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.Plugin.FooterBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.MainFrame = miog.F.LITE_MODE and miog.Plugin or miog.pveFrame2

	miog.createApplicationViewer()
	miog.createSearchPanel()
	miog.createEntryCreation()
	miog.loadFilterPanel()
	miog.loadLastInvitesPanel()

	miog.createClassPanel()

	if(not miog.F.LITE_MODE) then
		miog.loadQueueSystem()
		miog.loadCalendarSystem()
		miog.loadGearingChart()
		miog.loadAdventureJournal()
		miog.loadPartyCheck()
		
	end

	miog.createInspectCoroutine()

	hooksecurefunc("LFGListFrame_SetActivePanel", function(_, panel)
		setActivePanel(_, panel)
	end)
end