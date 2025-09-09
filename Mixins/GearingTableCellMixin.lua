GearingTableCellMixin = {}

function GearingTableCellMixin:Init(id)
    self.id = id
end

function GearingTableCellMixin:Populate(data, index)
    self.Text:SetText(data[self.id] or "")

end






GearingTableHeaderMixin = {}

function GearingTableHeaderMixin:Init(...)
    local title, settingsTable = ...

    self.Text:SetText(title)
end

