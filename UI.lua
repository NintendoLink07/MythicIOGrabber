local addonName, miog = ...
local wticc = WrapTextInColorCode

local function setUpPlaystyleDropDown()
	local playstyleDropDown = miog.entryCreation.PlaystyleDropDown
	playstyleDropDown:ResetDropDown()

	local info = {}
		
	info.entryType = "option"

	local activityInfo = C_LFGList.GetActivityInfoTable(LFGListFrame.EntryCreation.selectedActivity);

	if (activityInfo.isRatedPvpActivity) then
		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Standard, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Standard;
		info.checked = false;
		info.func = function() LFGListEntryCreation_OnPlayStyleSelected(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.PlayStyleDropdown, Enum.LFGEntryPlaystyle.Standard); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

		info.text =  C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Casual, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Casual;
		info.checked = false;
		info.func = function() LFGListEntryCreation_OnPlayStyleSelected(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.PlayStyleDropdown, Enum.LFGEntryPlaystyle.Casual); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Hardcore, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Hardcore;
		info.checked = false;
		info.func = function() LFGListEntryCreation_OnPlayStyleSelected(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.PlayStyleDropdown, Enum.LFGEntryPlaystyle.Hardcore); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

	else
		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Standard, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Standard;
		info.checked = false;
		info.func = function() LFGListEntryCreation_OnPlayStyleSelected(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.PlayStyleDropdown, Enum.LFGEntryPlaystyle.Standard); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Casual, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Casual;
		info.checked = false;
		info.func = function() LFGListEntryCreation_OnPlayStyleSelected(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.PlayStyleDropdown, Enum.LFGEntryPlaystyle.Casual); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Hardcore, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Hardcore;
		info.func = function() LFGListEntryCreation_OnPlayStyleSelected(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.PlayStyleDropdown, Enum.LFGEntryPlaystyle.Hardcore); end;
		info.checked = false;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)
	end
end

local function setUpDifficultyDropDown(categoryID, groupID, filters)
	local frame = miog.entryCreation
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

	local entryFrame = nil
	
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
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.EntryCreation.selectedFilters), LFGListFrame.EntryCreation.selectedCategory, nil, activityID)
				DevTools_Dump(activityInfo)
			end

			entryFrame = frame.DifficultyDropDown:CreateEntryFrame(info)
		end
	end

	if(miog.entryCreation.ActivityDropDown:IsShown() == false) then
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
	local frame = miog.entryCreation

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
		miog.entryCreation.selectedPlaystyle = nil
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
	if(not activitySuccess) then
		activityDropDown:SelectFirstFrameWithValue(self.selectedGroup)

	end

	difficultyDropDown:SelectFirstFrameWithValue(self.selectedActivity)
	playstyleDropDown:SelectFirstFrameWithValue(self.selectedPlaystyle)

	if(miog.ACTIVITY_INFO[self.selectedActivity]) then
		frame.Background:SetTexture(miog.ACTIVITY_INFO[self.selectedActivity].horizontal)

	else
		frame.Background:SetTexture(nil)
	
	end

	miog.entryCreation.ActivityDropDown.List:MarkDirty()
	miog.entryCreation.ActivityDropDown:MarkDirty()

	if(C_LFGList.HasActiveEntryInfo()) then
		local entryInfo = C_LFGList.GetActiveEntryInfo()

		miog.entryCreation.PrivateGroup:SetChecked(entryInfo.privateGroup)
		miog.entryCreation.ItemLevel:SetText(entryInfo.requiredItemLevel)
		miog.entryCreation.Rating:SetText(entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating or "")

	end

end

hooksecurefunc("LFGListEntryCreation_Select", function(_, filters, categoryID, groupID, activityID)
	setUpEntryCreation()
end)

local function gatherGroupsAndActivitiesForCategory(categoryID)
	local activityDropDown = miog.entryCreation.ActivityDropDown
	activityDropDown:ResetDropDown()

	local firstGroupID

	local borFilters = bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters)

	-- DUNGEONS

	if(categoryID == 2 or categoryID == 3 and LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
		local expansionTable = {}

		activityDropDown:CreateSeparator(9999)

		for i = 0, GetNumExpansions() - 2, 1 do
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
			local activityID = activities[#activities]

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
			local info = {}

			info.entryType = "option"
			info.index = activityInfo.groupFinderActivityGroupID
			info.text = C_LFGList.GetActivityGroupInfo(v)
			info.value = activityID
			info.activities = activities
			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
				
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

		if(C_LFGList.GetAdvancedFilter) then

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
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
					
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
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
					
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

			local allExpansionsGroups = C_LFGList.GetAvailableActivityGroups(categoryID)

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
					info.value = activityID
					info.func = function()
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
						
					end

					if(not firstGroupID and k == 1) then
						firstGroupID = v
					end

					legacyDungeonsTable[#legacyDungeonsTable+1] = info
				end
				
			end
		else
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
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
					
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
				local activityID = activities[#activities]
	
				--if(miog.ACTIVITY_INFO[activityID].expansionLevel == i) then
				if(miog.ACTIVITY_INFO[activityID].expansionLevel < maxExpansions) then
					local info = {}
					info.icon = miog.ACTIVITY_INFO[activityID].icon
	
					info.parentIndex = miog.ACTIVITY_INFO[activityID].expansionLevel + 10000
					info.entryType = "option"
					info.mapID = miog.ACTIVITY_INFO[activityID].mapID
					info.text = C_LFGList.GetActivityGroupInfo(v)
					info.value = activityID
					info.func = function()
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
						
					end
	
					legacyDungeonsTable[#legacyDungeonsTable+1] = info
				end
				
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
				info.func = function()
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, 0, activityID)
					
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

		local groups = C_LFGList.GetAvailableActivityGroups(categoryID, borFilters)

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
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
				
			end
			info.icon = miog.ACTIVITY_INFO[activityID].icon
			info.mapID = miog.ACTIVITY_INFO[activityID].mapID

			if(LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
				info.parentIndex = miog.ACTIVITY_INFO[activityID].expansionLevel + 10000
				legacyRaidTable[#legacyRaidTable+1] = info

			else
				currentRaidTable[#currentRaidTable+1] = info
			
			end

			if(k == 1) then
				firstGroupID = groups[1]
			end
		end

		if(LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.Recommended) then
			local worldBossActivity = C_LFGList.GetAvailableActivities(categoryID, 0, 5)
	
			for _, activityID in ipairs(worldBossActivity) do
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
				if(activityInfo.filters == 5) then
					local info = {}
					info.entryType = "option"
					info.index = 5000
					info.text = activityInfo.fullName
					info.value = activityID
					info.activities = worldBossActivity

					info.func = function()
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, activityInfo.groupFinderActivityGroupID, activityID)
						
					end

					info.icon = miog.ACTIVITY_INFO[activityID].icon
					info.mapID = miog.ACTIVITY_INFO[activityID].mapID

					currentRaidTable[#currentRaidTable+1] = info
	
				end
	
			end
			
		elseif(LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
			local activities = C_LFGList.GetAvailableActivities(categoryID, 0, 6)

			for activityIndex, activityID in ipairs(activities) do
				if(miog.ACTIVITY_INFO[activityID]) then
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
					local info = {}

					info.entryType = "option"
					info.index = #groups + activityIndex
					info.parentIndex = miog.ACTIVITY_INFO[activityID].expansionLevel + 10000
					info.text = activityInfo.fullName
					info.value = activityID
					info.activities = activities
					info.func = function()
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, 0, activityID)
						
					end

					info.mapID = miog.ACTIVITY_INFO[activityID].mapID
					info.icon = miog.ACTIVITY_INFO[activityID].icon

					legacyRaidTable[#legacyRaidTable+1] = info
				
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

		local pvpActivities = C_LFGList.GetAvailableActivities(categoryID, 0, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters));
		firstGroupID = 0
	
		for _, v in ipairs(pvpActivities) do
			local activityID = v

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

			local info = {}
			info.entryType = "option"
			info.text = activityInfo.fullName
			info.value = activityID
			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, 0, activityID)
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
		LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, categoryID, nil, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters))
	end

	listTable[#listTable+1] = info

	for k, v in ipairs(listTable) do
		activityDropDown:CreateEntryFrame(v)

	end

	if(C_LFGList.HasActiveEntryInfo()) then
		local entryInfo = C_LFGList.GetActiveEntryInfo()
		local activityInfo = C_LFGList.GetActivityInfoTable(entryInfo.activityID)
		
		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), activityInfo, activityInfo.groupFinderActivityGroupID, entryInfo.activityID)

	else
		if(categoryID == 2) then
			local regularActivityID, regularGroupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones

			if(regularActivityID) then
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, regularGroupID, regularActivityID)

			else
				local timewalkingActivityID, timewalkingGroupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true)  -- Check for a timewalking keystone.

				if(timewalkingActivityID) then
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, timewalkingGroupID, timewalkingActivityID)

				else
					local firstFrame = activityDropDown:GetFrameAtLayoutIndex(1)
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, firstGroupID, firstFrame and firstFrame.value or nil)
				
				end
			end
		else
			local firstFrame = activityDropDown:GetFrameAtLayoutIndex(1)
			LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, firstGroupID, firstFrame and firstFrame.value or nil)

		end
	end
end

function LFGListEntryCreationActivityFinder_Accept(self)
	if ( self.selectedActivity ) then
		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, self.selectedActivity);
	end
	self:Hide();
end

local function initializeActivityDropdown(isDifferentCategory, isSeparateCategory)
	local categoryID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory or 0

	local frame = miog.entryCreation
	
	if(isDifferentCategory or isSeparateCategory) then
		local activityDropDown = frame.ActivityDropDown
		activityDropDown:ResetDropDown()

		gatherGroupsAndActivitiesForCategory(categoryID)
		--selectActivity(activityDropDown:GetFrameAtLayoutIndex(1).value)

		miog.entryCreation.ActivityDropDown.List:MarkDirty()
		miog.entryCreation.ActivityDropDown:MarkDirty()
	end
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

local function updateFilterDifficulties()
	local difficultyDropDown = miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown
	difficultyDropDown:ResetDropDown()

	local isPvp = LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7 or LFGListFrame.SearchPanel.categoryID == 8 or LFGListFrame.SearchPanel.categoryID == 9
	local isDungeon = LFGListFrame.SearchPanel.categoryID == 2
	local isRaid = LFGListFrame.SearchPanel.categoryID == 3
	
	local currentValue = isDungeon and "dungeonDifficultyID" or isRaid and "raidDifficultyID" or isPvp and "bracketID" or nil

	for k, v in ipairs(isRaid and miog.RAID_DIFFICULTIES or isPvp and {6, 7} or miog.DUNGEON_DIFFICULTIES) do
		local info = {}
		info.entryType = "option"
		info.text = isPvp and (v == 6 and "2v2" or "3v3") or miog.DIFFICULTY_ID_INFO[v].name
		info.level = 1
		info.value = v
		info.func = function()
			if(currentValue) then
				MIOG_SavedSettings[miog.F.ACTIVE_PANEL .. "_FilterOptions"].table[currentValue] = v
	
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end
		end
		
		difficultyDropDown:CreateEntryFrame(info)

	end

	difficultyDropDown:MarkDirty()
	difficultyDropDown.List:MarkDirty()

	local success = difficultyDropDown:SelectFirstFrameWithValue(MIOG_SavedSettings[miog.F.ACTIVE_PANEL .. "_FilterOptions"].table[currentValue])
end

local function createUpgradedInvitePendingDialog()
	local inviteBox = CreateFrame("Frame", "MythicIOGrabber_InviteBox", WorldFrame, "MIOG_InviteBox")
	miog.inviteBox = inviteBox
	StaticPopup_SetUpPosition(inviteBox)
	--inviteBox:Hide()

	--miog.createFrameBorder(inviteBox, 1, CreateColorFromHexString(miog.CLRSCC.yellow):GetRGBA())
	--inviteBox:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
	miog.createFrameBorder(inviteBox.TitleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	inviteBox.framePool = CreateFramePool("Frame", inviteBox.Container, "MIOG_InviteBoxFrameTemplate", function(self)
		self.layoutIndex = nil
	end)

	inviteBox.Container:MarkDirty()
end

miog.ONCE = 0

miog.createFrames = function()
	EncounterJournal_LoadUI()
	EJ_SelectInstance(1207)

	C_EncounterJournal.OnOpen = miog.dummyFunction
	

	if(addonName == "MythicIOGrabber_Lite") then
		miog.Plugin = CreateFrame("Frame", "MythicIOGrabber_PluginFrame", LFGListFrame, "MIOG_Plugin")
		miog.Plugin:SetPoint("TOPLEFT", PVEFrameLeftInset, "TOPRIGHT")
		miog.Plugin:SetSize(LFGListFrame:GetWidth(), LFGListFrame:GetHeight() - PVEFrame.TitleContainer:GetHeight() - 7)

	else
		miog.createPVEFrameReplacement()
		miog.Plugin = CreateFrame("Frame", "MythicIOGrabber_PluginFrame", miog.MainTab, "MIOG_Plugin")
		miog.Plugin:SetPoint("TOPLEFT", miog.MainTab, "TOPRIGHT", -372, 0)
		miog.Plugin:SetPoint("TOPRIGHT", miog.MainTab, "TOPRIGHT")
		miog.Plugin:SetSize(372, 370)
		
		miog.Plugin:SetHeight(miog.pveFrame2:GetHeight() - miog.pveFrame2.TitleBar:GetHeight() - miog.Plugin.FooterBar:GetHeight() - 5)
		miog.createFrameBorder(miog.Plugin.FooterBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		miog.Plugin.FooterBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

		local standardWidth = miog.Plugin:GetWidth()

		miog.Plugin.Resize:SetScript("OnMouseUp", function()
			miog.Plugin:StopMovingOrSizing()

			MIOG_SavedSettings.frameManuallyResized.value = miog.Plugin:GetHeight()

			if(MIOG_SavedSettings.frameManuallyResized.value > miog.Plugin.standardHeight) then
				MIOG_SavedSettings.frameExtended.value = true
				miog.Plugin.extendedHeight = MIOG_SavedSettings.frameManuallyResized.value

			end

			--frame.Plugin:ClearAllPoints()
			miog.Plugin:SetPoint("TOPLEFT", miog.Plugin:GetParent(), "TOPRIGHT", -standardWidth, 0)
			miog.Plugin:SetPoint("TOPRIGHT", miog.Plugin:GetParent(), "TOPRIGHT", 0, 0)

		end)

		miog.Plugin.standardHeight = miog.Plugin:GetHeight()
		miog.Plugin.extendedHeight = MIOG_SavedSettings.frameManuallyResized and MIOG_SavedSettings.frameManuallyResized.value > 0 and MIOG_SavedSettings.frameManuallyResized.value or miog.Plugin.standardHeight * 1.5

		miog.Plugin:SetResizeBounds(standardWidth, miog.Plugin.standardHeight, standardWidth, GetScreenHeight() * 0.67)
		miog.Plugin:SetHeight(MIOG_SavedSettings.frameExtended.value == true and MIOG_SavedSettings.frameManuallyResized and MIOG_SavedSettings.frameManuallyResized.value > 0 and MIOG_SavedSettings.frameManuallyResized.value or miog.Plugin.standardHeight)

		miog.createFrameBorder(miog.Plugin, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		miog.Plugin:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
		
	end

	miog.createApplicationViewer()
	miog.createSearchPanel()
	miog.createEntryCreation()

	if(miog.MainTab) then
		miog.loadQueueSystem()
		miog.loadFilterPanel()
	end

	-- IMPLEMENTING CALENDAR EVENTS IN VERSION 2.1
	--miog.scriptReceiver:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
	--miog.scriptReceiver:RegisterEvent("CALENDAR_OPEN_EVENT")

	hooksecurefunc("LFGListFrame_SetActivePanel", function(_, panel)
		if(panel == LFGListFrame.ApplicationViewer) then
			miog.F.ACTIVE_PANEL = "applicationViewer"
			miog.searchPanel:Hide()
			miog.entryCreation:Hide()
			miog.Plugin:Show()
			miog.applicationViewer:Show()

			if(addonName == "MythicIOGrabber") then
				miog.MainTab.CategoryPanel:Hide()
				miog.searchPanel.PanelFilters:Hide()
				miog.setupFiltersForActivePanel()
				miog.pveFrame2:Show()
				miog.pveFrame2.SidePanel.Container.FilterPanel:Show()
				miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Hide()

			else
				LFGListFrame.ApplicationViewer:Hide()
			
			end
	
		elseif(panel == LFGListFrame.SearchPanel) then
			miog.F.ACTIVE_PANEL = "searchPanel"
			miog.applicationViewer:Hide()
			miog.entryCreation:Hide()
			miog.Plugin:Show()
			miog.searchPanel:Show()
	
			if(addonName == "MythicIOGrabber") then
				miog.pveFrame2:Show()
				miog.MainTab.CategoryPanel:Hide()
				miog.setupFiltersForActivePanel()
				miog.searchPanel.PanelFilters:Show()
				miog.pveFrame2.SidePanel.Container.FilterPanel:Show()
				miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Hide()

				if(LFGListFrame.SearchPanel.categoryID == 2 or LFGListFrame.SearchPanel.categoryID == 3 or LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) then
					updateFilterDifficulties()
					miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown:Enable()
					miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton:Enable()
					

					if(miog.UPDATED_DUNGEON_FILTERS == nil) then
						miog.updateDungeonCheckboxes()

					end

					if(miog.UPDATED_RAID_FILTERS == nil) then
						miog.updateRaidCheckboxes()
					end

					if(LFGListFrame.SearchPanel.categoryID == 2) then
						miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DungeonPanel:Show()
						miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DungeonPanel.OptionsButton:Show()

						miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.RaidPanel:Hide()
						miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.RaidPanel.OptionsButton:Hide()
						
					elseif(LFGListFrame.SearchPanel.categoryID == 3) then
						miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DungeonPanel:Hide()
						miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DungeonPanel.OptionsButton:Hide()

						miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.RaidPanel:Show()
						miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.RaidPanel.OptionsButton:Show()

					end
		
				else
					--miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown:Hide()
					--miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton:Hide()
				
					miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton:Disable()
					miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown:Disable()
				end
	
				miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[
					LFGListFrame.SearchPanel.categoryID == 2 and "filterForDungeonDifficulty" or
					LFGListFrame.SearchPanel.categoryID == 3 and "filterForRaidDifficulty" or
					(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "filterForArenaBracket"] or false)
			

			else
				LFGListFrame.SearchPanel:Hide()
			end
	
		elseif(panel == LFGListFrame.EntryCreation) then
			--LFGListFrame.EntryCreation.editMode = false
			miog.applicationViewer:Hide()
			miog.searchPanel:Hide()
	
			miog.Plugin:Show()
			miog.entryCreation:Show()

			if(addonName == "MythicIOGrabber") then
				miog.pveFrame2:Show()
				miog.MainTab.CategoryPanel:Hide()
				miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Show()
				miog.searchPanel.PanelFilters:Hide()

			else
				LFGListFrame.EntryCreation:Hide()
				miog.initializeActivityDropdown(true, C_LFGList.GetLfgCategoryInfo(LFGListFrame.CategorySelection.selectedCategory).separateRecommended)
			
			end
			
		else
			--miog.applicationViewer:Hide()
			--miog.searchPanel:Hide()
			--miog.entryCreation:Hide()
			miog.Plugin:Hide()

			if(addonName == "MythicIOGrabber") then
				miog.MainTab.CategoryPanel:Show()
				miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Show()
				miog.searchPanel.PanelFilters:Hide()
			end
	
		end
	end)
end