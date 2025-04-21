local addonName, miog = ...

local selectedInstance, selectedEncounter, selectedDifficulty

local journalInfo = {}
local expansionTable = {}

local selectedItemClass, selectedItemSubClass
local selectedArmor, selectedClass, selectedSpec

local loadedItems = {}
local loading = false

local extraItemInfo = {}

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

local function sortByEncounterIndex(k1, k2)
    if(k1.encounterIndex and k2.encounterIndex) then
        if(k1.encounterIndex == k2.encounterIndex) then
            if(k1.difficultyID and k2.difficultyID) then
                if(k1.difficultyID ~= k2.difficultyID) then
                    local diffOrder1, diffOrder2 = difficultyOrder[k1.difficultyID], difficultyOrder[k2.difficultyID]

                    return diffOrder1 > diffOrder2
                else
                    return k1.itemLevel > k2.itemLevel

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

local function getDifficultiesForJournalInstance(journalInstanceID)
    EJ_SelectInstance(journalInstanceID)

    return getDifficultiesForCurrentJournalInstance()

end

local function testLoad()
    local itemIndex, encounterIndex = 1, 1

    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex, encounterIndex)

    while(itemInfo) do
        while(itemInfo) do            
            itemIndex = itemIndex + 1
            itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex, encounterIndex)

        end
        
        encounterIndex = encounterIndex + 1
        itemIndex = 1
        itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex, encounterIndex)

    end
end

local function initScrollBoxFrame(frame, data)
    frame.difficultyID = data.difficultyID or frame.difficultyID
    frame.itemIndex = data.index or frame.itemIndex

    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(frame.itemIndex)

    if(not data) then
        print(itemInfo.name)

    end

    local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

    local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]
    local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

    itemInfo.difficultyID = frame.difficultyID
    itemInfo.sourceName = encounterName
    itemInfo.sourceIconType = "portrait"
    itemInfo.encounterIndex = encounterInfo and encounterInfo.encounterIndex or 0
    itemInfo.creatureDisplayInfoID = encounterInfo and encounterInfo.creatureDisplayInfoID or sectionInfo.creatureDisplayID

    updateScrollBoxItem(frame, itemInfo)
end

local function updateScrollBoxItemID(itemID)
    local scrollBox = miog.Journal.ScrollBox

    local frame = scrollBox:FindFrameByPredicate(function(localFrame, localData)
        return localData.itemID == itemID;
    end)

    if(frame) then
        initScrollBoxFrame(frame)

    end
end

local function UpdateDifficultyVisibility()
	local shouldDisplayDifficulty = select(9, EJ_GetInstanceInfo());

	-- As long as the current tab isn't the model tab, which always suppresses the difficulty, then update the shown state.
	local info = EncounterJournal.encounter.info;
	info.difficulty:SetShown(shouldDisplayDifficulty and (info.tab ~= 4));
end

local function requestAllItems()
    local shouldDisplay = shouldDisplayDifficultyForCurrentJournalInstance()

    local difficultyArray = selectedDifficulty and {selectedDifficulty} or getDifficultiesForCurrentJournalInstance()

    local stillLoading = false

    local limit = (selectedDifficulty or not shouldDisplay) and 1 or #difficultyArray

    for index = 1, limit, 1 do
        if(shouldDisplay) then
            EJ_SetDifficulty(difficultyArray[index])
        end

        local numOfLoot = EJ_GetNumLoot()

        for i = 1, numOfLoot, 1 do
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

            if(not itemInfo.name) then
                loadedItems[itemInfo.itemID] = false

                stillLoading = true
            end
        end
    end

    --[[for _, difficultyID in ipairs(difficultyArray) do
        if(shouldDisplay) then
            EJ_SetDifficulty(difficultyID)

        end

        local numOfLoot = EJ_GetNumLoot()

        for i = 1, numOfLoot, 1 do
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

            if(not itemInfo.name) then
                loadedItems[itemInfo.itemID] = false

                stillLoading = true
            end
        end
    end]]

    return stillLoading
end

local function loadAllItemsFromInstance(skipCheck)
    EJ_ResetLootFilter()
    C_EncounterJournal.ResetSlotFilter()

    if(not skipCheck) then
        loading = requestAllItems()
    end

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
    
                local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

                local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]
                local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

                local item = Item:CreateFromItemLink(itemInfo.link)

                itemInfo.index = i
                itemInfo.itemLevel = item:GetCurrentItemLevel()
                itemInfo.difficultyID = difficultyID
                itemInfo.sourceName = encounterName
                itemInfo.sourceIconType = "portrait"
                itemInfo.encounterIndex = encounterInfo and encounterInfo.index or 0
                itemInfo.creatureDisplayInfoID = encounterInfo and encounterInfo.creatureDisplayInfoID or sectionInfo.creatureDisplayID
                dataProvider:Insert(itemInfo)
                
            end
    
        end
    
        dataProvider:SetSortComparator(sortByEncounterIndex)
        miog.Journal.ScrollBox:SetDataProvider(dataProvider)

    end
end

local function resetInstance()
    selectedInstance = nil

    miog.Journal.ScrollBox:Flush()
    miog.Journal.InstanceDropdown:SetText(miog.Journal.InstanceDropdown:GetDefaultText())
    miog.Journal.BossDropdown:SetText(miog.Journal.BossDropdown:GetDefaultText())
end

local function resetEncounter()
    selectedEncounter = nil

    miog.Journal.BossDropdown:SetText(miog.Journal.BossDropdown:GetDefaultText())
end

local function resetDifficulty()
    selectedDifficulty = nil

    miog.Journal.DifficultyDropdown:SetText(miog.Journal.DifficultyDropdown:GetDefaultText())
end

local function refreshLoot()
    if(selectedInstance) then
        miog.checkJournalInstanceIDForNewData(selectedInstance)

        EJ_SelectInstance(selectedInstance)

        miog.Journal.DifficultyDropdown:SetShown(shouldDisplayDifficultyForCurrentJournalInstance())

        if(selectedEncounter) then
            local name = EJ_GetEncounterInfo(selectedEncounter)
            miog.Journal.BossDropdown:SetText(name)

            EJ_SelectEncounter(selectedEncounter)
            
        end

        if(selectedDifficulty) then
            EJ_SetDifficulty(selectedDifficulty)
            
        end

    else
        miog.Journal.ScrollBox:Flush()

    end

    loadAllItemsFromInstance()

    miog.refreshFilters()
end

local function setLootRetrieval(journalInstanceID, journalEncounterID, difficultyID)
    miog.Journal.SearchBox:ClearAllFilters()

    if(journalInstanceID) then
        if(selectedInstance ~= journalInstanceID) then
            resetEncounter()
            resetDifficulty()

        end
        
        selectedInstance = journalInstanceID
    end

    if(journalEncounterID) then
        selectedEncounter = journalEncounterID

    end

    if(difficultyID) then
        selectedDifficulty = difficultyID
        
    end

    refreshLoot()
end

local function updateScrollBoxItem(frame, data)
    frame.Item.Icon:SetTexture(data.icon)
    
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

    if(data.score) then
        if(data.score < math.huge) then
            local percentage = data.score / strlen(data.name) * 100
            frame.Item.Percentage:SetText(miog.round3(percentage, 2) .. "%")
            
        else
            frame.Item.Percentage:SetText("100%")

        end

    end

    frame.Item.Name:SetText(formattedText or data.name)

    if(data.link) then
        frame.Item.ItemLevel:SetText(data.itemLevel)
        frame.Item.itemLink = data.link
    end

    frame.Item.encounterID = data.encounterID

    --
    --EXTRA DATA
    --

    frame.Source.Name:SetText(WrapTextInColorCode("[" .. miog.DIFFICULTY_ID_INFO[data.difficultyID].shortName .. "] ", miog.DIFFICULTY_ID_INFO[data.difficultyID].color:GenerateHexColor()) .. data.sourceName)

    if(data.sourceIconType == "portrait") then
        SetPortraitTextureFromCreatureDisplayID(frame.Source.Icon, data.creatureDisplayInfoID)

        frame.Source:SetScript("OnMouseDown", function(self, button)
            setLootRetrieval(nil, data.encounterID)

        end)

    else
        frame.Source.Icon:SetTexture(data.sourceIcon)
        frame.Source:SetScript("OnMouseDown", function(self, button)

        end)

    end
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

local function refreshFilters()
    if(selectedInstance) then
        local instanceName = EJ_GetInstanceInfo(selectedInstance)
        miog.Journal.SearchBox:ShowFilter("instance", instanceName, function() resetInstance() end)

    end

    if(selectedEncounter) then
        local encounterName = EJ_GetEncounterInfo(selectedEncounter)
        miog.Journal.SearchBox:ShowFilter("encounter", encounterName, function()
            resetEncounter()
            setLootRetrieval()

        end)
    end

    if(selectedDifficulty) then
        local difficultyName = miog.DIFFICULTY_ID_INFO[selectedDifficulty].name
        miog.Journal.SearchBox:ShowFilter("difficulty", difficultyName, function() 
            resetDifficulty()
            setLootRetrieval()
            
        end)

    end

end

miog.refreshFilters = refreshFilters

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
        EJ_SelectTier(x)
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


local function fuzzyCheck(text, itemData)
    local filterArray = {}

    for k, v in ipairs(itemData) do
        table.insert(filterArray, v.name)

    end

    local result = miog.fzy.filter(text, filterArray)

    table.sort(result, function(k1, k2)
        return k1[3] > k2[3]
    end)

    local returnResults = {}

    for k, v in ipairs(result) do
        table.insert(returnResults, {index = v[1], positions = v[2], score = v[3]})

    end

    return returnResults
end

local function replaceItemLinkWithAdjustedVersion(link, isRaid, isActive)
    local newItemLink

    if(not isRaid and isActive) then
        newItemLink = miog.removeAndSetItemLinkItemLevels(link, "mythicPlus")

    else
        newItemLink = link

    end

    return newItemLink

end

local function addGroupsToList(list, groups, blockList, isActive)
    if(groups and #groups > 0) then
        for _, v in ipairs(groups) do
            if(not blockList[v]) then
                local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
                activityInfo.isActive = isActive
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
    addGroupsToList(instanceList, recommendedDungeons, groupsDone, false)
    addGroupsToList(instanceList, otherDungeons, groupsDone, false)
    addGroupsToList(instanceList, expansionDungeons, groupsDone, false)

    addGroupsToList(instanceList, raidGroups, groupsDone, false)
    addGroupsToList(instanceList, otherRaidGroups, groupsDone, false)

    if(worldBossActivity and #worldBossActivity > 0) then
        for _, v in ipairs(worldBossActivity) do
            local activityInfo = miog.ACTIVITY_INFO[v]
            activityInfo.isActive = false
            tinsert(instanceList, activityInfo)
        end
    end

    return instanceList
end

local function checkAllItemsForSearch()
    local dataProvider = CreateDataProvider()
    
    local searchBoxText = miog.Journal.SearchBox:GetText()

    local noFilter = C_EncounterJournal.GetSlotFilter() == 15

    local searching = searchBoxText ~= ""

    EJ_ResetLootFilter()
    C_EncounterJournal.ResetSlotFilter()

    --local instanceList = createJournalInstanceListFromActivityGroups()
    local instanceList = createJournalInstanceListFromJournalInfo()
    local itemData = {}

    for _, v in ipairs(instanceList) do
        EJ_SelectInstance(v.journalInstanceID)

        local name = EJ_GetInstanceInfo(v.journalInstanceID)

        local difficultyArray = getDifficultiesForCurrentJournalInstance()

        local isRaid = EJ_InstanceIsRaid()

        for _, difficultyID in ipairs(difficultyArray) do
            EJ_SetDifficulty(difficultyID)

            local itemIndex, encounterIndex = 1, 1

            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex)

            while(itemInfo) do
                while(itemInfo) do
                    if(itemInfo.slot) then
                        if(searching) then
                            local item = Item:CreateFromItemLink(itemInfo.link)

                            item:ContinueOnItemLoad(function()
                                local tempData = itemInfo
                                tempData.difficultyID = difficultyID
                                tempData.isRaid = isRaid
                                tempData.isActive = v.isActive
                                table.insert(itemData, tempData)
                            
                            end)
                        elseif(noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo, noFilter)) then
                            local newItemLink = replaceItemLinkWithAdjustedVersion(itemInfo.link, isRaid, v.isActive)

                            local item = Item:CreateFromItemLink(newItemLink)
                            local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

                            local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]
                            local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

                            dataProvider:Insert({
                                itemIcon = itemInfo.icon,
                                itemName = itemInfo.name,
                                itemLink = newItemLink,
                                itemLevel = item:GetCurrentItemLevel(),
                                rarity = itemInfo.displayAsVeryRare and 1 or itemInfo.displayAsExtremelyRare and 2 or 0,
            
                                difficultyID = difficultyID,
            
                                encounterIndex = encounterInfo and encounterInfo.index or 0,
                                encounterID = itemInfo.encounterID,
            
                                sourceName = encounterName,
                                sourceIconType = "portrait",
                                creatureDisplayInfoID = encounterInfo and encounterInfo.creatureDisplayInfoID or sectionInfo.creatureDisplayID
                            })

                        end
                    end

                    itemIndex = itemIndex + 1
                    itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex)

                end
                
                encounterIndex = encounterIndex + 1
                itemIndex = 1
                itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex)
                
            end
        end
    end

    if(searching) then
        local results = fuzzyCheck(searchBoxText, itemData)
        
        for k, v in ipairs(results) do
            local savedItem = itemData[v.index]

            local newItemLink = replaceItemLinkWithAdjustedVersion(savedItem.link, savedItem.isRaid, savedItem.isActive)

            local item = Item:CreateFromItemLink(newItemLink)
            
            local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(savedItem.encounterID)

            local encounterInfo = miog.ENCOUNTER_INFO[savedItem.encounterID]
            local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

            dataProvider:Insert({
                itemIcon = savedItem.icon,
                itemName = savedItem.name,
                itemLink = newItemLink,
                itemLevel = item:GetCurrentItemLevel(),
                rarity = savedItem.displayAsVeryRare and 1 or savedItem.displayAsExtremelyRare and 2 or 0,

                difficultyID = savedItem.difficultyID,

                encounterIndex = encounterInfo and encounterInfo.index or 0,
                encounterID = savedItem.encounterID,

                sourceName = encounterName,
                sourceIconType = "portrait",
                creatureDisplayInfoID = encounterInfo and encounterInfo.creatureDisplayInfoID or sectionInfo.creatureDisplayID,
                positions = v.positions,
                score = v.score
            })

        end
    end

    dataProvider:SetSortComparator(sortByEncounterIndex)
    miog.Journal.ScrollBox:SetDataProvider(dataProvider)
end

local function checkAllItemIDs()
    EJ_ResetLootFilter()
    C_EncounterJournal.ResetSlotFilter()

    --local instanceList = createJournalInstanceListFromActivityGroups()
    local instanceList = createJournalInstanceListFromJournalInfo()
    
    table.sort(instanceList, function(k1, k2)
        if(k1.isRaid == k2.isRaid) then
            return k1.shortName < k2.shortName
        end

        return not k1.isRaid
    end)
        
    local dataProvider = CreateDataProvider()
    
    local searchBoxText = miog.Journal.SearchBox:GetText()

    local noFilter = C_EncounterJournal.GetSlotFilter() == 15

    local searching = searchBoxText ~= ""

    local itemData = {}

    for _, v in ipairs(instanceList) do
        EJ_SelectTier(v.tier)
        EJ_SelectInstance(v.journalInstanceID)

        local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(v.journalInstanceID);

        local numOfLoot = EJ_GetNumLoot()

        local itemIndex, encounterIndex = 1, 1

        local itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex, encounterIndex)

        while(itemInfo) do
            while(itemInfo) do
                if(itemInfo.slot) then
                    if(searching) then
                        itemInfo.difficulty = difficulty
                        itemInfo.isRaid = isRaid
                        itemInfo.isActive = v.isActive
                        table.insert(itemData, itemInfo)

                    elseif(noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo, noFilter)) then
                        local newItemLink = replaceItemLinkWithAdjustedVersion(itemInfo.link, isRaid, v.isActive)

                        local item = Item:CreateFromItemLink(newItemLink)
                        local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(itemInfo.encounterID)

                        local encounterInfo = miog.ENCOUNTER_INFO[itemInfo.encounterID]
                        local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

                        dataProvider:Insert({
                            itemIcon = itemInfo.icon,
                            itemName = itemInfo.name,
                            itemLink = newItemLink,
                            itemLevel = item:GetCurrentItemLevel(),
                            rarity = itemInfo.displayAsVeryRare and 1 or itemInfo.displayAsExtremelyRare and 2 or 0,
        
                            difficultyID = difficulty,
        
                            encounterIndex = encounterInfo and encounterInfo.index or 0,
                            encounterID = itemInfo.encounterID,
        
                            sourceName = encounterName,
                            sourceIconType = "portrait",
                            creatureDisplayInfoID = encounterInfo and encounterInfo.creatureDisplayInfoID or sectionInfo.creatureDisplayID
                        })

                    end
                end

                itemIndex = itemIndex + 1
                itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex, encounterIndex)

            end
            
            encounterIndex = encounterIndex + 1
            itemIndex = 1
            itemInfo = C_EncounterJournal.GetLootInfoByIndex(itemIndex, encounterIndex)

        end

       
    end
    
    if(searching) then
        local results = fuzzyCheck(searchBoxText, itemData)
        
        for k, v in ipairs(results) do
            local savedItem = itemData[v.index]

            local newItemLink = replaceItemLinkWithAdjustedVersion(savedItem.link, savedItem.isRaid, savedItem.isActive)

            local item = Item:CreateFromItemLink(newItemLink)
            
            --local item = Item:CreateFromItemLink(itemInfo.link)
            local encounterName, _, journalEncounterID, rootSectionID, _, _, dungeonEncounterID = EJ_GetEncounterInfo(savedItem.encounterID)

            local encounterInfo = miog.ENCOUNTER_INFO[savedItem.encounterID]
            local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID);

            dataProvider:Insert({
                itemIcon = savedItem.icon,
                itemName = savedItem.name,
                itemLink = newItemLink,
                itemLevel = item:GetCurrentItemLevel(),
                rarity = savedItem.displayAsVeryRare and 1 or savedItem.displayAsExtremelyRare and 2 or 0,

                difficultyID = savedItem.difficulty,

                encounterIndex = encounterInfo and encounterInfo.index or 0,
                encounterID = savedItem.encounterID,

                sourceName = encounterName,
                sourceIconType = "portrait",
                creatureDisplayInfoID = encounterInfo and encounterInfo.creatureDisplayInfoID or sectionInfo.creatureDisplayID,
                positions = v.positions,
                score = v.score
            })
            --dataProvider:Insert({template = "MIOG_AdventureJournalLootItemSingleTemplate", name = item.name, icon = item.icon, link = item.link, encounterID = item.encounterID, positions = v.positions})

        end
    end

    --[[if(dataProvider:GetSize() == 0) then
        dataProvider:Insert({
            template = "MIOG_AdventureJournalLootSlotLineTemplate",
            name = "No loot available for this slot",
        })
    end]]
    
    dataProvider:SetSortComparator(sortByEncounterIndex)
    miog.Journal.ScrollBox:SetDataProvider(dataProvider)
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
                    EJ_SelectTier(tier)
                end
                
                setLootRetrieval(journalInstanceID, encounterID)
                
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
    for index, id in ipairs(getDifficultiesForJournalInstance(journalInstanceID or selectedInstance)) do
        local diffName = miog.DIFFICULTY_ID_INFO[id].name
        local difficultyButton = parent:CreateRadio(diffName, callback, function(difficultyID)
            setLootRetrieval(nil, nil, difficultyID)

        end, id)
    end
end

miog.loadJournal = function()
    local journal = miog.pveFrame2.TabFramesPanel.Journal
    journal:SetScript("OnShow", function()
        if(not selectedInstance) then
            local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, mapID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
            local mapInfo = miog.MAP_INFO[mapID]

            if(mapInfo and mapInfo.journalInstanceID) then
                setLootRetrieval(mapInfo.journalInstanceID)

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

                if(info.journalInstanceID) then
                    local instanceButton = expansionButton:CreateRadio(info.name, function(localInfo) return selectedInstance == localInfo.journalInstanceID end, function(localInfo)
                        EJ_SelectTier(localInfo.tier)
                        setLootRetrieval(localInfo.journalInstanceID)

                    end, info)

                    instanceButton:AddInitializer(function(button, description, menu)
                        local leftTexture = button:AttachTexture();
                        leftTexture:SetSize(16, 16);
                        leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
                        leftTexture:SetTexture(miog.MAP_INFO[info.mapID].icon);

                        button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

                        return button.fontString:GetUnboundedStringWidth() + 18 + 5
                    end)

                    --createEncounterSubmenu(instanceButton, info)
                end

                lastIsRaid = info.isRaid

            end
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
        if(selectedInstance) then
            createDifficultySubmenu(rootDescription, function(difficultyID) return selectedDifficulty == difficultyID end)

        end
    end)

    local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 2);
    ScrollUtil.InitScrollBoxListWithScrollBar(journal.ScrollBox, journal.ScrollBar, view);
	
	view:SetElementInitializer("MIOG_JournalFullItemTemplate", function(frame, data)
        --initScrollBoxFrame(frame, data)
        updateScrollBoxItem(frame, data)
    
    end)

    journal.SearchBox:SetScript("OnTextChanged", function(self, key)
        SearchBoxTemplate_OnTextChanged(self)

        --checkAllItemsForSearch()
        --checkAllItemIDs()

    end)

    --[[journal.SettingsBar.ArmorDropdown:SetDefaultText("Armor types")
    journal.SettingsBar.ArmorDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function(index)
            selectedArmor = nil
            selectedClass = nil
            selectedSpec = nil
            
            EJ_ResetLootFilter()
            requestAllItemsFromCurrentEncounter()

        end)

        local classButton = rootDescription:CreateButton("Classes")

        classButton:CreateButton(CLEAR_ALL, function(index)
            selectedClass = nil
            selectedSpec = nil
            EJ_ResetLootFilter()
            requestAllItemsFromCurrentEncounter()

        end)

        for k, v in ipairs(miog.CLASSES) do
	        local classMenu = classButton:CreateRadio(GetClassInfo(k), function(index) return index == selectedClass end, function(name)
                selectedClass = k
                selectedSpec = nil
                EJ_SetLootFilter(selectedClass, selectedSpec)
                requestAllItemsFromCurrentEncounter()

                if(dropdown:IsMenuOpen()) then
                    dropdown:CloseMenu()
                end
            end, k)

            for x, y in ipairs(v.specs) do
                local id, specName, description, icon, role, classFile, className = GetSpecializationInfoByID(y)

                classMenu:CreateRadio(specName, function(specID) return specID == selectedSpec end, function(name)
                    selectedClass = k
                    selectedSpec = id
                    EJ_SetLootFilter(k, id)
                    requestAllItemsFromCurrentEncounter()

                    if(dropdown:IsMenuOpen()) then
                        dropdown:CloseMenu()
                    end
                end, id)
            end
        end

        local armorButton = rootDescription:CreateButton("Armor")

        armorButton:CreateButton(CLEAR_ALL, function(index)
            selectedArmor = nil
            requestAllItemsFromCurrentEncounter()

        end)

        for k, v in ipairs(armorTypeInfo) do
	        armorButton:CreateRadio(v.name, function(name) return name == selectedArmor end, function(name)
                selectedArmor = v.name
                requestAllItemsFromCurrentEncounter()
            end, v.name)
            
        end

    end)

    journal.SettingsBar.SlotDropdown:SetDefaultText("Equipment slots")
    journal.SettingsBar.SlotDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function(index)
            selectedItemClass = nil
            selectedItemSubClass = nil
            C_EncounterJournal.ResetSlotFilter()
            requestAllItemsFromCurrentEncounter()

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
                requestAllItemsFromCurrentEncounter()

            end, i)
        end

        rootDescription:CreateRadio("Mounts", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            
            C_EncounterJournal.SetSlotFilter(14)
            requestAllItemsFromCurrentEncounter()

        end, {class = 15, subclass = 5})

        rootDescription:CreateRadio("Recipes", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            
            C_EncounterJournal.SetSlotFilter(14)
            requestAllItemsFromCurrentEncounter()

        end, {class = 9, subclass = nil})

        rootDescription:CreateRadio("Tokens", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass

            C_EncounterJournal.SetSlotFilter(14)
            requestAllItemsFromCurrentEncounter()

        end, {class = 15, subclass = 0})
    end)]]

    return journal
end

local function journalEvents(_, event, ...)
    if(event == "EJ_LOOT_DATA_RECIEVED" and loading) then
        if(...) then
            loadedItems[...] = true

            for k, v in pairs(loadedItems) do
                if(not v) then
                    return

                end

            end

            loading = false

            loadAllItemsFromInstance(true)
            
        end
    end
end

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_AJEventReceiver")

eventReceiver:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
eventReceiver:SetScript("OnEvent", journalEvents)