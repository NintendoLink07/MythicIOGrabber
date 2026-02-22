local addonName, miog = ...

LootMixin = {}

local instanceDB
local bossDropdownList = {}

local lootQueue = {}
local multiQueue = false
local numberOfBossesShown = 0
local showOnlyItems = false

local dataProvider

local selectedTier, selectedJournalInstance, selectedDifficulty
local selectedSlot, selectedItemClass, selectedItemSubClass, selectedArmorType
local selectedClass, selectedSpec
local specialSelection

local selectedEncounter

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

local armorTypeInfo = {
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Cloth)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Leather)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Mail)},
    {name = C_Item.GetItemSubClassInfo(4, Enum.ItemArmorSubclass.Plate)},
}

function LootMixin:CalculateWaitTime()
    local numOfInstances = #lootQueue

    return 0.25 + numOfInstances * 0.06 + numberOfBossesShown * 0.03

end

function LootMixin:GetSelectedEncounter()
    return selectedEncounter
end

function LootMixin:SetSelectedEncounter(encounterID)
    if(encounterID) then
        EJ_SelectEncounter(encounterID)
        selectedEncounter = encounterID

    else
        selectedEncounter = nil
        self:RequestLoot()

    end
end

function SortInstanceEntries(key1, key2)
    return key1.isRaid and not key2.isRaid or key1.data.journalInstanceID > key2.data.journalInstanceID

end

function SortBossEntries(key1, key2)
    return key1.data.index > key2.data.index

end

function SortItemEntries(key1, key2)
    return key1.data.itemlevel > key2.data.itemlevel

end

function LootMixin:RefreshDifficulties()
    self.DifficultyDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function()
            selectedDifficulty = nil

        end)

        rootDescription:CreateSpacer()

        for i, difficultyID in ipairs(EJ_DIFFICULTIES) do
            if EJ_IsValidInstanceDifficulty(difficultyID) then
                local difficultyButton = rootDescription:CreateRadio(miog.DIFFICULTY_ID_INFO[difficultyID].name, function(id) return id == selectedDifficulty end, function(id)
                    EJ_SetDifficulty(id)
                    self:UpdateAfterCompletion()

                end, difficultyID)
            end
        end
    end)
end

function LootMixin:CheckItemFiltering(itemInfo)
    local hasSpecialItemClass = selectedItemClass or selectedItemSubClass

    if(hasSpecialItemClass) then
        local name, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(itemInfo.link)

        local itemClassIDsOk = classID == selectedItemClass and (not selectedItemSubClass or selectedItemSubClass == subclassID)

        return itemClassIDsOk
    end

    if(selectedArmorType) then
        return selectedArmorType == itemInfo.armorType
        
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

    for k, v in ipairs(bossData) do
        tinsert(bossDropdownList, v)

    end
end


local function addBoss(parent, bossData, encounterID, instanceHasMoreThan1Boss)
    local bossInfo = bossData[encounterID]
    if not bossInfo then return nil end

    bossInfo.template = "MIOG_LootBossTemplate"
    local boss = parent:Insert(bossInfo)
    boss:SetSortComparator(SortItemEntries)
    boss:SetCollapsed(instanceHasMoreThan1Boss, true, false)
    
    return boss
end

local function addInstance(journalInstanceID)
    local journalInfo = miog:GetJournalInstanceInfo(journalInstanceID)
    journalInfo.template = "MIOG_LootInstanceTemplate"

    return dataProvider:Insert(journalInfo)

end


--[[

decouple ifs in journal selection, integrate into requestloot

--]]



function LootMixin:SelectJournalInstance(journalInstanceID)
    local id = journalInstanceID or selectedJournalInstance
    local showEverything = not showOnlyItems
    
    if(id) then
        EJ_SelectInstance(id)
        local numLoot = EJ_GetNumLoot()

        local parent, bossData, instanceHasMoreThan1Boss
        local isMissingData = false

        if(numLoot > 0) then
            if(not multiQueue) then
                parent = dataProvider

            end

            self:RefreshEncounters(id)

            if(showEverything) then
                bossData = miog:GetEncounterDataFromJournalInstance(id)
                instanceHasMoreThan1Boss = miog:GetNumOfBosses(id) > 1

            end

            local instances = {}
            local bosses = {}

            for i = 1, numLoot do
                local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

                if itemInfo and itemInfo.name then
                    local encounterID = itemInfo.encounterID
                    
                    -- Combined filtering and boss check logic
                    local isSelectedEncounter = not selectedEncounter or selectedEncounter == encounterID
                    
                    if isSelectedEncounter and self:CheckItemFiltering(itemInfo) then
                        local parentNode

                        if(showEverything) then
                            local instanceNode = instances[journalInstanceID]

                            if(not instanceNode) then
                                instanceNode = addInstance(journalInstanceID)
                                instances[journalInstanceID] = instanceNode
                                parent = instanceNode
                                parent:SetSortComparator(SortBossEntries)
                            end

                            parentNode = bosses[encounterID]
                            
                            -- Lazy-load the boss node only when an item passes filters
                            if not parentNode then
                                parentNode = addBoss(parent, bossData, itemInfo.encounterID, instanceHasMoreThan1Boss)
                                bosses[encounterID] = parentNode

                                if parentNode then
                                    numberOfBossesShown = numberOfBossesShown + 1
                                end
                            end

                        else
                            parentNode = dataProvider

                        end

                        itemInfo.template = "MIOG_LootItemTemplate"
                        
                        -- Optimization: Only create the item object if you truly need the level
                        local item = Item:CreateFromItemLink(itemInfo.link)
                        itemInfo.itemlevel = item:GetCurrentItemLevel()

                        parentNode:Insert(itemInfo)
                    end
                else
                    isMissingData = true

                end
            end
        end

        return isMissingData
    end
end

function LootMixin:RequestLoot()
    dataProvider:Flush()
    bossDropdownList = {}

    multiQueue = #lootQueue > 1
    numberOfBossesShown = 0
    showOnlyItems = self.OnlyItemsButton:GetChecked()

    local isMissingData

    if(showOnlyItems) then
        dataProvider:SetSortComparator(SortItemEntries)

    elseif(multiQueue) then
        dataProvider:SetSortComparator(SortInstanceEntries)

    end

    if(#lootQueue > 0) then
        for k, v in ipairs(lootQueue) do
            isMissingData = self:SelectJournalInstance(v) or false

        end

        self:RefreshDifficulties()

        if(not isMissingData) then
            if(numberOfBossesShown == 1) then
                dataProvider:SetAllCollapsed(false)

            else
                dataProvider:SetAllCollapsed(true)

            end

            self.ScrollBox:SetDataProvider(dataProvider)

        end
    end
end

function LootMixin:SetupInstanceMenu(dropdown, rootDescription)
    local expansionButtons = {}
    local allRaidsTierButtons, allDungeonsTierButtons = {}, {}

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

        allRaidsTierButtons[k] = expansionButtons[k]:CreateRadio(ALL .. " " .. RAIDS, function(index) return index == selectedTier and specialSelection == RAIDS end, function(index)
            lootQueue = allRaidsTierButtons[k].QueueList

            selectedJournalInstance = nil
            selectedTier = index
            specialSelection = RAIDS

            self:RequestLoot()
            
        end, k)
        allRaidsTierButtons[k].QueueList = {}

        allDungeonsTierButtons[k] = expansionButtons[k]:CreateRadio(ALL .. " " .. DUNGEONS, function(index) return index == selectedTier and specialSelection == DUNGEONS end, function(index)
            lootQueue = allDungeonsTierButtons[k].QueueList

            selectedJournalInstance = nil
            selectedTier = index
            specialSelection = DUNGEONS

            self:RequestLoot()

        end, k)
        allDungeonsTierButtons[k].QueueList = {}
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
                tinsert(allRaidsTierButtons[v.tier].QueueList, v.journalInstanceID)
                
            else
                tinsert(allDungeonsTierButtons[v.tier].QueueList, v.journalInstanceID)

            end
            
            local instanceButton = expansionButtons[v.tier]:CreateRadio(v.instanceName, function(journalInstanceID) return selectedJournalInstance == journalInstanceID end, function(journalInstanceID)
                lootQueue = {journalInstanceID}

                selectedJournalInstance = journalInstanceID
                selectedTier = v.tier
                specialSelection = nil

                self.SearchBox:CreateFilter("instance", v.instanceName, function() end)

                self:RequestLoot()

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

    if(#lootQueue == 0) then
        lootQueue = miog:table_merge(allDungeonsTierButtons[#allDungeonsTierButtons].QueueList, allRaidsTierButtons[#allRaidsTierButtons].QueueList)
        
        self:RequestLoot()
    end
end

function LootMixin:OnShow()
    instanceDB = miog:GetJournalDB()

    self.InstanceDropdown:SetupMenu(function(dropdown, rootDescription)
        self:SetupInstanceMenu(dropdown, rootDescription)
    end)
end

local lastInfo = 0

function LootMixin:UpdateAfterCompletion()
    lastInfo = GetTimePreciseSec()

    if(not updateTimer or updateTimer:IsCancelled()) then
        updateTimer = C_Timer.NewTicker(0.25, function()
            if(GetTimePreciseSec() - lastInfo > self:CalculateWaitTime()) then
                print("HERE", GetTimePreciseSec(), lastInfo, GetTimePreciseSec() - lastInfo)
                updateTimer:Cancel()

                self:RequestLoot()
            end
        end)
    end
end

function LootMixin:OnEvent(event, ...)
    print("EVENT", event)

    if(event == "EJ_LOOT_DATA_RECIEVED") then
        self:UpdateAfterCompletion()

    end
end

function LootMixin:RefreshClassesAndArmor()
    self.ClassArmorDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton(CLEAR_ALL, function()
            selectedArmorType = nil
            EJ_ResetLootFilter()

            self:RequestLoot()

        end)

        rootDescription:CreateSpacer()

        --local classID, specID = EJ_GetLootFilter()

        local ownClassName, fileName, ownClassID = UnitClass("PLAYER")
        local classColor = C_ClassColor.GetClassColor(fileName)
        rootDescription:CreateTitle(WrapTextInColorCode(ownClassName, classColor and classColor:GenerateHexColor() or "FFFFFFFF"))

        local specCount = C_SpecializationInfo.GetNumSpecializationsForClassID(ownClassID)

        for specIndex = 1, specCount, 1 do
            local specId, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(specIndex)

	        rootDescription:CreateRadio(name, function(getID) return getID == selectedSpec end, function(getID)
                EJ_SetLootFilter(ownClassID, getID)
                self:RequestLoot()
                
            end, specId)
        end

        rootDescription:CreateSpacer()

        local classButton = rootDescription:CreateButton(ALL_CLASSES)

        classButton:CreateButton(CLEAR_ALL, function()
            EJ_ResetLootFilter()
            self:RequestLoot()

        end)
            
        classButton:CreateSpacer()

        for k, v in ipairs(miog.OFFICIAL_CLASSES) do
	        local classMenu = classButton:CreateRadio(GetClassInfo(k), function(id) return id == selectedClass end, function(id)
                EJ_SetLootFilter(id, 0)
                self:RequestLoot()

            end, k)

            for x, y in ipairs(v.specs) do
                local id, specName, description, icon, role, classFile, className = GetSpecializationInfoByID(y)

                classMenu:CreateRadio(specName, function(getID) return getID == selectedSpec end, function(getID)
                    EJ_SetLootFilter(k, getID)
                    self:RequestLoot()
                    
                end, id)
            end
        end

        local armorButton = rootDescription:CreateButton(ARMOR)

        armorButton:CreateButton(CLEAR_ALL, function(index)
            selectedArmorType = nil
            self:RequestLoot()

        end)
            
        armorButton:CreateSpacer()

        for k, v in ipairs(armorTypeInfo) do
	        armorButton:CreateRadio(v.name, function(name) return name == selectedArmorType end, function(name)
                selectedArmorType = v.name
                self:RequestLoot()

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

            self:RequestLoot()

        end)
            
        rootDescription:CreateSpacer()

        local sortedFilters = {}

        for k, v in pairs(Enum.ItemSlotFilterType) do
            sortedFilters[v] = k
        end

        for i = 0, #sortedFilters - 1, 1 do
            rootDescription:CreateRadio(miog.SLOT_FILTER_TO_NAME[i], function(index) return index == C_EncounterJournal.GetSlotFilter() end, function(index)
                selectedItemClass = nil
                selectedItemSubClass = nil
                C_EncounterJournal.SetSlotFilter(index)

                self:RequestLoot()
            end, i)
        end

        rootDescription:CreateRadio("Mounts", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            C_EncounterJournal.SetSlotFilter(14)

            self:RequestLoot()

        end, {class = 15, subclass = 5})

        rootDescription:CreateRadio("Recipes", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            C_EncounterJournal.SetSlotFilter(14)

            self:RequestLoot()

        end, {class = 9, subclass = nil})

        rootDescription:CreateRadio("Tokens", function(data) return selectedItemClass == data.class and selectedItemSubClass == data.subclass end, function(data)
            selectedItemClass = data.class
            selectedItemSubClass = data.subclass
            C_EncounterJournal.SetSlotFilter(14)

            self:RequestLoot()

        end, {class = 15, subclass = 0})
    end)
end

function LootMixin:SetupEncounterMenu()
    self.BossDropdown:SetupMenu(function(dropdown, rootDescription)
        if(bossDropdownList and #bossDropdownList > 0) then
            rootDescription:CreateButton(CLEAR_ALL, function()
                self:SetSelectedEncounter()

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

                    local encounterButton = rootDescription:CreateRadio(v.name or v.altName, function(data) return data.journalEncounterID == self:GetSelectedEncounter() end, function(data)
                        self:SetSelectedEncounter(data.journalEncounterID)

                        self:RequestLoot()

                    end, v)
                end
            end
        end
    end)
end

function LootMixin:OnLoad()
	self.InstanceDropdown:SetDefaultText("---Instances---")
	self.BossDropdown:SetDefaultText("---Bosses---")
	self.ClassArmorDropdown:SetDefaultText("---Class---")
	self.SlotDropdown:SetDefaultText("---Slot---")
	self.DifficultyDropdown:SetDefaultText("---Difficulty---")

    dataProvider = CreateTreeDataProvider()
    self:RefreshSlots()
    self:RefreshClassesAndArmor()
    self:SetupEncounterMenu()

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
        self:RequestLoot()
    end)

    self.OnlyItemsButton:SetScript("PostClick", function(selfFrame)
        selfFrame:GetParent():RequestLoot()
    
    end)

	ScrollUtil.RegisterScrollBoxWithScrollBar(self.ScrollBox, self:GetParent():GetParent().ScrollBarArea.LootScrollBar)

    hooksecurefunc("EJ_SetLootFilter", function(classID, specID)
        selectedClass = classID
        selectedSpec = specID

    end)

    hooksecurefunc("EJ_ResetLootFilter", function()
        selectedClass = nil
        selectedSpec = nil

    end)

    hooksecurefunc("EJ_SetDifficulty", function(difficultyID)
        selectedDifficulty = difficultyID

    end)
end