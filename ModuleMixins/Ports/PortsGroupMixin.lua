local addonName, miog = ...

local maxNumberOfFramesInARow = 7
local expansions = {}

PortsGroupMixin = {}

function PortsGroupMixin:OnLoad()
    self.groups = {}
    self.framePool = CreateFramePool("Button", self.Subgroup, "MIOG_PortsButtonTemplate", function(_, frame) frame:Hide() frame.gridRow = nil frame.gridColumn = nil end)

    self.Subgroup.childXPadding = 4
    self.Subgroup.childYPadding = 2

    self.Subgroup.topPadding = 0
    self.Subgroup.leftPadding = 0
    self.Subgroup.rightPadding = 0
    self.Subgroup.bottomPadding = 0

end

function PortsGroupMixin:CalculateLayout(numFramesAdded)
    local numOfRegisteredElements = #self.groups

    local actualNumOfElements = numOfRegisteredElements + numFramesAdded

    self.rows = actualNumOfElements > 7 and 2 or 1
    
    local hasRest = actualNumOfElements % self.rows == 0

    if(hasRest) then
        self.numLastRowElements = actualNumOfElements % self.rows
        self.columns = ceil(actualNumOfElements / self.rows)
        
    else
        self.columns = ceil(actualNumOfElements / self.rows)

    end
end

function PortsGroupMixin:Setup(id, expansion)
    local name, description, numSlots, isKnown = GetFlyoutInfo(id)

    self:CalculateLayout(numSlots)
    
    local frameW, frameH = 0, 0

    local index = 0

    for i = 1, self.rows, 1 do
        local numOfCurrentElements = self.numLastRowElements and k == self.columns and self.numLastRowElements or self.columns

        for k = 1, numOfCurrentElements, 1 do
            index = index + 1

            local frame = self.groups[index]

            if(not frame) then
                frame = self.framePool:Acquire()
                frame.gridColumnSize = 1
                frame.gridRowSize = 1

                tinsert(self.groups, frame)
            end

            if(i == 1 and k == 1) then
                frameW, frameH = frame:GetSize()
                
            end

            frame.gridRow = i
            frame.gridColumn = k
            frame:Show()
        end
    end

    local subgroup = self.Subgroup
	
    -- actually necessary with a StaticGridLayoutFrame lol, need to rewrite Blizzard's implementation next
	self:SetSize(frameW * maxNumberOfFramesInARow + subgroup.childXPadding * (maxNumberOfFramesInARow - 1) + subgroup.leftPadding + subgroup.rightPadding + 20, frameH * self.rows + subgroup.childYPadding * (self.rows - 1) + subgroup.topPadding + subgroup.bottomPadding + 16)

    local start

    if(expansion) then
        start = expansions[expansion] and expansions[expansion] + 1 or 1
        expansions[expansion] = numSlots

    else
        start = 1

        self.Name:ClearAllPoints()
        self.Name:SetPoint("CENTER", self, "TOP", 0, -7)

        self.Subgroup:ClearAllPoints()
        self.Subgroup:SetPoint("CENTER")
        self.Subgroup:SetWidth(4 * frameW)
        self.Subgroup:SetHeight(2 * frameH)
    end

    if(expansion) then

    end

    for k = 1, numSlots, 1 do
        local flyoutSpellID, _, spellKnown, spellName, _ = GetFlyoutSlotInfo(id, k)

        if(self.groups[start]) then
            self.groups[start]:SetData({spellID = flyoutSpellID, isKnown = spellKnown})

            start = start + 1
        end
    end
end

ResizeStaticGridLayoutFrameMixin = CreateFromMixins(StaticGridLayoutFrameMixin);

function ResizeStaticGridLayoutFrameMixin:Layout()
    StaticGridLayoutFrameMixin.Layout(self)

end