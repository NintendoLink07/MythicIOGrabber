
local addonName, miog = ...
local wticc = WrapTextInColorCode

local selectedExpansion, defaultGroup, defaultActivity = nil, nil, nil

local playstyles = {
	Enum.LFGEntryPlaystyle.Standard,
	Enum.LFGEntryPlaystyle.Casual,
	Enum.LFGEntryPlaystyle.Hardcore
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
		local activityInfo = C_LFGList.GetActivityInfoTable(LFGListFrame.EntryCreation.selectedActivity)
	
		for k, playstyleInfo in ipairs(playstyles) do
			local activityButton = rootDescription:CreateRadio(C_LFGList.GetPlaystyleString(playstyleInfo, activityInfo), function(playstyle) return playstyle == LFGListFrame.EntryCreation.selectedPlaystyle end, function(playstyle)
				LFGListEntryCreation_OnPlayStyleSelectedInternal(LFGListFrame.EntryCreation, playstyle)
	
			end, playstyleInfo)
		end
	end)
	
	LFGListEntryCreation_OnPlayStyleSelectedInternal(LFGListFrame.EntryCreation, playstyles[1])
end

local function setUpDifficultyDropDown()
	miog.EntryCreation.DifficultyDropDown:SetupMenu(function(dropdown, rootDescription)
		local unsortedActivities = C_LFGList.GetAvailableActivities(LFGListFrame.EntryCreation.selectedCategory, LFGListFrame.EntryCreation.selectedGroup);
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
			local activityInfo = C_LFGList.GetActivityInfoTable(v)

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
	end)

	
end

function LFGListEntryCreation_SetTitleFromActivityInfo(self)
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	if(not self.selectedActivity or not self.selectedGroup or not self.selectedCategory) then
		return;
	end
	local activityID = activeEntryInfo and activeEntryInfo.activityIDs[1] or (self.selectedActivity or 0);
	local activityInfo =  C_LFGList.GetActivityInfoTable(activityID);
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

		activityButton:AddInitializer(function(button, description, menu)
			if(miog.ACTIVITY_INFO[v.activityID] and miog.ACTIVITY_INFO[v.activityID].icon) then
				local leftTexture = button:AttachTexture();
				leftTexture:SetSize(16, 16);
				leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
				leftTexture:SetTexture(miog.ACTIVITY_INFO[v.activityID].icon);

				button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

				return button.fontString:GetUnboundedStringWidth() + 18 + 5
			end
		end)

		if(not defaultGroup and not defaultActivity and k == 1) then
			defaultGroup = v.groupID
			defaultActivity = v.activityID
		end
	end
end

local function addExpansionHeadersToDropdown(rootDescription)
	if(LFGListFrame.CategorySelection.selectedCategory == 2 or LFGListFrame.CategorySelection.selectedCategory == 3 and LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
		for i = 0, GetNumExpansions() - (LFGListFrame.CategorySelection.selectedCategory == 3 and 2 or 1), 1 do
		--for k, v in ipairs(expansionTable) do
			local expansionInfo = GetExpansionDisplayInfo(i)

			local expansionButton = rootDescription:CreateRadio(miog.EXPANSION_INFO[i][1], function(index) return index == selectedExpansion end, function(index)
			end, i)
	
			expansionButton:AddInitializer(function(button, description, menu)
				local leftTexture = button:AttachTexture();
				leftTexture:SetSize(16, 16);
				leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
				leftTexture:SetTexture(expansionInfo.logo);

				button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

				return button.fontString:GetUnboundedStringWidth() + 18 + 5
			end)

			local expansionGroupList = {}
			local allExpansionsGroups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, Enum.LFGListFilter.PvE)
	
			for _, y in ipairs(allExpansionsGroups) do
				local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, y)
				local activityID = activities[#activities]

				if(miog.ACTIVITY_INFO[activityID].expansionLevel == i) then
					tinsert(expansionGroupList, {name = C_LFGList.GetActivityGroupInfo(y), activityID = activityID, groupID = y})

				end
			end

			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, 0, 6)

			for _, activityID in ipairs(activities) do
				if(miog.ACTIVITY_INFO[activityID].expansionLevel == i) then
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

					tinsert(expansionGroupList, {name = activityInfo.shortName, activityID = activityID, groupID = 0})
				end
			end
	
			table.sort(expansionGroupList, function(k1, k2)
				return k1.name < k2.name
			end)

			for k, v in ipairs(expansionGroupList) do
				local activityButton = expansionButton:CreateRadio(v.name, function(data) return (data.groupID > 0 and data.groupID == LFGListFrame.EntryCreation.selectedGroup or data.activityID == LFGListFrame.EntryCreation.selectedActivity) and selectedExpansion == i end, function(data)
					selectedExpansion = i

					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.EntryCreation.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, v.groupID, v.activityID)

				end, v)

				activityButton:AddInitializer(function(button, description, menu)
					local leftTexture = button:AttachTexture();
					leftTexture:SetSize(16, 16);
					leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
					leftTexture:SetTexture(miog.ACTIVITY_INFO[v.activityID].icon);

					button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

					return button.fontString:GetUnboundedStringWidth() + 18 + 5
				end)

				if(not selectedExpansion and not defaultGroup and not defaultActivity and k == 1) then
					defaultGroup = v.groupID
					defaultActivity = v.activityID
					selectedExpansion = i
					
				end
			end
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

		local seasonGroups = C_LFGList.GetAvailableActivityGroups(LFGListFrame.CategorySelection.selectedCategory, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE))

		for k, v in ipairs(seasonGroups) do
			local activities = C_LFGList.GetAvailableActivities(LFGListFrame.CategorySelection.selectedCategory, v)
			local activityID = activities[#activities]C_LFGList.GetActivityGroupInfo(v)

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
		
		rootDescription:CreateTitle(miog.EXPANSION_INFO[GetNumExpansions() - 1][1] .. " Dungeons")
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
				local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

				tinsert(raidList, {index = k, name = activityInfo.fullName, activityID = activityID, groupID = 0})
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

		for k, v in ipairs(pvpActivities) do
			local activityInfo = C_LFGList.GetActivityInfoTable(v)

			tinsert(pvpTable, {index = k, name = activityInfo.fullName, activityID = v, groupID = 0})
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
	local activityInfo = C_LFGList.GetActivityInfoTable(LFGListFrame.EntryCreation.selectedActivity);
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

	if(miog.ACTIVITY_INFO[LFGListFrame.EntryCreation.selectedActivity]) then
		if(miog.isMIOGHQLoaded()) then
			entryCreation.Background:SetVertTile(false)
			entryCreation.Background:SetHorizTile(false)
			entryCreation.Background:SetTexture(miog.ACTIVITY_INFO[LFGListFrame.EntryCreation.selectedActivity].horizontal, "CLAMP", "CLAMP")

		else
			entryCreation.Background:SetVertTile(true)
			entryCreation.Background:SetHorizTile(true)
			entryCreation.Background:SetTexture(miog.ACTIVITY_INFO[LFGListFrame.EntryCreation.selectedActivity].horizontal, "MIRROR", "MIRROR")

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
		local activityInfo = C_LFGList.GetActivityInfoTable(entryInfo.activityIDs[1])

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

	-- set to first group found in all activities // default
	LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, defaultGroup and defaultGroup > 0 and defaultGroup or nil, defaultActivity)
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
	local entryCreation = CreateFrame("Frame", "MythicIOGrabber_EntryCreation", miog.Plugin.InsertFrame, "MIOG_EntryCreation") ---@class Frame
	entryCreation:GetParent().EntryCreation = entryCreation

	entryCreation.Border:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	entryCreation.selectedActivity = 0

	entryCreation.ActivityDropDown:SetDefaultText("Select an activity")
	entryCreation.DifficultyDropDown:SetDefaultText("Select a difficulty")
	entryCreation.PlaystyleDropDown:SetDefaultText("Select a playstyle")

    entryCreation.ActivityDropDown:SetupMenu(function(dropdown, rootDescription)
		gatherAllActivities(dropdown, rootDescription)

	end)

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