local addonName, miog = ...

local simpleTypes = {
	itemID = 1,
	enchantID = 2,
	suffixID = 7,
	uniqueID = 8,
	linkLevel = 9,
	specializationID = 10,
	modifiersMask = 11,
	itemContext = 12,
}

local itemIDsToLoad = {}

local function getEnumKeyForItemMods(number)
    for k, v in pairs(Enum.ItemModification) do
        if(v == number) then
            return k
        end
    end
end

local function getEnumKeyForContext(number)
    for k, v in pairs(Enum.ItemCreationContext) do
        if(v == number) then
            return k
        end
    end
end

local function findCorrectBonusID(difference)
    local lastID

    for k, v in pairs(miog.RAW["ItemBonus"]) do
        if(v[7] == 1 and v[2] == difference) then
            if(not lastID or lastID < v[1]) then
                lastID = v[6]

                return lastID

            end
        end
    end

    return lastID
end

local function findActualBonusID(bonusID)
    for k, v in pairs(miog.RAW["ItemBonus"]) do
        if(v[6] == bonusID) then
            return v[1]
        end
    end
end

local function findBonusIDType(bonusID)
    for k, v in pairs(miog.RAW["ItemBonus"]) do
        if(v[1] == bonusID) then
            return v[7]
        end
    end
end

local function printAllBonusIDs(link)
    local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
    local array = {strsplit(":", linkOptions)}
	local numBonusIDs = tonumber(array[13])

    print("------- " .. displayText .. ", " .. getEnumKeyForContext(tonumber(array[12])) .. " -------")

    for i = 14, 13 + numBonusIDs, 1 do
        local bonusID = tonumber(array[i])

        local actualBonusID = findActualBonusID(bonusID)
        local bonusIDType = findBonusIDType(actualBonusID)

        print(actualBonusID, bonusID, bonusIDType)
    end
end

miog.printAllBonusIDs = printAllBonusIDs


--[[
    exp 1/8 11942
    exp 8/8 11949

    adv 1/8 11950
    adv 8/8 11957

    vet 1/8 11969
    vet 8/8 11976

    champ 1/8 11977
    champ 8/8 11984

    hero 1/6 11985
    hero 6/6 11990

    myth 1/6 11991
    myth 6/6 11996

]]

--[[
    mythic+ tag 10390
    fortune crafted 12040

]]

--[[
    base 593 10421
    base 662 25167
]]

local function addBonusIDsToArray(array, ...)
    local tempArray = {...}
    local size = #tempArray

    array[13] = tonumber(array[13]) + size

    for i = 1, size, 1 do
        table.insert(array, i + 13, tempArray[i])

    end
    
end

local function setItemLinkToSpecificItemLevel(link, ilvl, type)
    local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
    local array = {strsplit(":", linkOptions)}

    array[12] = type == "mythicPlus" and 34 or type == "crafting" and 13

    local bestBonusID = findCorrectBonusID((type == "mythicPlus" and 655 or type == "crafting" and 675) - ilvl)

    if(type == "mythicPlus") then
        addBonusIDsToArray(array, 10390, 11987, bestBonusID)

    elseif(type == "crafting") then
        addBonusIDsToArray(array, 21612, 10240, bestBonusID)
        
    end

    local newLink = LinkUtil.FormatLink(linkType, displayText, unpack(array))

    return newLink
end

miog.setItemLinkToSpecificItemLevel = setItemLinkToSpecificItemLevel

local function setItemLinkArrayToSpecificItemLevel(link, ilvl, type, linkIsArray)
    local array
    local linkType, linkOptions, displayText

    if(not linkIsArray) then
        linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
        array = {strsplit(":", linkOptions)}

    else
        array = link

    end

    array[12] = type == "mythicPlus" and 34 or type == "crafting" and 13

    local bestBonusID = findCorrectBonusID((type == "mythicPlus" and 655 or type == "crafting" and 675) - ilvl)

    if(type == "mythicPlus") then
        addBonusIDsToArray(array, 10390, 11987, bestBonusID)

    elseif(type == "crafting") then
        addBonusIDsToArray(array, 21612, 10240, bestBonusID)
        

    end

    if(not linkIsArray) then
        local newLink = LinkUtil.FormatLink(linkType, displayText, unpack(array))

        return newLink
    end

    return array
end


local tracks = {
    {name = "Explorer", range = {11942, 11949}},
    {name = "Adventurer", range = {11950, 11957}},
    {name = "Veteran", range = {11969, 11976}},
    {name = "Champion", range = {11977, 11984}},
    {name = "Hero", range = {11985, 11990}},
    {name = "Myth", range = {11991, 11996}},
}

local function findMaxItemLevelOfTrack(trackNameOrIndex)
    for k, v in ipairs(tracks) do
        if(trackNameOrIndex == k or trackNameOrIndex == v.name) then
            return v.range[2] - v.range[1] + 1

        end
    end
end

local function findTrackTypeOfItemLink(link)
    if(link) then
        local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
        local array = {strsplit(":", linkOptions)}

        local numBonusIDs = tonumber(array[13]) or 0

        for i = 14, 13 + numBonusIDs, 1 do
            local bonusID = tonumber(array[i])

            for k = 1, #tracks, 1 do
                local trackInfo = tracks[k]

                if(bonusID >= trackInfo.range[1] and bonusID <= trackInfo.range[2]) then
                    return trackInfo.name

                end
            end
        end
    end
end

local function removeItemLevelsFromItemLink(link, linkIsArray)
    local array, linkType, linkOptions, displayText
    
    if(not linkIsArray) then
        linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
        array = {strsplit(":", linkOptions)}

    else
        array = link

    end

	local numBonusIDs = tonumber(array[13]) or 0

    local toBeRemoved = {}

    for i = 14, 13 + numBonusIDs, 1 do
        local bonusID = tonumber(array[i])

        local actualBonusID = findActualBonusID(bonusID)
        local bonusIDType = findBonusIDType(actualBonusID)
        
        if(bonusIDType == 1 or bonusIDType == 42 or bonusIDType == 0) then -- remove anything with base itemlevel, item level addition or subtraction
            tinsert(toBeRemoved, i)

        end
    end

    array[13] = tostring(numBonusIDs - #toBeRemoved)

    for i = #toBeRemoved, 1, -1 do
        local index = toBeRemoved[i]
        table.remove(array, index)

    end

    if(not linkIsArray) then
        local newLink = LinkUtil.FormatLink(linkType, displayText, unpack(array))

        return newLink
    end

    return array
end

local function removeAndSetItemLinkItemLevels(link, type)
    local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
    local array = {strsplit(":", linkOptions)}

    array = removeItemLevelsFromItemLink(array, true)

    local _, _, ilvl = C_Item.GetDetailedItemLevelInfo(link)

    array = setItemLinkArrayToSpecificItemLevel(array, ilvl, type, true)

    return LinkUtil.FormatLink(linkType, displayText, unpack(array))
end

miog.removeAndSetItemLinkItemLevels = removeAndSetItemLinkItemLevels

local function initializeLootFrames(frame, elementData)
    if(elementData.template == "MIOG_UpgradeFinderItemSingleTemplate") then
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

        frame.BasicInformation.Icon:SetTexture(elementData.icon)

        if(elementData.itemlevel) then
            frame.BasicInformation.Itemlevel:SetText("[" .. elementData.itemlevel .. "]")

        else
            frame.BasicInformation.Itemlevel:SetText("")

        end

        frame.BasicInformation.Name:SetText(formattedText or elementData.name)

        if(elementData.difficultyID) then
            frame.BasicInformation.Difficulty:SetText("[" .. WrapTextInColorCode(
            miog.DIFFICULTY_ID_INFO[elementData.difficultyID].shortName .. (elementData.rarity == 1 and " - Rare" or ""), miog.DIFFICULTY_ID_TO_COLOR[elementData.difficultyID]:GenerateHexColor()) .. "]")

        else
            frame.BasicInformation.Difficulty:SetText("")

        end

        frame.BasicInformation.Instance:SetText(elementData.instanceName or "")


        if(elementData.color) then
            frame.BasicInformation.Name:SetTextColor(elementData.color.r, elementData.color.g, elementData.color.b, 1)

        else
            frame.BasicInformation.Name:SetTextColor(1, 1, 1, 1)

        end

        --frame.itemLink = elementData.link
        
        if(elementData.itemLink) then 
            frame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(elementData.itemLink)
                GameTooltip_AddBlankLineToTooltip(GameTooltip)

                if(elementData.encounterID) then
                    local encounterName, _, _, _, _, journalInstanceID = EJ_GetEncounterInfo(elementData.encounterID)
                    local instanceName = EJ_GetInstanceInfo(journalInstanceID)

                    GameTooltip:AddLine("[" .. instanceName .. "]: " .. encounterName)

                end

                if(elementData.rarity > 0) then
                    GameTooltip:AddLine(elementData.rarity == 1 and EJ_ITEM_CATEGORY_VERY_RARE or EJ_ITEM_CATEGORY_EXTREMELY_RARE)

                end

                GameTooltip:Show()
            end)
        else
            frame:SetScript("OnEnter", nil)

        end

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

local ProfessionsCustomerOrdersEvents =
{
    "PLAYER_MONEY",
};

local function professionsFrameOnShow()
    local self = ProfessionsCustomerOrdersFrame
    FrameUtil.RegisterFrameForEvents(self, ProfessionsCustomerOrdersEvents);

    self:UpdateMoneyFrame();
    self:SetPortraitToUnit("npc");
    self:SelectMode(ProfessionsCustomerOrdersMode.Browse);

    self.BrowseOrders:Init();

    PlaySound(SOUNDKIT.AUCTION_WINDOW_OPEN);

	self:ShowCurrentPage();
	C_CraftingOrders.OpenCustomerCraftingOrders();
end

local function requestAllLootForMapID(info)
    local mapInfo = miog.MAP_INFO[info.mapID]
    local journalInstanceID = mapInfo.journalInstanceID or C_EncounterJournal.GetInstanceForGameMap(info.mapID) or EJ_GetInstanceForMap(info.mapID) or nil

    if(journalInstanceID and journalInstanceID > 0 and C_EncounterJournal.InstanceHasLoot(journalInstanceID)) then
        EJ_SelectInstance(journalInstanceID)

        local isRaid = EJ_InstanceIsRaid()
        EJ_SetDifficulty(isRaid and (not info.active and 14 or 16) or (not info.active and 23 or 8))

        local numLoot = EJ_GetNumLoot()

        for i = 1, numLoot, 1 do
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

            if(not itemInfo.name) then
                itemIDsToLoad[itemInfo.itemID] = {isRaid = isRaid, journalInstanceID = journalInstanceID, active = info.active, difficultyID = EJ_GetDifficulty()}

            end
        end

        return {journalInstanceID = journalInstanceID}
    end

end

local function findAllRelevantMapIDs()
    local instanceList = {}

    local dungeonGroup = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.Recommended))
    local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE))
    local seasonGroups = miog.retrieveCurrentRaidActivityGroups()
    local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion))

    local listWithMapIDs = {}
    local seasonalDungeonsDone = {}
    
    if(dungeonGroup and #dungeonGroup > 0) then
        for _, v in ipairs(dungeonGroup) do
            local groupInfo = miog.requestGroupInfo(v)
            listWithMapIDs[#listWithMapIDs + 1] = {mapID = groupInfo.mapID, active = true}
            seasonalDungeonsDone[v] = true
        end
    end

    if(expansionGroups and #expansionGroups > 0) then
        for _, v in ipairs(expansionGroups) do
            if(not seasonalDungeonsDone[v]) then
                local groupInfo = miog.requestGroupInfo(v)
                listWithMapIDs[#listWithMapIDs + 1] = {mapID = groupInfo.mapID, active = false}
                
            end
        end
    end

    if(seasonGroups and #seasonGroups > 0) then
        for _, v in ipairs(seasonGroups) do
            local groupInfo = miog.requestGroupInfo(v)
            listWithMapIDs[#listWithMapIDs + 1] = {mapID = groupInfo.mapID, active = true}

        end
    end

    if(worldBossActivity and #worldBossActivity > 0) then
        for _, v in ipairs(worldBossActivity) do
            local activityInfo = miog.requestActivityInfo(v)
            listWithMapIDs[#listWithMapIDs + 1] = {mapID = activityInfo.mapID, active = false}
            
        end
    end

    for k, info in ipairs(listWithMapIDs) do
        print(k, info.mapID)

        local tbl = requestAllLootForMapID(info)

        if(tbl) then
            tbl.active = info.active
            tinsert(instanceList, tbl)
            
        end

    end

    return instanceList
end

local function hasNoMainStatOnIt(tbl)
    return not tbl["ITEM_MOD_AGILITY_SHORT"] and not tbl["ITEM_MOD_INTELLECT_SHORT"] and not tbl["ITEM_MOD_STRENGTH_SHORT"]
end

local function sortItems(k1, k2)
    return k1.itemlevel > k2.itemlevel
end

local function findMainHandItemLevel()
    local mainHandItem = Item:CreateFromEquipmentSlot(16)
    
    if(mainHandItem:GetInventoryType() == 17) then --TWOHANDED
        return mainHandItem:GetCurrentItemLevel()

    elseif(mainHandItem:GetInventoryType() == 13) then --ONEHANDED
        return 0

    else
        return 0

    end
end

local function addSinglePVEItemID(itemID)
    local ejInfo = C_EncounterJournal.GetLootInfo(itemID)
    local info = itemIDsToLoad[itemID]
 
    if(info and ejInfo) then
        local specID = GetSpecializationInfo(GetSpecialization())
        local mainStat = miog.SPECIALIZATIONS[specID].stat
        local item = Item:CreateFromItemID(itemID)
        local itemLink

        if(not info.isRaid and info.active) then
            local newLink = removeAndSetItemLinkItemLevels(item.link, "mythicPlus")

            itemLink = newLink

        else
            itemLink = item:GetItemLink()

        end

        local newItem = Item:CreateFromItemLink(itemLink)
        local itemLevel = newItem:GetCurrentItemLevel()

        local statTable = C_Item.GetItemStats(itemLink)

        local trackType1 = findTrackTypeOfItemLink(itemLink)
        local trackType2 = findTrackTypeOfItemLink(item:GetItemLink())

        local isOverIlvl = itemLevel >= itemLevelToBeat
        local isOverIlvlRaid = info.isRaid and isOverIlvl
        local isOverIlvlMPlus = not info.isRaid and (isOverIlvl or (info.active and trackType1 and trackType2 and (trackType1 == trackType2 or findMaxItemLevelOfTrack(trackType1) >= itemLevelToBeat)))
        
        if(isOverIlvlRaid or isOverIlvlMPlus and (statTable[mainStat] or hasNoMainStatOnIt(statTable))) then
            local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(info.journalInstanceID);

            miog.UpgradeFinder.ScrollBox:GetDataProvider():Insert({
                template = "MIOG_UpgradeFinderItemSingleTemplate",
                name = item:GetItemName(),
                icon = item:GetItemIcon(),
                rarity = ejInfo.displayAsVeryRare and 1 or ejInfo.displayAsExtremelyRare and 2 or 0,
                encounterID = ejInfo.encounterID,
                difficultyID = info.difficultyID,
                itemLink = itemLink,
                isRaid = info.isRaid,
                instanceName = instanceName,
                itemlevel = itemLevel,
                itemID = newItem:GetItemID(),
                color = newItem:GetItemQualityColor()
            })
        end
    end
end

local function checkSinglePVEItem(itemID)
    local frame = miog.UpgradeFinder.ScrollBox:FindFrameByPredicate(function(localFrame, data)
        return data.itemID == itemID
    end)

    if(not frame) then
        return true

    end
end

local function findApplicablePVEItems(dataProvider, instanceList, item, filterID)
    local itemLevelToBeat = item:GetCurrentItemLevel()
    local specID = GetSpecializationInfo(GetSpecialization())
    local mainStat = miog.SPECIALIZATIONS[specID].stat

    if(not itemLevelToBeat) then
        if(filterID == 11) then
            itemLevelToBeat = findMainHandItemLevel()

        else
            itemLevelToBeat = 0

        end
    end

    for _, v in ipairs(instanceList) do
        EncounterJournal.instanceID = instanceID;
        EncounterJournal.encounterID = nil;

        EJ_SelectInstance(v.journalInstanceID)

        local isRaid = EJ_InstanceIsRaid()
        
        local difficultyArray = isRaid and miog.RAID_DIFFICULTIES or {miog.DUNGEON_DIFFICULTIES[#miog.DUNGEON_DIFFICULTIES]}
        --local difficultyArray = isRaid and miog.RAID_DIFFICULTIES or miog.DUNGEON_DIFFICULTIES

        for _, difficultyID in ipairs(difficultyArray) do
            EJ_SetDifficulty(difficultyID)

            local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo();
            local numOfLoot = EJ_GetNumLoot()

            if(numOfLoot > 0) then
                for i = 1, numOfLoot, 1 do
                    local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

                    if(not itemInfo.weaponTypeError and not itemInfo.handError) then
                        local itemLink
                
                        if(not isRaid and v.active) then
                            local newLink = removeAndSetItemLinkItemLevels(itemInfo.link, "mythicPlus")
                
                            itemLink = newLink
                
                        else
                            itemLink = itemInfo.link
                
                        end
                
                        local newItem = Item:CreateFromItemLink(itemLink)
                        local itemLevel = newItem:GetCurrentItemLevel()
                
                        local statTable = C_Item.GetItemStats(itemInfo.link)
                
                        local trackType1 = findTrackTypeOfItemLink(newItem:GetItemLink())
                        local trackType2 = findTrackTypeOfItemLink(item:GetItemLink())
                
                        local isOverIlvl = itemLevel >= itemLevelToBeat
                        local isOverIlvlRaid = isRaid and isOverIlvl
                        local isOverIlvlMPlus = not isRaid and (isOverIlvl or (v.active and trackType1 and trackType2 and (trackType1 == trackType2 or findMaxItemLevelOfTrack(trackType1) >= itemLevelToBeat)))
                        
                        if((isOverIlvlRaid or isOverIlvlMPlus) and (statTable[mainStat] or hasNoMainStatOnIt(statTable))) then
                            dataProvider:Insert({
                                template = "MIOG_UpgradeFinderItemSingleTemplate",
                                name = itemInfo.name,
                                icon = itemInfo.icon,
                                rarity = itemInfo.displayAsVeryRare and 1 or itemInfo.displayAsExtremelyRare and 2 or 0,
                                encounterID = itemInfo.encounterID,
                                difficultyID = difficultyID,
                                itemLink = itemLink,
                                isRaid = isRaid,
                                instanceName = instanceName,
                                itemlevel = itemLevel,
                                itemID = newItem:GetItemID(),
                                color = newItem:GetItemQualityColor()
                            })
                        end
                    end
                end
            end
        end
    end
end

local invSlotToFilterType = {
    [0] = 14,
    [1] = 0,
    [2] = 1,
    [3] = 2,
    [4] = 14,
    [5] = 4,
    [6] = 8,
    [7] = 7,
    [8] = 9,
    [9] = 5,
    [10] = 6,
    [11] = 12,
    [12] = 13,
    [13] = 10,
    [14] = 11,
    [15] = 10,
    [16] = 3,
    [17] = 10,
    [18] = 14,
    [19] = 14,
    [20] = 14,
    [21] = 10,
    [22] = 10,
    [23] = 11,
    [24] = 14,
    [25] = 10,
    [26] = 10,

}

local function findApplicableCraftingItems(dataProvider, filterID, itemLevelToBeat)
    if(ProfessionsCustomerOrdersFrame) then
        local specID = GetSpecializationInfo(GetSpecialization())
        local mainStat = miog.SPECIALIZATIONS[specID].stat

        local categoryFilters = ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:GetCategoryFilters();
        local searchBoxText = ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox:GetText();
        local searchText = searchBoxText ~= "" and searchBoxText or nil;
        local filterDropdown = ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.FilterDropdown;
        local minLevel, maxLevel = filterDropdown.minLevel, filterDropdown.maxLevel;

        local searchParams =
        {
            isFavoritesSearch = false,
            -- All filters are ignored for favorites searches
            categoryFilters = categoryFilters,
            searchText = searchText,
            minLevel = minLevel,
            maxLevel = maxLevel,
            uncollectedOnly = filterDropdown.filters[Enum.AuctionHouseFilter.UncollectedOnly],
            usableOnly = true, --filterDropdown.filters[Enum.AuctionHouseFilter.UsableOnly],
            upgradesOnly = filterDropdown.filters[Enum.AuctionHouseFilter.UpgradesOnly],
            currentExpansionOnly = filterDropdown.filters[Enum.AuctionHouseFilter.CurrentExpansionOnly],
            includePoor = filterDropdown.filters[Enum.AuctionHouseFilter.PoorQuality],
            includeCommon = filterDropdown.filters[Enum.AuctionHouseFilter.CommonQuality],
            includeUncommon = filterDropdown.filters[Enum.AuctionHouseFilter.UncommonQuality],
            includeRare = filterDropdown.filters[Enum.AuctionHouseFilter.RareQuality],
            includeEpic = filterDropdown.filters[Enum.AuctionHouseFilter.EpicQuality],
            includeLegendary = filterDropdown.filters[Enum.AuctionHouseFilter.LegendaryQuality],
            includeArtifact = filterDropdown.filters[Enum.AuctionHouseFilter.ArtifactQuality],
        };

        local searchResults = C_CraftingOrders.GetCustomerOptions(searchParams);

        for k, v in pairs(searchResults.options) do
            if(v.iLvlMax == 675) then
                local item = Item:CreateFromItemID(v.itemID)

                if(invSlotToFilterType[item:GetInventoryType()] == filterID) then
                    local newLink = removeAndSetItemLinkItemLevels(item:GetItemLink(), "crafting")
                    local statTable = C_Item.GetItemStats(newLink)
                            
                    if(statTable[mainStat] or hasNoMainStatOnIt(statTable)) then
                        item = Item:CreateFromItemLink(newLink)

                        if(item:GetCurrentItemLevel() >= itemLevelToBeat) then
                            dataProvider:Insert({
                                template = "MIOG_UpgradeFinderItemSingleTemplate",
                                name = v.itemName,
                                icon = item:GetItemIcon(),
                                rarity = 0,
                                encounterID = nil,
                                difficultyID = nil,
                                itemLink = newLink,
                                isRaid = nil,
                                instanceName = "Crafting",
                                itemlevel = item:GetCurrentItemLevel(),
                                color = item:GetItemQualityColor()
                            })
                        end
                    end
                end
            end
        end
    end
end

local function findItems(filterID, item)
    C_EncounterJournal.SetSlotFilter(filterID)

    local instanceList = findAllRelevantMapIDs()

    local dataProvider = CreateDataProvider()
    dataProvider:SetSortComparator(sortItems)

    local itemlevel = item:GetCurrentItemLevel() or 0

    findApplicablePVEItems(dataProvider, instanceList, item, filterID)
    findApplicableCraftingItems(dataProvider, filterID, itemlevel)

    miog.UpgradeFinder.ScrollBox:SetDataProvider(dataProvider)

    return dataProvider:GetSize()
end

local function showNothingFoundMessage()
    local dataProvider = CreateDataProvider()
    dataProvider:SetSortComparator(sortItems)
    dataProvider:Insert({
        template = "MIOG_UpgradeFinderItemSingleTemplate",
        name = "No item upgrades found for this slot.",
        rarity = 0,
    })
    miog.UpgradeFinder.ScrollBox:SetDataProvider(dataProvider)
end

local lastFilter, lastItem

miog.updateItemList = function(filterID, item)
    lastFilter, lastItem = filterID, item

    local specID = GetSpecializationInfo(GetSpecialization())
    local _, _, classID = UnitClass("player")

    EJ_SetLootFilter(classID, specID);

    local size = findItems(filterID, item)

    if(size == 0 and (filterID == 10 or filterID == 11)) then
        local wasMainBefore = filterID == 10
        local newFilterID = wasMainBefore and 11 or 10
        --local newInvSlotID = wasMainBefore and 17 or 16

        --local item = Item:CreateFromEquipmentSlot(newInvSlotID)
        --local newIlvl = item:GetCurrentItemLevel()

        size = findItems(newFilterID, item, invSlotID)
        
    end

    if(size == 0) then
        showNothingFoundMessage()

    end
end

local function ufEvents(_, event, itemID)
    if(itemID) then
        if(checkSinglePVEItem(itemID)) then
            addSinglePVEItemID(itemID)

        end
    else
        if(lastFilter and lastItem) then
            miog.updateItemList(lastFilter, lastItem)

        end
    end
end

miog.loadUpgradeFinder = function()
    local upgradeFinder = miog.pveFrame2.TabFramesPanel.UpgradeFinder

    upgradeFinder:SetScript("OnShow", function()
        ProfessionsCustomerOrders_LoadUI();
        professionsFrameOnShow()
    
    end)

    local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 2)
    view:SetPadding(1, 1, 1, 1, 4)

    view:SetElementFactory(CustomFactory)
    
    ScrollUtil.InitScrollBoxListWithScrollBar(upgradeFinder.ScrollBox, upgradeFinder.ScrollBar, view)
    
    ProfessionsCustomerOrders_LoadUI();
    --ShowUIPanel(ProfessionsCustomerOrdersFrame);
    --HideUIPanel(ProfessionsCustomerOrdersFrame);

    local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_UFEventReceiver")

    eventReceiver:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
    eventReceiver:SetScript("OnEvent", ufEvents)

    return upgradeFinder
end