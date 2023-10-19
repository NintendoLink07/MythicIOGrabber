local addonName, miog = ...

local addonApplicantList = {}
local expandedFrameList = {}

local lastApplicantFrame
local applicantFramePadding = 6

local debugLFGList = {}
local debugApplicantIDList = {}
local currentAverageExecuteTime = {}
local debugTimer = nil

local getRioProfile
local fmod = math.fmod
local rep = string.rep
local wticc = WrapTextInColorCode
local tostring = tostring

local queueTimer

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

end

local function updateApplicantStatus(applicantID, applicantStatus)
	local currentApplicant = addonApplicantList[applicantID]
	if(currentApplicant.frame) then
		if(currentApplicant.frame.inviteButton) then
			currentApplicant.frame.inviteButton:Disable()
		end

		for _, memberFrame in pairs(currentApplicant.frame.memberFrames) do
			memberFrame.statusFrame:Show()
			memberFrame.statusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[applicantStatus].statusString, miog.APPLICANT_STATUS_INFO[applicantStatus].color))

		end

		currentApplicant.creationStatus = applicantStatus == "invited" and "invited" or "canBeRemoved"
	end
end

local function sortApplicantList(applicant1, applicant2)

	for key, tableElement in pairs(miog.F.SORT_METHODS) do
		if(tableElement.currentLayer == 1) then
			local firstState = miog.mainFrame.buttonPanel.sortByCategoryButtons[key]:GetActiveState()

			for innerKey, innerTableElement in pairs(miog.F.SORT_METHODS) do

				if(innerTableElement.currentLayer == 2) then
					local secondState = miog.mainFrame.buttonPanel.sortByCategoryButtons[innerKey]:GetActiveState()
			
					if(applicant1[key] == applicant2[key]) then
						return secondState == 1 and applicant1[innerKey] > applicant2[innerKey] or secondState == 2 and applicant1[innerKey] < applicant2[innerKey]

					elseif(applicant1[key] ~= applicant2[key]) then
						return firstState == 1 and applicant1[key] > applicant2[key] or firstState == 2 and applicant1[key] < applicant2[key]
							
					end
				end

			end
		
			if(applicant1[key] == applicant2[key]) then
				return firstState == 1 and applicant1.index > applicant2.index or firstState == 2 and applicant1.index < applicant2.index

			elseif(applicant1[key] ~= applicant2[key]) then
				return firstState == 1 and applicant1[key] > applicant2[key] or firstState == 2 and applicant1[key] < applicant2[key]
				
			end

		end

	end
	
	return applicant1.index < applicant2.index

end

local function addApplicantToPanel(applicantID)

	local applicantData = debugLFGList[applicantID] or C_LFGList.GetApplicantInfo(applicantID)

	if(applicantData) then
		local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityID or 0

		expandedFrameList[applicantID] = expandedFrameList[applicantID] or {}

		local applicantMemberPadding = 2
		local applicantFrame = miog.createBasicFrame("fleeting", "ResizeLayoutFrame, BackdropTemplate", miog.mainFrame.applicantPanel.container)
		applicantFrame.fixedWidth = miog.mainFrame.applicantPanel:GetWidth() - 2
		applicantFrame.minimumHeight = applicantData.numMembers * miog.C.APPLICANT_MEMBER_HEIGHT + applicantMemberPadding * (applicantData.numMembers-1) + 2
		applicantFrame.heightPadding = 1
		applicantFrame.memberFrames = {}
		applicantFrame:SetPoint("TOP", lastApplicantFrame or miog.mainFrame.applicantPanel.container, lastApplicantFrame and "BOTTOM" or "TOP", 0, lastApplicantFrame and -applicantFramePadding or 0)

		miog.mainFrame.applicantPanel.container.lastApplicantFrame = applicantFrame

		miog.createFrameBorder(applicantFrame, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

		for applicantIndex = 1, applicantData.numMembers, 1 do
			
			-- fullName, englishClassName, localizedClassName, level, ilvl, honorLevel, tank, healer, damager, assignedRole, friend, dungeonScore, pvpIlvl
			local fullName, englishClassName, _, _, ilvl, _, tank, healer, damager, assignedRole, friend, dungeonScore, _
			local dungeonData, pvpData, rioProfile
			
			if(miog.F.IS_IN_DEBUG_MODE) then
				fullName, englishClassName, _, _, ilvl, _, tank, healer, damager, assignedRole, friend, dungeonScore, _, dungeonData, _, pvpData, rioProfile = unpack(debugLFGList[applicantID].applicantMemberList[applicantIndex])

			else
				fullName, englishClassName, _, _, ilvl, _, tank, healer, damager, assignedRole, friend, dungeonScore, _ = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)
				dungeonData = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, applicantIndex, activityID)
				pvpData = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, applicantIndex, activityID)

			end

			local nameTable = miog.simpleSplit(fullName, "-")
			
			local profile, mythicKeystoneProfile, dungeonProfile, raidProfile

			if(miog.F.IS_RAIDERIO_LOADED) then
				if(not miog.F.IS_IN_DEBUG_MODE) then
					profile = getRioProfile(nameTable[1], nameTable[2], miog.C.CURRENT_REGION)

				else
					profile = getRioProfile(unpack(rioProfile))

				end
				
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
			applicantMemberFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
			applicantMemberFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
			applicantMemberFrame:SetBackdropBorderColor(0, 0, 0, 0)
			applicantFrame.memberFrames[applicantIndex] = applicantMemberFrame
			
			local applicantMemberStatusFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", applicantFrame, nil, nil, "FontString")
			applicantMemberStatusFrame:Hide()
			applicantMemberStatusFrame:SetPoint("TOPLEFT", applicantMemberFrame, "TOPLEFT", 0, 0)
			applicantMemberStatusFrame:SetPoint("BOTTOMRIGHT", applicantMemberFrame, "BOTTOMRIGHT", 0, 0)
			applicantMemberStatusFrame:SetFrameStrata("FULLSCREEN")
			applicantMemberStatusFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
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

			end

			expandFrameButton:RegisterForClicks("LeftButtonDown")
			expandFrameButton:SetScript("OnClick", function()
				if(applicantMemberFrame.detailedInformationPanel) then
					expandFrameButton:AdvanceState()
					expandedFrameList[applicantID][applicantIndex] = not applicantMemberFrame.detailedInformationPanel:IsVisible()

					applicantMemberFrame.detailedInformationPanel:SetShown(not applicantMemberFrame.detailedInformationPanel:IsVisible())

					applicantFrame:MarkDirty()
				end

			end)
			basicInformationPanel.expandButton = expandFrameButton

			local shortName = strsub(nameTable[1], 0, 20)
			local coloredSubName = fullName == "Rhany-Ravencrest" and wticc(shortName, miog.ITEM_QUALITY_COLORS[6].pureHex) or wticc(shortName, select(4, GetClassColor(englishClassName)))

			local nameFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.fixedWidth * 0.27, basicInformationPanel.maximumHeight, "FontString", miog.C.APPLICANT_MEMBER_FONT_SIZE)
			nameFrame:SetPoint("LEFT", expandFrameButton, "RIGHT", 3, 0)
			nameFrame:SetFrameStrata("DIALOG")
			nameFrame.FontString:SetText(coloredSubName)
			nameFrame:SetScript("OnMouseDown", function(_, button)
				if(button == "RightButton") then
					local link = "https://raider.io/characters/" .. miog.F.CURRENT_REGION .. "/" .. miog.REALM_LOCAL_NAMES[nameTable[2]] .. "/" .. nameTable[1]

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

				elseif(fullName == "Rhany-Ravencrest") then
					GameTooltip:SetOwner(nameFrame, "ANCHOR_CURSOR")
					GameTooltip:AddLine("You've found the creator of this addon.\nHow lucky!")
					GameTooltip:Show()

				end

			end)
			nameFrame:SetScript("OnLeave", function()
				GameTooltip:Hide()

			end)

			--nameFrame.linkBox = miog.createBasicFrame("fleeting", "InputBoxTemplate", WorldFrame, 250, miog.C.APPLICANT_MEMBER_HEIGHT)
			nameFrame.linkBox = miog.createBasicFrame("fleeting", "InputBoxTemplate", applicantMemberFrame, nil, miog.C.APPLICANT_MEMBER_HEIGHT)
			nameFrame.linkBox:SetFont(miog.FONTS["libMono"], miog.C.APPLICANT_MEMBER_FONT_SIZE, "OUTLINE")
			nameFrame.linkBox:SetFrameStrata("FULLSCREEN")
			nameFrame.linkBox:SetPoint("TOPLEFT", applicantMemberStatusFrame, "TOPLEFT", 5, 0)
			nameFrame.linkBox:SetPoint("TOPRIGHT", applicantMemberStatusFrame, "TOPRIGHT", -1, 0)
			nameFrame.linkBox:SetAutoFocus(true)
			nameFrame.linkBox:SetScript("OnKeyDown", function(_, key)
				if(key == "ESCAPE") then
					nameFrame.linkBox:Hide()
					nameFrame.linkBox:ClearFocus()

				end
			end)
			nameFrame.linkBox:Hide()

			local commentFrame = miog.createBasicTexture("fleeting", 136459, basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight)
			commentFrame:SetPoint("LEFT", nameFrame, "RIGHT", 0, 0)
			
			if(applicantData.comment == "") then
				commentFrame:Hide()
			end
	
			local roleFrame = miog.createBasicTexture("fleeting", 136459, basicInformationPanel, basicInformationPanel.maximumHeight - 1, basicInformationPanel.maximumHeight - 1)
			roleFrame:SetPoint("LEFT", commentFrame, "RIGHT", 1, 0)
			roleFrame:SetTexture(miog.C.STANDARD_FILE_PATH ..
			((assignedRole == "TANK" and "/infoIcons/tankSuperSmallIcon.png") or
			(assignedRole == "HEALER" and "/infoIcons/healerSuperSmallIcon.png") or
			(assignedRole == "DAMAGER" and "/infoIcons/dpsSuperSmallIcon.png")))

			local primaryIndicator = miog.createBasicFontString("fleeting", miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.11, basicInformationPanel.maximumHeight)
			primaryIndicator:SetPoint("LEFT", roleFrame, "RIGHT", 5, 0)
			primaryIndicator:SetJustifyH("CENTER")

			local secondaryIndicator = miog.createBasicFontString("fleeting", miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.1, basicInformationPanel.maximumHeight)
			secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 1, 0)
			secondaryIndicator:SetJustifyH("CENTER")

			local itemLevelFrame = miog.createBasicFontString("fleeting", miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.13, basicInformationPanel.maximumHeight)
			itemLevelFrame:SetPoint("LEFT", secondaryIndicator, "RIGHT", 1, 0)
			itemLevelFrame:SetJustifyH("CENTER")

			local reqIlvl = C_LFGList:HasActiveEntryInfo() and C_LFGList:GetActiveEntryInfo().requiredItemLevel or 0

			if(reqIlvl > ilvl) then
				itemLevelFrame:SetText(wticc(miog.round(ilvl, 1), miog.CLRSCC["red"]))

			else
				itemLevelFrame:SetText(miog.round(ilvl, 1))

			end

			local friendFrame = miog.createBasicTexture("fleeting", miog.C.STANDARD_FILE_PATH .. "/infoIcons/friend.png", basicInformationPanel, basicInformationPanel.maximumHeight - 3, basicInformationPanel.maximumHeight - 3)
			friendFrame:SetPoint("LEFT", itemLevelFrame, "RIGHT", 3, 0)
			friendFrame:SetDrawLayer("OVERLAY")
			friendFrame:SetShown(friend or false)
			friendFrame:SetMouseMotionEnabled(true)
			friendFrame:SetScript("OnEnter", function()
				GameTooltip:SetOwner(friendFrame, "ANCHOR_CURSOR")
				GameTooltip:SetText("On your friendlist")
				GameTooltip:Show()

			end)
			friendFrame:SetScript("OnLeave", function()
				GameTooltip:Hide()

			end)

			if(applicantIndex > 1) then
				local groupFrame = miog.createBasicTexture("fleeting", miog.C.STANDARD_FILE_PATH .. "/infoIcons/link.png", basicInformationPanel, basicInformationPanel.maximumHeight - 3, basicInformationPanel.maximumHeight - 3)
				groupFrame:ClearAllPoints()
				groupFrame:SetDrawLayer("OVERLAY")
				groupFrame:SetPoint("TOPRIGHT", basicInformationPanel, "TOPRIGHT", -1, -1)
			end

			local allowedToInvite = C_PartyInfo.CanInvite()

			if(applicantIndex == 1 and allowedToInvite or applicantIndex == 1 and miog.F.IS_IN_DEBUG_MODE) then
				local declineButton = miog.createBasicFrame("fleeting", "IconButtonTemplate", basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight)
				declineButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
				declineButton.iconSize = basicInformationPanel.maximumHeight - 4
				declineButton:OnLoad()
				declineButton:SetPoint("RIGHT", basicInformationPanel, "RIGHT", 0, 0)
				declineButton:SetFrameStrata("DIALOG")
				declineButton:RegisterForClicks("LeftButtonDown")
				declineButton:SetScript("OnClick", function()
					if(addonApplicantList[applicantID].creationStatus == "added") then
						addonApplicantList[applicantID].creationStatus = "canBeRemoved"
						C_LFGList.DeclineApplicant(applicantID)

					elseif(addonApplicantList[applicantID].creationStatus == "canBeRemoved") then
						miog.checkApplicantList(true)

					end

					--miog.mainFrame.applicantPanel.container:MarkDirty()
				end)
				applicantMemberFrame.basicInformationPanel.declineButton = declineButton

				local inviteButton = miog.createBasicFrame("fleeting", "IconButtonTemplate", basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight)
				inviteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png"
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
			detailedInformationPanel:SetShown(expandFrameButton:GetActiveState() > 0 and true or false)
			local detailedInformationPanelWidth = detailedInformationPanel:GetWidth() * 0.5

			applicantMemberFrame.detailedInformationPanel = detailedInformationPanel

			local tabPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel)
			tabPanel:SetPoint("TOPLEFT", detailedInformationPanel, "TOPLEFT")
			tabPanel:SetPoint("TOPRIGHT", detailedInformationPanel, "TOPRIGHT")
			tabPanel:SetHeight(miog.C.APPLICANT_MEMBER_HEIGHT)
			tabPanel.textRows = {}

			detailedInformationPanel.tabPanel = tabPanel

			local mythicPlusTabButton = miog.createBasicFrame("fleeting", "UIPanelButtonTemplate", tabPanel)
			mythicPlusTabButton:SetSize(detailedInformationPanelWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
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
			raidTabButton:SetSize(detailedInformationPanelWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
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

			local raidPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, detailedInformationPanelWidth, (miog.F.MOST_BOSSES) * 20)
			raidPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
			tabPanel.raidPanel = raidPanel
			raidPanel:SetShown(miog.F.LISTED_CATEGORY_ID == 3 and true)
			raidPanel.rows = {}

			local mythicPlusPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, detailedInformationPanelWidth, 8 * 20)
			mythicPlusPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
			tabPanel.mythicPlusPanel = mythicPlusPanel
			mythicPlusPanel:SetShown(miog.F.LISTED_CATEGORY_ID ~= 3 and true)
			mythicPlusPanel.rows = {true, true, true, true, true, true, true, true}

			local generalInfoPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, detailedInformationPanelWidth, 8 * 20)
			generalInfoPanel:SetPoint("TOPRIGHT", tabPanel, "BOTTOMRIGHT")
			tabPanel.generalInfoPanel = generalInfoPanel
			generalInfoPanel.rows = {}

			local mPlusWidth = mythicPlusPanel:GetWidth()
			local raidPanelWidth = raidPanel:GetWidth()
			local generalWidth = generalInfoPanel:GetWidth()

			for rowIndex = 1, miog.F.MOST_BOSSES, 1 do
				local remainder = fmod(rowIndex, 2)

				local textRowFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel)
				textRowFrame:SetSize(detailedInformationPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT)
				textRowFrame:SetPoint("TOPLEFT", tabPanel.textRows[rowIndex-1] or mythicPlusTabButton, "BOTTOMLEFT")

				if(remainder == 1) then
					textRowFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
					textRowFrame:SetBackdropColor(CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())
				else
					textRowFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
					textRowFrame:SetBackdropColor(CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA())
				end

				local divider = miog.createBasicTexture("fleeting", nil, textRowFrame, textRowFrame:GetWidth(), 2, "BORDER")
				divider:SetAtlas("UI-LFG-DividerLine")
				divider:SetPoint("BOTTOM", textRowFrame, "BOTTOM", 0, -1)

				tabPanel.textRows[rowIndex] = textRowFrame

				local textRowRaid = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidPanelWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", miog.C.TEXT_ROW_FONT_SIZE)
				textRowRaid:SetPoint("LEFT", tabPanel.textRows[rowIndex], "LEFT")
				raidPanel.rows[rowIndex] = textRowRaid

				if(rowIndex < 9) then

					local textRowMythicPlus = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, mPlusWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", miog.C.TEXT_ROW_FONT_SIZE)
					textRowMythicPlus:SetPoint("LEFT", tabPanel.textRows[rowIndex], "LEFT")
					mythicPlusPanel.rows[rowIndex] = textRowMythicPlus

					local textRowGeneralInfo = miog.createBasicFrame("fleeting", "BackdropTemplate", generalInfoPanel, generalWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", miog.C.TEXT_ROW_FONT_SIZE)
					textRowGeneralInfo.FontString:SetJustifyH("CENTER")
					textRowGeneralInfo:SetPoint("LEFT", tabPanel.textRows[rowIndex], "LEFT", generalWidth, 0)
					generalInfoPanel.rows[rowIndex] = textRowGeneralInfo

					if(rowIndex == 6) then
	
						local addRowMythicPlus = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, mPlusWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", miog.C.TEXT_ROW_FONT_SIZE)
						addRowMythicPlus.FontString:SetJustifyH("CENTER")
						addRowMythicPlus:SetPoint("LEFT", textRowGeneralInfo, "LEFT")
						mythicPlusPanel.rows[15] = addRowMythicPlus
		
						local addRowRaid = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, raidPanelWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", miog.C.TEXT_ROW_FONT_SIZE)
						addRowRaid.FontString:SetJustifyH("CENTER")
						addRowRaid:SetPoint("LEFT", textRowGeneralInfo, "LEFT")
						raidPanel.rows[15] = addRowRaid
					end
				else
					textRowFrame:SetParent(raidPanel)
				end
			end

			generalInfoPanel.rows[1].FontString:SetJustifyV("TOP")
			generalInfoPanel.rows[1].FontString:SetPoint("TOPLEFT", generalInfoPanel.rows[1], "TOPLEFT", 0, -5)
			generalInfoPanel.rows[1].FontString:SetPoint("BOTTOMRIGHT", generalInfoPanel.rows[5], "BOTTOMRIGHT", 0, 0)
			generalInfoPanel.rows[1].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. applicantData.comment)
			generalInfoPanel.rows[1].FontString:SetWordWrap(true)
			generalInfoPanel.rows[1].FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)
			
			generalInfoPanel.rows[7].FontString:SetText(_G["LFG_TOOLTIP_ROLES"] .. ((tank == true and miog.C.TANK_TEXTURE) or (healer == true and miog.C.HEALER_TEXTURE) or (damager == true and miog.C.DPS_TEXTURE)))

			--applicantMemberFrame:MarkDirty()
			--applicantFrame:MarkDirty()

			if(miog.F.LISTED_CATEGORY_ID == 2) then
				if(dungeonScore > 0) then
					local reqScore = C_LFGList:HasActiveEntryInfo() and C_LFGList:GetActiveEntryInfo().requiredDungeonScore or 0
					local highestKeyForDungeon

					if(reqScore > dungeonScore) then
						primaryIndicator:SetText(wticc(dungeonScore, miog.CLRSCC["red"]))

					else
						primaryIndicator:SetText(wticc(tostring(dungeonScore), C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore):GenerateHexColor()))

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
					local difficulty = miog.C.DIFFICULTY[-1] -- NO DATA
					primaryIndicator:SetText(wticc("0", difficulty.color))
					secondaryIndicator:SetText(wticc("0", difficulty.color))

				end

			elseif(miog.F.LISTED_CATEGORY_ID == (4 or 7 or 8 or 9)) then
				primaryIndicator:SetText(wticc(tostring(pvpData.rating), C_ChallengeMode.GetDungeonScoreRarityColor(pvpData.rating):GenerateHexColor()))

				local tierResult = miog.simpleSplit(pvpData.tier, " ")
				secondaryIndicator:SetText(strsub(tierResult[1], 0, 2) .. ((tierResult[2] and "" .. tierResult[2]) or ""))

			end

			if(profile) then
				if(mythicKeystoneProfile and mythicKeystoneProfile.currentScore > 0) then

					local rowWidth = mythicPlusPanel.rows[1]:GetWidth()
				
					for rowIndex = 1, #mythicKeystoneProfile.dungeons, 1 do
						if(dungeonProfile) then
							local primaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeons[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeons[rowIndex] or 0
							local primaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeonUpgrades[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeonUpgrades[rowIndex] or 0
							local secondaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeons[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeons[rowIndex] or 0
							local secondaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeonUpgrades[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeonUpgrades[rowIndex] or 0

							local textureString = miog.DUNGEON_ICONS[dungeonProfile[rowIndex].dungeon.instance_map_id]

							local dungeonIconFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2, "Texture", textureString)
							dungeonIconFrame:SetPoint("LEFT", mythicPlusPanel.rows[rowIndex], "LEFT")
							dungeonIconFrame:SetMouseClickEnabled(true)
							dungeonIconFrame:SetFrameStrata("FULLSCREEN")
							dungeonIconFrame:SetScript("OnMouseDown", function()
								local instanceID = C_EncounterJournal.GetInstanceForGameMap(dungeonProfile[rowIndex].dungeon.instance_map_id)

								--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
								EncounterJournal_OpenJournal(miog.F.CURRENT_DIFFICULTY, instanceID, nil, nil, nil, nil)
							end)

							local dungeonNameFrame = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidth*0.28, miog.C.APPLICANT_MEMBER_HEIGHT)
							dungeonNameFrame:SetText(dungeonProfile[rowIndex].dungeon.shortName .. ":")
							dungeonNameFrame:SetPoint("LEFT", dungeonIconFrame, "RIGHT", 1, 0)

							local primaryAffixScoreFrame = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidth*0.30, miog.C.APPLICANT_MEMBER_HEIGHT)
							local primaryText = wticc(primaryDungeonLevel .. rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or primaryDungeonChests), primaryDungeonChests > 0 and miog.C.GREEN_COLOR or primaryDungeonChests == 0 and miog.CLRSCC["red"] or "0")
							primaryAffixScoreFrame:SetText(primaryText)
							primaryAffixScoreFrame:SetPoint("LEFT", dungeonNameFrame, "RIGHT")

							local secondaryAffixScoreFrame = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidth*0.30, miog.C.APPLICANT_MEMBER_HEIGHT)
							local secondaryText = wticc(secondaryDungeonLevel .. rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or secondaryDungeonChests), secondaryDungeonChests > 0 and miog.C.GREEN_COLOR or secondaryDungeonChests == 0 and miog.CLRSCC["red"] or "0")
							secondaryAffixScoreFrame:SetText(secondaryText)
							secondaryAffixScoreFrame:SetPoint("LEFT", primaryAffixScoreFrame, "RIGHT")
						end
					end

					if(mythicKeystoneProfile.mainCurrentScore) then
						if(mythicKeystoneProfile.mainCurrentScore > 0) then
							mythicPlusPanel.rows[15].FontString:SetText(wticc("Main: " .. (mythicKeystoneProfile.mainCurrentScore), miog.ITEM_QUALITY_COLORS[6].pureHex))
						else
							mythicPlusPanel.rows[15].FontString:SetText(wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex))
						end
					else
						mythicPlusPanel.rows[15].FontString:SetText(wticc("Main Score N/A", miog.ITEM_QUALITY_COLORS[6].pureHex))
					end

					generalInfoPanel.rows[8].FontString:SetText(
						wticc(mythicKeystoneProfile.keystoneFivePlus or "0", miog.ITEM_QUALITY_COLORS[2].pureHex) .. " - " ..
						wticc(mythicKeystoneProfile.keystoneTenPlus or "0", miog.ITEM_QUALITY_COLORS[3].pureHex) .. " - " ..
						wticc(mythicKeystoneProfile.keystoneFifteenPlus or "0", miog.ITEM_QUALITY_COLORS[4].pureHex) .. " - " ..
						wticc(mythicKeystoneProfile.keystoneTwentyPlus or "0", miog.ITEM_QUALITY_COLORS[5].pureHex)
					)
				else
					mythicPlusPanel.rows[1].FontString:SetText(wticc("NO M+ DATA", miog.CLRSCC["red"]))
					mythicPlusPanel.rows[1].FontString:SetPoint("LEFT", mythicPlusPanel.rows[1], "LEFT", 2, 0)
				end

				if(raidProfile) then


					local lastOrdinal = nil
					local lastColumn = nil

					local higherDifficultyNumber = nil
					local lowerDifficultyNumber = nil

					local currentHigherDifficultyFrame = nil
					local currentLowerDifficultyFrame = nil
					local mainProgressText = ""
					local halfRowWidth = raidPanel.rows[1]:GetWidth() * 0.5

					local raidIndex = 0

					raidPanel.textureRows = {}

					for _, sortedProgress in ipairs(raidProfile.sortedProgress) do
						
						local currentOrdinal = sortedProgress.progress.raid.ordinal
						local progressCount = sortedProgress.progress.progressCount
						local difficultyData = miog.C.DIFFICULTY[sortedProgress.progress.difficulty]
						local bossCount = sortedProgress.progress.raid.bossCount
						local panelProgressString = wticc(difficultyData.shortName .. ":" .. progressCount .. "/" .. bossCount, difficultyData.color)
						local basicProgressString = wticc(progressCount .. "/" .. bossCount, currentOrdinal == 1 and difficultyData.color or miog.C.DIFFICULTY[0].color)
						if(sortedProgress.isMainProgress ~= true) then

							if(currentOrdinal ~= lastOrdinal) then
								
								if(miog.F.LISTED_CATEGORY_ID == 3) then
									if(primaryIndicator:GetText() ~= nil and secondaryIndicator:GetText() == nil) then
										secondaryIndicator:SetText(basicProgressString) -- ACTUAL PROGRESS
									end

									if(primaryIndicator:GetText() == nil) then
										primaryIndicator:SetText(basicProgressString) -- ACTUAL PROGRESS
									end
								end

								local raidShortName = sortedProgress.progress.raid.shortName

								local mapID = sortedProgress.progress.raid.mapId
								local textureString = miog.RAID_ICONS[mapID][bossCount + 1]
								local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
								
								raidIndex = raidIndex + 1
								raidPanel.textureRows[raidIndex] = {}

								currentLowerDifficultyFrame = nil
								lowerDifficultyNumber = nil
							
								local raidColumn = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, halfRowWidth, raidPanel:GetHeight())
								raidColumn:SetPoint("TOPLEFT", lastColumn or raidPanel, lastColumn and "TOPRIGHT" or "TOPLEFT")

								lastColumn = raidColumn

								local raidIconFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT, "Texture", textureString)
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

								higherDifficultyNumber = sortedProgress.progress.difficulty

								currentHigherDifficultyFrame = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE,  raidPanel, lastColumn:GetWidth()*0.48, miog.C.APPLICANT_MEMBER_HEIGHT)
								currentHigherDifficultyFrame:SetText(panelProgressString)
								currentHigherDifficultyFrame:SetPoint("TOPLEFT", raidIconFrame, "BOTTOMLEFT")

								for i = 1, ceil(bossCount * 0.5), 1 do
									local currentBossRow = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, halfRowWidth, miog.C.APPLICANT_MEMBER_HEIGHT * 1.4)
									currentBossRow:SetPoint("TOPLEFT", raidPanel.textureRows[raidIndex-1] and raidPanel.textureRows[raidIndex-1][i] or raidPanel.textureRows[raidIndex][i-1] or raidPanel.rows[i+2], raidPanel.textureRows[raidIndex-1] and "TOPRIGHT" or raidPanel.textureRows[raidIndex][i-1] and "BOTTOMLEFT" or "TOPLEFT")
									raidPanel.textureRows[raidIndex][i] = currentBossRow
									raidPanel.textureRows[raidIndex][i].bossFrames = {}

								end

								for i = 1, bossCount, 1 do
									local currentRow = ceil(i * 0.5)

									local index = #raidPanel.textureRows[raidIndex][currentRow].bossFrames + 1

									local bossFrameWH = raidPanel.textureRows[raidIndex][currentRow]:GetHeight() - 2
									
									local bossFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, bossFrameWH, bossFrameWH)
									bossFrame:SetPoint("TOPLEFT", index == 2 and raidPanel.textureRows[raidIndex][currentRow].bossFrames[index-1] or raidPanel.textureRows[raidIndex][currentRow], index == 2 and "TOPRIGHT" or "TOPLEFT", index == 2 and 2 or 0, 0)
									bossFrame:SetMouseClickEnabled(true)
									bossFrame:SetFrameStrata("DIALOG")
									bossFrame:SetScript("OnMouseDown", function()
										local _, _, encounterID = EJ_GetEncounterInfoByIndex(i, instanceID)
										--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
										EncounterJournal_OpenJournal(miog.F.CURRENT_DIFFICULTY, instanceID, encounterID, nil, nil, nil)
		
									end)
		
									local bossFrameTexture = miog.createBasicTexture("fleeting", miog.RAID_ICONS[sortedProgress.progress.raid.mapId][i], bossFrame, bossFrameWH - 2, bossFrameWH - 2)
									bossFrameTexture:SetDrawLayer("ARTWORK")
									bossFrameTexture:SetPoint("TOPLEFT", bossFrame, "TOPLEFT", 1, -1)

									if(sortedProgress.progress.killsPerBoss) then
										local desaturated
										local numberOfBossKills = sortedProgress.progress.killsPerBoss[i]

										if(numberOfBossKills > 0) then
											desaturated = false
											miog.createFrameBorder(bossFrame, 1, miog.ITEM_QUALITY_COLORS[higherDifficultyNumber+1].color:GetRGBA())

										elseif(numberOfBossKills == 0) then
											desaturated = true

										end
										
										bossFrameTexture:SetDesaturated(desaturated)
									end

									bossFrame.Texture = bossFrameTexture
		
									local bossNumber = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE, bossFrame)
									bossNumber:SetPoint("TOPLEFT", bossFrame, "TOPLEFT")
									bossNumber:SetText(i)

									raidPanel.textureRows[raidIndex][currentRow].bossFrames[index] = bossFrame
									
								end

							else
								lowerDifficultyNumber = sortedProgress.progress.difficulty

								if(lowerDifficultyNumber ~= higherDifficultyNumber) then

									if(miog.F.LISTED_CATEGORY_ID == 3) then
										if(secondaryIndicator:GetText() == nil) then
											secondaryIndicator:SetText(basicProgressString) -- ACTUAL PROGRESS
										end
									end

									currentLowerDifficultyFrame = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE,  raidPanel, lastColumn:GetWidth()*0.48, miog.C.APPLICANT_MEMBER_HEIGHT)
									currentLowerDifficultyFrame:SetText(panelProgressString)
									currentLowerDifficultyFrame:SetPoint("TOPLEFT", currentHigherDifficultyFrame, "TOPRIGHT")

									for rowNumber, textureRow in ipairs(raidPanel.textureRows[raidIndex]) do
										for bossIndex, bossFrame in pairs(textureRow.bossFrames) do
											local index = bossIndex == 1 and rowNumber * 2 - 1 or bossIndex == 2 and rowNumber * 2
											local kills = sortedProgress.progress.killsPerBoss and sortedProgress.progress.killsPerBoss[index] or 0
			
											local desaturated = true

											if(sortedProgress.progress.killsPerBoss) then
												if(kills > 0 and bossFrame.Texture:IsDesaturated() == true) then
													desaturated = false
													miog.createFrameBorder(bossFrame, 1, miog.ITEM_QUALITY_COLORS[lowerDifficultyNumber+1].color:GetRGBA())
													bossFrame.Texture:SetDesaturated(desaturated)
												end

											else
												if(progressCount == bossCount) then
													if(bossFrame.Texture:IsDesaturated() == true) then
														desaturated = false
														miog.createFrameBorder(bossFrame, 1, miog.ITEM_QUALITY_COLORS[lowerDifficultyNumber+1].color:GetRGBA())
														bossFrame.Texture:SetDesaturated(desaturated)
													end

												end
											end

										end
									end
								end
							end

							lastOrdinal = currentOrdinal
						else
							local difficulty = miog.C.DIFFICULTY[sortedProgress.progress.difficulty]
							mainProgressText = mainProgressText .. wticc(difficulty.shortName .. ":" .. sortedProgress.progress.progressCount .. "/" .. sortedProgress.progress.raid.bossCount, difficulty.color) .. " "

							if(miog.F.LISTED_CATEGORY_ID == 3) then
								if(primaryIndicator:GetText() == nil) then
									primaryIndicator:SetText(wticc("0/0", miog.C.DIFFICULTY[-1].color))
								end

								if(secondaryIndicator:GetText() == nil) then
									secondaryIndicator:SetText(wticc("0/0", miog.C.DIFFICULTY[-1].color))
								end
							end
						
						end

					end

					if(mainProgressText ~= "") then
						raidPanel.rows[15].FontString:SetText(wticc("Main: " .. mainProgressText, miog.ITEM_QUALITY_COLORS[6].pureHex))

					else
						raidPanel.rows[15].FontString:SetText(wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex))
						
					end

					if(miog.F.LISTED_CATEGORY_ID == 3) then
						if(primaryIndicator:GetText() == nil) then
							primaryIndicator:SetText(wticc("0/0", miog.C.DIFFICULTY[-1].color))
						end

						if(secondaryIndicator:GetText() == nil) then
							secondaryIndicator:SetText(wticc("0/0", miog.C.DIFFICULTY[-1].color))
						end
					end

				else
					raidPanel.rows[1].FontString:SetText(wticc("NO RAIDING DATA", miog.CLRSCC["red"]))
					raidPanel.rows[1].FontString:SetPoint("LEFT", raidPanel.rows[1], "LEFT", 2, 0)

					if(miog.F.LISTED_CATEGORY_ID == 3) then
						local difficulty = miog.C.DIFFICULTY[-1] -- NO DATA
						primaryIndicator:SetText(wticc("0/0", difficulty.color))
						secondaryIndicator:SetText(wticc("0/0", difficulty.color))
					end

				end
				
			else -- If RaiderIO is not installed
				mythicPlusPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))
				mythicPlusPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)

				raidPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))
				raidPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)

				local difficulty = miog.C.DIFFICULTY[-1] -- NO DATA

				if(miog.F.LISTED_CATEGORY_ID == 3) then
					primaryIndicator:SetText(wticc("0/0", difficulty.color))
					secondaryIndicator:SetText(wticc("0/0", difficulty.color))

				end

			end

			basicInformationPanel:MarkDirty()
			detailedInformationPanel:MarkDirty()
			applicantMemberFrame:MarkDirty()
			--applicantFrame:MarkDirty()

		end

		applicantFrame:MarkDirty()
		lastApplicantFrame = applicantFrame
		addonApplicantList[applicantID].frame = applicantFrame
		addonApplicantList[applicantID].creationStatus = "added"

	end

end

miog.checkApplicantList = function(needRefresh)
	local allApplicants = miog.F.IS_IN_DEBUG_MODE and debugApplicantIDList or C_LFGList:GetApplicants()

	if(needRefresh == true) then
		refreshFunction()

	end

	local unsortedMainApplicantsList = {}

	for _, applicantID in ipairs(allApplicants) do

		local applicantData = miog.F.IS_IN_DEBUG_MODE and debugLFGList[applicantID] or C_LFGList.GetApplicantInfo(applicantID)

		if(applicantData and applicantData.displayOrderID > 0) then
			local fullName, ilvl, assignedRole, dungeonScore, primarySort, secondarySort
			local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityID or 0
			local profile

			fullName, _, _, _, ilvl, _, _, _, _, assignedRole, _, dungeonScore = C_LFGList.GetApplicantMemberInfo(applicantID, 1)

			if(miog.F.IS_RAIDERIO_LOADED) then
				if(not miog.F.IS_IN_DEBUG_MODE) then
					local nameTable = miog.simpleSplit(fullName, "-")
					profile = getRioProfile(nameTable[1], nameTable[2], miog.C.CURRENT_REGION)

				else
					ilvl = debugLFGList[applicantID].applicantMemberList[1][5]
					assignedRole = debugLFGList[applicantID].applicantMemberList[1][10]
					profile = getRioProfile(unpack(debugLFGList[applicantID].applicantMemberList[1][17]))
					debugLFGList[applicantID].applicantMemberList[1][12] = profile and profile.mythicKeystoneProfile.currentScore or debugLFGList[applicantID].applicantMemberList[1][12]

				end
			end

			if(miog.F.LISTED_CATEGORY_ID ~= (3 or 4 or 7 or 8 or 9)) then
				if(not miog.F.IS_IN_DEBUG_MODE) then
					primarySort = dungeonScore
					secondarySort = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activityID).bestRunLevel

				else
					primarySort = debugLFGList[applicantID].applicantMemberList[1][12]
					secondarySort = debugLFGList[applicantID].applicantMemberList[1][14].bestRunLevel

				end

			elseif(miog.F.LISTED_CATEGORY_ID == 3) then
				local raidData = {}
				local weightsTable

				if(profile) then
					if(profile.raidProfile) then
						local lastDifficulty = nil
						local lastOrdinal = nil

						for i = 1, #profile.raidProfile.sortedProgress, 1 do
							if(profile.raidProfile.sortedProgress[i] and profile.raidProfile.sortedProgress[i].progress.raid.ordinal and not profile.raidProfile.sortedProgress[i].isMainProgress) then
								if(profile.raidProfile.sortedProgress[i].progress.raid.ordinal ~= lastOrdinal or profile.raidProfile.sortedProgress[i].progress.difficulty ~= lastDifficulty) then
									local bossCount = profile.raidProfile.sortedProgress[i].progress.raid.bossCount
									local kills = profile.raidProfile.sortedProgress[i].progress.progressCount or 0

									weightsTable = miog.generateRaidWeightsTable(bossCount)

									raidData[#raidData+1] = {
										ordinal = profile.raidProfile.sortedProgress[i].progress.raid.ordinal,
										difficulty = profile.raidProfile.sortedProgress[i].progress.difficulty,
										progress = kills,
										bossCount = bossCount,
										parsedString = kills .. "/" .. bossCount
									}

									if(#raidData == 2) then
										break
									end
								end

								lastOrdinal = raidData[i] and raidData[i].ordinal
								lastDifficulty = raidData[i] and raidData[i].difficulty

							else
							end
						end
					else
						raidData[1] = {
							ordinal = 0,
							difficulty = -1,
							progress = 0,
							bossCount = 0,
							parsedString = "0/0"
						}
						
						raidData[2] = {
							ordinal = 0,
							difficulty = -1,
							progress = 0,
							bossCount = 0,
							parsedString = "0/0"
						}


					end
				else
					raidData[1] = {
						ordinal = 0,
						difficulty = -1,
						progress = 0,
						bossCount = 0,
						parsedString = "0/0"
					}
					
					raidData[2] = {
						ordinal = 0,
						difficulty = -1,
						progress = 0,
						bossCount = 0,
						parsedString = "0/0"
					}

				end

				for i = 1, 2, 1 do
					if(not raidData[i]) then
						raidData[i] = {
							ordinal = 0,
							difficulty = -1,
							progress = 0,
							bossCount = 0,
							parsedString = "0/0"
						}
					end
				end

				primarySort = raidData[1].bossCount > 0 and raidData[1].progress / raidData[1].bossCount + (raidData[1].ordinal == 1 and weightsTable[raidData[1].difficulty] or 0) or 0
				secondarySort = raidData[2].bossCount > 0 and raidData[2].progress / raidData[2].bossCount + (raidData[2].ordinal == 1 and weightsTable[raidData[2].difficulty] or 0) or 0
			
			elseif(miog.F.LISTED_CATEGORY_ID == (4 or 7 or 8 or 9)) then
				if(not miog.F.IS_IN_DEBUG_MODE) then
					local pvpInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activityID)

					primarySort = pvpInfo.rating
					secondarySort = pvpInfo.rating

				else
					primarySort = debugLFGList[applicantID].applicantMemberList[1][16].rating
					secondarySort = debugLFGList[applicantID].applicantMemberList[1][16].rating

				end

			end

			if(assignedRole == "TANK") then
				miog.F.APPLIED_NUM_OF_TANKS = miog.F.APPLIED_NUM_OF_TANKS + 1

			elseif(assignedRole == "HEALER") then
				miog.F.APPLIED_NUM_OF_HEALERS = miog.F.APPLIED_NUM_OF_HEALERS + 1

			elseif(assignedRole == "DAMAGER") then
				miog.F.APPLIED_NUM_OF_DPS = miog.F.APPLIED_NUM_OF_DPS + 1

			end

			if(assignedRole == "TANK" and miog.F.SHOW_TANKS or assignedRole == "HEALER" and miog.F.SHOW_HEALERS or assignedRole == "DAMAGER" and miog.F.SHOW_DPS) then
				unsortedMainApplicantsList[#unsortedMainApplicantsList+1] = {
					index = applicantID,
					role = assignedRole,
					primary = primarySort,
					secondary = secondarySort,
					ilvl = ilvl
				}

			end
		end
	end

	miog.mainFrame.buttonPanel.RoleTextures[1].text:SetText(miog.F.APPLIED_NUM_OF_TANKS)
	miog.mainFrame.buttonPanel.RoleTextures[2].text:SetText(miog.F.APPLIED_NUM_OF_HEALERS)
	miog.mainFrame.buttonPanel.RoleTextures[3].text:SetText(miog.F.APPLIED_NUM_OF_DPS)

	if(unsortedMainApplicantsList[1]) then
		table.sort(unsortedMainApplicantsList, sortApplicantList)

		for _, listEntry in ipairs(unsortedMainApplicantsList) do
			if(addonApplicantList[listEntry.index] == nil) then
				addonApplicantList[listEntry.index] = {
					creationStatus = "inProgress",
					frame = nil,
				}

				addApplicantToPanel(listEntry.index)
			end

		end
	end
end

local function createFullEntries(iterations)
	refreshFunction()

	for index = 1, iterations, 1 do
		local applicantID = random(1000, 9999)

		debugApplicantIDList[index] = applicantID

		debugLFGList[applicantID] = {
			applicantID = applicantID,
			applicationStatus = "applied",
			numMembers = 1,
			isNew = true,
			comment = "Heiho, heiho, wir sind vergnügt und froh. Johei, johei, die Arbeit ist vorbei.",
			displayOrderID = 1,
			applicantMemberList = {}
		}

		local name, realm = UnitFullName("player")

		for memberIndex = 1, debugLFGList[applicantID].numMembers, 1 do
			local rating = random(1, 4000)
			rating = 0
			local progress1, progress2 = random(1, 9), random(1, 9)
			local diff = random(1, 3)
			local ordinal = random(1, 2)

			local rioProfile = miog.DEBUG_RAIDER_IO_PROFILES[random(1, #miog.DEBUG_RAIDER_IO_PROFILES)]
			local classInfo = C_CreatureInfo.GetClassInfo(random(1, 13))

			debugLFGList[applicantID].applicantMemberList[memberIndex] = {
				[1] = rioProfile[1] .. "-" .. rioProfile[2],
				[2] = classInfo.classFile, --ENG
				[3] = classInfo.className, --GER
				[4] = UnitLevel("player"),
				[5] = random(0, 450) + 0.5,
				[6] = UnitHonorLevel("player"),
				[7] = false,
				[8] = false,
				[9] = true,
				[10] = miog.DEBUG_ROLE_TABLE[random(1, 3)],
				[11] = true,
				[12] = rating,
				[13] = random(400, 450) + 0.5,
				[14] = {finishedSuccess = true, bestRunLevel = random(20, 35), mapName = "Big Dick Land"},
				[15] = {
					[1] = {
						ordinal = ordinal,
						difficulty = diff,
						progress = progress1,
						bossCount = 9,
						parsedString = progress1 .. "/9"
					},
					[2] = {
						ordinal = random(ordinal, ordinal+1),
						difficulty = diff,
						progress = progress2,
						bossCount = 9,
						parsedString = progress2 .. "/9"
					}
				},
				[16] = {bracket = "", rating = rating, activityName = "XD", tier = miog.debugGetTestTier(rating)},
				[17] = rioProfile
			}
		
		end

	end

	miog.checkApplicantList(false)
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

	if(miog.F.NUM_OF_GROUP_MEMBERS > 5) then

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
				miog.F.CURRENT_GROUP_INFO[#miog.F.CURRENT_GROUP_INFO + 1] = {guid = "empty", unitID = "empty", name = "afk", class = "NONE", role = "TANK", specIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			end

			if(groupCount["HEALER"] < 1 and #miog.F.CURRENT_GROUP_INFO < 5) then
				miog.F.CURRENT_GROUP_INFO[#miog.F.CURRENT_GROUP_INFO + 1] = {guid = "empty", unitID = "empty", name = "afk", class = "NONE", role = "HEALER", specIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			end

			for i = 1, 3 - groupCount["DAMAGER"], 1 do
				if(groupCount["DAMAGER"] < 3 and #miog.F.CURRENT_GROUP_INFO < 5) then
					miog.F.CURRENT_GROUP_INFO[#miog.F.CURRENT_GROUP_INFO + 1] = {guid = "empty", unitID = "empty"..i, name = "afk", class = "NONE", role = "DAMAGER", specIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
				end
			end
		end

		miog.sortTableForRoleAndClass(miog.F.CURRENT_GROUP_INFO)

		local lastIcon = nil

		for _, groupMember in ipairs(miog.F.CURRENT_GROUP_INFO) do
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.titleBar.groupMemberListing, miog.mainFrame.titleBar.factionIconSize, miog.mainFrame.titleBar.factionIconSize, "Texture", groupMember.specIcon)
			classIconFrame:SetPoint("LEFT", lastIcon or miog.mainFrame.titleBar.groupMemberListing, lastIcon and "RIGHT" or "LEFT")
			classIconFrame:SetFrameStrata("DIALOG")

			lastIcon = classIconFrame
		end

		lastIcon = nil
		
		if(miog.F.IS_IN_DEBUG_MODE) then
			for _, groupMember in ipairs(miog.F.CURRENT_GROUP_INFO) do
				local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", WorldFrame, miog.mainFrame.titleBar.factionIconSize, miog.mainFrame.titleBar.factionIconSize, "Texture", groupMember.specIcon)
				classIconFrame:SetPoint("TOPLEFT", lastIcon or WorldFrame, lastIcon and "TOPRIGHT" or "TOPLEFT")
				classIconFrame:SetFrameStrata("DIALOG")
				miog.createFrameBorder(classIconFrame, 1)

				lastIcon = classIconFrame
			end
		end

		miog.mainFrame.titleBar.groupMemberListing:MarkDirty()
	end
end

local function requestInspectDataFromFullGroup()
	local inPartyOrRaid = UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "player"

	local unitID, name, class, role, specID

	for groupIndex = 1, miog.F.NUM_OF_GROUP_MEMBERS, 1 do
		unitID = inPartyOrRaid..groupIndex == "party"..miog.F.NUM_OF_GROUP_MEMBERS and "player" or inPartyOrRaid..groupIndex
		specID = GetInspectSpecialization(unitID)
		name, class, role = UnitName(unitID), UnitClassBase(unitID), unitID == "player" and (GetSpecializationRoleByID(specID) or UnitGroupRolesAssigned("player")) or UnitGroupRolesAssigned(unitID)

		if(specID == 0 or specID == nil) then

			if(miog.F.INSPECT_QUEUE[UnitGUID(unitID)] == nil) then -- CHECK IF GUID ISNT IN ARRAY
				miog.F.INSPECT_QUEUE[UnitGUID(unitID)] = {[1] = false, [2] = unitID, [3] = 0, [4] = name, [5] = class or "NONE", [6] = role or ""} -- SET GUID TO FALSE -> NO DATA AVAILABLE

				if(miog.F.CURRENTLY_INSPECTING == false) then
					miog.F.CURRENTLY_INSPECTING = true

					NotifyInspect(unitID)

				end
			end
		else
			miog.F.INSPECT_QUEUE[UnitGUID(unitID)] = {[1] = true, [2] = unitID, [3] = specID, [4] = name, [5] = class or "NONE", [6] = role or ""}
			updateRoster()

		end
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
		--LFGListFrame.ApplicationViewer = miog.mainFrame

		hooksecurefunc("LFGListFrame_SetActivePanel", function(selfFrame, panel)
			if(panel == LFGListFrame.ApplicationViewer) then
				--LFGListFrame.ApplicationViewer:Hide()
				--miog.mainFrame:Show()
			else
				miog.mainFrame:Hide()
			end
		end)


	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then --LISTING CHANGES

		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		local activityInfo

		if(C_LFGList.HasActiveEntryInfo() == true) then
			activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)

			miog.F.LISTED_CATEGORY_ID = activityInfo.categoryID

			miog.mainFrame.buttonPanel.sortByCategoryButtons.secondary:Enable()

			if(activityInfo.categoryID == 2) then --Dungeons
				miog.mainFrame.infoPanel.affixFrame:Show()
				miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[11]
					
				miog.F.CURRENT_DIFFICULTY = miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DIFFICULTY

			else
				if(activityInfo.categoryID == 1) then --Questing
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[13]

				elseif(activityInfo.categoryID == 3) then --Raids
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[2]
					
					miog.F.CURRENT_DIFFICULTY = miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DIFFICULTY

				elseif(activityInfo.categoryID == 4) then --Arenas
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[4]

				elseif(activityInfo.categoryID == 5) then --Scenario
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[17]

				elseif(activityInfo.categoryID == 6) then --Custom
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[12]

				elseif(activityInfo.categoryID == 7) then --Skirmishes
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[6]

				elseif(activityInfo.categoryID == 8) then --Battlegrounds
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[5]

				elseif(activityInfo.categoryID == 9) then --Rated Battlegrounds
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[14]

				elseif(activityInfo.categoryID == 111) then --Island Expeditions
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[1]

				elseif(activityInfo.categoryID == 113) then --Torghast ... LOL
					miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[15]
					
				end

				miog.mainFrame.infoPanel.affixFrame:Hide()
			end

			miog.mainFrame.infoPanelBackdropFrame:ApplyBackdrop()

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

			queueTimer = C_Timer.NewTicker(1, function()
				local time = miog.secondsToClock(GetTimePreciseSec() - MIOG_QueueUpTime)
				miog.mainFrame.infoPanel.timerFrame.FontString:SetText(time)

			end)
			miog.mainFrame:Show()
		end

	elseif(event == "LFG_LIST_APPLICANT_UPDATED") then --ONE APPLICANT
		local applicantData = C_LFGList.GetApplicantInfo(...)

		if(applicantData) then
			if(applicantData.applicationStatus ~= "applied") then
				if(addonApplicantList[...] and addonApplicantList[...].creationStatus == "added") then
					updateApplicantStatus(..., applicantData.applicationStatus)
					
				end
			--elseif(applicantData.applicationStatus == "applied" and applicantData.displayOrderID > 0) then

			end
		end

	elseif(event == "LFG_LIST_APPLICANT_LIST_UPDATED") then --ALL THE APPLICANTS

		local newEntry, withData = ...

		if(newEntry == true and withData == false) then --NEW APPLICANT WITHOUT DATA

		elseif(newEntry == true and withData == true) then --NEW APPLICANT WITH DATA
			miog.checkApplicantList(false)

		elseif(newEntry == false and withData == false) then --DECLINED APPLICANT
			miog.checkApplicantList(true)

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
			getRioProfile = RaiderIO.GetProfile
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

		if(UnitIsGroupLeader("player")) then
			miog.footerBar:Show()
			miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.footerBar, "TOPRIGHT", 0, 0)

		else
			miog.footerBar:Hide()
			miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)

		end

	elseif(event == "INSPECT_READY") then

		if(miog.F.INSPECT_QUEUE[...]) then
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
end

SLASH_MIOG1 = '/miog'
local function handler(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if(command == "") then

	elseif(command == "options") then
		MIOG_OpenInterfaceOptions()

	elseif(command == "debug") then
		
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")
		if(IsInGroup()) then
			PVEFrame:Show()
			LFGListFrame:Show()
			LFGListPVEStub:Show()
			LFGListFrame.ApplicationViewer:Show()

			createFullEntries(33)

			miog.mainFrame:Show()
		end

	elseif(command == "debugoff") then
		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false
		refreshFunction()
	
	elseif(command == "perfstart") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

		local index = 1
		local tickRate = 0.2
		local numberOfEntries = 33
		local testLength = (tonumber(rest) or 10) / tickRate -- in seconds

		debugTimer = C_Timer.NewTicker(tickRate, function(self)
			local startTime = GetTimePreciseSec()

			createFullEntries(numberOfEntries)
			
			local endTime = GetTimePreciseSec()

			currentAverageExecuteTime[#currentAverageExecuteTime+1] = endTime - startTime

			print(currentAverageExecuteTime[#currentAverageExecuteTime])

			index = index + 1

			if(index == testLength) then
				self:Cancel()

				local avg = 0
				
				for _,v in ipairs(currentAverageExecuteTime) do
					avg = avg + v
				end
				
				print("Avg exec time: "..avg / #currentAverageExecuteTime)
				
				print("Debug mode off - Normal applicant mode")
				miog.F.IS_IN_DEBUG_MODE = false
				refreshFunction()
			end
		end)

	elseif(command == "perfstop") then
		if(debugTimer) then
			debugTimer:Cancel()
				
			local avg = 0

			for _,v in ipairs(currentAverageExecuteTime) do
				avg = avg + v
			end
			
			print("Avg exec time: "..avg / #currentAverageExecuteTime)
		end

		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false
		refreshFunction()

	else
		miog.mainFrame:Show()

	end
end
SlashCmdList["MIOG"] = handler