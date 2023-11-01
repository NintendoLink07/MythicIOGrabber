local addonName, miog = ...

local expandedFrameList = {}

local lastApplicantFrame
local applicantFramePadding = 6

--local inspectData = {}

local groupSystem = {}
groupSystem.groupMember = {}

local applicantSystem = {}
applicantSystem.applicantMember = {}

local currentAverageExecuteTime = {}
local debugTimer = nil

local getRioProfile
local fmod = math.fmod
local rep = string.rep
local wticc = WrapTextInColorCode
local tostring = tostring
local CreateColorFromHexString = CreateColorFromHexString

local queueTimer

local function resetArrays()
	miog.DEBUG_APPLICANT_DATA = {}
	miog.DEBUG_APPLICANT_MEMBER_INFO = {}
end

local function refreshFunction()
	miog.releaseAllFleetingWidgets()

	for k,v in pairs(applicantSystem.applicantMember) do
		v.activeFrame = nil
	end

	lastApplicantFrame = nil

	miog.F.APPLIED_NUM_OF_DPS = 0
	miog.F.APPLIED_NUM_OF_HEALERS = 0
	miog.F.APPLIED_NUM_OF_TANKS = 0

	miog.mainFrame.buttonPanel.RoleTextures[1].text:SetText(miog.F.APPLIED_NUM_OF_TANKS)
	miog.mainFrame.buttonPanel.RoleTextures[2].text:SetText(miog.F.APPLIED_NUM_OF_HEALERS)
	miog.mainFrame.buttonPanel.RoleTextures[3].text:SetText(miog.F.APPLIED_NUM_OF_DPS)

end

local function updateApplicantStatus(applicantID, applicantStatus)
	local currentApplicant = applicantSystem.applicantMember[applicantID]

	if(currentApplicant and currentApplicant.activeFrame) then

		for _, memberFrame in pairs(currentApplicant.activeFrame.memberFrames) do
			memberFrame.statusFrame:Show()
			memberFrame.statusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[applicantStatus].statusString, miog.APPLICANT_STATUS_INFO[applicantStatus].color))

			if(memberFrame.basicInformationPanel.inviteButton) then
				memberFrame.basicInformationPanel.inviteButton:Disable()
	
			end
		end

		if(applicantStatus == "invited") then
			currentApplicant.status = "pendingInvite"

		else
			currentApplicant.status = "removable"
			currentApplicant.activeFrame = nil

		end
	end
end

--[[local function updateApplicantStatus(applicantID, applicantStatus)
	local currentApplicant = applicantSystem.applicantMember[applicantID]

	if(currentApplicant and currentApplicant.frame) then
		if(currentApplicant.frame.inviteButton) then
			currentApplicant.frame.inviteButton:Disable()
		end

		for _, memberFrame in pairs(currentApplicant.frame.memberFrames) do
			memberFrame.statusFrame:Show()
			memberFrame.statusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[applicantStatus].statusString, miog.APPLICANT_STATUS_INFO[applicantStatus].color))

		end

		currentApplicant.creationStatus = applicantStatus == "invited" and "invited" or "canBeRemoved"
	end
end]]

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

	local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

	if(applicantData) then
		local activityID = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.activityID or 0

		expandedFrameList[applicantID] = expandedFrameList[applicantID] or {}

		local applicantMemberPadding = 2
		local applicantFrame = miog.createBasicFrame("fleeting", "ResizeLayoutFrame, BackdropTemplate", miog.mainFrame.applicantPanel.container)
		applicantFrame:SetPoint("TOP", lastApplicantFrame or miog.mainFrame.applicantPanel.container, lastApplicantFrame and "BOTTOM" or "TOP", 0, lastApplicantFrame and -applicantFramePadding or 0)
		applicantFrame.fixedWidth = miog.C.MAIN_WIDTH - 2
		applicantFrame.heightPadding = 1
		applicantFrame.minimumHeight = applicantData.numMembers * (miog.C.APPLICANT_MEMBER_HEIGHT + applicantMemberPadding)
		applicantFrame.memberFrames = {}
		applicantSystem.applicantMember[applicantID].activeFrame = applicantFrame

		miog.createFrameBorder(applicantFrame, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

		for applicantIndex = 1, applicantData.numMembers, 1 do

			local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, factionGroup, raceID, specID -- specID is new in 10.2
			local dungeonData, pvpData, rioProfile
			
			if(miog.F.IS_IN_DEBUG_MODE) then
				name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, _, specID, dungeonData, pvpData = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

			else
				name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, _, specID  = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)
				dungeonData = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, applicantIndex, activityID)
				pvpData = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, applicantIndex, activityID)

			end

			local nameTable = miog.simpleSplit(name, "-")
			
			local profile, mythicKeystoneProfile, dungeonProfile, raidProfile

			if(miog.F.IS_RAIDERIO_LOADED) then
				profile = getRioProfile(nameTable[1], nameTable[2], miog.C.CURRENT_REGION)

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

			local coloredSubName = name == "Rhany-Ravencrest" and wticc(nameTable[1], miog.ITEM_QUALITY_COLORS[6].pureHex) or wticc(nameTable[1], select(4, GetClassColor(class)))

			local nameFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", basicInformationPanel, basicInformationPanel.fixedWidth * 0.27, basicInformationPanel.maximumHeight, "FontString", miog.C.APPLICANT_MEMBER_FONT_SIZE)
			nameFrame:SetPoint("LEFT", expandFrameButton, "RIGHT", 0, 0)
			nameFrame:SetFrameStrata("DIALOG")
			nameFrame.FontString:SetText(coloredSubName)
			nameFrame:SetMouseMotionEnabled(true)
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
			nameFrame:SetScript("OnEnter", function()
				if(nameFrame.FontString:IsTruncated()) then
					GameTooltip:SetOwner(nameFrame, "ANCHOR_CURSOR")
					GameTooltip:SetText(nameFrame.FontString:GetText())
					GameTooltip:Show()

				elseif(name == "Rhany-Ravencrest") then
					GameTooltip:SetOwner(nameFrame, "ANCHOR_CURSOR")
					GameTooltip:AddLine("You've found the creator of this addon.\nHow lucky!")
					GameTooltip:Show()

				end

			end)
			nameFrame:SetScript("OnLeave", function()
				GameTooltip:Hide()

			end)

			nameFrame.linkBox = miog.createBasicFrame("fleeting", "InputBoxTemplate", applicantMemberFrame, nil, miog.C.APPLICANT_MEMBER_HEIGHT)
			nameFrame.linkBox:SetFont(miog.FONTS["libMono"], miog.C.APPLICANT_MEMBER_FONT_SIZE, "OUTLINE")
			nameFrame.linkBox:SetFrameStrata("FULLSCREEN")
			nameFrame.linkBox:SetPoint("TOPLEFT", applicantMemberStatusFrame, "TOPLEFT", 5, 0)
			nameFrame.linkBox:SetPoint("TOPRIGHT", applicantMemberStatusFrame, "TOPRIGHT", -1, 0)
			nameFrame.linkBox:SetAutoFocus(true)
			nameFrame.linkBox:SetScript("OnKeyDown", function(_, key)
				if(key == "ESCAPE" or key == "ENTER") then
					nameFrame.linkBox:Hide()
					nameFrame.linkBox:ClearFocus()

				end
			end)
			nameFrame.linkBox:Hide()

			if(applicantData.comment ~= "" and applicantData.comment ~= nil) then
				local commentFrame = miog.createBasicTexture("fleeting", 136459, basicInformationPanel, basicInformationPanel.maximumHeight - 10, basicInformationPanel.maximumHeight - 10)
				commentFrame:ClearAllPoints()
				commentFrame:SetPoint("BOTTOMRIGHT", expandFrameButton, "BOTTOMRIGHT", 0, 0)
			end

			local specFrame

			if(specID) then
				specFrame = miog.createBasicTexture("fleeting", miog.SPECIALIZATIONS[specID].icon, basicInformationPanel, basicInformationPanel.maximumHeight - 4, basicInformationPanel.maximumHeight - 4)
				specFrame:SetPoint("LEFT", nameFrame, "RIGHT", 3, 0)
				specFrame:SetDrawLayer("ARTWORK")
			else
				nameFrame:SetWidth(nameFrame:GetWidth() + basicInformationPanel.maximumHeight)
			end
	
			local roleFrame = miog.createBasicTexture("fleeting", nil, basicInformationPanel, basicInformationPanel.maximumHeight - 1, basicInformationPanel.maximumHeight - 1)
			roleFrame:SetPoint("LEFT", specFrame or nameFrame, "RIGHT", 1, 0)
			
			roleFrame:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. assignedRole .. "Icon.png")

			local primaryIndicator = miog.createBasicFontString("fleeting", miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.11, basicInformationPanel.maximumHeight)
			primaryIndicator:SetPoint("LEFT", roleFrame, "RIGHT", 5, 0)
			primaryIndicator:SetJustifyH("CENTER")

			local secondaryIndicator = miog.createBasicFontString("fleeting", miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.11, basicInformationPanel.maximumHeight)
			secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 1, 0)
			secondaryIndicator:SetJustifyH("CENTER")

			local itemLevelFrame = miog.createBasicFontString("fleeting", miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.13, basicInformationPanel.maximumHeight)
			itemLevelFrame:SetPoint("LEFT", secondaryIndicator, "RIGHT", 1, 0)
			itemLevelFrame:SetJustifyH("CENTER")

			local reqIlvl = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel or 0

			if(reqIlvl > itemLevel) then
				itemLevelFrame:SetText(wticc(miog.round(itemLevel, 1), miog.CLRSCC["red"]))

			else
				itemLevelFrame:SetText(miog.round(itemLevel, 1))

			end

			if(relationship) then
				local friendFrame = miog.createBasicTexture("fleeting", miog.C.STANDARD_FILE_PATH .. "/infoIcons/friend.png", basicInformationPanel, basicInformationPanel.maximumHeight - 3, basicInformationPanel.maximumHeight - 3)
				friendFrame:SetPoint("LEFT", itemLevelFrame, "RIGHT", 3, 0)
				friendFrame:SetDrawLayer("OVERLAY")
				friendFrame:SetMouseMotionEnabled(true)
				friendFrame:SetScript("OnEnter", function()
					GameTooltip:SetOwner(friendFrame, "ANCHOR_CURSOR")
					GameTooltip:SetText("On your friendlist")
					GameTooltip:Show()

				end)
				friendFrame:SetScript("OnLeave", function()
					GameTooltip:Hide()

				end)
			end

			if(applicantIndex > 1) then
				local groupFrame = miog.createBasicTexture("fleeting", miog.C.STANDARD_FILE_PATH .. "/infoIcons/link.png", basicInformationPanel, basicInformationPanel.maximumHeight - 3, basicInformationPanel.maximumHeight - 3)
				groupFrame:ClearAllPoints()
				groupFrame:SetDrawLayer("OVERLAY")
				groupFrame:SetPoint("TOPRIGHT", basicInformationPanel, "TOPRIGHT", -1, -1)
			end

			if(applicantIndex == 1 and C_PartyInfo.CanInvite() or applicantIndex == 1 and miog.F.IS_IN_DEBUG_MODE) then
				local declineButton = miog.createBasicFrame("fleeting", "IconButtonTemplate", basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight)
				declineButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
				declineButton.iconSize = basicInformationPanel.maximumHeight - 4
				declineButton:OnLoad()
				declineButton:SetPoint("RIGHT", basicInformationPanel, "RIGHT", 0, 0)
				declineButton:SetFrameStrata("DIALOG")
				declineButton:RegisterForClicks("LeftButtonUp")
				declineButton:SetScript("OnClick", function()
					print(applicantSystem.applicantMember[applicantID].status)

					if(applicantSystem.applicantMember[applicantID].status == "fullyAdded") then
						
						if(not miog.F.IS_IN_DEBUG_MODE) then
							C_LFGList.DeclineApplicant(applicantID)

						else
							miog.debug_DeclineApplicant(applicantID)

						end

					elseif(applicantSystem.applicantMember[applicantID].status == "removable") then
						if(not miog.F.IS_IN_DEBUG_MODE) then
							miog.checkApplicantList(true)

						else
							miog.debug_DeclineApplicant(applicantID)

						end

					end
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

					if(miog.F.IS_IN_DEBUG_MODE) then
						updateApplicantStatus(applicantID, "debug")
						--debugApplicantData[applicantID] = nil
					end

				end)

				applicantMemberFrame.basicInformationPanel.inviteButton = inviteButton
			end
			
			local detailedInformationPanel = miog.createBasicFrame("fleeting", "ResizeLayoutFrame, BackdropTemplate", applicantMemberFrame)
			detailedInformationPanel:SetWidth(basicInformationPanel.fixedWidth)

			detailedInformationPanel:SetPoint("TOPLEFT", basicInformationPanel, "BOTTOMLEFT", 0, 0)
			detailedInformationPanel:SetShown(expandFrameButton:GetActiveState() > 0 and true or false)
			local rowWidth = detailedInformationPanel:GetWidth() * 0.5

			applicantMemberFrame.detailedInformationPanel = detailedInformationPanel

			local tabPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel)
			tabPanel:SetPoint("TOPLEFT", detailedInformationPanel, "TOPLEFT")
			tabPanel:SetPoint("TOPRIGHT", detailedInformationPanel, "TOPRIGHT")
			tabPanel:SetHeight(miog.C.APPLICANT_MEMBER_HEIGHT)
			tabPanel.rows = {}

			detailedInformationPanel.tabPanel = tabPanel

			local mythicPlusTabButton = miog.createBasicFrame("fleeting", "UIPanelButtonTemplate", tabPanel)
			mythicPlusTabButton:SetSize(rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
			mythicPlusTabButton:SetPoint("LEFT", tabPanel, "LEFT")
			mythicPlusTabButton:SetFrameStrata("DIALOG")
			mythicPlusTabButton:SetText("Mythic+")
			mythicPlusTabButton:RegisterForClicks("LeftButtonDown")
			mythicPlusTabButton:SetScript("OnClick", function()
				tabPanel.mythicPlusPanel:Show()
				tabPanel.raidPanel:Hide()

				detailedInformationPanel:SetHeight(tabPanel.mythicPlusPanel:GetHeight())
				detailedInformationPanel:MarkDirty()
				applicantFrame:MarkDirty()
			end)
			tabPanel.mythicPlusTabButton = mythicPlusTabButton

			local raidTabButton = miog.createBasicFrame("fleeting", "UIPanelButtonTemplate", tabPanel)
			raidTabButton:SetSize(rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
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

			local raidPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, rowWidth, (miog.F.MOST_BOSSES) * 20)
			raidPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
			tabPanel.raidPanel = raidPanel
			raidPanel:SetShown(miog.F.LISTED_CATEGORY_ID == 3 and true)
			raidPanel.rows = {}

			local mythicPlusPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, rowWidth, 8 * 20)
			mythicPlusPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
			tabPanel.mythicPlusPanel = mythicPlusPanel
			mythicPlusPanel:SetShown(miog.F.LISTED_CATEGORY_ID ~= 3 and true)
			mythicPlusPanel.rows = {}

			local generalInfoPanel = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel, rowWidth, 8 * 20)
			generalInfoPanel:SetPoint("TOPRIGHT", tabPanel, "BOTTOMRIGHT")
			tabPanel.generalInfoPanel = generalInfoPanel
			generalInfoPanel.rows = {}

			local lastTextRow = nil

			for rowIndex = 1, miog.F.MOST_BOSSES, 1 do
				local remainder = fmod(rowIndex, 2)

				local textRowFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", detailedInformationPanel)
				textRowFrame:SetSize(detailedInformationPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT)
				textRowFrame:SetPoint("TOPLEFT", lastTextRow or mythicPlusTabButton, "BOTTOMLEFT")
				lastTextRow = textRowFrame
				tabPanel.rows[rowIndex] = textRowFrame

				if(remainder == 1) then
					textRowFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
					textRowFrame:SetBackdropColor(CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())

				else
					textRowFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
					textRowFrame:SetBackdropColor(CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA())

				end

				local divider = miog.createBasicTexture("fleeting", nil, textRowFrame, textRowFrame:GetWidth(), 1, "BORDER")
				divider:SetAtlas("UI-LFG-DividerLine")
				divider:SetPoint("BOTTOM", textRowFrame, "BOTTOM", 0, 0)

				if(rowIndex == 1 or rowIndex == 6 or rowIndex == 7 or rowIndex == 8 or rowIndex == 9) then
					local textRowGeneralInfo = miog.createBasicFrame("fleeting", "BackdropTemplate", textRowFrame, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", miog.C.TEXT_ROW_FONT_SIZE)
					textRowGeneralInfo.FontString:SetJustifyH("CENTER")
					textRowGeneralInfo:SetPoint("LEFT", textRowFrame, "LEFT", rowWidth, 0)
					generalInfoPanel.rows[rowIndex] = textRowGeneralInfo
					
					if(rowIndex == 1 or rowIndex == 6) then
						local textRowMythicPlus = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", miog.C.TEXT_ROW_FONT_SIZE)
						local textRowRaid = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", miog.C.TEXT_ROW_FONT_SIZE)
	
						if(rowIndex == 1) then
							textRowMythicPlus:SetPoint("LEFT", textRowFrame, "LEFT")
							textRowRaid:SetPoint("LEFT", textRowFrame, "LEFT")

						else
							textRowMythicPlus.FontString:SetJustifyH("CENTER")
							textRowMythicPlus:SetPoint("LEFT", textRowGeneralInfo, "LEFT")

							textRowRaid.FontString:SetJustifyH("CENTER")
							textRowRaid:SetPoint("LEFT", textRowGeneralInfo, "LEFT")

						end
	
						mythicPlusPanel.rows[rowIndex] = textRowMythicPlus
						raidPanel.rows[rowIndex] = textRowRaid
	
					end
				end

				if(rowIndex > 8) then
					textRowFrame:SetParent(raidPanel)

				end
			end

			generalInfoPanel.rows[1].FontString:SetJustifyV("TOP")
			generalInfoPanel.rows[1].FontString:SetPoint("TOPLEFT", generalInfoPanel.rows[1], "TOPLEFT", 0, -5)
			generalInfoPanel.rows[1].FontString:SetPoint("BOTTOMRIGHT", tabPanel.rows[5], "BOTTOMRIGHT", 0, 0)
			generalInfoPanel.rows[1].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. ((applicantData.comment and applicantData.comment) or ""))
			generalInfoPanel.rows[1].FontString:SetWordWrap(true)
			generalInfoPanel.rows[1].FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)
			
			generalInfoPanel.rows[7].FontString:SetText(_G["LFG_TOOLTIP_ROLES"] .. ((tank == true and miog.C.TANK_TEXTURE) or (healer == true and miog.C.HEALER_TEXTURE) or (damager == true and miog.C.DPS_TEXTURE)))
			generalInfoPanel.rows[9].FontString:SetText(_G["FRIENDS_LIST_REALM"] .. (nameTable[2] or GetRealmName() or ""))

			if(miog.F.LISTED_CATEGORY_ID == 2) then
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
					local difficulty = miog.C.DIFFICULTY[-1] -- NO DATA
					primaryIndicator:SetText(wticc("0", difficulty.color))
					secondaryIndicator:SetText(wticc("0", difficulty.color))

				end

			elseif(miog.F.LISTED_CATEGORY_ID == (4 or 7 or 8 or 9)) then
				primaryIndicator:SetText(wticc(tostring(pvpData.rating), miog.createCustomColorForScore(pvpData.rating):GenerateHexColor()))

				local tierResult = miog.simpleSplit(pvpData.tier, " ")
				secondaryIndicator:SetText(strsub(tierResult[1], 0, 2) .. ((tierResult[2] and "" .. tierResult[2]) or ""))

			end

			if(profile) then
				if(mythicKeystoneProfile and mythicKeystoneProfile.currentScore > 0) then
					
					for rowIndex = 1, #mythicKeystoneProfile.dungeons, 1 do
						if(dungeonProfile) then
							local primaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeons[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeons[rowIndex] or 0
							local primaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeonUpgrades[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeonUpgrades[rowIndex] or 0
							local secondaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeons[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeons[rowIndex] or 0
							local secondaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeonUpgrades[rowIndex] or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeonUpgrades[rowIndex] or 0

							local textureString = miog.DUNGEON_ICONS[dungeonProfile[rowIndex].dungeon.instance_map_id]

							--local dungeonIconFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", mythicPlusPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2, "Texture", textureString)
							local dungeonIconFrame = miog.createBasicTexture("fleeting", textureString, mythicPlusPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2)
							dungeonIconFrame:SetPoint("LEFT", tabPanel.rows[rowIndex], "LEFT")
							dungeonIconFrame:SetMouseClickEnabled(true)
							dungeonIconFrame:SetDrawLayer("OVERLAY")
							--dungeonIconFrame:SetFrameStrata("DIALOG")
							dungeonIconFrame:SetScript("OnMouseDown", function()
								local instanceID = C_EncounterJournal.GetInstanceForGameMap(dungeonProfile[rowIndex].dungeon.instance_map_id)

								--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
								EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)
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
							mythicPlusPanel.rows[6].FontString:SetText(wticc("Main: " .. (mythicKeystoneProfile.mainCurrentScore), miog.createCustomColorForScore(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor()))
						else
							mythicPlusPanel.rows[6].FontString:SetText(wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex))
						end
					else
						mythicPlusPanel.rows[6].FontString:SetText(wticc("Main Score N/A", miog.ITEM_QUALITY_COLORS[6].pureHex))
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

					local progressFrame
					local mainProgressText = ""
					local halfRowWidth = raidPanel.rows[1]:GetWidth() * 0.5

					local raidIndex = 0

					raidPanel.textureRows = {}

					for progressIndex, sortedProgress in ipairs(raidProfile.sortedProgress) do
						if(sortedProgress.isMainProgress ~= true) then
							local currentOrdinal = sortedProgress.progress.raid.ordinal
							local progressCount = sortedProgress.progress.progressCount
							local currentDifficulty = sortedProgress.progress.difficulty
							local difficultyData = miog.C.DIFFICULTY[currentDifficulty]
							local bossCount = sortedProgress.progress.raid.bossCount
							local panelProgressString = wticc(difficultyData.shortName .. ":" .. progressCount .. "/" .. bossCount, difficultyData.color)
							local basicProgressString = wticc(progressCount .. "/" .. bossCount, currentOrdinal == 1 and difficultyData.color or difficultyData.desaturated)

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

								lowerDifficultyNumber = nil
							
								local raidColumn = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, halfRowWidth, raidPanel:GetHeight())
								raidColumn:SetPoint("TOPLEFT", lastColumn or raidPanel, lastColumn and "TOPRIGHT" or "TOPLEFT")
								lastColumn = raidColumn

								local raidIconFrame = miog.createBasicTexture("fleeting", textureString, raidPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2)
								--local raidIconFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT, "Texture", textureString)
								raidIconFrame:SetPoint("TOPLEFT", raidColumn, "TOPLEFT", 0, 0)
								raidIconFrame:SetMouseClickEnabled(true)
								--raidIconFrame:SetFrameStrata("DIALOG")
								raidIconFrame:SetDrawLayer("OVERLAY")
								raidIconFrame:SetScript("OnMouseDown", function()
									--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
									EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, nil, nil, nil, nil)

								end)

								local raidNameString = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE, raidPanel)
								raidNameString:SetPoint("LEFT", raidIconFrame, "RIGHT", 2, 0)
								raidNameString:SetText(raidShortName .. ":")

								higherDifficultyNumber = sortedProgress.progress.difficulty

								
								progressFrame = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE,  raidPanel, raidColumn:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT)
								progressFrame:SetText(panelProgressString)
								progressFrame:SetPoint("TOPLEFT", raidIconFrame, "BOTTOMLEFT")

								--[[currentHigherDifficultyFrame = miog.createBasicFontString("fleeting", miog.C.TEXT_ROW_FONT_SIZE,  raidPanel, raidColumn:GetWidth()*0.48, miog.C.APPLICANT_MEMBER_HEIGHT)
								currentHigherDifficultyFrame:SetText(panelProgressString)
								currentHigherDifficultyFrame:SetPoint("TOPLEFT", raidIconFrame, "BOTTOMLEFT")]]


								for i = 1, ceil(bossCount * 0.5), 1 do
									local currentBossRow = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, halfRowWidth, miog.C.APPLICANT_MEMBER_HEIGHT * 1.4)
									currentBossRow:SetPoint("TOPLEFT", raidPanel.textureRows[raidIndex-1] and raidPanel.textureRows[raidIndex-1][i] or raidPanel.textureRows[raidIndex][i-1] or tabPanel.rows[i+2], raidPanel.textureRows[raidIndex-1] and "TOPRIGHT" or raidPanel.textureRows[raidIndex][i-1] and "BOTTOMLEFT" or "TOPLEFT")
									raidPanel.textureRows[raidIndex][i] = currentBossRow
									raidPanel.textureRows[raidIndex][i].bossFrames = {}

								end

								for i = 1, bossCount, 1 do
									local currentRow = ceil(i * 0.5)

									local index = #raidPanel.textureRows[raidIndex][currentRow].bossFrames + 1

									local bossFrameWH = raidPanel.textureRows[raidIndex][currentRow]:GetHeight() - 2
									
									local bossFrame = miog.createBasicFrame("fleeting", "BackdropTemplate", raidPanel, bossFrameWH, bossFrameWH)
									bossFrame:SetPoint("TOPLEFT", index == 2 and raidPanel.textureRows[raidIndex][currentRow].bossFrames[index-1] or raidPanel.textureRows[raidIndex][currentRow], index == 2 and "TOPRIGHT" or "TOPLEFT", index == 2 and 2 or 0, 0)
									
									bossFrame:SetFrameStrata("DIALOG")
		
									local bossFrameTexture = miog.createBasicTexture("fleeting", miog.RAID_ICONS[sortedProgress.progress.raid.mapId][i], bossFrame, bossFrameWH - 2, bossFrameWH - 2)
									bossFrameTexture:SetDrawLayer("ARTWORK")
									bossFrameTexture:SetPoint("TOPLEFT", bossFrame, "TOPLEFT", 1, -1)
									bossFrameTexture:SetMouseClickEnabled(true)
									bossFrameTexture:SetScript("OnMouseDown", function()
										
										--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
										EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, select(3, EJ_GetEncounterInfoByIndex(i, instanceID)), nil, nil, nil)
		
									end)

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

									progressFrame:SetText(progressFrame:GetText() .. " " .. panelProgressString)

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
						
						if(progressIndex == 4) then
							--break
						end
					end

					if(mainProgressText ~= "") then
						raidPanel.rows[6].FontString:SetText(wticc("Main: " .. mainProgressText, miog.ITEM_QUALITY_COLORS[6].pureHex))

					else
						raidPanel.rows[6].FontString:SetText(wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex))
						
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

		end

		applicantFrame:MarkDirty()
		lastApplicantFrame = applicantFrame
		applicantSystem.applicantMember[applicantID].status = "fullyAdded"

	end

	--updateApplicantStatus(applicantID, "debug")
	
end

miog.checkApplicantList = function(needRefresh)
	if(needRefresh == true) then
		refreshFunction()

	end

	local unsortedMainApplicantsList = {}

	local currentApplicants = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicants() or C_LFGList:GetApplicants()

	for _, applicantID in pairs(currentApplicants) do

		if(applicantSystem.applicantMember[applicantID]) then
			if(applicantSystem.applicantMember[applicantID].saveData == nil) then
				local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

				if(applicantData and applicantData.applicationStatus == "applied" and applicantData.displayOrderID > 0) then

					local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, factionGroup, raceID, specID, bestDungeonScoreForListing, pvpRatingInfo
					
					if(miog.F.IS_IN_DEBUG_MODE) then
						name, _, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo = miog.debug_GetApplicantMemberInfo(applicantID, 1)
					else
						name, _, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID = C_LFGList.GetApplicantMemberInfo(applicantID, 1)
					end

					local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityID or 0
					local profile, primarySortAttribute, secondarySortAttribute

					if(miog.F.IS_RAIDERIO_LOADED) then
						local nameTable = miog.simpleSplit(name, "-")
						profile = getRioProfile(nameTable[1], nameTable[2], miog.C.CURRENT_REGION)

					end

					if(miog.F.LISTED_CATEGORY_ID ~= (3 or 4 or 7 or 8 or 9)) then
						primarySortAttribute = dungeonScore
						secondarySortAttribute = miog.F.IS_IN_DEBUG_MODE and bestDungeonScoreForListing.bestRunLevel or C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activityID).bestRunLevel

					elseif(miog.F.LISTED_CATEGORY_ID == 3) then
						local raidData = {}

						if(profile) then
							if(profile.raidProfile) then
								local lastDifficulty = nil
								local lastOrdinal = nil

								for i = 1, #profile.raidProfile.sortedProgress, 1 do
									if(profile.raidProfile.sortedProgress[i] and profile.raidProfile.sortedProgress[i].progress.raid.ordinal and not profile.raidProfile.sortedProgress[i].isMainProgress) then
										if(profile.raidProfile.sortedProgress[i].progress.raid.ordinal ~= lastOrdinal or profile.raidProfile.sortedProgress[i].progress.difficulty ~= lastDifficulty) then
											local bossCount = profile.raidProfile.sortedProgress[i].progress.raid.bossCount
											local kills = profile.raidProfile.sortedProgress[i].progress.progressCount or 0

											raidData[#raidData+1] = {
												ordinal = profile.raidProfile.sortedProgress[i].progress.raid.ordinal,
												difficulty = profile.raidProfile.sortedProgress[i].progress.difficulty,
												progress = kills,
												bossCount = bossCount,
												parsedString = kills .. "/" .. bossCount,
												weight = kills / bossCount + miog.WEIGHTS_TABLE[profile.raidProfile.sortedProgress[i].progress.raid.ordinal][profile.raidProfile.sortedProgress[i].progress.difficulty]
											}

											if(#raidData == 2) then
												break
											end
										end

										lastOrdinal = raidData[i] and raidData[i].ordinal
										lastDifficulty = raidData[i] and raidData[i].difficulty
									end
								end
							end
						end

						for i = 1, 2, 1 do
							if(not raidData[i]) then
								raidData[i] = {
									ordinal = 0,
									difficulty = -1,
									progress = 0,
									bossCount = 0,
									parsedString = "0/0",
									weight = 0
								}
							end
						end

						primarySortAttribute = raidData[1].weight
						secondarySortAttribute = raidData[2].weight

					elseif(miog.F.LISTED_CATEGORY_ID == (4 or 7 or 8 or 9)) then
						if(not miog.F.IS_IN_DEBUG_MODE) then
							pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activityID)

						end

						primarySortAttribute = pvpRatingInfo.rating
						secondarySortAttribute = pvpRatingInfo.rating

					end

					applicantSystem.applicantMember[applicantID].saveData = {
						name = name,
						index = applicantID,
						role = assignedRole,
						primary = primarySortAttribute,
						secondary = secondarySortAttribute,
						ilvl = itemLevel
					}

				end

			else
				--print("FOUND DATA FOR STUFFS")

			end

			if(applicantSystem.applicantMember[applicantID].activeFrame == nil) then
				unsortedMainApplicantsList[#unsortedMainApplicantsList+1] = applicantSystem.applicantMember[applicantID].saveData

			end
		end
	end

	if(unsortedMainApplicantsList[1]) then
		table.sort(unsortedMainApplicantsList, sortApplicantList)

		for _, listEntry in ipairs(unsortedMainApplicantsList) do
									
			if(listEntry.role == "TANK") then
				miog.F.APPLIED_NUM_OF_TANKS = miog.F.APPLIED_NUM_OF_TANKS + 1

			elseif(listEntry.role == "HEALER") then
				miog.F.APPLIED_NUM_OF_HEALERS = miog.F.APPLIED_NUM_OF_HEALERS + 1

			elseif(listEntry.role == "DAMAGER") then
				miog.F.APPLIED_NUM_OF_DPS = miog.F.APPLIED_NUM_OF_DPS + 1

			end

			if(listEntry.role == "TANK" and miog.F.SHOW_TANKS or listEntry.role == "HEALER" and miog.F.SHOW_HEALERS or listEntry.role == "DAMAGER" and miog.F.SHOW_DPS) then
				applicantSystem.applicantMember[listEntry.index].status = "inProgress"
				addApplicantToPanel(listEntry.index)
			end
		end

		miog.mainFrame.buttonPanel.RoleTextures[1].text:SetText(miog.F.APPLIED_NUM_OF_TANKS)
		miog.mainFrame.buttonPanel.RoleTextures[2].text:SetText(miog.F.APPLIED_NUM_OF_HEALERS)
		miog.mainFrame.buttonPanel.RoleTextures[3].text:SetText(miog.F.APPLIED_NUM_OF_DPS)

	end
end

local function createFullEntries(iterations)
	refreshFunction()
	resetArrays()
	
	local numbers = {}
	for i = 1, #miog.DEBUG_RAIDER_IO_PROFILES do
		numbers[i] = i
	end
	miog.shuffleNumberTable(numbers)

	for index = 1, iterations, 1 do
		local applicantID = random(1000, 9999)

		miog.DEBUG_APPLICANT_DATA[applicantID] = {
			applicantID = applicantID,
			applicationStatus = "applied",
			numMembers = 1,
			isNew = true,
			comment = "Heiho, heiho, wir sind vergnügt und froh. Johei, johei, die Arbeit ist vorbei.",
			displayOrderID = 1,
		}

		applicantSystem.applicantMember[applicantID] = {
			activeFrame = nil,
			saveData = nil,
			status = "dataAvailable",
		}

		miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID] = {}

		for memberIndex = 1, miog.DEBUG_APPLICANT_DATA[applicantID].numMembers, 1 do
			local rating = random(1, 4000)
			rating = 0

			local debugProfile = miog.DEBUG_RAIDER_IO_PROFILES[numbers[index]]
			local rioProfile = RaiderIO.GetProfile(debugProfile[1], debugProfile[2], debugProfile[3])

			local classID = random(1, 13)
			local classInfo = C_CreatureInfo.GetClassInfo(classID) or {"WARLOCK", "Warlock"}
			
			local specID = miog.CLASSES[classID].specs[random(1, #miog.CLASSES[classID].specs)]

			--local specID = miog.CLASSES[classInfo.classFile].specs[random(1, #miog.CLASSES[classInfo.classFile].specs)]

			miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID][memberIndex] = {
				[1] = debugProfile[1] .. "-" .. debugProfile[2],
				[2]  = classInfo.classFile, --ENG
				[3]  = classInfo.className, --GER
				[4]  = UnitLevel("player"),
				[5]  = random(0, 450) + 0.5,
				[6]  = UnitHonorLevel("player"),
				[7]  = false,
				[8]  = false,
				[9]  = true,
				[10]  = select(5, GetSpecializationInfoByID(specID)),
				[11]  = true,
				[12]  = rioProfile and rioProfile.mythicKeystoneProfile and rioProfile.mythicKeystoneProfile.currentScore or 0,
				[13]  = random(400, 450) + 0.5,
				[14]  = "Alliance",
				[15]  = 0,
				[16]  = specID,
				[17]  = {finishedSuccess = true, bestRunLevel = random(20, 35), mapName = "Big Dick Land"},
				[18]  = {bracket = "", rating = rating, activityName = "XD", tier = miog.debugGetTestTier(rating)},
			}
		end

	end

	local startTime = GetTimePreciseSec()
	miog.checkApplicantList(false)
	local endTime = GetTimePreciseSec()

	currentAverageExecuteTime[#currentAverageExecuteTime+1] = endTime - startTime
end

local function updateAddonRoster()
	local inPartyOrRaid = UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "player"
	
	local groupCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
		["NONE"] = 0
	}
	
	miog.releaseRaidRosterPool()

	local indexedGroup = {}
	local classesInGroup = {}
	local index = 1
	local specTable = {}

	for key, groupMember in pairs(groupSystem.groupMember) do
		if(groupMember.dataAvailable == true) then
			local guid = key
			local classID = groupMember.classID
			local role = groupMember.role
			print(role)

			--local unitID1 = groupMember.unitID
			--local name = groupMember.name
			--local specID = groupMember.specID
			--local specIcon = miog.SPECIALIZATIONS[specID].icon

			local unitID = guid == UnitGUID("player") and "player" or inPartyOrRaid .. index

			local unitInPartyOrRaid = UnitInRaid(unitID) or UnitInParty(unitID) or guid == UnitGUID("player") or inPartyOrRaid == "player" and true or false

			if(unitInPartyOrRaid and role ~= "NONE") then
				if(groupCount[role]) then
					groupCount[role] = groupCount[role] + 1
				end

				specTable[groupMember.specID] = specTable[groupMember.specID] and specTable[groupMember.specID] + 1 or 1

				classesInGroup[classID] = classesInGroup[classID] and classesInGroup[classID] + 1 or 1
				indexedGroup[#indexedGroup+1] = groupMember

				--ONLY USED IN PARTY MODE
				indexedGroup[#indexedGroup].unitID = unitID

				if(inPartyOrRaid == "raid" or inPartyOrRaid == "party" and guid ~= UnitGUID("player")) then
					index = index + 1

				end

			else
				--inspectQueueMember = nil

			end
		end
	end

	local counter = 1

	for classID, classEntry in ipairs(miog.CLASSES) do
		if(classesInGroup[classID]) then
			local classFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.classPanel, 25, 25, "Texture", classEntry.icon)
			classFrame:SetPoint("TOP", miog.mainFrame.classPanel.classFrames[counter - 1] or miog.mainFrame.classPanel, miog.mainFrame.classPanel.classFrames[counter - 1] and "BOTTOM" or "TOP", 0, -5)
			classFrame.layoutIndex = counter

			local specPanel = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.classPanel)
			specPanel:Hide()

			local lastSpecFrame = nil

			for _, v in ipairs(classEntry.specs) do
				if(specTable[v]) then
					local specFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", specPanel, 20, 20, "Texture", miog.SPECIALIZATIONS[v].squaredIcon)
					specFrame:SetPoint("RIGHT", lastSpecFrame or classFrame, "LEFT", -5, 0)

					local specFrameFontString = miog.createBasicFontString("raidRoster", 14, specFrame)
					specFrameFontString:SetPoint("CENTER", specFrame, "CENTER", 0, -1)
					specFrameFontString:SetJustifyH("CENTER")
					specFrameFontString:SetText(specTable[v])
					specFrame.FontString = specFrameFontString

					lastSpecFrame = specFrame
				end

			end

			classFrame:SetMouseMotionEnabled(true)
			classFrame:SetScript("OnEnter", function()
				specPanel:Show()

			end)
			classFrame:SetScript("OnLeave", function()
				specPanel:Hide()

			end)

			local classFrameFontString = miog.createBasicFontString("raidRoster", 20, classFrame)
			classFrameFontString:SetPoint("CENTER", classFrame, "CENTER", 0, -1)
			classFrameFontString:SetJustifyH("CENTER")
			classFrameFontString:SetText(classesInGroup[classID])
			classFrame.FontString = classFrameFontString

			local rPerc, gPerc, bPerc = GetClassColor(classEntry.name)
			miog.createFrameBorder(classFrame, 1, rPerc, gPerc, bPerc, 1)
			
			miog.mainFrame.classPanel.classFrames[counter] = classFrame

			counter = counter + 1
		end
	
		miog.mainFrame.classPanel:MarkDirty()
	end

	for i = 1, #miog.CLASSES, 1 do
		if(not classesInGroup[i]) then
			local classFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.classPanel, 25, 25, "Texture", miog.CLASSES[i].icon)
			classFrame:SetPoint("TOP", miog.mainFrame.classPanel.classFrames[counter - 1] or miog.mainFrame.classPanel, miog.mainFrame.classPanel.classFrames[counter - 1] and "BOTTOM" or "TOP", 0, -5)
			classFrame.layoutIndex = counter
			classFrame.Texture:SetDesaturated(true)

			miog.createFrameBorder(classFrame, 1, 0, 0, 0, 1)
			
			miog.mainFrame.classPanel.classFrames[counter] = classFrame

			counter = counter + 1

		end
	
		miog.mainFrame.classPanel:MarkDirty()
	end
	
	miog.mainFrame.classPanel:MarkDirty()

	miog.mainFrame.titleBar.groupMemberListing.FontString:SetText("")

	if(#indexedGroup < 5) then
		if(groupCount["TANK"] < 1) then
			indexedGroup[#indexedGroup + 1] = {guid = "empty", unitID = "empty", name = "afk", classID = 20, role = "TANK", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
		end

		if(groupCount["HEALER"] < 1 and #indexedGroup < 5) then
			indexedGroup[#indexedGroup + 1] = {guid = "empty", unitID = "empty", name = "afk", classID = 21, role = "HEALER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
		end

		for i = 1, 3 - groupCount["DAMAGER"], 1 do
			if(groupCount["DAMAGER"] < 3 and #indexedGroup < 5) then
				indexedGroup[#indexedGroup + 1] = {guid = "empty", unitID = "empty"..i, name = "afk", classID = 22, role = "DAMAGER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			end
		end
	end

	table.sort(indexedGroup, function(a, b)
		if a.role ~= b.role then
			return b.role < a.role
		end
		
		return a.classID < b.classID
	end)

	local lastIcon

	if(miog.F.NUM_OF_GROUP_MEMBERS < 6) then
		lastIcon = nil

		for _, groupMember in ipairs(indexedGroup) do
			local specIcon = groupMember.icon or miog.SPECIALIZATIONS[groupMember.specID].squaredIcon
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.titleBar.groupMemberListing, miog.mainFrame.titleBar.factionIconSize - 2, miog.mainFrame.titleBar.factionIconSize - 2, "Texture", specIcon)
			classIconFrame:SetPoint("LEFT", lastIcon or miog.mainFrame.titleBar.groupMemberListing, lastIcon and "RIGHT" or "LEFT")
			classIconFrame:SetFrameStrata("DIALOG")

			lastIcon = classIconFrame

		end
	else
		miog.mainFrame.titleBar.groupMemberListing.FontString:SetText(groupCount["TANK"] .. "/" .. groupCount["HEALER"] .. "/" .. groupCount["DAMAGER"])

	end
	
	if(miog.F.IS_IN_DEBUG_MODE) then
		lastIcon = nil
		for _, groupMember in ipairs(indexedGroup) do
			local specIcon = groupMember.icon or miog.SPECIALIZATIONS[groupMember.specID].icon
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", WorldFrame, miog.mainFrame.titleBar.factionIconSize - 2, miog.mainFrame.titleBar.factionIconSize - 2, "Texture", specIcon)
			classIconFrame:SetPoint("TOPLEFT", lastIcon or WorldFrame, lastIcon and "TOPRIGHT" or "TOPLEFT")
			classIconFrame:SetFrameStrata("DIALOG")

			lastIcon = classIconFrame
		end
	end

	miog.mainFrame.titleBar.groupMemberListing:MarkDirty()

	print("ROSTER UPDATED")

end

--[[local function updateRoster()
	miog.F.CURRENT_GROUP_INFO = {}

	local inPartyOrRaid = UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "player"

	local groupCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
		["NONE"] = 0
	}

	miog.releaseRaidRosterPool()

	local index = 1
	local classesInGroup = {}

	for key, inspectQueueMember in pairs(miog.F.INSPECT_QUEUE) do
		local guid = key

		---@diagnostic disable-next-line: unbalanced-assignments
		local class, classID = inspectQueueMember[5] or UnitClassBase(inspectQueueMember[2])

		if(classID == nil) then
			classID = select(2, UnitClassBase(inspectQueueMember[2]))

		end

		local name = inspectQueueMember[4]
		local specID = inspectQueueMember[3]
		local _, _, _, icon, backupRole = GetSpecializationInfoByID(specID)
		local specIcon

		if(specID ~= nil and specID ~= 0) then
			specIcon = miog.SPECIALIZATIONS[specID].icon
		end

		local role = inspectQueueMember[6] or backupRole or "NONE"

		local unitID = guid == UnitGUID("player") and "player" or inPartyOrRaid .. index

		local unitInPartyOrRaid = UnitInRaid(unitID) or UnitInParty(unitID) or guid == UnitGUID("player") or inPartyOrRaid == "player" and true or false

		if(unitInPartyOrRaid and inspectQueueMember[1] == true) then

			inspectQueueMember[1] = true
			groupCount[role] = groupCount[role] + 1

			classesInGroup[classID] = classesInGroup[classID] and classesInGroup[classID] + 1 or 1

			miog.F.CURRENT_GROUP_INFO[#miog.F.CURRENT_GROUP_INFO + 1] = {guid = guid, unitID = unitID, name = name, class = class, role = role, specIcon = specIcon or icon or miog.CLASSES[classID].icon}

			if(inPartyOrRaid == "raid" or inPartyOrRaid == "party" and guid ~= UnitGUID("player")) then
				index = index + 1

			end

		else
			inspectQueueMember = nil

		end
	end

	--DevTools_Dump(classesInGroup)

	local counter = 1

	for i = 1, #miog.CLASSES, 1 do
		if(classesInGroup[i]) then
			local classFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.classPanel, 25, 25, "Texture", miog.CLASSES[i].icon)
			classFrame:SetPoint("TOP", miog.mainFrame.classPanel.classFrames[counter - 1] or miog.mainFrame.classPanel, miog.mainFrame.classPanel.classFrames[counter - 1] and "BOTTOM" or "TOP", 0, -5)
			classFrame.layoutIndex = counter

			local classFrameFontString = miog.createBasicFontString("persistent", 20, classFrame)
			classFrameFontString:SetPoint("CENTER", classFrame, "CENTER", 0, -1)
			classFrameFontString:SetJustifyH("CENTER")
			classFrameFontString:SetText(classesInGroup[i])

			classFrame.FontString = classFrameFontString

			local rPerc, gPerc, bPerc = GetClassColor(miog.CLASSES[i].name)
			miog.createFrameBorder(classFrame, 2, rPerc, gPerc, bPerc, 1)
			
			miog.mainFrame.classPanel.classFrames[counter] = classFrame

			counter = counter + 1
		end
	end
	
	miog.mainFrame.classPanel:MarkDirty()


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
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.titleBar.groupMemberListing, miog.mainFrame.titleBar.factionIconSize - 2, miog.mainFrame.titleBar.factionIconSize - 2, "Texture", groupMember.specIcon)
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
	
end]]


local function checkIfCanInvite()
	if(UnitIsGroupLeader("player")) then
		miog.mainFrame.footerBar:Show()
		miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame.footerBar, "TOPRIGHT", 0, 0)

	else
		miog.mainFrame.footerBar:Hide()
		miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)

	end
end

local inspectRoutine
local rosterUpdate = false

local function getInspectDataForGroup()
	rosterUpdate = false

	local inPartyOrRaid = UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "player"

	local unitID, name, classID, specID, guid

	for groupIndex = 1, miog.F.NUM_OF_GROUP_MEMBERS, 1 do
		unitID = inPartyOrRaid..groupIndex == "party"..miog.F.NUM_OF_GROUP_MEMBERS and "player" or inPartyOrRaid..groupIndex
		guid = UnitGUID(unitID) or ""

		if(not groupSystem.groupMember[guid]) then
			name = UnitName(unitID)
			classID = select(2, UnitClassBase(unitID))

			groupSystem.groupMember[guid] = {
				dataAvailable = false,
				unitID = unitID,
				name = name,
				classID = classID
			}

			if(CanInspect(unitID) and UnitIsConnected(unitID)) then
				miog.F.CURRENTLY_INSPECTING = true
				print("NOTIFY FOR "..name)
				NotifyInspect(unitID)
				coroutine.yield(inspectRoutine)
				
				groupSystem.groupMember[guid].dataAvailable = true
				groupSystem.groupMember[guid].specID = GetInspectSpecialization(unitID)
				groupSystem.groupMember[guid].role = unitID == "player" and (GetSpecializationRoleByID(groupSystem.groupMember[guid].specID)) or select(5, GetSpecializationInfoByID(groupSystem.groupMember[guid].specID))
				
				print(name .. " DONE")
			else
				-- CAN'T INSPECT, EITHER DISTANCE, WEIRD HORDE/ALLIANCE STUFF OR OFFLINE
			end
		end

		updateAddonRoster()
	end

	if(rosterUpdate) then
		if(miog.F.NUM_OF_GROUP_MEMBERS > 0) then
			inspectRoutine = coroutine.create(getInspectDataForGroup)
			print(coroutine.resume(inspectRoutine))
		end

	else
		miog.F.CURRENTLY_INSPECTING = false
		print("DONE")
	end
end

local lastInspectTime = 0

miog.OnEvent = function(_, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		inspectRoutine = coroutine.create(getInspectDataForGroup)

		miog.releaseAllFleetingWidgets()
		miog.loadSettings()
		miog.F.NUM_OF_GROUP_MEMBERS = GetNumGroupMembers()
		
		--miog.F.INSPECT_QUEUE = {}

		--requestInspectDataFromFullGroup()

		if(miog.F.NUM_OF_GROUP_MEMBERS > 0) then
			print(coroutine.resume(inspectRoutine))
		end

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
		miog.F.ACTIVE_ENTRY_INFO = C_LFGList.GetActiveEntryInfo()
		local activityInfo

		if(C_LFGList.HasActiveEntryInfo() == true) then
			activityInfo = C_LFGList.GetActivityInfoTable(miog.F.ACTIVE_ENTRY_INFO.activityID)

			miog.F.LISTED_CATEGORY_ID = activityInfo.categoryID

			miog.mainFrame.buttonPanel.sortByCategoryButtons.secondary:Enable()

			if(activityInfo.categoryID == 2) then --Dungeons
				miog.F.CURRENT_DUNGEON_DIFFICULTY = miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DUNGEON_DIFFICULTY
				miog.mainFrame.infoPanel.affixFrame:Show()

			elseif(activityInfo.categoryID == 3) then --Raids
				miog.F.CURRENT_RAID_DIFFICULTY = miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULT_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_RAID_DIFFICULTY
				miog.mainFrame.infoPanel.affixFrame:Hide()
			end

			miog.mainFrame.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] or miog.BACKGROUNDS[activityInfo.categoryID]
			miog.mainFrame.infoPanelBackdropFrame:ApplyBackdrop()

			miog.mainFrame.titleBar.titleStringFrame.FontString:SetText(miog.F.ACTIVE_ENTRY_INFO.name)
			miog.mainFrame.infoPanel.activityNameFrame:SetText(activityInfo.fullName)

			miog.mainFrame.listingSettingPanel.privateGroupFrame.active = miog.F.ACTIVE_ENTRY_INFO.privateGroup
			miog.mainFrame.listingSettingPanel.privateGroupFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. (miog.F.ACTIVE_ENTRY_INFO.privateGroup and "/infoIcons/questionMark_Yellow.png" or "/infoIcons/questionMark_Grey.png"))

			if(miog.F.ACTIVE_ENTRY_INFO.playstyle) then
				local playStyleString = (activityInfo.isMythicPlusActivity and miog.PLAYSTYLE_STRINGS["mPlus"..miog.F.ACTIVE_ENTRY_INFO.playstyle]) or
				(activityInfo.isMythicActivity and miog.PLAYSTYLE_STRINGS["mZero"..miog.F.ACTIVE_ENTRY_INFO.playstyle]) or
				(activityInfo.isCurrentRaidActivity and miog.PLAYSTYLE_STRINGS["raid"..miog.F.ACTIVE_ENTRY_INFO.playstyle]) or
				((activityInfo.isRatedPvpActivity or activityInfo.isPvpActivity) and miog.PLAYSTYLE_STRINGS["pvp"..miog.F.ACTIVE_ENTRY_INFO.playstyle])

				miog.mainFrame.listingSettingPanel.playstyleFrame.tooltipText = playStyleString

			else
				miog.mainFrame.listingSettingPanel.playstyleFrame.tooltipText = ""
			
			end

			if(miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore and activityInfo.categoryID == 2 or miog.F.ACTIVE_ENTRY_INFO.requiredPvpRating and activityInfo.categoryID == (4 or 7 or 8 or 9)) then
				miog.mainFrame.listingSettingPanel.ratingFrame.tooltipText = "Required rating: " .. miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or miog.F.ACTIVE_ENTRY_INFO.requiredPvpRating
				miog.mainFrame.listingSettingPanel.ratingFrame.FontString:SetText(miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or miog.F.ACTIVE_ENTRY_INFO.requiredPvpRating)

				miog.mainFrame.listingSettingPanel.ratingFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. (miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore and "/infoIcons/skull.png" or miog.F.ACTIVE_ENTRY_INFO.requiredPvpRating and "/infoIcons/spear.png"))

			else
				miog.mainFrame.listingSettingPanel.ratingFrame.FontString:SetText("----")
				miog.mainFrame.listingSettingPanel.ratingFrame.tooltipText = ""
			
			end

			if(miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel > 0) then
				miog.mainFrame.listingSettingPanel.itemLevelFrame.FontString:SetText(miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel)
				miog.mainFrame.listingSettingPanel.itemLevelFrame.tooltipText = "Required itemlevel: " .. miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel

			else
				miog.mainFrame.listingSettingPanel.itemLevelFrame.FontString:SetText("---")
				miog.mainFrame.listingSettingPanel.itemLevelFrame.tooltipText = ""

			end

			if(miog.F.ACTIVE_ENTRY_INFO.voiceChat ~= "") then
				LFGListFrame.EntryCreation.VoiceChat.CheckButton:SetChecked(true)

			end

			if(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked()) then

				miog.mainFrame.listingSettingPanel.voiceChatFrame.tooltipText = miog.F.ACTIVE_ENTRY_INFO.voiceChat
				miog.mainFrame.listingSettingPanel.voiceChatFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOn.png")
			else
				
				miog.mainFrame.listingSettingPanel.voiceChatFrame.tooltipText = ""
				miog.mainFrame.listingSettingPanel.voiceChatFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOff.png")

			end
			
			if(miog.F.ACTIVE_ENTRY_INFO.isCrossFactionListing == true) then
				miog.mainFrame.titleBar.factionFrame.Texture:SetTexture(2437241)

			else
				local playerFaction = UnitFactionGroup("player")
				miog.mainFrame.titleBar.factionFrame.Texture:SetTexture(playerFaction == "Alliance" and 2173919 or playerFaction == "Horde" and 2173920)

			end
			
			if(miog.F.ACTIVE_ENTRY_INFO.comment ~= "") then

				miog.mainFrame.infoPanel.commentFrame.FontString:SetHeight(2500)
				miog.mainFrame.infoPanel.commentFrame.FontString:SetText("Description: " .. miog.F.ACTIVE_ENTRY_INFO.comment)
				miog.mainFrame.infoPanel.commentFrame.FontString:SetHeight(miog.mainFrame.infoPanel.commentFrame.FontString:GetStringHeight())
				miog.mainFrame.infoPanel.commentFrame:SetHeight(miog.mainFrame.infoPanel.commentFrame.FontString:GetStringHeight())

			end
			
			miog.mainFrame.listingSettingPanel:MarkDirty()
		end

		if(... == nil) then
			if not(miog.F.ACTIVE_ENTRY_INFO) then
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
			miog.checkApplicantList(true)

			if(... == true) then --NEW LISTING
				MIOG_QueueUpTime = GetTimePreciseSec()
				expandedFrameList = {}
				miog.F.CURRENTLY_INSPECTING = false
				miog.F.CURRENT_GROUP_INFO = {}

			elseif(... == false) then --RELOAD OR SETTINGS EDIT
				MIOG_QueueUpTime = (MIOG_QueueUpTime and MIOG_QueueUpTime > 0) and MIOG_QueueUpTime or GetTimePreciseSec()

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
			if(applicantData.applicationStatus == "applied") then
				if(applicantData.displayOrderID > 0) then --APPLICANT WITH DATA
					if(applicantData.pendingApplicationStatus == nil) then--NEW APPLICANT WITH DATA 
						--print(... .. " APPLICANT NEW")
						--print("NEW")
						--miog.checkApplicantList(C_PartyInfo.CanInvite())

						applicantSystem.applicantMember[...] = {
							activeFrame = nil,
							saveData = nil,
							status = "dataAvailable",
						}
						
						miog.checkApplicantList(false)

					elseif(applicantData.pendingApplicationStatus == "declined") then
						--print(... .. " APPLICANT DECLINE - CLICKED")
						applicantSystem.applicantMember[...].activeFrame = nil

					else
						--print(... .. " APPLICANT IDK" .. applicantData.pendingApplicationStatus)

					end

				elseif(applicantData.displayOrderID == 0) then
					applicantSystem.applicantMember[...] = {
						activeFrame = nil,
						saveData = nil,
						status = "noDataAvailable",
					}

				end
			else --STATUS TRIGGERED BY APPLICANT
				--print(... .. " UPDATE STATUS" .. applicantData.applicationStatus)
				--INVITED, TIMED OUT, FAILED, ETC
				--print("APP DECLINE")
				updateApplicantStatus(..., applicantData.applicationStatus)
					
			end
		else
			--print(... .. " NO DATA")
		
		end

	elseif(event == "LFG_LIST_APPLICANT_LIST_UPDATED") then --ALL THE APPLICANTS

		local newEntry, withData = ...

		--if(newEntry == true and withData == false) then --NEW APPLICANT WITHOUT DATA

		--if(newEntry == true and withData == true) then --NEW APPLICANT WITH DATA
			--miog.checkApplicantList(false)

		if(newEntry == false and withData == false) then --DECLINED APPLICANT
			--print("MAJOR DECLINE")
			miog.checkApplicantList(true)

		elseif(not newEntry and not withData) then --REFRESH APP LIST
			--print("REFRESH")
			--print("MAJOR REFRESH")
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
		--miog.F.INSPECT_QUEUE = {}

		checkIfCanInvite()

	elseif(event == "GROUP_LEFT") then
		--miog.F.INSPECT_QUEUE = {}
		
		miog.F.NUM_OF_GROUP_MEMBERS = GetNumGroupMembers()

		--requestInspectDataFromFullGroup()
		--updateRoster()

	elseif(event == "PARTY_LEADER_CHANGED") then
		checkIfCanInvite()

	elseif(event == "GROUP_ROSTER_UPDATE") then
		rosterUpdate = true

		checkIfCanInvite()

		miog.F.NUM_OF_GROUP_MEMBERS = GetNumGroupMembers()

		--requestInspectDataFromFullGroup()

		if(coroutine.status(inspectRoutine) == "dead") then
			inspectRoutine = coroutine.create(getInspectDataForGroup)

		elseif(coroutine.status(inspectRoutine) == "suspended") then
			--coroutine.resume(inspectRoutine)

		else
		
		end
	
		if(not miog.F.CURRENTLY_INSPECTING) then
			print(coroutine.resume(inspectRoutine))
		end

	elseif(event == "INSPECT_READY") then
		print("INSPECT DATA READY FOR", ...)

		groupSystem.groupMember[...].dataAvailable = true
		ClearInspectPlayer()

		if(miog.F.NUM_OF_GROUP_MEMBERS < 6) then
			print(coroutine.resume(inspectRoutine))

		else
			--[[local delay = GetTimePreciseSec() - lastInspectTime
			print(delay)
			C_Timer.After(delay > 2 and 0 or 2, function() coroutine.resume(inspectRoutine) end)

			]]

			local delay = GetTimePreciseSec() - lastInspectTime

			print("LAST: "..delay)

			C_Timer.After(delay >= 1.5 and 1.5 or ((1.5 - delay) < 0 and 0 or 1.5 - delay), function() print(coroutine.resume(inspectRoutine)) end)

			lastInspectTime = GetTimePreciseSec()
		end

		--[[if(miog.F.INSPECT_QUEUE[...]) then
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
		end]]
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

	elseif(command == "debugon") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")


	elseif(command == "debugoff") then
		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false
		refreshFunction()
		resetArrays()
	
	elseif(command == "perfstart") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

		local index = 1
		local tickRate = 0.2
		local numberOfEntries = 33
		local testLength = (tonumber(rest) or 10) / tickRate -- in seconds

		currentAverageExecuteTime = {}

		debugTimer = C_Timer.NewTicker(tickRate, function(self)

			createFullEntries(numberOfEntries)

			print(currentAverageExecuteTime[#currentAverageExecuteTime])

			index = index + 1

			if(index == testLength) then
				self:Cancel()

				local avg = 0
				
				for _, v in ipairs(currentAverageExecuteTime) do
					avg = avg + v
				end
				
				print("Avg exec time: "..(avg / #currentAverageExecuteTime))
				
				print("Debug mode off - Normal applicant mode")
				miog.F.IS_IN_DEBUG_MODE = false
				refreshFunction()
				resetArrays()
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
		resetArrays()

	else
		miog.mainFrame:Show()

	end
end
SlashCmdList["MIOG"] = handler