local addonName, miog = ...

ProgressTabMixin = {}

local accountCharacters

local seasonOverride

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

local function sortByCombined(k1, k2)
    if k1 and k2 then
        -- Check if either is the player's GUID
        if k1.guid == UnitGUID("player") then
            return true
        elseif k2.guid == UnitGUID("player") then
            return false
        end
        -- Compare scores
        return k1.combinedWeight > k2.combinedWeight
    elseif k1 then
        return true  -- k1 is valid, k2 is nil
    elseif k2 then
        return false -- k2 is valid, k1 is nil
    else
        return false -- Both are nil, order doesn't matter
    end

end

local function pvpOnEnter(selfFrame, tierTable)
    local tierInfo = C_PvP.GetPvpTierInfo(tierTable[1])
    local nextTierInfo = C_PvP.GetPvpTierInfo(tierTable[2])

    GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
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

	local intimeInfo = MIOG_NewSettings.accountStatistics.characters[playerGUID].mplus[challengeMapID].intimeInfo
	local overtimeInfo = MIOG_NewSettings.accountStatistics.characters[playerGUID].mplus[challengeMapID].overtimeInfo
	local overtimeHigher = intimeInfo and overtimeInfo and overtimeInfo.dungeonScore > intimeInfo.dungeonScore and true or false
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

local function raidOnEnter(self, playerGUID, mapID, difficulty, type)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, miog.MAP_INFO[mapID].name)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	if(MIOG_NewSettings.accountStatistics.characters[playerGUID].raid[mapID][type][difficulty]) then
		for k, v in ipairs(MIOG_NewSettings.accountStatistics.characters[playerGUID].raid[mapID][type][difficulty].bosses) do
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

		if(not MIOG_NewSettings.accountStatistics.characters[playerGUID].raid[mapID][type][difficulty].ingame) then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddNormalLine(GameTooltip, "This data has been pulled from RaiderIO, it may be not accurate.")
			GameTooltip_AddNormalLine(GameTooltip, "Login with this character to request official data from Blizzard.")

		end
	end

	GameTooltip:Show()
end

local function round(n)
	return math.floor(n+0.5)
 end


 -- 14 untimed 290, JIT 395, 2chest 402.5, 3chest 410, 1 affix (counts)
 -- 13 untimed 290, JIT 380, 2chest 387.5, 3chest 395, 1 affix
 -- 12 untimed 290, JIT 365, 2chest 372.5, 3chest 380, 1 affix

 -- 11 untimed 290, JIT 335, 2chest 342.5, 3chest 350, 4 affixes
 -- 10 untimed 290, JIT 320, 2chest 327.5, 3chest 335, 4 affixes

 -- 9 untimed 265, JIT 295, 2chest 302.5, 3chest 310, 3 affixes
 -- 8 untimed 250, JIT 280, 2chest 287.5, 3chest 295, 3 affixes
 -- 7 untimed 235, JIT 265, 2chest 272.5, 3chest 280, 3 affixes

 -- 6 untimed 205, JIT 235, 2chest 242.5, 3chest 250, 2 affixes
 -- 5 untimed 190, JIT 220, 2chest 227.5, 3chest 235, 2 affixes
 -- 4 untimed 175, JIT 205, 2chest 212.5, 3chest 220, 2 affixes

 -- 3 untimed 150, JIT 180, 2chest 187.5, 3chest 195, 1 affix
 -- 2 untimed 135, JIT 165, 2chest 172.5, 3chest 180, 1 affix

local function calculateMapScore(challengeMapID, info)
	local _, _, mapTimer = C_ChallengeMode.GetMapUIInfo(challengeMapID)

	if(info.durationSec > mapTimer * 1.4) then
		return 0
	end

	local timerDifference = (mapTimer - info.durationSec)
	local overtime = timerDifference <= 0

    local level = overtime and info.level > 10 and 10 or info.level

	local baseScore = 125 + level * 15
	local timerBonus = (timerDifference / (mapTimer * 0.4)) * 15
	local affixBonus = (level > 11 and 5 or level > 9 and 4 or level > 6 and 3 or level > 3 and 2 or 1) * 10
	local extraBonus = (level > 11 and 10 or level > 6 and 5 or 0)

	local finalScore = baseScore + timerBonus + affixBonus + extraBonus - (overtime and 15 or 0)

	return finalScore
end

miog.calculateMapScore = calculateMapScore

local function calculateNewScore(mapID, newLevel, guid, customTimer)
	local intimeInfo, overtimeInfo

	if(guid) then
		intimeInfo = MIOG_NewSettings.accountStatistics.characters[guid].mplus[mapID].intimeInfo
		overtimeInfo = MIOG_NewSettings.accountStatistics.characters[guid].mplus[mapID].overtimeInfo

		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(mapID)

		local overTimeGain, lowGain, highGain = 0, 0, 0

		local info = intimeInfo or overtimeInfo
		local dungeonScore = info and info.dungeonScore or 0
	
		overTimeGain = calculateMapScore(mapID, {level = newLevel, durationSec = customTimer <= 0 and timeLimit * (1 - (customTimer / 100)) or timeLimit})
		lowGain = calculateMapScore(mapID, {level = newLevel, durationSec = timeLimit - 0.1})
		highGain = calculateMapScore(mapID, {level = newLevel, durationSec = customTimer > 0 and timeLimit - timeLimit * (customTimer / 100) or timeLimit - 0.1})

		return max(round(overTimeGain - dungeonScore), 0), max(round(lowGain - dungeonScore), 0), max(round(highGain - dungeonScore), 0)
	end
	
	return 0, 0, 0
 end

function ProgressTabMixin:CreateDebugKeyInfo(fullName, rootDescription)
	local newKeystoneInfo = {}
	newKeystoneInfo.challengeMapID = 507
	newKeystoneInfo.level = 14
	newKeystoneInfo.mapID = 670
	newKeystoneInfo.classID = 4

	if(newKeystoneInfo and newKeystoneInfo.mapID > 0) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(newKeystoneInfo.challengeMapID)
		local className, classFile = GetClassInfo(newKeystoneInfo.classID)

		local shortName = miog.createSplitName(fullName)

		local text = WrapTextInColorCode(shortName, C_ClassColor.GetClassColor(classFile):GenerateHexColor()) .. ": " .. WrapTextInColorCode("+" .. newKeystoneInfo.level .. " " .. miog.MAP_INFO[newKeystoneInfo.mapID].shortName, miog.createCustomColorForRating(newKeystoneInfo.level * 130):GenerateHexColor())

		local keystoneButton = rootDescription:CreateRadio(text, function(fullCharacterName) return self.currentUnitName == fullCharacterName end, function(fullCharacterName)
			self.currentUnitName = fullCharacterName
			self.currentKeystoneInfo = newKeystoneInfo
	
			self:SetMPlusScoreInfo()

		end, fullName)

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

function ProgressTabMixin:CreateDropdownEntry(fullName, rootDescription)
	--self:CreateDebugKeyInfo(fullName, rootDescription)

	local keystoneInfo = miog.openRaidLib.GetAllKeystonesInfo()[fullName]

	if(keystoneInfo and keystoneInfo.mapID > 0) then
		local mapName, id, timeLimit, texture, background = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)
		local className, classFile = GetClassInfo(keystoneInfo.classID)

		local shortName = miog.createSplitName(fullName)

		local text = WrapTextInColorCode(shortName, C_ClassColor.GetClassColor(classFile):GenerateHexColor()) .. ": " .. WrapTextInColorCode("+" .. keystoneInfo.level .. " " .. miog.MAP_INFO[keystoneInfo.mapID].shortName, miog.createCustomColorForRating(keystoneInfo.level * 130):GenerateHexColor())

		local keystoneButton = rootDescription:CreateRadio(text, function(fullCharacterName) return self.currentUnitName == fullCharacterName end, function(fullCharacterName)
			self.currentUnitName = fullCharacterName
			self.currentKeystoneInfo = keystoneInfo
	
			self:SetMPlusScoreInfo()

		end, fullName)

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

function ProgressTabMixin:StartScoreCalculationForCharacter(frame, guid)
	if(frame) then
		if(self.currentKeystoneInfo and (guid == UnitGUID("player") or self.currentUnitName ~= miog.createFullNameFrom("unitID", "player"))) then
			local overtimeScore, minScore, maxScore = calculateNewScore(self.currentKeystoneInfo.challengeMapID, self.currentKeystoneInfo.level, guid, self.Info.TimelimitSlider:GetValue())
			frame.ScoreIncrease:SetText(WrapTextInColorCode(overtimeScore, miog.CLRSCC.red) .. "||" .. WrapTextInColorCode(minScore, miog.CLRSCC.yellow) .. "||" .. WrapTextInColorCode(maxScore, miog.CLRSCC.green))
			frame.ScoreIncrease:Show()

		else
			frame.ScoreIncrease:SetText("")
			frame.ScoreIncrease:Hide()

		end
	end
end

function ProgressTabMixin:StartScoreCalculationForAllCharacters()
	for k, v in self.Rows:EnumerateFrames() do
		self:StartScoreCalculationForCharacter(v, v:GetElementData().guid)

	end
end

function ProgressTabMixin:FindFrameWithMatchingDataElement(scrollList, element, value)
	for k, v in scrollList:EnumerateFrames() do
		if(v:GetElementData()[element] == value) then
			return v

		end
	end
end

function ProgressTabMixin:SetMPlusScoreInfo()
	if(self.currentKeystoneInfo) then
		local columnFrame

		for k, v in self.Columns:EnumerateFrames() do
			if(v:GetElementData().mapID == self.currentKeystoneInfo.mapID) then
				columnFrame = v

			end
		end

		if(columnFrame) then
			if(self.lastColumnFrame) then
				self.lastColumnFrame.TransparentDark:Show()
			end

			self.lastColumnFrame = columnFrame

			self.lastColumnFrame.TransparentDark:Hide()

			self.Selection:ClearAllPoints()
			self.Selection:SetPoint("TOPLEFT", columnFrame, "TOPLEFT")
			self.Selection:SetPoint("BOTTOMRIGHT", columnFrame, "BOTTOMRIGHT")
			self.Selection:Show()
		end

		if(self.currentUnitName == miog.createFullNameFrom("unitID", "player")) then
			local frame = self:FindFrameWithMatchingDataElement(self.Rows, "guid", UnitGUID("player"))

			self:StartScoreCalculationForCharacter(frame, UnitGUID("player"))

		else
			self:StartScoreCalculationForAllCharacters()

		end
	end
end

function ProgressTabMixin:OnLoad(id)
    self.id = id

    self:SetScript("OnShow", function()
        self:UpdateStatistics()

        if(IsInRaid()) then
            miog.openRaidLib.RequestKeystoneDataFromRaid()

        elseif(IsInGroup()) then
            miog.openRaidLib.RequestKeystoneDataFromParty()
        end
    end)

	if(self.id < 4) then
		miog.createFrameBorder(self.Selection, 1, CreateColorFromHexString(miog.CLRSCC.silver):GetRGBA())

		local activityView = CreateScrollBoxListLinearView();
		activityView:SetHorizontal(true)
		activityView:SetElementInitializer("MIOG_ProgressColumnTemplate", function(frame, data)
			local shortName
			if(data.type == "pvp") then
				local i = data.index

				shortName = i == 1 and ARENA_2V2 or i == 2 and ARENA_3V3 or i == 3 and ARENA_5V5 or BATTLEGROUND_10V10
				frame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/vertical/" .. shortName .. ".png")

			else
				local mapInfo = miog.MAP_INFO[data.mapID]
				shortName = mapInfo.shortName

				frame.Background:SetTexture(mapInfo.vertical, "MIRROR", "MIRROR")

			end

			frame.Name:SetText(shortName)

			miog.createFrameBorder(frame, 1, CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
		end)

		activityView:SetPadding(1, 1, 1, 1, 2);
		self.Columns:Init(activityView);

		local characterView = CreateScrollBoxListLinearView();
		local template = self.id == 1 and "MIOG_ProgressDungeonCharacterTemplate" or self.id == 2 and "MIOG_ProgressRaidCharacterTemplate" or self.id == 3 and "MIOG_ProgressPVPCharacterTemplate" or "MIOG_ProgressFullCharacterTemplate"

		characterView:SetElementInitializer(template, function(frame, data)
			frame.Name:SetText(data.name)
			frame.Name:SetTextColor(C_ClassColor.GetClassColor(data.classFile):GetRGBA())

			local isRaid = data.template == "MIOG_ProgressRaidCharacterTemplate"
			local isDungeon = data.template == "MIOG_ProgressDungeonCharacterTemplate"
			local isPvp = data.template == "MIOG_ProgressPVPCharacterTemplate"
			local isAll = data.template == "MIOG_ProgressFullCharacterTemplate"

			local file, height, flags = _G["SystemFont_Shadow_Med1"]:GetFont()

			if(data.guid == UnitGUID("player")) then
				frame.Name:SetFont(file, height + 2, flags)

				if(isDungeon) then
					frame.Score:SetFont(file, height + 2, flags)
					frame.ScoreIncrease:SetFont(file, height + 2, flags)

				elseif(isAll) then
					frame.Score:SetFont(file, height + 2, flags)

				end
			else
				frame.Name:SetFont(file, height, flags)

				if(isDungeon) then
					frame.Score:SetFont(file, height, flags)
					frame.ScoreIncrease:SetFont(file, height, flags)

				elseif(isAll) then
					frame.Score:SetFont(file, height, flags)

				end
			end
			
			if(self.id < 3) then
				if(MIOG_NewSettings.accountStatistics.characters[data.guid].nextRewards.availableTimestamp) then
					if(MIOG_NewSettings.accountStatistics.characters[data.guid].nextRewards.availableTimestamp < time()) then
						frame.VaultAvailable:SetAtlas("gficon-chest-evergreen-greatvault-collect")
						frame.VaultAvailable.tooltipText = MYTHIC_PLUS_COLLECT_GREAT_VAULT
					
					elseif(MIOG_NewSettings.accountStatistics.characters[data.guid].vaultProgress[self.id == 2 and 3 or 1]) then
						frame.VaultAvailable:SetAtlas("gficon-chest-evergreen-greatvault-complete")
						frame.VaultAvailable.tooltipText = "Your weekly rewards in your great vault will be available in " .. SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset(), true) .. "."

					else
						frame.VaultAvailable:SetAtlas("gficon-chest-evergreen-greatvault-incomplete")
						frame.VaultAvailable.tooltipText = "You have no activity in this category completed."

					end
				else
					frame.VaultAvailable:SetAtlas("gficon-chest-evergreen-greatvault-incomplete")
					frame.VaultAvailable.tooltipText = "No great vault activity yet completed."
					
				end

				frame.VaultAvailable:Show()
			end

			if(isDungeon) then
				frame.Score:SetText(data.score.value)

				self:StartScoreCalculationForCharacter(frame, data.guid)

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
					local dungeonFrame = frame["Dungeon" .. index]
					dungeonFrame:SetWidth(self.Columns:GetView():GetElementExtent())
					dungeonFrame:SetHeight(frame:GetHeight())
					dungeonFrame.challengeMapID = challengeMapID
					dungeonFrame.layoutIndex = index

					local intimeInfo = MIOG_NewSettings.accountStatistics.characters[data.guid].mplus[challengeMapID].intimeInfo
					local overtimeInfo = MIOG_NewSettings.accountStatistics.characters[data.guid].mplus[challengeMapID].overtimeInfo

					local overtimeHigher = intimeInfo and overtimeInfo and overtimeInfo.dungeonScore > intimeInfo.dungeonScore and true or false

					dungeonFrame.Level:SetText(overtimeHigher and overtimeInfo.level or intimeInfo and intimeInfo.level or 0)
					dungeonFrame.Level:SetTextColor(CreateColorFromHexString(overtimeHigher and overtimeInfo.level and miog.CLRSCC.red or intimeInfo and intimeInfo.level and miog.CLRSCC.green or miog.CLRSCC.gray):GetRGBA())
					dungeonFrame:SetScript("OnEnter", function(selfFrame)
						mplusOnEnter(selfFrame, data.guid)

					end) -- ChallengesDungeonIconMixin:OnEnter()
				end
			elseif(isRaid) then
				for index, mapID in ipairs(self.activityTable) do
					local raidFrame = frame["Raid" .. index]
					raidFrame:SetWidth(self.Columns:GetView():GetElementExtent())
					raidFrame:SetHeight(frame:GetHeight())
					raidFrame.layoutIndex = index

					for a = 1, 3, 1 do
						local current = a == 1 and raidFrame.Normal.Current or a == 2 and raidFrame.Heroic.Current or a == 3 and raidFrame.Mythic.Current
						--local previous = a == 1 and raidFrame.Normal.Previous or a == 2 and raidFrame.Heroic.Previous or a == 3 and raidFrame.Mythic.Previous

						if(current) then -- and previous
							local currentProgress = MIOG_NewSettings.accountStatistics.characters[data.guid].raid[mapID].regular[a]

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
				if(MIOG_NewSettings.accountStatistics.characters[data.guid].tierInfo[1]) then
					local tierInfo = C_PvP.GetPvpTierInfo(MIOG_NewSettings.accountStatistics.characters[data.guid].tierInfo[1])

					frame.Rank:SetTexture(tierInfo.tierIconID)
					frame.Rank:SetScript("OnEnter", function(selfFrame)
						pvpOnEnter(selfFrame, MIOG_NewSettings.accountStatistics.characters[data.guid].tierInfo)

					end)

					frame.Rank:SetScript("OnLeave", function()
						GameTooltip:Hide()

					end)


				end

				for i = 1, 4, 1 do
					local bracketFrame = frame["Bracket" .. i]
					bracketFrame:SetWidth(self.Columns:GetView():GetElementExtent())
					bracketFrame:SetHeight(frame:GetHeight())
					bracketFrame.layoutIndex = i

					local rating
					local seasonBest

					if(MIOG_NewSettings.accountStatistics.characters[data.guid].brackets[i]) then
						rating = MIOG_NewSettings.accountStatistics.characters[data.guid].brackets[i].rating
						seasonBest = MIOG_NewSettings.accountStatistics.characters[data.guid].brackets[i].seasonBest

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
			elseif(isAll) then
				frame.Score:SetText(data.score.value)

				for index, mapID in ipairs(self.activityTable) do
					for a = 1, 3, 1 do
						local current = a == 1 and frame.Normal or a == 2 and frame.Heroic or a == 3 and frame.Mythic
						--local previous = a == 1 and raidFrame.Normal.Previous or a == 2 and raidFrame.Heroic.Previous or a == 3 and raidFrame.Mythic.Previous

						if(current) then -- and previous
							local currentProgress = MIOG_NewSettings.accountStatistics.characters[data.guid].raid[mapID].regular[a]

							local text2 = (currentProgress and currentProgress.kills or 0) .. "/" .. #miog.MAP_INFO[mapID].bosses
							current:SetText(WrapTextInColorCode(text2, currentProgress and miog.DIFFICULTY[a].color or miog.CLRSCC.gray))

							current:SetScript("OnEnter", function(selfFrame)
								raidOnEnter(selfFrame, data.guid, mapID, a, "regular")
							end)

							current:SetScript("OnLeave", function()
								GameTooltip:Hide()
							end)
						end
					end
				end
			end

			characterView:RecalculateExtent(self.Rows)
		end)

		characterView:SetPadding(1, 1, 1, 1, 4)
		characterView:SetElementExtent(32)

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

			self.Info.TimelimitSlider:SetScript("OnValueChanged", function(selfSlider)
				self.Info.TimePercentage:SetText(round((selfSlider:GetValue() * -1)) .. "%")
		
				self:SetMPlusScoreInfo()
			end)
		else
			self.Info:Hide()

		end
	else
		local characterView = CreateScrollBoxListLinearView()
		characterView:SetHorizontal(true)

		characterView:SetElementInitializer("MIOG_ProgressFullCharacterTemplate", function(frame, data)
			local classID = miog.CLASSFILE_TO_ID[data.classFile]
			frame.Class:SetTexture(miog.CLASSES[classID].icon)
			frame.Spec:SetTexture(data.spec and miog.SPECIALIZATIONS[data.spec].squaredIcon or miog.SPECIALIZATIONS[0].squaredIcon)
			frame.Name:SetText(WrapTextInColorCode(data.name, C_ClassColor.GetClassColor(data.classFile):GenerateHexColor()))

			frame.MPlusRating:SetText(string.format(miog.STRING_REPLACEMENTS["MPLUSRATINGSHORT"], data.score.value))
			frame.MPlusRating:SetTextColor(miog.createCustomColorForRating(data.score.value):GetRGBA())

			local mplusData = {}
			
			for k, info in ipairs(data.seasonalData[seasonOverride or C_MythicPlus.GetCurrentSeason()].mplus.weeklyData) do
				tinsert(mplusData, info.score.value)

			end

			self.Graph:AddDataset({id= "mplus", name = data.name, class = data.classFile, values = mplusData})

			for k, v in ipairs(self.raidActivityTable) do
				miog.checkSingleMapIDForNewData(v, true)
				local numBosses = #miog.MAP_INFO[v].bosses

				for i = 1, 3, 1 do
					local raidProgressFrame = frame["RaidProgress" .. i]
					raidProgressFrame:SetText(string.format(miog.STRING_REPLACEMENTS["RAIDPROGRESS" .. i .. "SHORT"], (data.progress[v] and data.progress[v].regular and data.progress[v].regular[i] and data.progress[v].regular[i].kills or 0) .. "/" .. numBosses))
					raidProgressFrame:SetTextColor(miog.DIFFICULTY[i].miogColors:GetRGBA())

				end
			
				local weights = {}
				local kills = 0
				local difficulty
				local lastWeight = 0

				for i, info in ipairs(data.seasonalData[seasonOverride or C_MythicPlus.GetCurrentSeason()].raid.weeklyData) do
					weights[i] = 0

					if(info[v]) then
						for x, y in pairs(info[v].regular) do --difficulty loop
							weights[i] = weights[i] + miog.calculateWeightedScore(x, y.kills, #y.bosses, true, k)
							
							if(weights[i] > lastWeight and y.kills > 0) then
								kills = y.kills
								difficulty = miog.DIFFICULTY[x].shortName

								lastWeight = weights[i]
							end
						end
					end
				end

				self.Graph:AddDataset({id= "raid", name = data.name, class = data.classFile, text = (difficulty or "") .. ": " .. kills .. "/" .. numBosses, values = weights})
			end

			--[[for k, v in ipairs(self.pvpActivityTable) do
				frame["PVPRating" .. v]:SetText(string.format(miog.STRING_REPLACEMENTS["PVPRATING" .. v .. "SHORT"], (data.brackets[v] and data.brackets[v].rating or 0)))
			end]]

			frame.Itemlevel:SetText(string.format(miog.STRING_REPLACEMENTS["ILVLSHORT"], miog.round(data.ilvl, 2)))

			self.Graph:AddDataset({id= "ilvl", name = data.name, class = data.classFile, values = data.seasonalData[seasonOverride or C_MythicPlus.GetCurrentSeason()].ilvl.weeklyData})

			self.Graph:ResetAndDrawAllDatasets()
		end)

		characterView:SetPadding(1, 1, 1, 1, 2);
		self.Columns:Init(characterView);

		self.Graph:OnLoad()
		self.Graph:SetIdentifiers({
			{id = "mplus", name = "M+"},
			{id = "raid", name = "Raid"},
			{id = "ilvl", name = "I-Lvl"}
		}, MIOG_NewSettings.lastSetCheckboxes, "Progress")

	end
end

 --workaround, gets most characters if they've been converted with the warband feature, you don't even have to be logged in first or used this addon.
 --just has to have atleast a single type of currency (money (copper, silver, gold) doesn't count)
function ProgressTabMixin:RequestAccountCharacters()
	C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
	
	accountCharacters = {}

	local charList = {}
	local info

	local playerGUID = UnitGUID("player")
	local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(playerGUID)
	local specID = GetSpecializationInfo(GetSpecialization())
	table.insert(accountCharacters, {guid = playerGUID, name = name, realm = realmName, classFile = englishClass, spec = specID})

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

		table.insert(accountCharacters, {guid = k, name = name, realm = realmName, classFile = englishClass})
	end
end

function HasRewardsComingReset()
	for i, activityInfo in ipairs(C_WeeklyRewards.GetActivities()) do
		if(activityInfo.progress >= activityInfo.threshold) then
			return true
		end
	end

	return false
end

local function checkIfItsTheFirstWeekOfSeasonForCharacter(guid)
	if(not MIOG_NewSettings.accountStatistics.characters[guid].seasonID) then
		MIOG_NewSettings.accountStatistics.characters[guid].seasonID = seasonOverride or C_MythicPlus.GetCurrentSeason()

		return true, "new"

	elseif((seasonOverride or C_MythicPlus.GetCurrentSeason()) > MIOG_NewSettings.accountStatistics.characters[guid].seasonID) then
		MIOG_NewSettings.accountStatistics.characters[guid].seasonID = seasonOverride or C_MythicPlus.GetCurrentSeason()
		
		return true, "next"

	end

	return false, (seasonOverride or C_MythicPlus.GetCurrentSeason()) == -1 and "offseason" or "old"
end

local function addSeasonalChartData(guid)
	local seasonID = seasonOverride or C_MythicPlus.GetCurrentSeason()

	MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID] = MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID] or {mplus = {weeklyData = {}}, raid = {weeklyData = {}}, pvp = {weeklyData = {}}, ilvl = {weeklyData = {}}, }

	if(seasonID ~= -1) then
		if(not MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.nextWeek or MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.nextWeek <= time()) then
			MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter = MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter and MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter + 1 or 1
			MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.nextWeek = time() + C_DateAndTime.GetSecondsUntilWeeklyReset()

			local lastWeek = MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter - 1

			if(lastWeek - 1 ~= 0) then
				MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID].mplus.weeklyData[lastWeek] = MIOG_NewSettings.accountStatistics.characters[guid].mplus
				MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID].raid.weeklyData[lastWeek] = MIOG_NewSettings.accountStatistics.characters[guid].raid
				MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID].pvp.weeklyData[lastWeek] = MIOG_NewSettings.accountStatistics.characters[guid].pvp
				MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID].ilvl.weeklyData[lastWeek] = MIOG_NewSettings.accountStatistics.characters[guid].ilvl
			end
		end
		
		MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID].mplus.weeklyData[MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter] = MIOG_NewSettings.accountStatistics.characters[guid].mplus
		MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID].raid.weeklyData[MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter] = MIOG_NewSettings.accountStatistics.characters[guid].raid
		MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID].pvp.weeklyData[MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter] = MIOG_NewSettings.accountStatistics.characters[guid].pvp
		MIOG_NewSettings.accountStatistics.characters[guid].seasonalData[seasonID].ilvl.weeklyData[MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter] = MIOG_NewSettings.accountStatistics.characters[guid].ilvl

	else
		MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.weekCounter = 0
		MIOG_NewSettings.accountStatistics.characters[guid].seasonalData.nextWeek = time() + C_DateAndTime.GetSecondsUntilWeeklyReset()
		
	end
end

--C_WeeklyRewards.AreRewardsForCurrentRewardPeriod()
--C_WeeklyRewards.HasAvailableRewards()
--C_WeeklyRewards.HasGeneratedRewards()
--C WeeklyRewards.CanClaimRewards()

local function addVaultProgress(guid)
	local hasRewardComing = HasRewardsComingReset()

	MIOG_NewSettings.accountStatistics.characters[guid].vaultProgress = {}

	MIOG_NewSettings.accountStatistics.characters[guid].nextRewards = {
		hasRewardComingReset = hasRewardComing,
		rewardsForCurrentPeriod = C_WeeklyRewards.AreRewardsForCurrentRewardPeriod(),
		hasAvailableRewards = C_WeeklyRewards.HasAvailableRewards(),
		hasGeneratedRewards = C_WeeklyRewards.HasGeneratedRewards(),
		canClaimRewards = C_WeeklyRewards.CanClaimRewards(),
		availableTimestamp = hasRewardComing and (time() + C_DateAndTime.GetSecondsUntilWeeklyReset()) or nil
	}

	for i, activityInfo in ipairs(C_WeeklyRewards.GetActivities()) do
		MIOG_NewSettings.accountStatistics.characters[guid].vaultProgress[activityInfo.type] = MIOG_NewSettings.accountStatistics.characters[guid].vaultProgress[activityInfo.type] or {}
		
		tinsert(MIOG_NewSettings.accountStatistics.characters[guid].vaultProgress[activityInfo.type], activityInfo)

	end
end

function ProgressTabMixin:CreateCharacterTables(guid, v)
	MIOG_NewSettings.accountStatistics.characters[guid] = MIOG_NewSettings.accountStatistics.characters[guid] or {}
	MIOG_NewSettings.accountStatistics.characters[guid].name = MIOG_NewSettings.accountStatistics.characters[guid].name or v.name
	MIOG_NewSettings.accountStatistics.characters[guid].fullName = MIOG_NewSettings.accountStatistics.characters[guid].fullName or miog.createFullNameFrom("unitName", v.name .. "-" .. v.realm)
	MIOG_NewSettings.accountStatistics.characters[guid].spec = MIOG_NewSettings.accountStatistics.characters[guid].spec or v.spec
	MIOG_NewSettings.accountStatistics.characters[guid].classFile = MIOG_NewSettings.accountStatistics.characters[guid].classFile or v.classFile
	MIOG_NewSettings.accountStatistics.characters[guid].mplus = MIOG_NewSettings.accountStatistics.characters[guid].mplus or {}
	MIOG_NewSettings.accountStatistics.characters[guid].raid = MIOG_NewSettings.accountStatistics.characters[guid].raid or {}
	MIOG_NewSettings.accountStatistics.characters[guid].pvp = MIOG_NewSettings.accountStatistics.characters[guid].pvp or {}
	MIOG_NewSettings.accountStatistics.characters[guid].seasonalData = MIOG_NewSettings.accountStatistics.characters[guid].seasonalData or {}
	MIOG_NewSettings.accountStatistics.characters[guid].nextRewards = MIOG_NewSettings.accountStatistics.characters[guid].nextRewards or {}
end

function ProgressTabMixin:UpdateAllCharacterStatistics(updateMPlus, updateRaid, updatePvp)
	if(not accountCharacters) then
		self:RequestAccountCharacters()
	end

	for _, v in ipairs(accountCharacters) do
		self:CreateCharacterTables(v.guid, v)

	end

	for guid, v in pairs(MIOG_NewSettings.accountStatistics.characters) do
		self:CreateCharacterTables(guid, v)

		local firstWeek, newOrNext = checkIfItsTheFirstWeekOfSeasonForCharacter(guid)

		if(firstWeek and newOrNext == "next") then
			MIOG_NewSettings.accountStatistics.characters[guid].mplus = {}
			MIOG_NewSettings.accountStatistics.characters[guid].raid = {}
			MIOG_NewSettings.accountStatistics.characters[guid].pvp = {}

		end
		
		if(self.activityTable) then
			if(self.id == 1 or updateMPlus) then
				self:UpdateCharacterMPlusStatistics(guid)

			elseif(self.id == 2 or updateRaid) then
				self:UpdateCharacterRaidStatistics(guid)

			elseif(self.id == 3 or updatePvp) then
				self:UpdatePVPStatistics(guid)

			end
		else
			self:UpdateCharacterMPlusStatistics(guid)
			self:UpdateCharacterRaidStatistics(guid)
			self:UpdatePVPStatistics(guid)
		end

		if(guid == UnitGUID("player")) then
			addVaultProgress(guid)

			MIOG_NewSettings.accountStatistics.characters[guid].ilvl = select(2, GetAverageItemLevel()) or MIOG_NewSettings.accountStatistics.characters[guid].ilvl

		else
			MIOG_NewSettings.accountStatistics.characters[guid].ilvl = MIOG_NewSettings.accountStatistics.characters[guid].ilvl or 0

		end

		addSeasonalChartData(guid)
	end
end

function ProgressTabMixin:LoadActivities()
	if(self.id == 1) then --M+
		self.activityTable = C_ChallengeMode.GetMapTable()

	elseif(self.id == 2) then --RAID
		local raidInfo = {}
		local raidGroups = C_LFGList.GetAvailableActivityGroups(3, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion))
	
		for k, v in ipairs(raidGroups) do
			local activities = C_LFGList.GetAvailableActivities(3, v)
			local activityID = activities[#activities]
	
			tinsert(raidInfo, miog.ACTIVITY_INFO[activityID].mapID)
		end

		self.activityTable = raidInfo

	elseif(self.id == 3) then --PVP
		self.activityTable = {1, 2, 3, 4}

	else
		self.mplusActivityTable = C_ChallengeMode.GetMapTable()

		local raidInfo = {}
		local raidGroups = C_LFGList.GetAvailableActivityGroups(3, bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion))
	
		for k, v in ipairs(raidGroups) do
			local activities = C_LFGList.GetAvailableActivities(3, v)
			local activityID = activities[#activities]
	
			tinsert(raidInfo, miog.ACTIVITY_INFO[activityID].mapID)
		end

		self.raidActivityTable = raidInfo

		self.pvpActivityTable = {1, 2, 3, 4}
	end

	if(self.id < 4) then
		if(self.id < 3) then
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
				miog.checkForMapAchievements(activityEntry)
				
				columnProvider:Insert({mapID = activityEntry});

			elseif(self.id == 3) then
				columnProvider:Insert({type = "pvp", index = activityEntry});

			end
		end

		self.Columns:GetView():SetElementExtent(400 / #self.activityTable)
		self.Columns:SetDataProvider(columnProvider);
	else
		self.Graph:ReleaseEverything()

	end
end

function ProgressTabMixin:CalculateProgressWeightViaAchievements(guid)
	local character = MIOG_NewSettings.accountStatistics.characters[guid]
	local progressWeight = 0

	for k, v in ipairs(self.activityTable or self.raidActivityTable) do
		if(character.raid[v].regular) then
			for difficultyIndex, table in pairs(character.raid[v].regular) do
				progressWeight = progressWeight + miog.calculateWeightedScore(difficultyIndex, table.kills, #table.bosses, true, 1)


			end
		else
			progressWeight = progressWeight + 0

		end
	end

	MIOG_NewSettings.accountStatistics.characters[guid].progressWeight = progressWeight
end

function ProgressTabMixin:UpdatePVPStatistics(guid)
	local playerGUID = UnitGUID("player")

    if(guid == playerGUID) then
		local highestRating = 0

		MIOG_NewSettings.accountStatistics.characters[playerGUID].brackets = {}

		for i = 1, 4, 1 do
			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, cap = GetPersonalRatedInfo(i) -- 1 == 2v2, 2 == 3v3, 3 == 5v5, 4 == 10v10

			MIOG_NewSettings.accountStatistics.characters[playerGUID].brackets[i] = {rating = rating, seasonBest = seasonBest}

			highestRating = rating > highestRating and rating or highestRating

		end

		local tierID, nextTierID = C_PvP.GetSeasonBestInfo();

		MIOG_NewSettings.accountStatistics.characters[playerGUID].tierInfo = {tierID, nextTierID}
		MIOG_NewSettings.accountStatistics.characters[playerGUID].rating = highestRating

	else
		MIOG_NewSettings.accountStatistics.characters[guid].brackets = MIOG_NewSettings.accountStatistics.characters[guid].brackets or {}
		MIOG_NewSettings.accountStatistics.characters[guid].tierInfo = MIOG_NewSettings.accountStatistics.characters[guid].tierInfo or {}
		MIOG_NewSettings.accountStatistics.characters[guid].rating = MIOG_NewSettings.accountStatistics.characters[guid].rating or 0

	end
end

local function checkForAchievements(type, guid, mapID)
	local currTable
	
	if(type == "awakened") then
		currTable = miog.MAP_INFO[mapID].achievementsAwakened

	else
		if(not miog.MAP_INFO[mapID].achievementTable) then
			miog.checkForMapAchievements(mapID)

		end

		currTable = miog.MAP_INFO[mapID].achievementTable

	end

	for k, d in ipairs(currTable) do
		local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(d)

		local searchFor = type == "awakened" and description or name

		local difficulty = string.find(searchFor, "Normal") and 1 or string.find(searchFor, "Heroic") and 2 or string.find(searchFor, "Mythic") and 3

		if(difficulty) then
			MIOG_NewSettings.accountStatistics.characters[guid].raid[mapID][type][difficulty] = MIOG_NewSettings.accountStatistics.characters[guid].raid[mapID][type][difficulty] or {ingame = true, kills = 0, bosses = {}}

			local numCriteria = type == "regular" and 1 or GetAchievementNumCriteria(d)

			for i = 1, numCriteria, 1 do
				local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(id, i, true)

				if(completedCriteria) then
					MIOG_NewSettings.accountStatistics.characters[guid].raid[mapID][type][difficulty].kills = MIOG_NewSettings.accountStatistics.characters[guid].raid[mapID][type][difficulty].kills + 1
					
				end

				table.insert(MIOG_NewSettings.accountStatistics.characters[guid].raid[mapID][type][difficulty].bosses, {id = id, criteriaID = criteriaID, killed = completedCriteria, quantity = quantity})
			end
		end
	end
end

function ProgressTabMixin:UpdateCharacterRaidStatistics(guid)
	if(self.activityTable or self.raidActivityTable) then
		local playerGUID = UnitGUID("player")

		if(guid == playerGUID) then
			for _, mapID in ipairs(self.activityTable or self.raidActivityTable) do
				MIOG_NewSettings.accountStatistics.characters[guid].raid[mapID] = {regular = {}, awakened = {}}

				if(miog.MAP_INFO[mapID].achievementsAwakened) then
					checkForAchievements("awakened", guid, mapID)
				end

				checkForAchievements("regular", guid, mapID)
			end

			self:CalculateProgressWeightViaAchievements(guid)
		else
			local raidData = miog.getNewRaidSortData(MIOG_NewSettings.accountStatistics.characters[guid].name, MIOG_NewSettings.accountStatistics.characters[guid].realm)

			local progressWeight = MIOG_NewSettings.accountStatistics.characters[guid].progressWeight or 0

			for k, v in ipairs(self.activityTable or self.raidActivityTable) do
				if(not MIOG_NewSettings.accountStatistics.characters[guid].raid[v] and raidData and raidData.character) then
					MIOG_NewSettings.accountStatistics.characters[guid].raid[v] = {regular = {}, awakened = {}}

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
									

									MIOG_NewSettings.accountStatistics.characters[guid].raid[v].regular[difficulty] = {ingame = false, kills = raiderIODifficultyData.kills, bosses = raiderIODifficultyData.bosses}

									local criteriaString, criteriaType, completedCriteria, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible = GetAchievementCriteriaInfo(id, 1, true)

									MIOG_NewSettings.accountStatistics.characters[guid].raid[v].regular[difficulty].bosses[x] =  {id = id, criteriaID = criteriaID, killed = raiderIODifficultyData.bosses[x].killed, quantity = raiderIODifficultyData.bosses[x].count}

								end
							end
						end
					else
						break

					end
				end
			end

			MIOG_NewSettings.accountStatistics.characters[guid].progressWeight = progressWeight
		end
	end
end

function ProgressTabMixin:UpdateCharacterMPlusStatistics(guid)
	if(self.activityTable or self.mplusActivityTable) then
		local playerGUID = UnitGUID("player")

		if(guid == playerGUID) then
			MIOG_NewSettings.accountStatistics.characters[guid].mplus.score = {value = C_ChallengeMode.GetOverallDungeonScore(), ingame = true}

			for _, challengeMapID in pairs(self.activityTable or self.mplusActivityTable) do
				MIOG_NewSettings.accountStatistics.characters[guid].mplus[challengeMapID] = {}

				local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID)

				MIOG_NewSettings.accountStatistics.characters[guid].mplus[challengeMapID].intimeInfo = intimeInfo
				MIOG_NewSettings.accountStatistics.characters[guid].mplus[challengeMapID].overtimeInfo = overtimeInfo
			end
		else
			MIOG_NewSettings.accountStatistics.characters[guid].mplus.score = MIOG_NewSettings.accountStatistics.characters[guid].mplus.score or {value = 0, ingame = true}

			local mplusData, intimeInfo, overtimeInfo = miog.getMPlusSortData(MIOG_NewSettings.accountStatistics.characters[guid].name, MIOG_NewSettings.accountStatistics.characters[guid].realm, nil, true)

			if(mplusData) then
				if(MIOG_NewSettings.accountStatistics.characters[guid].mplus.score.value == 0) then
					MIOG_NewSettings.accountStatistics.characters[guid].mplus.score = {value = mplusData.score.score, ingame = false}
				end
			end

			for _, challengeMapID in pairs(self.activityTable or self.mplusActivityTable) do
				MIOG_NewSettings.accountStatistics.characters[guid].mplus[challengeMapID] = {}
				MIOG_NewSettings.accountStatistics.characters[guid].mplus[challengeMapID].intimeInfo = intimeInfo and intimeInfo[challengeMapID] or MIOG_NewSettings.accountStatistics.characters[guid].mplus[challengeMapID].intimeInfo
				MIOG_NewSettings.accountStatistics.characters[guid].mplus[challengeMapID].overtimeInfo = overtimeInfo and overtimeInfo[challengeMapID] or MIOG_NewSettings.accountStatistics.characters[guid].mplus[challengeMapID].overtimeInfo
			end
		end
	end
end


function ProgressTabMixin:LoadCharacters()
	local scrollBox = self.id == 4 and self.Columns or self.Rows
	scrollBox:Flush()

	local dataProvider = CreateDataProvider();

	if(self.id == 1) then
		dataProvider:SetSortComparator(sortByScore)

	elseif(self.id == 2) then
		dataProvider:SetSortComparator(sortByProgress)

	elseif(self.id == 3) then
		dataProvider:SetSortComparator(sortByRating)

	else
		dataProvider:SetSortComparator(sortByCombined)

	end

	local template = self.id == 1 and "MIOG_ProgressDungeonCharacterTemplate" or self.id == 2 and "MIOG_ProgressRaidCharacterTemplate" or self.id == 3 and "MIOG_ProgressPVPCharacterTemplate" or "MIOG_ProgressFullCharacterTemplate"
	local counter = 1

	for k, v in pairs(MIOG_NewSettings.accountStatistics.characters) do
		dataProvider:Insert({
			template = template,
			guid = k,
			name = v.name,
			realm = v.realm,
			classFile = v.classFile,
			spec = v.spec,
			ilvl = v.ilvl,

			score = v.mplus.score,
			brackets = v.brackets,
			rating = v.rating,
			progress = v.raid,
			progressWeight = v.progressWeight,
			combinedWeight = v.mplus.score.value + v.progressWeight + v.rating,

			seasonalData = v.seasonalData,
		})

		counter = counter + 1
	end

	if(self.id == 4) then
		dataProvider:RemoveIndexRange(floor(self:GetWidth() / 100) + 1, dataProvider:GetSize())

	end

	scrollBox:SetDataProvider(dataProvider)
end

function ProgressTabMixin:UpdateStatistics(updateMPlus, updateRaid, updatePvp)
	self:LoadActivities()

	self:UpdateAllCharacterStatistics(updateMPlus, updateRaid, updatePvp)

	self:LoadCharacters()
end