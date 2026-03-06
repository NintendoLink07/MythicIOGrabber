LootSearchBarMixin = {}

function LootSearchBarMixin:OnLoad()
    local filterArea = CreateFrame("Frame", "FilterArea", self, "HorizontalLayoutFrame")
    filterArea.childLayoutDirection = "rightToLeft"
    filterArea.align = "center"
    filterArea.spacing = 4
    filterArea:SetPoint("LEFT", self.Left, "LEFT", 3, 0)
    filterArea:SetPoint("RIGHT", self.Right, "RIGHT", -1, 0)


    self.ActiveFilters = {}

    self.FilterPool = CreateFramePool("Frame", filterArea, "MIOG_SearchBoxFilterTemplate")
    self.FilterArea = filterArea
end

function LootSearchBarMixin:SetCallback(func)
    self.callback = func

end

function LootSearchBarMixin:ClearFilterWidgetByID(id)
    if(self.ActiveFilters[id]) then
        self:ClearFilterWidget(self.ActiveFilters[id])
        self.ActiveFilters[id] = nil

    end
end

function LootSearchBarMixin:ClearFilterWidget(widget)
    for k, v in pairs(self.ActiveFilters) do
        if(v.layer > widget.layer) then
            self.FilterPool:Release(v)

        end
    end

    self.FilterPool:Release(widget)
    self.FilterArea:MarkDirty()
end

function LootSearchBarMixin:CreateFilter(id, name, layer, localCallback)
    local filter = self.FilterPool:Acquire()

    self:ClearFilterWidgetByID(id)

    filter.Name:SetText(name)
    filter.id = id
    filter.layer = layer

    filter.layoutIndex = self.FilterPool:GetNumActive() + 1
    filter:SetWidth(filter.Name:GetStringWidth() + 26)
    filter.Cancel:SetScript("OnClick", function(localSelf)
        self:ClearFilterWidgetByID(localSelf:GetParent().id)

        if(localCallback) then
            localCallback()

        end

        if(self.callback) then
            self.callback()

        end
    end)
    filter:Show()

    self.ActiveFilters[id] = filter
    self.FilterArea:MarkDirty()
end