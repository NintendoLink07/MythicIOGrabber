SimplifiedSortingMixin = CreateFromMixins(CallbackRegistryMixin)

local numOfActiveButtons = 0

function SimplifiedSortingMixin:SetHeight(height, padding)
    self:SetHeight(height)

    local buttonHeight = padding and height - padding or height - 2

    for _, v in ipairs(self.sortButtons) do
        v:SetHeight(buttonHeight)

    end
end

function SimplifiedSortingMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self)
    self.states = {activeButtons = {}, buttons = {}}

    for k, v in ipairs(self.sortButtons) do
        v:RegisterCallback("OnSortingButtonClick", self.SortClick, self)
        v:SetHeight(24)

    end
    
end

function SimplifiedSortingMixin:Reset()
    self.dataProvider = nil
    self:OnLoad()
end

function SimplifiedSortingMixin:SetSortButtonTexts(...)
    local texts = {...}

    local index = 1

    for _, v in ipairs(self.sortButtons) do
        local currentText = texts[index]

        if(v:GetName() and currentText ~= nil) then
            v:SetText(currentText)
            v:Enable()
            
            index = index + 1
        else
            v:SetText("")
            v:Disable()

        end
    end
end



-- sort on insert //bad behavior when leader
-- sorts with no comparator on insert // for some reason



local function normalComparator(k1, k2, buttons, fallbackParameter)
    for i = 1, numOfActiveButtons do
        local button = buttons[i]
        local sortID = button.id
        local state = button.state

        -- Check the current sort field
        if (k1[sortID] ~= k2[sortID]) then
            -- Early return on the first difference found (fastest path)
            if (state == 1) then -- State 1: Ascending
                return k1[sortID] > k2[sortID]
            else -- State 2: Descending
                return k1[sortID] < k2[sortID]
            end
        end
        
        -- If k1[sortID] == k2[sortID], the loop continues to the next sort field.
    end
    
    -- Fallback Sort (Executed ONLY if ALL active sort fields were equal)
    -- This guarantees a deterministic sort based on the required fallback parameter.

    return k1[fallbackParameter] < k2[fallbackParameter]

end

local function nodeComparator(node1, node2, buttons, fallbackParameter)
    local k1 = node1.data
    local k2 = node2.data

    return normalComparator(k1, k2, buttons, fallbackParameter)
end

function SimplifiedSortingMixin:SetComparator()
    local fallbackParameter = self.fallbackParameter

    if(self.dataProvider) then
        local buttons = {}

        if(self.dataProvider.node) then
            for i = 1, numOfActiveButtons do
                local activeButton = self.states.activeButtons[i]

                buttons[i] = {id = activeButton.id, state = activeButton.state}

            end

            self.dataProvider:SetSortComparator(function(node1, node2)
                return nodeComparator(node1, node2, buttons, fallbackParameter)

            end, true)
        else
            self.dataProvider:SetSortComparator(function(k1, k2)
                return normalComparator(k1, k2, buttons, fallbackParameter)

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

    if(not self.dataProvider.node) then
        self:SetComparator()

    end
end

function SimplifiedSortingMixin:Sort()
    if(self.dataProvider) then
        numOfActiveButtons = #self.states.activeButtons

        if(self.dataProvider.node) then
            self:SetComparator()
            self.dataProvider:Invalidate()

        else
            self.dataProvider:Sort()

        end
    end
end

function SimplifiedSortingMixin:SortClick(...)
    local button = ...

    local active, state = button:GetStatus()

    if(self.dataProvider) then
        local id = button:GetID()

		if(id) then
			if(active and state == 1) then
				tinsert(self.states.activeButtons, {button = button, id = id, state = state})

            elseif(active and state == 2) then
                for k, v in ipairs(self.states.activeButtons) do
                    if(v.id == id) then
                        self.states.activeButtons[k].state = state

                    end
                end

            elseif(not active) then
                for k, v in ipairs(self.states.activeButtons) do
                    if(v.id == id) then
                        tremove(self.states.activeButtons, k)

                    end
                end
			end
		end

        self:Sort()
    end
end