local addonName, miog = ...
local wticc = WrapTextInColorCode

local numberOfSpaces = 40
local occupied = 0
local renamingIndex

local roles = {
    ["TANK"] = 0,
    ["HEALER"] = 0,
    ["DAMAGER"] = 0,
}

local PRESENCE_SORT_ORDER = {
	[Enum.ClubMemberPresence.Online] = 1,
	[Enum.ClubMemberPresence.OnlineMobile] = 2,
	[Enum.ClubMemberPresence.Away] = 3,
	[Enum.ClubMemberPresence.Busy] = 4,
	[Enum.ClubMemberPresence.Offline] = 5,
	[Enum.ClubMemberPresence.Unknown] = 6,
};

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
                if(string.find(strlower(widget.Name:GetText()), strlower(text))) then
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

local function orderClubMembers(lhsMemberInfo, rhsMemberInfo)
    if lhsMemberInfo.presence ~= rhsMemberInfo.presence then
        return PRESENCE_SORT_ORDER[lhsMemberInfo.presence] < PRESENCE_SORT_ORDER[rhsMemberInfo.presence];
    --elseif lhsMemberInfo.level and rhsMemberInfo.level and lhsMemberInfo.level ~= rhsMemberInfo.level then
    --    return lhsMemberInfo.level > rhsMemberInfo.level;
    --elseif lhsMemberInfo.guildRankOrder and rhsMemberInfo.guildRankOrder and lhsMemberInfo.guildRankOrder ~= rhsMemberInfo.guildRankOrder then
    --    return lhsMemberInfo.guildRankOrder < rhsMemberInfo.guildRankOrder;
    --elseif lhsMemberInfo.role ~= rhsMemberInfo.role then
    --    return lhsMemberInfo.role < rhsMemberInfo.role;
    elseif lhsMemberInfo.lastOnlineYear ~= rhsMemberInfo.lastOnlineYear then
        return lhsMemberInfo.lastOnlineYear < rhsMemberInfo.lastOnlineYear;

    elseif lhsMemberInfo.lastOnlineMonth ~= rhsMemberInfo.lastOnlineMonth then
        return lhsMemberInfo.lastOnlineMonth < rhsMemberInfo.lastOnlineMonth;

    elseif lhsMemberInfo.lastOnlineDay ~= rhsMemberInfo.lastOnlineDay then
        return lhsMemberInfo.lastOnlineDay < rhsMemberInfo.lastOnlineDay;

    elseif lhsMemberInfo.lastOnlineHour ~= rhsMemberInfo.lastOnlineHour then
        return lhsMemberInfo.lastOnlineHour < rhsMemberInfo.lastOnlineHour;

    elseif lhsMemberInfo.name and rhsMemberInfo.name then
        return lhsMemberInfo.name < rhsMemberInfo.name;
    else
        return lhsMemberInfo.memberId < rhsMemberInfo.memberId;
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
    if(MIOG_NewSettings.raidPlanner.selectedPreset and slotIndex) then
        local frame = miog.RaidSheet.Sheet["Space" .. slotIndex].occupiedBy

        if(frame) then
            MIOG_NewSettings.raidPlanner.sheets[MIOG_NewSettings.raidPlanner.selectedPreset].slots[slotIndex] = {specID = frame.activeSpecID, saveID = frame.saveID}

        else
            MIOG_NewSettings.raidPlanner.sheets[MIOG_NewSettings.raidPlanner.selectedPreset].slots[slotIndex] = nil

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

local function tryToSetFrame(self, populateFirstSlot)
    local hadSlotBefore = self.occupiedSpace
    local newSlotFound = false
    local swapFrames = false

    local slotIndex, finalSpace

    for i = 1, numberOfSpaces, 1 do
        local space = miog.RaidSheet.Sheet["Space" .. i]

        if(space) then
            if(not space.occupied or hadSlotBefore and self.occupiedSpace == space) then
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

local function createElementFrame(classID)
    local elementFrame = playerPool:Acquire()
    elementFrame:OnLoad(classID)

    for i = 1, 4, 1 do
        local specFrame = elementFrame.SpecPicker["Spec" .. i]
        
        if(i <= elementFrame.numOfSpecs) then
            specFrame:SetScript("PostClick", function(selfFrame)
                saveInfoToSlot(elementFrame.occupiedSpace.index)
                updateSheet()

            end)
            specFrame:Show()
        else
            specFrame:Hide()
            specFrame:SetScript("PostClick", nil)

        end
    end

    elementFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        tryToSetFrame(self)

        if(MouseIsOver(self) and self.occupiedSpace) then
            self.SpecPicker:Show()

        end
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

local function loadPreset(selectedPreset)
    clearAllSpaces()

    if(MIOG_NewSettings.raidPlanner.sheets[selectedPreset]) then
        MIOG_NewSettings.raidPlanner.selectedPreset = selectedPreset

        for slotIndex, slotInfo in pairs(MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots) do
            local playerFound = false

            for v in playerPool:EnumerateActive() do
                if(slotInfo.saveID == v.saveID) then
                    local space = miog.RaidSheet.Sheet["Space" .. slotIndex]

                    bindElementToSpace(v, space)
                    v:SetActiveSpecID(slotInfo.specID)

                    playerFound = true

                    break
                end
            end

            if(not playerFound) then --if the player can't be found, e.g. guild member isnt in guild anymore.
                --MIOG_NewSettings.raidPlanner.sheets[selectedPreset].slots[slotIndex] = nil

            end
        end
    end

    updateSheet()
end

local function deletePreset(index)
    local numberOfSheets = #MIOG_NewSettings.raidPlanner.sheets
    local isCurrentlySelected = index == MIOG_NewSettings.raidPlanner.selectedPreset

    MIOG_NewSettings.raidPlanner.sheets[index] = nil

    for i = index, numberOfSheets - 1, 1 do
        MIOG_NewSettings.raidPlanner.sheets[i] = MIOG_NewSettings.raidPlanner.sheets[i + 1]
    end

    MIOG_NewSettings.raidPlanner.selectedPreset = nil
    MIOG_NewSettings.raidPlanner.sheets[numberOfSheets] = nil


    if(isCurrentlySelected) then
        local nextIndex = MIOG_NewSettings.raidPlanner.sheets[index] and index or MIOG_NewSettings.raidPlanner.sheets[index - 1] and (index - 1) or nil

        if(nextIndex) then
            loadPreset(nextIndex)

        else
            clearAllSpaces()

        end
    else
        clearAllSpaces()

    end
end

local function setupFramePools()
    playerPool = playerPool or CreateFramePool("Button", miog.RaidSheet.ScrollFrame.PlayerList, "MIOG_RaidSheetDragDropElementTemplate", function(pool, frame) frame:Hide() frame.layoutIndex = nil frame.memberInfo = nil end)
    playerPool:ReleaseAll()

    local guildMembers = GetNumGuildMembers()

    if(IsInGuild() and guildMembers > 0) then
        local guildClubId = C_Club.GetGuildClubId()
        
        if(guildClubId) then
            local clubMembers = C_Club.GetClubMembers(guildClubId)

            local orderedGuildList = {}
            
            for k, v in ipairs(clubMembers) do
                orderedGuildList[k] = C_Club.GetMemberInfo(guildClubId, v)
            end

            table.sort(orderedGuildList, orderClubMembers)

            for k, v in ipairs(orderedGuildList) do
                local elementFrame = createElementFrame(v.classID)
                elementFrame:SetMemberInfo(v)
                elementFrame.saveID = v.name
                elementFrame.originalIndex = k
                elementFrame.layoutIndex = k

                elementFrame.align = "left"

                elementFrame.Name:SetText(miog.createSplitName(v.name))
            end
        end
    else
        for classIndex, classInfo in ipairs(miog.OFFICIAL_CLASSES) do
            local localizedName = GetClassInfo(classIndex)

            for specIndex, specID in ipairs(classInfo.specs) do
                local elementFrame = createElementFrame(classIndex)
                elementFrame:SetMemberInfo({name = localizedName .. specIndex, presence = 0, level = 80, memberNote = "Y no guild mate", test = true})
                elementFrame.saveID = classIndex .. " - " .. specID
                elementFrame.originalIndex = specID
                elementFrame.layoutIndex = specID

                elementFrame.align = "left"

                elementFrame.Name:SetText(localizedName .. specIndex)
            end
        end
    end

    loadPreset(MIOG_NewSettings.raidPlanner.selectedPreset)
end

local function setupSaveData()
    miog.RaidSheet.PresetDropdown:SetupMenu(function(dropdown, rootDescription)
        local newButton = rootDescription:CreateButton("New", function()
            miog.RaidSheet.TransparentDark:Show()
            miog.RaidSheet.CreateSettingsBox:SetText("RaidSheet" .. #MIOG_NewSettings.raidPlanner.sheets + 1)
            miog.RaidSheet.CreateSettingsBox:HighlightText()
            miog.RaidSheet.CreateSettingsBox:Show()
            miog.RaidSheet.CreateSettingsBox:SetFocus()
        end)

        local hasGuild = C_Club.GetGuildClubId() ~= nil

        for k, v in ipairs(MIOG_NewSettings.raidPlanner.sheets) do
            local sameGuild = v.guildClubID == C_Club.GetGuildClubId()

            if(not v.guildClubID or sameGuild) then
                local presetButton = rootDescription:CreateRadio(WrapTextInColorCode(v.name, hasGuild and sameGuild and miog.CLRSCC.green or hasGuild and not sameGuild and miog.CLRSCC.yellow or miog.CLRSCC.white), function(index) return index == MIOG_NewSettings.raidPlanner.selectedPreset end, function(index)
                    loadPreset(index)
                end, k)

                presetButton:SetTooltip(function(tooltip, elementDescription)
                    if(hasGuild) then
                        if(sameGuild) then
                            GameTooltip:AddLine("This preset is connected to this characters guild and only accessible by this account's characters in this guild.")

                        else
                            GameTooltip:AddLine("This preset is not associated with any guild and is accessible by all account characters.")

                        end
                    end

                    GameTooltip:Show()
                end)
    
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
                        menu:SendResponse(rootDescription, MenuResponse.Close)
    
                        miog.RaidSheet.PresetDropdown:OpenMenu()
                    end)
                    
                    local renameButton = button:AttachTemplate("UIButtonTemplate")
                    renameButton:SetSize(20, 20);
                    renameButton:SetPoint("RIGHT", deleteButton, "LEFT", -3, 0);
                    renameButton:SetNormalAtlas("uitools-icon-refresh")
                    renameButton:SetPushedAtlas("uitools-icon-refresh")
                    renameButton:SetHighlightAtlas("uitools-icon-refresh")
                    renameButton:SetDisabledAtlas("uitools-icon-refresh")
                    renameButton:SetScript("OnMouseDown", function(self, buttonName)
                        renamingIndex = description.data
                        menu:SendResponse(rootDescription, MenuResponse.Close)
    
                        miog.RaidSheet.TransparentDark:Show()
                        miog.RaidSheet.CreateSettingsBox:SetText(MIOG_NewSettings.raidPlanner.sheets[renamingIndex].name)
                        miog.RaidSheet.CreateSettingsBox:HighlightText()
                        miog.RaidSheet.CreateSettingsBox:Show()
                        miog.RaidSheet.CreateSettingsBox:SetFocus()
    
                    end)
                end)
            end
        end
    end)
end

local function raidSheetEvents(_, event, ...)
    if(event == "INITIAL_CLUBS_LOADED") then
        setupSaveData()
    end
end

miog.loadRaidPlanner = function()
    miog.RaidSheet = miog.pveFrame2.TabFramesPanel.RaidSheet
    miog.RaidSheet.Tank.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")
    miog.RaidSheet.Healer.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")
    miog.RaidSheet.Damager.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")
    miog.RaidSheet.Occupied.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/guildmate.png")
    
    miog.RaidSheet.SearchBox:SetScript("OnTextChanged", function(self, key)
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

        gridRow = gridColumn == 4 and gridRow + 1 or gridRow
        gridColumn = gridColumn == 4 and 1 or gridColumn + 1

        miog.createFrameBorder(spaceFrame, 1, CreateColorFromHexString(miog.CLRSCC.gray):GetRGBA())
    end

    miog.RaidSheet.CreateSettingsBox:SetScript("OnEnterPressed", function(self)
        if(not renamingIndex) then
            table.insert(MIOG_NewSettings.raidPlanner.sheets, {
                name = self:GetText(),
                slots = {}
            })
            MIOG_NewSettings.raidPlanner.sheets[#MIOG_NewSettings.raidPlanner.sheets].guildClubID = C_Club.GetGuildClubId()

            loadPreset(#MIOG_NewSettings.raidPlanner.sheets)
        else
            MIOG_NewSettings.raidPlanner.sheets[renamingIndex].name = self:GetText()
            renamingIndex = nil

        end

        miog.RaidSheet.PresetDropdown:SetText(self:GetText())
    end)

    miog.RaidSheet.CreateSettingsBox:SetScript("OnEscapePressed", function(self)
        renamingIndex = nil

    end)

    miog.RaidSheet.PresetDropdown:SetDefaultText("New")

    if(not IsInGuild() or C_Club.GetGuildClubId() ~= nil) then
        setupSaveData()
    end

    miog.RaidSheet.Occupied.Text:SetText("0" .. "/" .. numberOfSpaces)
    miog.RaidSheet:SetScript("OnShow", function()
        setupFramePools()
    end)

    miog.RaidSheet.ResetButton:SetScript("OnClick", function()
        setupFramePools()
    end)

    miog.RaidSheet:RegisterEvent("INITIAL_CLUBS_LOADED")
    miog.RaidSheet:SetScript("OnEvent", raidSheetEvents)
    miog.RaidSheet.ScrollFrame.ScrollBar:Hide()

    ScrollUtil.InitScrollFrameWithScrollBar(miog.RaidSheet.ScrollFrame, miog.pveFrame2.ScrollBarArea.RaidSheetScrollBar)
    
    if(#MIOG_NewSettings.raidPlanner.sheets > 0) then
        setupFramePools()
        loadPreset(MIOG_NewSettings.raidPlanner.selectedPreset or 1)

    end
end