local addonName, miog = ...
local wticc = WrapTextInColorCode

local indices = {
	["EVENT"] = 1,
	["NORMAL"] = 2,
	["HEROIC"] = 3,
	["FOLLOWER"] = 4,
	["SPECIFIC"] = 5,
	["RAIDFINDER"] = 6,
	["PVP"] = 7,
	["PET"] = 8,
}

local function updateRandomDungeons(blizzDesc)
	--[[local queueDropDown = miog.MainTab.QueueInformation.DropDown
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
				info.icon = miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or miog.LFG_DUNGEONS_INFO[id] and miog.LFG_DUNGEONS_INFO[id].expansionLevel and miog.EXPANSION_INFO[miog.LFG_DUNGEONS_INFO[id].expansionLevel][3] or nil
				info.parentIndex = subtypeID
				info.index = -1
				info.type2 = "random"

				info.func = function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, id);
					JoinSingleLFG(1, id);

					GetLFGDungeonInfo

					MIOG_NewSettings.lastUsedQueue = {type = "pve", subtype="dng", id = id}
				end
				
				local tempFrame = queueDropDown:CreateEntryFrame(info)
				tempFrame:SetScript("OnShow", function(self)
					local tempMode = GetLFGMode(1, id)
					self.Radio:SetChecked(tempMode == "queued")
					
				end)

				blizzDesc[difficultyID] = blizzDesc[difficultyID] or {}
				blizzDesc[difficultyID][#blizzDesc[difficultyID]+1] = {name = name, id = id, icon = info.icon}
			end
		end
	end]]
end

miog.updateRandomDungeons = updateRandomDungeons

local function sortAndAddDungeonList(list, enableOnShow)
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	table.sort(list, function(k1, k2)
		if(k1.expansionLevel == k2.expansionLevel) then
			if(k1.type1 == k2.type1) then
				return k1.text < k2.text
			end

			return k1.type1 > k2.type1
		end

		return k1.expansionLevel > k2.expansionLevel
	end)

	local lastExp = nil

	for k, v in pairs(list) do
		if(lastExp and lastExp ~= v.expansionLevel) then
			--queueDropDown:CreateSeparator(nil, v.parentIndex)

		end

		local tempFrame = queueDropDown:CreateEntryFrame(v)

		if(#list == 1) then
			MIOG_TEMP = tempFrame
		end

		if(enableOnShow) then
			tempFrame:SetScript("OnShow", function(self)
				local tempMode = GetLFGMode(1, v.id)
				self.Radio:SetChecked(tempMode == "queued")
				
			end)
		end
		
		lastExp = v.expansionLevel
	end
end

local function updateDungeons(overwrittenParentIndex, blizzDesc)
	local dungeonList = GetLFDChoiceOrder() or {}

	local normalDungeonList = {}
	local heroicDungeonList = {}
	local followerDungeonList = {}
	local eventDungeonList = {}

	-- local mythicDungeonList (we can only hope)

	LFGEnabledList = GetLFDChoiceEnabledState(LFGEnabledList)

	local selectedDungeonsList = {}

	if(not overwrittenParentIndex) then
		for i=1, GetNumRandomDungeons() do
			local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expLevel, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon = GetLFGRandomDungeonInfo(i)
			
			local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);
			local isFollowerDungeon = id >= 0 and C_LFGInfo.IsLFGFollowerDungeon(id)

			if(isAvailableForPlayer or not hideIfNotJoinable) then

				if(isAvailableForAll) then
					local mode = GetLFGMode(1, id)

					local info = {}
					info.text = name

					info.checked = mode == "queued"
					info.icon = miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or miog.LFG_DUNGEONS_INFO[id] and miog.LFG_DUNGEONS_INFO[id].expansionLevel and miog.EXPANSION_INFO[miog.LFG_DUNGEONS_INFO[id].expansionLevel][3] or nil
					info.parentIndex = (isHolidayDungeon or isTimewalkingDungeon) and indices["EVENT"] or subtypeID == 1 and indices["NORMAL"] or subtypeID == 2 and indices["HEROIC"]
					info.type1 = typeID
					--info.index = -1
					info.expansionLevel = miog.LFG_DUNGEONS_INFO[id] and miog.LFG_DUNGEONS_INFO[id].expansionLevel or expLevel
					info.type2 = "random"

					info.func = function()
						ClearAllLFGDungeons(1);
						SetLFGDungeon(1, id);
						JoinSingleLFG(1, id);

						MIOG_NewSettings.lastUsedQueue = {type = "pve", subtype="dng", id = id}
					end
					
					--[[local tempFrame = queueDropDown:CreateEntryFrame(info)
					tempFrame:SetScript("OnShow", function(self)
						local tempMode = GetLFGMode(1, id)
						self.Radio:SetChecked(tempMode == "queued")
						
					end)]]

					blizzDesc[difficultyID] = blizzDesc[difficultyID] or {}
					blizzDesc[difficultyID][#blizzDesc[difficultyID]+1] = {name = name, id = id, icon = info.icon}

					if(isFollowerDungeon) then
						followerDungeonList[#followerDungeonList + 1] = info

					elseif(isHolidayDungeon or isTimewalkingDungeon) then
						eventDungeonList[#eventDungeonList + 1] = info
					
					elseif(subtypeID == 1) then
						normalDungeonList[#normalDungeonList + 1] = info

					elseif(subtypeID == 2) then
						heroicDungeonList[#heroicDungeonList + 1] = info

					end
				end
			end
		end
	end

	--table.insert(dungeonList, 1533)

	for _, dungeonID in pairs(dungeonList) do
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID);
		local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expLevel, groupID, fileID, difficultyID, maxPlayers, _, isHolidayDungeon, _, minPlayers, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(dungeonID)

		local isFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID)

		if((isAvailableForPlayer or (not hideIfNotJoinable and dungeonID ~= 1533)) and (subtypeID and (difficultyID < 3 or difficultyID == 33) and not isFollowerDungeon or isFollowerDungeon)) then

			if(isAvailableForAll) then
				local info = {}
				info.entryType = "option"
				info.level = 2
				info.id = dungeonID
				info.type1 = typeID
				info.expansionLevel = miog.MAP_INFO[mapID].expansionLevel or expLevel

				info.text = name

				info.icon = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or miog.LFG_ID_INFO[dungeonID] and miog.LFG_ID_INFO[dungeonID].icon or fileID or nil
				
				info.parentIndex = overwrittenParentIndex or isFollowerDungeon and indices["FOLLOWER"] or (isHolidayDungeon or isTimewalkingDungeon) and indices["EVENT"] or subtypeID == 1 and indices["NORMAL"] or subtypeID == 2 and indices["HEROIC"]

				if(overwrittenParentIndex) then
					info.func = function(self)
						selectedDungeonsList[dungeonID] = not selectedDungeonsList[dungeonID] and dungeonID or nil

						LFGEnabledList[dungeonID] = selectedDungeonsList[dungeonID]
					end
				else
					info.func = function()
						ClearAllLFGDungeons(1);
						SetLFGDungeon(1, dungeonID);
						JoinSingleLFG(1, dungeonID);

						MIOG_NewSettings.lastUsedQueue = {type = "pve", subtype="dng", id = dungeonID}

					end
				end

				blizzDesc[difficultyID] = blizzDesc[difficultyID] or {}
				blizzDesc[difficultyID][#blizzDesc[difficultyID]+1] = {name = name, id = dungeonID, icon = info.icon}

				if(isFollowerDungeon) then
					followerDungeonList[#followerDungeonList + 1] = info

				elseif(isHolidayDungeon or isTimewalkingDungeon) then
					eventDungeonList[#eventDungeonList + 1] = info

				elseif(subtypeID == 1) then
					normalDungeonList[#normalDungeonList + 1] = info

				elseif(subtypeID == 2) then
					heroicDungeonList[#heroicDungeonList + 1] = info

				end
			end
		end
	end

	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	if(not overwrittenParentIndex and #eventDungeonList > 0) then
		local info = {}
		info.text = EVENTS_LABEL
		info.hasArrow = true
		info.level = 1
		info.index = indices["EVENT"]
		queueDropDown:CreateEntryFrame(info)

		sortAndAddDungeonList(eventDungeonList, overwrittenParentIndex == nil)

	end

	if(overwrittenParentIndex) then
		if(#normalDungeonList > 0) then
			queueDropDown:CreateTextLine(nil, overwrittenParentIndex, LFG_TYPE_DUNGEON)
		end
	else
		local info = {}
		info.text = LFG_TYPE_DUNGEON
		info.hasArrow = true
		info.level = 1
		info.index = indices["NORMAL"]
		info.disabled = #normalDungeonList == 0
		queueDropDown:CreateEntryFrame(info)

	end

	sortAndAddDungeonList(normalDungeonList, overwrittenParentIndex == nil)

	if(overwrittenParentIndex) then
		if(#heroicDungeonList > 0) then
			queueDropDown:CreateTextLine(nil, overwrittenParentIndex, LFG_TYPE_HEROIC_DUNGEON)
		end
	else
		local info = {}
		info.text = LFG_TYPE_HEROIC_DUNGEON
		info.hasArrow = true
		info.level = 1
		info.index = indices["HEROIC"]
		info.disabled = #heroicDungeonList == 0
		queueDropDown:CreateEntryFrame(info)
	end

	sortAndAddDungeonList(heroicDungeonList, overwrittenParentIndex == nil)

	if(overwrittenParentIndex) then
		if(#followerDungeonList > 0) then
			queueDropDown:CreateTextLine(nil, overwrittenParentIndex, LFG_TYPE_FOLLOWER_DUNGEON)
		end
	else
		local info = {}
		info.text = LFG_TYPE_FOLLOWER_DUNGEON
		info.hasArrow = true
		info.level = 1
		info.index = indices["FOLLOWER"]
		info.disabled = #followerDungeonList == 0
		queueDropDown:CreateEntryFrame(info)
	end

	sortAndAddDungeonList(followerDungeonList, overwrittenParentIndex == nil)
	
	if(overwrittenParentIndex ~= nil) then
		queueDropDown:CreateFunctionButton(nil, overwrittenParentIndex, "Queue for multiple dungeons", function()
			LFG_JoinDungeon(1, "specific", selectedDungeonsList, {})

			MIOG_NewSettings.lastUsedQueue = {type = "pve", subtype="multidng", id = selectedDungeonsList}
		end)
	
	end
end

miog.updateDungeons = updateDungeons

local function IsRaidFinderDungeonDisplayable(id)
	local name, typeID, subtypeID, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(id);
	local myLevel = UnitLevel("player");
	return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel;
end

local function updateRaidFinder(blizzDesc)
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	local mainInfo = {}
	mainInfo.text = RAID_FINDER
	mainInfo.hasArrow = true
	mainInfo.level = 1
	mainInfo.index = indices["RAIDFINDER"]
	local raidFinderFrame = queueDropDown:CreateEntryFrame(mainInfo)

	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil
	info.parentIndex = indices["RAIDFINDER"]

	local nextLevel = nil;
	local playerLevel = UnitLevel("player")

	local lastRaidName

	local hasAnEntry = false

	for rfIndex = 1, GetNumRFDungeons() do
		local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansion, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, raidName, minGearLevel, isScaling, mapID = GetRFDungeonInfo(rfIndex)
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if( not hideIfNotJoinable or isAvailableForAll ) then
			if ( isAvailableForAll or isAvailableForPlayer or IsRaidFinderDungeonDisplayable(id) ) then
				if (playerLevel >= minLevel and playerLevel <= maxLevel) then
					hasAnEntry = true

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

						MIOG_NewSettings.lastUsedQueue = {type = "pve", subtype="raid", id = id}
					end
					
					local tempFrame = queueDropDown:CreateEntryFrame(info)

					tempFrame:SetScript("OnShow", function(self)
						local tempMode = GetLFGMode(3, id)
						self.Radio:SetChecked(tempMode == "queued")
						
					end)

					tempFrame:HookScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
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
					

					blizzDesc[difficultyID] = blizzDesc[difficultyID] or {}
					blizzDesc[difficultyID][#blizzDesc[difficultyID]+1] = {name = name, id = id, index = rfIndex, icon = info.icon}

					nextLevel = nil

					lastRaidName = raidName

				elseif ( playerLevel < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
					nextLevel = minLevel

				end
			end
		end
	end

	if(hasAnEntry == false) then
		queueDropDown:DisableSpecificFrame(raidFinderFrame)

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
		button.TeamSizeText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	end

	if(button.TeamTypeText) then
		button.TeamTypeText:ClearAllPoints()
		button.TeamTypeText:SetPoint("LEFT", button.TeamSizeText, "RIGHT")
		button.TeamTypeText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	end

	if(button.CurrentRating) then
		button.CurrentRating:Hide()
	end

	if(button.Title) then
		button.Title:ClearAllPoints()
		button.Title:SetPoint("LEFT", button, "LEFT", 20, 0)
		button.Title:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")

	end

	button.Reward:Hide()
end

local function resetPVPFrame(frame, parent, setScript)
	frame:ClearAllPoints()
	frame:SetParent(parent)
	frame:SetWidth(parent:GetWidth())
	frame:SetHeight(20)

	if(setScript) then
		hideAllPVPButtonAssets(frame)
		--frame:HookScript("OnShow", function(self)
		--end)
	end
end

local function updatePVP(parent)
	if(HonorFrame and ConquestFrame) then
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

		local soloFrame = ConquestFrame.RatedSoloShuffle
		resetPVPFrame(soloFrame, parent, true)
		soloFrame.layoutIndex = 1

		local twoFrame = ConquestFrame.Arena2v2
		resetPVPFrame(twoFrame, parent, true)
		twoFrame.layoutIndex = 2

		local threeFrame = ConquestFrame.Arena3v3
		resetPVPFrame(threeFrame, parent, true)
		threeFrame.layoutIndex = 3

		local ratedBGFrame = ConquestFrame.RatedBG
		resetPVPFrame(ratedBGFrame, parent, true)
		ratedBGFrame.layoutIndex = 4

		local conquestJoinButton = ConquestFrame.JoinButton
		resetPVPFrame(conquestJoinButton, parent, false)
		conquestJoinButton.layoutIndex = 5

		local honorDropdown = HonorFrameTypeDropdown
		resetPVPFrame(honorDropdown, parent, false)
		honorDropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -100)
		--honorDropdown.layoutIndex = 6

		
	end
end

local function updatePVP2()
	if(HonorFrame and ConquestFrame) then
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
		info.parentIndex = indices["PVP"]
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
		info.parentIndex = indices["PVP"]
		hideAllPVPButtonAssets(ConquestFrame.Arena2v2)
		local twosFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.Arena2v2)
		twosFrame:HookScript("OnShow", function(self)
			hideAllPVPButtonAssets(self)
		end)

		info = {}
		info.entryType = "option"
		info.index = 3
		info.level = 2
		info.parentIndex = indices["PVP"]
		hideAllPVPButtonAssets(ConquestFrame.Arena3v3)
		local threesFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.Arena3v3)
		threesFrame:HookScript("OnShow", function(self)
			hideAllPVPButtonAssets(self)
		end)

		info = {}
		info.entryType = "option"
		info.index = 4
		info.level = 2
		info.parentIndex = indices["PVP"]
		hideAllPVPButtonAssets(ConquestFrame.RatedBG)
		local ratedBGFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.RatedBG)
		ratedBGFrame:HookScript("OnShow", function(self)
			hideAllPVPButtonAssets(self)
		end)

		info = {}
		info.entryType = "option"
		info.index = 5
		info.level = 2
		info.parentIndex = indices["PVP"]
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
		info.parentIndex = indices["PVP"]
		HonorFrameTypeDropdown:SetHeight(20)
		local dropdown = queueDropDown:InsertCustomFrame(info, HonorFrameTypeDropdown)
		dropdown.topPadding = 8
		dropdown.bottomPadding = 8
		dropdown.leftPadding = 0
		--UIDropDownMenu_SetWidth(HonorFrameTypeDropdown, 190)
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
				info.parentIndex = indices["PVP"]
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
							MIOG_NewSettings.lastUsedQueue = {type = "pvp", subtype="skirmish", id = 0}
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

							MIOG_NewSettings.lastUsedQueue = {type = "pvp", subtype="brawl", id = 0}
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

							MIOG_NewSettings.lastUsedQueue = {type = "pvp", subtype="brawlSpecial", id = 0}
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
		info.parentIndex = indices["PVP"]
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
		info.parentIndex = indices["PVP"]
		--hideAllPVPButtonAssets(ConquestFrame.Arena2v2)
		queueDropDown:InsertCustomFrame(info, HonorFrame.QueueButton)
	end
end

local function updateDropDown()
	if(not InCombatLockdown()) then
		local blizzardDropDownDescriptions = {}

		local queueDropDown = miog.MainTab.QueueInformation.DropDown
		queueDropDown:ResetDropDown()

		queueDropDown.List.selfCheck = true

		local info = {}
		
		info.text = SPECIFIC_DUNGEONS
		info.hasArrow = true
		info.level = 1
		info.index = indices["SPECIFIC"]
		info.hideOnClick = false
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = PLAYER_V_PLAYER
		info.hasArrow = true
		info.level = 1
		info.index = indices["PVP"]
		queueDropDown:CreateEntryFrame(info)

		info = {}
		info.text = PET_BATTLE_PVP_QUEUE
		info.checked = false
		info.entryType = "option"
		info.level = 1
		info.value = "PETBATTLEQUEUEBUTTON"
		info.index = indices["PET"]
		info.func = function()
			C_PetBattles.StartPVPMatchmaking()

			MIOG_NewSettings.lastUsedQueue = {type = "pvp", subtype="pet", id = 0}
		end

		local tempFrame = queueDropDown:CreateEntryFrame(info)
		tempFrame:SetScript("OnShow", function(self)
			self.Radio:SetChecked(C_PetBattles.GetPVPMatchmakingInfo() ~= nil)
			
		end)

		info = {}
		info.entryType = "option"
		info.level = 2
		info.index = nil

		updateRandomDungeons(blizzardDropDownDescriptions)
		updateDungeons(nil, blizzardDropDownDescriptions)
		updateDungeons(indices["SPECIFIC"], blizzardDropDownDescriptions)
		updateRaidFinder(blizzardDropDownDescriptions)

		if(HonorFrameTypeDropdown) then
			updatePVP2()
		end
		
		--[[local blizzardDropDown = miog.pveFrame2.TabFramesPanel.MainTab.QueueInformation.BlizzardDropdown

		local selectedDungeonsList = {}

		blizzardDropDown:SetupMenu(function(dropdown, rootDescription)
			local dungeonButton = rootDescription:CreateButton(LFG_TYPE_DUNGEON)

			for k, v in pairs(blizzardDropDownDescriptions[1]) do
				local entryButton = dungeonButton:CreateButton(v.name, function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, v.id);
					JoinSingleLFG(1, v.id);
				end)

				entryButton:AddInitializer(function(button, description, menu)
					local leftTexture = button:AttachTexture();
					leftTexture:SetSize(18, 18);
					leftTexture:SetPoint("LEFT");
					leftTexture:SetTexture(v.icon);

					button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

					return button.fontString:GetUnboundedStringWidth() + 18 + 5
				end)
			end

			local heroicButton = rootDescription:CreateButton(LFG_TYPE_HEROIC_DUNGEON)

			for k, v in pairs(blizzardDropDownDescriptions[2]) do
				local entryButton = heroicButton:CreateButton(v.name, function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, v.id);
					JoinSingleLFG(1, v.id);
				end)

				entryButton:AddInitializer(function(button, description, menu)
					local leftTexture = button:AttachTexture();
					leftTexture:SetSize(16, 16);
					leftTexture:SetPoint("LEFT");
					leftTexture:SetTexture(v.icon);

					button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

					return button.fontString:GetUnboundedStringWidth() + 18 + 5
				end)
			end

			local followerButton = rootDescription:CreateButton(LFG_TYPE_FOLLOWER_DUNGEON)

			for k, v in pairs(blizzardDropDownDescriptions[205]) do
				local entryButton = followerButton:CreateButton(v.name, function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, v.id);
					JoinSingleLFG(1, v.id);
				end)
				entryButton:AddInitializer(function(button, description, menu)
					local leftTexture = button:AttachTexture();
					leftTexture:SetSize(16, 16);
					leftTexture:SetPoint("LEFT");
					leftTexture:SetTexture(v.icon);

					button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

					return button.fontString:GetUnboundedStringWidth() + 18 + 5
				end)
			end

			local specificButton = rootDescription:CreateButton(SPECIFIC_DUNGEONS)

			specificButton:CreateTitle(LFG_TYPE_DUNGEON)

			for k, v in pairs(blizzardDropDownDescriptions[1]) do
				--LFG_JoinDungeon(1, "specific", selectedDungeonsList, {})
				local entryButton = specificButton:CreateCheckbox(v.name,
				function(dungeonID) return selectedDungeonsList[dungeonID] ~= nil end,
				function(dungeonID)
					selectedDungeonsList[dungeonID] = not selectedDungeonsList[dungeonID] and dungeonID or nil

					LFGEnabledList[dungeonID] = selectedDungeonsList[dungeonID]
				end,
				v.id)

				entryButton:AddInitializer(function(button, description, menu)
					local leftTexture = button:AttachTexture();
					leftTexture:SetSize(16, 16);
					leftTexture:SetPoint("LEFT", button.leftTexture1, "RIGHT", 5, 0);
					leftTexture:SetTexture(v.icon);

					button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

					return button.fontString:GetUnboundedStringWidth() + 18 + 5
				end)
			end
			
			specificButton:CreateSpacer();
			specificButton:CreateTitle(LFG_TYPE_HEROIC_DUNGEON)

			for k, v in pairs(blizzardDropDownDescriptions[2]) do
				local entryButton = specificButton:CreateCheckbox(v.name,
				function(dungeonID) return selectedDungeonsList[dungeonID] ~= nil end,
				function(dungeonID)
					selectedDungeonsList[dungeonID] = not selectedDungeonsList[dungeonID] and dungeonID or nil

					LFGEnabledList[dungeonID] = selectedDungeonsList[dungeonID]
				end,
				v.id)

				entryButton:AddInitializer(function(button, description, menu)
					local leftTexture = button:AttachTexture();
					leftTexture:SetSize(16, 16);
					leftTexture:SetPoint("LEFT", button.leftTexture1, "RIGHT", 5, 0);
					leftTexture:SetTexture(v.icon);

					button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

					return button.fontString:GetUnboundedStringWidth() + 18 + 5
				end)
			end

			local queueButton = specificButton:CreateTemplate("UIPanelButtonTemplate")
			queueButton:AddInitializer(function(button, description, menu)
				button:SetScript("OnClick", function(_, buttonName)
					LFG_JoinDungeon(1, "specific", selectedDungeonsList, {})
				end);
				button:SetText("Queue for multiple dungeons")
			end);

			local raidFinderButton = rootDescription:CreateButton(RAID_FINDER)

			local lastRaidName

			for k, v in pairs(blizzardDropDownDescriptions[17]) do
				local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, raidName, minGearLevel, isScaling, mapID = GetRFDungeonInfo(v.index)

				local isNewRaid = lastRaidName ~= raidName
				local modifiedInstanceInfo, modifiedInstanceTooltipText = nil, ""

				if(mapID) then
					modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(mapID)

					if (modifiedInstanceInfo) then
						--icon = GetFinalNameFromTextureKit("%s-small", modifiedInstanceInfo.uiTextureKit);
						modifiedInstanceTooltipText = "|n|n" .. modifiedInstanceInfo.description;

					else
					
					end

					--info.iconXOffset = -6;
				end

				if(isNewRaid) then
					if(lastRaidName ~= nil) then
						raidFinderButton:CreateSpacer()

					end

					local raidTitle = raidFinderButton:CreateTitle(miog.MAP_INFO[mapID].shortName)

					if(modifiedInstanceInfo) then
						raidTitle:AddInitializer(function(button, description, ...)
							local leftTexture = button:AttachTexture();
							leftTexture:SetSize(16, 16);
							leftTexture:SetPoint("LEFT");
							leftTexture:SetAtlas(GetFinalNameFromTextureKit("%s-small", modifiedInstanceInfo.uiTextureKit));

							button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);
							button.fontString:SetTextColor(0.1,0.83,0.77,1)

							return button.fontString:GetUnboundedStringWidth() + 18 + 5
						end)
					end

				end

				local entryButton = raidFinderButton:CreateButton(v.name, function()
					ClearAllLFGDungeons(3);
					SetLFGDungeon(3, v.id);
					JoinSingleLFG(3, v.id);
				end)
	
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

				entryButton:SetTooltip(function(tooltip, description)
					--GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					tooltip:SetText(RAID_BOSSES)
					GameTooltip_AddNormalLine(tooltip, encounters .. modifiedInstanceTooltipText, 1, 1, 1, true)
					GameTooltip:Show()
				end)

				entryButton:AddInitializer(function(button, description, menu)
					local leftTexture = button:AttachTexture();
					leftTexture:SetSize(16, 16);
					leftTexture:SetPoint("LEFT");
					leftTexture:SetTexture(v.icon);

					button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

					return button.fontString:GetUnboundedStringWidth() + 18 + 5
				end)

				lastRaidName = raidName
			end

			local pvpButton = rootDescription:CreateButton(PLAYER_V_PLAYER)

			local listFrame = pvpButton:CreateTemplate("VerticalLayoutFrame")

			listFrame:AddInitializer(function(frame, description, menu)
				frame:SetSize(150, 150)
				local newFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
				newFrame.layoutIndex = 2
				newFrame:SetBackdrop(BACKDROP_TEXT_PANEL_0_16)
				updatePVP(frame)
				frame:MarkDirty()
			end)

			
			rootDescription:CreateButton(PET_BATTLE_PVP_QUEUE, function()
				C_PetBattles.StartPVPMatchmaking()
			end)
		end)]]
	
	else
		miog.F.UPDATE_AFTER_COMBAT = true
	
	end
end

miog.updateDropDown = updateDropDown

local function activityEvents(_, event, ...)

    if(event == "LFG_UPDATE_RANDOM_INFO") then
        updateDropDown()

    elseif(event == "LFG_UPDATE") then

    elseif(event == "LFG_LOCK_INFO_RECEIVED") then
        updateDropDown()
        
    elseif(event == "PVP_BRAWL_INFO_UPDATED") then
        updateDropDown()

    elseif(event == "LFG_LIST_AVAILABILITY_UPDATE") then
        updateDropDown()

    elseif(event == "GROUP_ROSTER_UPDATE") then
        --updateDropDown()
    end
end

miog.activityEvents = activityEvents

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_ActivityEventReceiver")

eventReceiver:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
eventReceiver:RegisterEvent("LFG_UPDATE")
eventReceiver:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
eventReceiver:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
eventReceiver:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
eventReceiver:RegisterEvent("PLAYER_REGEN_DISABLED")
eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")
eventReceiver:SetScript("OnEvent", miog.activityEvents)