local addonName, miog = ...

local regex1 = "%d+ %w+ damage"
local regex2 = "%d+ damage"

local currentParent = nil

local parentsBefore = {}
local idsProcessed = {}
local framePool

local function resetJournalFrames(_, frame)
    frame:Hide()
    frame.layoutIndex = nil
    frame.Name:SetText("")
    frame.Icon:SetTexture(nil)
    frame.ExpandFrame:Show()

    frame.DetailedInformation.LFR.Name:SetText()
    frame.DetailedInformation.LFR.Description:SetText()

    frame.DetailedInformation.Normal.Name:SetText()
    frame.DetailedInformation.Normal.Description:SetText()

    frame.DetailedInformation.Heroic.Name:SetText()
    frame.DetailedInformation.Heroic.Description:SetText()

    frame.DetailedInformation.Mythic.Name:SetText()
    frame.DetailedInformation.Mythic.Description:SetText()
end

local function setDifficultyFrameData(difficultyID, sectionID, frame)
    local difficultyString = difficultyID == 14 and "Normal" or difficultyID == 15 and "Heroic" or difficultyID == 16 and "Mythic" or difficultyID == 17 and "LFR"
    EJ_SetDifficulty(difficultyID)
    local info = C_EncounterJournal.GetSectionInfo(sectionID)
    local text = not info.filteredByDifficulty and info.description
    frame.DetailedInformation[difficultyString].Description:SetText((frame.DetailedInformation[difficultyString].Description:GetText() == nil) and text or frame.DetailedInformation[difficultyString].Description:GetText())
    
    local showExpand = frame.DetailedInformation[difficultyString].Description:GetText() ~= nil

    frame.DetailedInformation[difficultyString]:SetHeight(showExpand and 70 or 20)
    frame.DetailedInformation:MarkDirty()
    
    return showExpand
end

miog.selectInstance = function(journalInstanceID)
    EJ_SelectInstance(journalInstanceID)
    EJ_SetDifficulty(14)

    local bossTable = {}
    local firstBossID = nil

    miog.AdventureJournal.BossDropdown:ResetDropDown()

    for i = 1, 50, 1 do
        local info = {}
        --info.icon = miog.ACTIVITY_INFO[activityID].icon
        local name, description, journalEncounterID, rootSectionID, link, journalInstanceID2, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(i, journalInstanceID)

        if(name) then
            info.index = i
            info.entryType = "option"
            info.text = name
            info.value = journalEncounterID
            info.func = function()
                miog.selectBoss(journalInstanceID, i)
                --LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.filters, categoryID, v, activityID)

            end

            if(#bossTable == 0) then
                firstBossID = journalEncounterID

            end

            bossTable[#bossTable+1] = info
        end
    end

	for k, v in ipairs(bossTable) do
		miog.AdventureJournal.BossDropdown:CreateEntryFrame(v)

	end

    miog.AdventureJournal.BossDropdown.List:MarkDirty()

    miog.selectBoss(journalInstanceID, 1)
    miog.AdventureJournal.BossDropdown:SelectFirstFrameWithValue(firstBossID)
end

miog.selectBoss = function(journalInstanceID, bossIndex)
    framePool:ReleaseAll()
    --local dataProvider = CreateDataProvider()
	local stack = {}

    local name, description, journalEncounterID, rootSectionID, link, journalInstanceID2, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(bossIndex, journalInstanceID)

    local counter = 1

    local frameChecker = {}
    
    if(rootSectionID) then
        repeat
            local info = C_EncounterJournal.GetSectionInfo(rootSectionID)

            if(info) then
                if not info.filteredByDifficulty then
                    --print(("  "):rep(info.headerType)..info.link.. ": "..info.description)
                end
                table.insert(stack, info.siblingSectionID)
                table.insert(stack, info.firstChildSectionID)
                --[[dataProvider:Insert({
                    icon = info.abilityIcon,
                    title = info.title,
                    description = info.description,
            
                });]]

                local frame

                if(not frameChecker[info.title]) then
                    frame = framePool:Acquire()
                    frame.layoutIndex = counter
                    frame.Name:SetText(info.title)
                    --frame.DetailedInformation.Normal:SetText(info.description)
                    frame.Icon:SetTexture(info.abilityIcon)
                    frame:Show()
                    frameChecker[info.title] = frame

                    frame.DetailedInformation.Normal.Name:SetText("Normal")
                    frame.DetailedInformation.Heroic.Name:SetText("Heroic")
                    frame.DetailedInformation.Mythic.Name:SetText("Mythic")
                    frame.DetailedInformation.LFR.Name:SetText("LFR")

                    counter = counter + 1
                end
                
                if(frameChecker[info.title]) then
                    frame = frame or frameChecker[info.title]

                    local normalExpand = setDifficultyFrameData(14, rootSectionID, frame)
                    local heroicExpand = setDifficultyFrameData(15, rootSectionID, frame)
                    local mythicExpand = setDifficultyFrameData(16, rootSectionID, frame)
                    local lfrExpand = setDifficultyFrameData(17, rootSectionID, frame)

                    --print(info.title, normalInfo.filteredByDifficulty, heroicInfo.filteredByDifficulty, mythicInfo.filteredByDifficulty)
                    
                    frame.ExpandFrame:SetShown(normalExpand or heroicExpand or mythicExpand or lfrExpand)

                end
            end

            rootSectionID = table.remove(stack)
        until not rootSectionID
    end

    --miog.AdventureJournal.SpecificScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
    --miog.AdventureJournal.SpecificScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

    miog.AdventureJournal.ScrollFrame.Container:MarkDirty()
end

miog.loadAdventureJournal = function()
    miog.AdventureJournal = CreateFrame("Frame", "MythicIOGrabber_AdventureJournal", miog.pveFrame2, "MIOG_AdventureJournal")
    miog.AdventureJournal:SetSize(miog.Plugin:GetSize())
    miog.AdventureJournal:SetPoint("TOPLEFT", miog.pveFrame2, "TOPRIGHT")

    framePool = CreateFramePool("Frame", miog.AdventureJournal.ScrollFrame.Container, "MIOG_AdventureJournalAbilityTemplate", resetJournalFrames)

	local instanceDropdown = miog.AdventureJournal.InstanceDropdown
	instanceDropdown:OnLoad()

	local bossDropdown = miog.AdventureJournal.BossDropdown
	bossDropdown:OnLoad()

    local instanceID = 1207
    EJ_SelectInstance(instanceID)
    local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID = EJ_GetInstanceInfo(instanceID)
    --miog.AdventureJournal.Instance.Name:SetText(name)

    local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(1, instanceID)

   -- miog.AdventureJournal.Boss.Name:SetText(name)

    --[[local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("MIOG_AdventureJournalAbilityTemplate", function(frame, elementData)
		frame.Icon:SetTexture(elementData.icon)
		frame.Name:SetText(elementData.title)
		frame.Description:SetText(elementData.description)
        frame.fixedHeight = max(frame.Description:GetStringHeight(), 20)
        frame:MarkDirty()
	end);
	view:SetPadding(2,2,2,2,0);]]

	--ScrollUtil.InitScrollBoxListWithScrollBar(miog.AdventureJournal.SpecificScrollBox, miog.AdventureJournal.SpecificScrollBar, view);
end