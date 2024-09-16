local addonName, miog = ...
local wticc = WrapTextInColorCode

local _, id = UnitClassBase("player")

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

local function convertFiltersToAdvancedBlizzardFilters()
	local categoryID = LFGListFrame.SearchPanel.categoryID or LFGListFrame.CategorySelection.selectedCategory

	if(categoryID == 2) then
		local miogFilters = {}

		miogFilters.minimumRating = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].minRating
		miogFilters.hasHealer = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].filterForHealers
		and MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].linkedHealers == false
		and MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].linkedTanks == false
		and MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].minHealers > 0

		miogFilters.hasTank = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].filterForTanks
		and MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].linkedTanks == false
		and MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].linkedHealers == false
		and MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].minTanks > 0

		local difficultyFiltered = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].filterForDifficulty
		miogFilters.difficultyNormal = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonNormal and difficultyFiltered
		miogFilters.difficultyHeroic = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonHeroic and difficultyFiltered
		miogFilters.difficultyMythic = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonMythic and difficultyFiltered
		miogFilters.difficultyMythicPlus = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonChallenge and difficultyFiltered

		miogFilters.needsTank = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].filterForRoles["TANK"] == false
		miogFilters.needsHealer = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].filterForRoles["HEALER"] == false
		miogFilters.needsDamage = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].filterForRoles["DAMAGER"] == false
		miogFilters.needsMyClass = MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].needsMyClass

		miogFilters.activities = {}

		if(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][categoryID].filterForDungeons) then
			if(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][2].dungeons) then
				for k, v in pairs(MIOG_NewSettings.filterOptions["LFGListFrame.SearchPanel"][2].dungeons) do
					if(v == true) then
						miogFilters.activities[#miogFilters.activities+1] = k
					end
					
				end
			else
				miogFilters.activities = C_LFGList.GetAdvancedFilter().activities

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

local function addOptionToFilterFrame(parent, _, text, name)
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

--[[
	Recommended 1
	NotRecommended 2
	PVE 4
	PVP 8
	Timerunning 16
	CurrentExpansion 32
	CurrentSeason 64
	NotCurrentSeason 128
]]

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
end

miog.loadFilterPanel = function()
	miog.FilterPanel = CreateFrame("Frame", "MythicIOGrabber_FilterPanel", miog.Plugin, "MIOG_FilterPanel") ---@class Frame
	miog.FilterPanel:SetPoint("TOPLEFT", miog.MainFrame, "TOPRIGHT", 5, 0)
	miog.FilterPanel:Hide()
	miog.createFrameBorder(miog.FilterPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	
	miog.FilterPanel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_NewSettings.backgroundOptions][2] .. "_small.png")

	miog.FilterPanel.Retract:SetScript("OnClick", function(self)
		miog.hideSidePanel(self)
	end)

	local firstClassPanel, lastClassPanel = createClassSpecFilters(miog.FilterPanel.ClassSpecOptions)
	--firstClassPanel:SetPoint("TOPLEFT", classSpecOption, "BOTTOMLEFT")

	local rolePanel = addRolePanel(miog.FilterPanel.IndexedOptions)
	rolePanel.expand = true
	rolePanel.layoutIndex = 1
	
	local partyFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Party fit", "partyFit")
	partyFitButton.expand = true
	partyFitButton.layoutIndex = 2
	--partyFitButton:SetPoint("TOPLEFT", lastClassPanel, "BOTTOMLEFT", 0, 0)
	
	local ressFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Ress fit", "ressFit")
	ressFitButton.expand = true
	ressFitButton.layoutIndex = 3
	--ressFitButton:SetPoint("TOPLEFT", partyFitButton, "BOTTOMLEFT", 0, 0)

	local lustFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Lust fit", "lustFit")
	lustFitButton.expand = true
	lustFitButton.layoutIndex = 4
	--lustFitButton:SetPoint("TOPLEFT", ressFitButton, "BOTTOMLEFT", 0, 0)
	--affixFitButton:SetPoint("TOPLEFT", lustFitButton, "BOTTOMLEFT", 0, 0)
	
	local hideHardDecline = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Hide hard decline", "hardDecline")
	hideHardDecline.expand = true
	--hideHardDecline:SetPoint("TOPLEFT", miog.FilterPanel.SearchPanelOptions, "TOPLEFT", 0, 0)
	hideHardDecline.layoutIndex = 5

	local dropdownOptionButton = CreateFrame("CheckButton", nil, miog.FilterPanel.IndexedOptions, "MIOG_MinimalCheckButtonTemplate")
	dropdownOptionButton:SetSize(miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	dropdownOptionButton.layoutIndex = 6
	--dropdownOptionButton:SetPoint("TOPLEFT", hideHardDecline, "BOTTOMLEFT", 0, 0)
	dropdownOptionButton:HookScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_NewSettings.filterOptions[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDifficulty = self:GetChecked()
		
		convertFiltersToAdvancedBlizzardFilters()

		if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
			miog.newUpdateFunction()

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

	local tanksSpinner = addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "Tanks")
	tanksSpinner.expand = true
	tanksSpinner.layoutIndex = 7
	--tanksSpinner:SetPoint("TOPLEFT", dropdownOptionButton, "BOTTOMLEFT", 0, 0)

	local healerSpinner = addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "Healers")
	healerSpinner.expand = true
	healerSpinner.layoutIndex = 8
	--healerSpinner:SetPoint("TOPLEFT", tanksSpinner, "BOTTOMLEFT", 0, 0)

	local damagerSpinner = addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "Damager")
	damagerSpinner.expand = true
	damagerSpinner.layoutIndex = 9
	--damagerSpinner:SetPoint("TOPLEFT", healerSpinner, "BOTTOMLEFT", 0, 0)

	local ratingField = addDualNumericFieldsToFilterFrame(miog.FilterPanel.IndexedOptions, "Rating")
	ratingField.expand = true
	ratingField.layoutIndex = 10

	local ageField = addDualNumericFieldsToFilterFrame(miog.FilterPanel.IndexedOptions, "Age")
	ageField.expand = true
	ageField.layoutIndex = 11

	local bossKillsSpinner = addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "BossKills", "Kills")
	bossKillsSpinner.expand = true
	bossKillsSpinner.layoutIndex = 10
	bossKillsSpinner.Link:Hide()

	--[[local affixFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Affix fit", "AffixFit")
	affixFitButton.expand = true
	affixFitButton.layoutIndex = 12]]

	local divider = miog.FilterPanel.IndexedOptions:CreateTexture(nil, "BORDER")
	divider:SetHeight(1)
	divider:SetWidth(miog.FilterPanel.fixedWidth)
	divider:SetAtlas("UI-LFG-DividerLine")
	divider.layoutIndex = 13

	local dungeonPanel = createDungeonPanel(miog.FilterPanel.IndexedOptions)
	dungeonPanel.expand = true
	dungeonPanel.layoutIndex = 14
	miog.addDungeonCheckboxes()

	local raidPanel = createRaidPanel(miog.FilterPanel.IndexedOptions)
	raidPanel.expand = true
	raidPanel.layoutIndex = 15
	miog.addRaidCheckboxes()

	miog.FilterPanel.IndexedOptions:MarkDirty()
	miog.FilterPanel:MarkDirty()
end
