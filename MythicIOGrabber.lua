local addonName, miog = ...

local applicantViewer_ExpandedFrameList = {}
local searchPanel_ExpandedFrameList = {}

local groupSystem = {}
groupSystem.groupMember = {}
groupSystem.inspectedGUIDs = {}

local applicantSystem = {}
applicantSystem.applicantMember = {}

local searchResultSystem = {}
searchResultSystem.resultFrames = {}
searchResultSystem.applicationStatus = {}

local currentAverageExecuteTime = {}
local debugTimer = nil

local fmod = math.fmod
local rep = string.rep
local wticc = WrapTextInColorCode
local tostring = tostring
local CreateColorFromHexString = CreateColorFromHexString

local applicationFrameIndex = 0
local resultFrameIndex = 0

local queueTimer

local lastNotifyTime = 0
local inspectQueue = {}
local inspectCoroutine

local function resetArrays()
	miog.DEBUG_APPLICANT_DATA = {}
	miog.DEBUG_APPLICANT_MEMBER_INFO = {}

end

local function releaseApplicantFrames()
	for _,v in pairs(applicantSystem.applicantMember) do
		if(v.frame) then
			v.frame.fontStringPool:ReleaseAll()
			v.frame.texturePool:ReleaseAll()
			v.frame.framePool:ReleaseAll()

		end
	end

	applicantSystem.applicantMember = {}

	miog.applicantFramePool:ReleaseAll()

	miog.applicationViewer.footerBar.applicantNumberFontString:SetText(0)
	miog.applicationViewer.applicantPanel.container:MarkDirty()

end

local function hideAllApplicantFrames()
	for _, v in pairs(applicantSystem.applicantMember) do
		if(v.frame) then
			v.frame:Hide()
			v.frame.layoutIndex = nil

		end
	end

	miog.applicationViewer.footerBar.applicantNumberFontString:SetText(0)
	miog.applicationViewer.applicantPanel.container:MarkDirty()

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

	for key, tableElement in pairs(miog.F.SORT_METHODS) do
		if(tableElement.currentLayer == 1) then
			local firstState = miog.applicationViewer.buttonPanel.sortByCategoryButtons[key]:GetActiveState()

			for innerKey, innerTableElement in pairs(miog.F.SORT_METHODS) do

				if(innerTableElement.currentLayer == 2) then
					local secondState = miog.applicationViewer.buttonPanel.sortByCategoryButtons[innerKey]:GetActiveState()

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

local function gatherRaiderIODisplayData(playerName, realm, poolFrame, memberFrame)
	local profile, mythicKeystoneProfile, raidProfile

	local basicInformationPanel = memberFrame.basicInformationPanel
	local primaryIndicator = basicInformationPanel.primaryIndicator
	local secondaryIndicator = basicInformationPanel.secondaryIndicator

	if(miog.F.IS_RAIDERIO_LOADED) then
		profile = RaiderIO.GetProfile(playerName, realm, miog.F.CURRENT_REGION)

		if(profile ~= nil) then
			mythicKeystoneProfile = profile.mythicKeystoneProfile
			raidProfile = profile.raidProfile

		end
	end

	local detailedInformationPanel = miog.createFleetingFrame(poolFrame.framePool, "ResizeLayoutFrame, BackdropTemplate", memberFrame)
	detailedInformationPanel:SetWidth(basicInformationPanel.fixedWidth)
	detailedInformationPanel:SetPoint("TOPLEFT", basicInformationPanel, "BOTTOMLEFT", 0, 0)
	detailedInformationPanel:SetShown(basicInformationPanel.expandButton:GetActiveState() > 0 and true or false)
	local rowWidth = basicInformationPanel.fixedWidth * 0.5

	memberFrame.detailedInformationPanel = detailedInformationPanel

	local tabPanel = miog.createFleetingFrame(poolFrame.framePool, "BackdropTemplate", detailedInformationPanel)
	tabPanel:SetPoint("TOPLEFT", detailedInformationPanel, "TOPLEFT")
	tabPanel:SetPoint("TOPRIGHT", detailedInformationPanel, "TOPRIGHT")
	tabPanel:SetHeight(miog.C.APPLICANT_MEMBER_HEIGHT)
	tabPanel.rows = {}

	detailedInformationPanel.tabPanel = tabPanel

	local mythicPlusTabButton = miog.createFleetingFrame(poolFrame.framePool, "UIPanelButtonTemplate", tabPanel)
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
		poolFrame:MarkDirty()
	end)
	tabPanel.mythicPlusTabButton = mythicPlusTabButton

	local raidTabButton = miog.createFleetingFrame(poolFrame.framePool, "UIPanelButtonTemplate", tabPanel)
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
		poolFrame:MarkDirty()
	end)
	tabPanel.raidTabButton = raidTabButton

	local raidPanel = miog.createFleetingFrame(poolFrame.framePool, "BackdropTemplate", detailedInformationPanel, rowWidth, 9 * 20)
	raidPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
	tabPanel.raidPanel = raidPanel
	raidPanel:SetShown(miog.F.LISTED_CATEGORY_ID == 3 and true)
	raidPanel.rows = {}

	local mythicPlusPanel = miog.createFleetingFrame(poolFrame.framePool, "BackdropTemplate", detailedInformationPanel, rowWidth, 9 * 20)
	mythicPlusPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
	tabPanel.mythicPlusPanel = mythicPlusPanel
	mythicPlusPanel:SetShown(miog.F.LISTED_CATEGORY_ID ~= 3 and true)
	mythicPlusPanel.rows = {}

	local generalInfoPanel = miog.createFleetingFrame(poolFrame.framePool, "BackdropTemplate", detailedInformationPanel, rowWidth, 9 * 20)
	generalInfoPanel:SetPoint("TOPRIGHT", tabPanel, "BOTTOMRIGHT")
	tabPanel.generalInfoPanel = generalInfoPanel
	generalInfoPanel.rows = {}

	local lastTextRow = nil

	local hoverColor = {CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA()}
	local cardColor = {CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA()}

	for rowIndex = 1, miog.F.MOST_BOSSES, 1 do
		local remainder = fmod(rowIndex, 2)

		local textRowFrame = miog.createFleetingFrame(poolFrame.framePool, "BackdropTemplate", detailedInformationPanel)
		textRowFrame:SetSize(basicInformationPanel.fixedWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
		textRowFrame:SetPoint("TOPLEFT", lastTextRow or mythicPlusTabButton, "BOTTOMLEFT")
		lastTextRow = textRowFrame
		tabPanel.rows[rowIndex] = textRowFrame

		local textRowBackground = miog.createFleetingTexture(poolFrame.texturePool, nil, textRowFrame, basicInformationPanel.fixedWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
		textRowBackground:SetDrawLayer("BACKGROUND")
		textRowBackground:SetPoint("CENTER", textRowFrame, "CENTER")

		if(remainder == 1) then
			textRowBackground:SetColorTexture(unpack(hoverColor))

		else
			textRowBackground:SetColorTexture(unpack(cardColor))

		end

		local divider = miog.createFleetingTexture(poolFrame.texturePool, nil, textRowFrame, basicInformationPanel.fixedWidth, 1, "BORDER")
		divider:SetAtlas("UI-LFG-DividerLine")
		divider:SetPoint("BOTTOM", textRowFrame, "BOTTOM", 0, 0)

		if(rowIndex == 1 or rowIndex > 4 and rowIndex < 10) then
			local textRowGeneralInfo = miog.createFleetingFrame(poolFrame.framePool, "BackdropTemplate", textRowFrame, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", poolFrame.fontStringPool,  miog.C.TEXT_ROW_FONT_SIZE)
			textRowGeneralInfo.FontString:SetJustifyH("CENTER")
			textRowGeneralInfo:SetPoint("LEFT", textRowFrame, "LEFT", rowWidth, 0)
			generalInfoPanel.rows[rowIndex] = textRowGeneralInfo

			if(rowIndex == 1 or rowIndex == 5 or rowIndex == 6) then
				local textRowMythicPlus = miog.createFleetingFrame(poolFrame.framePool, "BackdropTemplate", mythicPlusPanel, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", poolFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE)
				local textRowRaid = miog.createFleetingFrame(poolFrame.framePool, "BackdropTemplate", raidPanel, rowWidth, miog.C.APPLICANT_MEMBER_HEIGHT, "FontString", poolFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE)

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

					local dungeonIconFrame = miog.createFleetingTexture(poolFrame.texturePool, miog.MAP_INFO[mythicKeystoneProfile.sortedDungeons[rowIndex].dungeon.instance_map_id].icon, mythicPlusPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2)
					dungeonIconFrame:SetPoint("LEFT", tabPanel.rows[rowIndex], "LEFT")
					dungeonIconFrame:SetMouseClickEnabled(true)
					dungeonIconFrame:SetDrawLayer("OVERLAY")
					dungeonIconFrame:SetScript("OnMouseDown", function()
						local instanceID = C_EncounterJournal.GetInstanceForGameMap(mythicKeystoneProfile.sortedDungeons[rowIndex].dungeon.instance_map_id)

						--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
						EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

					end)

					local dungeonNameFrame = miog.createFleetingFontString(poolFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidth*0.25, miog.C.APPLICANT_MEMBER_HEIGHT)
					dungeonNameFrame:SetText(mythicKeystoneProfile.sortedDungeons[rowIndex].dungeon.shortName .. ":")
					dungeonNameFrame:SetPoint("LEFT", dungeonIconFrame, "RIGHT", 1, 0)

					local primaryAffixScoreFrame = miog.createFleetingFontString(poolFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidthThirty, miog.C.APPLICANT_MEMBER_HEIGHT)
					primaryAffixScoreFrame:SetText(wticc(primaryDungeonLevel[rowIndex] .. rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or primaryDungeonChests[rowIndex]),
					primaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or primaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))
					primaryAffixScoreFrame:SetPoint("LEFT", dungeonNameFrame, "RIGHT")

					local secondaryAffixScoreFrame = miog.createFleetingFontString(poolFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE,  mythicPlusPanel, rowWidthThirty, miog.C.APPLICANT_MEMBER_HEIGHT)
					secondaryAffixScoreFrame:SetText(wticc(secondaryDungeonLevel[rowIndex] .. rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or secondaryDungeonChests[rowIndex]),
					secondaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or secondaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))
					secondaryAffixScoreFrame:SetPoint("LEFT", primaryAffixScoreFrame, "RIGHT")
				end
			end

			local previousScoreString = ""

			if(mythicKeystoneProfile.previousScore and mythicKeystoneProfile.previousScore > 0) then
				previousScoreString = (miog.F.PREVIOUS_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]) .. ": " .. wticc(mythicKeystoneProfile.previousScore, miog.createCustomColorForScore(mythicKeystoneProfile.previousScore):GenerateHexColor())

			end

			mythicPlusPanel.rows[5].FontString:SetText(previousScoreString)

			local mainScoreString = ""

			if(mythicKeystoneProfile.mainCurrentScore) then
				if((mythicKeystoneProfile.mainCurrentScore > 0) == false and (mythicKeystoneProfile.mainPreviousScore > 0) == false) then
					mainScoreString = wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex)

				else
					if(mythicKeystoneProfile.mainCurrentScore > 0 and mythicKeystoneProfile.mainPreviousScore > 0) then
						mainScoreString = "Main " .. (miog.F.CURRENT_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason()]) .. ": " .. wticc(mythicKeystoneProfile.mainCurrentScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor()) ..
						" " .. (miog.F.PREVIOUS_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]) .. ": " .. wticc(mythicKeystoneProfile.mainPreviousScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainPreviousScore):GenerateHexColor())

					elseif(mythicKeystoneProfile.mainCurrentScore > 0) then
						mainScoreString = "Main " .. (miog.F.CURRENT_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason()]) .. ": " .. wticc(mythicKeystoneProfile.mainCurrentScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor())

					elseif(mythicKeystoneProfile.mainPreviousScore > 0) then
						mainScoreString = "Main " .. (miog.F.PREVIOUS_SEASON or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]) .. ": " .. wticc(mythicKeystoneProfile.mainPreviousScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainPreviousScore):GenerateHexColor())

					end

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
					local panelProgressString = wticc(progressCount .. "/" .. bossCount .. miog.DIFFICULTY[sortedProgress.progress.difficulty].shortName, miog.DIFFICULTY[sortedProgress.progress.difficulty].color)
					local basicProgressString = wticc(progressCount .. "/" .. bossCount, sortedProgress.progress.raid.ordinal == 1 and miog.DIFFICULTY[sortedProgress.progress.difficulty].color or miog.DIFFICULTY[sortedProgress.progress.difficulty].desaturated)

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

						local raidIconFrame = miog.createFleetingTexture(poolFrame.texturePool, miog.RAID_INFO[sortedProgress.progress.raid.mapId][bossCount + 1].icon, raidPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 2, miog.C.APPLICANT_MEMBER_HEIGHT - 2)
						raidIconFrame:SetPoint("LEFT", raidPanel.rows[1], "LEFT", lastIcon and halfRowWidth or 0, 0)
						raidIconFrame:SetMouseClickEnabled(true)
						raidIconFrame:SetDrawLayer("OVERLAY")
						raidIconFrame:SetScript("OnMouseDown", function()
							--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
							EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, nil, nil, nil, nil)

						end)

						lastIcon = true

						local raidNameString = miog.createFleetingFontString(poolFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE, raidPanel)
						raidNameString:SetPoint("LEFT", raidIconFrame, "RIGHT", 2, 0)
						raidNameString:SetText(sortedProgress.progress.raid.shortName .. ":")

						higherDifficultyNumber = sortedProgress.progress.difficulty

						progressFrame = miog.createFleetingFontString(poolFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE,  raidPanel, halfRowWidth, miog.C.APPLICANT_MEMBER_HEIGHT)
						progressFrame:SetText(panelProgressString)
						progressFrame:SetPoint("TOPLEFT", raidIconFrame, "BOTTOMLEFT")

						local currentDiffColor = {miog.ITEM_QUALITY_COLORS[higherDifficultyNumber+1].color:GetRGBA()}

						for bossIndex = 1, bossCount, 1 do
							if(bossIndex <= bossCount) then
								local bossFrame = miog.createFleetingTexture(poolFrame.texturePool, miog.RAID_INFO[sortedProgress.progress.raid.mapId][bossIndex].icon, raidPanel, rowHeight, rowHeight)
								bossFrame:SetPoint("TOPLEFT", bossIndex == 1 and progressFrame or bossIndex == 2 and raidPanel.textureRows[raidIndex][bossIndex - 1] or raidPanel.textureRows[raidIndex][bossIndex - 2],
								bossIndex == 2 and "TOPRIGHT" or "BOTTOMLEFT", bossIndex == 1 and 2 or bossIndex == 2 and 5 or 0, bossIndex == 1 and -2 or bossIndex == 2 and 0 or -5)
								bossFrame:SetDrawLayer("OVERLAY", -4)
								bossFrame:SetMouseClickEnabled(true)
								bossFrame:SetScript("OnMouseDown", function()

									--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
									EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, select(3, EJ_GetEncounterInfoByIndex(bossIndex, instanceID)), nil, nil, nil)

								end)

								bossFrame.border = miog.createFleetingTexture(poolFrame.texturePool, nil, raidPanel, bossFrame:GetSize())
								bossFrame.border:SetDrawLayer("OVERLAY", -5)
								bossFrame.border:SetPoint("TOPLEFT", bossFrame, "TOPLEFT", -2, 2)

								bossFrame:SetSize(bossFrame:GetWidth()-4, bossFrame:GetHeight()-4)

								if(sortedProgress.progress.killsPerBoss) then
									local desaturated
									local numberOfBossKills = sortedProgress.progress.killsPerBoss[bossIndex]

									if(numberOfBossKills > 0) then
										desaturated = false

										bossFrame.border:SetColorTexture(unpack(currentDiffColor))

									elseif(numberOfBossKills == 0) then
										desaturated = true
										bossFrame.border:SetColorTexture(0, 0, 0, 0)

									end

									bossFrame:SetDesaturated(desaturated)

								end

								local bossNumber = miog.createFleetingFontString(poolFrame.fontStringPool, miog.C.TEXT_ROW_FONT_SIZE, raidPanel)
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
										bossFrame.border:SetColorTexture(miog.ITEM_QUALITY_COLORS[sortedProgress.progress.difficulty + 1].color:GetRGBA())
										bossFrame:SetDesaturated(false)

									elseif(sortedProgress.progress.killsPerBoss[bossIndex] == 0 and desaturated == true) then
										bossFrame.border:SetColorTexture(0, 0, 0, 0)
									end

								else
									if(progressCount == bossCount) then
										if(desaturated == true) then
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
					mainProgressText = mainProgressText .. wticc(miog.DIFFICULTY[sortedProgress.progress.difficulty].shortName .. ":" .. sortedProgress.progress.progressCount .. "/" .. sortedProgress.progress.raid.bossCount, miog.DIFFICULTY[sortedProgress.progress.difficulty].color) .. " "

					if(miog.F.LISTED_CATEGORY_ID == 3) then
						if(primaryIndicator:GetText() == nil) then
							primaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))

						end

						if(secondaryIndicator:GetText() == nil) then
							secondaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))

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
					primaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))

				end

				if(secondaryIndicator:GetText() == nil) then
					secondaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))

				end
			end

		else
			raidPanel.rows[1].FontString:SetText(wticc("NO RAIDING DATA", miog.CLRSCC["red"]))
			raidPanel.rows[1].FontString:SetPoint("LEFT", raidPanel.rows[1], "LEFT", 2, 0)

			if(miog.F.LISTED_CATEGORY_ID == 3) then
				primaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))
				secondaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))

			end

		end

	else -- If RaiderIO is not installed
		mythicPlusPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))
		mythicPlusPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)

		raidPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))
		raidPanel.rows[1].FontString:SetPoint("LEFT", generalInfoPanel.rows[1], "LEFT", 2, 0)

		if(miog.F.LISTED_CATEGORY_ID == 3) then
			primaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))
			secondaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))

		end

	end
end

local function createApplicantFrame(applicantID)

	local applicantData = miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(applicantID) or C_LFGList.GetApplicantInfo(applicantID)

	if(applicantData) then
		local activityID = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.activityID or 0

		applicantViewer_ExpandedFrameList[applicantID] = applicantViewer_ExpandedFrameList[applicantID] or {}

		local applicantFrame = miog.createBasicFrame("applicant", "ResizeLayoutFrame, BackdropTemplate", miog.applicationViewer.applicantPanel.container)
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

			local applicantMemberFrame = miog.createFleetingFrame(applicantFrame.framePool, "ResizeLayoutFrame, BackdropTemplate", applicantFrame)
			applicantMemberFrame.fixedWidth = applicantFrame.fixedWidth - 2
			applicantMemberFrame.minimumHeight = 20
			applicantMemberFrame:SetPoint("TOP", applicantFrame.memberFrames[applicantIndex-1] or applicantFrame, applicantFrame.memberFrames[applicantIndex-1] and "BOTTOM" or "TOP", 0, applicantIndex > 1 and -miog.C.APPLICANT_PADDING or -1)
			applicantFrame.memberFrames[applicantIndex] = applicantMemberFrame

			if(MIOG_SavedSettings.favouredApplicants.table[name]) then
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

			local expandFrameButton = Mixin(miog.createFleetingFrame(applicantFrame.framePool, "UIButtonTemplate", basicInformationPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), MultiStateButtonMixin)
			expandFrameButton:OnLoad()
			expandFrameButton:SetMaxStates(2)
			expandFrameButton:SetTexturesForBaseState("UI-HUD-ActionBar-PageDownArrow-Up", "UI-HUD-ActionBar-PageDownArrow-Down", "UI-HUD-ActionBar-PageDownArrow-Mouseover", "UI-HUD-ActionBar-PageDownArrow-Disabled")
			expandFrameButton:SetTexturesForState1("UI-HUD-ActionBar-PageUpArrow-Up", "UI-HUD-ActionBar-PageUpArrow-Down", "UI-HUD-ActionBar-PageUpArrow-Mouseover", "UI-HUD-ActionBar-PageUpArrow-Disabled")
			expandFrameButton:SetState(false)
			expandFrameButton:SetPoint("LEFT", basicInformationPanel, "LEFT", 0, 0)
			expandFrameButton:SetFrameStrata("DIALOG")

			if(applicantViewer_ExpandedFrameList[applicantID][applicantIndex]) then
				expandFrameButton:AdvanceState()

			end

			expandFrameButton:RegisterForClicks("LeftButtonDown")
			expandFrameButton:SetScript("OnClick", function()
				if(applicantMemberFrame.detailedInformationPanel) then
					expandFrameButton:AdvanceState()
					applicantViewer_ExpandedFrameList[applicantID][applicantIndex] = not applicantMemberFrame.detailedInformationPanel:IsVisible()
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

			applicantMemberFrame.basicInformationPanel.nameFrame = nameFrame

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

			basicInformationPanel.primaryIndicator = primaryIndicator

			local secondaryIndicator = miog.createFleetingFontString(applicantFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationPanel, basicInformationPanel.fixedWidth*0.11, basicInformationPanel.maximumHeight)
			secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 1, 0)
			secondaryIndicator:SetJustifyH("CENTER")

			basicInformationPanel.secondaryIndicator = secondaryIndicator

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
				groupFrame:SetScript("OnEnter", function()
					GameTooltip:SetOwner(groupFrame, "ANCHOR_CURSOR")
					GameTooltip:SetText("Premades with " .. applicantFrame.memberFrames[1].basicInformationPanel.nameFrame.FontString:GetText())
					GameTooltip:Show()

				end)
				groupFrame:SetScript("OnLeave", function()
					GameTooltip:Hide()

				end)

			end

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

			if(applicantIndex == 1 and miog.F.CAN_INVITE or applicantIndex == 1 and miog.F.IS_IN_DEBUG_MODE) then
			else
				declineButton:Hide()
				inviteButton:Hide()

			end


			--[[
			ROW LAYOUT

			1-4 Comment
			5 Score for prev. season
			6 Score for main current/prev. season
			7 Applicant alternative roles + race
			8 M+ keys done +5 +10 +15 +20 (+25 not available from Raider.IO addon data)
			9 Region + Realm
 
			]]

			gatherRaiderIODisplayData(nameTable[1], nameTable[2], applicantFrame, applicantMemberFrame)

			local generalInfoPanel = applicantMemberFrame.detailedInformationPanel.tabPanel.generalInfoPanel

			generalInfoPanel.rows[1].FontString:SetJustifyV("TOP")
			generalInfoPanel.rows[1].FontString:SetPoint("TOPLEFT", generalInfoPanel.rows[1], "TOPLEFT", 0, -5)
			generalInfoPanel.rows[1].FontString:SetPoint("BOTTOMRIGHT", applicantMemberFrame.detailedInformationPanel.tabPanel.rows[4], "BOTTOMRIGHT", 0, 0)
			generalInfoPanel.rows[1].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. ((applicantData.comment and applicantData.comment) or ""))
			generalInfoPanel.rows[1].FontString:SetWordWrap(true)
			generalInfoPanel.rows[1].FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)
			generalInfoPanel.rows[7].FontString:SetText("Role: ")

			if(tank) then
				generalInfoPanel.rows[7].FontString:SetText(generalInfoPanel.rows[7].FontString:GetText() .. miog.C.TANK_TEXTURE)

			end

			if(healer) then
				generalInfoPanel.rows[7].FontString:SetText(generalInfoPanel.rows[7].FontString:GetText() .. miog.C.HEALER_TEXTURE)

			end

			if(damager) then
				generalInfoPanel.rows[7].FontString:SetText(generalInfoPanel.rows[7].FontString:GetText() .. miog.C.DPS_TEXTURE)

			end

			if(raceID and miog.RACES[raceID]) then
				generalInfoPanel.rows[7].FontString:SetText(generalInfoPanel.rows[7].FontString:GetText() ..  " " .. _G["RACE"] .. ": " .. CreateAtlasMarkup(miog.RACES[raceID], miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT))

			end

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
					local difficulty = miog.DIFFICULTY[-1] -- NO DATA
					primaryIndicator:SetText(wticc("0", difficulty.color))
					secondaryIndicator:SetText(wticc("0", difficulty.color))

				end

			elseif(miog.F.LISTED_CATEGORY_ID == (4 or 7 or 8 or 9)) then
				primaryIndicator:SetText(wticc(tostring(pvpData.rating), miog.createCustomColorForScore(pvpData.rating):GenerateHexColor()))

				local tierResult = miog.simpleSplit(pvpData.tier, " ")
				secondaryIndicator:SetText(strsub(tierResult[1], 0, 2) .. ((tierResult[2] and "" .. tierResult[2]) or ""))

			end

			basicInformationPanel:MarkDirty()
			applicantMemberFrame.detailedInformationPanel:MarkDirty()
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
							local profile, primarySortAttribute, secondarySortAttribute

							if(miog.F.IS_RAIDERIO_LOADED) then
								profile = RaiderIO.GetProfile(nameTable[1], nameTable[2], miog.F.CURRENT_REGION)

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

	return unsortedMainApplicantsList
end

local function addOrShowApplicant(applicantID)
	if(applicantSystem.applicantMember[applicantID].frame) then
		applicantSystem.applicantMember[applicantID].frame:Show()

	else
		applicantSystem.applicantMember[applicantID].status = "inProgress"
		createApplicantFrame(applicantID)

	end

	applicantSystem.applicantMember[applicantID].frame.layoutIndex = applicationFrameIndex

	miog.applicationViewer.applicantPanel.container:MarkDirty()
	applicationFrameIndex = applicationFrameIndex + 1
end

local function checkApplicantList(forceReorder, applicantID)
	local unsortedList = gatherSortData()

	miog.applicationViewer.footerBar.applicantNumberFontString:SetText(#unsortedList)

	local allSystemMembers = {}

	if(forceReorder) then
		for k, v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame:Hide()
				v.frame.layoutIndex = nil

			end

			allSystemMembers[k] = true

		end

		miog.applicationViewer.applicantPanel.container:MarkDirty()

		applicationFrameIndex = 0

		if(unsortedList[1]) then
			table.sort(unsortedList, sortApplicantList)

			for _, listEntry in ipairs(unsortedList) do
				allSystemMembers[listEntry[1].index] = nil

				for _, v in pairs(listEntry) do
					if((v.role == "TANK" and miog.applicationViewer.buttonPanel.filterPanel.roleFilterPanel.RoleButtons[1]:GetChecked()
					or v.role == "HEALER" and miog.applicationViewer.buttonPanel.filterPanel.roleFilterPanel.RoleButtons[2]:GetChecked()
					or v.role == "DAMAGER" and miog.applicationViewer.buttonPanel.filterPanel.roleFilterPanel.RoleButtons[3]:GetChecked())) then
						if(miog.applicationViewer.buttonPanel.filterPanel.classFilterPanel.ClassPanels[miog.CLASSFILE_TO_ID[v.class]].Button:GetChecked()) then
							if(miog.applicationViewer.buttonPanel.filterPanel.classFilterPanel.ClassPanels[miog.CLASSFILE_TO_ID[v.class]].specFilterPanel.SpecButtons[v.specID]:GetChecked()) then
								addOrShowApplicant(listEntry[1].index)
								break
							end
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

			miog.applicantFramePool:Release(applicantSystem.applicantMember[k].frame)

			applicantSystem.applicantMember[k] = nil

		end
	end

	miog.applicationViewer.applicantPanel.container:MarkDirty()
end

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

	currentAverageExecuteTime[#currentAverageExecuteTime+1] = endTime - startTime
end

local function updateSpecFrames()
	miog.releaseRaidRosterPool()

	local indexedGroup = {}
	groupSystem.specCount = {}

	local numOfMembers = GetNumGroupMembers()

	for guid, groupMember in pairs(groupSystem.groupMember) do
		if(groupMember.specID ~= nil and groupMember.specID ~= 0) then
			if(UnitGUID(groupMember.unitID) == guid) then
				local unitInPartyOrRaid = UnitInRaid(groupMember.unitID) or UnitInParty(groupMember.unitID) or miog.F.LFG_STATE == "solo"

				if(unitInPartyOrRaid) then
					indexedGroup[#indexedGroup+1] = groupMember
					indexedGroup[#indexedGroup].guid = guid

					miog.applicationViewer.classPanel.progressText:SetText(#indexedGroup .. "/" .. numOfMembers)

					groupSystem.specCount[groupMember.specID] = groupSystem.specCount[groupMember.specID] and groupSystem.specCount[groupMember.specID] + 1 or 1
				end
			end
		end
	end


	if(#indexedGroup >= numOfMembers) then
		miog.applicationViewer.classPanel.progressText:SetText("")

	end

	local specCounter = 1

	for classID, classEntry in ipairs(miog.CLASSES) do
		for _, v in ipairs(classEntry.specs) do
			local currentSpecFrame = miog.applicationViewer.classPanel.classFrames[classID].specPanel.specFrames[v]

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

		miog.applicationViewer.classPanel.classFrames[classID].specPanel:MarkDirty()

	end

	miog.applicationViewer.classPanel:MarkDirty()

	if(#indexedGroup < 6) then
		if(groupSystem.roleCount["TANK"] < 1) then
			indexedGroup[#indexedGroup + 1] = {guid = "emptyTank", unitID = "emptyTank", name = "afkTank", classID = 20, role = "TANK", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			groupSystem.roleCount["TANK"] = groupSystem.roleCount["TANK"] + 1
		end

		if(groupSystem.roleCount["HEALER"] < 1 and #indexedGroup < 6) then
			indexedGroup[#indexedGroup + 1] = {guid = "emptyHealer", unitID = "emptyHealer", name = "afkHealer", classID = 21, role = "HEALER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			groupSystem.roleCount["HEALER"] = groupSystem.roleCount["HEALER"] + 1

		end

		for i = 1, 3 - groupSystem.roleCount["DAMAGER"], 1 do
			if(groupSystem.roleCount["DAMAGER"] < 3 and #indexedGroup < 6) then
				indexedGroup[#indexedGroup + 1] = {guid = "emptyDPS" .. i, unitID = "emptyDPS" .. i, name = "afkDPS" .. i, classID = 22, role = "DAMAGER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
				groupSystem.roleCount["DAMAGER"] = groupSystem.roleCount["DAMAGER"] + 1

			end

		end

	end

	table.sort(indexedGroup, function(k1, k2)
		if(k1.role ~= k2.role) then
			return k1.role > k2.role

		else
			return k1.classID > k2.classID

		end
	end)

	local lastIcon

	if(GetNumGroupMembers() < 6) then
		local counter = 1

		lastIcon = nil

		for index, groupMember in ipairs(indexedGroup) do
			local specIcon = groupMember.icon or miog.SPECIALIZATIONS[groupMember.specID].squaredIcon
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.applicationViewer.titleBar.groupMemberListing, miog.applicationViewer.titleBar.factionIconSize - 2, miog.applicationViewer.titleBar.factionIconSize - 2, "Texture", specIcon)
			classIconFrame.layoutIndex = index
			classIconFrame:SetPoint("LEFT", lastIcon or miog.applicationViewer.titleBar.groupMemberListing, lastIcon and "RIGHT" or "LEFT")
			classIconFrame:SetFrameStrata("DIALOG")

			if(groupMember.classID <= 13) then
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

			if(groupMember.classID <= 13) then
				local color = C_ClassColor.GetClassColor(miog.CLASSES[groupMember.classID].name)
				miog.createFrameBorder(classIconFrame, 1, color.r, color.g, color.b, 1)

			end

			lastIcon = classIconFrame

			counter = counter + 1

			if(counter == 6) then
				break
			end

		end

	end

	miog.applicationViewer.titleBar.groupMemberListing:MarkDirty()

end

local function requestInspectData()

	for _, v in pairs(inspectQueue) do
		C_Timer.After((lastNotifyTime - GetTimePreciseSec()) > miog.C.BLIZZARD_INSPECT_THROTTLE and 0 or miog.C.BLIZZARD_INSPECT_THROTTLE,
		function()
			if(UnitGUID(v)) then
				NotifyInspect(v)

				-- LAST NOTIFY SAVED SO THE MAX TIME BETWEEN NOTIFY CALLS IS ~1.5s
				lastNotifyTime = GetTimePreciseSec()

			else
				--GUID gone

			end
		end)

		coroutine.yield(inspectCoroutine)
	end

	coroutine.yield(inspectCoroutine)

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

	miog.F.LFG_STATE = miog.checkLFGState()
	local numOfMembers = GetNumGroupMembers()

	for groupIndex = 1, miog.MAX_GROUP_SIZES[miog.F.LFG_STATE], 1 do
		local unitID = ((miog.F.LFG_STATE == "raid" or (miog.F.LFG_STATE == "party" and groupIndex ~= miog.MAX_GROUP_SIZES["party"])) and miog.F.LFG_STATE..groupIndex) or "player"

		local guid = UnitGUID(unitID)

		if(guid) then
			local _, _, _, _, _, classFile, _, _, _, _, _, role = GetRaidRosterInfo(groupIndex)

			local specID = GetInspectSpecialization(unitID)

			groupSystem.groupMember[guid] = {
				unitID = unitID,
				name = UnitName(unitID),
				classID = select(2, UnitClassBase(unitID)) or classFile and miog.CLASSFILE_TO_ID[classFile] or miog.CLASSFILE_TO_ID[select(2, GetPlayerInfoByGUID(guid))],
				role = role == "NONE" and "DAMAGER" or UnitGroupRolesAssigned(unitID) or GetSpecializationRoleByID(specID) or role,
				specID = groupSystem.inspectedGUIDs[guid] or specID ~= 0 and specID or nil
			}

			local member = groupSystem.groupMember[guid]

			if(not groupSystem.groupMember[guid].specID) then
				if(guid ~= miog.C.PLAYER_GUID and (miog.F.LFG_STATE == "raid" or miog.F.LFG_STATE == "party")) then
					inspectQueue[guid] = unitID

				else
					member.specID = GetSpecializationInfo(GetSpecialization())
					member.classID = select(2, UnitClassBase(unitID))
					member.role = member.role or GetSpecializationRoleByID(member.specID)

				end

			else
				groupSystem.inspectedGUIDs[guid] = groupSystem.groupMember[guid].specID

			end

			if(member.classID) then
				groupSystem.classCount[member.classID] = groupSystem.classCount[member.classID] and groupSystem.classCount[member.classID] + 1 or 1

			end

			groupSystem.roleCount[member.role] = groupSystem.roleCount[member.role] + 1

			updateSpecFrames()

		else
			--Unit does not exist

		end

	end

	if(numOfMembers < 6) then
		miog.applicationViewer.titleBar.groupMemberListing.FontString:SetText("")

	else
		miog.applicationViewer.titleBar.groupMemberListing.FontString:SetText(groupSystem.roleCount["TANK"] .. "/" .. groupSystem.roleCount["HEALER"] .. "/" .. groupSystem.roleCount["DAMAGER"])

	end

	local keys = {}

	for key, _ in pairs(groupSystem.classCount) do
		table.insert(keys, key)

	end

	table.sort(keys, function(a, b) return groupSystem.classCount[a] > groupSystem.classCount[b] end)

	local counter = 1

	for _, classID in ipairs(keys) do
		local classCount = groupSystem.classCount[classID]
		local currentClassFrame = miog.applicationViewer.classPanel.classFrames[classID]
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

		miog.applicationViewer.classPanel:MarkDirty()

	end

	updateSpecFrames()

	checkCoroutineStatus()

end

local function insertLFGInfo()
	local activityInfo = C_LFGList.GetActivityInfoTable(miog.F.ACTIVE_ENTRY_INFO.activityID)

	miog.F.LISTED_CATEGORY_ID = activityInfo.categoryID

	miog.applicationViewer.buttonPanel.sortByCategoryButtons.secondary:Enable()

	if(activityInfo.categoryID == 2) then --Dungeons
		miog.F.CURRENT_DUNGEON_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DUNGEON_DIFFICULTY
		miog.applicationViewer.infoPanel.affixFrame:Show()

	elseif(activityInfo.categoryID == 3) then --Raids
		miog.F.CURRENT_RAID_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_RAID_DIFFICULTY
		miog.applicationViewer.infoPanel.affixFrame:Hide()
	end

	miog.applicationViewer.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID] and miog.GROUP_ACTIVITY_BACKGROUNDS[activityInfo.groupFinderActivityGroupID].file 
	or miog.ACTIVITY_BACKGROUNDS[activityInfo.categoryID]
	miog.applicationViewer.infoPanelBackdropFrame:ApplyBackdrop()

	miog.applicationViewer.titleBar.titleStringFrame.FontString:SetText(miog.F.ACTIVE_ENTRY_INFO.name)
	miog.applicationViewer.infoPanel.activityNameFrame:SetText(activityInfo.fullName)

	miog.applicationViewer.listingSettingPanel.privateGroupFrame.active = miog.F.ACTIVE_ENTRY_INFO.privateGroup
	miog.applicationViewer.listingSettingPanel.privateGroupFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. (miog.F.ACTIVE_ENTRY_INFO.privateGroup and "/infoIcons/questionMark_Yellow.png" or "/infoIcons/questionMark_Grey.png"))

	if(miog.F.ACTIVE_ENTRY_INFO.playstyle) then
		local playStyleString = (activityInfo.isMythicPlusActivity and miog.PLAYSTYLE_STRINGS["mPlus"..miog.F.ACTIVE_ENTRY_INFO.playstyle]) or
		(activityInfo.isMythicActivity and miog.PLAYSTYLE_STRINGS["mZero"..miog.F.ACTIVE_ENTRY_INFO.playstyle]) or
		(activityInfo.isCurrentRaidActivity and miog.PLAYSTYLE_STRINGS["raid"..miog.F.ACTIVE_ENTRY_INFO.playstyle]) or
		((activityInfo.isRatedPvpActivity or activityInfo.isPvpActivity) and miog.PLAYSTYLE_STRINGS["pvp"..miog.F.ACTIVE_ENTRY_INFO.playstyle])

		miog.applicationViewer.listingSettingPanel.playstyleFrame.tooltipText = playStyleString

	else
		miog.applicationViewer.listingSettingPanel.playstyleFrame.tooltipText = ""

	end

	if(miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore and activityInfo.categoryID == 2 or miog.F.ACTIVE_ENTRY_INFO.requiredPvpRating and activityInfo.categoryID == (4 or 7 or 8 or 9)) then
		miog.applicationViewer.listingSettingPanel.ratingFrame.tooltipText = "Required rating: " .. miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or miog.F.ACTIVE_ENTRY_INFO.requiredPvpRating
		miog.applicationViewer.listingSettingPanel.ratingFrame.FontString:SetText(miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or miog.F.ACTIVE_ENTRY_INFO.requiredPvpRating)

		miog.applicationViewer.listingSettingPanel.ratingFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. (miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore and "/infoIcons/skull.png" or miog.F.ACTIVE_ENTRY_INFO.requiredPvpRating and "/infoIcons/spear.png"))

	else
		miog.applicationViewer.listingSettingPanel.ratingFrame.FontString:SetText("----")
		miog.applicationViewer.listingSettingPanel.ratingFrame.tooltipText = ""

	end

	if(miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel > 0) then
		miog.applicationViewer.listingSettingPanel.itemLevelFrame.FontString:SetText(miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel)
		miog.applicationViewer.listingSettingPanel.itemLevelFrame.tooltipText = "Required itemlevel: " .. miog.F.ACTIVE_ENTRY_INFO.requiredItemLevel

	else
		miog.applicationViewer.listingSettingPanel.itemLevelFrame.FontString:SetText("---")
		miog.applicationViewer.listingSettingPanel.itemLevelFrame.tooltipText = ""

	end

	if(miog.F.ACTIVE_ENTRY_INFO.voiceChat ~= "") then
		LFGListFrame.EntryCreation.VoiceChat.CheckButton:SetChecked(true)

	end

	if(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked()) then

		miog.applicationViewer.listingSettingPanel.voiceChatFrame.tooltipText = miog.F.ACTIVE_ENTRY_INFO.voiceChat
		miog.applicationViewer.listingSettingPanel.voiceChatFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOn.png")
	else

		miog.applicationViewer.listingSettingPanel.voiceChatFrame.tooltipText = ""
		miog.applicationViewer.listingSettingPanel.voiceChatFrame.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOff.png")

	end

	if(miog.F.ACTIVE_ENTRY_INFO.isCrossFactionListing == true) then
		miog.applicationViewer.titleBar.factionFrame.Texture:SetTexture(2437241)

	else
		local playerFaction = UnitFactionGroup("player")
		miog.applicationViewer.titleBar.factionFrame.Texture:SetTexture(playerFaction == "Alliance" and 2173919 or playerFaction == "Horde" and 2173920)

	end

	if(miog.F.ACTIVE_ENTRY_INFO.comment ~= "") then
		miog.applicationViewer.infoPanel.commentFrame.FontString:SetHeight(2500)
		miog.applicationViewer.infoPanel.commentFrame.FontString:SetText("Description: " .. miog.F.ACTIVE_ENTRY_INFO.comment)
		miog.applicationViewer.infoPanel.commentFrame.FontString:SetHeight(miog.applicationViewer.infoPanel.commentFrame.FontString:GetStringHeight())
		miog.applicationViewer.infoPanel.commentFrame:SetHeight(miog.applicationViewer.infoPanel.commentFrame.FontString:GetStringHeight())

	else
		miog.applicationViewer.infoPanel.commentFrame.FontString:SetText("")

	end

	miog.applicationViewer.listingSettingPanel:MarkDirty()
end

local function releaseAllSearchResultFrames()
	for _,v in pairs(searchResultSystem.resultFrames) do
		v.fontStringPool:ReleaseAll()
		v.texturePool:ReleaseAll()
		v.framePool:ReleaseAll()

	end

	miog.searchResultFramePool:ReleaseAll()

	miog.searchPanel.resultPanel.container:MarkDirty()

	searchResultSystem.resultFrames = {}

	miog.searchPanel.footerBar.groupNumberFontString:SetText(0)
end

local function computeResultMembers(resultID, numMembers, mapID)
	local orderedList = {}
	local resultFrame = searchResultSystem.resultFrames[resultID]

	if(resultFrame.memberFrames) then
		for _, v in pairs(resultFrame.memberFrames) do
			if(v.leaderCrown) then
				resultFrame.texturePool:Release(v.leaderCrown)

			end

			resultFrame.texturePool:Release(v.border)
			resultFrame.texturePool:Release(v)
		end
	end

	local roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
	}

	for i = 1, numMembers, 1 do
		local role, class, classLocalized, specLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i)

		orderedList[i] = {leader = i == 1 and true or false, role = role, class = class, specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]}

		if(role) then
			roleCount[role] = roleCount[role] + 1

		end
	end

	if(miog.F.LISTED_CATEGORY_ID == 3) then
		resultFrame.basicInformationPanel.secondFrame.resultMemberComp:SetText(roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"])

		--[[if(miog.RAID_INFO[mapID]) then
			resultFrame.bossFrames = {}

			local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(resultID)
			local encountersDefeated = {}

			if(encounterInfo) then
				for _, v in pairs(encounterInfo) do
					encountersDefeated[v] = true
				end
			end

			for i = 1, #miog.RAID_INFO[mapID] - 1, 1 do
				local resultBossFrame = miog.createFleetingTexture(resultFrame.texturePool, miog.RAID_INFO[mapID][i].icon, basicInformationFirstFrame, 15, 15)
				resultBossFrame:SetPoint("LEFT", resultFrame.bossFrames[i-1] or difficultyZoneFrame, "RIGHT", 3, 0)
				resultBossFrame:SetDrawLayer("ARTWORK")
				resultFrame.bossFrames[i] = resultBossFrame
				
				if(encountersDefeated[miog.RAID_INFO[mapID][i].name]) then
					resultBossFrame:SetDesaturated(true)
					
				end
			end
		end]]
	else
		if(#orderedList < 5) then
			if(roleCount["TANK"] == 0) then
				orderedList[#orderedList + 1] = {class = "DUMMY", role = "TANK", specID = 20}
				roleCount["TANK"] = roleCount["TANK"] + 1
			end

			if(roleCount["HEALER"] == 0 and #orderedList < 6) then
				orderedList[#orderedList + 1] = {class = "DUMMY", role = "HEALER", specID = 20}
				roleCount["HEALER"] = roleCount["HEALER"] + 1

			end

			for i = 1, 3 - roleCount["DAMAGER"], 1 do
				if(roleCount["DAMAGER"] < 3 and #orderedList < 6) then
					orderedList[#orderedList + 1] = {class = "DUMMY", role = "DAMAGER", specID = 20}
					roleCount["DAMAGER"] = roleCount["DAMAGER"] + 1
				end

			end

		end

		table.sort(orderedList, function(k1, k2)
			if(k1.role ~= k2.role) then
				return k1.role > k2.role

			elseif(k1.spec ~= k2.spec) then
				return k1.spec > k2.spec

			else
				return k1.class > k2.class

			end

		end)

		local resultMemberPanel = resultFrame.basicInformationPanel.secondFrame.memberPanel

		for i = 1, #orderedList, 1 do
			local resultMemberFrame = miog.createFleetingTexture(resultFrame.texturePool, miog.SPECIALIZATIONS[orderedList[i].specID].squaredIcon, resultMemberPanel, resultMemberPanel.fixedHeight, resultMemberPanel.fixedHeight)
			resultMemberFrame.layoutIndex = i
			resultMemberFrame:SetDrawLayer("OVERLAY", -4)
			resultFrame.memberFrames[i] = resultMemberFrame

			resultMemberFrame.border = miog.createFleetingTexture(resultFrame.texturePool, nil, resultMemberPanel)
			resultMemberFrame.border:SetDrawLayer("OVERLAY", -5)
			resultMemberFrame.border:SetPoint("TOPLEFT", resultMemberFrame, "TOPLEFT", -2, 2)
			resultMemberFrame.border:SetPoint("BOTTOMRIGHT", resultMemberFrame, "BOTTOMRIGHT", 2, -2)

			if(orderedList[i].class ~= "DUMMY") then
				resultMemberFrame.border:SetColorTexture(C_ClassColor.GetClassColor(orderedList[i].class):GetRGBA())
			end

			if(orderedList[i].leader) then
				local leaderCrown = miog.createFleetingTexture(resultFrame.texturePool, miog.C.STANDARD_FILE_PATH .. "/infoIcons/leaderIcon.png", resultMemberPanel, resultMemberPanel.fixedHeight, resultMemberPanel.fixedHeight)
				leaderCrown:SetPoint("CENTER", resultMemberFrame, "TOP")
				leaderCrown:SetDrawLayer("OVERLAY", -3)
				resultMemberFrame.leaderCrown = leaderCrown

				resultMemberFrame:SetMouseMotionEnabled(true)
				resultMemberFrame:SetScript("OnEnter", function()
					GameTooltip:SetOwner(resultMemberFrame, "ANCHOR_CURSOR")
					GameTooltip:AddLine(format(_G["LFG_LIST_TOOLTIP_LEADER"], resultFrame.name))
					GameTooltip:Show()

				end)
				resultMemberFrame:SetScript("OnLeave", function()
					GameTooltip:Hide()

				end)

			end

		end

	resultMemberPanel:MarkDirty()
	end

end

local function updateResultFrameStatus(resultID, status)
	local resultFrame = searchResultSystem.resultFrames[resultID]

	if(resultFrame) then
		searchResultSystem.applicationStatus[resultID] = status

		if(status ~= "applied") then
			if(status ~= "none") then
				resultFrame.statusFrame:Show()
				resultFrame.statusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[status].statusString, miog.APPLICANT_STATUS_INFO[status].color))
				--resultFrame:SetScript("OnMouseDown", nil)
				
				resultFrame.ageFrame.ageTicker:Cancel()

				resultFrame.basicInformationPanel.firstFrame.cancelApplicationButton:Hide()

				--miog.createFrameBorder(searchResultSystem.resultFrames[resultID], 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGB())
				searchResultSystem.resultFrames[resultID]:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
				searchResultSystem.resultFrames[resultID].background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
			end

			if(status == "inviteaccepted") then
				releaseAllSearchResultFrames()

			end

			if(status == "invitedeclined") then
				resultFrame.statusFrame.inviteButton:Hide()
				resultFrame.statusFrame.declineButton:Hide()

			end

			if(status == "invited") then
				resultFrame.statusFrame.inviteButton:Show()
				resultFrame.statusFrame.declineButton:Show()

				resultFrame.basicInformationPanel.firstFrame.cancelApplicationButton:Hide()

			end
		elseif(status == "applied") then
			--miog.createFrameBorder(searchResultSystem.resultFrames[resultID], 2, CreateColorFromHexString(miog.CLRSCC.green):GetRGB())
			searchResultSystem.resultFrames[resultID]:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.green):GetRGBA())
			searchResultSystem.resultFrames[resultID].background:SetColorTexture(CreateColorFromHexString(miog.CLRSCC.olive):GetRGBA())
			
			searchResultSystem.resultFrames[resultID].basicInformationPanel.firstFrame.cancelApplicationButton:Show()
			searchResultSystem.resultFrames[resultID].layoutIndex = -1
			miog.searchPanel.resultPanel.container:MarkDirty()
			--miog.reorderSearchResultList()
		
		end
		
		searchResultSystem.applicationStatus[resultID] = status

	end
end

local function createResultTooltip(resultID, resultFrame, autoAccept)
	if(C_LFGList.HasSearchResultInfo(resultID)) then
		GameTooltip:SetOwner(resultFrame, "ANCHOR_RIGHT", 25, 0)
		LFGListUtil_SetSearchEntryTooltip(GameTooltip, resultID, autoAccept == true and LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE)
		
	end
end

local function createSearchResultFrame(searchResultData, activityInfo)
	local resultID = searchResultData.searchResultID

	local resultFrame = miog.createBasicFrame("searchResult", "ResizeLayoutFrame, BackdropTemplate", miog.searchPanel.resultPanel.container)
	resultFrame.fixedWidth = miog.C.MAIN_WIDTH - 2
	resultFrame.heightPadding = 1
	resultFrame.minimumHeight = 40
	resultFrame:SetFrameStrata("DIALOG")
	resultFrame:SetScript("OnMouseDown", function(_, button)
		miog.signupToGroup(resultID)
	end)
	resultFrame:SetScript("OnEnter", function()
		createResultTooltip(resultID, resultFrame, searchResultData.autoAccept)
	end)
	resultFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	resultFrame.resultID = resultID + 1
	miog.createFrameBorder(resultFrame, 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGB())

	searchResultSystem.resultFrames[resultID] = resultFrame

	resultFrame.framePool = resultFrame.framePool or CreateFramePoolCollection()
	resultFrame.framePool:GetOrCreatePool("Frame", nil, "BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	resultFrame.framePool:GetOrCreatePool("Frame", nil, "HorizontalLayoutFrame, BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	resultFrame.framePool:GetOrCreatePool("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	resultFrame.framePool:GetOrCreatePool("Button", nil, "IconButtonTemplate, BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	resultFrame.framePool:GetOrCreatePool("Button", nil, "UIButtonTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	resultFrame.framePool:GetOrCreatePool("Button", nil, "UIPanelButtonTemplate", miog.resetFrame):SetResetDisallowedIfNew()

	-- resultID, appStatus, pendingStatus, appDuration, role

	resultFrame.fontStringPool = resultFrame.fontStringPool or CreateFontStringPool(resultFrame, "OVERLAY", nil, "GameTooltipText", miog.resetFontString)
	resultFrame.texturePool = resultFrame.texturePool or CreateTexturePool(resultFrame, "ARTWORK", nil, nil, miog.resetTexture)

	local profile, mythicKeystoneProfile, raidProfile
	
	local nameTable = miog.simpleSplit(searchResultData.leaderName, "-")

	if(not nameTable[2]) then
		nameTable[2] = GetNormalizedRealmName()

		searchResultData.leaderName = nameTable[1] .. "-" .. nameTable[2]

	end

	resultFrame.name = searchResultData.leaderName

	if(miog.F.IS_RAIDERIO_LOADED) then
		profile = RaiderIO.GetProfile(nameTable[1], nameTable[2], miog.F.CURRENT_REGION)

		if(profile ~= nil) then
			mythicKeystoneProfile = profile.mythicKeystoneProfile
			raidProfile = profile.raidProfile

		end
	end

	local resultFrameBackground = miog.createFleetingTexture(resultFrame.texturePool, nil, resultFrame, resultFrame.fixedWidth, resultFrame.minimumHeight)
	resultFrameBackground:SetDrawLayer("BACKGROUND")
	resultFrameBackground:SetAllPoints(true)
	resultFrameBackground:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	resultFrame.background = resultFrameBackground

	local resultFrameStatusFrame = miog.createFleetingFrame(resultFrame.framePool, "BackdropTemplate", resultFrame, nil, nil, "FontString", resultFrame.fontStringPool)
	resultFrameStatusFrame:Hide()
	resultFrameStatusFrame:SetPoint("TOPLEFT", resultFrame, "TOPLEFT", 0, 0)
	resultFrameStatusFrame:SetPoint("BOTTOMRIGHT", resultFrame, "BOTTOMRIGHT", 0, 0)
	resultFrameStatusFrame:SetFrameStrata("FULLSCREEN")
	resultFrameStatusFrame.FontString:SetJustifyH("CENTER")
	--resultFrameStatusFrame.FontString:SetWidth(resultFrame.fixedWidth)
	resultFrameStatusFrame.FontString:SetPoint("TOP", resultFrameStatusFrame, "TOP", 0, -2)
	resultFrameStatusFrame.FontString:Show()

	local statusFrameInviteButton = miog.createFleetingFrame(resultFrame.framePool, "IconButtonTemplate, BackdropTemplate", resultFrameStatusFrame, 20, 20)
	statusFrameInviteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png"
	statusFrameInviteButton.iconSize = 20 - 4
	statusFrameInviteButton:OnLoad()
	statusFrameInviteButton:SetPoint("RIGHT", resultFrameStatusFrame.FontString, "LEFT", -5, 0)
	statusFrameInviteButton:RegisterForClicks("LeftButtonDown")
	statusFrameInviteButton:SetScript("OnClick", function(self, button)
		if(button == "LeftButton") then
			C_LFGList.AcceptInvite(resultID)

		end
	end)
	statusFrameInviteButton:Hide()
	resultFrameStatusFrame.inviteButton = statusFrameInviteButton

	miog.createFrameBorder(statusFrameInviteButton, 2, CreateColorFromHexString(miog.CLRSCC.green):GetRGBA())

	local statusFrameDeclineButton = miog.createFleetingFrame(resultFrame.framePool, "IconButtonTemplate, BackdropTemplate", resultFrameStatusFrame, 20, 20)
	statusFrameDeclineButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	statusFrameDeclineButton.iconSize = 20 - 4
	statusFrameDeclineButton:OnLoad()
	statusFrameDeclineButton:SetPoint("LEFT", resultFrameStatusFrame.FontString, "RIGHT", 5, 0)
	statusFrameDeclineButton:RegisterForClicks("LeftButtonDown")
	statusFrameDeclineButton:SetScript("OnClick", function(self, button)
		if(button == "LeftButton") then
			C_LFGList.DeclineInvite(resultID)

		end
	end)
	statusFrameDeclineButton:Hide()
	resultFrameStatusFrame.declineButton = statusFrameInviteButton

	miog.createFrameBorder(statusFrameDeclineButton, 2, CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())

	local resultFrameStatusFrameBackground = miog.createFleetingTexture(resultFrame.texturePool, nil, resultFrameStatusFrame)
	resultFrameStatusFrameBackground:SetAllPoints(true)
	resultFrameStatusFrameBackground:SetColorTexture(0.1, 0.1, 0.1, 0.77)

	resultFrame.statusFrame = resultFrameStatusFrame

	local basicInformationPanel = miog.createFleetingFrame(resultFrame.framePool, "ResizeLayoutFrame, BackdropTemplate", resultFrame)
	basicInformationPanel.fixedWidth = resultFrame.fixedWidth
	basicInformationPanel.fixedHeight = resultFrame.minimumHeight
	basicInformationPanel:SetPoint("TOPLEFT", resultFrame, "TOPLEFT", 0, 0)
	resultFrame.basicInformationPanel = basicInformationPanel

	local mapID = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].mapID or 0

	local iconFrame = miog.createFleetingTexture(resultFrame.texturePool,
	miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.RAID_INFO[mapID] and miog.RAID_INFO[mapID][#miog.RAID_INFO[mapID]] and miog.RAID_INFO[mapID][#miog.RAID_INFO[mapID]].icon or nil, basicInformationPanel,
	basicInformationPanel.fixedHeight * 0.5, basicInformationPanel.fixedHeight * 0.5)
	iconFrame:SetPoint("TOPLEFT", basicInformationPanel, "TOPLEFT", 2, -2)
	iconFrame:SetMouseClickEnabled(true)
	iconFrame:SetDrawLayer("OVERLAY")
	iconFrame:SetScript("OnMouseDown", function()
		local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)

		--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
		EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

	end)

	iconFrame.border = miog.createFleetingTexture(resultFrame.texturePool, nil, resultFrame)
	iconFrame.border:SetDrawLayer("OVERLAY", -5)
	iconFrame.border:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -1, 1)
	iconFrame.border:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 1, -1)
	local color = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.DIFFICULTY[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].miogColors

	if(color) then
		iconFrame.border:SetColorTexture(color and color.r, color.g, color.b, 1)

	else
		iconFrame.border:SetColorTexture(1, 1, 1, 1)

	end

	local expandFrameButton = Mixin(miog.createFleetingFrame(resultFrame.framePool, "UIButtonTemplate", basicInformationPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), MultiStateButtonMixin)
	expandFrameButton:OnLoad()
	expandFrameButton:SetMaxStates(2)
	expandFrameButton:SetTexturesForBaseState("UI-HUD-ActionBar-PageDownArrow-Up", "UI-HUD-ActionBar-PageDownArrow-Down", "UI-HUD-ActionBar-PageDownArrow-Mouseover", "UI-HUD-ActionBar-PageDownArrow-Disabled")
	expandFrameButton:SetTexturesForState1("UI-HUD-ActionBar-PageUpArrow-Up", "UI-HUD-ActionBar-PageUpArrow-Down", "UI-HUD-ActionBar-PageUpArrow-Mouseover", "UI-HUD-ActionBar-PageUpArrow-Disabled")
	expandFrameButton:SetState(false)
	expandFrameButton:SetPoint("TOP", iconFrame, "BOTTOM", 0, 0)
	expandFrameButton:SetFrameStrata("DIALOG")

	if(searchPanel_ExpandedFrameList[resultID]) then
		expandFrameButton:AdvanceState()

	end

	expandFrameButton:RegisterForClicks("LeftButtonDown")
	expandFrameButton:SetScript("OnClick", function()
		if(resultFrame.detailedInformationPanel) then
			expandFrameButton:AdvanceState()
			searchPanel_ExpandedFrameList[resultID] = not resultFrame.detailedInformationPanel:IsVisible()
			resultFrame.detailedInformationPanel:SetShown(not resultFrame.detailedInformationPanel:IsVisible())
			resultFrame:MarkDirty()

		end

	end)
	basicInformationPanel.expandButton = expandFrameButton

	local basicInformationFirstFrame = miog.createFleetingFrame(resultFrame.framePool, "BackdropTemplate", basicInformationPanel)
	basicInformationFirstFrame:SetWidth(basicInformationPanel.fixedWidth - iconFrame:GetWidth())
	basicInformationFirstFrame:SetHeight(basicInformationPanel.fixedHeight * 0.5)
	basicInformationFirstFrame:SetPoint("TOPLEFT", basicInformationPanel, "TOPLEFT", iconFrame:GetWidth(), 0)
	basicInformationPanel.firstFrame = basicInformationFirstFrame

	if(searchResultData.comment ~= "" and searchResultData.comment ~= nil) then
		local commentFrame = miog.createFleetingTexture(resultFrame.texturePool, 136459, basicInformationFirstFrame, basicInformationFirstFrame:GetHeight() - 10, basicInformationFirstFrame:GetHeight() - 10)
		commentFrame:ClearAllPoints()
		commentFrame:SetDrawLayer("ARTWORK")
		commentFrame:SetPoint("BOTTOMRIGHT", expandFrameButton, "BOTTOMRIGHT", 0, 0)

	end

	local playerIsIgnored = C_FriendList.IsIgnored(searchResultData.leaderName)

	local rioLink = "https://raider.io/characters/" .. miog.F.CURRENT_REGION .. "/" .. miog.REALM_LOCAL_NAMES[nameTable[2]] .. "/" .. nameTable[1]

	-- ALIGNMENT

	local titleFrame = miog.createFleetingFontString(resultFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationFirstFrame, basicInformationFirstFrame:GetWidth() * 0.45, basicInformationFirstFrame:GetHeight())
	titleFrame:SetPoint("LEFT", basicInformationFirstFrame, "LEFT", 5, -1)
	titleFrame:SetText(searchResultData.name)
	titleFrame:SetScript("OnEnter", function()
		createResultTooltip(resultID, resultFrame, searchResultData.autoAccept)
	end)
	titleFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	titleFrame:SetScript("OnMouseDown", function(_, button)
		miog.signupToGroup(resultID)
	end)


	basicInformationFirstFrame.titleFrame = titleFrame

	local primaryIndicator = miog.createFleetingFontString(resultFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationFirstFrame, basicInformationFirstFrame:GetWidth()*0.11, basicInformationFirstFrame:GetHeight())
	primaryIndicator:SetPoint("LEFT", titleFrame, "RIGHT", 5, 0)
	primaryIndicator:SetJustifyH("CENTER")
	basicInformationPanel.primaryIndicator = primaryIndicator

	local secondaryIndicator = miog.createFleetingFontString(resultFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationFirstFrame, basicInformationFirstFrame:GetWidth()*0.11, basicInformationFirstFrame:GetHeight())
	secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 1, 0)
	secondaryIndicator:SetJustifyH("CENTER")
	basicInformationPanel.secondaryIndicator = secondaryIndicator

	local ageFrame = miog.createFleetingFontString(resultFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationFirstFrame, basicInformationFirstFrame:GetWidth()*0.20, basicInformationFirstFrame:GetHeight())
	ageFrame:SetPoint("LEFT", secondaryIndicator, "RIGHT", 1, 0)
	ageFrame:SetJustifyH("CENTER")
	ageFrame:SetText(miog.secondsToClock(searchResultData.age))

	resultFrame.ageFrame = ageFrame

	local ageNumber = searchResultData.age

	local ageTicker = C_Timer.NewTicker(1, function()
		ageNumber = ageNumber + 1
		ageFrame:SetText(miog.secondsToClock(ageNumber))

	end)

	ageFrame.ageTicker = ageTicker

	if(searchResultData.numBNetFriends > 0 or searchResultData.numCharFriends > 0 or searchResultData.numGuildMates > 0) then
		local friendFrame = miog.createFleetingTexture(resultFrame.texturePool, miog.C.STANDARD_FILE_PATH .. "/infoIcons/friend.png", basicInformationFirstFrame, basicInformationFirstFrame:GetHeight() - 3, basicInformationFirstFrame:GetHeight() - 3)
		friendFrame:SetPoint("LEFT", ageFrame, "RIGHT", 3, 1)
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

	local cancelApplicationButton = miog.createFleetingFrame(resultFrame.framePool, "IconButtonTemplate, BackdropTemplate", basicInformationFirstFrame, basicInformationFirstFrame:GetHeight(), basicInformationFirstFrame:GetHeight())
	cancelApplicationButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	cancelApplicationButton.iconSize = basicInformationFirstFrame:GetHeight() - 4
	cancelApplicationButton:OnLoad()
	cancelApplicationButton:SetPoint("RIGHT", basicInformationFirstFrame, "RIGHT")
	cancelApplicationButton:RegisterForClicks("LeftButtonDown")
	cancelApplicationButton:SetScript("OnClick", function(self, button)
		if(button == "LeftButton") then
			local _, appStatus = C_LFGList.GetApplicationInfo(resultID)

			if(appStatus == "applied") then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				C_LFGList.CancelApplication(resultID)
			
			end
		end
	end)
	basicInformationFirstFrame.cancelApplicationButton = cancelApplicationButton
	cancelApplicationButton:Hide()

	local dividerFirstSecondFrame = miog.createFleetingTexture(resultFrame.texturePool, nil, resultFrame, basicInformationFirstFrame:GetWidth(), 2, "BORDER")
	dividerFirstSecondFrame:SetAtlas("UI-LFG-DividerLine")
	dividerFirstSecondFrame:SetPoint("BOTTOMRIGHT", basicInformationFirstFrame, "BOTTOMRIGHT", 0, 0)

	local basicInformationSecondFrame = miog.createFleetingFrame(resultFrame.framePool, "BackdropTemplate", basicInformationPanel)
	basicInformationSecondFrame:SetSize(basicInformationFirstFrame:GetWidth(), basicInformationPanel.fixedHeight * 0.5 - 1)
	basicInformationSecondFrame:SetPoint("TOPLEFT", basicInformationFirstFrame, "BOTTOMLEFT", 0, -1)
	basicInformationPanel.secondFrame = basicInformationSecondFrame
	
	local difficultyZoneFrame = miog.createFleetingFontString(resultFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, basicInformationSecondFrame, basicInformationFirstFrame:GetWidth() * 0.45, basicInformationFirstFrame:GetHeight())
	difficultyZoneFrame:SetPoint("LEFT", basicInformationSecondFrame, "LEFT", 5, 0)
	difficultyZoneFrame:SetText(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.DIFFICULTY[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].shortName .. " - " ..
	(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].shortName) or activityInfo.fullName)
	difficultyZoneFrame:SetMouseMotionEnabled(true)
	difficultyZoneFrame:SetScript("OnEnter", function()
		createResultTooltip(resultID, resultFrame, searchResultData.autoAccept)
	end)
	titleFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	difficultyZoneFrame:SetScript("OnMouseDown", function(_, button)
		miog.signupToGroup(resultID)
	end)

	basicInformationSecondFrame.difficultyZoneFrame = difficultyZoneFrame
	
	local resultMemberPanel = miog.createFleetingFrame(resultFrame.framePool, "HorizontalLayoutFrame, BackdropTemplate", basicInformationSecondFrame)
	resultMemberPanel.fixedHeight = basicInformationSecondFrame:GetHeight() - 4
	resultMemberPanel.fixedWidth = 100
	resultMemberPanel.spacing = 14
	resultMemberPanel:SetPoint("LEFT", difficultyZoneFrame, "RIGHT", 5, 0)

	basicInformationSecondFrame.memberPanel = resultMemberPanel

	resultFrame.memberFrames = {}

	local resultMemberComp = miog.createFleetingFontString(resultFrame.fontStringPool, 12, basicInformationSecondFrame)
	resultMemberComp:SetPoint("LEFT", difficultyZoneFrame, "RIGHT", 5, 0)
	basicInformationSecondFrame.resultMemberComp = resultMemberComp

	computeResultMembers(resultID, searchResultData.numMembers, mapID)

	gatherRaiderIODisplayData(nameTable[1], nameTable[2], resultFrame, resultFrame)

	local generalInfoPanel = resultFrame.detailedInformationPanel.tabPanel.generalInfoPanel

	if(searchResultData.comment) then
		generalInfoPanel.rows[1].FontString:SetScript("OnEnter", function()
			GameTooltip:SetOwner(generalInfoPanel.rows[1].FontString, "ANCHOR_CURSOR")
			GameTooltip:SetText(searchResultData.comment)
			GameTooltip:Show()
		end)

		generalInfoPanel.rows[1].FontString:SetScript("OnLeave", function()
			GameTooltip:Hide()
	
		end)
	end

	generalInfoPanel.rows[1].FontString:SetJustifyV("TOP")
	generalInfoPanel.rows[1].FontString:SetPoint("TOPLEFT", generalInfoPanel.rows[1], "TOPLEFT", 0, -5)
	generalInfoPanel.rows[1].FontString:SetPoint("BOTTOMRIGHT", resultFrame.detailedInformationPanel.tabPanel.rows[4], "BOTTOMRIGHT", 0, 0)
	generalInfoPanel.rows[1].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. ((searchResultData.comment and searchResultData.comment) or ""))
	generalInfoPanel.rows[1].FontString:SetWordWrap(true)
	generalInfoPanel.rows[1].FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)
	generalInfoPanel.rows[7].FontString:SetText("Role: ")
	generalInfoPanel.rows[9].FontString:SetText(string.upper(miog.F.CURRENT_REGION) .. "-" .. (nameTable[2] or GetRealmName() or ""))

	if(LFGListFrame.SearchPanel.categoryID == 2) then
		if(searchResultData.leaderOverallDungeonScore > 0) then
			local reqScore = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or 0
			local highestKeyForDungeon

			if(reqScore > searchResultData.leaderOverallDungeonScore) then
				primaryIndicator:SetText(wticc(tostring(searchResultData.leaderOverallDungeonScore), miog.CLRSCC["red"]))

			else
				primaryIndicator:SetText(wticc(tostring(searchResultData.leaderOverallDungeonScore), miog.createCustomColorForScore(searchResultData.leaderOverallDungeonScore):GenerateHexColor()))

			end

			if(searchResultData.leaderDungeonScoreInfo) then
				if(searchResultData.leaderDungeonScoreInfo.finishedSuccess == true) then
					highestKeyForDungeon = wticc(tostring(searchResultData.leaderDungeonScoreInfo.bestRunLevel), miog.C.GREEN_COLOR)

				elseif(searchResultData.leaderDungeonScoreInfo.finishedSuccess == false) then
					highestKeyForDungeon = wticc(tostring(searchResultData.leaderDungeonScoreInfo.bestRunLevel), miog.CLRSCC["red"])

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
	elseif(LFGListFrame.SearchPanel.categoryID == (4 or 7 or 8 or 9)) then
		primaryIndicator:SetText(wticc(tostring(searchResultData.leaderPvpRatingInfo.rating), miog.createCustomColorForScore(searchResultData.leaderPvpRatingInfo.rating):GenerateHexColor()))

		local tierResult = miog.simpleSplit(searchResultData.leaderPvpRatingInfo.tier, " ")
		secondaryIndicator:SetText(strsub(tierResult[1], 0, 2) .. ((tierResult[2] and "" .. tierResult[2]) or ""))

	end
end

local roleRemainingKeyLookup = {
	["TANK"] = "TANK_REMAINING",
	["HEALER"] = "HEALER_REMAINING",
	["DAMAGER"] = "DAMAGER_REMAINING",
}

local function HasRemainingSlotsForBloodlust(resultID)
	local _, _, playerClassID = UnitClass("player")
	if(playerClassID == 3 or playerClassID == 7 or playerClassID == 8 or playerClassID == 13) then
		return true

	end

	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)
	if roles then
		local playerRole = GetSpecializationRole(GetSpecialization())

		if(playerRole == "DAMAGER" and (roles["HEALER_REMAINING"] > 0 or roles["DAMAGER_REMAINING"] > 1)) then
			return true

		end

		if(playerRole == "HEALER" and roles["DAMAGER_REMAINING"] > 0) then
			return true

		end

		for k, v in pairs(roles) do
			if((k == "HUNTER" or k == "SHAMAN" or k == "MAGE" or k == "EVOKER") and v == 1) then
				return true

			end
		end
	end
end

local function HasRemainingSlotsForBattleResurrection(resultID)
	local _, _, playerClassID = UnitClass("player")
	if(playerClassID == 2 or playerClassID == 6 or playerClassID == 9 or playerClassID == 11) then
		return true

	end

	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)
	if roles then
		local playerRole = GetSpecializationRole(GetSpecialization())

		if(playerRole == "DAMAGER" and (roles["HEALER_REMAINING"] > 0 or roles["DAMAGER_REMAINING"] > 1)) then
			return true

		end

		if(playerRole == "HEALER" and roles["DAMAGER_REMAINING"] > 0 or roles["TANK_REMAINING"] > 0) then
			return true

		end

		if(playerRole == "TANK" and roles["DAMAGER_REMAINING"] > 0 or roles["HEALER_REMAINING"] > 0) then
			return true

		end

		for k, v in pairs(roles) do
			if((k == "PALADIN" or k == "DEATHKNIGHT" or k == "WARLOCK" or k == "DRUID") and v == 1) then
				return true

			end
		end
	end
end

local function HasRemainingSlotsForLocalPlayerRole(resultID) -- LFGList.lua local function HasRemainingSlotsForLocalPlayerRole(lfgresultID)
	local roles = C_LFGList.GetSearchResultMemberCounts(resultID)
	if roles then
		local playerRole = GetSpecializationRole(GetSpecialization())
		if playerRole then
			local remainingRoleKey = roleRemainingKeyLookup[playerRole]
			if remainingRoleKey then
				return (roles[remainingRoleKey] or 0) > 0
			end
		end
	end
end

local function isGroupEligible(resultID)
	local searchResultData = C_LFGList.GetSearchResultInfo(resultID)

	if(MIOG_SavedSettings.searchPanel_FilterOptions.table.groupOptions) then
		if(miog.searchPanel.filterFrame.filterForDifficulty:GetChecked() == true and miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID ~= MIOG_SavedSettings.searchPanel_FilterOptions.table.difficultyID) then
			return false

		end

		if(miog.searchPanel.filterFrame.partyFit:GetChecked() == true and not HasRemainingSlotsForLocalPlayerRole(resultID)) then
			return false

		end
		
		if(miog.searchPanel.filterFrame.ressFit:GetChecked() == true and not HasRemainingSlotsForBattleResurrection(resultID)) then
			return false

		end
		
		if(miog.searchPanel.filterFrame.lustFit:GetChecked() == true and not HasRemainingSlotsForBloodlust(resultID)) then
			return false

		end

		if(C_LFGList.GetActivityInfoTable(searchResultData.activityID).categoryID ~= LFGListFrame.SearchPanel.categoryID) then
			return false

		end

		local roleCount = {
			["TANK"] = 0,
			["HEALER"] = 0,
			["DAMAGER"] = 0,
			["NONE"] = 0
		}

		for i = 1, searchResultData.numMembers, 1 do
			local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i)
			local specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]

			if(specID) then
				roleCount[role or "NONE"] = roleCount[role] + 1

				if(not miog.searchPanel.filterFrame.classFilterPanel.ClassPanels[miog.CLASSFILE_TO_ID[class]].Button:GetChecked() or
				not miog.searchPanel.filterFrame.classFilterPanel.ClassPanels[miog.CLASSFILE_TO_ID[class]].specFilterPanel.SpecButtons[specID]:GetChecked()) then
					return false

				end
			end
		end

		local minTanks = miog.searchPanel.filterFrame["minTanks"]:GetValue()
		local maxTanks = miog.searchPanel.filterFrame["maxTanks"]:GetValue()
		local minHealers = miog.searchPanel.filterFrame["minHealers"]:GetValue()
		local maxHealers = miog.searchPanel.filterFrame["maxHealers"]:GetValue()
		local minDamager = miog.searchPanel.filterFrame["minDamager"]:GetValue()
		local maxDamager = miog.searchPanel.filterFrame["maxDamager"]:GetValue()

		if(miog.searchPanel.filterFrame["filterForTanks"]:GetChecked() and maxTanks > 0 and not (roleCount["TANK"] >= minTanks and roleCount["TANK"] <= maxTanks)
		or miog.searchPanel.filterFrame["filterForHealers"]:GetChecked() and maxHealers > 0 and not (roleCount["HEALER"] >= minHealers and roleCount["HEALER"] <= maxHealers)
		or miog.searchPanel.filterFrame["filterForDamager"]:GetChecked() and maxDamager > 0 and not (roleCount["DAMAGER"] >= minDamager and roleCount["DAMAGER"] <= maxDamager)) then
			return false

		end
	end
	
	if(MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeonOptions and MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeons[searchResultData.activityID] == false) then
		return false

	end

	return true
end

local function sortSearchResultList(result1, result2)
	for key, tableElement in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do
		if(type(tableElement) == "table" and tableElement.currentLayer == 1) then
			local firstState = miog.searchPanel.buttonPanel.sortByCategoryButtons[key]:GetActiveState()

			for innerKey, innerTableElement in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do

				if(type(innerTableElement) == "table" and innerTableElement.currentLayer == 2) then
					local secondState = miog.searchPanel.buttonPanel.sortByCategoryButtons[innerKey]:GetActiveState()

					if(result1.appStatus == "applied" and result2.appStatus ~= "applied") then
						return true

					elseif(result1.appStatus ~= "applied" and result2.appStatus == "applied") then
						return false

					else
						if(result1[key] == result2[key]) then
							return secondState == 1 and result1[innerKey] > result2[innerKey] or secondState == 2 and result1[innerKey] < result2[innerKey]

						elseif(result1[key] ~= result2[key]) then
							return firstState == 1 and result1[key] > result2[key] or firstState == 2 and result1[key] < result2[key]

						end
					end
				end

			end

			
			if(result1.appStatus == "applied" and result2.appStatus ~= "applied") then
				return true

			elseif(result1.appStatus ~= "applied" and result2.appStatus == "applied") then
				return false
			
				-- ORDERING????
			else
				if(result1[key] == result2[key]) then
					return firstState == 1 and result1.index > result2.index or firstState == 2 and result1.index < result2.index

				elseif(result1[key] ~= result2[key]) then
					return firstState == 1 and result1[key] > result2[key] or firstState == 2 and result1[key] < result2[key]

				end
			end

		end

	end

	if(result1.appStatus == "applied" and result2.appStatus ~= "applied") then
		return true

	elseif(result1.appStatus ~= "applied" and result2.appStatus == "applied") then
		return false

	else
		return result1.index < result2.index

	end

end

local function updateSingleSearchResult(resultID, appStatus)
	local searchResultData = C_LFGList.GetSearchResultInfo(resultID)

	if((appStatus == "applied" or isGroupEligible(resultID)) and searchResultData and searchResultData.leaderName and not searchResultData.isDelisted) then
		local activityInfo = C_LFGList.GetActivityInfoTable(searchResultData.activityID)

		if(not searchResultSystem.resultFrames[resultID]) then
			createSearchResultFrame(searchResultData, activityInfo)

		end

		local mapID = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].mapID or 0
		computeResultMembers(resultID, searchResultData.numMembers, mapID)
		searchResultSystem.resultFrames[resultID].basicInformationPanel.firstFrame.titleFrame:SetText(searchResultData.name)
		searchResultSystem.resultFrames[resultID]:Show()
		searchResultSystem.resultFrames[resultID].layoutIndex = searchResultSystem.resultFrames[resultID].layoutIndex or resultFrameIndex
		resultFrameIndex = resultFrameIndex + 1
		return true
		
	else
		return false
	
	end
end

miog.signupToGroup = function(resultID)
	local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

	if (appStatus ~= "none" or pendingStatus or searchResultInfo.isDelisted ) then
		return false

	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	LFGListSearchPanel_SelectResult(LFGListFrame.SearchPanel, resultID)

	if(searchResultSystem.resultFrames[resultID]) then
		searchResultSystem.resultFrames[resultID]:SetBackdropBorderColor(CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())

		if(searchResultSystem.selectedResult and searchResultSystem.resultFrames[searchResultSystem.selectedResult]) then
			searchResultSystem.resultFrames[searchResultSystem.selectedResult]:SetBackdropBorderColor(
				CreateColorFromHexString(searchResultSystem.applicationStatus[searchResultSystem.selectedResult] == "applied" and miog.CLRSCC.olive or miog.C.BACKGROUND_COLOR_3):GetRGBA()
			)

		end

		searchResultSystem.selectedResult = resultID
	end

	LFGListSearchPanel_SignUp(LFGListFrame.SearchPanel)
end

local function gatherSearchResultSortData(singleResultID)
	local unsortedMainApplicantsList = {}

	local _, resultTable = LFGListFrame.SearchPanel.totalResults, LFGListFrame.SearchPanel.results or C_LFGList.GetSearchResults()

	local counter = 1

	for _, resultID in ipairs(singleResultID and {[1] = singleResultID} or resultTable) do
		local searchResultData = C_LFGList.GetSearchResultInfo(resultID)

		if(searchResultData and searchResultData.leaderName) then
			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultData.activityID)

			if(activityInfo.categoryID == LFGListFrame.SearchPanel.categoryID) then
				local _, appStatus = C_LFGList.GetApplicationInfo(resultID)
				local profile, primarySortAttribute, secondarySortAttribute

				if(miog.F.IS_RAIDERIO_LOADED) then
					profile = RaiderIO.GetProfile(searchResultData.leaderName)

				end

				if(miog.F.LISTED_CATEGORY_ID ~= (3 or 4 or 7 or 8 or 9)) then
					primarySortAttribute = searchResultData.leaderOverallDungeonScore
					secondarySortAttribute = searchResultData.leaderDungeonScoreInfo.bestRunLevel

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
					primarySortAttribute = searchResultData.leaderPvpRatingInfo.rating
					secondarySortAttribute = searchResultData.leaderPvpRatingInfo.rating

				end

				unsortedMainApplicantsList[counter] = {
					appStatus = searchResultData.isDelisted and "declined_delisted" or appStatus,
					primary = primarySortAttribute,
					secondary = secondarySortAttribute,
					age = searchResultData.age,
					index = resultID
				}

				counter = counter + 1
			end
		end

	end

	return unsortedMainApplicantsList
end

--[[miog.reorderSearchResultList = function()
	local unsortedList = gatherSearchResultSortData()

	local allSystemMembers = {}

	for k, v in pairs(searchResultSystem.resultFrames) do
		v:Hide()
		v.layoutIndex = nil

		allSystemMembers[k] = true
	end

	if(unsortedList[1]) then
		table.sort(unsortedList, sortSearchResultList)

		for _, listEntry in ipairs(unsortedList) do
			allSystemMembers[listEntry.index] = nil
		end
	end

	for k in pairs(allSystemMembers) do
		if(searchResultSystem.resultFrames[k]) then
			searchResultSystem.resultFrames[k].framePool:ReleaseAll()
			searchResultSystem.resultFrames[k].fontStringPool:ReleaseAll()
			searchResultSystem.resultFrames[k].texturePool:ReleaseAll()

			miog.searchResultFramePool:Release(searchResultSystem.resultFrames[k])

			searchResultSystem.resultFrames[k] = nil

		end
	end

	miog.searchPanel.resultPanel.container:MarkDirty()
end]]

local startTime, endTime
local currentlyFullyUpdatingSearchResultList = false

miog.updateSearchResultList = function(forceReorder, resultID)
	miog.mainFrame.throttledString:Hide()
	currentlyFullyUpdatingSearchResultList = forceReorder
	
	if(miog.F.IS_IN_DEBUG_MODE) then
		startTime = GetTimePreciseSec()
	end

	local unsortedList

	if(forceReorder) then
		unsortedList = gatherSearchResultSortData(resultID)

	else
		unsortedList = {}

		local searchResultData = C_LFGList.GetSearchResultInfo(resultID)
		local _, appStatus = C_LFGList.GetApplicationInfo(resultID)
		appStatus = searchResultData.isDelisted and "declined_delisted" or appStatus
		
		unsortedList[1] = {index = resultID, appStatus = appStatus}
	end
	
	if(unsortedList[1]) then
		local allSystemMembers = {}

		if(forceReorder) then
			table.sort(unsortedList, sortSearchResultList)
			
			for k, v in pairs(searchResultSystem.resultFrames) do
				v:Hide()
				v.layoutIndex = nil

				allSystemMembers[k] = true
			end
		end

		for _, listEntry in ipairs(unsortedList) do
			if(updateSingleSearchResult(listEntry.index, listEntry.appStatus)) then
				allSystemMembers[listEntry.index] = nil
				
			end

			updateResultFrameStatus(listEntry.index, listEntry.appStatus)
		end

		if(forceReorder) then
			for k in pairs(allSystemMembers) do
				if(searchResultSystem.resultFrames[k]) then
					searchResultSystem.resultFrames[k].framePool:ReleaseAll()
					searchResultSystem.resultFrames[k].fontStringPool:ReleaseAll()
					searchResultSystem.resultFrames[k].texturePool:ReleaseAll()

					miog.searchResultFramePool:Release(searchResultSystem.resultFrames[k])

					searchResultSystem.resultFrames[k] = nil
					searchResultSystem.applicationStatus[k] = nil

				end
			end
		end

		miog.searchPanel.resultPanel.container:MarkDirty()

	end

	if(miog.F.IS_IN_DEBUG_MODE) then 
		endTime = GetTimePreciseSec()
		currentAverageExecuteTime[#currentAverageExecuteTime+1] = endTime - startTime

		if(currentAverageExecuteTime[#currentAverageExecuteTime] > 0.05) then
			print(currentAverageExecuteTime[#currentAverageExecuteTime])
		end
	end

	miog.searchPanel.footerBar.groupNumberFontString:SetText(LFGListFrame.SearchPanel.totalResults)
	currentlyFullyUpdatingSearchResultList = false
end

local function searchResultsReceived()
	if(LFGListFrame.SearchPanel.totalResults > 0) then
		if(miog.F.WAITING_FOR_RESULTS == true) then
			miog.searchPanel.resultPanel:SetVerticalScroll(0)

			miog.F.WAITING_FOR_RESULTS = false
			--print(GetTimePreciseSec(), "GOT ACTUAL SEARCH RESULTS", LFGListFrame.SearchPanel.totalResults)
			miog.updateSearchResultList(true)
		end	
	end
end

miog.OnEvent = function(_, event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		local isInitialLogin, isReloadingUi = ...


		if(isInitialLogin or isReloadingUi) then
			updateRosterInfoData()

		else
			hideAllApplicantFrames()
			checkCoroutineStatus()

		end

	elseif(event == "PLAYER_LOGIN") then
		miog.checkForSavedSettings()
		miog.createFrames()
		miog.loadSettings()

		C_MythicPlus.RequestCurrentAffixes()

		miog.C.AVAILABLE_ROLES["TANK"], miog.C.AVAILABLE_ROLES["HEALER"], miog.C.AVAILABLE_ROLES["DAMAGER"] = UnitGetAvailableRoles("player")

		LFGListFrame.ApplicationViewer:HookScript("OnShow", function(self) self:Hide() miog.applicationViewer:Show() end)
		--LFGListFrame.SearchPanel:HookScript("OnShow", function(self) self:Hide() miog.searchPanel:Show() end)
		LFGListFrame.SearchPanel:HookScript("OnShow", function(self) miog.searchPanel:Show() end)

		if(C_AddOns.IsAddOnLoaded("RaiderIO")) then
			miog.F.IS_RAIDERIO_LOADED = true

			miog.mainFrame.raiderIOAddonIsLoadedFrame:Hide()

		end
		
		miog.scriptReceiver:UnregisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
		miog.scriptReceiver:UnregisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
		hooksecurefunc("LFGListSearchPanel_UpdateResultList", function(self)
			searchResultsReceived()
		end)

		if(C_AddOns.IsAddOnLoaded("PremadeGroupsFilter")) then
			-- Hooking into the same functions PGF uses

			--miog.scriptReceiver:UnregisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
			--miog.scriptReceiver:UnregisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

			--hooksecurefunc("LFGListSearchEntry_Update", function(self) miog.updateSearchResultList(true, self.resultID) end)

			-- HOOK BEFORE EVENT
			-- THROTTLE OR WRONG METHOD

		end

		for k, v in pairs(miog.SPECIALIZATIONS) do
			if(k ~= 0 and k ~= 20) then
				local _, localizedName, _, _, _, fileName = GetSpecializationInfoByID(k)

				miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[localizedName .. "-" .. fileName] = k
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
				releaseApplicantFrames()

				miog.applicationViewer.infoPanel.timerFrame.FontString:SetText("00:00:00")

				miog.applicationViewer:Hide()

				if(miog.F.WEEKLY_AFFIX == nil) then
					miog.setAffixes()

				end
			end
		else
			if(... == true) then --NEW LISTING
				MIOG_QueueUpTime = GetTimePreciseSec()
				applicantViewer_ExpandedFrameList = {}

			elseif(... == false) then --RELOAD, LOADING SCREENS OR SETTINGS EDIT
				MIOG_QueueUpTime = (MIOG_QueueUpTime and MIOG_QueueUpTime > 0) and MIOG_QueueUpTime or GetTimePreciseSec()

			end

			queueTimer = C_Timer.NewTicker(1, function()
				miog.applicationViewer.infoPanel.timerFrame.FontString:SetText(miog.secondsToClock(GetTimePreciseSec() - MIOG_QueueUpTime))

			end)

			miog.applicationViewer:Show()

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

			if(miog.applicationViewer and miog.applicationViewer.infoPanel) then
				miog.setAffixes()

				local currentSeason = C_MythicPlus.GetCurrentSeason()

				miog.F.CURRENT_SEASON = miog.MPLUS_SEASONS[currentSeason]
				miog.F.PREVIOUS_SEASON = miog.MPLUS_SEASONS[currentSeason - 1]

			end

        end

	elseif(event == "GROUP_JOINED" or event == "GROUP_LEFT") then
		miog.checkIfCanInvite()

		updateRosterInfoData()

	elseif(event == "PARTY_LEADER_CHANGED") then
		local canInvite = miog.checkIfCanInvite()

		for _,v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame.memberFrames[1].basicInformationPanel.inviteButton:SetShown(canInvite)
				v.frame.memberFrames[1].basicInformationPanel.declineButton:SetShown(canInvite)

			end
		end

	elseif(event == "GROUP_ROSTER_UPDATE") then
		local canInvite = miog.checkIfCanInvite()

		for _,v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame.memberFrames[1].basicInformationPanel.inviteButton:SetShown(canInvite)
				v.frame.memberFrames[1].basicInformationPanel.declineButton:SetShown(canInvite)

			end
		end

		updateRosterInfoData()

	elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local guid = UnitGUID(...)

		if(guid) then
			if(groupSystem.groupMember[guid] and not inspectQueue[guid]) then
				groupSystem.inspectedGUIDs[guid] = nil
				inspectQueue[guid] = ...
				checkCoroutineStatus()

			end
		end

	elseif(event == "INSPECT_READY") then
		if(groupSystem.groupMember[...] or inspectQueue[...]) then
			inspectQueue[...] = nil

			--local member = groupSystem.groupMember[...]

			--local specID = GetInspectSpecialization(member.unitID)
			--groupSystem.inspectedGUIDs[...] = specID ~= 0 and specID or nil

			--inspectedGUID.classID = select(2, UnitClassBase(member.unitID))

			--local tempRole = GetSpecializationRoleByID(inspectedGUID.specID)
			--inspectedGUID.role = tempRole == "NONE" and "DAMAGER" or tempRole


			--if(inspectedGUID.specID ~= nil and miog.CLASSES[inspectedGUID.classID] and (inspectedGUID.role == "TANK" or inspectedGUID.role == "HEALER" or inspectedGUID.role == "DAMAGER")) then
				--updateSpecFrames()
			updateRosterInfoData()

			--else
				--RE-NOTIFY FOR GUID, DATA MISSING FROM INSPECT
			--	inspectedGUID = nil

			--end

			ClearInspectPlayer()

			checkCoroutineStatus(true)

		else
			local unitID = UnitTokenFromGUID(...)
			miog.F.LFG_STATE = miog.checkLFGState()

			---@diagnostic disable-next-line: param-type-mismatch
			if(miog.F.LFG_STATE == "raid" and UnitInRaid(unitID) or miog.F.LFG_STATE == "party" and UnitInParty(unitID)) then
				createGroupMemberEntry(..., unitID)

			end

		end
	elseif(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
		searchResultsReceived()

	elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
		print("Search Result ID: " .. ...)

		--print(..., searchResultData.name, C_LFGList.HasSearchResultInfo(...))

		if(not currentlyFullyUpdatingSearchResultList) then
			miog.updateSearchResultList(false, ...)
		end

	elseif(event == "LFG_LIST_SEARCH_FAILED") then
		--print("Search failed because of " .. ...)

		if(... == "throttled") then
			miog.mainFrame.throttledString:Show()

		end

	elseif(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
		local resultID, new, old, name = ...
		--print(...)

		searchResultSystem.applicationStatus[resultID] = new

		if(searchResultSystem.resultFrames[resultID]) then
			--if(isGroupEligible(resultID)) then
			updateResultFrameStatus(resultID, new)

			--end
		end

		--miog.updateSearchResultList(false, resultID)

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS") then
		--print(event, ...)
		--Happens when in a group and group is at max members after inviting a person
		--Not decided if it's needed

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TIMEOUT") then
		--print(event, ...)

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

			miog.applicationViewer:Show()
		end

	elseif(command == "debugon") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")


	elseif(command == "debugoff") then
		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false
		releaseApplicantFrames()
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
				releaseApplicantFrames()
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
		releaseApplicantFrames()
		resetArrays()
	else
		--miog.applicationViewer:Show()

	end
end
SlashCmdList["MIOG"] = handler

hooksecurefunc("LFGListFrame_SetActivePanel", function(selfFrame, panel)
	if(panel == LFGListFrame.ApplicationViewer) then
		miog.searchPanel:Hide()
		miog.mainFrame:Show()
		miog.applicationViewer:Show()

	elseif(panel == LFGListFrame.SearchPanel) then
		miog.applicationViewer:Hide()
		miog.mainFrame:Show()
		miog.searchPanel:Show()

	else
		miog.mainFrame:Hide()
		miog.applicationViewer:Hide()
		miog.searchPanel:Hide()

	end
end)

hooksecurefunc("NotifyInspect", function() lastNotifyTime = GetTimePreciseSec() end)

-- Courtesy of Premade Group Finder

--[[function LFGListSearchPanel_SelectResult(self, resultID)
	self.selectedResult = resultID;
	LFGListSearchPanel_UpdateResults(self)

	if (IsInGroup() == false or UnitIsGroupLeader("player")) then
		C_LFGList.ApplyToGroup(LFGListFrame.SearchPanel.selectedResult, miog.C.AVAILABLE_ROLES.TANK, miog.C.AVAILABLE_ROLES.HEALER, miog.C.AVAILABLE_ROLES.DAMAGER)

	end
end]]

--[[LFGListApplicationDialog:HookScript("OnShow", function(self)
	if(IsInGroup() and not UnitIsGroupLeader("player")) then
		if(miog.C.AVAILABLE_ROLES.TANK) then
			LFDRoleCheckPopupRoleButtonTank.checkButton:SetChecked(true)

		else
			LFDRoleCheckPopupRoleButtonTank.checkButton:SetChecked(false)

		end

		if(miog.C.AVAILABLE_ROLES.HEALER) then
			LFDRoleCheckPopupRoleButtonHealer.checkButton:SetChecked(true)

		else
			LFDRoleCheckPopupRoleButtonHealer.checkButton:SetChecked(false)

		end

		if(miog.C.AVAILABLE_ROLES.DAMAGER) then
			LFDRoleCheckPopupRoleButtonDPS.checkButton:SetChecked(true)

		else
			LFDRoleCheckPopupRoleButtonDPS.checkButton:SetChecked(false)

		end

		LFDRoleCheckPopupAcceptButton:Enable()
		LFDRoleCheckPopupAcceptButton:Click()

	else
		LFGListApplicationDialog:Hide()

	end
end)]]

hooksecurefunc("LFGListSearchPanel_DoSearch", function()
	miog.F.WAITING_FOR_RESULTS = true
	releaseAllSearchResultFrames()
end)