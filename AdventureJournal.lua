local addonName, miog = ...

local regex1 = "%d+ damage"
local regex2 = "%d+ %w+ damage"

local basePool, lootPool, slotLinePool --switchPool
local isRaid
local changingKeylevel = false

local function resetSlotLine(_, frame)
    frame:Hide()
    frame.layoutIndex = nil
    frame.Name:SetText()
end

local function resetLootItemFrames(_, frame)
    frame:Hide()
    frame.layoutIndex = nil
    frame.BasicInformation.Name:SetText("")
    frame.BasicInformation.Icon:SetTexture(nil)
    frame.BasicInformation.ExpandFrame:Show()

    frame.fixedWidth = miog.AdventureJournal.LootFrame:GetWidth()

    frame.BasicInformation.Difficulty1Icon:SetTexture(nil)
    frame.BasicInformation.Difficulty1Icon:SetScript("OnEnter", nil)

    frame.BasicInformation.Difficulty2Icon:SetTexture(nil)
    frame.BasicInformation.Difficulty2Icon:SetScript("OnEnter", nil)

    frame.BasicInformation.Difficulty3Icon:SetTexture(nil)
    frame.BasicInformation.Difficulty3Icon:SetScript("OnEnter", nil)

    frame.BasicInformation.Difficulty4Icon:SetTexture(nil)
    frame.BasicInformation.Difficulty4Icon:SetScript("OnEnter", nil)
end

local frameWidth

local function resetJournalFrames(_, frame)
    frame:Hide()
    frame.layoutIndex = nil
    frame.Name:SetText("")
    frame.Icon:SetTexture(nil)
    frame.ExpandFrame:Show()
    frame.leftPadding = nil

    if(not changingKeylevel) then
        frame.ExpandFrame:SetState(0)
        frame.DetailedInformation:Hide()
    end

    frame.SwitchPanel:Show()
    frame.DetailedInformation.Base:Show()
    frame.DetailedInformation.Difficulty1:Show()
    frame.DetailedInformation.Difficulty2:Show()
    frame.DetailedInformation.Difficulty3:Show()
    frame.DetailedInformation.Difficulty4:Show()

    frame.DetailedInformation.Base.Name:SetText("")
    frame.DetailedInformation.Base.Description:SetText("")
    frame.DetailedInformation.Base.fixedWidth = frameWidth

    frame.DetailedInformation.Difficulty1.Name:SetText("")
    frame.DetailedInformation.Difficulty1.Description:SetText("")
    frame.DetailedInformation.Difficulty1.fixedWidth = frameWidth

    frame.DetailedInformation.Difficulty2.Name:SetText("")
    frame.DetailedInformation.Difficulty2.Description:SetText("")
    frame.DetailedInformation.Difficulty2.fixedWidth = frameWidth

    frame.DetailedInformation.Difficulty3.Name:SetText("")
    frame.DetailedInformation.Difficulty3.Description:SetText("")
    frame.DetailedInformation.Difficulty3.fixedWidth = frameWidth

    frame.DetailedInformation.Difficulty4.Name:SetText("")
    frame.DetailedInformation.Difficulty4.Description:SetText("")
    frame.DetailedInformation.Difficulty4.fixedWidth = frameWidth
end

local frameData = {}
local lootData = {}
local organizedFrameData = {}
local currentDifficultyIDs
local currentEncounterID

local function calculateNumberIncrease(number)
    for i = 2, miog.AdventureJournal.KeylevelDropdown:GetSelectedValue(), 1 do
        if(i == 2) then
            
        elseif(i > 2 and i < 10) then
            number = number * 1.08

        else
            number = number * 1.1
        
        end
    end

    return FormatLargeNumber(miog.round(number, 0))
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

local function createBaseString(id, lowestIndex)
    local baseArray = {}
    local shift = 0

    for n = lowestIndex, 3, 1 do
        local array1 = frameData[id][currentDifficultyIDs[lowestIndex]] and miog.simpleSplit(frameData[id][currentDifficultyIDs[lowestIndex]].description, "%s") or {}
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
    local lowestIndex = frameData[id][currentDifficultyIDs[1]] and 1 or frameData[id][currentDifficultyIDs[2]] and 2 or frameData[id][currentDifficultyIDs[3]] and 3 or frameData[id][currentDifficultyIDs[4]] and 4
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
        for n = lowestIndex, 4, 1 do
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
    
        for n = lowestIndex, 4, 1 do
            if(frameData[id][currentDifficultyIDs[n]]) then
                local array = frameData[id][currentDifficultyIDs[n]] and miog.simpleSplit(frameData[id][currentDifficultyIDs[n]].description, "%s")

                if(array) then
                    frameDataArrays[n] = array
                end
            end
        end

        if(forwardOrdered) then

            for n = lowestIndex, 4, 1 do
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
            for n = lowestIndex, 4, 1 do
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

    local blueprint = frameData[id][lowestDifficulty]

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

                            print(k, firstCurrentValue, higherArray[i])
                        
                            stringArray[lowerLengthID] = stringArray[lowerLengthID] .. firstCurrentValue .. " "
                            stringArray[higherLengthID] = stringArray[higherLengthID] .. higherArray[i] .. " "


                            if(firstFutureValue == higherArray[i + 1]) then
                                print("BREAK")
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

miog.selectInstance = function(journalInstanceID)
    --framePool:ReleaseAll()
    EJ_SelectInstance(journalInstanceID)

    if(miog.JOURNAL_INSTANCE_INFO[journalInstanceID].isRaid) then
        EJ_SetDifficulty(14)
        isRaid = true
        miog.AdventureJournal.KeylevelDropdown:Hide()
        
    else
        EJ_SetDifficulty(1)
        isRaid = false
        miog.AdventureJournal.KeylevelDropdown:Show()
    
    end


    local bossTable = {}
    local firstBossID = nil

    miog.AdventureJournal.BossDropdown:ResetDropDown()

    for i = 1, 50, 1 do
        local info = {}
        local name, description, journalEncounterID, rootSectionID, link, journalInstanceID2, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(i, journalInstanceID)

        if(name) then
            info.index = i
            info.entryType = "option"
            info.text = name
            info.value = journalEncounterID
            info.func = function()
                miog.selectBoss(journalInstanceID, journalEncounterID)

            end

            if(#bossTable == 0) then
                firstBossID = journalEncounterID

            end

            bossTable[#bossTable+1] = info
        end
    end

	for k, v in ipairs(bossTable) do
		miog.AdventureJournal.BossDropdown:CreateEntryFrame(v)

	end

    miog.selectBoss(journalInstanceID, firstBossID)
    miog.AdventureJournal.BossDropdown:SelectFirstFrameWithValue(firstBossID)
end

local difficultyIDs = {
    raid = {
        17,
        14,
        15,
        16
    },
    dungeon = {
        1,
        2,
        23,
        8
    }
}

local function retrieveItemInfoFromCurrentEncounter()
    lootPool:ReleaseAll()
    slotLinePool:ReleaseAll()

    lootData = {}

    for i = 1, 4, 1 do
        EJ_SetDifficulty(currentDifficultyIDs[i])

        for n = 1, EJ_GetNumLoot(), 1 do
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(n)

            if(itemInfo and itemInfo.name) then
                lootData[itemInfo.itemID] = lootData[itemInfo.itemID] or {
                    name = itemInfo.name,
                    icon = itemInfo.icon,
                    index = itemInfo.filterType or 20,
                    slot = itemInfo.slot == "" and "Other" or itemInfo.slot,
                    links = {}
                }

                table.insert(lootData[itemInfo.itemID].links, itemInfo.link)

            end
        end
    end

    local slotLines = {}

    print("-------------------------------")

    for k, v in pairs(lootData) do
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

        for x = 1, #v.links, 1 do
            frame.BasicInformation["Difficulty" .. x .. "Icon"]:SetTexture(v.icon)
            frame.BasicInformation["Difficulty" .. x .. "Icon"]:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(v.links[x])
            end)
            
        end

        frame:Show()
    end

    miog.AdventureJournal.LootFrame.Container:MarkDirty()
end

miog.selectBoss = function(journalInstanceID, journalEncounterID)
    basePool:ReleaseAll()
    --switchPool:ReleaseAll()

    currentEncounterID = journalEncounterID
    isRaid = miog.JOURNAL_INSTANCE_INFO[journalInstanceID].isRaid
        
    --EJ_SetDifficulty(currentDifficultyIDs[1])
    EJ_SelectEncounter(journalEncounterID)

	local stack = {}
    frameData = {}
    organizedFrameData = {}

    currentDifficultyIDs = difficultyIDs[isRaid and "raid" or "dungeon"]

    miog.AdventureJournal.Status:SetColorTexture(0, 1, 0)

    retrieveItemInfoFromCurrentEncounter()

    for i = 1, 4, 1 do
        EJ_SetDifficulty(currentDifficultyIDs[i])

        local _, _, _, rootSectionID = EJ_GetEncounterInfo(journalEncounterID)

        local counter = 1
        if(rootSectionID) then
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
                            local diffInfo = C_EncounterJournal.GetSectionInfo(rootSectionID)
                            local text = not diffInfo.filteredByDifficulty and diffInfo.description
                            
                            if(text) then
                                local desc = string.gsub(diffInfo.description, "|[cC]%x%x%x%x%x%x%x%x", "")
                                desc = string.gsub(desc, "$bullet; ", "")
                                --desc = string.gsub(desc, "|T(.+)|t", "")

                                frameData[diffInfo.title][currentDifficultyIDs[i]] = {
                                    title = diffInfo.title,
                                    description = desc,
                                    headerType = diffInfo.headerType,
                                    abilityIcon = diffInfo.abilityIcon,
                                    index = counter
                                }
                        
                            end
                        end
                    else
                        miog.AdventureJournal.Status:SetColorTexture(1, 0, 0)

                    end
                else
                    miog.AdventureJournal.Status:SetColorTexture(1, 0, 0)

                end

                rootSectionID = table.remove(stack)
            until not rootSectionID
        end
    end

    for id, difficultyData in pairs(frameData) do
        local compareArray = {}
        local compareValue

        for i = 1, 4, 1 do
            local array = difficultyData[currentDifficultyIDs[i]] and miog.simpleSplit(difficultyData[currentDifficultyIDs[i]].description, "%s")

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
        local lowestDifficulty = difficultyData[currentDifficultyIDs[1]] ~= nil and currentDifficultyIDs[1] or difficultyData[currentDifficultyIDs[2]] ~= nil and currentDifficultyIDs[2] or difficultyData[currentDifficultyIDs[3]] ~= nil and currentDifficultyIDs[3] or difficultyData[currentDifficultyIDs[4]] ~= nil and currentDifficultyIDs[4]

        if(lowestDifficulty) then
            organizedFrameData[difficultyData[lowestDifficulty].title] = {
                [currentDifficultyIDs[1]] = {},
                [currentDifficultyIDs[2]] = {},
                [currentDifficultyIDs[3]] = {},
                [currentDifficultyIDs[4]] = {},
            }

            local baseString = stopAndGo(id, equal, forwardOrdered)


            local concatString

            local frame
            local hasNoDifficultyData = compareArrayValues({#organizedFrameData[id][currentDifficultyIDs[1]], #organizedFrameData[id][currentDifficultyIDs[2]], #organizedFrameData[id][currentDifficultyIDs[3]], #organizedFrameData[id][currentDifficultyIDs[4]]}, 0)

            frame = basePool:Acquire()

            if(not equal and not forwardOrdered) then
                --frame = switchPool:Acquire()
                frame.SwitchPanel:Show()
                frame.DetailedInformation.Base:Hide()
                frame.DetailedInformation.Difficulty1:Hide()
                frame.DetailedInformation.Difficulty2:Hide()
                frame.DetailedInformation.Difficulty3:Hide()
                frame.DetailedInformation.Difficulty4:Hide()

            else
                frame.SwitchPanel:Hide()
            
            end
            
            if(hasNoDifficultyData) then
                frame.SwitchPanel:Hide()

                if(baseString == "") then
                    frame.ExpandFrame:SetShown(false)

                else
                    frame.DetailedInformation.Base:Show()
                    frame.ExpandFrame:SetShown(true)
                end
            else
                frame.DetailedInformation.Difficulty1:Show()
                frame.ExpandFrame:SetShown(true)
            
            end

            frame.layoutIndex = difficultyData[lowestDifficulty].index
            --frame.leftPadding = (difficultyData[lowestDifficulty].headerType or 0) * 20
            frame.fixedWidth = miog.AdventureJournal.AbilitiesFrame:GetWidth()
            frame.Name:SetText(difficultyData[lowestDifficulty].title)
            frame.Icon:SetTexture(difficultyData[lowestDifficulty].abilityIcon)
            frame:Show()

            frame.DetailedInformation.Difficulty1.Name:SetText(isRaid and "LFR" or "Normal")
            frame.DetailedInformation.Difficulty2.Name:SetText(isRaid and "Normal" or "Heroic")
            frame.DetailedInformation.Difficulty3.Name:SetText(isRaid and "Heroic" or "Mythic")
            frame.DetailedInformation.Difficulty4.Name:SetText(isRaid and "Mythic" or "Mythic+")

            frame.SwitchPanel.Switch1:SetText(isRaid and "L" or "N")
            frame.SwitchPanel.Switch2:SetText(isRaid and "N" or "H")
            frame.SwitchPanel.Switch3:SetText(isRaid and "H" or "M")
            frame.SwitchPanel.Switch4:SetText(isRaid and "M" or "M+")
            
            if(frame.DetailedInformation.Base) then
                frame.DetailedInformation.Base.Name:SetText("Base")
                frame.DetailedInformation.Base.Description:SetText(baseString)
            end

            for i = 1, 4, 1 do
                concatString = ""

                if(difficultyData[currentDifficultyIDs[i]] ~= nil) then
                    for k, v in ipairs(organizedFrameData[id][currentDifficultyIDs[i]]) do
                        if(v.colorIndex) then
                            concatString = concatString .. WrapTextInColorCode(v.string, miog.AJ_CLRSCC[v.colorIndex]) .. " "

                        else
                            concatString = concatString .. v.string .. " "

                        end

                    end

                    if(concatString == "") then
                        concatString = WrapTextInColorCode("Mechanic is implemented on " .. DifficultyUtil.GetDifficultyName(currentDifficultyIDs[i]), "FF00C200")

                    end
        
                else
                    concatString = WrapTextInColorCode("Mechanic not implemented on " .. DifficultyUtil.GetDifficultyName(currentDifficultyIDs[i]), "FFB92D27")
        
                end

                frame.DetailedInformation["Difficulty" .. i].Description:SetText(concatString)
            end
        end
    end

    miog.AdventureJournal.AbilitiesFrame.Container:MarkDirty()
end

miog.loadAdventureJournal = function()
    miog.AdventureJournal = CreateFrame("Frame", "MythicIOGrabber_AdventureJournal", miog.pveFrame2, "MIOG_AdventureJournal")
    miog.AdventureJournal:SetSize(miog.Plugin:GetSize())
    miog.AdventureJournal:SetPoint("TOPLEFT", miog.pveFrame2, "TOPRIGHT")
    frameWidth = miog.AdventureJournal.AbilitiesFrame:GetWidth()

    basePool = CreateFramePool("Frame", miog.AdventureJournal.AbilitiesFrame.Container, "MIOG_AdventureJournalAbilityTemplate", resetJournalFrames)
    lootPool = CreateFramePool("Frame", miog.AdventureJournal.LootFrame.Container, "MIOG_AdventureJournalLootItemTemplate", resetLootItemFrames)
    slotLinePool = CreateFramePool("Frame", miog.AdventureJournal.LootFrame.Container, "MIOG_AdventureJournalLootSlotLineTemplate", resetSlotLine)

	local instanceDropdown = miog.AdventureJournal.InstanceDropdown
	instanceDropdown:OnLoad()

	local bossDropdown = miog.AdventureJournal.BossDropdown
	bossDropdown:OnLoad()

	local keylevelDropdown = miog.AdventureJournal.KeylevelDropdown
    keylevelDropdown:OnLoad()

	local classSpecDropdown = miog.AdventureJournal.SettingsBar.ClassSpecDropdown
    classSpecDropdown:OnLoad()

    local info = {}
    info.entryType = "option"
    info.index = 0
    info.text = ALL_CLASSES
    info.value = 0
    info.func = function()
        EJ_SetLootFilter(0, 0)
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
                retrieveItemInfoFromCurrentEncounter()
            end

            classSpecDropdown:CreateEntryFrame(specInfo)
        end

    end

	local slotDropdown = miog.AdventureJournal.SettingsBar.SlotDropdown
    slotDropdown:OnLoad()

    for k, v in pairs(Enum.ItemSlotFilterType) do
        local info = {}
        info.entryType = "option"
        info.index = v
        info.text = k
        info.value = v
        info.func = function()
            C_EncounterJournal.SetSlotFilter(v)
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
            changingKeylevel = true
            miog.selectBoss(miog.AdventureJournal.currentInstanceID, currentEncounterID)
            changingKeylevel = false
        end

        miog.AdventureJournal.KeylevelDropdown:CreateEntryFrame(keyInfo)
    end

    miog.AdventureJournal.KeylevelDropdown:SelectFirstFrameWithValue(3)

    local instanceID = 1207
    EJ_SelectInstance(instanceID)
    EJ_SetDifficulty(14)
end