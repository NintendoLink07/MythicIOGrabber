GearingTableSmartCellMixin = {}

function GearingTableSmartCellMixin:Init()

end

function GearingTableSmartCellMixin:Populate(...)
    local data, index = ...

    local row = data[1][1]

    if(row) then
        if(row % 2 == 0) then
            self:SetColor(1, 1, 1, 0.1)

        else
            self:SetColor(0.75, 0.75, 0.75, 0.1)

        end
    end

    self.Text:SetText(data[index+1][1])

    if(data[index+1][2]) then
        self.Text:SetScript("OnEnter", function(selfFrame)
            GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(data[index+1][2])
            GameTooltip:Show()

        end)

    end
end