local addonName, miog = ...

MIOG_SavedSettings = MIOG_SavedSettings

local clearSignUpNote = LFGListApplicationDialog_Show
local clearEntryCreation = LFGListEntryCreation_Clear

local defaultOptionSettings = {
	newVersion = {
		type = "interal",
		title = "Newest version",
		access = "read",
		value = 200,
	},
	currentVersion = {
		type = "interal",
		title = "Currently used version",
		access = "read",
		value = 0, --SYNTAX VALUE, DOESN'T MATTER
	},
	frameExtended = {
		type = "variable",
		title = "Extend the mainframe",
		access = "read",
		value = false,
	},
	frameManuallyResized = {
		type = "variable",
		title = "Resized the mainframe via resize button",
		access = "read",
		value = 0,
	},
	activeSidePanel = {
		type = "variable",
		title = "Currently active sidepanel",
		access = "read",
		value = "",
	},
	resetAllSettings = {
		type = "button",
		title = "Reset all settings",
		access = "read,write",
	},
	keepSignUpNote = {
		type = "checkbox",
		title = "|cFFFFFF00(Experimental)|r Find a group: Don't discard the sign up not.|cFFFF0000 REQUIRES A RELOAD |r",
		value = true,
		access = "read",
		index = 6,
	},
	enableResultFrameClassSpecTooltip = {
		type = "checkbox",
		title = "(Search Panel) Enable/disable detailed tooltip information about a group listing (class and spec)",
		value = true,
		access = "read",
		index = 4,
	},
	keepInfoFromGroupCreation = {
		type = "checkbox",
		title = "|cFFFFFF00(Experimental)|r Start a group: Don't discard the info you've entered into the group creation fields.|cFFFF0000 REQUIRES A RELOAD |r",
		value = true,
		access = "read",
		index = 5,
	},
	mPlusStatistics = {
		type = "variable",
		title = "Mythic + Statistics for all your characters",
		access = "read",
		table = {},
	},
	pvpStatistics = {
		type = "variable",
		title = "PVP Statistics for all your characters",
		access = "read",
		table = {},
	},
	raidStatistics = {
		type = "variable",
		title = "Raid Statistics for all your characters",
		access = "read",
		table = {},
	},
	enableClassPanel = {
		type = "checkbox",
		title = "(Application Viewer) Enable the class panel for your group (shows class and spec data for your whole group after all inspects went through)",
		access = "read",
		value = true,
		index = 3,
	},
	liteMode = {
		type = "checkbox",
		title = "Enable/disable the lite mode of this addon (use Blizzards \"Dungeons and Raids\" Frame with this addon's frames layered on top)",
		access = "read",
		value = false,
		index = 1,
	},
	lastActiveSortingMethods = {
		type = "variable",
		title = "Last active sorting methods",
		access = "read",
	},
	backgroundOptions = {
		type = "dropdown",
		title = "Background options",
		access = "read",
		value = 10,
	},
	-- Name + Realm, time of last invite
	lastInvitedApplicants = {
		type = "variable",
		title = "Last invited applicants",
		access = "read",
		table = {}
	},
	-- Name + Realm
	favouredApplicants = {
		type = "checkbox,list",
		title = "(Side Panel) Enable favoured applicants (this also shows/hides the right click dropdown option).|cFFFF0000 REQUIRES A RELOAD |r",
		table = {},
		access = "read",
		value = true,
		index = 2,
	},
	lastGroup = {
		type = "variable",
		title = "Activity name of the last group you got invited to",
		access = "read",
		value = "",
	},
	filterOptions = {
		type = "variable",
		title = "Filter options for both the search panel and the application viewer",
		table = {
			default = {
				classSpec = {
					class = {},
					spec = {},
				},
				partyFit = false,
				ressFit = false,
				lustFit = false,
				filterForTanks = false,
				filterForHealers = false,
				filterForDamager = false,
				linkedTanks = false,
				linkedHealers = false,
				linkedDamager = false,
				filterForDifficulty = false,
				filterForScore = false,
				filterForActivities = true,
				filterForDungeons = true,
				filterForRaids = true,
				filterForRoles = {
					TANK = true,
					HEALER = true,
					DAMAGER = true,
				},
				filterForClassSpecs = true,
				minTanks = 0,
				maxTanks = 0,
				minHealers = 0,
				maxHealers = 0,
				minDamager = 0,
				maxDamager = 0,
				minScore = 0,
				maxScore = 0,
				difficultyID = 0,
				dungeons = {},
				raids = {},
				hardDecline = false,
				softDecline = false
			},
			["LFGListFrame.ApplicationViewer"] = nil,
			["LFGListFrame.SearchPanel"] = nil,
		},
		access = "read",
	},
	sortMethods_SearchPanel = {
		table = {
			primary = {
				currentLayer = 0,
				currentState = 0,
				active = false,
			},
			secondary = {
				currentLayer = 0,
				currentState = 0,
				active = false,
			},
			age = {
				currentLayer = 0,
				currentState = 0,
				active = false,
			},
			numberOfActiveMethods = 0,
		},
		type = "variable",
		access = "read",
		title = "Last active sorting methods for the search panel",
	},
	sortMethods_ApplicationViewer = {
		table = {
			role = {
				currentLayer = 0,
				currentState = 0,
				active = false,
			},
			primary = {
				currentLayer = 0,
				currentState = 0,
				active = false,
			},
			secondary = {
				currentLayer = 0,
				currentState = 0,
				active = false,
			},
			ilvl = {
				currentLayer = 0,
				currentState = 0,
				active = false,
			},
			numberOfActiveMethods = 0,
		},
		type = "variable",
		access = "read",
		title = "Last active sorting methods for the application viewer",
	},
	searchPanel_DeclinedGroups = {
		type = "variable",
		title = "Declined groups that are saved between loading screens / relogging",
		table = {},
		access = "read",
	},
	currentBlizzardFilters = {}
}

local function getBaseSettings(key)
	return defaultOptionSettings[key]
end

miog.getBaseSettings = getBaseSettings

miog.resetSpecificFilterToDefault = function(table)
	table = {}

	for k,v in pairs(defaultOptionSettings.filterOptions.table.default) do
		table[k] = v
	end

	return table
end

local function compareSettings()
	if(MIOG_SavedSettings.currentVersion == nil) then
		MIOG_SavedSettings = defaultOptionSettings
	end

	for key, optionEntry in pairs(MIOG_SavedSettings) do
		if(not defaultOptionSettings[key]) then
			MIOG_SavedSettings[key] = nil
		end
	end

	for key, optionEntry in pairs(defaultOptionSettings) do
		if(not MIOG_SavedSettings[key]) then
			MIOG_SavedSettings[key] = {}

			for k,v in pairs(optionEntry) do
				MIOG_SavedSettings[key][k] = v

			end

		elseif(MIOG_SavedSettings[key]) then
			
			if(MIOG_SavedSettings[key].title ~= optionEntry.title) then
				MIOG_SavedSettings[key].title = optionEntry.title
			end

			if(MIOG_SavedSettings[key].type ~= optionEntry.type) then
				MIOG_SavedSettings[key].type = optionEntry.type
			end

			if(MIOG_SavedSettings[key].index ~= optionEntry.index) then
				MIOG_SavedSettings[key].index = optionEntry.index

			end
			
			if(MIOG_SavedSettings[key].access ~= optionEntry.access) then
				MIOG_SavedSettings[key].access = optionEntry.access
				
			end

			if(MIOG_SavedSettings[key].access == "read,write") then
				MIOG_SavedSettings[key].table = optionEntry.table
				MIOG_SavedSettings[key].value = optionEntry.value
				MIOG_SavedSettings[key].table = optionEntry.table

			else
				if(optionEntry.table) then
					MIOG_SavedSettings[key].table = MIOG_SavedSettings[key].table or {}

					for tableKey, tableEntry in pairs(optionEntry.table) do
						if(not MIOG_SavedSettings[key].table[tableKey]) then
							MIOG_SavedSettings[key].table[tableKey] = tableEntry
		
						end
					end
				end
			end
		end
	end

	if(MIOG_SavedSettings.currentVersion.value < 200) then

	end

	MIOG_SavedSettings.currentVersion.value = defaultOptionSettings.newVersion.value
end

--https://github.com/0xbs/premade-groups-filter/commit/e31067e0ec1d1345dabc3de4c9282cc33c9aa18c courtesy of PGF
---@diagnostic disable-next-line: duplicate-set-field --overwriting Blizzard function
C_LFGList.GetPlaystyleString = function(playstyle, activityInfo)
    if not ( activityInfo and playstyle and playstyle ~= 0
            and C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID).showPlaystyleDropdown ) then
        return nil
    end
    local globalStringPrefix
    if activityInfo.isMythicPlusActivity then
        globalStringPrefix = "GROUP_FINDER_PVE_PLAYSTYLE"
    elseif activityInfo.isRatedPvpActivity then
        globalStringPrefix = "GROUP_FINDER_PVP_PLAYSTYLE"
    elseif activityInfo.isCurrentRaidActivity then
        globalStringPrefix = "GROUP_FINDER_PVE_RAID_PLAYSTYLE"
    elseif activityInfo.isMythicActivity then
        globalStringPrefix = "GROUP_FINDER_PVE_MYTHICZERO_PLAYSTYLE"
    end
    return globalStringPrefix and _G[globalStringPrefix .. tostring(playstyle)] or nil
end

LFGListEntryCreation_SetTitleFromActivityInfo = function(_) end

local function keepInfoFromGroupCreation(self)
	--Clear selections
	self.selectedGroup = nil;
	self.selectedActivity = nil;
	self.selectedFilters = nil;
	self.selectedCategory = nil;
	self.selectedPlaystyle = nil;

	--Reset widgets
	--C_LFGList.ClearCreationTextFields();
	--self.ItemLevel.CheckButton:SetChecked(false);
	--self.ItemLevel.EditBox:SetText("");
	--self.PvpItemLevel.CheckButton:SetChecked(false);
	--self.PvpItemLevel.EditBox:SetText("");
	--self.PVPRating.CheckButton:SetChecked(false);
	--self.PVPRating.EditBox:SetText("");
	--self.MythicPlusRating.CheckButton:SetChecked(false);
	--self.MythicPlusRating.EditBox:SetText("");
	--self.VoiceChat.CheckButton:SetChecked(false);
	--self.VoiceChat.EditBox:SetText(""); --Cleared in ClearCreationTextFields
	--self.PrivateGroup.CheckButton:SetChecked(false);
	--self.CrossFactionGroup.CheckButton:SetChecked(false);

	self.ActivityFinder:Hide();
end

local function keepSignUpNote(self, resultID)
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

	if(searchResultInfo) then

		self.resultID = resultID
		self.activityID = searchResultInfo.activityID

		LFGListApplicationDialog_UpdateRoles(self)
		StaticPopupSpecial_Show(self)
	end
end

miog.checkForSavedSettings = function()
	if(not MIOG_SavedSettings) then
		MIOG_SavedSettings = defaultOptionSettings

	else
		compareSettings()

	end
	
	MIOG_SavedSettings.timestamp = {
		type = "interal",
		title = "Timestamp of last setting save",
		value = time(),
		visual = date("%d/%m/%y %H:%M:%S")
	}

end

miog.loadSettings = function()
	miog.convertAdvancedBlizzardFiltersToMIOGFilters()

	local titleFrame = miog.createBasicFrame("persistent", "BackdropTemplate", miog.interfaceOptionsPanel, SettingsPanel.Container:GetWidth(), 20, "FontString", 20)
	titleFrame:SetPoint("TOP", miog.interfaceOptionsPanel, "TOP", 0, 0)
	titleFrame.FontString:SetText("Mythic IO Grabber")
	titleFrame.FontString:SetJustifyH("CENTER")
	
	local resetButton = CreateFrame("Button", nil, miog.interfaceOptionsPanel, "UIPanelButtonNoTooltipTemplate")
	resetButton:SetPoint("TOPRIGHT", miog.interfaceOptionsPanel, "TOPRIGHT", 0, 0)
	resetButton:SetText("Reset all settings")
	resetButton:FitToText()
	resetButton:SetScript("OnClick", function()
		MIOG_SavedSettings = nil
		C_UI.Reload()
	end)
	resetButton:Show()
	
	local optionPanel = miog.createBasicFrame("persistent", "ScrollFrameTemplate", miog.interfaceOptionsPanel)
	optionPanel:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, 0)
	optionPanel:SetSize(SettingsPanel.Container:GetWidth(), SettingsPanel.Container:GetHeight())
	miog.ApplicationViewer.optionPanel = optionPanel

	local optionPanelContainer = miog.createBasicFrame("persistent", "BackdropTemplate", optionPanel)
	optionPanelContainer:SetSize(optionPanel:GetWidth(), optionPanel:GetHeight() - titleFrame:GetHeight())
	optionPanelContainer:SetPoint("TOPLEFT", optionPanel, "TOPLEFT", 0, 0)
	optionPanel.container = optionPanelContainer
	optionPanel:SetScrollChild(optionPanelContainer)

	local lastOption = nil

	local orderedList = {}

	for key, setting in pairs(MIOG_SavedSettings) do
		if(setting.index) then
			orderedList[setting.index] = key

		end
	end

	for index, key in ipairs(orderedList) do
		local setting = MIOG_SavedSettings[key]
			for settingTypes in string.gmatch(setting.type, '([^,]+)') do
				if(settingTypes == "checkbox") then
					local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", optionPanelContainer, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
					optionButton:SetNormalAtlas("checkbox-minimal")
					optionButton:SetPushedAtlas("checkbox-minimal")
					optionButton:SetCheckedTexture("checkmark-minimal")
					optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
					optionButton:SetPoint("TOPLEFT", lastOption or optionPanelContainer, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
					optionButton:RegisterForClicks("LeftButtonDown")
					optionButton:SetChecked(setting.value)

					if(key == "keepSignUpNote") then

						optionButton:SetScript("OnClick", function()
							setting.value = not setting.value

							if(setting.value == true) then
								LFGListApplicationDialog_Show = keepSignUpNote

							else
								LFGListApplicationDialog_Show = clearSignUpNote

							end

							C_UI.Reload()
						end)
					elseif(key == "keepInfoFromGroupCreation") then

						optionButton:SetScript("OnClick", function()
							setting.value = not setting.value

							if(setting.value == true) then
								LFGListEntryCreation_Clear = keepInfoFromGroupCreation

							else
								LFGListEntryCreation_Clear = clearEntryCreation
								

							end

							C_UI.Reload()
						end)

					elseif(key == "enableResultFrameClassSpecTooltip") then
						optionButton:SetScript("OnClick", function()
							setting.value = not setting.value
						end)
						
					elseif(key == "enableClassPanel") then

						optionButton:SetScript("OnClick", function()
							setting.value = not setting.value
							miog.ApplicationViewer.ClassPanel:SetShown(setting.value)
							miog.ApplicationViewer.ClassPanel:MarkDirty()

						end)

						miog.ApplicationViewer.ClassPanel:SetShown(setting.value)

					elseif(key == "favouredApplicants") then
						optionButton:SetScript("OnClick", function()
							setting.value = not setting.value

							C_UI.Reload()
						end)

					elseif(key == "liteMode") then
						optionButton:SetScript("OnClick", function()
							setting.value = not setting.value

							miog.F.LITE_MODE = setting.value

							C_UI.Reload()
						end)

					end

					local optionButtonString = miog.createBasicFontString("persistent", 10, optionButton)
					optionButtonString:SetWidth(optionPanelContainer:GetWidth() - optionButton:GetWidth() - 15)
					optionButtonString:SetPoint("LEFT", optionButton, "RIGHT", 10, 0)
					optionButtonString:SetText(setting.title)

					optionButtonString:SetWordWrap(true)
					optionButtonString:SetNonSpaceWrap(true)

					lastOption = optionButton
				end
			end
		--end
	end

	if(MIOG_SavedSettings["backgroundOptions"]) then
		local backgroundOptionString = miog.createBasicFontString("persistent", 12, optionPanelContainer)
		backgroundOptionString:SetPoint("TOPLEFT", lastOption or optionPanelContainer, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
		backgroundOptionString:SetText(MIOG_SavedSettings["backgroundOptions"].title)
		backgroundOptionString:SetWordWrap(true)
		backgroundOptionString:SetNonSpaceWrap(true)

		local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", optionPanelContainer)
		optionDropdown:SetPoint("TOPLEFT", backgroundOptionString, "BOTTOMLEFT", 0, -5)
		UIDropDownMenu_SetWidth(optionDropdown, 200)

		UIDropDownMenu_SetText(optionDropdown, miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][1])
		UIDropDownMenu_Initialize(optionDropdown,
			function(frame, level, menuList)
				local info = UIDropDownMenu_CreateInfo()
				info.func = function(_, arg1, _, _)
					MIOG_SavedSettings["backgroundOptions"].value = arg1
					miog.MainFrame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png")
					miog.LastInvites.Panel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. "_small.png")
					UIDropDownMenu_SetText(optionDropdown, miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][1])
					CloseDropDownMenus()

				end

				for k, v in ipairs(miog.EXPANSION_INFO) do
					if(v[1]) then
						info.text, info.arg1 = v[1], k
						info.checked = k == MIOG_SavedSettings["backgroundOptions"].value
						UIDropDownMenu_AddButton(info)

					end
				end
			end
		)
		
		miog.MainFrame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png")
		miog.LastInvites.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png")
		miog.FilterPanel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png", "REPEAT", "REPEAT")

		lastOption = optionDropdown
	end
	
	if(MIOG_SavedSettings["favouredApplicants"] and MIOG_SavedSettings["favouredApplicants"].value == true) then
		hooksecurefunc("UIDropDownMenu_Initialize", miog.addFavouredButtonsToUnitPopup)

		local favouredApplicantsPanel = miog.createBasicFrame("persistent", "BackdropTemplate", optionPanelContainer, 250, 140)
		favouredApplicantsPanel:SetPoint("TOPLEFT", lastOption or optionPanelContainer, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
		miog.createFrameBorder(favouredApplicantsPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		favouredApplicantsPanel.standardHeight = 140

		optionPanelContainer.favouredApplicantsPanel = favouredApplicantsPanel

		local favouredApplicantsScrollFrame = miog.createBasicFrame("persistent", "ScrollFrameTemplate", favouredApplicantsPanel)
		favouredApplicantsScrollFrame:SetPoint("TOPLEFT", favouredApplicantsPanel, "TOPLEFT", 1, 0)
		favouredApplicantsScrollFrame:SetPoint("BOTTOMRIGHT", favouredApplicantsPanel, "BOTTOMRIGHT", -2, 1)
		favouredApplicantsPanel.scrollFrame = favouredApplicantsScrollFrame

		local favouredApplicantsContainer = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", favouredApplicantsScrollFrame)
		favouredApplicantsContainer.fixedWidth = favouredApplicantsPanel:GetWidth()
		favouredApplicantsContainer.minimumHeight = 1
		favouredApplicantsContainer.spacing = 3
		favouredApplicantsContainer.align = "top"
		favouredApplicantsContainer:SetPoint("TOPLEFT", favouredApplicantsScrollFrame, "TOPLEFT")

		favouredApplicantsScrollFrame.container = favouredApplicantsContainer
		favouredApplicantsScrollFrame:SetScrollChild(favouredApplicantsContainer)

		for _, v in pairs(MIOG_SavedSettings["favouredApplicants"].table) do
			miog.addFavouredApplicant(v)

		end

		lastOption = favouredApplicantsPanel
	end
	
	if(MIOG_SavedSettings.sortMethods_ApplicationViewer and MIOG_SavedSettings.sortMethods_ApplicationViewer.table) then
		for sortKey, row in pairs(MIOG_SavedSettings.sortMethods_ApplicationViewer.table) do
			if(miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons[sortKey]) then
				if(row.active == true) then
					miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons[sortKey]:SetState(MIOG_SavedSettings.sortMethods_ApplicationViewer.table[sortKey].active, MIOG_SavedSettings.sortMethods_ApplicationViewer.table[sortKey].currentState)
					miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons[sortKey].FontString:SetText(MIOG_SavedSettings.sortMethods_ApplicationViewer.table[sortKey].currentLayer)

				else
					miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons[sortKey]:SetState(false)

				end
			end
		end
	else
		MIOG_SavedSettings.sortMethods_ApplicationViewer.table = {}

	end
	
	if(MIOG_SavedSettings.sortMethods_SearchPanel and MIOG_SavedSettings.sortMethods_SearchPanel.table) then
		for sortKey, row in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do
			if(miog.SearchPanel.ButtonPanel.sortByCategoryButtons[sortKey]) then
				if(row.active == true) then
					miog.SearchPanel.ButtonPanel.sortByCategoryButtons[sortKey]:SetState(MIOG_SavedSettings.sortMethods_SearchPanel.table[sortKey].active, MIOG_SavedSettings.sortMethods_SearchPanel.table[sortKey].currentState)
					miog.SearchPanel.ButtonPanel.sortByCategoryButtons[sortKey].FontString:SetText(MIOG_SavedSettings.sortMethods_SearchPanel.table[sortKey].currentLayer)

				else
					miog.SearchPanel.ButtonPanel.sortByCategoryButtons[sortKey]:SetState(false)

				end
			end
		end
	else
		MIOG_SavedSettings.sortMethods_SearchPanel.table = {}

	end

	if(MIOG_SavedSettings.keepSignUpNote and MIOG_SavedSettings.keepSignUpNote.value ==  true) then
		LFGListApplicationDialog_Show = keepSignUpNote

	else
		LFGListApplicationDialog_Show = clearSignUpNote

	end

	if(MIOG_SavedSettings.keepInfoFromGroupCreation and MIOG_SavedSettings.keepInfoFromGroupCreation.value ==  true) then
		LFGListEntryCreation_Clear = keepInfoFromGroupCreation
	else
		LFGListEntryCreation_Clear = clearEntryCreation
	end

	if(MIOG_SavedSettings.disableBackgroundImages and MIOG_SavedSettings.disableBackgroundImages.value ==  true) then
		miog.MainFrame.Background:SetShown(false)

	else
		miog.MainFrame.Background:SetShown(true)
	
	end

	if(MIOG_SavedSettings.lastInvitedApplicants) then
		for k, v in pairs(MIOG_SavedSettings.lastInvitedApplicants.table) do
			if(v.timestamp and difftime(time(), v.timestamp) < 259200) then
				miog.addLastInvitedApplicant(v)

			else
				MIOG_SavedSettings.lastInvitedApplicants.table[k] = nil
			
			end

		end

	end

	if(MIOG_SavedSettings.searchPanel_DeclinedGroups and MIOG_SavedSettings.searchPanel_DeclinedGroups.table) then
		for k, v in pairs(MIOG_SavedSettings.searchPanel_DeclinedGroups.table) do
			if(v.timestamp < time() - 900) then
				MIOG_SavedSettings.searchPanel_DeclinedGroups.table[k] = nil
				
			end
		end

	end
end

function MIOG_OpenInterfaceOptions()
	Settings.OpenToAddonCategory("MythicIOGrabber")
end