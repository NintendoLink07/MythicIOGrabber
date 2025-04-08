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

--[[

]]

local function findNextBaseItemLevelBonusID(bonusID, ascending)
    for k, v in pairs(miog.RAW["ItemBonus"]) do
        if(v[1] == bonusID) then
            return v[7]
        end
    end
end

local alreadyIn = {}

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

    hero 1/6 11985
    hero 6/6 11990

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

--[[
    577, 544, 610

]]

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

local function replaceOptionsInItemLink(link, itemLevel)
    local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
    local array = {strsplit(":", linkOptions)}

    local index = 12
    --array[index] = tbl[1]

    index = index + 1

    local difference = 655 - 437

	local numBonusIDs = tonumber(array[index])

    array[index] = numBonusIDs and tostring(numBonusIDs + 1) or "0"
end

local function replaceModInItemLink(link, contentTuningID)
	local xd, linkOptions = LinkUtil.ExtractLink(link)
	local item = {strsplit(":", linkOptions)}

	local idx = 13
	local numBonusIDs = tonumber(item[idx])
	idx = idx + (numBonusIDs or 0) + 1

    local toReplace = ""
    local replacementString = ""
    
    local numModifiers = tonumber(item[idx])
	if numModifiers then
		for i = 1, numModifiers do
			local offset = i*2

            toReplace = item[idx+offset-1] .. ":" .. item[idx+offset]
            replacementString = item[idx+offset-1] .. ":" .. contentTuningID
		end
		idx = idx + numModifiers*2 + 1
	else
		idx = idx + 1
	end

    local string, count = string.gsub(link, toReplace, replacementString)

    return string
end

local function ParseItemLink(link)
	local _, linkOptions = LinkUtil.ExtractLink(link)
	local item = {strsplit(":", linkOptions)}
	local t = {}

	for k, v in pairs(simpleTypes) do
		t[k] = tonumber(item[v])
	end

	for i = 1, 4 do
		local gem = tonumber(item[i+2])
		if gem then
			t.gems = t.gems or {}
			t.gems[i] = gem
		end
	end

	local idx = 13
	local numBonusIDs = tonumber(item[idx])
	if numBonusIDs then
		t.bonusIDs = {}
		for i = 1, numBonusIDs do
			t.bonusIDs[i] = tonumber(item[idx+i])
		end
	end
	idx = idx + (numBonusIDs or 0) + 1

	local numModifiers = tonumber(item[idx])
	if numModifiers then
		t.modifiers = {}
		for i = 1, numModifiers do
			local offset = i*2

            local id1 = tonumber(item[idx+offset-1])
            local id2 = tonumber(item[idx+offset])

			t.modifiers[i] = {
				{id = id1, enum = getEnumKey(id1)},
				{id = id2, enum = getEnumKey(id2)},
			}
            
            --[[local id = tonumber(item[idx+offset-1])
            t.modifiers[i] = {
                id = id,
                enum = getEnumKey(id)
            }]]
		end
		idx = idx + numModifiers*2 + 1
	else
		idx = idx + 1
	end

	for i = 1, 3 do
		local relicNumBonusIDs = tonumber(item[idx])
		if relicNumBonusIDs then
			t.relicBonusIDs = t.relicBonusIDs or {}
			t.relicBonusIDs[i] = {}
			for j = 1, relicNumBonusIDs do
				t.relicBonusIDs[i][j] = tonumber(item[idx+j])
			end
		end
		idx = idx + (relicNumBonusIDs or 0) + 1
	end

	local crafterGUID = item[idx]
	if #crafterGUID > 0 then
		t.crafterGUID = crafterGUID
	end
	idx = idx + 1

	t.extraEnchantID = tonumber(item[idx])

	return t
end

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
        frame.BasicInformation.Itemlevel:SetText("[" .. elementData.itemlevel .. "]")
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

    return upgradeFinder
end

local currentItemIDs

local function requestAllLootForMapID(info, filterID)
    local mapInfo = miog.MAP_INFO[info.mapID]
    C_EncounterJournal.SetSlotFilter(filterID)

    local journalInstanceID = mapInfo.journalInstanceID or C_EncounterJournal.GetInstanceForGameMap(info.mapID) or EJ_GetInstanceForMap(info.mapID) or nil

    if(journalInstanceID and journalInstanceID > 0 and C_EncounterJournal.InstanceHasLoot(journalInstanceID)) then
        EJ_SelectInstance(journalInstanceID)

        local isRaid = EJ_InstanceIsRaid()
        EJ_SetDifficulty(isRaid and (not info.active and 14 or 16) or (not info.active and 23 or 8))

        for i = 1, EJ_GetNumLoot(), 1 do
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)

            if(not itemInfo.name) then
                currentItemIDs[itemInfo.itemID] = {hasData = false, journalInstanceID = journalInstanceID}

            end
        end

        return {journalInstanceID = journalInstanceID}
    end

end

local function findAllRelevantMapIDs(filterID)
    local instanceList = {}
    currentItemIDs = {}

    local dungeonGroup = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.Recommended))
    local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE))
    local seasonGroups = miog.retrieveCurrentRaidActivityGroups()
    local worldBossActivity = C_LFGList.GetAvailableActivities(3, 0, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion))

    local listWithMapIDs = {}
    local seasonalDungeonsDone = {}
    
    if(dungeonGroup and #dungeonGroup > 0) then
        for _, v in ipairs(dungeonGroup) do
            local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
            listWithMapIDs[#listWithMapIDs + 1] = {mapID = activityInfo.mapID, active = true}
            seasonalDungeonsDone[v] = true
        end
    end

    if(expansionGroups and #expansionGroups > 0) then
        for _, v in ipairs(expansionGroups) do
            if(not seasonalDungeonsDone[v]) then
                local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
                listWithMapIDs[#listWithMapIDs + 1] = {mapID = activityInfo.mapID, active = false}
                
            end
        end
    end

    if(seasonGroups and #seasonGroups > 0) then
        for _, v in ipairs(seasonGroups) do
            local activityInfo = miog.ACTIVITY_INFO[miog.GROUP_ACTIVITY[v].activityID]
            listWithMapIDs[#listWithMapIDs + 1] = {mapID = activityInfo.mapID, active = true}

        end
    end

    if(worldBossActivity and #worldBossActivity > 0) then
        for _, v in ipairs(worldBossActivity) do
            local activityInfo = miog.ACTIVITY_INFO[v]

            listWithMapIDs[#listWithMapIDs + 1] = {mapID = activityInfo.mapID, active = false}
        end
    end

    for k, info in ipairs(listWithMapIDs) do
        local tbl = requestAllLootForMapID(info, filterID)

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

local function findApplicablePVEItems(dataProvider, instanceList, itemLevelToBeat)
	local specID = GetSpecializationInfo(GetSpecialization())
    local mainStat = miog.SPECIALIZATIONS[specID].stat

    for instanceIndex, v in ipairs(instanceList) do
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

                        local item = Item:CreateFromItemLink(itemLink)
                        local itemLevel = item:GetCurrentItemLevel()

                        local statTable = C_Item.GetItemStats(itemInfo.link)
                        
                        if(itemLevel >= itemLevelToBeat and (statTable[mainStat] or hasNoMainStatOnIt(statTable))) then
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
                                color = item:GetItemQualityColor()
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

                        --print(filterID, v.itemName, item:GetInventoryType(), item:GetInventoryTypeName(), C_Transmog.GetSlotForInventoryType(type))

                        dataProvider:Insert({
                            template = "MIOG_UpgradeFinderItemSingleTemplate",
                            name = v.itemName,
                            icon = item:GetItemIcon(),
                            rarity = 0,
                            encounterID = nil,
                            difficultyID = nil,
                            itemLink = newLink,
                            isRaid = nil,
                            instanceName = nil,
                            itemlevel = item:GetCurrentItemLevel(),
                            color = item:GetItemQualityColor()
                        })
                    end
                end
            end
        end
    end
end

local function findItems(filterID, itemlevel)
    local instanceList = findAllRelevantMapIDs(filterID)

    local dataProvider = CreateDataProvider()
    dataProvider:SetSortComparator(sortItems)

    findApplicablePVEItems(dataProvider, instanceList, itemlevel)
    findApplicableCraftingItems(dataProvider, filterID, itemlevel)

    miog.UpgradeFinder.ScrollBox:SetDataProvider(dataProvider)

    return dataProvider:GetSize()
end

miog.updateItemList = function(filterID, itemlevel, invSlotID)
    local specID = GetSpecializationInfo(GetSpecialization())
    local _, _, classID = UnitClass("player")

    EJ_SetLootFilter(classID, specID);

    local size = findItems(filterID, itemlevel)

    if(size == 0 and (filterID == 10 or filterID == 11)) then
        local wasMainBefore = filterID == 10
        local newFilterID = wasMainBefore and 11 or 10
        --local newInvSlotID = wasMainBefore and 17 or 16

        --local item = Item:CreateFromEquipmentSlot(newInvSlotID)
        --local newIlvl = item:GetCurrentItemLevel()

        findItems(newFilterID, itemlevel)
        
    end
end