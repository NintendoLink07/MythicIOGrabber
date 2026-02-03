local addonName, miog = ...
local wticc = WrapTextInColorCode

PLUNDERSTORM_ACTIVE = C_GameEnvironmentManager and C_GameEnvironmentManager.GetCurrentEventRealmQueues() ~= Enum.EventRealmQueues.None and C_LobbyMatchmakerInfo.GetQueueFromMainlineEnabled()

local randomBGFrame, randomEpicBGFrame, arena1Frame, brawl1Frame, brawl2Frame, specificBox

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

	if(button.Reward) then
		button.Reward:Hide()
	end
end

miog.hideAllPVPButtonAssets = hideAllPVPButtonAssets

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
				info.icon = miog.LFG_ID_INFO[id] and miog.LFG_ID_INFO[id].icon or fileID or miog.LFG_DUNGEONS_INFO[id] and miog.LFG_DUNGEONS_INFO[id].expansionLevel and miog.TIER_INFO[miog.LFG_DUNGEONS_INFO[id].expansionLevel][3] or nil
				info.parentIndex = subtypeID
				info.index = -1
				info.type2 = "random"

				info.func = function()
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, id);
					JoinSingleLFG(1, id);

					GetLFGDungeonInfo

					MIOG_CharacterSettings.lastUsedQueue = {type = "pve", subtype="dng", id = id}
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
	local lfdList = GetLFDChoiceOrder()

	if(lfdList) then
		for _, dungeonID in pairs(lfdList) do
			local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID);
			--local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expLevel, groupID, fileID, difficultyID, maxPlayers, _, isHolidayDungeon, _, minPlayers, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(dungeonID)

			--local isFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID)

			if(isAvailableForAll and (isAvailableForPlayer or not hideIfNotJoinable)) then
				tinsert(dungeonList, dungeonID)
			end
		end
	end
end

local partyPlaylistEnumToIndex = {
	[0] = "SoloGameMode",
	[1] = "DuoGameMode",
	[2] = "TrioGameMode",
	[3] = "TrainingGameMode"
}

local function addPvpActivities(topButton)
	local honorFrames = {
		HonorFrame.BonusFrame.RandomBGButton,
		HonorFrame.BonusFrame.RandomEpicBGButton,
		HonorFrame.SpecificScrollBox,
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
		if(PLUNDERSTORM_ACTIVE) then
			topButton:CreateTitle(WOW_LABS_PLUNDERSTORM_CATEGORY)

			for i = 0, 3, 1 do
				--if(i ~= 2) then
					local modeString = i == 0 and FRONT_END_LOBBY_SOLOS or i == 1 and FRONT_END_LOBBY_DUOS or i == 2 and FRONT_END_LOBBY_TRIOS or FRONT_END_LOBBY_PRACTICE
					local activityButton = topButton:CreateRadio(modeString, function(index) return C_LobbyMatchmakerInfo.IsInQueue() and C_LobbyMatchmakerInfo.GetCurrQueueState() == partyPlaylistEnumToIndex[index] end, function(index)
						local modeFrame = PlunderstormFrame.QueueSelect.QueueContainer[index == 0 and "Solo" or index == 1 and "Duo" or index == 2 and "Trio" or "Practice"]
						
						if(modeFrame) then
							modeFrame:Click()

						end
			
						C_LobbyMatchmakerInfo.EnterQueue(index or PlunderstormFrame.QueueSelect.useLocalPlayIndex);
						MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="plunderstorm", id = index}

					end, i)
				--end
			end

			local spacer1 = topButton:CreateSpacer()
			local divider = topButton:CreateDivider()
			local spacer2 = topButton:CreateSpacer()
		end

		local typeDrop = topButton:CreateFrame()
		typeDrop:AddInitializer(function(blankFrame, description, menu)
			blankFrame:SetSize(300, 25)

			HonorFrame.TypeDropdown:ClearAllPoints()
			HonorFrame.TypeDropdown:SetAllPoints(blankFrame)
			HonorFrame.TypeDropdown:SetParent(blankFrame)
			HonorFrame.TypeDropdown:SetScript("OnHide", function(self)
				--self:ClearAllPoints()
			end)
		end)

		local isBonus = HonorFrame.type == "bonus"
		local isSpecific = HonorFrame.type == "specific"

		for k, v in ipairs(honorFrames) do
			local test = topButton:CreateFrame()

			if(v == HonorFrame.SpecificScrollBox) then
				test:AddInitializer(function(blankFrame, description, menu)
					blankFrame:SetSize(300, 300)
		
					HonorFrame.SpecificScrollBox:ClearAllPoints()
					HonorFrame.SpecificScrollBox:SetAllPoints(blankFrame)
					--HonorFrame.SpecificScrollBox.layoutIndex = 1
					--HonorFrame.SpecificScrollBox:SetSize(blankFrame:GetSize())
					HonorFrame.SpecificScrollBox:SetParent(blankFrame)
					HonorFrame.SpecificScrollBox:SetScript("OnHide", function(self)
						--self:ClearAllPoints()
					end)
		
					HonorFrame.SpecificScrollBar:ClearAllPoints()
					HonorFrame.SpecificScrollBar:SetPoint("TOPLEFT", HonorFrame.SpecificScrollBox, "TOPRIGHT", 5, 0)
					HonorFrame.SpecificScrollBar:SetPoint("BOTTOMLEFT", HonorFrame.SpecificScrollBox, "BOTTOMRIGHT", 5, 0)
					HonorFrame.SpecificScrollBar:SetParent(HonorFrame.SpecificScrollBox)
					HonorFrame.SpecificScrollBar:SetScript("OnHide", function(self)
						--self:ClearAllPoints()
					end)
		
				end)

				test:SetShown(isSpecific)
				specificBox = test

			else
				test:AddInitializer(function(blankFrame, description, menu)
					blankFrame:SetSize(300, 25)
					blankFrame.linkedFrameName = v:GetDebugName()
	
					v.baseName = blankFrame.linkedFrameName
					v:ClearAllPoints()
					v:SetAllPoints(blankFrame)
					v:SetParent(blankFrame)
				end)
				test:SetScript("OnShow", function()
					hideAllPVPButtonAssets(v)

				end)

				if(v == HonorFrame.BonusFrame.RandomBGButton) then
					test:SetShown(isBonus)
					randomBGFrame = test

				elseif(v == HonorFrame.BonusFrame.RandomEpicBGButton) then
					test:SetShown(isBonus)
					randomEpicBGFrame = test

				elseif(v == HonorFrame.BonusFrame.Arena1Button) then
					test:SetShown(isBonus)
					arena1Frame = test

				elseif(v == HonorFrame.BonusFrame.BrawlButton) then
					test:SetShown(isBonus)
					brawl1Frame = test

				elseif(v == HonorFrame.BonusFrame.BrawlButton2) then
					test:SetShown(isBonus)
					brawl2Frame = test

				end

			end
		end

		local honorQueue = topButton:CreateFrame()
		honorQueue:AddInitializer(function(blankFrame, description, menu)
			blankFrame:SetSize(300, 25)

			HonorFrame.QueueButton:ClearAllPoints()
			HonorFrame.QueueButton:SetAllPoints(blankFrame)
			HonorFrame.QueueButton:SetParent(blankFrame)
			HonorFrame.QueueButton:SetScript("OnHide", function(self)
				--self:ClearAllPoints()
			end)
		end)
	end

	if(ConquestFrame) then
		local spacer1 = topButton:CreateSpacer()
		local divider = topButton:CreateDivider()
		local spacer2 = topButton:CreateSpacer()

		for k, v in ipairs(conquestFrames) do
			local test = topButton:CreateFrame()
			test:AddInitializer(function(blankFrame, description, menu)
				blankFrame:SetSize(300, 25)

				v:ClearAllPoints()
				v:SetAllPoints(blankFrame)
				v:SetParent(blankFrame)
				v:SetScript("OnHide", function(self)
					--self:ClearAllPoints()
				end)

			end)
			test:SetScript("OnShow", function(self)
				hideAllPVPButtonAssets(v)
			end)
		end

		local conquestQueue = topButton:CreateFrame()
		conquestQueue:AddInitializer(function(blankFrame, description, menu)
			blankFrame:SetSize(300, 25)

			ConquestFrame.JoinButton:ClearAllPoints()
			ConquestFrame.JoinButton:SetAllPoints(blankFrame)
			ConquestFrame.JoinButton:SetParent(blankFrame)
			ConquestFrame.JoinButton:SetScript("OnHide", function(self)
				--self:ClearAllPoints()
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
					icon = miog.LFG_ID_INFO[dungeonID] and miog.LFG_ID_INFO[dungeonID].icon or miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].icon or fileID or miog.TIER_INFO[expLevel][3] or nil,
					expansionLevel = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].expansionLevel or miog.LFG_DUNGEONS_INFO[dungeonID] and miog.LFG_DUNGEONS_INFO[dungeonID].expansionLevel or expLevel,
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
			or miog.TIER_INFO[expLevel][3]
			or nil,
			expansionLevel = miog.MAP_INFO[mapID] and miog.MAP_INFO[mapID].expansionLevel or miog.LFG_DUNGEONS_INFO[dungeonID] and miog.LFG_DUNGEONS_INFO[dungeonID].expansionLevel or expLevel,
		})

		
	end

	for k, v in ipairs(indicesInfo) do
		local isLFR = k == 6

		table.sort(indicesList[k], function(k1, k2)
			if(k1.expansionLevel == k2.expansionLevel) then
				if(k1.typeID == k2.typeID) then
					if(not isLFR) then
						return k1.name < k2.name

					else
						if(k1.name2 == k2.name2) then
							return k1.dungeonID < k2.dungeonID
							
						end

						return k1.name2 < k2.name2

					end
				end
	
				return k1.typeID > k2.typeID
			end
	
			return k1.expansionLevel > k2.expansionLevel
		end)
	end
end

local selectedDungeonsList = {}

local function setupQueueDropdown(rootDescription)
	for k, v in ipairs(indicesList) do
		local isSpecific = k == indices["SPECIFIC"]
		local isRaidFinder = k == indices["RAIDFINDER"]
		local isEvent = k == indices["EVENT"]
		local isPvp = k == indices["PVP"]

		if(not isEvent and true or isEvent and #v > 0) then
			local isPetBattle = k == indices["PET"]
			
			local activityButton
			
			if(isPetBattle) then
				activityButton = rootDescription:CreateRadio(PET_BATTLE_PVP_QUEUE, function() return C_PetBattles.GetPVPMatchmakingInfo() ~= nil end, function()
					C_PetBattles.StartPVPMatchmaking()
		
					MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="pet", id = 0}

				end)
			else
				activityButton = rootDescription:CreateButton(indicesInfo[k].var, function(index)
				end, k)
			end

			local lastRaidName, lastExpansion
			activityButton:SetEnabled(isPetBattle and (not C_LobbyMatchmakerInfo.IsInQueue() and C_PetJournal.IsFindBattleEnabled() and C_PetJournal.IsJournalUnlocked())
				or isPvp and (C_PvP.CanPlayerUseRatedPVPUI() or C_LFGInfo.CanPlayerUsePremadeGroup()) and true or isSpecific and #indicesList[2] > 0 and true or #v > 0)

			local queueButton

			if(isPvp) then
				addPvpActivities(activityButton)

			else
				for listIndex, dungeonInfo in ipairs(v) do
					if(isSpecific) then
						if(dungeonInfo.typeID ~= 6) then
							if(lastExpansion ~= dungeonInfo.expansionLevel) then
								local title = activityButton:CreateTitle(miog.TIER_INFO[dungeonInfo.expansionLevel][1])
								
							end

							queueButton = activityButton:CreateCheckbox(dungeonInfo.name .. " " .. (dungeonInfo.subtypeID == 1 and PLAYER_DIFFICULTY1 or dungeonInfo.subtypeID == 2 and PLAYER_DIFFICULTY2 or ""), function(dungeonID) return selectedDungeonsList[dungeonID] ~= nil end, function(dungeonID)
								selectedDungeonsList[dungeonID] = not selectedDungeonsList[dungeonID] and dungeonID or nil

								LFGEnabledList[dungeonID] = selectedDungeonsList[dungeonID]
							end, dungeonInfo.dungeonID)

							lastExpansion = dungeonInfo.expansionLevel
						end
					elseif(isRaidFinder) then
						if(lastRaidName ~= dungeonInfo.name2) then
							local title = activityButton:CreateTitle(dungeonInfo.name2)

						end

						queueButton = activityButton:CreateRadio(dungeonInfo.name, function(dungeonID) return GetLFGMode(3, dungeonID) == "queued" end, function(dungeonID)
							ClearAllLFGDungeons(3);
							SetLFGDungeon(3, dungeonID);
							JoinSingleLFG(3, dungeonID);

							MIOG_CharacterSettings.lastUsedQueue = {type = "pve", subtype="raid", id = dungeonID}
						end, dungeonInfo.dungeonID)

						lastRaidName = dungeonInfo.name2
					else
						if(not isEvent and lastExpansion ~= dungeonInfo.expansionLevel) then
							local title = activityButton:CreateTitle(miog.TIER_INFO[dungeonInfo.expansionLevel][1])
							
						end

						queueButton = activityButton:CreateRadio(dungeonInfo.name, function(dungeonID) return GetLFGMode(1, dungeonID) == "queued" end, function(dungeonID)
							ClearAllLFGDungeons(1);
							SetLFGDungeon(1, dungeonID);
							JoinSingleLFG(1, dungeonID);
			
							MIOG_CharacterSettings.lastUsedQueue = {type = "pve", subtype="dng", id = dungeonID}
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
				queueButton = activityButton:CreateTemplate("UIPanelButtonTemplate", "Button")
				queueButton:AddInitializer(function(button, description, menu)
					button:SetScript("OnClick", function(_, buttonName)
						LFG_JoinDungeon(1, "specific", selectedDungeonsList, {})

						MIOG_CharacterSettings.lastUsedQueue = {type = "pve", subtype="multidng", id = selectedDungeonsList}

						rootDescription:CloseMenus()
					end);

					button:SetText("Queue for multiple dungeons")
				end);
			end
		end
	end
end

miog.setupQueueDropdown = setupQueueDropdown

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

    --elseif(event == "GROUP_ROSTER_UPDATE") then
		--refreshDungeonList()
    end

	--miog.updateDropDown()
end

miog.loadActivityChecker = function()
	local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_ActivityEventReceiver")

	eventReceiver:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	eventReceiver:RegisterEvent("LFG_UPDATE")
	eventReceiver:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
	--eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
	eventReceiver:RegisterEvent("PVP_BRAWL_INFO_UPDATED")
	eventReceiver:SetScript("OnEvent", activityEvents)
	
	if(HonorFrame.TypeDropdown) then
		hooksecurefunc("HonorFrame_SetTypeInternal", function(value)
			local isBonus = value == "bonus"
			local isSpecific = value == "specific"

			if(randomBGFrame) then
				randomBGFrame:SetShown(isBonus)

			end

			if(randomEpicBGFrame) then
				randomEpicBGFrame:SetShown(isBonus)

			end

			if(arena1Frame) then
				arena1Frame:SetShown(isBonus)

			end

			if(brawl1Frame) then
				brawl1Frame:SetShown(isBonus)

			end

			if(brawl2Frame) then
				brawl2Frame:SetShown(isBonus)

			end

			if(specificBox) then
				specificBox:SetShown(isSpecific)
				specificBox:GetParent():MarkDirty()

			end

			--HonorFrame.TypeDropdown:GetParent():GetParent():MarkDirty()
		end)
	end

	hooksecurefunc("PVPUIFrame_ConfigureRewardFrame", function(frame)
		hideAllPVPButtonAssets(frame:GetParent())
	end)

	LFGDungeonList_Setup()
end