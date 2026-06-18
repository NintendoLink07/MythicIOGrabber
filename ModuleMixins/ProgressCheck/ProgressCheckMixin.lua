ProgressCheckMixin = {}

local rows = {
    {name = ""},
    {name = "Itemlevel"},
    {name = "Mythic+"},
    {name = "Resilient"},
    {name = "Normal"},
    {name = "Heroic"},
    {name = "Mythic"},
    {name = "Raids"},
    {name = "Dungeons"},
    {name = "World"},
    {name = "Lockouts"},
}

local columns = {
    {name = ""},
    {name = "Name1"},
    {name = "Name2"},
    {name = "Name3"},
    {name = "Name4"},
    {name = "Name5"},
    {name = "Name6"},
    {name = "Name7"},
    {name = "Name8"},
    {name = "Name9"},
    {name = "Name10"},
}

function ProgressCheckMixin:BuildTable()
    local tableBuilder = self.tableBuilder

    for k, v in ipairs(columns) do
        local column = tableBuilder:AddColumn()
        column:ConstructHeader("Button", "MIOG_ProgressCheckHeaderTemplate", v.name)
        column:ConstrainToHeader(3)
        column:ConstructCells("Frame", "MIOG_ProgressCheckCellTemplate")

    end

	tableBuilder:Arrange()
end

function ProgressCheckMixin:OnLoad()
    local view = CreateScrollBoxListLinearView()
    view:SetHorizontal(true)
    view:SetElementInitializer("MIOG_ProgressCheckRowTemplate", function(frame, data)
        frame.Background:SetColorTexture(random(0, 1), random(0, 1), random(0, 1), 1)

    end)

    view:SetPadding(0, 0, 0, 0, 4)

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

    --[[local tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
    tableBuilder:SetHeaderContainer(self.HeaderContainer)

    local function ElementDataProvider(elementData, ...)
        return elementData

    end

    tableBuilder:SetDataProvider(ElementDataProvider)

    local function ElementDataTranslator(elementData, ...)
        return elementData

    end

    ScrollUtil.RegisterTableBuilder(self.ScrollBox, tableBuilder, ElementDataTranslator)

    self.tableBuilder = tableBuilder

    self:BuildTable()]]--
end


function ProgressCheckMixin:OnShow()
    self:SetSize(self:GetParent():GetSize())

	local dataProvider = CreateDataProvider()

    local players = {
        {itemLevel = 999}
    }

    for k, v in ipairs(players) do
        dataProvider:Insert(v)

    end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end



ProgressCheckHeaderMixin = CreateFromMixins(TableBuilderElementMixin);

function ProgressCheckHeaderMixin:Init(...)
    local name = ...
    self.Text:SetText(name)
    
end



ProgressCheckCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressCheckCellMixin:Populate(rowData, dataIndex)
	print(rowData.itemLevel)
    self.Text:SetText(rowData.itemLevel)

end

ProgressCheckRowMixin = CreateFromMixins(TableBuilderRowMixin)




ProgressCheckCharacterOverviewMixin = {}

function ProgressCheckCharacterOverviewMixin:OnLoad()

end