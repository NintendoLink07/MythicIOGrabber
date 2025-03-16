local addonName, miog = ...
local wticc = WrapTextInColorCode

local fullPlayerName, shortName, playerRealm

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
	playerInInspection = nil
	inspectList = {}
end

local function removePlayerFromInspectList(fullName)
	inspectList[fullName] = nil

end

miog.getKeystoneData = function(fullName)
	return playerKeystones[fullName]
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
			local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(playerKeystones[fullName].challengeMapID)

			if(miog.CHALLENGE_MODE_INFO[id]) then
				--playerKeystones[fullName].keystoneShortName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[id].mapID].shortName
				--data.keystone = texture
				--playerKeystones[fullName].keylevel = playerKeystones[fullName].level
				--playerKeystones[fullName].keystoneFullName = mapName

				local keystoneShortName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[id].mapID].shortName

				if(keystoneShortName) then
					frame.Keystone:SetText("+" .. playerKeystones[fullName].level .. " " .. keystoneShortName)
		
				else
					frame.Keystone:SetText("---")
		
				end
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

	removePlayerFromInspectList(fullName)
end

local function updateSingleCharacterItemData(fullName)
	if(not miog.GroupManager:IsShown()) then
		return
	end

	local frame = frameIsAvailable or miog.GroupManager.ScrollBox:FindFrameByPredicate(function(localFrame, data)
		return fullName == data.fullName

	end)


	local playerGear = playerGearData[fullName]

	if(frame and playerGear) then
		local data = frame.data
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
		
		frame.Itemlevel:SetText(playerGear.ilevel or "N/A")
		frame.Durability:SetText(playerGear.durability and "(" .. playerGear.durability .. "%)" or "N/A")
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

	playerKeystones[libName] = playerKeystones[libName] or miog.openRaidLib.GetKeystoneInfo(unitID)

	if(playerKeystones[libName]) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(playerKeystones[libName].challengeMapID)

		if(miog.CHALLENGE_MODE_INFO[id]) then
			data.keystoneShortName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[id].mapID].shortName
			data.keylevel = playerKeystones[libName].level
			data.keystoneFullName = mapName

		end
	end
	
	playerRaidData[libName] = playerRaidData[libName] or miog.getRaidProgressDataOnly(playerName, localRealm)

	if(playerRaidData[libName]) then
		data.progress = ""

		local raidTable = {}

		for _, v in ipairs(playerRaidData[libName].character.ordered) do
			if(v.difficulty > 0) then
				raidTable[v.mapID] = raidTable[v.mapID] or {}

				tinsert(raidTable[v.mapID], wticc(v.parsedString, miog.DIFFICULTY[v.difficulty].color) .. " ")
	
			end
		end

		local newTable = {}

		for k, v in pairs(raidTable) do
			data.progress = data.progress .. table.concat(v) .. "\r\n"

		end

		data.progressWeight = playerRaidData[libName].character.progressWeight or 0

	else
		data.progressWeight = 0
		data.progress = "---"

	end

	playerMPlusData[libName] = playerMPlusData[libName] or miog.getMPlusScoreOnly(playerName, localRealm)
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

	print(data.name, data.realm)

	indepthFrame:ApplyFillData()

	indepthFrame:Show()
end

local function updateGroupManagerPlayerFrame(frame, data)
	local rank, _, level, class, fileName, zone, online, isDead, role, isML

	-- Fetch data based on group status
	if data.index then
		_, rank, _, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(data.index)

	else
		class, fileName = UnitClass("player")
		level = UnitLevel("player")
		online = true
	end

	-- Cache repeated lookups
	local fullName = data.fullName
	local specID = playerSpecs[fullName] or 0
	local leaderCrown = miog.GroupManager.LeaderCrown
	local keystoneText = data.keystoneShortName and ("+" .. data.keylevel .. " " .. data.keystoneShortName) or "---"
	local colorizedSubgroup = online and data.subgroup or WrapTextInColorCode(data.subgroup, miog.CLRSCC.red)

	-- Assign frame values efficiently
	frame.data = data
	frame.id = data.index
	--frame.name = fullName
	frame.unit = data.unitID
	frame.specID = specID

	frame.Index:SetText(colorizedSubgroup)
	frame.Role:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/" .. (data.combatRole and data.combatRole .. "Icon.png" or "unknown.png"))
	frame.Name:SetText(fileName and WrapTextInColorCode(data.name, C_ClassColor.GetClassColor(fileName):GenerateHexColor()) or data.name)
	frame.Spec:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
	frame.Itemlevel:SetText(data.ilvl or "N/A")
	frame.Durability:SetText(data.durability and "(" .. data.durability .. "%)" or "N/A")
	frame.Score:SetText(data.score or 0)
	frame.Progress:SetText(data.progress or "N/A")
	frame.Keystone:SetText(keystoneText)

	-- Handle leader crown efficiently
	if rank == 2 then
		leaderCrown:ClearAllPoints()
		leaderCrown:SetPoint("RIGHT", frame.Group, "RIGHT")
		leaderCrown:SetParent(frame)
		leaderCrown:Show()
	end

	-- Optimize click handling
	frame:SetScript("OnClick", function(self, button)
		if button == "RightButton" then
			customMenu(self, IsInRaid() and "raid" or (IsInGroup() and "party" or nil))
		elseif button == "LeftButton" then
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
    local raidGroup = _G["RaidGroup" .. groupID]

    if not raidGroup then return end  -- Early exit if the group doesn't exist

    local nextIndex = raidGroup.nextIndex
    if nextIndex and frame.occupiedSpace.subgroupID ~= groupID then
        local groupTable = miog.GroupManager.Groups["Group" .. groupID]
        if groupTable then
            local nextSpace = groupTable["Space" .. nextIndex]
            if nextSpace then
                return bindFrameToSpace(frame, nextSpace)
            end
        end
    end

    bindFrameToSpace(frame, frame.occupiedSpace)
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
	frame.data = data

	frame.Name:SetText(data.name)

	local color

	if(data.fileName) then
		color = C_ClassColor.GetClassColor(data.fileName)

	else
		color = CreateColor(0.5, 0.5, 0.5, 1)

	end

	frame.Background:SetColorTexture(color:GetRGBA())
	frame.Border:SetColorTexture(color.r - 0.15, color.g - 0.15, color.b - 0.15, 1)

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
	
	--frame:SetPlayerData(data.shortName, data.realm)
	--frame:RequestFillData()
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

local function canInspectPlayer(fullName)
	local data = groupData[fullName]

	if(not data) then
		return false

	end

	if(CanInspect(data.unitID) and data.online ~= false) then
		return true

	end
end

local function addCharacterToInspectionList(fullName, unitID)
	inspectList[fullName] = unitID

end

local function updateSpecPanels(specTable)
	for classID = 1, #miog.OFFICIAL_CLASSES, 1 do
		local classEntry = miog.OFFICIAL_CLASSES[classID]
		local classFrame = miog.ClassPanel.Container.classFrames[classID].specPanel

		for _, v in ipairs(classEntry.specs) do
			local specFrame = classFrame.specFrames[v]
			
			if specTable[v] then
				specFrame.layoutIndex = v
				specFrame.FontString:SetText(specTable[v])
				specFrame:Show()
			else
				specFrame:Hide()
				specFrame.layoutIndex = nil
			end
		end

	end

	miog.ClassPanel.Container:MarkDirty()
end

local function countPlayersWithData()
	local specCount = {}
	local playersWithSpecData, inspectableMembers = 0, 0

	for _, data in pairs(groupData) do
		local playerSpec = playerSpecs[data.fullName]
		local hasPlayerSpec = playerSpec and playerSpec ~= 0

		if(hasPlayerSpec) then
			specCount[playerSpec] = specCount[playerSpec] and specCount[playerSpec] + 1 or 1

			playersWithSpecData = playersWithSpecData + 1
			inspectableMembers = inspectableMembers + 1

		elseif(canInspectPlayer(data.fullName)) then
			inspectableMembers = inspectableMembers + 1
			
		end
	end

	updateSpecPanels(specCount)

	return playersWithSpecData, inspectableMembers
end

miog.countPlayersWithData = countPlayersWithData

local function updateInspectionText()
	local name

	if(playerInInspection and groupData[playerInInspection]) then
		local color = C_ClassColor.GetClassColor(groupData[playerInInspection].fileName)
		name = color and WrapTextInColorCode(groupData[playerInInspection].name, color:GenerateHexColor()) or groupData[playerInInspection].name

	else
		name = ""

	end

	local specs, members = countPlayersWithData()

    miog.ClassPanel.StatusString:SetText(name .. "\n(" .. specs .. "/" .. members .. "/" .. GetNumGroupMembers() .. ")")
	miog.ClassPanel.LoadingSpinner:SetShown(groupData[playerInInspection] ~= nil)
end

local function startNotify()
	if(playerInInspection) then
		if(groupData[playerInInspection] and not playerSpecs[playerInInspection] and canInspectPlayer(playerInInspection)) then
			NotifyInspect(groupData[playerInInspection].unitID)

			pityTimer = C_Timer.NewTimer(5, function()
				if(groupData[playerInInspection]) then
					addCharacterToInspectionList(playerInInspection, groupData[playerInInspection].unitID)

				end

				ClearInspectPlayer(true)
				miog.inspectNextCharacter()
				
			end)

			return true
		else
			removePlayerFromInspectList(playerInInspection)

		end
	end
end

local function inspectCharacter(fullName)
	if(groupData[fullName] and not playerSpecs[fullName]) then
		if(playerInInspection == nil and UnitIsPlayer(groupData[fullName].unitID)) then
			inspectList[fullName] = nil
			playerInInspection = fullName
			updateInspectionText()

			local time = GetTimePreciseSec()

			if(time - lastNotifyTime > miog.C.BLIZZARD_INSPECT_THROTTLE_ULTRA_SAVE) then
				return startNotify()

			else
				C_Timer.After(lastNotifyTime - time + miog.C.BLIZZARD_INSPECT_THROTTLE_ULTRA_SAVE, function()
					startNotify()
					
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

	for fullName, unitID in pairs(inspectList) do
		local success = inspectCharacter(fullName)

		if(success) then
			break

		end
	end
end

miog.inspectNextCharacter = inspectNextCharacter

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

		local numOfMembers = GetNumGroupMembers()
		local isInRaid = IsInRaid()

		local offset = 0

		if(numOfMembers > 0) then
			for groupIndex = 1, numOfMembers, 1 do
				local name, rank, subgroup, level, localizedClassName, fileName, _, online, _, role, _, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

				if(name) then
					local unitID
					local playerName, realm = miog.createSplitName(name)
					local fullName = miog.createFullNameFrom("unitName", name)

					miog.AceComm:SendCommMessage("MIOG", "Hey, I'm " .. UnitName("player"), "WHISPER", fullName)
					--C_ChatInfo.SendAddonMessageLogged("MIOG", "Hey, I'm " .. UnitName("player"), "WHISPER", fullName)

					if(isInRaid) then
						unitID = "raid" .. groupIndex

					elseif(fullPlayerName == fullName) then
						unitID = "player"

						offset = offset + 1

					else
						unitID = "party" .. groupIndex - offset

					end

					local data

					if(fullName ~= fullPlayerName) then
						data = getOptionalPlayerData(fullName, playerName, realm, unitID)
						--data = {}

						if(not playerSpecs[fullName] or playerSpecs[fullName] == 0 and not playerInInspection == fullName) then
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
					

					groupData[fullName] = data
				end
			end
		else
			local localizedClassName, fileName, id = UnitClass("player")
			--local bestMap = C_Map.GetBestMapForUnit("player")

			playerSpecs[fullPlayerName] = GetSpecializationInfo(GetSpecialization())

			local data = getOptionalPlayerData(fullPlayerName, shortName, playerRealm, "player")
		
			data.index = nil
			data.level = UnitLevel("player")
			data.subgroup = 1
			data.unitID = "player"
			data.online = true
			data.fullName = fullPlayerName
			data.fileName = fileName
			data.className = localizedClassName
			data.name = UnitNameUnmodified("player")
			data.realm = playerRealm
			data.specID = playerSpecs[fullPlayerName] or 0
			data.combatRole = GetSpecializationRoleByID(data.specID)

			groupData[fullPlayerName] = data
		end

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
	end

	inspectNextCharacter(3)

	miog.ClassPanel.LoadingSpinner.inspectList = inspectList
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

local function checkPlayerInspectionStatus(fullName, openRaidSpec)
	if(groupData[fullName]) then
		playerSpecs[fullName] = openRaidSpec or GetInspectSpecialization(groupData[fullName].unitID)

		updateSingleCharacterSpecData(fullName)
	end

	if(playerInInspection == fullName) then
		ClearInspectPlayer(true)

		if(pityTimer) then
			pityTimer:Cancel()
		end

		inspectNextCharacter(4)
	end
end

local function groupManagerEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
		updateGroupData(1, true)

    elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local fullName = miog.createFullNameFrom("unitID", ...)

		if(fullName and groupData[fullName]) then
			playerSpecs[fullName] = nil

		end

	elseif(event == "INSPECT_READY") then
		local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(...)
		local fullName = miog.createFullNameFrom("unitName", name .. "-" .. realmName)

		checkPlayerInspectionStatus(fullName)
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
				checkPlayerInspectionStatus(singleUnitInfo.nameFull, singleUnitInfo.specId)

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
	miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
   
	local inspectManager = CreateFrame("Frame", nil)
	inspectManager:Hide()

	inspectManager:RegisterEvent("PLAYER_LOGIN")
	inspectManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	inspectManager:RegisterEvent("GROUP_JOINED")
	inspectManager:RegisterEvent("GROUP_LEFT")
	inspectManager:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	inspectManager:RegisterEvent("INSPECT_READY")
	inspectManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	inspectManager:RegisterEvent("PLAYER_REGEN_ENABLED")
	inspectManager:SetScript("OnEvent", groupManagerEvents)

	fullPlayerName = miog.createFullNameFrom("unitID", "player")
	
	shortName, playerRealm = miog.createSplitName(fullPlayerName)
	miog.fullPlayerName, miog.shortPlayerName = fullPlayerName, shortName
end

local function updateAllData()
	updateRaidLibData()
	updateGroupData(6, true)
end

miog.loadGroupManager = function()
    miog.GroupManager = miog.pveFrame2.TabFramesPanel.GroupManager
	miog.GroupManager:SetScrollBox(miog.GroupManager.ScrollBox)

	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")

    framePool = CreateFramePool("Button", nil, "MIOG_GroupManagerRaidFrameCharacterTemplate", function(_, frame) frame:Hide() clearFrameFromSpace(frame) end)

	miog.GroupManager:SetScript("OnShow", function()
		updateAllData()
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
		updateInspectionText()
		
	end
end)