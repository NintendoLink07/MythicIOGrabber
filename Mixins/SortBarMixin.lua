SortBarMixin = {}

--[[
    parameter

    name
    state -- 0 - n; 1 - n == active
]]

local buttonPool

function SortBarMixin:OnLoad(func, parameters)
    self.sortingParameters = {}

    buttonPool = CreateFramePool("Button", self.SortButtonRow, "MIOG_SortButtonTemplate", function(pool, frame)
        frame:SetScript("OnClick", function(frameSelf, button)
            if(button == "LeftButton") then
                self:AdvanceParameterState(frameSelf.parameter.index)
                frameSelf:AdvanceState()

            else
                self:SetParameterState(frameSelf.parameter.index, false)
                frameSelf:SetState(false)

            end

            if(func) then
                func()

            end
        end)
    end)
end

function SortBarMixin:SetSettingsTable(table)
    if(not table) then
        table = {}

    end

    self.settingsTable = table
end

function SortBarMixin:SetPostCallback(func)
    for widget in buttonPool:EnumerateActive() do
        widget:SetScript("PostClick", function()
            func(true)
        end)
        
    end
end

function SortBarMixin:CreateButtonsForParameters()
    buttonPool:ReleaseAll()

    for k, v in ipairs(self.sortingParameters) do
        local button = buttonPool:Acquire()

        button.leftPadding = v.padding or 0
        button.parameter = v
        button.layoutIndex = k

        button.tooltipTitle = v.tooltipTitle

        v.button = button

        if(v.state > 0) then
            self:SetParameterState(k, v.state)
            button:SetState(true, v.state)

        end
    end

    self.SortButtonRow:MarkDirty()
end

function SortBarMixin:PrintAllSortingParameters()
    for index, parameter in ipairs(self.sortingParameters) do
        print(index, parameter.name)
    end
end

function SortBarMixin:GetSortingParameters()
    return self.sortingParameters
end

function SortBarMixin:AddSingleSortingParameter(parameter, noCreation)
    local index = #self.sortingParameters + 1

    if(self.settingsTable[parameter.name] and not self.settingsTable[parameter.name].currentState) then
        self.sortingParameters[index] = self.settingsTable[parameter.name]
        self.sortingParameters[index].padding = parameter.padding
        self.sortingParameters[index].tooltipTitle = parameter.tooltipTitle
    else
        self.sortingParameters[index] = {name = parameter.name, padding = parameter.padding, state = 0, index = index, tooltipTitle = parameter.tooltipTitle}

    end

    if(not noCreation) then
        self:CreateButtonsForParameters()
    end
end

function SortBarMixin:AddMultipleSortingParameters(parameterTable)
    for index, parameter in ipairs(parameterTable) do
        self:AddSingleSortingParameter(parameter, true)

    end

    self:CreateButtonsForParameters()
end

function SortBarMixin:GetParameterInfo(parameter)
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

function SortBarMixin:CheckOrderStatus(parameterInfo)
    local hasBeenDeactivated = parameterInfo.state == 0

    if(hasBeenDeactivated) then
        local oldOrder = parameterInfo.order

        parameterInfo.order = nil
        parameterInfo.button.FontString:SetText(parameterInfo.order)

        for _, v in ipairs(self.sortingParameters) do
            if(v.order and v.order > oldOrder) then
                v.order = v.order - 1
                v.button.FontString:SetText(v.order)

                self.settingsTable[v.name].order = v.order
            end
        end
    else
        parameterInfo.order = parameterInfo.order or self:GetNumOfActiveSortMethods()
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

function SortBarMixin:SetParameterState(parameter, state)
    local parameterInfo = self:GetParameterInfo(parameter)

    if(parameterInfo) then
        parameterInfo.state = state == false and 0 or state == true and 1 or state

        self:CheckOrderStatus(parameterInfo)
    end
end

function SortBarMixin:AdvanceParameterState(parameter)
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

function SortBarMixin:ActivateParameter(parameter)
    local parameterInfo = self:GetParameterInfo(parameter)
    
    if(parameterInfo) then
        self:SetParameterState(parameter, 1)
        return true
    end

    return false
end

function SortBarMixin:ActivateParameters(parameterTable)
    for k, v in ipairs(parameterTable) do
        self:ActivateParameter(v)

    end
end

function SortBarMixin:GetNumOfActiveSortMethods()
    local number = 0

    for k, v in ipairs(self.sortingParameters) do
        if(v.state > 0) then
            number = number + 1
        end
    end

    return number
end

function SortBarMixin:SetCallback(func)
    self.func = func
end

function SortBarMixin:GetOrderedParameters()
    local orderedList = {}

    for k, v in ipairs(self.sortingParameters) do
        if(v.order) then
            orderedList[v.order] = v

        end
    end

    return #orderedList > 0 and orderedList or self.sortingParameters
end