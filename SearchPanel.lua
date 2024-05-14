local addonName, miog = ...
local wticc = WrapTextInColorCode

local searchResultSystem = {}
searchResultSystem.persistentFrames = {}
searchResultSystem.declinedGroups = {}

local function sortSearchResultList(result1, result2)
	for key, tableElement in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do
		if(type(tableElement) == "table" and tableElement.currentLayer == 1) then
			local firstState = miog.SearchPanel.ButtonPanel.sortByCategoryButtons[key]:GetActiveState()

			for innerKey, innerTableElement in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do

				if(type(innerTableElement) == "table" and innerTableElement.currentLayer == 2) then
					local secondState = miog.SearchPanel.ButtonPanel.sortByCategoryButtons[innerKey]:GetActiveState()

					if(result1.appStatus == "applied" and result2.appStatus ~= "applied") then
						return true

					elseif(result1.appStatus ~= "applied" and result2.appStatus == "applied") then
						return false
			
					elseif(result1.favoured and not result2.favoured) then
						return true
					
					elseif(not result1.favoured and result2.favoured) then
						return false

					else
						if(result1[key] == result2[key]) then
							return secondState == 1 and result1[innerKey] > result2[innerKey] or secondState == 2 and result1[innerKey] < result2[innerKey]

						elseif(result1[key] ~= result2[key]) then
							return firstState == 1 and result1[innerKey] > result2[innerKey] or firstState == 2 and result1[innerKey] < result2[innerKey]

						end
					end
				end
			end
			
			if(result1.appStatus == "applied" and result2.appStatus ~= "applied") then
				return true

			elseif(result1.appStatus ~= "applied" and result2.appStatus == "applied") then
				return false
			
			elseif(result1.favoured and not result2.favoured) then
				return true
			
			elseif(not result1.favoured and result2.favoured) then
				return false
			
			else
				if(result1[key] == result2[key]) then
					return firstState == 1 and result1.resultID > result2.resultID or firstState == 2 and result1.resultID < result2.resultID

				elseif(result1[key] ~= result2[key]) then
					return firstState == 1 and result1[key] > result2[key] or firstState == 2 and result1[key] < result2[key]

				end
			end

		end

	end

	if(result1.appStatus == "applied" and result2.appStatus ~= "applied") then
		return true

	elseif(result1.appStatus ~= "applied" and result2.appStatus == "applied") then
		return false

	elseif(result1.favoured and not result2.favoured) then
		return true
	
	elseif(not result1.favoured and result2.favoured) then
		return false

	else
		return result1.resultID < result2.resultID

	end

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
	local _, _, playerClassID = UnitClass("player")
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

local function isGroupEligible(resultID, bordermode)
	if(C_LFGList.HasSearchResultInfo(resultID)) then

		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
		local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)

		if(LFGListFrame.SearchPanel.categoryID and activityInfo.categoryID ~= LFGListFrame.SearchPanel.categoryID and not bordermode) then
			return false, miog.INELIGIBILITY_REASONS[2]

		end

		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].hardDecline and searchResultInfo.leaderName
		and MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultInfo.activityID .. searchResultInfo.leaderName] and MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultInfo.activityID .. searchResultInfo.leaderName].activeDecline) then
			return false, miog.INELIGIBILITY_REASONS[3]

		end

		local isPvp = activityInfo.categoryID == 4 or activityInfo.categoryID == 7
		local isDungeon = activityInfo.categoryID == 2
		local isRaid = activityInfo.categoryID == 3

		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForDifficulty) then
			if(isDungeon or isRaid) then
				if(miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID ~= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].difficultyID
				)then
					return false, miog.INELIGIBILITY_REASONS[4]

				end
			elseif(isPvp) then
				if(searchResultInfo.activityID ~= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].difficultyID) then
					return false, miog.INELIGIBILITY_REASONS[5]

				end
			
			end
		end

		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].partyFit == true and not HasRemainingSlotsForLocalPlayerRole(resultID)) then
			return false, miog.INELIGIBILITY_REASONS[6]

		end
		
		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].ressFit == true and not HasRemainingSlotsForBattleResurrection(resultID)) then
			return false, miog.INELIGIBILITY_REASONS[7]

		end
		
		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].lustFit == true and not HasRemainingSlotsForBloodlust(resultID)) then
			return false, miog.INELIGIBILITY_REASONS[8]

		end

		local roleCount = {
			["TANK"] = 0,
			["HEALER"] = 0,
			["DAMAGER"] = 0,
			["NONE"] = 0
		}

		for i = 1, searchResultInfo.numMembers, 1 do
			local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i)
			local specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]

			if(specID) then
				roleCount[role or "NONE"] = roleCount[role] + 1

				
				if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForClassSpecs) then
					if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].classSpec.class[miog.CLASSFILE_TO_ID[class]] == false) then
						return false, miog.INELIGIBILITY_REASONS[9]

					end

					if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].classSpec.spec[specID] == false) then
						return false, miog.INELIGIBILITY_REASONS[10]
						
					end
		
				end
			end
		end

		local tanksBanned = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForTanks and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxTanks > 0
		and not (roleCount["TANK"] >= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].minTanks and roleCount["TANK"] <= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxTanks)

		local healersBanned = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForHealers and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxHealers > 0
		and not (roleCount["HEALER"] >= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].minHealers and roleCount["HEALER"] <= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxHealers)

		local damagerBanned = MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForDamager and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxDamager > 0
		and not (roleCount["DAMAGER"] >= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].minDamager and roleCount["DAMAGER"] <= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxDamager)

		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedTanks == true and tanksBanned and
			(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedHealers == true and healersBanned
			or MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedDamager == true and damagerBanned)
	 	) then
			return false, miog.INELIGIBILITY_REASONS[11]

		elseif(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedHealers == true and healersBanned and
			(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedTanks == true and tanksBanned
			or MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedDamager == true and damagerBanned)
	 	) then
			return false, miog.INELIGIBILITY_REASONS[11]

		elseif(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedDamager == true and damagerBanned and
			(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedTanks == true and tanksBanned
			or MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedHealers == true and healersBanned)
	 	) then
			return false, miog.INELIGIBILITY_REASONS[11]

		elseif(tanksBanned and not MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedTanks
		or healersBanned and not MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedHealers
		or damagerBanned and not MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].linkedDamager) then
			return false, miog.INELIGIBILITY_REASONS[11]

		end

		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForRoles["TANK"] == false and roleCount["TANK"] > 0
		or MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForRoles["HEALER"] == false and roleCount["HEALER"] > 0
		or MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForRoles["DAMAGER"] == false and roleCount["DAMAGER"] > 0) then
			return false, miog.INELIGIBILITY_REASONS[12]

		end

		local score = isPvp and (searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0) or searchResultInfo.leaderOverallDungeonScore or 0

		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForScore) then
			if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].minScore ~= 0 and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxScore ~= 0) then
				if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxScore >= 0
				and not (score >= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].minScore
				and score <= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxScore)) then
					return false, miog.INELIGIBILITY_REASONS[13]

				end
			elseif(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].minScore ~= 0) then
				if(score < MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].minScore) then
					return false, miog.INELIGIBILITY_REASONS[14]

				end
			elseif(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxScore ~= 0) then
				if(score >= MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].maxScore) then
					return false, miog.INELIGIBILITY_REASONS[15]
					
				end

			end
		
		end
		
		if(isDungeon and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForDungeons) then
			if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].dungeons[activityInfo.groupFinderActivityGroupID] == false) then
				return false, miog.INELIGIBILITY_REASONS[16]

			end

		end
		
		if(isRaid and MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].filterForRaids) then
			if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.SearchPanel"][activityInfo.categoryID].raids[activityInfo.groupFinderActivityGroupID] == false) then
				return false, miog.INELIGIBILITY_REASONS[17]

			end

		end

		return true

	else
		return false, miog.INELIGIBILITY_REASONS[1]

	end
end

miog.isGroupEligible = isGroupEligible

local function setResultFrameColors(resultID)
	local resultFrame = searchResultSystem.persistentFrames[resultID]

	local isEligible = isGroupEligible(resultID, true)
	local _, appStatus = C_LFGList.GetApplicationInfo(resultID)

	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
		
	if(appStatus == "applied") then
		if(isEligible) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.green):GetRGBA())

		else
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
		
		end

		resultFrame.Background:SetColorTexture(CreateColorFromHexString("FF28644B"):GetRGBA())

	elseif(searchResultInfo and searchResultInfo.leaderName and C_FriendList.IsIgnored(searchResultInfo.leaderName)) then
		resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
		resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	elseif(resultID == LFGListFrame.SearchPanel.selectedResult) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())
			resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	elseif(MIOG_SavedSettings.favouredApplicants.table[searchResultInfo.leaderName]) then
		if(isEligible) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString("FFe1ad21"):GetRGBA())

		else
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.orange):GetRGBA())

		end

		resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	else
		if(isEligible) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

		else
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.orange):GetRGBA())

		end

		resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
	
	end
end

--[[local function updateResultFrameStatus(resultID, newStatus, oldStatus)
	local resultFrame = searchResultSystem.persistentFrames[resultID]

	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

	local id, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(resultID)

	local hasActualAppStatus = appStatus and appStatus ~= "none"
	local isNormalDelist = oldStatus == nil and newStatus == nil and searchResultInfo.isDelisted

	local actualStatus = hasActualAppStatus and appStatus or isNormalDelist and "declined_delisted" or newStatus

	if(resultFrame) then
		resultFrame.StatusFrame:Hide()

		if(actualStatus == "applied" or actualStatus == "none") then

			if(resultFrame.BasicInformation.Age.ageTicker) then
				resultFrame.BasicInformation.Age.ageTicker:Cancel()
	
			end

			resultFrame.CancelApplication:Show()

			local ageNumber = appDuration or 0
			resultFrame.BasicInformation.Age:SetText("[" .. miog.secondsToClock(ageNumber) .. "]")
			resultFrame.BasicInformation.Age:SetTextColor(CreateColorFromHexString(miog.CLRSCC.purple):GetRGBA())

			resultFrame.BasicInformation.Age.ageTicker = C_Timer.NewTicker(1, function()
				ageNumber = ageNumber - 1
				resultFrame.BasicInformation.Age:SetText("[" .. miog.secondsToClock(ageNumber) .. "]")

			end)

			resultFrame.layoutIndex = -1

			miog.SearchPanel.FramePanel.Container:MarkDirty()

		else
			resultFrame.CancelApplication:Hide()

			if(actualStatus) then
				if(resultFrame.BasicInformation.Age.ageTicker) then
					resultFrame.BasicInformation.Age.ageTicker:Cancel()

				end

				resultFrame.StatusFrame:Show()
				resultFrame.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[actualStatus].statusString, miog.APPLICANT_STATUS_INFO[actualStatus].color))

				if(searchResultInfo.leaderName and actualStatus ~= "declined_full") then
					MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultInfo.activityID .. searchResultInfo.leaderName] = {timestamp = time(), activeDecline = actualStatus == "declined"}

				end
			end
		end

		setResultFrameColors(resultID)
	end
end
]]

local function updateSearchResultFrameApplicationStatus(resultID, new, old)
	local resultFrame = searchResultSystem.persistentFrames[resultID]
	local id, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(resultID)

	appStatus = new or appStatus

	if(resultFrame and appStatus and appStatus ~= "none") then
		if(appStatus == "applied") then
			if(resultFrame.BasicInformation.Age.ageTicker) then
				resultFrame.BasicInformation.Age.ageTicker:Cancel()

			end

			resultFrame.CancelApplication:Show()

			local ageNumber = appDuration or 0
			resultFrame.BasicInformation.Age:SetText("[" .. miog.secondsToClock(ageNumber) .. "]")
			resultFrame.BasicInformation.Age:SetTextColor(CreateColorFromHexString(miog.CLRSCC.purple):GetRGBA())

			resultFrame.BasicInformation.Age.ageTicker = C_Timer.NewTicker(1, function()
				ageNumber = ageNumber - 1
				resultFrame.BasicInformation.Age:SetText("[" .. miog.secondsToClock(ageNumber) .. "]")

			end)

			resultFrame.layoutIndex = -1

			miog.SearchPanel.FramePanel.Container:MarkDirty()

		else
			resultFrame.CancelApplication:Hide()
			
			if(resultFrame.BasicInformation.Age.ageTicker) then
				resultFrame.BasicInformation.Age.ageTicker:Cancel()

			end

			resultFrame.StatusFrame:Show()
			resultFrame.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[appStatus].statusString, miog.APPLICANT_STATUS_INFO[appStatus].color))

			local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

			if(searchResultInfo.leaderName and appStatus ~= "declined_full") then
				MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultInfo.activityID .. searchResultInfo.leaderName] = {timestamp = time(), activeDecline = appStatus == "declined"}

			end
		end

		return true
	end

	return false
end

local function updateResultFrameStatus(resultID)
	local resultFrame = searchResultSystem.persistentFrames[resultID]

	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

	if(resultFrame) then
		resultFrame.StatusFrame:Hide()

		if(updateSearchResultFrameApplicationStatus(resultID) == false) then
			resultFrame.CancelApplication:Hide()

			if(searchResultInfo.isDelisted) then
				if(resultFrame.BasicInformation.Age.ageTicker) then
					resultFrame.BasicInformation.Age.ageTicker:Cancel()

				end

				resultFrame.StatusFrame:Show()
				resultFrame.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO["declined_delisted"].statusString, miog.APPLICANT_STATUS_INFO["declined_delisted"].color))
			end
		end

		setResultFrameColors(resultID)
	end
end

local function createResultTooltip(resultID, resultFrame)
	if(C_LFGList.HasSearchResultInfo(resultID)) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		GameTooltip:SetOwner(resultFrame, "ANCHOR_RIGHT", 0, 0)
		LFGListUtil_SetSearchEntryTooltip(GameTooltip, resultID, searchResultInfo.autoAccept and LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE)

		if(MIOG_SavedSettings.enableResultFrameClassSpecTooltip.value) then
			GameTooltip:AddLine(" ")

			local orderedList = {}
			local specList = {}

			for i = 1, searchResultInfo.numMembers, 1 do
				local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(searchResultInfo.searchResultID, i)

				orderedList[i] = {role = role, class = class, specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]}

				specList[orderedList[i].specID] = specList[orderedList[i].specID] and specList[orderedList[i].specID] + 1 or 1
			end

			table.sort(orderedList, function(k1, k2)
				if(k1.role ~= k2.role) then
					return k1.role > k2.role

				elseif(k1.specID ~= k2.specID) then
					return k1.specID < k2.specID

				else
					return k1.class < k2.class

				end

			end)

			local newRole = nil

			for k, v in ipairs(orderedList) do
				local _, name, _, icon, _, classFile, className = GetSpecializationInfoByID(v.specID)

				if(name == "") then
					name = "Unspecced"

				end

				if(specList[v.specID]) then
					if(newRole ~= v.role) then
						if(newRole ~= nil) then
							--GameTooltip_AddBlankLineToTooltip(GameTooltip)
						end

						newRole = v.role

						--GameTooltip:AddLine(v.role)
					end

					local roleIcon = v.role == "TANK" and "groupfinder-icon-role-micro-tank" or v.role == "HEALER" and "groupfinder-icon-role-micro-heal" or "groupfinder-icon-role-micro-dps"

					GameTooltip:AddLine("|A:" .. roleIcon .. ":16:16|a" .. wticc(specList[v.specID] .. "x " .. "|T" .. icon .. ":11:11|t " .. name .. " " .. className, C_ClassColor.GetClassColor(classFile):GenerateHexColor()))

					specList[v.specID] = nil
				end
			end
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode))
		
		if(MIOG_SavedSettings.favouredApplicants.table[searchResultInfo.leaderName]) then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(searchResultInfo.leaderName .. " is on your favoured player list.")
		end

		local success, reason = isGroupEligible(resultID)

		if(not success and reason) then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(WrapTextInColorCode(reason[1], miog.CLRSCC.red))
			

		end

		GameTooltip:Show()
	end
end

miog.createResultTooltip = createResultTooltip

local function groupSignup(resultID)
	if(resultID and (UnitIsGroupLeader("player") or not IsInGroup() or not IsInRaid())) then
		local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if (appStatus ~= "none" or pendingStatus or searchResultInfo.isDelisted) then
			return false
		end

		if(LFGListFrame.SearchPanel.selectedResult) then
			_, appStatus = C_LFGList.GetApplicationInfo(LFGListFrame.SearchPanel.selectedResult)

			if(searchResultSystem.persistentFrames[LFGListFrame.SearchPanel.selectedResult]) then
				searchResultSystem.persistentFrames[LFGListFrame.SearchPanel.selectedResult]:SetBackdropBorderColor(
					CreateColorFromHexString(appStatus == "applied" and miog.CLRSCC.green or miog.C.BACKGROUND_COLOR_3):GetRGBA()
				)
			end
		end

		if(resultID ~= LFGListFrame.SearchPanel.selectedResult and searchResultSystem.persistentFrames[resultID]) then
			searchResultSystem.persistentFrames[resultID]:SetBackdropBorderColor(CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())

		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		LFGListSearchPanel_SelectResult(LFGListFrame.SearchPanel, resultID)

		LFGListSearchPanel_SignUp(LFGListFrame.SearchPanel)
	end

end

miog.groupSignup = groupSignup

local function gatherSearchResultSortData(singleResultID)
	local unsortedMainApplicantsList = {}

	local resultTable

	if(miog.F.IS_PGF1_LOADED) then
		_, resultTable = LFGListFrame.SearchPanel.totalResults, LFGListFrame.SearchPanel.results

	else
		_, resultTable = C_LFGList.GetFilteredSearchResults()

	end

	local counter = 1

	for _, resultID in ipairs(singleResultID and {[1] = singleResultID} or resultTable) do
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if(searchResultInfo and not searchResultInfo.hasSelf) then
			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)

			local _, appStatus, _, appDuration = C_LFGList.GetApplicationInfo(resultID)

			--if(appStatus == "applied" or activityInfo.categoryID == LFGListFrame.SearchPanel.categoryID) then
				local primarySortAttribute, secondarySortAttribute

				local nameTable

				if(searchResultInfo.leaderName) then
					nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")
				end

				if(nameTable and not nameTable[2]) then
					nameTable[2] = GetNormalizedRealmName()

					searchResultInfo.leaderName = nameTable[1] .. "-" .. nameTable[2]

				end

				if(LFGListFrame.SearchPanel.categoryID ~= 3 and LFGListFrame.SearchPanel.categoryID ~= 4 and LFGListFrame.SearchPanel.categoryID ~= 7 and LFGListFrame.SearchPanel.categoryID ~= 8 and LFGListFrame.SearchPanel.categoryID ~= 9) then
					primarySortAttribute = searchResultInfo.leaderOverallDungeonScore or 0
					secondarySortAttribute = searchResultInfo.leaderDungeonScoreInfo and searchResultInfo.leaderDungeonScoreInfo.bestRunLevel or 0

				elseif(LFGListFrame.SearchPanel.categoryID == 3) then
					local raidData = miog.getRaidSortData(searchResultInfo.leaderName)

					if(raidData) then
						primarySortAttribute = raidData[1].weight
						secondarySortAttribute = raidData[2].weight

					else
						primarySortAttribute = 0
						secondarySortAttribute = 0
					
					end

				elseif(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7 or LFGListFrame.SearchPanel.categoryID == 8 or LFGListFrame.SearchPanel.categoryID == 9) then
					primarySortAttribute = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0
					secondarySortAttribute = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0

				end

				unsortedMainApplicantsList[counter] = {
					primary = primarySortAttribute,
					appStatus = appStatus,
					secondary = secondarySortAttribute,
					resultID = resultID,
					age = searchResultInfo.age,
					favoured = searchResultInfo.leaderName and MIOG_SavedSettings.favouredApplicants.table[searchResultInfo.leaderName] and true or false
				}

				counter = counter + 1
			--end
		end

	end

	return unsortedMainApplicantsList
end

local function updatePersistentResultFrame(resultID)
	if(C_LFGList.HasSearchResultInfo(resultID)) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if(searchResultSystem.persistentFrames[resultID] and searchResultInfo.leaderName) then
			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
			local currentFrame = searchResultSystem.persistentFrames[resultID]
			local mapID = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].mapID
			local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
			local declineData = searchResultInfo.leaderName and MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultInfo.activityID .. searchResultInfo.leaderName]
			
			currentFrame:SetScript("OnMouseDown", function(_, button)
				groupSignup(searchResultInfo.searchResultID)

			end)
			currentFrame:SetScript("OnEnter", function()
				createResultTooltip(searchResultInfo.searchResultID, currentFrame)

			end)

			currentFrame.BasicInformation.Icon:SetTexture(miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].icon or nil)
			currentFrame.BasicInformation.Icon:SetScript("OnMouseDown", function()
				EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

			end)

			local color = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.DIFFICULTY_ID_TO_COLOR[miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID] or {r = 1, g = 1, b = 1}

			currentFrame.BasicInformation.IconBorder:SetColorTexture(color.r, color.g, color.b, 1)
	
			currentFrame.CategoryInformation.ExpandFrame:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				currentFrame.CategoryInformation.ExpandFrame:AdvanceState()
				currentFrame.DetailedInformationPanel:SetShown(not currentFrame.DetailedInformationPanel:IsVisible())
				currentFrame:MarkDirty()
		
			end)
		

			if(currentFrame.BasicInformation.Age.ageTicker) then
				currentFrame.BasicInformation.Age.ageTicker:Cancel()
	
			end

			local ageNumber = searchResultInfo.age
			currentFrame.BasicInformation.Age:SetText(miog.secondsToClock(ageNumber))
			currentFrame.BasicInformation.Age:SetTextColor(1, 1, 1, 1)
			currentFrame.BasicInformation.Age.ageTicker = C_Timer.NewTicker(1, function()
				ageNumber = ageNumber + 1
				currentFrame.BasicInformation.Age:SetText(miog.secondsToClock(ageNumber))

			end)

			local titleZoneColor = nil

			if(searchResultInfo.autoAccept) then
				titleZoneColor = miog.CLRSCC.blue
				
			elseif(searchResultInfo.isWarMode) then
				titleZoneColor = miog.CLRSCC.yellow

			elseif(declineData) then
				if(declineData.timestamp > time() - 900) then
					titleZoneColor = declineData.activeDecline and miog.CLRSCC.red or miog.CLRSCC.orange
					
				else
					titleZoneColor = "FFFFFFFF"
					MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultInfo.activityID .. searchResultInfo.leaderName] = nil

				end
			else
				titleZoneColor = "FFFFFFFF"
			
			end

			local warmodeString = searchResultInfo.isWarMode and "|A:pvptalents-warmode-swords:12:12|a" or ""
			local bnetFriends = searchResultInfo.numBNetFriends > 0 and "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\battlenetfriend.png:14|t" or ""
			local charFriends = searchResultInfo.numCharFriends > 0 and "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\friend.png:14|t" or ""
			local guildFriends = searchResultInfo.numGuildMates > 0 and "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\guildmate.png:14|t" or ""

			currentFrame.BasicInformation.Title:SetText(warmodeString .. bnetFriends .. charFriends .. guildFriends .. wticc(searchResultInfo.name, titleZoneColor))
			currentFrame.CategoryInformation.Comment:SetShown(searchResultInfo.comment ~= "" and searchResultInfo.comment ~= nil and true or false)

			currentFrame.CancelApplication:SetScript("OnClick", function(self, button)
				if(button == "LeftButton") then
					local _, appStatus = C_LFGList.GetApplicationInfo(searchResultInfo.searchResultID)

					if(appStatus == "applied") then
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
						C_LFGList.CancelApplication(searchResultInfo.searchResultID)
					
					end
				end
			end)

			local difficultyID = miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID
			local difficultyName = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID ~= 0 and miog.DIFFICULTY_ID_INFO[difficultyID].shortName
			local questType = searchResultInfo.questID and C_QuestLog.GetQuestType(searchResultInfo.questID)
			local questDesc = questType and miog.RAW["QuestInfo"][questType] and miog.RAW["QuestInfo"][questType][1]
			local shortName = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].shortName

			local difficultyZoneText = difficultyID and difficultyName or questDesc or nil
			
			currentFrame.CategoryInformation.DifficultyZone:SetText(wticc((difficultyZoneText and difficultyZoneText .. " - " or "") .. (shortName or activityInfo.fullName), titleZoneColor)
			)

			local primaryIndicator = currentFrame.BasicInformation.Primary
			local secondaryIndicator = currentFrame.BasicInformation.Secondary
			local nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")

			miog.gatherRaiderIODisplayData(nameTable[1], nameTable[2], currentFrame)

			local generalInfoPanel = currentFrame.DetailedInformationPanel.PanelContainer.ForegroundRows.GeneralInfo
			
			generalInfoPanel.Right["1"].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. ((searchResultInfo.comment and searchResultInfo.comment) or ""))
			generalInfoPanel.Right["4"].FontString:SetText("Role: ")

			local appCategory = activityInfo.categoryID

			if(appCategory == 2) then
				if(searchResultInfo.leaderOverallDungeonScore > 0) then
					local reqScore = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or 0
					local highestKeyForDungeon

					if(reqScore > searchResultInfo.leaderOverallDungeonScore) then
						primaryIndicator:SetText(wticc(tostring(searchResultInfo.leaderOverallDungeonScore), miog.CLRSCC["red"]))

					else
						primaryIndicator:SetText(wticc(tostring(searchResultInfo.leaderOverallDungeonScore), miog.createCustomColorForScore(searchResultInfo.leaderOverallDungeonScore):GenerateHexColor()))

					end

					if(searchResultInfo.leaderDungeonScoreInfo) then
						if(searchResultInfo.leaderDungeonScoreInfo.finishedSuccess == true) then
							highestKeyForDungeon = wticc(tostring(searchResultInfo.leaderDungeonScoreInfo.bestRunLevel), miog.C.GREEN_COLOR)

						elseif(searchResultInfo.leaderDungeonScoreInfo.finishedSuccess == false) then
							highestKeyForDungeon = wticc(tostring(searchResultInfo.leaderDungeonScoreInfo.bestRunLevel), miog.CLRSCC["red"])

						end
					else
						highestKeyForDungeon = wticc(tostring(0), miog.CLRSCC["red"])

					end

					secondaryIndicator:SetText(highestKeyForDungeon)
				else
					local difficulty = miog.DIFFICULTY[-1] -- NO DATA
					primaryIndicator:SetText(wticc("0", difficulty.color))
					secondaryIndicator:SetText(wticc("0", difficulty.color))

				end
			elseif(appCategory == 4 or appCategory == 7 or appCategory == 8 or appCategory == 9) then
				if(searchResultInfo.leaderPvpRatingInfo) then
					primaryIndicator:SetText(wticc(tostring(searchResultInfo.leaderPvpRatingInfo.rating), miog.createCustomColorForScore(searchResultInfo.leaderPvpRatingInfo.rating):GenerateHexColor()))

					local tierResult = miog.simpleSplit(PVPUtil.GetTierName(searchResultInfo.leaderPvpRatingInfo.tier), " ")
					secondaryIndicator:SetText(strsub(tierResult[1], 0, tierResult[2] and 2 or 4) .. ((tierResult[2] and "" .. tierResult[2]) or ""))
					
				else
					primaryIndicator:SetText(0)
					secondaryIndicator:SetText("Unra")

				end
			end

			local orderedList = {}

			local roleCount = {
				["TANK"] = 0,
				["HEALER"] = 0,
				["DAMAGER"] = 0,
			}

			for i = 1, searchResultInfo.numMembers, 1 do
				local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(searchResultInfo.searchResultID, i)

				orderedList[i] = {leader = i == 1 and true or false, role = role, class = class, specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]}

				if(role) then
					roleCount[role] = roleCount[role] + 1

				else
					orderedList[i].role = "DAMAGER"
				end
			end

			local groupLimit = activityInfo.maxNumPlayers == 0 and 5 or activityInfo.maxNumPlayers
			local groupSize = #orderedList

			local memberPanel = currentFrame.CategoryInformation.MemberPanel
			local bossPanel = currentFrame.CategoryInformation.BossPanel

			currentFrame.CategoryInformation.RoleComposition:SetText("[" .. roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"] .. "]")
			
			if(appCategory == 3) then
				local raidData = miog.getRaidSortData(searchResultInfo.leaderName)
				primaryIndicator:SetText(wticc(raidData[1].parsedString, raidData[1].current and miog.DIFFICULTY[raidData[1].difficulty].color or miog.DIFFICULTY[raidData[1].difficulty].desaturated))
				secondaryIndicator:SetText(wticc(raidData[2].parsedString, raidData[2].current and miog.DIFFICULTY[raidData[2].difficulty].color or miog.DIFFICULTY[raidData[2].difficulty].desaturated))

				memberPanel:Hide()
				currentFrame.CategoryInformation.DifficultyZone:SetWidth(LFGListFrame.SearchPanel.filters == Enum.LFGListFilter.NotRecommended and 60 or 140)

				for i = 1, 2, 1 do
					if(roleCount["TANK"] < 2 and groupSize < groupLimit) then
						orderedList[groupSize + 1] = {class = "DUMMY", role = "TANK", specID = 20}
						roleCount["TANK"] = roleCount["TANK"] + 1
						groupSize = groupSize + 1
					end
				end
	
				for i = 1, 6, 1 do
					if(roleCount["HEALER"] < 6 and groupSize < groupLimit) then
						orderedList[groupSize + 1] = {class = "DUMMY", role = "HEALER", specID = 20}
						roleCount["HEALER"] = roleCount["HEALER"] + 1
						groupSize = groupSize + 1
		
					end
				end
	
				for i = groupSize, groupLimit, 1 do
					orderedList[groupSize + 1] = {class = "DUMMY", role = "DAMAGER", specID = 20}
					roleCount["DAMAGER"] = roleCount["DAMAGER"] + 1
					groupSize = groupSize + 1
				end
	
				table.sort(orderedList, function(k1, k2)
					-- Sort by role first
					if k1.role ~= k2.role then
						return k1.role > k2.role
					end
				
					-- Sort by specID if role and class are the same
					if k1.specID and k2.specID then
						return k1.specID > k2.specID
					elseif k1.specID then
						return false
					elseif k2.specID then
						return true
					end
				
					-- Sort by class if role is the same
					if k1.class ~= k2.class then
						-- "DUMMY" class should always come last
						if k1.class == "DUMMY" then
							return false
						elseif k2.class == "DUMMY" then
							return true
						end
						return k1.class > k2.class
					end
				
					-- If everything else is equal, maintain the existing order
					return false
				end)

				local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(resultID)

				if(currentFrame.encounterInfo ~= encounterInfo or encounterInfo == {}) then
					local encountersDefeated = {}

					if(encounterInfo) then
						for k, v in ipairs(encounterInfo) do
							encountersDefeated[v] = true
						end
					end

					for k, v in ipairs(bossPanel.bossFrames) do
						if(miog.MAP_INFO[mapID].bosses[k]) then

							local currentBoss = miog.MAP_INFO[mapID].bosses[k]

							if(encountersDefeated[currentBoss.name]) then
								v.Icon:SetDesaturated(true)
								v.Border:SetColorTexture(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())

							else
								v.Icon:SetDesaturated(false)
								v.Border:SetColorTexture(CreateColorFromHexString(miog.CLRSCC.green):GetRGBA())
							
							end
						
						else
							v.Border:SetColorTexture(0,0,0,0)

						end

					end

					currentFrame.encounterInfo = encounterInfo
				else
					--OPTIMIZE RAID FRAMES, UGHGHGHGHGHGHHGGHG

					--print("NO NEW BOSS INFO", GetTimePreciseSec())

					--bossPanel:MarkDirty()
				
				end

				--[[for i = 1, 40, 1 do
					local groupMemberFrame = currentFrame.RaidInformation.SpecFrames[i]

					if(i <= groupLimit) then
						if(groupMemberFrame.Icon:GetTexture() ~= miog.SPECIALIZATIONS[orderedList[i].specID].squaredIcon) then
							groupMemberFrame.Icon:SetTexture(miog.SPECIALIZATIONS[orderedList[i].specID].squaredIcon)

							if(orderedList[i].class ~= "DUMMY") then
								groupMemberFrame.Border:SetColorTexture(C_ClassColor.GetClassColor(orderedList[i].class):GetRGBA())
								groupMemberFrame.Border:Show()
	
							else
								groupMemberFrame.Border:Hide()
							
							end
						else
							groupMemberFrame.Border:Hide()
						
						end

						if(orderedList[i].role ~= "DAMAGER") then
							groupMemberFrame:Show()

						else
							damagerString = damagerString .. " |T" .. groupMemberFrame.Icon:GetTexture() .. ":16|t"
						end

					else
						groupMemberFrame:Hide()
					
					end
					
				end]]

				bossPanel:SetShown(true)
				--currentFrame.RaidInformation:SetShown(true)

			elseif(appCategory ~= 0 and appCategory ~= 8 and appCategory ~= 9) then
				--currentFrame.RaidInformation:Hide()
				currentFrame.CategoryInformation.DifficultyZone:SetWidth(100)
				bossPanel:Hide()

				for i = 1, 1, 1 do
					if(roleCount["TANK"] < 1 and groupSize < groupLimit) then
						orderedList[groupSize + 1] = {class = "DUMMY", role = "TANK", specID = 20}
						roleCount["TANK"] = roleCount["TANK"] + 1
						groupSize = groupSize + 1
					end
				end
	
				for i = 1, 1, 1 do
					if(roleCount["HEALER"] < 1 and groupSize < groupLimit) then
						orderedList[groupSize + 1] = {class = "DUMMY", role = "HEALER", specID = 20}
						roleCount["HEALER"] = roleCount["HEALER"] + 1
						groupSize = groupSize + 1
		
					end
				end
	
				for i = 3, 5, 1 do
					orderedList[groupSize + 1] = {class = "DUMMY", role = "DAMAGER", specID = 20}
					roleCount["DAMAGER"] = roleCount["DAMAGER"] + 1
					groupSize = groupSize + 1
				end
	
				table.sort(orderedList, function(k1, k2)
					if(k1.role ~= k2.role) then
						return k1.role > k2.role
	
					elseif(k1.spec ~= k2.spec) then

						if(k1.class == "DUMMY" and k2.class ~= "DUMMY") then
							return false

						elseif(k2.class == "DUMMY" and k1.class ~= "DUMMY") then
							return true

						else
							return k1.spec > k2.spec

						end
	
					else

						if(k1.class == "DUMMY" and k2.class ~= "DUMMY") then
							return false

						elseif(k2.class == "DUMMY" and k1.class ~= "DUMMY") then
							return true

						else
							return k1.class > k2.class

						end
	
					end
	
				end)
				
				for i = 1, 5, 1 do
					if(i <= groupLimit) then
						local currentMemberFrame = memberPanel[tostring(i)]

						currentMemberFrame.Icon:SetTexture(miog.SPECIALIZATIONS[orderedList[i].specID] and miog.SPECIALIZATIONS[orderedList[i].specID].squaredIcon)

						if(orderedList[i].class ~= "DUMMY") then
							currentMemberFrame.Border:SetColorTexture(C_ClassColor.GetClassColor(orderedList[i].class):GetRGBA())

						else
							currentMemberFrame.Border:SetColorTexture(0, 0, 0, 0)
						
						end

						if(orderedList[i].leader) then
							memberPanel.LeaderCrown:ClearAllPoints()
							memberPanel.LeaderCrown:SetParent(currentMemberFrame)
							memberPanel.LeaderCrown:SetPoint("CENTER", currentMemberFrame, "TOP")
							memberPanel.LeaderCrown:SetShown(true)

							currentMemberFrame:SetMouseMotionEnabled(true)
							currentMemberFrame:SetScript("OnEnter", function()
								GameTooltip:SetOwner(currentMemberFrame, "ANCHOR_CURSOR")
								GameTooltip:AddLine(format(_G["LFG_LIST_TOOLTIP_LEADER"], searchResultInfo.leaderName))
								GameTooltip:Show()

							end)
						else
							currentMemberFrame:SetScript("OnEnter", nil)
						
						end

						--orderedListIndex = orderedListIndex + 1
						memberPanel[tostring(i)]:Show()

					else
						memberPanel[tostring(i)]:Hide()
					
					end
				end
				
				memberPanel:Show()

			else
				bossPanel:Hide()
				memberPanel:Hide()
				currentFrame.CategoryInformation.DifficultyZone:SetWidth(144)
			
			end

			--currentFrame.DetailedInformationPanel:SetPoint("TOPLEFT", currentFrame.BasicInformationPanel or (currentFrame.RaidInformation:IsVisible() and currentFrame.RaidInformation or currentFrame.CategoryInformation), "BOTTOMLEFT")
			--currentFrame.DetailedInformationPanel:SetPoint("TOPRIGHT", currentFrame.BasicInformationPanel or (currentFrame.RaidInformation:IsVisible() and currentFrame.RaidInformation or currentFrame.CategoryInformation), "BOTTOMRIGHT")
			generalInfoPanel.Right["1"].FontString:SetText(resultID)
		end


		updateResultFrameStatus(resultID)
	end
end

local function createPersistentResultFrame(resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
	local mapID = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].mapID

	local persistentFrame = miog.createBasicFrame("searchResult", "MIOG_ResultFrameTemplate", miog.SearchPanel.FramePanel.Container)
	persistentFrame.fixedWidth = miog.SearchPanel.FramePanel:GetWidth()
	--persistentFrame:SetFrameStrata("DIALOG")
	persistentFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)
	miog.createFrameBorder(persistentFrame, 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGB())

	persistentFrame.framePool = persistentFrame.framePool or CreateFramePoolCollection()
	persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_GroupMemberTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_SmallGroupMemberTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_ResultFrameBossFrameTemplate", miog.resetFrame):SetResetDisallowedIfNew()

	searchResultSystem.persistentFrames[resultID] = persistentFrame

	persistentFrame.StatusFrame:SetFrameStrata("FULLSCREEN")

	if(miog.F.LITE_MODE) then
		persistentFrame.BasicInformation.Title:SetWidth(90)
		persistentFrame.CategoryInformation.RoleComposition:ClearAllPoints()
		persistentFrame.CategoryInformation.RoleComposition:SetPoint("LEFT", persistentFrame.BasicInformation.Title, "RIGHT", 3, 0)

		persistentFrame.BasicInformation.Primary:ClearAllPoints()
		persistentFrame.BasicInformation.Primary:SetPoint("LEFT", persistentFrame.CategoryInformation.RoleComposition, "RIGHT", 3, 0)

	end

	local expandFrameButton = persistentFrame.CategoryInformation.ExpandFrame
	expandFrameButton:OnLoad()
	expandFrameButton:SetMaxStates(2)
	expandFrameButton:SetTexturesForBaseState("UI-HUD-ActionBar-PageDownArrow-Up", "UI-HUD-ActionBar-PageDownArrow-Down", "UI-HUD-ActionBar-PageDownArrow-Mouseover", "UI-HUD-ActionBar-PageDownArrow-Disabled")
	expandFrameButton:SetTexturesForState1("UI-HUD-ActionBar-PageUpArrow-Up", "UI-HUD-ActionBar-PageUpArrow-Down", "UI-HUD-ActionBar-PageUpArrow-Mouseover", "UI-HUD-ActionBar-PageUpArrow-Disabled")
	expandFrameButton:SetState(false)

	persistentFrame.CancelApplication:OnLoad()


	--for i = 1, #, 1 do
	if(miog.MAP_INFO[mapID]) then
		--[[persistentFrame.RaidInformation.SpecFrames = {}

		for i = 1, 40, 1 do
			local currentPanel = i < 3 and "TankPanel" or i < 9 and "HealerPanel" or "DamagerPanel"
			local groupMemberFrame = persistentFrame.framePool:Acquire("MIOG_SmallGroupMemberTemplate")
			groupMemberFrame:SetParent(persistentFrame.RaidInformation[currentPanel])
			groupMemberFrame.layoutIndex = i
	
			persistentFrame.RaidInformation.SpecFrames[i] = groupMemberFrame
	
		end]]

		persistentFrame.CategoryInformation.BossPanel.bossFrames = {}

		for k, v in ipairs(miog.MAP_INFO[mapID].bosses) do
			local bossFrame = persistentFrame.framePool:Acquire("MIOG_ResultFrameBossFrameTemplate")
			bossFrame:SetParent(persistentFrame.CategoryInformation.BossPanel)
			bossFrame.layoutIndex = k

			if(bossFrame.BorderMask == nil) then
				bossFrame.BorderMask = bossFrame:CreateMaskTexture()
				bossFrame.BorderMask:SetAllPoints(bossFrame.Border)
				bossFrame.BorderMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
				bossFrame.Border:AddMaskTexture(bossFrame.BorderMask)
			end

			SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, v.creatureDisplayInfoID)
			bossFrame.Border:SetColorTexture(CreateColorFromHexString(miog.CLRSCC.green):GetRGBA())

			bossFrame:Show()

			persistentFrame.CategoryInformation.BossPanel.bossFrames[k] = bossFrame
		end
	
		persistentFrame.CategoryInformation.BossPanel:MarkDirty()
	end

	miog.createDetailedInformationPanel(persistentFrame)
end

local lastOrderedList = nil

local function checkSearchResultListForEligibleMembers()
	if(lastOrderedList) then
		local actualResultsCounter = 0
		local updatedFrames = {}

		table.sort(lastOrderedList, sortSearchResultList)

		for index, listEntry in ipairs(lastOrderedList) do
			searchResultSystem.persistentFrames[listEntry.resultID].layoutIndex = index

			updatePersistentResultFrame(listEntry.resultID)

			if(listEntry.appStatus == "applied" or isGroupEligible(listEntry.resultID)) then
				searchResultSystem.persistentFrames[listEntry.resultID]:Show()
				updatedFrames[listEntry.resultID] = true
				actualResultsCounter = actualResultsCounter + 1

			end
		end

		for index, v in pairs(searchResultSystem.persistentFrames) do
			if(not updatedFrames[index]) then
				v:Hide()

			end
		end

		miog.SearchPanel.FramePanel.Container:MarkDirty()

		miog.Plugin.FooterBar.Results:SetText(actualResultsCounter .. "(" .. #lastOrderedList .. ")")
	end
end

miog.checkSearchResultListForEligibleMembers = checkSearchResultListForEligibleMembers

local function releaseAllResultFrames()
	for index, v in pairs(searchResultSystem.persistentFrames) do
		v.framePool:ReleaseAll()

		miog.searchResultFramePool:Release(v)

		searchResultSystem.persistentFrames[index] = nil

	end
end

local function updateSearchResultList()
	if(not miog.F.SEARCH_IS_THROTTLED) then

		releaseAllResultFrames()

		local orderedList = gatherSearchResultSortData()
		table.sort(orderedList, sortSearchResultList)

		lastOrderedList = orderedList

		local actualResultsCounter = 0
		local updatedFrames = {}
		
		for index, listEntry in ipairs(orderedList) do
			createPersistentResultFrame(listEntry.resultID)
			searchResultSystem.persistentFrames[listEntry.resultID].layoutIndex = index

			updatePersistentResultFrame(listEntry.resultID)

			if(listEntry.appStatus == "applied" or isGroupEligible(listEntry.resultID)) then
				searchResultSystem.persistentFrames[listEntry.resultID]:Show()
				updatedFrames[listEntry.resultID] = true
				actualResultsCounter = actualResultsCounter + 1

			end
		end

		for index, v in pairs(searchResultSystem.persistentFrames) do
			if(not updatedFrames[index]) then
				v:Hide()

			end
		end

		miog.SearchPanel.FramePanel.Container:MarkDirty()

		miog.Plugin.FooterBar.Results:SetText(actualResultsCounter .. "(" .. #orderedList .. ")")

	end
end

miog.updateSearchResultList = updateSearchResultList

local blocked = false

local function searchResultsReceived()
	miog.SearchPanel.Status:Show()
	miog.SearchPanel.Status.FontString:Hide()
	miog.SearchPanel.Status.LoadingSpinner:Show()

	local totalResults = LFGListFrame.SearchPanel.totalResults or C_LFGList.GetFilteredSearchResults()

	--if(not LFGListFrame.SearchPanel.searching) then
		if(totalResults > 0) then
			if(not blocked) then
				blocked = true
				miog.SearchPanel.FramePanel:SetVerticalScroll(0)
				
				C_Timer.After(MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods > 0 and 0.45 or 0, function()
					miog.SearchPanel.Status:Hide()
					miog.SearchPanel.Status.LoadingSpinner:Hide()
					updateSearchResultList()
					blocked = false
				end)
			end
		else
			if(not miog.F.SEARCH_IS_THROTTLED) then
				miog.SearchPanel.Status.LoadingSpinner:Hide()
				miog.SearchPanel.Status.FontString:SetText(LFGListFrame.SearchPanel.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND)
				miog.SearchPanel.Status.FontString:Show()

			end
		end
	--end
end

local function searchPanelEvents(_, event, ...)
	if(event == "PLAYER_LOGIN") then

	elseif(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
		local totalResults = LFGListFrame.SearchPanel.totalResults or C_LFGList.GetFilteredSearchResults()
		LFGListFrame.SearchPanel.searching = true
		searchResultsReceived()

	elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then --update to title, ilvl, group members, etc
		if(C_LFGList.HasSearchResultInfo(...)) then
			updatePersistentResultFrame(...)

		end
	elseif(event == "LFG_LIST_SEARCH_FAILED") then
		--print("Search failed because of " .. ...)

		if(... == "throttled") then
			if(not miog.F.SEARCH_IS_THROTTLED) then
				miog.F.SEARCH_IS_THROTTLED = true
				local timestamp = GetTime()

				miog.SearchPanel.Status.FontString:Hide()
				miog.SearchPanel.Status.LoadingSpinner:Hide()
				miog.SearchPanel.StartSearch:Disable()
				miog.SearchPanel.Status.FontString:SetText("Time until search is available again: " .. miog.secondsToClock(timestamp + 3 - GetTime()))

				C_Timer.NewTicker(0.2, function(self)
					local timeUntil = timestamp + 3 - GetTime()
					miog.SearchPanel.Status.FontString:SetText("Time until search is available again: " .. wticc(miog.secondsToClock(timeUntil), timeUntil > 2 and miog.CLRSCC.red or timeUntil > 1 and miog.CLRSCC.orange or miog.CLRSCC.yellow))

					if(timeUntil <= 0) then
						miog.SearchPanel.StartSearch:Enable()
						miog.SearchPanel.Status.FontString:SetText(wticc("Search is available again!", miog.CLRSCC.green))
						miog.F.SEARCH_IS_THROTTLED = false
						self:Cancel()
					end
				end)
			
				miog.SearchPanel.Status:Show()
				miog.SearchPanel.Status.FontString:Show()

			end
		end

	elseif(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
		local resultID, new, old, name = ...

		--local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)

		updateSearchResultFrameApplicationStatus(resultID, new, old)

		if(not miog.F.LITE_MODE and new == "inviteaccepted") then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)

			local lastGroup = miog.ACTIVITY_INFO[searchResultInfo.activityID].name or activityInfo.fullName
			miog.MainTab.CategoryPanel.LastGroup.Text:SetText(lastGroup)

			MIOG_SavedSettings.lastGroup.value = lastGroup

		end

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS") then
		--print(event, ...)
		--Happens when in a group and group is at max members after inviting a person
		--Not decided if it's needed

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TIMEOUT") then
	end
end

miog.createSearchPanel = function()
	local searchPanel = CreateFrame("Frame", "MythicIOGrabber_SearchPanel", miog.Plugin.InsertFrame, "MIOG_SearchPanel") ---@class Frame
	miog.SearchPanel = searchPanel
	miog.SearchPanel.FramePanel.ScrollBar:SetPoint("TOPRIGHT", miog.SearchPanel.FramePanel, "TOPRIGHT", -7, 0)
	miog.ApplicationViewer.FramePanel.ScrollBar:SetPoint("TOPRIGHT", miog.ApplicationViewer.FramePanel, "TOPRIGHT", -7, 0)

	local signupButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.SearchPanel, 1, 20)
	signupButton:SetPoint("LEFT", miog.Plugin.FooterBar.Back, "RIGHT")
	signupButton:SetText("Signup")
	signupButton:FitToText()
	signupButton:RegisterForClicks("LeftButtonDown")
	signupButton:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		LFGListApplicationDialog_Show(LFGListApplicationDialog, LFGListFrame.SearchPanel.selectedResult)

		miog.groupSignup(LFGListFrame.SearchPanel.selectedResult)
	end)

	searchPanel.SignUpButton = signupButton

	local searchBox = LFGListFrame.SearchPanel.SearchBox
	searchBox:ClearAllPoints()
	searchBox:SetParent(searchPanel)

	searchPanel.standardSearchBoxWidth = LFGListFrame.SearchPanel.SearchBox:GetWidth()

	if(not miog.F.LITE_MODE) then
		searchBox:SetSize(searchPanel.SearchBoxBase:GetSize())
		searchBox:SetPoint(searchPanel.SearchBoxBase:GetPoint())

	else
		LFGListFrame.SearchPanel.SearchBox:SetWidth(searchPanel.standardSearchBoxWidth - 80)
	
	end

	searchPanel.SearchBox = searchBox

	local searchingSpinner = LFGListFrame.SearchPanel.SearchingSpinner
	searchingSpinner:ClearAllPoints()
	searchingSpinner:SetParent(searchPanel)
	searchingSpinner:Hide()
	searchPanel.SearchingSpinner = searchingSpinner

	local backButton = LFGListFrame.SearchPanel.BackButton
	backButton:ClearAllPoints()
	backButton:SetParent(searchPanel)
	backButton:Hide()
	searchPanel.BackButton = backButton

	local backToGroupButton = LFGListFrame.SearchPanel.BackToGroupButton
	backToGroupButton:ClearAllPoints()
	backToGroupButton:SetParent(searchPanel)
	backToGroupButton:Hide()
	searchPanel.BackToGroupButton = backToGroupButton

	local scrollBox = LFGListFrame.SearchPanel.ScrollBox
	scrollBox:ClearAllPoints()
	scrollBox:SetParent(searchPanel)
	scrollBox:Hide()
	searchPanel.ScrollBox = scrollBox

	local autoCompleteFrame = LFGListFrame.SearchPanel.AutoCompleteFrame
	autoCompleteFrame:ClearAllPoints()
	autoCompleteFrame:SetParent(searchPanel)
	autoCompleteFrame:SetFrameStrata("DIALOG")
	autoCompleteFrame:SetWidth(searchBox:GetWidth())
	autoCompleteFrame:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -4, 1)
	searchPanel.AutoCompleteFrame = autoCompleteFrame
	
	searchPanel.StartSearch:SetScript("OnClick", function( )
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
		--C_LFGList.Search(LFGListFrame.SearchPanel.categoryID, LFGListFrame.SearchPanel.filters, LFGListFrame.SearchPanel.preferredFilters, C_LFGList.GetLanguageSearchFilter());

		miog.SearchPanel.FramePanel:SetVerticalScroll(0)
	end)

	miog.createFrameBorder(searchPanel.ButtonPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	searchPanel.ButtonPanel.sortByCategoryButtons = {}

	for i = 1, 3, 1 do
		local sortByCategoryButton = searchPanel.ButtonPanel[i == 1 and "PrimarySort" or i == 2 and "SecondarySort" or "AgeSort"]
		sortByCategoryButton.panel = "SearchPanel"
		sortByCategoryButton.category = i == 1 and "primary" or i == 2 and "secondary" or i == 3 and "age"

		sortByCategoryButton:SetScript("PostClick", function(self, button)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			miog.checkSearchResultListForEligibleMembers()
		end)

		searchPanel.ButtonPanel.sortByCategoryButtons[sortByCategoryButton.category] = sortByCategoryButton

	end

	searchPanel.ButtonPanel["PrimarySort"]:AdjustPointsOffset(miog.Plugin:GetWidth() * 0.52, 0)

	miog.SearchPanel:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	miog.SearchPanel:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	miog.SearchPanel:RegisterEvent("LFG_LIST_SEARCH_FAILED")
	miog.SearchPanel:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT")
	miog.SearchPanel:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS")
	miog.SearchPanel:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
	miog.SearchPanel:SetScript("OnEvent", searchPanelEvents)
	miog.SearchPanel:SetScript("OnShow", function()
	end)
end