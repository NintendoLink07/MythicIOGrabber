local addonName, miog = ...

miog.scriptReceiver = CreateFrame("Frame", "MythicIOGrabber_ScriptReceiver", LFGListFrame, "BackdropTemplate") ---@class Frame
miog.mainFrame = CreateFrame("Frame", "MythicIOGrabber_MainFrame", LFGListFrame, "BackdropTemplate") ---@class Frame
miog.applicationViewer = CreateFrame("Frame", "MythicIOGrabber_ApplicationViewer", miog.mainFrame, "BackdropTemplate") ---@class Frame
miog.searchPanel = CreateFrame("Frame", "MythicIOGrabber_SearchPanel", miog.mainFrame, "BackdropTemplate") ---@class Frame

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

local function positionTab1ToActiveFrame(frame)
	frame:SetHeight(frame.extendedHeight)
	PVEFrameTab1:SetParent(frame)
	PVEFrameTab1:ClearAllPoints()
	PVEFrameTab1:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)

	PVEFrameTab1:SetWidth(PVEFrameTab1:GetWidth() - 2)
	PVEFrameTab2:SetWidth(PVEFrameTab2:GetWidth() - 2)
	PVEFrameTab3:SetWidth(PVEFrameTab3:GetWidth() - 2)

end

local function positionTab1ToPVEFrame(frame)
	frame:SetHeight(frame.standardHeight)
	PVEFrameTab1:SetParent(PVEFrame)
	PVEFrameTab1:ClearAllPoints()
	insertPointsIntoFrame(PVEFrameTab1, pveFrameTab1_Point)

	PVEFrameTab1:SetWidth(PVEFrameTab1:GetWidth() + 2)
	PVEFrameTab2:SetWidth(PVEFrameTab2:GetWidth() + 2)
	PVEFrameTab3:SetWidth(PVEFrameTab3:GetWidth() + 2)

end

local function createMainFrame()
	local mainFrame = miog.mainFrame ---@class Frame
    pveFrameTab1_Point = insertPointsIntoTable(PVEFrameTab1)

	mainFrame.standardWidth = (LFGListFrame:GetWidth() + 2)
	mainFrame.standardHeight = (LFGListPVEStub:GetHeight() - PVEFrame.TitleContainer:GetHeight() - 5)
	mainFrame:SetSize(mainFrame.standardWidth, mainFrame.standardHeight)
	mainFrame.extendedHeight = MIOG_SavedSettings and MIOG_SavedSettings.frameManuallyResized and MIOG_SavedSettings.frameManuallyResized.value > 0 and MIOG_SavedSettings.frameManuallyResized.value or mainFrame.standardHeight * 1.5
	--applicationViewer:SetScale(1.5)
	mainFrame:SetResizable(true)
	mainFrame:SetPoint(LFGListFrame.ApplicationViewer:GetPoint())
	mainFrame:SetFrameStrata("DIALOG")
	mainFrame:AdjustPointsOffset(-4, -PVEFrame.TitleContainer:GetHeight() - 1)
	mainFrame:SetResizeBounds(mainFrame.standardWidth, mainFrame.standardHeight, mainFrame.standardWidth, GetScreenHeight() * 0.66666)
	
	mainFrame:SetScript("OnEnter", function(_, button)
		
	end)

	miog.createFrameBorder(mainFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	mainFrame:HookScript("OnShow", function()
		if(MIOG_SavedSettings.frameExtended.value) then
			positionTab1ToActiveFrame(mainFrame)

		end
	end)

	mainFrame:HookScript("OnHide", function()
		positionTab1ToPVEFrame(mainFrame)

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
	expandDownwardsButton:SetPoint("RIGHT", openSettingsButton, "LEFT", 0, -expandDownwardsButton:GetHeight() / 4)
	expandDownwardsButton:SetNormalTexture(293770)
	expandDownwardsButton:SetPushedTexture(293769)
	expandDownwardsButton:SetDisabledTexture(293768)

	expandDownwardsButton:RegisterForClicks("LeftButtonDown")
	expandDownwardsButton:SetScript("OnClick", function()

		MIOG_SavedSettings.frameExtended.value = not MIOG_SavedSettings.frameExtended.value

		if(MIOG_SavedSettings.frameExtended.value) then
			positionTab1ToActiveFrame(mainFrame)

		elseif(not MIOG_SavedSettings.frameExtended.value) then
			positionTab1ToPVEFrame(mainFrame)

		end
	end)

	mainFrame.expandDownwardsButton = expandDownwardsButton

	local raiderIOAddonIsLoadedFrame = miog.createBasicFontString("persistent", 16, mainFrame)
	raiderIOAddonIsLoadedFrame:SetPoint("RIGHT", openSettingsButton, "LEFT", - 5 - expandDownwardsButton:GetWidth(), 0)
	raiderIOAddonIsLoadedFrame:SetJustifyH("RIGHT")
	raiderIOAddonIsLoadedFrame:SetText(WrapTextInColorCode("NO R.IO", miog.CLRSCC["red"]))
	raiderIOAddonIsLoadedFrame:SetShown(not miog.F.IS_RAIDERIO_LOADED)

	mainFrame.raiderIOAddonIsLoadedFrame = raiderIOAddonIsLoadedFrame

	local throttledString = miog.createBasicFontString("persistent", 16, mainFrame)
	throttledString:SetWordWrap(true)
	throttledString:SetNonSpaceWrap(true)
	throttledString:SetText("Search is throttled.\nWait 2 seconds.")
	throttledString:SetJustifyH("CENTER")
	throttledString:SetPoint("TOP", mainFrame, "TOP", 0, -50)
	throttledString:SetDrawLayer("BACKGROUND", 0)
	throttledString:Hide()
	mainFrame.throttledString = throttledString
	
	local resizeApplicationViewerButton = miog.createBasicFrame("persistent", "UIButtonTemplate", mainFrame)
	resizeApplicationViewerButton:EnableMouse(true)
	resizeApplicationViewerButton:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 22)
	resizeApplicationViewerButton:SetSize(20, 20)
	resizeApplicationViewerButton:SetFrameStrata("FULLSCREEN")
	resizeApplicationViewerButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	resizeApplicationViewerButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	resizeApplicationViewerButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	resizeApplicationViewerButton:SetScript("OnMouseDown", function()
		mainFrame:StartSizing()

	end)
	resizeApplicationViewerButton:SetScript("OnMouseUp", function()
		mainFrame:StopMovingOrSizing()

		MIOG_SavedSettings.frameManuallyResized.value = mainFrame:GetHeight()

		if(MIOG_SavedSettings.frameManuallyResized.value > mainFrame.standardHeight) then
			MIOG_SavedSettings.frameExtended.value = true
			mainFrame.extendedHeight = MIOG_SavedSettings.frameManuallyResized.value

		end

	end)
end

local function createApplicationViewer()
	local applicationViewer = miog.applicationViewer ---@class Frame
	applicationViewer:SetPoint("TOPLEFT", miog.mainFrame, "TOPLEFT")
	applicationViewer:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT")
	applicationViewer:SetFrameStrata("DIALOG")

	local classPanel = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", applicationViewer)
	classPanel:SetPoint("TOPRIGHT", applicationViewer, "TOPLEFT", -1, -2)
	classPanel.fixedWidth = 28

	applicationViewer.classPanel = classPanel

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

	local titleBar = miog.createBasicFrame("persistent", "BackdropTemplate", applicationViewer, nil, miog.mainFrame.standardHeight*0.06)
	titleBar:SetPoint("TOPLEFT", applicationViewer, "TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", applicationViewer, "TOPRIGHT", 0, 0)
	miog.createFrameBorder(titleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	titleBar.factionIconSize = titleBar:GetHeight() - 4
	applicationViewer.titleBar = titleBar

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

	local infoPanel = miog.createBasicFrame("persistent", "BackdropTemplate", applicationViewer)
	infoPanel:SetHeight(miog.mainFrame.standardHeight*0.19)
	infoPanel:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 1)
	infoPanel:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", -20, 1)

	applicationViewer.infoPanel = infoPanel

	local knownIssuesPanel = miog.createBasicFrame("persistent", "IconButtonTemplate", infoPanel, 15, 15)
	knownIssuesPanel:SetNormalAtlas("glueannouncementpopup-icon-info")
	knownIssuesPanel:SetHighlightAtlas("glueannouncementpopup-icon-info")
	knownIssuesPanel:SetPoint("TOPRIGHT", infoPanel, "TOPRIGHT", -4, -4)
	knownIssuesPanel:SetScript("OnEnter", function()
		GameTooltip:SetOwner(knownIssuesPanel, "ANCHOR_TOPRIGHT")
		GameTooltip:Show()

	end)
	knownIssuesPanel:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)
	knownIssuesPanel:Hide()

	local infoPanelBackdropFrame = miog.createBasicFrame("persistent", "BackdropTemplate", infoPanel)
	infoPanelBackdropFrame:SetPoint("TOPLEFT", infoPanel, "TOPLEFT")
	infoPanelBackdropFrame:SetPoint("BOTTOMRIGHT", infoPanel, "BOTTOMRIGHT")
	infoPanelBackdropFrame.backdropInfo = {
		bgFile=miog.ACTIVITY_BACKGROUNDS[10],
		tileSize=miog.C.APPLICANT_MEMBER_HEIGHT,
		tile=false,
		edgeSize=2,
		insets={left=1, right=1, top=1, bottom=0}
	}

	infoPanelBackdropFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	infoPanelBackdropFrame:ApplyBackdrop()
	infoPanelBackdropFrame.Center:SetDrawLayer("BACKGROUND", 1)

	applicationViewer.infoPanelBackdropFrame = infoPanelBackdropFrame

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
	commentScrollFrame.ScrollBar:Hide()

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

	applicationViewer.listingSettingPanel = listingSettingPanel

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
	miog.createFrameBorder(buttonPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	buttonPanel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	applicationViewer.buttonPanel = buttonPanel

	local expandFilterPanelButton = Mixin(miog.createBasicFrame("persistent", "UIButtonTemplate", buttonPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), MultiStateButtonMixin)
	expandFilterPanelButton:OnLoad()
	expandFilterPanelButton:SetMaxStates(2)
	expandFilterPanelButton:SetTexturesForBaseState("UI-HUD-ActionBar-PageDownArrow-Up", "UI-HUD-ActionBar-PageDownArrow-Down", "UI-HUD-ActionBar-PageDownArrow-Mouseover", "UI-HUD-ActionBar-PageDownArrow-Disabled")
	expandFilterPanelButton:SetTexturesForState1("UI-HUD-ActionBar-PageUpArrow-Up", "UI-HUD-ActionBar-PageUpArrow-Down", "UI-HUD-ActionBar-PageUpArrow-Mouseover", "UI-HUD-ActionBar-PageUpArrow-Disabled")
	expandFilterPanelButton:SetState(false)
	expandFilterPanelButton:SetPoint("LEFT", buttonPanel, "LEFT", 2, 0)
	expandFilterPanelButton:SetFrameStrata("DIALOG")
	expandFilterPanelButton:RegisterForClicks("LeftButtonDown")
	expandFilterPanelButton:SetScript("OnClick", function()
		if(buttonPanel.filterPanel) then
			expandFilterPanelButton:AdvanceState()
			buttonPanel.filterPanel:SetShown(not buttonPanel.filterPanel:IsVisible())

		end

	end)
	buttonPanel.expandButton = expandFilterPanelButton

	local filterString = miog.createBasicFontString("persistent", 12, buttonPanel)
	filterString:SetPoint("LEFT", expandFilterPanelButton, "RIGHT", 2, -1)
	filterString:SetJustifyH("CENTER")
	filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

	local filterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", buttonPanel, 220, 300)
	filterPanel:SetPoint("TOPLEFT", buttonPanel, "BOTTOMLEFT")
	filterPanel:Hide()
	miog.createFrameBorder(filterPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	filterPanel:SetBackdropColor(0.1, 0.1, 0.1, 1)

	buttonPanel.filterPanel = filterPanel

	local roleFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", filterPanel, 150, 20)
	roleFilterPanel:SetPoint("TOPLEFT", filterPanel, "TOPLEFT", 1, -4)
	roleFilterPanel.RoleTextures = {}
	roleFilterPanel.RoleButtons = {}

	filterPanel.roleFilterPanel = roleFilterPanel

	for i = 1, 3, 1 do
		local toggleRoleButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", roleFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
		toggleRoleButton:SetNormalAtlas("checkbox-minimal")
		toggleRoleButton:SetPushedAtlas("checkbox-minimal")
		toggleRoleButton:SetCheckedTexture("checkmark-minimal")
		toggleRoleButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		toggleRoleButton:SetPoint("LEFT", roleFilterPanel.RoleTextures[i-1] or roleFilterPanel, roleFilterPanel.RoleTextures[i-1] and "RIGHT" or "LEFT", roleFilterPanel.RoleTextures[i-1] and 8 or 0, 0)
		toggleRoleButton:RegisterForClicks("LeftButtonDown")
		toggleRoleButton:SetChecked(true)

		local roleTexture = miog.createBasicTexture("persistent", nil, roleFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 3, miog.C.APPLICANT_MEMBER_HEIGHT - 3, "ARTWORK")
		roleTexture:SetPoint("LEFT", toggleRoleButton, "RIGHT", 0, 0)

		toggleRoleButton:SetScript("OnClick", function()
			if(not miog.checkForActiveFilters(filterPanel)) then
				filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

			C_LFGList.RefreshApplicants()

		end)

		if(i == 1) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")

		elseif(i == 2) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")

		elseif(i == 3) then
			roleTexture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")

		end

		roleFilterPanel.RoleButtons[i] = toggleRoleButton
		roleFilterPanel.RoleTextures[i] = roleTexture

	end

	local classFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", filterPanel, filterPanel:GetWidth() - 2, filterPanel:GetHeight() - roleFilterPanel:GetHeight())
	classFilterPanel:SetPoint("TOPLEFT", roleFilterPanel, "BOTTOMLEFT", 0, -2)
	classFilterPanel.ClassPanels = {}

	filterPanel.classFilterPanel = classFilterPanel

	for classIndex, classEntry in ipairs(miog.CLASSES) do
		local singleClassPanel = miog.createBasicFrame("persistent", "BackdropTemplate", classFilterPanel, classFilterPanel:GetWidth(), 20)
		singleClassPanel:SetPoint("TOPLEFT", classFilterPanel.ClassPanels[classIndex-1] or classFilterPanel, classFilterPanel.ClassPanels[classIndex-1] and "BOTTOMLEFT" or "TOPLEFT", 0, -1)
		local r, g, b = GetClassColor(classEntry.name)
		miog.createFrameBorder(singleClassPanel, 1, r, g, b, 0.9)
		singleClassPanel:SetBackdropColor(r, g, b, 0.6)

		local toggleClassButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", classFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
		toggleClassButton:SetNormalAtlas("checkbox-minimal")
		toggleClassButton:SetPushedAtlas("checkbox-minimal")
		toggleClassButton:SetCheckedTexture("checkmark-minimal")
		toggleClassButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		toggleClassButton:RegisterForClicks("LeftButtonDown")
		toggleClassButton:SetChecked(true)
		toggleClassButton:SetPoint("LEFT", singleClassPanel, "LEFT")
		singleClassPanel.Button = toggleClassButton

		local classTexture = miog.createBasicTexture("persistent", miog.C.STANDARD_FILE_PATH .. "/classIcons/" .. classEntry.name .. "_round.png", singleClassPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 3, miog.C.APPLICANT_MEMBER_HEIGHT - 3, "ARTWORK")
		classTexture:SetPoint("LEFT", toggleClassButton, "RIGHT", 0, 0)
		singleClassPanel.Texture = classTexture

		local specFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", singleClassPanel, 200, 180)
		specFilterPanel:SetPoint("TOPLEFT", roleFilterPanel, "BOTTOMLEFT")
		specFilterPanel.SpecTextures = {}
		specFilterPanel.SpecButtons = {}

		singleClassPanel.specFilterPanel = specFilterPanel
		classFilterPanel.ClassPanels[classIndex] = singleClassPanel

		for specIndex, specID in pairs(classEntry.specs) do
			local specEntry = miog.SPECIALIZATIONS[specID]

			local toggleSpecButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", specFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
			toggleSpecButton:SetNormalAtlas("checkbox-minimal")
			toggleSpecButton:SetPushedAtlas("checkbox-minimal")
			toggleSpecButton:SetCheckedTexture("checkmark-minimal")
			toggleSpecButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
			toggleSpecButton:SetPoint("LEFT", specFilterPanel.SpecTextures[classEntry.specs[specIndex-1]] or classTexture, "RIGHT", 8, 0)
			toggleSpecButton:RegisterForClicks("LeftButtonDown")
			toggleSpecButton:SetChecked(true)
			toggleSpecButton:SetScript("OnClick", function()
				if(toggleSpecButton:GetChecked()) then
					toggleClassButton:SetChecked(true)

					if(not miog.checkForActiveFilters(filterPanel)) then
						filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

					end

				else
					filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

				end

				C_LFGList.RefreshApplicants()

			end)

			local specTexture = miog.createBasicTexture("persistent", specEntry.icon, specFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 4, miog.C.APPLICANT_MEMBER_HEIGHT - 4, "ARTWORK")
			specTexture:SetPoint("LEFT", toggleSpecButton, "RIGHT", 0, 0)

			specFilterPanel.SpecTextures[specID] = specTexture
			specFilterPanel.SpecButtons[specID] = toggleSpecButton

		end

		toggleClassButton:SetScript("OnClick", function()

			for k,v in pairs(specFilterPanel.SpecButtons) do

				if(toggleClassButton:GetChecked()) then
					v:SetChecked(true)

				else
					v:SetChecked(false)

				end

			end

			if(not miog.checkForActiveFilters(filterPanel)) then
				filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

			C_LFGList.RefreshApplicants()
		end)

	end

	local uncheckAllFiltersButton = miog.createBasicFrame("persistent", "IconButtonTemplate", filterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
	uncheckAllFiltersButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	uncheckAllFiltersButton.iconSize = miog.C.APPLICANT_MEMBER_HEIGHT - 3
	uncheckAllFiltersButton:OnLoad()
	uncheckAllFiltersButton:SetPoint("TOPRIGHT", filterPanel, "TOPRIGHT", 1, -5)
	uncheckAllFiltersButton:SetFrameStrata("DIALOG")
	uncheckAllFiltersButton:RegisterForClicks("LeftButtonUp")
	uncheckAllFiltersButton:SetScript("OnClick", function()
		for _, v in pairs(classFilterPanel.ClassPanels) do
			v.Button:SetChecked(false)

			for _, y in pairs(v.specFilterPanel.SpecButtons) do
				y:SetChecked(false)

			end

		end

		--for _, v in pairs(roleFilterPanel.RoleButtons) do
		--	v:SetChecked(false)

		--end

		if(not miog.checkForActiveFilters(filterPanel)) then
			filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

		else
			filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

		end

		C_LFGList.RefreshApplicants()
	end)
	filterPanel.uncheckAllFiltersButton = uncheckAllFiltersButton

	local checkAllFiltersButton = miog.createBasicFrame("persistent", "IconButtonTemplate", filterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
	checkAllFiltersButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png"
	checkAllFiltersButton.iconSize = miog.C.APPLICANT_MEMBER_HEIGHT - 3
	checkAllFiltersButton:OnLoad()
	checkAllFiltersButton:SetPoint("RIGHT", uncheckAllFiltersButton, "LEFT", -3, 0)
	checkAllFiltersButton:SetFrameStrata("DIALOG")
	checkAllFiltersButton:RegisterForClicks("LeftButtonUp")
	checkAllFiltersButton:SetScript("OnClick", function()
		for _, v in pairs(classFilterPanel.ClassPanels) do
			v.Button:SetChecked(true)

			for _, y in pairs(v.specFilterPanel.SpecButtons) do
				y:SetChecked(true)

			end

			if(not miog.checkForActiveFilters(filterPanel)) then
				filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

		end

		--for _, v in pairs(roleFilterPanel.RoleButtons) do
		--	v:SetChecked(true)

		--end

		C_LFGList.RefreshApplicants()
	end)
	filterPanel.checkAllFiltersButton = checkAllFiltersButton


	buttonPanel.sortByCategoryButtons = {}

	for i = 1, 4, 1 do

		local sortByCategoryButton = Mixin(miog.createBasicFrame("persistent", "UIButtonTemplate", buttonPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), MultiStateButtonMixin)
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

			miog.applicationViewer.applicantPanel:SetVerticalScroll(0)
		end
	)

	buttonPanel.resetButton = resetButton


	local lastInvitesPanel = miog.createBasicFrame("persistent", "BackdropTemplate", applicationViewer, 250, 250)
	lastInvitesPanel:SetPoint("TOPLEFT", titleBar, "TOPRIGHT", 5, 0)
	miog.createFrameBorder(lastInvitesPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	lastInvitesPanel.standardHeight = 140
	lastInvitesPanel:Hide()

	applicationViewer.lastInvitesPanel = lastInvitesPanel

	local lastInvitesShowHideButton = miog.createBasicFrame("persistent", "UIButtonTemplate, BackdropTemplate", applicationViewer, 20, 100)
	lastInvitesShowHideButton:SetPoint("TOPLEFT", infoPanel, "TOPRIGHT")
	lastInvitesShowHideButton:SetPoint("BOTTOMLEFT", buttonPanel, "BOTTOMRIGHT", 0, 0)
	miog.createFrameBorder(lastInvitesShowHideButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	lastInvitesShowHideButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	lastInvitesShowHideButton:RegisterForClicks("LeftButtonDown")
	lastInvitesShowHideButton:SetScript("OnClick", function()
		lastInvitesPanel:SetShown(not lastInvitesPanel:IsVisible())

	end)

	local lastInvitesShowHideString = miog.createBasicFontString("persistent", 16, lastInvitesShowHideButton)
	lastInvitesShowHideString:SetJustifyV("TOP")
	lastInvitesShowHideString:SetPoint("TOPLEFT", lastInvitesShowHideButton, "TOPLEFT", 4, -5)
	lastInvitesShowHideString:SetText(string.gsub("INVITES", "(.)", function(x) return x.."\n" end))
	lastInvitesShowHideString:SetSpacing(0)
	lastInvitesShowHideString:SetNonSpaceWrap(true)
	lastInvitesShowHideString:SetWordWrap(true)

	local lastInvitesPanelBackground = miog.createBasicTexture("persistent", miog.C.STANDARD_FILE_PATH .. "/backgrounds/df-bg-1.png", lastInvitesPanel)
	lastInvitesPanelBackground:SetTexCoord(0, 1, 0.25, 0.9)
	--lastInvitesPanelBackground:SetVertTile(true)
	--lastInvitesPanelBackground:SetHorizTile(true)
	lastInvitesPanelBackground:SetDrawLayer("BACKGROUND", -8)
	lastInvitesPanelBackground:SetPoint("TOPLEFT", lastInvitesPanel, "TOPLEFT")
	lastInvitesPanelBackground:SetPoint("BOTTOMRIGHT", lastInvitesPanel, "BOTTOMRIGHT")

	local lastInvitesTitleBar = miog.createBasicFrame("persistent", "BackdropTemplate", lastInvitesPanel, nil, miog.mainFrame.standardHeight*0.06)
	lastInvitesTitleBar:SetPoint("TOPLEFT", lastInvitesPanel, "TOPLEFT", 0, 0)
	lastInvitesTitleBar:SetPoint("TOPRIGHT", lastInvitesPanel, "TOPRIGHT", 0, 0)
	miog.createFrameBorder(lastInvitesTitleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	lastInvitesTitleBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local lastInvitesTitleBarString = miog.createBasicFontString("persistent", miog.C.TITLE_FONT_SIZE, lastInvitesTitleBar)
	lastInvitesTitleBarString:SetText("Last Invites")
	lastInvitesTitleBarString:SetPoint("CENTER", lastInvitesTitleBar, "CENTER")

	local lastInvitesRetractSidewardsButton = miog.createBasicFrame("persistent", "UIButtonTemplate", lastInvitesPanel, miog.C.APPLICANT_BUTTON_SIZE, miog.C.APPLICANT_BUTTON_SIZE)
	lastInvitesRetractSidewardsButton:SetPoint("RIGHT", lastInvitesTitleBar, "RIGHT", -5, -2)

	lastInvitesRetractSidewardsButton:SetNormalTexture(293770)
	lastInvitesRetractSidewardsButton:SetDisabledTexture(293768)
	lastInvitesRetractSidewardsButton:GetNormalTexture():SetRotation(-math.pi/2)
	lastInvitesRetractSidewardsButton:GetDisabledTexture():SetRotation(-math.pi/2)

	lastInvitesRetractSidewardsButton:RegisterForClicks("LeftButtonDown")
	lastInvitesRetractSidewardsButton:SetScript("OnClick", function()
		lastInvitesPanel:Hide()

	end)

	--lastInvitesPanel.expandDownwardsButton = expandDownwardsButton

	local lastInvitesScrollFrame = miog.createBasicFrame("persistent", "ScrollFrameTemplate", lastInvitesPanel)
	lastInvitesScrollFrame:SetPoint("TOPLEFT", lastInvitesTitleBar, "BOTTOMLEFT", 1, 0)
	lastInvitesScrollFrame:SetPoint("BOTTOMRIGHT", lastInvitesPanel, "BOTTOMRIGHT", -1, 1)
	lastInvitesPanel.scrollFrame = lastInvitesScrollFrame

	local lastInvitesContainer = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", lastInvitesScrollFrame)
	lastInvitesContainer.fixedWidth = lastInvitesScrollFrame:GetWidth()
	lastInvitesContainer.minimumHeight = 1
	lastInvitesContainer.spacing = 3
	lastInvitesContainer.align = "top"
	lastInvitesContainer:SetPoint("TOPLEFT", lastInvitesScrollFrame, "TOPLEFT")

	lastInvitesScrollFrame.container = lastInvitesContainer
	lastInvitesScrollFrame:SetScrollChild(lastInvitesContainer)

	local footerBar = miog.createBasicFrame("persistent", "BackdropTemplate", titleBar)
	footerBar:SetPoint("BOTTOMLEFT", applicationViewer, "BOTTOMLEFT", 0, 0)
	footerBar:SetPoint("TOPRIGHT", applicationViewer, "BOTTOMRIGHT", 0, miog.mainFrame.standardHeight*0.06)
	miog.createFrameBorder(footerBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	footerBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	applicationViewer.footerBar = footerBar

	local browseGroupsButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", footerBar, 1, footerBar:GetHeight())
	browseGroupsButton:SetPoint("LEFT", footerBar, "LEFT")
	browseGroupsButton:SetText("Browse Groups")
	browseGroupsButton:FitToText()
	browseGroupsButton:RegisterForClicks("LeftButtonDown")
	browseGroupsButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		local baseFilters = LFGListFrame.baseFilters
		local searchPanel = LFGListFrame.SearchPanel
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		if(activeEntryInfo) then
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
			if(activityInfo) then
				LFGListSearchPanel_SetCategory(searchPanel, activityInfo.categoryID, activityInfo.filters, baseFilters)
				LFGListFrame_SetActivePanel(LFGListFrame, searchPanel)
				LFGListSearchPanel_DoSearch(searchPanel)
			end
		end
	end)

	footerBar.browseGroupsButton = browseGroupsButton

	local delistButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", footerBar, 1, footerBar:GetHeight())
	delistButton:SetPoint("LEFT", browseGroupsButton, "RIGHT")
	delistButton:SetText("Delist")
	delistButton:FitToText()
	delistButton:RegisterForClicks("LeftButtonDown")
	delistButton:SetScript("OnClick", function()
		C_LFGList.RemoveListing()
	end)

	footerBar.delistButton = delistButton

	local editButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", footerBar, 1, footerBar:GetHeight())
	editButton:SetPoint("LEFT", delistButton, "RIGHT")
	editButton:SetText("Edit")
	editButton:FitToText()
	editButton:RegisterForClicks("LeftButtonDown")
	editButton:SetScript("OnClick", function()
		local entryCreation = LFGListFrame.EntryCreation
		LFGListEntryCreation_SetEditMode(entryCreation, true)
		LFGListFrame_SetActivePanel(LFGListFrame, entryCreation)
	end)

	footerBar.editButton = editButton

	local applicantNumberFontString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, footerBar)
	applicantNumberFontString:SetPoint("RIGHT", footerBar, "RIGHT", -3, -1)
	applicantNumberFontString:SetJustifyH("CENTER")
	applicantNumberFontString:SetText(0)

	footerBar.applicantNumberFontString = applicantNumberFontString

	local applicantPanel = miog.createBasicFrame("persistent", "ScrollFrameTemplate", titleBar)
	applicantPanel:SetPoint("TOPLEFT", buttonPanel, "BOTTOMLEFT", 2, 0)
	applicantPanel:SetPoint("BOTTOMRIGHT", footerBar, "TOPRIGHT", 0, 0)
	applicationViewer.applicantPanel = applicantPanel
	applicantPanel.ScrollBar:SetPoint("TOPLEFT", applicantPanel, "TOPRIGHT", 0, -10)
	applicantPanel.ScrollBar:SetPoint("BOTTOMLEFT", applicantPanel, "BOTTOMRIGHT", 0, 10)

	miog.C.MAIN_WIDTH = applicantPanel:GetWidth()

	local applicantPanelContainer = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", applicantPanel)
	applicantPanelContainer.fixedWidth = applicantPanel:GetWidth()
	applicantPanelContainer.minimumHeight = 1
	applicantPanelContainer.spacing = 5
	applicantPanelContainer.align = "top"
	applicantPanelContainer:SetPoint("TOPLEFT", applicantPanel, "TOPLEFT")
	applicantPanel.container = applicantPanelContainer

	applicantPanel:SetScrollChild(applicantPanelContainer)
end

local lastFilterOption = nil

local function addOptionToFilterFrame(text, name)
	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", miog.searchPanel.filterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	optionButton:SetPoint("TOPLEFT", lastFilterOption or miog.searchPanel.filterFrame, lastFilterOption and "BOTTOMLEFT" or "TOPLEFT", 0, lastFilterOption and -5 or -20)
	optionButton:RegisterForClicks("LeftButtonDown")
	optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[name] or false)
	optionButton:HookScript("OnClick", function()
		MIOG_SavedSettings.searchPanel_FilterOptions.table[name] = optionButton:GetChecked()
		miog.updateSearchResultList(true)
	end)

	miog.searchPanel.filterFrame[name] = optionButton

	local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.filterFrame)
	optionString:SetPoint("LEFT", optionButton, "RIGHT")
	optionString:SetText(text)

	lastFilterOption = optionButton
end

local function addNumericSpinnerToFilterFrame(text, name)
	local numericSpinner = Mixin(miog.createBasicFrame("persistent", "InputBoxTemplate", miog.searchPanel.filterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 5, miog.C.INTERFACE_OPTION_BUTTON_SIZE), NumericInputSpinnerMixin)
	numericSpinner:SetAutoFocus(false)
	numericSpinner:SetNumeric(true)
	numericSpinner:SetMaxLetters(1)
	numericSpinner:SetMinMaxValues(0, 9)
	numericSpinner:SetValue(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[name] or 0)

	local decrementButton = miog.createBasicFrame("persistent", "UIButtonTemplate", numericSpinner, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	decrementButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Up")
	decrementButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Down")
	decrementButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Disabled")
	decrementButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
	decrementButton:SetPoint("TOPLEFT", lastFilterOption or miog.searchPanel.filterFrame, "BOTTOMLEFT", 0, -5)
	decrementButton:SetScript("OnMouseDown", function()
		if decrementButton:IsEnabled() then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			numericSpinner:StartDecrement()

		end
	end)
	decrementButton:SetScript("OnMouseUp", function()
		numericSpinner:EndIncrement()
		MIOG_SavedSettings.searchPanel_FilterOptions.table[name] = numericSpinner:GetValue()
		numericSpinner:ClearFocus()
		miog.updateSearchResultList(true)

	end)

	numericSpinner:SetPoint("LEFT", decrementButton, "RIGHT", 6, 0)

	local incrementButton = miog.createBasicFrame("persistent", "UIButtonTemplate", numericSpinner, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	incrementButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Up")
	incrementButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Down")
	incrementButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Disabled")
	incrementButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
	incrementButton:SetPoint("LEFT", numericSpinner, "RIGHT")
	incrementButton:SetScript("OnMouseDown", function()
		if incrementButton:IsEnabled() then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			numericSpinner:StartIncrement()
		end
	end)
	incrementButton:SetScript("OnMouseUp", function()
		numericSpinner:EndIncrement()
		MIOG_SavedSettings.searchPanel_FilterOptions.table[name] = numericSpinner:GetValue()
		numericSpinner:ClearFocus()
		miog.updateSearchResultList(true)

	end)

	miog.searchPanel.filterFrame[name] = numericSpinner

	local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.filterFrame)
	optionString:SetPoint("LEFT", incrementButton, "RIGHT")
	optionString:SetText(text)

	lastFilterOption = decrementButton

end

local function addDualNumericSpinnerToFilterFrame(name)
	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", miog.searchPanel.filterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	optionButton:SetPoint("TOPLEFT", lastFilterOption, "BOTTOMLEFT", 0, -5)
	optionButton:RegisterForClicks("LeftButtonDown")
	optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name] or false)
	optionButton:HookScript("OnClick", function()
		MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name] = optionButton:GetChecked()
		miog.updateSearchResultList(true)
	end)

	miog.searchPanel.filterFrame["filterFor" .. name] = optionButton

	local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.filterFrame)
	optionString:SetPoint("LEFT", optionButton, "RIGHT")
	optionString:SetText(name)

	local minName = "min" .. name
	local maxName = "max" .. name
	local filterFrameWidth = miog.searchPanel.filterFrame:GetWidth() * 0.30

	for i = 1, 2, 1 do
		local numericSpinner = Mixin(miog.createBasicFrame("persistent", "InputBoxTemplate", miog.searchPanel.filterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 5, miog.C.INTERFACE_OPTION_BUTTON_SIZE), NumericInputSpinnerMixin)
		numericSpinner:SetAutoFocus(false)
		numericSpinner.autoFocus = false
		numericSpinner:SetNumeric(true)
		numericSpinner:SetMaxLetters(1)
		numericSpinner:SetMinMaxValues(0, 9)
		numericSpinner:SetValue(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] or 0)

		local decrementButton = miog.createBasicFrame("persistent", "UIButtonTemplate", numericSpinner, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		decrementButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Up")
		decrementButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Down")
		decrementButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Disabled")
		decrementButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
		decrementButton:SetPoint("LEFT", i == 1 and optionString or miog.searchPanel.filterFrame[minName].incrementButton, i == 1 and "LEFT" or "RIGHT", i == 1 and filterFrameWidth or 0, 0)
		decrementButton:SetScript("OnMouseDown", function()
			--PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			numericSpinner:Decrement()

			local spinnerValue = numericSpinner:GetValue()

			MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] = spinnerValue

			if(i == 2 and miog.searchPanel.filterFrame[minName]:GetValue() > spinnerValue) then
				miog.searchPanel.filterFrame[minName]:SetValue(spinnerValue)
				MIOG_SavedSettings.searchPanel_FilterOptions.table[minName] = spinnerValue

			end

			numericSpinner:ClearFocus()

			if(optionButton:GetChecked()) then
				miog.updateSearchResultList(true)

			end
		end)

		numericSpinner:SetPoint("LEFT", decrementButton, "RIGHT", 6, 0)
		numericSpinner.decrementButton = decrementButton

		local incrementButton = miog.createBasicFrame("persistent", "UIButtonTemplate", numericSpinner, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		incrementButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Up")
		incrementButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Down")
		incrementButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-NextPage-Disabled")
		incrementButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
		incrementButton:SetPoint("LEFT", numericSpinner, "RIGHT")
		incrementButton:SetScript("OnMouseDown", function()
			--PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			numericSpinner:Increment()

			local spinnerValue = numericSpinner:GetValue()

			MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] = spinnerValue

			if(i == 1 and miog.searchPanel.filterFrame[maxName]:GetValue() < spinnerValue) then
				miog.searchPanel.filterFrame[maxName]:SetValue(spinnerValue)
				MIOG_SavedSettings.searchPanel_FilterOptions.table[maxName] = spinnerValue

			end

			numericSpinner:ClearFocus()

			if(optionButton:GetChecked()) then
				miog.updateSearchResultList(true)
				
			end
		end)
		numericSpinner.incrementButton = incrementButton

		miog.searchPanel.filterFrame[i == 1 and minName or maxName] = numericSpinner

		lastFilterOption = incrementButton
	end

	lastFilterOption = optionButton

end

local function addDualNumericFieldsToFilterFrame(name)
	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", miog.searchPanel.filterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	optionButton:SetPoint("TOPLEFT", lastFilterOption, "BOTTOMLEFT", 0, -5)
	optionButton:RegisterForClicks("LeftButtonDown")
	optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name] or false)
	optionButton:HookScript("OnClick", function()
		MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name] = optionButton:GetChecked()
		miog.updateSearchResultList(true)
	end)

	miog.searchPanel.filterFrame["filterFor" .. name] = optionButton

	local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.filterFrame)
	optionString:SetPoint("LEFT", optionButton, "RIGHT")
	optionString:SetText(name)

	local minName = "min" .. name
	local maxName = "max" .. name

	for i = 1, 2, 1 do
		local numericField = miog.createBasicFrame("persistent", "InputBoxTemplate", miog.searchPanel.filterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		numericField:SetPoint("LEFT", i == 1 and optionString or lastFilterOption, "RIGHT", 5, 0)
		numericField:SetAutoFocus(false)
		numericField.autoFocus = false
		numericField:SetNumeric(true)
		numericField:SetMaxLetters(4)
		numericField:SetText(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] or 0)
		numericField:HookScript("OnTextChanged", function(self, ...)
			local text = tonumber(self:GetText())
			MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] = text ~= nil and text or 0

			miog.updateSearchResultList(true)

		end)
		

		miog.searchPanel.filterFrame[i == 1 and minName or maxName] = numericField

		lastFilterOption = numericField
	end

	lastFilterOption = optionButton

end

local function addDungeonCheckboxes()
	local sortedSeasonDungeons = {}

	for activityID, activityEntry in pairs(miog.ACTIVITY_ID_INFO) do
		if(activityEntry.mPlusSeasons) then
			for _, seasonID in ipairs(activityEntry.mPlusSeasons) do
				if(seasonID == (miog.F.CURRENT_SEASON or C_MythicPlus.GetCurrentSeason())) then
					sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {activityID = activityID, name = activityEntry.shortName}

				end
			end
		end
	end

	table.sort(sortedSeasonDungeons, function(k1, k2)
		return k1.name < k2.name
	end)

	local dungeonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", miog.searchPanel.filterFrame, miog.searchPanel.filterFrame:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	dungeonPanel:SetPoint("TOPLEFT", lastFilterOption or miog.searchPanel.filterFrame, lastFilterOption and "BOTTOMLEFT" or "TOPLEFT", 0, -5)
	dungeonPanel.buttons = {}

	miog.searchPanel.filterFrame.dungeonPanel = dungeonPanel

	local dungeonPanelFirstRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, miog.searchPanel.filterFrame:GetWidth(), dungeonPanel:GetHeight() / 2)
	dungeonPanelFirstRow:SetPoint("TOPLEFT", dungeonPanel, "TOPLEFT")

	local dungeonPanelSecondRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, miog.searchPanel.filterFrame:GetWidth(), dungeonPanel:GetHeight() / 2)
	dungeonPanelSecondRow:SetPoint("BOTTOMLEFT", dungeonPanel, "BOTTOMLEFT")

	local counter = 0

	for _, activityEntry in ipairs(sortedSeasonDungeons) do
		local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", dungeonPanel, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		optionButton:SetPoint("LEFT", counter < 4 and dungeonPanelFirstRow or counter > 3 and dungeonPanelSecondRow, "LEFT", counter < 4 and counter * 57 or (counter - 4) * 57, 0)
		optionButton:SetNormalAtlas("checkbox-minimal")
		optionButton:SetPushedAtlas("checkbox-minimal")
		optionButton:SetCheckedTexture("checkmark-minimal")
		optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		optionButton:RegisterForClicks("LeftButtonDown")
		optionButton:SetChecked(MIOG_SavedSettings and (MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeons[activityEntry.activityID] and false or MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeons[activityEntry.activityID] and true))
		optionButton:HookScript("OnClick", function()
			MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeons[activityEntry.activityID] = optionButton:GetChecked()
			miog.updateSearchResultList(true)

		end)
	
		miog.searchPanel.filterFrame[activityEntry.activityID] = optionButton
	
		local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.filterFrame)
		optionString:SetPoint("LEFT", optionButton, "RIGHT")
		optionString:SetText(activityEntry.name)

		dungeonPanel.buttons[activityEntry.activityID] = optionButton

		optionButton.fontString = optionString

		counter = counter + 1
	end
		
	lastFilterOption = dungeonPanel
end

local function createSearchPanel()
	local searchPanel = miog.searchPanel ---@class Frame
	searchPanel:SetPoint("TOPLEFT", miog.mainFrame, "TOPLEFT")
	searchPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT")
	searchPanel:SetFrameStrata("DIALOG")

	searchPanel:HookScript("OnShow", function()
		miog.F.LISTED_CATEGORY_ID = LFGListFrame.SearchPanel.categoryID
	end)

	local filterFrame = miog.createBasicFrame("persistent", "BackdropTemplate", searchPanel, 220, 620)
	filterFrame:SetPoint("TOPLEFT", searchPanel, "TOPRIGHT", 10, 0)
	miog.createFrameBorder(filterFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	filterFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	filterFrame:Hide()

	searchPanel.filterFrame = filterFrame

	local filterString = miog.createBasicFontString("persistent", 12, filterFrame, filterFrame:GetWidth(), 20)
	filterString:SetPoint("TOPLEFT", filterFrame, "TOPLEFT", 0, -1)
	filterString:SetJustifyH("CENTER")
	filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

	local uncheckAllFiltersButton = miog.createBasicFrame("persistent", "IconButtonTemplate", filterFrame, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
	uncheckAllFiltersButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	uncheckAllFiltersButton.iconSize = miog.C.APPLICANT_MEMBER_HEIGHT - 3
	uncheckAllFiltersButton:OnLoad()
	uncheckAllFiltersButton:SetPoint("TOPRIGHT", filterFrame, "TOPRIGHT", 0, -2)
	uncheckAllFiltersButton:SetFrameStrata("DIALOG")
	uncheckAllFiltersButton:RegisterForClicks("LeftButtonUp")
	uncheckAllFiltersButton:SetScript("OnClick", function()
		for classIndex, v in pairs(miog.searchPanel.filterFrame.classFilterPanel.ClassPanels) do
			v.Button:SetChecked(false)

			for specIndex, y in pairs(v.specFilterPanel.SpecButtons) do
				y:SetChecked(false)
				MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.spec[specIndex] = false

			end

			MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.class[classIndex] = false

		end

		--for _, v in pairs(roleFilterPanel.RoleButtons) do
		--	v:SetChecked(false)

		--end

		if(not miog.checkForActiveFilters(filterFrame)) then
			filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

		else
			filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

		end

		miog.updateSearchResultList(true)
	end)
	filterFrame.uncheckAllFiltersButton = uncheckAllFiltersButton

	local checkAllFiltersButton = miog.createBasicFrame("persistent", "IconButtonTemplate", filterFrame, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
	checkAllFiltersButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png"
	checkAllFiltersButton.iconSize = miog.C.APPLICANT_MEMBER_HEIGHT - 3
	checkAllFiltersButton:OnLoad()
	checkAllFiltersButton:SetPoint("RIGHT", uncheckAllFiltersButton, "LEFT", -3, 0)
	checkAllFiltersButton:SetFrameStrata("DIALOG")
	checkAllFiltersButton:RegisterForClicks("LeftButtonUp")
	checkAllFiltersButton:SetScript("OnClick", function()
		for classIndex, v in pairs(miog.searchPanel.filterFrame.classFilterPanel.ClassPanels) do
			v.Button:SetChecked(true)

			for specIndex, y in pairs(v.specFilterPanel.SpecButtons) do
				y:SetChecked(true)

				MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.spec[specIndex] = true

			end

			MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.class[classIndex] = true

			if(not miog.checkForActiveFilters(filterFrame)) then
				filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

		end

		miog.updateSearchResultList(true)

	end)
	filterFrame.checkAllFiltersButton = checkAllFiltersButton

	addOptionToFilterFrame("Class / spec", "filterForClassSpecs")

	local classFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", filterFrame, filterFrame:GetWidth() - 2, 20 * 14)
	classFilterPanel:SetPoint("TOPLEFT", lastFilterOption or filterFrame, lastFilterOption and "BOTTOMLEFT" or "TOPLEFT", 0, lastFilterOption and -5 or -20)
	classFilterPanel.ClassPanels = {}

	filterFrame.classFilterPanel = classFilterPanel

	for classIndex, classEntry in ipairs(miog.CLASSES) do
		local singleClassPanel = miog.createBasicFrame("persistent", "BackdropTemplate", classFilterPanel, classFilterPanel:GetWidth(), 20)
		singleClassPanel:SetPoint("TOPLEFT", classFilterPanel.ClassPanels[classIndex-1] or classFilterPanel, classFilterPanel.ClassPanels[classIndex-1] and "BOTTOMLEFT" or "TOPLEFT", 0, -1)
		local r, g, b = GetClassColor(classEntry.name)
		miog.createFrameBorder(singleClassPanel, 1, r, g, b, 0.9)
		singleClassPanel:SetBackdropColor(r, g, b, 0.6)

		local toggleClassButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", classFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
		toggleClassButton:SetNormalAtlas("checkbox-minimal")
		toggleClassButton:SetPushedAtlas("checkbox-minimal")
		toggleClassButton:SetCheckedTexture("checkmark-minimal")
		toggleClassButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
		toggleClassButton:RegisterForClicks("LeftButtonDown")

		if(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec) then
			if(MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.class[classIndex] ~= nil) then
				toggleClassButton:SetChecked(MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.class[classIndex])
				filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			else
				toggleClassButton:SetChecked(true)

			end

		else
			toggleClassButton:SetChecked(true)

		end

		toggleClassButton:SetPoint("LEFT", singleClassPanel, "LEFT")
		singleClassPanel.Button = toggleClassButton

		local classTexture = miog.createBasicTexture("persistent", miog.C.STANDARD_FILE_PATH .. "/classIcons/" .. classEntry.name .. "_round.png", singleClassPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 3, miog.C.APPLICANT_MEMBER_HEIGHT - 3, "ARTWORK")
		classTexture:SetPoint("LEFT", toggleClassButton, "RIGHT", 0, 0)
		singleClassPanel.Texture = classTexture

		local specFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", singleClassPanel, 200, 180)
		specFilterPanel:SetPoint("TOPLEFT", classFilterPanel, "BOTTOMLEFT")
		specFilterPanel.SpecTextures = {}
		specFilterPanel.SpecButtons = {}

		singleClassPanel.specFilterPanel = specFilterPanel
		classFilterPanel.ClassPanels[classIndex] = singleClassPanel

		for specIndex, specID in pairs(classEntry.specs) do
			local specEntry = miog.SPECIALIZATIONS[specID]

			local toggleSpecButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", specFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT)
			toggleSpecButton:SetNormalAtlas("checkbox-minimal")
			toggleSpecButton:SetPushedAtlas("checkbox-minimal")
			toggleSpecButton:SetCheckedTexture("checkmark-minimal")
			toggleSpecButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
			toggleSpecButton:SetPoint("LEFT", specFilterPanel.SpecTextures[classEntry.specs[specIndex-1]] or classTexture, "RIGHT", 8, 0)
			toggleSpecButton:RegisterForClicks("LeftButtonDown")

			if(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec) then
				if(MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.spec[specID] ~= nil) then
					toggleSpecButton:SetChecked(MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.spec[specID])
					filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

				else
					toggleSpecButton:SetChecked(true)

				end

			else
				toggleSpecButton:SetChecked(true)

			end


			toggleSpecButton:SetScript("OnClick", function()
				local state = toggleSpecButton:GetChecked()

				if(state) then
					toggleClassButton:SetChecked(true)

					if(not miog.checkForActiveFilters(filterFrame)) then
						filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

					end

				else
					filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

				end

				MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.spec[specID] = state

				miog.updateSearchResultList(true)

			end)

			local specTexture = miog.createBasicTexture("persistent", specEntry.icon, specFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 4, miog.C.APPLICANT_MEMBER_HEIGHT - 4, "ARTWORK")
			specTexture:SetPoint("LEFT", toggleSpecButton, "RIGHT", 0, 0)

			specFilterPanel.SpecTextures[specID] = specTexture
			specFilterPanel.SpecButtons[specID] = toggleSpecButton

		end

		toggleClassButton:SetScript("OnClick", function()
			local state = toggleClassButton:GetChecked()

			for specIndex, v in pairs(specFilterPanel.SpecButtons) do

				if(state) then
					v:SetChecked(true)

				else
					v:SetChecked(false)

				end

				MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.spec[specIndex] = state
			end

			MIOG_SavedSettings.searchPanel_FilterOptions.table.classSpec.class[classIndex] = state

			if(not miog.checkForActiveFilters(filterFrame)) then
				filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

			miog.updateSearchResultList(true)
		end)

	end

	lastFilterOption = classFilterPanel.ClassPanels[13]
	
	local dropdownOptionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", filterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	dropdownOptionButton:SetNormalAtlas("checkbox-minimal")
	dropdownOptionButton:SetPushedAtlas("checkbox-minimal")
	dropdownOptionButton:SetCheckedTexture("checkmark-minimal")
	dropdownOptionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	dropdownOptionButton:SetPoint("TOPLEFT", lastFilterOption or filterFrame, "BOTTOMLEFT", 0, -5)
	dropdownOptionButton:RegisterForClicks("LeftButtonDown")
	dropdownOptionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForDifficulty or false)
	dropdownOptionButton:HookScript("OnClick", function()
		MIOG_SavedSettings.searchPanel_FilterOptions.table.filterForDifficulty = dropdownOptionButton:GetChecked()
		miog.updateSearchResultList(true)
	end)

	miog.searchPanel.filterFrame.filterForDifficulty = dropdownOptionButton

	local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", filterFrame)
	optionDropdown:SetPoint("LEFT", dropdownOptionButton, "RIGHT", -15, 0)
	UIDropDownMenu_SetWidth(optionDropdown, 175)
	UIDropDownMenu_SetText(optionDropdown, MIOG_SavedSettings.searchPanel_FilterOptions.table.difficultyID and miog.DIFFICULTY[MIOG_SavedSettings.searchPanel_FilterOptions.table.difficultyID].description or "Mythic+")
	UIDropDownMenu_Initialize(optionDropdown,
		function(frame, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			info.func = function(_, arg1, _, _)
				MIOG_SavedSettings.searchPanel_FilterOptions.table.difficultyID = arg1
				UIDropDownMenu_SetText(optionDropdown, MIOG_SavedSettings.searchPanel_FilterOptions.table.difficultyID and miog.DIFFICULTY[MIOG_SavedSettings.searchPanel_FilterOptions.table.difficultyID].description)
				
				miog.updateSearchResultList(true)
				CloseDropDownMenus()

			end

			for i = 4, 1, -1 do
				info.text, info.arg1 = miog.DIFFICULTY[i].description, i
				info.checked = i == MIOG_SavedSettings.searchPanel_FilterOptions.table.difficultyID
				UIDropDownMenu_AddButton(info)

			end
		end
	)

	lastFilterOption = dropdownOptionButton

	-- KEY LEVEL
	-- DUNGEONS

	addOptionToFilterFrame("Party fit", "partyFit")
	addOptionToFilterFrame("Ress fit", "ressFit")
	addOptionToFilterFrame("Lust fit", "lustFit")
	addDualNumericSpinnerToFilterFrame("Tanks")
	addDualNumericSpinnerToFilterFrame("Healers")
	addDualNumericSpinnerToFilterFrame("Damager")

	addDualNumericFieldsToFilterFrame("Score")

	local divider = miog.createBasicTexture("persistent", nil, filterFrame, filterFrame:GetWidth(), 1, "BORDER")
	divider:SetAtlas("UI-LFG-DividerLine")
	divider:SetPoint("BOTTOM", lastFilterOption, "BOTTOM", 0, -5)

	lastFilterOption = divider

	addOptionToFilterFrame("Dungeon options", "dungeonOptions")
	addDungeonCheckboxes()

	local footerBar = miog.createBasicFrame("persistent", "BackdropTemplate", searchPanel)
	footerBar:SetPoint("BOTTOMLEFT", searchPanel, "BOTTOMLEFT", 0, 0)
	footerBar:SetPoint("TOPRIGHT", searchPanel, "BOTTOMRIGHT", 0, miog.mainFrame.standardHeight*0.06)
	miog.createFrameBorder(footerBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	footerBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	searchPanel.footerBar = footerBar

	local backButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", footerBar, 1, footerBar:GetHeight())
	backButton:SetPoint("LEFT", footerBar, "LEFT")
	backButton:SetText("Back")
	backButton:FitToText()
	backButton:RegisterForClicks("LeftButtonDown")
	backButton:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.CategorySelection);
		self:GetParent().shouldAlwaysShowCreateGroupButton = false;
	end)

	footerBar.backButton = backButton

	local signupButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", footerBar, 1, footerBar:GetHeight())
	signupButton:SetPoint("LEFT", backButton, "RIGHT")
	signupButton:SetText("Signup")
	signupButton:FitToText()
	signupButton:RegisterForClicks("LeftButtonDown")
	signupButton:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		LFGListApplicationDialog_Show(LFGListApplicationDialog, miog.F.CURRENT_SEARCH_RESULT_ID)

		miog.signupToGroup(LFGListFrame.SearchPanel.resultID)
	end)

	footerBar.signupButton = signupButton

	local groupNumberFontString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, footerBar)
	groupNumberFontString:SetPoint("RIGHT", footerBar, "RIGHT", -3, -1)
	groupNumberFontString:SetJustifyH("CENTER")
	groupNumberFontString:SetText(0)

	footerBar.groupNumberFontString = groupNumberFontString

	local interactionPanel = miog.createBasicFrame("persistent", "BackdropTemplate", searchPanel, miog.mainFrame.standardWidth, 45)
	interactionPanel:SetPoint("TOPLEFT", searchPanel, "TOPLEFT")

	local searchFrame = miog.createBasicFrame("persistent", "BackdropTemplate", searchPanel, miog.mainFrame.standardWidth, footerBar:GetHeight())
	searchFrame:SetFrameStrata("DIALOG")
	searchFrame:SetPoint("TOPLEFT", interactionPanel, "TOPLEFT")

	local searchBar = LFGListFrame.SearchPanel.SearchBox
	searchBar:ClearAllPoints()
	searchBar:SetFrameStrata("DIALOG")
	searchBar:SetPoint("LEFT", searchFrame, "LEFT", 5, 0)

	searchPanel.searchBar = searchBar

	local function ResolveCategoryFilters(categoryID, filters)
		-- Dungeons ONLY display recommended groups.
		if(categoryID == GROUP_FINDER_CATEGORY_ID_DUNGEONS) then
			return bit.band(bit.bnot(Enum.LFGListFilter.NotRecommended), bit.bor(filters, Enum.LFGListFilter.Recommended));
		end

		return filters;
	end

	local searchButton = miog.createBasicFrame("persistent", "UIButtonTemplate, BackdropTemplate", searchFrame, 52, miog.C.APPLICANT_MEMBER_HEIGHT)
	searchButton:SetPoint("LEFT", searchBar, "RIGHT")
	searchButton:RegisterForClicks("LeftButtonDown")
	miog.createFrameBorder(searchButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	searchButton:SetScript("OnClick", function(self)
		--PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		--C_LFGList.SetSearchToActivity(self.activityID);
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
		--C_LFGList.Search(LFGListFrame.SearchPanel.categoryID, ResolveCategoryFilters(LFGListFrame.SearchPanel.categoryID, LFGListFrame.SearchPanel.filters), LFGListFrame.SearchPanel.preferredFilters, C_LFGList.GetLanguageSearchFilter())

		miog.searchPanel.resultPanel:SetVerticalScroll(0)
	end)

	searchPanel.searchButton = searchButton

	local searchButtonString = miog.createBasicFontString("persistent", 12, searchButton)
	searchButtonString:SetWidth(52)
	searchButtonString:SetPoint("CENTER", searchButton, "CENTER")
	searchButtonString:SetJustifyH("CENTER")
	searchButtonString:SetText(_G["SEARCH"])

	local filterShowHideButton = miog.createBasicFrame("persistent", "UIButtonTemplate, BackdropTemplate", searchFrame, 52, miog.C.APPLICANT_MEMBER_HEIGHT)
	filterShowHideButton:SetPoint("LEFT", searchButton, "RIGHT")
	miog.createFrameBorder(filterShowHideButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	filterShowHideButton:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	filterShowHideButton:RegisterForClicks("LeftButtonDown")
	filterShowHideButton:SetScript("OnClick", function()
		filterFrame:SetShown(not filterFrame:IsVisible())

	end)

	local filterShowHideString = miog.createBasicFontString("persistent", 12, filterShowHideButton)
	filterShowHideString:ClearAllPoints()
	filterShowHideString:SetWidth(52)
	filterShowHideString:SetPoint("CENTER", filterShowHideButton, "CENTER")
	filterShowHideString:SetJustifyH("CENTER")
	filterShowHideString:SetText("Filter")


	local buttonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", searchPanel, nil, miog.C.APPLICANT_MEMBER_HEIGHT + 2)
	buttonPanel:SetPoint("TOPLEFT", searchFrame, "BOTTOMLEFT")
	buttonPanel:SetPoint("TOPRIGHT", searchFrame, "BOTTOMRIGHT")
	miog.createFrameBorder(buttonPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	buttonPanel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	searchPanel.buttonPanel = buttonPanel

	buttonPanel.sortByCategoryButtons = {}

	for i = 1, 3, 1 do
		local sortByCategoryButton = Mixin(miog.createBasicFrame("persistent", "UIButtonTemplate", buttonPanel, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT), MultiStateButtonMixin)
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
			currentCategory = "primary"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 181, 0)

		elseif(i == 2) then
			currentCategory = "secondary"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 216, 0)

		elseif(i == 3) then
			currentCategory = "age"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 265, 0)

		end

		sortByCategoryButton:SetScript("OnClick", function(_, button)
			local activeState = sortByCategoryButton:GetActiveState()

			if(button == "LeftButton") then

				if(activeState == 0 and MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods < 2) then
					--TO 1
					MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods = MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods + 1

					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active = true
					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentLayer = MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods

					sortByCategoryButton.FontString:SetText(MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods)

				elseif(activeState == 1) then
					--TO 2


				elseif(activeState == 2) then
					--RESET TO 0
					MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods = MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods - 1

					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active = false
					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentLayer = 0

					sortByCategoryButton.FontString:SetText("")

					for k, v in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do
						if(type(v) == "table" and v.currentLayer == 2) then
							v.currentLayer = 1
							buttonPanel.sortByCategoryButtons[k].FontString:SetText(1)
							MIOG_SavedSettings.sortMethods_SearchPanel.table[k].currentLayer = 1
						end
					end
				end

				if(MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods < 2 or MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods == 2 and MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active == true) then
					sortByCategoryButton:AdvanceState()

					--miog.F.SORT_METHODS[currentCategory].currentState = sortByCategoryButton:GetActiveState()
					--MIOG_SavedSettings.lastActiveSortingMethods.value[currentCategory] = miog.F.SORT_METHODS[currentCategory]

					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentState = sortByCategoryButton:GetActiveState()

					if(GameTooltip:GetOwner() == sortByCategoryButton) then
						GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
					end
				end

				miog.updateSearchResultList(true)
			elseif(button == "RightButton") then
				if(activeState == 1 or activeState == 2) then

					MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods = MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods - 1

					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active = false
					MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentLayer = 0

					sortByCategoryButton.FontString:SetText("")

					for k, v in pairs(MIOG_SavedSettings.sortMethods_SearchPanel.table) do
						if(type(v) == "table" and v.currentLayer == 2) then
							v.currentLayer = 1
							buttonPanel.sortByCategoryButtons[k].FontString:SetText(1)
							MIOG_SavedSettings.sortMethods_SearchPanel.table[k].currentLayer = 1
						end
					end

					sortByCategoryButton:SetState(false)

					if(MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods < 2 or MIOG_SavedSettings.sortMethods_SearchPanel.table.numberOfActiveMethods == 2 and MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].active == true) then

						--miog.F.SORT_METHODS[currentCategory].currentState = sortByCategoryButton:GetActiveState()
						--MIOG_SavedSettings.lastActiveSortingMethods.value[currentCategory] = miog.F.SORT_METHODS[currentCategory]

						MIOG_SavedSettings.sortMethods_SearchPanel.table[currentCategory].currentState = sortByCategoryButton:GetActiveState()

						if(GameTooltip:GetOwner() == sortByCategoryButton) then
							GameTooltip:SetText("Current sort: "..sortByCategoryButton:GetStateName(sortByCategoryButton:GetActiveState()))
						end
					end

					miog.updateSearchResultList(true)
				end
			end
		end)

		buttonPanel.sortByCategoryButtons[currentCategory] = sortByCategoryButton

	end

	local resultPanel = miog.createBasicFrame("persistent", "ScrollFrameTemplate", searchPanel)
	resultPanel:SetPoint("TOPLEFT", interactionPanel, "BOTTOMLEFT", 1, -1)
	resultPanel:SetPoint("BOTTOMRIGHT", footerBar, "TOPRIGHT", 1, 1)
	searchPanel.resultPanel = resultPanel
	resultPanel.ScrollBar:SetPoint("TOPLEFT", resultPanel, "TOPRIGHT", 0, -10)
	resultPanel.ScrollBar:SetPoint("BOTTOMLEFT", resultPanel, "BOTTOMRIGHT", 0, 10)

	local resultPanelContainer = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", resultPanel)
	resultPanelContainer.fixedWidth = resultPanel:GetWidth()
	resultPanelContainer.minimumHeight = 1
	resultPanelContainer.spacing = 5
	resultPanelContainer.align = "center"
	resultPanelContainer:SetPoint("TOP", resultPanel, "TOP")
	resultPanel.container = resultPanelContainer

	resultPanel:SetScrollChild(resultPanelContainer)
end

miog.createFrames = function()
	createMainFrame()
	createApplicationViewer()
	createSearchPanel()

	miog.scriptReceiver:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")

	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_FAILED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

	miog.scriptReceiver:RegisterEvent("PARTY_LEADER_CHANGED")
	miog.scriptReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
	miog.scriptReceiver:RegisterEvent("GROUP_JOINED")
	miog.scriptReceiver:RegisterEvent("GROUP_LEFT")
	miog.scriptReceiver:RegisterEvent("INSPECT_READY")
	miog.scriptReceiver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	miog.scriptReceiver:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")

	C_MythicPlus.GetCurrentAffixes()

	EncounterJournal_LoadUI()
	C_EncounterJournal.OnOpen = miog.dummyFunction
	EJ_SelectInstance(1207)

end

miog.scriptReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
miog.scriptReceiver:RegisterEvent("PLAYER_LOGIN")
miog.scriptReceiver:SetScript("OnEvent", miog.OnEvent)