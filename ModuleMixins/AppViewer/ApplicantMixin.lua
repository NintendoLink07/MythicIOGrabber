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
    
    local names = data.names
    
    if(names) then
        for k, v in ipairs(names) do
            local string = k == 1 and "" or self.Players:GetText() .. ", "

            if(v.class) then
                local color = C_ClassColor.GetClassColor(v.class)
                self.Players:SetText(string .. WrapTextInColorCode(v.name, color:GenerateHexColor()))

            else
                self.Players:SetText(string .. v.name)

            end
        end
    end

    local coloredPrimary, coloredSecondary

    if(not data.primaryAlias) then
        coloredPrimary = wticc(tostring(data.primary), miog.createCustomColorForRating(data.primary):GenerateHexColor())
        coloredSecondary = wticc(tostring(data.secondary), miog.createCustomColorForRating(data.secondary):GenerateHexColor())

    else
        if(data.raidData) then
            local orderedData1 = data.raidData[1]
            local orderedData2 = data.raidData[2]

            if(orderedData1) then
                coloredPrimary = wticc(data.primaryAlias, orderedData1.isCurrent and miog.DIFFICULTY[orderedData1.difficulty].color or miog.DIFFICULTY[orderedData1.difficulty].desaturated)

            else
			    coloredPrimary = wticc("0/0", miog.DIFFICULTY[-1].color)

            end

            if(orderedData2) then
                coloredSecondary = wticc(data.secondaryAlias, orderedData1.isCurrent and miog.DIFFICULTY[orderedData2.difficulty].color or miog.DIFFICULTY[orderedData2.difficulty].desaturated)

            else
			    coloredSecondary = wticc("0/0", miog.DIFFICULTY[-1].color)

            end
        else
			coloredPrimary = wticc("0/0", miog.DIFFICULTY[-1].color)
			coloredSecondary = wticc("0/0", miog.DIFFICULTY[-1].color)

        end
    end

    self.Primary:SetText(coloredPrimary)
    self.Secondary:SetText(coloredSecondary)
    self:SetItemLevel(data.itemLevel)
end