local addonName, miog = ...
local wticc = WrapTextInColorCode

local applicantSystem = {}
applicantSystem.applicantMember = {}

local applicantFramePool

local detailedList = {}

local applicationFrameIndex = 0
local queueTimer

local numOfApplicants, totalApplicants = 0, 0

local function resetBaseFrame(pool, childFrame)
    childFrame:Hide()
	childFrame.layoutIndex = nil
	childFrame.applicantID = nil
	childFrame:ClearBackdrop()

end

local function resetArrays()
	miog.DEBUG_APPLICANT_DATA = {}
	miog.DEBUG_APPLICANT_MEMBER_INFO = {}

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

local function releaseApplicantFrames()
	for widget in applicantFramePool:EnumerateActive() do
		widget.framePool:ReleaseAll()
	end

	applicantFramePool:ReleaseAll()

	miog.Plugin.FooterBar.Results:SetText("0(0)")
	miog.ApplicationViewer.FramePanel.Container:MarkDirty()

	applicantSystem = {}
	applicantSystem.applicantMember = {}

end

miog.releaseApplicantFrames = releaseApplicantFrames

local function hideAllApplicantFrames()
	for _, v in pairs(applicantSystem.applicantMember) do
		if(v.frame) then
			v.frame:Hide()
			v.frame.layoutIndex = nil

		end
	end

	miog.Plugin.FooterBar.Results:SetText("0(0)")
	miog.ApplicationViewer.FramePanel.Container:MarkDirty()

end

local function updateApplicantStatusFrame(applicantID, applicantStatus)
	local currentApplicant = applicantSystem.applicantMember[applicantID]

	if(currentApplicant and currentApplicant.frame and currentApplicant.frame.memberFrames) then
		for _, memberFrame in pairs(currentApplicant.frame.memberFrames) do
			memberFrame.StatusFrame:Show()
			memberFrame.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[applicantStatus].statusString, miog.APPLICANT_STATUS_INFO[applicantStatus].color))

			if(memberFrame.BasicInformation.inviteButton) then
				memberFrame.BasicInformation.inviteButton:Disable()

			end
		end

		if(applicantStatus == "invited") then
			currentApplicant.status = "pendingInvite"

		else
			currentApplicant.status = "removable"

			if(C_PartyInfo.CanInvite() and (applicantStatus == "inviteaccepted" or applicantStatus == "debug")) then
				miog.addInvitedPlayer(currentApplicant.memberData[1])

				for k, v in ipairs(currentApplicant.memberData) do
					miog.addInvitedPlayer(v)

				end
			end

		end
	end
end

local function sortApplicantList(applicant1, applicant2)
	local applicant1Member1 = applicant1[1]
	local applicant2Member1 = applicant2[1]

	for key, tableElement in pairs(MIOG_NewSettings.sortMethods["LFGListFrame.ApplicationViewer"]) do
		if(tableElement.currentLayer == 1) then
			local firstState = tableElement.currentState

			for innerKey, innerTableElement in pairs(MIOG_NewSettings.sortMethods["LFGListFrame.ApplicationViewer"]) do

				if(innerTableElement.currentLayer == 2) then
					local secondState = innerTableElement.currentState

					if(applicant1Member1.favoured and not applicant2Member1.favoured) then
						return true

					elseif(not applicant1Member1.favoured and applicant2Member1.favoured) then
						return false

					else
						if(applicant1Member1[key] == applicant2Member1[key]) then
							return secondState == 1 and applicant1Member1[innerKey] > applicant2Member1[innerKey] or secondState == 2 and applicant1Member1[innerKey] < applicant2Member1[innerKey]

						elseif(applicant1Member1[key] ~= applicant2Member1[key]) then
							return firstState == 1 and applicant1Member1[key] > applicant2Member1[key] or firstState == 2 and applicant1Member1[key] < applicant2Member1[key]

						end
					end
				end

			end

			if(applicant1Member1.favoured and not applicant2Member1.favoured) then
				return true

			elseif(not applicant1Member1.favoured and applicant2Member1.favoured) then
				return false

			else
				if(applicant1Member1[key] == applicant2Member1[key]) then
					return firstState == 1 and applicant1Member1.index > applicant2Member1.index or firstState == 2 and applicant1Member1.index < applicant2Member1.index

				elseif(applicant1Member1[key] ~= applicant2Member1[key]) then
					return firstState == 1 and applicant1Member1[key] > applicant2Member1[key] or firstState == 2 and applicant1Member1[key] < applicant2Member1[key]

				end
			end

		end

	end

	if(applicant1Member1.favoured and not applicant2Member1.favoured) then
		return true

	elseif(not applicant1Member1.favoured and applicant2Member1.favoured) then
		return false

	else
		return applicant1Member1.index < applicant2Member1.index

	end

end

local function createApplicantMemberFrame(applicantID, applicantIndex)
	local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)
	local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityIDs[1] or 0

	local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, factionGroup, raceID, specID
	local dungeonData, pvpData, rioProfile

	if(miog.F.IS_IN_DEBUG_MODE) then
		name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, raceID, specID, dungeonData, pvpData = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

	else
		name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, raceID, specID  = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)
		dungeonData = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, applicantIndex, activityID)
		pvpData = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, applicantIndex, activityID)

	end
	
	local playerName, realm = miog.createSplitName(name)
	local playerIsIgnored = C_FriendList.IsIgnored(name)

	local applicantFrame = applicantSystem.applicantMember[applicantID].frame

	local applicantMemberFrame = applicantFrame.framePool:Acquire()
	applicantMemberFrame.fixedWidth = applicantFrame:GetParent().fixedWidth - 2
	applicantMemberFrame.layoutIndex = applicantIndex
	applicantMemberFrame.memberIdx = applicantIndex
	applicantMemberFrame:SetScript("OnEnter", function(self)
		if(playerIsIgnored) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Player is on your ignore list")
			GameTooltip:Show()

		else
			if(not miog.F.IS_IN_DEBUG_MODE) then
				LFGListApplicantMember_OnEnter(self)
			end

			miog.checkEgoTrip(name)
		end
	end)
	applicantFrame.memberFrames[applicantIndex] = applicantMemberFrame

	if(MIOG_NewSettings.favouredApplicants[name]) then
		applicantMemberFrame:ClearBackdrop()
		miog.createFrameBorder(applicantMemberFrame, 1, CreateColorFromHexString("FFe1ad21"):GetRGBA())
	
	end

	local applicantMemberStatusFrame = applicantMemberFrame.StatusFrame
	applicantMemberStatusFrame:Hide()

	local expandFrameButton = applicantMemberFrame.BasicInformation.ExpandFrame
	expandFrameButton:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		local categoryID = miog.getCurrentCategoryID()
		local baseFrame = self:GetParent():GetParent()

		--[[local infoData = baseFrame.RaiderIOInformationPanel[categoryID == 3 and "raid" or "mplus"]

		baseFrame.RaiderIOInformationPanel.InfoPanel.Previous:SetText(infoData and infoData.previous or "")
		baseFrame.RaiderIOInformationPanel.InfoPanel.Main:SetText(infoData and infoData.main or "")]]

		baseFrame.RaiderIOInformationPanel:SetShown(not baseFrame.RaiderIOInformationPanel:IsShown())
		
		detailedList[name] = baseFrame.RaiderIOInformationPanel:IsShown()
		
		self:AdvanceState()
		baseFrame:MarkDirty()

	end)
	
	applicantMemberFrame.RaiderIOInformationPanel:SetShown(detailedList[name] or false)
	applicantMemberFrame.BasicInformation.Comment:SetShown(applicantData.comment ~= "" and applicantData.comment ~= nil)

	local r, g, b = C_ClassColor.GetClassColor(class):GetRGB()

	applicantMemberFrame.Background:SetColorTexture(r, g, b, 0.5)

	local nameFontString = applicantMemberFrame.BasicInformation.Name
	--nameFontString:SetText(playerIsIgnored and wticc(playerName, "FFFF0000") or wticc(playerName, select(4, GetClassColor(class))))
	nameFontString:SetText(playerName)
	nameFontString:SetScript("OnMouseDown", function(_, button)
		if(button == "RightButton") then
			local copybox = miog.ApplicationViewer.CopyBox
			copybox:SetText("https://raider.io/characters/" .. miog.F.CURRENT_REGION .. "/" .. miog.REALM_LOCAL_NAMES[realm] .. "/" .. playerName)
			copybox:SetSize(applicantMemberFrame.fixedWidth - 8, applicantMemberFrame:GetHeight())
			copybox:SetPoint("LEFT", applicantMemberFrame, "LEFT", 6, 0)
			copybox:Show()
			copybox:SetFocus()

		end
	end)

	if(miog.F.LITE_MODE) then
		nameFontString:SetWidth(85)
	end

	applicantMemberFrame.BasicInformation.Race:SetAtlas(miog.RACES[raceID])

	if(miog.SPECIALIZATIONS[specID] and class == miog.SPECIALIZATIONS[specID].class.name) then
		applicantMemberFrame.BasicInformation.Spec:SetTexture(miog.SPECIALIZATIONS[specID].icon)

	else
		applicantMemberFrame.BasicInformation.Spec:SetTexture(miog.SPECIALIZATIONS[0].icon)

	end

	applicantMemberFrame.BasicInformation.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. assignedRole .. "Icon.png")

	local reqIlvl = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().requiredItemLevel or 0

	if(reqIlvl > itemLevel) then
		applicantMemberFrame.BasicInformation.ItemLevel:SetText(wticc(miog.round(itemLevel, 1), miog.CLRSCC["red"]))

	else
		applicantMemberFrame.BasicInformation.ItemLevel:SetText(miog.round(itemLevel, 1))

	end

	applicantMemberFrame.BasicInformation.Friend:SetShown(relationship and true or false)

	if(applicantIndex > 1) then
		applicantMemberFrame.BasicInformation.Premade:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Premades with " .. applicantFrame.memberFrames[1].BasicInformation.nameFrame:GetText())
			GameTooltip:Show()

		end)

	end

	local declineButton = applicantMemberFrame.BasicInformation.Decline
	declineButton:OnLoad()
	declineButton:SetScript("OnClick", function()
		if(applicantSystem.applicantMember[applicantID].status == "indexed") then
			if(not miog.F.IS_IN_DEBUG_MODE) then
				C_LFGList.DeclineApplicant(applicantID)

			else
				miog.debug_DeclineApplicant(applicantID)

			end

		elseif(applicantSystem.applicantMember[applicantID].status == "removable") then
			if(not miog.F.IS_IN_DEBUG_MODE) then
				C_LFGList.RefreshApplicants()

			else
				miog.debug_DeclineApplicant(applicantID)

			end

		end
	end)

	local inviteButton = applicantMemberFrame.BasicInformation.Invite
	inviteButton:OnLoad()
	inviteButton:SetScript("OnClick", function()
		C_LFGList.InviteApplicant(applicantID)

		if(miog.F.IS_IN_DEBUG_MODE) then
			updateApplicantStatusFrame(applicantID, "debug")
		end

	end)

	if(applicantIndex == 1 and miog.F.CAN_INVITE == true or applicantIndex == 1 and miog.F.IS_IN_DEBUG_MODE) then
		declineButton:Show()
		inviteButton:Show()

	else
		declineButton:Hide()
		inviteButton:Hide()

	end
	
	local activeEntry = C_LFGList.GetActiveEntryInfo()
	local categoryID = activeEntry and C_LFGList.GetActivityInfoTable(activeEntry.activityIDs[1]).categoryID

	applicantMemberFrame.RaiderIOInformationPanel:OnLoad()
	applicantMemberFrame.RaiderIOInformationPanel:SetPlayerData(playerName, realm)
	applicantMemberFrame.RaiderIOInformationPanel:SetOptionalData(applicantData.comment, realm, {tank = tank, healer = healer, damager = damager})
	applicantMemberFrame.RaiderIOInformationPanel:ApplyFillData()

	miog.setInfoIndicators(applicantMemberFrame.BasicInformation, categoryID, dungeonScore, dungeonData, applicantMemberFrame.RaiderIOInformationPanel.raidData, pvpData)

	--BasicInformation:MarkDirty()
	applicantMemberFrame:MarkDirty()
	applicantMemberFrame:Show()

end

local function createApplicantFrame(applicantID)
	local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

	--if(applicantData) then
		local applicantFrame = applicantFramePool:Acquire()

		--applicantFrame.minimumHeight = applicantData.numMembers * (20 + 3)
		applicantFrame.memberFrames = {}

		applicantFrame.framePool = applicantFrame.framePool or CreateFramePool("Frame", applicantFrame, "MIOG_ApplicantMemberFrameTemplate", function(pool, frame)
			--miog.resetRaiderIOInformationPanel(frame)
			--miog.resetNewRaiderIOInfoPanel(frame.RaiderIOInformationPanel)
		end)

		applicantFrame.applicantID = applicantID

		miog.createFrameBorder(applicantFrame, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())

		applicantSystem.applicantMember[applicantID].frame = applicantFrame

		for applicantIndex = 1, applicantData.numMembers, 1 do
			createApplicantMemberFrame(applicantID, applicantIndex)
		end

		applicantFrame:MarkDirty()
		applicantSystem.applicantMember[applicantID].status = "indexed"
	--end

	return applicantFrame

	--updateApplicantStatusFrame(applicantID, "debug")
end

local function gatherSortingInformation()
	local applicantSortData = {}

	if(C_LFGList.HasActiveEntryInfo()) then
		local activeEntry = C_LFGList.GetActiveEntryInfo()

		local categoryID = C_LFGList.GetActivityInfoTable(activeEntry.activityIDs[1]).categoryID

		local currentApplicants = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicants() or C_LFGList.GetApplicants()

		for index, applicantID in pairs(currentApplicants) do
			local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

			local currentApplicantData = {}

			for applicantIndex = 1, applicantData.numMembers, 1 do
				local name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo
				local favourPrimary

				if(miog.F.IS_IN_DEBUG_MODE) then
					name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

				else
					name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)

				end

				local playerName, realm = miog.createSplitName(name)

				local primarySortAttribute, secondarySortAttribute

				if(applicantIndex == 1) then -- GET SORT DATA

					if(categoryID ~= 3 and categoryID ~= 4 and categoryID ~= 7 and categoryID ~= 8 and categoryID ~= 9) then
						primarySortAttribute = dungeonScore
						secondarySortAttribute = miog.F.IS_IN_DEBUG_MODE and bestDungeonScoreForListing.bestRunLevel or C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activityID).bestRunLevel

					elseif(categoryID == 3) then
						local raidData = miog.getRaidSortData(playerName .. "-" .. realm)

						if(raidData) then
							primarySortAttribute = raidData[1].weight
							secondarySortAttribute = raidData[2].weight
							--favourPrimary = wticc(miog.DIFFICULTY[raidData[1].difficulty].shortName .. ":" .. raidData[1].progress .. "/" .. raidData[1].bossCount, miog.DIFFICULTY[raidData[1].difficulty].color)

						else
							primarySortAttribute = 0
							secondarySortAttribute = 0
							--favourPrimary = 0
						
						end

					elseif(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
						if(not miog.F.IS_IN_DEBUG_MODE) then
							pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activeEntry.activityID)

						end

						primarySortAttribute = pvpRatingInfo.rating
						secondarySortAttribute = pvpRatingInfo.rating

					end
				end

				--[applicantID]

				currentApplicantData[applicantIndex] = {
					applicantID = applicantID,
					name = playerName,
					realm = realm,
					fullName = name,
					role = assignedRole,
					class = class,
					specID = specID,
					ilvl = itemLevel,
				}

				if(applicantIndex == 1 or MIOG_INCLUDE_SUBMEMBERS) then
					currentApplicantData[applicantIndex].primary = primarySortAttribute
					currentApplicantData[applicantIndex].secondary = secondarySortAttribute
					--applicantSortData[applicantID][applicantIndex].favourPrimary = categoryID ~= 3 and primarySortAttribute or favourPrimary
					currentApplicantData[applicantIndex].index = applicantID
					currentApplicantData[applicantIndex].favoured = MIOG_NewSettings.favouredApplicants[name] and true or false
				end

				table.insert(applicantSortData, currentApplicantData)
			end
		end
	end

	return applicantSortData
end

local function gatherSortData()
	local activeEntry = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo()
	local unsortedMainApplicantsList = {}

	local currentApplicants = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicants() or C_LFGList.GetApplicants()

	if(activeEntry) then
		local categoryID = C_LFGList.GetActivityInfoTable(activeEntry.activityIDs[1]).categoryID

		for _, applicantID in pairs(currentApplicants) do

			if(applicantSystem.applicantMember[applicantID]) then --CHECK IF ENTRY IS THERE

				local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

				if(applicantSystem.applicantMember[applicantID] and applicantSystem.applicantMember[applicantID].status ~= "removable") then
					if(applicantSystem.applicantMember[applicantID].memberData == nil) then -- FIRST TIME THIS APPLICANT APPLIES?
						applicantSystem.applicantMember[applicantID].memberData = {}

						for applicantIndex = 1, applicantData.numMembers, 1 do
							local name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo
							local favourPrimary

							if(miog.F.IS_IN_DEBUG_MODE) then
								name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

							else
								name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)

							end

							local playerName, realm = miog.createSplitName(name)

							applicantSystem.applicantMember[applicantID].memberData[applicantIndex] = {
								name = playerName,
								realm = realm,
								fullName = name,
								role = assignedRole,
								class = class,
								specID = specID,
								ilvl = itemLevel,
							}

							if(applicantIndex == 1) then -- GET SORT DATA
								local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityID or 0
								local primarySortAttribute, secondarySortAttribute

								if(categoryID ~= 3 and categoryID ~= 4 and categoryID ~= 7 and categoryID ~= 8 and categoryID ~= 9) then
									primarySortAttribute = dungeonScore or 0
									secondarySortAttribute = miog.F.IS_IN_DEBUG_MODE and bestDungeonScoreForListing.bestRunLevel or C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activityID).bestRunLevel

								elseif(categoryID == 3) then
									local raidData = miog.getRaidSortData(playerName .. "-" .. realm)

									if(raidData) then
										primarySortAttribute = raidData[1].weight
										secondarySortAttribute = raidData[2].weight
										favourPrimary = wticc(miog.DIFFICULTY[raidData[1].difficulty].shortName .. ":" .. raidData[1].progress .. "/" .. raidData[1].bossCount, miog.DIFFICULTY[raidData[1].difficulty].color)
				
									else
										primarySortAttribute = 0
										secondarySortAttribute = 0
										favourPrimary = 0
									
									end

								elseif(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
									if(not miog.F.IS_IN_DEBUG_MODE) then
										pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activityID)

									end

									primarySortAttribute = pvpRatingInfo.rating
									secondarySortAttribute = pvpRatingInfo.rating

								end

								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].primary = primarySortAttribute
								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].secondary = secondarySortAttribute
								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].favourPrimary = categoryID ~= 3 and primarySortAttribute or favourPrimary
								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].index = applicantID
								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].favoured = MIOG_NewSettings.favouredApplicants[applicantSystem.applicantMember[applicantID].memberData[applicantIndex].fullName] and true or false

							else
								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].primary = 0
								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].secondary = 0


							end

						end

					end

					--unsortedMainApplicantsList[#unsortedMainApplicantsList+1] = applicantSystem.applicantMember[applicantID].memberData
					unsortedMainApplicantsList[#unsortedMainApplicantsList+1] = applicantSystem.applicantMember[applicantID].memberData[1]

				end
			end
		end
	end

	return unsortedMainApplicantsList
end

local function addOrShowApplicant(applicantID)
	if(applicantSystem.applicantMember[applicantID]) then
		if(not applicantSystem.applicantMember[applicantID].frame) then
			applicantSystem.applicantMember[applicantID].status = "inProgress"
			createApplicantFrame(applicantID)

		end

		applicantSystem.applicantMember[applicantID].frame.layoutIndex = applicationFrameIndex
		applicantSystem.applicantMember[applicantID].frame:Show()

		applicationFrameIndex = applicationFrameIndex + 1

	end
end

local function checkApplicantList(forceReorder, applicantID)

	local unsortedList = gatherSortData()

	if(forceReorder) then
		local updatedFrames = {}

		applicationFrameIndex = 0

		if(unsortedList[1]) then
			miog.ApplicationViewer:UpdateSortingData(unsortedList)
			miog.ApplicationViewer:Sort()

			for d, listEntry in ipairs(miog.ApplicationViewer:GetSortingData()) do

				local showFrame, _ = miog.checkEligibility("LFGListFrame.ApplicationViewer", _, listEntry)

				if(showFrame) then
					updatedFrames[listEntry.index] = true
					addOrShowApplicant(listEntry.index)

				end
			end
		end

		for index, v in pairs(applicantSystem.applicantMember) do
			if(not updatedFrames[index] and v.frame) then
				v.frame:Hide()
				v.frame.layoutIndex = nil
	
			end
		end

	else
		addOrShowApplicant(applicantID)

	end

	numOfApplicants, totalApplicants = applicationFrameIndex, #unsortedList

	miog.updateFooterBarResults(numOfApplicants, totalApplicants, false)
	miog.ApplicationViewer.FramePanel.Container:MarkDirty()
end

local function createAVSelfEntry(pvpBracket)
	resetArrays()
	releaseApplicantFrames()

	local applicantID = 99999

	miog.DEBUG_APPLICANT_DATA[applicantID] = {
		applicantID = applicantID,
		applicationStatus = "applied",
		numMembers = 1,
		isNew = true,
		comment = "aaaaa aaaaaa aaaaaaaaaaa aaaaaaaaaaa aaa aaaaaaaaaaaa aaaa aaaa",
		displayOrderID = 1,
	}

	applicantSystem.applicantMember[applicantID] = {
		frame = nil,
		memberData = nil,
		status = "dataAvailable",
	}

	miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID] = {}

	local rioProfile

	if(miog.F.IS_RAIDERIO_LOADED) then
		rioProfile = RaiderIO.GetProfile(UnitFullName("player"))
	end

	local className, classFile = UnitClass("player")
	local specID = GetSpecializationInfo(GetSpecialization())
	local role = GetSpecializationRoleByID(specID)

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
		[10]  = select(5, GetSpecializationInfoByID(specID)),
		[11]  = true,
		[12]  = C_ChallengeMode.GetOverallDungeonScore(),
		[13]  = pvpItemLevel,
		[14]  = UnitFactionGroup("player"),
		[15]  = raceID,
		[16]  = specID,
		[17]  = {finishedSuccess = true, bestRunLevel = highestKey or 0, mapName = "Big Dick Land"},
		[18]  = {bracket = pvpBracket, rating = rating, activityName = "XD", tier = miog.debugGetTestTier(rating)},
	}

	--local startTime = GetTimePreciseSec()
	checkApplicantList(true)
	--local endTime = GetTimePreciseSec()

	--currentAverageExecuteTime[#currentAverageExecuteTime+1] = endTime - startTime
end

miog.createAVSelfEntry = createAVSelfEntry

local function createFullEntries(iterations)
	resetArrays()
	releaseApplicantFrames()

	local numbers = {}
	for i = 1, #miog.DEBUG_RAIDER_IO_PROFILES do
		numbers[i] = i

	end

	miog.shuffleNumberTable(numbers)

	for index = 1, iterations, 1 do
		local applicantID = random(10000, 99999)
		local numMembers = 1

		miog.DEBUG_APPLICANT_DATA[applicantID] = {
			applicantID = applicantID,
			applicationStatus = "applied",
			numMembers = numMembers,
			isNew = true,
			comment = "aaaaa aaaaaa aaaaaaaaaaa aaaaaaaaaaa aaa aaaaaaaaaaaa aaaa aaaa",
			displayOrderID = 1,
		}

		applicantSystem.applicantMember[applicantID] = {
			frame = nil,
			memberData = nil,
			status = "dataAvailable",
		}

		miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID] = {}

		local trueAndFalse = {true, false}

		for memberIndex = 1, miog.DEBUG_APPLICANT_DATA[applicantID].numMembers, 1 do
			--local rating = random(1, 4000)
			local rating = 0

			local debugProfile = miog.DEBUG_RAIDER_IO_PROFILES[numbers[random(1, iterations)]]
			local rioProfile

			if(miog.F.IS_RAIDERIO_LOADED) then
				rioProfile = RaiderIO.GetProfile(debugProfile[1], debugProfile[2], debugProfile[3])
			end

			local classID = random(1, 13)
			local classInfo = C_CreatureInfo.GetClassInfo(classID) or {"WARLOCK", "Warlock"}

			local specID = miog.CLASSES[classID].specs[random(1, #miog.DEBUG_SPEC_TABLE[classID])]

			local highestKey

			if(rioProfile and rioProfile.mythicKeystoneProfile) then
				highestKey = rioProfile.mythicKeystoneProfile.maxDungeonLevel
			end

			local randomRace = random(1, 5)
			local itemLevel = random(440, 489) + 0.5

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
				[10]  = select(5, GetSpecializationInfoByID(specID)),
				[11]  = true,
				[12]  = rioProfile and rioProfile.mythicKeystoneProfile and rioProfile.mythicKeystoneProfile.currentScore or 0,
				[13]  = itemLevel,
				[14]  = random(0, 100) > 50 and "Alliance" or "Horde",
				[15]  = randomRace == 1 and random(1, 11) or randomRace == 2 and 22 or randomRace == 3 and random(24, 37) or randomRace == 4 and 52 or 70,
				[16]  = specID,
				[17]  = {finishedSuccess = true, bestRunLevel = highestKey or 0, mapName = "Big Dick Land"},
				[18]  = {bracket = "", rating = rating, activityName = "XD", tier = miog.debugGetTestTier(rating)},
			}
		end

	end

	local startTime = GetTimePreciseSec()
	checkApplicantList(true)
	local endTime = GetTimePreciseSec()

	miog.debug.currentAverageExecuteTime[#miog.debug.currentAverageExecuteTime+1] = endTime - startTime
end

miog.createFullEntries = createFullEntries

local function applicationViewerEvents(_, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
        local isInitialLogin, isReloadingUi = ...

        if(not isInitialLogin and not isReloadingUi) then
            hideAllApplicantFrames()

        end
	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then --LISTING CHANGES
		local entryInfo = C_LFGList.GetActiveEntryInfo()

		if(entryInfo) then
			miog.insertLFGInfo()
		end

		if(... == nil) then --DELIST
			if not(entryInfo) then
				if(queueTimer) then
					queueTimer:Cancel()

				end

				resetArrays()
				releaseApplicantFrames()

				miog.ApplicationViewer.CreationSettings.Timer:SetText("00:00:00")

				miog.ApplicationViewer:Hide()
				
				miog.setAffixes()
			end
		else
			if(... == true) then --NEW LISTING
				MIOG_QueueUpTime = GetTimePreciseSec()

			elseif(... == false) then --RELOAD, LOADING SCREENS OR SETTINGS EDIT
				MIOG_QueueUpTime = (MIOG_QueueUpTime and MIOG_QueueUpTime > 0) and MIOG_QueueUpTime or GetTimePreciseSec()

			end

			queueTimer = C_Timer.NewTicker(1, function()
				miog.ApplicationViewer.CreationSettings.Timer:SetText(miog.secondsToClock(GetTimePreciseSec() - MIOG_QueueUpTime))

			end)

			miog.ApplicationViewer:Show()

		end

	elseif(event == "LFG_LIST_APPLICANT_UPDATED") then --ONE APPLICANT
		local applicantData = C_LFGList.GetApplicantInfo(...)

		if(applicantData) then
			if(applicantData.applicationStatus == "applied") then
				if(applicantData.displayOrderID > 0) then --APPLICANT WITH DATA
					local canInvite = miog.checkIfCanInvite()

					if(applicantData.pendingApplicationStatus == nil) then--NEW APPLICANT WITH DATA
						if(not applicantSystem.applicantMember[...]) then
							applicantSystem.applicantMember[...] = {
								frame = nil,
								saveData = nil,
								status = "dataAvailable",
							}

						end

						checkApplicantList(not canInvite, ...)

					elseif(applicantData.pendingApplicationStatus == "declined") then
						checkApplicantList(not canInvite, ...)

					end

				elseif(applicantData.displayOrderID == 0) then

				end
			else --STATUS TRIGGERED BY APPLICANT
				updateApplicantStatusFrame(..., applicantData.applicationStatus)

			end
		else
			updateApplicantStatusFrame(..., "declined")

		end

	elseif(event == "LFG_LIST_APPLICANT_LIST_UPDATED") then --ALL THE APPLICANTS
		local newEntry, withData = ...

		if(not newEntry and not withData) then --REFRESH APP LIST
			checkApplicantList(true)

		end
	elseif(event == "PARTY_LEADER_CHANGED") then
		local canInvite = miog.checkIfCanInvite()

		for _,v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame.memberFrames[1].BasicInformation.Invite:SetShown(canInvite)
				v.frame.memberFrames[1].BasicInformation.Decline:SetShown(canInvite)

			end
		end
	elseif(event == "GROUP_ROSTER_UPDATE") then
		local canInvite = miog.checkIfCanInvite()

		for _,v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame.memberFrames[1].BasicInformation.Invite:SetShown(canInvite)
				v.frame.memberFrames[1].BasicInformation.Decline:SetShown(canInvite)

			end
		end
	end

end

miog.createApplicationViewer = function()
	local applicationViewer = CreateFrame("Frame", "MythicIOGrabber_ApplicationViewer", miog.Plugin.InsertFrame, "MIOG_ApplicationViewer") ---@class Frame
	applicationViewer.FramePanel.ScrollBar:SetPoint("TOPRIGHT", applicationViewer.FramePanel, "TOPRIGHT", -1, 0)

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
	applicationViewer:SetScript("OnShow", function()
		miog.updateFooterBarResults(numOfApplicants, totalApplicants, false)
	end)

	applicationViewer:OnLoad(checkApplicantList)
	applicationViewer:SetSettingsTable(MIOG_NewSettings.sortMethods["LFGListFrame.ApplicationViewer"])
	applicationViewer:AddMultipleSortingParameters({
		{name = "role", padding = 156},
		{name = "primary", padding = 13},
		{name = "secondary", padding = 21},
		{name = "ilvl", padding = 21},
	})

	applicationViewer.FramePanel.Container:SetFixedWidth(applicationViewer.FramePanel:GetWidth())
	applicantFramePool = CreateFramePool("Frame", applicationViewer.FramePanel.Container, "MIOG_ApplicantFrameTemplate", resetBaseFrame)

	return applicationViewer
end