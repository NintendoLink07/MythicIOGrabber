local addonName, miog = ...

local DUNGEON_BASE_SCORES = {
	--Key Level	Base Score	Min Score	Max Score
	[2] = {40, 30, 45},
	[3] = {45, 35, 50},
	[4] = {55, 45, 60},
	[5] = {60, 50, 65},
	[6] = {65, 55, 70},
	[7] = {75, 65, 80},
	[8] = {80, 70, 85},
	[9] = {85, 75, 90},
	[10] = {100, 90, 105},
	[11] = {107, 97, 112},
	[12] = {114, 104, 119},
	[13] = {121, 111, 126},
	[14] = {128, 118, 133},
	[15] = {135, 125, 140},
	[16] = {142, 132, 147},
	[17] = {149, 139, 154},
	[18] = {156, 146, 161},
	[19] = {163, 153, 168},
	[20] = {170, 160, 175},
	[21] = {177, 167, 182},
	[22] = {184, 174, 189},
	[23] = {191, 181, 196},
	[24] = {198, 188, 203},
	[25] = {205, 195, 210},
	[26] = {212, 202, 217},
	[27] = {219, 209, 224},
	[28] = {226, 216, 231},
	[29] = {233, 223, 238},
	[30] = {240, 230, 245},
}

miog.calculateDualRating = function(fortified, tyrannical)
	return ((tyrannical > fortified and tyrannical or fortified) * 1.5) + ((tyrannical < fortified and tyrannical or fortified) * 0.5)

end

miog.calculateSpread = function(scores, level, name)
	local lowestDualRating, highestDualRating
	local oldDualRating = miog.calculateDualRating(scores[1].score, scores[2].score)

	for i = 1, 2, 1 do
		local newRating = DUNGEON_BASE_SCORES[level][1] + ((i == 1 and 0 or 0.4) * 12.5)
		local newDualRating = miog.calculateDualRating(miog.F.WEEKLY_AFFIX == 10 and newRating or scores[1].score, miog.F.WEEKLY_AFFIX == 9 and newRating or scores[2].score)

		if(i == 1) then
			lowestDualRating = newDualRating - oldDualRating

		else
			highestDualRating = newDualRating - oldDualRating

		end
	end

	return lowestDualRating and lowestDualRating > 0 and lowestDualRating or 0, highestDualRating and highestDualRating > 0 and highestDualRating or 0
end

miog.calculateScoreGain = function(mapID, level, charGUID)
    --local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(mapID)
    local scores
	
	if(charGUID == UnitGUID("player")) then
		scores = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID) or {} -- 1 FORT, 2 TYRA

		scores[1] = scores[1] or {}
		scores[1].score = scores[1].score or 0

		scores[2] = scores[2] or {}
		scores[2].score = scores[2].score or 0

	else
		scores = {}
		scores[1] = MIOG_SavedSettings.mPlusStatistics.table[charGUID].fortified[mapID] or {}
		scores[2] = MIOG_SavedSettings.mPlusStatistics.table[charGUID].tyrannical[mapID] or {}
	
		scores[1].score = scores[1].score ~= nil and scores[1].score or 0
		scores[2].score = scores[2].score ~= nil and scores[2].score or 0
		
	end

	return miog.calculateSpread(scores, level)
end

miog.retrieveScoreGain = function(mapID, level, charGUID)
    --local intime, overtime =  C_MythicPlus.GetSeasonBestForMap(mapID)
    --local scores, bestScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID) -- FORT THEN TYRA

    if(miog.F.WEEKLY_AFFIX) then
        local charStatistics = MIOG_SavedSettings.mPlusStatistics.table[charGUID]

        if(charStatistics) then
            local affixStatistics = charStatistics[miog.F.WEEKLY_AFFIX == 9 and "tyrannical" or "fortified"]

            if(affixStatistics) then
                local currentStatistics = affixStatistics[mapID]

                if(currentStatistics) then
                    return miog.calculateScoreGain(mapID, level, charGUID)
                end
            end
        end
    end
end

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
			info.func = function()

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
						miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
						miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText("+ " .. lowestGain .. " - " .. highestGain)
					end
				else
					for k, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
						local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, k)
						if(lowestGain and highestGain) then
							v.ScoreIncrease:Show()
							v.ScoreIncrease:SetText("+ " .. lowestGain .. " - " .. highestGain)
						end
	
					end
				
				end
			end

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
	miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:MarkDirty()
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

		MIOG_SavedSettings.mPlusStatistics.table[playerGUID].tyrannical = {}
		MIOG_SavedSettings.mPlusStatistics.table[playerGUID].fortified = {}
	end

	characterFrame.Name:SetText(MIOG_SavedSettings.mPlusStatistics.table[playerGUID].name)
	characterFrame.Name:SetTextColor(C_ClassColor.GetClassColor(MIOG_SavedSettings.mPlusStatistics.table[playerGUID].class):GetRGBA())
	characterFrame.Score:SetText(MIOG_SavedSettings.mPlusStatistics.table[playerGUID].score)
	characterFrame.Score:SetTextColor(miog.createCustomColorForScore(MIOG_SavedSettings.mPlusStatistics.table[playerGUID].score):GetRGBA())

	for index, challengeMapID in pairs(mapTable or C_ChallengeMode.GetMapTable()) do
		local dungeonFrame = characterFrame["Dungeon" .. index]
		dungeonFrame:SetWidth(miog.MPlusStatistics.DungeonColumns.Dungeons[challengeMapID]:GetWidth())
		dungeonFrame.layoutIndex = index

		if(isCurrentChar) then
			local affixScores = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(challengeMapID)

			MIOG_SavedSettings.mPlusStatistics.table[playerGUID].fortified[challengeMapID] =  affixScores and affixScores[2] or {}
			MIOG_SavedSettings.mPlusStatistics.table[playerGUID].tyrannical[challengeMapID] = affixScores and affixScores[1] or {}

		end

		local thisWeek = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][miog.F.WEEKLY_AFFIX == 9 and "tyrannical" or "fortified"][challengeMapID]
		local lastWeek = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][miog.F.WEEKLY_AFFIX == 9 and "fortified" or "tyrannical"][challengeMapID]

		dungeonFrame.Level1:SetText(thisWeek and thisWeek.level or 0)
		dungeonFrame.Level1:SetTextColor(CreateColorFromHexString((thisWeek == nil or (thisWeek.level == 0 or thisWeek.level) == nil) and miog.CLRSCC.gray or thisWeek.overTime and miog.CLRSCC.red or miog.CLRSCC.green):GetRGBA())

		local desaturatedColors = CreateColorFromHexString((lastWeek == nil or (lastWeek.level == 0 or lastWeek.level) == nil) and miog.CLRSCC.gray or lastWeek.overTime and miog.CLRSCC.red or miog.CLRSCC.green)

		dungeonFrame.Level2:SetText(lastWeek and lastWeek.level or 0)
		dungeonFrame.Level2:SetTextColor(desaturatedColors.r * 0.6, desaturatedColors.g * 0.6, desaturatedColors.b * 0.6, 1)

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