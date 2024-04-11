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

			MIOG_SavedSettings.searchPanel_FilterOptions.table.minScore = blizzardFilters.minimumRating
			MIOG_SavedSettings.searchPanel_FilterOptions.table.minHealers = blizzardFilters.hasHealer == true and 1 or 0
			MIOG_SavedSettings.searchPanel_FilterOptions.table.minTanks = blizzardFilters.hasTank == true and 1 or 0

			MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForTanks = MIOG_SavedSettings.searchPanel_FilterOptions.table.minTanks > 0 and true
			MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForHealers = MIOG_SavedSettings.searchPanel_FilterOptions.table.minHealers > 0 and true
			MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForScore = MIOG_SavedSettings.searchPanel_FilterOptions.table.minScore > 0 and true

			local _, id = UnitClassBase("player")
			MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.class[id] = not (blizzardFilters.needsMyClass == true)
			MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForRoles["TANK"] = not (blizzardFilters.needsTank == true)
			MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForRoles["HEALER"] = not (blizzardFilters.needsHealer == true)
			MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForRoles["DAMAGER"] = not (blizzardFilters.needsDamage == true)
		end
	end
end

miog.convertAdvancedBlizzardFiltersToMIOGFilters = convertAdvancedBlizzardFiltersToMIOGFilters

local function convertFiltersToAdvancedBlizzardFilters()
	if(C_LFGList.GetAdvancedFilter) then
		local miogFilters = {}

		miogFilters.minimumRating = MIOG_SavedSettings.searchPanel_FilterOptions.table.minScore
		miogFilters.hasHealer = MIOG_SavedSettings.searchPanel_FilterOptions.table.minHealers > 0 and true or false
		miogFilters.hasTank = MIOG_SavedSettings.searchPanel_FilterOptions.table.minTanks > 0 and true or false

		miogFilters.difficultyNormal = MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeonDifficultyID == DifficultyUtil.ID.DungeonNormal
		miogFilters.difficultyHeroic = MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeonDifficultyID == DifficultyUtil.ID.DungeonHeroic
		miogFilters.difficultyMythic = MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeonDifficultyID == DifficultyUtil.ID.DungeonMythic
		miogFilters.difficultyMythicPlus = MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeonDifficultyID == DifficultyUtil.ID.DungeonChallenge

		local _, id = UnitClassBase("player")

		miogFilters.needsMyClass = MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.class[id] == false
		miogFilters.needsTank = MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForRoles["TANK"] == false
		miogFilters.needsHealer = MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForRoles["HEALER"] == false
		miogFilters.needsDamage = MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForRoles["DAMAGER"] == false

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
		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[name] = self:GetChecked()

		convertFiltersToAdvancedBlizzardFilters()
		
		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterOption.Name:SetText(text)

	miog.pveFrame2.SidePanel.Container.FilterPanel.Panel.FilterOptions[name] = filterOption

	return filterOption
end

miog.addOptionToFilterFrame = addOptionToFilterFrame

local function addNumericSpinnerToFilterFrame(text, name)
	local numericSpinner = Mixin(miog.createBasicFrame("persistent", "InputBoxTemplate", miog.searchPanel.FilterPanel.FilterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 5, miog.C.INTERFACE_OPTION_BUTTON_SIZE), NumericInputSpinnerMixin)
	numericSpinner:SetAutoFocus(false)
	numericSpinner:SetNumeric(true)
	numericSpinner:SetMaxLetters(1)
	numericSpinner:SetMinMaxValues(0, 9)
	numericSpinner:SetValue(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[name] or 0)

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
		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[name] = numericSpinner:GetValue()
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
		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[name] = numericSpinner:GetValue()
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
	local filterPanel = miog.pveFrame2.SidePanel.Container.FilterPanel

	local minName = "min" .. name
	local maxName = "max" .. name

	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualSpinnerTemplate")
	filterOption:SetSize(parent:GetWidth(), 25)
	filterOption.Button:HookScript("OnClick", function(self)
		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table["filterFor" .. name] = self:GetChecked()

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
		--filterOption["Spinner" .. i]:SetValue(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[i == 1 and minName or maxName] or 0)

		filterOption["Spinner" .. i].DecrementButton:SetScript("OnMouseDown", function()
			--PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			filterOption["Spinner" .. i]:Decrement()

			local spinnerValue = filterOption["Spinner" .. i]:GetValue()

			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentName] = spinnerValue

			if(filterPanel.Panel.FilterOptions[minName]:GetValue() > spinnerValue) then
				filterPanel.Panel.FilterOptions[minName]:SetValue(spinnerValue)
				MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[minName] = spinnerValue

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

			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentName] = spinnerValue

			if(filterPanel.Panel.FilterOptions[maxName]:GetValue() < spinnerValue) then
				filterPanel.Panel.FilterOptions[maxName]:SetValue(spinnerValue)
				MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[maxName] = spinnerValue

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
	local filterPanel = miog.pveFrame2.SidePanel.Container.FilterPanel

	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", parent, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	--optionButton:SetPoint("TOPLEFT", lastFilterOption, "BOTTOMLEFT", 0, -5)
	optionButton:RegisterForClicks("LeftButtonDown")
	--optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table["filterFor" .. name] or false)
	optionButton:HookScript("OnClick", function()
		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table["filterFor" .. name] = optionButton:GetChecked()

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
		--numericField:SetText(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[i == 1 and minName or maxName] or 0)
		numericField:HookScript("OnTextChanged", function(self, ...)
			local text = tonumber(self:GetText())
			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentName] = text ~= nil and text or 0

			convertFiltersToAdvancedBlizzardFilters()

			if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table["filterFor" .. name]) then
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
	local filterPanel = miog.pveFrame2.SidePanel.Container.FilterPanel
	local sortedSeasonDungeons = {}

	if(miog.F.CURRENT_SEASON and miog.SEASONAL_DUNGEONS[miog.F.CURRENT_SEASON]) then
		for _, v in ipairs(miog.SEASONAL_DUNGEONS[miog.F.CURRENT_SEASON]) do
			local activityInfo = miog.ACTIVITY_INFO[v]
			sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}

		end

		table.sort(sortedSeasonDungeons, function(k1, k2)
			return k1.name < k2.name
		end)

		for k, activityEntry in ipairs(sortedSeasonDungeons) do
			local checked = MIOG_SavedSettings and MIOG_SavedSettings["searchPanel_FilterOptions"].table.dungeons[activityEntry.groupFinderActivityGroupID]
			local currentButton = filterPanel.Panel.FilterOptions.DungeonPanel.Buttons[k]
			currentButton:SetChecked(checked)

			currentButton:HookScript("OnClick", function(self)
				MIOG_SavedSettings["searchPanel_FilterOptions"].table.dungeons[activityEntry.groupFinderActivityGroupID] = self:GetChecked()

				if(MIOG_SavedSettings["searchPanel_FilterOptions"].table.dungeons) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end

			end)
			
			currentButton.FontString:SetText(activityEntry.name)
		end

		miog.F.ADDED_DUNGEON_FILTERS = true
	end
end

miog.updateDungeonCheckboxes = updateDungeonCheckboxes

local function updateRaidCheckboxes()
	local filterPanel = miog.pveFrame2.SidePanel.Container.FilterPanel
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
		local checked = MIOG_SavedSettings and MIOG_SavedSettings["searchPanel_FilterOptions"].table.raids[activityEntry.groupFinderActivityGroupID]
		local currentButton = filterPanel.Panel.FilterOptions.RaidPanel.Buttons[k]
		currentButton:SetChecked(checked)

		currentButton:HookScript("OnClick", function(self)
			MIOG_SavedSettings["searchPanel_FilterOptions"].table.raids[activityEntry.groupFinderActivityGroupID] = self:GetChecked()

			if(MIOG_SavedSettings["searchPanel_FilterOptions"].table.raids) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end

		end)
		
		currentButton.FontString:SetText(activityEntry.name)
	end

	--[[if(miog.F.CURRENT_SEASON and miog.SEASONAL_DUNGEONS[miog.F.CURRENT_SEASON]) then
		for _, v in ipairs(miog.SEASONAL_DUNGEONS[miog.F.CURRENT_SEASON]) do
			local activityInfo = C_LFGList.GetActivityInfoTable(v)
			sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {activityID = v, name = miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].shortName}

		end

		table.sort(sortedSeasonDungeons, function(k1, k2)
			return k1.name < k2.name
		end)

		for k, activityEntry in ipairs(sortedSeasonDungeons) do
			local checked = MIOG_SavedSettings and MIOG_SavedSettings["searchPanel_FilterOptions"].table.dungeons[activityEntry.activityID]
			local currentButton = filterPanel.Panel.FilterOptions.DungeonPanel.Buttons[k]
			currentButton:SetChecked(checked)

			currentButton:HookScript("OnClick", function(self)
				MIOG_SavedSettings["searchPanel_FilterOptions"].table.dungeons[activityEntry.activityID] = self:GetChecked()

				if(MIOG_SavedSettings["searchPanel_FilterOptions"].table.dungeons) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end

			end)
			
			currentButton.FontString:SetText(activityEntry.name)
		end

		miog.F.ADDED_DUNGEON_FILTERS = true
	end]]
end

miog.updateRaidCheckboxes = updateRaidCheckboxes

local function addRaidCheckboxes()
	local filterPanel = miog.pveFrame2.SidePanel.Container.FilterPanel
	
	local raidPanel = miog.createBasicFrame("persistent", "BackdropTemplate", miog.searchPanel.PanelFilters, miog.searchPanel.PanelFilters:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	raidPanel.Buttons = {}

	filterPanel.Panel.FilterOptions.RaidPanel = raidPanel

	local raidPanelFirstRow = miog.createBasicFrame("persistent", "BackdropTemplate", raidPanel, raidPanel:GetWidth(), raidPanel:GetHeight() / 2)
	raidPanelFirstRow:SetPoint("TOPLEFT", raidPanel, "TOPLEFT")

	local raidPanelSecondRow = miog.createBasicFrame("persistent", "BackdropTemplate", raidPanel, raidPanel:GetWidth(), raidPanel:GetHeight() / 2)
	raidPanelSecondRow:SetPoint("BOTTOMLEFT", raidPanel, "BOTTOMLEFT")

	local counter = 0

	--for _, activityEntry in ipairs(sortedSeasonDungeons) do
	for i = 1, 3, 1 do
		local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", raidPanel, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		optionButton:SetPoint("LEFT", counter < 4 and raidPanelFirstRow or counter > 3 and raidPanelSecondRow, "LEFT", counter < 4 and counter * 57 or (counter - 4) * 57, 0)
		optionButton:SetNormalAtlas("checkbox-minimal")
		optionButton:SetPushedAtlas("checkbox-minimal")
		optionButton:SetCheckedTexture("checkmark-minimal")
		optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		optionButton:RegisterForClicks("LeftButtonDown")
		--[[optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.dungeons[activityEntry.activityID])
		optionButton:HookScript("OnClick", function()
			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.dungeons[activityEntry.activityID] = optionButton:GetChecked()

			if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.dungeons) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end

		end)]]
	
		raidPanel.Buttons[i] = optionButton
		--filterPanel.Panel.FilterOptions[activityEntry.activityID] = optionButton
	
		local optionString = miog.createBasicFontString("persistent", 12, raidPanel)
		optionString:SetPoint("LEFT", optionButton, "RIGHT")
		--optionString:SetText(activityEntry.name)

		--dungeonPanel.Buttons[activityEntry.activityID] = optionButton

		optionButton.FontString = optionString

		counter = counter + 1
	end

	return raidPanel
end

miog.addRaidCheckboxes = addRaidCheckboxes

local function addDungeonCheckboxes()
	local filterPanel = miog.pveFrame2.SidePanel.Container.FilterPanel
	
	local dungeonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", miog.searchPanel.PanelFilters, miog.searchPanel.PanelFilters:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	dungeonPanel.Buttons = {}

	filterPanel.Panel.FilterOptions.DungeonPanel = dungeonPanel

	local dungeonPanelFirstRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), dungeonPanel:GetHeight() / 2)
	dungeonPanelFirstRow:SetPoint("TOPLEFT", dungeonPanel, "TOPLEFT")

	local dungeonPanelSecondRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), dungeonPanel:GetHeight() / 2)
	dungeonPanelSecondRow:SetPoint("BOTTOMLEFT", dungeonPanel, "BOTTOMLEFT")

	local counter = 0

	--for _, activityEntry in ipairs(sortedSeasonDungeons) do
	for i = 1, 8, 1 do
		local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", dungeonPanel, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		optionButton:SetPoint("LEFT", counter < 4 and dungeonPanelFirstRow or counter > 3 and dungeonPanelSecondRow, "LEFT", counter < 4 and counter * 57 or (counter - 4) * 57, 0)
		optionButton:SetNormalAtlas("checkbox-minimal")
		optionButton:SetPushedAtlas("checkbox-minimal")
		optionButton:SetCheckedTexture("checkmark-minimal")
		optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		optionButton:RegisterForClicks("LeftButtonDown")
		--[[optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.dungeons[activityEntry.activityID])
		optionButton:HookScript("OnClick", function()
			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.dungeons[activityEntry.activityID] = optionButton:GetChecked()

			if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.dungeons) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end

		end)]]
	
		dungeonPanel.Buttons[i] = optionButton
		--filterPanel.Panel.FilterOptions[activityEntry.activityID] = optionButton
	
		local optionString = miog.createBasicFontString("persistent", 12, dungeonPanel)
		optionString:SetPoint("LEFT", optionButton, "RIGHT")
		--optionString:SetText(activityEntry.name)

		--dungeonPanel.Buttons[activityEntry.activityID] = optionButton

		optionButton.FontString = optionString

		counter = counter + 1
	end

	return dungeonPanel
end

miog.addDungeonCheckboxes = addDungeonCheckboxes

local function setupFiltersForActivePanel()
	local container = miog.pveFrame2.SidePanel.Container
	local filterPanel = container.FilterPanel

	for i = 1, 3, 1 do
		filterPanel.Panel.FilterOptions.Roles.RoleButtons[i]:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"])
	end

	for k, v in pairs(filterPanel.Panel.FilterOptions) do
		if(v.Button and v.Button:GetObjectType() == "CheckButton") then
			v.Button:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[k])
		end
	end

	filterPanel.Panel.FilterOptions.filterForTanks:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForTanks)
	filterPanel.Panel.FilterOptions.minTanks:SetText(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.minTanks)
	filterPanel.Panel.FilterOptions.maxTanks:SetText(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.maxTanks)

	filterPanel.Panel.FilterOptions.filterForHealers:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForHealers)
	filterPanel.Panel.FilterOptions.minHealers:SetText(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.minHealers)
	filterPanel.Panel.FilterOptions.maxHealers:SetText(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.maxHealers)

	filterPanel.Panel.FilterOptions.filterForDamager:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForDamager)
	filterPanel.Panel.FilterOptions.minDamager:SetText(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.minDamager)
	filterPanel.Panel.FilterOptions.maxDamager:SetText(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.maxDamager)

	filterPanel.Panel.FilterOptions.filterForScore:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForScore)
	filterPanel.Panel.FilterOptions.minScore:SetText(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.minScore)
	filterPanel.Panel.FilterOptions.maxScore:SetText(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.maxScore)

	--filterPanel.Panel.FilterOptions["filterForClassSpecs"].Button:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForClassSpecs)

	for classIndex, classEntry in ipairs(miog.CLASSES) do
		local currentClassPanel = filterPanel.Panel.FilterOptions.ClassPanels[classIndex]

		if(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec) then
			if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.class[classIndex] ~= nil) then
				currentClassPanel.Class.Button:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.class[classIndex])
				
				if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.class[classIndex] == false) then
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

				MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.spec[specIndex] = state
			end

			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.class[classIndex] = state

			if(not miog.checkForActiveFilters(filterPanel.Panel)) then
				container.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				container.TitleBar.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

			convertFiltersToAdvancedBlizzardFilters()

			if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForClassSpecs) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.checkSearchResultListForEligibleMembers()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end
		end)

		for specIndex, specID in pairs(classEntry.specs) do
			local currentSpecFrame = currentClassPanel.SpecFrames[specID]
			if(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec) then
				if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.spec[specID] ~= nil) then
					currentSpecFrame.Button:SetChecked(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.spec[specID])

					if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.spec[specID] == false) then
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

				MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.spec[specID] = state

				convertFiltersToAdvancedBlizzardFilters()

				if(MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForClassSpecs) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end

			end)
		end
	end


	--filterPanel.Panel.FilterOptions["filterForClassSpecs"].Button:SetChecked()
end

miog.setupFiltersForActivePanel = setupFiltersForActivePanel

local function createClassSpecFilters(parent)
	local container = miog.pveFrame2.SidePanel.Container

	parent.Uncheck:SetScript("OnClick", function()

		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table = miog.getBaseSettings(miog.pveFrame2.activePanel .. "_FilterOptions").table

		setupFiltersForActivePanel()

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
	local container = miog.pveFrame2.SidePanel.Container

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

			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"] = state

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
	local filterPanel = miog.pveFrame2.SidePanel.Container.FilterPanel

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
end
