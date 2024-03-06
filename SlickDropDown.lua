local addonName, miog = ...

--[[ 
    Mixin---------

    
    
]]

SlickDropDown = {}

function SlickDropDown:OnLoad()
	self.List.framePool = CreateFramePool("Button", self.List, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)
	self.entryFrameTree = {}
	self.currentList = nil
	self.deactivatedExtraButtons = {}
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

	self.List.framePool:ReleaseAll()

	self.entryFrameTree = {}
	self.currentList = nil
	self.deactivatedExtraButtons = {}
end

function SlickDropDown:Disable()
	self.Button:Disable()
end

function SlickDropDown:Enable()
	self.Button:Enable()
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
		if(v.value == value) then
			return v
		end
	end
end

function SlickDropDown:SelectFirstFrameWithValue(value)
	for _, v in ipairs(self.List:GetLayoutChildren()) do
		if(v.value == value) then
			return self:SelectFrame(v)
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
	return self:SelectFrame(self.List:GetLayoutChildren()[index])
end

function SlickDropDown:SelectFrameAtIndex(index, parentIndex)
	if(parentIndex) then
		return self:SelectFrame(self.entryFrameTree[parentIndex][index])

	elseif(index) then
		return self:SelectFrame(self.entryFrameTree[index])

	end

	return false
end

function SlickDropDown:ResetFrame(frame)
	frame:Hide()
	frame.layoutIndex = nil
	frame.Name:SetText("")
	frame.Icon:SetTexture(nil)
	frame.infoTable = nil
	frame.type2 = nil
	frame.value = nil
	frame.entryType = nil
	frame.parentIndex = nil

	frame:SetScript("OnShow", nil)

	frame:SetAttribute("macrotext1", "")
	frame:SetAttribute("original", "")

	--self.List:MarkDirty()
	--self:MarkDirty()
end

function SlickDropDown:CreateEntryFrame(infoTable)
	local frame

	if(infoTable.parentIndex) then
		local parent = self.entryFrameTree[infoTable.parentIndex]
		parent.List.framePool = parent.List.framePool or CreateFramePool("Button", parent.List, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)
		parent.List.securePool = parent.List.securePool or CreateFramePool("Button", parent.List, "PVPCasualActivityButton, MIOG_DropDownMenuEntry, SecureActionButtonTemplate", SlickDropDown.ResetFrame)

		if(infoTable.func) then
			frame = parent.List.framePool:Acquire()

		else
			frame = parent.List.securePool:Acquire()

		end

		local tableIndex = #parent + 1
		frame.layoutIndex = infoTable.index or tableIndex

		self.entryFrameTree[infoTable.parentIndex][frame.layoutIndex] = frame

		frame:SetParent(self.entryFrameTree[infoTable.parentIndex].List)

		self.entryFrameTree[infoTable.parentIndex].List:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
		self.entryFrameTree[infoTable.parentIndex].List:SetBackdropColor(CreateColorFromHexString("FF2A2B2C"):GetRGBA())

		if(infoTable.parentIndex) then
			frame.Difficulty1:Hide()
		end

	else
		frame = self.List.framePool:Acquire()
		local tableIndex = infoTable.index or #self.entryFrameTree + 1
		frame.layoutIndex = tableIndex
		self.entryFrameTree[tableIndex] = frame

		self.List:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
		self.List:SetBackdropColor(CreateColorFromHexString("FF2A2B2C"):GetRGBA())
		frame.Difficulty1:Hide()
	
	end


	frame:SetWidth(self:GetWidth())
	frame.entryType = infoTable.entryType
	frame.Name:SetText(infoTable.text)
	frame.Icon:SetTexture(infoTable.icon)
	frame.type2 = infoTable.type2
	frame.value = infoTable.value

	if(infoTable.disabled) then
		frame.Radio:Hide()

	else
		frame.Radio:SetShown(frame.entryType ~= "arrow")
		frame.Radio:SetChecked(infoTable.checked)
	
	end
	--frame.Radio:SetMouseClickEnabled(true)
	frame.ParentDropDown = self
	frame.parentIndex = infoTable.parentIndex

	if(infoTable.func) then
		frame:SetScript("OnClick", infoTable.func)

	else
		frame:SetMouseClickEnabled(not infoTable.disabled)
		frame:RegisterForClicks("LeftButtonDown")
		frame:SetAttribute("type", "macro") -- left click causes macro

		if(infoTable.type2 == "more") then
			frame:SetAttribute("macrotext1", "/run PVEFrame_ShowFrame(\"PVPUIFrame\", \"HonorFrame\")" .. "\r\n" .. "/run HonorFrame.BonusFrame.Arena1Button:ClearAllPoints()" .. "\r\n" .. 
			"/run HonorFrame.BonusFrame.Arena1Button:SetPoint(\"LEFT\", HonorFrame.BonusFrame, \"LEFT\", (HonorFrame.BonusFrame:GetWidth() - HonorFrame.BonusFrame.Arena1Button:GetWidth()) / 2, 0)")
			--HonorFrame.BonusFrame.Arena1Button:ClearAllPoints()
			--HonorFrame.BonusFrame.Arena1Button:SetPoint("LEFT", HonorFrame.BonusFrame, "LEFT", (HonorFrame.BonusFrame:GetWidth() - HonorFrame.BonusFrame.Arena1Button:GetWidth()) / 2, 0)

		elseif(infoTable.type2 == "unrated") then
			frame:SetAttribute("macrotext1", "/click [nocombat] HonorFrameQueueButton")

		elseif(infoTable.type2 == "rated") then
			frame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")

		end

		frame:SetAttribute("original", frame:GetAttribute("macrotext1"))

	end

	if(infoTable.disabled) then
		frame.Name:SetTextColor(0.5, 0.5, 0.5, 1)

	else
		frame.Name:SetTextColor(1, 1, 1, 1)

	end

	frame:Show()

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