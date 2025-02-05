local addonName, miog = ...

RaiderIOInformationPanelMixin = {}

MIOG_FAILSAFE_SEASON_ID = 13

function RaiderIOInformationPanelMixin:RetrieveRelevantGroups()
    local mythicPlusInfo = {}
    local raidInfo = {}
    
    for k, v in ipairs(C_LFGList.GetAvailableActivityGroups(2, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE))) do
        local activities = C_LFGList.GetAvailableActivities(2, v)
        local activityID = activities[#activities]

        tinsert(mythicPlusInfo, {name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, mapID = miog.ACTIVITY_INFO[activityID].mapID})
    end

    table.sort(mythicPlusInfo, function(k1, k2)
        return k1.name < k2.name
    end)

    self.mythicPlusInfo = mythicPlusInfo

    local raidGroups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.CategorySelection.selectedFilters or LFGListFrame.CategorySelection.baseFilters);

    for k, v in ipairs(raidGroups) do
        local activities = C_LFGList.GetAvailableActivities(3, v)
        local activityID = activities[#activities]

        tinsert(raidInfo, {name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, mapID = miog.ACTIVITY_INFO[activityID].mapID})
    end
    
    self.raidInfo = raidInfo
end

function RaiderIOInformationPanelMixin:OnLoadMPlus()
    if(self.mythicPlusInfo) then
        local done = {}
        local k = 1

        for _, data in ipairs(self.mythicPlusInfo) do
            if(not done[data.mapID]) then
                local currentDungeon = self.MythicPlus["Dungeon" .. k]
                local mapData = miog.MAP_INFO[data.mapID]

                currentDungeon.dungeonName = mapData.name

                if(currentDungeon.Name) then
                    currentDungeon.Name:SetText(mapData.shortName)
                    
                end

                miog.checkSingleMapIDForNewData(data.mapID, nil, true)

                currentDungeon.Icon:SetTexture(self.mode == "side" and mapData.horizontal or mapData.icon)
                currentDungeon.Icon:SetDesaturation(0)
                currentDungeon.Icon:SetScript("OnMouseDown", function()
                    local instanceID = C_EncounterJournal.GetInstanceForGameMap(data.mapID)
                    local difficulty = 23

                    --difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
                    EncounterJournal_OpenJournal(difficulty, instanceID, nil, nil, nil, nil)

                end)

                done[data.mapID] = true

                k = k + 1
            end
        end
    end
end

function RaiderIOInformationPanelMixin:SetMode(mode)
    self.mode = mode
end

function RaiderIOInformationPanelMixin:SetupRaidFrame(raidFrame, v, isMainsFrame) --mapID
    local raidHeaderFrame = raidFrame.Header

    miog.checkSingleMapIDForNewData(v, nil, true)

    if(raidHeaderFrame.Progress1) then
        raidHeaderFrame.Progress1:SetText(WrapTextInColorCode("0/"..#miog.MAP_INFO[v].bosses, miog.CLRSCC.red))
        raidHeaderFrame.Progress2:SetText(WrapTextInColorCode("0/"..#miog.MAP_INFO[v].bosses, miog.CLRSCC.red))

    elseif(raidFrame.Bosses.Progress1) then
        raidFrame.Bosses.Progress1:SetMinMaxValues(0, 10)
        raidFrame.Bosses.Progress2:SetMinMaxValues(0, 10)

    end

    local hasIcon = self.Raids.Raid1.Header.Icon
    local texture = hasIcon and raidHeaderFrame.Icon or raidFrame.Background

    texture:SetTexture(hasIcon and miog.MAP_INFO[v].icon or miog.MAP_INFO[v].horizontal)
    texture:SetScript("OnMouseDown", function()
        local instanceID = C_EncounterJournal.GetInstanceForGameMap(v)
        local difficulty = 16
        --difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
        EncounterJournal_OpenJournal(difficulty, instanceID, nil, nil, nil, nil)

    end)

    raidHeaderFrame.Name:SetText(miog.MAP_INFO[v].shortName .. (isMainsFrame and "[Main]" or ""))

    for i = 1, 10, 1 do
        local currentBoss = "Boss" .. i

        if(miog.MAP_INFO[v].bosses[i]) then
            if(raidFrame.Bosses[currentBoss].Index) then
                raidFrame.Bosses[currentBoss].Index:SetText(i)

            end

            raidFrame.Bosses[currentBoss].name = miog.MAP_INFO[v].bosses[i].name
            raidFrame.Bosses[currentBoss].Icon:SetTexture(miog.MAP_INFO[v].bosses[i].icon)
            raidFrame.Bosses[currentBoss].Icon:SetScript("OnMouseDown", function()
                local instanceID = C_EncounterJournal.GetInstanceForGameMap(v)
                local difficulty = 16
                EncounterJournal_OpenJournal(difficulty, instanceID, select(3, EJ_GetEncounterInfoByIndex(i, instanceID)), nil, nil, nil)
            end)

            if(raidFrame.Bosses[currentBoss].Border) then
                raidFrame.Bosses[currentBoss].Border:SetColorTexture(1, 0, 0, 1);

            end

            raidFrame.Bosses[currentBoss].Icon:SetDesaturated(true)

            raidFrame.Bosses[currentBoss]:Show()

        else
            raidFrame.Bosses[currentBoss]:Hide()

        end
    end

    raidFrame:Show()
end

function RaiderIOInformationPanelMixin:OnLoadRaid()
    local raidCounter = 1

    local lastID

    for k, data in ipairs(self.raidInfo) do
        local raidFrame = self.Raids["Raid" .. raidCounter]

        if(raidFrame) then
            self:SetupRaidFrame(raidFrame, data.mapID)

            raidCounter = raidCounter + 1

            lastID = data.mapID
        end
    end

    if(self.Raids["Raid" .. raidCounter] and lastID) then
        self:SetupRaidFrame(self.Raids["Raid" .. raidCounter], lastID, true) --main's raid frame

    end
end

function RaiderIOInformationPanelMixin:OnLoad(mode)
    self:SetMode(mode)
    
    --self.seasonID = C_MythicPlus.GetCurrentSeason() > 0 and C_MythicPlus.GetCurrentSeason() or MIOG_FAILSAFE_SEASON_ID
    self.seasonID = MIOG_FAILSAFE_SEASON_ID

    self:RetrieveRelevantGroups()

	self:OnLoadMPlus()
    self:OnLoadRaid()
	
end

function RaiderIOInformationPanelMixin:Flush()
    self.playerName = nil
    self.realm = nil
    self.region = nil

    self.mplusData = nil
    self.raidData = nil
    self.comment = nil
    self.realm = nil
    self.roles = nil
    self.race = nil

    self:OnLoad(self.mode)
end

function RaiderIOInformationPanelMixin:CalculatePanelHeight()
    if(self.Comment) then
        if(self.comment and self.comment ~= "") then
            self.Comment:Show()
            self:SetHeight(200)

        else
            self.Comment:Hide()
            self:SetHeight(160)

        end
    end
end

function RaiderIOInformationPanelMixin:SetFillData(mplusData, raidData, server, comment, roles, race)
    self.mplusData = mplusData
    self.raidData = raidData
    self.comment = comment
    self.realm = server
    self.roles = roles
    self.race = race
end

function RaiderIOInformationPanelMixin:SetPlayerData(playerName, server, region)
    self.playerName = playerName
    self.realm = server
    self.region = region
end

function RaiderIOInformationPanelMixin:SetOptionalData(comment, server, roles, race)
    self.comment = comment
    self.realm = server
    self.roles = roles
    self.race = race
end

function RaiderIOInformationPanelMixin:RequestFillData()
    self.mplusData = miog.getMPlusSortData(self.playerName, self.realm, self.region)
    self.raidData = miog.getNewRaidSortData(self.playerName, self.realm, self.region)
end

function RaiderIOInformationPanelMixin:ApplyMythicPlusData(refreshData)
    self.mplusData = not refreshData and self.mplusData or miog.getMPlusSortData(self.playerName, self.realm, self.region)

    local done = {}
    local k = 1

    for _, data in ipairs(self.mythicPlusInfo) do
        if(not done[data.mapID]) then
            local currentDungeon = self.MythicPlus["Dungeon" .. k]

            if(self.mplusData and self.mplusData[data.mapID]) then
                currentDungeon.Level:SetText(WrapTextInColorCode(self.mplusData and (self.mplusData[data.mapID].level .. " " .. strrep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or self.mplusData[data.mapID].chests)) or 0, self.mplusData and self.mplusData[data.mapID].chests > 0 and miog.C.GREEN_COLOR or miog.CLRSCC.red))

                if(self.mplusData[data.mapID].level == 0) then
                    currentDungeon.Icon:SetDesaturation(0.7)
                end
            else
                currentDungeon.Level:SetText(WrapTextInColorCode(0, miog.CLRSCC.red))
                currentDungeon.Icon:SetDesaturation(0.7)

            end

            done[data.mapID] = true
            k = k + 1
        end
    end

	if(self.mplusData) then
        if(self.PreviousData) then
            if(self.mplusData.previousScore.score > 0) then
                self.PreviousData:SetText("Best m+ rating (S" .. self.mplusData.previousScore.season .. "): " .. WrapTextInColorCode(self.mplusData.previousScore.score, miog.createCustomColorForRating(self.mplusData.previousScore.score):GenerateHexColor()))

            else
                self.PreviousData:SetText("No previous m+ rating")
                
            end
        end

        if(self.MainData) then
            if(self.mplusData.mainScore.score > 0) then
                self.MainData:SetText("Main: " .. WrapTextInColorCode(self.mplusData.mainScore.score, miog.createCustomColorForRating(self.mplusData.mainScore.score):GenerateHexColor()))

                if(self.mplusData.mainPreviousScore.score > 0) then
                    self.MainData:SetText(self.MainData:GetText() .. " (S" .. self.mplusData.mainPreviousScore.season .. ": ".. (self.mplusData.mainPreviousScore and WrapTextInColorCode(self.mplusData.mainPreviousScore.score, miog.createCustomColorForRating(self.mplusData.mainPreviousScore.score):GenerateHexColor()) .. ")" or "N/A"))
                    
                else
                    self.MainData:SetText(self.MainData:GetText() .. " (No previous m+ rating)")
        
                end
            else
                self.MainData:SetText(WrapTextInColorCode("Main m+ char. ", miog.ITEM_QUALITY_COLORS[7].pureHex))

            end
        end

        if(self.MPlusKeys) then
            self.MPlusKeys:SetText("M+ Keys done: " ..
                WrapTextInColorCode(self.mplusData.keystoneMilestone2 or "0", miog.ITEM_QUALITY_COLORS[2].pureHex) .. " - " ..
                WrapTextInColorCode(self.mplusData.keystoneMilestone4 or "0", miog.ITEM_QUALITY_COLORS[3].pureHex) .. " - " ..
                WrapTextInColorCode(self.mplusData.keystoneMilestone7 or "0", miog.ITEM_QUALITY_COLORS[4].pureHex) .. " - " ..
                WrapTextInColorCode(self.mplusData.keystoneMilestone10 or "0", miog.ITEM_QUALITY_COLORS[5].pureHex) .. " - " ..
                WrapTextInColorCode(self.mplusData.keystoneMilestone12 or "0", miog.ITEM_QUALITY_COLORS[6].pureHex) .. " - " ..
                WrapTextInColorCode(self.mplusData.keystoneMilestone15 or "0", miog.ITEM_QUALITY_COLORS[7].pureHex)
            )
        end

	else
        if(self.PreviousData and self.MainData and self.MPlusKeys) then
            self.PreviousData:SetText("No previous m+ rating. ")
            self.MainData:SetText("No main m+ rating. ")
            self.MPlusKeys:SetText("No m+ keys done.")
        end
	end
end

function RaiderIOInformationPanelMixin:ApplyRaidData(refreshData)
    self.raidData = not refreshData and self.raidData or miog.getNewRaidSortData(self.playerName, self.realm, self.region)

	local raidMapIDSet = {}
	local mainRaidMapIDSet = {}
    local hasIcon = self.Raids.Raid1.Header.Icon
    
    if(self.raidData) then
        local raidCounter = 1

	    for k, data in ipairs(self.raidInfo) do
            for nmd = 1, 2, 1 do
                local raidFrame = self.Raids["Raid" .. raidCounter]

                if(raidFrame) then
                    local raidHeaderFrame = self.Raids["Raid" .. raidCounter].Header
                    local normalOrMainData = nmd == 1 and self.raidData.character or self.raidData.main

                    if(normalOrMainData.raids[data.mapID]) then    
                        local bossesDone = {}
    
                        for i = 1, 2, 1 do
                            local currentTable = i == 1 and normalOrMainData.raids[data.mapID].awakened or normalOrMainData.raids[data.mapID].regular
    
                            if(currentTable) then
                                for a = 3, 1, -1 do
                                    if(currentTable.difficulties[a]) then
                                        for z = 1, 10, 1 do
                                            if(currentTable.difficulties[a].bosses[z] and not bossesDone[z]) then
                                                local currentBoss = "Boss" .. z
    
                                                if(currentTable.difficulties[a].bosses[z].killed) then
    
                                                    if(raidFrame.Bosses[currentBoss].Border) then
                                                        raidFrame.Bosses[currentBoss].Border:SetColorTexture(miog.DIFFICULTY[a].miogColors:GetRGBA());
    
                                                    end
    
                                                    raidFrame.Bosses[currentBoss].Icon:SetDesaturated(false)
                                                    bossesDone[z] = true
                                    
                                                end
                                            end
                                        end
    
                                        if(nmd == 1 and raidMapIDSet[data.mapID] ~= true or nmd == 2 and mainRaidMapIDSet[data.mapID] ~= true) then
                                            if(normalOrMainData.raids[data.mapID].isAwakened) then
                                                raidHeaderFrame.Name:SetText(normalOrMainData.raids[data.mapID].shortName)
                                            end
    
                                            if(raidHeaderFrame.Progress1) then --miog.DIFFICULTY[a].shortName .. ":" .. 
                                                raidHeaderFrame.Progress1:SetText(WrapTextInColorCode(currentTable.difficulties[a].parsedString, miog.DIFFICULTY[a].color))
    
                                            elseif(raidFrame.Bosses.Progress1) then
                                                raidFrame.Bosses.Progress1:SetStatusBarColor(miog.DIFFICULTY[a].baseColor.color:GetRGBA())
    
                                            end
    
                                            if(currentTable.difficulties[a-1]) then
                                                if(raidHeaderFrame.Progress2) then --miog.DIFFICULTY[a-1].shortName .. ":" .. 
                                                    raidHeaderFrame.Progress2:SetText(WrapTextInColorCode(currentTable.difficulties[a-1].parsedString, miog.DIFFICULTY[a-1].color))
    
                                                elseif(raidFrame.Bosses.Progress2) then
                                                    raidFrame.Bosses.Progress2:SetStatusBarColor(miog.DIFFICULTY[a-1].baseColor.color:GetRGBA())
    
                                                end
                                            end
    
                                            local texture = hasIcon and raidHeaderFrame.Icon or raidFrame.Background
                                            texture:SetScript("OnMouseDown", function()
                                                local instanceID = C_EncounterJournal.GetInstanceForGameMap(data.mapID)
                                                local difficulty = a == 1 and 14 or a == 2 and 15 or 16
                                                --difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
                                                EncounterJournal_OpenJournal(difficulty, instanceID, nil, nil, nil, nil)
                        
                                            end)
    
                                            if(nmd == 1) then
                                                raidMapIDSet[data.mapID] = true
    
                                            elseif(nmd == 2) then
                                                mainRaidMapIDSet[data.mapID] = true
    
                                            end
    
                                            raidCounter = raidCounter + 1
    
    
                                        end
                                    end
                                end
                            else
                                for z = 1, 10, 1 do
                                    local currentBoss = "Boss" .. z
                                    raidFrame.Bosses[currentBoss].Icon:SetDesaturated(true)
    
                                end
                            end
                        end
                    end
                end

                
            end
        end
	end
end

function RaiderIOInformationPanelMixin:ApplyFillData(refreshData)
    self:CalculatePanelHeight()

    if(self.RaceRolesServer) then
        self.RaceRolesServer:SetText(string.upper(miog.F.CURRENT_REGION or "") .. "-" .. (self.realm or GetRealmName() or "") .. " ")
        
        if(self.roles) then
            if(self.roles.tank) then
                self.RaceRolesServer:SetText(self.RaceRolesServer:GetText() .. miog.C.TANK_TEXTURE .. " ")

            end

            if(self.roles.healer) then
                self.RaceRolesServer:SetText(self.RaceRolesServer:GetText() .. miog.C.HEALER_TEXTURE .. " ")

            end

            if(self.roles.damager) then
                self.RaceRolesServer:SetText(self.RaceRolesServer:GetText() .. miog.C.DPS_TEXTURE .. " ")

            end
        end
    end

    self:ApplyMythicPlusData(refreshData)
    self:ApplyRaidData(refreshData)

    if(self.Comment and self.comment) then
	    self.Comment:SetText(_G["COMMENTS_COLON"] .. " " .. ((self.comment and self.comment) or ""))
    end
end