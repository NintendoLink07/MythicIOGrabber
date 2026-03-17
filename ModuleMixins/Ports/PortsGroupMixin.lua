local addonName, miog = ...

local maxNumberOfFramesInARow = 7
local seasonButtonSize = 40

local expansions = {}

PortsGroupMixin = {}

function PortsGroupMixin:OnLoad()
    self.groups = {}
    self.framePool = CreateFramePool("Button", self.Subgroup, "MIOG_PortsButtonTemplate", function(_, frame) frame.gridRow = nil frame.gridColumn = nil end)

    local grid = self.Subgroup

    grid.childXPadding = 8
    grid.childYPadding = 4

    if(self:GetParentKey() == "ActiveSeason") then
        grid:ClearAllPoints()
        grid:SetPoint("BOTTOM", 0, 12)
        grid:SetWidth(4 * seasonButtonSize + 3 * grid.childXPadding)
        grid:SetHeight(2 * seasonButtonSize + grid.childYPadding)

    end
end

function PortsGroupMixin:Setup(id, expansion)
    local name, description, numSlots, isKnown = GetFlyoutInfo(id)

    if(expansion) then
        local expInfo = miog.EXPANSIONS[expansion]

        self.Icon:SetTexture(expInfo.icon)
    end

    local frameW, frameH

    for i = 1, numSlots, 1 do
        local flyoutSpellID, _, spellKnown, spellName, _ = GetFlyoutSlotInfo(id, i)
        
        local frame = self.framePool:Acquire()
        frame:SetData({spellID = flyoutSpellID, isKnown = spellKnown})
        frameW, frameH = frame:GetSize()
        
        tinsert(self.groups, frame)
    end

    local totalNumOfSlots = #self.groups
    local firstRow, numOfRows
    
    if(totalNumOfSlots > maxNumberOfFramesInARow) then
        firstRow, secondRow = floor(totalNumOfSlots / 2), ceil(totalNumOfSlots / 2)
        numOfRows = 2

    else
        firstRow = maxNumberOfFramesInARow
        numOfRows = 1

    end

    for k, v in ipairs(self.groups) do
        v.gridRow = k <= firstRow and 1 or 2
        v.gridColumn = k <= firstRow and k or k - firstRow

    end

    local subgroup = self.Subgroup

    if(self:GetParentKey() == "ActiveSeason") then

        self:SetHeight(seasonButtonSize * numOfRows + subgroup.childYPadding * (numOfRows - 1))

        for k, v in pairs(self.groups) do
            v:SetSize(seasonButtonSize, seasonButtonSize)

        end


    else
        self:SetHeight(frameH * numOfRows + subgroup.childYPadding * (numOfRows - 1))
        
    end
end

ResizeStaticGridLayoutFrameMixin = CreateFromMixins(StaticGridLayoutFrameMixin);

function ResizeStaticGridLayoutFrameMixin:Layout()
    StaticGridLayoutFrameMixin.Layout(self)

end