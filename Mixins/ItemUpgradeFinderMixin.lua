local addonName, miog = ...

ItemUpgradeFinderMixin = {}

local keyToFilterType = {
    ["Head"] = 0,
    ["Neck"] = 1,
    ["Shoulder"] = 2,
    ["Back"] = 3,
    ["Chest"] = 4,
    ["Wrist"] = 5,
    ["Hands"] = 6,
    ["Legs"] = 7,
    ["Waist"] = 8,
    ["Feet"] = 9,
    ["MainHand"] = 10,
    ["SecondaryHand"] = 11,
    ["Finger"] = 12,
    ["Trinket"] = 13,
    ["Other"] = 14,
    ["NoFilter"] = 15,
}

function ItemUpgradeFinderMixin:GetFilterID()
    local offset = 0
    local name = self:GetName()

    if(strfind(name, "Trinket") or strfind(name, "Finger")) then
        offset = 1
        
    end

    local slotName = strsub(name, 10, strlen(name) - 4 - offset)
    
	return keyToFilterType[slotName];
end

function ItemUpgradeFinderMixin:OnClick()
    if(self.filterID) then
        local item = Item:CreateFromEquipmentSlot(self:GetID())
        local linkType, linkOptions, displayText = LinkUtil.ExtractLink(item:GetItemLink())
        local itemlevel = item:GetCurrentItemLevel()

        --miog.removeItemLevelBonusIDsFromLink(item:GetItemLink())

        --miog.printAllBonusIDs(item:GetItemLink())

        miog.updateItemList(self.filterID, itemlevel)
    end
end

function ItemUpgradeFinderMixin:OnLoad()
    PaperDollItemSlotButton_OnLoad(self)
    self.filterID = self:GetFilterID()
end