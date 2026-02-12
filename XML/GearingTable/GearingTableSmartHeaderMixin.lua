GearingTableSmartHeaderMixin = {}

function GearingTableSmartHeaderMixin:Init(...)
    local name, canBeDisabled = ...

    self.Text:SetText(name)
    self:SetScript("OnClick", canBeDisabled and function() print("NOT YET IMPLEMENTED; LOL") end or nil)
end