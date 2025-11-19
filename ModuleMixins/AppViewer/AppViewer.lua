local addonName, miog = ...
local wticc = WrapTextInColorCode
local treeDataProvider = CreateTreeDataProvider()
local queueTimer

local categoryID

AppViewer = CreateFromMixins(CallbackRegistryMixin)

function AppViewer:FindApplicantFrame(applicantID)
	local frame = miog.SearchPanel.ScrollBox2:FindFrameByPredicate(function(localFrame, node)
		return node.applicantID == applicantID

	end)

	return frame
end

function AppViewer:RefreshApplicantList()
    local applicantList = C_LFGList.GetApplicants()
	local activeEntry = C_LFGList.GetActiveEntryInfo()

	treeDataProvider:Flush()

    for index, applicantID in ipairs(applicantList) do
		local groupData = {}

		local averageItemLevel, averagePrimary, averageSecondary, averageRole = 0, 0, 0, 0

        local applicantData = C_LFGList.GetApplicantInfo(applicantID)
		local memberNames = {}

		local parent

		for k = 1, applicantData.numMembers do
			local name, class, localizedClass, level, itemLevel, honorlevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, faction, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(applicantID, k)
            tinsert(memberNames, {name = name, class = class})

			local primary, secondary, primary2, secondary2
			local fullName, playerName, realm = miog.createFullNameValuesFrom("unitName", name)
			local playerDifficultyData

			if(categoryID == 2) then
				primary = dungeonScore
				secondary = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activeEntry.activityIDs[1]).bestRunLevel
				
			elseif(categoryID == 3) then
				local raidData = miog.getRaidProgress(playerName, realm)
				primary, secondary, primary2, secondary2 = miog.getWeightAndAliasesFromRaidProgress(raidData)
			
			elseif(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
				local pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activeEntry.activityIDs[1])

				primary = pvpRatingInfo.rating
				secondary = pvpRatingInfo.bracket

			else
				primary = 0
				secondary = 0

			end

			averagePrimary = averagePrimary + primary
			averageSecondary = averageSecondary + secondary

			groupData[k] = {
				template = "MIOG_AppViewerApplicantMemberTemplate",
				applicantID = applicantID,
				applicantIndex = k,
				playerName = playerName,
				realm = realm,

				comment = applicantData.comment,
				categoryID = categoryID,
				primary = primary,
				secondary = secondary,

				primary2 = primary2,
				secondary2 = secondary2,

				raidData = playerDifficultyData,
				itemLevel = itemLevel,
			}
		end

			
		averageItemLevel = averageItemLevel / applicantData.numMembers
		averagePrimary = averagePrimary / applicantData.numMembers
		averageSecondary = averageSecondary / applicantData.numMembers
		averageRole = averageRole / applicantData.numMembers

		if(applicantData.numMembers > 1) then
			parent = treeDataProvider:Insert({template = "MIOG_AppViewerApplicantTemplate", applicantID = applicantID, debug = true, categoryID = categoryID, itemLevel = averageItemLevel, primary = averagePrimary, secondary = averageSecondary, role = averageRole, names = memberNames})

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

function AppViewer:OnEvent(event, ...)
    print(event, ...)

    if(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		local justCreated = ...

		if(justCreated) then
			self.ScrollBox:Flush()
				MIOG_NewSettings.queueUpTime = GetTimePreciseSec()
			
		elseif(justCreated == false) then
			MIOG_NewSettings.queueUpTime = MIOG_NewSettings.queueUpTime > 0 and MIOG_NewSettings.queueUpTime or GetTimePreciseSec()
			
		end

        local activeEntry = C_LFGList.GetActiveEntryInfo()

		local queueTime

        if(activeEntry) then
            local activityInfo = C_LFGList.GetActivityInfoTable(activeEntry.activityIDs[1])
			categoryID = activityInfo.categoryID
			local customInfo = miog.requestActivityInfo(activeEntry.activityIDs[1])

            self.ActivityBar.Title:SetText(activityInfo.fullName)
            self.ActivityBar.Name:SetText(activeEntry.name)
            self.ActivityBar.Description:SetText(activeEntry.comment)

			self.ActivityBar.Background:SetTexture(customInfo.horizontal or miog.ACTIVITY_BACKGROUNDS[customInfo.categoryID])
        end

		if(queueTimer) then
			queueTimer:Cancel()

		end

		queueTimer = C_Timer.NewTicker(1, function()
			self.ActivityBar.QueueTime:SetText(miog.secondsToClock(GetTimePreciseSec() - MIOG_NewSettings.queueUpTime))

		end)

    elseif(event == "LFG_LIST_APPLICANT_LIST_UPDATED") then
        self:RefreshApplicantList()

		local fullName, playerName, realm = miog.createFullNameValuesFrom("unitName", UnitName("player"))

		for i = 1, 10 do
			local groupData = {}

			local stale = random(1, 100) > 75

			local multipleMembers = random(1, 100) > 75
			local numOfMembers = multipleMembers and random(2,4) or 1
			local averageItemLevel, averagePrimary, averageSecondary, averageRole = 0, 0, 0, 0

			local memberNames = {}
			local parent

			for k = 1, numOfMembers do
				local itemLevel = GetAverageItemLevel() + random(-4, 4)

				averageItemLevel = averageItemLevel + itemLevel

				local localized, file, id = UnitClass("player")
				tinsert(memberNames, {name = playerName .. k, class = file})

				local roleRoll = random(0, 2)
				averageRole = averageRole + roleRoll

				local data = {
					template = "MIOG_AppViewerApplicantMemberTemplate",
					applicantID = i,
					debug = true,
					categoryID = categoryID,
					stale = stale,
					multi = multipleMembers,
					debugIndex = i,
					itemLevel = itemLevel,
					assignedRole = roleRoll == 0 and "TANK" or roleRoll == 1 and "HEALER" or "DAMAGER",
					role = roleRoll,
				}
				
				if(data.categoryID == 2) then
					data.primary = C_ChallengeMode.GetOverallDungeonScore() + random(-1000, 500)

					local rioProfile = RaiderIO.GetProfile("player")
					
					if(rioProfile and rioProfile.mythicKeystoneProfile) then
						data.secondary = rioProfile.mythicKeystoneProfile.maxDungeonLevel + random(-10, 3)

					else
						data.secondary = 0

					end
					
				elseif(data.categoryID == 3) then
					local raidData = miog.getRaidProgress(playerName, realm)

					data.raidData = raidData

					if(raidData) then
						data.primary, data.secondary, data.primary2, data.secondary2 = miog.getWeightAndAliasesFromRaidProgress(raidData)

					else
						data.primary = 0
						data.secondary = 0
						data.primary2 = "0/0"
						data.secondary2 = "0/0"

					end

				elseif(data.categoryID == 4 and data.categoryID == 7 and data.categoryID == 8 and data.categoryID == 9) then
					data.primary = random(1, 2400)
					data.secondary = miog.debugGetTestTier(data.primary)

				else
					data.primary = 0
					data.secondary = 0

				end
					
				averagePrimary = averagePrimary + data.primary
				averageSecondary = averageSecondary + data.secondary

				groupData[k] = data

			end
			
			averageItemLevel = averageItemLevel / numOfMembers
			averagePrimary = averagePrimary / numOfMembers
			averageSecondary = averageSecondary / numOfMembers
			averageRole = averageRole / numOfMembers

			if(multipleMembers) then
				parent = treeDataProvider:Insert({template = "MIOG_AppViewerApplicantTemplate", applicantID = i, debug = true, categoryID = categoryID, stale = stale, itemLevel = averageItemLevel, primary = averagePrimary, secondary = averageSecondary, role = averageRole, names = memberNames})

			else
				parent = treeDataProvider

			end

			for k = 1, numOfMembers do
				local singleMember = parent:Insert(groupData[k])
				singleMember:SetCollapsed(true, true, true)
				singleMember:Insert({template = "MIOG_NewRaiderIOInfoPanel", applicantID = i, name = playerName, realm = realm, debug = true})

			end
		end

	elseif(event == "LFG_LIST_APPLICANT_UPDATED") then
		local applicantID = ...
		local applicantData = C_LFGList.GetApplicantInfo(applicantID)

		if(applicantData) then
			local appStatus = applicantData.applicationStatus
			local frame = self:FindApplicantFrame(applicantID)

			if(appStatus == "timedout" or appStatus == "cancelled" or appStatus == "failed" or appStatus == "invitedeclined") then
				if(frame) then
					frame:SetStatus(appStatus)

				end
			elseif(appStatus == "declined") then
				if(frame) then
					self.ScrollBox:RemoveByPredicate(function(selfFrame, data)
						return selfFrame.applicantID == applicantID
					
					end)
				end
			end
		end
	elseif(event == "PARTY_LEADER_CHANGED") then
		local canInvite = miog.checkIfCanInvite()

		if(treeDataProvider) then
			for _, frame in self.ScrollBox:EnumerateFrames() do
				if(frame.Invite) then
					frame.Invite:SetShown(canInvite)
					frame.Decline:SetShown(canInvite)

				end
			end
		end
    end
end

local setupDone = false

function AppViewer:OnShow()
	if(not setupDone) then
		ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, miog.pveFrame2.ScrollBarArea.ApplicationViewerScrollBar, self.view);

		self.ScrollBox:SetDataProvider(treeDataProvider)
		self.SortButtons:RegisterDataProvider(treeDataProvider, "applicantID")

		setupDone = true
	end
end

function AppViewer:OnLoad()
	CallbackRegistryMixin.OnLoad(self)
    local view = Mixin(CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 8), TreeListViewMultiSpacingMixin)
	view:SetDepthSpacing()
    self.view = view

	local function Initializer(frame, node)
		local data = node:GetData()

		if(data.template == "MIOG_AppViewerApplicantMemberTemplate") then
			if(data.debug) then
				local localized, file, id = UnitClass("player")
				local specID = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
				local _, _, raceID = UnitRace("player")

				data.name = UnitName("player") .. data.debugIndex
				data.level = UnitLevel("player")
				data.fileName = file
				data.specID = specID
				data.comment = "YAYAYAYA"
				data.raceID = raceID

				frame:SetDebugData(data)

				if(data.stale) then
					--frame:SetStatus("cancelled")

				end
				
			else
				frame:SetData(data)

			end

		elseif(data.template == "MIOG_AppViewerApplicantTemplate") then
			frame:SetData(data)

			if(data.stale) then
				--frame:SetStatus("cancelled")

			end

		elseif(data.template == "MIOG_NewRaiderIOInfoPanel") then
			miog.updateRaiderIOScrollBoxFrameData(frame, data)

		end
	end
	
	local function CustomFactory(factory, node)
		local data = node:GetData()

		local template = data.template

		factory(template, Initializer)
	end
	
	view:SetElementFactory(CustomFactory)

	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
	self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
	self:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)
end