local addonName, miog = ...
local wticc = WrapTextInColorCode

local formatter = CreateFromMixins(SecondsFormatterMixin)
formatter:Init(3600, SecondsFormatter.Abbreviation.OneLetter)

local activityIndices = {
	Enum.WeeklyRewardChestThresholdType.Raid, -- raid
	Enum.WeeklyRewardChestThresholdType.Activities, -- m+
	Enum.WeeklyRewardChestThresholdType.World, -- world/delves
}

local function openSearchPanel(categoryID, filters, dontSearch)
	if(LFGListFrame.CategorySelection.selectedCategory ~= categoryID) then
		LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)

	end

	LFGListFrame.CategorySelection.selectedCategory = categoryID
	LFGListFrame.CategorySelection.selectedFilters = filters or 0

	LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryID, filters or 0, LFGListFrame.baseFilters)
	
	LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)

	if(not dontSearch) then
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)

	else
		miog.SearchPanel.Status:Hide()

	end
end

miog.openSearchPanel = openSearchPanel

local function createCategoryButtons(categoryID, type, rootDescription)
	local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)

	for i = 1, categoryInfo.separateRecommended and 2 or 1, 1 do
		local categoryButton = rootDescription:CreateButton(i == 1 and categoryInfo.name or LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, false), function()
			local filters = i == 2 and categoryInfo.separateRecommended and Enum.LFGListFilter.NotRecommended or categoryID == 1 and 4 or Enum.LFGListFilter.Recommended

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

		local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();

		categoryButton:SetTooltip(function(tooltip, elementDescription)
			if(not canUse) then
				GameTooltip_SetTitle(tooltip, failureReason);
			end
		end)

		categoryButton:SetEnabled(canUse)
	end
end

local function retrieveSpellInfo(flyoutSpellID)
	local desc = C_Spell.GetSpellDescription(flyoutSpellID)
	local mapID = miog.TELEPORT_SPELLS_TO_MAP[flyoutSpellID]

	local abbreviatedName

	if(mapID) then
		local mapInfo = miog.MAP_INFO[mapID]
		abbreviatedName = mapInfo.abbreviatedName

	else
		abbreviatedName = ""

	end

	return desc, abbreviatedName
end

local tpButtonPool

local function addTeleportButtons()
	tpButtonPool:ReleaseAll()
	
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
				local desc, abbreviatedName = retrieveSpellInfo(flyoutSpellID)

				if(desc == "") then
					local spell = Spell:CreateFromSpellID(flyoutSpellID)
					spell:ContinueOnSpellLoad(function()
						--desc, abbreviatedName = retrieveSpellInfo(flyoutSpellID)
						--expNameTable[#expNameTable+1] = {name = spellName, desc = desc, spellID = flyoutSpellID, type = info.type, known = spellKnown, abbreviatedName = abbreviatedName}

						addTeleportButtons()
					end)
				else
					expNameTable[#expNameTable+1] = {name = spellName, desc = desc, spellID = flyoutSpellID, type = info.type, known = spellKnown, abbreviatedName = abbreviatedName}


				end
			end

			table.sort(expNameTable, function(k1, k2)
				if(k1.type == "dungeon") then
					return k1.abbreviatedName < k2.abbreviatedName

				else
					return k1.spellID < k2.spellID

				end
			end)

			for k, v in ipairs(expNameTable) do
				local spellInfo = C_Spell.GetSpellInfo(v.spellID)
				local tpButton = tpButtonPool:Acquire()
				--local tpButton = CreateFrame("Button", nil, miog.Teleports, "MIOG_TeleportButtonTemplate")
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

					tpButton.Text:SetText(v.abbreviatedName or WrapTextInColorCode("MISSING", "FFFF0000"))

				end

				local spell = Spell:CreateFromSpellID(v.spellID)
				spell:ContinueOnSpellLoad(function()
					tpButton:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip_AddHighlightLine(GameTooltip, v.name)
						GameTooltip:AddLine(spell:GetSpellDescription())
						GameTooltip:Show()
					end)
					tpButton:Show()
				end)
			end
		end
	end
end

local function createPVEFrameReplacement()
	local pveFrame2 = CreateFrame("Frame", "MythicIOGrabber_PVEFrameReplacement", UIParent, "MIOG_MainFrameTemplate")

	if(MIOG_NewSettings.mainFrameSize) then
		pveFrame2:SetSize(MIOG_NewSettings.mainFrameSize.width, MIOG_NewSettings.mainFrameSize.height)

	else
		pveFrame2:SetSize(PVEFrame:GetWidth() + 20, PVEFrame:GetHeight())

	end

	if(MIOG_NewSettings.mainFrameScale) then
		pveFrame2.TitleBar.UISlider.SliderWithSteppers:SetValue(MIOG_NewSettings.mainFrameScale)

	end

	pveFrame2:SetResizeBounds(PVEFrame:GetWidth() + 20, PVEFrame:GetHeight(), PVEFrame:GetWidth() * 2, PVEFrame:GetHeight()* 2)

	if(pveFrame2:GetPoint() == nil) then
		pveFrame2:SetPoint(PVEFrame:GetPoint())
	end

	miog.pveFrame2 = pveFrame2
	miog.MainTab = pveFrame2.TabFramesPanel.MainTab
	miog.Teleports = pveFrame2.TabFramesPanel.Teleports
	
	LFGListFrame.SearchPanel.results = LFGListFrame.SearchPanel.results or {}
	LFGListFrame.SearchPanel.applications = LFGListFrame.SearchPanel.applications or {}

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

		miog.MainTab.QueueInformation.LastGroup.Text:SetText("Last group: " .. MIOG_CharacterSettings.lastGroup)

		miog.F.CURRENT_REGION = miog.F.CURRENT_REGION or miog.C.REGIONS[GetCurrentRegion()]

		local isMaxLevel = IsPlayerAtEffectiveMaxLevel()

		if(isMaxLevel) then
			miog.MainTab.Information.KeystoneStatusBar:SetMinMaxValues(0, 100)
			miog.MainTab.Information.KeystoneStatusBar:SetValue(100)
			local regularActivityID, _, regularLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(); --Prioritize regular keystones
			local activityInfo

			if(regularActivityID) then
				activityInfo = miog.requestActivityInfo(regularActivityID)
				miog.MainTab.Information.KeystoneStatusBar.Text:SetText("+" .. regularLevel .. " " .. activityInfo.mapName)
				miog.MainTab.Information.KeystoneStatusBar:SetStatusBarColor(miog.createCustomColorForRating(miog.KEYSTONE_LEVEL_BASE_VALUES[regularLevel + 3] * 8):GetRGBA())
			else
				local timewalkingActivityID, _, timewalkingLevel = C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel(true)  -- Check for a timewalking keystone.

				if(timewalkingActivityID) then
					activityInfo = miog.requestActivityInfo(timewalkingActivityID)
					miog.MainTab.Information.KeystoneStatusBar.Text:SetText("+" .. timewalkingLevel .. " " .. activityInfo.mapName)
					miog.MainTab.Information.KeystoneStatusBar:SetStatusBarColor(miog.createCustomColorForRating(miog.KEYSTONE_LEVEL_BASE_VALUES[timewalkingLevel] * 8):GetRGBA())
					
				else
					miog.MainTab.Information.KeystoneStatusBar.Text:SetText("No keystone found")
					miog.MainTab.Information.KeystoneStatusBar:SetStatusBarColor(0, 0, 0, 1)
				
				end
			end

			for k, v in ipairs(activityIndices) do
				local activities = C_WeeklyRewards.GetActivities(v)

				local currentFrame = miog.MainTab.Information["VaultProgress" .. k]
				--local currentFrame = k == 1 and miog.MainTab.Information.MPlusStatus or k == 2 and miog.MainTab.Information.RaidStatus or miog.MainTab.Information.WorldStatus
				currentFrame:SetInfo(activities)

				local farthestActivity = currentFrame:GetFarthestActivity(true)
				--currentFrame:SetMinMaxValues(0, farthestActivity.threshold)
				--currentFrame:SetValue(farthestActivity.progress)

				local numOfCompletedActivities = currentFrame:GetNumOfCompletedActivities()

				local currentColor = numOfCompletedActivities == 3 and miog.CLRSCC.green or numOfCompletedActivities == 2 and miog.CLRSCC.yellow or numOfCompletedActivities == 1 and miog.CLRSCC.orange or miog.CLRSCC.red
				local dimColor = {CreateColorFromHexString(currentColor):GetRGB()}
				dimColor[4] = 0.1
					
				--currentFrame:SetStatusBarColor(CreateColorFromHexString(currentColor):GetRGBA())
				--miog.createFrameWithBackgroundAndBorder(currentFrame, 1, unpack(dimColor))

				--currentFrame.Text:SetTextColor(CreateColorFromHexString(numOfCompletedActivities == 0 and currentColor or "FFFFFFFF"):GetRGBA())

				currentFrame.ThresholdBar:SetMinMaxValues(currentFrame.ThresholdBar:GetLeft(), currentFrame.ThresholdBar:GetRight())
				--currentFrame.GlowBarBlue:SetPoint("LEFT", currentFrame["Progress1"], "CENTER", 1, 1)
				currentFrame.ThresholdBar.LeftText:SetText(k == 1 and RAIDS or k == 2 and DUNGEONS or k == 3 and WORLD)

				local ilvls = currentFrame:GetAllItemlevels()

				currentFrame.ThresholdBar:SetValue(0)
				local currentValue = currentFrame["Progress1"]:GetLeft() - 4
				
				local all = farthestActivity.progress == farthestActivity.threshold
				
				for i = 1, farthestActivity.threshold, 1 do
					local progressFrameString = "Progress" .. i
					local singleFrame = currentFrame[progressFrameString]
					singleFrame:SetParent(currentFrame.ThresholdBar)
					singleFrame.progressFrameIndex = i

					local isCompleted = farthestActivity.progress >= i
					local activityIndex = activities[1].threshold == i and 1 or activities[2].threshold == i and 2 or activities[3].threshold == i and 3
					local activityCompleted = isCompleted and activityIndex

					local checkmark = singleFrame.Checkmark
					local text = singleFrame.Text

					if(activityCompleted) then
						local ilvl = tremove(ilvls, 1)
						text:SetText(ilvl and WrapTextInColorCode(ilvl, miog.gearing.getColorForItemlevel(ilvl)) or "")
						text:SetParent(currentFrame.ThresholdBar)
						text:Show()

						checkmark:SetParent(currentFrame.ThresholdBar)
						checkmark:Show()

					else
						text:Hide()
						checkmark:Hide()

					end

					singleFrame.Ring:SetShown(activityIndex)
					singleFrame.Diamond:SetShown(not activityIndex)
					singleFrame.Glow:SetShown(not activityIndex and isCompleted)

					if(isCompleted) then
						currentValue = currentValue + singleFrame:GetWidth() + 4
						currentFrame.ThresholdBar:SetValue(currentValue)
						singleFrame[activityIndex and "Ring" or "Diamond"]:SetDesaturated(false)

					else
						singleFrame[activityIndex and "Ring" or "Diamond"]:SetDesaturated(true)

					end
				end

				if(all) then
					currentFrame.ThresholdBar.BarFillGlow:Show()
					currentFrame.ThresholdBar.BarBorderGlow:Show()
					currentFrame.ThresholdBar.Checkmark:Show()
					currentFrame.ThresholdBar.End:Hide()

				elseif(activities[1].progress > 0) then
					currentFrame.ThresholdBar.End:ClearAllPoints()
					currentFrame.ThresholdBar.End:SetPoint("RIGHT", currentFrame["Progress" .. farthestActivity.progress], "RIGHT", 3, 0)
					currentFrame.ThresholdBar.End:Show()
				end
			end

		else
			for k, v in ipairs(activityIndices) do
				local currentFrame = miog.MainTab.Information["VaultProgress" .. k]
				currentFrame:Hide()

			end

			miog.MainTab.Information.KeystoneStatusBar:Hide()
		end
		

		local renownFactions = {
			{id = 2736}
		}

		for k, v in ipairs(renownFactions) do
			--local factionData = C_Reputation.GetFactionDataByID(v.id)
			local majorFactionData = C_MajorFactions.GetMajorFactionData(v.id)
			local currentFrame = miog.MainTab.Information["RenownBar" .. k]

			if(majorFactionData) then -- and majorFactionData.isUnlocked
				currentFrame.id = v.id
				local standing = ""

				if(majorFactionData.renownLevelThreshold) then
					standing = majorFactionData.renownReputationEarned .. "/" .. majorFactionData.renownLevelThreshold
				end

				currentFrame.ThresholdBar.LeftText:SetText("(" .. majorFactionData.renownLevel .. ") " .. majorFactionData.name)
				currentFrame.ThresholdBar.RightText:SetText(standing)
				currentFrame.ThresholdBar:SetMinMaxValues(0, majorFactionData.renownLevelThreshold)
				currentFrame.ThresholdBar:SetValue(majorFactionData.renownReputationEarned)
				currentFrame:Show()
				
			else
				currentFrame:Hide()

			end
		end
	end)

	miog.MainTab.QueueInformation.Requeue:SetScript("OnClick", function()
		local queueInfo = MIOG_CharacterSettings.lastUsedQueue

		if(queueInfo.type == "pve") then
			if(queueInfo.subtype == "multidng") then
				for k, v in pairs(queueInfo.id) do
					LFGEnabledList[v] = v

				end
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

			elseif(queueInfo.subtype == "plunderstorm") then
				local modeFrame = PlunderstormFrame.QueueSelect.QueueContainer[queueInfo.id == 0 and "Solo" or queueInfo.id == 1 and "Duo" or queueInfo.id == 2 and "Trio" or "Practice"]
						
				if(modeFrame) then
					modeFrame:Click()

				end
	
				C_LobbyMatchmakerInfo.EnterQueue(queueInfo.id or PlunderstormFrame.QueueSelect.useLocalPlayIndex);

			elseif(queueInfo.subtype == "pet") then
				C_PetBattles.StartPVPMatchmaking()

			else
				UIErrorsFrame:AddExternalErrorMessage("[MIOG]: Requeuing for pvp queues is not possible via the requeue button.\n\rPlease requeue using the dropdown menu.");

			end
		end
	end)
	miog.MainTab.QueueInformation.Requeue:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Queue up for the same activity you queued for the last time.")

		if(MIOG_CharacterSettings.lastUsedQueue) then
			if(MIOG_CharacterSettings.lastUsedQueue.type == "pve") then
				if(type(MIOG_CharacterSettings.lastUsedQueue.id) == "table") then
					GameTooltip:AddLine("Last activity: Multiple dungeons ")

					for k, v in pairs(MIOG_CharacterSettings.lastUsedQueue.id) do
						local name, _, _, _, _, _, _, _, _, _, _, difficulty = GetLFGDungeonInfo(v)
						GameTooltip:AddLine(name .. " - " .. GetDifficultyInfo(difficulty))

					end
				else
					GameTooltip:AddLine("Last activity: " .. GetLFGDungeonInfo(MIOG_CharacterSettings.lastUsedQueue.id))

				end

			elseif(MIOG_CharacterSettings.lastUsedQueue.type == "pvp") then
				local activity

				if(MIOG_CharacterSettings.lastUsedQueue.subtype == "plunderstorm") then
					local index = MIOG_CharacterSettings.lastUsedQueue.index
					local modeString = index == 0 and FRONT_END_LOBBY_SOLOS or index == 1 and FRONT_END_LOBBY_DUOS or index == 2 and FRONT_END_LOBBY_TRIOS or FRONT_END_LOBBY_PRACTICE

					activity = modeString

				elseif(MIOG_CharacterSettings.lastUsedQueue.subtype == "skirmish") then
					activity = SKIRMISH

				elseif(MIOG_CharacterSettings.lastUsedQueue.subtype == "brawl") then
					_, activity = C_PvP.GetActiveBrawlInfo()

				elseif(MIOG_CharacterSettings.lastUsedQueue.subtype == "brawlSpecial") then
					_, activity = C_PvP.GetSpecialEventBrawlInfo()

				elseif(MIOG_CharacterSettings.lastUsedQueue.subtype == "pet") then
					activity = PET_BATTLE_PVP_QUEUE

				else
					activity = MIOG_CharacterSettings.lastUsedQueue.alias or ""

				end

				GameTooltip:AddLine("Last activity: " .. activity)
			end
		end
		GameTooltip:Show()
	end)

	hooksecurefunc("PVEFrame_ToggleFrame", function()
		HideUIPanel(PVEFrame)

		if(miog.pveFrame2:IsVisible()) then
			HideUIPanel(miog.pveFrame2)

		else
			ShowUIPanel(miog.pveFrame2)
			
		end
	end)

	miog.Progress = pveFrame2.TabFramesPanel.Progress
	miog.Progress.NewSystem:OnLoad("all", MIOG_NewSettings)

    miog.MPlusStatistics = miog.Progress.MPlusStatistics
	miog.MPlusStatistics:OnLoad("mplus", MIOG_NewSettings)

	miog.RaidStatistics = miog.Progress.RaidStatistics
	miog.RaidStatistics:OnLoad("raid", MIOG_NewSettings)

	miog.PVPStatistics = miog.Progress.PVPStatistics
	miog.PVPStatistics:OnLoad("pvp", MIOG_NewSettings)

	local queueRolePanel = miog.MainTab.QueueInformation.RolePanel
	local leaderChecked, tankChecked, healerChecked, damagerChecked = LFDQueueFrame_GetRoles()

	queueRolePanel.Leader.Checkbox:SetChecked(leaderChecked)
	queueRolePanel.Leader.Icon:SetTexture("Interface/Addons/MythicIOGrabber/res/infoIcons/leaderIcon.png")

	local tankAvailable, healerAvailable, damagerAvailable = UnitGetAvailableRoles("player")

	queueRolePanel.Tank.Checkbox:SetChecked(tankChecked)
	queueRolePanel.Tank.Checkbox:SetEnabled(tankAvailable)
	queueRolePanel.Tank.Icon:SetTexture("Interface/Addons/MythicIOGrabber/res/infoIcons/tankIcon.png")
	queueRolePanel.Tank.Icon:SetDesaturated(not tankAvailable)

	queueRolePanel.Healer.Checkbox:SetChecked(healerChecked)
	queueRolePanel.Healer.Checkbox:SetEnabled(healerAvailable)
	queueRolePanel.Healer.Icon:SetTexture("Interface/Addons/MythicIOGrabber/res/infoIcons/healerIcon.png")
	queueRolePanel.Healer.Icon:SetDesaturated(not healerAvailable)

	queueRolePanel.Damager.Checkbox:SetChecked(damagerChecked)
	queueRolePanel.Damager.Checkbox:SetEnabled(damagerAvailable)
	queueRolePanel.Damager.Icon:SetTexture("Interface/Addons/MythicIOGrabber/res/infoIcons/damagerIcon.png")
	queueRolePanel.Damager.Icon:SetDesaturated(not damagerAvailable)

	tpButtonPool = CreateFramePool("Button", miog.Teleports, "MIOG_TeleportButtonTemplate", function(pool, button)
		button:Hide()
		button:ClearAllPoints()
		button.Text:SetText("")
		button:ClearNormalTexture()
		button:ClearHighlightTexture()
		button:SetScript("OnEnter", nil)
	end)

	addTeleportButtons()
	
	miog.pveFrame2.TitleBar.CreateGroupButton.Text:SetText("Create")
	miog.pveFrame2.TitleBar.CreateGroupButton:SetScript("OnClick", function(selfButton)
		local currentMenu = MenuUtil.CreateContextMenu(miog.pveFrame2.TitleBar.CreateGroupButton, function(ownerRegion, rootDescription)
	
			rootDescription:CreateTitle("Create Groups");

			for _, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
				createCategoryButtons(categoryID, "entry", rootDescription)

			end

			rootDescription:SetTag("MIOG_FINDGROUP")
		end)

		currentMenu:SetPoint("TOPLEFT", selfButton, "BOTTOMLEFT")
	end)

	miog.MainTab.QueueInformation.FakeDropdown:SetupMenu(miog.setupQueueDropdown)
	miog.MainTab.QueueInformation.FakeDropdown:SetDefaultText("Select an activity...")

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
end

miog.createPVEFrameReplacement = createPVEFrameReplacement