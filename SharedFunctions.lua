local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.ONCE = true

miog.updateCurrencies = function()
	local currentSeason = 13 or C_MythicPlus.GetCurrentSeason()
	if(currentSeason > -1) then
		local currencyTable = miog.CURRENCY_INFO[currentSeason]

		if(currencyTable) then
			for k, v in ipairs(currencyTable) do
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(v.id)
				local currentFrame = miog.MainTab.Currency[tostring(k)]

				local insert = ""

				if(type(currencyInfo.maxQuantity) == "number" and currencyInfo.maxQuantity > 0) then
					insert = "/" .. currencyInfo.maxQuantity
				end

				if(currencyInfo.totalEarned > 0) then
					currentFrame.Text:SetText(currencyInfo.quantity .. " (" .. currencyInfo.totalEarned .. insert .. ")")

				else
					currentFrame.Text:SetText(currencyInfo.quantity .. insert)

				end
				currentFrame.Icon:SetTexture(v.icon or currencyInfo.iconFileID)
				currentFrame.Icon:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetCurrencyByID(v.id)
					GameTooltip:Show()
				end)
				currentFrame:Show()
				
			end

			for i = #currencyTable + 1, 6, 1 do
				miog.MainTab.Currency[tostring(i)]:Hide()

			end
		else
			miog.printDebug("No currencies for current season found. Current season:" .. currentSeason)

		end
	end
end

miog.resetNewRaiderIOInfoPanel = function(panel)
	for d = 1, 2, 1 do
		local raidHeaderFrame = d == 1 and panel.Raids["Raid1Header"] or panel.Raids["Raid2Header"]
		local raidBossesFrame = d == 1 and panel.Raids["Raid1"] or panel.Raids["Raid2"]

		raidHeaderFrame.Icon:SetTexture(nil)
		raidHeaderFrame.Name:SetText("")
		raidHeaderFrame.Progress1:SetText("")
		raidHeaderFrame.Progress2:SetText("")
		
		raidBossesFrame:Hide()

		for k = 1, 12, 1 do
			local bossFrame = raidBossesFrame["Boss" .. k]
			bossFrame:Hide()
			bossFrame.Icon:SetTexture(nil)
			bossFrame.Icon:SetDesaturated(true)
			bossFrame.Border:SetColorTexture(1,0,0,1)
	
		end
	end

	panel.PreviousData:SetText("")
	panel.MainData:SetText("")
	panel.MPlusKeys:SetText("")
	panel.RaceRolesServer:SetText("")

	if(panel.Comment) then
		panel.Comment:SetText("")
	end
end

local function DEPRECATED_resetRaiderIOInformationPanel(childFrame)
	if(childFrame.Hide) then
		childFrame:Hide()

	end

	for k, v in pairs(childFrame.RaiderIOInformationPanel.MythicPlusPanel) do
		if(type(v) == "table") then
			if(k == "Status") then
				v:Hide()
				
			else
				v.Name:SetText("")
				v.Primary:SetText("")
				v.Secondary:SetText("")
				v.Icon:SetTexture(nil)
			
			end
		end
	end

	for k, v in pairs(childFrame.RaiderIOInformationPanel.RaidPanel) do
		if(type(v) == "table") then
			if(k == "Status") then
				v:Hide()
				
			else
				v.Name:SetText("")
				v.Progress:SetText("")
				v.Icon:SetTexture(nil)
				
				for x, y in pairs(v.BossFrames.UpperRow) do
					if(type(y) == "table") then
						y.Icon:SetTexture(nil)
						y.Border:SetTexture(nil)
						y.Index:SetText("")

					end
				end
				
				for x, y in pairs(v.BossFrames.LowerRow) do
					if(type(y) == "table") then
						y.Icon:SetTexture(nil)
						y.Border:SetTexture(nil)
						y.Index:SetText("")

					end
				end
			end
		end
	end

	childFrame.RaiderIOInformationPanel.InfoPanel.MPlusKeys:SetText("")
	childFrame.RaiderIOInformationPanel.InfoPanel.Previous:SetText("")
	childFrame.RaiderIOInformationPanel.InfoPanel.Main:SetText("")
	childFrame.RaiderIOInformationPanel.InfoPanel.Realm:SetText("")
end

miog.resetRaiderIOInformationPanel = resetRaiderIOInformationPanel

miog.listGroup = function(manualAutoAccept) -- Effectively replaces LFGListEntryCreation_ListGroupInternal
	local frame = miog.EntryCreation
	local self = LFGListFrame.EntryCreation

	local activeEntryInfo = C_LFGList.GetActiveEntryInfo()

	local activityID = LFGListFrame.EntryCreation.selectedActivity or 0

	local itemLevel = tonumber(frame.ItemLevel:GetText()) or 0
	local rating = tonumber(frame.Rating:GetText()) or 0
	local pvpRating = (LFGListFrame.EntryCreation.selectedCategory == 4 or LFGListFrame.EntryCreation.selectedCategory == 9) and rating or 0
	local mythicPlusRating = LFGListFrame.EntryCreation.selectedCategory == 2 and rating or 0
	local selectedPlaystyle = frame.PlaystyleDropDown:IsShown() and LFGListFrame.EntryCreation.selectedPlaystyle or nil

	local autoAccept = manualAutoAccept or activeEntryInfo and activeEntryInfo.autoAccept or false
	local privateGroup = frame.PrivateGroup:GetChecked();
	local isCrossFaction =  frame.CrossFaction:IsShown() and not frame.CrossFaction:GetChecked();
	local questID = activeEntryInfo and activeEntryInfo.questID or 0

	local honorLevel = 0

	local createData = {
		activityIDs = { activityID },
		questID = questID,
		isAutoAccept = autoAccept,
		isCrossFactionListing = isCrossFaction,
		isPrivateGroup = privateGroup,
		playstyle = selectedPlaystyle,
		requiredDungeonScore = mythicPlusRating,
		requiredItemLevel = itemLevel,
		requiredPvpRating = pvpRating,
	};

	if ( LFGListEntryCreation_IsEditMode(self) ) then
		-- Pull these values from the active entry.
		createData.isAutoAccept = activeEntryInfo.autoAccept;
		createData.questID = activeEntryInfo.questID;

		if activeEntryInfo.isCrossFactionListing == isCrossFaction then
			C_LFGList.UpdateListing(createData);
		else
			-- Changing cross faction setting requires re-listing the group due to how listings are bucketed server side.
			C_LFGList.UpdateListing(createData);


			-- DOESNT WORK BECAUSE OF PROTECTION XD
			--C_LFGList.RemoveListing();
			--C_LFGList.CreateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
		end

		local unitName, unitID = miog.getGroupLeader()

		if(unitID == "player") then
			LFGListFrame_SetActivePanel(self:GetParent(), self:GetParent().ApplicationViewer);
			
		end
	else
		if(C_LFGList.HasActiveEntryInfo()) then
			C_LFGList.UpdateListing(createData)

		else
			C_LFGList.CreateListing(createData)

		end

		self.WorkingCover:Show();
		LFGListEntryCreation_ClearFocus(self);
	end
end

local function calculateWeightedScore(difficulty, kills, bossCount, current, ordinal)
	return (miog.WEIGHTS_TABLE[current and 1 or 2] * difficulty + miog.WEIGHTS_TABLE[current and 2 or 3] * kills / bossCount) + (miog.WEIGHTS_TABLE[current and 1 or 2] * difficulty + miog.WEIGHTS_TABLE[current and 2 or 3] * kills / bossCount) + (ordinal or 0)

end

miog.calculateWeightedScore = calculateWeightedScore

local function standardSortFunction(k1, k2)
    for k, v in ipairs(self.sortingParameters) do
        if(v.state > 0 and k1[v.name] ~= k2[v.name]) then
            if(v.state == 1) then
                return k1[v.name] < k2[v.name]

            else
                return k1[v.name] > k2[v.name]
            end
        end
    end
end

miog.standardSortFunction = standardSortFunction

local function retrieveCategoryGroups(categoryID)
	local raidInfo

    local raidGroups = C_LFGList.GetAvailableActivityGroups(categoryID, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.CategorySelection.selectedFilters or LFGListFrame.CategorySelection.baseFilters);

	if(#raidGroups > 0) then
		raidInfo = {}
		
		for k, v in ipairs(raidGroups) do
			local activities = C_LFGList.GetAvailableActivities(categoryID, v)
			local activityID = activities[#activities]

			tinsert(raidInfo, {name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, mapID = miog.ACTIVITY_INFO[activityID].mapID})
		end
	end
    
    return raidInfo
end

local function getNewRaidSortData(playerName, realm, region)
	local profile
	
	if(RaiderIO) then
		profile = RaiderIO.GetProfile(playerName, realm or GetNormalizedRealmName(), region or miog.F.CURRENT_REGION)
	end
	
	local raidData

	local raidInfo = retrieveCategoryGroups(2)

	if(raidInfo) then
		if(profile) then
			if(profile.raidProfile) then
				raidData = {character = {raids = {}, ordered = {}}, main = {raids = {}, ordered = {}}}

				for k, d in ipairs(profile.raidProfile.raidProgress) do
					local currentTable = d.isMainProgress and raidData.main or raidData.character

					local mapID
					local isAwakened = false

					if(string.find(d.raid.mapId, 10000)) then
						mapID = tonumber(strsub(d.raid.mapId, strlen(d.raid.mapId) - 3))
						isAwakened = d.current

					else
						mapID = d.raid.mapId

					end

					currentTable.raids[mapID] = currentTable.raids[mapID] or {regular = {difficulties = {}}, awakened = {difficulties = {}}, bossCount = d.raid.bossCount, isAwakened = isAwakened, shortName = d.raid.shortName}

					local modeTable = isAwakened and currentTable.raids[mapID].awakened or currentTable.raids[mapID].regular

					for x, y in ipairs(d.progress) do
						modeTable.difficulties[y.difficulty] = {
							difficulty = y.difficulty,
							current = d.current,
							kills = y.kills,
							cleared = y.cleared,
							mapID = mapID,
							shortName = currentTable.raids[mapID].shortName,
							weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current, d.raid.ordinal),
							parsedString = y.kills .. "/" .. d.raid.bossCount,
							bosses = {},
						}

						for a, b in ipairs(y.progress) do
							modeTable.difficulties[y.difficulty].bosses[a] = {
								killed = b.killed,
								count = b.count,
							}
						end

						currentTable.ordered[#currentTable.ordered+1] = modeTable.difficulties[y.difficulty]
					end

					table.sort(currentTable.ordered, function(k1, k2)
						if(k1.current == k2.current) then
							return k1.weight > k2.weight
							
						end

						return k1.current == k2.current
					end)
				end
			end
		end

		if(not raidData) then
			raidData = {
				character = {
					ordered = {
						[1] = {mapID = (raidInfo[3] or raidInfo[2] or raidInfo[1]).mapID, parsedString = "0/0", difficulty = -1},
						[2] = {mapID = (raidInfo[2] or raidInfo[1]).mapID, parsedString = "0/0", difficulty = -1},
					},
					raids = {}
				},
				main = {
					ordered = {
						[1] = {parsedString = "0/0", difficulty = -1},
						[2] = {parsedString = "0/0", difficulty = -1},
					},
					raids = {}
				},
			}
		else
			raidData.character.ordered[1] = raidData.character.ordered[1] or {mapID = (raidInfo[3] or raidInfo[2] or raidInfo[1]).mapID, parsedString = "0/0", difficulty = -1}
			raidData.character.ordered[2] = raidData.character.ordered[2] or {mapID = (raidInfo[2] or raidInfo[1]).mapID, parsedString = "0/0", difficulty = -1}
	
			raidData.main.ordered[1] = raidData.main.ordered[1] or {parsedString = "0/0", difficulty = -1}
			raidData.main.ordered[2] = raidData.main.ordered[2] or {parsedString = "0/0", difficulty = -1}
	
		end
	end

	return raidData
end

miog.getNewRaidSortData = getNewRaidSortData

local function getMPlusSortData(playerName, realm, region, returnAsBlizzardTable)
	local profile
	
	if(RaiderIO) then
		profile = RaiderIO.GetProfile(playerName, realm or GetNormalizedRealmName(), region and strlower(region) or miog.F.CURRENT_REGION)
	end

	if(profile) then
		local mplusData = {}
		local intimeInfo, overtimeInfo

		if(profile.mythicKeystoneProfile) then
			if(profile.mythicKeystoneProfile.sortedDungeons) then
				for i, dungeonEntry in ipairs(profile.mythicKeystoneProfile.sortedDungeons) do

					if(returnAsBlizzardTable) then
						local table

						if(dungeonEntry.chests > 0) then
							intimeInfo = intimeInfo or {}
							table = intimeInfo

						else
							overtimeInfo = overtimeInfo or {}
							table = overtimeInfo

						end

						table[dungeonEntry.dungeon.keystone_instance] = {
							durationSec = dungeonEntry.dungeon.timers[dungeonEntry.chests == 0 and 3 or dungeonEntry.chests == 1 and 2 or dungeonEntry.chests == 2 and 1] + (dungeonEntry.chests < 3 and 1 or -1),
							level = dungeonEntry.level,
						}
						
						--table[dungeonEntry.dungeon.keystone_instance].dungeonScore = miog.calculateMapScore(dungeonEntry.dungeon.keystone_instance, table[dungeonEntry.dungeon.keystone_instance])

					else
						mplusData[dungeonEntry.dungeon.instance_map_id] = {
							level = profile.mythicKeystoneProfile.dungeons[i],
							chests = profile.mythicKeystoneProfile.dungeonUpgrades[i]
						}

					end
				end
			end

			if(not returnAsBlizzardTable) then
				mplusData.score = profile.mythicKeystoneProfile.mplusCurrent
				mplusData.previousScore = profile.mythicKeystoneProfile.mplusPrevious
		
				mplusData.mainScore = profile.mythicKeystoneProfile.mplusMainCurrent
				mplusData.mainPreviousScore = profile.mythicKeystoneProfile.mplusMainPrevious
		
				mplusData.keystoneMilestone2 = profile.mythicKeystoneProfile.keystoneMilestone2
				mplusData.keystoneMilestone4 = profile.mythicKeystoneProfile.keystoneMilestone4
				mplusData.keystoneMilestone7 = profile.mythicKeystoneProfile.keystoneMilestone7
				mplusData.keystoneMilestone10 = profile.mythicKeystoneProfile.keystoneMilestone10
				mplusData.keystoneMilestone12 = profile.mythicKeystoneProfile.keystoneMilestone12
				mplusData.keystoneMilestone15 = profile.mythicKeystoneProfile.keystoneMilestone15
			end

		else
			if(not returnAsBlizzardTable) then
				mplusData.score = {score = 0}
				mplusData.previousScore = {score = 0}
		
				mplusData.mainScore = {score = 0}
				mplusData.mainPreviousScore = {score = 0}
		
				mplusData.keystoneMilestone2 = 0
				mplusData.keystoneMilestone4 = 0
				mplusData.keystoneMilestone7 = 0
				mplusData.keystoneMilestone10 = 0
				mplusData.keystoneMilestone12 = 0
				mplusData.keystoneMilestone15 = 0
			else

			end
		end

		return mplusData, intimeInfo, overtimeInfo
	end
end

miog.getMPlusSortData = getMPlusSortData

miog.updateFooterBarResults = function(filteredResultNumber, totalResultNumber, setSearchScript)
	miog.Plugin.FooterBar.Results:SetText(filteredResultNumber .. "(" .. totalResultNumber .. ")")
	
	miog.Plugin.FooterBar.Results:SetScript("OnEnter", setSearchScript and function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("There might be more groups listed.")
		GameTooltip:AddLine("Try to pre-filter by typing something in the search bar.")
		GameTooltip:Show()
	end or nil)
end

miog.isMIOGHQLoaded = function()
	return true
end

miog.setInfoIndicators = function(frameWithDoubleIndicators, categoryID, dungeonScore, dungeonData, raidData, pvpData)
	local primaryIndicator, secondaryIndicator = frameWithDoubleIndicators.Primary, frameWithDoubleIndicators.Secondary

	if(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
		if(pvpData.tier and pvpData.tier ~= "N/A") then
			local tierResult = miog.simpleSplit(PVPUtil.GetTierName(pvpData.tier), " ")
			primaryIndicator:SetText(wticc(tostring(pvpData.rating), miog.createCustomColorForRating(pvpData.rating):GenerateHexColor()))
			secondaryIndicator:SetText(strsub(tierResult[1], 0, tierResult[2] and 2 or 4) .. ((tierResult[2] and "" .. tierResult[2]) or ""))

		else
			primaryIndicator:SetText(0)
			secondaryIndicator:SetText("Unra")
		
		end
	
	elseif(categoryID ~= 3) then
		if(dungeonScore > 0) then
			local reqScore = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().requiredDungeonScore or 0
			local highestKeyForDungeon

			if(reqScore > dungeonScore) then
				primaryIndicator:SetText(wticc(tostring(dungeonScore), miog.CLRSCC.red))

			else
				primaryIndicator:SetText(wticc(tostring(dungeonScore), miog.createCustomColorForRating(dungeonScore):GenerateHexColor()))

			end

			if(dungeonData) then
				highestKeyForDungeon = wticc(tostring(dungeonData.bestRunLevel), dungeonData.finishedSuccess and miog.C.GREEN_COLOR or miog.CLRSCC.red)

			else
				highestKeyForDungeon = wticc("0", miog.CLRSCC.red)

			end

			secondaryIndicator:SetText(highestKeyForDungeon)
		else
			primaryIndicator:SetText(wticc("0", miog.DIFFICULTY[-1].color))
			secondaryIndicator:SetText(wticc("0", miog.DIFFICULTY[-1].color))

		end
	elseif(raidData) then
		if(raidData.character.ordered[1]) then
			primaryIndicator:SetText(wticc(raidData.character.ordered[1].parsedString, raidData.character.ordered[1].current and miog.DIFFICULTY[raidData.character.ordered[1].difficulty].color or miog.DIFFICULTY[raidData.character.ordered[1].difficulty].desaturated))
		end

		if(raidData.character.ordered[2]) then
			secondaryIndicator:SetText(wticc(raidData.character.ordered[2].parsedString, raidData.character.ordered[2].current and miog.DIFFICULTY[raidData.character.ordered[2].difficulty].color or miog.DIFFICULTY[raidData.character.ordered[2].difficulty].desaturated))
		end

	end
end

local function getRaidSortData(playerName)
	local profile

	if(miog.F.IS_RAIDERIO_LOADED) then
		profile = RaiderIO.GetProfile(playerName)

	end

	--[[

		raidProgress table
			1 table
				current bool
				isMainProgress bool

				raid table
					bossCount number
					id number
					mapID number
					ordinal number
					name string
					shortName string

				progress table
					1
						cleared bool
						obsolete bool
						difficulty number
						kills number
						progress table
							1
								killed bool
								count number
								difficulty number
								index number

				



	]]

	local currentData = {}
	local nonCurrentData = {}
	local mainData = {}
	local orderedData = {}

	if(profile and profile.success == true) then
		if(profile.raidProfile) then
			for k, d in ipairs(profile.raidProfile.raidProgress) do
				if(d.isMainProgress == false) then
					if(d.current == true) then
						local highestDifficulty = 1

						for x, y in ipairs(d.progress) do
							local mapID
							local awakened = false

							if(string.find(d.raid.mapId, 10000)) then
								mapID = tonumber(strsub(d.raid.mapId, strlen(d.raid.mapId) - 3))
								awakened = d.current
							else
								mapID = d.raid.mapId

							end

							if(highestDifficulty < y.difficulty) then
								highestDifficulty = y.difficulty
							end

							currentData[#currentData+1] = {
								ordinal = d.raid.ordinal,
								raidProgressIndex = k,
								mapId = mapID,
								difficulty = y.difficulty,
								current = d.current,
								shortName = d.raid.shortName,
								progress = y.kills,
								bossCount = d.raid.bossCount,
								parsedString = y.kills .. "/" .. d.raid.bossCount,
								weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current, d.raid.ordinal)
							}
							
						end
					elseif(d.current == false) then

						local highestDifficulty = 1

						for x, y in ipairs(d.progress) do
							local mapID
							local awakened = false

							if(string.find(d.raid.mapId, 10000)) then
								mapID = tonumber(strsub(d.raid.mapId, strlen(d.raid.mapId) - 3))
								awakened = true

							else
								mapID = d.raid.mapId

							end

							if(highestDifficulty < y.difficulty) then
								highestDifficulty = y.difficulty
							end

							nonCurrentData[#nonCurrentData+1] = {
								ordinal = d.raid.ordinal,
								raidProgressIndex = k,
								mapId = mapID,
								difficulty = y.difficulty,
								current = d.current,
								shortName = d.raid.shortName,
								progress = y.kills,
								bossCount = d.raid.bossCount,
								parsedString = y.kills .. "/" .. d.raid.bossCount,
								weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current, d.raid.ordinal)
							}
						end
					end
				else
					for x, y in ipairs(d.progress) do
						local mapID
						local awakened = false

						if(string.find(d.raid.mapId, 10000)) then
							mapID = tonumber(strsub(d.raid.mapId, strlen(d.raid.mapId) - 3))
							awakened = true

						else
							mapID = d.raid.mapId

						end

						mainData[#mainData+1] = {
							ordinal = d.raid.ordinal,
							raidProgressIndex = k,
							mapId = mapID,
							difficulty = y.difficulty,
							current = d.current,
							shortName = d.raid.shortName,
							progress = y.kills,
							bossCount = d.raid.bossCount,
							parsedString = y.kills .. "/" .. d.raid.bossCount,
							weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current, d.raid.ordinal)
						}
					end
				end
			end
		end
	end


	table.sort(currentData, function(k1, k2)
		return k1.difficulty > k2.difficulty
	end)

	table.sort(nonCurrentData, function(k1, k2)
		return k1.difficulty > k2.difficulty
	end)

	table.sort(mainData, function(k1, k2)
		return k1.difficulty > k2.difficulty
	end)

	if(currentData) then
		for k, v in ipairs(currentData) do
			orderedData[#orderedData+1] = v
		end
	end

	if(nonCurrentData) then
		for k, v in ipairs(nonCurrentData) do
			orderedData[#orderedData+1] = v
		end
	end

	if(#orderedData < 3) then
		for i = #orderedData + 1, 3, 1 do
			orderedData[i] = {
				difficulty = -1,
				progress = 0,
				bossCount = 0,
				parsedString = "0/0",
				weight = 0
			}
		end
	end


	for i = 1, 3, 1 do
		if(currentData[i] == nil) then
			currentData[i] = {
				difficulty = -1,
				progress = 0,
				bossCount = 0,
				parsedString = "0/0",
				weight = 0
			}
		end
	end

	for i = 1, 3, 1 do
		if(nonCurrentData[i] == nil) then
			nonCurrentData[i] = {
				difficulty = -1,
				progress = 0,
				bossCount = 0,
				parsedString = "0/0",
				weight = 0
			}
		end
	end
	
	for i = 1, 3, 1 do
		if(mainData[i] == nil) then
			mainData[i] = {
				difficulty = -1,
				progress = 0,
				bossCount = 0,
				parsedString = "0/0",
				weight = 0
			}
		end
	end

	return currentData, nonCurrentData, orderedData, mainData
end

miog.getRaidSortData = getRaidSortData

miog.updateRaiderIOScrollBoxFrameData = function(frame, data)
	local playerName, realm, comment, activityID

	if(data.resultID) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(data.resultID)
		--local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1])
		playerName, realm = miog.createSplitName(searchResultInfo.leaderName)
		comment = searchResultInfo.comment
		activityID = searchResultInfo.activityIDs[1]

	elseif(data.applicantID) then
		playerName, realm = data.name, data.realm
		comment = (miog.F.IS_IN_DEBUG_MODE and miog.debug_GetApplicantInfo(data.applicantID) or C_LFGList.GetApplicantInfo(data.applicantID)).comment
		activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityIDs[1] or 0

	end
	
	frame:Flush()
	frame:SetPlayerData(playerName, realm)
	frame:SetOptionalData(comment, realm)
	frame:ApplyFillData(true)

	frame.Background:SetTexture(miog.ACTIVITY_INFO[activityID].horizontal, "CLAMP", "MIRROR")
	frame.Background:SetVertexColor(0.75, 0.75, 0.75, 0.4)
end

miog.hideSidePanel = function(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	self:GetParent():Hide()
	self:GetParent():GetParent().ButtonPanel:Show()

	MIOG_NewSettings.activeSidePanel = "none"
end

-- type == unitID or unitName
-- value == (unitID) player, party3, raid29 or (unitName) Rhany, Merkuz, Solomeio-Ravencrest
local function createFullNameFrom(type, value)
	local name

	local realm = GetNormalizedRealmName()

	if(realm) then
		if(type == "unitID") then
			if(value == "player") then
				local shortName, realm2 = UnitFullName(value)

				if(shortName and realm2) then
					name = shortName .. "-" .. realm2

				else
					name = UnitNameUnmodified("player") .. "-" .. realm
				
				end

			else
				name = GetUnitName(value, true)
			
			end

		elseif(type == "unitName") then
			name = value
			
		else
			return nil
			
		end

		if(name) then
			local nameTable = miog.simpleSplit(name, "-")
			
			if(not nameTable[2]) then
				name = nameTable[1] .. "-" .. realm

			end
		end
	end

	return name
end

miog.createFullNameFrom = createFullNameFrom

local function createShortNameFrom(type, value)
	if(type == "unitID") then
		return UnitName(value)

	else
		local nameTable = miog.simpleSplit(value, "-")

		if(not nameTable[2]) then
			return value

		else
			return nameTable[1]

		end
	end
end

miog.createShortNameFrom = createShortNameFrom

local function printOnce(string)
	if(miog.ONCE) then
		miog.ONCE = false

		print(string)

	end
end

miog.printOnce = printOnce

miog.getGroupLeader = function()
	local numOfMembers = GetNumGroupMembers()
	miog.F.LFG_STATE = miog.checkLFGState()

	for groupIndex = 1, numOfMembers, 1 do
		local unitID = ((IsInRaid() or (IsInGroup() and (numOfMembers ~= 1 and groupIndex ~= numOfMembers))) and miog.F.LFG_STATE..groupIndex) or "player"

		if(UnitIsGroupLeader(unitID)) then
			return UnitName(unitID), (UnitGUID(unitID) == UnitGUID("player") and "player" or unitID)

		end
	end
end

hooksecurefunc("LFGListSearchPanel_DoSearch", function(self)
	miog.blizzardFilters = C_LFGList.GetAdvancedFilter()

	LFGListFrame.SearchPanel.SearchBox:ClearAllPoints()
	LFGListFrame.SearchPanel.SearchBox:SetParent(miog.SearchPanel)
	LFGListFrame.SearchPanel.FilterButton:Hide()

	if(not miog.F.LITE_MODE) then
		LFGListFrame.SearchPanel.SearchBox:SetSize(miog.SearchPanel.SearchBoxBase:GetSize())

	else
		LFGListFrame.SearchPanel.SearchBox:SetWidth(miog.SearchPanel.standardSearchBoxWidth - 100)
	
	end

	LFGListFrame.SearchPanel.SearchBox:SetPoint(miog.SearchPanel.SearchBoxBase:GetPoint())
	LFGListFrame.SearchPanel.SearchBox:SetFrameStrata("HIGH")
	LFGListFrame.SearchPanel.SearchBox:SetFrameLevel(9999)
end)

miog.getCurrentCategoryID = function()
	local currentPanel = miog.DropChecker and miog.DropChecker:IsShown() and "DropChecker" or LFGListFrame.activePanel:GetDebugName()
	local categoryID

	if(currentPanel ~= "DropChecker") then
		categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID
		or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityIDs[1]).categoryID or
		LFGListFrame.CategorySelection.selectedCategory
	else
		categoryID = 0

	end


	return categoryID, currentPanel
end

miog.createSplitName = function(name)
	local nameTable = miog.simpleSplit(name, "-")

	if(not nameTable[2]) then
		nameTable[2] = GetNormalizedRealmName()

	end

	return nameTable[1], nameTable[2]
end

miog.getActiveSortMethods = function(panel)
	local numberOfActiveMethods = 0

	for k, v in pairs(MIOG_NewSettings.sortMethods[panel]) do
		if(v.active) then
			numberOfActiveMethods = numberOfActiveMethods + 1
		end
	end

	return numberOfActiveMethods
end

miog.checkEgoTrip = function(name)
	if(name == "Rhany-Ravencrest" or name == "Gerhanya-Ravencrest") then
		GameTooltip:AddLine("You've found the creator of this addon.\nHow lucky!")

	end
end

local function desaturateTexture(bool, texture)
	if(bool) then
		texture:SetVertexColor(1, 1, 1, 1)

	else
		texture:SetVertexColor(0.75, 0.75, 0.75, 0.25)
	
	end
end

local function insertLFGInfo(activityID)
	local entryInfo = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo()
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID or entryInfo.activityIDs[1])

	--miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons.secondary:Enable()

	if(activityInfo.categoryID == 2) then --Dungeons
		miog.F.CURRENT_DUNGEON_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DUNGEON_DIFFICULTY

	elseif(activityInfo.categoryID == 3) then --Raids
		miog.F.CURRENT_RAID_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_RAID_DIFFICULTY
	end

	miog.ApplicationViewer.InfoPanel.Background:SetTexture(miog.ACTIVITY_INFO[entryInfo.activityIDs[1]] and miog.ACTIVITY_INFO[entryInfo.activityIDs[1]].horizontal or miog.ACTIVITY_BACKGROUNDS[activityInfo.categoryID])

	miog.ApplicationViewer.TitleBar.FontString:SetText(entryInfo.name)
	miog.ApplicationViewer.InfoPanel.Activity:SetText(activityInfo.fullName)

	miog.ApplicationViewer.CreationSettings.PrivateGroupButton:SetChecked(entryInfo.privateGroup)

	if(entryInfo.playstyle) then
		local playStyleString = (activityInfo.isMythicPlusActivity and miog.PLAYSTYLE_STRINGS["mPlus"..entryInfo.playstyle]) or
		(activityInfo.isMythicActivity and miog.PLAYSTYLE_STRINGS["mZero"..entryInfo.playstyle]) or
		(activityInfo.isCurrentRaidActivity and miog.PLAYSTYLE_STRINGS["raid"..entryInfo.playstyle]) or
		((activityInfo.isRatedPvpActivity or activityInfo.isPvpActivity) and miog.PLAYSTYLE_STRINGS["pvp"..entryInfo.playstyle])

		miog.ApplicationViewer.CreationSettings.Playstyle.tooltipText = playStyleString

	else
		miog.ApplicationViewer.CreationSettings.Playstyle.tooltipText = ""

	end

	if(entryInfo.requiredDungeonScore and activityInfo.categoryID == 2 or entryInfo.requiredPvpRating and activityInfo.categoryID == (4 or 7 or 8 or 9)) then
		miog.ApplicationViewer.CreationSettings.Rating.tooltipText = "Required rating: " .. entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating
		miog.ApplicationViewer.CreationSettings.Rating.FontString:SetText(entryInfo.requiredDungeonScore or entryInfo.requiredPvpRating)

		miog.ApplicationViewer.CreationSettings.Rating.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .. (entryInfo.requiredDungeonScore and "/infoIcons/skull.png" or entryInfo.requiredPvpRating and "/infoIcons/spear.png"))

	else
		miog.ApplicationViewer.CreationSettings.Rating.FontString:SetText("----")
		miog.ApplicationViewer.CreationSettings.Rating.tooltipText = ""

	end

	if(entryInfo.requiredItemLevel > 0) then
		miog.ApplicationViewer.CreationSettings.ItemLevel.FontString:SetText(entryInfo.requiredItemLevel)
		miog.ApplicationViewer.CreationSettings.ItemLevel.tooltipText = "Required itemlevel: " .. entryInfo.requiredItemLevel

	else
		miog.ApplicationViewer.CreationSettings.ItemLevel.FontString:SetText("---")
		miog.ApplicationViewer.CreationSettings.ItemLevel.tooltipText = ""

	end

	--if(entryInfo.voiceChat ~= "") then
		--LFGListFrame.EntryCreation.VoiceChat.CheckButton:SetChecked(true)

	--end

	miog.ApplicationViewer.CreationSettings.VoiceChatButton:SetChecked(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked())

	desaturateTexture(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked(), miog.ApplicationViewer.CreationSettings.VoiceChatButton:GetNormalTexture())
	desaturateTexture(entryInfo.privateGroup, miog.ApplicationViewer.CreationSettings.PrivateGroupButton:GetNormalTexture())
	desaturateTexture(entryInfo.autoAccept, miog.ApplicationViewer.CreationSettings.AutoAcceptButton:GetNormalTexture())

	--[[if(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked()) then
		--miog.ApplicationViewer.CreationSettings.VoiceChat.tooltipText = entryInfo.voiceChat
		miog.ApplicationViewer.CreationSettings.VoiceChat:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOn.png")

	else
		miog.ApplicationViewer.CreationSettings.VoiceChat.tooltipText = ""
		miog.ApplicationViewer.CreationSettings.VoiceChat:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/voiceChatOff.png")

	end]]

	if(entryInfo.isCrossFactionListing == true) then
		miog.ApplicationViewer.TitleBar.Faction:SetTexture(2437241)

	else
		local playerFaction = UnitFactionGroup("player")
		miog.ApplicationViewer.TitleBar.Faction:SetTexture(playerFaction == "Alliance" and 2173919 or playerFaction == "Horde" and 2173920)

	end

	if(entryInfo.comment ~= "") then
		miog.ApplicationViewer.InfoPanel.Description.Container.FontString:SetText("Description: " .. entryInfo.comment)
		miog.ApplicationViewer.InfoPanel.Description.Container:SetHeight(miog.ApplicationViewer.InfoPanel.Description.Container.FontString:GetStringHeight())

	else
		miog.ApplicationViewer.InfoPanel.Description.Container.FontString:SetText("")

	end
end

miog.insertLFGInfo = insertLFGInfo

local function ResolveCategoryFilters(categoryID, filters)
	-- Dungeons ONLY display recommended groups.
	if categoryID == GROUP_FINDER_CATEGORY_ID_DUNGEONS then
		return bit.band(bit.bnot(Enum.LFGListFilter.NotRecommended), bit.bor(filters, Enum.LFGListFilter.Recommended));
	end

	return filters;
end

miog.ResolveCategoryFilters = ResolveCategoryFilters