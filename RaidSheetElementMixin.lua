local addonName, miog = ...

RaidSheetElementMixin = {}

function RaidSheetElementMixin:OnLoad(className)
    self.type = "element"
    self.align = "left"

    self:SetClassID(className)
    self:UpdateSpecFrames()
end

function RaidSheetElementMixin:FreeSpace()
    self.layoutIndex = self.originalIndex
    self.occupiedSpace = nil
end

function RaidSheetElementMixin:Reset()
    if(self.activeSpecID) then
        self.activeSpecID = nil
        self.activeRole = nil

    end

    self.SpecPicker:Hide()
    self.Spec:SetTexture(nil)

    self:FreeSpace()
end

function RaidSheetElementMixin:UpdateSpecFrames()
    self.specIDs = {}

    for i = 1, GetNumSpecializationsForClassID(self.classID), 1 do
        local id, name, description, icon, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(self.classID, i)

        table.insert(self.specIDs, {id = id, role = role, icon = icon})

        local specFrame = self.SpecPicker["Spec" .. i]
        specFrame:SetNormalTexture(icon)
        specFrame.id = id
        specFrame.layoutIndex = i
        specFrame:SetScript("OnClick", function(selfFrame)
            self:SetActiveSpecID(selfFrame.id)
        end)
    end

    self.SpecPicker:MarkDirty()
end

function RaidSheetElementMixin:SetActiveSpecID(specID)
    for k, v in ipairs(self.specIDs) do
        if(v.id == specID) then
            self.Spec:SetTexture(v.icon)
            self.activeSpecID = v.id
            self.activeRole = v.role

        end
    end
end

function RaidSheetElementMixin:SetClassID(className)
    self.className = className
    self.classID = miog.CLASSFILE_TO_ID[className]

    self.color = C_ClassColor.GetClassColor(className)

    self:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=1, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})
    self:SetBackdropColor(self.color:GetRGBA())
    self:SetBackdropBorderColor(self.color.r - 0.15, self.color.g - 0.15, self.color.b - 0.15, 1)

    self:UpdateSpecFrames()
end

function RaidSheetElementMixin:OccupySpace(spaceFrame)
    self:ClearAllPoints()
    self.layoutIndex = nil

    self:SetPoint("TOPLEFT", spaceFrame, "TOPLEFT", 1, -1)
    self:SetPoint("BOTTOMRIGHT", spaceFrame, "BOTTOMRIGHT", -1, 1)

    self.occupiedSpace = spaceFrame
end