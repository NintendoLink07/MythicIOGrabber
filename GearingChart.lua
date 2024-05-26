local addonName, miog = ...

local currentChildren = {}

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

miog.createTrackString = function(seasonID, itemLevel)
    local trackString = ""

	for x, y in pairs(miog.GEARING_CHART) do
        if(x == seasonID) then
            --[[for k, v in ipairs(y.trackInfo) do
                for i = 1, v.length, 1 do
                    if(v.data[i] == itemLevel) then
                        trackString = trackString .. WrapTextInColorCode(i .. "/" .. v.length, miog.ITEM_QUALITY_COLORS[k - 1].color:GenerateHexColor()) .. " "
                    end
                end
            end]]

            --REVERSED, SO NEW TRACKS ARE INFRONT
            for k = #y.trackInfo, 1, -1 do
                if(y.awakenedInfo and k == #y.trackInfo) then

                else
                    local currentEntry = y.trackInfo[k]
                    
                    for i = 1, currentEntry.length, 1 do
                        if(currentEntry.data[i] == itemLevel) then
                            trackString = trackString .. WrapTextInColorCode(i .. "/" .. currentEntry.length, miog.ITEM_QUALITY_COLORS[k - 1].color:GenerateHexColor()) .. "  "
                        end
                    end
                end
            end

            if(y.awakenedInfo) then
                local currentEntry = y.trackInfo[#y.trackInfo]
                    
                for i = 1, currentEntry.length, 1 do
                    if(currentEntry.data[i] == itemLevel) then
                        trackString = trackString .. WrapTextInColorCode(i .. "/" .. currentEntry.length, miog.ITEM_QUALITY_COLORS[#y.trackInfo - 1].color:GenerateHexColor()) .. "  "
                    end
                end
            end
        end
    end

    return trackString
end

--local forceSeasonID = 13

miog.insertGearingData = function()
    local seasonID = forceSeasonID or C_MythicPlus.GetCurrentSeason()

    if(not seasonID) then
        seasonID = 12
        
    end

    local gearingData = miog.GEARING_CHART[seasonID]
    local r, g, b

    for k, v in pairs(miog.GEARING_CHART) do
        if(k == seasonID) then
            for a in pairs(v.itemLevelInfo) do
                currentChildren[a].ItemLevel:SetText(a)
                local fullDungeonText, fullDungeonVaultText = "", ""

                for x, y in pairs(gearingData.dungeon.itemLevels) do
                    if(y == a) then
                        fullDungeonText = fullDungeonText .. (fullDungeonText == "" and gearingData.dungeon.info[x].name or "/" .. gearingData.dungeon.info[x].name)
                    end
                end

                for x, y in pairs(gearingData.dungeon.vaultLevels) do
                    if(y == a) then
                        fullDungeonVaultText = fullDungeonVaultText .. (fullDungeonVaultText == "" and gearingData.dungeon.info[x].name or "/" .. gearingData.dungeon.info[x].name)
                    end
        
                end
        
                for x, y in pairs(gearingData.raid.itemLevels) do
                    if(y == a) then
                        currentChildren[a].Raid:SetText(gearingData.raid.info[x].name)
                    end
        
                end
        
                for x, y in pairs(gearingData.other.itemLevels) do
                    if(y == a) then
                        currentChildren[a].Other:SetText(gearingData.other.info[x].name)
                    end

                end

                currentChildren[a].Dungeon:SetText(fullDungeonText)
                currentChildren[a].DungeonVault:SetText(fullDungeonVaultText)
                currentChildren[a].Track:SetText(miog.createTrackString(seasonID, tonumber(a)))

                r, g, b = nil, nil, nil

                for x, y in ipairs(v.trackInfo) do
                    --if(v.baseItemLevel <= itemLevel and (miog.GEARING_CHART[seasonID].awakenedInfo and (k == #miog.GEARING_CHART[seasonID].trackInfo and itemLevel > miog.GEARING_CHART[seasonID].trackInfo[k - 1].maxItemLevel or k ~= #miog.GEARING_CHART[seasonID].trackInfo) or not miog.GEARING_CHART[seasonID].awakenedInfo)) then
                    --if(itemLevel <= v.maxItemLevel and (k == 1 and v.baseItemLevel <= itemLevel or itemLevel > miog.GEARING_CHART[seasonID].trackInfo[k - 1].maxItemLevel)) then

                    if(a > v.maxUpgradeItemLevel) then
                        r, g, b =  miog.ITEM_QUALITY_COLORS[6].color:GetRGB()
                        
                    else
                        for n = 1, y.length, 1 do
                            if(not v.awakenedInfo and a == y.data[n] or x ~= #v.trackInfo and a == y.data[n]) then
                                r, g, b =  miog.ITEM_QUALITY_COLORS[x - 1].color:GetRGB()

                            end
                        end
                    end
                end
        
                if(r == nil) then
                    r, g, b = 1, 1, 1
        
                end

                currentChildren[a].ItemLevel:SetTextColor(r, g, b, 1)
                currentChildren[a].Dungeon:SetTextColor(r, g, b, 1)
                currentChildren[a].Raid:SetTextColor(r, g, b, 1)
                currentChildren[a].DungeonVault:SetTextColor(r, g, b, 1)

                currentChildren[a].Other:SetTextColor(r,g,b,1)
        
                currentChildren[a].Progress:SetText(miog.getVaultProgress(a))
                currentChildren[a].Progress:SetTextColor(r,g,b,1)
            end

        end

    end

   --[[ while(currentItemLevel < gearingData.maxItemLevel) do
        currentItemLevel = miog.getAdjustedItemLevel(seasonID, counter)

        local dungeonText = ""
        local raidText = ""

        local hasData = false

        for k, v in pairs(gearingData.dungeon.itemLevels) do
            if(v == currentItemLevel) then
                dungeonText = v
                hasData = true
            end

        end

        for k, v in pairs(gearingData.raid.itemLevels) do
            if(v == currentItemLevel) then
                raidText = v
                hasData = true

                if(allowance == 0) then
                    allowance = 3
                    
                else
                    allowance = allowance - 1

                end
            end

        end

        if(hasData or allowance > 0) then
            local currentChild = rowChildren[counter]
            currentChild.ItemLevel:SetText(currentItemLevel)
            currentChild.Dungeon:SetText(dungeonText)
            currentChild.Raid:SetText(raidText)
        end

        counter = counter + 1
    end]]

    
   --[[ for i = gearingData.baseItemLevel, gearingData.maxItemLevel, 1 do
        if(gearingData.itemLevelInfo[i] or allowance > 0) then
            local currentLine = rowChildren[counter]
            currentLine.ItemLevel:SetText(i)
            local jumpsNeeded = miog.getJumpsForItemLevel(seasonID, i)

            for k, v in pairs(miog.GEARING_CHART[seasonID]) do
                if(type(v) == "number") then
                    print(v, i)
                    currentLine.Raid:SetText(v == miog.getJumpsForItemLevel(seasonID, i) and (k == "normal" and "Normal" or k == "heroic" and "Heroic" or k == "mythic" and "Mythic" or k == "lfr" and "LFR") or "")
                    
                end

            end

            counter = counter + 1
        end
    end]]

    --[[for i = 1, #rowChildren, 1 do
        local id = i > 15 and 16 or i > 11 and 15 or i > 7 and 14 or i > 3 and 17
        local itemLevel = i == 2 and miog.getAdjustedItemLevel(seasonID, gearingData.normalDungeon) or i == 3 and miog.getAdjustedItemLevel(seasonID, gearingData.heroicDungeon) or i == 1 and "ILvl" or miog.getAdjustedItemLevel(seasonID, gearingData.heroicDungeon + (i - 3))
        r, g, b = nil, nil, nil

        if(i > 1) then
            for k, v in ipairs(miog.GEARING_CHART[seasonID].trackInfo) do
                --if(v.baseItemLevel <= itemLevel and (miog.GEARING_CHART[seasonID].awakenedInfo and (k == #miog.GEARING_CHART[seasonID].trackInfo and itemLevel > miog.GEARING_CHART[seasonID].trackInfo[k - 1].maxItemLevel or k ~= #miog.GEARING_CHART[seasonID].trackInfo) or not miog.GEARING_CHART[seasonID].awakenedInfo)) then
                --if(itemLevel <= v.maxItemLevel and (k == 1 and v.baseItemLevel <= itemLevel or itemLevel > miog.GEARING_CHART[seasonID].trackInfo[k - 1].maxItemLevel)) then

                if(itemLevel > miog.GEARING_CHART[seasonID].maxUpgradeItemLevel) then
                    r, g, b =  miog.ITEM_QUALITY_COLORS[6].color:GetRGB()
                    
                else
                    for n = 1, v.length, 1 do
                        if(not miog.GEARING_CHART[seasonID].awakenedInfo and itemLevel == v.data[n] or k ~= #miog.GEARING_CHART[seasonID].trackInfo and itemLevel == v.data[n]) then
                            r, g, b =  miog.ITEM_QUALITY_COLORS[k - 1].color:GetRGB()

                        end
                    end
                end
            end
        end

        if(r == nil) then
            r, g, b = 1, 1, 1

        end

        rowChildren[i].ItemLevel:SetText(itemLevel)
        rowChildren[i].ItemLevel:SetTextColor(r,g,b,1)

        rowChildren[i].Track:SetText(i == 1 and "Track" or miog.createTrackString(seasonID, tonumber(itemLevel)))
        --rowChildren[i].Track:SetTextColor(r,g,b,1)

        rowChildren[i].Raid:SetText(i > 7 and miog.DIFFICULTY_ID_INFO[id].name or i > 3 and miog.DIFFICULTY_ID_INFO[id].shortName or i == 1 and "Raid" or "")
        rowChildren[i].Raid:SetTextColor(r,g,b,1)

        rowChildren[i].Dungeon:SetText(i == 13 and "+9/+10" or i == 12 and "+7/+8" or i == 11 and "+5/+6" or i == 10 and "+3/+4" or i == 9 and "+2" or i == 8 and "M0" or i == 3 and "Heroic/TW" or i == 2 and "Normal" or i == 1 and "Dng Loot" or "")
        rowChildren[i].Dungeon:SetTextColor(r,g,b,1)

        rowChildren[i].DungeonVault:SetText(i == 17 and "+9/+10" or i == 16 and "+7/+8" or i == 15 and "+5/+6" or i == 14 and "+3/+4" or i == 13 and "+2" or i == 12 and "M0" or i == 7 and "Heroic/TW" or i == 1 and "Dng Vault" or "")
        rowChildren[i].DungeonVault:SetTextColor(r,g,b,1)

        rowChildren[i].Other:SetText(i == 18 and "Aspect R5" or i == 15 and "Wyrm R5" or i == 1 and "Other" or "")
        rowChildren[i].Other:SetTextColor(r,g,b,1)

        rowChildren[i].Progress:SetText(i == 1 and "Progress" or miog.getVaultProgress(tonumber(rowChildren[i].ItemLevel:GetText())))
        rowChildren[i].Progress:SetTextColor(r,g,b,1)
    end]]
end

miog.loadGearingChart = function()
    local singleGrid = CreateFrame("Frame", nil, miog.pveFrame2.TabFramesPanel.Gearing.RowLayout, "MIOG_GearingChartLine")
    singleGrid.fixedWidth = miog.pveFrame2.TabFramesPanel.Gearing.RowLayout:GetWidth()
    singleGrid.layoutIndex = 1
    singleGrid.bottomPadding = 5

    singleGrid.ItemLevel.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    singleGrid.ItemLevel:SetText("ILvl")

    singleGrid.Track.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    singleGrid.Track:SetText("Track")

    singleGrid.Raid.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    singleGrid.Raid:SetText("Raid")

    singleGrid.Dungeon.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    singleGrid.Dungeon:SetText("Dng Loot")

    singleGrid.DungeonVault.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    singleGrid.DungeonVault:SetText("Dng Vault")

    singleGrid.Other.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    singleGrid.Other:SetText("Other")

    singleGrid.Progress.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    singleGrid.Progress:SetText("Progress")
    
    local seasonID = forceSeasonID or C_MythicPlus.GetCurrentSeason()

    if(not seasonID) then
        seasonID = 12
        
    end

    for k, v in pairs(miog.GEARING_CHART) do
        if(k == seasonID) then
            for a, b in pairs(v.itemLevelInfo) do
                singleGrid = CreateFrame("Frame", nil, miog.pveFrame2.TabFramesPanel.Gearing.RowLayout, "MIOG_GearingChartLine")
                singleGrid.fixedWidth = miog.pveFrame2.TabFramesPanel.Gearing.RowLayout:GetWidth()
                singleGrid.layoutIndex = a
                singleGrid.bottomPadding = 5
    
                singleGrid.ItemLevel.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    
                singleGrid.Track.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    
                singleGrid.Raid.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    
                singleGrid.Dungeon.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    
                singleGrid.DungeonVault.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    
                singleGrid.Other.layoutIndex = #singleGrid:GetLayoutChildren() + 1
    
                singleGrid.Progress.layoutIndex = #singleGrid:GetLayoutChildren() + 1

                currentChildren[a] = singleGrid
            end

            for a, b in ipairs(v.trackInfo) do
                local currentLegendFrame = miog.pveFrame2.TabFramesPanel.Gearing.Legend[a == 1 and "Explorer" or a == 2 and "Adventurer" or a == 3 and "Veteran" or a == 4 and "Champion" or a == 5 and "Hero" or a == 6 and "Myth" or a == 7 and "Awakened"]

                if(currentLegendFrame) then
                    currentLegendFrame:SetColorTexture(miog.ITEM_QUALITY_COLORS[a - 1].color:GetRGBA())
                    currentLegendFrame:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(self:GetParentKey())
                        GameTooltip:AddLine(LFG_LIST_ITEM_LEVEL_INSTR_SHORT .. ": " .. b.baseItemLevel .. " - " .. b.maxItemLevel)
                        GameTooltip:Show()
                    end)
                end
            end

            if(not v.awakenedInfo) then
                miog.pveFrame2.TabFramesPanel.Gearing.Legend["Awakened"]:Hide()
                miog.pveFrame2.TabFramesPanel.Gearing.Legend:SetWidth(miog.pveFrame2.TabFramesPanel.Gearing.Legend:GetWidth() - miog.pveFrame2.TabFramesPanel.Gearing.Legend["Awakened"]:GetWidth())
            end
        end
    end
end