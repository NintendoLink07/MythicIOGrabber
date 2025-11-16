SimplifiedSortingButtonMixin = CreateFromMixins(CallbackRegistryMixin)

SimplifiedSortingButtonMixin:GenerateCallbackEvents(
{
	"OnSortingButtonClick",
});

function SimplifiedSortingButtonMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self)
    self.Text:SetText(self:GetText())
    self:SetWidth(self.Text:GetStringWidth() + self.Button:GetWidth() + 2)

    self.Button:SetScript("OnClick", function(selfButton, button)
        self:TriggerEvent("OnSortingButtonClick", self:GetName(), selfButton:GetChecked())
    
    end)
end