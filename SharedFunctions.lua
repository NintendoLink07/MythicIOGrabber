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
				local currentFrame = miog.MainTab.Information.Currency[tostring(k)]

				if(currencyInfo.totalEarned > 0) then
					currentFrame.Text:SetText(currencyInfo.quantity .. " (" .. currencyInfo.totalEarned .. "/" .. currencyInfo.maxQuantity .. ")")

				else
					currentFrame.Text:SetText(currencyInfo.quantity .. "/" .. currencyInfo.maxQuantity)

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
				miog.MainTab.Information.Currency[tostring(i)]:Hide()

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

	local activityID = frame.DifficultyDropDown.Selected.value or frame.ActivityDropDown.Selected.value or 0

	local itemLevel = tonumber(frame.ItemLevel:GetText()) or 0
	local rating = tonumber(frame.Rating:GetText()) or 0
	local pvpRating = (LFGListFrame.EntryCreation.selectedCategory == 4 or LFGListFrame.EntryCreation.selectedCategory == 9) and rating or 0
	local mythicPlusRating = LFGListFrame.EntryCreation.selectedCategory == 2 and rating or 0
	local selectedPlaystyle = frame.PlaystyleDropDown:IsShown() and frame.PlaystyleDropDown.Selected.value or nil

	local autoAccept = manualAutoAccept or activeEntryInfo and activeEntryInfo.autoAccept or false
	local privateGroup = frame.PrivateGroup:GetChecked();
	local isCrossFaction =  frame.CrossFaction:IsShown() and not frame.CrossFaction:GetChecked();
	local questID = activeEntryInfo and activeEntryInfo.questID or 0

	local honorLevel = 0

	if ( LFGListEntryCreation_IsEditMode(self) ) then
		if activeEntryInfo.isCrossFactionListing == isCrossFaction then
			C_LFGList.UpdateListing(activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
		else
			-- Changing cross faction setting requires re-listing the group due to how listings are bucketed server side.
			C_LFGList.UpdateListing(activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);


			-- DOESNT WORK BECAUSE OF PROTECTION XD
			--C_LFGList.RemoveListing();
			--C_LFGList.CreateListing(activityID, itemLevel, honorLevel, activeEntryInfo.autoAccept, privateGroup, activeEntryInfo.questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction);
		end

		LFGListFrame_SetActivePanel(self:GetParent(), self:GetParent().ApplicationViewer);
	else
		if(C_LFGList.HasActiveEntryInfo()) then
			C_LFGList.UpdateListing(activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction)

		else
			C_LFGList.CreateListing(activityID, itemLevel, honorLevel, autoAccept, privateGroup, questID, mythicPlusRating, pvpRating, selectedPlaystyle, isCrossFaction)

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

local function getNewRaidSortData(playerName, realm, region)
	local profile
	
	if(RaiderIO) then 
		profile = RaiderIO.GetProfile(playerName, realm or GetNormalizedRealmName(), region or miog.F.CURRENT_REGION)
	end
	
	local raidData

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
						bossesKilled = y.kills,
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
					[1] = {mapID = miog.SEASONAL_MAP_IDS[13].raids[1], parsedString = "0/0", difficulty = -1},
					[2] = {mapID = miog.SEASONAL_MAP_IDS[13].raids[1], parsedString = "0/0", difficulty = -1},
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
		raidData.character.ordered[1] = raidData.character.ordered[1] or {mapID = miog.SEASONAL_MAP_IDS[13].raids[1], parsedString = "0/0", difficulty = -1}
		raidData.character.ordered[2] = raidData.character.ordered[2] or {mapID = miog.SEASONAL_MAP_IDS[13].raids[1], parsedString = "0/0", difficulty = -1}

		raidData.main.ordered[1] = raidData.main.ordered[1] or {parsedString = "0/0", difficulty = -1}
		raidData.main.ordered[2] = raidData.main.ordered[2] or {parsedString = "0/0", difficulty = -1}

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
		local intimeInfo = {}
		local overtimeInfo = {}

		if(profile.mythicKeystoneProfile) then
			if(profile.mythicKeystoneProfile.sortedDungeons) then
				for i, dungeonEntry in ipairs(profile.mythicKeystoneProfile.sortedDungeons) do

					if(returnAsBlizzardTable) then
						local table = dungeonEntry.chests > 0 and intimeInfo or overtimeInfo

						table[dungeonEntry.dungeon.keystone_instance] = {
							durationSec = dungeonEntry.dungeon.timers[dungeonEntry.chests == 0 and 3 or dungeonEntry.chests == 1 and 2 or dungeonEntry.chests == 2 and 1] + (dungeonEntry.chests < 3 and 1 or -1),
							level = dungeonEntry.level,
						}

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

getMPlusSortData("Rhany", "Ravencrest", "eu", true)

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
			local reqScore = miog.F.ACTIVE_ENTRY_INFO and miog.F.ACTIVE_ENTRY_INFO.requiredDungeonScore or 0
			local highestKeyForDungeon

			if(reqScore > dungeonScore) then
				primaryIndicator:SetText(wticc(tostring(dungeonScore), miog.CLRSCC.red))

			else
				primaryIndicator:SetText(wticc(tostring(dungeonScore), miog.createCustomColorForRating(dungeonScore):GenerateHexColor()))

			end

			if(dungeonData) then
				if(dungeonData.finishedSuccess == true) then
					highestKeyForDungeon = wticc(tostring(dungeonData.bestRunLevel), miog.C.GREEN_COLOR)

				elseif(dungeonData.finishedSuccess == false) then
					highestKeyForDungeon = wticc(tostring(dungeonData.bestRunLevel), miog.CLRSCC.red)

				end
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
					name = UnitName("player") .. "-" .. realm
				
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
	LFGListFrame.SearchPanel.SearchBox:SetFrameStrata("DIALOG")
	LFGListFrame.SearchPanel.SearchBox:SetFrameLevel(9999)
end)

miog.getCurrentCategoryID = function()
	local currentPanel = LFGListFrame.activePanel:GetDebugName()
	local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID
	or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActivityInfoTable(C_LFGList.GetActiveEntryInfo().activityID).categoryID or
	LFGListFrame.CategorySelection.selectedCategory

	return categoryID, currentPanel
end

miog.fillNewRaiderIOPanel = function(raiderIOPanel, playerName, realm)
	local forceSeason = 13

	local mplusData = miog.getMPlusSortData(playerName, realm)

	for k, v in ipairs(miog.SEASONAL_MAP_IDS[forceSeason].dungeons) do
		local currentDungeon = raiderIOPanel.MythicPlus["Dungeon" .. k]
		currentDungeon.Name:SetText(miog.MAP_INFO[v].shortName)
		currentDungeon.Icon:SetTexture(miog.MAP_INFO[v].icon)
		currentDungeon.Icon:SetScript("OnMouseDown", function()
			local instanceID = C_EncounterJournal.GetInstanceForGameMap(v)

			--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
			EncounterJournal_OpenJournal(EJ_GetDifficulty(), instanceID, nil, nil, nil, nil)

		end)

		if(mplusData and mplusData[v]) then
			local levelText = mplusData and (mplusData[v].level .. " " .. strrep(miog.C.RIO_STAR_TEXTURE, miog.F.IS_IN_DEBUG_MODE and 3 or mplusData[v].chests)) or 0
		
			currentDungeon.Level:SetText(wticc(levelText, mplusData and mplusData[v].chests > 0 and miog.C.GREEN_COLOR or miog.CLRSCC.red))
		else
			currentDungeon.Level:SetText(wticc(0, miog.CLRSCC.red))

		end

	end

	if(mplusData) then
		--local currentSeason = miog.MPLUS_SEASONS[miog.F.CURRENT_SEASON] or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason()]
		--local previousSeason = miog.MPLUS_SEASONS[miog.F.PREVIOUS_SEASON] or miog.MPLUS_SEASONS[C_MythicPlus.GetCurrentSeason() - 1]

		if(mplusData.previousScore.score > 0) then
			raiderIOPanel.PreviousData:SetText("Best m+ rating (S" .. mplusData.previousScore.season .. "): " .. wticc(mplusData.previousScore.score, miog.createCustomColorForRating(mplusData.previousScore.score):GenerateHexColor()))

		else
			raiderIOPanel.PreviousData:SetText("No previous m+ rating")
			
		end

		if(mplusData.mainScore.score > 0) then
			raiderIOPanel.MainData:SetText("Main: " .. wticc(mplusData.mainScore.score, miog.createCustomColorForRating(mplusData.mainScore.score):GenerateHexColor()))

			if(mplusData.mainPreviousScore.score > 0) then
				raiderIOPanel.MainData:SetText(raiderIOPanel.MainData:GetText() .. " (S" .. mplusData.mainPreviousScore.season .. ": ".. (mplusData.mainPreviousScore and wticc(mplusData.mainPreviousScore.score, miog.createCustomColorForRating(mplusData.mainPreviousScore.score):GenerateHexColor()) .. ")" or "N/A"))
				
			else
				raiderIOPanel.MainData:SetText(raiderIOPanel.MainData:GetText() .. " (No previous m+ rating)")
	
			end
		else
			raiderIOPanel.MainData:SetText(wticc("Main m+ char. ", miog.ITEM_QUALITY_COLORS[7].pureHex))

		end

		raiderIOPanel.MPlusKeys:SetText("M+ Keys done: " ..
			WrapTextInColorCode(mplusData.keystoneMilestone2 or "0", miog.ITEM_QUALITY_COLORS[2].pureHex) .. " - " ..
			WrapTextInColorCode(mplusData.keystoneMilestone4 or "0", miog.ITEM_QUALITY_COLORS[3].pureHex) .. " - " ..
			WrapTextInColorCode(mplusData.keystoneMilestone7 or "0", miog.ITEM_QUALITY_COLORS[4].pureHex) .. " - " ..
			WrapTextInColorCode(mplusData.keystoneMilestone10 or "0", miog.ITEM_QUALITY_COLORS[5].pureHex) .. " - " ..
			WrapTextInColorCode(mplusData.keystoneMilestone12 or "0", miog.ITEM_QUALITY_COLORS[6].pureHex) .. " - " ..
			WrapTextInColorCode(mplusData.keystoneMilestone15 or "0", miog.ITEM_QUALITY_COLORS[7].pureHex)
		)

	else
		raiderIOPanel.PreviousData:SetText("No previous m+ rating. ")
		raiderIOPanel.MainData:SetText("No main m+ rating. ")
		raiderIOPanel.MPlusKeys:SetText("No m+ keys done.")

	end

	local raidData = miog.getNewRaidSortData(playerName, realm)

	local raidCounter = 1
	local raidMapIDSet = {}

	for k, v in ipairs(miog.SEASONAL_MAP_IDS[forceSeason].raids) do
		local raidBossesFrame = raiderIOPanel.Raids["Raid" .. raidCounter]

		if(raidBossesFrame) then
			local raidHeaderFrame = raiderIOPanel.Raids["Raid" .. raidCounter .. "Header"]
		
			raidHeaderFrame.Progress1:SetText(wticc("0/"..#miog.MAP_INFO[v].bosses, miog.CLRSCC.red))
			raidHeaderFrame.Progress2:SetText(wticc("0/"..#miog.MAP_INFO[v].bosses, miog.CLRSCC.red))

			raidHeaderFrame.Icon:SetTexture(miog.MAP_INFO[v].icon)
			raidHeaderFrame.Icon:SetScript("OnMouseDown", function()
				local instanceID = C_EncounterJournal.GetInstanceForGameMap(v)
				local difficulty = 16
				--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
				EncounterJournal_OpenJournal(difficulty, instanceID, nil, nil, nil, nil)

			end)
			raidHeaderFrame.Name:SetText(miog.MAP_INFO[v].shortName)
			
            miog.checkSingleMapIDForNewData(v)

			for i = 1, 12, 1 do
				local currentBoss = "Boss" .. i

				if(miog.MAP_INFO[v].bosses[i]) then
					raidBossesFrame[currentBoss].Index:SetText(i)
					raidBossesFrame[currentBoss].Icon:SetTexture(miog.MAP_INFO[v].bosses[i].icon)
					raidBossesFrame[currentBoss].Icon:SetScript("OnMouseDown", function()
						local instanceID = C_EncounterJournal.GetInstanceForGameMap(v)
						local difficulty = 16
						EncounterJournal_OpenJournal(difficulty, instanceID, select(3, EJ_GetEncounterInfoByIndex(i, instanceID)), nil, nil, nil)
					end)

					raidBossesFrame[currentBoss]:Show()

				else
					raidBossesFrame[currentBoss]:Hide()

				end
			end

			raidBossesFrame:Show()
			raidHeaderFrame:Show()

			if(raidData) then
				for nmd = 1, 2, 1 do
					local normalOrMainData = nmd == 1 and raidData.character or raidData.main

					if(normalOrMainData.raids[v]) then
						local bossesDone = {}

						for i = 1, 2, 1 do
							local currentTable = i == 1 and normalOrMainData.raids[v].awakened or normalOrMainData.raids[v].regular
							if(currentTable) then

								for a = 3, 1, -1 do
									if(currentTable.difficulties[a]) then
										for z = 1, 12, 1 do
											if(currentTable.difficulties[a].bosses[z] and not bossesDone[z]) then
												local currentBoss = "Boss" .. z

												if(currentTable.difficulties[a].bosses[z].killed) then
													raidBossesFrame[currentBoss].Border:SetColorTexture(miog.DIFFICULTY[a].miogColors:GetRGBA());
													raidBossesFrame[currentBoss].Icon:SetDesaturated(false)
													bossesDone[z] = true

												else
													--currentRaid[currentBoss].Border:SetColorTexture(0,0,0,0)
									
												end
											end
										end

										if(raidMapIDSet[v] ~= true) then
											if(normalOrMainData.raids[v].isAwakened) then
												raidHeaderFrame.Name:SetText(normalOrMainData.raids[v].shortName)
											end

											raidHeaderFrame.Progress1:SetText(wticc(miog.DIFFICULTY[a].shortName .. ":" .. currentTable.difficulties[a].parsedString, miog.DIFFICULTY[a].color))

											if(currentTable.difficulties[a-1]) then
												raidHeaderFrame.Progress2:SetText(wticc(miog.DIFFICULTY[a-1].shortName .. ":" .. currentTable.difficulties[a-1].parsedString, miog.DIFFICULTY[a-1].color))
											end

											raidHeaderFrame.Icon:SetScript("OnMouseDown", function()
												local instanceID = C_EncounterJournal.GetInstanceForGameMap(v)
												local difficulty = a == 1 and 14 or a == 2 and 15 or 16
												--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
												EncounterJournal_OpenJournal(difficulty, instanceID, nil, nil, nil, nil)
						
											end)

											raidMapIDSet[v] = true
										end
									end
								end
							end
						end
					end
				end
			end

			raidCounter = raidCounter + 1
		end
	end

	return mplusData, raidData
end

local function fillRaidPanelWithData(profile, mainPanel, raidPanel, mainRaidPanel)
	local currentTierFrame
	local slotsFilled = {}
	local mainProgressText = ""

	local currentData, nonCurrentData, orderedData, mainData = getRaidSortData(profile.name .. (profile.realm and "-" .. profile.realm or ""))
	local hasMainData = mainData[1].parsedString ~= "0/0"

	if(hasMainData) then
		mainProgressText = mainData[1].shortName .. ": " .. wticc(miog.DIFFICULTY[mainData[1].difficulty].shortName .. ":" .. mainData[1].progress .. "/" .. mainData[1].bossCount, miog.DIFFICULTY[mainData[1].difficulty].color)

		--[[
		
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
		
		]]
	end

	if(mainPanel.RaiderIOInformationPanel) then
		mainPanel.RaiderIOInformationPanel.raid = {}
		if(mainProgressText ~= "") then
			mainPanel.RaiderIOInformationPanel.raid.main = wticc("Main: ", miog.ITEM_QUALITY_COLORS[7].pureHex) .. mainProgressText

		else
			mainPanel.RaiderIOInformationPanel.raid.main = wticc("On his main char", miog.ITEM_QUALITY_COLORS[7].pureHex)

		end
	end

	for n = 1, 2 + (mainRaidPanel and hasMainData and 1 or 0), 1 do
		local raidData = n == 1 and currentData or n == 2 and nonCurrentData or n == 3 and mainData

		if(n == 3) then
			raidPanel = mainRaidPanel
		end

		if(raidData) then
			for a, b in ipairs(raidData) do
				local slot = b.ordinal == 4 and 1 or b.ordinal == 5 and 2 or b.ordinal == 6 and 3 or b.ordinal

				if(slot and slotsFilled[slot] == nil) then
					slotsFilled[slot] = true

					local panelProgressString = ""
					local raidProgress = profile.raidProfile.raidProgress[b.raidProgressIndex]
					local mapId

					if(string.find(raidProgress.raid.mapId, 10000)) then
						mapId = tonumber(strsub(raidProgress.raid.mapId, strlen(raidProgress.raid.mapId) - 3))

					else
						mapId = raidProgress.raid.mapId

					end

					local instanceID = C_EncounterJournal.GetInstanceForGameMap(mapId)

					currentTierFrame = raidPanel[slot == 1 and "HighestTier" or slot == 2 and "MiddleTier" or slot == 3 and "LowestTier"]
					currentTierFrame:Show()
					currentTierFrame.Icon:SetTexture(miog.MAP_INFO[mapId].icon)
					currentTierFrame.Icon:SetScript("OnMouseDown", function()
						local difficulty = b.difficulty == 1 and 14 or b.difficulty == 2 and 15 or 16
						--difficultyID, instanceID, encounterID, sectionID, creatureID, itemID
						EncounterJournal_OpenJournal(difficulty, instanceID, nil, nil, nil, nil)

					end)

					currentTierFrame.Name:SetText(raidProgress.raid.shortName .. ":")

					local setLowestBorder = {}

					for x, y in ipairs(raidProgress.progress) do
						if(y.difficulty == b.difficulty and y.obsolete == false) then
							panelProgressString = wticc(miog.DIFFICULTY[y.difficulty].shortName .. ":" .. y.kills .. "/" .. raidProgress.raid.bossCount, miog.DIFFICULTY[y.difficulty].color) .. " " .. panelProgressString

							for i = 1, 12, 1 do
								local bossInfo = y.progress[i]
								local currentBoss = currentTierFrame.BossFrames[i < 7 and "UpperRow" or "LowerRow"][tostring(i)]

								if(bossInfo) then
									currentBoss.Index:SetText(i)
									
									if(bossInfo.killed) then
										currentBoss.Border:SetColorTexture(miog.DIFFICULTY[bossInfo.difficulty].miogColors:GetRGBA())
										currentBoss.Icon:SetDesaturated(false)

									end

									if(not setLowestBorder[i]) then
										if(not bossInfo.killed) then
											currentBoss.Border:SetColorTexture(0,0,0,0)
											currentBoss.Icon:SetDesaturated(not bossInfo.killed)

										end

										setLowestBorder[i] = true
									end

									currentBoss.Icon:SetTexture(miog.MAP_INFO[mapId].bosses[i].icon)
									currentBoss.Icon:SetScript("OnMouseDown", function()
										local difficulty = bossInfo.difficulty == 1 and 14 or bossInfo.difficulty == 2 and 15 or 16
										EncounterJournal_OpenJournal(difficulty, instanceID, select(3, EJ_GetEncounterInfoByIndex(i, instanceID)), nil, nil, nil)
									end)

									currentBoss:Show()

								else
									currentBoss:Hide()

								end
							end
						end
					end
					
					currentTierFrame.Progress:SetText(panelProgressString)
				end
			end

		end
	end
end

miog.fillRaidPanelWithData = fillRaidPanelWithData

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
	local entryInfo = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo() or miog.F.ACTIVE_ENTRY_INFO
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID or entryInfo.activityID)

	--miog.ApplicationViewer.ButtonPanel.sortByCategoryButtons.secondary:Enable()

	if(activityInfo.categoryID == 2) then --Dungeons
		miog.F.CURRENT_DUNGEON_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_DUNGEON_DIFFICULTY

	elseif(activityInfo.categoryID == 3) then --Raids
		miog.F.CURRENT_RAID_DIFFICULTY = miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName] and miog.DIFFICULTY_NAMES_TO_ID[activityInfo.categoryID][activityInfo.shortName][1] or miog.F.CURRENT_RAID_DIFFICULTY
	end

	miog.ApplicationViewer.InfoPanel.Background:SetTexture(miog.ACTIVITY_INFO[entryInfo.activityID].horizontal or miog.ACTIVITY_BACKGROUNDS[activityInfo.categoryID])

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