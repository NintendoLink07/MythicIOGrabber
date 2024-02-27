local addonName, miog = ...

local applicantViewer_ExpandedFrameList = {}
local searchPanel_ExpandedFrameList = {}

local groupSystem = {}
groupSystem.groupMember = {}
groupSystem.inspectedGUIDs = {}

local applicantSystem = {}
applicantSystem.applicantMember = {}

local searchResultSystem = {}
searchResultSystem.persistentFrames = {}
searchResultSystem.searchResultData = {}
searchResultSystem.declinedGroups = {}

local currentAverageExecuteTime = {}
local debugTimer = nil

local fmod = math.fmod
local rep = string.rep
local wticc = WrapTextInColorCode
local tostring = tostring
local CreateColorFromHexString = CreateColorFromHexString

local applicationFrameIndex = 0

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

	miog.applicationViewer.applicantNumberFontString:SetText(0)
	miog.applicationViewer.applicantPanel.container:MarkDirty()

end

local function hideAllApplicantFrames()
	for _, v in pairs(applicantSystem.applicantMember) do
		if(v.frame) then
			v.frame:Hide()
			v.frame.layoutIndex = nil

		end
	end

	miog.applicationViewer.applicantNumberFontString:SetText(0)
	miog.applicationViewer.applicantPanel.container:MarkDirty()

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

local function getRaidSortData(playerName)
	local raidData = {}

	local profile

	if(miog.F.IS_RAIDERIO_LOADED) then
		profile = RaiderIO.GetProfile(playerName)

	end

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

	return raidData
end

miog.getRaidSortData = getRaidSortData

local function createDetailedInformationPanel(poolFrame, listFrame)
	if (listFrame == nil) then
		listFrame = poolFrame

	end
	
	local detailedInformationPanel = miog.createFleetingFrame(poolFrame.framePool, "MIOG_DetailedInformationPanelTemplate", listFrame)
	detailedInformationPanel:SetPoint("TOPLEFT", listFrame.BasicInformationPanel, "BOTTOMLEFT")
	detailedInformationPanel:SetPoint("TOPRIGHT", listFrame.BasicInformationPanel, "BOTTOMRIGHT")
	detailedInformationPanel:SetShown(listFrame.BasicInformationPanel.ExpandFrame:GetActiveState() > 0 and true or false)
	listFrame.DetailedInformationPanel = detailedInformationPanel

	local tabPanel = detailedInformationPanel.TabPanel
	tabPanel:SetPoint("TOPLEFT", detailedInformationPanel, "TOPLEFT")
	tabPanel:SetPoint("TOPRIGHT", detailedInformationPanel, "TOPRIGHT")
	tabPanel.rows = {}

	local mythicPlusTabButton = tabPanel.MythicPlusTabButton
	mythicPlusTabButton:RegisterForClicks("LeftButtonDown")
	mythicPlusTabButton:SetScript("OnClick", function()
		detailedInformationPanel.MythicPlusPanel:Show()
		detailedInformationPanel.RaidPanel:Hide()

		detailedInformationPanel:SetHeight(detailedInformationPanel.MythicPlusPanel:GetHeight() + 20)
		detailedInformationPanel:MarkDirty()
		poolFrame:MarkDirty()
	end)

	local raidTabButton = tabPanel.RaidTabButton
	raidTabButton:RegisterForClicks("LeftButtonDown")
	raidTabButton:SetScript("OnClick", function()
		detailedInformationPanel.MythicPlusPanel:Hide()
		detailedInformationPanel.RaidPanel:Show()

		detailedInformationPanel:SetHeight(detailedInformationPanel.RaidPanel:GetHeight() + 20)
		detailedInformationPanel:MarkDirty()
		poolFrame:MarkDirty()
	end)

	local mythicPlusPanel = detailedInformationPanel.MythicPlusPanel
	mythicPlusPanel:SetShown(miog.F.LISTED_CATEGORY_ID ~= 3 and true)
	mythicPlusPanel.rows = {}
	mythicPlusPanel.dungeonFrames = {}

	local raidPanel = detailedInformationPanel.RaidPanel
	--raidPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
	raidPanel:SetShown(miog.F.LISTED_CATEGORY_ID == 3 and true)
	raidPanel.rows = {}

	-- 9 * 20

	local generalInfoPanel = detailedInformationPanel.GeneralInfoPanel
	generalInfoPanel.rows = {}

	local hoverColor = {CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA()}
	local cardColor = {CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA()}

	for rowIndex = 1, miog.F.MOST_BOSSES, 1 do
		local remainder = fmod(rowIndex, 2)

		local textRowFrame = miog.createFleetingFrame(poolFrame.framePool, "MIOG_DetailedInformationPanelTextRowTemplate", detailedInformationPanel)
		textRowFrame:SetPoint("TOPLEFT", tabPanel.rows[rowIndex-1] or tabPanel, "BOTTOMLEFT")
		textRowFrame:SetPoint("TOPRIGHT", tabPanel.rows[rowIndex-1] or tabPanel, "BOTTOMRIGHT")
		textRowFrame:SetHeight(miog.C.APPLICANT_MEMBER_HEIGHT)
		tabPanel.rows[rowIndex] = textRowFrame

		if(remainder == 1) then
			textRowFrame.Background:SetColorTexture(unpack(hoverColor))

		else
			textRowFrame.Background:SetColorTexture(unpack(cardColor))

		end

		local textRowGeneralInfo = textRowFrame.GeneralInfo
		generalInfoPanel.rows[rowIndex] = textRowGeneralInfo

		local textRowMythicPlus = textRowFrame.MythicPlus
		textRowMythicPlus:SetParent(mythicPlusPanel)
		mythicPlusPanel.rows[rowIndex] = textRowMythicPlus

		local textRowRaid = textRowFrame.Raid
		textRowRaid:SetParent(raidPanel)
		raidPanel.rows[rowIndex] = textRowRaid
		
		if(rowIndex ~= 1) then
			textRowMythicPlus.FontString:SetJustifyH("CENTER")
			textRowMythicPlus.FontString:SetPoint("CENTER", textRowGeneralInfo, "CENTER")

			textRowRaid.FontString:SetJustifyH("CENTER")
			textRowRaid.FontString:SetPoint("CENTER", textRowGeneralInfo, "CENTER")
			
		else
			textRowGeneralInfo.FontString:SetJustifyV("TOP")
			textRowGeneralInfo.FontString:SetWordWrap(true)
			textRowGeneralInfo.FontString:SetNonSpaceWrap(true)
			textRowGeneralInfo.FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)

			textRowGeneralInfo.FontString:SetScript("OnEnter", function(self)
				if(self:GetText() ~= nil) then
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:SetText(self:GetText(), nil, nil, nil, nil, true)
					GameTooltip:Show()
				end
			end)

			textRowGeneralInfo.FontString:SetScript("OnLeave", function()
				GameTooltip:Hide()
		
			end)
		end

		if(rowIndex < 9) then
			local dungeonRowFrame = miog.createFleetingFrame(poolFrame.framePool, "MIOG_DungeonRowTemplate", mythicPlusPanel)
			dungeonRowFrame:SetPoint("TOPLEFT", mythicPlusPanel.rows[rowIndex], "TOPLEFT")
			dungeonRowFrame:SetPoint("BOTTOMRIGHT", mythicPlusPanel.rows[rowIndex], "BOTTOMRIGHT")
			dungeonRowFrame.Icon:SetMouseClickEnabled(true)

			mythicPlusPanel.dungeonFrames[rowIndex] = dungeonRowFrame

		end
	end
	
	generalInfoPanel.rows[1].FontString:SetPoint("TOPLEFT", generalInfoPanel.rows[1], "TOPLEFT", 0, -5)
	generalInfoPanel.rows[1].FontString:SetPoint("BOTTOMRIGHT", generalInfoPanel.rows[4], "BOTTOMRIGHT", 0, 0)

	local currentTierFrame = miog.createFleetingFrame(poolFrame.framePool, "MIOG_RaidPanelTemplate", raidPanel)
	currentTierFrame:SetPoint("TOPLEFT", raidPanel.rows[1], "TOPLEFT")
	currentTierFrame:SetPoint("BOTTOMRIGHT", raidPanel.rows[4], "BOTTOMRIGHT")
	raidPanel.currentTier = currentTierFrame

	local lastTierFrame = miog.createFleetingFrame(poolFrame.framePool, "MIOG_RaidPanelTemplate", raidPanel)
	lastTierFrame:SetPoint("TOPLEFT", raidPanel.rows[5], "TOPLEFT")
	lastTierFrame:SetPoint("BOTTOMRIGHT", raidPanel.rows[8], "BOTTOMRIGHT")
	raidPanel.lastTier = lastTierFrame
	--miog.createFrameBorder(currentTierFrame.BossFrames.UpperRow, 2, 0, 1, 0, 1)
	--miog.createFrameBorder(currentTierFrame.BossFrames, 2, 1, 0, 0, 1)

	detailedInformationPanel:MarkDirty()
end

local function gatherRaiderIODisplayData(playerName, realm, poolFrame, memberFrame)
	if (memberFrame == nil) then
		memberFrame = poolFrame

	end

	local profile, mythicKeystoneProfile, raidProfile
	local BasicInformationPanel = memberFrame.BasicInformationPanel
	local detailedInformationPanel = memberFrame.DetailedInformationPanel
	local primaryIndicator = BasicInformationPanel.Primary
	local secondaryIndicator = BasicInformationPanel.Secondary
	local mythicPlusPanel = detailedInformationPanel.MythicPlusPanel
	local raidPanel = detailedInformationPanel.RaidPanel
	local generalInfoPanel = detailedInformationPanel.GeneralInfoPanel

	if(miog.F.IS_RAIDERIO_LOADED) then
		profile = RaiderIO.GetProfile(playerName, realm, miog.F.CURRENT_REGION)

		if(profile ~= nil) then
			mythicKeystoneProfile = profile.mythicKeystoneProfile
			raidProfile = profile.raidProfile

		end
	end

	if(profile) then
		if(mythicKeystoneProfile and mythicKeystoneProfile.currentScore > 0 and mythicKeystoneProfile.sortedDungeons) then
			table.sort(mythicKeystoneProfile.sortedDungeons, function(k1, k2)
				return k1.dungeon.shortName < k2.dungeon.shortName

			end)

			local primaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeons or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeons
			local primaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeonUpgrades or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeonUpgrades
			local secondaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeons or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeons
			local secondaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeonUpgrades or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeonUpgrades

			if(primaryDungeonLevel and primaryDungeonChests and secondaryDungeonLevel and secondaryDungeonChests) then
				for i, dungeonEntry in ipairs(mythicKeystoneProfile.sortedDungeons) do

					local dungeonRowFrame = mythicPlusPanel.dungeonFrames[i]

					local rowIndex = dungeonEntry.dungeon.index
					local texture = miog.MAP_INFO[dungeonEntry.dungeon.instance_map_id].icon

					dungeonRowFrame.Icon:SetTexture(texture)
					dungeonRowFrame.Icon:SetScript("OnMouseDown", function()
						local instanceID = C_EncounterJournal.GetInstanceForGameMap(dungeonEntry.dungeon.instance_map_id)

						--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
						EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

					end)

					dungeonRowFrame.Name:SetText(dungeonEntry.dungeon.shortName .. ":")

					dungeonRowFrame.Primary:SetText(wticc(primaryDungeonLevel[rowIndex] .. rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or primaryDungeonChests[rowIndex]),
					primaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or primaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))

					dungeonRowFrame.Secondary:SetText(wticc(secondaryDungeonLevel[rowIndex] .. rep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or secondaryDungeonChests[rowIndex]),
					secondaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or secondaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))
				end
			end

			local previousScoreString = ""

			local currentSeason = miog.MPLUS_SEASONS[miog.F.CURRENT_SEASON] or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason()]
			local previousSeason = miog.MPLUS_SEASONS[miog.F.PREVIOUS_SEASON] or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]

			if(mythicKeystoneProfile.previousScore and mythicKeystoneProfile.previousScore > 0) then
				previousScoreString = previousSeason .. ": " .. wticc(mythicKeystoneProfile.previousScore, miog.createCustomColorForScore(mythicKeystoneProfile.previousScore):GenerateHexColor())

			end

			mythicPlusPanel.rows[5].FontString:SetText(previousScoreString)

			local mainScoreString = ""

			if(mythicKeystoneProfile.mainCurrentScore) then
				if((mythicKeystoneProfile.mainCurrentScore > 0) == false and (mythicKeystoneProfile.mainPreviousScore > 0) == false) then
					mainScoreString = wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex)

				else
					if(mythicKeystoneProfile.mainCurrentScore > 0 and mythicKeystoneProfile.mainPreviousScore > 0) then
						mainScoreString = "Main " .. currentSeason .. ": " .. wticc(mythicKeystoneProfile.mainCurrentScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor()) ..
						" " .. previousSeason .. ": " .. wticc(mythicKeystoneProfile.mainPreviousScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainPreviousScore):GenerateHexColor())

					elseif(mythicKeystoneProfile.mainCurrentScore > 0) then
						mainScoreString = "Main " .. currentSeason .. ": " .. wticc(mythicKeystoneProfile.mainCurrentScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor())

					elseif(mythicKeystoneProfile.mainPreviousScore > 0) then
						mainScoreString = "Main " .. previousSeason .. ": " .. wticc(mythicKeystoneProfile.mainPreviousScore, miog.createCustomColorForScore(mythicKeystoneProfile.mainPreviousScore):GenerateHexColor())

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

		end

		if(raidProfile) then

			local lastOrdinal = nil

			local higherDifficultyNumber = nil
			local mainProgressText = ""

			local raidIndex = 0
			local currentTierFrame

			for _, sortedProgress in ipairs(raidProfile.sortedProgress) do
				if(sortedProgress.isMainProgress ~= true) then
					local progressCount = sortedProgress.progress.progressCount
					local bossCount = sortedProgress.progress.raid.bossCount
					local panelProgressString = wticc(progressCount .. "/" .. bossCount .. miog.DIFFICULTY[sortedProgress.progress.difficulty].shortName, miog.DIFFICULTY[sortedProgress.progress.difficulty].color)
					local basicProgressString = wticc(progressCount .. "/" .. bossCount, sortedProgress.progress.raid.ordinal == 1 and miog.DIFFICULTY[sortedProgress.progress.difficulty].color or miog.DIFFICULTY[sortedProgress.progress.difficulty].desaturated)

					if(sortedProgress.progress.raid.ordinal ~= lastOrdinal) then
						raidIndex = raidIndex + 1

						if(miog.F.LISTED_CATEGORY_ID == 3) then
							if(primaryIndicator:GetText() ~= nil and secondaryIndicator:GetText() == nil) then
								secondaryIndicator:SetText(basicProgressString)

							end

							if(primaryIndicator:GetText() == nil) then
								primaryIndicator:SetText(basicProgressString)

							end
						end

						local instanceID = C_EncounterJournal.GetInstanceForGameMap(sortedProgress.progress.raid.mapId)
						currentTierFrame = raidPanel[raidIndex == 1 and "currentTier" or "lastTier"]

						currentTierFrame.Icon:SetTexture(miog.MAP_INFO[sortedProgress.progress.raid.mapId][bossCount + 1].icon)
						currentTierFrame.Icon:SetScript("OnMouseDown", function()
							--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
							EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, nil, nil, nil, nil)

						end)

						currentTierFrame.Name:SetText(sortedProgress.progress.raid.shortName .. ":")

						higherDifficultyNumber = sortedProgress.progress.difficulty

						currentTierFrame.Progress:SetText(panelProgressString)

						local currentDiffColor = {miog.ITEM_QUALITY_COLORS[higherDifficultyNumber+1].color:GetRGBA()}

						for i = 1, 10, 1 do
							local currentBoss = currentTierFrame.BossFrames[i < 6 and "UpperRow" or "LowerRow"][tostring(i)]
							if(miog.MAP_INFO[sortedProgress.progress.raid.mapId][i] and not miog.MAP_INFO[sortedProgress.progress.raid.mapId][i].shortName) then
								currentBoss.Icon:SetTexture(miog.MAP_INFO[sortedProgress.progress.raid.mapId][i].icon)
								currentBoss.Icon:SetScript("OnMouseDown", function()

									--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
									EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, select(3, EJ_GetEncounterInfoByIndex(i, instanceID)), nil, nil, nil)
								end)

								currentBoss.Index:SetText(i)

								--raidPanel.raid[raidIndex].bossFrames[bossIndex] = bossFrame

								if(sortedProgress.progress.killsPerBoss) then
									local desaturated
									local numberOfBossKills = sortedProgress.progress.killsPerBoss[i]

									if(numberOfBossKills > 0) then
										desaturated = false

										currentBoss.Border:SetColorTexture(unpack(currentDiffColor))

									elseif(numberOfBossKills == 0) then
										desaturated = true
										currentBoss.Border:SetColorTexture(0, 0, 0, 0)

									end

									currentBoss.Icon:SetDesaturated(desaturated)

								end

								currentBoss:Show()

							else
								currentBoss:Hide()
							end
						end
					else

						if(sortedProgress.progress.difficulty ~= higherDifficultyNumber) then

							if(miog.F.LISTED_CATEGORY_ID == 3) then
								if(secondaryIndicator:GetText() == nil) then
									secondaryIndicator:SetText(basicProgressString) -- ACTUAL PROGRESS
								end
							end

							currentTierFrame.Progress:SetText(currentTierFrame.Progress:GetText() .. " " .. panelProgressString)

							for i = 1, 10, 1 do
								local currentBoss = currentTierFrame.BossFrames[i < 6 and "UpperRow" or "LowerRow"][tostring(i)]
								if(miog.MAP_INFO[sortedProgress.progress.raid.mapId][i] and not miog.MAP_INFO[sortedProgress.progress.raid.mapId][i].shortName) then
									local desaturated = currentBoss.Icon:IsDesaturated()

									if(sortedProgress.progress.killsPerBoss and sortedProgress.progress.killsPerBoss[i]) then
										if(sortedProgress.progress.killsPerBoss[i] > 0 and desaturated == true) then
											currentBoss.Border:SetColorTexture(miog.ITEM_QUALITY_COLORS[sortedProgress.progress.difficulty + 1].color:GetRGBA())
											currentBoss.Icon:SetDesaturated(false)

										elseif(sortedProgress.progress.killsPerBoss[i] == 0 and desaturated == true) then
											currentBoss.Border:SetColorTexture(0, 0, 0, 0)
										end

									else
										if(progressCount == bossCount) then
											if(desaturated == true) then
												currentBoss.Border:SetColorTexture(miog.ITEM_QUALITY_COLORS[sortedProgress.progress.difficulty + 1].color:GetRGBA())
												currentBoss.Icon:SetDesaturated(false)

											end

										end
									end
								end
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

		else
			raidPanel.rows[1].FontString:SetText(wticc("NO RAIDING DATA", miog.CLRSCC["red"]))

			if(miog.F.LISTED_CATEGORY_ID == 3) then
				primaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))
				secondaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))

			end

		end

	else -- If RaiderIO is not installed
		mythicPlusPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))

		raidPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))
	end


	if(primaryIndicator:GetText() == nil) then
		primaryIndicator:SetText(wticc(miog.F.LISTED_CATEGORY_ID == 3 and "0/0" or 0, miog.DIFFICULTY[-1].color))

	end

	if(secondaryIndicator:GetText() == nil) then
		secondaryIndicator:SetText(wticc(miog.F.LISTED_CATEGORY_ID == 3 and "0/0" or 0, miog.DIFFICULTY[-1].color))

	end

	generalInfoPanel.rows[9].FontString:SetText(string.upper(miog.F.CURRENT_REGION) .. "-" .. (realm or GetRealmName() or ""))
end

miog.gatherRaiderIODisplayData = gatherRaiderIODisplayData

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
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_ApplicantMemberFrameTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DetailedInformationPanelTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DetailedInformationPanelTextRowTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DungeonRowTemplate", miog.resetFrame):SetResetDisallowedIfNew()
		applicantFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_RaidPanelTemplate", miog.resetFrame):SetResetDisallowedIfNew()

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

			local applicantMemberFrame = miog.createFleetingFrame(applicantFrame.framePool, "MIOG_ApplicantMemberFrameTemplate", applicantFrame)
			applicantMemberFrame.fixedWidth = applicantFrame.fixedWidth - 2
			applicantMemberFrame.minimumHeight = 20
			applicantMemberFrame:SetPoint("TOP", applicantFrame.memberFrames[applicantIndex-1] or applicantFrame, applicantFrame.memberFrames[applicantIndex-1] and "BOTTOM" or "TOP", 0, applicantIndex > 1 and -miog.C.APPLICANT_PADDING or -1)
			applicantFrame.memberFrames[applicantIndex] = applicantMemberFrame

			if(MIOG_SavedSettings.favouredApplicants.table[name]) then
				miog.createFrameBorder(applicantMemberFrame, 2, CreateColorFromHexString("FFe1ad21"):GetRGBA())

			end

			local applicantMemberStatusFrame = applicantMemberFrame.StatusFrame
			applicantMemberStatusFrame:SetFrameStrata("FULLSCREEN")

			local expandFrameButton = applicantMemberFrame.BasicInformationPanel.ExpandFrame
			expandFrameButton:OnLoad()
			expandFrameButton:SetMaxStates(2)
			expandFrameButton:SetTexturesForBaseState("UI-HUD-ActionBar-PageDownArrow-Up", "UI-HUD-ActionBar-PageDownArrow-Down", "UI-HUD-ActionBar-PageDownArrow-Mouseover", "UI-HUD-ActionBar-PageDownArrow-Disabled")
			expandFrameButton:SetTexturesForState1("UI-HUD-ActionBar-PageUpArrow-Up", "UI-HUD-ActionBar-PageUpArrow-Down", "UI-HUD-ActionBar-PageUpArrow-Mouseover", "UI-HUD-ActionBar-PageUpArrow-Disabled")
			expandFrameButton:SetState(false)

			if(applicantViewer_ExpandedFrameList[applicantID][applicantIndex]) then
				expandFrameButton:AdvanceState()

			end

			expandFrameButton:RegisterForClicks("LeftButtonDown")
			expandFrameButton:SetScript("OnClick", function()
				if(applicantMemberFrame.DetailedInformationPanel) then
					expandFrameButton:AdvanceState()
					applicantViewer_ExpandedFrameList[applicantID][applicantIndex] = not applicantMemberFrame.DetailedInformationPanel:IsVisible()
					applicantMemberFrame.DetailedInformationPanel:SetShown(not applicantMemberFrame.DetailedInformationPanel:IsVisible())

					applicantFrame:MarkDirty()

				end

			end)

			if(applicantData.comment ~= "" and applicantData.comment ~= nil) then
				applicantMemberFrame.BasicInformationPanel.Comment:Show()

			end

			local playerIsIgnored = C_FriendList.IsIgnored(name)

			local rioLink = "https://raider.io/characters/" .. miog.F.CURRENT_REGION .. "/" .. miog.REALM_LOCAL_NAMES[nameTable[2]] .. "/" .. nameTable[1]

			local nameString = applicantMemberFrame.BasicInformationPanel.Name
			nameString:SetText(playerIsIgnored and wticc(nameTable[1], "FFFF0000") or wticc(nameTable[1], select(4, GetClassColor(class))))
			nameString:SetScript("OnMouseDown", function(_, button)
				if(button == "RightButton") then

					applicantMemberFrame.LinkBox:SetAutoFocus(true)
					applicantMemberFrame.LinkBox:SetText(rioLink)
					applicantMemberFrame.LinkBox:HighlightText()

					applicantMemberFrame.LinkBox:Show()
					applicantMemberFrame.LinkBox:SetAutoFocus(false)

				end
			end)
			nameString:SetScript("OnEnter", function()
				GameTooltip:SetOwner(nameString, "ANCHOR_CURSOR")

				if(playerIsIgnored) then
					GameTooltip:SetText("Player is on your ignore list")

				else
					if(nameString:IsTruncated()) then
						GameTooltip:SetText(nameString:GetText())
					end

					if(name == "Rhany-Ravencrest" or name == "Gerhanya-Ravencrest") then
						GameTooltip:AddLine("You've found the creator of this addon.\nHow lucky!")

					end
				end

				GameTooltip:Show()

			end)

			--[[applicantMemberFrame.LinkBox:SetScript("OnKeyDown", function(_, key)
				if(key == "ESCAPE" or key == "ENTER") then
					applicantMemberFrame.LinkBox:Hide()
					applicantMemberFrame.LinkBox:ClearFocus()

				end
			end)]]

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
				applicantMemberFrame.BasicInformationPanel.Group:SetScript("OnEnter", function(self)
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

			createDetailedInformationPanel(applicantFrame, applicantMemberFrame)

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

			local generalInfoPanel = applicantMemberFrame.DetailedInformationPanel.GeneralInfoPanel

			generalInfoPanel.rows[1].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. ((applicantData.comment and applicantData.comment) or ""))
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

			elseif(miog.F.LISTED_CATEGORY_ID == 4 or miog.F.LISTED_CATEGORY_ID == 7 or miog.F.LISTED_CATEGORY_ID == 8 or miog.F.LISTED_CATEGORY_ID == 9) then
				primaryIndicator:SetText(wticc(tostring(pvpData.rating), miog.createCustomColorForScore(pvpData.rating):GenerateHexColor()))

				local tierResult = miog.simpleSplit(PVPUtil.GetTierName(pvpData.tier), " ")
				secondaryIndicator:SetText(strsub(tierResult[1], 0, tierResult[2] and 2 or 4) .. ((tierResult[2] and "" .. tierResult[2]) or ""))

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

							if(miog.F.LISTED_CATEGORY_ID ~= 3 and miog.F.LISTED_CATEGORY_ID ~= 4 or miog.F.LISTED_CATEGORY_ID ~= 7 or miog.F.LISTED_CATEGORY_ID ~= 8 or miog.F.LISTED_CATEGORY_ID ~= 9) then
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
	if(applicantSystem.applicantMember[applicantID]) then
		if(applicantSystem.applicantMember[applicantID].frame) then
			applicantSystem.applicantMember[applicantID].frame:Show()

		else
			applicantSystem.applicantMember[applicantID].status = "inProgress"
			createApplicantFrame(applicantID)

		end

		applicantSystem.applicantMember[applicantID].frame.layoutIndex = applicationFrameIndex

		applicationFrameIndex = applicationFrameIndex + 1

	end
end

local function checkApplicantList(forceReorder, applicantID)
	local unsortedList = gatherSortData()

	local allSystemMembers = {}

	if(forceReorder) then
		for k, v in pairs(applicantSystem.applicantMember) do
			--[[if(v.frame) then
				v.frame:Hide()
				v.frame.layoutIndex = nil

			end]]

			allSystemMembers[k] = true

		end

		--miog.applicationViewer.applicantPanel.container:MarkDirty()

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

	miog.applicationViewer.applicantNumberFontString:SetText(applicationFrameIndex .. "(" .. #unsortedList .. ")")
	miog.applicationViewer.applicantPanel.container:MarkDirty()
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

	groupSystem.roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
	}

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

	if(#indexedGroup < 5) then
		if(groupSystem.roleCount["TANK"] < 1) then
			indexedGroup[#indexedGroup + 1] = {guid = "emptyTank", unitID = "emptyTank", name = "afkTank", classID = 20, role = "TANK", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			groupSystem.roleCount["TANK"] = groupSystem.roleCount["TANK"] + 1
		end

		if(groupSystem.roleCount["HEALER"] < 1 and #indexedGroup < 5) then
			indexedGroup[#indexedGroup + 1] = {guid = "emptyHealer", unitID = "emptyHealer", name = "afkHealer", classID = 21, role = "HEALER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			groupSystem.roleCount["HEALER"] = groupSystem.roleCount["HEALER"] + 1

		end

		for i = 1, 3 - groupSystem.roleCount["DAMAGER"], 1 do
			if(groupSystem.roleCount["DAMAGER"] < 3 and #indexedGroup < 5) then
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

	if(numOfMembers < 6) then
		miog.applicationViewer.titleBar.groupMemberListing.FontString:SetText("")
	
		local lastIcon = nil

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

			if(index == 5) then
				break
			end

		end

	else
		miog.applicationViewer.titleBar.groupMemberListing.FontString:SetText(groupSystem.roleCount["TANK"] .. "/" .. groupSystem.roleCount["HEALER"] .. "/" .. groupSystem.roleCount["DAMAGER"])
		
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

			updateSpecFrames()

		else
			--Unit does not exist

		end

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

	miog.applicationViewer.infoPanelBackdropFrame.backdropInfo.bgFile = miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID] and miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].file 
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
		if(roles["TANK_REMAINING"] == 0 and roles["HEALER_REMAINING"] == 0 and roles["DAMAGER_REMAINING"] == 0) then
			return true
		end

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
		if(roles["TANK_REMAINING"] == 0 and roles["HEALER_REMAINING"] == 0 and roles["DAMAGER_REMAINING"] == 0) then
			return true
		end

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
		if(roles["TANK_REMAINING"] == 0 and roles["HEALER_REMAINING"] == 0 and roles["DAMAGER_REMAINING"] == 0) then
			return true
		end

		local playerRole = GetSpecializationRole(GetSpecialization())
		if playerRole then
			local remainingRoleKey = roleRemainingKeyLookup[playerRole]
			if remainingRoleKey then
				return (roles[remainingRoleKey] or 0) > 0
			end
		end
	end
end

local function retrieveIDForDropdownFiltering(categoryID)
	if(categoryID == 2) then
		return MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeonDifficultyID

	elseif(categoryID == 3) then
		return MIOG_SavedSettings.searchPanel_FilterOptions.table.raidDifficultyID
	
	elseif(categoryID == 4 or categoryID == 7) then
		return MIOG_SavedSettings.searchPanel_FilterOptions.table.bracketID

	end
end

local function isGroupEligible(resultID, bordermode)
	local searchResultData = searchResultSystem.searchResultData[resultID]
	local activityInfo = C_LFGList.GetActivityInfoTable(searchResultData.activityID)

	if(activityInfo.categoryID ~= LFGListFrame.SearchPanel.categoryID and not bordermode) then
		return false

	end

	local isPvp = activityInfo.categoryID == 4 or activityInfo.categoryID == 7 or activityInfo.categoryID == 8 or activityInfo.categoryID == 9
	local isDungeon = activityInfo.categoryID == 2
	local isRaid = activityInfo.categoryID == 3

	if(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID ~= (retrieveIDForDropdownFiltering(activityInfo.categoryID))
	and (
		isDungeon and MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForDungeonDifficulty
		or isRaid and MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForRaidDifficulty
		or (activityInfo.categoryID == 4 or activityInfo.categoryID == 7) and MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForArenaBracket
	)
	)then
		return false

	end

	if(MIOG_SavedSettings.searchPanel_FilterOptions.table.partyFit == true and not HasRemainingSlotsForLocalPlayerRole(resultID)) then
		return false

	end
	
	if(MIOG_SavedSettings.searchPanel_FilterOptions.table.ressFit == true and not HasRemainingSlotsForBattleResurrection(resultID)) then
		return false

	end
	
	if(MIOG_SavedSettings.searchPanel_FilterOptions.table.lustFit == true and not HasRemainingSlotsForBloodlust(resultID)) then
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

			
			if(MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForClassSpecs) then
				if(MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.class[miog.CLASSFILE_TO_ID[class]] == false
				or MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.spec[specID] == false) then
					return false

				end
	
			end
		end
	end

	if(MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForTanks and MIOG_SavedSettings.searchPanel_FilterOptions.table.maxTanks > 0
	and not (roleCount["TANK"] >= MIOG_SavedSettings.searchPanel_FilterOptions.table.minTanks and roleCount["TANK"] <= MIOG_SavedSettings.searchPanel_FilterOptions.table.maxTanks)

	or MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForHealers and MIOG_SavedSettings.searchPanel_FilterOptions.table.maxHealers > 0
	and not (roleCount["HEALER"] >= MIOG_SavedSettings.searchPanel_FilterOptions.table.minHealers and roleCount["HEALER"] <= MIOG_SavedSettings.searchPanel_FilterOptions.table.maxHealers)

	or MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForDamager and MIOG_SavedSettings.searchPanel_FilterOptions.table.maxDamager > 0
	and not (roleCount["DAMAGER"] >= MIOG_SavedSettings.searchPanel_FilterOptions.table.minDamager and roleCount["DAMAGER"] <= MIOG_SavedSettings.searchPanel_FilterOptions.table.maxDamager)) then
		return false

	end

	local score = isPvp and (searchResultData.leaderPvpRatingInfo and searchResultData.leaderPvpRatingInfo.rating or 0) or searchResultData.leaderOverallDungeonScore or 0

	if(MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForScore) then
		if(MIOG_SavedSettings.searchPanel_FilterOptions.table.minScore ~= 0 and MIOG_SavedSettings.searchPanel_FilterOptions.table.maxScore ~= 0) then
			if(MIOG_SavedSettings.searchPanel_FilterOptions.table.maxScore >= 0
			and not (score >= MIOG_SavedSettings.searchPanel_FilterOptions.table.minScore
			and score <= MIOG_SavedSettings.searchPanel_FilterOptions.table.maxScore)) then
				return false

			end
		elseif(MIOG_SavedSettings.searchPanel_FilterOptions.table.minScore ~= 0) then
			if(score < MIOG_SavedSettings.searchPanel_FilterOptions.table.minScore) then
				return false

			end
		elseif(MIOG_SavedSettings.searchPanel_FilterOptions.table.maxScore ~= 0) then
			if(score >= MIOG_SavedSettings.searchPanel_FilterOptions.table.maxScore) then
				return false
				
			end

		end
	
	end
	
	if(isDungeon and MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeonOptions) then
		if(not MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeons[searchResultData.activityID]) then
			return false

		end

	end

	return true
end

local function setResultFrameColors(resultID)
	local resultFrame = searchResultSystem.persistentFrames[resultID]

	local isEligible = isGroupEligible(resultID, true)
	local _, appStatus = C_LFGList.GetApplicationInfo(resultID)

	
		
	if(appStatus == "applied") then
		if(isEligible) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.green):GetRGBA())

		else
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
		
		end

		resultFrame.Background:SetColorTexture(CreateColorFromHexString("FF28644B"):GetRGBA())

	elseif(resultID == searchResultSystem.selectedResult) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())
			resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	elseif(MIOG_SavedSettings.favouredApplicants.table[searchResultSystem.searchResultData[resultID].leaderName]) then
		if(isEligible) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString("FFe1ad21"):GetRGBA())

		else
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.orange):GetRGBA())

		end

		resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	else
		if(isEligible) then
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

		else
			resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.CLRSCC.orange):GetRGBA())

		end

		resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
	
	end
end

local function handleInvite(self, button, resultID, acceptInvite)
	if(button == "LeftButton") then
		if(acceptInvite) then
			C_LFGList.AcceptInvite(resultID)
			
		else
			C_LFGList.DeclineInvite(resultID)

		end
		--LFGListInviteDialog_CheckPending(self)
	end
end

miog.handleInvite = handleInvite

local function updateResultFrameStatus(resultID, newStatus, oldStatus)
	local resultFrame = searchResultSystem.persistentFrames[resultID]

	local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
	if (appStatus == "invited") then

		if(not pendingStatus) then
			miog.showUpgradedInvitePendingDialog(resultID)
		
		end

		if(miog.currentInvites[resultID]) then
			miog.updateInviteFrame(resultID, newStatus)
		end

	elseif(appStatus ~= "none") then
		if(miog.currentInvites[resultID]) then
			miog.updateInviteFrame(resultID, newStatus)

		end
	end

	newStatus = newStatus or appStatus

	if(resultFrame and newStatus) then
		if(newStatus ~= "none") then
			if(resultFrame.BasicInformationPanel.Age.ageTicker) then
				resultFrame.BasicInformationPanel.Age.ageTicker:Cancel()
			end

			if(newStatus ~= "applied") then
				resultFrame.StatusFrame:Show()
				resultFrame.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[newStatus].statusString, miog.APPLICANT_STATUS_INFO[newStatus].color))
				resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
				resultFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

				if(oldStatus and (newStatus == "declined" or newStatus == "declined_full" or newStatus == "declined_delisted" or newStatus == "timedout")) then
					resultFrame.BasicInformationPanel.Age.ageTicker = nil
					resultFrame.BasicInformationPanel.CancelApplication:Hide()

					local searchResultData = C_LFGList.GetSearchResultInfo(resultID)
					
					if(searchResultData.leaderName and newStatus ~= "declined_full")then
						MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultData.activityID .. searchResultData.leaderName] = {timestamp = time(), activeDecline = newStatus == "declined"}

					end

				elseif(newStatus == "inviteaccepted") then

				elseif(newStatus == "invitedeclined") then

				elseif(newStatus == "invited") then
					resultFrame.BasicInformationPanel.CancelApplication:Hide()

				end

			elseif(newStatus == "applied") then
				local ageNumber = 0
				local ageFrame = resultFrame.BasicInformationPanel.Age
				
				resultFrame.BasicInformationPanel.CancelApplication:Show()

				local _, _, _, appDuration = C_LFGList.GetApplicationInfo(resultID)
				ageNumber = appDuration or 0
				ageFrame:SetText("[" .. miog.secondsToClock(ageNumber) .. "]")
				ageFrame:SetTextColor(CreateColorFromHexString(miog.CLRSCC.purple):GetRGBA())

				ageFrame.ageTicker = C_Timer.NewTicker(1, function()
					ageNumber = ageNumber - 1
					ageFrame:SetText("[" .. miog.secondsToClock(ageNumber) .. "]")

				end)
				resultFrame.BasicInformationPanel.CancelApplication:Show()

				setResultFrameColors(resultID)

				resultFrame.layoutIndex = -1

				miog.searchPanel.resultPanel.container:MarkDirty()

			end
		else
			resultFrame.StatusFrame:Hide()

			local ageFrame = resultFrame.BasicInformationPanel.Age
			if(ageFrame.ageTicker) then
				ageFrame.ageTicker:Cancel()
			end

			local ageNumber = searchResultSystem.searchResultData[resultID].age
			ageFrame:SetText(miog.secondsToClock(ageNumber))
			ageFrame:SetTextColor(1, 1, 1, 1)

			ageFrame.ageTicker = C_Timer.NewTicker(1, function()
				ageNumber = ageNumber + 1
				ageFrame:SetText(miog.secondsToClock(ageNumber))
			end)

			setResultFrameColors(resultID)
		
		end
	end
end

local function createResultTooltip(resultID, resultFrame, autoAccept)
	if(C_LFGList.HasSearchResultInfo(resultID)) then
		GameTooltip:SetOwner(resultFrame, "ANCHOR_RIGHT", 25, 0)
		LFGListUtil_SetSearchEntryTooltip(GameTooltip, resultID, autoAccept == true and LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE)

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(C_LFGList.GetActivityFullName(searchResultSystem.searchResultData[resultID].activityID, nil, searchResultSystem.searchResultData[resultID].isWarMode))
		
		if(MIOG_SavedSettings.favouredApplicants.table[searchResultSystem.searchResultData[resultID].leaderName]) then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(searchResultSystem.searchResultData[resultID].leaderName .. " is on your favoured player list.")
		end

		GameTooltip:Show()
	end
end

miog.createResultTooltip = createResultTooltip

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
			
			elseif(result1.favoured and not result2.favoured) then
				return true
			
			elseif(not result1.favoured and result2.favoured) then
				return false
			
			else
				if(result1[key] == result2[key]) then
					return firstState == 1 and result1.resultID > result2.resultID or firstState == 2 and result1.resultID < result2.resultID

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

	elseif(result1.favoured and not result2.favoured) then
		return true
	
	elseif(not result1.favoured and result2.favoured) then
		return false

	else
		return result1.resultID < result2.resultID

	end

end

local function signupToGroup(resultID)
	local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
	searchResultSystem.searchResultData[resultID] = C_LFGList.GetSearchResultInfo(resultID)
	local searchResultData = searchResultSystem.searchResultData[resultID]

	if (appStatus ~= "none" or pendingStatus or searchResultData.isDelisted) then
		return false
	end

	if(searchResultSystem.selectedResult) then
		_, appStatus = C_LFGList.GetApplicationInfo(searchResultSystem.selectedResult)

		if(searchResultSystem.persistentFrames[searchResultSystem.selectedResult]) then
			searchResultSystem.persistentFrames[searchResultSystem.selectedResult]:SetBackdropBorderColor(
				CreateColorFromHexString(appStatus == "applied" and miog.CLRSCC.green or miog.C.BACKGROUND_COLOR_3):GetRGBA()
			)
		end
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	LFGListSearchPanel_SelectResult(LFGListFrame.SearchPanel, resultID)

	if(resultID ~= searchResultSystem.selectedResult and searchResultSystem.persistentFrames[resultID]) then
		searchResultSystem.persistentFrames[resultID]:SetBackdropBorderColor(CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGBA())

	end

	searchResultSystem.selectedResult = resultID

	LFGListSearchPanel_SignUp(LFGListFrame.SearchPanel)

end

local function gatherSearchResultSortData(singleResultID)
	local unsortedMainApplicantsList = {}

	local resultTable

	if(miog.F.IS_PGF1_LOADED) then
		_, resultTable = LFGListFrame.SearchPanel.totalResults, LFGListFrame.SearchPanel.results

	else
		_, resultTable = C_LFGList.GetFilteredSearchResults()

	end

	local counter = 1

	for _, resultID in ipairs(singleResultID and {[1] = singleResultID} or resultTable) do
		searchResultSystem.searchResultData[resultID] = C_LFGList.GetSearchResultInfo(resultID)

		local searchResultData = searchResultSystem.searchResultData[resultID]

		if(searchResultData and not searchResultData.hasSelf) then
			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultData.activityID)

			local _, appStatus, _, appDuration = C_LFGList.GetApplicationInfo(resultID)

			if(appStatus == "applied" or activityInfo.categoryID == LFGListFrame.SearchPanel.categoryID) then
				local primarySortAttribute, secondarySortAttribute

				local nameTable

				if(searchResultData.leaderName) then
					nameTable = miog.simpleSplit(searchResultData.leaderName, "-")
				end

				if(nameTable and not nameTable[2]) then
					nameTable[2] = GetNormalizedRealmName()

					searchResultData.leaderName = nameTable[1] .. "-" .. nameTable[2]

				end

				if(LFGListFrame.SearchPanel.categoryID ~= 3 and LFGListFrame.SearchPanel.categoryID ~= 4 and LFGListFrame.SearchPanel.categoryID ~= 7 and LFGListFrame.SearchPanel.categoryID ~= 8 and LFGListFrame.SearchPanel.categoryID ~= 9) then
					primarySortAttribute = searchResultData.leaderOverallDungeonScore or 0
					secondarySortAttribute = searchResultData.leaderDungeonScoreInfo and searchResultData.leaderDungeonScoreInfo.bestRunLevel or 0

				elseif(LFGListFrame.SearchPanel.categoryID == 3) then
					local raidData = getRaidSortData(searchResultData.leaderName)

					if(raidData) then
						primarySortAttribute = raidData[1].weight
						secondarySortAttribute = raidData[2].weight

					else
						primarySortAttribute = 0
						secondarySortAttribute = 0
					
					end

				elseif(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7 or LFGListFrame.SearchPanel.categoryID == 8 or LFGListFrame.SearchPanel.categoryID == 9) then
					primarySortAttribute = searchResultData.leaderPvpRatingInfo and searchResultData.leaderPvpRatingInfo.rating or 0
					secondarySortAttribute = searchResultData.leaderPvpRatingInfo and searchResultData.leaderPvpRatingInfo.rating or 0

				end

				unsortedMainApplicantsList[counter] = {
					leaderName = searchResultData.leaderName,
					appStatus = searchResultData.isDelisted and "declined_delisted" or appStatus,
					primary = primarySortAttribute,
					secondary = secondarySortAttribute,
					age = searchResultData.age,
					resultID = resultID,
					favoured = searchResultData.leaderName and MIOG_SavedSettings.favouredApplicants.table[searchResultData.leaderName] and true or false
				}

				counter = counter + 1
			end
		end

	end

	return unsortedMainApplicantsList
end

local function updatePersistentResultFrame(resultID)
	if(C_LFGList.HasSearchResultInfo(resultID)) then
		searchResultSystem.searchResultData[resultID] = C_LFGList.GetSearchResultInfo(resultID)

		if(searchResultSystem.persistentFrames[resultID] and searchResultSystem.searchResultData[resultID].leaderName) then
			local searchResultData = searchResultSystem.searchResultData[resultID]
			local activityInfo = C_LFGList.GetActivityInfoTable(searchResultData.activityID)
			local currentFrame = searchResultSystem.persistentFrames[resultID]
			local BasicInformationPanel = currentFrame.BasicInformationPanel
			local mapID = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].mapID or 0
			local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
			local declineData = searchResultData.leaderName and MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultData.activityID .. searchResultData.leaderName]
			
			currentFrame:SetScript("OnMouseDown", function(_, button)
				signupToGroup(searchResultData.searchResultID)

			end)
			currentFrame:SetScript("OnEnter", function()
				createResultTooltip(searchResultData.searchResultID, currentFrame, searchResultData.autoAccept)

			end)

			currentFrame.BasicInformationPanel.Icon:SetTexture(miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID][#miog.MAP_INFO[mapID]] and miog.MAP_INFO[mapID][#miog.MAP_INFO[mapID]].icon or nil)
			currentFrame.BasicInformationPanel.Icon:SetScript("OnMouseDown", function()

				--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
				EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

			end)

			local color = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and
			(activityInfo.isPvpActivity and miog.BRACKETS[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].miogColors
			or miog.DIFFICULTY[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].miogColors) or {r = 1, g = 1, b = 1}

			currentFrame.BasicInformationPanel.IconBorder:SetColorTexture(color.r, color.g, color.b, 1)
			
			if(searchPanel_ExpandedFrameList[searchResultData.searchResultID]) then
				BasicInformationPanel.ExpandFrame:AdvanceState()
		
			end
	
			BasicInformationPanel.ExpandFrame:SetScript("OnClick", function()
				if(currentFrame.DetailedInformationPanel) then
					BasicInformationPanel.ExpandFrame:AdvanceState()
					searchPanel_ExpandedFrameList[searchResultData.searchResultID] = not currentFrame.DetailedInformationPanel:IsVisible()
					currentFrame.DetailedInformationPanel:SetShown(not currentFrame.DetailedInformationPanel:IsVisible())
					currentFrame:MarkDirty()
		
				end
		
			end)

			local titleZoneColor = nil

			if(searchResultSystem.searchResultData[resultID].autoAccept) then
				titleZoneColor = miog.CLRSCC.blue
				
			elseif(declineData) then
				if(declineData.timestamp > time() - 900) then
					titleZoneColor = declineData.activeDecline and miog.CLRSCC.red or miog.CLRSCC.orange
					
				else
					titleZoneColor = "FFFFFFFF"
					MIOG_SavedSettings.searchPanel_DeclinedGroups.table[searchResultData.activityID .. searchResultData.leaderName] = nil

				end
			else
				titleZoneColor = "FFFFFFFF"
			
			end
			

			BasicInformationPanel.Title:SetText(wticc(searchResultData.name, titleZoneColor))
			BasicInformationPanel.Comment:SetShown(searchResultData.comment ~= "" and searchResultData.comment ~= nil and true or false)
			BasicInformationPanel.Friend:SetShown((searchResultData.numBNetFriends > 0 or searchResultData.numCharFriends > 0 or searchResultData.numGuildMates > 0) and true or false)

			BasicInformationPanel.CancelApplication:Hide()
			BasicInformationPanel.CancelApplication:SetScript("OnClick", function(self, button)
				if(button == "LeftButton") then
					local _, appStatus = C_LFGList.GetApplicationInfo(searchResultData.searchResultID)

					if(appStatus == "applied") then
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
						C_LFGList.CancelApplication(searchResultData.searchResultID)
					
					end
				end
			end)
			
			BasicInformationPanel.DifficultyZone:SetText(wticc(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.DIFFICULTY[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].shortName .. " - " ..
			(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].shortName) or activityInfo.fullName, titleZoneColor))

			local primaryIndicator = currentFrame.BasicInformationPanel.Primary
			primaryIndicator:SetText(nil)

			local secondaryIndicator = currentFrame.BasicInformationPanel.Secondary
			secondaryIndicator:SetText(nil)

			currentFrame.DetailedInformationPanel.MythicPlusPanel.rows[1].FontString:SetText(nil)
			currentFrame.DetailedInformationPanel.RaidPanel.rows[1].FontString:SetText(nil)
			
			local nameTable = miog.simpleSplit(searchResultData.leaderName, "-")

			gatherRaiderIODisplayData(nameTable[1], nameTable[2], currentFrame)

			local generalInfoPanel = currentFrame.DetailedInformationPanel.GeneralInfoPanel
			
			generalInfoPanel.rows[1].FontString:SetText(_G["COMMENTS_COLON"] .. " " .. ((searchResultData.comment and searchResultData.comment) or ""))
			generalInfoPanel.rows[7].FontString:SetText("Role: ")

			local appCategory = activityInfo.categoryID

			if(appCategory == 2) then
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
			elseif(appCategory == 4 or appCategory == 7 or appCategory == 8 or appCategory == 9) then
				if(searchResultData.leaderPvpRatingInfo) then
					primaryIndicator:SetText(wticc(tostring(searchResultData.leaderPvpRatingInfo.rating), miog.createCustomColorForScore(searchResultData.leaderPvpRatingInfo.rating):GenerateHexColor()))

					local tierResult = miog.simpleSplit(PVPUtil.GetTierName(searchResultData.leaderPvpRatingInfo.tier), " ")
					secondaryIndicator:SetText(strsub(tierResult[1], 0, tierResult[2] and 2 or 4) .. ((tierResult[2] and "" .. tierResult[2]) or ""))
					
				else
					primaryIndicator:SetText(0)
					secondaryIndicator:SetText("Unra")

				end
			end

			local orderedList = {}

			local roleCount = {
				["TANK"] = 0,
				["HEALER"] = 0,
				["DAMAGER"] = 0,
			}

			for i = 1, searchResultData.numMembers, 1 do
				local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(searchResultData.searchResultID, i)

				orderedList[i] = {leader = i == 1 and true or false, role = role, class = class, specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]}

				if(role) then
					roleCount[role] = roleCount[role] + 1

				end
			end

			local memberPanel = BasicInformationPanel.MemberPanel
			local bossPanel = BasicInformationPanel.BossPanel

			if(appCategory == 3 or appCategory == 9) then
				memberPanel:Hide()

				BasicInformationPanel.RoleComposition:Show()
				BasicInformationPanel.RoleComposition:SetText(roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"])

				if(miog.MAP_INFO[mapID]) then
					bossPanel:Show()

					local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(resultID)
					local encountersDefeated = {}

					if(encounterInfo) then
						for _, v in pairs(encounterInfo) do
							encountersDefeated[v] = true
						end
					end

					local numOfBosses = #miog.MAP_INFO[mapID] - 1

					for i = 1, miog.F.MOST_BOSSES, 1 do
						local currentRaidInfo = miog.MAP_INFO[mapID][numOfBosses - (i - 1)]
						if(currentRaidInfo) then
							bossPanel[tostring(i)].Icon:SetTexture(currentRaidInfo.icon)
							bossPanel[tostring(i)].Icon:SetDesaturated(encountersDefeated[currentRaidInfo.name] and true or false)
							bossPanel[tostring(i)]:Show()

						else
							bossPanel[tostring(i)]:Hide()
						
						end
					end
				else
					bossPanel:Hide()
				
				end

			elseif(appCategory ~= 0) then
				-- BRACKET 1 == 3v3, 0 == 2v2
				BasicInformationPanel.RoleComposition:Hide()
				bossPanel:Hide()

				local groupLimit = (appCategory == 4 or appCategory == 7) and (searchResultData.leaderPvpRatingInfo.bracket == 0 and 2 or searchResultData.leaderPvpRatingInfo.bracket == 1 and 3 or 5) or 5
				local groupSize = #orderedList

				if(roleCount["TANK"] == 0 and groupSize < groupLimit) then
					orderedList[groupSize + 1] = {class = "DUMMY", role = "TANK", specID = 20}
					roleCount["TANK"] = roleCount["TANK"] + 1
					groupSize = groupSize + 1
				end

				if(roleCount["HEALER"] == 0 and groupSize < groupLimit) then
					orderedList[groupSize + 1] = {class = "DUMMY", role = "HEALER", specID = 20}
					roleCount["HEALER"] = roleCount["HEALER"] + 1
					groupSize = groupSize + 1

				end

				for _ = 1, 3 - roleCount["DAMAGER"], 1 do
					if(roleCount["DAMAGER"] < 3 and groupSize < groupLimit) then
						orderedList[groupSize + 1] = {class = "DUMMY", role = "DAMAGER", specID = 20}
						roleCount["DAMAGER"] = roleCount["DAMAGER"] + 1
						groupSize = groupSize + 1

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
				
				for i = 1, groupLimit, 1 do
					local currentMemberFrame = memberPanel[tostring(i)]

					if(currentMemberFrame) then
						currentMemberFrame.Icon:SetTexture(miog.SPECIALIZATIONS[orderedList[i].specID] and miog.SPECIALIZATIONS[orderedList[i].specID].squaredIcon)

						if(orderedList[i].class ~= "DUMMY") then
							currentMemberFrame.Border:SetColorTexture(C_ClassColor.GetClassColor(orderedList[i].class):GetRGBA())

						else
							currentMemberFrame.Border:SetColorTexture(0, 0, 0, 0)
						
						end

						if(orderedList[i].leader) then
							memberPanel.LeaderCrown:ClearAllPoints()
							memberPanel.LeaderCrown:SetParent(currentMemberFrame)
							memberPanel.LeaderCrown:SetPoint("CENTER", currentMemberFrame, "TOP")

							currentMemberFrame:SetMouseMotionEnabled(true)
							currentMemberFrame:SetScript("OnEnter", function()
								GameTooltip:SetOwner(currentMemberFrame, "ANCHOR_CURSOR")
								GameTooltip:AddLine(format(_G["LFG_LIST_TOOLTIP_LEADER"], searchResultData.leaderName))
								GameTooltip:Show()

							end)
						else
							currentMemberFrame:SetScript("OnEnter", nil)
						
						end

						--orderedListIndex = orderedListIndex + 1

					else
						memberPanel[tostring(i)]:Hide()
					
					end
				end
				
				memberPanel:Show()

			end
		end
	end
end

local function createPersistentResultFrame(resultID)
	local persistentFrame = miog.createBasicFrame("searchResult", "MIOG_ResultFrameTemplate", miog.searchPanel.resultPanel.container)
	persistentFrame.fixedWidth = miog.C.MAIN_WIDTH - 2
	persistentFrame:SetFrameStrata("DIALOG")
	persistentFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)
	miog.createFrameBorder(persistentFrame, 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGB())

	persistentFrame.framePool = persistentFrame.framePool or CreateFramePoolCollection()
	persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DetailedInformationPanelTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DetailedInformationPanelTextRowTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_DungeonRowTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_ResultFrameBossFrameTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	persistentFrame.framePool:GetOrCreatePool("Frame", nil, "MIOG_RaidPanelTemplate", miog.resetFrame):SetResetDisallowedIfNew()

	searchResultSystem.persistentFrames[resultID] = persistentFrame

	persistentFrame.StatusFrame:SetFrameStrata("FULLSCREEN")

	local BasicInformationPanel = persistentFrame.BasicInformationPanel

	local expandFrameButton = BasicInformationPanel.ExpandFrame
	expandFrameButton:OnLoad()
	expandFrameButton:SetMaxStates(2)
	expandFrameButton:SetTexturesForBaseState("UI-HUD-ActionBar-PageDownArrow-Up", "UI-HUD-ActionBar-PageDownArrow-Down", "UI-HUD-ActionBar-PageDownArrow-Mouseover", "UI-HUD-ActionBar-PageDownArrow-Disabled")
	expandFrameButton:SetTexturesForState1("UI-HUD-ActionBar-PageUpArrow-Up", "UI-HUD-ActionBar-PageUpArrow-Down", "UI-HUD-ActionBar-PageUpArrow-Mouseover", "UI-HUD-ActionBar-PageUpArrow-Disabled")
	expandFrameButton:SetState(false)

	BasicInformationPanel.CancelApplication:OnLoad()

	for i = 1, 5, 1 do
		local resultMemberFrame = BasicInformationPanel.MemberPanel[tostring(i)]
		resultMemberFrame:SetPoint("LEFT", i == 1 and BasicInformationPanel.MemberPanel or BasicInformationPanel.MemberPanel[tostring(i-1)], BasicInformationPanel.MemberPanel[tostring(i-1)] and "RIGHT" or "LEFT", 14, 0)

	end

	BasicInformationPanel.BossPanel.bossFrames = {}

	for i = 1, miog.F.MOST_BOSSES, 1 do
		local resultBossFrame = BasicInformationPanel.BossPanel[tostring(i)]
		resultBossFrame:SetPoint("RIGHT", i == 1 and BasicInformationPanel.BossPanel or BasicInformationPanel.BossPanel[tostring(i-1)], i == 1 and "RIGHT" or "LEFT", -2, 0)

	end

	BasicInformationPanel.BossPanel:MarkDirty()

	createDetailedInformationPanel(persistentFrame)
end

local lastOrderedList = nil

local function checkListForEligibleMembers()
	if(lastOrderedList) then
		local actualResultsCounter = 0
		local updatedFrames = {}

		table.sort(lastOrderedList, sortSearchResultList)

		for index, listEntry in ipairs(lastOrderedList) do
			if(searchResultSystem.persistentFrames[listEntry.resultID]) then
				searchResultSystem.persistentFrames[listEntry.resultID].layoutIndex = index

				if(listEntry.appStatus == "applied" or isGroupEligible(listEntry.resultID)) then
					setResultFrameColors(listEntry.resultID)
					searchResultSystem.persistentFrames[listEntry.resultID]:Show()
					updatedFrames[listEntry.resultID] = true
					actualResultsCounter = actualResultsCounter + 1
				end

			end
		end

		for index, v in pairs(searchResultSystem.persistentFrames) do
			if(not updatedFrames[index]) then
				v:Hide()

			end
		end

		miog.searchPanel.resultPanel.container:MarkDirty()

		miog.searchPanel.groupNumberFontString:SetText(actualResultsCounter .. "(" .. #lastOrderedList .. ")")
	end
end

miog.checkListForEligibleMembers = checkListForEligibleMembers

local function releaseAllResultFrames()
	for index, v in pairs(searchResultSystem.persistentFrames) do
		v.framePool:ReleaseAll()
		--v.fontStringPool:ReleaseAll()
		--v.texturePool:ReleaseAll()

		miog.searchResultFramePool:Release(v)

		searchResultSystem.persistentFrames[index] = nil

	end
end

local function updateSearchResultList(forceReorder)
	if(not miog.F.SEARCH_IS_THROTTLED) then

		if(forceReorder) then
			releaseAllResultFrames()
		end

		searchResultSystem.selectedResult = nil
		searchResultSystem.searchResultData = {}

		local orderedList = gatherSearchResultSortData()
		table.sort(orderedList, sortSearchResultList)

		lastOrderedList = orderedList

		local actualResultsCounter = 0
		local updatedFrames = {}
		
		for index, listEntry in ipairs(orderedList) do

			if(searchResultSystem.persistentFrames[listEntry.resultID]) then
				searchResultSystem.persistentFrames[listEntry.resultID].framePool:ReleaseAll()
				searchResultSystem.persistentFrames[listEntry.resultID].fontStringPool:ReleaseAll()
				searchResultSystem.persistentFrames[listEntry.resultID].texturePool:ReleaseAll()

				miog.searchResultFramePool:Release(searchResultSystem.persistentFrames[listEntry.resultID])

				searchResultSystem.persistentFrames[listEntry.resultID] = nil
			end

			createPersistentResultFrame(listEntry.resultID)

			searchResultSystem.persistentFrames[listEntry.resultID].layoutIndex = index

			updatePersistentResultFrame(listEntry.resultID)
			updateResultFrameStatus(listEntry.resultID, listEntry.appStatus)

			if(listEntry.appStatus == "applied" or isGroupEligible(listEntry.resultID)) then
				searchResultSystem.persistentFrames[listEntry.resultID]:Show()
				updatedFrames[listEntry.resultID] = true
				actualResultsCounter = actualResultsCounter + 1

			end
		end

		for index, v in pairs(searchResultSystem.persistentFrames) do
			if(not updatedFrames[index]) then
				v:Hide()

			end
		end

		miog.searchPanel.resultPanel.container:MarkDirty()

		miog.searchPanel.groupNumberFontString:SetText(actualResultsCounter .. "(" .. #orderedList .. ")")

	end
end

miog.updateSearchResultList = updateSearchResultList

local blocked = false

local function searchResultsReceived()
	miog.searchPanel.statusFrame:Show()
	miog.searchPanel.statusFrame.throttledString:Hide()
	miog.searchPanel.statusFrame.noResultsString:Hide()
	miog.searchPanel.statusFrame.loadingSpinner:Show()

	local totalResults = LFGListFrame.SearchPanel.totalResults or C_LFGList.GetFilteredSearchResults()

	if(not LFGListFrame.SearchPanel.searching) then
		if(totalResults > 0) then
			if(not blocked) then
				blocked = true
				miog.searchPanel.resultPanel:SetVerticalScroll(0)
				
				C_Timer.After(MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods > 0 and 0.45 or 0, function()
					miog.searchPanel.statusFrame:Hide()
					miog.searchPanel.statusFrame.loadingSpinner:Hide()
					updateSearchResultList(true)
					blocked = false
				end)
			end
		else
			if(not miog.F.SEARCH_IS_THROTTLED) then
				miog.searchPanel.statusFrame.loadingSpinner:Hide()
				miog.searchPanel.statusFrame.noResultsString:SetText(LFGListFrame.SearchPanel.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND)
				miog.searchPanel.statusFrame.noResultsString:Show()

			end
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

		miog.C.AVAILABLE_ROLES["TANK"], miog.C.AVAILABLE_ROLES["HEALER"], miog.C.AVAILABLE_ROLES["DAMAGER"] = UnitGetAvailableRoles("player")

		C_MythicPlus.RequestCurrentAffixes()

		C_MythicPlus.RequestMapInfo()
		
		miog.checkForSavedSettings()
		miog.createFrames()
		miog.loadSettings()

		--createSearchResultFrames()

		LFGListFrame.ApplicationViewer:HookScript("OnShow", function(self) self:Hide() miog.applicationViewer:Show() end)
		LFGListFrame.SearchPanel:HookScript("OnShow", function(self) miog.searchPanel:Show() end)

		if(C_AddOns.IsAddOnLoaded("RaiderIO")) then
			miog.F.IS_RAIDERIO_LOADED = true

			miog.mainFrame.raiderIOAddonIsLoadedFrame:Hide()

		end
		
		if(C_AddOns.IsAddOnLoaded("PremadeGroupsFilter")) then
			miog.F.IS_PGF1_LOADED = true

			miog.scriptReceiver:UnregisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")

			hooksecurefunc("LFGListSearchPanel_UpdateResultList", function(self)
				searchResultsReceived()
			end)

		end

		for k, v in pairs(miog.SPECIALIZATIONS) do
			if(k ~= 0 and k ~= 20) then
				local _, localizedName, _, _, _, fileName = GetSpecializationInfoByID(k)

				miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[localizedName .. "-" .. fileName] = k
			end
		end

		--[[for i = 1, GetNumBattlegroundTypes(), 1 do
			local name, cantEnter, isHoliday, isRandom, battleGroundID, info = GetBattlegroundInfo(i)

			miog.INSTANCE_IDS[battleGroundID] = name
		end

		DevTools_Dump({C_PvP.GetAvailableBrawlInfo()})
		DevTools_Dump({C_PvP.GetSpecialEventBrawlInfo()})]]
		
		C_MythicPlus.GetCurrentAffixes()
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

    elseif(event == "CHALLENGE_MODE_MAPS_UPDATE") then
		if(not miog.searchPanel.filterFrame.dungeonPanel) then
			local currentSeason = C_MythicPlus.GetCurrentSeason()

			miog.F.CURRENT_SEASON = currentSeason
			miog.F.PREVIOUS_SEASON = currentSeason - 1

			miog.addDungeonCheckboxes()
			--miog.initializeActivityDropdown()

		end

    elseif(event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
		if(not miog.F.WEEKLY_AFFIX) then
			C_MythicPlus.GetCurrentAffixes() -- Safety call, so Affixes are 100% available

			if(miog.applicationViewer and miog.applicationViewer.infoPanel) then
				miog.setAffixes()

			end

        end

	elseif(event == "GROUP_JOINED" or event == "GROUP_LEFT") then
		miog.checkIfCanInvite()

		updateRosterInfoData()

	elseif(event == "PARTY_LEADER_CHANGED") then
		local canInvite = miog.checkIfCanInvite()

		for _,v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame.memberFrames[1].BasicInformationPanel.inviteButton:SetShown(canInvite)
				v.frame.memberFrames[1].BasicInformationPanel.declineButton:SetShown(canInvite)

			end
		end

	elseif(event == "GROUP_ROSTER_UPDATE") then
		local canInvite = miog.checkIfCanInvite()

		for _,v in pairs(applicantSystem.applicantMember) do
			if(v.frame) then
				v.frame.memberFrames[1].BasicInformationPanel.inviteButton:SetShown(canInvite)
				v.frame.memberFrames[1].BasicInformationPanel.declineButton:SetShown(canInvite)

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
		
		--checkSearchResultCoroutine()

	elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
		--print("RESULT UPDATE: " .. ...)
		--updateSearchResultList(false, ...)

		--searchResultQueue[...] = true
		
		--checkSearchResultCoroutine()

		updatePersistentResultFrame(...)
		updateResultFrameStatus(..., searchResultSystem.searchResultData[...] and searchResultSystem.searchResultData[...].isDelisted and "declined_delisted" or nil)

		--reorderAllFrames()

	elseif(event == "LFG_LIST_SEARCH_FAILED") then
		--print("Search failed because of " .. ...)

		if(... == "throttled") then
			if(not miog.F.SEARCH_IS_THROTTLED) then
				miog.F.SEARCH_IS_THROTTLED = true
				local timestamp = GetTime()

				miog.searchPanel.statusFrame.noResultsString:Hide()
				miog.searchPanel.statusFrame.loadingSpinner:Hide()
				miog.searchPanel.statusFrame.throttledString:SetText("Time until search is available again: " .. miog.secondsToClock(timestamp + 3 - GetTime()))

				C_Timer.NewTicker(0.2, function(self)
					local timeUntil = timestamp + 3 - GetTime()
					miog.searchPanel.statusFrame.throttledString:SetText("Time until search is available again: " .. wticc(miog.secondsToClock(timeUntil), timeUntil > 2 and miog.CLRSCC.red or timeUntil > 1 and miog.CLRSCC.orange or miog.CLRSCC.yellow))

					if(timeUntil <= 0) then
						miog.searchPanel.statusFrame.throttledString:SetText(wticc("Search is available again!", miog.CLRSCC.green))
						miog.F.SEARCH_IS_THROTTLED = false
						self:Cancel()
					end
				end)
			
				miog.searchPanel.statusFrame:Show()
				miog.searchPanel.statusFrame.throttledString:Show()

			end
		end

	elseif(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
		local resultID, new, old, name = ...
		--print(...)

		updateResultFrameStatus(resultID, new, old)

		--[[local apps = C_LFGList.GetApplications()
		for i=1, #apps do
		local _, status, pendingStatus = C_LFGList.GetApplicationInfo(apps[i])

		if (status == "invited") then

			if(not pendingStatus) then

			else
				if(miog.currentInvites[resultID]) then
					miog.hideActiveInviteFrame(resultID)
				end
			
			end

			--print(i, resultID)
		else
			if(miog.currentInvites[resultID]) then
				--miog.hideActiveInviteFrame(resultID)
				miog.updateInviteFrame(resultID, status)
			end

		end]]
		

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS") then
		--print(event, ...)
		--Happens when in a group and group is at max members after inviting a person
		--Not decided if it's needed

	elseif(event == "LFG_LIST_ENTRY_EXPIRED_TIMEOUT") then
		--print(event, ...)


	elseif(event == "LFG_UPDATE") then
		--[[print("LFGUPDATE")
		local queuedFor = {}

		for categoryID, listEntry in ipairs(LFGQueuedForList) do
			for dungeonID, queued in pairs(listEntry) do
				queuedFor[dungeonID] = true
			end
		end

		for queueFrameID, frame in pairs(miog.queueSystem.queueFrames) do
			print(queueFrameID)
			if(not queuedFor[queueFrameID]) then
				print("RELEASE")
				miog.queueSystem.framePool:Release(frame)
				miog.queueSystem.queueFrames[queueFrameID] = nil

			end

		end

		miog.pveFrame2.QueuePanel.Container:MarkDirty()]]
		
	elseif(event == "LFG_QUEUE_STATUS_UPDATE") then
		--[[print("QUEUE UPDATE")

		for i=1, NUM_LE_LFG_CATEGORYS do
			LFGQueuedForList[i] = GetLFGQueuedList(i, LFGQueuedForList[i]);	--Re-fill table if it already exists, otherwise create
		end

		for categoryID, listEntry in ipairs(LFGQueuedForList) do
			for dungeonID, queued in pairs(listEntry) do
				if(queued == true) then
					--DevTools_Dump({GetLFGDungeonInfo(dungeonID)})
					--DevTools_Dump({})
					local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, dungeonID)

					--print(hasData, categoryID, instanceName)

					if (hasData and queuedTime and not miog.queueSystem.queueFrames[dungeonID]) then
						--miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(dungeonID)}, {GetLFGQueueStats(categoryID)})
					end
				end
			end
		end]]

	elseif(event == "UPDATE_BATTLEFIELD_STATUS") then
		--print("BATTLEFIELD")

		--[[local totalHeight = 4; --Add some buffer height

		local queuedFor = {}

		for i=1, GetMaxBattlefieldID() do
			local status, mapName, teamSize, registeredMatch, suspend, queueType, _, _, _, short, long = GetBattlefieldStatus(i);

			--print(i, status)
			if (status == "queued" and not suspend) then
				queuedFor[mapName] = true

				local queuedTime = GetTime() - GetBattlefieldTimeWaited(i) / 1000
				local estimatedTime = GetBattlefieldEstimatedWaitTime(i) / 1000
				--local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
				--local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);

				--		1		2			3			4			5			6			7				8		9				10				11				12			13			14			15		16			17
				--local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime

				--print(mapName, queueType, short, long)
				

				local queueStats = {
					[1] = true,
					[11] = mapName,
					[12] = estimatedTime,
					[17] = queuedTime,
					[18] = mapName,
					[19] = "BATTLEGROUND"
				}
				if (queuedTime and not miog.queueSystem.queueFrames[mapName]) then
					miog.createQueueFrame(i, nil, queueStats)
				end

				if(miog.queueSystem.queueFrames[mapName]) then

					miog.queueSystem.queueFrames[mapName].CancelApplication:SetAttribute("macrotext1", i == 1 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button2 Left Button"
				or i == 2 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button4 Left Button"
				or i == 3 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button6 Left Button")

				end
			elseif(status == "none") then
				local inArena = IsActiveBattlefieldArena()

				if ( not inArena or GetBattlefieldWinner() or C_Commentator.GetMode() > 0 or C_PvP.IsInBrawl() ) then
				end
		
				if ( not inArena ) then
				end
		
				if ( inArena and not C_PvP.IsInBrawl() ) then
				else
					if ( C_PvP.IsSoloShuffle() ) then

					end
					if ( C_PvP.IsInBrawl() ) then

					else
						--queuedFor[i] = false

						--print("TRUE FOR ", i)

						for queueFrameID, frame in pairs(miog.queueSystem.queueFrames) do
							if(not queuedFor[queueFrameID]) then
								miog.queueSystem.framePool:Release(frame)
								miog.queueSystem.queueFrames[queueFrameID] = nil

							end

						end

						miog.pveFrame2.QueuePanel.Container:MarkDirty()

					end
				end
			
			end
		end]]
		
	elseif(event == "PVP_BRAWL_INFO_UPDATED") then
		print("BRAWL LIST")
		--miog.updateQueueDropDown()
		miog.updatePvP()

	elseif(event == "LFG_LIST_AVAILABILITY_UPDATE") then
		print("UPDATE LIST")
		miog.updateQueueDropDown()
		miog.initializeActivityDropdown()

		local lastFrame = nil
	
		--for i=1, #miog.CUSTOM_CATEGORY_ORDER do
		for k, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
			local isSelected = false;
			local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);

			if(not _G["MythicIOGrabber_" .. categoryInfo.name .. "Button"]) then

				local categoryFrame = CreateFrame("Button", "MythicIOGrabber_" .. categoryInfo.name .. "Button", miog.pveFrame2.CategoryPanel, "MIOG_MenuButtonTemplate")
				categoryFrame:SetHeight(30)
				categoryFrame:SetPoint("TOPLEFT", lastFrame or miog.pveFrame2.CategoryPanel, lastFrame and "BOTTOMLEFT" or "TOPLEFT", 0, k == 1 and 0 or -3)
				categoryFrame:SetPoint("TOPRIGHT", lastFrame or miog.pveFrame2.CategoryPanel, lastFrame and "BOTTOMRIGHT" or "TOPRIGHT", 0, k == 1 and 0 or -3)
				---@diagnostic disable-next-line: undefined-field
				categoryFrame.Title:SetText(categoryInfo.name)
				---@diagnostic disable-next-line: undefined-field
				categoryFrame.BackgroundImage:SetVertTile(true)
				---@diagnostic disable-next-line: undefined-field
				categoryFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], nil, "CLAMPTOBLACKADDITIVE")
				---@diagnostic disable-next-line: undefined-field
				categoryFrame.StartGroup:SetScript("OnClick", function()
					miog.F.LISTED_CATEGORY_ID = categoryID
					LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.EntryCreation)
				end)
				---@diagnostic disable-next-line: undefined-field
				categoryFrame.FindGroup:SetScript("OnClick", function()
					--local baseFilters = self:GetParent().baseFilters;
					--local searchPanel = self:GetParent().SearchPanel;
					--LFGListSearchPanel_Clear(searchPanel);
					--if questID then
					--	C_LFGList.SetSearchToQuestID(questID);
					--end
					--LFGListSearchPanel_SetCategory(searchPanel, self.selectedCategory, self.selectedFilters, baseFilters);
					--LFGListSearchPanel_DoSearch(searchPanel);
					--LFGListFrame_SetActivePanel(self:GetParent(), searchPanel);

					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
					local baseFilters = LFGListFrame.baseFilters
					local searchPanel = LFGListFrame.SearchPanel

					miog.LFG_LIST_FILTER = Enum.LFGListFilter.Recommended
					miog.pveFrame2.filters = miog.LFG_LIST_FILTER
					miog.pveFrame2.categoryID = categoryID

					LFGListFrame.SearchPanel.preferredFilters = miog.LFG_LIST_FILTER

					LFGListSearchPanel_SetCategory(searchPanel, categoryID, miog.LFG_LIST_FILTER, baseFilters)
					LFGListSearchPanel_DoSearch(searchPanel)

					--miog.requestSearchResults(categoryID, miog.LFG_LIST_FILTER)
					LFGListFrame_SetActivePanel(LFGListFrame, searchPanel)

					miog.mainFrame:Show()
					miog.searchPanel:Show()
				end)
			
				lastFrame = categoryFrame
		
				--DevTools_Dump(categoryInfo)
				if categoryInfo.separateRecommended then
					local notRecommendedFrame = CreateFrame("Button", "MythicIOGrabber_" .. LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, true) .. "Button", miog.pveFrame2.CategoryPanel, "MIOG_MenuButtonTemplate")
					notRecommendedFrame:SetHeight(30)
					notRecommendedFrame:SetPoint("TOPLEFT", lastFrame or miog.pveFrame2.CategoryPanel, lastFrame and "BOTTOMLEFT" or "TOPLEFT", 0, k == 1 and 0 or -3)
					notRecommendedFrame:SetPoint("TOPRIGHT", lastFrame or miog.pveFrame2.CategoryPanel, lastFrame and "BOTTOMRIGHT" or "TOPRIGHT", 0, k == 1 and 0 or -3)
					---@diagnostic disable-next-line: undefined-field
					notRecommendedFrame.Title:SetText(LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, true))
					---@diagnostic disable-next-line: undefined-field
					notRecommendedFrame.BackgroundImage:SetVertTile(true)
					---@diagnostic disable-next-line: undefined-field
					notRecommendedFrame.BackgroundImage:SetHorizTile(true)
					---@diagnostic disable-next-line: undefined-field
					notRecommendedFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
					---@diagnostic disable-next-line: undefined-field
					notRecommendedFrame.StartGroup:SetScript("OnClick", function()
						miog.F.LISTED_CATEGORY_ID = categoryID
						LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.EntryCreation)
					end)
---@diagnostic disable-next-line: undefined-field
					notRecommendedFrame.FindGroup:SetScript("OnClick", function()
						--local baseFilters = self:GetParent().baseFilters;
						--local searchPanel = self:GetParent().SearchPanel;
						--LFGListSearchPanel_Clear(searchPanel);
						--if questID then
						--	C_LFGList.SetSearchToQuestID(questID);
						--end
						--LFGListSearchPanel_SetCategory(searchPanel, self.selectedCategory, self.selectedFilters, baseFilters);
						--LFGListSearchPanel_DoSearch(searchPanel);
						--LFGListFrame_SetActivePanel(self:GetParent(), searchPanel);

						miog.LFG_LIST_FILTER = Enum.LFGListFilter.NotRecommended
						miog.pveFrame2.filters = miog.LFG_LIST_FILTER
						miog.pveFrame2.categoryID = categoryID

						LFGListFrame.SearchPanel.preferredFilters = miog.LFG_LIST_FILTER

						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
						local baseFilters = LFGListFrame.baseFilters
						local searchPanel = LFGListFrame.SearchPanel
						LFGListSearchPanel_SetCategory(searchPanel, categoryID, miog.LFG_LIST_FILTER, baseFilters)
						LFGListSearchPanel_DoSearch(searchPanel)
						--miog.requestSearchResults(categoryID, miog.LFG_LIST_FILTER)
						LFGListFrame_SetActivePanel(LFGListFrame, searchPanel)
						miog.mainFrame:Show()
						miog.searchPanel:Show()
					end)
			
					lastFrame = notRecommendedFrame
				end
			end	
		end
	elseif(event == "BATTLEFIELDS_SHOW") then
		print("BF SHOW")
	end
end

local function ResolveCategoryFilters(categoryID, filters)
	-- Dungeons ONLY display recommended groups.
	if categoryID == GROUP_FINDER_CATEGORY_ID_DUNGEONS then
		return bit.band(bit.bnot(Enum.LFGListFilter.NotRecommended), bit.bor(filters, Enum.LFGListFilter.Recommended));
	end

	return filters;
end

--[===[miog.updateSearchBoxAutoComplete = function(self)
	local text = self.SearchBox:GetText();
	if ( text == "" or not self.SearchBox:HasFocus() ) then
		self.AutoCompleteFrame:Hide();
		self.AutoCompleteFrame.selected = nil;
		return;
	end

	--Choose the autocomplete results
	local filters = ResolveCategoryFilters(self.categoryID, self.filters);
	local matchingActivities = C_LFGList.GetAvailableActivities(self.categoryID, nil, filters, text);
	LFGListUtil_SortActivitiesByRelevancy(matchingActivities);

	local numResults = math.min(#matchingActivities, MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES);

	if ( numResults == 0 ) then
		self.AutoCompleteFrame:Hide();
		self.AutoCompleteFrame.selected = nil;
		return;
	end

	--Update the buttons
	local foundSelected = false;
	for i=1, numResults do
		local id = matchingActivities[i];

		local button = self.AutoCompleteFrame.Results[i];
		if ( not button ) then
			button = CreateFrame("BUTTON", nil, self.AutoCompleteFrame, "LFGListSearchAutoCompleteButtonTemplate");
			button:SetPoint("TOPLEFT", self.AutoCompleteFrame.Results[i-1], "BOTTOMLEFT", 0, 0);
			button:SetPoint("TOPRIGHT", self.AutoCompleteFrame.Results[i-1], "BOTTOMRIGHT", 0, 0);
			self.AutoCompleteFrame.Results[i] = button;
		end

		if ( i == numResults and numResults < #matchingActivities ) then
			--This is just a "x more" button
			button:SetFormattedText(LFG_LIST_AND_MORE, #matchingActivities - numResults + 1);
			button:Disable();
			button.Selected:Hide();
			button.activityID = nil;
		else
			--This is an actual activity
			button:SetText( (C_LFGList.GetActivityFullName(id)) );
			button:Enable();
			button.activityID = id;

			if ( id == self.AutoCompleteFrame.selected ) then
				button.Selected:Show();
				foundSelected = true;
			else
				button.Selected:Hide();
			end
		end
		button:Show();
	end

	if ( not foundSelected ) then
		self.selected = nil;
	end

	--Hide unused buttons
	for i=numResults + 1, #self.AutoCompleteFrame.Results do
		self.AutoCompleteFrame.Results[i]:Hide();
	end

	--Update the frames height and show it
	self.AutoCompleteFrame:SetHeight(numResults * self.AutoCompleteFrame.Results[1]:GetHeight() + 8);
	self.AutoCompleteFrame:Show();
end

function LFGListSearchPanel_DoSearch()
	local self = LFGListFrame.SearchPanel

	local searchText = self.SearchBox:GetText();
	local languages = C_LFGList.GetLanguageSearchFilter();

	local filters = ResolveCategoryFilters(self.categoryID, self.filters);
	C_LFGList.Search(self.categoryID, filters, self.preferredFilters, languages);
	self.searching = true;
	self.searchFailed = false;
	self.selectedResult = nil;
	LFGListSearchPanel_UpdateResultList(self);

	-- If auto-create is desired, then the caller needs to set up that data after the search begins.
	-- There's an issue with using OnTextChanged to handle this due to how OnShow processes the update.
	if self.previousSearchText ~= searchText then
		LFGListEntryCreation_ClearAutoCreateMode(self:GetParent().EntryCreation);
	end

	self.previousSearchText = searchText;
end]===]

--[===[local function requestSearchResults2(categoryID, filters)

	local searchText = self.SearchBox:GetText();
	local languages = C_LFGList.GetLanguageSearchFilter();

	filters = ResolveCategoryFilters(self.categoryID, self.filters);
	C_LFGList.Search(miog.pveFrame2.categoryID, filters, miog.pveFrame2.preferredFilters, languages);
	self.searching = true;
	self.searchFailed = false;
	self.selectedResult = nil;
	LFGListSearchPanel_UpdateResultList(self);

	-- If auto-create is desired, then the caller needs to set up that data after the search begins.
	-- There's an issue with using OnTextChanged to handle this due to how OnShow processes the update.
	if self.previousSearchText ~= searchText then
		LFGListEntryCreation_ClearAutoCreateMode(self:GetParent().EntryCreation);
	end

	self.previousSearchText = searchText;



	--[[local searchText = self.SearchBox:GetText();
	local languages = C_LFGList.GetLanguageSearchFilter();

	local filters = ResolveCategoryFilters(self.categoryID, self.filters);

	C_LFGList.Search(categoryID, filters, LFGListFrame.baseFilters, languages, true);

	local searching = true;
	local searchFailed = false;
	local selectedResult = nil;

	LFGListFrame.SearchPanel.totalResults, LFGListFrame.SearchPanel.results = C_LFGList.GetFilteredSearchResults();
	LFGListFrame.SearchPanel.applications = C_LFGList.GetApplications();
	LFGListUtil_SortSearchResults(LFGListFrame.SearchPanel.results);


	--If we have an application selected, deselect it.
	LFGListSearchPanel_ValidateSelected(self);

	if ( self.searching ) then
		self.SearchingSpinner:Show();
		self.ScrollBox.NoResultsFound:Hide();
		self.ScrollBox.StartGroupButton:Hide();
		self.ScrollBox:RemoveDataProvider();
	else
		self.SearchingSpinner:Hide();

		local dataProvider = CreateDataProvider();
		local results = self.results;
		for index = 1, #results do
			dataProvider:Insert({resultID=results[index]});
		end

		local apps = self.applications;
		local resultSet = tInvert(self.results);
		for i, app in ipairs(apps) do
			if not resultSet[app]  then
				dataProvider:Insert({resultID=app});
			end
		end

		if(self.totalResults == 0) then
			self.ScrollBox.NoResultsFound:Show();
			self.ScrollBox.StartGroupButton:SetShown(not self.searchFailed);
			self.ScrollBox.StartGroupButton:ClearAllPoints();
			self.ScrollBox.StartGroupButton:SetPoint("BOTTOM", self.ScrollBox.NoResultsFound, "BOTTOM", 0, - 27);
			self.ScrollBox.NoResultsFound:SetText(self.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND);
		else
			self.ScrollBox.NoResultsFound:Hide();
			self.ScrollBox.StartGroupButton:SetShown(false);

			if(self.shouldAlwaysShowCreateGroupButton) then
				dataProvider:Insert({startGroup=true});
			end
		end

		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

		--Reanchor the errors to not overlap applications
		if not self.ScrollBox:HasScrollableExtent() then
			local extent = self.ScrollBox:GetExtent();
			self.ScrollBox.NoResultsFound:SetPoint("TOP", self.ScrollBox, "TOP", 0, -extent - 27);
		end
	end
	LFGListSearchPanel_UpdateButtonStatus(self);
	
	if self.previousSearchText ~= searchText then
		LFGListEntryCreation_ClearAutoCreateMode(self:GetParent().EntryCreation);
	end
	
	self.previousSearchText = searchText]]
end

miog.requestSearchResults = requestSearchResults]===]

SLASH_MIOG1 = '/miog'
local function handler(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if(command == "") then

	elseif(command == "options") then
		MIOG_OpenInterfaceOptions()

	elseif(command == "debugon_av") then
		if(IsInGroup()) then
			miog.F.IS_IN_DEBUG_MODE = true
			print("Debug mode on - No standard applicants coming through")

			PVEFrame:Show()
			LFGListFrame:Show()
			LFGListPVEStub:Show()
			LFGListFrame.ApplicationViewer:Show()

			createFullEntries(33)

			miog.applicationViewer:Show()
		end
	elseif(command == "debugon_av_self") then
		if(IsInGroup()) then
			miog.F.IS_IN_DEBUG_MODE = true
			print("Debug mode on - No standard applicants coming through")

			PVEFrame:Show()
			LFGListFrame:Show()
			LFGListPVEStub:Show()
			LFGListFrame.ApplicationViewer:Show()

			createAVSelfEntry(rest)

			miog.applicationViewer:Show()
		end
	elseif(command == "debugoff_av") then
		releaseApplicantFrames()
		resetArrays()

	elseif(command == "debugon") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

	elseif(command == "debugoff") then
		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false

	elseif(command == "debug_av_perfstart") then
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

	elseif(command == "debug_av_perfstop") then
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

	elseif(command == "debug_sp_perfstart") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

		local index = 1
		local tickRate = 0.2
		local testLength = (tonumber(rest) or 10) / tickRate -- in seconds

		currentAverageExecuteTime = {}

		debugTimer = C_Timer.NewTicker(tickRate, function(self)

			local startTime = GetTimePreciseSec()
			updateSearchResultList(true)
			local endTime = GetTimePreciseSec()
		
			currentAverageExecuteTime[#currentAverageExecuteTime+1] = endTime - startTime

			print(currentAverageExecuteTime[#currentAverageExecuteTime])

			index = index + 1

			if(index == testLength) then
				self:Cancel()

				local avg = 0

				for _, v in ipairs(currentAverageExecuteTime) do
					avg = avg + v
				end

				print("Avg exec time: "..(avg / #currentAverageExecuteTime))

				print("Debug mode off - Normal search result mode")
				miog.F.IS_IN_DEBUG_MODE = false
			end
		end)

	elseif(command == "debug_sp_perfstop") then
		if(debugTimer) then
			debugTimer:Cancel()

			local avg = 0

			for _,v in ipairs(currentAverageExecuteTime) do
				avg = avg + v
			end

			print("Avg exec time: "..avg / #currentAverageExecuteTime)
		end

		print("Debug mode off - Normal search result mode")
		miog.F.IS_IN_DEBUG_MODE = false

	elseif(command == "favour") then

		local nameTable = miog.simpleSplit(rest, "-")

		if(not nameTable[2]) then
			nameTable[2] = GetNormalizedRealmName()

			rest = nameTable[1] .. "-" .. nameTable[2]

		end

		MIOG_SavedSettings.favouredApplicants.table[rest] = {name = nameTable[1], fullName = rest}
	
	else
		--miog.applicationViewer:Show()

	end
end
SlashCmdList["MIOG"] = handler


hooksecurefunc("LFGListFrame_SetActivePanel", function(_, panel)
	if(panel == LFGListFrame.ApplicationViewer) then
		miog.searchPanel:Hide()
		miog.entryCreation:Hide()

		miog.mainFrame:Show()
		miog.applicationViewer:Show()
		
		--miog.F.LISTED_CATEGORY_ID = nil

	elseif(panel == LFGListFrame.SearchPanel) then
		miog.applicationViewer:Hide()
		miog.entryCreation:Hide()

		miog.mainFrame:Show()
		miog.searchPanel:Show()

		if(LFGListFrame.SearchPanel.categoryID == 2 or LFGListFrame.SearchPanel.categoryID == 3 or LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) then
			UIDropDownMenu_Initialize(miog.searchPanel.filterFrame.dropdown, miog.searchPanel.filterFrame.dropdown.initialize)
			miog.searchPanel.filterFrame.filterForDifficulty:Show()
			miog.searchPanel.filterFrame.dropdown:Show()

		else
			miog.searchPanel.filterFrame.dropdown:Hide()
			miog.searchPanel.filterFrame.filterForDifficulty:Hide()
		
		end

		miog.F.LISTED_CATEGORY_ID = LFGListFrame.SearchPanel.categoryID

		miog.searchPanel.filterFrame.filterForDifficulty:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[miog.F.LISTED_CATEGORY_ID == 2 and "filterForDungeonDifficulty" or miog.F.LISTED_CATEGORY_ID == 3 and "filterForRaidDifficulty" or(miog.F.LISTED_CATEGORY_ID == 4 or miog.F.LISTED_CATEGORY_ID == 7) and "filterForArenaBracket"] or false)

	elseif(panel == LFGListFrame.EntryCreation) then
		miog.applicationViewer:Hide()
		miog.searchPanel:Hide()

		miog.mainFrame:Show()
		miog.entryCreation:Show()
		
	else
		miog.mainFrame:Hide()
		miog.applicationViewer:Hide()
		miog.searchPanel:Hide()
		miog.entryCreation:Hide()
		
		miog.F.LISTED_CATEGORY_ID = nil

	end
	--miog.searchPanel.filterFrame.dropdown.initialize()
	--miog.searchPanel.filterFrame.dropdown.initialize(miog.searchPanel.filterFrame.dropdown)
	--UIDropDownMenu_RefreshAll(miog.searchPanel.filterFrame.dropdown, "")
end)

hooksecurefunc("NotifyInspect", function()
	lastNotifyTime = GetTimePreciseSec()
end)

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

--[[function LFGListInviteDialog_CheckPending(self)
	--print("GOT INVITE")

	local apps = C_LFGList.GetApplications()
	for i=1, #apps do
		local resultID, status, pendingStatus = C_LFGList.GetApplicationInfo(apps[i])

		if (status == "invited") then
			if(not pendingStatus) then
				if(miog.currentInvites[resultID] == nil) then
					miog.showUpgradedInvitePendingDialog(self, resultID)
				end

			else
				if(miog.currentInvites[resultID]) then
					miog.hideActiveInviteFrame(resultID)
				end
			
			end

			print(i, resultID)
		else
			if(miog.currentInvites[resultID]) then
				miog.hideActiveInviteFrame(resultID)
			end

		end
	end

end]]

hooksecurefunc("LFGListInviteDialog_CheckPending", function (self)
	StaticPopupSpecial_Hide(self)
	
end)

--[[function LFGListInviteDialog_Show(self, resultID, kstringGroupName)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
	local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);
	local _, status, _, _, role = C_LFGList.GetApplicationInfo(resultID);

	local informational = (status ~= "invited");
	assert(not informational or status == "inviteaccepted");

	self.resultID = resultID;
	self.GroupName:SetText(kstringGroupName or searchResultInfo.name);
	self.ActivityName:SetText(activityName);
	self.Role:SetText(_G[role]);
	local showDisabled = false;
	self.RoleIcon:SetAtlas(GetIconForRole(role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
	self.Label:SetText(informational and LFG_LIST_JOINED_GROUP_NOTICE or LFG_LIST_INVITED_TO_GROUP);

	self.informational = informational;
	self.AcceptButton:SetShown(not informational);
	self.DeclineButton:SetShown(not informational);
	self.AcknowledgeButton:SetShown(informational);

---@diagnostic disable-next-line: redundant-parameter
	if ( not informational and GroupHasOfflineMember(LE_PARTY_CATEGORY_HOME) ) then
		self:SetHeight(250);
		self.OfflineNotice:Show();
		LFGListInviteDialog_UpdateOfflineNotice(self);
	else
		self:SetHeight(210);
		self.OfflineNotice:Hide();
	end

	--StaticPopupSpecial_Show(self);	
	
	--PlaySound(SOUNDKIT.READY_CHECK);
	--FlashClientIcon();
end]]