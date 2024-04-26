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
			for k, d in ipairs(profile.raidProfile.raidProgress) do
				if(d.isMainProgress == false) then
					local bossCount = d.raid.bossCount

					for x, y in ipairs(d.progress) do

						local kills = y.kills or 0

						local tempData = {
							ordinal = d.raid.ordinal,
							raidProgressIndex = k,
							mapId = d.raid.mapId,
							current = d.current,
							shortName = d.raid.shortName,
							difficulty = y.difficulty,
							progress = kills,
							bossCount = bossCount,
							parsedString = kills .. "/" .. bossCount,
							weight = kills / bossCount + (miog.WEIGHTS_TABLE[d.raid.ordinal] * y.difficulty)
						}

						if(d.current) then
							if(#d.progress == 2 and x == 1) then
								raidData[2] = tempData

							else
								raidData[1] = tempData

							end
						else
							if(raidData[1] == nil) then
								if(#d.progress == 2 and x == 1) then
									raidData[2] = tempData

								else
									raidData[1] = tempData

								end

							elseif(raidData[2] == nil) then
								if(#d.progress == 1 or #d.progress == 2 and x == 2) then
									raidData[2] = tempData

								end

							end

						end
					end
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

miog.ONCE = true

local function printOnce(string)
	if(miog.ONCE) then
		miog.ONCE = false

		print(string)

	end
end

local function createDetailedInformationPanel(poolFrame, listFrame)
	if (listFrame == nil) then
		listFrame = poolFrame

	end

	local detailedInformationPanel = listFrame.DetailedInformationPanel
	detailedInformationPanel:SetPoint("TOPLEFT", listFrame.BasicInformationPanel or listFrame.CategoryInformation, "BOTTOMLEFT")
	detailedInformationPanel:SetPoint("TOPRIGHT", listFrame.BasicInformationPanel or listFrame.CategoryInformation, "BOTTOMRIGHT")
	detailedInformationPanel:SetShown((listFrame.BasicInformationPanel or listFrame.CategoryInformation).ExpandFrame:GetActiveState() > 0 and true or false)
	listFrame.DetailedInformationPanel = detailedInformationPanel

	local activeEntry = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo()
	local categoryID = activeEntry and C_LFGList.GetActivityInfoTable(activeEntry.activityID).categoryID or LFGListFrame.SearchPanel.categoryID

	local panelContainer = detailedInformationPanel.PanelContainer

	local raidPanel = panelContainer.Raid
	raidPanel:SetShown(categoryID == 3 and true)
	raidPanel.rows = raidPanel.rows or {}

	local mythicPlusPanel = panelContainer.MythicPlus
	mythicPlusPanel:SetShown(not raidPanel:IsShown())
	mythicPlusPanel.rows = mythicPlusPanel.rows or {}
	mythicPlusPanel.dungeonFrames = mythicPlusPanel.dungeonFrames or {}

	local generalInfoPanel = panelContainer.GeneralInfo
	generalInfoPanel.rows = generalInfoPanel.rows or {}

	panelContainer.rows = {}

	for rowIndex = 1, 9, 1 do
		local remainder = math.fmod(rowIndex, 2)

		local textRowFrame =  panelContainer[tostring(rowIndex)]

		if(remainder == 1) then
			textRowFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())

		else
			textRowFrame.Background:SetColorTexture(CreateColorFromHexString(miog.C.CARD_COLOR):GetRGBA())

		end
	end

	generalInfoPanel.Right["1"].FontString:SetSpacing(miog.C.APPLICANT_MEMBER_HEIGHT - miog.C.TEXT_ROW_FONT_SIZE)
	generalInfoPanel.Right["1"].FontString:SetWordWrap(true)
	generalInfoPanel.Right["1"].FontString:SetNonSpaceWrap(true)
	generalInfoPanel.Right["1"].FontString:SetScript("OnEnter", function(self)
		if(self:GetText() ~= nil and self:IsTruncated()) then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:SetText(self:GetText(), nil, nil, nil, nil, true)
			GameTooltip:Show()
		end
	end)

	generalInfoPanel.Right["1"].FontString:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)

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
	local mythicPlusPanel = detailedInformationPanel.PanelContainer.MythicPlus
	local raidPanel = detailedInformationPanel.PanelContainer.Raid
	local generalInfoPanel = detailedInformationPanel.PanelContainer.GeneralInfo

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

					local rowIndex = dungeonEntry.dungeon.index
					local texture = miog.MAP_INFO[dungeonEntry.dungeon.instance_map_id].icon

					dungeonRowFrame.Icon:SetTexture(texture)
					dungeonRowFrame.Icon:SetScript("OnMouseDown", function()
						local instanceID = C_EncounterJournal.GetInstanceForGameMap(dungeonEntry.dungeon.instance_map_id)

						--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
						EncounterJournal_OpenJournal(EJ_GetDifficulty(), instanceID, nil, nil, nil, nil)

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

			mythicPlusPanel.CategoryRow1.FontString:SetText(previousScoreString)

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
			local raidData = {}
			local currentTierFrame
			local mainProgressText = ""

			for k, v in ipairs(profile.raidProfile.raidProgress) do
				local bossCount = v.raid.bossCount
				local highestIndex = v.progress[2] and 2 or 1
				local kills = v.progress[highestIndex].kills or 0

				if(v.isMainProgress == false) then
					raidData[#raidData+1] = {
						ordinal = v.raid.ordinal,
						raidProgressIndex = k,
						mapId = v.raid.mapId,
						current = v.current,
						shortName = v.raid.shortName,
						difficulty = v.progress[highestIndex].difficulty,
						progress = kills,
						bossCount = bossCount,
						parsedString = kills .. "/" .. bossCount,
						weight = kills / bossCount + (miog.WEIGHTS_TABLE[v.raid.ordinal] * v.progress[highestIndex].difficulty)
					}
				else
					mainProgressText = mainProgressText .. wticc(miog.DIFFICULTY[v.progress[highestIndex].difficulty].shortName .. ":" .. kills .. "/" .. bossCount, miog.DIFFICULTY[v.progress[highestIndex].difficulty].color) .. " "

				end
			end

			if(mainProgressText ~= "") then
				raidPanel.CategoryRow2.FontString:SetText(wticc("Main: " .. mainProgressText, miog.ITEM_QUALITY_COLORS[6].pureHex))

			else
				raidPanel.CategoryRow2.FontString:SetText(wticc("Main Char", miog.ITEM_QUALITY_COLORS[7].pureHex))

			end

			for k, v in ipairs(raidData) do
				local panelProgressString = ""
				local raidProgress = profile.raidProfile.raidProgress[v.raidProgressIndex]
				local instanceID = C_EncounterJournal.GetInstanceForGameMap(v.mapId)

				currentTierFrame = raidPanel[k == 1 and "HighestTier" or k == 2 and "MiddleTier" or "LowestTier"]
				currentTierFrame:Show()
				currentTierFrame.Icon:SetTexture(miog.MAP_INFO[v.mapId].icon)
				currentTierFrame.Icon:SetScript("OnMouseDown", function()
					local difficulty = v.difficulty == 1 and 14 or v.difficulty == 2 and 15 or 16
					--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
					EncounterJournal_OpenJournal(difficulty, instanceID, nil, nil, nil, nil)

				end)

				currentTierFrame.Name:SetText(v.shortName .. ":")

				local setLowestBorder = {}

				for x, y in ipairs(raidProgress.progress) do
					panelProgressString = wticc(miog.DIFFICULTY[y.difficulty].shortName .. ":" .. y.kills .. "/" .. v.bossCount, miog.DIFFICULTY[y.difficulty].color) .. " " .. panelProgressString

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

							currentBoss.Icon:SetTexture(miog.MAP_INFO[v.mapId][i].icon)
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
				
				currentTierFrame.Progress:SetText(panelProgressString)
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