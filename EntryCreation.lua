
local addonName, miog = ...
local wticc = WrapTextInColorCode

local function setUpRatingLevels()
	local score = C_ChallengeMode.GetOverallDungeonScore()

	local lowest = miog.round3(score, 50)

	local scoreTable = {}
	scoreTable[1] = lowest - 200
	scoreTable[2] = lowest - 150
	scoreTable[3] = lowest - 100
	scoreTable[4] = lowest - 50
	scoreTable[5] = lowest

	if(scoreTable[5] ~= score) then
		scoreTable[6] = score

	end

	for k, v in ipairs(scoreTable) do
		if(v >= 0) then
			local info = {}

			info.text = v
			info.value = v
			info.checked = false
			info.func = function() miog.EntryCreation.Rating:SetText(v) end

			miog.EntryCreation.Rating.DropDown:CreateEntryFrame(info)
		end
		
	end
end

local function setUpItemLevels()
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
	local itemLevelTable = {}

	local lowest = miog.round3(avgItemLevelEquipped, 5)

	itemLevelTable[1] = lowest - 20
	itemLevelTable[2] = lowest - 15
	itemLevelTable[3] = lowest - 10
	itemLevelTable[4] = lowest - 5
	itemLevelTable[5] = lowest

	if(itemLevelTable[5] ~= miog.round(avgItemLevelEquipped, 0)) then
		itemLevelTable[6] = miog.round(avgItemLevelEquipped, 0)

	end

	for k, v in ipairs(itemLevelTable) do
		if(v >= 0) then
			local info = {}

			info.text = v
			info.value = v
			info.checked = false
			info.func = function() miog.EntryCreation.ItemLevel:SetText(v) end

			miog.EntryCreation.ItemLevel.DropDown:CreateEntryFrame(info)
		end

	end
end

miog.createEntryCreation = function()
	local frame = CreateFrame("Frame", "MythicIOGrabber_EntryCreation", miog.Plugin.InsertFrame, "MIOG_EntryCreation") ---@class Frame
	frame:GetParent().EntryCreation = frame
	miog.EntryCreation = frame

	--miog.createFrameBorder(miog.EntryCreation.Background, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	miog.EntryCreation.Border:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	frame.selectedActivity = 0

	local activityDropDown = frame.ActivityDropDown
	activityDropDown:OnLoad()

	local difficultyDropDown = frame.DifficultyDropDown
	difficultyDropDown:OnLoad()

	local playstyleDropDown = frame.PlaystyleDropDown
	playstyleDropDown:OnLoad()

	local nameField = LFGListFrame.EntryCreation.Name
	nameField:ClearAllPoints()
	nameField:SetAutoFocus(false)
	nameField:SetParent(frame)
	nameField:SetSize(frame:GetWidth() - 15, 25)
	--nameField:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -80)
	nameField:SetPoint(frame.Name:GetPoint())
	frame.Name = nameField
	frame.NameString:SetPoint("BOTTOMLEFT", nameField, "TOPLEFT", -5, 0)

	local descriptionField = LFGListFrame.EntryCreation.Description
	descriptionField:ClearAllPoints()
	descriptionField:SetParent(frame)
	descriptionField:SetSize(frame:GetWidth() - 20, 50)
	descriptionField:SetPoint("TOPLEFT", frame.Name, "BOTTOMLEFT", 0, -20)
	frame.Description = descriptionField
	
	frame.Rating:SetPoint("TOPLEFT", frame.Description, "BOTTOMLEFT", 0, -20)
	
	local voiceChat = LFGListFrame.EntryCreation.VoiceChat
	--voiceChat.CheckButton:SetNormalTexture("checkbox-minimal")
	--voiceChat.CheckButton:SetPushedTexture("checkbox-minimal")
	--voiceChat.CheckButton:SetCheckedTexture("checkmark-minimal")
	--voiceChat.CheckButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	voiceChat.CheckButton:Hide()
	voiceChat.Label:Hide()
	voiceChat.EditBox:ClearAllPoints()
	voiceChat.EditBox:SetPoint("LEFT", frame.VoiceChat, "LEFT")
	--voiceChat:SetPoint("LEFT", frame.VoiceChat, "LEFT", -6, 0)
	voiceChat:ClearAllPoints()
	voiceChat:SetParent(frame)
	
	--miogDropdown.List:MarkDirty()
	--miogDropdown:MarkDirty()

	local startGroup = CreateFrame("Button", nil, miog.EntryCreation, "UIPanelDynamicResizeButtonTemplate, LFGListMagicButtonTemplate")
	startGroup:SetSize(1, 20)
	startGroup:SetPoint("RIGHT", miog.Plugin.FooterBar, "RIGHT")
	startGroup:SetText("Start Group")
	startGroup:FitToText()
	startGroup:RegisterForClicks("LeftButtonDown")
	startGroup:Show()
	startGroup:SetScript("OnClick", function()
		miog.listGroup()
	end)
	miog.EntryCreation.StartGroup = startGroup

	frame:HookScript("OnShow", function()
		if(C_LFGList.HasActiveEntryInfo()) then
			LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)
			startGroup:SetText("Update")

		else
			LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, false)
			startGroup:SetText("Start Group")

		end
	end)

	frame:HookScript("OnHide", function(self)
		self.ActivityDropDown.List:Hide()
		self.DifficultyDropDown.List:Hide()
		self.PlaystyleDropDown.List:Hide()
	end)

	local activityFinder = LFGListFrame.EntryCreation.ActivityFinder
	activityFinder:ClearAllPoints()
	activityFinder:SetParent(frame)
	activityFinder:SetPoint("TOPLEFT", frame, "TOPLEFT")
	activityFinder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	activityFinder:SetFrameStrata("DIALOG")

	frame.ItemLevel.DropDown.Selected:Hide()
	frame.ItemLevel.DropDown.Button:Show()
	frame.ItemLevel.DropDown:OnLoad()
	setUpItemLevels()

	frame.Rating.DropDown.Selected:Hide()
	frame.Rating.DropDown.Button:Show()
	frame.Rating.DropDown:OnLoad()
	setUpRatingLevels()
end