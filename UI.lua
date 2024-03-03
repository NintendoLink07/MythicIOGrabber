local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.scriptReceiver = CreateFrame("Frame", "MythicIOGrabber_ScriptReceiver", miog.pveFrame2, "BackdropTemplate") ---@class Frame
miog.mainFrame = CreateFrame("Frame", "MythicIOGrabber_MainFrame", miog.pveFrame2, "BackdropTemplate") ---@class Frame
--miog.mainFrame:Hide()
--miog.applicationViewer = CreateFrame("Frame", "MythicIOGrabber_ApplicationViewer", miog.mainFrame, "BackdropTemplate") ---@class Frame
miog.searchPanel = CreateFrame("Frame", "MythicIOGrabber_SearchPanel", miog.pveFrame2, "BackdropTemplate") ---@class Frame
miog.searchPanel:SetScale(0.64)
miog.ipDialog = CreateFrame("Frame", "MythicIOGrabber_UpgradedInvitePendingDialog", nil, "ResizeLayoutFrame, BackdropTemplate")

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
    --pveFrameTab1_Point = insertPointsIntoTable(PVEFrameTab1)
	--mainFrame:SetSize(mainFrame.standardWidth, mainFrame.standardHeight)
	--applicationViewer:SetScale(1.5)
	mainFrame:SetScale(0.64)
	mainFrame:SetResizable(true)
	mainFrame:SetPoint("TOPRIGHT", miog.pveFrame2.SearchBox, "BOTTOMRIGHT")
	mainFrame:SetPoint("BOTTOMLEFT", miog.pveFrame2.QueuePanel, "BOTTOMRIGHT")
	mainFrame:SetFrameStrata("DIALOG")
	--mainFrame:AdjustPointsOffset(-4, -PVEFrame.TitleContainer:GetHeight() - 1)

	mainFrame.standardWidth = mainFrame:GetWidth()
	mainFrame.standardHeight = mainFrame:GetHeight()
	mainFrame.extendedHeight = MIOG_SavedSettings and MIOG_SavedSettings.frameManuallyResized and MIOG_SavedSettings.frameManuallyResized.value > 0 and MIOG_SavedSettings.frameManuallyResized.value or mainFrame.standardHeight * 1.5
	mainFrame:SetResizeBounds(mainFrame.standardWidth, mainFrame.standardHeight, mainFrame.standardWidth, GetScreenHeight() * 0.67)
	
	mainFrame:SetScript("OnEnter", function()
		
	end)

	miog.createFrameBorder(mainFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	mainFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	mainFrame:HookScript("OnShow", function()
		if(MIOG_SavedSettings.frameExtended.value) then
			--positionTab1ToActiveFrame(mainFrame)

		end
	end)

	mainFrame:HookScript("OnHide", function()
		--positionTab1ToPVEFrame(mainFrame)

	end)

	_G[mainFrame:GetName()] = mainFrame

	local footerBar = miog.createBasicFrame("persistent", "BackdropTemplate", mainFrame)
	footerBar:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, 0)
	footerBar:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
	footerBar:SetHeight(25)
	footerBar:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	miog.createFrameBorder(footerBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	mainFrame.footerBar = footerBar

	local backButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", mainFrame, 1, 20)
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

	local resizeApplicationViewerButton = miog.createBasicFrame("persistent", "UIButtonTemplate", mainFrame)
	resizeApplicationViewerButton:EnableMouse(true)
	resizeApplicationViewerButton:SetPoint("BOTTOMRIGHT", footerBar, "TOPRIGHT", 0, 0)
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

local function setUpPlaystyleDropDown(activityInfo)
	local playstyleDropDown = miog.entryCreation.PlaystyleDropDown
	playstyleDropDown:ResetDropDown()

	local info = {}
		
	info.entryType = "option"

	if (activityInfo.isRatedPvpActivity) then
		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Standard, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Standard;
		info.checked = false;
		info.isRadio = true;
		--info.func = function() LFGListEntryCreation_OnPlayStyleSelected(self, dropdown, Enum.LFGEntryPlaystyle.Standard); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

		info.text =  C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Casual, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Casual;
		info.checked = false;
		info.isRadio = true;
		--info.func = function() LFGListEntryCreation_OnPlayStyleSelected(self, dropdown, Enum.LFGEntryPlaystyle.Casual); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Hardcore, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Hardcore;
		info.checked = false;
		info.isRadio = true;
		--info.func = function() LFGListEntryCreation_OnPlayStyleSelected(self, dropdown, Enum.LFGEntryPlaystyle.Hardcore); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

	else
		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Standard, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Standard;
		info.checked = false;
		info.isRadio = true;
		--info.func = function() LFGListEntryCreation_OnPlayStyleSelected(self, dropdown, Enum.LFGEntryPlaystyle.Standard); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Casual, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Casual;
		info.checked = false;
		info.isRadio = true;
		--info.func = function() LFGListEntryCreation_OnPlayStyleSelected(self, dropdown, Enum.LFGEntryPlaystyle.Casual); end;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)

		info.text = C_LFGList.GetPlaystyleString(Enum.LFGEntryPlaystyle.Hardcore, activityInfo);
		info.value = Enum.LFGEntryPlaystyle.Hardcore;
		--info.func = function() LFGListEntryCreation_OnPlayStyleSelected(self, dropdown, Enum.LFGEntryPlaystyle.Hardcore); end;
		info.checked = false;
		info.isRadio = true;
		--UIDropDownMenu_AddButton(info);
		playstyleDropDown:CreateEntryFrame(info)
	end
end

local function setUpDifficultyDropDown(categoryID, filters)
	local frame = miog.entryCreation
	frame.DifficultyDropDown:ResetDropDown()

	--Start out displaying everything
	local unsortedActivities = C_LFGList.GetAvailableActivities(categoryID, frame.selectedGroup, filters);
	local activities = {}

	local info = {}

	if(categoryID == 2 or categoryID == 3) then
		for k, v in ipairs(unsortedActivities) do
			activities[k] = unsortedActivities[#unsortedActivities - k + 1]
		end

	else
		activities = unsortedActivities
		
	end
	
	for k, v in ipairs(activities) do
	--for i = #activities, 1, -1 do
		local activityID = v;
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
		local shortName = activityInfo and activityInfo.shortName;

		--info.arg1 = "activity";
		info.entryType = "option"
		--info.index = #activities - i + 1
		info.index = k
		info.text = shortName
		--print(shortName)
		info.value = activityID
		info.func = function()
			frame.DifficultyDropDown.CheckedValue.value = activityID
		end

		frame.DifficultyDropDown:CreateEntryFrame(info)
	end
end

local function setUpEntryCreation(filters, categoryID, groupID, activityID)
	local frame = miog.entryCreation

	---@diagnostic disable-next-line: undefined-field
	local activityDropDown = frame.ActivityDropDown

	---@diagnostic disable-next-line: undefined-field
	local playstyleDropDown = frame.PlaystyleDropDown

	---@diagnostic disable-next-line: undefined-field
	local difficultyDropDown = frame.DifficultyDropDown
	
	---@diagnostic disable-next-line: undefined-field
	local crossFaction = frame.CrossFaction


	--local filters, categoryID, groupID, activityID = LFGListUtil_AugmentWithBest(bit.bor(self.baseFilters or 0, filters or 0), categoryID, groupID, activityID);
	filters, categoryID, groupID, activityID = LFGListUtil_AugmentWithBest(bit.bor(LFGListFrame.baseFilters or 0, filters or 0), categoryID, groupID, activityID);

	miog.entryCreation.selectedCategory = categoryID;
	miog.entryCreation.selectedGroup = groupID;
	miog.entryCreation.selectedActivity = activityID;
	LFGListFrame.EntryCreation.selectedActivity = activityID;
	miog.entryCreation.selectedFilters = filters;

	--Update the category dropdown
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);

	--Update the activity dropdown
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
	if(not activityInfo) then
		return;
	end

	--Update the group dropdown. If the group dropdown is showing an activity, hide the activity dropdown
	local groupName = C_LFGList.GetActivityGroupInfo(groupID);
	activityDropDown:SetShown(groupName and not categoryInfo.autoChooseActivity);
	difficultyDropDown:SetShown(not categoryInfo.autoChooseActivity);

	local shouldShowPlayStyleDropdown = (categoryInfo.showPlaystyleDropdown) and (activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity or activityInfo.isCurrentRaidActivity or activityInfo.isMythicActivity);
	local shouldShowCrossFactionToggle = (categoryInfo.allowCrossFaction);
	local shouldDisableCrossFactionToggle = (categoryInfo.allowCrossFaction) and not (activityInfo.allowCrossFaction);

	--print((categoryInfo.showPlaystyleDropdown), (activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity or activityInfo.isCurrentRaidActivity or activityInfo.isMythicActivity))

	if(shouldShowPlayStyleDropdown) then
		--LFGListEntryCreation_OnPlayStyleSelected(self, self.PlayStyleDropdown, self.selectedPlaystyle or Enum.LFGEntryPlaystyle.Standard);
		setUpPlaystyleDropDown(activityInfo)
		playstyleDropDown:Enable()

	elseif(not shouldShowPlayStyleDropdown) then
		miog.entryCreation.selectedPlaystyle = nil
		playstyleDropDown:Disable()
	
	end

	playstyleDropDown:SetShown(shouldShowPlayStyleDropdown);
	--self.PlayStyleLabel:SetShown(shouldShowPlayStyleDropdown);

	local _, localizedFaction = UnitFactionGroup("player");
	--self.CrossFactionGroup.Label:SetText(LFG_LIST_CROSS_FACTION:format(localizedFaction));
	--self.CrossFactionGroup.tooltip = LFG_LIST_CROSS_FACTION_TOOLTIP:format(localizedFaction);
	--self.CrossFactionGroup.disableTooltip = LFG_LIST_CROSS_FACTION_DISABLE_TOOLTIP:format(localizedFaction);
	crossFaction:SetShown(shouldShowCrossFactionToggle)
	crossFaction:SetEnabled(not shouldDisableCrossFactionToggle)
	crossFaction:SetChecked(shouldDisableCrossFactionToggle)
	frame.CrossFactionString:SetShown(shouldShowCrossFactionToggle)

	frame.Rating:SetShown(activityInfo.isMythicPlusActivity or activityInfo.isRatedPvpActivity);
	frame.RatingString:SetShown(frame.Rating:IsShown());
	--self.PVPRating:SetShown(activityInfo.isRatedPvpActivity);

	--Update the recommended item level box
	if ( activityInfo.ilvlSuggestion ~= 0 ) then
		frame.ItemLevel.instructions = format(LFG_LIST_RECOMMENDED_ILVL, activityInfo.ilvlSuggestion);
	else
		frame.ItemLevel.instructions = LFG_LIST_ITEM_LEVEL_INSTR_SHORT;
	end

	--self.NameLabel:ClearAllPoints();
	if (not frame.ActivityDropDown:IsShown() and not frame.DifficultyDropDown:IsShown()) then
	--	self.NameLabel:SetPoint("TOPLEFT", 20, -82);
	else
	--	self.NameLabel:SetPoint("TOPLEFT", 20, -120);
	end

	frame.ItemLevel:ClearAllPoints();
	--self.PvpItemLevel:ClearAllPoints();

	frame.ItemLevel:SetShown(not activityInfo.isPvpActivity);
	--self.PvpItemLevel:SetShown(activityInfo.isPvpActivity);

	if(frame.Rating:IsShown()) then
		frame.ItemLevel:SetPoint("LEFT", frame.Rating, "RIGHT", 10, 0)

	else
		frame.ItemLevel:SetPoint(frame.Rating:GetPoint())
	
	end

	--[[if (self.MythicPlusRating:IsShown()) then
		self.ItemLevel:SetPoint("TOPLEFT", self.MythicPlusRating, "BOTTOMLEFT", 0, -3);
		self.PvpItemLevel:SetPoint("TOPLEFT", self.MythicPlusRating, "BOTTOMLEFT", 0, -3);
	elseif (self.PVPRating:IsShown()) then
		self.ItemLevel:SetPoint("TOPLEFT", self.PVPRating, "BOTTOMLEFT", 0, -3);
		self.PvpItemLevel:SetPoint("TOPLEFT", self.PVPRating, "BOTTOMLEFT", 0, -3);
	elseif(self.PlayStyleDropdown:IsShown()) then
		self.ItemLevel:SetPoint("TOPLEFT", self.PlayStyleLabel, "BOTTOMLEFT", -1, -15);
		self.PvpItemLevel:SetPoint("TOPLEFT", self.PlayStyleLabel, "BOTTOMLEFT", -1, -15);
	else
		self.ItemLevel:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", -6, -19);
		self.PvpItemLevel:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", -6, -19);
	end]]

	setUpDifficultyDropDown(categoryID, filters)

	activityDropDown.CheckedValue.Background:SetTexture(miog.retrieveBackgroundImageFromGroupActivityID(activityInfo.groupFinderActivityGroupID), "background")
	

	if(miog.SETUP_FIRST_ENTRY_CREATION_VIEW) then
		print("FIRST")
		local firstActivityFrame = miog.entryCreation.ActivityDropDown:GetFrameAtLayoutIndex(1)

		if(firstActivityFrame) then
			local firstActivityName = firstActivityFrame.Name:GetText()
			miog.entryCreation.ActivityDropDown.CheckedValue.Name:SetText(firstActivityName)
			miog.entryCreation.ActivityDropDown.CheckedValue.value = firstActivityFrame.value
			firstActivityFrame.Name:SetText(firstActivityName)
			firstActivityFrame.Radio:SetChecked(true)
		end

		local firstDifficultyFrame = miog.entryCreation.DifficultyDropDown:GetFrameAtLayoutIndex(1)

		if(firstDifficultyFrame) then
			local firstDifficultyName = firstDifficultyFrame.Name:GetText()
			miog.entryCreation.DifficultyDropDown.CheckedValue.Name:SetText(firstDifficultyName)
			miog.entryCreation.DifficultyDropDown.CheckedValue.value = firstDifficultyFrame.value
			firstDifficultyFrame.Name:SetText(firstDifficultyName)
			firstDifficultyFrame.Radio:SetChecked(true)

		end

		local firstPlaystyleFrame = miog.entryCreation.PlaystyleDropDown:GetFrameAtIndex(1)

		if(firstPlaystyleFrame) then
			local firstPlaystyleName = firstPlaystyleFrame.Name:GetText()
			miog.entryCreation.PlaystyleDropDown.CheckedValue.Name:SetText(firstPlaystyleName)
			miog.entryCreation.PlaystyleDropDown.CheckedValue.value = firstPlaystyleFrame.value
			firstPlaystyleFrame.Name:SetText(firstPlaystyleName)
			firstPlaystyleFrame.Radio:SetChecked(true)
		end
		
		miog.SETUP_FIRST_ENTRY_CREATION_VIEW = false
	end
end

miog.setUpEntryCreation = setUpEntryCreation

local function gatherGroupsAndActivitiesForCategory(categoryID)
		local activityDropDown = miog.entryCreation.ActivityDropDown
	activityDropDown:ResetDropDown()

	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);

	local borFilters = bit.bor(0, 8)

	local firstFilters, firstCategoryID, firstGroupID, firstActivityID

	if(categoryID < 4 or categoryID == 6) then
		if(categoryID == 2) then
			--implement expansion headers for dungeon view

		end
		local groups = C_LFGList.GetAvailableActivityGroups(categoryID, bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters))

		firstCategoryID = categoryID

		local lastHighestIndex = 0

		table.sort(groups, function(k1, k2)
			return k1 < k2
		end)

		for k, v in ipairs(groups) do
			--local groupName, order, x1, x2, x3 = C_LFGList.GetActivityGroupInfo(v)

			local activities = C_LFGList.GetAvailableActivities(categoryID, v)
			local activityID = activities[1]

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

			local currentMPlus = nil
			local info = {}

			if(categoryID == 2) then
				--info.parentIndex = 
				for activityIndex, activityID in ipairs(activities) do
					local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
				--	print(activityInfo.fullName, activityInfo.isMythicPlusActivity, activityID, activityInfo.groupFinderActivityGroupID)

					if(activityInfo.isMythicPlusActivity and miog.checkIfDungeonIsInCurrentSeason(activityID)) then
						currentMPlus = activityID

					end
				end
			else
				info.parentIndex = nil
			
			end

			info.entryType = "option"
			info.index = activityInfo.groupFinderActivityGroupID - (categoryID == 2 and currentMPlus and 1000 or 0)
			--print(groupName, activityInfo.isMythicPlusActivity, activityInfo.groupFinderActivityGroupID - (categoryID == 2 and hasCurrentMPlus and -1000 or 0))
			--info.index = activityIndex
			--info.text = activityInfo.fullName
			info.text = C_LFGList.GetActivityGroupInfo(v)
			--print(activityInfo.shortName)
			info.func = function()
				miog.SETUP_FIRST_ENTRY_CREATION_VIEW = true
				setUpEntryCreation(firstFilters, categoryID, v, activityID)
			end

			info.value = activityID
			
			local mapID = miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].mapID

			if(mapID) then
				if(miog.MAP_INFO[mapID]) then
					info.icon = miog.MAP_INFO[mapID].icon

				else
					local journalID = C_EncounterJournal.GetInstanceForGameMap(mapID)
					local _, _, _, buttonImage1, _, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, _ = EJ_GetInstanceInfo(journalID)
					
					info.icon = buttonImage2
				end
			end

			local entryFrame = activityDropDown:CreateEntryFrame(info)

			if(categoryID == 2) then
				lastHighestIndex = info.index < lastHighestIndex and info.index or lastHighestIndex

				if(lastHighestIndex == info.index) then
					firstGroupID = groups[1]
					firstActivityID = currentMPlus
					firstFilters = bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters)
					--print(lastHighestIndex, info.text, firstActivityID, firstGroupID)

				end
				
			else
				if(k == 1) then
					firstGroupID = groups[1]
					firstActivityID = activityID
					firstFilters = bit.bor(LFGListFrame.EntryCreation.baseFilters, LFGListFrame.CategorySelection.selectedFilters)
				end

			end
		end
	else
		local pvpActivities = C_LFGList.GetAvailableActivities(categoryID, 0, borFilters);
		firstFilters = 0
		firstCategoryID = categoryID
		firstGroupID = 0
		firstActivityID = pvpActivities[1]
	
		for k, v in ipairs(pvpActivities) do
			local activityID = v

			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

			local info = {}
			info.entryType = "option"
			info.index = activityInfo.groupFinderActivityGroupID
			--print(groupName, activityInfo.isMythicPlusActivity, activityInfo.groupFinderActivityGroupID - (categoryID == 2 and hasCurrentMPlus and -1000 or 0))
			--info.index = activityIndex
			--info.text = activityInfo.fullName
			info.text = activityInfo.fullName
			--print(activityInfo.shortName)
			--info.func = function() selectActivity(borFilters, categoryID, v, activityID) end

			info.value = activityID
			
			local mapID = miog.retrieveMapIDFromGFID(activityInfo.groupFinderActivityGroupID)

			if(mapID) then
				info.icon = miog.MAP_INFO[mapID].icon
			end

			local entryFrame = activityDropDown:CreateEntryFrame(info)

		end
	end

	setUpEntryCreation(firstFilters, firstCategoryID, firstGroupID, firstActivityID)
end

local function initializeActivityDropdown()
	print("INIT")

	local categoryID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or LFGListFrame.CategorySelection.selectedCategory or 0
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)

	local frame = miog.entryCreation
	
	if(frame.selectedCategory ~= LFGListFrame.CategorySelection.selectedCategory or frame.selectedCategory == LFGListFrame.CategorySelection.selectedCategory and categoryInfo.separateRecommended) then
		
		local activityDropDown = frame.ActivityDropDown
		activityDropDown:ResetDropDown()

		gatherGroupsAndActivitiesForCategory(categoryID)

		miog.entryCreation.ActivityDropDown.List:MarkDirty()
		miog.entryCreation.ActivityDropDown:MarkDirty()
	end
end

miog.initializeActivityDropdown = initializeActivityDropdown

local function LFGListEntryCreation_ListGroup()
	local frame = miog.entryCreation

	local itemLevel = tonumber(frame.ItemLevel:GetText()) or 0;
	local rating = tonumber(frame.Rating:GetText()) or 0;
	local pvpRating = rating
	local mythicPlusRating = rating
	local autoAccept = false;
	local privateGroup = frame.PrivateGroup:GetChecked();
	local isCrossFaction =  frame.CrossFaction:IsShown() and not frame.CrossFaction:GetChecked();
	local selectedPlaystyle = frame.PlaystyleDropDown:IsShown() and frame.PlaystyleDropDown.CheckedValue.value or nil;
	local activityID = frame.DifficultyDropDown.CheckedValue.value or frame.ActivityDropDown.CheckedValue.value or 0

	local self = LFGListFrame.EntryCreation

	LFGListEntryCreation_ListGroupInternal(self, activityID, itemLevel, autoAccept, privateGroup, 0, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
end

function LFGListEntryCreation_UpdateValidState(self)
	local errorText;
	local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity)
	local maxNumPlayers = activityInfo and  activityInfo.maxNumPlayers or 0;
	local mythicPlusDisableActivity = not C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity) and (activityInfo.isMythicPlusActivity and not C_LFGList.GetKeystoneForActivity(self.selectedActivity));
	if ( maxNumPlayers > 0 and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) >= maxNumPlayers ) then
		errorText = string.format(LFG_LIST_TOO_MANY_FOR_ACTIVITY, maxNumPlayers);
	elseif (mythicPlusDisableActivity) then
		errorText = LFG_AUTHENTICATOR_BUTTON_MYTHIC_PLUS_TOOLTIP;
	elseif ( LFGListEntryCreation_GetSanitizedName(self) == "" ) then
		errorText = LFG_LIST_MUST_HAVE_NAME;
	end

	LFGListEntryCreation_UpdateAuthenticatedState(self);

	LFGListFrame.EntryCreation.ListGroupButton.DisableStateClickButton:SetShown(mythicPlusDisableActivity);
	LFGListFrame.EntryCreation.ListGroupButton:SetEnabled(not errorText and not mythicPlusDisableActivity);
	LFGListFrame.EntryCreation.ListGroupButton.errorText = errorText;
end

function LFGListEntryCreation_UpdateAuthenticatedState(self)
	local isAuthenticated = C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity);
	LFGListFrame.EntryCreation.Description.EditBox:SetEnabled(isAuthenticated);
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
	local isQuestListing = activeEntryInfo and activeEntryInfo.questID or nil;
	LFGListFrame.EntryCreation.Name:SetEnabled(isAuthenticated and not isQuestListing);
	LFGListFrame.EntryCreation.VoiceChat.EditBox:SetEnabled(isAuthenticated)
end

local function createEntryCreation()
	miog.entryCreation = CreateFrame("Frame", "MythicIOGrabber_EntryCreation", miog.mainFrame, "MIOG_EntryCreation") ---@class Frame

	local frame = miog.entryCreation

	frame.selectedActivity = 0

	--local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", frame, 200, 25)
	--optionDropdown:SetPoint("TOPLEFT", frame, "TOPLEFT")
	--UIDropDownMenu_SetWidth(optionDropdown, 160)
	--frame.ActivityDropdown = optionDropdown

	---@diagnostic disable-next-line: undefined-field
	local activityDropDown = frame.ActivityDropDown
	activityDropDown:OnLoad()

	---@diagnostic disable-next-line: undefined-field
	local difficultyDropDown = frame.DifficultyDropDown
	difficultyDropDown:OnLoad()

	---@diagnostic disable-next-line: undefined-field
	local playstyleDropDown = frame.PlaystyleDropDown
	playstyleDropDown:OnLoad()

	local nameField = LFGListFrame.EntryCreation.Name
	nameField:ClearAllPoints()
	nameField:SetAutoFocus(false)
	nameField:SetParent(frame)
	nameField:SetSize(frame:GetWidth() - 15, 25)
	--nameField:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -80)
	nameField:SetPoint(frame.Name:GetPoint())
	frame.Name = nameField
	frame.NameString:SetPoint("BOTTOMLEFT", nameField, "TOPLEFT", -5, 0)

	local descriptionField = LFGListFrame.EntryCreation.Description
	descriptionField:ClearAllPoints()
	descriptionField:SetParent(frame)
	descriptionField:SetSize(frame:GetWidth() - 20, 50)
	descriptionField:SetPoint("TOPLEFT", frame.Name, "BOTTOMLEFT", 0, -20)
	frame.Description = descriptionField
	
	frame.Rating:SetPoint("TOPLEFT", frame.Description, "BOTTOMLEFT", 0, -20)
	
	local voiceChat = LFGListFrame.EntryCreation.VoiceChat
	--voiceChat.CheckButton:SetNormalTexture("checkbox-minimal")
	--voiceChat.CheckButton:SetPushedTexture("checkbox-minimal")
	--voiceChat.CheckButton:SetCheckedTexture("checkmark-minimal")
	--voiceChat.CheckButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	voiceChat.CheckButton:Hide()
	voiceChat.Label:Hide()
	voiceChat.EditBox:ClearAllPoints()
	voiceChat.EditBox:SetPoint("LEFT", frame.VoiceChat, "LEFT")
	--voiceChat:SetPoint("LEFT", frame.VoiceChat, "LEFT", -6, 0)
	voiceChat:ClearAllPoints()
	voiceChat:SetParent(frame)
	
	--miogDropdown.List:MarkDirty()
	--miogDropdown:MarkDirty()

	local startGroup = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.entryCreation, 1, 20)
	startGroup:SetPoint("RIGHT", miog.mainFrame.footerBar, "RIGHT")
	startGroup:SetText("Start Group")
	startGroup:FitToText()
	startGroup:RegisterForClicks("LeftButtonDown")
	startGroup:SetScript("OnClick", function()
		LFGListEntryCreation_ListGroup()
	end)

	frame:HookScript("OnShow", function()
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
		if(activeEntryInfo) then
			LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, true)
			startGroup:SetText("Update")

		else
			LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, false)
			startGroup:SetText("Start Group")

		end
	end)
end


local lastFilterOption = nil



local function addOptionToFilterFrame(parent, parentName, text, name)
	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", parent.FilterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	optionButton:SetPoint("TOPLEFT", lastFilterOption or parent.FilterFrame, lastFilterOption and "BOTTOMLEFT" or "TOPLEFT", 0, lastFilterOption and -5 or -20)
	optionButton:RegisterForClicks("LeftButtonDown")
	optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings[parentName .. "_FilterOptions"].table[name] or false)
	optionButton:HookScript("OnClick", function()
		MIOG_SavedSettings[parentName .. "_FilterOptions"].table[name] = optionButton:GetChecked()
		miog.checkListForEligibleMembers()
	end)

	parent.FilterFrame[name] = optionButton

	local optionString = miog.createBasicFontString("persistent", 12, parent.FilterFrame)
	optionString:SetPoint("LEFT", optionButton, "RIGHT")
	optionString:SetText(text)

	lastFilterOption = optionButton
end

local function addNumericSpinnerToFilterFrame(text, name)
	local numericSpinner = Mixin(miog.createBasicFrame("persistent", "InputBoxTemplate", miog.searchPanel.FilterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 5, miog.C.INTERFACE_OPTION_BUTTON_SIZE), NumericInputSpinnerMixin)
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
	decrementButton:SetPoint("TOPLEFT", lastFilterOption or miog.searchPanel.FilterFrame, "BOTTOMLEFT", 0, -5)
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
		miog.checkListForEligibleMembers()

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
		miog.checkListForEligibleMembers()

	end)

	miog.searchPanel.FilterFrame[name] = numericSpinner

	local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.FilterFrame)
	optionString:SetPoint("LEFT", incrementButton, "RIGHT")
	optionString:SetText(text)

	lastFilterOption = decrementButton

end

local function addDualNumericSpinnerToFilterFrame(name, range)
	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", miog.searchPanel.FilterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	optionButton:SetPoint("TOPLEFT", lastFilterOption, "BOTTOMLEFT", 0, -5)
	optionButton:RegisterForClicks("LeftButtonDown")
	optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name] or false)
	optionButton:HookScript("OnClick", function()
		MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name] = optionButton:GetChecked()
		miog.checkListForEligibleMembers()
	end)

	miog.searchPanel.FilterFrame["filterFor" .. name] = optionButton

	local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.FilterFrame)
	optionString:SetPoint("LEFT", optionButton, "RIGHT")
	optionString:SetText(name)

	local minName = "min" .. name
	local maxName = "max" .. name
	local filterFrameWidth = miog.searchPanel.FilterFrame:GetWidth() * 0.30

	for i = 1, 2, 1 do
		local numericSpinner = Mixin(miog.createBasicFrame("persistent", "InputBoxTemplate", miog.searchPanel.FilterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 5, miog.C.INTERFACE_OPTION_BUTTON_SIZE), NumericInputSpinnerMixin)
		numericSpinner:SetAutoFocus(false)
		numericSpinner.autoFocus = false
		numericSpinner:SetNumeric(true)
		numericSpinner:SetMaxLetters(1)
		numericSpinner:SetMinMaxValues(range ~= nil and range or 0, 9)
		numericSpinner:SetValue(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] or 0)

		local decrementButton = miog.createBasicFrame("persistent", "UIButtonTemplate", numericSpinner, miog.C.INTERFACE_OPTION_BUTTON_SIZE - 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		decrementButton:SetNormalTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Up")
		decrementButton:SetPushedTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Down")
		decrementButton:SetDisabledTexture("Interface/Buttons/UI-SpellbookIcon-PrevPage-Disabled")
		decrementButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
		decrementButton:SetPoint("LEFT", i == 1 and optionString or miog.searchPanel.FilterFrame[minName].incrementButton, i == 1 and "LEFT" or "RIGHT", i == 1 and filterFrameWidth or 0, 0)
		decrementButton:SetScript("OnMouseDown", function()
			--PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			numericSpinner:Decrement()

			local spinnerValue = numericSpinner:GetValue()

			MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] = spinnerValue

			if(i == 2 and miog.searchPanel.FilterFrame[minName]:GetValue() > spinnerValue) then
				miog.searchPanel.FilterFrame[minName]:SetValue(spinnerValue)
				MIOG_SavedSettings.searchPanel_FilterOptions.table[minName] = spinnerValue

			end

			numericSpinner:ClearFocus()

			if(optionButton:GetChecked()) then
				miog.checkListForEligibleMembers()

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

			if(i == 1 and miog.searchPanel.FilterFrame[maxName]:GetValue() < spinnerValue) then
				miog.searchPanel.FilterFrame[maxName]:SetValue(spinnerValue)
				MIOG_SavedSettings.searchPanel_FilterOptions.table[maxName] = spinnerValue

			end

			numericSpinner:ClearFocus()

			if(optionButton:GetChecked()) then
				miog.checkListForEligibleMembers()
				
			end
		end)
		numericSpinner.incrementButton = incrementButton

		miog.searchPanel.FilterFrame[i == 1 and minName or maxName] = numericSpinner

		lastFilterOption = incrementButton
	end

	lastFilterOption = optionButton

end

miog.addDualNumericSpinnerToFilterFrame = addDualNumericSpinnerToFilterFrame

local function addDualNumericFieldsToFilterFrame(name)
	local optionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", miog.searchPanel.FilterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	optionButton:SetNormalAtlas("checkbox-minimal")
	optionButton:SetPushedAtlas("checkbox-minimal")
	optionButton:SetCheckedTexture("checkmark-minimal")
	optionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	optionButton:SetPoint("TOPLEFT", lastFilterOption, "BOTTOMLEFT", 0, -5)
	optionButton:RegisterForClicks("LeftButtonDown")
	optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name] or false)
	optionButton:HookScript("OnClick", function()
		MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name] = optionButton:GetChecked()
		miog.checkListForEligibleMembers()
	end)

	miog.searchPanel.FilterFrame["filterFor" .. name] = optionButton

	local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.FilterFrame)
	optionString:SetPoint("LEFT", optionButton, "RIGHT")
	optionString:SetText(name)

	local minName = "min" .. name
	local maxName = "max" .. name

	for i = 1, 2, 1 do
		local numericField = miog.createBasicFrame("persistent", "InputBoxTemplate", miog.searchPanel.FilterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
		numericField:SetPoint("LEFT", i == 1 and optionString or lastFilterOption, "RIGHT", 5, 0)
		numericField:SetAutoFocus(false)
		numericField.autoFocus = false
		numericField:SetNumeric(true)
		numericField:SetMaxLetters(4)
		numericField:SetText(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] or 0)
		numericField:HookScript("OnTextChanged", function(self, ...)
			local text = tonumber(self:GetText())
			MIOG_SavedSettings.searchPanel_FilterOptions.table[i == 1 and minName or maxName] = text ~= nil and text or 0

			if(MIOG_SavedSettings.searchPanel_FilterOptions.table["filterFor" .. name]) then
				miog.checkListForEligibleMembers()
			end

		end)
		

		miog.searchPanel.FilterFrame[i == 1 and minName or maxName] = numericField

		lastFilterOption = numericField
	end

	lastFilterOption = optionButton

end

local function addDungeonCheckboxes()
	local sortedSeasonDungeons = {}

	for activityID, activityEntry in pairs(miog.ACTIVITY_ID_INFO) do
		if(activityEntry.mPlusSeasons) then
			for _, seasonID in ipairs(activityEntry.mPlusSeasons) do
				if(seasonID == miog.F.CURRENT_SEASON) then
					sortedSeasonDungeons[#sortedSeasonDungeons + 1] = {activityID = activityID, name = activityEntry.shortName}

				end
			end
		end
	end

	table.sort(sortedSeasonDungeons, function(k1, k2)
		return k1.name < k2.name
	end)

	local dungeonPanel = miog.createBasicFrame("persistent", "BackdropTemplate", miog.searchPanel.FilterFrame, miog.searchPanel.FilterFrame:GetWidth(), miog.C.INTERFACE_OPTION_BUTTON_SIZE * 3)
	dungeonPanel:SetPoint("TOPLEFT", lastFilterOption or miog.searchPanel.FilterFrame, lastFilterOption and "BOTTOMLEFT" or "TOPLEFT", 0, -5)
	dungeonPanel.buttons = {}

	miog.searchPanel.FilterFrame.dungeonPanel = dungeonPanel

	local dungeonPanelFirstRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, miog.searchPanel.FilterFrame:GetWidth(), dungeonPanel:GetHeight() / 2)
	dungeonPanelFirstRow:SetPoint("TOPLEFT", dungeonPanel, "TOPLEFT")

	local dungeonPanelSecondRow = miog.createBasicFrame("persistent", "BackdropTemplate", dungeonPanel, miog.searchPanel.FilterFrame:GetWidth(), dungeonPanel:GetHeight() / 2)
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
		optionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeons[activityEntry.activityID])
		optionButton:HookScript("OnClick", function()
			MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeons[activityEntry.activityID] = optionButton:GetChecked()

			if(MIOG_SavedSettings.searchPanel_FilterOptions.table.dungeonOptions) then
				miog.checkListForEligibleMembers()
			end

		end)
	
		miog.searchPanel.FilterFrame[activityEntry.activityID] = optionButton
	
		local optionString = miog.createBasicFontString("persistent", 12, miog.searchPanel.FilterFrame)
		optionString:SetPoint("LEFT", optionButton, "RIGHT")
		optionString:SetText(activityEntry.name)

		dungeonPanel.buttons[activityEntry.activityID] = optionButton

		optionButton.fontString = optionString

		counter = counter + 1
	end
		
	lastFilterOption = dungeonPanel
end

local function createClassSpecFilters(parent, parentName)
	local filterFrame = miog.createBasicFrame("persistent", "BackdropTemplate", parent, 220, 620)
	miog.createFrameBorder(filterFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	filterFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	filterFrame:Hide()

	parent.FilterFrame = filterFrame

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
		for classIndex, v in pairs(parent.FilterFrame.classFilterPanel.ClassPanels) do
			v.Class.Button:SetChecked(false)

			for specIndex, y in pairs(v.SpecFrames) do
				y.Button:SetChecked(false)
				MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.spec[specIndex] = false

			end

			MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.class[classIndex] = false

		end

		--for _, v in pairs(roleFilterPanel.RoleButtons) do
		--	v:SetChecked(false)

		--end

		if(not miog.checkForActiveFilters(filterFrame)) then
			filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

		else
			filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

		end

		miog.checkListForEligibleMembers()
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
		for classIndex, v in pairs(parent.FilterFrame.classFilterPanel.ClassPanels) do
			v.Class.Button:SetChecked(true)

			for specIndex, y in pairs(v.SpecFrames) do
				y.Button:SetChecked(true)

				MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.spec[specIndex] = true

			end

			MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.class[classIndex] = true

			if(not miog.checkForActiveFilters(filterFrame)) then
				filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

		end

		miog.checkListForEligibleMembers()

	end)
	filterFrame.checkAllFiltersButton = checkAllFiltersButton

	local classFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", filterFrame, filterFrame:GetWidth() - 2, 20 * 14)
	classFilterPanel:SetPoint("TOPLEFT", lastFilterOption or filterFrame, lastFilterOption and "BOTTOMLEFT" or "TOPLEFT", 0, lastFilterOption and -5 or -20)
	classFilterPanel.ClassPanels = {}

	filterFrame.classFilterPanel = classFilterPanel

	for classIndex, classEntry in ipairs(miog.CLASSES) do
		local classPanel = CreateFrame("Frame", nil, classFilterPanel, "MIOG_ClassSpecFilterRowTemplate")

		classPanel:SetSize(classFilterPanel:GetWidth(), 20)
		classPanel:SetPoint("TOPLEFT", classFilterPanel.ClassPanels[classIndex-1] or classFilterPanel, classFilterPanel.ClassPanels[classIndex-1] and "BOTTOMLEFT" or "TOPLEFT", 0, -1)
		local r, g, b = GetClassColor(classEntry.name)
		miog.createFrameBorder(classPanel, 1, r, g, b, 0.9)
		classPanel:SetBackdropColor(r, g, b, 0.6)

		if(MIOG_SavedSettings and MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec) then
			if(MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.class[classIndex] ~= nil) then
				classPanel.Class.Button:SetChecked(MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.class[classIndex])
				
				if(MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.class[classIndex] == false) then
					filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))
				end

			else
				classPanel.Class.Button:SetChecked(true)

			end

		else
			classPanel.Class.Button:SetChecked(true)

		end

		classPanel.Class.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. "/classIcons/" .. classEntry.name .. "_round.png")

		classFilterPanel.ClassPanels[classIndex] = classPanel
		classPanel.SpecFrames = {}

		for specIndex, specID in pairs(classEntry.specs) do
			local specEntry = miog.SPECIALIZATIONS[specID]

			local currentSpec = CreateFrame("Frame", nil, classFilterPanel, "MIOG_ClassSpecSingleOptionTemplate")
			currentSpec:SetSize(36, 20)
			currentSpec:SetPoint("LEFT", classPanel.SpecFrames[classEntry.specs[specIndex-1]] or classPanel.Class.Texture, "RIGHT", 8, 0)

			if(MIOG_SavedSettings and MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec) then
				if(MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.spec[specID] ~= nil) then
					currentSpec.Button:SetChecked(MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.spec[specID])

					if(MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.spec[specID] == false) then
						filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))
					end

				else
					currentSpec.Button:SetChecked(true)

				end

			else
				currentSpec.Button:SetChecked(true)

			end


			currentSpec.Button:SetScript("OnClick", function()
				local state = currentSpec.Button:GetChecked()

				if(state) then
					classPanel.Class.Button:SetChecked(true)

					if(not miog.checkForActiveFilters(filterFrame)) then
						filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

					end

				else
					filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

				end

				MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.spec[specID] = state

				if(MIOG_SavedSettings[parentName .. "_FilterOptions"].table.filterForClassSpecs) then
					miog.checkListForEligibleMembers()
				end

			end)

			--local specTexture = miog.createBasicTexture("persistent", specEntry.icon, specFilterPanel, miog.C.APPLICANT_MEMBER_HEIGHT - 4, miog.C.APPLICANT_MEMBER_HEIGHT - 4, "ARTWORK")
			currentSpec.Texture:SetTexture(specEntry.icon)
			--specTexture:SetPoint("LEFT", toggleSpecButton, "RIGHT", 0, 0)

			--specFilterPanel.SpecTextures[specID] = specTexture
			--specFilterPanel.SpecButtons[specID] = toggleSpecButton

			classPanel.SpecFrames[specID] = currentSpec

		end

		classPanel.Class.Button:SetScript("OnClick", function()
			local state = classPanel.Class.Button:GetChecked()

			for specIndex, specFrame in pairs(classPanel.SpecFrames) do
			--for i = 1, 4, 1 do

				if(state) then
					specFrame.Button:SetChecked(true)

				else
					specFrame.Button:SetChecked(false)

				end

				MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.spec[specIndex] = state
			end

			MIOG_SavedSettings[parentName .. "_FilterOptions"].table.classSpec.class[classIndex] = state

			if(not miog.checkForActiveFilters(filterFrame)) then
				filterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				filterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

			end

			if(MIOG_SavedSettings[parentName .. "_FilterOptions"].table.filterForClassSpecs) then
				miog.checkListForEligibleMembers()
			end
		end)

	end

	lastFilterOption = filterFrame
	
	return filterFrame
end

local function createApplicationViewer()
	local applicationViewer = CreateFrame("Frame", "MythicIOGrabber_ApplicationViewer", miog.pveFrame2.Plugin, "MIOG_ApplicationViewer") ---@class Frame
	miog.applicationViewer = applicationViewer
	miog.createFrameBorder(applicationViewer, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	applicationViewer:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	--applicationViewer:SetPoint("TOPLEFT", miog.mainFrame, "TOPLEFT")
	--applicationViewer:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT")
	--applicationViewer:SetFrameStrata("DIALOG")

	local classPanel = applicationViewer.ClassPanel

	applicationViewer.classPanel = classPanel

	classPanel.classFrames = {}

	for classID, classEntry in ipairs(miog.CLASSES) do
		local classFrame = CreateFrame("Frame", nil, classPanel, "MIOG_ClassPanelClassFrameTemplate")
		classFrame.layoutIndex = classID
		classFrame:SetSize(25, 25)
		classFrame.Icon:SetTexture(classEntry.icon)
		classFrame.rightPadding = 3
		classPanel.classFrames[classID] = classFrame

		local specPanel = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", classFrame)
		specPanel:SetPoint("TOP", classFrame, "BOTTOM", 0, -5)
		specPanel.fixedHeight = 22
		specPanel.specFrames = {}
		specPanel:Hide()
		classFrame.specPanel = specPanel

		local specCounter = 1

		for _, specID in ipairs(classEntry.specs) do
			local specFrame = CreateFrame("Frame", nil, specPanel, "MIOG_ClassPanelSpecFrameTemplate")
			specFrame:SetSize(specPanel.fixedHeight - 1, specPanel.fixedHeight - 1)
			specFrame.Icon:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
			specFrame.layoutIndex = specCounter
			specFrame.leftPadding = 0
			--miog.createFrameBorder(specFrame, 1, 0, 0, 0, 1)

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

	applicationViewer.TitleBar.Faction:SetTexture(2437241)
	applicationViewer.InfoPanel.Background:SetTexture(miog.ACTIVITY_BACKGROUNDS[10])

	local buttonPanel = applicationViewer.ButtonPanel

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
				buttonPanel.FilterString:SetText(WrapTextInColorCode("No filters", "FFFFFFFF"))

			else
				buttonPanel.FilterString:SetText(WrapTextInColorCode("Filter active", "FFFFFF00"))

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

	local filterFrame = createClassSpecFilters(applicationViewer.ButtonPanel, "applicationViewer")
	filterFrame:SetHeight(350)
	filterFrame:SetPoint("TOPLEFT", roleFilterPanel, "BOTTOMLEFT")

	--[====[local classFilterPanel = miog.createBasicFrame("persistent", "BackdropTemplate", filterPanel, filterPanel:GetWidth() - 2, filterPanel:GetHeight() - roleFilterPanel:GetHeight())
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

	end]====]

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
	lastInvitesPanel:SetPoint("TOPLEFT", applicationViewer.TitleBar, "TOPRIGHT", 5, 0)
	miog.createFrameBorder(lastInvitesPanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	lastInvitesPanel.standardHeight = 140
	lastInvitesPanel:Hide()

	applicationViewer.lastInvitesPanel = lastInvitesPanel

	local lastInvitesShowHideButton = miog.createBasicFrame("persistent", "UIButtonTemplate, BackdropTemplate", applicationViewer, 20, 100)
	lastInvitesShowHideButton:SetPoint("TOPLEFT", applicationViewer.InfoPanel, "TOPRIGHT")
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

	local browseGroupsButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.applicationViewer, 1, 20)
	browseGroupsButton:SetPoint("LEFT", miog.mainFrame.footerBar.backButton, "RIGHT")
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
				LFGListSearchPanel_DoSearch(searchPanel)
				LFGListFrame_SetActivePanel(LFGListFrame, searchPanel)
			end
		end
	end)

	miog.applicationViewer.browseGroupsButton = browseGroupsButton

	local delistButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.applicationViewer, 1, 20)
	delistButton:SetPoint("LEFT", browseGroupsButton, "RIGHT")
	delistButton:SetText("Delist")
	delistButton:FitToText()
	delistButton:RegisterForClicks("LeftButtonDown")
	delistButton:SetScript("OnClick", function()
		C_LFGList.RemoveListing()
	end)

	miog.applicationViewer.delistButton = delistButton

	local editButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.applicationViewer, 1, 20)
	editButton:SetPoint("LEFT", delistButton, "RIGHT")
	editButton:SetText("Edit")
	editButton:FitToText()
	editButton:RegisterForClicks("LeftButtonDown")
	editButton:SetScript("OnClick", function()
		local entryCreation = LFGListFrame.EntryCreation
		LFGListEntryCreation_SetEditMode(entryCreation, true)
		LFGListFrame_SetActivePanel(LFGListFrame, entryCreation)
	end)

	miog.applicationViewer.editButton = editButton

	local applicantNumberFontString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, miog.applicationViewer)
	applicantNumberFontString:SetPoint("RIGHT", miog.mainFrame.footerBar, "RIGHT", -3, -1)
	applicantNumberFontString:SetJustifyH("CENTER")
	applicantNumberFontString:SetText(0)

	miog.applicationViewer.applicantNumberFontString = applicantNumberFontString

	local applicantPanel = miog.createBasicFrame("persistent", "ScrollFrameTemplate", titleBar)
	applicantPanel:SetPoint("TOPLEFT", buttonPanel, "BOTTOMLEFT", 2, 0)
	applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame.footerBar, "TOPRIGHT", 0, 0)
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

miog.addDungeonCheckboxes = addDungeonCheckboxes

local function createSearchPanel()
	local searchPanel = miog.searchPanel ---@class Frame
	searchPanel:SetPoint("TOPLEFT", miog.mainFrame, "TOPLEFT")
	searchPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT")
	searchPanel:SetFrameStrata("DIALOG")

	searchPanel:HookScript("OnShow", function()
		LFGListFrame.SearchPanel.SearchBox:Show()
	end)

	local filterFrame = createClassSpecFilters(searchPanel, "searchPanel")
	filterFrame:SetPoint("TOPLEFT", miog.searchPanel, "TOPRIGHT", 10, 0)

	addOptionToFilterFrame(searchPanel, "searchPanel", "Class / spec", "filterForClassSpecs")

	local dropdownOptionButton = miog.createBasicFrame("persistent", "UICheckButtonTemplate", filterFrame, miog.C.INTERFACE_OPTION_BUTTON_SIZE, miog.C.INTERFACE_OPTION_BUTTON_SIZE)
	dropdownOptionButton:SetNormalAtlas("checkbox-minimal")
	dropdownOptionButton:SetPushedAtlas("checkbox-minimal")
	dropdownOptionButton:SetCheckedTexture("checkmark-minimal")
	dropdownOptionButton:SetDisabledCheckedTexture("checkmark-minimal-disabled")
	dropdownOptionButton:SetPoint("TOPLEFT", lastFilterOption or filterFrame, "BOTTOMLEFT", 0, -5)
	dropdownOptionButton:RegisterForClicks("LeftButtonDown")
	dropdownOptionButton:SetChecked(MIOG_SavedSettings and MIOG_SavedSettings.searchPanel_FilterOptions.table[LFGListFrame.SearchPanel.categoryID == 2 and "filterForDungeonDifficulty" or
	LFGListFrame.SearchPanel.categoryID == 3 and "filterForRaidDifficulty" or
	(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "filterForArenaBracket"] or false)
	dropdownOptionButton:HookScript("OnClick", function()
		MIOG_SavedSettings.searchPanel_FilterOptions.table[
			LFGListFrame.SearchPanel.categoryID == 2 and "filterForDungeonDifficulty" or
			LFGListFrame.SearchPanel.categoryID == 3 and "filterForRaidDifficulty" or
			(LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "filterForArenaBracket"] = dropdownOptionButton:GetChecked()
		miog.checkListForEligibleMembers()
	end)

	filterFrame.filterForDifficulty = dropdownOptionButton

	local function fillDropdown(optionDropdown, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		local currentCategoryTableValue = LFGListFrame.SearchPanel.categoryID == 2 and "dungeonDifficultyID" or LFGListFrame.SearchPanel.categoryID == 3 and "raidDifficultyID" or (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "bracketID" or nil
		if(currentCategoryTableValue) then
			local currentCategoryDescription = currentCategoryTableValue and (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and miog.BRACKETS[MIOG_SavedSettings.searchPanel_FilterOptions.table[currentCategoryTableValue]].description
			or miog.DIFFICULTY[MIOG_SavedSettings.searchPanel_FilterOptions.table[currentCategoryTableValue]].description

			UIDropDownMenu_SetText(optionDropdown, currentCategoryDescription)

		end

		info.func = function(_, arg1, _, _)
				currentCategoryTableValue = LFGListFrame.SearchPanel.categoryID == 2 and "dungeonDifficultyID" or LFGListFrame.SearchPanel.categoryID == 3 and "raidDifficultyID" or (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and "bracketID" or nil
				if(currentCategoryTableValue) then
					MIOG_SavedSettings.searchPanel_FilterOptions.table[currentCategoryTableValue] = arg1

					local currentCategoryDescription = currentCategoryTableValue and (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and miog.BRACKETS[MIOG_SavedSettings.searchPanel_FilterOptions.table[currentCategoryTableValue]].description
					or miog.DIFFICULTY[MIOG_SavedSettings.searchPanel_FilterOptions.table[currentCategoryTableValue]].description
					
					if(dropdownOptionButton:GetChecked()) then
						miog.checkListForEligibleMembers()

					end

					UIDropDownMenu_SetText(optionDropdown, currentCategoryDescription)

					CloseDropDownMenus()
				end
		end

		for i = (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and 2 or LFGListFrame.SearchPanel.categoryID == 3 and 3 or 4, 1, -1 do
			info.text, info.arg1 = (LFGListFrame.SearchPanel.categoryID == 4 or LFGListFrame.SearchPanel.categoryID == 7) and miog.BRACKETS[i].description or miog.DIFFICULTY[i].description, i
			info.checked = i == MIOG_SavedSettings.searchPanel_FilterOptions.table[currentCategoryTableValue]
			UIDropDownMenu_AddButton(info)

		end

	end

	local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", filterFrame)
	optionDropdown:SetPoint("LEFT", dropdownOptionButton, "RIGHT", -15, 0)
	optionDropdown.initialize = fillDropdown
	UIDropDownMenu_SetWidth(optionDropdown, 175)

	filterFrame.dropdown = optionDropdown

	lastFilterOption = dropdownOptionButton

	-- KEY LEVEL
	-- DUNGEONS

	addOptionToFilterFrame(searchPanel, "searchPanel", "Party fit", "partyFit")
	addOptionToFilterFrame(searchPanel, "searchPanel", "Ress fit", "ressFit")
	addOptionToFilterFrame(searchPanel, "searchPanel", "Lust fit", "lustFit")
	addDualNumericSpinnerToFilterFrame("Tanks")
	addDualNumericSpinnerToFilterFrame("Healers")
	addDualNumericSpinnerToFilterFrame("Damager")

	addDualNumericFieldsToFilterFrame("Score")

	local divider = miog.createBasicTexture("persistent", nil, filterFrame, filterFrame:GetWidth(), 1, "BORDER")
	divider:SetAtlas("UI-LFG-DividerLine")
	divider:SetPoint("BOTTOM", lastFilterOption, "BOTTOM", 0, -5)

	lastFilterOption = divider

	addOptionToFilterFrame(searchPanel, "searchPanel", "Dungeon options", "dungeonOptions")
	--addDungeonCheckboxes()

	local signupButton = miog.createBasicFrame("persistent", "UIPanelDynamicResizeButtonTemplate", miog.searchPanel, 1, 20)
	signupButton:SetPoint("LEFT", miog.mainFrame.footerBar.backButton, "RIGHT")
	signupButton:SetText("Signup")
	signupButton:FitToText()
	signupButton:RegisterForClicks("LeftButtonDown")
	signupButton:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		LFGListApplicationDialog_Show(LFGListApplicationDialog, miog.F.CURRENT_SEARCH_RESULT_ID)

		miog.signupToGroup(LFGListFrame.SearchPanel.resultID)
	end)

	searchPanel.SignUpButton = signupButton

	local groupNumberFontString = miog.createBasicFontString("persistent", miog.C.LISTING_INFO_FONT_SIZE, miog.searchPanel)
	groupNumberFontString:SetPoint("RIGHT", miog.mainFrame.footerBar, "RIGHT", -3, -1)
	groupNumberFontString:SetJustifyH("CENTER")
	groupNumberFontString:SetText(0)

	searchPanel.groupNumberFontString = groupNumberFontString

	local interactionPanel = miog.createBasicFrame("persistent", "BackdropTemplate", searchPanel, miog.mainFrame.standardWidth, 45)
	interactionPanel:SetPoint("TOPLEFT", searchPanel, "TOPLEFT")

	local searchFrame = miog.createBasicFrame("persistent", "BackdropTemplate", searchPanel, miog.mainFrame.standardWidth, 20)
	searchFrame:SetFrameStrata("DIALOG")
	searchFrame:SetPoint("TOPLEFT", interactionPanel, "TOPLEFT")

	local filterShowHideButton = miog.createBasicFrame("persistent", "UIButtonTemplate, BackdropTemplate", searchFrame, 52, miog.C.APPLICANT_MEMBER_HEIGHT)
	filterShowHideButton:SetPoint("RIGHT", searchFrame, "RIGHT")
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

	local searchButton = miog.createBasicFrame("persistent", "UIButtonTemplate, BackdropTemplate", searchFrame, 52, miog.C.APPLICANT_MEMBER_HEIGHT)
	searchButton:SetPoint("RIGHT", filterShowHideButton, "LEFT")
	searchButton:RegisterForClicks("LeftButtonDown")
	miog.createFrameBorder(searchButton, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	searchButton:SetScript("OnClick", function( )
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)

		miog.searchPanel.resultPanel:SetVerticalScroll(0)
	end)

	searchPanel.searchButton = searchButton

	local searchButtonString = miog.createBasicFontString("persistent", 12, searchButton)
	searchButtonString:SetWidth(52)
	searchButtonString:SetPoint("CENTER", searchButton, "CENTER")
	searchButtonString:SetJustifyH("CENTER")
	searchButtonString:SetText(_G["SEARCH"])

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
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 160, 0)

		elseif(i == 2) then
			currentCategory = "secondary"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 197, 0)

		elseif(i == 3) then
			currentCategory = "age"
			sortByCategoryButton:SetPoint("LEFT", buttonPanel, "LEFT", 257, 0)

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

				miog.checkListForEligibleMembers()
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

					miog.checkListForEligibleMembers()
				end
			end
		end)

		buttonPanel.sortByCategoryButtons[currentCategory] = sortByCategoryButton

	end
	
	local resultStatusFrame = miog.createBasicFrame("persistent", "BackdropTemplate", searchPanel)
	resultStatusFrame:SetPoint("TOPLEFT", interactionPanel, "BOTTOMLEFT")
	resultStatusFrame:SetPoint("BOTTOMRIGHT", miog.mainFrame.footerBar, "TOPRIGHT")
	resultStatusFrame:SetFrameStrata("FULLSCREEN")
	searchPanel.statusFrame = resultStatusFrame

	local statusBackground = miog.createBasicTexture("persistent", nil, resultStatusFrame)
	statusBackground:SetAllPoints(true)
	statusBackground:SetColorTexture(0.1, 0.1, 0.1, 0.93)
	resultStatusFrame.background = statusBackground

	local loadingSpinner = miog.createBasicFrame("persistent", "LoadingSpinnerTemplate", resultStatusFrame, 60, 60)
	loadingSpinner:SetPoint("TOP", resultStatusFrame, "TOP", 0, -10)
	loadingSpinner:Hide()
	resultStatusFrame.loadingSpinner = loadingSpinner

	local throttledString = miog.createBasicFontString("persistent", 16, resultStatusFrame)
	throttledString:SetWidth(resultStatusFrame:GetWidth())
	throttledString:SetPoint("TOP", resultStatusFrame, "TOP", 0, -10)
	throttledString:SetWordWrap(true)
	throttledString:SetNonSpaceWrap(true)
	throttledString:SetJustifyH("CENTER")
	throttledString:SetScript("OnEnter", function()
		
	end)
	throttledString:Hide()
	resultStatusFrame.throttledString = throttledString

	local noResultsString = miog.createBasicFontString("persistent", 16, resultStatusFrame)
	noResultsString:SetWidth(resultStatusFrame:GetWidth())
	noResultsString:SetPoint("TOP", resultStatusFrame, "TOP", 0, -10)
	noResultsString:SetWordWrap(true)
	noResultsString:SetNonSpaceWrap(true)
	noResultsString:SetJustifyH("CENTER")
	noResultsString:SetScript("OnEnter", function()
		
	end)
	noResultsString:Hide()
	resultStatusFrame.noResultsString = noResultsString

	local resultPanel = miog.createBasicFrame("persistent", "ScrollFrameTemplate", searchPanel)
	resultPanel:SetPoint("TOPLEFT", interactionPanel, "BOTTOMLEFT", 1, -1)
	resultPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame.footerBar, "TOPRIGHT", 1, 1)
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

local function createUpgradedInvitePendingDialog()
	local ipDialog = miog.ipDialog ---@class Frame
	ipDialog.fixedWidth = miog.C.MAIN_WIDTH + 25
	ipDialog.minimumHeight = 1
	ipDialog.extend = true
	ipDialog.activeFrames = 0
	--ipDialog:SetScale(miog.mainFrame:GetEffectiveScale())
	ipDialog:SetScript("OnEnter", function()
		
	end)
	miog.createFrameBorder(ipDialog, 1, CreateColorFromHexString(miog.CLRSCC.yellow):GetRGBA())
	ipDialog:Hide()
	StaticPopup_SetUpPosition(miog.ipDialog)
	ipDialog:SetFrameStrata("MEDIUM")

	local ipDialogBackground = miog.createBasicTexture("persistent", nil, ipDialog)
	ipDialogBackground:SetDrawLayer("BACKGROUND")
	ipDialogBackground:SetAllPoints(true)
	ipDialogBackground:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
	ipDialog.background = ipDialogBackground
	
	local titleBar = miog.createBasicFrame("persistent", "BackdropTemplate", ipDialog, nil, 25)
	titleBar:SetPoint("TOPLEFT", ipDialog, "TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", ipDialog, "TOPRIGHT", 0, 0)
	miog.createFrameBorder(titleBar, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local titleString = miog.createBasicFontString("persistent", miog.C.TITLE_FONT_SIZE, titleBar)
	titleString:SetPoint("TOPLEFT", titleBar, "TOPLEFT", 0, -2)
	titleString:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT")
	titleString:SetJustifyH("CENTER")
	titleString:SetJustifyV("CENTER")
	titleString:SetText("You have been invited!")

	titleBar.titleString = titleString

	local scrollFrameContainer = miog.createBasicFrame("persistent", "VerticalLayoutFrame, BackdropTemplate", ipDialog)
	scrollFrameContainer:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT")
	scrollFrameContainer:SetPoint("BOTTOMRIGHT", ipDialog, "BOTTOMRIGHT")
	scrollFrameContainer.fixedWidth = ipDialog.fixedWidth
	scrollFrameContainer.minimumHeight = 1
	scrollFrameContainer.spacing = 2
	scrollFrameContainer.align = "top"
	ipDialog.container = scrollFrameContainer

	scrollFrameContainer:MarkDirty()
---@diagnostic disable-next-line: undefined-field
	ipDialog:MarkDirty()
end

local frameIndex = 0

local function createInviteFrame()
	frameIndex = frameIndex + 1
	local listInviteFrame = miog.createBasicFrame("persistent", "BackdropTemplate", miog.ipDialog.container, miog.ipDialog.fixedWidth, 40)
	listInviteFrame.layoutIndex = frameIndex
	miog.createFrameBorder(listInviteFrame, 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGB())
	listInviteFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)

	listInviteFrame.framePool = listInviteFrame.framePool or CreateFramePoolCollection()
	listInviteFrame.framePool:GetOrCreatePool("Frame", nil, "BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	listInviteFrame.framePool:GetOrCreatePool("Frame", nil, "HorizontalLayoutFrame, BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	listInviteFrame.framePool:GetOrCreatePool("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	listInviteFrame.framePool:GetOrCreatePool("Button", nil, "IconButtonTemplate, BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	listInviteFrame.framePool:GetOrCreatePool("Button", nil, "UIButtonTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	listInviteFrame.framePool:GetOrCreatePool("Button", nil, "UIButtonTemplate, BackdropTemplate", miog.resetFrame):SetResetDisallowedIfNew()
	listInviteFrame.framePool:GetOrCreatePool("Button", nil, "UIPanelButtonTemplate", miog.resetFrame):SetResetDisallowedIfNew()

	-- resultID, appStatus, pendingStatus, appDuration, role

	listInviteFrame.fontStringPool = listInviteFrame.fontStringPool or CreateFontStringPool(listInviteFrame, "OVERLAY", nil, "GameTooltipText", miog.resetFontString)
	listInviteFrame.texturePool = listInviteFrame.texturePool or CreateTexturePool(listInviteFrame, "ARTWORK", nil, nil, miog.resetTexture)

	local resultFrameBackground = miog.createFleetingTexture(listInviteFrame.texturePool, nil, listInviteFrame)
	resultFrameBackground:SetDrawLayer("BACKGROUND")
	resultFrameBackground:SetAllPoints(true)
	resultFrameBackground:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
	listInviteFrame.background = resultFrameBackground

	local resultFrameStatusFrame = miog.createFleetingFrame(listInviteFrame.framePool, "BackdropTemplate", listInviteFrame)
	resultFrameStatusFrame:Hide()
	resultFrameStatusFrame:SetAllPoints(true)
	listInviteFrame.statusFrame = resultFrameStatusFrame

	local resultFrameStatusFrameBackground = miog.createFleetingTexture(listInviteFrame.texturePool, nil, resultFrameStatusFrame)
	resultFrameStatusFrameBackground:SetAllPoints(true)
	resultFrameStatusFrameBackground:SetColorTexture(0.1, 0.1, 0.1, 0.77)

	local statusFrameFontString = miog.createFleetingFontString(listInviteFrame.fontStringPool, 16, resultFrameStatusFrame)
	statusFrameFontString:SetPoint("CENTER", resultFrameStatusFrame, "CENTER")
	resultFrameStatusFrame.FontString = statusFrameFontString
	resultFrameStatusFrame.FontString:SetJustifyH("CENTER")
	resultFrameStatusFrame.FontString:Show()

	local iconFrameBorder = miog.createFleetingTexture(listInviteFrame.texturePool, nil, listInviteFrame, 36, 36)
	iconFrameBorder:SetDrawLayer("OVERLAY", -5)
	iconFrameBorder:SetPoint("TOPLEFT", listInviteFrame, "TOPLEFT", 2, -2)

	local iconFrame = miog.createFleetingTexture(listInviteFrame.texturePool, nil, listInviteFrame)
	iconFrame:SetPoint("TOPLEFT", iconFrameBorder, "TOPLEFT", 2, -2)
	iconFrame:SetPoint("BOTTOMRIGHT", iconFrameBorder, "BOTTOMRIGHT", -2, 2)
	iconFrame:SetMouseClickEnabled(true)
	iconFrame:SetDrawLayer("OVERLAY")
	iconFrame.border = iconFrameBorder

	listInviteFrame.iconFrame = iconFrame

	local titleFrame = miog.createFleetingFontString(listInviteFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, listInviteFrame)
	titleFrame:SetText("TITLE TEXT HERE")
	titleFrame:SetWidth(miog.ipDialog.container.fixedWidth * 0.35)
	titleFrame:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 5, -2)
	listInviteFrame.titleFrame = titleFrame

	local primaryIndicator = miog.createFleetingFontString(listInviteFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, listInviteFrame)
	primaryIndicator:SetWidth(miog.ipDialog.container.fixedWidth * 0.11)
	primaryIndicator:SetPoint("LEFT", titleFrame, "RIGHT", 5, 0)
	primaryIndicator:SetJustifyH("CENTER")
	primaryIndicator:SetText(0)
	listInviteFrame.primaryIndicator = primaryIndicator

	local secondaryIndicator = miog.createFleetingFontString(listInviteFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, listInviteFrame)
	secondaryIndicator:SetWidth(miog.ipDialog.container.fixedWidth * 0.11)
	secondaryIndicator:SetPoint("LEFT", primaryIndicator, "RIGHT", 1, 0)
	secondaryIndicator:SetJustifyH("CENTER")
	secondaryIndicator:SetText(0)
	listInviteFrame.secondaryIndicator = secondaryIndicator

	local ageFrame = miog.createFleetingFontString(listInviteFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, listInviteFrame)
	ageFrame:SetPoint("LEFT", secondaryIndicator, "RIGHT", 1, 0)
	ageFrame:SetWidth(miog.ipDialog.container.fixedWidth * 0.24)
	ageFrame:SetJustifyH("CENTER")
	ageFrame:SetTextColor(CreateColorFromHexString(miog.CLRSCC.purple):GetRGBA())
	ageFrame:SetText("[0:01:30]")
	listInviteFrame.ageFrame = ageFrame

	local friendFrame = miog.createFleetingTexture(listInviteFrame.texturePool, miog.C.STANDARD_FILE_PATH .. "/infoIcons/friend.png", listInviteFrame, 20 - 3, 20 - 3)
	friendFrame:SetPoint("LEFT", ageFrame, "RIGHT", 3, 1)
	friendFrame:SetDrawLayer("ARTWORK")
	friendFrame:SetMouseMotionEnabled(true)
	friendFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(friendFrame, "ANCHOR_CURSOR")
		GameTooltip:SetText("A friend is in this group")
		GameTooltip:Show()

	end)
	friendFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()

	end)
	listInviteFrame.friendFrame = friendFrame

	local dividerFirstSecondFrame = miog.createFleetingTexture(listInviteFrame.texturePool, nil, listInviteFrame, miog.ipDialog.container.fixedWidth - iconFrameBorder:GetWidth(), 2, "BORDER")
	dividerFirstSecondFrame:SetAtlas("UI-LFG-DividerLine")
	dividerFirstSecondFrame:SetPoint("LEFT", iconFrame, "RIGHT", 0, 0)

	local difficultyZoneFrame = miog.createFleetingFontString(listInviteFrame.fontStringPool, miog.C.APPLICANT_MEMBER_FONT_SIZE, listInviteFrame)
	difficultyZoneFrame:SetText("DIFFICULTY TEXT HERE")
	difficultyZoneFrame:SetWidth(titleFrame:GetWidth())
	difficultyZoneFrame:SetPoint("BOTTOMLEFT", iconFrame, "BOTTOMRIGHT", 5, 0)
	listInviteFrame.difficultyZoneFrame = difficultyZoneFrame
	
	local resultMemberPanel = miog.createFleetingFrame(listInviteFrame.framePool, "BackdropTemplate", listInviteFrame)
	resultMemberPanel:SetHeight(20 - 4)
	resultMemberPanel:SetWidth(100)
	resultMemberPanel:SetPoint("LEFT", difficultyZoneFrame, "RIGHT", 5, 2)
	resultMemberPanel:Hide()
	resultMemberPanel.memberFrames = {}
	listInviteFrame.memberPanel = resultMemberPanel

	for i = 1, 5, 1 do
		local resultMemberFrame = miog.createFleetingTexture(listInviteFrame.texturePool, nil, resultMemberPanel, 13, 13)
		resultMemberFrame:SetPoint("LEFT", resultMemberPanel.memberFrames[i-1] or resultMemberPanel, resultMemberPanel.memberFrames[i-1] and "RIGHT" or "LEFT", 14, 0)
		resultMemberFrame:SetDrawLayer("OVERLAY", -4)
		resultMemberPanel.memberFrames[i] = resultMemberFrame

		resultMemberFrame.border = miog.createFleetingTexture(listInviteFrame.texturePool, nil, resultMemberPanel)
		resultMemberFrame.border:SetDrawLayer("OVERLAY", -5)
		resultMemberFrame.border:SetPoint("TOPLEFT", resultMemberFrame, "TOPLEFT", -2, 2)
		resultMemberFrame.border:SetPoint("BOTTOMRIGHT", resultMemberFrame, "BOTTOMRIGHT", 2, -2)
	end

	local resultMemberComp = miog.createFleetingFontString(listInviteFrame.fontStringPool, 12, listInviteFrame)
	resultMemberComp:SetPoint("LEFT", difficultyZoneFrame, "RIGHT", 5, 0)
	listInviteFrame.resultMemberComp = resultMemberComp

	local declineInviteButton = miog.createFleetingFrame(listInviteFrame.framePool, "IconButtonTemplate, BackdropTemplate", listInviteFrame, 20, 20)
	declineInviteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	declineInviteButton.iconSize = 20 - 4
	declineInviteButton:OnLoad()
	declineInviteButton:SetPoint("TOPRIGHT", listInviteFrame, "TOPRIGHT", -1, -1)
	declineInviteButton:RegisterForClicks("LeftButtonDown")
	listInviteFrame.declineInviteButton = declineInviteButton

	local acceptInviteButton = miog.createFleetingFrame(listInviteFrame.framePool, "IconButtonTemplate, BackdropTemplate", listInviteFrame, 20, 20)
	acceptInviteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png"
	acceptInviteButton.iconSize = 20 - 4
	acceptInviteButton:OnLoad()
	acceptInviteButton:SetPoint("BOTTOMRIGHT", listInviteFrame, "BOTTOMRIGHT", -1, 1)
	acceptInviteButton:RegisterForClicks("LeftButtonDown")
	listInviteFrame.acceptInviteButton = acceptInviteButton
	
	local resultBossPanel = miog.createFleetingFrame(listInviteFrame.framePool, "ResizeLayoutFrame, BackdropTemplate", listInviteFrame)
	resultBossPanel.fixedHeight = 20 - 4
	resultBossPanel:SetPoint("BOTTOMRIGHT", acceptInviteButton, "BOTTOMLEFT", 0, 1)
	resultBossPanel:Hide()
	resultBossPanel.bossFrames = {}
	listInviteFrame.bossPanel = resultBossPanel

	for i = 1, miog.F.MOST_BOSSES, 1 do
		local resultBossFrame = miog.createFleetingTexture(listInviteFrame.texturePool, nil, resultBossPanel, 12, 12)
		resultBossFrame:SetPoint("RIGHT", resultBossPanel.bossFrames[i-1] or resultBossPanel, resultBossPanel.bossFrames[i-1] and "LEFT" or "RIGHT", -2, 0)
		resultBossFrame:SetDrawLayer("ARTWORK")
		resultBossPanel.bossFrames[i] = resultBossFrame
	end

	resultBossPanel:MarkDirty()

	local leaderCrown = miog.createFleetingTexture(listInviteFrame.texturePool, miog.C.STANDARD_FILE_PATH .. "/infoIcons/leaderIcon.png", resultMemberPanel, 14, 14)
	leaderCrown:SetDrawLayer("OVERLAY", -3)
	leaderCrown:Hide()
	resultMemberPanel.leaderCrown = leaderCrown

	return listInviteFrame
end

local currentInvites = {}

miog.currentInvites = currentInvites

local function updateInviteFrame(resultID, newStatus)
	local resultFrame = currentInvites[resultID]

	if(resultFrame and newStatus and newStatus ~= "invited") then
		resultFrame.statusFrame:Show()
		resultFrame.statusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[newStatus].statusString, miog.APPLICANT_STATUS_INFO[newStatus].color))
		--resultFrame:SetScript("OnMouseDown", nil)

		resultFrame.ageFrame.ageTicker:Cancel()

		--miog.createFrameBorder(searchResultSystem.resultFrames[resultID], 2, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGB())
		resultFrame:SetBackdropBorderColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		resultFrame.background:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

		if(newStatus == "declined" or newStatus == "declined_full" or newStatus == "declined_delisted" or newStatus == "timedout") then
			resultFrame.acceptInviteButton:Hide()
			--resultFrame.declineInviteButton:Hide()

			--miog.hideActiveInviteFrame(resultID)
		end
	end
end

miog.updateInviteFrame = updateInviteFrame

local function hideActiveInviteFrame(resultID)
	if(currentInvites[resultID]) then
		currentInvites[resultID].fontStringPool:ReleaseAll()
		currentInvites[resultID].texturePool:ReleaseAll()
		currentInvites[resultID].framePool:ReleaseAll()
		miog.persistentFramePool:Release(currentInvites[resultID])

		currentInvites[resultID] = nil
		
		miog.ipDialog.container:MarkDirty()
		---@diagnostic disable-next-line: undefined-field
		miog.ipDialog:MarkDirty()

		miog.ipDialog.activeFrames = miog.ipDialog.activeFrames - 1

		if(miog.ipDialog.activeFrames == 0) then
			miog.ipDialog:Hide()

		end
	end

end

miog.hideActiveInviteFrame = hideActiveInviteFrame

miog.showUpgradedInvitePendingDialog = function(resultID)
	local currentFrame

	if(not currentInvites[resultID]) then
		currentFrame = createInviteFrame()
		miog.ipDialog.activeFrames = miog.ipDialog.activeFrames + 1

		PlaySound(SOUNDKIT.READY_CHECK)

	else
		currentFrame = currentInvites[resultID]
	
	end
	
	FlashClientIcon()

	local searchResultData = C_LFGList.GetSearchResultInfo(resultID)
	local activityInfo = C_LFGList.GetActivityInfoTable(searchResultData.activityID)
	local mapID = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].mapID or 0
	local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)

	currentFrame:SetScript("OnEnter", function()
		miog.createResultTooltip(searchResultData.searchResultID, currentFrame, searchResultData.autoAccept)

	end)

	if(not currentInvites[resultID]) then
		currentFrame.acceptInviteButton:SetScript("OnClick", function(self, button)
			miog.handleInvite(self, button, resultID, true)
			hideActiveInviteFrame(resultID)
			
		end)

		currentFrame.declineInviteButton:SetScript("OnClick", function(self, button)
			miog.handleInvite(self, button, resultID, false)
			hideActiveInviteFrame(resultID)

		end)

		local _, _, _, appDuration = C_LFGList.GetApplicationInfo(resultID)
		appDuration = appDuration > 0 and appDuration or 89

		currentFrame.ageFrame.ageTicker = C_Timer.NewTicker(1, function()
			appDuration = appDuration - 1
			currentFrame.ageFrame:SetText("[" .. miog.secondsToClock(appDuration) .. "]")

		end)
	end

	currentFrame.iconFrame:SetTexture(miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID][#miog.MAP_INFO[mapID]] and miog.MAP_INFO[mapID][#miog.MAP_INFO[mapID]].icon or nil)
	currentFrame.iconFrame:SetScript("OnMouseDown", function()

		--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
		EncounterJournal_OpenJournal(miog.F.CURRENT_DUNGEON_DIFFICULTY, instanceID, nil, nil, nil, nil)

	end)
	local color = miog.ACTIVITY_ID_INFO[searchResultData.activityID] and
	(activityInfo.isPvpActivity and miog.BRACKETS[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].miogColors
	or miog.DIFFICULTY[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].miogColors) or {r = 1, g = 1, b = 1}
	currentFrame.iconFrame.border:SetColorTexture(color.r, color.g, color.b, 1)

	currentFrame.titleFrame:SetText(searchResultData.name)
	currentFrame.friendFrame:SetShown((searchResultData.numBNetFriends > 0 or searchResultData.numCharFriends > 0 or searchResultData.numGuildMates > 0) and true or false)

	currentFrame.difficultyZoneFrame:SetText(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.DIFFICULTY[miog.ACTIVITY_ID_INFO[searchResultData.activityID].difficultyID].shortName .. " - " ..
	(miog.ACTIVITY_ID_INFO[searchResultData.activityID] and miog.ACTIVITY_ID_INFO[searchResultData.activityID].shortName) or activityInfo.fullName)

	currentFrame.primaryIndicator:SetText(nil)
	currentFrame.secondaryIndicator:SetText(nil)

	local appCategory = activityInfo.categoryID
	local primarySortAttribute, secondarySortAttribute

	local nameTable

	if(searchResultData.leaderName) then
		nameTable = miog.simpleSplit(searchResultData.leaderName, "-")
	end

	if(nameTable and not nameTable[2]) then
		nameTable[2] = GetNormalizedRealmName()

		searchResultData.leaderName = nameTable[1] .. "-" .. nameTable[2]

	end

	if(appCategory ~= 3 and appCategory ~= 4 and appCategory ~= 7 and appCategory ~= 8 and appCategory ~= 9) then
		if(searchResultData.leaderOverallDungeonScore > 0) then
			local reqScore = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or 0
			local highestKeyForDungeon

			if(reqScore > searchResultData.leaderOverallDungeonScore) then
				currentFrame.primaryIndicator:SetText(wticc(tostring(searchResultData.leaderOverallDungeonScore), miog.CLRSCC["red"]))

			else
				currentFrame.primaryIndicator:SetText(wticc(tostring(searchResultData.leaderOverallDungeonScore), miog.createCustomColorForScore(searchResultData.leaderOverallDungeonScore):GenerateHexColor()))

			end

			if(searchResultData.leaderDungeonScoreInfo) then
				if(searchResultData.leaderDungeonScoreInfo.finishedSuccess == true) then
					highestKeyForDungeon = wticc(tostring(searchResultData.leaderDungeonScoreInfo.bestRunLevel), miog.C.GREEN_COLOR)

				elseif(searchResultData.leaderDungeonScoreInfo.finishedSuccess == false) then
					highestKeyForDungeon = wticc(tostring(searchResultData.leaderDungeonScoreInfo.bestRunLevel), miog.CLRSCC["red"])

				end
			else
				highestKeyForDungeon = wticc(tostring(0), miog.CLRSCC["red"])

			end

			currentFrame.secondaryIndicator:SetText(highestKeyForDungeon)
		else
			local difficulty = miog.DIFFICULTY[-1] -- NO DATA
			currentFrame.primaryIndicator:SetText(wticc("0", difficulty.color))
			currentFrame.secondaryIndicator:SetText(wticc("0", difficulty.color))

		end
	elseif(appCategory == 3) then
		local raidData = miog.getRaidSortData(searchResultData.leaderName)

		if(raidData) then
			
			primarySortAttribute = wticc(raidData[1].parsedString, raidData[1].ordinal == 1 and miog.DIFFICULTY[raidData[1].difficulty].color or miog.DIFFICULTY[raidData[1].difficulty].desaturated)
			secondarySortAttribute = wticc(raidData[2].parsedString, raidData[2].ordinal == 1 and miog.DIFFICULTY[raidData[2].difficulty].color or miog.DIFFICULTY[raidData[2].difficulty].desaturated)

		else
			primarySortAttribute = 0
			secondarySortAttribute = 0
		
		end

		currentFrame.primaryIndicator:SetText(primarySortAttribute)
		currentFrame.secondaryIndicator:SetText(secondarySortAttribute)

	elseif(appCategory == 4 or appCategory == 7 or appCategory == 8 or appCategory == 9) then
		if(searchResultData.leaderPvpRatingInfo) then
			currentFrame.primaryIndicator:SetText(wticc(tostring(searchResultData.leaderPvpRatingInfo.rating), miog.createCustomColorForScore(searchResultData.leaderPvpRatingInfo.rating):GenerateHexColor()))

			local tierResult = miog.simpleSplit(PVPUtil.GetTierName(searchResultData.leaderPvpRatingInfo.tier), " ")
			currentFrame.secondaryIndicator:SetText(strsub(tierResult[1], 0, tierResult[2] and 2 or 4) .. ((tierResult[2] and "" .. tierResult[2]) or ""))
			
		else
			currentFrame.primaryIndicator:SetText(0)
			currentFrame.secondaryIndicator:SetText("Unra")

		end
	end

	local orderedList = {}

	local roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
	}

	for i = 1, searchResultData.numMembers, 1 do
		local role, class, _, specLocalized = C_LFGList.GetSearchResultMemberInfo(searchResultData.searchResultID, i)

		orderedList[i] = {leader = i == 1 and true or false, role = role, class = class, specID = miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[specLocalized .. "-" .. class]}

		if(role) then
			roleCount[role] = roleCount[role] + 1

		end
	end

	local memberPanel = currentFrame.memberPanel
	local bossPanel = currentFrame.bossPanel

	if(appCategory == 3 or appCategory == 9) then
		memberPanel:Hide()

		currentFrame.resultMemberComp:Show()
		currentFrame.resultMemberComp:SetText(roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"])

		if(miog.MAP_INFO[mapID]) then
			bossPanel:Show()

			local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(resultID)
			local encountersDefeated = {}

			if(encounterInfo) then
				for _, v in pairs(encounterInfo) do
					encountersDefeated[v] = true
				end
			end

			local numOfBosses = #miog.MAP_INFO[mapID] - 1

			for i = 1, miog.F.MOST_BOSSES, 1 do
				local currentRaidInfo = miog.MAP_INFO[mapID][numOfBosses - (i - 1)]
				if(currentRaidInfo) then
					bossPanel.bossFrames[i]:SetTexture(currentRaidInfo.icon)

					if(encountersDefeated[currentRaidInfo.name]) then
						bossPanel.bossFrames[i]:SetDesaturated(true)
						
					else
						bossPanel.bossFrames[i]:SetDesaturated(false)

					end

					bossPanel.bossFrames[i]:Show()

				else
					bossPanel.bossFrames[i]:Hide()
				
				end
			end
		end

	elseif(appCategory ~= 0) then
		-- BRACKET 1 == 3v3, 0 == 2v2
		currentFrame.resultMemberComp:Hide()
		bossPanel:Hide()

		local groupLimit = (appCategory == 4 or appCategory == 7) and (searchResultData.leaderPvpRatingInfo.bracket == 0 and 2 or searchResultData.leaderPvpRatingInfo.bracket == 1 and 3 or 5) or 5
		local groupSize = #orderedList

		if(roleCount["TANK"] == 0 and groupSize < groupLimit) then
			orderedList[groupSize + 1] = {class = "DUMMY", role = "TANK", specID = 20}
			roleCount["TANK"] = roleCount["TANK"] + 1
			groupSize = groupSize + 1
		end

		if(roleCount["HEALER"] == 0 and groupSize < groupLimit) then
			orderedList[groupSize + 1] = {class = "DUMMY", role = "HEALER", specID = 20}
			roleCount["HEALER"] = roleCount["HEALER"] + 1
			groupSize = groupSize + 1

		end

		for _ = 1, 3 - roleCount["DAMAGER"], 1 do
			if(roleCount["DAMAGER"] < 3 and groupSize < groupLimit) then
				orderedList[groupSize + 1] = {class = "DUMMY", role = "DAMAGER", specID = 20}
				roleCount["DAMAGER"] = roleCount["DAMAGER"] + 1
				groupSize = groupSize + 1

			end
		end

		table.sort(orderedList, function(k1, k2)
			if(k1.role ~= k2.role) then
				return k1.role > k2.role

			elseif(k1.spec ~= k2.spec) then
				return k1.spec > k2.spec

			else
				return k1.class > k2.class

			end

		end)
		
		for i = 1, groupLimit, 1 do
			local currentMemberFrame = memberPanel.memberFrames[i]

			if(currentMemberFrame) then
				currentMemberFrame:SetTexture(miog.SPECIALIZATIONS[orderedList[i].specID] and miog.SPECIALIZATIONS[orderedList[i].specID].squaredIcon)

				if(orderedList[i].class ~= "DUMMY") then
					currentMemberFrame.border:SetColorTexture(C_ClassColor.GetClassColor(orderedList[i].class):GetRGBA())

				else
					currentMemberFrame.border:SetColorTexture(0, 0, 0, 0)
				
				end

				if(orderedList[i].leader) then
					memberPanel.leaderCrown:SetPoint("CENTER", currentMemberFrame, "TOP")
					memberPanel.leaderCrown:Show()

					currentMemberFrame:SetMouseMotionEnabled(true)
					currentMemberFrame:SetScript("OnEnter", function()
						GameTooltip:SetOwner(currentMemberFrame, "ANCHOR_CURSOR")
						GameTooltip:AddLine(format(_G["LFG_LIST_TOOLTIP_LEADER"], searchResultData.leaderName))
						GameTooltip:Show()

					end)
					currentMemberFrame:SetScript("OnLeave", function()
						GameTooltip:Hide()

					end)
				else
					currentMemberFrame:SetScript("OnEnter", nil)
				
				end

			else
				memberPanel.memberFrames[i]:Hide()
			
			end
		end
		
		memberPanel:Show()

	end

	currentInvites[resultID] = currentFrame
	currentFrame:Show()

	--miog.ipDialog:SetPoint("TOPLEFT", dialogBox, "TOPLEFT")
	miog.ipDialog.container:MarkDirty()
	---@diagnostic disable-next-line: undefined-field
	miog.ipDialog:MarkDirty()
	miog.ipDialog:SetShown(true)
	--StaticPopupSpecial_Show(miog.ipDialog)
end

MIOG_IPD = miog.showUpgradedInvitePendingDialog

miog.createFrames = function()
	miog.createPVEFrameReplacement()
	createMainFrame()
	createApplicationViewer()
	createSearchPanel()
	createEntryCreation()
	createUpgradedInvitePendingDialog()

	miog.scriptReceiver:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")

	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_SEARCH_FAILED")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TIMEOUT")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS")
	miog.scriptReceiver:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

	miog.scriptReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")

	miog.scriptReceiver:RegisterEvent("PARTY_LEADER_CHANGED")
	miog.scriptReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
	miog.scriptReceiver:RegisterEvent("GROUP_JOINED")
	miog.scriptReceiver:RegisterEvent("GROUP_LEFT")
	miog.scriptReceiver:RegisterEvent("INSPECT_READY")
	miog.scriptReceiver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	miog.scriptReceiver:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
	miog.scriptReceiver:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")

	miog.scriptReceiver:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
	miog.scriptReceiver:RegisterEvent("LFG_UPDATE")
	miog.scriptReceiver:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	miog.scriptReceiver:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
	miog.scriptReceiver:RegisterEvent("BATTLEFIELDS_SHOW")

	EncounterJournal_LoadUI()
	C_EncounterJournal.OnOpen = miog.dummyFunction
	EJ_SelectInstance(1207)
end

miog.scriptReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
miog.scriptReceiver:RegisterEvent("PLAYER_LOGIN")
miog.scriptReceiver:RegisterEvent("UPDATE_LFG_LIST")
miog.scriptReceiver:SetScript("OnEvent", miog.OnEvent)