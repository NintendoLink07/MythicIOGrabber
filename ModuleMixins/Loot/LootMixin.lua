local addonName, miog = ...

LootMixin = {}

local instanceDB

function LootMixin:SetupInstanceMenu(rootDescription, dropdown)
    local expansionButtons = {}
    
    for k, v in ipairs(miog.TIER_INFO) do
        local expansionButton = rootDescription:CreateRadio(v.name, function(index) return selectedIndex == index end, nil, k)

        expansionButton:AddInitializer(function(button, description, menu)
            local leftTexture = button:AttachTexture();
            leftTexture:SetSize(16, 16);
            leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
            leftTexture:SetTexture(v.icon);

            button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

            return button.fontString:GetUnboundedStringWidth() + 18 + 5
        end)

        expansionButtons[k] = expansionButton
    end

    local finalInstanceList = {}

     for i = 1, 4000, 1 do
        local instanceInfo = instanceDB[i]

        if(instanceInfo and instanceInfo.tier) then
            tinsert(finalInstanceList, instanceInfo)

        end
    end

    table.sort(finalInstanceList, function(k1, k2)
        if(k1.isRaid == k2.isRaid) then
            if(k1.isRaid) then
                return k1.journalInstanceID < k2.journalInstanceID

            end

            return k1.instanceName < k2.instanceName

        end

        return k1.isRaid and true or k2.isRaid and false
    end)

    local hadRaidTier, hadDungeonTier = {}, {}

    local first = false

    for k, v in ipairs(finalInstanceList) do
        if(v and v.tier) then
            local newRaidTier = v.isRaid and not hadRaidTier[v.tier]
            local newDungeonTier = not v.isRaid and not hadDungeonTier[v.tier]

            if(newRaidTier) then
                expansionButtons[v.tier]:CreateTitle("Raids")
                hadRaidTier[v.tier] = true
                
            elseif(newDungeonTier) then
                expansionButtons[v.tier]:CreateTitle("Dungeons")
                hadDungeonTier[v.tier] = true

            end

            local instanceButton = expansionButtons[v.tier]:CreateRadio(v.instanceName, function(index) return false end, nil, i)

            instanceButton:AddInitializer(function(button, description, menu)
                local leftTexture = button:AttachTexture();
                leftTexture:SetSize(16, 16);
                leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
                leftTexture:SetTexture(v.icon);

                if(not first and not v.icon) then
                    first = true
                    
                end

                button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

                return button.fontString:GetUnboundedStringWidth() + 18 + 5
            end)
        end
    end
end

function LootMixin:OnLoad()
    instanceDB = miog:GetJournalDB()

    self.InstanceDropdown:SetupMenu(self.SetupInstanceMenu)
end