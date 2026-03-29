local addonName, miog = ...

PortsButtonMixin = {}

function PortsButtonMixin:OnLoad()
    self:SetAttribute("type", "spell")
    self:RegisterForClicks("LeftButtonDown")

end

function PortsButtonMixin:CheckVisuals()
    if(self.data) then
        local isKnown = C_SpellBook.IsSpellInSpellBook(self.data.spellID)

        local texture = self:GetNormalTexture()
        
        if(texture) then
            texture:SetDesaturated(not isKnown)
            
        end
        
        if(isKnown) then
            self:SetHighlightAtlas("communities-create-avatar-border-hover")
            
            local teleportInfo = miog.TELEPORT_SPELLS_TO_MAP_DATA[self.data.spellID]
            
            if(teleportInfo) then
                local mapInfo = miog:GetMapInfo(teleportInfo.mapID)

                if(mapInfo) then
                    self.Text:SetText(mapInfo.abbreviatedName)
                end

            --else
                --self.Text:SetText(WrapTextInColorCode("MISSING", "FFFF0000"))
                --print(self.data.spellID, spellInfo.name)

            end
        end

    end
end

function PortsButtonMixin:OnShow()
    self:CheckVisuals()

end

function PortsButtonMixin:SetData(data)
    self.data = data

    local spell = Spell:CreateFromSpellID(data.spellID)

    spell:ContinueOnSpellLoad(function()
        local spellInfo = C_Spell.GetSpellInfo(data.spellID)

        self:SetAttribute("spell", spellInfo.name)
        self:SetNormalTexture(spellInfo.iconID)

        self:SetScript("OnEnter", function(selfButton)
            GameTooltip:SetOwner(selfButton, "ANCHOR_RIGHT")
            GameTooltip_AddHighlightLine(GameTooltip, spellInfo.name)
            GameTooltip:AddLine(C_Spell.GetSpellDescription(data.spellID)
)
            GameTooltip:Show()
        end)

        self:CheckVisuals()
    end)
end