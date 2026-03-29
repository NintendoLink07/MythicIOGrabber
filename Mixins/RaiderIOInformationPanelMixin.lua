local addonName, miog = ...

RaiderIOInformationPanelMixin = {}

MIOG_FAILSAFE_SEASON_ID = 13

function RaiderIOInformationPanelMixin:HasRaidInfo()
    return self.raidInfo and #self.raidInfo > 0
end

function RaiderIOInformationPanelMixin:GetAndSortMythicPlus()
	local mapTable = C_ChallengeMode.GetMapTable()

	table.sort(mapTable, function(k1, k2)
		return miog.retrieveAbbreviatedNameFromChallengeModeMap(k1) < miog.retrieveAbbreviatedNameFromChallengeModeMap(k2)

	end)

	return mapTable
end

function RaiderIOInformationPanelMixin:RetrieveRelevantGroups()
    self.mythicPlusInfo = self:GetAndSortMythicPlus()
    self.raidInfo = miog.retrieveCurrentRaidActivityIDs(true)

end

function RaiderIOInformationPanelMixin:OnLoadMPlus()
    if(self.mythicPlusInfo) then
        local done = {}
        local k = 1

        for _, mapChallengeModeID in ipairs(self.mythicPlusInfo) do
            local name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)

            if(not done[mapChallengeModeID]) then
                local currentDungeon = self.MythicPlus["Dungeon" .. k]
                local info = miog:GetMapInfo(mapID)

                currentDungeon.dungeonName = name

                if(currentDungeon.Name) then
                    currentDungeon.Name:SetText(miog.retrieveAbbreviatedNameFromChallengeModeMap(mapChallengeModeID))
                    
                end

                currentDungeon.Icon:SetTexture(self.mode == "side" and info.horizontal or info.icon)
                currentDungeon.Icon:SetDesaturation(0)
                currentDungeon.Icon:SetScript("OnMouseDown", function()
                    local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
                    local difficulty = 23

                    miog:OpenEncounterJournal(difficulty, instanceID)

                end)

                done[mapChallengeModeID] = true

                k = k + 1
            end
        end
    end
end

function RaiderIOInformationPanelMixin:SetMode(mode)
    self.mode = mode
end

function RaiderIOInformationPanelMixin:SetupRaidFrame(raidFrame, mapID, isMainsFrame) --mapID
    local raidHeaderFrame = raidFrame.Header

    local mapInfo = miog:GetMapInfo(mapID)

    if(mapInfo) then
        local numBosses = mapInfo.numOfBosses or 0

        if(raidHeaderFrame.Progress1) then
            raidHeaderFrame.Progress1:SetText(WrapTextInColorCode("0/"..numBosses, miog.CLRSCC.red))
            raidHeaderFrame.Progress2:SetText(WrapTextInColorCode("0/"..numBosses, miog.CLRSCC.red))

        elseif(raidFrame.Bosses.Progress1) then
            raidFrame.Bosses.Progress1:SetMinMaxValues(0, 10)
            raidFrame.Bosses.Progress2:SetMinMaxValues(0, 10)

        end

        local hasIcon = self.Raids.Raid1.Header.Icon
        local texture = hasIcon and raidHeaderFrame.Icon or raidFrame.Background

        if(texture) then
            texture:SetTexture(hasIcon and mapInfo.icon or mapInfo.horizontal)
            texture:SetScript("OnMouseDown", function()
                local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
                local difficulty = 16

                miog:OpenEncounterJournal(difficulty, instanceID)

            end)
        end

        raidHeaderFrame.Name:SetText(mapInfo.abbreviatedName .. (isMainsFrame and "[Main]" or ""))

        if(mapInfo.bosses) then
            local bossIcons = mapInfo.bossIcons or {}

            for i = 1, 10, 1 do
                local bossFrame = raidFrame.Bosses["Boss" .. i]
                local bossInfo = mapInfo.bosses[i]

                if(bossInfo) then
                    if(bossFrame.Index) then
                        bossFrame.Index:SetText(i)

                    end

                    bossFrame.name = bossInfo.name

                    if(bossIcons[i]) then
                        bossFrame.Icon:SetTexture(bossIcons[i].icon)

                    end

                    bossFrame.Icon:SetDesaturated(true)
                    bossFrame.Icon:SetScript("OnMouseDown", function()
                        local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
                        local difficulty = 16

                        miog:OpenEncounterJournal(difficulty, instanceID, bossInfo.journalEncounterID)
                    end)

                    if(bossFrame.Border) then
                        bossFrame.Border:SetColorTexture(1, 0, 0, 1);

                    end


                    bossFrame:Show()

                else
                    bossFrame:Hide()

                end
            end
        end

        raidFrame:Show()
    end
end

function RaiderIOInformationPanelMixin:OnLoadRaid()
    local raidCounter = 1

    local firstID

    for k = 1, 2, 1 do
        local data = self.raidInfo[k]

        if(data) then
            local raidFrame = self.Raids["Raid" .. raidCounter]

            if(raidFrame) then
                self:SetupRaidFrame(raidFrame, data.mapID)

                raidCounter = raidCounter + 1

                if(k == 1) then
                    firstID = data.mapID

                end

                self.raidFrames[data.mapID] = raidFrame
            end
        end
    end

    if(self.Raids["Raid" .. raidCounter] and firstID) then
        self:SetupRaidFrame(self.Raids["Raid" .. raidCounter], firstID, true) --main's raid frame

    end
end

function RaiderIOInformationPanelMixin:OnLoad(mode)
    self:SetMode(mode)

    self.raidFrames = {}
    
    --self.seasonID = C_MythicPlus.GetCurrentSeason() > 0 and C_MythicPlus.GetCurrentSeason() or MIOG_FAILSAFE_SEASON_ID
    self.seasonID = MIOG_FAILSAFE_SEASON_ID

    self:RetrieveRelevantGroups()

	self:OnLoadMPlus()
    self:OnLoadRaid()
end

function RaiderIOInformationPanelMixin:Flush()
    self.mplusData = nil
    self.raidData = nil

    if(self.RaceRolesServer) then
	    self.RaceRolesServer:SetText("")

    end

    self:SetComment()

    self:OnLoad(self.mode)
end

function RaiderIOInformationPanelMixin:CalculatePanelHeight()
    if(self.Comment) then
        if(self.Comment:GetText() ~= "") then
            self.Comment:Show()
            self:SetHeight(200)

        else
            self.Comment:Hide()
            self:SetHeight(160)

        end
    end
end

function RaiderIOInformationPanelMixin:SetComment(comment)
    if(self.Comment) then
        if(comment and comment ~= "") then
	        self.Comment:SetText(_G["COMMENTS_COLON"] .. " " .. (comment or ""))
            
        else
	        self.Comment:SetText("")

        end
    end
    
    self:CalculatePanelHeight()
end

function RaiderIOInformationPanelMixin:SetRace(raceID)
    if(raceID) then
        local text = self.RaceRolesServer:GetText() or ""
        self.RaceRolesServer:SetText(text .. "|A:" .. miog.RACES[raceID] .. "|a ")

    end
end

function RaiderIOInformationPanelMixin:AddRole(role)
    if(role) then
        local text = self.RaceRolesServer:GetText() or ""
        self.RaceRolesServer:SetText(text .. role .. " ")

    end
end

function RaiderIOInformationPanelMixin:SetRoles(rolesTable)
    if(rolesTable) then
        if(rolesTable.tank) then
            self:AddRole(miog.C.TANK_TEXTURE)

        end

        if(rolesTable.healer) then
            self:AddRole(miog.C.HEALER_TEXTURE)

        end

        if(rolesTable.damager) then
            self:AddRole(miog.C.DPS_TEXTURE)

        end
    end
end

function RaiderIOInformationPanelMixin:SetServerData(realm)
    realm = realm or GetRealmName() or ""
    local countryFlag, language = miog.getRealmData(realm, miog.F.CURRENT_REGION)

    local text = self.RaceRolesServer:GetText() or ""
    self.RaceRolesServer:SetText(text .. (countryFlag and ("|T" .. countryFlag .. ":12:12|t" .. " ") or "") .. string.upper(miog.F.CURRENT_REGION or "") .. "-" .. realm .. "(" .. language .. ")")
end

function RaiderIOInformationPanelMixin:SetOptionalData(comment, rolesTable, raceID)
    self:SetComment(comment)
    self:SetRace(raceID)
    self:SetRoles(rolesTable)

end

function RaiderIOInformationPanelMixin:ApplyMythicPlusData(refreshData, playerName, realm)
    self.mplusData = not refreshData and self.mplusData or miog.getMPlusSortData(playerName, realm, miog.F.CURRENT_REGION)

    local done = {}
    local k = 1

    for _, mapChallengeModeID in ipairs(self.mythicPlusInfo) do
        local name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
        if(not done[mapChallengeModeID]) then
            local currentDungeon = self.MythicPlus["Dungeon" .. k]

            if(self.mplusData and self.mplusData[mapChallengeModeID]) then
                currentDungeon.Level:SetText(WrapTextInColorCode(self.mplusData and (self.mplusData[mapChallengeModeID].level .. " " .. strrep(miog.C.RIO_STAR_TEXTURE, self.mplusData[mapChallengeModeID].chests)) or 0, self.mplusData and self.mplusData[mapChallengeModeID].chests > 0 and miog.C.GREEN_COLOR or miog.CLRSCC.red))

                if(self.mplusData[mapChallengeModeID].level == 0) then
                    currentDungeon.Icon:SetDesaturation(0.7)
                end
            else
                currentDungeon.Level:SetText(WrapTextInColorCode(0, miog.CLRSCC.red))
                currentDungeon.Icon:SetDesaturation(0.7)

            end

            done[mapChallengeModeID] = true
            k = k + 1
        end
    end

	if(self.mplusData) then
        if(self.PreviousData) then
            if(self.mplusData.previousScore.score > 0) then
                self.PreviousData:SetText("Best m+ rating (S" .. self.mplusData.previousScore.season + 1 .. "): " .. WrapTextInColorCode(self.mplusData.previousScore.score, miog.createCustomColorForRating(self.mplusData.previousScore.score):GenerateHexColor()))

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

function RaiderIOInformationPanelMixin:ApplyRaidData(refreshData, playerName, realm)
    self.raidData = not refreshData and self.raidData or miog.getNewRaidSortData(playerName, realm)

	local raidMapIDSet = {}
	local mainRaidMapIDSet = {}
    local hasIcon = self.Raids.Raid1.Header.Icon

    if(self.raidData) then
        local raidCounter = 1

        for k = 1, 2, 1 do
            local data = self.raidInfo[k]


	    --for k, data in ipairs(self.raidInfo) do
            if(data) then
                for nmd = 1, 2, 1 do
                    local raidFrame = nmd == 1 and self.raidFrames[data.mapID] or self.Raids["Raid3"]

                    if(raidFrame) then
                        local raidHeaderFrame = raidFrame.Header
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
                                                raidHeaderFrame.Name:SetText(normalOrMainData.raids[data.mapID].shortName)
        
                                                raidHeaderFrame.Progress1:SetText(WrapTextInColorCode(currentTable.difficulties[a].parsedString, miog.DIFFICULTY[a].color))
        
                                                if(currentTable.difficulties[a-1]) then
                                                    raidHeaderFrame.Progress2:SetText(WrapTextInColorCode(currentTable.difficulties[a-1].parsedString, miog.DIFFICULTY[a-1].color))
        
                                                end
        
                                                local texture = hasIcon and raidHeaderFrame.Icon or raidFrame.Background

                                                if(texture) then
                                                    texture:SetScript("OnMouseDown", function()
                                                        local instanceID = C_EncounterJournal.GetInstanceForGameMap(data.mapID)
                                                        local difficulty = a == 1 and 14 or a == 2 and 15 or 16

                                                        miog:OpenEncounterJournal(difficulty, instanceID)
                                
                                                    end)
                                                end
        
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
end

function RaiderIOInformationPanelMixin:ApplyFillData(type, refreshData, playerName, realm)
    if(self.RaceRolesServer) then
        self:SetServerData(realm)

    end

    if(type == "raid") then
        self:ApplyRaidData(refreshData, playerName, realm)
        
    elseif(type == "mplus") then
        self:ApplyMythicPlusData(refreshData, playerName, realm)

    else
        self:ApplyMythicPlusData(refreshData, playerName, realm)
        self:ApplyRaidData(refreshData, playerName, realm)

    end
end