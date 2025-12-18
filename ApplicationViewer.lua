local addonName, miog = ...
local wticc = WrapTextInColorCode

local applicantListSpacing = 4
local queueTimer

local actualResults

local function resetArrays()
	miog.DEBUG_APPLICANT_DATA = {}
	miog.DEBUG_APPLICANT_MEMBER_INFO = {}

	miog.ApplicationViewer.ScrollBox2:Flush()
end

miog.resetArrays = resetArrays

local function showEditBox(name, parent, numeric, maxLetters)
	local editbox = miog.ApplicationViewer.CreationSettings.EditBox

	parent:Hide()

	editbox.name = name
	editbox.hiddenElement = parent
	editbox:SetSize(parent:GetWidth() + 5, parent:GetHeight())
	editbox:SetPoint("LEFT", parent, "LEFT", 0, 0)
	editbox:SetNumeric(numeric)
	editbox:SetMaxLetters(maxLetters)
	editbox:SetText(parent:GetText())
	editbox:Show()

	LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)
end

local function getAllVisibleApplicantFrames(applicantID)
	local frameTable = {}

	for k, frame in miog.ApplicationViewer.ScrollBox2:EnumerateFrames() do
		if(frame.applicantID == applicantID) then
			tinsert(frameTable, frame)

		end
	end
	
	return frameTable
end

local function updateApplicantStatusFrame(applicantID, applicantStatus)
	local frameTable = getAllVisibleApplicantFrames(applicantID)

	if(#frameTable > 0) then
		for k, memberFrame in ipairs(frameTable) do
			memberFrame.StatusFrame:Show()
			memberFrame.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[applicantStatus].statusString, miog.APPLICANT_STATUS_INFO[applicantStatus].color))

			if(memberFrame.inviteButton) then
				memberFrame.inviteButton:Disable()

			end
		end

		if(applicantStatus ~= "invited") then
			if(C_PartyInfo.CanInvite() and (applicantStatus == "inviteaccepted" or applicantStatus == "debug")) then
				for k, memberFrame in ipairs(frameTable) do
					miog.addInvitedPlayer(memberFrame.data)

				end
			end

		end
	end
end

local function newSort(idData1, idData2)
	local k1 = idData1[1]
	local k2 = idData2[1]

	local orderedList = miog.ApplicationViewer:GetOrderedParameters()

	for k, v in ipairs(orderedList) do
		if(v.state > 0 and k1[v.name] ~= k2[v.name]) then
			if(v.state == 1) then
				return k1[v.name] > k2[v.name]

			else
				return k1[v.name] < k2[v.name]

			end
		end
	end
end

local function updateApplicantMemberFrame(frame, data)
	local applicantID, applicantIndex = data.applicantID, data.applicantIndex
	local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)
	local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityIDs[1] or 0

	local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, factionGroup, raceID, specID, isLeaver
	local dungeonData, pvpData, rioProfile

	if(miog.F.IS_IN_DEBUG_MODE) then
		name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, raceID, specID, isLeaver, dungeonData, pvpData = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

	else
		name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)
		dungeonData = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, applicantIndex, activityID)
		pvpData = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, applicantIndex, activityID)

	end
	
	local playerName, realm = miog.createSplitName(name)
	local playerIsIgnored = C_FriendList.IsIgnored(name)

	local applicantMemberFrame = frame

	applicantMemberFrame.data = data
	applicantMemberFrame.memberIdx = applicantIndex
	applicantMemberFrame:SetScript("OnEnter", function(self)
		self:GetParent().applicantID = applicantID
		LFGListApplicantMember_OnEnter(self)
	end)

	local applicantMemberStatusFrame = applicantMemberFrame.StatusFrame
	applicantMemberStatusFrame:Hide()

	applicantMemberFrame.Comment:SetShown(applicantData.comment ~= "" and applicantData.comment ~= nil)

	local r, g, b = C_ClassColor.GetClassColor(class):GetRGB()

	applicantMemberFrame.Background:SetColorTexture(r, g, b, 0.5)

	local nameTable = {}

	if(isLeaver) then
		tinsert(nameTable, "|A:groupfinder-icon-leaver:12:12|a")

	end

	if(relationship) then
		tinsert(nameTable, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\friend.png:14|t")

	end

	tinsert(nameTable, playerName)

	local nameFontString = applicantMemberFrame.Name

	nameFontString:SetText(table.concat(nameTable))
	nameFontString:SetScript("OnMouseDown", function(_, button)
		if(button == "RightButton") then
			local copybox = miog.ApplicationViewer.CopyBox
			copybox:SetText("https://raider.io/characters/" .. miog.F.CURRENT_REGION .. "/" .. miog.REALM_LOCAL_NAMES[realm] .. "/" .. playerName)
			copybox:SetPoint("LEFT", applicantMemberFrame, "LEFT", 6, 0)
			copybox:SetPoint("RIGHT", applicantMemberFrame, "RIGHT", -4, 0)
			copybox:Show()
			copybox:SetFocus()

		end
	end)

	if(miog.F.LITE_MODE) then
		nameFontString:SetWidth(85)
	end

	applicantMemberFrame.Race:SetAtlas(miog.RACES[raceID])

	if(miog.SPECIALIZATIONS[specID] and class == miog.SPECIALIZATIONS[specID].class.name) then
		applicantMemberFrame.Spec:SetTexture(miog.SPECIALIZATIONS[specID].icon)

	else
		applicantMemberFrame.Spec:SetTexture(miog.SPECIALIZATIONS[0].icon)

	end

	applicantMemberFrame.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. assignedRole .. "Icon.png")

	local reqIlvl = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().requiredItemLevel or 0

	if(reqIlvl > itemLevel) then
		applicantMemberFrame.ItemLevel:SetText(wticc(miog.round(itemLevel, 1), miog.CLRSCC["red"]))

	else
		applicantMemberFrame.ItemLevel:SetText(miog.round(itemLevel, 1))

	end

	local declineButton = applicantMemberFrame.Decline
	declineButton:OnLoad()
	declineButton:SetScript("OnClick", function()
		if(not miog.F.IS_IN_DEBUG_MODE) then
			C_LFGList.DeclineApplicant(applicantID)

		else
			miog.debug_DeclineApplicant(applicantID)

		end
	end)

	local inviteButton = applicantMemberFrame.Invite
	inviteButton:OnLoad()
	inviteButton:SetScript("OnClick", function()
		C_LFGList.InviteApplicant(applicantID)

		if(miog.F.IS_IN_DEBUG_MODE) then
			updateApplicantStatusFrame(applicantID, "debug")
		end

	end)

	if(applicantIndex == 1 and miog.checkIfCanInvite() == true or applicantIndex == 1 and miog.F.IS_IN_DEBUG_MODE) then
		declineButton:Show()
		inviteButton:Show()

	else
		declineButton:Hide()
		inviteButton:Hide()

	end
	
	local activeEntry = C_LFGList.GetActiveEntryInfo()
	local categoryID = activeEntry and miog.requestActivityInfo(activeEntry.activityIDs[1]).categoryID

	miog.setInfoIndicators(applicantMemberFrame, categoryID, dungeonScore, dungeonData, miog.getNewRaidSortData(playerName, realm), pvpData)
end

local function getApplicants()
	return miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicants() or C_LFGList.GetApplicants()
end

local function getApplicantInfo(applicantID)
	return miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)
end

local function createDataProviderWithUnsortedData()
	local activeEntry = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo()
	local basicTable = {}
	local numOfFiltered = 0
	local currentApplicants = getApplicants()

	if(activeEntry) then
		local categoryID = miog.requestActivityInfo(activeEntry.activityIDs[1]).categoryID

		for _, applicantID in pairs(currentApplicants) do
			local applicantData = getApplicantInfo(applicantID)
			local applicantInfos = {}

			local allOkay = true

			for applicantIndex = 1, applicantData.numMembers, 1 do
				local name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, isLeaver, bestDungeonScoreForListing, pvpRatingInfo

				if(miog.F.IS_IN_DEBUG_MODE) then
					name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, isLeaver, bestDungeonScoreForListing, pvpRatingInfo = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

				else
					name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, isLeaver = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)

				end

				local playerName, realm = miog.createSplitName(name)

				local primarySortAttribute, secondarySortAttribute

				if(categoryID ~= 3 and categoryID ~= 4 and categoryID ~= 7 and categoryID ~= 8 and categoryID ~= 9) then
					primarySortAttribute = dungeonScore or 0
					secondarySortAttribute = miog.F.IS_IN_DEBUG_MODE and bestDungeonScoreForListing.bestRunLevel or C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activeEntry.activityIDs[1]).bestRunLevel

				elseif(categoryID == 3) then
					local raidData = miog.getOnlyPlayerRaidData(playerName, realm)

					if(raidData) then
						primarySortAttribute = raidData.character.ordered[1].weight or 0
						secondarySortAttribute = raidData.character.ordered[2].weight or 0

					else
						primarySortAttribute = 0
						secondarySortAttribute = 0

					end

				elseif(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
					if(not miog.F.IS_IN_DEBUG_MODE) then
						pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activeEntry.activityIDs[1])

					end

					primarySortAttribute = pvpRatingInfo.rating
					secondarySortAttribute = pvpRatingInfo.rating

				end
				applicantInfos[applicantIndex] = {
					template = "MIOG_ApplicantMemberFrameTemplateNew",
					applicantIndex = applicantIndex,
					applicantID = applicantID,
					index = applicantID,
					name = playerName,
					realm = realm,
					fullName = name,
					role = assignedRole,
					class = class,
					specID = specID,
					ilvl = itemLevel or 0,

					primary = primarySortAttribute,
					secondary = secondarySortAttribute,
				}

				local showFrame, _ = miog.filter.checkIfApplicantIsEligible(applicantInfos[applicantIndex])

				if(not showFrame) then
					allOkay = false
					break

				end
			end


			if(allOkay) then
				tinsert(basicTable, applicantInfos)
				numOfFiltered = numOfFiltered + 1

			end
		end
	end

	return basicTable, numOfFiltered, #currentApplicants
end

local function updateApplicantList()
	local basicTable, numOfFiltered, total = createDataProviderWithUnsortedData()

	actualResults = total

	if(basicTable) then
		table.sort(basicTable, newSort)

		local dataProvider = CreateTreeDataProvider()

		for _, v in ipairs(basicTable) do
			for _, y in ipairs(v) do
				local finalData = dataProvider:Insert(y)
				finalData:Insert({template = "MIOG_NewRaiderIOInfoPanel", applicantID = y.applicantID, name = y.name, realm = y.realm})
			end

			dataProvider:Insert({template = "BackdropTemplate"})
		end

		dataProvider:SetAllCollapsed(true);
		miog.ApplicationViewer:SetDataProvider(dataProvider)

		actualResults = #basicTable
	end

	miog.updateFooterBarResults(numOfFiltered, actualResults, actualResults >= 100)
end

local function createAVSelfEntry(pvpBracket)
	resetArrays()

	local applicantID = 99999

	miog.DEBUG_APPLICANT_DATA[applicantID] = {
		applicantID = applicantID,
		applicationStatus = "applied",
		numMembers = 1,
		isNew = true,
		comment = "aaaaa aaaaaa aaaaaaaaaaa aaaaaaaaaaa aaa aaaaaaaaaaaa aaaa aaaa",
		displayOrderID = 1,
	}

	miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID] = {}

	local rioProfile = miog.getRaiderIOProfile(UnitFullName("player"))

	local className, classFile = UnitClass("player")
	local specID = GetSpecializationInfo(GetSpecialization())
	local role = GetSpecializationRoleByID(specID or 0)

	local highestKey

	if(rioProfile and rioProfile.mythicKeystoneProfile) then
		highestKey = rioProfile.mythicKeystoneProfile.maxDungeonLevel
	end

	local _, _, raceID = UnitRace("player")
	local _, itemLevel, pvpItemLevel = GetAverageItemLevel()

	local rating = 0

	if(pvpBracket) then
		rating = GetPersonalRatedInfo(pvpBracket)
	end

	miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID][1] = {
		[1] = UnitFullName("player"),
		[2]  = classFile, --ENG
		[3]  = className, --GER
		[4]  = UnitLevel("player"),
		[5]  = itemLevel,
		[6]  = UnitHonorLevel("player"),
		[7]  = role == "TANK",
		[8]  = role == "HEALER",
		[9]  = role == "DAMAGER",
		[10]  = select(5, GetSpecializationInfoByID(specID or 0)),
		[11]  = true,
		[12]  = C_ChallengeMode.GetOverallDungeonScore(),
		[13]  = pvpItemLevel,
		[14]  = UnitFactionGroup("player"),
		[15]  = raceID,
		[16]  = specID,
		[17] = random(0, 100) > 50 and true or false,
		[18]  = {finishedSuccess = true, bestRunLevel = highestKey or 0, mapName = "Big Dick Land"},
		[19]  = {bracket = pvpBracket, rating = rating, activityName = "XD", tier = miog.debugGetTestTier(rating)},
	}

	--local startTime = GetTimePreciseSec()
	updateApplicantList()
	--checkApplicantList(true)
	--local endTime = GetTimePreciseSec()

	--currentAverageExecuteTime[#currentAverageExecuteTime+1] = endTime - startTime
end

miog.createAVSelfEntry = createAVSelfEntry

local function createFullEntries(iterations)
	resetArrays()

	local numbers = {}
	for i = 1, #miog.DEBUG_RAIDER_IO_PROFILES do
		numbers[i] = i

	end

	miog.shuffleNumberTable(numbers)

	for index = 1, iterations, 1 do
		local applicantID = random(10000, 99999)
		local numMembers = 2

		miog.DEBUG_APPLICANT_DATA[applicantID] = {
			applicantID = applicantID,
			applicationStatus = "applied",
			numMembers = numMembers,
			isNew = true,
			comment = "aaaaa aaaaaa aaaaaaaaaaa aaaaaaaaaaa aaa aaaaaaaaaaaa aaaa aaaa",
			displayOrderID = 1,
		}

		miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID] = {}

		local trueAndFalse = {true, false}

		for memberIndex = 1, miog.DEBUG_APPLICANT_DATA[applicantID].numMembers, 1 do
			--local rating = random(1, 4000)
			local rating = 0

			local debugProfile = miog.DEBUG_RAIDER_IO_PROFILES[numbers[random(1, #miog.DEBUG_RAIDER_IO_PROFILES)]]

			local rioProfile = miog.getRaiderIOProfile(debugProfile[1], debugProfile[2], debugProfile[3])

			local classID = random(1, 13)
			local classInfo = C_CreatureInfo.GetClassInfo(classID) or {"WARLOCK", "Warlock"}

			local specID = miog.CLASSES[classID].specs[random(1, #miog.DEBUG_SPEC_TABLE[classID])]

			local highestKey
			local dungeonData, pvpData

			if(rioProfile and rioProfile.mythicKeystoneProfile) then
				highestKey = rioProfile.mythicKeystoneProfile.maxDungeonLevel

				local tier

				for _,v in ipairs(miog.DEBUG_TIER_TABLE) do
					if(rating >= v[1]) then
						tier = v[2]
					end
				end

				dungeonData = {finishedSuccess = true, bestRunLevel = highestKey or 0, mapName = "Big Dick Land"}
				pvpData = {bracket = "", rating = rating, activityName = "XD", tier = miog.debugGetTestTier(rating)}
			end

			local randomRace = random(1, 5)
			
			local _, tempItemLevel, tempPvpItemLevel = GetAverageItemLevel()
			local itemLevel = random(tempItemLevel - 20, tempItemLevel + 10)
			local pvpItemLevel = random(tempPvpItemLevel - 20, tempPvpItemLevel + 10)

			miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID][memberIndex] = {
				[1] = debugProfile[1] .. "-" .. debugProfile[2],
				[2]  = classInfo.classFile, --ENG
				[3]  = classInfo.className, --GER
				[4]  = UnitLevel("player"),
				[5]  = itemLevel,
				[6]  = UnitHonorLevel("player"),
				[7]  = trueAndFalse[random(1,2)],
				[8]  = trueAndFalse[random(1,2)],
				[9]  = trueAndFalse[random(1,2)],
				[10] = select(5, GetSpecializationInfoByID(specID)),
				[11] = true,
				[12] = rioProfile and rioProfile.mythicKeystoneProfile and rioProfile.mythicKeystoneProfile.currentScore or 0,
				[13] = pvpItemLevel,
				[14] = random(0, 100) > 50 and "Alliance" or "Horde",
				[15] = randomRace == 1 and random(1, 11) or randomRace == 2 and 22 or randomRace == 3 and random(24, 37) or randomRace == 4 and 52 or 70,
				[16] = specID,
				[17] = random(0, 100) > 50 and true or false,
				[18] = {finishedSuccess = true, bestRunLevel = highestKey or 0, mapName = "Big Dick Land"},
				[19] = {bracket = "", rating = rating, activityName = "XD", tier = miog.debugGetTestTier(rating)},
			}
		end

	end

	local startTime = GetTimePreciseSec()
	updateApplicantList()
	local endTime = GetTimePreciseSec()

	miog.debug.currentAverageExecuteTime[#miog.debug.currentAverageExecuteTime+1] = endTime - startTime
end

miog.createFullEntries = createFullEntries

local function applicationViewerEvents(_, event, ...)
	if(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		local entryInfo = C_LFGList.GetActiveEntryInfo()

		if(entryInfo) then
			miog.insertLFGInfo()

		end

		if(... == nil) then --DELIST
			if not(entryInfo) then
				if(queueTimer) then
					queueTimer:Cancel()

				end

				miog.ApplicationViewer:Hide()
				miog.ApplicationViewer.ScrollBox2:Flush()
				miog.ApplicationViewer.CreationSettings.Timer:SetText("00:00:00")
				
				miog.setAffixes()
			end
		else
			if(... == true) then --NEW LISTING
				MIOG_NewSettings.queueUpTime = GetTimePreciseSec()

			elseif(... == false) then --RELOAD, LOADING SCREENS OR SETTINGS EDIT
				MIOG_NewSettings.queueUpTime = MIOG_NewSettings.queueUpTime > 0 and MIOG_NewSettings.queueUpTime or GetTimePreciseSec()

			end

			queueTimer = C_Timer.NewTicker(1, function()
				miog.ApplicationViewer.CreationSettings.Timer:SetText(miog.secondsToClock(GetTimePreciseSec() - MIOG_NewSettings.queueUpTime))

			end)
		end
	elseif(event == "LFG_LIST_APPLICANT_UPDATED") then --ONE APPLICANT
		local applicantData = C_LFGList.GetApplicantInfo(...)

		if(applicantData) then
			if(applicantData.applicationStatus ~= "applied") then
				updateApplicantStatusFrame(..., applicantData.applicationStatus)


			end
		else
			updateApplicantStatusFrame(..., "declined")

		end
	elseif(event == "PARTY_LEADER_CHANGED") then
		local canInvite = miog.checkIfCanInvite()

		for _, frame in miog.ApplicationViewer.ScrollBox2:EnumerateFrames() do
			if(frame.Invite) then
				frame.Invite:SetShown(canInvite)
				frame.Decline:SetShown(canInvite)

			end
		end
	elseif(event == "LFG_LIST_APPLICANT_LIST_UPDATED") then --ALL THE APPLICANTS
		local newEntry, withData = ...

		if(withData or not newEntry) then --REFRESH APP LIST
			updateApplicantList()

		end
	end
end

miog.createApplicationViewer = function()
	local applicationViewer = CreateFrame("Frame", "MythicIOGrabber_ApplicationViewer", miog.Plugin.InsertFrame, "MIOG_ApplicationViewer")

	miog.createFrameBorder(applicationViewer, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.TitleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.InfoPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.CreationSettings, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.SortButtonRow, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	applicationViewer.TitleBar.Faction:SetTexture(2437241)
	applicationViewer.InfoPanel.Background:SetTexture(miog.ACTIVITY_BACKGROUNDS[10])
	applicationViewer.Browse:SetPoint("LEFT", miog.Plugin.FooterBar.Back, "RIGHT")

	applicationViewer.CreationSettings.EditBox.UpdateButton:SetScript("OnClick", function(self)
		LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)

		local editbox = applicationViewer.CreationSettings.EditBox
		editbox:Hide()

		if(editbox.hiddenElement) then
			editbox.hiddenElement:Show()
		end

		if(editbox.name) then
			local text = editbox:GetText()
			miog.EntryCreation[editbox.name]:SetText(text)
		end

		miog.listGroup()
		miog.insertLFGInfo()
	end)

	applicationViewer.CreationSettings.EditBox:SetScript("OnEnterPressed", applicationViewer.CreationSettings.EditBox.UpdateButton:GetScript("OnClick"))

	applicationViewer.InfoPanel.Description.Container:SetSize(applicationViewer.InfoPanel.Description:GetSize())
	applicationViewer.InfoPanel.Description:SetScript("OnMouseDown", function(self)
		if(self.lastClick and 0.2 > GetTime() - self.lastClick) then
		end
	
		self.lastClick = GetTime()
	end)
	
	applicationViewer.CreationSettings.ItemLevel:SetScript("OnMouseDown", function(self)
		if(self.lastClick and 0.2 > GetTime() - self.lastClick) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			showEditBox("ItemLevel", self.FontString, true, 3)
		end
	
		self.lastClick = GetTime()
	end)

	applicationViewer.CreationSettings.Rating:SetScript("OnMouseDown", function(self)
		if(self.lastClick and 0.2 > GetTime() - self.lastClick) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			showEditBox("Rating", self.FontString, true, 4)
		end
	
		self.lastClick = GetTime()
	end)

	applicationViewer.CreationSettings.PrivateGroupButton:SetScript("OnClick", function()
		LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)

		miog.EntryCreation.PrivateGroup:SetChecked(not miog.EntryCreation.PrivateGroup:GetChecked())

		miog.listGroup()
		miog.insertLFGInfo()
	end)

	applicationViewer.CreationSettings.AutoAcceptButton:SetScript("OnClick", function(self)
		LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)
		
		miog.listGroup(self:GetChecked())
		miog.insertLFGInfo()
	end)

	applicationViewer:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
	applicationViewer:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
	applicationViewer:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
	applicationViewer:RegisterEvent("PARTY_LEADER_CHANGED")
	applicationViewer:SetScript("OnEvent", applicationViewerEvents)

	applicationViewer:OnLoad(updateApplicantList)
	applicationViewer:SetTreeMode(true)
	applicationViewer:SetExternalSort(true)
	applicationViewer:SetSettingsTable(MIOG_NewSettings.sortMethods["LFGListFrame.ApplicationViewer"])
	applicationViewer:AddMultipleSortingParameters({
		{name = "role", padding = 186},
		{name = "primary", padding = 13},
		{name = "secondary", padding = 19},
		{name = "ilvl", padding = 21},
	})

	local view = CreateScrollBoxListTreeListView(0, 0, 1, 1, 0, 1);

	local function Initializer(frame, node)
		local data = node:GetData()

		frame.node = node

		if(data.template == "MIOG_ApplicantMemberFrameTemplateNew") then
			updateApplicantMemberFrame(frame, data)

		elseif(data.template == "MIOG_NewRaiderIOInfoPanel") then
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
		--local template = pool:GetTemplate()

		frame:Hide()
	end)

	view:SetElementExtentCalculator(function(index, node)
		local data = node:GetData()
		return data.template == "MIOG_NewRaiderIOInfoPanel" and 200 or data.template == "BackdropTemplate" and applicantListSpacing or 20
	end)

	ScrollUtil.InitScrollBoxListWithScrollBar(applicationViewer.ScrollBox2, miog.pveFrame2.ScrollBarArea.ApplicationViewerScrollBar, view);

	applicationViewer:SetScrollBox(applicationViewer.ScrollBox2)

	return applicationViewer
end