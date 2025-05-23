local addonName, miog = ...
local wticc = WrapTextInColorCode

local panels

--[[
    Function: setActivePanel
    Description: Manages the visibility and behavior of addon panels based on the active panel.
    Parameters:
        _ (any) - Unused argument, part of the hook signature.
        panel (table/string) - The panel to activate and display.
]]
local function setProgressPanelInfo(categoryID)
	if(IsPlayerAtEffectiveMaxLevel()) then
		miog.ProgressPanel:SetShown(categoryID == 2 or categoryID == 3)

		miog.ProgressPanel.MythicPlus:SetShown(categoryID == 2)
		miog.ProgressPanel.Raids:SetShown(categoryID == 3)

		miog.ProgressPanel.Background:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID])

		local playerName, realm = miog.createSplitName(UnitFullName("player"))
		
		miog.ProgressPanel:Flush()
		miog.ProgressPanel:SetPlayerData(playerName, realm)
		miog.ProgressPanel:ApplyFillData()
		
	else
		miog.ProgressPanel:Hide()

	end
end

local function setActivePanel(_, panel)
	for k, v in pairs(panels) do
		if(v) then
			v:Hide()

		end
	end

	miog.Plugin:Show()

	if(miog.F.LITE_MODE and panel ~= LFGListFrame.CategorySelection) then
		panel:Hide()

	elseif(panel == LFGListFrame.ApplicationViewer or panel == LFGListFrame.SearchPanel) then
		miog.Plugin.ButtonPanel:Hide()

		if(MIOG_NewSettings.activeSidePanel == "filter") then
			miog.NewFilterPanel.Lock:Hide()
			miog.NewFilterPanel:Show()
			
			miog.ProgressPanel:SetPoint("TOPLEFT", miog.NewFilterPanel, "BOTTOMLEFT", 0, -5)
			miog.ProgressPanel:SetPoint("TOPRIGHT", miog.NewFilterPanel, "BOTTOMRIGHT", 0, -5)

		elseif(MIOG_NewSettings.activeSidePanel == "invites") then
			miog.LastInvites:Show()

			miog.ProgressPanel:ClearAllPoints()
			miog.ProgressPanel:SetPoint("TOPLEFT", miog.LastInvites, "BOTTOMLEFT", 0, -5)

		else
			miog.NewFilterPanel:Hide()
			miog.Plugin.ButtonPanel:Show()

			miog.ProgressPanel:ClearAllPoints()
			miog.ProgressPanel:SetPoint("TOPLEFT", miog.Plugin.ButtonPanel, "BOTTOMLEFT", 0, -4)
		
		end
	end

	if(panel == LFGListFrame.ApplicationViewer or panel == LFGListFrame.SearchPanel) then
		setProgressPanelInfo(miog.getCurrentCategoryID())

	else
		miog.ProgressPanel:Hide()

	end

	if(panel == LFGListFrame.ApplicationViewer) then
		miog.ApplicationViewer:Show()

		if(UnitIsGroupLeader("player")) then
			miog.ApplicationViewer.Delist:Show()
			miog.ApplicationViewer.Edit:Show()

		else
			miog.ApplicationViewer.Delist:Hide()
			miog.ApplicationViewer.Edit:Hide()
			
		end

	elseif(panel == LFGListFrame.SearchPanel) then
		miog.SearchPanel:Show()

	elseif(panel == LFGListFrame.EntryCreation) then
		miog.NewFilterPanel.Lock:Show()
		miog.EntryCreation:Show()

		if(miog.F.LITE_MODE) then
			miog.initializeActivityDropdown()

		end

	elseif(panel == "RaiderIOChecker") then
		miog.RaiderIOChecker:Show()
		miog.NewFilterPanel.Lock:Show()

	else
		miog.Plugin:Hide()
		miog.NewFilterPanel.Lock:Show()

	end
	
	miog.setupFilterPanel()
end

miog.setActivePanel = setActivePanel

--[[
    Function: createFrames
    Description: Initializes and configures the addon UI elements and panels.
]]
miog.createFrames = function()
	-- Preload the encounter journal so any function in the addon doesn't have to always check if the journal is loaded
	EncounterJournal_LoadUI()

	-- OnOpen usually generates an error and doesn't really do anything important, so mask it with a dummy function
	C_EncounterJournal.OnOpen = miog.dummyFunction

	local settingsButton = CreateFrame("Button")
	settingsButton:SetSize(20, 20)
	settingsButton:SetNormalTexture("Interface/Addons/MythicIOGrabber/res/infoIcons/settingGear.png")
	settingsButton:SetScript("OnClick", function()
		MIOG_OpenInterfaceOptions()
	end)

	if(miog.F.LITE_MODE == true) then
		miog.Plugin = CreateFrame("Frame", "MythicIOGrabber_PluginFrame", LFGListFrame, "MIOG_Plugin")
		miog.Plugin:SetPoint("TOPLEFT", PVEFrameLeftInset, "TOPRIGHT")
		miog.Plugin:SetSize(LFGListFrame:GetWidth(), LFGListFrame:GetHeight() - PVEFrame.TitleContainer:GetHeight() - 7)
		miog.Plugin:SetFrameStrata("HIGH")

		settingsButton:SetParent(PVEFrame)
		settingsButton:SetFrameStrata("HIGH")
		settingsButton:SetPoint("RIGHT", PVEFrameCloseButton, "LEFT", -2, 0)
	else
		miog.createPVEFrameReplacement()
		miog.Plugin = CreateFrame("Frame", "MythicIOGrabber_PluginFrame", miog.MainTab, "MIOG_Plugin")
		miog.Plugin:SetPoint("TOPLEFT", miog.MainTab.QueueInformation, "TOPRIGHT", 0, 0)
		miog.Plugin:SetPoint("TOPRIGHT", miog.MainTab, "TOPRIGHT", 0, 0)
		miog.Plugin:SetHeight(miog.pveFrame2:GetHeight() - miog.pveFrame2.TitleBar:GetHeight() - 5 - miog.MainTab.Currency:GetHeight())

		miog.createFrameBorder(miog.Plugin, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		miog.Plugin:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

		--PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")
		--PVEFrame_ShowFrame("PVPUIFrame", "ConquestFrame")
		PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")

		settingsButton:SetParent(miog.pveFrame2.TitleBar)
		settingsButton:SetPoint("RIGHT", miog.pveFrame2.TitleBar.CloseButton, "LEFT", -2, 0)

		miog.pveFrame2.TitleBar.BlizzardFrame:SetPoint("RIGHT", settingsButton, "LEFT", -2, 0)
	end

	miog.Plugin:SetScript("OnEnter", function()
	
	end)
	
	miog.Plugin.ButtonPanel.FilterButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		miog.Plugin.ButtonPanel:Hide()

		miog.LastInvites:Hide()
		miog.NewFilterPanel:Show()

		miog.ProgressPanel:SetPoint("TOPLEFT", miog.NewFilterPanel, "BOTTOMLEFT", 0, -5)
		miog.ProgressPanel:SetPoint("TOPRIGHT", miog.NewFilterPanel, "BOTTOMRIGHT", 0, -5)

		MIOG_NewSettings.activeSidePanel = "filter"

		if(LFGListFrame.activePanel ~= LFGListFrame.SearchPanel and LFGListFrame.activePanel ~= LFGListFrame.ApplicationViewer) then
			miog.NewFilterPanel.Lock:Show()

		else
			miog.NewFilterPanel.Lock:Hide()
		
		end
	end)

	miog.Plugin.ButtonPanel.LastInvitesButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		miog.Plugin.ButtonPanel:Hide()

		MIOG_NewSettings.activeSidePanel = "invites"

		miog.LastInvites:Show()
		miog.NewFilterPanel:Hide()

		miog.ProgressPanel:SetPoint("TOPLEFT", miog.LastInvites, "BOTTOMLEFT", 0, -5)
	end)

	miog.createFrameBorder(miog.Plugin.ButtonPanel.FilterButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.Plugin.ButtonPanel.FilterButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.createFrameBorder(miog.Plugin.ButtonPanel.LastInvitesButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.Plugin.ButtonPanel.LastInvitesButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.Plugin.Resize:SetScript("OnDragStop", function(self)
		self:GetParent():StopMovingOrSizing()

		MIOG_NewSettings.manualResize = miog.Plugin:GetHeight()

		miog.Plugin:ClearAllPoints()
		miog.Plugin:SetPoint("TOPLEFT", miog.MainTab.QueueInformation, "TOPRIGHT", 0, 0)
		miog.Plugin:SetPoint("TOPRIGHT", miog.MainTab, "TOPRIGHT", 0, 0)
	end)

	miog.Plugin:SetResizeBounds(miog.Plugin:GetWidth(), miog.Plugin:GetHeight(), miog.Plugin:GetWidth(), GetScreenHeight() * 0.67)
	miog.Plugin:SetHeight(MIOG_NewSettings.manualResize > 0 and MIOG_NewSettings.manualResize or miog.Plugin:GetHeight())

	miog.createFrameBorder(miog.Plugin.FooterBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.Plugin.FooterBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.MainFrame = miog.F.LITE_MODE and miog.Plugin or miog.pveFrame2
	miog.MainFrame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_NewSettings.backgroundOptions][2] .. ".png")

	miog.ApplicationViewer = miog.createApplicationViewer()
	miog.SearchPanel = miog.createSearchPanel()
	miog.EntryCreation = miog.createEntryCreation()
	miog.NewFilterPanel = miog.loadNewFilterPanel()
	miog.LastInvites = miog.loadLastInvitesPanel()
	miog.ClassPanel = miog.createClassPanel()
	
	local progressPanel = CreateFrame("Frame", "ProgressPanel", miog.Plugin, "MIOG_ProgressPanel")
	miog.createFrameBorder(progressPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	miog.ProgressPanel = progressPanel
	
	miog.loadInspectManagement()

	if(MIOG_NewSettings.reQueue) then
		miog.loadReQueue()

	end

	if(not miog.F.LITE_MODE) then
		miog.loadQueueSystem()
		miog.loadCalendarSystem()
		miog.loadGearingTable()
		miog.loadGroupManager()
		miog.loadRaidPlanner()
		miog.loadActivityChecker()

		miog.Journal = miog.loadJournal()
		miog.UpgradeFinder = miog.loadUpgradeFinder()
	end

	hooksecurefunc("LFGListFrame_SetActivePanel", function(_, panel)
		setActivePanel(_, panel)
	end)

	panels = {
		miog.ApplicationViewer,
		miog.SearchPanel,
		miog.EntryCreation,
		miog.RaiderIOChecker,
		miog.ProgressPanel,
		miog.DropChecker,
	}
end