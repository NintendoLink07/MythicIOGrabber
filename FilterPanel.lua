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
	local missingFilters = MIOG_SavedSettings.currentBlizzardFilters == nil and true or false
	local filtersUpToDate = blizzardFilters == MIOG_SavedSettings.currentBlizzardFilters

	if(missingFilters or not filtersUpToDate) then
		MIOG_SavedSettings.currentBlizzardFilters = blizzardFilters

		if(not MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2]) then
			MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2] = miog.getDefaultFilters()
		end

		for k, v in pairs(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"]) do
			if(k == 2) then
				v.minRating = blizzardFilters.minimumRating
				v.minHealers = v.minHealers == 0 and blizzardFilters.hasHealer == true and 1 or v.minHealers or 0
				v.minTanks = v.minTanks == 0 and blizzardFilters.hasTank == true and 1 or v.minTanks or 0

				--v.filterForTanks = blizzardFilters.hasTank
				--v.filterForHealers = blizzardFilters.hasHealer

				v.needsMyClass = blizzardFilters.needsMyClass

				--local _, id = UnitClassBase("player")
				--v.classSpec.class[id] = v.needsMyClass

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

		miogFilters.minimumRating = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minRating
		miogFilters.hasHealer = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForHealers
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].linkedHealers == false
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].linkedTanks == false
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minHealers > 0

		miogFilters.hasTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForTanks
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].linkedTanks == false
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].linkedHealers == false
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minTanks > 0

		local difficultyFiltered = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForDifficulty
		miogFilters.difficultyNormal = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonNormal and difficultyFiltered
		miogFilters.difficultyHeroic = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonHeroic and difficultyFiltered
		miogFilters.difficultyMythic = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonMythic and difficultyFiltered
		miogFilters.difficultyMythicPlus = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonChallenge and difficultyFiltered

		miogFilters.needsTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["TANK"] == false
		miogFilters.needsHealer = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["HEALER"] == false
		miogFilters.needsDamage = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["DAMAGER"] == false
		miogFilters.needsMyClass = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].needsMyClass

		miogFilters.activities = {}

		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForDungeons) then
			if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2].dungeons) then
				for k, v in pairs(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2].dungeons) do
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
		miog.checkSearchResultListForEligibleMembers()

	elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
		C_LFGList.RefreshApplicants()

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

		convertAndRefresh()
	end)

	filterOption.Name:SetText(text)

	parent[name] = filterOption

	return filterOption
end

miog.addOptionToFilterFrame = addOptionToFilterFrame

local function addDualNumericSpinnerToFilterFrame(parent, name, text, range)
	local minName = "min" .. name
	local maxName = "max" .. name
	local settingName = "filterFor" .. name

	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualSpinnerTemplate")
	filterOption:SetSize(220, 25)
	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][settingName] = self:GetChecked()

		convertAndRefresh()
	end)

	filterOption.Name:SetText(text or name)

	parent[name] = filterOption
	parent["Linked" .. name] = filterOption.Link


	filterOption.Link:SetScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]["linked" .. name] = self:GetChecked()

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

					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

					self:SetValue(spinnerValue)

					if(i == 1) then
						if(parent[name].Maximum:GetValue() < spinnerValue) then
							parent[name].Maximum:SetValue(spinnerValue)
							MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][maxName] = spinnerValue

						end

					else
						if(parent[name].Minimum:GetValue() > spinnerValue) then
							parent[name].Minimum:SetValue(spinnerValue)
							MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][minName] = spinnerValue

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

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

			if(parent[name].Minimum:GetValue() > spinnerValue) then
				parent[name].Minimum:SetValue(spinnerValue)
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][minName] = spinnerValue

			end

			currentSpinner:ClearFocus()

			convertAndRefresh()
		end)

		currentSpinner.IncrementButton:SetScript("OnMouseDown", function()
			currentSpinner:Increment()

			local spinnerValue = currentSpinner:GetValue()

			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = spinnerValue

			if(parent[name].Maximum:GetValue() < spinnerValue) then
				parent[name].Maximum:SetValue(spinnerValue)
				MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][maxName] = spinnerValue

			end

			currentSpinner:ClearFocus()

			convertAndRefresh()
		end)
	end

	return filterOption

end

miog.addDualNumericSpinnerToFilterFrame = addDualNumericSpinnerToFilterFrame

local function addDualNumericFieldsToFilterFrame(parent, name)
	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualFieldTemplate")
	filterOption:SetSize(220, 25)
	local settingName = "filterFor" .. name

	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][settingName] = self:GetChecked()

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
		currentField:SetMaxLetters(4)
		currentField:HookScript("OnTextChanged", function(self, ...)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			
			local text = tonumber(self:GetText())
			local currentPanel = LFGListFrame.activePanel:GetDebugName()
			local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
		
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][currentName] = text ~= nil and text or 0

			convertFiltersToAdvancedBlizzardFilters()

			if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][settingName]) then
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

local function updateRaidCheckboxes()
	local sortedExpansionRaids

	if(not MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3]) then
		MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3] = miog.getDefaultFilters()
	end
	
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(3, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE));
	local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, 5)

	if(seasonGroups and #seasonGroups > 0) then
		sortedExpansionRaids = {}
		
		if(miog.ADDED_RAID_FILTERS ~= true) then
			miog.addRaidCheckboxes()
		end

		for _, v in ipairs(seasonGroups) do
			local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
			sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName, bosses = activityInfo.bosses}

		end

		local activityInfo = C_LFGList.GetActivityInfoTable(worldBossActivity[1])
		sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}

		if(sortedExpansionRaids) then
			table.sort(sortedExpansionRaids, function(k1, k2)
				return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID
			end)


			for k, activityEntry in ipairs(sortedExpansionRaids) do
				local currentButton = miog.FilterPanel.IndexedOptions.Raids.Buttons[k]
				MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID] = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID] or false

				currentButton:HookScript("OnClick", function(self)
					MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID] = self:GetChecked()

					if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids) then
						if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
							--miog.FilterPanel.IndexedOptions.Raids.Rows[k]:SetShown(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID])

							miog.FilterPanel.IndexedOptions.Raids.Rows[k]:MarkDirty()
							miog.FilterPanel.IndexedOptions.Raids:MarkDirty()
							miog.FilterPanel.IndexedOptions:MarkDirty()
							miog.FilterPanel:MarkDirty()

							miog.checkSearchResultListForEligibleMembers()
				
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

						MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID] = {}

						miog.checkSearchResultListForEligibleMembers()
					end)

					MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID] = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID] or {}
					
					for x, y in ipairs(activityEntry.bosses) do
						if(currentBossListRow.BossFrames[x]) then
							--SetPortraitTextureFromCreatureDisplayID(currentBossListRow.BossFrames[x].Icon, y.creatureDisplayInfoID)
							
						else
							MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] or 0

							local bossFrame = CreateFrame("Frame", nil, currentBossListRow, "MIOG_FilterPanelBossFrameTemplate")
							--bossFrame:SetPoint("LEFT", currentBossListRow, "LEFT", (x - 1) * (bossFrame:GetWidth()) + 3, 0)
							bossFrame.layoutIndex = x
							SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, y.creatureDisplayInfoID)
							bossFrame.Icon:SetDesaturated(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] or true)

							if(bossFrame.BorderMask == nil) then
								bossFrame.BorderMask = bossFrame:CreateMaskTexture()
								bossFrame.BorderMask:SetAllPoints(bossFrame.Border)
								bossFrame.BorderMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
								bossFrame.Border:AddMaskTexture(bossFrame.BorderMask)
							end
							
							local baseShortValue = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x]

							if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] > 0) then
								bossFrame.Border:SetColorTexture(CreateColorFromHexString(baseShortValue == 1 and miog.CLRSCC.red or baseShortValue == 2 and miog.CLRSCC.green or miog.CLRSCC.white):GetRGBA())
								bossFrame.Border:Show()

							else
								bossFrame.Border:Hide()

							end

							bossFrame.Icon:SetDesaturated(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] < 2 and true or false)

							bossFrame.Icon:SetScript("OnMouseDown", function(self)
								MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] = 
								MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] == 0 and 1 
								or MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] == 1 and 2 
								or MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] == 2 and 0 
								or 1

								if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] > 0) then
									bossFrame.Border:SetColorTexture(CreateColorFromHexString(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] == 1 and miog.CLRSCC.red 
									or MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] == 2 and miog.CLRSCC.green or miog.CLRSCC.white):GetRGBA())
									bossFrame.Border:Show()

								else
									bossFrame.Border:Hide()

								end
								
								self:SetDesaturated(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] < 2 and true or false)

								miog.checkSearchResultListForEligibleMembers()
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

			miog.UPDATED_RAID_FILTERS = true
		end
	end
end

miog.updateRaidCheckboxes = updateRaidCheckboxes

local function addRaidCheckboxes()
	local raidPanel = miog.FilterPanel.IndexedOptions.Raids

	local seasonGroups = C_LFGList.GetAvailableActivityGroups(3, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE));
	local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, 5)
	local maxGroups = #seasonGroups + #worldBossActivity

	if(seasonGroups and #seasonGroups > 0) then
		for i = 1, maxGroups, 1 do
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

		miog.ADDED_RAID_FILTERS = true
	end

	raidPanel:MarkDirty()
end

local function createRaidPanel(parent)
	local raidPanel = CreateFrame("Frame", nil, parent, "VerticalLayoutFrame, BackdropTemplate")
	raidPanel:SetSize(220, 24)
	raidPanel.Buttons = {}
	raidPanel.Rows = {}

	parent.Raids = raidPanel

	local raidOptionsButton = addOptionToFilterFrame(raidPanel, nil, "Raid options", "filterForRaids")
	--raidOptionsButton:SetPoint("TOPLEFT", raidPanel, "TOPLEFT", 0, 0)
	raidOptionsButton.layoutIndex = 1
	raidPanel.Option = raidOptionsButton

	return raidPanel
end

miog.addRaidCheckboxes = addRaidCheckboxes

local function updateDungeonCheckboxes()
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

	if(expansionGroups and #expansionGroups > 0) then
		if(miog.ADDED_DUNGEON_FILTERS ~= true) then
			miog.addDungeonCheckboxes()
		end

		for k, v in ipairs(seasonGroup) do
			local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
			sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}
			addedIDs[v] = true
		end

		for k, v in ipairs(expansionGroups) do
			if(not addedIDs[v]) then
				local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
				sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}
			end
		end

		for k, activityEntry in ipairs(sortedSeasonDungeons) do
			local currentButton = miog.FilterPanel.IndexedOptions.Dungeons.Buttons[k]

			currentButton:HookScript("OnClick", function(self)
				MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2].dungeons[activityEntry.groupFinderActivityGroupID] = self:GetChecked()

				convertFiltersToAdvancedBlizzardFilters()

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

local function createDungeonPanel(parent)
	local dungeonPanel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	dungeonPanel:SetSize(220, 72)
	dungeonPanel.Buttons = {}

	parent.Dungeons = dungeonPanel

	local dungeonOptionsButton = addOptionToFilterFrame(dungeonPanel, nil, "Dungeon options", "filterForDungeons")
	dungeonOptionsButton:SetPoint("TOPLEFT", dungeonPanel, "TOPLEFT", 0, 0)
	dungeonPanel.Option = dungeonOptionsButton

	local dungeonPanelFirstRow = CreateFrame("Frame", nil, dungeonPanel, "HorizontalLayoutFrame, BackdropTemplate")
	dungeonPanelFirstRow:SetSize(dungeonPanel:GetWidth(), 24)
	dungeonPanelFirstRow.spacing = 38
	dungeonPanelFirstRow:SetPoint("TOPLEFT", dungeonOptionsButton, "BOTTOMLEFT")
	dungeonPanel.FirstRow = dungeonPanelFirstRow

	local dungeonPanelSecondRow = CreateFrame("Frame", nil, dungeonPanel, "HorizontalLayoutFrame, BackdropTemplate")
	dungeonPanelSecondRow:SetSize(dungeonPanel:GetWidth(), 24)
	dungeonPanelSecondRow.spacing = 38
	dungeonPanelSecondRow:SetPoint("TOPLEFT", dungeonPanelFirstRow, "BOTTOMLEFT")
	dungeonPanel.SecondRow = dungeonPanelSecondRow

	local dungeonPanelThirdRow = CreateFrame("Frame", nil, dungeonPanel, "HorizontalLayoutFrame, BackdropTemplate")
	dungeonPanelThirdRow:SetSize(dungeonPanel:GetWidth(), 24)
	dungeonPanelThirdRow.spacing = 38
	dungeonPanelThirdRow:SetPoint("TOPLEFT", dungeonPanelSecondRow, "BOTTOMLEFT")
	dungeonPanel.ThirdRow = dungeonPanelThirdRow

	return dungeonPanel
end

local function addDungeonCheckboxes()
	local dungeonPanel = miog.FilterPanel.IndexedOptions.Dungeons
	local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE));

	if(expansionGroups and #expansionGroups > 0) then
		--for i = 1, #seasonGroups, 1 do
		for k, v in ipairs(expansionGroups) do
			local optionButton = CreateFrame("CheckButton", nil, k < 5 and dungeonPanel.FirstRow or k < 9 and dungeonPanel.SecondRow or dungeonPanel.ThirdRow, "MIOG_MinimalCheckButtonTemplate")
			optionButton:SetSize(miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
			optionButton.layoutIndex = k
			--optionButton:SetPoint("LEFT", k < 5 , "LEFT", counter < 4 and counter * 57 or (counter - 4) * 57, 0)
			optionButton:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end)
			
			dungeonPanel.Buttons[k] = optionButton
		
			local optionString = dungeonPanel:CreateFontString(nil, "OVERLAY", "GameTooltipText")
			optionString:SetFont("SystemFont_Shadow_Med1", 12, "OUTLINE")
			optionString:SetPoint("LEFT", optionButton, "RIGHT")

			optionButton.FontString = optionString
		end

		miog.ADDED_DUNGEON_FILTERS = true
	end
end

miog.addDungeonCheckboxes = addDungeonCheckboxes

local function updateFilterDifficulties(reset)
	local currentPanel = LFGListFrame.activePanel:GetDebugName()
	local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

	if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()]) then
		local difficultyDropDown = miog.FilterPanel.IndexedOptions.Difficulty.Dropdown
		difficultyDropDown:ResetDropDown()

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID] = MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]
		or miog.getDefaultFilters()

		--local categoryID = LFGListFrame.SearchPanel.categoryID or C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID

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

		MIOG_SavedSettings.filterOptions.table[currentPanel][categoryID] = miog.getDefaultFilters()

		setupFiltersForActivePanel(true)

		convertAndRefresh()
	end)

	local currentPanel = LFGListFrame.activePanel:GetDebugName()
	local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

	miog.FilterPanel.IndexedOptions.Tanks:SetShown(currentPanel == "LFGListFrame.SearchPanel" and true or false)
	miog.FilterPanel.IndexedOptions.Healers:SetShown(currentPanel == "LFGListFrame.SearchPanel" and true or false)
	miog.FilterPanel.IndexedOptions.Damager:SetShown(currentPanel == "LFGListFrame.SearchPanel" and true or false)
	miog.FilterPanel.IndexedOptions.hardDecline:SetShown(currentPanel == "LFGListFrame.SearchPanel" and true or false)

	miog.FilterPanel.IndexedOptions.BossKills:SetShown(currentPanel == "LFGListFrame.SearchPanel" and categoryID == 3 and true or false)
	miog.FilterPanel.IndexedOptions.Dungeons:SetShown(currentPanel == "LFGListFrame.SearchPanel" and categoryID == 2 and true or false)
	miog.FilterPanel.IndexedOptions.Raids:SetShown(currentPanel == "LFGListFrame.SearchPanel" and categoryID == 3 and true or false)
	miog.FilterPanel.IndexedOptions.Difficulty:SetShown((currentPanel == "LFGListFrame.SearchPanel" and categoryID == 2 or categoryID == 3) and true or false)
	miog.FilterPanel.IndexedOptions.Difficulty.Dropdown:SetShown((currentPanel == "LFGListFrame.SearchPanel" and categoryID == 2 or categoryID == 3) and true or false)

	miog.FilterPanel.IndexedOptions:MarkDirty()

	if(categoryID) then
		local currentSettings = MIOG_SavedSettings.filterOptions.table[currentPanel][categoryID]

		if(currentSettings == nil) then
			currentSettings = miog.getDefaultFilters()
			
		else
			for key, value in pairs(miog.defaultOptionSettings.filterOptions.table.default) do
				if(currentSettings[key] == nil) then
					currentSettings[key] = value

				end
			end
		end

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

		miog.FilterPanel.IndexedOptions.Age:SetShown(currentPanel == "LFGListFrame.SearchPanel")
		miog.FilterPanel.IndexedOptions.Age.Button:SetChecked(currentSettings.filterForAge)
		miog.FilterPanel.IndexedOptions.Age.Minimum:SetNumber(currentSettings.minAge or 0)
		miog.FilterPanel.IndexedOptions.Age.Maximum:SetNumber(currentSettings.maxAge or 0)

		miog.FilterPanel.IndexedOptions.BossKills.Button:SetChecked(currentSettings.filterForBossKills)
		miog.FilterPanel.IndexedOptions.BossKills.Minimum:SetValue(currentSettings.minBossKills)
		miog.FilterPanel.IndexedOptions.BossKills.Maximum:SetValue(currentSettings.maxBossKills)

		miog.FilterPanel.IndexedOptions.partyFit:SetShown(currentPanel == "LFGListFrame.SearchPanel")
		miog.FilterPanel.IndexedOptions.partyFit.Button:SetChecked(currentSettings.partyFit)

		miog.FilterPanel.IndexedOptions.ressFit.Button:SetChecked(currentSettings.ressFit)
		miog.FilterPanel.IndexedOptions.lustFit.Button:SetChecked(currentSettings.lustFit)

		miog.FilterPanel.IndexedOptions.hardDecline.Button:SetChecked(currentSettings.hardDecline)

		miog.FilterPanel.IndexedOptions.AffixFit:SetShown(categoryID == 2 and true or false)
		miog.FilterPanel.IndexedOptions.AffixFit.Button:SetChecked(currentSettings.affixFit)

		miog.FilterPanel.ClassSpecOptions.Option.Button:SetChecked(reset or currentSettings.filterForClassSpecs)

		for classIndex, classEntry in ipairs(miog.CLASSES) do
			local currentClassPanel = miog.FilterPanel.ClassSpecOptions.Panels[classIndex]

			if(MIOG_SavedSettings and currentSettings.classSpec) then
				if(currentSettings.classSpec.class[classIndex] ~= nil) then
					if(classIndex == id) then
						currentClassPanel.Class.Button:SetChecked(reset or not currentSettings.needsMyClass)
						
					else
						currentClassPanel.Class.Button:SetChecked(reset or currentSettings.classSpec.class[classIndex])

					end

				else
					if(classIndex == id) then
						currentClassPanel.Class.Button:SetChecked(not currentSettings.needsMyClass)
						
					else
						currentClassPanel.Class.Button:SetChecked(true)

					end

				end

			else
				currentClassPanel.Class.Button:SetChecked(true)

			end
			
			currentClassPanel.Class.Button:SetScript("OnClick", function(self)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				
				local state = self:GetChecked()

				if(classIndex == id) then
					currentSettings.needsMyClass = not state

					if(currentSettings.needsMyClass == true) then
						currentSettings.classSpec.class[id] = nil

					else
						currentSettings.classSpec.class[id] = state

					end
					
				else
					currentSettings.classSpec.class[classIndex] = state

				end

				for specIndex, specFrame in pairs(currentClassPanel.SpecFrames) do
					specFrame.Button:SetChecked(state)
					
					if(classIndex == id) then
						if(currentSettings.needsMyClass == true) then
							currentSettings.classSpec.spec[specIndex] = nil

						else
							currentSettings.classSpec.spec[specIndex] = state

						end
					else
						currentSettings.classSpec.spec[specIndex] = state
					
					end
				end

				convertFiltersToAdvancedBlizzardFilters()

				if(currentSettings.filterForClassSpecs) then
					if(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
						miog.checkSearchResultListForEligibleMembers()
			
					elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
						C_LFGList.RefreshApplicants()
			
					end
				end
			end)

			for specIndex, specID in pairs(classEntry.specs) do
				local currentSpecFrame = currentClassPanel.SpecFrames[specID]
				if(MIOG_SavedSettings and currentSettings.classSpec) then
					if(currentSettings.classSpec.spec[specID] ~= nil) then
						if(classIndex == id) then
							currentSpecFrame.Button:SetChecked(reset or not currentSettings.needsMyClass)
							
						else
							currentSpecFrame.Button:SetChecked(reset or currentSettings.classSpec.spec[specID])

						end

					else
						if(classIndex == id) then
							currentSpecFrame.Button:SetChecked(reset or not currentSettings.needsMyClass)
							
						else
							currentSpecFrame.Button:SetChecked(true)
	
						end

					end

				else
					currentSpecFrame.Button:SetChecked(true)

				end
				
				currentSpecFrame.Button:SetScript("OnClick", function(self)
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

					local state = self:GetChecked()

					if(state) then
						currentClassPanel.Class.Button:SetChecked(true)

					end

					currentSettings.classSpec.spec[specID] = state

					convertFiltersToAdvancedBlizzardFilters()

					if(currentSettings.filterForClassSpecs) then
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
			miog.FilterPanel.IndexedOptions.Dungeons.Option.Button:SetChecked(reset or currentSettings.filterForDungeons)

			local sortedSeasonDungeons = {}
			local addedIDs = {}

			local seasonGroup = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
			local expansionGroup = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE));	
			
			table.sort(seasonGroup, function(k1, k2)
				return miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k1].activityID].shortName < miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k2].activityID].shortName
			end)
		
			table.sort(expansionGroup, function(k1, k2)
				return miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k1].activityID].shortName < miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[k2].activityID].shortName
			end)

			if(expansionGroup) then
				for k, v in ipairs(seasonGroup) do
					local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
					sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}
					addedIDs[v] = true
				end

				for k, v in ipairs(expansionGroup) do
					if(not addedIDs[v]) then
						local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
						sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}
					end
				end

				for k, activityEntry in ipairs(sortedSeasonDungeons) do
					local checked = currentSettings.dungeons[activityEntry.groupFinderActivityGroupID]
					miog.FilterPanel.IndexedOptions.Dungeons.Buttons[k]:SetChecked(reset or checked)
				end
			end
		elseif(categoryID == 3) then
			local sortedExpansionRaids = {}
			miog.FilterPanel.IndexedOptions.Raids.Option.Button:SetChecked(reset or currentSettings.filterForRaids)

			if(LFGListFrame.SearchPanel.filters == Enum.LFGListFilter.Recommended) then
				local seasonGroups = C_LFGList.GetAvailableActivityGroups(3, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE));
				local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, 5)

				if(seasonGroups) then
					sortedExpansionRaids = {}

					for _, v in ipairs(seasonGroups) do
						local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
						sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName, bosses = activityInfo.bosses}

					end

					local activityInfo = C_LFGList.GetActivityInfoTable(worldBossActivity[1])
					sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = activityInfo.shortName}

					table.sort(sortedExpansionRaids, function(k1, k2)
						return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID
					end)

					for k, activityEntry in ipairs(sortedExpansionRaids) do
						miog.FilterPanel.IndexedOptions.Raids.Buttons[k]:SetChecked(reset or currentSettings.raids[activityEntry.groupFinderActivityGroupID])

						currentSettings.raidBosses[activityEntry.groupFinderActivityGroupID] = currentSettings.raidBosses[activityEntry.groupFinderActivityGroupID] or {}

						if(activityEntry.bosses) then
							for x, y in ipairs(activityEntry.bosses) do
								local bossFrame = miog.FilterPanel.IndexedOptions.Raids.Rows[k].BossFrames[x]
								bossFrame.Icon:SetDesaturated(currentSettings.raidBosses[activityEntry.groupFinderActivityGroupID][x] or true)

								miog.FilterPanel.IndexedOptions.Dungeons.Buttons[k]:SetChecked(reset or currentSettings.raidBosses[activityEntry.groupFinderActivityGroupID])
								
							end
						end
					end
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
	roleFilterPanel:SetSize(150, 20)
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
		
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRoles[i == 1 and "TANK" or i == 2 and "HEALER" or "DAMAGER"] = state

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

	miog.FilterPanel.Retract:SetScript("OnClick", function(self)
		miog.hideSidePanel(self)
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

	local dropdownOptionButton = CreateFrame("CheckButton", nil, miog.FilterPanel.IndexedOptions, "MIOG_MinimalCheckButtonTemplate")
	dropdownOptionButton:SetSize(miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	dropdownOptionButton.layoutIndex = 6
	--dropdownOptionButton:SetPoint("TOPLEFT", hideHardDecline, "BOTTOMLEFT", 0, 0)
	dropdownOptionButton:HookScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDifficulty = self:GetChecked()
		
		convertFiltersToAdvancedBlizzardFilters()

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

	local ratingField = miog.addDualNumericFieldsToFilterFrame(miog.FilterPanel.IndexedOptions, "Rating")
	ratingField.layoutIndex = 10

	local ageField = miog.addDualNumericFieldsToFilterFrame(miog.FilterPanel.IndexedOptions, "Age")
	ageField.layoutIndex = 11

	local bossKillsSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "BossKills", "Kills")
	bossKillsSpinner.layoutIndex = 10
	bossKillsSpinner.Link:Hide()
	--bossKillsSpinner:SetPoint("TOPLEFT", damagerSpinner, "BOTTOMLEFT", 0, 0)

	local affixFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Affix fit", "AffixFit")
	affixFitButton.layoutIndex = 12

	local divider = miog.FilterPanel.IndexedOptions:CreateTexture(nil, "BORDER")
	divider:SetSize(miog.FilterPanel.fixedWidth, 1)
	divider:SetAtlas("UI-LFG-DividerLine")
	divider.layoutIndex = 13

	local dungeonPanel = createDungeonPanel(miog.FilterPanel.IndexedOptions)
	dungeonPanel.layoutIndex = 14
	miog.addDungeonCheckboxes()
	--dungeonPanel:SetPoint("TOPLEFT", dungeonOptionsButton, "BOTTOMLEFT", 0, 0)

	local raidPanel = createRaidPanel(miog.FilterPanel.IndexedOptions)
	raidPanel.layoutIndex = 15
	miog.addRaidCheckboxes()
	--raidPanel:SetPoint("TOPLEFT", raidOptionsButton, "BOTTOMLEFT", 0, 0)
	--raidPanel.OptionsButton = raidOptionsButton

	miog.FilterPanel.IndexedOptions:MarkDirty()
	miog.FilterPanel:MarkDirty()
end
