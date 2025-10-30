local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.groupManager = {}

local mainDataProvider = CreateDataProvider()
local currentSortHeader
local isInRaid

local fullPlayerName, shortPlayerName, playerRealm
local numOfGroupMembers = 0
local groupMoreThanFivePlayers = false

local savedPlayerSpecs = {}
local savedKeystoneData = {}
local savedGearData = {}
local savedRaidData = {}
local savedMythicPlusData = {}

local inspectionTextData
local inspectRoutine

local inspectionQueue = {}
local playersInGroup = {}

local groupManager

local notifyBlocked = false
local inspectionPlayerData = {}
local retryList = {}
local resumeTime = 0

local groupUpdateQueued = false
local updateTimer

local pityTimer
local pityTimerRunning = false

local analyzeTimer
local analyzeTimerRunning = false

local throttleSetting = miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE
local doubleThrottle = throttleSetting * 2

local classSpecPanel

local function findFrame(fullName)
    local frame = groupManager.ListView.ScrollBox:FindFrameByPredicate(function(localFrame, data)
        return data.fullName == fullName

    end)

    return frame
end

local function updateSpecificFrameData(fullName, type, data)
    local listViewFrame = findFrame(fullName)
    local raidViewFrame = groupManager.RaidView:FindMemberFrame(fullName)

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

local function canInspectPlayer(fullName)
	local data = playersInGroup[fullName]

	if(not data) then
		return false

	end

	if(UnitIsPlayer(data.unitID) and CanInspect(data.unitID) and (data.online ~= false or UnitIsConnected(data.unitID)) and not isPlayerRetryBlocked(fullName)) then
		return true

	end
end

local function getInspectionTextData()
    return inspectionTextData

end

miog.getInspectionTextData = getInspectionTextData

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

local function resetOnGroupChange()
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

    inspectionQueue = {}

    savedPlayerSpecs = {}
    savedGearData = {}
    savedKeystoneData = {}
    savedRaidData = {}
    savedMythicPlusData = {}

    playersInGroup = {}
    retryList = {}

    inspectionPlayerData = {}
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

local function saveOptionalPlayerData(data, fullName, playerName, realm)
    local playerGear = savedGearData[fullName]

    if(playerGear) then
        data.itemLevel = playerGear.ilevel or 0
        data.durability = playerGear.durability or 0
        
    else
        data.itemLevel = 0
        data.durability = 0

    end
    
    local keystoneData = savedKeystoneData[fullName]

    if(keystoneData and miog.CHALLENGE_MODE_INFO[keystoneData.challengeMapID]) then
        --local mapName = C_ChallengeMode.GetMapUIInfo(keystoneData.challengeMapID)
        local challengeModeMapID = keystoneData.challengeMapID

        data.keystoneAbbreviatedName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[challengeModeMapID].mapID].abbreviatedName
        data.keylevel = keystoneData.level

    else
        data.keystoneShortName = ""
        data.keylevel = 0

    end

    local raiderIORaidData = miog.getRaidProgressDataOnly(playerName, realm)

    if(savedRaidData[fullName]) then
        data.progress = savedRaidData[fullName].progress
        data.progressWeight = savedRaidData[fullName].progressWeight
        
    elseif(raiderIORaidData) then
        data.progress = ""

        local raidTable = {}

        for _, v in ipairs(raiderIORaidData.character.ordered) do
            if(v.difficulty > 0) then
                raidTable[v.mapID] = raidTable[v.mapID] or {}

                tinsert(raidTable[v.mapID], wticc(v.parsedString, miog.DIFFICULTY[v.difficulty].color) .. " ")

            end
        end

        for k, v in pairs(raidTable) do
            data.progress = data.progress .. table.concat(v) .. "\r\n"

        end

        data.progressWeight = raiderIORaidData.character.progressWeight or 0

        savedRaidData[fullName] = {progress = data.progress, progressWeight = data.progressWeight}
    else
        data.progressWeight = 0
        data.progress = "-"

    end

    savedMythicPlusData[fullName] = savedMythicPlusData[fullName] or miog.getMPlusScoreOnly(playerName, realm)
    data.score = savedMythicPlusData[fullName]
               
    return data
end

local function createColumn(name, cellTemplate, key, useForSort, fill)
    local tableBuilder = groupManager.tableBuilder
    local column = tableBuilder:AddColumn()
    column:ConstructHeader("Button", "MIOG_GroupOrganizerHeaderTemplate", name, key, useForSort and setDataProviderSort)
    column:ConstructCells("Frame", cellTemplate, key)
    column:SetFillConstraints(fill or 0.7, 1)
end

local function updateElementExtent()
    local indiHeight = groupManager.ListView.ScrollBox:GetHeight() / (groupMoreThanFivePlayers and 12 or 6)
    groupManager.view:SetElementExtent(indiHeight)

end

local function updateSpecInspectionData()
    local offset = 0

    local membersWithSpecs = 0
    local inspectableMembers = 0

    local classCount = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 0,
			[8] = 0,
			[9] = 0,
			[10] = 0,
			[11] = 0,
			[12] = 0,
			[13] = 0,
		}

		local roleCount = {
			["TANK"] = 0,
			["HEALER"] = 0,
			["DAMAGER"] = 0,
			["NONE"] = 0,
		}


    if(numOfGroupMembers > 0) then
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

                    --playersInGroup[fullName] = {unitID = unitID, fullName = fullName, fileName = fileName, name = name, online = online}

                    if(savedPlayerSpecs[fullName]) then
                        membersWithSpecs = membersWithSpecs + 1
                        inspectableMembers = inspectableMembers + 1

                    elseif(canInspectPlayer(fullName)) then
                        inspectableMembers = inspectableMembers + 1

                        if(fullName ~= fullPlayerName) then
                            inspectionQueue[fullName] = {unitID = unitID, fullName = fullName, online = online}
                            
                        else
                            savedPlayerSpecs[fullPlayerName] = GetSpecializationInfo(GetSpecialization())
                            membersWithSpecs = membersWithSpecs + 1

                        end

                    end
                    
                    if(classCount[miog.CLASSFILE_TO_ID[fileName] ]) then
                        classCount[miog.CLASSFILE_TO_ID[fileName] ] = classCount[miog.CLASSFILE_TO_ID[fileName] ] + 1

                    end

                    if(roleCount[combatRole]) then
                        roleCount[combatRole] = roleCount[combatRole] + 1
        
                    end
                end
            end
        end

        local concatTable = {
            "[", membersWithSpecs, "/", inspectableMembers, "/", GetNumGroupMembers(), "]"
        }

        inspectionTextData = {
            specs = membersWithSpecs,
            members = inspectableMembers,
            numGroupMembers = GetNumGroupMembers(),
            queue = inspectionQueue,
            retry = retryList,
        }
    
        classSpecPanel.InspectionDataString:SetText(table.concat(concatTable))

    else
        local _, id = UnitClassBase("player")
        local specID, _, _, _, role = GetSpecializationInfo(GetSpecialization())

        savedPlayerSpecs[fullPlayerName] = specID
        
        if(classCount[id]) then
            classCount[id] = classCount[id] + 1

        end

        if(roleCount[role]) then
            roleCount[role] = roleCount[role] + 1

        end
    end

	classSpecPanel.TankString:SetText(roleCount["TANK"])
	classSpecPanel.HealerString:SetText(roleCount["HEALER"])
	classSpecPanel.DamagerString:SetText(roleCount["DAMAGER"])
end

local function gatherData()
    mainDataProvider = CreateDataProvider()
    playersInGroup = {}

    local offset = 0

    if(numOfGroupMembers > 0) then
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

                    playersInGroup[fullName] = {unitID = unitID, fullName = fullName, fileName = fileName, name = name, online = online}

                    --[[if(not savedPlayerSpecs[fullName]) then
                        if(fullName ~= fullPlayerName) then
                            if(canInspectPlayer(fullName)) then
                                inspectionQueue[fullName] = {unitID = unitID, fullName = fullName}

                            end

                        else
                            savedPlayerSpecs[fullPlayerName] = GetSpecializationInfo(GetSpecialization())

                        end
                    end]]

                    local playerSpec = savedPlayerSpecs[fullName] or 0

                    local data = {
                        index = groupIndex,
                        subgroup = subgroup,
                        unitID = unitID,
                        online = online,
                        
                        fullName = fullName,
                        name = playerName,
                        realm = realm,
                        level = level,
                        
                        fileName = fileName,
                        className = localizedClassName,
                        specID = playerSpec,
                        combatRole = combatRole or GetSpecializationRoleByID(playerSpec),

                        rank = rank,
                        role = role,
                    }

                    data = saveOptionalPlayerData(data, fullName, playerName, realm)
                    
                    mainDataProvider:Insert(data)
                end
            end
        end
    else
        local localizedClassName, fileName, id = UnitClass("player")
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

            specID = GetSpecializationInfo(GetSpecialization()),
            combatRole = GetSpecializationRoleByID(GetSpecializationInfo(GetSpecialization())),

        }
        
        saveOptionalPlayerData(data, fullPlayerName, shortPlayerName, playerRealm)
        
        mainDataProvider:Insert(data)
    end

    groupManager.RaidView:RefreshMemberData(mainDataProvider.collection)
end

local function queueHasEntries()
    local hasEntries = false

    for k, v in pairs(inspectionQueue) do
        if(canInspectPlayer(v.fullName)) then
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
            miog.printDebug("BLOCKED ANYWAY", analyzeTimerRunning, pityTimerRunning)
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
            miog.printDebug("ACTUALLY DOABLE")

            if(status == nil or status == "dead") then
                inspectRoutine = coroutine.create(function()
                    miog.printDebug("---", "COROUTINE NEW")

                    for k, nextUp in pairs(inspectionQueue) do
                        local name = nextUp.fullName

                        if(not isNotifyBlocked() and playersInGroup[name] and canInspectPlayer(name)) then
                            miog.printDebug("1", "NEXT PLAYER", name)
                            NotifyInspect(nextUp.unitID, true)

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

local function startUpdate()
    mainDataProvider:SetSortComparator(sortComparatorFunction)
    groupManager.ListView.ScrollBox:SetDataProvider(mainDataProvider, ScrollBoxConstants.RetainScrollPosition)

    groupUpdateQueued = false
end

local function queueGroupUpdate(instant, origin)
    analyzeCoroutine(origin)

    if(groupUpdateQueued and not instant) then
        return

    else
        groupUpdateQueued = true

        gatherData()

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

local function saveSpecIDManually(playerName, specID)
    if(not savedPlayerSpecs[playerName] or savedPlayerSpecs[playerName] ~= specID) then
        clearPlayerFromInspectionIfCurrent(playerName)

        miog.printDebug("MANUALLY", playerName, specID, savedPlayerSpecs[playerName])

        savedPlayerSpecs[playerName] = specID

        updateSpecificFrameData(playerName, "spec", specID)
        --queueGroupUpdate(false, "MANUAL SAVE")
    end
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
		if(singleUnitInfo.nameFull == shortPlayerName) then
			singleUnitInfo.nameFull = fullPlayerName
		end

		if(playersInGroup[singleUnitInfo.nameFull]) then
			if(singleUnitInfo.specId and singleUnitInfo.specId > 0) then
				saveSpecIDManually(singleUnitInfo.nameFull, singleUnitInfo.specId)

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

            queueGroupUpdate(false, "KEYSTONE")

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
        queueGroupUpdate(false, "GEAR")


	end
end

local function groupManagerEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        --local isLogin, isReload = ...
        
        isInRaid = IsInRaid()
        numOfGroupMembers = GetNumGroupMembers()

	elseif(event == "INSPECT_READY") then
        local guid = ...

        if(guid) then
            local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(guid)

            if(name) then
                local fullName = miog.createFullNameValuesFrom("unitName", name .. (realmName and "-" .. realmName or ""))

                if(fullName) then
                    if(playersInGroup[fullName]) then
                        local inspectID = GetInspectSpecialization(playersInGroup[fullName].unitID)

                        if(inspectID) then
                            if(inspectID > 0) then
                                savedPlayerSpecs[fullName] = inspectID
                                updateSpecificFrameData(fullName, "spec", inspectID)

                            end
                        end

                        analyzeCoroutine("INSPECT DONE")
                        --queueGroupUpdate(false, "INSPECT DONE")
                    end
                
                    clearPlayerFromInspectionIfCurrent(fullName)

                else
                    ClearInspectPlayer()

                end
            end
        end

	elseif(event == "GROUP_JOINED" or event == "GROUP_LEFT") then
        isInRaid = IsInRaid()
        resetOnGroupChange()
		queueGroupUpdate(true, event)

	elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
        local unitID = ...

        if(unitID) then
            local fullName = miog.createFullNameValuesFrom("unitID", unitID)

            savedPlayerSpecs[fullName] = nil

        end

        analyzeCoroutine("SPEC CHANGE")

	elseif(event == "GROUP_ROSTER_UPDATE") then
        isInRaid = IsInRaid()

        if(numOfGroupMembers ~= GetNumGroupMembers()) then

            groupMoreThanFivePlayers = GetNumGroupMembers() > 5
            updateElementExtent()

            numOfGroupMembers = GetNumGroupMembers()
        end

		queueGroupUpdate(false, event)

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
        queueGroupUpdate(false, "FLAGS")
        
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

     for classID, classEntry in ipairs(miog.CLASSES) do
        local currentClassFrame = classSpecPanel[classEntry.name]

        if(currentClassFrame) then
            currentClassFrame.Icon:SetTexture(classEntry.icon)
            currentClassFrame.Icon:SetDesaturated(true)
            currentClassFrame:SetAlpha(0.5)
            currentClassFrame.FontString:SetText(0)
        end
    end
end

miog.loadGroupOrganizer = function()
    loadClassSpecPanel()

    fullPlayerName, shortPlayerName, playerRealm = miog.createFullNameValuesFrom("unitID", "player")

    groupMoreThanFivePlayers = GetNumGroupMembers() > 5
    miog.GroupOrganizer = miog.pveFrame2.TabFramesPanel.GroupManager
    groupManager = miog.GroupOrganizer
    groupManager.Settings.Refresh:SetScript("OnClick", function()
        if(updateTimer) then
            updateTimer:Cancel()

        end

        retryList = {}
        
        if(inspectionPlayerData.name) then
            ClearInspectPlayer()

        end

        groupUpdateQueued = false
        queueGroupUpdate(true, "REFRESH")

        groupManager.RaidView:Unlock()
    end)

	--miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("MIOG_GroupOrganizerLineTemplate", function(frame, data)
        frame.data = data
        frame.id = data.index
        frame.name = data.fullName
        frame.unit = data.unitID
    end)

    view:SetPadding(0, 0, 0, 0, 0)
    groupManager.view = view
    updateElementExtent()

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

	groupManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	groupManager:RegisterEvent("INSPECT_READY")
	groupManager:RegisterEvent("GROUP_JOINED")
	groupManager:RegisterEvent("GROUP_LEFT")
	groupManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	groupManager:RegisterEvent("PLAYER_FLAGS_CHANGED")

	groupManager:SetScript("OnEvent", groupManagerEvents)

end

hooksecurefunc("NotifyInspect", function(unitID, own)
    print("NOTIFY NOW", own)
    notifyBlocked = true
    resumeTime = GetTimePreciseSec() + throttleSetting

    local fullName = miog.createFullNameValuesFrom("unitID", unitID)

    if(playersInGroup[fullName]) then
        inspectionPlayerData = {name = fullName, unitID = unitID, fileName = playersInGroup[fullName] and playersInGroup[fullName].fileName}
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

        analyzeCoroutine("PITY")
    end)
end)

hooksecurefunc("ClearInspectPlayer", function()
    print("CLEAR PLAYER NOW")
    
    local name = inspectionPlayerData.name

    if(name) then
        miog.printDebug("CLEAR CURRENT INSPECTION", name)

        inspectionQueue[name] = nil
        inspectionPlayerData = {}

        resetPityTimer()

        updateCurrentlyInspectedCharacter()
        updateSpecInspectionData()
    end

    notifyBlocked = false

end)