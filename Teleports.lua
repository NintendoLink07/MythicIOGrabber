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

local tpButtonPool

miog.addTeleportButtons2 = function()
	tpButtonPool:ReleaseAll()
	
	local lastExpansionFrames = {}

	for index, info in ipairs(miog.TELEPORT_FLYOUT_IDS) do
		local name, description, numSlots, isKnown = GetFlyoutInfo(info.id)

		local expansionInfo = GetExpansionDisplayInfo(info.expansion)

		local logoFrame = miog.Teleports[tostring(info.expansion)]

		if(logoFrame and expansionInfo) then
			logoFrame.Texture:SetTexture(expansionInfo.logo)

			local expNameTable = {}

		    local name, description, numSlots, isKnown = GetFlyoutInfo(info.id)
			for k = 1, numSlots, 1 do
				local flyoutSpellID, _, spellKnown, spellName, _ = GetFlyoutSlotInfo(info.id, k)
				local desc, abbreviatedName = retrieveSpellInfo(flyoutSpellID)

				if(desc == "") then
					local spell = Spell:CreateFromSpellID(flyoutSpellID)
					spell:ContinueOnSpellLoad(function()
						--desc, abbreviatedName = retrieveSpellInfo(flyoutSpellID)
						--expNameTable[#expNameTable+1] = {name = spellName, desc = desc, spellID = flyoutSpellID, type = info.type, known = spellKnown, abbreviatedName = abbreviatedName}

						miog.addTeleportButtons2()
					end)
				else
					expNameTable[#expNameTable+1] = {name = spellName, desc = desc, spellID = flyoutSpellID, type = info.type, known = spellKnown, abbreviatedName = abbreviatedName}


				end
			end

			table.sort(expNameTable, function(k1, k2)
				if(k1.type == "dungeon") then
					return k1.abbreviatedName < k2.abbreviatedName

				else
					return k1.spellID < k2.spellID

				end
			end)

			for k, v in ipairs(expNameTable) do
				local spellInfo = C_Spell.GetSpellInfo(v.spellID)
				local tpButton = tpButtonPool:Acquire()
				tpButton:SetNormalTexture(spellInfo.iconID)
				tpButton:GetNormalTexture():SetDesaturated(not v.known)
				tpButton:SetPoint("LEFT", lastExpansionFrames[info.expansion] or logoFrame, "RIGHT", lastExpansionFrames[info.expansion] and k == 1 and 18 or 3, 0)

				lastExpansionFrames[info.expansion] = tpButton

				if(v.known) then
					local myCooldown = tpButton.Cooldown
					
					tpButton:HookScript("OnShow", function()
						local spellCooldownInfo = C_Spell.GetSpellCooldown(v.spellID)
						--local start, duration, _, modrate = GetSpellCooldown(v.spellID)
						myCooldown:SetCooldown(spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.modRate)

						local secondsLeft = spellCooldownInfo.duration - (GetTime() - spellCooldownInfo.startTime)
						local text = secondsLeft > 0 and WrapTextInColorCode("Remaining CD: " .. formatter:Format(secondsLeft), miog.CLRSCC.red) or WrapTextInColorCode("Ready", miog.CLRSCC.green)

						miog.Teleports.Remaining:SetText(text)
					end)

					tpButton:SetHighlightAtlas("communities-create-avatar-border-hover")
					tpButton:SetAttribute("type", "spell")
					tpButton:SetAttribute("spell", spellInfo.name)
					tpButton:RegisterForClicks("LeftButtonDown")

					tpButton.Text:SetText(v.abbreviatedName or WrapTextInColorCode("MISSING", "FFFF0000"))

				end

				local spell = Spell:CreateFromSpellID(v.spellID)
				spell:ContinueOnSpellLoad(function()
					tpButton:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip_AddHighlightLine(GameTooltip, v.name)
						GameTooltip:AddLine(spell:GetSpellDescription())
						GameTooltip:Show()
					end)
					tpButton:Show()
				end)
			end
		end
	end
end

local function sortTeleports(k1, k2)
	if(k1.type == "icon") then
		return true

	elseif(k2.type == "icon") then
		return false

	else
        return k1.abbreviatedName < k2.abbreviatedName

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
	iconColumn:SetFixedConstraints(32, 3)

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
				column:SetFixedConstraints(32, 3)

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
	view:SetPadding(12, 1, 1, 1, 14)

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