local addonName, miog = ...

ProgressCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressCellMixin:Populate(data)
    local classID = miog.CLASSFILE_TO_ID[data.fileName]
    local color = C_ClassColor.GetClassColor(data.fileName)

    self.Class.Icon:SetTexture(miog.CLASSES[classID].icon)
    self.Spec.Icon:SetTexture(data.specID and miog.SPECIALIZATIONS[data.specID].squaredIcon or miog.SPECIALIZATIONS[0].squaredIcon)
    self.Name:SetText(data.name)

    self.GuildBannerBackground:SetVertexColor(color:GetRGB())
    self.GuildBannerBorder:SetVertexColor(color.r * 0.65, color.g * 0.65, color.b * 0.65)

    self.ItemLevel:SetText(data.itemLevel or 0)

    self.MythicPlusScore:SetText(data.mythicPlus.score)
    self.MythicPlusScore:SetTextColor(miog.createCustomColorForRating(data.mythicPlus.score):GetRGBA())
end

ProgressMythicPlusCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressMythicPlusCellMixin:Init(id)
    self.id = id
end

function ProgressMythicPlusCellMixin:Populate(data)
    local id = self.id

    if(id) then
        local dungeonData = data.mythicPlus.dungeons[id]

        if(dungeonData) then
            local intimeInfo = dungeonData.intimeInfo
            local overtimeInfo = dungeonData.overtimeInfo

            local overtimeHigher = intimeInfo and overtimeInfo and intimeInfo.dungeonScore and overtimeInfo.dungeonScore and overtimeInfo.dungeonScore > intimeInfo.dungeonScore
            local hasOnlyOvertime = not intimeInfo and overtimeInfo

            self.Level:SetText((overtimeHigher or hasOnlyOvertime) and overtimeInfo.level or intimeInfo and intimeInfo.level or 0)
            self.Level:SetTextColor(CreateColorFromHexString((overtimeHigher or hasOnlyOvertime) and overtimeInfo.level and miog.CLRSCC.red or intimeInfo and intimeInfo.level and miog.CLRSCC.green or miog.CLRSCC.gray):GetRGBA())
            self:Show()

            return

        end
        
    end

    self.Level:SetText(0)
    self.Level:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
    self:Show()
end

ProgressMythicPlusCharacterCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressMythicPlusCharacterCellMixin:Init()
    self.file, self.height, self.flags = _G["GameFontHighlight"]:GetFont()
end

function ProgressMythicPlusCharacterCellMixin:Populate(data)
    self.Name:SetText(data.name)
    self.Name:SetTextColor(C_ClassColor.GetClassColor(data.fileName):GetRGBA())
    
    if(data.guid == UnitGUID("player")) then
        self.Score:SetFont(self.file, self.height + 2, self.flags)

    else
        self.Score:SetFont(self.file, self.height, self.flags)

    end

    self.Score:SetText(data.mythicPlus.score)

    if(data.mythicPlus.validatedIngame) then
        self.Score:SetTextColor(miog.createCustomColorForRating(data.mythicPlus.score):GetRGBA())
        self.Score:SetScript("OnEnter", nil)
        self.Score:SetScript("OnLeave", nil)

    else
        self.Score:SetTextColor(CreateColorFromHexString(miog.CLRSCC.yellow):GetRGBA())
        self.Score:SetScript("OnEnter", function(selfFrame)
            GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
            GameTooltip:SetText("This data has been pulled from RaiderIO, it may be not accurate.")
            GameTooltip:AddLine("Login with this character to request official data from Blizzard.")
            GameTooltip:Show()
        end)

        self.Score:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

    end

end