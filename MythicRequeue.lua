local addonName, miog = ...
local wticc = WrapTextInColorCode

local eventReceiver = CreateFrame("Frame", "MythicRequeue_EventReceiver")

local refreshNeeded = true
local searchResults = {}
local applyPopup

local function getSavedPartyGUIDs()
	return MIOG_NewSettings.requeueGUIDs
end

local function addPartyGUID(guid, resultID)
	refreshNeeded = true
	MIOG_NewSettings.requeueGUIDs[guid] = {resultID = resultID, timestamp = GetTimePreciseSec()}
end

local function deletePartyGUID(guid)
	MIOG_NewSettings.requeueGUIDs[guid] = nil

end

local function getNumberOfPartyGUIDs()
    local num = 0

	for _ in pairs(MIOG_NewSettings.requeueGUIDs) do
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

			if(MIOG_NewSettings.requeueGUIDs[partyGUID]) then
				local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(v)

				if(appStatus ~= "applied" and pendingStatus ~= "applied") then
                    if(not MIOG_NewSettings.clearFakeApps or miog.checkEligibility("LFGListFrame.SearchPanel", nil, v, true)) then
                        newPartyGUIDs[partyGUID] = {resultID = v, timestamp = GetTimePreciseSec()}
                        
                    end
                end
			end
		end
    end

	MIOG_NewSettings.requeueGUIDs = newPartyGUIDs
end

local function getNumberOfActualApplications()
	local numOfActualApps = 0
	local applications = C_LFGList.GetApplications()

	for _, v in ipairs(applications) do
		local id, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(v)

		if(appStatus == "applied" or pendingStatus == "applied") then
			numOfActualApps = numOfActualApps + 1

		end
	end

	return numOfActualApps
end

local function searchForFirstResultID()
    local orderedList = {}
    
    for _, v in pairs(MIOG_NewSettings.requeueGUIDs) do
        table.insert(orderedList, v)

    end

    table.sort(orderedList, function(k1, k2)
        return k1.timestamp < k2.timestamp

    end)

    for _, v in ipairs(orderedList) do
		if(C_LFGList.HasSearchResultInfo(v.resultID) and not C_LFGList.GetSearchResultInfo(v.resultID).isDelisted) then
            local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(v.resultID)

            if(appStatus ~= "applied" and pendingStatus ~= "applied") then
                return v.resultID

            end
        end
    end
end

--[[local function getNextListingFromQueue()
    for _, v in ipairs(searchResults) do
        local searchResultInfo = C_LFGList.GetSearchResultInfo(v)

		if(C_LFGList.HasSearchResultInfo(v) and not searchResultInfo.isDelisted) then
            local partyGUID = searchResultInfo.partyGUID

			if(MIOG_NewSettings.requeueGUIDs[partyGUID]) then
				local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(v)

				if(appStatus ~= "applied" and pendingStatus ~= "applied") then
					return v

                end
			end
		end
    end
end]]

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
			applyPopup.ButtonPanel:MarkDirty()

		end
		
		StaticPopupSpecial_Show(applyPopup)
	end
end

local function loadReQueue()
	applyPopup = CreateFrame("Frame", nil, UIParent, "MIOG_PopupFrame")

	applyPopup.ButtonPanel.Button1:SetText("Dismiss")
	applyPopup.ButtonPanel.Button1:FitToText()
	applyPopup.ButtonPanel.Button1:SetScript("OnClick", function()
        StaticPopupSpecial_Hide(applyPopup)

	end)

	applyPopup.ButtonPanel.Button2:SetText("Refresh (REQUIRED)")
	applyPopup.ButtonPanel.Button2:FitToText()
	applyPopup.ButtonPanel.Button2:SetScript("OnClick", function(self)
		LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)

        StaticPopupSpecial_Hide(applyPopup)

        C_Timer.After(0.8, function()
            if(getNumberOfPartyGUIDs() > 0) then
                if(getNumberOfActualApplications() < 5) then
                    self:Hide()
                    self:GetParent().Button2P5:Show()
                    self:GetParent():MarkDirty()
    
                else
                    UIErrorsFrame:AddExternalErrorMessage("[MIOG]: Too many active applications.");
        
                end
            else
                UIErrorsFrame:AddExternalErrorMessage("[MIOG]: No more groups to apply to.");
        
            end
    
            setupApplyPopup()
        end)
	end)

	applyPopup.ButtonPanel.Button2P5:SetText("Apply to next group")
	applyPopup.ButtonPanel.Button2P5:FitToText()
	applyPopup.ButtonPanel.Button2P5:SetScript("OnClick", function()
		local resultID = searchForFirstResultID() or getNextListingFromQueue()

        if(resultID) then
            if(getNumberOfActualApplications() < 5) then
                C_LFGList.ApplyToGroup(resultID,
                    LFGListApplicationDialog.TankButton:IsShown() and LFGListApplicationDialog.TankButton.CheckButton:GetChecked(),
                    LFGListApplicationDialog.HealerButton:IsShown() and LFGListApplicationDialog.HealerButton.CheckButton:GetChecked(),
                    LFGListApplicationDialog.DamagerButton:IsShown() and LFGListApplicationDialog.DamagerButton.CheckButton:GetChecked()
                )
            else
                UIErrorsFrame:AddExternalErrorMessage("[MIOG]: Already too many active applications.");

            end
        else
            UIErrorsFrame:AddExternalErrorMessage("[MIOG]: All saved groups have been delisted.");

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

    eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
    eventReceiver:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
    eventReceiver:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
end

miog.loadReQueue = loadReQueue

local function events(_, event, ...)
    if(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
        refreshSearchResults()

	elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
        local resultID = ...

        if(C_LFGList.HasSearchResultInfo(resultID) and MIOG_NewSettings.requeueGUIDs[C_LFGList.GetSearchResultInfo(resultID).partyGUID]) then
            refreshPartyGUIDs()

        end
        
    elseif(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID, new, old, name = ...
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

        if(new == "failed") then --over the limit or already delisted
            if(C_LFGList.HasSearchResultInfo(resultID) and not searchResultInfo.isDelisted) then --checking that it's not delisted
                addPartyGUID(searchResultInfo.partyGUID, resultID) --adding to GUID list for later checks

            end
            
        elseif(new == "applied") then
            if(C_LFGList.HasSearchResultInfo(resultID) and not searchResultInfo.isDelisted) then
                deletePartyGUID(searchResultInfo.partyGUID)
            end

        elseif(new == "inviteaccepted") then --delete all data
            MIOG_NewSettings.requeueGUIDs = {}
            StaticPopupSpecial_Hide(applyPopup)

        elseif(new ~= "invited") then
            setupApplyPopup()

        end
    end
end

eventReceiver:SetScript("OnEvent", events)