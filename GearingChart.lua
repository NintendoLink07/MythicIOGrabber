local addonName, miog = ...

local currentChildren = {}

local seasonID

local function createTrackString(itemLevel)
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

local function insertGearingData()
    local gearingData = miog.GEARING_CHART[seasonID]
    local r, g, b

    for k, v in pairs(miog.GEARING_CHART) do
        if(k == seasonID) then
            for a in pairs(v.itemLevelInfo) do
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
                    r, g, b = miog.ITEM_QUALITY_COLORS[0].color:GetRGB()
        
                end

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
                        currentChildren[a].Raid:SetTextColor(r, g, b, 1)
                    end
        
                end
        
                for x, y in pairs(gearingData.raid.veryRare.itemLevels) do
                    if(y == a) then
                        currentChildren[a].Raid:SetText(gearingData.raid.veryRare.info[x].name)
                        local r2, g2, b2 =  miog.ITEM_QUALITY_COLORS[x + 1].color:GetRGB()
                        currentChildren[a].Raid:SetTextColor(r2, g2, b2, 1)
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
                        currentChildren[a].Other:SetTextColor(r,g,b,1)
                    end

                end

                if(fullDelvesText ~= "") then
                    currentChildren[a].Delves:SetText(fullDelvesText)
                end
                
                currentChildren[a].DelvesVault:SetText(fullDelvesVaultText)
                currentChildren[a].Dungeon:SetText(fullDungeonText)
                currentChildren[a].DungeonVault:SetText(fullDungeonVaultText)
                currentChildren[a].Track:SetText(createTrackString(tonumber(a)))


                currentChildren[a].ItemLevel:SetTextColor(r, g, b, 1)
                currentChildren[a].Dungeon:SetTextColor(r, g, b, 1)
                currentChildren[a].Delves:SetTextColor(r, g, b, 1)
                currentChildren[a].DelvesVault:SetTextColor(r, g, b, 1)
                currentChildren[a].DungeonVault:SetTextColor(r, g, b, 1)
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
    singleGrid.DelvesVault:SetText("Delves Vlt")
    singleGrid.Raid:SetText("Raid")
    singleGrid.Dungeon:SetText("Dungeon")
    singleGrid.DungeonVault:SetText("Dung Vlt")
    singleGrid.Other:SetText("Other")
    
    seasonID = 14 or C_MythicPlus.GetCurrentSeason() or miog.C.BACKUP_SEASON_ID

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

    insertGearingData()
end