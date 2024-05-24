local addonName, miog = ...

miog.getAdjustedItemLevel = function(season, jumps)
    local jumpsCompleted = 0
    local newItemLevel = miog.GEARING_CHART[season].baseItemLevel

    while(true) do
        for i = 1, 4, 1 do
            if(jumpsCompleted == jumps) then
                return newItemLevel

            else
                newItemLevel = newItemLevel + miog.ITEM_LEVEL_JUMPS[i]
                jumpsCompleted = jumpsCompleted + 1
            
            end

        end

        if(jumpsCompleted == jumps) then
            return newItemLevel

        elseif(jumpsCompleted > jumps) then
            return 0

        end
    end

    return 0
end

miog.getVaultProgress = function(lootLevel)
    local returnString = ""

    for k, v in ipairs(miog.VAULT_PROGRESS) do
        local name = k == 1 and "D" or k == 2 and "P" or k == 3 and "R"

        for i = 1, 3, 1 do
            if(v[i] and v[i] == lootLevel) then
                returnString = returnString .. name .. i .. " "
            end
        end
    end

    return returnString
end

miog.createTrackJumps = function(season)
    for i = 1, 7, 1 do
        local itemLevel = miog.getAdjustedItemLevel(season, (i - 1) * 4)
        miog.GEARING_CHART[season][i == 1 and "explorer" or i == 2 and "adventurer" or i == 3 and "veteran" or i == 4 and "champion" or i == 5 and "hero" or i == 6 and "myth"] = itemLevel
        miog.GEARING_CHART[season].tracks[i] = itemLevel
    end
end

miog.insertGearingData = function()
    local seasonID = C_MythicPlus.GetCurrentSeason()

    if(seasonID) then
        local gearingData = miog.GEARING_CHART[seasonID]
        miog.createTrackJumps(seasonID)
        local rowChildren = miog.pveFrame2.TabFramesPanel.Gearing.RowLayout:GetLayoutChildren()

        local r, g, b = 1, 1, 1

        for i = 1, #rowChildren, 1 do
            local id = i > 15 and 16 or i > 11 and 15 or i > 7 and 14 or i > 3 and 17
            local itemLevel = i == 2 and miog.getAdjustedItemLevel(seasonID, gearingData.normalDungeon) or i == 3 and miog.getAdjustedItemLevel(seasonID, gearingData.heroicDungeon) or i == 1 and "ILvl" or miog.getAdjustedItemLevel(seasonID, gearingData.heroicDungeon + (i - 3))

            if(i > 1) then
                for k, v in ipairs(miog.GEARING_CHART[seasonID].tracks) do
                    if(v <= itemLevel) then
                        r, g, b =  miog.ITEM_QUALITY_COLORS[k - 1].color:GetRGB()
                    end
                end
            end

            rowChildren[i].ItemLevel:SetText(itemLevel)
            rowChildren[i].ItemLevel:SetTextColor(r,g,b,1)

            rowChildren[i].Raid:SetText(i > 7 and miog.DIFFICULTY_ID_INFO[id].name or i > 3 and miog.DIFFICULTY_ID_INFO[id].shortName or i == 1 and "Raid" or "")
            rowChildren[i].Raid:SetTextColor(r,g,b,1)

            rowChildren[i].Dungeon:SetText(i == 13 and "+9/+10" or i == 12 and "+7/+8" or i == 11 and "+5/+6" or i == 10 and "+3/+4" or i == 9 and "+2" or i == 8 and "M0" or i == 3 and "Heroic/TW" or i == 2 and "Normal" or i == 1 and "Dng Loot" or "")
            rowChildren[i].Dungeon:SetTextColor(r,g,b,1)

            rowChildren[i].DungeonVault:SetText(i == 17 and "+9/+10" or i == 16 and "+7/+8" or i == 15 and "+5/+6" or i == 14 and "+3/+4" or i == 13 and "+2" or i == 12 and "M0" or i == 7 and "Heroic/TW" or i == 1 and "Dng Vault" or "")
            rowChildren[i].DungeonVault:SetTextColor(r,g,b,1)

            rowChildren[i].Other:SetText(i == 18 and "Craft Aspect Max" or i == 15 and "Craft Wyrm Max" or i == 1 and "Other" or "")
            rowChildren[i].Other:SetTextColor(r,g,b,1)

            rowChildren[i].Progress:SetText(i == 1 and "Progress" or miog.getVaultProgress(tonumber(rowChildren[i].ItemLevel:GetText())))
            rowChildren[i].Progress:SetTextColor(r,g,b,1)

            --HERERERERowsngfdioufjghndüpfgokmd+füög.
        end
    end
end

miog.loadGearingChart = function()
    for i = 1, 21, 1 do
        local singleGrid = CreateFrame("Frame", nil, miog.pveFrame2.TabFramesPanel.Gearing.RowLayout, "MIOG_GearingChartLine")
        singleGrid.fixedWidth = miog.pveFrame2.TabFramesPanel.Gearing.RowLayout:GetWidth()
        singleGrid.layoutIndex = i
        singleGrid.bottomPadding = i == 1 and 5 or 0

        singleGrid.ItemLevel.layoutIndex = 1
        singleGrid.Raid.layoutIndex = 2

        singleGrid.Dungeon.layoutIndex = 3
        singleGrid.DungeonVault.layoutIndex = 4

        singleGrid.Other.layoutIndex = 5

        singleGrid.Progress.layoutIndex = 6
    end
end