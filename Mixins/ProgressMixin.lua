local addonName, miog = ...

local playerGUID = UnitGUID("player")
local fullPlayerName = UnitFullName("player")
local initialRefreshDone = false

local pvpActivities = {
	1,
	2,
	--3,
	4,
	7,
	9,
}

ProgressSettingsConnectMixin = {}

function ProgressSettingsConnectMixin:ConnectSetting(settingsTable)
	self.settings = settingsTable
	self.characterSettings = settingsTable.characters

end

ProgressMixin = CreateFromMixins(ProgressSettingsConnectMixin)

function ProgressMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("WEEKLY_REWARDS_UPDATE")

	for i = 1, 3, 1 do
        local raidProgressFrame = i == 1 and self.Info.Normal.Text or i == 2 and self.Info.Heroic.Text or i == 3 and self.Info.Mythic.Text
        raidProgressFrame:SetTextColor(miog.DIFFICULTY[i].miogColors:GetRGBA())

	end

    self.Info.MythicPlusRating.Text:SetTextColor(miog.DIFFICULTY[4].miogColors:GetRGBA())
	self.Info.ResilientLevel.Text:SetTextColor(miog.ITEM_QUALITY_COLORS[6].color:GetRGBA())
end

function ProgressMixin:SetupInitialCharacterData(setupTable)
	self:ConnectSetting(setupTable)
	self:RequestAccountCharacters()

end

function ProgressMixin:RequestAccountCharacters()
    C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()

	local charList = {}

    local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize()
    for currencyIndex = 1, numTokenTypes do
		local currencyData = C_CurrencyInfo.GetCurrencyListInfo(currencyIndex)
		local accountCurrencyData = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyData.currencyID)

		if(accountCurrencyData) then
			for k, v in pairs(accountCurrencyData) do
				charList[v.characterGUID] = true

			end
		end
	end

	local localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(playerGUID)
	local specID = GetSpecializationInfo(GetSpecialization())
	local itemLevel = select(2, GetAverageItemLevel())

	local playerSettings = self.characterSettings[playerGUID]

	if(not playerSettings) then
		self.characterSettings[playerGUID] = {guid = playerGUID, name = name, realmName = realmName, fileName = englishClass, specID = specID, itemLevel = itemLevel,}

	else
		playerSettings.name = name
		playerSettings.realmName = realmName
		playerSettings.fileName = englishClass
		playerSettings.guid = playerGUID

		--Only player stats
		playerSettings.specID = specID
		playerSettings.itemLevel = itemLevel

	end

	for guid, v in pairs(charList) do
		localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(guid)

		local charSettings = self.characterSettings[guid]

		if(not charSettings) then
			self.characterSettings[guid] = {guid = guid, name = name, realmName = realmName, fileName = englishClass}

		else
			charSettings.name = name
			charSettings.guid = guid
			charSettings.realmName = realmName
			charSettings.fileName = englishClass

		end
	end
end

function ProgressMixin:RefreshGreatVaultProgress()
	local greatVaultData = {}
	local hasRewardOnReset = false

	for i, activityInfo in ipairs(C_WeeklyRewards.GetActivities()) do
		if(activityInfo.index == 1) then
			greatVaultData[activityInfo.type] = {}

		end

		greatVaultData[activityInfo.type][activityInfo.index] = activityInfo

		if(activityInfo.progress > activityInfo.threshold) then
			hasRewardOnReset = true

		end
	end

	local resetTime = time() + C_DateAndTime.GetSecondsUntilWeeklyReset()

	self.settings.greatVault = {
		resetTime = resetTime,
	}

	self.characterSettings[playerGUID].greatVault = {
		hasRewardOnReset = hasRewardOnReset,
		resetTime = resetTime,
		canClaimRewards = C_WeeklyRewards.CanClaimRewards(),
		hasGeneratedRewards = C_WeeklyRewards.HasGeneratedRewards(), --need to test function
		hasAvailableRewards = C_WeeklyRewards.HasAvailableRewards(),
		rewardsFromLastWeek = C_WeeklyRewards.AreRewardsForCurrentRewardPeriod(),
		activities = greatVaultData
	}
end

function ProgressMixin:RefreshAllData()
	self:RequestAccountCharacters()
	self:RefreshGreatVaultProgress()

	self.MythicPlus:UpdateAllCharactersProgressData()
	self.Raid:UpdateAllCharactersProgressData()
	self.PVP:UpdateAllCharactersProgressData()
	self.Overview:RefreshActivities()
end

function ProgressMixin:OnShow()
	self:RefreshAllData()

end

function ProgressMixin:OnEvent(event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		local isInitialLogin = ...

		if(isInitialLogin) then
			self:RefreshAllData()
			initialRefreshDone = true
		end
	elseif(event == "WEEKLY_REWARDS_UPDATE") then
		if(self.characterSettings and self.characterSettings[playerGUID]) then
			self:RefreshGreatVaultProgress()

		end
	end
end




ProgressActivityMixin = CreateFromMixins(ProgressSettingsConnectMixin)

function ProgressActivityMixin:GetNumberOfVisibleActivities()
	local counter = 0

	for _, v in pairs(self.activities) do
		if(self.settings.activities[v] and self.settings.activities[v].visible) then
			counter = counter + 1

		end
	end

	return counter
end

function ProgressActivityMixin:GetBackgroundImage(id)

end

function ProgressActivityMixin:GetAbbreviatedName(id)

end

function ProgressActivityMixin:GetNameAndBackground(id)
	return self:GetBackgroundImage(id), self:GetAbbreviatedName(id)
end

function ProgressActivityMixin:SortActivities()
	table.sort(self.activities, function(k1, k2)
		return k1 > k2

	end)
end

function ProgressActivityMixin:RefreshActivities()
	if(self.settings) then
		self.tableBuilder:Reset()

		local column = self.tableBuilder:AddColumn()
		column:ConstructHeader("Frame", "MIOG_ProgressActivityHeaderTemplate")
		column:SetFixedConstraints(90)
		column:ConstructCells("Frame", self.characterTemplate)

		tinsert(self.Columns, column)

		local availableWidth = self.ScrollBox:GetWidth() - column.headerFrame:GetWidth() - 50

		local numOfActivities = self:GetNumberOfVisibleActivities()

		for k, v in ipairs(self.activities) do
			if(self.settings.activities[v] and self.settings.activities[v].visible) then
				local bg, abbreviatedName = self:GetNameAndBackground(v)

				column = self.tableBuilder:AddColumn()
				column:ConstructHeader("Frame", "MIOG_ProgressActivityHeaderTemplate", abbreviatedName)

				tinsert(self.Columns, column)

				self.BackgroundTextures[v] = self.BackgroundTextures[v] or self:CreateTexture(nil, "BACKGROUND", nil, 0)
				self.BorderTextures[v] = self.BorderTextures[v] or self:CreateTexture(nil, "BACKGROUND", nil, -1)

				local borderTexture = self.BorderTextures[v]
				borderTexture:SetPoint("TOPLEFT", column.headerFrame, "TOPLEFT")
				borderTexture:SetPoint("BOTTOM", self, "BOTTOM")
				borderTexture:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR):GetRGBA())
				borderTexture:Show()

				local backgroundTexture = self.BackgroundTextures[v]
				backgroundTexture:SetPoint("TOPLEFT", borderTexture, "TOPLEFT", 1, -1)
				backgroundTexture:SetPoint("BOTTOMRIGHT", borderTexture, "BOTTOMRIGHT", -1, 1)
				backgroundTexture:SetVertTile(true)
				backgroundTexture:SetHorizTile(true)
				backgroundTexture:Show()

				self.BackgroundTextures[v]:SetTexture(bg, "MIRROR", "MIRROR")
				self.BorderTextures[v]:SetWidth(column.headerFrame:GetWidth())

				if(numOfActivities > 0) then
					local width = availableWidth / numOfActivities
					column:SetFixedConstraints(width, 3)
					self.BorderTextures[v]:SetWidth(width)

				else
					self.BorderTextures[v]:SetWidth(column.headerFrame:GetWidth())

				end
				column:ConstructCells("Frame", self.cellTemplate, v)

			else
				local borderTexture = self.BorderTextures[v]
				local backgroundTexture = self.BackgroundTextures[v]

				if(borderTexture and backgroundTexture) then
					borderTexture:Hide()
					backgroundTexture:Hide()

				end
			end
		end

		self.tableBuilder:Arrange()
		--self.tableBuilder:EnableRowDividers()
	end
end

function ProgressActivityMixin:LoadActivities()
	self:SortActivities()
end

function ProgressActivityMixin:UpdateAllCharactersVisibleData()

end

function ProgressActivityMixin:OnLoad()
	self.BackgroundTextures = {}
	self.BorderTextures = {}
	self.Columns = {}

	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("MIOG_ProgressLineTemplate", function(frame, data)

	end)

	view:SetPadding(1, 1, 1, 1, 8)
	view:SetElementExtent(36)

	self.ScrollBox:Init(view)

	self.tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
	self.tableBuilder:SetHeaderContainer(self.HeaderContainer)
	self.tableBuilder:SetTableMargins(5, 5)
	local function ElementDataProvider(elementData)
		return elementData
	end
	self.tableBuilder:SetDataProvider(ElementDataProvider)
	local function ElementDataTranslator(elementData)
		return elementData
	end
	ScrollUtil.RegisterTableBuilder(self.ScrollBox, self.tableBuilder, ElementDataTranslator)
end






ProgressOverviewMixin = CreateFromMixins(ProgressActivityMixin)

function ProgressOverviewMixin:CheckLockoutExpiration()
    for index, data in pairs(self.characterSettings[playerGUID].lockouts) do
		if(data.resetDate <= time()) then
			self.characterSettings[playerGUID].lockouts[index] = nil

		end
    end
end

function ProgressOverviewMixin:RefreshLockouts()
    if(self.characterSettings and self.characterSettings[playerGUID]) then
		self.characterSettings[playerGUID].lockouts = self.characterSettings[playerGUID].lockouts or {}

		for index = 1, GetNumSavedInstances(), 1 do
			local name, lockoutId, reset, difficultyId, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId = GetSavedInstanceInfo(index)

			if(lockoutId > 0 and reset > 0) then
				local allBossesAlive = true
				local bosses = {}

				for i = 1, numEncounters, 1 do
					local bossName, fileDataID, isKilled, unknown4 = GetSavedInstanceEncounterInfo(index, i)

					bosses[i] = {bossName = bossName, isKilled = isKilled}

					if(isKilled) then
						allBossesAlive = false
					end
				end

				if(not allBossesAlive) then
					local journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(instanceId)
					local _, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, _ = EJ_GetInstanceInfo(journalInstanceID)

					tinsert(self.characterSettings[playerGUID].lockouts, {
						id = lockoutId,
						name = name,
						difficulty = difficultyId,
						extended = extended,
						isRaid = isRaid,
						icon = buttonImage1,
						mapID = instanceId,
						index = index,
						numEncounters = numEncounters,
						cleared = numEncounters == encounterProgress,
						resetDate = time() + reset,
						bosses = bosses
					})
				end
			end
		end

		for i = 1, GetNumSavedWorldBosses(), 1 do
			local name, worldBossID, reset = GetSavedWorldBossInfo(i)

			tinsert(self.characterSettings[playerGUID].lockouts, {
				id = worldBossID,
				name = name,
				isWorldBoss = true,
				resetDate = time() + reset,
			})
		end
	end
end

function ProgressOverviewMixin:LoadActivities()
	if(not self.mythicPlusActivities or #self.mythicPlusActivities == 0) then
		self.mythicPlusActivities = C_ChallengeMode.GetMapTable()

	end

	if(not self.raidActivities or #self.raidActivities == 0) then
		local groups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion) or Enum.LFGListFilter.Recommended)
		local raidActivities = {}

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(3, v)
			local activityID = activities[#activities]
			local name, order = C_LFGList.GetActivityGroupInfo(v)
			local activityInfo = miog.requestActivityInfo(activityID)
			local mapID = activityInfo.mapID

			miog.checkSingleMapIDForNewData(mapID, true)
			--miog.checkForMapAchievements(mapID)

			tinsert(raidActivities, {name = name, order = order, activityID = activityID, mapID = mapID})
		end

		table.sort(raidActivities, function(k1, k2)
			if(k1.order == k2.order) then
				return k1.activityID > k2.activityID

			end

			return k1.order < k2.order
		end)

		self.raidActivities = raidActivities

		if(raidActivities[1]) then
			self.currentRaidMapID = raidActivities[1].mapID

		end
	end
end

local function sortOverviewCharacters(k1, k2)
	if(k1.guid == playerGUID) then
		return true
		
	elseif(k2.guid == playerGUID) then
		return false

	elseif(k1.sortWeight ~= k2.sortWeight) then
		return k1.sortWeight > k2.sortWeight

	elseif(k1.itemLevel and k2.itemLevel) then
		return k1.itemLevel > k2.itemLevel

	elseif(k1.itemLevel) then
		return true

	elseif(k2.itemLevel) then
		return false

	end

	return k1.name > k2.name
end

function ProgressOverviewMixin:RefreshActivities()
	self:LoadActivities()

	if(self.settings) then
		if(self.settings.honor) then
			self:GetParent().Info.HonorLevel.Text:SetText("Honor: " .. self.settings.honor.level)
			self:GetParent().Info.HonorProgress.Text:SetText(miog.shortenNumber(self.settings.honor.current) .. "/" .. miog.shortenNumber(self.settings.honor.maximum))

		end

		local provider = CreateDataProvider()

		for _, v in pairs(self.characterSettings) do
			v.sortWeight = v.mythicPlus.score + v.raids.progressWeight
			provider:Insert(v)
		end

		provider:SetSortComparator(sortOverviewCharacters)
		
		self.ScrollBox:SetDataProvider(provider)
	end
end

function ProgressOverviewMixin:OnLoad()
	hooksecurefunc("RequestRaidInfo", function()
		self:RefreshLockouts()

	end)

    RequestRaidInfo()

	local view = CreateScrollBoxListLinearView()
	view:SetHorizontal(true)

	local function initializeFrames(frame, data)
		local classID = miog.CLASSFILE_TO_ID[data.fileName]
		local color = C_ClassColor.GetClassColor(data.fileName)

		frame.Class.Icon:SetTexture(miog.OFFICIAL_CLASSES[classID].icon)
		frame.Spec.Icon:SetTexture(data.specID and miog.SPECIALIZATIONS[data.specID].squaredIcon or miog.SPECIALIZATIONS[0].squaredIcon)
		frame.Name:SetText(data.name)

		frame.GuildBannerBackground:SetVertexColor(color:GetRGB())
		frame.GuildBannerBorder:SetVertexColor(color.r * 0.65, color.g * 0.65, color.b * 0.65)
		frame.GuildBannerBorderGlow:SetShown(data.guid == UnitGUID("player"))
		
		frame.Identifiers.ItemLevel.Text:SetText(data.itemLevel or 0)
		frame.Identifiers.ItemLevel.Text:SetTextColor(miog.createCustomColorForRating(data.itemLevel and data.itemLevel > 0 and 4000 - (170 - data.itemLevel) ^ 2 or 1):GetRGBA())

		if(data.mythicPlus) then
			frame.Identifiers.MythicPlusScore.Text:SetText(data.mythicPlus.score)
			frame.Identifiers.MythicPlusScore.Text:SetTextColor(miog.createCustomColorForRating(data.mythicPlus.score):GetRGBA())
			
			frame.Identifiers.ResilientLevel.Text:SetText(data.mythicPlus.resilientLevel)
			frame.Identifiers.ResilientLevel.Text:SetTextColor(miog.ITEM_QUALITY_COLORS[6].color:GetRGBA())

			if(not data.mythicPlus.validatedIngame) then
				frame.Identifiers.MythicPlusScore:SetScript("OnEnter", function(selfFrame)
					GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
					GameTooltip:SetText("This data has been pulled from RaiderIO, it may be not accurate.")
					GameTooltip:AddLine("Login with this character to request official data from Blizzard.")
					GameTooltip:Show()
				end)
			end
		end

		local mapID = self.currentRaidMapID

		if(data.raids and mapID) then
			local journalInfo = miog:GetJournalDataForMapID(mapID)
			local numBosses = #journalInfo.bosses
			local playerInstanceData = data.raids.instances[mapID]

			for i = 1, 3, 1 do
				local raidProgressFrame = i == 1 and frame.Identifiers.Normal or i == 2 and frame.Identifiers.Heroic or i == 3 and frame.Identifiers.Mythic
				
				if(playerInstanceData and playerInstanceData[i]) then
					raidProgressFrame.Text:SetText(playerInstanceData[i].kills .. "/" .. numBosses)
					raidProgressFrame.Text:SetTextColor(miog.DIFFICULTY[i].miogColors:GetRGBA())

					if(playerInstanceData and playerInstanceData[i]) then
						raidProgressFrame:SetScript("OnEnter", function(selfFrame)
							GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT");
							GameTooltip_AddHighlightLine(GameTooltip, journalInfo.instanceName)
							GameTooltip_AddBlankLineToTooltip(GameTooltip)

							for k, v in ipairs(playerInstanceData[i].bosses) do
								if(v.id) then
									local name, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfoByID(v.id, 1, true)

									if(not name) then
										if(not journalInfo.bosses[k]) then
											journalInfo = miog:GetJournalDataForMapID(mapID)

										end

										name = journalInfo.bosses[k].name .. " kills"

									end

									GameTooltip:AddDoubleLine(v.count or v.quantity or 0, name)
								end

							end
							
							if(not playerInstanceData[i].validatedIngame) then
								GameTooltip_AddBlankLineToTooltip(GameTooltip)
								GameTooltip_AddNormalLine(GameTooltip, "This data has been pulled from RaiderIO, it may be not accurate.")
								GameTooltip_AddNormalLine(GameTooltip, "Login with this character to request official data from Blizzard.")

							end

							GameTooltip:Show()
						end)
					end
				else
					raidProgressFrame.Text:SetText("0/" .. numBosses)
					raidProgressFrame.Text:SetTextColor(miog.CLRSCC.colors.gray:GetRGBA())
					raidProgressFrame:SetScript("OnEnter", nil)

				end
				
			end
		end

		if(data.greatVault and data.greatVault.activities) then

				--[[
				
				frame.VaultStatus:SetAtlas("mythicplus-dragonflight-greatvault-collect")
				frame.VaultStatus:SetAtlas("mythicplus-dragonflight-greatvault-complete")
				frame.VaultStatus:SetAtlas("mythicplus-dragonflight-greatvault-incomplete")


		canClaimRewards = C_WeeklyRewards.CanClaimRewards(),
		hasGeneratedRewards = C_WeeklyRewards.HasGeneratedRewards(), --need to test function
		hasAvailableRewards = C_WeeklyRewards.HasAvailableRewards(),

				gficon-chest-evergreen-greatvault-collect
				]]

			if(data.greatVault.hasGeneratedRewards) then
				frame.Identifiers.GreatVault.Icon:SetAtlas("gficon-chest-evergreen-greatvault-collect")

				frame.Identifiers.GreatVault.Icon:SetScript("OnEnter", function(selfIcon)
					GameTooltip:SetOwner(selfIcon, "ANCHOR_RIGHT")
					GameTooltip:SetText(WEEKLY_REWARDS_RETURN_TO_CLAIM)
					GameTooltip:Show()
				end)

				frame.Identifiers.GreatVault.Icon:Show()
			elseif(data.greatVault.hasAvailableRewards or data.greatVault.hasRewardOnReset and data.greatVault.resetTime and data.greatVault.resetTime < time()) then
				frame.Identifiers.GreatVault.Icon:SetAtlas("gficon-chest-evergreen-greatvault-collect")

				frame.Identifiers.GreatVault.Icon:SetScript("OnEnter", function(selfIcon)
					GameTooltip:SetOwner(selfIcon, "ANCHOR_RIGHT")
					GameTooltip:SetText(MYTHIC_PLUS_COLLECT_GREAT_VAULT)
					GameTooltip:Show()
				end)

				frame.Identifiers.GreatVault.Icon:Show()
			else
				frame.Identifiers.GreatVault.Icon:Hide()

			end

			local raidProgress, raidThreshold = data.greatVault.activities[3][3].progress, data.greatVault.activities[3][3].threshold
			local dungeonProgress, dungeonThreshold = data.greatVault.activities[1][3].progress, data.greatVault.activities[1][3].threshold
			local worldProgress, worldThreshold = data.greatVault.activities[6][3].progress, data.greatVault.activities[6][3].threshold

			frame.Identifiers.GreatVaultRaids.Text:SetText((raidProgress > raidThreshold and raidThreshold or raidProgress) .. "/" .. raidThreshold)
			frame.Identifiers.GreatVaultRaids.Text:SetTextColor(miog.createCustomColorForRating(4000 * raidProgress / raidThreshold):GetRGBA())
			frame.Identifiers.GreatVaultRaids.Checkmark:SetShown(raidProgress >= raidThreshold)

			frame.Identifiers.GreatVaultDungeons.Text:SetText((dungeonProgress > dungeonThreshold and dungeonThreshold or dungeonProgress) .. "/" .. dungeonThreshold)
			frame.Identifiers.GreatVaultDungeons.Text:SetTextColor(miog.createCustomColorForRating(4000 * dungeonProgress / dungeonThreshold):GetRGBA())
			frame.Identifiers.GreatVaultDungeons.Checkmark:SetShown(dungeonProgress >= dungeonThreshold)

			frame.Identifiers.GreatVaultWorld.Text:SetText((worldProgress > worldThreshold and worldThreshold or worldProgress) .. "/" .. worldThreshold)
			frame.Identifiers.GreatVaultWorld.Text:SetTextColor(miog.createCustomColorForRating(4000 * worldProgress / worldThreshold):GetRGBA())
			frame.Identifiers.GreatVaultWorld.Checkmark:SetShown(worldProgress >= worldThreshold)

			frame.Identifiers.GreatVaultRaids:SetInfo(data.greatVault.activities[3])
			frame.Identifiers.GreatVaultDungeons:SetInfo(data.greatVault.activities[1])
			frame.Identifiers.GreatVaultWorld:SetInfo(data.greatVault.activities[6])
		else
			frame.Identifiers.GreatVaultRaids.Text:SetText("---")
			frame.Identifiers.GreatVaultRaids.Text:SetTextColor(1, 1, 1, 1)

			frame.Identifiers.GreatVaultDungeons.Text:SetText("---")
			frame.Identifiers.GreatVaultDungeons.Text:SetTextColor(1, 1, 1, 1)

			frame.Identifiers.GreatVaultWorld.Text:SetText("---")
			frame.Identifiers.GreatVaultWorld.Text:SetTextColor(1, 1, 1, 1)

			frame.Identifiers.GreatVault.Icon:Hide()

		end
	end
	
	view:SetElementInitializer("MIOG_ProgressOverviewFullTemplate", initializeFrames)
	view:SetPadding(1, 1, 1, 1, 1)
	view:SetElementExtent(96)

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)
end

function ProgressOverviewMixin:OnShow()
	self:GetParent().Menu.VisibilityDropdown:Hide()

	if(initialRefreshDone) then
		self:RefreshActivities()
	end
end
















ProgressDungeonMixin = CreateFromMixins(ProgressActivityMixin)

function ProgressDungeonMixin:UpdateSingleCharacterMythicPlusProgress(guid)
	if(self.activities) then
		local charData = self.characterSettings[guid]
		local dungeonData = {dungeons = {}}
		
		local resilientLevel = 99

		if guid == playerGUID then
			dungeonData.score = C_ChallengeMode.GetOverallDungeonScore()
			dungeonData.validatedIngame = true

			for _, challengeMapID in pairs(self.activities) do
				local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID)
				dungeonData.dungeons[challengeMapID] = {intimeInfo = intimeInfo, overtimeInfo = overtimeInfo}

				if(intimeInfo) then
					if(intimeInfo.level < resilientLevel) then
						resilientLevel = intimeInfo.level
					end
				end
			end
		else
			-- Fetch external Mythic+ data
			local externalData, intimeInfo, overtimeInfo = miog.getMPlusSortData(charData.name, charData.realm, nil, true)

			if(externalData) then
				if(not dungeonData.score or externalData.score.score > dungeonData.score) then
					dungeonData.score = externalData.score.score
					dungeonData.validatedIngame = false

					for _, challengeMapID in pairs(self.activities) do
						dungeonData.dungeons[challengeMapID] = {}
						dungeonData.dungeons[challengeMapID].overtimeInfo = overtimeInfo and overtimeInfo[challengeMapID]

						if(intimeInfo) then
							dungeonData.dungeons[challengeMapID].intimeInfo = intimeInfo[challengeMapID]

							if(intimeInfo[challengeMapID].level < resilientLevel) then
								resilientLevel = intimeInfo[challengeMapID].level

							end
						end
					end
				end

			else
				dungeonData.score = 0
				dungeonData.validatedIngame = true
				dungeonData.resilientLevel = "---"

			end
		end

		if(resilientLevel < 13 or resilientLevel == 99) then
			resilientLevel = "---"

		end

		dungeonData.resilientLevel = resilientLevel

		charData.mythicPlus = dungeonData
	end
end

function ProgressDungeonMixin:GetAbbreviatedName(challengeModeMapID)
	local groupID = miog.retrieveGroupIDFromChallengeModeMap(challengeModeMapID)
	local abbreviatedName

	local groupInfo = miog.GROUP_ACTIVITY[groupID]

	if(groupInfo) then
		abbreviatedName = groupInfo.abbreviatedName

	end

	if(not abbreviatedName) then
		local mapID = miog.retrieveMapIDFromChallengeModeMap(challengeModeMapID)

		local mapInfo = miog.MAP_INFO[mapID]

		if(mapInfo) then
			abbreviatedName = mapInfo.abbreviatedName

		end
	end

	return abbreviatedName
end

function ProgressDungeonMixin:GetBackgroundImage(challengeModeMapID)
	local groupID = miog.retrieveGroupIDFromChallengeModeMap(challengeModeMapID)
	local bg

	local groupInfo = miog:GetGroupInfo(groupID)

	if(groupInfo) then
		bg = groupInfo.vertical

	end

	if(not bg) then
		local mapID = miog.retrieveMapIDFromChallengeModeMap(challengeModeMapID)

		local mapInfo = miog:GetMapInfo(mapID)

		if(mapInfo) then
			bg = mapInfo.vertical

		end
	end

	return bg
end

function ProgressDungeonMixin:SortActivities()
	table.sort(self.activities, function(k1, k2)
		return miog.retrieveAbbreviatedNameFromChallengeModeMap(k1) < miog.retrieveAbbreviatedNameFromChallengeModeMap(k2)

	end)
end

function ProgressDungeonMixin:SetupVisibilityMenu(rootDescription)
	for k, v in ipairs(self.activities) do
		local bg, abbreviatedName = self:GetNameAndBackground(v)

		rootDescription:CreateCheckbox(abbreviatedName,
			function(challengeMapID)
				return self.settings.activities[challengeMapID].visible
			end,
			function(challengeMapID)
				self.settings.activities[challengeMapID].visible = not self.settings.activities[challengeMapID].visible

				self:RefreshActivities()
		end, v)
	end
end

function ProgressDungeonMixin:LoadActivities()
	if(not self.activities) then
		self.activities = C_ChallengeMode.GetMapTable()

		for k, v in ipairs(self.activities) do
			self.settings.activities[v] = self.settings.activities[v] or {visible = true}

		end

		self:SortActivities()

	end
end

local function sortMythicPlusCharacters(k1, k2)
	if(k1.guid == playerGUID) then
		return true

	elseif(k2.guid == playerGUID) then
		return false

	elseif(k1.mythicPlus.score and k2.mythicPlus.score) then
		return k1.mythicPlus.score > k2.mythicPlus.score

	elseif(k1.mythicPlus.score) then
		return true

	elseif(k2.mythicPlus.score) then
		return false

	end

	return k1.name > k2.name
end

function ProgressDungeonMixin:UpdateAllCharactersProgressData()
	self:LoadActivities()

	for guid, v in pairs(self.characterSettings) do
		self:UpdateSingleCharacterMythicPlusProgress(guid)

	end
end

function ProgressDungeonMixin:UpdateAllCharactersVisibleData()
	self:UpdateAllCharactersProgressData()

	local provider = CreateDataProvider()
	provider:SetSortComparator(sortMythicPlusCharacters)

	for guid, v in pairs(self.characterSettings) do
		v.guid = guid
		provider:Insert(v)
	end

	self.ScrollBox:SetDataProvider(provider)
end

function ProgressDungeonMixin:OnShow()
	self.characterTemplate = "MIOG_ProgressMythicPlusCharacterCellTemplate"
	self.cellTemplate = "MIOG_ProgressMythicPlusCellTemplate"

	self:UpdateAllCharactersVisibleData()

	self:GetParent().Menu.VisibilityDropdown:SetDefaultText("Change activity visibility")
	self:GetParent().Menu.VisibilityDropdown:SetupMenu(function(dropdown, rootDescription)
		self:SetupVisibilityMenu(rootDescription)

	end)

	ScrollUtil.RegisterScrollBoxWithScrollBar(self.ScrollBox, miog.pveFrame2.ScrollBarArea.ProgressMPlusScrollBar)

	self:RefreshActivities()
end













ProgressRaidMixin = CreateFromMixins(ProgressActivityMixin)

function ProgressRaidMixin:GetAbbreviatedName(mapID)
	local mapInfo = miog.MAP_INFO[mapID]

	if(mapInfo) then
		return mapInfo.abbreviatedName

	end
end

function ProgressRaidMixin:GetBackgroundImage(mapID)
	local mapInfo = miog.MAP_INFO[mapID]

	if(mapInfo) then
		return mapInfo.vertical

	end
end

function ProgressRaidMixin:CalculateProgressWeight(raidData)
	local progressWeight = 0

	for k, v in ipairs(self.activities) do
		if(raidData.instances[v]) then
			for difficultyIndex, table in pairs(raidData.instances[v]) do
				progressWeight = progressWeight + miog.calculateRaidWeight(difficultyIndex, table.kills, #table.bosses, k == 1)
				
			end
		else
			progressWeight = progressWeight + 0

		end
	end

	return progressWeight
end

function ProgressRaidMixin:CheckForAchievements(mapID)
	local mapDifficultyData = {}

	if(miog.MAP_INFO[mapID].achievementIDs) then
		for index, achievementID in ipairs(miog.MAP_INFO[mapID].achievementIDs) do
			local difficultyIndex = ((index - 1) % 4)

			if(difficultyIndex > 0) then
				--local numCriteria = GetAchievementNumCriteria(achievementID)

				mapDifficultyData[difficultyIndex] = mapDifficultyData[difficultyIndex] or {validatedIngame = true, kills = 0, bosses = {}}

				--for criteriaIndex = 1, numCriteria do
					local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfo(achievementID, 1, true)

					if(completed) then
						mapDifficultyData[difficultyIndex].kills = mapDifficultyData[difficultyIndex].kills + 1

					end

					table.insert(mapDifficultyData[difficultyIndex].bosses, {
						id = achievementID,
						killed = completed,
						count = quantity
					})
				--end
			end
		end
	end

	return mapDifficultyData
end

function ProgressRaidMixin:UpdateSingleCharacterRaidProgress(guid)
	if(self.activities) then
		local charData = self.characterSettings[guid]
		local raidData = {instances = {}}

		local activityTable = self.activities

		if guid == playerGUID then
			for _, mapID in ipairs(activityTable) do
				raidData.instances[mapID] = self:CheckForAchievements(mapID)

			end

			charData.raids = raidData
		elseif(not charData.raids) then
			local raiderIORaidData = miog.getNewRaidSortData(charData.name, charData.realm)

			if raiderIORaidData and raiderIORaidData.character then
				for _, mapID in ipairs(activityTable) do
					if not raidData.instances[mapID] then
						local instanceData = {}
						local mapInfo = miog.MAP_INFO[mapID]
						local characterRaid = raiderIORaidData.character.raids[mapID]

						if characterRaid then
							local bossCounter = 0

							for index, achievementID in ipairs(mapInfo.achievementIDs) do
								local difficultyIndex = ((index - 1) % 4)
								
								if(difficultyIndex == 0) then
									bossCounter = bossCounter + 1
								end

								if(difficultyIndex > 0) then
									local raiderIODifficultyData = characterRaid.regular.difficulties[difficultyIndex]

									if(raiderIODifficultyData) then
										instanceData[difficultyIndex] = instanceData[difficultyIndex] or {
											validatedIngame = false,
											kills = raiderIODifficultyData.kills,
											bosses = {}
										}
										
										local _, _, _, _, _, _, _, _, _, criteriaID, _ = GetAchievementCriteriaInfo(achievementID, 1, true)

										local bossData = raiderIODifficultyData.bosses[bossCounter]

										instanceData[difficultyIndex].bosses[bossCounter] = {
											id = achievementID,
											killed = bossData.killed,
											count = bossData.count
										}

									end
								end
							end
						end

						raidData.instances[mapID] = instanceData
					end
				end
			end

			charData.raids = raidData
		end

		raidData.progressWeight = self:CalculateProgressWeight(raidData)
	end
end

--/run MIOG_NewSettings.progressData = nil

function ProgressRaidMixin:LoadActivities()
	if(not self.activities or #self.activities == 0) then
		local groups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion) or Enum.LFGListFilter.Recommended)
		local raidTable = {}

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(3, v)
			local activityID = activities[#activities]
			local name, order = C_LFGList.GetActivityGroupInfo(v)
			local activityInfo = miog.requestActivityInfo(activityID)
			local mapID = activityInfo.mapID

			miog.checkSingleMapIDForNewData(mapID, true)

			tinsert(raidTable, {name = name, order = order, activityID = activityID, mapID = mapID})
		end

		self.activities = raidTable

		self:SortActivities()

		local raidActivities = {}

		for k, v in ipairs(self.activities) do
			self.settings.activities[v.mapID] = self.settings.activities[v.mapID] or {visible = true}
			tinsert(raidActivities, v.mapID)

		end

		self.activities = raidActivities
	end
end

function ProgressRaidMixin:UpdateAllCharactersProgressData()
	self:LoadActivities()

	for guid, v in pairs(self.characterSettings) do
		self:UpdateSingleCharacterRaidProgress(guid)

	end
end

function ProgressRaidMixin:SortActivities()
	table.sort(self.activities, function(k1, k2)
		if(k1.order == k2.order) then
			return k1.activityID > k2.activityID

		end

		return k1.order < k2.order
	end)
end

function ProgressRaidMixin:UpdateAllCharactersVisibleData()
	self:UpdateAllCharactersProgressData()

	local provider = CreateDataProvider()
	provider:SetSortComparator(sortMythicPlusCharacters)

	for guid, v in pairs(self.characterSettings) do
		v.guid = guid
		provider:Insert(v)

	end

	self.ScrollBox:SetDataProvider(provider)
end

function ProgressRaidMixin:SetupVisibilityMenu(rootDescription)
	for k, mapID in ipairs(self.activities) do
		local abbreviatedName = self:GetAbbreviatedName(mapID)

		rootDescription:CreateCheckbox(abbreviatedName,
			function(passedMapID)
				return self.settings.activities[passedMapID].visible
			end,
			function(passedMapID)
				self.settings.activities[passedMapID].visible = not self.settings.activities[passedMapID].visible

				self:RefreshActivities()
		end, mapID)
	end
end

function ProgressRaidMixin:OnShow()
	self.characterTemplate = "MIOG_ProgressRaidCharacterCellTemplate"
	self.cellTemplate = "MIOG_ProgressRaidCellTemplate"

	self:UpdateAllCharactersVisibleData()

	self:GetParent().Menu.VisibilityDropdown:SetDefaultText("Change activity visibility")
	self:GetParent().Menu.VisibilityDropdown:SetupMenu(function(dropdown, rootDescription)
		self:SetupVisibilityMenu(rootDescription)

	end)

	ScrollUtil.RegisterScrollBoxWithScrollBar(self.ScrollBox, miog.pveFrame2.ScrollBarArea.ProgressRaidScrollBar)

	self:RefreshActivities()
end






ProgressPVPMixin = CreateFromMixins(ProgressActivityMixin)

function ProgressPVPMixin:GetAbbreviatedName(id)
	local bracketInfo = miog.PVP_BRACKET_IDS_TO_INFO[id]

	if(bracketInfo) then
		return bracketInfo.shortName
	end
end

function ProgressPVPMixin:GetBackgroundImage(id)
	local bracketInfo = miog.PVP_BRACKET_IDS_TO_INFO[id]

	if(bracketInfo) then
		return bracketInfo.vertical
	end
end

function ProgressPVPMixin:UpdateSingleCharacterPVPProgress(guid)
    local charData = self.characterSettings[guid]
	local pvpData = {}

    if(guid == playerGUID) then
		local highestRating = 0

		pvpData.brackets = {}

		for index, id in ipairs(pvpActivities) do
		--for i = 1, 5, 1 do
			-- 1 == 2v2, 2 == 3v3, 3 == 5v5, 4 == 10v10, Solo Arena == 7, Solo BG == 9

			local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(id)

			pvpData.brackets[id] = {rating = rating, seasonBest = seasonBest}

			highestRating = rating > highestRating and rating or highestRating

		end

		local tierID, nextTierID = C_PvP.GetSeasonBestInfo()

		pvpData.tierInfo = {tierID, nextTierID}
		pvpData.rating = highestRating
		charData.pvp = pvpData

		self.settings.honor = {
			current = UnitHonor("player"),
			maximum = UnitHonorMax("player"),
			level = UnitHonorLevel("player")
		}


	elseif(not self.characterSettings[guid].pvp) then
		pvpData.brackets = pvpData.brackets or {}
		pvpData.tierInfo = pvpData.tierInfo or {}
		pvpData.rating = pvpData.rating or 0

		charData.pvp = pvpData

	end
end

function ProgressPVPMixin:UpdateAllCharactersProgressData()
	self:LoadActivities()

	for guid, v in pairs(self.characterSettings) do
		self:UpdateSingleCharacterPVPProgress(guid)

	end
end


function ProgressPVPMixin:UpdateAllCharactersVisibleData()
	self:UpdateAllCharactersProgressData()

	local provider = CreateDataProvider()
	provider:SetSortComparator(sortMythicPlusCharacters)

	for guid, v in pairs(self.characterSettings) do
		v.guid = guid
		provider:Insert(v)
	end

	self.ScrollBox:SetDataProvider(provider)
end

function ProgressPVPMixin:SetupVisibilityMenu(rootDescription)
	for k, id in ipairs(self.activities) do
		local bg, abbreviatedName = self:GetNameAndBackground(id)

		rootDescription:CreateCheckbox(abbreviatedName,
			function(passedID)
				return self.settings.activities[passedID].visible
			end,
			function(passedID)
				self.settings.activities[passedID].visible = not self.settings.activities[passedID].visible

				self:RefreshActivities()
		end, id)
	end
end

function ProgressPVPMixin:LoadActivities()
	self.activities = pvpActivities

	for k, v in ipairs(self.activities) do
		self.settings.activities[v] = self.settings.activities[v] or {visible = true}

	end
end

local function sortPVPCharacters(k1, k2)
	if(k1.guid == playerGUID) then
		return true

	elseif(k2.guid == playerGUID) then
		return false

	elseif(k1.pvp.rating and k2.pvp.rating) then
		return k1.pvp.rating < k2.pvp.rating

	elseif(k1.pvp.rating) then
		return true

	elseif(k2.pvp.rating) then
		return false

	end

	return k1.name > k2.name
end

function ProgressPVPMixin:OnShow()
	self.characterTemplate = "MIOG_ProgressPVPCharacterCellTemplate"
	self.cellTemplate = "MIOG_ProgressPVPCellTemplate"

	self:UpdateAllCharactersVisibleData()

	self:GetParent().Menu.VisibilityDropdown:SetDefaultText("Change activity visibility")
	self:GetParent().Menu.VisibilityDropdown:SetupMenu(function(dropdown, rootDescription)
		self:SetupVisibilityMenu(rootDescription)

	end)

	ScrollUtil.RegisterScrollBoxWithScrollBar(self.ScrollBox, miog.pveFrame2.ScrollBarArea.ProgressPVPScrollBar)

	self:RefreshActivities()
end



ProgressSelectionButtonMixin = {}

function ProgressSelectionButtonMixin:OnClick()
	self.Texture:SetAtlas("Options_List_Active")

	local tabParent = self:GetParent():GetParent()
	local oldButton = self:GetParent().selectedButton

	if(oldButton ~= self) then
		oldButton.Texture:SetTexture(nil)
		oldButton.isSelected = false
		tabParent[oldButton:GetName()]:Hide()

		local infoMenu = self:GetParent():GetParent().Info

		if(self.isOverviewButton) then
			self:GetParent().VisibilityDropdown:Hide()
			infoMenu:Show()

		else
			self:GetParent().VisibilityDropdown:Show()
			infoMenu:Hide()

		end

		infoMenu:MarkDirty()

		self:GetParent().selectedButton = self
		self.isSelected = true

		tabParent[self:GetName()]:Show()
	end
end

function ProgressSelectionButtonMixin:OnLoad()
	self.Label:SetText(self:GetText())

	if(self:GetText() == "Overview") then
		self:GetParent().selectedButton = self
		self.isSelected = true
		self.Texture:SetAtlas("Options_List_Active")

		self.isOverviewButton = true
	end
end