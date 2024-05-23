local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")



local function createPVEFrameReplacement()
	local pveFrame2 = CreateFrame("Frame", "MythicIOGrabber_PVEFrameReplacement", UIParent, "MIOG_MainFrameTemplate")
	pveFrame2:SetSize(PVEFrame:GetWidth(), PVEFrame:GetHeight())

	if(pveFrame2:GetPoint() == nil) then
		pveFrame2:SetPoint(PVEFrame:GetPoint())
	end

	miog.createFrameBorder(pveFrame2, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	
	pveFrame2:HookScript("OnShow", function(selfPVEFrame)
		if(IsInRaid()) then
			local raidKeystoneInfo = miog.openRaidLib.RequestKeystoneDataFromRaid()
			
		elseif(IsInGroup()) then
			local allKeystoneInfo = miog.openRaidLib.RequestKeystoneDataFromParty()

		end

		C_MythicPlus.RequestCurrentAffixes()
		C_MythicPlus.RequestMapInfo()

		miog.setUpMPlusStatistics()
		miog.gatherMPlusStatistics()

		miog.setupPVPStatistics()
		miog.gatherPVPStatistics()

		miog.setupRaidStatistics()
		miog.gatherRaidStatistics()

		miog.MainTab.CategoryPanel.LastGroup.Text:SetText("Last group: " .. MIOG_SavedSettings.lastGroup.value)
		
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

		if(miog.F.CURRENT_SEASON and miog.F.CURRENT_SEASON == 12) then
			local currentServerTime = C_DateAndTime.GetServerTimeLocal()
			local seasonData = miog.C.SEASON_AVAILABLE[miog.F.CURRENT_SEASON]

			if(currentServerTime >= seasonData.sinceEpoch + miog.C.REGION_DATE_DIFFERENCE[GetCurrentRegion()]) then
				miog.MainTab.Information.Awakened.Text:SetTextColor(1,1,1,1)

				if(currentServerTime >= seasonData.awakened.vaultDate1 and currentServerTime < seasonData.awakened.aberrusDate1) then
					miog.MainTab.Information.Awakened.Text:SetText("VAULT AWAKENED")

				elseif(currentServerTime >= seasonData.awakened.aberrusDate1 and currentServerTime < seasonData.awakened.amirdrassilDate1) then
					miog.MainTab.Information.Awakened.Text:SetText("ABERRUS AWAKENED")

				elseif(currentServerTime >= seasonData.awakened.amirdrassilDate1 and currentServerTime < seasonData.awakened.vaultDate2) then
					miog.MainTab.Information.Awakened.Text:SetText("AMIRDRASSIL AWAKENED")

				elseif(currentServerTime >= seasonData.awakened.vaultDate2 and currentServerTime < seasonData.awakened.aberrusDate2) then
					miog.MainTab.Information.Awakened.Text:SetText("VAULT AWAKENED")

				elseif(currentServerTime >= seasonData.awakened.aberrusDate2 and currentServerTime < seasonData.awakened.amirdrassilDate2) then
					miog.MainTab.Information.Awakened.Text:SetText("ABERRUS AWAKENED")

				elseif(currentServerTime >= seasonData.awakened.amirdrassilDate2 and currentServerTime < seasonData.awakened.fullRelease) then
					miog.MainTab.Information.Awakened.Text:SetText("AMIRDRASSIL AWAKENED")

				elseif(currentServerTime >= seasonData.awakened.fullRelease) then
					miog.MainTab.Information.Awakened.Text:SetText("ALL RAIDS AWAKENED")

				end

			else
				miog.MainTab.Information.Awakened.Text:SetTextColor(1,0,0,1)
				miog.MainTab.Information.Awakened.Text:SetText("NO RAID AWAKENED")
			
			end

		end

		local aspectInfo = C_CurrencyInfo.GetCurrencyInfo(2812)
		miog.MainTab.Information.Currency.Aspect.Text:SetText(aspectInfo.quantity .. " (" .. aspectInfo.totalEarned .. "/" .. aspectInfo.maxQuantity .. ")")
		miog.MainTab.Information.Currency.Aspect.Icon:SetTexture(aspectInfo.iconFileID)
		miog.MainTab.Information.Currency.Aspect.Icon:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetCurrencyByID(2812)
			GameTooltip:Show()
		end)

		local wyrmInfo = C_CurrencyInfo.GetCurrencyInfo(2809)
		miog.MainTab.Information.Currency.Wyrm.Text:SetText(wyrmInfo.quantity .. " (" .. wyrmInfo.totalEarned .. "/" .. wyrmInfo.maxQuantity .. ")")
		miog.MainTab.Information.Currency.Wyrm.Icon:SetTexture(wyrmInfo.iconFileID)
		miog.MainTab.Information.Currency.Wyrm.Icon:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetCurrencyByID(2809)
			GameTooltip:Show()
		end)

		local drakeInfo = C_CurrencyInfo.GetCurrencyInfo(2807)
		miog.MainTab.Information.Currency.Drake.Text:SetText(drakeInfo.quantity .. " (" .. drakeInfo.totalEarned .. "/" .. drakeInfo.maxQuantity .. ")")
		miog.MainTab.Information.Currency.Drake.Icon:SetTexture(drakeInfo.iconFileID)
		miog.MainTab.Information.Currency.Drake.Icon:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetCurrencyByID(2807)
			GameTooltip:Show()
		end)

		local whelplingInfo = C_CurrencyInfo.GetCurrencyInfo(2806)
		miog.MainTab.Information.Currency.Whelpling.Text:SetText(whelplingInfo.quantity .. " (" .. whelplingInfo.totalEarned .. "/" .. whelplingInfo.maxQuantity .. ")")
		miog.MainTab.Information.Currency.Whelpling.Icon:SetTexture(whelplingInfo.iconFileID)
		miog.MainTab.Information.Currency.Whelpling.Icon:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetCurrencyByID(2806)
			GameTooltip:Show()
		end)
		
		for frameIndex = 1, 3, 1 do
			local activities = C_WeeklyRewards.GetActivities(frameIndex)

			local firstThreshold = activities[1].progress >= activities[1].threshold
			local secondThreshold = activities[2].progress >= activities[2].threshold
			local thirdThreshold = activities[3].progress >= activities[3].threshold
			local currentColor = thirdThreshold and miog.CLRSCC.green or secondThreshold and miog.CLRSCC.yellow or firstThreshold and miog.CLRSCC.orange or miog.CLRSCC.red
			local dimColor = {CreateColorFromHexString(currentColor):GetRGB()}
			dimColor[4] = 0.1

			local currentFrame = frameIndex == 1 and miog.MainTab.Information.MPlusStatus or frameIndex == 2 and miog.MainTab.Information.HonorStatus or miog.MainTab.Information.RaidStatus

			currentFrame:SetMinMaxValues(0, activities[3].threshold)
			currentFrame.info = (thirdThreshold or secondThreshold) and activities[3] or firstThreshold and activities[2] or activities[1]
			currentFrame.activities = activities
			currentFrame.unlocked = currentFrame.info.progress >= currentFrame.info.threshold;

			local activities1Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[1].id))
			local activities2Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[2].id))
			local activities3Lvl = C_Item.GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activities[3].id))
			
			miog.VAULT_PROGRESS[frameIndex] = {activities1Lvl, activities2Lvl, activities3Lvl}

			currentFrame:SetStatusBarColor(CreateColorFromHexString(currentColor):GetRGBA())
			miog.createFrameWithBackgroundAndBorder(currentFrame, 1, unpack(dimColor))

			currentFrame:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);

				if self.info then
					local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.info.id);

					local itemLevel, upgradeItemLevel, previewLevel, sparse;
					if itemLink then
						itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
					end
					if upgradeItemLink then
						upgradeItemLevel, previewLevel, sparse = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);
					end

					local canShow = self:CanShowPreviewItemTooltip()
					
					GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);
					GameTooltip_AddBlankLineToTooltip(GameTooltip);
				
					local hasRewards = C_WeeklyRewards.HasAvailableRewards();

					if hasRewards then
						GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR);
						GameTooltip_AddBlankLineToTooltip(GameTooltip);
					end

					if self.info.type == Enum.WeeklyRewardChestThresholdType.Activities then
						if(canShow) then
							local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(self.info.activityTierID, self.info.level);
							if hasData then
								upgradeItemLevel = nextItemLevel;
							else
								nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(self.info.level);
							end
							
							self:HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel, nextLevel);

						else
							self:ShowIncompleteMythicTooltip();
							GameTooltip_AddBlankLineToTooltip(GameTooltip);

						end

						GameTooltip_AddNormalLine(GameTooltip, "Slot 1: " .. (activities1Lvl or "N/A"))

						GameTooltip_AddNormalLine(GameTooltip, "Slot 2: " .. (activities2Lvl or "N/A"))

						GameTooltip_AddNormalLine(GameTooltip, "Slot 3: " .. (activities3Lvl or "N/A"))

						GameTooltip_AddBlankLineToTooltip(GameTooltip);
						
						GameTooltip_AddNormalLine(GameTooltip, string.format("%s/%s rewards unlocked.", thirdThreshold and 3 or secondThreshold and 2 or firstThreshold and 1 or 0, 3))

					elseif self.info.type == Enum.WeeklyRewardChestThresholdType.Raid then
						if(canShow) then
							--self:HandlePreviewRaidRewardTooltip(itemLevel, upgradeItemLevel);
						end

						local currentDifficultyID = self.info.level;

						if(itemLevel) then
							local currentDifficultyName = DifficultyUtil.GetDifficultyName(currentDifficultyID);
							GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, itemLevel, currentDifficultyName));
							GameTooltip_AddBlankLineToTooltip(GameTooltip);
						end
						
						if upgradeItemLevel then
							local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(currentDifficultyID);
							local difficultyName = DifficultyUtil.GetDifficultyName(nextDifficultyID);
							GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
							GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_RAID, difficultyName));
						end
			
						local encounters = C_WeeklyRewards.GetActivityEncounterInfo(self.info.type, self.info.index);
						if encounters then
							table.sort(encounters, function(left, right)
								if left.instanceID ~= right.instanceID then
									return left.instanceID < right.instanceID;
								end
								local leftCompleted = left.bestDifficulty > 0;
								local rightCompleted = right.bestDifficulty > 0;
								if leftCompleted ~= rightCompleted then
									return leftCompleted;
								end
								return left.uiOrder < right.uiOrder;
							end)
							local lastInstanceID = nil;
							for index, encounter in ipairs(encounters) do
								local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounter.encounterID);
								if instanceID ~= lastInstanceID then
									local instanceName = EJ_GetInstanceInfo(instanceID);
									GameTooltip_AddBlankLineToTooltip(GameTooltip);	
									GameTooltip_AddHighlightLine(GameTooltip, instanceName);
									lastInstanceID = instanceID;
								end
								if name then
									if encounter.bestDifficulty > 0 then
										local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty);
										GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETED_ENCOUNTER, name, completedDifficultyName), miog.DIFFICULTY_ID_TO_COLOR[encounter.bestDifficulty]);
									else
										GameTooltip_AddColoredLine(GameTooltip, string.format(DASH_WITH_TEXT, name), DISABLED_FONT_COLOR);
									end
								end
							end
						end
						
						GameTooltip_AddBlankLineToTooltip(GameTooltip);

						GameTooltip_AddNormalLine(GameTooltip, "Slot 1: " .. (activities1Lvl or "N/A"))

						GameTooltip_AddNormalLine(GameTooltip, "Slot 2: " .. (activities2Lvl or "N/A"))
						
						GameTooltip_AddNormalLine(GameTooltip, "Slot 3: " .. (activities3Lvl or "N/A"))

						GameTooltip_AddBlankLineToTooltip(GameTooltip);
						GameTooltip_AddNormalLine(GameTooltip, string.format("%s/%s rewards unlocked.", thirdThreshold and 3 or secondThreshold and 2 or firstThreshold and 1 or 0, 3))

					elseif self.info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
						if not ConquestFrame_HasActiveSeason() then
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
							GameTooltip_AddDisabledLine(GameTooltip, UNAVAILABLE);
							GameTooltip_AddNormalLine(GameTooltip, CONQUEST_REQUIRES_PVP_SEASON);
							GameTooltip:Show();
							return;
						end
					
						local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress();
						local unlocksCompleted = weeklyProgress.unlocksCompleted or 0;

						GameTooltip_AddNormalLine(GameTooltip, "Honor earned: " .. weeklyProgress.progress .. "/" .. weeklyProgress.maxProgress);
						GameTooltip_AddBlankLineToTooltip(GameTooltip);
					
						local maxUnlocks = weeklyProgress.maxUnlocks or 3;
						local description;
						if unlocksCompleted > 0 then
							description = RATED_PVP_WEEKLY_VAULT_TOOLTIP:format(unlocksCompleted, maxUnlocks);

						else
							description = RATED_PVP_WEEKLY_VAULT_TOOLTIP_NO_REWARDS:format(unlocksCompleted, maxUnlocks);

						end

						GameTooltip_AddNormalLine(GameTooltip, description);
					
						--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
						--GameTooltip:Show();
					end

					GameTooltip_AddBlankLineToTooltip(GameTooltip);
					GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);

					GameTooltip:Show()

				end
			end)

			currentFrame:SetValue(activities[3].progress)

			currentFrame.Text:SetText((activities[3].progress <= activities[3].threshold and activities[3].progress or activities[3].threshold) .. "/" .. activities[3].threshold .. " " .. (frameIndex == 1 and "Dungeons" or frameIndex == 2 and "Honor" or frameIndex == 3 and "Bosses" or ""))
			currentFrame.Text:SetTextColor(CreateColorFromHexString(not firstThreshold and currentColor or "FFFFFFFF"):GetRGBA())
		end

		miog.insertGearingData()
	end)

	hooksecurefunc("PVEFrame_ToggleFrame", function()
		HideUIPanel(PVEFrame)

		if(miog.pveFrame2:IsVisible()) then
			HideUIPanel(miog.pveFrame2)

		else
			ShowUIPanel(miog.pveFrame2)
			
			C_Calendar.CloseEvent();

			local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
			C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year);

			C_Calendar.OpenCalendar();
		
		end
	end)

	miog.pveFrame2 = pveFrame2
	miog.MainTab = pveFrame2.TabFramesPanel.MainTab
	miog.Teleports = pveFrame2.TabFramesPanel.Teleports
	--miog.pveFrame2.TitleBar.Expand:SetParent(miog.Plugin)

	miog.MPlusStatistics = pveFrame2.TabFramesPanel.MPlusStatistics
	miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:OnLoad()
	miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:SetListAnchorToTopleft()
	miog.MPlusStatistics.ScrollFrame.Rows.accountChars = {}
	miog.MPlusStatistics.DungeonColumns.Dungeons = {}

	miog.MPlusStatistics:HookScript("OnShow", function()
		miog.MPlusStatistics.CharacterInfo.KeystoneDropdown:SetText("Party keystones")
		miog.refreshKeystones()
	end)

	miog.PVPStatistics = pveFrame2.TabFramesPanel.PVPStatistics
	miog.PVPStatistics.BracketColumns.Brackets = {}
	miog.PVPStatistics.ScrollFrame.Rows.accountChars = {}

	miog.RaidStatistics = pveFrame2.TabFramesPanel.RaidStatistics
	miog.RaidStatistics.RaidColumns.Raids = {}
	miog.RaidStatistics.ScrollFrame.Rows.accountChars = {}

	pveFrame2.TitleBar.Expand:SetScript("OnClick", function()

		MIOG_SavedSettings.frameExtended.value = not MIOG_SavedSettings.frameExtended.value

		if(MIOG_SavedSettings.frameExtended.value == true) then
			miog.Plugin:SetHeight(miog.Plugin.extendedHeight)

		elseif(MIOG_SavedSettings.frameExtended.value == false) then
			miog.Plugin:SetHeight(miog.Plugin.standardHeight)

		end
	end)

	pveFrame2.TitleBar.RaiderIOLoaded:SetText(WrapTextInColorCode("NO R.IO", miog.CLRSCC["red"]))
	pveFrame2.TitleBar.RaiderIOLoaded:SetShown(not miog.F.IS_RAIDERIO_LOADED)

---@diagnostic disable-next-line: undefined-field
	local queueRolePanel = miog.MainTab.QueueInformation.RolePanel
	--queueRolePanel:SetPoint("BOTTOM", frame.QueueDropdown, "TOP", 0, 5)

	local leader, tank, healer, damager = LFDQueueFrame_GetRoles()

	local function setRoles()
		SetLFGRoles(queueRolePanel.Leader.Checkbox:GetChecked(), queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(queueRolePanel.Tank.Checkbox:GetChecked(), queueRolePanel.Healer.Checkbox:GetChecked(), queueRolePanel.Damager.Checkbox:GetChecked())

	end

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

	PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")

---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueInformation.DropDown
	queueDropDown:OnLoad()
	queueDropDown:SetText("Choose a queue")
	miog.MainTab.QueueInformation.Panel:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	
	local counter = 0

	local offset = 35 + 22
	local _, _, _, tabSlots = GetSpellTabInfo(1)

	local formatter = CreateFromMixins(SecondsFormatterMixin)
	formatter:Init(3600, SecondsFormatter.Abbreviation.OneLetter)

	for i = 1, tabSlots, 1 do
		local spellType, id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)

		if(spellType == "FLYOUT") then
			local name, description, numSlots, isKnown = GetFlyoutInfo(id)

			if(string.find(name, "Hero's Path")) then
				local index
				local expName

				for x, y in ipairs(miog.EXPANSION_INFO) do
					if(y[1] == (string.sub(name, 14))) then
						index = x
						expName = string.sub(name, 14)
					end
				end

				local string = miog.Teleports:CreateFontString(nil, "OVERLAY", "GameTooltipText")
				string:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")
				string:SetPoint("TOPLEFT", miog.Teleports, "TOPLEFT", 0, (index - 4) * -offset)
				string:SetText(expName)

				for k = 1, numSlots, 1 do
					local flyoutSpellID, overrideSpellID, spellKnown, spellName, slotSpecID = GetFlyoutSlotInfo(id, k)

					local spellInfo = C_SpellBook.GetSpellInfo(flyoutSpellID)
					local tpButton = CreateFrame("Button", nil, miog.Teleports, "SecureActionButtonTemplate")
					tpButton:SetFrameStrata("MEDIUM")
					tpButton:SetSize(35, 35)
					tpButton:SetNormalTexture(spellInfo.iconID)
					tpButton:GetNormalTexture():SetDesaturated(not spellKnown)
					tpButton:SetPoint("TOPLEFT", miog.Teleports, "TOPLEFT", (k-1) * 37, -13 + (index - 4) * -offset)

					if(spellKnown) then
						local myCooldown = CreateFrame("Cooldown", nil, miog.Teleports, "CooldownFrameTemplate")
						myCooldown:SetFrameStrata("HIGH")
						myCooldown:SetPoint("TOPLEFT", tpButton, "TOPLEFT")
						myCooldown:SetPoint("BOTTOMRIGHT", tpButton, "BOTTOMRIGHT")
						
						tpButton:HookScript("OnShow", function()
							local start, duration, _, modrate = GetSpellCooldown(flyoutSpellID)
							myCooldown:SetCooldown(start, duration, modrate)

							local secondsLeft = duration - (GetTime() - start)
							local text = secondsLeft > 0 and WrapTextInColorCode("Remaining CD: " .. formatter:Format(secondsLeft), miog.CLRSCC.red) or WrapTextInColorCode("Ready", miog.CLRSCC.green)

							miog.Teleports.Remaining:SetText(text)
						end)

						tpButton:SetHighlightAtlas("communities-create-avatar-border-hover")
						tpButton:SetAttribute("type", "spell")
						tpButton:SetAttribute("spell", spellInfo.name)
						tpButton:RegisterForClicks("LeftButtonDown")
					end

					local spell = Spell:CreateFromSpellID(flyoutSpellID)
					spell:ContinueOnSpellLoad(function()
						tpButton:SetScript("OnEnter", function(self)
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
							GameTooltip_AddHighlightLine(GameTooltip, spellName)
							GameTooltip:AddLine(spell:GetSpellDescription())
							GameTooltip:Show()
						end)
					end)

					tpButton:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)
				end

				counter = counter + 1
			end
		end
	end
end

miog.createPVEFrameReplacement = createPVEFrameReplacement

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_EventReceiver")

eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
eventReceiver:RegisterEvent("PLAYER_LOGIN")
eventReceiver:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
eventReceiver:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
eventReceiver:RegisterEvent("PLAYER_REGEN_DISABLED")
eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")

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
