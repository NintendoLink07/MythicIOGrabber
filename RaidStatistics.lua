local addonName, miog = ...

miog.setupRaidStatistics = function()
	for k, v in pairs(miog.ACTIVITY_INFO) do
        local difficultyColumn = CreateFrame("Frame", nil, miog.RaidStatistics.DifficultyColumns, "MIOG_RaidStatisticsColumnTemplate")
        difficultyColumn:SetHeight(miog.RaidStatistics:GetHeight())
        difficultyColumn.layoutIndex = k

        miog.createFrameBorder(difficultyColumn, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
		
		if(v.expansionLevel == (GetAccountExpansionLevel()-1) and v.difficultyID == miog.RAID_DIFFICULTIES[3]) then
			--sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = v.groupFinderActivityGroupID, name = v.shortName}
			
			difficultyColumn.ShortName:SetText(v.shortName)

			difficultyColumn.Background:SetTexture(v.vertical)
	
			miog.RaidStatistics.DifficultyColumns.Difficulties[i] = difficultyColumn
		end
	

        --local shortName = i == 1 and PLAYER_DIFFICULTY1 or i == 2 and PLAYER_DIFFICULTY2 or i == 3 and PLAYER_DIFFICULTY6
    end
end

local function tierFrame_OnEnter(frame, tierTable)
    local tierInfo = C_PvP.GetPvpTierInfo(tierTable[1])
    local nextTierInfo = C_PvP.GetPvpTierInfo(tierTable[2])

    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
    GameTooltip:SetMinimumWidth(260);
    --GameTooltip_SetTitle(GameTooltip, tierName);
	local tierName = tierInfo and tierInfo.pvpTierEnum and PVPUtil.GetTierName(tierInfo.pvpTierEnum);
	if tierName then
        GameTooltip:AddLine(tierName)

		local activityItemLevel, weeklyItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(tierInfo.pvpTierEnum);
		if weeklyItemLevel > 0 then
			GameTooltip_AddColoredLine(GameTooltip, PVP_GEAR_REWARD_BY_RANK:format(weeklyItemLevel), NORMAL_FONT_COLOR);
		end
	end

    local nextTierName = nextTierInfo and nextTierInfo.pvpTierEnum and PVPUtil.GetTierName(nextTierInfo.pvpTierEnum);
	if nextTierName then
        GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip:AddLine(TOOLTIP_PVP_NEXT_RANK:format(nextTierName));
		local tierDescription = PVPUtil.GetTierDescription(nextTierInfo.pvpTierEnum);
		if tierDescription then
			GameTooltip_AddNormalLine(GameTooltip, tierDescription);
		end
		local activityItemLevel, weeklyItemLevel = C_PvP.GetRewardItemLevelsByTierEnum(nextTierInfo.pvpTierEnum);
		if activityItemLevel > 0 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, PVP_GEAR_REWARD_BY_NEXT_RANK:format(weeklyItemLevel), NORMAL_FONT_COLOR);
		end
	end

    GameTooltip:Show();
end

local function honorBar_OnEnter()
	local honorLevel = UnitHonorLevel("player");
	local nextHonorLevelForReward = C_PvP.GetNextHonorLevelForReward(honorLevel);
	local rewardInfo = nextHonorLevelForReward and C_PvP.GetHonorRewardInfo(nextHonorLevelForReward);
	if rewardInfo then
		local rewardText = select(11, GetAchievementInfo(rewardInfo.achievementRewardedID));
		if rewardText and rewardText ~= "" then
			GameTooltip:SetOwner(miog.PVPStatistics.CharacterInfo.Honor, "ANCHOR_RIGHT", -4, -4);
			GameTooltip:SetText(PVP_PRESTIGE_RANK_UP_NEXT_MAX_LEVEL_REWARD:format(nextHonorLevelForReward));
			local WRAP = true;
			GameTooltip_AddColoredLine(GameTooltip, rewardText, HIGHLIGHT_FONT_COLOR, WRAP);
			GameTooltip:Show();
		end
	end

end

miog.createPVPCharacter = function(playerGUID)
    local characterFrame

	if(miog.PVPStatistics.ScrollFrame.Rows.accountChars[playerGUID] == nil) then
		characterFrame = CreateFrame("Frame", nil, miog.PVPStatistics.ScrollFrame.Rows, "MIOG_PVPStatisticsCharacterTemplate")
		characterFrame:SetWidth(miog.PVPStatistics:GetWidth())
		characterFrame.layoutIndex = #miog.PVPStatistics.ScrollFrame.Rows:GetLayoutChildren() + 1

		if(characterFrame.layoutIndex == 1) then
			characterFrame:SetHeight(55)
			local fontFile, height, flags = characterFrame.Name:GetFont()
			characterFrame.Name:SetFont(fontFile, 14, flags)
			characterFrame.TransparentDark:SetHeight(36)

		else
			characterFrame.TransparentDark:SetHeight(32)

		end

		miog.PVPStatistics.ScrollFrame.Rows.accountChars[playerGUID] = characterFrame
	else

		characterFrame = miog.PVPStatistics.ScrollFrame.Rows.accountChars[playerGUID]
	end

    local isCurrentChar = playerGUID == UnitGUID("player")

    if(isCurrentChar) then
        local _, className = UnitClass("player")

        MIOG_SavedSettings.pvpStatistics.table[playerGUID] = {}
        MIOG_SavedSettings.pvpStatistics.table[playerGUID].name = MIOG_SavedSettings.pvpStatistics.table[playerGUID].name or UnitName("player")
        MIOG_SavedSettings.pvpStatistics.table[playerGUID].class = MIOG_SavedSettings.pvpStatistics.table[playerGUID].class or className
        MIOG_SavedSettings.pvpStatistics.table[playerGUID].brackets = {}

        for i = 1, 4, 1 do
            local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, cap = GetPersonalRatedInfo(i) -- 1 == 2v2, 2 == 3v3, 3 == 5v5, 4 == 10v10

            MIOG_SavedSettings.pvpStatistics.table[playerGUID].brackets[i] = {rating = rating, seasonBest = seasonBest}

        end

        local tierID, nextTierID = C_PvP.GetSeasonBestInfo();

        MIOG_SavedSettings.pvpStatistics.table[playerGUID].tierInfo = {tierID, nextTierID}
    end

	characterFrame.Name:SetText(MIOG_SavedSettings.pvpStatistics.table[playerGUID].name)
	characterFrame.Name:SetTextColor(C_ClassColor.GetClassColor(MIOG_SavedSettings.pvpStatistics.table[playerGUID].class):GetRGBA())
    characterFrame.Score:SetText("")

    local tierInfo = C_PvP.GetPvpTierInfo(MIOG_SavedSettings.pvpStatistics.table[playerGUID].tierInfo[1])
    characterFrame.Rank:SetTexture(tierInfo.tierIconID)

    characterFrame.Rank:SetScript("OnEnter", function(self) tierFrame_OnEnter(self, MIOG_SavedSettings.pvpStatistics.table[playerGUID].tierInfo)
    end)
    characterFrame.Rank:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

miog.fillPVPCharacter = function(playerGUID)
	local characterFrame = miog.PVPStatistics.ScrollFrame.Rows.accountChars[playerGUID]

    for i = 1, 4, 1 do
		local bracketFrame = characterFrame["Bracket" .. i]
		bracketFrame:SetWidth(miog.PVPStatistics.BracketColumns.Brackets[i]:GetWidth())
		bracketFrame.layoutIndex = i

        local rating = MIOG_SavedSettings.pvpStatistics.table[playerGUID].brackets[i].rating
        local seasonBest = MIOG_SavedSettings.pvpStatistics.table[playerGUID].brackets[i].seasonBest

		bracketFrame.Level1:SetText(rating)
		bracketFrame.Level1:SetTextColor(CreateColorFromHexString(rating == 0 and miog.CLRSCC.gray or miog.CLRSCC.yellow):GetRGBA())

		local desaturatedColors = CreateColorFromHexString(seasonBest == 0 and miog.CLRSCC.gray or miog.CLRSCC.yellow)

		bracketFrame.Level2:SetText(seasonBest or 0)
		bracketFrame.Level2:SetTextColor(desaturatedColors.r * 0.6, desaturatedColors.g * 0.6, desaturatedColors.b * 0.6, 1)

	end
end

miog.gatherPVPStatistics = function()
	local playerGUID = UnitGUID("player")

	miog.createPVPCharacter(playerGUID)
    miog.fillPVPCharacter(playerGUID)

	local orderedTable = {}

	for x, y in pairs(MIOG_SavedSettings.pvpStatistics.table) do
		local index = #orderedTable+1
		orderedTable[index] = y
		orderedTable[index].key = x
	end

	--table.sort(orderedTable, function(k1, k2)
	--	return k1.rating > k2.rating
	--end)

    miog.PVPStatistics.CharacterInfo.Honor.Level:SetText("Honor Level " .. UnitHonorLevel("player"))
    miog.PVPStatistics.CharacterInfo.Honor.Status:SetMinMaxValues(0, UnitHonorMax("player"))
    miog.PVPStatistics.CharacterInfo.Honor.Status:SetValue(UnitHonor("player"))
    miog.PVPStatistics.CharacterInfo.Honor.Status.Text:SetText(UnitHonor("player") .. "/" .. UnitHonorMax("player") .. " Honor")

    miog.PVPStatistics.CharacterInfo.Honor:SetScript("OnEnter", function() honorBar_OnEnter()
    end)
    miog.PVPStatistics.CharacterInfo.Honor:SetScript("OnLeave", function() GameTooltip:Hide() end)

	for x, y in pairs(orderedTable) do
		if(y.key ~= playerGUID) then
			miog.createPVPCharacter(y.key)
			miog.fillPVPCharacter(y.key)

		end
	end

	miog.PVPStatistics.ScrollFrame.Rows:MarkDirty()
end