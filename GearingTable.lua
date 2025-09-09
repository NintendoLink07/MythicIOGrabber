local addonName, miog = ...

local gearingTab

miog.gearing = {}

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

local currentChildren = {}

local function createTrackString(itemLevel)
    local trackString

	for trackIndex, trackInfo in miog.rpairs(miog.ITEM_LEVEL_DATA[miog.F.SEASON_ID].tracks) do
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
    local color
    
	for trackIndex, trackInfo in ipairs(miog.ITEM_LEVEL_DATA[miog.F.SEASON_ID].tracks) do
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
    miog.F.SEASON_ID = C_MythicPlus.GetCurrentSeason()

    if(miog.F.SEASON_ID < 1) then
        for k in pairs(miog.NEW_GEARING_DATA) do
            if(k > miog.F.SEASON_ID) then
                miog.F.SEASON_ID = k

            end
        end
    end
end

local function setupGearingTable()
    local levelToIndex = {}
    local fullTable = {}

    for k in ipairs(headers) do
        fullTable[k] = {}
    end

    local seasonalData = miog.ITEM_LEVEL_DATA[miog.F.SEASON_ID]

    for index, itemlevel in ipairs(seasonalData.itemLevelList) do
        tinsert(fullTable[1], WrapTextInColorCode(itemlevel, getColorForItemlevel(itemlevel)))
        tinsert(fullTable[2], createTrackString(itemlevel))

        fullTable[1].maxIndex = index
        fullTable[2].maxIndex = index

        levelToIndex[itemlevel] = index
    end

    for trackIndex, data in pairs(miog.ITEM_LEVEL_DATA[miog.F.SEASON_ID].tracks) do
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

    gearingTab.tableBuilder:Reset()

    local dataProvider = CreateDataProvider()

    for category, categoryData in pairs(seasonalData.data) do
        for index, data in ipairs(categoryData) do
            if(indices[category]) then
                local categoryIndex = indices[category] + 2
                local tableIndex = levelToIndex[data.level]
                local existingText = fullTable[categoryIndex][tableIndex]
                fullTable[categoryIndex][tableIndex] = WrapTextInColorCode(existingText and (existingText .. " / " .. data.name) or data.name, getColorForItemlevel(data.level))

                fullTable[categoryIndex].maxIndex = fullTable[categoryIndex].maxIndex and fullTable[categoryIndex].maxIndex > tableIndex and fullTable[categoryIndex].maxIndex or tableIndex

            end

            if(vaultIndices[category] and not data.ignoreForVault) then
                local categoryIndex = vaultIndices[category] + 2
                local tableIndex = levelToIndex[data.vaultLevel]
                local existingText = fullTable[categoryIndex][tableIndex]
                fullTable[categoryIndex][tableIndex] = WrapTextInColorCode(existingText and (existingText .. " / " .. data.name) or data.name, getColorForItemlevel(data.vaultLevel))

                fullTable[categoryIndex].maxIndex = fullTable[categoryIndex].maxIndex and fullTable[categoryIndex].maxIndex > tableIndex and fullTable[categoryIndex].maxIndex or tableIndex

            end
        end
    end

    local rows = {}
    local columns = {}
    local calcWidth = gearingTab:GetWidth() - 60

    local firstIndex = 1
    local newHeaderArray = {}

    for i, v in ipairs(headers) do
        if(MIOG_NewSettings.gearingTable[v.name .. (v.id or "")] == false) then
            v.index = i
            tinsert(newHeaderArray, #newHeaderArray + 1, v)

        else
            v.index = i
            tinsert(newHeaderArray, firstIndex, v)

            firstIndex = firstIndex + 1
        end
    end

    for _, v in ipairs(newHeaderArray) do
        local dataIndex = v.index
        local column = gearingTab.tableBuilder:AddColumn()
        columns[_] = column
        column:ConstructHeader("Frame", v.checkbox and "MIOG_GearingTableCheckboxHeaderTemplate" or "MIOG_GearingTableHeaderTemplate", v.name)

        local header = column.headerFrame

        if(v.checkbox) then
            header.Checkbox:SetScript("OnClick", function(selfButton, button)
                MIOG_NewSettings.gearingTable[v.name .. (v.id or "")] = selfButton:GetChecked()
            
                setupGearingTable()
            end)

            header.Checkbox:SetChecked(MIOG_NewSettings.gearingTable[v.name .. (v.id or "")])

        end

        if(MIOG_NewSettings.gearingTable[v.name .. (v.id or "")] ~= false) then
            column:ConstructCells("Frame", "MIOG_GearingTableCellTemplate", dataIndex)
            local fixedWidth = 0
            local width = 0

            for k = 1, fullTable[dataIndex].maxIndex, 1 do
                rows[k] = rows[k] or {}

                if(fullTable[dataIndex][k]) then
                    local text = fullTable[dataIndex][k]
                    rows[k][dataIndex] = text

                    gearingTab.TestFontString:SetText(text)

                    width = gearingTab.TestFontString:GetStringWidth()

                    fixedWidth = width > fixedWidth and width or fixedWidth
                end
            end

            column.actualWidth = fixedWidth
            calcWidth = calcWidth - fixedWidth

        else
            column:ConstructCells("Frame", "BackdropTemplate", dataIndex)
            column.actualWidth = header.Text:GetStringWidth()
            calcWidth = calcWidth - column.actualWidth

        end
    end

    local addWidth = 0

    if(calcWidth > 0) then
        addWidth = calcWidth / #headers

    end

    for _, v in ipairs(columns) do
        v:SetFixedConstraints(v.actualWidth + addWidth + 4, 2)
    end
    
    gearingTab.view:SetElementExtent((gearingTab:GetHeight() - 50) / #seasonalData.itemLevelList)

    for k, v in pairs(rows) do
        dataProvider:Insert(v)

    end

    gearingTab.tableBuilder:Arrange()

    gearingTab.ScrollBox:SetDataProvider(dataProvider)
end

miog.loadGearingTable = function()
    miog.Gearing = miog.pveFrame2.TabFramesPanel.GearingTable

    gearingTab = miog.Gearing

    local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("BackdropTemplate", function(frame, data)

	end)
	view:SetPadding(1, 1, 1, 1, 0)

    gearingTab.view = view

	ScrollUtil.InitScrollBoxListWithScrollBar(gearingTab.ScrollBox, gearingTab.ScrollBar, view)

	local tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
	tableBuilder:SetHeaderContainer(gearingTab.HeaderContainer)
	tableBuilder:SetTableMargins(3, 3)

	local function ElementDataProvider(elementData, ...)
		return elementData

	end

	tableBuilder:SetDataProvider(ElementDataProvider)
    
	local function ElementDataTranslator(elementData, ...)
		return elementData

	end
	
	ScrollUtil.RegisterTableBuilder(gearingTab.ScrollBox, tableBuilder, ElementDataTranslator)

    miog.Gearing.tableBuilder = tableBuilder

    miog.Gearing:SetScript("OnSizeChanged", function()
        setupGearingTable()
    end)

    retrieveSeasonID()

    setupGearingTable()
end