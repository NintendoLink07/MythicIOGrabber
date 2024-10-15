local addonName, miog = ...
local wticc = WrapTextInColorCode

local numberOfSpaces = 40
local occupied = 0
local roles = {
    ["TANK"] = 0,
    ["HEALER"] = 0,
    ["DAMAGER"] = 0,
}
local selectedPreset = nil

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
        element.layoutIndex = element.specID
        element.occupiedSpace = nil

        space.occupiedBy = nil
        space.occupied = false

        occupied = occupied - 1

        roles[element.role] = roles[element.role] - 1
    end
end

local function updateSheet()
    miog.RaidSheet.ScrollFrame.PlayerList:MarkDirty()

    miog.RaidSheet.Occupied:SetText(occupied .. "/" .. numberOfSpaces)
    miog.RaidSheet.Tank:SetText(roles["TANK"])
    miog.RaidSheet.Healer:SetText(roles["HEALER"])
    miog.RaidSheet.Damager:SetText(roles["DAMAGER"])
end

local function bindElementToSpace(element, space)
    element:ClearAllPoints()
    element.layoutIndex = nil

    element:SetPoint("CENTER", space, "CENTER")

    space.occupied = true
    space.occupiedBy = element
    element.occupiedSpace = space

    occupied = occupied + 1
    roles[element.role] = roles[element.role] + 1

end

local function populateFirstAvailableSpace(self)
    for i = 1, numberOfSpaces, 1 do
        local space = miog.RaidSheet.Sheet["Space" .. i]

        if(space and not space.occupied) then
            bindElementToSpace(self, space)

            break
        end
    end

    updateSheet()
end

local function saveInfoToSlot(slotIndex, info)
    if(selectedPreset) then
        for k, v in pairs(MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots) do
            if(v == info) then
                MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots[k] = nil

            end
        end

        if(slotIndex) then
            MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots[slotIndex] = info

        end
    end
end

local function tryToSetFrame(self)
    clearObject(self)

    local saveSlotIndex

    for i = 1, numberOfSpaces, 1 do
        local space = miog.RaidSheet.Sheet["Space" .. i]

        if(space) then
            if(MouseIsOver(space) and not space.occupied) then
                saveSlotIndex = i

                bindElementToSpace(self, space)
            end
        end
    end

    saveInfoToSlot(saveSlotIndex, self.specID)

    updateSheet()
end

local function createElementFrame()
    local elementFrame = CreateFrame("Button", nil, miog.RaidSheet.ScrollFrame.PlayerList, "MIOG_RaidSheetDragDropElementTemplate")

    elementFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()

        tryToSetFrame(self)
    end)
    elementFrame:SetScript("OnDoubleClick", function(self, button)
        if(button == "LeftButton") then
            populateFirstAvailableSpace(self)

        end
    end)

    elementFrame:SetScript("OnClick", function(self, button)
        if(button == "RightButton") then
            clearObject(self)
            saveInfoToSlot(nil, self.specID)
            updateSheet()

        end
    end)

    return elementFrame
end

local function loadPreset()
    for i = 1, numberOfSpaces, 1 do
        clearObject(miog.RaidSheet.Sheet["Space" .. i])

    end

    updateSheet()

    for slotIndex, slotInfo in pairs(MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots) do
        for k, v in ipairs(miog.RaidSheet.ScrollFrame.PlayerList:GetLayoutChildren()) do
            if(slotInfo == v.specID) then
                local space = miog.RaidSheet.Sheet["Space" .. slotIndex]

                bindElementToSpace(v, space)
            end
        end
    end

    updateSheet()
end

miog.loadRaidPlanner = function()
    miog.RaidSheet = miog.pveFrame2.TabFramesPanel.RaidSheet

    local gridColumn, gridRow = 1, 1

    for gridIndex = 1, numberOfSpaces, 1 do
        local spaceFrame = CreateFrame("Frame", nil, miog.RaidSheet.Sheet, "MIOG_RaidSheetDragDropSpaceTemplate")
        spaceFrame:SetParentKey("Space" .. gridIndex)
        spaceFrame.gridColumn = gridColumn
        spaceFrame.gridRow = gridRow

        gridColumn = gridRow == 10 and gridColumn + 1 or gridColumn
        gridRow = gridRow == 10 and 1 or gridRow + 1
    end

    for classIndex, classInfo in ipairs(miog.CLASSES) do
        local color = C_ClassColor.GetClassColor(classInfo.name)
        for specIndex, specID in ipairs(classInfo.specs) do
            local id, name, description, icon, role, isRecommended, isAllowed = GetSpecializationInfoForSpecID(specID)

            local elementFrame = createElementFrame()
            elementFrame.specID = specID
            elementFrame.role = role
            miog.createFrameWithBackgroundAndBorder(elementFrame, 1, color:GetRGBA())
            elementFrame.layoutIndex = specID
            elementFrame.align = "right"

            elementFrame.Name:SetText(name)
        end
    end

    miog.RaidSheet.PresetDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateButton("New", function()
            local newIndex = #MIOG_NewSettings.raidPlanner.sheets + 1
            table.insert(MIOG_NewSettings.raidPlanner.sheets, {
                name = "Test" .. (newIndex),
                slots = {}
            })
            selectedPreset = newIndex
            loadPreset()
        end)

        for k, v in ipairs(MIOG_NewSettings.raidPlanner.sheets) do
	        rootDescription:CreateRadio(v.name, function(index) return index == selectedPreset end, function(index)
                selectedPreset = index
                loadPreset()
            end, k)
        end
    end)

    miog.RaidSheet.Occupied:SetText("0" .. "/" .. numberOfSpaces)
end