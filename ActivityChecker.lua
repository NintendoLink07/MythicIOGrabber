local addonName, miog = ...
local wticc = WrapTextInColorCode

local randomBGFrame, randomEpicBGFrame, specificBox

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


local indicesInfo = {
	[1] = {id = "EVENT", var = EVENTS_LABEL},
	[2] = {id = "NORMAL", var = LFG_TYPE_DUNGEON},
	[3] = {id = "HEROIC", var = LFG_TYPE_HEROIC_DUNGEON},
	[4] = {id = "FOLLOWER", var = LFG_TYPE_FOLLOWER_DUNGEON},
	[5] = {id = "SPECIFIC", var = SPECIFIC_DUNGEONS},
	[6] = {id = "RAIDFINDER", var = RAID_FINDER},
	[7] = {id = "PVP", var = PLAYER_V_PLAYER},
	[8] = {id = "PET", var = PET_BATTLE_PVP_QUEUE},
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

local function getRandomDungeonsList(dungeonList)
	for i=1, GetNumRandomDungeons() do
		local id = GetLFGRandomDungeonInfo(i)
		
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if(isAvailableForAll and (isAvailableForPlayer or not hideIfNotJoinable)) then
			tinsert(dungeonList, id)

		end
	end
end

local function getRegularDungeonLists(dungeonList)
	for _, dungeonID in pairs(GetLFDChoiceOrder()) do
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID);
		--local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expLevel, groupID, fileID, difficultyID, maxPlayers, _, isHolidayDungeon, _, minPlayers, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(dungeonID)

		--local isFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID)

		if(isAvailableForAll and (isAvailableForPlayer or not hideIfNotJoinable)) then
			tinsert(dungeonList, dungeonID)
		end
	end
end

local function addPvpActivities(topButton)
	local honorFrames = {
		HonorFrame.BonusFrame.RandomBGButton,
		HonorFrame.BonusFrame.RandomEpicBGButton,
		HonorFrame.BonusFrame.Arena1Button,
		HonorFrame.BonusFrame.BrawlButton,
		HonorFrame.BonusFrame.BrawlButton2,
	}

	local conquestFrames = {
		ConquestFrame.RatedSoloShuffle,
		ConquestFrame.RatedBGBlitz,
		ConquestFrame.Arena2v2,
		ConquestFrame.Arena3v3,
		ConquestFrame.RatedBG,
	}

	if(HonorFrame.TypeDropdown) then
		if(HonorFrame.type == "bonus") then
			for k, v in ipairs(honorFrames) do
				local test = topButton:CreateFrame()
				test:AddInitializer(function(blankFrame, description, menu)
					blankFrame:SetSize(300, 25)
	
					v:ClearAllPoints()
					v:SetAllPoints(blankFrame)
					v:SetParent(blankFrame)
					v:SetScript("OnHide", function(self)
						self:ClearAllPoints()
					end)

					miog.hideAllPVPButtonAssets(v)
				end)
			end
		elseif(HonorFrame.type == "specific") then
			local specificBox = topButton:CreateTemplate("VerticalLayoutFrame")
			specificBox:AddInitializer(function(blankFrame, description, menu)
				blankFrame:SetSize(300, 300)
	
				HonorFrame.SpecificScrollBox:ClearAllPoints()
				HonorFrame.SpecificScrollBox.layoutIndex = 1
				HonorFrame.SpecificScrollBox:SetSize(blankFrame:GetSize())
				HonorFrame.SpecificScrollBox:SetParent(blankFrame)
				HonorFrame.SpecificScrollBox:SetScript("OnHide", function(self)
					self:ClearAllPoints()
				end)
	
				HonorFrame.SpecificScrollBar:ClearAllPoints()
				HonorFrame.SpecificScrollBar:SetPoint("TOPLEFT", HonorFrame.SpecificScrollBox, "TOPRIGHT", 5, 0)
				HonorFrame.SpecificScrollBar:SetPoint("BOTTOMLEFT", HonorFrame.SpecificScrollBox, "BOTTOMRIGHT", 5, 0)
				HonorFrame.SpecificScrollBar:SetParent(HonorFrame.SpecificScrollBox)
				HonorFrame.SpecificScrollBar:SetScript("OnHide", function(self)
					self:ClearAllPoints()
				end)
	
				blankFrame:MarkDirty()
			end)
		end

		local honorQueue = topButton:CreateFrame()
		honorQueue:AddInitializer(function(blankFrame, description, menu)
			blankFrame:SetSize(300, 25)

			HonorFrame.QueueButton:ClearAllPoints()
			HonorFrame.QueueButton:SetAllPoints(blankFrame)
			HonorFrame.QueueButton:SetParent(blankFrame)
			HonorFrame.QueueButton:SetScript("OnHide", function(self)
				self:ClearAllPoints()
			end)
		end)

		local spacer1 = topButton:CreateSpacer()
		local divider = topButton:CreateDivider()
		local spacer2 = topButton:CreateSpacer()
	end

	if(ConquestFrame) then
		for k, v in ipairs(conquestFrames) do
			local test = topButton:CreateFrame()
			test:AddInitializer(function(blankFrame, description, menu)
				blankFrame:SetSize(300, 25)

				v:ClearAllPoints()
				v:SetAllPoints(blankFrame)
				v:SetParent(blankFrame)
				v:SetScript("OnHide", function(self)
					self:ClearAllPoints()
				end)

				miog.hideAllPVPButtonAssets(v)
			end)
		end

		local conquestQueue = topButton:CreateFrame()
		conquestQueue:AddInitializer(function(blankFrame, description, menu)
			blankFrame:SetSize(300, 25)

			ConquestFrame.JoinButton:ClearAllPoints()
			ConquestFrame.JoinButton:SetAllPoints(blankFrame)
			ConquestFrame.JoinButton:SetParent(blankFrame)
			ConquestFrame.JoinButton:SetScript("OnHide", function(self)
				self:ClearAllPoints()
			end)
		end)
	end
end

local indicesList = {}

local function IsRaidFinderDungeonDisplayable(id)
	local name, typeID, subtypeID, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(id);
	local myLevel = UnitLevel("player");
	return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel;
end


local function addRaidFinderDungeonsToList(dungeonList)
	-- GetBestRFChoice()
	
	for rfIndex = 1, GetNumRFDungeons() do
		local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansion, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, raidName, minGearLevel, isScaling, mapID = GetRFDungeonInfo(rfIndex)

		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if(not hideIfNotJoinable or isAvailableForAll ) then
			if(isAvailableForAll or isAvailableForPlayer or IsRaidFinderDungeonDisplayable(id)) then
				table.insert(dungeonList, id)
				--table.insert(dungeonList, {id = id, rfIndex = rfIndex})
			end
		end
	end
end

local function checkIfIDIsAlreadyAdded(dungeonList, name)
	for k, v in ipairs(dungeonList) do
		if(v.name == name) then
			return true
		end
	end

	return false
end

local function refreshDungeonList()
	indicesList = {}

	for k, v in ipairs(indicesInfo) do
		indicesList[k] = {}

	end

	local dungeonList = {}

	getRandomDungeonsList(dungeonList)
	getRegularDungeonLists(dungeonList)
	addRaidFinderDungeonsToList(dungeonList)

	for _, dungeonID in ipairs(dungeonList) do
		local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expLevel, groupID, fileID, difficultyID, maxPlayers, desc, isHolidayDungeon, bonusRep, minPlayers, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(dungeonID)

		local isFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID)

		local entryType = (typeID == 1 and subtypeID == 3) and indices["RAIDFINDER"] or (isHolidayDungeon or isTimewalkingDungeon) and indices["EVENT"] or isFollowerDungeon and indices["FOLLOWER"] or subtypeID == 1 and indices["NORMAL"] or subtypeID == 2 and indices["HEROIC"]

		if(entryType == indices["NORMAL"] or entryType == indices["HEROIC"]) then
			if(not checkIfIDIsAlreadyAdded(indicesList[indices["SPECIFIC"]], name)) then
				tinsert(indicesList[indices["SPECIFIC"]], {
					name = name,
					name2 = name2,
					typeID = typeID,
					subtypeID = subtypeID,
					dungeonID = dungeonID,
					icon = miog.LFG_ID_INFO[dungeonID] and miog.LFG_ID_INFO[dungeonID].icon or miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or fileID or miog.EXPANSION_INFO[expLevel][3] or nil,
					expansionLevel = expLevel,
				})
			end
		end

		tinsert(indicesList[entryType], {
			name = name,
			name2 = name2,
			typeID = typeID,
			subtypeID = subtypeID,
			dungeonID = dungeonID,
			icon = miog.LFG_ID_INFO[dungeonID] and miog.LFG_ID_INFO[dungeonID].icon 
			or miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon 
			or fileID
			or miog.EXPANSION_INFO[expLevel][3]
			or nil,
			expansionLevel = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].expansionLevel or miog.LFG_DUNGEONS_INFO[dungeonID] and miog.LFG_DUNGEONS_INFO[dungeonID].expansionLevel or expLevel,
		})
	end

	for k, v in ipairs(indicesInfo) do
		table.sort(indicesList[k], function(k1, k2)
			if(k1.expansionLevel == k2.expansionLevel) then
				if(k1.typeID == k2.typeID) then
					return k1.name < k2.name
				end
	
				return k1.typeID > k2.typeID
			end
	
			return k1.expansionLevel > k2.expansionLevel
		end)
	end

end

local selectedDungeonsList = {}

local function setupQueueDropdown(rootDescription)
	--[[
	local orderedList = {}
	local lastRaidName
	table.sort(orderedList, function(k1, k2)
		return k1.id < k2.id
	end)

	for k, v in ipairs(orderedList) do
	--for rfIndex = 1, GetNumRFDungeons() do
		local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expLevel, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, raidName, minGearLevel, isScaling, mapID = GetRFDungeonInfo(v.rfIndex)

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
		end

		if(lastRaidName ~= raidName) then
			--local textLine = queueDropDown:CreateTextLine(nil, info.parentIndex, miog.MAP_INFO[mapID].shortName, icon)

			if(icon) then
				--textLine:SetTextColor(0.1,0.83,0.77,1)

			end
		end

		tinsert(indicesList[indices["RAIDFINDER"] ], {
			name = name,
			typeID = typeID,
			dungeonID = id,
			icon = miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or miog.LFG_DUNGEONS_INFO[id] and miog.LFG_DUNGEONS_INFO[id].expansionLevel and miog.EXPANSION_INFO[miog.LFG_DUNGEONS_INFO[id].expansionLevel][3] or nil,
			expansionLevel = miog.LFG_DUNGEONS_INFO[id] and miog.LFG_DUNGEONS_INFO[id].expansionLevel or expLevel,
		})

		--[ [local mode = GetLFGMode(3, id)
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

		lastRaidName = raidName] ]
	end


	]]

	LFGEnabledList = GetLFDChoiceEnabledState(LFGEnabledList);	--We maintain this list in Lua

	for k, v in ipairs(indicesList) do
		local isPetBattle = k == indices["PET"]
		
		local activityButton
		
		if(isPetBattle) then
			activityButton = rootDescription:CreateRadio(PET_BATTLE_PVP_QUEUE, function() return C_PetBattles.GetPVPMatchmakingInfo() ~= nil end, function()
				C_PetBattles.StartPVPMatchmaking()
	
				MIOG_NewSettings.lastUsedQueue = {type = "pvp", subtype="pet", id = 0}

			end)
		else
			activityButton = rootDescription:CreateButton(indicesInfo[k].var, function(index)
			end, k)
		end

		local lastRaidName, lastExpansion

		local isSpecific = k == indices["SPECIFIC"]
		local isRaidFinder = k == indices["RAIDFINDER"]
		local isEvent = k == indices["EVENT"]
		local isPvp = k == indices["PVP"]

		activityButton:SetEnabled(isPetBattle and true or isPvp and (C_PvP.CanPlayerUseRatedPVPUI() or C_LFGInfo.CanPlayerUsePremadeGroup()) and true or isSpecific and #indicesList[2] > 0 and true or #v > 0)

		local queueButton

		if(isPvp) then
			addPvpActivities(activityButton)

		else
			for listIndex, dungeonInfo in ipairs(v) do
				if(isSpecific) then
					if(dungeonInfo.typeID ~= 6) then
						if(lastExpansion ~= dungeonInfo.expansionLevel) then
							local title = activityButton:CreateTitle(miog.EXPANSION_INFO[dungeonInfo.expansionLevel][1])
							
						end

						queueButton = activityButton:CreateCheckbox(dungeonInfo.name, function(dungeonID) return selectedDungeonsList[dungeonID] ~= nil end, function(dungeonID)
							selectedDungeonsList[dungeonID] = not selectedDungeonsList[dungeonID] and dungeonID or nil

							LFGEnabledList[dungeonID] = selectedDungeonsList[dungeonID]
						end, dungeonInfo.dungeonID)

						lastExpansion = dungeonInfo.expansionLevel
					end
				elseif(isRaidFinder) then
					if(lastRaidName ~= dungeonInfo.name2) then
						--local textLine = queueDropDown:CreateTextLine(nil, info.parentIndex, miog.MAP_INFO[mapID].shortName, icon)
						local title = activityButton:CreateTitle(dungeonInfo.name2)

						if(icon) then
							--textLine:SetTextColor(0.1,0.83,0.77,1)

						end
					end

					queueButton = activityButton:CreateRadio(dungeonInfo.name, function(dungeonID) return GetLFGMode(3, dungeonID) == "queued" end, function(dungeonID)
						ClearAllLFGDungeons(3);
						SetLFGDungeon(3, dungeonID);
						JoinSingleLFG(3, dungeonID);

						MIOG_NewSettings.lastUsedQueue = {type = "pve", subtype="raid", id = dungeonID}
					end, dungeonInfo.dungeonID)

					lastRaidName = dungeonInfo.name2
				else
					if(not isEvent and lastExpansion ~= dungeonInfo.expansionLevel) then
						local title = activityButton:CreateTitle(miog.EXPANSION_INFO[dungeonInfo.expansionLevel][1])
						
					end

					queueButton = activityButton:CreateRadio(dungeonInfo.name, function(dungeonID) return GetLFGMode(1, dungeonID) == "queued" end, function(dungeonID)
						ClearAllLFGDungeons(1);
						SetLFGDungeon(1, dungeonID);
						JoinSingleLFG(1, dungeonID);
		
						MIOG_NewSettings.lastUsedQueue = {type = "pve", subtype="dng", id = dungeonID}
					end, dungeonInfo.dungeonID)

					lastExpansion = dungeonInfo.expansionLevel
				end

				if(queueButton) then
					queueButton:AddInitializer(function(button, description, menu)
						if(dungeonInfo.icon) then
							local leftTexture = button:AttachTexture();
							leftTexture:SetSize(16, 16);
							leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
							leftTexture:SetTexture(dungeonInfo.icon);
			
							button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);
			
							return button.fontString:GetUnboundedStringWidth() + 18 + 5
						end
					end)
				end
			end
		end

		if(isSpecific) then
			queueButton = activityButton:CreateTemplate("UIPanelButtonTemplate")
			queueButton:AddInitializer(function(button, description, menu)
				button:SetScript("OnClick", function(_, buttonName)
					LFG_JoinDungeon(1, "specific", selectedDungeonsList, {})

					MIOG_NewSettings.lastUsedQueue = {type = "pve", subtype="multidng", id = selectedDungeonsList}
				end);

				button:SetText("Queue for multiple dungeons")
			end);
		end
	end
end

miog.setupQueueDropdown = setupQueueDropdown

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
					info.icon = miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or miog.EXPANSION_INFO[expLevel][3] or nil
					info.parentIndex = (isHolidayDungeon or isTimewalkingDungeon) and indices["EVENT"] or subtypeID == 1 and indices["NORMAL"] or subtypeID == 2 and indices["HEROIC"]
					info.type1 = typeID
					--info.index = -1
					info.expansionLevel = expLevel
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
		info.hasArrow = #normalDungeonList > 0
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
		info.hasArrow = #heroicDungeonList > 0
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
		info.hasArrow = #followerDungeonList > 0
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

	local playerLevel = UnitLevel("player")

	local lastRaidName

	local hasAnEntry = false

	local orderedList = {}

	for rfIndex = 1, GetNumRFDungeons() do
		local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansion, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, raidName, minGearLevel, isScaling, mapID = GetRFDungeonInfo(rfIndex)

		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		if( not hideIfNotJoinable or isAvailableForAll ) then
			if ( isAvailableForAll or isAvailableForPlayer or IsRaidFinderDungeonDisplayable(id) ) then
				if (playerLevel >= minLevel and playerLevel <= maxLevel) then
					hasAnEntry = true
					table.insert(orderedList, {id = id, rfIndex = rfIndex})
				end
			end
		end
	end

	table.sort(orderedList, function(k1, k2)
		return k1.id < k2.id
	end)

	for k, v in ipairs(orderedList) do
	--for rfIndex = 1, GetNumRFDungeons() do
		local id, name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansion, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, raidName, minGearLevel, isScaling, mapID = GetRFDungeonInfo(v.rfIndex)


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

		lastRaidName = raidName
	end

	if(hasAnEntry == false) then
		queueDropDown:DisableSpecificFrame(raidFinderFrame)
		raidFinderFrame.Arrow:Hide()

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

	if(button.LevelRequirement and button.LevelRequirement:GetText()) then
		button.LevelRequirement:Hide()
		button:Enable()

		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(self.Title:GetText(), 1, 1, 1);
			GameTooltip:AddLine(self.LevelRequirement:GetText(), 1, 0, 0, true);
			GameTooltip:Show();
		end)
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

miog.hideAllPVPButtonAssets = hideAllPVPButtonAssets

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

local function addBonusSpecificDropdown()
	local queueDropDown = miog.MainTab.QueueInformation.DropDown

	local info = {}
	info.entryType = "option"
	info.index = 20
	info.level = 2
	info.parentIndex = indices["PVP"]
	HonorFrame.TypeDropdown:SetHeight(20)
	local dropdown = queueDropDown:InsertCustomFrame(info, HonorFrame.TypeDropdown)
	dropdown.topPadding = 8
	dropdown.bottomPadding = 8
	dropdown.leftPadding = 0
	dropdown:SetHeight(20)
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

		info = {}
		info.entryType = "option"
		info.index = 2
		info.level = 2
		info.parentIndex = indices["PVP"]
		hideAllPVPButtonAssets(ConquestFrame.RatedBGBlitz)
		local soloBGFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.RatedBGBlitz)
		soloBGFrame:HookScript("OnShow", function(self)
			hideAllPVPButtonAssets(self)
		end)
		
		info = {}
		info.entryType = "option"
		info.index = 3
		info.level = 2
		info.parentIndex = indices["PVP"]
		hideAllPVPButtonAssets(ConquestFrame.Arena2v2)
		local twosFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.Arena2v2)
		twosFrame:HookScript("OnShow", function(self)
			hideAllPVPButtonAssets(self)
		end)

		info = {}
		info.entryType = "option"
		info.index = 4
		info.level = 2
		info.parentIndex = indices["PVP"]
		hideAllPVPButtonAssets(ConquestFrame.Arena3v3)
		local threesFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.Arena3v3)
		threesFrame:HookScript("OnShow", function(self)
			hideAllPVPButtonAssets(self)
		end)

		info = {}
		info.entryType = "option"
		info.index = 5
		info.level = 2
		info.parentIndex = indices["PVP"]
		hideAllPVPButtonAssets(ConquestFrame.RatedBG)
		local ratedBGFrame = queueDropDown:InsertCustomFrame(info, ConquestFrame.RatedBG)
		ratedBGFrame:HookScript("OnShow", function(self)
			hideAllPVPButtonAssets(self)
		end)

		info = {}
		info.entryType = "option"
		info.index = 6
		info.level = 2
		info.parentIndex = indices["PVP"]
		queueDropDown:InsertCustomFrame(info, ConquestFrame.JoinButton)

		queueDropDown:CreateSeparator(10, indices["PVP"])

		for index = 1, 5, 1 do
			local currentBGQueue = index == 1 and C_PvP.GetRandomBGInfo() or index == 2 and C_PvP.GetRandomEpicBGInfo() or index == 3 and C_PvP.GetSkirmishInfo(4) or index == 4 and C_PvP.GetAvailableBrawlInfo() or index == 5 and C_PvP.GetSpecialEventBrawlInfo()

			if(currentBGQueue and (index == 3 or currentBGQueue.canQueue)) then
				info = {}
				info.text = index == 1 and RANDOM_BATTLEGROUNDS or index == 2 and RANDOM_EPIC_BATTLEGROUND or index == 3 and SKIRMISH or currentBGQueue.name
				info.entryType = "option"
				info.checked = false
				info.index = index == 1 and 21 or index == 2 and 22 or index + 10
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

		addBonusSpecificDropdown()
	
		info = {}
		info.entryType = "option"
		info.index = 21
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

		--addBonusSpecificDropdown()
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

		refreshDungeonList()
		updateRaidFinder(blizzardDropDownDescriptions)

		if(HonorFrame and HonorFrame.TypeDropdown) then
			updatePVP2()

		end
	else
		miog.F.UPDATE_AFTER_COMBAT = true
	
	end
end

miog.updateDropDown = updateDropDown

local function activityEvents(_, event, ...)
    if(event == "LFG_UPDATE_RANDOM_INFO") then
		refreshDungeonList()

    elseif(event == "LFG_UPDATE") then
		refreshDungeonList()

    elseif(event == "LFG_LOCK_INFO_RECEIVED") then
		refreshDungeonList()
        
    elseif(event == "PVP_BRAWL_INFO_UPDATED") then
		refreshDungeonList()

    elseif(event == "LFG_LIST_AVAILABILITY_UPDATE") then
		refreshDungeonList()

    elseif(event == "GROUP_ROSTER_UPDATE") then
		refreshDungeonList()
    end

	miog.updateDropDown()
end

miog.loadActivityChecker = function()
	local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_ActivityEventReceiver")

	eventReceiver:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	eventReceiver:RegisterEvent("LFG_UPDATE")
	eventReceiver:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
	eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
	eventReceiver:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
	eventReceiver:SetScript("OnEvent", activityEvents)
	
	if(HonorFrame.TypeDropdown) then
		hooksecurefunc("HonorFrame_SetTypeInternal", function(value)
			randomBGFrame:SetShown(value == "bonus")
			randomEpicBGFrame:SetShown(value == "bonus")

			specificBox:SetShown(value == "specific")
			specificBox:GetParent():MarkDirty()
		end)
	end
end