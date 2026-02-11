local addonName, miog = ...

ProgressHeaderMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressHeaderMixin:Init(name, fileName, specID, guid)
    local classID = miog.CLASSFILE_TO_ID[fileName]
    local color = C_ClassColor.GetClassColor(fileName)

    self.Class.Icon:SetTexture(miog.OFFICIAL_CLASSES[classID].icon)
    self.Spec.Icon:SetTexture(specID and miog.SPECIALIZATIONS[specID].squaredIcon or miog.SPECIALIZATIONS[0].squaredIcon)
    self.Name:SetText(name)

    self.GuildBannerBackground:SetVertexColor(color:GetRGB())
    self.GuildBannerBorder:SetVertexColor(color.r * 0.65, color.g * 0.65, color.b * 0.65)
    self.GuildBannerBorderGlow:SetShown(guid == UnitGUID("player"))
end

ProgressMythicPlusHeaderMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressMythicPlusHeaderMixin:Init(...)
    local name = ...

    self.Name:SetText(name)
end