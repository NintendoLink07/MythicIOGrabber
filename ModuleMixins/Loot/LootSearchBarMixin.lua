LootSearchBarMixin = {}

function LootSearchBarMixin:OnLoad()
    local filterArea = CreateFrame("Frame", "FilterArea", self, "HorizontalLayoutFrame")
    filterArea.childLayoutDirection = "rightToLeft"
    filterArea.align = "center"
    filterArea:SetPoint("TOPLEFT", self.Left, "TOPLEFT", 4, -2)
    filterArea:SetPoint("BOTTOMRIGHT", self.Right, "BOTTOMRIGHT", -4, 0)

    self.ActiveFilters = {}

    self.FilterPool = CreateFramePool("Button", filterArea, "MIOG_SearchBoxFilterTemplate")
    self.FilterArea = filterArea
end

function LootSearchBarMixin:SetCallback(func)
    self.callback = func

end

function LootSearchBarMixin:ClearFilterWidget(widget)
    self.FilterPool:Release(widget)
    self.FilterArea:MarkDirty()
end

function LootSearchBarMixin:CreateFilter(id, name, localCallback)
    local filter = self.FilterPool:Acquire()

    if(self.ActiveFilters[id]) then
        self:ClearFilterWidget(self.ActiveFilters[id])

    end

    filter.Name:SetText(name)
    filter.id = id

    filter.layoutIndex = self.FilterPool:GetNumActive() + 1
    filter:SetWidth(filter.Name:GetStringWidth() + 48)
    filter.Cancel:SetScript("OnClick", function(localSelf)
        self:ClearFilterWidget(localSelf:GetParent())

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

function LootSearchBarMixin:RefreshFilters()
    local instance = EJ_GetInstanceInfo()

    self:CreateFilter("instance", instance)
end