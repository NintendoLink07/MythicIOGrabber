local addonName, miog = ...

miog.filter = {}

local spinnerCategories = {
	"Tank",
	"Healer",
	"Damager",
}

local inputCategories = {
	"Age",
	"Rating"
}

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


local function HasRemainingSlotsForLocalPlayerRole(resultID) -- LFGList.lua local function HasRemainingSlotsForLocalPlayerRole(lfgresultID)
	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)

	local roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
	}

	if roles then
		local numOfMembers = GetNumGroupMembers()
		if(numOfMembers > 0) then
			for groupIndex = 1, numOfMembers, 1 do
				local _, _, _, _, _, _, _, _, _, _, _, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

				if combatRole then
					local remainingRoleKey = miog.roleRemainingKeyLookup[combatRole]
					if remainingRoleKey then
						if roles[remainingRoleKey] == roleCount[combatRole] then
							return false

						else
							roleCount[combatRole] = roleCount[combatRole] + 1

						end
					end
				end
			end

			return true
		else
			local playerRole = GetSpecializationRole(GetSpecialization())
			if playerRole then
				local remainingRoleKey = miog.roleRemainingKeyLookup[playerRole]
				if remainingRoleKey then
					return (roles[remainingRoleKey] or 0) > 0

				end
			end
		end
	end

	return false
end

local function HasRemainingSlotsForBattleResurrection(resultID, playerSpaceLeft)
	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)

	for fileName, v in pairs(roles) do
		if((fileName == "PALADIN" or fileName == "DEATHKNIGHT" or fileName == "WARLOCK" or fileName == "DRUID") and v > 0) then
			return true

		end
	end

	local numOfMembers = GetNumGroupMembers()
	if(numOfMembers > 0) then
		playerSpaceLeft = playerSpaceLeft - numOfMembers

		for groupIndex = 1, numOfMembers, 1 do
			local _, _, _, _, _, fileName = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

			if((fileName == "PALADIN" or fileName == "DEATHKNIGHT" or fileName == "WARLOCK" or fileName == "DRUID")) then
				return playerSpaceLeft > -1

			end
		end

		return playerSpaceLeft > 0

	else
		playerSpaceLeft = playerSpaceLeft - 1

		if(id == 2 or id == 6 or id == 9 or id == 11) then
			return playerSpaceLeft > -1

		else
			return playerSpaceLeft > 0

		end
	end

	return false
end

local function HasRemainingSlotsForBloodlust(resultID, playerSpaceLeft)
	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)

	for fileName, v in pairs(roles) do
		if((fileName == "HUNTER" or fileName == "SHAMAN" or fileName == "MAGE" or fileName == "EVOKER") and v > 0) then
			return true

		end
	end

	local numOfMembers = GetNumGroupMembers()
	if(numOfMembers > 0) then
		playerSpaceLeft = playerSpaceLeft - numOfMembers

		for groupIndex = 1, numOfMembers, 1 do
			local _, _, _, _, _, fileName = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

			if((fileName == "HUNTER" or fileName == "SHAMAN" or fileName == "MAGE" or fileName == "EVOKER")) then
				return playerSpaceLeft > -1

			end
		end

		return playerSpaceLeft > 0
	else
		playerSpaceLeft = playerSpaceLeft - 1

		if(id == 3 or id == 7 or id == 8 or id == 13) then
			return playerSpaceLeft > -1

		else
			return playerSpaceLeft > 0
		end
	end

	return false
end

local function checkIfPlayersFitIntoGroup(maxNumPlayers, listingPlayers)
	local groupMembers = GetNumGroupMembers()

	if((listingPlayers + groupMembers) > maxNumPlayers) then
		return false

	end

	return true
end

local function checkIfApplicantIsEligible(applicantData)
	if(currentSettings) then
		local settings = currentSettings
		local categoryID = getCurrentCategoryID("ApplicationViewer")

		local isPvp = categoryID == 4 or categoryID == 7
		local isDungeon = categoryID == 2

		local hasRess, hasLust = false, false

		if(settings.ressfit or settings.lustfit) then
			local numGroupMembers = GetNumGroupMembers()

			for groupIndex = 1, numGroupMembers, 1 do
                local _, _, _, _, _, fileName = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

				--classCount[fileName] = classCount[fileName] + 1

				if(not hasRess and fileName == "PALADIN" or fileName == "DEATHKNIGHT" or fileName == "WARLOCK" or fileName == "DRUID") then
					hasRess = true
					
				end

				if(not hasLust and fileName == "HUNTER" or fileName == "SHAMAN" or fileName == "MAGE" or fileName == "EVOKER") then
					hasLust = true
					
				end
			end
		end


		if(settings.ressfit and not hasRess) then
			return false, "ressFit"
	
		end

		if(settings.lustfit and not hasLust) then
			return false, "lustFit"
	
		end

		--[[if(settings.roles[applicantData.role] == false) then
			return false, "incorrectRoles"
	
		end]]
	
		if(settings.classes[miog.CLASSFILE_TO_ID[applicantData.class]] == false) then
			return false, "classFiltered"
		
		end

		if(settings.specs[applicantData.specID] == false) then
			return false, "specFiltered"

		end

		if(isDungeon or isPvp) then
			if(settings.rating.enabled) then
				local min = settings.rating.minimum
				local max = settings.rating.maximum

				local applicantRating = applicantData.rating

				if min ~= 0 and max ~= 0 then
					if applicantRating < min or applicantRating > max then
						return false, "ratingMismatch"
					end
				elseif min ~= 0 then
					if applicantRating < min then
						return false, "ratingLowerMismatch"
					end
				elseif max ~= 0 then
					if applicantRating >= max then
						return false, "ratingHigherMismatch"
					end
				end
			end
		end
		
		return true, "allGood"
	end

	return true, "noSettingsFound"
end

miog.filter.checkIfApplicantIsEligible = checkIfApplicantIsEligible

local function checkIfSearchResultIsEligible(resultID, isActiveQueue)
	if(currentSettings) then
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
		
		local hasSlotsForPlayers = HasRemainingSlotsForLocalPlayerRole(searchResultInfo.searchResultID)

		if(settings.partyfit) then
			if(not hasSlotsForPlayers) then
				return false, "partyFit"

			else
				if(not checkIfPlayersFitIntoGroup(activityInfo.maxNumPlayers, searchResultInfo.numMembers)) then
					return false, "exceededMaxPlayers"

				end
			end
		end
		
		local spaceLeft = activityInfo.maxNumPlayers - searchResultInfo.numMembers
	
		if(settings.ressfit and not HasRemainingSlotsForBattleResurrection(searchResultInfo.searchResultID, spaceLeft)) then
			return false, "ressFit"
	
		end
	
		if(settings.lustfit and not HasRemainingSlotsForBloodlust(searchResultInfo.searchResultID, spaceLeft)) then
			return false, "lustFit"
	
		end
			
		if(settings.decline and MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID] and MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID].activeDecline) then
			return false, "hardDeclined"
			
		end
				
		if(settings.age.enabled) then
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

		local rating = isPvp and (searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0) or searchResultInfo.leaderOverallDungeonScore or 0

		if(isDungeon or isPvp) then
			if(settings.rating.enabled) then
				local min = settings.rating.minimum
				local max = settings.rating.maximum

				if min ~= 0 and max ~= 0 then
					if rating < min or rating > max then
						return false, "ratingMismatch"
					end
				elseif min ~= 0 then
					if rating < min then
						return false, "ratingLowerMismatch"
					end
				elseif max ~= 0 then
					if rating >= max then
						return false, "ratingHigherMismatch"
					end
				end
			end
		end

		local tanksOk = not settings.tank.enabled or roleCount["TANK"] >= settings.tank.minimum and roleCount["TANK"] <= settings.tank.maximum
		local healersOk = not settings.healer.enabled or roleCount["HEALER"] >= settings.healer.minimum and roleCount["HEALER"] <= settings.healer.maximum
		local damagerOk = not settings.damager.enabled or roleCount["DAMAGER"] >= settings.damager.minimum and roleCount["DAMAGER"] <= settings.damager.maximum

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

		if(settings.difficulty.enabled) then
			if(isDungeon or isRaid) then
				if(activityInfo and activityInfo.difficultyID ~= settings.difficulty.id) then
					return false, "incorrectDifficulty"

				end
			elseif(isPvp) then
				if(searchResultInfo.activityIDs[1] ~= settings.difficulty.id) then
					return false, "incorrectBracket"

				end
			end
		end

		if(settings.activities.enabled and (isRaid or isDungeon) and settings.activities[activityInfo.groupFinderActivityGroupID] == false) then
			if(isDungeon) then
				return false, "dungeonMismatch"

			elseif(isRaid and LFGListFrame.SearchPanel.filters == 1) then
				return false, "raidMismatch"

			end
		end
			
		if(isActiveQueue and LFGListFrame.SearchPanel.categoryID and activityInfo.categoryID ~= LFGListFrame.SearchPanel.categoryID) then
			return false, "incorrectCategory"

		end
		
		return true, "allGood"
	end

	return true, "noSettingsFound"
end

miog.filter.checkIfSearchResultIsEligible = checkIfSearchResultIsEligible


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

local function refreshInputFilters(specificFilter)
	local filterManager = miog.FilterManager

	for _, inputString in ipairs(specificFilter and {specificFilter} or inputCategories) do
		local filterObject = filterManager[inputString]
		local nameLower = strlower(inputString)

		local filterSetting = retrieveSetting(nameLower)
		filterObject.Minimum:SetNumber(filterSetting.minimum or 0)
		filterObject.Maximum:SetNumber(filterSetting.maximum or 0)
		filterObject.CheckButton:SetChecked(filterSetting.enabled)
	end

end

local function refreshSpinnerFilters()
	local filterManager = miog.FilterManager

	for _, spinnerString in ipairs(spinnerCategories) do
		local filterObject = filterManager[spinnerString]
		local nameLower = strlower(spinnerString)

		local filterSetting = retrieveSetting(nameLower)
		filterObject.Minimum:SetValue(filterSetting.minimum or 0)
		filterObject.Maximum:SetValue(filterSetting.maximum or 0)
		filterObject.Link:SetChecked(filterSetting.linked)
		filterObject.CheckButton:SetChecked(filterSetting.enabled)
	end
end

local function sortActivityGroup(k1, k2)
	local ga1, ga2 = miog.requestGroupInfo(k1), miog.requestGroupInfo(k2)

	if(ga1 and ga2) then
		--local fn1, fn2 = C_LFGList.GetActivityInfoTable(ga1.activityID).fullName, C_LFGList.GetActivityInfoTable(ga2.activityID).fullName

		return ga1.abbreviatedName < ga2.abbreviatedName

	elseif(ga1) then
		return true

	else
		return false

	end
end

local function refreshFilters()
	local filterManager = miog.FilterManager
	local panel, categoryID = getCurrentPanelAndCategoryID()

	for classIndex, classInfo in ipairs(miog.CLASSES) do
		local singleClassFilter = filterManager.ClassFilters["Class" .. classIndex]

		local classSetting = retrieveSetting("classes", classIndex)
		singleClassFilter.ClassFrame.CheckButton:SetChecked(classSetting == nil and true or classSetting)

		for i = 1, #classInfo.specs, 1 do
			local specID = classInfo.specs[i]
			local specFrame = singleClassFilter["Spec" .. i]

			if(specFrame) then
				local specSetting = retrieveSetting("specs", specID)
				specFrame.CheckButton:SetChecked(specSetting == nil and true or specSetting)
				specFrame.CheckButton:SetEnabled(classSetting == nil and true or classSetting)

			end
		end
	end

	local lustFit = retrieveSetting("lustfit")
	filterManager.LustFit.CheckButton:SetChecked(lustFit == nil and false or lustFit)

	local ressSetting = retrieveSetting("ressfit")
	filterManager.RessFit.CheckButton:SetChecked(ressSetting == nil and false or ressSetting)
	
	local isLFG = panel == "SearchPanel"

	filterManager.PartyFit:SetShown(isLFG)
	filterManager.Decline:SetShown(isLFG)
	filterManager.Spacer:SetShown(isLFG)
	filterManager.Tank:SetShown(isLFG)
	filterManager.Healer:SetShown(isLFG)
	filterManager.Damager:SetShown(isLFG)
	filterManager.Age:SetShown(isLFG)
	filterManager.Difficulty:SetShown(isLFG)
	filterManager.Activities:SetShown(isLFG)
	filterManager.ActivityGrid:SetShown(isLFG)

	if(isLFG) then
		local partySetting = retrieveSetting("partyfit")
		filterManager.PartyFit.CheckButton:SetChecked(partySetting == nil and false or partySetting)

		local decline = retrieveSetting("decline")
		filterManager.Decline.CheckButton:SetChecked(decline == nil and false or decline)
		
		refreshInputFilters()
		refreshSpinnerFilters()

		local difficultySetting = retrieveSetting("difficulty", "enabled")
		filterManager.Difficulty.CheckButton:SetChecked(difficultySetting == nil and false or difficultySetting)

		local activitiesSetting = retrieveSetting("activities", "enabled")
		filterManager.Activities.CheckButton:SetChecked(activitiesSetting == nil and false or activitiesSetting)

		local allGroups = {}
		local seasonGroups = C_LFGList.GetAvailableActivityGroups(categoryID, Enum.LFGListFilter.CurrentSeason)
		local otherGroups = C_LFGList.GetAvailableActivityGroups(categoryID, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason))

		table.sort(seasonGroups, sortActivityGroup)
		table.sort(otherGroups, sortActivityGroup)

		for i = 1, 2, 1 do
			local currentGroups = i == 1 and seasonGroups or otherGroups

			for k, groupID in ipairs(currentGroups) do
				tinsert(allGroups, {groupID = groupID})

			end
		end

		if(categoryID == 3) then
			local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, 5)

			if(worldBossActivity and #worldBossActivity > 0) then
				local activityInfo = C_LFGList.GetActivityInfoTable(worldBossActivity[1])
				
				tinsert(allGroups, {groupID = activityInfo.groupFinderActivityGroupID, mapID = activityInfo.mapID})

			end
		end

		for rowCounter = 1, 4, 1 do
			for activityCounter = 1, 4, 1 do
				local counter = (rowCounter - 1) * 4 + activityCounter
				local groupData = allGroups[counter]
				local activityFilter = filterManager.ActivityGrid["Activity" .. counter]

				if(groupData and groupData.groupID) then
					local info

					if(groupData.groupID > 0) then
						info = miog.requestGroupInfo(groupData.groupID)
						activityFilter.mapID = nil
						activityFilter.groupID = groupData.groupID

					else
						info = miog.getMapInfo(groupData.mapID)
						activityFilter.groupID = nil
						activityFilter.mapID = groupData.mapID

					end

					--activityFilter.Icon:SetTexture(groupInfo.icon)
					activityFilter.Text:SetText(info.abbreviatedName or info.shortName)
					
					local groupSetting = retrieveSetting("activities", groupData.groupID)
					activityFilter.CheckButton:SetChecked(groupSetting == nil and true or groupSetting)
					activityFilter:Show()

				else
					activityFilter:Hide()

				end
			end
		end
	else
		refreshInputFilters("Rating")

	end

	currentSettings = MIOG_CharacterSettings.filters[panel][categoryID]

	filterManager:MarkDirty()
end

miog.filter.refreshFilters = refreshFilters

local function createFilterWithText(filter, text)
	local nameLower = strlower(filter:GetParentKey())

	filter.Text:SetText(text)
	filter.Text:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(text)
		GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[nameLower], nil, nil, nil, true)
		GameTooltip:Show()
	end)
	filter.CheckButton:SetScript("OnClick", function(self)
		changeSetting(self:GetChecked(), nameLower)
	end)
end

local function loadFilterManager()
	local filterManager = CreateFrame("Frame", "FilterManager", miog.Plugin, "MIOG_FilterManager")
	filterManager:SetPoint("TOPLEFT", miog.NewFilterPanel, "TOPRIGHT", 5, 0)

	miog.createFrameBorder(filterManager, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	filterManager.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_NewSettings.backgroundOptions][2] .. "_small.png")
	
	filterManager:Show()
	
	for categoryIndex, categoryID in pairs(miog.CUSTOM_CATEGORY_ORDER) do
		for index, panel in pairs(panels) do
			initializeSetting(panel, categoryID, "classes")
			initializeSetting(panel, categoryID, "specs")
			initializeSetting(panel, categoryID, "age")

			initializeSetting(panel, categoryID, "rating")
			initializeSetting(panel, categoryID, "tank")
			initializeSetting(panel, categoryID, "healer")
			initializeSetting(panel, categoryID, "damager")
			initializeSetting(panel, categoryID, "difficulty")
			initializeSetting(panel, categoryID, "activities")

		end
	end

	for classIndex, classInfo in ipairs(miog.CLASSES) do
		local r, g, b = GetClassColor(classInfo.name)

		local singleClassFilter = filterManager.ClassFilters["Class" .. classIndex]
		singleClassFilter:SetSize(200 + 5, 20)
		singleClassFilter.Border:SetColorTexture(r, g, b, 0.25)
		singleClassFilter.Background:SetColorTexture(r, g, b, 0.5)
		singleClassFilter.ClassFrame.Icon:SetTexture(classInfo.roundIcon)
		singleClassFilter.ClassFrame.CheckButton:SetScript("OnClick", function(self)
			changeSetting(self:GetChecked(), "classes", classIndex)

			if(classIndex == id) then
				changeSetting(self:GetChecked(), "needsMyClass")

			end
			
			for i = 1, #classInfo.specs, 1 do
				local specID = classInfo.specs[i]
				changeSetting(self:GetChecked(), "specs", specID)

				local specFrame = singleClassFilter["Spec" .. i]

				if(specFrame) then
					specFrame.CheckButton:SetChecked(self:GetChecked())
					specFrame.CheckButton:SetEnabled(self:GetChecked())
				end
			end
		end)

		for i = 1, #classInfo.specs, 1 do
			local specID = classInfo.specs[i]
			local specInfo = miog.SPECIALIZATIONS[specID]
			local specFrame = singleClassFilter["Spec" .. i]

			if(specFrame) then
				specFrame.Icon:SetTexture(specInfo.icon)
				specFrame.CheckButton:SetScript("OnClick", function(self)
					changeSetting(self:GetChecked(), "specs", specID)
				end)

			end
		end
	end

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
					end, y)
				end
			end
		end
	end)

	filterManager.Difficulty.CheckButton:SetScript("OnClick", function(self)
		changeSetting(self:GetChecked(), "difficulty", "enabled")
		setStatus("change")
	end)

	-- Determine highest width spinner
    local maxWidth = 0
    local widestString = nil

	for _, spinnerString in ipairs(spinnerCategories) do
		local spinner = filterManager[spinnerString]
		
		spinner.Text:SetText(spinnerString)
        local width = spinner.Text:GetStringWidth()

        if width > maxWidth then
            maxWidth = width
            widestString = spinnerString
        end
	end

	for k, spinnerString in ipairs(spinnerCategories) do
		local spinner = filterManager[spinnerString]
		local nameLower = strlower(spinnerString)

		if(widestString ~= spinnerString) then
			spinner.Link:AdjustPointsOffset(maxWidth - spinner.Text:GetStringWidth(), 0)
		end

		spinner.Text:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(spinnerString)
			GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[nameLower], nil, nil, nil, true)
			GameTooltip:Show()
		end)

		spinner.CheckButton:SetScript("OnClick", function(self)
			local inputSettings = retrieveSetting(nameLower)

			if(not inputSettings.minimum) then
				changeSetting(0, nameLower, "minimum")
				
			end

			if(not inputSettings.maximum) then
				changeSetting(0, nameLower, "maximum")
				
			end

			changeSetting(self:GetChecked(), nameLower, "enabled")
			setStatus("change")
		end)

		spinner.Link:SetScript("OnClick", function(self)
			changeSetting(self:GetChecked(), nameLower, "linked")

		end)

		spinner.Minimum:SetScript("OnTextChanged", function(self, manual)
			if(manual) then
				local spinnerValue = self:GetNumber()
				local before = retrieveSetting(nameLower, "minimum")

				if(spinnerValue) then
					changeSetting(spinnerValue, nameLower, "minimum")

					local maximum = retrieveSetting(nameLower, "maximum")

					if(maximum < spinnerValue) then
						spinner.Maximum:SetValue(spinnerValue)
						changeSetting(spinnerValue, nameLower, "maximum")

					end
					
					if(spinnerString ~= "Damager" and before == 0 and spinnerValue > 0) then
						setStatus("change")

					end
				end
			end
		end)
		spinner.Minimum:SetMinMaxValues(0, 40)
		
		spinner.Maximum:SetScript("OnTextChanged", function(self, manual)
			if(manual) then
				local spinnerValue = self:GetNumber()

				if(spinnerValue) then
					changeSetting(spinnerValue, nameLower, "maximum")

					local minimum = retrieveSetting(nameLower, "minimum")

					if(minimum > spinnerValue) then
						spinner.Minimum:SetValue(spinnerValue)
						changeSetting(spinnerValue, nameLower, "minimum")

					end
				end
			end
		end)
		spinner.Maximum:SetMinMaxValues(0, 40)

		spinner.Minimum.DecrementButton:SetScript("OnMouseDown", function(self)
			local parentSpinner = self:GetParent()
			parentSpinner:Decrement()

			local spinnerValue = parentSpinner:GetValue()
			local before = retrieveSetting(nameLower, "minimum")

			parentSpinner:ClearFocus()
			changeSetting(spinnerValue, nameLower, "minimum")
					
			if(spinnerString ~= "Damager" and before > 0 and spinnerValue == 0) then
				setStatus("change")

			end
		end)

		spinner.Minimum.IncrementButton:SetScript("OnMouseDown", function(self)
			local parentSpinner = self:GetParent()
			parentSpinner:Increment()

			local spinnerValue = parentSpinner:GetValue()
			local before = retrieveSetting(nameLower, "minimum")

			local maximum = retrieveSetting(nameLower, "maximum")
			
			if(not maximum or maximum < spinnerValue) then
				spinner.Maximum:SetValue(spinnerValue)
				changeSetting(spinnerValue, nameLower, "maximum")

			end
					
			if(spinnerString ~= "Damager" and before == 0 and spinnerValue > 0) then
				setStatus("change")

			end

			parentSpinner:ClearFocus()
			changeSetting(spinnerValue, nameLower, "minimum")
		end)

		spinner.Maximum.DecrementButton:SetScript("OnMouseDown", function(self)
			local parentSpinner = self:GetParent()
			parentSpinner:Decrement()

			local spinnerValue = parentSpinner:GetValue()

			local minimum = retrieveSetting(nameLower, "minimum")

			if(not minimum or minimum > spinnerValue) then
				spinner.Minimum:SetValue(spinnerValue)
				changeSetting(spinnerValue, nameLower, "minimum")

			end

			parentSpinner:ClearFocus()
			changeSetting(spinnerValue, nameLower, "maximum")
		end)

		spinner.Maximum.IncrementButton:SetScript("OnMouseDown", function(self)
			local parentSpinner = self:GetParent()
			parentSpinner:Increment()

			local spinnerValue = parentSpinner:GetValue()

			parentSpinner:ClearFocus()
			changeSetting(spinnerValue, nameLower, "maximum")
		end)
	end

	for _, inputString in ipairs(inputCategories) do
		local inputFilter = filterManager[inputString]
		local nameLower = strlower(inputString)

		inputFilter.Text:SetText(inputString)
		inputFilter.Minimum:SetScript("OnTextChanged", function(self, manual)
			if(manual) then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				
				local number = tonumber(self:GetText())

				changeSetting(number, nameLower, "minimum")

				if(inputString == "Rating") then
					setStatus("change")

				end
			end
		end)

		inputFilter.CheckButton:SetScript("OnClick", function(self)
			local inputSettings = retrieveSetting(nameLower)

			if(not inputSettings.minimum) then
				changeSetting(0, nameLower, "minimum")
				
			end

			if(not inputSettings.maximum) then
				changeSetting(0, nameLower, "maximum")
				
			end

			changeSetting(self:GetChecked(), nameLower, "enabled")

			if(inputString == "Rating") then
				setStatus("change")

			end

		end)
			
		inputFilter.Text:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(inputString)
			GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS[nameLower], nil, nil, nil, true)
			GameTooltip:Show()
		end)

		inputFilter.Maximum:SetScript("OnTextChanged", function(self, manual)
			if(manual) then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				
				local number = tonumber(self:GetText())

				changeSetting(number, nameLower, "maximum")
			end
		end)
	end

	filterManager.Difficulty.Text:SetText("Difficulty")
	filterManager.Difficulty.Text:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Difficulty")
		GameTooltip:AddLine(miog.FILTER_DESCRIPTIONS["difficulty"], nil, nil, nil, true)
		GameTooltip:Show()
	end)

	createFilterWithText(filterManager.PartyFit, "Party fit")
	createFilterWithText(filterManager.RessFit, "Ress fit")
	createFilterWithText(filterManager.LustFit, "Lust fit")
	createFilterWithText(filterManager.Decline, "Hide declines")
	createFilterWithText(filterManager.Activities, "Activities")

	filterManager.Activities.CheckButton:SetScript("OnClick", function(self)
		changeSetting(self:GetChecked(), "activities", "enabled")

	end)

	for i = 1, 16, 1 do
		local activityFilter = filterManager.ActivityGrid["Activity" .. i]
			
		activityFilter.Text:SetScript("OnEnter", function(self)
			local groupID = self:GetParent().groupID

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

			if(groupID) then
				GameTooltip:SetText(C_LFGList.GetActivityGroupInfo(groupID) or "")

			elseif(self:GetParent().mapID) then
				GameTooltip:SetText(miog.getMapInfo(self:GetParent().mapID).name)

			end

			GameTooltip:Show()
		end)
		activityFilter.CheckButton:SetScript("OnClick", function(self)
			local groupID = self:GetParent().groupID

			if(groupID) then
				changeSetting(self:GetChecked(), "activities", groupID)
				setStatus("change")

			end
		end)
	end

	miog.createFrameBorder(filterManager.ProgressPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	miog.ProgressPanel = filterManager.ProgressPanel

	filterManager:MarkDirty()

	return filterManager
end

hooksecurefunc("LFGListSearchPanel_DoSearch", function()
	setStatus("refreshed")
end)

miog.loadFilterManager = loadFilterManager