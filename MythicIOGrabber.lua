local addonName, miog = ...

local expandedFrameList = {}

local groupSystem = {}
groupSystem.groupMember = {}
groupSystem.inspectedGUIDs = {}

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

local function fullRelease()
	for _,v in pairs(applicantSystem.applicantMember) do
		if(v.frame) then
			v.frame.fontStringPool:ReleaseAll()
			v.frame.texturePool:ReleaseAll()
			v.frame.framePool:ReleaseAll()

		end
	end

	applicantSystem.applicantMember = {}

	miog.fleetingFramePool:ReleaseAll()

	miog.mainFrame.footerBar.applicantNumberFontString:SetText(0)
	miog.mainFrame.applicantPanel.container:MarkDirty()

end

local function hideAllFrames()
	for _, v in pairs(applicantSystem.applicantMember) do
		if(v.frame) then
			v.frame:Hide()
			v.frame.layoutIndex = nil

		end
	end

	miog.mainFrame.footerBar.applicantNumberFontString:SetText(0)
	miog.mainFrame.applicantPanel.container:MarkDirty()

end

local function updateApplicantStatusFrame(applicantID, applicantStatus)
	local currentApplicant = applicantSystem.applicantMember[applicantID]

	if(currentApplicant and currentApplicant.frame and currentApplicant.frame.memberFrames) then
		for _, memberFrame in pairs(currentApplicant.frame.memberFrames) do
			memberFrame.statusFrame:Show()
			memberFrame.statusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[applicantStatus].statusString, miog.APPLICANT_STATUS_INFO[applicantStatus].color))

			if(memberFrame.basicInformationPanel.inviteButton) then
				memberFrame.basicInformationPanel.inviteButton:Disable()

			end
		end

		if(applicantStatus == "invited") then
			currentApplicant.status = "pendingInvite"

		elseif(C_PartyInfo.CanInvite() and (applicantStatus == "inviteaccepted" or applicantStatus == "debug")) then
			miog.addLastInvitedApplicant(currentApplicant)

		else
			currentApplicant.status = "removable"

		end
	end
end

local function sortApplicantList(applicant1, applicant2)

	for key, tableElement in pairs(miog.F.SORT_METHODS) do
		if(tableElement.currentLayer == 1) then
			local firstState = miog.mainFrame.buttonPanel.sortByCategoryButtons[key]:GetActiveState()

			for innerKey, innerTableElement in pairs(miog.F.SORT_METHODS) do

				if(innerTableElement.currentLayer == 2) then
					local secondState = miog.mainFrame.buttonPanel.sortByCategoryButtons[innerKey]:GetActiveState()

					if(applicant1.preferred and not applicant2.preferred) then
						return true
				
					elseif(not applicant1.preferred and applicant2.preferred) then
						return false
				
					else
						if(applicant1[key] == applicant2[key]) then
							return secondState == 1 and applicant1[innerKey] > applicant2[innerKey] or secondState == 2 and applicant1[innerKey] < applicant2[innerKey]

						elseif(applicant1[key] ~= applicant2[key]) then
							return firstState == 1 and applicant1[key] > applicant2[key] or firstState == 2 and applicant1[key] < applicant2[key]

						end
					end
				end

			end

			if(applicant1.preferred and not applicant2.preferred) then
				return true
		
			elseif(not applicant1.preferred and applicant2.preferred) then
				return false
		
			else
				if(applicant1[key] == applicant2[key]) then
					return firstState == 1 and applicant1.index > applicant2.index or firstState == 2 and applicant1.index < applicant2.index

				elseif(applicant1[key] ~= applicant2[key]) then
					return firstState == 1 and applicant1[key] > applicant2[key] or firstState == 2 and applicant1[key] < applicant2[key]

				end
			end

		end

	end

	if(applicant1.preferred and not applicant2.preferred) then
		return true

	elseif(not applicant1.preferred and applicant2.preferred) then
		return false

	else
		return applicant1.index < applicant2.index

	end

end

local layoutIndex = 0

local function createApplicantFrame(applicantID)

	local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

	if(applicantData) then
		local activityID = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.activityID or 0

		expandedFrameList[applicantID] = expandedFrameList[applicantID] or {}

		local applicantFrame = miog.createBasicFrame("fleeting", "ResizeLayoutFrame, BackdropTemplate", miog.mainFrame.applicantPanel.container)
		applicantFrame.fixedWidth = miog.C.MAIN_WIDTH - 2
		applicantFrame.heightPadding = 1
		applicantFrame.minimumHeight = applicantData.numMembers * (miog.C.APPLICANT_MEMBER_HEIGHT + miog.C.APPLICANT_PADDING)
		applicantFrame.memberFrames = {}

		applicantFrame.framePool = applicantFrame.framePool or CreateFramePoolCollection()
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("EditBox", nil, "InputBoxTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("Button", nil, "IconButtonTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("Button", nil, "UIButtonTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("Button", nil, "UIPanelButtonTemplate", miog.resetFrame):SetResetDisallowedIfNew()

		applicantFrame.fontStringPool = applicantFrame.fontStringPool or CreateFontStringPool(applicantFrame, "OVERLAY", nil, "GameTooltipText", miog.resetFontString)
		applicantFrame.texturePool = applicantFrame.texturePool or CreateTexturePool(applicantFrame, "ARTWORK", nil, nil, miog.resetTexture)

		miog.createFrameBorder(applicantFrame, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

		applicantSystem.applicantMember[applicantID].frame = applicantFrame

		for applicantIndex = 1, applicantData.numMembers, 1 do

			local name, class, localizedClass, level, itemLevel, honorLevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, factionGroup, raceID, specID -- specID is new in 10.2
			local dungeonData, pvpData, rioProfile

			if(miog.F.IS_IN_DEBUG_MODE) then
				name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, _, specID, dungeonData, pvpData = miog.debug_GetApplicantMemberInfo(applicantID, applicantIndex)

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

			local profile, mythicKeystoneProfile, raidProfile

			if(miog.F.IS_RAIDERIO_LOADED) then
				profile = getRioProfile(nameTable[1], nameTable[2], miog.C.CURRENT_REGION)

				if(profile ~= nil) then
					mythicKeystoneProfile = profile.mythicKeystoneProfile
					raidProfile = profile.raidProfile

				end
			end

			local applicantMemberFrame = miog.createFleetingFrame(applicantFrame.framePool, "ResizeLayoutFrame, BackdropTemplate", applicantFrame)
			applicantMemberFrame.fixedWidth = applicantFrame.fixedWidth - 2
			applicantMemberFrame.minimumHeight = 20
			applicantMemberFrame:SetPoint("TOP", applicantFrame.memberFrames[applicantIndex-1] or applicantFrame, applicantFrame.memberFrames[applicantIndex-1] and "BOTTOM" or "TOP", 0, applicantIndex > 1 and -miog.C.APPLICANT_PADDING or -1)
			applicantFrame.memberFrames[applicantIndex] = applicantMemberFrame

			if(MIOG_SavedSettings.preferredApplicants.table[name]) then
				miog.createFrameBorder(applicantMemberFrame, 2, CreateColorFromHexString("FFe1ad21"):GetRGBA())

			end

			local applicantMemberFrameBackground = miog.createFleetingTexture(applicantFrame.texturePool, nil, applicantMemberFrame, applicantMemberFrame.fixedWidth, applicantMemberFrame.minimumHeight)
			applicantMemberFrameBackground:SetDrawLayer("BACKGROUND")
			applicantMemberFrameBackground:SetAllPoints(true)
			applicantMemberFrameBackground:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

			local applicantMemberStatusFrame = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", applicantFrame, nil, nil, "FontString", applicantFrame.fontStringPool)
			applicantMemberStatusFrame:Hide()
			applicantMemberStatusFrame:SetPoint("TOPLEFT", applicantMemberFrame, "TOPLEFT", 0, 0)
			applicantMemberStatusFrame:SetPoint("BOTTOMRIGHT", applicantMemberFrame, "BOTTOMRIGHT", 0, 0)
			applicantMemberStatusFrame:SetFrameStrata("FULLSCREEN")
			--applicantMemberStatusFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
			--applicantMemberStatusFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.7)

			local applicantMemberStatusFrameBackground = miog.createFleetingTexture(applicantFrame.texturePool, nil, applicantMemberStatusFrame)
			--applicantMemberStatusFrameBackground:SetDrawLayer("BACKGROUND")
			applicantMemberStatusFrameBackground:SetAllPoints(true)
			applicantMemberStatusFrameBackground:SetColorTexture(0.1, 0.1, 0.1, 0.7)

			applicantMemberStatusFrame.FontString:SetJustifyH("CENTER")
			applicantMemberStatusFrame.FontString:SetWidth(applicantMemberFrame.fixedWidth)
			applicantMemberStatusFrame.FontString:SetPoint("TOP", applicantMemberStatusFrame, "TOP", 0, -2)
			applicantMemberStatusFrame.FontString:Show()

			applicantMemberFrame.statusFrame = applicantMemberStatusFrame

			local basicInformationPanel = miog.createFleetingFrame(applicantFrame.framePool, "ResizeLayoutFrame, BackdropTemplate", applicantMemberFrame)
			basicInformationPanel.fixedWidth = applicantMemberFrame.fixedWidth
			basicInformationPanel.maximumHeight = miog.C.APPLICANT_MEMBER_HEIGHT
			basicInformationPanel:SetPoint("TOPLEFT", applicantMemberFrame, "TOPLEFT", 0, 0)
			applicantMemberFrame.basicInformationPanel = basicInformationPanel

			local expandFrameButton = Mixin(miog.createFleetingFrame(applicantFrame.framePool, "UIButtonTemplate", basicInformationPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), TripleStateButtonMixin)
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

			if(applicantData.comment ~= "" and applicantData.comment ~= nil) then
				local commentFrame = miog.createFleetingTexture(applicantFrame.texturePool, 136459, basicInformationPanel, basicInformationPanel.maximumHeight - 10, basicInformationPanel.maximumHeight - 10)
				commentFrame:ClearAllPoints()
				commentFrame:SetDrawLayer("ARTWORK")
				commentFrame:SetPoint("BOTTOMRIGHT", expandFrameButton, "BOTTOMRIGHT", 0, 0)

			end

			local playerIsIgnored = C_FriendList.IsIgnored(name)

			local rioLink = "https://raider.io/characters/" .. miog.F.CURRENT_REGION .. "/" .. miog.REALM_LOCAL_NAMES[nameTable[2]] .. "/" .. nameTable[1]

			local nameFrame = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", basicInformationPanel, basicInformationPanel.fixedWidth * 0.27, basicInformationPanel.maximumHeight, "FontString", applicantFrame.fontStringPool,  miog.C.APPLICANT_MEMBER_FONT_SIZE)
			nameFrame:SetPoint("LEFT", expandFrameButton, "RIGHT", 0, 0)
			nameFrame:SetFrameStrata("DIALOG")
			nameFrame.FontString:SetText(playerIsIgnored and wticc(nameTable[1], "FFFF0000") or wticc(nameTable[1], select(4, GetClassColor(class))))
			nameFrame:SetMouseMotionEnabled(true)
			nameFrame:SetScript("OnMouseDown", function(_, button)
				if(button == "RightButton") then

					nameFrame.linkBox:SetAutoFocus(true)
					nameFrame.linkBox:SetText(rioLink)
					nameFrame.linkBox:HighlightText()

					nameFrame.linkBox:Show()
					nameFrame.linkBox:SetAutoFocus(false)

				end
			end)
			nameFrame:SetScript("OnEnter", function()
				GameTooltip:SetOwner(nameFrame, "ANCHOR_CURSOR")

				if(playerIsIgnored) then
					GameTooltip:SetText("Player is on your ignore list")

				else
					if(nameFrame.FontString:IsTruncated()) then
						GameTooltip:SetText(nameFrame.FontString:GetText())
					end

					if(name == "Rhany-Ravencrest" or name == "Gerhanya-Ravencrest") then
						GameTooltip:AddLine("You've found the creator of this addon.\nHow lucky!")

					end
				end

				GameTooltip:Show()

			end)
			nameFrame:SetScript("OnLeave", function()
				GameTooltip:Hide()

			end)

			nameFrame.linkBox = miog.createFleetingFrame(applicantFrame.framePool, "InputBoxTemplate", applicantMemberFrame, nil, miog.C.APPLICANT_MEMBER_HEIGHT)
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

			local specFrame = miog.createFleetingTexture(applicantFrame.texturePool, nil, basicInformationPanel, basicInformationPanel.maximumHeight - 5, basicInformationPanel.maximumHeight - 5)

			if(miog.SPECIALIZATIONS[specID] and class == miog.SPECIALIZATIONS[specID].class.name) then
				specFrame:SetTexture(miog.SPECIALIZATIONS[specID].icon)

			else
				specFrame:SetTexture(miog.SPECIALIZATIONS[0].icon)

			end

			specFrame:SetPoint("LEFT", nameFrame, "RIGHT", 3, 0)
			specFrame:SetDrawLayer("ARTWORK")

			local roleFrame = miog.createFleetingTexture(applicantFrame.texturePool, nil, basicInformationPanel, basicInformationPanel.maximumHeight - 1, basicInformationPanel.maximumHeight - 1)
			roleFrame:SetPoint("LEFT", specFrame or nameFrame, "RIGHT", 1, 0)
			roleFrame:SetDrawLayer("ARTWORK")
			roleFrame:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. assignedRole .. "Icon.png")

			local primaryIndicator = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.11, basicInformationPanel.maximumHeight)
			primaryIndicator:SetPoint("LEFT", roleFrame, "RIGHT", 5, 0)
			primaryIndicator:SetJustifyH("CENTER")

			local secondaryIndicator = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.11, basicInformationPanel.maximumHeight)
			secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 1, 0)
			secondaryIndicator:SetJustifyH("CENTER")

			local itemLevelFrame = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.13, basicInformationPanel.maximumHeight)
			itemLevelFrame:SetPoint("LEFT", secondaryIndicator, "RIGHT", 1, 0)
			itemLevelFrame:SetJustifyH("CENTER")

			local reqIlvl = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel or 0

			if(reqIlvl > itemLevel) then
				itemLevelFrame:SetText(wticc(miog.round(itemLevel, 1), miog.CLRSCC["red"]))

			else
				itemLevelFrame:SetText(miog.round(itemLevel, 1))

			end

			if(relationship) then
				local friendFrame = miog.createFleetingTexture(applicantFrame.texturePool, miog.C.STANDARD_FILE_PATH .. "/infoIcons/friend.png", basicInformationPanel, basicInformationPanel.maximumHeight - 3, basicInformationPanel.maximumHeight - 3)
				friendFrame:SetPoint("LEFT", itemLevelFrame, "RIGHT", 3, 0)
				friendFrame:SetDrawLayer("ARTWORK")
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
				local groupFrame = miog.createFleetingTexture(applicantFrame.texturePool, miog.C.STANDARD_FILE_PATH .. "/infoIcons/link.png", basicInformationPanel, basicInformationPanel.maximumHeight - 3, basicInformationPanel.maximumHeight - 3)
				groupFrame:ClearAllPoints()
				groupFrame:SetDrawLayer("OVERLAY")
				groupFrame:SetPoint("TOPRIGHT", basicInformationPanel, "TOPRIGHT", -1, -1)

			end

			-- Mark player: good/bad

			if(applicantIndex == 1 and C_PartyInfo.CanInvite() == true or applicantIndex == 1 and miog.F.IS_IN_DEBUG_MODE) then
				local declineButton = miog.createFleetingFrame(applicantFrame.framePool, "IconButtonTemplate", basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight)
				declineButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
				declineButton.iconSize = basicInformationPanel.maximumHeight - 4
				declineButton:OnLoad()
				declineButton:SetPoint("RIGHT", basicInformationPanel, "RIGHT", 0, 0)
				declineButton:SetFrameStrata("DIALOG")
				declineButton:RegisterForClicks("LeftButtonUp")
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
				applicantMemberFrame.basicInformationPanel.declineButton = declineButton

				local inviteButton = miog.createFleetingFrame(applicantFrame.framePool, "IconButtonTemplate", basicInformationPanel, basicInformationPanel.maximumHeight, basicInformationPanel.maximumHeight)
				inviteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png"
				inviteButton.iconSize = basicInformationPanel.maximumHeight - 4
				inviteButton:SetFrameStrata("DIALOG")
				inviteButton:OnLoad()
				inviteButton:SetPoint("RIGHT", declineButton, "LEFT")
				inviteButton:RegisterForClicks("LeftButtonDown")
				inviteButton:SetScript("OnClick", function()
					C_LFGList.InviteApplicant(applicantID)

					if(miog.F.IS_IN_DEBUG_MODE) then
						updateApplicantStatusFrame(applicantID, "debug")
					end

				end)

				applicantMemberFrame.basicInformationPanel.inviteButton = inviteButton
			end

			local detailedInformationPanel = miog.createFleetingFrame(applicantFrame.framePool, "ResizeLayoutFrame, BackdropTemplate", applicantMemberFrame)
			detailedInformationPanel:SetWidth(basicInformationPanel.fixedWidth)
			detailedInformationPanel:SetPoint("TOPLEFT", basicInformationPanel, "BOTTOMLEFT", 0, 0)
			detailedInformationPanel:SetShown(expandFrameButton:GetActiveState() > 0 and true or false)
			local rowWidth = basicInformationPanel.fixedWidth * 0.5

			applicantMemberFrame.detailedInformationPanel = detailedInformationPanel

			local tabPanel = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", detailedInformationPanel)
			tabPanel:SetPoint("TOPLEFT", detailedInformationPanel, "TOPLEFT")
			tabPanel:SetPoint("TOPRIGHT", detailedInformationPanel, "TOPRIGHT")
			tabPanel:SetHeight(miog.C.APPLICANT_MEMBER_HEIGHT)
			tabPanel.rows = {}

			detailedInformationPanel.tabPanel = tabPanel

			local mythicPlusTabButton = miog.createFleetingFrame(applicantFrame.framePool, "UIPanelButtonTemplate", tabPanel)
			mythicPlusTabButton:SetSize(rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
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

			local raidTabButton = miog.createFleetingFrame(applicantFrame.framePool, "UIPanelButtonTemplate", tabPanel)
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

			local raidPanel = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", detailedInformationPanel, rowWidth, 9 * 20)
			raidPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
			tabPanel.raidPanel = raidPanel
			raidPanel:SetShown(miog.F.LISTED_CATEGORY_ID == 3 and true)
			raidPanel.rows = {}

			local mythicPlusPanel = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", detailedInformationPanel, rowWidth, 9 * 20)
			mythicPlusPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
			tabPanel.mythicPlusPanel = mythicPlusPanel
			mythicPlusPanel:SetShown(miog.F.LISTED_CATEGORY_ID ~= 3 and true)
			mythicPlusPanel.rows = {}

			local generalInfoPanel = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", detailedInformationPanel, rowWidth, 9 * 20)
			generalInfoPanel:SetPoint("TOPRIGHT", tabPanel, "BOTTOMRIGHT")
			tabPanel.generalInfoPanel = generalInfoPanel
			generalInfoPanel.rows = {}

			local lastTextRow = nil

			local hoverColor = {CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA()}
			local cardColor = {CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA()}

			for rowIndex = 1, miog.F.MOST_BOSSES, 1 do
				local remainder = fmod(rowIndex, 2)

				local textRowFrame = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", detailedInformationPanel)
				textRowFrame:SetSize(basicInformationPanel.fixedWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
				textRowFrame:SetPoint("TOPLEFT", lastTextRow or mythicPlusTabButton, "BOTTOMLEFT")
				lastTextRow = textRowFrame
				tabPanel.rows[rowIndex] = textRowFrame
				
				local textRowBackground = miog.createFleetingTexture(applicantFrame.texturePool, nil, textRowFrame, basicInformationPanel.fixedWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
				textRowBackground:SetDrawLayer("BACKGROUND")
				textRowBackground:SetPoint("CENTER", textRowFrame, "CENTER")

				if(remainder == 1) then
					--textRowFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
					--textRowFrame:SetBackdropColor(unpack(hoverColor))
					textRowBackground:SetColorTexture(unpack(hoverColor))

				else
					--textRowFrame:SetBackdrop(miog.BLANK_BACKGROUND_INFO)
					--textRowFrame:SetBackdropColor(unpack(cardColor))
					textRowBackground:SetColorTexture(unpack(cardColor))

				end

				local divider = miog.createFleetingTexture(applicantFrame.texturePool, nil, textRowFrame, basicInformationPanel.fixedWidth, 1, "BORDER")
				divider:SetAtlas("UI-LFG-DividerLine")
				divider:SetPoint("BOTTOM", textRowFrame, "BOTTOM", 0, 0)

				if(rowIndex == 1 or rowIndex > 4 and rowIndex < 10) then
					local textRowGeneralInfo = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", textRowFrame, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", applicantFrame.fontStringPool,  miog.C.TEXT_ROW_FONT_SIZE)
					textRowGeneralInfo.FontString:SetJustifyH("CENTER")
					textRowGeneralInfo:SetPoint("LEFT", textRowFrame, "LEFT", rowWidth, 0)
					generalInfoPanel.rows[rowIndex] = textRowGeneralInfo

					if(rowIndex == 1 or rowIndex == 5 or rowIndex == 6) then
						local textRowMythicPlus = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", mythicPlusPanel, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", applicantFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE)
						local textRowRaid = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", raidPanel, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", applicantFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE)

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
			end

			--[[
			ROW LAYOUT

			1-4 Comment
			5 Score for prev. season
			6 Score for main current/prev. season
			7 Applicant alternative roles
			8 M+ keys done +5 +10 +15 +20 (+25 not available from Raider.IO addon data)
			9 Region + Realm
 
			]]

			generalInfoPanel.rows[1].FontString:SetJustifyV("TOP")
			generalInfoPanel.rows[1].FontString:SetPoint("TOPLEFT", generalInfoPanel.rows[1], "TOPLEFT", 0, -5)
			generalInfoPanel.rows[1].FontString:SetPoint("BOTTOMRIGHT", tabPanel.rows[4], "BOTTOMRIGHT", 0, 0)
			generalInfoPanel.rows[1].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. ((applicantData.comment and applicantData.comment) or ""))
			generalInfoPanel.rows[1].FontString:SetWordWrap(true)
			generalInfoPanel.rows[1].FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)

			generalInfoPanel.rows[7].FontString:SetText(_G["LFG_TOOLTIP_ROLES"] .. ((tank == true and miog.C.TANK_TEXTURE) or (healer == true and miog.C.HEALER_TEXTURE) or (damager == true and miog.C.DPS_TEXTURE)))
			generalInfoPanel.rows[9].FontString:SetText(string.upper(miog.F.CURRENT_REGION) .. "-" .. (nameTable[2] or GetRealmName() or ""))

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
				if(mythicKeystoneProfile and mythicKeystoneProfile.currentScore > 0 and mythicKeystoneProfile.sortedDungeons) then

					table.sort(mythicKeystoneProfile.sortedDungeons, function(k1, k2)
						return k1.dungeon.shortName < k2.dungeon.shortName

					end)

					local rowWidthThirty = rowWidth*0.30

					local primaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeons or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeons
					local primaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeonUpgrades or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeonUpgrades
					local secondaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeons or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeons
					local secondaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeonUpgrades or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeonUpgrades

					if(primaryDungeonLevel and primaryDungeonChests and secondaryDungeonLevel and secondaryDungeonChests) then
						for _, dungeonEntry in ipairs(mythicKeystoneProfile.sortedDungeons) do
							local rowIndex = dungeonEntry.dungeon.index

							local dungeonIconFrame = miog.createFleetingTexture(applicantFrame.texturePool, miog.DUNGEON_ICONS[mythicKeystoneProfile.sortedDungeons[rowIndex].dungeon.instance_map_id], mythicPlusPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2)
							dungeonIconFrame:SetPoint("LEFT", tabPanel.rows[rowIndex], "LEFT")
							dungeonIconFrame:SetMouseClickEnabled(true)
							dungeonIconFrame:SetDrawLayer("OVERLAY")
							dungeonIconFrame:SetScript("OnMouseDown", function()
								local instanceID = C_EncounterJournal.GetInstanceForGameMap(mythicKeystoneProfile.sortedDungeons[rowIndex].dungeon.instance_map_id)

								--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
								EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

							end)

							local dungeonNameFrame = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidth*0.25, miog.C.APPLICANT_MEMBER_HEIGHT)
							dungeonNameFrame:SetText(mythicKeystoneProfile.sortedDungeons[rowIndex].dungeon.shortName .. ":")
							dungeonNameFrame:SetPoint("LEFT", dungeonIconFrame, "RIGHT", 1, 0)

							local primaryAffixScoreFrame = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidthThirty, miog.C.APPLICANT_MEMBER_HEIGHT)
							primaryAffixScoreFrame:SetText(wticc(primaryDungeonLevel[rowIndex] .. rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or primaryDungeonChests[rowIndex]),
							primaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or primaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))
							primaryAffixScoreFrame:SetPoint("LEFT", dungeonNameFrame, "RIGHT")

							local secondaryAffixScoreFrame = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidthThirty, miog.C.APPLICANT_MEMBER_HEIGHT)
							secondaryAffixScoreFrame:SetText(wticc(secondaryDungeonLevel[rowIndex] .. rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or secondaryDungeonChests[rowIndex]),
							secondaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or secondaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))
							secondaryAffixScoreFrame:SetPoint("LEFT", primaryAffixScoreFrame, "RIGHT")

							--[[if(miog.F.WEEKLY_AFFIX == 9 and rowIndex == mythicKeystoneProfile.tyrannicalMaxDungeonIndex or miog.F.WEEKLY_AFFIX == 10 and rowIndex == mythicKeystoneProfile.fortifiedMaxDungeonIndex) then
								local bestPrimaryDungeonFrame = miog.createFleetingTexture(applicantFrame.texturePool, miog.C.STANDARD_FILE_PATH .."/shapes/dotted_border.png", mythicPlusPanel, rowWidthThirty, miog.C.APPLICANT_MEMBER_HEIGHT)
								bestPrimaryDungeonFrame:SetDrawLayer("OVERLAY")
								bestPrimaryDungeonFrame:SetPoint("TOPLEFT", primaryAffixScoreFrame, "TOPLEFT")

							elseif(miog.F.WEEKLY_AFFIX == 9 and rowIndex == mythicKeystoneProfile.fortifiedMaxDungeonIndex or miog.F.WEEKLY_AFFIX == 10 and rowIndex == mythicKeystoneProfile.tyrannicalMaxDungeonIndex) then
								local bestSecondaryDungeonFrame = miog.createFleetingTexture(applicantFrame.texturePool, miog.C.STANDARD_FILE_PATH .."/shapes/dotted_border.png", mythicPlusPanel, rowWidthThirty, miog.C.APPLICANT_MEMBER_HEIGHT)
								bestSecondaryDungeonFrame:SetDrawLayer("OVERLAY")
								bestSecondaryDungeonFrame:SetPoint("TOPLEFT", secondaryAffixScoreFrame, "TOPLEFT")

							end]]

						end
					end

					local previousScoreString = ""

					if(mythicKeystoneProfile.previousScore > 0) then
						previousScoreString = (miog.F.PREVIOUS_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]) .. ": " .. wticc(mythicKeystoneProfile.previousScore, miog.createCustomColorForScore(mythicKeystoneProfile.previousScore):GenerateHexColor())
					
					end

					mythicPlusPanel.rows[5].FontString:SetText(previousScoreString)

					local mainScoreString = ""

					if((mythicKeystoneProfile.mainCurrentScore > 0) == false and (mythicKeystoneProfile.mainPreviousScore > 0) == false) then
						mainScoreString = wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex)

					else
						if(mythicKeystoneProfile.mainCurrentScore > 0 and mythicKeystoneProfile.mainPreviousScore > 0) then
							mainScoreString = "Main " .. (miog.F.CURRENT_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason()]) .. ": " .. wticc(mythicKeystoneProfile.mainCurrentScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor()) ..
							" " .. miog.F.PREVIOUS_SEASON .. ": " .. wticc(mythicKeystoneProfile.mainPreviousScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainPreviousScore):GenerateHexColor())

						elseif(mythicKeystoneProfile.mainCurrentScore > 0) then
							mainScoreString = "Main " .. (miog.F.CURRENT_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason()]) .. ": " .. wticc(mythicKeystoneProfile.mainCurrentScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor())

						elseif(mythicKeystoneProfile.mainPreviousScore > 0) then
							mainScoreString = "Main " .. (miog.F.PREVIOUS_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]) .. ": " .. wticc(mythicKeystoneProfile.mainPreviousScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainPreviousScore):GenerateHexColor())

						end

					end

					mythicPlusPanel.rows[6].FontString:SetText(mainScoreString)

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
					local lastIcon = false

					local higherDifficultyNumber = nil

					local progressFrame
					local mainProgressText = ""
					local halfRowWidth = raidPanel.rows[1]:GetWidth() * 0.5

					local raidIndex = 0

					local rowHeight = miog.C.APPLICANT_MEMBER_HEIGHT * 1.35

					raidPanel.textureRows = {}

					for _, sortedProgress in ipairs(raidProfile.sortedProgress) do
						if(sortedProgress.isMainProgress ~= true) then
							local progressCount = sortedProgress.progress.progressCount
							local bossCount = sortedProgress.progress.raid.bossCount
							local panelProgressString = wticc(miog.C.DIFFICULTY[sortedProgress.progress.difficulty].shortName .. ":" .. progressCount .. "/" .. bossCount, miog.C.DIFFICULTY[sortedProgress.progress.difficulty].color)
							local basicProgressString = wticc(progressCount .. "/" .. bossCount, sortedProgress.progress.raid.ordinal == 1 and miog.C.DIFFICULTY[sortedProgress.progress.difficulty].color or miog.C.DIFFICULTY[sortedProgress.progress.difficulty].desaturated)

							if(sortedProgress.progress.raid.ordinal ~= lastOrdinal) then

								if(miog.F.LISTED_CATEGORY_ID == 3) then
									if(primaryIndicator:GetText() ~= nil and secondaryIndicator:GetText() == nil) then
										secondaryIndicator:SetText(basicProgressString)

									end

									if(primaryIndicator:GetText() == nil) then
										primaryIndicator:SetText(basicProgressString)

									end
								end

								local instanceID = C_EncounterJournal.GetInstanceForGameMap(sortedProgress.progress.raid.mapId)

								raidIndex = raidIndex + 1
								raidPanel.textureRows[raidIndex] = {}

								local raidIconFrame = miog.createFleetingTexture(applicantFrame.texturePool, miog.RAID_ICONS[sortedProgress.progress.raid.mapId][bossCount + 1], raidPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2)
								raidIconFrame:SetPoint("LEFT", raidPanel.rows[1], "LEFT", lastIcon and halfRowWidth or 0, 0)
								raidIconFrame:SetMouseClickEnabled(true)
								raidIconFrame:SetDrawLayer("OVERLAY")
								raidIconFrame:SetScript("OnMouseDown", function()
									--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
									EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, nil, nil, nil, nil)

								end)

								lastIcon = true

								local raidNameString = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE, raidPanel)
								raidNameString:SetPoint("LEFT", raidIconFrame, "RIGHT", 2, 0)
								raidNameString:SetText(sortedProgress.progress.raid.shortName .. ":")

								higherDifficultyNumber = sortedProgress.progress.difficulty

								progressFrame = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE,  raidPanel, halfRowWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
								progressFrame:SetText(panelProgressString)
								progressFrame:SetPoint("TOPLEFT", raidIconFrame, "BOTTOMLEFT")

								local currentDiffColor = {miog.ITEM_QUALITY_COLORS[higherDifficultyNumber+1].color:GetRGBA()}

								for bossIndex = 1, bossCount, 1 do
									if(bossIndex <= bossCount) then
										--local bossFrame = miog.createFleetingFrame(applicantFrame.framePool, "BackdropTemplate", raidPanel, rowHeight, rowHeight)
										--bossFrame:SetPoint("TOPLEFT", columnIndex == 2 and raidPanel.textureRows[raidIndex][rowIndex].bossFrames[columnIndex-1] or raidPanel.textureRows[raidIndex][rowIndex], columnIndex == 2 and "TOPRIGHT" or "TOPLEFT", 2, 0)
										local bossFrame = miog.createFleetingTexture(applicantFrame.texturePool, miog.RAID_ICONS[sortedProgress.progress.raid.mapId][bossIndex], raidPanel, rowHeight, rowHeight)
										bossFrame:SetPoint("TOPLEFT", bossIndex == 1 and progressFrame or bossIndex == 2 and raidPanel.textureRows[raidIndex][bossIndex - 1] or raidPanel.textureRows[raidIndex][bossIndex - 2],
										bossIndex == 2 and "TOPRIGHT" or "BOTTOMLEFT", bossIndex == 1 and 2 or bossIndex == 2 and 5 or 0, bossIndex == 1 and -2 or bossIndex == 2 and 0 or -5)
										bossFrame:SetDrawLayer("OVERLAY", -4)
										bossFrame:SetMouseClickEnabled(true)
										bossFrame:SetScript("OnMouseDown", function()

											--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
											EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, select(3, EJ_GetEncounterInfoByIndex(bossIndex, instanceID)), nil, nil, nil)

										end)

										bossFrame.border = miog.createFleetingTexture(applicantFrame.texturePool, nil, raidPanel, bossFrame:GetSize())
										bossFrame.border:SetDrawLayer("OVERLAY", -5)
										bossFrame.border:SetPoint("TOPLEFT", bossFrame, "TOPLEFT", -2, 2)

										bossFrame:SetSize(bossFrame:GetWidth()-4, bossFrame:GetHeight()-4)
										--bossFrame.border:SetColorTexture(0,0,0)

										--[[bossFrame:SetBackdrop({
											bgFile = miog.RAID_ICONS[sortedProgress.progress.raid.mapId][bossIndex],
											edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
											edgeSize = 2
										})]]

										if(sortedProgress.progress.killsPerBoss) then
											local desaturated
											local numberOfBossKills = sortedProgress.progress.killsPerBoss[bossIndex]

											if(numberOfBossKills > 0) then
												desaturated = false

												bossFrame.border:SetColorTexture(unpack(currentDiffColor))
												--bossFrame:SetBackdropBorderColor(unpack(currentDiffColor))

											elseif(numberOfBossKills == 0) then
												desaturated = true
												--bossFrame:SetBackdropBorderColor(0, 0, 0, 0)
												bossFrame.border:SetColorTexture(0, 0, 0, 0)

											end

											bossFrame:SetDesaturated(desaturated)

										end

										local bossNumber = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE, raidPanel)
										bossNumber:SetPoint("TOPLEFT", bossFrame, "TOPLEFT")
										bossNumber:SetText(bossIndex)

										raidPanel.textureRows[raidIndex][bossIndex] = bossFrame
									end
								end

							else

								if(sortedProgress.progress.difficulty ~= higherDifficultyNumber) then

									if(miog.F.LISTED_CATEGORY_ID == 3) then
										if(secondaryIndicator:GetText() == nil) then
											secondaryIndicator:SetText(basicProgressString) -- ACTUAL PROGRESS
										end
									end

									progressFrame:SetText(progressFrame:GetText() .. " " .. panelProgressString)

									local bossIndex = 1

									for _, bossFrame in ipairs(raidPanel.textureRows[raidIndex]) do
										local desaturated = bossFrame:IsDesaturated()

										if(sortedProgress.progress.killsPerBoss) then
											if(sortedProgress.progress.killsPerBoss[bossIndex] > 0 and desaturated == true) then
												--bossFrame:SetBackdropBorderColor(miog.ITEM_QUALITY_COLORS[sortedProgress.progress.difficulty + 1].color:GetRGBA())
												bossFrame.border:SetColorTexture(miog.ITEM_QUALITY_COLORS[sortedProgress.progress.difficulty + 1].color:GetRGBA())
												bossFrame:SetDesaturated(false)

											elseif(sortedProgress.progress.killsPerBoss[bossIndex] == 0 and desaturated == true) then
												--bossFrame:SetBackdropBorderColor(0, 0, 0, 0)
												bossFrame.border:SetColorTexture(0, 0, 0, 0)
											end

										else
											if(progressCount == bossCount) then
												if(desaturated == true) then
													--bossFrame:SetBackdropBorderColor(miog.ITEM_QUALITY_COLORS[sortedProgress.progress.difficulty + 1].color:GetRGBA())
													bossFrame.border:SetColorTexture(miog.ITEM_QUALITY_COLORS[sortedProgress.progress.difficulty + 1].color:GetRGBA())
													bossFrame:SetDesaturated(false)
													
												end

											end
										end

										bossIndex = bossIndex + 1

									end
								end
							end

							lastOrdinal = sortedProgress.progress.raid.ordinal

						else
							mainProgressText = mainProgressText .. wticc(miog.C.DIFFICULTY[sortedProgress.progress.difficulty].shortName .. ":" .. sortedProgress.progress.progressCount .. "/" .. sortedProgress.progress.raid.bossCount, miog.C.DIFFICULTY[sortedProgress.progress.difficulty].color) .. " "

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
						primaryIndicator:SetText(wticc("0/0", miog.C.DIFFICULTY[-1].color))
						secondaryIndicator:SetText(wticc("0/0", miog.C.DIFFICULTY[-1].color))
						
					end

				end

			else -- If RaiderIO is not installed
				mythicPlusPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))
				mythicPlusPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)

				raidPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))
				raidPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)

				if(miog.F.LISTED_CATEGORY_ID == 3) then
					primaryIndicator:SetText(wticc("0/0", miog.C.DIFFICULTY[-1].color))
					secondaryIndicator:SetText(wticc("0/0", miog.C.DIFFICULTY[-1].color))

				end

			end

			basicInformationPanel:MarkDirty()
			detailedInformationPanel:MarkDirty()
			applicantMemberFrame:MarkDirty()

		end

		applicantFrame:MarkDirty()
		applicantSystem.applicantMember[applicantID].status = "indexed"

	end

	--updateApplicantStatusFrame(applicantID, "debug")

end

local function gatherSortData()

	local unsortedMainApplicantsList = {}

	local currentApplicants = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicants() or C_LFGList.GetApplicants()

	for _, applicantID in pairs(currentApplicants) do

		if(applicantSystem.applicantMember[applicantID]) then --CHECK IF ENTRY IS THERE

			--local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

			--if(applicantData and applicantData.applicationStatus == "applied" and applicantData.displayOrderID > 0) then --IF DATA IS AVAILABLE
			if(applicantSystem.applicantMember[applicantID] and applicantSystem.applicantMember[applicantID].status ~= "removable") then
				if(applicantSystem.applicantMember[applicantID].saveData == nil) then -- FIRST TIME THIS APPLICANT APPLIES?

					local name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo

					if(miog.F.IS_IN_DEBUG_MODE) then
						name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID, bestDungeonScoreForListing, pvpRatingInfo = miog.debug_GetApplicantMemberInfo(applicantID, 1)

					else
						name, class, _, _, itemLevel, _, _, _, _, assignedRole, _, dungeonScore, _, _, _, specID = C_LFGList.GetApplicantMemberInfo(applicantID, 1)

					end

					local nameTable = miog.simpleSplit(name, "-")

					if(not nameTable[2]) then
						nameTable[2] = GetNormalizedRealmName()

					end

					local activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityID or 0
					local profile, primarySortAttribute, secondarySortAttribute

					if(miog.F.IS_RAIDERIO_LOADED) then
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
						name = nameTable[1],
						realm = nameTable[2],
						fullName = name,
						index = applicantID,
						role = assignedRole,
						class = class,
						specID = specID,
						primary = primarySortAttribute,
						secondary = secondarySortAttribute,
						ilvl = itemLevel
					}

				end

				unsortedMainApplicantsList[#unsortedMainApplicantsList+1] = applicantSystem.applicantMember[applicantID].saveData
				unsortedMainApplicantsList[#unsortedMainApplicantsList].preferred = MIOG_SavedSettings.preferredApplicants.table[unsortedMainApplicantsList[#unsortedMainApplicantsList].fullName] and true or false

			end
		end
	end

	return unsortedMainApplicantsList
end

local function addOrShowApplicant(applicantID)
	if(applicantSystem.applicantMember[applicantID].frame) then
		applicantSystem.applicantMember[applicantID].frame:Show()

	else
		applicantSystem.applicantMember[applicantID].status = "inProgress"
		createApplicantFrame(applicantID)

	end

	applicantSystem.applicantMember[applicantID].frame.layoutIndex = layoutIndex

	miog.mainFrame.applicantPanel.container:MarkDirty()
	layoutIndex = layoutIndex + 1
end

local function checkApplicantList(forceReorder, applicantID)
	local unsortedList = gatherSortData()

	miog.mainFrame.footerBar.applicantNumberFontString:SetText(#unsortedList)

	local allSystemMembers = {}

	if(forceReorder) then
		for k, v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame:Hide()
				v.frame.layoutIndex = nil
	
			end
	
			allSystemMembers[k] = true
			
		end
	
		miog.mainFrame.applicantPanel.container:MarkDirty()
	
		layoutIndex = 0

		if(unsortedList[1]) then
			table.sort(unsortedList, sortApplicantList)

			for _, listEntry in ipairs(unsortedList) do
				allSystemMembers[listEntry.index] = nil

				if((listEntry.role == "TANK" and miog.mainFrame.buttonPanel.filterPanel.roleFilterPanel.RoleButtons[1]:GetChecked()
				or listEntry.role == "HEALER" and miog.mainFrame.buttonPanel.filterPanel.roleFilterPanel.RoleButtons[2]:GetChecked()
				or listEntry.role == "DAMAGER" and miog.mainFrame.buttonPanel.filterPanel.roleFilterPanel.RoleButtons[3]:GetChecked())) then
					if(miog.mainFrame.buttonPanel.filterPanel.classFilterPanel.ClassPanels[miog.CLASSFILE_TO_ID[listEntry.class]].Button:GetChecked()) then
						if(miog.SPECIALIZATIONS[listEntry.specID] and listEntry.class == miog.SPECIALIZATIONS[listEntry.specID].class.name) then
							if(miog.mainFrame.buttonPanel.filterPanel.classFilterPanel.ClassPanels[miog.CLASSFILE_TO_ID[listEntry.class]].specFilterPanel.SpecButtons[listEntry.specID]:GetChecked()) then
								addOrShowApplicant(listEntry.index)

							end

						else
							addOrShowApplicant(listEntry.index)

						end

					end

				end

			end
		end
	else
		addOrShowApplicant(applicantID)
	
	end

	for k in pairs(allSystemMembers) do
		if(applicantSystem.applicantMember[k].frame) then
			applicantSystem.applicantMember[k].frame.framePool:ReleaseAll()
			applicantSystem.applicantMember[k].frame.fontStringPool:ReleaseAll()
			applicantSystem.applicantMember[k].frame.texturePool:ReleaseAll()

			miog.fleetingFramePool:Release(applicantSystem.applicantMember[k].frame)

			applicantSystem.applicantMember[k] = nil

		end
	end
end


local function createFullEntries(iterations)
	resetArrays()
	fullRelease()

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
			comment = "Heiho, heiho, wir sind froh. Johei, johei, die Arbeit ist vorbei.",
			displayOrderID = 1,
		}

		applicantSystem.applicantMember[applicantID] = {
			frame = nil,
			saveData = nil,
			status = "dataAvailable",
		}

		miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID] = {}

		for memberIndex = 1, miog.DEBUG_APPLICANT_DATA[applicantID].numMembers, 1 do
			local rating = random(1, 4000)
			rating = 0

			local debugProfile = miog.DEBUG_RAIDER_IO_PROFILES[numbers[random(1, #miog.DEBUG_RAIDER_IO_PROFILES)]]
			local rioProfile = RaiderIO.GetProfile(debugProfile[1], debugProfile[2], debugProfile[3])

			local classID = random(1, 13)
			local classInfo = C_CreatureInfo.GetClassInfo(classID) or {"WARLOCK", "Warlock"}

			local specID = miog.CLASSES[classID].specs[random(1, #miog.DEBUG_SPEC_TABLE[classID])]

			local highestKey

			if(rioProfile and rioProfile.mythicKeystoneProfile) then
				highestKey = rioProfile.mythicKeystoneProfile.fortifiedMaxDungeonLevel > rioProfile.mythicKeystoneProfile.tyrannicalMaxDungeonLevel and
				rioProfile.mythicKeystoneProfile.fortifiedMaxDungeonLevel or rioProfile.mythicKeystoneProfile.tyrannicalMaxDungeonLevel
			end

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
				[17]  = {finishedSuccess = true, bestRunLevel = highestKey or 0, mapName = "Big Dick Land"},
				[18]  = {bracket = "", rating = rating, activityName = "XD", tier = miog.debugGetTestTier(rating)},
			}
		end

	end

	local startTime = GetTimePreciseSec()
	checkApplicantList(true)
	local endTime = GetTimePreciseSec()

	currentAverageExecuteTime[#currentAverageExecuteTime+1] = endTime - startTime
end

local function updateSpecFrames()
	miog.releaseRaidRosterPool()

	local indexedGroup = {}
	groupSystem.specCount = {}

	local numOfMembers = GetNumGroupMembers()

	for guid, groupMember in pairs(groupSystem.groupMember) do
		if(groupMember.specID ~= nil and groupMember.specID ~= 0) then
			if(UnitGUID(groupMember.unitID) == guid or guid == "PLAYER-1329-00000001") then
				local unitInPartyOrRaid = UnitInRaid(groupMember.unitID) or UnitInParty(groupMember.unitID) or miog.checkLFGState() == "solo"

				if(unitInPartyOrRaid or guid == "PLAYER-1329-00000001") then
					indexedGroup[#indexedGroup+1] = groupMember
					indexedGroup[#indexedGroup].guid = guid

					miog.mainFrame.classPanel.progressText:SetText(#indexedGroup .. "/" .. numOfMembers)

					groupSystem.specCount[groupMember.specID] = groupSystem.specCount[groupMember.specID] and groupSystem.specCount[groupMember.specID] + 1 or 1
				end
			end
		end
	end


	if(#indexedGroup >= numOfMembers) then
		miog.mainFrame.classPanel.progressText:SetText("")

	end

	local specCounter = 1

	for classID, classEntry in ipairs(miog.CLASSES) do
		for _, v in ipairs(classEntry.specs) do
			local currentSpecFrame = miog.mainFrame.classPanel.classFrames[classID].specPanel.specFrames[v]

			if(groupSystem.specCount[v]) then
				currentSpecFrame.layoutIndex = specCounter
				currentSpecFrame.FontString:SetText(groupSystem.specCount[v])
				specCounter = specCounter + 1
				currentSpecFrame:Show()

			else
				currentSpecFrame.layoutIndex = nil
				currentSpecFrame.FontString:SetText("")
				currentSpecFrame:Hide()

			end

		end

		miog.mainFrame.classPanel.classFrames[classID].specPanel:MarkDirty()

	end

	miog.mainFrame.classPanel:MarkDirty()

	if(#indexedGroup < 5) then
		if(groupSystem.roleCount["TANK"] < 1) then
			indexedGroup[#indexedGroup + 1] = {guid = "empty", unitID = "empty", name = "afk", classID = 20, role = "TANK", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}

		end

		if(groupSystem.roleCount["HEALER"] < 1 and #indexedGroup < 5) then
			indexedGroup[#indexedGroup + 1] = {guid = "empty", unitID = "empty", name = "afk", classID = 21, role = "HEALER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}

		end

		for i = 1, 3 - groupSystem.roleCount["DAMAGER"], 1 do
			if(groupSystem.roleCount["DAMAGER"] < 3 and #indexedGroup < 5) then
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

	if(GetNumGroupMembers() < 6) then
		local counter = 1

		lastIcon = nil

		for index, groupMember in ipairs(indexedGroup) do
			local specIcon = groupMember.icon or miog.SPECIALIZATIONS[groupMember.specID].squaredIcon
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.mainFrame.titleBar.groupMemberListing, miog.mainFrame.titleBar.factionIconSize - 2, miog.mainFrame.titleBar.factionIconSize - 2, "Texture", specIcon)
			classIconFrame.layoutIndex = index
			classIconFrame:SetPoint("LEFT", lastIcon or miog.mainFrame.titleBar.groupMemberListing, lastIcon and "RIGHT" or "LEFT")
			classIconFrame:SetFrameStrata("DIALOG")

			if(groupMember.classID <= #miog.CLASSES) then
				classIconFrame:SetScript("OnEnter", function()
					local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(groupMember.guid)

					GameTooltip:SetOwner(classIconFrame, "ANCHOR_CURSOR")
					GameTooltip:AddLine(name .. " - " .. (realm ~= "" and realm or GetRealmName()))
					GameTooltip:Show()

				end)
				classIconFrame:SetScript("OnLeave", function()
					GameTooltip:Hide()

				end)
			end

			if(groupMember.classID <= #miog.CLASSES) then
				local rPerc, gPerc, bPerc = GetClassColor(miog.CLASSES[groupMember.classID].name)
				--miog.createFrameBorder(classIconFrame, 1, rPerc, gPerc, bPerc, 1)

			end

			lastIcon = classIconFrame

			counter = counter + 1

			if(counter == 6) then
				break
			end

		end

	end

	miog.mainFrame.titleBar.groupMemberListing:MarkDirty()

end

local lastNotifyTime = 0

local inspectQueue = {}
local inspectCoroutine

local function requestInspectData()

	for k, v in pairs(inspectQueue) do
		C_Timer.After((lastNotifyTime - GetTimePreciseSec()) > miog.C.BLIZZARD_INSPECT_THROTTLE and 0 or miog.C.BLIZZARD_INSPECT_THROTTLE,
		function()
			local guid = UnitGUID(v)

			if(guid) then
				NotifyInspect(v)

				-- LAST NOTIFY SAVED SO THE MAX TIME BETWEEN NOTIFY CALLS IS ~1.5s
				lastNotifyTime = GetTimePreciseSec()

			else
				--GUID gone

			end
		end)

		coroutine.yield(inspectCoroutine)
	end

end

local function checkCoroutineStatus(newInspectData)
	if(inspectCoroutine == nil) then
		inspectCoroutine = coroutine.create(requestInspectData)
		miog.handleCoroutineReturn({coroutine.resume(inspectCoroutine)})

	else
		if(coroutine.status(inspectCoroutine) == "dead") then
			inspectCoroutine = coroutine.create(requestInspectData)
			miog.handleCoroutineReturn({coroutine.resume(inspectCoroutine)})

		elseif(newInspectData) then
			miog.handleCoroutineReturn({coroutine.resume(inspectCoroutine)})

		end
	end
end

local function createGroupMemberEntry(guid, unitID)
	local _, classFile, _, _, _, name = GetPlayerInfoByGUID(guid)
	local classID = classFile and miog.CLASSFILE_TO_ID[classFile]
	local specID = GetInspectSpecialization(unitID)

	groupSystem.inspectedGUIDs[guid] = specID

	groupSystem.groupMember[guid] = {
		unitID = unitID,
		name = name or UnitName(unitID),
		classID = classID or select(2, UnitClassBase(unitID)),
		role = GetSpecializationRoleByID(specID),
		specID = specID ~= 0 and specID or nil
	}

end

local function updateRosterInfoData()
	miog.releaseRaidRosterPool()

	groupSystem.groupMember = {}

	groupSystem.classCount = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0,
		[9] = 0,
		[10] = 0,
		[11] = 0,
		[12] = 0,
		[13] = 0,
	}

	groupSystem.roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
	}

	local lfgState = miog.checkLFGState()
	local numOfMembers = GetNumGroupMembers()

	for groupIndex = 1, lfgState == "raid" and 40 or lfgState == "party" and 5 or 1, 1 do
		local unitID = ((lfgState == "raid" or (lfgState == "party" and groupIndex ~= numOfMembers)) and lfgState..groupIndex) or "player"

		local guid = UnitGUID(unitID)

		if(guid) then
			local name, _, _, _, _, classFile, _, _, _, _, _, role = GetRaidRosterInfo(groupIndex)

			--print(role == "NONE" and UnitGroupRolesAssigned(unitID) or role or "DAMAGER")

			groupSystem.groupMember[guid] = {
				unitID = unitID,
				name = name or UnitName(unitID),
				classID = classFile and miog.CLASSFILE_TO_ID[classFile] or miog.CLASSFILE_TO_ID[select(2, GetPlayerInfoByGUID(guid))] or select(2, UnitClassBase(unitID)),
				role = role == "NONE" and UnitGroupRolesAssigned(unitID) or role or "DAMAGER",
				specID = groupSystem.inspectedGUIDs[guid]
			}

			local member = groupSystem.groupMember[guid]

			if(not groupSystem.inspectedGUIDs[guid]) then
				if(lfgState == "party" and unitID ~= "player" or lfgState == "raid" and guid ~= UnitGUID("player")) then
					inspectQueue[guid] = unitID

				else
					local specID, _, _, _ = GetSpecializationInfo(GetSpecialization())
					member.specID = specID
					member.classID = miog.CLASSFILE_TO_ID[classFile] or select(2, UnitClassBase(unitID))
					member.role = member.role or GetSpecializationRoleByID(member.specID)

				end

			end

			if(member.classID) then
				groupSystem.classCount[member.classID] = groupSystem.classCount[member.classID] and groupSystem.classCount[member.classID] + 1 or 1

			end

			if(member.role ~= "NONE") then
				groupSystem.roleCount[member.role] = groupSystem.roleCount[member.role] + 1

			end

			updateSpecFrames()

		else
			--Unit does not exist

		end

	end

	if(numOfMembers < 6) then
		miog.mainFrame.titleBar.groupMemberListing.FontString:SetText("")

	else
		miog.mainFrame.titleBar.groupMemberListing.FontString:SetText(groupSystem.roleCount["TANK"] .. "/" .. groupSystem.roleCount["HEALER"] .. "/" .. groupSystem.roleCount["DAMAGER"])

	end

	local keys = {}

	for key, _ in pairs(groupSystem.classCount) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b) return groupSystem.classCount[a] > groupSystem.classCount[b] end)

	local counter = 1

	for _, classID in ipairs(keys) do
		local classCount = groupSystem.classCount[classID]
		local currentClassFrame = miog.mainFrame.classPanel.classFrames[classID]
		currentClassFrame.layoutIndex = counter
		currentClassFrame.FontString:SetText(classCount > 0 == true and classCount or "")
		currentClassFrame.Texture:SetDesaturated(classCount > 0 == false and true or false)

		if(classCount > 0) then
			local rPerc, gPerc, bPerc = GetClassColor(miog.CLASSES[classID].name)
			miog.createFrameBorder(currentClassFrame, 1, rPerc, gPerc, bPerc, 1)

		else
			miog.createFrameBorder(currentClassFrame, 1, 0, 0, 0, 1)

		end

		counter = counter + 1

		miog.mainFrame.classPanel:MarkDirty()

	end

	updateSpecFrames()

	checkCoroutineStatus()

end

local function insertLFGInfo()
	local activityInfo = C_LFGList.GetActivityInfoTable(miog.F.ACTIVE_ENTRY_INFO.activityID)

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

miog.OnEvent = function(_, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		local isLogin, isReload = ...

		updateRosterInfoData()

		hideAllFrames()

	elseif(event == "PLAYER_LOGIN") then
		miog.createMainFrame()
		miog.loadSettings()

		C_MythicPlus.RequestCurrentAffixes()

		LFGListFrame.ApplicationViewer:HookScript("OnShow", function(self) self:Hide() miog.mainFrame:Show() end)
		--LFGListFrame.ApplicationViewer = miog.mainFrame

		if(IsAddOnLoaded("RaiderIO")) then
			getRioProfile = RaiderIO.GetProfile
			miog.F.IS_RAIDERIO_LOADED = true

			if(miog.mainFrame.raiderIOAddonIsLoadedFrame) then
				miog.mainFrame.raiderIOAddonIsLoadedFrame:Hide()

			end
		end

	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then --LISTING CHANGES
		miog.F.ACTIVE_ENTRY_INFO = C_LFGList.GetActiveEntryInfo()

		if(miog.F.ACTIVE_ENTRY_INFO) then
			insertLFGInfo()
		end

		if(... == nil) then --DELIST
			if not(miog.F.ACTIVE_ENTRY_INFO) then
				if(queueTimer) then
					queueTimer:Cancel()

				end

				resetArrays()
				fullRelease()

				miog.mainFrame.infoPanel.timerFrame.FontString:SetText("00:00:00")

				miog.mainFrame:Hide()

				if(miog.F.WEEKLY_AFFIX == nil) then
					miog.setAffixes()

				end
			end
		else
			if(... == true) then --NEW LISTING
				MIOG_QueueUpTime = GetTimePreciseSec()
				expandedFrameList = {}

			elseif(... == false) then --RELOAD, LOADING SCREENS OR SETTINGS EDIT
				MIOG_QueueUpTime = (MIOG_QueueUpTime and MIOG_QueueUpTime > 0) and MIOG_QueueUpTime or GetTimePreciseSec()

			end

			queueTimer = C_Timer.NewTicker(1, function()
				miog.mainFrame.infoPanel.timerFrame.FontString:SetText(miog.secondsToClock(GetTimePreciseSec() - MIOG_QueueUpTime))

			end)

			miog.mainFrame:Show()

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

    elseif(event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
		if(not miog.F.WEEKLY_AFFIX) then
			C_MythicPlus.GetCurrentAffixes() -- Safety call, so Affixes are 100% available

			if(miog.mainFrame and miog.mainFrame.infoPanel) then
				miog.setAffixes()

				miog.F.CURRENT_SEASON = miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason()]
				miog.F.PREVIOUS_SEASON = miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]

			end

        end

	elseif(event == "GROUP_JOINED" or event == "GROUP_LEFT") then
		miog.checkIfCanInvite()

		updateRosterInfoData()

	elseif(event == "PARTY_LEADER_CHANGED") then
		miog.checkIfCanInvite()

	elseif(event == "GROUP_ROSTER_UPDATE") then
		miog.checkIfCanInvite()

		updateRosterInfoData()

	elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local guid = UnitGUID(...)
		if(guid) then
			if(groupSystem.groupMember[guid] and not inspectQueue[guid]) then
				inspectQueue[guid] = ...
				checkCoroutineStatus()

			end
		end

	elseif(event == "INSPECT_READY") then
		if(groupSystem.groupMember[...] or inspectQueue[...]) then
			inspectQueue[...] = nil

			local member = groupSystem.groupMember[...]
			local specID = GetInspectSpecialization(member.unitID)
			member.specID = specID ~= 0 and specID or nil
			groupSystem.inspectedGUIDs[...] = specID

			if(not member.classID) then
				member.classID = select(2, UnitClassBase(member.unitID))

			end

			if(not member.role) then
				local tempRole = GetSpecializationRoleByID(member.specID)
				member.role = tempRole == "NONE" and "DAMAGER" or tempRole

			end

			if(member.specID ~= nil and miog.CLASSES[member.classID] and (member.role == "TANK" or member.role == "HEALER" or member.role == "DAMAGER")) then
				updateSpecFrames()

			else
				--RE-NOTIFY FOR GUID, DATA MISSING FROM INSPECT
				groupSystem.inspectedGUIDs[...] = nil

			end

			checkCoroutineStatus(true)

		else
			local unitID = UnitTokenFromGUID(...)
			local lfgState = miog.checkLFGState()

			---@diagnostic disable-next-line: param-type-mismatch
			if(lfgState == "raid" and UnitInRaid(unitID) or lfgState == "party" and UnitInParty(unitID)) then
				createGroupMemberEntry(..., unitID)
			end

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

	elseif(command == "debugon") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")


	elseif(command == "debugoff") then
		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false
		fullRelease()
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
				fullRelease()
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
		fullRelease()
		resetArrays()

	else
		miog.mainFrame:Show()

	end
end
SlashCmdList["MIOG"] = handler

hooksecurefunc("LFGListFrame_SetActivePanel", function(selfFrame, panel)
	if(panel == LFGListFrame.ApplicationViewer) then
		--LFGListFrame.ApplicationViewer:Hide()
		--miog.mainFrame:Show()
	else
		miog.mainFrame:Hide()
	end
end)

hooksecurefunc("NotifyInspect", function() lastNotifyTime = GetTimePreciseSec() end)