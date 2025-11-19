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



SimplifiedSortingButtonMixin = CreateFromMixins(MultiStateButtonsMixin, CallbackRegistryMixin)

SimplifiedSortingButtonMixin:GenerateCallbackEvents(
{
	"OnSortingButtonClick",
});

function SimplifiedSortingButtonMixin:OnLoad()
    MultiStateButtonsMixin.OnLoad(self)
	CallbackRegistryMixin.OnLoad(self)

    self.Text:SetText(self:GetText())
    self:SetWidth(self.Text:GetStringWidth() + self.SortArrow:GetWidth())

    self:SetScript("PostClick", function(selfButton, button)
        self:TriggerEvent("OnSortingButtonClick", self)
    
    end)
end

function SimplifiedSortingButtonMixin:GetStatus()
    return self.active, self.state

end

function SimplifiedSortingButtonMixin:GetID()
    return self:GetName()

end

function SimplifiedSortingButtonMixin:Update()
    if(self.active) then
        self.SortArrow:SetShown(true)

        if(self.state == 1) then
            self.SortArrow:SetTexCoord(0, 1, 0, 1);

        else
            self.SortArrow:SetTexCoord(0, 1, 1, 0);

        end
    else
        self.SortArrow:SetShown(false)

    end
end



