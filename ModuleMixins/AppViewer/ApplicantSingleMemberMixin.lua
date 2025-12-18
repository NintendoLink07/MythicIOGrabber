local _, miog = ...
local wticc = WrapTextInColorCode

ApplicantSingleMemberMixin = CreateFromMixins(ApplicantMixin)

function ApplicantSingleMemberMixin:RefreshExpandIcon()
	self.Expand:SetAtlas(self:GetElementData():IsCollapsed() and "campaign_headericon_closed" or "campaign_headericon_open");

end

function ApplicantSingleMemberMixin:SetCollapsed(bool)
	self:GetElementData():SetCollapsed(bool)
    self:RefreshExpandIcon()

end

function ApplicantSingleMemberMixin:OnMouseDown(button)
    if(button == "RightButton") then
        self:OnMouseDown_RightButton()

    elseif(button == "LeftButton") then
        self:GetElementData():ToggleCollapsed()
        self:RefreshExpandIcon()

    end
end

function ApplicantSingleMemberMixin:ResetWithExpandIcon()
    self:Reset()
    self:RefreshExpandIcon()
end

function ApplicantSingleMemberMixin:SetClass(fileName)
    if(fileName) then
        local classID = miog.CLASSFILE_TO_ID[fileName]
        local classColor = C_ClassColor.GetClassColor(fileName)
        local r, g, b, a = classColor:GetRGBA()

        self.Class:SetTexture(miog.CLASSES[classID].icon)

        self.Background:SetColorTexture(r, g, b, 0.4)

	    self:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=0, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1} )
        self:SetBackdropColor(0, 0, 0, 0)
        self:SetBackdropBorderColor(r, g, b, a)

    else
        self.Class:SetTexture(miog.CLASSES[100].icon)

    end
end

function ApplicantSingleMemberMixin:SetItemLevel(itemLevel)
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

function ApplicantSingleMemberMixin:SetData(data)
	self:ResetWithExpandIcon()

    self.applicantID = data.applicantID
    self.memberIdx = data.applicantIndex
    
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
    self:SetClass(data.class)
    self.Spec:SetTexture(miog.SPECIALIZATIONS[data.specID or 0].squaredIcon)

    local comment = data.comment
    self.Comment:SetShown(comment and comment ~= "")
    self.Comment:SetPoint("LEFT", self.Name, "LEFT", self.Name:GetStringWidth(), 4)
	--self.Race:SetAtlas(miog.RACES[raceID])
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
end