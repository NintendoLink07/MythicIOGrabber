local addonName, miog = ...

--[[ 
    Mixin---------

    
    
]]

SlickDropDown = {}

function SlickDropDown:OnLoad()
	self.List.framePool = CreateFramePool("Button", self.List, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)
	self.List.fontStringPool = CreateFontStringPool(self.List, "OVERLAY", nil, "GameTooltipText", SlickDropDown.ResetFontString)
	self.List.texturePool = CreateTexturePool(self.List, "ARTWORK", nil, nil, SlickDropDown.ResetTexture)
	
	self.entryFrameTree = {}
	self.currentList = nil
	self.deactivatedExtraButtons = {}
	self.List.highestWidth = 0
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

	self.List.fontStringPool:ReleaseAll()
	self.List.texturePool:ReleaseAll()

	self.List.framePool:ReleaseAll()

	self.entryFrameTree = {}
	self.currentList = nil
	self.deactivatedExtraButtons = {}
	self.List.highestWidth = 0
end

function SlickDropDown:ResetFrame(frame)
	frame:Hide()
	frame.layoutIndex = nil
	frame.Name:SetText("")
	frame.Icon:SetTexture(nil)
	frame.infoTable = nil
	frame.type2 = nil
	frame.value = nil
	frame.parentIndex = nil

	frame:SetScript("OnShow", nil)

	frame:SetAttribute("macrotext1", "")
	frame:SetAttribute("original", "")

	--self.List:MarkDirty()
	--self:MarkDirty()
end

function SlickDropDown:ResetFontString(fontString)
	fontString:ClearAllPoints()
	fontString.topPadding = nil
	fontString:SetJustifyH("CENTER")
	fontString:SetText("")
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
end

function SlickDropDown:Enable()
	--self.Button:Enable()
	self:SetMouseClickEnabled(false)
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

function SlickDropDown:GetFrameAtLayoutIndex(index)
	return self.List:GetLayoutChildren()[index]
end

function SlickDropDown:GetFirstFrameWithValue(value)
	for _, v in ipairs(self.List:GetLayoutChildren()) do
		if(v.value and v.value == value) then
			return v
		end
	end
end

function SlickDropDown:SelectFirstFrameWithValue(value)
	for _, v in ipairs(self.List:GetLayoutChildren()) do
		if(v.value == value) then
			local status = self:SelectFrame(v)
			return status
		end
	end

	return false
end

function SlickDropDown:SelectFrame(frame)
	if(frame) then
		local firstActivityName = frame.Name:GetText()

		self.CheckedValue.Name:SetText(firstActivityName)
		self.CheckedValue.value = frame.value

		frame.Radio:SetChecked(true)

		return true

	else
		return false
	
	end
end

function SlickDropDown:SelectFrameAtLayoutIndex(index)
	local selectedFrame = self.List:GetLayoutChildren()[index]

	if(selectedFrame) then
		if(selectedFrame.Name) then
			return self:SelectFrame(selectedFrame)

		else
			return self:SelectFrameAtLayoutIndex(index + 1)

		end
	else
		return false
	
	end
end

function SlickDropDown:SelectFrameAtIndex(index, parentIndex)
	if(parentIndex) then
		return self:SelectFrame(self.entryFrameTree[parentIndex][index])

	elseif(index) then
		return self:SelectFrame(self.entryFrameTree[index])

	end

	return false
end

function SlickDropDown:SetWidthToWidestFrame(infoTable)
	local list = infoTable and infoTable.parentIndex and self.entryFrameTree[infoTable.parentIndex].List or self.List

	local width = list.highestWidth + 45

	width = width > self:GetWidth() and width or self:GetWidth()

	-- SET TO LIST STANDARD WITH IF EVERY FRAME IS SMALLER

	--list:SetWidth(width)

	for _, v in ipairs(list:GetLayoutChildren()) do
		v:SetWidth(width)

	end

	list:MarkDirty()
end

function SlickDropDown:CreateTextLine(index, specificList, text)
	local textLine = self.List.fontStringPool:Acquire()
	textLine.topPadding = 7
	textLine:SetJustifyH("CENTER")
	textLine:SetText(text)
	textLine.layoutIndex = index or specificList and #specificList:GetLayoutChildren() or #self.entryFrameTree + 1
end

function SlickDropDown:CreateSeparator(index, specificList)
	local divider = self.List.texturePool:Acquire()
	divider:SetSize(divider:GetParent():GetWidth(), 2)
	divider.topPadding = 3
	divider.bottomPadding = 3
	divider:SetAtlas("UI-LFG-DividerLine")
	divider.layoutIndex = index or specificList and #specificList:GetLayoutChildren() or #self.entryFrameTree + 1
end

local color = "FFAAAAAA"

function SlickDropDown:CreateEntryFrame(infoTable)
	local frame = nil
	local list = nil

	if(infoTable.parentIndex) then
		local parent = self.entryFrameTree[infoTable.parentIndex]
		local tableIndex = #parent + 1
		list = self.entryFrameTree[infoTable.parentIndex].List

		parent.List.framePool = parent.List.framePool or CreateFramePool("Button", parent.List, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)
		parent.List.securePool = parent.List.securePool or CreateFramePool("Button", parent.List, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)

		if(infoTable.func) then
			frame = parent.List.framePool:Acquire()

		else
			frame = parent.List.securePool:Acquire()

		end

		frame.layoutIndex = infoTable.index or tableIndex

		self.entryFrameTree[infoTable.parentIndex][frame.layoutIndex] = frame

		frame:SetParent(list)
		list:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
		list:SetBackdropColor(CreateColorFromHexString("FF2A2B2C"):GetRGBA())
		list:SetBackdropBorderColor(CreateColorFromHexString(color):GetRGBA())

		if(infoTable.parentIndex) then
			frame.Difficulty1:Hide()
		end

	else
		local tableIndex = infoTable.index or #self.entryFrameTree + 1
		list = self.List

		frame = self.List.framePool:Acquire()
		frame.layoutIndex = tableIndex
		self.entryFrameTree[tableIndex] = frame

		self.List:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false,  edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
		self.List:SetBackdropColor(CreateColorFromHexString("FF2A2B2C"):GetRGBA())
		self.List:SetBackdropBorderColor(CreateColorFromHexString(color):GetRGBA())
		frame.Difficulty1:Hide()
		frame.List.highestWidth = 0
	
	end

	frame.Name:SetText(infoTable.text)
	frame.Icon:SetTexture(infoTable.icon)
	frame.type2 = infoTable.type2
	frame.value = infoTable.value
	frame.hasArrow = infoTable.hasArrow

	local stringWidth = frame.Name:GetStringWidth()
	list.highestWidth = (stringWidth  > list.highestWidth and stringWidth or list.highestWidth)

	if(infoTable.disabled) then
		frame.Radio:Hide()

	else
		frame.Radio:SetShown(not infoTable.hasArrow)
		frame.Radio:SetChecked(infoTable.checked)
	
	end
	
	frame.ParentDropDown = self
	frame.parentIndex = infoTable.parentIndex

	if(infoTable.func) then
		frame:SetScript("OnClick", infoTable.func)

	else
		frame:SetMouseClickEnabled(not infoTable.disabled)
		frame:RegisterForClicks("LeftButtonDown")
		frame:SetAttribute("type", "macro") -- left click causes macro

	end

	if(infoTable.disabled) then
		frame.Name:SetTextColor(0.5, 0.5, 0.5, 1)

	else
		frame.Name:SetTextColor(1, 1, 1, 1)

	end

	--self:SetWidthToWidestFrame(frame, infoTable)

	frame:Show()

	self:SetWidthToWidestFrame(infoTable)

	return frame
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
		for k, v in pairs(entryFrame.ParentDropDown.deactivatedExtraButtons) do
			v:Show()
			v:GetParent().Radio:Hide()
		end

		selfButton:Hide()
		table.insert(entryFrame.ParentDropDown.deactivatedExtraButtons, selfButton)
		entryFrame.Radio:Show()
	end)

	entryFrame.Radio:Hide()

	entryFrame:SetScript("OnShow", function()
		if(entryFrame.type2 == "unrated") then
			if(HonorFrame.type == "specific") then
				entryFrame.Name:SetTextColor(1, 0, 0, 1)
				entryFrame:SetAttribute("macrotext1", "/run PVEFrame_ShowFrame(\"PVPUIFrame\", \"HonorFrame\")")

			else
				entryFrame.Name:SetTextColor(1, 1, 1, 1)
				entryFrame:SetAttribute("macrotext1", entryFrame:GetAttribute("original"))
			
			end
		end
	end)
end