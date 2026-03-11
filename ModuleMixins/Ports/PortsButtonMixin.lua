local addonName, miog = ...

PortsButtonMixin = {}

function PortsButtonMixin:OnLoad()
    self:SetAttribute("type", "spell")
    self:RegisterForClicks("LeftButtonDown")

end

function PortsButtonMixin:SetData(data)
    local spell = Spell:CreateFromSpellID(data.spellID)
    spell:ContinueOnSpellLoad(function()
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)

        self:SetAttribute("spell", spellInfo.name)
        self:SetNormalTexture(spellInfo.iconID)
        self:GetNormalTexture():SetDesaturated(not data.isKnown)

        self:SetScript("OnEnter", function(selfButton)
            GameTooltip:SetOwner(selfButton, "ANCHOR_RIGHT")
            GameTooltip_AddHighlightLine(GameTooltip, spellInfo.name)
            GameTooltip:AddLine(C_Spell.GetSpellDescription(data.spellID)
)
            GameTooltip:Show()
        end)
    end)
end