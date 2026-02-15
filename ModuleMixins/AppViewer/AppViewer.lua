local addonName, miog = ...
local wticc = WrapTextInColorCode
local treeDataProvider = CreateTreeDataProvider()
local queueTimer

local categoryID

AppViewer = CreateFromMixins(CallbackRegistryMixin)

function AppViewer:FindApplicantFrame(applicantID)
	local frame = self.ScrollBox:FindFrameByPredicate(function(localFrame, node)
		local data = node:GetData()

		if(data) then
			return data.applicantID == applicantID

		end
	end)

	return frame
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

function AppViewer:AddApplicant(applicantID, activityID)
	local applicantData = C_LFGList.GetApplicantInfo(applicantID)

	if(applicantData) then
		local groupData = {}

		local parent
		local multipleMembers = applicantData.numMembers > 1
		local numMembers = applicantData.numMembers

		local allDataAvailable = true

		local overallPrimary, overallSecondary, overallRole, overallItemLevel = 0, 0, 0, 0

		local isRaid = categoryID == 3
		local raidTable = {}

		for k = 1, numMembers do
			local name, class, localizedClass, level, itemLevel, honorlevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, faction, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(applicantID, k)

			if(name) then
				local primary, secondary
				local fullName, playerName, realm = miog.createFullNameValuesFrom("unitName", name)
				local raidData

				if(categoryID == 2) then
					primary = dungeonScore

					local dungeonInfo = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activityID)
					secondary = dungeonInfo.bestRunLevel
					
				elseif(categoryID == 3) then
					raidData = miog.getRaidProgress(playerName, realm)
					primary, secondary = miog.getWeightFromRaidProgress(raidData)

					raidTable[k] = raidData
				
				elseif(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
					local pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activityID)

					primary = pvpRatingInfo.rating
					secondary = pvpRatingInfo.bracket

				else
					primary = 0
					secondary = 0

				end

				local roleValue = assignedRole == "TANK" and 1 or assignedRole == "HEALER" and 20 or 400

				groupData[k] = {
					template = "MIOG_AppViewerApplicantMemberTemplate",
					applicantID = applicantID,
					applicantIndex = k,
					numMembers = numMembers,

					class = class,
					specID = specID,

					playerName = playerName,
					realm = realm,

					categoryID = categoryID,
					primary = primary,
					secondary = secondary,

					raidData = raidData,
					itemLevel = itemLevel,

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
				local averagePrimary, averageSecondary, averageRole, averageItemLevel = overallPrimary / numMembers, overallSecondary / numMembers, overallRole / numMembers, overallItemLevel / numMembers

				parent = treeDataProvider:Insert({
					template = "MIOG_AppViewerApplicantTemplate",
					applicantID = applicantID,

					categoryID = categoryID,

					primary = averagePrimary,
					secondary = averageSecondary,
					
					raidData = raidTable,

					itemLevel = averageItemLevel,

					role = averageRole,
				})

			else
				parent = treeDataProvider

			end

			for k = 1, applicantData.numMembers do
				local singleMember = parent:Insert(groupData[k])
				singleMember:SetCollapsed(true, true, true)
				singleMember:Insert({template = "MIOG_NewRaiderIOInfoPanel", applicantID = applicantID, name = groupData[k].playerName, realm = groupData[k].realm})

			end
		end
	end
end

function AppViewer:RefreshApplicantList()
	C_LFGList.RefreshApplicants()

    treeDataProvider:Flush()

    local applicantList = C_LFGList.GetApplicants()
	local activeEntry = C_LFGList.GetActiveEntryInfo()

	if(applicantList and #applicantList > 0) then
		for _, applicantID in ipairs(applicantList) do
			local applicantData = C_LFGList.GetApplicantInfo(applicantID)

			self:AddApplicant(applicantID, activeEntry.activityIDs[1])
			
		end

    	self.SortButtons:Sort()
	end
end

function AppViewer:RetrieveAndSetEntryInfo()
	local activeEntry = C_LFGList.GetActiveEntryInfo()

	if(activeEntry) then
		local activityInfo = C_LFGList.GetActivityInfoTable(activeEntry.activityIDs[1])
		categoryID = activityInfo.categoryID
		local customInfo = miog:GetActivityInfo(activeEntry.activityIDs[1])

		local pretext = activeEntry.privateGroup and "!" or ""

		self.ActivityBar.Name:SetText(pretext .. activeEntry.name)
		self.ActivityBar.Title:SetText(pretext .. (activityInfo.difficultyID and miog.DIFFICULTY_ID_TO_SHORT_NAME[activityInfo.difficultyID] and customInfo.groupName .. " - " .. miog.DIFFICULTY_ID_TO_SHORT_NAME[activityInfo.difficultyID] or activityInfo.fullName))
		self.ActivityBar.Description:SetText(activeEntry.comment)
		self.ActivityBar.Background:SetTexture(customInfo.horizontal or miog.ACTIVITY_BACKGROUNDS[customInfo.categoryID], "MIRROR", "MIRROR")
		
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

		if(activeEntry.requiredItemLevel > 0) then
			self.ActivityBar.Secondary:SetText(activeEntry.requiredItemLevel)

		else
			self.ActivityBar.Secondary:SetText("---")

		end

		self.ActivityBar.VoiceChat:SetDesaturated(not LFGListFrame.EntryCreation.VoiceChat.CheckButton:GetChecked())

		if(activeEntry.isCrossFactionListing) then
			self.ActivityBar.Faction:SetTexture(2437241)

		else
			local playerFaction = UnitFactionGroup("player")
			self.ActivityBar.Faction:SetTexture(playerFaction == "Alliance" and 2173919 or playerFaction == "Horde" and 2173920)

		end
	end
end

function AppViewer:Refresh()
	local activeEntry = C_LFGList.GetActiveEntryInfo()
	local applicantList = C_LFGList.GetApplicants()

	if(applicantList and #applicantList > 0) then
		for _, applicantID in ipairs(applicantList) do
			local applicantExists = treeDataProvider:ContainsByPredicate(function(node)
				local data = node:GetData()

				if(data) then
					return data.applicantID == applicantID

				end
			end, true)

			if(not applicantExists) then
				self:AddApplicant(applicantID, activeEntry.activityIDs[1])

			end
		end
	end
end

function AppViewer:OnEvent(event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		self:RefreshApplicantList()

	elseif(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		local justCreated = ...

		if(justCreated == nil) then
			if(queueTimer) then
				queueTimer:Cancel()
				queueTimer = nil
			end
		else
			if(justCreated) then
				treeDataProvider:Flush()
				MIOG_NewSettings.queueUpTime = GetTimePreciseSec()
				
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

		if(withData) then
			self:Refresh()

		end
	elseif(event == "LFG_LIST_APPLICANT_UPDATED") then
		local applicantID = ...
		local applicantData = C_LFGList.GetApplicantInfo(applicantID)
		local canInvite = LFGListUtil_IsEntryEmpowered()
		local frame = self:FindApplicantFrame(applicantID)

		if(frame) then
			if(not applicantData) then
				if(canInvite) then
					frame:RefreshStatus("unknown")

				else
					self:RemoveApplicantFrame(applicantID)

				end
			else
				local appStatus = applicantData.pendingApplicationStatus or applicantData.applicationStatus

				if(appStatus ~= "applied") then
					if(appStatus == "timedout" or appStatus == "cancelled" or appStatus == "failed" or appStatus == "invitedeclined" or appStatus == "inviteaccepted" or appStatus == "declined" or appStatus == "declined_full" or appStatus == "declined_delisted") then
						if(canInvite) then
							frame:RefreshStatus(appStatus)

						else
							self:RemoveApplicantFrame(applicantID)

						end
					elseif(appStatus == "invited") then
						frame:RefreshStatus(appStatus)

					end
				end
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

local registered = false

function AppViewer:OnShow()
	if(not registered) then
		ScrollUtil.RegisterScrollBoxWithScrollBar(self.ScrollBox, miog.pveFrame2.ScrollBarArea.ApplicationViewerScrollBar)
		registered = true
	end
end

function AppViewer:OnLoad()
	CallbackRegistryMixin.OnLoad(self)
    --local view = Mixin(CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 6), TreeListViewMultiSpacingMixin)
	--view:SetDepthSpacing()
    local view = CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 6)
    self.view = view

	local function Initializer(frame, node)
		local data = node:GetData()

		if(data.template == "MIOG_AppViewerApplicantMemberTemplate") then
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
	self.ScrollBox:Init(view)

	--[[local tableBuilder = CreateTableBuilder(nil, TableBuilderMixin)
    tableBuilder:SetHeaderContainer(self.SortHeader)

    local function ElementDataProvider(elementData, ...)
        return elementData

    end

    tableBuilder:SetDataProvider(ElementDataProvider)

    local function ElementDataTranslator(elementData, ...)
        return elementData

    end

    ScrollUtil.RegisterTableBuilder(self.ScrollBox, tableBuilder, ElementDataTranslator)
    
    tableBuilder:Reset()

    local column0 = tableBuilder:AddColumn()
    column0:ConstructHeader("Button", "MIOG_HeaderSortButtonTemplate", "", "", 1)
    column0:ConstructCells("Frame", "MIOG_AppViewerTextCellTemplate")

    local column1 = tableBuilder:AddColumn()
    column1:ConstructHeader("Button", "MIOG_HeaderSortButtonTemplate", "Role", "role", 2)
    column1:ConstructCells("Frame", "MIOG_AppViewerTextureCellTemplate", "role")

    local column2 = tableBuilder:AddColumn()
    column2:ConstructHeader("Button", "MIOG_HeaderSortButtonTemplate", "", "", 3)
    column2:ConstructCells("Frame", "MIOG_AppViewerTextCellTemplate")

    local column3 = tableBuilder:AddColumn()
    column3:ConstructHeader("Button", "MIOG_HeaderSortButtonTemplate", "#1", "rating", 3)
    column3:ConstructCells("Frame", "MIOG_AppViewerTextCellTemplate")

    local column4 = tableBuilder:AddColumn()
    column4:ConstructHeader("Button", "MIOG_HeaderSortButtonTemplate", "#2", "primary", 3)
    column4:ConstructCells("Frame", "MIOG_AppViewerTextCellTemplate")

    local column5 = tableBuilder:AddColumn()
    column5:ConstructHeader("Button", "MIOG_HeaderSortButtonTemplate", "I-Lvl", "secondary", 3)
    column5:ConstructCells("Frame", "MIOG_AppViewerTextCellTemplate")
	
    local column6 = tableBuilder:AddColumn()
    column6:ConstructHeader("Button", "MIOG_HeaderSortButtonTemplate", "", "", 1)
    column6:ConstructCells("Frame", "MIOG_AppViewerTextCellTemplate")

    tableBuilder:Arrange()

	self.SortHeader:Reload()]]

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