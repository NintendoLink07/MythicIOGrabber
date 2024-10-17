local addonName, miog = ...

RaidSheetSpaceMixin = {}

function RaidSheetSpaceMixin:OnLoad(index)
    self.type = "space"
    self.occupied = false
    self:SetParentKey("Space" .. index)
    self.index = index
    self.Number:SetText("#" .. index)
end

function RaidSheetSpaceMixin:Reset()
    self.occupied = false
    self.occupiedBy = nil
end

function RaidSheetSpaceMixin:SetOccupiedBy(elementFrame)
    if(elementFrame and elementFrame:GetObjectType() == "Button") then
        self.occupied = true
        self.occupiedBy = elementFrame
    end
end