local addonName, miog = ...
local wticc = WrapTextInColorCode

local queuedList = {};

local queueSystem = {}
queueSystem.queueFrames = {}
queueSystem.currentlyInUse = 0

local frameQueue = {}

local queueFrameIndex = 0

local function resetQueueFrame(_, frame)
	frame:Hide()
	frame.layoutIndex = nil

	local objectType = frame:GetObjectType()

	if(objectType == "Frame") then
		frame:SetScript("OnMouseDown", nil)
		frame:SetScript("OnEnter", nil)
		frame.Name:SetText("")
		frame.Name:SetTextColor(1,1,1,1)
		frame.Age:SetText("")

		if(frame.Age.Ticker) then
			frame.Age.Ticker:Cancel()
			frame.Age.Ticker = nil
		end

		frame:ClearBackdrop()

		
		frame.CancelApplication:Show()

		frame.Icon:SetTexture(nil)

		frame.Wait:SetText("Wait")
	end

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()
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

	queueFrame:SetWidth(miog.MainTab.QueueInformation.Panel:GetWidth() - 7)
	
	--queueFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	queueFrame.Name:SetText(queueInfo[11])

	local ageNumber = 0

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

	if(queueInfo[20]) then
		queueFrame.Icon:SetTexture(queueInfo[20])
	end

	queueFrame.Wait:SetText("(" .. (queueInfo[12] ~= -1 and miog.secondsToClock(queueInfo[12] or 0) or "N/A") .. ")")

	queueFrame:SetShown(true)

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()

	return queueFrame
end

local function checkQueues()
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
					local inParty, joined, isQueued, noPartialClear, achievements, lfgComment, slotCount, categoryID2, leader, tank, healer, dps, x1, x2, x3, x4 = GetLFGInfoServer(categoryID, queueID);
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

					local frame

					if(hasData) then
						frame = createQueueFrame(frameData)

						if(categoryID == 3 and activeID == queueID) then
							queueSystem.queueFrames[queueID].ActiveIDFrame:Show()

						else
							queueSystem.queueFrames[queueID].ActiveIDFrame:Hide()
						
						end

						--queueSystem.queueFrames[queueID].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
						--queueSystem.queueFrames[queueID].CancelApplication:SetAttribute("macrotext1", "/run LeaveSingleLFG(" .. categoryID .. "," .. queueID .. ")")
						queueSystem.queueFrames[queueID].CancelApplication:SetScript("OnClick", function()
							LeaveSingleLFG(categoryID, queueID)
						end)

					else
						frameData[17] = nil
						frame = createQueueFrame(frameData)

					end

					frame:SetScript("OnEnter", function(self)
						local tooltip = GameTooltip
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
						local mapInfo = miog.MAP_INFO[mapID]
						--local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
						--local activityInfo = C_LFGList.GetActivityInfoTable(miog.MAP_INFO[mapID].activityID);
						local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)
						--local allowsCrossFaction = (categoryInfo and categoryInfo.allowCrossFaction) and (activityInfo and activityInfo.allowCrossFaction);

						local memberCounts = {TANK = totalTanks, HEALER = totalHealers, DAMAGER = totalDPS}
						tooltip:SetText(name, 1, 1, 1, true);

						--[[if (searchResultInfo.playstyle > 0) then
							local playstyleString = C_LFGList.GetPlaystyleString(searchResultInfo.playstyle, activityInfo);
							if(not searchResultInfo.crossFactionListing and allowsCrossFaction) then
								GameTooltip_AddColoredLine(tooltip, GROUP_FINDER_CROSS_FACTION_LISTING_WITH_PLAYSTLE:format(playstyleString,  FACTION_STRINGS[searchResultInfo.leaderFactionGroup]), GREEN_FONT_COLOR);
							else
								GameTooltip_AddColoredLine(tooltip, playstyleString, GREEN_FONT_COLOR);
							end
						elseif(not searchResultInfo.crossFactionListing and allowsCrossFaction) then
							GameTooltip_AddColoredLine(tooltip, GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE:format(FACTION_STRINGS[searchResultInfo.leaderFactionGroup]), GREEN_FONT_COLOR);
						end]]
						--[[if ( searchResultInfo.comment and searchResultInfo.comment == "" and searchResultInfo.questID ) then
							searchResultInfo.comment = LFGListUtil_GetQuestDescription(searchResultInfo.questID);
						end
						if ( searchResultInfo.comment ~= "" ) then
							tooltip:AddLine(string.format(LFG_LIST_COMMENT_FORMAT, searchResultInfo.comment), LFG_LIST_COMMENT_FONT_COLOR.r, LFG_LIST_COMMENT_FONT_COLOR.g, LFG_LIST_COMMENT_FONT_COLOR.b, true);
						end
						tooltip:AddLine(" ");
						if ( searchResultInfo.requiredDungeonScore > 0 ) then
							tooltip:AddLine(GROUP_FINDER_MYTHIC_RATING_REQ_TOOLTIP:format(searchResultInfo.requiredDungeonScore));
						end
						if ( searchResultInfo.requiredPvpRating > 0 ) then
							tooltip:AddLine(GROUP_FINDER_PVP_RATING_REQ_TOOLTIP:format(searchResultInfo.requiredPvpRating));
						end
						if ( searchResultInfo.requiredItemLevel > 0 ) then
							if(activityInfo.isPvpActivity) then
								tooltip:AddLine(LFG_LIST_TOOLTIP_ILVL_PVP:format(searchResultInfo.requiredItemLevel));
							else
								tooltip:AddLine(LFG_LIST_TOOLTIP_ILVL:format(searchResultInfo.requiredItemLevel));
							end
						end
						if ( activityInfo.useHonorLevel and searchResultInfo.requiredHonorLevel > 0 ) then
							tooltip:AddLine(LFG_LIST_TOOLTIP_HONOR_LEVEL:format(searchResultInfo.requiredHonorLevel));
						end
						if ( searchResultInfo.voiceChat ~= "" ) then
							tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_VOICE_CHAT, searchResultInfo.voiceChat), nil, nil, nil, true);
						end
						if ( searchResultInfo.requiredItemLevel > 0 or (activityInfo.useHonorLevel and searchResultInfo.requiredHonorLevel > 0) or searchResultInfo.voiceChat ~= "" or  searchResultInfo.requiredDungeonScore > 0 or searchResultInfo.requiredPvpRating > 0 ) then
							tooltip:AddLine(" ");
						end

						if ( searchResultInfo.leaderName ) then
							local factionString = searchResultInfo.leaderFactionGroup and FACTION_STRINGS[searchResultInfo.leaderFactionGroup];
							if(factionString and (UnitFactionGroup("player") ~= PLAYER_FACTION_GROUP[searchResultInfo.leaderFactionGroup])) then
								tooltip:AddLine(LFG_LIST_TOOLTIP_LEADER_FACTION:format(searchResultInfo.leaderName, factionString))
							else
								tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_LEADER, searchResultInfo.leaderName));
							end
						end]]

						--[[if( activityInfo.isRatedPvpActivity and searchResultInfo.leaderPvpRatingInfo) then
							GameTooltip_AddNormalLine(tooltip, PVP_RATING_GROUP_FINDER:format(searchResultInfo.leaderPvpRatingInfo.activityName, searchResultInfo.leaderPvpRatingInfo.rating, PVPUtil.GetTierName(searchResultInfo.leaderPvpRatingInfo.tier)));
						elseif ( isMythicPlusActivity and searchResultInfo.leaderOverallDungeonScore) then
							local color = C_ChallengeMode.GetDungeonScoreRarityColor(searchResultInfo.leaderOverallDungeonScore);
							if(not color) then
								color = HIGHLIGHT_FONT_COLOR;
							end
							GameTooltip_AddNormalLine(tooltip, DUNGEON_SCORE_LEADER:format(color:WrapTextInColorCode(searchResultInfo.leaderOverallDungeonScore)));
						end

						if(activityInfo.isMythicPlusActivity and searchResultInfo.leaderDungeonScoreInfo) then
							local leaderDungeonScoreInfo = searchResultInfo.leaderDungeonScoreInfo;
							local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(leaderDungeonScoreInfo.mapScore);
							if (not color) then
								color = HIGHLIGHT_FONT_COLOR;
							end
							if(leaderDungeonScoreInfo.mapScore == 0) then
								GameTooltip_AddNormalLine(tooltip, DUNGEON_SCORE_PER_DUNGEON_NO_RATING:format(leaderDungeonScoreInfo.mapName, leaderDungeonScoreInfo.mapScore));
							elseif (leaderDungeonScoreInfo.finishedSuccess) then
								GameTooltip_AddNormalLine(tooltip, DUNGEON_SCORE_DUNGEON_RATING:format(leaderDungeonScoreInfo.mapName, color:WrapTextInColorCode(leaderDungeonScoreInfo.mapScore), leaderDungeonScoreInfo.bestRunLevel));
							else
								GameTooltip_AddNormalLine(tooltip, DUNGEON_SCORE_DUNGEON_RATING_OVERTIME:format(leaderDungeonScoreInfo.mapName, color:WrapTextInColorCode(leaderDungeonScoreInfo.mapScore), leaderDungeonScoreInfo.bestRunLevel));
							end
						end]]
						if(hasData) then
							if ( queuedTime > 0 ) then
								tooltip:AddLine(string.format("Queued for: |cffffffff%s|r", SecondsToTime(GetTime() - queuedTime, false, false, 1, false)));
							end

							if ( myWait > 0 ) then
								tooltip:AddLine(string.format("Estimated wait time: |cffffffff%s|r", SecondsToTime(myWait, false, false, 1, false)));
							end

							if ( averageWait > 0 ) then
								tooltip:AddLine(string.format("Average wait time: |cffffffff%s|r", SecondsToTime(averageWait, false, false, 1, false)));
							end


							tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, totalTanks + totalHealers + totalDPS - tankNeeds - healerNeeds - dpsNeeds, tankNeeds .. "/" .. totalTanks, healerNeeds .. "/" .. totalHealers, dpsNeeds .. "/" .. totalDPS));
						end

						--[[if ( searchResultInfo.leaderName or searchResultInfo.age > 0 ) then
							tooltip:AddLine(" ");
						end

						if ( activityInfo.displayType == Enum.LFGListDisplayType.ClassEnumerate ) then
							tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS_SIMPLE, searchResultInfo.numMembers));
							for i=1, searchResultInfo.numMembers do
								local role, class, classLocalized, specLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i);
								local classColor = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR;
								tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_CLASS_ROLE, classLocalized, specLocalized), classColor.r, classColor.g, classColor.b);
							end
						else
							tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, searchResultInfo.numMembers, memberCounts.TANK, memberCounts.HEALER, memberCounts.DAMAGER));
						end

						if ( searchResultInfo.numBNetFriends + searchResultInfo.numCharFriends + searchResultInfo.numGuildMates > 0 ) then
							tooltip:AddLine(" ");
							tooltip:AddLine(LFG_LIST_TOOLTIP_FRIENDS_IN_GROUP);
							tooltip:AddLine(LFGListSearchEntryUtil_GetFriendList(resultID), 1, 1, 1, true);
						end

						local completedEncounters = C_LFGList.GetSearchResultEncounterInfo(resultID);
						if ( completedEncounters and #completedEncounters > 0 ) then
							tooltip:AddLine(" ");
							tooltip:AddLine(LFG_LIST_BOSSES_DEFEATED);
							for i=1, #completedEncounters do
								tooltip:AddLine(completedEncounters[i], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
							end
						end

						autoAcceptOption = autoAcceptOption or LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE;

						if autoAcceptOption == LFG_LIST_UTIL_ALLOW_AUTO_ACCEPT_LINE and searchResultInfo.autoAccept then
							tooltip:AddLine(" ");
							tooltip:AddLine(LFG_LIST_TOOLTIP_AUTO_ACCEPT, LIGHTBLUE_FONT_COLOR:GetRGB());
						end

						if ( searchResultInfo.isDelisted ) then
							tooltip:AddLine(" ");
							tooltip:AddLine(LFG_LIST_ENTRY_DELISTED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
						end

						tooltip:Show();]]

						GameTooltip:Show()
					end)
					frame:SetScript("OnLeave", function()
						GameTooltip:Hide()
					end)
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

			--[[for categoryID, listEntry in ipairs(LFGQueuedForList) do
				for dungeonID, queued in pairs(listEntry) do
					if(queued == true) then
						--DevTools_Dump({GetLFGDungeonInfo(dungeonID)})
						--DevTools_Dump({})
						local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID)
	
						if (hasData and queuedTime and not queueSystem.queueFrames[dungeonID]) then
							createQueueFrame(categoryID, {GetLFGDungeonInfo(dungeonID)}, {GetLFGQueueStats(categoryID)})
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
			[2] = groupInfo or activityInfo.shortName,
			[11] = "YOUR LISTING",
			[12] = -1,
			[17] = {"duration", activeEntryInfo.duration},
			[18] = "YOURLISTING",
			[20] = miog.ACTIVITY_INFO[activeEntryInfo.activityID].icon or nil,
			[21] = -2
		}

		local queueFrame = createQueueFrame(frameData)

		if(activityInfo.groupFinderActivityGroupID == 0) then
			queueFrame.Icon:SetAtlas("Mobile-BonusIcon")
		end

		queueSystem.queueFrames["YOURLISTING"].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
		queueSystem.queueFrames["YOURLISTING"].CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.RemoveListing()")
		queueSystem.queueFrames["YOURLISTING"]:SetScript("OnMouseDown", function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)
		end)

		--createQueueFrame(categoryID, {GetLFGDungeonInfo(activeID)}, {GetLFGQueueStats(categoryID)})
	end

	--Try LFGList applications
	local applications = C_LFGList.GetApplications()
	if(applications) then
		for _, v in ipairs(applications) do
		--for i=1, #apps do
			local id, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(v)

			if(id) then
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
						[21] = id
					}

					if(appStatus == "applied") then
						local frame = createQueueFrame(frameData)
						--queueSystem.queueFrames[identifier].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
						--queueSystem.queueFrames[identifier].CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.CancelApplication(" .. id .. ")")
						queueSystem.queueFrames[identifier].CancelApplication:SetScript("OnClick", function()
							C_LFGList.CancelApplication(id)
						end)
						queueSystem.queueFrames[identifier]:SetScript("OnMouseDown", function()
							PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
							LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)
							LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, activityInfo.categoryID, activityInfo.filters, LFGListFrame.baseFilters)
							LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
							LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
						end)

						if(miog.isGroupEligible(id) == false) then
							frame.Name:SetTextColor(1, 0, 0, 1)

						end

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
						createQueueFrame(frameData)
						queueSystem.queueFrames[mapName].CancelApplication:Hide()
						--queueSystem.queueFrames[mapName].CancelApplication:SetScript("OnClick",  SecureActionButton_OnClick)
					end

					--[[local currentDeclineButton = "/click QueueStatusButton RightButton" .. "\r\n" ..
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

					queueIndex = queueIndex + 1]]
					

				end
			elseif ( status == "confirm" ) then
				
				--[[local currentDeclineButton = queueIndex == 1 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button3 Left Button"
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
				or queueIndex == 12 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button24 Left Button"]]

			
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
	--[[for i=1, MAX_WORLD_PVP_QUEUES do
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
				createQueueFrame(frameData)
	
				if(queueSystem.queueFrames["PETBATTLE"]) then
					--queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("type", "macro")
					--queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")
					queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetScript("OnClick", function()
						C_PetBattles.StopPVPMatchmaking()
					end)
	
				end
	
				queueIndex = queueIndex + 1
	
			elseif(status == "proposal") then
				
			
			end
		end
	end]]

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
			createQueueFrame(frameData)

			if(queueSystem.queueFrames["PETBATTLE"]) then
				--queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("type", "macro")
				--queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")
				queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetScript("OnClick", function()
					C_PetBattles.StopPVPMatchmaking()
				end)

			end

			queueIndex = queueIndex + 1

		elseif(pbStatus == "proposal") then
		
		end
	end

	--miog.inviteBox:SetShown(gotInvite)
end

local function startNewGroup(categoryFrame)
	LFGListEntryCreation_ClearAutoCreateMode(LFGListFrame.EntryCreation);

	local isDifferentCategory = LFGListFrame.CategorySelection.selectedCategory ~= categoryFrame.categoryID
	local isSeparateCategory = C_LFGList.GetLfgCategoryInfo(categoryFrame.categoryID).separateRecommended

	LFGListFrame.CategorySelection.selectedCategory = categoryFrame.categoryID
	LFGListFrame.CategorySelection.selectedFilters = categoryFrame.filters

	LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryFrame.categoryID, categoryFrame.filters, LFGListFrame.baseFilters)

	LFGListEntryCreation_SetBaseFilters(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters)

	--LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters, LFGListFrame.CategorySelection.selectedCategory);
	
	miog.initializeActivityDropdown(isDifferentCategory, isSeparateCategory)
end

local function findGroup(categoryFrame)
	LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)
	
	LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, categoryFrame.categoryID, categoryFrame.filters)
	LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryFrame.categoryID, categoryFrame.filters, LFGListFrame.baseFilters)

	LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
end

hooksecurefunc("LFGListSearchPanel_SetCategory", function()
	miog.searchPanel.categoryID = LFGListFrame.SearchPanel.categoryID
	miog.searchPanel.filters = LFGListFrame.SearchPanel.filters
	miog.searchPanel.preferredFilters = LFGListFrame.SearchPanel.preferredFilters
end)

miog.loadQueueSystem = function()
	queueSystem.framePool = CreateFramePool("Frame", miog.MainTab.QueueInformation.Panel.ScrollFrame.Container, "MIOG_QueueFrame", resetQueueFrame)
	hooksecurefunc(QueueStatusFrame, "Update", checkQueues)

	local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_QueueEventReceiver")

	eventReceiver:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	eventReceiver:RegisterEvent("LFG_UPDATE")
	eventReceiver:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
	eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
	eventReceiver:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
	eventReceiver:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
	eventReceiver:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventReceiver:SetScript("OnEvent", miog.queueEvents)
end

local function updateRandomDungeons()
	local queueDropDown = miog.MainTab.QueueInformation.DropDown
	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil

	if(queueDropDown.entryFrameTree[1]) then
		queueDropDown:ReleaseSpecificFrames("random", queueDropDown.entryFrameTree[1].List)
	end
	
	if(queueDropDown.entryFrameTree[2]) then
		queueDropDown:ReleaseSpecificFrames("random", queueDropDown.entryFrameTree[2].List)
	end

	for i=1, GetNumRandomDungeons() do
		local id, name, typeID, subtypeID, _, _, _, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon = GetLFGRandomDungeonInfo(i)
		
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if((isAvailableForPlayer or not hideIfNotJoinable)) then
			if(isAvailableForAll) then
				local mode = GetLFGMode(1, id)
				info.text = isHolidayDungeon and "(Event) " .. name or name

				info.checked = mode == "queued"
				info.icon = miog.MAP_INFO[id] and miog.MAP_INFO[id].icon or miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or nil
				info.parentIndex = subtypeID
				info.index = 1
				info.type2 = "random"

				info.func = function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, id);
					JoinSingleLFG(1, id);
				end
				
				local tempFrame = queueDropDown:CreateEntryFrame(info)
				tempFrame:SetScript("OnShow", function(self)
					local tempMode = GetLFGMode(1, id)
					self.Radio:SetChecked(tempMode == "queued")
					
				end)
			end
		end
	end
end

miog.updateRandomDungeons = updateRandomDungeons

local function updateDungeons()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueInformation.DropDown
	if(queueDropDown.entryFrameTree[1].List.framePool) then
		queueDropDown.entryFrameTree[1].List.framePool:ReleaseAll()
	end

	if(queueDropDown.entryFrameTree[2].List.framePool) then
		queueDropDown.entryFrameTree[2].List.framePool:ReleaseAll()
	end

	if(queueDropDown.entryFrameTree[3].List.framePool) then
		queueDropDown.entryFrameTree[3].List.framePool:ReleaseAll()
	end

	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil

	local dungeonList = GetLFDChoiceOrder() or {}

	for _, dungeonID in ipairs(dungeonList) do
---@diagnostic disable-next-line: redundant-parameter
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID);
		local name, typeID, subtypeID, _, _, _, _, _, expLevel, groupID, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(dungeonID)

		local groupActivityID = miog.MAP_ID_TO_GROUP_ACTIVITY_ID[mapID]

		if(groupActivityID and not miog.GROUP_ACTIVITY[groupActivityID]) then
			miog.GROUP_ACTIVITY[groupActivityID] = {mapID = mapID, file = fileID}
		end

		local isFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID)

		if((isAvailableForPlayer or not hideIfNotJoinable) and (subtypeID and difficultyID < 3 and not isFollowerDungeon or isFollowerDungeon)) then
			if(isAvailableForAll) then
				local mode = GetLFGMode(1, dungeonID)
				info.text = isHolidayDungeon and "(Event) " .. name or name
				info.checked = mode == "queued"
				info.icon = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[dungeonID] and miog.LFG_ID_INFO[dungeonID].icon or fileID or nil
				info.parentIndex = isFollowerDungeon and 3 or subtypeID
				info.func = function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, dungeonID);
					JoinSingleLFG(1, dungeonID);

				end

				local tempFrame = queueDropDown:CreateEntryFrame(info)
				tempFrame:SetScript("OnShow", function(self)
					local tempMode = GetLFGMode(1, dungeonID)
					self.Radio:SetChecked(tempMode == "queued")
					
				end)
			end
		end
	end

	--DevTools_Dump(miog.GROUP_ID_TO_LFG_ID)
end

miog.updateDungeons = updateDungeons

local function updateRaidFinder()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	if(queueDropDown.entryFrameTree[4] and queueDropDown.entryFrameTree[4].List.framePool) then
		queueDropDown.entryFrameTree[4].List.framePool:ReleaseAll()
	end

	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil
	info.parentIndex = 4

	local nextLevel = nil;
	local playerLevel = UnitLevel("player")

	for rfIndex=1, GetNumRFDungeons() do
		local id, name, typeID, subtypeID, minLevel, maxLevel, _, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon = GetRFDungeonInfo(rfIndex)
---@diagnostic disable-next-line: redundant-parameter
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if((isAvailableForPlayer or not hideIfNotJoinable)) then
			if(isAvailableForAll) then
				if (playerLevel >= minLevel and playerLevel <= maxLevel) then
					local mode = GetLFGMode(3, id)
					info.text = isHolidayDungeon and "(Event) " .. name or name
					info.checked = mode == "queued"
					info.icon = miog.MAP_INFO[id] and miog.MAP_INFO[id].icon or miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or nil
					info.func = function()
						--JoinSingleLFG(1, dungeonID)
						ClearAllLFGDungeons(3);
						SetLFGDungeon(3, id);
						--JoinLFG(LE_LFG_CATEGORY_RF);
						JoinSingleLFG(3, id);
					end
					
					local tempFrame = queueDropDown:CreateEntryFrame(info)
					tempFrame:SetScript("OnShow", function(self)
						local tempMode = GetLFGMode(3, id)
						self.Radio:SetChecked(tempMode == "queued")
						
					end)

					nextLevel = nil

				elseif ( playerLevel < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
					nextLevel = minLevel

				end
			end
		end
	end
end

miog.updateRaidFinder = updateRaidFinder

local function checkIfCanQueue()
	local HonorFrame = HonorFrame;
	local canQueue;
	local arenaID;
	local isBrawl;
	local isSpecialBrawl;

	if ( HonorFrame.type == "specific" ) then
		if ( HonorFrame.SpecificScrollBox.selectionID ) then
			canQueue = true;
		end
	elseif ( HonorFrame.type == "bonus" ) then
		if ( HonorFrame.BonusFrame.selectedButton ) then
			canQueue = HonorFrame.BonusFrame.selectedButton.canQueue;
			arenaID = HonorFrame.BonusFrame.selectedButton.arenaID;
			isBrawl = HonorFrame.BonusFrame.selectedButton.isBrawl;
			isSpecialBrawl = HonorFrame.BonusFrame.selectedButton.isSpecialBrawl;
		end
	end

	local disabledReason;

	if arenaID then
		local battlemasterListInfo = C_PvP.GetSkirmishInfo(arenaID);
		if battlemasterListInfo then
			local groupSize = GetNumGroupMembers();
			local minPlayers = battlemasterListInfo.minPlayers;
			local maxPlayers = battlemasterListInfo.maxPlayers;
			if groupSize > maxPlayers then
				canQueue = false;
				disabledReason = PVP_ARENA_NEED_LESS:format(groupSize - maxPlayers);
			elseif groupSize < minPlayers then
				canQueue = false;
				disabledReason = PVP_ARENA_NEED_MORE:format(minPlayers - groupSize);
			end
		end
	end

	return canQueue
end

local function updatePvP()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	if(queueDropDown.entryFrameTree[5].List.securePool) then
		queueDropDown.entryFrameTree[5].List.securePool:ReleaseAll()
	end

	if(queueDropDown.entryFrameTree[5].List.framePool) then
		queueDropDown.entryFrameTree[5].List.framePool:ReleaseAll()
	end
	local groupSize = IsInGroup() and GetNumGroupMembers() or 1;

	local token, loopMax, generalTooltip;
	if (groupSize > (MAX_PARTY_MEMBERS + 1)) then
		token = "raid";
		loopMax = groupSize;
	else
		token = "party";
		loopMax = groupSize - 1; -- player not included in party tokens, just raid tokens
	end
	
	local maxLevel = GetMaxLevelForLatestExpansion();
	for i = 1, loopMax do
		if ( not UnitIsConnected(token..i) ) then
			generalTooltip = PVP_NO_QUEUE_DISCONNECTED_GROUP
			break;
		elseif ( UnitLevel(token..i) < maxLevel ) then
			generalTooltip = PVP_NO_QUEUE_GROUP
			break;
		end
	end

	local info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = PVP_RATED_SOLO_SHUFFLE

	local minItemLevel = C_PvP.GetRatedSoloShuffleMinItemLevel()
	local _, _, playerPvPItemLevel = GetAverageItemLevel();
	info.disabled = playerPvPItemLevel < minItemLevel
	info.icon = miog.findBrawlIconByName("Solo Shuffle")
	info.tooltipOnButton = true
	info.tooltipWhileDisabled = true
	info.type2 = "rated"
	info.tooltipTitle = "Unable to queue for this activity."
	info.tooltipText = generalTooltip or format(_G["INSTANCE_UNAVAILABLE_SELF_PVP_GEAR_TOO_LOW"], "", minItemLevel, playerPvPItemLevel);
	info.func = nil
	--info.func = function()
	--	JoinRatedSoloShuffle()
	-- end
	

	local soloFrame = queueDropDown:CreateEntryFrame(info)
	soloFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.RatedSoloShuffle, soloFrame)
	
	soloFrame:SetScript("OnShow", function(self)
		--local tempMode = GetLFGMode(1, dungeonID)
		--self.Radio:SetChecked(tempMode == "queued")
		
	end)

	info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = ARENA_BATTLES_2V2
	info.icon = miog.findBattlegroundIconByName("Arena (2v2)")
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 2 and string.format(PVP_ARENA_NEED_LESS, groupSize - 2) or groupSize < 2 and string.format(PVP_ARENA_NEED_MORE, 2 - groupSize)
	info.disabled = groupSize ~= 2
	--info.func = function()
	--	JoinArena()
	--end

	local twoFrame = queueDropDown:CreateEntryFrame(info)
	twoFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.Arena2v2, twoFrame)

	info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = ARENA_BATTLES_3V3
	info.icon = miog.findBattlegroundIconByName("Arena (3v3)")
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 3 and string.format(PVP_ARENA_NEED_LESS, groupSize - 3) or groupSize < 3 and string.format(PVP_ARENA_NEED_MORE, 3 - groupSize)
	info.disabled = generalTooltip or groupSize ~= 3
	--info.func = function()
	--	JoinArena()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local threeFrame = queueDropDown:CreateEntryFrame(info)
	threeFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.Arena3v3, threeFrame)

	info = {}
	info.level = 2
	info.parentIndex = 5
	info.text = PVP_RATED_BATTLEGROUNDS
	info.icon = miog.findBattlegroundIconByName("Rated Battlegrounds")
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 10 and string.format(PVP_RATEDBG_NEED_LESS, groupSize - 10) or groupSize < 10 and string.format(PVP_RATEDBG_NEED_MORE, 10 - groupSize)
	info.disabled = generalTooltip or groupSize ~= 10
	--info.func = function()
	--	JoinRatedBattlefield()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local tenFrame = queueDropDown:CreateEntryFrame(info)
	tenFrame:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")
	queueDropDown:CreateExtraButton(ConquestFrame.RatedBG, tenFrame)

	for index = 1, 5, 1 do
		local currentBGQueue = index == 1 and C_PvP.GetRandomBGInfo() or index == 2 and C_PvP.GetRandomEpicBGInfo() or index == 3 and C_PvP.GetSkirmishInfo(4) or index == 4 and C_PvP.GetAvailableBrawlInfo() or index == 5 and C_PvP.GetSpecialEventBrawlInfo()

		if(currentBGQueue and (index == 3 or currentBGQueue.canQueue)) then
			info = {}
			info.text = index == 1 and RANDOM_BATTLEGROUNDS or index == 2 and RANDOM_EPIC_BATTLEGROUND or index == 3 and "Skirmish" or currentBGQueue.name
			info.entryType = "option"
			info.checked = false
			--info.disabled = index == 1 or index == 2
			info.icon = index < 3 and miog.findBattlegroundIconByID(currentBGQueue.bgID) or index == 3 and currentBGQueue.icon or index > 3 and (miog.findBrawlIconByID(currentBGQueue.brawlID) or miog.findBrawlIconByName(currentBGQueue.name))
			info.level = 2
			info.parentIndex = 5
			info.type2 = "unrated"
			info.func = nil
			info.disabled = index ~= 3 and currentBGQueue.canQueue == false or index == 3 and not HonorFrame.BonusFrame.Arena1Button.canQueue

			-- UIDropDownMenu_AddButton(info, level)
			local tempFrame = queueDropDown:CreateEntryFrame(info)

			if(currentBGQueue.bgID) then
				if(currentBGQueue.bgID == 32) then
					tempFrame:SetAttribute("macrotext1", "/click HonorFrameQueueButton")
					queueDropDown:CreateExtraButton(HonorFrame.BonusFrame.RandomBGButton, tempFrame)
					

				elseif(currentBGQueue.bgID == 901) then
					--tempFrame:SetAttribute("macrotext1", "/click [nocombat] HonorFrame.BonusFrame.RandomEpicBGButton" .. "\r\n" .. "/click [nocombat] HonorFrameQueueButton")
					tempFrame:SetAttribute("macrotext1", "/click HonorFrameQueueButton")
					queueDropDown:CreateExtraButton(HonorFrame.BonusFrame.RandomEpicBGButton, tempFrame)

				end

				tempFrame:SetAttribute("original", tempFrame:GetAttribute("macrotext1"))
			else
				if(index == 3) then
					--JoinSkirmish(4)
					tempFrame:SetAttribute("macrotext1", "/run JoinSkirmish(4)")


				elseif(index == 4) then
					tempFrame:SetAttribute("macrotext1", "/run C_PvP.JoinBrawl()")
					--C_PvP.JoinBrawl()

				elseif(index == 5) then
					tempFrame:SetAttribute("macrotext1", "/run C_PvP.JoinBrawl(true)")
					--C_PvP.JoinBrawl(true)
				
				end
			end
		end

	end

	

	
end

miog.updatePvP = updatePvP

local function updateDropDown()
	if(miog.F.QUEUE_STOP == true) then
		miog.F.UPDATE_QUEUE_DROPDOWN = true
		
	else
		---@diagnostic disable-next-line: undefined-field
		local queueDropDown = miog.MainTab.QueueInformation.DropDown
		queueDropDown:ResetDropDown()

		local info = {}
		info.text = "Dungeons (Normal)"
		info.hasArrow = true
		info.level = 1
		info.index = 1
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = "Dungeons (Heroic)"
		info.hasArrow = true
		info.level = 1
		info.index = 2
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = "Follower"
		info.hasArrow = true
		info.level = 1
		info.index = 3
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = "Raid Finder"
		info.hasArrow = true
		info.level = 1
		info.index = 4
		queueDropDown:CreateEntryFrame(info)

		--[[info.text = "PvP"
		info.hasArrow = true
		info.level = 1
		info.index = 5
		queueDropDown:CreateEntryFrame(info)]]

		info = {}
		info.text = "Pet Battle"
		info.checked = false
		info.entryType = "option"
		info.level = 1
		info.value = "PETBATTLEQUEUEBUTTON"
		info.index = 6
		info.func = function()
			C_PetBattles.StartPVPMatchmaking()
		end

		local tempFrame = queueDropDown:CreateEntryFrame(info)
		tempFrame:SetScript("OnShow", function(self)
			local pbStatus = C_PetBattles.GetPVPMatchmakingInfo()
			self.Radio:SetChecked(pbStatus ~= nil)
			
		end)

		info.entryType = "option"
		info.level = 2
		info.index = nil

		updateRandomDungeons()
		updateDungeons()
		updateRaidFinder()
		--updatePvP()

		info = {}
		info.level = 1
		info.hasArrow = true
		--info.text = LFG_LIST_MORE
		info.text = "PVP (Stock UI)"
		-- info.checked = false
		--info.tooltipText = generalTooltip or groupSize > 10 and string.format(PVP_RATEDBG_NEED_LESS, groupSize - 10) or groupSize < 10 and string.format(PVP_RATEDBG_NEED_MORE, 10 - groupSize)
		--info.disabled = generalTooltip or groupSize ~= 10
		info.type2 = "more"
		info.disabled = nil
		--info.func = function()i
		--	JoinRatedBattlefield()
		--end

		-- UIDropDownMenu_AddButton(info, level)
		local moreFrame = queueDropDown:CreateEntryFrame(info)
		--[[moreFrame:SetAttribute("macrotext1", "/run PVEFrame_ShowFrame(\"PVPUIFrame\", \"HonorFrame\")" .. "\r\n" .. "/run HonorFrame.BonusFrame.Arena1Button:ClearAllPoints()" .. "\r\n" .. 
		"/run HonorFrame.BonusFrame.Arena1Button:SetPoint(\"LEFT\", HonorFrame.BonusFrame, \"LEFT\", (HonorFrame.BonusFrame:GetWidth() - HonorFrame.BonusFrame.Arena1Button:GetWidth()) / 2, 0)")]]

		--moreFrame:SetAttribute("macrotext1", "/run PVEFrame_ShowFrame(\"PVPUIFrame\", \"HonorFrame\")")
		moreFrame:SetScript("OnClick", function()
			PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")
		end)
	
	end
end

local function queueEvents(_, event, ...)
	if(event == "LFG_UPDATE_RANDOM_INFO") then
		--miog.updateRandomDungeons()
		updateDropDown()

	elseif(event == "LFG_UPDATE") then

	elseif(event == "LFG_LOCK_INFO_RECEIVED") then
		--miog.updateRaidFinder()
		--miog.updateDungeons()
		updateDropDown()
		
	elseif(event == "PVP_BRAWL_INFO_UPDATED") then
		updateDropDown()

	elseif(event == "LFG_LIST_AVAILABILITY_UPDATE") then
		updateDropDown()

		if(C_LFGList.HasActiveEntryInfo() and not miog.entryCreation:IsVisible()) then
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)

			startNewGroup({categoryID = activityInfo.categoryID, filters = activityInfo.filters})
		end

		local lastFrame = nil

		for k, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
			local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);

			if(not _G["MythicIOGrabber_" .. categoryInfo.name .. "Button"]) then

				local categoryFrame = CreateFrame("Button", "MythicIOGrabber_" .. categoryInfo.name .. "Button", miog.MainTab.CategoryPanel, "MIOG_MenuButtonTemplate")
				categoryFrame.categoryID = categoryID
				categoryFrame.filters = categoryID == 1 and 4 or Enum.LFGListFilter.Recommended

				miog.createFrameBorder(categoryFrame, 1, CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())

				categoryFrame:SetHeight(30)
				categoryFrame:SetPoint("TOPLEFT", lastFrame or miog.MainTab.CategoryPanel, lastFrame and "BOTTOMLEFT" or "TOPLEFT", 0, k == 1 and -50 or -3)
				categoryFrame:SetPoint("TOPRIGHT", lastFrame or miog.MainTab.CategoryPanel, lastFrame and "BOTTOMRIGHT" or "TOPRIGHT", 0, k == 1 and -50 or -3)
				categoryFrame.Title:SetText(categoryInfo.name)
				categoryFrame.BackgroundImage:SetVertTile(true)
				categoryFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], nil, "CLAMPTOBLACKADDITIVE")
				
				categoryFrame.StartGroup:SetScript("OnClick", function(self)
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
					local button = self:GetParent()
					startNewGroup(button)

					LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.EntryCreation);
				end)
				categoryFrame.FindGroup:SetScript("OnClick", function(self)
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
					local button = self:GetParent()
					findGroup(button)

					LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
				end)
			
				lastFrame = categoryFrame
		
				if categoryInfo.separateRecommended then
					local notRecommendedFrame = CreateFrame("Button", "MythicIOGrabber_" .. LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, true) .. "Button", miog.MainTab.CategoryPanel, "MIOG_MenuButtonTemplate")
					notRecommendedFrame.categoryID = categoryID
					notRecommendedFrame.filters = Enum.LFGListFilter.NotRecommended

					miog.createFrameBorder(notRecommendedFrame, 1, CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())

					notRecommendedFrame:SetHeight(30)
					notRecommendedFrame:SetPoint("TOPLEFT", lastFrame or miog.MainTab.CategoryPanel, lastFrame and "BOTTOMLEFT" or "TOPLEFT", 0, k == 1 and 0 or -3)
					notRecommendedFrame:SetPoint("TOPRIGHT", lastFrame or miog.MainTab.CategoryPanel, lastFrame and "BOTTOMRIGHT" or "TOPRIGHT", 0, k == 1 and 0 or -3)
					notRecommendedFrame.Title:SetText(LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, true))
					notRecommendedFrame.BackgroundImage:SetVertTile(true)
					notRecommendedFrame.BackgroundImage:SetHorizTile(true)
					notRecommendedFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
					notRecommendedFrame.StartGroup:SetScript("OnClick", function(self)
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
						local button = self:GetParent()
						startNewGroup(button)

						LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.EntryCreation);
					end)
					notRecommendedFrame.FindGroup:SetScript("OnClick", function(self)
						PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
						local button = self:GetParent()
						findGroup(button)

						LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
					end)
			
					lastFrame = notRecommendedFrame
				end
			end	
		end
	elseif(event == "GROUP_ROSTER_UPDATE") then
		--updateDropDown()
		
	elseif(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.UPDATE_QUEUE_DROPDOWN) then
			updateDropDown()

		end
	end
end

miog.queueEvents = queueEvents