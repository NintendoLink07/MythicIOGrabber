local addonName, miog = ...

FilterSettings = CreateFromMixins(CallbackRegistryMixin)

local categoryFilters = {
    [1] = {"Activity"},
    [2] = {"Activity", "Rating"},
    [3] = {"Activity", "Rating"},
    [4] = {"Activity", "Rating"},
    [6] = {"Activity"},
    [9] = {"Activity", "Rating"},
    [121] = {"Activity"},
}

local categoryID

function FilterSettings:Setup(originalFrame)
    categoryID = originalFrame.categoryID

    if(categoryID) then
        self.framePool:ReleaseAll()

        local key = originalFrame:GetDebugName()
        local settings = MIOG_NewSettings.filterSettings[key]

        if(not settings) then
            MIOG_NewSettings.filterSettings[key] = C_LFGList.GetAdvancedFilter()

            settings = MIOG_NewSettings.filterSettings[key]
        end

        for k, v in ipairs(categoryFilters[categoryID]) do
            local filter = self.framePool:Acquire()
            filter.originalIndex = k
            filter.layoutIndex = k
            filter.Name:SetText(v)
            filter:SetSize(100, 20)
            filter:GetParent():MarkDirty()

        end

        --[[
            needsTank 	boolean? = false 	
            needsHealer 	boolean? = false 	
            needsDamage 	boolean? = false 	
            needsMyClass 	boolean? = false 	
            hasTank 	boolean? = false 	
            hasHealer 	boolean? = false 	
            activities 	number[] 	Activity group IDs to filter by.
            minimumRating 	number? = 0 	
            difficultyNormal 	boolean? = false 	
            difficultyHeroic 	boolean? = false 	
            difficultyMythic 	boolean? = false 	
            difficultyMythicPlus 	boolean? = false 	
            generalPlaystyle1 	boolean? = false 	12.0.0
            generalPlaystyle2 	boolean? = false 	12.0.0
            generalPlaystyle3 	boolean? = false 	12.0.0
            generalPlaystyle4 	boolean? = false 	12.0.0
        ]]
    end
end

function FilterSettings:OnShow()

end

function FilterSettings:RenameFilters(filterFrame)
    local sortDrop = self.FilterList.SortDrop

    filterFrame.Index:SetText("")
    filterFrame.Name:SetText(categoryFilters[categoryID][filterFrame.originalIndex])

    for k, v in ipairs(sortDrop:GetLayoutChildren()) do
        v.layoutIndex = k
        v.Index:SetText(k .. ".")
        v.Name:SetText(categoryFilters[categoryID][v.originalIndex])

    end

end

function FilterSettings:DragFilter(filterFrame)

end

function FilterSettings:DropFilter(filterFrame)
    local sortDrop = self.FilterList.SortDrop
    local bucket = self.FilterList.FilterBucket

    local sortIndex = #sortDrop:GetLayoutChildren()
    local bucketIndex = #bucket:GetLayoutChildren()

    for k, v in ipairs(sortDrop:GetLayoutChildren()) do
        if(v == filterFrame) then
            
        elseif(v ~= filterFrame and MouseIsOver(v, 0, 8)) then
            filterFrame:SetParent(sortDrop)
            filterFrame.layoutIndex = sortIndex - 1.5
            sortDrop.Instructions:Hide()
            bucket.Instructions:SetShown(#bucket:GetLayoutChildren() == 0)

            sortDrop:MarkDirty()

            self:RenameFilters(filterFrame)

            return
        end
    end

    if(MouseIsOver(sortDrop)) then
        filterFrame:SetParent(sortDrop)
        filterFrame.layoutIndex = sortIndex + 1
        sortDrop.Instructions:Hide()
        bucket.Instructions:SetShown(#bucket:GetLayoutChildren() == 0)

        self:RenameFilters(filterFrame)

        sortDrop:MarkDirty()

    elseif(MouseIsOver(bucket)) then
        filterFrame:SetParent(bucket)
        filterFrame.layoutIndex = bucketIndex + 1
        bucket.Instructions:Hide()
        sortDrop.Instructions:SetShown(#sortDrop:GetLayoutChildren() == 0)

        self:RenameFilters(filterFrame)

        bucket:MarkDirty()
    else
        filterFrame:GetParent():MarkDirty()

    end

end

function FilterSettings:ResetFilter(filterFrame)
    local bucket = self.FilterList.FilterBucket
    filterFrame:SetParent(bucket)
    filterFrame.layoutIndex = #bucket:GetLayoutChildren() + 1
    bucket.Instructions:Hide()

    local sortDrop = self.FilterList.SortDrop
    sortDrop.Instructions:SetShown(#sortDrop:GetLayoutChildren() == 0)

    self:RenameFilters(filterFrame)

    sortDrop:MarkDirty()
    bucket:MarkDirty()

end

function FilterSettings:OnLoad()
    self.framePool = CreateFramePool("Frame", self.FilterList.FilterBucket, "MIOG_FilterSettingsFilterTemplate", function(_, frame) frame.Name:SetText("") frame.layoutIndex = nil frame.originalIndex = nil end)

    hooksecurefunc("LFGListFrame_SetActivePanel", function(lfgFrame, subFrame)
        self:Setup(subFrame)

    end)

    EventRegistry:RegisterCallback("MIOG_DRAG_FILTER", function(_, filterFrame) self:DragFilter(filterFrame) end, self);
    EventRegistry:RegisterCallback("MIOG_DROP_FILTER", function(_, filterFrame) self:DropFilter(filterFrame) end, self);
    EventRegistry:RegisterCallback("MIOG_RESET_FILTER", function(_, filterFrame) self:ResetFilter(filterFrame) end, self);
end

function FilterSettings:OnEvent(event, ...)

end






FilterSettingsFilterMixin = {}

function FilterSettingsFilterMixin:OnLoad()

end

function FilterSettingsFilterMixin:OnMouseDown()
    self:StartMoving()
    EventRegistry:TriggerEvent("MIOG_DRAG_FILTER", self)
end

function FilterSettingsFilterMixin:OnMouseUp()
    self:StopMovingOrSizing()
    EventRegistry:TriggerEvent("MIOG_DROP_FILTER", self)
end







FilterSettingsFilterCloseButtonMixin = {}

function FilterSettingsFilterCloseButtonMixin:OnClick()
    EventRegistry:TriggerEvent("MIOG_RESET_FILTER", self:GetParent())
end

