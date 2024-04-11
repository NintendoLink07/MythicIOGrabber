local addonName, miog = ...
local wticc = WrapTextInColorCode

local queuedList = {};

local queueSystem = {}
queueSystem.queueFrames = {}
queueSystem.currentlyInUse = 0

local queueFrameIndex = 0

local function resetQueueFrame(_, frame)
	frame:Hide()
	frame.layoutIndex = nil

	local objectType = frame:GetObjectType()

	if(objectType == "Frame") then
		frame:SetScript("OnMouseDown", nil)
		frame.Name:SetText("")
		frame.Age:SetText("")

		if(frame.Age.Ticker) then
			frame.Age.Ticker:Cancel()
			frame.Age.Ticker = nil
		end

		frame:ClearBackdrop()

		frame.Icon:SetTexture(nil)

		frame.Wait:SetText("Wait")
	end

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueuePanel.ScrollFrame.Container:MarkDirty()
end

miog.loadQueueSystem = function()
	queueSystem.framePool = CreateFramePool("Frame", miog.MainTab.QueuePanel.ScrollFrame.Container, "MIOG_QueueFrame", resetQueueFrame)

end

local function createQueueFrame(queueInfo)
	local queueFrame = queueSystem.queueFrames[queueInfo[18]]

	if(not queueSystem.queueFrames[queueInfo[18]]) then
		queueFrame = queueSystem.framePool:Acquire()
		queueFrame.ActiveIDFrame:Hide()
		queueFrame.CancelApplication:SetMouseClickEnabled(true)
		queueFrame.CancelApplication:RegisterForClicks("LeftButtonDown")

		--miog.createFrameBorder(queueFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		queueSystem.queueFrames[queueInfo[18]] = queueFrame

		queueFrameIndex = queueFrameIndex + 1
		queueFrame.layoutIndex = queueInfo[21] or queueFrameIndex
	
	end

	queueFrame:SetWidth(miog.MainTab.QueuePanel:GetWidth() - 7)
	
	--queueFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	queueFrame.Name:SetText(queueInfo[11])

	local ageNumber = 0

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

	queueFrame.Age:SetText(miog.secondsToClock(ageNumber))

	if(queueInfo[20]) then
		queueFrame.Icon:SetTexture(queueInfo[20])
	end

	queueFrame.Wait:SetText("(" .. (queueInfo[12] ~= -1 and miog.secondsToClock(queueInfo[12]) or "N/A") .. ")")

	queueFrame:SetShown(true)

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueuePanel.ScrollFrame.Container:MarkDirty()

	return queueFrame
end

miog.createQueueFrame = createQueueFrame

hooksecurefunc(QueueStatusFrame, "Update", function()
	queueSystem.queueFrames = {}
	queueSystem.framePool:ReleaseAll()
	--miog.inviteBox.framePool:ReleaseAll()

	local gotInvite = false

	local queueIndex = 1

	--Try each LFG type
	for categoryID = 1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(categoryID);

		if (mode and submode ~= "noteleport" ) then
			--local activeIndex = nil;
			--local allNames = {};

				--Get the list of everything we're queued for
			queuedList = GetLFGQueuedList(categoryID, queuedList) or {}
		
			local activeID = select(18, GetLFGQueueStats(categoryID));

			for queueID, queued in pairs(queuedList) do
				mode, submode = GetLFGMode(categoryID, queueID);

				if(queued == true) then
					--local inParty, joined, isQueued, noPartialClear, achievements, lfgComment, slotCount, categoryID2, leader, tank, healer, dps, x1, x2, x3, x4 = GetLFGInfoServer(categoryID, queueID);
					local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, queueID)
					local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)

					local isFollowerDungeon = queueID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(queueID)

					--print("SERVER", leader, tank, healer, dps)
					--print("NEEDS", leaderNeeds, tankNeeds, healerNeeds, dpsNeeds)
					--print("WAIT", myWait, tankWait, healerWait, damageWait)

					local frameData = {
						[1] = hasData,
						[2] = isFollowerDungeon and "Follower" or subtypeID == 1 and "Normal" or subtypeID == 2 and "Heroic" or subtypeID == 3 and "Raid Finder",
						[11] = name,
						[12] = myWait,
						[17] = {"queued", queuedTime},
						[18] = queueID,
						[20] = miog.DIFFICULTY_ID_INFO[difficulty] and miog.DIFFICULTY_ID_INFO[difficulty].isLFR and fileID
						or mapID and miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[queueID] and miog.LFG_ID_INFO[queueID].icon or fileID or miog.findBattlegroundIconByName(name) or miog.findBrawlIconByName(name) or nil
					}

					if(hasData) then
						miog.createQueueFrame(frameData)

						if(categoryID == 3 and activeID == queueID) then
							queueSystem.queueFrames[queueID].ActiveIDFrame:Show()

						else
							queueSystem.queueFrames[queueID].ActiveIDFrame:Hide()
						
						end

						queueSystem.queueFrames[queueID].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
						queueSystem.queueFrames[queueID].CancelApplication:SetAttribute("macrotext1", "/run LeaveSingleLFG(" .. categoryID .. "," .. queueID .. ")")

					else
						if(mode == "proposal") then
							local frame = miog.createInviteFrame(frameData)
							frame.Decline:SetAttribute("type", "macro") -- left click causes macro
							frame.Decline:SetAttribute("macrotext1", "/run RejectProposal()")

							frame.Accept:SetAttribute("type", "macro") -- left click causes macro
							frame.Accept:SetAttribute("macrotext1", "/run AcceptProposal()")
							
							--LFGListInviteDialog_Accept(self:GetParent());

							gotInvite = true
						end

					end
				end
			end
		
			local subTitle;
			local extraText;
		
			--[[if ( categoryID == LE_LFG_CATEGORY_RF and #allNames > 1 ) then --HACK - For now, RF works differently.
				--We're queued for more than one thing
				subTitle = table.remove(allNames, activeIndex);
				extraText = string.format(ALSO_QUEUED_FOR, table.concat(allNames, PLAYER_LIST_DELIMITER));
			elseif ( mode == "suspended" ) then
				local suspendedPlayers = GetLFGSuspendedPlayers(categoryID);
				if (suspendedPlayers and #suspendedPlayers > 0 ) then
					extraText = "";
					for i = 1, 3 do
						if (suspendedPlayers[i]) then
							if ( i > 1 ) then
								extraText = extraText .. "\n";
							end
							extraText = extraText .. string.format(RAID_MEMBER_NOT_READY, suspendedPlayers[i]);
						end
					end
				end
			end]]

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
						--miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(activeID)}, {GetLFGQueueStats(categoryID)})
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

			--[[for categoryID, listEntry in ipairs(LFGQueuedForList) do
				for dungeonID, queued in pairs(listEntry) do
					if(queued == true) then
						--DevTools_Dump({GetLFGDungeonInfo(dungeonID)})
						--DevTools_Dump({})
						local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID)
	
						if (hasData and queuedTime and not queueSystem.queueFrames[dungeonID]) then
							miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(dungeonID)}, {GetLFGQueueStats(categoryID)})
						end
					end
				end
			end]]
			
			queueIndex = queueIndex + 1
		else
		end
	end

	--Try LFGList entries
	local isActive = C_LFGList.HasActiveEntryInfo();
	if ( isActive ) then
		local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants();
		--QueueStatusEntry_SetMinimalDisplay(entry, activeEntryInfo.name, QUEUED_STATUS_LISTED, string.format(LFG_LIST_PENDING_APPLICANTS, numActiveApplicants));
		local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
		local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)

		local frameData = {
			[1] = true,
			[2] = groupInfo and groupInfo or activityInfo.shortName,
			[11] = "YOUR LISTING",
			[12] = -1,
			[17] = {"duration", activeEntryInfo.duration},
			[18] = "YOURLISTING",
			[20] = miog.ACTIVITY_INFO[activeEntryInfo.activityID].icon or nil,
			[21] = -2
		}

		local queueFrame = miog.createQueueFrame(frameData)

		if(activityInfo.groupFinderActivityGroupID == 0) then
			queueFrame.Icon:SetAtlas("Mobile-BonusIcon")
		end

		queueSystem.queueFrames["YOURLISTING"].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
		queueSystem.queueFrames["YOURLISTING"].CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.RemoveListing()")
		queueSystem.queueFrames["YOURLISTING"]:SetScript("OnMouseDown", function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)
		end)

		--miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(activeID)}, {GetLFGQueueStats(categoryID)})
	end

	--Try LFGList applications
	local applications = C_LFGList.GetApplications()
	if(applications) then
		for _, v in ipairs(applications) do
		--for i=1, #apps do
			local id, appStatus, pendingStatus, appDuration, role = C_LFGList.GetApplicationInfo(v)

            print(id, appStatus)

			local identifier = "APPLICATION_" .. id
			if(appStatus == "applied" or appStatus == "invited") then
				local searchResultInfo = C_LFGList.GetSearchResultInfo(id);
				--local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);

				local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
				local groupInfo = C_LFGList.GetActivityGroupInfo(activityInfo.groupFinderActivityGroupID)
		
				local frameData = {
					[1] = true,
					[2] = groupInfo,
					[11] = searchResultInfo.name,
					[12] = -1,
					[17] = {"duration", appDuration},
					[18] = identifier,
					[20] = miog.ACTIVITY_INFO[searchResultInfo.activityID].icon or nil,
					[21] = -1
				}

				if(appStatus == "applied") then
					miog.createQueueFrame(frameData)
					queueSystem.queueFrames[identifier].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
					queueSystem.queueFrames[identifier].CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.CancelApplication(" .. id .. ")")
					queueSystem.queueFrames[identifier]:SetScript("OnMouseDown", function()
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
						LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)
						LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, activityInfo.categoryID, activityInfo.filters, LFGListFrame.baseFilters)
						LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
						LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
					end)

				--[[elseif(appStatus == "invited") then
					queueSystem.queueFrames[identifier].CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.DeclineInvite(" .. id .. ")")
			
					local frame = miog.createInviteFrame(frameData)
					
					frame.Decline:SetAttribute("type", "macro") -- left click causes macro
					frame.Decline:SetAttribute("macrotext1", "/run C_LFGList.DeclineInvite(" .. id .. ")")

					frame.Accept:SetAttribute("type", "macro") -- left click causes macro
					frame.Accept:SetAttribute("macrotext1", "/run C_LFGList.AcceptInvite(" .. id .. ")")

					gotInvite = true]]
				end
			end
		end
	end
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
	end]]

	--Try all PvP queues
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend, queueType, gameType, _, _, _, longDescription, x1 = GetBattlefieldStatus(i);
		if ( status and status ~= "none" and status ~= "error" ) then
			local queuedTime = GetTime() - GetBattlefieldTimeWaited(i) / 1000
			local estimatedTime = GetBattlefieldEstimatedWaitTime(i) / 1000
			local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
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
			
			if ( status == "queued" ) then
				if ( suspend ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_SUSPENDED);
				else
					--QueueStatusEntry_SetFullDisplay(entry, mapName, queuedTime, estimatedTime, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText, assignedSpec);


					--local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
					--local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);

					--		1		2			3			4			5			6			7				8		9				10				11				12			13			14			15		16			17
					--local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime


					--BattlemasterList
					--PvpBrawl

					if (mapName and queuedTime) then
						miog.createQueueFrame(frameData)
						--queueSystem.queueFrames[mapName].CancelApplication:SetScript("OnClick",  SecureActionButton_OnClick)
					end

					local currentDeclineButton = "/click QueueStatusButton RightButton" .. "\r\n" ..
					(
						queueIndex == 1 and "/click [nocombat]DropDownList1Button2 Left Button" or
						queueIndex == 2 and "/click [nocombat]DropDownList1Button4 Left Button" or
						queueIndex == 3 and "/click [nocombat]DropDownList1Button6 Left Button" or
						queueIndex == 4 and "/click [nocombat]DropDownList1Button8 Left Button" or
						queueIndex == 5 and "/click [nocombat]DropDownList1Button10 Left Button" or
						queueIndex == 6 and "/click [nocombat]DropDownList1Button12 Left Button" or
						queueIndex == 7 and "/click [nocombat]DropDownList1Button14 Left Button" or
						queueIndex == 8 and "/click [nocombat]DropDownList1Button16 Left Button" or
						queueIndex == 9 and "/click [nocombat]DropDownList1Button18 Left Button" or
						queueIndex == 10 and "/click [nocombat]DropDownList1Button20 Left Button" or
						queueIndex == 11 and "/click [nocombat]DropDownList1Button22 Left Button" or
						queueIndex == 12 and "/click [nocombat]DropDownList1Button24 Left Button"
					)

					if(queueSystem.queueFrames[mapName]) then
						
						queueSystem.queueFrames[mapName].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
						queueSystem.queueFrames[mapName].CancelApplication:SetAttribute("macrotext1", currentDeclineButton)

					end

					queueIndex = queueIndex + 1
					

				end
			elseif ( status == "confirm" ) then
				
				local currentDeclineButton = queueIndex == 1 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button3 Left Button"
				or queueIndex == 2 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button6 Left Button"
				or queueIndex == 3 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button9 Left Button"
				or queueIndex == 4 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button12 Left Button"
				or queueIndex == 5 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button15 Left Button"
				or queueIndex == 6 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button18 Left Button"
				or queueIndex == 7 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button21 Left Button"
				or queueIndex == 8 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button24 Left Button"
				or queueIndex == 9 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button27 Left Button"
				or queueIndex == 10 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button30 Left Button"
				or queueIndex == 11 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button33 Left Button"
				or queueIndex == 12 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button36 Left Button"
				

				local currentAcceptButton = queueIndex == 1 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button2 Left Button"
				or queueIndex == 2 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button4 Left Button"
				or queueIndex == 3 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button6 Left Button"
				or queueIndex == 4 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button8 Left Button"
				or queueIndex == 5 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button10 Left Button"
				or queueIndex == 6 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button12 Left Button"
				or queueIndex == 7 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button14 Left Button"
				or queueIndex == 8 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button16 Left Button"
				or queueIndex == 9 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button18 Left Button"
				or queueIndex == 10 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button20 Left Button"
				or queueIndex == 11 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button22 Left Button"
				or queueIndex == 12 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button24 Left Button"

				local frame = miog.createInviteFrame(frameData)
				frame.activeIndex = i
				frame.Decline:SetAttribute("type", "macro") -- left click causes macro
				--frame.Decline = Mixin(frame.Decline, PVPReadyDialogLeaveButtonMixin)
				--frame.Decline:SetAttribute("macrotext1", currentDeclineButton)

				frame.Accept:SetAttribute("type", "macro") -- left click causes macro
				frame.Accept:SetAttribute("macrotext1", currentAcceptButton)

				if(allowsDecline) then
					frame.Decline:Show()

				else
					frame.Decline:Hide()
				
				end

				gotInvite = true
			elseif ( status == "active" ) then
				if (mapName) then
					--local hasLongDescription = longDescription and longDescription ~= "";
					--local text = hasLongDescription and longDescription or nil;
					--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS, text);
				else
					--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS);
				end
			elseif ( status == "locked" ) then
				--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_LOCKED, QUEUED_STATUS_LOCKED_EXPLANATION);
			else
				--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_UNKNOWN);
			end
		elseif(status) then
		
		end
	end

	--Try all World PvP queues
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID, expireTime, averageWaitTime, queuedTime, suspended = GetWorldPVPQueueStatus(i)
		if ( status and status ~= "none" ) then
			--QueueStatusEntry_SetUpWorldPvP(entry, i);
			local frameData = {
				[1] = true,
				[2] = "World PvP",
				[11] = mapName,
				[12] = averageWaitTime,
				[17] = {"queued", queuedTime},
				[18] = mapName,
				[20] = "interface/icons/inv_currency_petbattle.blp"
			}
	
			if (status == "queued") then
				miog.createQueueFrame(frameData)
	
				if(queueSystem.queueFrames["PETBATTLE"]) then
					queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("type", "macro")
					queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")
	
				end
	
				queueIndex = queueIndex + 1
	
			elseif(status == "proposal") then
				local frame = miog.createInviteFrame(frameData)
				frame.Decline:SetAttribute("type", "macro")
				frame.Decline:SetAttribute("macrotext1", "/run C_PetBattles.DeclineQueuedPVPMatch()")
	
				frame.Accept:SetAttribute("type", "macro")
				frame.Accept:SetAttribute("macrotext1", "/run QueueStatusDropDown_AcceptQueuedPVPMatch()")
			
			end
		end
	end

	--World PvP areas we're currently in
	if ( CanHearthAndResurrectFromArea() ) then
		--QueueStatusEntry_SetUpActiveWorldPVP(entry);
	end

	--Pet Battle PvP Queue
	local pbStatus, estimate, queued = C_PetBattles.GetPVPMatchmakingInfo();
	if ( pbStatus ) then
		local frameData = {
			[1] = true,
			[2] = "",
			[11] = "Pet Battle",
			[12] = estimate,
			[17] = {"queued", queued},
			[18] = "PETBATTLE",
			[20] = miog.C.STANDARD_FILE_PATH .. "/infoIcons/petbattle.png"
		}

		if (pbStatus == "queued") then
			miog.createQueueFrame(frameData)

			if(queueSystem.queueFrames["PETBATTLE"]) then
				queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("type", "macro")
				queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")

			end

			queueIndex = queueIndex + 1

		elseif(pbStatus == "proposal") then
			local frame = miog.createInviteFrame(frameData)
			frame.Decline:SetAttribute("type", "macro")
			frame.Decline:SetAttribute("macrotext1", "/run C_PetBattles.DeclineQueuedPVPMatch()")

			frame.Accept:SetAttribute("type", "macro")
			frame.Accept:SetAttribute("macrotext1", "/run QueueStatusDropDown_AcceptQueuedPVPMatch()")
		
		end
	end

	--miog.inviteBox:SetShown(gotInvite)
end)