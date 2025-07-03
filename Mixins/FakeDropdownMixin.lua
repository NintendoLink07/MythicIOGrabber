local dropdown

local visibleLists = {}
local selectedElements = {}

FakeDropdownListMixin = {}

local function resetPoolFrame(pool, frame)
    frame:Hide()
    frame.layoutIndex = nil
end

local function resetBasePoolFrame(pool, frame)
    resetPoolFrame(pool, frame)

    frame.fontString = nil

    frame.Radio:Hide()
    frame.Radio:SetChecked(false)

    frame.Checkbox:Hide()
    frame.Checkbox:SetChecked(false)

    frame.Text:SetPoint("LEFT", frame, "LEFT", 1, 0)
    frame.Text:SetText("")

    if(frame.List) then
        frame:ResetPools()

    end

    if(frame.attachTexturePool) then
        frame.attachTexturePool:ReleaseAll()

    else
        frame.attachTexturePool = CreateTexturePool(frame, "ARTWORK", nil, nil, function(localPool, texture) texture:ClearAllPoints() end)

    end
end

function FakeDropdownListMixin:HideAllLists()
    for list, status in pairs(visibleLists) do
        list:Hide()

    end
end

function FakeDropdownListMixin:ResetPools()
    self.List.framePoolCollection:ReleaseAll()
    self.List.texturePool:ReleaseAll()
    self.List.fontStringPool:ReleaseAll()
end

function FakeDropdownListMixin:CreateList()
    if(not self.List) then
        self.type = "list"

        self.List = self.List or CreateFrame("Frame", "List", self, "VerticalLayoutFrame")
        self.List:SetScript("OnMouseDown", function() end)
        self.List:SetFrameStrata("HIGH")
        self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, 0)
        self.List.topPadding = 5
        self.List.bottomPadding = 6
        self.List.leftPadding = 6
        self.List.rightPadding = 4
        self.List:Hide()

        self.List.level = self:GetParent().level and self:GetParent().level + 1 or 1

        self.List.Background = self.List.Background or self.List:CreateTexture("Background", "ARTWORK")
        self.List.Background:SetAtlas("common-dropdown-bg")
        self.List.Background:SetPoint("TOPLEFT", self.List, "TOPLEFT", -10, 6)
        self.List.Background:SetPoint("BOTTOMRIGHT", self.List, "BOTTOMRIGHT", 10, -12)

        self.List.framePoolCollection = self.List.framePoolCollection or CreateFramePoolCollection()
        self.List.framePoolCollection:GetOrCreatePool("Button", self.List, "MIOG_FakeDropdownButton", resetBasePoolFrame)

        self.List.texturePool = self.List.texturePool or CreateTexturePool(self.List, "ARTWORK", nil, nil, function(pool, texture) texture.layoutIndex = nil texture:SetTexture(nil) end)
        self.List.fontStringPool = self.List.fontStringPool or CreateFontStringPool(self.List, "OVERLAY", nil, "GameFontHighlight", function(pool, fontString) fontString.layoutIndex = nil fontString:SetText(nil) end)
    end

end

function FakeDropdownListMixin:CloseMenus()
    self:HideAllLists()

    dropdown:ResetPools()
end

function FakeDropdownListMixin:SetInitParameters(text, checkFunc, func, value)
    self.Text:SetText(text)

    self:SetScript("OnShow", function(localSelf)
        if(localSelf.List and #localSelf.List:GetLayoutChildren() > 0) then
            localSelf:CreateSubmenuArrow()

        end

        if(self:IsEnabled()) then
            self.Text:SetTextColor(1, 1, 1, 1)

        else
            self.Text:SetTextColor(0.6, 0.6, 0.6, 1)

        end

        if(checkFunc and checkFunc(value)) then
            (localSelf.Radio:IsShown() and localSelf.Radio or localSelf.Checkbox):SetChecked(true)
        end
    end)

    if(func) then
        self:SetScript("OnClick", function(localSelf)
            dropdown:OverrideText(localSelf.Text:GetText())

            func(value)

            if(localSelf.Checkbox:IsShown() and checkFunc) then
                localSelf.Checkbox:SetChecked(checkFunc(value))
                
                if(selectedElements[localSelf]) then
                    selectedElements[localSelf] = nil
                    
                else
                    selectedElements[localSelf] = localSelf.level

                end

            else
                localSelf:HideAllLists()
                selectedElements[localSelf] = localSelf.level

                dropdown:ResetPools()

            end

            --[[local s = ""
            local sorted = {}

            for k, v in pairs(selectedElements) do
                tinsert(sorted, {object = k, level = v})
                
            end

            table.sort(sorted, function(k1, k2)
                if(k1.level == k2.level) then
                    return k1.object.Text:GetText() < k2.object.Text:GetText()
                end

                return k1.level < k2.level
            end)

            local header

            for k, v in ipairs(sorted) do
                if(not header) then
                    s = v.object:GetParent():GetParent().Text:GetText()
                end

                s = s .. ", " .. v.object.Text:GetText()

            end

            dropdown:OverrideText(s)]]
        end)
    end
end

function FakeDropdownListMixin:CreateInnerButton(template)
    self:CreateList()

    --local button = CreateFrame("Button", nil, self.List, template or "MIOG_FakeDropdownButton")
    local button = template and self.List.framePoolCollection:GetOrCreatePool("Button", self.List, template, resetBasePoolFrame):Acquire(template) or self.List.framePoolCollection:Acquire("MIOG_FakeDropdownButton")
    button:SetHeight(20)
    button.layoutIndex = #button:GetParent():GetLayoutChildren() + 1
    button.fontString = button.Text
    button:SetParentKey(button.layoutIndex)

    button.level = self:GetParent().level and self:GetParent().level + 1 or 1

    button:SetScript("OnEnter", function(localSelf)
        local listBefore = localSelf:GetParent().visibleList

        if(listBefore) then
            listBefore:Hide()

            visibleLists[listBefore] = nil
        end

        if(localSelf.List and #localSelf.List:GetLayoutChildren() > 0) then
            localSelf:GetParent().visibleList = localSelf.List
            localSelf.List:Show()

            visibleLists[localSelf.List] = true

        end
    end)

    button:Show()

    self.List:MarkDirty()

    return button
end

function FakeDropdownListMixin:CreateButton(text, value)
    local button = self:CreateInnerButton()

    button:SetInitParameters(text, nil, nil, value)
    button:SetWidth(max(dropdown:GetWidth(), button.Text:GetUnboundedStringWidth() + 3))

    return button
end

function FakeDropdownListMixin:CreateRadio(text, checkFunc, func, value)
    local button = self:CreateInnerButton() --"UIRadioButtonTemplate"

    button.Radio:Show()
    button.Text:SetPoint("LEFT", button.Radio, "RIGHT", 6, 0)

    button:SetInitParameters(text, checkFunc, func, value)
    button:SetWidth(max(dropdown:GetWidth(), button.Text:GetUnboundedStringWidth() + 3 + (button.Checkbox:GetWidth() * 3)))

    return button
end

function FakeDropdownListMixin:CreateCheckbox(text, checkFunc, func, value)
    local button = self:CreateInnerButton() --"UICheckButtonTemplate"

    button.Checkbox:Show()
    button.Text:SetPoint("LEFT", button.Checkbox, "RIGHT", 5, 0)

    button:SetInitParameters(text, checkFunc, func, value)
    button:SetWidth(max(dropdown:GetWidth(), button.Text:GetUnboundedStringWidth() + 3 + (button.Checkbox:GetWidth() * 3)))

    return button
end

function FakeDropdownListMixin:CreateTemplate(template, type)
    self:CreateList()

    local frame = self.List.framePoolCollection:GetOrCreatePool(type, self.List, template, resetPoolFrame):Acquire(template)
    frame = Mixin(frame, FakeDropdownListMixin)
    
    frame:SetHeight(20)
    frame.expand = true
    frame.layoutIndex = #frame:GetParent():GetLayoutChildren() + 1
    frame:SetParentKey(frame.layoutIndex)

    frame:Show()

    frame:SetWidth(max(dropdown:GetWidth(), frame:GetParent():GetWidth()))

    self.List:MarkDirty()

    return frame
end

function FakeDropdownListMixin:CreateFrame()
    self:CreateList()

    local frame = self.List.framePoolCollection:GetOrCreatePool("Frame", self.List, "BackdropTemplate", resetPoolFrame):Acquire("BackdropTemplate")
    frame = Mixin(frame, FakeDropdownListMixin)
    frame.layoutIndex = #frame:GetParent():GetLayoutChildren() + 1
    frame:SetParentKey(frame.layoutIndex)
    frame:Show()

    frame:GetParent():MarkDirty()

    return frame
end

function FakeDropdownListMixin:CreateTitle(text)
    self:CreateList()

    local title = self.List.fontStringPool:Acquire()
    local _, height, flags = title:GetFont()
    title:SetFontObject("GameFontNormal")
    title:SetJustifyH("LEFT")
    title:SetHeight(20)
    title.expand = true
    title.layoutIndex = #title:GetParent():GetLayoutChildren() + 1
    title:SetParentKey(title.layoutIndex)
    title:SetText(text)

    if(self.type == "dropdown") then
        title:SetWidth(self:GetWidth())
    end

    title:GetParent():MarkDirty()

    return title
end

function FakeDropdownListMixin:CreateDivider()
    self:CreateList()

    local divider = self.List.texturePool:Acquire()
    divider:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
    divider:SetHeight(13)
    divider.expand = true
    divider.layoutIndex = #divider:GetParent():GetLayoutChildren() + 1
    divider:SetWidth(max(dropdown:GetWidth(), divider:GetParent():GetWidth()))
    divider:Show()
    divider:SetParentKey(divider.layoutIndex)

    divider:GetParent():MarkDirty()

    return divider
end

function FakeDropdownListMixin:CreateSpacer(extent)
    self:CreateList()

    local spacer = self.List.texturePool:Acquire()
    spacer:SetHeight(extent or 10)
    spacer.expand = true
    spacer.layoutIndex = #spacer:GetParent():GetLayoutChildren() + 1

    spacer:SetWidth(self:GetWidth())
    spacer:Show()
    spacer:SetParentKey(spacer.layoutIndex)

    self.List:MarkDirty()

    return spacer
end

function FakeDropdownListMixin:CreateSubmenuArrow(texture)
    local arrow = self.attachTexturePool:Acquire()
    arrow:SetPoint("RIGHT", self, "RIGHT", -3, 0)
    arrow:SetTexture(texture or "Interface\\ChatFrame\\ChatFrameExpandArrow")

    return arrow
end

function FakeDropdownListMixin:AddInitializer(func)
   local width = func(self)

   if(width) then
        --self:SetWidth(width)
   end
end

function FakeDropdownListMixin:AttachTexture()
    return self.attachTexturePool:Acquire()
end


FakeDropdownMixin = CreateFromMixins(FakeDropdownListMixin)

function FakeDropdownMixin:OnClick()
    local currentlyVisible = self.List:IsShown()

    if(not currentlyVisible and not dropdown.wasReset) then
        self.generator(self)
        self.List:Show()
        visibleLists[self.List] = true
        --[[
        When the dropdown button is shown, the generator function will be called (if it exists) to populate the description. Once finished, the dropdown 
button will iterate through all of the element descriptions accessible to the root description to find all of the selected elements, combining the 
result to form the selection text. If there are multiple selected elements, the text will become a comma delimited list.
        ]]

    else
        self.List:Hide()
        self:ResetPools()

    end

    dropdown.wasReset = false

    --self.List:SetShown(not self.List:IsShown())
end

local function iterateOverList(button, searchFor)
    if(searchFor == "mouseover" and MouseIsOver(button) or searchFor == "selection" and selectedElements[button]) then
        return true
    end

    if(button.List) then
        for k, v in ipairs(button.List:GetLayoutChildren()) do
            if(searchFor == "mouseover" and MouseIsOver(v) or searchFor == "selection" and selectedElements[v]) then
                return true
            end
        end
    end

    return false
end

function FakeDropdownMixin:IterateOverEverything(searchFor)
    for k, v in ipairs(self.List:GetLayoutChildren()) do
        if(iterateOverList(v, searchFor)) then
            return true
        end

    end

    return false
end

function FakeDropdownMixin:HandleGlobalMouseEvent(localSelf, event, buttonName)
    if event == "GLOBAL_MOUSE_DOWN" and (buttonName == "LeftButton" or buttonName == "RightButton") and self.List:IsShown() then
        if(not self:IterateOverEverything("mouseover")) then
            
            dropdown.wasReset = true
            
            self:OnClick()
        end
	end
end

function FakeDropdownMixin:SetupMenu(func)
    self.generator = func
    self.type = "dropdown"

    if(not self.List) then
        self:CreateList()
        
    end

    self.List:ClearAllPoints()

    self.List:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)

    dropdown = self

    self:SetScript("OnEvent", function(localSelf, ...)
        --localSelf:HandleGlobalMouseEvent(localSelf, ...)
    end)

    self:RegisterEvent("GLOBAL_MOUSE_DOWN")
end