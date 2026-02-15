local addonName, miog = ...

QueueManagerMixin = {}

function QueueManagerMixin:UpdateFakeApplications()


end

function QueueManagerMixin:UpdateListing()
	local isActive = C_LFGList.HasActiveEntryInfo()

	if (isActive) then
		self.dataProvider:Insert({
			template = "MIOG_QueueManagerListingFrameTemplate",
		})
	end
end

function QueueManagerMixin:UpdatePVEQueues()
    for categoryID = 1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(categoryID)

		if(mode and submode ~= "noteleport") then
			local queuedList = GetLFGQueuedList(categoryID, queuedList) or {}
			
			local length = 0

			for _ in pairs(queuedList) do
				length = length + 1

			end
		
			local activeID = select(18, GetLFGQueueStats(categoryID))
			local isRF = categoryID == LE_LFG_CATEGORY_RF

			for queueID, queued in pairs(queuedList) do
				local isCurrentlyActive = activeID == queueID
				
				if(isCurrentlyActive or isRF) then
					self.dataProvider:Insert({
						template = "MIOG_QueueManagerLFGFrameTemplate",
						categoryID = categoryID,
						queueID = queueID,
						isMultiDungeon = categoryID == LE_LFG_CATEGORY_LFD and length > 1 or false,
						isRaidFinder = isRF
					})
				end
			end
		end
	end
end

function QueueManagerMixin:UpdateGroupApplications()
	local applications = C_LFGList.GetApplications()

	if(applications and #applications > 0) then
		for _, v in ipairs(applications) do
			local resultID, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(v)

			if(resultID and appStatus == "applied") then
				self.dataProvider:Insert({
					template = "MIOG_QueueManagerApplicationFrameTemplate",
					resultID = resultID,
				})

			end
		end
	end
end



function QueueManagerMixin:UpdatePVPQueues()
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend, queueType, gameType, role, asGroup, shortDescription, longDescription, isSoloQueue = GetBattlefieldStatus(i);

		if(status and status ~= "none" and status ~= "error") then
			self.dataProvider:Insert({
				template = "MIOG_QueueManagerFramePVPTemplate",
				index = i,
				type = "battlefield"
			})
		end
	end
end

function QueueManagerMixin:UpdateWorldPVPQueues()
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID, expireTime, averageWaitTime, queuedTime, suspended = GetWorldPVPQueueStatus(i)

		if(status and status ~= "none") then
			self.dataProvider:Insert({
				template = "MIOG_QueueManagerFramePVPTemplate",
				index = i,
				type = "world"
			})
		end
	end

	if(CanHearthAndResurrectFromArea()) then
		self.dataProvider:Insert({
			template = "MIOG_QueueManagerFramePVPTemplate",
			type = "openworld"
		})

	end
end

function QueueManagerMixin:UpdatePetBattleQueue()
	if(C_PetBattles.GetPVPMatchmakingInfo()) then
		self.dataProvider:Insert({
			template = "MIOG_QueueManagerFramePVPTemplate",
			type = "petbattle",
		})

	end
end

function QueueManagerMixin:UpdatePlunderstormQueue()
	if(C_LobbyMatchmakerInfo.IsInQueue()) then
		self.dataProvider:Insert({
			template = "MIOG_QueueManagerFramePVPTemplate",
			type = "plunderstorm",
		})

	end
end

function QueueManagerMixin:CheckQueues()
    self.dataProvider:Flush()

    self:UpdateFakeApplications()
    self:UpdatePVEQueues()
	self:UpdateListing()
	self:UpdateGroupApplications()
	self:UpdatePVPQueues()
	self:UpdateWorldPVPQueues()
	self:UpdatePetBattleQueue()
	self:UpdatePlunderstormQueue()

	self.Title:SetShown(self.dataProvider:GetSize() < 1)
end

function QueueManagerMixin:OnEvent(event, ...)
	self:CheckQueues()

end

--QueueStatusFrame events for queues
function QueueManagerMixin:RegisterNecessaryEvents()
	--For Plunderstorm 
	self:RegisterEvent("LOBBY_MATCHMAKER_QUEUE_STATUS_UPDATE");
	self:RegisterEvent("LOBBY_MATCHMAKER_QUEUE_ABANDONED");
	self:RegisterEvent("LOBBY_MATCHMAKER_QUEUE_POPPED");
	self:RegisterEvent("LOBBY_MATCHMAKER_QUEUE_EXPIRED");
	self:RegisterEvent("LOBBY_MATCHMAKER_QUEUE_ERROR");

	--For LFG
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("LFG_ROLE_CHECK_UPDATE");
	self:RegisterEvent("LFG_READY_CHECK_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_FAILED");
	self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
	self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");

	--For LFGList
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
	self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED");

	--For PvP
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PVP_BRAWL_INFO_UPDATED");

	--For World PvP stuff
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED");

	--For Pet Battles
	self:RegisterEvent("PET_BATTLE_QUEUE_STATUS");
end

function QueueManagerMixin:OnLoad()
    self.dataProvider = CreateDataProvider()
    local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 3)

	local function Initializer(frame, data)
		frame.queueID = data.queueID
		frame.categoryID = data.categoryID
		frame.isMultiDungeon = data.isMultiDungeon
		frame.index = data.index

		local backgroundImage, activityName, macrotext, timeInQueue, timeToMatch

		if(data.template == "MIOG_QueueManagerLFGFrameTemplate") then
			local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, fileID, difficulty, maxPlayers, description, isHoliday, bonusRep, minPlayersDisband, isTimewalker, name2, minGearLevel, isScalingDungeon, mapID = GetLFGDungeonInfo(data.queueID)
			local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(data.categoryID, data.queueID)

			backgroundImage = miog:GetImageForMapID(mapID) or fileID

			activityName = data.isMultiDungeon and MULTIPLE_DUNGEONS or name
			macrotext = "/run LeaveSingleLFG(" .. data.categoryID .. "," .. data.queueID .. ")"
			
			if(hasData) then
				timeInQueue = queuedTime and GetTime() - queuedTime or 0
				frame:SetTimerInfo("add", timeInQueue)

				timeToMatch = myWait and myWait > -1 and myWait or averageWait and averageWait > -1 and averageWait or -1
				frame:SetWaitInfo(timeToMatch)

				local totalNumOfPlayers = maxPlayers - tankNeeds - healerNeeds - dpsNeeds

				if(totalNumOfPlayers > 1) then
					frame.Name:SetTextColor(1, 1, 0, 1)
					activityName = "(" .. (totalNumOfPlayers / maxPlayers * 100) .. "%) " .. activityName

				end
			end
		elseif(data.template == "MIOG_QueueManagerListingFrameTemplate") then
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
			local numApplicants, numActiveApplicants = C_LFGList.GetNumApplicants()
			local activityInfo = miog:GetActivityInfo(activeEntryInfo.activityIDs[1])

			if(activityInfo) then
				local unitName, unitID = miog:GetGroupLeader()

				macrotext = "/run C_LFGList.RemoveListing()"
				backgroundImage = activityInfo.horizontal or activityInfo.groupFinderActivityGroupID == 0 and miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dungeon.png"

				frame.CancelApplication:SetShown(UnitIsGroupLeader("player"))

				frame:SetTimerInfo("sub", activeEntryInfo.duration)

				activityName = (unitID == "player" and "Your Listing" or ((unitName or "Unknown") .. "'s Listing")) .. " (" .. numApplicants .. ")"
				
			end

			frame.Wait:Hide()

		elseif(data.template == "MIOG_QueueManagerApplicationFrameTemplate") then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(data.resultID)

			if(isFakeApp) then
				frame:SetAlpha(0.5)
				macrotext = "idkwhatilldoherebutillfigureitout"
				timeInQueue = searchResultInfo.age

				frame:SetTimerInfo("add", timeInQueue)

			else
				macrotext = "/run C_LFGList.CancelApplication(" .. data.resultID .. ")"

				local resultID, appStatus, pendingStatus, appDuration, appRole = C_LFGList.GetApplicationInfo(data.resultID)
				timeInQueue = appDuration
				
				frame:SetTimerInfo("sub", timeInQueue)

			end

			local activityInfo = miog:GetActivityInfo(searchResultInfo.activityIDs[1])

			activityName = searchResultInfo.name .. " - " .. (WrapTextInColorCode(activityInfo.fullName or "", CreateColor(1, 0.82, 0):GenerateHexColor()))
			backgroundImage = activityInfo.horizontal

			frame.categoryID = activityInfo.categoryID

			local eligible, reasonID = miog.filter.checkIfSearchResultIsEligible(data.resultID, true)
			local reason = miog.INELIGIBILITY_REASONS[reasonID]

			if(eligible == false) then
				frame.Name:SetTextColor(1, 0, 0, 1)

				if(reason) then
					frame.Name:SetText(frame.Name:GetText() .. " - " .. reason[2])
					
				end
			end

			frame:SetScript("OnEnter", function(self)
				miog.createResultTooltip(data.resultID, self)

			end)

			frame.Wait:Hide()
			
		elseif(data.template == "MIOG_QueueManagerFramePVPTemplate") then
			local status, mapName

			if(data.type == "battlefield") then
				status, mapName = GetBattlefieldStatus(data.index);
				macrotext = "/click QueueStatusButton RightButton"
				frame.type = "battlefield"

				if(status and status ~= "none" and status ~= "error") then
					timeInQueue = GetBattlefieldTimeWaited(data.index) / 1000
					timeToMatch = GetBattlefieldEstimatedWaitTime(data.index) / 1000

					local mapIDTable = miog.findBattlegroundMapIDsByName(mapName) or miog.findBrawlMapIDsByName(mapName)

					if(isHQ) then
						if(mapName == "Random Epic Battleground") then
							backgroundImage = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/epicbgs.png"

						elseif(mapName == "Random Battleground") then
							backgroundImage = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/normalbgs.png"

						end
						
					end

					if(not backgroundImage) then
						local numOfEntries = mapIDTable and #mapIDTable or 0
						
						if(numOfEntries > 0) then
							if(numOfEntries == 1) then
								backgroundImage = miog.MAP_INFO[mapIDTable[1]].horizontal
								
							elseif(numOfEntries > 1) then
								local counter = 0
								local randomNumber = random(1, numOfEntries)

								for k, v in pairs(mapIDTable) do
									counter = counter + 1

									if(counter == randomNumber) then
										backgroundImage = miog.MAP_INFO[v] and miog.MAP_INFO[v].horizontal
										break
									end
								end
							end
						end
					end

					backgroundImage = backgroundImage or miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/pvpbattleground.png"
				end

			elseif(data.type == "world") then
				local queueID, averageWaitTime, queuedTime

				status, mapName, queueID, _, averageWaitTime, queuedTime = GetWorldPVPQueueStatus(data.index)
				macrotext = "/run BattlefieldMgrExitRequest(" .. queueID .. ")"
				frame.type = "world"

				timeInQueue = GetTime() - queuedTime
				timeToMatch = averageWaitTime

			elseif(data.type == "openworld") then
				frame.type = "openworld"
				macrotext = "/run HearthAndResurrectFromArea()"
				mapName = GetRealZoneText()

				timeInQueue = GetTime()
				timeToMatch = -1

			elseif(data.type == "petbattle") then
				frame.type = "petbattle"
				macrotext = "/run C_PetBattles.StopPVPMatchmaking()"
				mapName = "Pet Battle"

				local _, estimated, queuedTime = C_PetBattles.GetPVPMatchmakingInfo()

				timeToMatch = estimated
				timeInQueue = GetTime() - queuedTime
				backgroundImage = "interface/petbattles/petbattlesqueue.blp"

			elseif(data.type == "plunderstorm") then
				local queueTime = C_LobbyMatchmakerInfo.GetQueueStartTime();

				macrotext = "/run C_LobbyMatchmakerInfo.AbandonQueue()"
				mapName = WOW_LABS_PLUNDERSTORM_CATEGORY
				timeInQueue = GetTime() - queueTime
			
			end
			
			activityName = mapName

			frame.index = data.index
			frame:SetTimerInfo("add", timeInQueue)
			frame:SetWaitInfo(timeToMatch)

			frame.Wait:Show()
		end

		--[[if(isHQ) then
			frame.Background:SetVertTile(false)
			frame.Background:SetHorizTile(false)
			frame.Background:SetTexture(backgroundImage, "CLAMP", "CLAMP")
			
		else]]
			frame.Background:SetVertTile(true)
			frame.Background:SetHorizTile(true)
			frame.Background:SetTexture(backgroundImage, "MIRROR", "MIRROR")

		--end

		frame.Name:SetText(activityName)
		frame.CancelApplication:SetAttribute("macrotext1", macrotext)
    end

    local function CustomFactory(factory, data)
		local template = data.template
		factory(template, Initializer)

	end
	
	view:SetElementFactory(CustomFactory)

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", 3, -4),
		CreateAnchor("BOTTOMRIGHT", -18, 3);
	}

	local scrollBoxAnchorsWithoutBar = {
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", -3, 3);
	}

	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar)

	self.ScrollBox:SetDataProvider(self.dataProvider)

	self:RegisterNecessaryEvents()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	--[[
	
		
	if(JoinArena) then
		hooksecurefunc("JoinArena", function()
			MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=ARENA}
		end)
	end

	if(JoinBattlefield) then
		hooksecurefunc("JoinRatedSoloShuffle", function()
			MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=PVP_RATED_SOLO_SHUFFLE}
		end)
	end

	if(JoinRatedBattlefield) then
		hooksecurefunc("JoinRatedBattlefield", function()
			MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=PVP_RATED_BATTLEGROUND}
		end)
	end

	if(C_PvP.JoinRatedBGBlitz) then
		hooksecurefunc(C_PvP, "JoinRatedBGBlitz", function()
			MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=PVP_RATED_BG_BLITZ}
		end)
	end

	if(JoinBattlefield) then
		hooksecurefunc("JoinBattlefield", function()
			MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=BATTLEGROUND}
		end)
	end

	if(JoinSkirmish) then
		hooksecurefunc("JoinSkirmish", function()
			MIOG_CharacterSettings.lastUsedQueue = {type = "pvp", subtype="faulty", alias=ARENA_CASUAL}
		end)
	end
	
	
	
	
	]]
end