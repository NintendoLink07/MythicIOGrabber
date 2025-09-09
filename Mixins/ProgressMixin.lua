local addonName, miog = ...

local playerGUID = UnitGUID("player")
local fullPlayerName = UnitFullName("player")

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

function ProgressMixin:RequestAccountCharacter()
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
		self.characterSettings[playerGUID] = {name = name, realmName = realmName, fileName = englishClass, specID = specID, itemLevel = itemLevel,}

	else
		playerSettings.name = name
		playerSettings.realmName = realmName
		playerSettings.fileName = englishClass

		--Only player stats
		playerSettings.specID = specID
		playerSettings.itemLevel = itemLevel

	end

	for guid, v in pairs(charList) do
		localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName = GetPlayerInfoByGUID(guid)

		local charSettings = self.characterSettings[guid]

		if(not charSettings) then
			self.characterSettings[guid] = {name = name, realmName = realmName, fileName = englishClass}

		else
			charSettings.name = name
			charSettings.realmName = realmName
			charSettings.fileName = englishClass

		end
	end
end

function ProgressMixin:SetupInitialCharacterData(setupTable)
	self:ConnectSetting(setupTable)
	self:RequestAccountCharacter()

end

function ProgressMixin:OnShow()
	self:RequestAccountCharacter()
	
	self.MythicPlus:UpdateAllCharactersProgressData()
	self.Raid:UpdateAllCharactersProgressData()
	self.PVP:UpdateAllCharactersProgressData()
	
	self.Overview:RefreshActivities()
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

function ProgressActivityMixin:SetupVisibilityMenu()

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
		self.tableBuilder:EnableRowDividers()
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

	self.tableBuilder = CreateTableBuilder(nil, TableBuilderSkinMixin)
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

function ProgressActivityMixin:OnShow()
	self:RefreshActivities()

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
	if(not self.mythicPlusActivities) then
		self.mythicPlusActivities = C_ChallengeMode.GetMapTable()

	end

	if(not self.raidActivities) then
		local groups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion) or Enum.LFGListFilter.Recommended)
		local raidActivities = {}

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(3, v)
			local activityID = activities[#activities]
			local name, order = C_LFGList.GetActivityGroupInfo(v)
			local activityInfo = miog.requestActivityInfo(activityID)
			local mapID = activityInfo.mapID

			miog.checkSingleMapIDForNewData(mapID, true)
			miog.checkForMapAchievements(mapID)

			tinsert(raidActivities, {name = name, order = order, activityID = activityID, mapID = mapID})
		end

		table.sort(raidActivities, function(k1, k2)
			if(k1.order == k2.order) then
				return k1.activityID > k2.activityID

			end

			return k1.order < k2.order
		end)

		self.raidActivities = raidActivities
	end
end

local function sortOverviewCharacters(k1, k2)
	if(k1.itemLevel and k2.itemLevel) then
		return k1.itemLevel > k2.itemLevel

	elseif(k1.itemLevel) then
		return true

	elseif(k2.itemLevel) then
		return false

	end

	return k1.name > k2.name
end

function ProgressOverviewMixin:RefreshActivities()
	if(self.settings) then
		self.tableBuilder:Reset()
		self.tableBuilder:SetTableMargins(5, 5)

		local column = self.tableBuilder:AddColumn()
		column:SetFixedConstraints(64)
		column:ConstructCells("Frame", "MIOG_ProgressOverviewFullTemplate")

		self.tableBuilder:Arrange()
	end
end

function ProgressOverviewMixin:OnShow()
	self:LoadActivities()

	local provider = CreateDataProvider()
	provider:SetSortComparator(sortOverviewCharacters)

	for k, v in pairs(self.characterSettings) do
		local providerSettings = v
		providerSettings.guid = k
		providerSettings.currentRaidMapID = self.raidActivities[1].mapID
		provider:Insert(providerSettings)

	end

	if(self.settings.honor) then
		self:GetParent().Menu.OverviewElements.HonorLevel:SetText("Honor: " .. self.settings.honor.level)
		self:GetParent().Menu.OverviewElements.HonorProgress:SetText(self.settings.honor.current .. " / " .. self.settings.honor.maximum)

	end

	self.ScrollBox:SetDataProvider(provider)

end

function ProgressOverviewMixin:OnLoad()
	hooksecurefunc("RequestRaidInfo", function()
		self:RefreshLockouts()

	end)

    RequestRaidInfo()

	for i = 1, 3, 1 do
        local raidProgressFrame = i == 1 and self.Info.Normal or i == 2 and self.Info.Heroic or i == 3 and self.Info.Mythic
        raidProgressFrame:SetTextColor(miog.DIFFICULTY[i].miogColors:GetRGBA())

	end

    self.Info.MythicPlus:SetTextColor(miog.DIFFICULTY[4].miogColors:GetRGBA())
	self.ScrollBox:SetHorizontal(true)

	local view = CreateScrollBoxListLinearView()
	view:SetHorizontal(true)
	view:SetElementInitializer("BackdropTemplate", function(frame, data)
		--line template

	end)

	view:SetPadding(1, 1, 1, 1, 4)
	view:SetElementExtent(64)

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

	self.tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
	self.tableBuilder:Init()

	local function ElementDataProvider(elementData, ...)
		return elementData

	end
	self.tableBuilder:SetDataProvider(ElementDataProvider)
	local function ElementDataTranslator(elementData, ...)
		return elementData

	end
	
	ScrollUtil.RegisterTableBuilder(self.ScrollBox, self.tableBuilder, ElementDataTranslator)
end


















ProgressDungeonMixin = CreateFromMixins(ProgressActivityMixin)

function ProgressDungeonMixin:UpdateSingleCharacterMythicPlusProgress(guid)
	if(self.activities) then
		local charData = self.characterSettings[guid]
		local dungeonData = {dungeons = {}}

		if guid == playerGUID then
			dungeonData.score = C_ChallengeMode.GetOverallDungeonScore()
			dungeonData.validatedIngame = true

			for _, challengeMapID in pairs(self.activities) do
				local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID)
				dungeonData.dungeons[challengeMapID] = {intimeInfo = intimeInfo, overtimeInfo = overtimeInfo}
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
						dungeonData.dungeons[challengeMapID].intimeInfo = intimeInfo and intimeInfo[challengeMapID]
						dungeonData.dungeons[challengeMapID].overtimeInfo = overtimeInfo and overtimeInfo[challengeMapID]

					end
				end

			else
				dungeonData.score = 0
				dungeonData.validatedIngame = true

			end
		end

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

	local groupInfo = miog.GROUP_ACTIVITY[groupID]

	if(groupInfo) then
		bg = groupInfo.vertical

	end

	if(not bg) then
		local mapID = miog.retrieveMapIDFromChallengeModeMap(challengeModeMapID)

		local mapInfo = miog.MAP_INFO[mapID]

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

	self:GetParent().Menu.OverviewElements.VisibilityDropdown:SetDefaultText("Change activity visibility")
	self:GetParent().Menu.OverviewElements.VisibilityDropdown:SetupMenu(function(dropdown, rootDescription)
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
				progressWeight = progressWeight + miog.calculateWeightedScore(difficultyIndex, table.kills, #table.bosses, true, 1)


			end
		else
			progressWeight = progressWeight + 0

		end
	end

	raidData.progressWeight = progressWeight
end

function ProgressRaidMixin:CheckForAchievements(mapID)
	if not miog.MAP_INFO[mapID].achievementTable then
		miog.checkForMapAchievements(mapID)

	end

	local mapDifficultyData = {}

	for _, achievementID in ipairs(miog.MAP_INFO[mapID].achievementTable) do
		local id, name, _, _, _, _, _, description = GetAchievementInfo(achievementID)
		local difficulty = string.find(name, "Normal") and 1
						or string.find(name, "Heroic") and 2
						or string.find(name, "Mythic") and 3

		if(difficulty) then
			mapDifficultyData[difficulty] = mapDifficultyData[difficulty] or {validatedIngame = true, kills = 0, bosses = {}}

			local string, type, completedCriteria, quantity, _, _, _, _, _, criteriaID = GetAchievementCriteriaInfo(id, 1, true)

			if(completedCriteria) then
				mapDifficultyData[difficulty].kills = mapDifficultyData[difficulty].kills + 1

				table.insert(mapDifficultyData[difficulty].bosses, {
					id = id,
					criteriaID = criteriaID,
					killed = completedCriteria,
					quantity = quantity
				})

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
		else
			local raiderIORaidData = miog.getNewRaidSortData(charData.name, charData.realm)
			local progressWeight = charData.progressWeight or 0

			if raiderIORaidData and raiderIORaidData.character then
				for _, mapID in ipairs(activityTable) do
					-- Only create table if it doesn't exist
					if not raidData.instances[mapID] then
						local instanceData = {}
						local mapInfo = miog.MAP_INFO[mapID]
						local characterRaid = raiderIORaidData.character.raids[mapID]

						if characterRaid then
							-- Calculate progress weight from difficulties
							for _, difficultyData in pairs(characterRaid.regular.difficulties) do
								progressWeight = progressWeight + difficultyData.weight
							end

							-- Process bosses and achievements
							for bossIndex, bossData in pairs(mapInfo.bosses) do
								for _, achievementID in ipairs(bossData.achievements) do
									local id, name, _, _, _, _, _, _, _, _, _, _, _, _, _ = GetAchievementInfo(achievementID)
									local difficulty = string.find(name, "Normal") and 1
													or string.find(name, "Heroic") and 2
													or string.find(name, "Mythic") and 3

									if difficulty and characterRaid.regular.difficulties[difficulty] then
										local raiderIODifficultyData = characterRaid.regular.difficulties[difficulty]

										instanceData[difficulty] = {
											validatedIngame = false,
											kills = raiderIODifficultyData.kills,
											bosses = raiderIODifficultyData.bosses
										}

										local _, _, _, _, _, _, _, _, _, criteriaID, _ = GetAchievementCriteriaInfo(id, 1, true)

										instanceData[difficulty].bosses[bossIndex] = {
											id = id,
											criteriaID = criteriaID,
											killed = raiderIODifficultyData.bosses[bossIndex].killed,
											quantity = raiderIODifficultyData.bosses[bossIndex].count
										}
									end
								end
							end
						end

						raidData.instances[mapID] = instanceData
					end
				end
			end

			charData.progressWeight = progressWeight
		end

		self:CalculateProgressWeight(raidData)

		charData.raids = raidData
	end
end

--/run MIOG_NewSettings.progressData = nil

function ProgressRaidMixin:LoadActivities()
	if(not self.activities) then
		local groups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion) or Enum.LFGListFilter.Recommended)
		local raidTable = {}

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(3, v)
			local activityID = activities[#activities]
			local name, order = C_LFGList.GetActivityGroupInfo(v)
			local activityInfo = miog.requestActivityInfo(activityID)
			local mapID = activityInfo.mapID

			miog.checkSingleMapIDForNewData(mapID, true)
			miog.checkForMapAchievements(mapID)

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

local function sortRaidCharacters(k1, k2)
	if(k1.guid == playerGUID) then
		return true

	elseif(k2.guid == playerGUID) then
		return false

	elseif(k1.raids.progressWeight and k2.raids.progressWeight) then
		return k1.raids.progressWeight > k2.raids.progressWeight

	elseif(k1.raids.progressWeight) then
		return true

	elseif(k2.raids.progressWeight) then
		return false

	end

	return k1.name > k2.name
end

function ProgressRaidMixin:OnShow()
	self.characterTemplate = "MIOG_ProgressRaidCharacterCellTemplate"
	self.cellTemplate = "MIOG_ProgressRaidCellTemplate"

	self:UpdateAllCharactersVisibleData()

	self:GetParent().Menu.OverviewElements.VisibilityDropdown:SetDefaultText("Change activity visibility")
	self:GetParent().Menu.OverviewElements.VisibilityDropdown:SetupMenu(function(dropdown, rootDescription)
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

	self:GetParent().Menu.OverviewElements.VisibilityDropdown:SetDefaultText("Change activity visibility")
	self:GetParent().Menu.OverviewElements.VisibilityDropdown:SetupMenu(function(dropdown, rootDescription)
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

		if(self.isOverviewButton) then
			self:GetParent().OverviewElements:Show()

		else
			self:GetParent().OverviewElements:Hide()

		end

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