LootBossMixin = CreateFromMixins(LootLineMixin)

function LootBossMixin:SetData(data)
    self.Name:SetText(data.name or data.altName)
    
    SetPortraitTextureFromCreatureDisplayID(self.Icon, data.creatureDisplayInfoID)

    self:SetExpandState(true)

    self.data = data
end

function LootBossMixin:OnMouseDown_Right()
    EncounterJournal_OpenJournal(nil, self.data.journalInstanceID, self.data.journalEncounterID, nil, nil, nil)

end