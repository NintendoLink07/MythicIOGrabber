local addonName, miog = ...

local function retrieveAbbreviatedName(flyoutSpellID)
	local mapID = miog.TELEPORT_SPELLS_TO_MAP[flyoutSpellID]
	local abbreviatedName

	if(mapID) then
		miog.MAP_INFO[mapID].teleport = flyoutSpellID
		local mapInfo = miog.MAP_INFO[mapID]
		abbreviatedName = mapInfo.abbreviatedName

	else
		abbreviatedName = ""

	end

	return abbreviatedName
end

local function sortTeleports(k1, k2)
	if(k1.type == "icon") then
		return true

	elseif(k2.type == "icon") then
		return false

	elseif(k2.type == "dungeon") then
        return k1.abbreviatedName < k2.abbreviatedName

	else
		return k1.initialIndex < k2.initialIndex
    end
end

local function refreshTeleports()
    local teleports = miog.Teleports
    teleports.tableBuilder:Reset()

    local dataProvider = CreateDataProvider()
	local columns = {}
	local dataTable = {}

	local iconColumn = teleports.tableBuilder:AddColumn()
	iconColumn:ConstructCells("Frame", "MIOG_TeleportLogoTemplate")
	iconColumn:SetFixedConstraints(32, 6)

	for _, info in ipairs(miog.TELEPORT_FLYOUT_IDS) do
		local tableIndex = info.expansion - 2
		local existingDataTable = dataTable[tableIndex]

		if(not existingDataTable) then
			dataTable[tableIndex] = {}

			
			tinsert(dataTable[tableIndex], {type = "icon", icon = miog.EXPANSIONS[info.expansion].icon})

			existingDataTable = dataTable[tableIndex]
		end

		local name, description, numSlots, isKnown = GetFlyoutInfo(info.id)

		local currentTable = {}

		for k = 1, numSlots, 1 do
       		local flyoutSpellID, _, spellKnown, spellName, _ = GetFlyoutSlotInfo(info.id, k)

			tinsert(currentTable, {
				type = info.type,
				initialIndex = k,
				abbreviatedName = retrieveAbbreviatedName(flyoutSpellID),
				flyoutSpellID = flyoutSpellID,
				isKnown = spellKnown}
			)
		end

		table.sort(currentTable, sortTeleports)

		if(info.type == "raid") then
			tinsert(existingDataTable, {type = "fill"})
			
		end

		for _, v in ipairs(currentTable) do
			v.index = #existingDataTable

			local column = columns[v.index]
			
			if(not column) then
				column = teleports.tableBuilder:AddColumn()
				column:ConstructCells("Button", "MIOG_TeleportButtonTemplate")
				column:SetFixedConstraints(32, 7)

				columns[v.index] = column
			end

			tinsert(existingDataTable, v)

		end

    end

	for _, v in ipairs(dataTable) do
		dataProvider:Insert(v)

	end

    teleports.tableBuilder:Arrange()
    teleports.ScrollBox:SetDataProvider(dataProvider)
end

miog.loadTeleports = function()
	miog.Teleports = miog.pveFrame2.TabFramesPanel.Teleports
    local teleports = miog.Teleports

    local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("MIOG_TeleportLineTemplate", function(frame, data)

	end)
	view:SetPadding(12, 1, 1, 1, 13)

    teleports.view = view

	ScrollUtil.InitScrollBoxListWithScrollBar(teleports.ScrollBox, miog.pveFrame2.ScrollBarArea.TeleportsScrollBar, view)

	local tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
	tableBuilder:SetTableMargins(3, 5)

	local function ElementDataProvider(elementData, ...)
		return elementData

	end

	tableBuilder:SetDataProvider(ElementDataProvider)
    
	local function ElementDataTranslator(elementData, ...)
		return elementData

	end
	
	ScrollUtil.RegisterTableBuilder(teleports.ScrollBox, tableBuilder, ElementDataTranslator)

    teleports.tableBuilder = tableBuilder

    refreshTeleports()
end