ColorCellMixin = {}

function ColorCellMixin:OnLoad()

end

function ColorCellMixin:SetColor(r, g, b, a)
    self.BackgroundColor:SetColorTexture(r, g, b, a)
    self.BackgroundColor:Show()
end