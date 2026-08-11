local addonName, miog = ...

FilterSettings = CreateFromMixins(CallbackRegistryMixin)

local callbacks = {}

local filterData = {
    [1] = {id = "activityName", name = "Activity"},
    [2] = {id = "rating", name = "Rating"},
}

local categoryFilters = {
    [1] = {filterData[1]},
    [2] = {filterData[1], filterData[2]},
    [3] = {filterData[1], filterData[2]},
    [4] = {filterData[1], filterData[2]},
    [6] = {filterData[1]},
    [9] = {filterData[1], filterData[2]},
    [121] = {filterData[1]},
}

local EJ_DIFFICULTIES = {
	DifficultyUtil.ID.DungeonNormal,
	DifficultyUtil.ID.DungeonHeroic,
	DifficultyUtil.ID.DungeonMythic,
	DifficultyUtil.ID.DungeonChallenge,
	DifficultyUtil.ID.DungeonTimewalker,
	DifficultyUtil.ID.RaidLFR,
	DifficultyUtil.ID.Raid10Normal,
	DifficultyUtil.ID.Raid10Heroic,
	DifficultyUtil.ID.Raid25Normal,
	DifficultyUtil.ID.Raid25Heroic,
	DifficultyUtil.ID.PrimaryRaidLFR,
	DifficultyUtil.ID.PrimaryRaidNormal,
	DifficultyUtil.ID.PrimaryRaidHeroic,
	DifficultyUtil.ID.PrimaryRaidMythic,
	DifficultyUtil.ID.RaidTimewalker,
	DifficultyUtil.ID.Raid40,
};

local categoryID
local key

function FilterSettings:GetSortOrder()
    return self.settings.sort

end

function FilterSettings:SetupSortFilters()
    for k, v in ipairs(categoryFilters[categoryID]) do
        local filterFrame = self.SortFilterFramePool:Acquire()

        filterFrame.originalIndex = k
        filterFrame.Name:SetText(v.name)

        filterFrame:SetSize(120, 20)

        local filterSettings = self.settings.sort and self.settings.sort[v.id]

        if(filterSettings) then
            filterFrame.Index:SetText(filterSettings.index .. ".")
            filterFrame.Reset:Show()
            filterFrame.SortDirection:Show()
            filterFrame:SetParent(self.FilterList.SortDrop)
            
            local isDescending = filterSettings.state == 1

            if(isDescending) then
                filterFrame.SortDirection.Icon:SetTexCoord(0, 1, 0, 1);

            else
                filterFrame.SortDirection.Icon:SetTexCoord(0, 1, 1, 0);

            end

            filterFrame.layoutIndex = filterSettings.index
            
        else
            filterFrame.Index:SetText("")
            filterFrame.Reset:Hide()
            filterFrame:SetParent(self.FilterList.SortFilterBucket)
            filterFrame.SortDirection:Hide()
            filterFrame.layoutIndex = k

        end

        filterFrame:Show()
        filterFrame:GetParent():MarkDirty()
    end

    local sortDrop = self.FilterList.SortDrop
    sortDrop.Instructions:SetShown(#sortDrop:GetLayoutChildren() == 0)
    sortDrop:MarkDirty()

    local bucket = self.FilterList.SortFilterBucket
    bucket.Instructions:SetShown(#bucket:GetLayoutChildren() == 0)
    bucket:MarkDirty()

end

local activitiesPerRow = 4

function FilterSettings:SetupActivityFilters()
    local isDungeon, isRaid, isDelve = categoryID == 2, categoryID == 3, categoryID == 121

    if(isDungeon or isRaid or isDelve) then
        local orderedGroups = {}
        local done = {}

        --[[
			local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
			local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE));
        ]]

		local baseGroups = C_LFGList.GetAvailableActivityGroups(categoryID, isDungeon and Enum.LFGListFilter.CurrentSeason or Enum.LFGListFilter.CurrentExpansion)

        for index, groupID in ipairs(baseGroups) do
            local groupInfo = miog:GetGroupInfo(groupID)
            tinsert(orderedGroups, {groupID = groupID, abbreviatedName = groupInfo.abbreviatedName, name = groupInfo.name, current = true})
            done[groupID] = true

        end

        if(isDungeon) then
		    local restGroups = C_LFGList.GetAvailableActivityGroups(categoryID, Enum.LFGListFilter.CurrentExpansion)
            for index, groupID in ipairs(restGroups) do
                local groupInfo = miog:GetGroupInfo(groupID)

                if(not done[groupID]) then
                    tinsert(orderedGroups, {groupID = groupID, abbreviatedName = groupInfo.abbreviatedName, name = groupInfo.name, current = false})

                end
            end
        end

        table.sort(orderedGroups, function(k1, k2)
            if(k1.current ~= k2.current) then
                return k1.current

            end
            
            return k1.abbreviatedName < k2.abbreviatedName
        end)

        local baseIndex = 0
        
        for index, groupInfo in ipairs(orderedGroups) do
            local frame = self.ActivitiesFilterFramePool:Acquire()

            frame.Text:SetText(groupInfo.abbreviatedName)
            frame:SetSize(100, 20)

            local rowIndex = ceil(index / activitiesPerRow)
            frame.gridColumn = index - ((rowIndex - 1) * activitiesPerRow)
            frame.gridRow = ceil(index / activitiesPerRow)
            frame.CheckButton:SetScript("OnClick", function(checkBox)
                self:SetMIOGSetting({"groups", groupInfo.groupID}, checkBox:GetChecked())
                    
            end)

            if(groupInfo.current) then
                frame.Text:SetTextColor(WHITE_FONT_COLOR:GetRGBA())

            else
                frame.Text:SetTextColor(GRAY_FONT_COLOR:GetRGBA())

            end

            frame:Show()

            baseIndex = index
        end

        if(isRaid) then
            local restActivities = C_LFGList.GetAvailableActivities(categoryID, 0, 5)

            for index, activityID in ipairs(restActivities) do
                local calcIndex = baseIndex + index
                local activityInfo = miog:GetActivityInfo(activityID)

                local frame = self.ActivitiesFilterFramePool:Acquire()

                frame.Text:SetText(activityInfo.abbreviatedName)
                frame:SetSize(100, 20)

                local rowIndex = ceil(calcIndex / activitiesPerRow)
                frame.gridColumn = calcIndex - ((rowIndex - 1) * activitiesPerRow)
                frame.gridRow = ceil(calcIndex / activitiesPerRow)
                frame.CheckButton:SetScript("OnClick", function(checkBox)
                    self:SetMIOGSetting({"groups", 0}, checkBox:GetChecked())
                        
                end)

                frame:Show()

            end
        end

        self.FilterList.Activities:SetFixedHeight(ceil(#self.FilterList.Activities.Grid:GetLayoutChildren() / 4) * 22 + 26)

        local function IsActivitySelected(id)
            return self:GetMIOGSetting({"difficultyID"}) == id;
        end
        
        local function SetActivitySelected(id)
            self:SetMIOGSetting({"difficultyID"}, id)
        end

        -- Helper function to extract type priority and comparison value
        local function parse_tier(str)
            -- Extract whatever comes after "Tier "
            local tier_val = str:match("Tier%s+(.+)") or str

            local num = tonumber(tier_val)
            if num then
                -- Category 1: Numbers (Weight 1, sorted numerically)
                return 1, num
            elseif tier_val:match("^%?+$") then
                -- Category 2: Question marks (Weight 2, sorted by '?' count)
                return 2, #tier_val
            else
                -- Fallback: Any other unrecognized format
                return 3, tier_val
            end
        end

        -- Custom comparator function for table.sort
        local function sort_tiers(a, b)
            local typeA, valA = parse_tier(a)
            local typeB, valB = parse_tier(b)

            -- If categories differ (Number vs ?), lower weight comes first
            if typeA ~= typeB then
                return typeA < typeB
            end

            -- If in the same category, compare their inner values
            return valA < valB
        end

        self.FilterList.Difficulty.Dropdown:SetupMenu(function(dropdown, rootDescription)
            local difficultyAdded = {}
            local orderedList = {}

            for groupIndex, groupID in ipairs(baseGroups) do
                local groupInfo = miog:GetGroupInfo(groupID)

                table.sort(groupInfo.activities, LFGListUtil_SortActivitiesByRelevancyCB)

                for activityIndex, activityID in ipairs(groupInfo.activities) do
                    local activityInfo = miog:GetActivityInfo(activityID)
                    
                    local shortName = activityInfo and activityInfo.shortName

                    if(not difficultyAdded[shortName]) then
                        tinsert(orderedList, {difficultyID = activityInfo.redirectedDifficultyID, difficultyOrder = miog.BETTER_DIFFICULTY_ORDER[activityInfo.redirectedDifficultyID], shortName = shortName})

                        difficultyAdded[shortName] = true
                    end

                end
            end

            table.sort(orderedList, function(k1, k2)
                if(k1.difficultyOrder ~= k2.difficultyOrder) then
                    return k1.difficultyOrder < k2.difficultyOrder

                end

                return sort_tiers(k1.shortName, k2.shortName)
            end)

            for _, info in ipairs(orderedList) do
                rootDescription:CreateRadio(info.shortName, IsActivitySelected, SetActivitySelected, isDelve and info.shortName or info.difficultyID);

            end
        end)

        self.FilterList.Activities:Show()

    else
        self.FilterList.Activities:Hide()

    end

    self.FilterList.Activities.Grid:MarkDirty()
end

function FilterSettings:Setup(originalFrame)
    categoryID = originalFrame.categoryID

    if(categoryID) then
        self.SortFilterFramePool:ReleaseAll()
        self.ActivitiesFilterFramePool:ReleaseAll()

        key = originalFrame:GetDebugName()

        if(not MIOG_NewSettings.filterOptions[key]) then
            MIOG_NewSettings.filterOptions[key] = {}

        end

        local settings = MIOG_NewSettings.filterOptions[key][categoryID]

        if(not settings) then
            MIOG_NewSettings.filterOptions[key][categoryID] = C_LFGList.GetAdvancedFilter()

            settings = MIOG_NewSettings.filterOptions[key][categoryID]
        end

        self.settings = settings

        self:SetupSortFilters()
        self:SetupActivityFilters()
        
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

--  /tinspect C_LFGList.GetAdvancedFilter()

function FilterSettings:ConvertToBlizzardFilters()
    if(categoryID == 2) then
        local newFilters = {
            needsTank = false,
            needsHealer = false,
            needsDamage = false,
            needsMyClass = false,
            hasTank = false,
            hasHealer = false,

            minimumRating = 0,

            difficultyNormal = false,
            difficultyHeroic = false,
            difficultyMythic = false,
            difficultyMythicPlus = false,

            generalPlaystyle1 = false,
            generalPlaystyle2 = false,
            generalPlaystyle3 = false,
            generalPlaystyle4 = false,
        }

        if(self.settings) then
            if(self.settings.groups) then
                if(self.settings.filterDifficulty) then
                    newFilters.difficultyNormal = self.settings.difficultyID == 1
                    newFilters.difficultyHeroic = self.settings.difficultyID == 2
                    newFilters.difficultyMythic = self.settings.difficultyID == 23
                    newFilters.difficultyMythicPlus = self.settings.difficultyID == 8

                end

                local tbl = {}

                if(self.settings.filterActivities) then
                    for k, v in pairs(self.settings.groups) do
                        if(v) then
                            tbl[#tbl+1] = k

                        end
                    end
                end

                newFilters.activities = tbl
            end
        end

        C_LFGList.SaveAdvancedFilter(newFilters)
    end
end

--    /run MIOG_NewSettings.filterOptions = nil

function FilterSettings:GetMIOGSetting(path)
    local current = self.settings

    for _, id in ipairs(path) do
        if(type(current) ~= "table")then
            return default
        end
        current = current[id]
    end

    if(current == nil)then
        return default
    end

    return current
end

function FilterSettings:SetMIOGSetting(path, value)
    local current = self.settings
    local length = #path

    for i, id in ipairs(path) do
        if(i == length) then
            current[id] = value

        else
            if(type(current[id]) ~= "table") then
                current[id] = {}

            end

            current = current[id]

        end
    end

    self:ConvertToBlizzardFilters()
end

function FilterSettings:OnShow()

end

function FilterSettings:ToggleSortDirection(filterFrame)
    local filterInfo = categoryFilters[categoryID][filterFrame.originalIndex]
    local filterSettings = self:GetSortSetting(filterInfo.id)

    if(filterSettings) then
        local isDescending = filterSettings.state == 1

        if(isDescending) then
            filterFrame.SortDirection.Icon:SetTexCoord(0, 1, 1, 0);

        else
            filterFrame.SortDirection.Icon:SetTexCoord(0, 1, 0, 1);

        end

        self:SetMIOGSetting({"sort", filterInfo.id}, {index = filterSettings.index, state = isDescending and 2 or 1})
        self:ExecuteCallback()
    end
end

function FilterSettings:SetCallback(frameKey, func)
    callbacks[frameKey] = func
    
end

function FilterSettings:GetCallback(frameKey)
    return callbacks[frameKey]
    
end

function FilterSettings:ExecuteCallback()
    local func = self:GetCallback(key)

    if(func) then
        func()

    end
end

function FilterSettings:ClearSortSetting(filterID)
    if(self.settings.sort) then
        self.settings.sort[filterID] = nil

    end

    self:ExecuteCallback()
end

function FilterSettings:GetSortSetting(filterID)
    if(self.settings.sort) then
        return self.settings.sort[filterID]

    end
end

function FilterSettings:RenameSortFilters(filterFrame)
    local sortDrop = self.FilterList.SortDrop

    filterFrame.Index:SetText("")
    filterFrame.Name:SetText(categoryFilters[categoryID][filterFrame.originalIndex].name)

    for k, v in ipairs(sortDrop:GetLayoutChildren()) do
        local filterInfo = categoryFilters[categoryID][v.originalIndex]
        v.layoutIndex = k
        v.Index:SetText(k .. ".")
        v.Name:SetText(filterInfo.name)

        local filterSettings = self:GetSortSetting(filterInfo.id)
        self:SetMIOGSetting({"sort", filterInfo.id}, {index = k, state = filterSettings and filterSettings.state or 1})

    end

    self:ExecuteCallback()
end

function FilterSettings:SetFilter(filterFrame, index)
    local sortDrop = self.FilterList.SortDrop
    local bucket = self.FilterList.SortFilterBucket

    filterFrame:SetParent(sortDrop)
    filterFrame.layoutIndex = index
    filterFrame.Reset:Show()
    filterFrame.SortDirection:Show()

    sortDrop.Instructions:Hide()
    bucket.Instructions:SetShown(#bucket:GetLayoutChildren() == 0)

    sortDrop:MarkDirty()
    bucket:MarkDirty()

    self:RenameSortFilters(filterFrame)
end

function FilterSettings:ResetSortFilter(filterFrame)
    local bucket = self.FilterList.SortFilterBucket
    filterFrame:SetParent(bucket)
    filterFrame.layoutIndex = #bucket:GetLayoutChildren() + 1
    filterFrame.Reset:Hide()
    filterFrame.SortDirection.Icon:SetTexCoord(0, 1, 0, 1)
    filterFrame.SortDirection:Hide()
    bucket.Instructions:Hide()

    local sortDrop = self.FilterList.SortDrop
    sortDrop.Instructions:SetShown(#sortDrop:GetLayoutChildren() == 0)

    local filterInfo = categoryFilters[categoryID][filterFrame.originalIndex]
    self:ClearSortSetting(filterInfo.id)

    self:RenameSortFilters(filterFrame)

    sortDrop:MarkDirty()
    bucket:MarkDirty()

end

function FilterSettings:DragSortFilter(filterFrame)
    filterFrame.DragHighlight:Show()
end

function FilterSettings:DropSortFilter(filterFrame)
    filterFrame.DragHighlight:Hide()

    local sortDrop = self.FilterList.SortDrop
    local bucket = self.FilterList.SortFilterBucket

    local sortIndex = #sortDrop:GetLayoutChildren()

    for k, v in ipairs(sortDrop:GetLayoutChildren()) do
        if(v ~= filterFrame and MouseIsOver(v, 0, 10)) then
            local filterInfo = categoryFilters[categoryID][v.originalIndex]
            local filterSettings = self:GetSortSetting(filterInfo.id)

            self:SetFilter(filterFrame, filterSettings.index - 1)

            return
        end
    end

    if(MouseIsOver(sortDrop) and filterFrame:GetParent() ~= sortDrop) then
        self:SetFilter(filterFrame, sortIndex + 1)

    elseif(MouseIsOver(bucket)) then
        self:ResetSortFilter(filterFrame)

    else
        filterFrame:GetParent():MarkDirty()

    end
end

function FilterSettings:OnLoad()
    self.SortFilterFramePool = CreateFramePool("Frame", self.FilterList.SortFilterBucket, "MIOG_FilterSettingsSortFilterTemplate", function(_, frame) frame.Name:SetText("") frame.layoutIndex = nil frame.originalIndex = nil frame:Hide() end)
    self.ActivitiesFilterFramePool = CreateFramePool("Frame", self.FilterList.Activities.Grid, "MIOG_FilterSettingsActivityFilterTemplate", function(_, frame) frame.Text:SetText("") frame.gridColumn = nil frame.gridRow = nil frame:Hide() end)

    hooksecurefunc("LFGListFrame_SetActivePanel", function(lfgFrame, subFrame)
        self:Setup(subFrame)

    end)

    self.FilterList.Activities.ButtonFrame.Text:SetText("Activities")
    self.FilterList.Activities.ButtonFrame.CheckButton:SetScript("OnClick", function(button)
        self:SetMIOGSetting({"filterActivities"}, button:GetChecked())
    
    end)

    self.FilterList.Difficulty.CheckButton:SetScript("OnClick", function(button)
        self:SetMIOGSetting({"filterDifficulty"}, button:GetChecked())
    
    end)
    self.FilterList.Difficulty.Dropdown:SetSelectionTranslator(function(selection)
        return DifficultyUtil.GetDifficultyName(selection.data)

    end)
    self.FilterList.Difficulty.Dropdown:SetDefaultText("Difficulty...")


    EventRegistry:RegisterCallback("MIOG_DRAG_FILTER", function(_, filterFrame) self:DragSortFilter(filterFrame) end, self);
    EventRegistry:RegisterCallback("MIOG_DROP_FILTER", function(_, filterFrame) self:DropSortFilter(filterFrame) end, self);
    EventRegistry:RegisterCallback("MIOG_RESET_FILTER", function(_, filterFrame) self:ResetSortFilter(filterFrame) end, self);
    EventRegistry:RegisterCallback("MIOG_TOGGLE_SORT_DIRECTION", function(_, filterFrame) self:ToggleSortDirection(filterFrame) end, self);

    miog.FilterSettings = self
end

function FilterSettings:OnEvent(event, ...)

end






FilterSettingsSortFilterMixin = {}

function FilterSettingsSortFilterMixin:OnLoad()

end

function FilterSettingsSortFilterMixin:OnMouseDown()
    self:StartMoving()
    EventRegistry:TriggerEvent("MIOG_DRAG_FILTER", self)
end

function FilterSettingsSortFilterMixin:OnMouseUp()
    self:StopMovingOrSizing()
    EventRegistry:TriggerEvent("MIOG_DROP_FILTER", self)
end







FilterSettingsSortFilterCloseButtonMixin = {}

function FilterSettingsSortFilterCloseButtonMixin:OnClick()
    EventRegistry:TriggerEvent("MIOG_RESET_FILTER", self:GetParent())
end







FilterSettingsSortFilterDirectionButtonMixin = {}

function FilterSettingsSortFilterDirectionButtonMixin:OnClick()
    EventRegistry:TriggerEvent("MIOG_TOGGLE_SORT_DIRECTION", self:GetParent())
end





FilterSettingsActivityFilterMixin = {}

function FilterSettingsActivityFilterMixin:OnLoad()

end



FilterSettingsDropdownMixin = {}

function FilterSettingsDropdownMixin:OnLoad()

end