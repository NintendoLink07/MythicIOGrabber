local addonName, miog = ...
local wticc = WrapTextInColorCode

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
	miog.mainTab.QueuePanel.Container:MarkDirty()
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
	optionButton:SetPoint("TOPLEFT", lastFilterOption, "BOTTOMLEFT", 0, -5)
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

local function uppdateDungeonCheckboxes()
	local filterPanel = miog.pveFrame2.SidePanel.Container.FilterPanel
	local sortedSeasonDungeons = {}

	for activityID, activityEntry in pairs(miog.ACTIVITY_ID_INFO) do
		if(activityEntry.mPlusSeasons) then
			for _, seasonID in ipairs(activityEntry.mPlusSeasons) do
				if(seasonID == miog.F.CURRENT_SEASON) then
					sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {activityID = activityID, name = activityEntry.shortName}

				end
			end
		end
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
end

miog.uppdateDungeonCheckboxes = uppdateDungeonCheckboxes

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
	
		filterPanel.Panel.FilterOptions.DungeonPanel.Buttons[i] = optionButton
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
	parent.Uncheck:SetScript("OnClick", function()
		for classIndex, v in pairs(parent.FilterFrame.classFilterPanel.ClassPanels) do
			v.Class.Button:SetChecked(false)

			for specIndex, y in pairs(v.SpecFrames) do
				y.Button:SetChecked(false)
				MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.spec[specIndex] = false

			end

			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.class[classIndex] = false

		end

		if(not miog.checkForActiveFilters(parent)) then
			parent.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

		else
			parent.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

		end

		miog.checkSearchResultListForEligibleMembers()
	end)

	parent.Check:SetScript("OnClick", function()
		for classIndex, v in pairs(parent.FilterFrame.classFilterPanel.ClassPanels) do
			v.Class.Button:SetChecked(true)

			for specIndex, y in pairs(v.SpecFrames) do
				y.Button:SetChecked(true)

				MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.spec[specIndex] = true

			end

			MIOG_SavedSettings[miog.pveFrame2.activePanel .. "_FilterOptions"].table.classSpec.class[classIndex] = true

			if(not miog.checkForActiveFilters(parent)) then
				parent.FontString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				parent.FontString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

		end

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

		C_MythicPlus.RequestCurrentAffixes()
		C_MythicPlus.RequestMapInfo()

		miog.setUpMPlusStatistics()
		miog.gatherMPlusStatistics()
		
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

			local currentFrame = frameIndex == 1 and miog.mainTab.MPlusStatus or frameIndex == 2 and miog.mainTab.HonorStatus or miog.mainTab.RaidStatus

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
			

			currentFrame.ticks = {}

			if(not thirdThreshold) then
				for tickIndex = 1, 2, 1 do
					dimColor[4] = tickIndex == 1 and firstThreshold and 0.1 or tickIndex == 2 and secondThreshold and 0.1 or 1
	
					local tick = miog.createBasicTexture("persistent", "Interface\\ChatFrame\\ChatFrameBackground", currentFrame, 20, 3)
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

			end

			currentFrame:SetValue(activities[3].progress)
		end
	end)

	miog.pveFrame2 = pveFrame2
	
	miog.mainTab = pveFrame2.TabFramesPanel.MainTab
	miog.MPlusStatistics = pveFrame2.TabFramesPanel.MPlusStatistics

	local frame = miog.mainTab


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
	queueSystem.framePool = CreateFramePool("Frame", miog.mainTab.QueuePanel.Container, "MIOG_QueueFrame", resetQueueFrame)

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
	frame.QueuePanel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	--[[

	miog.setStandardBackdrop(frame.QueuePanel)
	local color = CreateColorFromHexString(miog.C.BACKGROUND_COLOR)
	frame.QueuePanel:SetBackdropColor(color.r, color.g, color.b, 0.6)

	]]

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
		frame.Plugin:SetPoint("TOPLEFT", frame, "TOPRIGHT", -370, -20)
		frame.Plugin:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -20)

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
	local queueDropDown = miog.mainTab.QueueDropDown
	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil

	for i=1, GetNumRandomDungeons() do
				
		local id, name, typeID, subtypeID, _, _, _, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon = GetLFGRandomDungeonInfo(i)
		--print(id, name, typeID, subtypeID, isHolidayDungeon)
		
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		--print(id, name)
		if((isAvailableForPlayer or not hideIfNotJoinable)) then
			if(isAvailableForAll) then
				local mode = GetLFGMode(1, id)
				info.text = isHolidayDungeon and "(Event) " .. name or name

				info.checked = mode == "queued"
				info.icon = miog.MAP_INFO[id] and miog.MAP_INFO[id].icon or miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or nil
				info.parentIndex = subtypeID

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

local function updateDungeons()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.mainTab.QueueDropDown
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

	--DevTools_Dump(miog.GROUP_ID_TO_LFG_ID)
end

local function updateRaidFinder()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.mainTab.QueueDropDown
	if(queueDropDown.entryFrameTree[4].List.framePool) then
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

local function findBattlegroundIconByName(mapName)
	for bgID, bgEntry in pairs(miog.BATTLEGROUNDS) do
		if(bgEntry[2] == mapName) then
			--print("HIT", mapName)
			return bgEntry[16] ~= 0 and bgEntry[16] or 525915
		end
	end

	return nil
end

local function findBattlegroundIconByID(mapID)
	for bgID, bgEntry in pairs(miog.BATTLEGROUNDS) do
		if(bgEntry[1] == mapID) then
			return bgEntry[16] ~= 0 and bgEntry[16] or 525915
		end
	end

	return nil
end

local function findBrawlIconByName(mapName)
	for brawlID, brawlEntry in pairs(miog.BRAWL) do
		if(brawlEntry[2] == mapName) then
			return findBattlegroundIconByID(brawlEntry[4])
		end
	end

	return nil
end

local function findBrawlIconByID(mapID)
	for brawlID, brawlEntry in pairs(miog.BRAWL) do
		if(brawlEntry[1] == mapID) then
			return findBattlegroundIconByID(brawlEntry[4])
		end
	end

	return nil
end

local function updatePvP()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.mainTab.QueueDropDown

	if(queueDropDown.entryFrameTree[5].List.securePool) then
		queueDropDown.entryFrameTree[5].List.securePool:ReleaseAll()
	end

	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil
	info.parentIndex = 5
	info.type2 = "unrated"

	for index = 1, 5, 1 do
		local currentBGQueue = index == 1 and C_PvP.GetRandomBGInfo() or index == 2 and C_PvP.GetRandomEpicBGInfo() or index == 3 and C_PvP.GetSkirmishInfo(4) or index == 4 and C_PvP.GetAvailableBrawlInfo() or index == 5 and C_PvP.GetSpecialEventBrawlInfo()

		if(currentBGQueue and (index == 3 or currentBGQueue.canQueue)) then
			info.text = index == 1 and RANDOM_BATTLEGROUNDS or index == 2 and RANDOM_EPIC_BATTLEGROUND or index == 3 and "Skirmish" or currentBGQueue.name
			info.checked = false
			--info.disabled = index == 1 or index == 2
			info.icon = index < 3 and findBattlegroundIconByID(currentBGQueue.bgID) or index == 3 and currentBGQueue.icon or index > 3 and (findBrawlIconByID(currentBGQueue.brawlID) or findBrawlIconByName(currentBGQueue.name))
			info.type2 = "unrated"
			info.func = nil

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

		--HonorFrame.BonusFrame.Arena1Button:ClearAllPoints()
		--HonorFrame.BonusFrame.Arena1Button:SetPoint("LEFT", HonorFrame.BonusFrame, "LEFT", (HonorFrame.BonusFrame:GetWidth() - HonorFrame.BonusFrame.Arena1Button:GetWidth()) / 2, 0)

		

	info.text = PVP_RATED_SOLO_SHUFFLE
	-- info.checked = false
	local minItemLevel = C_PvP.GetRatedSoloShuffleMinItemLevel()
	local _, _, playerPvPItemLevel = GetAverageItemLevel();
	info.disabled = playerPvPItemLevel < minItemLevel
	--info.icon = bgIDToIcon[currentBGQueue.bgID]
	
	info.tooltipOnButton = true
	info.tooltipWhileDisabled = true
	info.type2 = "rated"
	info.tooltipTitle = "Unable to queue for this activity."
	info.tooltipText = generalTooltip or format(_G["INSTANCE_UNAVAILABLE_SELF_PVP_GEAR_TOO_LOW"], "", minItemLevel, playerPvPItemLevel);
	info.func = nil
	--info.func = function()
	--	JoinRatedSoloShuffle()
	-- end

	-- UIDropDownMenu_AddButton(info, level)
	local soloFrame = queueDropDown:CreateEntryFrame(info)
	soloFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.RatedSoloShuffle, soloFrame)

	info.text = ARENA_BATTLES_2V2
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 2 and string.format(PVP_ARENA_NEED_LESS, groupSize - 2) or groupSize < 2 and string.format(PVP_ARENA_NEED_MORE, 2 - groupSize)
	info.disabled = groupSize ~= 2
	--info.func = function()
	--	JoinArena()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local twoFrame = queueDropDown:CreateEntryFrame(info)
	twoFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.Arena2v2, twoFrame)

	info.text = ARENA_BATTLES_3V3
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

	info.text = PVP_RATED_BATTLEGROUNDS
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
	moreFrame:SetAttribute("macrotext1", "/run PVEFrame_ShowFrame(\"PVPUIFrame\", \"HonorFrame\")" .. "\r\n" .. "/run HonorFrame.BonusFrame.Arena1Button:ClearAllPoints()" .. "\r\n" .. 
	"/run HonorFrame.BonusFrame.Arena1Button:SetPoint(\"LEFT\", HonorFrame.BonusFrame, \"LEFT\", (HonorFrame.BonusFrame:GetWidth() - HonorFrame.BonusFrame.Arena1Button:GetWidth()) / 2, 0)")
end

miog.updatePvP = updatePvP

local function updateQueueDropDown()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.mainTab.QueueDropDown
	queueDropDown:ResetDropDown()

	print("UPDATE QUEUE")
--SetLFGDungeon(LE_LFG_CATEGORY_RF, RaidFinderQueueFrame.raid);
	--JoinLFG(LE_LFG_CATEGORY_RF);
	--JoinSingleLFG(LE_LFG_CATEGORY_RF, RaidFinderQueueFrame.raid);
	--LFG_QueueForInstanceIfEnabled(category, queueID);
	--IsLFGDungeonJoinable
	
	--[[function LFG_QueueForInstanceIfEnabled(category, queueID)
		if ( not LFGIsIDHeader(queueID) and LFGEnabledList[queueID] and not LFGLockList[queueID] ) then
			SetLFGDungeon(category, queueID);
			return true;
		end
		return false;
	end]]

	--SetLFGDungeon(3, 2368)
	--JoinLFG(3)
	--SetLFGDungeon(3, 2370)
	--JoinLFG(3)
	--SetLFGDungeon(3, 2399)
	--JoinLFG(3)
	--SetLFGDungeon(3, 2400)
	--JoinLFG(3)
	

	--[[local function GetLFGLockList()
		local lockInfo = C_LFGInfo.GetLFDLockStates();
		local lockMap = {};
		for _, lock in ipairs(lockInfo) do
			lockMap[lock.lfgID] = lock;
		end
		return lockMap;
	end

	--local LFGLockList = GetLFGLockList()
	LFGEnabledList = GetLFDChoiceEnabledState(LFGEnabledList)]]
	
 
	--UIDropDownMenu_Initialize(optionDropdown, function(self, level, menuList)
		--local info = UIDropDownMenu_CreateInfo()

		--[[info.text = "Dungeons"
		-- info.checked = false
		-- info.menuList = 1
		-- info.hasArrow = true
		-- UIDropDownMenu_AddButton(info)

		info.text = "Raid"
		-- info.checked = false
		-- info.menuList = 2
		-- info.hasArrow = true
		-- UIDropDownMenu_AddButton(info)

		info.text = "Outdoor"
		-- info.checked = false
		-- info.menuList = 4
		-- info.hasArrow = true
		-- UIDropDownMenu_AddButton(info)

		info.text = "Random Dungeon"
		-- info.checked = false
		-- info.menuList = 6
		-- info.hasArrow = true
		-- UIDropDownMenu_AddButton(info)

		for _, dungeonID in ipairs(dungeonList) do
			local name, typeID = GetLFGDungeonInfo(dungeonID)

			if not LFGLockList[dungeonID] then
				--print(name)
					info.text = name
					-- info.checked = false
					print(typeID)
					-- UIDropDownMenu_AddButton(info, typeID)
				--print(dungeonID, name)
				
			end
		end]]

		local info = {}
			info.text = "Dungeons (Normal)"
			info.hasArrow = true
			info.level = 1
			info.index = 1
			-- info.checked = false
			-- info.menuList = 1
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "Dungeons (Heroic)"
			info.hasArrow = true
			info.level = 1
			info.index = 2
			-- info.checked = false
			-- info.menuList = 2
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "Follower"
			info.hasArrow = true
			info.level = 1
			info.index = 3
			-- info.checked = false
			-- info.menuList = 3
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "Raid Finder"
			info.hasArrow = true
			info.level = 1
			info.index = 4
			-- info.checked = false
			-- info.menuList = 4
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "PvP"
			info.hasArrow = true
			info.level = 1
			info.index = 5
			-- info.checked = false
			-- info.menuList = 7
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "Pet Battle"
			info.entryType = "option"
			info.level = 1
			info.index = 6
			info.checked = false
			info.func = function()
				C_PetBattles.StartPVPMatchmaking()
			end

			queueDropDown:CreateEntryFrame(info)
		

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

local queuedList = {};

local function createQueueFrame(queueInfo)
	local queueFrame = queueSystem.queueFrames[queueInfo[18]]

	if(not queueSystem.queueFrames[queueInfo[18]]) then
		queueFrame = queueSystem.framePool:Acquire()
		queueFrame.ActiveIDFrame:Hide()
		queueFrame.CancelApplication:SetMouseClickEnabled(true)
		queueFrame.CancelApplication:RegisterForClicks("LeftButtonDown")

		miog.createFrameBorder(queueFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		queueSystem.queueFrames[queueInfo[18]] = queueFrame

		queueFrameIndex = queueFrameIndex + 1
		queueFrame.layoutIndex = queueFrameIndex
	
	end

	queueFrame:SetWidth(miog.mainTab.QueuePanel:GetWidth() - 7)
	
	queueFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

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
	miog.mainTab.QueuePanel.Container:MarkDirty()
end

miog.createQueueFrame = createQueueFrame

miog.createPVEFrameReplacement = createPVEFrameReplacement

miog.scriptReceiver = CreateFrame("Frame", "MythicIOGrabber_ScriptReceiver", frame, "BackdropTemplate") ---@class Frame
miog.scriptReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
miog.scriptReceiver:RegisterEvent("PLAYER_LOGIN")
miog.scriptReceiver:RegisterEvent("UPDATE_LFG_LIST")
miog.scriptReceiver:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
miog.scriptReceiver:SetScript("OnEvent", miog.OnEvent)

hooksecurefunc(QueueStatusFrame, "Update", function()
	--print("LFG")

	queueSystem.queueFrames = {}
	queueSystem.framePool:ReleaseAll()

	local gotInvite = false
	miog.inviteBox.framePool:ReleaseAll()

	local queueIndex = 1

	--Try each LFG type
	for categoryID = 1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(categoryID);

		if (mode and submode ~= "noteleport" ) then
			--local activeIndex = nil;
			--local allNames = {};

				--Get the list of everything we're queued for
			queuedList = GetLFGQueuedList(categoryID, queuedList) or {}
		
			local activeID = select(18, GetLFGQueueStats(categoryID));
			for queueID, queued in pairs(queuedList) do
				mode, submode = GetLFGMode(categoryID, activeID);

				if(queued == true) then
					local inParty, joined, isQueued, noPartialClear, achievements, lfgComment, slotCount, categoryID2, leader, tank, healer, dps, x1, x2, x3, x4 = GetLFGInfoServer(categoryID, queueID);
					local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, queueID)
					--print(activeID, queueID, averageWait, tankWait, healerWait, damageWait, myWait)
					--print(queueID, hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime)

					--DevTools_Dump({GetLFGQueueStats(categoryID, queueID)})

					local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)
			
					local isFollowerDungeon = queueID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(queueID)

					local frameData = {
						[1] = hasData,
						[2] = isFollowerDungeon and "Follower" or subtypeID == 1 and "Normal" or subtypeID == 2 and "Heroic" or subtypeID == 3 and "Raid Finder",
						[11] = name,
						[12] = averageWait,
						[17] = {"queued", queuedTime},
						[18] = queueID,
						[20] = mapID and miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[queueID] and miog.LFG_ID_INFO[queueID].icon or fileID or findBattlegroundIconByName(name) or findBrawlIconByName(name) or nil
					}

					if(hasData) then
						miog.createQueueFrame(frameData)

						if(categoryID == 3 and activeID == queueID) then
							miog.queueSystem.queueFrames[queueID].ActiveIDFrame:Show()

						else
							miog.queueSystem.queueFrames[queueID].ActiveIDFrame:Hide()
						
						end

						miog.queueSystem.queueFrames[queueID].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
						miog.queueSystem.queueFrames[queueID].CancelApplication:SetAttribute("macrotext1", "/run LeaveSingleLFG(" .. categoryID .. "," .. queueID .. ")")

						--print(miog.queueSystem.queueFrames[queueID].CancelApplication:GetAttribute("macrotext1"))
					
						--[[miog.queueSystem.queueFrames[queueID].CancelApplication:SetScript("PostClick", function(self, button)
							if(button == "LeftButton") then
								local mode2, submode2 = GetLFGMode(categoryID, queueID)
								print(categoryID, queueID, mode2, submode2)
								LeaveSingleLFG(categoryID, queueID)
							end
						end)]]
					else
						if(mode == "proposal") then
							local frame = miog.createInviteFrame(frameData)
							frame.Decline:SetAttribute("type", "macro") -- left click causes macro
							frame.Decline:SetAttribute("macrotext1", "/run RejectProposal()")

							frame.Accept:SetAttribute("type", "macro") -- left click causes macro
							frame.Accept:SetAttribute("macrotext1", "/run AcceptProposal()")
							
							--LFGListInviteDialog_Accept(self:GetParent());

							gotInvite = true
						end

					end
				end
			end
		
			local subTitle;
			local extraText;
		
			--[[if ( categoryID == LE_LFG_CATEGORY_RF and #allNames > 1 ) then --HACK - For now, RF works differently.
				--We're queued for more than one thing
				subTitle = table.remove(allNames, activeIndex);
				extraText = string.format(ALSO_QUEUED_FOR, table.concat(allNames, PLAYER_LIST_DELIMITER));
			elseif ( mode == "suspended" ) then
				local suspendedPlayers = GetLFGSuspendedPlayers(categoryID);
				if (suspendedPlayers and #suspendedPlayers > 0 ) then
					extraText = "";
					for i = 1, 3 do
						if (suspendedPlayers[i]) then
							if ( i > 1 ) then
								extraText = extraText .. "\n";
							end
							extraText = extraText .. string.format(RAID_MEMBER_NOT_READY, suspendedPlayers[i]);
						end
					end
				end
			end]]

			if(activeID) then
				if ( mode == "queued" ) then

					local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount, _, leader, tank, healer, dps = GetLFGInfoServer(categoryID, activeID);
					local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, activeID);
					if(categoryID == LE_LFG_CATEGORY_SCENARIO) then --Hide roles for scenarios
						tank, healer, dps = nil, nil, nil;
						totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds = nil, nil, nil, nil, nil, nil;

					elseif(categoryID == LE_LFG_CATEGORY_WORLDPVP) then
						--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_IN_PROGRESS, subTitle, extraText);
					else
						--QueueStatusEntry_SetFullDisplay(entry, GetDisplayNameFromCategory(category), queuedTime, myWait, tank, healer, dps, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText);
						--miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(activeID)}, {GetLFGQueueStats(categoryID)})
					end
				elseif ( mode == "proposal" ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_PROPOSAL, subTitle, extraText);
				elseif ( mode == "listed" ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_LISTED, subTitle, extraText);
				elseif ( mode == "suspended" ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_SUSPENDED, subTitle, extraText);
				elseif ( mode == "rolecheck" ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS, subTitle, extraText);
				elseif ( mode == "lfgparty" or mode == "abandonedInDungeon" ) then
					--[[local title;
					if (C_PvP.IsInBrawl()) then
						local brawlInfo = C_PvP.GetActiveBrawlInfo();
						if (brawlInfo and brawlInfo.canQueue and brawlInfo.longDescription) then
							title = brawlInfo.name;
							if (subTitle) then
								subTitle = QUEUED_STATUS_BRAWL_RULES_SUBTITLE:format(brawlInfo.longDescription, subTitle);
							else
								subTitle = brawlInfo.longDescription;
							end
						end
					else
						title = GetDisplayNameFromCategory(category);
					end
					
					QueueStatusEntry_SetMinimalDisplay(entry, title, QUEUED_STATUS_IN_PROGRESS, subTitle, extraText);]]
				else
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_UNKNOWN, subTitle, extraText);
				end
			end

			--[[for categoryID, listEntry in ipairs(LFGQueuedForList) do
				for dungeonID, queued in pairs(listEntry) do
					if(queued == true) then
						--DevTools_Dump({GetLFGDungeonInfo(dungeonID)})
						--DevTools_Dump({})
						local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID)
	
						if (hasData and queuedTime and not miog.queueSystem.queueFrames[dungeonID]) then
							miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(dungeonID)}, {GetLFGQueueStats(categoryID)})
						end
					end
				end
			end]]
			
			queueIndex = queueIndex + 1
		else
		end
	end

	--Try LFGList entries
	local isActive = C_LFGList.HasActiveEntryInfo();
	if ( isActive ) then
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants();
		--QueueStatusEntry_SetMinimalDisplay(entry, activeEntryInfo.name, QUEUED_STATUS_LISTED, string.format(LFG_LIST_PENDING_APPLICANTS, numActiveApplicants));
		local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
		local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)

		local icon = miog.retrieveBackgroundImageFromGroupActivityID(activityInfo.groupFinderActivityGroupID, "icon")

		local frameData = {
			[1] = true,
			[2] = groupInfo and groupInfo.name or activityInfo.shortName,
			[11] = "YOUR LISTING",
			[12] = -1,
			[17] = {"duration", activeEntryInfo.duration},
			[18] = "YOURLISTING",
			[20] = miog.ACTIVITY_ID_INFO[activeEntryInfo.activityID].icon or icon
		}

		miog.createQueueFrame(frameData)

		miog.queueSystem.queueFrames["YOURLISTING"].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
		miog.queueSystem.queueFrames["YOURLISTING"].CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.RemoveListing()")
		miog.queueSystem.queueFrames["YOURLISTING"]:SetScript("OnMouseDown", function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)
		end)

		--miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(activeID)}, {GetLFGQueueStats(categoryID)})
	end

	--Try LFGList applications
	local applications = C_LFGList.GetApplications()
	if(applications) then
		for _, v in ipairs(applications) do
		--for i=1, #apps do
			local id, appStatus, pendingStatus, appDuration, role = C_LFGList.GetApplicationInfo(v)

			local identifier = "APPLICATION_" .. id
			if(appStatus == "applied" or appStatus == "invited") then
				local searchResultInfo = C_LFGList.GetSearchResultInfo(id);
				--local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);

				local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
				local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)

				local icon = miog.retrieveBackgroundImageFromGroupActivityID(activityInfo.groupFinderActivityGroupID, "icon")
		
				local frameData = {
					[1] = true,
					[2] = groupInfo.name,
					[11] = searchResultInfo.name,
					[12] = -1,
					[17] = {"duration", appDuration},
					[18] = identifier,
					[20] = icon
				}

				if(appStatus == "applied") then
					miog.createQueueFrame(frameData)
					miog.queueSystem.queueFrames[identifier].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
					miog.queueSystem.queueFrames[identifier].CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.CancelApplication(" .. id .. ")")
					miog.queueSystem.queueFrames[identifier]:SetScript("OnMouseDown", function()
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
						LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)
						LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, activityInfo.categoryID, activityInfo.filters, LFGListFrame.baseFilters)
						LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
						LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
					end)

				elseif(appStatus == "invited") then
					miog.queueSystem.queueFrames[identifier].CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.DeclineInvite(" .. id .. ")")
			
					local frame = miog.createInviteFrame(frameData)
					
					frame.Decline:SetAttribute("type", "macro") -- left click causes macro
					frame.Decline:SetAttribute("macrotext1", "/run C_LFGList.DeclineInvite(" .. id .. ")")

					frame.Accept:SetAttribute("type", "macro") -- left click causes macro
					frame.Accept:SetAttribute("macrotext1", "/run C_LFGList.AcceptInvite(" .. id .. ")")

					gotInvite = true
				end
			end
		end
	end
--[[
	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();

	--Try PvP Role Check
	if ( inProgress and isBattleground ) then
		QueueStatusEntry_SetUpPVPRoleCheck(entry);
	end

	local readyCheckInProgress, readyCheckIsBattleground = GetLFGReadyCheckUpdate();

	-- Try PvP Ready Check
	if ( readyCheckInProgress and readyCheckIsBattleground ) then
		QueueStatusEntry_SetUpPvPReadyCheck(entry);
	end]]

	--Try all PvP queues
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend, queueType, gameType, _, _, _, longDescription, x1 = GetBattlefieldStatus(i);
		if ( status and status ~= "none" and status ~= "error" ) then
			local queuedTime = GetTime() - GetBattlefieldTimeWaited(i) / 1000
			local estimatedTime = GetBattlefieldEstimatedWaitTime(i) / 1000
			local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
			local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);
			local allowsDecline = PVPHelper_QueueAllowsLeaveQueueWithMatchReady(queueType)
			
			local frameData = {
				[1] = true,
				[2] = gameType,
				[11] = mapName,
				[12] = estimatedTime,
				[17] = {"queued", queuedTime},
				[18] = mapName,
				[20] = findBattlegroundIconByName(mapName) or findBrawlIconByName(mapName)
			}
			
			if ( status == "queued" ) then
				if ( suspend ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_SUSPENDED);
				else
					--QueueStatusEntry_SetFullDisplay(entry, mapName, queuedTime, estimatedTime, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText, assignedSpec);


					--local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
					--local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);

					--		1		2			3			4			5			6			7				8		9				10				11				12			13			14			15		16			17
					--local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime

					--print(mapName, queueType, short, long)

					--BattlemasterList
					--PvpBrawl

					if (mapName and queuedTime) then
						--print("NEW PVP")
						miog.createQueueFrame(frameData)
						--print("CREATED " .. mapName)
						--miog.queueSystem.queueFrames[mapName].CancelApplication:SetScript("OnClick",  SecureActionButton_OnClick)
					end

					local currentDeclineButton = "/click QueueStatusButton RightButton" .. "\r\n" ..
					(
						queueIndex == 1 and "/click [nocombat]DropDownList1Button2 Left Button" or
						queueIndex == 2 and "/click [nocombat]DropDownList1Button4 Left Button" or
						queueIndex == 3 and "/click [nocombat]DropDownList1Button6 Left Button" or
						queueIndex == 4 and "/click [nocombat]DropDownList1Button8 Left Button" or
						queueIndex == 5 and "/click [nocombat]DropDownList1Button10 Left Button" or
						queueIndex == 6 and "/click [nocombat]DropDownList1Button12 Left Button" or
						queueIndex == 7 and "/click [nocombat]DropDownList1Button14 Left Button" or
						queueIndex == 8 and "/click [nocombat]DropDownList1Button16 Left Button" or
						queueIndex == 9 and "/click [nocombat]DropDownList1Button18 Left Button" or
						queueIndex == 10 and "/click [nocombat]DropDownList1Button20 Left Button" or
						queueIndex == 11 and "/click [nocombat]DropDownList1Button22 Left Button" or
						queueIndex == 12 and "/click [nocombat]DropDownList1Button24 Left Button"
					)

					if(miog.queueSystem.queueFrames[mapName]) then
						--print("PVP MACRO")
						
						miog.queueSystem.queueFrames[mapName].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
						miog.queueSystem.queueFrames[mapName].CancelApplication:SetAttribute("macrotext1", currentDeclineButton)

						--print(miog.queueSystem.queueFrames[mapName].CancelApplication:GetAttribute("macrotext1"))
					end

					queueIndex = queueIndex + 1
					

				end
			elseif ( status == "confirm" ) then
				
				local currentDeclineButton = queueIndex == 1 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button3 Left Button"
				or queueIndex == 2 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button6 Left Button"
				or queueIndex == 3 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button9 Left Button"
				or queueIndex == 4 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button12 Left Button"
				or queueIndex == 5 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button15 Left Button"
				or queueIndex == 6 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button18 Left Button"
				or queueIndex == 7 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button21 Left Button"
				or queueIndex == 8 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button24 Left Button"
				or queueIndex == 9 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button27 Left Button"
				or queueIndex == 10 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button30 Left Button"
				or queueIndex == 11 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button33 Left Button"
				or queueIndex == 12 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button36 Left Button"
				

				local currentAcceptButton = queueIndex == 1 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button2 Left Button"
				or queueIndex == 2 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button4 Left Button"
				or queueIndex == 3 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button6 Left Button"
				or queueIndex == 4 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button8 Left Button"
				or queueIndex == 5 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button10 Left Button"
				or queueIndex == 6 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button12 Left Button"
				or queueIndex == 7 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button14 Left Button"
				or queueIndex == 8 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button16 Left Button"
				or queueIndex == 9 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button18 Left Button"
				or queueIndex == 10 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button20 Left Button"
				or queueIndex == 11 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button22 Left Button"
				or queueIndex == 12 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button24 Left Button"

				local frame = miog.createInviteFrame(frameData)
				frame.activeIndex = i
				frame.Decline:SetAttribute("type", "macro") -- left click causes macro
				--frame.Decline = Mixin(frame.Decline, PVPReadyDialogLeaveButtonMixin)
				--frame.Decline:SetAttribute("macrotext1", currentDeclineButton)

				frame.Accept:SetAttribute("type", "macro") -- left click causes macro
				frame.Accept:SetAttribute("macrotext1", currentAcceptButton)

				if(allowsDecline) then
					frame.Decline:Show()

				else
					frame.Decline:Hide()
				
				end

				gotInvite = true
			elseif ( status == "active" ) then
				if (mapName) then
					--local hasLongDescription = longDescription and longDescription ~= "";
					--local text = hasLongDescription and longDescription or nil;
					--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS, text);
				else
					--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS);
				end
			elseif ( status == "locked" ) then
				--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_LOCKED, QUEUED_STATUS_LOCKED_EXPLANATION);
			else
				--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_UNKNOWN);
			end
		elseif(status) then
			--print(mapName)
		
		end
	end

	--Try all World PvP queues
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID, expireTime, averageWaitTime, queuedTime, suspended = GetWorldPVPQueueStatus(i)
		if ( status and status ~= "none" ) then
			--QueueStatusEntry_SetUpWorldPvP(entry, i);
			local frameData = {
				[1] = true,
				[2] = "World PvP",
				[11] = mapName,
				[12] = averageWaitTime,
				[17] = {"queued", queuedTime},
				[18] = mapName,
				[20] = "interface/icons/inv_currency_petbattle.blp"
			}
	
			if (status == "queued") then
				miog.createQueueFrame(frameData)
	
				if(miog.queueSystem.queueFrames["PETBATTLE"]) then
					miog.queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("type", "macro")
					miog.queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")
	
				end
	
				queueIndex = queueIndex + 1
	
			elseif(status == "proposal") then
				local frame = miog.createInviteFrame(frameData)
				frame.Decline:SetAttribute("type", "macro")
				frame.Decline:SetAttribute("macrotext1", "/run C_PetBattles.DeclineQueuedPVPMatch()")
	
				frame.Accept:SetAttribute("type", "macro")
				frame.Accept:SetAttribute("macrotext1", "/run QueueStatusDropDown_AcceptQueuedPVPMatch()")
			
			end
		end
	end

	--World PvP areas we're currently in
	if ( CanHearthAndResurrectFromArea() ) then
		--QueueStatusEntry_SetUpActiveWorldPVP(entry);
	end

	--Pet Battle PvP Queue
	local pbStatus, estimate, queued = C_PetBattles.GetPVPMatchmakingInfo();
	if ( pbStatus ) then
		local frameData = {
			[1] = true,
			[2] = "",
			[11] = "Pet Battle",
			[12] = estimate,
			[17] = {"queued", queued},
			[18] = "PETBATTLE",
			[20] = "interface/icons/inv_currency_petbattle.blp"
		}

		if (pbStatus == "queued") then
			miog.createQueueFrame(frameData)

			if(miog.queueSystem.queueFrames["PETBATTLE"]) then
				miog.queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("type", "macro")
				miog.queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")

			end

			queueIndex = queueIndex + 1

		elseif(pbStatus == "proposal") then
			local frame = miog.createInviteFrame(frameData)
			frame.Decline:SetAttribute("type", "macro")
			frame.Decline:SetAttribute("macrotext1", "/run C_PetBattles.DeclineQueuedPVPMatch()")

			frame.Accept:SetAttribute("type", "macro")
			frame.Accept:SetAttribute("macrotext1", "/run QueueStatusDropDown_AcceptQueuedPVPMatch()")
		
		end
	end

	miog.inviteBox:SetShown(gotInvite)
end)