local addonName, miog = ...
local wticc = WrapTextInColorCode

local fullPlayerName, shortName, playerRealm

local groupData = {}

local lastNotifyTime = 0

local restartTimer

local pityTimers = {}
local nextInspectTimer
local playerInInspection
local playerSpecs = {}
local playerKeystones = {}
local playerRaidData = {}
local playerMPlusData = {}
local playerGearData = {}
local inspectList = {}

local manualItemlevels = {}

local timeouts = {}

local framePool

local function wipeAllData()
	for k, v in pairs(pityTimers) do
		v:Cancel()
		
	end

	if(nextInspectTimer) then
		nextInspectTimer:Cancel()

	end

	timeouts = {}
	playerSpecs = {}
	playerKeystones = {}
	playerRaidData = {}
	playerMPlusData = {}
	playerGearData = {}
	playerInInspection = nil
	inspectList = {}
end

local two_hand = {
	["INVTYPE_2HWEAPON"] = true,
 	["INVTYPE_RANGED"] = true,
	["INVTYPE_RANGEDRIGHT"] = true,
}

local function calcItemLevel(unitid, guid, shout)

	--[[if (type(unitid) == "table") then
		shout = unitid [3]
		guid = unitid [2]
		unitid = unitid [1]
	end]]

	--disable due to changes to CheckInteractDistance()
	if (not InCombatLockdown() and unitid and UnitIsPlayer(unitid) and CanInspect(unitid)) then

		--16 = all itens including main and off hand
		local item_amount = 16
		local item_level = 0
		local failed = 0

		for equip_id = 1, 17 do
			if (equip_id ~= 4) then --shirt slot
				local item = GetInventoryItemLink(unitid, equip_id)
				if (item) then
					local _, _, itemRarity, iLevel, _, _, _, _, equipSlot = C_Item.GetItemInfo(item)
					if (iLevel) then
						item_level = item_level + iLevel

						--16 = main hand 17 = off hand
						-- if using a two-hand, ignore the off hand slot
						if (equip_id == 16 and two_hand [equipSlot]) then
							item_amount = 15
							break
						end
					end
				else
					failed = failed + 1
					if (failed > 2) then
						break
					end
				end
			end
		end

		local average

		if(failed == 0) then
			average = item_level / item_amount

			average = miog.round(average, 0)

		end

		--register
		--[[if (average > 0) then
			if (shout) then
				Details:Msg(UnitName(unitid) .. " item level: " .. average)
			end

			if (average > MIN_ILEVEL_TO_STORE) then
				local unitName = Details:GetFullName(unitid)
				Details.item_level_pool [guid] = {name = unitName, ilvl = average, time = time()}
			end
		end

		local spec
		local talents = {}

		if (not DetailsFramework.IsTimewalkWoW()) then
			spec = GetInspectSpecialization(unitid)
			if (spec and spec ~= 0) then
				Details.cached_specs [guid] = spec
				Details:SendEvent("UNIT_SPEC", nil, unitid, spec, guid)
			end

			--------------------------------------------------------------------------------------------------------

			for i = 1, 7 do
				for o = 1, 3 do
					--need to review this in classic
					local talentID, name, texture, selected, available = GetTalentInfo(i, o, 1, true, unitid)
					if (selected) then
						tinsert(talents, talentID)
						break
					end
				end
			end

			if (talents [1]) then
				Details.cached_talents [guid] = talents
				Details:SendEvent("UNIT_TALENTS", nil, unitid, talents, guid)
			end
		end

		--------------------------------------------------------------------------------------------------------

		if (ilvl_core.forced_inspects [guid]) then
			if (type(ilvl_core.forced_inspects [guid].callback) == "function") then
				local okey, errortext = pcall(ilvl_core.forced_inspects[guid].callback, guid, unitid, ilvl_core.forced_inspects[guid].param1, ilvl_core.forced_inspects[guid].param2)
				if (not okey) then
					Details:Msg("Error on QueryInspect callback: " .. errortext)
				end
			end
			ilvl_core.forced_inspects [guid] = nil
		end

		--------------------------------------------------------------------------------------------------------
		]]

		return average
	end
end


local function getPlayerGemsAndEnchantInfo()
    --hold equipmentSlotId of equipment with a gem socket but it's empty
    local slotsWithoutGems = {}
    --hold equipmentSlotId of equipments without an enchant
    local slotsWithoutEnchant = {}

    local gearWithEnchantIds = {}

    for equipmentSlotId = 1, 17 do
        local itemLink = GetInventoryItemLink("player", equipmentSlotId)
        if (itemLink) then
            --get the information from the item
            local _, itemId, enchantId, gemId1, gemId2, gemId3, gemId4, suffixId, uniqueId, levelOfTheItem, specId, upgradeInfo, instanceDifficultyId, numBonusIds, restLink = strsplit(":", itemLink)
            local gemsIds = {gemId1, gemId2, gemId3, gemId4}

            --enchant
                --check if the slot can receive enchat and if the equipment has an enchant
                local enchantAttribute = LIB_OPEN_RAID_ENCHANT_SLOTS[equipmentSlotId]
                local nEnchantId = 0

                if (enchantAttribute) then --this slot can receive an enchant
                    if (enchantId and enchantId ~= "") then
                        local number = tonumber(enchantId)
                        nEnchantId = number
                        gearWithEnchantIds[#gearWithEnchantIds+1] = nEnchantId
                    else
                        gearWithEnchantIds[#gearWithEnchantIds+1] = 0
                    end

                    --6400 and above is dragonflight enchantId number space
                    if (nEnchantId < 6300 and not LIB_OPEN_RAID_DEATHKNIGHT_RUNEFORGING_ENCHANT_IDS[nEnchantId]) then
                        slotsWithoutEnchant[#slotsWithoutEnchant+1] = equipmentSlotId
                    end
                end

            --gems
                --local itemStatsTable = {}
                --fill the table above with information about the item
                --GetItemStats(itemLink, itemStatsTable) --deprecated in 10.2.5
                local itemStatsTable = GetItemStats(itemLink)

                --check if the item has a socket
                if (itemStatsTable) then
                    if (itemStatsTable.EMPTY_SOCKET_PRISMATIC) then
                        --check if the socket is empty
                        for i = 1, itemStatsTable.EMPTY_SOCKET_PRISMATIC do
                            local gemId = tonumber(gemsIds[i])
                            if (not gemId or gemId == 0) then
                                slotsWithoutGems[#slotsWithoutGems+1] = equipmentSlotId

                            --check if the gem is not a valid gem (deprecated gem)
                            elseif (gemId < 180000) then
                                slotsWithoutGems[#slotsWithoutGems+1] = equipmentSlotId
                            end
                        end
                    end
                end
        end
    end

    return slotsWithoutGems, slotsWithoutEnchant
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
end

local function updateSingleCharacterItemData(fullName)
	--if(not miog.GroupManager:IsShown()) then
		--return
	--end
	

	local frame = frameIsAvailable or miog.GroupManager.ScrollBox:FindFrameByPredicate(function(localFrame, data)
		return fullName == data.fullName

	end)

	local playerGear = playerGearData[fullName]

	if(frame) then
		if(playerGear) then
			local data = frame.data
			data.ilvl = playerGear.ilevel or 0
			data.durability = playerGear.durability or 0

			if(playerGear.noEnchants) then
				if(#playerGear.noEnchants > 0) then
					data.missingEnchants = {}

					for index, slotIdWithoutEnchant in ipairs (playerGear.noEnchants) do
						if(slotIdWithoutEnchant ~= 10) then
							data.missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
							
						end
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

		if(playerGear.noEnchants) then
			if(#playerGear.noEnchants > 0) then
				data.missingEnchants = {}

				for index, slotIdWithoutEnchant in ipairs (playerGear.noEnchants) do
					if(slotIdWithoutEnchant ~= 10) then
						data.missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
						
					end
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
		data.ilvl = manualItemlevels[libName] or 0
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

	indepthFrame:ApplyFillData()

	indepthFrame:Show()
end

local function updateGroupManagerPlayerFrame(frame, data)
	-- Cache repeated lookups
	local fullName = data.fullName
	local specID = playerSpecs[fullName] or 0
	local keystoneText = data.keystoneShortName and ("+" .. data.keylevel .. " " .. data.keystoneShortName) or "---"
	local colorizedSubgroup = data.online and data.subgroup or WrapTextInColorCode(data.subgroup, miog.CLRSCC.red)

	-- Assign frame values efficiently
	frame.data = data
	frame.id = data.index
	--frame.name = fullName
	frame.unit = data.unitID
	frame.specID = specID

	frame.Index:SetText(colorizedSubgroup)
	frame.Role:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/" .. (data.combatRole and data.combatRole .. "Icon.png" or "unknown.png"))
	frame.Name:SetText(data.fileName and WrapTextInColorCode(data.name, C_ClassColor.GetClassColor(data.fileName):GenerateHexColor()) or data.name)
	frame.Spec:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
	frame.Itemlevel:SetText(data.ilvl or "N/A")
	frame.Durability:SetText(data.durability and "(" .. data.durability .. "%)" or "N/A")
	frame.Score:SetText(data.score or 0)
	frame.Progress:SetText(data.progress or "N/A")
	frame.Keystone:SetText(keystoneText)

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

	if(UnitIsPlayer(data.unitID) and CanInspect(data.unitID) and (data.online ~= false or UnitIsConnected(data.unitID))) then
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

	local numGroupMembers = GetNumGroupMembers()

	if(not (specs == members == numGroupMembers)) then
		if(restartTimer) then
			restartTimer:Cancel()

		end

		restartTimer = C_Timer.NewTimer(5, function()
			miog.inspectNextCharacter()

		end)

	end

	miog.ClassPanel.InspectionName:SetText(name)
    miog.ClassPanel.Status:SetText("[" .. specs .. "/" .. members .. "/" .. numGroupMembers .. "]")
	miog.ClassPanel.Status.inspectList = inspectList
	miog.ClassPanel.LoadingSpinner:SetShown(playerInInspection ~= nil)
end

local function cancelPityTimer(fullName)
	if(pityTimers[fullName]) then
		pityTimers[fullName]:Cancel()
		pityTimers[fullName] = nil
	end
end

local function clearCharacter(fullName)
	if(playerInInspection == fullName) then
		ClearInspectPlayer(true)
		playerInInspection = nil

		cancelPityTimer(fullName)
	end

	removePlayerFromInspectList(fullName)
	updateInspectionText()

	miog.inspectNextCharacter()
end

local function checkTimeouts(fullName)
	return not timeouts[fullName] or timeouts[fullName] < 3
end

local function startNotify(fullName)
	if(fullName) then
		if(groupData[fullName]) then
			if(not playerSpecs[fullName] and canInspectPlayer(fullName) and checkTimeouts(fullName)) then
				playerInInspection = fullName

				NotifyInspect(groupData[playerInInspection].unitID)

				pityTimers[fullName] = C_Timer.NewTimer(5, function()
					timeouts[fullName] = timeouts[fullName] and timeouts[fullName] + 1 or 1

					if(groupData[fullName]) then
						--addCharacterToInspectionList(fullName)

					end

					clearCharacter(fullName)
					
				end)

				return true
			end
		end

		removePlayerFromInspectList(fullName)
	end
end

local function cancelInspectTimer()
	if(nextInspectTimer) then
		nextInspectTimer:Cancel()
		nextInspectTimer = nil
	end

end

local function startNewInspectTimer(nextCharacter, startTime)
	cancelInspectTimer()

	nextInspectTimer = C_Timer.NewTimer(lastNotifyTime - startTime + miog.C.BLIZZARD_INSPECT_THROTTLE_ULTRA_SAVE, function()
		local notifySuccess = miog.checkForNextExecution(nextCharacter)

		if(not notifySuccess) then
			clearCharacter(nextCharacter)

		end
		
	end)
end

local function checkForNextExecution(nextCharacter)
	local time = GetTimePreciseSec()
	local notifyIsAvailable = time - lastNotifyTime > miog.C.BLIZZARD_INSPECT_THROTTLE_ULTRA_SAVE

	if(checkTimeouts(nextCharacter)) then
		if(notifyIsAvailable) then
			--cancelPityTimer()

			return startNotify(nextCharacter)
			
		else
			playerInInspection = nextCharacter

			startNewInspectTimer(nextCharacter, time)

			return true
		end
	end
end

miog.checkForNextExecution = checkForNextExecution

local function getNextCharacter()
	for k, v in pairs(inspectList) do
		return k, v
	end
end

local function inspectNextCharacter()
	if(playerInInspection == nil) then
		local notifySuccess = false
		local nextCharacter = getNextCharacter()

		while nextCharacter do
		
			notifySuccess = checkForNextExecution(nextCharacter)

			if(not notifySuccess) then
				local lastCharacter = nextCharacter
				nextCharacter = getNextCharacter()

				if(lastCharacter == nextCharacter) then
					timeouts[lastCharacter] = timeouts[lastCharacter] and timeouts[lastCharacter] + 1 or 1

					startNewInspectTimer(lastCharacter, GetTimePreciseSec())

					nextCharacter = nil
					
				end

				break
			else
				nextCharacter = nil

			end
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
		
		updateInspectionText()
	end

	inspectNextCharacter(3)
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

local function checkPlayerInspectionStatus(fullName, openRaidSpec, type)
	if(groupData[fullName]) then
		playerSpecs[fullName] = openRaidSpec or GetInspectSpecialization(groupData[fullName].unitID)

		--manualItemlevels[fullName] = calcItemLevel(groupData[fullName].unitID)

		updateSingleCharacterSpecData(fullName)

	end

	clearCharacter(fullName)
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

		checkPlayerInspectionStatus(fullName, nil, 1)
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
				checkPlayerInspectionStatus(singleUnitInfo.nameFull, singleUnitInfo.specId, 2)

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

miog.OnGearUpdate = function(unitId, unitGear, allUnitsGear)
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

	local name = miog.createFullNameFrom("unitID", unitId)

	if(name) then
		playerGearData[name] = unitGear

		updateSingleCharacterItemData(name)

	end
end

local function updateRaidLibData()
	local isInRaid, isInGroup = IsInRaid(), IsInGroup()

	if(isInRaid or isInGroup) then
		miog.openRaidLib.GetAllUnitsInfo()
		miog.openRaidLib.GetAllUnitsGear()

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

	miog.GroupManager.StatusBar.Refresh:SetScript("OnClick", function()
		updateAllData()

		if(playerInInspection) then
			clearCharacter(playerInInspection)

		end
	end)

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