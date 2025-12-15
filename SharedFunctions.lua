local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.ONCE = true

miog.getRaiderIOProfile = function(playerName, realm, region)
	if(RaiderIO) then
		return RaiderIO.GetProfile(playerName, realm or GetNormalizedRealmName(), region or miog.F.CURRENT_REGION)

	end
end

miog.updateCurrencies = function()
	local currentSeason = miog.C.BACKUP_SEASON_ID or C_MythicPlus.GetCurrentSeason()

	if(currentSeason > -1) then
		local currencyTable = miog.CURRENCY_INFO[currentSeason]

		if(currencyTable) then
			local numOfCurrencies = #currencyTable
			
			for k, v in ipairs(currencyTable) do
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(v.id)

				local currentFrame = miog.pveFrame2.Currency[tostring(k)]
				local text = tostring(currencyInfo.quantity)

				if(currencyInfo.totalEarned > 0) then
					if(currencyInfo.maxQuantity > 0) then
						local leftToEarn = currencyInfo.maxQuantity - currencyInfo.totalEarned
				
						text = text .. "(" .. (leftToEarn > 0 and WrapTextInColorCode(leftToEarn, miog.CLRSCC.green) or WrapTextInColorCode(leftToEarn, miog.CLRSCC.red)) .. ")"

					end

				else
					text = text .. "/" .. currencyInfo.maxQuantity

				end

				currentFrame.Text:SetText(text)

				currentFrame.Icon:SetTexture(v.icon or currencyInfo.iconFileID)
				currentFrame.Icon:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetCurrencyByID(v.id)

					if(v.macro) then
						GameTooltip_AddBlankLineToTooltip(GameTooltip)
						GameTooltip_AddColoredLine(GameTooltip, "Click to open options.", GREEN_FONT_COLOR)

					end

					GameTooltip:Show()
				end)
				currentFrame:Show()
				
				if(v.macro) then
					currentFrame.Icon:SetScript("OnMouseDown", function(self)
						v.macro()
					
					end)

				else
					currentFrame.Icon:SetScript("OnMouseDown", nil)

				end
			end

			for i = numOfCurrencies + 1, 8, 1 do
				miog.pveFrame2.Currency[tostring(i)]:Hide()

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

miog.transformRaidData = function(originalData)
	local RAID_DEFINITIONS = {}
	local PLAYER_PROGRESS_BY_RAID = {}
	local MAIN_DATA = {
		progress = {},
		hasRenderableData = originalData.hasRenderableData or false
	}
	
	local InputValue = originalData

	-- 1. Process raidProgress to fill RAID_DEFINITIONS and PLAYER_PROGRESS_BY_RAID
	for _, raidInstance in pairs(InputValue.raidProgress) do
		local raidDef = raidInstance.raid
		local shortName = raidDef.shortName or raidDef.dungeon.shortName
		
		-- A. Fill RAID_DEFINITIONS (Static Data)
		if not RAID_DEFINITIONS[shortName] then
			RAID_DEFINITIONS[shortName] = {
				name = raidDef.name,
				shortName = shortName,
				id = raidDef.id,
				mapId = raidDef.mapId,
				bossCount = raidDef.bossCount,
				lfd_activity_ids = raidDef.dungeon.lfd_activity_ids,
			}
		end
		
		-- B. Fill PLAYER_PROGRESS_BY_RAID (Dynamic Progress)
		PLAYER_PROGRESS_BY_RAID[shortName] = PLAYER_PROGRESS_BY_RAID[shortName] or {}
		
		for _, progressEntry in pairs(raidInstance.progress) do
			local difficulty = progressEntry.difficulty
			
			-- Extract boss kills from the inner 'progress' array
			local boss_kills = {}
			for i = 1, #progressEntry.progress do
				-- Use the 'count' which represents total kills for that boss/index
				boss_kills[i] = progressEntry.progress[i].count 
			end

			PLAYER_PROGRESS_BY_RAID[shortName][difficulty] = {
				cleared = progressEntry.cleared,
				current = raidInstance.current,
				kills = progressEntry.kills,
				boss_kills = boss_kills,
			}
		end
	end

	-- 2. Process 'progress' to fill MAIN_DATA.progress (Summary Data)
	for _, summaryEntry in pairs(InputValue.progress) do
		-- Retrieve the shortName from the full 'raid' table reference
		-- We assume the 'raid' field here still contains the full nested raid info 
		local raidShortName = summaryEntry.raid.shortName
		
		table.insert(MAIN_DATA.progress, {
			raidKey = raidShortName,
			difficulty = summaryEntry.difficulty,
			progressCount = summaryEntry.progressCount,
			-- Add tier/obsolete status if needed, potentially from a lookup
		})
	end

	-- Optional: You could also process 'sortedProgress' and 'previousProgress' here 
	-- and store simplified versions if they contain unique, necessary data.
	
	return RAID_DEFINITIONS, PLAYER_PROGRESS_BY_RAID, MAIN_DATA
end


local function calculateWeightedScore(difficulty, kills, bossCount, isCurrentSeason)
	if kills == 0 then return 0 end

	local seasonFactor = isCurrentSeason and 100 or 1 -- Increase impact of current season
	return ((difficulty * 5) * 30 + (kills / bossCount * 20)) * seasonFactor
end

miog.getParsedProgressString = function(kills, bossCount)
	return kills .. "/" .. bossCount
end

miog.calculateWeightedScore = calculateWeightedScore

miog.getRaidProgress = function(playerName, realm, region)
    local profile = miog.getRaiderIOProfile(playerName, realm, region)
    if not (profile and profile.raidProfile) then return end

    local WeightedDifficulties = {}
    local InputValue = profile.raidProfile
    
    -- 1. Go through the array of raids (InputValue.raidProgress)
    for _, raidInstance in pairs(InputValue.raidProgress) do
		if(not raidInstance.isMainProgress) then
			local raidName = raidInstance.raid.name
			local raidShortName = raidInstance.raid.shortName
			local bossCount = raidInstance.raid.bossCount
			
			-- 2. Go through each difficulty (raidInstance.progress)
			-- This table is numerically indexed ([1], [2], etc.) for each difficulty level
			for _, progressEntry in pairs(raidInstance.progress) do
				local difficulty = progressEntry.difficulty
				local tier = progressEntry.tier
				local kills = progressEntry.kills -- Total boss kills for this difficulty
				
				-- Filter out entries that might be empty or incomplete if necessary
				-- (Based on your request, we only filter out if the tier or kills data is missing)
				if tier ~= nil and kills ~= nil then
					
					-- 3. Get the sorting weight of each difficulty
					local weight = calculateWeightedScore(difficulty, kills, bossCount, raidInstance.current)
					
					-- Store the results in a list
					table.insert(WeightedDifficulties, {
						raidName = raidName,
						shortName = raidShortName,
						difficulty = difficulty,
						tier = tier,
						kills = kills,
						bossCount = bossCount,
						weight = weight,
						isCurrent = raidInstance.current,
					})
				end
			end
		end
    end
    
    -- Optional: Sort the final list by weight from highest to lowest
    table.sort(WeightedDifficulties, function(a, b)
        return a.weight > b.weight
    end)
    
    return WeightedDifficulties
end

miog.getAliasesFromRaidProgress = function(playerDifficultyData)
	local primary2
	local secondary2

	if(playerDifficultyData) then
		if(playerDifficultyData[1]) then
			primary2 = miog.getParsedProgressString(playerDifficultyData[1].kills, playerDifficultyData[1].bossCount)

		else
			primary2 = "0/0"

		end
		
		if(playerDifficultyData[2]) then
			secondary2 = miog.getParsedProgressString(playerDifficultyData[2].kills, playerDifficultyData[2].bossCount)

		else
			secondary2 = "0/0"

		end
	else
		primary2 = "0/0"
		secondary2 = "0/0"

	end

	return primary2, secondary2
end

miog.getWeightFromRaidProgress = function(playerDifficultyData)
	local primary
	local secondary

	if(playerDifficultyData) then
		if(playerDifficultyData[1]) then
			primary = playerDifficultyData[1].weight or 0

		else
			primary = 0

		end
		
		if(playerDifficultyData[2]) then
			secondary = playerDifficultyData[2].weight or 0

		else
			secondary = 0

		end
	else
		primary = 0

		secondary = 0

	end

	return primary, secondary
end

miog.getWeightAliasesKillsAndBossCountFromRaidProgress = function(playerDifficultyData)
	local primary, primary2, primary3
	local secondary, secondary2, secondary3

	if(playerDifficultyData) then
		if(playerDifficultyData[1]) then
			primary = playerDifficultyData[1].weight or 0
			primary2 = miog.getParsedProgressString(playerDifficultyData[1].kills, playerDifficultyData[1].bossCount)
			primary3 = {kills = playerDifficultyData[1].kills, bossCount = playerDifficultyData[1].bossCount}

		else
			primary = 0
			primary2 = 0
			primary3 = {kills = 0, bossCount = 0}

		end
		
		if(playerDifficultyData[2]) then
			secondary = playerDifficultyData[2].weight or 0
			secondary2 = miog.getParsedProgressString(playerDifficultyData[2].kills, playerDifficultyData[2].bossCount)
			secondary3 = {kills = playerDifficultyData[2].kills, bossCount = playerDifficultyData[2].bossCount}

		else
			secondary = 0
			secondary2 = 0
			secondary3 = {kills = 0, bossCount = 0}

		end
	else
		primary = 0
		primary2 = 0
		primary3 = {kills = 0, bossCount = 0}

		secondary = 0
		secondary2 = 0
		secondary3 = {kills = 0, bossCount = 0}

	end

	return primary, secondary, primary2, secondary2, primary3, secondary3
end

miog.getWeightAndAliasesFromRaidProgress = function(playerDifficultyData)
	local primary, primary2
	local secondary, secondary2

	if(playerDifficultyData) then
		if(playerDifficultyData[1]) then
			primary = playerDifficultyData[1].weight or 0
			primary2 = miog.getParsedProgressString(playerDifficultyData[1].kills, playerDifficultyData[1].bossCount)

		else
			primary = 0
			primary2 = 0

		end
		
		if(playerDifficultyData[2]) then
			secondary = playerDifficultyData[2].weight or 0
			secondary2 = miog.getParsedProgressString(playerDifficultyData[2].kills, playerDifficultyData[2].bossCount)

		else
			secondary = 0
			secondary2 = 0

		end
	else
		primary = 0
		primary2 = 0

		secondary = 0
		secondary2 = 0

	end

	return primary, secondary, primary2, secondary2
end

miog.getWeightAliasesAndDifficultyFromRaidProgress = function(playerDifficultyData)
	local primary, primary2, primary3
	local secondary, secondary2, secondary3

	if(playerDifficultyData) then
		if(playerDifficultyData[1]) then
			primary = playerDifficultyData[1].weight or 0
			primary2 = miog.getParsedProgressString(playerDifficultyData[1].kills, playerDifficultyData[1].bossCount)
			primary3 = playerDifficultyData[1].difficulty

		else
			primary = 0
			primary2 = 0
			primary3 = 0

		end
		
		if(playerDifficultyData[2]) then
			secondary = playerDifficultyData[2].weight or 0
			secondary2 = miog.getParsedProgressString(playerDifficultyData[2].kills, playerDifficultyData[2].bossCount)
			secondary3 = playerDifficultyData[2].difficulty

		else
			secondary = 0
			secondary2 = 0
			secondary3 = 0

		end
	else
		primary = 0
		primary2 = 0
		primary3 = 0

		secondary = 0
		secondary2 = 0
		secondary3 = 0

	end

	return primary, secondary, primary2, secondary2, primary3, secondary3
end

miog.getWeightedAndSortedProgress = function(originalData)
    local FinalProgressList = {}
    local InputValue = originalData

    -- Step 1: Create a temporary dictionary for raid definitions for easy lookup
    local RaidDefinitions = {}
    for _, raidInstance in pairs(InputValue.raidProgress) do
        local raidDef = raidInstance.raid
        local shortName = raidDef.shortName or raidDef.dungeon.shortName
        
        if not RaidDefinitions[shortName] then
            RaidDefinitions[shortName] = {
                name = raidDef.name,
                shortName = shortName,
            }
        end
    end
    
    -- Step 2: Iterate through 'sortedProgress' and filter based on data richness
    for i, sortedEntry in ipairs(InputValue.sortedProgress) do
        local progressEntry = sortedEntry.progress
        
        -- Filter 1: Check if the entry is a simplified/previous version
        -- We require the entry NOT to be marked as 'isProgressPrev' 
        -- AND require it to have the detailed 'killsPerBoss' field.
        local hasKillsPerBoss = progressEntry.killsPerBoss ~= nil
        
        if hasKillsPerBoss then
            local progressCount = progressEntry.progressCount or 0
            
            -- Continue with data extraction and weighting logic:
            local raidShortName = progressEntry.raid.shortName 
            local difficulty = progressEntry.difficulty
            
            -- Determine Rarity/Recency Weight based on Tier and Obsolete status
            local TIER_WEIGHT = sortedEntry.tier or 0
            
            if sortedEntry.obsolete == true then
                TIER_WEIGHT = TIER_WEIGHT * 0.1 
            else
                TIER_WEIGHT = TIER_WEIGHT * 100 
            end

            -- Determine Progress Weight (using your formula)
            local PROGRESS_WEIGHT = (difficulty * 1000) + progressCount
            
            -- Final Weight is used for sorting the player against other players
            local FINAL_WEIGHT = TIER_WEIGHT + PROGRESS_WEIGHT
            
            -- Construct the final clean object for the list
            table.insert(FinalProgressList, {
                raidKey = raidShortName,
                raidName = RaidDefinitions[raidShortName] and RaidDefinitions[raidShortName].name or "Unknown Raid",
                difficulty = difficulty,
                progressCount = progressCount,
                isObsolete = sortedEntry.obsolete,
                isCurrent = (sortedEntry.obsolete == false and sortedEntry.isProgress == true),
                FINAL_WEIGHT = FINAL_WEIGHT,
            })
        end
        -- If the 'if' condition is false, the loop simply moves to the next iteration (Lua 5.1 equivalent of continue).
    end

    -- Step 3: Sort the list from newest/highest weight to oldest/lowest weight
    table.sort(FinalProgressList, function(a, b)
        return a.FINAL_WEIGHT > b.FINAL_WEIGHT
    end)
    
    return FinalProgressList
end

miog.getColoredAliasFromRaidProgress = function(playerDifficultyData)
	local diff1, diff2

	if(playerDifficultyData) then
		local diffData1, diffData2 = playerDifficultyData[1], playerDifficultyData[2]

		if(diffData1) then
			diff1 = wticc(miog.getParsedProgressString(diffData1.kills, diffData1.bossCount), diffData1.isCurrent and miog.DIFFICULTY[diffData1.difficulty].color or miog.DIFFICULTY[diffData1.difficulty].desaturated)

		else
			diff1 = wticc("0/0", miog.CLRSCC.red)

		end

		if(diffData2) then
			diff2 = wticc(miog.getParsedProgressString(diffData2.kills, diffData2.bossCount), diffData2.isCurrent and miog.DIFFICULTY[diffData2.difficulty].color or miog.DIFFICULTY[diffData2.difficulty].desaturated)

		else
			diff2 = wticc("0/0", miog.CLRSCC.red)

		end
	else
		diff1 = wticc("0/0", miog.CLRSCC.red)
		diff2 = wticc("0/0", miog.CLRSCC.red)

	end

	return diff1, diff2
end

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

	if(LFGListEntryCreation_IsEditMode(self)) then
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
        
        LFGListEntryCreation_SetEditMode(self, false)
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

local weightTable = {
	[1] = 2,
	[2] = 28,
	[3] = 392,
}

local function calculateRaidWeight(difficulty, kills, bossCount, isCurrentSeason)
	local factor = isCurrentSeason and 8 / bossCount or 8 / bossCount / 10

	return weightTable[difficulty] * kills * factor
end

miog.calculateRaidWeight = calculateRaidWeight

miog.retrieveCurrentSeasonDungeonActivityGroups = function()
	return C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.Recommended))
end

miog.retrieveCurrentRaidActivityGroups = function()
	return C_LFGList.GetAvailableActivityGroups(3, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.CurrentExpansion) or Enum.LFGListFilter.Recommended)
end

miog.retrieveCurrentSeasonDungeonActivityIDs = function(justIDs, sort)
	local mythicPlusActivities = {}

	for k, v in ipairs(C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.Recommended))) do
        local activities = C_LFGList.GetAvailableActivities(GROUP_FINDER_CATEGORY_ID_DUNGEONS, v)
        local activityID = activities[#activities]
		local activityInfo = miog.requestActivityInfo(activityID)

        tinsert(mythicPlusActivities, justIDs and activityID or {name = C_LFGList.GetActivityGroupInfo(v), activityID = activityID, mapID = activityInfo.mapID})
    end

	if(sort and #mythicPlusActivities > 1) then
		if(justIDs) then
			table.sort(mythicPlusActivities, function(k1, k2)
				return k1 < k2
			end)
		else
			table.sort(mythicPlusActivities, function(k1, k2)
				return k1.name < k2.name
			end)
		end
	end

	return mythicPlusActivities
end

miog.retrieveCurrentSeasonDungeonActivityIDsForMPlus = function(justIDs, sort)
	local mythicPlusActivities = {}

	if(IsPlayerAtEffectiveMaxLevel()) then
		local groups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.Recommended))

		--[[if(#groups ~= #miog.BACKUP_SEASONAL_IDS[2]) then
			groups = miog.BACKUP_SEASONAL_IDS[2]

		end]]

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(GROUP_FINDER_CATEGORY_ID_DUNGEONS, v)

			local activityID = activities[#activities]

			local activityInfo = miog.requestActivityInfo(activityID)

			tinsert(mythicPlusActivities, justIDs and activityID or {abbreviatedName = activityInfo.abbreviatedName, activityID = activityID, mapID = activityInfo.mapID})
		end

		if(sort) then
			if(justIDs) then
				table.sort(mythicPlusActivities, function(k1, k2)
					return k1 < k2
				end)
			else
				table.sort(mythicPlusActivities, function(k1, k2)
					return k1.abbreviatedName < k2.abbreviatedName
				end)
			end
		end
	end

	return mythicPlusActivities
end

miog.retrieveCurrentRaidActivityIDs = function(justIDs, sort)
	local raidActivities = {}

	if(IsPlayerAtEffectiveMaxLevel()) then
		local groups = C_LFGList.GetAvailableActivityGroups(3, Enum.LFGListFilter.CurrentExpansion)

		for k, v in ipairs(groups) do
			local activities = C_LFGList.GetAvailableActivities(3, v)
			local activityID = activities[#activities]
			local name, order = C_LFGList.GetActivityGroupInfo(v)
			local activityInfo = miog.requestActivityInfo(activityID)

			tinsert(raidActivities, justIDs and activityID or {name = name, order = order, activityID = activityID, mapID = activityInfo.mapID})
		end

		if(sort and #raidActivities > 1) then
			if(justIDs) then
				table.sort(raidActivities, function(k1, k2)
					return k1 > k2
				end)
				
			else
				table.sort(raidActivities, function(k1, k2)
					if(k1.order == k2.order) then
						return k1.activityID > k2.activityID

					end

					return k1.order < k2.order
				end)

			end
		end
	end

	return raidActivities
end

local function sortFunction(a, b)
	if(a.current == b.current) then
		return a.weight > b.weight

	end

	return a.current
end

local append = table.insert -- Localizing function for speed

local function getRaidProgressDataOnly(playerName, realm, region, existingProfile)
    local raidInfo = miog.retrieveCurrentRaidActivityIDs(false, true)
    if not raidInfo then return end

    local profile = existingProfile or miog.getRaiderIOProfile(playerName, realm, region)
    if not (profile and profile.raidProfile) then return end

    local raidData = {
        character = { ordered = {}, progressWeight = 0 },
        main = { ordered = {}, progressWeight = 0 }
    }
    local profileProgress = profile.raidProfile.raidProgress

    for i = 1, #profileProgress do
        local d = profileProgress[i]
        local currentTable = d.isMainProgress and raidData.main or raidData.character
        local d_raid = d.raid
        local mapID = tonumber(d_raid.mapId) or d_raid.mapId
        local d_bossCount, d_current = d_raid.bossCount, d.current
        local progress = d.progress

        for j = 1, #progress do
            local y = progress[j]
            local difficulty, kills = y.difficulty, y.kills
            local weight = calculateWeightedScore(y.difficulty, y.kills, d_bossCount, d_current)

            append(currentTable.ordered, {
                difficulty = difficulty,
                mapID = mapID,
                current = d_current,
                weight = weight,
                parsedString = kills .. "/" .. d_bossCount
            })
            currentTable.progressWeight = currentTable.progressWeight + weight
        end
    end

    table.sort(raidData.character.ordered, sortFunction)
    table.sort(raidData.main.ordered, sortFunction)

    local r1, r2, r3 = raidInfo[1], raidInfo[2], raidInfo[3]
    local defaultMapID1 = (r3 and r3.mapID) or (r2 and r2.mapID) or (r1 and r1.mapID) or 0
    local defaultMapID2 = (r2 and r2.mapID) or (r1 and r1.mapID) or 0

    local characterOrdered, mainOrdered = raidData.character.ordered, raidData.main.ordered

    if #characterOrdered < 1 then append(characterOrdered, { mapID = defaultMapID1, parsedString = "0/0", difficulty = -1, weight = 0}) end
    if #characterOrdered < 2 then append(characterOrdered, { mapID = defaultMapID2, parsedString = "0/0", difficulty = -1, weight = 0 }) end
    if #mainOrdered < 1 then append(mainOrdered, { parsedString = "0/0", difficulty = -1, weight = 0 }) end
    if #mainOrdered < 2 then append(mainOrdered, { parsedString = "0/0", difficulty = -1, weight = 0 }) end

    return raidData
end

miog.getRaidProgressDataOnly = getRaidProgressDataOnly

local function getOnlyPlayerRaidData(playerName, realm, region, existingProfile)
	local raidData
	local raidInfo = miog.retrieveCurrentRaidActivityIDs(false, true)

	local profile = existingProfile or miog.getRaiderIOProfile(playerName, realm, region)

	if(profile and profile.raidProfile)then
		raidData = {
			character = { raids = {}, ordered = {}, progressWeight = 0 },
		}

		local currentTable = raidData.character

		local profileProgress = profile.raidProfile.raidProgress

		for i = 1, #profileProgress, 1 do
			local d = profileProgress[i]
			if(not d.isMainProgress) then
				local mapID = d.raid.mapId % 10000
				local isAwakened = (mapID ~= d.raid.mapId) and d.current

				local raidEntry = currentTable.raids[mapID]
				if(not raidEntry) then
					raidEntry = {
						regular = { difficulties = {}},
						awakened = { difficulties = {}},
						isAwakened = isAwakened,
					}
					currentTable.raids[mapID] = raidEntry
				end

				local modeTable = isAwakened and raidEntry.awakened or raidEntry.regular

				local progress = d.progress
				for j = 1, #progress, 1 do
					local y = progress[j]
					local difficulty = y.difficulty
					local weight = calculateWeightedScore(difficulty, y.kills, d.raid.bossCount, d.current)

					local difficultyEntry = {
						difficulty = difficulty,
						current = d.current,
						weight = weight,
						parsedString = y.kills .. "/" .. d.raid.bossCount,
						--parsedString = string.format("%d/%d", y.kills, d.raid.bossCount)
					}

					modeTable.difficulties[difficulty] = difficultyEntry
					currentTable.progressWeight = currentTable.progressWeight + weight
					currentTable.ordered[#currentTable.ordered + 1] = difficultyEntry
				end
			end
		end

		local characterOrdered = raidData.character.ordered

		if #characterOrdered > 1 then table.sort(characterOrdered, sortFunction) end
	end

	if(not raidData)then
		raidData = {
			character = { ordered = {}, raids = {} },
		}
	end

	local characterOrdered = raidData.character.ordered

	local defaultMapID1 = (raidInfo[3] or raidInfo[2] or raidInfo[1]) and (raidInfo[3] or raidInfo[2] or raidInfo[1]).mapID or 0
	local defaultMapID2 = (raidInfo[2] or raidInfo[1]) and (raidInfo[2] or raidInfo[1]).mapID or 0

	characterOrdered[1] = characterOrdered[1] or { mapID = defaultMapID1, parsedString = "0/0", difficulty = -1 }
	characterOrdered[2] = characterOrdered[2] or { mapID = defaultMapID2, parsedString = "0/0", difficulty = -1 }

	return raidData
end

miog.getOnlyPlayerRaidData = getOnlyPlayerRaidData

local function getNewRaidSortData(playerName, realm, region, existingProfile)
	local raidData
	local raidInfo = miog.retrieveCurrentRaidActivityIDs(false, true)

	local profile = existingProfile or miog.getRaiderIOProfile(playerName, realm, region)

	if(profile and profile.raidProfile)then
		raidData = {
			character = { raids = {}, ordered = {}, progressWeight = 0 },
			main = { raids = {}, ordered = {}, progressWeight = 0 }
		}

		local profileProgress = profile.raidProfile.raidProgress

		for i = 1, #profileProgress, 1 do
			local d = profileProgress[i]
			local currentTable = d.isMainProgress and raidData.main or raidData.character
			local mapID = tonumber(string.sub(d.raid.mapId, -4)) or d.raid.mapId
			local isAwakened = (mapID ~= d.raid.mapId) and d.current

			local raidEntry = currentTable.raids[mapID]
			if(not raidEntry) then
				raidEntry = {
					regular = { difficulties = {}},
					awakened = { difficulties = {}},
					bossCount = d.raid.bossCount,
					isAwakened = isAwakened,
					shortName = d.raid.shortName
				}
				currentTable.raids[mapID] = raidEntry
			end

			local modeTable = isAwakened and raidEntry.awakened or raidEntry.regular

			local progress = d.progress
			for j = 1, #progress, 1 do
				local y = progress[j]
				local difficulty = y.difficulty
				local weight = calculateWeightedScore(difficulty, y.kills, d.raid.bossCount, d.current)

				local difficultyEntry = {
					difficulty = difficulty,
					current = d.current,
					kills = y.kills,
					cleared = y.cleared,
					mapID = mapID,
					shortName = raidEntry.shortName,
					weight = weight,
					parsedString = y.kills .. "/" .. d.raid.bossCount,
					bosses = {}
				}

				local bossProgress = y.progress
				for a = 1, #bossProgress, 1 do
					local b = bossProgress[a]
					difficultyEntry.bosses[a] = { killed = b.killed, count = b.count }
				end

				modeTable.difficulties[difficulty] = difficultyEntry
				currentTable.progressWeight = currentTable.progressWeight + weight
				currentTable.ordered[#currentTable.ordered + 1] = difficultyEntry
			end
		end

		local characterOrdered = raidData.character.ordered
		local mainOrdered = raidData.main.ordered

		if #characterOrdered > 1 then table.sort(characterOrdered, sortFunction) end
		if #mainOrdered > 1 then table.sort(mainOrdered, sortFunction) end
	end

	if(not raidData)then
		raidData = {
			character = { ordered = {}, raids = {} },
			main = { ordered = {}, raids = {} }
		}
	end

	local characterOrdered = raidData.character.ordered
	local mainOrdered = raidData.main.ordered

	local defaultMapID1 = (raidInfo[3] or raidInfo[2] or raidInfo[1]) and (raidInfo[3] or raidInfo[2] or raidInfo[1]).mapID or 0
	local defaultMapID2 = (raidInfo[2] or raidInfo[1]) and (raidInfo[2] or raidInfo[1]).mapID or 0

	characterOrdered[1] = characterOrdered[1] or { mapID = defaultMapID1, parsedString = "0/0", difficulty = -1 }
	characterOrdered[2] = characterOrdered[2] or { mapID = defaultMapID2, parsedString = "0/0", difficulty = -1 }
	mainOrdered[1] = mainOrdered[1] or { parsedString = "0/0", difficulty = -1 }
	mainOrdered[2] = mainOrdered[2] or { parsedString = "0/0", difficulty = -1 }

	return raidData
end

miog.getNewRaidSortData = getNewRaidSortData

local function getMPlusScoreOnly(playerName, realm, region, existingProfile)
	local profile = existingProfile or miog.getRaiderIOProfile(playerName, realm, region)

	if(profile and profile.mythicKeystoneProfile) then
		return profile.mythicKeystoneProfile.mplusCurrent.score

	end

	return 0
end
miog.getMPlusScoreOnly = getMPlusScoreOnly

miog.checkAllSeasonalMapIDs = function()
    local mythicPlusInfo = miog.retrieveCurrentSeasonDungeonActivityIDs(false, true)

	for k, v in ipairs(mythicPlusInfo) do
		--miog.checkForMapAchievements(v.mapID)

	end
    
    local raidInfo = miog.retrieveCurrentRaidActivityIDs(false, true)

	for k, v in ipairs(raidInfo) do
		--miog.checkForMapAchievements(v.mapID)

	end
end

miog.retrieveAndSortChallengeModeMapTable = function()
	local mapTable = C_ChallengeMode.GetMapTable()

	table.sort(mapTable, function(k1, k2)
		return miog.retrieveAbbreviatedNameFromChallengeModeMap(k1) < miog.retrieveAbbreviatedNameFromChallengeModeMap(k2)

	end)

	return mapTable
end

local function getMPlusSortData(playerName, realm, region, returnAsBlizzardTable, existingProfile)
	local profile = existingProfile or miog.getRaiderIOProfile(playerName, realm, region)

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
							durationSec = dungeonEntry.dungeon.timers[dungeonEntry.chests == 0 and 3 or dungeonEntry.chests == 1 and 2 or 1] + (dungeonEntry.chests < 3 and 1 or -1),
							level = dungeonEntry.level,
						}
						
						--table[dungeonEntry.dungeon.keystone_instance].dungeonScore = miog.calculateMapScore(dungeonEntry.dungeon.keystone_instance, table[dungeonEntry.dungeon.keystone_instance])

					else
						mplusData[dungeonEntry.dungeon.keystone_instance] = {
							level = profile.mythicKeystoneProfile.dungeons[dungeonEntry.dungeon.index],
							chests = profile.mythicKeystoneProfile.dungeonUpgrades[dungeonEntry.dungeon.index]
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

			else
				mplusData.score = profile.mythicKeystoneProfile.mplusCurrent

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


local function getMPlusAndRaidData(playerName, realm, region)
	local profile = miog.getRaiderIOProfile(playerName, realm, region)

	return getMPlusSortData(playerName, realm, region, nil, profile), getNewRaidSortData(playerName, realm, region, profile)
end
miog.getMPlusAndRaidData = getMPlusAndRaidData


local function getMPlusScoreAndRaidData(playerName, realm, region)
	local profile = miog.getRaiderIOProfile(playerName, realm, region)

	return getMPlusScoreOnly(playerName, realm, region, profile), getNewRaidSortData(playerName, realm, region, profile)
end
miog.getMPlusScoreAndRaidData = getMPlusScoreAndRaidData


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
	--return true
	return C_AddOns.IsAddOnLoaded("MythicIO - Resources")
end

miog.refreshLastGroupTeleport = function(mapID)
	local mapInfo = miog.MAP_INFO[mapID or MIOG_CharacterSettings.lastGroupMap]

	local lastGroupTeleportButton = miog.MainTab.QueueInformation.LastGroup.TeleportButton

	if(mapInfo and mapInfo.teleport and C_Spell.IsSpellUsable(mapInfo.teleport) and C_SpellBook.IsSpellInSpellBook(mapInfo.teleport)) then
		local spellInfo = C_Spell.GetSpellInfo(mapInfo.teleport)
		local desc = C_Spell.GetSpellDescription(mapInfo.teleport)

		--lastGroupTeleportButton.Text:SetText(mapInfo.abbreviatedName or WrapTextInColorCode("MISSING", "FFFF0000"))
		lastGroupTeleportButton:SetNormalTexture(spellInfo.iconID)
		lastGroupTeleportButton:SetHighlightAtlas("communities-create-avatar-border-hover")
		lastGroupTeleportButton:SetAttribute("type", "spell")
		lastGroupTeleportButton:SetAttribute("spell", spellInfo.name)
		lastGroupTeleportButton:RegisterForClicks("LeftButtonDown")
		lastGroupTeleportButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip_AddHighlightLine(GameTooltip, spellInfo.name)
			GameTooltip:AddLine(desc)
			GameTooltip:Show()
		end)
		
        local spellCooldownInfo = C_Spell.GetSpellCooldown(mapInfo.teleport)
        lastGroupTeleportButton.Cooldown:SetCooldown(spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.modRate)
		lastGroupTeleportButton:Show()
	else
		lastGroupTeleportButton:Hide()

	end
end

miog.setInfoIndicators = function(frameWithDoubleIndicators, categoryID, dungeonScore, dungeonData, raidData, pvpData)
	local primaryIndicator, secondaryIndicator = frameWithDoubleIndicators.Primary, frameWithDoubleIndicators.Secondary

	if(categoryID == 3) then
		if(raidData) then
			local orderedData1 = raidData.character.ordered[1]
			local orderedData2 = raidData.character.ordered[2]

			if(orderedData1) then
				primaryIndicator:SetText(wticc(orderedData1.parsedString, orderedData1.current and miog.DIFFICULTY[orderedData1.difficulty].color or miog.DIFFICULTY[orderedData1.difficulty].desaturated))

			end

			if(orderedData2) then
				secondaryIndicator:SetText(wticc(orderedData2.parsedString, orderedData2.current and miog.DIFFICULTY[orderedData2.difficulty].color or miog.DIFFICULTY[orderedData2.difficulty].desaturated))

			end

			return
		end
	else
		if(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
			if(pvpData.tier and pvpData.tier ~= "N/A") then
				local tierResult = miog.simpleSplit(PVPUtil.GetTierName(pvpData.tier), " ")
				primaryIndicator:SetText(wticc(tostring(pvpData.rating), miog.createCustomColorForRating(pvpData.rating):GenerateHexColor()))
				secondaryIndicator:SetText(strsub(tierResult[1], 0, tierResult[2] and 2 or 4) .. ((tierResult[2] and "" .. tierResult[2]) or ""))

			else
				primaryIndicator:SetText(0)
				secondaryIndicator:SetText("Unra")
			
			end

			return
		else
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

				return
			end
		end
	end
	
	local zeroText = wticc("0", miog.DIFFICULTY[-1].color)
	primaryIndicator:SetText(zeroText)
	secondaryIndicator:SetText(zeroText)
end

local function getRaidSortData(playerName)
	local profile

	miog.getRaiderIOProfile(playerName)

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
								weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current)
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
								weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current)
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
							weight = calculateWeightedScore(y.difficulty, y.kills, d.raid.bossCount, d.current)
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

		if(searchResultInfo.leaderName) then
			--local activityInfo = miog.requestActivityInfo(searchResultInfo.activityIDs[1])
			playerName, realm = miog.createSplitName(searchResultInfo.leaderName)
		end
		
		comment = searchResultInfo.comment
		activityID = searchResultInfo.activityIDs[1]

	elseif(data.applicantID) then
		local applicantData = C_LFGList.GetApplicantInfo(data.applicantID)
		playerName, realm = data.name, data.realm
		comment = applicantData and applicantData.comment or ""
		activityID = C_LFGList.HasActiveEntryInfo() and C_LFGList.GetActiveEntryInfo().activityIDs[1] or 0

	end
	
	frame:Flush()
	frame:SetPlayerData(playerName, realm)
	frame:SetOptionalData(comment, realm)
	frame:ApplyFillData(true)

	local activityInfo = miog.requestActivityInfo(activityID)

	if(activityInfo) then
		frame.Background:SetTexture(activityInfo.horizontal, "CLAMP", "MIRROR")
		frame.Background:SetVertexColor(0.75, 0.75, 0.75, 0.4)
	end
end

miog.hideSidePanel = function(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	self:GetParent():Hide()

	local buttonPanel = self:GetParent():GetParent().ButtonPanel
	buttonPanel:Show()

	MIOG_NewSettings.activeSidePanel = "none"
end

local function isUnitID(str)
    str = string.lower(str)

    if(string.find(str, "raid") or string.find(str, "party") or string.find(str, "player") or string.find(str, "target")) then
        return true

    end

    return false
end

local function createFullNameValuesFrom(type, value)
	if(not value) then
		return
		
	end

	if(not type) then
		type = isUnitID(value) and "unitID" or "unitName"

	end

	local fullName, shortName, realm

	local localRealm = GetNormalizedRealmName() or ""

	if(type == "unitName") then
		if(string.find(value, "-")) then
			fullName = value

			local nameTable = miog.simpleSplit(fullName, "-")
			shortName = nameTable[1]
			realm = nameTable[2]

		else
			shortName = value
			realm = localRealm
			fullName = value .. "-" .. localRealm

		end

	else
		if(value ~= "player") then
			local nameNoMod, realmNoMod = UnitNameUnmodified(value)

			if(nameNoMod) then

				shortName = nameNoMod

				if(realmNoMod) then
					realm = realmNoMod
					fullName = nameNoMod .. "-" .. realmNoMod

				else
					realm = localRealm
					fullName = nameNoMod .. "-" .. localRealm

				end
			end
		else
			shortName = UnitName("player")
			realm = localRealm
			fullName = shortName .. "-" .. localRealm

		end
	end

	return fullName, shortName, realm
end

miog.createFullNameValuesFrom = createFullNameValuesFrom

local function createFullNameFrom(type, value)
	local realm = GetNormalizedRealmName()
	local name

	if(not realm) then
		if(type == "unitName" and string.find(value, "-")) then
			return value
		end

		return
	end

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
		local nameTable = miog.simpleSplit(value, "-")

		if(nameTable[2]) then
			return value

		else
			name = nameTable[1] .. "-" .. realm

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

local function findScrollBoxFrame(scrollBox, checkFunc)
	local frame = scrollBox:FindFrameByPredicate(checkFunc())

	return frame
end

local function printOnce(string)
	if(miog.ONCE) then
		miog.ONCE = false

		print(string)

	end
end

miog.printOnce = printOnce

miog.changeTheme = function(index)
	local titleBarTexHeight = 0.0465
	local titleBarSeparatorHeight = 0.02
	local mainFrameStart = titleBarTexHeight + titleBarSeparatorHeight
	local scrollbarWidth = 1 - 0.03125
	local currencyHeight = 1 - 0.03125

	local value = index or MIOG_NewSettings.backgroundOptions
	
	miog.MainFrame.TitleBar.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. ".png")
	miog.MainFrame.TitleBar.Background:SetTexCoord(0, scrollbarWidth, 0, titleBarTexHeight)
	
	miog.MainFrame.TitleBarSeparator.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. ".png")
	miog.MainFrame.TitleBarSeparator.Background:SetTexCoord(0, scrollbarWidth, titleBarTexHeight, mainFrameStart)
	
	miog.MainFrame.ScrollBarArea.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. ".png")
	miog.MainFrame.ScrollBarArea.Background:SetTexCoord(scrollbarWidth, 1, mainFrameStart, currencyHeight)
	
	miog.MainFrame.TabFramesPanel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. ".png")
	miog.MainFrame.TabFramesPanel.Background:SetTexCoord(0, scrollbarWidth, mainFrameStart, currencyHeight)
	
	miog.MainFrame.Currency.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. ".png")
	miog.MainFrame.Currency.Background:SetTexCoord(0, 1, currencyHeight, 1)
	
	miog.FilterManager.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. "_small.png")

	miog.C.CURRENT_THEME = miog.COLOR_THEMES.standard
end

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
	local currentPanel = LFGListFrame.activePanel:GetDebugName()
	local categoryID = currentPanel == "LFGListFrame.SearchPanel" and LFGListFrame.SearchPanel.categoryID
	or currentPanel == "LFGListFrame.ApplicationViewer" and C_LFGList.HasActiveEntryInfo() and miog.requestActivityInfo(C_LFGList.GetActiveEntryInfo().activityIDs[1]).categoryID or
	LFGListFrame.CategorySelection.selectedCategory



	return categoryID, currentPanel
end

miog.createSplitName = function(name)
	local nameTable = miog.simpleSplit(name, "-")
	local wasFullName = true

	if(not nameTable[2]) then
		nameTable[2] = GetNormalizedRealmName()
		wasFullName = false

	end

	return nameTable[1], nameTable[2], wasFullName
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
	local fullName = createFullNameFrom("unitName", name)
	
	if(fullName == "Rhany-Ravencrest" or fullName == "Gerhanya-Ravencrest" or fullName == "Latimeria-Ravencrest") then
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

	if(entryInfo) then
		local activityInfo = miog.requestActivityInfo(entryInfo.activityIDs[1])
		miog.ApplicationViewer.InfoPanel.Background:SetTexture(activityInfo.horizontal or miog.ACTIVITY_BACKGROUNDS[activityInfo.categoryID])

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

		miog.ApplicationViewer.CreationSettings.VoiceChatButton:SetChecked(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked())

		desaturateTexture(LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked(), miog.ApplicationViewer.CreationSettings.VoiceChatButton:GetNormalTexture())
		desaturateTexture(entryInfo.privateGroup, miog.ApplicationViewer.CreationSettings.PrivateGroupButton:GetNormalTexture())
		desaturateTexture(entryInfo.autoAccept, miog.ApplicationViewer.CreationSettings.AutoAcceptButton:GetNormalTexture())

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