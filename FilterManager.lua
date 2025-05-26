local addonName, miog = ...

miog.filter = {}

local currentSettings
local _, id = UnitClassBase("player")

local panels = {
	"SearchPanel",
	"ApplicationViewer"
}

local function getCurrentPanel()
	if(miog.SearchPanel:IsShown()) then
		return "SearchPanel"
		
	elseif(miog.ApplicationViewer:IsShown()) then
		return "ApplicationViewer"
		
	end
end

local function getCurrentCategoryID(panel)
	panel = panel or getCurrentPanel()

	if(panel == "SearchPanel") then
		return LFGListFrame.SearchPanel.categoryID or
		LFGListFrame.CategorySelection.selectedCategory

	elseif(panel == "ApplicationViewer") then
		return C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityIDs[1]).categoryID or
		LFGListFrame.CategorySelection.selectedCategory

	end
end

local function getCurrentPanelAndCategoryID()
	local panel = getCurrentPanel()
	local categoryID = getCurrentCategoryID(panel)

	return panel, categoryID
end

local function checkIfSearchResultIsEligible(resultID)
	local roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
		["NONE"] = 0
	}

	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
	local settings = currentSettings
	local categoryID = getCurrentCategoryID("SearchPanel")
	local isPvp = categoryID == 4 or categoryID == 7
	local isDungeon = categoryID == 2
	local isRaid = categoryID == 3
	local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])

	for i = 1, searchResultInfo.numMembers, 1 do
		local info = C_LFGList.GetSearchResultPlayerInfo(resultID, i);

		if(info.assignedRole) then
			roleCount[info.assignedRole] = roleCount[info.assignedRole] + 1

		end

		if(settings.needsMyClass == true and miog.CLASSFILE_TO_ID[info.classFilename] == id or settings.classes[miog.CLASSFILE_TO_ID[info.classFilename]] == false) then
			return false, "classFiltered"

		end

		if(info.specName and info.classFilename and settings.specs[miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[info.specName .. "-" .. info.classFilename]] == false) then
			return false, "specFiltered"

		end
	end

	if(settings.difficulty.value) then
		if(isDungeon or isRaid) then
			if(activityInfo and activityInfo.difficultyID ~= settings.difficulty.id
			)then
				return false, "incorrectDifficulty"

			end
		elseif(isPvp) then
			if(searchResultInfo.activityIDs[1] ~= settings.difficulty.id) then
				return false, "incorrectBracket"

			end
		end
	end
	
	return true, "allGood"
end

miog.filter.checkIfSearchResultIsEligible = checkIfSearchResultIsEligible

local function checkIfApplicantIsEligible(applicantID)

end

miog.filter.checkIfApplicantIsEligible = checkIfApplicantIsEligible


local function setStatus(type)
	if(type == "change") then
		miog.FilterManager.Status:SetText("Refresh panel")
		miog.FilterManager.Status:SetTextColor(1, 1, 0, 1)

	elseif(type == "refreshed") then
		miog.FilterManager.Status:SetText("All good")
		miog.FilterManager.Status:SetTextColor(0, 1, 0, 1)

	end
end

local function changeSetting(value, ...)
	local panel, categoryID = getCurrentPanelAndCategoryID()

	if(panel and categoryID) then
		local lastSetting = MIOG_CharacterSettings.filters[panel][categoryID]
		local parameterArray = {...}

		for k, v in ipairs(parameterArray) do
			if(k == #parameterArray) then
				lastSetting[v] = value

				if(panel == "SearchPanel") then
					miog.fullyUpdateSearchPanel()

				elseif(panel == "ApplicationViewer") then
					C_LFGList.RefreshApplicants()

				end

				return true
			elseif(lastSetting[v]) then
				lastSetting = lastSetting[v]

			end
		end
	end
end

-- classes index

--[[
	/tinspect MIOG_CharacterSettings
	/run MIOG_CharacterSettings.filters = nil
			lastSetting[v] = value
			setStatus("change")
]]


local function retrieveSetting(...)
	local panel, categoryID = getCurrentPanelAndCategoryID()

	if(panel and categoryID) then
		local lastSetting = MIOG_CharacterSettings.filters[panel][categoryID]
		local parameterArray = {...}

		for k, v in ipairs(parameterArray) do
			if(lastSetting[v] ~= nil) then
				lastSetting = lastSetting[v]

				if(k == #parameterArray) then
					return lastSetting

				end
			else

			end
		end
	end
end

local function initializeSetting(...)
	local lastSetting = MIOG_CharacterSettings.filters
	local parameterArray = {...}

	for k, v in ipairs(parameterArray) do
		if(not lastSetting[v]) then
			lastSetting[v] = {}

		end

		lastSetting = lastSetting[v]
	end
end

local function refreshFilters()
	for classIndex, classInfo in ipairs(miog.CLASSES) do
		local singleClassFilter = miog.FilterManager.ClassFilters["Class" .. classIndex]

		local classSetting = retrieveSetting("classes", classIndex)
		singleClassFilter.ClassFrame.CheckButton:SetChecked(classSetting == nil and true or classSetting)

		for i = 1, #classInfo.specs, 1 do
			local specID = classInfo.specs[i]
			local specFrame = singleClassFilter["Spec" .. i]
			local specSetting = retrieveSetting("specs", specID)
			specFrame.CheckButton:SetChecked(specSetting == nil and true or specSetting)
		end
	end

	local difficultySetting = retrieveSetting("difficulty", "value")
	miog.FilterManager.Difficulty.CheckButton:SetChecked(difficultySetting == nil and true or difficultySetting)

	currentSettings = MIOG_CharacterSettings.filters["SearchPanel"][LFGListFrame.SearchPanel.categoryID or LFGListFrame.CategorySelection.selectedCategory]
end

miog.filter.refreshFilters = refreshFilters

local function loadFilterManager()
	local filterManager = CreateFrame("Frame", "FilterManager", miog.Plugin, "MIOG_FilterManager")
	filterManager:SetPoint("TOPLEFT", miog.NewFilterPanel, "TOPRIGHT", 5, 0)
	filterManager:Show()
	
	for categoryIndex, categoryID in pairs(miog.CUSTOM_CATEGORY_ORDER) do
		for index, panel in pairs(panels) do
			--MIOG_CharacterSettings.filters[panel][categoryID] = MIOG_CharacterSettings.filters[panel][categoryID] or {}
			initializeSetting(panel, categoryID, "classes")
			initializeSetting(panel, categoryID, "specs")
			initializeSetting(panel, categoryID, "difficulty")

		end
	end

	--initializeSetting("classes")
	--initializeSetting("specs")

	for classIndex, classInfo in ipairs(miog.CLASSES) do
		local r, g, b = GetClassColor(classInfo.name)

		local singleClassFilter = filterManager.ClassFilters["Class" .. classIndex]
		singleClassFilter:SetSize(200 + 5, 20)
		singleClassFilter.Border:SetColorTexture(r, g, b, 0.25)
		singleClassFilter.Background:SetColorTexture(r, g, b, 0.5)
		singleClassFilter.ClassFrame.Icon:SetTexture(classInfo.roundIcon)

		--local classSetting = retrieveSetting("classes", classIndex)

		--singleClassFilter.ClassFrame.CheckButton:SetChecked(classSetting == nil and true or classSetting)
		singleClassFilter.ClassFrame.CheckButton:SetScript("OnClick", function(self)
			changeSetting(self:GetChecked(), "classes", classIndex)

			if(classIndex == id) then
				changeSetting(self:GetChecked(), "needsMyClass")

			end
			
			for i = 1, #classInfo.specs, 1 do
				local specID = classInfo.specs[i]
				changeSetting(self:GetChecked(), "specs", specID)

				local specFrame = singleClassFilter["Spec" .. i]
				specFrame.CheckButton:SetChecked(self:GetChecked())
				specFrame.CheckButton:SetEnabled(self:GetChecked())
			end
		end)

		for i = 1, #classInfo.specs, 1 do
			local specID = classInfo.specs[i]
			local specInfo = miog.SPECIALIZATIONS[specID]
			local specFrame = singleClassFilter["Spec" .. i]
			specFrame.Icon:SetTexture(specInfo.icon)
			
			--local specSetting = retrieveSetting("specs", specID)
			--specFrame.CheckButton:SetChecked(specSetting == nil and true or specSetting)
			specFrame.CheckButton:SetScript("OnClick", function(self)
				changeSetting(self:GetChecked(), "specs", specID)
			end)
		end
	end

	filterManager.ClassFilters:MarkDirty()

	filterManager.Difficulty.Dropdown:SetDefaultText("Difficulty")
	filterManager.Difficulty.Dropdown:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Difficulty")
		GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS["difficulty"], nil, nil, nil, true)
		GameTooltip:Show()
	end)
	filterManager.Difficulty.Dropdown:SetupMenu(function(dropdown, rootDescription)
		local categoryID = getCurrentCategoryID("SearchPanel")

		if(categoryID) then
			local selectedDifficultyIndex = MIOG_CharacterSettings.filters["SearchPanel"][categoryID].difficulty.id

			local isPvp = categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9
			local isDungeon = categoryID == 2
			local isRaid = categoryID == 3

			if(isPvp or isDungeon or isRaid) then
				for _, y in ipairs(isRaid and {miog.RAID_DIFFICULTIES[2], miog.RAID_DIFFICULTIES[3], miog.RAID_DIFFICULTIES[4]} or isPvp and {6, 7} or isDungeon and miog.DUNGEON_DIFFICULTIES or {}) do
					local difficultyMenu = rootDescription:CreateRadio(isPvp and (y == 6 and "2v2" or "3v3") or miog.DIFFICULTY_ID_INFO[y].name, function(difficultyIndex) return difficultyIndex == selectedDifficultyIndex end, function(difficultyIndex)
						selectedDifficultyIndex = difficultyIndex
						changeSetting(difficultyIndex, "difficulty", "id")
						setStatus("change")
						--convertAndRefresh()
					end, y)
				end
			end
		end
	end)

	filterManager.Difficulty.CheckButton:SetScript("OnClick", function(self)
		changeSetting(self:GetChecked(), "difficulty", "value")
		setStatus("change")
	end)

	filterManager:MarkDirty()

	return filterManager
end

hooksecurefunc("LFGListSearchPanel_DoSearch", function()
	setStatus("refreshed")
end)

miog.loadFilterManager = loadFilterManager