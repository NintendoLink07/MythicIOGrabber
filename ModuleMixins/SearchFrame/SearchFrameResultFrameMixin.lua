local addonName, miog = ...

local MAX_NUM_SPOTS = 32

local rank = {
    ["TANK"] = 1,
    ["HEALER"] = 2,
    ["DAMAGER"] = 3,
}

local lastEntry

local improve = true

SearchFrameResultFrameMixin = {}

function SearchFrameResultFrameMixin:ImprovedClick(button)
    local resultID = self:GetData().resultID
    local searchResultInfo = miog:GetSecureSearchResultInfo(resultID)

    if(searchResultInfo and not searchResultInfo.isDelisted) then
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

    else
        return false

    end
end

function SearchFrameResultFrameMixin:OnMouseDown(button)
    if(self:ImprovedClick(button)) then
        if(button == "LeftButton") then
            local resultID = self:GetData().resultID
		    local _, appStatus = C_LFGList.GetApplicationInfo(resultID)

            if(not appStatus == "applied") then
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

local function LFGListAdvancedFiltersActivitiesNoneChecked(enabled)
	return #enabled.activities == 0;
end

local function LFGListAdvancedFiltersActivitiesAllChecked(enabled)
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
	local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE));
	local timerunningGroups = {};
	if PlayerIsTimerunning() then
		timerunningGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.Timerunning, Enum.LFGListFilter.PvE));
	end
	
	return #enabled.activities == (#seasonGroups + #expansionGroups + #timerunningGroups);
end

local function LFGListAdvancedFiltersDifficultyNoneChecked(enabled)
	return not (enabled.difficultyNormal or enabled.difficultyHeroic or enabled.difficultyMythic or enabled.difficultyMythicPlus);
end

local function LFGListAdvancedFiltersDifficultyAllChecked(enabled)
	return enabled.difficultyNormal and enabled.difficultyHeroic and enabled.difficultyMythic and enabled.difficultyMythicPlus;
end

local function LFGListAdvancedFiltersGeneralPlaystyleNoneChecked(enabled)
	return not (enabled.generalPlaystyle1 or enabled.generalPlaystyle2 or enabled.generalPlaystyle3 or enabled.generalPlaystyle4);
end

local function LFGListAdvancedFiltersGeneralPlaystyleAllChecked(enabled)
	return enabled.generalPlaystyle1 and enabled.generalPlaystyle2 and enabled.generalPlaystyle3 and enabled.generalPlaystyle4;
end

--for activities, difficulties and general playstyle, none checked and all checked are equivalent. Although visually we want to show all checked as the default.
local function LFGListAdvancedFiltersIsDefault(enabled)
	return (LFGListAdvancedFiltersActivitiesNoneChecked(enabled) or LFGListAdvancedFiltersActivitiesAllChecked(enabled))
		and (LFGListAdvancedFiltersDifficultyNoneChecked(enabled) or LFGListAdvancedFiltersDifficultyAllChecked(enabled))
		and (LFGListAdvancedFiltersGeneralPlaystyleNoneChecked(enabled) or LFGListAdvancedFiltersGeneralPlaystyleAllChecked(enabled))
		and not (enabled.needsTank or enabled.needsHealer or enabled.needsDamage or enabled.needsMyClass or enabled.hasTank or enabled.hasHealer 
				or (enabled.minimumRating ~= 0));
end

local function LFGListAdvancedFiltersCheckAllDifficulties(enabled)
	enabled.difficultyNormal = true;
	enabled.difficultyHeroic = true;
	enabled.difficultyMythic = true;
	enabled.difficultyMythicPlus = true;
end

local function LFGListAdvancedFiltersCheckAllGeneralPlaystyles(enabled)
	enabled.generalPlaystyle1 = true;
	enabled.generalPlaystyle2 = true;
	enabled.generalPlaystyle3 = true;
	enabled.generalPlaystyle4 = true;
end

local function LFGListAdvancedFiltersCheckAllDungeons(enabled)
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
	local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE));
	
	local allDungeons = {};

	tAppendAll(allDungeons, seasonGroups);
	tAppendAll(allDungeons, expansionGroups);

	if PlayerIsTimerunning() then
		local timerunningGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.Timerunning, Enum.LFGListFilter.PvE));
		tAppendAll(allDungeons, timerunningGroups);
	end

	enabled.activities = allDungeons;
end

local function EntryStillSatisfiesFilters(enabled, displayData, searchResultInfo)
	local _, classFilename = UnitClass("player");
	local infoTable = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1]);

	if enabled.needsTank and displayData["TANK"] ~= 0 then
		return false;
	elseif enabled.needsHealer and displayData["HEALER"] ~= 0 then
		return false;
	elseif enabled.needsDamage and displayData["DAMAGER"] >= 3 then
		return false;
	elseif enabled.needsMyClass and displayData[classFilename] > 0 then
		return false;
	elseif enabled.hasTank and displayData["TANK"] == 0 then
		return false;
	elseif enabled.hasHealer and displayData["HEALER"] == 0 then
		return false;
	elseif enabled.minimumRating > (searchResultInfo.leaderOverallDungeonScore or 0) then
		return false;
	elseif #enabled.activities > 0 then
		local foundActivity = false;
		for _, activityID in ipairs(enabled.activities) do
			if activityID == infoTable.groupFinderActivityGroupID then
				foundActivity = true;
				break;
			end
		end
		if not foundActivity then
			return false;
		end
	end
	if not LFGListAdvancedFiltersDifficultyNoneChecked(enabled) then
		if (infoTable.isNormalActivity and not enabled.difficultyNormal)
			or (infoTable.isHeroicActivity and not enabled.difficultyHeroic) 
			or (infoTable.isMythicActivity and not enabled.difficultyMythic)
			or (infoTable.isMythicPlusActivity and not enabled.difficultyMythicPlus) then
			return false;
		end
	end
	if not LFGListAdvancedFiltersGeneralPlaystyleNoneChecked(enabled) then
		if ((searchResultInfo.generalPlaystyle == Enum.LFGEntryGeneralPlaystyle.Learning) and not enabled.generalPlaystyle1)
			or ((searchResultInfo.generalPlaystyle == Enum.LFGEntryGeneralPlaystyle.FunRelaxed) and not enabled.generalPlaystyle2)
			or ((searchResultInfo.generalPlaystyle == Enum.LFGEntryGeneralPlaystyle.FunSerious) and not enabled.generalPlaystyle3)
			or ((searchResultInfo.generalPlaystyle == Enum.LFGEntryGeneralPlaystyle.Expert) and not enabled.generalPlaystyle4) then
			return false;
		end
	end

	return true;
end

local function IsDeclined(appStatus)
	return appStatus == "declined" or appStatus == "declined_delisted" or appStatus =="declined_full"

end

function SearchFrameResultFrameMixin:SetStatus(searchResultInfo)
    local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(searchResultInfo.searchResultID);
    local isDeclined = IsDeclined(appStatus);
    if LFGListFrame.declines then
        if not isDeclined and LFGListFrame.declines[searchResultInfo.partyGUID] then
            isDeclined = true;
            appStatus = LFGListFrame.declines[searchResultInfo.partyGUID];
        end
    end

    local isApplication = (appStatus ~= "none" or pendingStatus);
    local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus);
    local enabled = C_LFGList.GetAdvancedFilter();
    local displayData = C_LFGList.GetSearchResultMemberCounts(searchResultInfo.searchResultID);
    
    self.hasInvitation = appStatus == "invited"
    self.isTimedOut = appStatus == "timedout"
    self.isFull = appStatus == "declined_full"
    self.applicationHasBeenCancelled = appStatus == "cancelled"
    self.applicationHasBeenDeclined = appStatus == "declined"
    self.invitationHasBeenDeclined = appStatus == "invitedeclined"

    self.isNowFilteredOut = LFGListFrame.CategorySelection.selectedCategory == GROUP_FINDER_CATEGORY_ID_DUNGEONS and not EntryStillSatisfiesFilters(enabled, displayData, searchResultInfo);
    self.isApplication = isApplication and not isAppFinished;
    self.isSelected = LFGListFrame.SearchPanel.selectedResult == searchResultInfo.searchResultID and not isApplication and not searchResultInfo.isDelisted;
    self.isDelisted = searchResultInfo.isDelisted

    self.StatusFrame:Hide()

    if self.isDelisted then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("DELISTED")

    elseif self.hasInvitation then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("INVITED")

    elseif self.isFull then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("FULL")

    elseif self.applicationHasBeenDeclined then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("APP DECLINED")

    elseif self.invitationHasBeenDeclined then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("INVITE DECLINED")

    elseif self.applicationHasBeenCancelled then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("CANCELLED")

    elseif self.isTimedOut then
        self.Attention:Hide()
        self.StatusFrame:Show()
        self.StatusFrame.Text:SetText("TIMEOUT")

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

function SearchFrameResultFrameMixin:Update()
    local data = self:GetData()

    local searchResultInfo = miog:GetSecureSearchResultInfo(data.resultID)

    if(searchResultInfo) then
        self.resultID = data.resultID

        self:SetStatus(searchResultInfo)

        local activityID = searchResultInfo.activityIDs[1]
        local activityInfo = miog:GetActivityInfo(activityID)

        local isQuestCategory = activityInfo.categoryID == 1
        local isDungeonCategory = activityInfo.categoryID == 2
        local isRaidCategory = activityInfo.categoryID == 3
        local isDelveCategory = activityInfo.categoryID == 121
        local isCustomCategory = activityInfo.categoryID == 6

        if(activityInfo.horizontal) then
            self.Background:SetTexture(activityInfo.horizontal, "MIRROR", "MIRROR")

        else
            self.Background:SetColorTexture(PANEL_BACKGROUND_COLOR:GetRGBA())

        end

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

            if memberInfo and memberInfo.assignedRole then
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
                for i = ceil(searchResultInfo.numMembers / 10) * 10 - searchResultInfo.numMembers, 1, -1 do
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
end

SearchFrameQuestingResultFrameMixin = CreateFromMixins(SearchFrameResultFrameMixin)

function SearchFrameQuestingResultFrameMixin:OnLoad()
    SearchFrameResultFrameMixin.OnLoad(self)

end



SearchFrameArenaResultFrameMixin = CreateFromMixins(SearchFrameResultFrameMixin)


function SearchFrameArenaResultFrameMixin:ResetCategoryData()
    local r, g, b, a = WHITE_FONT_COLOR:GetRGBA()
    self.General.Rating:SetText("")
    self.General.Rating:SetTextColor(r, g, b, a)

    self.General.SecondaryRating:SetText("")
    self.General.SecondaryRating:SetTextColor(r, g, b, a)

end

function SearchFrameArenaResultFrameMixin:OnLoad()
    SearchFrameResultFrameMixin.OnLoad(self)

end

function SearchFrameArenaResultFrameMixin:UpdateCategoryData(searchResultInfo)
    if(searchResultInfo) then
        local pvpRatingInfo = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo[1]

        print(searchResultInfo.leaderPvpRatingInfo and #searchResultInfo.leaderPvpRatingInfo)

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