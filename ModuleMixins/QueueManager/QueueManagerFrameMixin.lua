local addonName, miog = ...

QueueManagerFrameMixin = {}

function QueueManagerFrameMixin:OnLoad()
    self.timer = C_DurationUtil.CreateDuration()

	self.CancelApplication:RegisterForClicks("LeftButtonDown")
    self.CancelApplication:SetAttribute("type", "macro")

end

--implementation in child mixins
function QueueManagerFrameMixin:SetTimerText()

end

function QueueManagerFrameMixin:SetTimerOnHold()
    self.Age:SetText("On hold")
    
end

function QueueManagerFrameMixin:SetTimerInfo(type, value1, value2)
    
end

function QueueManagerFrameMixin:SetWaitInfo(timeToMatch)
    self.Wait:SetText("(" .. SecondsToClock(timeToMatch) .. ")")

end

function QueueManagerFrameMixin:SetMacrotext()
	self.CancelApplication:SetAttribute("macrotext1", self.macrotext)

end

function QueueManagerFrameMixin:SetData(data)
    self.data = data
    self:Update()
    self:SetMacrotext()

end

function QueueManagerFrameMixin:OnHide()
    if(self.Ticker) then
        self.Ticker:Cancel()

    end

    self.timer:SetToDefaults()
    
    --[[self.Name:SetText("")
    self.Age:SetText("")
    self.Wait:SetText("")]]
end

function QueueManagerFrameMixin:SetBackground(background)
    self.Background:SetVertTile(true)
    self.Background:SetHorizTile(true)
    self.Background:SetTexture(background, "MIRROR", "MIRROR")

end








QueueManagerLFGFrameMixin = CreateFromMixins(QueueManagerFrameMixin)

function QueueManagerLFGFrameMixin:GetTimerFunction(currentTime, value)
    return function()
        if(not self.Ticker or self.Ticker:IsCancelled()) then
            self.Ticker = C_Timer.NewTicker(1, function()
                local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(self.data.categoryID, self.data.queueID)

                if(hasData) then
                    if(queuedTime and not issecretvalue(queuedTime)) then
                        value = value + 1

                        local calc = currentTime + value

                        self.timer:SetTimeSpan(queuedTime, calc)
                        self.Age:SetText(SecondsToClock(self.timer:GetElapsedDuration()))

                        local currentWait = myWait > 0 and myWait or averageWait
                        self:SetWaitInfo(currentWait)

                    end
                end
            end)
        end
    end
end

function QueueManagerLFGFrameMixin:SetTimerInfo()
    local currentTime = GetTime()
    local value = 0
    
    local timerFunc = self:GetTimerFunction(currentTime, value)

    if(not self.Ticker or self.Ticker:IsCancelled()) then
        self.Ticker = C_Timer.NewTicker(1, timerFunc)
        
    end

    timerFunc()
end

function QueueManagerLFGFrameMixin:Update()
    local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLeveKWl, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(self.data.queueID)
    local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(self.data.categoryID, self.data.queueID)

    local activityName = self.data.isMultiDungeon and MULTIPLE_DUNGEONS or name

    if(hasData) then
        if(queuedTime) then
            if(not issecretvalue(queuedTime)) then
                self:SetTimerInfo()

            end
        end

        local totalNumOfPlayers = maxPlayers - tankNeeds - healerNeeds - dpsNeeds

        if(totalNumOfPlayers > 1) then
            self.Name:SetTextColor(1, 1, 0, 1)
            activityName = "(" .. (totalNumOfPlayers / maxPlayers * 100) .. "%) " .. activityName

        end
    end

    self:SetBackground(miog:GetImageForMapID(mapID) or fileID)
	self.Name:SetText(activityName)

    self.macrotext = "/run LeaveSingleLFG(" .. self.data.categoryID .. "," .. self.data.queueID .. ")"
end

function QueueManagerLFGFrameMixin:RetrieveQueueList()
    local queuedList = GetLFGQueuedList(self.data.categoryID, {}) or {}
    local dungeonList = {}

    for queueID, queued in pairs(queuedList) do
        local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)
        table.insert(dungeonList, {dungeonID = queueID, name = name, difficulty = subtypeID == 1 and "Normal" or subtypeID == 2 and "Heroic"})

    end

    return dungeonList
end

function QueueManagerLFGFrameMixin:OnEnter()
    local queueID = self.data.queueID
    local categoryID = self.data.categoryID

    local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, altName, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)
    local inParty, joined, isQueued, noPartialClear, achievements, lfgComment, slotCount, categoryID2, leader, tank, healer, dps, x1, x2, x3, x4 = GetLFGInfoServer(categoryID, queueID)
    local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, queueID)
    local activityName = activityName == self.data.isMultiDungeon and MULTIPLE_DUNGEONS or name

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.data.isMultiDungeon and MULTIPLE_DUNGEONS or activityName, 1, 1, 1, 1, true)

    if(altName and name ~= altName) then
        GameTooltip:AddLine(altName)
        
    end

    GameTooltip:AddLine(string.format(DUNGEON_DIFFICULTY_BANNER_TOOLTIP, GetDifficultyInfo(difficulty)))

    if(IsPlayerAtEffectiveMaxLevel() and minLevel == UnitLevel("player")) then
        GameTooltip:AddLine("Max level dungeon")
        
    else
        GameTooltip:AddLine(isScalingDungeon and "Scales with level (" .. string.format("%d - %d", minLevel, maxLevel) .. ")" or "Doesn't scale with level")

    end

    GameTooltip:AddLine(string.format("%d - %d players", minPlayersDisband and minPlayersDisband > 0 and minPlayersDisband or 1, maxPlayers))

    GameTooltip_AddBlankLineToTooltip(GameTooltip)

    if(noPartialClear) then
        GameTooltip:AddLine("This will be a fresh ID.")

    else
        GameTooltip:AddLine("This group could have already killed some bosses.")

    end

    if(isTimewalker) then
        GameTooltip:AddLine(PLAYER_DIFFICULTY_TIMEWALKER)
    end

    if(isHoliday) then
        GameTooltip:AddLine(CALENDAR_FILTER_HOLIDAYS)
    end

    if(bonusRep > 0) then
        GameTooltip:AddLine(string.format(LFG_BONUS_REPUTATION, bonusRep))
        
    end

    if(hasData) then
        GameTooltip:AddLine(string.format(LFG_LIST_TOOLTIP_MEMBERS, totalTanks + totalHealers + totalDPS - tankNeeds - healerNeeds - dpsNeeds, totalTanks - tankNeeds, totalHealers - healerNeeds, totalDPS - dpsNeeds))

        if (queuedTime > 0) then
            GameTooltip:AddLine(string.format("Queued for: |cffffffff%s|r", SecondsToClock(GetTime() - queuedTime)))

        end

        local myWaitOk = myWait > 0
        local averageWaitOk = averageWait > 0
        local tankWaitOk = tankWait > 0
        local healerWaitOk = healerWait > 0
        local damageWaitOk = damageWait > 0
        
        if(myWaitOk or averageWaitOk or tankWaitOk or healerWaitOk or damageWaitOk) then
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip:AddLine("Wait times:")

            if (myWaitOk) then
                GameTooltip:AddLine(string.format("~ |cffffffff%s|r", SecondsToClock(myWait)))
            end

            if (averageWaitOk) then
                GameTooltip:AddLine(string.format("Ø |cffffffff%s|r", SecondsToClock(averageWait)))
            end

            if (tankWaitOk) then
                GameTooltip:AddLine(string.format("|A:GO-icon-role-Header-Tank:14:14|a |cffffffff%s|r", SecondsToClock(tankWait)))
            end

            if (healerWaitOk) then
                GameTooltip:AddLine(string.format("|A:GO-icon-role-Header-Healer:14:14|a |cffffffff%s|r", SecondsToClock(healerWait)))
            end

            if (damageWaitOk) then
                GameTooltip:AddLine(string.format("|A:GO-icon-role-Header-DPS:14:14|a |cffffffff%s|r", SecondsToClock(damageWait)))
            end

        end
    end
        
    if(self.data.isMultiDungeon) then
        GameTooltip_AddBlankLineToTooltip(GameTooltip)
        GameTooltip:AddLine(QUEUED_FOR_SHORT)

        local dungeonList = self:RetrieveQueueList()

        table.sort(dungeonList, function(k1, k2)
            if(k1.difficulty == k2.difficulty) then
                return k2.dungeonID > k1.dungeonID
            end

            return k2.difficulty > k1.difficulty
        end)

        for _, v in ipairs(dungeonList) do
            GameTooltip:AddLine(v.difficulty .. " " .. v.name)

        end
    end

    GameTooltip:Show()
end






QueueManagerApplicationFrameMixin = CreateFromMixins(QueueManagerFrameMixin)

function QueueManagerApplicationFrameMixin:GetTimerFunction(currentTime, value)
    return function()
        local resultID, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(self.data.resultID)

        if(appDuration and not issecretvalue(appDuration)) then
            value = value - 1

            local calc = currentTime - value

            self.timer:SetTimeFromStart(calc, appDuration)
            self.Age:SetText(SecondsToClock(self.timer:GetRemainingDuration()))

        end
    end
end

function QueueManagerApplicationFrameMixin:SetTimerInfo()
    local currentTime = GetTime()
    local value = 0

    local timerFunc = self:GetTimerFunction(currentTime, value)

    if(not self.Ticker or self.Ticker:IsCancelled()) then
        self.Ticker = C_Timer.NewTicker(1, timerFunc)
        
    end

    timerFunc()
end

function QueueManagerApplicationFrameMixin:Update()
    local searchResultInfo = C_LFGList.GetSearchResultInfo(self.data.resultID)

    if(not issecrettable(searchResultInfo)) then
        local activityInfo = miog:GetActivityInfo(searchResultInfo.activityIDs[1])

        self.categoryID = activityInfo.categoryID

        local activityName = searchResultInfo.name .. " - " .. (WrapTextInColorCode(activityInfo.fullName or "", CreateColor(1, 0.82, 0):GenerateHexColor()))

        local eligible, reasonID = miog.filter.checkIfSearchResultIsEligible(self.data.resultID, true)
        local reason = miog.INELIGIBILITY_REASONS[reasonID]

        if(eligible or not reason) then
            self.Name:SetTextColor(1, 1, 1, 1)
            self.Name:SetText(activityName)

        elseif(self.Name:GetText()) then
            self.Name:SetTextColor(1, 0, 0, 1)
            self.Name:SetText(activityName .. " - " .. reason[2])

        end

        self.Wait:Hide()

        --if(isFakeApp) then
            --self:SetAlpha(0.5)
            --self:SetTimerInfo(true)
            --self.macrotext = "idkwhatilldoherebutillfigureitout"

        --else
            self.macrotext = "/run C_LFGList.CancelApplication(" .. self.data.resultID .. ")"
            self:SetTimerInfo()

        --end

        self:SetBackground(activityInfo.horizontal)
    end
end

function QueueManagerApplicationFrameMixin:OnEnter()
    miog.createResultTooltip(self.data.resultID, self)

end

function QueueManagerApplicationFrameMixin:OnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, self.categoryID, LFGListFrame.SearchPanel.preferredFilters or 0, LFGListFrame.baseFilters)
    LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
    LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)

end






QueueManagerPVPFrameMixin = CreateFromMixins(QueueManagerFrameMixin)

function QueueManagerPVPFrameMixin:GetBattlefieldTimerFunction()
    return function()
        local queuedTime = GetBattlefieldTimeWaited(self.data.index) / 1000

        if(queuedTime and not issecretvalue(queuedTime)) then
            self.timer:SetTimeFromStart(GetTime(), queuedTime)
            self.Age:SetText(SecondsToClock(self.timer:GetRemainingDuration()))

        end
    end
end

function QueueManagerPVPFrameMixin:GetWorldPVPTimerFunction()
    return function()
        local _, _, _, _, _, queuedTime = GetWorldPVPQueueStatus(self.data.index)

        if(queuedTime and not issecretvalue(queuedTime)) then
            self.timer:SetTimeFromStart(GetTime(), queuedTime)
            self.Age:SetText(SecondsToClock(self.timer:GetRemainingDuration()))

        end
    end
end

function QueueManagerPVPFrameMixin:GetPetBattleTimerFunction()
    return function()
        local _, _, queuedTime = C_PetBattles.GetPVPMatchmakingInfo()

        if(queuedTime and not issecretvalue(queuedTime)) then
            self.timer:SetTimeFromStart(GetTime(), queuedTime)
            self.Age:SetText(SecondsToClock(self.timer:GetRemainingDuration()))

        end
    end
end

function QueueManagerPVPFrameMixin:GetPlunderstormTimerFunction()
    return function()
        local queuedTime = C_LobbyMatchmakerInfo.GetQueueStartTime();

        if(queuedTime and not issecretvalue(queuedTime)) then
            self.timer:SetTimeFromStart(GetTime(), queuedTime)
            self.Age:SetText(SecondsToClock(self.timer:GetRemainingDuration()))

        end
    end
end

function QueueManagerPVPFrameMixin:SetTimerInfo(type)
    if(not self.Ticker or self.Ticker:IsCancelled()) then
        self.Ticker = C_Timer.NewTicker(1,
            type == "battlefield" and self:GetBattlefieldTimerFunction() or
            type == "world" and self:GetWorldPVPTimerFunction() or
            type == "petbattle" and self:GetPetBattleTimerFunction() or
            type == "plunderstorm" and self:GetPlunderstormTimerFunction() or
            function() end
        )

    end
end

function QueueManagerPVPFrameMixin:Update()
    local status, mapName

    local timeInQueue, timeToMatch

    if(self.data.type == "battlefield") then
        status, mapName = GetBattlefieldStatus(self.data.index);
        self.macrotext = "/click QueueStatusButton RightButton"
        self.type = "battlefield"

        if(status and status ~= "none" and status ~= "error") then
            self:SetTimerInfo("battlefield")
            self:SetWaitTime(GetBattlefieldEstimatedWaitTime(self.data.index) / 1000)

            self:SetBackground(miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/pvpbattleground.png")

        end

    elseif(self.data.type == "world") then
        local queueID, averageWaitTime, queuedTime

        status, mapName, queueID, _, averageWaitTime, queuedTime = GetWorldPVPQueueStatus(self.data.index)
        self.macrotext = "/run BattlefieldMgrExitRequest(" .. queueID .. ")"
        self:SetTimerInfo("world")
        self:SetWaitTime(averageWaitTime)
        self.type = "world"

        timeInQueue = GetTime() - queuedTime
        timeToMatch = averageWaitTime

    elseif(self.data.type == "openworld") then
        self.type = "openworld"
        self.macrotext = "/run HearthAndResurrectFromArea()"
        self.Age:SetText("")
        mapName = GetRealZoneText()

        timeInQueue = GetTime()
        timeToMatch = -1

    elseif(self.data.type == "petbattle") then
        self.type = "petbattle"
        self.macrotext = "/run C_PetBattles.StopPVPMatchmaking()"

        local _, estimated, queuedTime = C_PetBattles.GetPVPMatchmakingInfo()
        self:SetTimerInfo("petbattle")
        self:SetWaitTime(estimated)
        mapName = "Pet Battle"


        --timeToMatch = estimated
        --timeInQueue = GetTime() - queuedTime

        self:SetBackground("interface/petbattles/petbattlesqueue.blp")

    elseif(self.data.type == "plunderstorm") then
        --local queueTime = C_LobbyMatchmakerInfo.GetQueueStartTime();

        self.macrotext = "/run C_LobbyMatchmakerInfo.AbandonQueue()"
        self:SetTimerInfo("plunderstorm")
        mapName = WOW_LABS_PLUNDERSTORM_CATEGORY
        --timeInQueue = GetTime() - queueTime
    
    end

    self.Name:SetText(mapName)
    self.Wait:Show()
end

function QueueManagerPVPFrameMixin:SetTimerText()
    self.Age:SetText(SecondsToClock(self.timer:GetRemainingDuration()))

end

function QueueManagerPVPFrameMixin:OnEnter()
    local index = self.data.index
    local type = self.type

    local mapName, queuedTime, estimatedTime, role, teamSize, assignedSpec

    if(type == "battlefield") then
        _, mapName, teamSize, _, _, _, _, role = GetBattlefieldStatus(index)
        queuedTime = GetBattlefieldTimeWaited(index) / 1000
        estimatedTime = GetBattlefieldEstimatedWaitTime(index) / 1000
        assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(index);

    elseif(type == "world") then
        _, mapName, _, _, estimatedTime, queuedTime = GetWorldPVPQueueStatus(self.data.index)

    elseif(type == "openWorld") then
        mapName = GetRealZoneText()

        queuedTime = GetTime()
        estimatedTime = -1

    elseif(type == "petbattle") then
        mapName = "Pet Battle"

        local _, estimated, queued = C_PetBattles.GetPVPMatchmakingInfo()

        estimatedTime = estimated
        queuedTime = GetTime() - queued

    else
        mapName = ""

    end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(mapName, 1, 1, 1, 1, true)

    if(role and role ~= "") then
        GameTooltip:AddLine(LFG_TOOLTIP_ROLES .. " " .. string.lower(role):gsub("^%l", string.upper))

    end

    if(assignedSpec) then
        local id, name, description, icon, role, classFile, className = GetSpecializationInfoByID(assignedSpec)
        GameTooltip:AddLine(ASSIGNED_COLON .. " " .. name)

    end
    
    GameTooltip_AddBlankLineToTooltip(GameTooltip)

    if(queuedTime and queuedTime > 0) then
        GameTooltip:AddLine(string.format("Queued for: |cffffffff%s|r", SecondsToClock(queuedTime)))

    end

    if(estimatedTime and estimatedTime > 0) then
        GameTooltip:AddLine(string.format("Average wait time: |cffffffff%s|r", SecondsToClock(estimatedTime)))

    end

    if(teamSize and teamSize > 0) then
        GameTooltip:AddLine(teamSize)

    end

    GameTooltip:Show()
end





QueueManagerListingFrameMixin = CreateFromMixins(QueueManagerFrameMixin)

function QueueManagerListingFrameMixin:GetTimerFunction(currentTime, value)
    return function()
        if(C_LFGList.HasActiveEntryInfo()) then
            local activeEntryInfo = C_LFGList.GetActiveEntryInfo()

            if(activeEntryInfo.duration and not issecretvalue(activeEntryInfo.duration)) then
                value = value - 1

                local calc = currentTime - value

                self.timer:SetTimeFromStart(calc, activeEntryInfo.duration)
                self.Age:SetText(SecondsToClock(self.timer:GetRemainingDuration()))

            end
        end
    end
end

function QueueManagerListingFrameMixin:SetTimerInfo()
    local currentTime = GetTime()
    local value = 0
    
    local timerFunc = self:GetTimerFunction(currentTime, value)

    if(not self.Ticker or self.Ticker:IsCancelled()) then
        self.Ticker = C_Timer.NewTicker(1, timerFunc)
        
    end

    timerFunc()
end

function QueueManagerListingFrameMixin:Update()
    local activeEntryInfo = C_LFGList.GetActiveEntryInfo()

    if(activeEntryInfo) then
        local activityInfo = miog:GetActivityInfo(activeEntryInfo.activityIDs[1])

        if(activityInfo) then
            local unitName, unitID = miog:GetGroupLeader()
            self:SetBackground(activityInfo.horizontal or activityInfo.groupFinderActivityGroupID == 0 and miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dungeon.png")

            local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants()
            self.Name:SetText((unitID == "player" and "Your Listing" or ((unitName or "Unknown") .. "'s Listing")) .. " (" .. numActiveApplicants .. ")")
            
        end

        self:SetTimerInfo()

        self.Wait:Hide()
        self.macrotext = "/run C_LFGList.RemoveListing() LFGListEntryCreation_SetEditMode(LFGListFrame.EntryCreation, false)"
    end
end

function QueueManagerListingFrameMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)

end

function QueueManagerListingFrameMixin:OnEnter()
    local activeEntryInfo = C_LFGList.GetActiveEntryInfo()

    if(activeEntryInfo) then
        local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants()
        self.BackgroundHover:Show()
        
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(string.format(LFG_LIST_PENDING_APPLICANTS, numActiveApplicants))

        if(activeEntryInfo.questID and activeEntryInfo.questID > 0) then
            GameTooltip:AddLine(LFG_TYPE_QUEST .. ": " .. C_QuestLog.GetTitleForQuestID(activeEntryInfo.questID))
            
        end

        GameTooltip:Show()

    end
end

function QueueManagerListingFrameMixin:OnShow()
	self.CancelApplication:SetShown(UnitIsGroupLeader("player"))

end




QueueManagerFakeLFGFrameMixin = CreateFromMixins(QueueManagerFrameMixin)