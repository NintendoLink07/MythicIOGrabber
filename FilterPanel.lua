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
				v.filterForScore = v.minScore > 0 and true

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

		miogFilters.minimumRating = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].minScore
		miogFilters.hasHealer = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].minHealers > 0 and true or false
		miogFilters.hasTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].minTanks > 0 and true or false

		miogFilters.difficultyNormal = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].difficultyID == DifficultyUtil.ID.DungeonNormal
		miogFilters.difficultyHeroic = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].difficultyID == DifficultyUtil.ID.DungeonHeroic
		miogFilters.difficultyMythic = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].difficultyID == DifficultyUtil.ID.DungeonMythic
		miogFilters.difficultyMythicPlus = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].difficultyID == DifficultyUtil.ID.DungeonChallenge

		local _, id = UnitClassBase("player")

		miogFilters.needsMyClass = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].classSpec.class[id] == false
		miogFilters.needsTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].filterForRoles["TANK"] == false
		miogFilters.needsHealer = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].filterForRoles["HEALER"] == false
		miogFilters.needsDamage = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][LFGListFrame.CategorySelection.selectedCategory].filterForRoles["DAMAGER"] == false

		local blizzardFilter = C_LFGList.GetAdvancedFilter()
		miogFilters.activities = blizzardFilter.activities
		C_LFGList.SaveAdvancedFilter(miogFilters)
	end
end

local function addOptionToFilterFrame(parent, _, text, name)
	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOption")
	filterOption:SetWidth(parent:GetWidth())
	filterOption:SetHeight(25)
	filterOption.Button:HookScript("OnClick", function(self)
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory][name] = self:GetChecked()

		convertFiltersToAdvancedBlizzardFilters()
		
		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterOption.Name:SetText(text)

	miog.SidePanel.Container.FilterPanel.Panel.FilterOptions[name] = filterOption

	return filterOption
end

miog.addOptionToFilterFrame = addOptionToFilterFrame

local function addNumericSpinnerToFilterFrame(text, name)
	local numericSpinner = Mixin(miog.createBasicFrame("persistent", "InputBoxTemplate", miog.searchPanel.FilterPanel.FilterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 5, miog.C.INTERFACE_OPTION_BUTTON_SIZE), NumericInputSpinnerMixin)
	numericSpinner:SetAutoFocus(false)
	numericSpinner:SetNumeric(true)
	numericSpinner:SetMaxLetters(1)
	numericSpinner:SetMinMaxValues(0, 9)
	numericSpinner:SetValue(MIOG_SavedSettings and MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory][name] or 0)

	local decrementButton = miog.createBasicFrame("persistent", "UIButtonTemplate", numericSpinner, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	decrementButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Up")
	decrementButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Down")
	decrementButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Disabled")
	decrementButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
	decrementButton:SetPoint("TOPLEFT", miog.searchPanel.FilterPanel.FilterFrame, "BOTTOMLEFT", 0, -5)
	decrementButton:SetScript("OnMouseDown", function()
		if decrementButton:IsEnabled() then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			numericSpinner:StartDecrement()

		end
	end)
	decrementButton:SetScript("OnMouseUp", function()
		numericSpinner:EndIncrement()
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].table[name] = numericSpinner:GetValue()
		numericSpinner:ClearFocus()
		
		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end

	end)

	numericSpinner:SetPoint("LEFT", decrementButton, "RIGHT", 6, 0)

	local incrementButton = miog.createBasicFrame("persistent", "UIButtonTemplate", numericSpinner, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	incrementButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Up")
	incrementButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Down")
	incrementButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Disabled")
	incrementButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
	incrementButton:SetPoint("LEFT", numericSpinner, "RIGHT")
	incrementButton:SetScript("OnMouseDown", function()
		if incrementButton:IsEnabled() then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			numericSpinner:StartIncrement()
		end
	end)
	incrementButton:SetScript("OnMouseUp", function()
		numericSpinner:EndIncrement()
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].table[name] = numericSpinner:GetValue()
		numericSpinner:ClearFocus()

		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end

	end)

	miog.searchPanel.FilterPanel.FilterFrame[name] = numericSpinner

	local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.FilterPanel.FilterFrame)
	optionString:SetPoint("LEFT", incrementButton, "RIGHT")
	optionString:SetText(text)

end

local function addDualNumericSpinnerToFilterFrame(parent, name, range)
	local filterPanel = miog.SidePanel.Container.FilterPanel

	local minName = "min" .. name
	local maxName = "max" .. name

	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualSpinnerTemplate")
	filterOption:SetSize(parent:GetWidth(), 25)
	filterOption.Button:HookScript("OnClick", function(self)
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory]["filterFor" .. name] = self:GetChecked()

		convertFiltersToAdvancedBlizzardFilters()

		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterOption.Name:SetText(name)

	filterPanel.Panel.FilterOptions["filterFor" .. name] = filterOption.Button

	for i = 1, 2, 1 do
		local currentName = i == 1 and minName or maxName

		filterOption["Spinner" .. i]:SetWidth(15)
		filterOption["Spinner" .. i]:SetMinMaxValues(range ~= nil and range or 0, 9)
		--filterOption["Spinner" .. i]:SetValue(MIOG_SavedSettings and MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].table[i == 1 and minName or maxName] or 0)

		filterOption["Spinner" .. i].DecrementButton:SetScript("OnMouseDown", function()
			--PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			filterOption["Spinner" .. i]:Decrement()

			local spinnerValue = filterOption["Spinner" .. i]:GetValue()

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory][currentName] = spinnerValue

			if(filterPanel.Panel.FilterOptions[minName]:GetValue() > spinnerValue) then
				filterPanel.Panel.FilterOptions[minName]:SetValue(spinnerValue)
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory][minName] = spinnerValue

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
			--PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			filterOption["Spinner" .. i]:Increment()

			local spinnerValue = filterOption["Spinner" .. i]:GetValue()

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory][currentName] = spinnerValue

			if(filterPanel.Panel.FilterOptions[maxName]:GetValue() < spinnerValue) then
				filterPanel.Panel.FilterOptions[maxName]:SetValue(spinnerValue)
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory][maxName] = spinnerValue

			end

			filterOption["Spinner" .. i]:ClearFocus()

			convertFiltersToAdvancedBlizzardFilters()
		
			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end
		end)

		filterPanel.Panel.FilterOptions[currentName] = filterOption["Spinner" .. i]
	end

	return filterOption

end

miog.addDualNumericSpinnerToFilterFrame = addDualNumericSpinnerToFilterFrame

local function addDualNumericFieldsToFilterFrame(parent, name)
	local filterPanel = miog.SidePanel.Container.FilterPanel

	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", parent, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	--optionButton:SetPoint("TOPLEFT", lastFilterOption, "BOTTOMLEFT", 0, -5)
	optionButton:RegisterForClicks("LeftButtonDown")
	--optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].table["filterFor" .. name] or false)
	optionButton:HookScript("OnClick", function()
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory]["filterFor" .. name] = optionButton:GetChecked()

		convertFiltersToAdvancedBlizzardFilters()
		
		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterPanel.Panel.FilterOptions["filterFor" .. name] = optionButton

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
		--numericField:SetText(MIOG_SavedSettings and MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].table[i == 1 and minName or maxName] or 0)
		numericField:HookScript("OnTextChanged", function(self, ...)
			local text = tonumber(self:GetText())
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory][currentName] = text ~= nil and text or 0

			convertFiltersToAdvancedBlizzardFilters()

			if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory]["filterFor" .. name]) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end

		end)
		

		filterPanel.Panel.FilterOptions[currentName] = numericField

		lastNumericField = numericField
	end

	return optionButton

end

miog.addDualNumericFieldsToFilterFrame = addDualNumericFieldsToFilterFrame

local function updateDungeonCheckboxes()
	local filterPanel = miog.SidePanel.Container.FilterPanel
	local sortedSeasonDungeons = {}

	local mapTable = C_ChallengeMode.GetMapTable()

	if(mapTable) then
		for _, v in ipairs(mapTable) do
			local activityInfo = miog.ACTIVITY_INFO[miog.CHALLENGE_MODE[v]]
			sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}

		end

		table.sort(sortedSeasonDungeons, function(k1, k2)
			return k1.name < k2.name
		end)

		for k, activityEntry in ipairs(sortedSeasonDungeons) do
			local currentButton = filterPanel.Panel.FilterOptions.DungeonPanel.Buttons[k]

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
	local filterPanel = miog.SidePanel.Container.FilterPanel
	local sortedExpansionRaids = {}

	for k, v in pairs(miog.ACTIVITY_INFO) do
		if(v.expansionLevel == (GetAccountExpansionLevel()-1) and v.difficultyID == miog.RAID_DIFFICULTIES[3]) then
			sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = v.groupFinderActivityGroupID, name = v.shortName}
		end

	end

	table.sort(sortedExpansionRaids, function(k1, k2)
		return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID
	end)

	for k, activityEntry in ipairs(sortedExpansionRaids) do
		--local checked = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3] and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID]
		--currentButton:SetChecked(checked)
		local currentButton = filterPanel.Panel.FilterOptions.RaidPanel.Buttons[k]

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

miog.updateRaidCheckboxes = updateRaidCheckboxes

local function addRaidCheckboxes()
	local filterPanel = miog.SidePanel.Container.FilterPanel
	
	local raidPanel = miog.createBasicFrame("persistent", "BackdropTemplate", miog.searchPanel.PanelFilters, miog.searchPanel.PanelFilters:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	raidPanel.Buttons = {}

	filterPanel.Panel.FilterOptions.RaidPanel = raidPanel

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
	local filterPanel = miog.SidePanel.Container.FilterPanel
	
	local dungeonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", miog.searchPanel.PanelFilters, miog.searchPanel.PanelFilters:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	dungeonPanel.Buttons = {}

	filterPanel.Panel.FilterOptions.DungeonPanel = dungeonPanel

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
		
		dungeonPanel.Buttons[i] = optionButton
	
		local optionString = miog.createBasicFontString("persistent", 12, dungeonPanel)
		optionString:SetPoint("LEFT", optionButton, "RIGHT")

		optionButton.FontString = optionString

		counter = counter + 1
	end

	return dungeonPanel
end

miog.addDungeonCheckboxes = addDungeonCheckboxes

local function updateFilterDifficulties()
	if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()]) then
		local difficultyDropDown = miog.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown
		difficultyDropDown:ResetDropDown()

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory] = MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory] or MIOG_SavedSettings.filterOptions.table.default

		local isPvp = LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7 or LFGListFrame.SearchPanel.categoryID == 8 or LFGListFrame.SearchPanel.categoryID == 9
		local isDungeon = LFGListFrame.SearchPanel.categoryID == 2
		local isRaid = LFGListFrame.SearchPanel.categoryID == 3

		for k, v in ipairs(isRaid and miog.RAID_DIFFICULTIES or isPvp and {6, 7} or miog.DUNGEON_DIFFICULTIES) do
			local info = {}
			info.entryType = "option"
			info.text = isPvp and (v == 6 and "2v2" or "3v3") or miog.DIFFICULTY_ID_INFO[v].name
			info.level = 1
			info.value = v
			info.func = function()
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].difficultyID = v

				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end
			
			difficultyDropDown:CreateEntryFrame(info)

		end

		difficultyDropDown:MarkDirty()
		difficultyDropDown.List:MarkDirty()

		local success = difficultyDropDown:SelectFirstFrameWithValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].difficultyID)
		
		if(not success) then
			difficultyDropDown:SelectFrameAtLayoutIndex(1)

		end
	end
end

local function setupFiltersForActivePanel(reset)
	local isDungeon = LFGListFrame.CategorySelection.selectedCategory == 2
	local isRaid =  LFGListFrame.CategorySelection.selectedCategory == 3
	local isPvp =  LFGListFrame.CategorySelection.selectedCategory == 4 or LFGListFrame.CategorySelection.selectedCategory == 7

	miog.SidePanel:SetSize(230, (miog.F.LITE_MODE and 430 or miog.pveFrame2:GetHeight()) * (LFGListFrame.activePanel:GetDebugName() == "LFGListFrame.SearchPanel" and (isDungeon or isRaid) and 1.45 or isPvp and 1.25 or 1))
	local container = miog.SidePanel.Container
	local filterPanel = container.FilterPanel

	if(LFGListFrame.CategorySelection.selectedCategory) then
		if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory] == nil) then
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory] = MIOG_SavedSettings.filterOptions.table.default
			
		end

		updateFilterDifficulties()

		for i = 1, 3, 1 do
			filterPanel.Panel.FilterOptions.Roles.RoleButtons[i]:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"])
		end

		for k, v in pairs(filterPanel.Panel.FilterOptions) do
			if(v.Button and v.Button:GetObjectType() == "CheckButton") then
				v.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory][k])
			end
		end

		filterPanel.Panel.FilterOptions.filterForTanks:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForTanks)
		filterPanel.Panel.FilterOptions.minTanks:SetText(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].minTanks)
		filterPanel.Panel.FilterOptions.maxTanks:SetText(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].maxTanks)

		filterPanel.Panel.FilterOptions.filterForHealers:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForHealers)
		filterPanel.Panel.FilterOptions.minHealers:SetText(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].minHealers)
		filterPanel.Panel.FilterOptions.maxHealers:SetText(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].maxHealers)

		filterPanel.Panel.FilterOptions.filterForDamager:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForDamager)
		filterPanel.Panel.FilterOptions.minDamager:SetText(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].minDamager)
		filterPanel.Panel.FilterOptions.maxDamager:SetText(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].maxDamager)

		filterPanel.Panel.FilterOptions.filterForScore:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForScore)
		filterPanel.Panel.FilterOptions.minScore:SetText(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].minScore)
		filterPanel.Panel.FilterOptions.maxScore:SetText(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].maxScore)

		--filterPanel.Panel.FilterOptions["filterForClassSpecs"].Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForClassSpecs)

		for classIndex, classEntry in ipairs(miog.CLASSES) do
			local currentClassPanel = filterPanel.Panel.FilterOptions.ClassPanels[classIndex]

			if(MIOG_SavedSettings and MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec) then
				if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.class[classIndex] ~= nil) then
					currentClassPanel.Class.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.class[classIndex])
					
					if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.class[classIndex] == false) then
						container.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))
					end

				else
					currentClassPanel.Class.Button:SetChecked(true)

				end

			else
				currentClassPanel.Class.Button:SetChecked(true)

			end
			
			currentClassPanel.Class.Button:SetScript("OnClick", function()
				local state = currentClassPanel.Class.Button:GetChecked()

				for specIndex, specFrame in pairs(currentClassPanel.SpecFrames) do
				--for i = 1, 4, 1 do

					if(state) then
						specFrame.Button:SetChecked(true)

					else
						specFrame.Button:SetChecked(false)

					end

					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.spec[specIndex] = state
				end

				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.class[classIndex] = state

				if(not miog.checkForActiveFilters(filterPanel.Panel)) then
					container.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

				else
					container.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

				end

				convertFiltersToAdvancedBlizzardFilters()

				if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForClassSpecs) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end
			end)

			for specIndex, specID in pairs(classEntry.specs) do
				local currentSpecFrame = currentClassPanel.SpecFrames[specID]
				if(MIOG_SavedSettings and MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec) then
					if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.spec[specID] ~= nil) then
						currentSpecFrame.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.spec[specID])

						if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.spec[specID]) then
							container.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))
						end

					else
						currentSpecFrame.Button:SetChecked(true)

					end

				else
					currentSpecFrame.Button:SetChecked(true)

				end
				
				currentSpecFrame.Button:SetScript("OnClick", function()
					local state = currentSpecFrame.Button:GetChecked()

					if(state) then
						currentClassPanel.Class.Button:SetChecked(true)

						if(not miog.checkForActiveFilters(filterPanel.Panel)) then
							container.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

						end

					else
						container.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

					end

					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].classSpec.spec[specID] = state

					convertFiltersToAdvancedBlizzardFilters()

					if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForClassSpecs) then
						if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
							miog.checkSearchResultListForEligibleMembers()
				
						elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
							C_LFGList.RefreshApplicants()
				
						end
					end

				end)
			end
		end

		if(LFGListFrame.CategorySelection.selectedCategory == 3) then
			local sortedExpansionRaids = {}

			for k, v in pairs(miog.ACTIVITY_INFO) do
				if(v.expansionLevel == (GetAccountExpansionLevel()-1) and v.difficultyID == miog.RAID_DIFFICULTIES[3]) then
					sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = v.groupFinderActivityGroupID, name = v.shortName}
				end

			end

			table.sort(sortedExpansionRaids, function(k1, k2)
				return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID
			end)

			for k, activityEntry in ipairs(sortedExpansionRaids) do
				local checked = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID]
				--currentButton:SetChecked(checked)
				local currentButton = filterPanel.Panel.FilterOptions.RaidPanel.Buttons[k]:SetChecked(checked)
			end
		elseif(LFGListFrame.CategorySelection.selectedCategory == 2) then

			local sortedSeasonDungeons = {}

			local mapTable = C_ChallengeMode.GetMapTable()

			if(mapTable) then
				for _, v in ipairs(mapTable) do
					local activityInfo = miog.ACTIVITY_INFO[miog.CHALLENGE_MODE[v]]
					sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}

				end

				table.sort(sortedSeasonDungeons, function(k1, k2)
					return k1.name < k2.name
				end)

				for k, activityEntry in ipairs(sortedSeasonDungeons) do
					local checked = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2].dungeons[activityEntry.groupFinderActivityGroupID]
					local currentButton = filterPanel.Panel.FilterOptions.DungeonPanel.Buttons[k]
					currentButton:SetChecked(checked)
				end
			end
		end
	end
end

miog.setupFiltersForActivePanel = setupFiltersForActivePanel

local function createClassSpecFilters(parent)
	local container = miog.SidePanel.Container

	parent.Uncheck:SetScript("OnClick", function()

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory] = MIOG_SavedSettings.filterOptions.table.default

		setupFiltersForActivePanel(true)

		container.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

		convertFiltersToAdvancedBlizzardFilters()

		miog.checkSearchResultListForEligibleMembers()
	end)

	parent.FilterOptions.ClassPanels = {}

	for classIndex, classEntry in ipairs(miog.CLASSES) do
		local classPanel = CreateFrame("Frame", nil, parent, "MIOG_ClassSpecFilterRowTemplate")

		classPanel:SetSize(parent:GetWidth(), 20)

		if(classIndex > 1) then
			classPanel:SetPoint("TOPLEFT", parent.FilterOptions.ClassPanels[classIndex-1] or parent, parent.FilterOptions.ClassPanels[classIndex-1] and "BOTTOMLEFT" or "TOPLEFT", 0, -1)
		end

		local r, g, b = GetClassColor(classEntry.name)
		miog.createFrameBorder(classPanel, 1, r, g, b, 0.9)
		classPanel:SetBackdropColor(r, g, b, 0.6)

		classPanel.Class.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/classIcons/" .. classEntry.name .. "_round.png")

		parent.FilterOptions.ClassPanels[classIndex] = classPanel
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

	return parent.FilterOptions.ClassPanels[1], parent.FilterOptions.ClassPanels[#miog.CLASSES]
end

local function addRolePanel(parent)
	local container = miog.SidePanel.Container

	local roleFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", parent, 150, 20)
	--roleFilterPanel:SetPoint("LEFT", filterForRoleButton.Name, "RIGHT")
	roleFilterPanel.RoleButtons = {}

	local lastTexture = nil

	parent.FilterOptions.Roles = roleFilterPanel

	for i = 1, 3, 1 do
		local toggleRoleButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", roleFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
		toggleRoleButton:SetNormalAtlas("checkbox-minimal")
		toggleRoleButton:SetPushedAtlas("checkbox-minimal")
		toggleRoleButton:SetCheckedTexture("checkmark-minimal")
		toggleRoleButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		toggleRoleButton:SetPoint("LEFT", lastTexture or roleFilterPanel, lastTexture and "RIGHT" or "LEFT", lastTexture and 10 or 0, 0)
		toggleRoleButton:RegisterForClicks("LeftButtonDown")
		--toggleRoleButton:SetChecked(true)

		local roleTexture = miog.createBasicTexture("persistent", nil, roleFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 3, miog.C.APPLICANT_MEMBER_HEIGHT - 3, "ARTWORK")
		roleTexture:SetPoint("LEFT", toggleRoleButton, "RIGHT", 0, 0)

		toggleRoleButton:SetScript("OnClick", function()
			local state = toggleRoleButton:GetChecked()

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"] = state

			if(not miog.checkForActiveFilters(parent)) then
				container.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				container.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

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
	local sidePanel = CreateFrame("Frame", "MythicIOGrabber_SidePanel", miog.MainFrame, "MIOG_SidePanel") ---@class Frame
	sidePanel:SetSize(230, (miog.F.LITE_MODE and 420 or miog.pveFrame2:GetHeight()) * (LFGListFrame.activePanel:GetDebugName() == "searchPanel" and 1.45 or 1))
	sidePanel:SetPoint("TOPLEFT", miog.MainFrame, "TOPRIGHT", miog.F.LITE_MODE and 3 or 0, 0)
	miog.SidePanel = sidePanel

	miog.createFrameBorder(sidePanel.ButtonPanel.FilterButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	sidePanel.ButtonPanel.FilterButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.createFrameBorder(sidePanel.ButtonPanel.LastInvitesButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	sidePanel.ButtonPanel.LastInvitesButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	
	miog.createFrameBorder(sidePanel.Container.TitleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	sidePanel.Container.TitleBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.createFrameBorder(sidePanel.Container.LastInvites.Panel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	
	miog.createFrameBorder(sidePanel.Container.FilterPanel.Panel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	sidePanel.Container.FilterPanel.Panel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local filterPanel = miog.SidePanel.Container.FilterPanel

	filterPanel.Panel.FilterOptions = {}

	local rolePanel = addRolePanel(filterPanel.Panel)
	rolePanel:SetPoint("TOPLEFT", filterPanel.Panel, "TOPLEFT")
	
	local classSpecOption = addOptionToFilterFrame(filterPanel.Panel, nil, "Class / spec", "filterForClassSpecs")
	classSpecOption:SetPoint("TOPLEFT", rolePanel, "BOTTOMLEFT")

	local firstClassPanel, lastClassPanel = createClassSpecFilters(filterPanel.Panel)
	firstClassPanel:SetPoint("TOPLEFT", classSpecOption, "BOTTOMLEFT")
	
	local partyFitButton = miog.addOptionToFilterFrame(filterPanel.Panel, nil, "Party fit", "partyFit")
	partyFitButton:SetPoint("TOPLEFT", lastClassPanel, "BOTTOMLEFT", 0, 0)
	
	local ressFitButton = miog.addOptionToFilterFrame(filterPanel.Panel, nil, "Ress fit", "ressFit")
	ressFitButton:SetPoint("TOPLEFT", partyFitButton, "BOTTOMLEFT", 0, 0)

	local lustFitButton = miog.addOptionToFilterFrame(filterPanel.Panel, nil, "Lust fit", "lustFit")
	lustFitButton:SetPoint("TOPLEFT", ressFitButton, "BOTTOMLEFT", 0, 0)

	filterPanel.Panel.Plugin:SetWidth(filterPanel.Panel:GetWidth())
	filterPanel.Panel.Plugin:SetPoint("TOPLEFT", lustFitButton, "BOTTOMLEFT", 0, 0)

	local searchPanelExtraFilter = miog.createBasicFrame("persistent", "BackdropTemplate", miog.SidePanel.Container.FilterPanel.Panel.Plugin, 220, 200)
	searchPanelExtraFilter:SetPoint("TOPLEFT", miog.SidePanel.Container.FilterPanel.Panel.Plugin, "TOPLEFT")

	miog.searchPanel.PanelFilters = searchPanelExtraFilter

	--miog.createFrameBorder(searchPanelExtraFilter, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	--searchPanelExtraFilter:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local dropdownOptionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", searchPanelExtraFilter, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	dropdownOptionButton:SetNormalAtlas("checkbox-minimal")
	dropdownOptionButton:SetPushedAtlas("checkbox-minimal")
	dropdownOptionButton:SetCheckedTexture("checkmark-minimal")
	dropdownOptionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	dropdownOptionButton:SetPoint("TOPLEFT", searchPanelExtraFilter, "TOPLEFT", 0, 0)
	dropdownOptionButton:HookScript("OnClick", function(self)
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][LFGListFrame.CategorySelection.selectedCategory].filterForDifficulty = self:GetChecked()

			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.checkSearchResultListForEligibleMembers()
	
			elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
				C_LFGList.RefreshApplicants()
	
			end
	end)
	miog.SidePanel.Container.FilterPanel.Panel.FilterOptions.DifficultyButton = dropdownOptionButton

	local optionDropDown = Mixin(CreateFrame("Frame", nil, searchPanelExtraFilter, "MIOG_DropDownMenu"), SlickDropDown)
	optionDropDown:OnLoad()
	optionDropDown.minimumWidth = searchPanelExtraFilter:GetWidth() - dropdownOptionButton:GetWidth() - 3
	optionDropDown.minimumHeight = 15
	optionDropDown:SetPoint("TOPLEFT", dropdownOptionButton, "TOPRIGHT")
	optionDropDown:SetText("Choose a difficulty")
	miog.SidePanel.Container.FilterPanel.Panel.FilterOptions.Dropdown = optionDropDown

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
	dungeonPanel.OptionsButton = dungeonOptionsButton

	local raidOptionsButton = miog.addOptionToFilterFrame(searchPanelExtraFilter, nil, "Raid options", "filterForRaids")
	raidOptionsButton:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, 0)

	local raidPanel = miog.addRaidCheckboxes()
	raidPanel:SetPoint("TOPLEFT", raidOptionsButton, "BOTTOMLEFT", 0, 0)
	raidPanel.OptionsButton = raidOptionsButton
end
