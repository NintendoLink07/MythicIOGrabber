local addonName, miog = ...

local selectedInstance, selectedEncounter, selectedDifficulty

local journalInfo = {}
local expansionTable = {}

local selectedItemClass, selectedItemSubClass
local selectedArmor, selectedClass, selectedSpec
local selectedTier

local itemsToFilter
local currentItemData

local loadedItems = {}
local loading

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

local function sortByItemLevel(k1, k2)
    if(k1.itemLevel ~= k2.itemLevel) then
        return k1.itemLevel > k2.itemLevel

    end

    return k1.index > k2.index
end

local function sortByEncounterIndex(k1, k2)
    if(k1.encounterIndex and k2.encounterIndex) then
        if(k1.encounterIndex == k2.encounterIndex) then
            if(k1.difficultyID and k2.difficultyID) then
                if(k1.difficultyID ~= k2.difficultyID) then
                    local diffOrder1, diffOrder2 = difficultyOrder[k1.difficultyID], difficultyOrder[k2.difficultyID]

                    return diffOrder1 > diffOrder2
                else
                    return k1.itemID > k2.itemID
                    --return k1.itemLevel > k2.itemLevel

                end
            end
        end

        return k1.encounterIndex < k2.encounterIndex

    end

    return k1.index > k2.index

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

local function getRaidDifficulties()
    return {17, 14, 15, 16}
end

local function selectInstance(journalInstanceID, id)
    selectedInstance = journalInstanceID
    EJ_SelectInstance(journalInstanceID)

    print(id)

end

local function getDifficultiesForJournalInstance(journalInstanceID)
    EJ_SelectInstance(journalInstanceID)

    return getDifficultiesForCurrentJournalInstance()

end

local function requestAllItemsFromActivities(instanceList)
    loadedItems = {}
    local stillLoading = false

    for _, v in ipairs(instanceList) do
        EJ_SelectInstance(v.journalInstanceID)
        local shouldDisplay = shouldDisplayDifficultyForCurrentJournalInstance()

        local difficultyArray = selectedDifficulty and {selectedDifficulty} or getDifficultiesForCurrentJournalInstance()

        local limit = (selectedDifficulty or not shouldDisplay) and 1 or #difficultyArray

        for index = 1, limit, 1 do
            if(shouldDisplay) then
                EJ_SetDifficulty(difficultyArray[index])
            end

            local numOfLoot = EJ_GetNumLoot()

            for i = 1, numOfLoot, 1 do
                local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

                if(not itemInfo.name) then
                    loadedItems[itemInfo.itemID] = loadedItems[itemInfo.itemID] and loadedItems[itemInfo.itemID] + 1 or 1

                    stillLoading = true
                end
            end
        end
    end

    return stillLoading
end

local function requestAllItemsFromCurrentJournalInstance()
    loadedItems = {}
    local stillLoading = false

    local shouldDisplay = shouldDisplayDifficultyForCurrentJournalInstance()

    local difficultyArray = selectedDifficulty and {selectedDifficulty} or getDifficultiesForCurrentJournalInstance()

    local limit = (selectedDifficulty or not shouldDisplay) and 1 or #difficultyArray

    for index = 1, limit, 1 do
        if(shouldDisplay) then
            EJ_SetDifficulty(difficultyArray[index])
        end

        local numOfLoot = EJ_GetNumLoot()

        for i = 1, numOfLoot, 1 do
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

            if(not itemInfo.name) then
                loadedItems[itemInfo.itemID] = loadedItems[itemInfo.itemID] and loadedItems[itemInfo.itemID] + 1 or 1
                stillLoading = true

            end
        end
    end

    return stillLoading
end

local function addGroupsToList(list, groups, blockList, isActive)
    if(groups and #groups > 0) then
        for _, v in ipairs(groups) do
            if(not blockList[v]) then
                local groupInfo = miog.requestGroupInfo(v)
                local activityInfo = miog.requestActivityInfo(groupInfo.highestDifficultyActivityID)
                activityInfo.isActive = isActive
                activityInfo.isRaid = not isActive
                activityInfo.name = activityInfo.extractedName
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
            activityInfo.name = activityInfo.extractedName

            highestIDRaid = highestIDRaid > groupInfo.highestDifficultyActivityID and highestIDRaid or groupInfo.highestDifficultyActivityID
        end
    end

    tinsert(instanceList, miog.requestActivityInfo(highestIDRaid))
end

local function createJournalInstanceListFromActivityGroups()
    local instanceList = {}
    local groupsDone = {}

    local recommendedDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.Recommended)
    local seasonalDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.CurrentSeason)
    local otherDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.PvE)
    local expansionDungeons = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Enum.LFGListFilter.CurrentExpansion)

    local raidGroups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and Enum.LFGListFilter.CurrentExpansion or Enum.LFGListFilter.Recommended)
    local otherRaidGroups = C_LFGList.GetAvailableActivityGroups(3, Enum.LFGListFilter.PvE)
    local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion))

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
            activityInfo.name = activityInfo.extractedName
            tinsert(instanceList, activityInfo)
        end
    end]]

    return instanceList
end

local function loadAllItemsFromActivities(skipCheck)
    local instanceList = createJournalInstanceListFromActivityGroups()

    if(not skipCheck) then
        loading = requestAllItemsFromActivities(instanceList)
    end

    local searchBoxText = miog.Journal.SearchBox:GetText()
    local noFilter = C_EncounterJournal.GetSlotFilter() == 15
    local searching = searchBoxText ~= ""

    local displayDifferentItems = miog.Journal.Checkbox:GetChecked()

    local namesToFilter = {}
    local itemData = {}

    if(not loading) then
        local dataProvider = CreateDataProvider()

        for _, v in ipairs(instanceList) do
            EJ_SelectInstance(v.journalInstanceID)

            local isRaid = EJ_InstanceIsRaid()
            local difficultyArray = selectedDifficulty and {selectedDifficulty} or getDifficultiesForCurrentJournalInstance()
            local shouldDisplay = shouldDisplayDifficultyForCurrentJournalInstance()
            local limit = (selectedDifficulty or not shouldDisplay) and 1 or #difficultyArray

            local offset = 0

            for index = 1, limit, 1 do
                local difficultyID

                if(shouldDisplay) then
                    difficultyID = difficultyArray[index]
                    EJ_SetDifficulty(difficultyID)

                else
                    difficultyID = EJ_GetDifficulty()
                end

                local numOfLoot = EJ_GetNumLoot()

                for i = 1, numOfLoot, 1 do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)
                    local item = Item:CreateFromItemLink(itemInfo.link)

                    if(searching) then
                        itemInfo.difficultyID = difficultyID
                        itemInfo.index = i

                        if(displayDifferentItems) then
                            table.insert(namesToFilter, itemInfo)

                        else
                            local currentItemLevel = item:GetCurrentItemLevel()

                            if(itemData[itemInfo.itemID]) then
                                if(currentItemLevel >= itemData[itemInfo.itemID].itemLevel) then
                                    local data
                                    local oldIndex = itemData[itemInfo.itemID].index
                                    local xValue

                                    for x = 1, #namesToFilter, 1 do
                                        local info = namesToFilter[x]

                                        if(info and info.itemID == itemInfo.itemID) then
                                            data = table.remove(namesToFilter, x)
                                            offset = offset and offset + 1 or 1

                                            break
                                        end
                                    end


                                    table.insert(namesToFilter, itemInfo)
                                    itemData[itemInfo.itemID] = {itemLevel = currentItemLevel, index = #namesToFilter, name = item:GetItemName(), otherIndex = i - #namesToFilter}
                                else

                                end

                            else
                                table.insert(namesToFilter, itemInfo)
                                itemData[itemInfo.itemID] = {itemLevel = currentItemLevel, index = #namesToFilter, name = item:GetItemName()}

                            end

                        end

                    elseif(noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo)) then
                        local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

                        local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]

                        itemInfo.index = i
                        itemInfo.itemLevel = item:GetCurrentItemLevel()
                        itemInfo.difficultyID = difficultyID
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

                        dataProvider:Insert(itemInfo)
                    end

                end

            end
        end

        if(searching) then
            local results = fuzzyCheck(searchBoxText, namesToFilter)

            for k, v in ipairs(results) do
                local itemInfo = namesToFilter[v[1]]

                if(itemInfo) then
                    if(noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo)) then
                        local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

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

                        dataProvider:Insert(itemInfo)
                    end
                end

            end
        end

        dataProvider:SetSortComparator(sortByEncounterIndex)
        miog.Journal.ScrollBox:SetDataProvider(dataProvider)

    end
end

local function requestItemsForDifficulty(difficultyID)
    if(difficultyID) then
        EJ_SetDifficulty(difficultyID)

    end

    local numOfLoot = EJ_GetNumLoot()

    for i = 1, numOfLoot, 1 do
        local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

        if(not itemInfo.name) then
            loadedItems[itemInfo.itemID] = loadedItems[itemInfo.itemID] and loadedItems[itemInfo.itemID] + 1 or 1

        end
    end
end

local function cnt(c, itemID)
    print("COUNT", itemID)
    return #c
end

local function loadItemsForDifficulty(difficultyID, dataProvider)
    EJ_SetDifficulty(difficultyID)

    local numOfLoot = EJ_GetNumLoot()

    local displayDifferentItems = miog.Journal.Checkbox:GetChecked()

    local stillLoading = false

    for i = 1, numOfLoot, 1 do
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

                    --local currentItemLevel = item:GetCurrentItemLevel()
                    
                    if(not currentItemData[itemInfo.itemID]) then
                        currentItemData[itemInfo.itemID] = {difficultyID = difficultyID, name = itemInfo.name, itemInfo = itemInfo, filterIndex = #itemsToFilter}

                    elseif(difficultyOrder[difficultyID] > difficultyOrder[currentItemData[itemInfo.itemID].difficultyID]) then
                        table.remove(itemsToFilter, currentItemData[itemInfo.itemID].filterIndex)
                        currentItemData[itemInfo.itemID] = {difficultyID = difficultyID, name = itemInfo.name, itemInfo = itemInfo, filterIndex = #itemsToFilter}

                    end


                        --[[if(currentItemLevel >= itemData[itemInfo.itemID].itemLevel) then
                            for x = 1, cnt(namesToFilter, itemInfo.itemID), 1 do
                                local info = namesToFilter[x]

                                if(info and info.itemID == itemInfo.itemID) then
                                    table.remove(namesToFilter, x)
                                    offset = offset and offset + 1 or 1

                                    break
                                end
                            end

                            --table.insert(namesToFilter, itemInfo)
                            itemData[itemInfo.itemID] = {itemLevel = currentItemLevel, index = #namesToFilter, name = item:GetItemName()}
                        end]]

                        --if(currentItemLevel >= itemData[itemInfo.itemID].itemLevel) then
                            --itemData[itemInfo.itemID] = {itemLevel = currentItemLevel, name = item:GetItemName(), itemInfo = itemInfo}

                        --end
                    --else
                     --   itemData[itemInfo.itemID] = {itemLevel = currentItemLevel, name = item:GetItemName()}

                    --end

                end
            elseif(noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo)) then
                local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]

                itemInfo.index = i
                --itemInfo.itemLevel = item:GetCurrentItemLevel()
                itemInfo.difficultyID = difficultyID

                if(encounterInfo) then
                    itemInfo.encounterIndex = encounterInfo and encounterInfo.index

                else
                    itemInfo.encounterIndex = 0

                end



                --[[
                
                
                INSERT IS THE PROBLEM, LOOK AT INIT
                
                
                ]]


                dataProvider:Insert(itemInfo)
            end
        end
    end
    
    return stillLoading
end

local function isItemDataStillMissing()
    for _ in pairs(loadedItems) do
        return true

    end

    return false
end

local timesLoaded = {}

local function loadItemsFromInstance(journalInstanceID, dataProvider)
    --timesLoaded[journalInstanceID] = timesLoaded[journalInstanceID] and timesLoaded[journalInstanceID] + 1 or 1

    local startTime = GetTimePreciseSec()
    selectInstance(journalInstanceID, 1)

    local stillLoading = false
    local numOfDiffs = 0

    if(not selectedDifficulty and shouldDisplayDifficultyForCurrentJournalInstance()) then
        for _, difficultyID in ipairs(EJ_DIFFICULTIES) do
            if EJ_IsValidInstanceDifficulty(difficultyID) then
                if(not stillLoading) then
                    stillLoading = loadItemsForDifficulty(difficultyID, dataProvider)

                end

                --print("NUM LOOT", difficultyID, EJ_GetNumLoot())

                numOfDiffs = numOfDiffs + 1
            end
        end
    else
        stillLoading = loadItemsForDifficulty(selectedDifficulty or EJ_InstanceIsRaid() and 14 or 1, dataProvider)

    end

    loading = stillLoading

    local endTime = GetTimePreciseSec()
end

local function loadItemsFromCurrentActivities(dataProvider)
    local instanceList = createJournalInstanceListFromActivityGroups()

    local startTime = GetTimePreciseSec()
    for _, v in ipairs(instanceList) do
        loadItemsFromInstance(v.journalInstanceID, dataProvider)

    end
    local endTime = GetTimePreciseSec()
    print("INSTANCES", endTime - startTime)

    startTime = GetTimePreciseSec()
    if(searching and not loading) then
        local results = fuzzyCheck(searchBoxText, itemsToFilter)

        for k, v in ipairs(results) do
            local itemInfo = currentItemData[itemsToFilter[v[1]].itemID].itemInfo

            if(itemInfo) then
                if(noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo)) then
                    local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

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

                    dataProvider:Insert(itemInfo)
                end
            end

        end
    end
    endTime = GetTimePreciseSec()
    print("FILTER", endTime - startTime)

end

local function loadAllItemsFromInstance(skipCheck)
    if(not skipCheck) then
        loading = requestAllItemsFromCurrentJournalInstance()
    end

    local noFilter = C_EncounterJournal.GetSlotFilter() == 15

    if(not loading) then
        local dataProvider = CreateDataProvider()

        local difficultyArray = selectedDifficulty and {selectedDifficulty} or getDifficultiesForCurrentJournalInstance()
        local shouldDisplay = shouldDisplayDifficultyForCurrentJournalInstance()
        local limit = (selectedDifficulty or not shouldDisplay) and 1 or #difficultyArray

        for index = 1, limit, 1 do
            local difficultyID

            if(shouldDisplay) then
                difficultyID = difficultyArray[index]
                EJ_SetDifficulty(difficultyID)

            else
                difficultyID = EJ_GetDifficulty()
            end

            local numOfLoot = EJ_GetNumLoot()

            for i = 1, numOfLoot, 1 do
                local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

                if(noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo)) then
                    local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

                    local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]

                    local item = Item:CreateFromItemLink(itemInfo.link)

                    itemInfo.index = i
                    itemInfo.itemLevel = item:GetCurrentItemLevel()
                    itemInfo.difficultyID = difficultyID
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

                    dataProvider:Insert(itemInfo)
                end
            end

        end

        dataProvider:SetSortComparator(sortByEncounterIndex)
        miog.Journal.ScrollBox:SetDataProvider(dataProvider)

    end
end

local function loadAllItems(id)
    miog.Journal.ScrollBox:Flush()
    local dataProvider = CreateDataProvider()
    dataProvider:SetSortComparator(sortByEncounterIndex)

    --local numFiltersActive = miog.Journal.SearchBox:GetNumActiveFilters()

    searchBoxText = miog.Journal.SearchBox:GetText()
    noFilter = C_EncounterJournal.GetSlotFilter() == 15
    searching = searchBoxText ~= ""

    loading = false

    itemsToFilter = {}
    currentItemData = {}

    print("LOAD ALL", id, selectedInstance)

    if(selectedInstance) then
        loadItemsFromInstance(selectedInstance, dataProvider)

    else
        loadItemsFromCurrentActivities(dataProvider)
        selectedInstance = nil

    end

    miog.Journal.ScrollBox:SetDataProvider(dataProvider)
end

local function resetInstance()
    print("RESET")

    selectedInstance = nil
    EncounterJournal.instanceID = nil;

    miog.Journal.ScrollBox:Flush()
    miog.Journal.InstanceDropdown:SetText(miog.Journal.InstanceDropdown:GetDefaultText())
    miog.Journal.BossDropdown:SetText(miog.Journal.BossDropdown:GetDefaultText())

    loadAllItems(10)
end

local function resetEncounter()
    selectedEncounter = nil
    EncounterJournal.encounterID = nil;

    miog.Journal.BossDropdown:SetText(miog.Journal.BossDropdown:GetDefaultText())
end

local function resetDifficulty()
    selectedDifficulty = nil

    miog.Journal.DifficultyDropdown:SetText(miog.Journal.DifficultyDropdown:GetDefaultText())
end

local function resetClassAndSpec()
    selectedClass = nil
    selectedSpec = nil
    EJ_ResetLootFilter()

    miog.Journal.ArmorDropdown:SetText(miog.Journal.ArmorDropdown:GetDefaultText())
end

local function resetArmorType()
    selectedArmor = nil

    miog.Journal.ArmorDropdown:SetText(miog.Journal.ArmorDropdown:GetDefaultText())
end


local function resetClassSpecAndArmor()
    resetClassAndSpec()
    resetArmorType()

end

local function selectTier(index, triggerEJ)
    selectedTier = index

    if(triggerEJ) then
        EJ_SelectTier(index)

    end
end

local function setJournalIDs(journalInstanceID, journalEncounterID, difficultyID, tierID, triggerEJ)
    miog.Journal.SearchBox:ClearAllFilters()

    if(tierID) then
        selectTier(tierID, triggerEJ)
    end

    if(journalEncounterID) then
        selectedEncounter = journalEncounterID

    end

    if(difficultyID) then
        selectedDifficulty = difficultyID

    end

    if(journalInstanceID) then
        selectInstance(journalInstanceID, 3)

        if(selectedInstance ~= journalInstanceID) then
            resetEncounter()
            resetDifficulty()

        end

        miog.checkJournalInstanceIDForNewData(selectedInstance)

        EncounterJournal.instanceID = journalInstanceID;
        --EncounterJournal.encounterID = nil;

        miog.Journal.DifficultyDropdown:SetShown(shouldDisplayDifficultyForCurrentJournalInstance())

        if(selectedEncounter) then
            local name = EJ_GetEncounterInfo(selectedEncounter)
            miog.Journal.BossDropdown:OverrideText(name)

            EJ_SelectEncounter(selectedEncounter)
            EncounterJournal.encounterID = selectedEncounter;

        end

        if(selectedDifficulty) then
            EJ_SetDifficulty(selectedDifficulty)

        end
    end

    miog.refreshFilters()

    loadAllItems(2)
end

local function refreshFilters()
    if(selectedInstance) then
        local instanceName = EJ_GetInstanceInfo(selectedInstance)

        miog.Journal.SearchBox:ShowFilter("instance", instanceName, function()
            resetInstance()

        end)

    end

    if(selectedEncounter) then
        local encounterName = EJ_GetEncounterInfo(selectedEncounter)
        miog.Journal.SearchBox:ShowFilter("encounter", encounterName, function()
            resetEncounter()
            setJournalIDs()

        end)
    end

    if(selectedDifficulty) then
        local difficultyName = miog.DIFFICULTY_ID_INFO[selectedDifficulty].name
        miog.Journal.SearchBox:ShowFilter("difficulty", difficultyName, function()
            resetDifficulty()
            setJournalIDs()

        end)

    end

end

miog.refreshFilters = refreshFilters

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

    for x = 1, EJ_GetNumTiers() - 1, 1 do
        selectTier(x, true)
        --EJ_SelectTier(x)
        journalInfo[x] = {}

        for k = 1, 2, 1 do
            local checkForRaid = k == 1 and true or false

            local counter = 1

            local journalInstanceID, name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceByIndex(counter, checkForRaid)
            local mapInfo = miog.getMapInfo(mapID)

            while(journalInstanceID) do
                tinsert(journalInfo[x], {
                    tier = x,
                    journalInstanceID = journalInstanceID,
                    name = name,
                    isRaid = checkForRaid,
                    shortName = mapInfo.shortName,
                    mapID = mapID,
                    index = counter,
                })

                counter = counter + 1

                journalInstanceID, name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceByIndex(counter, checkForRaid)
            end
        end

        table.sort(journalInfo[x], function(k1, k2)
            if(k1.isRaid == k2.isRaid) then
                if(k1.isRaid) then
                    return k1.index < k2.index

                end

                return k1.name < k2.name

            end

            return k1.isRaid and true or k2.isRaid and false
        end)
    end

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

local function createEncounterSubmenu(parent, localInfo)
    local journalInstanceID = localInfo and localInfo.journalInstanceID or selectedInstance

    if(journalInstanceID) then
        local bossTable = {}

        local counter = 1
        local name, _, journalEncounterID, _, _, _, _, mapID = EJ_GetEncounterInfoByIndex(counter, journalInstanceID)

        while name do
            tinsert(bossTable, {encounterID = journalEncounterID, name = name})

            counter = counter + 1

            name, _, journalEncounterID, _, _, _, _, mapID = EJ_GetEncounterInfoByIndex(counter, journalInstanceID)
        end

        local mapInfo = miog.checkJournalInstanceIDForNewData(journalInstanceID)

        local tier = localInfo and localInfo.tier or mapInfo.expansionLevel and mapInfo.expansionLevel + 1

        if(#bossTable == 0) then
            for i = 1, #mapInfo.bosses, 1 do
                local v = mapInfo.bosses[i]

                tinsert(bossTable, {encounterID = v.journalEncounterID, name = v.name})
            end

        end

        for k, v in ipairs(bossTable) do
            local encounterButton = parent:CreateRadio(v.name, function(encounterID) return selectedEncounter == encounterID end, function(encounterID)
                if(tier) then
                    selectTier(tier, true)
                    --EJ_SelectTier(tier)
                end

                setJournalIDs(journalInstanceID, encounterID)

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
end

local function createDifficultySubmenu(parent, callback, journalInstanceID)
    local instanceID = journalInstanceID or selectedInstance
    for index, id in ipairs(instanceID and getDifficultiesForJournalInstance(instanceID) or getRaidDifficulties()) do
        local diffName = miog.DIFFICULTY_ID_INFO[id].name
        local difficultyButton = parent:CreateRadio(diffName, callback, function(difficultyID)
            setJournalIDs(nil, nil, difficultyID)

        end, id)
    end
end

local function createInstanceButton(parent, info)
    if(info.journalInstanceID) then
        local instanceButton = parent:CreateRadio(info.name, function(localInfo) return selectedInstance == localInfo.journalInstanceID end, function(localInfo)
            setJournalIDs(localInfo.journalInstanceID, nil, nil, localInfo.tier or 100, localInfo.tier and true or false)

        end, info)

        instanceButton:AddInitializer(function(button, description, menu)
            local leftTexture = button:AttachTexture();
            leftTexture:SetSize(16, 16);
            leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
            leftTexture:SetTexture(miog.MAP_INFO[info.mapID].icon);

            button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

            return button.fontString:GetUnboundedStringWidth() + 18 + 5
        end)
    end
end

miog.loadJournal = function()
    local journal = miog.pveFrame2.TabFramesPanel.Journal
    journal:SetScript("OnShow", function()
        if(not selectedInstance) then
            local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, mapID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
            local mapInfo = miog.MAP_INFO[mapID]

            if(mapInfo and mapInfo.journalInstanceID) then
                setJournalIDs(mapInfo.journalInstanceID, nil, nil, mapInfo.expansionLevel)

            end
        end
    end)
    journal.SearchBox:OnLoad()
    journal.SearchBox:SetHierarchy({{id = "instance", order = 1}, {id = "difficulty", order = 2}, {id = "encounter", order = 2}})

    loadInstanceInfo()

    local instanceDropdown = journal.InstanceDropdown

    instanceDropdown:SetDefaultText("Select an instance")
    instanceDropdown:SetupMenu(function(dropdown, rootDescription)
		for k, v in ipairs(expansionTable) do
            local expansionButton = rootDescription:CreateRadio(v.text, function(index) return EJ_GetCurrentTier() == index end, nil, k)

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

                createInstanceButton(expansionButton, info)

                lastIsRaid = info.isRaid

            end
		end

        local currentActivitiesButton = rootDescription:CreateRadio("Current activities", function(index) return selectedTier == index end, nil, 100)

        local activitiesList = createCurrentActivitiesTable()

        currentActivitiesButton:CreateTitle("Raids")

        local lastIsRaid = false
        for k, info in ipairs(activitiesList) do
            if(lastIsRaid and lastIsRaid ~= info.isRaid) then
                currentActivitiesButton:CreateTitle("Dungeons")

            end

            createInstanceButton(currentActivitiesButton, info)

            lastIsRaid = info.isRaid

        end
    end)

	local bossDropdown = journal.BossDropdown
    bossDropdown:SetDefaultText("Select an encounter")
    bossDropdown:SetupMenu(function(dropdown, rootDescription)
        createEncounterSubmenu(rootDescription)
    end)


	local difficultyDropdown = journal.DifficultyDropdown
    difficultyDropdown:SetDefaultText("Select a difficulty")
    difficultyDropdown:SetupMenu(function(dropdown, rootDescription)
        createDifficultySubmenu(rootDescription, function(difficultyID) return selectedDifficulty == difficultyID end)

    end)

    local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 2);
    ScrollUtil.InitScrollBoxListWithScrollBar(journal.ScrollBox, journal.ScrollBar, view);

	view:SetElementInitializer("MIOG_JournalFullItemTemplate", function(frame, data)
        frame.Item.Icon:SetTexture(data.icon)
        local formattedText

        --[[if(data.positions) then
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

        if(data.score) then
            if(data.score < math.huge) then
                local percentage = data.score / strlen(data.name) * 100
                frame.Item.Percentage:SetText(miog.round3(percentage, 2) .. "%")

            else
                frame.Item.Percentage:SetText("100%")

            end

        else
            frame.Item.Percentage:SetText("")

        end]]

        frame.Item.Name:SetText(formattedText or data.name)

        if(data.slot) then
            frame.Item.Slot:SetText(data.slot)
        end

        local item = Item:CreateFromItemLink(data.link)
        frame.Item.ItemLevel:SetText(item:GetCurrentItemLevel())
        frame.Item.itemLink = data.link
        frame.Item.encounterID = data.encounterID

        --
        --EXTRA DATA
        --

        local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(data.encounterID)
        local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

        frame.Source.Name:SetText(WrapTextInColorCode("[" .. miog.DIFFICULTY_ID_INFO[data.difficultyID].shortName .. "] ", miog.DIFFICULTY_ID_INFO[data.difficultyID].color:GenerateHexColor()) .. encounterName)

        --SetPortraitTextureFromCreatureDisplayID(frame.Source.Icon, sectionInfo.creatureDisplayID)

        frame.Source:SetScript("OnMouseDown", function(self, button)
            setJournalIDs(nil, data.encounterID)

        end)
    end)

    journal.SearchBox:SetScript("OnTextChanged", function(self, key)
        SearchBoxTemplate_OnTextChanged(self)

        loadAllItems(8)
    end)

    journal.SlotDropdown:SetDefaultText("Equipment slots")
    journal.SlotDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function(index)
            selectedItemClass = nil
            selectedItemSubClass = nil
            C_EncounterJournal.ResetSlotFilter()

            loadAllItems(9)

        end)


        local sortedFilters = {}

        for k, v in pairs(Enum.ItemSlotFilterType) do
            sortedFilters[v] = k
        end

        for i = 0, #sortedFilters - 1, 1 do
	        rootDescription:CreateRadio(miog.SLOT_FILTER_TO_NAME[i], function(index) return index == C_EncounterJournal.GetSlotFilter() end, function(index)
                selectedItemClass = nil
                selectedItemSubClass = nil

                C_EncounterJournal.SetSlotFilter(index)
                loadAllItems(10)

            end, i)
        end

        rootDescription:CreateRadio("Mounts", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass

            C_EncounterJournal.SetSlotFilter(14)
            loadAllItems(11)

        end, {class = 15, subclass = 5})

        rootDescription:CreateRadio("Recipes", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass

            C_EncounterJournal.SetSlotFilter(14)
            loadAllItems(12)

        end, {class = 9, subclass = nil})

        rootDescription:CreateRadio("Tokens", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass

            C_EncounterJournal.SetSlotFilter(14)
            loadAllItems(13)

        end, {class = 15, subclass = 0})
    end)

    journal.ArmorDropdown:SetDefaultText("Armor types")
    journal.ArmorDropdown:SetupMenu(function(dropdown, rootDescription)
        local ejClass, ejSpec = EJ_GetLootFilter()

        rootDescription:CreateButton(CLEAR_ALL, function(index)
            resetClassSpecAndArmor()

            loadAllItems(14)
        end)

        local classButton = rootDescription:CreateButton("Classes")

        classButton:CreateButton(CLEAR_ALL, function(index)
            resetClassAndSpec()
            loadAllItems(15)

        end)

        for k, v in ipairs(miog.CLASSES) do
	        local classMenu = classButton:CreateRadio(GetClassInfo(k), function(index) return index == ejClass end, function(name)
                selectedClass = k
                selectedSpec = nil
                EJ_SetLootFilter(selectedClass, selectedSpec)
                loadAllItems(16)

                if(dropdown:IsMenuOpen()) then
                    dropdown:CloseMenu()
                end
            end, k)

            for x, y in ipairs(v.specs) do
                local id, specName, description, icon, role, classFile, className = GetSpecializationInfoByID(y)

                classMenu:CreateRadio(specName, function(specID) return specID == ejSpec end, function(name)
                    selectedClass = k
                    selectedSpec = id
                    EJ_SetLootFilter(k, id)
                    loadAllItems(17)

                    if(dropdown:IsMenuOpen()) then
                        dropdown:CloseMenu()
                    end
                end, id)
            end
        end

        local armorButton = rootDescription:CreateButton("Armor")

        armorButton:CreateButton(CLEAR_ALL, function(index)
            resetArmorType()
            loadAllItems(18)

        end)

        for k, v in ipairs(armorTypeInfo) do
	        armorButton:CreateRadio(v.name, function(name) return name == selectedArmor end, function(name)
                selectedArmor = v.name
                loadAllItems(19)

            end, v.name)

        end

    end)

    return journal
end

local function journalEvents(_, event, ...)
    if(event == "EJ_LOOT_DATA_RECIEVED" and loading) then
        if(...) then
            if(loadedItems[...]) then
                loadedItems[...] = loadedItems[...] - 1

                if(loadedItems[...] == 0) then
                    loadedItems[...] = nil
                end

                for _ in pairs(loadedItems) do
                    return

                end

                loading = false

                loadAllItems(20)
            end
        end
    end
end

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_AJEventReceiver")

eventReceiver:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
eventReceiver:SetScript("OnEvent", journalEvents)