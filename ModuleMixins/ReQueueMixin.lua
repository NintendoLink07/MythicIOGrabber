ReQueueMixin = {}

function ReQueueMixin:GetAllPartyGUIDs()
    return self.guidList
    
end

function ReQueueMixin:OnLoad()
    self.guidList = {}
    self.localID = 0
    self.isDirty = false

    self:SetSize(LFGListApplicationDialog:GetSize())
    
    self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
    self:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

end

function ReQueueMixin:AddGUID(guid)
    self.localID = self.localID + 1

    self.guidList[guid] = {resultID = resultID, applyTimestamp = GetTime(), id = self.localID}

    self.isDirty = true
end

function ReQueueMixin:RemoveGUID(guid)
    self.guidList[guid] = nil

end

function ReQueueMixin:GetNextPartyInfo()
    local nextInfo, nextGUID
    local lastCounter = math.huge

    for guid, info in pairs(self.guidList) do
        if(info.id < lastCounter) then
            nextInfo = info
            nextGUID = guid

        end

    end

    return nextInfo, nextGUID
end

function ReQueueMixin:CountActualApplications()
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

function ReQueueMixin:CountPartyGUIDs()
    local numOfGroups = 0

    for _ in pairs(self.guidList) do
        numOfGroups = numOfGroups + 1

    end

    return numOfGroups
end

function ReQueueMixin:HasGUID()
    for _ in pairs(self.guidList) do
        return true

    end

    return false
end

function ReQueueMixin:CanQueueNextApplication()
    if(self:CountActualApplications() == 5) then
        UIErrorsFrame:AddExternalErrorMessage("[MIOG]: Too many active applications.");
        return false

    elseif(not self:HasGUID()) then
        UIErrorsFrame:AddExternalErrorMessage("[MIOG]: No more groups to apply to.");
        return false

    end

    return true
end

function ReQueueMixin:SetupNextGUID()
    local info, guid = self:GetNextPartyInfo()

    if(info) then
        local resultID = info.resultID

        if(resultID and C_LFGList.HasSearchResultInfo(resultID)) then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
            local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1])
            local categoryInfo = C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID)

            local stringTable = {}

            local activityName = ""
            
            if(activityInfo.categoryID) then
                local categoryInfo = C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID)

                tinsert(stringTable, categoryInfo.name .. ":")
                tinsert(stringTable, ":")
            end

            if(activityInfo.icon) then
                tinsert(stringTable, " |T")
                tinsert(stringTable, activityInfo.icon)
                tinsert(stringTable, ":12:12|t ")

            end

            tinsert(stringTable, searchResultInfo.name)
            tinsert(stringTable, " - ")
            tinsert(stringTable, (activityInfo.mapName or ""))

            self.ActivityText:SetText(table.concat(stringTable))
            self.BacklogText:SetText("Applications in your backlog: " .. self:CountPartyGUIDs())

            self.currentResultID = resultID
            self.ApplyButton:SetShown(not self.isDirty)
            self.RefreshButton:SetShown(self.isDirty)
            
            StaticPopupSpecial_Show(self)
        else
            self:RemoveGUID(guid)
            self:SetupNextGUID()

        end
    end
end

function ReQueueMixin:OnEvent(event, ...)
    if(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID, appStatus, oldStatus = ...

        if(C_LFGList.HasSearchResultInfo(resultID)) then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
            local needsUpdate = false

            if(not searchResultInfo.isDelisted and appStatus == failed and oldStatus == "none") then
                self:AddGUID(guid)
                needsUpdate = true

            elseif(searchResultInfo.isDelisted or appStatus == "applied") then
                self:RemoveGUID(guid)
                needsUpdate = true

            end
        end

        if(self:CanQueueNextApplication()) then
            self:SetupNextGUID()

            needsUpdate = true
        end

        if(needsUpdate and not InCombatLockdown()) then
            QueueStatusFrame:Update()

        end
    elseif(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
        self.isDirty = false

    end
end