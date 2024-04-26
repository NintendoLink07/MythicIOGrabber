local addonName, miog = ...

miog.setupRaidStatistics = function()
	if(miog.RaidStatistics.RaidColumns.Raids[1] == nil) then
		for k, v in pairs(miog.ACTIVITY_INFO) do
			
			if(v.expansionLevel == (GetAccountExpansionLevel()-1) and v.difficultyID == miog.RAID_DIFFICULTIES[3]) then
				--sortedExpansionRaids[#sortedExpansionRaids + 1] = {groupFinderActivityGroupID = v.groupFinderActivityGroupID, name = v.shortName}
				local raidColumn = CreateFrame("Frame", nil, miog.RaidStatistics.RaidColumns, "MIOG_RaidStatisticsColumnTemplate")
				raidColumn.mapID = v.mapID
				raidColumn:SetHeight(miog.RaidStatistics:GetHeight())
				raidColumn.layoutIndex = k
		
				miog.createFrameBorder(raidColumn, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())

				raidColumn.ShortName:SetText(v.shortName)
				raidColumn.Background:SetTexture(v.vertical)
				raidColumn.Normal:SetTextColor(miog.DIFFICULTY[1].miogColors:GetRGBA())
				raidColumn.Heroic:SetTextColor(miog.DIFFICULTY[2].miogColors:GetRGBA())
				raidColumn.Mythic:SetTextColor(miog.DIFFICULTY[3].miogColors:GetRGBA())
		
				miog.RaidStatistics.RaidColumns.Raids[#miog.RaidStatistics.RaidColumns.Raids+1] = raidColumn
			end
		
			--local shortName = i == 1 and PLAYER_DIFFICULTY1 or i == 2 and PLAYER_DIFFICULTY2 or i == 3 and PLAYER_DIFFICULTY6
		end
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
			GameTooltip:SetOwner(miog.RaidStatistics.CharacterInfo.Honor, "ANCHOR_RIGHT", -4, -4);
			GameTooltip:SetText(PVP_PRESTIGE_RANK_UP_NEXT_MAX_LEVEL_REWARD:format(nextHonorLevelForReward))
			local WRAP = true;
			GameTooltip_AddColoredLine(GameTooltip, rewardText, HIGHLIGHT_FONT_COLOR, WRAP);
			GameTooltip:Show();
		end
	end

end

miog.createRaidCharacter = function(playerGUID)
    local characterFrame

	if(miog.RaidStatistics.ScrollFrame.Rows.accountChars[playerGUID] == nil) then
		characterFrame = CreateFrame("Frame", nil, miog.RaidStatistics.ScrollFrame.Rows, "MIOG_RaidStatisticsCharacterTemplate")
		characterFrame:SetWidth(miog.RaidStatistics:GetWidth())
		characterFrame.layoutIndex = #miog.RaidStatistics.ScrollFrame.Rows:GetLayoutChildren() + 1

		if(characterFrame.layoutIndex == 1) then
			characterFrame:SetHeight(54)
			local fontFile, height, flags = characterFrame.Name:GetFont()
			characterFrame.Name:SetFont(fontFile, 14, flags)
			characterFrame.TransparentDark:SetHeight(36)

		else
			characterFrame.TransparentDark:SetHeight(32)

		end

		miog.RaidStatistics.ScrollFrame.Rows.accountChars[playerGUID] = characterFrame
	else

		characterFrame = miog.RaidStatistics.ScrollFrame.Rows.accountChars[playerGUID]
	end

    local isCurrentChar = playerGUID == UnitGUID("player")

    if(isCurrentChar) then
        local _, className = UnitClass("player")

        MIOG_SavedSettings.raidStatistics.table[playerGUID] = {}
        MIOG_SavedSettings.raidStatistics.table[playerGUID].name = MIOG_SavedSettings.raidStatistics.table[playerGUID].name or UnitName("player")
        MIOG_SavedSettings.raidStatistics.table[playerGUID].class = MIOG_SavedSettings.raidStatistics.table[playerGUID].class or className

        MIOG_SavedSettings.raidStatistics.table[playerGUID].raids = {}

		--for a = 1, 3, 1 do
		for _, x in ipairs(miog.RaidStatistics.RaidColumns.Raids) do
			--local currentTable = a == 1 and criteriaTable1 or a == 2 and criteriaTable2 or criteriaTable3
			local mapID = x.mapID

			MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID] = {{}, {}, {}}

			if(miog.MAP_INFO[x.mapID].criteria) then
				for i = miog.MAP_INFO[x.mapID].criteria[1], miog.MAP_INFO[x.mapID].criteria[2], 1 do
				--for k, v in ipairs(criteriaTable) do
					--local bossNumber = GetAchievementNumCriteria(v)
					local id, name, points, completed, month, day, year, description, flags,
					icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
					= GetAchievementInfo(i)

					if(isStatistic) then
						local difficulty = string.find(name, "Normal") and 1 or string.find(name, "Heroic") and 2 or string.find(name, "Mythic") and 3

						if(difficulty) then
							local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(i, 1, true)

							table.insert(MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID][difficulty], completedCriteria)
						end
					end
				end

				for _, v in ipairs(MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID]) do
					if(v) then
						for _, y in ipairs(v) do
							if(y == true) then
								v.kills = v.kills == nil and 1 or v.kills + 1
							end

						end
					end
				end
			end

			if(miog.MAP_INFO[x.mapID].criteriaAwakened) then
				for k, v in ipairs(miog.MAP_INFO[x.mapID].criteriaAwakened) do
					local id, name, points, completed, month, day, year, description, flags,
					icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
					= GetAchievementInfo(v)
					local difficulty = string.find(description, "Normal") and 1 or string.find(description, "Heroic") and 2 or string.find(description, "Mythic") and 3
					MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID][difficulty].awakened = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID][difficulty].awakened or {}

					local numCriteria = GetAchievementNumCriteria(v)

					for i = 1, numCriteria, 1 do
						local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(v, i, true)

						table.insert(MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID][difficulty].awakened, completedCriteria)

					end
					
				end
			end

		end
    end

	characterFrame.Name:SetText(MIOG_SavedSettings.raidStatistics.table[playerGUID].name)
	characterFrame.Name:SetTextColor(C_ClassColor.GetClassColor(MIOG_SavedSettings.raidStatistics.table[playerGUID].class):GetRGBA())
end

miog.fillRaidCharacter = function(playerGUID)
	local characterFrame = miog.RaidStatistics.ScrollFrame.Rows.accountChars[playerGUID]

	local counter = 1

	--for k, v in pairs(MIOG_SavedSettings.raidStatistics.table[playerGUID].raids) do
	for _, x in ipairs(miog.RaidStatistics.RaidColumns.Raids) do
		--for i = 1, 1, 1 do
		local raidFrame = characterFrame["Raid" .. counter]
		raidFrame:SetWidth(miog.RaidStatistics.RaidColumns.Raids[counter]:GetWidth())
		raidFrame.layoutIndex = counter

		for a = 1, 3, 1 do

			local difficultyFontString2 = a == 1 and raidFrame.AwakenedNormal or a == 2 and raidFrame.AwakenedHeroic or a == 3 and raidFrame.AwakenedMythic

			local progress2 = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[x.mapID][a].awakened
			local text2 = (progress2 and progress2.kills or 0) .. "/" .. #miog.MAP_INFO[x.mapID].bosses
			difficultyFontString2:SetText(WrapTextInColorCode(text2, miog.DIFFICULTY[a].color))

			local difficultyFontString = a == 1 and raidFrame.Normal or a == 2 and raidFrame.Heroic or a == 3 and raidFrame.Mythic

			local progress = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[x.mapID][a]
			local text = (progress and progress.kills or 0) .. "/" .. #miog.MAP_INFO[x.mapID].bosses
			difficultyFontString:SetText(WrapTextInColorCode(text, miog.DIFFICULTY[a].desaturated))


			for i = 1, #miog.MAP_INFO[x.mapID].bosses, 1 do
				

			end
		end

		counter = counter + 1
	end
end

miog.gatherRaidStatistics = function()
	local playerGUID = UnitGUID("player")

	miog.createRaidCharacter(playerGUID)
    miog.fillRaidCharacter(playerGUID)

	local orderedTable = {}

	for x, y in pairs(MIOG_SavedSettings.raidStatistics.table) do
		local index = #orderedTable+1
		orderedTable[index] = y
		orderedTable[index].key = x
	end

	--table.sort(orderedTable, function(k1, k2)
	--	return k1.rating > k2.rating
	--end)

	for x, y in pairs(orderedTable) do
		if(y.key ~= playerGUID) then
			miog.createRaidCharacter(y.key)
			miog.fillRaidCharacter(y.key)

		end
	end

	miog.RaidStatistics.ScrollFrame.Rows:MarkDirty()
end