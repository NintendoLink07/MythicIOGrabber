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

				v.filterForTanks = blizzardFilters.hasTank
				v.filterForHealers = blizzardFilters.hasHealer

				v.filterForRating = v.minRating > 0 and true

				local _, id = UnitClassBase("player")
				v.classSpec.class[id] = blizzardFilters.needsMyClass == false
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
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].linkedHealers == true
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minHealers > 0

		miogFilters.hasTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForTanks
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].linkedTanks == true
		and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].minTanks > 0

		local difficultyFiltered = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForDifficulty
		miogFilters.difficultyNormal = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonNormal and difficultyFiltered
		miogFilters.difficultyHeroic = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonHeroic and difficultyFiltered
		miogFilters.difficultyMythic = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonMythic and difficultyFiltered
		miogFilters.difficultyMythicPlus = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].difficultyID == DifficultyUtil.ID.DungeonChallenge and difficultyFiltered

		local _, id = UnitClassBase("player")
		miogFilters.needsMyClass = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].classSpec.class[id] == false
		miogFilters.needsTank = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["TANK"] == false
		miogFilters.needsHealer = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["HEALER"] == false
		miogFilters.needsDamage = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][categoryID].filterForRoles["DAMAGER"] == false

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
	local settingName = "filterFor" .. name

	local filterOption = CreateFrame("Frame", nil, parent, "MIOG_FilterOptionDualSpinnerTemplate")
	filterOption:SetSize(220, 25)
	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory
	
		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][settingName] = self:GetChecked()

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

		convertFiltersToAdvancedBlizzardFilters()

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID]["linked" .. name] = self:GetChecked()

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

			if(parent[name].Minimum:GetValue() > spinnerValue) then
				parent[name].Minimum:SetValue(spinnerValue)
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

			if(parent[name].Maximum:GetValue() < spinnerValue) then
				parent[name].Maximum:SetValue(spinnerValue)
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
	local settingName = "filterFor" .. name

	--local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", parent, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	filterOption.Button:HookScript("OnClick", function(self)
		local currentPanel = LFGListFrame.activePanel:GetDebugName()
		local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][settingName] = self:GetChecked()

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
				MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID] = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID] or {}

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

						for _, v in pairs(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID]) do
							v = {}
							
						end

						miog.checkSearchResultListForEligibleMembers()
					end)

					--miog.FilterPanel.IndexedOptions.Raids.Rows[k]:SetShown(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raids[activityEntry.groupFinderActivityGroupID])
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
			local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", raidPanel, 20, 20)
			optionButton.layoutIndex = i + 1
			optionButton:SetNormalAtlas("checkbox-minimal")
			optionButton:SetPushedAtlas("checkbox-minimal")
			optionButton:SetCheckedTexture("checkmark-minimal")
			optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
			optionButton:RegisterForClicks("LeftButtonDown")
		
			raidPanel.Buttons[i] = optionButton
		
			local optionString = miog.createBasicFontString("persistent", 12, raidPanel)
			optionString:SetPoint("LEFT", optionButton, "RIGHT")

			optionButton.FontString = optionString


			local raidBossRow = miog.createBasicFrame("persistent", "HorizontalLayoutFrame, BackdropTemplate", raidPanel, raidPanel:GetWidth(), 24)
			raidBossRow:SetPoint("LEFT", optionButton, "RIGHT", 36, 0)
			raidBossRow.BossFrames = {}
			raidPanel.Rows[i] = raidBossRow

			local resetButton = miog.createBasicFrame("persistent", "IconButtonTemplate", raidBossRow, 20, 20)
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
	local raidPanel = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", parent, 220, 24)
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
	local dungeonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", parent, 220, 72)
	dungeonPanel.Buttons = {}

	parent.Dungeons = dungeonPanel

	local dungeonOptionsButton = addOptionToFilterFrame(dungeonPanel, nil, "Dungeon options", "filterForDungeons")
	dungeonOptionsButton:SetPoint("TOPLEFT", dungeonPanel, "TOPLEFT", 0, 0)
	dungeonPanel.Option = dungeonOptionsButton

	local dungeonPanelFirstRow = miog.createBasicFrame("persistent", "HorizontalLayoutFrame, BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), 24)
	dungeonPanelFirstRow.spacing = 38
	dungeonPanelFirstRow:SetPoint("TOPLEFT", dungeonOptionsButton, "BOTTOMLEFT")
	dungeonPanel.FirstRow = dungeonPanelFirstRow

	local dungeonPanelSecondRow = miog.createBasicFrame("persistent", "HorizontalLayoutFrame, BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), 24)
	dungeonPanelSecondRow.spacing = 38
	dungeonPanelSecondRow:SetPoint("TOPLEFT", dungeonPanelFirstRow, "BOTTOMLEFT")
	dungeonPanel.SecondRow = dungeonPanelSecondRow

	local dungeonPanelThirdRow = miog.createBasicFrame("persistent", "HorizontalLayoutFrame, BackdropTemplate", dungeonPanel, dungeonPanel:GetWidth(), 24)
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
			local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", k < 5 and dungeonPanel.FirstRow or k < 9 and dungeonPanel.SecondRow or dungeonPanel.ThirdRow, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
			optionButton.layoutIndex = k
			--optionButton:SetPoint("LEFT", k < 5 , "LEFT", counter < 4 and counter * 57 or (counter - 4) * 57, 0)
			optionButton:SetNormalAtlas("checkbox-minimal")
			optionButton:SetPushedAtlas("checkbox-minimal")
			optionButton:SetCheckedTexture("checkmark-minimal")
			optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
			optionButton:RegisterForClicks("LeftButtonDown")
			optionButton:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end)
			
			dungeonPanel.Buttons[k] = optionButton
		
			local optionString = miog.createBasicFontString("persistent", 12, dungeonPanel)
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

		convertFiltersToAdvancedBlizzardFilters()

		miog.checkSearchResultListForEligibleMembers()
	end)


	local currentPanel = LFGListFrame.activePanel:GetDebugName()
	local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

	miog.FilterPanel.IndexedOptions.Tanks:SetShown(currentPanel == "LFGListFrame.SearchPanel" and true or false)
	miog.FilterPanel.IndexedOptions.Healers:SetShown(currentPanel == "LFGListFrame.SearchPanel" and true or false)
	miog.FilterPanel.IndexedOptions.Damager:SetShown(currentPanel == "LFGListFrame.SearchPanel" and true or false)

	miog.FilterPanel.IndexedOptions.Rating:SetShown(currentPanel == "LFGListFrame.SearchPanel" and categoryID == 2 and true or false)
	miog.FilterPanel.IndexedOptions.BossKills:SetShown(currentPanel == "LFGListFrame.SearchPanel" and categoryID == 3 and true or false)
	miog.FilterPanel.IndexedOptions.Dungeons:SetShown(currentPanel == "LFGListFrame.SearchPanel" and categoryID == 2 and true or false)
	miog.FilterPanel.IndexedOptions.AffixFit:SetShown(currentPanel == "LFGListFrame.SearchPanel" and categoryID == 2 and true or false)
	miog.FilterPanel.IndexedOptions.Raids:SetShown(currentPanel == "LFGListFrame.SearchPanel" and categoryID == 3 and true or false)
	miog.FilterPanel.IndexedOptions.Difficulty:SetShown((currentPanel == "LFGListFrame.SearchPanel" and categoryID == 2 or categoryID == 3) and true or false)
	miog.FilterPanel.IndexedOptions.Difficulty.Dropdown:SetShown((currentPanel == "LFGListFrame.SearchPanel" and categoryID == 2 or categoryID == 3) and true or false)

	miog.FilterPanel.IndexedOptions:MarkDirty()

	if(categoryID) then
		if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID] == nil) then
			MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID] = miog.getDefaultFilters()
			
		else
			for key, value in pairs(miog.defaultOptionSettings.filterOptions.table.default) do
				if(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][key] == nil) then
					MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID][key] = value

				end
			end
		end

		updateFilterDifficulties(reset)

		--/run print(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][2].linkedTanks)

		miog.FilterPanel.IndexedOptions.Roles.Buttons[1]:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRoles["TANK"])
		miog.FilterPanel.IndexedOptions.Roles.Buttons[2]:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRoles["HEALER"])
		miog.FilterPanel.IndexedOptions.Roles.Buttons[3]:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRoles["DAMAGER"])

		miog.FilterPanel.IndexedOptions.Difficulty:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDifficulty)

		miog.FilterPanel.IndexedOptions.LinkedTanks:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedTanks)
		miog.FilterPanel.IndexedOptions.LinkedHealers:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedHealers)
		miog.FilterPanel.IndexedOptions.LinkedDamager:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].linkedDamager)

		miog.FilterPanel.IndexedOptions.Tanks.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForTanks)
		miog.FilterPanel.IndexedOptions.Tanks.Minimum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minTanks)
		miog.FilterPanel.IndexedOptions.Tanks.Maximum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxTanks)

		miog.FilterPanel.IndexedOptions.Healers.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForHealers)
		miog.FilterPanel.IndexedOptions.Healers.Minimum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minHealers)
		miog.FilterPanel.IndexedOptions.Healers.Maximum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxHealers)

		miog.FilterPanel.IndexedOptions.Damager.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForDamager)
		miog.FilterPanel.IndexedOptions.Damager.Minimum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minDamager)
		miog.FilterPanel.IndexedOptions.Damager.Maximum:SetValue(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxDamager)

		miog.FilterPanel.IndexedOptions.Rating.Button:SetChecked(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRating)
		miog.FilterPanel.IndexedOptions.Rating.Minimum:SetNumber(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].minRating or 0)
		miog.FilterPanel.IndexedOptions.Rating.Maximum:SetNumber(MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].maxRating or 0)

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

				else
					currentClassPanel.Class.Button:SetChecked(true)

				end

			else
				currentClassPanel.Class.Button:SetChecked(true)

			end
			
			currentClassPanel.Class.Button:SetScript("OnClick", function(self)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

				local state = self:GetChecked()

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

					else
						currentSpecFrame.Button:SetChecked(true)

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
					local notChecked = MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][2].dungeons[activityEntry.groupFinderActivityGroupID] == false
					miog.FilterPanel.IndexedOptions.Dungeons.Buttons[k]:SetChecked(reset or not notChecked)
				end
			end
		elseif(categoryID == 3) then
			local sortedExpansionRaids = {}
			miog.FilterPanel.IndexedOptions.Raids.Option.Button:SetChecked(reset or MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][categoryID].filterForRaids)

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
						local checked = MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][3].raids[activityEntry.groupFinderActivityGroupID]
						miog.FilterPanel.IndexedOptions.Raids.Buttons[k]:SetChecked(reset or checked)

						MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][3].raidBosses[activityEntry.groupFinderActivityGroupID] = MIOG_SavedSettings.filterOptions.table[LFGListFrame.activePanel:GetDebugName()][3].raidBosses[activityEntry.groupFinderActivityGroupID] or {}

						if(activityEntry.bosses) then
							for x, y in ipairs(activityEntry.bosses) do
								local bossFrame = miog.FilterPanel.IndexedOptions.Raids.Rows[k].BossFrames[x]
								bossFrame.Icon:SetDesaturated(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][3].raidBosses[activityEntry.groupFinderActivityGroupID][x] or true)
								
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

	local bossKillsSpinner = miog.addDualNumericSpinnerToFilterFrame(miog.FilterPanel.IndexedOptions, "BossKills", "Kills")
	bossKillsSpinner.layoutIndex = 10
	bossKillsSpinner.Link:Hide()
	--bossKillsSpinner:SetPoint("TOPLEFT", damagerSpinner, "BOTTOMLEFT", 0, 0)

	local affixFitButton = addOptionToFilterFrame(miog.FilterPanel.IndexedOptions, nil, "Affix fit", "AffixFit")
	affixFitButton.layoutIndex = 11

	local divider = miog.createBasicTexture("persistent", nil, miog.FilterPanel.IndexedOptions, miog.FilterPanel.fixedWidth, 1, "BORDER")
	divider:SetAtlas("UI-LFG-DividerLine")
	divider.layoutIndex = 12

	local dungeonPanel = createDungeonPanel(miog.FilterPanel.IndexedOptions)
	dungeonPanel.layoutIndex = 13
	miog.addDungeonCheckboxes()
	--dungeonPanel:SetPoint("TOPLEFT", dungeonOptionsButton, "BOTTOMLEFT", 0, 0)

	local raidPanel = createRaidPanel(miog.FilterPanel.IndexedOptions)
	raidPanel.layoutIndex = 13
	miog.addRaidCheckboxes()
	--raidPanel:SetPoint("TOPLEFT", raidOptionsButton, "BOTTOMLEFT", 0, 0)
	--raidPanel.OptionsButton = raidOptionsButton

	miog.FilterPanel.IndexedOptions:MarkDirty()
	miog.FilterPanel:MarkDirty()
end
