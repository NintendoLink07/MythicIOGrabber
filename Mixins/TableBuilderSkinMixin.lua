TableBuilderSkinMixin = CreateFromMixins(TableBuilderMixin)

function TableBuilderSkinMixin:EnableRowDividers()
    for k, v in pairs(self.rows) do
        if(not v.UpperDivider) then
            v.UpperDivider = v:CreateTexture(nil, "BORDER")
            v.UpperDivider:SetHeight(6)
            v.UpperDivider:SetAtlas("dragonflight-weeklyrewards-divider")
            v.UpperDivider:SetPoint("TOPLEFT", v, "TOPLEFT", -1, 3)
            v.UpperDivider:SetPoint("TOPRIGHT", v, "TOPRIGHT", 1, 3)

        end

        if(not v.LowerDivider) then
            v.LowerDivider = v:CreateTexture(nil, "BORDER")
            v.LowerDivider:SetHeight(4)
            v.LowerDivider:SetAtlas("dragonflight-weeklyrewards-divider")
            v.LowerDivider:SetPoint("BOTTOMLEFT", v, "BOTTOMLEFT", -1, -2)
            v.LowerDivider:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", 1, -2)

        end

        if(not v.TransparentBackground) then
            v.TransparentBackground = v:CreateTexture(nil, "BACKGROUND")
            v.TransparentBackground:SetAllPoints(true)
            v.TransparentBackground:SetColorTexture(0.03, 0.03, 0.03, 0.6)

        end
    end
end