local addonName, miog = ...

--[[ 
    Mixin---------

    
    
]]

SlickDropDown = {}

function SlickDropDown:OnLoad()
	--self.List.framePool = CreateFramePool("Button", self.List, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)
	--self.List.framePool = CreateFramePool("Button", self.List, "PVPCasualActivityButton, MIOG_DropDownMenuEntry", SlickDropDown.ResetFrame)
	self.List.framePool = CreateFramePool("Button", self.List, "MIOG_DropDownMenuEntry", SlickDropDown.ResetFrame)
	self.List.fontStringPool = CreateFontStringPool(self.List, "OVERLAY", nil, "GameTooltipText", SlickDropDown.ResetFontString)
	self.List.texturePool = CreateTexturePool(self.List, "ARTWORK", nil, nil, SlickDropDown.ResetTexture)
	self.List.buttonPool = CreateFramePool("Button", self.List, "UIButtonTemplate", SlickDropDown.ResetButton)
	self.List.buttonPool2 = CreateFramePool("Button", self.List, "UIPanelButtonTemplate", SlickDropDown.ResetButton)
	
	self.entryFrameTree = {}
	self.currentList = nil
	self.deactivatedExtraButtons = {}
	self.List.highestWidth = 0
	self.List.ExpandButton = {}
	self.List:SetScript("OnMouseDown", function()

	end)

	--miog.setStandardBackdrop(self.Selected)
	--local color = CreateColorFromHexString(miog.C.BACKGROUND_COLOR)
	--self.Selected:SetBackdropColor(color.r, color.g, color.b, 0.6)
end

function SlickDropDown:SetText(text)
	self.Selected.Name:SetText(text)
end

function SlickDropDown:SetListAnchorToTopleft()
	self.List:ClearAllPoints()
	self.List:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
end

function SlickDropDown:SetListAnchorToTopright()
	self.List:ClearAllPoints()
	self.List:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
end

function SlickDropDown:SetListAnchorToTop()
	self.List:ClearAllPoints()
	self.List:SetPoint("TOP", self, "BOTTOM")
end

function SlickDropDown:ResetDropDown()
	for widget in self.List.framePool:EnumerateActive() do
		if(widget.List.framePool) then
			widget.List.framePool:ReleaseAll()
		end

		if(widget.List.securePool) then
			widget.List.securePool:ReleaseAll()

		end
	end

	if(self.List.securePool) then
		self.List.securePool:ReleaseAll()

	end

	self.List.fontStringPool:ReleaseAll()
	self.List.texturePool:ReleaseAll()
	self.List.buttonPool:ReleaseAll()
	self.List.buttonPool2:ReleaseAll()
	self.List.framePool:ReleaseAll()

	self.entryFrameTree = {}
	self.currentList = nil
	self.deactivatedExtraButtons = {}
	self.List.highestWidth = 0
	self.List.ExpandButton = {}
	self.List.selfCheck = false
end

function SlickDropDown:ReleaseSpecificFrames(keyword, specificList)
	local currentPool = specificList and specificList.framePool or self.List.framePool

	for k, v in currentPool:EnumerateActive() do
		if(k.type2 == keyword) then
			currentPool:Release(k)

		end

	end
end

function SlickDropDown:ResetButton(button)

end

function SlickDropDown:ResetFrame(frame)
	if(miog.F.QUEUE_STOP ~= true) then
		frame:Hide()
		frame.layoutIndex = nil
		frame.Name:SetText("")
		frame.Name:SetTextColor(1,1,1,1)
		frame.Icon:SetTexture(nil)
		frame.infoTable = nil
		frame.info = nil
		frame.type2 = nil
		frame.value = nil
		frame.tooltip = nil
		frame.tooltipTitle = nil
		frame.parentIndex = nil
		frame.activeCheck = nil
		frame.activities = nil
		frame:ClearBackdrop()

		frame:SetScript("OnShow", nil)
		frame:SetScript("OnClick", nil)
		frame:SetScript("OnEnter", nil)
		frame:SetScript("OnLeave", nil)
	end
end

function SlickDropDown:ResetFontString(fontString)
	fontString:ClearAllPoints()
	fontString.topPadding = nil
	fontString:SetJustifyH("CENTER")
	fontString:SetText("")
	fontString:SetTextColor(1,1,1,1)
	fontString:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")
	fontString.layoutIndex = nil
end

function SlickDropDown:ResetTexture(texture)
	texture:ClearAllPoints()
	texture.bottomPadding = nil
	texture.topPadding = nil
	texture:SetTexture(nil)
	texture:SetAtlas(nil)
	texture.layoutIndex = nil

end

function SlickDropDown:Disable()
	--self.Button:Disable()
	self:SetMouseClickEnabled(false)
	self.Selected:SetMouseClickEnabled(false)
end

function SlickDropDown:Enable()
	--self.Button:Enable()
	self:SetMouseClickEnabled(false)
	self.Selected:SetMouseClickEnabled(true)
end

function SlickDropDown:IsEnabled()
	return self.Button:IsEnabled()
end

function SlickDropDown:GetFrameAtIndex(index, parentIndex)
	if(parentIndex) then
		return self.entryFrameTree[parentIndex][index]

	elseif(index) then
		return self.entryFrameTree[index]
	
	else
		return nil
	
	end
end

function SlickDropDown:GetFirstChildFrameFromLayoutFrame(index)
	local baseFrame = self:GetFrameAtLayoutIndex(index)

	if(baseFrame) then
		local layoutChildren = baseFrame.List:GetLayoutChildren()

		return layoutChildren[1]
	end
end

function SlickDropDown:GetFrameAtLayoutIndex(index)
	local layoutChildren = self.List:GetLayoutChildren()

	for k, v in ipairs(layoutChildren) do
		if(k == index) then
			if(v.value) then
				return v

			else
				return layoutChildren[k + 1]

			end
		end
	end

	return nil
end

function SlickDropDown:GetFirstFrameWithValue(value)
	for _, v in ipairs(self.List:GetLayoutChildren()) do
		if(v.value and v.value == value) then
			return v

		else
			if(v.activities) then
				for x, y in pairs(v.activities) do
					if(y == value) then
						return v
					end

				end

			end

		end
	end
end

function SlickDropDown:SelectFirstFrameWithValue(value)
	for _, v in ipairs(self.List:GetLayoutChildren()) do
		if(v.value == value) then
			local status = self:SelectFrame(v)
			return status
		else
			if(v.activities) then
				for x, y in pairs(v.activities) do
					if(y == value) then
						return self:SelectFrame(v)
					end
				end
			end

			if(v.List) then
				for _, y in ipairs(v.List:GetLayoutChildren()) do
					if(y.value == value) then
						return self:SelectFrame(y)
					else
						if(y.activities) then
							for a, b in pairs(y.activities) do
								if(b == value) then
									return self:SelectFrame(y)
								end
							end
						end
					end

				end

			end
		end
	end

	return false
end

function SlickDropDown:SelectFrame(frame)
	if(frame) then
		local firstActivityName = frame.Name:GetText()

		self.Selected.Name:SetText(firstActivityName)
		self.Selected.value = frame.value

		frame.Radio:SetChecked(true)

		return true

	else
		return false
	
	end
end

function SlickDropDown:SelectFirstChildFrameFromLayoutFrame(index)
	local child = self:GetFirstChildFrameFromLayoutFrame(index)

	return self:SelectFrame(child)
end

function SlickDropDown:SelectFrameAtLayoutIndex(index)
	local layoutChildren = self.List:GetLayoutChildren()

	for k,v in ipairs(layoutChildren) do
		if(v.layoutIndex == index) then
			local selectedFrame = v
			if(selectedFrame) then
				if(selectedFrame.value) then
					return self:SelectFrame(selectedFrame)

				else
					return self:SelectFrame(layoutChildren[k + 1])

				end
			else
				return false
			
			end
		end
	end
end

function SlickDropDown:SetWidthToWidestFrame(infoTable)
	local list = infoTable and infoTable.parentIndex and self.entryFrameTree[infoTable.parentIndex].List or self.List

	local width = list.highestWidth + 45

	width = width > self:GetWidth() and width or self:GetWidth()

	local childrenList = list:GetLayoutChildren()

	if(childrenList) then
		for _, v in ipairs(childrenList) do
			v:SetWidth(width - 2)

		end
	else
		if(infoTable.parentIndex == 6) then
			print("NOTHING BITCH")
		end
		local frame = self.entryFrameTree[infoTable.parentIndex][infoTable.index or 1]
		frame:SetWidth(width - 2)
	end

	list.minimumWidth = width

	list:MarkDirty()
end

function SlickDropDown:GetListOfParent(index)
	return self.entryFrameTree[index].List
end

function SlickDropDown:CreateTextLine(index, parentIndex, text, icon, fontSize, expandable)
	local textLine = self.List.fontStringPool:Acquire()

	if(parentIndex) then
		textLine:SetParent(self.entryFrameTree[parentIndex].List)

	end

	textLine.topPadding = 7
	textLine:SetJustifyH("CENTER")
	textLine:SetText(text)
	local file, height, flags = textLine:GetFont()
	textLine:SetFont(file, fontSize or height, flags)
	textLine.layoutIndex = index or (parentIndex and #self.entryFrameTree[parentIndex].List:GetLayoutChildren() or #self.List:GetLayoutChildren()) + 1

	if(icon) then
		textLine:SetText("|A:" .. icon .. ":" .. (fontSize or 12) .. ":" .. (fontSize or 12) .. "|a" .. textLine:GetText())
	end

	if(expandable) then
		local button = Mixin(self.List.buttonPool:Acquire(), MultiStateButtonMixin)
		button:OnLoad()
		button:SetMaxStates(2)
		button:SetTexturesForBaseState("UI-HUD-ActionBar-PageDownArrow-Up", "UI-HUD-ActionBar-PageDownArrow-Down", "UI-HUD-ActionBar-PageDownArrow-Mouseover", "UI-HUD-ActionBar-PageDownArrow-Disabled")
		button:SetTexturesForState1("UI-HUD-ActionBar-PageUpArrow-Up", "UI-HUD-ActionBar-PageUpArrow-Down", "UI-HUD-ActionBar-PageUpArrow-Mouseover", "UI-HUD-ActionBar-PageUpArrow-Disabled")
		button:SetState(false)
		button:SetPoint("CENTER", textLine, "CENTER", (textLine:GetStringWidth() / 2) + 15, 0)

		local currentButtonIndex = #self.List.ExpandButton + 1
		self.List.ExpandButton[currentButtonIndex] = {}

		button:SetScript("OnClick", function(selfButton)
			for k, v in pairs(self.List.ExpandButton[currentButtonIndex]) do
				v:SetShown(not v:IsShown())
				

			end

			self.List:MarkDirty()
			selfButton:AdvanceState()
		end)
	end

	return textLine
end

function SlickDropDown:CreateSeparator(index, parentIndex)
	local divider = self.List.texturePool:Acquire()

	if(parentIndex) then
		divider:SetParent(self.entryFrameTree[parentIndex].List)

	end

	divider:SetSize((parentIndex and self.entryFrameTree[parentIndex] or divider:GetParent()):GetWidth(), 2)
	divider.topPadding = 3
	divider.bottomPadding = 3
	divider:SetAtlas("UI-LFG-DividerLine")
	divider.layoutIndex = index or (parentIndex and #self.entryFrameTree[parentIndex].List:GetLayoutChildren() or #self.List:GetLayoutChildren()) + 1
end

function SlickDropDown:CreateFunctionButton(index, parentIndex, text, func)
	local button = self.List.buttonPool2:Acquire()

	if(parentIndex) then
		button:SetParent(self.entryFrameTree[parentIndex].List)

	end

	button:SetText(text)
	button:SetSize((parentIndex and self.entryFrameTree[parentIndex] or button:GetParent()):GetWidth(), 20)
	button.topPadding = 3
	button.bottomPadding = 3
	button:SetScript("OnClick", func)
	button.layoutIndex = index or (parentIndex and #self.entryFrameTree[parentIndex].List:GetLayoutChildren() or #self.List:GetLayoutChildren()) + 1
end

local color = "FFAAAAAA"

local function setScriptsOnFrame(self)
	self:SetScript("OnEnter", function()
		if(self.ParentDropDown.currentList) then
			local parent = self:GetParent():GetParent()

			if(self.parentIndex and parent.layoutIndex) then
				if(self.parentIndex ~= parent.layoutIndex) then
					self.ParentDropDown.currentList:Hide()

				elseif(self.parentIndex == nil and parent.layoutIndex == nil)then
					self.ParentDropDown.currentList:Hide()
				
				end
			else
				self.ParentDropDown.currentList:Hide()
			
			end
		end

		if(self.List and #self.List:GetLayoutChildren() > 1) then
			self.List:Show()
			self.ParentDropDown.currentList = self.List
			
		end

		if(self.tooltip) then
			self:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:SetText(self.tooltipTitle)
				GameTooltip:AddLine(self.tooltip)
				GameTooltip:Show()
			end)
			self:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
		end

		if(self:GetTop() and GetScreenHeight() / 2 > self:GetTop()) then
			self.List:ClearAllPoints()
			self.List:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT")

		else
			self.List:ClearAllPoints()
			self.List:SetPoint("TOPLEFT", self, "TOPRIGHT")

		end
	end)
end

function SlickDropDown:InsertCustomFrame(info, frame)
	if(miog.F.QUEUE_STOP ~= true) then
		local list = nil
	
		local infoTable = info

		frame:ClearAllPoints()

		if(infoTable.parentIndex) then
			local parent = self.entryFrameTree[infoTable.parentIndex]
			list = self.entryFrameTree[infoTable.parentIndex].List

			if(parent == nil) then
				--DevTools_Dump(infoTable)

			end

			frame.layoutIndex = infoTable.index or #list:GetLayoutChildren() + 1

			self.entryFrameTree[infoTable.parentIndex][frame.layoutIndex] = frame

			list:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
			list:SetBackdropColor(CreateColorFromHexString("FF2A2B2C"):GetRGBA())
			list:SetBackdropBorderColor(CreateColorFromHexString(color):GetRGBA())

		else
			list = self.List

			frame.layoutIndex = infoTable.index or #list:GetLayoutChildren() +1
			
			self.entryFrameTree[frame.layoutIndex] = frame

			list:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false,  edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
			list:SetBackdropColor(CreateColorFromHexString("FF2A2B2C"):GetRGBA())
			list:SetBackdropBorderColor(CreateColorFromHexString(color):GetRGBA())

		end

		frame:SetParent(list)

		if(list.ExpandButton and #list.ExpandButton > 0) then
			table.insert(list.ExpandButton[#list.ExpandButton], frame)
		end
		
		frame.parentIndex = infoTable.parentIndex
		
		frame:SetHeight(20)

		frame:Show()

		self:SetWidthToWidestFrame(infoTable)

		return frame
	end
end

function SlickDropDown:CreateEntryFrame(info)
	if(miog.F.QUEUE_STOP ~= true) then
		local frame = nil
		local list = nil

		local infoTable = info

		if(infoTable.parentIndex) then
			local parent = self.entryFrameTree[infoTable.parentIndex]
			list = self.entryFrameTree[infoTable.parentIndex].List

			if(parent == nil) then
				--DevTools_Dump(infoTable)

			end

			--list.framePool = list.framePool or CreateFramePool("Button", list, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)
			list.framePool = list.framePool or CreateFramePool("Button", list, "MIOG_DropDownMenuEntry", SlickDropDown.ResetFrame)
			--list.securePool = list.securePool or CreateFramePool("Button", list, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)

			frame = list.framePool:Acquire()

			frame.layoutIndex = infoTable.index or #list:GetLayoutChildren() + 1

			self.entryFrameTree[infoTable.parentIndex][frame.layoutIndex] = frame

			frame:SetParent(list)
			list:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
			list:SetBackdropColor(CreateColorFromHexString("FF2A2B2C"):GetRGBA())
			list:SetBackdropBorderColor(CreateColorFromHexString(color):GetRGBA())

			list:SetScript("OnMouseDown", function()
				
			end)
		else
			list = self.List

			frame = list.framePool:Acquire()
			frame.layoutIndex = infoTable.index or #list:GetLayoutChildren() +1
			
			self.entryFrameTree[frame.layoutIndex] = frame

			list:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false,  edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
			list:SetBackdropColor(CreateColorFromHexString("FF2A2B2C"):GetRGBA())
			list:SetBackdropBorderColor(CreateColorFromHexString(color):GetRGBA())
			frame.List.highestWidth = 0
		
			frame.List.hideOnClick = infoTable.hideOnClick

		end

		if(list.ExpandButton and #list.ExpandButton > 0) then
			table.insert(list.ExpandButton[#list.ExpandButton], frame)
		end

		frame.Name:SetText(infoTable.text)
		frame.Icon:SetTexture(infoTable.icon)
		frame.type2 = infoTable.type2
		frame.value = infoTable.value
		frame.hasArrow = infoTable.hasArrow
		frame.activities = infoTable.activities

		local stringWidth = frame.Name:GetStringWidth()
		list.highestWidth = (stringWidth  > list.highestWidth and stringWidth or list.highestWidth)

		if(infoTable.disabled) then
			frame.Radio:Hide()

		else
			frame.Radio:SetShown(not infoTable.hasArrow)
			frame.Radio:SetChecked(infoTable.checked)
		
		end

		frame.tooltip = infoTable.tooltip
		frame.tooltipTitle = infoTable.tooltipTitle
		
		frame.ParentDropDown = self
		frame.parentIndex = infoTable.parentIndex

		if(infoTable.func) then
			frame:SetScript("OnClick", infoTable.func)

		end

		if(infoTable.disabled) then
			frame.Name:SetTextColor(0.5, 0.5, 0.5, 1)

		else
			frame.Name:SetTextColor(1, 1, 1, 1)

		end

		setScriptsOnFrame(frame)

		frame:Show()

		self:SetWidthToWidestFrame(infoTable)

		return frame
	end
end

function SlickDropDown:CreateExtraButton(baseButton, entryFrame)
	entryFrame.ExtraButton = baseButton
	
	entryFrame.ExtraButton:ClearAllPoints()
	entryFrame.ExtraButton:SetParent(entryFrame)
	entryFrame.ExtraButton:SetPoint("TOPLEFT", entryFrame, "TOPLEFT")
	entryFrame.ExtraButton:SetPoint("BOTTOMRIGHT", entryFrame, "BOTTOMRIGHT")

	if(entryFrame.ExtraButton.Title) then
		entryFrame.ExtraButton.Title:Hide()
	end

	entryFrame.ExtraButton:SetScript("OnShow", function()

		if(entryFrame.ExtraButton.Reward) then
			entryFrame.ExtraButton.Reward:Hide()
			
		end

		if(entryFrame.ExtraButton.Tier) then
			entryFrame.ExtraButton.Tier:Hide()
			
		end

		if(entryFrame.ExtraButton.CurrentRating) then
			entryFrame.ExtraButton.CurrentRating:Hide()
			
		end

		if(entryFrame.ExtraButton.TeamSizeText) then
			entryFrame.ExtraButton.TeamSizeText:Hide()
			
		end

		if(entryFrame.ExtraButton.TeamTypeText) then
			entryFrame.ExtraButton.TeamTypeText:Hide()
			
		end

	end)

	entryFrame.ExtraButton:HookScript("PostClick", function(selfButton)
		--for k, v in pairs(entryFrame.ParentDropDown.deactivatedExtraButtons) do
		--	v:Show()
		--	v:GetParent().Radio:Hide()
		--end

		--selfButton:Hide()
		--table.insert(entryFrame.ParentDropDown.deactivatedExtraButtons, selfButton)
		--entryFrame.Radio:Show()
	end)

	entryFrame.Radio:Hide()
end