SimplifiedSortingMixin = CreateFromMixins(CallbackRegistryMixin)

function SimplifiedSortingMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self)
    self.states = {activeButtons = {}, buttons = {}}

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
    local fallbackParameter = self.fallbackParameter

    if(self.dataProvider) then
        if(self.dataProvider.node) then
            self.dataProvider:SetSortComparator(function(node1, node2)
                local k1 = node1.data
                local k2 = node2.data

                local numOfActiveButtons = #self.states.activeButtons

                for i = 1, numOfActiveButtons do
                    local button = self.states.activeButtons[i]
                    local sortID = button:GetID()
                    local _, state = button:GetStatus()

                    if(k1[sortID] ~= k2[sortID]) then
                        if(state == 1) then
                            return k1[sortID] < k2[sortID]

                        else
                            return k1[sortID] > k2[sortID]

                        end
                    elseif(i == numOfActiveButtons) then --can lead to errors if no fallback array value is available
                        if(state == 1) then
                            return k1[fallbackParameter] < k2[fallbackParameter]

                        else
                            return k1[fallbackParameter] > k2[fallbackParameter]

                        end
                    end
                end
            end, true)
        else
            self.dataProvider:SetSortComparator(function(k1, k2)
                local numOfActiveButtons = #self.states.activeButtons

                for i = 1, numOfActiveButtons do
                    local button = self.states.activeButtons[i]
                    local sortID = button:GetID()
                    local _, state = button:GetStatus()

                    if(k1[sortID] ~= k2[sortID]) then
                        if(state == 1) then
                            return k1[sortID] < k2[sortID]

                        else
                            return k1[sortID] > k2[sortID]

                        end

                    elseif(i == numOfActiveButtons) then --can lead to errors if no fallback array value is available
                        if(state == 1) then
                            return k1[fallbackParameter] < k2[fallbackParameter]

                        else
                            return k1[fallbackParameter] > k2[fallbackParameter]

                        end
                    end
                end
            end)
        end
    end
end

function SimplifiedSortingMixin:RegisterDataProvider(dataProvider, fallbackParameter)
    if(not fallbackParameter) then
		error("RegisterDataProvider() fallbackParameter was nil. A fallback parameter is required.");

    end

    self.dataProvider = dataProvider
    self.fallbackParameter = fallbackParameter

    self:SetAndExecuteComparator()
end

function SimplifiedSortingMixin:Sort(...)
    local button = ...

    local active = button:GetStatus()

    if(self.dataProvider) then
        local id = button:GetID()

		if(id) then
			if(active) then
				tinsert(self.states.activeButtons, button)
			    self.states.buttons[id] = {order = #self.states.activeButtons + 1}

			else
				for index, activeButton in ipairs(self.states.activeButtons) do
					if(activeButton:GetID() == id) then
						self.states.activeButtons[index] = nil

					end
				end
			end
		end

        self:SetAndExecuteComparator()
        self.dataProvider:Invalidate()
    end
end