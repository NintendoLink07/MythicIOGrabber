local addonName, miog = ...

ProgressCheckHeaderMixin = CreateFromMixins(TableBuilderElementMixin);

function ProgressCheckHeaderMixin:Init(...)
    local name = ...
    self.Text:SetText(name)

end


ProgressCheckCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressCheckCellMixin:Populate(rowData, dataIndex)
    self.Text:SetText(rowData.itemlevel)

end


ProgressCheckInfoColumnButtonMixin = {}

function ProgressCheckInfoColumnButtonMixin:OnClick()
    local key = self:GetParentKey()
    EventRegistry:TriggerEvent("MIOG_PROGRESS_CHECK_TYPE", key and strlower(self:GetParentKey()))

end



ProgressCheckLockoutsCellMixin = {}

function ProgressCheckLockoutsCellMixin:OnEnter()
    if(self.data) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(FLEX_RAID_LOCKOUT_LABEL .. ": " .. self.data[1].name)

        for _, instanceInfo in pairs(self.data) do
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip:AddDoubleLine(DifficultyUtil.GetDifficultyName(instanceInfo.difficultyID), date("%x %X", instanceInfo.resetDate))

            for i = 1, instanceInfo.numEncounters, 1 do
                local bossInfo = instanceInfo.bosses[i]
                GameTooltip:AddLine(WrapTextInColorCode(bossInfo.bossName, bossInfo.isKilled and RED_FONT_COLOR:GenerateHexColor() or GREEN_FONT_COLOR:GenerateHexColor()))

            end
        end

        GameTooltip:Show()
    end
end

function ProgressCheckLockoutsCellMixin:Reset()
    self.data = nil
    self.Text:SetText("")

end

function ProgressCheckLockoutsCellMixin:SetData(data)
    self:Reset()

    self.data = data

    local string = ""

    for _, instanceInfo in pairs(data) do
        local color = miog.DIFFICULTY_ID_TO_COLOR[instanceInfo.difficultyID]

        if(color) then
            string = string .. WrapTextInColorCode(instanceInfo.shortDifficulty, color:GenerateHexColor()) .. " "

        end
        
    end

    self.Text:SetText(string)
end


ProgressCheckColoredCellMixin = {}

function ProgressCheckColoredCellMixin:OnLoad()
    self.BackgroundColor:SetColorTexture(0.75, 0.75, 0.75, 0.1)
end