ApplicationViewerMixin = {}

function ApplicationViewerMixin:OnLoad()
    local visualTable = {
        edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 2
    }
    local r, g, b, a = GRAY_FONT_COLOR:GetRGBA()
	
	self:SetBackdrop(visualTable)
	self:SetBackdropBorderColor(r, g, b, a)

end