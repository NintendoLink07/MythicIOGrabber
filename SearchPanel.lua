local addonName, miog = ...
local wticc = WrapTextInColorCode

local formatter = CreateFromMixins(SecondsFormatterMixin)
formatter:SetStripIntervalWhitespace(true)
formatter:Init(0, SecondsFormatter.Abbreviation.None)

local currentlySelectedID

local function findFrame(resultID)
	local frame = miog.SearchPanel.ScrollBox2:FindFrameByPredicate(function(localFrame, node)
		return node.data.resultID == resultID
	end)

	return frame
end

local function setScrollBoxFrameColors(resultFrame, resultID)
	if(resultFrame and C_LFGList.HasSearchResultInfo(resultID)) then
		local isEligible, reasonID = miog.filter.checkIfSearchResultIsEligible(resultID)
		--local reason = miog.INELIGIBILITY_REASONS[reasonID]
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

local function updateScrollBoxFrameApplicationStatus(resultFrame, resultID, new, old)
	if(resultFrame) then
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

miog.updateScrollBoxFrameApplicationStatus = updateScrollBoxFrameApplicationStatus

local function updateScrollBoxFrameStatus(resultFrame, resultID)
	resultFrame.StatusFrame:Hide()

	if(updateScrollBoxFrameApplicationStatus(resultFrame, resultID) == false) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		resultFrame.CancelApplication:Hide()

		if(searchResultInfo.isDelisted) then
			if(resultFrame.BasicInformation.Age.ageTicker) then
				resultFrame.BasicInformation.Age.ageTicker:Cancel()

			end

			resultFrame.StatusFrame:Show()
			resultFrame.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO["declined_delisted"].statusString, miog.APPLICANT_STATUS_INFO["declined_delisted"].color))
		end
	end

	setScrollBoxFrameColors(resultFrame, resultID)
end

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
		GameTooltip:AddLine(C_LFGList.GetActivityFullName(searchResultInfo.activityIDs[1], nil, searchResultInfo.isWarMode))

		if(MIOG_NewSettings.favouredApplicants[searchResultInfo.leaderName]) then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(searchResultInfo.leaderName .. " is on your favoured player list.")
		end

		local success, reasonID = miog.filter.checkIfSearchResultIsEligible(resultID)
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
	if(currentlySelectedID) then
		local oldFrame = findFrame(currentlySelectedID)

		if(oldFrame) then
			setScrollBoxFrameColors(oldFrame, currentlySelectedID)
			currentlySelectedID = nil
		end
	end

	local newFrame = findFrame(resultID)

	if(newFrame) then
		newFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())
		currentlySelectedID = resultID
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

local function groupSignup(resultID)
	if(resultID and C_LFGList.HasSearchResultInfo(resultID) and (UnitIsGroupLeader("player") or not IsInGroup() or not IsInRaid())) then
		local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if (appStatus ~= "none" or pendingStatus or searchResultInfo.isDelisted) then
			return false
		end
	end
end

local function createDataProviderWithUnsortedData()
	local treeDataProvider = CreateTreeDataProvider()
	local actualResults, resultTable = C_LFGList.GetFilteredSearchResults()

	local numOfFiltered = 0

	for _, resultID in ipairs(resultTable) do
		if(C_LFGList.HasSearchResultInfo(resultID)) then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

			if(searchResultInfo and not searchResultInfo.hasSelf) then
				local _, appStatus = C_LFGList.GetApplicationInfo(resultID)

				local status, reason =  miog.filter.checkIfSearchResultIsEligible(resultID)
				
				if(appStatus == "applied" or status ~= false) then
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
						secondarySortAttribute = searchResultInfo.leaderDungeonScoreInfo and searchResultInfo.leaderDungeonScoreInfo[1] and searchResultInfo.leaderDungeonScoreInfo[1].bestRunLevel or 0

					elseif(LFGListFrame.SearchPanel.categoryID == 3) then
						if(searchResultInfo.leaderName) then
							local raidData = miog.getNewRaidSortData(nameTable[1], nameTable[2])

							primarySortAttribute = raidData.character.ordered[1].weight or 0
							secondarySortAttribute = raidData.character.ordered[2].weight or 0

						else
							primarySortAttribute = 0
							secondarySortAttribute = 0

						end

					elseif(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7 or LFGListFrame.SearchPanel.categoryID == 8 or LFGListFrame.SearchPanel.categoryID == 9) then
						primarySortAttribute = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0
						secondarySortAttribute = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0

					end

					local mainFrame = treeDataProvider:Insert(
						{
							template = "MIOG_SearchPanelResultFrameTemplate",
							name = searchResultInfo.leaderName,
							primary = primarySortAttribute,
							appStatus = appStatus,
							secondary = secondarySortAttribute,
							index = resultID,
							resultID = resultID,
							age = searchResultInfo.age,
							favoured = searchResultInfo.leaderName and MIOG_NewSettings.favouredApplicants[searchResultInfo.leaderName] and true or false
						}
					)

					mainFrame:Insert({
						template = "MIOG_NewRaiderIOInfoPanel",
						resultID = resultID,
					})

					numOfFiltered = numOfFiltered + 1

				end
			end
		end
	end

	return treeDataProvider, numOfFiltered, actualResults
end

local function addOneTimeFrames(frame)
	frame:SetScript("OnEnter", function(self)
		createResultTooltip(self.resultID, frame)

	end)

	frame:SetBackdrop({edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 2})

end

local function resetScrollBoxFrame(frame)
	frame.CategoryInformation.ExpandFrame:SetState(false)
	frame.CancelApplication:OnLoad()

	for i = 1, 20, 1 do
		local bossFrame = frame.CategoryInformation.BossPanel["Boss" .. i]

		bossFrame:Hide()
		bossFrame.name = nil
		bossFrame.altName = nil
	end
end

local questColor, basicColor = {r = 0, g = 0, b = 0, a = 0}, {r = 1, g = 1, b = 1}

local function updateOptionalScrollBoxFrameData(frame, data)
	if(C_LFGList.HasSearchResultInfo(data.resultID)) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(data.resultID)

		if(searchResultInfo.leaderName) then
			local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])
			local isQuestCategory = activityInfo.categoryID == 1
			local declineData = searchResultInfo.leaderName and MIOG_NewSettings.declinedGroups[searchResultInfo.partyGUID]
			local questTagInfo = searchResultInfo.questID and C_QuestLog.GetQuestTagInfo(searchResultInfo.questID)
			local questDesc = questTagInfo and questTagInfo.tagName
			local difficultyID = activityInfo.difficultyID
			local difficultyName = difficultyID and activityInfo.difficultyID ~= 0 and miog.DIFFICULTY_ID_INFO[difficultyID].shortName
			local shortName = activityInfo.abbreviatedName

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

			frame.CategoryInformation.DifficultyZone:SetText(wticc((difficultyZoneText and difficultyZoneText .. " - " or "") .. (shortName or activityInfo.fullName), titleZoneColor))

			if(isQuestCategory and questTagInfo) then
				frame.BasicInformation.Icon:SetAtlas(QuestUtils_GetQuestTagAtlas(questTagInfo.tagID, questTagInfo.worldQuestType) or QuestUtil.GetWorldQuestAtlasInfo(searchResultInfo.questID, questTagInfo) or nil)

			else
				frame.BasicInformation.Icon:SetTexture(activityInfo.icon)

			end
			
			local color = miog.DIFFICULTY_ID_TO_COLOR[difficultyID] or questTagInfo and questColor or basicColor

			frame.BasicInformation.IconBorder:SetColorTexture(color.r, color.g, color.b, color.a or 1)

			local strings = {}

			if(searchResultInfo.isWarMode) then
				tinsert(strings, "|A:pvptalents-warmode-swords:12:12|a")

			end

			if(searchResultInfo.numBNetFriends > 0) then
				tinsert(strings, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\battlenetfriend.png:14|t")

			end

			if(searchResultInfo.numCharFriends > 0) then
				tinsert(strings, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\friend.png:14|t")

			end

			if(searchResultInfo.numGuildMates > 0) then
				tinsert(strings, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\guildmate.png:14|t")

			end

			tinsert(strings, wticc(searchResultInfo.name, titleZoneColor))

			frame.BasicInformation.Title:SetText(table.concat(strings))
			
			local playerName, realm = miog.createSplitName(searchResultInfo.leaderName)

			miog.setInfoIndicators(frame.BasicInformation, activityInfo.categoryID, searchResultInfo.leaderOverallDungeonScore, searchResultInfo.leaderDungeonScoreInfo[1], miog.getNewRaidSortData(playerName, realm), searchResultInfo.leaderPvpRatingInfo)
		end
	end
end

local function isDummy(class)
	return class == "DUMMY"
end

local function sortSmallPvpGroup(k1, k2)
	if(k1 and k2) then
		if isDummy(k1.class) then
			return false

		elseif isDummy(k2.class) then
			return true

		end

		if k1.role ~= k2.role then
			return k1.role > k2.role
		end
	
		if k1.spec ~= k2.spec then
			return k1.spec > k2.spec

		end
	
		return k1.class > k2.class

	else
		return false

	end
end

local function sortSmallGroup(k1, k2)
	if k1.role ~= k2.role then
		return k1.role > k2.role
	end

	if k1.class == "DUMMY" or k2.class == "DUMMY" then
		return false

	end

	if k1.spec ~= k2.spec then
		return k1.spec > k2.spec

	end

	return k1.class > k2.class
end

local function retrieveEncounterStatus(resultID)
	local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(resultID)
	local encountersDefeated = {}

	if(encounterInfo) then
		for _, v in ipairs(encounterInfo) do
			encountersDefeated[v] = true

		end
	end

	return encountersDefeated
end

local function refreshBossTextures1(mapInfo, resultID, bossPanel)
	local bossData = mapInfo.bosses
	local bossNum = mapInfo.numOfBosses
	local frameIndex = 20
	
	local encountersDefeated = retrieveEncounterStatus(resultID)

	for i = 1, bossNum, 1 do
		local bossFrame = bossPanel["Boss" .. frameIndex]
		local bossInfo = bossData[i]

		local bossDefeated = encountersDefeated[bossInfo.name] or encountersDefeated[bossInfo.altName]

		bossFrame.Icon:SetDesaturated(bossDefeated)
		bossFrame.Border:SetColorTexture(CreateColorFromHexString(bossDefeated and miog.CLRSCC.red or miog.CLRSCC.green):GetRGBA())

		SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, bossInfo.creatureDisplayInfoID)
		bossFrame:Show()

		frameIndex = frameIndex - 1
	end

	for i = frameIndex, 1, -1 do
		local bossFrame = bossPanel["Boss" .. i]
		bossFrame:Hide()
	end
end

local function refreshBossTextures2(mapInfo, resultID, bossPanel)
	local bossData = mapInfo.bosses
	local bossCounter = 1
	
	local encountersDefeated = retrieveEncounterStatus(resultID)

	for i = 20, 1, -1 do
		local bossFrame = bossPanel["Boss" .. i]
		local bossInfo = bossData[mapInfo.numOfBosses - bossCounter + 1]

		if(bossInfo) then
			local bossDefeated = encountersDefeated[bossInfo.name] or encountersDefeated[bossInfo.altName]

			bossFrame.Icon:SetDesaturated(bossDefeated)
			bossFrame.Border:SetColorTexture(CreateColorFromHexString(bossDefeated and miog.CLRSCC.red or miog.CLRSCC.green):GetRGBA())

			SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, bossInfo.creatureDisplayInfoID)
			bossFrame:Show()

			bossCounter = bossCounter + 1

		else
			bossFrame:Hide()

		end
	end
end

local function updateScrollBoxFrame(frame, data)
	if(C_LFGList.HasSearchResultInfo(data.resultID)) then

		local searchResultInfo = C_LFGList.GetSearchResultInfo(data.resultID)
		local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])
		local mapID = activityInfo.mapID
		local currentFrame = frame
		local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
		currentFrame.resultID = data.resultID
		
		currentFrame.Background:SetTexture(activityInfo.horizontal, "CLAMP", "MIRROR")
		currentFrame.difficultyID = activityInfo.difficultyID
		currentFrame.instanceID = instanceID

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

		currentFrame.CategoryInformation.Comment:SetShown(searchResultInfo.comment ~= "")

		local categoryID = activityInfo.categoryID
		local isRaid = categoryID == 3
		local isPvE = categoryID == 1 or categoryID == 2 or categoryID == 6 or categoryID == 121

		local memberPanel = currentFrame.CategoryInformation.MemberPanel
		memberPanel:SetShown(not isRaid)

		local bossPanel = currentFrame.CategoryInformation.BossPanel
		bossPanel:SetShown(isRaid and activityInfo.difficultyID and activityInfo.difficultyID > 0)

		local roleCount = {
			["TANK"] = 0,
			["HEALER"] = 0,
			["DAMAGER"] = 0,
		}

		if(isRaid) then
			for i = 1, searchResultInfo.numMembers, 1 do
				local role = C_LFGList.GetSearchResultMemberInfo(data.resultID, i)

				if(role) then
					roleCount[role] = roleCount[role] + 1

				end
			end

			local mapInfo = miog.getMapInfo(mapID, true)

			if(mapInfo) then
				local bossData = mapInfo.bosses
				
				local encountersDefeated = retrieveEncounterStatus(data.resultID)

				local bossIndex = mapInfo.numOfBosses - 1 + 1

				for i = 20, 1, -1 do
					local bossFrame = bossPanel["Boss" .. i]
					local bossInfo = bossData[bossIndex]

					if(bossInfo) then
						local bossDefeated = encountersDefeated[bossInfo.name] or encountersDefeated[bossInfo.altName]

						bossFrame.Icon:SetDesaturated(bossDefeated)
						bossFrame.Border:SetColorTexture((bossDefeated and miog.CLRSCC.colors.red or miog.CLRSCC.colors.green):GetRGBA())

						SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, bossInfo.creatureDisplayInfoID)
						bossFrame:Show()

						bossIndex = bossIndex - 1
						

					else
						bossFrame:Hide()

					end
				end

			end
		else
			local memberList = {}
			local groupLimit = activityInfo.maxNumPlayers == 0 and 5 or activityInfo.maxNumPlayers

			for i = 1, 5, 1 do --max is num of group icons
				local info = C_LFGList.GetSearchResultPlayerInfo(data.resultID, i);

				if(info) then
					if(info.assignedRole or info.classFilename) then
						table.insert(memberList, {leader = info.isLeader, role = info.assignedRole, class = info.classFilename, specID = info.classFilename and info.specName and miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[info.specName .. "-" .. info.classFilename]})

						if(info.assignedRole) then
							roleCount[info.assignedRole] = roleCount[info.assignedRole] + 1

						end
					end
				else
					if(roleCount["TANK"] < 1) then
						tinsert(memberList, {class = "DUMMY", role = "TANK", specID = 20})

					end

					if(roleCount["HEALER"] < 1) then
						table.insert(memberList, {class = "DUMMY", role = "HEALER", specID = 20})

					end

					for _ = 3, 5, 1 do
						if(roleCount["DAMAGER"] < 3) then
							table.insert(memberList, {class = "DUMMY", role = "DAMAGER", specID = 20})
							
						end
					end
				end
			end

			table.sort(memberList, isPvE and sortSmallGroup or sortSmallPvpGroup)

			for i = 1, 5, 1 do
				local currentMemberFrame = memberPanel.memberFrames[i]
				local underLimit = i <= groupLimit
					
				if(underLimit) then
					local memberData = memberList[i]

					currentMemberFrame.Icon:SetTexture(memberData.specID and miog.SPECIALIZATIONS[memberData.specID] and miog.SPECIALIZATIONS[memberData.specID].squaredIcon or
					memberData.class and miog.CLASSFILE_TO_ID[memberData.class] and miog.CLASSES[miog.CLASSFILE_TO_ID[memberData.class]].icon)

					if(memberData.class ~= "DUMMY") then
						currentMemberFrame.Border:SetColorTexture(C_ClassColor.GetClassColor(memberData.class):GetRGBA())

					else
						currentMemberFrame.Border:SetColorTexture(0, 0, 0, 0)

					end

					if(memberData.leader) then
						memberPanel.LeaderCrown:ClearAllPoints()
						memberPanel.LeaderCrown:SetParent(currentMemberFrame)
						memberPanel.LeaderCrown:SetPoint("CENTER", currentMemberFrame, "TOP")
						memberPanel.LeaderCrown:Show()

						currentMemberFrame.leaderName = searchResultInfo.leaderName

					else
						currentMemberFrame.leaderName = nil

					end
				end
				
				currentMemberFrame:SetShown(underLimit)
			end
		end

		currentFrame.BasicInformation.RoleComposition:SetText("[" .. roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"] .. "]")

		updateOptionalScrollBoxFrameData(frame, data)
		updateScrollBoxFrameStatus(frame, data.resultID)
	end
end

local function showStatusOverlay(status)
	miog.SearchPanel.Status:Show()
	miog.SearchPanel.Status.LoadingSpinner:Hide()

	if(status == "throttled") then
		miog.SearchPanel.StartSearch:Disable()

		local timestamp = GetTime()
		miog.SearchPanel.Status.FontString:SetText("Time until search is available again: " .. miog.secondsToClock(timestamp + 3 - GetTime()))

		C_Timer.NewTicker(0.2, function(self)
			local timeUntil = timestamp + 3 - GetTime()
			miog.SearchPanel.Status.FontString:SetText("Time until search is available again: " .. wticc(miog.secondsToClock(timeUntil), timeUntil > 2 and miog.CLRSCC.red or timeUntil > 1 and miog.CLRSCC.orange or miog.CLRSCC.yellow))

			if(timeUntil <= 0) then
				miog.SearchPanel.StartSearch:Enable()
				miog.SearchPanel.Status.FontString:SetText(wticc("Search is available again!", miog.CLRSCC.green))
				self:Cancel()
			end
		end)
	else
		miog.SearchPanel.Status.FontString:SetText(LFGListFrame.SearchPanel.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND)
		miog.SearchPanel.ScrollBox:Flush()
		miog.Plugin.FooterBar.Results:SetText("0(0)")
	end
	
	miog.SearchPanel.Status.FontString:Show()
end

local function getSortCriteriaForSearchResult(resultID)
	local table

	if(C_LFGList.HasSearchResultInfo(resultID)) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if(searchResultInfo) then
			local _, appStatus = C_LFGList.GetApplicationInfo(resultID)
			local primarySortAttribute, secondarySortAttribute

			if(LFGListFrame.SearchPanel.categoryID ~= 3 and LFGListFrame.SearchPanel.categoryID ~= 4 and LFGListFrame.SearchPanel.categoryID ~= 7 and LFGListFrame.SearchPanel.categoryID ~= 8 and LFGListFrame.SearchPanel.categoryID ~= 9) then
				primarySortAttribute = searchResultInfo.leaderOverallDungeonScore or 0
				secondarySortAttribute = searchResultInfo.leaderDungeonScoreInfo and searchResultInfo.leaderDungeonScoreInfo[1] and searchResultInfo.leaderDungeonScoreInfo[1].bestRunLevel or 0

			elseif(LFGListFrame.SearchPanel.categoryID == 3) then
				if(searchResultInfo.leaderName) then
					local nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")

					if(nameTable and not nameTable[2]) then
						nameTable[2] = GetNormalizedRealmName()

					end

					local raidData = miog.getNewRaidSortData(nameTable[1], nameTable[2])

					primarySortAttribute = raidData.character.ordered[1].weight or 0
					secondarySortAttribute = raidData.character.ordered[2].weight or 0

				else
					primarySortAttribute = 0
					secondarySortAttribute = 0

				end

			elseif(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7 or LFGListFrame.SearchPanel.categoryID == 8 or LFGListFrame.SearchPanel.categoryID == 9) then
				primarySortAttribute = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0
				secondarySortAttribute = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating or 0

			end

			table = {
				primary = primarySortAttribute,
				appStatus = appStatus,
				secondary = secondarySortAttribute,
				index = resultID,
				resultID = resultID,
				age = searchResultInfo.age,
				favoured = searchResultInfo.leaderName and MIOG_NewSettings.favouredApplicants[searchResultInfo.leaderName] and true or false
			}
		end
	end

	return table
end

local function fullyUpdateSearchPanel()
	miog.SearchPanel.Status:Hide()

	local treeDataProvider, numOfFiltered, actualResults  = createDataProviderWithUnsortedData()

	local sortBarList = miog.SearchPanel:GetOrderedParameters()

	local orderedListLen = #sortBarList

	treeDataProvider:SetAllCollapsed(true)
	--[[treeDataProvider:SetSortComparator(function(n1, n2)
		local resultID1 = n1.data.resultID
		local resultID2 = n2.data.resultID

		local k1 = getSortCriteriaForSearchResult(resultID1)
		local k2 = getSortCriteriaForSearchResult(resultID2)

		if(k1.appStatus == "applied" and k2.appStatus ~= "applied") then
			return true

		elseif(k2.appStatus == "applied" and k1.appStatus ~= "applied") then
			return false

		else
			for i = 1, orderedListLen do

				local state, name = sortBarList[i].state, sortBarList[i].name

				if(state > 0 and k1[name] ~= k2[name]) then
					if(state == 1) then
						return k1[name] > k2[name]
		
					else
						return k1[name] < k2[name]
		
					end

				elseif(i == orderedListLen) then
					return k1.index > k2.index

				end
			end
		end
	end)]]

	treeDataProvider:SetSortComparator(function(n1, n2)
		local k1 = n1.data
		local k2 = n2.data

		if(k1.appStatus == "applied" and k2.appStatus ~= "applied") then
			return true

		elseif(k2.appStatus == "applied" and k1.appStatus ~= "applied") then
			return false

		else
			for i = 1, orderedListLen do

				local state, name = sortBarList[i].state, sortBarList[i].name

				if(state > 0 and k1[name] ~= k2[name]) then
					if(state == 1) then
						return k1[name] > k2[name]
		
					else
						return k1[name] < k2[name]
		
					end

				elseif(i == orderedListLen) then
					return k1.index > k2.index

				end
			end
		end
	end)

	miog.SearchPanel.ScrollBox2:SetDataProvider(treeDataProvider, true)

	miog.updateFooterBarResults(numOfFiltered, actualResults, actualResults >= 100)
		
	if(numOfFiltered == 0) then
		showStatusOverlay()

	end
end

local function refreshScrollBox()
	--local dp = miog.SearchPanel.ScrollBox2:GetDataProvider()

	if(dp) then
		miog.SearchPanel.ScrollBox2:Flush()

		dp:Sort()

		miog.SearchPanel.ScrollBox2:SetDataProvider(dp, true)

	else
		fullyUpdateSearchPanel()

	end
end


miog.fullyUpdateSearchPanel = fullyUpdateSearchPanel

local currentlySearching = false
local currentTimer

local function searchPanelEvents(_, event, ...)
	if(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
		if(currentlySearching) then
			miog.SearchPanel.ScrollBox2:RemoveDataProvider()

			miog.SearchPanel.totalResults = LFGListFrame.SearchPanel.totalResults
			miog.SearchPanel.results = LFGListFrame.SearchPanel.results

			fullyUpdateSearchPanel()

			currentTimer = C_Timer.NewTimer(0.65, function()
				fullyUpdateSearchPanel()
			end)
		end

		currentlySearching = false

	elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then --update to title, ilvl, group members, etc
		if(C_LFGList.HasSearchResultInfo(...)) then
			local resultID = ...
			local outData = nil

			local frame = miog.SearchPanel.ScrollBox2:FindFrameByPredicate(function(localFrame, node)
				local isTrue = node.data.resultID == resultID

				if(isTrue) then
					outData = node.data

				end

				return isTrue
			end)

			if(frame) then
				updateScrollBoxFrame(frame, outData)
			end
		end
	elseif(event == "LFG_LIST_SEARCH_FAILED") then
		showStatusOverlay(...)

	elseif(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
		local resultID, new, old, name = ...
		
		miog.increaseStatistic(new)

		updateScrollBoxFrameApplicationStatus(findFrame(resultID), resultID, new, old)

		if(new == "inviteaccepted") then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
			local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])
			local lastGroup = activityInfo.fullName

			if(not miog.F.LITE_MODE) then
				miog.MainTab.QueueInformation.LastGroup.Text:SetText(lastGroup)

			end

			MIOG_CharacterSettings.lastGroup = lastGroup

		elseif(new == "applied") then
			refreshScrollBox()

		end

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS") then

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TIMEOUT") then
	end
end

miog.createSearchPanel = function()
	local searchPanel = CreateFrame("Frame", "MythicIOGrabber_SearchPanel", miog.Plugin.InsertFrame, "MIOG_SearchPanel")

	searchPanel.SignUpButton:SetPoint("LEFT", miog.Plugin.FooterBar.Back, "RIGHT")
	searchPanel.SignUpButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		if(LFGListFrame.SearchPanel.selectedResult and C_LFGList.HasSearchResultInfo(LFGListFrame.SearchPanel.selectedResult)) then
			LFGListApplicationDialog_Show(LFGListApplicationDialog, LFGListFrame.SearchPanel.selectedResult)
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
	autoCompleteFrame:SetFrameStrata("FULLSCREEN")
	autoCompleteFrame:SetWidth(searchBox:GetWidth())
	autoCompleteFrame:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -4, 1)

	LFGListFrame.SearchPanel.AutoCompleteFrame = autoCompleteFrame
	searchPanel.AutoCompleteFrame = autoCompleteFrame

	searchPanel.StartSearch:SetScript("OnClick", function( )
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
	end)

	LFGListFrame.SearchPanel.results = {}
	LFGListFrame.SearchPanel.applications = {}

	searchPanel:SetScript("OnEvent", searchPanelEvents)
	searchPanel:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	searchPanel:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	searchPanel:RegisterEvent("LFG_LIST_SEARCH_FAILED")
	searchPanel:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT")
	searchPanel:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS")
	searchPanel:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

	searchPanel:OnLoad(fullyUpdateSearchPanel)
	searchPanel:SetSettingsTable(MIOG_NewSettings.sortMethods["LFGListFrame.SearchPanel"])
	searchPanel:AddMultipleSortingParameters({
		{name = "primary", padding = 235},
		{name = "secondary", padding = 20},
		{name = "age", padding = 35},
	})

	C_CVar.SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_KEY_RANGE_GROUP_FINDER, true)

	local view = CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 2);

	local function Initializer(frame, node)
		local data = node:GetData()

		frame.node = node
		

		if(data.template == "MIOG_SearchPanelResultFrameTemplate") then
			updateScrollBoxFrame(frame, data)

		else
			miog.updateRaiderIOScrollBoxFrameData(frame, data)

		end
	end
	
	local function CustomFactory(factory, node)
		local data = node:GetData()
		local template = data.template
		factory(template, Initializer)
	end
	
	view:SetElementFactory(CustomFactory)

	view:SetFrameFactoryResetter(function(pool, frame, new)
		local template = pool:GetTemplate()

		if(template == "MIOG_SearchPanelResultFrameTemplate") then
			if(new) then
				addOneTimeFrames(frame)

			else
				resetScrollBoxFrame(frame)

			end

		end

		frame:Hide()
	end)

	view:SetElementExtentCalculator(function(index, node)
		local data = node:GetData()
		local height = data.template == "MIOG_SearchPanelResultFrameTemplate" and 40 or 160
		return height
	end)

	ScrollUtil.InitScrollBoxListWithScrollBar(searchPanel.ScrollBox2, searchPanel.ScrollBar, view);

	local appDialogParentFrame = CreateFrame("Frame", nil, LFGListApplicationDialog, "MIOG_ApplicationDialogParentTemplate")

	local textboxView = CreateScrollBoxListLinearView(4, 2, 1, 1, 2);
	
	local function repopulateAppDialogBox()
		local provider = CreateDataProvider()
		for k, v in ipairs(MIOG_CharacterSettings.appDialogTexts) do
			provider:Insert({index = k, text = v})
	
		end

		if(provider:GetSize() == 0) then
			provider:Insert({index = 1, text = ""})

		end

		textboxView:SetDataProvider(provider, true)
	end

	appDialogParentFrame.Checkbox:SetScript("OnClick", function(self)
		local currentState = self:GetChecked()
		self:GetParent().Textbox:SetShown(currentState)
		MIOG_CharacterSettings.appDialogBoxExtented = currentState
	end)
	appDialogParentFrame.Checkbox:SetChecked(MIOG_CharacterSettings.appDialogBoxExtented)
	appDialogParentFrame.Textbox:SetShown(MIOG_CharacterSettings.appDialogBoxExtented)

	textboxView:SetElementInitializer("MIOG_ApplicationDialogTextboxInputTemplate", function(frame, data)
		frame.InputBox:SetText(data.text)

		MIOG_CharacterSettings.appDialogTexts[data.index] = data.text

		frame.InputBox:SetScript("OnTextChanged", function(self, userInput)
			if(userInput) then
				MIOG_CharacterSettings.appDialogTexts[data.index] = self:GetText()

			end
		end)

		if(data.index > 1) then
			frame.DeleteButton:SetScript("OnClick", function(self, button)
				table.remove(MIOG_CharacterSettings.appDialogTexts, data.index)

				repopulateAppDialogBox()
			end)
		else
			frame.DeleteButton:Hide()

		end
	end)
	textboxView:SetElementExtent(48)
	textboxView:SetElementResetter(function(frame, data)
		frame.DeleteButton:Show()

	end)
	ScrollUtil.InitScrollBoxListWithScrollBar(appDialogParentFrame.Textbox.ScrollBox, appDialogParentFrame.Textbox.ScrollBar, textboxView);

	repopulateAppDialogBox(true)

	appDialogParentFrame.AddInputBoxButton:SetParent(appDialogParentFrame.Textbox)
	appDialogParentFrame.AddInputBoxButton:SetScript("OnClick", function(self, button)
		local provider = textboxView:GetDataProvider()

		provider:Insert({index = provider:GetSize() + 1, text = ""})
		
	end)

	return searchPanel
end

hooksecurefunc("LFGListSearchPanel_SetCategory", function()
	miog.SearchPanel.categoryID = LFGListFrame.SearchPanel.categoryID
	miog.SearchPanel.filters = LFGListFrame.SearchPanel.filters
	miog.SearchPanel.preferredFilters = LFGListFrame.SearchPanel.preferredFilters
end)

hooksecurefunc("LFGListApplicationDialog_Show", function(dialog, resultID)
	groupSignup(resultID)
end)

hooksecurefunc("LFGListSearchPanel_SelectResult", function(searchPanel, resultID)
	selectResultFrame(resultID)
end)

hooksecurefunc("LFGListSearchPanel_DoSearch", function()
	currentlySearching = true
end)