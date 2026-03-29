local _, miog = ...
local wticc = WrapTextInColorCode

ApplicantMultiMemberMixin = CreateFromMixins(ApplicantMixin)

function ApplicantMultiMemberMixin:OnEnter()

end

function ApplicantMultiMemberMixin:SetData(data)
	self:ResetWithExpandIcon()

    local applicantData = C_LFGList.GetApplicantInfo(data.applicantID)

    if(applicantData) then
        self.Players:SetText("(" .. applicantData.numMembers .. ") ")

        for i = 1, applicantData.numMembers do
            local name, class = C_LFGList.GetApplicantMemberInfo(data.applicantID, i)
            local _, playerName, realm = miog.createFullNameValuesFrom("unitName", name)

            local string = i == 1 and self.Players:GetText() or self.Players:GetText() .. ", "

            if(class) then
                local color = C_ClassColor.GetClassColor(class)
                self.Players:SetText(string .. WrapTextInColorCode(playerName or name, color:GenerateHexColor()))

            else
                self.Players:SetText(string .. playerName or name)

            end
        end

        --[[local coloredPrimary, coloredSecondary

        if(data.categoryID ~= 3) then
            coloredPrimary = wticc(tostring(data.primary), miog.createCustomColorForRating(data.primary):GenerateHexColor())
            coloredSecondary = wticc(tostring(data.secondary), miog.createCustomColorForRating(data.secondary):GenerateHexColor())
            
        else
            coloredPrimary = "DIV"
            coloredSecondary = "DIV"

        end]]

        --self.Primary:SetText(coloredPrimary)
        --self.Secondary:SetText(coloredSecondary)
        --self:SetItemLevel(data.itemLevel)
    
        --[[else
        local numMembers = data.numMembers

        self.Players:SetText("(" .. numMembers .. ") ")

        for i = 1, numMembers do
            local playerData = data.players[i]
            local name = playerData.playerName
            local class = playerData.class

            local string = i == 1 and self.Players:GetText() or self.Players:GetText() .. ", "

            if(class) then
                local color = C_ClassColor.GetClassColor(class)
                self.Players:SetText(string .. WrapTextInColorCode(name, color:GenerateHexColor()))

            else
                self.Players:SetText(string .. name)

            end
        end]]

        self:SetInviteDeclineVisible(true, applicantData.numMembers)
    end
end