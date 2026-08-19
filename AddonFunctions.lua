local addonName, miog = ...

local function calculateWeightedScore(difficulty, kills, bossCount, current)
	if kills == 0 then return 0 end

	local seasonFactor = current and 100 or 1 -- Increase impact of current season
	return ((difficulty * 5) * 30 + (kills / bossCount * 20)) * seasonFactor
end

local function calcScore(difficulty, kills, current)
    return not current and (kills * 1) or ((100 + kills) ^ difficulty)
end

function miog:CalculateRaidWeight(difficulty, kills, isCurrent)
    return calcScore(difficulty, kills, isCurrent)
end

local function getBlizzardDifficulty(raiderIODifficulty)
	if(raiderIODifficulty == 1) then
		return 14

	elseif(raiderIODifficulty == 2) then
		return 15

	elseif(raiderIODifficulty == 3) then
		return 16

	end
end

function miog:GetNumOfBossesForSeasonID(seasonID)
    local seasonRaidData = miog:GetSeasonRaidData()

    if(seasonRaidData) then
        return seasonRaidData[seasonID] and seasonRaidData[seasonID].numOfBosses

    end
end

function miog:GetNumOfBossesForTierIndex(tierIndex)
    local seasonRaidData = miog:GetSeasonRaidDataOrdered()

    if(seasonRaidData) then
        return seasonRaidData[tierIndex] and seasonRaidData[tierIndex].numOfBosses

    end
end

function miog:GetRaiderIOProfile(playerName, realm, region)
	if(RaiderIO) then
		return RaiderIO.GetProfile(playerName, realm or GetNormalizedRealmName(), region)

	end
end

function miog:GetRaidTierDataViaRaiderIO(playerName, realm, region)
    local profile = self:GetRaiderIOProfile(playerName, realm, region)
    local currentSeason = C_MythicPlus.GetCurrentSeason()

    local mapsDone = {}

	if(profile and profile.raidProfile) then
        local seasonRaidData = miog:GetSeasonRaidDataOrdered()
        local tiers = {sortedEntries = {}}
        local raidProgress = profile.raidProfile.raidProgress
        local sortedEntriesIndex = 0

        for i = 1, #raidProgress do
            local v = raidProgress[i]

            if(not v.isMainProgress) then
                local currentTier
                local tierIndex

                if(v.current) then
                    tiers[1] = tiers[1] or {
                        current = true,
                        numOfBosses = 0,
                        tierWeight = 0,
                        difficulties = {},
                        sortedDifficulties = {},
                        mapID = v.raid.mapId,
                    }
                    currentTier = tiers[1]
                    tierIndex = 1

                else
                    tiers[2] = tiers[2] or {
                        current = false,
                        numOfBosses = 0,
                        tierWeight = 0,
                        difficulties = {},
                        sortedDifficulties = {},
                        mapID = v.raid.mapId,
                    }
                    currentTier = tiers[2]
                    tierIndex = 2

                end

                local bossIndexInfo = miog:GetSeasonRaidDataWithMapID(v.raid.mapId)

                for x, y in ipairs(v.progress) do
                    currentTier.difficulties[y.difficulty] = currentTier.difficulties[y.difficulty] or {
                        difficulty = y.difficulty,
                        difficultyID = getBlizzardDifficulty(y.difficulty),
                        current = v.current,
                        killedBosses = 0,
                        bosses = {},
                        tierIndex = tierIndex,
                    }

                    local difficultyTable = currentTier.difficulties[y.difficulty]
                    local kills = 0
                    
                    if(bossIndexInfo) then
                        for _, bossData in ipairs(y.progress) do
                            local bossTierIndex = bossIndexInfo[bossData.index]

                            difficultyTable.bosses[bossTierIndex] = bossData.killed

                            if(bossData.killed) then
                                kills = kills + 1

                            end
                        end

                        difficultyTable.killedBosses = difficultyTable.killedBosses + kills

                    end
                end

                currentTier.name = currentTier.name and currentTier.name .. "/" .. v.raid.shortName or v.raid.shortName

                if(not mapsDone[v.raid.mapId]) then
                    currentTier.numOfBosses = currentTier.numOfBosses + v.raid.bossCount

                    mapsDone[v.raid.mapId] = true
                end
            end
        end

        for i = 1, 2 do
            local currentTier = tiers[i]

            if currentTier then
                local sortedDiffs = currentTier.sortedDifficulties
                local sortedDiffsIndex = 0
                local numOfBosses = currentTier.numOfBosses
                local tierWeight = 0

                for _, diffTable in pairs(currentTier.difficulties) do
                    local weight = calcScore(diffTable.difficulty, diffTable.killedBosses, diffTable.current)
                    diffTable.weight = weight
                    diffTable.cleared = (diffTable.killedBosses == numOfBosses)

                    -- 7. Direct index assignment instead of tinsert
                    sortedDiffsIndex = sortedDiffsIndex + 1
                    sortedDiffs[sortedDiffsIndex] = diffTable

                    sortedEntriesIndex = sortedEntriesIndex + 1
                    tiers.sortedEntries[sortedEntriesIndex] = diffTable

                    tierWeight = tierWeight + weight
                end
                
                currentTier.tierWeight = tierWeight

                table.sort(sortedDiffs, function(k1, k2)
                    return k1.difficulty > k2.difficulty
                end)
            end
        end

        table.sort(tiers.sortedEntries, function(k1, k2)
            return k1.weight > k2.weight

        end)

        return tiers
    end
end

function miog:GetMythicPlusDataViaRaiderIO(playerName, realm, region)
	local profile = self:GetRaiderIOProfile(playerName, realm, region)

	if(profile) then
		local mplusData = {}
		local intimeInfo, overtimeInfo
		local keystoneProfile = profile.mythicKeystoneProfile

		if(keystoneProfile) then
			local sortedDungeons = profile.mythicKeystoneProfile.sortedDungeons
			
			if(sortedDungeons) then
				for i, dungeonEntry in ipairs(sortedDungeons) do
                    mplusData[dungeonEntry.dungeon.keystone_instance] = {
                        level = dungeonEntry.level,
                        chests = dungeonEntry.chests
                    }

				end
			end

            mplusData.mplusCurrent = keystoneProfile.mplusCurrent
            mplusData.mplusPrevious = keystoneProfile.mplusPrevious
    
            mplusData.mplusMainCurrent = keystoneProfile.mplusMainCurrent
            mplusData.mplusMainPrevious = keystoneProfile.mplusMainPrevious
    
            mplusData.keystoneMilestone2 = keystoneProfile.keystoneMilestone2
            mplusData.keystoneMilestone4 = keystoneProfile.keystoneMilestone4
            mplusData.keystoneMilestone7 = keystoneProfile.keystoneMilestone7
            mplusData.keystoneMilestone10 = keystoneProfile.keystoneMilestone10
            mplusData.keystoneMilestone12 = keystoneProfile.keystoneMilestone12
            mplusData.keystoneMilestone15 = keystoneProfile.keystoneMilestone15


		else
            mplusData.mplusCurrent = {score = 0}
            mplusData.mplusPrevious = {score = 0}
    
            mplusData.mplusMainCurrent = {score = 0}
            mplusData.mplusMainPrevious = {score = 0}
    
            mplusData.keystoneMilestone2 = 0
            mplusData.keystoneMilestone4 = 0
            mplusData.keystoneMilestone7 = 0
            mplusData.keystoneMilestone10 = 0
            mplusData.keystoneMilestone12 = 0
            mplusData.keystoneMilestone15 = 0

		end

		return mplusData, intimeInfo, overtimeInfo
	end
end

function miog:GetOrderedMythicPlusMapTable()
    local mapTable = C_ChallengeMode.GetMapTable()
    local orderedMapTable = {}

    for k, mapChallengeModeID in ipairs(mapTable) do
        local name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
        local mapInfo = miog:GetMapInfo(mapID)
        tinsert(orderedMapTable, {id = id, name = name, texture = texture, abbreviatedName = mapInfo.abbreviatedName, activityID = mapInfo.activityID})
    end

    table.sort(orderedMapTable, function(k1, k2)
        return k1.name < k2.name

    end)

    return orderedMapTable
end