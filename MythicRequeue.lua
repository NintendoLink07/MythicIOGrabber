local addonName, miog = ...
local wticc = WrapTextInColorCode

local eventReceiver = CreateFrame("Frame", "MythicRequeue_EventReceiver")

local refreshNeeded
local searchResults = {}
local applyPopup

local function getSavedPartyGUIDs()
	return MIOG_NewSettings.requeueData.guids
end

local function addPartyGUID(guid, resultID)
	refreshNeeded = true
	MIOG_NewSettings.requeueData.guids[guid] = {resultID = resultID, partyGUID = guid, timestamp = GetTimePreciseSec()}
end

local function deletePartyGUID(guid)
	MIOG_NewSettings.requeueData.guids[guid] = nil

end

MIOG_DeletePartyGUID = deletePartyGUID

local function getNumberOfPartyGUIDs()
    local num = 0

	for _ in pairs(MIOG_NewSettings.requeueData.guids) do
		num = num + 1
		
	end

	return num
end


local function refreshSearchResults()
    local _, resultTable = C_LFGList.GetFilteredSearchResults()

    searchResults = resultTable
end

local function refreshPartyGUIDs()
    local newPartyGUIDs = {}

    for _, v in ipairs(searchResults) do
        local searchResultInfo = C_LFGList.GetSearchResultInfo(v)
		if(C_LFGList.HasSearchResultInfo(v) and not searchResultInfo.isDelisted) then
            local partyGUID = searchResultInfo.partyGUID

			if(MIOG_NewSettings.requeueData.guids[partyGUID]) then
				local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(v)

				if(appStatus ~= "applied" and pendingStatus ~= "applied") then
                    if(not MIOG_NewSettings.clearFakeApps or miog.checkEligibility("LFGListFrame.SearchPanel", nil, v, true)) then
                        newPartyGUIDs[partyGUID] = {resultID = v, timestamp = MIOG_NewSettings.requeueData.guids[partyGUID] and MIOG_NewSettings.requeueData.guids[partyGUID].timestamp or GetTimePreciseSec()}
                        
                    end
                end
			end
		end
    end

	MIOG_NewSettings.requeueData.guids = #searchResults > 0 and newPartyGUIDs or MIOG_NewSettings.requeueData.guids
end

local function getNumberOfActualApplications()
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

local function searchForFirstResultID()
    local orderedList = {}
    
    for _, v in pairs(MIOG_NewSettings.requeueData.guids) do
        v.partyGUID = _
        table.insert(orderedList, v)

    end

    table.sort(orderedList, function(k1, k2)
        return k1.timestamp < k2.timestamp

    end)

    for _, v in ipairs(orderedList) do
        local searchResultInfo = C_LFGList.GetSearchResultInfo(v.resultID)

		if(C_LFGList.HasSearchResultInfo(v.resultID) and not searchResultInfo.isDelisted) then
            local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(v.resultID)

            if(appStatus ~= "applied" and pendingStatus ~= "applied") then
                return v.resultID, searchResultInfo

            end
        else
            deletePartyGUID(v.partyGUID)

        end
    end
end

local function makeFunctionsPublic()
    MR_GetNumberOfPartyGUIDs = getNumberOfPartyGUIDs
    MR_GetSavedPartyGUIDs = getSavedPartyGUIDs
end

local function setupApplyPopup(text1, text2, text3, text4, text5, text6)
	StaticPopupSpecial_Hide(applyPopup)

	refreshPartyGUIDs()

    local numOfPartyGUIDs = getNumberOfPartyGUIDs()

	if(numOfPartyGUIDs > 0 and getNumberOfActualApplications() < 5) then
		applyPopup.Text1:SetText(text1 or "A group has been delisted or declined you.")
		applyPopup.Text2:SetText(text2 or wticc("Your next group is currently still listed.", "FF00FF00"))
		applyPopup.Text3:SetText(text3 or "")
		applyPopup.Text4:SetText(text4 or "")
		applyPopup.Text5:SetText(text5 or "Apply to next group?")
		applyPopup.Text6:SetText(text6 or "Applications in backlog: " .. numOfPartyGUIDs)
		applyPopup:MarkDirty()

		if(refreshNeeded) then
			applyPopup.ButtonPanel.Button2P5:Hide()
			applyPopup.ButtonPanel.Button2:Show()

        else
			applyPopup.ButtonPanel.Button2:Hide()
			applyPopup.ButtonPanel.Button2P5:Show()

		end
		
		StaticPopupSpecial_Show(applyPopup)
	end
end

local function getCategoryIDOfFirstResult()
    local _, info = searchForFirstResultID()

    local activityInfo = C_LFGList.GetActivityInfoTable(info.activityID)

    return activityInfo and activityInfo.categoryID
end

local function checkForErrors()
    if(getNumberOfPartyGUIDs() == 0) then
        UIErrorsFrame:AddExternalErrorMessage("[MIOG]: No more groups to apply to.");
        return false
       
    elseif(getNumberOfActualApplications() == 5) then
        UIErrorsFrame:AddExternalErrorMessage("[MIOG]: Too many active applications.");
        return false

    end

    return true
end

local function loadReQueue()
	applyPopup = CreateFrame("Frame", nil, UIParent, "MIOG_PopupFrame")
    applyPopup:SetPropagateMouseClicks(false)

	applyPopup.ButtonPanel.Button1:SetText("Dismiss")
	applyPopup.ButtonPanel.Button1:FitToText()
	applyPopup.ButtonPanel.Button1:SetScript("OnClick", function()
        StaticPopupSpecial_Hide(applyPopup)

	end)

	applyPopup.ButtonPanel.Button2:SetText("Refresh (REQUIRED)")
	applyPopup.ButtonPanel.Button2:FitToText()
	applyPopup.ButtonPanel.Button2:SetScript("OnClick", function(self)
	    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)

        StaticPopupSpecial_Hide(applyPopup)

        C_Timer.After(0.75, function()
            checkForErrors()
            setupApplyPopup()
        end)
	end)

	applyPopup.ButtonPanel.Button2P5:SetText("Apply to next group")
	applyPopup.ButtonPanel.Button2P5:FitToText()
	applyPopup.ButtonPanel.Button2P5:SetScript("OnClick", function()
	    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		local resultID, searchResultInfo = searchForFirstResultID()

        if(resultID) then
            if(checkForErrors()) then
                C_LFGList.ApplyToGroup(resultID,
                    LFGListApplicationDialog.TankButton:IsShown() and LFGListApplicationDialog.TankButton.CheckButton:GetChecked(),
                    LFGListApplicationDialog.HealerButton:IsShown() and LFGListApplicationDialog.HealerButton.CheckButton:GetChecked(),
                    LFGListApplicationDialog.DamagerButton:IsShown() and LFGListApplicationDialog.DamagerButton.CheckButton:GetChecked()
                )
            end

            deletePartyGUID(searchResultInfo.partyGUID)
        end

        setupApplyPopup()
	end)

	applyPopup:SetScript("OnShow", function()
		if(MIOG_NewSettings.flashOnApplyPopup) then
			FlashClientIcon()
            
		end
	end)

    makeFunctionsPublic()
    hooksecurefunc("LFGListSearchPanel_DoSearch", function() refreshNeeded = false end)

    LFGListFrame.SearchPanel.results = {}

    eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
    eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
    eventReceiver:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
end

miog.loadReQueue = loadReQueue

local function events(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        local isInitialLogin = ...

        if(isInitialLogin and MIOG_NewSettings.requeueData.lastCharacter == miog.createFullNameFrom("unitID", "player")) then
            MIOG_NewSettings.requeueData.guids = {}

        end

        MIOG_NewSettings.requeueData.lastCharacter = miog.createFullNameFrom("unitID", "player")
        
        setupApplyPopup()

    elseif(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
        refreshSearchResults()

	elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
        local resultID = ...

        if(C_LFGList.HasSearchResultInfo(resultID) and MIOG_NewSettings.requeueData.guids[C_LFGList.GetSearchResultInfo(resultID).partyGUID]) then
            refreshPartyGUIDs()

        end
        
    elseif(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID, new, old, name = ...
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

        if(new == "failed") then --over the limit or already delisted
            if(C_LFGList.HasSearchResultInfo(resultID) and not searchResultInfo.isDelisted) then --checking that it's not delisted
                addPartyGUID(searchResultInfo.partyGUID, resultID) --adding to GUID list for later checks

                local frame = miog.SearchPanel.ScrollBox2:FindFrameByPredicate(function(localFrame, node)
                    return node.data.resultID == resultID
                end)
                
                if(frame) then
                    miog.updateScrollBoxFrameApplicationStatus(frame, resultID, "requeue")
                end
            end
            
        elseif(new == "applied") then
            if(C_LFGList.HasSearchResultInfo(resultID) and not searchResultInfo.isDelisted) then
                deletePartyGUID(searchResultInfo.partyGUID)
            end

        elseif(new == "inviteaccepted") then --delete all data
            MIOG_NewSettings.requeueData.guids = {}
            StaticPopupSpecial_Hide(applyPopup)

        elseif(new ~= "invited") then
            setupApplyPopup()

            miog.updateFakeGroupApplications()

        end
    end
end

eventReceiver:SetScript("OnEvent", events)