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
	local miogFilters = {}
	local categoryID = LFGListFrame.SearchPanel.categoryID or LFGListFrame.CategorySelection.selectedCategory

	miogFilters.minimumRating = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minScore
	miogFilters.hasHealer = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForHealers
	miogFilters.hasTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForTanks

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

	parent[name] = filterOption

	return filterOption
end

miog.addOptionToFilterFrame = addOptionToFilterFrame

local function addDualNumericSpinnerToFilterFrame(parent, name, text, range)
	local minName = "min" .. name
	local maxName = "max" .. name

	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualSpinnerTemplate")
	filterOption:SetSize(220, 25)
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

	filterOption.Name:SetText(text or name)

	parent[name] = filterOption
	parent["Linked" .. name] = filterOption.Link


	filterOption.Link:SetScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]["Linked" .. name] = self:GetChecked()

		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	for i = 1, 2, 1 do
		local currentName = i == 1 and minName or maxName

		local currentSpinner = filterOption[i == 1 and "Minimum" or "Maximum"]

		currentSpinner:SetWidth(21)
		currentSpinner:SetMinMaxValues(range ~= nil and range or 0, 40)
		
		currentSpinner:SetScript("OnTextChanged", function(self, userInput)
			if(userInput) then
				local spinnerValue = self:GetNumber()

				if(spinnerValue) then

					local currentPanel = LFGListFrame.activePanel:GetDebugName()
					local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

					self:SetValue(spinnerValue)

					if(i == 1) then
						if(parent[maxName]:GetValue() < spinnerValue) then
							parent[maxName]:SetValue(spinnerValue)
							MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][maxName] = spinnerValue

						end

					else
						if(parent[minName]:GetValue() > spinnerValue) then
							parent[minName]:SetValue(spinnerValue)
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

		currentSpinner.DecrementButton:SetScript("OnMouseDown", function(self)
			currentSpinner:Decrement()

			local spinnerValue = currentSpinner:GetValue()

			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

			if(parent[minName]:GetValue() > spinnerValue) then
				parent[minName]:SetValue(spinnerValue)
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][minName] = spinnerValue

			end

			currentSpinner:ClearFocus()

			convertFiltersToAdvancedBlizzardFilters()
		
			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end
		end)

		currentSpinner.IncrementButton:SetScript("OnMouseDown", function()
			currentSpinner:Increment()

			local spinnerValue = currentSpinner:GetValue()

			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

			if(parent[maxName]:GetValue() < spinnerValue) then
				parent[maxName]:SetValue(spinnerValue)
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][maxName] = spinnerValue

			end

			currentSpinner:ClearFocus()

			convertFiltersToAdvancedBlizzardFilters()
		
			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end
		end)
	end

	return filterOption

end

miog.addDualNumericSpinnerToFilterFrame = addDualNumericSpinnerToFilterFrame

local function addDualNumericFieldsToFilterFrame(parent, name)
	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualFieldTemplate")
	filterOption:SetSize(220, 25)

	--local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", parent, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
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

	parent[name] = filterOption

	filterOption.Name:SetText(name)

	local minName = "min" .. name
	local maxName = "max" .. name

	for i = 1, 2, 1 do
		local currentName = i == 1 and minName or maxName

		local currentField = filterOption[i == 1 and "Minimum" or "Maximum"]
		currentField:SetAutoFocus(false)
		currentField.autoFocus = false
		currentField:SetNumeric(true)
		currentField:SetMaxLetters(4)
		currentField:HookScript("OnTextChanged", function(self, ...)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			
			local text = tonumber(self:GetText())
			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
		
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = text ~= nil and text or 0

			convertFiltersToAdvancedBlizzardFilters()

			if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][name]) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end

		end)
	end

	return filterOption

end

miog.addDualNumericFieldsToFilterFrame = addDualNumericFieldsToFilterFrame

local function updateDungeonCheckboxes()
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
			local currentButton = miog.FilterPanel.IndexedOptions.Dungeons.Buttons[k]

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
			local currentButton = miog.FilterPanel.IndexedOptions.Raids.Buttons[k]

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

local function addRaidCheckboxes(parent)	
	local raidPanel = miog.createBasicFrame("persistent", "BackdropTemplate", parent, parent:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	raidPanel.Buttons = {}

	parent.Raids = raidPanel

	local raidOptionsButton = addOptionToFilterFrame(raidPanel, nil, "Raid options", "filterForRaids")
	raidOptionsButton:SetPoint("TOPLEFT", raidPanel, "TOPLEFT", 0, 0)
	raidPanel.Option = raidOptionsButton

	local raidPanelFirstRow = miog.createBasicFrame("persistent", "BackdropTemplate", raidPanel, raidPanel:GetWidth(), raidPanel:GetHeight() / 2)
	raidPanelFirstRow:SetPoint("TOPLEFT", raidOptionsButton, "BOTTOMLEFT")

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

local function addDungeonCheckboxes(parent)	
	local dungeonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", parent, 220, 72)
	dungeonPanel.Buttons = {}

	parent.Dungeons = dungeonPanel

	local dungeonOptionsButton = addOptionToFilterFrame(dungeonPanel, nil, "Dungeon options", "filterForDungeons")
	dungeonOptionsButton:SetPoint("TOPLEFT", dungeonPanel, "TOPLEFT", 0, 0)
	dungeonPanel.Option = dungeonOptionsButton

	local dungeonPanelFirstRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), 24)
	dungeonPanelFirstRow:SetPoint("TOPLEFT", dungeonOptionsButton, "BOTTOMLEFT")

	local dungeonPanelSecondRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), 24)
	dungeonPanelSecondRow:SetPoint("TOPLEFT", dungeonPanelFirstRow, "BOTTOMLEFT")

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
		local difficultyDropDown = miog.FilterPanel.IndexedOptions.Difficulty.Dropdown
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
		--miog.FilterPanel.SearchPanelOptions:Show()
		
		miog.FilterPanel.IndexedOptions.Score:SetShown(categoryID == 2 and true or false)
		miog.FilterPanel.IndexedOptions.BossKills:SetShown(categoryID == 3 and true or false)
		--miog.FilterPanel.IndexedOptions.Divider:SetShown((categoryID == 2 or categoryID == 3) and true or false)
		miog.FilterPanel.IndexedOptions.Dungeons:SetShown(categoryID == 2 and true or false)
		--miog.FilterPanel.IndexedOptions.filterForDungeons:SetShown(categoryID == 2 and true or false)
		--miog.FilterPanel.IndexedOptions.RaidOptionsButton:SetShown(categoryID == 3 and true or false)
		miog.FilterPanel.IndexedOptions.Raids:SetShown(categoryID == 3 and true or false)
		--miog.FilterPanel.IndexedOptions.affixFitButton

	else
		
		miog.FilterPanel.IndexedOptions.ScoreField:Hide()
		miog.FilterPanel.IndexedOptions.BossKillsSpinner:Hide()
		miog.FilterPanel.IndexedOptions.Divider:Hide()
		miog.FilterPanel.IndexedOptions.DungeonOptionsButton:Hide()
		miog.FilterPanel.IndexedOptions.DungeonPanel:Hide()
		miog.FilterPanel.IndexedOptions.RaidOptionsButton:Hide()
		miog.FilterPanel.IndexedOptions.RaidPanel:Hide()
	
	end

	miog.FilterPanel.IndexedOptions:MarkDirty()


	local isDungeon = categoryID == 2
	local isRaid = categoryID == 3
	local isPvp = categoryID == 4 or categoryID == 7

	if(categoryID) then
		if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID] == nil) then
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID] = miog.resetSpecificFilterToDefault(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID])
			
		end

		updateFilterDifficulties(reset)

		for i = 1, 3, 1 do
			miog.FilterPanel.IndexedOptions.Roles.Buttons[i]:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"])
		end

		--for k, v in pairs(miog.FilterPanel.IndexedOptions) do
		--	if(v.Button and v.Button:GetObjectType() == "CheckButton") then
		--		v.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][k])
		--	end
		--end

		miog.FilterPanel.IndexedOptions.Difficulty:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDifficulty)

		miog.FilterPanel.IndexedOptions.LinkedTanks:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedTanks)
		miog.FilterPanel.IndexedOptions.LinkedHealers:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedHealers)
		miog.FilterPanel.IndexedOptions.LinkedTanks:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedDamager)

		miog.FilterPanel.IndexedOptions.Tanks.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForTanks)
		miog.FilterPanel.IndexedOptions.Tanks.Minimum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minTanks)
		miog.FilterPanel.IndexedOptions.Tanks.Maximum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxTanks)

		miog.FilterPanel.IndexedOptions.Healers.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForHealers)
		miog.FilterPanel.IndexedOptions.Healers.Minimum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minHealers)
		miog.FilterPanel.IndexedOptions.Healers.Maximum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxHealers)

		miog.FilterPanel.IndexedOptions.Damager.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDamager)
		miog.FilterPanel.IndexedOptions.Damager.Minimum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minDamager)
		miog.FilterPanel.IndexedOptions.Damager.Maximum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxDamager)

		miog.FilterPanel.IndexedOptions.Score.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForScore)
		miog.FilterPanel.IndexedOptions.Score.Minimum:SetNumber(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minScore)
		miog.FilterPanel.IndexedOptions.Score.Maximum:SetNumber(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxScore)

		miog.FilterPanel.IndexedOptions.BossKills.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForBossKills)
		miog.FilterPanel.IndexedOptions.BossKills.Minimum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minBossKills)
		miog.FilterPanel.IndexedOptions.BossKills.Maximum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxBossKills)

		--filterPanel.FilterOptions["filterForClassSpecs"].Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForClassSpecs)
		miog.FilterPanel.ClassSpecOptions.Option.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForClassSpecs)

		for classIndex, classEntry in ipairs(miog.CLASSES) do
			local currentClassPanel = miog.FilterPanel.ClassSpecOptions.Panels[classIndex]

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
			miog.FilterPanel.IndexedOptions.Dungeons.Option.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDungeons)

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
					miog.FilterPanel.IndexedOptions.Dungeons.Buttons[k]:SetChecked(reset or not notChecked)
				end
			end
		elseif(categoryID == 3) then
			local sortedExpansionRaids = {}
			miog.FilterPanel.IndexedOptions.Raids.Option.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRaids)

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
					miog.FilterPanel.IndexedOptions.Raids.Buttons[k]:SetChecked(reset or checked)
				end
			end
		end
	end


	miog.FilterPanel.IndexedOptions:MarkDirty()
	miog.FilterPanel:MarkDirty()
end

miog.setupFiltersForActivePanel = setupFiltersForActivePanel

local function createClassSpecFilters(parent)
	--miog.FilterPanel.FilterOptions.ClassPanels = {}
	local classSpecOption = addOptionToFilterFrame(parent, nil, "Class / spec", "filterForClassSpecs")
	classSpecOption.layoutIndex = 1
	miog.FilterPanel.ClassSpecOptions.Option = classSpecOption
	--classSpecOption:SetPoint("TOPLEFT", miog.FilterPanel.ClassSpecOptions, "TOPLEFT")

	parent.Panels = {}

	for classIndex, classEntry in ipairs(miog.CLASSES) do
		local classPanel = CreateFrame("Frame", nil, parent, "MIOG_ClassSpecFilterRowTemplate")
		classPanel.layoutIndex = classIndex + 1
		classPanel:SetWidth(parent:GetWidth())

		local r, g, b = GetClassColor(classEntry.name)
		miog.createFrameBorder(classPanel, 1, r, g, b, 0.9)
		classPanel:SetBackdropColor(r, g, b, 0.6)

		classPanel.Class.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/classIcons/" .. classEntry.name .. "_round.png")
		classPanel.Class.rightPadding = 8

		--miog.FilterPanel.FilterOptions.ClassPanels[classIndex] = classPanel
		parent.Panels[classIndex] = classPanel
		classPanel.SpecFrames = {}

		for specIndex, specID in pairs(classEntry.specs) do
			local specEntry = miog.SPECIALIZATIONS[specID]

			local currentSpec = CreateFrame("Frame", nil, classPanel, "MIOG_ClassSpecSingleOptionTemplate")
			currentSpec.layoutIndex = specIndex + 1
			--currentSpec:SetSize(36, 20)
			currentSpec.rightPadding = 8
			currentSpec.Texture:SetTexture(specEntry.icon)

			classPanel.SpecFrames[specID] = currentSpec

		end
	end

	miog.FilterPanel.IndexedOptions:MarkDirty()
	miog.FilterPanel:MarkDirty()

	return parent.Panels[1], parent.Panels[#parent.Panels]
end

local function addRolePanel(parent)
	local roleFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", parent, 150, 20)
	roleFilterPanel.Buttons = {}

	local lastTexture = nil

	parent.Roles = roleFilterPanel

	for i = 1, 3, 1 do
		local toggleRoleButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", roleFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
		toggleRoleButton:SetNormalAtlas("checkbox-minimal")
		toggleRoleButton:SetPushedAtlas("checkbox-minimal")
		toggleRoleButton:SetCheckedTexture("checkmark-minimal")
		toggleRoleButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		toggleRoleButton:SetPoint("LEFT", lastTexture or roleFilterPanel, lastTexture and "RIGHT" or "LEFT", lastTexture and 7 or 0, 0)
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

		roleFilterPanel.Buttons[i] = toggleRoleButton

		lastTexture = roleTexture

	end

	miog.FilterPanel.IndexedOptions:MarkDirty()
	miog.FilterPanel:MarkDirty()

	return roleFilterPanel
end

miog.loadFilterPanel = function()
	miog.FilterPanel = CreateFrame("Frame", "MythicIOGrabber_FilterPanel", miog.Plugin, "MIOG_FilterPanel") ---@class Frame
	miog.FilterPanel:SetPoint("TOPLEFT", miog.MainFrame, "TOPRIGHT", 5, 0)
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

	local firstClassPanel, lastClassPanel = createClassSpecFilters(miog.FilterPanel.ClassSpecOptions)
	--firstClassPanel:SetPoint("TOPLEFT", classSpecOption, "BOTTOMLEFT")

	local rolePanel = addRolePanel(miog.FilterPanel.IndexedOptions)
	rolePanel.layoutIndex = 1
	
	local partyFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Party fit", "partyFit")
	partyFitButton.layoutIndex = 2
	--partyFitButton:SetPoint("TOPLEFT", lastClassPanel, "BOTTOMLEFT", 0, 0)
	
	local ressFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Ress fit", "ressFit")
	ressFitButton.layoutIndex = 3
	--ressFitButton:SetPoint("TOPLEFT", partyFitButton, "BOTTOMLEFT", 0, 0)

	local lustFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Lust fit", "lustFit")
	lustFitButton.layoutIndex = 4
	--lustFitButton:SetPoint("TOPLEFT", ressFitButton, "BOTTOMLEFT", 0, 0)
	--affixFitButton:SetPoint("TOPLEFT", lustFitButton, "BOTTOMLEFT", 0, 0)
	
	local hideHardDecline = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Hide hard decline", "hardDecline")
	--hideHardDecline:SetPoint("TOPLEFT", miog.FilterPanel.SearchPanelOptions, "TOPLEFT", 0, 0)
	hideHardDecline.layoutIndex = 5

	local dropdownOptionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", miog.FilterPanel.IndexedOptions, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	dropdownOptionButton:SetNormalAtlas("checkbox-minimal")
	dropdownOptionButton:SetPushedAtlas("checkbox-minimal")
	dropdownOptionButton:SetCheckedTexture("checkmark-minimal")
	dropdownOptionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	dropdownOptionButton.layoutIndex = 6
	--dropdownOptionButton:SetPoint("TOPLEFT", hideHardDecline, "BOTTOMLEFT", 0, 0)
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
	miog.FilterPanel.IndexedOptions.Difficulty = dropdownOptionButton

	local optionDropDown = Mixin(CreateFrame("Frame", nil, miog.FilterPanel.IndexedOptions, "MIOG_DropDownMenu"), SlickDropDown)
	optionDropDown:OnLoad()
	optionDropDown:SetWidth(miog.FilterPanel.fixedWidth - dropdownOptionButton:GetWidth() - 5)
	optionDropDown:SetHeight(25)
	optionDropDown:SetPoint("LEFT", dropdownOptionButton, "RIGHT")
	optionDropDown:SetText("Choose a difficulty")
	miog.FilterPanel.IndexedOptions.Difficulty.Dropdown = optionDropDown

	local tanksSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "Tanks")
	tanksSpinner.layoutIndex = 7
	--tanksSpinner:SetPoint("TOPLEFT", dropdownOptionButton, "BOTTOMLEFT", 0, 0)

	local healerSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "Healers")
	healerSpinner.layoutIndex = 8
	--healerSpinner:SetPoint("TOPLEFT", tanksSpinner, "BOTTOMLEFT", 0, 0)

	local damagerSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "Damager")
	damagerSpinner.layoutIndex = 9
	--damagerSpinner:SetPoint("TOPLEFT", healerSpinner, "BOTTOMLEFT", 0, 0)

	local scoreField = miog.addDualNumericFieldsToFilterFrame(miog.FilterPanel.IndexedOptions, "Score")
	scoreField.layoutIndex = 10
	--scoreField:SetPoint("TOPLEFT", damagerSpinner, "BOTTOMLEFT", 0, 0)

	local bossKillsSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "BossKills", "Kills")
	bossKillsSpinner.layoutIndex = 11
	bossKillsSpinner.Link:Hide()
	--bossKillsSpinner:SetPoint("TOPLEFT", damagerSpinner, "BOTTOMLEFT", 0, 0)

	local divider = miog.createBasicTexture("persistent", nil, miog.FilterPanel.IndexedOptions, miog.FilterPanel.fixedWidth, 1, "BORDER")
	divider:SetAtlas("UI-LFG-DividerLine")
	divider.layoutIndex = 12

	local dungeonPanel = miog.addDungeonCheckboxes(miog.FilterPanel.IndexedOptions)
	dungeonPanel.layoutIndex = 13
	--dungeonPanel:SetPoint("TOPLEFT", dungeonOptionsButton, "BOTTOMLEFT", 0, 0)

	local raidPanel = miog.addRaidCheckboxes(miog.FilterPanel.IndexedOptions)
	raidPanel.layoutIndex = 13
	--raidPanel:SetPoint("TOPLEFT", raidOptionsButton, "BOTTOMLEFT", 0, 0)
	--raidPanel.OptionsButton = raidOptionsButton

	--local affixFitButton = addOptionToFilterFrame(miog.FilterPanel.StandardOptions, nil, "Affix fit", "affixFit")
	--affixFitButton.layoutIndex = 5

	miog.FilterPanel.IndexedOptions:MarkDirty()
	miog.FilterPanel:MarkDirty()
	--divider:SetPoint("BOTTOMLEFT", scoreField, "BOTTOMLEFT", 0, -5)
end
