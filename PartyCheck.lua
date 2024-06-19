local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.checkSystem = {}
miog.checkSystem.groupMember = {}
miog.checkSystem.keystoneData = {}

miog.OnKeystoneUpdate = function(unitName, keystoneInfo, allKeystoneData)
	unitName = miog.createFullNameFrom("unitName", unitName)
	
	miog.checkSystem.keystoneData[unitName] = keystoneInfo

	miog.updateRosterInfoData()
end

miog.OnUnitUpdate = function(singleUnitId, singleUnitInfo, allUnitsInfo)
	if(singleUnitInfo) then
		local specId = singleUnitInfo.specId
		local specName = singleUnitInfo.specName
		local role = singleUnitInfo.role
		local renown = singleUnitInfo.renown
		local covenantId = singleUnitInfo.covenantId
		local talents = singleUnitInfo.talents
		local pvpTalents = singleUnitInfo.pvpTalents
		local conduits = singleUnitInfo.conduits
		local class = singleUnitInfo.class
		local classId = singleUnitInfo.classId
		local className = singleUnitInfo.className
		local unitName = singleUnitInfo.name
		local unitNameFull = singleUnitInfo.nameFull

		miog.checkSystem.groupMember[unitNameFull] = miog.checkSystem.groupMember[unitNameFull] or {}

		for k, v in pairs(singleUnitInfo) do
			miog.checkSystem.groupMember[unitNameFull][k] = v

		end

		MIOG_SavedSpecIDs[unitNameFull] = specId ~= 0 and specId
		MIOG_InspectedNames[unitNameFull] = MIOG_SavedSpecIDs[unitNameFull] and GetTimePreciseSec() or nil
	end

	miog.updateRosterInfoData()
end

--[[function miog.OnUnitUpdate(singleUnitId, singleUnitInfo, allUnitsInfo)
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

    local counter = 1

	if(allUnitsInfo) then
		for unitNameKey, unitInfo in pairs(allUnitsInfo) do
			local specId = unitInfo.specId
			local specName = unitInfo.specName
			local role = unitInfo.role
			local renown = unitInfo.renown
			local covenantId = unitInfo.covenantId
			local talents = unitInfo.talents
			local pvpTalents = unitInfo.pvpTalents
			local conduits = unitInfo.conduits
			local class = unitInfo.class
			local classId = unitInfo.classId
			local className = unitInfo.className
			local unitName = unitInfo.name
			local unitNameFull = unitInfo.nameFull


			if(not groupSystem.groupMember[unitNameFull]) then
				local memberFrame = partyPool:Acquire()
				memberFrame.Name:SetText(counter .. " " .. unitName)
				memberFrame.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. role .. "Icon.png")
				memberFrame.Spec:SetTexture(miog.SPECIALIZATIONS[specId].squaredIcon)
				memberFrame.unitInfo = unitInfo
				memberFrame:Show()

				groupSystem.groupMember[unitNameFull] = memberFrame

				groupSystem.classCount[classId] = groupSystem.classCount[classId] + 1
				groupSystem.specCount[specId] = groupSystem.specCount[specId] and groupSystem.specCount[specId] + 1 or 1
				groupSystem.roleCount[role] = groupSystem.roleCount[role] + 1

			else
				local currentFrame = groupSystem.groupMember[unitNameFull]
				local oldUnitInfo = currentFrame.unitInfo

				groupSystem.specCount[oldUnitInfo.specId] = groupSystem.specCount[oldUnitInfo.specId] - 1
				groupSystem.roleCount[oldUnitInfo.role] = groupSystem.roleCount[oldUnitInfo.role] - 1

				groupSystem.specCount[specId] = groupSystem.specCount[specId] + 1
				groupSystem.roleCount[role] = groupSystem.roleCount[role] + 1

				currentFrame.layoutIndex = role == "TANK" and 1 or role == "HEALER" and 50 or 100

			end

			counter = counter + 1
		end
	end

    miog.PartyCheck.ScrollFrame.Container:MarkDirty()

	miog.ClassPanel.StatusString:SetText("(" .. counter .. "/" .. GetNumGroupMembers() .. ")")

	local percentageInspected = counter / GetNumGroupMembers()

	miog.ClassPanel.InspectStatus:SetShown(percentageInspected < 1)

	miog.ClassPanel.InspectStatus:SetMinMaxValues(0, GetNumGroupMembers())
	miog.ClassPanel.InspectStatus:SetValue(counter)
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
	
	if(GetNumGroupMembers() < 5) then
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
	end)] ]

	miog.ApplicationViewer.TitleBar.GroupComposition.Roles:SetText(groupSystem.roleCount["TANK"] .. "/" .. groupSystem.roleCount["HEALER"] .. "/" .. groupSystem.roleCount["DAMAGER"])
end]]

function miog.OnUnitInfoWipe()
	--all unit info got wiped
    --partyPool:ReleaseAll()
    --miog.OnUnitUpdate()
end

function miog.OnGearUpdate(unitId, unitGear, allUnitsGear)
	local name = miog.createFullNameFrom("unitID", unitId)

	if(name) then
		--hasWeaponEnchant is 1 have enchant or 0 is don't
		local hasWeaponEnchantNumber = unitGear.weaponEnchant
		local noEnchantTable = unitGear.noEnchants
		local noGemsTable = unitGear.noGems

		miog.checkSystem.groupMember[name] = miog.checkSystem.groupMember[name] or {}
		miog.checkSystem.groupMember[name].ilvl = unitGear.ilevel
		miog.checkSystem.groupMember[name].durability = unitGear.durability
		miog.checkSystem.groupMember[name].missingEnchants = {}
		miog.checkSystem.groupMember[name].missingGems = {}

		for index, slotIdWithoutEnchant in ipairs (noEnchantTable) do
			miog.checkSystem.groupMember[name].missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
		end

		for index, slotIdWithEmptyGemSocket in ipairs (noGemsTable) do
			miog.checkSystem.groupMember[name].missingGems[index] = miog.SLOT_ID_INFO[slotIdWithEmptyGemSocket].localizedName
		end

		miog.updateRosterInfoData()
	end
end

function miog.OnGearDurabilityUpdate(unitId, durability, unitGear, allUnitsGear)
	local name = miog.createFullNameFrom("unitID", unitId)

	if(name) then
		miog.checkSystem.groupMember[name] = miog.checkSystem.groupMember[name] or {}
		miog.checkSystem.groupMember[name].durability = durability

		miog.updateRosterInfoData()
	end
end

--registering the callback:

miog.loadPartyCheck = function()
    miog.PartyCheck = miog.pveFrame2.TabFramesPanel.PartyCheck
	miog.PartyCheck.sortByCategoryButtons = {}

	for k, v in pairs(miog.PartyCheck) do
		if(type(v) == "table" and v.Button) then
			v.Name:SetText(v:GetParentKey())
			miog.PartyCheck.sortByCategoryButtons[v:GetDebugName()] = v.Button
			v.Button.panel = "partyCheck"
			v.Button.category = v:GetDebugName()
			v.Button:SetScript("PostClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				miog.updateRosterInfoData()
			end)
		end

	end

	miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearDurabilityUpdate", "OnGearDurabilityUpdate")
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
end