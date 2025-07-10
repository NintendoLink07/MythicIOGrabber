local addonName, miog = ...

miog.gearing = {}

local currentChildren = {}

local seasonID

local function createTrackString(itemLevel)
    local trackString

	for trackIndex, trackInfo in ipairs(miog.ITEM_LEVEL_DATA[seasonID].tracks) do
        --if(x == seasonID) then
            --REVERSED, SO NEW TRACKS ARE INFRONT
        --for k = #y.tracks, 1, -1 do
        local length = trackInfo.revisedLength or trackInfo.length
        for index = length, 1, -1 do
        --for index, trackItemLevel in pairs(trackInfo.itemlevels) do
            local trackItemLevel = trackInfo.itemlevels[index]

            if(trackItemLevel == itemLevel) then
                local tempString = WrapTextInColorCode(index .. "/" .. length, miog.ITEM_QUALITY_COLORS[trackIndex - 1].color:GenerateHexColor())
                trackString = trackString and trackString .. " " .. tempString or tempString

            end
        end

            --[[for i = 1, #trackInfo.itemlevels, 1 do
                if(currentEntry.level == itemLevel) then
                    local tempString = WrapTextInColorCode(i .. "/" .. currentEntry.length, miog.ITEM_QUALITY_COLORS[trackIndex - 1].color:GenerateHexColor())
                    trackString = trackString and trackString .. " " .. tempString or tempString
                end
            end]]
        --end
        --end
    end

    return trackString or ""
end

local function getColorForItemlevel(itemLevel)
    local gearingData = miog.ITEM_LEVEL_DATA[seasonID]
    local color
    
	for trackIndex, trackInfo in ipairs(miog.ITEM_LEVEL_DATA[seasonID].tracks) do
        if(itemLevel >= trackInfo.itemlevels[1] and itemLevel <= trackInfo.itemlevels[#trackInfo.itemlevels]) then
            color = miog.ITEM_QUALITY_COLORS[trackIndex - 1].color
            
        end
    end

    if(color == nil) then
        color = miog.ITEM_QUALITY_COLORS[0].color

    end

    return color:GenerateHexColor()
end

miog.gearing.getColorForItemlevel = getColorForItemlevel

local function insertGearingData()
    local gearingData = miog.GEARING_CHART[seasonID]
    local r, g, b

    for k, v in pairs(miog.GEARING_CHART) do
        if(k == seasonID) then
            for a in pairs(v.itemLevelInfo) do
                r, g, b = nil, nil, nil

                for x, y in ipairs(v.trackInfo) do

                    if(a > v.maxUpgradeItemLevel) then
                        r, g, b =  miog.ITEM_QUALITY_COLORS[6].color:GetRGB()
                        
                    else
                        for n = 1, y.length, 1 do
                            if(not v.awakenedInfo and a == y.data[n] or x ~= #v.trackInfo and a == y.data[n]) then
                                r, g, b =  miog.ITEM_QUALITY_COLORS[x - 1].color:GetRGB()
                            end
                        end
                    end
                end
        
                if(r == nil) then
                    r, g, b = miog.ITEM_QUALITY_COLORS[0].color:GetRGB()
        
                end

                currentChildren[a].ItemLevel:SetText(a)
                local fullDungeonText, fullDungeonVaultText, fullDelvesText, fullDelvesVaultText = "", "", "", ""

                for x, y in pairs(gearingData.dungeon.itemLevels) do
                    if(y == a) then
                        fullDungeonText = fullDungeonText .. (fullDungeonText == "" and gearingData.dungeon.info[x].name or "/" .. gearingData.dungeon.info[x].name)
                    end
                end

                for x, y in pairs(gearingData.dungeon.vaultLevels) do
                    if(y == a) then
                        fullDungeonVaultText = fullDungeonVaultText .. (fullDungeonVaultText == "" and gearingData.dungeon.info[x].name or "/" .. gearingData.dungeon.info[x].name)
                    end
        
                end
        
                for x, y in pairs(gearingData.raid.itemLevels) do
                    if(y == a) then
                        currentChildren[a].Raid:SetText(gearingData.raid.info[x].name)
                        currentChildren[a].Raid:SetTextColor(r, g, b, 1)
                    end
        
                end
        
                for x, y in pairs(gearingData.raid.veryRare.itemLevels) do
                    if(y == a) then
                        currentChildren[a].Raid:SetText(gearingData.raid.veryRare.info[x].name)
                        local r2, g2, b2 =  miog.ITEM_QUALITY_COLORS[x + 1].color:GetRGB()
                        currentChildren[a].Raid:SetTextColor(r2, g2, b2, 1)
                    end
        
                end

                for x, y in pairs(gearingData.delves.itemLevels) do
                    if(y == a) then
                        fullDelvesText = fullDelvesText .. (fullDelvesText == "" and gearingData.delves.info[x].name or "/" .. gearingData.delves.info[x].name)
                    end
                end

                for x, y in pairs(gearingData.delves.vaultLevels) do
                    if(y == a) then
                        fullDelvesVaultText = fullDelvesVaultText .. (fullDelvesVaultText == "" and gearingData.delves.info[x].name or "/" .. gearingData.delves.info[x].name)
                    end
                end
        
                for x, y in pairs(gearingData.other.itemLevels) do
                    if(y == a) then
                        currentChildren[a].Other:SetText(gearingData.other.info[x].name)
                        currentChildren[a].Other:SetTextColor(r,g,b,1)
                    end

                end

                if(fullDelvesText ~= "") then
                    currentChildren[a].Delves:SetText(fullDelvesText)
                end
                
                currentChildren[a].DelvesVault:SetText(fullDelvesVaultText)
                currentChildren[a].Dungeon:SetText(fullDungeonText)
                currentChildren[a].DungeonVault:SetText(fullDungeonVaultText)
                currentChildren[a].Track:SetText(createTrackString(tonumber(a)))


                currentChildren[a].ItemLevel:SetTextColor(r, g, b, 1)
                currentChildren[a].Dungeon:SetTextColor(r, g, b, 1)
                currentChildren[a].Delves:SetTextColor(r, g, b, 1)
                currentChildren[a].DelvesVault:SetTextColor(r, g, b, 1)
                currentChildren[a].DungeonVault:SetTextColor(r, g, b, 1)
            end

        end

    end
end

local function checkTable(name, itemlevel)
    local string

    if(miog.ITEM_LEVEL_DATA[seasonID][name].usedItemlevels[itemlevel]) then
        for x, y in ipairs(miog.NEW_GEARING_DATA[seasonID][name].usedItemlevels[itemlevel]) do
            if(string) then
                string = string .. "/" .. y

            else
                string = y

            end
        end
    end

    return string and WrapTextInColorCode(string, getColorForItemlevel(itemlevel))
end

local function checkSubtable(name, subname, itemlevel)
    local string

    if(miog.NEW_GEARING_DATA[seasonID][name][subname].usedItemlevels[itemlevel]) then

        for x, y in ipairs(miog.NEW_GEARING_DATA[seasonID][name][subname].usedItemlevels[itemlevel]) do
            if(string) then
                string = string .. "/" .. y

            else
                string = y

            end
        end
    end

    return string and WrapTextInColorCode(string, getColorForItemlevel(itemlevel))
end

local function retrieveSeasonID()
    seasonID = -1 or C_MythicPlus.GetCurrentSeason()

    if(seasonID < 1) then
        for k in pairs(miog.NEW_GEARING_DATA) do
            if(k > seasonID) then
                seasonID = k

            end
        end
    end
end

miog.loadGearingTable = function()
    miog.Gearing = miog.pveFrame2.TabFramesPanel.GearingTable

    miog.Gearing.GearingTable:OnLoad(nil, nil, 2, 2)
    
    retrieveSeasonID()
    
    local headers = {
        {name = "ILvl"},
        {name = "Track"},
        {name = "Delves", checkbox = true},
        {name = "Vault", id = "Delves", checkbox = true},
        {name = "Raid", checkbox = true},
        {name = "Dungeon", checkbox = true},
        {name = "Vault", id = "Dungeon",  checkbox = true},
        {name = "Other", checkbox = true},
    }
    miog.Gearing.GearingTable:CreateTable(false, headers, MIOG_NewSettings.gearingTable.headers)


    for trackIndex, data in pairs(miog.ITEM_LEVEL_DATA[seasonID].tracks) do
        --if(k == "tracks") then
            --for trackIndex, data in ipairs(v) do
                local currentLegendFrame = miog.Gearing.Legend["Track" .. trackIndex]

                if(currentLegendFrame) then
                    currentLegendFrame:SetColorTexture(miog.ITEM_QUALITY_COLORS[trackIndex - 1].color:GetRGBA())
                    currentLegendFrame:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(data.name)
                        GameTooltip:AddLine(LFG_LIST_ITEM_LEVEL_INSTR_SHORT .. ": " .. data.minLevel .. " - " .. data.maxLevel)
                        GameTooltip:Show()
                    end)
                end
            --end
        --end
    end

    if(not miog.NEW_GEARING_DATA[seasonID].awakenedInfo) then
        miog.Gearing.Legend["Track7"]:Hide()
        miog.Gearing.Legend:SetWidth(miog.Gearing.Legend:GetWidth() - miog.Gearing.Legend["Track7"]:GetWidth())
    end

    local counter = 1

    local fullTable = {}

    for k, v in ipairs(headers) do
        fullTable[k] = {}
    end

    local seasonalData = miog.ITEM_LEVEL_DATA[seasonID]

    --[[for trackIndex, data in ipairs(seasonalData.tracks) do
        data.minLevel = seasonalData.referenceMinLevel + (trackIndex - 1) * fullStep
        data.maxLevel = data.minLevel + getItemLevelIncreaseViaSteps((data.revisedLength or data.length) - 1)

    end]]

    local levelToIndex = {

    }

    for index, itemlevel in ipairs(seasonalData.itemLevelList) do
        tinsert(fullTable[1], WrapTextInColorCode(itemlevel, getColorForItemlevel(itemlevel)))
        tinsert(fullTable[2], createTrackString(itemlevel))

        levelToIndex[itemlevel] = index
    end

    local indices = {
        ["delves"] = 1,
        ["delvesBountiful"] = 1,
        ["dungeon"] = 4,
        ["raid"] = 3,
        ["crafting"] = 6,
    }

    local vaultIndices = {
        ["delves"] = 2,
        ["dungeon"] = 5,
    }

    for category, categoryData in pairs(seasonalData.data) do
        for index, data in ipairs(categoryData) do
            if(indices[category]) then
                local categoryIndex = indices[category] + 2
                local tableIndex = levelToIndex[data.level]
                local existingText = fullTable[categoryIndex][tableIndex]
                fullTable[categoryIndex][tableIndex] = WrapTextInColorCode(existingText and (existingText .. " / " .. data.name) or data.name, getColorForItemlevel(data.level))

            end

            if(vaultIndices[category] and not data.ignoreForVault) then
                local categoryIndex = vaultIndices[category] + 2
                local tableIndex = levelToIndex[data.vaultLevel]
                local existingText = fullTable[categoryIndex][tableIndex]
                fullTable[categoryIndex][tableIndex] = WrapTextInColorCode(existingText and (existingText .. " / " .. data.name) or data.name, getColorForItemlevel(data.vaultLevel))

            end
        end

        --local level, offset = getItemLevelIncreaseViaSteps(ilvlData.steps)
        --ilvlData.level = seasonalData.referenceMinLevel + level

        --if(ilvlData.vaultOffset) then
            --ilvlData.vaultLevel = ilvlData.level + getItemLevelIncreaseViaSteps(ilvlData.vaultOffset, offset)

        -- end
    end
    --[[for k, v in pairs(miog.NEW_GEARING_DATA[seasonID].allItemlevels) do
        if(miog.NEW_GEARING_DATA[seasonID].usedItemlevels[v]) then
            tinsert(fullTable[1], counter, WrapTextInColorCode(v, getColorForItemlevel(v)))
            tinsert(fullTable[2], counter, createTrackString(v))
            tinsert(fullTable[3], counter, checkTable("delves", v))
            tinsert(fullTable[4], counter, checkSubtable("delves", "vault", v))
            tinsert(fullTable[5], counter, checkTable("raid", v))
            tinsert(fullTable[6], counter, checkTable("dungeon", v))
            tinsert(fullTable[7], counter, checkSubtable("dungeon", "vault", v))
            tinsert(fullTable[8], counter, checkTable("other", v))

            counter = counter + 1
        end
    end]]

    for k, v in ipairs(fullTable) do
        miog.Gearing.GearingTable:AddTextToColumn(v, k)

    end
end