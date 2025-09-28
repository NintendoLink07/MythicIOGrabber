GearingTableCellMixin = {}

function GearingTableCellMixin:ColorCell(rowIndex, columnIndex)
    if(rowIndex) then
        local restRow = rowIndex % 2
        local restColumn = columnIndex % 2

        local value = 1 - (restRow + restColumn) * 0.25

        self.BackgroundColor:SetColorTexture(value, value, value, 0.1)
        
    end
end

function GearingTableCellMixin:Init()
end

function GearingTableCellMixin:Populate(data, columnIndex)
    self:ColorCell(data.rowIndex, columnIndex)
    self.Text:SetText(data.text[columnIndex] or "")

end






GearingTableHeaderMixin = {}

function GearingTableHeaderMixin:Init(...)
    local title, hasCheckbox, settingTable, id, callback = ...

    self.Text:SetText(title)
    self.Text:ClearAllPoints()
    
    if(hasCheckbox) then
        self.Text:SetPoint("CENTER", 7, 0)

    else
        self.Text:SetPoint("CENTER")

    end

    self.Checkbox:SetShown(hasCheckbox)

    if(hasCheckbox) then
        self.Checkbox:SetChecked(settingTable[id] == nil and true or settingTable[id])
        self.Checkbox:SetScript("OnClick", function(selfButton)
            settingTable[id] = selfButton:GetChecked()
            callback()
        
        end)
    end
end