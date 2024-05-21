local addonName, miog = ...
local wticc = WrapTextInColorCode

local queuedList = {};

local queueSystem = {}
queueSystem.queueFrames = {}
queueSystem.currentlyInUse = 0

local frameQueue = {}

local queueFrameIndex = 1
local randomBGFrame, randomEpicBGFrame, skirmish, brawl1, brawl2, specificBox

function MIOG_GetCurrentDropdownButton(queueIndex)
	return _G["DropDownList1Button" .. (queueIndex * 2)]

end

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
		frame.Background:SetTexture(nil)

		if(frame.Age.Ticker) then
			frame.Age.Ticker:Cancel()
			frame.Age.Ticker = nil
		end

		frame:ClearBackdrop()
		
		--frame.CancelApplication:SetScript("OnClick", nil)
		--frame.CancelApplication:SetScript("OnEnter", nil)
		frame.CancelApplication:RegisterForClicks("LeftButtonDown")
		frame.CancelApplication:SetAttribute("type", nil)
		frame.CancelApplication:SetAttribute("macrotext1", nil)
		frame.CancelApplication:Show()

		--frame.Icon:SetTexture(nil)

		frame.Wait:SetText("Wait")
	end

	--frame.Icon:Hide()

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()
end

local function createQueueFrame(queueInfo)
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
		queueFrame.Background:SetTexture(queueInfo[30])

	end

	queueFrame.Age:SetText(miog.secondsToClock(ageNumber or 0))

	--if(queueInfo[20]) then
		--queueFrame.Icon:SetTexture(queueInfo[20])
	--end

	queueFrame.Wait:SetText("(" .. (queueInfo[12] ~= -1 and miog.secondsToClock(queueInfo[12] or 0) or "N/A") .. ")")

	queueFrame:SetShown(true)

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()

	return queueFrame
end

local function checkQueues()
	queueSystem.queueFrames = {}
	queueSystem.framePool:ReleaseAll()

	local queueIndex = 1

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
						[2] = isFollowerDungeon and "Follower" or subtypeID == 1 and "Normal" or subtypeID == 2 and "Heroic" or subtypeID == 3 and "Raid Finder",
						[11] = isSpecificQueue and MULTIPLE_DUNGEONS or name,
						[12] = myWait,
						[17] = {"queued", queuedTime},
						[18] = queueID,
						[20] = miog.DIFFICULTY_ID_INFO[difficulty] and miog.DIFFICULTY_ID_INFO[difficulty].isLFR and fileID
						or mapID and miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[queueID] and miog.LFG_ID_INFO[queueID].icon or fileID or miog.findBattlegroundIconByName(name) or miog.findBrawlIconByName(name) or nil,
						[30] = (isSpecificQueue or mapID == nil) and miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dungeon.png" or miog.MAP_INFO[mapID].horizontal
					}

					local frame

					if(not hasData) then
						frameData[17] = nil
					end

					frame = createQueueFrame(frameData)

					if(hasData) then
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

					end

					frame:SetScript("OnEnter", function(self)
						local tooltip = GameTooltip
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
						local mapInfo = miog.MAP_INFO[mapID]

						--DevTools_Dump(mapInfo)
						--local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
						--local activityInfo = C_LFGList.GetActivityInfoTable(miog.MAP_INFO[mapID].activityID);
						local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)
						--local allowsCrossFaction = (categoryInfo and categoryInfo.allowCrossFaction) and (activityInfo and activityInfo.allowCrossFaction);

						local memberCounts = {TANK = totalTanks, HEALER = totalHealers, DAMAGER = totalDPS}
						tooltip:SetText(isSpecificQueue and MULTIPLE_DUNGEONS or name, 1, 1, 1, true);

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
							if(name2 and name ~= name2) then
								tooltip:AddLine(name2)
								
							end

							GameTooltip_AddBlankLineToTooltip(GameTooltip)

							if ( queuedTime > 0 ) then
								tooltip:AddLine(string.format("Queued for: |cffffffff%s|r", SecondsToTime(GetTime() - queuedTime, false, false, 1, false)));
							end

							if ( myWait > 0 ) then
								tooltip:AddLine(string.format("Estimated wait time: |cffffffff%s|r", SecondsToTime(myWait, false, false, 1, false)));
							end

							if ( averageWait > 0 ) then
								tooltip:AddLine(string.format("Average wait time: |cffffffff%s|r", SecondsToTime(averageWait, false, false, 1, false)));
							end

							tooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, totalTanks + totalHealers + totalDPS - tankNeeds - healerNeeds - dpsNeeds, totalTanks - tankNeeds, totalHealers - healerNeeds, totalDPS - dpsNeeds));

							if(isSpecificQueue) then
								GameTooltip_AddBlankLineToTooltip(GameTooltip)

								tooltip:AddLine(QUEUED_FOR_SHORT)

								table.sort(specificQueueDungeons, function(k1, k2)
									if(k1.difficulty == k2.difficulty) then
										return k1.dungeonID < k2.dungeonID
									end

									return k1.difficulty < k2.difficulty
								end)

								for k, v in ipairs(specificQueueDungeons) do
									tooltip:AddLine(v.difficulty .. " " .. v.name)

								end
							end

						else
							tooltip:AddLine(WrapTextInColorCode("Still waiting for data from Blizzard...", miog.CLRSCC.red));
						
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
			[21] = -2,
			[30] = activityInfo.groupFinderActivityGroupID == 0 and miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dungeon.png" or miog.ACTIVITY_INFO[activeEntryInfo.activityID] and miog.ACTIVITY_INFO[activeEntryInfo.activityID].horizontal or nil
		}

		local frame = createQueueFrame(frameData)

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
						[21] = id,
						[30] = miog.ACTIVITY_INFO[searchResultInfo.activityID] and miog.ACTIVITY_INFO[searchResultInfo.activityID].horizontal or nil
					}

					if(appStatus == "applied") then
						local frame = createQueueFrame(frameData)

						--[[frame.CancelApplication:SetScript("OnClick", function()
							C_LFGList.CancelApplication(id)
						end)]]

						frame.CancelApplication:SetAttribute("type", "macro")
						frame.CancelApplication:SetAttribute("macrotext1", "/run C_LFGList.CancelApplication(" .. id .. ")")

						frame:SetScript("OnMouseDown", function()
							PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
							--LFGListSearchPanel_Clear(LFGListFrame.SearchPanel)
							LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, activityInfo.categoryID, LFGListFrame.SearchPanel.preferredFilters, LFGListFrame.baseFilters)

							if(LFGListFrame.SearchPanel.filters == nil) then
								LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
							end
							
							LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
						end)

						local eligible, reason = miog.isGroupEligible(id, true)

						if(eligible == false) then
							frame.Name:SetTextColor(1, 0, 0, 1)

							if(reason) then
								frame.Name:SetText(frame.Name:GetText() .. " - " .. reason[2])
							end
						end

						frame:SetScript("OnEnter", function(self)
							miog.createResultTooltip(id, frame)

							GameTooltip:Show()
						end)
						frame:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)

						queueIndex = queueIndex + 1
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

			local frame

			if (mapName and queuedTime) then
				frame = createQueueFrame(frameData)
				--frame.CancelApplication:Hide()

				local mapIDTable = miog.findBattlegroundMapIDsByName(mapName) or miog.findBrawlMapIDsByName(mapName)

				--local battleInfo = miog.BATTLEMASTER_INFO[v[1]]

				if(mapIDTable and #mapIDTable > 0) then
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

				if(mapName == "Random Epic Battleground") then
					frame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/epicbgs.png")

				end
				
				--queueSystem.queueFrames[mapName].CancelApplication:SetScript("OnClick",  SecureActionButton_OnClick)
			end

			
			if (frame and status == "queued" ) then
				if ( suspend ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_SUSPENDED);
				else
					--QueueStatusEntry_SetFullDisplay(entry, mapName, queuedTime, estimatedTime, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText, assignedSpec);


					--local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
					--local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);

					--		1		2			3			4			5			6			7				8		9				10				11				12			13			14			15		16			17
					--local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime

					------
					---- CHECK IF SECURE BUTTON IS NEEDED
					-----
					
					frame.CancelApplication:SetAttribute("type", "macro")
					frame.CancelApplication:SetAttribute("macrotext1", "/click QueueStatusButton RightButton" .. "\r\n" .. "/click " .. MIOG_GetCurrentDropdownButton(queueIndex):GetDebugName() .." LeftButton")

					queueIndex = queueIndex + 1
					

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
			[20] = miog.C.STANDARD_FILE_PATH .. "/infoIcons/petbattle.png",
			[30] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/petbattle.png",
		}

		if (pbStatus == "queued") then
			local frame = createQueueFrame(frameData)
			--frame.Icon:Show()

			if(frame) then
				--queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("type", "macro")
				--queueSystem.queueFrames["PETBATTLE"].CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")
				--[[frame.CancelApplication:SetScript("OnClick", function()
					C_PetBattles.StopPVPMatchmaking()
				end)]]

				frame.CancelApplication:SetAttribute("type", "macro")
				frame.CancelApplication:SetAttribute("macrotext1", "/run C_PetBattles.StopPVPMatchmaking()")

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
	
	LFGListFrame.CategorySelection.selectedCategory = categoryFrame.categoryID
	LFGListFrame.CategorySelection.selectedFilters = categoryFrame.filters

	LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, categoryFrame.categoryID, categoryFrame.filters, LFGListFrame.baseFilters)

	LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
end

hooksecurefunc("LFGListSearchPanel_SetCategory", function()
	miog.SearchPanel.categoryID = LFGListFrame.SearchPanel.categoryID
	miog.SearchPanel.filters = LFGListFrame.SearchPanel.filters
	miog.SearchPanel.preferredFilters = LFGListFrame.SearchPanel.preferredFilters
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

	hooksecurefunc("HonorFrameTypeDropDown_OnClick", function(self)
		randomBGFrame:SetShown(self.value == "bonus")
		randomEpicBGFrame:SetShown(self.value == "bonus")

		specificBox:SetShown(self.value == "specific")
		specificBox:GetParent():MarkDirty()
	end)
end

local function updateRandomDungeons()
	local queueDropDown = miog.MainTab.QueueInformation.DropDown
	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil

	for i=1, GetNumRandomDungeons() do
		local id, name, typeID, subtypeID, _, _, _, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon = GetLFGRandomDungeonInfo(i)
		
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if((isAvailableForPlayer or not hideIfNotJoinable)) then
			if(isAvailableForAll) then
				local mode = GetLFGMode(1, id)
				info.text = isHolidayDungeon and "(Event) " .. name or name

				info.checked = mode == "queued"
				info.icon = miog.MAP_INFO[id] and miog.MAP_INFO[id].icon or miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or miog.LFG_DUNGEONS_INFO[id] and miog.LFG_DUNGEONS_INFO[id].expansionLevel and miog.EXPANSION_INFO[miog.LFG_DUNGEONS_INFO[id].expansionLevel][3] or nil
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

local function sortAndAddDungeonList(list, enableOnShow)
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	table.sort(list, function(k1, k2)
		return k1.text < k2.text
	end)

	for k, v in pairs(list) do
		local tempFrame = queueDropDown:CreateEntryFrame(v)

		if(enableOnShow) then
			tempFrame:SetScript("OnShow", function(self)
				local tempMode = GetLFGMode(1, v.id)
				self.Radio:SetChecked(tempMode == "queued")
				
			end)
		end
	end
end

local function updateDungeons(overwrittenParentIndex)
	local dungeonList = GetLFDChoiceOrder() or {}

	local normalDungeonList = {}
	local heroicDungeonList = {}
	local followerDungeonList = {}

	-- local mythicDungeonList (we can only hope)

	LFGEnabledList = GetLFDChoiceEnabledState(LFGEnabledList)

	local selectedDungeonsList = {}

	for _, dungeonID in pairs(dungeonList) do
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID);
		local name, typeID, subtypeID, _, _, _, _, _, expLevel, groupID, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(dungeonID)

		local groupActivityID = miog.MAP_ID_TO_GROUP_ACTIVITY_ID[mapID]

		if(groupActivityID and not miog.GROUP_ACTIVITY[groupActivityID]) then
			miog.GROUP_ACTIVITY[groupActivityID] = {mapID = mapID, file = fileID}
		end

		local isFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID)

		if((isAvailableForPlayer or not hideIfNotJoinable) and (subtypeID and difficultyID < 3 and not isFollowerDungeon or isFollowerDungeon and overwrittenParentIndex == nil)) then
			if(isAvailableForAll) then
				local info = {}
				info.entryType = "option"
				info.level = 2
				info.id = dungeonID
				info.index = nil

				info.text = isHolidayDungeon and "(Event) " .. name or name

				info.icon = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[dungeonID] and miog.LFG_ID_INFO[dungeonID].icon or fileID or nil

				info.parentIndex = overwrittenParentIndex or isFollowerDungeon and 3 or subtypeID

				if(overwrittenParentIndex) then
					info.func = function(self)
						local value = not self.Radio:GetChecked()
						
						selectedDungeonsList[dungeonID] = value == true and dungeonID or nil
						LFGEnabledList[dungeonID] = selectedDungeonsList[dungeonID]
					end
				else
					info.func = function()
						ClearAllLFGDungeons(1);
						SetLFGDungeon(1, dungeonID);
						JoinSingleLFG(1, dungeonID);

					end
				end

				if(subtypeID == 1) then
					normalDungeonList[#normalDungeonList + 1] = info

				elseif(subtypeID == 2) then
					heroicDungeonList[#heroicDungeonList + 1] = info

				else
					followerDungeonList[#followerDungeonList + 1] = info

				end
			end
		end
	end


	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	if(overwrittenParentIndex) then
		queueDropDown:CreateTextLine(nil, overwrittenParentIndex, "Normal")

	end

	sortAndAddDungeonList(normalDungeonList, overwrittenParentIndex == nil)


	if(overwrittenParentIndex) then
		queueDropDown:CreateTextLine(nil, overwrittenParentIndex, "Heroic")

	end

	sortAndAddDungeonList(heroicDungeonList, overwrittenParentIndex == nil)

	if(overwrittenParentIndex == nil) then
		sortAndAddDungeonList(followerDungeonList, true)
	
	else
		queueDropDown:CreateFunctionButton(nil, overwrittenParentIndex, "Queue for multiple dungeons", function()
			LFG_JoinDungeon(1, "specific", selectedDungeonsList, {})
		end)
	
	end
end

miog.updateDungeons = updateDungeons

local function updateRaidFinder()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil
	info.parentIndex = 5

	local nextLevel = nil;
	local playerLevel = UnitLevel("player")

	local lastRaidName

	for rfIndex = 1, GetNumRFDungeons() do
		local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, raidName, minGearLevel, isScaling, mapID = GetRFDungeonInfo(rfIndex)
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if((isAvailableForPlayer or not hideIfNotJoinable)) then
			if(isAvailableForAll) then
				if (playerLevel >= minLevel and playerLevel <= maxLevel) then
					local encounters;
					local numEncounters = GetLFGDungeonNumEncounters(id);
					for j = 1, numEncounters do
						local bossName, _, isKilled = GetLFGDungeonEncounterInfo(id, j);
						local colorCode = "";
						if ( isKilled ) then
							colorCode = RED_FONT_COLOR_CODE;
						end
						if encounters then
							encounters = encounters.."|n"..colorCode..bossName..FONT_COLOR_CODE_CLOSE;
						else
							encounters = colorCode..bossName..FONT_COLOR_CODE_CLOSE;
						end
					end
					
					local modifiedInstanceTooltipText = "";
					local icon = nil

					if(mapID) then
						local modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(mapID)

						if (modifiedInstanceInfo) then
							icon = GetFinalNameFromTextureKit("%s-small", modifiedInstanceInfo.uiTextureKit);
							modifiedInstanceTooltipText = "|n|n" .. modifiedInstanceInfo.description;

						else
						
						end

						--info.iconXOffset = -6;
					end


					if(lastRaidName ~= raidName) then

						local textLine = queueDropDown:CreateTextLine(nil, info.parentIndex, miog.MAP_INFO[mapID].shortName, icon)

						if(icon) then
							textLine:SetTextColor(0.1,0.83,0.77,1)

						end

					end

					local mode = GetLFGMode(3, id)
					info.text = isHolidayDungeon and "(Event) " .. name or name
					info.checked = mode == "queued"
					--info.index = rfIndex
					info.icon = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or nil
					info.func = function()
						ClearAllLFGDungeons(3);
						SetLFGDungeon(3, id);
						JoinSingleLFG(3, id);
					end
					
					local tempFrame = queueDropDown:CreateEntryFrame(info)

					tempFrame:SetScript("OnShow", function(self)
						local tempMode = GetLFGMode(3, id)
						self.Radio:SetChecked(tempMode == "queued")
						
					end)

					tempFrame:HookScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
						GameTooltip:SetText(RAID_BOSSES)
						GameTooltip:AddLine(encounters .. modifiedInstanceTooltipText, 1, 1, 1, true)
						GameTooltip:Show()
					end)

					tempFrame:HookScript("OnLeave", function()
						GameTooltip:Hide()
					end)

					if(icon) then
						tempFrame.Name:SetTextColor(0.1,0.83,0.77,1)
					end


					nextLevel = nil

					lastRaidName = raidName

				elseif ( playerLevel < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
					nextLevel = minLevel

				end
			end
		end
	end
end

miog.updateRaidFinder = updateRaidFinder

local function hideAllPVPButtonAssets(button)
	if(button.Tier) then
		button.Tier:ClearAllPoints()
		button.Tier:SetSize(20, 20)
		button.Tier:SetPoint("LEFT", button, "LEFT")
		button.Tier:Hide()

		button.TierIcon:ClearAllPoints()
		button.TierIcon:SetSize(5, 5)
		button.TierIcon:SetPoint("CENTER", button.Tier, "CENTER")
		button.TierIcon:Hide()
	end

	if(button.TeamSizeText) then
		button.TeamSizeText:ClearAllPoints()
		button.TeamSizeText:SetPoint("LEFT", button.Tier, "RIGHT")
		button.TeamSizeText:SetFont(miog.FONTS["libMono"], 11, "OUTLINE")
	end

	if(button.TeamTypeText) then
		button.TeamTypeText:ClearAllPoints()
		button.TeamTypeText:SetPoint("LEFT", button.TeamSizeText, "RIGHT")
		button.TeamTypeText:SetFont(miog.FONTS["libMono"], 11, "OUTLINE")
	end

	if(button.CurrentRating) then
		button.CurrentRating:Hide()
	end

	if(button.Title) then
		button.Title:ClearAllPoints()
		button.Title:SetPoint("LEFT", button, "LEFT", 20, 0)
		button.Title:SetFont(miog.FONTS["libMono"], 11, "OUTLINE")

	end

	button.Reward:Hide()
end

local function updatePVP2()
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

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
	info.entryType = "option"
	info.index = 1
	info.level = 2
	info.parentIndex = 6
	hideAllPVPButtonAssets(ConquestFrame.RatedSoloShuffle)
	local soloFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.RatedSoloShuffle)
	soloFrame:HookScript("OnShow", function(self)
		hideAllPVPButtonAssets(self)
	end)
	--ConquestFrame.RatedSoloShuffle:SetAttribute("type", "macro")
	--ConquestFrame.RatedSoloShuffle:SetAttribute("macrotext1", "/click [nocombat] ConquestJoinButton")

	info = {}
	info.entryType = "option"
	info.index = 2
	info.level = 2
	info.parentIndex = 6
	hideAllPVPButtonAssets(ConquestFrame.Arena2v2)
	local twosFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.Arena2v2)
	twosFrame:HookScript("OnShow", function(self)
		hideAllPVPButtonAssets(self)
	end)

	info = {}
	info.entryType = "option"
	info.index = 3
	info.level = 2
	info.parentIndex = 6
	hideAllPVPButtonAssets(ConquestFrame.Arena3v3)
	local threesFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.Arena3v3)
	threesFrame:HookScript("OnShow", function(self)
		hideAllPVPButtonAssets(self)
	end)

	info = {}
	info.entryType = "option"
	info.index = 4
	info.level = 2
	info.parentIndex = 6
	hideAllPVPButtonAssets(ConquestFrame.RatedBG)
	local ratedBGFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.RatedBG)
	ratedBGFrame:HookScript("OnShow", function(self)
		hideAllPVPButtonAssets(self)
	end)

	info = {}
	info.entryType = "option"
	info.index = 5
	info.level = 2
	info.parentIndex = 6
	--hideAllPVPButtonAssets(ConquestFrame.Arena2v2)
	queueDropDown:InsertCustomFrame(info, ConquestFrame.JoinButton)

	--[[soloFrame:SetScript("OnClick", function()
		--PVEFrame_ShowFrame("PVPUIFrame", "ConquestFrame")
		ConquestJoinButton:Click()

		--HideUIPanel(PVEFrame)
	end)]]

	--SlickDropDown:CreateExtraButton(ConquestFrame.RatedSoloShuffle, soloFrame)

	--info.func = function()
	--	JoinArena()
	--end

	--HonorFrame.BonusFrame.Arena1Button:Hide()
	--HonorFrame.BonusFrame.BrawlButton:Hide()
	--HonorFrame.BonusFrame.BrawlButton2:Hide()

	info = {}
	info.entryType = "option"
	info.index = 10
	info.level = 2
	info.parentIndex = 6
	HonorFrameTypeDropDown:SetHeight(20)
	local dropdown = queueDropDown:InsertCustomFrame(info, HonorFrameTypeDropDown)
	dropdown.topPadding = 8
	dropdown.bottomPadding = 8
	dropdown.leftPadding = -15
	UIDropDownMenu_SetWidth(HonorFrameTypeDropDown, 190)
	dropdown:SetHeight(20)

	for index = 1, 5, 1 do
		local currentBGQueue = index == 1 and C_PvP.GetRandomBGInfo() or index == 2 and C_PvP.GetRandomEpicBGInfo() or index == 3 and C_PvP.GetSkirmishInfo(4) or index == 4 and C_PvP.GetAvailableBrawlInfo() or index == 5 and C_PvP.GetSpecialEventBrawlInfo()

		if(currentBGQueue and (index == 3 or currentBGQueue.canQueue)) then
			info = {}
			info.text = index == 1 and RANDOM_BATTLEGROUNDS or index == 2 and RANDOM_EPIC_BATTLEGROUND or index == 3 and SKIRMISH or currentBGQueue.name
			info.entryType = "option"
			info.checked = false
			info.index = index == 1 and 11 or index == 2 and 12 or index + 4
			--info.disabled = index == 1 or index == 2
			info.icon = index < 3 and miog.findBattlegroundIconByID(currentBGQueue.bgID) or index == 3 and currentBGQueue.icon or index > 3 and (miog.findBrawlIconByID(currentBGQueue.brawlID) or miog.findBrawlIconByName(currentBGQueue.name))
			info.level = 2
			info.parentIndex = 6
			info.disabled = index ~= 3 and currentBGQueue.canQueue == false or index == 3 and not HonorFrame.BonusFrame.Arena1Button.canQueue

			if(currentBGQueue.bgID) then
				if(currentBGQueue.bgID == 32) then
					hideAllPVPButtonAssets(HonorFrame.BonusFrame.RandomBGButton)
					randomBGFrame = queueDropDown:InsertCustomFrame(info, HonorFrame.BonusFrame.RandomBGButton)
					randomBGFrame:HookScript("OnShow", function(self)
						hideAllPVPButtonAssets(self)
						self:SetHeight(20)
					end)

				elseif(currentBGQueue.bgID == 901) then
					hideAllPVPButtonAssets(HonorFrame.BonusFrame.RandomEpicBGButton)
					randomEpicBGFrame = queueDropDown:InsertCustomFrame(info, HonorFrame.BonusFrame.RandomEpicBGButton)
					randomEpicBGFrame:HookScript("OnShow", function(self)
						hideAllPVPButtonAssets(self)
						self:SetHeight(20)
					end)

				end
			else
				if(index == 3) then
					--JoinSkirmish(4)
					--tempFrame:SetAttribute("macrotext1", "/run JoinSkirmish(4)")

					info.func = function()
						JoinSkirmish(4)
					end

					--info.tooltipTitle = info.text
					--info.tooltip = info.text

					skirmish = queueDropDown:CreateEntryFrame(info)
					skirmish:SetScript("OnEnter", function(self)
						PVPCasualActivityButton_OnEnter(self)
					end)
					skirmish.tooltipTableKey = "Skirmish"

				elseif(index == 4) then
					--tempFrame:SetAttribute("macrotext1", "/run C_PvP.JoinBrawl()")
					--C_PvP.JoinBrawl()

					info.func = function()
						C_PvP.JoinBrawl()
					end

					--info.tooltipTitle = info.text
					--info.tooltip = info.text
					
					brawl1 = queueDropDown:CreateEntryFrame(info)
					brawl1:SetScript("OnEnter", function(self)
						PVPCasualActivityButton_OnEnter(self)
					end)
					brawl1.tooltipTableKey = "Brawl"

				elseif(index == 5) then
					--tempFrame:SetAttribute("macrotext1", "/run C_PvP.JoinBrawl(true)")
					--C_PvP.JoinBrawl(true)

					info.func = function()
						C_PvP.JoinBrawl(true)
					end
					
					brawl2 = queueDropDown:CreateEntryFrame(info)

					brawl2:SetScript("OnEnter", function(self)
						PVPCasualActivityButton_OnEnter(self)
					end)
					brawl2.tooltipTableKey = "SpecialEventBrawl"
					--info.tooltipTitle = info.text
					--info.tooltip = info.text
				
				end
			end
		end
	end

	info = {}
	info.entryType = "option"
	info.index = 15
	info.level = 2
	info.parentIndex = 6
	specificBox = queueDropDown:InsertCustomFrame(info, HonorFrame.SpecificScrollBox)
	specificBox.leftPadding = -3
	specificBox:SetHeight(120)

	HonorFrame.SpecificScrollBar:ClearAllPoints()
	HonorFrame.SpecificScrollBar:SetPoint("TOPLEFT", HonorFrame.SpecificScrollBox, "TOPRIGHT", -10, 0)
	HonorFrame.SpecificScrollBar:SetPoint("BOTTOMLEFT", HonorFrame.SpecificScrollBox, "BOTTOMRIGHT", -10, 0)
	HonorFrame.SpecificScrollBar:SetParent(HonorFrame.SpecificScrollBox)

	randomBGFrame:SetShown(HonorFrame.type == "bonus")
	randomEpicBGFrame:SetShown(HonorFrame.type == "bonus")

	specificBox:SetShown(HonorFrame.type == "specific")
	specificBox:GetParent():MarkDirty()

	--[[info = {}
	info.entryType = "option"
	info.index = 15
	info.level = 2
	info.parentIndex = 6
	hideAllPVPButtonAssets(ConquestFrame.RatedBG)
	local specific1 = queueDropDown:InsertCustomFrame(info, ConquestFrame.RatedBG)
	ratedBGFrame:HookScript("OnShow", function(self)
		hideAllPVPButtonAssets(self)
	end)]]

	info = {}
	info.entryType = "option"
	info.index = 30
	info.level = 2
	info.parentIndex = 6
	--hideAllPVPButtonAssets(ConquestFrame.Arena2v2)
	queueDropDown:InsertCustomFrame(info, HonorFrame.QueueButton)
end

--[[local function updatePvP()
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

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
	info.parentIndex = 7
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
	info.parentIndex = 7
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
	info.parentIndex = 7
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
	info.parentIndex = 7
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

miog.updatePvP = updatePvP]]

local function updateDropDown()
	if(miog.F.QUEUE_STOP == true) then
		miog.F.UPDATE_QUEUE_DROPDOWN = true
		
	else
		local queueDropDown = miog.MainTab.QueueInformation.DropDown
		queueDropDown:ResetDropDown()

		queueDropDown.List.selfCheck = true

		local info = {}
		info.text = LFG_TYPE_DUNGEON
		info.hasArrow = true
		info.level = 1
		info.index = 1
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = LFG_TYPE_HEROIC_DUNGEON
		info.hasArrow = true
		info.level = 1
		info.index = 2
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = LFG_TYPE_FOLLOWER_DUNGEON
		info.hasArrow = true
		info.level = 1
		info.index = 3
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = SPECIFIC_DUNGEONS
		info.hasArrow = true
		info.level = 1
		info.index = 4
		info.hideOnClick = false
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = RAID_FINDER
		info.hasArrow = true
		info.level = 1
		info.index = 5
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = PLAYER_V_PLAYER
		info.hasArrow = true
		info.level = 1
		info.index = 6
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = PET_BATTLE_PVP_QUEUE
		info.checked = false
		info.entryType = "option"
		info.level = 1
		info.value = "PETBATTLEQUEUEBUTTON"
		info.index = 7
		info.func = function()
			C_PetBattles.StartPVPMatchmaking()
		end

		local tempFrame = queueDropDown:CreateEntryFrame(info)
		tempFrame:SetScript("OnShow", function(self)
			self.Radio:SetChecked(C_PetBattles.GetPVPMatchmakingInfo() ~= nil)
			
		end)

		--[[info = {}
		info.level = 1
		info.hasArrow = true
		info.text = "PVP (Stock UI)"
		info.type2 = "more"
		info.index = 8
		info.disabled = nil
		local moreFrame = queueDropDown:CreateEntryFrame(info)
		moreFrame:SetScript("OnClick", function()
			PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")
		end)]]

		info = {}
		info.entryType = "option"
		info.level = 2
		info.index = nil

		updateRandomDungeons()
		updateDungeons()
		updateDungeons(4)
		updateRaidFinder()
		updatePVP2()
		--updatePvP()
	
	end
end

local function queueEvents(_, event, ...)
	if(event == "LFG_UPDATE_RANDOM_INFO") then
		--miog.updateRandomDungeons()
		updateDropDown()

	elseif(event == "LFG_UPDATE") then

	elseif(event == "LFG_LOCK_INFO_RECEIVED") then
		updateDropDown()
		
	elseif(event == "PVP_BRAWL_INFO_UPDATED") then
		updateDropDown()

	elseif(event == "LFG_LIST_AVAILABILITY_UPDATE") then
		updateDropDown()

		if(C_LFGList.HasActiveEntryInfo() and not miog.EntryCreation:IsVisible()) then
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)

			startNewGroup({categoryID = activityInfo.categoryID, filters = activityInfo.filters})
		end

		local lastFrame = nil

		local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();

		local function showFailureReason(owner)
			GameTooltip:SetOwner(owner, "ANCHOR_TOPRIGHT")
			GameTooltip:SetText(failureReason)
			GameTooltip:Show()
		end

		for k, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
			local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);

			if(not _G["MythicIOGrabber_" .. categoryInfo.name .. "Button"]) then

				local categoryFrame = CreateFrame("Button", "MythicIOGrabber_" .. categoryInfo.name .. "Button", miog.MainTab.CategoryPanel, "MIOG_MenuButtonTemplate")
				categoryFrame.categoryID = categoryID
				categoryFrame.filters = categoryID == 1 and 4 or Enum.LFGListFilter.Recommended

				miog.createFrameBorder(categoryFrame, 1, CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())

				categoryFrame:SetHeight(30)
				categoryFrame:SetPoint("TOPLEFT", lastFrame or miog.MainTab.CategoryPanel, lastFrame and "BOTTOMLEFT" or "TOPLEFT", 0, k == 1 and -60 or -3)
				categoryFrame:SetPoint("TOPRIGHT", lastFrame or miog.MainTab.CategoryPanel, lastFrame and "BOTTOMRIGHT" or "TOPRIGHT", 0, k == 1 and -50 or -3)
				categoryFrame.Title:SetText(categoryInfo.name)
				categoryFrame.BackgroundImage:SetVertTile(true)
				categoryFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], nil, "CLAMPTOBLACKADDITIVE")
				categoryFrame.StartGroup.Icon:SetDesaturated(not canUse)
				categoryFrame.FindGroup.Icon:SetDesaturated(not canUse)

				if(not canUse) then
					categoryFrame.StartGroup:SetScript("OnEnter", function(self)
						showFailureReason(self)
					end)
					categoryFrame.StartGroup:SetScript("OnLeave", function(self)
						GameTooltip:Hide()
					end)

					categoryFrame.FindGroup:SetScript("OnEnter", function(self)
						showFailureReason(self)
					end)
					categoryFrame.FindGroup:SetScript("OnLeave", function(self)
						GameTooltip:Hide()
					end)

				else
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
				
				end
			
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
					notRecommendedFrame.StartGroup.Icon:SetDesaturated(not canUse)
					notRecommendedFrame.FindGroup.Icon:SetDesaturated(not canUse)

					if(not canUse) then
						notRecommendedFrame.StartGroup:SetScript("OnEnter", function(self)
							showFailureReason(self)
						end)
						notRecommendedFrame.StartGroup:SetScript("OnLeave", function(self)
							GameTooltip:Hide()
						end)
	
						notRecommendedFrame.FindGroup:SetScript("OnEnter", function(self)
							showFailureReason(self)
						end)
						notRecommendedFrame.FindGroup:SetScript("OnLeave", function(self)
							GameTooltip:Hide()
						end)
	
					else
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
					
					end
			
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