local addonName, miog = ...

miog.mainFrame = CreateFrame("Frame", "MythicIOGrabber_MainFrame", LFGListFrame, "InsetFrameTemplate")

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
	miog.mainFrame:SetSize(LFGListFrame:GetWidth() + 5, LFGListPVEStub:GetHeight() - PVEFrame.TitleContainer:GetHeight() - 5)
	miog.mainFrame.expanded = false
	miog.mainFrame:SetPoint(LFGListFrame.ApplicationViewer:GetPoint())
	miog.mainFrame:AdjustPointsOffset(-5, -PVEFrame.TitleContainer:GetHeight()-1)
	miog.mainFrame:RegisterForDrag("LeftButton")
	miog.mainFrame:SetMovable(true)
	miog.mainFrame:SetFrameStrata("HIGH")
	miog.mainFrame:EnableMouse(true)
	miog.mainFrame:RegisterForDrag("LeftButton")
	miog.mainFrame:Hide()

	_G[miog.mainFrame:GetName()] = miog.mainFrame
	tinsert(UISpecialFrames, miog.mainFrame:GetName())

    local pveFrameTab1_Point = insertPointsIntoTable(PVEFrameTab1)

	local titleBar = miog.persistentFramePool:Acquire("BackdropTemplate")
	titleBar:SetPoint("TOPLEFT", miog.mainFrame, "TOPLEFT", 0, 0)
	titleBar:SetPoint("BOTTOMRIGHT", miog.mainFrame, "TOPRIGHT", 0, -25)
	titleBar:SetParent(miog.mainFrame)
	titleBar:SetFrameStrata("DIALOG")
	--miog.createFrameBorder(titleBar)
	titleBar:Show()
	miog.mainFrame.titleBar = titleBar

	miog.F.FACTION_ICON_SIZE = titleBar:GetHeight() - 2

	local titleString = miog.persistentFontStringPool:Acquire()
	titleString:SetFont(miog.fonts["libMono"], 14, "OUTLINE")
	titleString:SetPoint("LEFT", titleBar, "LEFT", miog.C.PADDING_OFFSET*2, -miog.C.PADDING_OFFSET)
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
	faction:SetPoint("RIGHT", titleBar, "RIGHT", -1, -2)
	faction:SetSize(titleBar:GetHeight()*2, titleBar:GetHeight())
	faction:SetParent(titleBar)
	faction:Show()
	miog.mainFrame.titleBar.faction = faction

	local affixes = miog.persistentFontStringPool:Acquire()
	affixes:SetFont(miog.fonts["libMono"], 22, "OUTLINE")
	affixes:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", -2, -3)
	affixes:SetParent(titleBar)
	affixes:SetText(miog.getAffixes())
	affixes:Show()
	miog.mainFrame.affixes = affixes

	local resetButton = miog.persistentFramePool:Acquire("BigRedRefreshButtonTemplate")
	resetButton:ClearAllPoints()
	resetButton:SetSize(PVEFrameCloseButton:GetHeight() or titleBar:GetHeight(), PVEFrameCloseButton:GetHeight() or titleBar:GetHeight(), 1, 1)
	resetButton:SetPoint("RIGHT", PVEFrameCloseButton, "LEFT", -1, 0)
	resetButton:SetParent(titleBar)
	resetButton:SetScript("OnClick",
		function()
			--miog.checkApplicantList(true, true)
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

	--hooksecurefunc(C_LFGList, "Search", function(...) local cat, filt1, filt2, languages = ... DevTools_Dump(languages) end)

	expandDownwardsButton:Show()
	miog.mainFrame.expandDownwardsButton = expandDownwardsButton

	local voiceChat = LFGListFrame.ApplicationViewer.VoiceChatFrame
	voiceChat:ClearAllPoints()
	voiceChat:SetPoint("RIGHT", faction, "LEFT", -2, 0)
	voiceChat:SetParent(titleBar)
	miog.mainFrame.titleBar.voiceChat = voiceChat

	local settingScrollFrame = miog.persistentFramePool:Acquire("BackdropTemplate, ScrollFrameTemplate")
	settingScrollFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -5)
	settingScrollFrame:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", -affixes:GetWidth(), -70)
	settingScrollFrame:SetParent(miog.mainFrame)
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
	settingContainer:SetFrameStrata("FULLSCREEN")
	settingContainer:SetParent(settingScrollFrame)
	settingContainer:Show()
	--miog.createFrameBorder(settingContainer)


	settingScrollFrame:SetScrollChild(settingContainer)
	miog.mainFrame.settingScrollFrame.settingContainer = settingContainer

	local settingString = miog.persistentFontStringPool:Acquire()
	settingString:SetFont(miog.fonts["libMono"], miog.C.SETTING_FONT_SIZE, "THICK")
	settingString:SetPoint("TOPLEFT", settingContainer, "TOPLEFT", miog.C.PADDING_OFFSET*3, -miog.C.PADDING_OFFSET)
	--settingString:SetPoint("BOTTOMRIGHT", settingContainer, "BOTTOMRIGHT", -miog.C.PADDING_OFFSET*3, -miog.C.PADDING_OFFSET*3)
	settingString:SetWidth(settingContainer:GetWidth() - miog.C.PADDING_OFFSET*3)
	settingString:SetParent(settingContainer)
	settingString:SetJustifyV("TOP")
	settingString:SetJustifyH("LEFT")
	settingString:SetSpacing(3.1)
	settingString:SetWordWrap(true)
	settingString:SetNonSpaceWrap(true)
	settingString:Show()
	miog.mainFrame.settingScrollFrame.settingContainer.settingString = settingString

	local statusBar = miog.persistentFramePool:Acquire("BackdropTemplate")
	statusBar:SetPoint("TOPLEFT", settingScrollFrame, "BOTTOMLEFT", 0, 0)
	statusBar:SetPoint("BOTTOMRIGHT", settingScrollFrame, "BOTTOMRIGHT", 5, -25)
	statusBar:SetParent(miog.mainFrame)
	statusBar:SetFrameStrata("DIALOG")
	--createFrameBorder(statusBar)
	statusBar:Show()

	miog.mainFrame.statusBar = statusBar

	local timerString = miog.persistentFontStringPool:Acquire()
	timerString:SetFont(miog.fonts["libMono"], 18, "OUTLINE")
	timerString:SetPoint("LEFT", statusBar, "LEFT", miog.C.PADDING_OFFSET*2, 0)
	timerString:SetParent(statusBar)
	timerString:SetJustifyV("CENTER")
	timerString:Show()
	miog.mainFrame.statusBar.timerString = timerString

	if not(IsAddOnLoaded("RaiderIO")) then
		local rioLoaded = miog.persistentFontStringPool:Acquire()
		rioLoaded:SetFont(miog.fonts["libMono"], 18, "OUTLINE")
		rioLoaded:SetPoint("TOPLEFT", timerString, "TOPRIGHT", 5, 0)
		rioLoaded:SetParent(statusBar)
		rioLoaded:SetJustifyH("LEFT")
		rioLoaded:SetText(WrapTextInColorCode("NO RAIDER IO", miog.C.RED_COLOR))
		rioLoaded:Show()
		miog.mainFrame.statusBar.rioLoaded = rioLoaded
	end

	local showDPSButton = miog.persistentFramePool:Acquire("UICheckButtonTemplate")
	showDPSButton:SetParent(statusBar)
	showDPSButton:SetPoint("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT", 0, 0)
	showDPSButton:SetSize(miog.C.ENTRY_FRAME_SIZE * 1.2, miog.C.ENTRY_FRAME_SIZE * 1.2)
	showDPSButton:RegisterForClicks("LeftButtonDown")
	showDPSButton:SetChecked(true)
	showDPSButton:SetScript("OnClick", function(self, leftButton)
		miog.F.SHOW_DPS = not miog.F.SHOW_DPS

		miog.checkApplicantList(true, miog.F.IS_LIST_SORTED)
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

		miog.checkApplicantList(true, miog.F.IS_LIST_SORTED)
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

		miog.checkApplicantList(true, miog.F.IS_LIST_SORTED)
	end)
	showTanksButton:Show()

	for i = 1, 3, 1 do
		local roleTexture = miog.persistentTexturePool:Acquire()
		roleTexture:SetDrawLayer("OVERLAY")
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

	--[[

2175177	interface/encounterjournal/dungeonjournaltierbackgrounds1.blp		
2175180	interface/encounterjournal/dungeonjournaltierbackgrounds2.blp		
2175183	interface/encounterjournal/dungeonjournaltierbackgrounds3.blp		
2175186	interface/encounterjournal/dungeonjournaltierbackgrounds4.blp
3054898	interface/auctionframe/auctionhousebackgrounds.blp
4748832	interface/covenantrenown/dragonflightmajorfactionsexpeditionbackground.blp

	]]

	local footerBar = miog.persistentFramePool:Acquire("BackdropTemplate")
	footerBar:SetPoint("TOPLEFT", miog.mainFrame, "BOTTOMLEFT", 0, 25)
	footerBar:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)
	footerBar:SetParent(miog.mainFrame)

	miog.mainFrame.footerBar = footerBar

	local mainScrollFrame = miog.persistentFramePool:Acquire("BackdropTemplate, ScrollFrameTemplate")
	mainScrollFrame:SetParent(miog.mainFrame)
	mainScrollFrame:SetPoint("TOPLEFT", miog.mainFrame.statusBar, "BOTTOMLEFT", 0, 0)
	mainScrollFrame:SetPoint("BOTTOMRIGHT", miog.mainFrame.footerBar, "TOPRIGHT", 0, 0)

	--mainScrollFrame.ScrollBar:Hide()
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
		local button = miog.persistentFramePool:Acquire("UICheckButtonTemplate")
		button:SetParent(optionsScrollChild)
		button:SetPoint("TOPLEFT", optionsScrollChild, "TOPLEFT", 0, -miog.C.ENTRY_FRAME_SIZE*2 * index)
		button:SetSize(miog.C.ENTRY_FRAME_SIZE * 2, miog.C.ENTRY_FRAME_SIZE * 2)
		button:RegisterForClicks("LeftButtonDown")
		button:SetChecked(setting.value)
		button:SetScript("OnClick", function(self, leftButton, down)
			setting.value = not setting.value
			button:SetChecked(setting.value)

			SavedOptionSettings = miog.defaultOptionSettings

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

    miog.relocateBlizzardElements()
end

miog.relocateBlizzardElements = function()
	local browseGroups = LFGListFrame.ApplicationViewer.BrowseGroupsButton
	browseGroups:ClearAllPoints()
	browseGroups:SetParent(miog.mainFrame)
	browseGroups:SetPoint("TOPLEFT", miog.mainFrame.footerBar, "TOPLEFT", 0, 0)

	miog.mainFrame.footerBar.browseGroups = browseGroups

	local delistButton = LFGListFrame.ApplicationViewer.RemoveEntryButton
	delistButton:ClearAllPoints()
	delistButton:SetParent(miog.mainFrame)
	delistButton:SetPoint("LEFT", miog.mainFrame.footerBar.browseGroups, "RIGHT", 0, 0)
	
	miog.mainFrame.footerBar.delistButton = delistButton

	local editButton = LFGListFrame.ApplicationViewer.EditButton
	editButton:ClearAllPoints()
	editButton:SetParent(miog.mainFrame)
	editButton:SetPoint("LEFT", miog.mainFrame.footerBar.delistButton, "RIGHT", 0, 0)

	miog.mainFrame.footerBar.editButton = editButton
	
	local infoBackground = LFGListFrame.ApplicationViewer.InfoBackground
	infoBackground:ClearAllPoints()
	infoBackground:SetDrawLayer("BACKGROUND")
	infoBackground:SetParent(miog.mainFrame.settingScrollFrame)
	infoBackground:SetWidth(miog.mainFrame.titleBar:GetWidth())
	infoBackground:SetPoint("TOP", miog.mainFrame.titleBar, "BOTTOM", 0, 0)

	miog.mainFrame.statusBar.infoBackground = infoBackground
end

miog.mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
miog.mainFrame:RegisterEvent("PLAYER_LOGIN")
miog.mainFrame:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
miog.mainFrame:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
miog.mainFrame:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
miog.mainFrame:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
miog.mainFrame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
miog.mainFrame:SetScript("OnEvent", miog.OnEvent)