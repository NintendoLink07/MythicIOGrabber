local addonName, miog = ...


local weapons = {id = 2, enum = Enum.ItemWeaponSubclass}
local armor = {id = 4, enum = Enum.ItemArmorSubclass}

local blizzEnums = {weapons, armor}

local enumTables = {}

for k, v in pairs(blizzEnums) do
    enumTables[v.id] = {}

    for x, y in pairs(v.enum) do
        enumTables[v.id][y] = x

    end

end

LootItemMixin = CreateFromMixins(LootLineMixin)

local weaponTypes = {}

local function createTableFromEnum(enum, table)
    for k, v in pairs(enum) do
        table[v] = k

    end
end

createTableFromEnum(Enum.ItemWeaponSubclass, weaponTypes)

local function getItemClassSubClassName(itemID, classID, subclassID)
    if(classID == 0 and subclassID == 8) then
        return "Other"

    elseif(classID == 1) then
        --if(subclassID == 0) then
        return "Bag"

    elseif(classID == 3) then
        if(subclassID == 11) then
            return "Relic"

        end

    elseif(classID == 5 and subclassID == 2) then
        return "Curio"
        
    elseif(classID == 7) then
        return "Trade"
        
    elseif(classID == 9) then
        return "Recipe"

    elseif(classID == 12) then
        return "Quest"
    
    elseif(classID == 15) then
        if(subclassID == 0) then
            local _, toyName = C_ToyBox.GetToyInfo(itemID)

            if(toyName) then
                return "Toy"
                
            else
                return "Class token"

            end
        elseif(subclassID == 2) then
            return "Pet"

        elseif(subclassID == 4) then
            return "Other"

        elseif(subclassID == 5) then
            return "Mount"

        end
    elseif(classID == 20) then
        if(subclassID == 0) then
            return "Decor"

        end

    else
        return nil, "|cffff0000" .. "MISS" .. "|r" .. classID .. "-" .. subclassID

    end
end

function replace_char3(pos, str, r)
    return table.concat{str:sub(1,pos-1), r, str:sub(pos+1)}
end

function replace_char2(pos, str, r)
    return ("%s%s%s"):format(str:sub(1,pos-1), r, str:sub(pos+1))
end

function replace_char1(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

function LootItemMixin:CalculateConfidence(value, origLen, places)
    if(value and origLen) then
        return string.format("%." .. (places or 0) .. "f %%", (value / origLen) * 100)

    end
end

function LootItemMixin:ColorFilterMatches()
    if(self.data.filterMatches) then
        if(self.data.filterMatches[1]) then
            local matchIndices = self.data.filterMatches[1][2]

            if(matchIndices) then
                local text = self.Name:GetText()
                local origLen = strlen(text)
                local offset = self.data.abbreviatedName and strlen(self.data.abbreviatedName) + 3 or 0

                for k, v in ipairs(matchIndices) do
                    if(k == 1) then
                        offset = offset + 0

                    else
                        offset = offset + 12

                    end

                    local char = strsub(text, v+offset, v+offset)

                    --print(k, v+offset, char, text)

                    text = replace_char2(v+offset, text, WrapTextInColorCode(char, miog.CLRSCC.green))
                    
                    
                end

                self.Name:SetText(text .. " - " .. self:CalculateConfidence(self.data.filterMatches[1][3], origLen, 2))
            end

            --[[for k, v in pairs(self.data.filterMatches[1][2]) do
                string.gsub(text, )
                
            end]]
        end
    end
end

function LootItemMixin:SetData(data)
    --WrapTextInColorCode(data.name, data.itemQuality)
    self.Name:SetText((data.abbreviatedName and "[" .. data.abbreviatedName .. "]" .. " " or "") .. (data.filterMatches and data.name or WrapTextInColorCode(data.name, data.itemQuality)))
    self.Name:SetPoint("LEFT", self.Itemlevel, "RIGHT", 3, 0)

    self.Icon:SetTexture(data.icon)
    self.Icon:SetPoint("LEFT", self, "LEFT", 0, 0)

    if(data.slot) then
        if(data.filterType == 14) then
            local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(data.link)

            local type, status = getItemClassSubClassName(data.itemID, classID, subclassID)
            
            if(not type) then
                type = C_Item.GetItemSubClassInfo(classID, subclassID)

            end
            
            self.Type:SetText(type)

        else
            local name, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(data.link)

            local subclassName = C_Item.GetItemSubClassInfo(classID, subclassID)

            local altName = classID == 4 and subclassID ~= 0 and subclassName
            local altSlot = classID == 2 and subclassName

            self.Type:SetText((altSlot or data.slot) .. (altName and " - " .. altName or ""))

        end
    end
    
    self.Itemlevel:SetText(data.itemlevel)

    self.data = data

    self:ColorFilterMatches()
    self:SetExpandState(false)
end

function LootItemMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(self.data.link)

    if(self.data.bossName) then
        GameTooltip_AddBlankLineToTooltip(GameTooltip)
        GameTooltip:AddLine(string.format(BOSS_INFO_STRING, self.data.bossName))

    end

    GameTooltip:Show()

end