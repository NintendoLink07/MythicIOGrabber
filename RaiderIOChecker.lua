local addonName, miog = ...
local wticc = WrapTextInColorCode

local function setRaiderIOInformation(profile)
    if(profile) then
        local mythicKeystoneProfile = profile.mythicKeystoneProfile

        miog.RaiderIOChecker.Name:SetText(profile.name)
        miog.RaiderIOChecker.Realm:SetText(profile.realm)
        miog.RaiderIOChecker.Realm:SetText(profile.mythicKeystoneProfile.currentScore)

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
    end
end

miog.loadRaiderIOChecker = function()
    miog.RaiderIOChecker = CreateFrame("Frame", "MythicIOGrabber_RaiderIOChecker", miog.Plugin.InsertFrame, "MIOG_RaiderIOChecker")
    miog.TitleBar.RaiderIOChecker:Show()

    miog.RaiderIOChecker.NameSearchBox:SetScript("OnKeyDown", function(self, key)
        if(key == "ENTER") then
            local profile = RaiderIO.GetProfile(self:GetText(), miog.RaiderIOChecker.RealmSearchBox:GetText() or "")

            setRaiderIOInformation(profile)
        end
    end)

    miog.RaiderIOChecker.RealmSearchBox:SetScript("OnKeyDown", function(self, key)
        if(key == "ENTER") then
            local profile = RaiderIO.GetProfile(miog.RaiderIOChecker.NameSearchBox:GetText() or "", self:GetText())

            setRaiderIOInformation(profile)
        end
    end)

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
end