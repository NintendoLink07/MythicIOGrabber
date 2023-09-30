local addonName, miog = ...

local addonApplicantList = {}
local detailExpandedList = {}

local latestApplicantFrame
local latestEntryFrame
local queueTimer

--- SAVED VARIABLES

QueueUpTime = 0

---

local function timeInQueue()
	local time = miog.secondsToClock(GetTimePreciseSec() - QueueUpTime)
	miog.mainFrame.statusBar.timerString:SetText(time)
end

local function refreshFunction()
	miog.releaseAllTemporaryPools()

	latestEntryFrame = nil
	latestApplicantFrame = nil

	addonApplicantList = {}
end

local function changeApplicantStatus(applicantID, frame, string, color)
	if(frame.inviteButton) then
		frame.inviteButton:Disable()
	end

	for _, entryFrame in pairs(frame.entryFrames) do
		entryFrame.statusString:Show()
		entryFrame.statusString.backgroundColor:Show()
		entryFrame.statusString:SetText(WrapTextInColorCode(string, color))
	end

	detailExpandedList[applicantID] = nil

	if(string == "INVITED") then
		addonApplicantList[applicantID]["creationStatus"] = "invited"
	else
		addonApplicantList[applicantID]["creationStatus"] = "canBeRemoved"
	end
end

local function createEntryFrame(applicantID, debug)
	local applicantData = C_LFGList.GetApplicantInfo(applicantID)

	if(debug) then
		applicantData = {applicantID = applicantID, applicationStatus = "applied", numMembers = random(1, 4), isNew = true, comment = "Heiho, heiho, wir sind vergnügt und froh. Johei, johei, die Arbeit ist vorbei.", displayOrderID = 1}
	end

	local applicantsFrame = miog.createBaseFrame("temporary", "BackdropTemplate", miog.mainFrame.mainScrollFrame.mainContainer, miog.mainFrame.mainScrollFrame:GetWidth(), miog.C.ENTRY_FRAME_SIZE * applicantData.numMembers + applicantData.numMembers * miog.F.PX_SIZE_1() + 1)
	applicantsFrame.entryFrames = {}
	applicantsFrame.applicantID = applicantID

	miog.createFrameBorder(applicantsFrame, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

	if(not latestApplicantFrame) then
		applicantsFrame:SetPoint("TOP", miog.mainFrame.mainScrollFrame.mainContainer, "TOP")
	else
		applicantsFrame:SetPoint("TOPLEFT", latestApplicantFrame, "BOTTOMLEFT", 0, 3*-PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1))
	end

	local activityID = C_LFGList.GetActiveEntryInfo().activityID

	for index = 1, applicantData.numMembers, 1 do
		local fullName, englishClassName, _, _, ilvl, honor, tank, healer, damager, assignedRole, friend, dungeonScore = C_LFGList.GetApplicantMemberInfo(applicantID, index)

		if(fullName or debug) then
			local bestDungeonScoreForListing

			if(debug) then
				local name, realm = UnitFullName("player")
				fullName = name .. "-" .. realm
				ilvl = random(400, 450) + 0.5
				dungeonScore = random(1, 4000)
				englishClassName = UnitClassBase("player")
				assignedRole = "DAMAGER"
				tank = false
				healer = false
				damager = true
				friend = true
				bestDungeonScoreForListing = {finishedSuccess = true, bestRunLevel = 99, mapName = "Big Dick Land"}
			else
				bestDungeonScoreForListing = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, index, activityID)
			end

			local result = miog.simpleSplit(fullName, "-")

			local profile
			local mythicKeystoneProfile
			local dungeonProfile
			
			if(IsAddOnLoaded("RaiderIO")) then
				profile = RaiderIO.GetProfile(result[1], result[2], miog.C.REGIONS[GetCurrentRegion()])
				
				if(profile ~= nil) then
					mythicKeystoneProfile = profile.mythicKeystoneProfile

					if(mythicKeystoneProfile ~= nil) then
						dungeonProfile = mythicKeystoneProfile.sortedDungeons

						if(dungeonProfile ~= nil) then
							table.sort(dungeonProfile, function(k1, k2) return k1.dungeon.index < k2.dungeon.index end)
						end
					end
					
				end
			end

			local entryFrame = miog.createBaseFrame("temporary", "BackdropTemplate", applicantsFrame, applicantsFrame:GetWidth()-2, miog.C.ENTRY_FRAME_SIZE)
			entryFrame.active = false

			if(not latestEntryFrame) then
				entryFrame:SetPoint("TOP", applicantsFrame, "TOP", 0, -PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1))
			else
				if(index > 1) then
					entryFrame:SetPoint("TOP", applicantsFrame.entryFrames[index-1], "BOTTOM", 0, -PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1))
				end
			end

			applicantsFrame.entryFrames[index] = entryFrame

			entryFrame.linkBox = miog.createBaseFrame("temporary", "InputBoxTemplate", WorldFrame, 250, 20)
			entryFrame.linkBox:SetFont(miog.fonts["libMono"], 7, "OUTLINE")
			entryFrame.linkBox:SetPoint("CENTER")
			entryFrame.linkBox:SetAutoFocus(true)
			entryFrame.linkBox:SetScript("OnKeyDown", function(editBoxSelf, key) if(key == "ESCAPE") then entryFrame.linkBox:Hide() entryFrame.linkBox:ClearFocus() end end)
			entryFrame.linkBox:Hide()
			entryFrame:SetScript("OnMouseDown", function(self, button)
				if(button == "RightButton") then
					local link = "https://raider.io/characters/" .. miog.C.REGIONS[GetCurrentRegion()] .. "/" .. result[2] .. "/" .. result[1]

					entryFrame.linkBox:SetAutoFocus(true)
					entryFrame.linkBox:SetText(link)
					entryFrame.linkBox:HighlightText()

					entryFrame.linkBox:Show()
					entryFrame.linkBox:SetAutoFocus(false)
				end
			end)

			entryFrame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=false} )
			entryFrame:SetBackdropColor(CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA())

			latestEntryFrame = entryFrame
			
			local dataFrameDungeons = miog.createBaseFrame("temporary", "BackdropTemplate", entryFrame, entryFrame:GetWidth()*0.52, miog.C.FULL_SIZE)
			dataFrameDungeons:SetPoint("TOPLEFT", entryFrame, "TOPLEFT", 0, -miog.C.ENTRY_FRAME_SIZE - 2)
			--dataFrameDungeons:SetFrameStrata("HIGH")
			dataFrameDungeons.textLines = {}
			dataFrameDungeons:Hide()

			entryFrame.progress = dataFrameDungeons
			
			local dataFrameGeneralInfo = miog.createBaseFrame("temporary", "BackdropTemplate", entryFrame, entryFrame:GetWidth()*0.48, miog.C.FULL_SIZE)
			dataFrameGeneralInfo:SetPoint("TOPLEFT", dataFrameDungeons, "TOPRIGHT")
			--dataFrameGeneralInfo:SetFrameStrata("HIGH")
			dataFrameGeneralInfo.textLines = {}
			dataFrameGeneralInfo:Hide()

			entryFrame.info = dataFrameGeneralInfo

			local detailsButton = miog.createBaseFrame("temporary", "UICheckButtonTemplate", entryFrame, miog.C.ENTRY_FRAME_SIZE + 2, miog.C.ENTRY_FRAME_SIZE + 2)
			detailsButton:SetPoint("TOPLEFT", entryFrame, "TOPLEFT", 0, 1)
			detailsButton:RegisterForClicks("LeftButtonDown")
			detailsButton:SetFrameStrata("DIALOG")
			detailsButton:SetScript("OnClick", function(self, button, down)

				if(entryFrame.active == true) then
					entryFrame.progress:Hide()
					entryFrame.info:Hide()
					entryFrame:SetSize(entryFrame:GetWidth(), miog.C.ENTRY_FRAME_SIZE)
					applicantsFrame:SetSize(applicantsFrame:GetWidth(), applicantsFrame:GetHeight() - miog.C.FULL_SIZE - 2)
				else
					entryFrame.progress:Show()
					entryFrame.info:Show()
					entryFrame:SetSize(entryFrame:GetWidth(), miog.C.ENTRY_FRAME_SIZE + miog.C.FULL_SIZE + 2)
					applicantsFrame:SetSize(applicantsFrame:GetWidth(), applicantsFrame:GetHeight() + miog.C.FULL_SIZE + 2)
				end

				detailsButton:SetChecked(not entryFrame.active)
				detailExpandedList[applicantID] = not entryFrame.active
				entryFrame.active = not entryFrame.active
			end)

			if(detailExpandedList[applicantID]) then
				detailsButton:Click()
			end

			local allowedToInvite = C_PartyInfo.CanInvite()
			
			if(index == 1 and allowedToInvite or index == 1 and debug) then
				applicantsFrame.declineButton = miog.createBaseFrame("temporary", "UIButtonTemplate, BackdropTemplate", entryFrame, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE)
				applicantsFrame.declineButton:SetText(CreateTextureMarkup(136813, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE/2, miog.C.APPLICANT_BUTTON_SIZE/2, 0.1, 0.85, 0.15, 0.85))
				applicantsFrame.declineButton:SetPoint("TOPRIGHT", entryFrame, "TOPRIGHT")
				applicantsFrame.declineButton:SetFrameStrata("DIALOG")
				applicantsFrame.declineButton:RegisterForClicks("LeftButtonDown")
				applicantsFrame.declineButton:SetScript("OnClick", function(self, button)
					if(addonApplicantList[applicantID]["creationStatus"] == "added") then

						addonApplicantList[applicantID]["creationStatus"] = "canBeRemoved"
						addonApplicantList[applicantID]["appStatus"] = "declined"
						C_LFGList.DeclineApplicant(applicantID)

					elseif(addonApplicantList[applicantID]["creationStatus"] == "canBeRemoved") then
						miog.checkApplicantList(true, miog.defaultOptionSettings[3].value)
					end

				end)

				local declineButtonFontString = applicantsFrame.declineButton:GetFontString()
				if(declineButtonFontString) then
					declineButtonFontString:SetFont(miog.fonts["libMono"], miog.C.ENTRY_FRAME_SIZE, "OUTLINE")
				end

				applicantsFrame.inviteButton = miog.createBaseFrame("temporary", "UIButtonTemplate, BackdropTemplate", entryFrame, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE)
				applicantsFrame.inviteButton:SetText(CreateTextureMarkup(136814, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE/2, miog.C.APPLICANT_BUTTON_SIZE/2, 0.1, 0.85, 0.1, 0.95))
				applicantsFrame.inviteButton:SetPoint("TOPRIGHT", applicantsFrame.declineButton, "TOPLEFT")
				applicantsFrame.inviteButton:SetFrameStrata("DIALOG")
				applicantsFrame.inviteButton:RegisterForClicks("LeftButtonDown")
				applicantsFrame.inviteButton:SetScript("OnClick", function(self, button)
					C_LFGList.InviteApplicant(applicantID)
				end)

				local inviteButtonFontString = applicantsFrame.inviteButton:GetFontString()
				if(inviteButtonFontString) then
					inviteButtonFontString:SetFont(miog.fonts["libMono"], miog.C.ENTRY_FRAME_SIZE, "OUTLINE")
				end
			elseif(not allowedToInvite) then
				miog.mainFrame.mainScrollFrame:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)

			end

			if(index > 1) then
				local groupIcon = miog.createBaseTexture("temporary", 134148, entryFrame, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
				groupIcon:SetPoint("TOPRIGHT", entryFrame, "TOPRIGHT")
				groupIcon:SetTexCoord(0, 0.95, 0.05, 1)
			end

			--[[entryFrame.statusString = miog.createFontString("", entryFrame, miog.C.ENTRY_FRAME_SIZE)
			entryFrame.statusString:SetJustifyH("CENTER")
			entryFrame.statusString:SetJustifyV("CENTER")
			entryFrame.statusString:SetSize(entryFrame:GetSize())
			entryFrame.statusString:SetPoint("TOP", entryFrame, "TOP", 0, -1)
			entryFrame.statusString:SetDrawLayer("OVERLAY")
			entryFrame.statusString:Hide()

			entryFrame.statusString.backgroundColor = miog.createBaseTexture("temporary", nil, entryFrame, entryFrame:GetSize())
			entryFrame.statusString.backgroundColor:SetPoint("TOPLEFT", entryFrame, "TOPLEFT")
			entryFrame.statusString.backgroundColor:SetColorTexture(0.1, 0.1, 0.1, 0.7)
			entryFrame.statusString.backgroundColor:Hide()]]

			local shortName = strsub(result[1], 0, 20)
			local coloredSubName = WrapTextInColorCode(shortName, select(4, GetClassColor(englishClassName)))

			local nameString = miog.createFontString(coloredSubName, entryFrame, 11, entryFrame:GetWidth()*0.28, miog.C.ENTRY_FRAME_SIZE) --28%
			nameString:SetMouseMotionEnabled(true)
			nameString:SetPoint("LEFT", detailsButton, "RIGHT")
			nameString:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(entryFrame, "ANCHOR_CURSOR")
				GameTooltip:SetText(fullName)
				GameTooltip:Show()
			end)
			nameString:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)

			local commentTexture = miog.createBaseTexture("temporary", 1505953, entryFrame, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
			commentTexture:SetPoint("LEFT", nameString, "RIGHT", 3, 0)
			
			if(applicantData.comment == "") then
				commentTexture:Hide()
			end

			local roleTexture = miog.createBaseTexture("temporary", 2202478, entryFrame, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
			roleTexture:SetPoint("LEFT", commentTexture, "RIGHT", 3, 0)

			if(assignedRole == "DAMAGER") then
				roleTexture:SetTexCoord(0, 0.25, 0, 1)
			elseif(assignedRole == "HEALER") then
				roleTexture:SetTexCoord(0.25, 0.5, 0, 1)
			elseif(assignedRole == "TANK") then
				roleTexture:SetTexCoord(0.5, 0.75, 0, 1)
			end

			local primaryIndicator = miog.createFontString("", entryFrame, 12, miog.F.LISTED_CATEGORY_ID == 2 and entryFrame:GetWidth()*0.12 or entryFrame:GetWidth()*0.10, 10)
			primaryIndicator:SetPoint("LEFT", roleTexture, "RIGHT", 3, 0)

			local secondaryIndicator = miog.createFontString("", entryFrame, 12, miog.F.LISTED_CATEGORY_ID == 2 and entryFrame:GetWidth()*0.06 or entryFrame:GetWidth()*0.08, 10)
			secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 3, 0)
			
			if(miog.F.LISTED_CATEGORY_ID == 2) then
				primaryIndicator:SetText(WrapTextInColorCode(tostring(dungeonScore), C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore):GenerateHexColor()))
				
				local highestKeyForDungeon

				if(bestDungeonScoreForListing) then
					if(bestDungeonScoreForListing.finishedSuccess == true) then
						highestKeyForDungeon = WrapTextInColorCode(tostring(bestDungeonScoreForListing.bestRunLevel), miog.C.GREEN_COLOR)
					elseif(bestDungeonScoreForListing.finishedSuccess == false) then
						highestKeyForDungeon = WrapTextInColorCode(tostring(bestDungeonScoreForListing.bestRunLevel), miog.C.RED_COLOR)
					end
				else
					highestKeyForDungeon = WrapTextInColorCode(tostring(0), miog.C.RED_COLOR)
				end

				secondaryIndicator:SetText(highestKeyForDungeon)
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
									primaryIndicator:SetText(progressString)
								else
									secondaryIndicator:SetText(progressString)
								end
							else
								if(i == 1) then
									primaryIndicator:SetText("0/9")
								else
									secondaryIndicator:SetText("0/9")
								end
							end
						end
					else
						primaryIndicator:SetText(WrapTextInColorCode("---", miog.C.RED_COLOR))
						secondaryIndicator:SetText(WrapTextInColorCode("---", miog.C.RED_COLOR))
					end
				else
					primaryIndicator:SetText("0/9")
					secondaryIndicator:SetText("0/9")
				end
			elseif(miog.F.LISTED_CATEGORY_ID == 4 or miog.F.LISTED_CATEGORY_ID == 7 or miog.F.LISTED_CATEGORY_ID == 8 or miog.F.LISTED_CATEGORY_ID == 9) then
				local pvpRatingInfo
				if(debug) then
					pvpRatingInfo = {
						bracket = "2v2",
						rating = 3000,
						activityName = "XD",
						tier = "Elite X"
					}
				else
					pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, index, activityID)
				end
				primaryIndicator:SetText(WrapTextInColorCode(tostring(pvpRatingInfo.rating), C_ChallengeMode.GetDungeonScoreRarityColor(pvpRatingInfo.rating):GenerateHexColor()))

				local tierResult = miog.simpleSplit(pvpRatingInfo.tier, " ")
				secondaryIndicator:SetText(strsub(tierResult[1], 0, 2) .. "" .. tierResult[2])
			end
			
			local ilvlString = miog.createFontString(miog.round(ilvl, 1), entryFrame, 12, entryFrame:GetWidth()*0.135, 10)
			ilvlString:SetPoint("LEFT", secondaryIndicator, "RIGHT", 3, 0)

			local friendTexture = miog.createBaseTexture("temporary", 648207, entryFrame, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
			friendTexture:SetPoint("LEFT", ilvlString, "RIGHT")
			friendTexture:SetShown(friend or false)

			for lineIndex = 1, 8, 1 do
				local remainder = math.fmod(lineIndex, 2)

				entryFrame.progress.textLines[lineIndex] = miog.createTextLine(entryFrame.progress, lineIndex)
				entryFrame.progress.textLines[lineIndex].fontString = miog.createFontString("", entryFrame.progress.textLines[lineIndex], miog.C.TEXT_LINE_FONT_SIZE)
				entryFrame.progress.textLines[lineIndex].fontString:SetPoint("LEFT", entryFrame.progress.textLines[lineIndex], "LEFT")
				entryFrame.progress.textLines[lineIndex].fontString:SetSize(entryFrame.progress.textLines[lineIndex]:GetSize())
				entryFrame.progress.textLines[lineIndex].fontString = entryFrame.progress.textLines[lineIndex].fontString

				entryFrame.info.textLines[lineIndex] = miog.createTextLine(entryFrame.info, lineIndex)
				entryFrame.info.textLines[lineIndex].fontString = miog.createFontString("", entryFrame.info.textLines[lineIndex], miog.C.TEXT_LINE_FONT_SIZE)
				entryFrame.info.textLines[lineIndex].fontString:SetPoint("LEFT", entryFrame.info.textLines[lineIndex], "LEFT")
				entryFrame.info.textLines[lineIndex].fontString:SetSize(entryFrame.info.textLines[lineIndex]:GetSize())
				entryFrame.info.textLines[lineIndex].fontString = entryFrame.info.textLines[lineIndex].fontString

				if(remainder == 1) then
					entryFrame.progress.textLines[lineIndex]:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=false} )
					entryFrame.progress.textLines[lineIndex]:SetBackdropColor(CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())
					
					entryFrame.info.textLines[lineIndex]:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=false} )
					entryFrame.info.textLines[lineIndex]:SetBackdropColor(CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())
				end

				if(lineIndex == 1) then
					entryFrame.info.textLines[lineIndex].fontString:SetJustifyV("TOP")
					entryFrame.info.textLines[lineIndex].fontString:SetPoint("TOPLEFT", entryFrame.info.textLines[lineIndex], "TOPLEFT", 2, -1)
				else
					entryFrame.info.textLines[lineIndex].fontString:SetPoint("LEFT", entryFrame.info.textLines[lineIndex], "LEFT", 2, -1)
					entryFrame.info.textLines[lineIndex].fontString:SetSize(entryFrame.info.textLines[lineIndex]:GetSize())
				end

				entryFrame.progress.textLines[lineIndex] = entryFrame.progress.textLines[lineIndex]
				entryFrame.info.textLines[lineIndex] = entryFrame.info.textLines[lineIndex]
			end

			entryFrame.info.textLines[1].fontString:AdjustPointsOffset(0, -5)
			entryFrame.info.textLines[1].fontString:SetText(_G["COMMENTS_COLON"] .. " " .. applicantData.comment)
			entryFrame.info.textLines[1].fontString:SetSize(entryFrame.info.textLines[1]:GetWidth(), miog.C.FULL_SIZE*0.75)
			entryFrame.info.textLines[1].fontString:SetWordWrap(true)
			entryFrame.info.textLines[1].fontString:SetSpacing(miog.C.ENTRY_FRAME_SIZE - miog.C.TEXT_LINE_FONT_SIZE)

			entryFrame.info.textLines[7].fontString:SetText(_G["LFG_TOOLTIP_ROLES"])

			if(tank == true) then
				entryFrame.info.textLines[7].fontString:SetText(entryFrame.info.textLines[7].fontString:GetText() .. CreateTextureMarkup(2202478, 256, 64, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE, 0.5, 0.75, 0, 1))
			end
			if(healer == true) then
				entryFrame.info.textLines[7].fontString:SetText(entryFrame.info.textLines[7].fontString:GetText() .. CreateTextureMarkup(2202478, 256, 64, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE, 0.25, 0.5, 0, 1))
			end
			if(damager == true) then
				entryFrame.info.textLines[7].fontString:SetText(entryFrame.info.textLines[7].fontString:GetText() .. CreateTextureMarkup(2202478, 256, 64, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE, 0, 0.25, 0, 1))
			end

			if(profile) then --If Raider.IO is installed
				if(miog.F.LISTED_CATEGORY_ID == 2) then
					if(profile.mythicKeystoneProfile) then
						for lineIndex = 1, #profile.mythicKeystoneProfile.dungeons, 1 do
							local primaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and profile.mythicKeystoneProfile.tyrannicalDungeons[lineIndex] or miog.F.WEEKLY_AFFIX == 10 and profile.mythicKeystoneProfile.fortifiedDungeons[lineIndex] or 0
							local primaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and profile.mythicKeystoneProfile.tyrannicalDungeonUpgrades[lineIndex] or miog.F.WEEKLY_AFFIX == 10 and profile.mythicKeystoneProfile.fortifiedDungeonUpgrades[lineIndex] or 0
							local secondaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and profile.mythicKeystoneProfile.fortifiedDungeons[lineIndex] or miog.F.WEEKLY_AFFIX == 10 and profile.mythicKeystoneProfile.tyrannicalDungeons[lineIndex] or 0
							local secondaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and profile.mythicKeystoneProfile.fortifiedDungeonUpgrades[lineIndex] or miog.F.WEEKLY_AFFIX == 10 and profile.mythicKeystoneProfile.tyrannicalDungeonUpgrades[lineIndex] or 0

							if(dungeonProfile) then
								local textureString

								for _, icon in pairs(miog.dungeonIcons) do
									if(dungeonProfile[lineIndex].dungeon.name == icon[1]) then
										textureString = icon[2]
									end
								end

								local dungeonIconTexture = miog.createBaseTexture("temporary", textureString, entryFrame.progress.textLines[lineIndex], miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
								dungeonIconTexture:SetPoint("LEFT", entryFrame.progress.textLines[lineIndex], "LEFT")

								local dungeonNameFrame = miog.createBaseFrame("temporary", "BackdropTemplate", entryFrame.progress.textLines[lineIndex], entryFrame.progress.textLines[lineIndex]:GetWidth()*0.30, entryFrame.progress.textLines[lineIndex]:GetHeight())
								dungeonNameFrame:SetPoint("LEFT", dungeonIconTexture, "RIGHT", 2, 0)

								local dungeonString = miog.createFontString(dungeonProfile[lineIndex].dungeon.shortName .. ":", entryFrame.progress.textLines[lineIndex], miog.C.TEXT_LINE_FONT_SIZE)
								dungeonString:SetPoint("LEFT", dungeonNameFrame, "LEFT")
								dungeonString:SetSize(dungeonNameFrame:GetSize())

								local primaryFrame = miog.createBaseFrame("temporary", "BackdropTemplate", entryFrame.progress.textLines[lineIndex], entryFrame.progress.textLines[lineIndex]:GetWidth()*0.30, entryFrame.progress.textLines[lineIndex]:GetHeight())
								primaryFrame:SetPoint("LEFT", dungeonNameFrame, "RIGHT")

								local primaryText = WrapTextInColorCode(primaryDungeonLevel .. string.rep(miog.C.RIO_STAR_TEXTURE, debug and 3 or primaryDungeonChests), primaryDungeonChests > 0 and miog.C.GREEN_COLOR or primaryDungeonChests == 0 and miog.C.RED_COLOR or "0")
								local primaryString = miog.createFontString(primaryText, entryFrame.progress.textLines[lineIndex], miog.C.TEXT_LINE_FONT_SIZE)
								primaryString:SetPoint("LEFT", primaryFrame, "LEFT")
								primaryString:SetSize(primaryFrame:GetSize())

								local secondaryFrame = miog.createBaseFrame("temporary", "BackdropTemplate", entryFrame.progress.textLines[lineIndex], entryFrame.progress.textLines[lineIndex]:GetWidth()*0.30, entryFrame.progress.textLines[lineIndex]:GetHeight())
								secondaryFrame:SetPoint("LEFT", primaryFrame, "RIGHT")

								local secondaryText = WrapTextInColorCode(secondaryDungeonLevel .. string.rep(miog.C.RIO_STAR_TEXTURE, debug and 3 or secondaryDungeonChests), secondaryDungeonChests > 0 and miog.C.GREEN_COLOR or secondaryDungeonChests == 0 and miog.C.RED_COLOR or "0")
								local secondaryString = miog.createFontString(secondaryText, entryFrame.progress.textLines[lineIndex], miog.C.TEXT_LINE_FONT_SIZE)
								secondaryString:SetPoint("LEFT", secondaryFrame, "LEFT")
								secondaryString:SetSize(secondaryFrame:GetSize())
							end
						end

						entryFrame.progress.textLines[6].fontString:SetText(
							WrapTextInColorCode(profile.mythicKeystoneProfile.keystoneFivePlus or "0", _G["ITEM_QUALITY_COLORS"][2].color:GenerateHexColor()) .. " - " ..
							WrapTextInColorCode(profile.mythicKeystoneProfile.keystoneTenPlus or "0", _G["ITEM_QUALITY_COLORS"][3].color:GenerateHexColor()) .. " - " ..
							WrapTextInColorCode(profile.mythicKeystoneProfile.keystoneFifteenPlus or "0", _G["ITEM_QUALITY_COLORS"][4].color:GenerateHexColor()) .. " - " ..
							WrapTextInColorCode(profile.mythicKeystoneProfile.keystoneTwentyPlus or "0", _G["ITEM_QUALITY_COLORS"][5].color:GenerateHexColor())
						)
						entryFrame.progress.textLines[6].fontString:SetPoint("LEFT", entryFrame.info.textLines[6], "LEFT", 2, 0)

						if(profile.mythicKeystoneProfile.mainCurrentScore) then
							if(profile.mythicKeystoneProfile.mainCurrentScore > 0) then
								entryFrame.info.textLines[8].fontString:SetText(WrapTextInColorCode("Main: " .. (profile.mythicKeystoneProfile.mainCurrentScore), _G["ITEM_QUALITY_COLORS"][6].color:GenerateHexColor()))
							else
								entryFrame.info.textLines[8].fontString:SetText(WrapTextInColorCode("Main Char", _G["ITEM_QUALITY_COLORS"][7].color:GenerateHexColor()))
							end
						else
							entryFrame.info.textLines[8].fontString:SetText(WrapTextInColorCode("Main Score N/A", _G["ITEM_QUALITY_COLORS"][6].color:GenerateHexColor()))
						end
					else
						entryFrame.progress.textLines[1].fontString:SetText(WrapTextInColorCode("NO M+ DATA", "FFFF0000"))
						entryFrame.progress.textLines[1].fontString:SetPoint("LEFT", entryFrame.progress.textLines[1], "LEFT", 2, 0)
					end
				elseif(miog.F.LISTED_CATEGORY_ID == 3) then
					if(profile.raidProfile) then

						local lineIndex = 1

						local ordinal = nil

						for raidIndex, raidProgressInfo in ipairs(profile.raidProfile.progress) do

							local bossCount = raidProgressInfo.raid.bossCount
							local difficulty = miog.C.DIFFICULTY[raidProgressInfo.difficulty]
							local progressCount = raidProgressInfo.progressCount or 0

							if(raidProgressInfo.raid.ordinal ~= ordinal) then

								ordinal = raidProgressInfo.raid.ordinal
								local textureString = miog.RAID_ICONS[raidProgressInfo.raid.shortName][bossCount + 1]

								local progressString =  WrapTextInColorCode(difficulty.singleChar .. ": " .. progressCount .. "/" .. bossCount, difficulty.color:GenerateHexColor())

								local dungeonIconTexture = miog.createBaseTexture("temporary", textureString, entryFrame.progress.textLines[lineIndex], miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
								dungeonIconTexture:SetPoint("LEFT", entryFrame.progress.textLines[lineIndex], "LEFT")
								
								entryFrame.progress.textLines[lineIndex].fontString:SetText(progressString)
								entryFrame.progress.textLines[lineIndex].fontString:SetPoint("LEFT", dungeonIconTexture, "RIGHT", 2, 0)
								
								entryFrame.progress.textLines[lineIndex+1]:SetHeight(miog.C.ENTRY_FRAME_SIZE * 1.5)
								entryFrame.progress.textLines[lineIndex+1].textures = {}

								local desaturated = true

								for i = 1, bossCount, 1 do
									local bossFrame = miog.createBaseFrame("temporary", "BackdropTemplate", entryFrame.progress.textLines[lineIndex+1], entryFrame.progress.textLines[lineIndex+1]:GetHeight() - 2, entryFrame.progress.textLines[lineIndex+1]:GetHeight() - 2)
									bossFrame:SetPoint(
									entryFrame.progress.textLines[lineIndex+1].textures[i-5] and "TOPLEFT" or "LEFT", 
									entryFrame.progress.textLines[lineIndex+1].textures[i-5] or entryFrame.progress.textLines[lineIndex+1].textures[i-1] or entryFrame.progress.textLines[lineIndex+1],
									entryFrame.progress.textLines[lineIndex+1].textures[i-5] and "BOTTOMLEFT" or entryFrame.progress.textLines[lineIndex+1].textures[i-1] and "RIGHT" or "LEFT", (i > 1 and i < 6) and 2 or 0, i > 5 and - 2 or 0)

									local kills = raidProgressInfo.killsPerBoss[i]

									if(kills > 0) then
										desaturated = false
										miog.createFrameBorder(bossFrame, 2, difficulty.color:GetRGBA())
									end

									local bossTexture = miog.createBaseTexture("temporary", miog.RAID_ICONS[raidProgressInfo.raid.shortName][i], entryFrame.progress.textLines[lineIndex+1])
									bossTexture:SetPoint("TOPLEFT", bossFrame, "TOPLEFT")
									bossTexture:SetSize(bossFrame:GetSize())
									bossTexture:SetDesaturated(desaturated)

									bossFrame.texture = bossTexture

									entryFrame.progress.textLines[lineIndex+1].textures[i] = bossFrame
								end
							else
								local progressString =  WrapTextInColorCode(difficulty.singleChar .. ": " .. progressCount .. "/" .. bossCount, difficulty.color:GenerateHexColor())
								entryFrame.progress.textLines[lineIndex].fontString:SetText(entryFrame.progress.textLines[lineIndex].fontString:GetText() .. " | " .. progressString)

								for i = 1, bossCount, 1 do
									local prevKills = profile.raidProfile.progress[raidIndex-1].killsPerBoss[i]

									if(prevKills == 0) then
										local kills = raidProgressInfo.killsPerBoss[i]

										if(kills > 0) then
											miog.createFrameBorder(entryFrame.progress.textLines[lineIndex+1].textures[i], 2, difficulty.color:GetRGBA())
											entryFrame.progress.textLines[lineIndex+1].textures[i].texture:SetDesaturated(false)
										end
									end
								end

								lineIndex = lineIndex + 4
							end
							
							if(raidIndex == 3 and profile.raidProfile.previousProgress[2]) then
								difficulty = miog.C.DIFFICULTY[profile.raidProfile.previousProgress[2].difficulty]
								progressCount = profile.raidProfile.previousProgress[2].progressCount

								local progressString =  WrapTextInColorCode(difficulty.singleChar .. ": " .. progressCount .. "/" .. bossCount, difficulty.color:GenerateHexColor())
								entryFrame.progress.textLines[lineIndex].fontString:SetText(entryFrame.progress.textLines[lineIndex].fontString:GetText() .. " | " .. progressString)
							end
						end

						
						if(profile.raidProfile.mainProgress) then
							local mainProgressText = ""

							for _, raidProgressInfo in ipairs(profile.raidProfile.mainProgress) do
								local difficulty = miog.C.DIFFICULTY[raidProgressInfo.difficulty]
								mainProgressText = mainProgressText .. WrapTextInColorCode(difficulty.singleChar .. ": " .. raidProgressInfo.progressCount .. "/" .. raidProgressInfo.raid.bossCount, difficulty.color:GenerateHexColor()) .. " "
							end
							
							entryFrame.info.textLines[8].fontString:SetText(WrapTextInColorCode("Main: " .. mainProgressText, _G["ITEM_QUALITY_COLORS"][6].color:GenerateHexColor()))
						else
							entryFrame.info.textLines[8].fontString:SetText(WrapTextInColorCode("Main Char", _G["ITEM_QUALITY_COLORS"][7].color:GenerateHexColor()))
						end
					else
						entryFrame.progress.textLines[1].fontString:SetText(WrapTextInColorCode("NO RAIDING DATA", "FFFF0000"))
						entryFrame.progress.textLines[1].fontString:SetPoint("LEFT", entryFrame.progress.textLines[1], "LEFT", 2, 0)
					end
				end
			else -- If RaiderIO is not installed
					entryFrame.progress.textLines[1].fontString:SetText(WrapTextInColorCode("NO RAIDER.IO DATA", "FFFF0000"))
					entryFrame.progress.textLines[1].fontString:SetPoint("LEFT", entryFrame.progress.textLines[1], "LEFT", 2, 0)
			end
		end
	end

	addonApplicantList[applicantID]["frame"] = applicantsFrame
	addonApplicantList[applicantID]["creationStatus"] = "added"
	latestEntryFrame = nil
	latestApplicantFrame = applicantsFrame
end

local function iterateThroughList(list, orderedFor)
	if(orderedFor == "score") then
		table.sort(list, function (k1, k2) return k1["scoreNumber"] > k2["scoreNumber"] end)
	elseif(orderedFor == "appID") then
		table.sort(list, function (k1, k2) return k1["applicantID"] < k2["applicantID"] end)
	end

	for _, listEntry in ipairs(list) do
		local applicantData = C_LFGList.GetApplicantInfo(listEntry["applicantID"])

		if(applicantData.applicationStatus == "applied" and addonApplicantList[listEntry["applicantID"]] == nil) then
			addonApplicantList[listEntry["applicantID"]] = {
				["creationStatus"] = "inProgress",
				["appStatus"] = applicantData.applicationStatus,
				["frame"] = nil,
			}

			createEntryFrame(listEntry["applicantID"])

		elseif(applicantData.applicationStatus == "applied" and addonApplicantList[listEntry["applicantID"]] ~= nil ) then
			
		elseif(applicantData.applicationStatus ~= "applied") then
		end
	end
end

miog.checkApplicantList = function(needRefresh, needSort)
	local allApplicants = C_LFGList:GetApplicants()

	if(needRefresh) then
		refreshFunction()
	end

	local tankList = {}
	local healerList = {}
	local dpsList = {}
	local fullList = {}

	for _, applicantID in ipairs(allApplicants) do

		local applicantData = C_LFGList.GetApplicantInfo(applicantID)

		if(applicantData) then
			local hasAllApplicantData = true

			for i = 1, applicantData.numMembers, 1 do
				if(C_LFGList.GetApplicantMemberInfo(applicantID, i) == nil) then
					hasAllApplicantData = false
					break
				end
			end

			local _, _, _, _, _, _, _, _, _, assignedRole, _, dungeonScore = C_LFGList.GetApplicantMemberInfo(applicantID, 1)

			if(hasAllApplicantData) then
				if(assignedRole == "DAMAGER" and miog.F.SHOW_DPS or assignedRole == "TANK" and miog.F.SHOW_TANKS or assignedRole == "HEALER" and miog.F.SHOW_HEALERS) then
					if(needSort) then

						local scoreNumber = dungeonScore

						if(applicantData and assignedRole) then
							if(assignedRole == "DAMAGER") then
								dpsList[#dpsList+1] = {["applicantID"] = applicantID, ["scoreNumber"] = scoreNumber}
							elseif(assignedRole == "HEALER") then
								healerList[#healerList+1] = {["applicantID"] = applicantID, ["scoreNumber"] = scoreNumber}
							elseif(assignedRole == "TANK") then
								tankList[#tankList+1] = {["applicantID"] = applicantID, ["scoreNumber"] = scoreNumber}
							end
						end
					else
						fullList[#fullList+1] = {["applicantID"] = applicantID,}
					end
				end
			end
		end
	end

	if(needSort) then
		iterateThroughList(tankList, "score")
		iterateThroughList(healerList, "score")
		iterateThroughList(dpsList, "score")
		
		miog.mainFrame.mainScrollFrame:SetVerticalScroll(0)
	else
		iterateThroughList(fullList, "appID")
	end
end

local function createFullEntries(iterations)
	for i = 1, iterations, 1 do
		local applicantID = random(1000, 9999)

		addonApplicantList[applicantID] = {
			["creationStatus"] = "inProgress",
			["appStatus"] = "applied",
			["frame"] = nil,
		}

		createEntryFrame(applicantID, true)
	end

	miog.mainFrame:Show()
end


local function setUpSettingString(activeEntryInfo, activityInfo)
	local settingStringInfo = activityInfo.fullName
	miog.mainFrame.titleBar.titleString:SetText(activeEntryInfo.name)

	if(activeEntryInfo.privateGroup == true) then
		settingStringInfo = settingStringInfo .. " - Private Group"
	end

	if(activeEntryInfo.playstyle) then
		local playStyleString = (activityInfo.isMythicPlusActivity and miog.playStyleStrings["mPlus"..activeEntryInfo.playstyle]) or
		(activityInfo.isMythicActivity and miog.playStyleStrings["mZero"..activeEntryInfo.playstyle]) or
		(activityInfo.isCurrentRaidActivity and miog.playStyleStrings["raid"..activeEntryInfo.playstyle]) or
		((activityInfo.isRatedPvpActivity or activityInfo.isPvpActivity) and miog.playStyleStrings["pvp"..activeEntryInfo.playstyle])

		settingStringInfo = settingStringInfo .. " - " .. playStyleString
	end

	if(activeEntryInfo.requiredDungeonScore) then
		settingStringInfo = settingStringInfo .. "\n" .. activeEntryInfo.requiredDungeonScore .. " Rating"
	end

	if(activeEntryInfo.requiredPvpRating) then
		settingStringInfo = settingStringInfo .. "\n" .. activeEntryInfo.requiredPvpRating .. " Rating"
	end

	if(activeEntryInfo.requiredItemLevel > 0) then 
		settingStringInfo = settingStringInfo .. "\n" .. activeEntryInfo.requiredItemLevel .. " I-Lvl"
	end

	if(activeEntryInfo.voiceChat ~= "") then
		LFGListFrame.EntryCreation.VoiceChat.CheckButton:SetChecked(true)
	end

	if(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked()) then
		miog.mainFrame.titleBar.voiceChat:Show()
	else
		miog.mainFrame.titleBar.voiceChat:Hide()
	end
	
	if(activeEntryInfo.isCrossFactionListing == true) then
		miog.mainFrame.titleBar.faction:SetText(
			CreateTextureMarkup(2173919, 56, 56, miog.mainFrame.titleBar:GetHeight(), miog.mainFrame.titleBar:GetHeight(), 0, 1, 0, 1)..
			CreateTextureMarkup(2173920, 56, 56, miog.mainFrame.titleBar:GetHeight(), miog.mainFrame.titleBar:GetHeight(), 0, 1, 0, 1)
		)
		miog.mainFrame.titleBar.faction:SetSize(miog.mainFrame.titleBar:GetHeight()*2, miog.mainFrame.titleBar:GetHeight())
	else
		local playerFaction = UnitFactionGroup("player")

		if(playerFaction == "Alliance") then
			miog.mainFrame.titleBar.faction:SetText(CreateTextureMarkup(2173919, 56, 56, miog.mainFrame.titleBar:GetHeight(), miog.mainFrame.titleBar:GetHeight(), 0, 1, 0, 1))
		elseif(playerFaction == "Horde") then
			miog.mainFrame.titleBar.faction:SetText(CreateTextureMarkup(2173920, 56, 56, miog.mainFrame.titleBar:GetHeight(), miog.mainFrame.titleBar:GetHeight(), 0, 1, 0, 1))
		end

		miog.mainFrame.titleBar.faction:SetSize(miog.mainFrame.titleBar:GetHeight(), miog.mainFrame.titleBar:GetHeight())
	end

	return settingStringInfo
end

local function refreshSpecIcons()
	if(miog.defaultOptionSettings[1].value == true) then
		for _, scrollTarget in LFGListFrame.SearchPanel.ScrollBox:EnumerateFrames() do

			local resultID = scrollTarget.resultID

			if(resultID) then
				local searchResultData = C_LFGList.GetSearchResultInfo(resultID)

				if(searchResultData) then
					local members = {}

					for i = 1, searchResultData.numMembers do
						local role, class, classLocalized, specLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i)

						local classColor = RAID_CLASS_COLORS[class]
						
						local numSpecs = GetNumSpecializationsForClassID(miog.classTable[class])
						for specIndex = 1, numSpecs, 1 do
							local _, name, _, icon, _, _, _ = GetSpecializationInfoForClassID(miog.classTable[class], specIndex)

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

					if(not miog.defaultOptionSettings[2].value) then
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

					if(miog.defaultOptionSettings[2].value) then
						for k, v in ipairs(emptyMembers) do
							table.insert(members, v)
						end
						miog.sortTableForRoleAndClass(members)
					else
						miog.sortTableForRoleAndClass(emptyMembers)
						for k, v in ipairs(emptyMembers) do
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

								for i, child in pairs(children) do
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
end

miog.OnEvent = function(self, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		miog.releaseAllTemporaryPools()
	elseif(event == "PLAYER_LOGIN") then

		miog.F.AFFIX_UPDATE_COUNTER = 0

        C_MythicPlus.RequestMapInfo()

		LFGListFrame.ApplicationViewer:Hide()
		hooksecurefunc("LFGListFrame_SetActivePanel", function(selfFrame, panel)
			if(panel == LFGListFrame.ApplicationViewer) then
				LFGListFrame.ApplicationViewer:Hide()
				miog.mainFrame:Show()
			else
				miog.mainFrame:Hide()
			end
		end)
		LFGListFrame:HookScript("OnShow", function(selfFrame) if(selfFrame.activePanel == LFGListFrame.ApplicationViewer) then miog.mainFrame:Show() end end)

		hooksecurefunc("LFGListSearchEntry_Update", refreshSpecIcons)

		if(LFGListFrame.ApplicationViewer.Inset.Bg:GetTexture()) then
			miog.mainFrame.backgroundTexture:Show()
			miog.mainFrame.infoPanel.backgroundTexture:SetPoint("TOPLEFT", miog.mainFrame.infoPanel, "TOPLEFT", 0, -1)
			miog.mainFrame.infoPanel.backgroundTexture:SetPoint("BOTTOMRIGHT", miog.mainFrame.infoPanel, "BOTTOMRIGHT", 0 , 1)
		else
			miog.mainFrame.infoPanel.backgroundTexture:SetPoint("TOPLEFT", miog.mainFrame.infoPanel, "TOPLEFT", 1, -1)
			miog.mainFrame.infoPanel.backgroundTexture:SetPoint("BOTTOMRIGHT", miog.mainFrame.infoPanel, "BOTTOMRIGHT", -1 , 1)
		end
	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then --LISTING CHANGES

		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		local activityInfo

		if(C_LFGList.HasActiveEntryInfo() ==  true) then
			activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)

			miog.F.LISTED_CATEGORY_ID = activityInfo.categoryID

			if(miog.F.LISTED_CATEGORY_ID == 2) then
				miog.mainFrame.affixes:Show()
			else
				miog.mainFrame.affixes:Hide()
			end

			miog.mainFrame.settingScrollFrame.settingContainer.settingString:SetHeight(2500)
			miog.mainFrame.settingScrollFrame.settingContainer.settingString:SetText(setUpSettingString(activeEntryInfo, activityInfo))
			miog.mainFrame.settingScrollFrame.settingContainer.settingString:SetHeight(miog.mainFrame.settingScrollFrame.settingContainer.settingString:GetStringHeight())
		end

		if(... == nil) then
			if not(activeEntryInfo) then
				if(queueTimer) then
					queueTimer:Cancel()

				end

				miog.mainFrame.statusBar.timerString:SetText("00:00:00")

				miog.mainFrame.settingScrollFrame.settingContainer.settingString:SetText("")

				miog.mainFrame:Hide()

				if(miog.F.WEEKLY_AFFIX == nil) then
					miog.getAffixes()
				end
			--else DECLINE SOMEONE, WHY HERE THOUGH LOL

			end
		else
			detailExpandedList = {}
			if(... == true) then --NEW LISTING
				QueueUpTime = GetTimePreciseSec()
				refreshFunction()

			elseif(... == false) then --RELOAD OR SETTINGS EDIT
				QueueUpTime = QueueUpTime > 0 and QueueUpTime or GetTimePreciseSec()
				miog.checkApplicantList(true, true)

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
			miog.checkApplicantList(not allowedToInvite, not allowedToInvite)

		elseif(newEntry == false and withData == false) then --DECLINED APPLICANT
			miog.checkApplicantList(true, miog.defaultOptionSettings[3].value)

		elseif(not newEntry and not withData) then --REFRESH APP LIST
			miog.checkApplicantList(true, true)

		end
    elseif(event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
        miog.F.AFFIX_UPDATE_COUNTER = miog.F.AFFIX_UPDATE_COUNTER + 1
        
		if(miog.F.AFFIX_UPDATE_COUNTER == 1) then
			C_MythicPlus.GetCurrentAffixes()
        elseif(miog.F.AFFIX_UPDATE_COUNTER == 2) then
			miog.getAffixes()
        end
	elseif(event == "ADDON_LOADED") then
		local addon = ...

		if(addon == "RaiderIO") then
			miog.mainFrame.statusBar.rioLoaded:Hide()
		end
	end
end

SLASH_MIOG1 = '/miog'
local function handler(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if(command == "new") then
		if(IsInGroup()) then
			PVEFrame:Show()
			LFGListFrame:Show()
			LFGListPVEStub:Show()
			LFGListFrame.ApplicationViewer:Show()
			createFullEntries(3)
		end
	else
		miog.mainFrame:Show()
	end
end
SlashCmdList["MIOG"] = handler