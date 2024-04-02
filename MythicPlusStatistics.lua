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
	miog.MPlusStatistics.KeystoneDropdown:ResetDropDown()

	local groupMembers = GetNumGroupMembers()
	local numMembers = groupMembers ~= 0 and groupMembers or 1
 
	for i = 1, numMembers, 1 do
		local unitID = i == 1 and "player" or "party" .. (i-1)

		local keystoneInfo = miog.openRaidLib.GetKeystoneInfo(unitID)

		if(keystoneInfo and keystoneInfo.mapID ~= 0) then
			keystoneInfo.level = 30
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
	
				miog.MPlusStatistics.DungeonColumns.Selection:SetPoint("TOPLEFT", miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.mapID], "TOPLEFT")
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark = miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.mapID].TransparentDark
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Hide()
	
				if(unitID == "player") then
					local playerGUID = UnitGUID("player")
	
					for k, v in pairs(miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars) do
						v.ScoreIncrease:Hide()
	
					end
	
					local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, playerGUID)
	
					miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
					miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText(lowestGain .. " - " .. highestGain)
				else
					for k, v in pairs(miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars) do
						local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, k)
						v.ScoreIncrease:Show()
						v.ScoreIncrease:SetText(lowestGain .. " - " .. highestGain)
	
					end
				
				end
			end

			miog.MPlusStatistics.KeystoneDropdown:CreateEntryFrame(info)
		end
	end

	local keystoneInfo = {mapID = 1501, level = 26, challengeMapID = 199}

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

			miog.MPlusStatistics.DungeonColumns.Selection:SetPoint("TOPLEFT", miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.mapID], "TOPLEFT")
			miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark = miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.mapID].TransparentDark
			miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Hide()

			local unitID = "PARTY1"

			if(unitID == "player") then
				local playerGUID = UnitGUID("player")

				for k, v in pairs(miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars) do
					v.ScoreIncrease:Hide()

				end

				local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, playerGUID)

				miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
				miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText(lowestGain .. " - " .. highestGain)
			else
				for k, v in pairs(miog.MPlusStatistics.CharacterScrollFrame.Rows.accountChars) do
					local lowestGain, highestGain = miog.retrieveScoreGain(keystoneInfo.challengeMapID, keystoneInfo.level, k)
					v.ScoreIncrease:Show()
					v.ScoreIncrease:SetText(lowestGain .. " - " .. highestGain)

				end
			
			end
		end

		miog.MPlusStatistics.KeystoneDropdown:CreateEntryFrame(info)
	end

	miog.MPlusStatistics.KeystoneDropdown.List:MarkDirty()
	miog.MPlusStatistics.KeystoneDropdown:MarkDirty()
end