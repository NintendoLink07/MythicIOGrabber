local addonName, miog = ...

miog.getAdjustedItemLevel = function(jumps)
    local jumpsCompleted = 0
    local newItemLevel = miog.GEARING_CHART[12].baseItemLevel

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
        local name = k == 1 and "M+" or k == 2 and "PvP" or k == 3 and "Raid"

        for i = 1, 3, 1 do
            if(v[i] and v[i] == lootLevel) then
                returnString = returnString .. name .. "[" .. i .. "] "
            end
        end
    end

    return returnString
end

miog.insertGearingData = function()
    local gearingData = miog.GEARING_CHART[12]
    local rowChildren = miog.pveFrame2.TabFramesPanel.Gearing.RowLayout:GetLayoutChildren()

    for i = 1, #rowChildren, 1 do
        local maxVaultLoot = miog.getAdjustedItemLevel(gearingData.heroicDungeon + (i - 3) + 4)
        local gridChildren = rowChildren[i]:GetLayoutChildren()
        local id = i > 15 and 16 or i > 11 and 15 or i > 7 and 14 or i > 3 and 17

        gridChildren[1]:SetText(i == 2 and miog.getAdjustedItemLevel(gearingData.normalDungeon) or i == 3 and miog.getAdjustedItemLevel(gearingData.heroicDungeon) or i == 1 and "Loot/Vault" or miog.getAdjustedItemLevel(gearingData.heroicDungeon + (i - 3)))
        --gridChildren[2]:SetText(i <= 13 and i >= 8 and maxVaultLoot or i == 3 and miog.getAdjustedItemLevel(gearingData.heroicDungeon + 4) or i == 1 and "Dun Vault" or "")

        gridChildren[2]:SetText(i > 7 and miog.DIFFICULTY_ID_INFO[id].name or i > 3 and miog.DIFFICULTY_ID_INFO[id].shortName or i == 1 and "Raid" or "")
        gridChildren[3]:SetText(i == 13 and "+9/+10" or i == 12 and "+7/+8" or i == 11 and "+5/+6" or i == 10 and "+3/+4" or i == 9 and "+2" or i == 8 and "M0" or i == 3 and "Heroic" or i == 2 and "Normal" or i == 1 and "Dng Loot" or "")
        gridChildren[4]:SetText(i == 17 and "+9/+10" or i == 16 and "+7/+8" or i == 15 and "+5/+6" or i == 14 and "+3/+4" or i == 13 and "+2" or i == 12 and "M0" or i == 1 and "Dng Vault" or "")
        gridChildren[5]:SetText(i == 18 and "Craft Aspect Max" or i == 13 and "Craft Wyrm Max" or i == 1 and "Other" or "")

        gridChildren[6]:SetText(i == 1 and "Progress" or miog.getVaultProgress(tonumber(gridChildren[1]:GetText())))

    end
end

miog.loadGearingChart = function()
    for i = 1, 21, 1 do
        local singleGrid = CreateFrame("Frame", nil, miog.pveFrame2.TabFramesPanel.Gearing.RowLayout, "GridLayoutFrame")
        singleGrid.isHorizontal = true
        singleGrid.layoutFramesGoingRight = true
        singleGrid.stride = 6
        singleGrid.childXPadding = 5
        singleGrid.fixedWidth = miog.pveFrame2.TabFramesPanel.Gearing.RowLayout:GetWidth()
        singleGrid.layoutIndex = i

        local itemLevel = singleGrid:CreateFontString()
        itemLevel:SetJustifyH("LEFT")
        itemLevel:SetWidth(50)
        itemLevel:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")
        itemLevel.layoutIndex = 1
        

        --[[local vaultItemLevel = singleGrid:CreateFontString()
        vaultItemLevel:SetJustifyH("LEFT")
        vaultItemLevel:SetWidth(50)
        vaultItemLevel:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")
        vaultItemLevel.layoutIndex = 2]]

        local raidName = singleGrid:CreateFontString()
        raidName:SetJustifyH("LEFT")
        raidName:SetWidth(60)
        raidName:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")

        local id = i > 15 and 16 or i > 11 and 15 or i > 7 and 14 or i > 3 and 17

        local r,g,b
        
        if(miog.DIFFICULTY_ID_TO_COLOR[id]) then
            r, g, b = miog.DIFFICULTY_ID_TO_COLOR[id].r, miog.DIFFICULTY_ID_TO_COLOR[id].g, miog.DIFFICULTY_ID_TO_COLOR[id].b

        else
            r, g, b = 1,1,1

        end

        raidName:SetTextColor(r,g,b,1)
        raidName.layoutIndex = 2

        local dungeonLoot = singleGrid:CreateFontString()
        dungeonLoot:SetJustifyV("MIDDLE")
        dungeonLoot:SetJustifyH("LEFT")
        dungeonLoot:SetWidth(60)
        dungeonLoot:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")
        dungeonLoot.layoutIndex = 3

        local dungeonVault = singleGrid:CreateFontString()
        dungeonVault:SetJustifyV("MIDDLE")
        dungeonVault:SetJustifyH("LEFT")
        dungeonVault:SetWidth(60)
        dungeonVault:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")
        dungeonVault.layoutIndex = 4

        local otherName = singleGrid:CreateFontString()
        otherName:SetJustifyV("MIDDLE")
        otherName:SetJustifyH("LEFT")
        otherName:SetWidth(125)
        otherName:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")
        -- i > 13 and i - 13 <= 5 and "Craft Aspect " .. (i - 13) .. "/5" or 
        otherName.layoutIndex = 5

        local progress = singleGrid:CreateFontString()
        progress:SetJustifyV("MIDDLE")
        progress:SetJustifyH("LEFT")
        progress:SetWidth(200)
        progress:SetFont(miog.FONTS["libMono"], 12, "OUTLINE")
        progress.layoutIndex = 6

        local separator = singleGrid:CreateTexture()
        separator:SetAtlas("dragonflight-weeklyrewards-divider")
        separator:SetHeight(5)
        separator:SetPoint("TOPLEFT", singleGrid, "BOTTOMLEFT")
        separator:SetPoint("TOPRIGHT", singleGrid, "BOTTOMRIGHT")
    end
end