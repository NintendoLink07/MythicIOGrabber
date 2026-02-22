LootInstanceMixin = CreateFromMixins(LootLineMixin)

function LootInstanceMixin:SetData(data)
    self.Name:SetText(data.instanceName)
    self.Icon:SetTexture(data.icon)

    self:SetExpandState(true)

    self.data = data
end

function LootInstanceMixin:OnMouseDown_Right(button)
    EncounterJournal_OpenJournal(nil, self.data.journalInstanceID, nil, nil, nil, nil)

end