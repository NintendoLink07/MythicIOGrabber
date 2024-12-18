local addonName, miog = ...
local wticc = WrapTextInColorCode

local disabledPopups = {}
local filterPopupID = nil
local numOfActiveApps = 0
local queueIndex = 1

local filterPopup
local showFilterPopup

local queuedList = {};

local queueSystem = {}
--queueSystem.queueFrames = {}
queueSystem.currentlyInUse = 0

local queueFrameIndex = 1
local randomBGFrame, randomEpicBGFrame, skirmish, brawl1, brawl2, specificBox
--local stayActive = false

local formatter = CreateFromMixins(SecondsFormatterMixin)
formatter:SetStripIntervalWhitespace(true)
formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter)

local function setupFilterPopup(resultID, reason, groupName, activityName, leaderName)
	filterPopupID = resultID
	filterPopup.Text2:SetText(reason)
	filterPopup.Text2:SetTextColor(1, 0, 0, 1)
	filterPopup.Text3:SetText(groupName .. " - " .. activityName)
	filterPopup.Text4:SetText("Leader: " .. (leaderName or "N/A"))
	filterPopup:MarkDirty()
end

local function resetQueueFrame(_, frame)
	if(not InCombatLockdown()) then
		frame:Hide()
		frame.layoutIndex = nil

		local objectType = frame:GetObjectType()

		if(objectType == "Frame") then
			frame:SetScript("OnMouseDown", nil)
			frame:SetScript("OnEnter", nil)
			frame:SetScript("OnLeave", nil)
			frame.Name:SetText("")
			frame.Name:SetTextColor(1,1,1,1)
			frame.Age:SetText("")
			frame.Background:SetTexture(nil)
			frame:SetAlpha(1)

			frame:ClearBackdrop()
			
			frame.CancelApplication:RegisterForClicks("LeftButtonDown")
			frame.CancelApplication:SetAttribute("type", nil)
			frame.CancelApplication:SetAttribute("macrotext1", nil)
			frame.CancelApplication:Show()

			frame.Wait:SetText("Wait")
		end

		miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()

	else
		miog.F.UPDATE_AFTER_COMBAT = true

	end
end

local function createQueueFrame(queueInfo)
	if(not InCombatLockdown()) then
		local queueFrame = queueSystem.queueFrames[queueInfo[18]]

		if(not queueSystem.queueFrames[queueInfo[18]]) then
			queueFrame = queueSystem.framePool:Acquire()
			queueFrame.ActiveIDFrame:Hide()

			--miog.createFrameBorder(queueFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
			queueSystem.queueFrames[queueInfo[18]] = queueFrame

			queueFrameIndex = queueFrameIndex + 1
			queueFrame.layoutIndex = queueInfo[21] or queueFrameIndex
		
		end

		queueFrame:SetWidth(miog.MainTab.QueueInformation.Panel:GetWidth() - 7)
		
		--queueFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

		queueFrame.Name:SetText(queueInfo[11])

		local ageNumber = 0

		if(queueFrame.Age.Ticker) then
			queueFrame.Age.Ticker:Cancel()
			queueFrame.Age.Ticker = nil
		end

		if(queueInfo[17]) then
			if(queueInfo[17][1] == "queued") then
				ageNumber = GetTime() - queueInfo[17][2]

				queueFrame.Age.Ticker = C_Timer.NewTicker(1, function()
					ageNumber = ageNumber + 1
					queueFrame.Age:SetText(miog.secondsToClock(ageNumber))

				end)
			elseif(queueInfo[17][1] == "duration") then
				ageNumber = queueInfo[17][2]

				queueFrame.Age.Ticker = C_Timer.NewTicker(1, function()
					ageNumber = ageNumber - 1
					queueFrame.Age:SetText(miog.secondsToClock(ageNumber))

				end)
			
			end
		end

		if(queueInfo[30]) then
			local isHQ = miog.isMIOGHQLoaded()
			
			if(isHQ) then
				queueFrame.Background:SetVertTile(false)
				queueFrame.Background:SetHorizTile(false)
				queueFrame.Background:SetTexture(queueInfo[30], "CLAMP", "CLAMP")
				
			else
				queueFrame.Background:SetVertTile(true)
				queueFrame.Background:SetHorizTile(true)
				queueFrame.Background:SetTexture(queueInfo[30], "MIRROR", "MIRROR")

			end

		end

		queueFrame.Age:SetText(miog.secondsToClock(ageNumber or 0))

		--if(queueInfo[20]) then
			--queueFrame.Icon:SetTexture(queueInfo[20])
		--end

		queueFrame.Wait:SetText("(" .. (queueInfo[12] ~= -1 and miog.secondsToClock(queueInfo[12] or 0) or "N/A") .. ")")

		queueFrame:SetShown(true)

	---@diagnostic disable-next-line: undefined-field
		miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()

		queueFrame:GetParent():MarkDirty()

		return queueFrame
	else
		miog.F.UPDATE_AFTER_COMBAT = true
	
	end
end

local function updateFakeGroupApplications()
	if(MR_GetNumberOfPartyGUIDs) then
		local numOfSavedGUIDs = MR_GetNumberOfPartyGUIDs()

		miog.pveFrame2.TabFramesPanel.MainTab.QueueInformation.Panel.Title.FakeApps:SetText("(+" .. numOfSavedGUIDs .. ")")

		if(numOfSavedGUIDs> 0) then
			for d, listEntry in ipairs(miog.SearchPanel:GetSortingData()) do
				if(C_LFGList.HasSearchResultInfo(listEntry.resultID)) then
					local partyGUID = C_LFGList.GetSearchResultInfo(listEntry.resultID).partyGUID

					if(MR_GetSavedPartyGUIDs()[partyGUID]) then
						local id, appStatus = C_LFGList.GetApplicationInfo(listEntry.resultID)
		
						if(appStatus ~= "applied") then
							local identifier = "FAKE_APPLICATION_FOR_RESULT_" .. listEntry.resultID
							local searchResultInfo = C_LFGList.GetSearchResultInfo(id);
							local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1])
							local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)
					
							local frameData = {
								[1] = true,
								[2] = groupInfo,
								[11] = searchResultInfo.name,
								[12] = -1,
								--[17] = {"duration", appDuration},
								[18] = identifier,
								[20] = miog.ACTIVITY_INFO[searchResultInfo.activityIDs[1]].icon or nil,
								[21] = listEntry.resultID + 1000,
								[30] = miog.ACTIVITY_INFO[searchResultInfo.activityIDs[1]] and miog.ACTIVITY_INFO[searchResultInfo.activityIDs[1]].horizontal or nil
							}

							local frame = createQueueFrame(frameData)

							if(frame) then
								frame:SetAlpha(0.45)
								frame:SetScript("OnMouseDown", function()
									PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
									LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, activityInfo.categoryID, LFGListFrame.SearchPanel.preferredFilters or 0, LFGListFrame.baseFilters)
									LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
									LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
								end)

								frame:SetScript("OnEnter", function(self)
									miog.createResultTooltip(id, frame)

									GameTooltip:Show()
								end)
								frame:SetScript("OnLeave", function()
									GameTooltip:Hide()
								end)
							end
						end
					end
				end
			end
		else
			miog.pveFrame2.TabFramesPanel.MainTab.QueueInformation.Panel.Title.FakeApps:SetText("")

		end
	end
end

miog.updateFakeGroupApplications = updateFakeGroupApplications

local function updateAllPVEQueues()
	for categoryID = 1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(categoryID);

		if (mode and submode ~= "noteleport" ) then
			queuedList = GetLFGQueuedList(categoryID, queuedList) or {}
			
			local length = 0
			for _ in pairs(queuedList) do
				length = length + 1
			end
		
			local activeID = select(18, GetLFGQueueStats(categoryID));
			local isSpecificQueue = categoryID == LE_LFG_CATEGORY_LFD and length > 1
			local specificQueueDungeons = {}

			for queueID, queued in pairs(queuedList) do
				mode, submode = GetLFGMode(categoryID, queueID);
				local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)

				table.insert(specificQueueDungeons, {dungeonID = queueID, name = name, difficulty = subtypeID == 1 and "Normal" or subtypeID == 2 and "Heroic"})

				if(mode == "queued" and activeID == queueID or categoryID == LE_LFG_CATEGORY_RF) then
					local inParty, joined, isQueued, noPartialClear, achievements, lfgComment, slotCount, categoryID2, leader, tank, healer, dps, x1, x2, x3, x4 = GetLFGInfoServer(categoryID, queueID);

					local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, queueID)

					local isFollowerDungeon = queueID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(queueID)

					local frameData = {
						[1] = hasData,
						[2] = isFollowerDungeon and LFG_TYPE_FOLLOWER_DUNGEON or subtypeID == 1 and LFG_TYPE_DUNGEON or subtypeID == 2 and LFG_TYPE_HEROIC_DUNGEON or subtypeID == 3 and RAID_FINDER,
						[11] = isSpecificQueue and MULTIPLE_DUNGEONS or name,
						[12] = myWait,
						[17] = {"queued", queuedTime},
						[18] = queueID,
						[20] = miog.DIFFICULTY_ID_INFO[difficulty] and miog.DIFFICULTY_ID_INFO[difficulty].isLFR and fileID
						or mapID and miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[queueID] and miog.LFG_ID_INFO[queueID].icon or fileID or miog.findBattlegroundIconByName(name) or miog.findBrawlIconByName(name) or nil,
						[30] = miog.LFG_ID_INFO[queueID] and miog.LFG_ID_INFO[queueID].horizontal or (isSpecificQueue or mapID == nil) and miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dungeon.png" or miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].horizontal
					}

					local frame

					if(not hasData) then
						frameData[17] = nil
					end

					frame = createQueueFrame(frameData)

					if(frame) then
						if(categoryID == 3 and activeID == queueID and length > 1) then
							frame.ActiveIDFrame:Show()

						else
							frame.ActiveIDFrame:Hide()

							--[[if(categoryID == 1) then
								frame.CancelApplication:SetScript("OnEnter", function(self)
									GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
									GameTooltip_AddErrorLine(GameTooltip, "This will also cancel all group finder applications!")
									GameTooltip:Show()
								end)

							end]]
						
						end

						--[[frame.CancelApplication:SetScript("OnClick", function()
							LeaveSingleLFG(categoryID, queueID)
						end)]]
						
					
						frame.CancelApplication:SetAttribute("type", "macro")
						frame.CancelApplication:SetAttribute("macrotext1", "/run LeaveSingleLFG(" .. categoryID .. "," .. queueID .. ")")

						if(mapID and not isSpecificQueue) then
							frame:SetScript("OnMouseDown", function()
								EncounterJournal_OpenJournal(difficulty, miog.MAP_INFO[mapID].journalInstanceID, nil, nil, nil, nil)
							end)
						end

						frame:SetScript("OnEnter", function(self)
							local tooltip = GameTooltip
							tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
	
							tooltip:SetText(isSpecificQueue and MULTIPLE_DUNGEONS or name, 1, 1, 1, true);

							if(hasData) then
								if(name2 and name ~= name2) then
									tooltip:AddLine(name2)
									
								end

								tooltip:AddLine(string.format(DUNGEON_DIFFICULTY_BANNER_TOOLTIP, miog.DIFFICULTY_ID_INFO[difficulty].name))

								if(IsPlayerAtEffectiveMaxLevel() and minLevel == UnitLevel("player")) then
									tooltip:AddLine("Max level dungeon")
									
								else
									tooltip:AddLine(isScalingDungeon and "Scales with level (" .. string.format("%d - %d", minLevel, maxLevel) .. ")" or "Doesn't scale with level")

								end
								tooltip:AddLine(string.format("%d - %d players", minPlayersDisband and minPlayersDisband > 0 and minPlayersDisband or 1, maxPlayers))
	
								GameTooltip_AddBlankLineToTooltip(GameTooltip)

								if(noPartialClear) then
									tooltip:AddLine("This will be a fresh ID.")

								else
									tooltip:AddLine("This group could have already killed some bosses.")

								end

								if(isTimewalker) then
									tooltip:AddLine(PLAYER_DIFFICULTY_TIMEWALKER)
								end

								if(isHoliday) then
									tooltip:AddLine(CALENDAR_FILTER_HOLIDAYS)
								end

								if(bonusRep > 0) then
									tooltip:AddLine(string.format(LFG_BONUS_REPUTATION, bonusRep))
									
								end
	
								tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, totalTanks + totalHealers + totalDPS - tankNeeds - healerNeeds - dpsNeeds, totalTanks - tankNeeds, totalHealers - healerNeeds, totalDPS - dpsNeeds));
	
								if ( queuedTime > 0 ) then
									tooltip:AddLine(string.format("Queued for: |cffffffff%s|r", formatter:Format(GetTime() - queuedTime)));
								end
	
								GameTooltip_AddBlankLineToTooltip(GameTooltip)
								
								tooltip:AddLine("Wait times:");
	
								if ( myWait > 0 ) then
									tooltip:AddLine(string.format("~ |cffffffff%s|r", formatter:Format(myWait)));
								end
	
								if ( averageWait > 0 ) then
									tooltip:AddLine(string.format("Ø |cffffffff%s|r", formatter:Format(averageWait)));
								end
	
								if ( tankWait > 0 ) then
									tooltip:AddLine(string.format("|A:GO-icon-role-Header-Tank:14:14|a |cffffffff%s|r", formatter:Format(tankWait)));
								end
	
								if ( healerWait > 0 ) then
									tooltip:AddLine(string.format("|A:GO-icon-role-Header-Healer:14:14|a |cffffffff%s|r", formatter:Format(healerWait)));
								end
	
								if ( damageWait > 0 ) then
									tooltip:AddLine(string.format("|A:GO-icon-role-Header-DPS:14:14|a |cffffffff%s|r", formatter:Format(damageWait)));
								end
	
								if(isSpecificQueue) then
									GameTooltip_AddBlankLineToTooltip(GameTooltip)
	
									tooltip:AddLine(QUEUED_FOR_SHORT)
	
									table.sort(specificQueueDungeons, function(k1, k2)
										if(k1.difficulty == k2.difficulty) then
											return k1.dungeonID < k2.dungeonID
										end
	
										return k1.difficulty < k2.difficulty
									end)
	
									for _, v in ipairs(specificQueueDungeons) do
										tooltip:AddLine(v.difficulty .. " " .. v.name)
	
									end
								end
	
							else
								tooltip:AddLine(WrapTextInColorCode("Still waiting for data from Blizzard...", miog.CLRSCC.red));
							
							end
	
							GameTooltip:Show()
						end)

						frame:SetScript("OnLeave", GameTooltip_Hide)
					end
				end
			end
		
			if(activeID) then
				if ( mode == "queued" ) then

					local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount, _, leader, tank, healer, dps = GetLFGInfoServer(categoryID, activeID);
					local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, activeID);
					if(categoryID == LE_LFG_CATEGORY_SCENARIO) then --Hide roles for scenarios
						tank, healer, dps = nil, nil, nil;
						totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds = nil, nil, nil, nil, nil, nil;

					elseif(categoryID == LE_LFG_CATEGORY_WORLDPVP) then
						--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_IN_PROGRESS, subTitle, extraText);
					else
						--QueueStatusEntry_SetFullDisplay(entry, GetDisplayNameFromCategory(category), queuedTime, myWait, tank, healer, dps, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText);
						--createQueueFrame(categoryID, {GetLFGDungeonInfo(activeID)}, {GetLFGQueueStats(categoryID)})
					end
				elseif ( mode == "proposal" ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_PROPOSAL, subTitle, extraText);
				elseif ( mode == "listed" ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_LISTED, subTitle, extraText);
				elseif ( mode == "suspended" ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_SUSPENDED, subTitle, extraText);
				elseif ( mode == "rolecheck" ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_ROLE_CHECK_IN_PROGRESS, subTitle, extraText);
				elseif ( mode == "lfgparty" or mode == "abandonedInDungeon" ) then
					--[[local title;
					if (C_PvP.IsInBrawl()) then
						local brawlInfo = C_PvP.GetActiveBrawlInfo();
						if (brawlInfo and brawlInfo.canQueue and brawlInfo.longDescription) then
							title = brawlInfo.name;
							if (subTitle) then
								subTitle = QUEUED_STATUS_BRAWL_RULES_SUBTITLE:format(brawlInfo.longDescription, subTitle);
							else
								subTitle = brawlInfo.longDescription;
							end
						end
					else
						title = GetDisplayNameFromCategory(category);
					end
					
					QueueStatusEntry_SetMinimalDisplay(entry, title, QUEUED_STATUS_IN_PROGRESS, subTitle, extraText);]]
				else
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_UNKNOWN, subTitle, extraText);
				end
			end
			
			queueIndex = queueIndex + 1
		end
	end
end

local function updateCurrentListing()
	--Try LFGList entries
	local isActive = C_LFGList.HasActiveEntryInfo();
	if ( isActive ) then
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants();
		local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityIDs[1])
		local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)

		local unitName, unitID = miog.getGroupLeader()

		local frameData = {
			[1] = true,
			[2] = groupInfo or activityInfo.shortName,
			[11] = unitID == "player" and "Your Listing" or (unitName or "Unknown") .. "'s Listing",
			[12] = -1,
			[17] = {"duration", activeEntryInfo.duration},
			[18] = "YOURLISTING",
			[20] = miog.ACTIVITY_INFO[activeEntryInfo.activityIDs[1]].icon or nil,
			[21] = -2,
			[30] = miog.ACTIVITY_INFO[activeEntryInfo.activityIDs[1]] and miog.ACTIVITY_INFO[activeEntryInfo.activityIDs[1]].horizontal or activityInfo.groupFinderActivityGroupID == 0 and miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dungeon.png" or nil
		}

		local frame = createQueueFrame(frameData)

		if(frame) then
			frame.CancelApplication:SetShown(UnitIsGroupLeader("player"))
			--[[frame.CancelApplication:SetScript("OnClick", function()
				C_LFGList.RemoveListing()
			end)]]

			frame.CancelApplication:SetAttribute("type", "macro")
			frame.CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.RemoveListing()")

			frame:SetScript("OnMouseDown", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)
			end)
			frame:SetScript("OnEnter", function(self)
				self.BackgroundHover:Show()
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(string.format(LFG_LIST_PENDING_APPLICANTS, numActiveApplicants))

				if(activeEntryInfo.questID and activeEntryInfo.questID > 0) then
					GameTooltip:AddLine(LFG_TYPE_QUEST .. ": " .. C_QuestLog.GetTitleForQuestID(activeEntryInfo.questID))
					
				end

				GameTooltip:Show()
			end)
			frame:SetScript("OnLeave", function(self)
				self.BackgroundHover:Hide()
				GameTooltip:Hide()
			end)
		end

		--createQueueFrame(categoryID, {GetLFGDungeonInfo(activeID)}, {GetLFGQueueStats(categoryID)})
	end
end

local function updateGroupApplications()
	numOfActiveApps = 0
	showFilterPopup = false

	local applications = C_LFGList.GetApplications()
	if(applications) then
		for _, v in ipairs(applications) do
			local id, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(v)

			if(id) then
				local identifier = "APPLICATION_" .. id

				if(appStatus == "applied") then

					local searchResultInfo = C_LFGList.GetSearchResultInfo(id);
					local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1])
					local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)
			
					local frameData = {
						[1] = true,
						[2] = groupInfo,
						[11] = searchResultInfo.name,
						[12] = -1,
						[17] = {"duration", appDuration},
						[18] = identifier,
						[20] = miog.ACTIVITY_INFO[searchResultInfo.activityIDs[1]].icon or nil,
						[21] = id,
						[30] = miog.ACTIVITY_INFO[searchResultInfo.activityIDs[1]] and miog.ACTIVITY_INFO[searchResultInfo.activityIDs[1]].horizontal or nil
					}

					local frame = createQueueFrame(frameData)

					numOfActiveApps = numOfActiveApps + 1

					if(frame) then
						frame.CancelApplication:SetAttribute("type", "macro")
						frame.CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.CancelApplication(" .. id .. ")")

						frame:SetScript("OnMouseDown", function()
							PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
							LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, activityInfo.categoryID, LFGListFrame.SearchPanel.preferredFilters or 0, LFGListFrame.baseFilters)
							LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
							LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
						end)

						local eligible, reasonID = miog.checkEligibility("LFGListFrame.SearchPanel", nil, id, true)
						local reason = miog.INELIGIBILITY_REASONS[reasonID]

						if(eligible == false) then
							frame.Name:SetTextColor(1, 0, 0, 1)

							if(reason) then
								frame.Name:SetText(frame.Name:GetText() .. " - " .. reason[2])

								if(MIOG_NewSettings.filterPopup and not disabledPopups[v] and not searchResultInfo.isDelisted) then
									setupFilterPopup(v, reason[1], searchResultInfo.name, activityInfo.fullName, searchResultInfo.leaderName)

									showFilterPopup = true
								end
							end
						end

						frame:SetScript("OnEnter", function(self)
							miog.createResultTooltip(id, frame)

							GameTooltip:Show()
						end)
						frame:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)
					end

					queueIndex = queueIndex + 1
				end
			end
		end
	end

	if(MIOG_NewSettings.filterPopup) then
		filterPopup.Text6:SetText("Remaining applications: " .. (numOfActiveApps - 1))

		if(filterPopupID) then
			local id, appStatus = C_LFGList.GetApplicationInfo(filterPopupID)

			if(id and appStatus == "applied" and showFilterPopup) then
				StaticPopupSpecial_Show(filterPopup)

			else
				filterPopupID = nil
				StaticPopupSpecial_Hide(filterPopup)

			end
		end
	end
end

local function updatePVPQueues()
	--[[
		local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();

		--Try PvP Role Check
		if ( inProgress and isBattleground ) then
			QueueStatusEntry_SetUpPVPRoleCheck(entry);
		end

		local readyCheckInProgress, readyCheckIsBattleground = GetLFGReadyCheckUpdate();

		-- Try PvP Ready Check
		if ( readyCheckInProgress and readyCheckIsBattleground ) then
			QueueStatusEntry_SetUpPvPReadyCheck(entry);
		end
	]]

	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend, queueType, gameType, role, asGroup, shortDescription, longDescription, isSoloQueue = GetBattlefieldStatus(i);

		if ( status and status ~= "none" and status ~= "error" ) then
			local queuedTime = GetTime() - GetBattlefieldTimeWaited(i) / 1000
			local estimatedTime = GetBattlefieldEstimatedWaitTime(i) / 1000
			local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);
			local allowsDecline = PVPHelper_QueueAllowsLeaveQueueWithMatchReady(queueType)
			
			local frameData = {
				[1] = true,
				[2] = gameType,
				[11] = mapName,
				[12] = estimatedTime,
				[17] = {"queued", queuedTime},
				[18] = mapName,
				[20] = miog.findBattlegroundIconByName(mapName) or miog.findBrawlIconByName(mapName) or 525915
			}

			local frame

			if (mapName and queuedTime) then
				frame = createQueueFrame(frameData)
				--frame.CancelApplication:Hide()

				if(frame) then
					local mapIDTable = miog.findBattlegroundMapIDsByName(mapName) or miog.findBrawlMapIDsByName(mapName)

					if(mapName == "Random Epic Battleground") then
						frame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/epicbgs.png")

					elseif(mapName == "Random Battleground") then
						frame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/normalbgs.png")

					elseif(mapIDTable and #mapIDTable > 0) then
						local counter = 0
						local randomNumber = random(1, #mapIDTable)

						for k, v in pairs(mapIDTable) do
							counter = counter + 1

							if(counter == randomNumber) then
								frame.Background:SetTexture(miog.MAP_INFO[v].horizontal)
								break
							end
						end
					else
						frame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/pvpbattleground.png")
					
					end

					frame:SetScript("OnEnter", function(self)
						local tooltip = GameTooltip
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)

						tooltip:SetText(mapName, 1, 1, 1, true);

						if(role ~= "") then
							tooltip:AddLine(LFG_TOOLTIP_ROLES .. " " .. string.lower(role):gsub("^%l", string.upper));
						end

						if(role ~= "") then
							tooltip:AddLine(LFG_TOOLTIP_ROLES .. " " .. string.lower(role):gsub("^%l", string.upper));
						end

						if(assignedSpec) then
							tooltip:AddLine(ASSIGNED_COLON .. miog.SPECIALIZATIONS[assignedSpec].name);
						end
						
						GameTooltip_AddBlankLineToTooltip(GameTooltip)

						if ( queuedTime > 0 ) then
							tooltip:AddLine(string.format("Queued for: |cffffffff%s|r", SecondsToTime(GetTime() - queuedTime, false, false, 1, false)));
						end

						if ( estimatedTime > 0 ) then
							tooltip:AddLine(string.format("Average wait time: |cffffffff%s|r", SecondsToTime(estimatedTime, false, false, 1, false)));
						end

						if(teamSize > 0) then
							tooltip:AddLine(teamSize);
						end


						GameTooltip:Show()
					end)

					frame:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)
				end
			end

			
			if (frame and status == "queued" ) then
				if(not suspend) then
					frame.CancelApplication:SetAttribute("type", "macro")
					frame.CancelApplication:SetAttribute("macrotext1", "/click QueueStatusButton RightButton")

					queueIndex = queueIndex + 1
					

				end
			end
		elseif(status) then
		
		end
	end
end

local function updateWorldPVPQueues()
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID, expireTime, averageWaitTime, queuedTime, suspended = GetWorldPVPQueueStatus(i)
		if ( status and status ~= "none" ) then
			--QueueStatusEntry_SetUpWorldPvP(entry, i);
			local frameData = {
				[1] = true,
				[2] = "",
				[11] = "World PvP",
				[12] = averageWaitTime,
				[17] = {"queued", queuedTime},
				[18] = mapName or ("WORLDPVP" .. i),
				[30] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/pvpbattleground.png",
			}
	
			if (status == "queued") then
				local frame = createQueueFrame(frameData)
				--frame.Icon:Show()
	
				if(frame) then
					frame.CancelApplication:SetAttribute("type", "macro")
					frame.CancelApplication:SetAttribute("macrotext1", "/run BattlefieldMgrExitRequest(" .. queueID .. ")")
	
				end
	
				queueIndex = queueIndex + 1
	
			elseif(status == "proposal") then
				
			
			end
		end
	end

	--World PvP areas we're currently in
	if ( CanHearthAndResurrectFromArea() ) then
		local frameData = {
			[1] = true,
			[2] = "",
			[11] = "Open World PvP",
			[12] = 0,
			[17] = {"queued", GetTime()},
			[18] = GetRealZoneText(),
			[30] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/pvpbattleground.png",
		}

		local frame = createQueueFrame(frameData)
		--frame.Icon:Show()

		if(frame) then
			frame.CancelApplication:SetAttribute("type", "macro")
			frame.CancelApplication:SetAttribute("macrotext1", "/run HearthAndResurrectFromArea()")

		end

		queueIndex = queueIndex + 1

	end
end

local function updatePetBattleQueue()
	local pbStatus, estimate, queued = C_PetBattles.GetPVPMatchmakingInfo();
	if ( pbStatus ) then
		local frameData = {
			[1] = true,
			[2] = "",
			[11] = "Pet Battle",
			[12] = estimate,
			[17] = {"queued", queued},
			[18] = "PETBATTLE",
			[20] = miog.C.STANDARD_FILE_PATH .. "/infoIcons/petbattle.png",
			[30] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/petbattle.png",
		}

		if (pbStatus == "queued") then
			local frame = createQueueFrame(frameData)

			if(frame) then
				frame.CancelApplication:SetAttribute("type", "macro")
				frame.CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")

			end

			queueIndex = queueIndex + 1

		elseif(pbStatus == "proposal") then
		
		end
	end
end

local function checkQueues()
	if(not InCombatLockdown()) then
		queueSystem.queueFrames = {}
		queueSystem.framePool:ReleaseAll()
		queueIndex = 1

		updateAllPVEQueues()
		updateCurrentListing()
		updateFakeGroupApplications()
		updateGroupApplications()
		updatePVPQueues()
		updateWorldPVPQueues()
		updatePetBattleQueue()
		
	else
		miog.F.UPDATE_AFTER_COMBAT = true

	end
end

local function createFilterPopup()
	filterPopup = CreateFrame("Frame", nil, UIParent, "MIOG_PopupFrame")
    filterPopup:SetPropagateMouseClicks(false)

	filterPopup.ButtonPanel.Button1:SetText("Dismiss")
	filterPopup.ButtonPanel.Button1:FitToText()
	filterPopup.ButtonPanel.Button1:SetScript("OnClick", function()
	    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		if(filterPopupID) then
			disabledPopups[filterPopupID] = true

		end

		filterPopupID = nil

		StaticPopupSpecial_Hide(filterPopup)
	end)

	filterPopup.ButtonPanel.Button2:SetText("Cancel")
	filterPopup.ButtonPanel.Button2:FitToText()
	filterPopup.ButtonPanel.Button2:SetScript("OnClick", function()
	    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		
		if(filterPopupID) then
			C_LFGList.CancelApplication(filterPopupID)

		end
		
		filterPopupID = nil

		StaticPopupSpecial_Hide(filterPopup)
	end)

	filterPopup:SetScript("OnShow", function()
		if(MIOG_NewSettings.flashOnFilterPopup) then
			FlashClientIcon()
		end
	end)
end

miog.loadQueueSystem = function()
	queueSystem.framePool = CreateFramePool("Frame", miog.MainTab.QueueInformation.Panel.ScrollFrame.Container, "MIOG_QueueFrame", resetQueueFrame)
	hooksecurefunc(QueueStatusFrame, "Update", checkQueues)

	local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_QueueEventReceiver")

	eventReceiver:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	eventReceiver:RegisterEvent("LFG_UPDATE")
	eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
	eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	eventReceiver:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
	eventReceiver:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
	eventReceiver:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventReceiver:SetScript("OnEvent", miog.queueEvents)

	createFilterPopup()
end

local function queueEvents(_, event, ...)
	if(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.UPDATE_AFTER_COMBAT) then
			miog.F.UPDATE_AFTER_COMBAT = false

			miog.updateDropDown()
			checkQueues()
		end
	end
end

miog.queueEvents = queueEvents