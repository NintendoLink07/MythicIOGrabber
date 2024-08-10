local addonName, miog = ...
local wticc = WrapTextInColorCode

local inventorySlotsInfo = {
    {name = C_Item.GetItemInventorySlotInfo(1), index = 1},
    {name = C_Item.GetItemInventorySlotInfo(2), index = 2},
    {name = C_Item.GetItemInventorySlotInfo(3), index = 3},
    {name = C_Item.GetItemInventorySlotInfo(16), index = 16},
    {name = C_Item.GetItemInventorySlotInfo(5), index = 5},
    {name = C_Item.GetItemInventorySlotInfo(9), index = 9},
    {name = C_Item.GetItemInventorySlotInfo(10), index = 10},
    {name = C_Item.GetItemInventorySlotInfo(6), index = 6},
    {name = C_Item.GetItemInventorySlotInfo(7), index = 7},
    {name = C_Item.GetItemInventorySlotInfo(8), index = 8},
    {name = C_Item.GetItemInventorySlotInfo(11), index = 11},
    {name = C_Item.GetItemInventorySlotInfo(12), index = 12},
    {name = C_Item.GetItemInventorySlotInfo(13), index = 13},
    {name = C_Item.GetItemInventorySlotInfo(14), index = 14},
    {name = C_Item.GetItemInventorySlotInfo(15), index = 15},
    {name = C_Item.GetItemInventorySlotInfo(17), index = 17},
    {name = C_Item.GetItemInventorySlotInfo(18), index = 18},
}

local armorTypeInfo = {
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Cloth)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Leather)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Mail)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Plate)},
}

local currentItemIDs
local selectedArmor, selectedClass, selectedSpec, selectedSlot

local allNames

local function fuzzyCheck(text)
    local result = miog.fzy.filter(text, allNames)

    table.sort(result, function(k1, k2)
        return k1[3] > k2[3]
    end)

    local smallTable = {}

    local dataProvider = CreateDataProvider()

    for k, v in ipairs(result) do
        --print(k, v[1], v[2], v[3])
        table.insert(smallTable, allNames[k])

        dataProvider:Insert({name = allNames[k]})
    end

    miog.DropChecker.AutoCompleteBox:SetDataProvider(dataProvider)

    
end

local function resetLootItemFrames(frame, data)
    if(data.template == "MIOG_AdventureJournalLootItemTemplate") then
        frame.itemLink = nil
        frame.BasicInformation.Name:SetText("")
        frame.BasicInformation.Icon:SetTexture(nil)

        frame:SetScript("OnEnter", nil)

        frame.BasicInformation.Item1:Hide()
        frame.BasicInformation.Item2:Hide()
        frame.BasicInformation.Item3:Hide()
        frame.BasicInformation.Item4:Hide()
    else
        local x1, x2, x3 = frame.Name:GetFont()
        frame.Name:SetFont(x1, 12, x3)

    end
end

local instanceQueue = {}
local forceSeasonID = 13

local function loadLoot()
    local allItems = true
    
    for k, v in pairs(currentItemIDs) do
        if(v.hasData ~= true) then
            allItems = false
            break
        end
    end
    
    if(allItems) then
        local dataProvider = CreateDataProvider()

        allNames = {}

        local searchBoxText = miog.DropChecker.SearchBox:GetText()

        for k, v in ipairs(instanceQueue) do
            EJ_SelectInstance(v.journalInstanceID)
            EJ_SetDifficulty(v.isRaid and 16 or 23)

            local numOfLoot = EJ_GetNumLoot()
            local addedInstanceName = false

            if(numOfLoot > 0) then
                local slotsDone = {}

                for i = 1, numOfLoot, 1 do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

                    if(itemInfo.slot) then
                        table.insert(allNames, itemInfo.name)

                        local noFilter = C_EncounterJournal.GetSlotFilter() == 15

                        local nameCheck, allLootOkay, bothCheck, armorCheck, slotCheck

                        if(searchBoxText ~= "") then
                            nameCheck = string.find(string.lower(itemInfo.name), string.lower(searchBoxText))

                        else
                            allLootOkay = noFilter and selectedArmor == nil
                            bothCheck = not noFilter and selectedArmor ~= nil and itemInfo.filterType == C_EncounterJournal.GetSlotFilter() and StripHyperlinks(itemInfo.armorType) == selectedArmor
                            armorCheck = noFilter and selectedArmor ~= nil and StripHyperlinks(itemInfo.armorType) == selectedArmor
                            slotCheck = selectedArmor == nil and itemInfo.filterType == C_EncounterJournal.GetSlotFilter()

                        end

                        if(nameCheck or allLootOkay or bothCheck or selectedArmor == nil and slotCheck or noFilter and armorCheck) then
                            if(not addedInstanceName) then
                                dataProvider:Insert({
                                    template = "MIOG_AdventureJournalLootSlotLineTemplate",
                                    name = EJ_GetInstanceInfo(),
                                    header = true,
                                })

                                addedInstanceName = true
                            end

                            if(not slotsDone[itemInfo.slot] and noFilter) then
                                dataProvider:Insert({
                                    template = "MIOG_AdventureJournalLootSlotLineTemplate",
                                    name = itemInfo.slot ~= "" and itemInfo.slot or "Other",
                                })

                                slotsDone[itemInfo.slot] = true
                            end

                            dataProvider:Insert({template = "MIOG_AdventureJournalLootItemTemplate", name = itemInfo.name, icon = itemInfo.icon, link = itemInfo.link, encounterID = itemInfo.encounterID})
            
                        end
                    end
                end
            end
        end

        fuzzyCheck(searchBoxText)

        if(dataProvider:GetSize() == 0) then
            dataProvider:Insert({
                template = "MIOG_AdventureJournalLootSlotLineTemplate",
                name = "No loot available for this slot",
            })
        end
        
        miog.DropChecker.ScrollBox:SetDataProvider(dataProvider)
    end
end

local function requestAllLootForMapID(mapID)
    local journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(mapID) or nil

    if(journalInstanceID) then
        EJ_SelectInstance(journalInstanceID)

        for i = 1, EJ_GetNumLoot(), 1 do
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

            if(not itemInfo.name) then
                currentItemIDs[itemInfo.itemID] = {hasData = false, journalInstanceID = journalInstanceID}

            end
        end

        table.insert(instanceQueue, {journalInstanceID = journalInstanceID, isRaid = EJ_InstanceIsRaid()})
    end
end

local function checkAllItemIDs()
    currentItemIDs = {}
    instanceQueue = {}

    for x, y in pairs(miog.SEASONAL_MAP_IDS) do
        if((forceSeasonID or C_MythicPlus:GetCurrentSeason()) == x) then
            for _, mapID in ipairs(y.dungeons) do
                requestAllLootForMapID(mapID)
            end
            
            for _, mapID in ipairs(y.raids) do
                requestAllLootForMapID(mapID)
            end
        end
    end
    
    table.sort(instanceQueue, function(k1, k2)
        if(k1.isRaid == k2.isRaid) then
            return k1.journalInstanceID < k2.journalInstanceID
        end

        return not k1.isRaid
    end)
                
    loadLoot()
end

miog.loadDropChecker = function()
    miog.DropChecker = CreateFrame("Frame", "MythicIOGrabber_DropChecker", miog.Plugin.InsertFrame, "MIOG_DropChecker")
    miog.DropChecker:SetScript("OnShow", function()
        if(miog.DropChecker.ScrollBox:GetDataProvider():GetSize() <= 1) then
            EJ_ResetLootFilter()
            C_EncounterJournal.ResetSlotFilter()
            checkAllItemIDs()
        end
    end)


    miog.DropChecker.SlotDropdown:SetDefaultText("Equipment slots")
    miog.DropChecker.SlotDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton("Clear", function(index)
            selectedSlot = nil
            C_EncounterJournal.ResetSlotFilter()

            checkAllItemIDs()

        end)

        
        local sortedFilters = {}

        for k, v in pairs(Enum.ItemSlotFilterType) do
            sortedFilters[v] = k
        end

        for i = 0, #sortedFilters - 1, 1 do
	        rootDescription:CreateRadio(miog.SLOT_FILTER_TO_NAME[i], function(index) return index == selectedSlot end, function(index)
                selectedSlot = i
                C_EncounterJournal.SetSlotFilter(index)
                checkAllItemIDs()

            end, i)
        end
    end)














    miog.DropChecker.ArmorDropdown:SetDefaultText("Armor types")
    miog.DropChecker.ArmorDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton("Clear", function(index)
            selectedArmor = nil
            selectedClass = nil
            selectedSpec = nil
            
            EJ_ResetLootFilter()

            checkAllItemIDs()

        end)

        local classButton = rootDescription:CreateButton("Classes")

        for k, v in ipairs(miog.CLASSES) do
	        local classMenu = classButton:CreateRadio(GetClassInfo(k), function(index) return index == selectedClass end, function(name)
                selectedClass = k
                EJ_SetLootFilter(k, GetSpecializationInfoForClassID(k, 1))

                checkAllItemIDs()

                if(dropdown:IsMenuOpen()) then
                    dropdown:CloseMenu()
                end
            end, k)

            for x, y in ipairs(v.specs) do
                local id, specName, description, icon, role, classFile, className = GetSpecializationInfoByID(y)

                classMenu:CreateRadio(specName, function(specID) return specID == selectedSpec end, function(name)
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

        for k, v in ipairs(armorTypeInfo) do
	        armorButton:CreateRadio(v.name, function(name) return name == selectedArmor end, function(name)
                selectedArmor = v.name

                checkAllItemIDs()
            end, v.name)
            
        end
    end)

    local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 2);

    local function initializeLootFrames(frame, elementData)
        --local elementData = node:GetData()

        if(elementData.template == "MIOG_AdventureJournalLootItemTemplate") then
            frame.BasicInformation.Name:SetText(elementData.name)
            frame.BasicInformation.Icon:SetTexture(elementData.icon)
            
            frame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(elementData.link)
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                local name = EJ_GetEncounterInfo(elementData.encounterID)
                GameTooltip:AddLine("Dropped by: " .. name)
                GameTooltip:Show()
            end)

        else
            frame.Name:SetText(elementData.name)

            if(elementData.header) then
                local x1, x2, x3 = frame.Name:GetFont()
                frame.Name:SetFont(x1, 16, x3)

            end

        end
    end

    local function CustomFactory(factory, data)
        --local data = node:GetData()
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
    
    ScrollUtil.InitScrollBoxListWithScrollBar(miog.DropChecker.ScrollBox, miog.DropChecker.ScrollBar, view);

    miog.DropChecker.ScrollBox:SetDataProvider(CreateDataProvider())

    miog.DropChecker.SearchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)

        if(key == "ESCAPE" or key == "ENTER") then
            self:Hide()
            self:ClearFocus()
    
        else
            checkAllItemIDs()
            --miog.DropChecker.AutoCompleteBox:Show()

        end
    end)

    local autoCompleteView = CreateScrollBoxListLinearView();
    autoCompleteView:SetElementInitializer("MIOG_DropCheckerAutoCompleteEntryTemplate", function(button, elementData)
        button.Name:SetText(elementData.name)
    end)
    autoCompleteView:SetPadding(1, 1, 1, 1, 2);
    
    ScrollUtil.InitScrollBoxListWithScrollBar(miog.DropChecker.AutoCompleteBox, miog.DropChecker.AutoCompleteBar, autoCompleteView);

    miog.createFrameBorder(miog.DropChecker.AutoCompleteBox, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
    miog.DropChecker.AutoCompleteBox:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
end

local function dcEvents(_, event, ...)
    if(currentItemIDs and currentItemIDs[...]) then
        currentItemIDs[...].hasData = true

        loadLoot()
    end
end

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_AJEventReceiver")

--eventReceiver:RegisterEvent("EJ_DIFFICULTY_UPDATE")
eventReceiver:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
eventReceiver:SetScript("OnEvent", dcEvents)