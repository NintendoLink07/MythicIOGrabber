local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.groupManager = {}

local groupPlayerList = {}

local mainDataProvider = CreateDataProvider()
local currentSortHeader
local isInRaid

local fullPlayerName, shortPlayerName, playerRealm

local numOfGroupMembers = 99
local inspectedMembers = 0
local inspectableMembers = 0

local groupMoreThanFivePlayers = false

local savedPlayerSpecs
local savedKeystoneData
local savedGearData
local savedRaidData
local savedMythicPlusData
local classCount, roleCount

local inspectRoutine
local inspectionQueue
local orderedInspectionQueue

local groupManager

local notifyBlocked = false
local inspectionPlayerData
local retryList
local resumeTime = 0

local groupUpdateQueued
local updateTimer

local pityTimer
local pityTimerRunning

local analyzeTimer
local analyzeTimerRunning

local throttleSetting = miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE
local doubleThrottle = throttleSetting * 2

local classSpecPanel

local function updateElementExtent()
    groupManager.view:SetElementExtent(groupManager.ListView.ScrollBox:GetHeight() / (groupMoreThanFivePlayers and 12 or 6))

end

local function findFrames(fullName)
    local listViewFrame = groupManager.ListView.ScrollBox:FindFrameByPredicate(function(localFrame, data)
        return data.fullName == fullName

    end)

    local raidViewFrame = groupManager.RaidView:FindMemberFrame(fullName)

    return listViewFrame, raidViewFrame
end

local function updateSpecificFrameData(fullName, type, data)
    local listViewFrame, raidViewFrame = findFrames(fullName)

    if(listViewFrame and raidViewFrame) then
        if(type == "spec") then
            for k, v in pairs(listViewFrame.cells) do
                if(v.key == "specID") then
                    v:SetSpecialization(data)

                end
            end

            raidViewFrame:SetSpecialization(data)

        end
    end
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

local function canInspectUnit(unitID)
	if(UnitIsPlayer(unitID) and CanInspect(unitID) and UnitIsConnected(unitID)) then
		return true

	end
end

local function updateCurrentlyInspectedCharacter()
    local name

    if(inspectionPlayerData.fileName) then
        local color = C_ClassColor.GetClassColor(inspectionPlayerData.fileName)
        name = color and WrapTextInColorCode(inspectionPlayerData.name, color:GenerateHexColor()) or inspectionPlayerData.name

    else
        name = inspectionPlayerData.name

    end

	classSpecPanel.InspectCharacterName:SetText(name or "")
	classSpecPanel.LoadingSpinner:SetShown(inspectionPlayerData.name)
end

local function resetPityTimer()
    if(pityTimer and pityTimerRunning) then
        pityTimer:Cancel()
        pityTimerRunning = false

    end
end

local function checkNumberOfGroupMembers()
    local hasChanged = false

    if(numOfGroupMembers ~= GetNumGroupMembers()) then
        numOfGroupMembers = GetNumGroupMembers()

        groupMoreThanFivePlayers = numOfGroupMembers > 5
        updateElementExtent()
        hasChanged = true

    end

    return hasChanged
end

local function updateInspectionString()
    classSpecPanel.InspectionString:SetText(inspectedMembers .. " | " .. inspectableMembers .. " | " .. numOfGroupMembers)

end

local function updateClassPanel()
	classSpecPanel.TankString:SetText(roleCount["TANK"])
	classSpecPanel.HealerString:SetText(roleCount["HEALER"])
	classSpecPanel.DamagerString:SetText(roleCount["DAMAGER"])

    local classFrameIndex = 1

    for _, classEntry in ipairs(miog.CLASSES) do
        local name = classEntry.name

        local numOfClasses = classCount[name]
        local currentClassFrame = classSpecPanel.Classes[name]

        local r, g, b, a = currentClassFrame:GetBackdropBorderColor()

        if(numOfClasses > 0) then
            currentClassFrame:SetSize(26, 26)
            currentClassFrame.layoutIndex = classFrameIndex
            currentClassFrame.Icon:SetDesaturated(false)
            currentClassFrame.Icon:SetAlpha(0.85)
            currentClassFrame:SetBackdropBorderColor(r, g, b, 0.85)
            currentClassFrame.FontString:SetText(numOfClasses)

            classFrameIndex = classFrameIndex + 1
            
        else
            currentClassFrame:SetSize(18, 18)
            currentClassFrame.layoutIndex = classFrameIndex + 20
            currentClassFrame.Icon:SetDesaturated(true)
            currentClassFrame.Icon:SetAlpha(0.4)
            currentClassFrame:SetBackdropBorderColor(r, g, b, 0.4)
            currentClassFrame.FontString:SetText("")

        end
    end

    classSpecPanel.Classes:MarkDirty()

end

local function refreshGroupCycle()
    if(updateTimer) then
        updateTimer:Cancel()
        
    end

    if(analyzeTimer and analyzeTimerRunning) then
        analyzeTimer:Cancel()
        analyzeTimerRunning = false

    end

    resetPityTimer()

    ClearInspectPlayer()

    groupUpdateQueued = false

    orderedInspectionQueue = {}
    inspectionQueue = {}
    inspectionPlayerData = {}
    retryList = {}
    groupPlayerList = {}

    inspectableMembers = 0
    inspectedMembers = 0

    checkNumberOfGroupMembers()
    updateInspectionString()
end

local function resetClassAndRoleCount()
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

end

local function resetOnGroupChange()
    refreshGroupCycle()

    savedPlayerSpecs = {}
    savedGearData = {}
    savedKeystoneData = {}
    savedRaidData = {}
    savedMythicPlusData = {}

    resetClassAndRoleCount()
end

local sortComparatorFunction

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

                sortComparatorFunction = nil
                
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

            playerData.keystoneAbbreviatedName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[challengeModeMapID].mapID].abbreviatedName
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
            playerData.progress = ""

            local raidTable = {}

            for _, v in ipairs(raiderIORaidData.character.ordered) do
                if(v.difficulty > 0) then
                    raidTable[v.mapID] = raidTable[v.mapID] or {}

                    tinsert(raidTable[v.mapID], wticc(v.parsedString, miog.DIFFICULTY[v.difficulty].color) .. " ")

                end
            end

            for k, v in pairs(raidTable) do
                playerData.progress = playerData.progress .. table.concat(v) .. "\r\n"

            end

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
    refreshRaidData(fullName)

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

local function queueHasEntries()
    local hasEntries = false

    for k, v in pairs(inspectionQueue) do
        if(canInspectPlayerInGroup(k)) then
            hasEntries = true
            break

        end
    end

    return hasEntries
end

local function isNotifyBlocked()
    if(resumeTime > GetTimePreciseSec()) then
        return true

    else
        return false

    end
end

local function internalCoroutineResume()
    coroutine.resume(inspectRoutine)

end

local function analyzeCoroutine(origin)
    local status = inspectRoutine and coroutine.status(inspectRoutine)
    local hasEntries, isBlocked = queueHasEntries(), isNotifyBlocked()
    
    miog.printDebug(origin, hasEntries, isBlocked, notifyBlocked, resumeTime > GetTimePreciseSec(), resumeTime, GetTimePreciseSec())

    if(hasEntries) then
        if(isBlocked) then
            if(analyzeTimerRunning) then
                return

            elseif(not pityTimerRunning) then
                analyzeTimerRunning = true
                local nextStart = resumeTime - GetTimePreciseSec()

                analyzeTimer = C_Timer.NewTimer(nextStart > 0 and nextStart + 0.3 or throttleSetting, function()
                    analyzeTimerRunning = false
                    analyzeCoroutine("SELF")

                end)

            end
        else
            if(status == nil or status == "dead") then
                inspectRoutine = coroutine.create(function()
                    for fullName in pairs(inspectionQueue) do
                        if(not isNotifyBlocked() and groupPlayerList[fullName] and canInspectPlayerInGroup(fullName)) then
                            NotifyInspect(groupPlayerList[fullName].unitID, true)

                            coroutine.yield()

                        end
                    end
                end)

                internalCoroutineResume()

            elseif(status == "suspended") then
                internalCoroutineResume()

            end
        end

    end
end

local function orderedAnalyze()
    if(resumeTime < GetTimePreciseSec()) then
        local status = inspectRoutine and coroutine.status(inspectRoutine)
        
        if(status == nil or status == "dead") then
            inspectRoutine = coroutine.create(function()
                local nextPlayerInfo = tremove(orderedInspectionQueue)

                if(nextPlayerInfo) then
                    print(nextPlayerInfo.name, nextPlayerInfo.unitID)

                    coroutine.yield()
                end
            end)

            coroutine.resume(inspectRoutine)
        end
    end
end

local function startUpdate()
    mainDataProvider = CreateDataProvider()

    for k, v in pairs(groupPlayerList) do
        mainDataProvider:Insert(v)

    end

    updateClassPanel()

    groupManager.RaidView:RefreshMemberData(mainDataProvider.collection)

    mainDataProvider:SetSortComparator(sortComparatorFunction)
    groupManager.ListView.ScrollBox:SetDataProvider(mainDataProvider, ScrollBoxConstants.RetainScrollPosition)

    groupUpdateQueued = false
end

local function queueGroupUpdate(instant, origin)
    --analyzeCoroutine(origin)
    orderedAnalyze()

    if(groupUpdateQueued and not instant) then
        return

    else
        groupUpdateQueued = true

        if(instant) then
            startUpdate()

        else
            updateTimer = C_Timer.NewTimer(throttleSetting, function()
                startUpdate()

            end)
        end
    end
end

local function clearPlayerFromInspectionIfCurrent(playerName)
    if(inspectionQueue[playerName] and inspectionPlayerData.name == playerName) then
        ClearInspectPlayer()
        
    end
end

local function saveSpecID(playerName, specID)
    savedPlayerSpecs[playerName] = specID
    groupPlayerList[playerName].specID = specID

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
                clearPlayerFromInspectionIfCurrent(playerName)

                saveSpecID(playerName, specID)

                updateSpecificFrameData(playerName, "spec", specID)
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


	end
end

local function checkAndCountPlayerStatus(fullName)
    if(savedPlayerSpecs[fullName]) then
        inspectedMembers = inspectedMembers + 1
        inspectableMembers = inspectableMembers + 1

    elseif(canInspectPlayerInGroup(fullName)) then
        inspectableMembers = inspectableMembers + 1

        if(fullName ~= fullPlayerName) then
            inspectionQueue[fullName] = true
            
        else
            savedPlayerSpecs[fullPlayerName] = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
            inspectedMembers = inspectedMembers + 1

        end
    end
end

local function countAllPlayersWithSpec()
    inspectedMembers = 0
    inspectableMembers = 0

    if(numOfGroupMembers > 0) then
        for groupIndex = 1, MAX_RAID_MEMBERS, 1 do
            local name = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

            if(name) then
                local fullName = miog.createFullNameValuesFrom("unitName", name)

                if(savedPlayerSpecs[fullName]) then
                    inspectedMembers = inspectedMembers + 1
                    inspectableMembers = inspectableMembers + 1

                elseif(canInspectPlayerInGroup(fullName)) then
                    inspectableMembers = inspectableMembers + 1

                    if(fullName == fullPlayerName) then
                        inspectedMembers = inspectedMembers + 1

                    end
                end
            end
        end
    end
end

local function checkOnlineStatus(unitID)
    return UnitIsConnected(unitID)
end

local function refreshDataOfAllPlayers()
    inspectedMembers = 0
    inspectableMembers = 0

    resetClassAndRoleCount()

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

                groupPlayerList[fullName] = {
                    index = groupIndex,
                    subgroup = subgroup,
                    unitID = unitID,
                    online = checkOnlineStatus(unitID) or online,
                    
                    fullName = fullName,
                    name = playerName,
                    realm = realm,
                    level = level,
                    
                    fileName = fileName,
                    className = localizedClassName,

                    rank = rank,
                    role = role,
                }

                checkAndCountPlayerStatus(fullName)

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
    local localizedClassName, fileName = UnitClass("player")
    local specID, _, _, _, combatRole = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())

    savedPlayerSpecs[fullPlayerName] = specID

    local data = {
        index = 1,
        subgroup = 1,
        unitID = "player",
        online = true,

        fullName = fullPlayerName,
        name = shortPlayerName,
        realm = playerRealm,
        level = UnitLevel("player"),

        fileName = fileName,
        className = localizedClassName,

        specID = specID,
        combatRole = combatRole,

    }

    groupPlayerList[fullPlayerName] = data

    checkAndCountPlayerStatus(fullPlayerName)

    if(classCount[fileName]) then
        classCount[fileName] = classCount[fileName] + 1

    end

    if(roleCount[combatRole]) then
        roleCount[combatRole] = roleCount[combatRole] + 1

    end

    refreshOptionalPlayerData(fullPlayerName, shortPlayerName, playerRealm)
end

local function removeSpecID(fullName)
    savedPlayerSpecs[fullName] = nil

    if(groupPlayerList[fullName]) then
        groupPlayerList[fullName].specID = nil

    end
end

local function clearPlayerFromInspectionQueue(fullName)
    for i = 1, #orderedInspectionQueue do
        if(orderedInspectionQueue[i].fullName == fullName) then
            orderedInspectionQueue[i] = nil

        end
    end
end

local function customEvents(event, ...)
    print(event, ...)

    if(event == "PLAYER_LEFT_GROUP") then
        local fullName = ...
        
        if(fullName) then
            savedPlayerSpecs[fullName] = nil
            retryList[fullName] = nil
            inspectionQueue[fullName] = nil
            groupPlayerList[fullName] = nil

            clearPlayerFromInspectionQueue(fullName)
        end
    elseif(event == "PLAYER_JOINED_GROUP") then
        local groupIndex, unitID, fullName, playerName, realm = ...

        if(fullName and not savedPlayerSpecs[fullName] and canInspectUnit(unitID)) then
            if(fullName ~= fullPlayerName) then
                inspectionQueue[fullName] = true
                tinsert(orderedInspectionQueue, {fullName = fullName})
                
            else
                savedPlayerSpecs[fullPlayerName] = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())

            end
        end

    end
end

-- needs to be called right after GROUP_ROSTER_UPDATE fires
local function handleGroupRosterUpdate(updateInstantly, origin)
    local numOfPlayersChanged = checkNumberOfGroupMembers()

    if(numOfPlayersChanged) then
        local currentMembers = {}
        local offset = 0

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

        countAllPlayersWithSpec()
    elseif(numOfGroupMembers > 0) then
        refreshDataOfAllPlayers()

    else
        resetClassAndRoleCount()
        refreshPlayerCharacterData()
        countAllPlayersWithSpec()
        
    end

    updateInspectionString()
    queueGroupUpdate(updateInstantly, origin)
end

local function isPlayerCurrentlyInInspection(fullName)
    if(inspectionPlayerData.name == fullName) then
        return true

    end

    return false
end

local function groupManagerEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        local isLogin, isReload = ...
        
        isInRaid = IsInRaid()
        handleGroupRosterUpdate(true, event)

	elseif(event == "INSPECT_READY") then
        local guid = ...

        if(guid) then
            local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(guid)

            if(name) then
                local fullName = miog.createFullNameValuesFrom("unitName", name .. (realmName and "-" .. realmName or ""))

                if(fullName) then
                    if(groupPlayerList[fullName]) then
                        local inspectID = GetInspectSpecialization(groupPlayerList[fullName].unitID)

                        if(inspectID) then
                            if(inspectID > 0) then
                                saveSpecID(fullName, inspectID)
                                updateSpecificFrameData(fullName, "spec", inspectID)

                            end
                        end
                        
                        if(isPlayerCurrentlyInInspection(fullName)) then
                            ClearInspectPlayer()
                            coroutine.resume(inspectRoutine)
                            
                        end

                        --clearPlayerFromInspectionIfCurrent(fullName)

                        --analyzeCoroutine("INSPECT DONE")

                    else
                        ClearInspectPlayer()

                    end
                else
                    ClearInspectPlayer()

                end
            end
        end

	elseif(event == "GROUP_JOINED" or event == "GROUP_LEFT") then
        isInRaid = IsInRaid()
        resetOnGroupChange()
        handleGroupRosterUpdate(true, event)

	elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
        local unitID = ...

        if(unitID) then
            local fullName = miog.createFullNameValuesFrom("unitID", unitID)
            removeSpecID(fullName)

            clearPlayerFromInspectionQueue(fullName)

        end

        --analyzeCoroutine("SPEC CHANGE")

	elseif(event == "GROUP_ROSTER_UPDATE") then
        isInRaid = IsInRaid()
        handleGroupRosterUpdate(false, event)

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
        handleGroupRosterUpdate(false, "FLAGS")
        
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
    classSpecPanel:SetPoint("BOTTOMRIGHT", classSpecPanel:GetParent(), "TOPRIGHT", 0, 1)
    classSpecPanel:SetPoint("BOTTOMLEFT", classSpecPanel:GetParent(), "TOPLEFT", 0, 1)

    classSpecPanel.TankIcon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")
    classSpecPanel.HealerIcon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")
    classSpecPanel.DamagerIcon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")

     for _, classEntry in ipairs(miog.CLASSES) do
        local currentClassFrame = classSpecPanel.Classes[classEntry.name]

        if(currentClassFrame) then
            currentClassFrame.Icon:SetTexture(classEntry.icon)
        end
    end

    classSpecPanel.InspectionString:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Inspection data:")
        GameTooltip:AddLine("Inspected members: " .. inspectedMembers)
        GameTooltip:AddLine("Inspectable members: " .. inspectableMembers)
        GameTooltip:AddLine("Total members: " .. numOfGroupMembers)
        GameTooltip:Show()
    end)
end

miog.loadGroupOrganizer = function()
    fullPlayerName, shortPlayerName, playerRealm = miog.createFullNameValuesFrom("unitID", "player")

    groupMoreThanFivePlayers = GetNumGroupMembers() > 5
    miog.GroupOrganizer = miog.pveFrame2.TabFramesPanel.GroupManager
    groupManager = miog.GroupOrganizer
    groupManager.Settings.Refresh:SetScript("OnClick", function()
        refreshGroupCycle()

        handleGroupRosterUpdate(true, "REFRESH")

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

	--miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")

    hooksecurefunc("NotifyInspect", function(unitID, own)
        notifyBlocked = true
        resumeTime = GetTimePreciseSec() + throttleSetting
        miog.printDebug("NOTIFY NOW", own)

        local fullName = miog.createFullNameValuesFrom("unitID", unitID)

        if(groupPlayerList[fullName]) then
            inspectionPlayerData = {name = fullName, unitID = unitID, fileName = groupPlayerList[fullName] and groupPlayerList[fullName].fileName}
            updateCurrentlyInspectedCharacter()

        end

        resetPityTimer()

        pityTimerRunning = true

        pityTimer = C_Timer.NewTimer(doubleThrottle, function()
            pityTimerRunning = false

            local inspectionName = inspectionPlayerData.name

            if(inspectionName) then
                miog.printDebug("PITY PLAYER", inspectionName)
                retryList[inspectionName] = retryList[inspectionName] and retryList[inspectionName] + 1 or 1
                ClearInspectPlayer()
            end

            --analyzeCoroutine("PITY")
        end)
    end)

    hooksecurefunc("ClearInspectPlayer", function()
        local name = inspectionPlayerData.name

        if(name) then
            miog.printDebug("CLEAR CURRENT INSPECTION", name)

            clearPlayerFromInspectionQueue(name)
            inspectionQueue[name] = nil
            inspectionPlayerData = {}

            resetPityTimer()

            updateCurrentlyInspectedCharacter()
        end

        notifyBlocked = false

        countAllPlayersWithSpec()
        updateInspectionString()
    end)

	groupManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	groupManager:RegisterEvent("INSPECT_READY")
	groupManager:RegisterEvent("GROUP_JOINED")
	groupManager:RegisterEvent("GROUP_LEFT")
	groupManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	groupManager:RegisterEvent("PLAYER_FLAGS_CHANGED")

	groupManager:SetScript("OnEvent", groupManagerEvents)

end