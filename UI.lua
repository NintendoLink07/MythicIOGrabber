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
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
		local shortName = activityInfo and activityInfo.shortName;

		info.entryType = "option"
		info.index = k
		info.text = shortName
		info.value = activityID

		info.func = function()
			LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.EntryCreation.selectedFilters), LFGListFrame.EntryCreation.selectedCategory, nil, activityID)
			--frame.DifficultyDropDown:SelectFrame(entryFrame)
		end

		entryFrame = frame.DifficultyDropDown:CreateEntryFrame(info)
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

local frameIndex = 0

local function createInviteFrame(queueData)
	frameIndex = frameIndex + 1
	--local listInviteFrame = miog.createBasicFrame("persistent", "BackdropTemplate", miog.ipDialog.Container, miog.ipDialog.fixedWidth, 40)
	local inviteFrame = miog.inviteBox.framePool:Acquire()
	inviteFrame:SetSize(miog.inviteBox:GetWidth(), 40)
	inviteFrame.layoutIndex = 1
	inviteFrame.Title:SetText("YOYOYOY")
	miog.createFrameBorder(inviteFrame, 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGB())
	inviteFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	inviteFrame.Icon.Texture:SetTexture(queueData[20])
	inviteFrame.Title:SetText(queueData[11])
	inviteFrame.Activity:SetText(queueData[2])

	inviteFrame.Decline:SetMouseClickEnabled(true)
	inviteFrame.Decline:RegisterForClicks("LeftButtonDown")

	inviteFrame.Accept:SetMouseClickEnabled(true)
	inviteFrame.Accept:RegisterForClicks("LeftButtonDown")

	--inviteFrame.Activity:SetText(queueData[])

	--[===[local primaryIndicator = miog.createFleetingFontString(listInviteFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, listInviteFrame)
	primaryIndicator:SetWidth(miog.ipDialog.container.fixedWidth * 0.11)
	primaryIndicator:SetPoint("LEFT", titleFrame, "RIGHT", 5, 0)
	primaryIndicator:SetJustifyH("CENTER")
	primaryIndicator:SetText(0)
	listInviteFrame.primaryIndicator = primaryIndicator

	local secondaryIndicator = miog.createFleetingFontString(listInviteFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, listInviteFrame)
	secondaryIndicator:SetWidth(miog.ipDialog.container.fixedWidth * 0.11)
	secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 1, 0)
	secondaryIndicator:SetJustifyH("CENTER")
	secondaryIndicator:SetText(0)
	listInviteFrame.secondaryIndicator = secondaryIndicator

	local ageFrame = miog.createFleetingFontString(listInviteFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, listInviteFrame)
	ageFrame:SetPoint("LEFT", secondaryIndicator, "RIGHT", 1, 0)
	ageFrame:SetWidth(miog.ipDialog.container.fixedWidth * 0.24)
	ageFrame:SetJustifyH("CENTER")
	ageFrame:SetTextColor(CreateColorFromHexString(miog.CLRSCC.purple):GetRGBA())
	ageFrame:SetText("[0:01:30]")
	listInviteFrame.ageFrame = ageFrame

	local friendFrame = miog.createFleetingTexture(listInviteFrame.texturePool, miog.C.STANDARD_FILE_PATH .. "/infoIcons/friend.png", listInviteFrame, 20 - 3, 20 - 3)
	friendFrame:SetPoint("LEFT", ageFrame, "RIGHT", 3, 1)
	friendFrame:SetDrawLayer("ARTWORK")
	friendFrame:SetMouseMotionEnabled(true)
	friendFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(friendFrame, "ANCHOR_CURSOR")
		GameTooltip:SetText("A friend is in this group")
		GameTooltip:Show()

	end)
	friendFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)
	listInviteFrame.friendFrame = friendFrame

	local dividerFirstSecondFrame = miog.createFleetingTexture(listInviteFrame.texturePool, nil, listInviteFrame, miog.ipDialog.container.fixedWidth - iconFrameBorder:GetWidth(), 2, "BORDER")
	dividerFirstSecondFrame:SetAtlas("UI-LFG-DividerLine")
	dividerFirstSecondFrame:SetPoint("LEFT", iconFrame, "RIGHT", 0, 0)
	
	local resultMemberPanel = miog.createFleetingFrame(listInviteFrame.framePool, "BackdropTemplate", listInviteFrame)
	resultMemberPanel:SetHeight(20 - 4)
	resultMemberPanel:SetWidth(100)
	resultMemberPanel:SetPoint("LEFT", difficultyZoneFrame, "RIGHT", 5, 2)
	resultMemberPanel:Hide()
	resultMemberPanel.memberFrames = {}
	listInviteFrame.memberPanel = resultMemberPanel

	for i = 1, 5, 1 do
		local resultMemberFrame = miog.createFleetingTexture(listInviteFrame.texturePool, nil, resultMemberPanel, 13, 13)
		resultMemberFrame:SetPoint("LEFT", resultMemberPanel.memberFrames[i-1] or resultMemberPanel, resultMemberPanel.memberFrames[i-1] and "RIGHT" or "LEFT", 14, 0)
		resultMemberFrame:SetDrawLayer("OVERLAY", -4)
		resultMemberPanel.memberFrames[i] = resultMemberFrame

		resultMemberFrame.border = miog.createFleetingTexture(listInviteFrame.texturePool, nil, resultMemberPanel)
		resultMemberFrame.border:SetDrawLayer("OVERLAY", -5)
		resultMemberFrame.border:SetPoint("TOPLEFT", resultMemberFrame, "TOPLEFT", -2, 2)
		resultMemberFrame.border:SetPoint("BOTTOMRIGHT", resultMemberFrame, "BOTTOMRIGHT", 2, -2)
	end

	local resultMemberComp = miog.createFleetingFontString(listInviteFrame.fontStringPool, 12, listInviteFrame)
	resultMemberComp:SetPoint("LEFT", difficultyZoneFrame, "RIGHT", 5, 0)
	listInviteFrame.resultMemberComp = resultMemberComp
	
	
	local resultBossPanel = miog.createFleetingFrame(listInviteFrame.framePool, "ResizeLayoutFrame, BackdropTemplate", listInviteFrame)
	resultBossPanel.fixedHeight = 20 - 4
	resultBossPanel:SetPoint("BOTTOMRIGHT", acceptInviteButton, "BOTTOMLEFT", 0, 1)
	resultBossPanel:Hide()
	resultBossPanel.bossFrames = {}
	listInviteFrame.bossPanel = resultBossPanel

	for i = 1, miog.F.MOST_BOSSES, 1 do
		local resultBossFrame = miog.createFleetingTexture(listInviteFrame.texturePool, nil, resultBossPanel, 12, 12)
		resultBossFrame:SetPoint("RIGHT", resultBossPanel.bossFrames[i-1] or resultBossPanel, resultBossPanel.bossFrames[i-1] and "LEFT" or "RIGHT", -2, 0)
		resultBossFrame:SetDrawLayer("ARTWORK")
		resultBossPanel.bossFrames[i] = resultBossFrame
	end

	resultBossPanel:MarkDirty()

	local leaderCrown = miog.createFleetingTexture(listInviteFrame.texturePool, miog.C.STANDARD_FILE_PATH .. "/infoIcons/leaderIcon.png", resultMemberPanel, 14, 14)
	leaderCrown:SetDrawLayer("OVERLAY", -3)
	leaderCrown:Hide()
	resultMemberPanel.leaderCrown = leaderCrown
	
	
	]===]

	miog.inviteBox.Container:MarkDirty()

	return inviteFrame
end

miog.createInviteFrame = createInviteFrame

local currentInvites = {}

miog.currentInvites = currentInvites

local function updateInviteFrame(resultID, newStatus)
	local resultFrame = currentInvites[resultID]

	if(resultFrame and newStatus and newStatus ~= "invited") then
		resultFrame.statusFrame:Show()
		resultFrame.statusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[newStatus].statusString, miog.APPLICANT_STATUS_INFO[newStatus].color))
		--resultFrame:SetScript("OnMouseDown", nil)

		resultFrame.ageFrame.ageTicker:Cancel()

		--miog.createFrameBorder(searchResultSystem.resultFrames[resultID], 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGB())
		resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		resultFrame.background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

		if(newStatus == "declined" or newStatus == "declined_full" or newStatus == "declined_delisted" or newStatus == "timedout") then
			resultFrame.acceptInviteButton:Hide()
			--resultFrame.declineInviteButton:Hide()

			--miog.hideActiveInviteFrame(resultID)
		end
	end
end

miog.updateInviteFrame = updateInviteFrame

local function hideActiveInviteFrame(resultID)
	if(currentInvites[resultID]) then
		currentInvites[resultID].fontStringPool:ReleaseAll()
		currentInvites[resultID].texturePool:ReleaseAll()
		currentInvites[resultID].framePool:ReleaseAll()
		miog.persistentFramePool:Release(currentInvites[resultID])

		currentInvites[resultID] = nil
		
		miog.ipDialog.container:MarkDirty()
		---@diagnostic disable-next-line: undefined-field
		miog.ipDialog:MarkDirty()

		miog.ipDialog.activeFrames = miog.ipDialog.activeFrames - 1

		if(miog.ipDialog.activeFrames == 0) then
			miog.ipDialog:Hide()

		end
	end

end

miog.hideActiveInviteFrame = hideActiveInviteFrame

miog.showUpgradedInvitePendingDialog = function(resultID)
	local currentFrame

	if(not currentInvites[resultID]) then
		currentFrame = createInviteFrame()
		miog.ipDialog.activeFrames = miog.ipDialog.activeFrames + 1

		PlaySound(SOUNDKIT.READY_CHECK)

	else
		currentFrame = currentInvites[resultID]
	
	end
	
	FlashClientIcon()

	local searchResultData = C_LFGList.GetSearchResultInfo(resultID)
	local activityInfo = C_LFGList.GetActivityInfoTable(searchResultData.activityID)
	local mapID = miog.ACTIVITY_INFO[searchResultData.activityID] and miog.ACTIVITY_INFO[searchResultData.activityID].mapID or 0
	local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)

	currentFrame:SetScript("OnEnter", function()
		miog.createResultTooltip(searchResultData.searchResultID, currentFrame, searchResultData.autoAccept)

	end)

	if(not currentInvites[resultID]) then
		currentFrame.acceptInviteButton:SetScript("OnClick", function(self, button)
			miog.handleInvite(self, button, resultID, true)
			hideActiveInviteFrame(resultID)
			
		end)

		currentFrame.declineInviteButton:SetScript("OnClick", function(self, button)
			miog.handleInvite(self, button, resultID, false)
			hideActiveInviteFrame(resultID)

		end)

		local _, _, _, appDuration = C_LFGList.GetApplicationInfo(resultID)
		appDuration = appDuration > 0 and appDuration or 89

		currentFrame.ageFrame.ageTicker = C_Timer.NewTicker(1, function()
			appDuration = appDuration - 1
			currentFrame.ageFrame:SetText("[" .. miog.secondsToClock(appDuration) .. "]")

		end)
	end

	currentFrame.iconFrame:SetTexture(miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID][#miog.MAP_INFO[mapID]] and miog.MAP_INFO[mapID][#miog.MAP_INFO[mapID]].icon or nil)
	currentFrame.iconFrame:SetScript("OnMouseDown", function()

		--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
		EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

	end)
	local color = miog.ACTIVITY_INFO[searchResultData.activityID] and
	(activityInfo.isPvpActivity and miog.BRACKETS[miog.ACTIVITY_INFO[searchResultData.activityID].difficultyID].miogColors
	or miog.DIFFICULTY[miog.ACTIVITY_INFO[searchResultData.activityID].difficultyID].miogColors) or {r = 1, g = 1, b = 1}
	currentFrame.iconFrame.border:SetColorTexture(color.r, color.g, color.b, 1)

	currentFrame.titleFrame:SetText(searchResultData.name)
	currentFrame.friendFrame:SetShown((searchResultData.numBNetFriends > 0 or searchResultData.numCharFriends > 0 or searchResultData.numGuildMates > 0) and true or false)

	currentFrame.difficultyZoneFrame:SetText(
		(miog.ACTIVITY_INFO[searchResultData.activityID] and miog.ACTIVITY_INFO[searchResultData.activityID].difficultyID ~= 0 and miog.DIFFICULTY_ID_INFO[miog.ACTIVITY_INFO[searchResultData.activityID].difficultyID].shortName .. " - " or "") ..
		(miog.ACTIVITY_INFO[searchResultData.activityID].shortName or activityInfo.fullName))

	currentFrame.primaryIndicator:SetText(nil)
	currentFrame.secondaryIndicator:SetText(nil)

	local appCategory = activityInfo.categoryID
	local primarySortAttribute, secondarySortAttribute

	local nameTable

	if(searchResultData.leaderName) then
		nameTable = miog.simpleSplit(searchResultData.leaderName, "-")
	end

	if(nameTable and not nameTable[2]) then
		nameTable[2] = GetNormalizedRealmName()

		searchResultData.leaderName = nameTable[1] .. "-" .. nameTable[2]

	end

	if(appCategory ~= 3 and appCategory ~= 4 and appCategory ~= 7 and appCategory ~= 8 and appCategory ~= 9) then
		if(searchResultData.leaderOverallDungeonScore > 0) then
			local reqScore = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or 0
			local highestKeyForDungeon

			if(reqScore > searchResultData.leaderOverallDungeonScore) then
				currentFrame.primaryIndicator:SetText(wticc(tostring(searchResultData.leaderOverallDungeonScore), miog.CLRSCC["red"]))

			else
				currentFrame.primaryIndicator:SetText(wticc(tostring(searchResultData.leaderOverallDungeonScore), miog.createCustomColorForScore(searchResultData.leaderOverallDungeonScore):GenerateHexColor()))

			end

			if(searchResultData.leaderDungeonScoreInfo) then
				if(searchResultData.leaderDungeonScoreInfo.finishedSuccess == true) then
					highestKeyForDungeon = wticc(tostring(searchResultData.leaderDungeonScoreInfo.bestRunLevel), miog.C.GREEN_COLOR)

				elseif(searchResultData.leaderDungeonScoreInfo.finishedSuccess == false) then
					highestKeyForDungeon = wticc(tostring(searchResultData.leaderDungeonScoreInfo.bestRunLevel), miog.CLRSCC["red"])

				end
			else
				highestKeyForDungeon = wticc(tostring(0), miog.CLRSCC["red"])

			end

			currentFrame.secondaryIndicator:SetText(highestKeyForDungeon)
		else
			local difficulty = miog.DIFFICULTY[-1] -- NO DATA
			currentFrame.primaryIndicator:SetText(wticc("0", difficulty.color))
			currentFrame.secondaryIndicator:SetText(wticc("0", difficulty.color))

		end
	elseif(appCategory == 3) then
		local raidData = miog.getRaidSortData(searchResultData.leaderName)

		if(raidData) then
			
			primarySortAttribute = wticc(raidData[1].parsedString, raidData[1].ordinal == 1 and miog.DIFFICULTY[raidData[1].difficulty].color or miog.DIFFICULTY[raidData[1].difficulty].desaturated)
			secondarySortAttribute = wticc(raidData[2].parsedString, raidData[2].ordinal == 1 and miog.DIFFICULTY[raidData[2].difficulty].color or miog.DIFFICULTY[raidData[2].difficulty].desaturated)

		else
			primarySortAttribute = 0
			secondarySortAttribute = 0
		
		end

		currentFrame.primaryIndicator:SetText(primarySortAttribute)
		currentFrame.secondaryIndicator:SetText(secondarySortAttribute)

	elseif(appCategory == 4 or appCategory == 7 or appCategory == 8 or appCategory == 9) then
		if(searchResultData.leaderPvpRatingInfo) then
			currentFrame.primaryIndicator:SetText(wticc(tostring(searchResultData.leaderPvpRatingInfo.rating), miog.createCustomColorForScore(searchResultData.leaderPvpRatingInfo.rating):GenerateHexColor()))

			local tierResult = miog.simpleSplit(PVPUtil.GetTierName(searchResultData.leaderPvpRatingInfo.tier), " ")
			currentFrame.secondaryIndicator:SetText(strsub(tierResult[1], 0, tierResult[2] and 2 or 4) .. ((tierResult[2] and "" .. tierResult[2]) or ""))
			
		else
			currentFrame.primaryIndicator:SetText(0)
			currentFrame.secondaryIndicator:SetText("Unra")

		end
	end

	local orderedList = {}

	local roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
	}

	for i = 1, searchResultData.numMembers, 1 do
		local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(searchResultData.searchResultID, i)

		orderedList[i] = {leader = i == 1 and true or false, role = role, class = class, specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]}

		if(role) then
			roleCount[role] = roleCount[role] + 1

		end
	end

	local memberPanel = currentFrame.memberPanel
	local bossPanel = currentFrame.bossPanel

	if(appCategory == 3 or appCategory == 9) then
		memberPanel:Hide()

		currentFrame.resultMemberComp:Show()
		currentFrame.resultMemberComp:SetText(roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"])

		if(miog.MAP_INFO[mapID]) then
			bossPanel:Show()

			local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(resultID)
			local encountersDefeated = {}

			if(encounterInfo) then
				for _, v in pairs(encounterInfo) do
					encountersDefeated[v] = true
				end
			end

			local numOfBosses = #miog.MAP_INFO[mapID] - 1

			for i = 1, miog.F.MOST_BOSSES, 1 do
				local currentRaidInfo = miog.MAP_INFO[mapID][numOfBosses - (i - 1)]
				if(currentRaidInfo) then
					bossPanel.bossFrames[i]:SetTexture(currentRaidInfo.icon)

					if(encountersDefeated[currentRaidInfo.name]) then
						bossPanel.bossFrames[i]:SetDesaturated(true)
						
					else
						bossPanel.bossFrames[i]:SetDesaturated(false)

					end

					bossPanel.bossFrames[i]:Show()

				else
					bossPanel.bossFrames[i]:Hide()
				
				end
			end
		end

	elseif(appCategory ~= 0) then
		-- BRACKET 1 == 3v3, 0 == 2v2
		currentFrame.resultMemberComp:Hide()
		bossPanel:Hide()

		local groupLimit = (appCategory == 4 or appCategory == 7) and (searchResultData.leaderPvpRatingInfo.bracket == 0 and 2 or searchResultData.leaderPvpRatingInfo.bracket == 1 and 3 or 5) or 5
		local groupSize = #orderedList

		if(roleCount["TANK"] == 0 and groupSize < groupLimit) then
			orderedList[groupSize + 1] = {class = "DUMMY", role = "TANK", specID = 20}
			roleCount["TANK"] = roleCount["TANK"] + 1
			groupSize = groupSize + 1
		end

		if(roleCount["HEALER"] == 0 and groupSize < groupLimit) then
			orderedList[groupSize + 1] = {class = "DUMMY", role = "HEALER", specID = 20}
			roleCount["HEALER"] = roleCount["HEALER"] + 1
			groupSize = groupSize + 1

		end

		for _ = 1, 3 - roleCount["DAMAGER"], 1 do
			if(roleCount["DAMAGER"] < 3 and groupSize < groupLimit) then
				orderedList[groupSize + 1] = {class = "DUMMY", role = "DAMAGER", specID = 20}
				roleCount["DAMAGER"] = roleCount["DAMAGER"] + 1
				groupSize = groupSize + 1

			end
		end

		table.sort(orderedList, function(k1, k2)
			if(k1.role ~= k2.role) then
				return k1.role > k2.role

			elseif(k1.spec ~= k2.spec) then
				return k1.spec > k2.spec

			else
				return k1.class > k2.class

			end

		end)
		
		for i = 1, groupLimit, 1 do
			local currentMemberFrame = memberPanel.memberFrames[i]

			if(currentMemberFrame) then
				currentMemberFrame:SetTexture(miog.SPECIALIZATIONS[orderedList[i].specID] and miog.SPECIALIZATIONS[orderedList[i].specID].squaredIcon)

				if(orderedList[i].class ~= "DUMMY") then
					currentMemberFrame.border:SetColorTexture(C_ClassColor.GetClassColor(orderedList[i].class):GetRGBA())

				else
					currentMemberFrame.border:SetColorTexture(0, 0, 0, 0)
				
				end

				if(orderedList[i].leader) then
					memberPanel.leaderCrown:SetPoint("CENTER", currentMemberFrame, "TOP")
					memberPanel.leaderCrown:Show()

					currentMemberFrame:SetMouseMotionEnabled(true)
					currentMemberFrame:SetScript("OnEnter", function()
						GameTooltip:SetOwner(currentMemberFrame, "ANCHOR_CURSOR")
						GameTooltip:AddLine(format(_G["LFG_LIST_TOOLTIP_LEADER"], searchResultData.leaderName))
						GameTooltip:Show()

					end)
					currentMemberFrame:SetScript("OnLeave", function()
						GameTooltip:Hide()

					end)
				else
					currentMemberFrame:SetScript("OnEnter", nil)
				
				end

			else
				memberPanel.memberFrames[i]:Hide()
			
			end
		end
		
		memberPanel:Show()

	end

	currentInvites[resultID] = currentFrame
	currentFrame:Show()

	--miog.ipDialog:SetPoint("TOPLEFT", dialogBox, "TOPLEFT")
	miog.ipDialog.container:MarkDirty()
	---@diagnostic disable-next-line: undefined-field
	miog.ipDialog:MarkDirty()
	miog.ipDialog:SetShown(true)
	--StaticPopupSpecial_Show(miog.ipDialog)
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
			miog.applicationViewer:Hide()
			miog.searchPanel:Hide()
			miog.entryCreation:Hide()
			miog.Plugin:Hide()

			if(addonName == "MythicIOGrabber") then
				miog.MainTab.CategoryPanel:Show()
				miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Show()
				miog.searchPanel.PanelFilters:Hide()
			end
	
		end
	end)
end