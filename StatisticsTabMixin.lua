local addonName, miog = ...

StatisticsTabMixin = {}

local function getChestsLevelForID(challengeMapID, durationSec)
	local name, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeMapID)

	local oneChest = timeLimit
	local twoChest = timeLimit * 0.8
	local threeChest = timeLimit * 0.6

	return durationSec <= threeChest and 3 or durationSec <= twoChest and 2 or durationSec <= oneChest and 1 or 0
end

local function sortByScore(k1, k2)
    if k1 and k2 then
        -- Check if either is the player's GUID
        if k1.guid == UnitGUID("player") then
            return true
        elseif k2.guid == UnitGUID("player") then
            return false
        end
        -- Compare scores
        return k1.score.value > k2.score.value
    elseif k1 then
        return true  -- k1 is valid, k2 is nil
    elseif k2 then
        return false -- k2 is valid, k1 is nil
    else
        return false -- Both are nil, order doesn't matter
    end
end

local function sortByProgress(k1, k2)
    if k1 and k2 then
        -- Check if either is the player's GUID
        if k1.guid == UnitGUID("player") then
            return true
        elseif k2.guid == UnitGUID("player") then
            return false
        end
        -- Compare scores
        return k1.progressWeight > k2.progressWeight
    elseif k1 then
        return true  -- k1 is valid, k2 is nil
    elseif k2 then
        return false -- k2 is valid, k1 is nil
    else
        return false -- Both are nil, order doesn't matter
    end

end

local function sortByRating(k1, k2)
    if k1 and k2 then
        -- Check if either is the player's GUID
        if k1.guid == UnitGUID("player") then
            return true
        elseif k2.guid == UnitGUID("player") then
            return false
        end
        -- Compare scores
        return k1.rating > k2.rating
    elseif k1 then
        return true  -- k1 is valid, k2 is nil
    elseif k2 then
        return false -- k2 is valid, k1 is nil
    else
        return false -- Both are nil, order doesn't matter
    end

end

local function pvpOnEnter(self, tierTable)
    local tierInfo = C_PvP.GetPvpTierInfo(tierTable[1])
    local nextTierInfo = C_PvP.GetPvpTierInfo(tierTable[2])

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
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

local function mplusOnEnter(self, playerGUID)
	local challengeMapID = self.challengeMapID
	local name = C_ChallengeMode.GetMapUIInfo(challengeMapID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(name, 1, 1, 1);

	local overAllScore = MIOG_NewSettings.accountStatistics[playerGUID].mplus[challengeMapID].overAllScore
	local inTimeInfo = MIOG_NewSettings.accountStatistics[playerGUID].mplus[challengeMapID].intimeInfo
	local overtimeInfo = MIOG_NewSettings.accountStatistics[playerGUID].mplus[challengeMapID].overtimeInfo

	if(inTimeInfo or overtimeInfo) then
		if(overAllScore) then
			local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overAllScore);
			if(not color) then
				color = HIGHLIGHT_FONT_COLOR;
			end
			GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(overAllScore)), GREEN_FONT_COLOR);
		end

		local info = inTimeInfo or overtimeInfo

		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(info.level) .. (inTimeInfo and string.format(" (%s chest)", inTimeInfo.chests or getChestsLevelForID(challengeMapID, inTimeInfo.durationSec)) or ""), HIGHLIGHT_FONT_COLOR);
		
		if(overAllScore) then
			if(inTimeInfo) then
				GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(inTimeInfo.durationSec, inTimeInfo.durationSec >= SECONDS_PER_HOUR and true or false), HIGHLIGHT_FONT_COLOR);

			elseif(overtimeInfo) then
				GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(overtimeInfo.durationSec, overtimeInfo.durationSec >= SECONDS_PER_HOUR and true or false)), LIGHTGRAY_FONT_COLOR);

			end
		else
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddNormalLine(GameTooltip, "This data has been pulled from RaiderIO, it may be not accurate.")
			GameTooltip_AddNormalLine(GameTooltip, "Login with this character to request official data from Blizzard.")

		end
	end

	GameTooltip:Show();
end

local function raidOnEnter(self, playerGUID, mapID, difficulty, type)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, miog.MAP_INFO[mapID].name)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	if(MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID][type][difficulty]) then
		for k, v in ipairs(MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID][type][difficulty].bosses) do
			local bossInfo = v
			local criteriaString, name

			if(bossInfo.id) then
				_, name = GetAchievementInfo(bossInfo.id)
				
			else
				name = miog.MAP_INFO[mapID].bosses[k].name .. " kills"

			end

			if(bossInfo.criteriaID) then
				criteriaString = GetAchievementCriteriaInfoByID(bossInfo.id, bossInfo.criteriaID, true)

			else
				name = miog.MAP_INFO[mapID].bosses[k].name .. " kills"

			end

			GameTooltip:AddDoubleLine(bossInfo.quantity or 0, type == "awakened" and criteriaString .. " kills" or name)

		end

		if(not MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID][type][difficulty].ingame) then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddNormalLine(GameTooltip, "This data has been pulled from RaiderIO, it may be not accurate.")
			GameTooltip_AddNormalLine(GameTooltip, "Login with this character to request official data from Blizzard.")
	
		end
	end

	GameTooltip:Show()
end

function StatisticsTabMixin:CreateDropdownEntry(fullName, rootDescription)
	local keystoneInfo = miog.checkSystem.keystoneData[fullName]

	if(keystoneInfo and keystoneInfo.mapID > 0) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)
		local className, classFile = GetClassInfo(keystoneInfo.classID)
		
		local shortName = miog.createSplitName(fullName)

		local text = WrapTextInColorCode(shortName, C_ClassColor.GetClassColor(classFile):GenerateHexColor()) .. ": " .. WrapTextInColorCode("+" .. keystoneInfo.level .. " " .. miog.MAP_INFO[keystoneInfo.mapID].shortName, miog.createCustomColorForRating(keystoneInfo.level * 130):GenerateHexColor())

		local keystoneButton = rootDescription:CreateRadio(text, function() return (currentChallengeMapID == keystoneInfo.challengeMapID) == (currentUnitName == fullName) end, function()
			self.currentUnitName = fullName
			self.currentChallengeMapID = keystoneInfo.challengeMapID
			self.currentLevel = keystoneInfo.level
			
			if(miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark) then
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Show()

			end

			if(miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID]) then
				miog.MPlusStatistics.DungeonColumns.Selection:SetPoint("TOPLEFT", miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID], "TOPLEFT")
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark = miog.MPlusStatistics.DungeonColumns.Dungeons[keystoneInfo.challengeMapID].TransparentDark
				miog.MPlusStatistics.DungeonColumns.Selection.TransparentDark:Hide()
			end

			if(fullName == UnitName("player")) then
				local overtimeScore, minScore, maxScore = miog.calculateNewScore(keystoneInfo.challengeMapID, keystoneInfo.level, nil, miog.MPlusStatistics.CharacterInfo.TimelimitSlider:GetValue())

				local playerGUID = UnitGUID("player")

				for _, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
					v.ScoreIncrease:Hide()

				end

				miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
				miog.MPlusStatistics.ScrollFrame.Rows.accountChars[playerGUID].ScoreIncrease:Show()
			else
				for k, v in pairs(miog.MPlusStatistics.ScrollFrame.Rows.accountChars) do
					local overtimeScore, minScore, maxScore = miog.calculateNewScore(keystoneInfo.challengeMapID, keystoneInfo.level, k, miog.MPlusStatistics.CharacterInfo.TimelimitSlider:GetValue())

					v.ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
					v.ScoreIncrease:Show()

				end
			
			end
		end, keystoneInfo.challengeMapID)

		keystoneButton:AddInitializer(function(button, description, menu)
			local leftTexture = button:AttachTexture();
			leftTexture:SetSize(14, 14);
			leftTexture:SetPoint("LEFT", 17, 0);
			leftTexture:SetTexture(texture);

			button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

			return button.fontString:GetUnboundedStringWidth() + 14 + 2
		end)
	end
end

function StatisticsTabMixin:OnLoad(id)
    self.id = id

    self:SetScript("OnShow", function()
        self:UpdateStatistics()

        if(IsInRaid()) then
            miog.openRaidLib.RequestKeystoneDataFromRaid()
            
        elseif(IsInGroup()) then
            miog.openRaidLib.RequestKeystoneDataFromParty()
        end
    end)

    local activityView = CreateScrollBoxListLinearView();
    activityView:SetHorizontal(true)
    activityView:SetElementInitializer("MIOG_StatisticsColumnTemplate", function(frame, data)
		local shortName
		if(data.type == "pvp") then
			local i = data.index

			shortName = i == 1 and ARENA_2V2 or i == 2 and ARENA_3V3 or i == 3 and ARENA_5V5 or BATTLEGROUND_10V10
			frame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/vertical/" .. shortName .. ".png")

		else
			local mapInfo = miog.MAP_INFO[data.mapID]
			shortName = mapInfo.shortName

			frame.Background:SetTexture(mapInfo.vertical, "MIRROR", "CLAMP")

		end

		frame.Name:SetText(shortName)

		miog.createFrameBorder(frame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
	end)
	
	activityView:SetPadding(1, 1, 1, 1, 2);
    self.Columns:Init(activityView);

    local characterView = CreateScrollBoxListLinearView();
    local template = self.id == 1 and "MIOG_StatisticsDungeonCharacterTemplate" or self.id == 2 and "MIOG_StatisticsRaidCharacterTemplate" or self.id == 3 and "MIOG_StatisticsPVPCharacterTemplate"
    characterView:SetElementInitializer(template, function(frame, data)
        frame.Name:SetText(data.name)
        frame.Name:SetTextColor(C_ClassColor.GetClassColor(data.classFile):GetRGBA())

		local isRaid = data.template == "MIOG_StatisticsRaidCharacterTemplate"
		local isDungeon = data.template == "MIOG_StatisticsDungeonCharacterTemplate"
		local isPvp = data.template == "MIOG_StatisticsPVPCharacterTemplate"

		local file, height, flags = _G["SystemFont_Shadow_Med1"]:GetFont()

		if(data.guid == UnitGUID("player")) then
			frame.Name:SetFont(file, height + 2, flags)

			if(isDungeon) then
				frame.Score:SetFont(file, height + 2, flags)

			end
		else
			frame.Name:SetFont(file, height, flags)

			if(isDungeon) then
				frame.Score:SetFont(file, height, flags)

			end
		end
    
        if(isDungeon) then
            frame.Score:SetText(data.score.value)
    
            if(data.score.ingame) then
                frame.Score:SetTextColor(miog.createCustomColorForRating(data.score.value):GetRGBA())
                frame.Score:SetScript("OnEnter", nil)
                frame.Score:SetScript("OnLeave", nil)
    
            else
                frame.Score:SetTextColor(CreateColorFromHexString(miog.CLRSCC.yellow):GetRGBA())
                frame.Score:SetScript("OnEnter", function(selfFrame)
                    GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
                    GameTooltip:SetText("This data has been pulled from RaiderIO, it may be not accurate.")
					GameTooltip:AddLine("Login with this character to request official data from Blizzard.")
                    GameTooltip:Show()
                end)
            
                frame.Score:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
    
            end
            
            for index, challengeMapID in ipairs(self.activityTable) do
                local dungeonFrame = frame.Dungeons["Dungeon" .. index]
                dungeonFrame:SetWidth(self.Columns:GetView():GetElementExtent())
                dungeonFrame.challengeMapID = challengeMapID
                dungeonFrame.layoutIndex = index

                local hasIntimeInfo = MIOG_NewSettings.accountStatistics[data.guid].mplus[challengeMapID].intimeInfo ~= nil
                local hasOvertimeInfo = MIOG_NewSettings.accountStatistics[data.guid].mplus[challengeMapID].overtimeInfo ~= nil

                dungeonFrame.Level:SetText(hasIntimeInfo and MIOG_NewSettings.accountStatistics[data.guid].mplus[challengeMapID].intimeInfo.level or hasOvertimeInfo and MIOG_NewSettings.accountStatistics[data.guid].mplus[challengeMapID].overtimeInfo.level or 0)
                dungeonFrame.Level:SetTextColor(CreateColorFromHexString(hasIntimeInfo and  miog.CLRSCC.green or hasOvertimeInfo and MIOG_NewSettings.accountStatistics[data.guid].mplus[challengeMapID].overtimeInfo.level and miog.CLRSCC.red or miog.CLRSCC.gray):GetRGBA())
                dungeonFrame:SetScript("OnEnter", function(selfFrame)
					mplusOnEnter(selfFrame, data.guid)
				end) -- ChallengesDungeonIconMixin:OnEnter()

            end
        elseif(isRaid) then

			for index, mapID in ipairs(self.activityTable) do
				local raidFrame = frame["Raid" .. index]
				raidFrame:SetWidth(self.Columns:GetView():GetElementExtent())
				raidFrame.layoutIndex = index

				for a = 1, 3, 1 do
					local current = a == 1 and raidFrame.Normal.Current or a == 2 and raidFrame.Heroic.Current or a == 3 and raidFrame.Mythic.Current
					--local previous = a == 1 and raidFrame.Normal.Previous or a == 2 and raidFrame.Heroic.Previous or a == 3 and raidFrame.Mythic.Previous
		
					if(current) then -- and previous
						local currentProgress = MIOG_NewSettings.accountStatistics[data.guid].raid[mapID].regular[a]

						local text2 = (currentProgress and currentProgress.kills or 0) .. "/" .. #miog.MAP_INFO[mapID].bosses
						current:SetText(WrapTextInColorCode(text2, currentProgress and miog.DIFFICULTY[a].color or miog.CLRSCC.gray))
		
						current:SetScript("OnEnter", function(selfFrame)
							raidOnEnter(selfFrame, data.guid, mapID, a, "regular")
						end)
		
						current:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)
		
						--[[if(previous) then
							local previousProgress = MIOG_NewSettings.raidStats[playerGUID].raid[mapID].regular[a]
							local text = (previousProgress and previousProgress.kills or 0) .. "/" .. #miog.MAP_INFO[mapID].bosses
							previous:SetText(WrapTextInColorCode(text, miog.DIFFICULTY[a].desaturated))
							previous:Show()
						end
		
						previous:SetScript("OnEnter", function(self)
							raidFrame_OnEnter(self, playerGUID, mapID, a, "regular")
						end)
		
						previous:SetScript("OnLeave", function()
							GameTooltip:Hide()
						end)]]
					end
				end
			end
		elseif(isPvp) then
			if(MIOG_NewSettings.accountStatistics[data.guid].tierInfo[1]) then
				local tierInfo = C_PvP.GetPvpTierInfo(MIOG_NewSettings.accountStatistics[data.guid].tierInfo[1])

				frame.Rank:SetTexture(tierInfo.tierIconID)
				frame.Rank:SetScript("OnEnter", function()
					pvpOnEnter(self, MIOG_NewSettings.accountStatistics[data.guid].tierInfo)
	
				end)
	
				frame.Rank:SetScript("OnLeave", function()
					GameTooltip:Hide()
	
				end)
	

			end
			for i = 1, 4, 1 do
				local bracketFrame = frame["Bracket" .. i]
				bracketFrame:SetWidth(self.Columns:GetView():GetElementExtent())
				bracketFrame.layoutIndex = i

				local rating
				local seasonBest
		
				if(MIOG_NewSettings.accountStatistics[data.guid].brackets[i]) then
					rating = MIOG_NewSettings.accountStatistics[data.guid].brackets[i].rating
					seasonBest = MIOG_NewSettings.accountStatistics[data.guid].brackets[i].seasonBest

				else
					rating = 0
					seasonBest = 0

				end
		
				bracketFrame.Level1:SetText(rating)
				bracketFrame.Level1:SetTextColor(CreateColorFromHexString(rating == 0 and miog.CLRSCC.gray or miog.CLRSCC.yellow):GetRGBA())
		
				local desaturatedColors = CreateColorFromHexString(seasonBest == 0 and miog.CLRSCC.gray or miog.CLRSCC.yellow)
		
				bracketFrame.Level2:SetText(seasonBest or 0)
				bracketFrame.Level2:SetTextColor(desaturatedColors.r * 0.6, desaturatedColors.g * 0.6, desaturatedColors.b * 0.6, 1)
		
			end
		end
	end)

    characterView:SetPadding(1, 1, 1, 1, 4)
    characterView:SetElementExtentCalculator(function(index, data)
		return data.guid == UnitGUID("player") and 40 or 32
	end)

    ScrollUtil.InitScrollBoxListWithScrollBar(self.Rows, self.RowsScrollBar, characterView);

	if(self.id == 1) then
		self.Info.KeystoneDropdown:SetDefaultText("Keystones")
		self.Info.KeystoneDropdown:SetupMenu(function(dropdown, rootDescription)
			--local shortName = GetUnitName("player", false)
			local fullPlayerName = miog.createFullNameFrom("unitID", "player")

			local numGroupMembers = GetNumGroupMembers()

			if(numGroupMembers > 0) then
				for groupIndex = 1, numGroupMembers, 1 do
					local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP

					local unitID
				
					if(IsInRaid()) then
						unitID = "raid" .. groupIndex
					else
						if groupIndex == 1 then
							unitID = "player";

						else
							unitID = "party"..(groupIndex - 1);

						end
					end

					local playerName, realm = miog.createSplitName(name)
					local fullName = playerName .. "-" .. (realm or "")

					self:CreateDropdownEntry(fullName, rootDescription)
				end
			else
				self:CreateDropdownEntry(fullPlayerName, rootDescription)

			end
		end)
	else
		self.Info:Hide()

	end
end

 --workaround, gets most characters if they've been converted with the warband feature, not even have to be logged in first or used this addon.
 --just has to have atleast a single type of currency (money (coppper, silver, gold) doesn't count)
function StatisticsTabMixin:RequestAccountCharacters()
	self.accountCharacters = {}

	local charList = {}
	local info

	local playerGUID = UnitGUID("player")
	local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(playerGUID)
	table.insert(self.accountCharacters, {guid = playerGUID, name = name, realm = realmName, classFile = englishClass})

	for i = 1, 5000, 1 do
		info = C_CurrencyInfo.GetCurrencyListInfo(i)

		if(info) then
			local accountCurrencyData = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(info.currencyID)

			if(accountCurrencyData) then
				for k, v in pairs(accountCurrencyData) do
					charList[v.characterGUID] = true

				end
			end
		end
	end
	
	for k, v in pairs(charList) do
		localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(k)
		
		table.insert(self.accountCharacters, {guid = k, name = name, realm = realmName, classFile = englishClass})
	end
end

function StatisticsTabMixin:UpdateAllCharacterStatistics()
	for k, v in ipairs(self.accountCharacters) do
		if(not MIOG_NewSettings.accountStatistics[v.guid]) then
			MIOG_NewSettings.accountStatistics[v.guid] = {}
			MIOG_NewSettings.accountStatistics[v.guid].name = v.name
			MIOG_NewSettings.accountStatistics[v.guid].fullName = miog.createFullNameFrom("unitName", v.name .. "-" .. v.realm)
			MIOG_NewSettings.accountStatistics[v.guid].classFile = v.classFile
			MIOG_NewSettings.accountStatistics[v.guid].mplus = {}
			MIOG_NewSettings.accountStatistics[v.guid].raid = {}
			MIOG_NewSettings.accountStatistics[v.guid].pvp = {}
		end

		if(self.id == 1) then
			self:UpdateCharacterMPlusStatistics(v.guid)

		elseif(self.id == 2) then
			self:UpdateCharacterRaidStatistics(v.guid)

		elseif(self.id == 3) then
			self:UpdatePVPStatistics(v.guid)

		end

	end
end

function StatisticsTabMixin:LoadActivities()
	if(self.id == 1) then
		self.activityTable = miog.SEASONAL_CHALLENGE_MODES[13] or C_ChallengeMode.GetMapTable()

	elseif(self.id == 2) then
		self.activityTable = miog.SEASONAL_MAP_IDS[13].raids
		
	elseif(self.id == 3) then
		self.activityTable = {1, 2, 3, 4}

	end
	
	if(self.id ~= 3) then
		table.sort(self.activityTable, function(k1, k2)
			local mapName1, mapName2

			if(self.id == 1) then
				mapName1 = miog.retrieveShortNameFromChallengeModeMap(k1)
				mapName2 = miog.retrieveShortNameFromChallengeModeMap(k2)

			elseif(self.id == 2) then
				mapName1 = miog.MAP_INFO[k1].shortName
				mapName2 = miog.MAP_INFO[k2].shortName

			end

			return mapName1 < mapName2

		end)
	end

	self.Columns:Flush()
	
	local columnProvider = CreateDataProvider();

	for index, activityEntry in ipairs(self.activityTable) do
		if(self.id == 1) then
			columnProvider:Insert({mapID = miog.retrieveMapIDFromChallengeModeMap(activityEntry)});

		elseif(self.id == 2) then
			miog.checkSingleMapIDForNewData(activityEntry, true)
			columnProvider:Insert({mapID = activityEntry});

		elseif(self.id == 3) then
			columnProvider:Insert({type = "pvp", index = activityEntry});

		end
	end

    self.Columns:GetView():SetElementExtent(400 / #self.activityTable)
	self.Columns:SetDataProvider(columnProvider);
end

function StatisticsTabMixin:CalculateProgressWeightViaAchievements(guid)
	local character = MIOG_NewSettings.accountStatistics[guid]
	local progressWeight = 0

	for k, v in ipairs(self.activityTable) do
		if(character.raid[v].regular) then
			for difficultyIndex, table in pairs(character.raid[v].regular) do
				progressWeight = progressWeight + miog.calculateWeightedScore(difficultyIndex, table.kills, #table.bosses, true, 1)
				

			end
		else
			progressWeight = progressWeight + 0

		end
	end

	MIOG_NewSettings.accountStatistics[guid].progressWeight = progressWeight

	--for a, b in ipairs(miog.guildSystem.memberData[name][3]) do
	--	progress = (progress or "") .. wticc(b.parsedString, miog.DIFFICULTY[b.difficulty].color) .. " "
	
	--	progressWeight = progressWeight + (b.weight or 0)
end

function StatisticsTabMixin:UpdatePVPStatistics(guid)
	local playerGUID = UnitGUID("player")

    if(guid == playerGUID) then
		local highestRating = 0

		MIOG_NewSettings.accountStatistics[playerGUID].brackets = {}

		for i = 1, 4, 1 do
			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, cap = GetPersonalRatedInfo(i) -- 1 == 2v2, 2 == 3v3, 3 == 5v5, 4 == 10v10

			MIOG_NewSettings.accountStatistics[playerGUID].brackets[i] = {rating = rating, seasonBest = seasonBest}

			highestRating = rating > highestRating and rating or highestRating

		end

		local tierID, nextTierID = C_PvP.GetSeasonBestInfo();

		MIOG_NewSettings.accountStatistics[playerGUID].tierInfo = {tierID, nextTierID}

		MIOG_NewSettings.accountStatistics[playerGUID].rating = highestRating

	else
		MIOG_NewSettings.accountStatistics[guid].brackets = MIOG_NewSettings.accountStatistics[guid].brackets or {}
		MIOG_NewSettings.accountStatistics[guid].tierInfo = MIOG_NewSettings.accountStatistics[guid].tierInfo or {}
		MIOG_NewSettings.accountStatistics[guid].rating = MIOG_NewSettings.accountStatistics[guid].rating or 0

	end
end

function StatisticsTabMixin:UpdateCharacterRaidStatistics(guid)
	local playerGUID = UnitGUID("player")

    if(guid == playerGUID) then
		for _, mapID in ipairs(self.activityTable) do
			MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID] = {regular = {}, awakened = {}}
			
			if(miog.MAP_INFO[mapID].achievementsAwakened) then
				for k, d in ipairs(miog.MAP_INFO[mapID].achievementsAwakened) do
					local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(d)

					local difficulty = string.find(description, "Normal") and 1 or string.find(name, "Heroic") and 2 or string.find(name, "Mythic") and 3

					if(difficulty) then
						MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].awakened[difficulty] = {ingame = true, kills = 0, bosses = {}}

						local numCriteria = GetAchievementNumCriteria(d)
						for i = 1, numCriteria, 1 do
							local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(id, i, true)

							if(completedCriteria) then
								MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].awakened[difficulty].kills = MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].awakened[difficulty].kills + 1

							end

							table.insert(MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].awakened[difficulty].bosses, {id = id, criteriaID = criteriaID, killed = completedCriteria, quantity = quantity})
						end
					end
				end
			end
			
			
			for k, d in ipairs(miog.MAP_INFO[mapID].achievementTable) do
				local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(d)

				local difficulty = string.find(name, "Normal") and 1 or string.find(name, "Heroic") and 2 or string.find(name, "Mythic") and 3

				if(difficulty) then
					MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].regular[difficulty] = MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].regular[difficulty] or {ingame = true, kills = 0, bosses = {}}

					local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(id, 1, true)

					if(completedCriteria) then
						MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].regular[difficulty].kills = MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].regular[difficulty].kills + 1

					end

					table.insert(MIOG_NewSettings.accountStatistics[playerGUID].raid[mapID].regular[difficulty].bosses, {id = id, criteriaID = criteriaID, killed = completedCriteria, quantity = quantity})
				end
			end
		end

		self:CalculateProgressWeightViaAchievements(guid)
    else
		local raidData = miog.getNewRaidSortData(MIOG_NewSettings.accountStatistics[guid].name, MIOG_NewSettings.accountStatistics[guid].realm)

		local progressWeight = MIOG_NewSettings.accountStatistics[guid].progressWeight or 0

		for k, v in ipairs(self.activityTable) do
			if(not MIOG_NewSettings.accountStatistics[guid].raid[v] and raidData and raidData.character) then
				MIOG_NewSettings.accountStatistics[guid].raid[v] = {regular = {}, awakened = {}}

				local mapInfo = miog.MAP_INFO[v]

				if(raidData.character.raids[v]) then
					for x, y in pairs(raidData.character.raids[v].regular.difficulties) do
						progressWeight = progressWeight + y.weight
					end

					for x, y in pairs(mapInfo.bosses) do
						for _, achievementID in ipairs(y.achievements) do
							local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID)

							local difficulty = string.find(name, "Normal") and 1 or string.find(name, "Heroic") and 2 or string.find(name, "Mythic") and 3

							if(difficulty and raidData.character.raids[v].regular.difficulties[difficulty]) then
								local raiderIODifficultyData = raidData.character.raids[v].regular.difficulties[difficulty]

								MIOG_NewSettings.accountStatistics[guid].raid[v].regular[difficulty] = {ingame = false, kills = raiderIODifficultyData.bossesKilled, bosses = raiderIODifficultyData.bosses}

								local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(id, 1, true)

								MIOG_NewSettings.accountStatistics[guid].raid[v].regular[difficulty].bosses[x] =  {id = id, criteriaID = criteriaID, killed = raiderIODifficultyData.bosses[x].killed, quantity = raiderIODifficultyData.bosses[x].count}

							end
						end
					end
				else
					break

				end
			end
		end

		MIOG_NewSettings.accountStatistics[guid].progressWeight = progressWeight
	end
end

function StatisticsTabMixin:UpdateCharacterMPlusStatistics(guid)
	local playerGUID = UnitGUID("player")

	if(guid == playerGUID) then
		MIOG_NewSettings.accountStatistics[playerGUID].mplus.score = {value = C_ChallengeMode.GetOverallDungeonScore(), ingame = true}

		for index, challengeMapID in pairs(mapTable or miog.SEASONAL_CHALLENGE_MODES[13] or C_ChallengeMode.GetMapTable()) do
			MIOG_NewSettings.accountStatistics[playerGUID].mplus[challengeMapID] = {}
	
			local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID)
	
			MIOG_NewSettings.accountStatistics[playerGUID].mplus[challengeMapID].intimeInfo = intimeInfo
			MIOG_NewSettings.accountStatistics[playerGUID].mplus[challengeMapID].overtimeInfo = overtimeInfo
			MIOG_NewSettings.accountStatistics[playerGUID].mplus[challengeMapID].overAllScore = intimeInfo and intimeInfo.dungeonScore or overtimeInfo and overtimeInfo.dungeonScore or 0
		end
	else
		MIOG_NewSettings.accountStatistics[guid].mplus.score = MIOG_NewSettings.accountStatistics[guid].mplus.score or {value = 0, ingame = true}

		if(MIOG_NewSettings.accountStatistics[guid].mplus.score.value == 0) then
			local mplusData = miog.getMPlusSortData(MIOG_NewSettings.accountStatistics[guid].name, MIOG_NewSettings.accountStatistics[guid].realm)

			if(mplusData) then
				MIOG_NewSettings.accountStatistics[guid].mplus.score = {value = mplusData.score.score, ingame = false}
			end
		end
		
		local mplusData, intimeInfo, overtimeInfo = miog.getMPlusSortData(MIOG_NewSettings.accountStatistics[guid].name, MIOG_NewSettings.accountStatistics[guid].realm, nil, true)
	
		for index, challengeMapID in pairs(mapTable or miog.SEASONAL_CHALLENGE_MODES[13] or C_ChallengeMode.GetMapTable()) do
			if(not MIOG_NewSettings.accountStatistics[guid].mplus[challengeMapID]) then
				MIOG_NewSettings.accountStatistics[guid].mplus[challengeMapID] = {}
				MIOG_NewSettings.accountStatistics[guid].mplus[challengeMapID].intimeInfo = intimeInfo and intimeInfo[challengeMapID]
				MIOG_NewSettings.accountStatistics[guid].mplus[challengeMapID].overtimeInfo = overtimeInfo and overtimeInfo[challengeMapID]

			end
		end
	end
end


function StatisticsTabMixin:LoadCharacters()
	self.Rows:Flush()
	
	local columnProvider = CreateDataProvider();

	if(self.id == 1) then
		columnProvider:SetSortComparator(sortByScore)

	elseif(self.id == 2) then
		columnProvider:SetSortComparator(sortByProgress)

	elseif(self.id == 3) then
		columnProvider:SetSortComparator(sortByRating)
		
	end

	local template = self.id == 1 and "MIOG_StatisticsDungeonCharacterTemplate" or self.id == 2 and "MIOG_StatisticsRaidCharacterTemplate" or self.id == 3 and "MIOG_StatisticsPVPCharacterTemplate"

	for k, v in pairs(MIOG_NewSettings.accountStatistics) do
		columnProvider:Insert({template = template, guid = k, name = v.name, realm = v.realm, classFile = v.classFile, score = v.mplus.score, progressWeight = v.progressWeight, rating = v.rating})

	end

	self.Rows:SetDataProvider(columnProvider)
end

function StatisticsTabMixin:UpdateStatistics()
    self:LoadActivities()

	self:RequestAccountCharacters()
	self:UpdateAllCharacterStatistics()

    self:LoadCharacters()
end