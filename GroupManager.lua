local addonName, miog = ...
local wticc = WrapTextInColorCode

local fullPlayerName, shortName, realm
local currentInspectionName = ""
local playersWithSpecData, inspectableMembers = 0, 0

local groupData = {}

local lastNotifyTime = 0
local pityTimer = nil
local playerInInspection
local playerSpecs = {}
local playerKeystones = {}
local playerRaidData = {}
local playerMPlusData = {}
local playerGearData = {}
local inspectList = {}

local framePool

local function wipeAllData()
	playerSpecs = {}
	playerKeystones = {}
	playerRaidData = {}
	playerMPlusData = {}
	inspectList = {}
end

local function countPlayersWithSpecData()
	playersWithSpecData, inspectableMembers = 0, 0

	for _, data in pairs(groupData) do
		if(playerSpecs[data.fullName] and playerSpecs[data.fullName] ~= 0) then
			playersWithSpecData = playersWithSpecData + 1
		end
		
		if(CanInspect(data.unitID)) then
			inspectableMembers = inspectableMembers + 1
		
		end
	end
end

local function updateInspectionText()
	countPlayersWithSpecData()
	miog.setInspectionData(currentInspectionName, playersWithSpecData, inspectableMembers)
end



local function updateSingleCharacterKeystoneData(fullName, frameIsAvailable)
	if(not miog.GroupManager:IsShown()) then
		return
	end

	local frame = frameIsAvailable or miog.GroupManager.ScrollBox:FindFrameByPredicate(function(localFrame, data)
		return fullName == data.fullName

	end)

	if(frame) then
		if(playerKeystones[fullName]) then
			if(playerKeystones[fullName].keystoneShortName) then
				frame.Keystone:SetText("+" .. playerKeystones[fullName].keylevel .. " " .. playerKeystones[fullName].keystoneShortName)
	
			else
				frame.Keystone:SetText("---")
	
			end

			local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(playerKeystones[fullName].challengeMapID)

			if(miog.CHALLENGE_MODE_INFO[id]) then
				playerKeystones[fullName].keystoneShortName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[id].mapID].shortName
				--data.keystone = texture
				playerKeystones[fullName].keylevel = playerKeystones[fullName].level
				playerKeystones[fullName].keystoneFullName = mapName

			end
		end
	end
end

local function updateSingleCharacterSpecData(fullName, frameIsAvailable)
	if(not miog.GroupManager or not miog.GroupManager:IsShown()) then
		return
	end

	local frame = frameIsAvailable or miog.GroupManager.ScrollBox:FindFrameByPredicate(function(localFrame, data)
		return fullName == data.fullName

	end)

	if(frame) then
		frame.Spec:SetTexture(miog.SPECIALIZATIONS[playerSpecs[fullName] or 0].squaredIcon)

		frame.specID = playerSpecs[fullName]
	end
end

local function updateSingleCharacterItemData(fullName)
	if(not miog.GroupManager:IsShown()) then
		return
	end

	local frame = frameIsAvailable or miog.GroupManager.ScrollBox:FindFrameByPredicate(function(localFrame, data)
		return fullName == data.fullName

	end)


	local playerGear = playerGearData[fullName]

	if(frame) then
		if(playerGear) then
			if(playerGear.noEnchants and #playerGear.noEnchants > 0) then
				data.missingEnchants = {}

				for index, slotIdWithoutEnchant in ipairs (playerGear.noEnchants) do
					if(slotIdWithoutEnchant ~= 10) then
						data.missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
						
					end
				end
			end

			if(playerGear.noGems and #playerGear.noGems > 0) then
				data.missingGems = {}

				for index, slotIdWithEmptyGemSocket in ipairs (playerGear.noGems) do
					data.missingGems[index] = miog.SLOT_ID_INFO[slotIdWithEmptyGemSocket].localizedName
				end
			end
			
			frame.Itemlevel:SetText(playerGear.ilevel or "N/A")
			frame.Durability:SetText(playerGear.durability and "(" .. playerGear.durability .. "%)" or "N/A")
		end
	end
end

local function getOptionalPlayerData(libName, playerName, localRealm, unitID)
	local data = {}

	local playerGear = playerGearData[libName] or miog.openRaidLib.GetUnitGear(unitID)

	if(playerGear) then
		data.ilvl = playerGear.ilevel or 0
		data.durability = playerGear.durability or 0

		if(playerGear.noEnchants and #playerGear.noEnchants > 0) then
			data.missingEnchants = {}

			for index, slotIdWithoutEnchant in ipairs (playerGear.noEnchants) do
				if(slotIdWithoutEnchant ~= 10) then
					data.missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
					
				end
			end
		end

		if(playerGear.noGems and #playerGear.noGems > 0) then
			data.missingGems = {}

			for index, slotIdWithEmptyGemSocket in ipairs (playerGear.noGems) do
				data.missingGems[index] = miog.SLOT_ID_INFO[slotIdWithEmptyGemSocket].localizedName
			end
		end
	else
		data.ilvl = 0
		data.durability = 0

	end

	data.keylevel = 0

	if(playerKeystones[libName]) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(playerKeystones[libName].challengeMapID)

		if(miog.CHALLENGE_MODE_INFO[id]) then
			data.keystoneShortName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[id].mapID].shortName
			data.keylevel = playerKeystones[libName].level
			data.keystoneFullName = mapName

		end
	end
	
	playerMPlusData[libName] = playerMPlusData[libName] or miog.getMPlusScoreOnly(playerName, localRealm)
	playerRaidData[libName] = playerRaidData[libName] or miog.getNewRaidSortData(playerName, localRealm)

	data.progress = ""

	if(playerRaidData[libName]) then
		local raidTable = {}

		for _, v in ipairs(playerRaidData[libName].character.ordered) do
			if(v.difficulty > 0) then
				raidTable[v.mapID] = raidTable[v.mapID] or {}

				tinsert(raidTable[v.mapID], wticc(v.parsedString, miog.DIFFICULTY[v.difficulty].color) .. " ")
	
			end
		end

		local newTable = {}

		for k, v in pairs(raidTable) do
			data.progress = table.concat(v) .. "\r\n"

		end

		data.progressWeight = playerRaidData[libName].character.progressWeight or 0

	else
		data.progressWeight = 0
		data.progress = "---"

	end

	data.score = playerMPlusData[libName]

	return data
end

local function customMenu(self, type)
	local contextData

	if(type == "raid") then
		if self.id and self.name then
			contextData =
			{
				unit = self.unit,
				name = self.name;
			};
		end
	elseif(type == "party") then
		contextData =
		{
			unit = self.unit,
		};
	end

	UnitPopup_OpenMenu("MIOG_" .. strupper(type), contextData);
end

local function showIndepthData(data)
	local indepthFrame = miog.GroupManager.Indepth

	indepthFrame:Flush()

	indepthFrame.Name:SetText(data.fileName and WrapTextInColorCode(data.name, C_ClassColor.GetClassColor(data.fileName):GenerateHexColor()) or data.name)
	indepthFrame.Level:SetText("Level " .. data.level)

	local _, specName = GetSpecializationInfoForSpecID(data.specID)

	indepthFrame.Spec:SetText(specName and (specName .. " " .. data.className) or "???")

	--indepthFrame.Guild:SetText(GetGuildInfo(data.unitID) or "Currently guildless")

	indepthFrame:SetPlayerData(data.name, data.realm)
	indepthFrame:ApplyFillData()

	indepthFrame:Show()
end

local function updateGroupManagerPlayerFrame(frame, data)
	local rank, _, level, class, fileName, zone, online, isDead, role, isML, _

	if(data.index) then
		_, rank, _, level, class, fileName, zone, online, isDead, role, isML, _ = GetRaidRosterInfo(data.index) --ONLY WORKS WHEN IN GROUP

	else
		class, fileName = UnitClass("player")
		online = true
		level = UnitLevel("player")

	end

	frame.data = data
	frame.id = data.index
	frame.name = data.fullName
	frame.unit = data.unitID
	frame.specID = playerSpecs[data.fullName] or 0

	frame.Index:SetText(online and data.subgroup or WrapTextInColorCode(data.subgroup, miog.CLRSCC.red))
	frame.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. (data.combatRole .. "Icon.png" or "unknown.png"))
	frame.Name:SetText(fileName and WrapTextInColorCode(data.name, C_ClassColor.GetClassColor(fileName):GenerateHexColor()) or data.name)
	frame.Spec:SetTexture(miog.SPECIALIZATIONS[playerSpecs[data.fullName] or 0].squaredIcon)

	if(rank == 2) then
		miog.GroupManager.LeaderCrown:ClearAllPoints()
		miog.GroupManager.LeaderCrown:SetPoint("RIGHT", frame.Group, "RIGHT")
		miog.GroupManager.LeaderCrown:SetParent(frame)
		miog.GroupManager.LeaderCrown:Show()

	end

	frame.Itemlevel:SetText(data.ilvl or "N/A")
	frame.Durability:SetText(data.durability and "(" .. data.durability .. "%)" or "N/A")
	frame.Score:SetText(data.score or 0)
	frame.Progress:SetText(data.progress or "N/A")

	if(data.keystoneShortName) then
		frame.Keystone:SetText("+" .. data.keylevel .. " " .. data.keystoneShortName)

	else
		frame.Keystone:SetText("---")

	end

	frame:SetScript("OnClick", function(self, button)
		if(button == "RightButton") then
			if(IsInRaid()) then
				customMenu(self, "raid")

			elseif(IsInGroup()) then
				customMenu(self, "party")

			end
		elseif(button == "LeftButton") then
			showIndepthData(data)
		end
	end)
end

local spaceFrames = {}

local function clearFrameFromSpace(frame)
    local space = frame.occupiedSpace

    if(space) then
        frame:ClearAllPoints()
        space.occupiedBy = nil
        frame.occupiedSpace = nil
    end
end


local function swapButtonInRaidFrame(frame)
    if(IsInRaid() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
        SetRaidSubgroup(frame.id, frame.occupiedSpace.subgroupID);
    end
    --SwapRaidSubgroup(frame.id, frame.occupiedSpace.id);
end

local function bindFrameToSpace(frame, space)
    if(not space.occupiedBy or space.occupiedBy == frame) then
        clearFrameFromSpace(frame)

        frame:SetAllPoints(space)
        frame:SetParent(space)

        space.occupiedBy = frame
        frame.occupiedSpace = space
    end
end

local function bindFrameToSubgroupSpot(frame, subgroup, spot)
	local space = miog.GroupManager.Groups["Group" .. subgroup]["Space" .. spot]

	if(space) then
		bindFrameToSpace(frame, space)
	end
end

local function bindFrameToSpaceGroup(frame, space)
    local groupID = space.subgroupID

    if(_G["RaidGroup" .. groupID]) then
        local nextIndex = groupID and _G["RaidGroup" .. groupID].nextIndex

        if(nextIndex and frame.occupiedSpace.subgroupID ~= groupID) then
            local nextSpace = miog.GroupManager.Groups["Group" .. groupID]["Space" .. nextIndex]

            if(nextSpace) then
                bindFrameToSpace(frame, nextSpace)
            end
        else
            bindFrameToSpace(frame, frame.occupiedSpace)
        end
    end
end

local function bindFrameToSpaceGroupIndex(frame, index)
    bindFrameToSpaceGroup(frame, spaceFrames[index])
end

local function isFrameOverAnySpace(frame)
    for k, v in ipairs(spaceFrames) do
        if(MouseIsOver(v)) then
            return true, k
        end
    end

    return false
end

local openBlizzardRaidFrame = CreateFromMixins(UnitPopupButtonBaseMixin);

openBlizzardRaidFrame.OnClick = function()
	ToggleFriendsFrame(3)
end
openBlizzardRaidFrame.GetText = function()
	return "Open Blizzard's raid frame"
end

local customPartyPopupMenu = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("MIOG_PARTY", customPartyPopupMenu);
function customPartyPopupMenu:GetEntries()
	return {
		UnitPopupRaidTargetButtonMixin,
		--UnitPopupSetFocusButtonMixin,
		UnitPopupAddFriendButtonMixin,
		UnitPopupAddFriendMenuButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupRafSummonButtonMixin,
		UnitPopupRafGrantLevelButtonMixin,
		UnitPopupMenuFriendlyPlayerInteract, -- Submenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupEnterEditModeMixin,
		UnitPopupReportInWorldButtonMixin,
	}
end

local customRaidPopupMenu = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("MIOG_RAID", customRaidPopupMenu);
function customRaidPopupMenu:GetEntries()
	return {
		--UnitPopupSetFocusButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupSetRaidLeaderButtonMixin,
		UnitPopupSetRaidAssistButtonMixin,
		--UnitPopupSetRaidMainTankButtonMixin,
		--UnitPopupSetRaidMainAssistButtonMixin,

		UnitPopupSetRaidDemoteButtonMixin,
		UnitPopupLootPromoteButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupEnterEditModeMixin,
		UnitPopupReportGroupMemberButtonMixin,
		--UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupPvpReportAfkButtonMixin,
		UnitPopupVoteToKickButtonMixin,
		UnitPopupSetRaidRemoveButtonMixin,
		UnitPopupSubsectionSeperatorMixin,
		openBlizzardRaidFrame,
	}
end

local function createCharacterFrame(data)
	local frame = framePool:Acquire()
	frame.id = data.index
	frame.name = data.name
	frame.unit = data.unitID
	frame.subgroupSpotID = data.subgroup
	frame.data = data

	frame.Name:SetText(data.name)
	
	frame:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=1, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})

	local color

	if(data.fileName) then
		color = C_ClassColor.GetClassColor(data.fileName)

	else
		color = CreateColor(0.5, 0.5, 0.5, 1)

	end

	frame:SetBackdropColor(color:GetRGBA())
	frame:SetBackdropBorderColor(color.r - 0.15, color.g - 0.15, color.b - 0.15, 1)
	frame.Name:SetTextColor(1, 1, 1, 1)

	frame.Spec:SetTexture(miog.SPECIALIZATIONS[data.specID or 0].squaredIcon)

	if (data.rank == 2) then
		frame.RaidRole:SetTexture("interface/groupframe/ui-group-leadericon.blp")

	elseif (data.rank == 1) then
		frame.RaidRole:SetTexture("interface/groupframe/ui-group-assistanticon.blp")

	else
		if(data.role == "MAINTANK") then
			frame.RaidRole:SetTexture("interface/groupframe/ui-group-maintankicon.blp")
	
		elseif(data.role == "MAINASSIST") then
			frame.RaidRole:SetTexture("interface/groupframe/ui-group-mainassisticon.blp")
	
		else
			frame.RaidRole:SetTexture(nil)
			
		end
	end

	data.classColor = color
	
	frame:SetScript("OnEnter", function(self)
		if(self.data.unitID) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetUnit(self.data.unitID)

			if(self.data.rank == 2 ) then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine("Rank: " .. RAID_LEADER)

			elseif(self.data.rank == 1 ) then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine("Rank: " .. RAID_ASSISTANT)

			else
				if(self.data.role ~= nil) then
					GameTooltip_AddBlankLineToTooltip(GameTooltip)

					if (self.data.role == "MAINTANK" ) then
						GameTooltip:AddLine("Raid role: " .. MAIN_TANK);
					elseif (self.data.role == "MAINASSIST" ) then
						GameTooltip:AddLine("Raid role: " .. MAIN_ASSIST);
					end
				end
			end

			if(self.data.keystone) then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine("Keystone: +" .. self.data.keylevel .. " " .. self.data.keyname)

			end

			if(self.data.progressTooltipData) then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine(self.data.progressTooltipData)

			end

			if(self.data.hasWeaponEnchant) then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine(WrapTextInColorCode("Weapon enchanted", "FF00FF00"))

			elseif(self.data.hasWeaponEnchant == false) then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine(WrapTextInColorCode("Weapon not enchanted", "FFFF0000"))

			end

			if(self.data.missingEnchants) then
				if(#self.data.missingEnchants > 0) then
					local missingEnchants = ""

					for k, v in ipairs(self.data.missingEnchants) do
						missingEnchants = missingEnchants .. v .. " "

					end 
					
					GameTooltip_AddBlankLineToTooltip(GameTooltip)
					GameTooltip:AddLine(WrapTextInColorCode("Unenchanted slots: " .. missingEnchants, "FFFF0000"))
				else
					GameTooltip_AddBlankLineToTooltip(GameTooltip)
					GameTooltip:AddLine(WrapTextInColorCode("Fully enchanted", "FF00FF00"))

				end
			end

			if(self.data.missingGems) then
				if(#self.data.missingGems > 0) then
					local missingGems = ""

					for k, v in ipairs(self.data.missingGems) do
						missingGems = missingGems .. v .. " "

					end 
					
					GameTooltip_AddBlankLineToTooltip(GameTooltip)
					GameTooltip:AddLine(WrapTextInColorCode("Unsocketed slots: " .. missingGems, "FFFF0000"))
				else
					GameTooltip_AddBlankLineToTooltip(GameTooltip)
					GameTooltip:AddLine(WrapTextInColorCode("All sockets filled", "FF00FF00"))

				end
			end

			if(not self.data.missingEnchants) then
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine(WrapTextInColorCode("No data available (yet) for this player.", "FFFF0000"))
				GameTooltip:AddLine(WrapTextInColorCode("This player may not have Details or MythicIOGrabber installed.", "FFFF0000"))

			end

			GameTooltip:Show()
		end
	end)
	frame:SetScript("OnLeave", GameTooltip_Hide)
	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if(IsInRaid() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
			self:StartMoving()

		end
	end)

	frame:SetScript("OnDragStop", function(self)
		local isOverFrame, index = isFrameOverAnySpace(self)

		self:StopMovingOrSizing()

		if(UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
			if(isOverFrame) then
				bindFrameToSpaceGroupIndex(frame, index)
				swapButtonInRaidFrame(frame)
				--swapButtonToSubgroupInRaidFrame(self, index)
			else
				bindFrameToSpace(frame, frame.occupiedSpace)

			end
		end
	end)
	
	frame:SetPlayerData(data.shortName, data.realm)
	frame:RequestFillData()
	frame:SetScript("OnClick", function(self, button)
		if(button == "LeftButton") then
			showIndepthData(self.data)

		else
			if(IsInRaid()) then
				customMenu(self, "raid")

			elseif(IsInGroup()) then
				customMenu(self, "party")

			end

		end

		--local playerGear = miog.openRaidLib.GetUnitGear(self.data.unitID)
		--[[if(playerGear) then
			local itemFrame = miog.GroupManager.Indepth.Items

			for k, v in ipairs(playerGear.equippedGear) do
				local item = itemFrame[miog.SLOT_ID_INFO[v.slotId].slotName]

				if(item) then
					item.itemLink = v.itemLink
					local itemData = Item:CreateFromItemID(v.itemId)

					itemData:ContinueOnItemLoad(function()
						item.Icon:SetTexture(itemData:GetItemIcon())

					end)
				end
			end

			for k, v in ipairs(playerGear.noEnchants) do
				local item = itemFrame[miog.SLOT_ID_INFO[v].slotName]

				if(item) then
					item.missingEnchant = true
					item.Border:Show()

				end
			end

			for k, v in ipairs(playerGear.noGems) do
				local item = itemFrame[miog.SLOT_ID_INFO[v].slotName]

				if(item) then
					item.missingEnchant = true
					item.Border:Show()

				end
			end
		end]]

		--miog.GroupManager.Indepth:Show()
		--miog.GroupManager.Overlay:Hide()
	end)

	frame:Show()

	return frame
end

local function fillSpaceFramesTable()
    for i = 1, 40, 1 do
        local group = ceil(i / 5)
        local spaceNumber = i - (group - 1) * 5
        local groupFrame = miog.GroupManager.Groups["Group" .. group]
        local space = groupFrame and miog.GroupManager.Groups["Group" .. group]["Space" .. spaceNumber]

        if(space) then
            space.subgroupID = group
            space.id = i
            space.Number:SetText("#" .. i)
            
            miog.createFrameBorder(space, 1, CreateColorFromHexString(miog.CLRSCC.gray):GetRGBA())
	        space:SetBackdropColor(0,0,0,0.75)
            tinsert(spaceFrames, space)

        end
    end
end

local function removePlayerFromInspectList(fullName)
	inspectList[fullName] = nil
	miog.inspectNextCharacter()

end

local function startNotify(fullName, delay)
	if(playerInInspection and not playerSpecs[fullName] and groupData[fullName] and CanInspect(groupData[fullName].unitID)) then
		miog.ClassPanel.LoadingSpinner:SetShown(true)
		local color = C_ClassColor.GetClassColor(groupData[playerInInspection].fileName)
		currentInspectionName = color and WrapTextInColorCode(groupData[playerInInspection].name, color:GenerateHexColor()) or groupData[playerInInspection].name
		NotifyInspect(groupData[fullName].unitID)

		pityTimer = C_Timer.NewTimer(5, function()
			ClearInspectPlayer(true)
		
		end)

		return true
	else
		removePlayerFromInspectList(fullName)

	end

	return false
end

local function inspectCharacter(fullName)
	if(groupData[fullName] and not playerSpecs[fullName]) then
		if(not playerInInspection and UnitIsPlayer(groupData[fullName].unitID)) then --  and (GetTimePreciseSec() - lastNotifyTime) > miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE
			inspectList[fullName] = nil
			playerInInspection = fullName

			local time = GetTimePreciseSec()

			if(time - lastNotifyTime > miog.C.BLIZZARD_INSPECT_THROTTLE_ULTRA_SAVE) then
				startNotify(fullName)

			else
				C_Timer.After(lastNotifyTime - time + miog.C.BLIZZARD_INSPECT_THROTTLE_ULTRA_SAVE, function()
					local success = startNotify(fullName, true)

					if(not success) then
						miog.inspectNextCharacter()

					end
				end)
			end
		end
	else
		removePlayerFromInspectList(fullName)

	end

	return false
end

local function inspectNextCharacter()

	updateInspectionText()

	for k, v in pairs(inspectList) do
		local success = inspectCharacter(v)

		if(success) then
			break

		end
	end
end

miog.inspectNextCharacter = inspectNextCharacter

local function addCharacterToInspectionList(fullName, unitID)
	inspectList[fullName] = fullName

end

local lastCall = {
	type = -1,
	numMembers = -1,

}

local function updateGroupData(type, overwrite)
	if(not InCombatLockdown() and (overwrite or (lastCall.type ~= type or lastCall.numMembers ~= GetNumGroupMembers()))) then
		lastCall.type = type
		lastCall.numMembers = GetNumGroupMembers()

		groupData = {}
		
		local subgroupSpotsTaken = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 0,
			[8] = 0,
		}

		local specCount = {}
		local numOfMembers = GetNumGroupMembers()
		local isInRaid = IsInRaid()

		if(numOfMembers > 0) then
			for groupIndex = 1, numOfMembers, 1 do
				local name, rank, subgroup, level, localizedClassName, fileName, _, online, _, role, _, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

				if(name) then
					local unitID
					local playerName, localRealm = miog.createSplitName(name)
					local fullName = playerName .. "-" .. (localRealm or "")

					if(isInRaid) then
						unitID = "raid" .. groupIndex

					elseif(groupIndex > 1) then
						unitID = "party" .. groupIndex - 1

					else
						unitID = "player"

					end

					local data

					if(fullName ~= fullPlayerName) then
						data = getOptionalPlayerData(fullName, playerName, localRealm, unitID)
						--data = {}

						if(not playerSpecs[fullName] and playerSpecs[fullName] ~= 0) then
							addCharacterToInspectionList(fullName, unitID)

						end
					else
						data = getOptionalPlayerData(fullPlayerName, shortName, realm, unitID)

						if(not playerSpecs[fullPlayerName]) then
							playerSpecs[fullPlayerName] = GetSpecializationInfo(GetSpecialization())

						end
					end

					data.index = groupIndex
					data.subgroup = subgroup
					data.unitID = unitID
					data.level = level
					data.rank = rank
					data.online = online
					data.role = role
					data.specID = playerSpecs[fullName] or 0
					data.combatRole = combatRole or GetSpecializationRoleByID(data.specID)
					data.fullName = fullName
					data.fileName = fileName
					data.className = localizedClassName
					data.name = playerName
					data.realm = realm
					
					specCount[data.specID] = specCount[data.specID] and specCount[data.specID] + 1 or 1

					groupData[fullName] = data
				end
			end
		else
			local localizedClassName, fileName, id = UnitClass("player")
			local bestMap = C_Map.GetBestMapForUnit("player")

			playerSpecs[fullPlayerName] = GetSpecializationInfo(GetSpecialization())

			local data = getOptionalPlayerData(fullPlayerName, shortName, realm, "player")
		
			data.index = nil
			data.level = UnitLevel("player")
			data.subgroup = 1
			data.unitID = "player"
			data.online = true
			data.fullName = fullPlayerName
			data.fileName = fileName
			data.className = localizedClassName
			data.name = UnitNameUnmodified("player")
			data.realm = realm
			data.specID = playerSpecs[fullPlayerName] or 0
			data.combatRole = GetSpecializationRoleByID(data.specID)

			specCount[data.specID] = specCount[data.specID] and specCount[data.specID] + 1 or 1

			groupData[fullPlayerName] = data
		end

		inspectNextCharacter()

		if(miog.GroupManager) then
			framePool:ReleaseAll()

			local dataProvider = CreateDataProvider()

			for _, data in pairs(groupData) do
				dataProvider:Insert(data)

				local playerFrame = createCharacterFrame(data)
				subgroupSpotsTaken[data.subgroup] = subgroupSpotsTaken[data.subgroup] + 1
				bindFrameToSubgroupSpot(playerFrame, data.subgroup, subgroupSpotsTaken[data.subgroup])

			end

			miog.GroupManager:SetDataProvider(dataProvider)
		end

		for classID = 1, #miog.OFFICIAL_CLASSES, 1 do
			local classEntry = miog.OFFICIAL_CLASSES[classID]
            local classFrame = miog.ClassPanel.Container.classFrames[classID].specPanel

            for _, v in ipairs(classEntry.specs) do
                local specFrame = classFrame.specFrames[v]
                if specCount[v] then
                    specFrame.layoutIndex = v
                    specFrame.FontString:SetText(specCount[v])
                    specFrame:Show()
                else
                    specFrame:Hide()
                    specFrame.layoutIndex = nil
                end
            end

            classFrame:MarkDirty()
        end
	end
end

local readyCheckStatus = {}

local function updateReadyStatus(name, isReady)
	local frame = miog.GroupManager.ScrollBox:FindFrameByPredicate(function(localFrame, data)
		return data.fullName == name
	end)

    if(frame) then
        frame.Ready:SetColorTexture(unpack(isReady and {0, 1, 0, 1} or isReady == false and {1, 0, 0, 1} or {0, 0, 0, 1}))

    end
end

local function groupManagerEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        local isInitialLogin, isReloadingUi = ...

        if(isInitialLogin or isReloadingUi) then
			miog.openRaidLib.GetAllUnitsInfo()

        end

		updateGroupData(1, true)

    elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local fullName = miog.createFullNameFrom("unitID", ...)

		if(fullName and groupData[fullName]) then
			playerSpecs[fullName] = nil

		end

	elseif(event == "INSPECT_READY") then
		local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(...)
		local fullName = miog.createFullNameFrom("unitName", name.."-"..realmName)

		local startUpdate = false

		if(groupData[fullName]) then
			playerSpecs[fullName] = GetInspectSpecialization(groupData[fullName].unitID)
	
			updateSingleCharacterSpecData(fullName)
		end

		if(playerInInspection == fullName) then
			ClearInspectPlayer(true)
			miog.ClassPanel.LoadingSpinner:SetShown(false)

			if(pityTimer) then
				pityTimer:Cancel()
			end

			startUpdate = true
		end

		if(startUpdate) then
			inspectNextCharacter()

		end
	elseif(event == "GROUP_JOINED") then
		updateGroupData(2)

	elseif(event == "GROUP_LEFT") then
		wipeAllData()

		updateGroupData(3)
	elseif(event == "GROUP_ROSTER_UPDATE") then
		updateGroupData(4)

	elseif(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.UPDATE_AFTER_COMBAT) then
			miog.F.UPDATE_AFTER_COMBAT = false

			updateGroupData(5, true)
		end
	elseif(event == "READY_CHECK") then -- initiatorName, readyCheckTimeLeft
			miog.GroupManager.StatusBar.ReadyBox:SetColorTexture(1, 1, 0, 1)
	
			readyCheckStatus = {}
	
			local initName, timeLeft = ...
	
			local fullName = miog.createFullNameFrom("unitName", initName)
	
			readyCheckStatus[fullName] = true
	
			updateReadyStatus(fullName, true)
	
	elseif(event == "READY_CHECK_CONFIRM") then -- unitTarget, isReady
		local unitID, isReady = ...

		local fullName = miog.createFullNameFrom("unitID", unitID)
		
		readyCheckStatus[fullName] = isReady

		updateReadyStatus(fullName, isReady)
	elseif(event == "READY_CHECK_FINISHED") then -- preempted
		local allReady = true

		for fullName, ready in pairs(readyCheckStatus) do
			updateReadyStatus(fullName)

			if(not ready) then
				allReady = false

				--break
			end

		end

		miog.GroupManager.StatusBar.ReadyBox:SetColorTexture(unpack(allReady and {0, 1, 0, 1} or {1, 0, 0, 1}))
	end
end

--[[
local specName = singleUnitInfo.specName
local role = singleUnitInfo.role
local renown = singleUnitInfo.renown
local covenantId = singleUnitInfo.covenantId
local heroTalentId = singleUnitInfo.heroTalentId
local talents = singleUnitInfo.talents
local pvpTalents = singleUnitInfo.pvpTalents
local conduits = singleUnitInfo.conduits
local class = singleUnitInfo.class
local classId = singleUnitInfo.classId
local className = singleUnitInfo.className
local unitName = singleUnitInfo.name
local fullName = singleUnitInfo.nameFull
]]
miog.OnUnitUpdate = function(singleUnitId, singleUnitInfo, allUnitsInfo)
	if(singleUnitInfo) then
		if(singleUnitInfo.nameFull == shortName) then
			singleUnitInfo.nameFull = fullPlayerName
		end

		if(groupData[singleUnitInfo.nameFull]) then
			if(singleUnitInfo.specId and singleUnitInfo.specId > 0) then

				playerSpecs[singleUnitInfo.nameFull] = singleUnitInfo.specId
				
				updateSingleCharacterSpecData(singleUnitInfo.nameFull)

				inspectNextCharacter()
			end
		end
	end
end

miog.OnKeystoneUpdate = function(unitName, keystoneInfo, allKeystoneInfo)
	local mapName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)

	if(mapName) then
		local fullName = miog.createFullNameFrom("unitName", unitName)

		playerKeystones[fullName] = keystoneInfo

		updateSingleCharacterKeystoneData(fullName)

	end
end

miog.OnGearUpdate = function(unitName, unitGear, allUnitsGear)
	--[[local itemLevelNumber = unitGear.ilevel
	local durabilityNumber = unitGear.durability
	--hasWeaponEnchant is 1 have enchant or 0 is don't
	local hasWeaponEnchantNumber = unitGear.weaponEnchant
	local noEnchantTable = unitGear.noEnchants
	local noGemsTable = unitGear.noGems

	for index, slotIdWithoutEnchant in ipairs (noEnchantTable) do
	end

	for index, slotIdWithEmptyGemSocket in ipairs (noGemsTable) do
	end]]

	local name = miog.createFullNameFrom("unitName", unitName)

	if(name) then
		playerGearData[name] = unitGear

		updateSingleCharacterItemData(name)

	end
end

local function updateRaidLibData()
	local isInRaid, isInGroup = IsInRaid(), IsInGroup()

	if(isInRaid or isInGroup) then
		miog.openRaidLib.GetAllUnitsInfo()

		if(isInRaid) then
			miog.openRaidLib.RequestKeystoneDataFromRaid()
			
		else
			miog.openRaidLib.RequestKeystoneDataFromParty()

		end
	end
end

miog.loadInspectManagement = function()
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
	miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
   
	local inspectManager = CreateFrame("Frame", nil)
	inspectManager:Hide()

	inspectManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	inspectManager:RegisterEvent("GROUP_JOINED")
	inspectManager:RegisterEvent("GROUP_LEFT")
	inspectManager:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	inspectManager:RegisterEvent("INSPECT_READY")
	inspectManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	inspectManager:RegisterEvent("PLAYER_REGEN_ENABLED")
	inspectManager:SetScript("OnEvent", groupManagerEvents)

	fullPlayerName = miog.createFullNameFrom("unitID", "player")
	
	shortName, realm = miog.createSplitName(fullPlayerName)
	miog.fullPlayerName, miog.shortPlayerName = fullPlayerName, shortName
end

local function updateAllData()
	updateRaidLibData()
	updateGroupData(6, true)
end

miog.loadGroupManager = function()
    miog.GroupManager = miog.pveFrame2.TabFramesPanel.GroupManager
	miog.GroupManager:SetScrollBox(miog.GroupManager.ScrollBox)

	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")

    framePool = CreateFramePool("Button", nil, "MIOG_GroupManagerRaidFrameCharacterTemplate", function(_, frame) frame:Hide() clearFrameFromSpace(frame) end)

	miog.GroupManager:SetScript("OnShow", function()
		updateRaidLibData()
		
		local name = miog.createFullNameFrom("unitID", "player")

		if(name) then
			updateGroupData(7, true)

		end
	end)

	miog.GroupManager.StatusBar.Refresh:SetScript("OnClick", updateAllData)

	miog.GroupManager:OnLoad(updateAllData)
	miog.GroupManager:SetSettingsTable(MIOG_NewSettings.sortMethods.GroupManager)
	miog.GroupManager:AddMultipleSortingParameters({
		{name = "subgroup", tooltipTitle = GROUP},
		{name = "combatRole", tooltipTitle = ROLE},
		{name = "specID", tooltipTitle = SPECIALIZATION},
		{name = "name", tooltipTitle = NAME},
		{name = "ilvl", tooltipTitle = STAT_AVERAGE_ITEM_LEVEL, padding = 82},
		{name = "durability", tooltipTitle = DURABILITY, padding = 17},
		{name = "score", tooltipTitle = PROVING_GROUNDS_SCORE, padding = 29},
		{name = "progressWeight", tooltipTitle = PVP_PROGRESS_REWARDS_HEADER, padding = 26},
		{name = "keylevel", tooltipTitle = WEEKLY_REWARDS_MYTHIC_KEYSTONE, padding = 41},
	})

	miog.GroupManager:RegisterEvent("READY_CHECK")
	miog.GroupManager:RegisterEvent("READY_CHECK_CONFIRM")
	miog.GroupManager:RegisterEvent("READY_CHECK_FINISHED")
	miog.GroupManager:SetScript("OnEvent", groupManagerEvents)

	local ScrollView = CreateScrollBoxListLinearView(0, 0, 0, 0, 2)

	miog.GroupManager.ScrollView = ScrollView
	
	ScrollUtil.InitScrollBoxListWithScrollBar(miog.GroupManager.ScrollBox, miog.GroupManager.ScrollBar, ScrollView)

	ScrollView:SetElementInitializer("MIOG_GroupManagerListCharacterTemplate", function(frame, data)
		updateGroupManagerPlayerFrame(frame, data)
	
	end)

	ScrollView:SetElementExtentCalculator(function(index, data)
		return GetNumGroupMembers() < 6 and 50 or 25
	end)

    fillSpaceFramesTable()

    miog.GroupManager.Groups.Tank.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")
    miog.GroupManager.Groups.Healer.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")
    miog.GroupManager.Groups.Damager.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")
	miog.GroupManager.Indepth:OnLoad("side")
end

hooksecurefunc("NotifyInspect", function()
	lastNotifyTime = GetTimePreciseSec()

	updateInspectionText()
end)

hooksecurefunc("ClearInspectPlayer", function(own)
	if(own) then
		playerInInspection = nil
		currentInspectionName = nil
		
	end
end)