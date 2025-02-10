local addonName, miog = ...
local wticc = WrapTextInColorCode

local fullPlayerName, shortName

local groupData = {}

local lastNotifyTime = 0
local pityTimer = nil
local playerInInspection
local playerSpecs = {}

local framePool

local inspectManager = CreateFrame("Frame", nil)
inspectManager:Hide()

miog.getPlayerSpec = function(name)
	return playerSpecs[name]

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

	indepthFrame.Name:SetText(WrapTextInColorCode(data.shortName, C_ClassColor.GetClassColor(data.classFileName):GenerateHexColor()))
	indepthFrame.Level:SetText("Level " .. data.level)

	local _, name = GetSpecializationInfoForSpecID(data.specID)

	indepthFrame.Spec:SetText(name and (name .. " " .. data.localizedClassName) or "???")
	indepthFrame.Guild:SetText(GetGuildInfo(data.unitID) or "Currently guildless")

	indepthFrame:SetPlayerData(data.name, data.realm)
	indepthFrame:ApplyFillData()

	indepthFrame:Show()
end

local function createSingleGroupManagerFrame(memberFrame, member)
	memberFrame.data = member
	memberFrame.id = member.index
	memberFrame.name = member.name
	memberFrame.unit = member.unitID

	memberFrame.fixedWidth = miog.GroupManager:GetWidth()
	memberFrame.Index:SetText(member.online and member.group or WrapTextInColorCode(member.group, miog.CLRSCC.red))
	memberFrame.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. (member.role .. "Icon.png" or "unknown.png"))
	memberFrame.Spec:SetTexture(miog.SPECIALIZATIONS[member.specID or 0].squaredIcon)
	memberFrame.Name:SetText(WrapTextInColorCode(member.shortName, C_ClassColor.GetClassColor(member.classFileName):GenerateHexColor()))

	if(member.rank == 2) then
		miog.GroupManager.LeaderCrown:ClearAllPoints()
		miog.GroupManager.LeaderCrown:SetPoint("RIGHT", memberFrame.Group, "RIGHT")
		miog.GroupManager.LeaderCrown:SetParent(memberFrame)
		miog.GroupManager.LeaderCrown:Show()

	end

	memberFrame.Itemlevel:SetText(member.ilvl or "N/A")
	memberFrame.Durability:SetText(member.durability and "(" .. member.durability .. "%)" or "N/A")
	memberFrame.Score:SetText(member.score or 0)
	memberFrame.Progress:SetText(member.progress or "N/A")

	if(member.keystoneShortName) then
		memberFrame.Keystone:SetText("+" .. member.keylevel .. " " .. member.keystoneShortName)

	else
		memberFrame.Keystone:SetText("---")

	end

	memberFrame:SetScript("OnClick", function(self, button)
		if(button == "RightButton") then
			if(IsInRaid()) then
				customMenu(self, "raid")

			elseif(IsInGroup()) then
				customMenu(self, "party")

			end
		elseif(button == "LeftButton") then
			showIndepthData(self.data)
		end
	end)
end

local function getOptionalPlayerData(fullName)
	local libName

	if(fullName == miog.createFullNameFrom("unitID", "player")) then
		libName = UnitName("player")

	else
		libName = fullName

	end

	local libData = miog.openRaidLib.GetAllUnitsGear()[libName]
	local keystoneInfo = miog.openRaidLib.GetAllKeystonesInfo()[libName]
	local raidData = miog.getNewRaidSortData(miog.createSplitName(fullName))

	if(libData) then
		groupData[fullName].ilvl = libData.ilevel or 0
		groupData[fullName].durability = libData.durability or 0

		if(libData.noEnchants and #libData.noEnchants > 0) then
			groupData[fullName].missingEnchants = {}

			for index, slotIdWithoutEnchant in ipairs (libData.noEnchants) do
				if(slotIdWithoutEnchant ~= 10) then
					groupData[fullName].missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
					
				end
			end
		end

		if(libData.noGems and #libData.noGems > 0) then
			groupData[fullName].missingGems = {}

			for index, slotIdWithEmptyGemSocket in ipairs (libData.noGems) do
				groupData[fullName].missingGems[index] = miog.SLOT_ID_INFO[slotIdWithEmptyGemSocket].localizedName
			end
		end
	end

	if(keystoneInfo) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)

		if(miog.CHALLENGE_MODE_INFO[id]) then
			groupData[fullName].keystoneShortName = miog.MAP_INFO[miog.CHALLENGE_MODE_INFO[id].mapID].shortName
			--groupData[fullName].keystone = texture
			groupData[fullName].keylevel = keystoneInfo.level
			groupData[fullName].keystoneFullName = mapName

		end
	end

	if(raidData) then
		local charData = raidData.character
		local mainData = raidData.main

		for i = 1, 2, 1 do
			local raidInfo = i == 1 and charData or mainData

			for k, v in ipairs(raidInfo.ordered) do
				if(v.difficulty > 0) then
					if(i == 1) then
						groupData[fullName].progress = (groupData[fullName].progress or "") .. wticc(v.parsedString, miog.DIFFICULTY[v.difficulty].color) .. " "
						groupData[fullName].progressWeight = groupData[fullName].progressWeight + (v.weight or 0)
					end
					
					groupData[fullName].progressTooltipData = (groupData[fullName].progressTooltipData or "") .. (i == 2 and "Main - " or "") .. v.shortName .. ": " .. wticc(miog.DIFFICULTY[v.difficulty].shortName .. ":" .. v.kills .. "/" .. #v.bosses, miog.DIFFICULTY[v.difficulty].color) .. "\r\n"
				end
			end
		end
	end

	local mplusData = miog.getMPlusSortData(miog.createSplitName(fullName))

	if(mplusData) then
		groupData[fullName].score = mplusData.score.score
		
	end
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
	frame.subgroupSpotID = data.subgroupSpotID
	frame.data = data

	frame.Name:SetText(data.shortName)
	
	frame:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=1, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})

	local color

	if(data.classFileName) then
		color = C_ClassColor.GetClassColor(data.classFileName)

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
		if(data.raidRole == "MAINTANK") then
			frame.RaidRole:SetTexture("interface/groupframe/ui-group-maintankicon.blp")
	
		elseif(data.raidRole == "MAINASSIST") then
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
				if(self.data.raidRole ~= nil) then
					GameTooltip_AddBlankLineToTooltip(GameTooltip)

					if (self.data.raidRole == "MAINTANK" ) then
						GameTooltip:AddLine("Raid role: " .. MAIN_TANK);
					elseif (self.data.raidRole == "MAINASSIST" ) then
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
		if(IsInRaid()) then
			self:StartMoving()

		end
	end)

	frame:SetScript("OnDragStop", function(self)
		local isOverFrame, index = isFrameOverAnySpace(self)

		if(isOverFrame and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))) then
			self:StopMovingOrSizing()
			bindFrameToSpaceGroupIndex(frame, index)
			swapButtonInRaidFrame(frame)
			--swapButtonToSubgroupInRaidFrame(self, index)

		else
			self:StopMovingOrSizing()
			bindFrameToSpace(frame, frame.occupiedSpace)

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

local currentInspectionName = ""

local function updateGroupData()
	if(not InCombatLockdown()) then
		miog.ClassPanel.LoadingSpinner:Hide()

		if(miog.GroupManager) then
			framePool:ReleaseAll()
		end

		groupData = {}

		local roleCount = {
			["TANK"] = 0,
			["HEALER"] = 0,
			["DAMAGER"] = 0,
		}    
		
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

		local hasNoData = true

		local groupOffset = 0
		local playersWithSpecData, inspectableMembers, numOfMembers = 0, 0, GetNumGroupMembers()
		local inspectedPlayerStillInGroup = false

		for groupIndex = 1, GetNumGroupMembers(), 1 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

			if(name) then
				local unitID

				if(IsInRaid()) then
					unitID = "raid" .. groupIndex

				elseif(IsInGroup() and name ~= shortName) then
					unitID = "party" .. groupIndex + groupOffset

				elseif(name == shortName) then
					unitID = "player"
					groupOffset = groupOffset - 1

				end

				local playerName, realm = miog.createSplitName(name)
				local fullName = playerName .. "-" .. (realm or "")
				
				groupData[fullName] = {
					index = groupIndex,
					unitID = unitID,
					name = fullName,
					shortName = playerName,
					classID = fileName and miog.CLASSFILE_TO_ID[fileName],
					localizedClassName = class,
					classFileName = fileName,
					role = combatRole,
					group = subgroup,
					specID = playerSpecs[fullName] or 0,
					rank = rank,
					level = level,
					zone = zone,
					online = online,
					dead = isDead,
					raidRole = role,
					masterLooter = isML,

					keylevel = 0,

					ilvl = 0,
					durability = 0,

					progressWeight = 0,
					progress = "",
					score = 0,
				}

				getOptionalPlayerData(fullName)
				
				if(miog.GroupManager) then
                	subgroupSpotsTaken[subgroup] = subgroupSpotsTaken[subgroup] + 1
				
					local playerFrame = createCharacterFrame(groupData[fullName])
					bindFrameToSubgroupSpot(playerFrame, subgroup, subgroupSpotsTaken[subgroup])
				end

				if(online and CanInspect(groupData[fullName].unitID)) then
					inspectableMembers = inspectableMembers + 1

				end

				if(playerInInspection == fullName and playerSpecs[fullName]) then
					ClearInspectPlayer(true)

				end

				if(fullName ~= fullPlayerName) then
					if(not playerInInspection and not playerSpecs[fullName] and CanInspect(groupData[fullName].unitID) and online) then --  and (GetTimePreciseSec() - lastNotifyTime) > miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE
						playerInInspection = fullName

						if(groupData[playerInInspection].classFileName) then
							local color = C_ClassColor.GetClassColor(groupData[playerInInspection].classFileName)
							currentInspectionName = color and WrapTextInColorCode(groupData[playerInInspection].shortName, color:GenerateHexColor()) or groupData[playerInInspection].shortName
							
						end

						C_Timer.After(miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE, function()
							if(playerInInspection and not playerSpecs[fullName]) then
								NotifyInspect(groupData[playerInInspection].unitID)

								pityTimer = C_Timer.NewTimer(10, function()
									ClearInspectPlayer(true)
									updateGroupData()
								
								end)
							end
						end)
					end
				else
					groupData[fullName].specID = GetSpecializationInfo(GetSpecialization())
					playerSpecs[fullName] = groupData[fullName].specID
				end

				if(groupData[fullName].specID) then
					specCount[groupData[fullName].specID] = specCount[groupData[fullName].specID] and specCount[groupData[fullName].specID] + 1 or 1

					if(groupData[fullName].role == nil) then
						groupData[fullName].role = GetSpecializationRoleByID(groupData[fullName].specID)
					end

					if(groupData[fullName].specID ~= 0) then
						playersWithSpecData = playersWithSpecData + 1
					end
				end

				if(roleCount[combatRole]) then
					roleCount[combatRole] = roleCount[combatRole] + 1
	
				end

				hasNoData = false

				if(fullName == playerInInspection) then
					inspectedPlayerStillInGroup = true
				end
			end
		end

		if(not inspectedPlayerStillInGroup) then
			ClearInspectPlayer(true)

		end

		if(playerInInspection) then
			miog.ClassPanel.LoadingSpinner:Show()

		end

		if(hasNoData) then
			local localizedClassName, fileName, id = UnitClass("player")
			local bestMap = C_Map.GetBestMapForUnit("player")
			local specID = GetSpecializationInfo(GetSpecialization())

			groupData[fullPlayerName] = {
				index = nil,
				unitID = "player",
				name = fullPlayerName,
				shortName = UnitNameUnmodified("player"),
				classID = id,
				classFileName = fileName,
				localizedClassName = localizedClassName,
				role = "DAMAGER",
				group = 0,
				specID = specID,
				rank = nil,
				level = UnitLevel("player"),
				zone = bestMap and C_Map.GetMapInfo(bestMap).name or "N/A",
				online = true,
				dead = UnitIsDead("player"),
				raidRole = nil,
				masterLooter = nil,

				progressWeight = 0,
				progress = "",
				score = 0,
			}

			playerSpecs[fullPlayerName] = specID

			getOptionalPlayerData(fullPlayerName)

			if(miog.GroupManager) then
				local playerFrame = createCharacterFrame(groupData[fullPlayerName])
				bindFrameToSubgroupSpot(playerFrame, 1, 1)
			end

			if(groupData[fullPlayerName].specID) then
				specCount[groupData[fullPlayerName].specID] = specCount[groupData[fullPlayerName].specID] and specCount[groupData[fullPlayerName].specID] + 1 or 1

				if(groupData[fullPlayerName].role == nil) then
					groupData[fullPlayerName].role = GetSpecializationRoleByID(groupData[fullPlayerName].specID)
				end

				if(groupData[fullPlayerName].specID ~= 0) then
					playersWithSpecData = playersWithSpecData + 1
				end
			end

			inspectableMembers = inspectableMembers + 1

		end

		local dataProvider = CreateDataProvider()

		for _, member in pairs(groupData) do
			dataProvider:Insert(member)
		end


		miog.ApplicationViewer.TitleBar.GroupComposition.Roles:SetText(roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"])

		if(miog.GroupManager) then
			miog.GroupManager.Groups.Tank.Text:SetText(roleCount["TANK"])
			miog.GroupManager.Groups.Healer.Text:SetText(roleCount["HEALER"])
			miog.GroupManager.Groups.Damager.Text:SetText(roleCount["DAMAGER"])

			miog.GroupManager:SetDataProvider(dataProvider)
		end

		if(miog.ClassPanel) then
			for classID, classEntry in ipairs(miog.CLASSES) do
				for _, v in ipairs(classEntry.specs) do
					local currentSpecFrame = miog.ClassPanel.Container.classFrames[classID].specPanel.specFrames[v]

					if(specCount[v]) then
						currentSpecFrame.layoutIndex = v
						currentSpecFrame.FontString:SetText(specCount[v])
						currentSpecFrame.Border:SetColorTexture(C_ClassColor.GetClassColor(classEntry.name):GetRGBA())
						currentSpecFrame:Show()

					else
						currentSpecFrame:Hide()
						currentSpecFrame.layoutIndex = nil

					end

				end
			end
	
			miog.ClassPanel.StatusString:SetText((currentInspectionName or "") .. "\n(" .. playersWithSpecData .. "/" .. inspectableMembers .. "/" .. numOfMembers .. ")")
			miog.ClassPanel.StatusString:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(playersWithSpecData .. " players with spec data.")
				GameTooltip:AddLine(inspectableMembers .. " group members that are inspectable (not offline or some weird faction stuff interaction).")
				GameTooltip:AddLine(numOfMembers .. " total group members.")
				GameTooltip:Show()
			end)
		end
	end
end

miog.updateGroupData = updateGroupData

local readyCheckStatus = {}

local function updateReadyStatus(name, isReady)
	local frame = miog.GroupManager.ScrollBox:FindFrameByPredicate(function(localFrame, data)
		return data.name == name
	end)

    if(frame) then
        frame.Ready:SetColorTexture(unpack(isReady and {0, 1, 0, 1} or isReady == false and {1, 0, 0, 1} or {1, 1, 0, 1}))

    end
end

local function groupManagerEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        local isInitialLogin, isReloadingUi = ...

        if(isInitialLogin or isReloadingUi) then
			miog.openRaidLib.GetAllUnitsInfo()

        end

		updateGroupData()

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
			startUpdate = true
			playerSpecs[fullName] = GetInspectSpecialization(groupData[fullName].unitID)

		end

		if(playerInInspection == fullName) then
			ClearInspectPlayer(true)

			if(pityTimer) then
				pityTimer:Cancel()
			end

			startUpdate = true
		end

		if(startUpdate) then
			updateGroupData()

		end
	elseif(event == "GROUP_JOINED") then
		miog.GroupManager.ScrollView:Flush()
		updateGroupData()

	elseif(event == "GROUP_LEFT") then
		miog.GroupManager.ScrollView:Flush()
		updateGroupData()
	
	elseif(event == "GROUP_ROSTER_UPDATE") then
		updateGroupData()

	elseif(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.UPDATE_AFTER_COMBAT) then
			miog.F.UPDATE_AFTER_COMBAT = false

			updateGroupData()
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

		for _, ready in pairs(readyCheckStatus) do
			if(not ready) then
				allReady = false

				break
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
		if(groupData[singleUnitInfo.nameFull]) then
			if(singleUnitInfo.specId and singleUnitInfo.specId > 0) then
				playerSpecs[singleUnitInfo.nameFull] = singleUnitInfo.specId
				updateGroupData()
			end
		end
	end
end

function MIOG_GETLIBGEAR()
	return miog.openRaidLib.GetAllUnitsGear()
end

local function updateRaidLibData()
	local isInRaid, isInGroup = IsInRaid(), IsInGroup()

	if(isInRaid or isInGroup) then
		miog.openRaidLib.GetAllUnitsGear()
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
	
	inspectManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	inspectManager:RegisterEvent("GROUP_JOINED")
	inspectManager:RegisterEvent("GROUP_LEFT")
	inspectManager:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	inspectManager:RegisterEvent("INSPECT_READY")
	inspectManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	inspectManager:RegisterEvent("PLAYER_REGEN_ENABLED")
	inspectManager:SetScript("OnEvent", groupManagerEvents)

	fullPlayerName = miog.createFullNameFrom("unitID", "player")
	
	shortName = GetUnitName("player", false)
	miog.fullPlayerName, miog.shortPlayerName = fullPlayerName, shortName
end

miog.loadGroupManager = function()
    miog.GroupManager = miog.pveFrame2.TabFramesPanel.GroupManager
	miog.GroupManager:SetScrollBox(miog.GroupManager.ScrollBox)

    framePool = CreateFramePool("Button", nil, "MIOG_GroupManagerRaidFrameCharacterTemplate", function(_, frame) frame:Hide() clearFrameFromSpace(frame) end)

	miog.GroupManager:SetScript("OnShow", function()
		updateRaidLibData()
		
		local name = miog.createFullNameFrom("unitID", "player")

		if(name) then
			updateGroupData()

		end
	end)

	miog.GroupManager.StatusBar.Refresh:SetScript("OnClick", function()
		updateRaidLibData()
	end)

	miog.GroupManager:OnLoad()
	miog.GroupManager:SetSettingsTable(MIOG_NewSettings.sortMethods.GroupManager)
	miog.GroupManager:AddMultipleSortingParameters({
		{name = "group", tooltipTitle = GROUP},
		{name = "role", tooltipTitle = ROLE},
		{name = "spec", tooltipTitle = SPECIALIZATION},
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
		createSingleGroupManagerFrame(frame, data)
	
	end)

    fillSpaceFramesTable()

    miog.GroupManager.Groups.Tank.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/tankIcon.png")
    miog.GroupManager.Groups.Healer.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/healerIcon.png")
    miog.GroupManager.Groups.Damager.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/damagerIcon.png")
	miog.GroupManager.Indepth:OnLoad("side")
end


hooksecurefunc("NotifyInspect", function(unitID)
	lastNotifyTime = GetTimePreciseSec()
end)

hooksecurefunc("ClearInspectPlayer", function(own)
	if(own) then
		playerInInspection = nil
		currentInspectionName = nil
	end
end)