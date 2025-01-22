local addonName, miog = ...

FilterMixin = {}

function FilterMixin:OnLoad()

end

function FilterMixin:ConnectSetting(tableKeys)
    self.tableKeys = tableKeys

end

function FilterMixin:SetSetting(value)
    self.setting = value

end