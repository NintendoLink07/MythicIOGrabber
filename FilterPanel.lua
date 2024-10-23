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

	activities {groupFinderActivityGroupID}
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
		miogFilters.needsMyClass = currentSettings.needsMyClass

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
		
	if(miog.DropChecker and miog.DropChecker:IsShown()) then
		miog.checkAllDropCheckerItemIDs()

	elseif(LFGListFrame.activePanel == LFGListFrame.SearchPanel) then
		miog.newUpdateFunction()

	elseif(LFGListFrame.activePanel == LFGListFrame.ApplicationViewer) then
		C_LFGList.RefreshApplicants()

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

local function setupIconSetting(key, parent, texture, filterID)
	local icon = parent[key]
	icon.Icon:SetTexture(texture)
	icon:SetWidth(36)
	icon.layoutIndex = #parent:GetLayoutChildren() + 1
		
	icon.Button:SetScript("PostClick", function()
		convertAndRefresh()
	end)

	if(filterID) then
		table.insert(allFilters, {type = "icon", id = filterID, object = icon})

	end

	return icon
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
	containerFrame.Setting.Button:SetScript("PostClick", function(self)
		convertAndRefresh(self:GetChecked())
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

	for classIndex, classInfo in ipairs(miog.CLASSES) do
		--containerFrame = CreateFrame("Frame", nil, parent or miog.NewFilterPanel, "MIOG_NewFilterPanelContainerRowTemplate")
		containerFrame = miog.NewFilterPanel[classInfo.name]
		containerFrame.layoutIndex = #containerFrame:GetParent():GetLayoutChildren() + 1
		containerFrame.classID = classIndex

		local r, g, b = GetClassColor(classInfo.name)
		containerFrame.Border:SetColorTexture(r, g, b, 0.9)
		containerFrame.Background:SetColorTexture(r, g, b, 0.6)

		local classFrame = containerFrame.ClassFrame
		classFrame.classID = classIndex
		setupIconSetting("ClassFrame", containerFrame, classInfo.roundIcon)
		
		classFrame.Icon:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(GetClassInfo(self:GetParent().classID))
			GameTooltip:Show()
		end)

		for specIndex, specID in ipairs(classInfo.specs) do
			local specInfo = miog.SPECIALIZATIONS[specID]

			local specFrame = setupIconSetting("Spec" .. specIndex, containerFrame, specInfo.icon)
			specFrame.specID = specID
			specFrame.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(select(2, GetSpecializationInfoByID(self:GetParent().specID)))
				GameTooltip:Show()
			end)
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
	if(id == 3 or id == 7 or id == 8 or id == 13) then
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
	if(id == 2 or id == 6 or id == 9 or id == 11) then
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
				return false, "incorrectCategory"

			end

			local rating = isPvp and (searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0) or searchResultInfo.leaderOverallDungeonScore or 0
			
			if(settings.hideHardDecline and MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID] and MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID].activeDecline) then
				return false, "hardDeclined"
				
			end

			if(settings.difficulty.value) then
				if(isDungeon or isRaid) then
					if(miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID ~= settings.difficulty.id
					)then
						return false, "incorrectDifficulty"

					end
				elseif(isPvp) then
					if(searchResultInfo.activityID ~= settings.difficulty.id) then
						return false, "incorrectBracket"

					end
				end
			end

			for i = 1, searchResultInfo.numMembers, 1 do
				local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(searchResultInfo.searchResultID, i)

				if(role) then
					roleCount[role] = roleCount[role] + 1

				end

				if(settings.needsMyClass == true and miog.CLASSFILE_TO_ID[class] == id or settings.classes[miog.CLASSFILE_TO_ID[class]] == false) then
					return false, "classFiltered"

				end

				if(class and settings.specs[miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]] == false) then
					return false, "specFiltered"

				end

			end

			local tankCountInRange = roleCount["TANK"] >= settings.tank.minimum and roleCount["TANK"] <= settings.tank.maximum
			local healerCountInRange = roleCount["HEALER"] >= settings.healer.minimum and roleCount["HEALER"] <= settings.healer.maximum
			local damagerCountInRange = roleCount["DAMAGER"] >= settings.damager.minimum and roleCount["DAMAGER"] <= settings.damager.maximum

			local tanksOk = settings.tank.value == false or
			settings.tank.value and tankCountInRange == true

			local healersOk = settings.healer.value == false or
			settings.healer.value and healerCountInRange == true

			local damagerOk = settings.damager.value == false or
			settings.damager.value and damagerCountInRange == true

			if(not tanksOk and (settings.tank.linked ~= true or settings.tank.linked == true and settings.healer.linked == false and settings.damager.linked == false)
			or not healersOk and (settings.healer.linked ~= true or settings.healer.linked == true and settings.damager.linked == false and settings.tank.linked == false)
			or not damagerOk and (settings.damager.linked ~= true or settings.damager.linked == true and settings.tank.linked == false and settings.healer.linked == false)) then
				return false, "incorrectNumberOfRoles"
			end

			if(settings.tank.linked and settings.healer.linked and not tanksOk and not healersOk
			or settings.healer.linked and settings.damager.linked and not healersOk and not damagerOk
			or settings.damager.linked and settings.tank.linked and not damagerOk and not tanksOk) then
				return false, "incorrectNumberOfRoles"
				
			end

			if(settings.tank.linked and settings.healer.linked and not tanksOk and not healersOk
			or settings.healer.linked and settings.damager.linked and not healersOk and not damagerOk
			or settings.damager.linked and settings.tank.linked and not damagerOk and not tanksOk) then
				return false, "incorrectNumberOfRoles"
				
			end

			if(settings.roles["TANK"] == false and roleCount["TANK"] > 0) then
				return false, "incorrectRoles"
			end

			if(settings.roles["HEALER"] == false and roleCount["HEALER"] > 0) then
				return false, "incorrectRoles"
			end

			if(settings.roles["DAMAGER"] == false and roleCount["DAMAGER"] > 0) then
				return false, "incorrectRoles"
			end
				
			if(settings.age.value) then
				if(settings.age.minimum ~= 0 and settings.age.maximum ~= 0) then
					if(settings.age.maximum >= 0 and not (searchResultInfo.age >= settings.age.minimum * 60 and searchResultInfo.age <= settings.age.maximum * 60)) then
						return false, "ageMismatch"

					end
				elseif(settings.age.minimum ~= 0) then
					if(searchResultInfo.age < settings.age.minimum * 60) then
						return false, "ageLowerMismatch"

					end
				elseif(settings.age.maximum ~= 0) then
					if(searchResultInfo.age >= settings.age.maximum * 60) then
						return false, "ageHigherMismatch"

					end

				end
			end

			if(settings.activities.value and (isRaid or isDungeon)) then
				if(isDungeon and not settings.activities[activityInfo.groupFinderActivityGroupID].value) then
					return false, "dungeonMismatch"

				end

				if(isRaid and LFGListFrame.SearchPanel.filters == 1 and settings.activities[activityInfo.groupFinderActivityGroupID]) then
					if(not settings.activities[activityInfo.groupFinderActivityGroupID].value) then
						return false, "raidMismatch"

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
								if(v == 2 and encountersDefeated[bossInfo.name] or v == 3 and not encountersDefeated[bossInfo.name]) then
									return false, "bossSelectionMismatch"

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
								return false, "bossKillsMismatch"

							end
						elseif(minKills ~= 0) then
							if(numberOfSlainEncounters < minKills) then
								return false, "bossKillsLowerMismatch"

							end
						elseif(maxKills ~= 0) then
							if(numberOfSlainEncounters >= maxKills) then
								return false, "bossKillsHigherMismatch"

							end

						end

					end

				end
			end

			if(isDungeon or isPvp) then
				if(settings.rating.value) then
					if(settings.rating.minimum ~= 0 and settings.rating.maximum ~= 0) then
						if(settings.rating.maximum >= 0
						and not (rating >= settings.rating.minimum
						and rating <= settings.rating.maximum)) then
							return false, "ratingMismatch"

						end
					elseif(settings.rating.minimum ~= 0) then
						if(rating < settings.rating.minimum) then
							return false, "ratingLowerMismatch"

						end
					elseif(settings.rating.maximum ~= 0) then
						if(rating >= settings.rating.maximum) then
							return false, "ratingHigherMismatch"

						end

					end
				end
			end

			if(settings.partyFit and not HasRemainingSlotsForLocalPlayerRole(searchResultInfo.searchResultID)) then
				return false, "partyFit"
		
			end
		
			if(settings.ressFit and not HasRemainingSlotsForBattleResurrection(searchResultInfo.searchResultID)) then
				return false, "ressFit"
		
			end
		
			if(settings.lustFit and not HasRemainingSlotsForBloodlust(searchResultInfo.searchResultID)) then
				return false, "lustFit"
		
			end
		else
			return false, "noResult"

		end
	elseif(panel == "LFGListFrame.ApplicationViewer") then
		local categoryID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

		settings = MIOG_NewSettings.newFilterOptions[panel][categoryID]
		
		if(settings.ressFit) then
			local _, _, playerClassID = UnitClass("player")
			if(playerClassID == 2 or playerClassID == 6 or playerClassID == 9 or playerClassID == 11) then
	
			elseif(resultOrApplicant.class ~= "PALADIN" and resultOrApplicant.class ~= "DEATHKNIGHT" and resultOrApplicant.class ~= "WARLOCK" and resultOrApplicant.class ~= "DRUID") then
				return false, "ressFit"
	
			end
		end
	
		if(settings.lustFit) then
			local _, _, playerClassID = UnitClass("player")
			if(playerClassID == 3 or playerClassID == 7 or playerClassID == 8 or playerClassID == 13) then
				--return true
	
			elseif(resultOrApplicant.class ~= "HUNTER" and resultOrApplicant.class ~= "SHAMAN" and resultOrApplicant.class ~= "MAGE" and resultOrApplicant.class ~= "EVOKER") then
				return false, "lustFit"
	
			end
		end

		if(settings.roles[resultOrApplicant.role] == false) then
			return false, "incorrectRoles"
	
		end
	
		if(settings.classes[miog.CLASSFILE_TO_ID[resultOrApplicant.class]] == false) then
			return false, "classFiltered"
		
		end

		if(settings.specs[resultOrApplicant.specID] == false) then
			return false, "specFiltered"

		end
	
		local isPvp = categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9
		local isDungeon = categoryID == 2
	
		if(isDungeon or isPvp) then
			local rating = resultOrApplicant.primary or 0
	
			if(settings.rating.value and rating) then
				if(settings.rating.minimum ~= 0 and settings.rating.maximum ~= 0) then
					if(settings.rating.maximum >= 0
					and not (rating >= settings.rating.minimum
					and rating <= settings.rating.maximum)) then
						return false, "ratingMismatch"

					end
				elseif(settings.rating.minimum ~= 0) then
					if(rating < settings.rating.minimum) then
						return false, "ratingLowerMismatch"

					end
				elseif(settings.rating.maximum ~= 0) then
					if(rating >= settings.rating.maximum) then
						return false, "ratingHigherMismatch"
						
					end

				end
			end
		end
	end
	
	return true, {"All filters checked and group is okay", "All good"}
end

miog.checkEligibility = checkEligibility

local function setFilterVisibilityByCategoryAndPanel(categoryID, panel)
	MIOG_NewSettings.newFilterOptions[panel] = MIOG_NewSettings.newFilterOptions[panel] or {}
	MIOG_NewSettings.newFilterOptions[panel][categoryID] = MIOG_NewSettings.newFilterOptions[panel][categoryID] or {}

	local categorySettings = MIOG_NewSettings.newFilterOptions[panel][categoryID]
	local activitiesLine

	for k, v in ipairs(allFilters) do
		if(v.id == "activitiesSpacer" and (categoryID == 0 or categoryID == 2 or categoryID == 3)) then
			v.object:Show()
		
		elseif(v.id == "classPanel" and categoryID ~= 0) then
			v.object:Show()

			categorySettings.classes = categorySettings.classes or {}
			categorySettings.specs = categorySettings.specs or {}

			if(categoryID == 2 and categorySettings.needsMyClass == true and v.object.classID == id or categorySettings.classes[v.object.classID] == false) then
				v.object.ClassFrame.Button:SetChecked(false)
					
			else
				v.object.ClassFrame.Button:SetChecked(true)

			end

			v.object.ClassFrame.Button:SetScript("OnClick", function(self)
				if(v.object.classID == id) then
					categorySettings.needsMyClass = not self:GetChecked()

				else
					categorySettings.classes[v.object.classID] = self:GetChecked()

				end
			end)

			for i = 1, 4, 1 do
				local specFrame = v.object["Spec" .. i]

				if(specFrame) then
					if(categorySettings.specs[specFrame.specID] == false or categoryID == 2 and categorySettings.needsMyClass == true and v.object.classID == id) then
						specFrame.Button:SetChecked(false)
						
					else
						specFrame.Button:SetChecked(true)

					end

					specFrame.Button:SetScript("OnClick", function(self)
						categorySettings.specs[specFrame.specID] = self:GetChecked()

						if(categorySettings.specs[specFrame.specID] and categorySettings.classes[v.object.classID] == false) then
							v.object.ClassFrame.Button:SetChecked(true)

						end
					
					end)
				end
				
			end

		elseif(v.id == "roles" and categoryID ~= 0) then
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

			v.object.tank.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText("Tank")
				GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[v.id], nil, nil, nil, true)
				GameTooltip:Show()
			end)
			v.object.tank.Icon:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			v.object.healer.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText("Healer")
				GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[v.id], nil, nil, nil, true)
				GameTooltip:Show()
			end)
			v.object.healer.Icon:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			v.object.damager.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText("Damager")
				GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[v.id], nil, nil, nil, true)
				GameTooltip:Show()
			end)
			v.object.damager.Icon:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			v.object:Show()

		elseif(categoryID ~= 0 and (v.id == "lustFit" or v.id == "ressFit" or (v.id == "hideHardDecline" or v.id == "partyFit") and panel == "LFGListFrame.SearchPanel")) then
			v.object:Show()
			v.object.Button:SetScript("OnClick", function(self)
				categorySettings[v.id] = self:GetChecked()
			end)
			v.object.Button:SetChecked(categorySettings[v.id])

			v.object.Text:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(v.object.Text:GetText())
				GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[v.id], nil, nil, nil, true)
				GameTooltip:Show()
			end)
			v.object.Text:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			--bossFrame:SetScript("OnLeave", nil)
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
				convertAndRefresh()
			end)
			v.object.Button:SetChecked(categorySettings[v.id].value)

			v.object.Dropdown:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText("Difficulty")
				GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[v.id], nil, nil, nil, true)
				GameTooltip:Show()
			end)
			v.object.Dropdown:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

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

			v.object.Setting.Text:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(v.object.Setting.Text:GetText())
				GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[v.id], nil, nil, nil, true)
				GameTooltip:Show()
			end)
			v.object.Setting.Text:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

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

			v.object.Setting.Text:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(v.object.Setting.Text:GetText())
				GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[v.id], nil, nil, nil, true)
				GameTooltip:Show()
			end)
			v.object.Setting.Text:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			v.object:Show()

		elseif(v.id == "activities") then
			categorySettings.activities = categorySettings.activities or {}

			v.object.Button:SetChecked(categorySettings[v.id].value)
			v.object.Button:SetScript("OnClick", function(self)
				categorySettings[v.id].value = self:GetChecked()
			end)

			v.object.Text:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(v.object.Text:GetText())
				GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[v.id], nil, nil, nil, true)
				GameTooltip:Show()
			end)
			v.object.Text:SetScript("OnLeave", function()
				GameTooltip:Hide()
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

			if(panel == "LFGListFrame.SearchPanel" and (categoryID == 2 or categoryID == 3) or panel == "DropChecker") then
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
							frame:Hide()

						end

						frame.Text:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)

					end

					v.object:Show()
					miog.NewFilterPanel:MarkDirty()
					
				elseif(categoryID == 3 and LFGListFrame.SearchPanel.filters == 1) then
					local seasonGroups = C_LFGList.GetAvailableActivityGroups(3, Enum.LFGListFilter.Recommended);
					local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, 5)
		
					local sortedExpansionRaids = {}
		
					if(seasonGroups and #seasonGroups > 0) then
						for _, v in ipairs(seasonGroups) do
							local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
							miog.checkSingleMapIDForNewData(activityInfo.mapID, false, true)
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

									bossFrame:SetScript("OnClick", function(self, button)
										if(button == "LeftButton") then
											categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] = categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] == 3 and 1
											or categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] + 1

										else
											categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d] = 1

										end

										convertAndRefresh()
									end)
									bossFrame:SetScript("OnEnter", function(self)
										GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
										GameTooltip:SetText(sortedExpansionRaids[i].bosses[d].name)
										GameTooltip:Show()
									end)
									bossFrame:SetScript("OnLeave", function()
										GameTooltip:Hide()

									end)
									--categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d]

									bossFrame:SetState(categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].bosses[d])
									bossFrame:Show()
								else
									bossFrame:Hide()
									bossFrame:SetScript("OnClick", nil)
									bossFrame:SetScript("OnEnter", nil)

								end
							end

							bossRow:Show()
							bossRow.layoutIndex = 1004 + i

						end
					end

					v.object:Show()
					miog.NewFilterPanel:MarkDirty()

				
				elseif(categoryID == 0) then
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
					
					local overall = 1

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
						
							if(categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value) then
								frame.Button:SetChecked(categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value)
								categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value = categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value ~= false

							else
								frame.Button:SetChecked(true)
								categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value = true

							end

							frame.Button:SetScript("OnClick", function(self)
								categorySettings.activities[sortedSeasonDungeons[i].groupFinderActivityGroupID].value = self:GetChecked()

								convertAndRefresh()
							end)

							overall = overall + 1

						else
							frame.Button:SetChecked(true)
							frame.Text:SetScript("OnEnter", nil)

							frame:Hide()

						end

						frame.Text:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)

					end

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
						sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = activityInfo.groupFinderActivityGroupID, name = "World"}
		
					end
		
					table.sort(sortedExpansionRaids, function(k1, k2)
						return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID

					end)

					for i = 1, 16, 1 do
						local row = overall < 5 and 1 or overall < 9 and 2 or overall < 13 and 3 or 4
						local column = overall - ((row - 1) * 4)

						local activityRow = miog.NewFilterPanel["ActivityRow" .. row]
						local frame = activityRow["Activity" .. column]

						if(sortedExpansionRaids[i]) then
							categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID] = categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID] or {}

							frame.Text:SetText(sortedExpansionRaids[i].name)
							frame.Text:SetScript("OnEnter", function(self)
								GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
								GameTooltip:SetText(C_LFGList.GetActivityGroupInfo(sortedExpansionRaids[i].groupFinderActivityGroupID) or sortedExpansionRaids[i].name or "")
								GameTooltip:Show()
							end)
							frame:Show()

							activityRow.layoutIndex = 1000 + row
							activityRow:Show()
						
							if(categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value) then
								frame.Button:SetChecked(categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value)
								categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value = categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value ~= false

							else
								frame.Button:SetChecked(true)
								categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value = true

							end

							frame.Button:SetScript("OnClick", function(self)
								categorySettings.activities[sortedExpansionRaids[i].groupFinderActivityGroupID].value = self:GetChecked()

								convertAndRefresh()
							end)

							overall = overall + 1

						else
							frame.Button:SetChecked(true)
							frame.Text:SetScript("OnEnter", nil)

							frame:Hide()

						end

						frame.Text:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)
					end

					v.object:Show()
					miog.NewFilterPanel:MarkDirty()
					
				else
					v.object:Hide()
					miog.NewFilterPanel:MarkDirty()

				end
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