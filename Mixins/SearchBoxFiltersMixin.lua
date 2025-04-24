SearchBoxFiltersMixin = {}

function SearchBoxFiltersMixin:OnLoad()
    local filterArea = CreateFrame("Frame", "FilterArea", self, "HorizontalLayoutFrame")
    filterArea.childLayoutDirection = "rightToLeft"
    filterArea.align = "center"
    filterArea:SetPoint("TOPLEFT", self.Left, "TOPLEFT", 4, -2)
    filterArea:SetPoint("BOTTOMRIGHT", self.Right, "BOTTOMRIGHT", -4, 0)

    self.filterPool = CreateFramePool("Button", filterArea, "MIOG_SearchBoxFilterTemplate")
    self.filterArea = filterArea
end

function SearchBoxFiltersMixin:SetHierarchy(tbl)
    self.hierarchy = tbl

end

function SearchBoxFiltersMixin:CheckForExistingFilter(id)
    for widget in self.filterPool:EnumerateActive() do
        if(widget.id == id) then
            return true, widget
        end

    end

    return false
end

function SearchBoxFiltersMixin:ShowFilter(id, name, callback)
    local doesFilterIDExist, widget = self:CheckForExistingFilter(id)

    if(doesFilterIDExist) then
        if(widget.Name:GetText() ~= name) then
            self.filterPool:Release(widget)
            
        else
            return

        end
    end

    local filter = self.filterPool:Acquire()
    filter.Name:SetText(name)
    filter.id = id

    filter.layoutIndex = self.filterPool:GetNumActive() + 1
    filter:SetWidth(filter.Name:GetStringWidth() + 48)
    filter.Cancel:SetScript("OnClick", function(localSelf)
        self:ClearFilterWidget(localSelf:GetParent())

        if(callback) then
            callback()

        end
    end)
    filter:Show()

    filter:GetParent():MarkDirty()
end

function SearchBoxFiltersMixin:GetNumActiveFilters()
    return self.filterPool:GetNumActive()
end

function SearchBoxFiltersMixin:IsIDActive(id)
    for widget in self.filterPool:EnumerateActive() do
        if(widget.id == id) then
            return true
        end
    end

    return false
end

function SearchBoxFiltersMixin:GetIDHierarchyOrder(id)
    for k, v in ipairs(self.hierarchy) do
        if(v.id == id) then
            return v.order

        end
    end
end

function SearchBoxFiltersMixin:ClearFilterWidget(widget)
    local id = widget.id

    self.filterPool:Release(widget)

    self:ClearLowerIDsIfNecessary(id)

    self.filterArea:MarkDirty()
end

function SearchBoxFiltersMixin:ClearLowerIDsIfNecessary(id)
    local highestIDOrder = self.hierarchy[#self.hierarchy].order

    if(self:GetIDHierarchyOrder(id) < highestIDOrder) then
        for k, v in ipairs(self.hierarchy) do
            for widget in self.filterPool:EnumerateActive() do
                if(self:GetIDHierarchyOrder(id) < highestIDOrder) then
                    self:ClearFilterWidget(widget)
                    widget:GetParent():MarkDirty()
        
                end
            end
        end
    end
end

function SearchBoxFiltersMixin:ClearFilterID(id)
    for widget in self.filterPool:EnumerateActive() do
        if(widget.id == id) then
            self:ClearFilterWidget(widget)

            break
        end
    end
end

function SearchBoxFiltersMixin:ClearAllFilters()
    self.filterPool:ReleaseAll()
    self.filterArea:MarkDirty()

end