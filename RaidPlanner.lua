local addonName, miog = ...
local wticc = WrapTextInColorCode

local occupiedSpaces = {}

local numberOfSpaces = 40
local occupied = 0
local roles = {
    ["TANK"] = 0,
    ["HEALER"] = 0,
    ["DAMAGER"] = 0,
}

local selectedPreset = nil
local playerPool

local function clearObject(object)
    local space, element

    if(object.type == "space" and object.occupiedBy) then
        space = object
        element = object.occupiedBy
        
    elseif(object.type == "element" and object.occupiedSpace) then
        space = object.occupiedSpace
        element = object

    end

    if(space and element) then
        element:Reset()
        space:Reset()
    end
end

local function countRoles()
    roles = {
        ["TANK"] = 0,
        ["HEALER"] = 0,
        ["DAMAGER"] = 0,
    }

    occupied = 0

    for i = 1, numberOfSpaces, 1 do
        local space = miog.RaidSheet.Sheet["Space" .. i]

        if(space) then
            local element = space.occupiedBy

            if(element) then
                occupied = occupied + 1

                if(element.activeRole) then
                    roles[element.activeRole] = roles[element.activeRole] + 1

                end
            end
        end
    end

    miog.RaidSheet.Occupied.Text:SetText(occupied .. "/" .. numberOfSpaces)
    miog.RaidSheet.Tank.Text:SetText(roles["TANK"])
    miog.RaidSheet.Healer.Text:SetText(roles["HEALER"])
    miog.RaidSheet.Damager.Text:SetText(roles["DAMAGER"])
end

local function filterPlayerList()
    local text = miog.RaidSheet.SearchBox:GetText()

    if(text ~= "") then
        for widget in playerPool:EnumerateActive() do
            if(not widget.occupiedSpace) then
                if(string.find(widget.Name:GetText(), text)) then
                    widget.layoutIndex = widget.originalIndex
                    widget:Show()

                else
                    widget.layoutIndex = nil
                    widget:Hide()

                end
            else
                widget:Show()
                
            end
        end
    else
        for widget in playerPool:EnumerateActive() do
            if(not widget.occupiedSpace) then
                widget.layoutIndex = widget.originalIndex
                widget:Show()
            end
        end
    end
    
end

local function updateSheet()
    countRoles()
    filterPlayerList()
    miog.RaidSheet.ScrollFrame.PlayerList:MarkDirty()
end

local function clearAllSpaces()
    for i = 1, numberOfSpaces, 1 do
        clearObject(miog.RaidSheet.Sheet["Space" .. i])

    end

    updateSheet()
end

local function bindElementToSpace(element, space)
    element:FreeSpace()
    element:OccupySpace(space)
    space:SetOccupiedBy(element)
end

local function saveInfoToSlot(slotIndex)
    if(selectedPreset and slotIndex) then
        local frame = miog.RaidSheet.Sheet["Space" .. slotIndex].occupiedBy

        if(frame) then
            MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots[slotIndex] = {specID = frame.activeSpecID, saveID = frame.saveID}

        else
            MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots[slotIndex] = nil

        end
    end
end

local function swapElements(element1, element2)
    local space1, space2 = element1.occupiedSpace, element2.occupiedSpace
    local space1Index, space2Index = space1.index, space2.index

    bindElementToSpace(element1, space2)
    saveInfoToSlot(space2Index)

    bindElementToSpace(element2, space1)
    saveInfoToSlot(space1Index)
end

local function debug_CheckOccupiedSpaces()
    for i = 1, numberOfSpaces, 1 do
        local space = miog.RaidSheet.Sheet["Space" .. i]
        
        if(space.occupied) then
            print(i, "is occupied")

        end

    end
end

local function tryToSetFrame(self, populateFirstSlot)
    local hadSlotBefore = self.occupiedSpace
    local newSlotFound = false
    local swapFrames = false

    local slotIndex, finalSpace

    for i = 1, numberOfSpaces, 1 do
        local space = miog.RaidSheet.Sheet["Space" .. i]

        if(space) then
            if(not space.occupied) then
                if(populateFirstSlot or not populateFirstSlot and MouseIsOver(space)) then
                    newSlotFound = true

                    finalSpace = space
                    slotIndex = i

                    break
                end
            elseif(MouseIsOver(space) and self.occupiedSpace and space.occupiedBy and self.saveID ~= space.occupiedBy.saveID) then
                swapElements(self, space.occupiedBy)
                swapFrames = true

                break

            end
        end
    end

    if(not swapFrames) then
        if(newSlotFound) then
            if(hadSlotBefore) then --MOVING FROM SPACE TO SPACE
                self.occupiedSpace:Reset()

            else --MOVING FROM LIST TO SPACE
                clearObject(self)

            end

            bindElementToSpace(self, finalSpace)
            saveInfoToSlot(slotIndex)
        else
            if(hadSlotBefore) then --MOVING FROM SLOT TO LIST
                clearObject(self)
                
            else --MOVING FROM LIST TO LIST
                clearObject(self)

            end

        end
    else

    end

    updateSheet()
end

local function createElementFrame(className)
    --local elementFrame = CreateFrame("Button", nil, miog.RaidSheet.ScrollFrame.PlayerList, "MIOG_RaidSheetDragDropElementTemplate")
    local elementFrame = playerPool:Acquire()
    elementFrame:OnLoad(className)

    for i = 1, GetNumSpecializationsForClassID(elementFrame.classID), 1 do
        local specFrame = elementFrame.SpecPicker["Spec" .. i]
        
        specFrame:SetScript("PostClick", function(selfFrame)
            saveInfoToSlot(elementFrame.occupiedSpace.index)
            updateSheet()

        end)
    end

    elementFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        tryToSetFrame(self)

    end)
    elementFrame:SetScript("OnDoubleClick", function(self, button)
        if(button == "LeftButton") then
            tryToSetFrame(self, true)

        end
    end)

    elementFrame:SetScript("OnClick", function(self, button)
        if(button == "RightButton" and self.occupiedSpace) then
            local toBeDeletedIndex = self.occupiedSpace.index
            clearObject(self)
            saveInfoToSlot(toBeDeletedIndex)
            updateSheet()

        end
    end)

    return elementFrame
end

local function loadPreset()
    clearAllSpaces()

    for slotIndex, slotInfo in pairs(MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots) do
        for v in playerPool:EnumerateActive() do
            if(slotInfo.saveID == v.saveID) then
                local space = miog.RaidSheet.Sheet["Space" .. slotIndex]

                bindElementToSpace(v, space)
                v:SetActiveSpecID(slotInfo.specID)
            end
        end
    end

    updateSheet()
end

local function deletePreset(index)
    local numberOfSheets = #MIOG_NewSettings.raidPlanner.sheets
    local isCurrentlySelected = index == selectedPreset

    MIOG_NewSettings.raidPlanner.sheets[index] = nil

    for i = index, numberOfSheets - 1, 1 do
        MIOG_NewSettings.raidPlanner.sheets[i] = MIOG_NewSettings.raidPlanner.sheets[i + 1]
    end

    MIOG_NewSettings.raidPlanner.sheets[numberOfSheets] = nil


    if(isCurrentlySelected) then
        local nextIndex = MIOG_NewSettings.raidPlanner.sheets[index] and index or MIOG_NewSettings.raidPlanner.sheets[index - 1] and (index - 1) or nil

        selectedPreset = nextIndex

        if(selectedPreset) then
            loadPreset()

        else
            clearAllSpaces()

        end
    else
        clearAllSpaces()

    end
end

miog.loadRaidPlanner = function()
    miog.RaidSheet = miog.pveFrame2.TabFramesPanel.RaidSheet
    miog.RaidSheet.Tank.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")
    miog.RaidSheet.Healer.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")
    miog.RaidSheet.Damager.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")
    miog.RaidSheet.Occupied.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/guildmate.png")

    --local elementFrame = CreateFrame("Button", nil, miog.RaidSheet.ScrollFrame.PlayerList, "MIOG_RaidSheetDragDropElementTemplate")
    playerPool = CreateFramePool("Button", miog.RaidSheet.ScrollFrame.PlayerList, "MIOG_RaidSheetDragDropElementTemplate", function(pool, frame) end)
    
    miog.RaidSheet.SearchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)

        if(key == "ESCAPE" or key == "ENTER") then
            self:Hide()
            self:ClearFocus()
    
        else
            updateSheet()

        end
    end)

    local gridColumn, gridRow = 1, 1

    for gridIndex = 1, numberOfSpaces, 1 do
        local spaceFrame = CreateFrame("Frame", nil, miog.RaidSheet.Sheet, "MIOG_RaidSheetDragDropSpaceTemplate")
        spaceFrame:OnLoad(gridIndex)
        spaceFrame.gridColumn = gridColumn
        spaceFrame.gridRow = gridRow

        --gridColumn = gridRow == 10 and gridColumn + 1 or gridColumn
        --gridRow = gridRow == 10 and 1 or gridRow + 1

        gridRow = gridColumn == 4 and gridRow + 1 or gridRow
        gridColumn = gridColumn == 4 and 1 or gridColumn + 1

        miog.createFrameBorder(spaceFrame, 1, CreateColorFromHexString(miog.CLRSCC.gray):GetRGBA())
    end

    local guildMembers = GetNumGuildMembers()

    if(guildMembers > 0) then
        for i = 1, guildMembers, 1 do
            local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)

            local elementFrame = createElementFrame(class)
            elementFrame.saveID = name
            elementFrame.originalIndex = i
            elementFrame.layoutIndex = i

            elementFrame.align = "left"

            elementFrame.Name:SetText(name)
        end
    else
        for classIndex, classInfo in ipairs(miog.CLASSES) do
            for specIndex, specID in ipairs(classInfo.specs) do
                local elementFrame = createElementFrame(classInfo.name)
                elementFrame.saveID = classIndex .. " - " .. specID
                elementFrame.originalIndex = specID
                elementFrame.layoutIndex = specID

                elementFrame.Name:SetText(classInfo.name .. specIndex)
            end
        end
    end

    miog.RaidSheet.CreateSettingsBox:SetScript("OnEnterPressed", function(self)
        table.insert(MIOG_NewSettings.raidPlanner.sheets, {
            name = self:GetText(),
            slots = {}
        })

        selectedPreset = #MIOG_NewSettings.raidPlanner.sheets
        loadPreset()

        miog.RaidSheet.PresetDropdown:SetText(self:GetText())
    end)

    miog.RaidSheet.PresetDropdown:SetDefaultText("New")
    miog.RaidSheet.PresetDropdown:SetupMenu(function(dropdown, rootDescription)
        local newButton = rootDescription:CreateButton("New", function()
            miog.RaidSheet.TransparentDark:Show()
            miog.RaidSheet.CreateSettingsBox:SetText("RaidSheet" .. #MIOG_NewSettings.raidPlanner.sheets + 1)
            miog.RaidSheet.CreateSettingsBox:HighlightText()
            miog.RaidSheet.CreateSettingsBox:Show()
            miog.RaidSheet.CreateSettingsBox:SetFocus()
        end)

        for k, v in ipairs(MIOG_NewSettings.raidPlanner.sheets) do
	        local presetButton = rootDescription:CreateRadio(v.name, function(index) return index == selectedPreset end, function(index)
                selectedPreset = index
                loadPreset()
            end, k)

            presetButton:AddInitializer(function(button, description, menu)
                local deleteButton = button:AttachTemplate("UIButtonTemplate")
                deleteButton:SetSize(20, 20);
                deleteButton:SetPoint("RIGHT", 0, 0);
                deleteButton:SetNormalAtlas("128-redbutton-delete")
                deleteButton:SetPushedAtlas("128-redbutton-delete")
                deleteButton:SetHighlightAtlas("128-redbutton-delete")
                deleteButton:SetDisabledAtlas("128-redbutton-delete")
                deleteButton:SetScript("OnMouseDown", function(self, buttonName)
                    deletePreset(k)
                    --menu:SendResponse(rootDescription, MenuResponse.Refresh)
                    menu:SendResponse(rootDescription, MenuResponse.Close)

                    miog.RaidSheet.PresetDropdown:OpenMenu()
                    
                    if(#MIOG_NewSettings.raidPlanner.sheets > 0) then
		                --description:Pick(MenuInputContext.MouseButton, buttonName);

                    end
                end)

                return button.fontstring:GetUnboundedStringWidth() + 2 - 16
            end)
        end

    end)

    miog.RaidSheet.Occupied.Text:SetText("0" .. "/" .. numberOfSpaces)
end