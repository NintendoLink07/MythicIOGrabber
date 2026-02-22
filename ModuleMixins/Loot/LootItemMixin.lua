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

function LootItemMixin:SetData(data)
    self.Name:SetText(WrapTextInColorCode(data.name, data.itemQuality))
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
            local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(data.link)

            local altName = (classID~= 4 or subclassID ~= 0) and C_Item.GetItemSubClassInfo(classID, subclassID)

            self.Type:SetText(data.slot .. (altName and " - " .. altName or ""))

        end
    end
    
    self.Itemlevel:SetText(data.itemlevel)

    self.data = data

    self:SetExpandState(false)
end

function LootItemMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(self.data.link)
    GameTooltip:Show()

end