local addonName, miog = ...

MIOG_SavedSettings = MIOG_SavedSettings

local clearSignUpNote = LFGListApplicationDialog_Show
local clearEntryCreation = LFGListEntryCreation_Clear

local defaultOptionSettings = {
	frameExtended = {
		type = "variable",
		title = "Extend the mainframe",
		access = "read,write",
		value = false,
	},
	frameManuallyResized = {
		type = "variable",
		title = "Resized the mainframe via resize button",
		access = "read,write",
		value = 0,
	},
	keepSignUpNote = {
		type = "checkbox",
		title = "|cFFFFFF00(Experimental)|r Find a group: Don't discard the sign up not.|cFFFF0000 REQUIRES A RELOAD |r",
		value = true,
		access = "read,write",
	},
	keepInfoFromGroupCreation = {
		type = "checkbox",
		title = "|cFFFFFF00(Experimental)|r Start a group: Don't discard the info you've entered into the group creation fields.|cFFFF0000 REQUIRES A RELOAD |r",
		value = true,
		access = "read,write",
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
	enableClassPanel = {
		type = "checkbox",
		title = "Enable the class panel for your group (shows class and spec data for your whole group after all inspects went through)",
		access = "read,write",
		value = true,
	},
	lastActiveSortingMethods = {
		type = "variable",
		title = "Last active sorting methods",
		access = "read,write",
	},
	backgroundOptions = {
		type = "dropdown",
		title = "Background options",
		access = "read,write",
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
		title = "Enable favoured applicants (this also shows/hides the right click dropdown option).|cFFFF0000 REQUIRES A RELOAD |r",
		table = {},
		access = "read",
		value = true,
	},
	applicationViewer_FilterOptions = {
		type = "variable",
		title = "Filter options for the application viewer",
		table = {
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
			filterForDungeonDifficulty = false,
			filterForRaidDifficulty = false,
			filterForArenaBracket = false,
			filterForScore = false,
			filterForRoles = {
				TANK = true,
				HEALER = true,
				DAMAGER = true,
			},
			filterForClassSpecs = false,

			minTanks = 0,
			maxTanks = 0,
			minHealers = 0,
			maxHealers = 0,
			minDamager = 0,
			maxDamager = 0,
			minScore = 0,
			maxScore = 0,
			dungeonDifficultyID = 4,
			raidDifficultyID = 3,
			bracketID = 1,
			dungeons = {},
			filterForDungeons = false,
		},
		access = "read",
	},
	searchPanel_FilterOptions = {
		type = "variable",
		title = "Filter options for the search panel",
		table = {
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
			filterForDungeonDifficulty = false,
			filterForRaidDifficulty = false,
			filterForArenaBracket = false,
			filterForScore = false,
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
			dungeonDifficultyID = 4,
			raidDifficultyID = 3,
			bracketID = 1,
			dungeons = {},
			raids = {},
			filterForDungeons = false,
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

local function compareSettings()
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
			
			if(MIOG_SavedSettings[key].access ~= optionEntry.access) then
				MIOG_SavedSettings[key].access = optionEntry.access
				
			end

			if(MIOG_SavedSettings[key].access == "read,write") then
				MIOG_SavedSettings[key].table = optionEntry.table
				MIOG_SavedSettings[key].value = optionEntry.value

			else
				MIOG_SavedSettings[key].table = MIOG_SavedSettings[key].table or {}

				if(optionEntry.table) then
					for tableKey, tableEntry in pairs(optionEntry.table) do
						if(not MIOG_SavedSettings[key].table[tableKey]) then
							MIOG_SavedSettings[key].table[tableKey] = tableEntry
		
						end
					end
				end
			end
		end
	end
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
	
	local optionPanel = miog.createBasicFrame("persistent", "ScrollFrameTemplate", miog.interfaceOptionsPanel)
	optionPanel:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, 0)
	optionPanel:SetSize(SettingsPanel.Container:GetWidth(), SettingsPanel.Container:GetHeight())
	miog.applicationViewer.optionPanel = optionPanel

	local optionPanelContainer = miog.createBasicFrame("persistent", "BackdropTemplate", optionPanel)
	optionPanelContainer:SetSize(optionPanel:GetWidth(), optionPanel:GetHeight() - titleFrame:GetHeight())
	optionPanelContainer:SetPoint("TOPLEFT", optionPanel, "TOPLEFT")
	optionPanel.container = optionPanelContainer
	optionPanel:SetScrollChild(optionPanelContainer)

	local lastOption = nil

	for key, setting in pairs(MIOG_SavedSettings) do
		if(setting.type) then
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
					elseif(key == "enableClassPanel") then

						optionButton:SetScript("OnClick", function()
							setting.value = not setting.value
							miog.applicationViewer.ClassPanel:SetShown(setting.value)
							miog.applicationViewer.ClassPanel:MarkDirty()

						end)

						miog.applicationViewer.ClassPanel:SetShown(setting.value)

					elseif(key == "favouredApplicants") then
						optionButton:SetScript("OnClick", function()
							setting.value = not setting.value

							C_UI.Reload()
						end)

					end

					local optionButtonString = miog.createBasicFontString("persistent", 12, optionButton)
					optionButtonString:SetWidth(optionPanelContainer:GetWidth() - optionButton:GetWidth() - 15)
					optionButtonString:SetPoint("LEFT", optionButton, "RIGHT", 10, 0)
					optionButtonString:SetText(setting.title)

					optionButtonString:SetWordWrap(true)
					optionButtonString:SetNonSpaceWrap(true)

					lastOption = optionButton

				elseif(settingTypes == "dropdown") then
					if(key == "backgroundOptions") then
						local backgroundOptionString = miog.createBasicFontString("persistent", 12, optionPanelContainer)
						backgroundOptionString:SetPoint("TOPLEFT", lastOption or optionPanelContainer, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
						backgroundOptionString:SetText(setting.title)
						backgroundOptionString:SetWordWrap(true)
						backgroundOptionString:SetNonSpaceWrap(true)

						local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", optionPanelContainer)
						optionDropdown:SetPoint("TOPLEFT", backgroundOptionString, "BOTTOMLEFT", 0, -5)
						UIDropDownMenu_SetWidth(optionDropdown, 200)

						UIDropDownMenu_SetText(optionDropdown, miog.EXPANSION_INFO[setting.value][1])
						UIDropDownMenu_Initialize(optionDropdown,
							function(frame, level, menuList)
								local info = UIDropDownMenu_CreateInfo()
								info.func = function(_, arg1, _, _)
									setting.value = arg1
									miog.pveFrame2.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[setting.value][2] .. ".png")
									miog.pveFrame2.SidePanel.Container.LastInvites.Panel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[setting.value][2] .. "_small.png")
									UIDropDownMenu_SetText(optionDropdown, miog.EXPANSION_INFO[setting.value][1])
									CloseDropDownMenus()
				
								end

								for k, v in ipairs(miog.EXPANSION_INFO) do
									if(v[1]) then
										info.text, info.arg1 = v[1], k
										info.checked = k == setting.value
										UIDropDownMenu_AddButton(info)

									end
								end
							end
						)
						
						miog.pveFrame2.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[setting.value][2] .. ".png")
						miog.pveFrame2.SidePanel.Container.LastInvites.Panel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[setting.value][2] .. "_small.png")

						lastOption = optionDropdown
					end
				elseif(settingTypes == "list") then
					if(key == "favouredApplicants" and setting.value == true) then
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

						for _, v in pairs(setting.table) do
							miog.addFavouredApplicant(v)

						end
				
						lastOption = favouredApplicantsPanel
					end
				end
			end
		end
	end
	
	if(MIOG_SavedSettings.sortMethods_ApplicationViewer and MIOG_SavedSettings.sortMethods_ApplicationViewer.table) then
		for sortKey, row in pairs(MIOG_SavedSettings.sortMethods_ApplicationViewer.table) do
			if(miog.applicationViewer.ButtonPanel.sortByCategoryButtons[sortKey]) then
				if(row.active == true) then
					miog.applicationViewer.ButtonPanel.sortByCategoryButtons[sortKey]:SetState(MIOG_SavedSettings.sortMethods_ApplicationViewer.table[sortKey].active, MIOG_SavedSettings.sortMethods_ApplicationViewer.table[sortKey].currentState)
					miog.applicationViewer.ButtonPanel.sortByCategoryButtons[sortKey].FontString:SetText(MIOG_SavedSettings.sortMethods_ApplicationViewer.table[sortKey].currentLayer)

				else
					miog.applicationViewer.ButtonPanel.sortByCategoryButtons[sortKey]:SetState(false)

				end
			end
		end
	else
		MIOG_SavedSettings.sortMethods_ApplicationViewer.table = {}

	end
	
	if(MIOG_SavedSettings.sortMethods_SearchPanel and MIOG_SavedSettings.sortMethods_SearchPanel.table) then
		for sortKey, row in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do
			if(miog.searchPanel.ButtonPanel.sortByCategoryButtons[sortKey]) then
				if(row.active == true) then
					miog.searchPanel.ButtonPanel.sortByCategoryButtons[sortKey]:SetState(MIOG_SavedSettings.sortMethods_SearchPanel.table[sortKey].active, MIOG_SavedSettings.sortMethods_SearchPanel.table[sortKey].currentState)
					miog.searchPanel.ButtonPanel.sortByCategoryButtons[sortKey].FontString:SetText(MIOG_SavedSettings.sortMethods_SearchPanel.table[sortKey].currentLayer)

				else
					miog.searchPanel.ButtonPanel.sortByCategoryButtons[sortKey]:SetState(false)

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
		miog.pveFrame2.Background:SetShown(false)

	else
		miog.pveFrame2.Background:SetShown(true)
	
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