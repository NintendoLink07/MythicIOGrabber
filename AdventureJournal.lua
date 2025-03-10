local addonName, miog = ...

local regex1 = "%d+ [D-d]amage"
local regex2 = "%d+ %w+ [D-d]amage"
local regex3 = "%d+ %w+ %w+ [D-d]amage"

local selectedInstance, expansionTable, selectedEncounter

local journalInfo = {}

local basePool, modelPool, difficultyPool, switchPool
local changingKeylevel = false
local currentModels = {}
local lootWaitlist = {}

local currentItemTable = {}
local selectedItemClass, selectedItemSubClass
local selectedArmor, selectedClass, selectedSpec

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

local difficultyIDs = {
    raid = {
        17,
        14,
        15,
        16
    },
    oldRaid = {
        3,
        4,
        5,
        6
    },
    dungeon = {
        1,
        2,
        23,
        8
    }
}

local function resetModelFrame(_, frame)
    frame:Hide()
    frame.layoutIndex = nil
    frame.name = nil
    frame.id = nil
    frame.description = nil
    frame.displayInfo = nil
    frame.uiModelSceneID = nil

end

local function resetSlotLine(_, frame)
    frame:Hide()
    frame.layoutIndex = nil
    frame.Name:SetText()
end

local function resetLootItemFrames(frame, data)
    --frame:Hide()
    --frame.layoutIndex = nil
    if(data.template == "MIOG_AdventureJournalLootItemTemplate") then
        frame.itemLink = nil
        frame.BasicInformation.Name:SetText("")
        frame.BasicInformation.Icon:SetTexture(nil)

        frame:SetScript("OnEnter", nil)

        frame.BasicInformation.Item1:SetTexture(nil)
        frame.BasicInformation.Item1:SetScript("OnEnter", nil)
        frame.BasicInformation.Item1.itemLink = nil

        frame.BasicInformation.Item2:SetTexture(nil)
        frame.BasicInformation.Item2:SetScript("OnEnter", nil)
        frame.BasicInformation.Item2.itemLink = nil

        frame.BasicInformation.Item3:SetTexture(nil)
        frame.BasicInformation.Item3:SetScript("OnEnter", nil)
        frame.BasicInformation.Item3.itemLink = nil

        frame.BasicInformation.Item4:SetTexture(nil)
        frame.BasicInformation.Item4:SetScript("OnEnter", nil)
        frame.BasicInformation.Item4.itemLink = nil
    end
end

local frameWidth

local function resetJournalFrames(_, frame)
    frame:Hide()
    frame.layoutIndex = nil

    frame.Icon:SetTexture(nil)
    frame.Title:SetText("")

    frame.Base.Name:SetText("")
    frame.Base.Description:SetText("")

    frame.Diff1.Name:SetText("")
    frame.Diff1.Description:SetText("")

    frame.Diff2.Name:SetText("")
    frame.Diff2.Description:SetText("")

    frame.Diff3.Name:SetText("")
    frame.Diff3.Description:SetText("")

    frame.Diff4.Name:SetText("")
    frame.Diff4.Description:SetText("")
end

local function resetSwitchFrames(_, frame)
    frame:Hide()
    frame.layoutIndex = nil

end

local function resetDifficultyFrames(_, frame)
    frame.Name:SetText((""))
    frame.Description:SetText((""))
end

local frameData = {}
local organizedFrameData = {}
local currentDifficultyIDs
local currentEncounterID

local function calculateNumberIncrease(number)
    for i = 2, miog.AdventureJournal.SettingsBar.KeylevelDropdown:GetSelectedValue(), 1 do
        if(i == 2) then
            
        elseif(i > 2 and i < 10) then
            number = number * 1.08

        else
            number = number * 1.1
        
        end
    end

    return miog.format_num(miog.round(number, 2))
end

local function compareArrayValues(array, value)
    local equals = true
    local index  = 1
  
    while (equals and (index <= #array)) do
        if array[index] == value then
            index = index + 1

        else
            equals = false

        end
    end
  
    return equals
end

local function forwardOrderedValues(array)
    local equals = true

    if(#array > 1) then
        for i = #array, 2, -1 do
            if(array[i] >= array[i - 1]) then
                
            else
                return false
            end
        end
    end
    
    return equals
end

local function GetEJDifficultySize(difficultyID)
	if difficultyID ~= DifficultyUtil.ID.RaidTimewalker and not DifficultyUtil.IsPrimaryRaid(difficultyID) then
		return DifficultyUtil.GetMaxPlayers(difficultyID);
	end
	return nil;
end

local function GetEJDifficultyString(difficultyID)
	local name = DifficultyUtil.GetDifficultyName(difficultyID);
	local size = GetEJDifficultySize(difficultyID);
	if size then
		return string.format(ENCOUNTER_JOURNAL_DIFF_TEXT, size, name);
	else
		return name;
	end
end

local function createBaseString(id, lowestIndex)
    local baseArray = {}
    local shift = 0

    for n = lowestIndex, #currentDifficultyIDs, 1 do
        local array1 = frameData[id][currentDifficultyIDs[n]] and miog.simpleSplit(frameData[id][currentDifficultyIDs[n]].description, "%s") or {}
        local array2 = frameData[id][currentDifficultyIDs[n + 1]] and miog.simpleSplit(frameData[id][currentDifficultyIDs[n + 1]].description, "%s") or {}

        for k, v in ipairs(array2) do
            local firstCurrentValue = array1[k]
            local firstFutureValue = array1[k + 1]

            local thirdCurrentValue = array2[k + shift]

            if(firstCurrentValue and thirdCurrentValue) then

                for i = k + shift, #array2, 1 do
                    if(firstCurrentValue == array2[i]) then
                        --baseArray[k] = false

                        break

                    else
                        baseArray[i] = false
                        --else

                        --end

                        if(array2[i + 1] == "million" or array2[i + 1] == "billion") then
                            --table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = array2[i] .. " " .. table.remove(array2, i + 1), colorIndex = xCounter})
                            table.remove(array2, i + 1)
                        
                        end

                        if(firstFutureValue == array2[i + 1]) then
                            break
                        else

                            shift = shift + 1
                        end
                    end
                end
            end
        end
    end

    return baseArray
end

local function stopAndGo(id, equal, forwardOrdered)
    local lowestIndex = 1000
    
    for k, v in ipairs(currentDifficultyIDs) do
        if(frameData[id][v] and k < lowestIndex) then
            lowestIndex = k

        end
    end
    
    local lowestDifficulty = currentDifficultyIDs[lowestIndex]

    local baseArray = createBaseString(id, lowestIndex)

    local xCounter = 1
    local baseString = ""

    if(frameData[id][lowestDifficulty]) then
        local lastIndex = 0

        for k, v in ipairs(miog.simpleSplit(frameData[id][lowestDifficulty].description, "%s")) do
            if(baseArray[k] ~= false) then
                baseString = baseString .. v .. " "
                
            else
                if(lastIndex == k - 1) then
                    
                else
                    if(xCounter > 10) then
                        xCounter = 1
                    end

                    baseString = baseString .. WrapTextInColorCode("[" .. xCounter .. "]", miog.AJ_CLRSCC[xCounter]) .. " "
                    xCounter = xCounter + 1

                end

                lastIndex = k
            
            end

        end
    end

    if(equal) then
        for n = lowestIndex, #currentDifficultyIDs, 1 do
            local array1 = miog.simpleSplit(baseString, "%s") or {}
            local array2 = frameData[id][currentDifficultyIDs[n]] and miog.simpleSplit(frameData[id][currentDifficultyIDs[n]].description, "%s") or {}
    
            local shift = 0

            local xCounter = 1

            for k, v in ipairs(array2) do
                local firstCurrentValue = array1[k]
                local firstFutureValue = array1[k + 1]

                local thirdCurrentValue = array2[k + shift]

                if(firstCurrentValue and thirdCurrentValue) then
                    for i = k + shift, #array2, 1 do
                        if(xCounter > 10) then
                            xCounter = 1
                        end

                        --local thirdFutureValue = array2[i]
                        
                        if(firstCurrentValue == array2[i]) then
                            if(n == 1) then
                                --baseString = baseString .. firstCurrentValue .. " "
                                --baseArray[i] = false
                            end

                            break

                        else
                            if(n == 1) then
                                --table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = array1[i], colorIndex = xCounter})
                                --baseString = baseString .. WrapTextInColorCode("[" .. xCounter .. "]", miog.AJ_CLRSCC[xCounter]) .. " "
                                --baseArray[i] = true
                                
                            end

                            if(n == 4 and currentDifficultyIDs[4] == 8) then
                                local withoutComma = string.gsub(array2[i], ",", "")
                                local maybeNumber = tonumber(withoutComma)

                                local scaledNumber, found

                                if(maybeNumber and array2[i + 1] and array2[i + 2]) then
                                    local threeString = maybeNumber .. " " .. array2[i + 1] .. " " .. array2[i + 2]
                                    found = string.find(threeString, regex2)

                                elseif(maybeNumber and array2[i + 1]) then
                                    local twoString = maybeNumber .. " " .. array2[i + 1]
                                    found = string.find(twoString, regex1)

                                end

                                if(found) then
                                    scaledNumber = calculateNumberIncrease(maybeNumber)
                                    
                                end

                                table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = scaledNumber or array2[i], colorIndex = xCounter})

                            else
                                
                                table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = array2[i], colorIndex = xCounter})
                            
                            end

                            if(firstFutureValue == array2[i + 1]) then
                                xCounter = xCounter + 1
                                break

                            else
                                shift = shift + 1

                            end
                        end
                    end
                elseif(thirdCurrentValue) then
                    table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = thirdCurrentValue, colorIndex = xCounter})

                elseif(firstCurrentValue) then
                    --table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = firstCurrentValue, colorIndex = xCounter})

                end
            end
        end
    else

        local frameDataArrays = {}
    
        for n = lowestIndex, #currentDifficultyIDs, 1 do
            if(frameData[id][currentDifficultyIDs[n]]) then
                local array = frameData[id][currentDifficultyIDs[n]] and miog.simpleSplit(frameData[id][currentDifficultyIDs[n]].description, "%s")

                if(array) then
                    frameDataArrays[n] = array
                end
            end
        end

        if(forwardOrdered) then
            for n = lowestIndex, #currentDifficultyIDs, 1 do
                --frameDataArrays[n]
                local array1 = miog.simpleSplit(baseString, "%s") or {}
                local array2 = frameDataArrays[n] or {}

                local shift = 0
                local xCounter = 1
                
                for k, v in ipairs(array2) do
                    local firstCurrentValue = array1[k]
                    local firstFutureValue = array1[k + 1]
    
                    local thirdCurrentValue = array2[k + shift]
                    --local thirdFutureValue = higherArray[k + shift + 1]
    
                    if(firstCurrentValue and thirdCurrentValue) then
                        for i = k + shift, #array2, 1 do
                            if(xCounter > 10) then
                                xCounter = 1
                            end

                            if(firstCurrentValue == array2[i]) then
                                if(n == 1) then
                                    --baseString = baseString .. firstCurrentValue .. " "
                                    --baseArray[i] = false

                                end
    
                                break
    
                            else

                                if(n == 1) then
                                    --table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = array1[i], colorIndex = xCounter})
                                    --baseString = baseString .. WrapTextInColorCode("[" .. xCounter .. "]", miog.AJ_CLRSCC[xCounter]) .. " "
                                    --baseArray[i] = true
                                
                                end

                                if(n == 4 and currentDifficultyIDs[4] == 8) then
                                    local withoutComma = string.gsub(array2[i], ",", "")
                                    local maybeNumber = tonumber(withoutComma)

                                    local scaledNumber, found

                                    if(maybeNumber) then
                                        if(array2[i + 1] and array2[i + 2] and array2[i + 3]) then
                                            local fourString = maybeNumber .. " " .. array2[i + 1] .. " " .. array2[i + 2] .. " " .. array2[i + 3]
                                            found = string.find(fourString, regex3)

                                        elseif(array2[i + 1] and array2[i + 2]) then
                                            local threeString = maybeNumber .. " " .. array2[i + 1] .. " " .. array2[i + 2]
                                            found = string.find(threeString, regex2)

                                        elseif(array2[i + 1]) then
                                            local twoString = maybeNumber .. " " .. array2[i + 1]
                                            found = string.find(twoString, regex1)
                                        end

                                        if(found) then
                                            scaledNumber = calculateNumberIncrease(maybeNumber)
                                            
                                        end
                                    end

                                    table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = scaledNumber or array2[i], colorIndex = xCounter})

                                else
                                    table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = array2[i], colorIndex = xCounter})
                                    
                                end
    
                                if(firstFutureValue == array2[i + 1]) then
                                    xCounter = xCounter + 1
                                    break
                                else
                                    shift = shift + 1
                                end
                            end
                        end
                    elseif(thirdCurrentValue) then
                        table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = thirdCurrentValue, colorIndex = xCounter})

                    elseif(firstCurrentValue) then
                        --table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = firstCurrentValue, colorIndex = xCounter})

                    end
                end
            end
        else
            for n = lowestIndex, #currentDifficultyIDs, 1 do
                xCounter = 1
    
                --table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = frameData[id][currentDifficultyIDs[n]].description})
                
                local array = frameDataArrays[n]

                for k, v in ipairs(array) do
                    if(xCounter > 10) then
                        xCounter = 1
                    end

                    local withoutComma = string.gsub(v, ",", "")
                    local maybeNumber = tonumber(withoutComma)

                    if(maybeNumber) then
                        table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = FormatLargeNumber(maybeNumber), colorIndex = xCounter})
                        
                    else
                        table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = v})
                    
                    end
                    
                end
            end
        end
    end

    return baseString
end

local function checkForBossInfo(journalInstanceID)
    local bossTable = {}
    local firstBossID = nil

    for i = 1, 50, 1 do
        local info = {}
        local name, description, journalEncounterID, rootSectionID, link, journalInstanceID2, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(i, selectedInstance or journalInstanceID)

        if(name) then
            info.index = i
            info.entryType = "option"
            info.text = name
            info.value = journalEncounterID
            info.func = function()

            end

            if(#bossTable == 0) then
                firstBossID = journalEncounterID

            end

            bossTable[#bossTable+1] = info
        end
    end

    return bossTable, firstBossID
end

local function retrieveDifficultyIDs()
    currentDifficultyIDs = {}

    for i, difficultyID in ipairs(EJ_DIFFICULTIES) do
        if EJ_IsValidInstanceDifficulty(difficultyID) then
            table.insert(currentDifficultyIDs, difficultyID)
        end
    end
end

local function selectInstance(journalInstanceID)
    selectedInstance = journalInstanceID
    selectedEncounter = nil

    EJ_SelectInstance(selectedInstance)

    retrieveDifficultyIDs()
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

local function requestCurrentDifficultyItemsFromCurrentEncounter(difficultyIndex)
    EJ_SetDifficulty(currentDifficultyIDs[difficultyIndex])

    miog.AdventureJournal.ScrollBox:GetDataProvider():Flush()
    local dataProvider = CreateDataProvider();
    --[[dataProvider:SetSortComparator(function(k1, k2)
        if(k1 and k2) then

            if(k1.index == k2.index) then
                return k1.header or not k1.header

            end

            return k1.index > k2.index
        end
    end)]]

    local usedSlots = {}
    local noFilter = C_EncounterJournal.GetSlotFilter() == 15

    for n = 1, EJ_GetNumLoot(), 1 do
        local itemInfo = C_EncounterJournal.GetLootInfoByIndex(n)
            
        currentItemTable[itemInfo.itemID] = currentItemTable[itemInfo.itemID] or {}

        if((noFilter and selectedArmor == nil or checkIfItemIsFiltered(itemInfo)) and itemInfo.name) then
            local slot = itemInfo.slot == "" and "Other" or itemInfo.slot
            
            currentItemTable[itemInfo.itemID].links = currentItemTable[itemInfo.itemID].links or {}

            --itemLinks[itemInfo.name] = itemLinks[itemInfo.name] or {}

            if(not usedSlots[itemInfo.filterType]) then
                dataProvider:Insert({
                    template = "MIOG_AdventureJournalLootSlotLineTemplate",
                    name = slot,
                    index = itemInfo.filterType,
                    header = true
                })

                usedSlots[itemInfo.filterType] = "used"
            end

            currentItemTable[itemInfo.itemID].links[EJ_GetDifficulty()] = itemInfo.link

            dataProvider:Insert({
                template = "MIOG_AdventureJournalLootItemTemplate",
                name = itemInfo.name,
                icon = itemInfo.icon,
                itemID = itemInfo.itemID,
                slot = slot,
                index = itemInfo.filterType,
                --links = itemLinks[itemInfo.name],
                header = false,
            })

        else
            lootWaitlist[itemInfo.itemID] = false

        end

    end

    if(dataProvider:GetSize() == 0) then
        dataProvider:Insert({
            template = "MIOG_AdventureJournalLootSlotLineTemplate",
            name = "No loot available for this slot",
        })
    end

    miog.AdventureJournal.ScrollBox:SetDataProvider(dataProvider);
end

local function requestAllItemsFromCurrentEncounter()
    for x = 1, #currentDifficultyIDs, 1 do
        requestCurrentDifficultyItemsFromCurrentEncounter(x)

    end
end

local function showModel(uiModelSceneID, creatureDisplayID, forceUpdate)
    miog.AdventureJournal.ModelScene.Frame:SetFromModelSceneID(uiModelSceneID, forceUpdate);

    local creature = miog.AdventureJournal.ModelScene.Frame:GetActorByTag("creature");
    if creature then
        creature:SetModelByCreatureDisplayID(creatureDisplayID, forceUpdate);

    end
end

local function retrieveEncounterCreatureInfo()
    modelPool:ReleaseAll()

    local id, name, displayInfo, iconImage, uiModelSceneID, description

	for i = 1, 9, 1 do
		id, name, description, displayInfo, iconImage, uiModelSceneID = EJ_GetCreatureInfo(i)

		if id then
			local button = modelPool:Acquire()
            button.layoutIndex = i
			SetPortraitTextureFromCreatureDisplayID(button.creature, displayInfo)
			button.name = name
			button.id = id
			button.description = description
			button.displayInfo = displayInfo
			button.uiModelSceneID = uiModelSceneID
            button:SetScript("OnClick", function(self)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)

                if(self.uiModelSceneID and self.displayInfo) then
                    showModel(self.uiModelSceneID, self.displayInfo, true)

                end
            end)

            button:Show()

            table.insert(currentModels, button)
		end
	end

    miog.AdventureJournal.ModelScene.List.Container:MarkDirty()
end

local function compareTexts(needles, haystack)
    local text = ""

    local needleArray = miog.simpleSplit(needles, "%s") or {}
    local haystackArray = miog.simpleSplit(haystack, "%s") or {}

    local array = {}

    local isNextEqualAgain = false
    local counter = 1

    for index, needle in ipairs(needleArray) do
        if(needle == haystackArray[index]) then
            text = text .. needle .. " "
            
        else
            text = text .. "[" .. counter .. "] "
            counter = counter + 1

            tinsert(array, needle)

            isNextEqualAgain = haystackArray[index + 1] == needleArray[index + 1]

            if(isNextEqualAgain) then
                

            end
        end
    end
   
    --print(counter > 1, text)

    return counter > 1, array, text
end

local function compareTexts2(needles, haystackString)
    local haystackArray = miog.simpleSplit(haystackString, "%s")

    local text = ""

    local differences = {}
    local counter = 1

    for needle in needles:gmatch("%S+") do
        local result = miog.fzy.has_match(needle, haystackString, true)

        if(result) then
            text = text .. needle .. " "

        else
            text = text .. "[HERE-" .. counter .. "] "
            tinsert(differences, {needle = needle, haystack = haystackArray[counter]})

        end

        counter = counter + 1
    end

    return differences, text
end

local function findNumberInText(text)
    for word in text:gmatch("%S+") do
        if(tonumber(word)) then
            print(word)
        end
    end
end

local function compareAllAvailableDescriptions(array)

end

local function selectEncounter(encounterID)
    selectedEncounter = encounterID
    EJ_SelectEncounter(selectedEncounter)

    local stack = {}
    local sectionInfo = {}

    local oneIsMissing = false

    for k, v in ipairs(currentDifficultyIDs) do
        EJ_SetDifficulty(v)

        local _, _, _, rootSectionID = EJ_GetEncounterInfo(encounterID)

        repeat
            local info = C_EncounterJournal.GetSectionInfo(rootSectionID)

            if(info) then
                sectionInfo[rootSectionID] = sectionInfo[rootSectionID] or {}

                table.insert(stack, info.siblingSectionID)

                if(info.title) then
                    if(info.title ~= "Overview") then
                        table.insert(stack, info.firstChildSectionID)

                    end

                    --oneIsMissing = info.description == nil

                    --if(info.filteredByDifficulty ~= true) then
                        if(info.description ~= "") then
                            info.difficulty = v
                            info.rootSectionID = rootSectionID
                            --info.difficultyData = {}
            
                            table.insert(sectionInfo[rootSectionID], info)
                        end


                    --end
                end

            end
            
            rootSectionID = table.remove(stack)
        until not rootSectionID
    end

    --[[if(oneIsMissing) then
        C_Timer.After(2, function()
            print("RESET")
            selectEncounter(encounterID)
        end)
    end]]

    --DevTools_Dump(sectionInfo[30135])

    local info1, info2
    local sectionText
    local mainOffset, otherOffset
    local finalText

    --local sectionDiffArray = {}
    --local sectionID = 30135
    --local v = sectionInfo[sectionID]

    local provider = CreateDataProvider()

    local compareLowestAndHighest = false

    for sectionID, v in pairs(sectionInfo) do
        finalText = ""

        local noChange = true

        for k, sectionData in ipairs(v) do

            if(#v == 1) then
                finalText = sectionData.description

            else
                sectionText = ""

                if(sectionData.spellID == 385574) then
                    --print(sectionData.description)
                end
    
                info1 = v[compareLowestAndHighest and k or 1]
                info2 = v[k + 1]
    
                if(compareLowestAndHighest and info1 and not info2 and k == #v) then
                    info2 = v[1]
    
                end
    
                if(info1 and info2) then
                    local currentSize
                    local diffArray1, diffArray2, sameArray = TEXTCOMP_COMPARETEXTS(info1.description, info2.description)

                    if(#diffArray1 > 0 or #diffArray2 > 0) then
                        noChange = false
                    end

                    if(sectionData.spellID == 434776 and info2.difficulty == 16) then
                        --DevTools_Dump(diffArray1)
                        --DevTools_Dump(diffArray2)
                    end
    
                    --tinsert(sectionData.difficultyData, diffArray)
    
                    --if(sectionData.spellID == 445268) then
                        local tempText = ""
    
                        for x, y in ipairs(diffArray1) do
                            currentSize = #y
    
                            for a, b in ipairs(y) do
                                if(b.needle) then
                                    tempText = tempText .. b.needle .. " "
    
                                end
                            end
    
                            --print(info1.difficulty, x, tempText)
                        end
    
                        if(not compareLowestAndHighest and k == 1) then
                            info1.difficultyText = tempText
    
                            local tempFinalText
    
                            for x, y in ipairs(sameArray) do
                                tempFinalText = nil
    
                                for a, b in ipairs(y) do
                                    if(b.needle) then
                                        tempFinalText = tempFinalText and (tempFinalText .. " " .. b.needle) or b.needle
        
                                    end
                                end
    
                                if(tempFinalText) then 
                                    if(x ~= #sameArray) then
                                        tempFinalText = tempFinalText .. "."
    
                                    end
    
                                    finalText = finalText .. tempFinalText .. "\n\r"
    
                                end
        
                                --print("SAME", tempText)
    
                            end
                        end
    
                        tempText = ""
    
                        if(info2.difficulty == 16) then
                            --DevTools_Dump(diffArray2)
                        end
    
                        for x, y in ipairs(diffArray2) do
                            if(currentSize ~= #y) then
                                sameSize = false
                            end
    
                            for a, b in ipairs(y) do
                                if(b.needle) then
                                    tempText = tempText .. b.needle .. " "
    
                                end
                            end
    
                            --print(info2.difficulty, x, tempText)
                        end
    
                        info2.difficultyText = tempText
    
                        --print("WAS THE SAME SIZE?", sameSize)
                            --print(sectionData.description)
                    --end
                    --[[otherOffset, mainOffset = 0, 0
                    
                    local needleArray = miog.simpleSplit(info1.description, "%s") or {}
                    local haystackArray = miog.simpleSplit(info2.description, "%s") or {}
                
                    local isNextEqualAgain = false
                    local counter = 1
                    local mainArray = needleArray
                    local otherArray = haystackArray
                
                    for index, needle in ipairs(mainArray) do
                        local needleWithOffset = mainArray[index + mainOffset]
    
                        if(needleWithOffset) then
                            if(needleWithOffset == otherArray[index + otherOffset]) then
                                sectionText = sectionText .. needleWithOffset .. " "
                                
                            else
                                sectionText = sectionText .. "[" .. counter .. "] "
    
                                tinsert(sectionData.difficultyData, {needle = needleWithOffset, index = counter})
                                counter = counter + 1
                    
                                isNextEqualAgain = otherArray[index + otherOffset + 1] == mainArray[index + mainOffset + 1]
                    
                                if(isNextEqualAgain) then
                                    
                    
                                else
                                    if(otherArray[index + otherOffset + 1] == "million") then
                                        otherOffset = otherOffset + 1
    
                                    --elseif(#mainArray > #otherArray and mainArray[index + mainOffset + 1] == "million") then
                                        --mainOffset = mainOffset + 1
    
                                    end
                                end
                            end
                        end
                    end]]
    
                    --finalText = sameText
    
                    --sectionData.difficultyData.text = diffText
    
                    --sectionData.difficultyText = diffText
                end

            end
        end


        --[[

        for k, _ in ipairs(v) do
            sectionText = ""

            info1 = finalText and {description = finalText} or v[k]
            info2 = v[k + 1]

            if(info1 and not info2 and k == #v) then
                info2 = v[1]

            end
            
            if(info1 and info2) then
                local needleArray = miog.simpleSplit(info1.description, "%s") or {}
                local haystackArray = miog.simpleSplit(info2.description, "%s") or {}

                local isNextEqualAgain = false
                local counter = 1

                for index, needle in ipairs(needleArray) do
                    if(needle == haystackArray[index]) then
                        sectionText = sectionText .. needle .. " "
                        
                    else
                        sectionText = sectionText .. "[" .. counter .. "] "

                        counter = counter + 1
            
                        isNextEqualAgain = haystackArray[index + 1] == needleArray[index + 1]
            
                        if(isNextEqualAgain) then
                            
            
                        end
                    end
                end

                finalText = sectionText
            end
        end]]
        
        provider:Insert({sectionInfo = v, base = finalText})
    end

    for index, data in ipairs(provider.collection) do
        if(#data.sectionInfo > 0) then
            local frame = basePool:Acquire()

            frame.layoutIndex = index
            frame.fixedWidth = frameWidth

            frame.Title:SetText(data.sectionInfo[1].title .. ", " .. data.sectionInfo[1].spellID)
            frame.Base.Description:SetText(data.base)
            frame.Base:MarkDirty()
            frame.Icon:SetTexture(data.sectionInfo[1].abilityIcon)


            for k, v in ipairs(currentDifficultyIDs) do
                frame["Diff" .. k].Name:SetText(GetEJDifficultyString(v))
            end

            for k, v in ipairs(data.sectionInfo) do
                frame.Title:SetText(frame.Title:GetText() .. " " .. v.difficulty)

                local diffFrame = frame["Diff" .. k]

                if(v.difficultyText == "") then
                    v.difficultyText = "This mechanic is implemented on " .. diffFrame.Name:GetText()
                    --print("EMPTY", data.sectionInfo[1].title)

                elseif(v.difficultyText == nil) then
                    print("NIL", data.sectionInfo[1].title)

                else

                end

                diffFrame.Description:SetText(v.difficultyText)
                diffFrame:MarkDirty()
            end

            frame:MarkDirty()
            frame:Show()
        end
    end
    --miog.AdventureJournal.ScrollBox:SetDataProvider(provider)

    --DevTools_Dump(sectionDiffArray)

    --434776

    --[[
    local differences = {}
    local a1, a2
    
    for k, v in pairs(sectionInfo) do
        print("--------")
        local sectionText

        for index, info in ipairs(v) do
            differences[info.spellID] = differences[info.spellID] or {}
            differences[info.spellID][info.difficulty] = differences[info.spellID][info.difficulty] or {}

            a1 = v[index]
            a2 = v[index + 1]

            if(a1 and not a2 and index == #v) then
                a2 = v[1]

            end

            if(a1 and a2) then
                --print(a1.difficulty, a2.difficulty)
                local difference, array, text = compareTexts(a1.description, a2.description)

                -- ARRAY RETURNS ALL ORIGINAL THINGIES FROM A1

                sectionText = text
            end
        end
    end]]

    --[[for k, v in pairs(sectionInfo) do
        local a1, a2

        for difficultyID, info in pairs(v) do
            differences[info.spellID] = differences[info.spellID] or {}
            differences[info.spellID][difficultyID] = differences[info.spellID][difficultyID] or {}

            if(not a1) then
                a1 = info
                a1.currentDiff = difficultyID

            elseif(not a2) then
                a2 = info
                a2.currentDiff = difficultyID

            else
                a1 = a2

                a2 = info
                a2.currentDiff = difficultyID

            end

            if(a1 and a2) then
                local diff, text = compareTexts2(a1.description, a2.description)
                compareTexts(a1.description, a2.description)

                if(#diff > 0) then
                    for x, y in ipairs(diff) do
                        tinsert(differences[info.spellID][a1.currentDiff], y.needle)
                        tinsert(differences[info.spellID][a2.currentDiff], y.haystack)

                        --differences[info.spellID][a1.currentDiff].originals[y.needle] = true
                        --differences[info.spellID][a1.currentDiff][a2.currentDiff] = differences[info.spellID][a1.currentDiff][a2.currentDiff] or {}
                        --tinsert(differences[info.spellID][a1.currentDiff][a2.currentDiff], y.needle)

                        --differences[info.spellID][a2.currentDiff].originals[y.haystack] = true
                        --differences[info.spellID][a2.currentDiff][a1.currentDiff] = differences[info.spellID][a2.currentDiff][a1.currentDiff] or {}
                        --tinsert(differences[info.spellID][a2.currentDiff][a1.currentDiff], y.haystack)
                    end

                    --differences[info.spellID][a1.currentDiff]["text"..tostring(a2.currentDiff)] = text
                    --differences[info.spellID][a2.currentDiff]["text"..tostring(a1.currentDiff)] = text

                end
            end
        end
    end]]

    --[[
    
    for k, v in pairs(sectionInfo) do
        diffSwitch = false
        local a1, a2

        for difficultyID, info in pairs(v) do
            differences[difficultyID] = differences[difficultyID] or {}
            differences[difficultyID][info.spellID] = differences[difficultyID][info.spellID] or {}

            if(not a1) then
                a1 = info
                a1.currentDiff = difficultyID

            elseif(not a2) then
                a2 = info
                a2.currentDiff = difficultyID

            else
                if(diffSwitch) then
                    a1 = info
                    a1.currentDiff = difficultyID

                    diffSwitch = true
                else
                    a2 = info
                    a2.currentDiff = difficultyID

                end

            end

            if(a1 and a2) then
                local diff, text = compareTexts2(a1.description, a2.description)

                if(#diff > 0) then
                    for x, y in ipairs(diff) do
                        differences[a1.currentDiff][info.spellID][a2.currentDiff] = differences[a1.currentDiff][info.spellID][a2.currentDiff] or {}
                        tinsert(differences[a1.currentDiff][info.spellID][a2.currentDiff], y.needle)

                        differences[a2.currentDiff][info.spellID][a1.currentDiff] = differences[a2.currentDiff][info.spellID][a1.currentDiff] or {}
                        tinsert(differences[a2.currentDiff][info.spellID][a1.currentDiff], y.haystack)
                    end

                    differences[a1.currentDiff][info.spellID][a2.currentDiff].text = text
                    differences[a2.currentDiff][info.spellID][a1.currentDiff].text = text

                end
            end
        end
    end
    
    ]]
end

miog.selectBoss = function(journalEncounterID, abilityTitle)
    if(not abilityTitle or abilityTitle and currentEncounterID ~= journalEncounterID) then
        selectedBoss = journalEncounterID

        --C_EncounterJournal.SetPreviewMythicPlusLevel(miog.AdventureJournal and miog.AdventureJournal.SettingsBar.KeylevelDropdown:GetSelectedValue() or 0)
        basePool:ReleaseAll()
        difficultyPool:ReleaseAll()
        switchPool:ReleaseAll()

        currentEncounterID = journalEncounterID
        
        EJ_SelectEncounter(currentEncounterID)

        frameData = {}
        organizedFrameData = {}
        currentModels = {}
        local stack = {}

        miog.AdventureJournal.Status:SetColorTexture(0, 1, 0)

        retrieveEncounterCreatureInfo()

        if(#currentModels > 0) then
            showModel(currentModels[1].uiModelSceneID, currentModels[1].displayInfo, true)
        end

        miog.AdventureJournal.AbilitiesFrame.Status:Hide()
        
        for x = 1, #currentDifficultyIDs, 1 do
            requestCurrentDifficultyItemsFromCurrentEncounter(x)

            local _, _, _, originalRootID = EJ_GetEncounterInfo(currentEncounterID)

            local counter = 1

            local rootSectionID = originalRootID

            if(rootSectionID and rootSectionID ~= 0) then
                repeat
                    local info = C_EncounterJournal.GetSectionInfo(rootSectionID)
                    
                    if(info) then
                        table.insert(stack, info.siblingSectionID)

                        if(info.title) then
                            if(info.title == "Overview") then

                            else
                                frameData[info.title] = frameData[info.title] or {}
                                
                                counter = counter + 1
                                table.insert(stack, info.firstChildSectionID)
                                local notFiltered = not info.filteredByDifficulty

                                if(notFiltered) then
                                    frameData[info.title][currentDifficultyIDs[x]] = {
                                        title = info.title,
                                        headerType = info.headerType,
                                        abilityIcon = info.abilityIcon,
                                        spellID = info.spellID,
                                        index = counter
                                    }

                                    if(info.description ~= "") then
                                        local desc = string.gsub(info.description, "|[cC]%x%x%x%x%x%x%x%x", "")
                                        desc = string.gsub(desc, "|T(.+)|t", "")

                                        
                                        frameData[info.title][currentDifficultyIDs[x]].description = desc
                                    
                                    else
                                        frameData[info.title][currentDifficultyIDs[x]].description = RETRIEVING_DATA
                                        local currentSectionID, currentTitle, currentDifficultyID = rootSectionID, info.title, currentDifficultyIDs[x]
                                    
                                        C_Timer.After(0.2, function()
                                            EJ_SetDifficulty(currentDifficultyID)
                                            local newInfo = C_EncounterJournal.GetSectionInfo(currentSectionID)

                                            if(newInfo.description ~= "") then
                                                local desc = string.gsub(newInfo.description, "|[cC]%x%x%x%x%x%x%x%x", "")
                                                --desc = string.gsub(desc, "|T(.+)|t", "")

                                                frameData[currentTitle][currentDifficultyID] = {
                                                    title = newInfo.title,
                                                    headerType = newInfo.headerType,
                                                    abilityIcon = newInfo.abilityIcon,
                                                    spellID = newInfo.spellID,
                                                    index = counter
                                                }
                                                frameData[currentTitle][currentDifficultyIDs[x]].description = desc
                                            else
                                                frameData[currentTitle][currentDifficultyID] = {
                                                    title = newInfo.title,
                                                    headerType = newInfo.headerType,
                                                    abilityIcon = newInfo.abilityIcon,
                                                    spellID = newInfo.spellID,
                                                    description = "",
                                                    index = counter
                                                }
                                            
                                            end
                                        end)
                                    end
                                end
                            end
                        else
                        
                        end
                    end

                    rootSectionID = table.remove(stack)
                until not rootSectionID
            else
                miog.AdventureJournal.AbilitiesFrame.Status:Show()

                break

            end
        end

        miog.AdventureJournal.Status:SetColorTexture(0, 1, 0)

        for id, difficultyData in pairs(frameData) do
            local lowestDifficulty

            for k, v in pairs(difficultyData) do
                if(lowestDifficulty == nil or k < lowestDifficulty) then
                    lowestDifficulty = k
                end
                
            end

            if(lowestDifficulty) then
                organizedFrameData[difficultyData[lowestDifficulty].title] = {}

                for k, v in pairs(difficultyData) do
                    organizedFrameData[difficultyData[lowestDifficulty].title][k] = {}
                end

                local frame = basePool:Acquire()

                frame.ExpandFrame:SetShown(difficultyData[lowestDifficulty].description ~= "")
                frame.layoutIndex = difficultyData[lowestDifficulty].index
                frame.fixedWidth = miog.AdventureJournal.AbilitiesFrame:GetWidth()
                frame.Name:SetText(difficultyData[lowestDifficulty].title)
                frame.Icon:SetTexture(difficultyData[lowestDifficulty].abilityIcon)
                frame.spellID = difficultyData[lowestDifficulty].spellID
                frame.encounterID = currentEncounterID
                frame.abilityTitle = difficultyData[lowestDifficulty].title
                frame.difficultyFrames = {}

                C_Timer.After(0.3, function()
                    local compareArray = {}
                    local compareValue

                    for i = 1, #currentDifficultyIDs, 1 do
                        local array = difficultyData[currentDifficultyIDs[i] ] and miog.simpleSplit(difficultyData[currentDifficultyIDs[i] ].description, "%s")

                        if(array) then
                            if(compareValue) then
                                table.insert(compareArray, #array)
                                
                            else
                                compareValue = #array

                            end
                        end
                    end
                    
                    local equal = compareArrayValues(compareArray, compareValue)
                    local forwardOrdered = forwardOrderedValues(compareArray)

                    local baseString = stopAndGo(id, equal, forwardOrdered)

                    for i = 1, #currentDifficultyIDs, 1 do
                        local difficultyFrame = difficultyPool:Acquire()

                        local concatString = ""

                        if(frameData[id][currentDifficultyIDs[i] ] ~= nil) then
                            for k, v in ipairs(organizedFrameData[id][currentDifficultyIDs[i] ]) do
                                if(v.colorIndex) then
                                    concatString = concatString .. WrapTextInColorCode(v.string, miog.AJ_CLRSCC[v.colorIndex]) .. " "

                                else
                                    concatString = concatString .. v.string .. "  "

                                end

                            end

                            if(concatString == "") then
                                concatString = WrapTextInColorCode("Mechanic is implemented on " .. GetEJDifficultyString(currentDifficultyIDs[i]), "FF00C200")

                            end
                
                        else
                            concatString = WrapTextInColorCode("Mechanic not implemented on " .. GetEJDifficultyString(currentDifficultyIDs[i]), "FFB92D27")
                
                        end

                        difficultyFrame.Description:SetText(concatString)
                        difficultyFrame.Name:SetText(GetEJDifficultyString(currentDifficultyIDs[i]))
                        difficultyFrame:SetParent(frame.DetailedInformation.Difficulties)
                        difficultyFrame.layoutIndex = i
                        difficultyFrame.fixedWidth = frameWidth
                        difficultyFrame:SetShown(i == 1 or equal or forwardOrdered or false)

                        frame.difficultyFrames[i] = difficultyFrame
                    end

                    frame.DetailedInformation.Difficulties:MarkDirty()
                    
                    frame.DetailedInformation.Base.Name:SetText("Base")
                    frame.DetailedInformation.Base.Description:SetText(baseString)

                    frame.ExpandFrame:SetShown(difficultyData[lowestDifficulty].description ~= "")
                    frame.DetailedInformation.Base:SetShown((equal or forwardOrdered) and baseString ~= "")

                    if(not equal and not forwardOrdered) then
                        frame.DetailedInformation.Base:Hide()
                    
                        for i = 1, #currentDifficultyIDs, 1 do
                            local switchFrame = switchPool:Acquire()
                            local shortName = miog.DIFFICULTY_ID_TO_SHORT_NAME[currentDifficultyIDs[i] ]
                            switchFrame:SetParent(frame.SwitchPanel)
                            switchFrame.layoutIndex = i
                            switchFrame:SetText(shortName)
                            switchFrame:SetWidth(switchFrame:GetTextWidth() + 15)
                            switchFrame:SetScript("OnClick", function(self)
                                for _, v in pairs(frame.difficultyFrames) do
                                    v:SetShown(self.layoutIndex == v.layoutIndex)
                                    
                                end
    
                                frame.DetailedInformation.Difficulties:MarkDirty()
                                frame.ExpandFrame:SetState(true)
                                frame.DetailedInformation:Show()
                            end)
                            switchFrame:Show()
    
                        end
    
                        frame.SwitchPanel:MarkDirty()
                    end
    
                    frame.SwitchPanel:SetShown(not equal and not forwardOrdered)
                end)
                

                
                frame:Show()
            end
        end
    end

    if(abilityTitle) then
        for widget in basePool:EnumerateActive() do
            if(widget.abilityTitle == abilityTitle) then
                widget.DetailedInformation:Show()
                widget.ExpandFrame:SetState(true)
                miog.AdventureJournal.AbilitiesFrame:SetVerticalScroll(widget.layoutIndex * 20)
                
                break
            end
        end
        
    end

    miog.AdventureJournal.AbilitiesFrame.Container:MarkDirty()
end

local function loadInstanceInfo()
    expansionTable = {}

	for x = 1, EJ_GetNumTiers() - 1, 1 do
		local name, link = EJ_GetTierInfo(x)
		local expansionInfo = GetExpansionDisplayInfo(x-1)

		local expInfo = {}
		--expInfo.index = x + 10000
		expInfo.text = name
		expInfo.icon = expansionInfo and expansionInfo.logo

		expansionTable[#expansionTable+1] = expInfo
			
	end

    --local adventureJournalDungeonTable = {}
    --local adventureJournalRaidTable = {}

    journalInfo = {}

    for x = 1, EJ_GetNumTiers() - 1, 1 do
        journalInfo[x] = {}
        EJ_SelectTier(x)
        
        for k = 1, 2, 1 do
            local checkForRaid = k == 1 and true or false
            for i = 1, 5000, 1 do
                local journalInstanceID, name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceByIndex(i, checkForRaid)

                if(journalInstanceID) then
                    journalInfo[x][journalInstanceID] = {
                        tier = x,
                        journalInstanceID = journalInstanceID,
                        name = name,
                        isRaid = checkForRaid,
                        mapID = mapID,
                    }

                    --[[local info = {}
                
                    info.index = i + (isRaid and 1 or 300)
                    info.entryType = "option"
                    info.text = name
                    info.parentIndex = x + 10000
                    --info.icon = miog.MAP_INFO[mapID].icon
                    info.value = journalInstanceID
                    info.func = function()
                        --LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, v, activityID)
                
                    end

                    if(isRaid) then
                        adventureJournalRaidTable[#adventureJournalRaidTable+1] = info

                    else
                        adventureJournalDungeonTable[#adventureJournalDungeonTable+1] = info
                    
                    end]]
                end
            end
        end
    end

   -- for k, v in ipairs(adventureJournalRaidTable) do
        --miog.AdventureJournal.InstanceDropdown:CreateEntryFrame(v)

    --end

   -- for k, v in ipairs(adventureJournalDungeonTable) do
        --miog.AdventureJournal.InstanceDropdown:CreateEntryFrame(v)

    --end

    --miog.AdventureJournal.InstanceDropdown.List:MarkDirty()
end

miog.loadAdventureJournal = function()
    local adventureJournal = CreateFrame("Frame", "MythicIOGrabber_AdventureJournal", miog.Plugin.InsertFrame, "MIOG_AdventureJournal")
    frameWidth = adventureJournal.AbilitiesFrame:GetWidth()

    --[[adventureJournal:SetScript("OnShow", function()
        local currentMapID = select(8, GetInstanceInfo());
        
        if(currentMapID and currentMapID ~= 0) then
            local journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(currentMapID) or nil

            if(journalInstanceID) then
                selectInstance(journalInstanceID)
                
            end
        end
    end)]]

    basePool = CreateFramePool("Frame", adventureJournal.AbilitiesFrame.Container, "MIOG_AdventureJournalAbilityTemplate2", resetJournalFrames)
    --difficultyPool = CreateFramePool("Frame", nil, "MIOG_AdventureJournalAbilityDifficultyTemplate", resetDifficultyFrames)
    --switchPool = CreateFramePool("Button", nil, "MIOG_AdventureJournalAbilitySwitchTemplate", resetSwitchFrames)
    --modelPool = CreateFramePool("Button", adventureJournal.ModelScene.List.Container, "MIOG_AdventureJournalCreatureButtonTemplate", resetModelFrame)

    --[[local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 4);
    view:SetElementInitializer("MIOG_AdventureJournalAbilityTemplate2", function(frame, data)
        --local diffText
        frame.Title:SetText(data.sectionInfo[1].title .. ", " .. data.sectionInfo[1].spellID)
        frame.Base.Description:SetText(data.base)
        frame.Base:MarkDirty()
        frame.Icon:SetTexture(data.sectionInfo[1].abilityIcon)

        for k, v in ipairs(currentDifficultyIDs) do
            frame["Diff" .. k].Name:SetText(GetEJDifficultyString(v))
        end

        for k, v in ipairs(data.sectionInfo) do
            frame.Title:SetText(frame.Title:GetText() .. " " .. v.difficulty)

            local diffFrame = frame["Diff" .. k]

            if(v.difficultyText == "") then
                v.difficultyText = "This mechanic is implemented on " .. diffFrame.Name:GetText()
                --print("EMPTY", data.sectionInfo[1].title)

            elseif(v.difficultyText == nil) then
                print("NIL", data.sectionInfo[1].title)

            else

            end

            diffFrame.Description:SetText(v.difficultyText)
        end

        frame:MarkDirty()
    end)

    view:SetElementResetter(function(frame, data)
        frame.Icon:SetTexture(nil)
        frame.Title:SetText("")

        frame.Base.Name:SetText("")
        frame.Base.Description:SetText("")

        frame.Diff1.Name:SetText("")
        frame.Diff1.Description:SetText("")

        frame.Diff2.Name:SetText("")
        frame.Diff2.Description:SetText("")

        frame.Diff3.Name:SetText("")
        frame.Diff3.Description:SetText("")

        frame.Diff4.Name:SetText("")
        frame.Diff4.Description:SetText("")
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(adventureJournal.ScrollBox, adventureJournal.ScrollBar, view);]]


    loadInstanceInfo()

    local instanceDropdown = adventureJournal.InstanceDropdown

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

            for journalIndex, info in pairs(journalInfo[k]) do
                if(info.journalInstanceID) then
                    local instanceButton = expansionButton:CreateRadio(info.name, function(instanceID) return selectedInstance == instanceID end, function(instanceID)
                        EJ_SelectTier(k)
                        selectInstance(instanceID)

                    end, info.journalInstanceID)

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
		end

    end)

	local bossDropdown = adventureJournal.BossDropdown
    bossDropdown:SetupMenu(function(dropdown, rootDescription)
        if(selectedInstance) then
            local bossTable, firstBossID = checkForBossInfo(selectedInstance)
        
            for k, v in ipairs(bossTable) do
                local instanceButton = rootDescription:CreateRadio(v.text, function(encounterID) return selectedEncounter == encounterID end, function(encounterID)
                    selectEncounter(encounterID)
                end, v.value)
        
            end

            --adventureJournal.SettingsBar.SlotDropdown:Show()
            --adventureJournal.SettingsBar.ArmorDropdown:Show()
        end
    end)

	--[[local keylevelDropdown = adventureJournal.SettingsBar.KeylevelDropdown
    keylevelDropdown:OnLoad()
    keylevelDropdown:SetParent(adventureJournal.Abilities)]]

    adventureJournal.SettingsBar.ArmorDropdown:SetDefaultText("Armor types")
    adventureJournal.SettingsBar.ArmorDropdown:SetupMenu(function(dropdown, rootDescription)
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

    adventureJournal.SettingsBar.SlotDropdown:SetDefaultText("Equipment slots")
    adventureJournal.SettingsBar.SlotDropdown:SetupMenu(function(dropdown, rootDescription)
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
    end)

    for i = 2, 40, 1 do
        local keyInfo = {}
        keyInfo.entryType = "option"
        keyInfo.index = i
        keyInfo.text = "+" .. i
        keyInfo.value = i
        keyInfo.func = function()
            changingKeylevel = true
            C_EncounterJournal.SetPreviewMythicPlusLevel(i)
            changingKeylevel = false
        end

        --keylevelDropdown:CreateEntryFrame(keyInfo)
    end

    --keylevelDropdown:SelectFirstFrameWithValue(3)

    --[[local view = CreateScrollBoxListLinearView(1, 1, 1, 1, 2);

    local function initializeLootFrames(frame, elementData)
        --local elementData = node:GetData()

        if(elementData.template == "MIOG_AdventureJournalLootItemTemplate") then
            frame.BasicInformation.Name:SetText(elementData.name)
            frame.BasicInformation.Icon:SetTexture(elementData.icon)

            local counter = 0

            for _, y in ipairs(currentDifficultyIDs) do
                local currentItem = counter == 0 and frame or frame.BasicInformation["Item" .. (counter)]

                if(currentItemTable[elementData.itemID].links[y]) then
                    currentItem:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetHyperlink(currentItemTable[elementData.itemID].links[y])
                    end)

                    currentItem.itemLink = currentItemTable[elementData.itemID].links[y]

                    if(currentItem ~= frame) then
                        currentItem:SetTexture(elementData.icon)

                    end

                    counter = counter + 1
                elseif(currentItem) then
                    if(currentItem ~= frame) then
                        currentItem:SetTexture(nil)

                    end
                    
                    currentItem:SetScript("OnEnter", nil)
                    currentItem.itemLink = nil

                end
                
            end
        else
            frame.Name:SetText(elementData.name)


        end
    end
		
    local function CustomFactory(factory, data)
        --local data = node:GetData()
        local template = data.template
        factory(template, initializeLootFrames)
    end

    view:SetElementFactory(CustomFactory)
    view:SetElementResetter(resetLootItemFrames)
    
    view:SetPadding(1, 1, 1, 1, 4);
    
    ScrollUtil.InitScrollBoxListWithScrollBar(adventureJournal.ScrollBox, adventureJournal.ScrollBar, view);

    adventureJournal.ScrollBox:SetDataProvider(CreateDataProvider())]]

    return adventureJournal
end

hooksecurefunc("SetItemRef", function(link)
    local linkType, linkData = LinkUtil.SplitLinkData(link)

	if(linkType == "addon") then
        local linkAddonName, system, feature, data1, data2 = strsplit(":", linkData)
        if(linkAddonName == addonName) then
            if(system == "aj") then
                miog.setActivePanel(nil, "AdventureJournal")
                
                if(feature == "ability") then

                end
            end
        end
    end
end)

local function aj_events(_, event, ...)
    --checkAllEncounterSections(...)

    if(event == "EJ_LOOT_DATA_RECIEVED" and currentEncounterID and ...) then
        lootWaitlist[...] = nil

        local counter = 0

        for k, v in pairs(lootWaitlist) do
            counter = counter + 1
            break

        end

        if(counter == 0) then
            requestAllItemsFromCurrentEncounter()
        end
    end
end


local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_AJEventReceiver")

--eventReceiver:RegisterEvent("EJ_DIFFICULTY_UPDATE")
eventReceiver:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
eventReceiver:SetScript("OnEvent", aj_events)