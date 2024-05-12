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

	--[[local vaultNormal = 16343
	local vaultHeroic = 16345
	local vaultMythic = 16354
	
	local id, name, points, completed, month, day, year, description, flags,
	icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
	= GetAchievementInfo(vaultHeroic)

	local max = GetAchievementNumCriteria(vaultHeroic)

	for i = 1, max, 1 do
		local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(vaultHeroic, i, true)
		print("ACHIEV", id, name, completed)
		print("CRITERIA", criteriaID, criteriaString, completedCriteria)
	end]]

	local totalAchievements = GetCategoryNumAchievements(15469)

    if(isCurrentChar) then
        local _, className = UnitClass("player")

        MIOG_SavedSettings.raidStatistics.table[playerGUID] = {}
        MIOG_SavedSettings.raidStatistics.table[playerGUID].name = MIOG_SavedSettings.raidStatistics.table[playerGUID].name or UnitName("player")
        MIOG_SavedSettings.raidStatistics.table[playerGUID].class = MIOG_SavedSettings.raidStatistics.table[playerGUID].class or className
        MIOG_SavedSettings.raidStatistics.table[playerGUID].raids = {}

		for _, x in ipairs(miog.RaidStatistics.RaidColumns.Raids) do
			local mapID = x.mapID

			MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID] = {regular = {}, awakened = {}}

			--[[if(miog.MAP_INFO[x.mapID].achievementsAwakened) then
				for a, b in ipairs(miog.MAP_INFO[x.mapID].achievementsAwakened) do
					local id, name, points, completed, month, day, year, description, flags,
					icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
					= GetAchievementInfo(b)

					local difficulty = string.find(description, "Normal") and 1 or string.find(description, "Heroic") and 2 or string.find(description, "Mythic") and 3
					
					if(difficulty) then
						MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty] = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty] or {kills = 0, bosses = {}}

						local numCriteria = GetAchievementNumCriteria(b)

						for i = 1, numCriteria, 1 do
							local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(b, i, true)

							if(completedCriteria) then
								MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty].kills = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty].kills + 1

							end

							table.insert(MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty].bosses, {id = b, criteriaID = criteriaID, killed = completedCriteria, quantity = quantity})

						end
					end
				end
			end]]
			
			for k, d in ipairs(miog.MAP_INFO[mapID].achievementsAwakened) do
				local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(d)

				local difficulty = string.find(description, "Normal") and 1 or string.find(name, "Heroic") and 2 or string.find(name, "Mythic") and 3

				if(difficulty) then
					MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty] = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty] or {kills = 0, bosses = {}}

					local numCriteria = GetAchievementNumCriteria(d)
					for i = 1, numCriteria, 1 do
						local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(id, i, true)

						if(completedCriteria) then
							MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty].kills = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty].kills + 1

						end

						table.insert(MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].awakened[difficulty].bosses, {id = id, criteriaID = criteriaID, killed = completedCriteria, quantity = quantity})
					end
				end
			end
			
			--for d = 1, totalAchievements, 1 do
			for k, d in ipairs(miog.MAP_INFO[mapID].achievementTable) do
				local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(d)

				local difficulty = string.find(name, "Normal") and 1 or string.find(name, "Heroic") and 2 or string.find(name, "Mythic") and 3

				if(difficulty) then
					MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].regular[difficulty] = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].regular[difficulty] or {kills = 0, bosses = {}}

					local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(id, 1, true)

					if(completedCriteria) then
						MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].regular[difficulty].kills = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].regular[difficulty].kills + 1

					end

					table.insert(MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID].regular[difficulty].bosses, {id = id, criteriaID = criteriaID, killed = completedCriteria, quantity = quantity})
				end
			end
		end
    end

	characterFrame.Name:SetText(MIOG_SavedSettings.raidStatistics.table[playerGUID].name)
	characterFrame.Name:SetTextColor(C_ClassColor.GetClassColor(MIOG_SavedSettings.raidStatistics.table[playerGUID].class):GetRGBA())
end

local function raidFrame_OnEnter(self, playerGUID, mapID, difficulty, type)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, miog.MAP_INFO[mapID].name)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	for k, v in ipairs(MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[mapID][type][difficulty].bosses) do
		local bossInfo = v
		local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfoByID(bossInfo.id, bossInfo.criteriaID, true)
		local id, name, points, completed, month, day, year, description, flags,
		icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
		= GetAchievementInfo(bossInfo.id)

		GameTooltip:AddDoubleLine(bossInfo.quantity or 0, type == "awakened" and criteriaString .. " kills" or name)
	end

	GameTooltip:Show()
end

miog.fillRaidCharacter = function(playerGUID)
	local characterFrame = miog.RaidStatistics.ScrollFrame.Rows.accountChars[playerGUID]

	local counter = 1

	for _, x in ipairs(miog.RaidStatistics.RaidColumns.Raids) do
		local raidFrame = characterFrame["Raid" .. counter]
		raidFrame:SetWidth(miog.RaidStatistics.RaidColumns.Raids[counter]:GetWidth())
		raidFrame.layoutIndex = counter

		for a = 1, 3, 1 do
			local current = a == 1 and raidFrame.Normal.Current or a == 2 and raidFrame.Heroic.Current or a == 3 and raidFrame.Mythic.Current
			local previous = a == 1 and raidFrame.Normal.Previous or a == 2 and raidFrame.Heroic.Previous or a == 3 and raidFrame.Mythic.Previous

			local currentProgress = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[x.mapID].awakened[a]
			local text2 = (currentProgress and currentProgress.kills or 0) .. "/" .. #miog.MAP_INFO[x.mapID].bosses
			current:SetText(WrapTextInColorCode(text2, miog.DIFFICULTY[a].color))

			if(previous) then
				local previousProgress = MIOG_SavedSettings.raidStatistics.table[playerGUID].raids[x.mapID].regular[a]
				local text = (previousProgress and previousProgress.kills or 0) .. "/" .. #miog.MAP_INFO[x.mapID].bosses
				previous:SetText(WrapTextInColorCode(text, miog.DIFFICULTY[a].desaturated))
				previous:Show()
			end

			current:SetScript("OnEnter", function(self)
				raidFrame_OnEnter(self, playerGUID, x.mapID, a, "awakened")
			end)

			current:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			previous:SetScript("OnEnter", function(self)
				raidFrame_OnEnter(self, playerGUID, x.mapID, a, "regular")
			end)

			previous:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
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