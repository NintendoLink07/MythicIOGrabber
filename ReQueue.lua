local addonName, miog = ...

local function events(_, event, ...)
    if(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
            local resultID, new, old, name = ...
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    end
end

eventReceiver:SetScript("OnEvent", events)