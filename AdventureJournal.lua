local addonName, miog = ...

local regex1 = "%d+ [D-d]amage"
local regex2 = "%d+ %w+ [D-d]amage"
local regex3 = "%d+ %w+ %w+ [D-d]amage"

local basePool, lootPool, slotLinePool, modelPool, difficultyPool, switchPool
local isRaid
local changingKeylevel = false
local currentModels = {}
local lootWaitlist = {}
local currentOffset = 0

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
    --SetPortraitTextureFromCreatureDisplayID(button.creature, displayInfo);
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

local function resetLootItemFrames(_, frame)
    frame:Hide()
    frame.layoutIndex = nil
    frame.itemLink = nil
    frame.BasicInformation.Name:SetText("")
    frame.BasicInformation.Icon:SetTexture(nil)
    frame.BasicInformation.ExpandFrame:Show()
    frame.abilityTitle = nil

    frame:SetScript("OnEnter", nil)

    frame.fixedWidth = miog.AdventureJournal.LootFrame:GetWidth()

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

local frameWidth

local function resetJournalFrames(_, frame)
    frame:Hide()
    frame.layoutIndex = nil
    frame.Name:SetText("")
    frame.Icon:SetTexture(nil)
    frame.ExpandFrame:Show()
    frame.leftPadding = nil
    frame.difficultyFrames = nil
    frame.spellID = nil

    if(not changingKeylevel) then
        frame.ExpandFrame:SetState(0)
        frame.DetailedInformation:Hide()
    end

    frame.SwitchPanel:Hide()
    frame.DetailedInformation.Base:Show()

    frame.DetailedInformation.Base.Name:SetText("")
    frame.DetailedInformation.Base.Description:SetText("")
    frame.DetailedInformation.Base.fixedWidth = frameWidth

    frame.DetailedInformation.Difficulties.fixedWidth = frameWidth
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
local lootData = {}
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


    --[[local baseArray = {

    }

    --local blueprint = frameData[id][lowestDifficulty]

    local stringArray = {
        [currentDifficultyIDs[1] ] = "",
        [currentDifficultyIDs[2] ] = "",
        [currentDifficultyIDs[3] ] = "",
        [currentDifficultyIDs[4] ] = "",
    }

    local baseString = ""

    for n = 1, 3, 1 do
        local fAID = currentDifficultyIDs[n]
        local tAID = currentDifficultyIDs[n + 1]

        local fArray = frameData[id][fAID] and miog.simpleSplit(frameData[id][fAID], "%s") or {}
        local tArray = frameData[id][tAID] and miog.simpleSplit(frameData[id][tAID], "%s") or {}

        local lowerArray, higherArray

        if(#fArray > #tArray) then
            lowerArray = tArray
            higherArray = fArray

        else
            lowerArray = fArray
            higherArray = tArray
        
        end

        local shift = 0

        local firstX = false
        local xCounter = 1

        --if(id == "Lightning Devastation") then
        for k, v in ipairs(lowerArray) do
            local firstCurrentValue = lowerArray[k]
            local firstFutureValue = lowerArray[k + 1]

            local thirdCurrentValue = higherArray[k + shift]

            if(firstCurrentValue and thirdCurrentValue) then
                local withoutComma = string.gsub(thirdCurrentValue, ",", "")
                local maybeNumber = tonumber(withoutComma)
                if(maybeNumber) then

                    for i = k + shift, #higherArray, 1 do
                        if(firstCurrentValue == higherArray[i]) then
                            break
                        else
                                if(firstX == false) then
                                    --baseArray[i] = "[" .. xCounter .. "]"
                                    xCounter = xCounter + 1
                                    firstX = true
                                end
                                    
                                --else
                                    baseArray[i] = false

                                --end
                                if(higherArray[i] == "million" or higherArray[i] == "billion") then
                                    baseArray[i] = nil

                                end

                                if(firstFutureValue == higherArray[i + 1]) then
                                    break
                                else

                                    shift = shift + 1
                                end
                        end
                    end
                end

                firstX = false
            end
        end
        --end
    end

    for k, v in ipairs(miog.simpleSplit(frameData[id][lowestDifficulty], "%s")) do
        if(baseArray[k] ~= false) then
            --if(baseArray[k]) then
                --baseString = baseString .. baseArray[k] .. " "

           -- else
                baseString = baseString .. v .. " "

           -- end

        --elseif(baseArray[k] == false) then
            --baseString = baseString .. "X "

        end

    end

    for n = 1, 4, 1 do
        local diffID = currentDifficultyIDs[n]
        local diffArray = frameData[id][diffID] and miog.simpleSplit(frameData[id][diffID], "%s") or {}
        local baseStringArray = miog.simpleSplit(baseString, "%s") or {}

        stringArray[diffID] = ""

        local shift = 0

       -- if(id == "Lightning Devastation") then
            for k, v in ipairs(diffArray) do
                local firstCurrentValue = baseStringArray[k]
                local firstFutureValue = baseStringArray[k + 1]

                local thirdCurrentValue = diffArray[k + shift]
                --local thirdFutureValue = higherArray[k + shift + 1]

                if(firstCurrentValue and thirdCurrentValue) then
                    local withoutComma = string.gsub(thirdCurrentValue, ",", "")
                    local maybeNumber = tonumber(withoutComma)
                    if(maybeNumber) then
                        for i = k + shift, #diffArray, 1 do

                            if(firstCurrentValue == diffArray[i]) then
                                --print(k, "OK", firstCurrentValue, higherArray[i])
                                --if((lowerLengthID == lowestDifficulty or higherLengthID == lowestDifficulty)) then
                                    --baseString = baseString .. firstCurrentValue .. " "
                                    --baseArray[i] = true
                                --end

                                break
                            else
                                
                                    --baseString = baseString .. "YYY "
                                    --baseArray[i] = false

                                    --print(k, firstCurrentValue, diffArray[i])
                                
                                    stringArray[diffID] = stringArray[diffID] .. diffArray[i] .. " "
                                    table.insert(organizedFrameData[id][diffID], diffArray[i])

                                    if(firstFutureValue == diffArray[i + 1]) then
                                        --print("BREAK")
                                        break
                                    else

                                        shift = shift + 1
                                    end
                            end
                        end

                        --[ [if(firstCurrentValue == higherArray[i]) then
                            --if(lowerLengthID == lowestDifficulty) then
                                --baseString = baseString .. firstCurrentValue .. " "
                            --end
                            --print("MATCH", )
                            
                            --if(firstFutureValue and higherArray[i + 1] and firstFutureValue ~= higherArray[i + 1]) then
                                --baseString = baseString .. "[" .. xCounter .. "] "

                            --end

                            --stringArray[lowerLengthID] = stringArray[lowerLengthID] .. firstCurrentValue .. " "

                            --stringArray[higherLengthID] = stringArray[higherLengthID] .. firstCurrentValue .. " "

                            break
                        else
                            --organizedFrameData[id][higherLengthID][#organizedFrameData[id][higherLengthID]+1] = higherArray[i]
                            --stringArray[higherLengthID] = stringArray[higherLengthID] .. higherArray[i] .. " "

                            stringArray[lowerLengthID] = stringArray[lowerLengthID] .. firstCurrentValue .. " "
                            stringArray[higherLengthID] = stringArray[higherLengthID] .. firstCurrentValue .. " "


                            if(firstFutureValue == higherArray[i + 1]) then
                                --print(lowerLengthID, "MISMATCH BUT SAME", firstCurrentValue, higherArray[i])

                                --organizedFrameData[id][lowerLengthID][#organizedFrameData[id][lowerLengthID]+1] = firstCurrentValue


                                --firstString = firstString .. "X" .. xCounter .. "="

                                --firstString = firstString .. firstCurrentValue .. " "

                                --xCounter = xCounter + 1

                            else
                                --print(lowerLengthID, higherLengthID, "MISMATCH AND STILL", firstCurrentValue, higherArray[i])

                                if(lowerArray[i]) then
                                    --firstString = firstString .. lowerArray[i] .. " "
                                end

                                shift = shift + 1
                            
                            end

                            --otherString = otherString .. "X" .. xCounter .. "="
                            --otherString = otherString .. higherArray[i] .. " "

                            break

                        end] ]

                    end
                end
            end
        --end
    end]]


    --[[for n = 1, 3, 1 do
        local fAID = currentDifficultyIDs[n]
        local tAID = currentDifficultyIDs[n + 1]

        --organizedFrameData[id][fID] = {}
        --organizedFrameData[id][tID] = {}

        local fArray = frameData[id][fAID] and miog.simpleSplit(frameData[id][fAID], "%s") or {}
        local tArray = frameData[id][tAID] and miog.simpleSplit(frameData[id][tAID], "%s") or {}

        local lowerArray, higherArray
        local lowerLengthID, higherLengthID

        local switched = false

        if(#fArray > #tArray) then
            lowerArray = tArray
            higherArray = fArray

            lowerLengthID = tAID
            higherLengthID = fAID

            switched = true

        else
            lowerArray = fArray
            higherArray = tArray

            lowerLengthID = fAID
            higherLengthID = tAID
        
        end

        stringArray[lowerLengthID] = ""
        stringArray[higherLengthID] = ""

        --stringArray[fAID] = ""
        --stringArray[tAID] = ""
        --local firstString = ""
        --local otherString = ""

        local shift = 0
        local xCounter = 1

        if(id == "Lightning Devastation") then
            for k, v in ipairs(lowerArray) do
                local firstCurrentValue = lowerArray[k]
                local firstFutureValue = lowerArray[k + 1]

                local thirdCurrentValue = higherArray[k + shift]
                --local thirdFutureValue = higherArray[k + shift + 1]

                if(firstCurrentValue and thirdCurrentValue) then
                    for i = k + shift, #higherArray, 1 do

                        if(firstCurrentValue == higherArray[i]) then
                            --print(k, "OK", firstCurrentValue, higherArray[i])
                            if((lowerLengthID == lowestDifficulty or higherLengthID == lowestDifficulty)) then
                                --baseString = baseString .. firstCurrentValue .. " "
                                --baseArray[i] = true
                            end

                            break
                        else
                            --baseString = baseString .. "YYY "
                            --baseArray[i] = false

                            --print(k, firstCurrentValue, higherArray[i])
                        
                            stringArray[lowerLengthID] = stringArray[lowerLengthID] .. firstCurrentValue .. " "
                            stringArray[higherLengthID] = stringArray[higherLengthID] .. higherArray[i] .. " "


                            if(firstFutureValue == higherArray[i + 1]) then
                                --print("BREAK")
                                break
                            else
                                shift = shift + 1
                            end
                        end

                        --[ [
                        if(firstCurrentValue == higherArray[i]) then
                            --if(lowerLengthID == lowestDifficulty) then
                                --baseString = baseString .. firstCurrentValue .. " "
                            --end
                            --print("MATCH", )
                            
                            --if(firstFutureValue and higherArray[i + 1] and firstFutureValue ~= higherArray[i + 1]) then
                                --baseString = baseString .. "[" .. xCounter .. "] "

                            --end

                            --stringArray[lowerLengthID] = stringArray[lowerLengthID] .. firstCurrentValue .. " "

                            --stringArray[higherLengthID] = stringArray[higherLengthID] .. firstCurrentValue .. " "

                            break
                        else
                            --organizedFrameData[id][higherLengthID][#organizedFrameData[id][higherLengthID]+1] = higherArray[i]
                            --stringArray[higherLengthID] = stringArray[higherLengthID] .. higherArray[i] .. " "

                            stringArray[lowerLengthID] = stringArray[lowerLengthID] .. firstCurrentValue .. " "
                            stringArray[higherLengthID] = stringArray[higherLengthID] .. firstCurrentValue .. " "


                            if(firstFutureValue == higherArray[i + 1]) then
                                --print(lowerLengthID, "MISMATCH BUT SAME", firstCurrentValue, higherArray[i])

                                --organizedFrameData[id][lowerLengthID][#organizedFrameData[id][lowerLengthID]+1] = firstCurrentValue


                                --firstString = firstString .. "X" .. xCounter .. "="

                                --firstString = firstString .. firstCurrentValue .. " "

                                --xCounter = xCounter + 1

                            else
                                --print(lowerLengthID, higherLengthID, "MISMATCH AND STILL", firstCurrentValue, higherArray[i])

                                if(lowerArray[i]) then
                                    --firstString = firstString .. lowerArray[i] .. " "
                                end

                                shift = shift + 1
                            
                            end

                            --otherString = otherString .. "X" .. xCounter .. "="
                            --otherString = otherString .. higherArray[i] .. " "

                            break

                        end ] ]
                    end


                elseif(firstCurrentValue) then
                    if(lowerLengthID == lowestDifficulty) then
                        --baseString = baseString .. firstCurrentValue .. " "
                    end
                
                end
            end
        end
    end]]

   --[[ for k, v in ipairs(miog.simpleSplit(frameData[id][lowestDifficulty], "%s")) do
        if(baseArray[k] ~= false) then
            baseString = baseString .. v .. " "

        --elseif(baseArray[k] == false) then
            --baseString = baseString .. "X "

        end

    end]]

    return baseString
end

local function checkForBossInfo(journalInstanceID)
    local bossTable = {}
    local firstBossID = nil

    for i = 1, 50, 1 do
        local info = {}
        local name, description, journalEncounterID, rootSectionID, link, journalInstanceID2, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(i, journalInstanceID)

        if(name) then
            info.index = i
            info.entryType = "option"
            info.text = name
            info.value = journalEncounterID
            info.func = function()
                miog.selectBoss(journalEncounterID)

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

    EJ_SetDifficulty(currentDifficultyIDs[1])
end

miog.selectInstance = function(journalInstanceID)
    EJ_SelectInstance(journalInstanceID)
    retrieveDifficultyIDs()

    isRaid = miog.JOURNAL_INSTANCE_INFO[journalInstanceID] and miog.JOURNAL_INSTANCE_INFO[journalInstanceID].isRaid or false
    miog.AdventureJournal.SettingsBar.KeylevelDropdown:SetShown(not isRaid)

    miog.AdventureJournal.BossDropdown:ResetDropDown()

    local bossTable, firstBossID = checkForBossInfo(journalInstanceID)

	for k, v in ipairs(bossTable) do
		miog.AdventureJournal.BossDropdown:CreateEntryFrame(v)

	end

    miog.selectBoss(firstBossID)
    miog.AdventureJournal.BossDropdown:SelectFirstFrameWithValue(firstBossID)
end

local function retrieveItemInfoFromCurrentEncounter(fromEvent)
    lootPool:ReleaseAll()
    slotLinePool:ReleaseAll()

    if(currentDifficultyIDs and currentDifficultyIDs[1]) then
        local slotLines = {}

        for _, v in pairs(lootData) do
            if(not slotLines[v.index]) then
                local line = slotLinePool:Acquire()
                line:SetWidth(frameWidth)
                line.layoutIndex = v.index * 10
                line.Name:SetText(v.slot)
                line:Show()

                slotLines[v.index] = true
            end

            local frame = lootPool:Acquire()
            frame.BasicInformation.Name:SetText(v.name)
            frame.BasicInformation.Icon:SetTexture(v.icon)
            frame.layoutIndex = v.index * 10 + 1

            local counter = 0

            for _, y in ipairs(currentDifficultyIDs) do
                local currentItem = counter == 0 and frame or frame.BasicInformation["Item" .. (counter)]

                if(v.links[y]) then
                    currentItem:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetHyperlink(v.links[y])
                    end)

                    currentItem.itemLink = v.links[y]

                    if(currentItem ~= frame) then
                        currentItem:SetTexture(v.icon)
                        currentItem:Show()

                    end

                    counter = counter + 1
                elseif(currentItem) then
                    currentItem:Hide()

                end
                
            end

            frame:Show()
        end

        miog.AdventureJournal.LootFrame.Container:MarkDirty()
    end
end

local function requestCurrentDifficultyItemsFromCurrentEncounter()
    for n = 1, EJ_GetNumLoot(), 1 do
        local itemInfo = C_EncounterJournal.GetLootInfoByIndex(n)

        if(itemInfo and itemInfo.name) then
            lootData[itemInfo.name] = lootData[itemInfo.name] or {
                name = itemInfo.name,
                icon = itemInfo.icon,
                itemID = itemInfo.itemID,
                index = itemInfo.filterType or 20,
                slot = itemInfo.slot == "" and "Other" or itemInfo.slot,
                links = {}
            }

            lootData[itemInfo.name].links[EJ_GetDifficulty()] = itemInfo.link

        else
            lootWaitlist[itemInfo.itemID] = false

        end
    end
end

local function requestAllItemsFromCurrentEncounter()
    for x = 1, #currentDifficultyIDs, 1 do
        EJ_SetDifficulty(currentDifficultyIDs[x])

        requestCurrentDifficultyItemsFromCurrentEncounter()
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

    local id, name, displayInfo, iconImage, uiModelSceneID, description;
	for i=1, 9, 1 do
		id, name, description, displayInfo, iconImage, uiModelSceneID = EJ_GetCreatureInfo(i);

		if id then
			local button = modelPool:Acquire();
            button.layoutIndex = i
			SetPortraitTextureFromCreatureDisplayID(button.creature, displayInfo);
			button.name = name;
			button.id = id;
			button.description = description;
			button.displayInfo = displayInfo;
			button.uiModelSceneID = uiModelSceneID;
            button:SetScript("OnClick", function(self)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);

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

miog.selectBoss = function(journalEncounterID, abilityTitle)
    if(not abilityTitle or abilityTitle and currentEncounterID ~= journalEncounterID) then
        C_EncounterJournal.SetPreviewMythicPlusLevel(miog.AdventureJournal.SettingsBar.KeylevelDropdown:GetSelectedValue())
        basePool:ReleaseAll()
        difficultyPool:ReleaseAll()
        switchPool:ReleaseAll()

        currentEncounterID = journalEncounterID
        
        EJ_SelectEncounter(currentEncounterID)

        frameData = {}
        organizedFrameData = {}
        lootData = {}
        currentModels = {}
        local stack = {}

        miog.AdventureJournal.Status:SetColorTexture(0, 1, 0)

        retrieveEncounterCreatureInfo()

        if(#currentModels > 0) then
            showModel(currentModels[1].uiModelSceneID, currentModels[1].displayInfo, true)
        end

        miog.AdventureJournal.AbilitiesFrame.Status:Hide()

        for x = 1, #currentDifficultyIDs, 1 do
            EJ_SetDifficulty(currentDifficultyIDs[x])

            requestCurrentDifficultyItemsFromCurrentEncounter()

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

        retrieveItemInfoFromCurrentEncounter()

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
    
                    --requestAllItemsFromCurrentEncounter()
                    --retrieveItemInfoFromCurrentEncounter()
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

miog.loadAdventureJournal = function()
    miog.AdventureJournal = CreateFrame("Frame", "MythicIOGrabber_AdventureJournal", miog.Plugin.InsertFrame, "MIOG_AdventureJournal")
    frameWidth = miog.AdventureJournal.AbilitiesFrame:GetWidth()

    miog.AdventureJournal:SetScript("OnShow", function()
        local journalInstanceID = AdventureGuideUtil.GetCurrentJournalInstance()

        if(journalInstanceID) then
            miog.selectInstance(journalInstanceID)
            miog.AdventureJournal.InstanceDropdown:SelectFirstFrameWithValue(journalInstanceID)
            
        end
    end)

    basePool = CreateFramePool("Frame", miog.AdventureJournal.AbilitiesFrame.Container, "MIOG_AdventureJournalAbilityTemplate", resetJournalFrames)
    difficultyPool = CreateFramePool("Frame", nil, "MIOG_AdventureJournalAbilityDifficultyTemplate", resetDifficultyFrames)
    switchPool = CreateFramePool("Button", nil, "MIOG_AdventureJournalAbilitySwitchTemplate", resetSwitchFrames)

    lootPool = CreateFramePool("Frame", miog.AdventureJournal.LootFrame.Container, "MIOG_AdventureJournalLootItemTemplate", resetLootItemFrames)
    slotLinePool = CreateFramePool("Frame", miog.AdventureJournal.LootFrame.Container, "MIOG_AdventureJournalLootSlotLineTemplate", resetSlotLine)
    modelPool = CreateFramePool("Button", miog.AdventureJournal.ModelScene.List.Container, "MIOG_AdventureJournalCreatureButtonTemplate", resetModelFrame)

	local instanceDropdown = miog.AdventureJournal.InstanceDropdown
	instanceDropdown:OnLoad()

	local bossDropdown = miog.AdventureJournal.BossDropdown
	bossDropdown:OnLoad()

	local keylevelDropdown = miog.AdventureJournal.SettingsBar.KeylevelDropdown
    keylevelDropdown:SetParent(miog.AdventureJournal.Abilities)
    keylevelDropdown:OnLoad()

	local classSpecDropdown = miog.AdventureJournal.SettingsBar.ClassSpecDropdown
    classSpecDropdown:SetParent(miog.AdventureJournal.LootFrame)
    classSpecDropdown:OnLoad()

    local info = {}
    info.entryType = "option"
    info.index = 0
    info.text = ALL_CLASSES
    info.value = 0
    info.func = function()
        EJ_SetLootFilter(0, 0)

        lootData = {}
        requestAllItemsFromCurrentEncounter()
        retrieveItemInfoFromCurrentEncounter()
    end

    classSpecDropdown:CreateEntryFrame(info)

    for k, v in ipairs(miog.CLASSES) do

        local info = {}
        info.entryType = "option"
        info.index = k
        info.text = GetClassInfo(k)
        info.value = k
        info.func = function()
            EJ_SetLootFilter(k, GetSpecializationInfoForClassID(k, 1))

            lootData = {}
            requestAllItemsFromCurrentEncounter()
            retrieveItemInfoFromCurrentEncounter()
        end

        classSpecDropdown:CreateEntryFrame(info)

        for x, y in ipairs(v.specs) do
            local id, name, description, icon, role, classFile, className = GetSpecializationInfoByID(y)

            local specInfo = {}
            specInfo.entryType = "option"
            specInfo.parentIndex = k
            specInfo.index = y
            specInfo.text = name
            specInfo.value = y
            specInfo.func = function()
                EJ_SetLootFilter(k, y)

                lootData = {}
                requestAllItemsFromCurrentEncounter()
                retrieveItemInfoFromCurrentEncounter()
            end

            classSpecDropdown:CreateEntryFrame(specInfo)
        end

    end

	local slotDropdown = miog.AdventureJournal.SettingsBar.SlotDropdown
    slotDropdown:SetParent(miog.AdventureJournal.LootFrame)
    slotDropdown:OnLoad()

    for k, v in pairs(Enum.ItemSlotFilterType) do
        local info = {}
        info.entryType = "option"
        info.index = v
        info.text = k
        info.value = v
        info.func = function()
            C_EncounterJournal.SetSlotFilter(v)

            lootData = {}
            requestAllItemsFromCurrentEncounter()
            retrieveItemInfoFromCurrentEncounter()
        end

        miog.AdventureJournal.SettingsBar.SlotDropdown:CreateEntryFrame(info)
    end

    for i = 2, 40, 1 do
        local keyInfo = {}
        keyInfo.entryType = "option"
        keyInfo.index = i
        keyInfo.text = "+" .. i
        keyInfo.value = i
        keyInfo.func = function()
            currentOffset = miog.AdventureJournal.AbilitiesFrame:GetVerticalScroll()
            changingKeylevel = true
            C_EncounterJournal.SetPreviewMythicPlusLevel(i)
            miog.selectBoss(currentEncounterID)
            changingKeylevel = false
        end

        keylevelDropdown:CreateEntryFrame(keyInfo)
    end

    keylevelDropdown:SelectFirstFrameWithValue(3)

    local classID, specID = EJ_GetLootFilter()

    local success = classSpecDropdown:SelectFirstFrameWithValue(specID)

    if(not success) then
        classSpecDropdown:SelectFirstFrameWithValue(classID)
        
    end

    local filter = C_EncounterJournal.GetSlotFilter()

    miog.AdventureJournal.SettingsBar.SlotDropdown:SelectFirstFrameWithValue(filter)
end

hooksecurefunc("SetItemRef", function(link)
	local linkType, linkAddonName, system, feature, data1, data2 = strsplit(":", link)
	if linkType == "addon" and linkAddonName == addonName then
        if(system == "aj") then
            miog.setActivePanel(nil, "AdventureJournal")
            
            if(feature == "ability") then
                miog.selectBoss(data1, data2)

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
            --print(GetTimePreciseSec(), "ZEROOOOOO")
            requestAllItemsFromCurrentEncounter()
            retrieveItemInfoFromCurrentEncounter(true)
        end
    end
end

MIOG_AJ = aj_events


local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_AJEventReceiver")

--eventReceiver:RegisterEvent("EJ_DIFFICULTY_UPDATE")
eventReceiver:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
eventReceiver:SetScript("OnEvent", aj_events)