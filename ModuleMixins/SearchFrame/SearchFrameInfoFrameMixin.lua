local addonName, miog = ...


local tierMapIDs = {
    [1] = {2912, 2939, 2913, 1592}
}

SearchFrameInfoFrameMixin = CreateFromMixins(SearchFrameBaseFrameMixin)

function SearchFrameInfoFrameMixin:GetRaiderIOProfile(playerName, realm, region)
	if(RaiderIO) then
		return RaiderIO.GetProfile(playerName, realm or GetNormalizedRealmName(), region)

	end
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

    for raidIndex, mapTable in ipairs(tierMapIDs) do
        local raidFrame = self.Raids["Raid" .. raidIndex]
        local name

        for k, mapID in ipairs(mapTable) do
            local mapInfo = miog:GetMapInfo(mapID)
            name = name and (name .. "/" .. mapInfo.abbreviatedName) or mapInfo.abbreviatedName

            for mapBossIndex, bossInfo in ipairs(mapInfo.bosses) do
                local bossFrame = raidFrame.childFrames[bossIndex]

                if(bossFrame) then
                    SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, bossInfo.creatureDisplayInfoID)

                end

                bossIndex = bossIndex + 1
            end
        end

        raidFrame.Name:SetText(name)
    end
end

function SearchFrameInfoFrameMixin:Reset()

end

function SearchFrameInfoFrameMixin:OnLoad()
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


function SearchFrameInfoFrameMixin:Update()
    if(IsPlayerAtEffectiveMaxLevel()) then
        local data = self:GetData()
        local searchResultInfo = miog:GetSecureSearchResultInfo(data.resultID)

        if(searchResultInfo and searchResultInfo.leaderName) then
            local nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")

            if(nameTable and not nameTable[2]) then
                nameTable[2] = GetNormalizedRealmName()

            end

            local mplusData = self:GetMythicPlusDataViaRaiderIO(nameTable[1], nameTable[2])

            if(mplusData) then
                for _, v in ipairs(self.Dungeons.childFrames) do
                    local idData = mplusData[v.id]

                    if(idData) then
                        v.Text:SetText(idData.level)
                        
                    end
                end

            else
                for _, v in ipairs(self.Dungeons.childFrames) do
                    v.Text:SetText(0)
                        
                end
            end
        end

        self:SetStatus(searchResultInfo)
        self:UpdateVisuals(searchResultInfo)
        
    else
        self:Reset()

    end
end