local addonName, miog = ...

SearchFrameInfoFrameMixin = CreateFromMixins(SearchFrameBaseFrameMixin)

function SearchFrameInfoFrameMixin:SetupMapTable()
    local orderedMapTable = miog:GetOrderedMythicPlusMapTable()
    
    for index, mapUIInfo in ipairs(orderedMapTable) do
        local frame = self.Dungeons.childFrames[index]

        if(frame) then
            frame.id = mapUIInfo.id
            frame.Name:SetText(mapUIInfo.abbreviatedName or mapUIInfo.name)
            frame.Icon:SetTexture(mapUIInfo.texture)

        end
    end
end

function SearchFrameInfoFrameMixin:SetupRaids()
    local bossIndex = 1
    local seasonRaidData = miog:GetSeasonRaidData()

    if(seasonRaidData) then
        for raidIndex, tierInfo in ipairs(seasonRaidData) do
            local raidFrame = self.Raids["Raid" .. raidIndex]

            if(raidFrame) then
                local name

                for _, mapID in ipairs(tierInfo.mapIDs) do
                    local mapInfo = miog:GetMapInfo(mapID)

                    if(mapInfo) then
                        name = name and (name .. "/" .. mapInfo.abbreviatedName) or mapInfo.abbreviatedName

                        if(mapInfo.bosses and #mapInfo.bosses > 0) then
                            for _, bossInfo in ipairs(mapInfo.bosses) do
                                local bossFrame = raidFrame.childFrames[bossIndex]

                                if(bossFrame) then
                                    SetPortraitTextureFromCreatureDisplayID(bossFrame.Icon, bossInfo.creatureDisplayInfoID)
                                    bossFrame:Show()

                                end

                                bossIndex = bossIndex + 1
                            end

                            raidFrame:Show()

                        else
                            raidFrame:Hide()

                        end

                    else
                        raidFrame:Hide()

                    end
                end

                raidFrame.Name:SetText(name)
            end
        end
    end
end

function SearchFrameInfoFrameMixin:Reset()
    for _, v in ipairs(self.Dungeons.childFrames) do
        v.Text:SetText(0)
        v.Text:SetTextColor(GRAY_FONT_COLOR:GetRGBA())

    end

    for i = 1, 2, 1 do
        local raidFrame = self.Raids["Raid" .. i]
 
        if(raidFrame) then
            raidFrame.Progress1:SetText("")
            raidFrame.Progress2:SetText("")

            for _, v in ipairs(raidFrame.childFrames) do
                v.Border:SetColorTexture(RED_FONT_COLOR:GetRGBA())
                v.Icon:SetDesaturated(true)

            end
        end
    end

    self.KeysDone.levels = nil
end

function SearchFrameInfoFrameMixin:OnLoad()
    self:Reset()
    self:SetupMapTable()
    self:SetupRaids()

end

function SearchFrameInfoFrameMixin:RefreshStatus()
    self.StatusFrame:Show()

    if self.isDelisted then
        self.StatusFrame.Text:SetText("DELISTED")
        
    elseif self.hasInvitation then
        self.StatusFrame.Text:SetText("INVITED")

    elseif self.isFull then
        self.StatusFrame.Text:SetText("FULL")

    elseif self.applicationHasBeenDeclined then
        self.StatusFrame.Text:SetText("APP DECLINED")

    elseif self.invitationHasBeenDeclined then
        self.StatusFrame.Text:SetText("INVITE DECLINED")

    elseif self.applicationHasBeenCancelled then
        self.StatusFrame.Text:SetText("CANCELLED")

    elseif self.isTimedOut then
        self.StatusFrame.Text:SetText("TIMEOUT")

    else
        self.StatusFrame:Hide()

    end
    
    self.Background:SetVertexColor(1, 1, 1, 1)

end

function SearchFrameInfoFrameMixin:SetRealmData(realm)
    local region = miog.F.CURRENT_REGION
    local countryFlag, language = miog:GetRealmData(realm, region)
    local countryFlagTexture = countryFlag and ("|T" .. countryFlag .. ":12:12|t" .. " ") or ""

    self.Realm:SetText(countryFlagTexture .. string.upper(region or "") .. "-" .. realm .. "(" .. language .. ")")
end

function SearchFrameInfoFrameMixin:SetKeyLevels(mplusData)
    self.KeysDone:SetText(
        WrapTextInColorCode((mplusData.keystoneMilestone2 or 0), miog.ITEM_QUALITY_COLORS[2].pureHex) .. " - " ..
        WrapTextInColorCode((mplusData.keystoneMilestone4 or 0), miog.ITEM_QUALITY_COLORS[3].pureHex) .. " - " ..
        WrapTextInColorCode((mplusData.keystoneMilestone7 or 0), miog.ITEM_QUALITY_COLORS[4].pureHex) .. " - " ..
        WrapTextInColorCode((mplusData.keystoneMilestone10 or 0), miog.ITEM_QUALITY_COLORS[5].pureHex) .. " - " ..
        WrapTextInColorCode((mplusData.keystoneMilestone12 or 0), miog.ITEM_QUALITY_COLORS[6].pureHex) .. " - " ..
        WrapTextInColorCode((mplusData.keystoneMilestone15 or 0), miog.ITEM_QUALITY_COLORS[7].pureHex)
    )

    self.KeysDone:SetScript("OnEnter", function(selfFontString)
        GameTooltip:SetOwner(selfFontString, "ANCHOR_RIGHT")
        GameTooltip:SetText("The amount of keys in a specific keylevel bracket that have been completed:")
        GameTooltip:AddLine("2-3: " .. (mplusData.keystoneMilestone2 or 0))
        GameTooltip:AddLine("4-6: " .. (mplusData.keystoneMilestone4 or 0))
        GameTooltip:AddLine("7-9: " .. (mplusData.keystoneMilestone7 or 0))
        GameTooltip:AddLine("10-11: " .. (mplusData.keystoneMilestone10 or 0))
        GameTooltip:AddLine("12-14: " .. (mplusData.keystoneMilestone12 or 0))
        GameTooltip:AddLine("15+: " .. (mplusData.keystoneMilestone15 or 0))
        GameTooltip:Show()
    
    end)
end

function SearchFrameInfoFrameMixin:Update()
    if(IsPlayerAtEffectiveMaxLevel()) then
        local data = self:GetData()
        local searchResultInfo = miog:GetSecureSearchResultInfo(data.resultID)

        if(searchResultInfo and searchResultInfo.leaderName) then
            local name, realm = strsplit("-", searchResultInfo.leaderName)

            if(not realm) then
                realm = GetNormalizedRealmName()

            end

            self:SetRealmData(realm)

            --M+
            local mplusData = miog:GetMythicPlusDataViaRaiderIO(name, realm)

            if(mplusData) then
                for _, v in ipairs(self.Dungeons.childFrames) do
                    local idData = mplusData[v.id]

                    if(idData) then
                        v.Text:SetText(idData.level .. (strrep(miog.C.RIO_STAR_TEXTURE, idData.chests) or ""))

                        if(idData.level == 0) then
                            v.Text:SetTextColor(GRAY_FONT_COLOR:GetRGBA())
                            
                        elseif(idData.chests > 0) then
                            v.Text:SetTextColor(GREEN_FONT_COLOR:GetRGBA())

                        else
                            v.Text:SetTextColor(RED_FONT_COLOR:GetRGBA())

                        end
                    end
                end     

                if(mplusData.mplusMainCurrent and mplusData.mplusMainCurrent.score > 0) then
                    self.MainChar:SetText("Alt; Main rating is " .. mplusData.mplusMainCurrent.score)

                else
                    self.MainChar:SetText("M+ Main")

                end

                self:SetKeyLevels(mplusData)
            else
                for _, v in ipairs(self.Dungeons.childFrames) do
                    v.Text:SetText(0)
                    v.Text:SetTextColor(GRAY_FONT_COLOR:GetRGBA())
                        
                end
            end

            --Raid
            local raidData = miog:GetRaidTierDataViaRaiderIO(name, realm)
            local bossesKilled = {}

            if(raidData) then
                for k, v in ipairs(raidData) do
                    local raidFrame = self.Raids["Raid" .. k]
                    local numOfBosses = miog:GetNumOfBossesForTier(v.sortedDifficulties[1].tierIndex)

                    for i = 1, 2, 1 do
                        local progressFrame = raidFrame["Progress" .. i]
                        local difficultyData = v.sortedDifficulties[i]

                        if(difficultyData) then
                            progressFrame:SetText(numOfBosses and (difficultyData.killedBosses .. "/" .. numOfBosses) or "")
                            progressFrame:SetTextColor(miog.DIFFICULTY[difficultyData.difficulty].miogColors:GetRGBA())

                            local r, g, b, a = miog.DIFFICULTY[difficultyData.difficulty].miogColors:GetRGBA()

                            for bossIndex = 1, 10, 1 do
                                local bossKilled = difficultyData.bosses[bossIndex]

                                if(bossKilled) then
                                    local bossFrame = raidFrame.childFrames[bossIndex]
                                    
                                    if(bossFrame) then
                                        if(not bossesKilled[bossIndex] or difficultyData.difficulty > bossesKilled[bossIndex]) then
                                            bossFrame.Border:SetColorTexture(r, g, b, a)
                                            bossesKilled[bossIndex] = difficultyData.difficulty
                                            bossFrame.Icon:SetDesaturated(false)

                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                local raidFrame1 = self.Raids["Raid1"]
                raidFrame1.Progress1:SetText("")
                raidFrame1.Progress2:SetText("")

                local raidFrame2 = self.Raids["Raid2"]
                raidFrame2.Progress1:SetText("")
                raidFrame2.Progress2:SetText("")

            end

            if(searchResultInfo.comment) then
                self.Comment:SetText(searchResultInfo.comment)

            end
        end

        self:SetStatus(searchResultInfo)
        
    else
        self:Reset()

    end
end