local addonName, miog = ...
local wticc = WrapTextInColorCode

--[[
	needsMyClass

	needsTank

	needsHealer

	needsDamage

	hasTank

	hasHealer

	minimumRating

	difficultyNormal

	difficultyHeroic

	difficultyMythic

	difficultyMythicPlus

	activities {groupFinderActivityID}
]]
local function convertAdvancedBlizzardFiltersToMIOGFilters()
	if(C_LFGList.GetAdvancedFilter) then
		local blizzardFilters = C_LFGList.GetAdvancedFilter()
		local missingFilters = MIOG_SavedSettings.currentBlizzardFilters == nil and true or false
		local filtersUpToDate = true

		for k, v in pairs(blizzardFilters) do
			if(k ~= "activities" and v ~= MIOG_SavedSettings.currentBlizzardFilters[k]) then
				filtersUpToDate = false

			end
		end

		if(missingFilters or not filtersUpToDate) then
			MIOG_SavedSettings.currentBlizzardFilters = blizzardFilters

			for k, v in pairs(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"]) do
				v.minScore = blizzardFilters.minimumRating
				v.minHealers = blizzardFilters.hasHealer == true and 1 or 0
				v.minTanks = blizzardFilters.hasTank == true and 1 or 0

				v.filterForTanks = v.minTanks > 0 and true
				v.filterForHealers = v.minHealers > 0 and true

				if(k == 2) then
					v.filterForScore = v.minScore > 0 and true
				end

				local _, id = UnitClassBase("player")
				v.classSpec.class[id] = not (blizzardFilters.needsMyClass == true)
				v.filterForRoles["TANK"] = not (blizzardFilters.needsTank == true)
				v.filterForRoles["HEALER"] = not (blizzardFilters.needsHealer == true)
				v.filterForRoles["DAMAGER"] = not (blizzardFilters.needsDamage == true)
			end
		end
	end
end

miog.convertAdvancedBlizzardFiltersToMIOGFilters = convertAdvancedBlizzardFiltersToMIOGFilters

local function convertFiltersToAdvancedBlizzardFilters()
	if(C_LFGList.GetAdvancedFilter) then
		local miogFilters = {}
		local categoryID = LFGListFrame.SearchPanel.categoryID or LFGListFrame.CategorySelection.selectedCategory

		miogFilters.minimumRating = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minScore
		miogFilters.hasHealer = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minHealers > 0 and true or false
		miogFilters.hasTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minTanks > 0 and true or false

		miogFilters.difficultyNormal = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonNormal
		miogFilters.difficultyHeroic = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonHeroic
		miogFilters.difficultyMythic = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonMythic
		miogFilters.difficultyMythicPlus = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonChallenge

		local _, id = UnitClassBase("player")

		miogFilters.needsMyClass = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].classSpec.class[id] == false
		miogFilters.needsTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["TANK"] == false
		miogFilters.needsHealer = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["HEALER"] == false
		miogFilters.needsDamage = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["DAMAGER"] == false

		local blizzardFilter = C_LFGList.GetAdvancedFilter()
		miogFilters.activities = blizzardFilter.activities
		C_LFGList.SaveAdvancedFilter(miogFilters)
	end
end

local function addOptionToFilterFrame(parent, _, text, name)
	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOption")
	filterOption:SetWidth(200)
	filterOption:SetHeight(25)
	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][name] = self:GetChecked()

		convertFiltersToAdvancedBlizzardFilters()
		
		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterOption.Name:SetText(text)

	miog.FilterPanel.FilterOptions[name] = filterOption

	return filterOption
end

miog.addOptionToFilterFrame = addOptionToFilterFrame

local function addDualNumericSpinnerToFilterFrame(parent, name, range)
	local filterPanel = miog.FilterPanel

	local minName = "min" .. name
	local maxName = "max" .. name

	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualSpinnerTemplate")
	filterOption:SetSize(parent:GetWidth(), 25)
	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]["filterFor" .. name] = self:GetChecked()

		convertFiltersToAdvancedBlizzardFilters()

		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterOption.Name:SetText(name)

	filterPanel.FilterOptions["filterFor" .. name] = filterOption.Button
	filterPanel.FilterOptions["linked" .. name] = filterOption.Link

	filterOption.Link:SetScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]["linked" .. name] = self:GetChecked()

		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	for i = 1, 2, 1 do
		local currentName = i == 1 and minName or maxName

		filterOption["Spinner" .. i]:SetWidth(21)
		filterOption["Spinner" .. i]:SetMinMaxValues(range ~= nil and range or 0, 40)
		
		filterOption["Spinner" .. i]:SetScript("OnTextChanged", function(self, userInput)
			if(userInput) then
				local spinnerValue = self:GetNumber()

				if(spinnerValue) then

					local currentPanel = LFGListFrame.activePanel:GetDebugName()
					local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

					self:SetValue(spinnerValue)

					if(i == 1) then
						if(filterPanel.FilterOptions[maxName]:GetValue() < spinnerValue) then
							filterPanel.FilterOptions[maxName]:SetValue(spinnerValue)
							MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][maxName] = spinnerValue

						end

					else
						if(filterPanel.FilterOptions[minName]:GetValue() > spinnerValue) then
							filterPanel.FilterOptions[minName]:SetValue(spinnerValue)
							MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][minName] = spinnerValue

						end
					end

					convertFiltersToAdvancedBlizzardFilters()
				
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end
			end
		end)

		filterOption["Spinner" .. i].DecrementButton:SetScript("OnMouseDown", function(self)
			filterOption["Spinner" .. i]:Decrement()

			local spinnerValue = filterOption["Spinner" .. i]:GetValue()

			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
		

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

			if(filterPanel.FilterOptions[minName]:GetValue() > spinnerValue) then
				filterPanel.FilterOptions[minName]:SetValue(spinnerValue)
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][minName] = spinnerValue

			end

			filterOption["Spinner" .. i]:ClearFocus()

			convertFiltersToAdvancedBlizzardFilters()
		
			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end
		end)

		filterOption["Spinner" .. i].IncrementButton:SetScript("OnMouseDown", function()
			filterOption["Spinner" .. i]:Increment()

			local spinnerValue = filterOption["Spinner" .. i]:GetValue()

			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

			if(filterPanel.FilterOptions[maxName]:GetValue() < spinnerValue) then
				filterPanel.FilterOptions[maxName]:SetValue(spinnerValue)
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][maxName] = spinnerValue

			end

			filterOption["Spinner" .. i]:ClearFocus()

			convertFiltersToAdvancedBlizzardFilters()
		
			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end
		end)

		filterPanel.FilterOptions[currentName] = filterOption["Spinner" .. i]
	end

	return filterOption

end

miog.addDualNumericSpinnerToFilterFrame = addDualNumericSpinnerToFilterFrame

local function addDualNumericFieldsToFilterFrame(parent, name)
	local filterPanel = miog.FilterPanel

	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", parent, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	optionButton:RegisterForClicks("LeftButtonDown")
	optionButton:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]["filterFor" .. name] = self:GetChecked()

		convertFiltersToAdvancedBlizzardFilters()
		
		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterPanel.FilterOptions["filterFor" .. name] = optionButton

	local optionString = miog.createBasicFontString("persistent", 11, parent)
	optionString:SetPoint("LEFT", optionButton, "RIGHT", 2, 0)
	optionString:SetText(name)

	local minName = "min" .. name
	local maxName = "max" .. name

	local lastNumericField = nil

	for i = 1, 2, 1 do
		local currentName = i == 1 and minName or maxName

		local numericField = miog.createBasicFrame("persistent", "InputBoxTemplate", parent, miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		numericField:SetPoint("LEFT", i == 1 and optionButton or lastNumericField, "RIGHT", i == 1 and 70 or 5, 0)
		numericField:SetAutoFocus(false)
		numericField.autoFocus = false
		numericField:SetNumeric(true)
		numericField:SetMaxLetters(4)
		numericField:HookScript("OnTextChanged", function(self, ...)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			
			local text = tonumber(self:GetText())
			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
		
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = text ~= nil and text or 0

			convertFiltersToAdvancedBlizzardFilters()

			if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]["filterFor" .. name]) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end

		end)
		

		filterPanel.FilterOptions[currentName] = numericField

		lastNumericField = numericField
	end

	return optionButton

end

miog.addDualNumericFieldsToFilterFrame = addDualNumericFieldsToFilterFrame

local function updateDungeonCheckboxes()
	local filterPanel = miog.FilterPanel
	local sortedSeasonDungeons = {}

	local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));

	if(seasonGroups) then
		for _, v in ipairs(seasonGroups) do
			local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
			sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}

		end

		table.sort(sortedSeasonDungeons, function(k1, k2)
			return k1.name < k2.name
		end)

		for k, activityEntry in ipairs(sortedSeasonDungeons) do
			local currentButton = filterPanel.FilterOptions.DungeonPanel.Buttons[k]

			currentButton:HookScript("OnClick", function(self)
				MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2].dungeons[activityEntry.groupFinderActivityGroupID] = self:GetChecked()

				if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2].dungeons) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end

			end)
			
			currentButton.FontString:SetText(activityEntry.name)
		end

		miog.UPDATED_DUNGEON_FILTERS = true
	end
end

miog.updateDungeonCheckboxes = updateDungeonCheckboxes

local function updateRaidCheckboxes()
	local filterPanel = miog.FilterPanel
	local sortedExpansionRaids = {}
	
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(3, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE));

	if(seasonGroups) then
		for _, v in ipairs(seasonGroups) do
			local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
			sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}

		end

		table.sort(sortedExpansionRaids, function(k1, k2)
			return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID
		end)

		for k, activityEntry in ipairs(sortedExpansionRaids) do
			local currentButton = filterPanel.FilterOptions.RaidPanel.Buttons[k]

			currentButton:HookScript("OnClick", function(self)
				MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID] = self:GetChecked()

				if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end

			end)
			
			currentButton.FontString:SetText(activityEntry.name)
		end

		miog.UPDATED_RAID_FILTERS = true
	end
end

miog.updateRaidCheckboxes = updateRaidCheckboxes

local function addRaidCheckboxes()
	local filterPanel = miog.FilterPanel
	
	local raidPanel = miog.createBasicFrame("persistent", "BackdropTemplate", filterPanel.CategoryOptions, filterPanel.CategoryOptions:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	raidPanel.Buttons = {}

	filterPanel.FilterOptions.RaidPanel = raidPanel

	local raidPanelFirstRow = miog.createBasicFrame("persistent", "BackdropTemplate", raidPanel, raidPanel:GetWidth(), raidPanel:GetHeight() / 2)
	raidPanelFirstRow:SetPoint("TOPLEFT", raidPanel, "TOPLEFT")

	local raidPanelSecondRow = miog.createBasicFrame("persistent", "BackdropTemplate", raidPanel, raidPanel:GetWidth(), raidPanel:GetHeight() / 2)
	raidPanelSecondRow:SetPoint("BOTTOMLEFT", raidPanel, "BOTTOMLEFT")

	local counter = 0

	for i = 1, 3, 1 do
		local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", raidPanel, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		optionButton:SetPoint("LEFT", counter < 4 and raidPanelFirstRow or counter > 3 and raidPanelSecondRow, "LEFT", counter < 4 and counter * 57 or (counter - 4) * 57, 0)
		optionButton:SetNormalAtlas("checkbox-minimal")
		optionButton:SetPushedAtlas("checkbox-minimal")
		optionButton:SetCheckedTexture("checkmark-minimal")
		optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		optionButton:RegisterForClicks("LeftButtonDown")
	
		raidPanel.Buttons[i] = optionButton
	
		local optionString = miog.createBasicFontString("persistent", 12, raidPanel)
		optionString:SetPoint("LEFT", optionButton, "RIGHT")

		optionButton.FontString = optionString

		counter = counter + 1
	end

	return raidPanel
end

miog.addRaidCheckboxes = addRaidCheckboxes

local function addDungeonCheckboxes()
	local filterPanel = miog.FilterPanel
	
	local dungeonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", filterPanel.CategoryOptions, filterPanel.CategoryOptions:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	dungeonPanel.Buttons = {}

	filterPanel.FilterOptions.DungeonPanel = dungeonPanel

	local dungeonPanelFirstRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), dungeonPanel:GetHeight() / 2)
	dungeonPanelFirstRow:SetPoint("TOPLEFT", dungeonPanel, "TOPLEFT")

	local dungeonPanelSecondRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), dungeonPanel:GetHeight() / 2)
	dungeonPanelSecondRow:SetPoint("BOTTOMLEFT", dungeonPanel, "BOTTOMLEFT")

	local counter = 0

	for i = 1, 8, 1 do
		local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", dungeonPanel, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		optionButton:SetPoint("LEFT", counter < 4 and dungeonPanelFirstRow or counter > 3 and dungeonPanelSecondRow, "LEFT", counter < 4 and counter * 57 or (counter - 4) * 57, 0)
		optionButton:SetNormalAtlas("checkbox-minimal")
		optionButton:SetPushedAtlas("checkbox-minimal")
		optionButton:SetCheckedTexture("checkmark-minimal")
		optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		optionButton:RegisterForClicks("LeftButtonDown")
		optionButton:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end)
		
		dungeonPanel.Buttons[i] = optionButton
	
		local optionString = miog.createBasicFontString("persistent", 12, dungeonPanel)
		optionString:SetPoint("LEFT", optionButton, "RIGHT")

		optionButton.FontString = optionString

		counter = counter + 1
	end

	return dungeonPanel
end

miog.addDungeonCheckboxes = addDungeonCheckboxes

local function updateFilterDifficulties(reset)
	local currentPanel = LFGListFrame.activePanel:GetDebugName()
	local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

	if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()]) then
		local difficultyDropDown = miog.FilterPanel.FilterOptions.Dropdown
		difficultyDropDown:ResetDropDown()

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID] = MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]
		or miog.resetSpecificFilterToDefault(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID])

		local categoryID = LFGListFrame.SearchPanel.categoryID or C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID

		local isPvp = categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9
		local isDungeon = categoryID == 2
		local isRaid = categoryID == 3

		if(isPvp or isDungeon or isRaid) then

			for k, v in ipairs(isRaid and miog.RAID_DIFFICULTIES or isPvp and {6, 7} or isDungeon and miog.DUNGEON_DIFFICULTIES) do
				local info = {}
				info.entryType = "option"
				info.text = isPvp and (v == 6 and "2v2" or "3v3") or miog.DIFFICULTY_ID_INFO[v].name
				info.level = 1
				info.value = v
				info.func = function()
					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].difficultyID = v

					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end
				
				difficultyDropDown:CreateEntryFrame(info)

			end

			difficultyDropDown.List:MarkDirty()

			if(not reset) then
				local success = difficultyDropDown:SelectFirstFrameWithValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].difficultyID)
				
				if(not success) then
					difficultyDropDown:SelectFrameAtLayoutIndex(1)

				end

			else
				difficultyDropDown:SelectFrameAtLayoutIndex(1)

			end
		end
	end
end

local function setupFiltersForActivePanel(reset)
	miog.FilterPanel.Uncheck:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_SavedSettings.filterOptions.table[currentPanel][categoryID] = miog.resetSpecificFilterToDefault(MIOG_SavedSettings.filterOptions.table[currentPanel][categoryID])

		setupFiltersForActivePanel(true)

		miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

		convertFiltersToAdvancedBlizzardFilters()

		miog.checkSearchResultListForEligibleMembers()
	end)


	local currentPanel = LFGListFrame.activePanel:GetDebugName()
	local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

	if(currentPanel == "LFGListFrame.SearchPanel") then
		miog.FilterPanel.SearchPanelOptions:Show()

		if((categoryID == 2 or categoryID == 3)) then
			miog.FilterPanel.CategoryOptions:Show()

		else
			miog.FilterPanel.CategoryOptions:Hide()
		
		end
	else
		miog.FilterPanel.SearchPanelOptions:Hide()
		miog.FilterPanel.CategoryOptions:Hide()
	
	end


	local isDungeon = categoryID == 2
	local isRaid = categoryID == 3
	local isPvp = categoryID == 4 or categoryID == 7

	local filterPanel = miog.FilterPanel

	if(categoryID) then
		if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID] == nil) then
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID] = miog.resetSpecificFilterToDefault(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID])
			
		end

		updateFilterDifficulties(reset)

		for i = 1, 3, 1 do
			filterPanel.FilterOptions.Roles.RoleButtons[i]:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"])
		end

		for k, v in pairs(filterPanel.FilterOptions) do
			if(v.Button and v.Button:GetObjectType() == "CheckButton") then
				v.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][k])
			end
		end

		filterPanel.FilterOptions.filterForDifficulty:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDifficulty)

		filterPanel.FilterOptions.linkedTanks:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedTanks)
		filterPanel.FilterOptions.linkedHealers:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedHealers)
		filterPanel.FilterOptions.linkedDamager:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedDamager)

		filterPanel.FilterOptions.filterForTanks:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForTanks)
		filterPanel.FilterOptions.minTanks:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minTanks)
		filterPanel.FilterOptions.maxTanks:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxTanks)

		filterPanel.FilterOptions.filterForHealers:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForHealers)
		filterPanel.FilterOptions.minHealers:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minHealers)
		filterPanel.FilterOptions.maxHealers:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxHealers)

		filterPanel.FilterOptions.filterForDamager:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDamager)
		filterPanel.FilterOptions.minDamager:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minDamager)
		filterPanel.FilterOptions.maxDamager:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxDamager)

		filterPanel.FilterOptions.filterForScore:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForScore)
		filterPanel.FilterOptions.minScore:SetNumber(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minScore)
		filterPanel.FilterOptions.maxScore:SetNumber(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxScore)

		--filterPanel.FilterOptions["filterForClassSpecs"].Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForClassSpecs)
		filterPanel.FilterOptions.filterForClassSpecs.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForClassSpecs)

		for classIndex, classEntry in ipairs(miog.CLASSES) do
			local currentClassPanel = filterPanel.FilterOptions.ClassPanels[classIndex]

			if(MIOG_SavedSettings and MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec) then
				if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.class[classIndex] ~= nil) then
					currentClassPanel.Class.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.class[classIndex])
					
					if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.class[classIndex] == false) then
						miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))
					end

				else
					currentClassPanel.Class.Button:SetChecked(true)

				end

			else
				currentClassPanel.Class.Button:SetChecked(true)

			end
			
			currentClassPanel.Class.Button:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

				local state = currentClassPanel.Class.Button:GetChecked()

				for specIndex, specFrame in pairs(currentClassPanel.SpecFrames) do
				--for i = 1, 4, 1 do

					if(state) then
						specFrame.Button:SetChecked(true)

					else
						specFrame.Button:SetChecked(false)

					end

					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.spec[specIndex] = state
				end

				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.class[classIndex] = state

				if(not miog.checkForActiveFilters()) then
					miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

				else
					miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

				end

				convertFiltersToAdvancedBlizzardFilters()

				if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForClassSpecs) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end
			end)

			for specIndex, specID in pairs(classEntry.specs) do
				local currentSpecFrame = currentClassPanel.SpecFrames[specID]
				if(MIOG_SavedSettings and MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec) then
					if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.spec[specID] ~= nil) then
						currentSpecFrame.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.spec[specID])

						if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.spec[specID]) then
							miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))
						end

					else
						currentSpecFrame.Button:SetChecked(true)

					end

				else
					currentSpecFrame.Button:SetChecked(true)

				end
				
				currentSpecFrame.Button:SetScript("OnClick", function()
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

					local state = currentSpecFrame.Button:GetChecked()

					if(state) then
						currentClassPanel.Class.Button:SetChecked(true)

						if(not miog.checkForActiveFilters()) then
							miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

						end

					else
						miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

					end

					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].classSpec.spec[specID] = state

					convertFiltersToAdvancedBlizzardFilters()

					if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForClassSpecs) then
						if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
							miog.checkSearchResultListForEligibleMembers()
				
						elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
							C_LFGList.RefreshApplicants()
				
						end
					end

				end)
			end
		end
		if(categoryID == 2) then
			filterPanel.FilterOptions.filterForDungeons.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDungeons)

			local sortedSeasonDungeons = {}

			local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));

			if(seasonGroups) then
				for _, v in ipairs(seasonGroups) do
					local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
					sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}
		
				end
		
				table.sort(sortedSeasonDungeons, function(k1, k2)
					return k1.name < k2.name
				end)

				for k, activityEntry in ipairs(sortedSeasonDungeons) do
					local notChecked = MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][2].dungeons[activityEntry.groupFinderActivityGroupID] == false
					filterPanel.FilterOptions.DungeonPanel.Buttons[k]:SetChecked(reset or not notChecked)
				end
			end
		elseif(categoryID == 3) then
			local sortedExpansionRaids = {}
			filterPanel.FilterOptions.filterForRaids.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRaids)

			if(LFGListFrame.SearchPanel.filters == Enum.LFGListFilter.Recommended) then
				for k, v in pairs(miog.ACTIVITY_INFO) do
					if(v.expansionLevel == (GetAccountExpansionLevel()-1) and v.difficultyID == miog.RAID_DIFFICULTIES[3]) then
						sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = v.groupFinderActivityGroupID, name = v.shortName}
					end

				end

				table.sort(sortedExpansionRaids, function(k1, k2)
					return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID
				end)

				for k, activityEntry in ipairs(sortedExpansionRaids) do
					local checked = MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][3].raids[activityEntry.groupFinderActivityGroupID]
					filterPanel.FilterOptions.RaidPanel.Buttons[k]:SetChecked(reset or checked)
				end
			end
		end
	end

	miog.FilterPanel:MarkDirty()
end

miog.setupFiltersForActivePanel = setupFiltersForActivePanel

local function createClassSpecFilters(parent)
	miog.FilterPanel.FilterOptions.ClassPanels = {}

	for classIndex, classEntry in ipairs(miog.CLASSES) do
		local classPanel = CreateFrame("Frame", nil, parent, "MIOG_ClassSpecFilterRowTemplate")

		classPanel:SetSize(parent:GetWidth(), 20)

		if(classIndex > 1) then
			classPanel:SetPoint("TOPLEFT", miog.FilterPanel.FilterOptions.ClassPanels[classIndex-1] or parent, miog.FilterPanel.FilterOptions.ClassPanels[classIndex-1] and "BOTTOMLEFT" or "TOPLEFT", 0, -1)
		end

		local r, g, b = GetClassColor(classEntry.name)
		miog.createFrameBorder(classPanel, 1, r, g, b, 0.9)
		classPanel:SetBackdropColor(r, g, b, 0.6)

		classPanel.Class.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/classIcons/" .. classEntry.name .. "_round.png")

		miog.FilterPanel.FilterOptions.ClassPanels[classIndex] = classPanel
		classPanel.SpecFrames = {}

		for specIndex, specID in pairs(classEntry.specs) do
			local specEntry = miog.SPECIALIZATIONS[specID]

			local currentSpec = CreateFrame("Frame", nil, parent, "MIOG_ClassSpecSingleOptionTemplate")
			currentSpec:SetSize(36, 20)
			currentSpec:SetPoint("LEFT", classPanel.SpecFrames[classEntry.specs[specIndex-1]] or classPanel.Class.Texture, "RIGHT", 8, 0)
			currentSpec.Texture:SetTexture(specEntry.icon)

			classPanel.SpecFrames[specID] = currentSpec

		end

	end

	return miog.FilterPanel.FilterOptions.ClassPanels[1], miog.FilterPanel.FilterOptions.ClassPanels[#miog.CLASSES]
end

local function addRolePanel(parent)
	local roleFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", parent, 150, 20)
	roleFilterPanel.RoleButtons = {}

	local lastTexture = nil

	miog.FilterPanel.FilterOptions.Roles = roleFilterPanel

	for i = 1, 3, 1 do
		local toggleRoleButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", roleFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
		toggleRoleButton:SetNormalAtlas("checkbox-minimal")
		toggleRoleButton:SetPushedAtlas("checkbox-minimal")
		toggleRoleButton:SetCheckedTexture("checkmark-minimal")
		toggleRoleButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		toggleRoleButton:SetPoint("LEFT", lastTexture or roleFilterPanel, lastTexture and "RIGHT" or "LEFT", lastTexture and 10 or 0, 0)
		toggleRoleButton:RegisterForClicks("LeftButtonDown")

		local roleTexture = miog.createBasicTexture("persistent", nil, roleFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 3, miog.C.APPLICANT_MEMBER_HEIGHT - 3, "ARTWORK")
		roleTexture:SetPoint("LEFT", toggleRoleButton, "RIGHT", 0, 0)

		toggleRoleButton:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

			local state = toggleRoleButton:GetChecked()
			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
		

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"] = state

			if(not miog.checkForActiveFilters()) then
				miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				miog.FilterPanel.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

			convertFiltersToAdvancedBlizzardFilters()

			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end

		end)

		if(i == 1) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")

		elseif(i == 2) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")

		elseif(i == 3) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")

		end

		roleFilterPanel.RoleButtons[i] = toggleRoleButton

		lastTexture = roleTexture

	end

	return roleFilterPanel
end

miog.loadFilterPanel = function()
	miog.FilterPanel = CreateFrame("Frame", "MythicIOGrabber_FilterPanel", miog.Plugin, "MIOG_FilterPanel") ---@class Frame
	miog.FilterPanel:SetPoint("TOPLEFT", miog.MainFrame, "TOPRIGHT", 5, 0)
	miog.FilterPanel:SetSize(230, 650)
	miog.FilterPanel:Hide()
	miog.createFrameBorder(miog.FilterPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	
	miog.LastInvites = CreateFrame("Frame", "MythicIOGrabber_LastInvitesPanel", miog.Plugin, "MIOG_LastInvitesTemplate") ---@class Frame
	miog.LastInvites:SetPoint("TOPLEFT", miog.MainFrame, "TOPRIGHT", 5, 0)
	miog.LastInvites:SetSize(230, miog.MainFrame:GetHeight())
	miog.LastInvites:Hide()
	miog.createFrameBorder(miog.LastInvites, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local function hideSidePanel(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self:GetParent():GetParent():Hide()
		self:GetParent():GetParent():GetParent().ButtonPanel:Show()

		MIOG_SavedSettings.activeSidePanel.value = ""
	end

	miog.FilterPanel.TitleBar.Retract:SetScript("OnClick", function(self)
		hideSidePanel(self)
	end)

	miog.LastInvites.TitleBar.Retract:SetScript("OnClick", function(self)
		hideSidePanel(self)
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


	miog.FilterPanel.FilterOptions = {}

	local rolePanel = addRolePanel(miog.FilterPanel.StandardOptions)
	rolePanel:SetPoint("TOPLEFT", miog.FilterPanel.StandardOptions, "TOPLEFT")
	
	local classSpecOption = addOptionToFilterFrame(miog.FilterPanel.StandardOptions, nil, "Class / spec", "filterForClassSpecs")
	classSpecOption:SetPoint("TOPLEFT", rolePanel, "BOTTOMLEFT")

	local firstClassPanel, lastClassPanel = createClassSpecFilters(miog.FilterPanel.StandardOptions)
	firstClassPanel:SetPoint("TOPLEFT", classSpecOption, "BOTTOMLEFT")
	
	local partyFitButton = addOptionToFilterFrame(miog.FilterPanel.StandardOptions, nil, "Party fit", "partyFit")
	partyFitButton:SetPoint("TOPLEFT", lastClassPanel, "BOTTOMLEFT", 0, 0)
	
	local ressFitButton = addOptionToFilterFrame(miog.FilterPanel.StandardOptions, nil, "Ress fit", "ressFit")
	ressFitButton:SetPoint("TOPLEFT", partyFitButton, "BOTTOMLEFT", 0, 0)

	local lustFitButton = addOptionToFilterFrame(miog.FilterPanel.StandardOptions, nil, "Lust fit", "lustFit")
	lustFitButton:SetPoint("TOPLEFT", ressFitButton, "BOTTOMLEFT", 0, 0)
	
	local hideHardDecline = addOptionToFilterFrame(miog.FilterPanel.SearchPanelOptions, nil, "Hide hard decline", "hardDecline")
	hideHardDecline:SetPoint("TOPLEFT", miog.FilterPanel.SearchPanelOptions, "TOPLEFT", 0, 0)

	local dropdownOptionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", miog.FilterPanel.SearchPanelOptions, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	dropdownOptionButton:SetNormalAtlas("checkbox-minimal")
	dropdownOptionButton:SetPushedAtlas("checkbox-minimal")
	dropdownOptionButton:SetCheckedTexture("checkmark-minimal")
	dropdownOptionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	dropdownOptionButton:SetPoint("TOPLEFT", hideHardDecline, "BOTTOMLEFT", 0, 0)
	dropdownOptionButton:HookScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDifficulty = self:GetChecked()

			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end
	end)
	miog.FilterPanel.FilterOptions.filterForDifficulty = dropdownOptionButton

	local optionDropDown = Mixin(CreateFrame("Frame", nil, miog.FilterPanel.SearchPanelOptions, "MIOG_DropDownMenu"), SlickDropDown)
	optionDropDown:OnLoad()
	optionDropDown:SetWidth(miog.FilterPanel:GetWidth() - dropdownOptionButton:GetWidth() - 5)
	optionDropDown:SetHeight(25)
	optionDropDown:SetPoint("TOPLEFT", dropdownOptionButton, "TOPRIGHT")
	optionDropDown:SetText("Choose a difficulty")
	miog.FilterPanel.FilterOptions.Dropdown = optionDropDown

	local tanksSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.SearchPanelOptions, "Tanks")
	tanksSpinner:SetPoint("TOPLEFT", dropdownOptionButton, "BOTTOMLEFT", 0, 0)

	local healerSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.SearchPanelOptions, "Healers")
	healerSpinner:SetPoint("TOPLEFT", tanksSpinner, "BOTTOMLEFT", 0, 0)

	local damagerSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.SearchPanelOptions, "Damager")
	damagerSpinner:SetPoint("TOPLEFT", healerSpinner, "BOTTOMLEFT", 0, 0)

	local scoreField = miog.addDualNumericFieldsToFilterFrame(miog.FilterPanel.SearchPanelOptions, "Score")
	scoreField:SetPoint("TOPLEFT", damagerSpinner, "BOTTOMLEFT", 0, 0)

	local divider = miog.createBasicTexture("persistent", nil, miog.FilterPanel.CategoryOptions, miog.FilterPanel.CategoryOptions:GetWidth(), 1, "BORDER")
	divider:SetAtlas("UI-LFG-DividerLine")
	divider:SetPoint("BOTTOMLEFT", scoreField, "BOTTOMLEFT", 0, -5)

	local dungeonOptionsButton = addOptionToFilterFrame(miog.FilterPanel.CategoryOptions, nil, "Dungeon options", "filterForDungeons")
	dungeonOptionsButton:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, 0)

	local dungeonPanel = miog.addDungeonCheckboxes()
	dungeonPanel:SetPoint("TOPLEFT", dungeonOptionsButton, "BOTTOMLEFT", 0, 0)
	dungeonPanel.OptionsButton = dungeonOptionsButton

	local raidOptionsButton = addOptionToFilterFrame(miog.FilterPanel.CategoryOptions, nil, "Raid options", "filterForRaids")
	raidOptionsButton:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, 0)

	local raidPanel = miog.addRaidCheckboxes()
	raidPanel:SetPoint("TOPLEFT", raidOptionsButton, "BOTTOMLEFT", 0, 0)
	raidPanel.OptionsButton = raidOptionsButton
end
