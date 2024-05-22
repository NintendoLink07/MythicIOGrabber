local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.refreshLastInvites = function()
    local dataProvider = CreateDataProvider();

    for k, v in pairs(MIOG_SavedSettings.lastInvitedApplicants.table) do
		dataProvider:Insert(v);
	end

	miog.LastInvites.SpecificScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

end

miog.addInvitedPlayer = function(currentApplicant)
	MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.fullName] = currentApplicant
	MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.fullName].timestamp = MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.fullName].timestamp or time()

    miog.refreshLastInvites()
end

miog.refreshFavouredPlayers = function()
    local dataProvider = CreateDataProvider();

    for k, v in pairs(MIOG_SavedSettings.favouredApplicants.table) do
		dataProvider:Insert(v);
	end

	miog.LastInvites.FavouredScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

end

miog.addFavouredPlayer = function(currentApplicant)
	MIOG_SavedSettings.favouredApplicants.table[currentApplicant.fullName] = currentApplicant
	MIOG_SavedSettings.favouredApplicants.table[currentApplicant.fullName].timestamp = MIOG_SavedSettings.favouredApplicants.table[currentApplicant.fullName].timestamp or time()

    miog.refreshFavouredPlayers()
end

miog.loadLastInvitesPanel = function()
    miog.LastInvites = CreateFrame("Frame", "MythicIOGrabber_LastInvitesPanel", miog.Plugin, "MIOG_LastInvitesTemplate") ---@class Frame
	miog.LastInvites:SetPoint("TOPLEFT", miog.MainFrame, "TOPRIGHT", 5, 0)
	miog.LastInvites:Hide()
	miog.LastInvites:SetSize(230, miog.MainFrame:GetHeight())
	miog.createFrameBorder(miog.LastInvites, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	miog.LastInvites.TitleBar.Retract:SetScript("OnClick", function(self)
		miog.hideSidePanel(self)
	end)

    local view = CreateScrollBoxListLinearView();
    view:SetElementInitializer("MIOG_LastInvitesPlayerTemplate", function(button, elementData)
        button.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
    
        button.Name:SetText(WrapTextInColorCode(elementData.name, select(4, GetClassColor(elementData.class))))
        button.Spec:SetTexture(miog.SPECIALIZATIONS[elementData.specID].icon)
        button.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. elementData.role .. "Icon.png")
        button.Primary:SetText(elementData.favourPrimary or elementData.primary)
        
        button.Delete.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
        button.Delete.iconSize = 12
        
        button.Delete:OnLoad()
        button.Delete:SetScript("OnClick", function(self)
            MIOG_SavedSettings.lastInvitedApplicants.table[elementData.fullName] = nil
            miog.refreshLastInvites()
        end)
    
        button.Favour:OnLoad()
        button.Favour:SetSingleTextureForSpecificState(0, miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", 15)
        button.Favour:SetSingleTextureForSpecificState(1, miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png", 12)
        button.Favour:SetMaxStates(2)
        button.Favour:SetState(MIOG_SavedSettings.favouredApplicants.table[elementData.fullName] and true or false)
        button.Favour:SetScript("OnClick", function(self)
            self:AdvanceState()
    
            if(self:GetActiveState() == 0) then
                MIOG_SavedSettings.favouredApplicants.table[elementData.fullName] = nil
                miog.refreshFavouredPlayers()
    
            else
                miog.addFavouredPlayer(elementData)
    
            end
    
    
        end)

        button:Show()
        miog.createFrameBorder(button, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())
    end);
    
    view:SetPadding(1, 1, 1, 1, 2);
    
    ScrollUtil.InitScrollBoxListWithScrollBar(miog.LastInvites.SpecificScrollBox, miog.LastInvites.SpecificScrollBar, view);
end

miog.loadFavouredPlayersPanel = function(parent, lastOption)
    local scrollBox = CreateFrame("Frame", nil, parent, "BackdropTemplate, WowScrollBoxList")
    scrollBox:SetSize(220, 140)
    scrollBox:SetFrameStrata("HIGH")
    scrollBox:SetPoint("TOPLEFT", lastOption or parent, lastOption and "BOTTOMLEFT" or "TOPLEFT", 0, -15)
    miog.createFrameBorder(scrollBox, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

    miog.LastInvites.FavouredScrollBox = scrollBox

    local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT")
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT")

    local view = CreateScrollBoxListLinearView();
    view:SetElementInitializer("MIOG_LastInvitesPlayerTemplate", function(button, elementData)
        button.Background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
    
        button.Name:SetText(WrapTextInColorCode(elementData.name, select(4, GetClassColor(elementData.class))))
        button.Spec:SetTexture(elementData.specID and miog.SPECIALIZATIONS[elementData.specID].icon)
        button.Role:SetTexture(elementData.role and miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. elementData.role .. "Icon.png")
        button.Primary:SetText(elementData.favourPrimary or elementData.primary)
        
        button.Delete.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
        button.Delete.iconSize = 12
        
        button.Delete:OnLoad()
        button.Delete:SetScript("OnClick", function(self)
            MIOG_SavedSettings.favouredApplicants.table[elementData.fullName] = nil
            miog.refreshFavouredPlayers()
        end)
    
        button.Favour:Hide()
        button:Show()
    end);
    
    view:SetPadding(1, 1, 1, 1, 2);
    
    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view);

    return scrollBox
end

miog.addFavouredButtonsToUnitPopup = function(dropdownMenu, _, _, ...)
	if(UIDROPDOWNMENU_MENU_LEVEL == 1) then
		local dropdownParent =  dropdownMenu:GetParent()

		if(dropdownMenu.unit or dropdownParent and dropdownParent.unit) then
			local unitID = dropdownMenu and (dropdownMenu.unit or dropdownMenu:GetParent().unit)
			if(UnitIsPlayer(unitID) and dropdownMenu.which ~= "SELF") then --  
				local name = dropdownMenu.name
				local server = dropdownMenu.server or GetRealmName()
				local fullName = name .. "-" .. server

				UIDropDownMenu_AddSeparator()

				local info = UIDropDownMenu_CreateInfo()
				info.notCheckable = true
				info.func = function(self, arg1, arg2, checked)
					if(type(arg1) == "table") then
						miog.addFavouredPlayer(arg1)

					else
                        MIOG_SavedSettings.favouredApplicants.table[arg1] = nil
                        miog.refreshFavouredPlayers()

					end

				end

				if(MIOG_SavedSettings.favouredApplicants.table[fullName]) then
					info.text = "[MIOG] Unfavour"
					info.arg1 = fullName

				else
					local profile = miog.F.IS_RAIDERIO_LOADED and RaiderIO.GetProfile(name, server, miog.F.CURRENT_REGION)

					local applicantData = {
						name = name,
                        class = unitID and UnitClassBase(unitID),
						--spec = spec,
						--role = role,
						primary = profile and profile.mythicKeystoneProfile and profile.mythicKeystoneProfile.currentScore and profile.mythicKeystoneProfile.currentScore > 0 and profile.mythicKeystoneProfile.currentScore or "No score",
						fullName = fullName,
					}

					info.text = "[MIOG] Favour"
					info.arg1 = applicantData

				end

				UIDropDownMenu_AddButton(info, 1)
			end
		end
	end
end