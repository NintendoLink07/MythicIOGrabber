local addonName, miog = ...

SortingMixin = {}

--[[
    parameter

    name
    state -- 0 - n; 1 - n == active
]]

local buttonPool

function SortingMixin:OnLoad(func)
    self.sortingParameters = {}
    self.sortingData = {}
    self.expandedChildren = {}

    buttonPool = CreateFramePool("Button", self.SortButtonRow, "MIOG_SortButtonTemplate", function(pool, frame)
        frame:SetScript("OnClick", function(frameSelf, button)
            if(button == "LeftButton") then
                self:AdvanceParameterState(frameSelf.parameter.index)
                frameSelf:AdvanceState()

            else
                self:SetParameterState(frameSelf.parameter.index, false)
                frameSelf:SetState(false)

            end

            if(self.scrollView) then
                self:Sort()
            end

            if(func) then
                func(true)
            end
        end)
    end)
end

function SortingMixin:SetSettingsTable(table)
    if(not table) then
        table = {}

    end

    self.settingsTable = table
end

function SortingMixin:SetScrollView(scrollView)
    self.scrollView = scrollView
end

function SortingMixin:SetPostCallback(func)
    for widget in buttonPool:EnumerateActive() do
        widget:SetScript("PostClick", function()
            func(true)
        end)
        
    end
end

function SortingMixin:CreateButtonsForParameters()
    buttonPool:ReleaseAll()

    for k, v in ipairs(self.sortingParameters) do
        local button = buttonPool:Acquire()

        button.leftPadding = v.padding or 0
        button.parameter = v
        button.layoutIndex = k

        v.button = button

        if(v.state > 0) then
            self:SetParameterState(k, v.state)
            button:SetState(true, v.state)

        end
    end

    self.SortButtonRow:MarkDirty()
end

function SortingMixin:PrintAllSortingParameters()
    for index, parameter in ipairs(self.sortingParameters) do
        print(index, parameter.name)
    end
end

function SortingMixin:GetSortingParameters()
    return self.sortingParameters
end

function SortingMixin:AddSingleSortingParameter(parameter, noCreation)
    --table.insert(self.sortingParameters, {name = parameter, state = 0, index = #self.sortingParameters})

    local index = #self.sortingParameters + 1

    if(self.settingsTable[parameter.name] and not self.settingsTable[parameter.name].currentState) then
        self.sortingParameters[index] = self.settingsTable[parameter.name]
        self.sortingParameters[index].padding = parameter.padding
    else
        self.sortingParameters[index] = {name = parameter.name, padding = parameter.padding, state = 0, index = index}

    end

    if(not noCreation) then
        self:CreateButtonsForParameters()
    end
end

function SortingMixin:AddMultipleSortingParameters(parameterTable)
    for index, parameter in ipairs(parameterTable) do
        self:AddSingleSortingParameter(parameter, true)

    end

    self:CreateButtonsForParameters()
end

function SortingMixin:UpdateSortingData(table)
    self.sortingData = table
end

function SortingMixin:GetSortingData()
    return self.sortingData
end

function SortingMixin:SetSortingFunction(func)
    self.sortingFunction = func
end

function SortingMixin:GetParameterInfo(parameter)
    if(type(parameter) == "string") then
        for k, v in ipairs(self.sortingParameters) do
            if(v.name == parameter) then
                return self.sortingParameters[k]
            end
        end

    elseif(type(parameter) == "number" and self.sortingParameters[parameter]) then
        return self.sortingParameters[parameter]

    end
end

function SortingMixin:CheckOrderStatus(parameterInfo)
    local hasBeenDeactivated = parameterInfo.state == 0

    if(hasBeenDeactivated) then
        local oldOrder = parameterInfo.order

        parameterInfo.order = nil
        parameterInfo.button.FontString:SetText(parameterInfo.order)

        for k, v in ipairs(self.sortingParameters) do
            if(v.order and v.order > oldOrder) then
                v.order = v.order - 1
                v.button.FontString:SetText(v.order)
            end
        end
    else
        parameterInfo.order = not parameterInfo.order and self:GetNumOfActiveSortMethods() or parameterInfo.order
        parameterInfo.button.FontString:SetText(parameterInfo.order)

    end

    self.settingsTable[parameterInfo.name] = {
        name = parameterInfo.name,
        order = parameterInfo.order,
        index = parameterInfo.index,
        state = parameterInfo.state,
        padding = parameterInfo.padding,
    }
end

function SortingMixin:SetParameterState(parameter, state)
    local parameterInfo = self:GetParameterInfo(parameter)

    if(parameterInfo) then
        parameterInfo.state = state == false and 0 or state == true and 1 or state

        self:CheckOrderStatus(parameterInfo)
    end
end

function SortingMixin:AdvanceParameterState(parameter)
    local parameterInfo = self:GetParameterInfo(parameter)

    if(parameterInfo) then
        if(parameterInfo.state == 0 or parameterInfo.state == 1) then
            parameterInfo.state = parameterInfo.state + 1

        else
            parameterInfo.state = 0

        end

        self:CheckOrderStatus(parameterInfo)

    end
end

function SortingMixin:SetExpandedChild(id, isCollapsed)
    self.expandedChildren[id] = isCollapsed

end

function SortingMixin:ActivateParameter(parameter)
    local parameterInfo = self:GetParameterInfo(parameter)
    
    if(parameterInfo) then
        self:SetParameterState(parameter, 1)
        return true
    end

    return false
end

function SortingMixin:ActivateParameters(parameterTable)
    for k, v in ipairs(parameterTable) do
        self:ActivateParameter(v)

    end
end

function SortingMixin:GetNumOfActiveSortMethods()
    local number = 0

    for k, v in ipairs(self.sortingParameters) do
        if(v.state > 0) then
            number = number + 1
        end
    end

    return number
end

function SortingMixin:SortBy()
    
end

function SortingMixin:SetCallback(func)
    self.func = func
end

function SortingMixin:GetOrderedParameters()
    local orderedList = {}

    for k, v in ipairs(self.sortingParameters) do
        if(v.order) then
            orderedList[v.order] = v

        end
    end

    return #orderedList > 0 and orderedList or self.sortingParameters
end

function SortingMixin:Sort()
    if(self.sortingFunction) then
        table.sort(self.sortingData, function(k1, k2)
            self.sortingFunction(k1, k2)
        end)
    else
        local orderedList = self:GetOrderedParameters()

        table.sort(self.sortingData, function(k1, k2)
            for k, v in ipairs(orderedList) do
                if(v.state > 0 and k1[v.name] ~= k2[v.name]) then
                    if(v.state == 1) then
                        return k1[v.name] > k2[v.name]

                    else
                        return k1[v.name] < k2[v.name]

                    end
                end
            end
        end)
        
        if(self.scrollView) then
            local dataProvider = CreateTreeDataProvider()

            for _, member in ipairs(self.sortingData) do
                member.template = "MIOG_PartyCheckPlayerTemplate"
                local baseFrameData = dataProvider:Insert(member)

                baseFrameData:Insert({
                    template = "MIOG_NewRaiderIOInfoPanel",
                    name = member.name,
                    classFileName = member.classFileName
                    
                })

            end

            self.scrollView:SetDataProvider(dataProvider)

            for k, v in pairs(dataProvider:GetChildrenNodes()) do
                if(v.data.collapsed == false) then
                    v:SetCollapsed(v.data.collapsed)

                else
                    v:SetCollapsed(true)

                end
            end
        end
    end
end