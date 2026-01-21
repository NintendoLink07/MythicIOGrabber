local addonName, miog = ...
local wticc = WrapTextInColorCode

ApplicantMixin = {}

function ApplicantMixin:OnLoad()

end

function ApplicantMixin:HasApplicantIDInfo()
    if(self.applicantID and C_LFGList.GetApplicantInfo(self.applicantID)) then
        self:GetParent().applicantID = self.applicantID
        
        return true
    end

    return false
end

function ApplicantMixin:OnMouseDown_RightButton()
    if(self:HasApplicantIDInfo()) then
        LFGListApplicantMember_OnMouseDown(self)

    end
end

function ApplicantMixin:OnEnter()
    if(self:HasApplicantIDInfo()) then
        LFGListApplicantMember_OnEnter(self)

    end
end

function ApplicantMixin:EnableLFGInteractions()
    self.Invite:Show()
    self.Decline:Show()

    self.Invite:Enable()
    self.Decline:Enable()

end

function ApplicantMixin:DisableLFGInteractions()
    self.Invite:Disable()
    self.Decline:Disable()

end

function ApplicantMixin:RefreshInviteDeclineVisiblity()
	local showLFGInteractions = LFGListUtil_IsEntryEmpowered()

    if(showLFGInteractions) then
        self:EnableLFGInteractions()
        
    else
        self:DisableLFGInteractions()

    end
end

function ApplicantMixin:Reset()
	self.StatusFrame:Hide()
    self:RefreshInviteDeclineVisiblity()

end

function ApplicantMixin:RefreshStatus(appStatus)
    if(not appStatus) then
		local applicantData = C_LFGList.GetApplicantInfo(self.applicantID)
        
        if(applicantData) then
            appStatus = applicantData.applicationStatus

        end
    end

    local disableInteractions = appStatus == "timedout" or appStatus == "cancelled" or appStatus == "failed" or appStatus == "invitedeclined" or appStatus == "inviteaccepted" or appStatus == "declined" or appStatus == "declined_full" or appStatus == "declined_delisted"

    if(disableInteractions or appStatus == "invited") then
        if(disableInteractions) then
            self:DisableLFGInteractions()

        end

        self.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[appStatus].statusString, miog.APPLICANT_STATUS_INFO[appStatus].color))
        self.StatusFrame:Show()

    elseif(appStatus == "unknown") then
        self.StatusFrame.FontString:SetText("UNKNOWN")
        self.StatusFrame:Show()
        
    else
	    self.StatusFrame:Hide()

    end
end