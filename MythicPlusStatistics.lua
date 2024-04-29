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

local function round(n)
	return math.floor(n+0.5)
 end
 
 local function GetAffixCount(level)
	if level >= 14 then
	   return 3
	elseif level >= 7 then
	   return 2
	else
	   return 1
	end
 end
 
 
 local function GetTimerBonus(mapID, info)
	local _, _, mapTimer = C_ChallengeMode.GetMapUIInfo(mapID)
	local maxBonusTime = mapTimer * 0.4
	local beatTimerBy = mapTimer - info.durationSec -- can be negative
	local bonus = beatTimerBy/maxBonusTime
	return Clamp(bonus, -1, 1)
 end
 
 local function CalculateScore(mapID, info)
	local naffix = GetAffixCount(info.level)
 
	-- Gain or lose up to one level worth of score for being -40% to +40% timer
	local timerBonus = GetTimerBonus(mapID, info)
	
	-- Levels above 10 are worth 2 extra points (7 instead of 5)
	local nAboveTen = max(info.level-10, 0)
	
	-- The bonus (or penalty) for the timer does not get the 2 bonus
	local level = info.level + timerBonus
	
	-- Subtract one level for not timing it (not penalised the 2 points).
	if timerBonus <= 0 then
	   level = level - 1
	end
	
	return 20 + level*5 + nAboveTen*2 + naffix*10
 end

miog.calculateScoreGain = function(mapID, level, charGUID)
    --local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(mapID)
    local scores = {}
	local blizzardScores, blizzardOverall = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)
	
	if(charGUID == UnitGUID("player")) then

		for k, v in ipairs(blizzardScores) do
			if(v.name == "Tyrannical") then
				scores[1] = v

			else
				scores[2] = v
			
			end
		end

		scores[1] = scores[1] or {}
		scores[1].score = scores[1].score or 0

		scores[2] = scores[2] or {}
		scores[2].score = scores[2].score or 0

	else
		scores[1] = MIOG_SavedSettings.mPlusStatistics.table[charGUID]["tyrannical"][mapID] or {}
		scores[2] = MIOG_SavedSettings.mPlusStatistics.table[charGUID]["fortified"][mapID] or {}
	
		scores[1].score = scores[1].score ~= nil and scores[1].score or 0
		scores[2].score = scores[2].score ~= nil and scores[2].score or 0
		
	end

	local originalScore = CalculateScore(mapID, blizzardScores[1].level)

	return CalculateScore(mapID, 10, true) / (originalScore / blizzardScores[1].score), CalculateScore(mapID, 10) / (originalScore / blizzardScores[1].score)
end

for _, mapID in pairs(C_ChallengeMode.GetMapTable()) do
	local scores, overallScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)
	for _, info in ipairs(scores) do
	   local score = CalculateScore(mapID, info)
	   --print(miog.MAP_INFO[miog.retrieveMapIDFromChallengeModeMap(mapID)].shortName , overallScore, info.score, round(score))
	end
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

			MIOG_SavedSettings.mPlusStatistics.table[playerGUID].tyrannical[challengeMapID] = affixScores and affixScores[1] or {}
			MIOG_SavedSettings.mPlusStatistics.table[playerGUID].fortified[challengeMapID] =  affixScores and affixScores[2] or {}

		end

		local thisWeek = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][miog.F.WEEKLY_AFFIX == 9 and "tyrannical" or "fortified"][challengeMapID]
		local lastWeek = MIOG_SavedSettings.mPlusStatistics.table[playerGUID][miog.F.WEEKLY_AFFIX == 9 and "fortified" or "tyrannical"][challengeMapID]

		dungeonFrame.Level1:SetText(thisWeek and thisWeek.level or 0)
		dungeonFrame.Level1:SetTextColor(CreateColorFromHexString((thisWeek == nil or (thisWeek.level == 0 or thisWeek.level) == nil) and miog.CLRSCC.gray or thisWeek.overTime and miog.CLRSCC.red or miog.CLRSCC.green):GetRGBA())

		local desaturatedColors = CreateColorFromHexString((lastWeek == nil or (lastWeek.level == 0 or lastWeek.level) == nil) and miog.CLRSCC.gray or lastWeek.overTime and miog.CLRSCC.red or miog.CLRSCC.green)

		dungeonFrame.Level2:SetText(lastWeek and lastWeek.level or 0)
		dungeonFrame.Level2:SetTextColor(desaturatedColors.r * 0.5, desaturatedColors.g * 0.5, desaturatedColors.b * 0.5, 1)

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