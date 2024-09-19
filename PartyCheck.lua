local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.checkSystem = {}
miog.checkSystem.groupMember = {}
miog.checkSystem.keystoneData = {}

local stopUpdates = false

miog.OnKeystoneUpdate = function(unitName, keystoneInfo, allKeystoneData)
	if(unitName) then
		unitName = miog.createFullNameFrom("unitName", unitName)

		if(miog.inspection.characterExists(unitName) or unitName == miog.createFullNameFrom("unitID", "player") or unitName == UnitName("player")) then
			miog.checkSystem.keystoneData[unitName] = keystoneInfo

			--miog.updateRosterInfoData()
			--miog.inspection.updateGroupData()

		end

		--[[if(miog.guildSystem and miog.guildSystem.baseFrames[unitName]) then
			MIOG_NewSettings.guildKeystoneInfo[unitName] = keystoneInfo
			miog.guildSystem.keystoneData[unitName] = keystoneInfo

			local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)

			local currentFrame = miog.guildSystem.baseFrames[unitName]
			currentFrame.BasicInformation.Keylevel:SetText("+" .. keystoneInfo.level)
			currentFrame.BasicInformation.Keystone:SetTexture(texture)
		end]]
	end

	--for name, singleKeystoneInfo in pairs(allKeystoneData) do
	--	miog.insertInfoIntoDropdown(name, singleKeystoneInfo)
	--end
end

miog.OnUnitUpdate = function(singleUnitId, singleUnitInfo, allUnitsInfo)
	if(singleUnitInfo) then
		local specId = singleUnitInfo.specId
		--[[local specName = singleUnitInfo.specName
		local role = singleUnitInfo.role
		local renown = singleUnitInfo.renown
		local covenantId = singleUnitInfo.covenantId
		local talents = singleUnitInfo.talents
		local pvpTalents = singleUnitInfo.pvpTalents
		local conduits = singleUnitInfo.conduitsw
		local class = singleUnitInfo.class
		local classId = singleUnitInfo.classId
		local className = singleUnitInfo.className
		local unitName = singleUnitInfo.name]]

		singleUnitInfo.unitId = singleUnitId

		miog.checkSystem.groupMember[singleUnitInfo.nameFull] = miog.checkSystem.groupMember[singleUnitInfo.nameFull] or {}

		for k, v in pairs(singleUnitInfo) do
			miog.checkSystem.groupMember[singleUnitInfo.nameFull][k] = v

		end

		miog.playerSpecs[singleUnitInfo.nameFull] = specId ~= 0 and specId
		--MIOG_InspectedNames[singleUnitInfo.nameFull] = MIOG_SavedSpecIDs[singleUnitInfo.nameFull] and GetTimePreciseSec() or nil
	end
	

	--miog.updateRosterInfoData()
	--miog.inspection.updateGroupData()
end

function miog.OnUnitInfoWipe()
	--all unit info got wiped
    --partyPool:ReleaseAll()
    --miog.OnUnitUpdate()
end

function miog.OnGearUpdate(unitId, unitGear, allUnitsGear)
	if(unitId) then
		local name = miog.createFullNameFrom("unitID", unitId)

		if(name) then
			--local hasWeaponEnchantNumber = unitGear.weaponEnchant

			miog.checkSystem.groupMember[name] = miog.checkSystem.groupMember[name] or {}
			miog.checkSystem.groupMember[name].ilvl = unitGear.ilevel
			miog.checkSystem.groupMember[name].durability = unitGear.durability
			miog.checkSystem.groupMember[name].missingEnchants = {}
			--miog.checkSystem.groupMember[name].hasWeaponEnchant = hasWeaponEnchantNumber == 1 and true or false
			miog.checkSystem.groupMember[name].missingGems = {}

			for index, slotIdWithoutEnchant in ipairs (unitGear.noEnchants) do
				if(slotIdWithoutEnchant ~= 10) then
					miog.checkSystem.groupMember[name].missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
					
				end
			end

			for index, slotIdWithEmptyGemSocket in ipairs (unitGear.noGems) do
				miog.checkSystem.groupMember[name].missingGems[index] = miog.SLOT_ID_INFO[slotIdWithEmptyGemSocket].localizedName
			end

			--miog.inspection.updateGroupData()
		end
	end
end

function miog.OnGearDurabilityUpdate(unitId, durability, unitGear, allUnitsGear)
	if(unitId) then
		local name = miog.createFullNameFrom("unitID", unitId)

		if(name) then
			miog.checkSystem.groupMember[name] = miog.checkSystem.groupMember[name] or {}
			miog.checkSystem.groupMember[name].durability = durability

			--miog.inspection.updateGroupData()
		end
	end
end

miog.loadPartyCheck = function()
    miog.PartyCheck = miog.pveFrame2.TabFramesPanel.PartyCheck
	miog.PartyCheck:SetScrollView(miog.PartyCheck.ScrollView)

	miog.PartyCheck:SetScript("OnShow", function()
		if(IsInRaid()) then
			miog.openRaidLib.RequestKeystoneDataFromRaid()
			--miog.openRaidLib.GetAllUnitsGear()
			
		elseif(IsInGroup()) then
			miog.openRaidLib.RequestKeystoneDataFromParty()
			--miog.openRaidLib.GetAllUnitsGear()

		end

		local unitId = "player"

        local itemLevel = miog.openRaidLib.GearManager.GetPlayerItemLevel()
        local gearDurability, lowestItemDurability = miog.openRaidLib.GearManager.GetPlayerGearDurability()
    	local weaponEnchant, mainHandEnchantId, offHandEnchantId = miog.openRaidLib.GearManager.GetPlayerWeaponEnchant()
        local slotsWithoutGems, slotsWithoutEnchant = miog.openRaidLib.GearManager.GetPlayerGemsAndEnchantInfo()
		
		if(unitId) then
			local name = miog.createFullNameFrom("unitID", unitId)

			if(name) then
				miog.checkSystem.groupMember[name] = miog.checkSystem.groupMember[name] or {}
				miog.checkSystem.groupMember[name].ilvl = itemLevel
				miog.checkSystem.groupMember[name].durability = gearDurability
				miog.checkSystem.groupMember[name].missingEnchants = {}
				--miog.checkSystem.groupMember[name].hasWeaponEnchant = weaponEnchant == 1 and true or false
				miog.checkSystem.groupMember[name].missingGems = {}

				for index, slotIdWithoutEnchant in ipairs(slotsWithoutEnchant) do
					if(slotIdWithoutEnchant ~= 10) then
						miog.checkSystem.groupMember[name].missingEnchants[index] = miog.SLOT_ID_INFO[slotIdWithoutEnchant].localizedName
						
					end
				end
	
				for index, slotIdWithEmptyGemSocket in ipairs (slotsWithoutGems) do
					miog.checkSystem.groupMember[name].missingGems[index] = miog.SLOT_ID_INFO[slotIdWithEmptyGemSocket].localizedName
				end

				miog.inspection.updateGroupData()
			end
		end
		
		miog.PartyCheck:Sort()
	end)

	miog.PartyCheck:OnLoad()
	miog.PartyCheck:SetSettingsTable(MIOG_NewSettings.sortMethods.PartyCheck)
	miog.PartyCheck:AddMultipleSortingParameters({
		{name = "group"},
		{name = "name", padding = 20},
		{name = "role", padding = 80},
		{name = "spec", padding = 30},
		{name = "ilvl", padding = 30},
		{name = "durability", padding = 30},
		{name = "keylevel", padding = 30},
		{name = "score", padding = 30},
		{name = "progressWeight", padding = 35},
	})

	miog.openRaidLib.RegisterCallback(miog, "UnitInfoUpdate", "OnUnitUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearUpdate", "OnGearUpdate")
	miog.openRaidLib.RegisterCallback(miog, "GearDurabilityUpdate", "OnGearDurabilityUpdate")
	miog.openRaidLib.RegisterCallback(miog, "KeystoneUpdate", "OnKeystoneUpdate")
end