local addonName, miog = ...

local rank = {
    ["TANK"] = 1,
    ["HEALER"] = 2,
    ["DAMAGER"] = 3,
}

local RED_R, RED_G, RED_B, RED_A = RED_FONT_COLOR:GetRGBA()
local GREEN_R, GREEN_G, GREEN_B, GREEN_A = GREEN_FONT_COLOR:GetRGBA()

SearchFrameResultFrameMixin = CreateFromMixins(SearchFrameBaseFrameMixin)

function SearchFrameResultFrameMixin:OnMouseDown(button)
    local searchResultInfo = miog:GetSecureSearchResultInfo(self.resultID)

    if(searchResultInfo and not searchResultInfo.isDelisted) then
        LFGListSearchEntry_OnClick(self, button)

        if(LFGListFrame.SearchPanel.selectedResult) then
            LFGListSearchPanel_SignUp(LFGListFrame.SearchPanel)

        end

        self:Update()
    end
end

function SearchFrameResultFrameMixin:OnEnter()
    local searchResultInfo = miog:GetSecureSearchResultInfo(self.resultID)

    if(searchResultInfo and not searchResultInfo.isDelisted) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 25, 0);
        LFGListUtil_SetSearchEntryTooltip(GameTooltip, self.resultID);

		if(searchResultInfo.leaderName) then
            local _, realm = strsplit("-", searchResultInfo.leaderName)

			if(not realm) then
				realm = GetNormalizedRealmName()

			end

			if(realm) then
				local countryFlag, language = miog.getRealmData(realm, miog.F.CURRENT_REGION)
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip:AddLine("|T" .. countryFlag .. ":12:12|t" .. " - " .. language)
			end

             local success, reasonID = miog.filter.checkIfSearchResultIsEligible(self.resultID)

            if(not success) then
                local reason = miog.INELIGIBILITY_REASONS[reasonID]

                if(reason) then
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    GameTooltip:AddLine(WrapTextInColorCode(reason[1], miog.CLRSCC.red))

                else
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    GameTooltip:AddLine("Untracked ID", reasonID)

                end
            end

            GameTooltip:Show()
		end

        if(searchResultInfo.crossFactionListing) then
            LFGListSearchPanel_EvaluateTutorial(LFGListFrame.SearchPanel, self);
        end

        if self.isNowFilteredOut or self.isApplication or not self.isSelected then
            self.Highlight:Show()
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
        local searchResultInfo = miog:GetSecureSearchResultInfo(self.resultID)

        if(searchResultInfo) then
            local id, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(self.resultID)

            self.Cancel:SetShown(appStatus == "applied")
        end
    end
end

function SearchFrameResultFrameMixin:Update()
    local data = self:GetData()

    local searchResultInfo = miog:GetSecureSearchResultInfo(data.resultID)

    if(searchResultInfo) then
        self.Activity.Expand:SetChecked(not self:IsCollapsed())

        self.resultID = data.resultID

        local activityID = searchResultInfo.activityIDs[1]
        local activityInfo = miog:GetActivityInfo(activityID)

        local isQuestCategory = activityInfo.categoryID == 1
        local isDungeonCategory = activityInfo.categoryID == 2
        local isRaidCategory = activityInfo.categoryID == 3
        local isDelveCategory = activityInfo.categoryID == 121
        local isCustomCategory = activityInfo.categoryID == 6
        local isPVPCategory = activityInfo.categoryID == 4 or activityInfo.categoryID == 9

        local declineData = LFGListFrame.declines and LFGListFrame.declines[searchResultInfo.partyGUID]
        local questTagInfo = searchResultInfo.questID and C_QuestLog.GetQuestTagInfo(searchResultInfo.questID)
        local questDesc = questTagInfo and questTagInfo.tagName
        local difficultyID = activityInfo.difficultyID ~= 0 and activityInfo.difficultyID
        local difficultyName = difficultyID and miog:ConvertDifficultyIDToShortName(difficultyID)

        local difficultyZoneText = difficultyName or questDesc

        local titleZoneColor

        if(searchResultInfo.autoAccept) then
            titleZoneColor = BLUE_FONT_COLOR

        elseif((isQuestCategory or isCustomCategory) and searchResultInfo.isWarMode) then
            titleZoneColor = YELLOW_FONT_COLOR

        elseif(declineData) then
            titleZoneColor = DULL_RED_FONT_COLOR

        elseif(difficultyID) then
            titleZoneColor = miog:GetColorMatchingDifficultyID(difficultyID)

        elseif(isPVPCategory) then
            if(activityID == 6) then
                titleZoneColor = miog:GetColorMatchingDifficultyID(15)
                
            else
                titleZoneColor = miog:GetColorMatchingDifficultyID(16)

            end
        end

        self.Activity.Name:SetText(WrapTextInColorCode((difficultyZoneText and difficultyZoneText .. " - " or "") .. (activityInfo.abbreviatedName or activityInfo.fullName), (titleZoneColor or WHITE_FONT_COLOR):GenerateHexColor()))

        local roles = {
            ["TANK"] = 0,
            ["HEALER"] = 0,
            ["DAMAGER"] = 0,
        }

        local groupInfo = {}
        local groupHasLeaver = false

        for i = 1, searchResultInfo.numMembers, 1 do
            local memberInfo = C_LFGList.GetSearchResultPlayerInfo(self.resultID, i)

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
                local maxPlayers = activityInfo.maxNumPlayers ~= 0 and activityInfo.maxNumPlayers or (activityInfo.categoryID == 9 and 10 or activityInfo.categoryID ~= 6 and 5 or 40)

                for i = 1 + searchResultInfo.numMembers, maxPlayers, 1 do
                    tinsert(groupInfo, {
                        classFilename = "DUMMY",
                        specID = 20,
                        assignedRole = "DAMAGER",
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
    
    self.allBossFrames = {}

    for k, v in ipairs(self.Activity.BossListTop.bossFrames) do
        tinsert(self.allBossFrames, v)

    end

    for k, v in ipairs(self.Activity.BossListBottom.bossFrames) do
        tinsert(self.allBossFrames, v)
        
    end
end

function SearchFrameRaidResultFrameMixin:ResetCategoryData()
    for k, v in ipairs(self.allBossFrames) do
        v.Border:SetTexture()
        v.Icon:SetTexture()
        v:Hide()
    end
end

function SearchFrameRaidResultFrameMixin:UpdateBossVisuals(bossData)
    if(bossData) then
        local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(self.resultID)
        local defeatedEncounters = {}

        if encounterInfo then
            for i = 1, #encounterInfo do
                defeatedEncounters[encounterInfo[i]] = true
            end
        end

        local numOfBosses = #bossData
        local frameIndex = 20 - numOfBosses + 1 - (numOfBosses > 10 and 0 or 10)

        for i = 1, numOfBosses do
            local v = bossData[i]
            local bossFrame = self.allBossFrames[frameIndex]
            local bossDefeated = defeatedEncounters[v.name] or defeatedEncounters[v.altName]

            bossFrame.Icon:SetDesaturated(bossDefeated)

            if bossDefeated then
                bossFrame.Border:SetColorTexture(RED_R, RED_G, RED_B, RED_A)

            else
                bossFrame.Border:SetColorTexture(GREEN_R, GREEN_G, GREEN_B, GREEN_A)

            end
            
            SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, v.creatureDisplayInfoID)
            
            bossFrame:Show()

            frameIndex = frameIndex + 1
        end
    end
end

function SearchFrameRaidResultFrameMixin:UpdateCategoryData(searchResultInfo)
    local activityID = searchResultInfo.activityIDs[1]
    local activityInfo = miog:GetActivityInfo(activityID)

    if(not activityInfo.bosses and activityInfo.mapID > 0) then
        miog:RetrieveJournalInstanceBossData(activityInfo.journalInstanceID)

    end

    self:UpdateBossVisuals(activityInfo.bosses)

    if(searchResultInfo.leaderName) then
        local name, realm = strsplit("-", searchResultInfo.leaderName)

        if(not realm) then
            realm = GetNormalizedRealmName()

        end
        
        local raidData = miog:GetRaidTierDataViaRaiderIO(name, realm)

        if(raidData) then
            local entry1, entry2 = raidData.sortedEntries[1], raidData.sortedEntries[2]

            if(entry1) then
                local tier1NumOfBosses = miog:GetNumOfBossesForTierIndex(entry1.tierIndex)
                self.General.Rating:SetText(tier1NumOfBosses and (entry1.killedBosses .. "/" .. tier1NumOfBosses) or "")
                self.General.Rating:SetTextColor(miog.DIFFICULTY[entry1.difficulty].miogColors:GetRGBA())

            else
                self.General.Rating:SetText("")

            end

            if(entry2) then
                local tier2NumOfBosses = miog:GetNumOfBossesForTierIndex(entry2.tierIndex)
                self.General.SecondaryRating:SetText(tier2NumOfBosses and (entry2.killedBosses .. "/" .. tier2NumOfBosses) or "")
                self.General.SecondaryRating:SetTextColor(miog.DIFFICULTY[entry2.difficulty].miogColors:GetRGBA())

            else
                self.General.SecondaryRating:SetText("")

            end
        else
            self.General.Rating:SetText("")
            self.General.SecondaryRating:SetText("")

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



SearchFrameBigGroupResultFrameMixin = CreateFromMixins(SearchFrameResultFrameMixin)

function SearchFrameBigGroupResultFrameMixin:OnLoad()
    SearchFrameResultFrameMixin.OnLoad(self)
    
    self.Activity.Members.memberFrames = {}

    for k, v in ipairs(self.Activity.MemberRow1.memberFrames) do
        tinsert(self.Activity.Members.memberFrames, v)

    end

    for k, v in ipairs(self.Activity.MemberRow2.memberFrames) do
        tinsert(self.Activity.Members.memberFrames, v)
        
    end

    for k, v in ipairs(self.Activity.MemberRow3.memberFrames) do
        tinsert(self.Activity.Members.memberFrames, v)
        
    end

    for k, v in ipairs(self.Activity.MemberRow4.memberFrames) do
        tinsert(self.Activity.Members.memberFrames, v)
        
    end
end

function SearchFrameBigGroupResultFrameMixin:ResetCategoryData()
    --[[for k, v in ipairs(self.Activity.Members.memberFrames) do
        v.Border:SetTexture()
        v.Icon:SetTexture()
        v.LeaverIcon:Hide()
        v:Hide()
    end]]
end



SearchFrameRaidResultWithCompositionFrameMixin = CreateFromMixins(SearchFrameRaidResultFrameMixin)

function SearchFrameRaidResultWithCompositionFrameMixin:OnLoad()
    SearchFrameRaidResultFrameMixin.OnLoad(self)

    for i = 1, 13, 1 do
        local frame = self.Composition.classes[i]
        local classInfo = miog.CLASSES[i]

        frame.Icon:SetTexture(classInfo.icon)
        frame.Icon:SetDesaturated(true)
        frame.Border:SetColorTexture(C_ClassColor.GetClassColor(classInfo.name):GetRGBA())
        frame.Border:Hide()
        frame.Counter:SetText("")
    end
end

function SearchFrameRaidResultWithCompositionFrameMixin:Reset()
    SearchFrameRaidResultFrameMixin.Reset(self)

    for i = 1, 13, 1 do
        local frame = self.Composition.classes[i]
        frame.Icon:SetDesaturated(true)
        frame.Border:Hide()
        frame.Counter:SetText("")

    end
end

function SearchFrameRaidResultWithCompositionFrameMixin:Update()
    SearchFrameRaidResultFrameMixin.Update(self)

    local data = self:GetData()
    local searchResultInfo = miog:GetSecureSearchResultInfo(data.resultID)

    if(searchResultInfo) then
        local classMap = {
            ["WARRIOR"] = {},
            ["PALADIN"] = {},
            ["HUNTER"] = {},
            ["ROGUE"] = {},
            ["PRIEST"] = {},
            ["DEATHKNIGHT"] = {},
            ["SHAMAN"] = {},
            ["MAGE"] = {},
            ["WARLOCK"] = {},
            ["MONK"] = {},
            ["DRUID"] = {},
            ["DEMONHUNTER"] = {},
            ["EVOKER"] = {},
        }

        for i = 1, searchResultInfo.numMembers, 1 do
            local memberInfo = C_LFGList.GetSearchResultPlayerInfo(data.resultID, i)

            if memberInfo and memberInfo.specName then
                memberInfo.specID = memberInfo.classFilename and memberInfo.specName and miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[memberInfo.specName .. "-" .. memberInfo.classFilename]                

                if(memberInfo.specID and classMap[memberInfo.classFilename]) then
                    classMap[memberInfo.specID] = classMap[memberInfo.specID] and classMap[memberInfo.specID] + 1 or 1

                    local classInfo = miog:GetClassInfoFromFileName(memberInfo.classFilename)

                    if(classInfo) then
                        local frame = self.Composition.classes[classInfo.classId]
                        
                        frame.Icon:SetDesaturated(false)
                        frame.Border:Show()
                        frame.Counter:SetText(classMap[memberInfo.specID])
                    end
                end
            end
        end
    end
end

