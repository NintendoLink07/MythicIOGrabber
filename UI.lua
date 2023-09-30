local addonName, miog = ...

miog.mainFrame = CreateFrame("Frame", "MythicIOGrabber_MainFrame", LFGListFrame, "BackdropTemplate")

local function insertPointsIntoTable(frame)
	local table = {}

	for i = 1, frame:GetNumPoints(), 1 do
		table[i] = {frame:GetPoint(i)}
	end

	return table
end

local function insertPointsIntoFrame(frame, table)
	for i = 1, #table, 1 do
		frame:SetPoint(unpack(table[i]))
	end
end

miog.createMainFrame = function()
	miog.mainFrame:SetSize(LFGListFrame:GetWidth() + 2, LFGListPVEStub:GetHeight() - PVEFrame.TitleContainer:GetHeight() - 5)
	miog.mainFrame:SetPoint(LFGListFrame.ApplicationViewer:GetPoint())
	miog.mainFrame:SetMovable(true)
	miog.mainFrame:AdjustPointsOffset(-4, -PVEFrame.TitleContainer:GetHeight()-2)
	miog.mainFrame:SetFrameStrata("DIALOG")
	miog.mainFrame.expanded = false
	miog.mainFrame:Hide()
	
	_G[miog.mainFrame:GetName()] = miog.mainFrame
	tinsert(UISpecialFrames, miog.mainFrame:GetName())

	local mainFrameBackgroundTexture = miog.persistentTexturePool:Acquire()
	mainFrameBackgroundTexture:SetPoint("TOPLEFT", miog.mainFrame, "TOPLEFT")
	mainFrameBackgroundTexture:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT")
	mainFrameBackgroundTexture:SetParent(miog.mainFrame)
	mainFrameBackgroundTexture:SetDrawLayer("BACKGROUND")
	mainFrameBackgroundTexture:SetTexture(985877)
	mainFrameBackgroundTexture:SetTexCoord(0, 0.3215, 0.133, 0.4605)
	miog.mainFrame.backgroundTexture = mainFrameBackgroundTexture

    local pveFrameTab1_Point = insertPointsIntoTable(PVEFrameTab1)

	local titleBar = miog.persistentFramePool:Acquire("BackdropTemplate")
	titleBar:SetPoint("TOPLEFT", miog.mainFrame, "TOPLEFT", 0, 0)
	titleBar:SetPoint("BOTTOMRIGHT", miog.mainFrame, "TOPRIGHT", 0, -25)
	titleBar:SetParent(miog.mainFrame)
	titleBar:Show()
	miog.mainFrame.titleBar = titleBar

	miog.F.FACTION_ICON_SIZE = titleBar:GetHeight() - 2

	local titleString = miog.persistentFontStringPool:Acquire()
	titleString:SetFont(miog.fonts["libMono"], 14, "OUTLINE")
	titleString:SetPoint("LEFT", titleBar, "LEFT", 4, -1)
	titleString:SetParent(titleBar)
	titleString:SetJustifyH("LEFT")
	titleString:SetJustifyV("CENTER")
	titleString:Show()
	miog.mainFrame.titleBar.titleString = titleString

	local faction = miog.persistentFontStringPool:Acquire()
	faction:SetFont(miog.fonts["libMono"], 10, "OUTLINE")
	faction:SetText(
		CreateTextureMarkup(2173919, 56, 56, titleBar:GetHeight(), titleBar:GetHeight(), 0, 1, 0, 1)..
		CreateTextureMarkup(2173920, 56, 56, titleBar:GetHeight(), titleBar:GetHeight(), 0, 1, 0, 1)
	)
	faction:SetJustifyH("RIGHT")
	faction:SetPoint("RIGHT", titleBar, "RIGHT", -1, -1)
	faction:SetSize(titleBar:GetHeight()*2, titleBar:GetHeight())
	faction:SetParent(titleBar)
	faction:Show()
	miog.mainFrame.titleBar.faction = faction

	local resetButton = miog.persistentFramePool:Acquire("BigRedRefreshButtonTemplate")
	resetButton:ClearAllPoints()
	resetButton:SetSize(PVEFrameCloseButton:GetHeight(), PVEFrameCloseButton:GetHeight())
	resetButton:SetPoint("RIGHT", PVEFrameCloseButton, "LEFT", -1, 1)
	resetButton:SetParent(titleBar)
	resetButton:SetScript("OnClick",
		function()
			C_LFGList.RefreshApplicants()
		end
	)
	resetButton:Show()
	miog.mainFrame.resetButton = resetButton

	local expandDownwardsButton = miog.persistentFramePool:Acquire("UIButtonTemplate")
	expandDownwardsButton:SetParent(titleBar)
	expandDownwardsButton:SetSize(miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE)
	expandDownwardsButton:SetPoint("RIGHT", resetButton, "LEFT", 0, -expandDownwardsButton:GetHeight()/4)

	expandDownwardsButton:SetNormalTexture(293770)
	expandDownwardsButton:SetPushedTexture(293769)

	expandDownwardsButton:RegisterForClicks("LeftButtonDown")
	expandDownwardsButton:SetScript("OnClick", function(self, button, down)
		miog.mainFrame.expanded = not miog.mainFrame.expanded

		if(miog.mainFrame.expanded) then
			miog.mainFrame:SetSize(miog.mainFrame:GetWidth(), miog.mainFrame:GetHeight() * 1.5)
			PVEFrameTab1:ClearAllPoints()
			PVEFrameTab1:SetWidth(PVEFrameTab1:GetWidth()-2)
			PVEFrameTab1:SetPoint("TOPLEFT", miog.mainFrame, "BOTTOMLEFT", 0, 0)

		elseif(not miog.mainFrame.expanded) then
			miog.mainFrame:SetSize(miog.mainFrame:GetWidth(), miog.mainFrame:GetHeight() / 1.5)
			PVEFrameTab1:ClearAllPoints()
			PVEFrameTab1:SetWidth(PVEFrameTab1:GetWidth()+2)
			insertPointsIntoFrame(PVEFrameTab1, pveFrameTab1_Point)

		end

		
	miog.mainFrame:HookScript("OnShow", function()
		PVEFrameTab1:ClearAllPoints()
		PVEFrameTab1:SetWidth(PVEFrameTab1:GetWidth()-2)
		PVEFrameTab1:SetPoint("TOPLEFT", miog.mainFrame, "BOTTOMLEFT", 0, 0)
	end)
	miog.mainFrame:HookScript("OnHide", function()
		PVEFrameTab1:ClearAllPoints()
		PVEFrameTab1:SetWidth(PVEFrameTab1:GetWidth()+2)
		insertPointsIntoFrame(PVEFrameTab1, pveFrameTab1_Point)
	end)
	end)

	expandDownwardsButton:Show()
	miog.mainFrame.expandDownwardsButton = expandDownwardsButton

	local voiceChat = LFGListFrame.ApplicationViewer.VoiceChatFrame
	voiceChat:ClearAllPoints()
	voiceChat:SetPoint("RIGHT", faction, "LEFT", -2, 0)
	voiceChat:SetParent(titleBar)
	miog.mainFrame.titleBar.voiceChat = voiceChat

	local infoPanel = miog.persistentFramePool:Acquire("BackdropTemplate")
	infoPanel:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
	infoPanel:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
	infoPanel:SetHeight(95)
	infoPanel:SetParent(miog.mainFrame)
	miog.createFrameBorder(infoPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	infoPanel:Show()
	miog.mainFrame.infoPanel = infoPanel

	local infoPanelBackgroundTexture = miog.persistentTexturePool:Acquire()
	infoPanelBackgroundTexture:SetPoint("TOPLEFT", infoPanel, "TOPLEFT")
	infoPanelBackgroundTexture:SetPoint("BOTTOMRIGHT", infoPanel, "BOTTOMRIGHT")
	infoPanelBackgroundTexture:SetParent(infoPanel)
	infoPanelBackgroundTexture:SetTexture(LFGListFrame.ApplicationViewer.InfoBackground:GetTexture())
	infoPanelBackgroundTexture:SetDrawLayer("BACKGROUND")
	infoPanelBackgroundTexture:SetTexCoord(0.05, 0.3215, 0.04, 0.128)
	infoPanelBackgroundTexture:Show()
	miog.mainFrame.infoPanel.backgroundTexture = infoPanelBackgroundTexture

	local affixes = miog.persistentFontStringPool:Acquire()
	affixes:SetFont(miog.fonts["libMono"], 22, "OUTLINE")
	affixes:SetPoint("TOPRIGHT", infoPanel, "TOPRIGHT", -2, -3)
	affixes:SetWidth(infoPanel:GetWidth()*0.075)
	affixes:SetParent(infoPanel)
	miog.mainFrame.affixes = affixes

	local settingScrollFrame = miog.persistentFramePool:Acquire("BackdropTemplate, ScrollFrameTemplate")
	settingScrollFrame:SetPoint("TOPLEFT",  infoPanel, "TOPLEFT")
	settingScrollFrame:SetWidth(infoPanel:GetWidth()*0.925)
	settingScrollFrame:SetHeight(infoPanel:GetHeight()*0.72)
	settingScrollFrame:SetParent(infoPanel)
	settingScrollFrame.ScrollBar:Hide()
	settingScrollFrame:Show()
	settingScrollFrame:SetMouseMotionEnabled(true)
	settingScrollFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(settingScrollFrame, "ANCHOR_CURSOR")

		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		if(activeEntryInfo) then
			if(activeEntryInfo.comment) then
				GameTooltip:SetText(activeEntryInfo.comment)
			end
		end


		GameTooltip:Show()
	end)
	settingScrollFrame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	miog.mainFrame.settingScrollFrame = settingScrollFrame

	local settingContainer = miog.persistentFramePool:Acquire("BackdropTemplate")
	settingContainer:SetSize(settingScrollFrame:GetWidth(), settingScrollFrame:GetHeight())
	settingContainer:SetPoint("TOP", settingScrollFrame, "TOP", 0, 0)
	settingContainer:SetParent(settingScrollFrame)
	settingContainer:Show()

	settingScrollFrame:SetScrollChild(settingContainer)
	miog.mainFrame.settingScrollFrame.settingContainer = settingContainer

	local settingString = miog.persistentFontStringPool:Acquire()
	settingString:SetFont(miog.fonts["libMono"], miog.C.SETTING_FONT_SIZE, "THICK")
	settingString:SetPoint("TOPLEFT", settingContainer, "TOPLEFT", 4, -miog.C.PADDING_OFFSET*2)
	settingString:SetWidth(settingContainer:GetWidth() - miog.C.PADDING_OFFSET*3)
	settingString:SetParent(settingContainer)
	settingString:SetJustifyV("TOP")
	settingString:SetJustifyH("LEFT")
	settingString:SetSpacing(3)
	settingString:SetWordWrap(true)
	settingString:SetNonSpaceWrap(true)
	settingString:Show()
	miog.mainFrame.settingScrollFrame.settingContainer.settingString = settingString

	local statusBar = miog.persistentFramePool:Acquire("BackdropTemplate")
	statusBar:SetPoint("TOPLEFT", settingScrollFrame, "BOTTOMLEFT", 0, 0)
	statusBar:SetPoint("TOPRIGHT", affixes, "BOTTOMRIGHT", 0, 0)
	statusBar:SetHeight(infoPanel:GetHeight()*0.28)
	statusBar:SetParent(miog.mainFrame)
	statusBar:Show()

	miog.mainFrame.statusBar = statusBar

	local timerString = miog.persistentFontStringPool:Acquire()
	timerString:SetFont(miog.fonts["libMono"], 18, "OUTLINE")
	timerString:SetPoint("LEFT", statusBar, "LEFT", miog.C.PADDING_OFFSET*1, 0)
	timerString:SetParent(statusBar)
	timerString:SetJustifyV("CENTER")
	timerString:Show()
	miog.mainFrame.statusBar.timerString = timerString
			
	if(not IsAddOnLoaded("RaiderIO")) then
		local rioLoaded = miog.persistentFontStringPool:Acquire()
		rioLoaded:SetFont(miog.fonts["libMono"], 18, "OUTLINE")
		rioLoaded:SetPoint("TOPLEFT", timerString, "TOPRIGHT", 5, 0)
		rioLoaded:SetParent(statusBar)
		rioLoaded:SetJustifyH("LEFT")
		rioLoaded:SetText(WrapTextInColorCode("NO R.IO", miog.C.RED_COLOR))
		rioLoaded:Show()
		miog.mainFrame.statusBar.rioLoaded = rioLoaded
	end

	local showDPSButton = miog.persistentFramePool:Acquire("UICheckButtonTemplate")
	showDPSButton:SetParent(statusBar)
	showDPSButton:SetPoint("RIGHT", statusBar, "RIGHT", -miog.C.ENTRY_FRAME_SIZE + 4, 0)
	showDPSButton:SetSize(miog.C.ENTRY_FRAME_SIZE * 1.2, miog.C.ENTRY_FRAME_SIZE * 1.2)
	showDPSButton:RegisterForClicks("LeftButtonDown")
	showDPSButton:SetChecked(true)
	showDPSButton:SetScript("OnClick", function(self, leftButton)
		miog.F.SHOW_DPS = not miog.F.SHOW_DPS

		miog.checkApplicantList(true, miog.defaultOptionSettings[3].value)
	end)
	showDPSButton:Show()
	
	local showHealersButton = miog.persistentFramePool:Acquire("UICheckButtonTemplate")
	showHealersButton:SetParent(statusBar)
	showHealersButton:SetPoint("RIGHT", showDPSButton, "LEFT", -miog.C.ENTRY_FRAME_SIZE, 0)
	showHealersButton:SetSize(miog.C.ENTRY_FRAME_SIZE * 1.2, miog.C.ENTRY_FRAME_SIZE * 1.2)
	showHealersButton:RegisterForClicks("LeftButtonDown")
	showHealersButton:SetChecked(true)
	showHealersButton:SetScript("OnClick", function(self, leftButton)
		miog.F.SHOW_HEALERS = not miog.F.SHOW_HEALERS

		miog.checkApplicantList(true, miog.defaultOptionSettings[3].value)
	end)
	showHealersButton:Show()
	
	local showTanksButton = miog.persistentFramePool:Acquire("UICheckButtonTemplate")
	showTanksButton:SetParent(statusBar)
	showTanksButton:SetPoint("RIGHT", showHealersButton, "LEFT", -miog.C.ENTRY_FRAME_SIZE, 0)
	showTanksButton:SetSize(miog.C.ENTRY_FRAME_SIZE * 1.2, miog.C.ENTRY_FRAME_SIZE * 1.2)
	showTanksButton:RegisterForClicks("LeftButtonDown")
	showTanksButton:SetChecked(true)
	showTanksButton:SetScript("OnClick", function(self, leftButton)
		miog.F.SHOW_TANKS = not miog.F.SHOW_TANKS

		miog.checkApplicantList(true, miog.defaultOptionSettings[3].value)
	end)
	showTanksButton:Show()

	for i = 1, 3, 1 do
		local roleTexture = miog.persistentTexturePool:Acquire()
		roleTexture:SetDrawLayer("ARTWORK")
		roleTexture:SetSize(miog.C.ENTRY_FRAME_SIZE * 0.9, miog.C.ENTRY_FRAME_SIZE * 0.9)
		roleTexture:SetTexture(2202478)
		roleTexture:SetParent(settingScrollFrame)

		if(i == 1) then
			roleTexture:SetPoint("LEFT", showTanksButton, "RIGHT", -4, 0)
			roleTexture:SetTexCoord(0.52, 0.75, 0.03, 0.97)
		elseif(i == 2) then
			roleTexture:SetPoint("LEFT", showHealersButton, "RIGHT", -4, 0)
			roleTexture:SetTexCoord(0.27, 0.5, 0.03, 0.97)
		elseif(i == 3) then
			roleTexture:SetPoint("LEFT", showDPSButton, "RIGHT", -4, 0)
			roleTexture:SetTexCoord(0.02, 0.25, 0.03, 0.97)
		end

		roleTexture:Show()
	end

	local autoSortButton = miog.persistentFramePool:Acquire("UICheckButtonTemplate")
	autoSortButton:SetParent(statusBar)
	autoSortButton:SetPoint("RIGHT", showTanksButton, "LEFT", -miog.C.ENTRY_FRAME_SIZE, 0)
	autoSortButton:SetSize(miog.C.ENTRY_FRAME_SIZE * 1.2, miog.C.ENTRY_FRAME_SIZE * 1.2)
	autoSortButton:RegisterForClicks("LeftButtonDown")
	autoSortButton:SetChecked(true)
	autoSortButton:SetScript("OnClick", function(self, leftButton)
		miog.defaultOptionSettings[3].value = autoSortButton:GetChecked()

		miog.saveCurrentSettings()

		miog.checkApplicantList(true, miog.defaultOptionSettings[3].value)
	end)
	autoSortButton:Show()

	local autoSortIcon = miog.persistentTexturePool:Acquire()
	autoSortIcon:SetDrawLayer("ARTWORK")
	autoSortIcon:SetSize(miog.C.ENTRY_FRAME_SIZE * 0.9, miog.C.ENTRY_FRAME_SIZE * 0.9)
	autoSortIcon:SetTexture(423814)
	autoSortIcon:SetPoint("LEFT", autoSortButton, "RIGHT", -4, 0)
	autoSortIcon:SetParent(settingScrollFrame)
	autoSortIcon:Show()

	local footerBar = miog.persistentFramePool:Acquire("BackdropTemplate")
	footerBar:SetPoint("TOPLEFT", miog.mainFrame, "BOTTOMLEFT", 0, 25)
	footerBar:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)
	footerBar:SetParent(miog.mainFrame)
	footerBar:Show()

	miog.mainFrame.footerBar = footerBar

	local browseGroups = miog.persistentFramePool:Acquire("UIPanelButtonTemplate")
	browseGroups:SetText("Browse Groups")
	browseGroups:SetSize(LFGListFrame.ApplicationViewer.BrowseGroupsButton:GetSize())
	browseGroups:SetPoint("TOPLEFT", miog.mainFrame.footerBar, "TOPLEFT", 0, 0)
	browseGroups:SetParent(miog.mainFrame.footerBar)
	browseGroups:RegisterForClicks("LeftButtonDown")
	browseGroups:SetScript("OnClick", function(self, leftButton)

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local baseFilters = LFGListFrame.baseFilters;
		local searchPanel = LFGListFrame.SearchPanel;
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		if(activeEntryInfo) then
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID);
			if(activityInfo) then
				LFGListSearchPanel_SetCategory(searchPanel, activityInfo.categoryID, activityInfo.filters, baseFilters);
				LFGListFrame_SetActivePanel(LFGListFrame, searchPanel);
				LFGListSearchPanel_DoSearch(searchPanel);
			end
		end
		
	end)
	browseGroups:Show()

	local editButton = miog.persistentFramePool:Acquire("UIPanelButtonTemplate")
	editButton:SetText("Edit")
	editButton:SetSize(LFGListFrame.ApplicationViewer.EditButton:GetSize())
	editButton:SetPoint("RIGHT", footerBar, "RIGHT", 0, 0)
	editButton:SetParent(miog.mainFrame.footerBar)
	editButton:RegisterForClicks("LeftButtonDown")
	editButton:SetScript("OnClick", function(self, leftButton)

		local entryCreation = LFGListFrame.EntryCreation;
		LFGListEntryCreation_SetEditMode(entryCreation, true);
		LFGListFrame_SetActivePanel(LFGListFrame, entryCreation);
		
	end)
	editButton:Show()
	
	local delistButton = miog.persistentFramePool:Acquire("UIPanelButtonTemplate")
	delistButton:SetText("Delist")
	delistButton:SetSize(LFGListFrame.ApplicationViewer.RemoveEntryButton:GetSize())
	delistButton:SetPoint("RIGHT", editButton, "LEFT", 0, 0)
	delistButton:SetParent(miog.mainFrame.footerBar)
	delistButton:RegisterForClicks("LeftButtonDown")
	delistButton:SetScript("OnClick", function(self, leftButton)

		C_LFGList.RemoveListing()
		
	end)
	delistButton:Show()

	local mainScrollFrame = miog.persistentFramePool:Acquire("BackdropTemplate, ScrollFrameTemplate")
	mainScrollFrame:SetParent(miog.mainFrame)
	mainScrollFrame:SetPoint("TOPLEFT", miog.mainFrame.infoPanel, "BOTTOMLEFT", 0, -2*miog.F.PX_SIZE_1())
	mainScrollFrame:SetPoint("BOTTOMRIGHT", miog.mainFrame.footerBar, "TOPRIGHT", 0, 0)
	mainScrollFrame:Show()

	miog.mainFrame.mainScrollFrame = mainScrollFrame

	local mainContainer = miog.persistentFramePool:Acquire("BackdropTemplate")
	mainContainer:SetSize(miog.mainFrame.mainScrollFrame:GetWidth(), miog.mainFrame.mainScrollFrame:GetHeight())
	mainContainer:SetPoint("TOP", miog.mainFrame.mainScrollFrame, "TOP", 0, 0)
	mainContainer:SetParent(miog.mainFrame.mainScrollFrame)
	mainContainer:Show()

	miog.mainFrame.mainScrollFrame.mainContainer = mainContainer

	miog.mainFrame.mainScrollFrame:SetScrollChild(miog.mainFrame.mainScrollFrame.mainContainer)

	local optionsFrame = miog.persistentFramePool:Acquire("BackdropTemplate")
	optionsFrame.name = "Mythic IO Grabber"
---@diagnostic disable-next-line: undefined-global --DEPRECATED
	InterfaceOptions_AddCategory(optionsFrame)
	
	local optionScrollFrame = miog.persistentFramePool:Acquire("BackdropTemplate, ScrollFrameTemplate")
	optionScrollFrame:SetParent(optionsFrame)
	optionScrollFrame:SetPoint("TOPLEFT", 3, -4)
	optionScrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)
	optionScrollFrame:Show()

	local optionsScrollChild = miog.persistentFramePool:Acquire("BackdropTemplate")
	optionScrollFrame:SetScrollChild(optionsScrollChild)
	optionsScrollChild:SetWidth(SettingsPanel.Container:GetWidth()-18)
	optionsScrollChild:SetHeight(1)
	optionsScrollChild:Show()

	local title = miog.persistentFontStringPool:Acquire()
	title:SetParent(optionsScrollChild)
	title:SetPoint("TOP", optionsScrollChild, "TOP", 0, 0)
	title:SetText("Mythic IO Grabber")
	title:Show()

	for index, setting in ipairs(miog.loadSettings()) do
		if(setting.type == "checkbox") then
			local button = miog.persistentFramePool:Acquire("UICheckButtonTemplate")
			button:SetParent(optionsScrollChild)
			button:SetPoint("TOPLEFT", optionsScrollChild, "TOPLEFT", 0, -miog.C.ENTRY_FRAME_SIZE*2 * index)
			button:SetSize(miog.C.ENTRY_FRAME_SIZE * 2, miog.C.ENTRY_FRAME_SIZE * 2)
			button:RegisterForClicks("LeftButtonDown")
			button:SetChecked(setting.value)
			button:SetScript("OnClick", function(self, leftButton, down)
				setting.value = not setting.value
				button:SetChecked(setting.value)

				miog.saveCurrentSettings()

				if(setting.key == "showActualSpecIcons" and setting.value == false) then
					C_UI.Reload()
				end

			end)
			button:Show()

			local buttonText = miog.persistentFontStringPool:Acquire()
			buttonText:SetParent(button)
			buttonText:SetPoint("LEFT", button, "RIGHT", 10, 0)
			buttonText:SetWordWrap(true)
			buttonText:SetNonSpaceWrap(true)
			buttonText:SetText(setting.title)
			buttonText:Show()
		end
	end
end

miog.mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
miog.mainFrame:RegisterEvent("PLAYER_LOGIN")
miog.mainFrame:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
miog.mainFrame:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
miog.mainFrame:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
miog.mainFrame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
miog.mainFrame:RegisterEvent("ADDON_LOADED")
miog.mainFrame:SetScript("OnEvent", miog.OnEvent)

miog.createMainFrame()