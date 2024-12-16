local addonName, miog = ...
local wticc = WrapTextInColorCode

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_EventReceiver")

miog.openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

local function openSearchPanel(categoryID, filters, dontSearch)
	--LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)

	LFGListFrame.CategorySelection.selectedCategory = categoryID
	LFGListFrame.CategorySelection.selectedFilters = filters or 0

	LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryID, filters or 0, LFGListFrame.baseFilters)

	if(not dontSearch) then
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)

	else
		miog.SearchPanel.Status:Hide()

	end
	
	LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
end

miog.openSearchPanel = openSearchPanel

local function createCategoryButtons(categoryID, type, rootDescription)
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)

	for i = 1, categoryInfo.separateRecommended and 2 or 1, 1 do
		local categoryButton = rootDescription:CreateButton(i == 1 and categoryInfo.name or LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, true), function()
			local filters = i == 2 and categoryInfo.separateRecommended and Enum.LFGListFilter.NotRecommended or categoryID == 1 and 4 or Enum.LFGListFilter.Recommended

			--categoryFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], nil, "CLAMPTOBLACKADDITIVE")

			if(type == "search") then
				openSearchPanel(categoryID, filters)

			else
				LFGListFrame.CategorySelection.selectedCategory = categoryID
				LFGListFrame.CategorySelection.selectedFilters = filters

				LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryID, filters, LFGListFrame.baseFilters)

				LFGListCategorySelectionStartGroupButton_OnClick(LFGListFrame.EntryCreation)
				
				LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.EntryCreation);

				miog.initializeActivityDropdown(filters)
			end
		
			PanelTemplates_SetTab(miog.pveFrame2, 1)
	
			if(miog.pveFrame2.selectedTabFrame) then
				miog.pveFrame2.selectedTabFrame:Hide()
			end
	
			miog.pveFrame2.TabFramesPanel.MainTab:Show()
			miog.pveFrame2.selectedTabFrame = miog.pveFrame2.TabFramesPanel.MainTab
		end)

		categoryButton:SetTooltip(function(tooltip, elementDescription)
			local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();
			if(not canUse) then
				GameTooltip_SetTitle(tooltip, failureReason);
			end
		end)
	end
end

local function setRoles()
	local queueRolePanel = miog.MainTab.QueueInformation.RolePanel
	
	SetLFGRoles(queueRolePanel.Leader.Checkbox:GetChecked(), queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
	SetPVPRoles(queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())

end

local activityIndices = {
	Enum.WeeklyRewardChestThresholdType.Activities, -- m+
	Enum.WeeklyRewardChestThresholdType.Raid, -- raid
	Enum.WeeklyRewardChestThresholdType.World, -- world/delves
}

local function createPVEFrameReplacement()
	local pveFrame2 = CreateFrame("Frame", "MythicIOGrabber_PVEFrameReplacement", UIParent, "MIOG_MainFrameTemplate")
	pveFrame2:SetSize(PVEFrame:GetWidth(), PVEFrame:GetHeight())

	miog.pveFrame2 = pveFrame2
	miog.MainTab = pveFrame2.TabFramesPanel.MainTab
	miog.Teleports = pveFrame2.TabFramesPanel.Teleports
	
	LFGListFrame.SearchPanel.results = LFGListFrame.SearchPanel.results or {}
	LFGListFrame.SearchPanel.applications = LFGListFrame.SearchPanel.applications or {}

	if(pveFrame2:GetPoint() == nil) then
		pveFrame2:SetPoint(PVEFrame:GetPoint())
	end

	miog.createFrameBorder(pveFrame2, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local setup = false
	
	pveFrame2:HookScript("OnShow", function(selfPVEFrame)
		C_MythicPlus.RequestMapInfo()
		C_MythicPlus.RequestCurrentAffixes()

		if(not setup) then
			miog.updateCurrencies()

			setup = true
		end
		
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year);

		C_Calendar.OpenCalendar();

		--miog.updateProgressData()

		miog.MainTab.QueueInformation.LastGroup.Text:SetText("Last group: " .. MIOG_NewSettings.lastGroup)
		
		if(miog.F.CURRENT_SEASON == nil or miog.F.PREVIOUS_SEASON == nil) then
			local currentSeason = C_MythicPlus.GetCurrentSeason()

			miog.F.CURRENT_SEASON = currentSeason
			miog.F.PREVIOUS_SEASON = currentSeason - 1
		end

		miog.F.CURRENT_REGION = miog.F.CURRENT_REGION or miog.C.REGIONS[GetCurrentRegion()]

		local regularActivityID, regularGroupID, regularLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones

		if(regularActivityID) then
			miog.MainTab.Information.Keystone.Text:SetText("+" .. regularLevel .. " " .. C_LFGList.GetActivityGroupInfo(regularGroupID))
			miog.MainTab.Information.Keystone.Text:SetTextColor(miog.createCustomColorForRating(regularLevel * 130):GetRGBA())
			
		else
			local timewalkingActivityID, timewalkingGroupID, timewalkingLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true)  -- Check for a timewalking keystone.

			if(timewalkingActivityID) then
				miog.MainTab.Information.Keystone.Text:SetText("+" .. timewalkingLevel .. " " .. C_LFGList.GetActivityGroupInfo(timewalkingGroupID))
				miog.MainTab.Information.Keystone.Text:SetTextColor(miog.createCustomColorForRating(timewalkingLevel * 130):GetRGBA())
				
			else
				miog.MainTab.Information.Keystone.Text:SetText("NO KEYSTONE")
				miog.MainTab.Information.Keystone.Text:SetTextColor(1, 0, 0, 1)
			
			end
		end

		for k, v in ipairs(activityIndices) do
			local activities = C_WeeklyRewards.GetActivities(v)

			local currentFrame = k == 1 and miog.MainTab.Information.MPlusStatus or k == 2 and miog.MainTab.Information.RaidStatus or miog.MainTab.Information.WorldStatus

			currentFrame:SetInfo(activities)

			local farthestActivity = currentFrame:GetFarthestActivity(true)
			currentFrame:SetMinMaxValues(0, farthestActivity.threshold)
			currentFrame:SetValue(farthestActivity.progress)

			local numOfCompletedActivities = currentFrame:GetNumOfCompletedActivities()

			local currentColor = numOfCompletedActivities == 3 and miog.CLRSCC.green or numOfCompletedActivities == 2 and miog.CLRSCC.yellow or numOfCompletedActivities == 1 and miog.CLRSCC.orange or miog.CLRSCC.red
			local dimColor = {CreateColorFromHexString(currentColor):GetRGB()}
			dimColor[4] = 0.1
				
			currentFrame:SetStatusBarColor(CreateColorFromHexString(currentColor):GetRGBA())
			miog.createFrameWithBackgroundAndBorder(currentFrame, 1, unpack(dimColor))

			currentFrame.Text:SetText((activities[3].progress <= activities[3].threshold and activities[3].progress or activities[3].threshold) .. "/" .. activities[3].threshold .. " " .. (k == 1 and "Dungeons" or k == 2 and "Bosses" or k == 3 and "World" or ""))
			currentFrame.Text:SetTextColor(CreateColorFromHexString(numOfCompletedActivities == 0 and currentColor or "FFFFFFFF"):GetRGBA())

		end
		
		--HonorFrame.TypeDropdown:ClearAllPoints()
		--HonorFrame.TypeDropdown:SetAllPoints(pveFrame2.TabFramesPanel.MainTab.QueueInformation.BonusSpecificPoint)
		--HonorFrame.TypeDropdown:SetParent(pveFrame2)
	end)

	miog.MainTab.QueueInformation.Requeue:SetScript("OnClick", function()
		local queueInfo = MIOG_NewSettings.lastUsedQueue

		if(queueInfo.type == "pve") then
			if(queueInfo.subtype == "multidng") then
				LFG_JoinDungeon(1, "specific", queueInfo.id, {})
				
			else
				ClearAllLFGDungeons(queueInfo.subtype == "dng" and 1 or 3);
				SetLFGDungeon(queueInfo.subtype == "dng" and 1 or 3, queueInfo.id);
				JoinSingleLFG(queueInfo.subtype == "dng" and 1 or 3, queueInfo.id);

			end

		elseif(queueInfo.type == "pvp") then
			if(queueInfo.subtype == "skirmish") then
				JoinSkirmish(4)
				
			elseif(queueInfo.subtype == "brawl") then
				C_PvP.JoinBrawl()

			elseif(queueInfo.subtype == "brawlSpecial") then
				C_PvP.JoinBrawl(true)

			elseif(queueInfo.subtype == "pet") then
				C_PetBattles.StartPVPMatchmaking()

			end
		end
	end)

	hooksecurefunc("PVEFrame_ToggleFrame", function()
		HideUIPanel(PVEFrame)

		if(miog.pveFrame2:IsVisible()) then
			HideUIPanel(miog.pveFrame2)

		else
			ShowUIPanel(miog.pveFrame2)
			
		end
	end)
	--miog.pveFrame2.TitleBar.Expand:SetParent(miog.Plugin)

	if(miog.F.IS_RAIDERIO_LOADED) then
		miog.pveFrame2.TitleBar.RaiderIOLoaded:Hide()
	end

	miog.Statistics = pveFrame2.TabFramesPanel.Statistics
    miog.MPlusStatistics = miog.Statistics.MPlusStatistics
	miog.MPlusStatistics:OnLoad(1)

	miog.RaidStatistics = miog.Statistics.RaidStatistics
	miog.RaidStatistics:OnLoad(2)

	miog.PVPStatistics = miog.Statistics.PVPStatistics
	miog.PVPStatistics:OnLoad(3)

	local r,g,b = CreateColorFromHexString(miog.CLRSCC.black):GetRGB()

	for i = 1, 6, 1 do
		local currentFrame = miog.MainTab.Information.Currency[tostring(i)]

		miog.createFrameBorder(currentFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		currentFrame:SetBackdropColor(r, g, b, 0.8)

	end

	pveFrame2.TitleBar.RaiderIOLoaded:SetText(WrapTextInColorCode("NO R.IO", miog.CLRSCC["red"]))
	pveFrame2.TitleBar.RaiderIOLoaded:SetShown(not miog.F.IS_RAIDERIO_LOADED)

	local queueRolePanel = miog.MainTab.QueueInformation.RolePanel
	local leader, tank, healer, damager = LFDQueueFrame_GetRoles()

	queueRolePanel.Leader.Checkbox:SetChecked(leader)
	queueRolePanel.Leader.Checkbox:SetScript("OnClick", function(self)
		setRoles()
	end)

	queueRolePanel.Tank.Checkbox:SetChecked(tank)
	queueRolePanel.Tank.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["TANK"])
	queueRolePanel.Tank.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["TANK"])
	queueRolePanel.Tank.Checkbox:SetScript("OnClick", function(self)
		setRoles()
	end)

	queueRolePanel.Healer.Checkbox:SetChecked(healer)
	queueRolePanel.Healer.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["HEALER"])
	queueRolePanel.Healer.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["HEALER"])
	queueRolePanel.Healer.Checkbox:SetScript("OnClick", function(self)
		setRoles()
	end)

	queueRolePanel.Damager.Checkbox:SetChecked(damager)
	queueRolePanel.Damager.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["DAMAGER"])
	queueRolePanel.Damager.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["DAMAGER"])
	queueRolePanel.Damager.Checkbox:SetScript("OnClick", function(self)
		setRoles()
	end)
	
	setRoles()

	local queueDropDown = miog.MainTab.QueueInformation.DropDown
	queueDropDown:OnLoad()
	queueDropDown:SetText("Select an activity")
	miog.MainTab.QueueInformation.Panel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	local formatter = CreateFromMixins(SecondsFormatterMixin)
	formatter:Init(3600, SecondsFormatter.Abbreviation.OneLetter)

	local function addTeleportButtons()
		local lastExpansionFrames = {}

		for index, info in ipairs(miog.TELEPORT_FLYOUT_IDS) do
			local name, description, numSlots, isKnown = GetFlyoutInfo(info.id)

			local expansionInfo = GetExpansionDisplayInfo(info.expansion)

			local logoFrame = miog.Teleports[tostring(info.expansion)]

			if(logoFrame and expansionInfo) then
				logoFrame.Texture:SetTexture(expansionInfo.logo)

				local expNameTable = {}

				for k = 1, numSlots, 1 do
					local flyoutSpellID, _, spellKnown, spellName, _ = GetFlyoutSlotInfo(info.id, k)
					local desc = C_Spell.GetSpellDescription(flyoutSpellID)
					local tableIndex = #expNameTable + 1

					expNameTable[tableIndex] = {name = spellName, desc = desc, spellID = flyoutSpellID, known = spellKnown}

					if(desc == "") then
						local spell = Spell:CreateFromSpellID(flyoutSpellID)
						spell:ContinueOnSpellLoad(function()
							addTeleportButtons()

						end)

						return false

					end
				end

				table.sort(expNameTable, function(k1, k2)
					return k1.desc < k2.desc
				end)

				for k, v in ipairs(expNameTable) do
					local spellInfo = C_Spell.GetSpellInfo(v.spellID)
					local tpButton = CreateFrame("Button", nil, miog.Teleports, "MIOG_TeleportButtonTemplate")
					tpButton:SetNormalTexture(spellInfo.iconID)
					tpButton:GetNormalTexture():SetDesaturated(not v.known)
					tpButton:SetPoint("LEFT", lastExpansionFrames[info.expansion] or logoFrame, "RIGHT", lastExpansionFrames[info.expansion] and k == 1 and 18 or 3, 0)

					lastExpansionFrames[info.expansion] = tpButton

					if(v.known) then
						local myCooldown = tpButton.Cooldown
						
						tpButton:HookScript("OnShow", function()
							
							local spellCooldownInfo = C_Spell.GetSpellCooldown(v.spellID)
							--local start, duration, _, modrate = GetSpellCooldown(v.spellID)
							myCooldown:SetCooldown(spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.modRate)

							local secondsLeft = spellCooldownInfo.duration - (GetTime() - spellCooldownInfo.startTime)
							local text = secondsLeft > 0 and WrapTextInColorCode("Remaining CD: " .. formatter:Format(secondsLeft), miog.CLRSCC.red) or WrapTextInColorCode("Ready", miog.CLRSCC.green)

							miog.Teleports.Remaining:SetText(text)
						end)

						tpButton:SetHighlightAtlas("communities-create-avatar-border-hover")
						tpButton:SetAttribute("type", "spell")
						tpButton:SetAttribute("spell", spellInfo.name)
						tpButton:RegisterForClicks("LeftButtonDown")
					end

					local spell = Spell:CreateFromSpellID(v.spellID)
					spell:ContinueOnSpellLoad(function()
						tpButton:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
							GameTooltip_AddHighlightLine(GameTooltip, v.name)
							GameTooltip:AddLine(spell:GetSpellDescription())
							GameTooltip:Show()
						end)
					end)

					tpButton:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)
				end
			end
		end
	end

	addTeleportButtons()
	
	miog.pveFrame2.TitleBar.CreateGroupButton.Text:SetText("Create")
	miog.pveFrame2.TitleBar.CreateGroupButton:SetScript("OnClick", function(selfButton)
		local currentMenu = MenuUtil.CreateContextMenu(miog.pveFrame2.TitleBar.CreateGroupButton, function(ownerRegion, rootDescription)
	
			rootDescription:CreateTitle("Create Groups");

			for _, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
				createCategoryButtons(categoryID, "entry", rootDescription)

			end

			--[[local dd = rootDescription:CreateTemplate("WowStyle1DropdownTemplate")
			dd:AddInitializer(function(frame, description, menu)
				frame:SetDefaultText("My Dropdown");
				frame:SetupMenu(function(dropdown, rootDescription)
					rootDescription:CreateButton("TEST", function(index)
						
			
					end)
					rootDescription:CreateButton("TEST2", function(index)
						
			
					end)
				end)
			
	
			end)]]

			rootDescription:SetTag("MIOG_FINDGROUP")
		end)

		currentMenu:SetPoint("TOPLEFT", selfButton, "BOTTOMLEFT")
	end)

	miog.MainTab.QueueInformation.ActivityDropdown:SetDefaultText("Select an activity...")
	miog.MainTab.QueueInformation.ActivityDropdown:SetupMenu(function(dropdown, rootDescription)
		--miog.setupQueueDropdown(rootDescription)

	end)
	miog.updateDropDown()

	miog.pveFrame2.TitleBar.FindGroupButton.Text:SetText("Find")
	miog.pveFrame2.TitleBar.FindGroupButton:SetScript("OnClick", function(selfButton)
		local currentMenu = MenuUtil.CreateContextMenu(miog.pveFrame2.TitleBar.FindGroupButton, function(ownerRegion, rootDescription)
	
			rootDescription:CreateTitle("Find Groups");
			
			local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();

			for _, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
				createCategoryButtons(categoryID, "search", rootDescription, canUse)

			end
			rootDescription:SetTag("MIOG_FINDGROUP")
		end)

		currentMenu:SetPoint("TOPLEFT", selfButton, "BOTTOMLEFT")
	end)

	local function setCustomActivePanel(name)
		miog.setActivePanel(nil, name)

		PanelTemplates_SetTab(miog.pveFrame2, 1)

		if(miog.pveFrame2.selectedTabFrame) then
			miog.pveFrame2.selectedTabFrame:Hide()
		end

		miog.pveFrame2.TabFramesPanel.MainTab:Show()
		miog.pveFrame2.selectedTabFrame = miog.pveFrame2.TabFramesPanel.MainTab
	end

	miog.pveFrame2.TitleBar.MoreButton.Text:SetText("More")
	miog.pveFrame2.TitleBar.MoreButton:SetScript("OnClick", function(self)
		local currentMenu = MenuUtil.CreateContextMenu(miog.pveFrame2.TitleBar.MoreButton, function(ownerRegion, rootDescription)
			rootDescription:CreateTitle("More");
			rootDescription:CreateButton("Adventure Journal", function() setCustomActivePanel("AdventureJournal") end)
			rootDescription:CreateButton("DropChecker", function() setCustomActivePanel("DropChecker") end)
			--rootDescription:CreateButton("RaiderIOChecker", function() setCustomActivePanel("RaiderIOChecker") end)
			rootDescription:SetTag("MIOG_MORE")
		end)

		currentMenu:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	end)
end

miog.createPVEFrameReplacement = createPVEFrameReplacement

eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
eventReceiver:RegisterEvent("PLAYER_LOGIN")
eventReceiver:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
eventReceiver:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
eventReceiver:RegisterEvent("PLAYER_REGEN_DISABLED")
eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")
eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
eventReceiver:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
eventReceiver:RegisterEvent("ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED")

eventReceiver:RegisterEvent("CHALLENGE_MODE_START")
eventReceiver:RegisterEvent("CHALLENGE_MODE_RESET")
eventReceiver:RegisterEvent("CHALLENGE_MODE_COMPLETED")

eventReceiver:RegisterEvent("WEEKLY_REWARDS_UPDATE")
--eventReceiver:RegisterEvent("Menu.OpenMenuTag")



eventReceiver:SetScript("OnEvent", miog.OnEvent)

--[[

scriptReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
scriptReceiver:RegisterEvent("GROUP_JOINED")
scriptReceiver:RegisterEvent("GROUP_LEFT")
scriptReceiver:RegisterEvent("INSPECT_READY")
scriptReceiver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")


scriptReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
scriptReceiver:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
scriptReceiver:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
scriptReceiver:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
scriptReceiver:RegisterEvent("BATTLEFIELDS_SHOW")
scriptReceiver:RegisterEvent("LFG_UPDATE")
scriptReceiver:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
scriptReceiver:RegisterEvent("LFG_LOCK_INFO_RECEIVED")

]]
