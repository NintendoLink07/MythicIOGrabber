local addonName, miog = ...

ColorChangerMixin = {}

function ColorChangerMixin:OnShow()
    local theme = miog.C.CURRENT_THEME

    if(self.hasHighlight) then
        self:GetHighlightTexture():SetVertexColor(theme[5].r, theme[5].g, theme[5].b, 1)

    end

    if(self.hasBackdrop) then
        miog.createFrameBorder(self, 1, theme[4].r, theme[4].g, theme[4].b, 1)

    end
end