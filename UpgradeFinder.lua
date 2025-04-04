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

local function printAllBonusIDs(link)
    local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
    local array = {strsplit(":", linkOptions)}
	local numBonusIDs = tonumber(array[13])

    print("------- " .. displayText .. ", " .. getEnumKeyForContext(tonumber(array[12])) .. " -------")

    for i = 14, 13 + numBonusIDs, 1 do
        local bonusID = tonumber(array[i])

        local actualBonusID = findActualBonusID(bonusID)
        local bonusIDType = findBonusIDType(actualBonusID)
    end
end

miog.printAllBonusIDs = printAllBonusIDs

-- champion track bonus start id =????? 3524
-- hero track bonus start id =????? 

--[[

    hero 1/6 11985
    hero 6/6 11990

]]

--[[
    not
    10396
    6652
    11343
    10390
    11964
    10383

]]

--[[
    maybe mandatory

    10390
    6652
    10383
    11988

]]

local function setItemLinkArrayToSpecificItemLevel(link, ilvl, linkIsArray)
    local array
    local linkType, linkOptions, displayText

    if(not linkIsArray) then
        linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
        array = {strsplit(":", linkOptions)}

    else
        array = link

    end

    array[12] = 33

    --table.insert(array, 14, 12042)
    local bestBonusID = findCorrectBonusID(655 - ilvl)
    table.insert(array, 14, 11985)
    table.insert(array, 15, bestBonusID)

    array[13] = tonumber(array[13]) + 2

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

	local numBonusIDs = tonumber(array[13])

    local toBeRemoved = {}

    for i = 14, 13 + numBonusIDs, 1 do
        local bonusID = tonumber(array[i])

        local actualBonusID = findActualBonusID(bonusID)
        local bonusIDType = findBonusIDType(actualBonusID)
        
        if(bonusIDType == 1 or bonusIDType == 42) then -- remove anything with base itemlevel, item level addition or subtraction
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

local function removeAndSetItemLinkItemLevels(link)
    local linkType, linkOptions, displayText = LinkUtil.ExtractLink(link)
    local array = {strsplit(":", linkOptions)}

    local removedArray = removeItemLevelsFromItemLink(array, true)

    local _, _, ilvl = C_Item.GetDetailedItemLevelInfo(link)

    local setArray = setItemLinkArrayToSpecificItemLevel(removedArray, ilvl, true)

    return LinkUtil.FormatLink(linkType, displayText, unpack(setArray))
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
        frame.BasicInformation.Instance:SetText(elementData.instanceName)

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

miog.loadUpgradeFinder = function()
    local upgradeFinder = miog.pveFrame2.TabFramesPanel.UpgradeFinder

    local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 2)
    view:SetPadding(1, 1, 1, 1, 4)

    view:SetElementFactory(CustomFactory)
    
    ScrollUtil.InitScrollBoxListWithScrollBar(upgradeFinder.ScrollBox, upgradeFinder.ScrollBar, view)

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
        EJ_SetDifficulty(isRaid and (not info.active and 14 or 16) or (not info.active and 8 or 23))

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

local function findApplicableItems(instanceList, itemLevelToBeat)
	local specID = GetSpecializationInfo(GetSpecialization())

    local mainStat = miog.SPECIALIZATIONS[specID].stat

    local dataProvider = CreateDataProvider()
    dataProvider:SetSortComparator(sortItems)

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
                            local newLink = removeAndSetItemLinkItemLevels(itemInfo.link)

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
                                encounterID = itemInfo.encounterID,
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

    miog.UpgradeFinder.ScrollBox:SetDataProvider(dataProvider)
end

miog.updateItemList = function(filterID, itemlevel)
    local instanceList = findAllRelevantMapIDs(filterID)

    findApplicableItems(instanceList, itemlevel)
end