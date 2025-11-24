MultiStateButtonsMixin = {}

function MultiStateButtonsMixin:OnLoad()
    self.active = false
    self.state = 0

end

function MultiStateButtonsMixin:Update()

end

function MultiStateButtonsMixin:AdvanceState()
    self.state = self.state < 2 and self.state + 1 or 0
    self.active = self.state > 0

    self:Update()

end

function MultiStateButtonsMixin:OnClick()
    self:AdvanceState()

end



SortButtonMixin = CreateFromMixins(MultiStateButtonsMixin, CallbackRegistryMixin)

SortButtonMixin:GenerateCallbackEvents(
{
	"OnSortingButtonClick",
});

function SortButtonMixin:SetText(text)
    self.Text:SetText(text)
    self:SetWidth(self.Text:GetStringWidth() + self.SortArrow:GetWidth() + 6)

end

function SortButtonMixin:OnLoad()
    MultiStateButtonsMixin.OnLoad(self)
	CallbackRegistryMixin.OnLoad(self)

    self:SetText(self:GetText())

    self:SetScript("PostClick", function(selfButton, button)
        self:TriggerEvent("OnSortingButtonClick", self)
    
    end)
end

function SortButtonMixin:GetStatus()
    return self.active, self.state

end

function SortButtonMixin:GetID()
    return self:GetName()

end

function SortButtonMixin:Update()
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