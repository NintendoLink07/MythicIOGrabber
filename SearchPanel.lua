local addonName, miog = ...
local wticc = WrapTextInColorCode

local _, playerClassID = UnitClassBase("player")

local searchResultSystem = {}
searchResultSystem.declinedGroups = {}
searchResultSystem.raidSortData = {}

searchResultSystem.baseFrames = {}
searchResultSystem.raiderIOPanels = {}

local collapsedList = {}
local currentDataList

local framePool

local function resetFrame(pool, childFrame)
    childFrame:Hide()
	childFrame.layoutIndex = nil
	childFrame.resultID = nil

	childFrame.CategoryInformation.BossPanel:Hide()

	--miog.resetNewRaiderIOInfoPanel(childFrame.RaiderIOInformationPanel)
end

local function setResultFrameColors(resultID, isInviteFrame)
	local resultFrame = searchResultSystem.baseFrames[resultID]

	if(resultFrame and C_LFGList.HasSearchResultInfo(resultID)) then
		local isEligible, reasonID = miog.checkEligibility("LFGListFrame.SearchPanel", nil, resultID, true)
		local reason = miog.INELIGIBILITY_REASONS[reasonID]
		local _, appStatus = C_LFGList.GetApplicationInfo(resultID)

		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		local r, g, b

		if(appStatus == "applied") then
			if(isEligible) then
				resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.green):GetRGBA())
				r, g, b = CreateColorFromHexString(miog.CLRSCC.green):GetRGB()

			else
				resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
				r, g, b = CreateColorFromHexString(miog.CLRSCC.red):GetRGB()

			end

		elseif(searchResultInfo and searchResultInfo.leaderName and C_FriendList.IsIgnored(searchResultInfo.leaderName)) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
			r, g, b = CreateColorFromHexString(miog.CLRSCC.red):GetRGB()

			--resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

		elseif(resultID == LFGListFrame.SearchPanel.selectedResult) then
				resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())

		elseif(MIOG_NewSettings.favouredApplicants[searchResultInfo.leaderName]) then
			if(isEligible) then
				resultFrame:SetBackdropBorderColor(CreateColorFromHexString("FFe1ad21"):GetRGBA())
				r, g, b = CreateColorFromHexString("FFe1ad21"):GetRGB()

			else
				r, g, b = CreateColorFromHexString(miog.CLRSCC.orange):GetRGB()
				resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.orange):GetRGBA())

			end

			--resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

		else
			if(isEligible) then
				if(MR_GetSavedPartyGUIDs) then
					local partyGUIDs = MR_GetSavedPartyGUIDs()

					if(partyGUIDs[searchResultInfo.partyGUID]) then
						resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.yellow):GetRGBA())
						r, g, b = CreateColorFromHexString(miog.CLRSCC.yellow):GetRGB()

					else
						resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

					end
				else
					resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

				end
			else
				r, g, b = CreateColorFromHexString(miog.CLRSCC.orange):GetRGB()
				resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.orange):GetRGBA())

			end
		end
		
		if(r) then
			resultFrame.Background:SetVertexColor(r, g, b, 0.4)
		end
	end
end

miog.setResultFrameColors = setResultFrameColors

local function updateSearchResultFrameApplicationStatus(resultID, new, old)
	local resultFrame = searchResultSystem.baseFrames[resultID]

	if(resultFrame) then
		local id, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(resultID)

		appStatus = new or appStatus

		if(resultFrame and appStatus and appStatus ~= "none") then
			if(appStatus == "applied") then
				if(resultFrame.BasicInformation.Age.ageTicker) then
					resultFrame.BasicInformation.Age.ageTicker:Cancel()

				end

				resultFrame.CancelApplication:Show()
				resultFrame.AcceptInvite:Hide()

				local ageNumber = appDuration or 0
				resultFrame.BasicInformation.Age:SetText("[" .. miog.secondsToClock(ageNumber) .. "]")
				resultFrame.BasicInformation.Age:SetTextColor(CreateColorFromHexString(miog.CLRSCC.purple):GetRGBA())

				resultFrame.BasicInformation.Age.ageTicker = C_Timer.NewTicker(1, function()
					ageNumber = ageNumber - 1
					resultFrame.BasicInformation.Age:SetText("[" .. miog.secondsToClock(ageNumber) .. "]")

				end)
			else
				resultFrame.CancelApplication:Hide()

				if(resultFrame.BasicInformation.Age.ageTicker) then
					resultFrame.BasicInformation.Age.ageTicker:Cancel()

				end

				resultFrame.StatusFrame:Show()
				resultFrame.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[appStatus].statusString, miog.APPLICANT_STATUS_INFO[appStatus].color))

				local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
					
				if(searchResultInfo.leaderName and appStatus ~= "declined_full" and appStatus ~= "failed" and appStatus ~= "invited" and appStatus ~= "inviteaccepted") then
					MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID] = {timestamp = time(), activeDecline = appStatus == "declined"}

				end
			end

			return true
		end

		return false
	end

	return false
end

miog.updateSearchResultFrameApplicationStatus = updateSearchResultFrameApplicationStatus

local function updateResultFrameStatus(resultID)
	local resultFrame = searchResultSystem.baseFrames[resultID]

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

miog.updateResultFrameStatus = updateResultFrameStatus

local function createResultTooltip(resultID, resultFrame)
	if(C_LFGList.HasSearchResultInfo(resultID)) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		GameTooltip:SetOwner(resultFrame, "ANCHOR_RIGHT", 0, 0)
		LFGListUtil_SetSearchEntryTooltip(GameTooltip, resultID, searchResultInfo.autoAccept and LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE)

		if(MIOG_NewSettings.enableResultFrameClassSpecTooltip) then
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

		if(MIOG_NewSettings.favouredApplicants[searchResultInfo.leaderName]) then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(searchResultInfo.leaderName .. " is on your favoured player list.")
		end

		local success, reasonID = miog.checkEligibility("LFGListFrame.SearchPanel", nil, resultID)
		local reason = miog.INELIGIBILITY_REASONS[reasonID]

		if(not success and reason) then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(WrapTextInColorCode(reason[1], miog.CLRSCC.red))

		end

		miog.checkEgoTrip(searchResultInfo.leaderName)

		GameTooltip:Show()
	end
end

miog.createResultTooltip = createResultTooltip

local function selectResultFrame(resultID)
	if(LFGListFrame.SearchPanel.selectedResult) then
		local oldResultID = LFGListFrame.SearchPanel.selectedResult

		if(searchResultSystem.baseFrames[LFGListFrame.SearchPanel.selectedResult]) then
			LFGListFrame.SearchPanel.selectedResult = nil
			setResultFrameColors(oldResultID)
		end
	end

	if(resultID ~= LFGListFrame.SearchPanel.selectedResult and searchResultSystem.baseFrames[resultID]) then
		searchResultSystem.baseFrames[resultID]:SetBackdropBorderColor(CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())

	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	LFGListSearchPanel_SelectResult(LFGListFrame.SearchPanel, resultID)
end

local function groupSignup(resultID)
	if(resultID and C_LFGList.HasSearchResultInfo(resultID) and (UnitIsGroupLeader("player") or not IsInGroup() or not IsInRaid())) then
		local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if (appStatus ~= "none" or pendingStatus or searchResultInfo.isDelisted) then
			return false
		end

		selectResultFrame(resultID)

		LFGListApplicationDialog_Show(LFGListApplicationDialog, resultID)
	end

end

miog.groupSignup = groupSignup

local function gatherSearchResultSortData(singleResultID)
	local unsortedMainApplicantsList = {}

	local total, resultTable = C_LFGList.GetFilteredSearchResults()

	local counter = 1

	for _, resultID in ipairs(singleResultID and {[1] = singleResultID} or resultTable) do
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if(searchResultInfo and not searchResultInfo.hasSelf) then
			--local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)

			local _, appStatus, _, appDuration = C_LFGList.GetApplicationInfo(resultID)

			--if(appStatus == "applied" or activityInfo.categoryID == LFGListFrame.SearchPanel.categoryID) then
				local primarySortAttribute, secondarySortAttribute

				local nameTable

				if(searchResultInfo.leaderName) then
					nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")
				end

				if(nameTable and not nameTable[2]) then
					nameTable[2] = GetNormalizedRealmName()
	
					if(nameTable[2]) then
						searchResultInfo.leaderName = nameTable[1] .. "-" .. nameTable[2]
	
					end
				end

				if(LFGListFrame.SearchPanel.categoryID ~= 3 and LFGListFrame.SearchPanel.categoryID ~= 4 and LFGListFrame.SearchPanel.categoryID ~= 7 and LFGListFrame.SearchPanel.categoryID ~= 8 and LFGListFrame.SearchPanel.categoryID ~= 9) then
					primarySortAttribute = searchResultInfo.leaderOverallDungeonScore or 0
					secondarySortAttribute = searchResultInfo.leaderDungeonScoreInfo and searchResultInfo.leaderDungeonScoreInfo.bestRunLevel or 0

				elseif(LFGListFrame.SearchPanel.categoryID == 3) then
					if(searchResultInfo.leaderName) then
						searchResultSystem.raidSortData[searchResultInfo.leaderName] = {miog.getRaidSortData(searchResultInfo.leaderName)}

						--primarySortAttribute = currentData[1].weight + currentData[2].weight + currentData[3].weight
						--secondarySortAttribute = nonCurrentData[1].weight + nonCurrentData[2].weight + nonCurrentData[3].weight

						primarySortAttribute = searchResultSystem.raidSortData[searchResultInfo.leaderName][3][1].weight
						secondarySortAttribute = searchResultSystem.raidSortData[searchResultInfo.leaderName][3][2].weight

						--if(currentData) then
							--secondarySortAttribute = currentData[2].weight

						--elseif(nonCurrentData) then
							--primarySortAttribute = nonCurrentData[1].weight

						--else
							--primarySortAttribute = 0
							--secondarySortAttribute = 0

						--end
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
					favoured = searchResultInfo.leaderName and MIOG_NewSettings.favouredApplicants[searchResultInfo.leaderName] and true or false
				}

				counter = counter + 1
			--end
		end

	end

	return unsortedMainApplicantsList
end

local function initializeSearchResultFrame(resultID)
	if(C_LFGList.HasSearchResultInfo(resultID)) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		local mapID = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].mapID

		local persistentFrame = framePool:Acquire()
		persistentFrame:SetFixedWidth(miog.SearchPanel.NewScrollFrame.Container:GetFixedWidth())
		searchResultSystem.baseFrames[resultID] = persistentFrame
		persistentFrame.InviteBackground:Hide()

		miog.createInvisibleFrameBorder(persistentFrame, 2)

		persistentFrame.framePool = persistentFrame.framePool or CreateFramePoolCollection()
		persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_SmallGroupMemberTemplate", resetFrame)
		persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_ResultFrameBossFrameTemplate", function(_, childFrame)
			childFrame:Hide()
			childFrame.layoutIndex = nil
		end)

		persistentFrame.framePool:ReleaseAll()
			
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

			if(#miog.MAP_INFO[mapID].bosses == 0) then
				miog.checkSingleMapIDForNewData(mapID)
			end

			for k, v in ipairs(miog.MAP_INFO[mapID].bosses) do
				--if(v.factionChecked) then
					local bossFrame = persistentFrame.framePool:Acquire("MIOG_ResultFrameBossFrameTemplate")
					bossFrame:SetParent(persistentFrame.CategoryInformation.BossPanel)
					bossFrame.layoutIndex = k

					SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, v.creatureDisplayInfoID)
					bossFrame.Border:SetColorTexture(CreateColorFromHexString(miog.CLRSCC.green):GetRGBA())

					bossFrame:Show()

					persistentFrame.CategoryInformation.BossPanel.bossFrames[k] = bossFrame
				--end
			end

			persistentFrame.CategoryInformation.BossPanel:MarkDirty()
		end

		persistentFrame.RaiderIOInformationPanel:Hide()

		return persistentFrame
	end
end

local function updatePersistentResultFrame(resultID, isInviteFrame)
	if(C_LFGList.HasSearchResultInfo(resultID)) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if(searchResultInfo.leaderName and searchResultSystem.baseFrames[resultID]) then

			local mapID = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].mapID

			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
			local currentFrame = searchResultSystem.baseFrames[resultID]
			currentFrame.resultID = resultID
			--local mapID = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].mapID
			local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
			local declineData = searchResultInfo.leaderName and MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID]
			local playerName, realm = miog.createSplitName(searchResultInfo.leaderName)

			local questTagInfo = searchResultInfo.questID and C_QuestLog.GetQuestTagInfo(searchResultInfo.questID)
			local questDesc = questTagInfo and questTagInfo.tagName
			local difficultyID = miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID
			local difficultyName = difficultyID and miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID ~= 0 and miog.DIFFICULTY_ID_INFO[difficultyID].shortName
			local shortName = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].shortName

			local difficultyZoneText = difficultyID and difficultyName or questDesc or nil

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
					MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID] = nil

				end
			else
				titleZoneColor = "FFFFFFFF"

			end

			currentFrame.CategoryInformation.DifficultyZone:SetText(wticc((difficultyZoneText and difficultyZoneText .. " - " or "") .. (shortName or activityInfo.fullName), titleZoneColor)
			)

			currentFrame.RaiderIOInformationPanel:OnLoad()
			currentFrame.RaiderIOInformationPanel:SetPlayerData(playerName, realm)
			currentFrame.RaiderIOInformationPanel:SetOptionalData(searchResultInfo.comment, realm)
			currentFrame.RaiderIOInformationPanel:ApplyFillData()

			miog.setInfoIndicators(currentFrame.BasicInformation, activityInfo.categoryID, searchResultInfo.leaderOverallDungeonScore, searchResultInfo.leaderDungeonScoreInfo, currentFrame.RaiderIOInformationPanel.raidData, searchResultInfo.leaderPvpRatingInfo)

			currentFrame:SetScript("OnMouseDown", function(self, button)
				if(button == "LeftButton") then
					groupSignup(self.resultID)

				else
					selectResultFrame(self.resultID)
					LFGListSearchEntry_CreateContextMenu(self)

				end

			end)
			currentFrame:SetScript("OnEnter", function(self)
				createResultTooltip(self.resultID, currentFrame)

			end)

			currentFrame.Background:SetTexture(miog.ACTIVITY_INFO[searchResultInfo.activityID].horizontal, "CLAMP", "MIRROR")
			currentFrame.Background:SetVertexColor(0.75, 0.75, 0.75, 0.4)

			if(not questTagInfo) then
				currentFrame.BasicInformation.Icon:SetTexture(miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].icon or nil)

			else
				currentFrame.BasicInformation.Icon:SetAtlas(QuestUtils_GetQuestTagAtlas(questTagInfo.tagID, questTagInfo.worldQuestType) or QuestUtil.GetWorldQuestAtlasInfo(searchResultInfo.questID, questTagInfo) or nil)

			end

			currentFrame.BasicInformation.Icon:SetScript("OnMouseDown", function()
				EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

			end)

			local color = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.DIFFICULTY_ID_TO_COLOR[miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID]
			or questTagInfo and {r = 0, g = 0, b = 0, a = 0}
			or {r = 1, g = 1, b = 1}

			currentFrame.BasicInformation.IconBorder:SetColorTexture(color.r, color.g, color.b, color.a or 1)

			currentFrame.CategoryInformation.ExpandFrame:SetScript("OnClick", function(self)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				
				currentFrame.CategoryInformation.ExpandFrame:AdvanceState()

				currentFrame.RaiderIOInformationPanel:SetShown(not currentFrame.RaiderIOInformationPanel:IsShown())

				currentFrame:MarkDirty()

				--currentFrame.node:ToggleCollapsed()

				--collapsedList[saveID] = currentFrame.node:IsCollapsed()
			end)

			if(currentFrame.BasicInformation.Age.ageTicker) then
				currentFrame.BasicInformation.Age.ageTicker:Cancel()

			end

			local ageNumber = searchResultInfo.age
			currentFrame.BasicInformation.Age:Show()
			currentFrame.BasicInformation.Age:SetText(miog.secondsToClock(ageNumber))
			currentFrame.BasicInformation.Age:SetTextColor(1, 1, 1, 1)
			currentFrame.BasicInformation.Age.ageTicker = C_Timer.NewTicker(1, function()
				ageNumber = ageNumber + 1
				currentFrame.BasicInformation.Age:SetText(miog.secondsToClock(ageNumber))

			end)

			local warmodeString = searchResultInfo.isWarMode and "|A:pvptalents-warmode-swords:12:12|a" or ""
			local bnetFriends = searchResultInfo.numBNetFriends > 0 and "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\battlenetfriend.png:14|t" or ""
			local charFriends = searchResultInfo.numCharFriends > 0 and "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\friend.png:14|t" or ""
			local guildFriends = searchResultInfo.numGuildMates > 0 and "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\guildmate.png:14|t" or ""

			currentFrame.BasicInformation.Title:SetText(warmodeString .. bnetFriends .. charFriends .. guildFriends .. wticc(searchResultInfo.name, titleZoneColor))
			currentFrame.CategoryInformation.Comment:SetShown(searchResultInfo.comment ~= "" and searchResultInfo.comment ~= nil and true or false)
			--currentFrame.RaiderIOInformationPanel.Comment:SetText(COMMENTS_COLON .. " " .. (searchResultInfo.comment or ""))

			currentFrame.AcceptInvite:Hide()
			currentFrame.CancelApplication:SetScript("OnClick", function(self, button)
				if(button == "LeftButton") then
					local _, appStatus = C_LFGList.GetApplicationInfo(searchResultInfo.searchResultID)

					if(appStatus == "applied") then
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
						C_LFGList.CancelApplication(searchResultInfo.searchResultID)

					end
				end
			end)

			updateResultFrameStatus(resultID)

			--local primaryIndicator = currentFrame.BasicInformation.Primary
			--local secondaryIndicator = currentFrame.BasicInformation.Secondary
			local nameTable
			
			if(searchResultInfo.leaderName) then
				nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")
			end

			if(nameTable and not nameTable[2]) then
				nameTable[2] = GetNormalizedRealmName()

				if(nameTable[2]) then
					searchResultInfo.leaderName = nameTable[1] .. "-" .. nameTable[2]

				end
			end

			local orderedList = {}

			local roleCount = {
				["TANK"] = 0,
				["HEALER"] = 0,
				["DAMAGER"] = 0,
			}

			for i = 1, searchResultInfo.numMembers, 1 do
				local role, class, _, specLocalized, isLeader = C_LFGList.GetSearchResultMemberInfo(searchResultInfo.searchResultID, i)

				table.insert(orderedList, {leader = isLeader, role = role, class = class, specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]})

				if(role) then
					roleCount[role] = roleCount[role] + 1

				end
			end

			local groupLimit = activityInfo.maxNumPlayers == 0 and 5 or activityInfo.maxNumPlayers

			local memberPanel = currentFrame.CategoryInformation.MemberPanel
			local bossPanel = currentFrame.CategoryInformation.BossPanel

			memberPanel:SetShown(activityInfo.categoryID ~= 3)
			bossPanel:SetShown(activityInfo.categoryID == 3 and miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID and miog.ACTIVITY_INFO[searchResultInfo.activityID].difficultyID > 0)
			currentFrame.CategoryInformation.DifficultyZone:SetWidth(activityInfo.categoryID ~= 3 and 100 or LFGListFrame.SearchPanel.filters == Enum.LFGListFilter.NotRecommended and 60 or 140)

			currentFrame.CategoryInformation.RoleComposition:SetText("[" .. roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"] .. "]")

			if(activityInfo.categoryID == 3) then
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

				end
			end

			if(activityInfo.categoryID ~= 3) then
				for i = 1, 1, 1 do
					if(roleCount["TANK"] < 1 and searchResultInfo.numMembers < groupLimit) then
						table.insert(orderedList, {class = "DUMMY", role = "TANK", specID = 20})
					end
				end

				for i = 2, 2, 1 do
					if(roleCount["HEALER"] < 1 and searchResultInfo.numMembers < groupLimit) then
						table.insert(orderedList, {class = "DUMMY", role = "HEALER", specID = 20})
						roleCount["HEALER"] = roleCount["HEALER"] + 1

					end
				end

				for i = 3, 5, 1 do
					if(roleCount["DAMAGER"] < 3 and searchResultInfo.numMembers < groupLimit) then
						table.insert(orderedList, {class = "DUMMY", role = "DAMAGER", specID = 20})
						roleCount["DAMAGER"] = roleCount["DAMAGER"] + 1
					end
				end

				local function isDummy(class)
					return class == "DUMMY"
				end

				table.sort(orderedList, function(k1, k2)
					if(k1 and k2) then
						if k1.role ~= k2.role then
							return k1.role > k2.role
						end
					
						if isDummy(k1.class) and not isDummy(k2.class) then
							return false
						elseif isDummy(k2.class) and not isDummy(k1.class) then
							return true
						end
					
						if k1.spec ~= k2.spec then
							return k1.spec > k2.spec
						end
					
						return k1.class > k2.class

					else
						return false

					end
				end)

				for i = 1, 5, 1 do
					if(i <= groupLimit) then
						local currentMemberFrame = memberPanel[tostring(i)]

						currentMemberFrame.Icon:SetTexture(orderedList[i].specID and miog.SPECIALIZATIONS[orderedList[i].specID] and miog.SPECIALIZATIONS[orderedList[i].specID].squaredIcon or
						orderedList[i].class and miog.CLASSFILE_TO_ID[orderedList[i].class] and miog.CLASSES[miog.CLASSFILE_TO_ID[orderedList[i].class]].icon)

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
								GameTooltip:SetOwner(currentMemberFrame, "ANCHOR_RIGHT")
								GameTooltip:AddLine(format(_G["LFG_LIST_TOOLTIP_LEADER"], searchResultInfo.leaderName))
								GameTooltip:Show()

							end)
						else
							currentMemberFrame:SetScript("OnEnter", nil)

						end

						memberPanel[tostring(i)]:Show()

					else
						memberPanel[tostring(i)]:Hide()

					end
				end
			end
			
			updateResultFrameStatus(resultID)
		end
	end
end

miog.updatePersistentResultFrame = updatePersistentResultFrame

local function newUpdateFunction()
	framePool:ReleaseAll()

	local unsortedList = gatherSearchResultSortData()

	miog.SearchPanel:UpdateSortingData(unsortedList)
	miog.SearchPanel:Sort()

	local actualResultsCounter = 0

	for d, listEntry in ipairs(miog.SearchPanel:GetSortingData()) do
		local showFrame, reasonID = listEntry.appStatus == "applied" or miog.checkEligibility("LFGListFrame.SearchPanel", nil, listEntry.resultID)

		if(showFrame) then

			local frame = initializeSearchResultFrame(listEntry.resultID)
			frame.layoutIndex = d
			frame:SetParent(miog.SearchPanel.NewScrollFrame.Container)
			frame:Show()

			updatePersistentResultFrame(listEntry.resultID)

			actualResultsCounter = actualResultsCounter + 1

		end

	end

	miog.SearchPanel.NewScrollFrame.Container:MarkDirty()

	miog.SearchPanel.NewScrollFrame.ScrollBar:ScrollToBegin()

	--[[local DataProvider = CreateTreeDataProvider()
	DataProvider:SetSortComparator(sortSearchResultList, false)

	local actualResultsCounter = 0

	for i = 1, #orderedList, 1 do
		local listEntry = orderedList[i]
		local showFrame = listEntry.appStatus == "applied" or isGroupEligible(listEntry.resultID)

		if(showFrame) then
			actualResultsCounter = actualResultsCounter + 1

			local baseFrameData = DataProvider:Insert({
				template = "MIOG_SearchResultFrameTemplate",
				resultID = listEntry.resultID,
				primary = listEntry.primary,
				appStatus = listEntry.appStatus,
				secondary = listEntry.secondary,
				age = listEntry.age,
				favoured = listEntry.favoured
			})

			baseFrameData:Insert({
				template = "MIOG_RaiderIOInformationPanel",
				resultID = listEntry.resultID,
			})
		end
	end

	miog.SearchPanel.ScrollView:SetDataProvider(DataProvider)

	DataProvider:CollapseAll()

	for index, child in ipairs(DataProvider.node.nodes) do
		if(C_LFGList.HasSearchResultInfo(child.data.resultID)) then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(child.data.resultID)

			if(searchResultInfo.leaderName) then
				local saveID = searchResultInfo.activityID .. searchResultInfo.leaderName

				if(collapsedList[saveID] == false) then
					child:SetCollapsed(false)

					for index2, child2 in ipairs(child.nodes) do
						child2:SetCollapsed(false)

					end
				end
			end
		end
	end]]

	miog.Plugin.FooterBar.Results:SetText(actualResultsCounter .. "(" .. #miog.SearchPanel:GetSortingData() .. ")")
	
	miog.Plugin.FooterBar.Results:SetScript("OnEnter", #miog.SearchPanel:GetSortingData() >= 100 and function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("There might be more groups listed.")
		GameTooltip:AddLine("Try to pre-filter by typing something in the search bar.")
		GameTooltip:Show()
	end or nil)

	miog.Plugin.FooterBar.Results:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

miog.newUpdateFunction = newUpdateFunction

local blocked = false

local function searchResultsReceived()
	miog.SearchPanel.Status:Show()
	miog.SearchPanel.Status.FontString:Hide()
	miog.SearchPanel.Status.LoadingSpinner:Show()

	local numOfResults, table = C_LFGList.GetFilteredSearchResults()

	LFGListFrame.SearchPanel.totalResults = numOfResults or 0
	LFGListFrame.SearchPanel.results = table or {}
	miog.SearchPanel.totalResults = numOfResults or 0
	miog.SearchPanel.results = table or {}

	--if(not LFGListFrame.SearchPanel.searching) then
		if(LFGListFrame.SearchPanel.totalResults > 0) then
			if(not blocked) then
				blocked = true

				C_Timer.After(miog.SearchPanel:GetNumOfActiveSortMethods() > 0 and 0.5 or 0, function()
					miog.SearchPanel.Status:Hide()
					miog.SearchPanel.Status.LoadingSpinner:Hide()
					newUpdateFunction()
					blocked = false
				end)
			end
		else
			if(not miog.F.SEARCH_IS_THROTTLED) then
				miog.SearchPanel.Status.LoadingSpinner:Hide()
				miog.SearchPanel.Status.FontString:SetText(LFGListFrame.SearchPanel.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND)
				miog.SearchPanel.Status.FontString:Show()

				if(LFGListFrame.SearchPanel.searchFailed) then
					miog.SearchPanel.ScrollView:GetDataProvider():Flush()
					miog.Plugin.FooterBar.Results:SetText("0(0)")
				end

			end
		end
	--end
end
	
local function Initializer(frame, node)
	local data = node:GetData()

	--frame:SetShown(data.visibility)

	if(data.template == "MIOG_SearchResultFrameTemplate") then
		frame.node = node

		frame.resultID = data.resultID

		initializeSearchResultFrame(frame, data.resultID)
		updatePersistentResultFrame(data.resultID)

	elseif(data.template == "MIOG_RaiderIOInformationPanel") then
		searchResultSystem.raiderIOPanels[data.resultID] = {RaiderIOInformationPanel = frame}
		
		if(C_LFGList.HasSearchResultInfo(data.resultID)) then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(data.resultID)

			if(searchResultInfo.leaderName) then
				local playerName, realm = miog.createSplitName(searchResultInfo.leaderName)
			end
		end
	end
end

local function searchPanelEvents(_, event, ...)
	if(event == "PLAYER_LOGIN") then

	elseif(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
		searchResultsReceived()

	elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then --update to title, ilvl, group members, etc
		if(C_LFGList.HasSearchResultInfo(...)) then
			updatePersistentResultFrame(...)
			
		end
	elseif(event == "LFG_LIST_SEARCH_FAILED") then

		if(... == "throttled") then
			if(not miog.F.SEARCH_IS_THROTTLED) then
				miog.F.SEARCH_IS_THROTTLED = true
				local timestamp = GetTime()

				miog.SearchPanel.Status.FontString:Hide()
				miog.SearchPanel.Status.LoadingSpinner:Hide()
				miog.SearchPanel.StartSearch:Disable()
				miog.SearchPanel.Status.FontString:SetText("Time until search is available again: " .. miog.secondsToClock(timestamp + 3 - GetTime()))

				C_Timer.NewTicker(0.25, function(self)
					local timeUntil = timestamp + 2.5 - GetTime()
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
		
		miog.increaseStatistic(new)

		updateSearchResultFrameApplicationStatus(resultID, new, old)

		if(not miog.F.LITE_MODE and new == "inviteaccepted") then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)

			local lastGroup = miog.ACTIVITY_INFO[searchResultInfo.activityID].name or activityInfo.fullName
			miog.MainTab.QueueInformation.LastGroup.Text:SetText(lastGroup)

			MIOG_NewSettings.lastGroup = lastGroup
		end

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS") then

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TIMEOUT") then
	end
end

miog.createSearchPanel = function()
	local searchPanel = CreateFrame("Frame", "MythicIOGrabber_SearchPanel", miog.Plugin.InsertFrame, "MIOG_SearchPanel") ---@class Frame

	searchPanel.SignUpButton:SetPoint("LEFT", miog.Plugin.FooterBar.Back, "RIGHT")
	searchPanel.SignUpButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		if(LFGListFrame.SearchPanel.selectedResult and C_LFGList.HasSearchResultInfo(LFGListFrame.SearchPanel.selectedResult)) then
			LFGListApplicationDialog_Show(LFGListApplicationDialog, LFGListFrame.SearchPanel.selectedResult)

			miog.groupSignup(LFGListFrame.SearchPanel.selectedResult)
		end
	end)

	local searchBox = LFGListFrame.SearchPanel.SearchBox
	searchBox:ClearAllPoints()
	searchBox:SetParent(searchPanel)

	searchPanel.standardSearchBoxWidth = LFGListFrame.SearchPanel.SearchBox:GetWidth()
	LFGListFrame.SearchPanel.FilterButton:Hide()

	if(not miog.F.LITE_MODE) then
		LFGListFrame.SearchPanel.SearchBox:SetSize(searchPanel.SearchBoxBase:GetSize())

	else
		LFGListFrame.SearchPanel.SearchBox:SetWidth(searchPanel.standardSearchBoxWidth - 100)

	end

	LFGListFrame.SearchPanel.SearchBox:SetPoint(searchPanel.SearchBoxBase:GetPoint())
	LFGListFrame.SearchPanel.SearchBox:SetFrameStrata("HIGH")
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
	end)

	--miog.createFrameBorder(searchPanel.ButtonPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	--[[searchPanel.ButtonPanel.sortByCategoryButtons = {}

	for i = 1, 3, 1 do
		local sortByCategoryButton = searchPanel.ButtonPanel[i == 1 and "PrimarySort" or i == 2 and "SecondarySort" or "AgeSort"]
		sortByCategoryButton.panel = "LFGListFrame.SearchPanel"
		sortByCategoryButton.category = i == 1 and "primary" or i == 2 and "secondary" or i == 3 and "age"

		sortByCategoryButton:SetScript("PostClick", function(self, button)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

			--local dataProvider = miog.SearchPanel.ScrollView:GetDataProvider()

			--dataProvider:Sort()
			--dataProvider:SetAllCollapsed(true)

			table.sort(currentDataList, sortSearchResultList)

			local orderedResultIDList = {}

			for k, v in ipairs(currentDataList) do
				orderedResultIDList[v.resultID] = k
			end

			for widget in framePool:EnumerateActive() do
				widget.layoutIndex = orderedResultIDList[widget.resultID]

			end

			miog.SearchPanel.NewScrollFrame.Container:MarkDirty()
		end)

		searchPanel.ButtonPanel.sortByCategoryButtons[sortByCategoryButton.category] = sortByCategoryButton

	end

	searchPanel.ButtonPanel["PrimarySort"]:AdjustPointsOffset(176, 0)]]

	LFGListFrame.SearchPanel.results = {}
	LFGListFrame.SearchPanel.applications = {}

	searchPanel:SetScript("OnEvent", searchPanelEvents)
	searchPanel:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	searchPanel:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	searchPanel:RegisterEvent("LFG_LIST_SEARCH_FAILED")
	searchPanel:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT")
	searchPanel:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS")
	searchPanel:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

	framePool = CreateFramePool("Frame", searchPanel.NewScrollFrame, "MIOG_SearchResultFrameTemplate", resetFrame)

	searchPanel.NewScrollFrame.Container:SetFixedWidth(searchPanel.NewScrollFrame:GetWidth())
	searchPanel.NewScrollFrame.ScrollBar:AdjustPointsOffset(-8, 0)
	
	local function performantSort()
		--table.sort(currentDataList, sortSearchResultList)
		searchPanel:Sort()

		local orderedResultIDList = {}

		for k, v in ipairs(searchPanel:GetSortingData()) do
			orderedResultIDList[v.resultID] = k
		end

		for widget in framePool:EnumerateActive() do
			widget.layoutIndex = orderedResultIDList[widget.resultID]

		end

		miog.SearchPanel.NewScrollFrame.Container:MarkDirty()
	end

	searchPanel:OnLoad(performantSort)
	searchPanel:SetSettingsTable(MIOG_NewSettings.sortMethods["LFGListFrame.SearchPanel"])
	searchPanel:AddMultipleSortingParameters({
		{name = "primary", padding = 175},
		{name = "secondary", padding = 18},
		{name = "age", padding = 35},
	})

	--[[local ScrollView = CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 2)

	miog.SearchPanel.ScrollView = ScrollView
	
	ScrollUtil.InitScrollBoxListWithScrollBar(miog.SearchPanel.ScrollBox2, miog.SearchPanel.ScrollBar, ScrollView)
	
	local function CustomFactory(factory, node)
		local data = node:GetData()
		local template = data.template
		factory(template, Initializer)
	end

	ScrollView:SetElementFactory(CustomFactory)]]

	return searchPanel
end

hooksecurefunc("LFGListSearchPanel_SetCategory", function()
	miog.SearchPanel.categoryID = LFGListFrame.SearchPanel.categoryID
	miog.SearchPanel.filters = LFGListFrame.SearchPanel.filters
	miog.SearchPanel.preferredFilters = LFGListFrame.SearchPanel.preferredFilters
end)