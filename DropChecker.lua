local addonName, miog = ...
local wticc = WrapTextInColorCode

local armorTypeInfo = {
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Cloth)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Leather)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Mail)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Plate)},
}

local currentItemIDs
local selectedArmor, selectedClass, selectedSpec, selectedSlot

local itemData = {}

local function fuzzyCheck(text)
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
        table.insert(returnResults, {index = v[1], positions = v[2]})

    end

    return returnResults
end

local function resetLootItemFrames(frame, data)
    if(data.template == "MIOG_AdventureJournalLootItemSingleTemplate") then
        frame.itemLink = nil
        frame.BasicInformation.Name:SetText("")
        frame.BasicInformation.Icon:SetTexture(nil)
        frame:SetScript("OnEnter", nil)

    else
        local x1, x2, x3 = frame.Name:GetFont()
        frame.Name:SetFont(x1, 12, x3)

    end
end

local instanceQueue = {}
local forceSeasonID = 13
local selectedItemClass, selectedItemSubClass

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

local function iterateInstanceQueue()

end

local function loadLoot()
    local allItems = true
    
    for k, v in pairs(currentItemIDs) do
        if(v.hasData ~= true) then
            allItems = false
            break
        end
    end
        
    local dataProvider = CreateDataProvider()
    
    if(allItems) then
        local searchBoxText = miog.DropChecker.SearchBox:GetText()

        local noFilter = C_EncounterJournal.GetSlotFilter() == 15

        local searching = searchBoxText ~= ""

        itemData = {}

        for _, v in ipairs(instanceQueue) do
            --EJ_SetDifficulty(v.isRaid and 16 or 23)

            EncounterJournal.instanceID = instanceID;
            EncounterJournal.encounterID = nil;

            EJ_SelectInstance(v.journalInstanceID)

	        local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo();

            local numOfLoot = EJ_GetNumLoot()

            local addedInstance = false
            local slotsDone = {}

            if(numOfLoot > 0) then
                for i = 1, numOfLoot, 1 do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

                    if(itemInfo.slot) then
                        if(searching) then
                            table.insert(itemData, itemInfo)
    
                        else
                            if(noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo, noFilter)) then
                                if(not addedInstance) then
                                    --local instanceName, _, _, _, _, _, _, _, _, mapID = EJ_GetInstanceInfo()

                                    dataProvider:Insert({
                                        template = "MIOG_AdventureJournalLootSlotLineTemplate",
                                        name = instanceName,
                                        icon = miog.MAP_INFO[mapID].icon,
                                        header = true,
                                    })
                        
                                    addedInstance = true
                                end

                                if(not slotsDone[itemInfo.filterType] and noFilter) then
                                    dataProvider:Insert({
                                        template = "MIOG_AdventureJournalLootSlotLineTemplate",
                                        name = itemInfo.slot ~= "" and itemInfo.slot or "Other",
                                    })
                        
                                    slotsDone[itemInfo.filterType] = true
                                end
                                
                                dataProvider:Insert({template = "MIOG_AdventureJournalLootItemSingleTemplate", name = itemInfo.name, icon = itemInfo.icon, link = itemInfo.link, encounterID = itemInfo.encounterID})

                            end
                        end
                    end
                end
            end
        end
        
        if(searching) then
            local results = fuzzyCheck(searchBoxText)
            
            for k, v in ipairs(results) do
                local item = itemData[v.index]
                dataProvider:Insert({template = "MIOG_AdventureJournalLootItemSingleTemplate", name = item.name, icon = item.icon, link = item.link, encounterID = item.encounterID, positions = v.positions})

            end
        end
    end

    if(dataProvider:GetSize() == 0) then
        dataProvider:Insert({
            template = "MIOG_AdventureJournalLootSlotLineTemplate",
            name = "No loot available for this slot",
        })
    end
    
    miog.DropChecker.ScrollBox:SetDataProvider(dataProvider)
end

local function getMaxDifficultyForMapID(mapID)
    local instanceType = miog.MAP_INFO[mapID].instanceType

    if(instanceType == 2) then
        
    end
end

local function requestAllLootForMapID(mapID)
    local mapInfo = miog.MAP_INFO[mapID]
    local settings = MIOG_NewSettings.newFilterOptions["DropChecker"] and MIOG_NewSettings.newFilterOptions["DropChecker"][0]

    if(settings and settings.activities.value and settings.activities[mapInfo.groupFinderActivityGroupID] and settings.activities[mapInfo.groupFinderActivityGroupID].value == false) then
        return

    end

    local journalInstanceID = mapInfo.journalInstanceID or C_EncounterJournal.GetInstanceForGameMap(mapID) or EJ_GetInstanceForMap(mapID) or nil

    if(journalInstanceID and journalInstanceID > 0) then
        EJ_SetDifficulty(mapInfo.isRaid and 16 or 23)
        EJ_SelectInstance(journalInstanceID)

        for i = 1, EJ_GetNumLoot(), 1 do
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

            if(not itemInfo.name) then
                currentItemIDs[itemInfo.itemID] = {hasData = false, journalInstanceID = journalInstanceID}

            end
        end

        table.insert(instanceQueue, {journalInstanceID = journalInstanceID, isRaid = EJ_InstanceIsRaid(), shortName = mapInfo.shortName})
    end
end

local function checkAllItemIDs()
    currentItemIDs = {}
    instanceQueue = {}

    local dungeonGroup = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.CurrentExpansion))
    local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE))
    local seasonGroups = C_LFGList.GetAvailableActivityGroups(3, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion))
    local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion))

    local listWithMapIDs = {}
    local seasonalDungeonsDone = {}
    
    if(dungeonGroup and #dungeonGroup > 0) then
        for _, v in ipairs(dungeonGroup) do
            local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
            listWithMapIDs[#listWithMapIDs + 1] = activityInfo.mapID
            seasonalDungeonsDone[v] = true
        end
    end

    if(expansionGroups and #expansionGroups > 0) then
        for _, v in ipairs(expansionGroups) do
            if(not seasonalDungeonsDone[v]) then
                local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
                listWithMapIDs[#listWithMapIDs + 1] = activityInfo.mapID
                
            end
        end
    end

    if(seasonGroups and #seasonGroups > 0) then
        for _, v in ipairs(seasonGroups) do
            local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
            listWithMapIDs[#listWithMapIDs + 1] = activityInfo.mapID

        end
    end

    if(worldBossActivity and #worldBossActivity > 0) then
        for _, v in ipairs(worldBossActivity) do
            --local activityInfo = C_LFGList.GetActivityInfoTable(worldBossActivity[1])
            --listWithMapIDs[#listWithMapIDs + 1] = 2774
            local activityInfo = miog.ACTIVITY_INFO[v]

            listWithMapIDs[#listWithMapIDs + 1] = activityInfo.mapID
        end
    end

    --[[for x, y in pairs(miog.SEASONAL_MAP_IDS) do
        if((forceSeasonID or C_MythicPlus:GetCurrentSeason()) == x) then
            for _, mapID in ipairs((miog.DROPCHECKER_MAP_IDS[x] or y).dungeons) do
                requestAllLootForMapID(mapID)
            end
            
            for _, mapID in ipairs((miog.DROPCHECKER_MAP_IDS[x] or y).raids) do
                requestAllLootForMapID(mapID)
            end
        end
    end]]

    for k, mapID in ipairs(listWithMapIDs) do
        requestAllLootForMapID(mapID)

    end
    
    table.sort(instanceQueue, function(k1, k2)
        if(k1.isRaid == k2.isRaid) then
            return k1.shortName < k2.shortName
        end

        return not k1.isRaid
    end)
                
    loadLoot()
end

miog.checkAllDropCheckerItemIDs = checkAllItemIDs

miog.loadDropChecker = function()
    local dropChecker = CreateFrame("Frame", "MythicIOGrabber_DropChecker", miog.Plugin.InsertFrame, "MIOG_DropChecker")
    dropChecker:SetScript("OnShow", function()
        if(dropChecker.ScrollBox:GetDataProvider():GetSize() <= 1) then
            EJ_ResetLootFilter()
            C_EncounterJournal.ResetSlotFilter()
            checkAllItemIDs()
        end
    end)


    dropChecker.SlotDropdown:SetDefaultText("Equipment slots")
    dropChecker.SlotDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function(index)
            selectedItemClass = nil
            selectedItemSubClass = nil
            C_EncounterJournal.ResetSlotFilter()

            checkAllItemIDs()

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
                checkAllItemIDs()

            end, i)
        end

        rootDescription:CreateRadio("Mounts", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            
            C_EncounterJournal.SetSlotFilter(14)
            checkAllItemIDs()

        end, {class = 15, subclass = 5})

        rootDescription:CreateRadio("Recipes", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            
            C_EncounterJournal.SetSlotFilter(14)
            checkAllItemIDs()

        end, {class = 9, subclass = nil})

        rootDescription:CreateRadio("Tokens", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass

            C_EncounterJournal.SetSlotFilter(14)
            checkAllItemIDs()

        end, {class = 15, subclass = 0})
    end)

    dropChecker.ArmorDropdown:SetDefaultText("Armor types")
    dropChecker.ArmorDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function(index)
            selectedArmor = nil
            selectedClass = nil
            selectedSpec = nil
            
            EJ_ResetLootFilter()

            checkAllItemIDs()

        end)

        local classButton = rootDescription:CreateButton("Classes")

        classButton:CreateButton(CLEAR_ALL, function(index)
            selectedClass = nil
            selectedSpec = nil
            EJ_ResetLootFilter()

            checkAllItemIDs()

        end)

        for k, v in ipairs(miog.CLASSES) do
	        local classMenu = classButton:CreateRadio(GetClassInfo(k), function(index) return index == selectedClass end, function(name)
                selectedClass = k
                selectedSpec = nil
                EJ_SetLootFilter(selectedClass, selectedSpec)

                checkAllItemIDs()

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
                    checkAllItemIDs()

                    if(dropdown:IsMenuOpen()) then
                        dropdown:CloseMenu()
                    end
                end, id)
            end
        end

        local armorButton = rootDescription:CreateButton("Armor")

        armorButton:CreateButton(CLEAR_ALL, function(index)
            selectedArmor = nil

            checkAllItemIDs()

        end)

        for k, v in ipairs(armorTypeInfo) do
	        armorButton:CreateRadio(v.name, function(name) return name == selectedArmor end, function(name)
                selectedArmor = v.name

                checkAllItemIDs()
            end, v.name)
            
        end

    end)

    local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 2);

    local function initializeLootFrames(frame, elementData)
        if(elementData.template == "MIOG_AdventureJournalLootItemSingleTemplate") then
            local formattedText

            if(elementData.positions) then
                formattedText = ""
    
                local positionArray = {}
    
                for k, v in ipairs(elementData.positions) do
                    positionArray[v] = true
                end
    
                for i = 1, strlen(elementData.name), 1 do
                    if(positionArray[i]) then
                        formattedText = formattedText .. WrapTextInColorCode(strsub(elementData.name, i, i), miog.CLRSCC.green)
    
                    else
                        formattedText = formattedText .. strsub(elementData.name, i, i)
    
                    end
    
                end
            end

            frame.BasicInformation.Name:SetText(formattedText or elementData.name)
            frame.BasicInformation.Icon:SetTexture(elementData.icon)
            frame.itemLink = elementData.link
            
            frame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(elementData.link)
                GameTooltip_AddBlankLineToTooltip(GameTooltip)

                local encounterName, _, _, _, _, journalInstanceID = EJ_GetEncounterInfo(elementData.encounterID)
                local instanceName = EJ_GetInstanceInfo(journalInstanceID)

                GameTooltip:AddLine("[" .. instanceName .. "]: " .. encounterName)
                GameTooltip:Show()
            end)

        else
            frame.Name:SetText(elementData.name)
            frame.Icon:SetTexture(elementData.icon)
            frame.Icon:SetShown(elementData.icon ~= nil)

            if(elementData.header) then
                local x1, x2, x3 = frame.Name:GetFont()
                frame.Name:SetFont(x1, 16, x3)

            end

        end
    end

    local function CustomFactory(factory, data)
        local template = data.template
        factory(template, initializeLootFrames)
    end

    view:SetElementFactory(CustomFactory)
    view:SetElementResetter(resetLootItemFrames)
    view:SetElementExtentCalculator(function(index, elementData)
		if(elementData.header and index ~= 1) then
            return 35

        else
            return 20

        end
	end);
    
    view:SetPadding(1, 1, 1, 1, 4);
    
    ScrollUtil.InitScrollBoxListWithScrollBar(dropChecker.ScrollBox, dropChecker.ScrollBar, view);

    dropChecker.ScrollBox:SetDataProvider(CreateDataProvider())

    dropChecker.SearchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)

        if(key == "ESCAPE" or key == "ENTER") then
            self:Hide()
            self:ClearFocus()
    
        else
            checkAllItemIDs()

        end
    end)

    return dropChecker
end

local function dcEvents(_, event, ...)
    if(currentItemIDs and currentItemIDs[...]) then
        currentItemIDs[...].hasData = true

        loadLoot()
    end
end

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_AJEventReceiver")

eventReceiver:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
eventReceiver:SetScript("OnEvent", dcEvents)