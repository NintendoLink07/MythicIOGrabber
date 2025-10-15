local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.groupManager = {}

local mainDataProvider = CreateDataProvider()
local currentSortHeader

local fullPlayerName, shortPlayerName, playerRealm
local numOfGroupMembers = 0
local groupMoreThanFivePlayers = false

local savedPlayerSpecs = {}
local savedKeystoneData = {}
local savedGearData = {}
local savedRaidData = {}
local savedMythicPlusData = {}

local inspectionTextData

local inspectionQueue = {}
local playersInGroup = {}

local groupManager
local inspectRoutine
local pityTimer

local notifyBlocked = false
local inspectionPlayerData = {}
local retryList = {}
local resumeTime = 0

local groupUpdateQueued = false
local updateTimer

local throttleSetting = miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE

local function isPlayerRetryBlocked(fullName)
    if(retryList[fullName] and retryList[fullName] < 5) then
        return true

    end
        
    return false
end

local function canInspectPlayer(fullName)
	local data = inspectionQueue[fullName]

	if(not data) then
		return false

	end

	if(UnitIsPlayer(data.unitID) and CanInspect(data.unitID) and (data.online ~= false or UnitIsConnected(data.unitID)) and isPlayerRetryBlocked(fullName)) then
		return true

    else
	end
end

local function countPlayersWithData()
	local playersWithSpecData, inspectableMembers = 0, 0

	for fullName in pairs(playersInGroup) do
		local playerSpec = savedPlayerSpecs[fullName]
		local hasPlayerSpec = playerSpec and playerSpec ~= 0

		if(hasPlayerSpec) then
			playersWithSpecData = playersWithSpecData + 1
			inspectableMembers = inspectableMembers + 1

		elseif(canInspectPlayer(fullName)) then
			inspectableMembers = inspectableMembers + 1
			
		end
	end

	return playersWithSpecData, inspectableMembers
end

local function getInspectionTextData()
    return inspectionTextData

end

miog.getInspectionTextData = getInspectionTextData

local function updateGroupInfoText()
	local name

    if(inspectionPlayerData.fileName) then
        local color = C_ClassColor.GetClassColor(inspectionPlayerData.fileName)
        name = color and WrapTextInColorCode(inspectionPlayerData.name, color:GenerateHexColor()) or inspectionPlayerData.name

    else
        name = inspectionPlayerData.name

    end

	local specs, members = countPlayersWithData()

    local concatTable = {
        "[", specs, "/", members, "/", GetNumGroupMembers(), "]"
    }

    inspectionTextData = {
        specs = specs,
        members = members,
        numGroupMembers = GetNumGroupMembers(),
        queue = inspectionQueue,
    }

	miog.ClassPanel.InspectionName:SetText(name or "")
    miog.ClassPanel.Status:SetText(table.concat(concatTable))
	miog.ClassPanel.LoadingSpinner:SetShown(inspectionPlayerData.name)
    miog.updateGroupClassData()
end

local function resetOnGroupChange()
    if(pityTimer) then
        pityTimer:Cancel()

    end

    if(updateTimer) then
        updateTimer:Cancel()
        
    end

    groupUpdateQueued = false

    inspectionQueue = {}

    savedPlayerSpecs = {}
    savedGearData = {}
    savedKeystoneData = {}
    savedRaidData = {}
    savedMythicPlusData = {}

    playersInGroup = {}
    retryList = {}
    resumeTime = 0

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

local function gatherData()
    mainDataProvider = CreateDataProvider()
    playersInGroup = {}

    local numOfMembers = GetNumGroupMembers()
    local isInRaid = IsInRaid()
    local offset = 0

    if(numOfMembers > 0) then
        for groupIndex = 1, MAX_RAID_MEMBERS, 1 do
            if(groupIndex <= numOfMembers) then
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

                        playersInGroup[fullName] = true
                        
                        if(fullName ~= fullPlayerName) then
                            if(canInspectPlayer(fullName) and not isPlayerRetryBlocked(fullName)) then
                                if(not savedPlayerSpecs[fullName]) then
                                    inspectionQueue[fullName] = {unitID = unitID, fileName = fileName, name = name, online = online}

                                else
                                    inspectionQueue[fullName] = nil

                                end

                            end

                        elseif(not savedPlayerSpecs[fullPlayerName]) then
                            savedPlayerSpecs[fullPlayerName] = GetSpecializationInfo(GetSpecialization())

                        end

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

                        --groupManager.RaidView:SetMemberValues(data)

                        data = saveOptionalPlayerData(data, fullName, playerName, realm)
                        
                        mainDataProvider:Insert(data)
                    end
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

        --groupManager.RaidView:SetMemberValues(data)
        
        saveOptionalPlayerData(data, fullPlayerName, shortPlayerName, playerRealm)
        
        mainDataProvider:Insert(data)
    end

    groupManager.RaidView:RefreshMemberData(mainDataProvider.collection)
end

local function queueHasEntries()
    local hasEntries = false

    for k, v in pairs(inspectionQueue) do
        hasEntries = true
        break

    end

    return hasEntries
end

local function clearPlayer(name, stopInspection)
    if(name) then
        inspectionQueue[name] = nil

        if(stopInspection) then
            --print("2", "CLEAR", name, stopInspection)

            ClearInspectPlayer()

            if(pityTimer) then
                pityTimer:Cancel()

            end
            inspectionPlayerData = {}
            notifyBlocked = false

            updateGroupInfoText()
        end
    end
end

local function startNotify(name, unitID)
    if(notifyBlocked or isPlayerRetryBlocked(name)) then
        clearPlayer(name)
        --print("ABORT BLOCK", notifyBlocked, retryList[name])
        return false
    end

    if(not playersInGroup[name] and not inspectionQueue[name]) then
        --print("ABORT N/A", playersInGroup[name], inspectionQueue[name])
        clearPlayer(name)
        return false
    end

    --print("1", "NEXT PLAYER", name)
    NotifyInspect(unitID)
    updateGroupInfoText()
    inspectionPlayerData = {name = name, unitID = unitID, fileName = inspectionQueue[name] and inspectionQueue[name].fileName}

    pityTimer = C_Timer.NewTimer(throttleSetting * 4, function()
        clearPlayer(name, true)
        retryList[name] = retryList[name] and retryList[name] + 1 or 1
        --print("PITY PLAYER", name)
        miog.checkCoroutine("PITY")
    end)

    return true
end

local function startCoroutine()
    local status = inspectRoutine and coroutine.status(inspectRoutine)
    --print("---", "START STATUS", status)

    if(status == nil or status == "dead") then
        inspectRoutine = coroutine.create(function()
            --print("---", "START COROUTINE NEW - INSPECT FUNCTION")
            for name, data in pairs(inspectionQueue) do
                local canStartNotify = resumeTime <= GetTimePreciseSec()

                --print("---", "CAN START", canStartNotify)

                if(canStartNotify) then
                    local notifySuccess = startNotify(name, data.unitID)

                    if(notifySuccess) then
                        coroutine.yield()

                    end
                else
                    local timerStart = resumeTime - GetTimePreciseSec()

                    C_Timer.NewTimer(timerStart > 0 and timerStart or throttleSetting, function()
                        startNotify(name, data.unitID)
                    
                    end)

                    coroutine.yield()
                end
            end

            if(queueHasEntries()) then
                

            end
        end)

        coroutine.resume(inspectRoutine)
    end
end

local function resumeCoroutine()
    local status = inspectRoutine and coroutine.status(inspectRoutine)
    --print("---", "RESUME STATUS", status)

    if(status == "suspended") then
        coroutine.resume(inspectRoutine)
    end
end

local function checkCoroutine(origin)
    local status = inspectRoutine and coroutine.status(inspectRoutine)
    --print(origin, "CHECK STATUS", status, notifyBlocked, queueHasEntries())

    if(not notifyBlocked and queueHasEntries()) then
        if(status == nil or status == "dead") then
            startCoroutine()
            
        elseif(status == "suspended") then
            resumeCoroutine()

        end
    end
end

local function queueGroupUpdate(instant, origin)
    gatherData()

    if(groupUpdateQueued) then
        return

    else
       -- print("-------------------", "QUEUED")
        groupUpdateQueued = true

        updateTimer = C_Timer.NewTimer(instant and 0.1 or 1.25, function()
            --print("-------------------", "EXECUTE QUEUE")
            mainDataProvider:SetSortComparator(sortComparatorFunction)
            groupManager.ListView.ScrollBox:SetDataProvider(mainDataProvider, ScrollBoxConstants.RetainScrollPosition)
            updateGroupInfoText()

            groupUpdateQueued = false

            checkCoroutine(origin)
        end)

    end
end

miog.checkCoroutine = checkCoroutine

local function checkIfPlayerIsInInspection(playerName)
    if(inspectionQueue[playerName] and inspectionPlayerData.name == playerName) then
        return true
    end

    return false
end

local function saveSpecIDManually(playerName, specID)
    clearPlayer(playerName, checkIfPlayerIsInInspection(playerName))

    if(not savedPlayerSpecs[playerName] or savedPlayerSpecs[playerName] ~= specID) then
        savedPlayerSpecs[playerName] = specID

        queueGroupUpdate(false, "MANUAL SAVE")
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
		queueGroupUpdate(false, "LOADING SCREEN")

    elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local fullName = miog.createFullNameValuesFrom("unitID", ...)

		if(fullName and playersInGroup[fullName]) then
			savedPlayerSpecs[fullName] = nil

		end

	elseif(event == "INSPECT_READY") then
        if(...) then
            local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(...)
            local fullName = miog.createFullNameValuesFrom("unitName", name .. "-" .. realmName)

            if(fullName) then
                if(playersInGroup[fullName]) then
                    if(checkIfPlayerIsInInspection(fullName)) then
                        local inspectID = GetInspectSpecialization(inspectionQueue[fullName].unitID)

                        if(inspectID) then
                            if(inspectID > 0) then
                                savedPlayerSpecs[fullName] = inspectID

                            end
                        end

                        clearPlayer(fullName, true)
                    end

                    queueGroupUpdate(false, "INSPECT DONE")
                end
            end
        end

		--checkPlayerInspectionStatus(fullName, nil, 1)
	elseif(event == "GROUP_JOINED") then
        resetOnGroupChange()
		queueGroupUpdate(true, "JOIN")

	elseif(event == "GROUP_LEFT") then
        resetOnGroupChange()
		queueGroupUpdate(true, "LEFT")

	elseif(event == "GROUP_ROSTER_UPDATE") then
        if(numOfGroupMembers ~= GetNumGroupMembers()) then
            groupMoreThanFivePlayers = GetNumGroupMembers() > 5
            updateElementExtent()

        end

		queueGroupUpdate(false, "ROSTER")

        numOfGroupMembers = GetNumGroupMembers()

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

miog.loadGroupOrganizer = function()
    fullPlayerName, shortPlayerName, playerRealm = miog.createFullNameValuesFrom("unitID", "player")

    groupMoreThanFivePlayers = GetNumGroupMembers() > 5
    -- miog.GroupOrganizer = miog.pveFrame2.TabFramesPanel.GroupManager
    miog.GroupOrganizer = miog.pveFrame2.TabFramesPanel.GroupManager
    groupManager = miog.GroupOrganizer
    groupManager.Settings.Refresh:SetScript("OnClick", function()
        if(not updateTimer:IsCancelled()) then
            updateTimer:Cancel()

        end

        retryList = {}
        groupUpdateQueued = false
        queueGroupUpdate(true, "REFRESH")

        groupManager.RaidView:Unlock()
    end)

	miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("MIOG_GroupOrganizerLineTemplate", function(frame, data)
        frame.data = data
        frame.id = data.index
        frame.name = data.fullName
        frame.unit = data.unitID

        local classColor  = C_ClassColor.GetClassColor(data.fileName)
        local r, g, b = classColor:GetRGBA()
        --frame.BackgroundColor:SetColorTexture(r, g, b, 0.65)
    end)

    view:SetPadding(0, 0, 0, 0, 0)
    groupManager.view = view
    updateElementExtent()

    ScrollUtil.InitScrollBoxListWithScrollBar(groupManager.ListView.ScrollBox, miog.pveFrame2.ScrollBarArea.GroupManagerScrollBar, view)

    local tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
    groupManager.tableBuilder = tableBuilder
    tableBuilder:SetHeaderContainer(groupManager.ListView.HeaderContainer)
    tableBuilder:SetTableMargins(1, 1)

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
    createColumn("Name", "MIOG_GroupOrganizerTextCellTemplate", "name", true, 1.8)
    createColumn("Role", "MIOG_GroupOrganizerIconCellTemplate", "combatRole", true, 0.8)
    createColumn("Class", "MIOG_GroupOrganizerIconCellTemplate", "class", false, 0.8)
    createColumn("Spec", "MIOG_GroupOrganizerIconCellTemplate", "specID", true, 0.85)
    createColumn("Level", "MIOG_GroupOrganizerTextCellTemplate", "level", true, 0.9)
    createColumn("I-Lvl", "MIOG_GroupOrganizerTextCellTemplate", "itemLevel", true, 0.8)
    createColumn("Repair", "MIOG_GroupOrganizerTextCellTemplate", "durability", true, 1)
    createColumn("M+", "MIOG_GroupOrganizerTextCellTemplate", "score", true, 0.8)
    createColumn("Raid", "MIOG_GroupOrganizerTextCellTemplate", "progress", true, 1.15)
    ---createColumn("Key", "MIOG_GroupOrganizerTextCellTemplate", "keylevel", true, 1.35)
    --createColumn("#", "MIOG_GroupOrganizerTextCellTemplate", "index", true, 0.35)
    tableBuilder:Arrange()

	groupManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	groupManager:RegisterEvent("INSPECT_READY")
	groupManager:RegisterEvent("GROUP_JOINED")
	groupManager:RegisterEvent("GROUP_LEFT")
	groupManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	groupManager:RegisterEvent("PLAYER_FLAGS_CHANGED")

	groupManager:SetScript("OnEvent", groupManagerEvents)

end

hooksecurefunc("NotifyInspect", function(unitID)
	resumeTime = GetTimePreciseSec() + throttleSetting
    notifyBlocked = true
end)