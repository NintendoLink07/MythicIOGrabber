local addonName, miog = ...

local gearingTab

miog.gearing = {}

local headersNew = {
    [1] = {id = "ilvl", name = "ILvl"},
    [2] = {id = "track", name = "Track"},
    [3] = {id = "delves", hasSetting = true, name = "Delves"},
    [4] = {id = "delvesVault", hasSetting = true, name = "Dlv Vault"},
    [5] = {id = "raid", hasSetting = true, name = "Raid"},
    [6] = {id = "dungeon", hasSetting = true, name = "Dungeon"},
    [7] = {id = "dungeonVault", hasSetting = true, name = "Dun Vault"},
    [8] = {id = "prey", hasSetting = true, name = "Prey"},
    [9] = {id = "other", hasSetting = true, name = "Other"},
}

local indices = {
    ["delves"] = 3,
    ["dungeon"] = 6,
    ["raid"] = 5,
    ["prey"] = 8,
    ["other"] = 9,
}

local vaultIndices = {
    ["delves"] = 4,
    ["dungeon"] = 7,
}

local function createTrackString(itemLevel)
    local trackString

	for trackIndex, trackInfo in miog.rpairs(miog.ITEM_LEVEL_DATA[miog.F.SEASON_ID].tracks) do
        for k, v in miog.rpairs(trackInfo.itemlevels) do
            if(v == itemLevel) then
                local tempString = WrapTextInColorCode(k .. "/" .. trackInfo.length, miog.ITEM_QUALITY_COLORS[trackIndex].color:GenerateHexColor())
                trackString = trackString and trackString .. " " .. tempString or tempString

            end
        end
    end

    return trackString or ""
end

local function getColorForItemlevel(itemLevel)
    local color
    
	for trackIndex, trackInfo in ipairs(miog.ITEM_LEVEL_DATA[miog.F.SEASON_ID].tracks) do
        if(itemLevel >= trackInfo.itemlevels[1] and itemLevel <= trackInfo.itemlevels[#trackInfo.itemlevels]) then
            color = miog.ITEM_QUALITY_COLORS[trackIndex].color
            
        end
    end

    if(color == nil) then
        color = miog.ITEM_QUALITY_COLORS[0].color

    end

    return color:GenerateHexColor()
end

miog.gearing.getColorForItemlevel = getColorForItemlevel

local function retrieveSeasonID()
    miog.F.SEASON_ID = 16 or C_MythicPlus.GetCurrentSeason()

    if(miog.F.SEASON_ID < 1) then
        for k in pairs(miog.NEW_GEARING_DATA) do
            if(k > miog.F.SEASON_ID) then
                miog.F.SEASON_ID = k

            end
        end
    end
end

local function calculateStringWidth(string)
    gearingTab.TestFontString:SetText(string)

    return gearingTab.TestFontString:GetStringWidth()
end

local function createGearingDataTable()
    gearingTab.tableBuilder:Reset()

    local dataProvider = CreateDataProvider()
    local seasonalData = miog.ITEM_LEVEL_DATA[miog.F.SEASON_ID]

    local revisedHeaderOrder = {}
    local revisedIndices = {}
    local enabledIndex = 1

    for headerIndex, headerData in ipairs(headersNew) do
        local enabled = MIOG_NewSettings.gearingTable[headerData.id] ~= false
        headerData.enabled = enabled

        if(enabled ~= false) then
            tinsert(revisedHeaderOrder, enabledIndex, {index = headerIndex, enabled = enabled})

            enabledIndex = enabledIndex + 1

        else
            tinsert(revisedHeaderOrder, #revisedHeaderOrder + 1, {index = headerIndex, enabled = enabled})

        end

    end

    for index, headerInfo in ipairs(revisedHeaderOrder) do
        local headerData = headersNew[headerInfo.index]

        revisedIndices[headerData.id] = index

        local column = gearingTab.tableBuilder:AddColumn()

        column:ConstructHeader("Frame", "MIOG_GearingTableColorHeaderTemplate", headerData.name, headerData.hasSetting, MIOG_NewSettings.gearingTable, headerData.id, function() createGearingDataTable() end)
        column:ConstructCells("Frame", "MIOG_GearingTableColorCellTemplate")

        local stringWidth = calculateStringWidth(headerData.name)

        headerData.width = stringWidth + 2
        headerData.tableColumn = column
        column:SetFixedConstraints(headerData.width + 4, 1)
    end

    local dataProviderTable = {}
    local translator = {}
    local stringWidth
    local itemLevelColors = {}

    for rowIndex, itemLevel in ipairs(seasonalData.itemLevelList) do
        dataProviderTable[rowIndex] = {}
        translator[itemLevel] = rowIndex

        local itemLevelString = WrapTextInColorCode(itemLevel, getColorForItemlevel(itemLevel))
        dataProviderTable[rowIndex][1] = {text = itemLevelString}
        stringWidth = calculateStringWidth(itemLevelString)
        headersNew[1].width = stringWidth > headersNew[1].width and stringWidth or headersNew[1].width

        local trackString = createTrackString(itemLevel)
        dataProviderTable[rowIndex][2] = {text = trackString}
        stringWidth = calculateStringWidth(trackString)
        headersNew[2].width = stringWidth > headersNew[2].width and stringWidth or headersNew[2].width
        
        itemLevelColors[itemLevel] = getColorForItemlevel(itemLevel)
    end

    for id, data in pairs(seasonalData.data) do
        local formerBaseIndex = indices[id]
        local formerVaultIndex = vaultIndices[id]

        local baseHeaderData = headersNew[formerBaseIndex]
        local vaultHeaderData = headersNew[formerVaultIndex]

        local baseTableIndex = revisedIndices[baseHeaderData.id]
        local vaultTableIndex

        if(id == "delves" or id == "dungeon") then
            vaultTableIndex = revisedIndices[vaultHeaderData.id]

        end

        for _, entryData in ipairs(data) do
            local rowCellData
            local baseItemLevel, vaultItemLevel = entryData.level, entryData.vaultLevel
            local currentName = entryData.name

            if(baseHeaderData.enabled) then
                rowCellData = dataProviderTable[translator[baseItemLevel]][baseTableIndex]
                
                if(not rowCellData) then
                    dataProviderTable[translator[baseItemLevel]][baseTableIndex] = {text = WrapTextInColorCode(currentName, itemLevelColors[baseItemLevel]), tooltip = entryData.tooltip}

                else
                    dataProviderTable[translator[baseItemLevel]][baseTableIndex] = {text = WrapTextInColorCode(rowCellData.text .. "/" .. currentName, itemLevelColors[baseItemLevel]), tooltip = entryData.tooltip}

                end
                
                rowCellData = dataProviderTable[translator[baseItemLevel]][baseTableIndex]

                print(rowCellData.text)

                stringWidth = calculateStringWidth(rowCellData.text)
                headersNew[formerBaseIndex].width = stringWidth > headersNew[formerBaseIndex].width and stringWidth or headersNew[formerBaseIndex].width
            end
                
            if(entryData.vaultOffset and vaultHeaderData.enabled and vaultTableIndex) then
                rowCellData = dataProviderTable[translator[vaultItemLevel]][vaultTableIndex]
            
                if(not rowCellData) then
                    dataProviderTable[translator[vaultItemLevel]][vaultTableIndex] = {text = WrapTextInColorCode(currentName, itemLevelColors[vaultItemLevel]), tooltip = entryData.tooltip}

                else
                    dataProviderTable[translator[vaultItemLevel]][vaultTableIndex] = {text = WrapTextInColorCode(rowCellData.text .. "/" .. currentName, itemLevelColors[vaultItemLevel]), tooltip = entryData.tooltip}

                end
                
                rowCellData = dataProviderTable[translator[vaultItemLevel]][vaultTableIndex]

                stringWidth = calculateStringWidth(rowCellData.text)

                headersNew[formerVaultIndex].width = stringWidth > headersNew[formerVaultIndex].width and stringWidth or headersNew[formerVaultIndex].width
            end
        end
    end

    for _, headerData in ipairs(headersNew) do
        headerData.tableColumn:SetFixedConstraints(headerData.width + 6, 1)

    end

    for k, v in ipairs(dataProviderTable) do
        dataProvider:Insert({array = v, rowIndex = k})

    end

    gearingTab.tableBuilder:Arrange()
    gearingTab.ScrollBox:SetDataProvider(dataProvider)
end

miog.loadGearingTable = function()
    retrieveSeasonID()

    miog.Gearing = miog.pveFrame2.TabFramesPanel.GearingTable

    gearingTab = miog.Gearing

    local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("BackdropTemplate", function(frame, data)
        --line template
	end)
	view:SetPadding(0, 0, 0, 0, 0)
    view:SetElementExtent(15)

	ScrollUtil.InitScrollBoxListWithScrollBar(gearingTab.ScrollBox, gearingTab.ScrollBar, view)

	local tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
	tableBuilder:SetHeaderContainer(gearingTab.HeaderContainer)
    tableBuilder:SetTableMargins(1, 1)

	local function ElementDataProvider(elementData, ...)
		return elementData

	end

	tableBuilder:SetDataProvider(ElementDataProvider)
    
	local function ElementDataTranslator(elementData, ...)
		return elementData

	end
	
	ScrollUtil.RegisterTableBuilder(gearingTab.ScrollBox, tableBuilder, ElementDataTranslator)

    gearingTab.tableBuilder = tableBuilder
    gearingTab.view = view

    local seasonalData = miog.ITEM_LEVEL_DATA[miog.F.SEASON_ID]

    gearingTab:SetScript("OnSizeChanged", function(self)
        --self.view:SetElementExtent((gearingTab:GetHeight() - 50) / #seasonalData.itemLevelList)

        --createGearingDataTable()
    end)

    createGearingDataTable()

    for trackIndex, data in pairs(seasonalData.tracks) do
        local currentLegendFrame = gearingTab.Legend["Track" .. trackIndex]

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
end