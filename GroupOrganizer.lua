local addonName, miog = ...
local wticc = WrapTextInColorCode
local throttleSetting = miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE
local doubleThrottle = throttleSetting * 2
local progressBarTick = throttleSetting / 5
local INVERSE_DURATION = 1 / throttleSetting

miog.groupManager = {}

local formatter = CreateFromMixins(SecondsFormatterMixin)
formatter:SetStripIntervalWhitespace(true)
formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter)

local groupPlayerList = {}

local mainDataProvider = CreateDataProvider()
local currentSortHeader
local isInRaid

local fullPlayerName, shortPlayerName, playerRealm

local numOfGroupMembers = 99
local inspectedMembers = 0
local inspectableMembers = 0

local savedPlayerSpecs = {}
local savedKeystoneData = {}
local savedGearData = {}
local savedRaidData = {}
local savedMythicPlusData = {}
local classCount, roleCount, specCount

local inspectRoutine
local orderedInspectionQueue = {}

local groupManager

local inspectionPlayerData = {}
local retryList = {}
local resumeTime = 0

local groupUpdateQueued
local updateTimer
local startScheduled = false

local classSpecPanel

local addedSinceLastRefresh = {}

local abortTimer
local abortTimerPlayerName
local abortTimerUnitID

local inspectionLoopTimerUnitID
local inspectionLoopTimerFullName

local function addPlayerToRetryList(fullName)
    retryList[fullName] = retryList[fullName] and retryList[fullName] + 1 or 1

end

local function getCurrentlyInspectedPlayer()
    return inspectionPlayerData and inspectionPlayerData.name
end

local function tryToResumeCoroutine()
    if(getCurrentlyInspectedPlayer() == nil) then
        coroutine.resume(inspectRoutine)

    end
end

local function deletePlayerFromFullInspection(fullName)
    if(fullName == getCurrentlyInspectedPlayer()) then
        inspectionPlayerData = {}
        classSpecPanel.InspectCharacterName:SetText("")
        classSpecPanel.LoadingSpinner:SetShown(false)
        ClearInspectPlayer()

    end
end

local function addPlayerToInspectionQueue(fullName, unitID)
    if(not savedPlayerSpecs[fullName]) then
        tinsert(orderedInspectionQueue, {fullName = fullName, unitID = unitID})

    end
end

local function needsToBeInspected(fullName)
    return savedPlayerSpecs[fullName] == nil

end

local function updateMemberString()
    classSpecPanel.InspectionString:SetText(inspectedMembers .. " | " .. inspectableMembers .. " | " .. numOfGroupMembers)

end

local function isPlayerRetryBlocked(fullName)
    if(retryList[fullName] and retryList[fullName] > 4) then
        return true

    end
        
    return false
end

local function canInspectPlayerInGroup(fullName)
    local data = groupPlayerList[fullName]

    if(not data) then
        return false

    end

    local unitID = data.unitID

	if(UnitIsPlayer(unitID) and CanInspect(unitID) and (data.online ~= false or UnitIsConnected(unitID)) and not isPlayerRetryBlocked(fullName)) then
		return true

	end

end

local function resetSpecCount()
    for spec in pairs(specCount) do
        specCount[spec] = 0
    end

end

local function countPlayerSpecs()
    inspectedMembers = 0
    inspectableMembers = 0
    resetSpecCount()

    if(numOfGroupMembers > 0) then
        for groupIndex = 1, MAX_RAID_MEMBERS, 1 do
        local name = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

            if(name) then
                local fullName = miog.createFullNameValuesFrom("unitName", name)

                if(savedPlayerSpecs[fullName]) then
                    inspectedMembers = inspectedMembers + 1
                    inspectableMembers = inspectableMembers + 1

                    specCount[savedPlayerSpecs[fullName]] = specCount[savedPlayerSpecs[fullName]] + 1

                elseif(canInspectPlayerInGroup(fullName)) then
                    inspectableMembers = inspectableMembers + 1

                    if(fullName == fullPlayerName) then
                        inspectedMembers = inspectedMembers + 1

                    end
                end
            end
        end
    end

    updateMemberString()
end

local function abortTimerCallback()
    if(abortTimerPlayerName) then
        addPlayerToRetryList(abortTimerPlayerName)
        deletePlayerFromFullInspection(abortTimerPlayerName)

        if(retryList[abortTimerPlayerName] and retryList[abortTimerPlayerName] < 5) then
            if(groupPlayerList[abortTimerPlayerName]) then
                addPlayerToInspectionQueue(abortTimerPlayerName, abortTimerUnitID)
            end
        else
            countPlayerSpecs()
                               
        end
        tryToResumeCoroutine()
    end
end

local function stopAbortTimer()
    if(abortTimer and not abortTimer:IsCancelled()) then
        abortTimer:Cancel()

    end

end

local function startAbortTimer(playerToBeAborted, unitID)
    stopAbortTimer()

    abortTimerPlayerName = playerToBeAborted
    abortTimerUnitID = unitID
    
    abortTimer = C_Timer.NewTimer(doubleThrottle, abortTimerCallback)
end

local function startInspection(unitID, fullName)
    NotifyInspect(unitID)
    startAbortTimer(fullName, unitID)
    
    if(groupPlayerList[fullName]) then
        local fileName = groupPlayerList[fullName].fileName

        inspectionPlayerData = {name = fullName, unitID = unitID, fileName = fileName}

        local coloredString

        if(fileName) then
            local color = C_ClassColor.GetClassColor(fileName)
            coloredString = WrapTextInColorCode(fullName, color:GenerateHexColor())

        end

        classSpecPanel.InspectCharacterName:SetText(coloredString or fullName)
        classSpecPanel.LoadingSpinner:SetShown(fullName)

    end
end

local function inspectionLoopCallback()
    if(inspectionLoopTimerUnitID and inspectionLoopTimerFullName) then
        startInspection(inspectionLoopTimerUnitID, inspectionLoopTimerFullName)
        startScheduled = false
    end
end

local progressBarEndTime = 0
local function progressBarUpdate(self)
    local currentTime = GetTime()
    local timeRemaining = progressBarEndTime - currentTime
    
    if (timeRemaining <= -progressBarTick) then
        groupManager.Settings.NextRefreshString:SetText("")
        classSpecPanel.ProgressBar:Hide()
        self:Cancel()
    else
        local ratioComplete = 1 - (timeRemaining * INVERSE_DURATION)
        classSpecPanel.ProgressBar:SetSmoothedValue(ratioComplete)
    end
end

local function removeSpecID(fullName)
    savedPlayerSpecs[fullName] = nil

    if(groupPlayerList[fullName]) then
        groupPlayerList[fullName].specID = nil

    end
end

local function inspectionLoop()
    while true do
        if #orderedInspectionQueue > 0 then
            local nextPlayerInfo = tremove(orderedInspectionQueue)

            if(nextPlayerInfo) then
                local fullName = nextPlayerInfo.fullName
                local unitID = nextPlayerInfo.unitID

                if(needsToBeInspected(fullName)) then
                    if(not startScheduled) then
                        local nextStart = resumeTime - GetTimePreciseSec()

                        if(nextStart > 0) then
                            startScheduled = true

                            inspectionLoopTimerUnitID = unitID
                            inspectionLoopTimerFullName = fullName
                            
                            C_Timer.After(nextStart, inspectionLoopCallback)
                            
                        else
                            startInspection(unitID, fullName)

                        end
                    else
                        addPlayerToInspectionQueue(fullName, unitID)

                    end

                    coroutine.yield()

                else
                    deletePlayerFromFullInspection(fullName)

                end
            end
        else
            coroutine.yield()

        end
    end
end

local function orderedAnalyze()
    local status = inspectRoutine and coroutine.status(inspectRoutine)

    if(status == nil or status == "dead") then
        inspectRoutine = coroutine.create(inspectionLoop)
        tryToResumeCoroutine()

    end
end

local function findFrames(fullName)
    if(groupPlayerList[fullName]) then
        local listViewFrame = groupManager.ListView.ScrollBox:FindFrameByPredicate(function(localFrame, data)
            return data.fullName == fullName

        end)

        local raidViewFrame = groupManager.RaidView:FindMemberFrame(fullName)

        return listViewFrame, raidViewFrame
    end
end

local function getKeystoneAbbreviatedName(challengeModeMapID)
    return miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[challengeModeMapID].mapID].abbreviatedName
end

local function updateSpecificFrameData(fullName, key, data)
    local listViewFrame, raidViewFrame = findFrames(fullName)

    if(listViewFrame and raidViewFrame) then
        if(key == "specID") then
            for k, v in pairs(listViewFrame.cells) do
                if(v.key == key) then
                    v:SetSpecialization(data)

                end
            end

            raidViewFrame:SetSpecialization(data)

        elseif(key == "online") then
            local isOnline = UnitIsConnected(data)
            local isAfk = UnitIsAFK(data)
            local isDnd = UnitIsDND(data)

            for k, v in pairs(listViewFrame.cells) do
                if(v.key == key) then
                    v:SetOnlineStatus(isOnline, isAfk, isDnd)

                end
            end

            raidViewFrame:SetOnlineStatus(isOnline, isAfk, isDnd)

        elseif(key == "itemLevel") then
            for k, v in pairs(listViewFrame.cells) do
                if(v.key == key) then
                    v:SetItemLevel(data)

                end
            end

        elseif(key == "durability") then
            for k, v in pairs(listViewFrame.cells) do
                if(v.key == key) then
                    v:SetDurability(data)

                end
            end

        elseif(key == "keylevel") then
            for k, v in pairs(listViewFrame.cells) do
                if(v.key == key) then                    
                    v:SetKeystone({keystoneAbbreviatedName = getKeystoneAbbreviatedName(data.challengeMapID), keylevel = data.level})

                end
            end
        end
    end
end

local function canInspectUnit(unitID)
	if(UnitIsPlayer(unitID) and CanInspect(unitID) and UnitIsConnected(unitID)) then
		return true

	end
end

local function checkNumberOfGroupMembers()
    local hasChanged = false

    if(numOfGroupMembers ~= GetNumGroupMembers()) then
        numOfGroupMembers = GetNumGroupMembers()

        groupManager.view:SetElementExtent(numOfGroupMembers > 5 and 30 or 60)
        hasChanged = true

    end

    return hasChanged
end

local function updateClassPanel()
	classSpecPanel.TankString:SetText(roleCount["TANK"])
	classSpecPanel.HealerString:SetText(roleCount["HEALER"])
	classSpecPanel.DamagerString:SetText(roleCount["DAMAGER"])


    for classIndex, classEntry in ipairs(miog.OFFICIAL_CLASSES) do
        local name = classEntry.name

        local numOfClasses = classCount[name]
        local currentClassFrame = classSpecPanel.Classes[name]

        local r, g, b, a = currentClassFrame:GetBackdropBorderColor()

        if(numOfClasses > 0) then
            currentClassFrame:SetSize(26, 26)
            currentClassFrame.layoutIndex = -classIndex
            currentClassFrame.Icon:SetDesaturated(false)
            currentClassFrame.Icon:SetAlpha(0.85)
            currentClassFrame:SetBackdropBorderColor(r, g, b, 0.85)
            currentClassFrame.FontString:SetText(numOfClasses)

        else
            currentClassFrame:SetSize(18, 18)
            currentClassFrame.layoutIndex = classIndex
            currentClassFrame.Icon:SetDesaturated(true)
            currentClassFrame.Icon:SetAlpha(0.4)
            currentClassFrame:SetBackdropBorderColor(r, g, b, 0.4)
            currentClassFrame.FontString:SetText("")

            currentClassFrame.Specializations:Hide()
        end
    end

    classSpecPanel.Classes:MarkDirty()
end

local function resetClassRoleSpecCount()
    for class in pairs(classCount) do
        classCount[class] = 0
    end
    
    for role in pairs(roleCount) do
        roleCount[role] = 0
    end

    resetSpecCount()
end

local function countPlayerClassRoleSpec()
    inspectedMembers = 0
    inspectableMembers = 0
    resetClassRoleSpecCount()

    if(numOfGroupMembers > 0) then
        for groupIndex = 1, MAX_RAID_MEMBERS, 1 do
        local name, rank, subgroup, level, localizedClassName, fileName, _, online, _, role, _, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

            if(name) then
                local fullName = miog.createFullNameValuesFrom("unitName", name)

                if(savedPlayerSpecs[fullName]) then
                    inspectedMembers = inspectedMembers + 1
                    inspectableMembers = inspectableMembers + 1

                    specCount[savedPlayerSpecs[fullName]] = specCount[savedPlayerSpecs[fullName]] + 1

                elseif(canInspectPlayerInGroup(fullName)) then
                    inspectableMembers = inspectableMembers + 1

                    if(fullName == fullPlayerName) then
                        inspectedMembers = inspectedMembers + 1

                    end
                end
                
                if(classCount[fileName]) then
                    classCount[fileName] = classCount[fileName] + 1

                end

                if(roleCount[combatRole]) then
                    roleCount[combatRole] = roleCount[combatRole] + 1

                end
            end
        end
    end

    updateMemberString()
end

local function refreshGroupCycle()
    if(updateTimer) then
        updateTimer:Cancel()
        
    end

    groupUpdateQueued = false

    table.wipe(addedSinceLastRefresh)
    table.wipe(orderedInspectionQueue)
    table.wipe(retryList)
    table.wipe(groupPlayerList)

    deletePlayerFromFullInspection(getCurrentlyInspectedPlayer())

    countPlayerClassRoleSpec()

    checkNumberOfGroupMembers()
end

local function createClassRoleSpecCount()
    classCount = {
        ["WARRIOR"] = 0,
        ["PALADIN"] = 0,
        ["HUNTER"] = 0,
        ["ROGUE"] = 0,
        ["PRIEST"] = 0,
        ["DEATHKNIGHT"] = 0,
        ["SHAMAN"] = 0,
        ["MAGE"] = 0,
        ["WARLOCK"] = 0,
        ["MONK"] = 0,
        ["DRUID"] = 0,
        ["DEMONHUNTER"] = 0,
        ["EVOKER"] = 0,
    }

    roleCount = {
        ["TANK"] = 0,
        ["HEALER"] = 0,
        ["DAMAGER"] = 0,
        ["NONE"] = 0,
    }

    specCount = {
        [62] = 0,
        [63] = 0,
        [64] = 0,
        
        [65] = 0,
        [66] = 0,
        [70] = 0,
        
        [71] = 0,
        [72] = 0,
        [73] = 0,
        
        [102] = 0,
        [103] = 0,
        [104] = 0,
        [105] = 0,

        [250] = 0,
        [251] = 0,
        [252] = 0,

        [253] = 0,
        [254] = 0,
        [255] = 0,

        [256] = 0,
        [257] = 0,
        [258] = 0,

        [259] = 0,
        [260] = 0,
        [261] = 0,

        [262] = 0,
        [263] = 0,
        [264] = 0,

        [265] = 0,
        [266] = 0,
        [267] = 0,

        [268] = 0,
        [269] = 0,
        [270] = 0,

        [577] = 0,
        [581] = 0,
        [1480] = 0,

        [1467] = 0,
        [1468] = 0,
        [1473] = 0,

        --- Initials
        
        [1444] = 0,
        [1446] = 0,
        [1447] = 0,
        [1448] = 0,
        [1449] = 0,
        [1450] = 0,
        [1451] = 0,
        [1452] = 0,
        [1453] = 0,
        [1454] = 0,
        [1455] = 0,
        [1456] = 0,
        [1465] = 0,
        [1478] = 0,
    }
end

local function resetOnGroupChange()
    refreshGroupCycle()

    table.wipe(savedPlayerSpecs)
    table.wipe(savedGearData)
    table.wipe(savedKeystoneData)
    table.wipe(savedRaidData)
    table.wipe(savedMythicPlusData)

    --mainDataProvider:Flush()
end

local function standardSort(k1, k2)
    return k1["index"] < k2["index"]

end

local sortComparatorFunction = standardSort

local function setDataProviderSort(originColumnHeader, key)
    local dataProvider = groupManager.ListView.ScrollBox:GetDataProvider()

    if(currentSortHeader) then
        if(currentSortHeader.headerName == originColumnHeader.headerName) then
            if(currentSortHeader.state == 2) then
                currentSortHeader.SortArrow:Hide()
                currentSortHeader.SortArrow:SetTexCoord(0, 1, 0, 1);
                currentSortHeader.Text:AdjustPointsOffset(4, 0)
                currentSortHeader.state = nil
                currentSortHeader = nil

                sortComparatorFunction = standardSort
                
            else
                sortComparatorFunction = function(k1, k2)
                    return k1[key] > k2[key]
                    
                end
                currentSortHeader.SortArrow:SetTexCoord(0, 1, 1, 0);
                currentSortHeader.state = 2

            end

        else
            currentSortHeader.SortArrow:Hide()
		    currentSortHeader.SortArrow:SetTexCoord(0, 1, 0, 1);
            currentSortHeader.Text:AdjustPointsOffset(4, 0)
            currentSortHeader.state = nil

            sortComparatorFunction = function(k1, k2)
                return k1[key] < k2[key]
                
            end

            originColumnHeader.SortArrow:SetTexCoord(0, 1, 0, 1);
            originColumnHeader.Text:AdjustPointsOffset(-4, 0)
            originColumnHeader.SortArrow:Show()
            originColumnHeader.state = 1
            currentSortHeader = originColumnHeader
        end
        
    else
        sortComparatorFunction = function(k1, k2)
            return k1[key] < k2[key]

        end

		originColumnHeader.SortArrow:SetTexCoord(0, 1, 0, 1);
        originColumnHeader.Text:AdjustPointsOffset(-4, 0)
        originColumnHeader.SortArrow:Show()
        originColumnHeader.state = 1
        currentSortHeader = originColumnHeader

    end

    dataProvider:SetSortComparator(sortComparatorFunction)
end

local function refreshKeystoneData(fullName)
    local playerData = groupPlayerList[fullName]

    if(playerData) then
        local keystoneData = savedKeystoneData[fullName]

        if(keystoneData and miog.CHALLENGE_MODE_INFO[keystoneData.challengeMapID]) then
            local challengeModeMapID = keystoneData.challengeMapID

            playerData.keystoneAbbreviatedName = getKeystoneAbbreviatedName(challengeModeMapID)
            playerData.keylevel = keystoneData.level

        else
            playerData.keystoneShortName = ""
            playerData.keylevel = 0

        end
    end
end

local function refreshGearData(fullName)
    local playerData = groupPlayerList[fullName]

    if(playerData) then
        local playerGear = savedGearData[fullName]

        if(playerGear) then
            playerData.itemLevel = playerGear.ilevel or 0
            playerData.durability = playerGear.durability or 0
            
        else
            playerData.itemLevel = 0
            playerData.durability = 0

        end
    end
end

local function refreshRaidData(fullName, playerName, realm)
    local playerData = groupPlayerList[fullName]

    local raiderIORaidData = miog.getRaidProgressDataOnly(playerName, realm)

    if(playerData) then
        if(savedRaidData[fullName]) then
            playerData.progress = savedRaidData[fullName].progress
            playerData.progressWeight = savedRaidData[fullName].progressWeight
            
        elseif(raiderIORaidData) then
            local progressTable = {}

            local raidTable = {}

            for _, v in ipairs(raiderIORaidData.character.ordered) do
                if(v.difficulty > 0) then
                    raidTable[v.mapID] = raidTable[v.mapID] or {}

                    tinsert(raidTable[v.mapID], wticc(v.parsedString, miog.DIFFICULTY[v.difficulty].color) .. " ")

                end
            end

            for k, v in pairs(raidTable) do
                tinsert(progressTable, table.concat(v))
            end

            playerData.progress = table.concat(progressTable, "\r\n") 
            
            playerData.progressWeight = raiderIORaidData.character.progressWeight or 0

            savedRaidData[fullName] = {progress = playerData.progress, progressWeight = playerData.progressWeight}
        else
            playerData.progressWeight = 0
            playerData.progress = "-"

        end
    end
end

local function refreshOptionalPlayerData(fullName, playerName, realm)
    local playerGroupData = groupPlayerList[fullName]

    refreshGearData(fullName)
    refreshKeystoneData(fullName)
    refreshRaidData(fullName, playerName, realm)

    savedMythicPlusData[fullName] = savedMythicPlusData[fullName] or miog.getMPlusScoreOnly(playerName, realm)
    playerGroupData.score = savedMythicPlusData[fullName]
end

local function createColumn(name, cellTemplate, key, useForSort, fill)
    local tableBuilder = groupManager.tableBuilder
    local column = tableBuilder:AddColumn()
    column:ConstructHeader("Button", "MIOG_GroupOrganizerHeaderTemplate", name, key, useForSort and setDataProviderSort)
    column:ConstructCells("Frame", cellTemplate, key)
    column:SetFillConstraints(fill or 0.7, 1)
end

local function checkOnlineStatus(unitID)
    return UnitIsConnected(unitID)
end

local function hasTableEntry(fullName)
    local playerData = groupPlayerList[fullName]

    if not playerData then
        playerData = {}
        groupPlayerList[fullName] = playerData
    end

    return playerData
end

local function refreshDataOfAllPlayers()
    inspectedMembers = 0
    inspectableMembers = 0

    local offset = 0

    for groupIndex = 1, MAX_RAID_MEMBERS, 1 do
        local name, rank, subgroup, level, localizedClassName, fileName, _, online, _, role, _, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

        if(name and fileName) then
            local unitID

            local fullName, playerName, realm = miog.createFullNameValuesFrom("unitName", name)

            if(fullName) then
                if(isInRaid) then
                    unitID = "raid" .. groupIndex

                elseif(fullPlayerName ~= fullName) then
                    unitID = "party" .. groupIndex - offset

                else
                    unitID = "player"

                    offset = offset + 1

                end

                local playerData = hasTableEntry(fullName)

                playerData.index = groupIndex
                playerData.subgroup = subgroup
                playerData.unitID = unitID
                playerData.online = checkOnlineStatus(unitID) or online
                    
                playerData.fullName = fullName
                playerData.name = playerName
                playerData.realm = realm
                playerData.level = level
                    
                playerData.fileName = fileName
                playerData.className = localizedClassName

                playerData.rank = rank
                playerData.role = role

                local playerSpec = savedPlayerSpecs[fullName] or 0

                groupPlayerList[fullName].specID = playerSpec
                groupPlayerList[fullName].combatRole = combatRole or GetSpecializationRoleByID(playerSpec)

                if(classCount[fileName]) then
                    classCount[fileName] = classCount[fileName] + 1

                end

                if(roleCount[combatRole]) then
                    roleCount[combatRole] = roleCount[combatRole] + 1

                end

                refreshOptionalPlayerData(fullName, playerName, realm)
            end
        end
    end
end

local function refreshPlayerCharacterData()
    inspectedMembers = 0
    inspectableMembers = 0

    local localizedClassName, fileName = UnitClass("player")
    local _, _, _, _, combatRole = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
    combatRole = combatRole or "DAMAGER"
    
    local playerData = hasTableEntry(fullPlayerName)
    local playerSpec = savedPlayerSpecs[fullPlayerName] or 0

    playerData.index = 1
    playerData.subgroup = 1
    playerData.unitID = "player"
    playerData.online = true
        
    playerData.fullName = fullPlayerName
    playerData.name = shortPlayerName
    playerData.realm = playerRealm
    playerData.level = UnitLevel(playerData.unitID)
        
    playerData.fileName = fileName
    playerData.className = localizedClassName
    
    playerData.specID = playerSpec
    playerData.combatRole = combatRole or "DAMAGER"

    if(classCount[fileName]) then
        classCount[fileName] = classCount[fileName] + 1

    end

    if(roleCount[combatRole]) then
        roleCount[combatRole] = roleCount[combatRole] + 1

    end

    specCount[playerSpec] = specCount[playerSpec] + 1

    inspectedMembers = inspectedMembers + 1
    inspectableMembers = inspectableMembers + 1

    refreshOptionalPlayerData(fullPlayerName, shortPlayerName, playerRealm)

    updateMemberString()
end

local function updateNecessaryPlayers()
    if(numOfGroupMembers > 0) then
        refreshDataOfAllPlayers()
        countPlayerClassRoleSpec()

    else
        resetClassRoleSpecCount()
        refreshPlayerCharacterData()
        
    end

    updateClassPanel()
end

local function startUpdate()
    updateNecessaryPlayers()

    mainDataProvider:Flush()

    for k, v in pairs(groupPlayerList) do
       mainDataProvider:Insert(v)

    end

    groupManager.RaidView:RefreshMemberData(mainDataProvider.collection)

    groupUpdateQueued = false
end

local function queueGroupUpdate(instant, origin)
    if(groupUpdateQueued and not instant) then
        return

    else
        groupUpdateQueued = true

        if(updateTimer) then
            updateTimer:Cancel()

        end

        if(instant) then
            startUpdate()

        else
            updateTimer = C_Timer.NewTimer(throttleSetting + progressBarTick, startUpdate)

            progressBarEndTime = GetTime() + throttleSetting

            classSpecPanel.ProgressBar:ResetSmoothedValue(0)
            classSpecPanel.ProgressBar:Show()

            C_Timer.NewTicker(progressBarTick, progressBarUpdate)
        end
    end
end

local function saveSpecID(playerName, specID)
    savedPlayerSpecs[playerName] = specID
    groupPlayerList[playerName].specID = specID

    countPlayerSpecs()
end

--[[
local specName = singleUnitInfo.specName
local role = singleUnitInfo.role
local renown = singleUnitInfo.renown
local covenantId = singleUnitInfo.covenantId
local heroTalentId = singleUnitInfo.heroTalentId
local talents = singleUnitInfo.talents
local pvpTalents = singleUnitInfo.pvpTalents
local conduits = singleUnitInfo.conduits
local class = singleUnitInfo.class
local classId = singleUnitInfo.classId
local className = singleUnitInfo.className
local unitName = singleUnitInfo.name
local fullName = singleUnitInfo.nameFull
]]
miog.OnUnitUpdate = function(singleUnitId, singleUnitInfo, allUnitsInfo)
	if(singleUnitInfo) then
        local playerName = singleUnitInfo.nameFull
        local specID = singleUnitInfo.specId

		if(playerName == shortPlayerName) then
			playerName = fullPlayerName
		end

		if(groupPlayerList[playerName]) then
			if(specID and specID > 0 and (not savedPlayerSpecs[playerName] or savedPlayerSpecs[playerName] ~= specID)) then
                saveSpecID(playerName, specID)
                updateSpecificFrameData(playerName, "specID", specID)
                tryToResumeCoroutine()
			end
		end
	end
end

miog.OnKeystoneUpdate = function(unitName, keystoneInfo, allKeystoneInfo)
	local mapName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)

	if(mapName) then
        local fullName = miog.createFullNameValuesFrom("unitName", unitName)


        if(fullName) then
            local keystoneData = savedKeystoneData[fullName]

            if(keystoneData and keystoneData.challengeMapID == keystoneInfo.challengeMapID and keystoneData.level == keystoneInfo.level) then
                return

            end

		    savedKeystoneData[fullName] = keystoneInfo
            refreshKeystoneData(fullName)

            updateSpecificFrameData(fullName, "keylevel", keystoneInfo)

        end

		--updateSingleCharacterKeystoneData(fullName)

	end
end

miog.OnGearUpdate = function(unit, unitGear, allUnitsGear)
	--[[local itemLevelNumber = unitGear.ilevel
	local durabilityNumber = unitGear.durability
	--hasWeaponEnchant is 1 have enchant or 0 is don't
	local hasWeaponEnchantNumber = unitGear.weaponEnchant
	local noEnchantTable = unitGear.noEnchants
	local noGemsTable = unitGear.noGems

	for index, slotIdWithoutEnchant in ipairs (noEnchantTable) do
	end

	for index, slotIdWithEmptyGemSocket in ipairs (noGemsTable) do
	end]]

    local fullName = miog.createFullNameValuesFrom(nil, unit)

	if(fullName) then
        local gearData = savedGearData[fullName]

        if(gearData and gearData.ilevel == gearData.ilevel and gearData.durability == gearData.durability) then
            return
        end

		savedGearData[fullName] = unitGear
        refreshGearData(fullName)

        updateSpecificFrameData(fullName, "itemLevel", savedGearData[fullName].ilevel)
        updateSpecificFrameData(fullName, "durability", savedGearData[fullName].durability)

	end
end

local function addPlayerSinceLastRefresh()
    for _ = 1, #addedSinceLastRefresh do
        local name = tremove(addedSinceLastRefresh, 1)

        if(name) then
            mainDataProvider:Insert(groupPlayerList[name])

        end
    end
end

local function customEvents(event, ...)
    if(event == "PLAYER_LEFT_GROUP") then
        local fullName = ...
        
        if(fullName) then
            if(groupPlayerList[fullName]) then
                mainDataProvider:Remove(groupPlayerList[fullName])

            end

            savedPlayerSpecs[fullName] = nil
            retryList[fullName] = nil
            groupPlayerList[fullName] = nil

            deletePlayerFromFullInspection(fullName)
        end

    elseif(event == "PLAYER_JOINED_GROUP") then
        local groupIndex, unitID, fullName, playerName, realm = ...

        local name, rank, subgroup, level, localizedClassName, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

        if(fullName and not savedPlayerSpecs[fullName] and canInspectUnit(unitID)) then
            if(fullName ~= fullPlayerName) then
                addPlayerToInspectionQueue(fullName, unitID)
                --tinsert(addedSinceLastRefresh, fullName)

                
            else
                savedPlayerSpecs[fullPlayerName] = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
                --tinsert(addedSinceLastRefresh, fullPlayerName)

            end
        end

    elseif(event == "PLAYER_SOLO_UPDATE") then
        savedPlayerSpecs[fullPlayerName] = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
        --tinsert(addedSinceLastRefresh, fullPlayerName)
    end
end

local function checkGroupState()
    local currentMembers = {}
    local offset = 0

    if(numOfGroupMembers > 0) then
        for groupIndex = 1, MAX_RAID_MEMBERS, 1 do
            local name = GetRaidRosterInfo(groupIndex)

            if(name) then
                local fullName, playerName, realm = miog.createFullNameValuesFrom("unitName", name)

                if(fullName) then
                    local unitID

                    if(isInRaid) then
                        unitID = "raid" .. groupIndex

                    elseif(fullPlayerName ~= fullName) then
                        unitID = "party" .. groupIndex - offset

                    else
                        unitID = "player"

                        offset = offset + 1

                    end

                    currentMembers[fullName] = true

                    if(not groupPlayerList[fullName]) then
                        customEvents("PLAYER_JOINED_GROUP", groupIndex, unitID, fullName, playerName, realm)

                    end
                end
            end
        end

        for playerName in pairs(groupPlayerList) do
            if(not currentMembers[playerName]) then
                customEvents("PLAYER_LEFT_GROUP", playerName)

            end
        end

    else
        customEvents("PLAYER_SOLO_UPDATE")

    end
end

local function groupManagerEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        local isLogin, isReload = ...
        
        isInRaid = IsInRaid()
        checkGroupState()
        queueGroupUpdate(true, event)
        --addPlayerSinceLastRefresh()

        if(isLogin or isReload) then
            orderedAnalyze()

        end

	elseif(event == "INSPECT_READY") then
        local guid = ...

        if(guid) then
            local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(guid)

            if(name) then
                local fullName = miog.createFullNameValuesFrom("unitName", name .. (realmName and realmName ~= "" and ("-" .. realmName) or ""))

                if(fullName) then
                    if(groupPlayerList[fullName]) then
                        local inspectID = GetInspectSpecialization(groupPlayerList[fullName].unitID)
                        ClearInspectPlayer()

                        if(inspectID) then
                            if(inspectID > 0) then
                                saveSpecID(fullName, inspectID)
                                updateSpecificFrameData(fullName, "specID", inspectID)

                            end
                        end

                        deletePlayerFromFullInspection(fullName)
                        tryToResumeCoroutine()

                    end
                end
            end
        end

	elseif(event == "GROUP_JOINED") then
        isInRaid = IsInRaid()
        resetOnGroupChange()
        checkGroupState()
        
    elseif(event == "GROUP_LEFT") then
        isInRaid = IsInRaid()
        resetOnGroupChange()
        checkGroupState()

	elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
        local unitID = ...

        if(unitID) then
            local fullName = miog.createFullNameValuesFrom("unitID", unitID)
            removeSpecID(fullName)
            addPlayerToInspectionQueue(fullName, unitID)
        end

        --analyzeCoroutine("SPEC CHANGE")

	elseif(event == "GROUP_ROSTER_UPDATE") then
        isInRaid = IsInRaid()
        
        local numOfPlayersChanged = checkNumberOfGroupMembers()

        if(numOfPlayersChanged) then
            checkGroupState()
            tryToResumeCoroutine()

        end

        queueGroupUpdate(false, event)

    elseif(event == "PLAYER_REGEN_ENABLED") then
	--[[elseif(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.UPDATE_AFTER_COMBAT) then
			miog.F.UPDATE_AFTER_COMBAT = false

			updateGroupData(5, true)
		end
	elseif(event == "READY_CHECK") then -- initiatorName, readyCheckTimeLeft
			miog.GroupManager.StatusBar.ReadyBox:SetColorTexture(1, 1, 0, 1)
	
			readyCheckStatus = {}
	
			local initName, timeLeft = ...
	
			local fullName = miog.createFullNameFrom("unitName", initName)
	
			readyCheckStatus[fullName] = true
	
			updateReadyStatus(fullName, true)
	
	elseif(event == "READY_CHECK_CONFIRM") then -- unitTarget, isReady
		local unitID, isReady = ...

		local fullName = miog.createFullNameFrom("unitID", unitID)
		
		readyCheckStatus[fullName] = isReady

		updateReadyStatus(fullName, isReady)
	elseif(event == "READY_CHECK_FINISHED") then -- preempted
		local allReady = true

		for fullName, ready in pairs(readyCheckStatus) do
			updateReadyStatus(fullName)

			if(not ready) then
				allReady = false

				--break
			end

		end

		miog.GroupManager.StatusBar.ReadyBox:SetColorTexture(unpack(allReady and {0, 1, 0, 1} or {1, 0, 0, 1}))]]

	elseif(event == "PLAYER_FLAGS_CHANGED") then
        local unitID = ...

        if(unitID) then
            local fullName = miog.createFullNameValuesFrom("unitID", ...)
            updateSpecificFrameData(fullName, "online", unitID)
        end
	end
end

local customPlayerPopupMenu = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("MIOG_PLAYER", customPlayerPopupMenu);
function customPlayerPopupMenu.GetEntries()
    return {
		UnitPopupRaidTargetButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupInspectButtonMixin,
		UnitPopupAchievementButtonMixin,
		UnitPopupTradeButtonMixin, 
		UnitPopupFollowButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin,
		UnitPopupEnterEditModeMixin,
    }
end

local customPartyPopupMenu = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("MIOG_PARTY", customPartyPopupMenu);
function customPartyPopupMenu:GetEntries()
    return {
        UnitPopupRaidTargetButtonMixin,
        UnitPopupRafSummonButtonMixin,
        UnitPopupRafGrantLevelButtonMixin,
        UnitPopupAddFriendButtonMixin,
        UnitPopupAddFriendMenuButtonMixin,
		UnitPopupInteractSubsectionTitle,
        UnitPopupMenuFriendlyPlayerInteract, -- Submenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin,
		UnitPopupEnterEditModeMixin,
        UnitPopupReportInWorldButtonMixin,
    }
end

local openBlizzardRaidFrame = CreateFromMixins(UnitPopupButtonBaseMixin);

openBlizzardRaidFrame.OnClick = function()
	ToggleFriendsFrame(3)
end
openBlizzardRaidFrame.GetText = function()
	return "Open Blizzard's raid frame"
end

local customRaidPopupMenu = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("MIOG_RAID", customRaidPopupMenu);
function customRaidPopupMenu:GetEntries()
    return {
        UnitPopupSetRaidLeaderButtonMixin,
        UnitPopupSetRaidAssistButtonMixin, 
        UnitPopupSetRaidMainTankButtonMixin,
        UnitPopupSetRaidMainAssistButtonMixin,
        UnitPopupSetRaidDemoteButtonMixin,
        UnitPopupLootPromoteButtonMixin,
        UnitPopupOtherSubsectionTitle,
        UnitPopupVoiceChatButtonMixin,
        UnitPopupMovePlayerFrameButtonMixin,
        UnitPopupMoveTargetFrameButtonMixin,
        UnitPopupEnterEditModeMixin,
        UnitPopupReportGroupMemberButtonMixin,
        UnitPopupCopyCharacterNameButtonMixin,
        UnitPopupPvpReportAfkButtonMixin,
        UnitPopupVoteToKickButtonMixin,
        UnitPopupSetRaidRemoveButtonMixin,
        UnitPopupSubsectionSeperatorMixin,
        openBlizzardRaidFrame,
    }
end

local function loadClassSpecPanel()
    classSpecPanel = CreateFrame("Frame", "MythicIOGrabber_ClassPanel", miog.F.LITE_MODE and PVEFrame or miog.pveFrame2, "MIOG_ClassSpecPanel")
    classSpecPanel:SetPoint("BOTTOMRIGHT", classSpecPanel:GetParent(), "TOPRIGHT")
    classSpecPanel:SetPoint("BOTTOMLEFT", classSpecPanel:GetParent(), "TOPLEFT")

    classSpecPanel.TankIcon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")
    classSpecPanel.HealerIcon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")
    classSpecPanel.DamagerIcon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")

     for _, classEntry in ipairs(miog.OFFICIAL_CLASSES) do
        local currentClassFrame = classSpecPanel.Classes[classEntry.name]

        if(currentClassFrame) then
            currentClassFrame.Icon:SetTexture(classEntry.icon)
        end
                
        local classColor = C_ClassColor.GetClassColor(classEntry.name)

        for specIndex in ipairs(classEntry.specs) do
            local specFrame = currentClassFrame.Specializations["Spec" .. specIndex]
            specFrame:SetBackdropBorderColor(classColor:GetRGBA())

        end
        
        currentClassFrame:SetScript("OnEnter", function(self)
            local specGroup = self.Specializations

            for specIndex, specID in ipairs(classEntry.specs) do
                local specFrame = specGroup["Spec" .. specIndex]

                if(specCount[specID] > 0) then
                    specFrame:Show()
                    specFrame.Icon:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
                    specFrame.FontString:SetText(specCount[specID])

                else
                    specFrame:Hide()

                end
            end

            specGroup:MarkDirty()
            specGroup:Show()
        end)
    end

    classSpecPanel.InspectionString:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Inspection data:")
        GameTooltip:AddLine("Inspected members: " .. inspectedMembers)
        GameTooltip:AddLine("Inspectable members: " .. inspectableMembers)
        GameTooltip:AddLine("Total members: " .. numOfGroupMembers)

        if(#orderedInspectionQueue > 0) then
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip:AddLine("To be inspected:")

            for k, v in ipairs(orderedInspectionQueue) do
                GameTooltip:AddLine(v.fullName .. (retryList[v.fullName] and (", retry #" .. retryList[v.fullName]) or ""))

            end
        end

        local retriesAdded = false

        for k, v in pairs(retryList) do
            if(v > 4) then
                if(not retriesAdded) then
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    GameTooltip:AddLine("Blocked from inspection (too many timeouts):")
                    retriesAdded = true

                end

                GameTooltip:AddLine(k)
            end
        end

        GameTooltip:Show()
    end)
            
    classSpecPanel.ProgressBar:SetMinMaxSmoothedValue(0, 1)
    
    createClassRoleSpecCount()
end

miog.loadGroupOrganizer = function()
    fullPlayerName, shortPlayerName, playerRealm = miog.createFullNameValuesFrom("unitID", "player")

    miog.GroupOrganizer = miog.pveFrame2.TabFramesPanel.GroupManager
    groupManager = miog.GroupOrganizer
    groupManager.Settings.Refresh:SetScript("OnClick", function()
        isInRaid = IsInRaid()
        refreshGroupCycle()
        checkGroupState()
        queueGroupUpdate(true, "REFRESH")

        groupManager.RaidView:Unlock()
    end)

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("MIOG_GroupOrganizerLineTemplate", function(frame, data)
        frame.data = data
        frame.id = data.index
        frame.name = data.fullName
        frame.unit = data.unitID
    end)

    view:SetPadding(0, 0, 0, 0, 0)
    groupManager.view = view

    ScrollUtil.InitScrollBoxListWithScrollBar(groupManager.ListView.ScrollBox, miog.pveFrame2.ScrollBarArea.GroupManagerScrollBar, view)

    local tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
    groupManager.tableBuilder = tableBuilder
    tableBuilder:SetHeaderContainer(groupManager.ListView.HeaderContainer)

    local function ElementDataProvider(elementData, ...)
        return elementData

    end

    tableBuilder:SetDataProvider(ElementDataProvider)

    local function ElementDataTranslator(elementData, ...)
        return elementData

    end

    ScrollUtil.RegisterTableBuilder(groupManager.ListView.ScrollBox, tableBuilder, ElementDataTranslator)
    
    tableBuilder:Reset()
    createColumn("", "MIOG_GroupOrganizerIconCellTemplate", "online", false, 0.3)
    createColumn("#", "MIOG_GroupOrganizerTextCellTemplate", "index", true, 0.35)
    createColumn("Name", "MIOG_GroupOrganizerTextCellTemplate", "name", true, 1.8)
    createColumn("Role", "MIOG_GroupOrganizerIconCellTemplate", "combatRole", true, 0.85)
    createColumn("Class", "MIOG_GroupOrganizerIconCellTemplate", "class", false, 0.8)
    createColumn("Spec", "MIOG_GroupOrganizerIconCellTemplate", "specID", true, 0.85)
    createColumn("Level", "MIOG_GroupOrganizerTextCellTemplate", "level", true, 0.9)
    createColumn("I-Lvl", "MIOG_GroupOrganizerTextCellTemplate", "itemLevel", true, 0.8)
    createColumn("Repair", "MIOG_GroupOrganizerTextCellTemplate", "durability", true, 1)
    createColumn("M+", "MIOG_GroupOrganizerTextCellTemplate", "score", true, 0.8)
    createColumn("Raid", "MIOG_GroupOrganizerTextCellTemplate", "progress", true, 1.15)
    createColumn("Key", "MIOG_GroupOrganizerTextCellTemplate", "keylevel", true, 1.35)
    tableBuilder:Arrange()

    loadClassSpecPanel()
    resetOnGroupChange()

    mainDataProvider = CreateDataProvider()
    mainDataProvider:SetSortComparator(sortComparatorFunction)
    groupManager.ListView.ScrollBox:SetDataProvider(mainDataProvider, ScrollBoxConstants.RetainScrollPosition)

	miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")

    hooksecurefunc("NotifyInspect", function()
        resumeTime = GetTimePreciseSec() + throttleSetting

    end)

	groupManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	groupManager:RegisterEvent("INSPECT_READY")
	groupManager:RegisterEvent("GROUP_JOINED")
	groupManager:RegisterEvent("GROUP_LEFT")
	groupManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	groupManager:RegisterEvent("PLAYER_FLAGS_CHANGED")

	groupManager:SetScript("OnEvent", groupManagerEvents)

end