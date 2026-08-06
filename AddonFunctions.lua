local addonName, miog = ...

local function calculateWeightedScore(difficulty, kills, bossCount, current)
	if kills == 0 then return 0 end

	local seasonFactor = current and 100 or 1 -- Increase impact of current season
	return ((difficulty * 5) * 30 + (kills / bossCount * 20)) * seasonFactor
end

local function calcScore(difficulty, kills, current)
    return not current and (kills * 1) or ((100 + kills) ^ difficulty)
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

function miog:GetNumOfBossesForTier(tierIndex)
    local seasonRaidData = miog:GetSeasonRaidData()

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

    local mapsDone = {}

	if(profile and profile.raidProfile) then
        local seasonRaidData = miog:GetSeasonRaidData()
        local tiers = {sortedEntries = {}}

        for k, v in ipairs(profile.raidProfile.raidProgress) do
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
                    }
                    currentTier = tiers[2]
                    tierIndex = 2

                end

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
                    
                    for bossIndex, bossData in ipairs(y.progress) do
                        local tierInfo = seasonRaidData[tierIndex]
                        local bossIndexInfo = tierInfo.bosses[v.raid.mapId]
                        local bossTierIndex = bossIndexInfo[bossData.index]

                        difficultyTable.bosses[bossTierIndex] = bossData.killed

                        if(bossData.killed) then
                            difficultyTable.killedBosses = difficultyTable.killedBosses + 1

                        end
                    end
                end

                currentTier.name = currentTier.name and currentTier.name .. "/" .. v.raid.shortName or v.raid.shortName

                if(not mapsDone[v.raid.mapId]) then
                    currentTier.numOfBosses = currentTier.numOfBosses + v.raid.bossCount

                    mapsDone[v.raid.mapId] = true
                end
            end
        end

        for k, v in ipairs(tiers) do
            for x, y in pairs(v.difficulties) do
                y.weight = calcScore(y.difficulty, y.killedBosses, y.current)
                y.cleared = y.killedBosses == v.numOfBosses

                tinsert(v.sortedDifficulties, y)
                tinsert(tiers.sortedEntries, y)

                v.tierWeight = v.tierWeight + y.weight

            end

            table.sort(v.sortedDifficulties, function(k1, k2)
                return k1.difficulty > k2.difficulty

            end)
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