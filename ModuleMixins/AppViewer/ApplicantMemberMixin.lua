local addonName, miog = ...
local wticc = WrapTextInColorCode

ApplicantMemberMixin = {}

function ApplicantMemberMixin:SetCollapsed(bool)
	self:GetElementData():SetCollapsed(bool)
	self.Expand:SetAtlas(self:GetElementData():IsCollapsed() and "campaign_headericon_closed" or "campaign_headericon_open");

end

function ApplicantMemberMixin:OnMouseDown(button, ...)
	self:GetElementData():ToggleCollapsed()
	self.Expand:SetAtlas(self:GetElementData():IsCollapsed() and "campaign_headericon_closed" or "campaign_headericon_open");
end

function ApplicantMemberMixin:OnLoad()

end

function ApplicantMemberMixin:OnEnter()
    if(self.applicantID) then
        if(C_LFGList.GetApplicantInfo(self.applicantID)) then
            self:GetParent().applicantID = self.applicantID
            LFGListApplicantMember_OnEnter(self)

        end
    end
end

function ApplicantMemberMixin:RefreshStatus(status)
    if(not status) then
		local applicantData = C_LFGList.GetApplicantInfo(self.applicantID)
        
        if(applicantData) then
            status = applicantData.applicationStatus

        end
    end

    if(status == "timedout" or status == "cancelled" or status == "failed" or status == "invitedeclined" or status == "invited" or status == "inviteaccepted") then
        self.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[status].statusString, miog.APPLICANT_STATUS_INFO[status].color))
        self.StatusFrame:Show()

    else
	    self.StatusFrame:Hide()

    end
end

function ApplicantMemberMixin:Reset()
    self:RefreshStatus()
	self.Expand:SetAtlas(self:GetElementData():IsCollapsed() ~= false and "campaign_headericon_closed" or "campaign_headericon_open");

end

function ApplicantMemberMixin:SetClass(fileName)
    if(fileName) then
        local classID = miog.CLASSFILE_TO_ID[fileName]
        local classColor = C_ClassColor.GetClassColor(fileName)

        local r, g, b, a = classColor:GetRGBA()

        self.Class:SetTexture(miog.CLASSES[classID].icon)

        self.Background:SetColorTexture(r, g, b, 0.4)

	    self:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=0, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
        self:SetBackdropColor(0, 0, 0, 0)
        self:SetBackdropBorderColor(classColor:GetRGBA())
    else
        self.Class:SetTexture(miog.CLASSES[100].icon)

    end
end

function ApplicantMemberMixin:SetItemLevel(itemLevel)
    if(itemLevel) then
        local reqIlvl = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().requiredItemLevel or 0

        if(reqIlvl > itemLevel) then
            self.ItemLevel:SetText(wticc(miog.round(itemLevel, 1), miog.CLRSCC["red"]))

        else
            self.ItemLevel:SetText(miog.round(itemLevel, 1))
            self.ItemLevel:SetTextColor(miog.createCustomColorForItemLevel(itemLevel, 700, 730):GetRGBA())

        end
    end
end

function ApplicantMemberMixin:SetInviteDeclineStatus()
    local visible = C_PartyInfo.CanInvite()

    self.Invite:SetShown(visible)
    self.Decline:SetShown(visible)
end

function ApplicantMemberMixin:SetData(data)
    self.applicantID = data.applicantID
    self.memberIdx = data.applicantIndex

	self:Reset()

    local comment = data.comment
    
    local name, class, localizedClass, level, itemLevel, honorlevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, faction, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(self.applicantID, self.memberIdx)


    local fullName, playerName = miog.createFullNameValuesFrom("unitName", name)

    local nameTable = {}

	if(isLeaver) then
		tinsert(nameTable, "|A:groupfinder-icon-leaver:12:12|a")

	end

	if(relationship) then
		tinsert(nameTable, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\friend.png:14|t")

	end

	tinsert(nameTable, name)

    name = table.concat(nameTable)

    self.Name:SetText(data.playerName or playerName or name)
    --self.Level:SetText(level)
    self:SetClass(data.class)
    self.Spec:SetTexture(miog.SPECIALIZATIONS[data.specID or 0].squaredIcon)
    self.Comment:SetShown(comment and comment ~= "")
    self.Comment:SetPoint("LEFT", self.Name, "LEFT", self.Name:GetStringWidth(), 4)
	self.Race:SetAtlas(miog.RACES[raceID])
	self.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. (assignedRole or "DAMAGER") .. "Icon.png")

    local coloredPrimary, coloredSecondary

    if(data.categoryID ~= 3) then
        coloredPrimary = wticc(tostring(data.primary), miog.createCustomColorForRating(data.primary):GenerateHexColor())
        coloredSecondary = wticc(tostring(data.secondary), miog.createCustomColorForRating(data.secondary):GenerateHexColor())
        
    else
        coloredPrimary, coloredSecondary = miog.getColoredAliasFromRaidProgress(data.raidData)

    end

    self.Primary:SetText(coloredPrimary)
    self.Secondary:SetText(coloredSecondary)

    self:SetItemLevel(itemLevel)

    self:SetInviteDeclineStatus(data.multi)
end