local addonName, miog = ...

miog.gearing = {}

local currentChildren = {}

local seasonID

local function createTrackString(itemLevel)
    local trackString

	for trackIndex, trackInfo in miog.rpairs(miog.ITEM_LEVEL_DATA[seasonID].tracks) do
        for k, v in miog.rpairs(trackInfo.itemlevels) do

            if(v == itemLevel) then
                local tempString = WrapTextInColorCode(k .. "/" .. trackInfo.length, miog.ITEM_QUALITY_COLORS[trackIndex - 1].color:GenerateHexColor())
                trackString = trackString and trackString .. " " .. tempString or tempString

            end
        end
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
    end

    if(not miog.NEW_GEARING_DATA[seasonID].awakenedInfo) then
        miog.Gearing.Legend["Track7"]:Hide()
        miog.Gearing.Legend:SetWidth(miog.Gearing.Legend:GetWidth() - miog.Gearing.Legend["Track7"]:GetWidth())
    end

    local fullTable = {}

    for k in ipairs(headers) do
        fullTable[k] = {}
    end

    local seasonalData = miog.ITEM_LEVEL_DATA[seasonID]
    local levelToIndex = {}

    for index, itemlevel in ipairs(seasonalData.itemLevelList) do
        tinsert(fullTable[1], WrapTextInColorCode(itemlevel, getColorForItemlevel(itemlevel)))
        tinsert(fullTable[2], createTrackString(itemlevel))

        levelToIndex[itemlevel] = index
    end

    local indices = {
        ["delves"] = 1,
        ["delvesBounty"] = 1,
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
    end

    for k, v in ipairs(fullTable) do
        miog.Gearing.GearingTable:AddTextToColumn(v, k)

    end
end