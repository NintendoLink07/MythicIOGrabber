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
	if(miog.ProgressPanel and IsPlayerAtEffectiveMaxLevel()) then
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

	end

	if(miog.ApplicationViewer and panel == LFGListFrame.ApplicationViewer) then
		if(UnitIsGroupLeader("player")) then
			miog.ApplicationViewer.Delist:Show()
			miog.ApplicationViewer.Edit:Show()

		else
			miog.ApplicationViewer.Delist:Hide()
			miog.ApplicationViewer.Edit:Hide()
			
		end

		miog.ApplicationViewer:Show()

	elseif(panel == LFGListFrame.SearchPanel) then
		miog.SearchPanel:Show()

	elseif(panel == LFGListFrame.EntryCreation) then
		miog.EntryCreation:Show()

		if(miog.F.LITE_MODE) then
			miog.initializeActivityDropdown()

		end

	elseif(panel == "RaiderIOChecker") then
		miog.RaiderIOChecker:Show()

	else
		miog.Plugin:Hide()

	end

	if(miog.FilterManager) then
		if((miog.ApplicationViewer and panel == LFGListFrame.ApplicationViewer) or (miog.SearchPanel and panel == LFGListFrame.SearchPanel)) then
			setProgressPanelInfo(miog.getCurrentCategoryID())

			miog.FilterManager:Show()
			miog.filter.refreshFilters()
		else
			miog.FilterManager:Hide()
			miog.ProgressPanel:Hide()

		end
	end
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

	local settingsButton = CreateFrame("Button", nil, nil, "UIButtonTemplate")
	settingsButton:SetSize(19, 19)
	settingsButton:SetNormalAtlas("QuestLog-icon-setting")
	settingsButton:SetHighlightAtlas("QuestLog-icon-setting")
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
	miog.ClassPanel = miog.createClassPanel()
	miog.FilterManager = miog.loadFilterManager()
	
	miog.loadInspectManagement()

	if(MIOG_NewSettings.reQueue) then
		--miog.loadReQueue()
		miog.loadRequeue()
	end

	if(not miog.F.LITE_MODE) then
		miog.loadQueueSystem()
		--miog.loadCalendarSystem()
		miog.loadGearingTable()
		miog.loadGroupManager()
		miog.loadRaidPlanner()
		miog.loadActivityChecker()

		miog.Drops = miog.loadJournal()
		miog.UpgradeFinder = miog.loadUpgradeFinder()
	end

	hooksecurefunc("LFGListFrame_SetActivePanel", function(_, panel)
		setActivePanel(_, panel)
	end)

	panels = {
		miog.ApplicationViewer,
		miog.SearchPanel,
		miog.EntryCreation,
	}
end