SimplifiedSortingMixin = CreateFromMixins(CallbackRegistryMixin)

function SimplifiedSortingMixin:SetButtonTemplate(template)
    self.buttonTemplate = template
end

function SimplifiedSortingMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self)
    self.states = {activeButtons = {}, buttons = {}}

    self:SetButtonTemplate("MIOG_SimplifiedHeaderTemplate")

    for k, v in ipairs(self.sortButtons) do
        self.states.buttons[v:GetName()] = {}
	    v:RegisterCallback("OnSortingButtonClick", self.Sort, self)
    end

end

function SimplifiedSortingMixin:Reset()
    self.dataProvider = nil
    self:OnLoad()
end

function SimplifiedSortingMixin:StandardSortFunction(k1, k2)
    

    --[[for i = 1, orderedListLen do
        local state, name = sortBarList[i].state, sortBarList[i].name

        if(state > 0 and k1[name] ~= k2[name]) then
            if(state == 1) then
                return k1[name] > k2[name]

            else
                return k1[name] < k2[name]

            end

        elseif(i == orderedListLen) then
            return k1.index > k2.index

        end
    end]]
end

function SimplifiedSortingMixin:SetAndExecuteComparator()
    if(self.dataProvider) then
        if(self.dataProvider.CollapseAll) then
            self.dataProvider:SetSortComparator(function(node1, node2)
                local k1 = node1.data
                local k2 = node2.data

                local numOfActiveButtons = #self.states.activeButtons
                for i = 1, numOfActiveButtons do
                    local sortID = self.states.activeButtons[i]

                    if(k1[sortID] ~= k2[sortID]) then
                        return k1[sortID] < k2[sortID]

                    elseif(i == numOfActiveButtons) then --can lead to errors if no fallback array value is available
                        return k1.applicantID < k2.applicantID

                    end

                end
            end, false)
        else
            self.dataProvider:SetSortComparator(function(k1, k2)
                local numOfActiveButtons = #self.states.activeButtons
                for i = 1, numOfActiveButtons do
                    local sortID = self.states.activeButtons[i]
                    
                    if(k1[sortID] ~= k2[sortID]) then
                        return k1[sortID] > k2[sortID]

                    elseif(i == numOfActiveButtons) then
                        return k1.index > k2.index

                    end

                end
            end)
        end
    end
end

function SimplifiedSortingMixin:RegisterDataProvider(dataProvider)
    self.dataProvider = dataProvider

    self:SetAndExecuteComparator()
end

function SimplifiedSortingMixin:Sort(...)
    local sortID, isChecked = ...

    if(isChecked) then
        tinsert(self.states.activeButtons, sortID)

    else
        for index, activeButtonName in ipairs(self.states.activeButtons) do
            if(activeButtonName == sortID) then
                self.states.activeButtons[index] = nil

            end
        end
    end
    
    self.states.buttons[sortID] = {active = isChecked, order = nil}

    if(self.dataProvider) then
        self:SetAndExecuteComparator()

        DevTools_Dump(self.dataProvider)

        for k, v in self.dataProvider:Enumerate(nil, nil, false) do
            print(k, v:GetData().itemLevel)

        end
    end
end