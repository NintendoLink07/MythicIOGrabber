local addonName, miog = ...

MIOG_SavedSettings = MIOG_SavedSettings

local clearSignUpNote = LFGListApplicationDialog_Show
local clearEntryCreation = LFGListEntryCreation_Clear

local function compareSettings(defaultOptions, savedSettings)
	for key, optionEntry in pairs(defaultOptions) do
		if(not savedSettings[key]) then
			savedSettings[key] = {}
			for k,v in pairs(optionEntry) do
				savedSettings[key][k] = v
			end
		else
			if(savedSettings[key].title ~= optionEntry.title) then
				savedSettings[key].title = optionEntry.title

			elseif(savedSettings[key].type ~= optionEntry.type) then
				savedSettings[key].type = optionEntry.type

			else
				if(savedSettings[key].type == "dropdown") then
					savedSettings[key].table = optionEntry.table

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

	self.resultID = resultID
	self.activityID = searchResultInfo.activityID

	LFGListApplicationDialog_UpdateRoles(self)
	StaticPopupSpecial_Show(self)
end

local function sortSettingsAlphabetically()

	local sortedTable = {}

	for keyString, setting in pairs(MIOG_SavedSettings) do
		setting.key = keyString
		table.insert(sortedTable, setting)
	end

	table.sort(sortedTable, function(k1, k2) return (k1.title or "") < (k2.title or "") end)

	return sortedTable
end

miog.loadSettings = function()
    miog.defaultOptionSettings = {
		disableBackgroundImages = {
			type = "checkbox",
			title = "Hide the background image and some background colors (mainly for ElvUI users)",
			value = false,
		},
		frameExtended = {
			type = "variable",
			title = "Extend the mainframe",
			value = false,
		},
		keepSignUpNote = {
			type = "checkbox",
			title = "|cFFFFFF00(Experimental)|r Find a group: Don't discard the sign up note",
			value = true,
		},
		keepInfoFromGroupCreation = {
			type = "checkbox",
			title = "|cFFFFFF00(Experimental)|r Start a group: Don't discard the info you've entered into the group creation fields",
			value = true,
		},
		enableClassPanel = {
			type = "checkbox",
			title = "Enable the class panel for your group (shows class and spec data for your whole group after all inspects went through)",
			value = true,
		},
		lastActiveSortingMethods = {
			type = "variable",
			title = "Last active sorting methods",
		},
		backgroundOptions = {
			type = "dropdown",
			title = "Background options",
			table = {
				[1] = {"Standard", "lfg-background_tall_1024.png"},
				[2] = {"Vanilla", "vanilla-bg-1.png"},
				[3] = {"The Burning Crusade", "tbc-bg-1.png"},
				[4] = {"Wrath of the Lich King", "wotlk-bg-1.png"},
				[5] = {"Cataclysm", "cata-bg-1.png"},
				[6] = {"Mists of Pandaria", "mop-bg-1.png"},
				[7] = {"Warlords of Draenor", "wod-bg-1.png"},
				[8] = {"Legion", "legion-bg-1.png"},
				[9] = {"Battle for Azeroth", "bfa-bg-1.png"},
				[10] = {"Shadowlands", "sl-bg-1.png"},
				[11] = {"Dragonflight", "df-bg-1.png"},
			},
			value = 11
		}
	}

	if(not MIOG_SavedSettings) then
		MIOG_SavedSettings = miog.defaultOptionSettings
	else
		compareSettings(miog.defaultOptionSettings, MIOG_SavedSettings)
	end
	
	MIOG_SavedSettings.datestamp = {
		type = "interal",
		title = "Datestamp of last setting save",
		value = date("%d/%m/%y %H:%M:%S")
	}

	local interfaceOptionsPanel = miog.createBasicFrame("persistent", "BackdropTemplate", nil)
	interfaceOptionsPanel.name = "Mythic IO Grabber"

	local category, layout = Settings.RegisterCanvasLayoutCategory(interfaceOptionsPanel, interfaceOptionsPanel.name, interfaceOptionsPanel.name)
	category.ID = interfaceOptionsPanel.name
	Settings.RegisterAddOnCategory(category)

	miog.interfaceOptionsPanel = interfaceOptionsPanel

	local titleFrame = miog.createBasicFrame("persistent", "BackdropTemplate", interfaceOptionsPanel, SettingsPanel.Container:GetWidth(), 20, "FontString", 20)
	titleFrame:SetPoint("TOP", interfaceOptionsPanel, "TOP", 0, 0)
	titleFrame.FontString:SetText("Mythic IO Grabber")
	titleFrame.FontString:SetJustifyH("CENTER")
	
	local optionPanel = miog.createBasicFrame("persistent", "ScrollFrameTemplate", interfaceOptionsPanel)
	optionPanel:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, 0)
	optionPanel:SetSize(SettingsPanel.Container:GetWidth(), SettingsPanel.Container:GetHeight())
	miog.mainFrame.optionPanel = optionPanel

	local optionPanelContainer = miog.createBasicFrame("persistent", "BackdropTemplate", optionPanel)
	optionPanelContainer:SetSize(optionPanel:GetWidth(), optionPanel:GetHeight() - titleFrame:GetHeight())
	optionPanelContainer:SetPoint("TOPLEFT", optionPanel, "TOPLEFT")
	optionPanel.container = optionPanelContainer
	optionPanel:SetScrollChild(optionPanelContainer)

	local sortedTable = sortSettingsAlphabetically()

	local lastOption = nil

	for _, setting in pairs(sortedTable or MIOG_SavedSettings) do
		if(setting.type == "checkbox") then
			local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", optionPanelContainer, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
			optionButton:SetNormalAtlas("checkbox-minimal")
			optionButton:SetPushedAtlas("checkbox-minimal")
			optionButton:SetCheckedTexture("checkmark-minimal")
			optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
			optionButton:SetPoint("TOPLEFT", lastOption or optionPanelContainer, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
			optionButton:RegisterForClicks("LeftButtonDown")
			optionButton:SetChecked(setting.value)

			if(setting.key == "keepSignUpNote") then

				optionButton:SetScript("OnClick", function()
					setting.value = not setting.value

					if(setting.value == true) then
						LFGListApplicationDialog_Show = keepSignUpNote

					else
						LFGListApplicationDialog_Show = clearSignUpNote

					end
				end)
			elseif(setting.key == "keepInfoFromGroupCreation") then

				optionButton:SetScript("OnClick", function()
					setting.value = not setting.value

					if(setting.value == true) then
						LFGListEntryCreation_Clear = keepInfoFromGroupCreation
					else
						LFGListEntryCreation_Clear = clearEntryCreation

					end
				end)
			elseif(setting.key == "disableBackgroundImages") then

				optionButton:SetScript("OnClick", function()
					setting.value = not setting.value

					miog.mainFrame.backdropFrame:SetShown(not setting.value)

					if(setting.value == false) then
						miog.mainFrame.listingSettingPanel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

					else
						miog.mainFrame.listingSettingPanel:SetBackdropColor(0, 0, 0, 0)
					
					end
				end)
			elseif(setting.key == "enableClassPanel") then

				optionButton:SetScript("OnClick", function()
					setting.value = not setting.value

					miog.mainFrame.classPanel:SetShown(setting.value)
					miog.mainFrame.classPanel:MarkDirty()
				end)

				miog.mainFrame.classPanel:SetShown(setting.value)
			end

			local optionButtonString = miog.createBasicFontString("persistent", 12, optionButton)
			optionButtonString:SetWidth(optionPanelContainer:GetWidth() - optionButton:GetWidth() - 15)
			optionButtonString:SetPoint("LEFT", optionButton, "RIGHT", 10, 0)
			optionButtonString:SetText(setting.title)

			optionButtonString:SetWordWrap(true)
			optionButtonString:SetNonSpaceWrap(true)

			lastOption = optionButton

		elseif(setting.type == "dropdown") then
			if(setting.key == "backgroundOptions") then
				local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", optionPanelContainer)
				--local optionDropdown = CreateFrame("Frame", "WPDemoDropDown", optionPanelContainer, "UIDropDownMenuTemplate")
				optionDropdown:SetPoint("TOPLEFT", lastOption or optionPanelContainer, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
				UIDropDownMenu_SetWidth(optionDropdown, 200)

				UIDropDownMenu_SetText(optionDropdown, setting.table[setting.value][1])
				UIDropDownMenu_Initialize(optionDropdown,
					function(frame, level, menuList)
						local info = UIDropDownMenu_CreateInfo()
						info.func = function(_, arg1, _, _)
							setting.value = arg1
							miog.mainFrame.backdropFrame:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. setting.table[arg1][2])
							UIDropDownMenu_SetText(optionDropdown, setting.table[arg1][1])
							CloseDropDownMenus()
		
						end

						for k, v in ipairs(setting.table) do
							if(v[1]) then
								info.text, info.arg1 = v[1], k
								info.checked = k == setting.value
								UIDropDownMenu_AddButton(info)

							end
						end
					end
				)
				
				miog.mainFrame.backdropFrame:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. setting.table[setting.value][2])

				lastOption = optionDropdown
			end
		end

	end

	if(MIOG_SavedSettings.lastActiveSortingMethods and MIOG_SavedSettings.lastActiveSortingMethods.value) then
		for sortKey, row in pairs(MIOG_SavedSettings.lastActiveSortingMethods.value) do
			
			if(miog.mainFrame.buttonPanel.sortByCategoryButtons[sortKey]) then
				if(row.active == true) then
					local active = MIOG_SavedSettings.lastActiveSortingMethods.value[sortKey].active
					local currentLayer = MIOG_SavedSettings.lastActiveSortingMethods.value[sortKey].currentLayer
					local currentState = MIOG_SavedSettings.lastActiveSortingMethods.value[sortKey].currentState
			
					miog.mainFrame.buttonPanel.sortByCategoryButtons[sortKey]:SetState(active, currentState)
			
					miog.F.CURRENTLY_ACTIVE_SORTING_METHODS = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS + 1
					miog.F.SORT_METHODS[sortKey].active = true
					miog.F.SORT_METHODS[sortKey].currentLayer = currentLayer
					miog.mainFrame.buttonPanel.sortByCategoryButtons[sortKey].FontString:SetText(currentLayer)
				else
					miog.mainFrame.buttonPanel.sortByCategoryButtons[sortKey]:SetState(false)
				end
			end
		end
	else
		MIOG_SavedSettings.lastActiveSortingMethods.value = {}
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
		miog.mainFrame.backdropFrame:SetShown(false)
		miog.mainFrame.listingSettingPanel:SetBackdropColor(0, 0, 0, 0)

	else
		miog.mainFrame.backdropFrame:SetShown(true)
		miog.mainFrame.listingSettingPanel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	
	end
end

function MIOG_OpenInterfaceOptions()
---@diagnostic disable-next-line: undefined-global
	InterfaceOptionsFrame_OpenToCategory(interfaceOptionsPanel)
end