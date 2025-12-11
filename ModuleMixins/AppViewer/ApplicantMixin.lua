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

function ApplicantMixin:SetItemLevel(itemLevel)
	local reqIlvl = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().requiredItemLevel or 0

    if(reqIlvl > itemLevel) then
		self.ItemLevel:SetText("Ø" .. wticc(miog.round(itemLevel, 1), miog.CLRSCC["red"]))

	else
		self.ItemLevel:SetText(miog.round(itemLevel, 1))
        self.ItemLevel:SetTextColor(miog.createCustomColorForItemLevel(itemLevel, 700, 730):GetRGBA())

	end
end

function ApplicantMixin:SetData(data)
    self:Reset()
    self.applicantID = data.applicantID

    local applicantData = C_LFGList.GetApplicantInfo(self.applicantID)

    self.Players:SetText("(" .. applicantData.numMembers .. ") ")

    for i = 1, applicantData.numMembers do
        local name, class = C_LFGList.GetApplicantMemberInfo(self.applicantID, i)
		local _, playerName, realm = miog.createFullNameValuesFrom("unitName", name)

        local string = i == 1 and self.Players:GetText() or self.Players:GetText() .. ", "

        if(class) then
            local color = C_ClassColor.GetClassColor(class)
            self.Players:SetText(string .. WrapTextInColorCode(playerName or name, color:GenerateHexColor()))

        else
            self.Players:SetText(string .. playerName or name)

        end
    end

    local coloredPrimary, coloredSecondary

    if(data.categoryID ~= 3) then
        coloredPrimary = wticc(tostring(data.primary), miog.createCustomColorForRating(data.primary):GenerateHexColor())
        coloredSecondary = wticc(tostring(data.secondary), miog.createCustomColorForRating(data.secondary):GenerateHexColor())
        
    else
        coloredPrimary = "DIV"
        coloredSecondary = "DIV"

    end

    --self.Primary:SetText(coloredPrimary)
    --self.Secondary:SetText(coloredSecondary)
    --self:SetItemLevel(data.itemLevel)
end