local addonName, miog = ...

MIOG_SavedSettings = MIOG_SavedSettings

local clearSignUpNote = LFGListApplicationDialog_Show
local clearEntryCreation = LFGListEntryCreation_Clear

miog.getSetting = function(name, subname, subSubName)
	return subSubName and MIOG_SavedSettings[name].table[subname][subSubName] or subname and MIOG_SavedSettings[name].table[subname] or MIOG_SavedSettings[name]
end

local defaultOptionSettings = {
	newVersion = {
		type = "interal",
		title = "Newest version",
		value = 200,
	},
	currentVersion = {
		type = "interal",
		title = "Currently used version",
		value = 0, --SYNTAX VALUE, DOESN'T MATTER
	},
	resetSortSettings = {
		type = "button",
		title = "Reset all sorting settings (if sorting somehow isn't working anymore).|cFFFF0000 REQUIRES A RELOAD |r",
		index = 7,
	},
	frameExtended = {
		type = "variable",
		title = "Extend the mainframe",
		value = false,
	},
	frameManuallyResized = {
		type = "variable",
		title = "Resized the mainframe via resize button",
		value = 0,
	},
	activeSidePanel = {
		type = "variable",
		title = "Currently active sidepanel",
		value = "",
	},
	resetAllSettings = {
		type = "extraButton",
		title = "Reset all settings",
	},
	keepSignUpNote = {
		type = "checkbox",
		title = "|cFFFFFF00(Experimental)|r Find a group: Don't discard the sign up not.|cFFFF0000 REQUIRES A RELOAD |r",
		value = true,
		index = 6,
	},
	enableResultFrameClassSpecTooltip = {
		type = "checkbox",
		title = "(Search Panel) Enable/disable detailed tooltip information about a group listing (class and spec)",
		value = true,
		index = 4,
	},
	keepInfoFromGroupCreation = {
		type = "checkbox",
		title = "|cFFFFFF00(Experimental)|r Start a group: Don't discard the info you've entered into the group creation fields.|cFFFF0000 REQUIRES A RELOAD |r",
		value = true,
		index = 5,
	},
	mPlusStatistics = {
		type = "variable",
		title = "Mythic + Statistics for all your characters",
		table = {},
	},
	pvpStatistics = {
		type = "variable",
		title = "PVP Statistics for all your characters",
		table = {},
	},
	raidStatistics = {
		type = "variable",
		title = "Raid Statistics for all your characters",
		table = {},
	},
	enableClassPanel = {
		type = "checkbox",
		title = "(Application Viewer) Enable the class panel for your group (shows class and spec data for your whole group after all inspects went through)",
		value = true,
		index = 3,
	},
	liteMode = {
		type = "checkbox",
		title = "Enable/disable the lite mode of this addon (use Blizzards \"Dungeons and Raids\" Frame with this addon's frames layered on top)",
		value = false,
		index = 1,
	},
	lastActiveSortingMethods = {
		type = "variable",
		title = "Last active sorting methods",
	},
	backgroundOptions = {
		type = "dropdown",
		title = "Background options",
		value = 10,
	},
	guildKeystoneInfo = {
		type = "variable",
		title = "Guild keystone info",
		table = {}
	},
	-- Name + Realm, time of last invite
	lastInvitedApplicants = {
		type = "variable",
		title = "Last invited applicants",
		table = {}
	},
	-- Name + Realm
	favouredApplicants = {
		type = "checkbox,list",
		title = "(Side Panel) Enable favoured applicants (this also shows/hides the right click dropdown option).|cFFFF0000 REQUIRES A RELOAD |r",
		table = {},
		value = true,
		index = 2,
	},
	lastGroup = {
		type = "variable",
		title = "Activity name of the last group you got invited to",
		value = "",
	},
	lastReset = {
		type = "variable",
		title = "Last reset",
		value = 0
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
				affixFit = false,
				filterForTanks = false,
				filterForHealers = false,
				filterForDamager = false,
				linkedTanks = false,
				linkedHealers = false,
				linkedDamager = false,
				filterForDifficulty = false,
				filterForRating = false,
				filterForAge = false,
				filterForBossKills = false,
				filterForActivities = false,
				filterForDungeons = false,
				filterForRaids = false,
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
				minRating = 0,
				maxRating = 0,
				minAge = 0,
				maxAge = 0,
				minBossKills = 0,
				maxBossKills = 0,
				difficultyID = 0,
				dungeons = {},
				raids = {},
				raidBosses = {},
				hardDecline = false,
				softDecline = false,
				needsMyClass = true
			},
			["LFGListFrame.ApplicationViewer"] = {},
			["LFGListFrame.SearchPanel"] = {},
		},
	},
	sortMethods = {
		table = {
			partyCheck = {
				group = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				shortName = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				role = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				specID = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				ilvl = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				durability = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				keylevel = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				score = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				progressWeight = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
			},
			searchPanel = {
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
			},
			applicationViewer = {
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
			},
			guild = {
				level = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				rank = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				class = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				keystone = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				keylevel = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				score = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
				progressWeight = {
					currentLayer = 0,
					currentState = 0,
					active = false,
				},
			}
		},
		type = "variable",
		title = "Currently active sort algorithms, each with settings",
	},
	searchPanel_DeclinedGroups = {
		type = "variable",
		title = "Declined groups that are saved between loading screens / relogging",
		table = {},
	},
	currentBlizzardFilters = {}
}

miog.defaultOptionSettings = defaultOptionSettings

local function getBaseSettings(key)
	return defaultOptionSettings[key]
end

miog.getBaseSettings = getBaseSettings

miog.getDefaultFilters = function()
	local table = {}

	for k, v in pairs(defaultOptionSettings.filterOptions.table.default) do
		table[k] = v
	end

	return table
end

local function compareSettings()
	if(MIOG_SavedSettings.currentVersion == nil) then
		MIOG_SavedSettings = defaultOptionSettings
	end
	
	if(MIOG_SavedSettings.lastReset.value < C_DateAndTime.GetSecondsUntilWeeklyReset()) then
		MIOG_SavedSettings.guildKeystoneInfo = nil
		MIOG_SavedSettings.lastReset.value = C_DateAndTime.GetSecondsUntilWeeklyReset()

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

			if(optionEntry.table) then
				MIOG_SavedSettings[key].table = MIOG_SavedSettings[key].table or {}

				for tableKey, tableEntry in pairs(optionEntry.table) do
					if(not MIOG_SavedSettings[key].table[tableKey]) then
						MIOG_SavedSettings[key].table[tableKey] = tableEntry

					else
						if(type(tableEntry) == "table") then
							for innerTableKey, innerTableEntry in pairs(tableEntry) do
								if(not MIOG_SavedSettings[key].table[tableKey][innerTableKey]) then
									MIOG_SavedSettings[key].table[tableKey][innerTableKey] = innerTableEntry

								else
									if(type(innerTableEntry) == "table") then
										for innererTableKey, innererTableEntry in pairs(innerTableEntry) do
											if(not MIOG_SavedSettings[key].table[tableKey][innerTableKey][innererTableKey]) then
												MIOG_SavedSettings[key].table[tableKey][innerTableKey][innererTableKey] = innererTableEntry
											else
											
											end
										end
									end
								end
							end
						end
					end
				end

				if(key == "sortMethods") then
					for tableKey, tableEntry in pairs(MIOG_SavedSettings[key].table) do
						if(defaultOptionSettings[key].table[tableKey] == nil) then
							MIOG_SavedSettings[key].table[tableKey] = nil

						else
							if(type(tableEntry) == "table") then
								for innerTableKey, innerTableEntry in pairs(tableEntry) do
									if(defaultOptionSettings[key].table[tableKey][innerTableKey] == nil) then
										MIOG_SavedSettings[key].table[tableKey][innerTableKey] = nil
										
									else
										if(type(innerTableEntry) == "table") then
											for innererTableKey, innererTableEntry in pairs(innerTableEntry) do
												if(defaultOptionSettings[key].table[tableKey][innerTableKey][innererTableKey] == nil) then
													MIOG_SavedSettings[key].table[tableKey][innerTableKey][innererTableKey] = nil
												
												end
											end
										end
									end
								end
							end
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

--/run MIOG_SavedSettings.sortMethods.table.searchPanel.numberOfActiveMethods = 99

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
	if(resultID) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		if(searchResultInfo) then

			self.resultID = resultID
			self.activityID = searchResultInfo.activityID

			LFGListApplicationDialog_UpdateRoles(self)
			StaticPopupSpecial_Show(self)
		end
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

				elseif(key == "enableClassPanel" and not miog.F.LITE_MODE and miog.ClassPanel) then
					optionButton:SetScript("OnClick", function()
						setting.value = not setting.value
						miog.ClassPanel:SetShown(setting.value)

					end)

					miog.ClassPanel:SetShown(setting.value)

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
			elseif(settingTypes == "button") then
				local button = CreateFrame("Button", nil, miog.interfaceOptionsPanel, "UIPanelButtonNoTooltipTemplate")
				button:SetPoint("TOPLEFT", lastOption or optionPanelContainer, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
				button:SetText("Reset sorting settings")
				button:FitToText()
				
				if(key == "resetSortSettings") then
					button:SetScript("OnClick", function()
						MIOG_SavedSettings.sortMethods = nil

						C_UI.Reload()
					end)
				end
						
				button:Show()

				lastOption = button
			end
		end
	end

	if(MIOG_SavedSettings["backgroundOptions"]) then
		local backgroundOptionString = miog.createBasicFontString("persistent", 12, optionPanelContainer)
		backgroundOptionString:SetPoint("TOPLEFT", lastOption or optionPanelContainer, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
		backgroundOptionString:SetText(MIOG_SavedSettings["backgroundOptions"].title)
		backgroundOptionString:SetWordWrap(true)
		backgroundOptionString:SetNonSpaceWrap(true)

		local optionDropdown = Mixin(CreateFrame("Frame", "MythicIOGrabber_BackgroundDropdown", optionPanelContainer, "MIOG_DropDownMenu"), SlickDropDown)
		optionDropdown:OnLoad()
		--local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", optionPanelContainer)
		optionDropdown:SetPoint("TOPLEFT", backgroundOptionString, "BOTTOMLEFT", 0, -5)
		optionDropdown:SetSize(200, 20)

		for k, v in ipairs(miog.EXPANSION_INFO) do
			if(v[1]) then
				local info = {}
				info.text = v[1]
				info.checked = k == MIOG_SavedSettings["backgroundOptions"].value
				info.value = k
				info.index = k
				info.func = function()
					MIOG_SavedSettings["backgroundOptions"].value = k
					miog.MainFrame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png")
					miog.LastInvites.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. "_small.png")
					miog.FilterPanel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png", "REPEAT", "REPEAT")
					
					if(miog.AdventureJournal) then
						miog.AdventureJournal.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png", "REPEAT", "REPEAT")
					end
				end

				optionDropdown:CreateEntryFrame(info)
			end
		end

		optionDropdown.List:MarkDirty()

		optionDropdown:SelectFirstFrameWithValue(miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][1])
		
		miog.MainFrame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png")
		miog.LastInvites.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png")
		miog.FilterPanel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png", "REPEAT", "REPEAT")
		
		if(miog.AdventureJournal) then
			miog.AdventureJournal.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[MIOG_SavedSettings["backgroundOptions"].value][2] .. ".png", "REPEAT", "REPEAT")
		end

		lastOption = optionDropdown
	end
	
	if(MIOG_SavedSettings["favouredApplicants"] and MIOG_SavedSettings["favouredApplicants"].value == true) then
		hooksecurefunc("UIDropDownMenu_Initialize", miog.addFavouredButtonsToUnitPopup)
		local scrollBox = miog.loadFavouredPlayersPanel(optionPanelContainer, lastOption)

		for _, v in pairs(MIOG_SavedSettings.favouredApplicants.table) do
			miog.addFavouredPlayer(v)

		end

		miog.refreshFavouredPlayers()

		lastOption = scrollBox
	end

	for k, v in pairs(MIOG_SavedSettings.sortMethods.table) do
		local buttonArray = k == "applicationViewer" and miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons
		or k == "searchPanel" and miog.SearchPanel.ButtonPanel.sortByCategoryButtons
		or k == "partyCheck" and miog.PartyCheck and miog.PartyCheck.sortByCategoryButtons
		or k == "guild" and miog.Guild and miog.Guild.sortByCategoryButtons

		if(buttonArray) then
			for sortKey, row in pairs(v) do
				if(buttonArray[sortKey]) then
					if(row.active == true) then
						buttonArray[sortKey]:SetState(row.active, row.currentState)
						buttonArray[sortKey].FontString:SetText(row.currentLayer)

					else
						buttonArray[sortKey]:SetState(false)

					end
				end
			end
		end
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
				miog.addInvitedPlayer(v)

			else
				MIOG_SavedSettings.lastInvitedApplicants.table[k] = nil
			
			end

		end

		miog.refreshLastInvites()

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