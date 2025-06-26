local formatter = CreateFromMixins(SecondsFormatterMixin)
formatter:SetStripIntervalWhitespace(true)
formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter)

QueueFrameMixin = {}

function QueueFrameMixin:OnLoad()
    self.formatter = formatter

    self.CancelApplication:SetAttribute("type", "macro")
end

function QueueFrameMixin:RetrieveQueueList()
    local length = 0
    local queuedList = GetLFGQueuedList(self.categoryID, {}) or {}

    for _ in pairs(queuedList) do
        length = length + 1
    end

    local isMultiDungeon = self.categoryID == LE_LFG_CATEGORY_LFD and length > 1
    local dungeonList = {}

    for queueID, queued in pairs(queuedList) do
        if(isMultiDungeon) then
            local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(queueID)
            table.insert(dungeonList, {dungeonID = queueID, name = name, difficulty = subtypeID == 1 and "Normal" or subtypeID == 2 and "Heroic"})

        end
    end

    return dungeonList
end