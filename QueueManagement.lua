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

		if(objectType == "Button") then
			frame:SetScript("OnMouseDown", nil)
			frame:SetScript("OnEnter", nil)
			frame.Name:SetText("")
			frame.Name:SetTextColor(1,1,1,1)
			frame.Age:SetText("")
			frame.Background:SetTexture(nil)
			frame:SetAlpha(1)

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
	if(not InCombatLockdown() and true == false) then
		local queueFrame = queueSystem.queueFrames[queueInfo[18]]

		if(not queueSystem.queueFrames[queueInfo[18]]) then
			queueFrame = queueSystem.framePool:Acquire()
			queueFrame.ActiveIDFrame:Hide()
			queueSystem.queueFrames[queueInfo[18]] = queueFrame

			queueFrameIndex = queueFrameIndex + 1
			queueFrame.layoutIndex = queueInfo[21] or queueFrameIndex
		
		end

		queueFrame:SetWidth(miog.MainTab.QueueInformation.Panel:GetWidth() - 7)

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

		queueFrame.Age:SetText(miog.secondsToClock(ageNumber or 0))
		queueFrame.Wait:SetText("(" .. (queueInfo[12] ~= -1 and miog.secondsToClock(queueInfo[12] or 0) or "N/A") .. ")")

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

		queueFrame:Show()

		miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()

		return queueFrame

	else
		miog.F.UPDATE_AFTER_COMBAT = true
	
	end
end

local function updateFakeGroupApplications(dataProvider)
	if(MR_GetNumberOfPartyGUIDs and not miog.F.LITE_MODE) then
		local numOfSavedGUIDs = MR_GetNumberOfPartyGUIDs()

		miog.pveFrame2.TabFramesPanel.MainTab.QueueInformation.Panel.FakeApps:SetText("(+" .. numOfSavedGUIDs .. ")")

		if(numOfSavedGUIDs> 0) then
			local total, resultTable = C_LFGList.GetFilteredSearchResults()
			for _, resultID in ipairs(resultTable) do
			--for d, listEntry in ipairs(miog.SearchPanel:GetSortingData()) do
				if(C_LFGList.HasSearchResultInfo(resultID)) then
					local partyGUID = C_LFGList.GetSearchResultInfo(resultID).partyGUID

					if(MR_GetSavedPartyGUIDs()[partyGUID]) then
						local id, appStatus = C_LFGList.GetApplicationInfo(resultID)
		
						if(appStatus ~= "applied") then
							--local identifier = "FAKE_APPLICATION_FOR_RESULT_" .. resultID
							--local searchResultInfo = C_LFGList.GetSearchResultInfo(id);
							--local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])
							--local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)
					
							

							dataProvider:Insert({
								template = "MIOG_QueueFakeApplicationFrameTemplate",
								resultID = resultID,
							})

							--[[local frameData = {
								[1] = true,
								[2] = groupInfo,
								[11] = searchResultInfo.name,
								[12] = -1,
								--[17] = {"duration", appDuration},
								[18] = identifier,
								[20] = activityInfo.icon or nil,
								[21] = resultID + 1000,
								[30] = activityInfo.horizontal or nil
							}

							--local frame = createQueueFrame(frameData)

							if(frame) then
								frame:SetAlpha(0.5)
								frame:SetScript("OnMouseDown", function()
									PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
									LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, activityInfo.categoryID, LFGListFrame.SearchPanel.preferredFilters or 0, LFGListFrame.baseFilters)
									LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
									LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
								end)

								--frame:SetScript("OnEnter", function(self)
									--miog.createResultTooltip(id, frame)

								--	GameTooltip:Show()
								--end)

								frame.CancelApplication:SetAttribute("type", "macro")
								frame.CancelApplication:SetAttribute("macrotext1", "/run MIOG_DeletePartyGUID(" .. tostring(C_LFGList.GetSearchResultInfo(resultID).partyGUID) .. ")")
							end]]
						end
					end
				end
			end
		else
			miog.pveFrame2.TabFramesPanel.MainTab.QueueInformation.Panel.FakeApps:SetText("")

		end
	end
end

miog.updateFakeGroupApplications = updateFakeGroupApplications

local function updateAllPVEQueues(dataProvider)
	for categoryID = 1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(categoryID);
		local isRF = categoryID == LE_LFG_CATEGORY_RF

		if (mode and submode ~= "noteleport" ) then
			queuedList = GetLFGQueuedList(categoryID, queuedList) or {}
			
			local length = 0
			for _ in pairs(queuedList) do
				length = length + 1
			end
		
			local activeID = select(18, GetLFGQueueStats(categoryID));
			local isMultiDungeon = categoryID == LE_LFG_CATEGORY_LFD and length > 1

			for queueID, queued in pairs(queuedList) do
				mode, submode = GetLFGMode(categoryID, queueID)
				
				if(activeID == queueID or isRF) then
					dataProvider:Insert({
						template = "MIOG_QueueLFGFrameTemplate",
						mode = mode,
						submode = submode,
						categoryID = categoryID,
						queueID = queueID,
						activeID = activeID,
						isCurrentlyActive = queueID == activeID,
						isMultiDungeon = isMultiDungeon,
					})
				end
				--end
			end
		end
	end
		
			--[[if(activeID) then
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
					-- local title;
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
					
					QueueStatusEntry_SetMinimalDisplay(entry, title, QUEUED_STATUS_IN_PROGRESS, subTitle, extraText);] ]
				else
					--QueueStatusEntry_SetMinimalDisplay(entry, GetDisplayNameFromCategory(category), QUEUED_STATUS_UNKNOWN, subTitle, extraText);
				end
			end]]
end

local function updateCurrentListing(dataProvider)
	--Try LFGList entries
	local isActive = C_LFGList.HasActiveEntryInfo()

	if (isActive) then
		dataProvider:Insert({
			template = "MIOG_QueueListingFrameTemplate",
			type = "listing",
		})
	end
end

local function updateGroupApplications(dataProvider)
	--numOfActiveApps = 0
	--showFilterPopup = false

	local applications = C_LFGList.GetApplications()
	if(#applications > 0) then
		for _, v in ipairs(applications) do
			local resultID, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(v)

			if(resultID) then
				--local identifier = "APPLICATION_" .. resultID

				if(appStatus == "applied") then
					--local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
					--local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])
					--local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)
			
					--[[local frameData = {
						[1] = true,
						[2] = groupInfo,
						[11] = searchResultInfo.name,
						[12] = -1,
						[17] = {"duration", appDuration},
						[18] = identifier,
						[20] = activityInfo.icon,
						[21] = resultID,
						[30] = activityInfo.horizontal or nil
					}]]

					dataProvider:Insert({
						template = "MIOG_QueueApplicationFrameTemplate",
						resultID = resultID,
					})

					--local frame = createQueueFrame(frameData)

					--numOfActiveApps = numOfActiveApps + 1

					--if(frame) then
						
					--end

					--queueIndex = queueIndex + 1
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

local function updatePVPQueues(dataProvider)
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
			--local queuedTime = GetTime() - GetBattlefieldTimeWaited(i) / 1000
			--local estimatedTime = GetBattlefieldEstimatedWaitTime(i) / 1000
			--local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);
			--local allowsDecline = PVPHelper_QueueAllowsLeaveQueueWithMatchReady(queueType)

			dataProvider:Insert({
				template = "MIOG_QueueFramePVPTemplate",
				type = "battlefield",
				index = i,
			})
			
			--[[local frameData = {
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

				if(frame) then
					local mapIDTable = miog.findBattlegroundMapIDsByName(mapName) or miog.findBrawlMapIDsByName(mapName)
					local texture

					if(mapName == "Random Epic Battleground") then
						texture = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/epicbgs.png"

					elseif(mapName == "Random Battleground") then
						texture = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/normalbgs.png"

					elseif(mapIDTable and #mapIDTable > 0) then
						if(#mapIDTable == 1) then
							texture = miog.MAP_INFO[mapIDTable[1] ].horizontal
							
						elseif(#mapIDTable > 1) then
							local counter = 0
							local randomNumber = random(1, #mapIDTable)

							for k, v in pairs(mapIDTable) do
								counter = counter + 1

								if(counter == randomNumber) then
									texture = miog.MAP_INFO[mapIDTable[v] ].horizontal
									break
								end
							end
						end
					end

					frame.Background:SetTexture(texture or miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/pvpbattleground.png")

					frame:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:SetText(mapName, 1, 1, 1, true);

						if(role ~= "") then
							GameTooltip:AddLine(LFG_TOOLTIP_ROLES .. " " .. string.lower(role):gsub("^%l", string.upper));
						end

						if(assignedSpec) then
							GameTooltip:AddLine(ASSIGNED_COLON .. miog.SPECIALIZATIONS[assignedSpec].name);
						end
						
						GameTooltip_AddBlankLineToTooltip(GameTooltip)

						if ( queuedTime > 0 ) then
							GameTooltip:AddLine(string.format("Queued for: |cffffffff%s|r", SecondsToTime(GetTime() - queuedTime, false, false, 1, false)));
						end

						if ( estimatedTime > 0 ) then
							GameTooltip:AddLine(string.format("Average wait time: |cffffffff%s|r", SecondsToTime(estimatedTime, false, false, 1, false)));
						end

						if(teamSize > 0) then
							GameTooltip:AddLine(teamSize);
						end

						GameTooltip:Show()
					end)
				end
			end]]

			
			--[[if (frame and status == "queued" ) then
				if(not suspend) then
					local id = queueIndex * 2

					frame.CancelApplication:SetAttribute("type", "macro")

					--/click Menu.GetManager():GetOpenMenu():GetLayoutChildren()[" .. id .. "]
					--frame.CancelApplication:SetAttribute("macrotext1", "/click QueueStatusButton RightButton" .. "\r\n" .. "/click CreateFromMixins(Menu.GetManager():GetOpenMenu():GetLayoutChildren()[" .. id .. "], UIButtonMixin)")
					frame.CancelApplication:SetAttribute("macrotext1", "/click QueueStatusButton RightButton")

					--MENU_QUEUE_STATUS_FRAME
					queueIndex = queueIndex + 1
					

				end
			end]]
		elseif(status) then
		
		end
	end
end

local function updateWorldPVPQueues(dataProvider)
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID, expireTime, averageWaitTime, queuedTime, suspended = GetWorldPVPQueueStatus(i)
		if ( status and status ~= "none" ) then
			--[[local frameData = {
				[1] = true,
				[2] = "",
				[11] = "World PvP",
				[12] = averageWaitTime,
				[17] = {"queued", queuedTime},
				[18] = mapName or ("WORLDPVP" .. i),
				[30] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/pvpbattleground.png",
			}]]

			dataProvider:Insert({
				template = "MIOG_QueueFramePVPTemplate",
				index = i,
				type = "world"
			})
	
			--[[if (status == "queued") then
				local frame = createQueueFrame(frameData)
	
				if(frame) then
					frame.CancelApplication:SetAttribute("type", "macro")
					frame.CancelApplication:SetAttribute("macrotext1", "/run BattlefieldMgrExitRequest(" .. queueID .. ")")
	
				end
	
				queueIndex = queueIndex + 1
	
			--elseif(status == "proposal") then
				
			
			end]]
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

		dataProvider:Insert({
			template = "MIOG_QueueFramePVPTemplate",
			type = "openworld"
		})

	end
end

local function updatePetBattleQueue(dataProvider)
	local pbStatus = C_PetBattles.GetPVPMatchmakingInfo()

	if(pbStatus) then
		dataProvider:Insert({
			template = "MIOG_QueueFramePVPTemplate",
			type = "petbattle",
		})
	end
end

local function updatePlunderstormQueue(dataProvider)
	local queuedForPlunderstorm = C_LobbyMatchmakerInfo.IsInQueue()

	if(queuedForPlunderstorm) then
		dataProvider:Insert({
			template = "MIOG_QueueFramePVPTemplate",
			type = "plunderstorm",
		})
	end
end

local function checkQueues()
	local dataProvider = CreateDataProvider()

	if(not InCombatLockdown()) then
		--queueSystem.framePool:ReleaseAll()
		--queueSystem.queueFrames = {}
		--queueIndex = 1

		updateAllPVEQueues(dataProvider)
		updateCurrentListing(dataProvider)

		--updateFakeGroupApplications(dataProvider)

		updateGroupApplications(dataProvider)
		updatePVPQueues(dataProvider)
		updateWorldPVPQueues(dataProvider)
		updatePetBattleQueue(dataProvider)
		updatePlunderstormQueue(dataProvider)

		
		local scrollbox = miog.MainTab.QueueInformation.Panel.QueueScrollBox
		scrollbox:SetDataProvider(dataProvider)
		
		miog.MainTab.QueueInformation.Panel.Title:SetShown(dataProvider:GetSize() == 0)

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

local function queueEvents(_, event, ...)
	if(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.UPDATE_AFTER_COMBAT) then
			miog.F.UPDATE_AFTER_COMBAT = false

			checkQueues()
		end
	end
end

miog.loadQueueSystem = function()
	local scrollbox = miog.MainTab.QueueInformation.Panel.QueueScrollBox
	local scrollbar = miog.MainTab.QueueInformation.Panel.QueueScrollBar
	--queueSystem.framePool = CreateFramePool("Button", miog.MainTab.QueueInformation.Panel.ScrollFrame.Container, "MIOG_QueueFrame", resetQueueFrame)
	hooksecurefunc(QueueStatusFrame, "Update", checkQueues)

	local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 3);

	local function Initializer(frame, data)
		frame.isMultiDungeon = data.isMultiDungeon
		frame.queueID = data.queueID
		frame.categoryID = data.categoryID

		local activityName, backgroundImage, timeInQueue, timeToMatch, macrotext
		local isHQ = miog.isMIOGHQLoaded()

		if(frame.Age.Ticker) then
			frame.Age.Ticker:Cancel()
			frame.Age.Ticker = nil
		end

		frame.Name:SetTextColor(1, 1, 1, 1)
		frame:SetAlpha(1)

		local isFakeApp = data.template == "MIOG_QueueFakeApplicationFrameTemplate"

		if(data.template == "MIOG_QueueLFGFrameTemplate") then
			local queueID = data.queueID
			local categoryID = data.categoryID

			local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)

			local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, queueID)

			local isFollowerDungeon = queueID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(queueID)

			macrotext = "/run LeaveSingleLFG(" .. categoryID .. "," .. queueID .. ")"

			activityName = data.isMultiDungeon and MULTIPLE_DUNGEONS or name
			timeInQueue = queuedTime and GetTime() - queuedTime or 0
			timeToMatch = myWait and myWait > -1 and myWait or averageWait and averageWait > -1 and averageWait or -1

			if(hasData) then
				frame.Age.Ticker = C_Timer.NewTicker(1, function()
					timeInQueue = timeInQueue + 1
					frame.Age:SetText(miog.secondsToClock(timeInQueue))

				end)

				frame.Wait:SetText(timeToMatch ~= -1 and "(" .. (timeToMatch ~= -1 and miog.secondsToClock(timeToMatch)) .. ")" or "")
				frame.Wait:Show()

				local totalNumOfPlayers = maxPlayers - tankNeeds - healerNeeds - dpsNeeds

				if(totalNumOfPlayers > 1) then
					frame.Name:SetTextColor(1, 1, 0, 1)

					activityName = "(" .. (totalNumOfPlayers / maxPlayers * 100) .. "%) " .. activityName

				end
			else
				frame.Wait:Hide()

				local mode, submode = GetLFGMode(categoryID, queueID);

				if(submode == "unaccepted") then
					frame.Name:SetTextColor(0, 1, 0, 1)
				
				end
			end

			backgroundImage = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].horizontal or fileID
			
			if(mapID and not data.isMultiDungeon) then
				frame:SetScript("OnClick", function(self, button)
					if(button == "LeftButton") then
						EncounterJournal_OpenJournal(difficulty, miog.MAP_INFO[mapID].journalInstanceID)

					end

				end)
			else
				frame:SetScript("OnClick", nil)
			end

			--mode = mode,
			--submode = submode,
			--hasData = hasData,
			--activityTypeString = isFollowerDungeon and LFG_TYPE_FOLLOWER_DUNGEON or subtypeID == 1 and LFG_TYPE_DUNGEON or subtypeID == 2 and LFG_TYPE_HEROIC_DUNGEON or subtypeID == 3 and RAID_FINDER,
			--,
			--multiDungeon = isSpecificQueue,
			--timeInQueue = myWait,
			--type = "lfg",
			--queueType = "queue",
			--typeValue = queuedTime,
			--id = queueID,
			--icon = miog.DIFFICULTY_ID_INFO[difficulty] and miog.DIFFICULTY_ID_INFO[difficulty].isLFR and fileID
			--or mapID and miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[queueID] and miog.LFG_ID_INFO[queueID].icon or fileID or miog.findBattlegroundIconByName(name) or miog.findBrawlIconByName(name) or nil,
			--activeID = categoryID == 3 and activeID == queueID and length > 1,
			--difficulty = difficulty,
			--mapID = mapID,

		elseif(data.template == "MIOG_QueueListingFrameTemplate") then
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
			local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants()
			local activityInfo = miog.requestActivityInfo(activeEntryInfo.activityIDs[1])

			if(activityInfo) then
				local unitName, unitID = miog.getGroupLeader()

				macrotext = "/run C_LFGList.RemoveListing()"
				backgroundImage = activityInfo.horizontal or activityInfo.groupFinderActivityGroupID == 0 and miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dungeon.png"

				frame.CancelApplication:SetShown(UnitIsGroupLeader("player"))

				timeInQueue = activeEntryInfo.duration

				frame.Age.Ticker = C_Timer.NewTicker(1, function()
					timeInQueue = timeInQueue - 1
					frame.Age:SetText(miog.secondsToClock(timeInQueue))

				end)

				activityName = unitID == "player" and ("Your Listing" .. " (" .. numApplicants .. ")") or (unitName or "Unknown") .. "'s Listing"
				
			end

			frame.Wait:Hide()

		elseif(data.template == "MIOG_QueueApplicationFrameTemplate" or isFakeApp) then
			if(isFakeApp) then
				frame:SetAlpha(0.5)
				macrotext = "/run MIOG_DeletePartyGUID(" .. tostring(C_LFGList.GetSearchResultInfo(data.resultID).partyGUID) .. ")"
				timeInQueue = GetTime()

			else
				macrotext = "/run C_LFGList.CancelApplication(" .. data.resultID .. ")"

				local resultID, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(data.resultID)
				timeInQueue = appDuration
			end

			local searchResultInfo = C_LFGList.GetSearchResultInfo(data.resultID)
			local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])

			activityName = searchResultInfo.name .. " - " .. activityInfo.name
			backgroundImage = activityInfo.horizontal

			frame.categoryID = activityInfo.categoryID

			local eligible, reasonID = miog.filter.checkIfSearchResultIsEligible(data.resultID, true)
			local reason = miog.INELIGIBILITY_REASONS[reasonID]

			if(eligible == false) then
				frame.Name:SetTextColor(1, 0, 0, 1)

				if(reason) then
					frame.Name:SetText(frame.Name:GetText() .. " - " .. reason[2])

					--[[if(MIOG_NewSettings.filterPopup and not disabledPopups[v] and not searchResultInfo.isDelisted) then
						setupFilterPopup(v, reason[1], searchResultInfo.name, activityInfo.name, searchResultInfo.leaderName)

						showFilterPopup = true
					end]]
				end
			end

			frame:SetScript("OnEnter", function(self)
				miog.createResultTooltip(data.resultID, self)

			end)

			frame.Age.Ticker = C_Timer.NewTicker(1, function()
				timeInQueue = timeInQueue - 1
				frame.Age:SetText(miog.secondsToClock(timeInQueue))

			end)

			frame.Wait:Hide()

		elseif(data.template == "MIOG_QueueFramePVPTemplate") then
			local status, mapName

			if(data.type == "battlefield") then
				status, mapName = GetBattlefieldStatus(data.index);
				macrotext = "/click QueueStatusButton RightButton"
				frame.type = "battlefield"

				if ( status and status ~= "none" and status ~= "error" ) then
					local queuedTime = GetTime() - GetBattlefieldTimeWaited(data.index) / 1000
					local estimatedTime = GetBattlefieldEstimatedWaitTime(data.index) / 1000
					--local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(data.index);

					timeInQueue = GetBattlefieldTimeWaited(data.index) / 1000
					timeToMatch = estimatedTime

					local mapIDTable = miog.findBattlegroundMapIDsByName(mapName) or miog.findBrawlMapIDsByName(mapName)

					if(isHQ) then
						if(mapName == "Random Epic Battleground") then
							backgroundImage = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/epicbgs.png"

						elseif(mapName == "Random Battleground") then
							backgroundImage = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/normalbgs.png"

						end
						
					end

					if(not backgroundImage) then
						local numOfEntries = mapIDTable and #mapIDTable or 0
						
						if(numOfEntries > 0) then
							if(numOfEntries == 1) then
								backgroundImage = miog.MAP_INFO[mapIDTable[1]].horizontal
								
							elseif(numOfEntries > 1) then
								local counter = 0
								local randomNumber = random(1, numOfEntries)

								for k, v in pairs(mapIDTable) do
									counter = counter + 1

									if(counter == randomNumber) then
										backgroundImage = miog.MAP_INFO[v] and miog.MAP_INFO[v].horizontal
										break
									end
								end
							end
						end
					end

					backgroundImage = backgroundImage or miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/pvpbattleground.png"
				end

			elseif(data.type == "world") then
				local queueID, averageWaitTime, queuedTime

				status, mapName, queueID, _, averageWaitTime, queuedTime = GetWorldPVPQueueStatus(data.index)
				macrotext = "/run BattlefieldMgrExitRequest(" .. queueID .. ")"
				frame.type = "world"

				timeInQueue = GetTime() - queuedTime
				timeToMatch = averageWaitTime

			elseif(data.type == "openworld") then
				frame.type = "openworld"
				macrotext = "/run HearthAndResurrectFromArea()"
				mapName = GetRealZoneText()

				timeInQueue = GetTime()
				timeToMatch = -1
				

			elseif(data.type == "petbattle") then
				frame.type = "petbattle"
				macrotext = "/run C_PetBattles.StopPVPMatchmaking()"
				mapName = "Pet Battle"

				local _, estimated, queuedTime = C_PetBattles.GetPVPMatchmakingInfo()

				timeToMatch = estimated
				timeInQueue = GetTime() - queuedTime
				backgroundImage = "interface/petbattles/petbattlesqueue.blp"

			elseif(data.type == "plunderstorm") then
				local queueTime = C_LobbyMatchmakerInfo.GetQueueStartTime();

				macrotext = "/run C_LobbyMatchmakerInfo.AbandonQueue()"
				mapName = WOW_LABS_PLUNDERSTORM_CATEGORY
				timeInQueue = GetTime() - queueTime
			
			end
			
			activityName = mapName

			frame.index = data.index

			frame.Age.Ticker = C_Timer.NewTicker(1, function()
				timeInQueue = timeInQueue + 1
				frame.Age:SetText(miog.secondsToClock(timeInQueue))

			end)

			frame.Wait:SetText(timeToMatch ~= -1 and "(" .. (timeToMatch ~= -1 and miog.secondsToClock(timeToMatch)) .. ")" or "")
			frame.Wait:Show()
		end

		frame.CancelApplication:RegisterForClicks("LeftButtonDown")
		frame.CancelApplication:SetAttribute("macrotext1", macrotext)

		
		if(isHQ) then
			frame.Background:SetVertTile(false)
			frame.Background:SetHorizTile(false)
			frame.Background:SetTexture(backgroundImage, "CLAMP", "CLAMP")
			
		else
			frame.Background:SetVertTile(true)
			frame.Background:SetHorizTile(true)
			frame.Background:SetTexture(backgroundImage, "MIRROR", "MIRROR")

		end

		frame.Name:SetText(activityName)
		frame.Age:SetText(miog.secondsToClock(timeInQueue))
	end
	
	local function CustomFactory(factory, data)
		local template = data.template
		factory(template, Initializer)
	end
	
	view:SetElementFactory(CustomFactory)

	ScrollUtil.InitScrollBoxListWithScrollBar(scrollbox, scrollbar, view);
	
	local scrollBoxAnchorsWithBar =
	{
		CreateAnchor("TOPLEFT", 3, -4),
		CreateAnchor("BOTTOMRIGHT", -16, 3);
	}
	local scrollBoxAnchorsWithoutBar =
	{
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", -3, 3);
	}
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollbox, scrollbar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar)

	local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_QueueEventReceiver")

	--eventReceiver:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	--eventReceiver:RegisterEvent("LFG_UPDATE")
	--eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
	--eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	--eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	--eventReceiver:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
	--eventReceiver:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
	--eventReceiver:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	hooksecurefunc("JoinArena", function()
		MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=ARENA}
	end)

	hooksecurefunc("JoinRatedSoloShuffle", function()
		MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=PVP_RATED_SOLO_SHUFFLE}
	end)

	hooksecurefunc("JoinRatedBattlefield", function()
		MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=PVP_RATED_BATTLEGROUND}
	end)

	hooksecurefunc(C_PvP, "JoinRatedBGBlitz", function()
		MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=PVP_RATED_BG_BLITZ}
	end)

	hooksecurefunc("JoinBattlefield", function()
		MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=BATTLEGROUND}
	end)

	hooksecurefunc("JoinSkirmish", function()
		MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=ARENA_CASUAL}
	end)

	eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventReceiver:SetScript("OnEvent", queueEvents)

	createFilterPopup()
end