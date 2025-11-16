local addonName, miog = ...
local wticc = WrapTextInColorCode

ApplicantMixin = {}

function ApplicantMixin:OnLoad()

end

function ApplicantMixin:EnableLFGInteractions()
    self.Invite:Enable()
    self.Decline:Enable()

end

function ApplicantMixin:DisableLFGInteractions()
    self.Invite:Disable()
    self.Decline:Disable()

end

function ApplicantMixin:Reset()
	self.StatusFrame:Hide()
    self:EnableLFGInteractions()

end

function ApplicantMixin:SetStatus(status)
    self.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[status].statusString, miog.APPLICANT_STATUS_INFO[status].color))
    self.StatusFrame:Show()

    if(status == "timedout" or status == "cancelled" or status == "failed" or status == "invitedeclined") then
        self:DisableLFGInteractions()

    end
end

function ApplicantMixin:SetData(data)
    self:Reset()
    self.applicantID = data.applicantID
    

    local names = data.names
    
    if(names) then
        self.Players:SetText(IMPORTANT_PEOPLE_IN_GROUP)

        for k, v in ipairs(names) do
            local lastString = self.Players:GetText() .. (k == 1 and " " or ", ")
            local color = C_ClassColor.GetClassColor(v.class)
            self.Players:SetText(lastString .. WrapTextInColorCode(v.name, color:GenerateHexColor()))

        end
    end
end