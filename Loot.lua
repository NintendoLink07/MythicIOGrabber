local addonName, miog = ...

local eventReceiver = CreateFrame("Frame", "MIOG_LootReceiver")

miog.loot = {}

local function lootEvents(_, event, ...)
    if(event == "LOOT_ITEM_AVAILABLE") then
        print("LOOT AVAILABLE", ...)

    elseif(event == "LOOT_HISTORY_UPDATE_ENCOUNTER") then
        print("UPDATE_ENCOUNTER", ...)

    elseif(event == "LOOT_HISTORY_UPDATE_DROP") then
        print("UPDATE_DROP", ...)

    end
end

miog.loot.init = function()
    eventReceiver:RegisterEvent("LOOT_ITEM_AVAILABLE")
    eventReceiver:RegisterEvent("LOOT_HISTORY_UPDATE_ENCOUNTER")
    eventReceiver:RegisterEvent("LOOT_HISTORY_UPDATE_DROP")
    eventReceiver:SetScript("OnEvent", lootEvents)

end