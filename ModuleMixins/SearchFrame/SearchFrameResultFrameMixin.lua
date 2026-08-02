local addonName, miog = ...

local MAX_NUM_SPOTS = 32

local rank = {
    ["TANK"] = 1,
    ["HEALER"] = 2,
    ["DAMAGER"] = 3,
}

local lastEntry

local improve = true

SearchFrameResultFrameMixin = CreateFromMixins(SearchFrameBaseFrameMixin)

function SearchFrameResultFrameMixin:ImprovedClick(button)
    local resultID = self:GetData().resultID
    local searchResultInfo = miog:GetSecureSearchResultInfo(resultID)

    if(resultID and searchResultInfo and not searchResultInfo.isDelisted) then
        if(improve) then
            local panel = LFGListFrame.SearchPanel

            if(button == "RightButton") then
                LFGListSearchEntry_CreateContextMenu(self)

            elseif(panel.selectedResult ~= resultID and LFGListSearchPanelUtil_CanSelectResult(resultID)) then
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                
            end

            LFGListSearchPanel_SelectResult(panel, self.resultID)

        else
            LFGListSearchEntry_OnClick(self, button)

        end

        return true
    end

    return false
end

function SearchFrameResultFrameMixin:OnMouseDown(button)
    if(self:ImprovedClick(button)) then
        if(button == "LeftButton") then
            local resultID = self:GetData().resultID
		    local _, appStatus = C_LFGList.GetApplicationInfo(resultID)

            if(resultID and LFGListFrame.SearchPanel.selectedResult and appStatus ~= "applied") then
                LFGListSearchPanel_SignUp(LFGListFrame.SearchPanel)

            end
        end

        if(lastEntry) then
            lastEntry:Update()

        end
            
        lastEntry = self
    end

    self:Update()
end

function SearchFrameResultFrameMixin:OnEnter()
	local resultID = self:GetData().resultID;

    local searchResultInfo = miog:GetSecureSearchResultInfo(resultID)

    if(searchResultInfo and not searchResultInfo.isDelisted) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 25, 0);
        LFGListUtil_SetSearchEntryTooltip(GameTooltip, resultID);

        local nameTable

		if(searchResultInfo.leaderName) then
			nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")

			if(nameTable and not nameTable[2]) then
				nameTable[2] = GetNormalizedRealmName()

			end

			if(nameTable[2]) then
				local countryFlag, language = miog.getRealmData(nameTable[2], miog.F.CURRENT_REGION)
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine("|T" .. countryFlag .. ":12:12|t" .. " - " .. language)
                GameTooltip:Show()
			end
		end

        if(searchResultInfo.crossFactionListing) then
            LFGListSearchPanel_EvaluateTutorial(LFGListFrame.SearchPanel, self);
        end

        if self.isNowFilteredOut or self.isApplication or not self.isSelected then
            self.Highlight:Show();
        end
    end
end



function SearchFrameResultFrameMixin:OnLoad()
	self:SetBackdrop({edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})
	self:SetBackdropBorderColor(GRAY_FONT_COLOR:GetRGBA())

end

function SearchFrameResultFrameMixin:Reset()
    self.Cancel:Hide()
    self.LeaderCrown:Hide()
    self.Activity.Expand:SetChecked(false)

    local memberParent = self.Activity.Members

    if(memberParent) then
        for i = 1, 40, 1 do
            local member = memberParent["Member"..i]
            
            if(member) then
                member.Icon:SetTexture()
                member.LeaverIcon:Hide()
                member.Border:SetTexture()
            end
        end
    end

    self:ResetCategoryData()
end

local function sortByRole(k1, k2)
    return rank[k1.assignedRole] < rank[k2.assignedRole]

end

local function sortByRoleAndSpec(k1, k2)
    local rank1, rank2 = rank[k1.assignedRole], rank[k2.assignedRole]

    if(rank1 == rank2) then
        return k1.specID > k2.specID

    end

    return rank1 < rank2

end

function SearchFrameResultFrameMixin:RefreshStatus()
    self.StatusFrame:Hide()

    if self.isDelisted then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("DELISTED")
        self.Background:SetVertexColor(1, 1, 1, 1)

    elseif self.hasInvitation then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("INVITED")
        self.Background:SetVertexColor(1, 1, 1, 1)

    elseif self.isFull then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("FULL")
        self.Background:SetVertexColor(1, 1, 1, 1)

    elseif self.applicationHasBeenDeclined then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("APP DECLINED")
        self.Background:SetVertexColor(1, 1, 1, 1)

    elseif self.invitationHasBeenDeclined then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("INVITE DECLINED")
        self.Background:SetVertexColor(1, 1, 1, 1)

    elseif self.applicationHasBeenCancelled then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("CANCELLED")
        self.Background:SetVertexColor(1, 1, 1, 1)

    elseif self.isTimedOut then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("TIMEOUT")
        self.Background:SetVertexColor(1, 1, 1, 1)

    elseif self.isNowFilteredOut then
        self.Attention:Show()
        self.Attention:SetVertexColor(ORANGE_FONT_COLOR:GetRGBA())
        self.Background:SetVertexColor(ORANGE_FONT_COLOR:GetRGBA())

    elseif self.isApplication then
        self.Attention:Show()
        self.Attention:SetVertexColor(GREEN_FONT_COLOR:GetRGBA())
        self.Background:SetVertexColor(GREEN_FONT_COLOR:GetRGBA())

    elseif self.isSelected then
        self.Attention:Show()
        self.Attention:SetVertexColor(YELLOW_FONT_COLOR:GetRGBA())
        self.Background:SetVertexColor(YELLOW_FONT_COLOR:GetRGBA())
        
    else
        self.Attention:Hide()
        self.Background:SetVertexColor(1, 1, 1, 1)

    end
end

function SearchFrameResultFrameMixin:ResetCategoryData()
    --implement in children

end

function SearchFrameResultFrameMixin:UpdateCategoryData(searchResultInfo)
    --implement in children

end

function SearchFrameResultFrameMixin:UpdateApplicationStatus()
    if(self.GetData) then
        local resultID = self:GetData().resultID
        
        local searchResultInfo = miog:GetSecureSearchResultInfo(resultID)

        if(searchResultInfo) then
            local id, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(resultID)

            self.Cancel:SetShown(appStatus == "applied")
        end
    end
end

function SearchFrameResultFrameMixin:Update()
    local data = self:GetData()

    local searchResultInfo = miog:GetSecureSearchResultInfo(data.resultID)

    if(searchResultInfo) then
        self.resultID = data.resultID

        local activityID = searchResultInfo.activityIDs[1]
        local activityInfo = miog:GetActivityInfo(activityID)

        local isQuestCategory = activityInfo.categoryID == 1
        local isDungeonCategory = activityInfo.categoryID == 2
        local isRaidCategory = activityInfo.categoryID == 3
        local isDelveCategory = activityInfo.categoryID == 121
        local isCustomCategory = activityInfo.categoryID == 6

        local declineData = LFGListFrame.declines and LFGListFrame.declines[searchResultInfo.partyGUID]
        local questTagInfo = searchResultInfo.questID and C_QuestLog.GetQuestTagInfo(searchResultInfo.questID)
        local questDesc = questTagInfo and questTagInfo.tagName
        local difficultyID = activityInfo.difficultyID
        local difficultyName = difficultyID and difficultyID ~= 0 and miog:ConvertDifficultyIDToShortName(difficultyID)

        local difficultyZoneText = difficultyID and difficultyName or questDesc

        local titleZoneColor

        if(searchResultInfo.autoAccept) then
            titleZoneColor = BLUE_FONT_COLOR

        elseif((isQuestCategory or isCustomCategory) and searchResultInfo.isWarMode) then
            titleZoneColor = YELLOW_FONT_COLOR

        elseif(declineData) then
            titleZoneColor = DULL_RED_FONT_COLOR

        else
            titleZoneColor = WHITE_FONT_COLOR

        end

        self.Activity.Name:SetText(WrapTextInColorCode((difficultyZoneText and difficultyZoneText .. " - " or "") .. (activityInfo.abbreviatedName or activityInfo.fullName), titleZoneColor:GenerateHexColor()))

        local roles = {
            ["TANK"] = 0,
            ["HEALER"] = 0,
            ["DAMAGER"] = 0,
        }

        local groupInfo = {}
        local groupHasLeaver = false

        for i = 1, searchResultInfo.numMembers, 1 do
            local memberInfo = C_LFGList.GetSearchResultPlayerInfo(data.resultID, i)

            if memberInfo and memberInfo.assignedRole and memberInfo.specName then
                local role = memberInfo.assignedRole
                memberInfo.specID = memberInfo.classFilename and memberInfo.specName and miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[memberInfo.specName .. "-" .. memberInfo.classFilename]
                tinsert(groupInfo, memberInfo)
                
                roles[role] = roles[role] + 1

                if(not groupHasLeaver) then
                    groupHasLeaver = memberInfo and memberInfo.isLeaver

                end
            end
        end

        local strings = {}

        if(groupHasLeaver) then
            tinsert(strings, "|A:groupfinder-icon-leaver:12:12|a")

        end

        if(searchResultInfo.isWarMode) then
            tinsert(strings, "|A:pvptalents-warmode-swords:12:12|a")

        end

        if(searchResultInfo.numBNetFriends > 0) then
            tinsert(strings, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\battlenetfriend.png:14|t")

        end

        if(searchResultInfo.numCharFriends > 0) then
            tinsert(strings, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\friend.png:14|t")

        end

        if(searchResultInfo.numGuildMates > 0) then
            tinsert(strings, "|TInterface\\Addons\\MythicIOGrabber\\res\\infoIcons\\guildmate.png:14|t")

        end

        tinsert(strings, searchResultInfo.name)

        self.General.Title:SetText(table.concat(strings))
        self.General.Composition:SetText("[" .. roles["TANK"] .. "||" .. roles["HEALER"] .. "||" .. roles["DAMAGER"] .. "]")

        if(not isRaidCategory) then
            local memberParent = self.Activity.Members

            if(isDungeonCategory or isDelveCategory) then
                if(roles["TANK"] == 0) then
                    tinsert(groupInfo, {
                        classFilename = "DUMMY",
                        specID = 1,
                        assignedRole = "TANK",
                        isLeaver = false,
                        atlas = GetIconForRole("TANK", true)
                    })
                    
                end

                if(roles["HEALER"] == 0) then
                    tinsert(groupInfo, {
                        classFilename = "DUMMY",
                        specID = 2,
                        assignedRole = "HEALER",
                        isLeaver = false,
                        atlas = GetIconForRole("HEALER", true)
                    })
                    
                end

                for i = 3, 1, -1 do
                    if(roles["DAMAGER"] < i) then
                        tinsert(groupInfo, {
                            classFilename = "DUMMY",
                            specID = 3,
                            assignedRole = "DAMAGER",
                            isLeaver = false,
                            atlas = GetIconForRole("DAMAGER", true)
                        })
                    end
                end
            else
                --Custom Category - Custom PVP not adding members
                --also extension calc on member add or rm

                local maxMembers = activityInfo.maxNumPlayers > 0 and activityInfo.maxNumPlayers or 5

                --ceil(searchResultInfo.numMembers / 10) * 10 - searchResultInfo.numMembers

                for i = 1 + searchResultInfo.numMembers, maxMembers, 1 do
                    tinsert(groupInfo, {
                        classFilename = "DUMMY",
                        specID = 9999,
                        assignedRole = "TANK",
                        isLeaver = false,
                        --atlas = GetIconForRole("DAMAGER", true)
                    })
                end
            end
            
            table.sort(groupInfo, sortByRoleAndSpec)
            
            for frameIndex, frame in ipairs(memberParent.memberFrames) do
                local memberInfo = groupInfo[frameIndex]

                if(memberInfo) then
                    if(memberInfo.atlas) then
                        frame.Icon:SetAtlas(memberInfo.atlas)

                    else
                        frame.Icon:SetTexture(memberInfo.icon or miog.SPECIALIZATIONS[memberInfo.specID] and miog.SPECIALIZATIONS[memberInfo.specID].squaredIcon or miog.CLASSFILE_TO_INFO[memberInfo.classFilename].icon)

                    end
                    
                    frame.LeaverIcon:SetShown(memberInfo.isLeaver)

                    if(memberInfo.classFilename ~= "DUMMY") then
                        frame.Border:SetColorTexture(miog.CLASS_COLORS[memberInfo.classFilename]:GetRGBA())

                    else
                        frame.Border:SetColorTexture(0, 0, 0, 0)

                    end

                    if(memberInfo.isLeader) then
                        self.LeaderCrown:ClearAllPoints()
                        self.LeaderCrown:SetParent(frame)
                        self.LeaderCrown:SetPoint("CENTER", frame, "TOP")
                        self.LeaderCrown:Show()

                    end

                    frame:Show()

                else
                    frame:Hide()

                end
            end
        end

        self:UpdateCategoryData(searchResultInfo)
        self:UpdateApplicationStatus()

        self:SetStatus(searchResultInfo)
    end
end






SearchFrameDungeonResultFrameMixin = CreateFromMixins(SearchFrameResultFrameMixin)

function SearchFrameDungeonResultFrameMixin:ResetCategoryData()
    local r, g, b, a = WHITE_FONT_COLOR:GetRGBA()
    self.General.Rating:SetText("")
    self.General.Rating:SetTextColor(r, g, b, a)

    self.General.SecondaryRating:SetText("")
    self.General.SecondaryRating:SetTextColor(r, g, b, a)

end

function SearchFrameDungeonResultFrameMixin:OnLoad()
    SearchFrameResultFrameMixin.OnLoad(self)

end

function SearchFrameDungeonResultFrameMixin:UpdateCategoryData(searchResultInfo)
    if(searchResultInfo) then
        self.General.Rating:SetText(searchResultInfo.leaderOverallDungeonScore or 0)

        if(searchResultInfo.leaderOverallDungeonScore and searchResultInfo.leaderOverallDungeonScore > 0) then
            self.General.Rating:SetTextColor(miog.createCustomColorForRating(searchResultInfo.leaderOverallDungeonScore):GetRGBA())

        else
            self.General.SecondaryRating:SetTextColor(GRAY_FONT_COLOR:GetRGBA())

        end

        local dungeonScoreInfo = searchResultInfo.leaderDungeonScoreInfo and searchResultInfo.leaderDungeonScoreInfo[1]

        if(dungeonScoreInfo and dungeonScoreInfo.bestRunLevel > 0) then
            self.General.SecondaryRating:SetText(dungeonScoreInfo.bestRunLevel)

            if(dungeonScoreInfo.finishedSuccess) then
                self.General.SecondaryRating:SetTextColor(GREEN_FONT_COLOR:GetRGBA())

            else
                self.General.SecondaryRating:SetTextColor(RED_FONT_COLOR:GetRGBA())

            end
        else
            self.General.SecondaryRating:SetText(0)
            self.General.SecondaryRating:SetTextColor(GRAY_FONT_COLOR:GetRGBA())

        end
    end
end






SearchFrameRaidResultFrameMixin = CreateFromMixins(SearchFrameResultFrameMixin)

function SearchFrameRaidResultFrameMixin:OnLoad()
    SearchFrameResultFrameMixin.OnLoad(self)

end

function SearchFrameRaidResultFrameMixin:ResetCategoryData()
    for k, v in ipairs(self.Activity.Bosses.bossFrames) do
        v.Border:SetTexture()
        v.Icon:SetTexture()
        v.ignoreInLayout = true
        v:Hide()
    end
end

function SearchFrameRaidResultFrameMixin:UpdateCategoryData(searchResultInfo)
    local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(searchResultInfo.searchResultID) or {}

    local activityID = searchResultInfo.activityIDs[1]
    local activityInfo = miog:GetActivityInfo(activityID)

    local bossData = activityInfo.bosses

    if(bossData) then
        local numOfBosses = #bossData

        for k, v in miog.rpairs(bossData) do
            local defeatedBossName = encounterInfo[k]
            local bossDefeated = defeatedBossName == v.name or defeatedBossName == v.altName

            local bossFrame
            
            if(numOfBosses > 10) then
                bossFrame = self.Activity.Bosses.bossFrames[20 - numOfBosses + k]

            else
                bossFrame = self.Activity.Bosses.bossFrames[10 - numOfBosses + k]

            end

            bossFrame.ignoreInLayout = nil

            bossFrame.Icon:SetDesaturated(bossDefeated)
            bossFrame.Border:SetColorTexture((bossDefeated and RED_FONT_COLOR or GREEN_FONT_COLOR):GetRGBA())
            SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, v.creatureDisplayInfoID)
            bossFrame:Show()
            
        end
    end

    local nameTable

    if(searchResultInfo.leaderName) then
        nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")

          if(nameTable and not nameTable[2]) then
            nameTable[2] = GetNormalizedRealmName()

        end

        local progressData = miog.getRaidProgress(nameTable[1], nameTable[2])

        if(progressData) then
            local orderedData1 = progressData[1]
            local orderedData2 = progressData[2]

            if(orderedData1) then
                self.General.Rating:SetText(WrapTextInColorCode(miog.getParsedProgressString(orderedData1.kills, orderedData1.bossCount), orderedData1.isCurrent and miog.DIFFICULTY[orderedData1.difficulty].color or miog.DIFFICULTY[orderedData1.difficulty].desaturated))

            end

            if(orderedData2) then
                self.General.SecondaryRating:SetText(WrapTextInColorCode(miog.getParsedProgressString(orderedData2.kills, orderedData2.bossCount), orderedData1.isCurrent and miog.DIFFICULTY[orderedData2.difficulty].color or miog.DIFFICULTY[orderedData2.difficulty].desaturated))

            else
                self.General.SecondaryRating:SetText("")
                self.General.SecondaryRating:SetTextColor(WHITE_FONT_COLOR:GetRGBA())


            end

        else
            local r, g, b, a = WHITE_FONT_COLOR:GetRGBA()
            self.General.Rating:SetText("")
            self.General.Rating:SetTextColor(r, g, b, a)

            self.General.SecondaryRating:SetText("")
            self.General.SecondaryRating:SetTextColor(r, g, b, a)

        end

    else
        local r, g, b, a = WHITE_FONT_COLOR:GetRGBA()
        self.General.Rating:SetText("")
        self.General.Rating:SetTextColor(r, g, b, a)

        self.General.SecondaryRating:SetText("")
        self.General.SecondaryRating:SetTextColor(r, g, b, a)
        
    end
end

SearchFrameQuestingResultFrameMixin = CreateFromMixins(SearchFrameResultFrameMixin)

function SearchFrameQuestingResultFrameMixin:OnLoad()
    SearchFrameResultFrameMixin.OnLoad(self)

end



SearchFramePVPResultFrameMixin = CreateFromMixins(SearchFrameResultFrameMixin)


function SearchFramePVPResultFrameMixin:ResetCategoryData()
    local r, g, b, a = WHITE_FONT_COLOR:GetRGBA()
    self.General.Rating:SetText("")
    self.General.Rating:SetTextColor(r, g, b, a)

    self.General.SecondaryRating:SetText("")
    self.General.SecondaryRating:SetTextColor(r, g, b, a)

end

function SearchFramePVPResultFrameMixin:OnLoad()
    SearchFrameResultFrameMixin.OnLoad(self)

end

function SearchFramePVPResultFrameMixin:UpdateCategoryData(searchResultInfo)
    if(searchResultInfo) then
        local pvpRatingInfo = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo[1]

        if(pvpRatingInfo and pvpRatingInfo.rating > 0) then
            self.General.Rating:SetText(pvpRatingInfo.rating)
            self.General.Rating:SetTextColor(miog.createCustomColorForRating(pvpRatingInfo.rating):GetRGBA())

        else
            self.General.Rating:SetText(0)
            self.General.Rating:SetTextColor(GRAY_FONT_COLOR:GetRGBA())

        end

        if(pvpRatingInfo and pvpRatingInfo.tier > 0) then
            self.General.SecondaryRating:SetText(pvpRatingInfo.tier)

        else
            self.General.SecondaryRating:SetText(0)
            self.General.SecondaryRating:SetTextColor(GRAY_FONT_COLOR:GetRGBA())

        end
    end
end