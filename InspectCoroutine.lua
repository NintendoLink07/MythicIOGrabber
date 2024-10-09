local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.inspection = {}

local raiderIOPanels = {}
local groupData = {}

local lastNotifyTime = 0
local pityTimer = nil
local playerInInspection

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_InspectCoroutineEventReceiver")

MIOG_InspectedNames = {}
MIOG_SavedSpecIDs = {}

miog.playerSpecs = {}

local collapsedList = {}

local fullPlayerName, shortName

miog.inspection.characterExists = function(playerName)
	return groupData[playerName] ~= nil
end

local function startPityTimer()
	pityTimer = C_Timer.NewTimer(10, function()
		if(GetTimePreciseSec() - lastNotifyTime > 10) then
			ClearInspectPlayer(true)
			miog.inspection.updateGroupData()
	
		end
	end)
end

local function createSinglePartyCheckFrame(memberFrame, member)
	memberFrame.data = member
	memberFrame.fixedWidth = miog.PartyCheck:GetWidth()
	memberFrame.Group:SetText(member.online and member.group or WrapTextInColorCode(member.group, miog.CLRSCC.red))
	memberFrame.Name:SetText(WrapTextInColorCode(member.shortName, C_ClassColor.GetClassColor(member.classFileName):GenerateHexColor()))
	memberFrame.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. (member.role .. "Icon.png" or "unknown.png"))
	memberFrame.Spec:SetTexture(miog.SPECIALIZATIONS[member.specID or 0].squaredIcon)

	--miog.insertInfoIntoDropdown(member.name, miog.checkSystem.keystoneData[member.name])
	
	memberFrame:SetScript("OnMouseDown", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		local frame = raiderIOPanels[member.name]
		
		frame.RaiderIOInformationPanel:SetPlayerData(member.name)
		--currentFrame.RaiderIOInformationPanel:SetOptionalData(searchResultInfo.comment, realm)
		frame.RaiderIOInformationPanel:ApplyFillData()

		memberFrame.node:ToggleCollapsed()
		collapsedList[member.name] = memberFrame.node:IsCollapsed()

		--miog.PartyCheck:SetExpandedChild(member.name, memberFrame.node:IsCollapsed())
	end)

	if(member.rank == 2) then
		miog.PartyCheck.LeaderCrown:ClearAllPoints()
		miog.PartyCheck.LeaderCrown:SetPoint("RIGHT", memberFrame.Group, "RIGHT")
		miog.PartyCheck.LeaderCrown:SetParent(memberFrame)
		miog.PartyCheck.LeaderCrown:Show()

	end
	memberFrame.ILvl:SetText(member.ilvl or "N/A")
	memberFrame.Durability:SetText(member.durability or "N/A")
	memberFrame.Keystone:SetTexture(member.keystone)
	memberFrame.Keylevel:SetText("+" .. member.keylevel)
	memberFrame.Score:SetText(member.score or 0)
	memberFrame.Progress:SetText(member.progress or "N/A")

	--memberFrame.layoutIndex = index
	--memberFrame:MarkDirty()
	--memberFrame:Show()
end

local function sortPartyCheckList(k1, k2)
	k1 = k1.data
	k2 = k2.data

	for key, tableElement in pairs(MIOG_NewSettings.sortMethods["PartyCheck"]) do
		if(tableElement.currentLayer == 1) then
			local firstState = tableElement.currentState

			for innerKey, innerTableElement in pairs(MIOG_NewSettings.sortMethods["PartyCheck"]) do
				if(innerTableElement.currentLayer == 2) then
					local secondState = innerTableElement.currentState

					if(k1[key] == k2[key]) then
						return secondState == 1 and k1[innerKey] > k2[innerKey] or secondState == 2 and k1[innerKey] < k2[innerKey]

					elseif(k1[key] ~= k2[key]) then
						return firstState == 1 and k1[key] > k2[key] or firstState == 2 and k1[key] < k2[key]

					end
				end
			end

			if(k1[key] == k2[key]) then
				return firstState == 1 and k1.index > k2.index or firstState == 2 and k1.index < k2.index

			elseif(k1[key] ~= k2[key]) then
				return firstState == 1 and k1[key] > k2[key] or firstState == 2 and k1[key] < k2[key]

			end

		end

	end

	return k1.index < k2.index
end

local function getOptionalPlayerData(fullName)
	local libData = miog.checkSystem.groupMember[fullName]
	local keystoneInfo = miog.checkSystem.keystoneData[fullName]
	local raidData = miog.getNewRaidSortData(miog.createSplitName(fullName))

	if(libData) then
		groupData[fullName].ilvl = libData.ilvl or 0
		groupData[fullName].durability = libData.durability or 0
		groupData[fullName].missingEnchants = libData.missingEnchants or {}
		groupData[fullName].missingGems = libData.missingGems or {}
		--groupData[fullName].hasWeaponEnchant = libData.hasWeaponEnchant or false
		
	end

	if(keystoneInfo) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)

		groupData[fullName].keystone = texture
		groupData[fullName].keylevel = keystoneInfo.level
		groupData[fullName].keyname = mapName
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
					
					groupData[fullName].progressTooltipData = groupData[fullName].progressTooltipData .. (i == 2 and "Main - " or "") .. v.shortName .. ": " .. wticc(miog.DIFFICULTY[v.difficulty].shortName .. ":" .. v.bossesKilled .. "/" .. #v.bosses, miog.DIFFICULTY[v.difficulty].color) .. "\r\n"
				end
			end
		end
	end

	local mplusData = miog.getMPlusSortData(miog.createSplitName(fullName))

	if(mplusData) then
		groupData[fullName].score = mplusData.score.score
		
	end
end

local currentInspectionName = ""

local function updateGroupData()
	if(not InCombatLockdown()) then
		groupData = {}

		local roleCount = {
			["TANK"] = 0,
			["HEALER"] = 0,
			["DAMAGER"] = 0,
		}

		local specCount = {}

		local hasNoData = true

		local playersWithSpecData, inspectableMembers, numOfMembers = 0, 0, GetNumGroupMembers()
		local inspectedPlayerStillInGroup = false

		for groupIndex = 1, GetNumGroupMembers(), 1 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

			if(name) then
				local unitID
				
				if(IsInRaid()) then
					unitID = "raid" .. groupIndex
				else
					if groupIndex == 1 then
						unitID = "player";

					else
						unitID = "party"..(groupIndex - 1);

					end
				end

				local playerName, realm = miog.createSplitName(name)
				local fullName = playerName .. "-" .. (realm or "")
				
				groupData[fullName] = {
					index = groupIndex,
					unitID = unitID,
					name = fullName,
					shortName = playerName,
					classID = fileName and miog.CLASSFILE_TO_ID[fileName],
					classFileName = fileName,
					role = combatRole,
					group = subgroup,
					specID = miog.playerSpecs[fullName] or 0,
					rank = rank,
					level = level,
					zone = zone,
					online = online,
					dead = isDead,
					raidRole = role,
					masterLooter = isML,

					keystone = "",
					keylevel = 0,
					keyname = "",

					ilvl = 0,
					durability = 0,
					missingEnchants = {},
					missingGems = {},
					--hasWeaponEnchant = false,

					progressWeight = 0,
					progress = "",
					progressTooltipData = "",
					score = 0,

					collapsed = collapsedList[fullName]
				}

				getOptionalPlayerData(fullName)

				if(online and CanInspect(groupData[fullName].unitID)) then
					inspectableMembers = inspectableMembers + 1

				end

				if(fullName ~= fullPlayerName) then
					if(not miog.playerSpecs[fullName] and not playerInInspection and CanInspect(groupData[fullName].unitID) and online) then --  and (GetTimePreciseSec() - lastNotifyTime) > miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE
						playerInInspection = fullName

						if(groupData[playerInInspection].classFileName) then
							local color = C_ClassColor.GetClassColor(groupData[playerInInspection].classFileName)
							currentInspectionName = color and WrapTextInColorCode(groupData[playerInInspection].shortName, color:GenerateHexColor()) or groupData[playerInInspection].shortName

							C_Timer.After(miog.C.BLIZZARD_INSPECT_THROTTLE_SAVE, function()
								NotifyInspect(unitID)
								startPityTimer()
							
							end)
						end
					end
				else
					groupData[fullName].specID = GetSpecializationInfo(GetSpecialization())

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

		if(hasNoData) then
			local fileName, id = UnitClassBase("player")
			local bestMap = C_Map.GetBestMapForUnit("player")
			local specID = GetSpecializationInfo(GetSpecialization())

			groupData[fullPlayerName] = {
				index = nil,
				unitID = "player",
				name = fullPlayerName,
				shortName = UnitName("player"),
				classID = id,
				classFileName = fileName,
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

				keystone = "",
				keylevel = 0,
				keyname = "",

				ilvl = 0,
				durability = 0,
				missingEnchants = {},
				missingGems = {},
				--hasWeaponEnchant = false,

				progressWeight = 0,
				progress = "",
				progressTooltipData = "",
				score = 0,

				collapsed = collapsedList[fullPlayerName]
			}

			miog.playerSpecs[fullPlayerName] = specID

			getOptionalPlayerData(fullPlayerName)

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

		local sortingData = {}

		for _, member in pairs(groupData) do
			table.insert(sortingData, member)
		end

		--miog.ClassPanel.Container:MarkDirty()

		miog.ApplicationViewer.TitleBar.GroupComposition.Roles:SetText(roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"])

		if(miog.PartyCheck) then
			miog.PartyCheck:UpdateSortingData(sortingData)
			miog.PartyCheck:SetScrollView(miog.PartyCheck.ScrollView)

			if(miog.PartyCheck:IsShown()) then
				miog.PartyCheck:Sort()
			end
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

		miog.inspection.groupData = groupData
	end
end

miog.inspection.updateGroupData = updateGroupData

local function updateGroupClassData()
	local classCount = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0,
		[9] = 0,
		[10] = 0,
		[11] = 0,
		[12] = 0,
		[13] = 0,
	}
	local hasNoData = true

	for groupIndex = 1, GetNumGroupMembers(), 1 do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP
		
		if(name) then
			if(classCount[miog.CLASSFILE_TO_ID[fileName] ]) then
				classCount[miog.CLASSFILE_TO_ID[fileName] ] = classCount[miog.CLASSFILE_TO_ID[fileName] ] + 1

			end

			hasNoData = false
		end
	end

	if(hasNoData) then
		local _, id = UnitClassBase("player")
		
		if(classCount[id]) then
			classCount[id] = classCount[id] + 1

		end
	end

	if(miog.ClassPanel) then
		if(not playerInInspection) then
			miog.ClassPanel.LoadingSpinner:Hide()

		else
			miog.ClassPanel.LoadingSpinner:Show()

		end

		for classID, classEntry in ipairs(miog.CLASSES) do
			local numOfClasses = classCount[classID]
			local currentClassFrame = miog.ClassPanel.Container.classFrames[classID]
			currentClassFrame.layoutIndex = classID
			currentClassFrame.Icon:SetDesaturated(numOfClasses < 1)

			if(numOfClasses > 0) then
				--local rPerc, gPerc, bPerc = GetClassColor(miog.CLASSES[classID].name)
				--miog.createFrameBorder(currentClassFrame, 1, rPerc, gPerc, bPerc, 1)
				currentClassFrame.FontString:SetText(numOfClasses)
				currentClassFrame.Border:SetColorTexture(C_ClassColor.GetClassColor(classEntry.name):GetRGBA())
				currentClassFrame.layoutIndex = currentClassFrame.layoutIndex - 100

			else
				currentClassFrame.FontString:SetText("")
				currentClassFrame.Border:SetColorTexture(0, 0, 0, 1)
				--miog.createFrameBorder(currentClassFrame, 1, 0, 0, 0, 1)

			end

			miog.ClassPanel.Container.classFrames[classID].specPanel:MarkDirty()

		end
	end
end

local function inspectCoroutineEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
		
        local isInitialLogin, isReloadingUi = ...

        if(isInitialLogin or isReloadingUi) then
			--[[if(isInitialLogin) then
				MIOG_InspectedNames = {}
				MIOG_SavedSpecIDs = {}
			end]]

			miog.openRaidLib.GetAllUnitsInfo()

        end

		--updateRosterInfoData()

		updateGroupData()
		updateGroupClassData()

    elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local fullName = miog.createFullNameFrom("unitID", ...)

		if(fullName and groupData[fullName]) then
			--MIOG_InspectedNames[fullName] = nil
			--MIOG_SavedSpecIDs[name] = nil
			miog.playerSpecs[fullName] = nil

		end

	elseif(event == "INSPECT_READY") then
		local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(...)
		local fullName = miog.createFullNameFrom("unitName", name.."-"..realmName)

		--[[if(currentInspection == fullName) then
			ClearInspectPlayer(true)
		end]]

		if(playerInInspection == fullName) then
			ClearInspectPlayer(true)

			if(pityTimer) then
				pityTimer:Cancel()
			end

		end

		if(groupData[fullName]) then
			miog.playerSpecs[fullName] = GetInspectSpecialization(groupData[fullName].unitID)

			updateGroupData()

		end

		--[[if(groupSystem.groupMember[fullName]) then
			MIOG_InspectedNames[fullName] = GetTimePreciseSec()
			
			if(timers[fullName]) then
				timers[fullName]:Cancel()
			end

			updateRosterInfoData()
		
		end]]
	elseif(event == "GROUP_JOINED") then
		updateGroupData()
		updateGroupClassData()

	elseif(event == "GROUP_LEFT") then
		updateGroupData()
		updateGroupClassData()
	
	elseif(event == "GROUP_ROSTER_UPDATE") then
		updateGroupData()
		updateGroupClassData()

	elseif(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.UPDATE_AFTER_COMBAT) then
			miog.F.UPDATE_AFTER_COMBAT = false

			updateGroupData()
		end
    end
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

miog.createInspectCoroutine = function()
	--miog.OnUnitUpdate()
	eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventReceiver:RegisterEvent("GROUP_JOINED")
	eventReceiver:RegisterEvent("GROUP_LEFT")
	eventReceiver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	eventReceiver:RegisterEvent("INSPECT_READY")
	eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventReceiver:SetScript("OnEvent", inspectCoroutineEvents)

	if(miog.PartyCheck) then
		local ScrollView = CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 2)

		miog.PartyCheck.ScrollView = ScrollView
		
		ScrollUtil.InitScrollBoxListWithScrollBar(miog.PartyCheck.ScrollBox, miog.PartyCheck.ScrollBox.ScrollBar, ScrollView)

		local function initializePartyFrames(frame, node)
			local data = node:GetData()

			if(data.template == "MIOG_PartyCheckPlayerTemplate") then
				frame.node = node
		
				createSinglePartyCheckFrame(frame, data)
		
			elseif(data.template == "MIOG_NewRaiderIOInfoPanel") then
				raiderIOPanels[data.name] = {RaiderIOInformationPanel = frame}
				
				local playerName, realm = miog.createSplitName(data.name)
				frame:OnLoad()
				frame:SetPlayerData(playerName, realm)
				frame:ApplyFillData()

				if(data.classFileName) then
					local r, g, b = C_ClassColor.GetClassColor(data.classFileName):GetRGB()

					frame.Background:SetColorTexture(r, g, b, 0.5)
				end
			end
		end
		
		local function CustomFactory(factory, node)
			local data = node:GetData()
			local template = data.template
			factory(template, initializePartyFrames)
		end

		ScrollView:SetElementFactory(CustomFactory)
	end

	fullPlayerName = miog.createFullNameFrom("unitID", "player")
	shortName = GetUnitName("player", false)
	miog.fullPlayerName, miog.shortPlayerName = fullPlayerName, shortName

	--local allUnitsInfo = miog.openRaidLib.GetAllUnitsInfo()
end