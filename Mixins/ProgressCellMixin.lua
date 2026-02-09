local addonName, miog = ...

ProgressOverviewCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressOverviewCellMixin:Populate(dataTable, index)
    local data = dataTable[index]

    self.Text:SetText("YE")

    if(data) then
        if(index == 2) then
            --self.Text:SetText(data or 0)

        elseif(index == 3) then

            --self.Text:SetText(data.score)
            --self.Text:SetTextColor(miog.createCustomColorForRating(data.score):GetRGBA())
                
        elseif(index == 4) then
            --[[
            local mapID = data.currentRaidMapID

            local mapInfo = miog.getMapInfo(mapID, true)
            local numBosses = #mapInfo.bosses

            for i = 1, 3, 1 do
                local raidProgressFrame = i == 1 and self.Normal or i == 2 and self.Heroic or i == 3 and self.Mythic
                raidProgressFrame:SetText((data.raids.instances[mapID] and data.raids.instances[mapID][i] and data.raids.instances[mapID][i].kills or 0) .. "/" .. numBosses)
                raidProgressFrame:SetTextColor(miog.DIFFICULTY[i].miogColors:GetRGBA())

            end]]
        else

        end
    end
end

ProgressOverviewFullMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressOverviewFullMixin:Init(id)
    self.id = id
end

function ProgressOverviewFullMixin:Populate(data, index)
    if(self.id == index) then
        local classID = miog.CLASSFILE_TO_ID[data.fileName]
        local color = C_ClassColor.GetClassColor(data.fileName)

        self.Class.Icon:SetTexture(miog.CLASSES[classID].icon)
        self.Spec.Icon:SetTexture(data.specID and miog.SPECIALIZATIONS[data.specID].squaredIcon or miog.SPECIALIZATIONS[0].squaredIcon)
        self.Name:SetText(data.name)

        self.GuildBannerBackground:SetVertexColor(color:GetRGB())
        self.GuildBannerBorder:SetVertexColor(color.r * 0.65, color.g * 0.65, color.b * 0.65)
        self.GuildBannerBorderGlow:SetShown(data.guid == UnitGUID("player"))
    end

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
			GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(tostring(overallScore))), GREEN_FONT_COLOR);
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
        self.Name:SetFont(self.file, self.height + 3, self.flags)
        self.Score:SetFont(self.file, self.height + 1, self.flags)

    else
        self.Name:SetFont(self.file, self.height, self.flags)
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




ProgressRaidCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressRaidCellMixin:Init(mapID)
    self.id = mapID
    self.file, self.height, self.flags = _G["GameFontHighlight"]:GetFont()
end

function ProgressRaidCellMixin:Populate(data)
    local id = self.id
    self.data = data

    if(id) then
        local journalInfo = miog:GetJournalDataForMapID(id)
        local numBosses = #journalInfo.bosses
        local raidData = data.raids.instances[id]

        if(raidData) then
            for a = 1, 3, 1 do
                local current = a == 1 and self.Normal or a == 2 and self.Heroic or a == 3 and self.Mythic

                if(current) then
                    local hasRaidData = raidData[a] ~= nil

                    if(hasRaidData) then
                        local text = (raidData[a].kills) .. "/" .. numBosses
                        current:SetText(WrapTextInColorCode(text, miog.DIFFICULTY[a].color))

                    else
                        local text = "0/" .. numBosses
                        current:SetText(WrapTextInColorCode(text, miog.CLRSCC.gray))
                        

                    end

                    current:SetScript("OnEnter", function(selfFrame)
                        if(hasRaidData) then
                            GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
                            GameTooltip_AddHighlightLine(GameTooltip, journalInfo.instanceName)
                            GameTooltip_AddBlankLineToTooltip(GameTooltip)

                            for k, v in ipairs(raidData[a].bosses) do
                                if(v.id) then
                                    local name, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfoByID(v.id, 1, true)

                                    if(not name) then
                                        name = journalInfo.bosses[k].name .. " kills"

                                    end

                                    GameTooltip:AddDoubleLine(v.count or v.quantity or 0, name)
                                end
                            end
                            
                            if(not raidData[a].validatedIngame) then
                                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                                GameTooltip_AddNormalLine(GameTooltip, "This data has been pulled from RaiderIO, it may be not accurate.")
                                GameTooltip_AddNormalLine(GameTooltip, "Login with this character to request official data from Blizzard.")

                            end

                            GameTooltip:Show()
                        end
                    end)
                end
            end

            return
        end
    end

    self.Normal:SetText(0 .. "/" .. 0)
    self.Normal:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
    self.Heroic:SetText(0 .. "/" .. 0)
    self.Heroic:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
    self.Mythic:SetText(0 .. "/" .. 0)
    self.Mythic:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
    self:SetScript("OnEnter", nil)
    self:Show()
end



ProgressRaidCharacterCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressRaidCharacterCellMixin:Init()
    self.file, self.height, self.flags = _G["GameFontHighlight"]:GetFont()
    
end

function ProgressRaidCharacterCellMixin:Populate(data)
    self.Name:SetText(data.name)
    self.Name:SetTextColor(C_ClassColor.GetClassColor(data.fileName):GetRGBA())
    
    if(data.guid == UnitGUID("player")) then
        self.Name:SetFont(self.file, self.height + 3, self.flags)

    else
        self.Name:SetFont(self.file, self.height, self.flags)

    end
end




ProgressPVPCharacterCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressPVPCharacterCellMixin:Init()
    self.file, self.height, self.flags = _G["GameFontHighlight"]:GetFont()

end

function ProgressPVPCharacterCellMixin:Populate(data)
    self.Name:SetText(data.name)
    self.Name:SetTextColor(C_ClassColor.GetClassColor(data.fileName):GetRGBA())
    
    if(data.guid == UnitGUID("player")) then
        self.Name:SetFont(self.file, self.height + 3, self.flags)

    else
        self.Name:SetFont(self.file, self.height, self.flags)

    end
end



ProgressPVPCellMixin = CreateFromMixins(TableBuilderCellMixin)

function ProgressPVPCellMixin:Init(activityID)
    self.id = activityID
end

function ProgressPVPCellMixin:Populate(data)
    local id = self.id

    if(data.pvp.brackets[id]) then
        self.Rating:SetText(data.pvp.brackets[id].rating .. " YE")
        self.SeasonBest:SetText(data.pvp.brackets[id].seasonBest)

    end


    self.Rating:SetText(0)
    self.SeasonBest:SetText(0)

   --[[ if(id) then
        local numOfBosses = #miog.MAP_INFO[id].bosses
        local raidData = data.raids.instances[id]

        if(raidData) then
            for a = 1, 3, 1 do
                local current = a == 1 and self.Normal or a == 2 and self.Heroic or a == 3 and self.Mythic

                local text = (raidData[a] and raidData[a].kills or 0) .. "/" .. numOfBosses
                current:SetText(WrapTextInColorCode(text, raidData[a] and miog.DIFFICULTY[a].color or miog.CLRSCC.gray))

                current:SetScript("OnEnter", function(selfFrame)
                    --raidOnEnter(selfFrame, data.guid, id, a, "regular")
                end)

                current:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end

            return
        end
    end

    self.Normal:SetText(0 .. "/" .. 0)
    self.Normal:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
    self.Heroic:SetText(0 .. "/" .. 0)
    self.Heroic:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
    self.Mythic:SetText(0 .. "/" .. 0)
    self.Mythic:SetTextColor(CreateColorFromHexString(miog.CLRSCC.red):GetRGBA())
    self:SetScript("OnEnter", nil)
    self:Show()]]
end