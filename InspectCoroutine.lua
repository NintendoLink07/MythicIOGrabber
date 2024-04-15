local addonName, miog = ...
local wticc = WrapTextInColorCode

local groupSystem = {}
groupSystem.groupMember = {}
groupSystem.inspectedGUIDs = {}
local lastNotifyTime = 0
local inspectQueue = {}
local inspectCoroutine

local function updateSpecFrames()
	miog.releaseRaidRosterPool()

	local indexedGroup = {}
	groupSystem.specCount = {}

	groupSystem.roleCount = {
		["TANK"] = 0,
		["HEALER"] = 0,
		["DAMAGER"] = 0,
	}

	local numOfMembers = GetNumGroupMembers()
	numOfMembers = numOfMembers ~= 0 and numOfMembers or 1

	for guid, groupMember in pairs(groupSystem.groupMember) do
		if(groupMember.specID ~= nil and groupMember.specID ~= 0) then
			if(UnitGUID(groupMember.unitID) == guid) then
				local unitInPartyOrRaid = UnitInRaid(groupMember.unitID) or UnitInParty(groupMember.unitID) or miog.F.LFG_STATE == "solo"

				if(unitInPartyOrRaid) then
					indexedGroup[#indexedGroup+1] = groupMember
					indexedGroup[#indexedGroup].guid = guid

					groupSystem.specCount[groupMember.specID] = groupSystem.specCount[groupMember.specID] and groupSystem.specCount[groupMember.specID] + 1 or 1
				end
			end
		end
	end

	local percentageInspected = #indexedGroup / numOfMembers

	miog.applicationViewer.ClassPanel.InspectStatus:SetMinMaxValues(0, numOfMembers)
	miog.applicationViewer.ClassPanel.InspectStatus:SetValue(#indexedGroup)
	miog.applicationViewer.ClassPanel.InspectStatus:SetStatusBarColor(1 - percentageInspected, percentageInspected, 0, 1)


	if(percentageInspected >= 1) then
		miog.applicationViewer.ClassPanel.InspectStatus:Hide()

	else
		miog.applicationViewer.ClassPanel.InspectStatus:Show()
	
	end

	local specCounter = 1

	for classID, classEntry in ipairs(miog.CLASSES) do
		for _, v in ipairs(classEntry.specs) do
			local currentSpecFrame = miog.applicationViewer.ClassPanel.classFrames[classID].specPanel.specFrames[v]

			if(groupSystem.specCount[v]) then
				currentSpecFrame.layoutIndex = specCounter
				currentSpecFrame.FontString:SetText(groupSystem.specCount[v])
				specCounter = specCounter + 1

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

		miog.applicationViewer.ClassPanel.classFrames[classID].specPanel:MarkDirty()

	end

	miog.applicationViewer.ClassPanel:MarkDirty()

	if(#indexedGroup < 5) then
		if(groupSystem.roleCount["TANK"] < 1) then
			indexedGroup[#indexedGroup + 1] = {guid = "emptyTank", unitID = "emptyTank", name = "afkTank", classID = 20, role = "TANK", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			groupSystem.roleCount["TANK"] = groupSystem.roleCount["TANK"] + 1
		end

		if(groupSystem.roleCount["HEALER"] < 1 and #indexedGroup < 5) then
			indexedGroup[#indexedGroup + 1] = {guid = "emptyHealer", unitID = "emptyHealer", name = "afkHealer", classID = 21, role = "HEALER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
			groupSystem.roleCount["HEALER"] = groupSystem.roleCount["HEALER"] + 1

		end

		for i = 1, 3 - groupSystem.roleCount["DAMAGER"], 1 do
			if(groupSystem.roleCount["DAMAGER"] < 3 and #indexedGroup < 5) then
				indexedGroup[#indexedGroup + 1] = {guid = "emptyDPS" .. i, unitID = "emptyDPS" .. i, name = "afkDPS" .. i, classID = 22, role = "DAMAGER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"}
				groupSystem.roleCount["DAMAGER"] = groupSystem.roleCount["DAMAGER"] + 1

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

	local width = miog.applicationViewer.TitleBar.Faction:GetWidth()
	local height = miog.applicationViewer.TitleBar.Faction:GetHeight()

	if(numOfMembers < 6) then
		miog.applicationViewer.TitleBar.GroupComposition.Roles:Hide()

		for index, groupMember in ipairs(indexedGroup) do
			local specIcon = groupMember.icon or miog.SPECIALIZATIONS[groupMember.specID].squaredIcon
			local classIconFrame = miog.createBasicFrame("raidRoster", "BackdropTemplate", miog.applicationViewer.TitleBar.GroupComposition.Party, width - 2, height - 2, "Texture", specIcon)
			classIconFrame.layoutIndex = index
			--classIconFrame:SetPoint("LEFT", lastIcon or miog.applicationViewer.TitleBar.GroupComposition, lastIcon and "RIGHT" or "LEFT")
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
		
		miog.applicationViewer.TitleBar.GroupComposition.Party:MarkDirty()
	else
		miog.applicationViewer.TitleBar.GroupComposition.Roles:Show()
		miog.applicationViewer.TitleBar.GroupComposition.Roles:SetText(groupSystem.roleCount["TANK"] .. "/" .. groupSystem.roleCount["HEALER"] .. "/" .. groupSystem.roleCount["DAMAGER"])
		
	end
end

local function requestInspectData()

	for _, v in pairs(inspectQueue) do
		C_Timer.After((lastNotifyTime - GetTimePreciseSec()) > miog.C.BLIZZARD_INSPECT_THROTTLE and 0 or miog.C.BLIZZARD_INSPECT_THROTTLE,
		function()
			if(UnitGUID(v)) then
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

	groupSystem.inspectedGUIDs[guid] = specID

	groupSystem.groupMember[guid] = {
		unitID = unitID,
		name = name or UnitName(unitID),
		classID = classID or select(2, UnitClassBase(unitID)),
		role = GetSpecializationRoleByID(specID),
		specID = specID ~= 0 and specID or nil
	}

end

local function updateRosterInfoData()
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

	miog.F.LFG_STATE = miog.checkLFGState()
	local numOfMembers = GetNumGroupMembers()

	for groupIndex = 1, miog.MAX_GROUP_SIZES[miog.F.LFG_STATE], 1 do
		local unitID = ((miog.F.LFG_STATE == "raid" or (miog.F.LFG_STATE == "party" and groupIndex ~= miog.MAX_GROUP_SIZES["party"])) and miog.F.LFG_STATE..groupIndex) or "player"

		local guid = UnitGUID(unitID)

		if(guid) then
			local _, _, _, _, _, classFile, _, _, _, _, _, role = GetRaidRosterInfo(groupIndex)

			local specID = GetInspectSpecialization(unitID)

			groupSystem.groupMember[guid] = {
				unitID = unitID,
				name = UnitName(unitID),
				classID = select(2, UnitClassBase(unitID)) or classFile and miog.CLASSFILE_TO_ID[classFile] or miog.CLASSFILE_TO_ID[select(2, GetPlayerInfoByGUID(guid))],
				role = role == "NONE" and "DAMAGER" or UnitGroupRolesAssigned(unitID) or GetSpecializationRoleByID(specID) or role,
				specID = groupSystem.inspectedGUIDs[guid] or specID ~= 0 and specID or nil
			}

			local member = groupSystem.groupMember[guid]

			if(not groupSystem.groupMember[guid].specID) then
				if(guid ~= miog.C.PLAYER_GUID and (miog.F.LFG_STATE == "raid" or miog.F.LFG_STATE == "party")) then
					inspectQueue[guid] = unitID

				else
					member.specID = GetSpecializationInfo(GetSpecialization())
					member.classID = select(2, UnitClassBase(unitID))
					member.role = member.role or GetSpecializationRoleByID(member.specID)

				end

			else
				groupSystem.inspectedGUIDs[guid] = groupSystem.groupMember[guid].specID

			end

			if(member.classID) then
				groupSystem.classCount[member.classID] = groupSystem.classCount[member.classID] and groupSystem.classCount[member.classID] + 1 or 1

			end

			updateSpecFrames()

		else
			--Unit does not exist

		end

	end

	local keys = {}

	for key, _ in pairs(groupSystem.classCount) do
		table.insert(keys, key)

	end

	table.sort(keys, function(a, b) return groupSystem.classCount[a] > groupSystem.classCount[b] end)

	local counter = 1

	for _, classID in ipairs(keys) do
		local classCount = groupSystem.classCount[classID]
		local currentClassFrame = miog.applicationViewer.ClassPanel.classFrames[classID]
		currentClassFrame.layoutIndex = counter
		currentClassFrame.FontString:SetText(classCount > 0 == true and classCount or "")
		currentClassFrame.Icon:SetDesaturated(classCount > 0 == false and true or false)

		if(classCount > 0) then
			local rPerc, gPerc, bPerc = GetClassColor(miog.CLASSES[classID].name)
			miog.createFrameBorder(currentClassFrame, 1, rPerc, gPerc, bPerc, 1)

		else
			miog.createFrameBorder(currentClassFrame, 1, 0, 0, 0, 1)

		end

		counter = counter + 1

		miog.applicationViewer.ClassPanel:MarkDirty()

	end

	updateSpecFrames()

	checkCoroutineStatus()

end

local function inspectCoroutineEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
		
        local isInitialLogin, isReloadingUi = ...

        if(isInitialLogin or isReloadingUi) then
            updateRosterInfoData()

        else
            checkCoroutineStatus()

        end
    elseif(event == "GROUP_JOINED" or event == "GROUP_LEFT") then
        miog.checkIfCanInvite()

        updateRosterInfoData()

    elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local guid = UnitGUID(...)

		if(guid) then
			if(groupSystem.groupMember[guid] and not inspectQueue[guid]) then
				groupSystem.inspectedGUIDs[guid] = nil
				inspectQueue[guid] = ...
				checkCoroutineStatus()

			end
		end

	elseif(event == "INSPECT_READY") then
		if(groupSystem.groupMember[...] or inspectQueue[...]) then
			inspectQueue[...] = nil
			
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