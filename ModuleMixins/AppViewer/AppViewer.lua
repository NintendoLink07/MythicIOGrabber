local addonName, miog = ...
local wticc = WrapTextInColorCode
local dataProvider = CreateTreeDataProvider()

local categoryID

AppViewer = {}

function AppViewer:FindApplicantFrame(applicantID)
	local frame = miog.SearchPanel.ScrollBox2:FindFrameByPredicate(function(localFrame, node)
		return node.applicantID == applicantID

	end)

	return frame
end

function AppViewer:RefreshApplicantList()
    local applicantList = C_LFGList.GetApplicants()
	local activeEntry = C_LFGList.GetActiveEntryInfo()

	dataProvider:Flush()

	local multiMember

    for index, applicantID in ipairs(applicantList) do
        local applicantData = C_LFGList.GetApplicantInfo(applicantID)
		local memberNames = {}

		if(applicantData.numMembers > 1) then
			multiMember = dataProvider:Insert({template = "MIOG_AppViewerApplicantTemplate", debug = true, categoryID = categoryID, names = memberNames})

		else
			multiMember = nil

		end

		for k = 1, applicantData.numMembers do
			local name, class, localizedClass, level, itemLevel, honorlevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, faction, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(applicantID, k)
            tinsert(memberNames, {name = name, class = class})

			local primary, secondary
			local fullName, playerName, realm = miog.createFullNameValuesFrom("unitName", name)
			local playerDifficultyData

			if(categoryID == 2) then
				primary = dungeonScore
				secondary = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, 1, activeEntry.activityIDs[1]).bestRunLevel
				
			elseif(categoryID == 3) then
				playerDifficultyData = miog.getWeightFromRaidProgress(playerName, realm)
				primary, secondary = miog.getWeightFromRaidProgress(playerDifficultyData)
			
			elseif(categoryID == 4 or categoryID == 7 or categoryID == 8 or categoryID == 9) then
				local pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, 1, activeEntry.activityIDs[1])

				primary = pvpRatingInfo.rating
				secondary = pvpRatingInfo.bracket

			else
				primary = 0
				secondary = 0

			end

			local member = (multiMember or dataProvider):Insert({
				template = "MIOG_AppViewerApplicantMemberTemplate",
				applicantID = applicantID,
				applicantIndex = k,
				comment = applicantData.comment,
				categoryID = categoryID,
				primary = primary,
				secondary = secondary,
				raidData = playerDifficultyData,
				itemLevel = itemLevel,
			})

			member:Insert({template = "MIOG_NewRaiderIOInfoPanel", applicantID = applicantID, name = playerName, realm = realm, debug = true})

		end
    end
    
    --name, class, _, _, itemLevel, _, tank, healer, damager, assignedRole, relationship, dungeonScore, _, _, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(applicantID, applicantIndex)
    --dungeonData = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, applicantIndex, activityID)
    --pvpData = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantID, applicantIndex, activityID)

end

function AppViewer:OnEvent(event, ...)
    print(event, ...)

    if(event == "LFG_LIST_ACTIVE_ENTRY_UPDATE") then
		local justCreated = ...

		if(justCreated) then
			self.ScrollBox:Flush()
			
		end

        local activeEntry = C_LFGList.GetActiveEntryInfo()

        if(activeEntry) then
            local activityInfo = C_LFGList.GetActivityInfoTable(activeEntry.activityIDs[1])
			categoryID = miog.requestActivityInfo(activeEntry.activityIDs[1]).categoryID

            self.ActivityBar.Title:SetText(activityInfo.fullName)
            self.ActivityBar.Name:SetText(activeEntry.name)
            self.ActivityBar.Description:SetText(activeEntry.comment)

        end

    elseif(event == "LFG_LIST_APPLICANT_LIST_UPDATED") then
        self:RefreshApplicantList()

		local fullName, playerName, realm = miog.createFullNameValuesFrom("unitName", UnitName("player"))

		for i = 1, 10 do
			local groupData = {}

			local stale = random(1, 100) > 70

			local multipleMembers = random(1, 100) > 80
			local numOfMembers = multipleMembers and random(2,4) or 1
			local averageItemLevel = 0

			local memberNames = {}
			local parent

			for k = 1, numOfMembers do
				local itemLevel = GetAverageItemLevel() + random(-4, 4)
				averageItemLevel = averageItemLevel + itemLevel

				local localized, file, id = UnitClass("player")
				tinsert(memberNames, {name = playerName .. k, class = file})

				groupData[k] = {
					template = "MIOG_AppViewerApplicantMemberTemplate",
					applicantID = i,
					debug = true,
					categoryID = categoryID,
					stale = stale,
					multi = multipleMembers,
					debugIndex = i,
					itemLevel = itemLevel,
				}

			end
			
			averageItemLevel = averageItemLevel / numOfMembers

			if(multipleMembers) then
				parent = dataProvider:Insert({template = "MIOG_AppViewerApplicantTemplate", applicantID = i, debug = true, categoryID = categoryID, stale = stale, itemLevel = averageItemLevel, names = memberNames})

			else
				parent = dataProvider

			end

			-- sort tree data?

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

		if(dataProvider) then
			for _, frame in self.ScrollBox:EnumerateFrames() do
				if(frame.Invite) then
					frame.Invite:SetShown(canInvite)
					frame.Decline:SetShown(canInvite)

				end
			end
		end
    end
end

function AppViewer:OnShow()
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, miog.pveFrame2.ScrollBarArea.ApplicationViewerScrollBar, self.view);

	self.ScrollBox:SetDataProvider(dataProvider)
	self.SortButtons:RegisterDataProvider(dataProvider)
end

function AppViewer:OnLoad()
    local view = Mixin(CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 8), TreeListViewMultiSpacingMixin)
	view:SetDepthSpacing()
    self.view = view

	local function Initializer(frame, node)
		local data = node:GetData()

		frame.node = node

		if(data.template == "MIOG_AppViewerApplicantMemberTemplate") then
			if(data.debug) then
				local localized, file, id = UnitClass("player")
				local specID, _, _, _, assignedRole = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
				local _, _, raceID = UnitRace("player")

				data.name = UnitName("player") .. data.debugIndex
				data.level = UnitLevel("player")
				data.fileName = file
				data.specID = specID
				data.comment = "YAYAYAYA"
				data.raceID = raceID
				data.assignedRole = assignedRole

				if(data.categoryID == 2) then
					data.primary = C_ChallengeMode.GetOverallDungeonScore()
				
					local rioProfile = RaiderIO.GetProfile("player")
					
					if(rioProfile and rioProfile.mythicKeystoneProfile) then
						data.secondary = rioProfile.mythicKeystoneProfile.maxDungeonLevel

					else
						data.secondary = 0

					end
					
				elseif(data.categoryID == 3) then
					local fullName, playerName, realm = miog.createFullNameValuesFrom("unitName", UnitName("player"))
					local raidData = miog.getRaidProgress(playerName, realm)

					data.raidData = raidData

					if(raidData) then
						data.primary, data.secondary, data.primary2, data.secondary2 = miog.getWeightAndAliasesFromRaidProgress(raidData)

					else
						data.primary = 0
						data.secondary = 0
						data.primary2 = "0/0"
						data.secondary = "0/0"

					end

				elseif(data.categoryID == 4 and data.categoryID == 7 and data.categoryID == 8 and data.categoryID == 9) then
					data.primary = random(1, 2400)
					data.secondary = miog.debugGetTestTier(data.primary)

				else
					data.primary = ""
					data.secondary = ""

				end

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