local addonName, miog = ...

RaidViewMixin = {}

local usedFramesCounter = 0

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
    local f1Parent, f1Index = frame1:GetParent(), frame1.layoutIndex
    local f2Parent, f2Index = frame2:GetParent(), frame2.layoutIndex

    frame1:SetParent(f2Parent)
    frame1:SetLayoutIndex(f2Index)

    frame2:SetParent(f1Parent)
    frame2:SetLayoutIndex(f1Index)

    SwapRaidSubgroup(frame1.raidIndex, frame2.raidIndex)

    local p1, p2 = frame1:GetParent(), frame2:GetParent()
    
    p1:MarkDirty()

    if(p1 ~= p2) then
        p2:MarkDirty()

    end
end

function RaidViewMixin:BindFrameToSubgroup(frame, subgroup)
    local numOfTakenSpots = self:GetNumOfSpotsTaken(subgroup)

    if(numOfTakenSpots < 5) then
        self:SetUnderlyingColor(frame, true)

        local newGroup = self["Group" .. subgroup]
        local newIndex = self:GetNumOfSpotsTaken(subgroup) + 1

        frame:SetParent(newGroup)
        frame:SetLayoutIndex(newIndex)

        self:SetUnderlyingColor(frame, false)

        newGroup:MarkDirty()
        
        SetRaidSubgroup(frame.raidIndex, subgroup)

    end
end

function RaidViewMixin:MoveFrame(frame)
    if(canMoveFrames() and frame.raidIndex) then
        local mouseoverFrame = self:IsFrameOverAnyOtherFrame(frame)

        if(mouseoverFrame) then
            self:SwapFrames(frame, mouseoverFrame)

        else
            local groupFrame = self:IsFrameOverGroup(frame)

            if(groupFrame and frame:GetParent() ~= groupFrame) then
                self:BindFrameToSubgroup(frame, groupFrame.index)
                
            elseif(frame.raidIndex) then
                frame:GetParent():MarkDirty()

            end
        end
    end
end

function RaidViewMixin:PrepareForNewData()
    for i = 1, 40 do
        local memberFrame = self["Member" .. i]

        if(memberFrame) then
            memberFrame:ClearData()
            memberFrame.layoutIndex = nil

            memberFrame:SetCallback(nil)
            memberFrame:Hide()

        end
    end

    usedFramesCounter = 0

    for i = 1, 8 do
        local group = self["Group" .. i]

        group.Space1Color:Show()
        group.Space2Color:Show()
        group.Space3Color:Show()
        group.Space4Color:Show()
        group.Space5Color:Show()

        group:MarkDirty()

    end
end

function RaidViewMixin:OnLoad()
    for i = 1, 8 do
        local group = self["Group" .. i]
        group.index = i
        group.Title:SetText("Group " .. i)

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

        end

        self.hasTheme = true
    end
end

function RaidViewMixin:SetUnderlyingColor(frame, state)
    local index = frame.layoutIndex
    local space = frame:GetParent()["Space" .. index .. "Color"]

    space:SetShown(state)
end

function RaidViewMixin:SetMemberValues(data)
    local index = usedFramesCounter + 1

    local memberFrame = self["Member" .. index]

    if(memberFrame) then
        local group = self["Group" .. data.subgroup]
        usedFramesCounter = usedFramesCounter + 1

        memberFrame:SetData(data)
        memberFrame:SetCallback(function(paraFrame) self:MoveFrame(paraFrame) end)

        memberFrame:SetLayoutIndex(self:GetNumOfSpotsTaken(data.subgroup) + 1)
        memberFrame:SetParent(group)
        self:SetUnderlyingColor(memberFrame, false)
        memberFrame:Show()

        memberFrame:GetParent():MarkDirty()
        
    end
end



RaidViewButtonMixin = {}

function RaidViewButtonMixin:SetData(data)
    local classColor  = C_ClassColor.GetClassColor(data.fileName)

    self.Spec:SetTexture(miog.SPECIALIZATIONS[data.specID].squaredIcon)

    self.Text:SetText(data.name)

    if(data.online) then
        self.Text:SetTextColor(classColor:GetRGBA())

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
	if(canMoveFrames() and self.raidIndex) then
        self:StartMoving()

    end
end

function RaidViewButtonMixin:StopMoving()
    self.callback(self)

    self:StopMovingOrSizing()

end

function RaidViewButtonMixin:RefreshColor()
    local isOdd = self.layoutIndex % 2 == 1

    local theme = miog.C.CURRENT_THEME

    if(isOdd) then
        self.BackgroundColor:SetColorTexture(theme[2].r, theme[2].g, theme[2].b, 0.2)

    else
        self.BackgroundColor:SetColorTexture(theme[3].r, theme[3].g, theme[3].b, 0.2)

    end

    if(self.data.online) then
        if(UnitIsAFK(self.data.unitID)) then
            self.Status:SetTexture("interface/friendsframe/statusicon-away.blp")

        elseif(UnitIsDND(self.data.unitID)) then
            self.Status:SetTexture("interface/friendsframe/statusicon-dnd.blp")

        else
            self.Status:SetTexture("interface/friendsframe/statusicon-online.blp")

        end
    else
        self.Status:SetTexture("interface/friendsframe/statusicon-offline.blp")

    end
end

function RaidViewButtonMixin:SetLayoutIndex(layoutIndex)
    self.layoutIndex = layoutIndex
    self:RefreshColor()
end

function RaidViewButtonMixin:SetCallback(func)
    self.callback = func
end