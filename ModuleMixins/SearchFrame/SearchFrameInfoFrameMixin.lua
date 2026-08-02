local addonName, miog = ...

local function calculateWeightedScore(difficulty, kills, bossCount, current)
	if kills == 0 then return 0 end

	local seasonFactor = current and 100 or 1 -- Increase impact of current season
	return ((difficulty * 5) * 30 + (kills / bossCount * 20)) * seasonFactor
end

SearchFrameInfoFrameMixin = CreateFromMixins(SearchFrameBaseFrameMixin)

function SearchFrameInfoFrameMixin:GetRaiderIOProfile(playerName, realm, region)
	if(RaiderIO) then
		return RaiderIO.GetProfile(playerName, realm or GetNormalizedRealmName(), region)

	end
end

local tierData = {
    [1] = {
        mapIDs = {2912, 2939, 2913, 1592},
        numOfBosses = 0,
        bosses = {
            [2912] = {1,2,3,4,5,6,7,8,9},
            [1592] = {10}
        }
    },
    [2] = {
        mapIDs = {3004},
        numOfBosses = 0,
        bosses = {
            [3004] = {1,2,3,4,5,6,7,8},
        }
    }
}

local function getBlizzardDifficulty(raiderIODifficulty)
	if(raiderIODifficulty == 1) then
		return 14

	elseif(raiderIODifficulty == 2) then
		return 15

	elseif(raiderIODifficulty == 3) then
		return 16

	end
end

function SearchFrameInfoFrameMixin:GetRaidTierDataViaRaiderIO(playerName, realm, region)
    local profile = self:GetRaiderIOProfile(playerName, realm, region)

    local mapsDone = {}

	if(profile and profile.raidProfile) then
        local tiers = {}

        for k, v in ipairs(profile.raidProfile.raidProgress) do
            if(not v.isMainProgress) then
                local currentTier
                local tierIndex

                if(v.current) then
                    tiers[1] = tiers[1] or {
                        numOfBosses = 0,
                        tierWeight = 0,
                        difficulties = {}
                    }
                    currentTier = tiers[1]
                    tierIndex = 1

                else
                    tiers[2] = tiers[2] or {
                        numOfBosses = 0,
                        tierWeight = 0,
                        difficulties = {}
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
                        cleared = y.cleared,
                        weight = calculateWeightedScore(y.difficulty, y.kills, v.raid.bossCount, v.current),
                        bosses = {}
                    }

                    local difficultyTable = currentTier.difficulties[y.difficulty]
                    
                    for bossIndex, bossData in ipairs(y.progress) do
                        local tierInfo = tierData[tierIndex]
                        local bossIndexInfo = tierInfo.bosses[v.raid.mapId]
                        local bossTierIndex = bossIndexInfo[bossData.index]

                        difficultyTable.bosses[bossTierIndex] = bossData.killed

                        if(bossData.killed) then
                            difficultyTable.killedBosses = difficultyTable.killedBosses + 1

                        end
                    end

                    currentTier.tierWeight = currentTier.tierWeight + difficultyTable.weight
                end

                table.sort(currentTier.difficulties, function(k1, k2)
                    return k1.difficulty > k2.difficulty

                end)

                currentTier.name = currentTier.name and currentTier.name .. "/" .. v.raid.shortName or v.raid.shortName

                if(not mapsDone[v.raid.mapId]) then
                    currentTier.numOfBosses = currentTier.numOfBosses + v.raid.bossCount

                    mapsDone[v.raid.mapId] = true
                end
            end
        end

        return tiers
    end
end

function SearchFrameInfoFrameMixin:GetRaidDataViaRaiderIO(playerName, realm, region)
    local profile = miog.getRaiderIOProfile(playerName, realm, region)
    if not (profile and profile.raidProfile) then return end

    local WeightedDifficulties = {}
    local InputValue = profile.raidProfile
    
    for _, raidInstance in pairs(InputValue.raidProgress) do
		if(not raidInstance.isMainProgress) then
			local raidName = raidInstance.raid.name
			local raidShortName = raidInstance.raid.shortName
			local bossCount = raidInstance.raid.bossCount
			
			for _, progressEntry in pairs(raidInstance.progress) do
				local difficulty = progressEntry.difficulty
				local tier = progressEntry.tier
				local kills = progressEntry.kills
				
				if tier ~= nil and kills ~= nil then
					local weight = calculateWeightedScore(difficulty, kills, bossCount, raidInstance.current)
					
					table.insert(WeightedDifficulties, {
						raidName = raidName,
						shortName = raidShortName,
						difficulty = difficulty,
						tier = tier,
						kills = kills,
						bossCount = bossCount,
						weight = weight,
						current = raidInstance.current,
					})
				end
			end
		end
    end
    
    table.sort(WeightedDifficulties, function(a, b)
        return a.weight > b.weight

    end)
    
    return #WeightedDifficulties > 0 and WeightedDifficulties
end

function SearchFrameInfoFrameMixin:GetMythicPlusDataViaRaiderIO(playerName, realm, region)
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

function SearchFrameInfoFrameMixin:SetupMapTable()
    local mapTable = C_ChallengeMode.GetMapTable()
    local orderedMapTable = {}

    for k, mapChallengeModeID in ipairs(mapTable) do
        local name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
        local mapInfo = miog:GetMapInfo(mapID)
        tinsert(orderedMapTable, {id = id, name = name, texture = texture, abbreviatedName = mapInfo.abbreviatedName})
    end

    table.sort(orderedMapTable, function(k1, k2)
        return k1.name < k2.name

    end)
    
    for index, mapUIInfo in ipairs(orderedMapTable) do
        local frame = self.Dungeons.childFrames[index]

        if(frame) then
            frame.id = mapUIInfo.id
            frame.Name:SetText(mapUIInfo.abbreviatedName or mapUIInfo.name)
            frame.Icon:SetTexture(mapUIInfo.texture)

        end
    end
end

function SearchFrameInfoFrameMixin:SetupRaids()
    local bossIndex = 1

    for raidIndex, tierInfo in ipairs(tierData) do
        local raidFrame = self.Raids["Raid" .. raidIndex]

        if(raidFrame) then
            local name

            for _, mapID in ipairs(tierInfo.mapIDs) do
                local mapInfo = miog:GetMapInfo(mapID)

                if(mapInfo) then
                    name = name and (name .. "/" .. mapInfo.abbreviatedName) or mapInfo.abbreviatedName

                    if(mapInfo.bosses and #mapInfo.bosses > 0) then
                        for _, bossInfo in ipairs(mapInfo.bosses) do
                            local bossFrame = raidFrame.childFrames[bossIndex]

                            if(bossFrame) then
                                SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, bossInfo.creatureDisplayInfoID)
                                bossFrame:Show()

                            end

                            bossIndex = bossIndex + 1
                        end

                        raidFrame:Show()

                    else
                        raidFrame:Hide()

                    end

                else
                    raidFrame:Hide()

                end
            end

            raidFrame.Name:SetText(name)
        end
    end
end

function SearchFrameInfoFrameMixin:Reset()
    for _, v in ipairs(self.Dungeons.childFrames) do
        v.Text:SetText(0)
        v.Text:SetTextColor(GRAY_FONT_COLOR:GetRGBA())

    end

    for i = 1, 2, 1 do
        local raidFrame = self.Raids["Raid" .. i]
 
        if(raidFrame) then
            raidFrame.Progress1:SetText("")
            raidFrame.Progress2:SetText("")

            for _, v in ipairs(raidFrame.childFrames) do
                v.Border:SetColorTexture(RED_FONT_COLOR:GetRGBA())
                v.Icon:SetDesaturated(true)

            end
        end
    end
end

function SearchFrameInfoFrameMixin:OnLoad()
    self:Reset()
    self:SetupMapTable()
    self:SetupRaids()

end

function SearchFrameInfoFrameMixin:RefreshStatus()
    self.StatusFrame:Show()

    if self.isDelisted then
        self.StatusFrame.Text:SetText("DELISTED")
        
    elseif self.hasInvitation then
        self.StatusFrame.Text:SetText("INVITED")

    elseif self.isFull then
        self.StatusFrame.Text:SetText("FULL")

    elseif self.applicationHasBeenDeclined then
        self.StatusFrame.Text:SetText("APP DECLINED")

    elseif self.invitationHasBeenDeclined then
        self.StatusFrame.Text:SetText("INVITE DECLINED")

    elseif self.applicationHasBeenCancelled then
        self.StatusFrame.Text:SetText("CANCELLED")

    elseif self.isTimedOut then
        self.StatusFrame.Text:SetText("TIMEOUT")

    else
        self.StatusFrame:Hide()

    end
    
    self.Background:SetVertexColor(1, 1, 1, 1)

end

function SearchFrameInfoFrameMixin:GetNumOfBossesForTier(tierIndex)
    local tierInfo = tierData[tierIndex].mapIDs

    for mapIndex, mapID in ipairs(tierInfo) do
        local mapInfo = miog:GetMapInfo(mapID)

        if(mapInfo) then
            tierData[tierIndex].numOfBosses = tierData[tierIndex].numOfBosses + #mapInfo.bosses
        end
    end

    return tierData[tierIndex].numOfBosses
end

function SearchFrameInfoFrameMixin:SetRealmData(realm)
    local region = miog.F.CURRENT_REGION
    local countryFlag, language = miog:GetRealmData(realm, region)
    local countryFlagTexture = countryFlag and ("|T" .. countryFlag .. ":12:12|t" .. " ") or ""

    self.Realm:SetText(countryFlagTexture .. string.upper(region or "") .. "-" .. realm .. "(" .. language .. ")")
end


function SearchFrameInfoFrameMixin:Update()
    if(IsPlayerAtEffectiveMaxLevel()) then
        local data = self:GetData()
        local searchResultInfo = miog:GetSecureSearchResultInfo(data.resultID)

        if(searchResultInfo and searchResultInfo.leaderName) then
            local nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")

            if(nameTable and not nameTable[2]) then
                nameTable[2] = GetNormalizedRealmName()

            end

            self:SetRealmData(nameTable[2])

            --M+
            local mplusData = self:GetMythicPlusDataViaRaiderIO(nameTable[1], nameTable[2])

            if(mplusData) then
                for _, v in ipairs(self.Dungeons.childFrames) do
                    local idData = mplusData[v.id]

                    if(idData) then
                        v.Text:SetText(idData.level .. (strrep(miog.C.RIO_STAR_TEXTURE, idData.chests) or ""))

                        if(idData.level == 0) then
                            v.Text:SetTextColor(GRAY_FONT_COLOR:GetRGBA())
                            
                        elseif(idData.chests > 0) then
                            v.Text:SetTextColor(GREEN_FONT_COLOR:GetRGBA())

                        else
                            v.Text:SetTextColor(RED_FONT_COLOR:GetRGBA())

                        end
                    end
                end
                
                self.KeysDone:SetText(
                    WrapTextInColorCode(mplusData.keystoneMilestone2 or "0", miog.ITEM_QUALITY_COLORS[2].pureHex) .. " - " ..
                    WrapTextInColorCode(mplusData.keystoneMilestone4 or "0", miog.ITEM_QUALITY_COLORS[3].pureHex) .. " - " ..
                    WrapTextInColorCode(mplusData.keystoneMilestone7 or "0", miog.ITEM_QUALITY_COLORS[4].pureHex) .. " - " ..
                    WrapTextInColorCode(mplusData.keystoneMilestone10 or "0", miog.ITEM_QUALITY_COLORS[5].pureHex) .. " - " ..
                    WrapTextInColorCode(mplusData.keystoneMilestone12 or "0", miog.ITEM_QUALITY_COLORS[6].pureHex) .. " - " ..
                    WrapTextInColorCode(mplusData.keystoneMilestone15 or "0", miog.ITEM_QUALITY_COLORS[7].pureHex)
                )

                if(mplusData.mplusMainCurrent and mplusData.mplusMainCurrent.score > 0) then
                    self.MainChar:SetText("Alt; Main rating is " .. mplusData.mplusMainCurrent.score)

                else
                    self.MainChar:SetText("Main")

                end
            else
                for _, v in ipairs(self.Dungeons.childFrames) do
                    v.Text:SetText(0)
                    v.Text:SetTextColor(GRAY_FONT_COLOR:GetRGBA())
                        
                end
            end

            --Raid
            local raidData = self:GetRaidTierDataViaRaiderIO(nameTable[1], nameTable[2])
            local bossesKilled = {}
            
            if(raidData) then
                for k, v in ipairs(raidData) do
                    local tierBosses = tierData[k].numOfBosses
                    local numOfBosses = tierBosses ~= 0 and tierBosses or self:GetNumOfBossesForTier(k)

                    local raidFrame = self.Raids["Raid" .. k]
                    
                    if(raidFrame) then
                        for i = 1, 3, 1 do
                            local difficultyData = v.difficulties[i]

                            if(difficultyData) then
                                local currentProgress = raidFrame.Progress1:GetText() == nil and raidFrame.Progress1 or raidFrame.Progress2:GetText() == nil and raidFrame.Progress2

                                if(currentProgress) then
                                    currentProgress:SetText(difficultyData.killedBosses .. "/" .. numOfBosses)

                                    for bossIndex = 1, 10, 1 do
                                        local bossKilled = difficultyData.bosses[bossIndex]

                                        if(bossKilled) then
                                            local bossFrame = raidFrame.childFrames[bossIndex]
                                            
                                            if(bossFrame) then
                                                if(not bossesKilled[bossIndex] or difficultyData.difficulty > bossesKilled[bossIndex]) then
                                                    bossFrame.Border:SetColorTexture(miog.DIFFICULTY[difficultyData.difficulty].miogColors:GetRGBA());
                                                    bossesKilled[bossIndex] = difficultyData.difficulty
                                                    bossFrame.Icon:SetDesaturated(false)

                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        self:SetStatus(searchResultInfo)
        
    else
        self:Reset()

    end
end