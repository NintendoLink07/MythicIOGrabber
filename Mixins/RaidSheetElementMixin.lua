local addonName, miog = ...

local presenceColors = {
    [0] = miog.CLRSCC.gray, --unknown
    [1] = miog.CLRSCC.green, --online
    [2] = miog.CLRSCC.teal, --mobile
    [3] = miog.CLRSCC.red, --offline
    [4] = miog.CLRSCC.orange, --away
    [5] = miog.CLRSCC.yellow, --busy
}


RaidSheetElementMixin = {}

function RaidSheetElementMixin:OnLoad(classID)
    self.type = "element"
    self.align = "left"

    self:SetClassID(classID)
end

function RaidSheetElementMixin:FreeSpace()
    self.layoutIndex = self.originalIndex
    self.occupiedSpace = nil
end

function RaidSheetElementMixin:UpdatePresence()
    if(self.memberInfo) then
        self:UpdateBorder()
    end
end

function RaidSheetElementMixin:SetMemberInfo(memberInfo)
    self.memberInfo = memberInfo

    self:UpdatePresence()
end

function RaidSheetElementMixin:Reset()
    if(self.activeSpecID) then
        self.activeSpecID = nil
        self.activeRole = nil

    end

    self.SpecPicker:Hide()
    self.Spec:SetTexture(nil)

    self:FreeSpace()
    self:UpdateBorder()
end

function RaidSheetElementMixin:UpdateSpecFrames()
    self.specIDs = {}
    self.numOfSpecs = GetNumSpecializationsForClassID(self.classID)

    for i = 1, self.numOfSpecs, 1 do
        local id, name, description, icon, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(self.classID, i)

        table.insert(self.specIDs, {id = id, role = role, icon = icon})

        local specFrame = self.SpecPicker["Spec" .. i]
        specFrame:SetNormalTexture(icon)
        specFrame.id = id
        specFrame.layoutIndex = i
        specFrame:SetScript("OnClick", function(selfFrame)
            self:SetActiveSpecID(selfFrame.id)
        end)
    end

    self.SpecPicker:MarkDirty()
end

function RaidSheetElementMixin:SetActiveSpecID(specID)
    for k, v in ipairs(self.specIDs) do
        if(v.id == specID) then
            self.Spec:SetTexture(v.icon)
            self.activeSpecID = v.id
            self.activeRole = v.role

        end
    end
end

function RaidSheetElementMixin:UpdateBorder()
    self:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=1, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})

    if(self.occupiedSpace or not self.memberInfo or self.memberInfo.presence == 1 or self.memberInfo.test) then
        self:SetBackdropColor(self.color:GetRGBA())
        self:SetBackdropBorderColor(self.color.r - 0.15, self.color.g - 0.15, self.color.b - 0.15, 1)
        self.Name:SetTextColor(1, 1, 1, 1)

    else
        self:SetBackdropBorderColor(self.color.r - 0.25, self.color.g - 0.25, self.color.b - 0.25, 1)
        self.Name:SetTextColor(CreateColorFromHexString(presenceColors[self.memberInfo.presence]):GetRGBA())

        if(self.memberInfo.presence == 3) then
            self:SetBackdropColor(self.color.r, self.color.g, self.color.b, 0.25)

        elseif(self.memberInfo.presence == 4) then
            self:SetBackdropColor(self.color.r, self.color.g, self.color.b, 0.5)

        elseif(self.memberInfo.presence == 5) then
            self:SetBackdropColor(self.color.r, self.color.g, self.color.b, 0.75)

        end
    end
end

function RaidSheetElementMixin:SetClassID(classID)
    self.className = select(2, GetClassInfo(classID))
    self.classID = classID

    self.color = C_ClassColor.GetClassColor(self.className)

    self:UpdateBorder()
    self:UpdateSpecFrames()
end

function RaidSheetElementMixin:OccupySpace(spaceFrame)
    self:ClearAllPoints()
    self.layoutIndex = nil

    self:SetPoint("TOPLEFT", spaceFrame, "TOPLEFT", 1, -1)
    self:SetPoint("BOTTOMRIGHT", spaceFrame, "BOTTOMRIGHT", -1, 1)

    self.Spec:SetTexture(nil)

    self.occupiedSpace = spaceFrame

    self:UpdateBorder()
end

function RaidSheetElementMixin:OnDragStart()
    if(self.occupiedSpace) then
        self.SpecPicker:Hide()
    end

    if(not self.originalWidth and not self.originalHeight) then
        self.originalWidth = self:GetWidth()
        self.originalHeight = self:GetHeight()

    else
        self:SetSize(self.originalWidth, self.originalHeight)

    end

    self:StartMoving()
end

function RaidSheetElementMixin:OnEnter()
    if(self.occupiedSpace) then
        self.SpecPicker:Show()
    end

    if self.memberInfo then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local name = self.memberInfo.name;
		if name and self.memberInfo.timerunningSeasonID then
			name = TimerunningUtil.AddSmallIcon(name);
		end
		GameTooltip:AddLine(name);

        local guildClubID = C_Club.GetGuildClubId()

		local clubInfo = guildClubID and C_Club.GetClubInfo(guildClubID);
		if not clubInfo or clubInfo.clubType == Enum.ClubType.Guild then
			GameTooltip:AddLine(self.memberInfo.guildRank or "");
		else
			local memberRoleId = self.memberInfo.role;
			if memberRoleId then
				GameTooltip:AddLine(COMMUNITY_MEMBER_ROLE_NAMES[memberRoleId], HIGHLIGHT_FONT_COLOR:GetRGB());
			end
		end

		if self.memberInfo.level and self.memberInfo.race and self.memberInfo.classID then
			local raceInfo = C_CreatureInfo.GetRaceInfo(self.memberInfo.race);
			local classInfo = C_CreatureInfo.GetClassInfo(self.memberInfo.classID);
			if raceInfo and classInfo then
				GameTooltip:AddLine(COMMUNITY_MEMBER_CHARACTER_INFO_FORMAT:format(self.memberInfo.level, raceInfo.raceName, classInfo.className), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
			end
		end

        local status

		if self.memberInfo.presence == Enum.ClubMemberPresence.Online then
			status = FRIENDS_LIST_ONLINE

        elseif self.memberInfo.presence == Enum.ClubMemberPresence.OnlineMobile then
			status = COMMUNITIES_PRESENCE_MOBILE_CHAT

        elseif self.memberInfo.presence == Enum.ClubMemberPresence.Away then
			status = FRIENDS_LIST_AWAY

        elseif self.memberInfo.presence == Enum.ClubMemberPresence.Busy then
			status = FRIENDS_LIST_BUSY

        elseif self.memberInfo.presence == Enum.ClubMemberPresence.Busy then
			status = COMMUNITIES_PRESENCE_OFFLINE
        end
        
        if(status) then
			GameTooltip:AddLine(string.format(FRIENDS_LIST_STATUS_TOOLTIP, status));
        end

        if self.memberInfo.presence == Enum.ClubMemberPresence.Offline then
			if self.memberInfo.lastOnlineYear then
				GameTooltip:AddLine(LAST_ONLINE_COLON .. " " .. RecentTimeDate(self.memberInfo.lastOnlineYear, self.memberInfo.lastOnlineMonth, self.memberInfo.lastOnlineDay, self.memberInfo.lastOnlineHour));
			else
				GameTooltip:AddLine(COMMUNITIES_PRESENCE_OFFLINE);
			end
		elseif self.memberInfo.zone then
			GameTooltip:AddLine(self.memberInfo.zone);
		else
			GameTooltip:AddLine("");
		end

		if self.memberInfo.memberNote then
			GameTooltip:AddLine(COMMUNITY_MEMBER_NOTE_FORMAT:format(self.memberInfo.memberNote), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end

		if(clubInfo and clubInfo.clubType ~= Enum.ClubType.BattleNet and self.memberInfo.faction and (UnitFactionGroup("player") ~= PLAYER_FACTION_GROUP[self.memberInfo.faction])) then 
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip:AddLine(COMMUNITY_MEMBER_LIST_CROSS_FACTION:format(PLAYER_FACTION_BRIGHT_COLORS[self.memberInfo.faction]:GenerateHexColorMarkup() .. FACTION_LABELS[self.memberInfo.faction]), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end

		GameTooltip:Show();

    end
end

function RaidSheetElementMixin:OnLeave()
    if(self.occupiedSpace) then
        self.SpecPicker:Hide()
    end

    GameTooltip_Hide()
end