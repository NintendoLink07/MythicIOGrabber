local addonName, miog = ...
local wticc = WrapTextInColorCode

local queueSystem = {}
queueSystem.queueFrames = {}
queueSystem.currentlyInUse = 0

miog.queueSystem = queueSystem
miog.pveFrame2 = nil

local function resetQueueFrame(_, frame)
	frame:Hide()
	frame.layoutIndex = nil

	local objectType = frame:GetObjectType()

	if(objectType == "Frame") then
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
	miog.pveFrame2.QueuePanel.Container:MarkDirty()
end

hooksecurefunc("PVEFrame_ToggleFrame", function()
	HideUIPanel(PVEFrame)
	miog.pveFrame2:SetShown(not miog.pveFrame2:IsVisible())
end)

local function createPVEFrameReplacement()

	local frame = CreateFrame("Frame", "MythicIOGrabber_PVEFrameReplacement", WorldFrame, "MIOG_MainFrameTemplate")
	frame:SetSize(PVEFrame:GetWidth(), PVEFrame:GetHeight())
	frame:SetPoint(PVEFrame:GetPoint())
	frame:SetScale(0.64)

	frame:AdjustPointsOffset(900, 0)

	miog.createFrameBorder(frame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	--frame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

	miog.pveFrame2 = frame
	--PVEFrame:SetAlpha(0)
	--PVEFrame:HookScript("OnShow", function(self)
		--print("HIDE")
		--PVEFrame:Hide()
		--miog.pveFrame2:Show()
	
	--end)
	--PVEFrame:HookScript("OnHide", function(self) miog.pveFrame2:Hide() end)

---@diagnostic disable-next-line: undefined-field
	miog.createFrameBorder(frame.QueuePanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

---@diagnostic disable-next-line: undefined-field
	queueSystem.framePool = CreateFramePool("Frame", miog.pveFrame2.QueuePanel.Container, "MIOG_QueueFrame", resetQueueFrame)

	local searchBox = LFGListFrame.SearchPanel.SearchBox
	searchBox:ClearAllPoints()
	searchBox:SetParent(frame)
	---@diagnostic disable-next-line: undefined-field
	searchBox:SetPoint(frame.SearchBox:GetPoint())
	searchBox:SetFrameStrata("DIALOG")

	LFGListFrame.SearchPanel.SearchBox:Hide()
	--[[searchBox:SetScript("OnEnterPressed", function(self)
		local parent = self:GetParent();

		if ( parent.AutoCompleteFrame:IsShown() and parent.AutoCompleteFrame.selected ) then
			C_LFGList.SetSearchToActivity(parent.AutoCompleteFrame.selected);
		end

		miog.requestSearchResults(miog.pveFrame2.categoryID, miog.pveFrame2.filters)
		self:ClearFocus();
	
	end)]]

---@diagnostic disable-next-line: undefined-field
	local rolePanel = frame.RolePanel
	--rolePanel:SetPoint("BOTTOM", frame.QueueDropdown, "TOP", 0, 5)
	miog.createFrameBorder(rolePanel, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())

	local leader, tank, healer, damager = LFDQueueFrame_GetRoles()

	rolePanel.Leader.Checkbox:SetChecked(leader)
	rolePanel.Leader.Checkbox:SetScript("OnClick", function(self)
		SetLFGRoles(rolePanel.Leader.Checkbox:GetChecked(), rolePanel.Tank.Checkbox:GetChecked(), rolePanel.Healer.Checkbox:GetChecked(), rolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(rolePanel.Tank.Checkbox:GetChecked(), rolePanel.Healer.Checkbox:GetChecked(), rolePanel.Damager.Checkbox:GetChecked())
	end)

	rolePanel.Tank.Checkbox:SetChecked(tank)
	rolePanel.Tank.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["TANK"])
	rolePanel.Tank.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["TANK"])
	rolePanel.Tank.Checkbox:SetScript("OnClick", function(self)
		SetLFGRoles(rolePanel.Leader.Checkbox:GetChecked(), rolePanel.Tank.Checkbox:GetChecked(), rolePanel.Healer.Checkbox:GetChecked(), rolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(rolePanel.Tank.Checkbox:GetChecked(), rolePanel.Healer.Checkbox:GetChecked(), rolePanel.Damager.Checkbox:GetChecked())
	end)

	rolePanel.Healer.Checkbox:SetChecked(healer)
	rolePanel.Healer.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["HEALER"])
	rolePanel.Healer.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["HEALER"])
	rolePanel.Healer.Checkbox:SetScript("OnClick", function(self)
		SetLFGRoles(rolePanel.Leader.Checkbox:GetChecked(), rolePanel.Tank.Checkbox:GetChecked(), rolePanel.Healer.Checkbox:GetChecked(), rolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(rolePanel.Tank.Checkbox:GetChecked(), rolePanel.Healer.Checkbox:GetChecked(), rolePanel.Damager.Checkbox:GetChecked())
	end)

	rolePanel.Damager.Checkbox:SetChecked(damager)
	rolePanel.Damager.Checkbox:SetEnabled(miog.C.AVAILABLE_ROLES["DAMAGER"])
	rolePanel.Damager.Icon:SetDesaturated(not miog.C.AVAILABLE_ROLES["DAMAGER"])
	rolePanel.Damager.Checkbox:SetScript("OnClick", function(self)
		SetLFGRoles(rolePanel.Leader.Checkbox:GetChecked(), rolePanel.Tank.Checkbox:GetChecked(), rolePanel.Healer.Checkbox:GetChecked(), rolePanel.Damager.Checkbox:GetChecked())
		SetPVPRoles(rolePanel.Tank.Checkbox:GetChecked(), rolePanel.Healer.Checkbox:GetChecked(), rolePanel.Damager.Checkbox:GetChecked())
	end)

	--local optionDropdown = miog.createBasicFrame("persistent", "UIDropDownMenuTemplate", frame, 200, 20)
	--optionDropdown:SetPoint("TOP", rolePanel, "BOTTOM", 0, 0)
	--UIDropDownMenu_SetWidth(optionDropdown, 160)
	--frame.QueueDropdown = optionDropdown

	--PVPQueueFrame_ShowFrame(HonorFrame)
	PVEFrame_ShowFrame("PVPUIFrame", "HonorFrame")

	--local queueDropDown = Mixin(CreateFrame("Frame", nil, frame, "MIOG_DropDownMenu"), SlickDropDown) --CreateFrame("Frame", nil, frame, "MIOG_DropDownMenu") ---@class Frame
---@diagnostic disable-next-line: undefined-field
	local queueDropDown = frame.QueueDropDown
	queueDropDown:OnLoad()
	--miog.createFrameBorder(queueDropDown, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
	--queueDropDown:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	--queueDropDown.framePool = CreateFramePool("Frame", queueDropDown.List, "MIOG_DropDownMenuEntry", resetDropDownListFrame)
	--queueDropDown.entryFrameTree = {}
	--queueDropDown.List.entryTable = {}
	--miog.pveFrame2.QueueDropDown = queueDropDown
	
end

local function updateRandomDungeons()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.pveFrame2.QueueDropDown
	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil

	for i=1, GetNumRandomDungeons() do
				
		local id, name, typeID, subtypeID, _, _, _, _, _, _, _, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon = GetLFGRandomDungeonInfo(i)
		--print(id, name, typeID, subtypeID, isHolidayDungeon)
		
---@diagnostic disable-next-line: redundant-parameter
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);

		--print(id, name)
		if((isAvailableForPlayer or not hideIfNotJoinable)) then
			if isAvailableForAll then
				local mode = GetLFGMode(1, id)
				info.text = isHolidayDungeon and "(Event) " .. name or name

				info.checked = mode == "queued"
				info.icon = fileID or miog.MAP_INFO[id] and miog.MAP_INFO[id].icon or nil
				info.parentIndex = subtypeID

				info.func = function()
					--JoinSingleLFG(1, dungeonID)
					ClearAllLFGDungeons(1);
					SetLFGDungeon(1, id);
					--JoinLFG(LE_LFG_CATEGORY_RF);
					JoinSingleLFG(1, id);
				end
				--print(typeID)
				-- UIDropDownMenu_AddButton(info, level)
				local tempFrame = queueDropDown:CreateEntryFrame(info)
				tempFrame:SetScript("OnShow", function(self)
					local tempMode = GetLFGMode(1, id)
					self.Radio:SetChecked(tempMode == "queued")
					
				end)

			end
		end
	end
end

local function updateDungeons()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.pveFrame2.QueueDropDown
	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil

	local dungeonList = GetLFDChoiceOrder() or {}

	for _, dungeonID in ipairs(dungeonList) do
---@diagnostic disable-next-line: redundant-parameter
		local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID);
		local name, typeID, subtypeID, _, _, _, _, _, expLevel, groupID, fileID, difficultyID, _, _, isHolidayDungeon, _, _, isTimewalkingDungeon, name2, minGearLevel, isScalingDungeon, lfgMapID = GetLFGDungeonInfo(dungeonID)

		--miog.GROUP_ID_TO_LFG_ID[groupID == 0 and 0 or (groupID * -1)] = {mapID = lfgMapID, icon = fileID, difficultyID = difficultyID}
		--print(name, difficultyID, groupID, lfgMapID, dungeonID)
		local groupActivityID = miog.MAP_ID_TO_GROUP_ACTIVITY_ID[lfgMapID]

		if(groupActivityID and not miog.GROUP_ACTIVITY[groupActivityID]) then
			miog.GROUP_ACTIVITY[groupActivityID] = {mapID = lfgMapID, file = fileID}
			--print("miog.GROUP_ACTIVITY[" .. groupActivityID .. "] = {mapID = " .. lfgMapID .. ", file = " .. fileID .. "}")
		end

		local isFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID)

		--if(not LFGLockList[dungeonID] and typeID == menuList) then
		if((isAvailableForPlayer or not hideIfNotJoinable) and (subtypeID and difficultyID < 3 and not isFollowerDungeon or isFollowerDungeon)) then
			--local isLFGFollowerDungeon = dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID);
		--print(name)
			local mode = GetLFGMode(1, dungeonID)
			info.text = isHolidayDungeon and "(Event) " .. name or name
			info.checked = mode == "queued"
			info.icon = fileID or miog.MAP_INFO[lfgMapID] and miog.MAP_INFO[lfgMapID].icon or nil
			info.parentIndex = isFollowerDungeon and 3 or subtypeID
			info.func = function()
				--print(name, dungeonID)
				--JoinSingleLFG(1, dungeonID)
				ClearAllLFGDungeons(1);
				SetLFGDungeon(1, dungeonID);
				--JoinLFG(LE_LFG_CATEGORY_RF);
				JoinSingleLFG(1, dungeonID);

				--LFGRole_SetChecked(tankButton, tank);
				--LFGRole_SetChecked(healButton, healer);
				--LFGRole_SetChecked(dpsButton, dps);

				--if ( leaderButton ) then
				--	leaderButton.checkButton:SetChecked(leader);
				--endless

			end
			--print(typeID)
			-- UIDropDownMenu_AddButton(info, level)
				local tempFrame = queueDropDown:CreateEntryFrame(info)
				tempFrame:SetScript("OnShow", function(self)
					local tempMode = GetLFGMode(1, dungeonID)
					self.Radio:SetChecked(tempMode == "queued")
					
				end)
		--print(dungeonID, name)
			
		end
	end

	--DevTools_Dump(miog.GROUP_ID_TO_LFG_ID)
end

local function updateRaidFinder()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.pveFrame2.QueueDropDown
	if(queueDropDown.entryFrameTree[4].List.framePool) then
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

		if (playerLevel >= minLevel and playerLevel <= maxLevel) then
			local mode = GetLFGMode(3, id)
			info.text = isHolidayDungeon and "(Event) " .. name or name
			info.checked = mode == "queued"
			info.icon = fileID
			info.func = function()
				--JoinSingleLFG(1, dungeonID)
				ClearAllLFGDungeons(3);
				SetLFGDungeon(3, id);
				--JoinLFG(LE_LFG_CATEGORY_RF);
				JoinSingleLFG(3, id);
			end
			--print(typeID)
			-- UIDropDownMenu_AddButton(info, level)
				local tempFrame = queueDropDown:CreateEntryFrame(info)
				tempFrame:SetScript("OnShow", function(self)
					local tempMode = GetLFGMode(3, id)
					self.Radio:SetChecked(tempMode == "queued")
					
				end)

			nextLevel = nil;
		elseif ( playerLevel < minLevel and (not nextLevel or minLevel < nextLevel ) ) then
			nextLevel = minLevel;
		end
	end
end

local function findBattlegroundIconByName(mapName)
	for bgID, bgEntry in pairs(miog.BATTLEGROUNDS) do
		if(bgEntry[2] == mapName) then
			--print("HIT", mapName)
			return bgEntry[16] ~= 0 and bgEntry[16] or 525915
		end
	end

	return nil
end

local function findBattlegroundIconByID(mapID)
	for bgID, bgEntry in pairs(miog.BATTLEGROUNDS) do
		if(bgEntry[1] == mapID) then
			return bgEntry[16] ~= 0 and bgEntry[16] or 525915
		end
	end

	return nil
end

local function findBrawlIconByName(mapName)
	for brawlID, brawlEntry in pairs(miog.BRAWL) do
		if(brawlEntry[2] == mapName) then
			return findBattlegroundIconByID(brawlEntry[4])
		end
	end

	return nil
end

local function findBrawlIconByID(mapID)
	for brawlID, brawlEntry in pairs(miog.BRAWL) do
		if(brawlEntry[1] == mapID) then
			return findBattlegroundIconByID(brawlEntry[4])
		end
	end

	return nil
end

local function updatePvP()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.pveFrame2.QueueDropDown

	if(queueDropDown.entryFrameTree[5].List.framePool) then
		queueDropDown.entryFrameTree[5].List.framePool:ReleaseAll()
	end

	local info = {}
	info.entryType = "option"
	info.level = 2
	info.index = nil
	info.parentIndex = 5
	info.type2 = "unrated"
	
	--for bgIndex = 1, GetNumBattlegroundTypes() do
	--	local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers, gameType, iconTexture, shortDescription, longDescription = GetBattlegroundInfo(bgIndex);

	--	bgIDToIcon[battleGroundID] = iconTexture
	--end

	for index = 1, 5, 1 do
		local currentBGQueue = index == 1 and C_PvP.GetRandomBGInfo() or index == 2 and C_PvP.GetRandomEpicBGInfo() or index == 3 and C_PvP.GetSkirmishInfo(4) or index == 4 and C_PvP.GetAvailableBrawlInfo() or C_PvP.GetSpecialEventBrawlInfo()

		if(currentBGQueue and (index == 3 or currentBGQueue.canQueue)) then
			info.text = index == 1 and RANDOM_BATTLEGROUNDS or index == 2 and RANDOM_EPIC_BATTLEGROUND or index == 3 and "Skirmish" or currentBGQueue.name
			-- info.checked = false
			--info.disabled = index == 1 or index == 2
			info.icon = index < 3 and findBattlegroundIconByID(currentBGQueue.bgID) or index == 3 and currentBGQueue.icon or index > 3 and findBrawlIconByID(currentBGQueue.brawlID)
			info.func = nil

			-- UIDropDownMenu_AddButton(info, level)
			local tempFrame = queueDropDown:CreateEntryFrame(info)

			if(currentBGQueue.bgID) then
				if(currentBGQueue.bgID == 32) then
					--tempFrame.ExtraButton = HonorFrame.BonusFrame.RandomBGButton
					queueDropDown:CreateExtraButton(HonorFrame.BonusFrame.RandomBGButton, tempFrame)

				elseif(currentBGQueue.bgID == 901) then
					--tempFrame.ExtraButton = HonorFrame.BonusFrame.RandomEpicBGButton
					queueDropDown:CreateExtraButton(HonorFrame.BonusFrame.RandomEpicBGButton, tempFrame)

				end
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
			
				tempFrame:SetAttribute("original", tempFrame:GetAttribute("macrotext1"))
			end
		end

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
		

	info.text = PVP_RATED_SOLO_SHUFFLE
	-- info.checked = false
	local minItemLevel = C_PvP.GetRatedSoloShuffleMinItemLevel()
	local _, _, playerPvPItemLevel = GetAverageItemLevel();
	info.disabled = playerPvPItemLevel < minItemLevel
	--info.icon = bgIDToIcon[currentBGQueue.bgID]
	
	info.tooltipOnButton = true
	info.tooltipWhileDisabled = true
	info.type2 = "rated"
	info.tooltipTitle = "Unable to queue for this activity."
	info.tooltipText = generalTooltip or format(_G["INSTANCE_UNAVAILABLE_SELF_PVP_GEAR_TOO_LOW"], "", minItemLevel, playerPvPItemLevel);
	info.func = nil
	--info.func = function()
	--	JoinRatedSoloShuffle()
	-- end

	-- UIDropDownMenu_AddButton(info, level)
	local soloFrame = queueDropDown:CreateEntryFrame(info)
	queueDropDown:CreateExtraButton(ConquestFrame.RatedSoloShuffle, soloFrame)

	info.text = ARENA_BATTLES_2V2
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 2 and string.format(PVP_ARENA_NEED_LESS, groupSize - 2) or groupSize < 2 and string.format(PVP_ARENA_NEED_MORE, 2 - groupSize)
	info.disabled = groupSize ~= 2
	--info.func = function()
	--	JoinArena()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local twoFrame = queueDropDown:CreateEntryFrame(info)
	queueDropDown:CreateExtraButton(ConquestFrame.Arena2v2, twoFrame)

	info.text = ARENA_BATTLES_3V3
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 3 and string.format(PVP_ARENA_NEED_LESS, groupSize - 3) or groupSize < 3 and string.format(PVP_ARENA_NEED_MORE, 3 - groupSize)
	info.disabled = generalTooltip or groupSize ~= 3
	--info.func = function()
	--	JoinArena()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local threeFrame = queueDropDown:CreateEntryFrame(info)
	queueDropDown:CreateExtraButton(ConquestFrame.Arena3v3, threeFrame)

	info.text = PVP_RATED_BATTLEGROUNDS
	-- info.checked = false
	info.type2 = "rated"
	info.tooltipText = generalTooltip or groupSize > 10 and string.format(PVP_RATEDBG_NEED_LESS, groupSize - 10) or groupSize < 10 and string.format(PVP_RATEDBG_NEED_MORE, 10 - groupSize)
	info.disabled = generalTooltip or groupSize ~= 10
	--info.func = function()
	--	JoinRatedBattlefield()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	local tenFrame = queueDropDown:CreateEntryFrame(info)
	queueDropDown:CreateExtraButton(ConquestFrame.RatedBG, tenFrame)

	info.text = LFG_LIST_MORE
	-- info.checked = false
	--info.tooltipText = generalTooltip or groupSize > 10 and string.format(PVP_RATEDBG_NEED_LESS, groupSize - 10) or groupSize < 10 and string.format(PVP_RATEDBG_NEED_MORE, 10 - groupSize)
	--info.disabled = generalTooltip or groupSize ~= 10
	info.type2 = "more"
	info.disabled = nil
	--info.func = function()
	--	JoinRatedBattlefield()
	--end

	-- UIDropDownMenu_AddButton(info, level)
	queueDropDown:CreateEntryFrame(info)
end

miog.updatePvP = updatePvP

local function updateQueueDropDown()
	---@diagnostic disable-next-line: undefined-field
	local queueDropDown = miog.pveFrame2.QueueDropDown
	queueDropDown.List.framePool:ReleaseAll()

	print("UPDATE QUEUE")
--SetLFGDungeon(LE_LFG_CATEGORY_RF, RaidFinderQueueFrame.raid);
	--JoinLFG(LE_LFG_CATEGORY_RF);
	--JoinSingleLFG(LE_LFG_CATEGORY_RF, RaidFinderQueueFrame.raid);
	--LFG_QueueForInstanceIfEnabled(category, queueID);
	--IsLFGDungeonJoinable
	
	--[[function LFG_QueueForInstanceIfEnabled(category, queueID)
		if ( not LFGIsIDHeader(queueID) and LFGEnabledList[queueID] and not LFGLockList[queueID] ) then
			SetLFGDungeon(category, queueID);
			return true;
		end
		return false;
	end]]

	--SetLFGDungeon(3, 2368)
	--JoinLFG(3)
	--SetLFGDungeon(3, 2370)
	--JoinLFG(3)
	--SetLFGDungeon(3, 2399)
	--JoinLFG(3)
	--SetLFGDungeon(3, 2400)
	--JoinLFG(3)
	

	--[[local function GetLFGLockList()
		local lockInfo = C_LFGInfo.GetLFDLockStates();
		local lockMap = {};
		for _, lock in ipairs(lockInfo) do
			lockMap[lock.lfgID] = lock;
		end
		return lockMap;
	end

	--local LFGLockList = GetLFGLockList()
	LFGEnabledList = GetLFDChoiceEnabledState(LFGEnabledList)]]
	
 
	--UIDropDownMenu_Initialize(optionDropdown, function(self, level, menuList)
		--local info = UIDropDownMenu_CreateInfo()

		--[[info.text = "Dungeons"
		-- info.checked = false
		-- info.menuList = 1
		-- info.hasArrow = true
		-- UIDropDownMenu_AddButton(info)

		info.text = "Raid"
		-- info.checked = false
		-- info.menuList = 2
		-- info.hasArrow = true
		-- UIDropDownMenu_AddButton(info)

		info.text = "Outdoor"
		-- info.checked = false
		-- info.menuList = 4
		-- info.hasArrow = true
		-- UIDropDownMenu_AddButton(info)

		info.text = "Random Dungeon"
		-- info.checked = false
		-- info.menuList = 6
		-- info.hasArrow = true
		-- UIDropDownMenu_AddButton(info)

		for _, dungeonID in ipairs(dungeonList) do
			local name, typeID = GetLFGDungeonInfo(dungeonID)

			if not LFGLockList[dungeonID] then
				--print(name)
					info.text = name
					-- info.checked = false
					print(typeID)
					-- UIDropDownMenu_AddButton(info, typeID)
				--print(dungeonID, name)
				
			end
		end]]

		local info = {}
		--[[infoTable.entryType = "option"
		infoTable.index = activityInfo.orderIndex
		infoTable.value = activityID
		infoTable.name = activityInfo.fullName
		if(miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID]) then
			infoTable.icon = miog.MAP_INFO[miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].mapID].icon

		end

		local dropDownEntryFrame = createDropDownEntry(miog.entryCreation.ActivityDropDown, infoTable)

		dropDownEntryFrame:SetScript("OnMouseDown", function(self)
			self.Radio:SetChecked(true)

			local dropDownMenuList = self:GetParent()
			dropDownMenuList:GetParent().CheckedValue.Name:SetText(activityInfo.fullName)
			dropDownMenuList:Hide()
		end)]]

		--if (level or 1) == 1 then
			info.text = "Dungeons (Normal)"
			info.entryType = "arrow"
			info.level = 1
			info.index = 1
			-- info.checked = false
			-- info.menuList = 1
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "Dungeons (Heroic)"
			info.entryType = "arrow"
			info.level = 1
			info.index = 2
			-- info.checked = false
			-- info.menuList = 2
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "Follower"
			info.entryType = "arrow"
			info.level = 1
			info.index = 3
			-- info.checked = false
			-- info.menuList = 3
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "Raid Finder"
			info.entryType = "arrow"
			info.level = 1
			info.index = 4
			-- info.checked = false
			-- info.menuList = 4
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)

			info.text = "PvP"
			info.entryType = "arrow"
			info.level = 1
			info.index = 5
			-- info.checked = false
			-- info.menuList = 7
			-- info.hasArrow = true
			-- UIDropDownMenu_AddButton(info)
			queueDropDown:CreateEntryFrame(info)
		
		--else
			
			-- Display a nested group of 10 favorite number options
			--info.func = self.SetValue
			--for i=menuList*10, menuList*10+9 do
			--info.text, info.arg1, -- info.checked = i, i, i == favoriteNumber
			---- UIDropDownMenu_AddButton(info, level)
			--end

			local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable

			info.entryType = "option"
			info.level = 2
			info.index = nil

			updateRandomDungeons()
			updateDungeons()
			updateRaidFinder()
			updatePvP()

			
		--end

		--if(menuList == 7) then

			--HonorFrame.BonusFrame.Arena1Button:Hide()
			--HonorFrame.BonusFrame.BrawlButton:Hide()
			--HonorFrame.BonusFrame.BrawlButton2:Hide()

			

			--[===[for index = 1, GetNumBattlegroundTypes() do
				local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers, gameType, iconTexture, shortDescription, longDescription = GetBattlegroundInfo(index);
				info.text = localizedName
				-- info.checked = false
				info.func = nil
				info.disabled = true
				info.icon = bgIDToIcon[battleGroundID]
				
				--[[info.func = function()
					JoinBattlefield(battleGroundID)
				end]]

				if localizedName and canEnter and not isRandom then
					--info.disabled = false
					info.tooltipText = nil
					info.tooltipTitle = nil
				else
					--info.disabled = generalTooltip
					info.tooltipTitle = "Unable to queue for this activity."
					info.tooltipText = generalTooltip

				end

				-- UIDropDownMenu_AddButton(info, level)
				local tempFrame = queueDropDown:CreateEntryFrame(info)
				local baseFrame = HonorFrame.SpecificScrollBox:FindFrameByPredicate(function(elementData)
					return elementData.bgID == battleGroundID
				end)

				if(baseFrame) then
					queueDropDown:CreateExtraButton(baseFrame, tempFrame)
				end
			end]===]

			--[[if ( ConquestFrame.selectedButton.id == RATED_SOLO_SHUFFLE_BUTTON_ID) then
			elseif ( groupSize == 0 ) then
				button.tooltip = PVP_NO_QUEUE_GROUP;
			elseif ( not UnitIsGroupLeader("player") ) then
				button.tooltip = PVP_NOT_LEADER;
			else
				local neededSize = CONQUEST_SIZES[ConquestFrame.selectedButton.id];
				local token, loopMax;
				if (groupSize > (MAX_PARTY_MEMBERS + 1)) then
					token = "raid";
					loopMax = groupSize;
				else
					token = "party";
					loopMax = groupSize - 1; -- player not included in party tokens, just raid tokens
				end
				if ( neededSize == groupSize ) then
					local validGroup = true;
					local teamIndex = ConquestFrame.selectedButton.teamIndex;
					-- Rated activities require a max level party/raid
					local maxLevel = GetMaxLevelForLatestExpansion();
					for i = 1, loopMax do
						if ( not UnitIsConnected(token..i) ) then
							validGroup = false;
							button.tooltip = PVP_NO_QUEUE_DISCONNECTED_GROUP;
							break;
						elseif ( UnitLevel(token..i) < maxLevel ) then
							validGroup = false;
							button.tooltip = PVP_NO_QUEUE_GROUP;
							break;
						end
					end
					if ( validGroup ) then
						if ( not GetSpecialization() ) then
							button.tooltip = SPELL_FAILED_CUSTOM_ERROR_122;
						else
							button.tooltip = nil;
							button:Enable();
							return;
						end
					end
				elseif ( neededSize > groupSize ) then
					if ( ConquestFrame.selectedButton.id == RATED_BG_BUTTON_ID ) then
						button.tooltip = string.format(PVP_RATEDBG_NEED_MORE, neededSize - groupSize);
					else
						button.tooltip = string.format(PVP_ARENA_NEED_MORE, neededSize - groupSize);
					end
				else
					if ( ConquestFrame.selectedButton.id == RATED_BG_BUTTON_ID ) then
						button.tooltip = string.format(PVP_RATEDBG_NEED_LESS, groupSize -  neededSize);
					else
						button.tooltip = string.format(PVP_ARENA_NEED_LESS, groupSize -  neededSize);
					end
				end]]

			--[[info.text = ARENA_BATTLES_2V2
			-- info.checked = false
			info.func = function()
				--JoinRatedSoloShuffle()
			end

			-- UIDropDownMenu_AddButton(info, level)
				
			

			if (ConquestFrame.selectedButton.id == RATED_SOLO_SHUFFLE_BUTTON_ID) then
				JoinRatedSoloShuffle();
			elseif (ConquestFrame.selectedButton.id == RATED_BG_BUTTON_ID) then
				JoinRatedBattlefield();
			else
				JoinArena();
			end]]
		--end
	--end)


	--[[local HonorFrame = HonorFrame;
	if ( HonorFrame.type == "specific" and HonorFrame.SpecificScrollBox.selectionID ) then
		JoinBattlefield(HonorFrame.SpecificScrollBox.selectionID);
	elseif ( HonorFrame.type == "bonus" and HonorFrame.BonusFrame.selectedButton ) then
		if ( HonorFrame.BonusFrame.selectedButton.arenaID ) then
			JoinSkirmish(HonorFrame.BonusFrame.selectedButton.arenaID);
		elseif (HonorFrame.BonusFrame.selectedButton.queueID) then
			ClearAllLFGDungeons(LE_LFG_CATEGORY_WORLDPVP);
			JoinSingleLFG(LE_LFG_CATEGORY_WORLDPVP, HonorFrame.BonusFrame.selectedButton.queueID);
		elseif (HonorFrame.BonusFrame.selectedButton.isBrawl) then
			C_PvP.JoinBrawl();
		elseif (HonorFrame.BonusFrame.selectedButton.isSpecialBrawl) then
			C_PvP.JoinBrawl(true);
		else
			JoinBattlefield(HonorFrame.BonusFrame.selectedButton.bgID);
		end
	end]]

	--for index = 1, GetNumBattlegroundTypes() do
	--	local localizedName, canEnter, isHoliday, isRandom, battleGroundID, mapDescription, BGMapID, maxPlayers, gameType, iconTexture, shortDescription, longDescription = GetBattlegroundInfo(index);
		--print(localizedName, battleGroundID, isHoliday, isRandom, gameType)
	--end

end

miog.updateQueueDropDown = updateQueueDropDown

local queueFrameIndex = 0

local queuedList = {};

hooksecurefunc(QueueStatusFrame, "Update", function()
	--print("LFG")

	queueSystem.queueFrames = {}
	queueSystem.framePool:ReleaseAll()

	local queueIndex = 1

	--Try each LFG type
	for categoryID = 1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(categoryID);

		if (mode and submode ~= "noteleport" ) then

			local activeIndex = nil;
			local allNames = {};

				--Get the list of everything we're queued for
			queuedList = GetLFGQueuedList(categoryID, queuedList) or {}
		
			local activeID = select(18, GetLFGQueueStats(categoryID));
			for queueID, queued in pairs(queuedList) do
				mode, submode = GetLFGMode(categoryID, queueID);
				if ( mode ) then
					--Save off the name (we'll remove the active one later)
					allNames[#allNames + 1] = queueID
					if ( mode ~= "queued" and mode ~= "listed" and mode ~= "suspended" ) then
						activeID = queueID;
						activeIndex = #allNames;
					elseif ( not activeID ) then
						activeID = queueID;
						activeIndex = #allNames;
					end
				end

				if(queued == true) then
					--local inParty, joined, isQueued, noPartialClear, achievements, lfgComment, slotCount, categoryID2, leader, tank, healer, dps, x1, x2, x3, x4 = GetLFGInfoServer(categoryID, queueID);
					local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, activeID or queueID)
					--print(activeID, queueID, averageWait, tankWait, healerWait, damageWait, myWait)
					--print(queueID, hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime)

					--DevTools_Dump({GetLFGQueueStats(categoryID, queueID)})

					local name, typeID, subTypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)

					local queueStats = {
						[1] = hasData,
						[11] = name,
						[12] = averageWait,
						[17] = queuedTime,
						[18] = queueID,
						[19] = categoryID == 1 and "LFD" or categoryID == 3 and "LFR",
						[20] = miog.MAP_INFO[queueID] and miog.MAP_INFO[queueID].icon or fileID or nil
					}

					if(hasData) then
						miog.createQueueFrame(queueStats)

						if(categoryID == 3 and activeID == queueID) then
							miog.queueSystem.queueFrames[queueID].ActiveIDFrame:Show()

						else
							miog.queueSystem.queueFrames[queueID].ActiveIDFrame:Hide()
						
						end

						miog.queueSystem.queueFrames[queueID].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
						miog.queueSystem.queueFrames[queueID].CancelApplication:SetAttribute("macrotext1", "/run LeaveSingleLFG(" .. categoryID .. "," .. queueID .. ")")

						--print(miog.queueSystem.queueFrames[queueID].CancelApplication:GetAttribute("macrotext1"))
					
						--[[miog.queueSystem.queueFrames[queueID].CancelApplication:SetScript("PostClick", function(self, button)
							if(button == "LeftButton") then
								local mode2, submode2 = GetLFGMode(categoryID, queueID)
								print(categoryID, queueID, mode2, submode2)
								LeaveSingleLFG(categoryID, queueID)
							end
						end)]]
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
	
						if (hasData and queuedTime and not miog.queueSystem.queueFrames[dungeonID]) then
							miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(dungeonID)}, {GetLFGQueueStats(categoryID)})
						end
					end
				end
			end]]
			
			queueIndex = queueIndex + 1
		end
	end

	--Try LFGList entries
	local isActive = C_LFGList.HasActiveEntryInfo();
	if ( isActive ) then
		--local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
		--local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants();
		--QueueStatusEntry_SetMinimalDisplay(entry, activeEntryInfo.name, QUEUED_STATUS_LISTED, string.format(LFG_LIST_PENDING_APPLICANTS, numActiveApplicants));

		--miog.createQueueFrame(categoryID, {GetLFGDungeonInfo(activeID)}, {GetLFGQueueStats(categoryID)})
	end
--[[
	--Try LFGList applications
	local apps = C_LFGList.GetApplications();
	for i=1, #apps do
		local _, appStatus = C_LFGList.GetApplicationInfo(apps[i])

		if ( appStatus == "applied" or appStatus == "invited" ) then
			QueueStatusEntry_SetUpLFGListApplication(entry, apps[i]);

			if ( appStatus == "applied" ) then
			end
		end
	end 

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
		local status, mapName, teamSize, registeredMatch, suspend, _, _, _, _, _, longDescription, x1 = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			
			if ( status == "queued" ) then
				if ( suspend ) then
					--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_SUSPENDED);
				else
					local queuedTime = GetTime() - GetBattlefieldTimeWaited(i) / 1000
---@diagnostic disable-next-line: redundant-parameter
					local estimatedTime = GetBattlefieldEstimatedWaitTime(i) / 1000
					local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
					local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);
					--QueueStatusEntry_SetFullDisplay(entry, mapName, queuedTime, estimatedTime, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText, assignedSpec);


					--local isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
					--local assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(i);

					--		1		2			3			4			5			6			7				8		9				10				11				12			13			14			15		16			17
					--local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime

					--print(mapName, queueType, short, long)
					

					local queueStats = {
						[1] = true,
						[11] = mapName,
						[12] = estimatedTime,
						[17] = queuedTime,
						[18] = mapName,
						[19] = "BATTLEGROUND",
						[20] = findBattlegroundIconByName(mapName) or findBrawlIconByName(mapName)
					}

					--BattlemasterList
					--PvpBrawl

					if (mapName and queuedTime) then
						--print("NEW PVP")
						miog.createQueueFrame(queueStats)
						--print("CREATED " .. mapName)
						--miog.queueSystem.queueFrames[mapName].CancelApplication:SetScript("OnClick",  SecureActionButton_OnClick)
					end

					if(miog.queueSystem.queueFrames[mapName]) then
						--print("PVP MACRO")
						miog.queueSystem.queueFrames[mapName].CancelApplication:SetAttribute("type", "macro") -- left click causes macro
						miog.queueSystem.queueFrames[mapName].CancelApplication:SetAttribute("macrotext1", queueIndex == 1 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button2 Left Button"
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
						or queueIndex == 12 and "/click QueueStatusButton RightButton" .. "\r\n" .. "/click [nocombat]DropDownList1Button24 Left Button")

						--print(miog.queueSystem.queueFrames[mapName].CancelApplication:GetAttribute("macrotext1"))
					end

					queueIndex = queueIndex + 1
					

				end
			elseif ( status == "confirm" ) then
				--QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_PROPOSAL);
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
			--print(mapName)
		
		end
	end

	--Try all World PvP queues
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID = GetWorldPVPQueueStatus(i);
		if ( status and status ~= "none" ) then
			--QueueStatusEntry_SetUpWorldPvP(entry, i);

			if ( status == "queued" ) then
			end
		end
	end

	--World PvP areas we're currently in
	if ( CanHearthAndResurrectFromArea() ) then
		--QueueStatusEntry_SetUpActiveWorldPVP(entry);
	end

	--Pet Battle PvP Queue
	local pbStatus = C_PetBattles.GetPVPMatchmakingInfo();
	if ( pbStatus ) then
		--QueueStatusEntry_SetUpPetBattlePvP(entry);

		if ( pbStatus == "queued" ) then
		end
	end
end)

local function createQueueFrame(queueInfo)
	local queueFrame = queueSystem.queueFrames[queueInfo[18]]

	if(not queueSystem.queueFrames[queueInfo[18]]) then
		queueFrame = queueSystem.framePool:Acquire()
		queueFrame.ActiveIDFrame:Hide()
		queueFrame.CancelApplication:SetMouseClickEnabled(true)
		queueFrame.CancelApplication:RegisterForClicks("LeftButtonDown")

		miog.createFrameBorder(queueFrame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR_3):GetRGBA())
		queueSystem.queueFrames[queueInfo[18]] = queueFrame

		queueFrameIndex = queueFrameIndex + 1
		queueFrame.layoutIndex = queueFrameIndex
	
	end
	
	queueFrame:SetBackdropColor(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	queueFrame.Name:SetText(queueInfo[11])

	local ageNumber = GetTime() - queueInfo[17]
	queueFrame.Age:SetText(miog.secondsToClock(ageNumber))

	queueFrame.Age.Ticker = C_Timer.NewTicker(1, function()
		ageNumber = ageNumber + 1
		queueFrame.Age:SetText(miog.secondsToClock(ageNumber))

	end)

	if(queueInfo[20]) then
		queueFrame.Icon:SetTexture(queueInfo[20])
	end

	queueFrame.Wait:SetText("(" .. (queueInfo[12] ~= -1 and miog.secondsToClock(queueInfo[12]) or "N/A") .. ")")

	--/run DevTools_Dump(C_PvP.GetAvailableBrawlInfo())
	--/run DevTools_Dump(C_PvP.GetSpecialEventBrawlInfo())
	--/run DevTools_Dump()
	--/run DevTools_Dump()
	--/run DevTools_Dump()

	queueFrame:SetShown(true)

---@diagnostic disable-next-line: undefined-field
	miog.pveFrame2.QueuePanel.Container:MarkDirty()
end

miog.createQueueFrame = createQueueFrame

miog.createPVEFrameReplacement = createPVEFrameReplacement