local currentDropdown

SlickerDropdownMixin = {}

function SlickerDropdownMixin:OnShow()
    if(self.List) then
        if(not self.arrow) then
            self:CreateSubmenuArrow()

        end

        self.arrow:SetShown(#self.List:GetLayoutChildren() > 0)
    end

    if(self.data and self.data.selectedFunc) then
        local firstType = self.checkbox2 or self.radio2

        if(firstType) then
            firstType:SetShown(self.data.selectedFunc(self.data.value))

        end
    end
end

function SlickerDropdownMixin:OnLoad()
    --self.provider = CreateDataProvider()
    
    self:CreateFactory()
end

function SlickerDropdownMixin:CreateFactory()
    self.List.frameFactories = self.List.frameFactories or CreateFramePoolCollection()
    self.List.buttonFactory = self.List.buttonFactory or self.List.frameFactories:GetOrCreatePool("Button", self.List, "HorizontalLayoutFrame, MIOG_SlickerDropdownBaseTemplate", function(pool, frame)
        frame:Hide()
        frame.layoutIndex = nil
        frame.currentDropdown = nil
        frame.data = nil
        frame:ReleaseAllChildren()
    end)

	self.fontstringFactory = self.fontstringFactory or CreateFontStringPool(self, "OVERLAY", nil, "SystemFont_Shadow_Med1", function(pool, fontstring)
    end)

	self.textureFactory = self.textureFactory or CreateTexturePool(self, "ARTWORK", nil, nil, function(pool, texture)
    end)
end

function SlickerDropdownMixin:ReleaseAllChildren()
    self.List.frameFactories:ReleaseAll()
    self.List.buttonFactory:ReleaseAll()

    self.fontstringFactory:ReleaseAll()
    self.textureFactory:ReleaseAll()

end

function SlickerDropdownMixin:Reset()
    self:ReleaseAllChildren()
    --self.provider = CreateDataProvider()
end

function SlickerDropdownMixin:AddChildFrame(data)
    local frame = self.List.buttonFactory:Acquire()
    frame:SetToListOnlyMode()
    frame.layoutIndex = self.List.buttonFactory:GetNumActive() + 1
    frame.data = data

    if(data.func) then
        frame:SetScript("OnClick", function(localSelf)
            data.func(data.value)

            if(localSelf.data.type ~= "checkbox") then
                currentDropdown.List:Hide()

            end
        end)
    end
    
    if(data.type == "radio") then
        frame:AttachRadioTexture()

    end

    if(data.type == "checkbox") then
        frame:AttachCheckboxTexture()
        -- ATTACH FRAME POST CLICK
    end

    if(data.text) then
        frame:AttachText(data.text)

    end

    frame:Show()

    self.List:MarkDirty()

    return frame
end

function SlickerDropdownMixin:RefreshMenu()
    self:ReleaseAllChildren()

    local child
    
    self.generator(self)

    self.List:MarkDirty()

    return child
end

function SlickerDropdownMixin:CreateDivider(index)
    local divider = self.textureFactory:Acquire()
    divider.layoutIndex = index or self.textureFactory:GetNumActive() + 1
	divider:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent");
    divider.expand = true
	divider:SetHeight(13);

	return divider
end

function SlickerDropdownMixin:CreateTitle(text)
    --[[local title = self.List.fontstringFactory:Acquire()
    title.layoutIndex = index or self.List.fontstringFactory:GetNumActive() + 1

    title:SetHeight(self:GetHeight())
    title:SetText(text)

	return title;]]
end

function SlickerDropdownMixin:CreateSpacer(index)
    --[[local spacer = self.List.frameFactories:GetOrCreatePool("Frame", self.List, "BackdropTemplate", function(pool, frame) end):Acquire()
    spacer.layoutIndex = index or #self.List:GetChildren() + 1

	spacer:SetHeight(10);

	return spacer]]
end

function SlickerDropdownMixin:CreateTemplate(template, type)
    local pool = self.List.frameFactories:GetOrCreatePool(type, self.List, type == "Frame" and template or (template .. ", MIOG_SlickerDropdownBaseTemplate"), function(pool, frame)
        frame:Hide()
        frame.layoutIndex = nil
        frame.currentDropdown = nil
        frame.data = nil
    end)
    
    local frame = pool:Acquire()
    frame:SetParentKey("SPECI")
    frame:SetSize(300, 25)
    frame.layoutIndex = self.List.buttonFactory:GetNumActive() + 1
    frame:Show()

    return frame
end

function SlickerDropdownMixin:CreateFrame()
    local pool = self.List.frameFactories:GetOrCreatePool("Frame", self.List, "BackdropTemplate, MIOG_SlickerDropdownBaseTemplate", function(pool, frame)
        frame:Hide()
        frame.layoutIndex = nil
        frame.currentDropdown = nil
        frame.data = nil
    end)
    
    local frame = pool:Acquire()
    frame.layoutIndex = pool:GetNumActive() + 1
    frame.data = {
        type = "custom",
        id = pool:GetNumActive() + 1,
    }

    frame:Show()

    return frame
end

function SlickerDropdownMixin:CreateButton(text, func)
    local id = #self.List:GetLayoutChildren() + 1
    local data = {
        type = "button",
        id = id,
        text = text,
        func = func,
    }

    local frame = self:AddChildFrame(data)

    return frame
end

function SlickerDropdownMixin:CreateRadio(text, selectedFunc, func, value)
    local id = #self.List:GetLayoutChildren() + 1

    local data = {
        type = "radio",
        id = id,
        text = text,
        func = func,
        selectedFunc = selectedFunc,
        parent = self,
        value = value,
    }

    local frame = self:AddChildFrame(data)

    return frame
end

function SlickerDropdownMixin:CreateCheckbox(text, selectedFunc, func, value)
    local id = #self.List:GetLayoutChildren() + 1

    local data = {
        type = "checkbox",
        id = id,
        text = text,
        func = func,
        selectedFunc = selectedFunc,
        value = value,
    }

    local frame = self:AddChildFrame(data)

    return frame
end

function SlickerDropdownMixin:CreateSubmenuArrow(texture)
    self.arrow = self.arrow or self:CreateTexture("Arrow", "ARTWORK")
    self.arrow:SetPoint("RIGHT", self, "RIGHT", -5, 0)
    self.arrow:SetTexture(texture or "Interface\\ChatFrame\\ChatFrameExpandArrow")

    return self.arrow
end

function SlickerDropdownMixin:AddInitializer(func)
    func(self)
end

function SlickerDropdownMixin:SetToDropdownMode()
    self.List:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    self.List:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")

    self:ClearHighlightTexture()
    self:SetDefaultText("Select an activity...")

    self:SetScript("OnClick", function(localSelf)
        local isListShown = localSelf.List:IsShown()

        if(not isListShown and self.generator) then
            self:RefreshMenu()

        end

        localSelf.List:SetShown(not isListShown)

        currentDropdown = localSelf
    end)
end

function SlickerDropdownMixin:SetToListOnlyMode()
    self:AddMotionScripts()
    self.spacing = 3

    self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 6)
    self:SetFixedWidth(200)
end

function SlickerDropdownMixin:SetGenerator(generator)
    self:ReleaseAllChildren()
    self.generator = generator
end


function SlickerDropdownMixin:AddMotionScripts()
    self:SetScript("OnEnter", function(localSelf)
        if(localSelf:GetParent().activeList) then
            localSelf:GetParent().activeList:Hide()

        end

        if(self.List.buttonFactory:GetNumActive() > 0 or localSelf.data.text == PLAYER_V_PLAYER) then
            localSelf.List:Show()
            localSelf:GetParent().activeList = localSelf.List

        end
    end)

    self:SetScript("OnLeave", function(localSelf)

    end)
end

function SlickerDropdownMixin:AttachText(text)
    self.fontString = self.fontString or self.fontstringFactory:Acquire()

    self.fontString:SetParent(self)
    self.fontString:SetText(text)
    self.fontString:SetJustifyV("MIDDLE")

    self.fontString.layoutIndex = 5
    self.fontString.align = "center"
    self.fontString.leftPadding = 1

    self.fontString:Show()
    
    self:MarkDirty()

    return self.fontString
end

function SlickerDropdownMixin:AttachTexture(file, name, isAtlas)
    local height = self:GetHeight() - 4

    name = name or "icon"

    self[name] = self[name] or self.textureFactory:Acquire()
    self[name]:SetParent(self)

    if(isAtlas) then
        self[name]:SetAtlas(file)
        
    else
        self[name]:SetTexture(file)

    end

    self[name]:SetSize(height, height)

    self[name].layoutIndex = 2
    self[name].align = "center"
    
    self:MarkDirty()

    return self[name]
end

function SlickerDropdownMixin:AttachRadioTexture(texture1, texture2)
    local height = self:GetHeight() - 2

    local radio = self:AttachTexture(texture1 or "common-dropdown-tickradial", "radio", true)
    radio:SetSize(height - 2, height)
    radio.layoutIndex = 1

    local radio2 = self:AttachTexture(texture2 or "common-dropdown-icon-radialtick-yellow", "radio2", true)
    radio2:SetSize(height - 2, height)
    radio2.ignoreInLayout = true
    radio2:SetAllPoints(radio)

    return radio
end

function SlickerDropdownMixin:AttachCheckboxTexture(texture1, texture2)
    local height = self:GetHeight() - 6

    local checkbox = self:AttachTexture(texture1 or "common-dropdown-ticksquare", "checkbox", true)
    checkbox:SetSize(height - 1, height)
    checkbox.layoutIndex = 1
    checkbox.leftPadding = 2
    checkbox.rightPadding = 2

    local checkbox2 = self:AttachTexture(texture2 or "common-dropdown-icon-checkmark-yellow", "checkbox2", true)
    checkbox2:SetSize(height - 1, height)
    checkbox2.layoutIndex = nil
    checkbox2.ignoreInLayout = true
    checkbox2:SetAllPoints(checkbox)

    return checkbox
end