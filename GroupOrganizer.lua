local addonName, miog = ...
local wticc = WrapTextInColorCode

local currentSortHeader

local fullPlayerName, shortPlayerName, playerRealm
local numOfGroupMembers = 0
local groupMoreThanFivePlayers = false

local savedPlayerSpecs = {}
local savedKeystoneData = {}
local savedGearData = {}
local savedRaidData = {}
local savedMythicPlusData = {}


local inspectionQueue = {}
local playersInGroup = {}

local groupManager
local inspectRoutine
local pityTimer

local notifyBlocked = false
local inspectionPlayerName
local retryList = {}
local resumeTime = 0

local throttleSetting = miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE

local function canInspectPlayer(fullName)
	local data = inspectionQueue[fullName]

	if(not data) then
		return false

	end

	if(UnitIsPlayer(data.unitID) and CanInspect(data.unitID) and (data.online ~= false or UnitIsConnected(data.unitID))) then
		return true

	end
end

local function countPlayersWithData()
	local specCount = {}
	local playersWithSpecData, inspectableMembers = 0, 0

	for fullName in pairs(playersInGroup) do
		local playerSpec = savedPlayerSpecs[fullName]
		local hasPlayerSpec = playerSpec and playerSpec ~= 0

		if(hasPlayerSpec) then
			specCount[playerSpec] = specCount[playerSpec] and specCount[playerSpec] + 1 or 1

			playersWithSpecData = playersWithSpecData + 1
			inspectableMembers = inspectableMembers + 1

		elseif(canInspectPlayer(fullName)) then
			inspectableMembers = inspectableMembers + 1
			
		end
	end

	--updateSpecPanels(specCount)

	return playersWithSpecData, inspectableMembers
end

local function updateInspectionText()
	local name

	if(inspectionPlayerName) then
        if(inspectionQueue[inspectionPlayerName] and inspectionQueue[inspectionPlayerName].fileName) then
            local color = C_ClassColor.GetClassColor(inspectionQueue[inspectionPlayerName].fileName)
            name = color and WrapTextInColorCode(inspectionQueue[inspectionPlayerName].name, color:GenerateHexColor()) or inspectionQueue[inspectionPlayerName].name

        else
            name = inspectionPlayerName

        end

	else
		name = ""

	end

	local specs, members = countPlayersWithData()

	local numGroupMembers = GetNumGroupMembers()

	miog.ClassPanel.InspectionName:SetText(name)
    miog.ClassPanel.Status:SetText("[" .. specs .. "/" .. members .. "/" .. numGroupMembers .. "]")
	miog.ClassPanel.Status.inspectList = inspectionQueue

    miog.ClassPanel.Status.data = {specs = specs, members = members}
	miog.ClassPanel.LoadingSpinner:SetShown(inspectionPlayerName ~= nil)
end

local function resetOnGroupChange()
    inspectionQueue = {}

    savedPlayerSpecs = {}
    savedGearData = {}
    savedKeystoneData = {}
    savedRaidData = {}
    savedMythicPlusData = {}

    playersInGroup = {}
    retryList = {}
    resumeTime = 0

    if(pityTimer) then
        pityTimer:Cancel()

    end

    inspectionPlayerName = nil
    
    updateInspectionText()
end

local sortComparatorFunction

local function setDataProviderSort(originColumnHeader, key)
    local dataProvider = groupManager.ScrollBox:GetDataProvider()

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

local function createColumn(name, cellTemplate, key, useForSort, iconColumn)
    local tableBuilder = groupManager.tableBuilder
    local column = tableBuilder:AddColumn()
    local header = column:ConstructHeader("Button", "MIOG_GroupOrganizerHeaderTemplate", name, key, useForSort and setDataProviderSort)
    column:ConstructCells("Frame", cellTemplate, key)

    if(fixed) then
        local width
        
        if(column.headerFrame.Text) then
            width = column.headerFrame.Text:GetStringWidth() + 20

        end

        column:SetFixedConstraints(width or 48, 1)

    elseif(key == "name") then
        column:SetFixedConstraints(88, 1)
        
    else
	    column:SetPadding(1);
    end
end

local function updateElementExtent()
    local indiHeight = groupManager.ScrollBox:GetHeight() / (groupMoreThanFivePlayers and 18 or 6)
    groupManager.view:SetElementExtent(indiHeight)

end

local function saveOptionalPlayerData(data, fullName, playerName, realm)
    if(not playerName or not realm) then
        playerName, realm = miog.createSplitName(fullName)
    end

    local playerGear = savedGearData[fullName]

    print(fullName)
    DevTools_Dump(playerGear)

    if(playerGear) then
        data.itemLevel = playerGear.ilevel or 0
        data.durability = playerGear.durability or 0
        
    else
        data.itemLevel = 0
        data.durability = 0

    end
    
    local keystoneData = savedKeystoneData[fullName]

    if(keystoneData and miog.CHALLENGE_MODE_INFO[keystoneData.challengeMapID]) then
        local challengeModeMapID = keystoneData.challengeMapID

        local mapName = C_ChallengeMode.GetMapUIInfo(challengeModeMapID)
        data.keystoneShortName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[challengeModeMapID].mapID].shortName
        data.keylevel = keystoneData.level
        data.keystoneFullName = mapName

    else
        data.keystoneShortName = ""
        data.keylevel = 0
        data.keystoneFullName = ""

    end

    savedRaidData[fullName] = savedRaidData[fullName] or miog.getRaidProgressDataOnly(playerName, realm)

    if(savedRaidData[fullName]) then
        data.progress = ""

        local raidTable = {}

        for _, v in ipairs(savedRaidData[fullName].character.ordered) do
            if(v.difficulty > 0) then
                raidTable[v.mapID] = raidTable[v.mapID] or {}

                tinsert(raidTable[v.mapID], wticc(v.parsedString, miog.DIFFICULTY[v.difficulty].color) .. " ")

            end
        end

        for k, v in pairs(raidTable) do
            data.progress = data.progress .. table.concat(v) .. "\r\n"

        end

        data.progressWeight = savedRaidData[fullName].character.progressWeight or 0

    else
        data.progressWeight = 0
        data.progress = "-"

    end

    savedMythicPlusData[fullName] = savedMythicPlusData[fullName] or miog.getMPlusScoreOnly(playerName, realm)
    data.score = savedMythicPlusData[fullName]
               
    return data
end

local function updateGroup()
    local tableBuilder = groupManager.tableBuilder
    tableBuilder:Reset()
    updateElementExtent()

    playersInGroup = {}

    local dataProvider = CreateDataProvider()
    dataProvider:SetSortComparator(sortComparatorFunction)

    createColumn("Name", "MIOG_GroupOrganizerTextCellTemplate", "name", true)
    createColumn("Role", "MIOG_GroupOrganizerIconCellTemplate", "combatRole", true, true)
    createColumn("Class", "MIOG_GroupOrganizerIconCellTemplate", "class", false, true)
    createColumn("Spec", "MIOG_GroupOrganizerIconCellTemplate", "specID", true, true)
    createColumn("Level", "MIOG_GroupOrganizerTextCellTemplate", "level", true)
    createColumn("I-Lvl", "MIOG_GroupOrganizerTextCellTemplate", "itemLevel", true)
    createColumn("Repair", "MIOG_GroupOrganizerTextCellTemplate", "durability", true)
    createColumn("M+", "MIOG_GroupOrganizerTextCellTemplate", "score", true)
    createColumn("Raid", "MIOG_GroupOrganizerTextCellTemplate", "progressWeight", true)
    createColumn("Key", "MIOG_GroupOrganizerTextCellTemplate", "keylevel", true)
    createColumn("Group", "MIOG_GroupOrganizerTextCellTemplate", "index", true)

    local numOfMembers = GetNumGroupMembers()
    local isInRaid = IsInRaid()
    local offset = 0

    if(numOfMembers > 0) then
        for groupIndex = 1, numOfMembers, 1 do
            local name, rank, subgroup, level, localizedClassName, fileName, _, online, _, role, _, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

            if(name) then
                local unitID
                local playerName, realm = miog.createSplitName(name)
                local fullName = miog.createFullNameFrom("unitName", name)

                if(isInRaid) then
                    unitID = "raid" .. groupIndex

                elseif(fullPlayerName ~= fullName) then
                    unitID = "party" .. groupIndex - offset

                else
                    unitID = "player"

                    offset = offset + 1

                end

                playersInGroup[fullName] = true

                local playerSpec = savedPlayerSpecs[fullName] or 0
                
                if(fullName ~= fullPlayerName) then
                    if(not savedPlayerSpecs[fullName] and online) then
                        inspectionQueue[fullName] = unitID

                    end

                else
                    savedPlayerSpecs[fullPlayerName] = GetSpecializationInfo(GetSpecialization())

                end

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

                data = saveOptionalPlayerData(data, fullName)
	            
                dataProvider:Insert(data)
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
            name = UnitNameUnmodified("player"),
            realm = playerRealm,
            level = UnitLevel("player"),

            fileName = fileName,
            className = localizedClassName,

            specID = GetSpecializationInfo(GetSpecialization()),
            combatRole = GetSpecializationRoleByID(GetSpecializationInfo(GetSpecialization())),

        }
        
        saveOptionalPlayerData(data, fullPlayerName)
        
        dataProvider:Insert(data)
    end

    groupManager.tableBuilder:Arrange()

    groupManager.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
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
            ClearInspectPlayer()
            print("CLEAR", name)
            inspectionPlayerName = nil
            notifyBlocked = false

            if(pityTimer) then
                pityTimer:Cancel()

            end
        end
    end
end

local function startNotify(name, unitID)
    if(notifyBlocked or retryList[name] and retryList[name] > 5) then
        return false
    end

    if(not playersInGroup[name]) then
        clearPlayer(name)
        return false
    end

    print("NEXT PLAYER", name)
    NotifyInspect(unitID)
    inspectionPlayerName = name

    pityTimer = C_Timer.NewTimer(throttleSetting * 3, function()
        clearPlayer(name, true)
        retryList[name] = retryList[name] and retryList[name] + 1 or 1
        miog.checkCoroutine(1)
    end)

    return true
end

local function startCoroutine()
    local status = inspectRoutine and coroutine.status(inspectRoutine)
    print("START STATUS", status)

    if(status == nil or status == "dead") then
        inspectRoutine = coroutine.create(function()
            print("INSPECT FUNCTION")
            for name, unitID in pairs(inspectionQueue) do
                local canStartNotify = resumeTime <= GetTimePreciseSec()

                if(canStartNotify) then
                    local notifySuccess = startNotify(name, unitID)

                    if(notifySuccess) then
                        coroutine.yield()

                    end
                else
                    local timerStart = resumeTime - GetTimePreciseSec()

                    C_Timer.NewTimer(timerStart > 0 and timerStart or throttleSetting, function()
                        startNotify(name, unitID)
                        coroutine.resume(inspectRoutine)
                    
                    end)

                    coroutine.yield()
                end
            end
        end)

        coroutine.resume(inspectRoutine)
    end
end

local function resumeCoroutine()
    local status = inspectRoutine and coroutine.status(inspectRoutine)
    print("RESUME STATUS", status)

    if(status == "suspended") then
        coroutine.resume(inspectRoutine)

    end
end

local function checkCoroutine(origin)
    local status = inspectRoutine and coroutine.status(inspectRoutine)
    print(origin, "CHECK STATUS", status)

    if(not notifyBlocked and queueHasEntries()) then
        if(status == nil or status == "dead") then
            startCoroutine()
            
        elseif(status == "suspended") then
            resumeCoroutine()

        end
    end
end

miog.checkCoroutine = checkCoroutine


local function checkIfPlayerIsInInspection(playerName)
    if(inspectionPlayerName == playerName) then
        clearPlayer(playerName, true)

    end
end

local function saveSpecIDManually(playerName, specID)
    checkIfPlayerIsInInspection(playerName)

    if(not savedPlayerSpecs[playerName] or savedPlayerSpecs[playerName] ~= specID) then
        print("MANUALLY", playerName, specID)

        savedPlayerSpecs[playerName] = specID

        checkCoroutine(9)
        updateGroup()
        updateInspectionText()
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
		local fullName = miog.createFullNameFrom("unitName", unitName)

        if(fullName) then
		    savedKeystoneData[fullName] = keystoneInfo

        end

        updateGroup()

		--updateSingleCharacterKeystoneData(fullName)

	end
end

local function isUnitID()

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

    local name

    --
    --proper unit check
    --

    if(UnitIsPlayer(unit)) then
        name = miog.createFullNameFrom("unitID", unit)

    else
        name = miog.createFullNameFrom("unitName", unit)

    end

    print("UNIT ID", unit, name, UnitIsPlayer(unit))

	if(name) then
        print("SAVE GEAR", name)
		savedGearData[name] = unitGear

        updateGroup()

		--updateSingleCharacterItemData(name)

	end
end

local function groupManagerEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
		updateGroup()
        checkCoroutine(2)

    --[[elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local fullName = miog.createFullNameFrom("unitID", ...)

		if(fullName and groupData[fullName]) then
			playerSpecs[fullName] = nil

		end]]

	elseif(event == "INSPECT_READY") then
		local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(...)
		local fullName = miog.createFullNameFrom("unitName", name .. "-" .. realmName)

        --local specializationIndex = C_SpecializationInfo.GetSpecialization(true)
        --local specID = C_SpecializationInfo.GetSpecializationInfo(specializationIndex, true)
        local inspectID = GetInspectSpecialization(inspectionQueue[fullName])

        print(fullName, inspectID)

        checkIfPlayerIsInInspection(fullName)

        if(playersInGroup[fullName]) then
            if(inspectID) then
                if(inspectID > 0) then
                    savedPlayerSpecs[fullName] = inspectID

                end
            end

            checkCoroutine(3)
            updateGroup()
            updateInspectionText()
        end

		--checkPlayerInspectionStatus(fullName, nil, 1)
	elseif(event == "GROUP_JOINED") then
        resetOnGroupChange()
		updateGroup()
        checkCoroutine(4)

	elseif(event == "GROUP_LEFT") then
        resetOnGroupChange()
        checkCoroutine(5)
		updateGroup()

	elseif(event == "GROUP_ROSTER_UPDATE") then
        if(numOfGroupMembers ~= GetNumGroupMembers()) then
            groupMoreThanFivePlayers = GetNumGroupMembers() > 5
            updateGroup()
            checkCoroutine(6)

        end

        updateInspectionText()

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
	end
end

miog.loadGroupOrganizer = function()
    groupMoreThanFivePlayers = GetNumGroupMembers() > 5
    -- miog.GroupOrganizer = miog.pveFrame2.TabFramesPanel.GroupManager
    miog.GroupOrganizer = CreateFrame("Frame", nil, miog.GroupManager, "MIOG_GroupOrganizer")
    groupManager = miog.GroupOrganizer
    groupManager:SetSize(miog.GroupManager:GetSize())
    groupManager:SetPoint("TOPLEFT", miog.GroupManager, "TOPRIGHT")

	miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("MIOG_GroupOrganizerLineTemplate", function(frame, data)
        frame.data = data
        frame.id = data.index
        frame.name = data.fullName
        frame.unit = data.unitID
    end)
    view:SetPadding(0, 0, 0, 0, 3)
    groupManager.view = view
    updateElementExtent()

    ScrollUtil.InitScrollBoxListWithScrollBar(groupManager.ScrollBox, groupManager.ScrollBar, view)

    local tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
    groupManager.tableBuilder = tableBuilder
    tableBuilder:SetHeaderContainer(groupManager.HeaderContainer)
    tableBuilder:SetTableMargins(1, 1)

    local function ElementDataProvider(elementData, ...)
        return elementData

    end

    tableBuilder:SetDataProvider(ElementDataProvider)

    local function ElementDataTranslator(elementData, ...)
        return elementData

    end

    ScrollUtil.RegisterTableBuilder(groupManager.ScrollBox, tableBuilder, ElementDataTranslator)

	fullPlayerName = miog.createFullNameFrom("unitID", "player")
	shortPlayerName, playerRealm = miog.createSplitName(fullPlayerName)

    --updateGroup()

	groupManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	groupManager:RegisterEvent("INSPECT_READY")
	groupManager:RegisterEvent("GROUP_JOINED")
	groupManager:RegisterEvent("GROUP_LEFT")
	groupManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	groupManager:SetScript("OnEvent", groupManagerEvents)
end

hooksecurefunc("NotifyInspect", function(unitID)
    print("NOTIFY", unitID)
	resumeTime = GetTimePreciseSec() + throttleSetting
    notifyBlocked = true
    updateInspectionText()
end)