local addonName, miog = ...
local wticc = WrapTextInColorCode

-- /dump C_LFGList.GetAdvancedFilter()

local allFilters = {}
local _, id = UnitClassBase("player")
local selectedDifficultyIndex = nil

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
	local blizzardFilters = C_LFGList.GetAdvancedFilter()
	local missingFilters = MIOG_NewSettings.currentBlizzardFilters == nil and true or false
	local filtersUpToDate = blizzardFilters == MIOG_NewSettings.currentBlizzardFilters

	if(missingFilters or not filtersUpToDate) then
		MIOG_NewSettings.currentBlizzardFilters = blizzardFilters

		if(not MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][2]) then
			MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][2] = miog.getDefaultFilters()
		end

		for k, v in pairs(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"]) do
			if(k == 2) then
				v.minRating = blizzardFilters.minimumRating
				v.minHealers = v.minHealers == 0 and blizzardFilters.hasHealer == true and 1 or v.minHealers or 0
				v.minTanks = v.minTanks == 0 and blizzardFilters.hasTank == true and 1 or v.minTanks or 0

				v.needsMyClass = blizzardFilters.needsMyClass

				v.filterForRoles["TANK"] = blizzardFilters.needsTank == false
				v.filterForRoles["HEALER"] = blizzardFilters.needsHealer == false
				v.filterForRoles["DAMAGER"] = blizzardFilters.needsDamage == false
			end
		end
	end
end

miog.convertAdvancedBlizzardFiltersToMIOGFilters = convertAdvancedBlizzardFiltersToMIOGFilters

local function isBlizzardBaseFilterActive()

end

local function convertFiltersToAdvancedBlizzardFilters()
	local categoryID = LFGListFrame.SearchPanel.categoryID or LFGListFrame.CategorySelection.selectedCategory

	if(categoryID == 2) then
		local miogFilters = {}
		local currentSettings = MIOG_NewSettings.newFilterOptions["LFGListFrame.SearchPanel"][categoryID]

		miogFilters.minimumRating = currentSettings.rating and currentSettings.rating.minimum
		miogFilters.hasHealer = currentSettings.healer and currentSettings.healer.value
		and currentSettings.healer.linked == false
		and currentSettings.tank.linked == false
		and currentSettings.damager.linked == false
		and currentSettings.healer.minimum > 0

		miogFilters.hasTank = currentSettings.tank and currentSettings.tank.value
		and currentSettings.tank.linked == false
		and currentSettings.healer.linked == false
		and currentSettings.damager.linked == false
		and currentSettings.tank.minimum > 0

		local difficultyFiltered = currentSettings.difficulty and currentSettings.difficulty.value

		miogFilters.difficultyNormal = difficultyFiltered and currentSettings.difficulty.id == DifficultyUtil.ID.DungeonNormal
		miogFilters.difficultyHeroic = difficultyFiltered and currentSettings.difficulty.id == DifficultyUtil.ID.DungeonHeroic
		miogFilters.difficultyMythic = difficultyFiltered and currentSettings.difficulty.id == DifficultyUtil.ID.DungeonMythic
		miogFilters.difficultyMythicPlus = difficultyFiltered and currentSettings.difficulty.id == DifficultyUtil.ID.DungeonChallenge

		miogFilters.needsTank = currentSettings.roles and currentSettings.roles["TANK"] == false
		miogFilters.needsHealer = currentSettings.roles and currentSettings.roles["HEALER"] == false
		miogFilters.needsDamage = currentSettings.roles and currentSettings.roles["DAMAGER"] == false
		miogFilters.needsMyClass = currentSettings.classes and currentSettings.classes[id] == false

		miogFilters.activities = {}

		if(currentSettings.activities.value) then
			for k, v in pairs(currentSettings.activities) do
				if(type(v) == "table" and v.value) then
					miogFilters.activities[#miogFilters.activities+1] = k
				end
				
			end
		end

		C_LFGList.SaveAdvancedFilter(miogFilters)
	end
end

local function convertAndRefresh()
	convertFiltersToAdvancedBlizzardFilters()
		
	if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
		miog.newUpdateFunction()

	elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
		C_LFGList.RefreshApplicants()

	end
end

--[[local function addOptionToFilterFrame(parent, _, text, name)
	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOption")
	filterOption:SetHeight(25)
	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][name] = self:GetChecked()

		convertAndRefresh()
	end)

	filterOption.Name:SetText(text)

	parent[name] = filterOption

	return filterOption
end

local function addDualNumericSpinnerToFilterFrame(parent, name, text, range)
	local minName = "min" .. name
	local maxName = "max" .. name
	local settingName = "filterFor" .. name

	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualSpinnerTemplate")
	filterOption:SetHeight(25)
	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][settingName] = self:GetChecked()

		convertAndRefresh()
	end)

	filterOption.Name:SetText(text or name)

	parent[name] = filterOption
	parent["Linked" .. name] = filterOption.Link


	filterOption.Link:SetScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID]["linked" .. name] = self:GetChecked()

		convertAndRefresh()
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

					MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

					self:SetValue(spinnerValue)

					if(i == 1) then
						if(parent[name].Maximum:GetValue() < spinnerValue) then
							parent[name].Maximum:SetValue(spinnerValue)
							MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][maxName] = spinnerValue

						end

					else
						if(parent[name].Minimum:GetValue() > spinnerValue) then
							parent[name].Minimum:SetValue(spinnerValue)
							MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][minName] = spinnerValue

						end
					end

					convertAndRefresh()
				end
			end
		end)

		currentSpinner.DecrementButton:SetScript("OnMouseDown", function(self)
			currentSpinner:Decrement()

			local spinnerValue = currentSpinner:GetValue()

			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

			MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

			if(parent[name].Minimum:GetValue() > spinnerValue) then
				parent[name].Minimum:SetValue(spinnerValue)
				MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][minName] = spinnerValue

			end

			currentSpinner:ClearFocus()

			convertAndRefresh()
		end)

		currentSpinner.IncrementButton:SetScript("OnMouseDown", function()
			currentSpinner:Increment()

			local spinnerValue = currentSpinner:GetValue()

			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

			MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

			if(parent[name].Maximum:GetValue() < spinnerValue) then
				parent[name].Maximum:SetValue(spinnerValue)
				MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][maxName] = spinnerValue

			end

			currentSpinner:ClearFocus()

			convertAndRefresh()
		end)
	end

	return filterOption

end

local function addDualNumericFieldsToFilterFrame(parent, name)
	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualFieldTemplate")
	filterOption:SetHeight(25)
	local settingName = "filterFor" .. name

	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][settingName] = self:GetChecked()

		convertAndRefresh()
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
		--currentField:SetMaxLetters(4)
		currentField:HookScript("OnTextChanged", function(self, ...)
			if(MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()]) then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				
				local text = tonumber(self:GetText())
				local currentPanel = LFGListFrame.activePanel:GetDebugName()
				local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
			
				MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = text ~= nil and text or 0

				convertFiltersToAdvancedBlizzardFilters()

				if(MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID][settingName]) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.newUpdateFunction()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end
			end
		end)
	end

	return filterOption

end

--[ [
	Recommended 1
	NotRecommended 2
	PVE 4
	PVP 8
	Timerunning 16
	CurrentExpansion 32
	CurrentSeason 64
	NotCurrentSeason 128
] ]

local function updateRaidCheckboxes(reset)
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(3, Enum.LFGListFilter.Recommended);
	local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, 5)

	local sortedExpansionRaids = {}

	if(seasonGroups and #seasonGroups > 0) then
		for _, v in ipairs(seasonGroups) do
			local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
			miog.checkSingleMapIDForNewData(activityInfo.mapID)
			sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName, bosses = activityInfo.bosses}

		end
	end

	if(worldBossActivity and #worldBossActivity > 0) then
		local activityInfo = C_LFGList.GetActivityInfoTable(worldBossActivity[1])
		sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}

	end

	table.sort(sortedExpansionRaids, function(k1, k2)
		return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID
	end)

	for k, activityEntry in ipairs(sortedExpansionRaids) do
		local currentButton = miog.FilterPanel.IndexedOptions.Raids.Buttons[k]

		if(type(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID]) == "boolean" or MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID] == nil) then
			MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID] = {setting = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID], bosses = {}}
		end

		currentButton:SetChecked(reset or MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].setting)
		currentButton:HookScript("OnClick", function(self)
			MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].setting = self:GetChecked()

			if(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.FilterPanel.IndexedOptions.Raids.Rows[k]:MarkDirty()
					miog.FilterPanel.IndexedOptions.Raids:MarkDirty()
					miog.FilterPanel.IndexedOptions:MarkDirty()
					miog.FilterPanel:MarkDirty()

					miog.newUpdateFunction()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end

		end)
		
		currentButton.FontString:SetText(activityEntry.name)

		if(activityEntry.bosses) then
			local currentBossListRow = miog.FilterPanel.IndexedOptions.Raids.Rows[k]

			currentBossListRow.Reset:SetScript("OnClick", function(self)
				local currentRow = self:GetParent()

				for x, y in ipairs(currentRow.BossFrames) do
					--bossFrame:SetPoint("LEFT", currentBossListRow, "LEFT", (x - 1) * (bossFrame:GetWidth()) + 3, 0)
					y.Icon:SetDesaturated(true)
					y.Border:Hide()
					
				end

				MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses = {}

				miog.newUpdateFunction()
			end)

			if(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raidBosses) then
				MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raidBosses
				MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raidBosses = nil

			end
			
			for x, y in ipairs(activityEntry.bosses) do
				if(currentBossListRow.BossFrames[x]) then
					--SetPortraitTextureFromCreatureDisplayID(currentBossListRow.BossFrames[x].Icon, y.creatureDisplayInfoID)
					
				else
					MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] or 0

					local bossFrame = CreateFrame("Frame", nil, currentBossListRow, "MIOG_FilterPanelBossFrameTemplate")
					bossFrame.layoutIndex = x
					SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, y.creatureDisplayInfoID)
					
					bossFrame.Icon:SetDesaturated(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] or true)

					if(bossFrame.BorderMask == nil) then
						bossFrame.BorderMask = bossFrame:CreateMaskTexture()
						bossFrame.BorderMask:SetAllPoints(bossFrame.Border)
						bossFrame.BorderMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
						bossFrame.Border:AddMaskTexture(bossFrame.BorderMask)
					end

					local baseShortValue = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x]

					if(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] > 0) then
						bossFrame.Border:SetColorTexture(CreateColorFromHexString(baseShortValue == 1 and miog.CLRSCC.red or baseShortValue == 2 and miog.CLRSCC.green or miog.CLRSCC.white):GetRGBA())
						bossFrame.Border:Show()

					else
						bossFrame.Border:Hide()

					end

					bossFrame.Icon:SetDesaturated(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] < 2 and true or false)

					bossFrame.Icon:SetScript("OnMouseDown", function(self)
						MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] =
						MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] == 0 and 1
						or MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] == 1 and 2
						or MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] == 2 and 0
						or 1

						if(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] > 0) then
							bossFrame.Border:SetColorTexture(CreateColorFromHexString(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] == 1 and miog.CLRSCC.red
							or MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] == 2 and miog.CLRSCC.green or miog.CLRSCC.white):GetRGBA())
							bossFrame.Border:Show()

						else
							bossFrame.Border:Hide()

						end
						
						self:SetDesaturated(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID].bosses[x] < 2 and true or false)

						miog.newUpdateFunction()
					end)

					currentBossListRow.BossFrames[x] = bossFrame

				end
				
			end

			miog.FilterPanel.IndexedOptions.Raids.Rows[k]:MarkDirty()
			miog.FilterPanel.IndexedOptions.Raids:MarkDirty()
			miog.FilterPanel.IndexedOptions:MarkDirty()
			miog.FilterPanel:MarkDirty()

		end
	end
end

miog.updateRaidCheckboxes = updateRaidCheckboxes

local function addRaidCheckboxes()
	local raidPanel = miog.FilterPanel.IndexedOptions.Raids

	for i = 1, 4, 1 do
		local optionButton = CreateFrame("CheckButton", nil, raidPanel, "MIOG_MinimalCheckButtonTemplate")
		optionButton:SetSize(20, 20)
		optionButton.layoutIndex = i + 1
	
		raidPanel.Buttons[i] = optionButton
	
		optionButton.FontString = optionButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		optionButton.FontString:SetFont("SystemFont_Shadow_Med1", 12, "OUTLINE")
		optionButton.FontString:SetPoint("LEFT", optionButton, "RIGHT")

		local raidBossRow = CreateFrame("Frame", nil, raidPanel, "HorizontalLayoutFrame, BackdropTemplate")
		raidBossRow:SetSize(raidPanel:GetWidth(), 24)
		raidBossRow:SetPoint("LEFT", optionButton, "RIGHT", 36, 0)
		raidBossRow.BossFrames = {}
		raidPanel.Rows[i] = raidBossRow

		local resetButton = CreateFrame("Button", nil, raidBossRow, "IconButtonTemplate")
		resetButton:SetSize(20, 20)
		resetButton.icon = "Interface\\Addons\\MythicIOGrabber\\res\\infoIcons\\xSmallIcon.png"
		resetButton.iconSize = 16
		resetButton:OnLoad()
		resetButton:SetPoint("LEFT", raidBossRow, "RIGHT")
		raidBossRow.Reset = resetButton
	end

	raidPanel:MarkDirty()
end

local function createRaidPanel(parent)
	local raidPanel = CreateFrame("Frame", nil, parent, "VerticalLayoutFrame, BackdropTemplate")
	raidPanel:SetHeight(24)
	raidPanel.Buttons = {}
	raidPanel.Rows = {}

	parent.Raids = raidPanel

	local raidOptionsButton = addOptionToFilterFrame(raidPanel, nil, "Raid options", "filterForRaids")
	raidOptionsButton.expand = true
	raidOptionsButton.layoutIndex = 1
	raidPanel.Option = raidOptionsButton

	return raidPanel
end

miog.addRaidCheckboxes = addRaidCheckboxes

local function updateDungeonCheckboxes(reset)
	for k, v in ipairs(miog.FilterPanel.IndexedOptions.Dungeons.Buttons) do
		v:Hide()

	end

	local sortedSeasonDungeons = {}
	local addedIDs = {}

	local seasonGroup = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
	local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE));
	
	table.sort(seasonGroup, function(k1, k2)
		return miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k1].activityID].shortName < miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k2].activityID].shortName
	end)

	table.sort(expansionGroups, function(k1, k2)
		return miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k1].activityID].shortName < miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k2].activityID].shortName
	end)

	if(seasonGroup and #seasonGroup > 0) then
		for k, v in ipairs(seasonGroup) do
			local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
			sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}
			addedIDs[v] = true
		end
	end

	if(expansionGroups and #expansionGroups > 0) then
		for k, v in ipairs(expansionGroups) do
			if(not addedIDs[v]) then
				local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
				sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}
			end
		end
	end

	for k, activityEntry in ipairs(sortedSeasonDungeons) do
		local currentButton = miog.FilterPanel.IndexedOptions.Dungeons.Buttons[k]
		currentButton:HookScript("OnClick", function(self)
			MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][2].dungeons[activityEntry.groupFinderActivityGroupID] = self:GetChecked()

			convertFiltersToAdvancedBlizzardFilters()

			if(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][2].dungeons) then
				if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
					miog.newUpdateFunction()
		
				elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
					C_LFGList.RefreshApplicants()
		
				end
			end

		end)

		currentButton.FontString:SetText(activityEntry.name)
		currentButton:SetChecked(reset or MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][2].dungeons[activityEntry.groupFinderActivityGroupID])
		
		currentButton:Show()
	end
end

miog.updateDungeonCheckboxes = updateDungeonCheckboxes

local function createDungeonPanel(parent)
	local dungeonPanel = CreateFrame("Frame", nil, parent, "VerticalLayoutFrame, BackdropTemplate")
	dungeonPanel:SetHeight(72)
	dungeonPanel.Buttons = {}

	parent.Dungeons = dungeonPanel

	local dungeonOptionsButton = addOptionToFilterFrame(dungeonPanel, nil, "Dungeon options", "filterForDungeons")
	--dungeonOptionsButton:SetPoint("TOPLEFT", dungeonPanel, "TOPLEFT", 0, 0)
	dungeonOptionsButton.expand = true
	dungeonOptionsButton.layoutIndex = 1
	dungeonPanel.Option = dungeonOptionsButton

	local dungeonPanelFirstRow = CreateFrame("Frame", nil, dungeonPanel, "HorizontalLayoutFrame, BackdropTemplate")
	dungeonPanelFirstRow:SetHeight(24)
	dungeonPanelFirstRow.spacing = 38
	dungeonPanelFirstRow.expand = true
	dungeonPanelFirstRow.layoutIndex = 2
	dungeonPanel.FirstRow = dungeonPanelFirstRow

	local dungeonPanelSecondRow = CreateFrame("Frame", nil, dungeonPanel, "HorizontalLayoutFrame, BackdropTemplate")
	dungeonPanelSecondRow:SetHeight(24)
	dungeonPanelSecondRow.spacing = 38
	dungeonPanelSecondRow.expand = true
	dungeonPanelSecondRow.layoutIndex = 3
	dungeonPanel.SecondRow = dungeonPanelSecondRow

	local dungeonPanelThirdRow = CreateFrame("Frame", nil, dungeonPanel, "HorizontalLayoutFrame, BackdropTemplate")
	dungeonPanelThirdRow:SetHeight(24)
	dungeonPanelThirdRow.spacing = 38
	dungeonPanelThirdRow.expand = true
	dungeonPanelThirdRow.layoutIndex = 4
	dungeonPanel.ThirdRow = dungeonPanelThirdRow

	local dungeonPanelFourthRow = CreateFrame("Frame", nil, dungeonPanel, "HorizontalLayoutFrame, BackdropTemplate")
	dungeonPanelFourthRow:SetHeight(24)
	dungeonPanelFourthRow.spacing = 38
	dungeonPanelFourthRow.expand = true
	dungeonPanelFourthRow.layoutIndex = 4
	dungeonPanel.FourthRow = dungeonPanelFourthRow

	return dungeonPanel
end

local function addDungeonCheckboxes()
	local dungeonPanel = miog.FilterPanel.IndexedOptions.Dungeons

	for i = 1, 16, 1 do
		local optionButton = CreateFrame("CheckButton", nil, i < 5 and dungeonPanel.FirstRow or i < 9 and dungeonPanel.SecondRow or i < 13 and dungeonPanel.ThirdRow or dungeonPanel.FourthRow, "MIOG_MinimalCheckButtonTemplate")
		optionButton:SetSize(miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		optionButton.layoutIndex = i
		optionButton:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end)
		optionButton:Hide()
		
		dungeonPanel.Buttons[i] = optionButton
	
		local optionString = dungeonPanel:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		optionString:SetFont("SystemFont_Shadow_Med1", 12, "OUTLINE")
		optionString:SetPoint("LEFT", optionButton, "RIGHT")

		optionButton.FontString = optionString
	end
end

miog.addDungeonCheckboxes = addDungeonCheckboxes

local function updateFilterDifficulties(reset)
	local currentPanel = LFGListFrame.activePanel:GetDebugName()
	local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

	if(MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()]) then
		local difficultyDropDown = miog.FilterPanel.IndexedOptions.Difficulty.Dropdown
		difficultyDropDown:ResetDropDown()

		local isPvp = categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9
		local isDungeon = categoryID == 2
		local isRaid = categoryID == 3

		if(isPvp or isDungeon or isRaid) then

			for k, v in ipairs(isRaid and miog.RAID_DIFFICULTIES or isPvp and {6, 7} or isDungeon and miog.DUNGEON_DIFFICULTIES or {}) do
				local info = {}
				info.entryType = "option"
				info.text = isPvp and (v == 6 and "2v2" or "3v3") or miog.DIFFICULTY_ID_INFO[v].name
				info.level = 1
				info.value = v
				info.func = function()
					MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID].difficultyID = v

					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.newUpdateFunction()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end

				if(MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID].difficultyID == 0) then
					MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID].difficultyID = v
				end
				
				difficultyDropDown:CreateEntryFrame(info)

			end

			difficultyDropDown.List:MarkDirty()

			if(not reset) then
				local success = difficultyDropDown:SelectFirstFrameWithValue(MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID].difficultyID)
				
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

		--local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)

		-- /dump MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][1]

		MIOG_NewSettings.filterOptions[currentPanel][categoryID] = miog.defaultFilters

		setupFiltersForActivePanel(true)

		convertAndRefresh()
	end)

	local cp = LFGListFrame.activePanel:GetDebugName()
	local categoryID = cp == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or cp == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

	miog.FilterPanel.IndexedOptions.Tanks:SetShown(cp == "LFGListFrame.SearchPanel" and true or false)
	miog.FilterPanel.IndexedOptions.Healers:SetShown(cp == "LFGListFrame.SearchPanel" and true or false)
	miog.FilterPanel.IndexedOptions.Damager:SetShown(cp == "LFGListFrame.SearchPanel" and true or false)
	miog.FilterPanel.IndexedOptions.hardDecline:SetShown(cp == "LFGListFrame.SearchPanel" and true or false)

	miog.FilterPanel.IndexedOptions.BossKills:SetShown(cp == "LFGListFrame.SearchPanel" and categoryID == 3 and true or false)
	miog.FilterPanel.IndexedOptions.Dungeons:SetShown(cp == "LFGListFrame.SearchPanel" and categoryID == 2 and true or false)
	miog.FilterPanel.IndexedOptions.Raids:SetShown(cp == "LFGListFrame.SearchPanel" and categoryID == 3 and true or false)
	miog.FilterPanel.IndexedOptions.Difficulty:SetShown((cp == "LFGListFrame.SearchPanel" and (categoryID == 2 or categoryID == 3)) and true or false)
	miog.FilterPanel.IndexedOptions.Difficulty.Dropdown:SetShown((cp == "LFGListFrame.SearchPanel" and (categoryID == 2 or categoryID == 3)) and true or false)

	miog.FilterPanel.IndexedOptions:MarkDirty()

	if(categoryID) then
		local currentSettings = MIOG_NewSettings.filterOptions[cp][categoryID]

		updateFilterDifficulties(reset)

		miog.FilterPanel.IndexedOptions.Roles.Buttons[1]:SetChecked(currentSettings.filterForRoles["TANK"])
		miog.FilterPanel.IndexedOptions.Roles.Buttons[2]:SetChecked(currentSettings.filterForRoles["HEALER"])
		miog.FilterPanel.IndexedOptions.Roles.Buttons[3]:SetChecked(currentSettings.filterForRoles["DAMAGER"])

		miog.FilterPanel.IndexedOptions.Difficulty:SetChecked(currentSettings.filterForDifficulty)

		miog.FilterPanel.IndexedOptions.LinkedTanks:SetChecked(currentSettings.linkedTanks)
		miog.FilterPanel.IndexedOptions.LinkedHealers:SetChecked(currentSettings.linkedHealers)
		miog.FilterPanel.IndexedOptions.LinkedDamager:SetChecked(currentSettings.linkedDamager)

		miog.FilterPanel.IndexedOptions.Tanks.Button:SetChecked(currentSettings.filterForTanks)
		miog.FilterPanel.IndexedOptions.Tanks.Minimum:SetValue(currentSettings.minTanks)
		miog.FilterPanel.IndexedOptions.Tanks.Maximum:SetValue(currentSettings.maxTanks)

		miog.FilterPanel.IndexedOptions.Healers.Button:SetChecked(currentSettings.filterForHealers)
		miog.FilterPanel.IndexedOptions.Healers.Minimum:SetValue(currentSettings.minHealers)
		miog.FilterPanel.IndexedOptions.Healers.Maximum:SetValue(currentSettings.maxHealers)

		miog.FilterPanel.IndexedOptions.Damager.Button:SetChecked(currentSettings.filterForDamager)
		miog.FilterPanel.IndexedOptions.Damager.Minimum:SetValue(currentSettings.minDamager)
		miog.FilterPanel.IndexedOptions.Damager.Maximum:SetValue(currentSettings.maxDamager)

		miog.FilterPanel.IndexedOptions.Rating:SetShown((categoryID == 2 or categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) and true or false)

		miog.FilterPanel.IndexedOptions.Rating.Button:SetChecked(currentSettings.filterForRating)
		miog.FilterPanel.IndexedOptions.Rating.Minimum:SetNumber(currentSettings.minRating or 0)
		miog.FilterPanel.IndexedOptions.Rating.Maximum:SetNumber(currentSettings.maxRating or 0)

		miog.FilterPanel.IndexedOptions.Age:SetShown(cp == "LFGListFrame.SearchPanel")
		miog.FilterPanel.IndexedOptions.Age.Button:SetChecked(currentSettings.filterForAge)
		miog.FilterPanel.IndexedOptions.Age.Minimum:SetNumber(currentSettings.minAge or 0)
		miog.FilterPanel.IndexedOptions.Age.Maximum:SetNumber(currentSettings.maxAge or 0)

		miog.FilterPanel.IndexedOptions.BossKills.Button:SetChecked(currentSettings.filterForBossKills)
		miog.FilterPanel.IndexedOptions.BossKills.Minimum:SetValue(currentSettings.minBossKills)
		miog.FilterPanel.IndexedOptions.BossKills.Maximum:SetValue(currentSettings.maxBossKills)

		miog.FilterPanel.IndexedOptions.partyFit:SetShown(cp == "LFGListFrame.SearchPanel")
		miog.FilterPanel.IndexedOptions.partyFit.Button:SetChecked(currentSettings.partyFit)

		miog.FilterPanel.IndexedOptions.ressFit.Button:SetChecked(currentSettings.ressFit)
		miog.FilterPanel.IndexedOptions.lustFit.Button:SetChecked(currentSettings.lustFit)

		miog.FilterPanel.IndexedOptions.hardDecline.Button:SetChecked(currentSettings.hardDecline)

		--miog.FilterPanel.IndexedOptions.AffixFit:SetShown(categoryID == 2 and true or false)
		--miog.FilterPanel.IndexedOptions.AffixFit.Button:SetChecked(currentSettings.affixFit)

		miog.FilterPanel.ClassSpecOptions.Option.Button:SetChecked(reset or currentSettings.filterForClassSpecs)

		for classIndex, classEntry in ipairs(miog.CLASSES) do
			local currentClassPanel = miog.FilterPanel.ClassSpecOptions.Panels[classIndex]

			if(reset) then
				currentClassPanel.Class.Button:SetChecked(reset)
				
			elseif(classIndex == id) then
				currentClassPanel.Class.Button:SetChecked(not currentSettings.needsMyClass)

			else
				currentClassPanel.Class.Button:SetChecked(currentSettings.classes[classIndex] ~= false and true or false)

			end
			
			currentClassPanel.Class.Button:SetScript("OnClick", function(self)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				
				local state = self:GetChecked()

				if(classIndex == id) then
					currentSettings.needsMyClass = not state

					if(currentSettings.needsMyClass == true) then
						currentSettings.classes[id] = nil

					else
						currentSettings.classes[id] = state

					end
					
				else
					currentSettings.classes[classIndex] = state

				end

				for specIndex, specFrame in pairs(currentClassPanel.SpecFrames) do
					specFrame.Button:SetChecked(state)
					
					if(classIndex == id) then
						if(currentSettings.needsMyClass == true) then
							currentSettings.specs[specIndex] = nil

						else
							currentSettings.specs[specIndex] = state

						end
					else
						currentSettings.specs[specIndex] = state
					
					end
				end

				convertFiltersToAdvancedBlizzardFilters()

				if(currentSettings.filterForClassSpecs) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.newUpdateFunction()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end
			end)

			for specIndex, specID in pairs(classEntry.specs) do
				local currentSpecFrame = currentClassPanel.SpecFrames[specID]

				if(reset) then
					currentSpecFrame.Button:SetChecked(reset)
					
				elseif(classIndex == id) then
					currentSpecFrame.Button:SetChecked(not currentSettings.needsMyClass)

				else
					currentSpecFrame.Button:SetChecked(currentSettings.specs[specID] ~= false and true or false)

				end
				
				currentSpecFrame.Button:SetScript("OnClick", function(self)
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

					local state = self:GetChecked()

					if(state) then
						currentClassPanel.Class.Button:SetChecked(true)
						currentSettings.classes[classIndex] = true

					end

					currentSettings.specs[specID] = state

					convertFiltersToAdvancedBlizzardFilters()

					if(currentSettings.filterForClassSpecs) then
						if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
							miog.newUpdateFunction()
				
						elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
							C_LFGList.RefreshApplicants()
				
						end
					end

				end)
			end
		end

		if(categoryID == 2) then
			miog.updateDungeonCheckboxes(reset)

			miog.FilterPanel.IndexedOptions.Dungeons.Option.Button:SetChecked(reset or currentSettings.filterForDungeons)
		elseif(categoryID == 3) then
			miog.updateRaidCheckboxes()

			miog.FilterPanel.IndexedOptions.Raids.Option.Button:SetChecked(reset or currentSettings.filterForRaids)
			
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
		classPanel.fixedWidth = miog.FilterPanel.fixedWidth

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
	local roleFilterPanel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	roleFilterPanel:SetHeight(20)
	roleFilterPanel.Buttons = {}

	local lastTexture = nil

	parent.Roles = roleFilterPanel

	for i = 1, 3, 1 do
		local toggleRoleButton = CreateFrame("CheckButton", nil, roleFilterPanel, "MIOG_MinimalCheckButtonTemplate")
		toggleRoleButton:SetSize(miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
		toggleRoleButton:SetPoint("LEFT", lastTexture or roleFilterPanel, lastTexture and "RIGHT" or "LEFT", lastTexture and 7 or 0, 0)

		local roleTexture = roleFilterPanel:CreateTexture(nil, "ARTWORK")
		roleTexture:SetSize(miog.C.APPLICANT_MEMBER_HEIGHT - 3, miog.C.APPLICANT_MEMBER_HEIGHT - 3)
		roleTexture:SetPoint("LEFT", toggleRoleButton, "RIGHT", 0, 0)

		toggleRoleButton:SetScript("OnClick", function(self)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

			local state = self:GetChecked()
			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
		
			MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"] = state

			convertFiltersToAdvancedBlizzardFilters()

			if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
				miog.newUpdateFunction()
	
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
end]]--



-- create new filter panel
-- completely from scratch

local function setWidthForExpandableFrame(frame)
	local width = 0

	for k, v in ipairs(frame:GetLayoutChildren()) do
		print(k, v:GetWidth())
		width = width + v:GetWidth()

	end

	if(width > 0) then
		frame:SetWidth(width)

	end
end

local function setupTextSetting(key, text, filterID)
	local setting = miog.NewFilterPanel[key]

	setting.Text:SetText(text)
	setting:SetWidth(setting.Text:GetUnboundedStringWidth() + 20)
	setting.layoutIndex = #setting:GetParent():GetLayoutChildren() + 1
	setting.Button:SetScript("PostClick", function()
		convertAndRefresh()
	end)

	table.insert(allFilters, {type = "icon", id = filterID, object = setting})

	return setting

end

local function createIconSetting(texture, parent, filterID)
	local filterOption = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelIconSettingTemplate")
	filterOption.Icon:SetTexture(texture)
	filterOption:SetWidth(36)
	filterOption.layoutIndex = #filterOption:GetParent():GetLayoutChildren() + 1
		
	filterOption.Button:SetScript("PostClick", function()
		convertAndRefresh()
	end)

	table.insert(allFilters, {type = "icon", id = filterID, object = filterOption})

	return filterOption
end

local function createTextSetting(text, parent, filterID)
	local filterOption = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelTextSettingTemplate")
	filterOption.Text:SetText(text)
	filterOption:SetWidth(filterOption.Text:GetUnboundedStringWidth() + 20)
	filterOption.layoutIndex = #filterOption:GetParent():GetLayoutChildren() + 1
	filterOption.Button:SetScript("PostClick", function()
		convertAndRefresh()
	end)

	table.insert(allFilters, {type = "text", id = filterID, object = filterOption})

	return filterOption
end

local function setDualInputBoxesScripts(filterOption, setting)
	for i = 1, 2, 1 do
		local currentField = filterOption[i == 1 and "Minimum" or "Maximum"]
		local currentName = i == 1 and "minimum" or "maximum"

		--currentField:SetAutoFocus(false)
		--currentField.autoFocus = false
		--currentField:SetNumeric(true)
		--currentField:SetMaxLetters(4)
		currentField:HookScript("OnTextChanged", function(self, ...)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			
			local text = tonumber(self:GetText())
			setting[currentName] = text ~= nil and text or 0

			convertAndRefresh()
		end)
	end
end

local function setDualSpinnerScripts(filterOption, setting)
	for i = 1, 2, 1 do
		local currentSpinner = filterOption[i == 1 and "Minimum" or "Maximum"]
		local currentName = i == 1 and "minimum" or "maximum"

		currentSpinner:SetScript("OnTextChanged", function(self, userInput)
			if(userInput) then
				local spinnerValue = self:GetNumber()

				if(spinnerValue) then

					setting[currentName] = spinnerValue

					self:SetValue(spinnerValue)

					if(i == 1) then
						if(setting.maximum < spinnerValue) then
							filterOption.Maximum:SetValue(spinnerValue)
							setting.maximum = spinnerValue

						end

					else
						if(setting.minimum > spinnerValue) then
							filterOption.Minimum:SetValue(spinnerValue)
							setting.minimum = spinnerValue

						end
					end
				end
			end

			convertAndRefresh()
		end)

		currentSpinner.DecrementButton:SetScript("OnMouseDown", function(self)
			currentSpinner:Decrement()

			local spinnerValue = currentSpinner:GetValue()

			setting[currentName] = spinnerValue

			if(i == 2) then
				if(not setting.minimum or setting.minimum > setting.maximum) then
					filterOption.Minimum:SetValue(setting.maximum)
					setting.minimum = setting.maximum

				end
			end

			currentSpinner:ClearFocus()

			convertAndRefresh()
		end)

		currentSpinner.IncrementButton:SetScript("OnMouseDown", function()
			currentSpinner:Increment()

			local spinnerValue = currentSpinner:GetValue()

			setting[currentName] = spinnerValue

			if(i == 1) then
				if(not setting.maximum or setting.maximum < setting.minimum) then
					filterOption.Maximum:SetValue(setting.minimum)
					setting.maximum = setting.minimum

				end
			end

			currentSpinner:ClearFocus()

			convertAndRefresh()
		end)
	end
end

local function setupDualSpinner(key, text, filterID)
	local spinnerContainer = miog.NewFilterPanel[key]

	spinnerContainer.Setting.Text:SetText(text)
	spinnerContainer.Setting:SetWidth(spinnerContainer.Setting.Text:GetUnboundedStringWidth() + 20)
	spinnerContainer.Setting.Button:SetScript("PostClick", function()
		convertAndRefresh()
	end)

	spinnerContainer.DualSpinner:SetWidth(154)

	spinnerContainer.DualSpinner.Minimum:SetWidth(22)
	spinnerContainer.DualSpinner.Minimum:SetMinMaxValues(range ~= nil and range or 0, 40)

	spinnerContainer.DualSpinner.Maximum:SetWidth(22)
	spinnerContainer.DualSpinner.Maximum:SetMinMaxValues(range ~= nil and range or 0, 40)

	spinnerContainer.layoutIndex = #spinnerContainer:GetParent():GetLayoutChildren() + 1

	table.insert(allFilters, {type = "icon", id = filterID, object = spinnerContainer})

	return setting
end

local function createDualSpinner(parent)
	local filterOption = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelDualSpinnerTemplate")
	filterOption:SetWidth(154)

	filterOption.Minimum:SetWidth(22)
	filterOption.Minimum:SetMinMaxValues(range ~= nil and range or 0, 40)

	filterOption.Maximum:SetWidth(22)
	filterOption.Maximum:SetMinMaxValues(range ~= nil and range or 0, 40)
	
	filterOption.layoutIndex = #filterOption:GetParent():GetLayoutChildren() + 1

	return filterOption
end

local function createSpinnerSetting(text, parent, filterID)
	local containerFrame = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelContainerRowTemplate")
	containerFrame.layoutIndex = #containerFrame:GetParent():GetLayoutChildren() + 1

	local checkBox = createTextSetting(text, containerFrame)
	local dualSpinner = createDualSpinner(containerFrame)

	containerFrame.DualSpinner = dualSpinner
	containerFrame.CheckBox = checkBox

	table.insert(allFilters, {type = "dualSpinner", id = filterID, object = containerFrame})

	return containerFrame
end

local function createDualInputBox(parent)
	local filterOption = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelDualInputBoxTemplate")
	filterOption.layoutIndex = #filterOption:GetParent():GetLayoutChildren() + 1

	filterOption.Minimum:SetAutoFocus(false)
	filterOption.Minimum.autoFocus = false
	filterOption.Minimum:SetNumeric(true)

	filterOption.Maximum:SetAutoFocus(false)
	filterOption.Maximum.autoFocus = false
	filterOption.Maximum:SetNumeric(true)

	return filterOption
end

local function setupDualInputBoxes(key, text, filterID)
	local containerFrame = miog.NewFilterPanel[key]
	containerFrame.layoutIndex = #containerFrame:GetParent():GetLayoutChildren() + 1

	containerFrame.Setting.Text:SetText(text)
	containerFrame.Setting:SetWidth(containerFrame.Setting.Text:GetUnboundedStringWidth() + 20)
	containerFrame.Setting.Button:SetScript("PostClick", function()
		convertAndRefresh()
	end)
	containerFrame.Setting.Text:SetText(text)
	
	containerFrame.DualBoxes.Minimum:SetAutoFocus(false)
	containerFrame.DualBoxes.Minimum.autoFocus = false
	containerFrame.DualBoxes.Minimum:SetNumeric(true)

	containerFrame.DualBoxes.Maximum:SetAutoFocus(false)
	containerFrame.DualBoxes.Maximum.autoFocus = false
	containerFrame.DualBoxes.Maximum:SetNumeric(true)

	table.insert(allFilters, {type = "dualInput", id = filterID, object = containerFrame})
end

local function createInputBoxSetting(text, parent, filterID)
	local containerFrame = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelContainerRowTemplate")
	containerFrame.layoutIndex = #containerFrame:GetParent():GetLayoutChildren() + 1

	local checkBox = createTextSetting(text, containerFrame)
	local dualBoxes = createDualInputBox(containerFrame)

	containerFrame.dualBoxes = dualBoxes
	containerFrame.checkBox = checkBox

	table.insert(allFilters, {type = "dualInput", id = filterID, object = containerFrame})

	return containerFrame
end

local function setupDropdownSetting(key, text, filterID)
	local setting = miog.NewFilterPanel[key]
	setting.layoutIndex = #setting:GetParent():GetLayoutChildren() + 1

	setting.Dropdown:SetDefaultText(text)

	table.insert(allFilters, {type = "dropdown", id = filterID, object = setting})
	
	return setting
end


local function createDropdownSetting(parent, filterID)
	local filterOption = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelDropdownSettingTemplate")
	filterOption.layoutIndex = #filterOption:GetParent():GetLayoutChildren() + 1

	filterOption.Dropdown:SetDefaultText("Difficulty")

	table.insert(allFilters, {type = "dropdown", id = filterID, object = filterOption})
	
	return filterOption
end

local function createNewClassPanel(parent, filterID)
	local containerFrame

	for _, classInfo in ipairs(miog.CLASSES) do
		containerFrame = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelContainerRowTemplate")
		containerFrame.layoutIndex = #containerFrame:GetParent():GetLayoutChildren() + 1
		containerFrame.classID = _

		local r, g, b = GetClassColor(classInfo.name)
		containerFrame.Border:SetColorTexture(r, g, b, 0.9)
		containerFrame.Background:SetColorTexture(r, g, b, 0.6)

		local classFrame = createIconSetting(classInfo.roundIcon, containerFrame)
		classFrame.Icon:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(GetClassInfo(_))
			GameTooltip:Show()
		end)
		classFrame.Icon:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

		containerFrame.classFrame = classFrame

		for _, specID in ipairs(classInfo.specs) do
			local specInfo = miog.SPECIALIZATIONS[specID]

			local specFrame = createIconSetting(specInfo.icon, containerFrame)
			specFrame.specID = specID
			specFrame.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(select(2, GetSpecializationInfoByID(specID)))
				GameTooltip:Show()
			end)
			specFrame.Icon:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)

			containerFrame["Spec" .. _] = specFrame
		end

		table.insert(allFilters, {type = "classPanel", id = filterID, object = containerFrame})
	end

	return containerFrame
end

local function createRolePanel(parent, filterID)
	local containerFrame = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelContainerRowTemplate")
	containerFrame.layoutIndex = #containerFrame:GetParent():GetLayoutChildren() + 1

	for i = 1, 3, 1 do
		if(i == 1) then
			containerFrame.tank = createIconSetting(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png", containerFrame)

		elseif(i == 2) then
			containerFrame.healer = createIconSetting(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png", containerFrame)

		elseif(i == 3) then
			containerFrame.damager = createIconSetting(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png", containerFrame)

		end
	end

	table.insert(allFilters, {type = "rolePanel", id = filterID, object = containerFrame})

	return containerFrame
end

local function setupSpacer(key, filterID)
	local spacer = miog.NewFilterPanel[key]
	spacer.layoutIndex = #spacer:GetParent():GetLayoutChildren() + 1
	spacer:SetWidth(spacer:GetParent():GetWidth())

	table.insert(allFilters, {type = "spacer", id = filterID, object = spacer})

	return spacer
end

local function createSpacer(parent, filterID)
	local divider = parent:CreateTexture(nil, "BORDER")
	divider.layoutIndex = #parent:GetLayoutChildren() + 1
	divider.expand = true
	divider:SetHeight(1)
	divider:SetAtlas("UI-LFG-DividerLine", false)
	divider:SetWidth(parent:GetWidth())
	table.insert(allFilters, {type = "spacer", id = filterID, object = divider})

	return divider
end



local function HasRemainingSlotsForBloodlust(resultID)
	local _, _, playerClassID = UnitClass("player")
	if(playerClassID == 3 or playerClassID == 7 or playerClassID == 8 or playerClassID == 13) then
		return true

	end

	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)
	if roles then
		if(roles["TANK_REMAINING"] == 0 and roles["HEALER_REMAINING"] == 0 and roles["DAMAGER_REMAINING"] == 0) then
			return true
		end

		local playerRole = GetSpecializationRole(GetSpecialization())

		if(playerRole == "DAMAGER" and (roles["HEALER_REMAINING"] > 0 or roles["DAMAGER_REMAINING"] > 1)) then
			return true

		end

		if(playerRole == "HEALER" and roles["DAMAGER_REMAINING"] > 0) then
			return true

		end

		for k, v in pairs(roles) do
			if((k == "HUNTER" or k == "SHAMAN" or k == "MAGE" or k == "EVOKER") and v > 0) then
				return true

			end
		end
	end
end

local function HasRemainingSlotsForBattleResurrection(resultID)
	if(playerClassID == 2 or playerClassID == 6 or playerClassID == 9 or playerClassID == 11) then
		return true

	end

	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)
	if roles then
		if(roles["TANK_REMAINING"] == 0 and roles["HEALER_REMAINING"] == 0 and roles["DAMAGER_REMAINING"] == 0) then
			return true
		end

		local playerRole = GetSpecializationRole(GetSpecialization())

		if(playerRole == "DAMAGER" and (roles["HEALER_REMAINING"] > 0 or roles["DAMAGER_REMAINING"] > 1)) then
			return true

		end

		if(playerRole == "HEALER" and roles["DAMAGER_REMAINING"] > 0 or roles["TANK_REMAINING"] > 0) then
			return true

		end

		if(playerRole == "TANK" and roles["DAMAGER_REMAINING"] > 0 or roles["HEALER_REMAINING"] > 0) then
			return true

		end

		for k, v in pairs(roles) do
			if((k == "PALADIN" or k == "DEATHKNIGHT" or k == "WARLOCK" or k == "DRUID") and v > 0) then
				return true

			end
		end
	end
end

local function HasRemainingSlotsForLocalPlayerRole(resultID) -- LFGList.lua local function HasRemainingSlotsForLocalPlayerRole(lfgresultID)
	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)

	if roles then
		if(roles["TANK_REMAINING"] == 0 and roles["HEALER_REMAINING"] == 0 and roles["DAMAGER_REMAINING"] == 0) then
			return true
		end

		local playerRole = GetSpecializationRole(GetSpecialization())
		if playerRole then
			local remainingRoleKey = miog.roleRemainingKeyLookup[playerRole]
			if remainingRoleKey then
				return (roles[remainingRoleKey] or 0) > 0
			end
		end
	end
end

local function checkEligibility(panel, _, resultOrApplicant, borderMode)
	--categoryID, panel = categoryID, panel or miog.getCurrentCategoryID()
	local roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
		["NONE"] = 0
	}

	local settings

	if(panel == "LFGListFrame.SearchPanel") then
		if(C_LFGList.HasSearchResultInfo(resultOrApplicant)) then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(resultOrApplicant)
			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)

			settings = MIOG_NewSettings.newFilterOptions[panel][activityInfo.categoryID]

			local isPvp = activityInfo.categoryID == 4 or activityInfo.categoryID == 7
			local isDungeon = activityInfo.categoryID == 2
			local isRaid = activityInfo.categoryID == 3

			miog.checkSingleMapIDForNewData(miog.ACTIVITY_INFO[searchResultInfo.activityID].mapID)
			
			if(LFGListFrame.SearchPanel.categoryID and activityInfo.categoryID ~= LFGListFrame.SearchPanel.categoryID and not borderMode) then
				return false, miog.INELIGIBILITY_REASONS[2]

			end

			print("A")

			local rating = isPvp and (searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0) or searchResultInfo.leaderOverallDungeonScore or 0
			
			if(settings.hideHardDecline and MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID] and MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID].activeDecline) then
				return false, miog.INELIGIBILITY_REASONS[3]
				
			end

			print("B")

			if(settings.difficulty.value) then
				if(isDungeon or isRaid) then
					if(miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID ~= settings.difficulty.id
					)then
						return false, miog.INELIGIBILITY_REASONS[4]

					end
				elseif(isPvp) then
					if(searchResultInfo.activityID ~= settings.difficulty.id) then
						return false, miog.INELIGIBILITY_REASONS[5]

					end
				end
			end

			print("C")

			-- shit stops here for some reason, idk yet why

			for i = 1, searchResultInfo.numMembers, 1 do
				local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(searchResultInfo.searchResultID, i)
				local specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]

				if(role) then
					roleCount[role] = roleCount[role] + 1

				end

				if(miog.CLASSFILE_TO_ID[class] == id and miog.blizzardFilters.needsMyClass == true) then
					return false, miog.INELIGIBILITY_REASONS[10]

				end

				if(settings.classes[miog.CLASSFILE_TO_ID[class]] == false) then
					return false, miog.INELIGIBILITY_REASONS[10]

				end

				if(settings.specs[specID] == false) then
					return false, miog.INELIGIBILITY_REASONS[11]

				end

			end

			print("D")
			

			local tankCountInRange = roleCount["TANK"] >= settings.tank.minimum and roleCount["TANK"] <= settings.tank.maximum
			local healerCountInRange = roleCount["HEALER"] >= settings.healer.minimum and roleCount["HEALER"] <= settings.healer.maximum
			local damagerCountInRange = roleCount["DAMAGER"] >= settings.damager.minimum and roleCount["DAMAGER"] <= settings.damager.maximum

			local tanksOk = settings.tank.value == false or
			settings.tank.value and tankCountInRange == true

			local healersOk = settings.healer.value == false or
			settings.healer.value and healerCountInRange == true

			local damagerOk = settings.damager.value == false or
			settings.damager.value and damagerCountInRange == true


			if(not tanksOk and settings.tank.linked ~= true or not healersOk and settings.healer.linked ~= true or not damagerOk and settings.damager.linked ~= true) then
				return false, miog.INELIGIBILITY_REASONS[12]
			end

			if(settings.roles["TANK"] == false and roleCount["TANK"] > 0) then
				return false, miog.INELIGIBILITY_REASONS[13]
			end

			if(settings.roles["HEALER"] == false and roleCount["HEALER"] > 0) then
				return false, miog.INELIGIBILITY_REASONS[13]
			end

			if(settings.roles["DAMAGER"] == false and roleCount["DAMAGER"] > 0) then
				return false, miog.INELIGIBILITY_REASONS[13]
			end

			print("E")
				
			if(settings.age.value) then
				if(settings.age.minimum ~= 0 and settings.age.maximum ~= 0) then
					if(settings.age.maximum >= 0 and not (searchResultInfo.age >= settings.age.minimum * 60 and searchResultInfo.age <= settings.age.maximum * 60)) then
						return false, miog.INELIGIBILITY_REASONS[23]

					end
				elseif(settings.age.minimum ~= 0) then
					if(searchResultInfo.age < settings.age.minimum * 60) then
						return false, miog.INELIGIBILITY_REASONS[24]

					end
				elseif(settings.age.maximum ~= 0) then
					if(searchResultInfo.age >= settings.age.maximum * 60) then
						return false, miog.INELIGIBILITY_REASONS[25]

					end

				end
			end

			print("F")

			if(settings.activities.value and (isRaid or isDungeon)) then
				if(not settings.activities[activityInfo.groupFinderActivityGroupID].value) then
					return false, miog.INELIGIBILITY_REASONS[17]

				end

				if(isRaid and LFGListFrame.SearchPanel.filters == 1) then
					if(not settings.activities[activityInfo.groupFinderActivityGroupID].value) then
						return false, miog.INELIGIBILITY_REASONS[18]

					else
						local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(searchResultInfo.searchResultID)

						local encountersDefeated = {}

						if(encounterInfo) then
							for k, v in ipairs(encounterInfo) do
								encountersDefeated[v] = true
							end
						end

						for k, v in pairs(settings.activities[activityInfo.groupFinderActivityGroupID].bosses) do
							local bossInfo = miog.ACTIVITY_INFO[searchResultInfo.activityID].bosses[k]

							if(bossInfo) then
								-- 1 either defeated or alive
								-- 2 defeated
								-- 3 alive
								if(v == 3 and encountersDefeated[bossInfo.name] or v == 2 and not encountersDefeated[bossInfo.name]) then
									return false, miog.INELIGIBILITY_REASONS[19]

								end
							end
						end
					end

				if(settings.kills) then
					local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(searchResultInfo.searchResultID)

					local numberOfSlainEncounters = encounterInfo and #encounterInfo or 0

					local minKills = settings.kills.minimum
					local maxKills = settings.kills.maximum

					if(minKills ~= 0 and maxKills ~= 0) then
						if(maxKills >= 0
						and not (numberOfSlainEncounters >= minKills
						and numberOfSlainEncounters <= maxKills)) then
							return false, miog.INELIGIBILITY_REASONS[20]

						end
					elseif(minKills ~= 0) then
						if(numberOfSlainEncounters < minKills) then
							return false, miog.INELIGIBILITY_REASONS[21]

						end
					elseif(maxKills ~= 0) then
						if(numberOfSlainEncounters >= maxKills) then
							return false, miog.INELIGIBILITY_REASONS[22]

						end

					end

				end

				end
			end

			print("G")

			if(isDungeon or isPvp) then
				if(settings.rating.value) then
					if(settings.rating.minimum ~= 0 and settings.rating.maximum ~= 0) then
						if(settings.rating.maximum >= 0
						and not (rating >= settings.rating.minimum
						and rating <= settings.rating.maximum)) then
							return false, miog.INELIGIBILITY_REASONS[14]

						end
					elseif(settings.rating.minimum ~= 0) then
						if(rating < settings.rating.minimum) then
							return false, miog.INELIGIBILITY_REASONS[15]

						end
					elseif(settings.rating.maximum ~= 0) then
						if(rating >= settings.rating.maximum) then
							return false, miog.INELIGIBILITY_REASONS[16]

						end

					end
				end
			end

			print("H")

			if(settings.partyFit and not HasRemainingSlotsForLocalPlayerRole(searchResultInfo.searchResultID)) then
				return false, miog.INELIGIBILITY_REASONS[6]
		
			end

			print("I")
		
			if(settings.ressFit and not HasRemainingSlotsForBattleResurrection(searchResultInfo.searchResultID)) then
				return false, miog.INELIGIBILITY_REASONS[7]
		
			end

			print("J")
		
			if(settings.lustFit and not HasRemainingSlotsForBloodlust(searchResultInfo.searchResultID)) then
				return false, miog.INELIGIBILITY_REASONS[8]
		
			end

			print("K")
		else
			return false, miog.INELIGIBILITY_REASONS[1]

		end
	end

	return true
end

miog.checkEligibility = checkEligibility

local function setFilterVisibilityByCategoryAndPanel(categoryID, panel)
	MIOG_NewSettings.newFilterOptions[panel] = MIOG_NewSettings.newFilterOptions[panel] or {}
	MIOG_NewSettings.newFilterOptions[panel][categoryID] = MIOG_NewSettings.newFilterOptions[panel][categoryID] or {}

	local categorySettings = MIOG_NewSettings.newFilterOptions[panel][categoryID]

	for k, v in ipairs(allFilters) do
		if(v.id == "activitiesSpacer" and (categoryID == 2 or categoryID == 3)) then
			v.object:Show()
		
		elseif(v.id == "classPanel") then
			v.object:Show()

			categorySettings.classes = categorySettings.classes or {}
			categorySettings.specs = categorySettings.specs or {}

			local blizzardFilters = C_LFGList.GetAdvancedFilter()

			if(categorySettings.classes[v.object.classID] == false or categoryID == 2 and blizzardFilters.needsMyClass == true and v.object.classID == id) then
				v.object.classFrame.Button:SetChecked(false)
					
			else
				v.object.classFrame.Button:SetChecked(true)

			end

			v.object.classFrame.Button:SetScript("OnClick", function(self)
				categorySettings.classes[v.object.classID] = self:GetChecked()

			end)

			for i = 1, 4, 1 do
				local specFrame = v.object["Spec" .. i]

				if(specFrame) then
					if(categorySettings.specs[specFrame.specID] == false or categoryID == 2 and blizzardFilters.needsMyClass == true and v.object.classID == id) then
						specFrame.Button:SetChecked(false)
						
					else
						specFrame.Button:SetChecked(true)

					end

					specFrame.Button:SetScript("OnClick", function(self)
						categorySettings.specs[specFrame.specID] = self:GetChecked()

						if(categorySettings.specs[specFrame.specID] and categorySettings.classes[v.object.classID] == false) then
							v.object.classFrame.Button:SetChecked(true)

						end
					
					end)
				end
				
			end

		elseif(v.id == "roles") then
			categorySettings[v.id] = categorySettings[v.id] or {}

			v.object.tank.Button:SetChecked(categorySettings.roles["TANK"] ~= false)
			v.object.tank.Button:SetScript("OnClick", function(self)
				categorySettings[v.id]["TANK"] = self:GetChecked()
			
			end)

			v.object.healer.Button:SetChecked(categorySettings.roles["HEALER"] ~= false)
			v.object.healer.Button:SetScript("OnClick", function(self)
				categorySettings[v.id]["HEALER"] = self:GetChecked()
			
			end)

			v.object.damager.Button:SetChecked(categorySettings.roles["DAMAGER"] ~= false)
			v.object.damager.Button:SetScript("OnClick", function(self)
				categorySettings[v.id]["DAMAGER"] = self:GetChecked()
			
			end)

			v.object:Show()

		elseif(v.id == "lustFit" or v.id == "ressFit" or (v.id == "hideHardDecline" or v.id == "partyFit") and panel == "LFGListFrame.SearchPanel") then
			v.object:Show()
			v.object.Button:SetScript("OnClick", function(self)
				categorySettings[v.id] = self:GetChecked()
			end)
			v.object.Button:SetChecked(categorySettings[v.id])

		elseif(v.id == "difficulty" and panel == "LFGListFrame.SearchPanel") then

			categorySettings.difficulty = categorySettings.difficulty or {}

			v.object:Show()
			selectedDifficultyIndex = categorySettings.difficulty.id
			
			v.object.Dropdown:SetupMenu(function(dropdown, rootDescription)
				local isPvp = categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9
				local isDungeon = categoryID == 2
				local isRaid = categoryID == 3
		
				if(isPvp or isDungeon or isRaid) then
					for _, y in ipairs(isRaid and miog.RAID_DIFFICULTIES or isPvp and {6, 7} or isDungeon and miog.DUNGEON_DIFFICULTIES or {}) do
						local difficultyMenu = rootDescription:CreateRadio(isPvp and (y == 6 and "2v2" or "3v3") or miog.DIFFICULTY_ID_INFO[y].name, function(difficultyIndex) return difficultyIndex == selectedDifficultyIndex end, function(difficultyIndex)
							selectedDifficultyIndex = difficultyIndex
							MIOG_NewSettings.newFilterOptions["LFGListFrame.SearchPanel"][LFGListFrame.SearchPanel.categoryID].difficulty.id = difficultyIndex
							convertAndRefresh()
							--changeFilterSetting()
						end, y)
					end
				end
			end)

			v.object.CheckButton:SetScript("OnClick", function(self)
				categorySettings[v.id].value = self:GetChecked()
			end)
			v.object.Button:SetChecked(categorySettings[v.id].value)

		elseif((v.id == "tank" or v.id == "healer" or v.id == "damager") and panel == "LFGListFrame.SearchPanel") then
			categorySettings[v.id] = categorySettings[v.id] or {value = false, minimum = 0, maximum = 0, linked = false}

			setDualSpinnerScripts(v.object.DualSpinner, categorySettings[v.id])
			v.object.Setting.Button:SetScript("OnClick", function(self)
				categorySettings[v.id].value = self:GetChecked()
		
			end)
			v.object.DualSpinner.Link:SetScript("OnClick", function(self)
				categorySettings[v.id].linked = self:GetChecked()
				convertAndRefresh()
		
			end)

			--/run MIOG_NewSettings.newFilterOptions = nil

			v.object.Setting.Button:SetChecked(categorySettings[v.id].value)
			v.object.DualSpinner.Link:SetChecked(categorySettings[v.id].linked)
			v.object.DualSpinner.Minimum:SetValue(categorySettings[v.id].minimum)
			v.object.DualSpinner.Maximum:SetValue(categorySettings[v.id].maximum)

			v.object:Show()

		elseif(v.id == "age" and panel == "LFGListFrame.SearchPanel" or v.id == "rating" and (categoryID == 2 or categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9)) then
			categorySettings[v.id] = categorySettings[v.id] or {value = false, minimum = 0, maximum = 0}

			setDualInputBoxesScripts(v.object.DualBoxes, categorySettings[v.id])
			v.object.Setting.Button:SetScript("OnClick", function(self)
				categorySettings[v.id].value = self:GetChecked()
		
			end)
			v.object.Setting.Button:SetChecked(categorySettings[v.id].value)
			v.object.DualBoxes.Minimum:SetNumber(categorySettings[v.id].minimum)
			v.object.DualBoxes.Maximum:SetNumber(categorySettings[v.id].maximum)

			v.object:Show()

		elseif(v.id == "activities") then
			categorySettings.activities = categorySettings.activities or {}

			v.object.Button:SetChecked(categorySettings[v.id].value)
			v.object.Button:SetScript("OnClick", function(self)
				categorySettings[v.id].value = self:GetChecked()
			end)
			
			miog.NewFilterPanel.ActivityRow1:Hide()
			miog.NewFilterPanel.ActivityRow1.layoutIndex = nil

			miog.NewFilterPanel.ActivityRow2:Hide()
			miog.NewFilterPanel.ActivityRow2.layoutIndex = nil

			miog.NewFilterPanel.ActivityRow3:Hide()
			miog.NewFilterPanel.ActivityRow3.layoutIndex = nil

			miog.NewFilterPanel.ActivityRow4:Hide()
			miog.NewFilterPanel.ActivityRow4.layoutIndex = nil

			miog.NewFilterPanel.ActivityBossRow1:Hide()
			miog.NewFilterPanel.ActivityBossRow1.layoutIndex = nil

			miog.NewFilterPanel.ActivityBossRow2:Hide()
			miog.NewFilterPanel.ActivityBossRow2.layoutIndex = nil

			miog.NewFilterPanel.ActivityBossRow3:Hide()
			miog.NewFilterPanel.ActivityBossRow3.layoutIndex = nil

			miog.NewFilterPanel.ActivityBossRow4:Hide()
			miog.NewFilterPanel.ActivityBossRow4.layoutIndex = nil

			if(panel == "LFGListFrame.SearchPanel" and (categoryID == 2 or categoryID == 3)) then
				if(categoryID == 2) then
					local sortedSeasonDungeons = {}
					local addedIDs = {}

					local seasonGroup = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
					local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE));
					
					table.sort(seasonGroup, function(k1, k2)
						return miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k1].activityID].shortName < miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k2].activityID].shortName
					end)

					table.sort(expansionGroups, function(k1, k2)
						return miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k1].activityID].shortName < miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k2].activityID].shortName
					end)

					if(seasonGroup and #seasonGroup > 0) then
						for x, y in ipairs(seasonGroup) do
							local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[y].activityID]
							sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName, activityID = miog.GROUP_ACTIVITY[y].activityID}
							addedIDs[y] = true
						end
					end

					if(expansionGroups and #expansionGroups > 0) then
						for x, y in ipairs(expansionGroups) do
							if(not addedIDs[y]) then
								local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[y].activityID]
								sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName, activityID = miog.GROUP_ACTIVITY[y].activityID}
							end
						end
					end

					for i = 1, 16, 1 do
						local row = i < 5 and 1 or i < 9 and 2 or i < 13 and 3 or 4
						local column = i - ((row - 1) * 4)

						local activityRow = miog.NewFilterPanel["ActivityRow" .. row]
						local frame = activityRow["Activity" .. column]

						if(sortedSeasonDungeons[i]) then
							categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID] = categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID] or {}

							frame.Text:SetText(sortedSeasonDungeons[i].name)
							frame.Text:SetScript("OnEnter", function(self)
								GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
								GameTooltip:SetText(C_LFGList.GetActivityGroupInfo(sortedSeasonDungeons[i].groupFinderActivityGroupID) or "")
								GameTooltip:Show()
							end)
							frame:Show()

							activityRow.layoutIndex = 1000 + row
							activityRow:Show()
						
							frame.Button:SetChecked(categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value ~= false)
							categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value = categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value ~= false --setting this as a workaround for Blizzards way of filtering activities with the advanced filter

							frame.Button:SetScript("OnClick", function(self)
								categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value = self:GetChecked()

								convertAndRefresh()
							end)

						else
							frame.Button:SetChecked(true)
							frame.Text:SetScript("OnEnter", nil)

						end

						frame.Text:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)

					end
				
				elseif(categoryID == 3) then
					local seasonGroups = C_LFGList.GetAvailableActivityGroups(3, Enum.LFGListFilter.Recommended);
					local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, 5)
		
					local sortedExpansionRaids = {}
		
					if(seasonGroups and #seasonGroups > 0) then
						for _, v in ipairs(seasonGroups) do
							local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
							miog.checkSingleMapIDForNewData(activityInfo.mapID)
							sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName, bosses = activityInfo.bosses}
		
						end
					end
		
					if(worldBossActivity and #worldBossActivity > 0) then
						local activityInfo = C_LFGList.GetActivityInfoTable(worldBossActivity[1])
						sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}
		
					end
		
					table.sort(sortedExpansionRaids, function(k1, k2)
						return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID
					end)

					for i = 1, 4, 1 do
						local bossRow = miog.NewFilterPanel["ActivityBossRow" .. i]

						if(sortedExpansionRaids[i]) then
							categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID] = categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID] or {}
							categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses = categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses or {}

							bossRow.Activity.Text:SetText(sortedExpansionRaids[i].name)
							bossRow.Activity.Button:SetChecked(categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value ~= false)
							categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value = categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value ~= false --setting this as a workaround for Blizzards way of filtering activities with the advanced filter

							bossRow.Activity.Button:SetScript("OnClick", function(self)
								categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value = self:GetChecked()
								convertAndRefresh()

							end)

							for d = 1, 20, 1 do
								local bossFrame = bossRow["Boss" .. d]
								categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] = categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] or 1

								if(sortedExpansionRaids[i].bosses and sortedExpansionRaids[i].bosses[d]) then
									SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, sortedExpansionRaids[i].bosses[d].creatureDisplayInfoID)

									bossFrame:SetScript("OnClick", function()
										categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] = categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] == 3 and 1
										or categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] + 1

										convertAndRefresh()
									end)
									--categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d]

									bossFrame:SetState(categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d])
									bossFrame:Show()
								else
									bossFrame:Hide()
									bossFrame:SetScript("OnClick", nil)

								end
							end

							bossRow:Show()
							bossRow.layoutIndex = 1004 + i

						end
					end
				end

				miog.NewFilterPanel:MarkDirty()

				v.object:Show()
			else
				miog.NewFilterPanel:MarkDirty()

				v.object:Hide()

			end

		elseif(v.id == nil) then
			v.object:Show()

		else
			v.object:Hide()

		end

	end
end

local function setupFilterPanel()
	local categoryID, currentPanel = miog.getCurrentCategoryID()

	if(categoryID and currentPanel) then
		setFilterVisibilityByCategoryAndPanel(categoryID, currentPanel)

	end
end

miog.setupFilterPanel = setupFilterPanel

miog.loadNewFilterPanel = function()
	miog.NewFilterPanel = CreateFrame("Frame", "MythicIOGrabber_NewFilterPanel", miog.Plugin, "MIOG_NewFilterPanel")
	miog.NewFilterPanel:SetPoint("TOPLEFT", miog.MainFrame, "TOPRIGHT", 5, 0)
	miog.NewFilterPanel:Hide()
	miog.createFrameBorder(miog.NewFilterPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.NewFilterPanel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_NewSettings.backgroundOptions][2] .. "_small.png")
	
	miog.NewFilterPanel.Uncheck:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		local categoryID, currentPanel = miog.getCurrentCategoryID()

		MIOG_NewSettings.filterOptions[currentPanel][categoryID] = miog.defaultFilters

		setupFilterPanel()
		convertAndRefresh()
	end)

	miog.NewFilterPanel.Retract:SetScript("OnClick", function(self)
		miog.hideSidePanel(self)
	end)

	local classPanel = createNewClassPanel(nil, "classPanel")

	local rolePanel = createRolePanel(nil, "roles")
	rolePanel.topPadding = 2
	rolePanel.bottomPadding = 2

	local partyFit = setupTextSetting("PartyFit", "Party fit", "partyFit")
	local ressFit = setupTextSetting("RessFit", "Ress fit", "ressFit")
	local lustFit = setupTextSetting("LustFit", "Lust fit", "lustFit")
	local hideHardDecline = setupTextSetting("HideHardDecline", "Hide hard declines", "hideHardDecline")
	local difficulty = setupDropdownSetting("Difficulty", "Difficulty", "difficulty")
	local tankSpinner = setupDualSpinner("TankSpinnerContainer", "Tank", "tank")
	local healerSpinner = setupDualSpinner("HealerSpinnerContainer", "Healer", "healer")
	local damagerSpinner = setupDualSpinner("DamagerSpinnerContainer", "Damager", "damager")
	local ratingBoxes = setupDualInputBoxes("RatingInputBoxes", "Rating", "rating")
	local ageBoxes = setupDualInputBoxes("AgeInputBoxes", "Age", "age")
	local spacer = setupSpacer("ActivitiesSpacer", "activitiesSpacer")
	local activitiesOption = setupTextSetting("Activities", "Activities", "activities")

	setupFilterPanel()

	miog.NewFilterPanel:MarkDirty()
	
	convertAndRefresh()
end