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
	detailExpandedList = {}
end

local function createEntryFrame(applicantID, debug)
	local applicantData = C_LFGList.GetApplicantInfo(applicantID)

	if(debug) then
		applicantData = {applicantID = applicantID, applicationStatus = "applied", numMembers = random(1, 4), isNew = true, comment = "Heiho, heiho, wir sind vergnügt und froh. Johei, johei, die Arbeit ist vorbei.", displayOrderID = 1}
	end

	local applicantsFrame = miog.temporaryFramePool:Acquire("BackdropTemplate")

	if(not latestApplicantFrame) then
		applicantsFrame:SetPoint("TOP", miog.mainFrame.mainScrollFrame.mainContainer, "TOP", 0, 0)
	else
		applicantsFrame:SetPoint("TOPLEFT", latestApplicantFrame, "BOTTOMLEFT", 0, -3)
	end

	applicantsFrame:SetParent(miog.mainFrame.mainScrollFrame.mainContainer)
	applicantsFrame.entryFrames = {}
	applicantsFrame.applicantID = applicantID
	applicantsFrame:Show()
	miog.createFrameBorder(applicantsFrame, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())

	local sizeIncrease = miog.C.ENTRY_FRAME_SIZE * applicantData.numMembers + 2 + applicantData.numMembers
	
	applicantsFrame:SetSize(miog.mainFrame.mainScrollFrame:GetWidth() - 4, sizeIncrease)

	for index = 1, applicantData.numMembers, 1 do
		local fullName, englishClassName, _, _, ilvl, honor, tank, healer, damager, assignedRole, friend, dungeonScore = C_LFGList.GetApplicantMemberInfo(applicantID, index)

		if(fullName or debug) then
			local bestDungeonScoreForListing
			local profile

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
				bestDungeonScoreForListing = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, index, C_LFGList.GetActiveEntryInfo().activityID)
			end

			local result = miog.simpleSplit(fullName, "-")

			local entryFrame = miog.temporaryFramePool:Acquire("BackdropTemplate")
			entryFrame:SetSize(applicantsFrame:GetWidth()-2, miog.C.ENTRY_FRAME_SIZE)

			if(not latestEntryFrame) then
				entryFrame:SetPoint("TOP", applicantsFrame, "TOP", 0, -1)
			else
				if(index > 1) then
					entryFrame:SetPoint("TOP", applicantsFrame.entryFrames[index-1], "BOTTOM", 0, -1)
				end
			end

			applicantsFrame.entryFrames[index] = entryFrame

			entryFrame.linkBox = miog.temporaryFramePool:Acquire("InputBoxTemplate")
			entryFrame.linkBox:SetParent(WorldFrame)
			entryFrame.linkBox:SetFont(miog.fonts["libMono"], 7, "OUTLINE")
			entryFrame.linkBox:SetSize(250, 20)
			entryFrame.linkBox:SetPoint("CENTER")
			entryFrame.linkBox:SetAutoFocus(true)
			entryFrame.linkBox:SetScript("OnKeyDown", function(editBoxSelf, key) if(key == "ESCAPE") then entryFrame.linkBox:Hide() entryFrame.linkBox:ClearFocus() end end)

			entryFrame:SetParent(applicantsFrame)
			entryFrame:SetScript("OnMouseDown", function(self, button)
				if(button == "RightButton") then
					local link = "https://raider.io/characters/" .. profile.region .. "/" .. profile.realm .. "/" .. profile.name

					entryFrame.linkBox:SetAutoFocus(true)
					entryFrame.linkBox:SetText(link)
					entryFrame.linkBox:HighlightText()

					entryFrame.linkBox:Show()
					entryFrame.linkBox:SetAutoFocus(false)
				end
			end)
			entryFrame.active = false

			local entryFrame_BackgroundTexture = miog.temporaryTexturePool:Acquire()
			entryFrame_BackgroundTexture:SetParent(entryFrame)
			entryFrame_BackgroundTexture:SetAllPoints()
			entryFrame_BackgroundTexture:SetDrawLayer("BACKGROUND")
			entryFrame_BackgroundTexture:SetColorTexture(CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA())
			entryFrame_BackgroundTexture:Show()
	
			entryFrame:Show()

			latestEntryFrame = entryFrame
			
			local dataFrameDungeons = miog.temporaryFramePool:Acquire("BackdropTemplate")
			dataFrameDungeons:SetSize(entryFrame:GetWidth()*0.52, miog.C.FULL_SIZE)
			dataFrameDungeons:SetPoint("TOPLEFT", entryFrame, "TOPLEFT", 0, -miog.C.ENTRY_FRAME_SIZE - 2)
			dataFrameDungeons:SetFrameStrata("HIGH")
			dataFrameDungeons:SetParent(entryFrame)
			
			local dataFrameGeneralInfo = miog.temporaryFramePool:Acquire("BackdropTemplate")
			dataFrameGeneralInfo:SetSize(entryFrame:GetWidth()*0.48, miog.C.FULL_SIZE)
			dataFrameGeneralInfo:SetPoint("TOPLEFT", dataFrameDungeons, "TOPRIGHT", 0, 0)
			dataFrameGeneralInfo:SetFrameStrata("HIGH")
			dataFrameGeneralInfo:SetParent(entryFrame)

			local detailsButton = miog.temporaryFramePool:Acquire("UICheckButtonTemplate")
			detailsButton:SetParent(entryFrame)
			detailsButton:SetPoint("TOPLEFT", entryFrame, "TOPLEFT", 0, 1)
			detailsButton:SetSize(miog.C.ENTRY_FRAME_SIZE + 2, miog.C.ENTRY_FRAME_SIZE + 2)
			detailsButton:RegisterForClicks("LeftButtonDown")
			detailsButton:SetScript("OnClick", function(self, button, down)
				dataFrameDungeons:SetShown(not dataFrameDungeons:IsVisible())
				dataFrameGeneralInfo:SetShown(not dataFrameGeneralInfo:IsVisible())

				if(entryFrame.active == true) then
					entryFrame:SetSize(entryFrame:GetWidth(), miog.C.ENTRY_FRAME_SIZE)
					applicantsFrame:SetSize(applicantsFrame:GetWidth(), applicantsFrame:GetHeight() - miog.C.FULL_SIZE - 2)
				else
					entryFrame:SetSize(entryFrame:GetWidth(), miog.C.ENTRY_FRAME_SIZE + miog.C.FULL_SIZE + 2)
					applicantsFrame:SetSize(applicantsFrame:GetWidth(), applicantsFrame:GetHeight() + miog.C.FULL_SIZE + 2)
				end

				detailsButton:SetChecked(not entryFrame.active)
				detailExpandedList[applicantID] = not entryFrame.active
				entryFrame.active = not entryFrame.active
			end)

			if(detailExpandedList[applicantID]) then
				detailsButton:SetChecked(detailExpandedList[applicantID])
			end

			detailsButton:Show()

			local allowedToInvite = C_PartyInfo.CanInvite()
			if(index == 1 and allowedToInvite or index == 1 and debug) then
				applicantsFrame.declineButton = miog.temporaryFramePool:Acquire("UIButtonTemplate, BackdropTemplate")
				applicantsFrame.declineButton:SetText(CreateTextureMarkup(136813, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE/2, miog.C.APPLICANT_BUTTON_SIZE/2, 0.1, 0.85, 0.15, 0.85))
				applicantsFrame.declineButton:SetParent(entryFrame)
				applicantsFrame.declineButton:SetSize(miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE)

				applicantsFrame.declineButton:SetPoint("TOPRIGHT", entryFrame, "TOPRIGHT", 0, 0)
				applicantsFrame.declineButton:RegisterForClicks("LeftButtonDown")
				applicantsFrame.declineButton:SetScript("OnClick", function(self, button)

					if(addonApplicantList[applicantID]["creationStatus"] == "added") then

						addonApplicantList[applicantID]["creationStatus"] = "canBeRemoved"
						addonApplicantList[applicantID]["appStatus"] = "declined"
						C_LFGList.DeclineApplicant(applicantID)

					elseif(addonApplicantList[applicantID]["creationStatus"] == "canBeRemoved") then
						miog.checkApplicantList(true, miog.F.IS_LIST_SORTED)
					end

				end)

				local declineButtonFontString = applicantsFrame.declineButton:GetFontString()
				if(declineButtonFontString) then
					declineButtonFontString:SetFont(miog.fonts["libMono"], miog.C.ENTRY_FRAME_SIZE, "OUTLINE")
				end

				applicantsFrame.declineButton:Show()

				applicantsFrame.inviteButton = miog.temporaryFramePool:Acquire("UIButtonTemplate, BackdropTemplate")
				applicantsFrame.inviteButton:SetText(CreateTextureMarkup(136814, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE/2, miog.C.APPLICANT_BUTTON_SIZE/2, 0.1, 0.85, 0.1, 0.95))
				applicantsFrame.inviteButton:SetParent(entryFrame)
				applicantsFrame.inviteButton:SetSize(miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE)
				applicantsFrame.inviteButton:SetPoint("TOPRIGHT", applicantsFrame.declineButton, "TOPLEFT", 0, 0)
				applicantsFrame.inviteButton:RegisterForClicks("LeftButtonDown")
				applicantsFrame.inviteButton:SetScript("OnClick", function(self, button)
					C_LFGList.InviteApplicant(applicantID)
				end)

				local inviteButtonFontString = applicantsFrame.inviteButton:GetFontString()
				if(inviteButtonFontString) then
					inviteButtonFontString:SetFont(miog.fonts["libMono"], miog.C.ENTRY_FRAME_SIZE, "OUTLINE")
				end

				applicantsFrame.inviteButton:Show()

			elseif(index > 1) then
				local groupIcon = miog.temporaryTexturePool:Acquire()
				groupIcon:SetTexture(134148)
				groupIcon:SetSize(miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
				groupIcon:SetPoint("TOPRIGHT", entryFrame, "TOPRIGHT", 0, 0)
				groupIcon:SetTexCoord(0, 0.95, 0.05, 1)
				groupIcon:SetDrawLayer("OVERLAY")
				groupIcon:SetParent(entryFrame)
				groupIcon:Show()
			elseif(not allowedToInvite) then
				miog.mainFrame.mainScrollFrame:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)
			end

			entryFrame.statusString = miog.createFontString("", entryFrame, 12)
			entryFrame.statusString:SetFont(miog.fonts["libMono"], miog.C.ENTRY_FRAME_SIZE, "OUTLINE")
			entryFrame.statusString:SetJustifyH("CENTER")
			entryFrame.statusString:SetJustifyV("CENTER")
			entryFrame.statusString:SetPoint("TOPLEFT", entryFrame, "TOPLEFT", 0, -1)
			entryFrame.statusString:SetDrawLayer("OVERLAY")
			entryFrame.statusString:Hide()

			entryFrame.statusString.backgroundColor = miog.temporaryTexturePool:Acquire()
			entryFrame.statusString.backgroundColor:SetParent(entryFrame)
			entryFrame.statusString.backgroundColor:SetDrawLayer("OVERLAY")
			entryFrame.statusString.backgroundColor:SetSize(entryFrame:GetSize())
			entryFrame.statusString.backgroundColor:SetPoint("TOPLEFT", entryFrame, "TOPLEFT", 0, 0)
			entryFrame.statusString.backgroundColor:SetColorTexture(0.1, 0.1, 0.1, 0.7)
			entryFrame.statusString.backgroundColor:Hide()

			local shortName = strsub(result[1], 0, 20)
			local coloredSubName = WrapTextInColorCode(shortName, select(4, GetClassColor(englishClassName)))

			local nameString = miog.createFontString(coloredSubName, entryFrame, 11, entryFrame:GetWidth()*0.28, miog.C.ENTRY_FRAME_SIZE)
			nameString:SetMouseMotionEnabled(true)
			nameString:SetPoint("LEFT", detailsButton, "RIGHT", 0, 0)
			nameString:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(entryFrame, "ANCHOR_CURSOR")
				GameTooltip:SetText(fullName)
				GameTooltip:Show()
			end)
			nameString:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)

			local commentTexture = miog.temporaryTexturePool:Acquire()
			commentTexture:SetDrawLayer("OVERLAY")
			commentTexture:SetPoint("LEFT", nameString, "RIGHT", 3, 0)
			commentTexture:SetSize(miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
			commentTexture:SetTexture(1505953)
			commentTexture:SetParent(entryFrame)
			
			if(applicantData.comment ~= "") then
				commentTexture:Show()
			end

			local roleTexture = miog.temporaryTexturePool:Acquire()
			roleTexture:SetDrawLayer("OVERLAY")
			roleTexture:SetPoint("LEFT", commentTexture, "RIGHT", 3, 0)
			roleTexture:SetSize(miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
			roleTexture:SetTexture(2202478)
			roleTexture:SetParent(entryFrame)
			roleTexture:Show()

			if(assignedRole == "DAMAGER") then
				roleTexture:SetTexCoord(0, 0.25, 0, 1)
			elseif(assignedRole == "HEALER") then
				roleTexture:SetTexCoord(0.25, 0.5, 0, 1)
			elseif(assignedRole == "TANK") then
				roleTexture:SetTexCoord(0.5, 0.75, 0, 1)
			end

			local scoreString = miog.createFontString(coloredSubName, entryFrame, 12, entryFrame:GetWidth()*0.11, 10)
			scoreString:SetPoint("LEFT", roleTexture, "RIGHT", 3, 0)
			
			local mythicKeystoneProfile
			local dungeonProfile
			
			if(IsAddOnLoaded("RaiderIO")) then
				profile = RaiderIO.GetProfile(result[1], result[2])
				
				if(profile ~= nil) then
					mythicKeystoneProfile = profile.mythicKeystoneProfile

					if(mythicKeystoneProfile ~= nil) then
						dungeonProfile = mythicKeystoneProfile.sortedDungeons

						if(dungeonProfile ~= nil) then
							table.sort(dungeonProfile, function(k1, k2) return k1.dungeon.index < k2.dungeon.index end)
						end
					end
					
					scoreString:SetText(WrapTextInColorCode(tostring(dungeonScore), C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore):GenerateHexColor()))
				end
			end

			local timedApplyingDungeon
	
			if(bestDungeonScoreForListing) then
				if(bestDungeonScoreForListing.finishedSuccess == true) then
					timedApplyingDungeon = WrapTextInColorCode(tostring(bestDungeonScoreForListing.bestRunLevel), miog.C.GREEN_COLOR)
				elseif(bestDungeonScoreForListing.finishedSuccess == false) then
					timedApplyingDungeon = WrapTextInColorCode(tostring(bestDungeonScoreForListing.bestRunLevel), miog.C.RED_COLOR)
				end
			else
				timedApplyingDungeon = WrapTextInColorCode(tostring(0), miog.C.RED_COLOR)
			end

			local keyString = miog.createFontString(timedApplyingDungeon, entryFrame, 12, entryFrame:GetWidth()*0.06, 10)
			keyString:SetPoint("LEFT", scoreString, "RIGHT", 3, 0)
			
			local ilvlString = miog.createFontString(miog.round(ilvl, 1), entryFrame, 12, entryFrame:GetWidth()*0.135, 10)
			ilvlString:SetPoint("LEFT", keyString, "RIGHT", 3, 0)

			local friendTexture = miog.temporaryTexturePool:Acquire()
			friendTexture:SetDrawLayer("OVERLAY")
			friendTexture:SetPoint("LEFT", ilvlString, "RIGHT", 0, 0)
			friendTexture:SetSize(miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
			friendTexture:SetTexture(648207)
			friendTexture:SetParent(entryFrame)
			friendTexture:SetShown(friend or false)

			for dngIndex = 1, 8, 1 do
				
				local remainder = math.fmod(dngIndex, 2)

				local textLineLeft = miog.createTextLine(dataFrameDungeons, dngIndex)
				local textLineRight = miog.createTextLine(dataFrameGeneralInfo, dngIndex)

				if(remainder == 1) then
					local offBackgroundColor = miog.temporaryTexturePool:Acquire()
					offBackgroundColor:SetParent(textLineLeft)
					offBackgroundColor:SetSize(entryFrame:GetWidth() - 1, textLineLeft:GetHeight())
					offBackgroundColor:SetPoint("TOPLEFT", textLineLeft, "TOPLEFT", 0, 0)
					
					offBackgroundColor:SetColorTexture(CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())
					offBackgroundColor:Show()
				end

				local textLineRightFontString
				
				if(dngIndex == 1) then
					textLineRight:SetSize(textLineRight:GetWidth(), miog.C.FULL_SIZE*0.75)

					textLineRightFontString = miog.createFontString(_G["COMMENTS_COLON"] .. " " .. applicantData.comment, textLineRight,  miog.C.TEXT_LINE_FONT_SIZE)
					textLineRightFontString:SetSize(textLineRight:GetWidth()-1, textLineRight:GetHeight())
					textLineRightFontString:SetWordWrap(true)
					textLineRightFontString:SetSpacing(textLineRightFontString:GetHeight()/16)

				elseif(dngIndex == 7) then
					textLineRightFontString = miog.createFontString(_G["LFG_TOOLTIP_ROLES"], textLineRight, miog.C.TEXT_LINE_FONT_SIZE)

					if(tank == true) then
						textLineRightFontString:SetText(textLineRightFontString:GetText() .. CreateTextureMarkup(2202478, 256, 64, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE, 0.5, 0.75, 0, 1))
					end
					if(healer == true) then
						textLineRightFontString:SetText(textLineRightFontString:GetText() .. CreateTextureMarkup(2202478, 256, 64, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE, 0.25, 0.5, 0, 1))
					end
					if(damager == true) then
						textLineRightFontString:SetText(textLineRightFontString:GetText() .. CreateTextureMarkup(2202478, 256, 64, miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE, 0, 0.25, 0, 1))
					end

				elseif(dngIndex == 8) then
					if(profile and profile.mythicKeystoneProfile and (profile.mythicKeystoneProfile.mainCurrentScore or 0) > 0) then
						textLineRightFontString = miog.createFontString(WrapTextInColorCode("Main: " .. (profile.mythicKeystoneProfile.mainCurrentScore or 0), _G["ITEM_QUALITY_COLORS"][6].color:GenerateHexColor()), textLineRight, miog.C.TEXT_LINE_FONT_SIZE)
					else
						textLineRightFontString = miog.createFontString(WrapTextInColorCode("Main Char", _G["ITEM_QUALITY_COLORS"][7].color:GenerateHexColor()), textLineRight, miog.C.TEXT_LINE_FONT_SIZE)
					end
				end

				if(textLineRightFontString) then
					if(dngIndex == 1) then
						textLineRightFontString:SetJustifyV("TOP")
						textLineRightFontString:SetPoint("TOPLEFT", textLineRight, "TOPLEFT", 2, -4)
					else
						textLineRightFontString:SetPoint("TOPLEFT", textLineRight, "TOPLEFT", 2, -1)
					end
				end
				
				if(profile) then --If Raider.IO is installed
					if(mythicKeystoneProfile) then

						if(dngIndex == 1) then
						elseif(dngIndex == 6) then
							textLineRightFontString = miog.createFontString("", textLineRight, miog.C.TEXT_LINE_FONT_SIZE)
							textLineRightFontString:SetText(
								WrapTextInColorCode(profile.mythicKeystoneProfile.keystoneFivePlus or 0, _G["ITEM_QUALITY_COLORS"][2].color:GenerateHexColor()) .. " - " ..
								WrapTextInColorCode(profile.mythicKeystoneProfile.keystoneTenPlus or 0, _G["ITEM_QUALITY_COLORS"][3].color:GenerateHexColor()) .. " - " ..
								WrapTextInColorCode(profile.mythicKeystoneProfile.keystoneFifteenPlus or 0, _G["ITEM_QUALITY_COLORS"][4].color:GenerateHexColor()) .. " - " ..
								WrapTextInColorCode(profile.mythicKeystoneProfile.keystoneTwentyPlus or 0, _G["ITEM_QUALITY_COLORS"][5].color:GenerateHexColor())
							)
							textLineRightFontString:SetPoint("TOPLEFT", textLineRight, "TOPLEFT", 2, -1, 1, 1)
						end
					end

					local primaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and profile.mythicKeystoneProfile.tyrannicalDungeons[dngIndex] or miog.F.WEEKLY_AFFIX == 10 and profile.mythicKeystoneProfile.fortifiedDungeons[dngIndex]
					local primaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and profile.mythicKeystoneProfile.tyrannicalDungeonUpgrades[dngIndex] or miog.F.WEEKLY_AFFIX == 10 and profile.mythicKeystoneProfile.fortifiedDungeonUpgrades[dngIndex]
					local secondaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and profile.mythicKeystoneProfile.fortifiedDungeons[dngIndex] or miog.F.WEEKLY_AFFIX == 10 and profile.mythicKeystoneProfile.tyrannicalDungeons[dngIndex]
					local secondaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and profile.mythicKeystoneProfile.fortifiedDungeonUpgrades[dngIndex] or miog.F.WEEKLY_AFFIX == 10 and profile.mythicKeystoneProfile.tyrannicalDungeonUpgrades[dngIndex]
					local starTexture = CreateTextureMarkup("Interface/Addons/MythicIOGrabber/res/star_256.png", 256, 256, 10, 10, 0, 1, 0, 1)

					if(dungeonProfile) then
						local textureString

						for _, icon in pairs(miog.dungeonIcons) do
							if(dungeonProfile[dngIndex].dungeon.name == icon[1]) then
								textureString = icon[2]
							end
						end

						local dungeonIconTexture = miog.temporaryTexturePool:Acquire()
						dungeonIconTexture:SetTexture(textureString)
						dungeonIconTexture:SetPoint("LEFT", textLineLeft, "LEFT", 0, 0)
						dungeonIconTexture:SetSize(miog.C.ENTRY_FRAME_SIZE, miog.C.ENTRY_FRAME_SIZE)
						dungeonIconTexture:SetParent(textLineLeft)
						dungeonIconTexture:SetDrawLayer("OVERLAY")
						dungeonIconTexture:Show()

						local dungeonNameShort = dungeonProfile[dngIndex].dungeon.shortName
						local insertStringDungeon = string.sub("   ", 1, 5-string.len(dungeonNameShort))
						local tf1String = dungeonNameShort .. ":" .. insertStringDungeon

						local insertStringPrimary = string.sub("  ", 1, 3-primaryDungeonChests)

						if(primaryDungeonChests >= 1) then
							tf1String = tf1String .. WrapTextInColorCode(primaryDungeonLevel .. string.rep(starTexture, primaryDungeonChests), miog.C.GREEN_COLOR) .. insertStringPrimary
							
						elseif(primaryDungeonChests == 0) then
							tf1String = tf1String .. WrapTextInColorCode(primaryDungeonLevel, miog.C.RED_COLOR) .. insertStringPrimary .. " "
						end

						if(secondaryDungeonChests >= 1) then
							tf1String = tf1String .. WrapTextInColorCode(secondaryDungeonLevel .. string.rep(starTexture, secondaryDungeonChests), miog.C.GREEN_SECONDARY_COLOR)

						elseif(secondaryDungeonChests == 0) then
							tf1String = tf1String .. WrapTextInColorCode(secondaryDungeonLevel, miog.C.RED_SECONDARY_COLOR) .. " "
						end

						local textLineLeftFontString = miog.createFontString(tf1String, textLineLeft, miog.C.TEXT_LINE_FONT_SIZE)
						textLineLeftFontString:SetSpacing(2)
						textLineLeftFontString:SetPoint("LEFT", dungeonIconTexture, "RIGHT", 2, 0)

					end
				else -- If RaiderIO is not installed
					if(dngIndex == 1) then
						local textLineLeftFontString = miog.createFontString(WrapTextInColorCode("NO RAIDER.IO DATA", "FFFF0000"), textLineLeft, miog.C.TEXT_LINE_FONT_SIZE)
						textLineLeftFontString:SetPoint("LEFT", textLineLeft, "LEFT", 2, 0)

						textLineLeftFontString = miog.createFontString(WrapTextInColorCode("NO DATA", "FFFF0000"), textLineLeft, miog.C.TEXT_LINE_FONT_SIZE)
						textLineLeftFontString:SetPoint("LEFT", textLineLeft, "LEFT", 2, 0)

						scoreString:SetText(WrapTextInColorCode(tostring(dungeonScore), C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore):GenerateHexColor()))
					end
				end
			end
		end
	end

	addonApplicantList[applicantID]["frame"] = applicantsFrame
	addonApplicantList[applicantID]["creationStatus"] = "added"
	latestEntryFrame = nil
	latestApplicantFrame = applicantsFrame
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

	if(not string == "INVITED") then
		addonApplicantList[applicantID]["creationStatus"] = "canBeRemoved"
	else
		addonApplicantList[applicantID]["creationStatus"] = "invited"
	end
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
					if(needSort and miog.defaultOptionSettings[3].value) then
						miog.F.IS_LIST_SORTED = true

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

	if(needSort and miog.defaultOptionSettings[3].value) then
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
					for k,v in pairs(C_LFGList.GetSearchResultMemberCounts(resultID)) do

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
		miog.relocateBlizzardElements()
		miog.releaseAllTemporaryPools()

	elseif(event == "PLAYER_LOGIN") then
		miog.F.AFFIX_UPDATE_COUNTER = 0

        C_MythicPlus.RequestMapInfo()

		miog.createMainFrame()
		
		LFGListFrame.ApplicationViewer:HookScript("OnHide", function() miog.mainFrame:Hide() end)
		LFGListFrame.ApplicationViewer:HookScript("OnShow", function() miog.mainFrame:Show() end)

		hooksecurefunc("LFGListSearchEntry_Update", refreshSpecIcons)

	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then --LISTING CHANGES

		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		local activityInfo

		if(C_LFGList.HasActiveEntryInfo() ==  true) then
			activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)

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
			if(... == true) then --NEW LISTING
				miog.F.IS_LIST_SORTED = false
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
							changeApplicantStatus(..., frame, "DECLINED_WITH_APP_ID", "FFFF0000")

						elseif(status == "declined_full") then
							changeApplicantStatus(..., frame, "DECLINED_FULL_WITH_APP_ID", "FFFF0000")
				
						elseif(status == "declined_delisted") then
							changeApplicantStatus(..., frame, "DECLINED_DELISTED", "FFFF0000")
						
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
			miog.checkApplicantList(true, not allowedToInvite)

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
	end
end

SLASH_MIOG1 = '/miog'
local function handler(msg, editBox)
	if(msg == "new") then
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