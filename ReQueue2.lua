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
    local partyGUID = getFirstPartyGUID()

    for _, v in pairs(LFGListFrame.SearchPanel.results) do
        if(C_LFGList.HasSearchResultInfo(v)) then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(v)

            if(partyGUID == searchResultInfo.partyGUID) then
                return v

            end
        end
    end
end

--[[local function getFirstResultID()
    local firstResultID
    local lastCounter = math.huge

    for guid, info in pairs(partyGUIDList) do
        if(info.id < lastCounter) then
            firstResultID = info.resultID

        end

    end

    return firstResultID
end]]

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

local function processResultID(resultID, appStatus, oldStatus)
    if(C_LFGList.HasSearchResultInfo(resultID)) then
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

        if(appStatus == "applied" or appStatus == "inviteaccepted" or appStatus == "invitedeclined" or appStatus == "declined_full" or (appStatus == "declined" and not searchResultInfo.isDelisted)) then
            removeGUIDFromList(searchResultInfo.partyGUID)
            
        elseif(appStatus == "failed" and oldStatus == "none") then
            if(not searchResultInfo.isDelisted) then
                addDataToList(searchResultInfo.partyGUID, resultID)

            else
                removeGUIDFromList(searchResultInfo.partyGUID)
                
            end
        end
    end
end

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

            requeueFrame.resultID = resultID

            StaticPopupSpecial_Show(requeueFrame)
        end
    end
end

local function processAndSetup(resultID, appStatus, oldStatus)
    processResultID(resultID, appStatus, oldStatus)
    setupPopup()

end

MIOG_RQ_PROCESS = processAndSetup

local function events(_, event, ...)
    if(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID, appStatus, oldStatus = ...

        processAndSetup(resultID, appStatus, oldStatus)

        if(not InCombatLockdown()) then
            QueueStatusFrame:Update()

        end
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
	mainFrame.ApplyButton:SetScript("OnClick", function(self)
	    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		local resultID = self:GetParent().resultID

        if(resultID and checkForErrors()) then
            C_LFGList.ApplyToGroup(resultID,
                LFGListApplicationDialog.TankButton:IsShown() and LFGListApplicationDialog.TankButton.CheckButton:GetChecked(),
                LFGListApplicationDialog.HealerButton:IsShown() and LFGListApplicationDialog.HealerButton.CheckButton:GetChecked(),
                LFGListApplicationDialog.DamagerButton:IsShown() and LFGListApplicationDialog.DamagerButton.CheckButton:GetChecked()
            )
        end

        StaticPopupSpecial_Hide(requeueFrame)
	end)

    requeueFrame = mainFrame

    
	--[[if ( newStatus == "declined" ) then
		return LFG_LIST_APP_DECLINED_MESSAGE

	elseif ( newStatus == "declined_full" ) then
		return LFG_LIST_APP_DECLINED_FULL_MESSAGE

	elseif ( newStatus == "declined_delisted" ) then
		return LFG_LIST_APP_DECLINED_DELISTED_MESSAGE

	elseif ( newStatus == "timedout" ) then
		return LFG_LIST_APP_TIMED_OUT_MESSAGE

	end

    function ChatFrame_DisplaySystemMessageInPrimary(messageTag)
        local info = ChatTypeInfo["SYSTEM"];
        DEFAULT_CHAT_FRAME:AddMessage(messageTag, info.r, info.g, info.b, info.id);
    end]]

end

miog.loadRequeue = loadRequeue

eventReceiver:SetScript("OnEvent", events)