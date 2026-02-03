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
    local arrayData = data.array and data.array[columnIndex]

    self:ColorCell(data.rowIndex, columnIndex)
    self.Text:SetText(arrayData and arrayData.text or "")

    if(arrayData and arrayData.tooltip) then
        self:SetScript("OnEnter", function(selfFrame)
            GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(arrayData.tooltip)
            GameTooltip:Show()
        end)
    else
        self:SetScript("OnEnter", nil)

    end
end






GearingTableHeaderMixin = {}

function GearingTableHeaderMixin:Init(...)
    local title, hasSetting, settingTable, id, callback = ...

    self.Text:SetText(title)
    
    local initIsChecked = settingTable[id]

    if(initIsChecked == false) then
        self.BackgroundColor:SetColorTexture(0.4, 0.4, 0.4, 0.3)

    else
        self.BackgroundColor:SetColorTexture(1, 1, 1, 0.3)

    end

    if(hasSetting) then
        self:SetScript("OnMouseDown", function()
            local isChecked = settingTable[id]

            if(not isChecked) then
                self.BackgroundColor:SetColorTexture(1, 1, 1, 0.3)
                isChecked = true

            else
                self.BackgroundColor:SetColorTexture(0.7, 0.7, 0.7, 0.3)
                isChecked = false

            end

            settingTable[id] = isChecked
            callback()
        
        end)
    else
        self:SetScript("OnMouseDown", nil)

    end
end