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
		local isDungeon = categoryID == 2
		local isRaid = categoryID == 3
		local isCorrectCategory = isDungeon or isRaid

		miog.ProgressPanel:SetShown(isCorrectCategory)

		if(isCorrectCategory) then
			miog.ProgressPanel.MythicPlus:SetShown(isDungeon)
			miog.ProgressPanel.Raids:SetShown(isRaid)

			local playerName, realm = miog.createSplitName(UnitFullName("player"))
			
			miog.ProgressPanel:Flush()
			miog.ProgressPanel:SetPlayerData(playerName, realm)
			miog.ProgressPanel:ApplySpecificFillDataOnly(isDungeon and "mplus" or "raid")

		end
	else
		miog.ProgressPanel:Hide()

	end
end

local activePanel

local function getActivePanel()
	return activePanel
end

miog.getActivePanel = getActivePanel

local function setActivePanel(_, panel)
	for k, v in pairs(panels) do
		if(v) then
			v:Hide()

		end
	end

	if(panel == LFGListFrame.ApplicationViewer) then
		if(UnitIsGroupLeader("player")) then
			miog.ApplicationViewer.ActivityBar.Delist:SetEnabled(true)
			miog.ApplicationViewer.ActivityBar.Edit:SetEnabled(true)

		else
			miog.ApplicationViewer.ActivityBar.Delist:SetEnabled(false)
			miog.ApplicationViewer.ActivityBar.Edit:SetEnabled(false)
			
		end

		miog.ApplicationViewer:Show()
		miog.Plugin:Hide()
	else
		miog.Plugin:Show()

		if(panel == LFGListFrame.SearchPanel) then
			miog.SearchPanel:Show()

		elseif(panel == LFGListFrame.EntryCreation) then
			miog.EntryCreation:Show()

			if(miog.F.LITE_MODE) then
				miog.initializeActivityDropdown()

			end
		else
			miog.Plugin:Hide()

		end

	end

	if(miog.FilterManager) then
		if(panel == LFGListFrame.ApplicationViewer or panel == LFGListFrame.SearchPanel) then
			if(miog.ProgressPanel) then
				setProgressPanelInfo(miog.getCurrentCategoryID())

			end

			miog.FilterManager:Show()

			miog.filter.refreshFilters()
		else
			miog.FilterManager:Hide()
			miog.ProgressPanel:Hide()

		end
	end

	activePanel = panel
	
	miog.pveFrame2.anchorNewScrollBar(1)
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
		miog.Plugin:SetPoint("BOTTOMRIGHT", miog.pveFrame2.Currency, "TOPRIGHT", -20, 5)
		miog.Plugin:SetFrameStrata("HIGH")

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

	miog.createFrameBorder(miog.Plugin.FooterBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	miog.Plugin.FooterBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.MainFrame = miog.F.LITE_MODE and miog.Plugin or miog.pveFrame2

	
	--miog.ApplicationViewer = miog.createApplicationViewer()
	miog.SearchPanel = miog.createSearchPanel()
	miog.EntryCreation = miog.createEntryCreation()
	miog.FilterManager = miog.loadFilterManager()
	
	--miog.loadInspectManagement()

	--miog.loadRequeue()

	if(not miog.F.LITE_MODE) then
		--miog.loadQueueSystem()
		--miog.loadCalendarSystem()
		miog.loadTeleports()
		miog.loadGearingTable()
		--miog.loadGroupManager()
		miog.loadGroupOrganizer()
		miog.loadRaidPlanner()
		miog.loadActivityChecker()

		miog.Drops = miog.loadJournal()
		miog.UpgradeFinder = miog.loadUpgradeFinder()

		--miog.loot.init()
	end


	miog.changeTheme()

	hooksecurefunc("LFGListFrame_SetActivePanel", function(_, panel)
		setActivePanel(_, panel)
	end)

	panels = {
		miog.ApplicationViewer,
		miog.SearchPanel,
		miog.EntryCreation,
	}
end