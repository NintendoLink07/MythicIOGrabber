local addonName, miog = ...

TableHeaderButtonMixin = {}

function TableHeaderButtonMixin:OnShow()
    local theme = miog.C.CURRENT_THEME
    self.BackgroundColor:SetColorTexture(theme[4].r, theme[4].g, theme[4].b, 0.25)
end