local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

local queueSystem = {}
queueSystem.queueFrames = {}
queueSystem.currentlyInUse = 0

miog.queueSystem = queueSystem
miog.pveFrame2 = nil

local function resetQueueFrame(_, frame)
	frame:Hide()
	frame.layoutIndex = nil

	local objectType = frame:GetObjectType()

	if(objectType == "Frame") then
		frame:SetScript("OnMouseDown", nil)
		frame.Name:SetText("")
		frame.Age:SetText("")

		if(frame.Age.Ticker) then
			frame.Age.Ticker:Cancel()
			frame.Age.Ticker = nil
		end

		frame:ClearBackdrop()

		frame.Icon:SetTexture(nil)

		frame.Wait:SetText("Wait")
	end

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueuePanel.ScrollFrame.Container:MarkDirty()
end

hooksecurefunc("PVEFrame_ToggleFrame", function()
	HideUIPanel(PVEFrame)
	miog.pveFrame2:SetShown(not miog.pveFrame2:IsVisible())
end)

local function addOptionToFilterFrame(parent, _, text, name)
	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOption")
	filterOption:SetWidth(parent:GetWidth())
	filterOption:SetHeight(25)
	filterOption.Button:HookScript("OnClick", function(self)
		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[name] = self:GetChecked()
		
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

		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterOption.Name:SetText(name)

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
		
		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.checkSearchResultListForEligibleMembers()

		elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
			C_LFGList.RefreshApplicants()

		end
	end)

	filterPanel.Panel.FilterOptions["filterFor" .. name] = optionButton

	local optionString = miog.createBasicFontString("persistent", 12, parent)
	optionString:SetPoint("LEFT", optionButton, "RIGHT")
	optionString:SetText(name)

	local minName = "min" .. name
	local maxName = "max" .. name

	local lastNumericField = nil

	for i = 1, 2, 1 do
		local currentName = i == 1 and minName or maxName

		local numericField = miog.createBasicFrame("persistent", "InputBoxTemplate", parent, miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		numericField:SetPoint("LEFT", i == 1 and optionString or lastNumericField, "RIGHT", 5, 0)
		numericField:SetAutoFocus(false)
		numericField.autoFocus = false
		numericField:SetNumeric(true)
		numericField:SetMaxLetters(4)
		--numericField:SetText(MIOG_SavedSettings and MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[i == 1 and minName or maxName] or 0)
		numericField:HookScript("OnTextChanged", function(self, ...)
			local text = tonumber(self:GetText())
			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table[currentName] = text ~= nil and text or 0

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
	local filterPanel = container.FilterPanel

	parent.Uncheck:SetScript("OnClick", function()

		MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table = miog.getBaseSettings(miog.pveFrame2.activePanel .. "_FilterOptions").table

		setupFiltersForActivePanel()

		container.TitleBar.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

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

local function createPVEFrameReplacement()
	local pveFrame2 = CreateFrame("Frame", "MythicIOGrabber_PVEFrameReplacement", WorldFrame, "MIOG_MainFrameTemplate")
	pveFrame2:SetSize(PVEFrame:GetWidth(), PVEFrame:GetHeight())
	pveFrame2.SidePanel:SetHeight(pveFrame2:GetHeight() * 1.45)

	if(pveFrame2:GetPoint() == nil) then
		pveFrame2:SetPoint(PVEFrame:GetPoint())
	end
	pveFrame2:SetScale(0.64)

	_G[pveFrame2:GetName()] = pveFrame2

	miog.createFrameBorder(pveFrame2, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	
	pveFrame2:HookScript("OnShow", function(selfPVEFrame)
		local allKeystoneInfo = miog.openRaidLib.RequestKeystoneDataFromParty()

		C_MythicPlus.RequestCurrentAffixes()
		C_MythicPlus.RequestMapInfo()

		miog.setUpMPlusStatistics()
		miog.gatherMPlusStatistics()
		
		if(not miog.F.ADDED_DUNGEON_FILTERS) then
			local currentSeason = C_MythicPlus.GetCurrentSeason()

			miog.F.CURRENT_SEASON = currentSeason
			miog.F.PREVIOUS_SEASON = currentSeason - 1

			miog.updateDungeonCheckboxes()
			miog.updateRaidCheckboxes()

		end

		local regularActivityID, regularGroupID, regularLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones

		if(regularActivityID) then
			miog.MainTab.Keystone.Text:SetText("+" .. regularLevel .. " " .. C_LFGList.GetActivityGroupInfo(regularGroupID))
			miog.MainTab.Keystone.Text:SetTextColor(miog.createCustomColorForScore(regularLevel * 130):GetRGBA())

			--miog.MPlusStatistics.Keystone.Text:SetText("+" .. regularLevel .. " " .. C_LFGList.GetActivityGroupInfo(regularGroupID))
			--miog.MPlusStatistics.Keystone.Text:SetTextColor(miog.createCustomColorForScore(regularLevel * 130):GetRGBA())
			
			
		else
			local timewalkingActivityID, timewalkingGroupID, timewalkingLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true)  -- Check for a timewalking keystone.

			if(timewalkingActivityID) then
				miog.MainTab.Keystone.Text:SetText("+" .. timewalkingLevel .. " " .. C_LFGList.GetActivityGroupInfo(timewalkingGroupID))
				miog.MainTab.Keystone.Text:SetTextColor(miog.createCustomColorForScore(timewalkingLevel * 130):GetRGBA())

				--miog.MPlusStatistics.Keystone.Text:SetText("+" .. timewalkingLevel .. " " .. C_LFGList.GetActivityGroupInfo(timewalkingGroupID))
				--miog.MPlusStatistics.Keystone.Text:SetTextColor(miog.createCustomColorForScore(timewalkingLevel * 130):GetRGBA())
				
			else
				miog.MainTab.Keystone.Text:SetText("NO KEYSTONE")
				miog.MainTab.Keystone.Text:SetTextColor(1, 0, 0, 1)

				--miog.MPlusStatistics.Keystone.Text:SetText("NO KEYSTONE")
				--miog.MPlusStatistics.Keystone.Text:SetTextColor(1, 0, 0, 1)
			
			end
		end
		
		for frameIndex = 1, 3, 1 do
			local activities = C_WeeklyRewards.GetActivities(frameIndex)

			activities[1].progress = random(0, activities[1].threshold) * 2
			activities[2].progress = activities[1].progress >= activities[1].threshold and random(activities[1].progress, activities[3].threshold) or activities[1].progress
			activities[3].progress = activities[2].progress >= activities[2].threshold and random(activities[2].progress, activities[3].threshold) or activities[2].progress

			local firstThreshold = activities[1].progress >= activities[1].threshold
			local secondThreshold = activities[2].progress >= activities[2].threshold
			local thirdThreshold = activities[3].progress >= activities[3].threshold
			local currentColor = thirdThreshold and miog.CLRSCC.green or secondThreshold and miog.CLRSCC.yellow or firstThreshold and miog.CLRSCC.orange or miog.CLRSCC.red
			local dimColor = {CreateColorFromHexString(currentColor):GetRGB()}
			dimColor[4] = 0.1

			local currentFrame = frameIndex == 1 and miog.MainTab.MPlusStatus or frameIndex == 2 and miog.MainTab.HonorStatus or miog.MainTab.RaidStatus

			if(currentFrame.ticks) then
				for k, v in pairs(currentFrame.ticks) do
					miog.persistentTexturePool:Release(v)
					currentFrame.ticks[k] = nil

				end

			end

			currentFrame:SetMinMaxValues(0, activities[3].threshold)
			currentFrame.info = (thirdThreshold or secondThreshold) and activities[3] or firstThreshold and activities[2] or activities[1]
			currentFrame.unlocked = currentFrame.info.progress >= currentFrame.info.threshold;

			currentFrame:SetStatusBarColor(CreateColorFromHexString(currentColor):GetRGBA())
			miog.createFrameWithBackgroundAndBorder(currentFrame, 1, unpack(dimColor))

			currentFrame:SetScript("OnEnter", function(self)

				GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);

				if self.info then
					local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.info.id);
					local itemLevel, upgradeItemLevel;
					if itemLink then
						itemLevel = GetDetailedItemLevelInfo(itemLink);
					end
					if upgradeItemLink then
						upgradeItemLevel = GetDetailedItemLevelInfo(upgradeItemLink);
					end
					if not itemLevel then
						--GameTooltip_AddErrorLine(GameTooltip, RETRIEVING_ITEM_INFO);
						--self.UpdateTooltip = self.ShowPreviewItemTooltip;
					
					end

					local canShow = self:CanShowPreviewItemTooltip()
					
					GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);
					GameTooltip_AddBlankLineToTooltip(GameTooltip);
				
					local hasRewards = C_WeeklyRewards.HasAvailableRewards();
					if hasRewards then
						GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR);
						GameTooltip_AddBlankLineToTooltip(GameTooltip);
					end

					if self.info.type == Enum.WeeklyRewardChestThresholdType.Activities then
						if(canShow) then
							local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(self.info.activityTierID, self.info.level);
							if hasData then
								upgradeItemLevel = nextItemLevel;
							else
								nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(self.info.level);
							end
							self:HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel, nextLevel);

						else
							self:ShowIncompleteMythicTooltip();

						end

						GameTooltip_AddBlankLineToTooltip(GameTooltip);
						GameTooltip_AddNormalLine(GameTooltip, string.format("%s/%s rewards unlocked.", thirdThreshold and 3 or secondThreshold and 2 or firstThreshold and 1 or 0, 3))

					elseif self.info.type == Enum.WeeklyRewardChestThresholdType.Raid then
						local currentDifficultyID = self.info.level;

						if(itemLevel) then
							local currentDifficultyName = DifficultyUtil.GetDifficultyName(currentDifficultyID);
							GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, itemLevel, currentDifficultyName));
							GameTooltip_AddBlankLineToTooltip(GameTooltip);
						end
						
						if upgradeItemLevel then
							local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(currentDifficultyID);
							local difficultyName = DifficultyUtil.GetDifficultyName(nextDifficultyID);
							GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
							GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_RAID, difficultyName));
						end
			
						local encounters = C_WeeklyRewards.GetActivityEncounterInfo(self.info.type, self.info.index);
						if encounters then
							table.sort(encounters, function(left, right)
								if left.instanceID ~= right.instanceID then
									return left.instanceID < right.instanceID;
								end
								local leftCompleted = left.bestDifficulty > 0;
								local rightCompleted = right.bestDifficulty > 0;
								if leftCompleted ~= rightCompleted then
									return leftCompleted;
								end
								return left.uiOrder < right.uiOrder;
							end)
							local lastInstanceID = nil;
							for index, encounter in ipairs(encounters) do
								local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounter.encounterID);
								if instanceID ~= lastInstanceID then
									local instanceName = EJ_GetInstanceInfo(instanceID);
									--GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_ENCOUNTER_LIST, instanceName));
									--GameTooltip_AddBlankLineToTooltip(GameTooltip);	
									lastInstanceID = instanceID;
								end
								if name then
									if encounter.bestDifficulty > 0 then
										local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty);
										GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETED_ENCOUNTER, name, completedDifficultyName), miog.DIFFICULTY_ID_TO_COLOR[encounter.bestDifficulty]);
									else
										GameTooltip_AddColoredLine(GameTooltip, string.format(DASH_WITH_TEXT, name), DISABLED_FONT_COLOR);
									end
								end
							end
						end

						GameTooltip_AddBlankLineToTooltip(GameTooltip);
						GameTooltip_AddNormalLine(GameTooltip, string.format("%s/%s rewards unlocked.", thirdThreshold and 3 or secondThreshold and 2 or firstThreshold and 1 or 0, 3))

					elseif self.info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
						if not ConquestFrame_HasActiveSeason() then
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
							GameTooltip_AddDisabledLine(GameTooltip, UNAVAILABLE);
							GameTooltip_AddNormalLine(GameTooltip, CONQUEST_REQUIRES_PVP_SEASON);
							GameTooltip:Show();
							return;
						end
					
						local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress();
						local unlocksCompleted = weeklyProgress.unlocksCompleted or 0;

						GameTooltip_AddNormalLine(GameTooltip, "Honor earned: " .. weeklyProgress.progress .. "/" .. weeklyProgress.maxProgress);
						GameTooltip_AddBlankLineToTooltip(GameTooltip);
					
						local maxUnlocks = weeklyProgress.maxUnlocks or 3;
						local description;
						if unlocksCompleted > 0 then
							description = RATED_PVP_WEEKLY_VAULT_TOOLTIP:format(unlocksCompleted, maxUnlocks);

						else
							description = RATED_PVP_WEEKLY_VAULT_TOOLTIP_NO_REWARDS:format(unlocksCompleted, maxUnlocks);

						end

						GameTooltip_AddNormalLine(GameTooltip, description);
					
						--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
						--GameTooltip:Show();
					end

					GameTooltip_AddBlankLineToTooltip(GameTooltip);
					GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);

					GameTooltip:Show()

				end
			end)
			currentFrame:SetScript("OnLeave", function()
				GameTooltip:Hide()
		
			end)

			--currentVaultFrame:SetScript("OnEnter", currentFrame:GetScript("OnEnter"))
			--currentVaultFrame:SetScript("OnLeave", currentFrame:GetScript("OnLeave"))
			
			currentFrame.ticks = {}

			--[[
			if(not thirdThreshold) then
				for tickIndex = 1, 2, 1 do
					dimColor[4] = tickIndex == 1 and firstThreshold and 0.1 or tickIndex == 2 and secondThreshold and 0.1 or 1
	
					local tick = miog.createBasicTexture("persistent", "Interface\\ChatFrame\\ChatFrameBackground", currentFrame, 24, 3)
					tick:SetColorTexture(0.8, 0.8, 0.8, 1)
					tick:SetDrawLayer("OVERLAY")
					tick:SetPoint("BOTTOMLEFT", currentFrame, "BOTTOMLEFT", 0, currentFrame:GetHeight() / (activities[3].threshold / activities[tickIndex].threshold))
					currentFrame.ticks[#currentFrame.ticks+1] = tick
				end

				for tickIndex = 1, 2, 1 do
					if(tickIndex == 1 and firstThreshold or tickIndex == 2 and secondThreshold) then
						local tick = miog.createBasicTexture("persistent", "Interface\\Addons\\MythicIOGrabber\\res\\infoIcons\\checkmarkSmallIcon.png", currentFrame, 10, 10)
						tick:SetPoint("BOTTOMRIGHT", currentFrame, "BOTTOMRIGHT", 5, currentFrame:GetHeight() / (activities[3].threshold / activities[tickIndex].threshold))
						tick:SetDrawLayer("OVERLAY")
						currentFrame.ticks[#currentFrame.ticks+1] = tick
					end
				end

			else
				local tick = miog.createBasicTexture("persistent", "Interface\\Addons\\MythicIOGrabber\\res\\infoIcons\\checkmarkSmallIcon.png", currentFrame, 10, 10)
				tick:SetPoint("TOPRIGHT", currentFrame, "TOPRIGHT", 5, 5)
				tick:SetDrawLayer("OVERLAY")
				currentFrame.ticks[#currentFrame.ticks+1] = tick

			end]]

			currentFrame:SetValue(activities[3].progress)

			currentFrame.Text:SetText(activities[3].progress .. "/" .. activities[3].threshold .. " " .. (frameIndex == 1 and "Dungeons" or frameIndex == 2 and "Honor" or frameIndex == 3 and "Bosses" or ""))
			currentFrame.Text:SetTextColor(CreateColorFromHexString(not firstThreshold and currentColor or "FFFFFFFF"):GetRGBA())
		end
	end)

	miog.pveFrame2 = pveFrame2
	
	miog.MainTab = pveFrame2.TabFramesPanel.MainTab
	miog.pveFrame2.TitleBar.Expand:SetParent(miog.MainTab.Plugin)

	miog.MPlusStatistics = pveFrame2.TabFramesPanel.MPlusStatistics
	miog.MPlusStatistics.KeystoneDropdown:OnLoad()
	miog.MPlusStatistics.KeystoneDropdown:SetListAnchorToTopleft()
	miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars = {}
	miog.MPlusStatistics.DungeonColumns.Dungeons = {}
	miog.MPlusStatistics:HookScript("OnShow", function()
		miog.MPlusStatistics.KeystoneDropdown:SetText("Party keystones")
		miog.refreshKeystones()
	end)

	local texture = WorldFrame:CreateTexture("test", "OVERLAY")
	texture:SetSize(50, 50)
	texture:SetPoint("TOPLEFT")
	texture:Show()

	local frame = miog.MainTab
	local filterPanel = pveFrame2.SidePanel.Container.FilterPanel
	
	filterPanel.Panel.FilterOptions = {}

	--miog.createFrameBorder(filterPanel.Button, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	--filterPanel.Button:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.createFrameBorder(pveFrame2.SidePanel.Container, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	pveFrame2.SidePanel.Container:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.createFrameBorder(pveFrame2.SidePanel.ButtonPanel.FilterButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	pveFrame2.SidePanel.ButtonPanel.FilterButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.createFrameBorder(pveFrame2.SidePanel.ButtonPanel.LastInvitesButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	pveFrame2.SidePanel.ButtonPanel.LastInvitesButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

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

	pveFrame2.TitleBar.Expand:SetScript("OnClick", function()

		MIOG_SavedSettings.frameExtended.value = not MIOG_SavedSettings.frameExtended.value

		if(MIOG_SavedSettings.frameExtended.value == true) then
			frame.Plugin:SetHeight(frame.Plugin.extendedHeight)

		elseif(MIOG_SavedSettings.frameExtended.value == false) then
			frame.Plugin:SetHeight(frame.Plugin.standardHeight)

		end
	end)

	pveFrame2.TitleBar.RaiderIOLoaded:SetText(WrapTextInColorCode("NO R.IO", miog.CLRSCC["red"]))
	pveFrame2.TitleBar.RaiderIOLoaded:SetShown(not miog.F.IS_RAIDERIO_LOADED)


---@diagnostic disable-next-line: undefined-field
	queueSystem.framePool = CreateFramePool("Frame", miog.MainTab.QueuePanel.ScrollFrame.Container, "MIOG_QueueFrame", resetQueueFrame)

---@diagnostic disable-next-line: undefined-field
	local queueRolePanel = frame.QueueRolePanel
	--queueRolePanel:SetPoint("BOTTOM", frame.QueueDropdown, "TOP", 0, 5)

	local leader, tank, healer, damager = LFDQueueFrame_GetRoles()

	queueRolePanel.Leader.Checkbox:SetChecked(leader)
	queueRolePanel.Leader.Checkbox:SetScript("OnClick", function(self)
		SetLFGRoles(queueRolePanel.Leader.Checkbox:GetChecked(), queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
	end)

	queueRolePanel.Tank.Checkbox:SetChecked(tank)
	queueRolePanel.Tank.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["TANK"])
	queueRolePanel.Tank.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["TANK"])
	queueRolePanel.Tank.Checkbox:SetScript("OnClick", function(self)
		SetLFGRoles(queueRolePanel.Leader.Checkbox:GetChecked(), queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
	end)

	queueRolePanel.Healer.Checkbox:SetChecked(healer)
	queueRolePanel.Healer.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["HEALER"])
	queueRolePanel.Healer.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["HEALER"])
	queueRolePanel.Healer.Checkbox:SetScript("OnClick", function(self)
		SetLFGRoles(queueRolePanel.Leader.Checkbox:GetChecked(), queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
	end)

	queueRolePanel.Damager.Checkbox:SetChecked(damager)
	queueRolePanel.Damager.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["DAMAGER"])
	queueRolePanel.Damager.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["DAMAGER"])
	queueRolePanel.Damager.Checkbox:SetScript("OnClick", function(self)
		SetLFGRoles(queueRolePanel.Leader.Checkbox:GetChecked(), queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
	end)

	PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")

---@diagnostic disable-next-line: undefined-field
	local queueDropDown = frame.QueueDropDown
	queueDropDown:OnLoad()
	queueDropDown:SetText("Choose a queue")
	frame.QueuePanel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	frame.Plugin:SetHeight(pveFrame2:GetHeight() - pveFrame2.TitleBar:GetHeight() - frame.Plugin.FooterBar:GetHeight() - 2)
	miog.createFrameBorder(frame.Plugin.FooterBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	frame.Plugin.FooterBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	frame.Plugin.Resize:SetScript("OnMouseUp", function()
		frame.Plugin:StopMovingOrSizing()

		MIOG_SavedSettings.frameManuallyResized.value = frame.Plugin:GetHeight()

		if(MIOG_SavedSettings.frameManuallyResized.value > frame.Plugin.standardHeight) then
			MIOG_SavedSettings.frameExtended.value = true
			frame.Plugin.extendedHeight = MIOG_SavedSettings.frameManuallyResized.value

		end

		--frame.Plugin:ClearAllPoints()
		frame.Plugin:SetPoint("TOPLEFT", frame.Plugin:GetParent(), "TOPRIGHT", -370, 0)
		frame.Plugin:SetPoint("TOPRIGHT", frame.Plugin:GetParent(), "TOPRIGHT", 0, 0)

	end)

	local standardWidth = frame.Plugin:GetWidth()
	frame.Plugin.standardHeight = frame.Plugin:GetHeight()
	frame.Plugin.extendedHeight = MIOG_SavedSettings and MIOG_SavedSettings.frameManuallyResized and MIOG_SavedSettings.frameManuallyResized.value > 0 and MIOG_SavedSettings.frameManuallyResized.value or frame.Plugin.standardHeight * 1.5

	frame.Plugin:SetResizeBounds(standardWidth, frame.Plugin.standardHeight, standardWidth, GetScreenHeight() * 0.67)
	frame.Plugin:SetHeight(MIOG_SavedSettings and MIOG_SavedSettings.frameExtended.value == true and MIOG_SavedSettings.frameManuallyResized and MIOG_SavedSettings.frameManuallyResized.value > 0 and MIOG_SavedSettings.frameManuallyResized.value or frame.Plugin.standardHeight)

	miog.createFrameBorder(frame.Plugin, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	frame.Plugin:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	--miog.createFrameBorder(frame.LastInvites.Button, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	--frame.LastInvites.Button:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local lastInvitesPanel = pveFrame2.SidePanel.Container.LastInvites

	miog.createFrameBorder(lastInvitesPanel.Panel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	miog.createFrameBorder(pveFrame2.SidePanel.Container.TitleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	--frame.SidePanel.Container.TitleBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	--miog.createFrameBorder(frame.SidePanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	--miog.setStandardBackdrop(frame.MPlusStatistics)
	--frame.MPlusStatistics:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
end

local function updateRandomDungeons()
	local queueDropDown = miog.MainTab.QueueDropDown
	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil

	if(queueDropDown.entryFrameTree[1]) then
		queueDropDown:ReleaseSpecificFrames("random", queueDropDown.entryFrameTree[1].List)
	end
	
	if(queueDropDown.entryFrameTree[2]) then
		queueDropDown:ReleaseSpecificFrames("random", queueDropDown.entryFrameTree[2].List)
	end

	for i=1, GetNumRandomDungeons() do
		local id, name, typeID, subtypeID, _, _, _, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon = GetLFGRandomDungeonInfo(i)
		
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if((isAvailableForPlayer or not hideIfNotJoinable)) then
			if(isAvailableForAll) then
				local mode = GetLFGMode(1, id)
				info.text = isHolidayDungeon and "(Event) " .. name or name

				info.checked = mode == "queued"
				info.icon = miog.MAP_INFO[id] and miog.MAP_INFO[id].icon or miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or nil
				info.parentIndex = subtypeID
				info.index = 1
				info.type2 = "random"

				info.func = function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, id);
					JoinSingleLFG(1, id);
				end
				
				local tempFrame = queueDropDown:CreateEntryFrame(info)
				tempFrame:SetScript("OnShow", function(self)
					local tempMode = GetLFGMode(1, id)
					self.Radio:SetChecked(tempMode == "queued")
					
				end)
			end
		end
	end
end

miog.updateRandomDungeons = updateRandomDungeons

local function updateDungeons()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueDropDown
	if(queueDropDown.entryFrameTree[1].List.framePool) then
		queueDropDown.entryFrameTree[1].List.framePool:ReleaseAll()
	end

	if(queueDropDown.entryFrameTree[2].List.framePool) then
		queueDropDown.entryFrameTree[2].List.framePool:ReleaseAll()
	end

	if(queueDropDown.entryFrameTree[3].List.framePool) then
		queueDropDown.entryFrameTree[3].List.framePool:ReleaseAll()
	end

	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil

	local dungeonList = GetLFDChoiceOrder() or {}

	for _, dungeonID in ipairs(dungeonList) do
---@diagnostic disable-next-line: redundant-parameter
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID);
		local name, typeID, subtypeID, _, _, _, _, _, expLevel, groupID, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(dungeonID)

		local groupActivityID = miog.MAP_ID_TO_GROUP_ACTIVITY_ID[mapID]

		if(groupActivityID and not miog.GROUP_ACTIVITY[groupActivityID]) then
			miog.GROUP_ACTIVITY[groupActivityID] = {mapID = mapID, file = fileID}
		end

		local isFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID)

		if((isAvailableForPlayer or not hideIfNotJoinable) and (subtypeID and difficultyID < 3 and not isFollowerDungeon or isFollowerDungeon)) then
			if(isAvailableForAll) then
				local mode = GetLFGMode(1, dungeonID)
				info.text = isHolidayDungeon and "(Event) " .. name or name
				info.checked = mode == "queued"
				info.icon = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[dungeonID] and miog.LFG_ID_INFO[dungeonID].icon or fileID or nil
				info.parentIndex = isFollowerDungeon and 3 or subtypeID
				info.func = function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, dungeonID);
					JoinSingleLFG(1, dungeonID);

				end

				local tempFrame = queueDropDown:CreateEntryFrame(info)
				tempFrame:SetScript("OnShow", function(self)
					local tempMode = GetLFGMode(1, dungeonID)
					self.Radio:SetChecked(tempMode == "queued")
					
				end)
			end
		end
	end

	--DevTools_Dump(miog.GROUP_ID_TO_LFG_ID)
end

miog.updateDungeons = updateDungeons

local function updateRaidFinder()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueDropDown

	if(queueDropDown.entryFrameTree[4] and queueDropDown.entryFrameTree[4].List.framePool) then
		queueDropDown.entryFrameTree[4].List.framePool:ReleaseAll()
	end

	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil
	info.parentIndex = 4

	local nextLevel = nil;
	local playerLevel = UnitLevel("player")


	for rfIndex=1, GetNumRFDungeons() do
		local id, name, typeID, subtypeID, minLevel, maxLevel, _, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon = GetRFDungeonInfo(rfIndex)
---@diagnostic disable-next-line: redundant-parameter
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if((isAvailableForPlayer or not hideIfNotJoinable)) then
			if(isAvailableForAll) then
				if (playerLevel >= minLevel and playerLevel <= maxLevel) then
					local mode = GetLFGMode(3, id)
					info.text = isHolidayDungeon and "(Event) " .. name or name
					info.checked = mode == "queued"
					info.icon = miog.MAP_INFO[id] and miog.MAP_INFO[id].icon or miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or nil
					info.func = function()
						--JoinSingleLFG(1, dungeonID)
						ClearAllLFGDungeons(3);
						SetLFGDungeon(3, id);
						--JoinLFG(LE_LFG_CATEGORY_RF);
						JoinSingleLFG(3, id);
					end
					
					local tempFrame = queueDropDown:CreateEntryFrame(info)
					tempFrame:SetScript("OnShow", function(self)
						local tempMode = GetLFGMode(3, id)
						self.Radio:SetChecked(tempMode == "queued")
						
					end)

					nextLevel = nil

				elseif ( playerLevel < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
					nextLevel = minLevel

				end
			end
		end
	end
end

miog.updateRaidFinder = updateRaidFinder

local function checkIfCanQueue()
	local HonorFrame = HonorFrame;
	local canQueue;
	local arenaID;
	local isBrawl;
	local isSpecialBrawl;

	if ( HonorFrame.type == "specific" ) then
		if ( HonorFrame.SpecificScrollBox.selectionID ) then
			canQueue = true;
		end
	elseif ( HonorFrame.type == "bonus" ) then
		if ( HonorFrame.BonusFrame.selectedButton ) then
			canQueue = HonorFrame.BonusFrame.selectedButton.canQueue;
			arenaID = HonorFrame.BonusFrame.selectedButton.arenaID;
			isBrawl = HonorFrame.BonusFrame.selectedButton.isBrawl;
			isSpecialBrawl = HonorFrame.BonusFrame.selectedButton.isSpecialBrawl;
		end
	end

	local disabledReason;

	if arenaID then
		local battlemasterListInfo = C_PvP.GetSkirmishInfo(arenaID);
		if battlemasterListInfo then
			local groupSize = GetNumGroupMembers();
			local minPlayers = battlemasterListInfo.minPlayers;
			local maxPlayers = battlemasterListInfo.maxPlayers;
			if groupSize > maxPlayers then
				canQueue = false;
				disabledReason = PVP_ARENA_NEED_LESS:format(groupSize - maxPlayers);
			elseif groupSize < minPlayers then
				canQueue = false;
				disabledReason = PVP_ARENA_NEED_MORE:format(minPlayers - groupSize);
			end
		end
	end

	return canQueue
end

local function updatePvP()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueDropDown

	if(queueDropDown.entryFrameTree[5].List.securePool) then
		queueDropDown.entryFrameTree[5].List.securePool:ReleaseAll()
	end

	if(queueDropDown.entryFrameTree[5].List.framePool) then
		queueDropDown.entryFrameTree[5].List.framePool:ReleaseAll()
	end
	local groupSize = IsInGroup() and GetNumGroupMembers() or 1;

	local token, loopMax, generalTooltip;
	if (groupSize > (MAX_PARTY_MEMBERS + 1)) then
		token = "raid";
		loopMax = groupSize;
	else
		token = "party";
		loopMax = groupSize - 1; -- player not included in party tokens, just raid tokens
	end
	
	local maxLevel = GetMaxLevelForLatestExpansion();
	for i = 1, loopMax do
		if ( not UnitIsConnected(token..i) ) then
			generalTooltip = PVP_NO_QUEUE_DISCONNECTED_GROUP
			break;
		elseif ( UnitLevel(token..i) < maxLevel ) then
			generalTooltip = PVP_NO_QUEUE_GROUP
			break;
		end
	end

	local info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = PVP_RATED_SOLO_SHUFFLE

	local minItemLevel = C_PvP.GetRatedSoloShuffleMinItemLevel()
	local _, _, playerPvPItemLevel = GetAverageItemLevel();
	info.disabled = playerPvPItemLevel < minItemLevel
	info.icon = miog.findBrawlIconByName("Solo Shuffle")
	info.tooltipOnButton = true
	info.tooltipWhileDisabled = true
	info.type2 = "rated"
	info.tooltipTitle = "Unable to queue for this activity."
	info.tooltipText = generalTooltip or format(_G["INSTANCE_UNAVAILABLE_SELF_PVP_GEAR_TOO_LOW"], "", minItemLevel, playerPvPItemLevel);
	info.func = nil
	--info.func = function()
	--	JoinRatedSoloShuffle()
	-- end
	

	local soloFrame = queueDropDown:CreateEntryFrame(info)
	soloFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.RatedSoloShuffle, soloFrame)
	
	soloFrame:SetScript("OnShow", function(self)
		--local tempMode = GetLFGMode(1, dungeonID)
		--self.Radio:SetChecked(tempMode == "queued")
		
	end)

	info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = ARENA_BATTLES_2V2
	info.icon = miog.findBattlegroundIconByName("Arena (2v2)")
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 2 and string.format(PVP_ARENA_NEED_LESS, groupSize - 2) or groupSize < 2 and string.format(PVP_ARENA_NEED_MORE, 2 - groupSize)
	info.disabled = groupSize ~= 2
	--info.func = function()
	--	JoinArena()
	--end

	local twoFrame = queueDropDown:CreateEntryFrame(info)
	twoFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.Arena2v2, twoFrame)

	info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = ARENA_BATTLES_3V3
	info.icon = miog.findBattlegroundIconByName("Arena (3v3)")
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 3 and string.format(PVP_ARENA_NEED_LESS, groupSize - 3) or groupSize < 3 and string.format(PVP_ARENA_NEED_MORE, 3 - groupSize)
	info.disabled = generalTooltip or groupSize ~= 3
	--info.func = function()
	--	JoinArena()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local threeFrame = queueDropDown:CreateEntryFrame(info)
	threeFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.Arena3v3, threeFrame)

	info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = PVP_RATED_BATTLEGROUNDS
	info.icon = miog.findBattlegroundIconByName("Rated Battlegrounds")
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 10 and string.format(PVP_RATEDBG_NEED_LESS, groupSize - 10) or groupSize < 10 and string.format(PVP_RATEDBG_NEED_MORE, 10 - groupSize)
	info.disabled = generalTooltip or groupSize ~= 10
	--info.func = function()
	--	JoinRatedBattlefield()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local tenFrame = queueDropDown:CreateEntryFrame(info)
	tenFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.RatedBG, tenFrame)

	for index = 1, 5, 1 do
		local currentBGQueue = index == 1 and C_PvP.GetRandomBGInfo() or index == 2 and C_PvP.GetRandomEpicBGInfo() or index == 3 and C_PvP.GetSkirmishInfo(4) or index == 4 and C_PvP.GetAvailableBrawlInfo() or index == 5 and C_PvP.GetSpecialEventBrawlInfo()

		if(currentBGQueue and (index == 3 or currentBGQueue.canQueue)) then
			info = {}
			info.text = index == 1 and RANDOM_BATTLEGROUNDS or index == 2 and RANDOM_EPIC_BATTLEGROUND or index == 3 and "Skirmish" or currentBGQueue.name
			info.entryType = "option"
			info.checked = false
			--info.disabled = index == 1 or index == 2
			info.icon = index < 3 and miog.findBattlegroundIconByID(currentBGQueue.bgID) or index == 3 and currentBGQueue.icon or index > 3 and (miog.findBrawlIconByID(currentBGQueue.brawlID) or miog.findBrawlIconByName(currentBGQueue.name))
			info.level = 2
			info.parentIndex = 5
			info.type2 = "unrated"
			info.func = nil
			info.disabled = index ~= 3 and currentBGQueue.canQueue == false or index == 3 and not HonorFrame.BonusFrame.Arena1Button.canQueue

			-- UIDropDownMenu_AddButton(info, level)
			local tempFrame = queueDropDown:CreateEntryFrame(info)

			if(currentBGQueue.bgID) then
				if(currentBGQueue.bgID == 32) then
					tempFrame:SetAttribute("macrotext1", "/click HonorFrameQueueButton")
					queueDropDown:CreateExtraButton(HonorFrame.BonusFrame.RandomBGButton, tempFrame)
					

				elseif(currentBGQueue.bgID == 901) then
					--tempFrame:SetAttribute("macrotext1", "/click [nocombat] HonorFrame.BonusFrame.RandomEpicBGButton" .. "\r\n" .. "/click [nocombat] HonorFrameQueueButton")
					tempFrame:SetAttribute("macrotext1", "/click HonorFrameQueueButton")
					queueDropDown:CreateExtraButton(HonorFrame.BonusFrame.RandomEpicBGButton, tempFrame)

				end

				tempFrame:SetAttribute("original", tempFrame:GetAttribute("macrotext1"))
			else
				if(index == 3) then
					--JoinSkirmish(4)
					tempFrame:SetAttribute("macrotext1", "/run JoinSkirmish(4)")


				elseif(index == 4) then
					tempFrame:SetAttribute("macrotext1", "/run C_PvP.JoinBrawl()")
					--C_PvP.JoinBrawl()

				elseif(index == 5) then
					tempFrame:SetAttribute("macrotext1", "/run C_PvP.JoinBrawl(true)")
					--C_PvP.JoinBrawl(true)
				
				end
			end
		end

	end

	

	info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = LFG_LIST_MORE
	-- info.checked = false
	--info.tooltipText = generalTooltip or groupSize > 10 and string.format(PVP_RATEDBG_NEED_LESS, groupSize - 10) or groupSize < 10 and string.format(PVP_RATEDBG_NEED_MORE, 10 - groupSize)
	--info.disabled = generalTooltip or groupSize ~= 10
	info.type2 = "more"
	info.disabled = nil
	--info.func = function()
	--	JoinRatedBattlefield()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local moreFrame = queueDropDown:CreateEntryFrame(info)
	--[[moreFrame:SetAttribute("macrotext1", "/run PVEFrame_ShowFrame(\"PVPUIFrame\", \"HonorFrame\")" .. "\r\n" .. "/run HonorFrame.BonusFrame.Arena1Button:ClearAllPoints()" .. "\r\n" .. 
	"/run HonorFrame.BonusFrame.Arena1Button:SetPoint(\"LEFT\", HonorFrame.BonusFrame, \"LEFT\", (HonorFrame.BonusFrame:GetWidth() - HonorFrame.BonusFrame.Arena1Button:GetWidth()) / 2, 0)")]]

	moreFrame:SetAttribute("macrotext1", "/run PVEFrame_ShowFrame(\"PVPUIFrame\", \"HonorFrame\")")
end

miog.updatePvP = updatePvP

local function updateQueueDropDown()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueDropDown
	queueDropDown:ResetDropDown()

	local info = {}
	info.text = "Dungeons (Normal)"
	info.hasArrow = true
	info.level = 1
	info.index = 1
	queueDropDown:CreateEntryFrame(info)

	info.text = "Dungeons (Heroic)"
	info.hasArrow = true
	info.level = 1
	info.index = 2
	queueDropDown:CreateEntryFrame(info)

	info.text = "Follower"
	info.hasArrow = true
	info.level = 1
	info.index = 3
	queueDropDown:CreateEntryFrame(info)

	info.text = "Raid Finder"
	info.hasArrow = true
	info.level = 1
	info.index = 4
	queueDropDown:CreateEntryFrame(info)

	info.text = "PvP"
	info.hasArrow = true
	info.level = 1
	info.index = 5
	queueDropDown:CreateEntryFrame(info)

	info = {}

	info.text = "Pet Battle"
	info.checked = false
	info.entryType = "option"
	info.level = 1
	info.value = "PETBATTLEQUEUEBUTTON"
	info.index = 6
	info.func = function()
		C_PetBattles.StartPVPMatchmaking()
	end

	local tempFrame = queueDropDown:CreateEntryFrame(info)
	tempFrame:SetScript("OnShow", function(self)
		local pbStatus = C_PetBattles.GetPVPMatchmakingInfo()
		self.Radio:SetChecked(pbStatus ~= nil)
		
	end)

	info.entryType = "option"
	info.level = 2
	info.index = nil

	updateRandomDungeons()
	updateDungeons()
	updateRaidFinder()
	updatePvP()
end

miog.updateQueueDropDown = updateQueueDropDown

local queueFrameIndex = 0

local function createQueueFrame(queueInfo)
	local queueFrame = queueSystem.queueFrames[queueInfo[18]]

	if(not queueSystem.queueFrames[queueInfo[18]]) then
		queueFrame = queueSystem.framePool:Acquire()
		queueFrame.ActiveIDFrame:Hide()
		queueFrame.CancelApplication:SetMouseClickEnabled(true)
		queueFrame.CancelApplication:RegisterForClicks("LeftButtonDown")

		--miog.createFrameBorder(queueFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		queueSystem.queueFrames[queueInfo[18]] = queueFrame

		queueFrameIndex = queueFrameIndex + 1
		queueFrame.layoutIndex = queueInfo[21] or queueFrameIndex
	
	end

	queueFrame:SetWidth(miog.MainTab.QueuePanel:GetWidth() - 7)
	
	--queueFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	queueFrame.Name:SetText(queueInfo[11])

	local ageNumber = 0

	if(queueInfo[17][1] == "queued") then
		ageNumber = GetTime() - queueInfo[17][2]

		queueFrame.Age.Ticker = C_Timer.NewTicker(1, function()
			ageNumber = ageNumber + 1
			queueFrame.Age:SetText(miog.secondsToClock(ageNumber))

		end)
	elseif(queueInfo[17][1] == "duration") then
		ageNumber = queueInfo[17][2]

		queueFrame.Age.Ticker = C_Timer.NewTicker(1, function()
			ageNumber = ageNumber - 1
			queueFrame.Age:SetText(miog.secondsToClock(ageNumber))

		end)
	
	end

	queueFrame.Age:SetText(miog.secondsToClock(ageNumber))

	if(queueInfo[20]) then
		queueFrame.Icon:SetTexture(queueInfo[20])
	end

	queueFrame.Wait:SetText("(" .. (queueInfo[12] ~= -1 and miog.secondsToClock(queueInfo[12]) or "N/A") .. ")")

	--/run DevTools_Dump(C_PvP.GetAvailableBrawlInfo())
	--/run DevTools_Dump(C_PvP.GetSpecialEventBrawlInfo())
	--/run DevTools_Dump()
	--/run DevTools_Dump()
	--/run DevTools_Dump()

	queueFrame:SetShown(true)

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueuePanel.ScrollFrame.Container:MarkDirty()

	return queueFrame
end

miog.createQueueFrame = createQueueFrame

miog.createPVEFrameReplacement = createPVEFrameReplacement

miog.scriptReceiver = CreateFrame("Frame", "MythicIOGrabber_ScriptReceiver", miog.pveFrame2, "BackdropTemplate") ---@class Frame
miog.scriptReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
miog.scriptReceiver:RegisterEvent("PLAYER_LOGIN")
miog.scriptReceiver:RegisterEvent("UPDATE_LFG_LIST")
miog.scriptReceiver:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
miog.scriptReceiver:SetScript("OnEvent", miog.OnEvent)