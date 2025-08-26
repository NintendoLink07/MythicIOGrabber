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

local function getChestsLevelForID(challengeMapID, durationSec)
	local name, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeMapID)

	local oneChest = timeLimit
	local twoChest = timeLimit * 0.8
	local threeChest = timeLimit * 0.6

	return durationSec <= threeChest and 3 or durationSec <= twoChest and 2 or durationSec <= oneChest and 1 or 0
end

function ProgressMythicPlusCellMixin:OnEnter(challengeMapID, guid)
	local name = C_ChallengeMode.GetMapUIInfo(challengeMapID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(name, 1, 1, 1);

	local intimeInfo = self.data.mythicPlus.dungeons[challengeMapID].intimeInfo
	local overtimeInfo = self.data.mythicPlus.dungeons[challengeMapID].overtimeInfo
	local overtimeHigher = intimeInfo and overtimeInfo and intimeInfo.dungeonScore and overtimeInfo.dungeonScore and overtimeInfo.dungeonScore > intimeInfo.dungeonScore and true or false
	local overallScore = overtimeHigher and overtimeInfo.dungeonScore or intimeInfo and intimeInfo.dungeonScore or 0

	if(intimeInfo or overtimeInfo) then
		if(overallScore) then
			local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overallScore);
			if(not color) then
				color = HIGHLIGHT_FONT_COLOR;
			end
			GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(overallScore)), GREEN_FONT_COLOR);
		end

		local info = overtimeHigher and overtimeInfo or intimeInfo

		if(info) then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(info.level) .. (intimeInfo and string.format(" (%s chest)", intimeInfo.chests or getChestsLevelForID(challengeMapID, intimeInfo.durationSec)) or ""), HIGHLIGHT_FONT_COLOR);

			if(overallScore) then
				if(not overtimeHigher and intimeInfo) then
					GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(intimeInfo.durationSec, intimeInfo.durationSec >= SECONDS_PER_HOUR and true or false), HIGHLIGHT_FONT_COLOR);

				elseif(overtimeInfo) then
					GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(overtimeInfo.durationSec, overtimeInfo.durationSec >= SECONDS_PER_HOUR and true or false)), LIGHTGRAY_FONT_COLOR);

				end
			else
				GameTooltip_AddBlankLineToTooltip(GameTooltip)
				GameTooltip_AddNormalLine(GameTooltip, "This data has been pulled from RaiderIO, it may be not accurate.")
				GameTooltip_AddNormalLine(GameTooltip, "Login with this character to request official data from Blizzard.")

			end
		end
	end

	GameTooltip:Show();
end

function ProgressMythicPlusCellMixin:Populate(data)
    local id = self.id
    self.data = data

    if(id) then
        local dungeonData = data.mythicPlus.dungeons[id]

        if(dungeonData) then
            local intimeInfo = dungeonData.intimeInfo
            local overtimeInfo = dungeonData.overtimeInfo

            local overtimeHigher = intimeInfo and overtimeInfo and intimeInfo.dungeonScore and overtimeInfo.dungeonScore and overtimeInfo.dungeonScore > intimeInfo.dungeonScore
            local hasOnlyOvertime = not intimeInfo and overtimeInfo

            self.Level:SetText((overtimeHigher or hasOnlyOvertime) and overtimeInfo.level or intimeInfo and intimeInfo.level or 0)
            self.Level:SetTextColor(CreateColorFromHexString((overtimeHigher or hasOnlyOvertime) and overtimeInfo.level and miog.CLRSCC.red or intimeInfo and intimeInfo.level and miog.CLRSCC.green or miog.CLRSCC.gray):GetRGBA())
            self:SetScript("OnEnter", function(selfFrame)
                self:OnEnter(id, data.guid)
            end)
            self:Show()

            return
        end
    end

    self.Level:SetText(0)
    self.Level:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
    self:SetScript("OnEnter", nil)
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