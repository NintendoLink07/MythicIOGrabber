local addonName, miog = ...
local accountCharacters
local playerGUID
local mythicPlusActivities, raidActivities

local formatter = CreateFromMixins(SecondsFormatterMixin)
formatter:SetStripIntervalWhitespace(true)
formatter:Init(0, SecondsFormatter.Abbreviation.None)

local activityIndices = {
	Enum.WeeklyRewardChestThresholdType.Activities, -- m+
	Enum.WeeklyRewardChestThresholdType.Raid, -- raid
	Enum.WeeklyRewardChestThresholdType.World, -- world/delves
}

local pvpActivities = {
	1,
	2,
	--3,
	4,
	7,
	9,
}
-- 1 == 2v2, 2 == 3v3, 3 == 5v5, 4 == 10v10, Solo Arena == 7, Solo BG == 9

ProgressionTabMixin = {}


local function getChestsLevelForID(challengeMapID, durationSec)
	local name, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeMapID)

	local oneChest = timeLimit
	local twoChest = timeLimit * 0.8
	local threeChest = timeLimit * 0.6

	return durationSec <= threeChest and 3 or durationSec <= twoChest and 2 or durationSec <= oneChest and 1 or 0
end

local function sortByScore(k1, k2)
    if k1 and k2 then
        -- Check if either is the player's GUID
        if k1.guid == UnitGUID("player") then
            return true
        elseif k2.guid == UnitGUID("player") then
            return false
        end
        -- Compare scores
        return k1.score.value > k2.score.value
    elseif k1 then
        return true  -- k1 is valid, k2 is nil
    elseif k2 then
        return false -- k2 is valid, k1 is nil
    else
        return false -- Both are nil, order doesn't matter
    end
end

local function sortByProgress(k1, k2)
    if k1 and k2 then
        -- Check if either is the player's GUID
        if k1.guid == UnitGUID("player") then
            return true
        elseif k2.guid == UnitGUID("player") then
            return false
        end
        -- Compare scores

        return k1.progressWeight > k2.progressWeight
    elseif k1 then
        return true  -- k1 is valid, k2 is nil
    elseif k2 then
        return false -- k2 is valid, k1 is nil
    else
        return false -- Both are nil, order doesn't matter
    end

end

local function sortByRating(k1, k2)
    if k1 and k2 then
        -- Check if either is the player's GUID
        if k1.guid == UnitGUID("player") then
            return true
        elseif k2.guid == UnitGUID("player") then
            return false
        end
        -- Compare scores
        return k1.rating > k2.rating
    elseif k1 then
        return true  -- k1 is valid, k2 is nil
    elseif k2 then
        return false -- k2 is valid, k1 is nil
    else
        return false -- Both are nil, order doesn't matter
    end

end

local function sortByCombined(k1, k2)
    if k1 and k2 then
        -- Check if either is the player's GUID
        if k1.guid == UnitGUID("player") then
            return true
        elseif k2.guid == UnitGUID("player") then
            return false
        end
        -- Compare scores
        return k1.combinedWeight > k2.combinedWeight
    elseif k1 then
        return true  -- k1 is valid, k2 is nil
    elseif k2 then
        return false -- k2 is valid, k1 is nil
    else
        return false -- Both are nil, order doesn't matter
    end

end

local function pvpOnEnter(selfFrame, tierTable)
    local tierInfo = C_PvP.GetPvpTierInfo(tierTable[1])
    local nextTierInfo = C_PvP.GetPvpTierInfo(tierTable[2])

    GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
    GameTooltip:SetMinimumWidth(260);
    --GameTooltip_SetTitle(GameTooltip, tierName);
	local tierName = tierInfo and tierInfo.pvpTierEnum and PVPUtil.GetTierName(tierInfo.pvpTierEnum);
	if tierName then
        GameTooltip:AddLine(tierName)

		local activityItemLevel, weeklyItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(tierInfo.pvpTierEnum);
		if weeklyItemLevel > 0 then
			GameTooltip_AddColoredLine(GameTooltip, PVP_GEAR_REWARD_BY_RANK:format(weeklyItemLevel), NORMAL_FONT_COLOR);
		end
	end

    local nextTierName = nextTierInfo and nextTierInfo.pvpTierEnum and PVPUtil.GetTierName(nextTierInfo.pvpTierEnum);
	if nextTierName then
        GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip:AddLine(TOOLTIP_PVP_NEXT_RANK:format(nextTierName));
		local tierDescription = PVPUtil.GetTierDescription(nextTierInfo.pvpTierEnum);
		if tierDescription then
			GameTooltip_AddNormalLine(GameTooltip, tierDescription);
		end
		local activityItemLevel, weeklyItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(nextTierInfo.pvpTierEnum);
		if activityItemLevel > 0 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, PVP_GEAR_REWARD_BY_NEXT_RANK:format(weeklyItemLevel), NORMAL_FONT_COLOR);
		end
	end

    GameTooltip:Show();
end

local function mplusOnEnter(self, playerGUID)
	local challengeMapID = self.challengeMapID
	local name = C_ChallengeMode.GetMapUIInfo(challengeMapID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(name, 1, 1, 1);

	local intimeInfo = MIOG_NewSettings.accountStatistics.characters[playerGUID].mplus[challengeMapID].intimeInfo
	local overtimeInfo = MIOG_NewSettings.accountStatistics.characters[playerGUID].mplus[challengeMapID].overtimeInfo
	local overtimeHigher = intimeInfo and overtimeInfo and intimeInfo.dungeonScore and overtimeInfo.dungeonScore and overtimeInfo.dungeonScore > intimeInfo.dungeonScore and true or false
	local overallScore = overtimeHigher and overtimeInfo.dungeonScore or intimeInfo and intimeInfo.dungeonScore or 0

	if(intimeInfo or overtimeInfo) then
		if(overallScore) then
			local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overallScore);
			if(not color) then
				color = HIGHLIGHT_FONT_COLOR;
			end
			GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(overallScore)), GREEN_FONT_COLOR);
		end

		local info = overtimeHigher and overtimeInfo or intimeInfo

		if(info) then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(info.level) .. (intimeInfo and string.format(" (%s chest)", intimeInfo.chests or getChestsLevelForID(challengeMapID, intimeInfo.durationSec)) or ""), HIGHLIGHT_FONT_COLOR);

			if(overallScore) then
				if(not overtimeHigher and intimeInfo) then
					GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(intimeInfo.durationSec, intimeInfo.durationSec >= SECONDS_PER_HOUR and true or false), HIGHLIGHT_FONT_COLOR);

				elseif(overtimeInfo) then
					GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(overtimeInfo.durationSec, overtimeInfo.durationSec >= SECONDS_PER_HOUR and true or false)), LIGHTGRAY_FONT_COLOR);

				end
			else
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip_AddNormalLine(GameTooltip, "This data has been pulled from RaiderIO, it may be not accurate.")
				GameTooltip_AddNormalLine(GameTooltip, "Login with this character to request official data from Blizzard.")

			end
		end
	end

	GameTooltip:Show();
end

local function raidOnEnter(self, playerGUID, mapID, difficulty, type)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, miog.MAP_INFO[mapID].name)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	if(MIOG_NewSettings.accountStatistics.characters[playerGUID].raid[mapID][type][difficulty]) then
		for k, v in ipairs(MIOG_NewSettings.accountStatistics.characters[playerGUID].raid[mapID][type][difficulty].bosses) do
			local bossInfo = v
			local criteriaString, name

			if(bossInfo.id) then
				_, name = GetAchievementInfo(bossInfo.id)

			else
				name = miog.MAP_INFO[mapID].bosses[k].name .. " kills"

			end

			if(bossInfo.criteriaID) then
				criteriaString = GetAchievementCriteriaInfoByID(bossInfo.id, bossInfo.criteriaID, true)

			else
				name = miog.MAP_INFO[mapID].bosses[k].name .. " kills"

			end

			GameTooltip:AddDoubleLine(bossInfo.quantity or 0, type == "awakened" and criteriaString .. " kills" or name)

		end

		if(not MIOG_NewSettings.accountStatistics.characters[playerGUID].raid[mapID][type][difficulty].ingame) then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddNormalLine(GameTooltip, "This data has been pulled from RaiderIO, it may be not accurate.")
			GameTooltip_AddNormalLine(GameTooltip, "Login with this character to request official data from Blizzard.")

		end
	end

	GameTooltip:Show()
end

local function round(n)
	return math.floor(n+0.5)
 end

 -- 14 untimed 290, JIT 395, 2chest 402.5, 3chest 410, 1 affix (counts)
 -- 13 untimed 290, JIT 380, 2chest 387.5, 3chest 395, 1 affix
 -- 12 untimed 290, JIT 365, 2chest 372.5, 3chest 380, 1 affix

 -- 11 untimed 290, JIT 335, 2chest 342.5, 3chest 350, 4 affixes
 -- 10 untimed 290, JIT 320, 2chest 327.5, 3chest 335, 4 affixes

 -- 9 untimed 265, JIT 295, 2chest 302.5, 3chest 310, 3 affixes
 -- 8 untimed 250, JIT 280, 2chest 287.5, 3chest 295, 3 affixes
 -- 7 untimed 235, JIT 265, 2chest 272.5, 3chest 280, 3 affixes

 -- 6 untimed 205, JIT 235, 2chest 242.5, 3chest 250, 2 affixes
 -- 5 untimed 190, JIT 220, 2chest 227.5, 3chest 235, 2 affixes
 -- 4 untimed 175, JIT 205, 2chest 212.5, 3chest 220, 2 affixes

 -- 3 untimed 150, JIT 180, 2chest 187.5, 3chest 195, 1 affix
 -- 2 untimed 135, JIT 165, 2chest 172.5, 3chest 180, 1 affix





 --  7 untimed 245, JIT 260, 2chest 267.5, 3chest 275, 3 bonus score
 
 --  6 untimed 215, JIT 230, 2chest 237.5, 3chest 245, 2 bonus score
 --  5 untimed 200, JIT 215, 2chest 222.5, 3chest 230, 2 bonus score


local function calculateMapScore(challengeMapID, info)
	local _, _, mapTimer = C_ChallengeMode.GetMapUIInfo(challengeMapID)

	if(info.durationSec > mapTimer * 1.4) then
		return 0
	end
	
	local fastestTimePossible = mapTimer * 0.6

	local timerDifference = mapTimer - (info.durationSec < fastestTimePossible and fastestTimePossible or info.durationSec)
	local overtime = timerDifference < 0

	local level = overtime and info.level > 10 and 10 or info.level
	local baseScore = 120 + level * 15

	local timerBonus = (timerDifference / (mapTimer * 0.4)) * 15
	--[[
	local affixBonus = (level > 11 and 5 or level > 9 and 4 or level > 6 and 3 or level > 3 and 2 or 1) * 10
	local extraBonus = (level > 11 and 10 or level > 6 and 5 or 0)
	]]

	local affixBonus = (level > 11 and 5 or level > 9 and 4 or level > 6 and 3 or level > 3 and 2 or 1) * 10
	local extraBonus = (level > 11 and 10 or level > 6 and 5 or 0)

	local finalScore = baseScore + timerBonus + affixBonus + extraBonus - (overtime and 15 or 0)

	return finalScore
end

miog.calculateMapScore = calculateMapScore

local function calculateNewScore(mapID, newLevel, guid, customTimer)
	local intimeInfo, overtimeInfo

	if(guid) then
		intimeInfo = MIOG_NewSettings.accountStatistics.characters[guid].mplus[mapID].intimeInfo
		overtimeInfo = MIOG_NewSettings.accountStatistics.characters[guid].mplus[mapID].overtimeInfo

		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(mapID)

		local overTimeGain, lowGain, highGain = 0, 0, 0

		local info = intimeInfo or overtimeInfo
		local dungeonScore = info and info.dungeonScore or 0
	
		overTimeGain = calculateMapScore(mapID, {level = newLevel, durationSec = customTimer < 0 and timeLimit * (1 - (customTimer / 100)) or timeLimit})
		lowGain = calculateMapScore(mapID, {level = newLevel, durationSec = timeLimit - 0.1})
		highGain = calculateMapScore(mapID, {level = newLevel, durationSec = customTimer >= 0 and timeLimit - timeLimit * (customTimer / 100) or timeLimit - 0.1})

		return max(round(overTimeGain - dungeonScore), 0), max(round(lowGain - dungeonScore), 0), max(round(highGain - dungeonScore), 0)
	end
	
	return 0, 0, 0
end


function ProgressionTabMixin:CreateDebugKeyInfo(fullName, rootDescription)
	local newKeystoneInfo = {}
	newKeystoneInfo.challengeMapID = 507
	newKeystoneInfo.level = 14
	newKeystoneInfo.mapID = 670
	newKeystoneInfo.classID = 4

	if(newKeystoneInfo and newKeystoneInfo.mapID > 0) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(newKeystoneInfo.challengeMapID)
		local className, classFile = GetClassInfo(newKeystoneInfo.classID)

		local shortName = miog.createSplitName(fullName)

		local text = WrapTextInColorCode(shortName, C_ClassColor.GetClassColor(classFile):GenerateHexColor()) .. ": " .. WrapTextInColorCode("+" .. newKeystoneInfo.level .. " " .. miog.MAP_INFO[newKeystoneInfo.mapID].shortName, miog.createCustomColorForRating(newKeystoneInfo.level * 130):GenerateHexColor())

		local keystoneButton = rootDescription:CreateRadio(text, function(fullCharacterName) return self.currentUnitName == fullCharacterName end, function(fullCharacterName)
			self.currentUnitName = fullCharacterName
			self.currentKeystoneInfo = newKeystoneInfo
	
			self:SetMPlusScoreInfo()

		end, fullName)

		keystoneButton:AddInitializer(function(button, description, menu)
			local leftTexture = button:AttachTexture();
			leftTexture:SetSize(14, 14);
			leftTexture:SetPoint("LEFT", 17, 0);
			leftTexture:SetTexture(texture);

			button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

			return button.fontString:GetUnboundedStringWidth() + 14 + 2
		end)
	end
 end

function ProgressionTabMixin:CreateDropdownEntry(fullName, rootDescription)
	--self:CreateDebugKeyInfo(fullName, rootDescription)
	local keystoneInfo = miog.getKeystoneData(fullName)

	if(keystoneInfo and keystoneInfo.mapID > 0) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)
		local className, classFile = GetClassInfo(keystoneInfo.classID)

		local shortName = miog.createSplitName(fullName)

		local text = WrapTextInColorCode(shortName, C_ClassColor.GetClassColor(classFile):GenerateHexColor()) .. ": " .. WrapTextInColorCode("+" .. keystoneInfo.level .. " " .. miog.MAP_INFO[keystoneInfo.mapID].shortName, miog.createCustomColorForRating(keystoneInfo.level * 130):GenerateHexColor())

		local keystoneButton = rootDescription:CreateRadio(text, function(fullCharacterName) return self.currentUnitName == fullCharacterName end, function(fullCharacterName)
			self.currentUnitName = fullCharacterName
			self.currentKeystoneInfo = keystoneInfo
	
			self:SetMPlusScoreInfo()

		end, fullName)

		keystoneButton:AddInitializer(function(button, description, menu)
			local leftTexture = button:AttachTexture();
			leftTexture:SetSize(14, 14);
			leftTexture:SetPoint("LEFT", 17, 0);
			leftTexture:SetTexture(texture);

			button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

			return button.fontString:GetUnboundedStringWidth() + 14 + 2
		end)
	end
end

function ProgressionTabMixin:StartScoreCalculationForCharacter(frame, guid)
	if(frame) then
		if(self.currentKeystoneInfo and (guid == UnitGUID("player") or self.currentUnitName ~= miog.createFullNameFrom("unitID", "player"))) then
			local overtimeScore, minScore, maxScore = calculateNewScore(self.currentKeystoneInfo.challengeMapID, self.currentKeystoneInfo.level, guid, self.Info.TimelimitSlider:GetValue())
			frame.ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
			frame.ScoreIncrease:Show()

		else
			frame.ScoreIncrease:SetText("")
			frame.ScoreIncrease:Hide()

		end
	end
end

function ProgressionTabMixin:StartScoreCalculationForAllCharacters()
	for k, v in self.Rows:EnumerateFrames() do
		self:StartScoreCalculationForCharacter(v, v:Getdata().guid)

	end
end

function ProgressionTabMixin:FindFrameWithMatchingDataElement(scrollList, element, value)
	for k, v in scrollList:EnumerateFrames() do
		if(v:Getdata()[element] == value) then
			return v

		end
	end
end

function ProgressionTabMixin:ShowMapIDSelectionFrame()
	if(self.currentKeystoneInfo) then
		local columnFrame

		for k, v in self.Columns:EnumerateFrames() do
			if(v:Getdata().mapID == self.currentKeystoneInfo.mapID) then
				columnFrame = v

			end
		end

		if(columnFrame) then
			if(self.lastColumnFrame) then
				self.lastColumnFrame.TransparentDark:Show()
			end

			self.lastColumnFrame = columnFrame

			self.lastColumnFrame.TransparentDark:Hide()

			self.Selection:ClearAllPoints()
			self.Selection:SetPoint("TOPLEFT", columnFrame, "TOPLEFT")
			self.Selection:SetPoint("BOTTOMRIGHT", columnFrame, "BOTTOMRIGHT")
			self.Selection:Show()

		else
			self.Selection:Hide()

		end
	end
end

function ProgressionTabMixin:SetMPlusScoreInfo()
	self:ShowMapIDSelectionFrame()

	if(self.currentUnitName == miog.createFullNameFrom("unitID", "player")) then
		local frame = self:FindFrameWithMatchingDataElement(self.Rows, "guid", UnitGUID("player"))

		self:StartScoreCalculationForCharacter(frame, UnitGUID("player"))

	else
		self:StartScoreCalculationForAllCharacters()

	end
end

function ProgressionTabMixin:VisibilitySelected(type, index)
    return self.mainSettings.progressActivityVisibility[type][index] ~= false

end

function ProgressionTabMixin:GatherActivitiesForDataProvider()
    local activityProvider = CreateDataProvider()

    if(self.type == "mplus" or self.type == "all") then --M+
		mythicPlusActivities = C_ChallengeMode.GetMapTable()

        table.sort(mythicPlusActivities, function(k1, k2)
            return miog.retrieveShortNameFromChallengeModeMap(k1) < miog.retrieveShortNameFromChallengeModeMap(k2)

        end)

        for _, activityEntry in ipairs(mythicPlusActivities) do
            if(self:VisibilitySelected(self.type, activityEntry)) then
                activityProvider:Insert({mapID = miog.retrieveMapIDFromChallengeModeMap(activityEntry), index = activityEntry});

            end
        end
    end

	if(self.type == "raid" or self.type == "all") then --RAID
		raidActivities = {}

		for k, v in ipairs(C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion) or Enum.LFGListFilter.Recommended)) do
			local activities = C_LFGList.GetAvailableActivities(3, v)
			local activityID = activities[#activities]
			local name, order = C_LFGList.GetActivityGroupInfo(v)
            local activityInfo = miog.requestActivityInfo(activityID)
			local mapID = activityInfo.mapID

            miog.checkSingleMapIDForNewData(mapID, true)
            miog.checkForMapAchievements(mapID)

			tinsert(raidActivities, {name = name, order = order, activityID = activityID, mapID = mapID})
		end

		table.sort(raidActivities, function(k1, k2)
			if(k1.order == k2.order) then
				return k1.activityID > k2.activityID

			end

			return k1.order < k2.order
		end)

        for _, info in ipairs(raidActivities) do
			local mapID = info.mapID

            if(self:VisibilitySelected(self.type, mapID)) then
                activityProvider:Insert({mapID = mapID, index = mapID});

            end

        end
    end
    
    if(self.type == "pvp" or self.type == "all") then --PVP
        for _, id in ipairs(pvpActivities) do
            if(self:VisibilitySelected(self.type, id)) then
                activityProvider:Insert({id = id});

            end

        end
    end

    return activityProvider
end

function ProgressionTabMixin:PopulateActivities()
	local activityProvider = self:GatherActivitiesForDataProvider()

	if(self.type ~= "all") then
		self.currentActivities = self.type == "mplus" and mythicPlusActivities or self.type == "raid" and raidActivities or pvpActivities

		local activityView = self.Columns:GetView()
		
		activityView:SetElementExtent(400 / activityProvider:GetSize())
		self.Columns:SetDataProvider(activityProvider)

		self.Info.VisibilityDropdown:SetDefaultText("Change activity visibility")
        self.Info.VisibilityDropdown:SetupMenu(function(dropdown, rootDescription)
            for k, v in ipairs(self.currentActivities) do
                local shortName
				local value

                if(self.type == "pvp") then
                    local bracketInfo = miog.PVP_BRACKET_IDS_TO_INFO[v]
    
                    if(bracketInfo) then
                        shortName = bracketInfo.shortName
                    end

					value = v

                elseif(self.type == "raid") then
                    local mapInfo = miog.MAP_INFO[v.mapID]

                    if(mapInfo) then
                        shortName = mapInfo.shortName
                    end

					value = v.mapID

                elseif(self.type == "mplus") then
                    local mapInfo = miog.MAP_INFO[miog.retrieveMapIDFromChallengeModeMap(v)]

                    if(mapInfo) then
                        shortName = mapInfo.shortName

                    end

					value = v
                end

                rootDescription:CreateCheckbox(shortName,
                    function(index)
                        return self.mainSettings.progressActivityVisibility[self.type][index] ~= false
                    end,
                    function(index)
                        self.mainSettings.progressActivityVisibility[self.type][index] = not self:VisibilitySelected(self.type, index)
                        local dp = self:GatherActivitiesForDataProvider()
                        activityView:SetElementExtent(400 / dp:GetSize())
                        activityView:SetDataProvider(dp)

						self:PopulateViews()
						
						self:ShowMapIDSelectionFrame()
                    end, value)
            end
        end)
	end
end

function ProgressionTabMixin:OnLoad(type, tempSettings)
    self.type = type
	self.template = type == "mplus" and "MIOG_ProgressDungeonCharacterTemplate" or type == "raid" and "MIOG_ProgressRaidCharacterTemplate" or type == "pvp" and "MIOG_ProgressPVPCharacterTemplate" or "MIOG_ProgressionVerticalCharacterTemplate"
    self.mainSettings = tempSettings
    self.settings = tempSettings.accountStatistics.characters

    self.mainSettings.progressActivityVisibility[self.type] = self.mainSettings.progressActivityVisibility[self.type] or {}

    RequestRaidInfo()

    playerGUID = UnitGUID("player")

    if(self.type == "all") then
		self:RegisterEvent("WEEKLY_REWARDS_UPDATE")
		self:SetScript("OnEvent", function(localSelf, event, ...)
			if(event == "WEEKLY_REWARDS_UPDATE") then
				self:UpdateSaveData()
		
			end
		end)

		self.Columns:SetHorizontal(true)

        local horizontalView = CreateScrollBoxListLinearView();
		horizontalView:SetHorizontal(true)
		horizontalView:SetElementInitializer(self.template, function(frame, data)
            local classID = miog.CLASSFILE_TO_ID[data.classFile]
			local color = C_ClassColor.GetClassColor(data.classFile)

			frame.Class.Icon:SetTexture(miog.CLASSES[classID].icon)
			frame.Spec.Icon:SetTexture(data.spec and miog.SPECIALIZATIONS[data.spec].squaredIcon or miog.SPECIALIZATIONS[0].squaredIcon)
			frame.Name:SetText(data.name)

			frame.MPlusRating:SetText(string.format(miog.STRING_REPLACEMENTS["MPLUSRATINGSHORT"], data.score.value))
			frame.MPlusRating:SetTextColor(miog.createCustomColorForRating(data.score.value):GetRGBA())

			if(raidActivities[1]) then
				local mapID = raidActivities[1].mapID
				local mapInfo = miog.getMapInfo(mapID, true)
				local numBosses = #mapInfo.bosses

				for i = 1, 3, 1 do
					local raidProgressFrame = frame["RaidProgress" .. i]
					raidProgressFrame:SetText(string.format(miog.STRING_REPLACEMENTS["RAIDPROGRESS" .. i .. "SHORT"], (data.progress[mapID] and data.progress[mapID].regular and data.progress[mapID].regular[i] and data.progress[mapID].regular[i].kills or 0) .. "/" .. numBosses))
					raidProgressFrame:SetTextColor(miog.DIFFICULTY[i].miogColors:GetRGBA())

				end
				--end

				frame.Itemlevel:SetText(string.format(miog.STRING_REPLACEMENTS["ILVLSHORT"], miog.round(data.ilvl, 2)))

				frame.Honor:SetText("Honorlevel: " .. data.honor.level)

				frame.GuildBannerBackground:SetVertexColor(color:GetRGB())
				frame.GuildBannerBorder:SetVertexColor(color.r * 0.65, color.g * 0.65, color.b * 0.65)

				if(data.nextRewards.availableTimestamp) then
					if(data.nextRewards.availableTimestamp < time()) then
						frame.VaultStatus:SetAtlas("mythicplus-dragonflight-greatvault-collect")
						frame.VaultStatus.tooltipText = MYTHIC_PLUS_COLLECT_GREAT_VAULT
					
					elseif(MIOG_NewSettings.accountStatistics.characters[data.guid].vaultProgress[self.id == 2 and 3 or 1]) then
						frame.VaultStatus:SetAtlas("mythicplus-dragonflight-greatvault-complete")
						frame.VaultStatus.tooltipText = "Your weekly rewards in your great vault will be available in " .. SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset(), true) .. "."

					else
						frame.VaultStatus:SetAtlas("mythicplus-dragonflight-greatvault-incomplete")
						frame.VaultStatus.tooltipText = "You have no activity in this category completed."

					end
				else
					frame.VaultStatus:SetAtlas("mythicplus-dragonflight-greatvault-incomplete")
					frame.VaultStatus.tooltipText = "No great vault activity yet completed."
					
				end

				if(data.vaultProgress) then
					GameTooltip:SetOwner(frame.VaultStatus, "ANCHOR_RIGHT")

					for k, v in ipairs(activityIndices) do
						local activities = data.vaultProgress[v]

						local currentFrame = k == 1 and frame.MPlusStatus or k == 2 and frame.RaidStatus or k == 3 and frame.WorldStatus

						if(activities) then
							currentFrame.frameType = "progress"

							currentFrame:SetInfo(activities)

							local farthestActivity = currentFrame:GetFarthestActivity(true)
							currentFrame:SetMinMaxValues(0, farthestActivity.threshold)
							currentFrame:SetValue(farthestActivity.progress)

							local numOfCompletedActivities = currentFrame:GetNumOfCompletedActivities()

							local currentColor = numOfCompletedActivities == 3 and miog.CLRSCC.green or numOfCompletedActivities == 2 and miog.CLRSCC.yellow or numOfCompletedActivities == 1 and miog.CLRSCC.orange or miog.CLRSCC.red
							local dimColor = {CreateColorFromHexString(currentColor):GetRGB()}
							dimColor[4] = 0.1
								
							currentFrame:SetStatusBarColor(CreateColorFromHexString(currentColor):GetRGBA())
							miog.createFrameWithBackgroundAndBorder(currentFrame, 1, unpack(dimColor))

							currentFrame.Text:SetText((activities[3].progress <= activities[3].threshold and activities[3].progress or activities[3].threshold) .. "/" .. activities[3].threshold)
							currentFrame.Text:SetTextColor(CreateColorFromHexString(numOfCompletedActivities == 0 and currentColor or "FFFFFFFF"):GetRGBA())

						else
							currentFrame:SetMinMaxValues(0, 0)
							currentFrame:SetValue(0)
							currentFrame:SetStatusBarColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
							currentFrame.Text:SetText("0/0")
							currentFrame.Text:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())

						end
					end

					local pvpFrame = frame.PVPStatus
					pvpFrame.frameType = "progress"

					local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID);
					local maxProgress = currencyInfo.maxQuantity;
					local progress = math.min(currencyInfo.totalEarned, maxProgress);
					local percentage = progress / maxProgress * 100
					local currentColor = percentage >= 100 and miog.CLRSCC.green or percentage >= 66 and miog.CLRSCC.yellow or percentage >= 33 and miog.CLRSCC.orange or miog.CLRSCC.red
					local dimColor = {CreateColorFromHexString(currentColor):GetRGB()}
					dimColor[4] = 0.1
						
					pvpFrame:SetStatusBarColor(CreateColorFromHexString(currentColor):GetRGBA())
					miog.createFrameWithBackgroundAndBorder(pvpFrame, 1, unpack(dimColor))

					pvpFrame:SetMinMaxValues(0, maxProgress)
					pvpFrame:SetValue(progress)
					pvpFrame.Text:SetText(progress .. "/" .. maxProgress)
					pvpFrame.Text:SetTextColor(CreateColorFromHexString(percentage == 0 and currentColor or "FFFFFFFF"):GetRGBA())

				else
					for k, v in ipairs(activityIndices) do
						local currentFrame = k == 1 and frame.MPlusStatus or k == 2 and frame.RaidStatus or frame.WorldStatus

						currentFrame:SetMinMaxValues(0, 0)
						currentFrame:SetValue(0)
						currentFrame:SetStatusBarColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
						currentFrame.Text:SetText("0/0")
						currentFrame.Text:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())

					end

					local pvpFrame = frame.PVPStatus
					pvpFrame:SetMinMaxValues(0, 0)
					pvpFrame:SetValue(0)
					pvpFrame:SetStatusBarColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
					pvpFrame.Text:SetText("0/0")
					pvpFrame.Text:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
				end

				frame.VaultStatus:Show()

				local view = CreateScrollBoxListLinearView();
				view:SetElementInitializer("MIOG_LockoutCheckInstanceTemplate", function(elementFrame, data)
					if(not data.isWorldBoss) then
						elementFrame.Name:SetText(miog.MAP_INFO[data.mapID].shortName or data.name)
						elementFrame.Icon:SetTexture(data.icon)
						elementFrame.Difficulty:SetText(WrapTextInColorCode(miog.DIFFICULTY_ID_INFO[data.difficulty].shortName, miog.DIFFICULTY_ID_TO_COLOR[data.difficulty]:GenerateHexColor()))
						elementFrame.Checkmark:SetShown(data.cleared)
			
						elementFrame:SetScript("OnEnter", function(localSelf)
							RequestRaidInfo()

							GameTooltip:SetOwner(localSelf, "ANCHOR_RIGHT")
							GameTooltip:SetText(miog.MAP_INFO[data.mapID].name)
							GameTooltip:AddLine(string.format(DUNGEON_DIFFICULTY_BANNER_TOOLTIP, miog.DIFFICULTY_ID_INFO[data.difficulty].name))
							GameTooltip:AddLine(string.format(data.extended and RAID_INSTANCE_EXPIRES_EXTENDED or RAID_INSTANCE_EXPIRES, formatter:Format(data.resetDate - time()) .. " (" .. date("%x %X", data.resetDate) .. ")"))

							local setAliveEncounters, setDefeatedEncounters = false, false

							for i = 1, data.numEncounters, 1 do
								local isKilled = data.bosses[i].isKilled
								local bossName = data.bosses[i].bossName

								if(not isKilled) then
									if(not setAliveEncounters) then
										GameTooltip_AddBlankLineToTooltip(GameTooltip)
										GameTooltip:AddLine("Encounters available: ")
										setAliveEncounters = true
										
									end

									GameTooltip:AddLine(WrapTextInColorCode(isKilled and "Defeated " or "Alive ", isKilled and miog.CLRSCC.red or miog.CLRSCC.green) ..  bossName)

								end
							end

							for i = 1, data.numEncounters, 1 do
								local isKilled = data.bosses[i].isKilled
								local bossName = data.bosses[i].bossName
								--local bossName, fileDataID, isKilled, unknown4 = GetSavedInstanceEncounterInfo(index, i)

								if(isKilled) then
									if(not setDefeatedEncounters) then
										GameTooltip_AddBlankLineToTooltip(GameTooltip)
										GameTooltip:AddLine("Encounters defeated: ")
										setDefeatedEncounters = true
										
									end

									GameTooltip:AddLine(WrapTextInColorCode(isKilled and "Defeated " or "Alive ", isKilled and miog.CLRSCC.red or miog.CLRSCC.green) ..  bossName)
								end
							end
			
							GameTooltip:Show()
						end)
					elseif(MIOG_NOTDISABLED) then
						elementFrame.Name:SetText("OWB")
						elementFrame:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

							GameTooltip:SetText(data.name)
							GameTooltip:AddLine("World Boss")
							GameTooltip:AddLine(string.format(data.extended and RAID_INSTANCE_EXPIRES_EXTENDED or RAID_INSTANCE_EXPIRES, formatter:Format(data.resetDate - time()) .. " (" .. date("%x %X", data.resetDate) .. ")"))

							GameTooltip:Show()
						end)

					end

					elementFrame:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)
				end);
				
				view:SetPadding(1, 1, 1, 1, 2);

				frame.ScrollBox:Init(view);

				local dataProvider = CreateDataProvider();
				
				if(MIOG_NewSettings.lockoutCheck[data.fullName]) then
					local settings = MIOG_NewSettings.lockoutCheck[data.fullName]

					for a, b in ipairs(settings) do
						dataProvider:Insert(b);

					end

					frame.ScrollBox:SetDataProvider(dataProvider);
				end
			end
        end)

		horizontalView:SetPadding(1, 1, 1, 1, 7);
        horizontalView:SetElementExtent(100)

		ScrollUtil.InitScrollBoxListWithScrollBar(self.Columns, self.ScrollBar, horizontalView);
        self.horizontalView = horizontalView
    else
		miog.createFrameBorder(self.Selection, 1, CreateColorFromHexString(miog.CLRSCC.silver):GetRGBA())
	
		local activityView = CreateScrollBoxListLinearView();
		activityView:SetHorizontal(true)
		activityView:SetElementInitializer("MIOG_ProgressColumnTemplate", function(frame, data)
			local shortName

            if(self.type == "pvp") then
                local bracketInfo = miog.PVP_BRACKET_IDS_TO_INFO[data.id]

                if(bracketInfo) then
                    shortName = bracketInfo.shortName

                    frame.Background:SetTexture(bracketInfo.vertical, "MIRROR", "MIRROR")
                end

            else
                local mapInfo = miog.MAP_INFO[data.mapID]
                shortName = mapInfo.shortName

                frame.Background:SetTexture(mapInfo.vertical, "MIRROR", "MIRROR")

            end

            frame.Name:SetText(shortName)

            miog.createFrameBorder(frame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
		end)
        
		activityView:SetPadding(1, 1, 1, 1, 2);
		self.Columns:Init(activityView);
		
		self:PopulateActivities()

		local characterView = CreateScrollBoxListLinearView();

		characterView:SetElementInitializer(self.template, function(frame, data)
			frame.Name:SetText(data.name)
			frame.Name:SetTextColor(C_ClassColor.GetClassColor(data.classFile):GetRGBA())

			local isRaid = data.type == "raid"
			local isDungeon = data.type == "mplus"
			local isPvp = data.type == "pvp"

			local file, height, flags = _G["GameFontHighlight"]:GetFont()

			if(data.guid == UnitGUID("player")) then
				frame.Name:SetFont(file, height + 2, flags)

				if(isDungeon) then
					frame.Score:SetFont(file, height + 2, flags)
					frame.ScoreIncrease:SetFont(file, height + 2, flags)

				elseif(isPvp) then
					frame.HonorLevel:SetFont(file, height + 2, flags)
					frame.HonorProgress:SetFont(file, height + 2, flags)

				elseif(isAll) then
					frame.Score:SetFont(file, height + 2, flags)

				end
			else
				frame.Name:SetFont(file, height, flags)

				if(isDungeon) then
					frame.Score:SetFont(file, height, flags)
					frame.ScoreIncrease:SetFont(file, height, flags)

				elseif(isPvp) then
					frame.HonorLevel:SetFont(file, height, flags)
					frame.HonorProgress:SetFont(file, height, flags)

				elseif(isAll) then
					frame.Score:SetFont(file, height, flags)

				end
			end
			
			if(self.type ~= "pvp") then
				if(MIOG_NewSettings.accountStatistics.characters[data.guid].nextRewards.availableTimestamp) then
					if(MIOG_NewSettings.accountStatistics.characters[data.guid].nextRewards.availableTimestamp < time()) then
						frame.VaultStatus:SetAtlas("gficon-chest-evergreen-greatvault-collect")
						frame.VaultStatus.tooltipText = MYTHIC_PLUS_COLLECT_GREAT_VAULT
					
					elseif(MIOG_NewSettings.accountStatistics.characters[data.guid].vaultProgress[self.id == 2 and 3 or 1]) then
						frame.VaultStatus:SetAtlas("gficon-chest-evergreen-greatvault-complete")
						frame.VaultStatus.tooltipText = "Your weekly rewards in your great vault will be available in " .. SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset(), true) .. "."

					else
						frame.VaultStatus:SetAtlas("gficon-chest-evergreen-greatvault-incomplete")
						frame.VaultStatus.tooltipText = "You have no activity in this category completed."

					end
				else
					frame.VaultStatus:SetAtlas("gficon-chest-evergreen-greatvault-incomplete")
					frame.VaultStatus.tooltipText = "No great vault activity yet completed."
					
				end

				frame.VaultStatus:Show()

			else
				frame.HonorLevel:SetText(data.honor.level)
				frame.HonorProgress:SetText(data.honor.current .. "/" .. data.honor.maximum)
				
				frame.VaultStatus:Hide()
				
			end

			if(isDungeon) then
				frame.Score:SetText(data.score.value)

				self:StartScoreCalculationForCharacter(frame, data.guid)

				if(data.score.ingame) then
					frame.Score:SetTextColor(miog.createCustomColorForRating(data.score.value):GetRGBA())
					frame.Score:SetScript("OnEnter", nil)
					frame.Score:SetScript("OnLeave", nil)

				else
					frame.Score:SetTextColor(CreateColorFromHexString(miog.CLRSCC.yellow):GetRGBA())
					frame.Score:SetScript("OnEnter", function(selfFrame)
						GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
						GameTooltip:SetText("This data has been pulled from RaiderIO, it may be not accurate.")
						GameTooltip:AddLine("Login with this character to request official data from Blizzard.")
						GameTooltip:Show()
					end)

					frame.Score:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)

				end

				local counter = 1

				for index, challengeMapID in ipairs(self.currentActivities) do
					local isVisible = self:VisibilitySelected(self.type, challengeMapID)

					local dungeonFrame = frame["Dungeon" .. index]

					if(isVisible) then
						dungeonFrame:SetWidth(self.Columns:GetView():GetElementExtent())
						dungeonFrame:SetHeight(frame:GetHeight())

						dungeonFrame.challengeMapID = challengeMapID
						dungeonFrame.layoutIndex = counter

						local intimeInfo = MIOG_NewSettings.accountStatistics.characters[data.guid].mplus[challengeMapID].intimeInfo
						local overtimeInfo = MIOG_NewSettings.accountStatistics.characters[data.guid].mplus[challengeMapID].overtimeInfo

						local overtimeHigher = intimeInfo and overtimeInfo and intimeInfo.dungeonScore and overtimeInfo.dungeonScore and overtimeInfo.dungeonScore > intimeInfo.dungeonScore and true or false

						dungeonFrame.Level:SetText(overtimeHigher and overtimeInfo.level or intimeInfo and intimeInfo.level or 0)
						dungeonFrame.Level:SetTextColor(CreateColorFromHexString(overtimeHigher and overtimeInfo.level and miog.CLRSCC.red or intimeInfo and intimeInfo.level and miog.CLRSCC.green or miog.CLRSCC.gray):GetRGBA())
						dungeonFrame:SetScript("OnEnter", function(selfFrame)
							mplusOnEnter(selfFrame, data.guid)

						end) -- ChallengesDungeonIconMixin:OnEnter()

						dungeonFrame:Show()

						counter = counter + 1

					else
						dungeonFrame:Hide()
						dungeonFrame.layoutIndex = nil

					end
				end
			elseif(isRaid) then
				local counter = 1

				for index, info in ipairs(self.currentActivities) do
					local mapID = info.mapID

					local isVisible = self:VisibilitySelected(self.type, mapID)
					local raidFrame = frame["Raid" .. index]

					if(isVisible) then
						raidFrame:SetWidth(self.Columns:GetView():GetElementExtent())
						raidFrame:SetHeight(frame:GetHeight())
						raidFrame.layoutIndex = counter

						for a = 1, 3, 1 do
							local current = a == 1 and raidFrame.Normal.Current or a == 2 and raidFrame.Heroic.Current or a == 3 and raidFrame.Mythic.Current
							--local previous = a == 1 and raidFrame.Normal.Previous or a == 2 and raidFrame.Heroic.Previous or a == 3 and raidFrame.Mythic.Previous

							if(current) then -- and previous
								local currentProgress = MIOG_NewSettings.accountStatistics.characters[data.guid].raid[mapID].regular[a]

								local text2 = (currentProgress and currentProgress.kills or 0) .. "/" .. #miog.MAP_INFO[mapID].bosses
								current:SetText(WrapTextInColorCode(text2, currentProgress and miog.DIFFICULTY[a].color or miog.CLRSCC.gray))

								current:SetScript("OnEnter", function(selfFrame)
									raidOnEnter(selfFrame, data.guid, mapID, a, "regular")
								end)

								current:SetScript("OnLeave", function()
									GameTooltip:Hide()
								end)

								--[[if(previous) then
									local previousProgress = MIOG_NewSettings.raidStats[playerGUID].raid[mapID].regular[a]
									local text = (previousProgress and previousProgress.kills or 0) .. "/" .. #miog.MAP_INFO[mapID].bosses
									previous:SetText(WrapTextInColorCode(text, miog.DIFFICULTY[a].desaturated))
									previous:Show()
								end
				
								previous:SetScript("OnEnter", function(self)
									raidFrame_OnEnter(self, playerGUID, mapID, a, "regular")
								end)
				
								previous:SetScript("OnLeave", function()
									GameTooltip:Hide()
								end)]]
							end
						end

						counter = counter + 1
						raidFrame:Show()

					else
						raidFrame:Hide()
						raidFrame.layoutIndex = nil

					end
				end
			elseif(isPvp) then
				if(MIOG_NewSettings.accountStatistics.characters[data.guid].tierInfo[1]) then
					local tierInfo = C_PvP.GetPvpTierInfo(MIOG_NewSettings.accountStatistics.characters[data.guid].tierInfo[1])

					frame.Rank:SetTexture(tierInfo.tierIconID)
					frame.Rank:SetScript("OnEnter", function(selfFrame)
						pvpOnEnter(selfFrame, MIOG_NewSettings.accountStatistics.characters[data.guid].tierInfo)

					end)

					frame.Rank:SetScript("OnLeave", function()
						GameTooltip:Hide()

					end)

				end

				local ratingAbove0 = false
				
				local counter = 1

				for index, id in ipairs(self.currentActivities) do
					local isVisible = self:VisibilitySelected(self.type, index)
					local bracketFrame = frame["Bracket" .. index]

					if(isVisible) then
						bracketFrame:SetWidth(self.Columns:GetView():GetElementExtent())
						bracketFrame:SetHeight(frame:GetHeight())
						bracketFrame.layoutIndex = counter

						local rating
						local seasonBest

						if(MIOG_NewSettings.accountStatistics.characters[data.guid].brackets[id]) then
							rating = MIOG_NewSettings.accountStatistics.characters[data.guid].brackets[id].rating
							seasonBest = MIOG_NewSettings.accountStatistics.characters[data.guid].brackets[id].seasonBest

						else
							rating = 0
							seasonBest = 0

						end

						if(rating > 0) then
							ratingAbove0 = true
						end

						bracketFrame.Level1:SetText(rating)
						bracketFrame.Level1:SetTextColor(CreateColorFromHexString(rating == 0 and miog.CLRSCC.gray or miog.CLRSCC.yellow):GetRGBA())

						local desaturatedColors = CreateColorFromHexString(seasonBest == 0 and miog.CLRSCC.gray or miog.CLRSCC.yellow)

						bracketFrame.Level2:SetText(seasonBest or 0)
						bracketFrame.Level2:SetTextColor(desaturatedColors.r * 0.6, desaturatedColors.g * 0.6, desaturatedColors.b * 0.6, 1)

						bracketFrame:Show()

						counter = counter + 1
					else
						bracketFrame:Hide()
						bracketFrame.layoutIndex = nil

					end

				end

				frame.Rank:SetShown(ratingAbove0)
			end

			frame:MarkDirty()

			characterView:RecalculateExtent(self.Rows)
		end)

		characterView:SetPadding(1, 1, 1, 1, 4)

		ScrollUtil.InitScrollBoxListWithScrollBar(self.Rows, self.RowsScrollBar, characterView);

		if(self.type == "mplus") then
			self.Info.KeystoneDropdown:SetDefaultText("Keystones")
			self.Info.KeystoneDropdown:SetupMenu(function(dropdown, rootDescription)
				local numGroupMembers = GetNumGroupMembers()

				if(numGroupMembers > 0) then
					for groupIndex = 1, numGroupMembers, 1 do
						local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

						--[[local unitID

						if(IsInRaid()) then
							unitID = "raid" .. groupIndex
						else
							if groupIndex == 1 then
								unitID = "player";

							else
								unitID = "party"..(groupIndex - 1);

							end
						end]]

						local playerName, realm = miog.createSplitName(name)
						local fullName = playerName .. "-" .. (realm or "")

						self:CreateDropdownEntry(fullName, rootDescription)
					end
				else
					local fullPlayerName = miog.createFullNameFrom("unitID", "player")
					self:CreateDropdownEntry(fullPlayerName, rootDescription)

				end
			end)

			self.Info.TimelimitSlider:SetScript("OnValueChanged", function(selfSlider)
				self.Info.TimePercentage:SetText(round((selfSlider:GetValue() * -1)) .. "%")
		
				self:SetMPlusScoreInfo()
			end)
		else
			self.Info.KeystoneDropdown:Hide()
			self.Info.TimelimitSlider:Hide()
			self.Info.TimePercentage:Hide()

		end
    end
end

local fullPlayerName

local function checkEntriesForExpiration()
    for k, v in pairs(MIOG_NewSettings.lockoutCheck) do
        for a, b in ipairs(v) do
            if(b.resetDate <= time()) then
                MIOG_NewSettings.lockoutCheck[k][a] = nil

            end
        end
    end
end

local function refreshCharacterInfo()
    MIOG_NewSettings.lockoutCheck[fullPlayerName] = {class = UnitClassBase("player")}
    
    for index = 1, GetNumSavedInstances(), 1 do
        local name, lockoutId, reset, difficultyId, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId = GetSavedInstanceInfo(index)

        if(lockoutId > 0 and reset > 0) then
            local allBossesAlive = true
            local bosses = {}

            for i = 1, numEncounters, 1 do
                local bossName, fileDataID, isKilled, unknown4 = GetSavedInstanceEncounterInfo(index, i)

                bosses[i] = {bossName = bossName, isKilled = isKilled}

                if(isKilled) then
                    allBossesAlive = false
                end
            end

            if(not allBossesAlive) then
                tinsert(MIOG_NewSettings.lockoutCheck[fullPlayerName], {
                    id = lockoutId,
                    name = name,
                    difficulty = difficultyId,
                    extended = extended,
                    isRaid = isRaid,
                    icon = miog.MAP_INFO[instanceId].icon,
                    mapID = instanceId,
                    index = index,
                    numEncounters = numEncounters,
                    cleared = numEncounters == encounterProgress,
                    resetDate = time() + reset,
                    bosses = bosses
                })
            end
        end
    end
    
    for i = 1, GetNumSavedWorldBosses(), 1 do
        local name, worldBossID, reset = GetSavedWorldBossInfo(i)

        tinsert(MIOG_NewSettings.lockoutCheck[fullPlayerName], {
            id = worldBossID,
            name = name,
            isWorldBoss = true,
            resetDate = time() + reset,
        })
    end
end

hooksecurefunc("RequestRaidInfo", function()
    fullPlayerName = miog.createFullNameFrom("unitID", "player")

    if(fullPlayerName) then
        refreshCharacterInfo()
        
    end
end)

function ProgressionTabMixin:UpdateLockoutData()
    RequestRaidInfo()

	checkEntriesForExpiration()

	--[[
	table.sort(MIOG_NewSettings.lockoutCheck[fullPlayerName], function(k1, k2)
		if(k1.isRaid == k2.isRaid) then
			if(miog.MAP_INFO[k1.mapID].shortName == miog.MAP_INFO[k2.mapID].shortName) then
				return miog.DIFFICULTY_ID_INFO[k1.difficulty].customDifficultyOrderIndex > miog.DIFFICULTY_ID_INFO[k2.difficulty].customDifficultyOrderIndex

			end

			return miog.MAP_INFO[k1.mapID].shortName < miog.MAP_INFO[k2.mapID].shortName

		end

		return k1.isRaid ~= k2.isRaid
	end)

	local columnProvider = CreateDataProvider();

	local orderedCharacterTable = {}

	for k, v in pairs(MIOG_NewSettings.lockoutCheck) do
		if(#v > 0) then
			tinsert(orderedCharacterTable, k)

		else
			MIOG_NewSettings.lockoutCheck[k] = nil

		end
	end

	table.sort(orderedCharacterTable, function(k1, k2)
		return k1 < k2
	end)

	for k, v in ipairs(orderedCharacterTable) do
		columnProvider:Insert({name = v, settings = MIOG_NewSettings.lockoutCheck[v]});
		
	end

	lockoutCheck.Columns:SetDataProvider(columnProvider);]]
end

function ProgressionTabMixin:OnShow()
	self:UpdateLockoutData()
	self:PopulateActivities()

	if(self.type == "all") then
        self:UpdateAllData()

    elseif(self.type == "mplus") then
        self:UpdateMythicPlusProgress()

    elseif(self.type == "raid") then
        self:UpdateRaidProgress()

    elseif(self.type == "pvp") then
        self:UpdatePVPProgress()

    end

	self:PopulateViews()
end

function ProgressionTabMixin:RequestAccountCharacter()
    C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
	
	accountCharacters = {}
	local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(playerGUID)
	local specID = GetSpecializationInfo(GetSpecialization())
	accountCharacters[playerGUID] = {name = name, realm = realmName, classFile = englishClass, spec = specID}

	local charList = {}

	for currencyID in pairs(miog.RAW["Currency"]) do
		local accountCurrencyData = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID)

		if(accountCurrencyData) then
			for k, v in pairs(accountCurrencyData) do
				charList[v.characterGUID] = true

			end
		end

	end

	for k, v in pairs(charList) do
		localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(k)

		accountCharacters[k] = {name = name, realm = realmName, classFile = englishClass}
	end
end

function HasRewardsComingReset()
	for i, activityInfo in ipairs(C_WeeklyRewards.GetActivities()) do
		if(activityInfo.progress >= activityInfo.threshold) then
			return true
		end
	end

	return false
end

function ProgressionTabMixin:AddWeeklyProgress()
	local hasRewardComing = HasRewardsComingReset()

	self.settings[playerGUID].vaultProgress = {}

	self.settings[playerGUID].nextRewards = {
		hasRewardComingReset = hasRewardComing,
		rewardsForCurrentPeriod = C_WeeklyRewards.AreRewardsForCurrentRewardPeriod(),
		hasAvailableRewards = C_WeeklyRewards.HasAvailableRewards(),
		hasGeneratedRewards = C_WeeklyRewards.HasGeneratedRewards(),
		canClaimRewards = C_WeeklyRewards.CanClaimRewards(),
		availableTimestamp = hasRewardComing and (time() + C_DateAndTime.GetSecondsUntilWeeklyReset()) or nil
	}

	local exampleLinks = {}

	for i, activityInfo in ipairs(C_WeeklyRewards.GetActivities()) do
		self.settings[playerGUID].vaultProgress[activityInfo.type] = self.settings[playerGUID].vaultProgress[activityInfo.type] or {}
		activityInfo.raidEncounterInfo = {}

		if(activityInfo.type == Enum.WeeklyRewardChestThresholdType.Activities) then
			local runHistory = C_MythicPlus.GetRunHistory(false, true);

			activityInfo.runHistory = runHistory
		
		elseif(activityInfo.type == Enum.WeeklyRewardChestThresholdType.Raid) then
			local encounters = C_WeeklyRewards.GetActivityEncounterInfo(activityInfo.type, activityInfo.index);

			activityInfo.raidEncounterInfo[activityInfo.index] = encounters

		end

		exampleLinks[activityInfo.type] = exampleLinks[activityInfo.type] or {}

		local item, upgrade = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activityInfo.id)

		exampleLinks[activityInfo.type][activityInfo.id] = {item = item, upgrade = upgrade}

		activityInfo.hasRewards = C_WeeklyRewards.HasAvailableRewards()

		tinsert(self.settings[playerGUID].vaultProgress[activityInfo.type], activityInfo)
	end

	self.settings[playerGUID].vaultProgress[2] = C_WeeklyRewards.GetConquestWeeklyProgress()
	

	for k, v in ipairs(activityIndices) do
		local progress = self.settings[playerGUID].vaultProgress[v]

		for i = 1, 3, 1 do
			progress[i].exampleLinks = exampleLinks[v]

		end
	end
end

function ProgressionTabMixin:UpdateSingleCharacterPVPProgress(guid)
    local charData = self.settings[guid]

    if(guid == playerGUID) then
		local highestRating = 0

		charData.brackets = {}

		for index, id in ipairs(pvpActivities) do
		--for i = 1, 5, 1 do
			-- 1 == 2v2, 2 == 3v3, 3 == 5v5, 4 == 10v10, Solo Arena == 7, Solo BG == 9

			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(id);

			charData.brackets[id] = {rating = rating, seasonBest = seasonBest}

			highestRating = rating > highestRating and rating or highestRating

		end

		local tierID, nextTierID = C_PvP.GetSeasonBestInfo();

		charData.tierInfo = {tierID, nextTierID}
		charData.rating = highestRating
		charData.honor = {
			current = UnitHonor("player"),
			maximum = UnitHonorMax("player"),
			level = UnitHonorLevel("player")
		}

	else
		charData.brackets = charData.brackets or {}
		charData.tierInfo = charData.tierInfo or {}
		charData.rating = charData.rating or 0
		charData.honor = {
			current = 0,
			maximum = 0,
			level = 0,
		}

	end
end

function ProgressionTabMixin:CalculateProgressWeightViaAchievements(guid)
	local progressWeight = 0

	for k, info in ipairs(raidActivities) do
		local mapID = info.mapID

		if(self.settings[guid].raid[mapID].regular) then
			for difficultyIndex, table in pairs(self.settings[guid].raid[mapID].regular) do
				progressWeight = progressWeight + miog.calculateWeightedScore(difficultyIndex, table.kills, #table.bosses, true, 1)


			end
		else
			progressWeight = progressWeight + 0

		end
	end

	self.settings[guid].progressWeight = progressWeight
end

function ProgressionTabMixin:CheckForAchievements(guid, type, mapID)
    local charData = self.settings[guid]
	local currTable = miog.MAP_INFO[mapID].achievementsAwakened

	if type ~= "awakened" then
		if not miog.MAP_INFO[mapID].achievementTable then
			miog.checkForMapAchievements(mapID)
			
		end
		currTable = miog.MAP_INFO[mapID].achievementTable
	end

	local raidData = charData.raid[mapID][type]

	for _, achievementID in ipairs(currTable) do
		local id, name, _, _, _, _, _, description = GetAchievementInfo(achievementID)
		local searchFor = (type == "awakened") and description or name

		local difficulty = string.find(searchFor, "Normal") and 1 
						or string.find(searchFor, "Heroic") and 2 
						or string.find(searchFor, "Mythic") and 3

		if difficulty then
			local difficultyData = raidData[difficulty] or { ingame = true, kills = 0, bosses = {} }
			raidData[difficulty] = difficultyData

			local numCriteria = (type == "regular") and 1 or GetAchievementNumCriteria(id)

			for i = 1, numCriteria do
				local _, _, completedCriteria, quantity, _, _, _, _, _, criteriaID = GetAchievementCriteriaInfo(id, i, true)

				if completedCriteria then
					difficultyData.kills = difficultyData.kills + 1
				end

				table.insert(difficultyData.bosses, {
					id = id,
					criteriaID = criteriaID,
					killed = completedCriteria,
					quantity = quantity
				})
			end
		end
	end
end

function ProgressionTabMixin:UpdateSingleCharacterRaidProgress(guid)
    local charData = self.settings[guid]
    local raidTable = charData.raid

    if guid == playerGUID then
        for _, info in ipairs(raidActivities) do
			local mapID = info.mapID

            raidTable[mapID] = {regular = {}, awakened = {}}

            if miog.MAP_INFO[mapID].achievementsAwakened then
                self:CheckForAchievements(guid, "awakened", mapID)
            end

            self:CheckForAchievements(guid, "regular", mapID)
        end
    else
        local raidData = miog.getNewRaidSortData(charData.name, charData.realm)
        local progressWeight = charData.progressWeight or 0

        if raidData and raidData.character then
            for _, info in ipairs(raidActivities) do
				local mapID = info.mapID
                -- Only create table if it doesn't exist
                if not raidTable[mapID] then
                    raidTable[mapID] = {regular = {}, awakened = {}}
                    local mapInfo = miog.MAP_INFO[mapID]
                    local characterRaid = raidData.character.raids[mapID]

                    if characterRaid then
                        -- Calculate progress weight from difficulties
                        for _, difficultyData in pairs(characterRaid.regular.difficulties) do
                            progressWeight = progressWeight + difficultyData.weight
                        end

                        -- Process bosses and achievements
                        for bossIndex, bossData in pairs(mapInfo.bosses) do
                            for _, achievementID in ipairs(bossData.achievements) do
                                local id, name, _, _, _, _, _, _, _, _, _, _, _, _, _ = GetAchievementInfo(achievementID)
                                local difficulty = string.find(name, "Normal") and 1 
                                                or string.find(name, "Heroic") and 2 
                                                or string.find(name, "Mythic") and 3

                                if difficulty and characterRaid.regular.difficulties[difficulty] then
                                    local raiderIODifficultyData = characterRaid.regular.difficulties[difficulty]

                                    raidTable[mapID].regular[difficulty] = {
                                        ingame = false,
                                        kills = raiderIODifficultyData.kills,
                                        bosses = raiderIODifficultyData.bosses
                                    }

                                    local _, _, _, _, _, _, _, _, _, criteriaID, _ = GetAchievementCriteriaInfo(id, 1, true)

                                    raidTable[mapID].regular[difficulty].bosses[bossIndex] = {
                                        id = id,
                                        criteriaID = criteriaID,
                                        killed = raiderIODifficultyData.bosses[bossIndex].killed,
                                        quantity = raiderIODifficultyData.bosses[bossIndex].count
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end

        charData.progressWeight = progressWeight
    end

	self:CalculateProgressWeightViaAchievements(guid)
end

function ProgressionTabMixin:UpdateSingleCharacterMythicPlusProgress(guid)
    local charData = self.settings[guid]
    local mplusData = charData.mplus

    if guid == playerGUID then
        -- Update the player's Mythic+ score
        mplusData.score = { value = C_ChallengeMode.GetOverallDungeonScore(), ingame = true }

        for _, challengeMapID in pairs(mythicPlusActivities) do
            local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID)
            mplusData[challengeMapID] = { intimeInfo = intimeInfo, overtimeInfo = overtimeInfo }
        end
    else
        -- Ensure score table exists
        mplusData.score = mplusData.score or { value = 0, ingame = true }

        -- Fetch external Mythic+ data
        local externalData, intimeInfo, overtimeInfo = miog.getMPlusSortData(charData.name, charData.realm, nil, true)

        -- Only update score if the stored score is zero
        if externalData and mplusData.score.value == 0 then
            mplusData.score = { value = externalData.score.score, ingame = false }
        end

        for _, challengeMapID in pairs(mythicPlusActivities) do
            local challengeData = mplusData[challengeMapID] or {}
            challengeData.intimeInfo = intimeInfo and intimeInfo[challengeMapID] or challengeData.intimeInfo
            challengeData.overtimeInfo = overtimeInfo and overtimeInfo[challengeMapID] or challengeData.overtimeInfo
            mplusData[challengeMapID] = challengeData
        end
    end
end

function ProgressionTabMixin:PopulateViews()
	local dataProvider = CreateDataProvider();
    
	if(self.type == "mplus") then
		dataProvider:SetSortComparator(sortByScore)

	elseif(self.type == "raid") then
		dataProvider:SetSortComparator(sortByProgress)

	elseif(self.type == "pvp") then
		dataProvider:SetSortComparator(sortByRating)

	else
		dataProvider:SetSortComparator(sortByCombined)

	end

	for k, v in pairs(self.settings) do
		dataProvider:Insert({
			type = self.type,
			guid = k,
			name = v.name,
			realm = v.realm,
			classFile = v.classFile,
			fullName = v.fullName,
			spec = v.spec,
			ilvl = v.ilvl,

			honor = v.honor,
			score = v.mplus.score,
			brackets = v.brackets,
			rating = v.rating,
			progress = v.raid,
			progressWeight = v.progressWeight,
			combinedWeight = v.mplus.score.value + v.progressWeight + v.rating,
			nextRewards = v.nextRewards,

			vaultProgress = v.vaultProgress,
			seasonalData = v.seasonalData,
		})
	end

	local scrollBox

    if(self.type == "all") then
		scrollBox = self.Columns

		local startIndex = floor(self:GetWidth() / 100) + 1
		local providerSize = dataProvider:GetSize()

		if(providerSize > startIndex) then
			dataProvider:RemoveIndexRange(startIndex, providerSize)

		end

		
	else
		scrollBox = self.Rows
    end

	scrollBox:SetDataProvider(dataProvider)
end

function ProgressionTabMixin:UpdateMythicPlusProgress()
    for guid, v in pairs(self.settings) do
        self:UpdateSingleCharacterMythicPlusProgress(guid)

    end
end

function ProgressionTabMixin:UpdateRaidProgress()
    for guid, v in pairs(self.settings) do
        self:UpdateSingleCharacterRaidProgress(guid)

    end
end

function ProgressionTabMixin:UpdatePVPProgress()
    for guid, v in pairs(self.settings) do
        self:UpdateSingleCharacterPVPProgress(guid)

    end
end

local function createProgressTables(characterData)
	characterData.mplus = characterData.mplus or {}
	characterData.raid = characterData.raid or {}
	characterData.pvp = characterData.pvp or {}
	characterData.seasonalData = characterData.seasonalData or {}
	characterData.nextRewards = characterData.nextRewards or {}
end

function ProgressionTabMixin:CreateCharacterTables(guid, v)
	self.settings[guid] = self.settings[guid] or {}

    local characterStats = self.settings[guid]

	characterStats.name = v.name or characterStats.name
	characterStats.fullName = v.name and miog.createFullNameFrom("unitName", v.name .. "-" .. v.realm) or characterStats.fullName
	characterStats.spec = v.spec or characterStats.spec
	characterStats.classFile = v.classFile or characterStats.classFile

	if(guid == UnitGUID("player")) then
		characterStats.ilvl = select(2, GetAverageItemLevel()) or v.ilvl

	else
		characterStats.ilvl = characterStats.ilvl or 0

	end

    createProgressTables(characterStats)
end

function ProgressionTabMixin:UpdateSaveData()
	self:RequestAccountCharacter()

    if(accountCharacters) then
        for guid, v in pairs(accountCharacters) do
            self:CreateCharacterTables(guid, v)

        end

        self:AddWeeklyProgress()
    end

    self:UpdateMythicPlusProgress()
    self:UpdateRaidProgress()
    self:UpdatePVPProgress()
end

function ProgressionTabMixin:UpdateAllData()
    self:RequestAccountCharacter()

    if(accountCharacters) then
        for guid, v in pairs(accountCharacters) do
            self:CreateCharacterTables(guid, v)

        end

        self:AddWeeklyProgress()
    end

    self:UpdateMythicPlusProgress()
    self:UpdateRaidProgress()
    self:UpdatePVPProgress()
    
    self:PopulateViews()
end