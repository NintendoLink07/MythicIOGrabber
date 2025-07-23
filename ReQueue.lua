local addonName, miog = ...

local eventReceiver = CreateFrame("Frame", "MythicRequeue_EventReceiver2")

local id = 1
local partyGUIDList = {}
local isDirty = false

local requeueFrame

miog.requeue = {}

local function removeGUIDFromList(guid)
    partyGUIDList[guid] = nil
end

local function addDataToList(guid, resultID)
    partyGUIDList[guid] = {resultID = resultID, timestamp = GetTimePreciseSec(), id = id}

    id = id + 1

    isDirty = true
end

local function getPartyGUIDData(guid)
    return partyGUIDList[guid]
end

miog.requeue.getPartyGUIDData = getPartyGUIDData

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

local function getFirstResultID()
    local firstResultID
    local lastCounter = math.huge

    for guid, info in pairs(partyGUIDList) do
        if(info.id < lastCounter) then
            firstResultID = info.resultID

        end

    end

    return firstResultID
end

local function countPartyGUIDs()
    local numOfGroups = 0

    for _ in pairs(partyGUIDList) do
        numOfGroups = numOfGroups + 1

    end

    return numOfGroups
end

miog.requeue.countPartyGUIDs = countPartyGUIDs

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

local function countApplicationsAndGUIDs()
    return countActualApplications(), countPartyGUIDs()

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

    if(not InCombatLockdown()) then
        QueueStatusFrame:Update()

    end
end

MIOG_PROCESS_FAKE_RESULT_ID = processResultID

local function checkForErrors()
    if(countPartyGUIDs() == 0) then
        UIErrorsFrame:AddExternalErrorMessage("[MIOG]: No more groups to apply to.");
        return false
       
    elseif(countActualApplications() == 5) then
        UIErrorsFrame:AddExternalErrorMessage("[MIOG]: Too many active applications.");
        return false

    end

    return true
end

local function canSetupPopup()
    local apps, guids = countApplicationsAndGUIDs()

    return apps < 5 and guids > 0 and true or false
end

local function setupPopup()
    if(canSetupPopup()) then
        local resultID = getFirstResultID()

        if(C_LFGList.HasSearchResultInfo(resultID)) then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
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

            requeueFrame.BacklogText:SetText("Applications in your backlog: " .. countPartyGUIDs())

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
end

local function events(_, event, ...)
    if(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID, appStatus = ...

        processResultID(resultID, appStatus)
        setupPopup()
        
    --elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
        --local resultID = ...
        --local appStatus = "failed"

        --processResultID(resultID, appStatus)
        --setupPopup()

    elseif(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
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

	mainFrame.ApplyButton:FitToText()
	mainFrame.ApplyButton:SetScript("OnClick", function()
	    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		local resultID = getFirstResultID()

        if(resultID and checkForErrors()) then
            C_LFGList.ApplyToGroup(resultID,
                LFGListApplicationDialog.TankButton:IsShown() and LFGListApplicationDialog.TankButton.CheckButton:GetChecked(),
                LFGListApplicationDialog.HealerButton:IsShown() and LFGListApplicationDialog.HealerButton.CheckButton:GetChecked(),
                LFGListApplicationDialog.DamagerButton:IsShown() and LFGListApplicationDialog.DamagerButton.CheckButton:GetChecked()
            )
        end
	end)

    requeueFrame = mainFrame
end

miog.loadRequeue = loadRequeue

eventReceiver:SetScript("OnEvent", events)