local addonName, miog = ...
local wticc = WrapTextInColorCode
local treeDataProvider = CreateTreeDataProvider()
local queueTimer

local categoryID

AppViewer = CreateFromMixins(CallbackRegistryMixin)

function AppViewer:CreateDebugApplicants(numApplicants)
	local groupData = {}

	local applicantID = random(1, 100)

	for i = 1, numApplicants, 1 do
		groupData[i] = {
			template = "MIOG_AppViewerApplicantSingleMemberTemplate",
			applicantID = applicantID,
			applicantIndex = i,
			numMembers = numApplicants,

			class = miog.CLASSES[i].name,
			specID = miog.CLASSES[i].specs[1],

			playerName = "Player" .. i,
			realm = "Realm" .. i,

			categoryID = categoryID,
			primary = random(0, 4000),
			secondary = random(0, 25),

			raidData = nil,
			itemLevel = random(210, 240),

			role = 2,
		}
	end

	if(numApplicants > 1) then
		parent = treeDataProvider:Insert({
			template = "MIOG_AppViewerApplicantMultiMemberTemplate",
			applicantID = applicantID,
			categoryID = categoryID,
			itemLevel = averageItemLevel,
			numMembers = numApplicants,
			players = groupData
		})
		parent:SetCollapsed(true, true, false)

	else
		parent = treeDataProvider

	end

	for k = 1, numApplicants do
		local singleMember = parent:Insert(groupData[k])
		singleMember:SetCollapsed(true, true, false)
		singleMember:Insert({template = "MIOG_NewRaiderIOInfoPanel", applicantID = applicantID, name = groupData[k].playerName, realm = groupData[k].realm})

	end
end

function AppViewer:RemoveApplicantFrame(applicantID)
	local index, node = treeDataProvider:FindByPredicate(function(node)
		local data = node:GetData()

		if(data) then
			return data.applicantID == applicantID

		end
	end, true)

	treeDataProvider:Remove(node)
end

function AppViewer:AddApplicant(applicantID)
	local activeEntry = miog:GetSecureActiveEntryInfo()
	local applicantData = miog:GetSecureApplicantData(applicantID)

	if(applicantData and miog:CanAccessValue(applicantData.comment)) then
		local groupData = {}

		local parent
		local multipleMembers = applicantData.numMembers > 1

		local allDataAvailable = true

		local overallPrimary, overallSecondary, overallRole, overallItemLevel = 0, 0, 0, 0
		local raidTable = {}

		for k = 1, applicantData.numMembers do
			local name, class, localizedClass, level, itemLevel, honorlevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, faction, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(applicantID, k)

			if(name) then
				local primary, secondary
				local _, playerName, realm = miog.createFullNameValuesFrom("unitName", name)
				local raidData

				if(categoryID == 2) then
					primary = dungeonScore

					local dungeonInfo = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activeEntry.activityIDs[1])
					secondary = dungeonInfo.bestRunLevel
					
				elseif(categoryID == 3) then
					raidData = miog.getRaidProgress(playerName, realm)
					primary, secondary = miog.getWeightFromRaidProgress(raidData)

					raidTable[k] = raidData
				
				elseif(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
					local pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activeEntry.activityIDs[1])

					primary = pvpRatingInfo.rating
					secondary = pvpRatingInfo.bracket

				else
					primary = 0
					secondary = 0

				end

				local roleValue = assignedRole == "TANK" and 1 or assignedRole == "HEALER" and 20 or 400

				groupData[k] = {
					template = "MIOG_AppViewerApplicantSingleMemberTemplate",
					applicantID = applicantID,
					applicantIndex = k,

					categoryID = categoryID,

					itemLevel = itemLevel,
					primary = primary,
					secondary = secondary,
					raidData = raidData,
					role = roleValue,
				}

				overallRole = overallRole + roleValue
				overallPrimary = overallPrimary + primary
				overallSecondary = overallSecondary + secondary
				overallItemLevel = overallItemLevel + itemLevel

			else
				allDataAvailable = false

			end
		end

		if(allDataAvailable) then
			if(multipleMembers) then
				--local averagePrimary, averageSecondary, averageRole, averageItemLevel = overallPrimary / applicantData.numMembers, overallSecondary / applicantData.numMembers, overallRole / applicantData.numMembers, overallItemLevel / applicantData.numMembers

				parent = treeDataProvider:Insert({
					template = "MIOG_AppViewerApplicantMultiMemberTemplate",
					applicantID = applicantID,

					categoryID = categoryID,

					primary = averagePrimary,
					secondary = averageSecondary,
					
					raidData = raidTable,

					itemLevel = averageItemLevel,

					role = averageRole,
				})
				parent:SetCollapsed(true, true, false)

			else
				parent = treeDataProvider

			end

			for k = 1, applicantData.numMembers do
				local singleMember = parent:Insert(groupData[k])
				singleMember:SetCollapsed(true, true, false)
				singleMember:Insert({template = "MIOG_NewRaiderIOInfoPanel", applicantID = applicantID, applicantIndex = k})

			end
		end
	end
end

function AppViewer:RetrieveAndSetEntryInfo()
	local activeEntry = miog:GetSecureActiveEntryInfo()

	if(activeEntry) then
		local activityInfo = miog:GetActivityInfo(activeEntry.activityIDs[1])
		categoryID = activityInfo.categoryID

		self.ActivityBar.Name:SetText(activeEntry.name)
		self.ActivityBar.Title:SetText(activityInfo.difficultyID and miog.DIFFICULTY_ID_TO_SHORT_NAME[activityInfo.difficultyID] and activityInfo.fullName .. " - " .. miog.DIFFICULTY_ID_TO_SHORT_NAME[activityInfo.difficultyID] or activityInfo.fullName)
		self.ActivityBar.Description:SetText(activeEntry.comment)
		self.ActivityBar.Background:SetTexture(activityInfo.horizontal or miog.ACTIVITY_BACKGROUNDS[activityInfo.categoryID], "MIRROR", "MIRROR")
		
		if(activityInfo.categoryID == 2) then
			self.ActivityBar.Primary:SetText(activityInfo.requiredDungeonScore)
			self.SortButtons:SetSortButtonTexts("Role", "Rtng", "Key", "I-Lvl")

		elseif(activityInfo.categoryID == 4 or activityInfo.categoryID == 7 or activityInfo.categoryID == 8 or activityInfo.categoryID == 9) then
			self.ActivityBar.Primary:SetText(activityInfo.requiredPvpRating)
			self.SortButtons:SetSortButtonTexts("Role", "Rtng", "Tier", "I-Lvl")

		elseif(activityInfo.categoryID == 3) then --todo
			self.ActivityBar.Primary:SetText("---")
			self.SortButtons:SetSortButtonTexts("Role", "Prog", "Prog", "I-Lvl")
			
		else
			self.ActivityBar.Primary:SetText("---")
			self.SortButtons:SetSortButtonTexts("Role", nil, nil, "I-Lvl")

		end

		self.ActivityBar.Secondary:SetText(activeEntry.requiredItemLevel)
		self.ActivityBar.VoiceChat:SetDesaturated(not LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked())

		--[[if(LFGListFrame.EntryCreation.CrossFactionGroup.CheckButton:IsChecked()) then
			self.ActivityBar.Faction:SetTexture(2437241)

		else
			local playerFaction = UnitFactionGroup("player")
			self.ActivityBar.Faction:SetTexture(playerFaction == "Alliance" and 2173919 or playerFaction == "Horde" and 2173920)

		end]]
	end
end

function AppViewer:Refresh()
	treeDataProvider:Flush()
	treeDataProvider:SetAllCollapsed(true)

	local applicantList = C_LFGList.GetApplicants()

	if(applicantList and #applicantList > 0) then
		for _, applicantID in ipairs(applicantList) do
			self:AddApplicant(applicantID)

		end

    	self.SortButtons:Sort()
	end

	self.ScrollBox:SetDataProvider(treeDataProvider)

	--self:CreateDebugApplicants(3)
end

function AppViewer:OnEvent(event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		self:Refresh()

	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		local justCreated = ...

		if(justCreated == nil) then
			if(queueTimer) then
				queueTimer:Cancel()

			end
		else
			if(justCreated) then
				self:Refresh()
				MIOG_NewSettings.queueUpTime = GetTimePreciseSec()
				
				if(queueTimer) then
					queueTimer:Cancel()
					queueTimer = nil
				end
			else
				MIOG_NewSettings.queueUpTime = MIOG_NewSettings.queueUpTime > 0 and MIOG_NewSettings.queueUpTime or GetTimePreciseSec()

			end

			if(not queueTimer) then
				queueTimer = C_Timer.NewTicker(1, function()
					self.ActivityBar.QueueTime:SetText(miog.secondsToClock(GetTimePreciseSec() - MIOG_NewSettings.queueUpTime))

				end)
			end
		end

		self:RetrieveAndSetEntryInfo()

	elseif(event == "LFG_LIST_APPLICANT_LIST_UPDATED") then
		local newEntry, withData = ...

		if(withData or not newEntry) then
			self:Refresh()
			
		end
	elseif(event == "LFG_LIST_APPLICANT_UPDATED") then
		local applicantID = ...
		local frame = self.ScrollBox:FindFrameByPredicate(function(localFrame, node)
		local data = node:GetData()
			if(data) then
				return data.applicantID == applicantID

			end
		end)

		if(frame) then
			local applicantData = miog:GetSecureApplicantData(applicantID)

			if(applicantData) then
				local appStatus = applicantData.pendingApplicationStatus or applicantData.applicationStatus

				if(appStatus ~= "applied") then
					if(appStatus == "timedout" or appStatus == "cancelled" or appStatus == "failed" or appStatus == "invitedeclined" or appStatus == "inviteaccepted" or appStatus == "declined" or appStatus == "declined_full" or appStatus == "declined_delisted") then
						frame:RefreshStatus(appStatus)

					end
				end
			elseif(LFGListUtil_IsEntryEmpowered()) then
				frame:RefreshStatus("unknown")

			end
		end
	elseif(event == "PARTY_LEADER_CHANGED") then
		local visible = LFGListUtil_IsEntryEmpowered()

		for _, frame in self.ScrollBox:EnumerateFrames() do
			frame.Invite:SetShown(visible)
			frame.Decline:SetShown(visible)

		end

		self.ActivityBar.Delist:SetEnabled(visible)
		self.ActivityBar.Edit:SetEnabled(visible)
	end
end

function AppViewer:OnShow()
	self:Refresh()

end

function AppViewer:OnLoad()
	local visualTable = {
        edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 2
    }
    local r, g, b, a = GRAY_FONT_COLOR:GetRGBA()
	
	self:SetBackdrop(visualTable)
	self:SetBackdropBorderColor(r, g, b, a)

	self.SortButtons.Role:SetBackdrop(visualTable)
	self.SortButtons.Role:SetBackdropBorderColor(r, g, b, a)

	self.SortButtons.Primary:SetBackdrop(visualTable)
	self.SortButtons.Primary:SetBackdropBorderColor(r, g, b, a)

	self.SortButtons.Secondary:SetBackdrop(visualTable)
	self.SortButtons.Secondary:SetBackdropBorderColor(r, g, b, a)

	self.SortButtons.ItemLevel:SetBackdrop(visualTable)
	self.SortButtons.ItemLevel:SetBackdropBorderColor(r, g, b, a)

	
	CallbackRegistryMixin.OnLoad(self)
    local view = CreateScrollBoxListTreeListView(3, 0, 0, 0, 0, 6)
    self.view = view

	local function Initializer(frame, node)
		local data = node:GetData()

		if(data.template == "MIOG_AppViewerApplicantSingleMemberTemplate") then
			frame:SetData(data)

		elseif(data.template == "MIOG_NewRaiderIOInfoPanel") then
			miog.updateRaiderIOScrollBoxFrameData(frame, data)

		else
			frame:SetData(data)

		end
	end
	
	local function CustomFactory(factory, node)
		local data = node:GetData()

		local template = data.template

		factory(template, Initializer)
	end

	view:SetElementFactory(CustomFactory)
    ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self:GetParent():GetParent():GetParent().ScrollBarArea.ApplicationViewerScrollBar, view)
	self.ScrollBox:SetDataProvider(treeDataProvider)
	self.SortButtons:RegisterDataProvider(treeDataProvider, "applicantID")

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
	self:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
	self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)

	miog.ApplicationViewer = self
end