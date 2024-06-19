local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.ONCE = true

miog.listGroup = function() -- Effectively replaces LFGListEntryCreation_ListGroupInternal
	local frame = miog.EntryCreation

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
			C_LFGList.UpdateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);


			-- DOESNT WORK BECAUSE OF PROTECTION XD
			--C_LFGList.RemoveListing();
			--C_LFGList.CreateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
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

local function calculateWeightedScore(difficulty, kills, bossCount, current, ordinal)
	return (miog.WEIGHTS_TABLE[current and 1 or 2] * difficulty + miog.WEIGHTS_TABLE[current and 2 or 3] * kills / bossCount) + (miog.WEIGHTS_TABLE[current and 1 or 2] * difficulty + miog.WEIGHTS_TABLE[current and 2 or 3] * kills / bossCount)

end

local function getRaidSortData(playerName)
	local profile

	if(miog.F.IS_RAIDERIO_LOADED) then
		profile = RaiderIO.GetProfile(playerName)

	end

	--[[

		raidProgress table
			1 table
				current bool
				isMainProgress bool

				raid table
					bossCount number
					id number
					mapID number
					ordinal number
					name string
					shortName string

				progress table
					1
						cleared bool
						obsolete bool
						difficulty number
						kills number
						progress table
							1
								killed bool
								count number
								difficulty number
								index number

				



	]]

	local currentData = {}
	local nonCurrentData = {}
	local mainData = {}
	local orderedData = {}

	if(profile and profile.success == true) then
		if(profile.raidProfile) then

			for k, d in ipairs(profile.raidProfile.raidProgress) do
				if(d.isMainProgress == false) then
					if(d.current == true) then
						local highestDifficulty = 1

						for x, y in ipairs(d.progress) do
							local mapID
							local awakened = false

							if(string.find(d.raid.mapId, 10000)) then
								mapID = tonumber(strsub(d.raid.mapId, strlen(d.raid.mapId) - 3))
								awakened = d.current
							else
								mapID = d.raid.mapId

							end

							if(highestDifficulty < y.difficulty) then
								highestDifficulty = y.difficulty
							end

							currentData[#currentData+1] = {
								ordinal = d.raid.ordinal,
								raidProgressIndex = k,
								mapId = mapID,
								difficulty = y.difficulty,
								current = d.current,
								shortName = d.raid.shortName,
								progress = y.kills,
								bossCount = d.raid.bossCount,
								parsedString = y.kills .. "/" .. d.raid.bossCount,
								weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current, d.raid.ordinal)
							}
							
						end
					elseif(d.current == false) then

						local highestDifficulty = 1

						for x, y in ipairs(d.progress) do
							local mapID
							local awakened = false

							if(string.find(d.raid.mapId, 10000)) then
								mapID = tonumber(strsub(d.raid.mapId, strlen(d.raid.mapId) - 3))
								awakened = true

							else
								mapID = d.raid.mapId

							end

							if(highestDifficulty < y.difficulty) then
								highestDifficulty = y.difficulty
							end

							nonCurrentData[#nonCurrentData+1] = {
								ordinal = d.raid.ordinal,
								raidProgressIndex = k,
								mapId = mapID,
								difficulty = y.difficulty,
								current = d.current,
								shortName = d.raid.shortName,
								progress = y.kills,
								bossCount = d.raid.bossCount,
								parsedString = y.kills .. "/" .. d.raid.bossCount,
								weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current, d.raid.ordinal)
							}
						end
					end
				else

					for x, y in ipairs(d.progress) do
						local mapID
						local awakened = false

						if(string.find(d.raid.mapId, 10000)) then
							mapID = tonumber(strsub(d.raid.mapId, strlen(d.raid.mapId) - 3))
							awakened = true

						else
							mapID = d.raid.mapId

						end

						mainData[#mainData+1] = {
							ordinal = d.raid.ordinal,
							raidProgressIndex = k,
							mapId = mapID,
							difficulty = y.difficulty,
							current = d.current,
							shortName = d.raid.shortName,
							progress = y.kills,
							bossCount = d.raid.bossCount,
							parsedString = y.kills .. "/" .. d.raid.bossCount,
							weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current, d.raid.ordinal)
						}
					end
				end
			end
		end
	end


	table.sort(currentData, function(k1, k2)
		return k1.difficulty > k2.difficulty
	end)

	table.sort(nonCurrentData, function(k1, k2)
		return k1.difficulty > k2.difficulty
	end)

	table.sort(mainData, function(k1, k2)
		return k1.difficulty > k2.difficulty
	end)

	if(currentData) then
		for k, v in ipairs(currentData) do
			orderedData[#orderedData+1] = v
		end
	end

	if(nonCurrentData) then
		for k, v in ipairs(nonCurrentData) do
			orderedData[#orderedData+1] = v
		end
	end

	if(#orderedData < 3) then
		for i = #orderedData + 1, 3, 1 do
			orderedData[i] = {
				difficulty = -1,
				progress = 0,
				bossCount = 0,
				parsedString = "0/0",
				weight = 0
			}
		end
	end


	for i = 1, 3, 1 do
		if(currentData[i] == nil) then
			currentData[i] = {
				difficulty = -1,
				progress = 0,
				bossCount = 0,
				parsedString = "0/0",
				weight = 0
			}
		end
	end

	for i = 1, 3, 1 do
		if(nonCurrentData[i] == nil) then
			nonCurrentData[i] = {
				difficulty = -1,
				progress = 0,
				bossCount = 0,
				parsedString = "0/0",
				weight = 0
			}
		end
	end
	
	for i = 1, 3, 1 do
		if(mainData[i] == nil) then
			mainData[i] = {
				difficulty = -1,
				progress = 0,
				bossCount = 0,
				parsedString = "0/0",
				weight = 0
			}
		end
	end

	return currentData, nonCurrentData, orderedData
end

miog.getRaidSortData = getRaidSortData


miog.hideSidePanel = function(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	self:GetParent():Hide()
	self:GetParent():GetParent().ButtonPanel:Show()

	MIOG_SavedSettings.activeSidePanel.value = ""
end

-- type == unitID or unitName
-- value == (unitID) player, party3, raid29 or (unitName) Rhany, Merkuz, Solomeio-Ravencrest
local function createFullNameFrom(type, value)
	local name

	if(type == "unitID") then
		name = GetUnitName(value, true)

		if(value == "player") then
			name = name .. "-" .. GetNormalizedRealmName()
		end
	elseif(type == "unitName") then
		local nameTable = miog.simpleSplit(value, "-")

		if(not nameTable[2]) then
			nameTable[2] = GetNormalizedRealmName()
	
			if(nameTable[2]) then
				name = nameTable[1] .. "-" .. nameTable[2]
	
			end
	
		else
			name = value
			
		end
	end

	return name
end

miog.createFullNameFrom = createFullNameFrom

local function printOnce(string)
	if(miog.ONCE) then
		miog.ONCE = false

		print(string)

	end
end

miog.getGroupLeader = function()
	local numOfMembers = GetNumGroupMembers()
	miog.F.LFG_STATE = miog.checkLFGState()

	for groupIndex = 1, numOfMembers, 1 do
		local unitID = ((IsInRaid() or (IsInGroup() and (numOfMembers ~= 1 and groupIndex ~= numOfMembers))) and miog.F.LFG_STATE..groupIndex) or "player"

		if(UnitIsGroupLeader(unitID)) then
			return UnitName(unitID), (UnitGUID(unitID) == UnitGUID("player") and "player" or unitID)

		end
	end
end


hooksecurefunc("LFGListSearchPanel_DoSearch", function(self)
	LFGListFrame.SearchPanel.SearchBox:ClearAllPoints()
	LFGListFrame.SearchPanel.SearchBox:SetParent(miog.SearchPanel)
	LFGListFrame.SearchPanel.FilterButton:Hide()

	if(not miog.F.LITE_MODE) then
		LFGListFrame.SearchPanel.SearchBox:SetSize(miog.SearchPanel.SearchBoxBase:GetSize())

	else
		LFGListFrame.SearchPanel.SearchBox:SetWidth(miog.SearchPanel.standardSearchBoxWidth - 100)
	
	end

	LFGListFrame.SearchPanel.SearchBox:SetPoint(miog.SearchPanel.SearchBoxBase:GetPoint())
	LFGListFrame.SearchPanel.SearchBox:SetFrameStrata("DIALOG")
	LFGListFrame.SearchPanel.SearchBox:SetFrameLevel(9999)
end)

local function createDetailedInformationPanel(poolFrame, listFrame)
	if (listFrame == nil) then
		listFrame = poolFrame

	end

	local detailedInformationPanel = listFrame.DetailedInformationPanel
	detailedInformationPanel:SetWidth(listFrame.fixedWidth)
	--detailedInformationPanel:SetPoint("TOPLEFT", listFrame.BasicInformation or listFrame.Row, "BOTTOMLEFT")
	--detailedInformationPanel:SetPoint("TOPRIGHT", listFrame.BasicInformation or listFrame.CategoryInformation, "BOTTOMRIGHT")
	
	detailedInformationPanel:SetShown((listFrame.CategoryInformation or listFrame.BasicInformation).ExpandFrame:GetActiveState() > 0 and true or false)
	listFrame.DetailedInformationPanel = detailedInformationPanel

	local activeEntry = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo()
	local categoryID = activeEntry and C_LFGList.GetActivityInfoTable(activeEntry.activityID).categoryID or LFGListFrame.SearchPanel.categoryID

	local panelContainer = detailedInformationPanel.PanelContainer
	panelContainer.ForegroundRows:SetFrameStrata("HIGH")

	local raidPanel = panelContainer.ForegroundRows.Raid
	raidPanel:SetShown(categoryID == 3 and true)

	local mythicPlusPanel = panelContainer.ForegroundRows.MythicPlus
	mythicPlusPanel:SetShown(not raidPanel:IsShown())
	mythicPlusPanel.dungeonFrames = mythicPlusPanel.dungeonFrames or {}

	local generalInfoPanel = panelContainer.ForegroundRows.GeneralInfo

	generalInfoPanel.Right["1"].FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)
	generalInfoPanel.Right["1"].FontString:SetWordWrap(true)
	generalInfoPanel.Right["1"].FontString:SetNonSpaceWrap(true)
	generalInfoPanel.Right["1"].FontString:SetScript("OnEnter", function(self)
		if(self:GetText() ~= nil and self:IsTruncated()) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self:GetText(), nil, nil, nil, nil, true)
			GameTooltip:Show()
		end
	end)

	generalInfoPanel.Right["1"].FontString:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)
end

miog.createDetailedInformationPanel = createDetailedInformationPanel

local function gatherRaiderIODisplayData(playerName, realm, poolFrame, memberFrame)
	if (memberFrame == nil) then
		memberFrame = poolFrame

	end

	local profile, mythicKeystoneProfile, raidProfile
	local detailedInformationPanel = memberFrame.DetailedInformationPanel
	local mythicPlusPanel = detailedInformationPanel.PanelContainer.ForegroundRows.MythicPlus
	local raidPanel = detailedInformationPanel.PanelContainer.ForegroundRows.Raid
	local generalInfoPanel = detailedInformationPanel.PanelContainer.ForegroundRows.GeneralInfo

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

					local dungeonRowFrame = mythicPlusPanel["DungeonRow" .. i]

					--miog.createFrameBorder(dungeonRowFrame, 1)

					local rowIndex = dungeonEntry.dungeon.index
					local texture = miog.MAP_INFO[dungeonEntry.dungeon.instance_map_id].icon

					dungeonRowFrame.Icon:SetTexture(texture)
					dungeonRowFrame.Icon:SetScript("OnMouseDown", function()
						local instanceID = C_EncounterJournal.GetInstanceForGameMap(dungeonEntry.dungeon.instance_map_id)

						--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
						EncounterJournal_OpenJournal(EJ_GetDifficulty(), instanceID, nil, nil, nil, nil)

					end)

					dungeonRowFrame.Name:SetText(dungeonEntry.dungeon.shortName .. ":")

					dungeonRowFrame.Primary:SetText(wticc(primaryDungeonLevel[rowIndex] .. " " .. strrep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or primaryDungeonChests[rowIndex]),
					primaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or primaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))

					dungeonRowFrame.Secondary:SetText(wticc(secondaryDungeonLevel[rowIndex] .. " " .. strrep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or secondaryDungeonChests[rowIndex]),
					secondaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or secondaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))
				end
			end

			local previousScoreString = ""

			local currentSeason = miog.MPLUS_SEASONS[miog.F.CURRENT_SEASON] or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason()]
			local previousSeason = miog.MPLUS_SEASONS[miog.F.PREVIOUS_SEASON] or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]

			if(mythicKeystoneProfile.previousScore and mythicKeystoneProfile.previousScore > 0) then
				previousScoreString = previousSeason .. ": " .. wticc(mythicKeystoneProfile.previousScore, miog.createCustomColorForRating(mythicKeystoneProfile.previousScore):GenerateHexColor())

			end

			mythicPlusPanel.CategoryRow1.FontString:SetText(previousScoreString)

			local mainScoreString = ""

			if(mythicKeystoneProfile.mainCurrentScore) then
				if((mythicKeystoneProfile.mainCurrentScore > 0) == false and (mythicKeystoneProfile.mainPreviousScore > 0) == false) then
					mainScoreString = wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex)

				else
					if(mythicKeystoneProfile.mainCurrentScore > 0 and mythicKeystoneProfile.mainPreviousScore > 0) then
						mainScoreString = "Main " .. currentSeason .. ": " .. wticc(mythicKeystoneProfile.mainCurrentScore, miog.createCustomColorForRating(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor()) ..
						" " .. previousSeason .. ": " .. wticc(mythicKeystoneProfile.mainPreviousScore, miog.createCustomColorForRating(mythicKeystoneProfile.mainPreviousScore):GenerateHexColor())

					elseif(mythicKeystoneProfile.mainCurrentScore > 0) then
						mainScoreString = "Main " .. currentSeason .. ": " .. wticc(mythicKeystoneProfile.mainCurrentScore, miog.createCustomColorForRating(mythicKeystoneProfile.mainCurrentScore):GenerateHexColor())

					elseif(mythicKeystoneProfile.mainPreviousScore > 0) then
						mainScoreString = "Main " .. previousSeason .. ": " .. wticc(mythicKeystoneProfile.mainPreviousScore, miog.createCustomColorForRating(mythicKeystoneProfile.mainPreviousScore):GenerateHexColor())

					end

				end

				mainScoreString = wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex)
			
			end

			mythicPlusPanel.CategoryRow2.FontString:SetText(mainScoreString)

			generalInfoPanel.Right["5"].FontString:SetText(
				wticc(mythicKeystoneProfile.keystoneFivePlus or "0", miog.ITEM_QUALITY_COLORS[2].pureHex) .. " - " ..
				wticc(mythicKeystoneProfile.keystoneTenPlus or "0", miog.ITEM_QUALITY_COLORS[3].pureHex) .. " - " ..
				wticc(mythicKeystoneProfile.keystoneFifteenPlus or "0", miog.ITEM_QUALITY_COLORS[4].pureHex) .. " - " ..
				wticc(mythicKeystoneProfile.keystoneTwentyPlus or "0", miog.ITEM_QUALITY_COLORS[5].pureHex)
			)

		else
			mythicPlusPanel.CategoryRow1.FontString:SetText(wticc("NO M+ DATA", miog.CLRSCC["red"]))

		end

		if(raidProfile) then
			local currentTierFrame
			local mainProgressText = ""

			local currentData, nonCurrentData, orderedData = getRaidSortData(playerName .. (realm and "-" .. realm or ""))

			if(mainProgressText ~= "") then
				raidPanel.CategoryRow2.FontString:SetText(wticc("Main: " .. mainProgressText, miog.ITEM_QUALITY_COLORS[6].pureHex))

			else
				raidPanel.CategoryRow2.FontString:SetText(wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex))

			end

			local slotsFilled = {}

			for n = 1, 2, 1 do
				local raidData = n == 1 and currentData or nonCurrentData

				if(raidData) then
					for a, b in ipairs(raidData) do
						local slot = b.ordinal == 4 and 1 or b.ordinal == 5 and 2 or b.ordinal == 6 and 3 or b.ordinal

						if(slot and slotsFilled[slot] == nil) then
							slotsFilled[slot] = true

							local panelProgressString = ""
							local raidProgress = profile.raidProfile.raidProgress[b.raidProgressIndex]
							local mapId

							if(string.find(raidProgress.raid.mapId, 10000)) then
								mapId = tonumber(strsub(raidProgress.raid.mapId, strlen(raidProgress.raid.mapId) - 3))
							else
								mapId = raidProgress.raid.mapId

							end

							--detailedInformationPanel:GetParent().BasicInformation.Title:SetText(math.floor(orderedData[1].weight + 0.5) .. "/" .. math.floor(orderedData[2].weight + 0.5))

							local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapId)

							currentTierFrame = raidPanel[slot == 1 and "HighestTier" or slot == 2 and "MiddleTier" or slot == 3 and "LowestTier"]
							currentTierFrame:Show()
							currentTierFrame.Icon:SetTexture(miog.MAP_INFO[mapId].icon)
							currentTierFrame.Icon:SetScript("OnMouseDown", function()
								local difficulty = b.difficulty == 1 and 14 or b.difficulty == 2 and 15 or 16
								--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
								EncounterJournal_OpenJournal(difficulty, instanceID, nil, nil, nil, nil)

							end)

							currentTierFrame.Name:SetText(raidProgress.raid.shortName .. ":")

							local setLowestBorder = {}

							for x, y in ipairs(raidProgress.progress) do
								if(y.difficulty == b.difficulty and y.obsolete == false) then
									panelProgressString = wticc(miog.DIFFICULTY[y.difficulty].shortName .. ":" .. y.kills .. "/" .. raidProgress.raid.bossCount, miog.DIFFICULTY[y.difficulty].color) .. " " .. panelProgressString

									for i = 1, 10, 1 do
										local bossInfo = y.progress[i]
										local currentBoss = currentTierFrame.BossFrames[i < 6 and "UpperRow" or "LowerRow"][tostring(i)]

										if(bossInfo) then
											currentBoss.Index:SetText(i)
											
											if(bossInfo.killed) then
												currentBoss.Border:SetColorTexture(miog.DIFFICULTY[bossInfo.difficulty].miogColors:GetRGBA())
												currentBoss.Icon:SetDesaturated(false)

											end

											if(not setLowestBorder[i]) then
												if(not bossInfo.killed) then
													currentBoss.Border:SetColorTexture(0,0,0,0)
													currentBoss.Icon:SetDesaturated(not bossInfo.killed)

												end

												setLowestBorder[i] = true
											end

											currentBoss.Icon:SetTexture(miog.MAP_INFO[mapId][i].icon)
											currentBoss.Icon:SetScript("OnMouseDown", function()
												local difficulty = bossInfo.difficulty == 1 and 14 or bossInfo.difficulty == 2 and 15 or 16
												EncounterJournal_OpenJournal(difficulty, instanceID, select(3, EJ_GetEncounterInfoByIndex(i, instanceID)), nil, nil, nil)
											end)

											currentBoss:Show()

										else
											currentBoss:Hide()

										end
									end
								end
							end
							
							currentTierFrame.Progress:SetText(panelProgressString)
						end
					end
				end
			end
		else --NO RAIDING DATA
			if(categoryID == 3) then
				--primaryIndicator:SetText(wticc("0/0", miog.CLRSCC.red))
				--secondaryIndicator:SetText(wticc("0/0", miog.CLRSCC.red))
			end
		end

	else -- If RaiderIO is not installed or no profile available
		if(categoryID == 3) then
			--primaryIndicator:SetText(wticc("0/0", miog.CLRSCC.red))
			--secondaryIndicator:SetText(wticc("0/0", miog.CLRSCC.red))
		end
	end

	generalInfoPanel.Right["6"].FontString:SetText(string.upper(miog.F.CURRENT_REGION) .. "-" .. (realm or GetRealmName() or ""))
end

miog.gatherRaiderIODisplayData = gatherRaiderIODisplayData



local function insertLFGInfo(activityID)
	local entryInfo = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo() or miog.F.ACTIVE_ENTRY_INFO
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID or entryInfo.activityID)

	miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons.secondary:Enable()

	if(activityInfo.categoryID == 2) then --Dungeons
		miog.F.CURRENT_DUNGEON_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DUNGEON_DIFFICULTY
		miog.ApplicationViewer.CreationSettings.Affixes:Show()

	elseif(activityInfo.categoryID == 3) then --Raids
		miog.F.CURRENT_RAID_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_RAID_DIFFICULTY
		miog.ApplicationViewer.CreationSettings.Affixes:Hide()
	end

	miog.ApplicationViewer.InfoPanel.Background:SetTexture(miog.ACTIVITY_INFO[entryInfo.activityID].horizontal or miog.ACTIVITY_BACKGROUNDS[activityInfo.categoryID])

	miog.ApplicationViewer.TitleBar.FontString:SetText(entryInfo.name)
	miog.ApplicationViewer.InfoPanel.Activity:SetText(activityInfo.fullName)

	miog.ApplicationViewer.CreationSettings.PrivateGroup.active = entryInfo.privateGroup
	miog.ApplicationViewer.CreationSettings.PrivateGroup:SetTexture(miog.C.STANDARD_FILE_PATH .. (entryInfo.privateGroup and "/infoIcons/questionMark_Yellow.png" or "/infoIcons/questionMark_Grey.png"))

	if(entryInfo.playstyle) then
		local playStyleString = (activityInfo.isMythicPlusActivity and miog.PLAYSTYLE_STRINGS["mPlus"..entryInfo.playstyle]) or
		(activityInfo.isMythicActivity and miog.PLAYSTYLE_STRINGS["mZero"..entryInfo.playstyle]) or
		(activityInfo.isCurrentRaidActivity and miog.PLAYSTYLE_STRINGS["raid"..entryInfo.playstyle]) or
		((activityInfo.isRatedPvpActivity or activityInfo.isPvpActivity) and miog.PLAYSTYLE_STRINGS["pvp"..entryInfo.playstyle])

		miog.ApplicationViewer.CreationSettings.Playstyle.tooltipText = playStyleString

	else
		miog.ApplicationViewer.CreationSettings.Playstyle.tooltipText = ""

	end

	if(entryInfo.requiredDungeonScore and activityInfo.categoryID == 2 or entryInfo.requiredPvpRating and activityInfo.categoryID == (4 or 7 or 8 or 9)) then
		miog.ApplicationViewer.CreationSettings.Rating.tooltipText = "Required rating: " .. entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating
		miog.ApplicationViewer.CreationSettings.Rating.FontString:SetText(entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating)

		miog.ApplicationViewer.CreationSettings.Rating.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. (entryInfo.requiredDungeonScore and "/infoIcons/skull.png" or entryInfo.requiredPvpRating and "/infoIcons/spear.png"))

	else
		miog.ApplicationViewer.CreationSettings.Rating.FontString:SetText("----")
		miog.ApplicationViewer.CreationSettings.Rating.tooltipText = ""

	end

	if(entryInfo.requiredItemLevel > 0) then
		miog.ApplicationViewer.CreationSettings.ItemLevel.FontString:SetText(entryInfo.requiredItemLevel)
		miog.ApplicationViewer.CreationSettings.ItemLevel.tooltipText = "Required itemlevel: " .. entryInfo.requiredItemLevel

	else
		miog.ApplicationViewer.CreationSettings.ItemLevel.FontString:SetText("---")
		miog.ApplicationViewer.CreationSettings.ItemLevel.tooltipText = ""

	end

	if(entryInfo.voiceChat ~= "") then
		LFGListFrame.EntryCreation.VoiceChat.CheckButton:SetChecked(true)

	end

	if(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked()) then
		miog.ApplicationViewer.CreationSettings.VoiceChat.tooltipText = entryInfo.voiceChat
		miog.ApplicationViewer.CreationSettings.VoiceChat:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOn.png")

	else
		miog.ApplicationViewer.CreationSettings.VoiceChat.tooltipText = ""
		miog.ApplicationViewer.CreationSettings.VoiceChat:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOff.png")

	end

	if(entryInfo.isCrossFactionListing == true) then
		miog.ApplicationViewer.TitleBar.Faction:SetTexture(2437241)

	else
		local playerFaction = UnitFactionGroup("player")
		miog.ApplicationViewer.TitleBar.Faction:SetTexture(playerFaction == "Alliance" and 2173919 or playerFaction == "Horde" and 2173920)

	end

	if(entryInfo.comment ~= "") then
		miog.ApplicationViewer.InfoPanel.Description.Container.FontString:SetText("Description: " .. entryInfo.comment)
		miog.ApplicationViewer.InfoPanel.Description.Container:SetHeight(miog.ApplicationViewer.InfoPanel.Description.Container.FontString:GetStringHeight())

	else
		miog.ApplicationViewer.InfoPanel.Description.Container.FontString:SetText("")

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