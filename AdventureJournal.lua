local addonName, miog = ...

local regex1 = "%d+ %w+ damage"
local regex2 = "%d+ damage"

local basePool, switchPool
local isRaid
local changingKeylevel = false

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

    if(frame.DetailedInformation.Base) then
        frame.DetailedInformation.Base.Name:SetText()
        frame.DetailedInformation.Base.Description:SetText()
    end

    frame.DetailedInformation.Difficulty1.Name:SetText()
    frame.DetailedInformation.Difficulty1.Description:SetText()

    frame.DetailedInformation.Difficulty2.Name:SetText()
    frame.DetailedInformation.Difficulty2.Description:SetText()

    frame.DetailedInformation.Difficulty3.Name:SetText()
    frame.DetailedInformation.Difficulty3.Description:SetText()

    frame.DetailedInformation.Difficulty4.Name:SetText()
    frame.DetailedInformation.Difficulty4.Description:SetText()
end

local frameData = {}
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

local function findStringDifferences(id, difficultyID1, difficultyID2) -- 
    local lowestDifficultyID = frameData[id][currentDifficultyIDs[1]] and currentDifficultyIDs[1] or frameData[id][currentDifficultyIDs[2]] and currentDifficultyIDs[2] or frameData[id][currentDifficultyIDs[3]] and currentDifficultyIDs[3] or frameData[id][currentDifficultyIDs[4]] and currentDifficultyIDs[4]
    local lowestDifficultyIndex = frameData[id][currentDifficultyIDs[1]] and 1 or frameData[id][currentDifficultyIDs[2]] and 2 or frameData[id][currentDifficultyIDs[3]] and 3 or frameData[id][currentDifficultyIDs[4]] and 4

    --local firstArray = frameData[id][difficultyID1] and miog.simpleSplit(frameData[id][difficultyID1], "%s") or {}
    --local secondArray = frameData[id][difficultyID2] and miog.simpleSplit(frameData[id][difficultyID2], "%s") or {}


    local colorCounter

   --[[ for i = lowestDifficultyIndex + 1, 4, 1 do
        colorCounter = 1

        if(frameData[id][currentDifficultyIDs[lowestDifficultyIndex] ] and frameData[id][currentDifficultyIDs[i] ]) then
            local baseArray = miog.simpleSplit(frameData[id][currentDifficultyIDs[lowestDifficultyIndex] ], "%s") or {}
            local checkArray = miog.simpleSplit(frameData[id][currentDifficultyIDs[i] ], "%s") or {}

            for k, v in ipairs(baseArray) do
                local baseValue = baseArray[k]
                local checkValue = checkArray[k]

                if(baseValue and checkValue) then
                    if(baseValue ~= checkValue) then
                        organizedFrameData[id][currentDifficultyIDs[lowestDifficultyIndex] ][k] = colorCounter

                        colorCounter = colorCounter + 1

                    end

                else
                    organizedFrameData[id][currentDifficultyIDs[lowestDifficultyIndex] ][k] = nil
                
                end
            end
        end
    end

    local longCheck = false
    local longCheckString = ""

    for i = 2, 4, 1 do
        colorCounter = 1

        if(frameData[id][currentDifficultyIDs[i] ] and frameData[id][currentDifficultyIDs[i - 1] ]) then
            local baseArray = miog.simpleSplit(frameData[id][currentDifficultyIDs[i] ], "%s") or {}
            local checkArray = miog.simpleSplit(frameData[id][currentDifficultyIDs[i - 1] ], "%s") or {}

            for k, v in ipairs(baseArray) do
                local baseValue = baseArray[k]
                local checkValue = checkArray[k]

                if(baseValue and checkValue) then
                    if(id == "Lightning Devastation") then
                        print(baseValue, checkValue)
                    end

                    if(baseValue ~= checkValue) then
                        organizedFrameData[id][currentDifficultyIDs[i] ][k] = colorCounter

                        colorCounter = colorCounter + 1

                    end

                else
                    organizedFrameData[id][currentDifficultyIDs[i] ][k] = nil
                
                end
            end
        end
    end]]
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

local function stopAndGo(id, equal, smallest, largest)
    local lowestIndex = frameData[id][currentDifficultyIDs[1]] and 1 or frameData[id][currentDifficultyIDs[2]] and 2 or frameData[id][currentDifficultyIDs[3]] and 3 or frameData[id][currentDifficultyIDs[4]] and 4
    local lowestDifficulty = currentDifficultyIDs[lowestIndex]

    local baseString

    if(equal) then
        baseString = ""

        for n = 1, 3, 1 do
            local array1 = frameData[id][currentDifficultyIDs[n]] and miog.simpleSplit(frameData[id][currentDifficultyIDs[n]].description, "%s") or {}
            local array2 = frameData[id][currentDifficultyIDs[n + 1]] and miog.simpleSplit(frameData[id][currentDifficultyIDs[n + 1]].description, "%s") or {}
    
            local shift = 0

            local xCounter = 1
    
            for k, v in ipairs(array2) do
                local firstCurrentValue = array1[k]
                local firstFutureValue = array1[k + 1]

                local thirdCurrentValue = array2[k + shift]

                if(firstCurrentValue and thirdCurrentValue) then
                    for i = k + shift, #array2, 1 do
                        local thirdFutureValue = array2[i]
                        
                        if(firstCurrentValue == array2[i]) then
                            if(n == 1) then
                                baseString = baseString .. firstCurrentValue .. " "
                            end

                            break

                        else
                            if(n == 1) then
                                table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = array1[i], colorIndex = xCounter})
                                baseString = baseString .. WrapTextInColorCode("[" .. xCounter .. "]", miog.AJ_CLRSCC[xCounter]) .. " "
                                
                            end

                            table.insert(organizedFrameData[id][currentDifficultyIDs[n + 1]], {string = array2[i], colorIndex = xCounter})

                            xCounter = xCounter + 1
                            
                            --[[if(array2[i + 1] == "million" or array2[i + 1] == "billion") then
                                shift = shift + 2

                                table.insert(organizedFrameData[id][currentDifficultyIDs[n] ], {string = array2[i + 1], colorIndex = xCounter})

                                break

                            end]]

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
    else

        --IMPLEMENT FORWARD ARRAYS

        local arraySizes = {}
    
        for n = 1, 4, 1 do
            if(frameData[id][currentDifficultyIDs[n]]) then
                table.insert(organizedFrameData[id][currentDifficultyIDs[n]], {string = frameData[id][currentDifficultyIDs[n]].description})

                table.insert(arraySizes, #(miog.simpleSplit(frameData[id][currentDifficultyIDs[n]].description, "%s") or {}))
            end
        end

        --print(id, "NOT EQUAL", arraySizes[1], arraySizes[2], arraySizes[3], arraySizes[4])
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

    --if(id == "Lightning Devastation") then
        --print("B", baseString)
        --print(1, stringArray[currentDifficultyIDs[1]])
        --print(2, stringArray[currentDifficultyIDs[2]])
        --print(3, stringArray[currentDifficultyIDs[3]])
        --print(4, stringArray[currentDifficultyIDs[4]])

    --end

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

    miog.AdventureJournal.BossDropdown.List:MarkDirty()

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

miog.selectBoss = function(journalInstanceID, journalEncounterID)
    currentEncounterID = journalEncounterID

    if(miog.JOURNAL_INSTANCE_INFO[journalInstanceID].isRaid) then
        EJ_SetDifficulty(14)
        isRaid = true
        
    else
        EJ_SetDifficulty(1)
        isRaid = false
    
    end

    EJ_SelectEncounter(journalEncounterID)

    basePool:ReleaseAll()
    switchPool:ReleaseAll()

	local stack = {}
    frameData = {}
    organizedFrameData = {}

    currentDifficultyIDs = difficultyIDs[isRaid and "raid" or "dungeon"]
    miog.AdventureJournal.Status:SetColorTexture(0, 1, 0)

    local name, description, _, rootSectionID, link, journalInstanceID2, dungeonEncounterID, instanceID = EJ_GetEncounterInfo(journalEncounterID)

    local counter = 1

    if(rootSectionID) then
        repeat
            local info = C_EncounterJournal.GetSectionInfo(rootSectionID)

            if(info and info.title) then
                frameData[info.title] = {}

                if(info.description == nil) then
                    miog.AdventureJournal.Status:SetColorTexture(1, 0, 0)
                
                end
                
                counter = counter + 1

                table.insert(stack, info.siblingSectionID)
                table.insert(stack, info.firstChildSectionID)
                
                for i = 1, 4, 1 do
                    EJ_SetDifficulty(currentDifficultyIDs[i])
                    local diffInfo = C_EncounterJournal.GetSectionInfo(rootSectionID)
                    local text = not diffInfo.filteredByDifficulty and diffInfo.description

                    diffInfo.index = counter
                    
                    if(text and diffInfo.title) then
                        frameData[diffInfo.title][currentDifficultyIDs[i]] = diffInfo
                
                    end
                end
            end

            rootSectionID = table.remove(stack)
        until not rootSectionID

        
    end

    for id, difficultyData in pairs(frameData) do
        local compareArray = {}
        local compareValue

        local smallestValue = 10000
        local largestValue = 0

        for i = 1, 4, 1 do
            local array = difficultyData[currentDifficultyIDs[i]] and miog.simpleSplit(difficultyData[currentDifficultyIDs[i]].description, "%s")

            if(array) then
                smallestValue = min(smallestValue, #array)
                largestValue = max(largestValue, #array)

                if(compareValue) then
                    table.insert(compareArray, #array)
                    
                else
                    compareValue = #array

                end
            end
        end
        
        local equal = compareArrayValues(compareArray, compareValue)
        local frame

        if(equal) then
            frame = basePool:Acquire()

        else
            frame = switchPool:Acquire()

            frame.SwitchPanel.Switch1:SetText(isRaid and "L" or "N")
            frame.SwitchPanel.Switch2:SetText(isRaid and "N" or "H")
            frame.SwitchPanel.Switch3:SetText(isRaid and "H" or "M")
            frame.SwitchPanel.Switch4:SetText(isRaid and "M" or "M+")
        end

        local lowestDifficulty = difficultyData[currentDifficultyIDs[1]] ~= nil and currentDifficultyIDs[1] or difficultyData[currentDifficultyIDs[2]] ~= nil and currentDifficultyIDs[2] or difficultyData[currentDifficultyIDs[3]] ~= nil and currentDifficultyIDs[3] or difficultyData[currentDifficultyIDs[4]] ~= nil and currentDifficultyIDs[4]

        frame.layoutIndex = difficultyData[lowestDifficulty].index
        frame.leftPadding = (difficultyData[lowestDifficulty].headerType or 0) * 20
        frame.Name:SetText(difficultyData[lowestDifficulty].title)
        frame.Icon:SetTexture(difficultyData[lowestDifficulty].abilityIcon)
        frame:Show()

        frame.DetailedInformation.Difficulty1.Name:SetText(isRaid and "LFR" or "Normal")
        frame.DetailedInformation.Difficulty2.Name:SetText(isRaid and "Normal" or "Heroic")
        frame.DetailedInformation.Difficulty3.Name:SetText(isRaid and "Heroic" or "Mythic")
        frame.DetailedInformation.Difficulty4.Name:SetText(isRaid and "Mythic" or "Mythic+")
        

        organizedFrameData[difficultyData[lowestDifficulty].title] = {
            [currentDifficultyIDs[1]] = {},
            [currentDifficultyIDs[2]] = {},
            [currentDifficultyIDs[3]] = {},
            [currentDifficultyIDs[4]] = {},
        }
        
        frame.ExpandFrame:SetShown(difficultyData[currentDifficultyIDs[1]] ~= nil or difficultyData[currentDifficultyIDs[2]] ~= nil or difficultyData[currentDifficultyIDs[3]] ~= nil or difficultyData[currentDifficultyIDs[4]] ~= nil)

        local baseString = stopAndGo(id, equal, smallestValue, largestValue)

        if(frame.DetailedInformation.Base) then
            frame.DetailedInformation.Base.Name:SetText("Base")
            frame.DetailedInformation.Base.Description:SetText(baseString)
        end

        local concatString

        for i = 1, 4, 1 do
            concatString = ""

            if(difficultyData[currentDifficultyIDs[i]] ~= nil) then
                for k, v in ipairs(organizedFrameData[id][currentDifficultyIDs[i]]) do
                    concatString = concatString .. WrapTextInColorCode(v.string, miog.AJ_CLRSCC[v.colorIndex] or "FFFFFFFF") .. " "

                end
     
             else
                 concatString = WrapTextInColorCode("Mechanic not implemented on " .. DifficultyUtil.GetDifficultyName(currentDifficultyIDs[i]), "FFB92D27")
     
             end

             frame.DetailedInformation["Difficulty" .. i].Description:SetText(concatString)
        end
    end

    miog.AdventureJournal.ScrollFrame.Container:MarkDirty()
end

miog.loadAdventureJournal = function()
    miog.AdventureJournal = CreateFrame("Frame", "MythicIOGrabber_AdventureJournal", miog.pveFrame2, "MIOG_AdventureJournal")
    miog.AdventureJournal:SetSize(miog.Plugin:GetSize())
    miog.AdventureJournal:SetPoint("TOPLEFT", miog.pveFrame2, "TOPRIGHT")

    basePool = CreateFramePool("Frame", miog.AdventureJournal.ScrollFrame.Container, "MIOG_AdventureJournalAbilityTemplate", resetJournalFrames)
    switchPool = CreateFramePool("Frame", miog.AdventureJournal.ScrollFrame.Container, "MIOG_AdventureJournalAbilityWithSwitchTemplate", resetJournalFrames)

	local instanceDropdown = miog.AdventureJournal.InstanceDropdown
	instanceDropdown:OnLoad()

	local bossDropdown = miog.AdventureJournal.BossDropdown
	bossDropdown:OnLoad()

	local keylevelDropdown = miog.AdventureJournal.KeylevelDropdown
    keylevelDropdown:OnLoad()
    
    local keytable = {}


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