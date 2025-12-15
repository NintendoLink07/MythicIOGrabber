MultiStateButtonsMixin = {}

function MultiStateButtonsMixin:OnLoad()
    self.active = false
    self.state = 0

end

function MultiStateButtonsMixin:Update()
    if(self.textures) then
        if(self.textures.type == "atlas") then
            self.Background:SetAtlas(self.textures[self.state + 1])

        elseif(self.textures.type == "texture") then
            self.Background:SetTexture(self.textures[self.state + 1])

        end
    end

    if(self.highlights) then
        if(self.highlights.type == "atlas") then
            self:SetHighlightAtlas(self.highlights[self.state + 1])

        else
            self:SetHighlightTexture(self.highlights[self.state + 1])

        end
    end
end

function MultiStateButtonsMixin:Reset()
    self.state = 0
    self.active = false

    self:Update()

end

function MultiStateButtonsMixin:AdvanceState()
    self.state = self.state < 2 and self.state + 1 or 0
    self.active = self.state > 0

    self:Update()
end

function MultiStateButtonsMixin:OnClick(button)
    if(button == "LeftButton") then
        self:AdvanceState()

    elseif(button == "RightButton") then
        self:Reset()

    end
end

function MultiStateButtonsMixin:SetTextures(inactive, active1, active2)
    self.textures = {type="texture", inactive, active1 or inactive, active2 or active1 or inactive}
    self.BackgroundColor:Hide()
    self.Background:Show()
    self:Update()

end

function MultiStateButtonsMixin:SetAtlases(inactive, active1, active2)
    self.textures = {type = "atlas", inactive, active1 or inactive, active2 or active1 or inactive}
    self.BackgroundColor:Hide()
    self.Background:Show()
    self:Update()
end

function MultiStateButtonsMixin:SetHighlightAtlases(inactive, active1, active2)
    self.highlights = {type = "atlas", inactive, active1 or inactive, active2 or active1 or inactive}
    self:Update()
end

function MultiStateButtonsMixin:SetHighlightTextures(inactive, active1, active2)
    self.highlights = {type = "texture", inactive, active1 or inactive, active2 or active1 or inactive}
    self:Update()
end

function MultiStateButtonsMixin:DisableTextures()
    self.textures = nil
    self.BackgroundColor:Show()
    self.Background:Hide()

end

function MultiStateButtonsMixin:DisableHighlights()
    self.highlights = nil

end


SortButtonMixin = CreateFromMixins(MultiStateButtonsMixin, CallbackRegistryMixin)

SortButtonMixin:GenerateCallbackEvents(
{
	"OnSortingButtonClick",
});

function SortButtonMixin:SetText(text)
    self.Text:SetText(text)

end

function SortButtonMixin:OnLoad()
    MultiStateButtonsMixin.OnLoad(self)
	CallbackRegistryMixin.OnLoad(self)

    self:SetText(self:GetText())

    self:SetScript("PostClick", function(selfButton, button)
        self:TriggerEvent("OnSortingButtonClick", self)
    
    end)

    self.BackgroundColor:Hide()
    
    --self:SetAtlases("GarrLanding-TopTabUnselected", "GarrLanding-TopTabSelected")
    --self:SetHighlightAtlases("GarrLanding-TopTabHighlight")
end

function SortButtonMixin:GetStatus()
    return self.active, self.state

end

function SortButtonMixin:GetID()
    return self:GetName()

end

function SortButtonMixin:Update()
    MultiStateButtonsMixin.Update(self)

    if(self.active) then
        self.SortArrow:SetShown(true)

        if(self.state == 1) then
            self.SortArrow:SetTexCoord(0, 1, 0, 1);
            self.Text:ClearAllPoints()
            self.Text:SetPoint("LEFT", self, "LEFT", self:GetWidth() / 2 - self.Text:GetStringWidth() / 2 - 4, 0)

        else
            self.SortArrow:SetTexCoord(0, 1, 1, 0);

        end
    else
        self.SortArrow:SetShown(false)
        self.Text:ClearAllPoints()
        self.Text:SetPoint("CENTER")

    end
end