local addonName, miog = ...
local wticc = WrapTextInColorCode

local function selectActivity(activityID)
	if(activityID) then
		LFGListFrame.EntryCreation.selectedActivity = activityID
	end

	local frame = miog.entryCreation
	local activityDropDown = miog.entryCreation.ActivityDropDown
	local difficultyDropDown = miog.entryCreation.DifficultyDropDown
	local playstyleDropDown = miog.entryCreation.PlaystyleDropDown

	if(activityID) then
		if(activityDropDown:SelectFirstFrameWithValue(activityID) == false) then
			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
			
			activityDropDown.CheckedValue.Name:SetText(C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID))
			activityDropDown.CheckedValue.value = activityID

			difficultyDropDown:SelectFirstFrameWithValue(activityID)

		else
			if(not miog.entryCreation.isActivityHidden) then
				difficultyDropDown:SelectFrameAtIndex(1)

			else
				difficultyDropDown.CheckedValue.value = nil
			
			end

		end

		--activityDropDown.CheckedValue.Background:SetTexture(miog.ACTIVITY_ID_INFO[activityID].background)
		
	elseif(C_LFGList.HasActiveEntryInfo()) then
		local entryData = C_LFGList.GetActiveEntryInfo()
		local activityInfo = C_LFGList.GetActivityInfoTable(entryData.activityID)

		frame.PrivateGroup:SetChecked(entryData.privateGroup)
		frame.Rating:SetText(entryData.requiredDungeonScore or entryData.requiredPvpRating or "")
		frame.ItemLevel:SetText(entryData.requiredItemLevel or entryData.requiredHonorLevel or "")
		frame.VoiceChat:SetText(entryData.voiceChat)

		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, activityInfo.filters), activityInfo.categoryID, activityInfo.groupFinderActivityGroupID, entryData.activityID)
		
		activityDropDown:SelectFirstFrameWithValue(entryData.activityID)
		difficultyDropDown:SelectFirstFrameWithValue(entryData.activityID)
		playstyleDropDown:SelectFrameAtLayoutIndex(1)

	else
		frame.PrivateGroup:SetChecked(false)
		frame.Rating:SetText("")
		frame.ItemLevel:SetText("")
		frame.VoiceChat:SetText("")

		C_LFGList.ClearCreationTextFields()
	
		activityDropDown:SelectFrameAtLayoutIndex(1)
		difficultyDropDown:SelectFrameAtLayoutIndex(1)
		playstyleDropDown:SelectFrameAtLayoutIndex(1)

	end
end

local function setUpRatingLevels()
	local score = C_ChallengeMode.GetOverallDungeonScore()

	local lowest = miog.round2(score, 50)

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
			info.func = function() miog.entryCreation.Rating:SetText(v) end

			miog.entryCreation.Rating.DropDown:CreateEntryFrame(info)
		end
		
	end
end

local function setUpItemLevels()
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
	local itemLevelTable = {}

	local lowest = miog.round2(avgItemLevelEquipped, 5)

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
			info.func = function() miog.entryCreation.ItemLevel:SetText(v) end

			miog.entryCreation.ItemLevel.DropDown:CreateEntryFrame(info)
		end

	end
end

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

	local info = {}

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
		local activityID = v;
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
		local shortName = activityInfo and activityInfo.shortName;

		info.entryType = "option"
		info.index = k
		info.text = shortName
		info.value = activityID

		info.func = function()
			LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), LFGListFrame.EntryCreation.selectedCategory, LFGListFrame.EntryCreation.selectedGroup, activityID)
			selectActivity(activityID)
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

hooksecurefunc("LFGListEntryCreation_Select", function(_, filters, categoryID, groupID, activityID)
	miog.setUpEntryCreation()
end)

miog.setUpDifficultyDropDown = setUpDifficultyDropDown

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

	activityDropDown.CheckedValue.Background:SetTexture(miog.retrieveBackgroundImageFromGroupActivityID(activityInfo.groupFinderActivityGroupID), "background")

	miog.entryCreation.ActivityDropDown.List:MarkDirty()
	miog.entryCreation.ActivityDropDown:MarkDirty()
end

miog.setUpEntryCreation = setUpEntryCreation

local function gatherGroupsAndActivitiesForCategory(categoryID)
	local activityDropDown = miog.entryCreation.ActivityDropDown
	activityDropDown:ResetDropDown()

	local firstGroupID, firstActivityID

	local listTable = {}
	local lfgTable = {}
	local mythicPlusTable = {}
	local pvpTable = {}
	local expansionTable = {}

	local borFilters = bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters)

	if(categoryID < 4 or categoryID == 6) then
		local groups = C_LFGList.GetAvailableActivityGroups(categoryID, borFilters)

		local lastHighestIndex = 0

		--table.sort(groups, function(k1, k2)
		--	return k1 < k2
		--end)

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(categoryID, v)
			local activityID = activities[#activities]

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

			local currentMPlus = nil
			local info = {}

			if(categoryID == 2) then
				for activityIndex, difficultyActivityID in ipairs(activities) do
					local difficultyActivityInfo = C_LFGList.GetActivityInfoTable(difficultyActivityID)

					if(difficultyActivityInfo.isMythicPlusActivity) then
						info.sort = "mplus"

					end
				end
			else
				info.parentIndex = nil
			
			end

			info.entryType = "option"
			info.index = activityInfo.groupFinderActivityGroupID
			info.text = C_LFGList.GetActivityGroupInfo(v)
			info.value = activityID
			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
				selectActivity(activityID)
				
			end
			info.icon = miog.ACTIVITY_ID_INFO[activityID].icon
			info.mapID = miog.ACTIVITY_ID_INFO[activityID][9]
			
			--[[local mapID = activityInfo.groupFinderActivityGroupID ~= 0 and miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].mapID

			if(mapID) then
				if(miog.MAP_INFO[mapID]) then
					info.mapID = mapID
					info.icon = miog.MAP_INFO[mapID].icon

				else
					local journalID = C_EncounterJournal.GetInstanceForGameMap(mapID)
					local _, _, _, buttonImage1, _, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, _ = EJ_GetInstanceInfo(journalID)
					
					info.icon = buttonImage2
				end
			end]]


			if(info.sort == "mplus") then
				mythicPlusTable[#mythicPlusTable+1] = info

			else
				lfgTable[#lfgTable+1] = info
			
			end
			--local entryFrame = activityDropDown:CreateEntryFrame(info)

			--if(categoryID == 2) then
				--lastHighestIndex = info.index < lastHighestIndex and info.index or lastHighestIndex

				--if(lastHighestIndex == info.index) then
				--	firstGroupID = groups[1]
				--	firstActivityID = currentMPlus

				--end
				
			--else
				if(k == 1) then
					firstGroupID = groups[1]
					firstActivityID = activityID
				end

			--end
		end

		if(categoryID == 3 and LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
			local activities = C_LFGList.GetAvailableActivities(categoryID, 0, 6)

			for activityIndex, activityID in ipairs(activities) do
				if(miog.MAP_INFO[miog.ACTIVITY_ID_INFO[activityID][9]]) then
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
					local info = {}

					info.entryType = "option"
					info.index = #groups + activityIndex
					info.text = activityInfo.fullName
					info.value = activityID
					info.func = function()
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, 0, activityID)
						selectActivity(activityID)
						
					end

					info.mapID = miog.ACTIVITY_ID_INFO[activityID][9]
					print(info.mapID)
					info.icon = miog.ACTIVITY_ID_INFO[activityID].icon

					--[[local mapID = miog.ACTIVITY_ID_INFO[activityID].mapID

					if(mapID) then
						if(miog.MAP_INFO[mapID]) then
							info.mapID = mapID

						else
							local journalID = C_EncounterJournal.GetInstanceForGameMap(mapID)
							local _, _, _, buttonImage1, _, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, _ = EJ_GetInstanceInfo(journalID)
							
							info.icon = buttonImage2
						end
					end]]

					lfgTable[#lfgTable+1] = info
				else
					print("NO DATA FOR", miog.ACTIVITY_ID_INFO[activityID][9])
				
				end
			end
		end
	else
		local pvpActivities = C_LFGList.GetAvailableActivities(categoryID, 0, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters));
		firstGroupID = 0
		firstActivityID = pvpActivities[1]
	
		for _, v in ipairs(pvpActivities) do
			local activityID = v

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

			local info = {}
			info.entryType = "option"
			--info.index = activityInfo.groupFinderActivityGroupID
			info.text = activityInfo.fullName
			info.value = activityID
			info.func = function()
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, 0, activityID)
				selectActivity(activityID)
			end
			
			local mapID = miog.retrieveMapIDFromGFID(activityInfo.groupFinderActivityGroupID)

			if(mapID) then
				info.icon = miog.MAP_INFO[mapID].icon
			end

			pvpTable[#pvpTable+1] = info
			--local entryFrame = activityDropDown:CreateEntryFrame(info)
		end
	end
	
	if(categoryID == 2) then
		--activityDropDown:CreateSeparator(8)
		--activityDropDown:CreateSeparator(9999)

		for i = 0, GetNumExpansions() - 1, 1 do
			local expansionInfo = GetExpansionDisplayInfo(i)

			local info = {}
			info.entryType = "arrow"
			info.index = i + 10000
			info.text = miog.APPLICATION_VIEWER_BACKGROUNDS[i + 2][1]
			info.icon = expansionInfo and expansionInfo.logo

			expansionTable[#expansionTable+1] = info
			--local expansionFrame = activityDropDown:CreateEntryFrame(info)

			local groups = C_LFGList.GetAvailableActivityGroups(categoryID)

			table.sort(groups, function(k1, k2)
				local k1name = C_LFGList.GetActivityGroupInfo(k1)
				local k2name = C_LFGList.GetActivityGroupInfo(k2)
				return k1name < k2name
			end)

			for k, v in ipairs(groups) do
				local activities = C_LFGList.GetAvailableActivities(categoryID, v)
				local activityID = activities[#activities]

				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
				
				local mapID = miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].mapID

				if(mapID) then
					if(miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].expansionLevel == i) then
						info = {}
						info.icon = miog.MAP_INFO[mapID].icon

						info.parentIndex = i + 10000
						info.entryType = "option"
						info.mapID = mapID
						--info.index = k
						info.text = C_LFGList.GetActivityGroupInfo(v)
						info.value = activityID
						info.func = function()
							LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, v, activityID)
							selectActivity(activityID)
							
						end


						expansionTable[#expansionTable+1] = info
						--local entryFrame = activityDropDown:CreateEntryFrame(info)
					else
						--print("EXP LEVEL WRONG FOR ", C_LFGList.GetActivityGroupInfo(v), miog.MAP_INFO[mapID].expansionLevel, i)
					end
				else
					print("NO MAP ID FOR ", activityInfo.groupFinderActivityGroupID, C_LFGList.GetActivityGroupInfo(v))
				
				end
			end
			
			local activities = C_LFGList.GetAvailableActivities(categoryID, 0, 6)

			for activityIndex, activityID in ipairs(activities) do
				local mapID = miog.ACTIVITY_ID_INFO[activityID][9]
				if(miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].expansionLevel == i) then
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
					info = {}

					info.entryType = "option"
					info.parentIndex = i + 10000
					info.text = activityInfo.shortName
					info.value = activityID
					info.func = function()
						LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, 0, activityID)
						selectActivity(activityID)
						
					end
					info.icon = miog.ACTIVITY_ID_INFO[activityID].icon

					--[[local mapID = miog.ACTIVITY_ID_INFO[activityID].mapID

					if(mapID) then
						if(miog.MAP_INFO[mapID]) then
							info.mapID = mapID

						else
							local journalID = C_EncounterJournal.GetInstanceForGameMap(mapID)
							local _, _, _, buttonImage1, _, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, _ = EJ_GetInstanceInfo(journalID)
							
							info.icon = buttonImage2
						end
					end]]

					expansionTable[#expansionTable+1] = info				
				end
			end

		end
	end
	

	local info = {}
	info.entryType = "option"
	info.index = 100000
	info.text = "More..."
	info.func = function()
		LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, categoryID, nil, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters))
	end
	--local moreFrame = activityDropDown:CreateEntryFrame(info)
	

	listTable[#listTable+1] = info
	local mplusOffset = 0

	if(categoryID == 2) then
		activityDropDown:CreateTextLine(-1, nil, "Seasonal Mythic+ Dungeons")
		
		table.sort(mythicPlusTable, function(k1, k2)
			return k1.text < k2.text
		end)

		for k, v in ipairs(mythicPlusTable) do
			v.index = k
			activityDropDown:CreateEntryFrame(v)

			mplusOffset = mplusOffset + 1
		end

		activityDropDown:CreateSeparator(9)
		mplusOffset = mplusOffset + 1
	end

	if(categoryID == 2 or categoryID == 3) then
		table.sort(lfgTable, function(k1, k2)
			--local newIndex = string.sub(k1.text, 1, 1) > string.sub(k2.text, 1, 1)
			if(categoryID == 3 and k1.mapID and k2.mapID) then
				if(miog.MAP_INFO[k1.mapID].expansionLevel == miog.MAP_INFO[k2.mapID].expansionLevel) then
					return k1.index < k2.index
					
				else
					return miog.MAP_INFO[k1.mapID].expansionLevel < miog.MAP_INFO[k2.mapID].expansionLevel
				
				end

			else
				return k1.text < k2.text

			end
		end)
	end

	local lastExpansion = nil
	local offset = 0

	for k, v in ipairs(lfgTable) do
		local currentIndex = mplusOffset + offset + k

		if(categoryID == 3 and LFGListFrame.CategorySelection.selectedFilters ~= 1 and v.mapID and lastExpansion ~= miog.MAP_INFO[v.mapID].expansionLevel) then
			activityDropDown:CreateTextLine(currentIndex, nil, miog.APPLICATION_VIEWER_BACKGROUNDS[miog.MAP_INFO[v.mapID].expansionLevel + 2][1])
			lastExpansion = miog.MAP_INFO[v.mapID].expansionLevel
			offset = offset + 1
			currentIndex = mplusOffset + offset + k
		end

		v.index = currentIndex

		activityDropDown:CreateEntryFrame(v)

	end

	for k, v in ipairs(pvpTable) do
		activityDropDown:CreateEntryFrame(v)

	end
	
	activityDropDown:CreateSeparator(9999)

	for k, v in ipairs(expansionTable) do
		activityDropDown:CreateEntryFrame(v)

	end

	for k, v in ipairs(listTable) do
		activityDropDown:CreateEntryFrame(v)

	end

	LFGListEntryCreation_Select(LFGListFrame.EntryCreation, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters), categoryID, firstGroupID, firstActivityID)
end

function LFGListEntryCreationActivityFinder_Accept(self)
	if ( self.selectedActivity ) then
		LFGListEntryCreation_Select(LFGListFrame.EntryCreation, nil, nil, nil, self.selectedActivity);
	end
	self:Hide();
end

hooksecurefunc("LFGListEntryCreationActivityFinder_Accept", function(self)
	if(self.selectedActivity) then
		selectActivity(self.selectedActivity)
	end
end)

local function initializeActivityDropdown(isDifferentCategory, isSeparateCategory)
	print("INIT")

	local categoryID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory or 0

	local frame = miog.entryCreation
	
	if(isDifferentCategory or isSeparateCategory) then
		local activityDropDown = frame.ActivityDropDown
		activityDropDown:ResetDropDown()

		gatherGroupsAndActivitiesForCategory(categoryID)
		selectActivity()

		miog.entryCreation.ActivityDropDown.List:MarkDirty()
		miog.entryCreation.ActivityDropDown:MarkDirty()
	end
end

miog.initializeActivityDropdown = initializeActivityDropdown

local function LFGListEntryCreation_ListGroup()
	local frame = miog.entryCreation

	local itemLevel = tonumber(frame.ItemLevel:GetText()) or 0;
	local rating = tonumber(frame.Rating:GetText()) or 0;
	local pvpRating = rating
	local mythicPlusRating = rating
	local autoAccept = false;
	local privateGroup = frame.PrivateGroup:GetChecked();
	local isCrossFaction =  frame.CrossFaction:IsShown() and not frame.CrossFaction:GetChecked();
	local selectedPlaystyle = frame.PlaystyleDropDown:IsShown() and frame.PlaystyleDropDown.CheckedValue.value or nil;
	local activityID = frame.DifficultyDropDown.CheckedValue.value or frame.ActivityDropDown.CheckedValue.value or 0

	local self = LFGListFrame.EntryCreation

	LFGListEntryCreation_ListGroupInternal(self, activityID, itemLevel, autoAccept, privateGroup, 0, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
end

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
--[===[
hooksecurefunc("LFGListEntryCreation_SetEditMode", function(self, editMode)
	--self.editMode = editMode;

	local descInstructions = nil;
	local isAccountSecured = C_LFGList.IsPlayerAuthenticatedForLFG(self:GetParent().selectedActivity);
	if (not isAccountSecured) then
		descInstructions = LFG_AUTHENTICATOR_DESCRIPTION_BOX;
	end

	if ( editMode ) then
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		assert(activeEntryInfo);

		LFGListEntryCreation_Select(self, nil, nil, nil, activeEntryInfo.activityID);

		miog.entryCreation.ActivityDropDown:Disable()
		miog.entryCreation.DifficultyDropDown:Disable()

		C_LFGList.CopyActiveEntryInfoToCreationFields();
		miog.entryCreation.Name:SetEnabled(activeEntryInfo.questID == nil and isAccountSecured);
		if ( activeEntryInfo.questID ) then
			miog.entryCreation.Description.EditBox.Instructions:SetText(LFGListUtil_GetQuestDescription(activeEntryInfo.questID));
		else
			miog.entryCreation.Description.EditBox.Instructions:SetText(descInstructions or DESCRIPTION_OF_YOUR_GROUP);
		end

		if (miog.entryCreation.ItemLevel:IsShown()) then
			miog.entryCreation.ItemLevel:SetText(activeEntryInfo.requiredItemLevel ~= 0 and activeEntryInfo.requiredItemLevel or "");
		end

		miog.entryCreation.Rating:SetText(activeEntryInfo.requiredDungeonScore or activeEntryInfo.requiredPvpRating or "" );
		miog.entryCreation.PrivateGroup:SetChecked(activeEntryInfo.privateGroup);
		miog.entryCreation.CrossFaction:SetChecked(not activeEntryInfo.isCrossFactionListing);

		--if(self.PlayStyleDropdown:IsShown()) then
			--LFGListEntryCreation_OnPlayStyleSelected(self, self.PlayStyleDropdown, activeEntryInfo.playstyle);
		--end

		miog.entryCreation.StartGroup:SetText(DONE_EDITING);
	else
		miog.entryCreation.ActivityDropDown:Enable()
		miog.entryCreation.DifficultyDropDown:Enable()
		miog.entryCreation.StartGroup:SetText(LIST_GROUP);
		miog.entryCreation.Name:SetEnabled(isAccountSecured);
		miog.entryCreation.Description.EditBox.Instructions:SetText(descInstructions or DESCRIPTION_OF_YOUR_GROUP);

		local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity);

		if(activityInfo and self.selectedCategory == GROUP_FINDER_CATEGORY_ID_DUNGEONS) then
			local activityID, groupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones
			if(activityID) then
				LFGListEntryCreation_Select(self, self.selectedFilters, self.selectedCategory, groupID, activityID);
			else
				local activityID, groupID = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true);  -- Check for a timewalking keystone.
				if(activityID) then
					LFGListEntryCreation_Select(self, self.selectedFilters, self.selectedCategory, groupID, activityID);
				end
			end
		end
	end
end)
]===]

local function createEntryCreation()
	miog.entryCreation = CreateFrame("Frame", "MythicIOGrabber_EntryCreation", miog.mainTab.Plugin, "MIOG_EntryCreation") ---@class Frame

	local frame = miog.entryCreation

	frame.selectedActivity = 0

	--local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", frame, 200, 25)
	--optionDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT")
	--UIDropDownMenu_SetWidth(optionDropdown, 160)
	--frame.ActivityDropdown = optionDropdown

	---@diagnostic disable-next-line: undefined-field
	local activityDropDown = frame.ActivityDropDown
	activityDropDown:OnLoad()

	---@diagnostic disable-next-line: undefined-field
	local difficultyDropDown = frame.DifficultyDropDown
	difficultyDropDown:OnLoad()

	---@diagnostic disable-next-line: undefined-field
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

	local startGroup = CreateFrame("Button", nil, miog.entryCreation, "UIPanelDynamicResizeButtonTemplate, LFGListMagicButtonTemplate")
	startGroup:SetSize(1, 20)
	startGroup:SetPoint("RIGHT", miog.mainTab.Plugin.FooterBar, "RIGHT")
	startGroup:SetText("Start Group")
	startGroup:FitToText()
	startGroup:RegisterForClicks("LeftButtonDown")
	startGroup:Show()
	startGroup:SetScript("OnClick", function()
		LFGListEntryCreation_ListGroup()
	end)
	miog.entryCreation.StartGroup = startGroup

	frame:HookScript("OnShow", function()
		if(C_LFGList.HasActiveEntryInfo()) then
			LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)
			startGroup:SetText("Update")

		else
			LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, false)
			startGroup:SetText("Start Group")

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

	frame.ItemLevel.DropDown.CheckedValue:Hide()
	frame.ItemLevel.DropDown.Button:Show()
	frame.ItemLevel.DropDown:OnLoad()
	setUpItemLevels()

	frame.Rating.DropDown.CheckedValue:Hide()
	frame.Rating.DropDown.Button:Show()
	frame.Rating.DropDown:OnLoad()
	setUpRatingLevels()
end

local function createApplicationViewer()
	local applicationViewer = CreateFrame("Frame", "MythicIOGrabber_ApplicationViewer", miog.mainTab.Plugin, "MIOG_ApplicationViewer") ---@class Frame
	miog.applicationViewer = applicationViewer
	miog.createFrameBorder(applicationViewer, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.TitleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.InfoPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.CreationSettings, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.ButtonPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local classPanel = applicationViewer.ClassPanel

	classPanel.classFrames = {}

	for classID, classEntry in ipairs(miog.CLASSES) do
		local classFrame = CreateFrame("Frame", nil, classPanel, "MIOG_ClassPanelClassFrameTemplate")
		classFrame.layoutIndex = classID
		classFrame:SetSize(25, 25)
		classFrame.Icon:SetTexture(classEntry.icon)
		classFrame.rightPadding = 3
		classPanel.classFrames[classID] = classFrame

		local specPanel = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", classFrame)
		specPanel:SetPoint("TOP", classFrame, "BOTTOM", 0, -5)
		specPanel.fixedHeight = 22
		specPanel.specFrames = {}
		specPanel:Hide()
		classFrame.specPanel = specPanel

		local specCounter = 1

		for _, specID in ipairs(classEntry.specs) do
			local specFrame = CreateFrame("Frame", nil, specPanel, "MIOG_ClassPanelSpecFrameTemplate")
			specFrame:SetSize(specPanel.fixedHeight, specPanel.fixedHeight)
			specFrame.Icon:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
			specFrame.layoutIndex = specCounter
			specFrame.leftPadding = 0

			specPanel.specFrames[specID] = specFrame

			specCounter = specCounter + 1
		end

		specPanel:MarkDirty()

		classFrame:SetScript("OnEnter", function()
			specPanel:Show()

		end)
		classFrame:SetScript("OnLeave", function()
			specPanel:Hide()

		end)
	end

	classPanel:MarkDirty()

	applicationViewer.TitleBar.Faction:SetTexture(2437241)
	applicationViewer.InfoPanel.Background:SetTexture(miog.ACTIVITY_BACKGROUNDS[10])

	local buttonPanel = applicationViewer.ButtonPanel

	buttonPanel.sortByCategoryButtons = {}

	for i = 1, 4, 1 do

		local sortByCategoryButton = Mixin(miog.createBasicFrame("persistent", "UIButtonTemplate", buttonPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), MultiStateButtonMixin)
		sortByCategoryButton:OnLoad()
		sortByCategoryButton:SetTexturesForBaseState("hud-MainMenuBar-arrowdown-disabled", "hud-MainMenuBar-arrowdown-disabled", "hud-MainMenuBar-arrowdown-highlight", "hud-MainMenuBar-arrowdown-disabled")
		sortByCategoryButton:SetTexturesForState1("hud-MainMenuBar-arrowdown-up", "hud-MainMenuBar-arrowdown-down", "hud-MainMenuBar-arrowdown-highlight", "hud-MainMenuBar-arrowdown-disabled")
		sortByCategoryButton:SetTexturesForState2("hud-MainMenuBar-arrowup-up", "hud-MainMenuBar-arrowup-down", "hud-MainMenuBar-arrowup-highlight", "hud-MainMenuBar-arrowup-disabled")
		sortByCategoryButton:SetStateName(0, "None")
		sortByCategoryButton:SetStateName(1, "Descending")
		sortByCategoryButton:SetStateName(2, "Ascending")
		sortByCategoryButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		sortByCategoryButton:SetState(false)
		sortByCategoryButton:SetMouseMotionEnabled(true)
		sortByCategoryButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(sortByCategoryButton, "ANCHOR_CURSOR")
			GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
			GameTooltip:Show()

		end)
		sortByCategoryButton:SetScript("OnLeave", function()
			GameTooltip:Hide()

		end)

		local sortByCategoryButtonString = miog.createBasicFontString("persistent", 9, sortByCategoryButton)
		sortByCategoryButtonString:ClearAllPoints()
		sortByCategoryButtonString:SetPoint("BOTTOMLEFT", sortByCategoryButton, "BOTTOMLEFT")

		sortByCategoryButton.FontString = sortByCategoryButtonString

		local currentCategory = ""

		if(i == 1) then
			currentCategory = "role"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 132, 0)

		elseif(i == 2) then
			currentCategory = "primary"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 164, 0)

		elseif(i == 3) then
			currentCategory = "secondary"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 203, 0)

		elseif(i == 4) then
			currentCategory = "ilvl"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 243, 0)

		end

		sortByCategoryButton:SetScript("OnClick", function(_, button)
			local activeState = sortByCategoryButton:GetActiveState()

			if(button == "LeftButton") then

				if(activeState == 0 and miog.F.CURRENTLY_ACTIVE_SORTING_METHODS < 2) then
					--TO 1
					miog.F.CURRENTLY_ACTIVE_SORTING_METHODS = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS + 1

					miog.F.SORT_METHODS[currentCategory].active = true
					miog.F.SORT_METHODS[currentCategory].currentLayer = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS

					sortByCategoryButton.FontString:SetText(miog.F.CURRENTLY_ACTIVE_SORTING_METHODS)

				elseif(activeState == 1) then
					--TO 2


				elseif(activeState == 2) then
					--RESET TO 0
					miog.F.CURRENTLY_ACTIVE_SORTING_METHODS = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS - 1

					miog.F.SORT_METHODS[currentCategory].active = false
					miog.F.SORT_METHODS[currentCategory].currentLayer = 0

					sortByCategoryButton.FontString:SetText("")

					for k, v in pairs(miog.F.SORT_METHODS) do
						if(v.currentLayer == 2) then
							v.currentLayer = 1
							buttonPanel.sortByCategoryButtons[k].FontString:SetText(1)
							miog.F.SORT_METHODS[k].currentLayer = 1
							MIOG_SavedSettings.lastActiveSortingMethods.value[k].currentLayer = 1
						end
					end
				end

				if(miog.F.CURRENTLY_ACTIVE_SORTING_METHODS < 2 or miog.F.CURRENTLY_ACTIVE_SORTING_METHODS == 2 and miog.F.SORT_METHODS[currentCategory].active == true) then
					sortByCategoryButton:AdvanceState()

					miog.F.SORT_METHODS[currentCategory].currentState = sortByCategoryButton:GetActiveState()

					MIOG_SavedSettings.lastActiveSortingMethods.value[currentCategory] = miog.F.SORT_METHODS[currentCategory]

					if(GameTooltip:GetOwner() == sortByCategoryButton) then
						GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
					end
				end

				C_LFGList.RefreshApplicants()
			elseif(button == "RightButton") then
				if(activeState == 1 or activeState == 2) then

					miog.F.CURRENTLY_ACTIVE_SORTING_METHODS = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS - 1

					miog.F.SORT_METHODS[currentCategory].active = false
					miog.F.SORT_METHODS[currentCategory].currentLayer = 0

					sortByCategoryButton.FontString:SetText("")

					for k, v in pairs(miog.F.SORT_METHODS) do
						if(v.currentLayer == 2) then
							v.currentLayer = 1
							buttonPanel.sortByCategoryButtons[k].FontString:SetText(1)
							miog.F.SORT_METHODS[k].currentLayer = 1
							MIOG_SavedSettings.lastActiveSortingMethods.value[k].currentLayer = 1
						end
					end

					sortByCategoryButton:SetState(false)

					if(miog.F.CURRENTLY_ACTIVE_SORTING_METHODS < 2 or miog.F.CURRENTLY_ACTIVE_SORTING_METHODS == 2 and miog.F.SORT_METHODS[currentCategory].active == true) then

						miog.F.SORT_METHODS[currentCategory].currentState = sortByCategoryButton:GetActiveState()

						MIOG_SavedSettings.lastActiveSortingMethods.value[currentCategory] = miog.F.SORT_METHODS[currentCategory]

						if(GameTooltip:GetOwner() == sortByCategoryButton) then
							GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
						end
					end

					C_LFGList.RefreshApplicants()
				end
			end
		end)

		buttonPanel.sortByCategoryButtons[currentCategory] = sortByCategoryButton

	end
	

	buttonPanel.ResetButton:SetScript("OnClick",
		function()
			C_LFGList.RefreshApplicants()

			miog.applicationViewer.applicantPanel:SetVerticalScroll(0)
		end
	)

	local browseGroupsButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.applicationViewer, 1, 20)
	browseGroupsButton:SetPoint("LEFT", miog.mainTab.Plugin.FooterBar.Back, "RIGHT")
	browseGroupsButton:SetText("Browse Groups")
	browseGroupsButton:FitToText()
	browseGroupsButton:RegisterForClicks("LeftButtonDown")
	browseGroupsButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		local baseFilters = LFGListFrame.baseFilters
		local searchPanel = LFGListFrame.SearchPanel
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		if(activeEntryInfo) then
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
			if(activityInfo) then
				LFGListSearchPanel_SetCategory(searchPanel, activityInfo.categoryID, activityInfo.filters, baseFilters)
				LFGListSearchPanel_DoSearch(searchPanel)
				LFGListFrame_SetActivePanel(LFGListFrame, searchPanel)
			end
		end
	end)

	miog.applicationViewer.browseGroupsButton = browseGroupsButton

	local delistButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.applicationViewer, 1, 20)
	delistButton:SetPoint("LEFT", browseGroupsButton, "RIGHT")
	delistButton:SetText("Delist")
	delistButton:FitToText()
	delistButton:RegisterForClicks("LeftButtonDown")
	delistButton:SetScript("OnClick", function()
		C_LFGList.RemoveListing()
	end)

	miog.applicationViewer.delistButton = delistButton

	local editButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.applicationViewer, 1, 20)
	editButton:SetPoint("LEFT", delistButton, "RIGHT")
	editButton:SetText("Edit")
	editButton:FitToText()
	editButton:RegisterForClicks("LeftButtonDown")
	editButton:SetScript("OnClick", function()
		local entryCreation = LFGListFrame.EntryCreation
		LFGListEntryCreation_SetEditMode(entryCreation, true)
		LFGListFrame_SetActivePanel(LFGListFrame, entryCreation)
	end)

	miog.applicationViewer.editButton = editButton

	local applicantNumberFontString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, miog.applicationViewer)
	applicantNumberFontString:SetPoint("RIGHT", miog.mainTab.Plugin.FooterBar, "RIGHT", -3, -1)
	applicantNumberFontString:SetJustifyH("CENTER")
	applicantNumberFontString:SetText(0)

	miog.applicationViewer.applicantNumberFontString = applicantNumberFontString
end

local function createSearchPanel()
	local searchPanel = CreateFrame("Frame", "MythicIOGrabber_SearchPanel", miog.mainTab.Plugin, "MIOG_SearchPanel") ---@class Frame
	miog.searchPanel = searchPanel
	miog.searchPanel.FramePanel.ScrollBar:SetPoint("TOPRIGHT", miog.searchPanel.FramePanel, "TOPRIGHT", -10, 0)
	miog.applicationViewer.FramePanel.ScrollBar:SetPoint("TOPRIGHT", miog.applicationViewer.FramePanel, "TOPRIGHT", -10, 0)

	local signupButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.searchPanel, 1, 20)
	signupButton:SetPoint("LEFT", miog.mainTab.Plugin.FooterBar.Back, "RIGHT")
	signupButton:SetText("Signup")
	signupButton:FitToText()
	signupButton:RegisterForClicks("LeftButtonDown")
	signupButton:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		LFGListApplicationDialog_Show(LFGListApplicationDialog, miog.F.CURRENT_SEARCH_RESULT_ID)

		miog.signupToGroup(LFGListFrame.SearchPanel.resultID)
	end)

	searchPanel.SignUpButton = signupButton

	local groupNumberFontString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, miog.searchPanel)
	groupNumberFontString:SetPoint("RIGHT", miog.mainTab.Plugin.FooterBar, "RIGHT", -3, -1)
	groupNumberFontString:SetJustifyH("CENTER")
	groupNumberFontString:SetText(0)

	searchPanel.groupNumberFontString = groupNumberFontString

	local searchBox = LFGListFrame.SearchPanel.SearchBox
	searchBox:ClearAllPoints()
	searchBox:SetParent(searchPanel)
	searchBox:SetSize(searchPanel.SearchBox:GetSize())
	searchBox:SetPoint(searchPanel.SearchBox:GetPoint())
	searchPanel.SearchBox = searchBox

	local autoCompleteFrame = LFGListFrame.SearchPanel.AutoCompleteFrame
	autoCompleteFrame:ClearAllPoints()
	autoCompleteFrame:SetParent(searchPanel)
	searchPanel.AutoCompleteFrame = autoCompleteFrame

	local searchingSpinner = LFGListFrame.SearchPanel.SearchingSpinner
	searchingSpinner:ClearAllPoints()
	searchingSpinner:SetParent(searchPanel)
	searchingSpinner:Hide()
	searchPanel.SearchingSpinner = searchingSpinner

	local backButton = LFGListFrame.SearchPanel.BackButton
	backButton:ClearAllPoints()
	backButton:SetParent(searchPanel)
	backButton:Hide()
	searchPanel.BackButton = backButton

	local backToGroupButton = LFGListFrame.SearchPanel.BackToGroupButton
	backToGroupButton:ClearAllPoints()
	backToGroupButton:SetParent(searchPanel)
	backToGroupButton:Hide()
	searchPanel.BackToGroupButton = backToGroupButton

	local scrollBox = LFGListFrame.SearchPanel.ScrollBox
	scrollBox:ClearAllPoints()
	scrollBox:SetParent(searchPanel)
	scrollBox:Hide()
	searchPanel.ScrollBox = scrollBox

	searchPanel.StartSearch:SetScript("OnClick", function( )
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)

		miog.searchPanel.FramePanel:SetVerticalScroll(0)
	end)

	miog.createFrameBorder(searchPanel.ButtonPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	searchPanel.ButtonPanel.sortByCategoryButtons = {}

	local firstButton = 199

	for i = 1, 3, 1 do
		local sortByCategoryButton = Mixin(miog.createBasicFrame("persistent", "UIButtonTemplate", searchPanel.ButtonPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), MultiStateButtonMixin)
		sortByCategoryButton:OnLoad()
		sortByCategoryButton:SetTexturesForBaseState("hud-MainMenuBar-arrowdown-disabled", "hud-MainMenuBar-arrowdown-disabled", "hud-MainMenuBar-arrowdown-highlight", "hud-MainMenuBar-arrowdown-disabled")
		sortByCategoryButton:SetTexturesForState1("hud-MainMenuBar-arrowdown-up", "hud-MainMenuBar-arrowdown-down", "hud-MainMenuBar-arrowdown-highlight", "hud-MainMenuBar-arrowdown-disabled")
		sortByCategoryButton:SetTexturesForState2("hud-MainMenuBar-arrowup-up", "hud-MainMenuBar-arrowup-down", "hud-MainMenuBar-arrowup-highlight", "hud-MainMenuBar-arrowup-disabled")
		sortByCategoryButton:SetStateName(0, "None")
		sortByCategoryButton:SetStateName(1, "Descending")
		sortByCategoryButton:SetStateName(2, "Ascending")
		sortByCategoryButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		sortByCategoryButton:SetState(false)
		sortByCategoryButton:SetMouseMotionEnabled(true)
		sortByCategoryButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(sortByCategoryButton, "ANCHOR_CURSOR")
			GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
			GameTooltip:Show()

		end)
		sortByCategoryButton:SetScript("OnLeave", function()
			GameTooltip:Hide()

		end)

		local sortByCategoryButtonString = miog.createBasicFontString("persistent", 9, sortByCategoryButton)
		sortByCategoryButtonString:ClearAllPoints()
		sortByCategoryButtonString:SetPoint("BOTTOMLEFT", sortByCategoryButton, "BOTTOMLEFT")

		sortByCategoryButton.FontString = sortByCategoryButtonString

		local currentCategory = ""

		if(i == 1) then
			currentCategory = "primary"
			sortByCategoryButton:SetPoint("LEFT", searchPanel.ButtonPanel, "LEFT", firstButton, 0)

		elseif(i == 2) then
			currentCategory = "secondary"
			sortByCategoryButton:SetPoint("LEFT", searchPanel.ButtonPanel, "LEFT", firstButton + 40, 0)

		elseif(i == 3) then
			currentCategory = "age"
			sortByCategoryButton:SetPoint("LEFT", searchPanel.ButtonPanel, "LEFT", firstButton + 93, 0)

		end

		sortByCategoryButton:SetScript("OnClick", function(_, button)
			local activeState = sortByCategoryButton:GetActiveState()

			if(button == "LeftButton") then

				if(activeState == 0 and MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods < 2) then
					--TO 1
					MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods = MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods + 1

					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active = true
					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentLayer = MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods

					sortByCategoryButton.FontString:SetText(MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods)

				elseif(activeState == 1) then
					--TO 2


				elseif(activeState == 2) then
					--RESET TO 0
					MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods = MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods - 1

					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active = false
					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentLayer = 0

					sortByCategoryButton.FontString:SetText("")

					for k, v in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do
						if(type(v) == "table" and v.currentLayer == 2) then
							v.currentLayer = 1
							buttonPanel.sortByCategoryButtons[k].FontString:SetText(1)
							MIOG_SavedSettings.sortMethods_SearchPanel.table[k].currentLayer = 1
						end
					end
				end

				if(MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods < 2 or MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods == 2 and MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active == true) then
					sortByCategoryButton:AdvanceState()

					--miog.F.SORT_METHODS[currentCategory].currentState = sortByCategoryButton:GetActiveState()
					--MIOG_SavedSettings.lastActiveSortingMethods.value[currentCategory] = miog.F.SORT_METHODS[currentCategory]

					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentState = sortByCategoryButton:GetActiveState()

					if(GameTooltip:GetOwner() == sortByCategoryButton) then
						GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
					end
				end

				miog.checkSearchResultListForEligibleMembers()
			elseif(button == "RightButton") then
				if(activeState == 1 or activeState == 2) then

					MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods = MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods - 1

					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active = false
					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentLayer = 0

					sortByCategoryButton.FontString:SetText("")

					for k, v in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do
						if(type(v) == "table" and v.currentLayer == 2) then
							v.currentLayer = 1
							buttonPanel.sortByCategoryButtons[k].FontString:SetText(1)
							MIOG_SavedSettings.sortMethods_SearchPanel.table[k].currentLayer = 1
						end
					end

					sortByCategoryButton:SetState(false)

					if(MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods < 2 or MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods == 2 and MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active == true) then

						--miog.F.SORT_METHODS[currentCategory].currentState = sortByCategoryButton:GetActiveState()
						--MIOG_SavedSettings.lastActiveSortingMethods.value[currentCategory] = miog.F.SORT_METHODS[currentCategory]

						MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentState = sortByCategoryButton:GetActiveState()

						if(GameTooltip:GetOwner() == sortByCategoryButton) then
							GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
						end
					end

					miog.checkSearchResultListForEligibleMembers()
				end
			end
		end)

		searchPanel.ButtonPanel.sortByCategoryButtons[currentCategory] = sortByCategoryButton

	end

	local searchPanelExtraFilter = miog.createBasicFrame("persistent", "BackdropTemplate", miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.Plugin, 220, 200)
	searchPanelExtraFilter:SetPoint("TOPLEFT", miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.Plugin, "TOPLEFT")

	miog.searchPanel.PanelFilters = searchPanelExtraFilter

	--miog.createFrameBorder(searchPanelExtraFilter, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	--searchPanelExtraFilter:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local dropdownOptionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", searchPanelExtraFilter, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	dropdownOptionButton:SetNormalAtlas("checkbox-minimal")
	dropdownOptionButton:SetPushedAtlas("checkbox-minimal")
	dropdownOptionButton:SetCheckedTexture("checkmark-minimal")
	dropdownOptionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	dropdownOptionButton:SetPoint("TOPLEFT", searchPanelExtraFilter, "TOPLEFT", 0, 0)
	dropdownOptionButton:RegisterForClicks("LeftButtonDown")
	--[[dropdownOptionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[LFGListFrame.SearchPanel.categoryID == 2 and "filterForDungeonDifficulty" or
	LFGListFrame.SearchPanel.categoryID == 3 and "filterForRaidDifficulty" or
	(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "filterForArenaBracket"] or false)]]
	dropdownOptionButton:HookScript("OnClick", function()
		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[
			LFGListFrame.SearchPanel.categoryID == 2 and "filterForDungeonDifficulty" or
			LFGListFrame.SearchPanel.categoryID == 3 and "filterForRaidDifficulty" or
			(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "filterForArenaBracket"] = dropdownOptionButton:GetChecked()

			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end
	end)

	miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton = dropdownOptionButton

	local function fillDropdown(optionDropdown, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		local currentCategoryTableValue = LFGListFrame.SearchPanel.categoryID == 2 and "dungeonDifficultyID" or LFGListFrame.SearchPanel.categoryID == 3 and "raidDifficultyID" or (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "bracketID" or nil
		if(currentCategoryTableValue) then
			local currentCategoryDescription = currentCategoryTableValue and (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and miog.BRACKETS[MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentCategoryTableValue]].description
			or miog.DIFFICULTY[MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentCategoryTableValue]].description

			UIDropDownMenu_SetText(optionDropdown, currentCategoryDescription)

		end

		info.func = function(_, arg1, _, _)
				currentCategoryTableValue = LFGListFrame.SearchPanel.categoryID == 2 and "dungeonDifficultyID" or LFGListFrame.SearchPanel.categoryID == 3 and "raidDifficultyID" or (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "bracketID" or nil
				if(currentCategoryTableValue) then
					MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentCategoryTableValue] = arg1

					local currentCategoryDescription = currentCategoryTableValue and (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and miog.BRACKETS[MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentCategoryTableValue]].description
					or miog.DIFFICULTY[MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentCategoryTableValue]].description
					
					if(dropdownOptionButton:GetChecked()) then
						miog.checkSearchResultListForEligibleMembers()

					end

					UIDropDownMenu_SetText(optionDropdown, currentCategoryDescription)

					CloseDropDownMenus()
				end
		end

		for i = (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and 2 or LFGListFrame.SearchPanel.categoryID == 3 and 3 or 4, 1, -1 do
			info.text, info.arg1 = (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and miog.BRACKETS[i].description or miog.DIFFICULTY[i].description, i
			info.checked = i == MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentCategoryTableValue]
			UIDropDownMenu_AddButton(info)

		end

	end

	local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", searchPanelExtraFilter)
	optionDropdown:SetPoint("LEFT", dropdownOptionButton, "RIGHT", -15, 0)
	optionDropdown.initialize = fillDropdown
	UIDropDownMenu_SetWidth(optionDropdown, 175)

	miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown = optionDropdown

	local tanksSpinner = miog.addDualNumericSpinnerToFilterFrame(searchPanelExtraFilter, "Tanks")
	tanksSpinner:SetPoint("TOPLEFT", dropdownOptionButton, "BOTTOMLEFT", 0, 0)

	local healerSpinner = miog.addDualNumericSpinnerToFilterFrame(searchPanelExtraFilter, "Healers")
	healerSpinner:SetPoint("TOPLEFT", tanksSpinner, "BOTTOMLEFT", 0, 0)

	local damagerSpinner = miog.addDualNumericSpinnerToFilterFrame(searchPanelExtraFilter, "Damager")
	damagerSpinner:SetPoint("TOPLEFT", healerSpinner, "BOTTOMLEFT", 0, 0)

	local scoreField = miog.addDualNumericFieldsToFilterFrame(searchPanelExtraFilter, "Score")
	scoreField:SetPoint("TOPLEFT", damagerSpinner, "BOTTOMLEFT", 0, 0)

	local divider = miog.createBasicTexture("persistent", nil, searchPanelExtraFilter, searchPanelExtraFilter:GetWidth(), 1, "BORDER")
	divider:SetAtlas("UI-LFG-DividerLine")
	divider:SetPoint("BOTTOMLEFT", scoreField, "BOTTOMLEFT", 0, -5)

	local dungeonOptionsButton = miog.addOptionToFilterFrame(searchPanelExtraFilter, nil, "Dungeon options", "filterForDungeons")
	dungeonOptionsButton:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, 0)

	local dungeonPanel = miog.addDungeonCheckboxes()
	dungeonPanel:SetPoint("TOPLEFT", dungeonOptionsButton, "BOTTOMLEFT", 0, 0)

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
	local mapID = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].mapID or 0
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
	local color = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and
	(activityInfo.isPvpActivity and miog.BRACKETS[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].miogColors
	or miog.DIFFICULTY[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].miogColors) or {r = 1, g = 1, b = 1}
	currentFrame.iconFrame.border:SetColorTexture(color.r, color.g, color.b, 1)

	currentFrame.titleFrame:SetText(searchResultData.name)
	currentFrame.friendFrame:SetShown((searchResultData.numBNetFriends > 0 or searchResultData.numCharFriends > 0 or searchResultData.numGuildMates > 0) and true or false)

	currentFrame.difficultyZoneFrame:SetText(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.DIFFICULTY[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].shortName .. " - " ..
	(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].shortName) or activityInfo.fullName)

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

miog.createFrames = function()
	miog.createPVEFrameReplacement()
	createApplicationViewer()
	createSearchPanel()
	createEntryCreation()
	createUpgradedInvitePendingDialog()

	miog.scriptReceiver:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")

	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_FAILED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

	miog.scriptReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")

	miog.scriptReceiver:RegisterEvent("PARTY_LEADER_CHANGED")
	miog.scriptReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
	miog.scriptReceiver:RegisterEvent("GROUP_JOINED")
	miog.scriptReceiver:RegisterEvent("GROUP_LEFT")
	miog.scriptReceiver:RegisterEvent("INSPECT_READY")
	miog.scriptReceiver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	miog.scriptReceiver:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")

	miog.scriptReceiver:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
	miog.scriptReceiver:RegisterEvent("LFG_UPDATE")
	miog.scriptReceiver:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	miog.scriptReceiver:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
	miog.scriptReceiver:RegisterEvent("BATTLEFIELDS_SHOW")

	-- IMPLEMENTING CALENDAR EVENTS IN VERSION 2.1
	--miog.scriptReceiver:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
	--miog.scriptReceiver:RegisterEvent("CALENDAR_OPEN_EVENT")

	EncounterJournal_LoadUI()
	C_EncounterJournal.OnOpen = miog.dummyFunction
	EJ_SelectInstance(1207)

	hooksecurefunc("LFGListFrame_SetActivePanel", function(_, panel)
		if(panel == LFGListFrame.ApplicationViewer) then
			miog.pveFrame2.activePanel = "applicationViewer"
			miog.searchPanel:Hide()
			miog.entryCreation:Hide()
			miog.mainTab.CategoryPanel:Hide()

			miog.setupFiltersForActivePanel()
	
			miog.pveFrame2:Show()
			miog.mainTab.Plugin:Show()
			miog.applicationViewer:Show()
			miog.pveFrame2.SidePanel.Container.FilterPanel:Show()
			miog.searchPanel.PanelFilters:Hide()
			miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Hide()
	
		elseif(panel == LFGListFrame.SearchPanel) then
			miog.pveFrame2.activePanel = "searchPanel"
			miog.applicationViewer:Hide()
			miog.entryCreation:Hide()
			miog.mainTab.CategoryPanel:Hide()

			miog.setupFiltersForActivePanel()

			miog.pveFrame2:Show()
			miog.mainTab.Plugin:Show()
			miog.searchPanel:Show()
			miog.pveFrame2.SidePanel.Container.FilterPanel:Show()
			miog.searchPanel.PanelFilters:Show()
			miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Hide()
	
			if(LFGListFrame.SearchPanel.categoryID == 2 or LFGListFrame.SearchPanel.categoryID == 3 or LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) then
				UIDropDownMenu_Initialize(miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown, miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown.initialize)
				miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton:Show()
				miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown:Show()
	
			else
				miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown:Hide()
				miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton:Hide()
			
			end 
	
			miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[
				LFGListFrame.SearchPanel.categoryID == 2 and "filterForDungeonDifficulty" or
				LFGListFrame.SearchPanel.categoryID == 3 and "filterForRaidDifficulty" or
				(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "filterForArenaBracket"] or false)
	
		elseif(panel == LFGListFrame.EntryCreation) then
			--LFGListFrame.EntryCreation.editMode = false
			miog.applicationViewer:Hide()
			miog.searchPanel:Hide()
			miog.mainTab.CategoryPanel:Hide()
	
			miog.pveFrame2:Show()
			miog.mainTab.Plugin:Show()
			miog.entryCreation:Show()
			miog.searchPanel.PanelFilters:Hide()
			miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Show()
			
		else
			miog.applicationViewer:Hide()
			miog.searchPanel:Hide()
			miog.entryCreation:Hide()

			miog.mainTab.CategoryPanel:Show()
			miog.pveFrame2.SidePanel.Container.FilterPanel.Lock:Show()
			miog.mainTab.Plugin:Hide()
			miog.searchPanel.PanelFilters:Hide()
	
		end
	end)
end