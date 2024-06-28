local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.checkSystem = {}
miog.checkSystem.groupMember = {}
miog.checkSystem.keystoneData = {}

local stopUpdates = false

miog.OnKeystoneUpdate = function(unitName, keystoneInfo, allKeystoneData)
	unitName = miog.createFullNameFrom("unitName", unitName)

	if(miog.groupSystem.groupMember[unitName] or unitName == miog.createFullNameFrom("unitID", "player")) then
		miog.checkSystem.keystoneData[unitName] = keystoneInfo

	end

	if(miog.guildFrames[unitName]) then
		MIOG_SavedSettings.guildKeystoneInfo[unitName] = keystoneInfo
		miog.guildSystem.keystoneData[unitName] = keystoneInfo

		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)

		local currentFrame = miog.guildFrames[unitName]
		currentFrame.BasicInformation.Keylevel:SetText("+" .. keystoneInfo.level)
        currentFrame.BasicInformation.Keystone:SetTexture(texture)
	end

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
			if(slotIdWithoutEnchant ~= 10) then
				miog.checkSystem.groupMember[name].missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
				
			end
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

	miog.PartyCheck:SetScript("OnShow", function()
		if(IsInRaid()) then
			miog.openRaidLib.RequestKeystoneDataFromRaid()
			miog.openRaidLib.GetAllUnitsGear()
			
		elseif(IsInGroup()) then
			miog.openRaidLib.RequestKeystoneDataFromParty()
			miog.openRaidLib.GetAllUnitsGear()

		else
			miog.openRaidLib.RequestKeystoneDataFromParty()

		end
	end)

	miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearDurabilityUpdate", "OnGearDurabilityUpdate")
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
end