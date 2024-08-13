local addonName, miog = ...
local wticc = WrapTextInColorCode

local setupDone = false

local function setUpRaiderIOChecker()
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(2, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE))
    local dungeons = {}

    for k, v in ipairs(seasonGroups) do
        if(miog.GROUP_ACTIVITY[v]) then
            table.insert(dungeons, v)

        end
    end

    table.sort(dungeons, function(k1, k2)
        return miog.GROUP_ACTIVITY[k1].shortName < miog.GROUP_ACTIVITY[k2].shortName
    end)

    for k, v in ipairs(dungeons) do
        local activityID = miog.GROUP_ACTIVITY[v].activityID
        
        local dungeonRowFrame = miog.RaiderIOChecker.MythicPlusPanel["DungeonRow" .. k]
        dungeonRowFrame.Icon:SetTexture(miog.ACTIVITY_INFO[activityID].icon)
        dungeonRowFrame.Icon:SetScript("OnMouseDown", function()
            local instanceID = C_EncounterJournal.GetInstanceForGameMap(miog.ACTIVITY_INFO[activityID].mapID)

            --difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
            EncounterJournal_OpenJournal(EJ_GetDifficulty(), instanceID, nil, nil, nil, nil)

        end)

        dungeonRowFrame.Name:SetText(miog.GROUP_ACTIVITY[v].shortName .. ":")

    end

    local raidGroups = C_LFGList.GetAvailableActivityGroups(3, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.PvE))
    local raids = {}

    for k, v in ipairs(raidGroups) do
        if(miog.GROUP_ACTIVITY[v]) then
            table.insert(raids, v)

        end
    end

    table.sort(raids, function(k1, k2)
        return miog.GROUP_ACTIVITY[k1].shortName < miog.GROUP_ACTIVITY[k2].shortName
    end)

    for k, v in ipairs(raids) do
        local activityID = miog.GROUP_ACTIVITY[v].activityID

        local currentTier = k == 1 and miog.RaiderIOChecker.RaidPanel.HighestTier or k == 2 and miog.RaiderIOChecker.RaidPanel.MiddleTier or k == 3 and miog.RaiderIOChecker.RaidPanel.LowestTier
        
        if(currentTier) then
            --local dungeonRowFrame = miog.RaiderIOChecker.MythicPlusPanel["DungeonRow" .. k]
            currentTier.Icon:SetTexture(miog.ACTIVITY_INFO[activityID].icon)
            currentTier.Icon:SetScript("OnMouseDown", function()
                local instanceID = C_EncounterJournal.GetInstanceForGameMap(miog.ACTIVITY_INFO[activityID].mapID)

                --difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
                EncounterJournal_OpenJournal(EJ_GetDifficulty(), instanceID, nil, nil, nil, nil)

            end)

            currentTier.Name:SetText(miog.GROUP_ACTIVITY[v].shortName .. ":")
            currentTier.Progress:SetText("")
        end
    end

	setupDone = true
end

local function resetAllFrames()
	for k, v in pairs(miog.RaiderIOChecker.MythicPlusPanel) do
		if(type(v) == "table") then
			--v.Name:SetText("")
			v.Primary:SetText("")
			v.Secondary:SetText("")
			--v.Icon:SetTexture(nil)
		end
	end

	for k, v in pairs(miog.RaiderIOChecker.RaidPanel) do
		if(type(v) == "table") then
			--v.Name:SetText("")
			v.Progress:SetText("")
			--v.Icon:SetTexture(nil)
			
			for x, y in pairs(v.BossFrames.UpperRow) do
				if(type(y) == "table") then
					y.Icon:SetTexture(nil)
					y.Border:SetTexture(nil)
					y.Index:SetText("")

				end
			end
			
			for x, y in pairs(v.BossFrames.LowerRow) do
				if(type(y) == "table") then
					y.Icon:SetTexture(nil)
					y.Border:SetTexture(nil)
					y.Index:SetText("")

				end
			end
		end
	end

	for k, v in pairs(miog.RaiderIOChecker.MainRaidPanel) do
		if(type(v) == "table") then
			--v.Name:SetText("")
			v.Progress:SetText("")
			--v.Icon:SetTexture(nil)
			
			for x, y in pairs(v.BossFrames.UpperRow) do
				if(type(y) == "table") then
					y.Icon:SetTexture(nil)
					y.Border:SetTexture(nil)
					y.Index:SetText("")

				end
			end
			
			for x, y in pairs(v.BossFrames.LowerRow) do
				if(type(y) == "table") then
					y.Icon:SetTexture(nil)
					y.Border:SetTexture(nil)
					y.Index:SetText("")

				end
			end
		end
	end
end

local function setRaiderIOInformation(profile)
	if(not setupDone) then
		setUpRaiderIOChecker()
	end

    if(profile) then
        resetAllFrames()

        local mythicKeystoneProfile = profile.mythicKeystoneProfile
        local raidProfile = profile.raidProfile

        miog.RaiderIOChecker.Rating:SetText(profile.mythicKeystoneProfile and profile.mythicKeystoneProfile.currentScore or 0)

        if(mythicKeystoneProfile and mythicKeystoneProfile.currentScore > 0 and mythicKeystoneProfile.sortedDungeons) then
			table.sort(mythicKeystoneProfile.sortedDungeons, function(k1, k2)
				return k1.dungeon.shortName < k2.dungeon.shortName

			end)

			local primaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeons or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeons
			local primaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.tyrannicalDungeonUpgrades or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.fortifiedDungeonUpgrades
			local secondaryDungeonLevel = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeons or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeons
			local secondaryDungeonChests = miog.F.WEEKLY_AFFIX == 9 and mythicKeystoneProfile.fortifiedDungeonUpgrades or miog.F.WEEKLY_AFFIX == 10 and mythicKeystoneProfile.tyrannicalDungeonUpgrades

			if(primaryDungeonLevel and primaryDungeonChests and secondaryDungeonLevel and secondaryDungeonChests) then
                for i, dungeonEntry in ipairs(mythicKeystoneProfile.sortedDungeons) do
                    local rowIndex = dungeonEntry.dungeon.index

                    local dungeonRowFrame = miog.RaiderIOChecker.MythicPlusPanel["DungeonRow" .. i]

                    dungeonRowFrame.Primary:SetText(wticc(primaryDungeonLevel[rowIndex] .. " " .. strrep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or primaryDungeonChests[rowIndex]),
                    primaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or primaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))

                    dungeonRowFrame.Secondary:SetText(wticc(secondaryDungeonLevel[rowIndex] .. " " .. strrep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or secondaryDungeonChests[rowIndex]),
                    secondaryDungeonChests[rowIndex] > 0 and miog.C.GREEN_COLOR or secondaryDungeonChests[rowIndex] == 0 and miog.CLRSCC["red"] or "0"))
                end
            end
        end

        if(raidProfile) then
			miog.fillRaidPanelWithData(profile, miog.RaiderIOChecker, miog.RaiderIOChecker.RaidPanel, miog.RaiderIOChecker.MainRaidPanel)

        else
            
        
        end
    end
end

miog.loadRaiderIOChecker = function()
	miog.RaiderIOChecker = CreateFrame("Frame", "MythicIOGrabber_RaiderIOChecker", miog.Plugin.InsertFrame, "MIOG_RaiderIOChecker")

    miog.RaiderIOChecker.NameSearchBox:SetScript("OnKeyDown", function(self, key)
        if(key == "ENTER") then
            local profile = RaiderIO.GetProfile(self:GetText(), miog.RaiderIOChecker.RealmSearchBox:GetText() or "")

            setRaiderIOInformation(profile)

        elseif(key == "TAB") then
            miog.RaiderIOChecker.RealmSearchBox:SetFocus()
        end
    end)

    miog.RaiderIOChecker.RealmSearchBox:SetScript("OnKeyDown", function(self, key)
        if(key == "ENTER") then
            local profile = RaiderIO.GetProfile(miog.RaiderIOChecker.NameSearchBox:GetText() or "", self:GetText())

            setRaiderIOInformation(profile)

        elseif(key == "TAB") then
            miog.RaiderIOChecker.NameSearchBox:SetFocus()

        end
    end)

	miog.RaiderIOChecker.RIOVersion:SetText(C_AddOns.GetAddOnMetadata("RaiderIO", "Version"))
end