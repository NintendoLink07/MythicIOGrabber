NewMultiStateButtonMixin = {}

function NewMultiStateButtonMixin:OnLoad(type, baseState, maxStates)
    self.type = type
    self.baseState = baseState or 1
    self.currentState = self.baseState
    self.maxStates = maxStates or 3
    self.colorTable = {
        [1] = {0, 0, 0, 0},
        [2] = {0, 1, 0, 1},
        [3] = {1, 0, 0, 1},
    }
end

function NewMultiStateButtonMixin:SetColors(colorTable)
    self.colorTable = {}

    for i = 1, self.maxStates, 1 do
        self.colorTable[i] = colorTable[i]

    end
end

function NewMultiStateButtonMixin:SetState(state)
    if(state >= self.baseState and state <= self.maxStates) then
        self.currentState = state

        local r, g, b, a = unpack(self.colorTable[self.currentState])
        self.Border:SetColorTexture(r, g, b, a)
    end

    if(self.currentState == self.maxStates) then
        self.Icon:SetDesaturated(true)

    else
        self.Icon:SetDesaturated(false)

    end
end

function NewMultiStateButtonMixin:AdvanceState()
    self.currentState = self.currentState == self.maxStates and 1 or self.currentState + 1

    if(self.type == "color") then
        local r, g, b, a = unpack(self.colorTable[self.currentState])
        self.Border:SetColorTexture(r, g, b, a)

        if(self.currentState == self.maxStates) then
            self.Icon:SetDesaturated(true)

        else
            self.Icon:SetDesaturated(false)

        end

    end
end