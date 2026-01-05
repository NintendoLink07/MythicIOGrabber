TeleportButtonMixin = {}

function TeleportButtonMixin:Init()
    self:SetAttribute("type", "spell")
    self:RegisterForClicks("LeftButtonDown")

end

function TeleportButtonMixin:OnShow()
    if(self.flyoutSpellID) then
        local spellCooldownInfo = C_Spell.GetSpellCooldown(self.flyoutSpellID)
        self.Cooldown:SetCooldown(spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.modRate)

    end
end

function TeleportButtonMixin:Refresh(data)
    if(data and data.type ~= "fill") then
        self.flyoutSpellID = data.flyoutSpellID

        local desc = C_Spell.GetSpellDescription(self.flyoutSpellID)

        if(desc == "") then
            local spell = Spell:CreateFromSpellID(self.flyoutSpellID)
            spell:ContinueOnSpellLoad(function()
                self:Refresh(data)

            end)
        else
            local spellInfo = C_Spell.GetSpellInfo(self.flyoutSpellID)
            self:SetNormalTexture(spellInfo.iconID)
            self:GetNormalTexture():SetDesaturated(not data.isKnown)

            if(data.isKnown) then
                self:SetHighlightAtlas("communities-create-avatar-border-hover")
                self:SetAttribute("spell", spellInfo.name)

                self.Text:SetText(data.abbreviatedName or WrapTextInColorCode("MISSING", "FFFF0000"))

            end

            self:SetScript("OnEnter", function(selfButton)
                GameTooltip:SetOwner(selfButton, "ANCHOR_RIGHT")
                GameTooltip_AddHighlightLine(GameTooltip, spellInfo.name)
                GameTooltip:AddLine(desc)
                GameTooltip:Show()
            end)
            self:Show()

        end
    else
        self:ClearNormalTexture()
        self:ClearHighlightTexture()
        self:SetScript("OnEnter", nil)
        self.Text:SetText("")

    end
end

function TeleportButtonMixin:Populate(data, index)
    self:Refresh(data[index])

end