local addonName, miog = ...
local wticc = WrapTextInColorCode

local applicantSystem = {}
applicantSystem.applicantMember = {}

local applicationFrameIndex = 0
local queueTimer

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
	for widget in miog.applicantFramePool:EnumerateActive() do
		widget.framePool:ReleaseAllByTemplate("MIOG_ApplicantMemberFrameTemplate")
		widget.framePool:ReleaseAllByTemplate("MIOG_ApplicantMemberFrameTemplate")
	end

	applicantSystem.applicantMember = {}

	miog.applicantFramePool:ReleaseAll()

	miog.Plugin.FooterBar.Results:SetText("0(0)")
	miog.ApplicationViewer.FramePanel.Container:MarkDirty()

	applicantSystem = {}
	applicantSystem.applicantMember = {}

	--collectgarbage()

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

			if(memberFrame.BasicInformationPanel.inviteButton) then
				memberFrame.BasicInformationPanel.inviteButton:Disable()

			end
		end

		if(applicantStatus == "invited") then
			currentApplicant.status = "pendingInvite"

		else
			currentApplicant.status = "removable"

			if(C_PartyInfo.CanInvite() and (applicantStatus == "inviteaccepted" or applicantStatus == "debug")) then
				miog.addLastInvitedApplicant(currentApplicant.memberData[1])

			end

		end
	end
end

local function sortApplicantList(applicant1, applicant2)
	local applicant1Member1 = applicant1[1]
	local applicant2Member1 = applicant2[1]

	for key, tableElement in pairs(MIOG_SavedSettings.sortMethods_ApplicationViewer.table) do
		if(type(tableElement) == "table" and tableElement.currentLayer == 1) then
			local firstState = miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons[key]:GetActiveState()

			for innerKey, innerTableElement in pairs(MIOG_SavedSettings.sortMethods_ApplicationViewer.table) do

				if(type(innerTableElement) == "table" and innerTableElement.currentLayer == 2) then
					local secondState = miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons[innerKey]:GetActiveState()

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

local function createApplicantFrame(applicantID)

	local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

	if(applicantData) then
		local activityID = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.activityID or 0

		local applicantFrame = miog.applicantFramePool:Acquire("MIOG_ApplicantFrameTemplate")
		applicantFrame:SetParent(miog.ApplicationViewer.FramePanel.Container)
		applicantFrame.fixedWidth = miog.ApplicationViewer.FramePanel:GetWidth()
		applicantFrame.minimumHeight = applicantData.numMembers * (miog.C.APPLICANT_MEMBER_HEIGHT + miog.C.APPLICANT_PADDING)
		applicantFrame.memberFrames = {}

		applicantFrame.framePool = applicantFrame.framePool or CreateFramePoolCollection()
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_ApplicantMemberFrameTemplate", miog.resetFrame)
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DetailedInformationPanelTemplate", miog.resetFrame)
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DetailedInformationPanelTextRowTemplate", miog.resetFrame)
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DungeonRowTemplate", miog.resetFrame)
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_RaidPanelTemplate", miog.resetFrame)

		applicantFrame.fontStringPool = applicantFrame.fontStringPool or CreateFontStringPool(applicantFrame, "OVERLAY", nil, "GameTooltipText", miog.resetFontString)
		applicantFrame.texturePool = applicantFrame.texturePool or CreateTexturePool(applicantFrame, "ARTWORK", nil, nil, miog.resetTexture)

		miog.createFrameBorder(applicantFrame, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())

		applicantSystem.applicantMember[applicantID].frame = applicantFrame

		for applicantIndex = 1, applicantData.numMembers, 1 do

			local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, factionGroup, raceID, specID
			local dungeonData, pvpData, rioProfile

			if(miog.F.IS_IN_DEBUG_MODE) then
				name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, raceID, specID, dungeonData, pvpData = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

			else
				name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, raceID, specID  = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)
				dungeonData = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, applicantIndex, activityID)
				pvpData = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, applicantIndex, activityID)

			end

			local nameTable = miog.simpleSplit(name, "-")

			if(not nameTable[2]) then
				nameTable[2] = GetNormalizedRealmName()

				name = nameTable[1] .. "-" .. nameTable[2]

			end

			local applicantMemberFrame = miog.createFleetingFrame(applicantFrame.framePool, "MIOG_ApplicantMemberFrameTemplate", applicantFrame)
			applicantMemberFrame.fixedWidth = applicantFrame.fixedWidth - 2
			applicantMemberFrame.minimumHeight = 20
			applicantMemberFrame:SetPoint("TOP", applicantFrame.memberFrames[applicantIndex-1] or applicantFrame, applicantFrame.memberFrames[applicantIndex-1] and "BOTTOM" or "TOP", 0, applicantIndex > 1 and -miog.C.APPLICANT_PADDING or -1)
			applicantFrame.memberFrames[applicantIndex] = applicantMemberFrame

			if(MIOG_SavedSettings.favouredApplicants.table[name]) then
				miog.createFrameBorder(applicantMemberFrame, 2, CreateColorFromHexString("FFe1ad21"):GetRGBA())

			else
				--miog.createFrameBorder(applicantMemberFrame, 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
			
			end

			local applicantMemberStatusFrame = applicantMemberFrame.StatusFrame
			applicantMemberStatusFrame:SetFrameStrata("FULLSCREEN")
			applicantMemberStatusFrame:Hide()

			local expandFrameButton = applicantMemberFrame.BasicInformationPanel.ExpandFrame

			expandFrameButton:RegisterForClicks("LeftButtonDown")
			expandFrameButton:SetScript("OnClick", function()
				if(applicantMemberFrame.DetailedInformationPanel) then
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
					
					expandFrameButton:AdvanceState()
					applicantMemberFrame.DetailedInformationPanel:SetShown(not applicantMemberFrame.DetailedInformationPanel:IsVisible())

					applicantFrame:MarkDirty()

				end

			end)

			if(applicantData.comment ~= "" and applicantData.comment ~= nil) then
				applicantMemberFrame.BasicInformationPanel.Comment:Show()

			end

			local playerIsIgnored = C_FriendList.IsIgnored(name)

			local rioLink = "https://raider.io/characters/" .. miog.F.CURRENT_REGION .. "/" .. miog.REALM_LOCAL_NAMES[nameTable[2]] .. "/" .. nameTable[1]

			local nameFontString = applicantMemberFrame.BasicInformationPanel.Name
			nameFontString:SetText(playerIsIgnored and wticc(nameTable[1], "FFFF0000") or wticc(nameTable[1], select(4, GetClassColor(class))))
			nameFontString:SetScript("OnMouseDown", function(_, button)
				if(button == "RightButton") then

					applicantMemberFrame.LinkBox:SetAutoFocus(true)
					applicantMemberFrame.LinkBox:SetText(rioLink)
					applicantMemberFrame.LinkBox:HighlightText()

					applicantMemberFrame.LinkBox:Show()
					applicantMemberFrame.LinkBox:SetAutoFocus(false)

				end
			end)
			nameFontString:SetScript("OnEnter", function()
				GameTooltip:SetOwner(nameFontString, "ANCHOR_CURSOR")

				if(playerIsIgnored) then
					GameTooltip:SetText("Player is on your ignore list")

				else
					if(nameFontString:IsTruncated()) then
						GameTooltip:SetText(nameFontString:GetText())
					end

					if(name == "Rhany-Ravencrest" or name == "Gerhanya-Ravencrest") then
						GameTooltip:AddLine("You've found the creator of this addon.\nHow lucky!")

					end
				end

				GameTooltip:Show()

			end)

			if(miog.F.LITE_MODE) then
				nameFontString:SetWidth(100)
			end

			local specFrame = applicantMemberFrame.BasicInformationPanel.Spec

			if(miog.SPECIALIZATIONS[specID] and class == miog.SPECIALIZATIONS[specID].class.name) then
				specFrame:SetTexture(miog.SPECIALIZATIONS[specID].icon)

			else
				specFrame:SetTexture(miog.SPECIALIZATIONS[0].icon)

			end

			local roleFrame = applicantMemberFrame.BasicInformationPanel.Role
			roleFrame:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. assignedRole .. "Icon.png")

			local primaryIndicator = applicantMemberFrame.BasicInformationPanel.Primary
			local secondaryIndicator = applicantMemberFrame.BasicInformationPanel.Secondary
			local itemLevelFrame = applicantMemberFrame.BasicInformationPanel.ItemLevel

			local reqIlvl = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel or 0

			if(reqIlvl > itemLevel) then
				itemLevelFrame:SetText(wticc(miog.round(itemLevel, 1), miog.CLRSCC["red"]))

			else
				itemLevelFrame:SetText(miog.round(itemLevel, 1))

			end

			applicantMemberFrame.BasicInformationPanel.Friend:SetShown(relationship and true or false)

			if(applicantIndex > 1) then
				applicantMemberFrame.BasicInformationPanel.Premade:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:SetText("Premades with " .. applicantFrame.memberFrames[1].BasicInformationPanel.nameFrame:GetText())
					GameTooltip:Show()

				end)

			end

			local declineButton = applicantMemberFrame.BasicInformationPanel.Decline
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

			local inviteButton = applicantMemberFrame.BasicInformationPanel.Invite
			inviteButton:OnLoad()
			inviteButton:SetScript("OnClick", function()
				C_LFGList.InviteApplicant(applicantID)

				if(miog.F.IS_IN_DEBUG_MODE) then
					updateApplicantStatusFrame(applicantID, "debug")
				end

			end)

			if(applicantIndex == 1 and miog.F.CAN_INVITE or applicantIndex == 1 and miog.F.IS_IN_DEBUG_MODE) then
				declineButton:Show()
				inviteButton:Show()

			end

			miog.createDetailedInformationPanel(applicantFrame, applicantMemberFrame)

			--[[
			ROW LAYOUT

			1-4 Comment
			5 Score for prev. season
			6 Score for main current/prev. season
			7 Applicant alternative roles + race
			8 M+ keys done +5 +10 +15 +20 (+25 not available from Raider.IO addon data)
			9 Region + Realm
 
			]]

			miog.gatherRaiderIODisplayData(nameTable[1], nameTable[2], applicantFrame, applicantMemberFrame)

			local raidData = miog.getRaidSortData(nameTable[1] .. "-" .. nameTable[2])
			primaryIndicator:SetText(wticc(raidData[1].parsedString, raidData[1].current and miog.DIFFICULTY[raidData[1].difficulty].color or miog.DIFFICULTY[raidData[1].difficulty].desaturated))
			secondaryIndicator:SetText(wticc(raidData[2].parsedString, raidData[2].current and miog.DIFFICULTY[raidData[2].difficulty].color or miog.DIFFICULTY[raidData[2].difficulty].desaturated))

			local generalInfoPanel = applicantMemberFrame.DetailedInformationPanel.PanelContainer.ForegroundRows.GeneralInfo

			generalInfoPanel.Right["1"].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. ((applicantData.comment and applicantData.comment) or ""))
			generalInfoPanel.Right["4"].FontString:SetText("Role: ")

			if(tank) then
				generalInfoPanel.Right["4"].FontString:SetText(generalInfoPanel.Right["4"].FontString:GetText() .. miog.C.TANK_TEXTURE)

			end

			if(healer) then
				generalInfoPanel.Right["4"].FontString:SetText(generalInfoPanel.Right["4"].FontString:GetText() .. miog.C.HEALER_TEXTURE)

			end

			if(damager) then
				generalInfoPanel.Right["4"].FontString:SetText(generalInfoPanel.Right["4"].FontString:GetText() .. miog.C.DPS_TEXTURE)

			end

			if(raceID and miog.RACES[raceID]) then
				generalInfoPanel.Right["4"].FontString:SetText(generalInfoPanel.Right["4"].FontString:GetText() ..  " " .. _G["RACE"] .. ": " .. CreateAtlasMarkup(miog.RACES[raceID], miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT))

			end

			local activeEntry = C_LFGList.GetActiveEntryInfo()
			local categoryID = activeEntry and C_LFGList.GetActivityInfoTable(activeEntry.activityID).categoryID

			if(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
				primaryIndicator:SetText(wticc(tostring(pvpData.rating), miog.createCustomColorForScore(pvpData.rating):GenerateHexColor()))

				if(pvpData.tier and pvpData.tier ~= "N/A") then
					local tierResult = miog.simpleSplit(PVPUtil.GetTierName(pvpData.tier), " ")
					secondaryIndicator:SetText(strsub(tierResult[1], 0, tierResult[2] and 2 or 4) .. ((tierResult[2] and "" .. tierResult[2]) or ""))

				else
					secondaryIndicator:SetText(0)
				
				end
			
			elseif(categoryID ~= 3) then
				if(dungeonScore > 0) then
					local reqScore = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or 0
					local highestKeyForDungeon

					if(reqScore > dungeonScore) then
						primaryIndicator:SetText(wticc(tostring(dungeonScore), miog.CLRSCC["red"]))

					else
						primaryIndicator:SetText(wticc(tostring(dungeonScore), miog.createCustomColorForScore(dungeonScore):GenerateHexColor()))

					end

					if(dungeonData) then
						if(dungeonData.finishedSuccess == true) then
							highestKeyForDungeon = wticc(tostring(dungeonData.bestRunLevel), miog.C.GREEN_COLOR)

						elseif(dungeonData.finishedSuccess == false) then
							highestKeyForDungeon = wticc(tostring(dungeonData.bestRunLevel), miog.CLRSCC["red"])

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
			
			
			end

			--BasicInformationPanel:MarkDirty()
			applicantMemberFrame.DetailedInformationPanel:MarkDirty()
			applicantMemberFrame:MarkDirty()

		end

		applicantFrame:MarkDirty()
		applicantSystem.applicantMember[applicantID].status = "indexed"

	end

	--updateApplicantStatusFrame(applicantID, "debug")

end

local function gatherSortData()
	local activeEntry = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo()
	local unsortedMainApplicantsList = {}

	local currentApplicants = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicants() or C_LFGList.GetApplicants()

	if(activeEntry) then
		local categoryID = C_LFGList.GetActivityInfoTable(activeEntry.activityID).categoryID

		for _, applicantID in pairs(currentApplicants) do

			if(applicantSystem.applicantMember[applicantID]) then --CHECK IF ENTRY IS THERE

				local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

				if(applicantSystem.applicantMember[applicantID] and applicantSystem.applicantMember[applicantID].status ~= "removable") then
					if(applicantSystem.applicantMember[applicantID].memberData == nil) then -- FIRST TIME THIS APPLICANT APPLIES?
						applicantSystem.applicantMember[applicantID].memberData = {}

						for applicantIndex = 1, applicantData.numMembers, 1 do
							local name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo

							if(miog.F.IS_IN_DEBUG_MODE) then
								name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

							else
								name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)

							end

							local nameTable = miog.simpleSplit(name, "-")

							if(not nameTable[2]) then
								nameTable[2] = GetNormalizedRealmName()

							end

							applicantSystem.applicantMember[applicantID].memberData[applicantIndex] = {
								name = nameTable[1],
								realm = nameTable[2],
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
									primarySortAttribute = dungeonScore
									secondarySortAttribute = miog.F.IS_IN_DEBUG_MODE and bestDungeonScoreForListing.bestRunLevel or C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activityID).bestRunLevel

								elseif(categoryID == 3) then
									local raidData = miog.getRaidSortData(nameTable[1] .. "-" .. nameTable[2])

									if(raidData) then
										primarySortAttribute = raidData[1].weight
										secondarySortAttribute = raidData[2].weight
				
									else
										primarySortAttribute = 0
										secondarySortAttribute = 0
									
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
								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].index = applicantID
								applicantSystem.applicantMember[applicantID].memberData[applicantIndex].favoured = MIOG_SavedSettings.favouredApplicants.table[applicantSystem.applicantMember[applicantID].memberData[applicantIndex].fullName] and true or false
							end

						end

					end

					unsortedMainApplicantsList[#unsortedMainApplicantsList+1] = applicantSystem.applicantMember[applicantID].memberData

				end
			end
		end
	end

	return unsortedMainApplicantsList
end

local function addOrShowApplicant(applicantID)
	if(applicantSystem.applicantMember[applicantID]) then
		if(applicantSystem.applicantMember[applicantID].frame) then
			applicantSystem.applicantMember[applicantID].frame:Show()

		else
			applicantSystem.applicantMember[applicantID].status = "inProgress"
			createApplicantFrame(applicantID)
			applicantSystem.applicantMember[applicantID].frame:Show()

		end

		applicantSystem.applicantMember[applicantID].frame.layoutIndex = applicationFrameIndex

		applicationFrameIndex = applicationFrameIndex + 1

	end
end

local function checkApplicantListForEligibleMembers(listEntry)
	local categoryID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory

	if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.ApplicationViewer"][categoryID].filterForRoles[listEntry.role] ~= true) then
		return false

	end

	if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.ApplicationViewer"][categoryID].filterForClassSpecs == true) then
		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.ApplicationViewer"][categoryID].classSpec.class[miog.CLASSFILE_TO_ID[listEntry.class]] == false) then
			return false
		
		end

		if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.ApplicationViewer"][categoryID].classSpec.spec[listEntry.specID] == false) then
			return false

		end
	end

	if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.ApplicationViewer"][categoryID].lustFit) then
		if(listEntry.class ~= "HUNTER" and listEntry.class ~= "SHAMAN" and listEntry.class ~= "MAGE" and listEntry.class ~= "EVOKER") then
			return false

		end
	end
	
	if(MIOG_SavedSettings.filterOptions.table["LFGListFrame.ApplicationViewer"][categoryID].ressFit) then
		if(listEntry.class ~= "PALADIN" and listEntry.class ~= "DEATHKNIGHT" and listEntry.class ~= "WARLOCK" and listEntry.class ~= "DRUID") then
			return false

		end
	end

	return true
end

local function checkApplicantList(forceReorder, applicantID)
	local unsortedList = gatherSortData()

	if(forceReorder) then
		local updatedFrames = {}

		applicationFrameIndex = 0

		if(unsortedList[1]) then
			table.sort(unsortedList, sortApplicantList)

			local time = GetTime()

			for d, listEntry in ipairs(unsortedList) do

				for _, v in pairs(listEntry) do
					if(checkApplicantListForEligibleMembers(v) == true) then
						updatedFrames[listEntry[1].index] = true
						addOrShowApplicant(listEntry[1].index)
						break
					
					end
				end
			end
		end

		for index, v in pairs(applicantSystem.applicantMember) do
			if(not updatedFrames[index] and v.frame) then
				v.frame:Hide()
	
			end
		end

	else
		addOrShowApplicant(applicantID)

	end

	miog.Plugin.FooterBar.Results:SetText(applicationFrameIndex .. "(" .. #unsortedList .. ")")
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
		comment = "Tettles is question mark spam pinging me, please help.",
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
		highestKey = rioProfile.mythicKeystoneProfile.fortifiedMaxDungeonLevel > rioProfile.mythicKeystoneProfile.tyrannicalMaxDungeonLevel and
		rioProfile.mythicKeystoneProfile.fortifiedMaxDungeonLevel or rioProfile.mythicKeystoneProfile.tyrannicalMaxDungeonLevel
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

		miog.DEBUG_APPLICANT_DATA[applicantID] = {
			applicantID = applicantID,
			applicationStatus = "applied",
			numMembers = random(1, 1),
			isNew = true,
			comment = "Tettles is question mark spam pinging me, please help.",
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
				highestKey = rioProfile.mythicKeystoneProfile.fortifiedMaxDungeonLevel > rioProfile.mythicKeystoneProfile.tyrannicalMaxDungeonLevel and
				rioProfile.mythicKeystoneProfile.fortifiedMaxDungeonLevel or rioProfile.mythicKeystoneProfile.tyrannicalMaxDungeonLevel
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

        if(isInitialLogin or isReloadingUi) then
        else
            hideAllApplicantFrames()

        end
	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then --LISTING CHANGES
		miog.F.ACTIVE_ENTRY_INFO = C_LFGList.GetActiveEntryInfo()

		if(miog.F.ACTIVE_ENTRY_INFO) then
			miog.insertLFGInfo()
		end

		if(... == nil) then --DELIST
			if not(miog.F.ACTIVE_ENTRY_INFO) then
				if(queueTimer) then
					queueTimer:Cancel()

				end

				resetArrays()
				releaseApplicantFrames()

				miog.ApplicationViewer.CreationSettings.Timer:SetText("00:00:00")

				miog.ApplicationViewer:Hide()

				if(miog.F.WEEKLY_AFFIX == nil) then
					miog.setAffixes()

				end
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
				v.frame.memberFrames[1].BasicInformationPanel.Invite:SetShown(canInvite)
				v.frame.memberFrames[1].BasicInformationPanel.Decline:SetShown(canInvite)

			end
		end
	elseif(event == "GROUP_ROSTER_UPDATE") then
		local canInvite = miog.checkIfCanInvite()

		for _,v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame.memberFrames[1].BasicInformationPanel.Invite:SetShown(canInvite)
				v.frame.memberFrames[1].BasicInformationPanel.Decline:SetShown(canInvite)

			end
		end
	end

end

miog.createApplicationViewer = function()
	local applicationViewer = CreateFrame("Frame", "MythicIOGrabber_ApplicationViewer", miog.Plugin.InsertFrame, "MIOG_ApplicationViewer") ---@class Frame
	miog.ApplicationViewer = applicationViewer

	miog.createFrameBorder(applicationViewer, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.TitleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.InfoPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.CreationSettings, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.createFrameBorder(applicationViewer.ButtonPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local classPanel = applicationViewer.ClassPanel

	classPanel:SetHeight(miog.F.LITE_MODE and 22 or 25)

	classPanel.classFrames = {}

	for classID, classEntry in ipairs(miog.CLASSES) do
		local classFrame = CreateFrame("Frame", nil, classPanel, "MIOG_ClassPanelClassFrameTemplate")
		classFrame.layoutIndex = classID
		classFrame:SetSize(classPanel:GetHeight(), classPanel:GetHeight())

		classFrame.Icon:SetTexture(classEntry.icon)
		classFrame.rightPadding = 3
		classPanel.classFrames[classID] = classFrame

		local specPanel = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", classFrame)
		specPanel:SetPoint("TOP", classFrame, "BOTTOM", 0, -5)
		specPanel.fixedHeight = classFrame:GetHeight() - 3
		specPanel.specFrames = {}
		specPanel:Hide()
		classFrame.specPanel = specPanel

		local specCounter = 1

		for _, specID in ipairs(classEntry.specs) do
			local specFrame = CreateFrame("Frame", nil, specPanel, "MIOG_ClassPanelSpecFrameTemplate")
			specFrame:SetSize(specPanel.fixedHeight, specPanel.fixedHeight)
			specFrame.Icon:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
			specFrame.layoutIndex = specCounter
			specFrame.leftPadding = 0

			specPanel.specFrames[specID] = specFrame

			specCounter = specCounter + 1
		end

		specPanel:MarkDirty()

		classFrame:SetScript("OnEnter", function()
			specPanel:Show()

		end)
		classFrame:SetScript("OnLeave", function()
			specPanel:Hide()

		end)
	end

	classPanel:MarkDirty()

	applicationViewer.TitleBar.Faction:SetTexture(2437241)
	applicationViewer.InfoPanel.Background:SetTexture(miog.ACTIVITY_BACKGROUNDS[10])

	applicationViewer.ButtonPanel.sortByCategoryButtons = {}

	for i = 1, 4, 1 do
		local sortByCategoryButton = applicationViewer.ButtonPanel[i == 1 and "RoleSort" or i == 2 and "PrimarySort" or i == 3 and "SecondarySort" or i == 4 and "IlvlSort"]
		sortByCategoryButton.panel = "ApplicationViewer"
		sortByCategoryButton.category = i == 1 and "role" or i == 2 and "primary" or i == 3 and "secondary" or i == 4 and "ilvl"

		sortByCategoryButton:SetScript("PostClick", function(self, button)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			C_LFGList.RefreshApplicants()
		end)

		applicationViewer.ButtonPanel.sortByCategoryButtons[sortByCategoryButton.category] = sortByCategoryButton

	end

	applicationViewer.ButtonPanel["RoleSort"]:AdjustPointsOffset(miog.Plugin:GetWidth() * 0.402, 0)
	
	applicationViewer.ButtonPanel.ResetButton:SetScript("OnClick",
		function()
			C_LFGList.RefreshApplicants()

			miog.ApplicationViewer.FramePanel:SetVerticalScroll(0)
		end
	)

	local browseGroupsButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.ApplicationViewer, 1, 20)
	browseGroupsButton:SetPoint("LEFT", miog.Plugin.FooterBar.Back, "RIGHT")
	browseGroupsButton:SetText("Browse")
	browseGroupsButton:FitToText()
	browseGroupsButton:RegisterForClicks("LeftButtonDown")
	browseGroupsButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		local baseFilters = LFGListFrame.baseFilters
		local searchPanel = LFGListFrame.SearchPanel
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		if(activeEntryInfo) then
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
			if(activityInfo) then
				LFGListSearchPanel_SetCategory(searchPanel, activityInfo.categoryID, activityInfo.filters, baseFilters)
				LFGListSearchPanel_DoSearch(searchPanel)
				LFGListFrame_SetActivePanel(LFGListFrame, searchPanel)
			end
		end
	end)

	miog.ApplicationViewer.browseGroupsButton = browseGroupsButton

	local delistButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.ApplicationViewer, 1, 20)
	delistButton:SetPoint("LEFT", browseGroupsButton, "RIGHT")
	delistButton:SetText("Delist")
	delistButton:FitToText()
	delistButton:RegisterForClicks("LeftButtonDown")
	delistButton:SetScript("OnClick", function()
		C_LFGList.RemoveListing()
	end)

	miog.ApplicationViewer.delistButton = delistButton

	local editButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.ApplicationViewer, 1, 20)
	editButton:SetPoint("LEFT", delistButton, "RIGHT")
	editButton:SetText("Edit")
	editButton:FitToText()
	editButton:RegisterForClicks("LeftButtonDown")
	editButton:SetScript("OnClick", function()
		local entryCreation = LFGListFrame.EntryCreation
		LFGListEntryCreation_SetEditMode(entryCreation, true)
		LFGListFrame_SetActivePanel(LFGListFrame, entryCreation)
	end)

	miog.ApplicationViewer.editButton = editButton

	miog.ApplicationViewer.CreationSettings.EditBox.UpdateButton:SetScript("OnClick", function(self)
		LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)

		local editbox = miog.ApplicationViewer.CreationSettings.EditBox
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

	miog.ApplicationViewer.CreationSettings.EditBox:SetScript("OnEnterPressed", miog.ApplicationViewer.CreationSettings.EditBox.UpdateButton:GetScript("OnClick"))

	miog.ApplicationViewer.InfoPanel.Description.Container:SetSize(miog.ApplicationViewer.InfoPanel.Description:GetSize())

	miog.ApplicationViewer.InfoPanel.Description:SetScript("OnMouseDown", function(self)
		if(self.lastClick and 0.2 > GetTime() - self.lastClick) then
			--miog.EntryCreation.Description:SetParent(miog.ApplicationViewer.InfoPanel)
			--miog.ApplicationViewer.CreationSettings.EditBox.UpdateButton:SetPoint("LEFT", miog.EntryCreation.Description, "RIGHT")
		end
	
		self.lastClick = GetTime()
	end)
	
	miog.ApplicationViewer.CreationSettings.ItemLevel:SetScript("OnMouseDown", function(self)
		if(self.lastClick and 0.2 > GetTime() - self.lastClick) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			showEditBox("ItemLevel", self.FontString, true, 3)
		end
	
		self.lastClick = GetTime()
	end)

	miog.ApplicationViewer.CreationSettings.Rating:SetScript("OnMouseDown", function(self)
		if(self.lastClick and 0.2 > GetTime() - self.lastClick) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			showEditBox("Rating", self.FontString, true, 4)
		end
	
		self.lastClick = GetTime()
	end)
	PlaySound(SOUNDKIT.UI_PROFESSION_HIDE_UNOWNED_REAGENTS_CHECKBOX)

	miog.ApplicationViewer.CreationSettings.PrivateGroup:SetScript("OnMouseDown", function()
		LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)

		miog.EntryCreation.PrivateGroup:SetChecked(not miog.EntryCreation.PrivateGroup:GetChecked())
		miog.listGroup()
		miog.insertLFGInfo()
	end)

	miog.ApplicationViewer:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
	miog.ApplicationViewer:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
	miog.ApplicationViewer:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
	miog.ApplicationViewer:RegisterEvent("PARTY_LEADER_CHANGED")
	miog.ApplicationViewer:SetScript("OnEvent", applicationViewerEvents)

	MIOG_SYSTEM = miog
end