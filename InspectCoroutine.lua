local addonName, miog = ...
local wticc = WrapTextInColorCode

local groupSystem = {}
groupSystem.groupMember = {}
local lastNotifyTime = 0
local inspectCoroutine

MIOG_InspectQueue = {}
MIOG_InspectedGUIDs = {}
MIOG_SavedSpecIDs = {}

local function requestInspectData()
	for guid, v in pairs(MIOG_InspectQueue) do
		C_Timer.After((lastNotifyTime - GetTimePreciseSec()) > miog.C.BLIZZARD_INSPECT_THROTTLE and 0 or miog.C.BLIZZARD_INSPECT_THROTTLE,
		function()
			if(UnitIsConnected(v) and UnitGUID(v)) then
				NotifyInspect(v)

				-- LAST NOTIFY SAVED SO THE MAX TIME BETWEEN NOTIFY CALLS IS ~1.5s
				lastNotifyTime = GetTimePreciseSec()

			else
				--GUID gone

			end
		end)

		coroutine.yield(inspectCoroutine)
	end

	coroutine.yield(inspectCoroutine)

end

local function checkCoroutineStatus(newInspectData)
	if(inspectCoroutine == nil) then
		inspectCoroutine = coroutine.create(requestInspectData)
		miog.handleCoroutineReturn({coroutine.resume(inspectCoroutine)})

	else
		if(coroutine.status(inspectCoroutine) == "dead") then
			inspectCoroutine = coroutine.create(requestInspectData)
			miog.handleCoroutineReturn({coroutine.resume(inspectCoroutine)})

		elseif(newInspectData) then
			miog.handleCoroutineReturn({coroutine.resume(inspectCoroutine)})

		end
	end
end

local function createGroupMemberEntry(guid, unitID)
	local _, classFile, _, _, _, name = GetPlayerInfoByGUID(guid)
	local classID = classFile and miog.CLASSFILE_TO_ID[classFile]
	local specID = GetInspectSpecialization(unitID)

	MIOG_InspectedGUIDs[guid] = GetTimePreciseSec()

	groupSystem.groupMember[guid] = {
		unitID = unitID,
		name = name or UnitName(unitID),
		classID = classID or select(2, UnitClassBase(unitID)),
		role = GetSpecializationRoleByID(specID),
		specID = specID ~= 0 and specID or nil
	}

end

local function updateRosterInfoData()
	miog.releaseRaidRosterPool()

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

	--SHOW CURRENTLY INSPECTED DUDE FOR MANUAL LOOKUP

	miog.F.LFG_STATE = miog.checkLFGState()
	local numOfMembers = GetNumGroupMembers()

	for groupIndex = 1, MAX_RAID_MEMBERS, 1 do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

		if(name) then
			local unitID = ((IsInRaid() or (IsInGroup() and (numOfMembers ~= 1 and groupIndex ~= 5))) and miog.F.LFG_STATE..groupIndex) or "player"
			local guid = UnitGUID(unitID)

			if(guid) then
				groupSystem.groupMember[guid] = {
					unitID = unitID,
					name = name,
					classID = fileName and miog.CLASSFILE_TO_ID[fileName],
					role = combatRole,
				}

				if(guid ~= UnitGUID("player") and not MIOG_InspectQueue[guid] and not MIOG_InspectedGUIDs[guid]) then
					if(not MIOG_InspectedGUIDs[guid] or GetTimePreciseSec() - MIOG_InspectedGUIDs[guid] > 300) then
						MIOG_InspectQueue[guid] = unitID
					end

				end

				if(groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName]]) then
					groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName]] = groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName]] + 1

				end
	
			end

		end

	end

	local indexedGroup = {}

	for guid, member in pairs(groupSystem.groupMember) do
		if(MIOG_InspectedGUIDs[guid]) then
			member.specID = MIOG_SavedSpecIDs[guid] or GetInspectSpecialization(member.unitID)

			MIOG_SavedSpecIDs[guid] = member.specID ~= 0 and member.specID or nil

		elseif(guid == UnitGUID("player")) then
			local specID, _, _, _, role = GetSpecializationInfo(GetSpecialization())
			member.specID = specID
			member.role = role
		end

		if(member.specID) then
			groupSystem.specCount[member.specID] = groupSystem.specCount[member.specID] and groupSystem.specCount[member.specID] + 1 or 1

			indexedGroup[#indexedGroup+1] = member
			indexedGroup[#indexedGroup].guid = guid

			if(member.role == nil) then
				member.role = GetSpecializationRoleByID(member.specID)
			end

			if(groupSystem.roleCount[member.role]) then
				groupSystem.roleCount[member.role] = groupSystem.roleCount[member.role] + 1

			end
		end
	end

	local percentageInspected = #indexedGroup / numOfMembers

	if(percentageInspected >= 1) then
		miog.ApplicationViewer.ClassPanel.InspectStatus:Hide()

	else
		miog.ApplicationViewer.ClassPanel.InspectStatus:Show()
	
	end

	miog.ApplicationViewer.ClassPanel.InspectStatus:SetMinMaxValues(0, numOfMembers)
	miog.ApplicationViewer.ClassPanel.InspectStatus:SetValue(#indexedGroup)
	miog.ApplicationViewer.ClassPanel.InspectStatus:SetStatusBarColor(1 - percentageInspected, percentageInspected, 0, 1)

	for classID, classEntry in ipairs(miog.CLASSES) do
		local classCount = groupSystem.classCount[classID]
		local currentClassFrame = miog.ApplicationViewer.ClassPanel.classFrames[classID]
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
			local currentSpecFrame = miog.ApplicationViewer.ClassPanel.classFrames[classID].specPanel.specFrames[v]

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

		miog.ApplicationViewer.ClassPanel.classFrames[classID].specPanel:MarkDirty()

	end

	miog.ApplicationViewer.ClassPanel:MarkDirty()

	if(numOfMembers < 5) then
		if(groupSystem.roleCount["TANK"] < 1) then
			indexedGroup[#indexedGroup + 1] = {guid = "emptyTank", unitID = "emptyTank", name = "afkTank", classID = 20, role = "TANK", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			--groupSystem.roleCount["TANK"] = groupSystem.roleCount["TANK"] + 1
		end

		if(groupSystem.roleCount["HEALER"] < 1 and #indexedGroup < 5) then
			indexedGroup[#indexedGroup + 1] = {guid = "emptyHealer", unitID = "emptyHealer", name = "afkHealer", classID = 21, role = "HEALER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			--groupSystem.roleCount["HEALER"] = groupSystem.roleCount["HEALER"] + 1

		end

		for i = 1, 3 - groupSystem.roleCount["DAMAGER"], 1 do
			if(groupSystem.roleCount["DAMAGER"] < 3 and #indexedGroup < 5) then
				indexedGroup[#indexedGroup + 1] = {guid = "emptyDPS" .. i, unitID = "emptyDPS" .. i, name = "afkDPS" .. i, classID = 22, role = "DAMAGER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
				--groupSystem.roleCount["DAMAGER"] = groupSystem.roleCount["DAMAGER"] + 1

			end

		end
	end

	table.sort(indexedGroup, function(k1, k2)
		if(k1.role ~= k2.role) then
			return k1.role > k2.role

		else
			return k1.classID > k2.classID

		end
	end)

	if(numOfMembers <= 5) then
		miog.ApplicationViewer.TitleBar.GroupComposition.Roles:Hide()

		for index, groupMember in ipairs(indexedGroup) do
			local specIcon = groupMember.icon or miog.SPECIALIZATIONS[groupMember.specID].squaredIcon
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.ApplicationViewer.TitleBar.GroupComposition.Party, miog.ApplicationViewer.TitleBar.Faction:GetWidth() - 3, miog.ApplicationViewer.TitleBar.Faction:GetHeight() - 3, "Texture", specIcon)
			classIconFrame.layoutIndex = index
			classIconFrame:SetFrameStrata("DIALOG")

			if(groupMember.classID <= 13) then
				classIconFrame:SetScript("OnEnter", function()
					local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(groupMember.guid)

					GameTooltip:SetOwner(classIconFrame, "ANCHOR_CURSOR")
					GameTooltip:AddLine(name .. " - " .. (realm ~= "" and realm or GetRealmName()))
					GameTooltip:Show()

				end)
				classIconFrame:SetScript("OnLeave", function()
					GameTooltip:Hide()

				end)

				local color = C_ClassColor.GetClassColor(miog.CLASSES[groupMember.classID].name)
				miog.createFrameBorder(classIconFrame, 1, color.r, color.g, color.b, 1)

			end

			if(index == 5) then
				break
			end

		end
		
		miog.ApplicationViewer.TitleBar.GroupComposition.Party:MarkDirty()
		miog.ApplicationViewer.TitleBar.GroupComposition.Party:Show()

	else
		miog.ApplicationViewer.TitleBar.GroupComposition.Party:Hide()

		miog.ApplicationViewer.TitleBar.GroupComposition.Roles:SetText(groupSystem.roleCount["TANK"] .. "/" .. groupSystem.roleCount["HEALER"] .. "/" .. groupSystem.roleCount["DAMAGER"])
		miog.ApplicationViewer.TitleBar.GroupComposition.Roles:Show()
		
	end
end

-- IMPLEMENT QUEUE SAVING

local function inspectCoroutineEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
		
        local isInitialLogin, isReloadingUi = ...

        if(isInitialLogin or isReloadingUi) then
			if(isInitialLogin) then
				MIOG_InspectedGUIDs = {}
				MIOG_InspectQueue = {}
				MIOG_SavedSpecIDs = {}
			end
            updateRosterInfoData()

        end

		checkCoroutineStatus()

    elseif(event == "GROUP_JOINED" or event == "GROUP_LEFT") then
		--print("JOINED")
        miog.checkIfCanInvite()

    elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local guid = UnitGUID(...)

		if(guid) then
			if(groupSystem.groupMember[guid] and not MIOG_InspectQueue[guid]) then
				MIOG_InspectedGUIDs[guid] = nil
				MIOG_SavedSpecIDs[guid] = nil
				MIOG_InspectQueue[guid] = ...
				checkCoroutineStatus()

			end
		end

	elseif(event == "INSPECT_READY") then
		if(groupSystem.groupMember[...] or MIOG_InspectQueue[...]) then
			MIOG_InspectedGUIDs[...] = GetTimePreciseSec()
			MIOG_InspectQueue[...] = nil
			
			updateRosterInfoData()

			ClearInspectPlayer()

			checkCoroutineStatus(true)

		else
			local unitID = UnitTokenFromGUID(...)
			miog.F.LFG_STATE = miog.checkLFGState()

			---@diagnostic disable-next-line: param-type-mismatch
			if(miog.F.LFG_STATE == "raid" and UnitInRaid(unitID) or miog.F.LFG_STATE == "party" and UnitInParty(unitID)) then
				createGroupMemberEntry(..., unitID)

			end

		end
	elseif(event == "GROUP_ROSTER_UPDATE") then
		updateRosterInfoData()
		checkCoroutineStatus()

    end
end

hooksecurefunc("NotifyInspect", function()
	lastNotifyTime = GetTimePreciseSec()
end)

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_InspectCoroutineEventReceiver")

eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
eventReceiver:RegisterEvent("GROUP_JOINED")
eventReceiver:RegisterEvent("GROUP_LEFT")
eventReceiver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventReceiver:RegisterEvent("INSPECT_READY")
eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
eventReceiver:SetScript("OnEvent", inspectCoroutineEvents)