local addonName, miog = ...

local dataProvider = CreateDataProvider()

local EMPTY_STRING = "---"
local grayColor = miog.CLRSCC.colors.gray

local pvpActivityIDs = {
	1,
	2,
	--3,
	4,
	7,
	9,
}

ProgressCheckMixin = {}

local function ProgressCheckDiffFrame_OnEnter(selfFrame, mapID, data, difficultyIndex)
    local mapInfo = miog:GetMapInfo(mapID)

    GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
    GameTooltip_AddHighlightLine(GameTooltip, mapInfo.instanceName)
    GameTooltip_AddBlankLineToTooltip(GameTooltip)

    for k, v in ipairs(data[difficultyIndex].bosses) do
        if(v.id) then
            local name, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfoByID(v.id, 1, true)

            if(not name) then
                name = mapInfo.bosses[k].name .. " kills"

            end

            GameTooltip:AddDoubleLine(v.count or v.quantity or 0, name)
        end
    end
    
    GameTooltip:Show()
end

local function getChestsLevelForID(challengeMapID, durationSec)
	local name, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeMapID)

	local oneChest = timeLimit
	local twoChest = timeLimit * 0.8
	local threeChest = timeLimit * 0.6

	return durationSec <= threeChest and 3 or durationSec <= twoChest and 2 or durationSec <= oneChest and 1 or 0
end

local function ProgressCheckLevelFrame_OnEnter(frame, data, challengeMapID)
	local name = C_ChallengeMode.GetMapUIInfo(challengeMapID);
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	GameTooltip:SetText(name, 1, 1, 1);

	local intimeInfo = data.intimeInfo
	local overtimeInfo = data.overtimeInfo
	local overtimeHigher = intimeInfo and overtimeInfo and intimeInfo.dungeonScore and overtimeInfo.dungeonScore and overtimeInfo.dungeonScore > intimeInfo.dungeonScore and true or false
	local overallScore = overtimeHigher and overtimeInfo.dungeonScore or intimeInfo and intimeInfo.dungeonScore or 0

	if(intimeInfo or overtimeInfo) then
		if(overallScore) then
			local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overallScore);
			if(not color) then
				color = HIGHLIGHT_FONT_COLOR;
			end
			GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(tostring(overallScore))), GREEN_FONT_COLOR);
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
			end
		end
	end

	GameTooltip:Show();
end

function ProgressCheckMixin:RefreshCharacterList()
	local charList = {}

    local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize()

    for currencyIndex = 1, numTokenTypes do
		local currencyData = C_CurrencyInfo.GetCurrencyListInfo(currencyIndex)
		local accountCurrencyData = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyData.currencyID)

		if(accountCurrencyData) then
			for k, v in pairs(accountCurrencyData) do
				charList[v.characterGUID] = true

			end
		end
	end

    return charList
end

function ProgressCheckMixin:GetGeneralSettings()
    return self.settings

end

function ProgressCheckMixin:GetCharacterSettings()
    return self:GetGeneralSettings().characters[UnitGUID("player")]

end

function ProgressCheckMixin:GetCharacterMythicPlusSettings()
    return self:GetCharacterSettings().mythicPlus

end

function ProgressCheckMixin:GetCharacterRaidingSettings()
    return self:GetCharacterSettings().raiding

end

function ProgressCheckMixin:GetCharacterPVPSettings()
    return self:GetCharacterSettings().pvp

end

function ProgressCheckMixin:GetCharacterVaultSettings()
    return self:GetCharacterSettings().greatVault

end

function ProgressCheckMixin:GetCharacterLockoutsSettings()
    return self:GetCharacterSettings().lockouts

end

function ProgressCheckMixin:UpdateVault()
	local activitiesData = {}
    local raidEncounterData = {}
    local exampleRewardsData = {}

	for _, activityInfo in ipairs(C_WeeklyRewards.GetActivities()) do
        activitiesData[activityInfo.type] = activitiesData[activityInfo.type] or {}
        raidEncounterData[activityInfo.type] = raidEncounterData[activityInfo.type] or {}
        exampleRewardsData[activityInfo.type] = exampleRewardsData[activityInfo.type] or {}

        if(activityInfo.type == 3) then
            local raidEncounters = C_WeeklyRewards.GetActivityEncounterInfo(activityInfo.type, activityInfo.index)
            tinsert(raidEncounterData[activityInfo.type], raidEncounters)

        end

        local exampleRewards = {C_WeeklyRewards.GetExampleRewardItemHyperlinks(activityInfo.id)}

        tinsert(activitiesData[activityInfo.type], activityInfo)
        tinsert(exampleRewardsData[activityInfo.type], exampleRewards)

	end

	local resetTime = time() + C_DateAndTime.GetSecondsUntilWeeklyReset()
    local numHeroic, numMythic, numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns()

	self:GetGeneralSettings().resetTime = resetTime

	self:GetCharacterSettings().greatVault = {
		resetTime = resetTime,
		canClaimRewards = C_WeeklyRewards.CanClaimRewards(),
		hasGeneratedRewards = C_WeeklyRewards.HasGeneratedRewards(),
		hasAvailableRewards = C_WeeklyRewards.HasAvailableRewards(),
		rewardsAreForLastWeek = C_WeeklyRewards.AreRewardsForCurrentRewardPeriod(),
		activities = activitiesData,
		raidEncounterData = raidEncounterData,
		exampleRewardsData = exampleRewardsData,
        runHistory = C_MythicPlus.GetRunHistory(false, true),
        worldHistory = C_WeeklyRewards.GetSortedProgressForActivity(Enum.WeeklyRewardChestThresholdType.World, true),
        numHeroic = numHeroic,
        numMythic = numMythic,
        numMythicPlus = numMythicPlus
	}
end

function ProgressCheckMixin:UpdateDungeonData()
    local resilientLevel
    local mythicPlusSettings = self:GetCharacterMythicPlusSettings()

    mythicPlusSettings.score = C_ChallengeMode.GetOverallDungeonScore()
    mythicPlusSettings.source = "ingame"

    local numOfCheckedDungeons = 0

    for _, challengeMapID in pairs(C_ChallengeMode.GetMapTable()) do
        local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID)
        mythicPlusSettings.dungeons[challengeMapID] = {intimeInfo = intimeInfo, overtimeInfo = overtimeInfo}


        if(intimeInfo and intimeInfo.level > 11) then
            if(not resilientLevel or intimeInfo.level < resilientLevel) then
                resilientLevel = intimeInfo.level

            end

            numOfCheckedDungeons = numOfCheckedDungeons + 1
        end
    end

    if(numOfCheckedDungeons == 8) then
        mythicPlusSettings.resilient = resilientLevel

    end
end

function ProgressCheckMixin:UpdateRaidData()
    local raidingSettings = self:GetCharacterRaidingSettings()
    local mapIDTable = miog:GetCurrentTierJournalMapIDs("raid")

    raidingSettings.progressWeight = 0
    raidingSettings.progress = {}

    for k, mapID in ipairs(mapIDTable) do
        local mapInfo = miog:GetMapInfo(mapID)

        if(mapInfo and mapInfo.achievementIDs) then
            raidingSettings.raids[mapID] = {}

            local raidSettings = raidingSettings.raids[mapID]

            for index, achievementID in ipairs(mapInfo.achievementIDs) do
                local difficultyIndex = ((index - 1) % 4)

                if(difficultyIndex > 0) then
                    raidSettings[difficultyIndex] = raidSettings[difficultyIndex] or {source = "ingame", kills = 0, numOfBosses = 0, bosses = {}}

                    local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfo(achievementID, 1, true)

                    if(completed) then
                        raidSettings[difficultyIndex].kills = raidSettings[difficultyIndex].kills + 1
                        raidingSettings.progress[difficultyIndex] = raidingSettings.progress[difficultyIndex] and raidingSettings.progress[difficultyIndex] + 1 or 1

                    end

                    table.insert(raidSettings[difficultyIndex].bosses, {
                        id = achievementID,
                        killed = completed,
                        count = quantity
                    })

                    raidSettings[difficultyIndex].numOfBosses = raidSettings[difficultyIndex].numOfBosses + 1
				    raidingSettings.progressWeight = raidingSettings.progressWeight + miog:CalculateRaidWeight(difficultyIndex, raidSettings[difficultyIndex].kills, raidSettings[difficultyIndex].numOfBosses, true)
                end
            end
        end
    end
end

function ProgressCheckMixin:UpdatePVPData()
    local pvpSettings = self:GetCharacterPVPSettings()
    local highestRating = 0

    for index, id in ipairs(pvpActivityIDs) do
        local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(id)

        pvpSettings[id] = {
            rating = rating,
            seasonBest = seasonBest,
        }

        highestRating = max(rating, highestRating)

    end

    pvpSettings.highestRating = highestRating
end

function ProgressCheckMixin:UpdateLockouts()
    local lockoutSettings = self:GetCharacterLockoutsSettings()
    local instanceLockouts = {}

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
                if(not instanceLockouts[instanceId]) then
                    instanceLockouts[instanceId] = {}

                end

                local journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(instanceId)
                local _, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, _ = EJ_GetInstanceInfo(journalInstanceID)

                local infoTable = {
                    id = lockoutId,
                    name = name,
                    difficultyID = difficultyId,
                    shortDifficulty = miog:ConvertDifficultyIDToShortName(difficultyId),
                    extended = extended,
                    isRaid = isRaid,
                    icon = buttonImage1,
                    mapID = instanceId,
                    journalInstanceID = journalInstanceID,
                    index = index,
                    numEncounters = numEncounters,
                    cleared = numEncounters == encounterProgress,
                    resetDate = time() + reset,
                    bosses = bosses
                }

                tinsert(lockoutSettings.list, infoTable)

                tinsert(instanceLockouts[instanceId], infoTable)
            end
        end
    end

    lockoutSettings.instances = instanceLockouts
end

function ProgressCheckMixin:UpdateAllData()
    self:UpdateDungeonData()
    self:UpdateRaidData()
    self:UpdatePVPData()
    self:UpdateVault()
    self:UpdateLockouts()
end

function ProgressCheckMixin:RefreshCharacters()
    C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
    
	local playersGUID = UnitGUID("player")

	local localizedClass, fileName, localizedRace, englishRace, sex, name = GetPlayerInfoByGUID(playersGUID)
	local specID = GetSpecializationInfo(GetSpecialization())

	if(playersGUID) then
        self.settings.characters[playersGUID] = {
            guid = playersGUID,
            name = name,
            fileName = fileName,
            specID = specID,
            itemlevel = select(2, GetAverageItemLevel()) or 0,
            mythicPlus = {
                score = 0,
                dungeons = {},
            },
            raiding = {
                progressWeight = 0,
                raids = {},
                progress = {},
            },
            pvp = {
                highestRating = 0,
            },
            lockouts = {
                instances = {},
                list = {},
            },
            greatVault = {},
        }

        self:UpdateAllData()
	end

	for guid in pairs(self:RefreshCharacterList()) do
		localizedClass, fileName, localizedRace, englishRace, sex, name = GetPlayerInfoByGUID(guid)

		local charSettings = self.settings.characters[guid]

        if(charSettings) then
            if(charSettings.fileName ~= fileName) then
                charSettings.specID = 0
                charSettings.itemlevel = 0

            end

            charSettings.guid = guid
            charSettings.name = name
            charSettings.fileName = fileName

        else
            self.settings.characters[guid] = {
                guid = guid,
                name = name,
                fileName = fileName,
                specID = 0,
                itemlevel = 0,
                mythicPlus = {
                    score = 0,
                    dungeons = {},
                },
                raiding = {
                    progressWeight = 0,
                    raids = {},
                    progress = {},
                },
                pvp = {
                    highestRating = 0
                },
                lockouts = {
                    instances = {},
                    list = {},
                },
                greatVault = {},
            }
        end
	end
end

function ProgressCheckMixin:UpdateDataColumns()
    dataProvider:Flush()

    local orderedList = {}

    for k, v in pairs(self.settings.characters) do
        tinsert(orderedList, v)
        
    end

    local playerGUID = UnitGUID("player")

    for k, v in ipairs(self.InfoColumn.CellList.cellTable) do
        v:Hide()

        local backgroundImage = self["Background" .. k]

        if(backgroundImage) then
            backgroundImage:ClearAllPoints()

        end
    end

    if(not self.type) then
        for k, v in ipairs(self.InfoColumn.CellList.cellTable) do
            local backgroundImage = self["Background" .. k]
            if(backgroundImage) then
                backgroundImage:ClearAllPoints()

            end

            v.Text:SetText(v:GetParentKey())
            v:Show()

        end

        table.sort(orderedList, function(k1, k2)
            if(k1.guid == playerGUID) then
                return true

            elseif(k2.guid == playerGUID) then
                return false
                
            else
                return k1.itemlevel > k2.itemlevel

            end
        end)

        for k, v in ipairs(orderedList) do
            v.template = "MIOG_ProgressCheckCharacterOverviewTemplate"
            dataProvider:Insert(v)

        end

    elseif(self.type == "dungeon") then
        local mapTable = C_ChallengeMode.GetMapTable()
        local orderedTable = {}

        for k, mapChallengeModeID in ipairs(mapTable) do
            local name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
            tinsert(orderedTable, {id = id, name = name, mapID = mapID})
        end

        table.sort(orderedTable, function(k1, k2)
            return k1.name < k2.name
        end)

        for k, v in ipairs(self.InfoColumn.CellList.cellTable) do
            local mapUIInfo = orderedTable[k]

            local backgroundImage = self["Background" .. k]
            if(backgroundImage) then
                backgroundImage:ClearAllPoints()

            end

            if(mapUIInfo) then
                local mapInfo = miog:GetMapInfo(mapUIInfo.mapID)

                backgroundImage:SetHeight(v:GetHeight() - 2)
                backgroundImage:SetTexture(mapInfo.horizontal, "MIRROR", "MIRROR")
                backgroundImage:SetPoint("LEFT", v, "LEFT")
                backgroundImage:SetPoint("RIGHT", self, "RIGHT")

                v.Text:SetText(mapUIInfo.name)
                v:Show()

            else
                v:Hide()

            end
        end

        table.sort(orderedList, function(k1, k2)
            if(k1.guid == playerGUID) then
                return true

            elseif(k2.guid == playerGUID) then
                return false
                
            else
                return k1.mythicPlus.score > k2.mythicPlus.score

            end
        end)

        for k, v in ipairs(orderedList) do
            v.template = "MIOG_ProgressCheckCharacterDungeonTemplate"
            dataProvider:Insert(v)

        end

    elseif(self.type == "raid") then
        local mapIDTable = miog:GetCurrentTierJournalMapIDs("raid")

        for k, v in ipairs(self.InfoColumn.CellList.cellTable) do
            local mapID = mapIDTable[k]
            local mapInfo = miog:GetMapInfo(mapID)

            if(mapInfo) then
                local backgroundImage = self["Background" .. k]

                if(backgroundImage) then
                    backgroundImage:SetHeight(v:GetHeight() - 2)
                    backgroundImage:SetPoint("LEFT", v, "LEFT")
                    backgroundImage:SetPoint("RIGHT", self, "RIGHT")

                    if(mapID == 2939) then --backup for now, Blizzard's image for this id is wrong
                        backgroundImage:SetTexture(mapInfo.buttonImage2, "MIRROR", "MIRROR")

                    else
                        backgroundImage:SetTexture(mapInfo.horizontal, "MIRROR", "MIRROR")

                    end
                end

                v.Text:SetText(mapInfo.instanceName)
                v:Show()

            end
        end

        table.sort(orderedList, function(k1, k2)
            if(k1.guid == playerGUID) then
                return true

            elseif(k2.guid == playerGUID) then
                return false
                
            else
                return k1.raiding.progressWeight > k2.raiding.progressWeight

            end
        end)

        for k, v in ipairs(orderedList) do
            v.template = "MIOG_ProgressCheckCharacterRaidTemplate"
            dataProvider:Insert(v)

        end
    elseif(self.type == "pvp") then
        for k, v in ipairs(self.InfoColumn.CellList.cellTable) do
            local pvpIndex = pvpActivityIDs[k]

            local backgroundImage = self["Background" .. k]

            if(backgroundImage) then
                backgroundImage:ClearAllPoints()

            end

            local pvpInfo = miog:GetPVPBacketInfo(pvpIndex)

            if(pvpInfo) then
                backgroundImage:SetHeight(v:GetHeight() - 2)
                backgroundImage:SetPoint("LEFT", v, "LEFT")
                backgroundImage:SetPoint("RIGHT", self, "RIGHT")
                backgroundImage:SetTexture(pvpInfo.horizontal, "MIRROR", "MIRROR")

                local name = PVPUtil.GetBracketName(pvpIndex)
            
                v.Text:SetText(name)
                v:Show()

            else
                v:Hide()

            end
        end

        table.sort(orderedList, function(k1, k2)
            if(k1.guid == playerGUID) then
                return true

            elseif(k2.guid == playerGUID) then
                return false

            else
                return k1.pvp.highestRating > k2.pvp.highestRating

            end
        end)

        for k, v in ipairs(orderedList) do
            v.template = "MIOG_ProgressCheckCharacterPVPTemplate"
            dataProvider:Insert(v)

        end

    elseif(self.type == "lockouts") then
        for k, v in ipairs(self.InfoColumn.CellList.cellTable) do
            v:Hide()
            
            local backgroundImage = self["Background" .. k]

            if(backgroundImage) then
                backgroundImage:ClearAllPoints()

            end
        end

        local lockoutIndices = {} 
        local lockoutInstances = {}
        local frameIndex = 1

        for _, characterInfo in pairs(self.settings.characters) do
            lockoutIndices[characterInfo.name] = {}

            for k, v in pairs(characterInfo.lockouts.instances) do
                local instanceInfo = v[1]
                
                if(not lockoutInstances[instanceInfo.name]) then
                    local descFrame = self.InfoColumn.CellList.cellTable[frameIndex]

                    if(descFrame) then
                        lockoutInstances[instanceInfo.name] = true

                        descFrame.Text:SetText(instanceInfo.name)
                        descFrame:Show()

                        local backgroundImage = self["Background" .. frameIndex]

                        if(backgroundImage) then
                            local mapInfo = miog:GetMapInfo(instanceInfo.mapID)

                            if(instanceInfo.mapID == 2939) then --backup for now, Blizzard's image for this id is wrong
                                backgroundImage:SetTexture(mapInfo.buttonImage2, "MIRROR", "MIRROR")

                            else
                                backgroundImage:SetTexture(mapInfo.horizontal, "MIRROR", "MIRROR")

                            end

                            backgroundImage:SetHeight(descFrame:GetHeight() - 2)
                            backgroundImage:SetPoint("LEFT", descFrame, "LEFT")
                            backgroundImage:SetPoint("RIGHT", self, "RIGHT")
                            
                        end

                        frameIndex = frameIndex + 1
                    end
                end

                tinsert(lockoutIndices[characterInfo.name], {infoIndex = frameIndex, dataIndex = k})
            end
        end

         table.sort(orderedList, function(k1, k2)
            if(k1.guid == playerGUID) then
                return true

            elseif(k2.guid == playerGUID) then
                return false
            
            else
                return #k1.lockouts.list > #k2.lockouts.list

            end
        end)

        for k, v in ipairs(orderedList) do
            v.lockoutIndices = lockoutIndices[v.name]
            v.template = "MIOG_ProgressCheckCharacterLockoutsTemplate"
            dataProvider:Insert(v)

        end
    end

    self.InfoColumn.CellList:MarkDirty()
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function ProgressCheckMixin:Refresh()
    self:SetSize(self:GetParent():GetSize())
    self:RefreshCharacters()

    self:UpdateDataColumns()
end

function ProgressCheckMixin:SetType(owner, type)
    self.type = type

    self:Refresh()

end

function ProgressCheckMixin:OnShow()
    self:Refresh()

end

function ProgressCheckMixin:OnEvent(event, ...)
    if(event == "CHALLENGE_MODE_COMPLETED") then
        self:UpdateDungeonData()
        self:UpdateVault()

    elseif(event == "BOSS_KILL") then
        if(IsInRaid()) then
            self:UpdateRaidData()

        elseif(IsInGroup()) then
            self:UpdateDungeonData()

        end

        self:UpdateVault()
        self:UpdateLockouts()

    elseif(event == "PLAYER_AVG_ITEM_LEVEL_UPDATE") then
        self:UpdateDataColumns()

    elseif(event == "PVP_RATED_STATS_UPDATE") then
        self:UpdatePVPData()

    elseif(event == "PLAYER_ENTERING_WORLD") then
        C_Timer.After(10, function()
            self:UpdateAllData()
        end)
    end
end

function ProgressCheckMixin:OnLoad()
    self.settings = MIOG_NewSettings["progress"]

    local view = CreateScrollBoxListLinearView()
    view:SetHorizontal(true)

    local mapIDTable = miog:GetCurrentTierJournalMapIDs("raid")
    local numBosses = 0

    for k, v in ipairs(mapIDTable) do
        local mapInfo = miog:GetMapInfo(v)
        numBosses = numBosses + mapInfo.numOfBosses

    end
    
    EventRegistry:RegisterCallback("MIOG_PROGRESS_CHECK_TYPE", function(...) self:SetType(...) end, self);
    
    local function initFrames(frame, data)
        local color = C_ClassColor.GetClassColor(data.fileName)
        frame.Header.GuildBannerBackground:SetVertexColor(color:GetRGB())
        frame.Header.GuildBannerBorder:SetVertexColor(color.r * 0.65, color.g * 0.65, color.b * 0.65)
        frame.Header.GuildBannerBorderGlow:SetShown(data.guid == UnitGUID("player"))
        frame.Header.Name:SetText(data.name)
        
        frame.Header.Class.Icon:SetAtlas(GetClassAtlas(data.fileName))

        if(data.specID > 0) then
            frame.Header.Spec.Icon:SetTexture(PlayerUtil.GetSpecIconBySpecID(data.specID))
            
        else
            frame.Header.Spec.Icon:SetAtlas("questlog-waypoint-finaldestination-questionmark")

        end

        if(data.template == "MIOG_ProgressCheckCharacterOverviewTemplate") then
            if(data.itemlevel > 0) then
                frame.CellList.Itemlevel.Text:SetText(data.itemlevel)
                frame.CellList.Itemlevel.Text:SetTextColor(miog.createCustomColorForRating(data.itemlevel * 12):GetRGBA())

            else
                frame.CellList.Itemlevel.Text:SetText(EMPTY_STRING)
			    frame.CellList.Itemlevel.Text:SetTextColor(grayColor:GetRGBA())

            end

            frame.CellList.Score.Text:SetText(data.mythicPlus.score)

            if(data.mythicPlus.score > 0) then
                frame.CellList.Score.Text:SetText(data.mythicPlus.score)
			    frame.CellList.Score.Text:SetTextColor(miog.createCustomColorForRating(data.mythicPlus.score):GetRGBA())

            else
                frame.CellList.Score.Text:SetText(EMPTY_STRING)
			    frame.CellList.Score.Text:SetTextColor(grayColor:GetRGBA())

            end

            if(data.mythicPlus.resilient) then
                frame.CellList.Resilient.Text:SetText(data.mythicPlus.resilient)
                frame.CellList.Resilient.Text:SetTextColor(miog.ITEM_QUALITY_COLORS[6].color:GetRGBA())
                
            else
                frame.CellList.Resilient.Text:SetText(EMPTY_STRING)
                frame.CellList.Resilient.Text:SetTextColor(grayColor:GetRGBA())

            end

            local raidData = data.raiding.progress

            for i = 1, 3, 1 do
                local diffFrame = i == 1 and "Normal" or i == 2 and "Heroic" or i == 3 and "Mythic"
                local separateData = raidData[i]

                if(separateData) then
                    frame.CellList[diffFrame].Text:SetText(separateData .. "/" .. numBosses)
                    frame.CellList[diffFrame].Text:SetTextColor(miog.DIFFICULTY[i].miogColors:GetRGBA())

                else
                    frame.CellList[diffFrame].Text:SetText(EMPTY_STRING)
                    frame.CellList[diffFrame].Text:SetTextColor(grayColor:GetRGBA())

                end
            end

            if(data.greatVault and data.greatVault.activities and #data.greatVault.activities > 0) then
                --[[if(data.greatVault.hasGeneratedRewards) then
                    frame.CellList.GreatVault.Icon:SetAtlas("gficon-chest-evergreen-greatvault-collect")

                    frame.CellList.GreatVault.Icon:SetScript("OnEnter", function(selfIcon)
                        GameTooltip:SetOwner(selfIcon, "ANCHOR_RIGHT")
                        GameTooltip:SetText(WEEKLY_REWARDS_RETURN_TO_CLAIM)
                        GameTooltip:Show()
                    end)

                    frame.CellList.GreatVault.Icon:Show()
                elseif(data.greatVault.hasAvailableRewards or data.greatVault.hasRewardOnReset and data.greatVault.resetTime and data.greatVault.resetTime < time()) then
                    frame.CellList.GreatVault.Icon:SetAtlas("gficon-chest-evergreen-greatvault-collect")

                    frame.CellList.GreatVault.Icon:SetScript("OnEnter", function(selfIcon)
                        GameTooltip:SetOwner(selfIcon, "ANCHOR_RIGHT")
                        GameTooltip:SetText(MYTHIC_PLUS_COLLECT_GREAT_VAULT)
                        GameTooltip:Show()
                    end)

                    frame.CellList.GreatVault.Icon:Show()
                else
                    frame.CellList.GreatVault.Icon:Hide()

                end]]

                frame.CellList.Raids:SetInfo(data.greatVault, 3)
                frame.CellList.Dungeons:SetInfo(data.greatVault, 1)
                frame.CellList.World:SetInfo(data.greatVault, 6)

                local raidPercentage = frame.CellList.Raids:GetProgressPercentage()
                if(raidPercentage > 0) then
                    frame.CellList.Raids.Text:SetTextColor(miog.createCustomColorForRating(4000 * raidPercentage):GetRGBA())
                    frame.CellList.Raids.Checkmark:SetShown(raidPercentage == 1)

                else
                    frame.CellList.Raids.Text:SetTextColor(grayColor:GetRGBA())
                    frame.CellList.Raids.Checkmark:SetShown(false)

                end
                
                local dungeonPercentage = frame.CellList.Dungeons:GetProgressPercentage()
                if(dungeonPercentage > 0) then
                    frame.CellList.Dungeons.Text:SetTextColor(miog.createCustomColorForRating(4000 * dungeonPercentage):GetRGBA())
                    frame.CellList.Dungeons.Checkmark:SetShown(dungeonPercentage == 1)
                    
                else
                    frame.CellList.Dungeons.Text:SetTextColor(grayColor:GetRGBA())
                    frame.CellList.Dungeons.Checkmark:SetShown(false)

                end
                
                local worldPercentage = frame.CellList.World:GetProgressPercentage()
                if(worldPercentage > 0) then
                    frame.CellList.World.Text:SetTextColor(miog.createCustomColorForRating(4000 * worldPercentage):GetRGBA())
                    frame.CellList.World.Checkmark:SetShown(worldPercentage == 1)

                else
                    frame.CellList.World.Text:SetTextColor(grayColor:GetRGBA())
                    frame.CellList.World.Checkmark:SetShown(false)

                end
            else
                frame.CellList.Raids.Text:SetText(EMPTY_STRING)
                frame.CellList.Raids.Text:SetTextColor(grayColor:GetRGBA())
                frame.CellList.Raids.Checkmark:SetShown(false)

                frame.CellList.Dungeons.Text:SetText(EMPTY_STRING)
                frame.CellList.Dungeons.Text:SetTextColor(grayColor:GetRGBA())
                frame.CellList.Dungeons.Checkmark:SetShown(false)

                frame.CellList.World.Text:SetText(EMPTY_STRING)
                frame.CellList.World.Text:SetTextColor(grayColor:GetRGBA())
                frame.CellList.World.Checkmark:SetShown(false)

                frame.CellList.Raids:Reset()
                frame.CellList.Dungeons:Reset()
                frame.CellList.World:Reset()

                --frame.CellList.GreatVault.Icon:Hide()

                --[[frame.CellList.Raids:ResetAllData()
                frame.CellList.Dungeons:ResetAllData()
                frame.CellList.World:ResetAllData()]]
            end
        else
            frame.CellList:Reset()

            if(data.template == "MIOG_ProgressCheckCharacterDungeonTemplate") then
                local mapTable = C_ChallengeMode.GetMapTable()
                local orderedTable = {}

                for k, mapChallengeModeID in ipairs(mapTable) do
                    local name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
                    tinsert(orderedTable, {id = id, name = name, mapID = mapID})
                end

                table.sort(orderedTable, function(k1, k2)
                    return k1.name < k2.name
                end)

                for index, mapUIInfo in ipairs(orderedTable) do
                    local levelFrame = frame.CellList:CreateFrame()
                    
                    local dungeonData = data.mythicPlus.dungeons[mapUIInfo.id]

                    if(dungeonData) then
                        local intimeInfo = dungeonData.intimeInfo
                        local overtimeInfo = dungeonData.overtimeInfo

                        local overtimeHigher = intimeInfo and overtimeInfo and intimeInfo.dungeonScore and overtimeInfo.dungeonScore and overtimeInfo.dungeonScore > intimeInfo.dungeonScore
                        local hasOnlyOvertime = not intimeInfo and overtimeInfo

                        levelFrame.Text:SetText((overtimeHigher or hasOnlyOvertime) and overtimeInfo.level or intimeInfo and intimeInfo.level or 0)
                        levelFrame.Text:SetTextColor(CreateColorFromHexString((overtimeHigher or hasOnlyOvertime) and overtimeInfo.level and miog.CLRSCC.red or intimeInfo and intimeInfo.level and miog.CLRSCC.green or miog.CLRSCC.gray):GetRGBA())
                        levelFrame:SetScript("OnEnter", function(selfFrame) ProgressCheckLevelFrame_OnEnter(selfFrame, dungeonData, mapUIInfo.id) end)

                    else
                        levelFrame.Text:SetText(EMPTY_STRING)
                        levelFrame.Text:SetTextColor(grayColor:GetRGBA())
                        levelFrame:SetScript("OnEnter", nil)

                    end
                end

            elseif(data.template == "MIOG_ProgressCheckCharacterRaidTemplate") then
                for index, mapID in pairs(mapIDTable) do
                    local diffFrame = frame.CellList:CreateFrame()
                    local raidData = data.raiding.raids[mapID]

                    if(raidData) then
                        diffFrame.LeftText:SetText(data.raiding.raids[mapID][1] and ((data.raiding.raids[mapID][1].kills or 0) .. "/" .. data.raiding.raids[mapID][1].numOfBosses) or EMPTY_STRING)
                        diffFrame.LeftText:SetTextColor(_G["ITEM_QUALITY_COLORS"][1 + 1].color:GetRGBA())
                        diffFrame.LeftText:SetScript("OnEnter", function(selfFrame) ProgressCheckDiffFrame_OnEnter(selfFrame, mapID, raidData, 1) end)

                        diffFrame.Text:SetText(data.raiding.raids[mapID][2] and ((data.raiding.raids[mapID][2].kills or 0) .. "/" .. data.raiding.raids[mapID][2].numOfBosses) or EMPTY_STRING)
                        diffFrame.Text:SetTextColor(_G["ITEM_QUALITY_COLORS"][2 + 1].color:GetRGBA())
                        diffFrame.Text:SetScript("OnEnter", function(selfFrame) ProgressCheckDiffFrame_OnEnter(selfFrame, mapID, raidData, 2) end)

                        diffFrame.RightText:SetText(data.raiding.raids[mapID][3] and ((data.raiding.raids[mapID][3].kills or 0) .. "/" .. data.raiding.raids[mapID][3].numOfBosses) or EMPTY_STRING)
                        diffFrame.RightText:SetTextColor(_G["ITEM_QUALITY_COLORS"][3 + 1].color:GetRGBA())
                        diffFrame.RightText:SetScript("OnEnter", function(selfFrame) ProgressCheckDiffFrame_OnEnter(selfFrame, mapID, raidData, 3) end)

                    else
                        diffFrame.LeftText:SetText(EMPTY_STRING)
                        diffFrame.LeftText:SetScript("OnEnter", nil)
                        diffFrame.LeftText:SetTextColor(grayColor:GetRGBA())

                        diffFrame.Text:SetText(EMPTY_STRING)
                        diffFrame.Text:SetTextColor(grayColor:GetRGBA())
                        diffFrame.Text:SetScript("OnEnter", nil)


                        diffFrame.RightText:SetText(EMPTY_STRING)
                        diffFrame.RightText:SetScript("OnEnter", nil)
                        diffFrame.RightText:SetTextColor(grayColor:GetRGBA())
                    end
                end
            elseif(data.template == "MIOG_ProgressCheckCharacterPVPTemplate") then
                for index, id in ipairs(pvpActivityIDs) do
                    local bracketFrame = frame.CellList:CreateFrame()
                    local pvpData = data.pvp[id]

                    if(pvpData and pvpData.rating > 0) then
                        bracketFrame.Text:SetText(pvpData.rating)
                        bracketFrame.Text:SetTextColor(miog.createCustomColorForRating(pvpData.rating * 1.3):GetRGBA())

                    else
                        bracketFrame.Text:SetText(EMPTY_STRING)
                        bracketFrame.Text:SetTextColor(grayColor:GetRGBA())

                    end
                end
            elseif(data.template == "MIOG_ProgressCheckCharacterLockoutsTemplate") then
                for k, v in ipairs(data.lockoutIndices) do
                    local lockoutFrame = frame.CellList:CreateFrame()
                    lockoutFrame:SetData(data.lockouts.instances[v.dataIndex])

                end
            end
        end

        frame.CellList:MarkDirty()
    end

    local function CustomFactory(factory, data)
		local template = data.template
		factory(template, initFrames)

	end

    view:SetElementFactory(CustomFactory)
    view:SetPadding(0, 0, 0, 0, 0)
    view:SetElementExtent(128)

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("BOSS_KILL")
    self:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
    self:RegisterEvent("PVP_RATED_STATS_UPDATE")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

end