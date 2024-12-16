local baseTemplate = "UIButtonTemplate"

SlickerDropdownBaseMixin = {}

function SlickerDropdownBaseMixin:OnLoad(buttonTemplate)
    self:SetButtonTemplate(buttonTemplate)

    self.provider = CreateDataProvider()
    
    self:CreateFactory()

    self:Init()
end

function SlickerDropdownBaseMixin:CreateFactory()
    self.frameFactories = self.frameFactories or CreateFramePoolCollection()

	self.titleFontStringFactory = self.titleFontStringFactory or CreateFontStringPool(self.List, "OVERLAY", nil, "SystemFont_Shadow_Med1", function(pool, fontstring) end)
	self.titleTextureFactory = self.titleTextureFactory or CreateTexturePool(self.List, "ARTWORK", nil, nil, function(pool, texture) end)

    self.buttonFactory = self.buttonFactory or self.frameFactories:GetOrCreatePool("Button", self.List, "MIOG_SlickerDropdownChildTemplate", function(pool, frame) end)
	self.fontstringFactory = self.fontstringFactory or CreateFontStringPool(self.List, "OVERLAY", nil, "SystemFont_Shadow_Med1", function(pool, fontstring) end)
	self.textureFactory = self.textureFactory or CreateTexturePool(self.List, "ARTWORK", nil, nil, function(pool, texture) end)
end

function SlickerDropdownBaseMixin:RefreshMenu(id)
    self.frameFactories:ReleaseAll()

    self.fontstringFactory:ReleaseAll()
    self.textureFactory:ReleaseAll()

    self.buttonFactory:ReleaseAll()

    local child
    
    for k, v in self.provider:Enumerate() do
        local frame = self.buttonFactory:Acquire()
        frame.layoutIndex = k

        if(v.type == "radio") then
            frame:AttachRadioTexture()

        end

        if(v.type == "checkbox") then
            frame:AttachCheckboxTexture()

        end

        if(v.text) then
            frame:AttachText(v.text)

        end
        
        if(id and v.id == id) then
            child = frame
        end
    end

    self.List:MarkDirty()
    
    if(self.buttonFactory:GetNumActive() > 0) then
        self:CreateSubmenuArrow()
    end

    return child
end

function SlickerDropdownBaseMixin:SetButtonTemplate(template)
    self.buttonTemplate = template or baseTemplate

    if(self.buttonFactory) then
        self.buttonFactory:ReleaseAll()

    end

    self:CreateFactory()
end

function SlickerDropdownBaseMixin:CreateButton(text, func)
    local id = self.List:GetSize() + 1

    self.provider:Insert({
        type = "button",
        id = id,
        text = text,
        func = func,
    })

    local child = self:RefreshMenu(id)

    return child
end

function SlickerDropdownBaseMixin:CreateRadio(text, selectedFunc, func)
    local id = self.List:GetSize() + 1

    self.provider:Insert({
        type = "radio",
        id = id,
        text = text,
        func = func,
        selectedFunc = selectedFunc,
    })

    local child = self:RefreshMenu(id)

    return child
end

function SlickerDropdownBaseMixin:CreateCheckbox(text, selectedFunc, func)
    local id = self.List:GetSize() + 1

    self.provider:Insert({
        type = "checkbox",
        id = id,
        text = text,
        func = func,
        selectedFunc = selectedFunc,
    })

    local child = self:RefreshMenu(id)

    return child
end

function SlickerDropdownBaseMixin:CreateTemplate(template)
    local pool = self.frameFactories:GetOrCreatePool("Button", self.List, template, function(pool, frame) end)
    local frame = Mixin(pool:Acquire(), SlickerDropdownBaseMixin)

    return frame
end

function SlickerDropdownBaseMixin:CreateFrame()
    local pool = self.frameFactories:GetOrCreatePool("Frame", self.List, "BackdropTemplate", function(pool, frame) end)
    local frame = Mixin(pool:Acquire(), SlickerDropdownBaseMixin)

    return frame
end

function SlickerDropdownBaseMixin:CreateSubmenuArrow(texture, index)
    self.arrow = self.textureFactory:Acquire()
    self.arrow:SetPoint("RIGHT", -5, 0)
    self.arrow:SetTexture(texture or "Interface\\ChatFrame\\ChatFrameExpandArrow")

    self:SetWidth(self:GetWidth() + self.arrow:GetWidth() + 4)

    return self.arrow
end

function SlickerDropdownBaseMixin:AddInitializer(func)
    func(self)
end







SlickerDropdownMixin = {}

function SlickerDropdownMixin:Init(buttonTemplate)
    self.List:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    self.List:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")

    self:SetDefaultText("Select an activity...");

    self:SetScript("OnClick", function(localSelf)
        localSelf.List:SetShown(not localSelf.List:IsShown())
    end)
end








SlickerDropdownChildMixin = {}

function SlickerDropdownChildMixin:AddMotionScripts()
    self:SetScript("OnEnter", function(localSelf)
        if(localSelf:GetParent().activeList) then
            localSelf:GetParent().activeList:Hide()

        end

        if(self.buttonFactory:GetNumActive() > 0) then
            localSelf.List:Show()
            localSelf:GetParent().activeList = localSelf.List

        end
    end)

    self:SetScript("OnLeave", function(localSelf)

    end)
end

function SlickerDropdownChildMixin:Init()
    if(not hoverOnly) then
        self:SetScript("OnClick", function(localSelf)
            localSelf:GetParent():Hide()
            print(#self:GetChildren())
        end)
    end
    
    self:AddMotionScripts()

    self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 6)

    self:SetFixedWidth(self:GetParent():GetParent():GetWidth() - 4)
end

function SlickerDropdownChildMixin:AttachText(text, index)
    self.text = self.titleFontStringFactory:Acquire()
    self.text:SetHeight(self:GetHeight())
    self.text.layoutIndex = index or #self:GetChildren() + 1
    self.text:SetJustifyV("MIDDLE")
    self.text:SetText(text)

    return self.text
end

function SlickerDropdownChildMixin:AttachTexture(texture, index)
    self.icon = self.titleTextureFactory:Acquire()
    self.icon:SetSize(self:GetHeight(), self:GetHeight())
    self.icon.layoutIndex = index or #self:GetChildren() + 1
    self.icon:SetTexture(texture)

    return self.icon
end

function SlickerDropdownChildMixin:AttachRadioTexture(texture1, texture2, index)
    self.radio = self.titleTextureFactory:Acquire()
    self.radio:SetSize(self:GetHeight(), self:GetHeight())
    self.radio.layoutIndex = index or #self:GetChildren() + 1
    self.radio:SetAtlas(texture1 or "common-dropdown-tickradial")

    return self.radio
end

function SlickerDropdownChildMixin:AttachCheckboxTexture(texture1, texture2, index)
    self.radio = self.titleTextureFactory:Acquire()
    self.radio:SetSize(self:GetHeight(), self:GetHeight())
    self.radio.layoutIndex = index or #self:GetChildren() + 1
    self.radio:SetAtlas(texture1 or "common-dropdown-ticksquare")

    return self.radio
end

function SlickerDropdownChildMixin:CreateDivider(index)
    local divider = self.titleTextureFactory:Acquire()
    divider.layoutIndex = index or #self:GetParent():GetChildren() + 1
	divider:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent");
	divider:SetHeight(13);

	return divider;
end

function SlickerDropdownChildMixin:CreateSpacer()
    local spacer = self.frameFactories:GetOrCreatePool("Frame", self, "BackdropTemplate", function(pool, frame) end):Acquire()
    spacer.layoutIndex = index or #self:GetParent():GetChildren() + 1
	spacer:SetHeight(10);

	return spacer;
end

function SlickerDropdownChildMixin:CreateTitle(text)
    local title = self.titleFontStringFactory:Acquire()
    title.layoutIndex = index or #self:GetParent():GetChildren() + 1
    title:SetHeight(self:GetHeight())
    title:SetText(text)

	return title;
end