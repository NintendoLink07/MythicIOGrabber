local addonName, miog = ...

LootMixin = {}

local currentlySearching

local instanceDB
local bossDropdownList = {}

local allRaidsJournalInstanceIDList, allDungeonsJournalInstanceIDList = {}, {}
local defaultList = {}

local lootQueue = {}
local multiQueue = false
local showOnlyItems = false

local dataProvider
local numBossesShown = 0

local selectedTier, selectedJournalInstance, selectedDifficulty
local selectedItemClass, selectedItemSubClass, selectedArmorType
local specialSelection

local selectedEncounter

local armorTypeInfo = {
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Cloth)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Leather)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Mail)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Plate)},
}

function LootMixin:GetSelectedEncounter()
    return selectedEncounter
end

function LootMixin:SetSelectedEncounter(encounterID)
    if(encounterID) then
        EJ_SelectEncounter(encounterID)
        selectedEncounter = encounterID

    else
        selectedEncounter = nil
        self:RequestLoot(1)

    end
end

function SortInstanceEntries(key1, key2)
    return key1.isRaid and not key2.isRaid or key1.data.journalInstanceID > key2.data.journalInstanceID

end

function SortBossEntries(key1, key2)
    return key1.data.index > key2.data.index

end

function SortItemEntries(key1, key2)
    if(key1.data.itemlevel == key2.data.itemlevel) then
        return key1.data.filterType < key2.data.filterType
        
    else
        return key1.data.itemlevel > key2.data.itemlevel

    end
end

function SortItemEntriesWithSearch(key1, key2)
    return key1.data.filterMatches[1][3] > key2.data.filterMatches[1][3]

end

function LootMixin:RefreshDifficulties()
    self.DifficultyDropdown:SetupMenu(function(dropdown, rootDescription)
        if(selectedJournalInstance or specialSelection) then
            rootDescription:CreateButton(CLEAR_ALL, function()
                selectedDifficulty = nil

            end)

            rootDescription:CreateSpacer()

            for i, difficultyID in ipairs(miog.EJ_DIFFICULTIES) do
                if EJ_IsValidInstanceDifficulty(difficultyID) then
                    local difficultyButton = rootDescription:CreateRadio(miog.DIFFICULTY_ID_INFO[difficultyID].name, function(id) return id == EJ_GetDifficulty() end, function(id)
                        EJ_SetDifficulty(id)
                        selectedDifficulty = difficultyID

                        self:UpdateAfterCompletion()

                    end, difficultyID)
                end
            end
        end
    end)
end

function LootMixin:CheckItemFiltering(itemInfo)
    local hasSpecialItemClass = selectedItemClass or selectedItemSubClass

    if(hasSpecialItemClass) then
        local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(itemInfo.link)

        if(not (classID == selectedItemClass and (not selectedItemSubClass or selectedItemSubClass == subclassID))) then
            return false

        end
    end

    if(selectedArmorType and not selectedArmorType == itemInfo.armorType) then
        return false

    end

    if(currentlySearching) then
        local filterMatches = miog.fzy.filter(searchText, {itemInfo.name})

        if(#filterMatches > 0) then
            itemInfo.filterMatches = filterMatches

        else
            return false

        end
    end

    return true
end

function LootMixin:RefreshEncounters(journalInstanceID)
    local bossData = miog:GetJournalInstanceBossData(journalInstanceID)

    local hasData = #bossDropdownList > 0

    if(hasData) then
        tinsert(bossDropdownList, {type = "spacer"})

    end

    tinsert(bossDropdownList, {type = "title"})

    if(bossData) then
        for k, v in ipairs(bossData) do
            tinsert(bossDropdownList, v)

        end
    end
end

function LootMixin:ShowOnlyItemsFromCurrentJournalInstance(numLoot, encounterData)
    local isMissingData = false
    local hasNoInstanceSelected = not selectedJournalInstance
    local needsInstanceAbbreviation = hasNoEncounterSelected and multiQueue or hasNoInstanceSelected

    for i = 1, numLoot do
        local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

        if not isMissingData and itemInfo and itemInfo.name then
            local encounterID = itemInfo.encounterID
            
            local hasNoEncounterSelected = not selectedEncounter
            local isSelectedEncounter = hasNoEncounterSelected or selectedEncounter == encounterID
            
            if isSelectedEncounter and self:CheckItemFiltering(itemInfo) then
                itemInfo.template = "MIOG_LootItemTemplate"
                itemInfo.typeWithSource = showOnlyItems
                itemInfo.bossName = encounterData[encounterID] and (encounterData[encounterID].name or encounterData[encounterID].altName)

                if(needsInstanceAbbreviation) then
                    itemInfo.abbreviatedName = encounterData[encounterID].abbreviatedInstanceName

                end
                    
                itemInfo.itemlevel = C_Item.GetDetailedItemLevelInfo(itemInfo.link)

                dataProvider:Insert(itemInfo)
            end
        else
            isMissingData = true

        end
    end

    return isMissingData
end

function LootMixin:ShowEverythingFromCurrentJournalInstance(numLoot, encounterData, journalInstanceID)
    local noEncounterSelected = not selectedEncounter

    local instanceNodes, bossNodes = {}, {}
    instanceNode, bossNode = nil, nil

    local parentNode

    if(not multiQueue) then
        parentNode = dataProvider
        parentNode:SetSortComparator(SortBossEntries)
        
    end

    local isMissingData = false

    for i = 1, numLoot do
        local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

        if not isMissingData and itemInfo and itemInfo.name then
            if(self:CheckItemFiltering(itemInfo)) then
                local encounterID = itemInfo.encounterID

                if(noEncounterSelected or selectedEncounter == encounterID) then
                    itemInfo.itemlevel = C_Item.GetDetailedItemLevelInfo(itemInfo.link)
                    itemInfo.template = "MIOG_LootItemTemplate"

                    if(multiQueue) then
                        if(not instanceNodes[journalInstanceID]) then
                            local journalInfo = miog:GetJournalInstanceInfo(journalInstanceID)
                            journalInfo.template = "MIOG_LootInstanceTemplate"

                            dataProvider:SetSortComparator(SortInstanceEntries)

                            instanceNode = dataProvider:Insert(journalInfo)
                            instanceNode:SetSortComparator(SortBossEntries)
                            instanceNodes[journalInstanceID] = instanceNode

                            parentNode = instanceNode

                        else
                            parentNode = instanceNodes[journalInstanceID]

                        end
                    end

                    if(not bossNodes[encounterID]) then
                        local bossInfo = encounterData and encounterData[encounterID] or miog:GetEncounterData(encounterID)

                        bossInfo.template = "MIOG_LootBossTemplate"

                        bossNode = parentNode:Insert(bossInfo)
                        bossNode:SetSortComparator(SortItemEntries)

                        bossNodes[encounterID] = bossNode
                        
                        numBossesShown = numBossesShown + 1
                    end

                    bossNodes[encounterID]:Insert(itemInfo)
                end
            end
        else
            isMissingData = true

        end
    end

    return isMissingData
end

function LootMixin:GetHighestDifficulty(isRaid)
    if(isRaid) then
        return 16

    else
        return 8

    end

end

function LootMixin:SelectJournalInstance(journalInstanceID)
    local id = journalInstanceID or selectedJournalInstance
    local showEverything = not showOnlyItems
    
    if(id) then
        EJ_SelectInstance(id)

        if(not selectedDifficulty) then
            local highestID = miog:GetHighestDifficultyForInstance()

            if(EJ_GetDifficulty() ~= highestID) then
                EJ_SetDifficulty(highestID)

            end
        end

        local isMissingData = false
        local numLoot = EJ_GetNumLoot()

        if(numLoot > 0) then
            self:RefreshEncounters(id)
            local encounterData = miog:GetEncounterDataFromJournalInstance(id)

            if(showEverything) then
                isMissingData = self:ShowEverythingFromCurrentJournalInstance(numLoot, encounterData, id)
                
            else
                isMissingData = self:ShowOnlyItemsFromCurrentJournalInstance(numLoot, encounterData)

            end
        end

        return isMissingData
    end
end

function LootMixin:RequestLoot(origin)
    dataProvider:Flush()
    dataProvider:SetAllCollapsed(true);

    bossDropdownList = {}
    numBossesShown = 0

    multiQueue = #lootQueue > 1
    showOnlyItems = self.OnlyItemsButton:GetChecked()

    local isMissingData = false
    searchText = self.SearchBox:GetText()
    currentlySearching = searchText ~= ""

    if(showOnlyItems) then
        if(currentlySearching) then
            dataProvider:SetSortComparator(SortItemEntriesWithSearch)

        else
            dataProvider:SetSortComparator(SortItemEntries)

        end
    end

    if(#lootQueue > 0) then
        for k, v in ipairs(lootQueue) do
            local isDataMissingFromInstance = self:SelectJournalInstance(v)

            if(isDataMissingFromInstance) then
                isMissingData = true

            end
        end

        if(not isMissingData) then
            local hasMultipleInstances = dataProvider.node:GetSize(true) > 1
            local hasMultipleBosses = numBossesShown > 1

            if(multiQueue) then
                if(hasMultipleInstances) then
                    dataProvider.node:SetCollapsed(hasMultipleInstances, hasMultipleBosses, true)
                    
                end

            else
                dataProvider:SetAllCollapsed(hasMultipleBosses)
                self:RefreshDifficulties()

            end

            dataProvider:Invalidate()
            
            self.ScrollBox:SetDataProvider(dataProvider)

        end
    end
end

function LootMixin:ResetInstance()
    lootQueue = defaultList

    selectedJournalInstance = nil
    selectedTier = nil
    specialSelection = nil
    
    self:RequestLoot(2)
end

function LootMixin:LoadAllInstanceFromTypeAndTier(type, tier)
    lootQueue = (type == RAIDS and allRaidsJournalInstanceIDList or allDungeonsJournalInstanceIDList)[tier]

    selectedJournalInstance = nil
    selectedTier = tier
    specialSelection = type

    self.SearchBox:CreateFilter("instance", EJ_GetTierInfo(tier) .. " - " .. type, function() self:ResetInstance() self.InstanceDropdown:SignalUpdate() end)

    self:RequestLoot(3)

end

local function setSpecialButtonTooltip(tooltip, elementDescription, name)
    local elementText = MenuUtil.GetElementText(elementDescription)

    GameTooltip_SetTitle(tooltip, name .. " - " .. elementText);
    GameTooltip_AddErrorLine(tooltip, "This will load " .. elementText .. " from \"" .. name .. "\".");
    GameTooltip_AddErrorLine(tooltip, "Loading might take some time.");
end

function LootMixin:SetupInstanceMenu()
    self.InstanceDropdown:SetupMenu(function(dropdown, rootDescription)
        if(instanceDB) then
            local expansionButtons = {}

            for k, v in ipairs(miog.TIER_INFO) do
                local expansionButton = rootDescription:CreateRadio(v.name, function(index) return index == selectedTier end, nil, k)

                expansionButton:AddInitializer(function(button, description, menu)
                    local leftTexture = button:AttachTexture();
                    leftTexture:SetSize(16, 16);
                    leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
                    leftTexture:SetTexture(v.icon);

                    button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

                    return button.fontString:GetUnboundedStringWidth() + 18 + 5
                end)

                expansionButtons[k] = expansionButton

                local raidButton = expansionButtons[k]:CreateRadio(ALL .. " " .. RAIDS, function(index) return index == selectedTier and specialSelection == RAIDS end, function(index)
                    self:LoadAllInstanceFromTypeAndTier(RAIDS, index)
                    
                end, k)

                raidButton:SetTooltip(function(tooltip, elementDescription)
                    setSpecialButtonTooltip(tooltip, elementDescription, v.name)

                end);

                allRaidsJournalInstanceIDList[k] = {}

                local dungeonButton = expansionButtons[k]:CreateRadio(ALL .. " " .. DUNGEONS, function(index) return index == selectedTier and specialSelection == DUNGEONS end, function(index)
                    self:LoadAllInstanceFromTypeAndTier(DUNGEONS, index)

                end, k)

                dungeonButton:SetTooltip(function(tooltip, elementDescription)
                    setSpecialButtonTooltip(tooltip, elementDescription, v.name)
                    
                end);

                allDungeonsJournalInstanceIDList[k] = {}
            end

            local finalInstanceList = {}

            for i = 1, 4000, 1 do
                local instanceInfo = instanceDB[i]

                if(instanceInfo and instanceInfo.tier) then
                    tinsert(finalInstanceList, instanceInfo)

                end
            end

            table.sort(finalInstanceList, function(k1, k2)
                if(k1.isRaid == k2.isRaid) then
                    if(k1.isRaid) then
                        return k1.journalInstanceID < k2.journalInstanceID

                    else
                        return k1.instanceName < k2.instanceName

                    end
                end

                return k1.isRaid and true or k2.isRaid and false
            end)

            local raidTitles, dungeonTitles = {}, {}

            local first = false

            for k, v in ipairs(finalInstanceList) do
                if(v and v.tier) then
                    local hasNoRaidTitle = v.isRaid and not raidTitles[v.tier]
                    local hasNoDungeonTitle = not v.isRaid and not dungeonTitles[v.tier]

                    if(hasNoRaidTitle) then
                        raidTitles[v.tier] = expansionButtons[v.tier]:CreateTitle(RAIDS)

                    elseif(hasNoDungeonTitle) then
                        dungeonTitles[v.tier] = expansionButtons[v.tier]:CreateTitle(DUNGEONS)
                        
                    end
                    
                    if(v.isRaid) then
                        tinsert(allRaidsJournalInstanceIDList[v.tier], v.journalInstanceID)
                        
                    else
                        tinsert(allDungeonsJournalInstanceIDList[v.tier], v.journalInstanceID)

                    end
                    
                    local instanceButton = expansionButtons[v.tier]:CreateRadio(v.instanceName, function(journalInstanceID) return selectedJournalInstance == journalInstanceID end, function(journalInstanceID)
                        lootQueue = {journalInstanceID}

                        selectedJournalInstance = journalInstanceID
                        selectedTier = v.tier
                        specialSelection = nil

                        self.SearchBox:CreateFilter("instance", v.instanceName, function() self:ResetInstance() self.InstanceDropdown:SignalUpdate() end)

                        self:RequestLoot(4)

                    end, v.journalInstanceID)

                    instanceButton:AddInitializer(function(button, description, menu)
                        local leftTexture = button:AttachTexture();
                        leftTexture:SetSize(16, 16);
                        leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
                        leftTexture:SetTexture(v.icon);

                        if(not first and not v.icon) then
                            first = true
                            
                        end

                        button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

                        return button.fontString:GetUnboundedStringWidth() + 18 + 5
                    end)
                end
            end

            defaultList = miog:table_merge({}, allDungeonsJournalInstanceIDList[#allDungeonsJournalInstanceIDList], allRaidsJournalInstanceIDList[#allRaidsJournalInstanceIDList])

            if(#lootQueue == 0) then
                self:ResetInstance()

            end
        end
    end)
end

local lastInfo = 0

function LootMixin:CalculateWaitTime()
    local numOfInstances = #lootQueue

    return 0.25 + numOfInstances * 0.12

end

function LootMixin:UpdateAfterCompletion()
    lastInfo = GetTimePreciseSec()

    if(not updateTimer or updateTimer:IsCancelled()) then
        local waitTime = self:CalculateWaitTime()
        local finishedAt = GetTimePreciseSec() + waitTime
        self.ProgressBar:SetMinMaxSmoothedValue(0, waitTime)

        updateTimer = C_Timer.NewTicker(0.25, function()
            current = finishedAt - GetTimePreciseSec()
            self.ProgressBar:SetSmoothedValue(waitTime - current)

            if(GetTimePreciseSec() - lastInfo > waitTime) then
                updateTimer:Cancel()
                self.ProgressBar:ResetSmoothedValue(0)

                self:RequestLoot(5)

            end
        end)
    end
end

function LootMixin:OnEvent(event, ...)
    if(event == "EJ_LOOT_DATA_RECIEVED") then
        self:UpdateAfterCompletion()

    end
end

function LootMixin:RefreshClassesAndArmor()
    self.ClassArmorDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function()
            selectedArmorType = nil
            EJ_ResetLootFilter()

        end)

        rootDescription:CreateSpacer()

        local ownClassName, fileName, ownClassID = UnitClass("PLAYER")
        local classColor = C_ClassColor.GetClassColor(fileName)
        rootDescription:CreateTitle(WrapTextInColorCode(ownClassName, classColor and classColor:GenerateHexColor() or "FFFFFFFF"))

        local specCount = C_SpecializationInfo.GetNumSpecializationsForClassID(ownClassID)

        for specIndex = 1, specCount, 1 do
            local specId, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(specIndex)

	        rootDescription:CreateRadio(name, function(getID) return getID == select(2, EJ_GetLootFilter()) end, function(getID)
                EJ_SetLootFilter(ownClassID, getID)
                
            end, specId)
        end

        rootDescription:CreateSpacer()

        local classButton = rootDescription:CreateButton(ALL_CLASSES)

        classButton:CreateButton(CLEAR_ALL, function()
            EJ_ResetLootFilter()

        end)
            
        classButton:CreateSpacer()

        for k, v in ipairs(miog.OFFICIAL_CLASSES) do
	        local classMenu = classButton:CreateRadio(GetClassInfo(k), function(id) return id == EJ_GetLootFilter() end, function(id)
                EJ_SetLootFilter(id, 0)

                
            end, k)

            for x, y in ipairs(v.specs) do
                local id, specName, description, icon, role, classFile, className = GetSpecializationInfoByID(y)

                classMenu:CreateRadio(specName, function(getID) return getID == select(2, EJ_GetLootFilter()) end, function(getID)
                    EJ_SetLootFilter(k, getID)
                    
                end, id)
            end
        end

        local armorButton = rootDescription:CreateButton(ARMOR)

        armorButton:CreateButton(CLEAR_ALL, function(index)
            selectedArmorType = nil
            self:RequestLoot(6)

        end)
            
        armorButton:CreateSpacer()

        for k, v in ipairs(armorTypeInfo) do
	        armorButton:CreateRadio(v.name, function(name) return name == selectedArmorType end, function(name)
                selectedArmorType = v.name
                self:RequestLoot(7)

            end, v.name)

        end
    end)
end

function LootMixin:RefreshSlots()
    self.SlotDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function()
            selectedItemClass = nil
            selectedItemSubClass = nil
            C_EncounterJournal.ResetSlotFilter()

            self:RequestLoot(8)

        end)
            
        rootDescription:CreateSpacer()

        local sortedFilters = {}

        for k, v in pairs(Enum.ItemSlotFilterType) do
            sortedFilters[v] = k
        end

        for i = 0, #sortedFilters - 1, 1 do
            local mainSlots = rootDescription:CreateRadio(miog.SLOT_FILTER_TO_NAME[i], function(data) return data.slot == C_EncounterJournal.GetSlotFilter() end, function(data)
                selectedItemClass = data.class
                selectedItemSubClass = data.subclass
                C_EncounterJournal.SetSlotFilter(data.slot)

                dropdown:CloseMenu()

                self:RequestLoot(9)
            end, {slot = i, class = nil, subclass = nil})

            if(i == 10) then
                for k, v in pairs(Enum.ItemWeaponSubclass) do
                    mainSlots:CreateRadio(C_Item.GetItemSubClassInfo(2, v), function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
                        selectedItemClass = data.class
                        selectedItemSubClass = data.subclass
                        C_EncounterJournal.SetSlotFilter(data.slot)

                        self:RequestLoot(10)

                    end, {slot = i, class = 2, subclass = v})
                end

            elseif(i == 14) then
                mainSlots:CreateRadio(MOUNTS, function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
                    selectedItemClass = data.class
                    selectedItemSubClass = data.subclass
                    C_EncounterJournal.SetSlotFilter(data.slot)

                    self:RequestLoot(11)

                end, {slot = 14, class = 15, subclass = 5})

                local recipeButton = mainSlots:CreateRadio(PROFESSIONS_RECIPES_TAB, function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
                    selectedItemClass = data.class
                    selectedItemSubClass = data.subclass
                    C_EncounterJournal.SetSlotFilter(data.slot)
                    
                    dropdown:CloseMenu()

                    self:RequestLoot(12)

                end, {slot = 14, class = 9, subclass = nil})

                for k, v in pairs(Enum.ItemRecipeSubclass) do
                    recipeButton:CreateRadio(C_Item.GetItemSubClassInfo(9, v), function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
                        selectedItemClass = data.class
                        selectedItemSubClass = data.subclass
                        C_EncounterJournal.SetSlotFilter(data.slot)

                        self:RequestLoot(13)

                    end, {slot = 14, class = 9, subclass = v})

                end

                mainSlots:CreateRadio(TOKENS, function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
                    selectedItemClass = data.class
                    selectedItemSubClass = data.subclass
                    C_EncounterJournal.SetSlotFilter(data.slot)

                    self:RequestLoot(14)

                end, {slot = 14, class = 15, subclass = 0})
            end
        end

       
    end)
end

function LootMixin:ResetEncounter()
    self:SetSelectedEncounter()

end

function LootMixin:SetupEncounterMenu()
    self.BossDropdown:SetupMenu(function(dropdown, rootDescription)
        if(bossDropdownList and #bossDropdownList > 0) then
            rootDescription:CreateButton(CLEAR_ALL, function()
                self:ResetEncounter()

            end)
            
            rootDescription:CreateSpacer()

            local nextTitle = false

            for k, v in ipairs(bossDropdownList) do
                if(v.type == "title") then
                    nextTitle = true
                    
                elseif(v.type == "spacer") then
                    rootDescription:CreateSpacer()

                else
                    if(nextTitle) then
                        local name = EJ_GetInstanceInfo(v.journalInstanceID)
                        rootDescription:CreateTitle(name)
                        
                        nextTitle = false
                    end

                    local name = v.name or v.altName

                    local encounterButton = rootDescription:CreateRadio(name, function(data) return data.journalEncounterID == self:GetSelectedEncounter() end, function(data)
                        self:SetSelectedEncounter(data.journalEncounterID)
                        self.SearchBox:CreateFilter("encounter", name, function() self:ResetEncounter() self.BossDropdown:SignalUpdate() end)

                        self:RequestLoot(15)


                    end, v)
                end
            end
        end
    end)
end

function LootMixin:OnShow()
    instanceDB = miog:GetJournalDB()

    self:SetupInstanceMenu()
end

function LootMixin:OnLoad()
	self.InstanceDropdown:SetDefaultText("---Instances---")
	self.BossDropdown:SetDefaultText("---Bosses---")
	self.ClassArmorDropdown:SetDefaultText("---Class---")
	self.SlotDropdown:SetDefaultText("---Slot---")
	self.DifficultyDropdown:SetDefaultText("---Difficulty---")
    self.ProgressBar:SetMinMaxSmoothedValue(0, 1)
    self.ProgressBar:ResetSmoothedValue(0)

    dataProvider = CreateTreeDataProvider()
    self:RefreshSlots()
    self:RefreshClassesAndArmor()
    self:SetupEncounterMenu()
    self:SetupInstanceMenu()

	self.SearchBox.Instructions:SetText("Enter atleast 3 characters to search");
    self.SearchBox:SetScript("OnTextChanged", function(selfFrame, manual)
        SearchBoxTemplate_OnTextChanged(selfFrame)

        local length = strlen(selfFrame:GetText())

        if(length > 2 or length == 0) then
            self:RequestLoot(16)

        end
    end)

    local view = CreateScrollBoxListTreeListView(12, 0, 0, 0, 0, 6)
    self.view = view

	local function Initializer(frame, node)
		local data = node:GetData()

		frame:SetData(data)
	end
	
	local function CustomFactory(factory, node)
		local data = node:GetData()

		local template = data.template

		factory(template, Initializer)
	end

	view:SetElementFactory(CustomFactory)
	self.ScrollBox:Init(view)

    self:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
    self:RegisterEvent("EJ_DIFFICULTY_UPDATE")
    self:SetScript("OnEvent", function(selfFrame, event, ...)
        selfFrame:OnEvent(event, ...)

    end)

    self.SearchBox:SetCallback(function()
    end)

    self.OnlyItemsButton:SetScript("PostClick", function(selfFrame)
        selfFrame:GetParent():RequestLoot(18)
    
    end)

	ScrollUtil.RegisterScrollBoxWithScrollBar(self.ScrollBox, self:GetParent():GetParent().ScrollBarArea.LootScrollBar)

    hooksecurefunc("EJ_SetLootFilter", function(classID, specID)
        self.DifficultyDropdown:SignalUpdate()
        self:RequestLoot(19)
    end)

    hooksecurefunc("EJ_ResetLootFilter", function()
        self.DifficultyDropdown:SignalUpdate()
        self:RequestLoot(20)
    end)

    hooksecurefunc("EJ_SetDifficulty", function(difficultyID)
        self.DifficultyDropdown:SignalUpdate()
    end)
end