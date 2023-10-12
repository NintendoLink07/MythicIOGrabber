local addonName, miog = ...

local addonApplicantList = {}
local expandedFrameList = {}

local lastApplicantFrame
local applicantFramePadding = 6

local debugLFGList = {}
local debugApplicantIDList = {}

local queueTimer

local function timeInQueue()
	local time = miog.secondsToClock(GetTimePreciseSec() - MIOG_QueueUpTime)
	miog.mainFrame.infoPanel.timerFrame.FontString:SetText(time)
end

local function refreshFunction()
	miog.releaseAllFleetingWidgets()

	lastApplicantFrame = nil
	addonApplicantList = {}
	debugLFGList = {}
	debugApplicantIDList = {}

	miog.F.APPLIED_NUM_OF_DPS = 0
	miog.F.APPLIED_NUM_OF_HEALERS = 0
	miog.F.APPLIED_NUM_OF_TANKS = 0

	miog.mainFrame.buttonPanel.RoleTextures[1].text:SetText(miog.F.APPLIED_NUM_OF_TANKS)
	miog.mainFrame.buttonPanel.RoleTextures[2].text:SetText(miog.F.APPLIED_NUM_OF_HEALERS)
	miog.mainFrame.buttonPanel.RoleTextures[3].text:SetText(miog.F.APPLIED_NUM_OF_DPS)

	miog.mainFrame.applicantPanel.container:MarkDirty()
end

local function changeApplicantStatus(applicantID, frame, string, color)
	if(frame.inviteButton) then
		frame.inviteButton:Disable()
	end

	for _, memberFrame in pairs(frame.memberFrames) do
		memberFrame.statusFrame:Show()
		memberFrame.statusFrame.FontString:SetText(WrapTextInColorCode(string, color))
	end

	if(string == "INVITED") then
		addonApplicantList[applicantID]["creationStatus"] = "invited"
	else
		addonApplicantList[applicantID]["creationStatus"] = "canBeRemoved"
	end
end

local function addApplicantToPanel(applicantID)
	local applicantData

	if(miog.F.IS_IN_DEBUG_MODE) then
		applicantData = debugLFGList[applicantID]
	else
		applicantData = C_LFGList.GetApplicantInfo(applicantID)
	end

	if(applicantData) then
		local applicantMemberPadding = 2
		local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityID or 0

		expandedFrameList[applicantID] = expandedFrameList[applicantID] or {}

		local applicantFrame = miog.createBasicFrame("fleeting", "ResizeLayoutFrame, BackdropTemplate", miog.mainFrame.applicantPanel.container)
		applicantFrame.fixedWidth = miog.mainFrame.applicantPanel:GetWidth() - 2
		applicantFrame.minimumHeight = applicantData.numMembers * miog.C.APPLICANT_MEMBER_HEIGHT + applicantMemberPadding * (applicantData.numMembers-1) + 2
		applicantFrame.heightPadding = 1
		applicantFrame:SetPoint("TOP", lastApplicantFrame or miog.mainFrame.applicantPanel.container, lastApplicantFrame and "BOTTOM" or "TOP", 0, lastApplicantFrame and -applicantFramePadding or 0)
		applicantFrame.memberFrames = {}

		miog.mainFrame.applicantPanel.container.lastApplicantFrame = applicantFrame

		miog.createFrameBorder(applicantFrame, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

		for applicantIndex = 1, applicantData.numMembers, 1 do
			local fullName, englishClassName, _, _, ilvl, _, tank, healer, damager, assignedRole, friend, dungeonScore, dataForDungeon
			
			if(miog.F.IS_IN_DEBUG_MODE) then
				fullName = applicantData.applicantMemberList[applicantIndex].fullName
				englishClassName = applicantData.applicantMemberList[applicantIndex].englishClassName
				ilvl = applicantData.applicantMemberList[applicantIndex].ilvl
				tank = applicantData.applicantMemberList[applicantIndex].tank
				healer = applicantData.applicantMemberList[applicantIndex].healer
				damager = applicantData.applicantMemberList[applicantIndex].damager
				assignedRole = applicantData.applicantMemberList[applicantIndex].assignedRole
				friend = applicantData.applicantMemberList[applicantIndex].friend
				dungeonScore = applicantData.applicantMemberList[applicantIndex].dungeonScore
				dataForDungeon = applicantData.applicantMemberList[applicantIndex].dataForDungeon

			else
				fullName, englishClassName, _, _, ilvl, _, tank, healer, damager, assignedRole, friend, dungeonScore = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)
				dataForDungeon = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, applicantIndex, activityID)

			end

			local nameTable = miog.simpleSplit(fullName, "-")

			local profile, mythicKeystoneProfile, dungeonProfile, raidProfile
			
			if(IsAddOnLoaded("RaiderIO")) then
				profile = RaiderIO.GetProfile(nameTable[1], nameTable[2], miog.C.REGIONS[GetCurrentRegion()])
				--profile = RaiderIO.GetProfile("Drjay", "Ragnaros", miog.C.REGIONS[GetCurrentRegion()])
				
				if(profile ~= nil) then
					mythicKeystoneProfile = profile.mythicKeystoneProfile
					raidProfile = profile.raidProfile

					if(mythicKeystoneProfile ~= nil) then
						dungeonProfile = mythicKeystoneProfile.sortedDungeons

						if(dungeonProfile ~= nil) then
							table.sort(dungeonProfile, function(k1, k2) return k1.dungeon.index < k2.dungeon.index end)
						end
					end
					
				end
			end

			local applicantMemberFrame = miog.createBasicFrame("fleeting", "ResizeLayoutFrame, BackdropTemplate", applicantFrame)
			applicantMemberFrame.fixedWidth = applicantFrame.fixedWidth - 2
			applicantMemberFrame.minimumHeight = 20
			applicantMemberFrame:SetPoint("TOP", applicantFrame.memberFrames[applicantIndex-1] or applicantFrame, applicantFrame.memberFrames[applicantIndex-1] and "BOTTOM" or "TOP", 0, applicantIndex > 1 and -applicantMemberPadding or -1)

			applicantMemberFrame:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=miog.C.APPLICANT_MEMBER_HEIGHT, tile=true, edgeSize=1})
			applicantMemberFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
			applicantMemberFrame:SetBackdropBorderColor(0,0,0,0)
			applicantFrame.memberFrames[applicantIndex] = applicantMemberFrame
			
			local applicantMemberStatusFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", applicantFrame, nil, nil, "fontstring")
			applicantMemberStatusFrame:Hide()
			applicantMemberStatusFrame:SetPoint("TOPLEFT", applicantMemberFrame, "TOPLEFT", 0, 0)
			applicantMemberStatusFrame:SetPoint("BOTTOMRIGHT", applicantMemberFrame, "BOTTOMRIGHT", 0, 0)
			applicantMemberStatusFrame:SetFrameStrata("FULLSCREEN")
			applicantMemberStatusFrame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=false, edgeSize=1} )
			applicantMemberStatusFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.7)

			applicantMemberStatusFrame.FontString:SetJustifyH("CENTER")
			applicantMemberStatusFrame.FontString:SetWidth(applicantMemberFrame.fixedWidth)
			applicantMemberStatusFrame.FontString:SetPoint("TOP", applicantMemberStatusFrame, "TOP", 0, -2)
			applicantMemberStatusFrame.FontString:Show()

			applicantMemberFrame.statusFrame = applicantMemberStatusFrame

			--changeApplicantStatus(applicantID, applicantFrame, "GONE BABY", "FFFF0000")

			local basicInformationPanel = miog.createBasicFrame("fleeting", "ResizeLayoutFrame, BackdropTemplate", applicantMemberFrame)
			basicInformationPanel.fixedWidth = applicantMemberFrame.fixedWidth
			basicInformationPanel.maximumHeight = miog.C.APPLICANT_MEMBER_HEIGHT
			basicInformationPanel:SetPoint("TOPLEFT", applicantMemberFrame, "TOPLEFT", 0, 0)
			applicantMemberFrame.basicInformationPanel = basicInformationPanel

			local expandFrameButton = Mixin(miog.createBasicFrame("fleeting", "UIButtonTemplate", basicInformationPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), TripleStateButtonMixin)
			expandFrameButton:OnLoad()
			expandFrameButton:SetMaxStates(2)
			expandFrameButton:SetTexturesForBaseState("UI-HUD-ActionBar-PageDownArrow-Up", "UI-HUD-ActionBar-PageDownArrow-Down", "UI-HUD-ActionBar-PageDownArrow-Mouseover", "UI-HUD-ActionBar-PageDownArrow-Disabled")
			expandFrameButton:SetTexturesForState1("UI-HUD-ActionBar-PageUpArrow-Up", "UI-HUD-ActionBar-PageUpArrow-Down", "UI-HUD-ActionBar-PageUpArrow-Mouseover", "UI-HUD-ActionBar-PageUpArrow-Disabled")
			expandFrameButton:SetState(false)

			expandFrameButton:SetPoint("LEFT", basicInformationPanel, "LEFT", 0, 0)
			expandFrameButton:SetFrameStrata("DIALOG")
			
			if(expandedFrameList[applicantID][applicantIndex]) then
				expandFrameButton:AdvanceState()
				expandFrameButton:SetChecked(true)
			else

				expandFrameButton:SetChecked(false)
			end

			expandFrameButton:RegisterForClicks("LeftButtonDown")
			expandFrameButton:SetScript("OnClick", function()
				expandFrameButton:AdvanceState()
				expandedFrameList[applicantID][applicantIndex] = not applicantMemberFrame.detailedInformationPanel:IsVisible()

				applicantMemberFrame.detailedInformationPanel:SetShown(not applicantMemberFrame.detailedInformationPanel:IsVisible())

				applicantFrame:MarkDirty()
			end)
			basicInformationPanel.expandButton = expandFrameButton

			local shortName = strsub(nameTable[1], 0, 20)
			local coloredSubName = WrapTextInColorCode(shortName, select(4, GetClassColor(englishClassName)))

			local nameFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.fixedWidth * 0.27, basicInformationPanel.maximumHeight, "fontstring", miog.C.APPLICANT_MEMBER_FONT_SIZE)
			nameFrame:SetPoint("LEFT", expandFrameButton, "RIGHT", 3, 0)
			nameFrame.FontString:SetText(coloredSubName)
			nameFrame:SetScript("OnMouseDown", function(_, button)
				if(button == "RightButton") then
					local link = "https://raider.io/characters/" .. miog.C.REGIONS[GetCurrentRegion()] .. "/" .. nameTable[2] .. "/" .. nameTable[1]

					nameFrame.linkBox:SetAutoFocus(true)
					nameFrame.linkBox:SetText(link)
					nameFrame.linkBox:HighlightText()

					nameFrame.linkBox:Show()
					nameFrame.linkBox:SetAutoFocus(false)
				end
			end)
			nameFrame:SetMouseMotionEnabled(true)
			nameFrame:SetScript("OnEnter", function()
				if(nameFrame.FontString:IsTruncated()) then
					GameTooltip:SetOwner(nameFrame, "ANCHOR_CURSOR")
					GameTooltip:SetText(nameFrame.FontString:GetText())
					GameTooltip:Show()
				end
			end)
			nameFrame:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			nameFrame.linkBox = miog.createBasicFrame("fleeting", "InputBoxTemplate", WorldFrame, 250, miog.C.APPLICANT_MEMBER_HEIGHT)
			nameFrame.linkBox:SetFont(miog.FONTS["libMono"], 7, "OUTLINE")
			nameFrame.linkBox:SetPoint("CENTER")
			nameFrame.linkBox:SetAutoFocus(true)
			nameFrame.linkBox:SetScript("OnKeyDown", function(_, key)
				if(key == "ESCAPE") then
					nameFrame.linkBox:Hide()
					nameFrame.linkBox:ClearFocus()
				end
			end)
			nameFrame.linkBox:Hide()

			local commentFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight, "texture", 136459)
			commentFrame:SetPoint("LEFT", nameFrame, "RIGHT", 0, 0)
			
			if(applicantData.comment == "") then
				commentFrame:Hide()
			end
	
			local roleFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.maximumHeight - 1, basicInformationPanel.maximumHeight - 1, "texture")
			roleFrame:SetPoint("LEFT", commentFrame, "RIGHT", 1, 0)


			if(assignedRole == "DAMAGER") then
				roleFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/dpsSuperSmallIcon.png")

			elseif(assignedRole == "HEALER") then
				roleFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/healerSuperSmallIcon.png")

			elseif(assignedRole == "TANK") then
				roleFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/tankSuperSmallIcon.png")

			end

			local primaryIndicator = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.fixedWidth*0.11, basicInformationPanel.maximumHeight, "fontstring", miog.C.APPLICANT_MEMBER_FONT_SIZE)
			primaryIndicator:SetPoint("LEFT", roleFrame, "RIGHT", 5, 0)
			primaryIndicator.FontString:SetJustifyH("CENTER")

			local secondaryIndicator = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.fixedWidth*0.1, basicInformationPanel.maximumHeight, "fontstring", miog.C.APPLICANT_MEMBER_FONT_SIZE)
			secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 1, 0)
			secondaryIndicator.FontString:SetJustifyH("CENTER")

			if(miog.F.LISTED_CATEGORY_ID == 2 or miog.F.IS_IN_DEBUG_MODE) then

				local reqScore = C_LFGList:HasActiveEntryInfo() and C_LFGList:GetActiveEntryInfo().requiredDungeonScore or 0
				local highestKeyForDungeon

				if(reqScore > dungeonScore) then
					primaryIndicator.FontString:SetText("|cFFFF0000" .. dungeonScore .. "|r")

				else
					primaryIndicator.FontString:SetText(WrapTextInColorCode(tostring(dungeonScore), C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore):GenerateHexColor()))

				end

				if(dataForDungeon) then
					if(dataForDungeon.finishedSuccess == true) then
						highestKeyForDungeon = WrapTextInColorCode(tostring(dataForDungeon.bestRunLevel), miog.C.GREEN_COLOR)

					elseif(dataForDungeon.finishedSuccess == false) then
						highestKeyForDungeon = WrapTextInColorCode(tostring(dataForDungeon.bestRunLevel), miog.C.RED_COLOR)

					end
				else
					highestKeyForDungeon = WrapTextInColorCode(tostring(0), miog.C.RED_COLOR)

				end

				secondaryIndicator.FontString:SetText(highestKeyForDungeon)

			elseif(miog.F.LISTED_CATEGORY_ID == 3) then
				if(profile) then
					if(profile.raidProfile) then
						for i = 1, 2, 1 do
							if(profile.raidProfile.sortedProgress[i] and not profile.raidProfile.sortedProgress[i].isMainProgress) then
								local highestDifficulty = profile.raidProfile.sortedProgress[i].progress.difficulty
								local difficulty = miog.C.DIFFICULTY[highestDifficulty]
								local bossCount = profile.raidProfile.sortedProgress[i].progress.raid.bossCount
								local kills = profile.raidProfile.sortedProgress[i].progress.progressCount or 0

								local progressString = WrapTextInColorCode(kills .. "/" .. bossCount, difficulty.color:GenerateHexColor())

								if(i == 1) then
									primaryIndicator.FontString:SetText(progressString)

								else
									secondaryIndicator.FontString:SetText(progressString)

								end
							else
								if(i == 1) then
									primaryIndicator.FontString:SetText("0/9")

								else
									secondaryIndicator.FontString:SetText("0/9")

								end
							end
						end
					else
						primaryIndicator.FontString:SetText(WrapTextInColorCode("---", miog.C.RED_COLOR))
						secondaryIndicator.FontString:SetText(WrapTextInColorCode("---", miog.C.RED_COLOR))

					end
				else
					primaryIndicator.FontString:SetText("0/9")
					secondaryIndicator.FontString:SetText("0/9")

				end
			elseif(miog.F.LISTED_CATEGORY_ID == 4 or miog.F.LISTED_CATEGORY_ID == 7 or miog.F.LISTED_CATEGORY_ID == 8 or miog.F.LISTED_CATEGORY_ID == 9) then

				local pvpRatingInfo

				if(miog.F.IS_IN_DEBUG_MODE) then
					pvpRatingInfo = {
						bracket = "2v2",
						rating = 3000,
						activityName = "XD",
						tier = "Elite X"
					}

				else
					pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, applicantIndex, activityID)

				end

				primaryIndicator.FontString:SetText(WrapTextInColorCode(tostring(pvpRatingInfo.rating), C_ChallengeMode.GetDungeonScoreRarityColor(pvpRatingInfo.rating):GenerateHexColor()))

				local tierResult = miog.simpleSplit(pvpRatingInfo.tier, " ")
				secondaryIndicator.FontString:SetText(strsub(tierResult[1], 0, 2) .. "" .. tierResult[2])

			end

			local itemLevelFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.fixedWidth*0.13, basicInformationPanel.maximumHeight, "fontstring", miog.C.APPLICANT_MEMBER_FONT_SIZE)
			itemLevelFrame.FontString:SetJustifyH("CENTER")
			itemLevelFrame:SetPoint("LEFT", secondaryIndicator, "RIGHT", 1, 0)

			local reqIlvl = C_LFGList:HasActiveEntryInfo() and C_LFGList:GetActiveEntryInfo().requiredItemLevel or 0

			if(reqIlvl > ilvl) then
				
				itemLevelFrame.FontString:SetText("|cFFFF0000" .. miog.round(ilvl, 1) .. "|r")

			else
				itemLevelFrame.FontString:SetText(miog.round(ilvl, 1))

			end

			local friendTexture = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.maximumHeight - 3, basicInformationPanel.maximumHeight - 3, "texture", miog.C.STANDARD_FILE_PATH .. "/infoIcons/friend.png")
			friendTexture:SetPoint("LEFT", itemLevelFrame, "RIGHT", 3, 0)
			friendTexture:SetShown(friend or false)
			friendTexture:SetMouseMotionEnabled(true)
			friendTexture:SetScript("OnEnter", function()
				GameTooltip:SetOwner(friendTexture, "ANCHOR_CURSOR")
				GameTooltip:SetText("On your friendlist")
				GameTooltip:Show()
			end)
			friendTexture:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			if(applicantIndex > 1) then
				local groupTexture = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.maximumHeight - 3, basicInformationPanel.maximumHeight - 3, "texture", miog.C.STANDARD_FILE_PATH .. "/infoIcons/link.png") --134148
				groupTexture:SetPoint("TOPRIGHT", basicInformationPanel, "TOPRIGHT", -1, -1)
				groupTexture:SetMouseMotionEnabled(true)
				groupTexture:SetScript("OnEnter", function()
					GameTooltip:SetOwner(groupTexture, "ANCHOR_CURSOR")
					GameTooltip:SetText("Premade of " .. (applicantData.applicantMemberList[1] and applicantData.applicantMemberList[1].fullName) or C_LFGList.GetApplicantMemberInfo(applicantID, 1))
					GameTooltip:Show()
				end)
				groupTexture:SetScript("OnLeave", function()
					GameTooltip:Hide()
				end)
			end

			local allowedToInvite = C_PartyInfo.CanInvite()

			if(applicantIndex == 1 and allowedToInvite or applicantIndex == 1 and miog.F.IS_IN_DEBUG_MODE) then
				local declineButton = miog.createBasicFrame("fleeting", "IconButtonTemplate", basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight)
				declineButton.icon = miog.C.STANDARD_FILE_PATH .. "/xSmallIcon.png"
				declineButton.iconSize = basicInformationPanel.maximumHeight - 4
				declineButton:OnLoad()
				declineButton:SetPoint("RIGHT", basicInformationPanel, "RIGHT", 0, 0)
				declineButton:SetFrameStrata("DIALOG")
				declineButton:RegisterForClicks("LeftButtonDown")
				declineButton:SetScript("OnClick", function()
					if(addonApplicantList[applicantID]["creationStatus"] == "added") then

						addonApplicantList[applicantID]["creationStatus"] = "canBeRemoved"
						addonApplicantList[applicantID]["appStatus"] = "declined"
						C_LFGList.DeclineApplicant(applicantID)

					elseif(addonApplicantList[applicantID]["creationStatus"] == "canBeRemoved") then
						miog.checkApplicantList(true)

						miog.mainFrame.applicantPanel.container:MarkDirty()
					end
				end)
				applicantMemberFrame.basicInformationPanel.declineButton = declineButton

				local inviteButton = miog.createBasicFrame("fleeting", "IconButtonTemplate", basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight)
				inviteButton.icon = miog.C.STANDARD_FILE_PATH .. "/checkmarkSmallIcon.png"
				inviteButton.iconSize = basicInformationPanel.maximumHeight - 4
				inviteButton:SetFrameStrata("DIALOG")
				inviteButton:OnLoad()
				inviteButton:SetPoint("RIGHT", declineButton, "LEFT")
				inviteButton:RegisterForClicks("LeftButtonDown")
				inviteButton:SetScript("OnClick", function()
					C_LFGList.InviteApplicant(applicantID)
				end)

				applicantMemberFrame.basicInformationPanel.inviteButton = inviteButton
			end
			
			local detailedInformationPanel = miog.createBasicFrame("fleeting", "ResizeLayoutFrame, BackdropTemplate", applicantMemberFrame)
			detailedInformationPanel:SetWidth(basicInformationPanel.fixedWidth)

			detailedInformationPanel:SetPoint("TOPLEFT", basicInformationPanel, "BOTTOMLEFT", 0, 1)
			detailedInformationPanel:SetShown(expandFrameButton:GetChecked())

			applicantMemberFrame.detailedInformationPanel = detailedInformationPanel

			local tabPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel)
			tabPanel:SetPoint("TOPLEFT", detailedInformationPanel, "TOPLEFT")
			tabPanel:SetPoint("TOPRIGHT", detailedInformationPanel, "TOPRIGHT")
			tabPanel:SetHeight(miog.C.APPLICANT_MEMBER_HEIGHT)
			tabPanel.textRows = {}

			detailedInformationPanel.tabPanel = tabPanel

			local mythicPlusTabButton = miog.createBasicFrame("fleeting", "UIPanelButtonTemplate", tabPanel)
			mythicPlusTabButton:SetSize(detailedInformationPanel:GetWidth()/2, miog.C.APPLICANT_MEMBER_HEIGHT)
			mythicPlusTabButton:SetPoint("LEFT", tabPanel, "LEFT")
			mythicPlusTabButton:SetFrameStrata("DIALOG")
			mythicPlusTabButton:SetText("Mythic+")
			mythicPlusTabButton:RegisterForClicks("LeftButtonDown")
			mythicPlusTabButton:SetScript("OnClick", function()
				tabPanel.mythicPlusPanel:Show()
				tabPanel.raidPanel:Hide()

				detailedInformationPanel:SetHeight(tabPanel.mythicPlusPanel:GetHeight() + 20)
				detailedInformationPanel:MarkDirty()
				applicantFrame:MarkDirty()
			end)
			tabPanel.mythicPlusTabButton = mythicPlusTabButton

			local raidTabButton = miog.createBasicFrame("fleeting", "UIPanelButtonTemplate", tabPanel)
			raidTabButton:SetSize(detailedInformationPanel:GetWidth()/2, miog.C.APPLICANT_MEMBER_HEIGHT)
			raidTabButton:SetPoint("LEFT", mythicPlusTabButton, "RIGHT")
			raidTabButton:SetFrameStrata("DIALOG")
			raidTabButton:SetText("Raid")
			raidTabButton:RegisterForClicks("LeftButtonDown")
			raidTabButton:SetScript("OnClick", function()
				tabPanel.mythicPlusPanel:Hide()
				tabPanel.raidPanel:Show()

				detailedInformationPanel:SetHeight(tabPanel.raidPanel:GetHeight() + 20)
				detailedInformationPanel:MarkDirty()
				applicantFrame:MarkDirty()
			end)
			tabPanel.raidTabButton = raidTabButton

			local mostBosses = 0

			for key, value in pairs(miog.RAID_ICONS) do
				mostBosses = #value-1 > mostBosses and #value-1 or mostBosses
			end

			local raidPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, detailedInformationPanel:GetWidth()/2, (mostBosses) * 20)
			raidPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
			tabPanel.raidPanel = raidPanel
			raidPanel:SetShown(miog.F.LISTED_CATEGORY_ID == 3 and true)
			raidPanel.rows = {}

			local mythicPlusPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, detailedInformationPanel:GetWidth()/2, 8 * 20)
			mythicPlusPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
			tabPanel.mythicPlusPanel = mythicPlusPanel
			mythicPlusPanel:SetShown(miog.F.LISTED_CATEGORY_ID ~= 3 and true)
			mythicPlusPanel.rows = {}

			local generalInfoPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, detailedInformationPanel:GetWidth()/2, 8 * 20)
			generalInfoPanel:SetPoint("TOPRIGHT", tabPanel, "BOTTOMRIGHT")
			tabPanel.generalInfoPanel = generalInfoPanel
			generalInfoPanel.rows = {}

			for rowIndex = 1, mostBosses, 1 do
				local remainder = math.fmod(rowIndex, 2)

				local textRowFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel)
				textRowFrame:SetSize(detailedInformationPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT)
				textRowFrame:SetPoint("TOPLEFT", tabPanel.textRows[rowIndex-1] or mythicPlusTabButton, "BOTTOMLEFT")

				if(remainder == 1) then
					textRowFrame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=miog.C.APPLICANT_MEMBER_HEIGHT, tile=false, edgeSize=1} )
					textRowFrame:SetBackdropColor(CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())
				else
					textRowFrame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=miog.C.APPLICANT_MEMBER_HEIGHT, tile=false, edgeSize=1} )
					textRowFrame:SetBackdropColor(CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA())
				end

				local divider = miog.createBasicTexture("fleeting", nil, textRowFrame, textRowFrame:GetWidth(), 2, "BORDER")
				divider:SetAtlas("UI-LFG-DividerLine")
				divider:SetPoint("BOTTOM", textRowFrame, "BOTTOM", 0, -1)

				tabPanel.textRows[rowIndex] = textRowFrame

				local textRowRaid = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
				textRowRaid:SetPoint("LEFT", tabPanel.textRows[rowIndex], "LEFT")
				raidPanel.rows[rowIndex] = textRowRaid

				if(rowIndex < 9) then

					local textRowMythicPlus = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, mythicPlusPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
					textRowMythicPlus:SetPoint("LEFT", tabPanel.textRows[rowIndex], "LEFT")
					mythicPlusPanel.rows[rowIndex] = textRowMythicPlus

					local textRowGeneralInfo = miog.createBasicFrame("fleeting", "BackdropTemplate", generalInfoPanel, generalInfoPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
					textRowGeneralInfo.FontString:SetJustifyH("CENTER")
					textRowGeneralInfo:SetPoint("LEFT", tabPanel.textRows[rowIndex], "LEFT", generalInfoPanel:GetWidth(), 0)
					generalInfoPanel.rows[rowIndex] = textRowGeneralInfo

					if(rowIndex == 6) then
	
						local addRowMythicPlus = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, mythicPlusPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
						addRowMythicPlus.FontString:SetJustifyH("CENTER")
						addRowMythicPlus:SetPoint("LEFT", textRowGeneralInfo, "LEFT")
						mythicPlusPanel.rows[15] = addRowMythicPlus
		
						local addRowRaid = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
						addRowRaid.FontString:SetJustifyH("CENTER")
						addRowRaid:SetPoint("LEFT", textRowGeneralInfo, "LEFT")
						raidPanel.rows[15] = addRowRaid
					end
				else
					textRowFrame:SetParent(raidPanel)
				end
			end

			applicantMemberFrame:MarkDirty()
			applicantFrame:MarkDirty()

			generalInfoPanel.rows[1].FontString:SetJustifyV("TOP")
			generalInfoPanel.rows[1].FontString:SetPoint("TOPLEFT", generalInfoPanel.rows[1], "TOPLEFT", 0, -5)
			generalInfoPanel.rows[1].FontString:SetPoint("BOTTOMRIGHT", generalInfoPanel.rows[5], "BOTTOMRIGHT", 0, 0)
			generalInfoPanel.rows[1].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. applicantData.comment)
			generalInfoPanel.rows[1].FontString:SetWordWrap(true)
			generalInfoPanel.rows[1].FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)
			
			generalInfoPanel.rows[7].FontString:SetText(_G["LFG_TOOLTIP_ROLES"])

			if(tank == true) then
				generalInfoPanel.rows[7].FontString:SetText(generalInfoPanel.rows[7].FontString:GetText() .. miog.C.TANK_TEXTURE)
			end
			if(healer == true) then
				generalInfoPanel.rows[7].FontString:SetText(generalInfoPanel.rows[7].FontString:GetText() .. miog.C.HEALER_TEXTURE)
			end
			if(damager == true) then
				generalInfoPanel.rows[7].FontString:SetText(generalInfoPanel.rows[7].FontString:GetText() .. miog.C.DPS_TEXTURE)
			end

			if(profile) then --If Raider.IO is installed
				if(mythicKeystoneProfile) then
					for rowIndex = 1, #mythicKeystoneProfile.dungeons, 1 do
						local primaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeons[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeons[rowIndex] or 0
						local primaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeonUpgrades[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeonUpgrades[rowIndex] or 0
						local secondaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeons[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeons[rowIndex] or 0
						local secondaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeonUpgrades[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeonUpgrades[rowIndex] or 0

						if(dungeonProfile) then
							local textureString = miog.DUNGEON_ICONS[dungeonProfile[rowIndex].dungeon.instance_map_id]

							local dungeonIconFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2, "texture", textureString)
							dungeonIconFrame:SetPoint("LEFT", mythicPlusPanel.rows[rowIndex], "LEFT")
							dungeonIconFrame:SetMouseClickEnabled(true)
							dungeonIconFrame:SetFrameStrata("DIALOG")
							dungeonIconFrame:SetScript("OnMouseDown", function()
								local instanceID = C_EncounterJournal.GetInstanceForGameMap(dungeonProfile[rowIndex].dungeon.instance_map_id)

								--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
								EncounterJournal_OpenJournal(miog.F.CURRENT_DIFFICULTY, instanceID, nil, nil, nil, nil)
							end)

							local dungeonNameFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, mythicPlusPanel.rows[rowIndex]:GetWidth()*0.28, miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
							dungeonNameFrame.FontString:SetText(dungeonProfile[rowIndex].dungeon.shortName .. ":")
							dungeonNameFrame:SetPoint("LEFT", dungeonIconFrame, "RIGHT", 1, 0)

							local primaryAffixScoreFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, mythicPlusPanel.rows[rowIndex]:GetWidth()*0.30, miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
							local primaryText = WrapTextInColorCode(primaryDungeonLevel .. string.rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or primaryDungeonChests), primaryDungeonChests > 0 and miog.C.GREEN_COLOR or primaryDungeonChests == 0 and miog.C.RED_COLOR or "0")
							primaryAffixScoreFrame.FontString:SetText(primaryText)
							primaryAffixScoreFrame:SetPoint("LEFT", dungeonNameFrame, "RIGHT")

							local secondaryAffixScoreFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, mythicPlusPanel.rows[rowIndex]:GetWidth()*0.30, miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
							local secondaryText = WrapTextInColorCode(secondaryDungeonLevel .. string.rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or secondaryDungeonChests), secondaryDungeonChests > 0 and miog.C.GREEN_COLOR or secondaryDungeonChests == 0 and miog.C.RED_COLOR or "0")
							secondaryAffixScoreFrame.FontString:SetText(secondaryText)
							secondaryAffixScoreFrame:SetPoint("LEFT", primaryAffixScoreFrame, "RIGHT")
						end
					end

					if(mythicKeystoneProfile.mainCurrentScore) then
						if(mythicKeystoneProfile.mainCurrentScore > 0) then
							mythicPlusPanel.rows[15].FontString:SetText(WrapTextInColorCode("Main: " .. (mythicKeystoneProfile.mainCurrentScore), _G["ITEM_QUALITY_COLORS"][6].color:GenerateHexColor()))
						else
							mythicPlusPanel.rows[15].FontString:SetText(WrapTextInColorCode("Main Char", _G["ITEM_QUALITY_COLORS"][7].color:GenerateHexColor()))
						end
					else
						mythicPlusPanel.rows[15].FontString:SetText(WrapTextInColorCode("Main Score N/A", _G["ITEM_QUALITY_COLORS"][6].color:GenerateHexColor()))
					end

					generalInfoPanel.rows[8].FontString:SetText(
						WrapTextInColorCode(mythicKeystoneProfile.keystoneFivePlus or "0", _G["ITEM_QUALITY_COLORS"][2].color:GenerateHexColor()) .. " - " ..
						WrapTextInColorCode(mythicKeystoneProfile.keystoneTenPlus or "0", _G["ITEM_QUALITY_COLORS"][3].color:GenerateHexColor()) .. " - " ..
						WrapTextInColorCode(mythicKeystoneProfile.keystoneFifteenPlus or "0", _G["ITEM_QUALITY_COLORS"][4].color:GenerateHexColor()) .. " - " ..
						WrapTextInColorCode(mythicKeystoneProfile.keystoneTwentyPlus or "0", _G["ITEM_QUALITY_COLORS"][5].color:GenerateHexColor())
					)
				else
					mythicPlusPanel.rows[1].FontString:SetText(WrapTextInColorCode("NO M+ DATA", "FFFF0000"))
					mythicPlusPanel.rows[1].FontString:SetPoint("LEFT", mythicPlusPanel.rows[1], "LEFT", 2, 0)
				end

				if(raidProfile) then

					local ordinal = nil
					local lastColumn = nil

					raidPanel.textureRows = {}

					for raidIndex, raidProgressInfo in ipairs(raidProfile.progress) do
						
						local bossCount = raidProgressInfo.raid.bossCount
						local progressCount = raidProgressInfo.progressCount or 0
						local raidShortName = raidProgressInfo.raid.shortName

						local difficulty = miog.C.DIFFICULTY[raidProgressInfo.difficulty]
						local lowerDifficulty = raidProfile.progress[raidIndex+1] and miog.C.DIFFICULTY[raidProfile.progress[raidIndex+1].difficulty]
						local instanceID = C_EncounterJournal.GetInstanceForGameMap(raidProgressInfo.raid.mapId)

						if(raidProgressInfo.raid.ordinal ~= ordinal) then
							ordinal = raidProgressInfo.raid.ordinal
							raidPanel.textureRows[ordinal] = {}

							local textureString = miog.RAID_ICONS[raidProgressInfo.raid.mapId][bossCount + 1]
							local progressString =  WrapTextInColorCode(difficulty.singleChar .. ":" .. progressCount .. "/" .. bossCount, difficulty.color:GenerateHexColor())

							local raidColumn = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidPanel.rows[1]:GetWidth()*0.5, raidPanel:GetHeight())
							raidColumn:SetPoint("TOPLEFT", lastColumn or raidPanel, lastColumn and "TOPRIGHT" or "TOPLEFT")

							lastColumn = raidColumn

							local raidIconFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT, "texture", textureString)
							raidIconFrame:SetPoint("TOPLEFT", raidColumn, "TOPLEFT", 0, 0)
							raidIconFrame:SetMouseClickEnabled(true)
							raidIconFrame:SetFrameStrata("DIALOG")
							raidIconFrame:SetScript("OnMouseDown", function()
								--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
								EncounterJournal_OpenJournal(miog.F.CURRENT_DIFFICULTY, instanceID, nil, nil, nil, nil)

							end)

							local raidNameString = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE, raidIconFrame)
							raidNameString:SetPoint("LEFT", raidIconFrame, "RIGHT", 2, 0)
							raidNameString:SetText(raidShortName .. ":")

							local highestDifficultyFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidColumn:GetWidth()*0.48, miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
							highestDifficultyFrame.FontString:SetText(progressString)
							highestDifficultyFrame:SetPoint("TOPLEFT", raidIconFrame, "BOTTOMLEFT")

							if(lowerDifficulty) then
								local lowerDifficultyProgressString =  WrapTextInColorCode(lowerDifficulty.singleChar .. ":" .. raidProfile.progress[raidIndex+1].progressCount .. "/" .. bossCount, lowerDifficulty.color:GenerateHexColor())

								local lowerDifficultyFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidColumn:GetWidth()*0.48, miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
								lowerDifficultyFrame.FontString:SetText(lowerDifficultyProgressString)
								lowerDifficultyFrame:SetPoint("TOPLEFT", highestDifficultyFrame, "TOPRIGHT")

							else
								if(raidIndex == 3 and raidProfile.previousProgress[2]) then
									lowerDifficulty = miog.C.DIFFICULTY[raidProfile.previousProgress[2].difficulty]
		
									local lowerDifficultyProgressString =  WrapTextInColorCode(lowerDifficulty.singleChar .. ":" .. raidProfile.previousProgress[2].progressCount .. "/" .. bossCount, lowerDifficulty.color:GenerateHexColor())
									local lowerDifficultyFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidColumn:GetWidth()*0.5, miog.C.APPLICANT_MEMBER_HEIGHT, "fontstring", miog.C.TEXT_ROW_FONT_SIZE)
									lowerDifficultyFrame.FontString:SetText(lowerDifficultyProgressString)
									lowerDifficultyFrame:SetPoint("TOPLEFT", highestDifficultyFrame, "TOPRIGHT")
	
								end
							end

							for i = 1, ceil(bossCount/2), 1 do
								local currentBossRow = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidPanel.rows[i+1]:GetWidth()*0.5, raidPanel.rows[i+1]:GetHeight() * 1.4)
								currentBossRow:SetPoint("TOPLEFT", raidPanel.textureRows[ordinal-1] and raidPanel.textureRows[ordinal-1][i] or raidPanel.textureRows[ordinal][i-1] or raidPanel.rows[i+2], raidPanel.textureRows[ordinal-1] and "TOPRIGHT" or raidPanel.textureRows[ordinal][i-1] and "BOTTOMLEFT" or "TOPLEFT")
								raidPanel.textureRows[ordinal][i] = currentBossRow
								raidPanel.textureRows[ordinal][i].bossFrames = {}

							end

							for i = 1, bossCount, 1 do
								local remainder = math.fmod(i, 2)

								local nextRow = ceil(i/2)
								
								local bossFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidPanel.textureRows[ordinal][nextRow]:GetHeight() - 2, raidPanel.textureRows[ordinal][nextRow]:GetHeight() - 2)
								bossFrame:SetPoint("TOPLEFT", remainder == 0 and raidPanel.textureRows[ordinal][nextRow][i-1] or raidPanel.textureRows[ordinal][nextRow], remainder == 0 and "TOPRIGHT" or "TOPLEFT", remainder == 0 and 2 or 0, 0)
								bossFrame:SetMouseClickEnabled(true)
								bossFrame:SetFrameStrata("DIALOG")
								bossFrame:SetScript("OnMouseDown", function()
									local _, _, encounterID = EJ_GetEncounterInfoByIndex(i, instanceID)
									--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
									EncounterJournal_OpenJournal(miog.F.CURRENT_DIFFICULTY, instanceID, encounterID, nil, nil, nil)

								end)

								local kills = raidProgressInfo.killsPerBoss[i]

								local desaturated = true

								if(kills > 0) then
									desaturated = false
									miog.createFrameBorder(bossFrame, 1, difficulty.color:GetRGBA())

								elseif(kills == 0) then
									if(raidProfile.progress[raidIndex+1] or raidIndex == 3 and raidProfile.previousProgress[2] and raidProfile.previousProgress[2].progressCount == bossCount) then
										
										desaturated = false
										
										miog.createFrameBorder(bossFrame, 1, lowerDifficulty.color:GetRGBA())

									end
								end

								local bossFrameTexture = miog.createBasicTexture("fleeting", miog.RAID_ICONS[raidProgressInfo.raid.mapId][i], bossFrame, bossFrame:GetHeight() - 2, bossFrame:GetHeight() - 2)
								bossFrameTexture:SetPoint("TOPLEFT", bossFrame, "TOPLEFT", 1, -1)
								bossFrameTexture:SetDesaturated(desaturated)

								local bossNumber = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE, bossFrame)
								bossNumber:SetPoint("TOPLEFT", bossFrame, "TOPLEFT")
								bossNumber:SetText(i)

								raidPanel.textureRows[ordinal][nextRow][i] = bossFrame
							end
						end
					end

					if(raidProfile.mainProgress) then
						local mainProgressText = ""

						for _, raidProgressInfo in ipairs(raidProfile.mainProgress) do
							local difficulty = miog.C.DIFFICULTY[raidProgressInfo.difficulty]
							mainProgressText = mainProgressText .. WrapTextInColorCode(difficulty.singleChar .. ": " .. raidProgressInfo.progressCount .. "/" .. raidProgressInfo.raid.bossCount, difficulty.color:GenerateHexColor()) .. " "
						end
						
						raidPanel.rows[15].FontString:SetText(WrapTextInColorCode("Main: " .. mainProgressText, _G["ITEM_QUALITY_COLORS"][6].color:GenerateHexColor()))
					else
						raidPanel.rows[15].FontString:SetText(WrapTextInColorCode("Main Char", _G["ITEM_QUALITY_COLORS"][7].color:GenerateHexColor()))
					end

				else
					raidPanel.rows[1].FontString:SetText(WrapTextInColorCode("NO RAIDING DATA", "FFFF0000"))
					raidPanel.rows[1].FontString:SetPoint("LEFT", raidPanel.rows[1], "LEFT", 2, 0)
				end
				
			else -- If RaiderIO is not installed
				generalInfoPanel.rows[1].FontString:SetText(WrapTextInColorCode("NO RAIDER.IO DATA", "FFFF0000"))
				generalInfoPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)

				mythicPlusPanel.rows[1].FontString:SetText(WrapTextInColorCode("NO RAIDER.IO DATA", "FFFF0000"))
				mythicPlusPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)

				raidPanel.rows[1].FontString:SetText(WrapTextInColorCode("NO RAIDER.IO DATA", "FFFF0000"))
				raidPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)
			end

			basicInformationPanel:MarkDirty()

			applicantMemberFrame:MarkDirty()
			applicantFrame:MarkDirty()
		end

		applicantFrame:MarkDirty()
		lastApplicantFrame = applicantFrame
		addonApplicantList[applicantID]["frame"] = applicantFrame
		addonApplicantList[applicantID]["creationStatus"] = "added"
	end
end

local function sortApplicantList(applicant1, applicant2)

	for key, tableElement in pairs(miog.F.SORT_METHODS) do
		if(tableElement.currentLayer == 1) then
			local firstState = miog.sortByCategoryButtons[key]:GetActiveState()

			for innerKey, innerTableElement in pairs(miog.F.SORT_METHODS) do

				if(innerTableElement.currentLayer == 2) then
					local secondState = miog.sortByCategoryButtons[innerKey]:GetActiveState()

					if(applicant1[key] == applicant2[key]) then --IF ROLE EQUALS THEN CHECK FOR 
						return secondState == 1 and applicant1[innerKey] > applicant2[innerKey] or secondState == 2 and applicant1[innerKey] < applicant2[innerKey]

					elseif(applicant1[key] ~= applicant2[key]) then
						return firstState == 1 and applicant1[key] > applicant2[key] or firstState == 2 and applicant1[key] < applicant2[key]

					end
				end

			end
		
			if(applicant1[key] == applicant2[key]) then --IF ROLE EQUALS THEN CHECK FOR
				return firstState == 1 and applicant1["applicantID"] > applicant2["applicantID"] or firstState == 2 and applicant1["applicantID"] < applicant2["applicantID"]

			elseif(applicant1[key] ~= applicant2[key]) then
				return firstState == 1 and applicant1[key] > applicant2[key] or firstState == 2 and applicant1[key] < applicant2[key]
				
			end

		end

	end
	
	return applicant1["applicantID"] > applicant2["applicantID"]

end

local function iterateThroughList(list)
	table.sort(list, sortApplicantList)

	for _, listEntry in ipairs(list) do
		local applicantData = miog.F.IS_IN_DEBUG_MODE and debugLFGList[listEntry.applicantID] or C_LFGList.GetApplicantInfo(listEntry.applicantID)

		if(applicantData.applicationStatus == "applied" and addonApplicantList[listEntry.applicantID] == nil) then
			addonApplicantList[listEntry.applicantID] = {
				["creationStatus"] = "inProgress",
				["appStatus"] = applicantData.applicationStatus,
				["frame"] = nil,
			}

			addApplicantToPanel(listEntry.applicantID)

		elseif(applicantData.applicationStatus == "applied" and addonApplicantList[listEntry.applicantID] ~= nil ) then
			
		elseif(applicantData.applicationStatus ~= "applied") then
		end
	end
end

miog.checkApplicantList = function(needRefresh)
	local allApplicants = miog.F.IS_IN_DEBUG_MODE and debugApplicantIDList or C_LFGList:GetApplicants()

	if(needRefresh) then
		refreshFunction()
	end

	local fullList = {}

	for _, applicantID in ipairs(allApplicants) do

		local applicantData = C_LFGList.GetApplicantInfo(applicantID) or miog.F.IS_IN_DEBUG_MODE and debugLFGList[applicantID]

		if(applicantData) then
			local hasAllApplicantData = true

			if(not miog.F.IS_IN_DEBUG_MODE) then
				for i = 1, applicantData.numMembers, 1 do
					if(C_LFGList.GetApplicantMemberInfo(applicantID, i) == nil) then
						hasAllApplicantData = false
						break
					end
				end
			end

			local ilvl, assignedRole, dungeonScore, keyLevel
			local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityID or 0

			if(miog.F.IS_IN_DEBUG_MODE ==  false) then
				_, _, _, _, ilvl, _, _, _, _, assignedRole, _, dungeonScore = C_LFGList.GetApplicantMemberInfo(applicantID, 1)
				keyLevel = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activityID).bestRunLevel

			else
				ilvl = applicantData.applicantMemberList[1].ilvl
				assignedRole = applicantData.applicantMemberList[1].assignedRole
				dungeonScore = applicantData.applicantMemberList[1].dungeonScore
				keyLevel = applicantData.applicantMemberList[1].dataForDungeon.bestRunLevel
			end

			if(hasAllApplicantData) then
				if(assignedRole == "TANK") then
					miog.F.APPLIED_NUM_OF_TANKS = miog.F.APPLIED_NUM_OF_TANKS + 1
					miog.mainFrame.buttonPanel.RoleTextures[1].text:SetText(miog.F.APPLIED_NUM_OF_TANKS)

				elseif(assignedRole == "HEALER") then
					miog.F.APPLIED_NUM_OF_HEALERS = miog.F.APPLIED_NUM_OF_HEALERS + 1
					miog.mainFrame.buttonPanel.RoleTextures[2].text:SetText(miog.F.APPLIED_NUM_OF_HEALERS)

				elseif(assignedRole == "DAMAGER") then
					miog.F.APPLIED_NUM_OF_DPS = miog.F.APPLIED_NUM_OF_DPS + 1
					miog.mainFrame.buttonPanel.RoleTextures[3].text:SetText(miog.F.APPLIED_NUM_OF_DPS)
	
				end

				if(assignedRole == "TANK" and miog.F.SHOW_TANKS or assignedRole == "HEALER" and miog.F.SHOW_HEALERS or assignedRole == "DAMAGER" and miog.F.SHOW_DPS) then
					fullList[#fullList+1] = {["applicantID"] = applicantID, ["score"] = dungeonScore, ["ilvl"] = ilvl, ["keylevel"] = keyLevel, ["role"] = assignedRole}
				end
			end
		end
	end

	iterateThroughList(fullList)
end

local function createFullEntries(iterations)
	refreshFunction()

	for index = 1, iterations, 1 do
		local applicantID = random(1000, 9999)

		debugApplicantIDList[index] = applicantID

		debugLFGList[applicantID] = {
			applicantID = applicantID,
			applicationStatus = "applied",
			numMembers = random(1, 4),
			isNew = true,
			comment = "Heiho, heiho, wir sind vergnügt und froh. Johei, johei, die Arbeit ist vorbei.",
			displayOrderID = 1,
			applicantMemberList = {}
		}

		local name, realm = UnitFullName("player")

		local roleTable = {
			"TANK",
			"HEALER",
			"DAMAGER"
		}

		for memberIndex = 1, debugLFGList[applicantID].numMembers, 1 do
			debugLFGList[applicantID].applicantMemberList[memberIndex] = {
				name = name,
				realm = realm,
				fullName = name .. "-" .. realm,
				ilvl = random(400, 450) + 0.5,
				dungeonScore = random(1, 4000),
				englishClassName = UnitClassBase("player"),
				assignedRole = roleTable[random(#roleTable)],
				tank = false,
				healer = false,
				damager = true,
				friend = true,
				dataForDungeon = {finishedSuccess = true, bestRunLevel = random(20, 35), mapName = "Big Dick Land"},
			}
		end
	end

	miog.checkApplicantList(false)
end


local function setUpSettingString(activeEntryInfo, activityInfo)
	miog.mainFrame.titleBar.titleStringFrame.FontString:SetText(activeEntryInfo.name)
	miog.mainFrame.infoPanel.activityNameFrame:SetText(activityInfo.fullName)

	if(activeEntryInfo.privateGroup == true) then
		miog.mainFrame.listingSettingPanel.privateGroupFrame.active = true
		miog.mainFrame.listingSettingPanel.privateGroupFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/questionMark_Yellow.png")
	else
		miog.mainFrame.listingSettingPanel.privateGroupFrame.active = false
		miog.mainFrame.listingSettingPanel.privateGroupFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/questionMark_Grey.png")
	end


	if(activeEntryInfo.playstyle) then
		local playStyleString = (activityInfo.isMythicPlusActivity and miog.PLAYSTYLE_STRINGS["mPlus"..activeEntryInfo.playstyle]) or
		(activityInfo.isMythicActivity and miog.PLAYSTYLE_STRINGS["mZero"..activeEntryInfo.playstyle]) or
		(activityInfo.isCurrentRaidActivity and miog.PLAYSTYLE_STRINGS["raid"..activeEntryInfo.playstyle]) or
		((activityInfo.isRatedPvpActivity or activityInfo.isPvpActivity) and miog.PLAYSTYLE_STRINGS["pvp"..activeEntryInfo.playstyle])

		miog.mainFrame.listingSettingPanel.playstyleFrame.tooltipText = playStyleString

	else
		miog.mainFrame.listingSettingPanel.playstyleFrame.tooltipText = ""
	
	end

	if(activeEntryInfo.requiredDungeonScore or activeEntryInfo.requiredPvpRating) then
		miog.mainFrame.listingSettingPanel.ratingFrame.tooltipText = "Required rating: " .. activeEntryInfo.requiredDungeonScore or activeEntryInfo.requiredPvpRating
		miog.mainFrame.listingSettingPanel.ratingFrame.FontString:SetText(activeEntryInfo.requiredDungeonScore or activeEntryInfo.requiredPvpRating)

		if(activeEntryInfo.requiredDungeonScore) then
			miog.mainFrame.listingSettingPanel.ratingFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/skull.png")

		end

		if(activeEntryInfo.requiredPvpRating) then
			miog.mainFrame.listingSettingPanel.ratingFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/spear.png")
			
		end
	else
		miog.mainFrame.listingSettingPanel.ratingFrame.FontString:SetText("----")
		miog.mainFrame.listingSettingPanel.ratingFrame.tooltipText = ""
	
	end

	if(activeEntryInfo.requiredItemLevel > 0) then
		
		miog.mainFrame.listingSettingPanel.itemLevelFrame.FontString:SetText(activeEntryInfo.requiredItemLevel)
		miog.mainFrame.listingSettingPanel.itemLevelFrame.tooltipText = "Required itemlevel: " .. activeEntryInfo.requiredItemLevel

	else
	
		miog.mainFrame.listingSettingPanel.itemLevelFrame.FontString:SetText("---")
		miog.mainFrame.listingSettingPanel.itemLevelFrame.tooltipText = ""
	end

	if(activeEntryInfo.voiceChat ~= "") then
		LFGListFrame.EntryCreation.VoiceChat.CheckButton:SetChecked(true)

	end

	if(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked()) then

		miog.mainFrame.listingSettingPanel.voiceChatFrame.tooltipText = activeEntryInfo.voiceChat
		miog.mainFrame.listingSettingPanel.voiceChatFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOn.png")
	else
		
		miog.mainFrame.listingSettingPanel.voiceChatFrame.tooltipText = ""
		miog.mainFrame.listingSettingPanel.voiceChatFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOff.png")

	end
	
	if(activeEntryInfo.isCrossFactionListing == true) then
		miog.mainFrame.titleBar.factionFrame.Texture:SetTexture(2437241)

	else
		local playerFaction = UnitFactionGroup("player")

		if(playerFaction == "Alliance") then
			miog.mainFrame.titleBar.factionFrame.Texture:SetTexture(2173919)

		elseif(playerFaction == "Horde") then
			miog.mainFrame.titleBar.factionFrame.Texture:SetTexture(2173920)

		end
	end
	
	if(activeEntryInfo.comment ~= "") then

		miog.mainFrame.infoPanel.commentFrame.FontString:SetHeight(2500)
		miog.mainFrame.infoPanel.commentFrame.FontString:SetText("Description: " .. activeEntryInfo.comment)
		miog.mainFrame.infoPanel.commentFrame.FontString:SetHeight(miog.mainFrame.infoPanel.commentFrame.FontString:GetStringHeight())
		miog.mainFrame.infoPanel.commentFrame:SetHeight(miog.mainFrame.infoPanel.commentFrame.FontString:GetStringHeight())

	end
	
	miog.mainFrame.listingSettingPanel:MarkDirty()
end

--[[miog.refreshSpecIcons = function()
	if(MIOG_SavedSettings["showActualSpecIcons"].value == true) then
		for _, scrollTarget in LFGListFrame.SearchPanel.ScrollBox:EnumerateFrames() do

			local resultID = scrollTarget.resultID

			if(resultID) then
				local searchResultData = C_LFGList.GetSearchResultInfo(resultID)

				if(searchResultData) then
					local members = {}

					for i = 1, searchResultData.numMembers do
						local role, class, classLocalized, specLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i)

						local classColor = RAID_CLASS_COLORS[class]
						
						for specIndex = 1, GetNumSpecializationsForClassID(miog.CLASSES[class].index), 1 do
							local _, name, _, icon, _, _, _ = GetSpecializationInfoForClassID(miog.CLASSES[class].index, specIndex)

							if(name == specLocalized) then
								
								table.insert(members, {
									role = role,
									class = class,
									classLocalized = classLocalized,
									specLocalized = specLocalized,
									classColor = classColor,
									isLeader = i == 1,
									icon = icon,
								})
							end
						end
					end

					if(not MIOG_SavedSettings["showActualSpecIcons"].value) then
						miog.sortTableForRoleAndClass(members)
					end

					local emptyMembers = {}
					local memberCount = C_LFGList.GetSearchResultMemberCounts(resultID)

					if(memberCount) then
						for k,v in pairs(memberCount) do

							if(string.find(k, "REMAINING")) then
								if(v > 0) then
									if(string.find(k, "TANK")) then
										for index = 1, v, 1 do
											table.insert(emptyMembers, {
												role = "TANK",
												class = "21",
												icon = 5171843,
												iconCoords = miog.iconCoords.tankCoords,
											})
										end
									elseif(string.find(k, "HEALER")) then
										for index = 1, v, 1 do
											table.insert(emptyMembers, {
												role = "HEALER",
												class = "22",
												icon = 5171843,
												iconCoords = miog.iconCoords.healerCoords,
											})
										end
									elseif(string.find(k, "DAMAGER")) then
										for index = 1, v, 1 do
											table.insert(emptyMembers, {
												role = "DAMAGER",
												class = "23",
												icon = 5171843,
												iconCoords = miog.iconCoords.dpsCoords,
											})
										end
									end
								end
							end
						end
					end

					if(MIOG_SavedSettings["showActualSpecIcons"].value) then
						for _, v in ipairs(emptyMembers) do
							table.insert(members, v)
						end
						miog.sortTableForRoleAndClass(members)
					else
						miog.sortTableForRoleAndClass(emptyMembers)
						for _, v in ipairs(emptyMembers) do
							table.insert(members, v)
						end
					end

					for index = 1, 5, 1 do
						local iconIndex = 6-index

						if(index <= #members) then
							scrollTarget.DataDisplay.Enumerate.Icons[iconIndex]:SetTexCoord(0,1,0,1)
							scrollTarget.DataDisplay.Enumerate.Icons[iconIndex]:SetTexture(members[index].icon)

							if(members[index].iconCoords) then
								scrollTarget.DataDisplay.Enumerate.Icons[iconIndex]:SetTexCoord(unpack(members[index].iconCoords))
							end

							if(members[index].isLeader) then
								local children = {scrollTarget:GetChildren()}

								for _, child in pairs(children) do
									local leaderCrown = child.LeaderCrown

									if(leaderCrown) then

										leaderCrown:ClearAllPoints()
										leaderCrown:SetPoint("BOTTOM", scrollTarget.DataDisplay.Enumerate.Icons[iconIndex], "TOP", 0, 0)
										leaderCrown:Show()
									end
								end
							end
						end
					end
				end
			end
		end
	else
	end
end]]

local function updateRoster()
	miog.F.CURRENT_GROUP_INFO = {}

	local inPartyOrRaid = UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "player"

	local groupCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
		["NONE"] = 0
	}

	miog.releaseRaidRosterPool()

	if(miog.F.NUM_OF_GROUP_MEMBERS > 20) then

		for groupIndex = 1, miog.F.NUM_OF_GROUP_MEMBERS, 1 do
			local name, _, _, _, _, class, _, _, _, _, _, combatRole = GetRaidRosterInfo(groupIndex)

			if(name ~= nil) then
				groupCount[combatRole] = groupCount[combatRole] + 1
			end

			miog.F.CURRENT_GROUP_INFO[groupIndex] = {guid = UnitGUID("raid"..groupIndex), name = name, class = class, role = combatRole}
		end

		miog.mainFrame.titleBar.groupMemberListing.FontString:SetText(groupCount["TANK"] .. "/" .. groupCount["HEALER"] .. "/" .. groupCount["DAMAGER"])

	else
		miog.mainFrame.titleBar.groupMemberListing.FontString:SetText("")
		
		local index = 1

		for key, inspectQueueMember in pairs(miog.F.INSPECT_QUEUE) do
			local guid = key
			local class = inspectQueueMember[5] or UnitClassBase(inspectQueueMember[2])
			local name = inspectQueueMember[4]
			local specID = inspectQueueMember[3]
			local _, _, _, icon, backupRole = GetSpecializationInfoByID(specID)
			local role = inspectQueueMember[6] or backupRole or "NONE"

			local unitID = guid == UnitGUID("player") and "player" or inPartyOrRaid .. index

			local unitInPartyOrRaid = UnitInRaid(unitID) or UnitInParty(unitID) or guid == UnitGUID("player") or inPartyOrRaid == "player" and true or false

			if(unitInPartyOrRaid and inspectQueueMember[1] == true) then

				inspectQueueMember[1] = true
				groupCount[role] = groupCount[role] + 1

				miog.F.CURRENT_GROUP_INFO[#miog.F.CURRENT_GROUP_INFO+1] = {guid = guid, unitID = unitID, name = name, class = class, role = role, specIcon = icon or miog.CLASSES[class].icon}

				if(inPartyOrRaid == "raid" or inPartyOrRaid == "party" and guid ~= UnitGUID("player")) then
					index = index + 1

				end
			else
				inspectQueueMember = nil
			end
		end

		if(#miog.F.CURRENT_GROUP_INFO < 5) then
			if(groupCount["TANK"] < 1) then
				miog.F.CURRENT_GROUP_INFO[#miog.F.CURRENT_GROUP_INFO + 1] = {guid = "empty", unitID = "empty", name = "afk", class = "NONE", role = "TANK", specIcon = miog.C.STANDARD_FILE_PATH .. "/empty.png"}
			end

			if(groupCount["HEALER"] < 1 and #miog.F.CURRENT_GROUP_INFO < 5) then
				miog.F.CURRENT_GROUP_INFO[#miog.F.CURRENT_GROUP_INFO + 1] = {guid = "empty", unitID = "empty", name = "afk", class = "NONE", role = "HEALER", specIcon = miog.C.STANDARD_FILE_PATH .. "/empty.png"}
			end

			for i = 1, 3 - groupCount["DAMAGER"], 1 do
				if(groupCount["DAMAGER"] < 3 and #miog.F.CURRENT_GROUP_INFO < 5) then
					miog.F.CURRENT_GROUP_INFO[#miog.F.CURRENT_GROUP_INFO + 1] = {guid = "empty", unitID = "empty"..i, name = "afk", class = "NONE", role = "DAMAGER", specIcon = miog.C.STANDARD_FILE_PATH .. "/empty.png"}
				end
			end
		end

		miog.sortTableForRoleAndClass(miog.F.CURRENT_GROUP_INFO)

		local lastIcon = nil

		for _, groupMember in ipairs(miog.F.CURRENT_GROUP_INFO) do
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.titleBar.groupMemberListing, miog.mainFrame.titleBar.factionIconSize, miog.mainFrame.titleBar.factionIconSize, "texture", groupMember.specIcon)
			classIconFrame:SetPoint("LEFT", lastIcon or miog.mainFrame.titleBar.groupMemberListing, lastIcon and "RIGHT" or "LEFT")
			classIconFrame:SetFrameStrata("DIALOG")

			lastIcon = classIconFrame
		end

		lastIcon = nil
		
		if(miog.F.IS_IN_DEBUG_MODE) then
			for _, groupMember in ipairs(miog.F.CURRENT_GROUP_INFO) do
				local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", WorldFrame, miog.mainFrame.titleBar.factionIconSize, miog.mainFrame.titleBar.factionIconSize, "texture", groupMember.specIcon)
				classIconFrame:SetPoint("TOPLEFT", lastIcon or WorldFrame, lastIcon and "TOPRIGHT" or "TOPLEFT")
				classIconFrame:SetFrameStrata("DIALOG")
				miog.createFrameBorder(classIconFrame, 1)

				lastIcon = classIconFrame
			end
		end

		miog.mainFrame.titleBar.groupMemberListing:MarkDirty()
	end
end

local function getPlayerSpec()
	local specID = GetInspectSpecialization("player")
	local name, class, role = UnitName("player"), UnitClassBase("player"), GetSpecializationRoleByID(specID) or UnitGroupRolesAssigned("player")

	if(specID == 0 or specID == nil) then

		if(miog.F.INSPECT_QUEUE[UnitGUID("player")] == nil) then -- CHECK IF GUID ISNT IN ARRAY

			miog.F.INSPECT_QUEUE[UnitGUID("player")] = {[1] = false, [2] = "player", [3] = 0, [4] = name, [5] = class, [6] = role} -- SET GUID TO FALSE -> NO DATA AVAILABLE

			if(miog.F.CURRENTLY_INSPECTING == false) then

				miog.F.CURRENTLY_INSPECTING = true

				NotifyInspect("player")

			end

		end
	else
		miog.F.INSPECT_QUEUE[UnitGUID("player")] = {[1] = true, [2] = "player", [3] = specID, [4] = name, [5] = class, [6] = role} -- SET GUID TO FALSE -> NO DATA AVAILABLE

		updateRoster()
	end
end

local function requestInspectDataFromFullGroup()
	local inPartyOrRaid = UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "player"

	for groupIndex = 1, inPartyOrRaid == "party" and miog.F.NUM_OF_GROUP_MEMBERS-1 or miog.F.NUM_OF_GROUP_MEMBERS, 1 do

		local unitID = inPartyOrRaid..groupIndex

		local name, class, role = UnitName(unitID), UnitClassBase(unitID), UnitGroupRolesAssigned(unitID)

		local specID = GetInspectSpecialization(unitID)

		if(specID == 0 or specID == nil) then

			if(miog.F.INSPECT_QUEUE[UnitGUID(unitID)] == nil) then -- CHECK IF GUID ISNT IN ARRAY

				miog.F.INSPECT_QUEUE[UnitGUID(unitID)] = {[1] = false, [2] = unitID, [3] = 0, [4] = name, [5] = class, [6] = role} -- SET GUID TO FALSE -> NO DATA AVAILABLE

				if(miog.F.CURRENTLY_INSPECTING == false) then

					miog.F.CURRENTLY_INSPECTING = true


					NotifyInspect(unitID)

				end

			else
			end
		else
			miog.F.INSPECT_QUEUE[UnitGUID(unitID)] = {[1] = true, [2] = unitID, [3] = specID, [4] = name, [5] = class, [6] = role} -- SET GUID TO FALSE -> NO DATA AVAILABLE
			updateRoster()

		end
	end

	if(inPartyOrRaid == "party" or inPartyOrRaid == "player") then -- In a raid you are part of the raid roster, in a party you are NOT part of the party roster
		getPlayerSpec()

	end
end

miog.OnEvent = function(_, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		miog.releaseAllFleetingWidgets()
		miog.loadSettings()
		miog.F.NUM_OF_GROUP_MEMBERS = GetNumGroupMembers()
		

		miog.F.INSPECT_QUEUE = {}
		requestInspectDataFromFullGroup()
	elseif(event == "PLAYER_LOGIN") then
		miog.createMainFrame()

		C_MythicPlus.RequestCurrentAffixes()

		LFGListFrame.ApplicationViewer:HookScript("OnShow", function(self) self:Hide() miog.mainFrame:Show() end)

		hooksecurefunc("LFGListFrame_SetActivePanel", function(selfFrame, panel)
			if(panel == LFGListFrame.ApplicationViewer) then
				--LFGListFrame.ApplicationViewer:Hide()
				--miog.mainFrame:Show()
			else
				miog.mainFrame:Hide()
			end
		end)

		if(LFGListFrame.ApplicationViewer.Inset.Bg:GetTexture()) then
			--miog.mainFrame.infoPanel.Texture:Show()
		end

	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then --LISTING CHANGES

		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		local activityInfo

		if(C_LFGList.HasActiveEntryInfo() == true) then
			activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)

			miog.F.LISTED_CATEGORY_ID = activityInfo.categoryID

			if(activityInfo.categoryID == 2) then --Dungeons
				miog.mainFrame.infoPanel.affixFrame:Show()
				miog.mainFrame.infoPanel.backdropInfo.bgFile = miog.BACKGROUNDS[11]
					
				miog.F.CURRENT_DIFFICULTY = miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1]

			else
				if(activityInfo.categoryID == 1) then --Questing
					miog.mainFrame.infoPanel.backdropInfo.bgFile = miog.BACKGROUNDS[1]

				elseif(activityInfo.categoryID == 3) then --Raids
					miog.mainFrame.infoPanel.backdropInfo.bgFile = miog.BACKGROUNDS[2]
					
					miog.F.CURRENT_DIFFICULTY = miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DIFFICULTY

				elseif(activityInfo.categoryID == 4) then --Arenas
					miog.mainFrame.infoPanel.backdropInfo.bgFile = miog.BACKGROUNDS[4]

				elseif(activityInfo.categoryID == 6) then --Custom
					miog.mainFrame.infoPanel.backdropInfo.bgFile = miog.BACKGROUNDS[12]

				elseif(activityInfo.categoryID == 7) then --Skirmishes
					miog.mainFrame.infoPanel.backdropInfo.bgFile = miog.BACKGROUNDS[6]

				elseif(activityInfo.categoryID == 8) then --Battlegrounds
					miog.mainFrame.infoPanel.backdropInfo.bgFile = miog.BACKGROUNDS[5]

				elseif(activityInfo.categoryID == 9) then --Rated Battlegrounds
					miog.mainFrame.infoPanel.backdropInfo.bgFile = miog.BACKGROUNDS[14]
					
				end

				miog.mainFrame.infoPanel.affixFrame:Hide()
			end

			miog.mainFrame.infoPanel:ApplyBackdrop()
			setUpSettingString(activeEntryInfo, activityInfo)
		end

		if(... == nil) then
			if not(activeEntryInfo) then
				if(queueTimer) then
					queueTimer:Cancel()

				end

				miog.mainFrame.infoPanel.timerFrame.FontString:SetText("00:00:00")

				miog.mainFrame:Hide()

				if(miog.F.WEEKLY_AFFIX == nil) then
					miog.getAffixes()
				end
			end
		else
			refreshFunction()

			if(... == true) then --NEW LISTING
				MIOG_QueueUpTime = GetTimePreciseSec()
				expandedFrameList = {}
				miog.F.CURRENTLY_INSPECTING = false
				miog.F.CURRENT_GROUP_INFO = {}

			elseif(... == false) then --RELOAD OR SETTINGS EDIT
				MIOG_QueueUpTime = (MIOG_QueueUpTime and MIOG_QueueUpTime > 0) and MIOG_QueueUpTime or GetTimePreciseSec()
				miog.checkApplicantList(true)

			end

			queueTimer = C_Timer.NewTicker(1, timeInQueue)
			miog.mainFrame:Show()
		end

	elseif(event == "LFG_LIST_APPLICANT_UPDATED") then --ONE APPLICANT
		local applicantData = C_LFGList.GetApplicantInfo(...)

		if(applicantData) then
			if(applicantData.applicationStatus ~= "applied") then
				if(addonApplicantList[...]) then
					if(addonApplicantList[...]["frame"]) then
						local status = applicantData.applicationStatus
						local frame = addonApplicantList[...]["frame"]

						if(status == "invited") then
							changeApplicantStatus(..., frame, "INVITED", "FFFFFF00")
				
						elseif(status == "failed") then
							changeApplicantStatus(..., frame, "FAILED", "FFFF009D")
				
						elseif(status == "cancelled") then
							changeApplicantStatus(..., frame, "CANCELLED", "FFFFA600")
				
						elseif(status == "timedout") then
							changeApplicantStatus(..., frame, "TIMEOUT", "FF8400FF")
				
						elseif(status == "inviteaccepted") then
							changeApplicantStatus(..., frame, "INVITE ACCEPTED", "FF00FF00")
				
						elseif(status == "invitedeclined") then
							changeApplicantStatus(..., frame, "INVITE DECLINED", "FFFF0000")
				
						elseif(status == "declined") then
							changeApplicantStatus(..., frame, "DECLINED", "FFFF0000")

						elseif(status == "declined_full") then
							changeApplicantStatus(..., frame, "DECLINED", "FFFF0000")
				
						elseif(status == "declined_delisted") then
							changeApplicantStatus(..., frame, "DECLINED", "FFFF0000")
						
						end
					end
				end
			end
		else
			if(addonApplicantList[...]) then
				addonApplicantList[...]["appStatus"] = "canBeRemoved"
			end
		end
		
	elseif(event == "LFG_LIST_APPLICANT_LIST_UPDATED") then --ALL THE APPLICANTS

		local newEntry, withData = ...

		local allowedToInvite = C_PartyInfo.CanInvite()

		if(newEntry == true and withData == false) then --NEW APPLICANT WITHOUT DATA

		elseif(newEntry == true and withData == true) then --NEW APPLICANT WITH DATA
			miog.checkApplicantList(false)

		elseif(newEntry == false and withData == false) then --DECLINED APPLICANT
			miog.checkApplicantList(not allowedToInvite)

		elseif(not newEntry and not withData) then --REFRESH APP LIST
			miog.checkApplicantList(true)

		end

    elseif(event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
		if(not miog.F.WEEKLY_AFFIX) then
			C_MythicPlus.GetCurrentAffixes() -- Safety call, so Affixes are 100% available
			miog.setAffixes()
        end

	elseif(event == "ADDON_LOADED") then
		local addon = ...

		if(addon == "RaiderIO") then
			miog.F.IS_RAIDERIO_LOADED = true

			if(miog.mainFrame.raiderIOAddonIsLoadedFrame) then
				miog.mainFrame.raiderIOAddonIsLoadedFrame:Hide()
			end
		end

	elseif(event == "GROUP_JOINED") then
		miog.F.INSPECT_QUEUE = {}

		if(UnitIsGroupLeader("player")) then
			miog.footerBar:Show()
			miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.footerBar, "TOPRIGHT", 0, 0)

		else
			miog.footerBar:Hide()
			miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)

		end

	elseif(event == "GROUP_LEFT") then
		miog.F.INSPECT_QUEUE = {}
		
		miog.F.NUM_OF_GROUP_MEMBERS = GetNumGroupMembers()

		requestInspectDataFromFullGroup()
		updateRoster()

	elseif(event == "PARTY_LEADER_CHANGED") then
		if(UnitIsGroupLeader("player")) then
			miog.footerBar:Show()
			miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.footerBar, "TOPRIGHT", 0, 0)

		else
			miog.footerBar:Hide()
			miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)

		end

	elseif(event == "GROUP_ROSTER_UPDATE") then
		miog.F.NUM_OF_GROUP_MEMBERS = GetNumGroupMembers()

		requestInspectDataFromFullGroup()
		--updateRoster()

		if(UnitIsGroupLeader("player")) then
			miog.footerBar:Show()
			miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.footerBar, "TOPRIGHT", 0, 0)

		else
			miog.footerBar:Hide()
			miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)

		end

	elseif(event == "INSPECT_READY") then

		miog.F.INSPECT_QUEUE[...][1] = true

		local specID = GetInspectSpecialization(miog.F.INSPECT_QUEUE[...][2])

		if(specID == 0 or specID == nil) then
		else
			miog.F.INSPECT_QUEUE[...][3] = specID
		end

		ClearInspectPlayer()
		
		local inspectingFinished = true

		for _, queueMember in pairs(miog.F.INSPECT_QUEUE) do
			if(queueMember[1] == false) then
				if(CanInspect(queueMember[2]) and UnitIsConnected(queueMember[2])) then

					inspectingFinished = false

					NotifyInspect(queueMember[2])

					break
				else
					-- CAN'T INSPECT, EITHER DISTANCE, WEIRD HORDE/ALLIANCE STUFF OR OFFLINE
				end
			end
		end

		if(inspectingFinished == true) then
			miog.F.CURRENTLY_INSPECTING = false
			
		end

		updateRoster()
	end
end

SLASH_MIOG1 = '/miog'
local function handler(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if(command == "") then
		
	elseif(command == "debug") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")
		if(IsInGroup()) then
			PVEFrame:Show()
			LFGListFrame:Show()
			LFGListPVEStub:Show()
			LFGListFrame.ApplicationViewer:Show()
			createFullEntries(3)
			miog.mainFrame:Show()
		else
			createFullEntries(3)
		end
	elseif(command == "debugoff") then
		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false
		refreshFunction()
	else
		miog.mainFrame:Show()
	end
end
SlashCmdList["MIOG"] = handler