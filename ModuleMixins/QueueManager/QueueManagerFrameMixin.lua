local formatter = CreateFromMixins(SecondsFormatterMixin)
formatter:SetStripIntervalWhitespace(true)
formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter)

QueueManagerFrameMixin = {}

function QueueManagerFrameMixin:OnLoad()
    self.formatter = formatter

	self.CancelApplication:RegisterForClicks("LeftButtonDown")
    self.CancelApplication:SetAttribute("type", "macro")
end

function QueueManagerFrameMixin:SetTimerInfo(type, value)
    self.timerType = type

    value = value or 0

    if(self.Ticker) then
        self.Ticker:Cancel()
        self.Age:SetText(formatter:Format(value))

    end

    if(type == "add") then
        self.Ticker = C_Timer.NewTicker(1, function()
            value = value + 1
            self.Age:SetText(formatter:Format(value))

        end)
        
    elseif(type == "sub") then
        self.Ticker = C_Timer.NewTicker(1, function()
            value = value - 1
            self.Age:SetText(formatter:Format(value))

        end)
    end
end

function QueueManagerFrameMixin:SetWaitInfo(timeToMatch)
    self.Wait:SetText(timeToMatch ~= -1 and "(" .. (timeToMatch ~= -1 and formatter:Format(timeToMatch)) .. ")" or "")
end








QueueManagerLFGFrameMixin = CreateFromMixins(QueueManagerFrameMixin)

function QueueManagerLFGFrameMixin:RetrieveQueueList()
    local queuedList = GetLFGQueuedList(self.categoryID, {}) or {}
    local dungeonList = {}

    for queueID, queued in pairs(queuedList) do
        local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)
        table.insert(dungeonList, {dungeonID = queueID, name = name, difficulty = subtypeID == 1 and "Normal" or subtypeID == 2 and "Heroic"})

    end

    return dungeonList
end

function QueueManagerLFGFrameMixin:OnEnter()
    local queueID = self.queueID
    local categoryID = self.categoryID

    local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, altName, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)
    local inParty, joined, isQueued, noPartialClear, achievements, lfgComment, slotCount, categoryID2, leader, tank, healer, dps, x1, x2, x3, x4 = GetLFGInfoServer(categoryID, queueID)
    local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(categoryID, queueID)
    local activityName = activityName == self.isMultiDungeon and MULTIPLE_DUNGEONS or name

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.isMultiDungeon and MULTIPLE_DUNGEONS or activityName, 1, 1, 1, 1, true)

    if(altName and name ~= altName) then
        GameTooltip:AddLine(altName)
        
    end

    GameTooltip:AddLine(string.format(DUNGEON_DIFFICULTY_BANNER_TOOLTIP, GetDifficultyInfo(difficulty)))

    if(IsPlayerAtEffectiveMaxLevel() and minLevel == UnitLevel("player")) then
        GameTooltip:AddLine("Max level dungeon")
        
    else
        GameTooltip:AddLine(isScaling and "Scales with level (" .. string.format("%d - %d", minLevel, maxLevel) .. ")" or "Doesn't scale with level")

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
            GameTooltip:AddLine(string.format("Queued for: |cffffffff%s|r", self.formatter:Format(GetTime() - queuedTime)))
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
                GameTooltip:AddLine(string.format("~ |cffffffff%s|r", self.formatter:Format(myWait)))
            end

            if (averageWaitOk) then
                GameTooltip:AddLine(string.format("Ø |cffffffff%s|r", self.formatter:Format(averageWait)))
            end

            if (tankWaitOk) then
                GameTooltip:AddLine(string.format("|A:GO-icon-role-Header-Tank:14:14|a |cffffffff%s|r", self.formatter:Format(tankWait)))
            end

            if (healerWaitOk) then
                GameTooltip:AddLine(string.format("|A:GO-icon-role-Header-Healer:14:14|a |cffffffff%s|r", self.formatter:Format(healerWait)))
            end

            if (damageWaitOk) then
                GameTooltip:AddLine(string.format("|A:GO-icon-role-Header-DPS:14:14|a |cffffffff%s|r", self.formatter:Format(damageWait)))
            end

        end
    end
        
    if(self.isMultiDungeon) then
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

function QueueManagerApplicationFrameMixin:OnClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, self.categoryID, LFGListFrame.SearchPanel.preferredFilters or 0, LFGListFrame.baseFilters)
    LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
    LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)

end






QueueManagerPVPFrameMixin = CreateFromMixins(QueueManagerFrameMixin)

function QueueManagerPVPFrameMixin:OnEnter()
    local index = self.index
    local type = self.type

    local mapName, queuedTime, estimatedTime, role, teamSize, assignedSpec

    if(type == "battlefield") then
        _, mapName, teamSize, _, _, _, _, role = GetBattlefieldStatus(index)
        queuedTime = GetBattlefieldTimeWaited(index) / 1000
        estimatedTime = GetBattlefieldEstimatedWaitTime(index) / 1000
        assignedSpec = C_PvP.GetAssignedSpecForBattlefieldQueue(index);

    elseif(type == "world") then
        _, mapName, _, _, estimatedTime, queuedTime = GetWorldPVPQueueStatus(data.index)

    elseif(type == "openWorld") then
        mapName = GetRealZoneText()

        queuedTime = GetTime()
        estimatedTime = -1

    elseif(type == "petbattle") then
        mapName = "Pet Battle"

        local _, estimated, queued = C_PetBattles.GetPVPMatchmakingInfo()

        estimatedTime = estimated
        queuedTime = GetTime() - queued
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
        GameTooltip:AddLine(string.format("Queued for: |cffffffff%s|r", SecondsToTime(queuedTime, false, false, 1, false)))

    end

    if(estimatedTime and estimatedTime > 0) then
        GameTooltip:AddLine(string.format("Average wait time: |cffffffff%s|r", SecondsToTime(estimatedTime, false, false, 1, false)))

    end

    if(teamSize and teamSize > 0) then
        GameTooltip:AddLine(teamSize)

    end

    GameTooltip:Show()
end





QueueManagerListingFrameMixin = CreateFromMixins(QueueManagerFrameMixin)

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





QueueManagerFakeLFGFrameMixin = CreateFromMixins(QueueManagerFrameMixin)