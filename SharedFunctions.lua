local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.listGroup = function() -- Effectively replaces LFGListEntryCreation_ListGroupInternal
	local frame = miog.entryCreation

	local itemLevel = tonumber(frame.ItemLevel:GetText()) or 0;
	local rating = tonumber(frame.Rating:GetText()) or 0;
	local pvpRating = rating
	local mythicPlusRating = rating
	local autoAccept = false;
	local privateGroup = frame.PrivateGroup:GetChecked();
	local isCrossFaction =  frame.CrossFaction:IsShown() and not frame.CrossFaction:GetChecked();
	local selectedPlaystyle = frame.PlaystyleDropDown:IsShown() and frame.PlaystyleDropDown.Selected.value or nil;
	local activityID = frame.DifficultyDropDown.Selected.value or frame.ActivityDropDown.Selected.value or 0

	local self = LFGListFrame.EntryCreation

	local honorLevel = 0;

	local activeEntryInfo = C_LFGList.GetActiveEntryInfo()

	if ( LFGListEntryCreation_IsEditMode(self) ) then
		if activeEntryInfo.isCrossFactionListing == isCrossFaction then
			C_LFGList.UpdateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
		else
			-- Changing cross faction setting requires re-listing the group due to how listings are bucketed server side.
			C_LFGList.RemoveListing();
			C_LFGList.CreateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
		end

		LFGListFrame_SetActivePanel(self:GetParent(), self:GetParent().ApplicationViewer);
	else
		if(C_LFGList.HasActiveEntryInfo()) then
			C_LFGList.UpdateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction)

		else
			C_LFGList.CreateListing(activityID, itemLevel, honorLevel, autoAccept, privateGroup, 0, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction)

		end

		self.WorkingCover:Show();
		LFGListEntryCreation_ClearFocus(self);
	end
end

miog.ONCE = 0

local function getRaidSortData(playerName)
	local raidData = {}

	local profile

	if(miog.F.IS_RAIDERIO_LOADED) then
		profile = RaiderIO.GetProfile(playerName)

	end

	if(profile and profile.success == true) then
		if(profile.raidProfile) then
			local lastDifficulty = nil
			local lastOrdinal = nil

			for i = 1, #profile.raidProfile.raidProgress, 1 do
				if(profile.raidProfile.raidProgress[i].isMainProgress == false) then
					local bossCount = profile.raidProfile.raidProgress[i].raid.bossCount

					local highestIndex = profile.raidProfile.raidProgress[i].progress[2] and 2 or 1
					local kills = profile.raidProfile.raidProgress[i].progress[highestIndex].kills or 0

					raidData[#raidData+1] = {
						ordinal = profile.raidProfile.raidProgress[i].raid.ordinal,
						difficulty = profile.raidProfile.raidProgress[i].progress[highestIndex].difficulty,
						progress = kills,
						bossCount = bossCount,
						parsedString = kills .. "/" .. bossCount,
						weight = kills / bossCount + miog.WEIGHTS_TABLE[profile.raidProfile.raidProgress[i].raid.ordinal][profile.raidProfile.raidProgress[i].progress[highestIndex].difficulty]
					}
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
	detailedInformationPanel:SetPoint("TOPLEFT", listFrame.BasicInformationPanel or listFrame.CategoryInformation, "BOTTOMLEFT")
	detailedInformationPanel:SetPoint("TOPRIGHT", listFrame.BasicInformationPanel or listFrame.CategoryInformation, "BOTTOMRIGHT")
	detailedInformationPanel:SetShown((listFrame.BasicInformationPanel or listFrame.CategoryInformation).ExpandFrame:GetActiveState() > 0 and true or false)
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

	local activeEntry = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo()
	local categoryID = activeEntry and C_LFGList.GetActivityInfoTable(activeEntry.activityID).categoryID or LFGListFrame.SearchPanel.categoryID

	local mythicPlusPanel = detailedInformationPanel.MythicPlusPanel
	mythicPlusPanel:SetShown(categoryID ~= 3 and true)
	mythicPlusPanel.rows = {}
	mythicPlusPanel.dungeonFrames = {}

	local raidPanel = detailedInformationPanel.RaidPanel
	--raidPanel:SetPoint("TOPLEFT", tabPanel, "BOTTOMLEFT")
	raidPanel:SetShown(categoryID == 3 and true)
	raidPanel.rows = {}

	-- 9 * 20

	local generalInfoPanel = detailedInformationPanel.GeneralInfoPanel
	generalInfoPanel.rows = {}

	local hoverColor = {}
	local cardColor = {}

	for rowIndex = 1, 9, 1 do
		local remainder = math.fmod(rowIndex, 2)

		local textRowFrame = miog.createFleetingFrame(poolFrame.framePool, "MIOG_DetailedInformationPanelTextRowTemplate", detailedInformationPanel)
		textRowFrame:SetPoint("TOPLEFT", tabPanel.rows[rowIndex-1] or tabPanel, "BOTTOMLEFT")
		textRowFrame:SetPoint("TOPRIGHT", tabPanel.rows[rowIndex-1] or tabPanel, "BOTTOMRIGHT")
		textRowFrame:SetHeight(miog.C.APPLICANT_MEMBER_HEIGHT)
		tabPanel.rows[rowIndex] = textRowFrame

		if(remainder == 1) then
			textRowFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())

		else
			textRowFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA())

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
				if(self:GetText() ~= nil and self:IsTruncated()) then
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

miog.createDetailedInformationPanel = createDetailedInformationPanel

local function gatherRaiderIODisplayData(playerName, realm, poolFrame, memberFrame)
	if (memberFrame == nil) then
		memberFrame = poolFrame

	end

	local profile, mythicKeystoneProfile, raidProfile
	local BasicInformationPanel = memberFrame.BasicInformationPanel or memberFrame.BasicInformation
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

	local activeEntry = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo()
	local categoryID = activeEntry and C_LFGList.GetActivityInfoTable(activeEntry.activityID).categoryID or LFGListFrame.SearchPanel.categoryID

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

					dungeonRowFrame.Primary:SetText(wticc(primaryDungeonLevel[rowIndex] .. strrep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or primaryDungeonChests[rowIndex]),
					primaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or primaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))

					dungeonRowFrame.Secondary:SetText(wticc(secondaryDungeonLevel[rowIndex] .. strrep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or secondaryDungeonChests[rowIndex]),
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

						if(categoryID == 3) then
							if(primaryIndicator:GetText() ~= nil and secondaryIndicator:GetText() == nil) then
								secondaryIndicator:SetText(basicProgressString)

							end

							if(primaryIndicator:GetText() == nil) then
								primaryIndicator:SetText(basicProgressString)

							end
						end

						local instanceID = C_EncounterJournal.GetInstanceForGameMap(sortedProgress.progress.raid.mapId)
						currentTierFrame = raidPanel[raidIndex == 1 and "currentTier" or "lastTier"]

						currentTierFrame.Icon:SetTexture(miog.MAP_INFO[sortedProgress.progress.raid.mapId].icon)
						currentTierFrame.Icon:SetScript("OnMouseDown", function()
							--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
							EncounterJournal_OpenJournal(miog.F.CURRENT_RAID_DIFFICULTY, instanceID, nil, nil, nil, nil)

						end)

						currentTierFrame.Name:SetText(sortedProgress.progress.raid.shortName .. ":")

						higherDifficultyNumber = sortedProgress.progress.difficulty

						currentTierFrame.Progress:SetText(panelProgressString)

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

										currentBoss.Border:SetColorTexture(miog.ITEM_QUALITY_COLORS[higherDifficultyNumber+1].color:GetRGBA())

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

							if(categoryID == 3) then
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

					if(categoryID == 3) then
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

			if(categoryID == 3) then
				primaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))
				secondaryIndicator:SetText(wticc("0/0", miog.DIFFICULTY[-1].color))

			end

		end

	else -- If RaiderIO is not installed
		mythicPlusPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))

		raidPanel.rows[1].FontString:SetText(wticc("NO RAIDER.IO DATA", miog.CLRSCC["red"]))
	end


	if(primaryIndicator:GetText() == nil) then
		primaryIndicator:SetText(wticc(categoryID == 3 and "0/0" or 0, miog.DIFFICULTY[-1].color))

	end

	if(secondaryIndicator:GetText() == nil) then
		secondaryIndicator:SetText(wticc(categoryID == 3 and "0/0" or 0, miog.DIFFICULTY[-1].color))

	end

	generalInfoPanel.rows[9].FontString:SetText(string.upper(miog.F.CURRENT_REGION) .. "-" .. (realm or GetRealmName() or ""))
end

miog.gatherRaiderIODisplayData = gatherRaiderIODisplayData



local function insertLFGInfo(activityID)
	local entryInfo = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo() or miog.F.ACTIVE_ENTRY_INFO
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID or entryInfo.activityID)

	miog.applicationViewer.ButtonPanel.sortByCategoryButtons.secondary:Enable()

	if(activityInfo.categoryID == 2) then --Dungeons
		miog.F.CURRENT_DUNGEON_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DUNGEON_DIFFICULTY
		miog.applicationViewer.CreationSettings.Affixes:Show()

	elseif(activityInfo.categoryID == 3) then --Raids
		miog.F.CURRENT_RAID_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_RAID_DIFFICULTY
		miog.applicationViewer.CreationSettings.Affixes:Hide()
	end
	
	miog.applicationViewer.InfoPanel.Background:SetTexture(miog.ACTIVITY_INFO[entryInfo.activityID].horizontal or miog.ACTIVITY_BACKGROUNDS[activityInfo.categoryID])

	miog.applicationViewer.TitleBar.FontString:SetText(entryInfo.name)
	miog.applicationViewer.InfoPanel.Activity:SetText(activityInfo.fullName)

	miog.applicationViewer.CreationSettings.PrivateGroup.active = entryInfo.privateGroup
	miog.applicationViewer.CreationSettings.PrivateGroup:SetTexture(miog.C.STANDARD_FILE_PATH .. (entryInfo.privateGroup and "/infoIcons/questionMark_Yellow.png" or "/infoIcons/questionMark_Grey.png"))

	if(entryInfo.playstyle) then
		local playStyleString = (activityInfo.isMythicPlusActivity and miog.PLAYSTYLE_STRINGS["mPlus"..entryInfo.playstyle]) or
		(activityInfo.isMythicActivity and miog.PLAYSTYLE_STRINGS["mZero"..entryInfo.playstyle]) or
		(activityInfo.isCurrentRaidActivity and miog.PLAYSTYLE_STRINGS["raid"..entryInfo.playstyle]) or
		((activityInfo.isRatedPvpActivity or activityInfo.isPvpActivity) and miog.PLAYSTYLE_STRINGS["pvp"..entryInfo.playstyle])

		miog.applicationViewer.CreationSettings.Playstyle.tooltipText = playStyleString

	else
		miog.applicationViewer.CreationSettings.Playstyle.tooltipText = ""

	end

	if(entryInfo.requiredDungeonScore and activityInfo.categoryID == 2 or entryInfo.requiredPvpRating and activityInfo.categoryID == (4 or 7 or 8 or 9)) then
		miog.applicationViewer.CreationSettings.Rating.tooltipText = "Required rating: " .. entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating
		miog.applicationViewer.CreationSettings.Rating.FontString:SetText(entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating)

		miog.applicationViewer.CreationSettings.Rating.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. (entryInfo.requiredDungeonScore and "/infoIcons/skull.png" or entryInfo.requiredPvpRating and "/infoIcons/spear.png"))

	else
		miog.applicationViewer.CreationSettings.Rating.FontString:SetText("----")
		miog.applicationViewer.CreationSettings.Rating.tooltipText = ""

	end

	if(entryInfo.requiredItemLevel > 0) then
		miog.applicationViewer.CreationSettings.ItemLevel.FontString:SetText(entryInfo.requiredItemLevel)
		miog.applicationViewer.CreationSettings.ItemLevel.tooltipText = "Required itemlevel: " .. entryInfo.requiredItemLevel

	else
		miog.applicationViewer.CreationSettings.ItemLevel.FontString:SetText("---")
		miog.applicationViewer.CreationSettings.ItemLevel.tooltipText = ""

	end

	if(entryInfo.voiceChat ~= "") then
		LFGListFrame.EntryCreation.VoiceChat.CheckButton:SetChecked(true)

	end

	if(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked()) then
		miog.applicationViewer.CreationSettings.VoiceChat.tooltipText = entryInfo.voiceChat
		miog.applicationViewer.CreationSettings.VoiceChat:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOn.png")
		
	else
		miog.applicationViewer.CreationSettings.VoiceChat.tooltipText = ""
		miog.applicationViewer.CreationSettings.VoiceChat:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOff.png")

	end

	if(entryInfo.isCrossFactionListing == true) then
		miog.applicationViewer.TitleBar.Faction:SetTexture(2437241)

	else
		local playerFaction = UnitFactionGroup("player")
		miog.applicationViewer.TitleBar.Faction:SetTexture(playerFaction == "Alliance" and 2173919 or playerFaction == "Horde" and 2173920)

	end

	if(entryInfo.comment ~= "") then
		miog.applicationViewer.InfoPanel.Description.Container.FontString:SetText("Description: " .. entryInfo.comment)
		miog.applicationViewer.InfoPanel.Description.Container:SetHeight(miog.applicationViewer.InfoPanel.Description.Container.FontString:GetStringHeight())
		
	else
		miog.applicationViewer.InfoPanel.Description.Container.FontString:SetText("")

	end
end

miog.insertLFGInfo = insertLFGInfo

local function ResolveCategoryFilters(categoryID, filters)
	-- Dungeons ONLY display recommended groups.
	if categoryID == GROUP_FINDER_CATEGORY_ID_DUNGEONS then
		return bit.band(bit.bnot(Enum.LFGListFilter.NotRecommended), bit.bor(filters, Enum.LFGListFilter.Recommended));
	end

	return filters;
end

miog.ResolveCategoryFilters = ResolveCategoryFilters