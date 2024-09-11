local addonName, miog = ...

local formatter = CreateFromMixins(SecondsFormatterMixin)
formatter:SetStripIntervalWhitespace(true)
formatter:Init(0, SecondsFormatter.Abbreviation.None)

local function checkEntriesForExpiration()
    for k, v in pairs(MIOG_NewSettings.lockoutCheck) do
        for a, b in ipairs(v) do
        --for i = 1, #v, 1 do
            if(b.resetDate <= time()) then
                MIOG_NewSettings.lockoutCheck[k][a] = nil

            end
        end
    end
end

miog.loadLockoutCheck = function()
    local fullPlayerName = miog.createFullNameFrom("unitID", "player")

    --framePool = CreateFramePool("Frame", miog.LockoutCheck.ScrollFrame.Columns, "MIOG_LockoutCheckCharacterTemplate", function(_, frame) frame.Name:SetText("") end)

    --miog.LockoutCheck.ScrollFrame:SetHorizontal(true)

    local columnView = CreateScrollBoxListLinearView();
    columnView:SetHorizontal(true)
    columnView:SetElementInitializer("MIOG_LockoutCheckCharacterTemplate", function(frame, settingsData)
        local k = settingsData.name
        local v = settingsData.settings

        local playerName, realm = miog.createSplitName(k)
        frame.Name:SetText(WrapTextInColorCode(playerName, v.class and C_ClassColor.GetClassColor(v.class):GenerateHexColor() or "FFFFFFFF"))

        --local instanceFramePool = CreateFramePool("Frame", frame, "MIOG_LockoutCheckCharacterTemplate", function(_, frame) frame.Name:SetText("") end)

        local view = CreateScrollBoxListLinearView();
        view:SetElementInitializer("MIOG_LockoutCheckInstanceTemplate", function(elementFrame, elementData)
            if(not elementData.isWorldBoss) then
                elementFrame.Name:SetText(miog.MAP_INFO[elementData.mapID].shortName or elementData.name)
                elementFrame.Icon:SetTexture(elementData.icon)
                elementFrame.Difficulty:SetText(WrapTextInColorCode(miog.DIFFICULTY_ID_INFO[elementData.difficulty].shortName, miog.DIFFICULTY_ID_TO_COLOR[elementData.difficulty]:GenerateHexColor()))
    
                elementFrame:SetScript("OnEnter", function(self)
                    RequestRaidInfo()

                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(miog.MAP_INFO[elementData.mapID].name)
                    GameTooltip:AddLine(string.format(DUNGEON_DIFFICULTY_BANNER_TOOLTIP, miog.DIFFICULTY_ID_INFO[elementData.difficulty].name))
                    GameTooltip:AddLine(string.format(elementData.extended and RAID_INSTANCE_EXPIRES_EXTENDED or RAID_INSTANCE_EXPIRES, formatter:Format(elementData.resetDate - time()) .. " (" .. date("%x %X", elementData.resetDate) .. ")"))

                    local setAliveEncounters, setDefeatedEncounters = false, false

                    for i = 1, elementData.numEncounters, 1 do
                        local isKilled = elementData.bosses[i].isKilled
                        local bossName = elementData.bosses[i].bossName
                        --local bossName, fileDataID, isKilled, unknown4 = GetSavedInstanceEncounterInfo(index, i)

                        if(not isKilled) then
                            if(not setAliveEncounters) then
                                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                                GameTooltip:AddLine("Encounters available: ")
                                setAliveEncounters = true
                                
                            end

                            GameTooltip:AddLine(WrapTextInColorCode(isKilled and "Defeated " or "Alive ", isKilled and miog.CLRSCC.red or miog.CLRSCC.green) ..  bossName)

                        end
                    end

                    for i = 1, elementData.numEncounters, 1 do
                        local isKilled = elementData.bosses[i].isKilled
                        local bossName = elementData.bosses[i].bossName
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

                    GameTooltip:SetText(elementData.name)
                    GameTooltip:AddLine("World Boss")
                    GameTooltip:AddLine(string.format(elementData.extended and RAID_INSTANCE_EXPIRES_EXTENDED or RAID_INSTANCE_EXPIRES, formatter:Format(elementData.resetDate - time()) .. " (" .. date("%x %X", elementData.resetDate) .. ")"))

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

        for a, b in ipairs(v) do
            dataProvider:Insert(b);

        end

        frame.ScrollBox:SetHeight((#v + 1) * 20)
    
        frame.ScrollBox:SetDataProvider(dataProvider);
    end)

    columnView:SetPadding(1, 1, 1, 1, 2);

    miog.LockoutCheck.Columns:SetHorizontal(true)
    --miog.LockoutCheck.Columns:Init(columnView);

    ScrollUtil.InitScrollBoxListWithScrollBar(miog.LockoutCheck.Columns, miog.LockoutCheck.ScrollBar, columnView);

    --miog.LockoutCheck.Columns:SetHeight((#v + 1) * 20)

    miog.LockoutCheck:SetScript("OnShow", function()
        --framePool:ReleaseAll()
        miog.LockoutCheck.Columns:Flush()

        checkEntriesForExpiration()
    
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
                    MIOG_NewSettings.lockoutCheck[fullPlayerName][#MIOG_NewSettings.lockoutCheck[fullPlayerName]+1] = {
                        id = lockoutId,
                        name = name,
                        difficulty = difficultyId,
                        extended = extended,
                        isRaid = isRaid,
                        icon = miog.MAP_INFO[instanceId].icon,
                        mapID = instanceId,
                        index = index,
                        numEncounters = numEncounters,
                        resetDate = time() + reset,
                        bosses = bosses
                    }
                end
            end
        end
        
        for i = 1, GetNumSavedWorldBosses(), 1 do
            local name, worldBossID, reset = GetSavedWorldBossInfo(i)

            MIOG_NewSettings.lockoutCheck[fullPlayerName][#MIOG_NewSettings.lockoutCheck[fullPlayerName] + 1] = {
                id = worldBossID,
                name = name,
                isWorldBoss = true,
                resetDate = time() + reset,
                --icon = miog.MAP_INFO[instanceId].icon,
            }
        end
    
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
                orderedCharacterTable[#orderedCharacterTable+1] = k

            else
                MIOG_NewSettings.lockoutCheck[k] = nil

            end
        end

        table.sort(orderedCharacterTable, function(k1, k2)
            return k1 < k2
        end)

        for k, v in ipairs(orderedCharacterTable) do
            --local frame = framePool:Acquire()
            --frame.layoutIndex = counter

            columnProvider:Insert({name = v, settings = MIOG_NewSettings.lockoutCheck[v]});
        end

        miog.LockoutCheck.Columns:SetDataProvider(columnProvider);

        --miog.LockoutCheck.ScrollFrame.Columns:MarkDirty()
    end)
end