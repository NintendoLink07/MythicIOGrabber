local addonName, miog = ...

local lastUpdate = 0
local dataProvider = CreateDataProvider()

QueueManagerMixin = {}

function QueueManagerMixin:FindFrame(name, value)
	return dataProvider:FindByPredicate(function(data)
		return data[name] and data[name] == value

	end)
end

function QueueManagerMixin:RemoveFrame(name, value)
	return dataProvider:RemoveByPredicate(function(data)
		return data[name] and data[name] == value

	end)
end

function QueueManagerMixin:UpdateFakeApplications()
end

function QueueManagerMixin:UpdateListing()
	local isActive = C_LFGList.HasActiveEntryInfo()

	if (isActive) then
		dataProvider:Insert({
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
			local isRaidFinder = categoryID == LE_LFG_CATEGORY_RF

			for queueID, queued in pairs(queuedList) do
				local isCurrentlyActive = activeID == queueID
				
				if(isCurrentlyActive or isRaidFinder) then
					if(not self:FindFrame("queueID", queueID)) then
						dataProvider:Insert({
							template = "MIOG_QueueManagerLFGFrameTemplate",
							categoryID = categoryID,
							queueID = queueID,
							isMultiDungeon = categoryID == LE_LFG_CATEGORY_LFD and length > 1 or false,
							isRaidFinder = isRaidFinder
						})
					end
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
				dataProvider:Insert({
					template = "MIOG_QueueManagerApplicationFrameTemplate",
					resultID = resultID,
				})

			end
		end
	end
end



function QueueManagerMixin:UpdatePVPQueues()
	for i=1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i);

		if(status and status ~= "none" and status ~= "error") then
			dataProvider:Insert({
				template = "MIOG_QueueManagerFramePVPTemplate",
				index = i,
				type = "battlefield"
			})
		end
	end
end

function QueueManagerMixin:UpdateWorldPVPQueues()
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status = GetWorldPVPQueueStatus(i)

		if(status and status ~= "none") then
			dataProvider:Insert({
				template = "MIOG_QueueManagerFramePVPTemplate",
				index = i,
				type = "world"
			})
		end
	end

	if(CanHearthAndResurrectFromArea()) then
		dataProvider:Insert({
			template = "MIOG_QueueManagerFramePVPTemplate",
			type = "openworld"
		})

	end
end

function QueueManagerMixin:UpdatePetBattleQueue()
	if(C_PetBattles.GetPVPMatchmakingInfo()) then
		dataProvider:Insert({
			template = "MIOG_QueueManagerFramePVPTemplate",
			type = "petbattle",
		})

	end
end

function QueueManagerMixin:UpdatePlunderstormQueue()
	if(C_LobbyMatchmakerInfo.IsInQueue()) then
		dataProvider:Insert({
			template = "MIOG_QueueManagerFramePVPTemplate",
			type = "plunderstorm",
		})

	end
end

function QueueManagerMixin:CheckQueues()
	if(not InCombatLockdown()) then
		dataProvider:Flush()

		self:UpdateFakeApplications()
		self:UpdatePVEQueues()
		self:UpdateListing()
		self:UpdateGroupApplications()
		self:UpdatePVPQueues()
		self:UpdateWorldPVPQueues()
		self:UpdatePetBattleQueue()
		self:UpdatePlunderstormQueue()

		self.Title:SetShown(dataProvider:GetSize() < 1)
	end
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

function QueueManagerMixin:OnEvent(...)
	--local currentTime = GetTime()

	--if(currentTime > lastUpdate + 0.1) then
	--	lastUpdate = currentTime

	--local event = ...

	local event2 = ...

	if(not InCombatLockdown()) then
		if(event2 == "LFG_LIST_APPLICATION_STATUS_UPDATED") then --event == "LFG_LIST_SEARCH_RESULT_UPDATED"
			local resultID, status = ...
		
			local frame = self:FindFrame("resultID", resultID)

			if(frame and status == "applied") then
				frame:Update()

			else
				self:UpdateGroupApplications()

			end

		elseif(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
			self:UpdateGroupApplications()

		elseif(event == "LFG_UPDATE" or event == "LFG_ROLE_CHECK_UPDATE" or event == "LFG_READY_CHECK_UPDATE" or event == "LFG_PROPOSAL_UPDATE" or event == "LFG_PROPOSAL_FAILED" or event == "LFG_PROPOSAL_SUCCEEDED" or event == "LFG_PROPOSAL_SHOW" or event == "LFG_QUEUE_STATUS_UPDATE") then
			self:UpdatePVEQueues()

		elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" or event == "LFG_LIST_APPLICANT_UPDATED") then
			self:UpdateListing()

		elseif(event == "UPDATE_BATTLEFIELD_STATUS" or event == "PVP_BRAWL_INFO_UPDATED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED") then
			self:UpdatePVPQueues()
			self:UpdateWorldPVPQueues()

		elseif(event == "PET_BATTLE_QUEUE_STATUS") then
			self:UpdatePetBattleQueue()

		elseif(event == "LOBBY_MATCHMAKER_QUEUE_STATUS_UPDATE" or event == "LOBBY_MATCHMAKER_QUEUE_ABANDONED" or event == "LOBBY_MATCHMAKER_QUEUE_POPPED" or event == "LOBBY_MATCHMAKER_QUEUE_EXPIRED" or event == "LOBBY_MATCHMAKER_QUEUE_ERROR") then
			self:UpdatePlunderstormQueue()

		else
			self:CheckQueues()

		end
	end
	--end
end

function QueueManagerMixin:OnLoad()
	--[[EventRegistry:RegisterCallback("LobbyMatchmaker.UpdateQueueState",
		function(...)
			local table = ...
			print(table:GetDebugName())

			local currentTime = GetTime()

			if(currentTime > lastUpdate + 0.5) then
				lastUpdate = currentTime

				self:CheckQueues()
			end
		end,
	self);]]
	
	--hooksecurefunc(QueueStatusFrame, "Update", function() print("UPDATEEEE") end)

    dataProvider = CreateDataProvider()
    local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 3)

	local function Initializer(frame, data)
		--[[local backgroundImage, activityName, macrotext, timeInQueue, timeToMatch

		if(data.template == "MIOG_QueueManagerLFGFrameTemplate") then
			
		elseif(data.template == "MIOG_QueueManagerListingFrameTemplate") then

		elseif(data.template == "MIOG_QueueManagerApplicationFrameTemplate") then
			
		elseif(data.template == "MIOG_QueueManagerFramePVPTemplate") then
			
		end]]

		--[[if(isHQ) then
			frame.Background:SetVertTile(false)
			frame.Background:SetHorizTile(false)
			frame.Background:SetTexture(backgroundImage, "CLAMP", "CLAMP")
			
		else
			frame.Background:SetVertTile(true)
			frame.Background:SetHorizTile(true)
			frame.Background:SetTexture(backgroundImage, "MIRROR", "MIRROR")

		--end]]

		frame:SetData(data)
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

	self.ScrollBox:SetDataProvider(dataProvider)

	self:RegisterNecessaryEvents()

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