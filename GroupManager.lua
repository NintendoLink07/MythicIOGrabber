local addonName, miog = ...
local wticc = WrapTextInColorCode

local framePool
local spaceFrames = {}

local function clearFrameFromSpace(frame)
    local space = frame.occupiedSpace

    if(space) then
        frame:ClearAllPoints()
        space.occupiedBy = nil
        frame.occupiedSpace = nil
    end
end

local function unoccupySpace(space)
    local frame = space.occupiedBy

    if(frame) then
        frame:ClearAllPoints()
        frame.occupiedSpace = nil
        space.occupiedBy = nil
    end
end

local function swapButtonToSubgroupInRaidFrame(frame, spaceIndex)
    SetRaidSubgroup(frame.id, spaceFrames[spaceIndex].subgroupID);
    --SwapRaidSubgroup(frame.id, frame.occupiedSpace.id);
end

local function swapButtonInRaidFrame(frame)
    if(IsInRaid() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
        SetRaidSubgroup(frame.id, frame.occupiedSpace.subgroupID);
    end
    --SwapRaidSubgroup(frame.id, frame.occupiedSpace.id);
end

local function bindFrameToSpace(frame, space)
    if(not space.occupiedBy or space.occupiedBy == frame) then
        clearFrameFromSpace(frame)

        frame:SetAllPoints(space)
        frame:SetParent(space)

        space.occupiedBy = frame
        frame.occupiedSpace = space
    end
end

local function bindFrameToSubgroupSpot(frame, subgroup, spot)
    local space = miog.GroupManager.Groups["Group" .. subgroup]["Space" .. spot]

    if(space) then
        bindFrameToSpace(frame, space)
    end
end

local function bindFrameToFirstSpaceInGroup(frame, groupID)
    local nextIndex = _G["RaidGroup" .. groupID].nextIndex
    
    local nextSpace = miog.GroupManager.Groups["Group" .. groupID]["Space" .. nextIndex]

    if(nextSpace) then
        bindFrameToSpace(frame, nextSpace)
        
    end
end

local function bindFrameToSpaceGroup(frame, space)
    local groupID = space.subgroupID

    if(_G["RaidGroup" .. groupID]) then
        local nextIndex = groupID and _G["RaidGroup" .. groupID].nextIndex

        if(nextIndex and frame.occupiedSpace.subgroupID ~= groupID) then
            local nextSpace = miog.GroupManager.Groups["Group" .. groupID]["Space" .. nextIndex]

            if(nextSpace) then
                bindFrameToSpace(frame, nextSpace)
            end
        else
            bindFrameToSpace(frame, frame.occupiedSpace)
        end
    end
end

local function bindFrameToSpaceGroupIndex(frame, index)
    bindFrameToSpaceGroup(frame, spaceFrames[index])
end

local function bindFrameToSpaceIndex(frame, index)
    bindFrameToSpace(frame, spaceFrames[index])
end

local function bindFrameToFirstAvailableSpace(frame)
    for k, v in ipairs(spaceFrames) do
        if(not v.occupiedBy) then
            bindFrameToSpaceGroup(frame, v)
            break
            
        end
    end
end

local function fillSpaceFramesTable()
    for i = 1, 40, 1 do
        local group = ceil(i / 5)
        local spaceNumber = i - (group - 1) * 5
        local groupFrame = miog.GroupManager.Groups["Group" .. group]
        local space = groupFrame and miog.GroupManager.Groups["Group" .. group]["Space" .. spaceNumber]

        if(space) then
            space.subgroupID = group
            space.id = i
            space.Number:SetText("#" .. i)
            
            miog.createFrameBorder(space, 1, CreateColorFromHexString(miog.CLRSCC.gray):GetRGBA())
            space:SetBackdropColor(CreateColorFromHexString(miog.CLRSCC.black):GetRGBA())
            tinsert(spaceFrames, space)

        end
    end
end

local function isFrameOverAnySpace(frame)
    for k, v in ipairs(spaceFrames) do
        if(MouseIsOver(v)) then
            return true, k
        end
    end

    return false
end

local function resetIndepthData()
    local indepthFrame = miog.GroupManager.Indepth

    indepthFrame.Name:SetText("")
    indepthFrame.Name:SetTextColor(1, 1, 1, 1)
    indepthFrame.Level:SetText("");

    indepthFrame:Flush()
    indepthFrame:ApplyFillData()

    --[[
    local itemFrame = miog.GroupManager.Indepth.Items

    for k, v in ipairs(miog.SLOT_ID_INFO) do
        local item = itemFrame[v.slotName]

        if(item) then
            item.Icon:SetTexture(nil)
            item.Border:Hide()

        end
    end]]
end

local function setIndepthData(data)
    local indepthFrame = miog.GroupManager.Indepth

    indepthFrame.Name:SetText(data.shortName)
    indepthFrame.Name:SetTextColor(data.classColor:GetRGBA())
    indepthFrame.Level:SetFormattedText(LEVEL_GAINED, data.level);
    indepthFrame.Spec:SetTexture(miog.SPECIALIZATIONS[data.specID].squaredIcon)

    indepthFrame:OnLoad("side")
    indepthFrame:SetPlayerData(data.shortName, data.realm)
    indepthFrame:RequestFillData()
    indepthFrame:ApplyFillData()
end

local function createCharacterFrame(data)
    local frame = framePool:Acquire()
    frame.id = data.id
    frame.subgroupSpotID = data.subgroupSpotID
    frame.data = data

    frame.Name:SetText(data.shortName)
    
    frame:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=1, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})

    local color = C_ClassColor.GetClassColor(data.className)

    frame:SetBackdropColor(color:GetRGBA())
    frame:SetBackdropBorderColor(color.r - 0.15, color.g - 0.15, color.b - 0.15, 1)
    frame.Name:SetTextColor(1, 1, 1, 1)
    frame.Spec:SetTexture(data.specID and miog.SPECIALIZATIONS[data.specID].squaredIcon)

    data.classColor = color
    
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetUnit(self.data.unitID)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", GameTooltip_Hide)

    if(IsInRaid()) then
        frame:RegisterForDrag()
        frame:SetScript("OnDragStart", function(self)
            self:StartMoving()
    
        end)
    
        frame:SetScript("OnDragStop", function(self)
            local isOverFrame, index = isFrameOverAnySpace(self)
    
            if(isOverFrame) then
                self:StopMovingOrSizing()
                bindFrameToSpaceGroupIndex(frame, index)
                swapButtonInRaidFrame(frame)
                --swapButtonToSubgroupInRaidFrame(self, index)
    
            else
                self:StopMovingOrSizing()
                bindFrameToSpace(frame, frame.occupiedSpace)
    
            end
        end)
    end
    
    frame:SetPlayerData(data.shortName, data.realm)
    frame:RequestFillData()
    frame:SetScript("OnClick", function(self)
        setIndepthData(self.data, self.mplusData)

        --local playerGear = miog.openRaidLib.GetUnitGear(self.data.unitID)
        --[[if(playerGear) then
            local itemFrame = miog.GroupManager.Indepth.Items

            for k, v in ipairs(playerGear.equippedGear) do
                local item = itemFrame[miog.SLOT_ID_INFO[v.slotId].slotName]

                if(item) then
                    item.itemLink = v.itemLink
                    local itemData = Item:CreateFromItemID(v.itemId)

                    itemData:ContinueOnItemLoad(function()
                        item.Icon:SetTexture(itemData:GetItemIcon())

                    end)
                end
            end

            for k, v in ipairs(playerGear.noEnchants) do
                local item = itemFrame[miog.SLOT_ID_INFO[v].slotName]

                if(item) then
                    item.missingEnchant = true
                    item.Border:Show()

                end
            end

            for k, v in ipairs(playerGear.noGems) do
                local item = itemFrame[miog.SLOT_ID_INFO[v].slotName]

                if(item) then
                    item.missingEnchant = true
                    item.Border:Show()

                end
            end
        end]]

        miog.GroupManager.Indepth:Show()
        miog.GroupManager.Overlay:Hide()
    end)

    frame:Show()

    return frame
end

local function updateGroupData()
    framePool:ReleaseAll()

    local numGroupMembers = GetNumGroupMembers()

    local subgroupSpotsTaken = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
    }

    local groupOffset = 0

    if(numGroupMembers > 0) then
        for raidIndex = 1, numGroupMembers, 1 do
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(raidIndex) --ONLY WORKS WHEN IN GROUP

            if(name) then
				local playerName, realm = miog.createSplitName(name)
				local fullName = playerName .. "-" .. (realm or "")

                subgroupSpotsTaken[subgroup] = subgroupSpotsTaken[subgroup] + 1

                local unitID
        
                if(IsInRaid()) then
                    unitID = "raid" .. raidIndex
        
                elseif(IsInGroup() and name ~= playerName) then
                    unitID = "party" .. raidIndex + groupOffset
        
                elseif(name == playerName) then
                    unitID = "player"
                    groupOffset = -1

                end

                local data = {
                    unitID = unitID,
                    id = raidIndex,
                    fullName = fullName,
                    shortName = playerName,
                    localizedClassName = class,
                    className = fileName,
                    realm = realm,
                    level = level,
                    zone = zone,
                    online = online,
                    isDead = isDead,
                    specID = miog.getPlayerSpec(fullName),
                }

                local playerFrame = createCharacterFrame(data)

                bindFrameToSubgroupSpot(playerFrame, subgroup, subgroupSpotsTaken[subgroup])
                --bindFrameToSpaceIndex(playerFrame, raidIndex)
            end
        end
    else
        local class, fileName, id = UnitClass("player")
        local bestMap = C_Map.GetBestMapForUnit("player")
        local specID = GetSpecializationInfo(GetSpecialization())

        local data = {
            unitID = "player",
            fullName = miog.createFullNameFrom("unitID", "player"),
            shortName = UnitNameUnmodified("player"),
            className = fileName,
            localizedClassName = class,
            realm = GetNormalizedRealmName(),
            level = UnitLevel("player"),
            zone = bestMap,
            online = true,
            isDead = UnitIsDead("player"),
            specID = specID, 
        }

        local playerFrame = createCharacterFrame(data)

        bindFrameToSubgroupSpot(playerFrame, 1, 1)
    end
end

local function managerEvents(_, event, ...)
	if(event == "GROUP_ROSTER_UPDATE") then
        updateGroupData()
    end
end

miog.loadGroupManager = function()
    miog.GroupManager = miog.pveFrame2.TabFramesPanel.GroupManager

    framePool = CreateFramePool("Button", nil, "MIOG_GroupManagerCharacterTemplate", function(_, frame) frame:Hide() clearFrameFromSpace(frame) end)

    miog.GroupManager:SetScript("OnEvent", managerEvents)
    miog.GroupManager:RegisterEvent("GROUP_ROSTER_UPDATE")

    miog.GroupManager:SetScript("OnShow", function()
        updateGroupData()
    end)

    fillSpaceFramesTable()
    
    miog.GroupManager.Indepth:OnLoad()

    miog.GroupManager.Indepth.CloseButton:SetScript("OnClick", function(self)
        self:GetParent():Hide()
        self:GetParent():GetParent().Overlay:Show()
        
        resetIndepthData()
    end)

    resetIndepthData()
end