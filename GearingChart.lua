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

local forceSeasonID = 13

miog.updateProgressData = function()
    local seasonID = forceSeasonID or C_MythicPlus.GetCurrentSeason()

    if(not seasonID or seasonID == -1) then
        seasonID = 12

    end

    local r, g, b

    for k, v in pairs(miog.GEARING_CHART) do
        if(k == seasonID) then
            for a in pairs(v.itemLevelInfo) do
                local progressValue = miog.getVaultProgress(a)
                
                if(progressValue ~= "") then
                    r, g, b = nil, nil, nil

                    for x, y in ipairs(v.trackInfo) do
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

                    currentChildren[a].Progress:SetText(progressValue)
                    currentChildren[a].Progress:SetTextColor(r,g,b,1)
                end
            end
        end
    end
end

miog.insertGearingData = function()
    local seasonID = forceSeasonID or C_MythicPlus.GetCurrentSeason()

    if(not seasonID or seasonID == -1) then
        seasonID = 12
        
    end

    local gearingData = miog.GEARING_CHART[seasonID]
    local r, g, b

    for k, v in pairs(miog.GEARING_CHART) do
        if(k == seasonID) then
            for a in pairs(v.itemLevelInfo) do

                currentChildren[a].ItemLevel:SetText(a)
                local fullDungeonText, fullDungeonVaultText, fullDelvesText, fullDelvesVaultText = "", "", "", ""

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
        
                for x, y in pairs(gearingData.raid.veryRare.itemLevels) do
                    if(y == a) then
                        currentChildren[a].Raid:SetText(gearingData.raid.veryRare.info[x].name)
                    end
        
                end

                for x, y in pairs(gearingData.delves.itemLevels) do
                    if(y == a) then
                        fullDelvesText = fullDelvesText .. (fullDelvesText == "" and gearingData.delves.info[x].name or "/" .. gearingData.delves.info[x].name)
                    end
                end

                for x, y in pairs(gearingData.delves.vaultLevels) do
                    if(y == a) then
                        fullDelvesVaultText = fullDelvesVaultText .. (fullDelvesVaultText == "" and gearingData.delves.info[x].name or "/" .. gearingData.delves.info[x].name)
                    end
                end
        
                for x, y in pairs(gearingData.other.itemLevels) do
                    if(y == a) then
                        currentChildren[a].Other:SetText(gearingData.other.info[x].name)
                    end

                end

                if(fullDelvesText ~= "") then
                    currentChildren[a].Delves:SetText(fullDelvesText .. "(?)")
                end
                
                currentChildren[a].DelvesVault:SetText(fullDelvesVaultText)
                currentChildren[a].Dungeon:SetText(fullDungeonText)
                currentChildren[a].DungeonVault:SetText(fullDungeonVaultText)
                currentChildren[a].Track:SetText(miog.createTrackString(seasonID, tonumber(a)))

                r, g, b = nil, nil, nil

                for x, y in ipairs(v.trackInfo) do
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
                currentChildren[a].Delves:SetTextColor(r, g, b, 1)
                currentChildren[a].DelvesVault:SetTextColor(r, g, b, 1)
                currentChildren[a].Raid:SetTextColor(r, g, b, 1)
                currentChildren[a].DungeonVault:SetTextColor(r, g, b, 1)

                currentChildren[a].Other:SetTextColor(r,g,b,1)
            end

        end

    end
end

miog.loadGearingChart = function()
    miog.Gearing = miog.pveFrame2.TabFramesPanel.Gearing

    local singleGrid = CreateFrame("Frame", nil, miog.Gearing.RowLayout, "MIOG_GearingChartLine")
    singleGrid.fixedWidth = miog.Gearing.RowLayout:GetWidth()
    singleGrid.layoutIndex = 1

    singleGrid.ItemLevel:SetText("ILvl")
    singleGrid.Track:SetText("Track")
    singleGrid.Delves:SetText("Delves")
    singleGrid.DelvesVault:SetText("Delves Vault")
    singleGrid.Raid:SetText("Raid")
    singleGrid.Dungeon:SetText("Dng Loot")
    singleGrid.DungeonVault:SetText("Dng Vault")
    singleGrid.Other:SetText("Other")
    --singleGrid.Progress:SetText("Progress")
    
    local seasonID = forceSeasonID or C_MythicPlus.GetCurrentSeason()

    if(not seasonID or seasonID == -1) then
        seasonID = 12
        
    end

    for k, v in pairs(miog.GEARING_CHART) do
        if(k == seasonID) then
            for a, b in pairs(v.itemLevelInfo) do
                singleGrid = CreateFrame("Frame", nil, miog.Gearing.RowLayout, "MIOG_GearingChartLine")
                singleGrid.fixedWidth = miog.Gearing.RowLayout:GetWidth()
                singleGrid.layoutIndex = a

                currentChildren[a] = singleGrid
            end

            for a, b in ipairs(v.trackInfo) do
                local currentLegendFrame = miog.Gearing.Legend["Track" .. a]

                if(currentLegendFrame) then
                    currentLegendFrame:SetColorTexture(miog.ITEM_QUALITY_COLORS[a - 1].color:GetRGBA())
                    currentLegendFrame:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(b.name)
                        GameTooltip:AddLine(LFG_LIST_ITEM_LEVEL_INSTR_SHORT .. ": " .. b.baseItemLevel .. " - " .. b.maxItemLevel)
                        GameTooltip:Show()
                    end)
                end
            end

            if(not v.awakenedInfo) then
                miog.Gearing.Legend["Track7"]:Hide()
                miog.Gearing.Legend:SetWidth(miog.Gearing.Legend:GetWidth() - miog.Gearing.Legend["Track7"]:GetWidth())
            end
        end
    end
end