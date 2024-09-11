local addonName, miog = ...

local currentUnitName, currentChallengeMapID, currentLevel

-- ALGO FROM https://www.reddit.com/r/wow/comments/13vqsbw/an_accurate_formula_for_m_score_calculation_in/

local currentlySelectedID

local function round(n)
	return math.floor(n+0.5)
 end

 local function GetAffixCount(level)
	if level >= 10 then
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
 
 local function CalculateSingleScore(mapID, info, oldLevel)
	local naffix = GetAffixCount(info.level)
 
	-- Gain or lose up to one level worth of score for being -40% to +40% timer
	local timerBonus = GetTimerBonus(mapID, info)
	
	-- The bonus (or penalty) for the timer does not get the 2 bonus
	local level = info.level + timerBonus

	local nAboveTen = max(info.level-10, 0)
	
	-- Subtract one level for not timing it (not penalised the 2 points).
	if timerBonus <= 0 then
	   level = level - 1
	end
	
	return (90 + level * 5 + nAboveTen * 2 + naffix * 10) * (timerBonus <= 0 and nAboveTen >= 0 and oldLevel >= 10 and 0 or 1)
 end

 local function CalculateCombinedScore(mapID)
	local calcScores = {0, 0}

	local scores, overallScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)

	for k, info in ipairs(scores) do
		calcScores[k] = CalculateSingleScore(mapID, info)
	end

	return max(calcScores[1] , calcScores[2]) * 1.5 + min(calcScores[1] , calcScores[2]) * 0.5
 end

 local function calculateNewScore(mapID, newLevel, guid, customTimer)

	local scores, overallScore, inTimeInfo, overtimeInfo
	
	if(guid) then
		overallScore = MIOG_NewSettings.mplusStats[guid][mapID].overAllScore
		inTimeInfo = MIOG_NewSettings.mplusStats[guid][mapID].intimeInfo
		overtimeInfo = MIOG_NewSettings.mplusStats[guid][mapID].overtimeInfo
		
	else
		scores, overallScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)

	end

	local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(mapID)

	local overTimeGain, lowGain, highGain = 0, 0, 0
	local otherAffixScore = 0
	overallScore = overallScore or 0

	if(#scores > 0) then
		for k, info in ipairs(scores) do
			if(info.name == (miog.F.WEEKLY_AFFIX == 9 and "Tyrannical" or miog.F.WEEKLY_AFFIX == 10 and "Fortified")) then
				overTimeGain = CalculateSingleScore(mapID, {level = newLevel, durationSec = timeLimit}, info.level)
				lowGain = CalculateSingleScore(mapID, {level = newLevel, durationSec = timeLimit - 0.1}, info.level)
				highGain = CalculateSingleScore(mapID, {level = newLevel, durationSec = timeLimit - timeLimit * (customTimer and customTimer / 100)}, info.level)

			else
				otherAffixScore = CalculateSingleScore(mapID, info)
			
			end
		end
	else
		overTimeGain = CalculateSingleScore(mapID, {level = newLevel, durationSec = timeLimit}, 0)
		lowGain = CalculateSingleScore(mapID, {level = newLevel, durationSec = timeLimit - 0.1}, 0)
		highGain = CalculateSingleScore(mapID, {level = newLevel, durationSec = timeLimit - timeLimit * (customTimer and customTimer / 100)}, 0)
	
	end

	local overtimeScore = max(overTimeGain , otherAffixScore) * 1.5 + min(overTimeGain , otherAffixScore) * 0.5
	local lowerScore = max(lowGain , otherAffixScore) * 1.5 + min(lowGain , otherAffixScore) * 0.5
	local higherScore = max(highGain , otherAffixScore) * 1.5 + min(highGain , otherAffixScore) * 0.5

	return max(round(overtimeScore - overallScore), 0), max(round(lowerScore - overallScore), 0), max(round(higherScore - overallScore), 0)
 end

miog.calculateNewScore = calculateNewScore

miog.insertInfoIntoDropdown = function(unitName, keystoneInfo)
	if(unitName and keystoneInfo and keystoneInfo.mapID ~= 0) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)
		local className, classFile = GetClassInfo(keystoneInfo.classID)
		
		unitName = miog.createShortNameFrom("unitName", unitName)

		local text = WrapTextInColorCode(unitName, C_ClassColor.GetClassColor(classFile):GenerateHexColor()) .. ": " .. WrapTextInColorCode("+" .. keystoneInfo.level .. " " .. miog.MAP_INFO[keystoneInfo.mapID].shortName, miog.createCustomColorForRating(keystoneInfo.level * 130):GenerateHexColor())

		miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:SetDefaultText("Keystones")
		miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:SetupMenu(function(dropdown, rootDescription)
			local keystoneButton = rootDescription:CreateRadio(text, function() return (currentChallengeMapID == keystoneInfo.challengeMapID) == (currentUnitName == unitName) end, function()
				currentUnitName = unitName
				currentChallengeMapID = keystoneInfo.challengeMapID
				currentLevel = keystoneInfo.level
				
				if(miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark) then
					miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Show()

				end

				if(miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID]) then
					miog.MPlusStatistics.DungeonColumns.Selection:SetPoint("TOPLEFT", miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID], "TOPLEFT")
					miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark = miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID].TransparentDark
					miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Hide()
				end

				if(unitName == UnitName("player")) then
					local overtimeScore, minScore, maxScore = miog.calculateNewScore(keystoneInfo.challengeMapID, keystoneInfo.level, nil, miog.MPlusStatistics.CharacterInfo.TimelimitSlider:GetValue())

					local playerGUID = UnitGUID("player")

					for _, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
						v.ScoreIncrease:Hide()

					end

					miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
					miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
				else
					for k, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
						local overtimeScore, minScore, maxScore = miog.calculateNewScore(keystoneInfo.challengeMapID, keystoneInfo.level, k, miog.MPlusStatistics.CharacterInfo.TimelimitSlider:GetValue())

						v.ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
						v.ScoreIncrease:Show()

					end
				
				end
			end, keystoneInfo.challengeMapID)

			keystoneButton:AddInitializer(function(button, description, menu)
				local leftTexture = button:AttachTexture();
				leftTexture:SetSize(14, 14);
				leftTexture:SetPoint("LEFT", 17, 0);
				leftTexture:SetTexture(texture);

				button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

				return button.fontString:GetUnboundedStringWidth() + 14 + 2
			end)

		end)

			

		--[[local info = {}
		info.entryType = "option"
		info.text = text
		info.value = keystoneInfo.level
		info.icon = texture
		info.func = function()
			currentUnitName = unitName
			currentChallengeMapID = keystoneInfo.challengeMapID
			currentLevel = keystoneInfo.level
			
			if(miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark) then
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Show()

			end

			miog.MPlusStatistics.DungeonColumns.Selection:SetPoint("TOPLEFT", miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID], "TOPLEFT")
			miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark = miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID].TransparentDark
			miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Hide()

			if(unitName == UnitName("player")) then
				local overtimeScore, minScore, maxScore = miog.calculateNewScore(keystoneInfo.challengeMapID, keystoneInfo.level, nil, miog.MPlusStatistics.CharacterInfo.TimelimitSlider:GetValue())

				local playerGUID = UnitGUID("player")

				for _, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
					v.ScoreIncrease:Hide()

				end

				miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
				miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
			else
				for k, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
					local overtimeScore, minScore, maxScore = miog.calculateNewScore(keystoneInfo.challengeMapID, keystoneInfo.level, k, miog.MPlusStatistics.CharacterInfo.TimelimitSlider:GetValue())

					v.ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
					v.ScoreIncrease:Show()

				end
			
			end
		end

		if(miog.MPlusStatistics) then
			miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:CreateEntryFrame(info)
		end]]
	end
end

miog.setUpMPlusStatistics = function()
	miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:SetText("Party keystones")

	miog.MPlusStatistics.CharacterInfo.TimelimitSlider:SetScript("OnValueChanged", function(self)
		self.Text:SetText(round(self:GetValue()) .. "%")

		if(currentUnitName) then
			local currentTimerValue = miog.MPlusStatistics.CharacterInfo.TimelimitSlider:GetValue()

			if(miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark) then
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Show()

			end

			if(miog.MPlusStatistics.DungeonColumns.Dungeons[currentChallengeMapID]) then
				miog.MPlusStatistics.DungeonColumns.Selection:SetPoint("TOPLEFT", miog.MPlusStatistics.DungeonColumns.Dungeons[currentChallengeMapID], "TOPLEFT")
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark = miog.MPlusStatistics.DungeonColumns.Dungeons[currentChallengeMapID].TransparentDark
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Hide()
			end

			if(currentUnitName == UnitName("player")) then
				local overtimeScore, minScore, maxScore = calculateNewScore(currentChallengeMapID, currentLevel, nil, currentTimerValue)

				local playerGUID = UnitGUID("player")

				for _, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
					v.ScoreIncrease:Hide()

				end

				miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
				miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
			else
				for k, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
					local overtimeScore, minScore, maxScore = calculateNewScore(currentChallengeMapID, currentLevel, k, currentTimerValue)

					v.ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
					v.ScoreIncrease:Show()

				end
			
			end
		end
	end)

	if(miog.F.MPLUS_SETUP_COMPLETE ~= true) then
		local mapTable = miog.SEASONAL_CHALLENGE_MODES[13] or C_ChallengeMode.GetMapTable()

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
		selectionFrame:SetHeight(miog.MPlusStatistics:GetHeight() - 2)
		miog.createFrameBorder(selectionFrame, 1, CreateColorFromHexString(miog.CLRSCC.silver):GetRGBA())

		miog.MPlusStatistics.DungeonColumns:MarkDirty()

		miog.MPlusStatistics:SetScript("OnShow", function()
			miog.gatherMPlusStatistics()

			if(IsInRaid()) then
				miog.openRaidLib.RequestKeystoneDataFromRaid()
				
			elseif(IsInGroup()) then
				miog.openRaidLib.RequestKeystoneDataFromParty()
			end
		end)

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
		MIOG_NewSettings.mplusStats[playerGUID] = {}
		MIOG_NewSettings.mplusStats[playerGUID].name = UnitName("player")
		MIOG_NewSettings.mplusStats[playerGUID].fullName = miog.createFullNameFrom("unitID", "player")
		MIOG_NewSettings.mplusStats[playerGUID].class = className
		MIOG_NewSettings.mplusStats[playerGUID].score = C_ChallengeMode.GetOverallDungeonScore()
	end

	characterFrame.Name:SetText(MIOG_NewSettings.mplusStats[playerGUID].name)
	characterFrame.Name:SetTextColor(C_ClassColor.GetClassColor(MIOG_NewSettings.mplusStats[playerGUID].class):GetRGBA())
	--[[characterFrame.Name:SetScript("OnEnter", function()
		local name, realm = miog.createSplitName(MIOG_NewSettings.mplusStats[playerGUID].fullName)

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(, 1, 1, 1);

		for k, v in ipairs(miog.getMPlusSortData(name, realm)) do
	end)]]
	characterFrame.Score:SetText(MIOG_NewSettings.mplusStats[playerGUID].score)
	characterFrame.Score:SetTextColor(miog.createCustomColorForRating(MIOG_NewSettings.mplusStats[playerGUID].score):GetRGBA())

	for index, challengeMapID in pairs(mapTable or miog.SEASONAL_CHALLENGE_MODES[13] or C_ChallengeMode.GetMapTable()) do
		local dungeonFrame = characterFrame["Dungeon" .. index]
		dungeonFrame.mapID = challengeMapID
		dungeonFrame:SetWidth(miog.MPlusStatistics.DungeonColumns.Dungeons[challengeMapID]:GetWidth())
		dungeonFrame.layoutIndex = index

		if(isCurrentChar) then
			MIOG_NewSettings.mplusStats[playerGUID][challengeMapID] = {}

			local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID)

			MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].inTimeInfo = intimeInfo
			MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].overtimeInfo = overtimeInfo
			MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].overAllScore = intimeInfo and intimeInfo.dungeonScore or overtimeInfo and overtimeInfo.dungeonScore or 0
		end

		local hasIntimeInfo = MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].inTimeInfo ~= nil
		local hasOvertimeInfo = MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].overtimeInfo ~= nil

		dungeonFrame.Level:SetText(hasIntimeInfo and MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].inTimeInfo.level or hasOvertimeInfo and MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].overtimeInfo.level or 0)
		dungeonFrame.Level:SetTextColor(CreateColorFromHexString(not hasIntimeInfo and not hasOvertimeInfo and miog.CLRSCC.gray or hasOvertimeInfo and MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].overtimeInfo.level and miog.CLRSCC.red or miog.CLRSCC.green):GetRGBA())
		dungeonFrame:SetScript("OnEnter", function(self) -- ChallengesDungeonIconMixin:OnEnter()
			local name = C_ChallengeMode.GetMapUIInfo(challengeMapID);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(name, 1, 1, 1);
		
			--local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.mapID);
			--local affixScores, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(self.mapID);

			local overAllScore = MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].overAllScore
			local inTimeInfo = MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].inTimeInfo
			local overtimeInfo = MIOG_NewSettings.mplusStats[playerGUID][challengeMapID].overtimeInfo
		
			if(overAllScore and (inTimeInfo or overtimeInfo)) then
				local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overAllScore);
				if(not color) then
					color = HIGHLIGHT_FONT_COLOR;
				end
				GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(overAllScore)), GREEN_FONT_COLOR);

				local info = inTimeInfo or overtimeInfo

				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				--GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_BEST_AFFIX:format(affixInfo.name));
				GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(info.level), HIGHLIGHT_FONT_COLOR);
				if(not hasIntimeInfo and hasOvertimeInfo) then
					if(overtimeInfo.durationSec >= SECONDS_PER_HOUR) then
						GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(overtimeInfo.durationSec, true)), LIGHTGRAY_FONT_COLOR);
					else
						GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(overtimeInfo.durationSec, false)), LIGHTGRAY_FONT_COLOR);
					end
				elseif(hasIntimeInfo) then
					if(inTimeInfo.durationSec >= SECONDS_PER_HOUR) then
						GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(inTimeInfo.durationSec, true), HIGHLIGHT_FONT_COLOR);
					else
						GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(inTimeInfo.durationSec, false), HIGHLIGHT_FONT_COLOR);
					end
				end
			end
		
			GameTooltip:Show();
		end)

	end
end

miog.gatherMPlusStatistics = function()
	local playerGUID = UnitGUID("player")
	
	local mapTable = miog.SEASONAL_CHALLENGE_MODES[13] or C_ChallengeMode.GetMapTable()

	table.sort(mapTable, function(k1, k2)
		local mapName1 = miog.retrieveShortNameFromChallengeModeMap(k1)
		local mapName2 = miog.retrieveShortNameFromChallengeModeMap(k2)

		return mapName1 < mapName2

	end)

	miog.createMPlusCharacter(playerGUID, mapTable)

	local orderedTable = {}

	for x, y in pairs(MIOG_NewSettings.mplusStats) do
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