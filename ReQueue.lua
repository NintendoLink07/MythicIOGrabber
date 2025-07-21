local addonName, miog = ...

local eventReceiver = CreateFrame("Frame", "MythicRequeue_EventReceiver2")

local id = 1
local partyGUIDList = {}
local isDirty = false

local requeueFrame

local function removeGUIDFromList(guid)
    partyGUIDList[guid] = nil
end

local function addDataToList(guid, resultID)
    partyGUIDList[guid] = {resultID = resultID, timestamp = GetTimePreciseSec(), id = id}
    isDirty = true

    id = id + 1
end

local function getFirstPartyGUID()
    local firstGUID
    local lastCounter = math.huge

    for guid, info in pairs(partyGUIDList) do
        if(info.id < lastCounter) then
            firstGUID = guid

        end

    end

    return firstGUID
end

local function countPartyGUIDs()
    local numOfGroups = 0

    for _ in pairs(partyGUIDList) do
        numOfGroups = numOfGroups + 1

    end

    return numOfGroups
end

local function countActualApplications()
	local numOfActualApps = 0
	local applications = C_LFGList.GetApplications()

	for _, v in ipairs(applications) do
		local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(v)

		if(appStatus == "applied" or pendingStatus == "applied") then
			numOfActualApps = numOfActualApps + 1

		end
	end

	return numOfActualApps
end

local function processResultID(resultID, appStatus)
    if(C_LFGList.HasSearchResultInfo(resultID)) then
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

        if(appStatus == "inviteaccepted" or appStatus == "invitedeclined" or (appStatus == "declined" and not searchResultInfo.isDelisted)) then
            removeGUIDFromList(searchResultInfo.partyGUID)
            
        elseif(appStatus == "failed") then
            if(not searchResultInfo.isDelisted) then
                addDataToList(searchResultInfo.partyGUID, resultID)

            else
                removeGUIDFromList(searchResultInfo.partyGUID)
                
            end
        end
    end
end

local function setupPopup()
    if(countPartyGUIDs() > 0 and countActualApplications() < 5) then
        local info = partyGUIDList[getFirstPartyGUID()]
        local searchResultInfo = C_LFGList.GetSearchResultInfo(info.resultID)
        local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])

        local activityName = ""
        
        if(activityInfo.categoryID) then
	        local categoryInfo = C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID)

            activityName = categoryInfo.name .. ":"
        end

        if(activityInfo.icon) then
            activityName = activityName .. " |T" .. activityInfo.icon .. ":12:12|t "

        end

        activityName = activityName .. searchResultInfo.name .. " - " .. (activityInfo.mapName or "")

        requeueFrame.ActivityText:SetText(activityName)

        if(isDirty) then
            requeueFrame.ApplyButton:Hide()
            requeueFrame.RefreshButton:Show()

        else
            requeueFrame.RefreshButton:Hide()
            requeueFrame.ApplyButton:Show()

        end
        
        requeueFrame:SetSize(LFGListApplicationDialog:GetSize())
        StaticPopupSpecial_Show(requeueFrame)

    end
end

local function events(_, event, ...)
    if(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID, appStatus = ...

        processResultID(resultID, appStatus)
        setupPopup()
        
    elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
        local resultID = ...
        local appStatus = "failed"

        processResultID(resultID, appStatus)
        setupPopup()
    end
end

local function loadRequeue()
    local mainFrame = CreateFrame("Frame", "MythicRequeue_Frame1", UIParent, "MIOG_RequeuePopup")
    mainFrame:ClearAllPoints()
    mainFrame:SetSize(400, 300)

    eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
    eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
    eventReceiver:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

    hooksecurefunc("LFGListSearchPanel_DoSearch", function() isDirty = false end)

    requeueFrame = mainFrame
end

miog.loadRequeue = loadRequeue

eventReceiver:SetScript("OnEvent", events)