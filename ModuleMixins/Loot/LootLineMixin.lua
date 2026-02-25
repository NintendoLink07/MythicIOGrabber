LootLineMixin = {}

function LootLineMixin:RefreshExpandIcon(bool)
    local state = self:GetElementData():IsCollapsed()

    if(state == true) then
	    self.Expand:SetAtlas("campaign_headericon_closed");
        
    elseif(state == false) then
	    self.Expand:SetAtlas("campaign_headericon_open");

    else
	    self.Expand:SetAtlas("campaign_headericon_open");

    end

end

function LootLineMixin:SetExpandState(bool)
    self.Icon:ClearAllPoints()

    if(bool) then
        self.Expand:Show()
        self.Icon:SetPoint("LEFT", self.Expand, "RIGHT", 2, 0)
    
    else
        self.Expand:Hide()
        self.Icon:SetPoint("LEFT", self, "LEFT", 2, 0)

    end

    self:RefreshExpandIcon()
end

function LootLineMixin:OnMouseDown(button)
    if(button == "LeftButton") then
        self:GetElementData():ToggleCollapsed()
        self:RefreshExpandIcon()

    elseif(button == "RightButton") then
        if(self.OnMouseDown_Right) then
            self:OnMouseDown_Right()

        end
    end
end

function LootLineMixin:OnLoad()
    self:SetBackdrop({
        edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1
    })
    self:SetBackdropBorderColor(PAPER_FRAME_EXPANDED_COLOR:GetRGB())

end