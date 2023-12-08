local addonName, miog = ...

miog.mainFrame = CreateFrame("Frame", "MythicIOGrabber_MainFrame", LFGListFrame, "BackdropTemplate") ---@class Frame

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

local pveFrameTab1_Point = nil

local function positionTab1ToMainFrame()
	miog.mainFrame:SetHeight(miog.mainFrame.extendedHeight)
	PVEFrameTab1:SetParent(miog.mainFrame)
	PVEFrameTab1:ClearAllPoints()
	PVEFrameTab1:SetPoint("TOPLEFT", miog.mainFrame, "BOTTOMLEFT", 0, 0)

	PVEFrameTab1:SetWidth(PVEFrameTab1:GetWidth() - 2)
	PVEFrameTab2:SetWidth(PVEFrameTab2:GetWidth() - 2)
	PVEFrameTab3:SetWidth(PVEFrameTab3:GetWidth() - 2)

end

local function positionTab1PVEFrame()
	miog.mainFrame:SetHeight(miog.mainFrame.standardHeight)
	PVEFrameTab1:SetParent(PVEFrame)
	PVEFrameTab1:ClearAllPoints()
	insertPointsIntoFrame(PVEFrameTab1, pveFrameTab1_Point)

	PVEFrameTab1:SetWidth(PVEFrameTab1:GetWidth() + 2)
	PVEFrameTab2:SetWidth(PVEFrameTab2:GetWidth() + 2)
	PVEFrameTab3:SetWidth(PVEFrameTab3:GetWidth() + 2)

end

miog.createMainFrame = function()

	local mainFrame = miog.mainFrame ---@class Frame
    pveFrameTab1_Point = insertPointsIntoTable(PVEFrameTab1)

	mainFrame:SetSize((LFGListFrame:GetWidth() + 2), (LFGListPVEStub:GetHeight() - PVEFrame.TitleContainer:GetHeight() - 5))
	mainFrame.standardHeight = mainFrame:GetHeight()
	mainFrame.extendedHeight = mainFrame.standardHeight * 1.5
	--mainFrame:SetScale(1.5)
	mainFrame:SetPoint(LFGListFrame.ApplicationViewer:GetPoint())
	mainFrame:SetFrameStrata("DIALOG")
	mainFrame:AdjustPointsOffset(-4, -PVEFrame.TitleContainer:GetHeight() - 1)

	miog.createFrameBorder(mainFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	mainFrame:HookScript("OnShow", function()
		if(MIOG_SavedSettings.frameExtended.value) then
			positionTab1ToMainFrame()

		end
	end)
	mainFrame:HookScript("OnHide", function()
		positionTab1PVEFrame()

	end)
	_G[mainFrame:GetName()] = mainFrame

	local backdropFrame = miog.createBasicTexture("persistent", miog.C.STANDARD_FILE_PATH .. "/backgrounds/df-bg-1.png", mainFrame)
	backdropFrame:SetVertTile(true)
	backdropFrame:SetHorizTile(true)
	backdropFrame:SetDrawLayer("BACKGROUND", -8)
	backdropFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT")
	backdropFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT")

	mainFrame.backdropFrame = backdropFrame

	local openSettingsButton = miog.createBasicFrame("persistent", "UIButtonTemplate", mainFrame, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE)
	openSettingsButton:SetPoint("RIGHT", PVEFrameCloseButton, "LEFT", 0, 0)
	openSettingsButton:SetNormalTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/settingGear.png")
	openSettingsButton:RegisterForClicks("LeftButtonDown")
	openSettingsButton:SetScript("OnClick", function()
		Settings.OpenToCategory("Mythic IO Grabber")

	end)

	local expandDownwardsButton = miog.createBasicFrame("persistent", "UIButtonTemplate", mainFrame, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE)
	expandDownwardsButton:SetPoint("RIGHT", openSettingsButton, "LEFT", 0, -expandDownwardsButton:GetHeight()/4)
	expandDownwardsButton:SetNormalTexture(293770)
	expandDownwardsButton:SetPushedTexture(293769)
	expandDownwardsButton:SetDisabledTexture(293768)

	expandDownwardsButton:RegisterForClicks("LeftButtonDown")
	expandDownwardsButton:SetScript("OnClick", function()

		MIOG_SavedSettings.frameExtended.value = not MIOG_SavedSettings.frameExtended.value

		if(MIOG_SavedSettings.frameExtended.value) then
			positionTab1ToMainFrame()

		elseif(not MIOG_SavedSettings.frameExtended.value) then
			positionTab1PVEFrame()

		end
	end)

	mainFrame.expandDownwardsButton = expandDownwardsButton
	
	local raiderIOAddonIsLoadedFrame = miog.createBasicFontString("persistent", 16, mainFrame)
	raiderIOAddonIsLoadedFrame:SetPoint("RIGHT", openSettingsButton, "LEFT", - 5 - expandDownwardsButton:GetWidth(), 0)
	raiderIOAddonIsLoadedFrame:SetJustifyH("RIGHT")
	raiderIOAddonIsLoadedFrame:SetText(WrapTextInColorCode("NO R.IO", miog.CLRSCC["red"]))
	raiderIOAddonIsLoadedFrame:SetShown(not miog.F.IS_RAIDERIO_LOADED)

	miog.mainFrame.raiderIOAddonIsLoadedFrame = raiderIOAddonIsLoadedFrame

	local classPanel = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", mainFrame)
	classPanel:SetPoint("TOPRIGHT", mainFrame, "TOPLEFT", -1, -2)
	classPanel.fixedWidth = 28

	mainFrame.classPanel = classPanel

	classPanel.classFrames = {}
	
	for classID, classEntry in ipairs(miog.CLASSES) do
		local classFrame = miog.createBasicFrame("persistent", "BackdropTemplate", classPanel, 25, 25, "Texture", classEntry.icon)
		classPanel.classFrames[classID] = classFrame
		classFrame.bottomPadding = 5
		
		local classFrameFontString = miog.createBasicFontString("persistent", 20, classFrame)
		classFrameFontString:SetPoint("CENTER", classFrame, "CENTER", 0, -1)
		classFrameFontString:SetJustifyH("CENTER")
		classFrame.FontString = classFrameFontString

		local specPanel = miog.createBasicFrame("persistent", "HorizontalLayoutFrame, BackdropTemplate", classFrame)
		specPanel:SetPoint("RIGHT", classFrame, "LEFT", -5, 0)
		specPanel.fixedHeight = 25
		specPanel.specFrames = {}
		specPanel:Hide()
		classFrame.specPanel = specPanel

		local specCounter = 1

		for _, specID in ipairs(classEntry.specs) do
			local specFrame = miog.createBasicFrame("persistent", "BackdropTemplate", specPanel, 25, 25, "Texture", miog.SPECIALIZATIONS[specID].squaredIcon)
			specFrame.layoutIndex = specCounter
			specFrame.leftPadding = 5
			miog.createFrameBorder(specFrame, 1, 0, 0, 0, 1)

			local specFrameFontString = miog.createBasicFontString("persistent", miog.C.SPEC_PANEL_FONT_SIZE, specFrame)
			specFrameFontString:SetPoint("CENTER", specFrame, "CENTER", 0, -1)
			specFrameFontString:SetJustifyH("CENTER")
			specFrame.FontString = specFrameFontString

			specPanel.specFrames[specID] = specFrame

			specCounter = specCounter + 1
		end

		specPanel:MarkDirty()

		classFrame:SetScript("OnEnter", function()
			specPanel:Show()

		end)
		classFrame:SetScript("OnLeave", function()
			specPanel:Hide()

		end)
	end

	classPanel:MarkDirty()

	local inspectProgressText = miog.createBasicFontString("persistent", miog.C.CLASS_PANEL_FONT_SIZE, classPanel)
	inspectProgressText:SetPoint("TOPRIGHT", classPanel, "TOPLEFT", -5, -5)
	inspectProgressText:SetText("0/40")
	inspectProgressText:SetJustifyH("RIGHT")

	classPanel.progressText = inspectProgressText

	local titleBar = miog.createBasicFrame("persistent", "BackdropTemplate", mainFrame, nil, mainFrame:GetHeight()*0.06)
	titleBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
	miog.createFrameBorder(titleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	titleBar.factionIconSize = titleBar:GetHeight() - 4
	mainFrame.titleBar = titleBar

	local titleStringFrame = miog.createBasicFrame("persistent", "BackdropTemplate", titleBar, titleBar:GetWidth()*0.6, titleBar:GetHeight(), "FontString", miog.C.TITLE_FONT_SIZE)
	titleStringFrame:SetPoint("LEFT", titleBar, "LEFT")
	titleStringFrame:SetMouseMotionEnabled(true)
	titleStringFrame:SetScript("OnEnter", function()
		if(titleStringFrame.FontString:IsTruncated()) then
			GameTooltip:SetOwner(titleStringFrame, "ANCHOR_CURSOR")
			GameTooltip:SetText(titleStringFrame.FontString:GetText())
			GameTooltip:Show()
		end
	end)
	titleStringFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	titleStringFrame.FontString:AdjustPointsOffset(miog.C.STANDARD_PADDING, -1)
	titleStringFrame.FontString:SetText("")

	titleBar.titleStringFrame = titleStringFrame
	
	local factionFrame = miog.createBasicFrame("persistent", "BackdropTemplate", titleBar, titleBar.factionIconSize, titleBar.factionIconSize, "Texture", 2437241)
	factionFrame:SetPoint("RIGHT", titleBar, "RIGHT", -1, 0)

	titleBar.factionFrame = factionFrame

	local groupMemberListing = miog.createBasicFrame("persistent", "HorizontalLayoutFrame, BackdropTemplate", titleBar)
	groupMemberListing.fixedHeight = 20
	groupMemberListing.minimumWidth = 20
	groupMemberListing:SetPoint("RIGHT", factionFrame, "LEFT", 0, -1)

	titleBar.groupMemberListing = groupMemberListing

	local groupMemberListingText = miog.createBasicFontString("persistent", 16, groupMemberListing)
	groupMemberListingText:SetPoint("RIGHT", groupMemberListing, "RIGHT", 0, -1)
	groupMemberListingText:SetText("0/0/0")
	groupMemberListingText:SetJustifyH("RIGHT")
	groupMemberListing:MarkDirty()

	groupMemberListing.FontString = groupMemberListingText

	local infoPanel = miog.createBasicFrame("persistent", "BackdropTemplate", mainFrame)
	infoPanel:SetHeight(mainFrame:GetHeight()*0.19)
	infoPanel:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 1)
	infoPanel:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 1)

	mainFrame.infoPanel = infoPanel

	local knownIssuesPanel = miog.createBasicFrame("persistent", "IconButtonTemplate", infoPanel, 15, 15)
	knownIssuesPanel:SetNormalAtlas("glueannouncementpopup-icon-info")
	knownIssuesPanel:SetHighlightAtlas("glueannouncementpopup-icon-info")
	knownIssuesPanel:SetPoint("TOPRIGHT", infoPanel, "TOPRIGHT", -4, -4)
	knownIssuesPanel:SetScript("OnEnter", function()
		GameTooltip:SetOwner(knownIssuesPanel, "ANCHOR_TOPRIGHT")
		GameTooltip:AddLine("Current Issues:")
		GameTooltip:AddLine("A premade group of 2 or more members won't send correct spec data to the game client.", 1, 1, 1)
		GameTooltip:AddLine("Instead of a spec icon it will show a question mark for those groups.", 1, 1, 1)
		GameTooltip:AddLine("It's a bug on Blizzard's end, unless I find a workaround we have to wait for Blizzard to fix it.", 1, 1, 1)
		GameTooltip:Show()

	end)
	knownIssuesPanel:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)

	local infoPanelBackdropFrame = miog.createBasicFrame("persistent", "BackdropTemplate", infoPanel)
	infoPanelBackdropFrame:SetPoint("TOPLEFT", infoPanel, "TOPLEFT")
	infoPanelBackdropFrame:SetPoint("BOTTOMRIGHT", infoPanel, "BOTTOMRIGHT")
	infoPanelBackdropFrame.backdropInfo = {
		bgFile=miog.BACKGROUNDS[10],
		tileSize=miog.C.APPLICANT_MEMBER_HEIGHT,
		tile=false,
		edgeSize=2,
		insets={left=1, right=1, top=1, bottom=0}
	}

	infoPanelBackdropFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	infoPanelBackdropFrame:ApplyBackdrop()
	infoPanelBackdropFrame.Center:SetDrawLayer("BACKGROUND", 1)

	mainFrame.infoPanelBackdropFrame = infoPanelBackdropFrame

	local infoPanelDarkenFrame = miog.createBasicFrame("persistent", "BackdropTemplate", infoPanelBackdropFrame)
	infoPanelDarkenFrame:SetPoint("TOPLEFT", infoPanel, "TOPLEFT", 0, 0)
	infoPanelDarkenFrame:SetPoint("BOTTOMRIGHT", infoPanel, "BOTTOMRIGHT", 0, 0)
	infoPanelDarkenFrame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=false, edgeSize=1} )
	infoPanelDarkenFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.4)
	--infoPanelDarkenFrame:Hide()

	local activityNameFontString = infoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	activityNameFontString:SetFont(miog.FONTS["libMono"], miog.C.ACTIVITY_NAME_FONT_SIZE, "OUTLINE")
	activityNameFontString:SetPoint("TOPLEFT", infoPanel, "TOPLEFT", miog.C.STANDARD_PADDING, -miog.C.STANDARD_PADDING)
	activityNameFontString:SetPoint("TOPRIGHT", infoPanel, "TOPRIGHT", -miog.C.STANDARD_PADDING, -miog.C.STANDARD_PADDING)
	activityNameFontString:SetJustifyH("LEFT")
	activityNameFontString:SetParent(infoPanelDarkenFrame)
	activityNameFontString:SetWordWrap(true)
	activityNameFontString:SetText("ActivityName")
	activityNameFontString:SetTextColor(1, 0.8, 0, 1)
	activityNameFontString:Show()

	infoPanel.activityNameFrame = activityNameFontString

	local commentScrollFrame = miog.createBasicFrame("persistent", "ScrollFrameTemplate", infoPanelDarkenFrame)
	commentScrollFrame:SetPoint("TOPLEFT", activityNameFontString, "BOTTOMLEFT", 0, -miog.C.STANDARD_PADDING*2)
	commentScrollFrame:SetPoint("BOTTOMRIGHT", infoPanel, "BOTTOMRIGHT", -miog.C.STANDARD_PADDING, miog.C.STANDARD_PADDING)
	--commentScrollFrame.ScrollBar:Hide()

	local commentFrame = miog.createBasicFrame("persistent", "BackdropTemplate", commentScrollFrame, commentScrollFrame:GetWidth(), commentScrollFrame:GetHeight(), "FontString", miog.C.LISTING_COMMENT_FONT_SIZE)
	commentFrame.FontString:SetWidth(commentFrame:GetWidth())
	commentFrame.FontString:SetJustifyV("TOP")
	commentFrame.FontString:SetPoint("TOPLEFT", commentFrame, "TOPLEFT")
	commentFrame.FontString:SetPoint("BOTTOMRIGHT", commentFrame, "BOTTOMRIGHT")
	commentFrame.FontString:SetText("")
	commentFrame.FontString:SetSpacing(5)
	commentFrame.FontString:SetNonSpaceWrap(true)
	commentFrame.FontString:SetWordWrap(true)
	commentScrollFrame:SetScrollChild(commentFrame)

	infoPanel.commentFrame = commentFrame
	
	local listingSettingPanel = miog.createBasicFrame("persistent", "ResizeLayoutFrame, BackdropTemplate", infoPanel)
	listingSettingPanel:SetPoint("TOPLEFT", infoPanel, "BOTTOMLEFT")
	listingSettingPanel:SetPoint("TOPRIGHT", infoPanel, "BOTTOMRIGHT")
	listingSettingPanel:SetHeight(titleBar:GetHeight())

	miog.createFrameBorder(listingSettingPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	listingSettingPanel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	mainFrame.listingSettingPanel = listingSettingPanel

	local privateGroupFrame = miog.createBasicFrame("persistent", "BackdropTemplate", listingSettingPanel, listingSettingPanel:GetWidth()*0.04, listingSettingPanel:GetHeight(), "Texture", miog.C.STANDARD_FILE_PATH .. "/infoIcons/questionMark_Grey.png")
	privateGroupFrame:SetPoint("LEFT", listingSettingPanel, "LEFT", 0, 0)
	privateGroupFrame.active = false
	privateGroupFrame.Texture:ClearAllPoints()
	privateGroupFrame.Texture:SetPoint("CENTER")
	privateGroupFrame.Texture:SetWidth(privateGroupFrame:GetWidth() - 4)
	privateGroupFrame.Texture:SetScale(0.75)
	privateGroupFrame:SetMouseMotionEnabled(true)
	privateGroupFrame:SetScript("OnEnter", function()
		if(privateGroupFrame.active == true) then
			GameTooltip:SetOwner(privateGroupFrame, "ANCHOR_CURSOR")
			GameTooltip:SetText("Group listing is set to private")
			GameTooltip:Show()
		end
	end)
	privateGroupFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	listingSettingPanel.privateGroupFrame = privateGroupFrame
	miog.createFrameBorder(privateGroupFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	
	local voiceChatFrame = miog.createBasicFrame("persistent", "BackdropTemplate", listingSettingPanel, listingSettingPanel:GetWidth()*0.06, listingSettingPanel:GetHeight(), "Texture", miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOff.png")
	voiceChatFrame.fixedHeight = listingSettingPanel:GetHeight()
	voiceChatFrame.maximumWidth = listingSettingPanel:GetWidth()*0.15
	voiceChatFrame.tooltipText = ""
	voiceChatFrame.Texture:ClearAllPoints()
	voiceChatFrame.Texture:SetHeight(listingSettingPanel:GetHeight())
	voiceChatFrame.Texture:SetWidth(listingSettingPanel:GetHeight())
	voiceChatFrame.Texture:SetPoint("CENTER")
	voiceChatFrame.Texture:SetScale(0.7)
	voiceChatFrame:SetPoint("LEFT", privateGroupFrame, "RIGHT")
	listingSettingPanel.voiceChatFrame = voiceChatFrame
	miog.createFrameBorder(voiceChatFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	voiceChatFrame:SetMouseMotionEnabled(true)
	voiceChatFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(voiceChatFrame, "ANCHOR_CURSOR")
		GameTooltip:SetText(voiceChatFrame.tooltipText)
		GameTooltip:Show()
	end)
	voiceChatFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local playstyleFrame = miog.createBasicFrame("persistent", "BackdropTemplate", listingSettingPanel, listingSettingPanel:GetWidth()*0.07, listingSettingPanel:GetHeight(), "Texture", miog.C.STANDARD_FILE_PATH .. "/infoIcons/book.png")
	playstyleFrame.Texture:ClearAllPoints()
	playstyleFrame.Texture:SetPoint("CENTER", playstyleFrame, "CENTER", 1, 0)
	playstyleFrame:SetPoint("LEFT", voiceChatFrame, "RIGHT")
	playstyleFrame.tooltipText = ""
	playstyleFrame:SetMouseMotionEnabled(true)
	playstyleFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(playstyleFrame, "ANCHOR_CURSOR")
		GameTooltip:SetText(playstyleFrame.tooltipText)
		GameTooltip:Show()
	end)
	playstyleFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	listingSettingPanel.playstyleFrame = playstyleFrame
	miog.createFrameBorder(playstyleFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local ratingFrame = miog.createBasicFrame("persistent", "BackdropTemplate", listingSettingPanel, listingSettingPanel:GetWidth()*0.2, listingSettingPanel:GetHeight(), "Texture", miog.C.STANDARD_FILE_PATH .. "/infoIcons/skull.png")
	ratingFrame.Texture:SetWidth(listingSettingPanel:GetHeight())
	ratingFrame.Texture:SetScale(0.85)
	ratingFrame.Texture:ClearAllPoints()
	ratingFrame.Texture:SetPoint("LEFT", ratingFrame, "LEFT")
	ratingFrame:SetPoint("LEFT", playstyleFrame, "RIGHT")
	ratingFrame.tooltipText = ""
	ratingFrame:SetMouseMotionEnabled(true)
	ratingFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(ratingFrame, "ANCHOR_CURSOR")
		GameTooltip:SetText(ratingFrame.tooltipText)
		GameTooltip:Show()
	end)
	ratingFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	listingSettingPanel.ratingFrame = ratingFrame
	miog.createFrameBorder(ratingFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local ratingString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, ratingFrame)
	ratingString:SetPoint("TOPLEFT", ratingFrame.Texture, "TOPRIGHT", 0, 0)
	ratingString:SetPoint("BOTTOMRIGHT", ratingFrame, "BOTTOMRIGHT", 0, 0)
	ratingString:SetJustifyH("CENTER")
	ratingString:SetText("3333")
	ratingFrame.FontString = ratingString

	local itemLevelFrame = miog.createBasicFrame("persistent", "BackdropTemplate", listingSettingPanel, listingSettingPanel:GetWidth()*0.17, listingSettingPanel:GetHeight(), "Texture", miog.C.STANDARD_FILE_PATH .. "/infoIcons/itemsacks.png")
	itemLevelFrame.Texture:SetWidth(listingSettingPanel:GetHeight())
	itemLevelFrame.Texture:SetScale(0.85)
	itemLevelFrame.Texture:ClearAllPoints()
	itemLevelFrame.Texture:SetPoint("LEFT", itemLevelFrame, "LEFT")
	itemLevelFrame:SetPoint("LEFT", ratingFrame, "RIGHT")
	itemLevelFrame.tooltipText = ""
	itemLevelFrame:SetMouseMotionEnabled(true)
	itemLevelFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(itemLevelFrame, "ANCHOR_CURSOR")
		GameTooltip:SetText(itemLevelFrame.tooltipText)
		GameTooltip:Show()
	end)
	itemLevelFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	listingSettingPanel.itemLevelFrame = itemLevelFrame
	miog.createFrameBorder(itemLevelFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local itemLevelString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, itemLevelFrame)
	itemLevelString:SetPoint("TOPLEFT", itemLevelFrame.Texture, "TOPRIGHT", 0, 0)
	itemLevelString:SetPoint("BOTTOMRIGHT", itemLevelFrame, "BOTTOMRIGHT", 0, 0)
	itemLevelString:SetJustifyH("CENTER")
	itemLevelString:SetText("444")
	itemLevelFrame.FontString = itemLevelString

	local affixFrame = miog.createBasicFrame("persistent", "BackdropTemplate", infoPanel, listingSettingPanel:GetWidth()*0.2, listingSettingPanel:GetHeight(), "FontString", miog.C.AFFIX_TEXTURE_FONT_SIZE)
	affixFrame:SetPoint("LEFT", itemLevelFrame, "RIGHT", 0, 0)
	affixFrame.tooltipText = ""
	affixFrame:SetMouseMotionEnabled(true)
	affixFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(affixFrame, "ANCHOR_CURSOR")
		GameTooltip:SetText(affixFrame.tooltipText)
		GameTooltip:Show()
	end)
	affixFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	affixFrame.FontString:SetJustifyH("CENTER")
	affixFrame.FontString:ClearAllPoints()
	affixFrame.FontString:SetPoint("CENTER", affixFrame, "CENTER", 1, -1)
	miog.createFrameBorder(affixFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	infoPanel.affixFrame = affixFrame

	local timerFrame = miog.createBasicFrame("persistent", "BackdropTemplate", infoPanel, listingSettingPanel:GetWidth()*0.25, listingSettingPanel:GetHeight(), "FontString", miog.C.LISTING_INFO_FONT_SIZE, "0:00:00")
	timerFrame.FontString:ClearAllPoints()
	timerFrame.FontString:SetPoint("CENTER", timerFrame, "CENTER", 0, -1)
	timerFrame:SetPoint("TOPLEFT", affixFrame, "TOPRIGHT")
	timerFrame:SetPoint("BOTTOMRIGHT", listingSettingPanel, "BOTTOMRIGHT")
	timerFrame.FontString:SetJustifyH("CENTER")
	infoPanel.timerFrame = timerFrame
	miog.createFrameBorder(timerFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	listingSettingPanel:MarkDirty()

	local buttonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", infoPanel, nil, miog.C.APPLICANT_MEMBER_HEIGHT + 2)
	buttonPanel:SetPoint("TOPLEFT", listingSettingPanel, "BOTTOMLEFT", 0, 1)
	buttonPanel:SetPoint("TOPRIGHT", listingSettingPanel, "BOTTOMRIGHT", 0, 1)
	buttonPanel.RoleTextures = {}
	buttonPanel.RoleButtons = {}
	miog.createFrameBorder(buttonPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	buttonPanel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	mainFrame.buttonPanel = buttonPanel

	for i = 1, 3, 1 do
		local toggleRoleButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", buttonPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
		toggleRoleButton:SetNormalAtlas("checkbox-minimal")
		toggleRoleButton:SetPushedAtlas("checkbox-minimal")
		toggleRoleButton:SetCheckedTexture("checkmark-minimal")
		toggleRoleButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		toggleRoleButton:SetPoint("LEFT", buttonPanel.RoleTextures[i-1] or buttonPanel, buttonPanel.RoleTextures[i-1] and "RIGHT" or "LEFT", buttonPanel.RoleTextures[i-1] and 5 or 1, 0)
		toggleRoleButton:RegisterForClicks("LeftButtonDown")
		toggleRoleButton:SetChecked(true)

		local roleTexture = miog.createBasicTexture("persistent", nil, buttonPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 3, miog.C.APPLICANT_MEMBER_HEIGHT - 3, "ARTWORK")
		roleTexture:SetPoint("LEFT", toggleRoleButton, "RIGHT", 0, 0)

		local showRoleButtonText = miog.createBasicFontString("persistent", 16, buttonPanel)
		showRoleButtonText:Hide()
		showRoleButtonText:SetPoint("CENTER", roleTexture, "CENTER", 0, -1)
		showRoleButtonText:SetJustifyV("CENTER")
		showRoleButtonText:SetText("0")

		roleTexture.text = showRoleButtonText

		if(i == 3) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")

			toggleRoleButton:SetScript("OnClick", function()
				miog.F.SHOW_DPS = not miog.F.SHOW_DPS
				showRoleButtonText:SetShown(not miog.F.SHOW_DPS)
	
				C_LFGList.RefreshApplicants()
			end)

		elseif(i == 2) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")

			toggleRoleButton:SetScript("OnClick", function()
				miog.F.SHOW_HEALERS = not miog.F.SHOW_HEALERS
				showRoleButtonText:SetShown(not miog.F.SHOW_HEALERS)
	
				C_LFGList.RefreshApplicants()
			end)

		elseif(i == 1) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")

			toggleRoleButton:SetScript("OnClick", function()
				miog.F.SHOW_TANKS = not miog.F.SHOW_TANKS
				showRoleButtonText:SetShown(not miog.F.SHOW_TANKS)
	
				C_LFGList.RefreshApplicants()
			end)

		end

		buttonPanel.RoleButtons[i] = toggleRoleButton
		buttonPanel.RoleTextures[i] = roleTexture
	end

	buttonPanel.sortByCategoryButtons = {}

	for i = 1, 4, 1 do

		local sortByCategoryButton = Mixin(miog.createBasicFrame("persistent", "UIButtonTemplate", buttonPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), TripleStateButtonMixin)
		sortByCategoryButton:OnLoad()
		sortByCategoryButton:SetTexturesForBaseState("hud-MainMenuBar-arrowdown-disabled", "hud-MainMenuBar-arrowdown-disabled", "hud-MainMenuBar-arrowdown-highlight", "hud-MainMenuBar-arrowdown-disabled")
		sortByCategoryButton:SetTexturesForState1("hud-MainMenuBar-arrowdown-up", "hud-MainMenuBar-arrowdown-down", "hud-MainMenuBar-arrowdown-highlight", "hud-MainMenuBar-arrowdown-disabled")
		sortByCategoryButton:SetTexturesForState2("hud-MainMenuBar-arrowup-up", "hud-MainMenuBar-arrowup-down", "hud-MainMenuBar-arrowup-highlight", "hud-MainMenuBar-arrowup-disabled")
		sortByCategoryButton:SetStateName(0, "None")
		sortByCategoryButton:SetStateName(1, "Descending")
		sortByCategoryButton:SetStateName(2, "Ascending")
		sortByCategoryButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		sortByCategoryButton:SetState(false)
		sortByCategoryButton:SetMouseMotionEnabled(true)
		sortByCategoryButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(sortByCategoryButton, "ANCHOR_CURSOR")
			GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
			GameTooltip:Show()

		end)
		sortByCategoryButton:SetScript("OnLeave", function()
			GameTooltip:Hide()

		end)

		local sortByCategoryButtonString = miog.createBasicFontString("persistent", 9, sortByCategoryButton)
		sortByCategoryButtonString:ClearAllPoints()
		sortByCategoryButtonString:SetPoint("BOTTOMLEFT", sortByCategoryButton, "BOTTOMLEFT")

		sortByCategoryButton.FontString = sortByCategoryButtonString

		local currentCategory = ""

		if(i == 1) then
			currentCategory = "role"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 132, 0)

		elseif(i == 2) then
			currentCategory = "primary"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 164, 0)

		elseif(i == 3) then
			currentCategory = "secondary"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 203, 0)

		elseif(i == 4) then
			currentCategory = "ilvl"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 243, 0)

		end

		sortByCategoryButton:SetScript("OnClick", function(_, button)
			local activeState = sortByCategoryButton:GetActiveState()

			if(button == "LeftButton") then

				if(activeState == 0 and miog.F.CURRENTLY_ACTIVE_SORTING_METHODS < 2) then
					--TO 1
					miog.F.CURRENTLY_ACTIVE_SORTING_METHODS = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS + 1

					miog.F.SORT_METHODS[currentCategory].active = true
					miog.F.SORT_METHODS[currentCategory].currentLayer = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS

					sortByCategoryButton.FontString:SetText(miog.F.CURRENTLY_ACTIVE_SORTING_METHODS)

				elseif(activeState == 1) then
					--TO 2


				elseif(activeState == 2) then
					--RESET TO 0
					miog.F.CURRENTLY_ACTIVE_SORTING_METHODS = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS - 1

					miog.F.SORT_METHODS[currentCategory].active = false
					miog.F.SORT_METHODS[currentCategory].currentLayer = 0

					sortByCategoryButton.FontString:SetText("")

					for k, v in pairs(miog.F.SORT_METHODS) do
						if(v.currentLayer == 2) then
							v.currentLayer = 1
							buttonPanel.sortByCategoryButtons[k].FontString:SetText(1)
							miog.F.SORT_METHODS[k].currentLayer = 1
							MIOG_SavedSettings.lastActiveSortingMethods.value[k].currentLayer = 1
						end
					end
				end
				
				if(miog.F.CURRENTLY_ACTIVE_SORTING_METHODS < 2 or miog.F.CURRENTLY_ACTIVE_SORTING_METHODS == 2 and miog.F.SORT_METHODS[currentCategory].active == true) then
					sortByCategoryButton:AdvanceState()
					
					miog.F.SORT_METHODS[currentCategory].currentState = sortByCategoryButton:GetActiveState()

					MIOG_SavedSettings.lastActiveSortingMethods.value[currentCategory] = miog.F.SORT_METHODS[currentCategory]

					if(GameTooltip:GetOwner() == sortByCategoryButton) then
						GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
					end
				end

				C_LFGList.RefreshApplicants()
			elseif(button == "RightButton") then
				if(activeState == 1 or activeState == 2) then
					
					miog.F.CURRENTLY_ACTIVE_SORTING_METHODS = miog.F.CURRENTLY_ACTIVE_SORTING_METHODS - 1

					miog.F.SORT_METHODS[currentCategory].active = false
					miog.F.SORT_METHODS[currentCategory].currentLayer = 0

					sortByCategoryButton.FontString:SetText("")

					for k, v in pairs(miog.F.SORT_METHODS) do
						if(v.currentLayer == 2) then
							v.currentLayer = 1
							buttonPanel.sortByCategoryButtons[k].FontString:SetText(1)
							miog.F.SORT_METHODS[k].currentLayer = 1
							MIOG_SavedSettings.lastActiveSortingMethods.value[k].currentLayer = 1
						end
					end
					
					sortByCategoryButton:SetState(false)
				
					if(miog.F.CURRENTLY_ACTIVE_SORTING_METHODS < 2 or miog.F.CURRENTLY_ACTIVE_SORTING_METHODS == 2 and miog.F.SORT_METHODS[currentCategory].active == true) then
						
						miog.F.SORT_METHODS[currentCategory].currentState = sortByCategoryButton:GetActiveState()

						MIOG_SavedSettings.lastActiveSortingMethods.value[currentCategory] = miog.F.SORT_METHODS[currentCategory]

						if(GameTooltip:GetOwner() == sortByCategoryButton) then
							GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
						end
					end

					C_LFGList.RefreshApplicants()
				end
			end
		end)

		buttonPanel.sortByCategoryButtons[currentCategory] = sortByCategoryButton

	end

	local resetButton = miog.createBasicFrame("persistent", "IconButtonTemplate", buttonPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
	resetButton.iconAtlas = "UI-RefreshButton"
	resetButton.iconSize = miog.C.APPLICANT_MEMBER_HEIGHT
	resetButton:OnLoad()
	resetButton:SetPoint("RIGHT", buttonPanel, "RIGHT", -2, 0)
	resetButton:SetScript("OnClick",
		function()
			C_LFGList.RefreshApplicants()
		
			miog.mainFrame.applicantPanel:SetVerticalScroll(0)
		end
	)

	buttonPanel.resetButton = resetButton

	local applicantNumberFontString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, itemLevelFrame)
	applicantNumberFontString:SetPoint("RIGHT", resetButton, "LEFT", -10, -2)
	applicantNumberFontString:SetJustifyH("CENTER")
	applicantNumberFontString:SetText(0)

	buttonPanel.applicantNumberFontString = applicantNumberFontString

	local footerBar = miog.createBasicFrame("persistent", "BackdropTemplate", titleBar)
	footerBar:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, 0)
	footerBar:SetPoint("TOPRIGHT", mainFrame, "BOTTOMRIGHT", 0, mainFrame:GetHeight()*0.06)
	miog.createFrameBorder(footerBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	footerBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	mainFrame.footerBar = footerBar

	local browseGroupsButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", footerBar, 1, footerBar:GetHeight())
	browseGroupsButton:SetPoint("LEFT", footerBar, "LEFT")
	browseGroupsButton:SetText("Browse Groups")
	browseGroupsButton:FitToText()
	browseGroupsButton:RegisterForClicks("LeftButtonDown")
	browseGroupsButton:SetScript("OnClick", function()
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

	local editButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", footerBar, 1, footerBar:GetHeight())
	editButton:SetPoint("RIGHT", footerBar, "RIGHT")
	editButton:SetText("Edit")
	editButton:FitToText()
	editButton:RegisterForClicks("LeftButtonDown")
	editButton:SetScript("OnClick", function()
		local entryCreation = LFGListFrame.EntryCreation;
		LFGListEntryCreation_SetEditMode(entryCreation, true);
		LFGListFrame_SetActivePanel(LFGListFrame, entryCreation);
	end)

	local delistButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", footerBar, 1, footerBar:GetHeight())
	delistButton:SetPoint("RIGHT", editButton, "LEFT")
	delistButton:SetText("Delist")
	delistButton:FitToText()
	delistButton:RegisterForClicks("LeftButtonDown")
	delistButton:SetScript("OnClick", function()
		C_LFGList.RemoveListing()
	end)

	local applicantPanel = miog.createBasicFrame("persistent", "ScrollFrameTemplate", titleBar)
	applicantPanel:SetPoint("TOPLEFT", buttonPanel, "BOTTOMLEFT", 1, 0)
	applicantPanel:SetPoint("BOTTOMRIGHT", footerBar, "TOPRIGHT", 0, 0)
	mainFrame.applicantPanel = applicantPanel

	miog.C.MAIN_WIDTH = applicantPanel:GetWidth()

	local applicantPanelContainer = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", applicantPanel)
	applicantPanelContainer.fixedWidth = applicantPanel:GetWidth()
	applicantPanelContainer.minimumHeight = 1
	applicantPanelContainer.spacing = 5
	applicantPanelContainer.align = "top"
	applicantPanelContainer:SetPoint("TOPLEFT", applicantPanel, "TOPLEFT")
	applicantPanel.container = applicantPanelContainer

	applicantPanel:SetScrollChild(applicantPanelContainer)

	miog.mainFrame:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
	miog.mainFrame:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
	miog.mainFrame:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
	miog.mainFrame:RegisterEvent("PARTY_LEADER_CHANGED")
	miog.mainFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	miog.mainFrame:RegisterEvent("GROUP_JOINED")
	miog.mainFrame:RegisterEvent("GROUP_LEFT")
	miog.mainFrame:RegisterEvent("INSPECT_READY")
	miog.mainFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	miog.mainFrame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
	C_MythicPlus.GetCurrentAffixes()

	EncounterJournal_LoadUI()
	C_EncounterJournal.OnOpen = miog.dummyFunction
	EJ_SelectInstance(1207)

	if(RaiderIO_ExportButton) then
		RaiderIO_ExportButton:ClearAllPoints()
		RaiderIO_ExportButton:SetPoint("LEFT", browseGroupsButton, "RIGHT", 5, 0)
		RaiderIO_ExportButton:SetParent(footerBar)
	end


end

miog.mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
miog.mainFrame:RegisterEvent("PLAYER_LOGIN")
miog.mainFrame:SetScript("OnEvent", miog.OnEvent)