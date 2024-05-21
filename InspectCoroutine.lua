local addonName, miog = ...
local wticc = WrapTextInColorCode

local groupSystem = {}
groupSystem.groupMember = {}

local lastNotifyTime = 0

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_InspectCoroutineEventReceiver")

MIOG_InspectedGUIDs = {}
MIOG_SavedSpecIDs = {}

local timers = {}

local currentInspection = nil
local currentInspectionName = nil

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
	
	if(currentInspection and GetTimePreciseSec() - lastNotifyTime > 7) then
		ClearInspectPlayer(true)
		updateRosterInfoData()

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

	for groupIndex = 1, numOfMembers, 1 do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

		if(name) then
			local unitID = ((IsInRaid() or (IsInGroup() and (numOfMembers ~= 1 and groupIndex ~= numOfMembers))) and miog.F.LFG_STATE..groupIndex) or "player"
			--local unitID = ((miog.F.LFG_STATE == "raid" or (miog.F.LFG_STATE == "party" and groupIndex ~= miog.MAX_GROUP_SIZES["party"])) and miog.F.LFG_STATE..groupIndex) or "player"
			local guid = UnitGUID(unitID)

			if(guid) then
				groupSystem.groupMember[guid] = {
					unitID = unitID,
					name = name,
					shortName = UnitName(unitID),
					classID = fileName and miog.CLASSFILE_TO_ID[fileName],
					role = combatRole,
				}

				if(guid ~= UnitGUID("player") and (not MIOG_InspectedGUIDs[guid] or GetTimePreciseSec() - MIOG_InspectedGUIDs[guid] > 300)) then

					if(currentInspection == nil and UnitIsConnected(unitID) and CanInspect(unitID)) then

						currentInspectionName = name
						currentInspection = guid

						if(timers[guid]) then
							timers[guid]:Cancel()
						end

						local timer = C_Timer.NewTimer(10,
						function()
							if(currentInspection and GetTimePreciseSec() - lastNotifyTime > 7) then
								currentInspection = nil
								ClearInspectPlayer(true)
								updateRosterInfoData()
							end
						end)

						timers[guid] = timer

						C_Timer.After(numOfMembers <= 20 and miog.C.BLIZZARD_INSPECT_THROTTLE or 2,
						function()
							if(groupSystem.groupMember[guid]) then
								lastNotifyTime = GetTimePreciseSec()
			

								NotifyInspect(unitID) -- 2nd argument for hook to check if own or other addons' notify
			
								local color = C_ClassColor.GetClassColor(fileName)
								name = color and WrapTextInColorCode(groupSystem.groupMember[guid].shortName, color:GenerateHexColor()) or groupSystem.groupMember[guid].shortName
								
								miog.ClassPanel.LoadingSpinner:Show()
								miog.ClassPanel.StatusString:SetText(name .. "\n(" .. #indexedGroup .. "/" .. inspectableMembers .. "/" .. numOfMembers .. ")")
							end
						end)
					else
						--GUID gone
						MIOG_InspectedGUIDs[guid] = nil
						MIOG_SavedSpecIDs[guid] = nil
			
					end
				end

				if(groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName]]) then
					groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName]] = groupSystem.classCount[miog.CLASSFILE_TO_ID[fileName]] + 1

				end
	
				if(guid == currentInspection) then
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

	local percentageInspected = #indexedGroup / inspectableMembers

	if(not currentInspection) then
		miog.ClassPanel.LoadingSpinner:Hide()
		miog.ClassPanel.StatusString:SetText("(" .. #indexedGroup .. "/" .. inspectableMembers .. "/" .. numOfMembers .. ")")
		

	end

	if(percentageInspected >= 1) then
		miog.ClassPanel.InspectStatus:Hide()

	else
		miog.ClassPanel.InspectStatus:Show()
	
	end

	miog.ClassPanel.InspectStatus:SetMinMaxValues(0, inspectableMembers)
	miog.ClassPanel.InspectStatus:SetValue(#indexedGroup)
	miog.ClassPanel.InspectStatus:SetStatusBarColor(1 - percentageInspected, percentageInspected, 0, 1)

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

local function resetInspectCoroutine()
	MIOG_InspectedGUIDs = {}
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
				MIOG_InspectedGUIDs = {}
				MIOG_SavedSpecIDs = {}
			end

            updateRosterInfoData()

        end

    elseif(event == "PLAYER_SPECIALIZATION_CHANGED") then
		local guid = UnitGUID(...)

		if(guid) then
			if(groupSystem.groupMember[guid]) then
				MIOG_InspectedGUIDs[guid] = nil
				MIOG_SavedSpecIDs[guid] = nil

			end
		end

	elseif(event == "INSPECT_READY") then
		local name = select(6, GetPlayerInfoByGUID(...))

		if(currentInspection == ...) then
			ClearInspectPlayer(true)
		end

		if(groupSystem.groupMember[...]) then
			MIOG_InspectedGUIDs[...] = GetTimePreciseSec()
			
			if(timers[...]) then
				timers[...]:Cancel()
			end

			updateRosterInfoData()

		else
			local unitID = UnitTokenFromGUID(...)
			miog.F.LFG_STATE = miog.checkLFGState()

			---@diagnostic disable-next-line: param-type-mismatch
			if(miog.F.LFG_STATE == "raid" and UnitInRaid(unitID) or miog.F.LFG_STATE == "party" and UnitInParty(unitID)) then
				createGroupMemberEntry(..., unitID)

			end

		end
	elseif(event == "GROUP_JOINED") then
		updateRosterInfoData()

	elseif(event == "GROUP_LEFT") then
		updateRosterInfoData()
	
	elseif(event == "GROUP_ROSTER_UPDATE") then
		updateRosterInfoData()

    end
end

hooksecurefunc("NotifyInspect", function(unitID)
	lastNotifyTime = GetTimePreciseSec()
end)

hooksecurefunc("ClearInspectPlayer", function(own)
	if(own) then
		currentInspection = nil
		currentInspectionName = nil
		--miog.pveFrame2.ClassPanelStatusString:SetText("Waiting for next inspect...")
	end
end)

miog.createInspectCoroutine = function()
	eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventReceiver:RegisterEvent("GROUP_JOINED")
	eventReceiver:RegisterEvent("GROUP_LEFT")
	eventReceiver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	eventReceiver:RegisterEvent("INSPECT_READY")
	eventReceiver:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventReceiver:SetScript("OnEvent", inspectCoroutineEvents)
end

