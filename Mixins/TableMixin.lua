TableMixin = {}

local function resetFrame(pool, frame)
    frame:Hide()
    frame.gridRow = nil
    frame.gridColumn = nil
    frame.minimumWidth = nil
end

function TableMixin:OnLoad(sizeW, sizeH, spacing, spacingH)
    self.columnWidths = {}
    self.lines = {}

    if(not spacingH) then
        self.childXPadding = spacing or 0
        self.childYPadding = spacing or 0

    else
        self.childXPadding = spacingW or 0
        self.childYPadding = spacingH or 0

    end

    self.cellWidth = sizeW or 40
    self.cellHeight = sizeH or 14

    local dividers = CreateFrame("Frame", "DividersParentFrame", self, "VerticalLayoutFrame")
    dividers:SetAllPoints(self)
    dividers:Show()
    
    self.Dividers = dividers

    self.pools = CreateFramePoolCollection()
	--self.pools:CreatePool("Frame", self, "MIOG_TableColumnTemplate")
	--self.pools:CreatePool("Frame", self, "MIOG_TableRowTemplate")
	self.pools:CreatePool("Frame", self, "MIOG_TableCellTemplate", resetFrame)
	self.pools:CreatePool("Frame", self, "MIOG_TableCellWithCheckboxTemplate", resetFrame)
	self.pools:CreatePool("Frame", self.Dividers, "MIOG_TableDivider", resetFrame)

    self.standardAtlas = "VAS-inputBox"
end
 
function TableMixin:SetCellAtlas(atlas)
    self.standardAtlas = atlas

    self.pools:ReleaseAll()
    self:CreateTable()
end

local function getMaximumSize(textWidth, currentWidth)
    return textWidth > 1 and textWidth + 5 or 1
end

function TableMixin:AddRowLines(numOfLines)
    local lastLine


    for i = 1, numOfLines, 1 do
        local chartLine = self.pools:Acquire("MIOG_TableDivider")
        chartLine:SetHeight(self.spacingH or self.spacing or 2)
        local indexOffset = -14

        chartLine:SetPoint("TOPLEFT", lastLine or self, lastLine and "BOTTOMLEFT" or "TOPLEFT", 0, indexOffset)
        chartLine:SetPoint("TOPRIGHT", lastLine or self, lastLine and "BOTTOMRIGHT" or "TOPRIGHT", 0, indexOffset)
        chartLine:Show()

        tinsert(self.lines, chartLine)

        lastLine = chartLine
    end

end

function TableMixin:CreateHeaders(tbl, settingsTable)
    self.headers = {}

    for k = 1, min(#tbl, self.iterationsColumns), 1 do
        local settingsName = (tbl[k].id or "") .. tbl[k].name
        local isCheckbox = tbl[k].checkbox
        local frame = self.pools:Acquire(isCheckbox and "MIOG_TableCellWithCheckboxTemplate" or "MIOG_TableCellTemplate")
        frame.Background:SetAtlas("")
        frame.Text:SetText(tbl[k].name)
        frame.gridRow = 1
        frame.gridColumn = k
        frame.minimumWidth = getMaximumSize(frame.Checkbox and (frame.Text:GetStringWidth() + frame.Checkbox:GetWidth()) or frame.Text:GetStringWidth(), frame:GetWidth())
        frame.minimumHeight = self.cellHeight

        if(isCheckbox) then
            if(settingsTable[settingsName] ~= nil) then
                frame.Checkbox:SetChecked(settingsTable[settingsName])
                
            else
                frame.Checkbox:SetChecked(true)

            end

            frame.Checkbox:SetScript("OnClick", function(localSelf, button)
                local isChecked = localSelf:GetChecked()

                for i = 1, self.iterationsRows, 1 do
                    local cell = self.cells[i][k]
                    cell:SetShown(isChecked and cell.Text:GetText() ~= nil)
                    cell.gridColumn = isChecked and k or nil
                    cell.gridRow = isChecked and (i + 1) or nil

                end

                settingsTable[settingsName] = isChecked

                self:MarkDirty()

            end)
        end

        self.headers[k] = frame

        frame:Show()
        frame:MarkDirty()
    end
end

function TableMixin:AddNewRow(showAll)
    local start = #self.cells + self.headerOffset + 1

    self.cells[start] = {}

    for k = 1, self.iterationsColumns, 1 do
        local frame = self.pools:Acquire("MIOG_TableCellTemplate")
        frame.Background:SetAtlas(self.standardAtlas)
        frame.gridRow = start
        frame.gridColumn = k
        frame.minimumHeight = 14
        frame:MarkDirty()

        if(showAll) then
            frame:Show()

        end

        self.cells[start][k] = frame
    end

    return self.cells[start]
end

function TableMixin:CreateTable(showAll, headerData, settingsTable)
    self.cells = {}
    self.pools:ReleaseAll()

    local width, height = self:GetSize()
    self.headerOffset = headerData ~= nil and 1 or 0
    self.iterationsRows = floor(height / (self.cellHeight + self.childYPadding)) - self.headerOffset

    if(headerData) then
        self.iterationsColumns = min(#headerData, floor(width / (self.cellWidth + self.childXPadding)))
        self:CreateHeaders(headerData, settingsTable)

    else
        self.iterationsColumns = floor(width / (self.cellWidth + self.childXPadding))

    end

    for i = 1, self.iterationsRows, 1 do
        self.cells[i] = {}

        for k = 1, self.iterationsColumns, 1 do
            local frame = self.pools:Acquire("MIOG_TableCellTemplate")
            frame.Background:SetAtlas(self.standardAtlas)
            frame.gridRow = i + self.headerOffset
            frame.gridColumn = k
            frame.minimumHeight = 14
            frame:MarkDirty()

            if(showAll) then
                frame:Show()

            end

            self.cells[i][k] = frame
        end
    end

    self:AddRowLines(self.iterationsRows - (headerData and 0 or 1))

    self:MarkDirty()
end

function TableMixin:SetCellText(text, row, column)
    local rowTable = self.cells[row]

    if(not rowTable) then
        rowTable = self:AddNewRow()

    end

    local cell = rowTable[column]

    if(cell) then
        cell.Text:SetText(text)

        cell.minimumWidth = getMaximumSize(cell.Checkbox and (cell.Text:GetStringWidth() + cell.Checkbox:GetWidth()) or cell.Text:GetStringWidth(), cell:GetWidth())
        cell:MarkDirty()

        local header = self.headers[cell.gridColumn]

        if(header and header.Checkbox) then
            cell:SetShown(header.Checkbox:GetChecked())
            
        else
            cell:SetShown(true)

        end
    end

    self:MarkDirty()
end

function TableMixin:AddTextToColumn(table, index)
    for k, v in pairs(table) do
        self:SetCellText(v, k, index)

    end
end

function TableMixin:AddTextToRow(table, index)
    for k, v in pairs(table) do
        self:SetCellText(v, index, k)

    end
end