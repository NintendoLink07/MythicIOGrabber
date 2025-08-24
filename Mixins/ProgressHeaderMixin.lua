ProgressHeaderMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressHeaderMixin:Init(row, data)
	--self.GuildBannerBackground:SetVertexColor(color:GetRGB())
    --self.GuildBannerBorder:SetVertexColor(color.r * 0.65, color.g * 0.65, color.b * 0.65)
end

ProgressMythicPlusHeaderMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressMythicPlusHeaderMixin:Init(...)
    local name = ...

    self.Name:SetText(name)
end