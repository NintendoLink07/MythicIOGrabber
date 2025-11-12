local addonName, miog = ...

local interactionState = true

RaidViewMixin = {}

local groupsTaken = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
}

function RaidViewMixin:GetNumOfSpotsTaken(groupIndex)
    return #self["Group" .. groupIndex]:GetLayoutChildren()
end

function RaidViewMixin:GetChildrenOfGroup(groupIndex)
    return self["Group" .. groupIndex]:GetLayoutChildren()
end

function RaidViewMixin:IsFrameOverGroup()
    for i = 1, 8 do
        local group = self["Group" .. i]

        if(group and MouseIsOver(group)) then
            return group

        end
    end
end

function RaidViewMixin:IsFrameOverAnyOtherFrame(frame)
    for i = 1, 8 do
        local children = self:GetChildrenOfGroup(i)

        for memberIndex = 1, 5 do
            local memberFrame = children[memberIndex]

            if(memberFrame and MouseIsOver(memberFrame) and memberFrame ~= frame) then
                return memberFrame

            end
        end
    end
end

local function canMoveFrames()
    if(IsInRaid() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
        return true

    end
end

function RaidViewMixin:SwapFrames(frame1, frame2)
    self:SetInteractionState(false)

    local f1Parent, f1Index, f1RaidIndex = frame1:GetParent(), frame1.layoutIndex, frame1.raidIndex
    local f2Parent, f2Index, f2RaidIndex = frame2:GetParent(), frame2.layoutIndex, frame2.raidIndex

    frame1:SetParent(f2Parent)
    frame1:SetLayoutIndex(f2Index)
    frame1.raidIndex = f2RaidIndex

    frame2:SetParent(f1Parent)
    frame2:SetLayoutIndex(f1Index)
    frame2.raidIndex = f1RaidIndex

    SwapRaidSubgroup(f1RaidIndex, f2RaidIndex)

    local p1, p2 = frame1:GetParent(), frame2:GetParent()
    
    p1:MarkDirty()

    if(p1 ~= p2) then
        p2:MarkDirty()

    end
end

function RaidViewMixin:BindFrameToSubgroup(frame, subgroup)
    local numOfTakenSpots = self:GetNumOfSpotsTaken(subgroup)

    if(numOfTakenSpots < 5) then
        self:SetInteractionState(false)

        local newGroup = self["Group" .. subgroup]
        local newIndex = self:GetNumOfSpotsTaken(subgroup) + 1

        frame:SetParent(newGroup)
        frame:SetLayoutIndex(newIndex)

        newGroup:MarkDirty()
        
        SetRaidSubgroup(frame.raidIndex, subgroup)

    end
end

function RaidViewMixin:MoveFrame(frame)
    if(canMoveFrames() and frame.raidIndex) then
        local mouseoverFrame = self:IsFrameOverAnyOtherFrame(frame)

        if(not mouseoverFrame) then
            
            
        end

        if(mouseoverFrame) then
            if(mouseoverFrame.data.subgroup ~= frame.data.subgroup) then
                self:SwapFrames(frame, mouseoverFrame)
                return

            end
        else
            local groupFrame = self:IsFrameOverGroup(frame)

            if(groupFrame and frame:GetParent() ~= groupFrame) then
                self:BindFrameToSubgroup(frame, groupFrame.index)
                return

            end
        end

        if(frame.raidIndex) then
            frame:GetParent():MarkDirty()

        end
    end
end

function RaidViewMixin:PrepareForNewData()
    for i = 1, 40 do
        local memberFrame = self["Member" .. i]

        if(memberFrame) then
            memberFrame:Hide()
            memberFrame:ClearData()
            memberFrame.layoutIndex = nil
            memberFrame:SetParent(nil)

        end
    end

    groupsTaken = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
    }
end

function RaidViewMixin:GetInteractionState()
    return interactionState
end

function RaidViewMixin:SetInteractionState(state)
    interactionState = state
    self.Blocker:SetShown(not state)
end

function RaidViewMixin:Unlock()
    self:SetInteractionState(true)
end

function RaidViewMixin:RefreshMemberData(fullData)
    self:PrepareForNewData()

    for k, v in ipairs(fullData) do
        if(v.subgroup) then
            groupsTaken[v.subgroup] = groupsTaken[v.subgroup] + 1
            local group = self["Group" .. v.subgroup]

            local memberFrame = self["Member" .. k]

            memberFrame:SetData(v)
            memberFrame:Show()
            memberFrame:SetScript("OnMouseUp", function(selfFrame)
                if(canMoveFrames()) then
                    self:MoveFrame(selfFrame)
                    selfFrame:StopMoving()

                end
            end)

            memberFrame:SetLayoutIndex(groupsTaken[v.subgroup])
            memberFrame:SetParent(group)
            memberFrame:GetParent():MarkDirty()
        end
    end
end

function RaidViewMixin:OnLoad()
    for i = 1, 8 do
        local group = self["Group" .. i]
        group.index = i
        group.Title:SetText("Group " .. i)

    end

	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:SetScript("OnEvent", function(_, event, ...)
        if(event == "GROUP_ROSTER_UPDATE") then
            self:SetInteractionState(true)

        end
    end)
end

function RaidViewMixin:FindMemberFrame(fullName)
    for i = 1, 8 do
        local children = self:GetChildrenOfGroup(i)

        for memberIndex = 1, 5 do
            local memberFrame = children[memberIndex]

            if(memberFrame and memberFrame.data.fullName == fullName) then
                return memberFrame

            end
        end
    end
end

function RaidViewMixin:OnShow()
    if(not self.hasTheme) then
        local theme = miog.C.CURRENT_THEME

        for i = 1, 8 do
            local group = self["Group" .. i]

            group.HeaderColor:SetColorTexture(theme[4].r, theme[4].g, theme[4].b, 0.25)
            group.Space1Color:SetColorTexture(theme[2].r, theme[2].g, theme[2].b, 0.1)
            group.Space2Color:SetColorTexture(theme[3].r, theme[3].g, theme[3].b, 0.1)
            group.Space3Color:SetColorTexture(theme[2].r, theme[2].g, theme[2].b, 0.1)
            group.Space4Color:SetColorTexture(theme[3].r, theme[3].g, theme[3].b, 0.1)
            group.Space5Color:SetColorTexture(theme[2].r, theme[2].g, theme[2].b, 0.1)
            group:MarkDirty()

        end

        self.hasTheme = true
    end
end







RaidViewButtonMixin = {}

function RaidViewButtonMixin:SetSpecialization(specID)
    self.Spec:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)

end

function RaidViewButtonMixin:SetData(data)
    self:SetSpecialization(data.specID)

    self.Text:SetText(data.name)

    if(data.online) then
        self.Text:SetTextColor(1, 1, 1, 1)

    else
        self.Text:SetTextColor(1, 0, 0, 1)

    end

    if(data.rank == 2) then
        self.Role:SetTexture("interface/groupframe/ui-group-leadericon.blp")

    elseif(data.rank == 1) then
        self.Role:SetTexture("interface/groupframe/ui-group-assistanticon.blp")

    end

    if(data.role == "MAINTANK") then
        self.Rank:SetTexture("interface/groupframe/ui-group-maintankicon.blp")

    elseif(data.role == "MAINASSIST") then
        self.Rank:SetTexture("interface/groupframe/ui-group-mainassisticon.blp")
        
    end

    self.data = data

    self.raidIndex = data.index
end

function RaidViewButtonMixin:ClearData()
    self.Text:SetText("")
    self.Text:SetTextColor(1, 1, 1, 1)
    self.Spec:SetTexture(nil)
    self.Rank:SetTexture(nil)
    self.Role:SetTexture(nil)

    self.data = nil
    self.raidIndex = nil
end

function RaidViewButtonMixin:AttemptToMove()
	if(canMoveFrames() and self.raidIndex and RaidViewMixin:GetInteractionState() == true) then
        self:StartMoving()

    end
end

function RaidViewButtonMixin:StopMoving()
    self:StopMovingOrSizing()

end

function RaidViewButtonMixin:SetOnlineStatus(isOnline, isAfk, isDnd)
    local classColor  = C_ClassColor.GetClassColor(self.data.fileName)
    local r, g, b = classColor:GetRGBA()

    if(isOnline) then
        self.BackgroundColor:SetColorTexture(r, g, b, 0.8)
        self:SetBackdropBorderColor(r-0.5, g-0.5, b-0.5, 0.8)

        if(isAfk) then
            self.Status:SetTexture("interface/friendsframe/statusicon-away.blp")

        elseif(isDnd) then
            self.Status:SetTexture("interface/friendsframe/statusicon-dnd.blp")

        else
            self.Status:SetTexture("interface/friendsframe/statusicon-online.blp")

        end
    else
        self.BackgroundColor:SetColorTexture(r, g, b, 0.3)
        self:SetBackdropBorderColor(0.8, 0.05, 0.05, 1)
        self.Status:SetTexture("interface/friendsframe/statusicon-offline.blp")

    end
end

function RaidViewButtonMixin:UpdateOnlineStatus()
    local isOnline = self.data.online
    local isAfk = UnitIsAFK(self.data.unitID)
    local isDnd = UnitIsDND(self.data.unitID)

    self:SetOnlineStatus(isOnline, isAfk, isDnd)
end

function RaidViewButtonMixin:SetLayoutIndex(layoutIndex)
    self.layoutIndex = layoutIndex
    self:UpdateOnlineStatus()
end

function RaidViewButtonMixin:SetCallback(func)
    self.callback = func
end