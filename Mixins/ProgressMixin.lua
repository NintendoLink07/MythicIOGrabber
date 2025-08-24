local addonName, miog = ...

ProgressMixin = {}

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

function ProgressMixin:RequestAccountCharacter()
    C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()

	local charList = {}

    local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize();
    for currencyIndex = 1, numTokenTypes do
		local currencyData = C_CurrencyInfo.GetCurrencyListInfo(currencyIndex);
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
		playerSettings = {name = name, realmName = realmName, classFile = englishClass, specID = specID, itemLevel = itemLevel,}

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
			charSettings = {name = name, realmName = realmName, classFile = englishClass}

		else
			charSettings.name = name
			charSettings.realmName = realmName
			charSettings.fileName = englishClass

		end
	end
end

function ProgressMixin:CheckLockoutExpiration()
    for index, data in pairs(self.characterSettings[playerGUID].lockouts) do
		if(data.resetDate <= time()) then
			self.characterSettings[playerGUID].lockouts[index] = nil

		end
    end
end

function ProgressMixin:RefreshLockouts()
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

function ProgressMixin:LoadAllActivities()
	self.mythicPlusActivities = C_ChallengeMode.GetMapTable()

        table.sort(self.mythicPlusActivities, function(k1, k2)
            return miog.retrieveAbbreviatedNameFromChallengeModeMap(k1) < miog.retrieveAbbreviatedNameFromChallengeModeMap(k2)

        end)

	self.raidActivities = {}

	local groups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion) or Enum.LFGListFilter.Recommended)

	for k, v in ipairs(groups) do
		local activities = C_LFGList.GetAvailableActivities(3, v)
		local activityID = activities[#activities]
		local name, order = C_LFGList.GetActivityGroupInfo(v)
		local activityInfo = miog.requestActivityInfo(activityID)
		local mapID = activityInfo.mapID

		miog.checkSingleMapIDForNewData(mapID, true)
		miog.checkForMapAchievements(mapID)

		tinsert(self.raidActivities, {name = name, order = order, activityID = activityID, mapID = mapID})
	end

	table.sort(self.raidActivities, function(k1, k2)
		if(k1.order == k2.order) then
			return k1.activityID > k2.activityID

		end

		return k1.order < k2.order
	end)
end

function ProgressMixin:OnLoad()
	hooksecurefunc("RequestRaidInfo", function()
		self:RefreshLockouts()
			
	end)

    RequestRaidInfo()

	self.mythicPlusActivities = C_ChallengeMode.GetMapTable()
	self.raidActivities = {}

	local groups = C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion) or Enum.LFGListFilter.Recommended)

	for k, v in ipairs(groups) do
		local activities = C_LFGList.GetAvailableActivities(3, v)
		local activityID = activities[#activities]
		local name, order = C_LFGList.GetActivityGroupInfo(v)
		local activityInfo = miog.requestActivityInfo(activityID)
		local mapID = activityInfo.mapID

		miog.checkSingleMapIDForNewData(mapID, true)
		miog.checkForMapAchievements(mapID)

		tinsert(self.raidActivities, {name = name, order = order, activityID = activityID, mapID = mapID})
	end

	table.sort(self.raidActivities, function(k1, k2)
		if(k1.order == k2.order) then
			return k1.activityID > k2.activityID

		end

		return k1.order < k2.order
	end)

	self.Overview.ScrollBox:SetHorizontal(true)

	local horizontalView = CreateScrollBoxListLinearView();
	horizontalView:SetHorizontal(true)
	horizontalView:SetElementInitializer("MIOG_ProgressOverviewCellTemplate", function(frame, data)
		--[[local classID = miog.CLASSFILE_TO_ID[data.fileName]
		local color = C_ClassColor.GetClassColor(data.fileName)

		frame.Class.Icon:SetTexture(miog.CLASSES[classID].icon)
		frame.Spec.Icon:SetTexture(data.specID and miog.SPECIALIZATIONS[data.specID].squaredIcon or miog.SPECIALIZATIONS[0].squaredIcon)
		frame.Name:SetText(data.name)

		frame.GuildBannerBackground:SetVertexColor(color:GetRGB())
		frame.GuildBannerBorder:SetVertexColor(color.r * 0.65, color.g * 0.65, color.b * 0.65)

		frame.MythicPlusScore:SetText(string.format(miog.STRING_REPLACEMENTS["MPLUSRATINGSHORT"], data.mythicPlus.score))
		frame.MythicPlusScore:SetTextColor(miog.createCustomColorForRating(data.mythicPlus.score):GetRGBA())]]
		
	end)

	horizontalView:SetPadding(1, 1, 1, 1, 3);
	horizontalView:SetElementExtent(76)

	ScrollUtil.InitScrollBoxListWithScrollBar(self.Overview.ScrollBox, self.Overview.ScrollBar, horizontalView)

	self.tableBuilder = CreateTableBuilder(nil, TableBuilderMixin);
	self.tableBuilder:Init()
	local function ElementDataProvider(elementData)
		return elementData;
	end;
	self.tableBuilder:SetDataProvider(ElementDataProvider);
	local function ElementDataTranslator(elementData)
		return elementData;
	end;
	ScrollUtil.RegisterTableBuilder(self.Overview.ScrollBox, self.tableBuilder, ElementDataTranslator);

	self.tableBuilder:Reset();
	--self.tableBuilder:SetColumnHeaderOverlap(2);
	--self.tableBuilder:SetHeaderContainer(self.HeaderContainer);
	self.tableBuilder:SetTableMargins(5, 5);
	self.tableBuilder:Arrange();

	local column = self.tableBuilder:AddColumn()
	--column:ConstructHeader("Frame", "MIOG_ProgressOverviewHeaderTemplate")
	column:ConstructCells("Frame", "MIOG_ProgressOverviewCellTemplate")

end

function ProgressMixin:Setup()
	if(self.characterSettings) then
		self:RequestAccountCharacter()
		RequestRaidInfo()

	end
end

local function sortCharacters(k1, k2)
	if(k1.mythicPlus.score and k2.mythicPlus.score) then
		return k1.mythicPlus.score > k2.mythicPlus.score
		
	end

	return k1.name > k2.name
end

function ProgressMixin:OnShow()
	local provider = CreateDataProvider()
	provider:SetSortComparator(sortCharacters)

	for k, v in pairs(self.characterSettings) do
		provider:Insert(v)

	end

	self.tableBuilder:Reset();

	self.Overview.ScrollBox:SetDataProvider(provider);
	--self.OverviewTable:SetDataProvider(provider)
	--self.Overview.ScrollBox:SetDataProvider(provider)
	self.tableBuilder:Arrange();

end

function ProgressMixin:ConnectSetting(settingsTable)
	self:SetSize(self:GetParent():GetSize())

	self.settings = settingsTable
	self.characterSettings = settingsTable.characters
	self:Setup()
end


ProgressDungeonMixin = CreateFromMixins(ProgressMixin)

function ProgressDungeonMixin:UpdateSingleCharacterMythicPlusProgress(guid)
	if(self.activities) then
		local charData = self.characterSettings[guid]
		local dungeonData = {dungeons = {}}

		if guid == playerGUID then
			-- Update the player's Mythic+ score
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

function ProgressDungeonMixin:GetNumberOfVisibleActivities()
	local counter = 0

	for _, v in pairs(self.activities) do
		if(self.settings.activities[v].visible) then
			counter = counter + 1

		end
	end

	return counter
end

function ProgressDungeonMixin:RefreshActivities()
	if(self.settings) then
		self.tableBuilder:Reset()

		local column = self.tableBuilder:AddColumn()
		local header = column:ConstructHeader("Frame", "MIOG_ProgressMythicPlusHeaderTemplate")
		column:SetFixedConstraints(90)
		column:ConstructCells("Frame", "MIOG_ProgressMythicPlusCharacterCellTemplate")

		tinsert(self.Columns, column)

		local availableWidth = self.ScrollBox:GetWidth() - column.headerFrame:GetWidth() - 50

		local numOfActivities = self:GetNumberOfVisibleActivities()

		for k, v in ipairs(self.activities) do
			if(self.settings.activities[v].visible) then
				local bg
				local mapInfo
				local groupID = miog.retrieveGroupIDFromChallengeModeMap(v)

				if(groupID) then
					local groupInfo = miog.GROUP_ACTIVITY[groupID]

					bg = miog.getBackgroundImageForIdentifier(groupInfo.mapID, nil, groupID)

				else
					local mapID = miog.retrieveMapIDFromChallengeModeMap(v)
					mapInfo = miog.MAP_INFO[mapID]

					bg = mapInfo.vertical
				end

				column = self.tableBuilder:AddColumn()
				column:ConstructHeader("Frame", "MIOG_ProgressMythicPlusHeaderTemplate", miog.retrieveAbbreviatedNameFromChallengeModeMap(v))


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
				column:ConstructCells("Frame", "MIOG_ProgressMythicPlusCellTemplate", v)

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

function ProgressDungeonMixin:OnShow()
	self:GetParent().Menu.VisibilityDropdown:SetDefaultText("Change activity visibility")
	self:GetParent().Menu.VisibilityDropdown:SetupMenu(function(dropdown, rootDescription)
		for k, v in ipairs(self.activities) do
			self.settings.activities[v] = self.settings.activities[v] or {visible = true}
			local shortName

			local groupID = miog.retrieveGroupIDFromChallengeModeMap(v)
			local mapID

			if(not groupID) then
				mapID = miog.retrieveMapIDFromChallengeModeMap(v)
				
				local mapInfo = miog.MAP_INFO[mapID]

				if(mapInfo) then
					shortName = mapInfo.abbreviatedName

				end
			else
				local groupInfo = miog.GROUP_ACTIVITY[groupID]

				if(groupInfo.abbreviatedName) then
					shortName = groupInfo.abbreviatedName

				else
					mapID = miog.retrieveMapIDFromChallengeModeMap(v)
					local mapInfo = miog.GROUP_ACTIVITY[mapID]
					shortName = mapInfo.abbreviatedName

				end
			end

			rootDescription:CreateCheckbox(shortName,
				function(challengeMapID)
					return self.settings.activities[challengeMapID].visible
				end,
				function(challengeMapID)
					self.settings.activities[challengeMapID].visible = not self.settings.activities[challengeMapID].visible
					
					self:RefreshActivities()
			end, v)
		end
	end)

	--self.tableBuilder:Reset();
	ScrollUtil.RegisterScrollBoxWithScrollBar(self.ScrollBox, miog.pveFrame2.ScrollBarArea.ProgressMPlusScrollBar)

	local provider = CreateDataProvider()
	provider:SetSortComparator(sortCharacters)

	for guid in pairs(self.characterSettings) do
		self:UpdateSingleCharacterMythicPlusProgress(guid)

	end

	for guid, v in pairs(self.characterSettings) do
		v.guid = guid
		provider:Insert(v)

	end

	--self.OverviewTable:SetDataProvider(provider)
	--self.tableBuilder:SetDataProvider(provider);

	self:RefreshActivities()

	self.ScrollBox:SetDataProvider(provider)
end

function ProgressDungeonMixin:OnLoad()
	self.activities = C_ChallengeMode.GetMapTable()
	self.BackgroundTextures = {}
	self.BorderTextures = {}
	self.Columns = {}

	table.sort(self.activities, function(k1, k2)
		return miog.retrieveAbbreviatedNameFromChallengeModeMap(k1) < miog.retrieveAbbreviatedNameFromChallengeModeMap(k2)

	end)

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("BackdropTemplate", function(frame, data)
		-- dummy
		
	end)

	view:SetPadding(1, 1, 1, 1, 8);
	view:SetElementExtent(36)

	self.ScrollBox:Init(view)
	--ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, miog.pveFrame2.ScrollBarArea.ProgressMPlusScrollBar, view)

	self.tableBuilder = CreateTableBuilder(nil, TableBuilderSkinMixin);
	--self.tableBuilder:Init()

	--self.tableBuilder:SetColumnHeaderOverlap(2);
	self.tableBuilder:SetHeaderContainer(self.HeaderContainer);
	self.tableBuilder:SetTableMargins(5, 5);
	local function ElementDataProvider(elementData)
		return elementData;
	end;
	self.tableBuilder:SetDataProvider(ElementDataProvider);
	local function ElementDataTranslator(elementData)
		return elementData;
	end;
	ScrollUtil.RegisterTableBuilder(self.ScrollBox, self.tableBuilder, ElementDataTranslator);

	self:RefreshActivities()
end