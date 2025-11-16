local addonName, miog = ...
local wticc = WrapTextInColorCode

ApplicantMemberMixin = {}

function ApplicantMemberMixin:SetCollapsed(bool)
    self.node:SetCollapsed(bool)
	self.Expand:SetAtlas(self.node:IsCollapsed() and "campaign_headericon_closed" or "campaign_headericon_open");

end

function ApplicantMemberMixin:OnMouseDown(button, ...)
    MIOG_T = self
	self.node:ToggleCollapsed()
	self.Expand:SetAtlas(self.node:IsCollapsed() and "campaign_headericon_closed" or "campaign_headericon_open");
end

function ApplicantMemberMixin:OnLoad()
    
end

function ApplicantMemberMixin:OnEnter()
    if(self.applicantID) then
        self:GetParent().applicantID = self.applicantID
        LFGListApplicantMember_OnEnter(self)

    end
end

function ApplicantMemberMixin:Reset()
	self.StatusFrame:Hide()

end

function ApplicantMemberMixin:SetStatus(status)
    self.StatusFrame.FontString:SetText(wticc(miog.APPLICANT_STATUS_INFO[status].statusString, miog.APPLICANT_STATUS_INFO[status].color))
    self.StatusFrame:Show()

end

function ApplicantMemberMixin:SetClass(fileName)
    local classID = miog.CLASSFILE_TO_ID[fileName]
    local classColor = C_ClassColor.GetClassColor(fileName)

    self.Name:SetTextColor(classColor:GetRGBA())
    self.Class:SetTexture(miog.CLASSES[classID].icon)
end

function ApplicantMemberMixin:SetItemLevel(itemLevel)
	local reqIlvl = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().requiredItemLevel or 0

    if(reqIlvl > itemLevel) then
		self.ItemLevel:SetText(wticc(miog.round(itemLevel, 1), miog.CLRSCC["red"]))

	else
		self.ItemLevel:SetText(miog.round(itemLevel, 1))

	end
end

function ApplicantMemberMixin:SetInternalData(name, level, class, specID, comment, raceID, assignedRole, primary, secondary, primary2, secondary2, itemLevel, relationship, isLeaver)
	self:Reset()
        
	local nameTable = {}

	if(isLeaver) then
		tinsert(nameTable, "|A:groupfinder-icon-leaver:12:12|a")

	end

	if(relationship) then
		tinsert(nameTable, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\friend.png:14|t")

	end

	tinsert(nameTable, name)

    name = table.concat(nameTable)

    self.Name:SetText(name)
    --self.Level:SetText(level)
    self:SetClass(class)
    self.Spec:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
    self.Comment:SetShown(comment ~= "")
    self.Comment:SetPoint("LEFT", self.Name, "LEFT", self.Name:GetStringWidth(), 4)
	self.Race:SetAtlas(miog.RACES[raceID])
	self.Role:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. assignedRole .. "Icon.png")
    self.Primary:SetText(primary2 or primary)
    self.Secondary:SetText(secondary2 or secondary)

    self:SetItemLevel(itemLevel)

    self:SetInviteDeclineStatus()
end

function ApplicantMemberMixin:SetInviteDeclineStatus()
    local visible = not self.data.multi

    self.Invite:SetShown(visible)
    self.Decline:SetShown(visible)
end

function ApplicantMemberMixin:SetData(data)
    local applicantID = data.applicantID
    local applicantIndex = data.applicantIndex
    local comment = data.comment
    
    local name, class, localizedClass, level, itemLevel, honorlevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, faction, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)


    self.data = data
    self.applicantID = applicantID

    self:SetInternalData(name, level, class, specID, comment, raceID, assignedRole, data.primary, data.secondary, data.primary2, data.secondary2, data.itemLevel, relationship, isLeaver)
end

function ApplicantMemberMixin:SetDebugData(data)
    self.data = data

    self:SetInternalData(data.name, data.level, data.fileName, data.specID, data.comment, data.raceID, data.assignedRole, data.primary, data.secondary, data.primary2, data.secondary2, data.itemLevel, true, true)

end