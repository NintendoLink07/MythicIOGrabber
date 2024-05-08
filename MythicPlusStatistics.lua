local addonName, miog = ...

local DUNGEON_BASE_SCORES = {
	--Key Level	Base Score	Min Score	Max Score
	[1] = 0,
	[2] = 40,
	[3] = 45,
	[4] = 55,
	[5] = 60,
	[6] = 65,
	[7] = 75,
	[8] = 80,
	[9] = 85,
	[10] = 100,
	[11] = 107,
	[12] = 114,
	[13] = 121,
	[14] = 128,
	[15] = 135,
	[16] = 142,
	[17] = 149,
	[18] = 156,
	[19] = 163,
	[20] = 170,
	[21] = 177,
	[22] = 184,
	[23] = 191,
	[24] = 198,
	[25] = 205,
	[26] = 212,
	[27] = 219,
	[28] = 226,
	[29] = 233,
	[30] = 240,
}

miog.refreshKeystones = function()
	miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:ResetDropDown()

	local groupMembers = GetNumGroupMembers()
	local numMembers = groupMembers ~= 0 and groupMembers or 1
 
	for i = 1, numMembers, 1 do
		local unitID = i == 1 and "player" or "party" .. (i-1)

		local keystoneInfo = miog.openRaidLib.GetKeystoneInfo(unitID)

		if(keystoneInfo and keystoneInfo.mapID ~= 0) then
			local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)
			local className, classFile = GetClassInfo(keystoneInfo.classID)

			local info = {}
			info.entryType = "option"
			info.text = WrapTextInColorCode(UnitName(unitID), C_ClassColor.GetClassColor(classFile):GenerateHexColor()) .. ": " .. WrapTextInColorCode("+" .. keystoneInfo.level .. " " .. miog.MAP_INFO[keystoneInfo.mapID].shortName, miog.createCustomColorForScore(keystoneInfo.level * 130):GenerateHexColor())
			info.value = keystoneInfo.level
			info.icon = texture
			--[[info.func = function()

				if(miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark) then
					miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Show()
	
				end
	
				--miog.MPlusStatistics.DungeonColumns.Selection:SetSize(miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID]:GetSize())
				miog.MPlusStatistics.DungeonColumns.Selection:SetPoint("TOPLEFT", miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID], "TOPLEFT")
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark = miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID].TransparentDark
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Hide()
	
				if(unitID == "player") then
					local playerGUID = UnitGUID("player")
	
					for _, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
						v.ScoreIncrease:Hide()
	
					end
	
					local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, playerGUID)
	
					if(lowestGain and highestGain) then
						miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText("+ " .. lowestGain .. " - " .. highestGain)
						miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
					end
				else
					for k, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
						local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, k)
						if(lowestGain and highestGain) then
							v.ScoreIncrease:SetText("+ " .. lowestGain .. " - " .. highestGain)
							v.ScoreIncrease:Show()
						end
	
					end
				
				end
			end]]

			miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:CreateEntryFrame(info)
		end
	end

	--[[local keystoneInfo = {mapID = 1501, level = 26, challengeMapID = 199}

	if(keystoneInfo) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)
		local classFile = "WARRIOR"

		local info = {}
		info.entryType = "option"
		info.text = WrapTextInColorCode("PARTY1", C_ClassColor.GetClassColor(classFile):GenerateHexColor()) .. ": " .. WrapTextInColorCode("+" .. keystoneInfo.level .. " " .. miog.MAP_INFO[keystoneInfo.mapID].shortName, miog.createCustomColorForScore(keystoneInfo.level * 130):GenerateHexColor())
		info.value = keystoneInfo.level
		info.icon = texture
		info.func = function()

			if(miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark) then
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Show()

			end

			miog.MPlusStatistics.DungeonColumns.Selection:SetSize(miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID]:GetSize())
			miog.MPlusStatistics.DungeonColumns.Selection:SetPoint("TOPLEFT", miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID], "TOPLEFT")
			miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark = miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID].TransparentDark
			miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Hide()

			local unitID = "PARTY1"

			if(unitID == "player") then
				local playerGUID = UnitGUID("player")

				for k, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
					v.ScoreIncrease:Hide()

				end

				local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, playerGUID)

				miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
				miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText(lowestGain .. " - " .. highestGain)
			else
				for k, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
					local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, k)
					v.ScoreIncrease:Show()
					v.ScoreIncrease:SetText(lowestGain .. " - " .. highestGain)

				end
			
			end
		end

		miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:CreateEntryFrame(info)
	end]]

	miog.MPlusStatistics.CharacterInfo.KeystoneDropdown.List:MarkDirty()
end

miog.setUpMPlusStatistics = function()
	if(miog.F.MPLUS_SETUP_COMPLETE ~= true) then
		local mapTable = C_ChallengeMode.GetMapTable()

		table.sort(mapTable, function(k1, k2)
			local mapName1 = miog.retrieveShortNameFromChallengeModeMap(k1)
			local mapName2 = miog.retrieveShortNameFromChallengeModeMap(k2)

			return mapName1 < mapName2

		end)

		for index, challengeMapID in pairs(mapTable) do
			if(miog.MPlusStatistics.DungeonColumns.Dungeons[challengeMapID] == nil) then
				local mapID = miog.retrieveMapIDFromChallengeModeMap(challengeMapID)
				local mapInfo = miog.MAP_INFO[mapID]

				local dungeonColumn = CreateFrame("Frame", nil, miog.MPlusStatistics.DungeonColumns, "MIOG_MPlusStatisticsColumnTemplate")
				dungeonColumn:SetHeight(miog.MPlusStatistics:GetHeight())
				dungeonColumn.layoutIndex = index

				miog.createFrameBorder(dungeonColumn, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

				dungeonColumn.Background:SetTexture(mapInfo.vertical)

				local shortName = miog.retrieveShortNameFromChallengeModeMap(challengeMapID)
				dungeonColumn.ShortName:SetText(shortName)

				miog.MPlusStatistics.DungeonColumns.Dungeons[challengeMapID] = dungeonColumn

			end
		end

		local selectionFrame = miog.MPlusStatistics.DungeonColumns.Selection
		selectionFrame:SetHeight(miog.MPlusStatistics:GetHeight())
		miog.createFrameBorder(selectionFrame, 1, CreateColorFromHexString(miog.CLRSCC.silver):GetRGBA())

		miog.MPlusStatistics.DungeonColumns:MarkDirty()

		miog.F.MPLUS_SETUP_COMPLETE = true
	end
end

miog.createMPlusCharacter = function(playerGUID, mapTable)
	local characterFrame

	if(miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID] == nil) then
		characterFrame = CreateFrame("Frame", nil, miog.MPlusStatistics.ScrollFrame.Rows, "MIOG_MPlusStatisticsCharacterTemplate")

		characterFrame:SetWidth(miog.MPlusStatistics.ScrollFrame:GetWidth())
		characterFrame.layoutIndex = #miog.MPlusStatistics.ScrollFrame.Rows:GetLayoutChildren() + 1

		if(characterFrame.layoutIndex == 1) then
			characterFrame:SetHeight(55)
			local fontFile, height, flags = characterFrame.Name:GetFont()
			characterFrame.Name:SetFont(fontFile, 14, flags)
			characterFrame.TransparentDark:SetHeight(36)

		else
			characterFrame.TransparentDark:SetHeight(32)

		end

		miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID] = characterFrame
	else

		characterFrame = miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID]
	end

	local _, className = UnitClass("player")
	local isCurrentChar = playerGUID == UnitGUID("player")

	if(isCurrentChar) then
		MIOG_SavedSettings.mPlusStatistics.table[playerGUID] = {}
		MIOG_SavedSettings.mPlusStatistics.table[playerGUID].name = UnitName("player")
		MIOG_SavedSettings.mPlusStatistics.table[playerGUID].class = className
		MIOG_SavedSettings.mPlusStatistics.table[playerGUID].score = C_ChallengeMode.GetOverallDungeonScore()
	end

	characterFrame.Name:SetText(MIOG_SavedSettings.mPlusStatistics.table[playerGUID].name)
	characterFrame.Name:SetTextColor(C_ClassColor.GetClassColor(MIOG_SavedSettings.mPlusStatistics.table[playerGUID].class):GetRGBA())
	characterFrame.Score:SetText(MIOG_SavedSettings.mPlusStatistics.table[playerGUID].score)
	characterFrame.Score:SetTextColor(miog.createCustomColorForScore(MIOG_SavedSettings.mPlusStatistics.table[playerGUID].score):GetRGBA())

	if(miog.F.WEEKLY_AFFIX) then
		characterFrame.Affix1:SetTexture(miog.F.AFFIX_INFO[miog.F.WEEKLY_AFFIX][3])
		characterFrame.Affix2:SetTexture(miog.F.AFFIX_INFO[miog.F.WEEKLY_AFFIX == 9 and 10 or 9][3])
	end

	for index, challengeMapID in pairs(mapTable or C_ChallengeMode.GetMapTable()) do
		local dungeonFrame = characterFrame["Dungeon" .. index]
		dungeonFrame.mapID = challengeMapID
		dungeonFrame:SetWidth(miog.MPlusStatistics.DungeonColumns.Dungeons[challengeMapID]:GetWidth())
		dungeonFrame.layoutIndex = index

		if(isCurrentChar) then
			MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID] = {}

			local affixScores, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(challengeMapID)

			if(affixScores) then
				for k, v in ipairs(affixScores) do
					MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID][v.name] = v

				end

				local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID);

				MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID].overAllScore = overAllScore
				MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID].inTimeInfo = inTimeInfo
				MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID].overtimeInfo = overtimeInfo
			end

		end

		local thisWeek = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID][miog.F.WEEKLY_AFFIX == 9 and "Tyrannical" or "Fortified"]
		local lastWeek = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID][miog.F.WEEKLY_AFFIX == 9 and "Fortified" or "Tyrannical"]

		dungeonFrame.Level1:SetText(thisWeek and thisWeek.level or 0)
		dungeonFrame.Level1:SetTextColor(CreateColorFromHexString((thisWeek == nil or (thisWeek.level == 0 or thisWeek.level) == nil) and miog.CLRSCC.gray or thisWeek.overTime and miog.CLRSCC.red or miog.CLRSCC.green):GetRGBA())

		local desaturatedColors = CreateColorFromHexString((lastWeek == nil or (lastWeek.level == 0 or lastWeek.level) == nil) and miog.CLRSCC.gray or lastWeek.overTime and miog.CLRSCC.red or miog.CLRSCC.green)

		dungeonFrame.Level2:SetText(lastWeek and lastWeek.level or 0)
		dungeonFrame.Level2:SetTextColor(desaturatedColors.r * 0.5, desaturatedColors.g * 0.5, desaturatedColors.b * 0.5, 1)

		dungeonFrame:SetScript("OnEnter", function(self) -- ChallengesDungeonIconMixin:OnEnter()
			local name = C_ChallengeMode.GetMapUIInfo(challengeMapID);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(name, 1, 1, 1);
		
			--local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.mapID);
			--local affixScores, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(self.mapID);

			local overAllScore = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID].overAllScore
			local inTimeInfo = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID].inTimeInfo
			local overtimeInfo = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID].overtimeInfo
		
			if(overAllScore and (inTimeInfo or overtimeInfo)) then
				local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overAllScore);
				if(not color) then
					color = HIGHLIGHT_FONT_COLOR;
				end
				GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(overAllScore)), GREEN_FONT_COLOR);
			end
		
			--if(affixScores and #affixScores > 0) then
				--for _, affixInfo in ipairs(affixScores) do
				for i = 1, 2, 1 do
					local affixInfo = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][challengeMapID][i == 1 and (miog.F.WEEKLY_AFFIX == 9 and "Tyrannical" or "Fortified") or miog.F.WEEKLY_AFFIX == 9 and "Fortified" or "Tyrannical"]

					if(affixInfo) then
						GameTooltip_AddBlankLineToTooltip(GameTooltip);
						GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_BEST_AFFIX:format(affixInfo.name));
						GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(affixInfo.level), HIGHLIGHT_FONT_COLOR);
						if(affixInfo.overTime) then
							if(affixInfo.durationSec >= SECONDS_PER_HOUR) then
								GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, true)), LIGHTGRAY_FONT_COLOR);
							else
								GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, false)), LIGHTGRAY_FONT_COLOR);
							end
						else
							if(affixInfo.durationSec >= SECONDS_PER_HOUR) then
								GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, true), HIGHLIGHT_FONT_COLOR);
							else
								GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, false), HIGHLIGHT_FONT_COLOR);
							end
						end
					end
				end
				--end
			--end
		
			GameTooltip:Show();
		end)

	end
end

miog.gatherMPlusStatistics = function()
	local playerGUID = UnitGUID("player")
	
	local mapTable = C_ChallengeMode.GetMapTable()

	table.sort(mapTable, function(k1, k2)
		local mapName1 = miog.retrieveShortNameFromChallengeModeMap(k1)
		local mapName2 = miog.retrieveShortNameFromChallengeModeMap(k2)

		return mapName1 < mapName2

	end)

	miog.createMPlusCharacter(playerGUID, mapTable)

	local orderedTable = {}

	for x, y in pairs(MIOG_SavedSettings.mPlusStatistics.table) do
		local index = #orderedTable+1
		orderedTable[index] = y
		orderedTable[index].key = x
	end

	table.sort(orderedTable, function(k1, k2)
		return k1.score > k2.score
	end)

	for x, y in pairs(orderedTable) do
		if(y.key ~= playerGUID) then
			miog.createMPlusCharacter(y.key, mapTable)

		end
	end

	miog.MPlusStatistics.ScrollFrame.Rows:MarkDirty()
end