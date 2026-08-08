ModernCheckButtonMixin = {}

function ModernCheckButtonMixin:OnLoad()

end

function ModernCheckButtonMixin:SetText(text)
    self.Text:SetText(text)

    self:MarkDirty()
end

function ModernCheckButtonMixin:SetChecked(bool)
    self.CheckButton:SetChecked(bool)
    
end

function ModernCheckButtonMixin:GetChecked()
    return self.CheckButton:GetChecked()
    
end

function ModernCheckButtonMixin:SetOnClick(func)
    self.CheckButton:SetScript("OnClick", func)
    
end