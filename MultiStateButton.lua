local addonName, miog = ...

--[[ 
    Mixin---------

    Button used for 3 different states, e.g. for sorting a list: no sort, sort descending, sort ascending
    Way easier than implementing it manually all the time 
]]

MultiStateButtonMixin = {}

function MultiStateButtonMixin:OnLoad(numberOfStates)
    self.stateList = {
        [0] = {name = "", key = "off", value = true, singleTexture = false},
    }

    for i = 1, numberOfStates and numberOfStates - 1 or 2, 1 do
        self.stateList[i] = {name = "", key = "state" .. i, value = false, singleTexture = false}

    end

    self.currentState = 0

    self.maxStates = numberOfStates or 3
end

function MultiStateButtonMixin:SetMaxStates(number)
    self.maxStates = number
end

function MultiStateButtonMixin:GetStateList()
    return self.stateList
end

function MultiStateButtonMixin:SetAllTextures(state)
    if(self.stateList[state].singleTexture == true) then
        self:SetNormalTexture(self.stateList[state].textures.normal or "")
        self:SetPushedTexture(self.stateList[state].textures.pushed or "")
        self:SetHighlightTexture(self.stateList[state].textures.highlight or "")
        self:SetDisabledTexture(self.stateList[state].textures.disabled or "")

        if(self.stateList[state].size) then
            self:SetSize(self.stateList[state].size, self.stateList[state].size)

        end

    elseif(self.stateList[state].textures.normal) then
        self:SetNormalAtlas(self.stateList[state].textures.normal or "")
        self:SetPushedAtlas(self.stateList[state].textures.pushed or "")
        self:SetHighlightAtlas(self.stateList[state].textures.highlight or "")
        self:SetDisabledAtlas(self.stateList[state].textures.disabled or "")

        --Implement later, checkbutton states:

        --self:SetCheckedTexture(self.stateList[state].textures.checked or "")
        --self:SetDisabledCheckedTexture(self.stateList[state].textures.disabledChecked or "")
    
    else
        self:ClearNormalTexture()
        self:ClearPushedTexture()
        self:ClearHighlightTexture()
        self:ClearDisabledTexture()

    end
    
end

function MultiStateButtonMixin:GetActiveStateAndValue()
    return self.currentState, self.stateList[self.currentState].value
end

function MultiStateButtonMixin:GetActiveState()
    return self.currentState

end

function MultiStateButtonMixin:GetActiveStateValue()
    return self.stateList[self.currentState].value

end

function MultiStateButtonMixin:GetStateValue(state)
    return self.stateList[state].value

end

function MultiStateButtonMixin:SetState(value, state)
    if(state) then
        if(state == 0) then
            self.stateList[0].value = value
            self.stateList[1].value = false
            self.stateList[2].value = false

        elseif(state == 1) then
            self.stateList[0].value = false
            self.stateList[1].value = value
            self.stateList[2].value = false

        elseif(state == 2) then
            self.stateList[0].value = false
            self.stateList[1].value = false
            self.stateList[2].value = value

        end

        self:SetAllTextures(state)

        self.currentState = state
    else
        if(value ==  true) then
            self.stateList[0].value = false
            self.stateList[1].value = true

            self:SetAllTextures(1)
            self.currentState = 1

        elseif(value ==  false) then
            self.stateList[0].value = true
            self.stateList[1].value = false

            self:SetAllTextures(0)
            self.currentState = 0
        end

    end
end

function MultiStateButtonMixin:SetStateName(state, name)
    self.stateList[state].name = name
end

function MultiStateButtonMixin:GetStateName(state)
    return self.stateList[state].name
end

function MultiStateButtonMixin:AdvanceState()
    self.currentState = self.currentState < (#self.stateList and (self.maxStates - 1)) and self.currentState + 1 or 0

    if(self.currentState == 0) then
        self.stateList[0].value = true
        self.stateList[1].value = false
        self.stateList[2].value = false

    elseif(self.currentState == 1) then
        self.stateList[0].value = false
        self.stateList[1].value = true
        self.stateList[2].value = false

    elseif(self.currentState == 2 and self.stateList[2].textures) then
        self.stateList[0].value = false
        self.stateList[1].value = false
        self.stateList[2].value = true

    elseif(self.currentState == 2 and not self.stateList[2].textures) then
        self.stateList[0].value = true
        self.stateList[1].value = false
        self.stateList[2].value = false
    end

    self:SetAllTextures(self.currentState)

end

function MultiStateButtonMixin:SetTexturesForSpecificState(state, normal, pushed, highlight, disabled, checked, disabledChecked)
    self.stateList[state].textures = {
        normal = normal,
        pushed = pushed,
        highlight = highlight,
        disabled = disabled,
        checked = checked,
        disabledChecked = disabledChecked
    }

end

function MultiStateButtonMixin:SetTexturesForBaseState(normal, pushed, highlight, disabled, checked, disabledChecked)
    self.stateList[0].textures = {
        normal = normal,
        pushed = pushed,
        highlight = highlight,
        disabled = disabled,
        checked = checked,
        disabledChecked = disabledChecked
    }

end

function MultiStateButtonMixin:SetTexturesForState1(normal, pushed, highlight, disabled, checked, disabledChecked)
    self.stateList[1].textures = {
        normal = normal,
        pushed = pushed,
        highlight = highlight,
        disabled = disabled,
        checked = checked,
        disabledChecked = disabledChecked
    }

end

function MultiStateButtonMixin:SetTexturesForState2(normal, pushed, highlight, disabled, checked, disabledChecked)
    self.stateList[2].textures = {
        normal = normal,
        pushed = pushed,
        highlight = highlight,
        disabled = disabled,
        checked = checked,
        disabledChecked = disabledChecked
    }

end

function MultiStateButtonMixin:SetSingleTextureForSpecificState(state, texture, size)
    self.stateList[state].singleTexture = true
    self.stateList[state].textures = {
        normal = texture,
        pushed = texture,
        highlight = texture,
        disabled = texture,
        checked = texture,
        disabledChecked = texture
    }

    if(size) then
        self.stateList[state].size = size

    end
end