QueueBufferMixin = {}

function QueueBufferMixin:OnLoad()
    self.queue = {}
    self:SetSize(LFGListApplicationDialog:GetSize())

end

function QueueBufferMixin:OnEvent(event, ...)
    if(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID, appStatus, oldStatus = ...

        if(C_LFGList.HasSearchResultInfo(resultID)) then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
            
            if(searchResultInfo.isDelisted or appStatus == "applied") then
                self.queue[searchResultInfo.partyGUID] = nil

                print("DELETED", searchResultInfo.name, resultID)
                
            elseif(not searchResultInfo.isDelisted and appStatus == "failed" and oldStatus == "none") then
                self.queue[searchResultInfo.partyGUID] = {timestamp = GetTime()}

                print("QUEUED", searchResultInfo.name, resultID)

            end
        end
    elseif(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
        self.isDirty = false

    end
end