local addonName, miog = ...
local wticc = WrapTextInColorCode

local partyPool

local groupSystem = {}
groupSystem.groupMember = {}

miog.groupSystem = groupSystem

local lastNotifyTime = 0

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_InspectCoroutineEventReceiver")



MIOG_InspectedNames = {}
MIOG_SavedSpecIDs = {}

local timers = {}

local currentInspection = nil

local function sortPartyCheckList(k1, k2)
	for key, tableElement in pairs(MIOG_SavedSettings.sortMethods.table.partyCheck) do
		if(tableElement.currentLayer == 1) then
			local firstState = tableElement.currentState

			for innerKey, innerTableElement in pairs(MIOG_SavedSettings.sortMethods.table.partyCheck) do
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

local function updateRosterInfoData()
	if(not InCombatLockdown()) then
		if(currentInspection and GetTimePreciseSec() - lastNotifyTime > 7) then
			ClearInspectPlayer(true)
			updateRosterInfoData()

		end

		if(partyPool) then
			partyPool:ReleaseAll()
		end

		groupSystem.groupMember = {}

		groupSystem.classCount = {
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

		groupSystem.roleCount = {
			["TANK"] = 0,
			["HEALER"] = 0,
			["DAMAGER"] = 0,
		}

		groupSystem.specCount = {}

		miog.F.LFG_STATE = miog.checkLFGState()
		local numOfMembers = GetNumGroupMembers()

		local indexedGroup = {}
		local inspectableMembers = 0
		local currentInspectionStillInGroup = false

		miog.F.LFG_STATE = miog.checkLFGState()

		local playersWithSpecData = 0
		local fullPlayerName = miog.createFullNameFrom("unitID", "player")

		if(miog.F.LFG_STATE == "solo") then
			local fileName, id = UnitClassBase("player")
			local bestMap = C_Map.GetBestMapForUnit("player")

			groupSystem.groupMember[fullPlayerName] = {
				unitID = "player",
				name = fullPlayerName,
				shortName = UnitName("player"),
				classID = id,
				classFileName = fileName,
				role = "DAMAGER",
				group = 0,
				specID = 0,
				rank = rank,
				level = UnitLevel("player"),
				zone = bestMap and C_Map.GetMapInfo(bestMap).name or "N/A",
				online = true,
				dead = UnitIsDead("player"),
				raidRole = role,
				masterLooter = isML,
				index = groupIndex,
			}
		end

		for groupIndex = 1, numOfMembers, 1 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

			if(name) then
				local unitID = ((IsInRaid() or (IsInGroup() and (numOfMembers ~= 1 and groupIndex ~= numOfMembers))) and miog.F.LFG_STATE..groupIndex) or "player"

				local nameTable = miog.simpleSplit(name, "-")

				if(not nameTable[2]) then
					nameTable[2] = GetNormalizedRealmName()

					if(nameTable[2]) then
						name = nameTable[1] .. "-" .. nameTable[2]

					end
				end

				if(name) then
					groupSystem.groupMember[name] = {
						unitID = unitID,
						name = name,
						shortName = nameTable[1],
						classID = fileName and miog.CLASSFILE_TO_ID[fileName],
						classFileName = fileName,
						role = combatRole,
						group = subgroup,
						specID = 0,
						rank = rank,
						level = level,
						zone = zone,
						online = online,
						dead = isDead,
						raidRole = role,
						masterLooter = isML,
						index = groupIndex,
					}

					if(name ~= fullPlayerName and (not MIOG_InspectedNames[name] or GetTimePreciseSec() - MIOG_InspectedNames[name] > 300)) then
						if(currentInspection == nil and UnitIsConnected(unitID) and CanInspect(unitID)) then
							currentInspection = name

							if(timers[name]) then
								timers[name]:Cancel()
							end

							local timer = C_Timer.NewTimer(10,
							function()
								if(currentInspection and GetTimePreciseSec() - lastNotifyTime > 7) then
									currentInspection = nil
									ClearInspectPlayer(true)
									updateRosterInfoData()
								end
							end)

							timers[name] = timer

							C_Timer.After(miog.C.BLIZZARD_INSPECT_THROTTLE,
							function()
								if(groupSystem.groupMember[name] and (not MIOG_SavedSpecIDs[name])) then
									lastNotifyTime = GetTimePreciseSec()

									NotifyInspect(groupSystem.groupMember[name].unitID)
				
									local color = C_ClassColor.GetClassColor(groupSystem.groupMember[name].classFileName)
									local shortName = color and WrapTextInColorCode(groupSystem.groupMember[name].shortName, color:GenerateHexColor()) or groupSystem.groupMember[name].shortName
									
									miog.ClassPanel.LoadingSpinner:Show()
									miog.ClassPanel.StatusString:SetText(shortName .. "\n(" .. playersWithSpecData .. "/" .. inspectableMembers .. "/" .. numOfMembers .. ")")
								end
							end)
						else
							MIOG_InspectedNames[name] = nil
							MIOG_SavedSpecIDs[name] = nil
				
						end
					end

					if(groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName] ]) then
						groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName] ] = groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName] ] + 1

					end
		
					if(name == currentInspection) then
						currentInspectionStillInGroup = true
					end
				end

				if(UnitIsConnected(unitID) and CanInspect(unitID)) then
					inspectableMembers = inspectableMembers + 1

				end

			end

		end

		if(currentInspectionStillInGroup == false) then
			currentInspection = nil
			ClearInspectPlayer(true)
		end

		for name, member in pairs(groupSystem.groupMember) do
			local libData = miog.checkSystem.groupMember[name]

			if(MIOG_InspectedNames[name]) then
				member.specID = MIOG_SavedSpecIDs[name] or GetInspectSpecialization(member.unitID)

				MIOG_SavedSpecIDs[name] = member.specID ~= 0 and member.specID or nil

			elseif(name == fullPlayerName) then
				local specID, _, _, _, role = GetSpecializationInfo(GetSpecialization())
				member.specID = specID
				member.role = role

			end
				
			if(libData) then
				member.ilvl = libData.ilvl or 0
				member.durability = libData.durability or 0
				member.missingEnchants = libData.missingEnchants
				member.missingGems = libData.missingGems


			else
				member.durability = 0
				member.ilvl = 0
			
			end

			local keystoneInfo = miog.checkSystem.keystoneData[member.name]

			if(keystoneInfo) then
				local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)

				member.keystone = texture
				member.keylevel = keystoneInfo.level
				member.keyname = mapName
			else
				member.keylevel = 0
			
			end


			local rioProfile

			if(miog.F.IS_RAIDERIO_LOADED) then
				rioProfile = RaiderIO.GetProfile(member.name)
			end

			member.progressWeight = 0

			if(rioProfile) then
				member.score = rioProfile.mythicKeystoneProfile and rioProfile.mythicKeystoneProfile.currentScore or 0
				
				local currentData, nonCurrentData, orderedData = miog.getRaidSortData(member.name)
				
				if(#orderedData > 0) then
					member.progress = ""
					member.progressTooltipData = ""
					
					for a, b in ipairs(orderedData) do
						member.progress = (member.progress or "") .. wticc(b.parsedString, miog.DIFFICULTY[b.difficulty].color) .. " "
					
						member.progressWeight = member.progressWeight + (b.weight or 0)

						if(b.mapId) then

							if(string.find(b.mapId, 10000)) then
								b.mapId = tonumber(strsub(b.mapId, strlen(b.mapId) - 3))
							end
						
							member.progressTooltipData = member.progressTooltipData .. b.shortName .. ": " .. wticc(miog.DIFFICULTY[b.difficulty].shortName .. ":" .. b.progress .. "/" .. b.bossCount, miog.DIFFICULTY[b.difficulty].color) .. "\r\n"
						end

						if(a == 3) then
							break
						end
					end

					if(member.progressWeight == 0) then
						member.progress = nil
						member.progressTooltipData = nil
					end
				end
			else
				member.progress = ""
				member.score = 0
			
			end

			if(member.specID) then
				groupSystem.specCount[member.specID] = groupSystem.specCount[member.specID] and groupSystem.specCount[member.specID] + 1 or 1

				if(member.role == nil) then
					member.role = GetSpecializationRoleByID(member.specID)
				end

				if(member.specID ~= 0) then
					playersWithSpecData = playersWithSpecData + 1
				end
			end

			if(groupSystem.roleCount[member.role]) then
				groupSystem.roleCount[member.role] = groupSystem.roleCount[member.role] + 1

			end

			indexedGroup[#indexedGroup+1] = member
		end

		local percentageInspected = playersWithSpecData / inspectableMembers

		if(miog.ClassPanel) then
			if(not currentInspection) then
				miog.ClassPanel.LoadingSpinner:Hide()
				miog.ClassPanel.StatusString:SetText("(" .. playersWithSpecData .. "/" .. inspectableMembers .. "/" .. numOfMembers .. ")")
				

			end

			--[[if(percentageInspected >= 1) then
				miog.ClassPanel.InspectStatus:Hide()

			else
				miog.ClassPanel.InspectStatus:Show()
			
			end

			miog.ClassPanel.InspectStatus:SetMinMaxValues(0, inspectableMembers)
			miog.ClassPanel.InspectStatus:SetValue(#indexedGroup)
			miog.ClassPanel.InspectStatus:SetStatusBarColor(1 - percentageInspected, percentageInspected, 0, 1)]]

			for classID, classEntry in ipairs(miog.CLASSES) do
				local classCount = groupSystem.classCount[classID]
				local currentClassFrame = miog.ClassPanel.Container.classFrames[classID]
				currentClassFrame.layoutIndex = classID
				currentClassFrame.FontString:SetText(classCount > 0 == true and classCount or "")
				currentClassFrame.Icon:SetDesaturated(classCount > 0 == false and true or false)

				if(classCount > 0) then
					local rPerc, gPerc, bPerc = GetClassColor(miog.CLASSES[classID].name)
					miog.createFrameBorder(currentClassFrame, 1, rPerc, gPerc, bPerc, 1)
					currentClassFrame.layoutIndex = currentClassFrame.layoutIndex - 100

				else
					miog.createFrameBorder(currentClassFrame, 1, 0, 0, 0, 1)

				end

				for _, v in ipairs(classEntry.specs) do
					local currentSpecFrame = miog.ClassPanel.Container.classFrames[classID].specPanel.specFrames[v]

					if(groupSystem.specCount[v]) then
						currentSpecFrame.layoutIndex = v
						currentSpecFrame.FontString:SetText(groupSystem.specCount[v])

						local color = C_ClassColor.GetClassColor(miog.CLASSES[classID].name)
						miog.createFrameBorder(currentSpecFrame, 1, color.r, color.g, color.b, 1)

						currentSpecFrame:Show()

					else
						currentSpecFrame.layoutIndex = nil
						currentSpecFrame.FontString:SetText("")
						currentSpecFrame:ClearBackdrop()
						currentSpecFrame:Hide()

					end

				end

				miog.ClassPanel.Container.classFrames[classID].specPanel:MarkDirty()

			end

			miog.ClassPanel.Container:MarkDirty()

			if(miog.PartyCheck) then
				table.sort(indexedGroup, sortPartyCheckList)
			end

			miog.ApplicationViewer.TitleBar.GroupComposition.Roles:SetText(groupSystem.roleCount["TANK"] .. "/" .. groupSystem.roleCount["HEALER"] .. "/" .. groupSystem.roleCount["DAMAGER"])

			if(partyPool) then
				for index, member in ipairs(indexedGroup) do
					local memberFrame = partyPool:Acquire()
					memberFrame.data = member
					memberFrame:SetWidth(miog.PartyCheck:GetWidth())
					memberFrame.Group:SetText(member.group)
					memberFrame.Name:SetText(WrapTextInColorCode(member.shortName, C_ClassColor.GetClassColor(member.classFileName):GenerateHexColor()))
					memberFrame.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. (member.role .. "Icon.png" or "unknown.png"))
					memberFrame.Spec:SetTexture(miog.SPECIALIZATIONS[member.specID or 0].squaredIcon)

					if(member.rank == 2) then
						miog.PartyCheck.LeaderCrown:ClearAllPoints()
						miog.PartyCheck.LeaderCrown:SetPoint("RIGHT", memberFrame.Group, "RIGHT")
						miog.PartyCheck.LeaderCrown:Show()

					end

					memberFrame.ILvl:SetText(member.ilvl or "N/A")
					memberFrame.Durability:SetText(member.durability or "N/A")
					memberFrame.Keystone:SetTexture(member.keystone)
					memberFrame.Keylevel:SetText("+" .. member.keylevel)
					memberFrame.Score:SetText(member.score or "0")
					memberFrame.Progress:SetText(member.progress or "N/A")

						--[[for k, v in pairs(memberFrame.MissingEnchantSlots) do
							if(type(v) == "table") then
								if(checkData.missingEnchants and checkData.missingEnchants[k]) then
									v.layoutIndex = k
									v:Show()

								else
									v.layoutIndex = nil
									v:Hide()

								end
							end

						end

						memberFrame.MissingEnchantSlots:MarkDirty()]]

					memberFrame.layoutIndex = index
					memberFrame:Show()
				end

				miog.PartyCheck.ScrollFrame.Container:MarkDirty()
			end
		end
	else
		miog.F.UPDATE_AFTER_COMBAT = true
		
	end
end

miog.updateRosterInfoData = updateRosterInfoData

local function resetInspectCoroutine()
	MIOG_InspectedNames = {}
	MIOG_SavedSpecIDs = {}

	ClearInspectPlayer(true)

	updateRosterInfoData()
end

miog.resetInspectCoroutine = resetInspectCoroutine

local function inspectCoroutineEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
		
        local isInitialLogin, isReloadingUi = ...

        if(isInitialLogin or isReloadingUi) then
			if(isInitialLogin) then
				MIOG_InspectedNames = {}
				MIOG_SavedSpecIDs = {}
			end

			miog.openRaidLib.GetAllUnitsInfo()
            updateRosterInfoData()

        end

    elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local name = GetUnitName(..., true)

		if(name) then
			if(groupSystem.groupMember[name]) then
				MIOG_InspectedNames[name] = nil
				MIOG_SavedSpecIDs[name] = nil

			end
		end

	elseif(event == "INSPECT_READY") then
		local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(...)
		local fullName

		if(realmName == "") then
			realmName = GetNormalizedRealmName()
		end

		fullName = name .. "-" .. realmName

		if(currentInspection == fullName) then
			ClearInspectPlayer(true)
		end

		if(groupSystem.groupMember[fullName]) then
			MIOG_InspectedNames[fullName] = GetTimePreciseSec()
			
			if(timers[fullName]) then
				timers[fullName]:Cancel()
			end

			updateRosterInfoData()
		
		end
	elseif(event == "GROUP_JOINED") then
		updateRosterInfoData()

	elseif(event == "GROUP_LEFT") then
		updateRosterInfoData()
	
	elseif(event == "GROUP_ROSTER_UPDATE") then
		updateRosterInfoData()

	elseif(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.UPDATE_AFTER_COMBAT) then
			miog.F.UPDATE_AFTER_COMBAT = false
			
			updateRosterInfoData()
		end
    end
end

hooksecurefunc("NotifyInspect", function(unitID)
	lastNotifyTime = GetTimePreciseSec()
end)

hooksecurefunc("ClearInspectPlayer", function(own)
	if(own) then
		currentInspection = nil
	end
end)


local function resetPartyFrames(_, frame)
    frame:Hide()
    frame.layoutIndex = nil

    frame.Name:SetText("")
    frame.Role:SetTexture(nil)
    frame.Spec:SetTexture(nil)
	frame.ILvl:SetText("")
	frame.Durability:SetText("")
	frame.Score:SetText("")
	frame.Progress:SetText("")
    frame.Keystone:SetTexture(nil)
	frame.Keylevel:SetText("")
	frame.data = nil

	
	--[[for k, v in pairs(frame.MissingEnchantSlots) do
		if(type(v) == "table") then
			v.layoutIndex = nil
			v:Hide()
		end

	end]]
end

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
   		partyPool = CreateFramePool("Frame", miog.PartyCheck.ScrollFrame.Container, "MIOG_PartyCheckPlayerTemplate", resetPartyFrames)
	end

	--local allUnitsInfo = miog.openRaidLib.GetAllUnitsInfo()
end