local addonName, miog = ...

local selectedInstance, selectedIndex, selectedEncounter, selectedDifficulty

local journalInfo = {}
local expansionTable = {}
local currentActivitiesTable = {}

local selectedItemClass, selectedItemSubClass
local selectedArmor, selectedClass, selectedSpec, selectedSlot

local missingItems = {}

local searchBoxText = ""
local noFilter = false
local searching = false

local armorTypeInfo = {
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Cloth)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Leather)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Mail)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Plate)},
}

local EJ_DIFFICULTIES = {
	DifficultyUtil.ID.DungeonNormal,
	DifficultyUtil.ID.DungeonHeroic,
	DifficultyUtil.ID.DungeonMythic,
	DifficultyUtil.ID.DungeonChallenge,
	DifficultyUtil.ID.DungeonTimewalker,
	DifficultyUtil.ID.RaidLFR,
	DifficultyUtil.ID.Raid10Normal,
	DifficultyUtil.ID.Raid10Heroic,
	DifficultyUtil.ID.Raid25Normal,
	DifficultyUtil.ID.Raid25Heroic,
	DifficultyUtil.ID.PrimaryRaidLFR,
	DifficultyUtil.ID.PrimaryRaidNormal,
	DifficultyUtil.ID.PrimaryRaidHeroic,
	DifficultyUtil.ID.PrimaryRaidMythic,
	DifficultyUtil.ID.RaidTimewalker,
	DifficultyUtil.ID.Raid40,
};

local difficultyOrder = {
    [9] = 1,
    [7] = 2,
    [3] = 3,
    [5] = 4,
    [4] = 5,
    [6] = 6,
    [1] = 10,
    [2] = 11,
    [17] = 12,
    [33] = 13,
    [14] = 14,
    [23] = 15,
    [24] = 16,
    [25] = 17,
    [15] = 18,
    [8] = 19,
    [16] = 20,
}

local function getItemClassSubClassName(itemID, classID, subclassID)
    if(classID == 0 and subclassID == 8) then
        return "Other"
    elseif(classID == 1) then
        --if(subclassID == 0) then
        return "Bag"

    elseif(classID == 3) then
        if(subclassID == 11) then
            return "Relic"
        end
    elseif(classID == 5 and subclassID == 2) then
        return "Curio"
        
    elseif(classID == 7) then
        return "Trade"
        
    elseif(classID == 9) then
        return "Recipe"

    elseif(classID == 12) then
        return "Quest"
    
    elseif(classID == 15) then
        if(subclassID == 0) then
            local _, toyName = C_ToyBox.GetToyInfo(itemID)

            if(toyName) then
                return "Toy"
                
            else
                return "Class token"

            end
        elseif(subclassID == 2) then
            return "Pet"

        elseif(subclassID == 4) then
            return "Other"

        elseif(subclassID == 5) then
            return "Mount"

        end
    else
        return "|cffff0000" .. "MISS" .. "|r" .. classID .. "-" .. subclassID

    end
end

local function fuzzyCheck(text, data)
    local filterArray = {}

    for k, v in pairs(data) do
        table.insert(filterArray, v.name)
        --data.index = k
    end

    local results = miog.fzy.filter(text, filterArray)

    table.sort(results, function(k1, k2)
        return k1[3] > k2[3]
    end)

    return results
end

local function checkIfItemIsFiltered(item)
    if(noFilter and selectedArmor == nil) then
        return true
    end

    local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(item.link)

    local isSpecialToken = classID == 5 and subclassID == 2 and selectedItemClass == 15 and selectedItemSubClass == 0
    local specialItemCorrectClass = classID == selectedItemClass
    local specialItemCorrectSubClass = selectedItemSubClass ~= nil and subclassID == selectedItemSubClass or selectedItemSubClass == nil and true

    local isSlotCorrect = item.filterType == C_EncounterJournal.GetSlotFilter()

    local isArmorCorrect = selectedArmor == item.armorType

    if(isSpecialToken or specialItemCorrectClass and specialItemCorrectSubClass) then
        return true

    elseif(selectedItemClass == nil and selectedItemSubClass == nil and (isSlotCorrect or isArmorCorrect)) then
        if(selectedArmor ~= nil and C_EncounterJournal.GetSlotFilter() ~= 15 and (not isSlotCorrect or not isArmorCorrect)) then
            return false

        end

        return true

    end

    return false
end

local function sortByEncounterIndex(k1, k2)
    --local k1, k2 = k1B.data, k2B.data

    if(k1.mapID == k2.mapID) then
        if(k1.encounterIndex == k2.encounterIndex) then
            if(k1.difficultyID and k2.difficultyID) then
                if(k1.difficultyID ~= k2.difficultyID) then
                    local diffOrder1, diffOrder2 = difficultyOrder[k1.difficultyID], difficultyOrder[k2.difficultyID]

                    return diffOrder1 > diffOrder2

                --else
                    --if(k1.template ~= k2.template) then
                        --return k1.template == "MIOG_DropsSourceTemplate"
                        
                    elseif(k1.itemlevel and k2.itemlevel) then
                        if(k1.itemlevel == k2.itemlevel) then
                            return k1.filterType < k2.filterType

                        else
                            return k1.itemlevel > k2.itemlevel

                        end
                    --end
                end
            end
        end

        return k1.encounterIndex < k2.encounterIndex
    end

    return k1.mapID > k2.mapID

end

local function shouldDisplayDifficultyForCurrentJournalInstance()
	return select(9, EJ_GetInstanceInfo());

end

local function getDifficultiesForCurrentJournalInstance()
    local instanceDifficulties = {}

    for i, difficultyID in ipairs(EJ_DIFFICULTIES) do
        if EJ_IsValidInstanceDifficulty(difficultyID) then
            table.insert(instanceDifficulties, difficultyID)
        end
    end

    return instanceDifficulties
end

local function getDifficultiesForJournalInstance(journalInstanceID)
    EJ_SelectInstance(journalInstanceID)

    return getDifficultiesForCurrentJournalInstance()

end

local function addGroupsToList(list, groups, blockList, isActive)
    if(groups and #groups > 0) then
        for _, v in ipairs(groups) do
            if(not blockList[v]) then
                local groupInfo = miog.requestGroupInfo(v)
                local activityInfo = miog.requestActivityInfo(groupInfo.highestDifficultyActivityID)
                activityInfo.isActive = isActive
                activityInfo.isRaid = not isActive
                activityInfo.name = activityInfo.groupName
                tinsert(list, activityInfo)
                blockList[v] = true
            end
        end
    end
end

local function createJournalInstanceListFromJournalInfo()
    local instanceList = {}

    for index, expansionInfo in ipairs(journalInfo) do
        for k, info in pairs(expansionInfo) do
            tinsert(instanceList, info)

        end
    end

    return instanceList
end

-- /tinspect C_LFGList.GetAvailableActivities(3, nil, Enum.LFGListFilter.CurrentExpansion)
-- /tinspect C_LFGList.GetAvailableActivityGroups(3, Enum.LFGListFilter.CurrentExpansion)

local function addMostCurrentRaidToList(instanceList, groups)
    local highestIDRaid = -1

    if(groups and #groups > 0) then
        for _, v in ipairs(groups) do
            local groupInfo = miog.requestGroupInfo(v)
            local activityInfo = miog.requestActivityInfo(groupInfo.highestDifficultyActivityID)
            activityInfo.isRaid = true
            activityInfo.name = activityInfo.mapName

            highestIDRaid = highestIDRaid > groupInfo.highestDifficultyActivityID and highestIDRaid or groupInfo.highestDifficultyActivityID
        end
    end

    tinsert(instanceList, miog.requestActivityInfo(highestIDRaid))
end

local function createListWithCurrentGroupInfos()
    local seasonalDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.CurrentSeason)
    local raidGroups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and Enum.LFGListFilter.CurrentExpansion or Enum.LFGListFilter.Recommended)

    local fullList = {}

    if(seasonalDungeons and #seasonalDungeons > 0) then
        for _, v in ipairs(seasonalDungeons) do
            tinsert(fullList, {groupID = v, isRaid = false})
        end
    end

    if(raidGroups and #raidGroups > 0) then
        for _, v in ipairs(raidGroups) do
            tinsert(fullList, {groupID = v, isRaid = true})
        end
    end

    local mapIDList = {}

    for k, info in ipairs(fullList) do
        local groupInfo = miog.requestGroupInfo(info.groupID)
        local activityInfo = miog.requestActivityInfo(groupInfo.highestDifficultyActivityID)
        
        tinsert(mapIDList, {activityID = groupInfo.highestDifficultyActivityID, mapID = activityInfo.mapID, name = groupInfo.groupName, isRaid = info.isRaid})
    end

    return mapIDList
end

local function createJournalInstanceListFromActivityGroups()
    local instanceList = {}
    local groupsDone = {}

    --local recommendedDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.Recommended)
    local seasonalDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.CurrentSeason)
    --local otherDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.PvE)
    --local expansionDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.CurrentExpansion)

    local raidGroups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and Enum.LFGListFilter.CurrentExpansion or Enum.LFGListFilter.Recommended)
    --local otherRaidGroups = C_LFGList.GetAvailableActivityGroups(3, Enum.LFGListFilter.PvE)
    --local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion))

    addGroupsToList(instanceList, seasonalDungeons, groupsDone, true)
    --addGroupsToList(instanceList, recommendedDungeons, groupsDone, false)
    --addGroupsToList(instanceList, otherDungeons, groupsDone, false)
    --addGroupsToList(instanceList, expansionDungeons, groupsDone, false)

    --addGroupsToList(instanceList, raidGroups, groupsDone, false)
    addMostCurrentRaidToList(instanceList, raidGroups)
    --addGroupsToList(instanceList, otherRaidGroups, groupsDone, false)

    --[[if(worldBossActivity and #worldBossActivity > 0) then
        for _, v in ipairs(worldBossActivity) do
            local activityInfo = miog.ACTIVITY_INFO[v]
            activityInfo.isActive = false
            activityInfo.isRaid = true
            activityInfo.name = activityInfo.mapName
            tinsert(instanceList, activityInfo)
        end
    end]]

    return instanceList
end

local function loadItems()
    local lootTable = {}
    local difficultyID = EJ_GetDifficulty()
    local startTime = GetTimePreciseSec()

    local _, _, _, _, _, _, _, _, _, mapID = EJ_GetInstanceInfo()
    miog.checkSingleMapIDForNewData(mapID)

    for i = 1, EJ_GetNumLoot() do
		local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)
        if(checkIfItemIsFiltered(itemInfo)) then
            itemInfo.index = i
            itemInfo.difficultyID = difficultyID
            itemInfo.encounterIndex = miog.ENCOUNTER_INFO[itemInfo.encounterID] and miog.ENCOUNTER_INFO[itemInfo.encounterID].index or 0

            if(itemInfo.link) then
                local item = Item:CreateFromItemLink(itemInfo.link)
                itemInfo.itemlevel = item:GetCurrentItemLevel()
            end

            itemInfo.mapID = mapID

            if itemInfo.displayAsPerPlayerLoot then
                tinsert(lootTable, itemInfo)

            elseif itemInfo.displayAsExtremelyRare then
                tinsert(lootTable, itemInfo)

            elseif itemInfo.displayAsVeryRare then
                tinsert(lootTable, itemInfo)

            elseif itemInfo.link then
                tinsert(lootTable, itemInfo)

            else
                missingItems[itemInfo.itemID] = true

            end
        end
	end

    return lootTable

    --[[for i = 1, numOfLoot, 1 do
        local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

        if(not itemInfo.name) then
            loadedItems[itemInfo.itemID] = loadedItems[itemInfo.itemID] and loadedItems[itemInfo.itemID] + 1 or 1
            stillLoading = true

        elseif(not stillLoading) then
            --local item = Item:CreateFromItemLink(itemInfo.link)

            if(searching) then
                itemInfo.difficultyID = difficultyID
                itemInfo.index = i

                if(displayDifferentItems) then
                    table.insert(itemsToFilter, itemInfo)

                else
                    table.insert(itemsToFilter, itemInfo)
                    
                    if(not currentItemData[itemInfo.itemID]) then
                        currentItemData[itemInfo.itemID] = {difficultyID = difficultyID, name = itemInfo.name, itemInfo = itemInfo, filterIndex = #itemsToFilter}

                    elseif(difficultyOrder[difficultyID] > difficultyOrder[currentItemData[itemInfo.itemID].difficultyID]) then
                        table.remove(itemsToFilter, currentItemData[itemInfo.itemID].filterIndex)
                        currentItemData[itemInfo.itemID] = {difficultyID = difficultyID, name = itemInfo.name, itemInfo = itemInfo, filterIndex = #itemsToFilter}

                    end

                end
            elseif(checkIfItemIsFiltered(itemInfo)) then
                local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]

                itemInfo.index = i
                --itemInfo.itemLevel = item:GetCurrentItemLevel()
                itemInfo.difficultyID = difficultyID

                if(encounterInfo) then
                    itemInfo.encounterIndex = encounterInfo and encounterInfo.index

                else
                    itemInfo.encounterIndex = 0

                end

                dataProvider:Insert(itemInfo)
            end
        end
    end]]
end

local function concatenateTables(t1, t2)
    local t2Size = #t2

    for i = 1 , t2Size do
        t1[#t1 + 1] = t2[i]

    end
    
    return t1
end


local function loadItemsFromInstance(journalInstanceID)
    EJ_SelectInstance(journalInstanceID)

    if(selectedEncounter) then
        EJ_SelectEncounter(selectedEncounter)

    end

    local lootTable = {}

    --local stillLoading = false

    if(not selectedDifficulty and shouldDisplayDifficultyForCurrentJournalInstance()) then
        for _, difficultyID in ipairs(EJ_DIFFICULTIES) do
            if EJ_IsValidInstanceDifficulty(difficultyID) then
                EJ_SetDifficulty(difficultyID)
                --if(not stillLoading) then
                    --stillLoading = loadItemsForDifficulty(difficultyID, dataProvider)
                    local tempTable = loadItems()

                    concatenateTables(lootTable, tempTable)
                    
                --end
            end
        end
    else
        local tempTable = loadItems()

        concatenateTables(lootTable, tempTable)
        --stillLoading = loadItemsForDifficulty(selectedDifficulty or EJ_InstanceIsRaid() and 14 or 1, dataProvider)

    end

    return lootTable

    --loading = stillLoading
end

local function areItemsStillMissing()
    for _ in pairs(missingItems) do
        return true

    end

    return false
end

local function loadItemsFromCurrentActivities()
    local instanceList = createJournalInstanceListFromActivityGroups()

    local filterTable = {}

    for _, v in ipairs(instanceList) do
        local tempTable = loadItemsFromInstance(v.journalInstanceID)
        concatenateTables(filterTable, tempTable)

    end

    local lootTable = {}

    if(not areItemsStillMissing()) then
        if(searching) then
            local results = fuzzyCheck(searchBoxText, filterTable)

            for k, v in ipairs(results) do
                local itemInfo = filterTable[v[1]]

                if(itemInfo) then
                    if(checkIfItemIsFiltered(itemInfo)) then
                        --[[local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

                        local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]

                        local item = Item:CreateFromItemLink(itemInfo.link)

                        itemInfo.index = itemInfo.index
                        itemInfo.itemLevel = item:GetCurrentItemLevel()
                        itemInfo.difficultyID = itemInfo.difficultyID
                        itemInfo.sourceName = encounterName
                        itemInfo.sourceIconType = "portrait"

                        if(encounterInfo) then
                            itemInfo.encounterIndex = encounterInfo and encounterInfo.index
                            itemInfo.creatureDisplayInfoID = encounterInfo and encounterInfo.creatureDisplayInfoID
                        else
                            itemInfo.encounterIndex = 0

                            local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);
                            itemInfo.creatureDisplayInfoID = sectionInfo.creatureDisplayID

                        end

                        itemInfo.positions = v[2]
                        itemInfo.score = v[3]

                        dataProvider:Insert(itemInfo)]]

                        itemInfo.positions = v[2]

                        tinsert(lootTable, itemInfo)

                    end
                end

            end

        else
            for k, v in ipairs(filterTable) do
                if(checkIfItemIsFiltered(v)) then
                    tinsert(lootTable, v)

                end

            end
        end
    end

    return lootTable
end

local function resetDifficulty()
    selectedDifficulty = nil
    miog.Drops.DifficultyDropdown:SetText(miog.Drops.DifficultyDropdown:GetDefaultText())

end

local function resetEncounter()
    selectedEncounter = nil
    EncounterJournal.encounterID = nil;

    miog.Drops.BossDropdown:SetText(miog.Drops.BossDropdown:GetDefaultText())

end

local function resetInstance()
    selectedInstance = nil
    EncounterJournal.instanceID = nil;

    miog.Drops.ScrollBox:Flush()
    miog.Drops.InstanceDropdown:SetText(miog.Drops.InstanceDropdown:GetDefaultText())
    
    resetEncounter()
    resetDifficulty()

end

local function refreshFilters()
    miog.Drops.SearchBox:ClearAllFilters()

    if(selectedInstance) then
        local instanceName = EJ_GetInstanceInfo(selectedInstance)

        miog.Drops.SearchBox:ShowFilter("instance", instanceName, function()
            resetInstance()
            miog.updateLoot()

        end)
    end

    if(selectedEncounter) then
        local encounterName = select(1, EJ_GetEncounterInfo(selectedEncounter))
        miog.Drops.SearchBox:ShowFilter("encounter", encounterName, function()
            resetEncounter()
            miog.updateLoot()

        end)
    end
    
    if(selectedDifficulty) then
        local difficultyName = miog.DIFFICULTY_ID_INFO[selectedDifficulty].name
        miog.Drops.SearchBox:ShowFilter("difficulty", difficultyName, function()
            resetDifficulty()
            miog.updateLoot()

        end)

    end
end

local function updateLoot()
    refreshFilters()
    
    miog.Drops.ScrollBox:Flush()
    searchBoxText = miog.Drops.SearchBox:GetText()
    noFilter = C_EncounterJournal.GetSlotFilter() == 15
    
    if(selectedSlot) then
        C_EncounterJournal.SetSlotFilter(selectedSlot)

    end

    searching = searchBoxText ~= ""

    missingItems = {}

    local mainLootTable
    local dataProvider = CreateTreeDataProvider()

    if(selectedInstance) then
        mainLootTable = loadItemsFromInstance(selectedInstance)
        --dataProvider:SetSortComparator(sortByEncounterIndex)

    else
        mainLootTable = loadItemsFromCurrentActivities()
        selectedInstance = nil

    end

    --[[
    
    Sort before
    Create headers
    Add children to headers
    EA repframe
    
    ]]

    table.sort(mainLootTable, sortByEncounterIndex)

    if(mainLootTable) then
        local lastInstance
        local lastEncounter, lastDifficulty
        local header1, subheader

        for i = 1, #mainLootTable do
            local itemInfo = mainLootTable[i]
            
            if(selectedInstance) then
                if(lastEncounter ~= itemInfo.encounterID) then
                    if(lastEncounter) then
			            header1:Insert({template = "MIOG_DropsFillerTemplate"})

                    end

                    header1 = dataProvider:Insert({
                        template = "MIOG_DropsSourceTemplate",
                        difficultyID = itemInfo.difficultyID,
                        encounterID = itemInfo.encounterID,
                        encounterIndex = itemInfo.encounterIndex,
                        mapID = itemInfo.mapID,
                        type = "encounter",
                        expandable = true,
                    })

                    lastDifficulty = nil

                end

                if(lastDifficulty ~= itemInfo.difficultyID) then
                    header1:Insert({
                        template = "MIOG_DropsDifficultyTemplate",
                        difficultyID = itemInfo.difficultyID,
                        encounterID = itemInfo.encounterID,
                        encounterIndex = itemInfo.encounterIndex,
                        mapID = itemInfo.mapID,
                        source = "difficulty",
                        expandable = true,
                    })
                    

                end

                itemInfo.template = "MIOG_DropsItemTemplate"

                header1:Insert(mainLootTable[i])

            elseif(not searching) then
                local sameInstance = lastInstance == itemInfo.mapID
                if(not sameInstance) then
                    header1 = dataProvider:Insert({
                        template = "MIOG_DropsSourceTemplate",
                        difficultyID = itemInfo.difficultyID,
                        mapID = itemInfo.mapID,
                        source = "instance",
                        expandable = true,
                    })

                end

                local differentEncounter = lastEncounter ~= itemInfo.encounterID
                local differentDifficulty = lastDifficulty ~= itemInfo.difficultyID

                if(differentDifficulty) then
                    if(differentEncounter) then
                        if(lastEncounter) then
                            subheader:Insert({template = "MIOG_DropsFillerTemplate"})

                        end

                        local array = {
                            template = "MIOG_DropsSourceTemplate",
                            difficultyID = itemInfo.difficultyID,
                            encounterID = itemInfo.encounterID,
                            encounterIndex = itemInfo.encounterIndex,
                            mapID = itemInfo.mapID,
                            source = "encounter",
                            expandable = true,
                        }

                        subheader = header1:Insert(array)
                    end

                    subheader:Insert({
                        template = "MIOG_DropsDifficultyTemplate",
                        difficultyID = itemInfo.difficultyID,
                        encounterID = itemInfo.encounterID,
                        encounterIndex = itemInfo.encounterIndex,
                        mapID = itemInfo.mapID,
                        source = "difficulty",
                        expandable = true,
                    })
                    

                end

                itemInfo.template = "MIOG_DropsItemTemplate"

                (subheader or header1):Insert(mainLootTable[i])

                --[[itemInfo.template = "MIOG_DropsFullItemTemplate"
                itemInfo.source = "activity"
                dataProvider:Insert(mainLootTable[i])]]

                lastInstance = itemInfo.mapID

            else
                itemInfo.template = "MIOG_DropsFullItemTemplate"
                itemInfo.source = "activity"
                dataProvider:Insert(mainLootTable[i])

            end

            lastDifficulty = itemInfo.difficultyID
            lastEncounter = itemInfo.encounterID
        end

        miog.Drops.ScrollBox:SetDataProvider(dataProvider)
    end
end

miog.updateLoot = updateLoot

local function selectDifficulty(difficultyID)
    selectedDifficulty = difficultyID
    EJ_SetDifficulty(difficultyID)

    updateLoot()

end

local function selectEncounter(encounterID)
    selectedEncounter = encounterID

    updateLoot()

end

local function selectInstance(journalInstanceID)
    local isDifferentInstance = journalInstanceID ~= selectedInstance

    selectedInstance = journalInstanceID

    if(selectedEncounter and isDifferentInstance) then
        resetEncounter()

    end

    updateLoot()
end

local function resetClassAndSpec()
    selectedClass = 0
    selectedSpec = 0
    EJ_ResetLootFilter()

    miog.Drops.ArmorDropdown:SetText(miog.Drops.ArmorDropdown:GetDefaultText())
end

local function resetArmorType()
    selectedArmor = nil

    miog.Drops.ArmorDropdown:SetText(miog.Drops.ArmorDropdown:GetDefaultText())
end


local function resetClassSpecAndArmor()
    resetClassAndSpec()
    resetArmorType()

end

local function createCurrentActivitiesTable()
    local list = createJournalInstanceListFromActivityGroups()

    table.sort(list, function(k1, k2)
        if(k1.isRaid == k2.isRaid) then
            if(k1.isRaid) then
                return k1.groupFinderActivityGroupID < k2.groupFinderActivityGroupID

            end

            return k1.fullName < k2.fullName

        end

        return k1.isRaid and true or k2.isRaid and false
    end)

    return list
end

local function sortJournalInstances(k1, k2)
    if(k1.isRaid == k2.isRaid) then
        if(k1.isRaid) then
            return k1.index < k2.index

        end

        return k1.name < k2.name

    end

    return k1.isRaid and true or k2.isRaid and false
end

local function loadInstanceInfo()
    expansionTable = {}

	for x = 1, EJ_GetNumTiers() - 1, 1 do
		local name, link = EJ_GetTierInfo(x)
		local expansionInfo = GetExpansionDisplayInfo(x-1)

		local expInfo = {}
		expInfo.text = name
		expInfo.icon = expansionInfo and expansionInfo.logo

		expansionTable[#expansionTable+1] = expInfo

	end

    journalInfo = {}

    for tierIndex = 1, EJ_GetNumTiers() - 1, 1 do
        EJ_SelectTier(tierIndex)
        journalInfo[tierIndex] = {}

        for k = 1, 2, 1 do
            local checkForRaid = k == 1 and true or false

            local counter = 1

            local journalInstanceID, name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceByIndex(counter, checkForRaid)
            local mapInfo = miog.getMapInfo(mapID)

            while(journalInstanceID) do
                tinsert(journalInfo[tierIndex], {
                    tier = tierIndex,
                    journalInstanceID = journalInstanceID,
                    name = name,
                    isRaid = checkForRaid,
                    --abbreviatedName = mapInfo.abbreviatedName,
                    mapID = mapID,
                    index = counter,
                })

                counter = counter + 1

                journalInstanceID, name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceByIndex(counter, checkForRaid)

            end
        end

        table.sort(journalInfo[tierIndex], sortJournalInstances)
    end

    local mapIDList = createListWithCurrentGroupInfos()

    for k, v in ipairs(mapIDList) do
        local journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(v.mapID)
        tinsert(currentActivitiesTable, {journalInstanceID = journalInstanceID, name = v.name, index = k, isRaid = v.isRaid, mapID = v.mapID})
        
    end

    table.sort(currentActivitiesTable, sortJournalInstances)

end

---[[
--- DROPCHECKER START
---
---
---
---
---
---]]

local function replaceItemLinkWithAdjustedVersion(link, isRaid, isActive)
    local newItemLink

    if(not isRaid and isActive) then
        newItemLink = miog.removeAndSetItemLinkItemLevels(link, "mythicPlus")

    else
        newItemLink = link

    end

    return newItemLink

end

---[[
--- DROPCHECKER END
---
---
---
---
---
---
---
---
---]]
---
---

local function updatePartialItemFrame(frame, data)
    frame.Icon:SetTexture(data.icon)
    local formattedText

    if(data.positions) then
        formattedText = ""

        local positionArray = {}

        for k, v in ipairs(data.positions) do
            positionArray[v] = true
        end

        for i = 1, strlen(data.name), 1 do
            if(positionArray[i]) then
                formattedText = formattedText .. WrapTextInColorCode(strsub(data.name, i, i), miog.CLRSCC.green)

            else
                formattedText = formattedText .. strsub(data.name, i, i)

            end

        end
    end

    --[[if(data.score) then
        if(data.score < math.huge) then
            local percentage = data.score / strlen(data.name) * 100
            frame.Percentage:SetText(miog.round3(percentage, 2) .. "%")

        else
            frame.Percentage:SetText("100%")

        end

    else
        frame.Percentage:SetText("")

    end]]

    frame.Name:SetText(formattedText or data.name)


    if(data.link) then
        local item = Item:CreateFromItemLink(data.link)
        frame.ItemLevel:SetText(item:GetCurrentItemLevel())
        frame.itemLink = data.link

        if(data.slot) then
            if(data.filterType == 14) then
                local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(data.link)

                local type = getItemClassSubClassName(data.itemID, classID, subclassID)
                
                frame.Slot:SetText(type)

            else
                frame.Slot:SetText(data.slot)

            end
        end
    end

    frame.encounterID = data.encounterID
end

local function updateSourceFrame(frame, data, fullFrame)
    frame.Icon:ClearAllPoints()

    if(data.expandable) then
        frame.Icon:SetPoint("LEFT", frame.ExpandFrame, "RIGHT", 2, 0)
        frame.ExpandFrame:Show()

    else
        frame.Icon:SetPoint("LEFT", frame, "LEFT", 2, 0)
        frame.ExpandFrame:Hide()

    end

    if(data.encounterID) then
        local encounterName, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID = EJ_GetEncounterInfo(data.encounterID)
        --local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

        
        local encData = miog.getEncounterInfo(data.encounterID)
        local text = miog.DIFFICULTY_ID_INFO[data.difficultyID].shortName

        if(fullFrame) then
            local mapInfo = miog.getJournalInstanceInfo(journalInstanceID)
            frame.Icon:SetTexture(mapInfo.icon)
            text = text .. " - " .. (mapInfo.abbreviatedName or "")
            frame.Name:SetText(WrapTextInColorCode("[" .. text .. "] ", miog.DIFFICULTY_ID_INFO[data.difficultyID].color:GenerateHexColor()) .. encounterName)

        elseif(encData) then
            SetPortraitTextureFromCreatureDisplayID(frame.Icon, encData.creatureDisplayInfoID)
            frame.Name:SetText(encounterName)
        end

    else
        local mapInfo = miog.getMapInfo(data.mapID)

        frame.Icon:SetTexture(mapInfo.icon)
        frame.Name:SetText(mapInfo.name)


    end
end

local function updateFullItemFrame(frame, data)
    updatePartialItemFrame(frame.Item, data)
    updateSourceFrame(frame.Source, data, true)
end

local function journalEvents(_, event, itemID)
    if(event == "EJ_LOOT_DATA_RECIEVED" and itemID and missingItems[itemID]) then
        missingItems[itemID] = nil

        if(not areItemsStillMissing()) then
            updateLoot()

        end
    end
end

miog.loadJournal = function()
    local journal = miog.pveFrame2.TabFramesPanel.Drops
    journal:SetScript("OnShow", function()
        if(not selectedInstance) then
            local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, mapID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
            local mapInfo = miog.MAP_INFO[mapID]

            if(mapInfo and mapInfo.journalInstanceID and mapInfo.journalInstanceID ~= 0 and instanceType ~= "none") then
                selectInstance(mapInfo.journalInstanceID)

            end
        end
    end)
    journal.SearchBox:OnLoad()
    journal.SearchBox:SetHierarchy({{id = "instance", order = 1}, {id = "difficulty", order = 2}, {id = "encounter", order = 2}})
	journal.SearchBox.Instructions:SetText("Enter atleast 3 characters to search...");

    loadInstanceInfo()

    local instanceDropdown = journal.InstanceDropdown

    instanceDropdown:SetDefaultText("Select an instance")
    instanceDropdown:SetupMenu(function(dropdown, rootDescription)
		for k, v in ipairs(expansionTable) do
            local expansionButton = rootDescription:CreateRadio(v.text, function(index) return selectedIndex == index end, nil, k)

            expansionButton:AddInitializer(function(button, description, menu)
                local leftTexture = button:AttachTexture();
                leftTexture:SetSize(16, 16);
                leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
                leftTexture:SetTexture(v.icon);

                button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

                return button.fontString:GetUnboundedStringWidth() + 18 + 5
            end)

            local lastIsRaid = false

            expansionButton:CreateTitle("Raids")

            for _, info in pairs(journalInfo[k]) do
                if(lastIsRaid and lastIsRaid ~= info.isRaid) then
                    expansionButton:CreateTitle("Dungeons")

                end

                local instanceButton = expansionButton:CreateRadio(info.name, function(localInfo) return selectedInstance == localInfo.journalInstanceID and selectedIndex == localInfo.tier end, function(localInfo)
                    selectInstance(localInfo.journalInstanceID)
                    selectedIndex = localInfo.tier
        
                end, info)
        
                instanceButton:AddInitializer(function(button, description, menu)
                    if(info.mapID and not miog.MAP_INFO[info.mapID]) then
                        print("NOTHING FOR", info.mapID)

                    end

                    if(info.mapID and miog.MAP_INFO[info.mapID] and miog.MAP_INFO[info.mapID].icon) then
                        local leftTexture = button:AttachTexture();
                        leftTexture:SetSize(16, 16);
                        leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
                        leftTexture:SetTexture(miog.MAP_INFO[info.mapID].icon);
            
                        button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);
            
                        return button.fontString:GetUnboundedStringWidth() + 18 + 5

                    end
                end)

                lastIsRaid = info.isRaid

            end
		end

        local currentActivitiesButton = rootDescription:CreateRadio("Current activities", function(index) return selectedIndex == index end, nil, 100)

        currentActivitiesButton:CreateTitle("Raids")

        local lastIsRaid = false
        for k, info in ipairs(currentActivitiesTable) do
            if(lastIsRaid and lastIsRaid ~= info.isRaid) then
                currentActivitiesButton:CreateTitle("Dungeons")

            end

            local instanceButton = currentActivitiesButton:CreateRadio(info.name, function(localInfo) return selectedInstance == localInfo.journalInstanceID and selectedIndex == 100 end, function(localInfo)
                selectInstance(localInfo.journalInstanceID)
                selectedIndex = 100
    
            end, info)
    
            instanceButton:AddInitializer(function(button, description, menu)
                local leftTexture = button:AttachTexture();
                leftTexture:SetSize(16, 16);
                leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
                leftTexture:SetTexture(miog.MAP_INFO[info.mapID].icon);
    
                button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);
    
                return button.fontString:GetUnboundedStringWidth() + 18 + 5
            end)

            lastIsRaid = info.isRaid

        end
    end)

	local bossDropdown = journal.BossDropdown
    bossDropdown:SetDefaultText("Select an encounter")
    bossDropdown:SetupMenu(function(dropdown, rootDescription)
        if(selectedInstance) then
            local bossTable = {}
    
            local counter = 1
            local name, _, journalEncounterID, _, _, _, _, mapID = EJ_GetEncounterInfoByIndex(counter, selectedInstance)
    
            while name do
                tinsert(bossTable, {encounterID = journalEncounterID, name = name})
    
                counter = counter + 1
    
                name, _, journalEncounterID, _, _, _, _, mapID = EJ_GetEncounterInfoByIndex(counter, selectedInstance)
            end
    
            local mapInfo = miog.checkJournalInstanceIDForNewData(selectedInstance)
    
            local tier = mapInfo.expansionLevel and mapInfo.expansionLevel + 1
    
            if(#bossTable == 0) then
                for i = 1, #mapInfo.bosses, 1 do
                    local v = mapInfo.bosses[i]
    
                    tinsert(bossTable, {encounterID = v.journalEncounterID, name = v.name})
                end
    
            end
    
            for k, v in ipairs(bossTable) do
                local encounterButton = rootDescription:CreateRadio(v.name, function(encounterID) return selectedEncounter == encounterID end, function(encounterID)
                    selectEncounter(encounterID)
    
                end, v.encounterID)
    
                if(miog.ENCOUNTER_INFO[v.encounterID]) then
                    encounterButton:AddInitializer(function(button, description, menu)
                        local leftTexture = button:AttachTexture();
                        leftTexture:SetSize(16, 16);
                        leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
                        SetPortraitTextureFromCreatureDisplayID(leftTexture, miog.ENCOUNTER_INFO[v.encounterID].creatureDisplayInfoID)
    
                        button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);
    
                        return button.fontString:GetUnboundedStringWidth() + 18 + 5
                    end)
                end
            end
        end
    end)


	local difficultyDropdown = journal.DifficultyDropdown
    difficultyDropdown:SetDefaultText("Select a difficulty")
    difficultyDropdown:SetupMenu(function(dropdown, rootDescription)
        if(selectedInstance) then
            for index, id in ipairs(getDifficultiesForJournalInstance(selectedInstance)) do
                local diffName = miog.DIFFICULTY_ID_INFO[id].name
                local difficultyButton = rootDescription:CreateRadio(diffName, function(difficultyID) return difficultyID == selectedDifficulty end, function(difficultyID)
                    selectDifficulty(difficultyID)
                    
                end, id)
            end
        end
    end)

	local view = CreateScrollBoxListTreeListView(12, 1, 1, 1, 1, 2);
    --local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 2);

    local function initFrames(frame, node)
		local data = node:GetData()

		frame.node = node

		if(data.template == "MIOG_DropsFullItemTemplate") then
			updateFullItemFrame(frame, data)

		elseif(data.template == "MIOG_DropsItemTemplate") then
			updatePartialItemFrame(frame, data)

		elseif(data.template == "MIOG_DropsSourceTemplate") then
            updateSourceFrame(frame, data)
            frame.ExpandFrame:SetState(false)

        elseif(data.template == "MIOG_DropsDifficultyTemplate") then
            local difficulty = miog.DIFFICULTY_ID_INFO[data.difficultyID]
            local text = difficulty.name
			frame.Difficulty:SetText(text)
            frame.Difficulty:SetTextColor(difficulty.color:GetRGBA())
            frame.Line:SetColorTexture(difficulty.color:GetRGBA())

		end
	end
	
	local function customFactory(factory, node)
		local data = node:GetData()
		local template = data.template

		factory(template, initFrames)
	end
	
	view:SetElementFactory(customFactory)
    
    ScrollUtil.InitScrollBoxListWithScrollBar(journal.ScrollBox, miog.pveFrame2.ScrollBarArea.DropsScrollBar, view);

    journal.SearchBox:SetScript("OnTextChanged", function(self, manual)
        SearchBoxTemplate_OnTextChanged(self)

        local length = strlen(self:GetText())

        if(length > 2 or length == 0) then
            updateLoot()

        end
    end)
    
    selectedSlot = C_EncounterJournal.GetSlotFilter()

    journal.SlotDropdown:SetDefaultText("Equipment slots")
    journal.SlotDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function(index)
            selectedItemClass = nil
            selectedItemSubClass = nil
            selectedSlot = nil
            C_EncounterJournal.ResetSlotFilter()

            updateLoot()

        end)

        local sortedFilters = {}

        for k, v in pairs(Enum.ItemSlotFilterType) do
            sortedFilters[v] = k
        end

        for i = 0, #sortedFilters - 1, 1 do
	        rootDescription:CreateRadio(miog.SLOT_FILTER_TO_NAME[i], function(index) return index == selectedSlot end, function(index)
                selectedItemClass = nil
                selectedItemSubClass = nil
                selectedSlot = index

                C_EncounterJournal.SetSlotFilter(index)
                updateLoot()

            end, i)
        end

        rootDescription:CreateRadio("Mounts", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            selectedSlot = nil

            C_EncounterJournal.SetSlotFilter(14)
            updateLoot()

        end, {class = 15, subclass = 5})

        rootDescription:CreateRadio("Recipes", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            selectedSlot = nil

            C_EncounterJournal.SetSlotFilter(14)
            updateLoot()

        end, {class = 9, subclass = nil})

        rootDescription:CreateRadio("Tokens", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            selectedSlot = nil

            C_EncounterJournal.SetSlotFilter(14)
            updateLoot()

        end, {class = 15, subclass = 0})
    end)

    selectedClass, selectedSpec = EJ_GetLootFilter()

    journal.ArmorDropdown:SetDefaultText("Armor types")
    journal.ArmorDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function(index)
            resetClassSpecAndArmor()
            updateLoot()

        end)

        local classButton = rootDescription:CreateButton("Classes")

        classButton:CreateButton(CLEAR_ALL, function(index)
            resetClassAndSpec()
            updateLoot()

        end)

        for k, v in ipairs(miog.CLASSES) do
	        local classMenu = classButton:CreateRadio(GetClassInfo(k), function(index) return index == selectedClass end, function(name)
                selectedClass = k
                selectedSpec = 0
                EJ_SetLootFilter(selectedClass, selectedSpec)
                updateLoot()

                dropdown:CloseMenu()
            end, k)

            for x, y in ipairs(v.specs) do
                local id, specName, description, icon, role, classFile, className = GetSpecializationInfoByID(y)

                classMenu:CreateRadio(specName, function(specID) return specID == selectedSpec end, function(name)
                    selectedClass = k
                    selectedSpec = id
                    EJ_SetLootFilter(k, id)
                    updateLoot()
                    
                end, id)
            end
        end

        local armorButton = rootDescription:CreateButton("Armor")

        armorButton:CreateButton(CLEAR_ALL, function(index)
            resetArmorType()
            updateLoot()

        end)

        for k, v in ipairs(armorTypeInfo) do
	        armorButton:CreateRadio(v.name, function(name) return name == selectedArmor end, function(name)
                selectedArmor = v.name
                updateLoot()

            end, v.name)

        end

    end)

    local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_AJEventReceiver")

    eventReceiver:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
    eventReceiver:SetScript("OnEvent", journalEvents)

    return journal
end