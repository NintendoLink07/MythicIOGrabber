local addonName, miog = ...

PortsMixin = {}

function PortsMixin:OnLoad()
    local name, description, numSlots, isKnown = GetFlyoutInfo(96)

    local children = self.ActiveSeason:GetLayoutChildren()

    for k = 1, numSlots, 1 do
        local flyoutSpellID, _, spellKnown, spellName, _ = GetFlyoutSlotInfo(96, k)

        if(children[k]) then
            children[k]:SetData({spellID = flyoutSpellID, isKnown = spellKnown})

        end
    end
end

function PortsMixin:OnShow()


end