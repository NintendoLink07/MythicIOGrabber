local addonName, miog = ...

miog.debug = {}

miog.referencePVPButtons = {}

miog.debug.currentAverageExecuteTime = {}
miog.debug.timer = nil

local function createBaseCategoryFrame(categoryID, index, canUseLFG, failureReason)
	local categoryFrame = miog.pveFrame2.categoryFramePool:Acquire()

	categoryFrame.categoryID = categoryID
	categoryFrame:SetFrameStrata("FULLSCREEN")

	categoryFrame:SetSize(140, 20)
	categoryFrame.layoutIndex = index
	categoryFrame.BackgroundImage:SetVertTile(true)
	categoryFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], nil, "CLAMPTOBLACKADDITIVE")
	categoryFrame.BackgroundImage:SetDesaturated(not canUseLFG)

	miog.createFrameBorder(categoryFrame, 1, CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())

	categoryFrame:SetScript("OnShow", function(self)
		if(not canUseLFG) then
			self:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(failureReason)
				GameTooltip:Show()
			end)
			self:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
		else
			self:SetScript("OnClick", function()
				self:GetParent().setupFunction(self)
				self:GetParent():Hide()
			end)
		
		end
	end)

	return categoryFrame
end


miog.OnEvent = function(_, event, ...)
	if(event == "PLAYER_LOGIN") then
		miog.C.AVAILABLE_ROLES["TANK"], miog.C.AVAILABLE_ROLES["HEALER"], miog.C.AVAILABLE_ROLES["DAMAGER"] = UnitGetAvailableRoles("player")
		
		miog.checkForSavedSettings()

		miog.F.LITE_MODE = MIOG_SavedSettings.liteMode.value

		miog.createFrames()

		miog.loadSettings()
		miog.loadRawData()
		
		EJ_SetDifficulty(8)

		--LFGListFrame.ApplicationViewer:HookScript("OnShow", function(self) self:Hide() miog.ApplicationViewer:Show() end)
		--LFGListFrame.SearchPanel:HookScript("OnShow", function(self) miog.SearchPanel:Show() end)

		if(C_AddOns.IsAddOnLoaded("RaiderIO")) then
			miog.F.IS_RAIDERIO_LOADED = true

			if(not miog.F.LITE_MODE) then
				miog.pveFrame2.TitleBar.RaiderIOLoaded:Hide()
			end

		end

		if(C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards")) then
			miog.MainTab.MPlusStatus = Mixin(miog.MainTab.MPlusStatus, WeeklyRewardsActivityMixin)
			miog.MainTab.HonorStatus = Mixin(miog.MainTab.HonorStatus, WeeklyRewardsActivityMixin)
			miog.MainTab.RaidStatus = Mixin(miog.MainTab.RaidStatus, WeeklyRewardsActivityMixin)

		end
		
		for k, v in pairs(miog.SPECIALIZATIONS) do
			if(k > 25) then
				local _, localizedName, _, _, _, fileName = GetSpecializationInfoByID(k)

				if(localizedName == "") then
					localizedName = "Initial"
				end

				miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[localizedName .. "-" .. fileName] = k
			end
		end
		
		if(not miog.F.LITE_MODE) then
			PVPUIFrame:HookScript("OnShow", function()
				ConquestFrame.selectedButton = nil
				ConquestFrame.RatedBG.SelectedTexture:Hide()
				--ConquestFrame.ratedSoloShuffleEnabled = false
				--ConquestFrame.arenasEnabled = false
			end)
			
			hooksecurefunc("HonorFrame_InitSpecificButton", function(button, elementData)
				button:SetHeight(40)
				button.Bg:Hide()
				button.Border:Hide()
				button.Icon:Hide()
				button.InfoText:Hide()
				--button.SelectedTexture:Hide()

				button:SetNormalAtlas("pvpqueue-button-casual-up")
				button:SetPushedAtlas("pvpqueue-button-casual-down")
				button:SetHighlightAtlas("pvpqueue-button-casual-highlight", "ADD")

				button.SizeText:ClearAllPoints()
				button.SizeText:SetFont("SystemFont_Shadow_Med1", 11, "OUTLINE")
				button.SizeText:SetPoint("LEFT", button, "LEFT", 5, 0)

				button.NameText:ClearAllPoints()
				button.NameText:SetFont("SystemFont_Shadow_Med1", 11, "OUTLINE")
				button.NameText:SetTextColor(1, 1, 1, 1)
				button.NameText:SetPoint("LEFT", button.SizeText, "RIGHT", 5, 0)
			end)
		end

	elseif(event == "CHALLENGE_MODE_MAPS_UPDATE") then
		if(not miog.F.ADDED_DUNGEON_FILTERS) then
			local currentSeason = C_MythicPlus.GetCurrentSeason()

			miog.F.CURRENT_SEASON = currentSeason
			miog.F.PREVIOUS_SEASON = currentSeason - 1

			miog.updateDungeonCheckboxes()
			miog.updateRaidCheckboxes()

		end

		if(miog.F.MPLUS_SETUP_COMPLETE) then
			miog.gatherMPlusStatistics()
		end

    elseif(event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
		if(miog.F.WEEKLY_AFFIX == nil) then
			C_MythicPlus.GetCurrentAffixes() -- Safety call, so Affixes are 100% available

			miog.F.AFFIX_INFO[9] = {C_ChallengeMode.GetAffixInfo(9)} --TYRA
			miog.F.AFFIX_INFO[10] = {C_ChallengeMode.GetAffixInfo(10)} --FORT
			
			miog.setAffixes()
			
			if(miog.F.MPLUS_SETUP_COMPLETE) then
				miog.gatherMPlusStatistics()
			end
        end
	elseif(event == "GROUP_ROSTER_UPDATE") then
		miog.openRaidLib.RequestKeystoneDataFromParty()
		
	elseif(event == "PLAYER_REGEN_DISABLED") then
		HideUIPanel(miog.pveFrame2)
		
		miog.F.QUEUE_STOP = true

	elseif(event == "PLAYER_REGEN_ENABLED") then
		miog.F.QUEUE_STOP = false

	elseif(event == "LFG_LIST_AVAILABILITY_UPDATE") then
		if(C_LFGList.HasActiveEntryInfo() and not miog.EntryCreation:IsVisible()) then
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
		
			miog.startNewGroup({categoryID = activityInfo.categoryID, filters = activityInfo.filters})
		end

		if(not miog.F.LITE_MODE) then
			local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();

			local index = 0
			
			miog.pveFrame2.categoryFramePool:ReleaseAll()

			for _, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
				index = index + 1

				local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)

				local categoryFrame = createBaseCategoryFrame(categoryID, index, canUse, failureReason)
				categoryFrame.filters = categoryID == 1 and 4 or Enum.LFGListFilter.Recommended
				categoryFrame.Title:SetText(categoryInfo.name)
				categoryFrame:Show()

				if(categoryInfo.separateRecommended) then
					index = index + 1

					local nonRecommendedFrame = createBaseCategoryFrame(categoryID, index, canUse)
					nonRecommendedFrame.filters = categoryInfo.separateRecommended and Enum.LFGListFilter.NotRecommended
					nonRecommendedFrame.Title:SetText(LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, true))
					nonRecommendedFrame:Show()
					
				end
			end

			miog.pveFrame2.CategoryHoverFrame:MarkDirty()

		end

	end
end


SLASH_MIOG1 = '/miog'
local function handler(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if(command == "") then

	elseif(command == "options") then
		MIOG_OpenInterfaceOptions()

	elseif(command == "debugon_av") then
		if(IsInGroup()) then
			miog.F.IS_IN_DEBUG_MODE = true
			print("Debug mode on - No standard applicants coming through")

			--PVEFrame:Show()
			--LFGListFrame:Show()
			--LFGListPVEStub:Show()
			--LFGListFrame.ApplicationViewer:Show()

			LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)

			miog.createFullEntries(33)

			miog.ApplicationViewer:Show()
		end
	elseif(command == "debugon_av_self") then
		if(IsInGroup()) then
			miog.F.IS_IN_DEBUG_MODE = true
			print("Debug mode on - No standard applicants coming through")

			--PVEFrame:Show()
			--LFGListFrame:Show()
			--LFGListPVEStub:Show()
			--LFGListFrame.ApplicationViewer:Show()

			LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)

			miog.createAVSelfEntry(rest)

			miog.ApplicationViewer:Show()
		end
	elseif(command == "debugoff_av") then
		miog.releaseApplicantFrames()
		miog.resetArrays()

	elseif(command == "debugon") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

	elseif(command == "debugoff") then
		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false

	elseif(command == "debug_av_perfstart") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

		local index = 1
		local tickRate = 0.2
		local numberOfEntries = 33
		local testLength = (tonumber(rest) or 10) / tickRate -- in seconds

		miog.debug.currentAverageExecuteTime = {}

		miog.debug.debugTimer = C_Timer.NewTicker(tickRate, function(self)

			miog.createFullEntries(numberOfEntries)

			print(miog.debug.currentAverageExecuteTime[#miog.debug.currentAverageExecuteTime])

			index = index + 1

			if(index == testLength) then
				self:Cancel()

				local avg = 0

				for _, v in ipairs(miog.debug.currentAverageExecuteTime) do
					avg = avg + v
				end

				print("Avg exec time: "..(avg / #miog.debug.currentAverageExecuteTime))

				print("Debug mode off - Normal applicant mode")
				miog.F.IS_IN_DEBUG_MODE = false
				miog.releaseApplicantFrames()
				miog.resetArrays()
			end
		end)

	elseif(command == "debug_av_perfstop") then
		if(miog.debug.debugTimer) then
			miog.debug.debugTimer:Cancel()

			local avg = 0

			for _,v in ipairs(miog.debug.currentAverageExecuteTime) do
				avg = avg + v
			end

			print("Avg exec time: "..avg / #miog.debug.currentAverageExecuteTime)
		end

		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false
		miog.releaseApplicantFrames()
		miog.resetArrays()

	elseif(command == "debug_sp_perfstart") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

		local index = 1
		local tickRate = 0.2
		local testLength = (tonumber(rest) or 10) / tickRate -- in seconds

		miog.debug.currentAverageExecuteTime = {}

		miog.debug.debugTimer = C_Timer.NewTicker(tickRate, function(self)

			local startTime = GetTimePreciseSec()
			miog.updateSearchResultList(true)
			local endTime = GetTimePreciseSec()
		
			miog.debug.currentAverageExecuteTime[#miog.debug.currentAverageExecuteTime+1] = endTime - startTime

			print(miog.debug.currentAverageExecuteTime[#miog.debug.currentAverageExecuteTime])

			index = index + 1

			if(index == testLength) then
				self:Cancel()

				local avg = 0

				for _, v in ipairs(miog.debug.currentAverageExecuteTime) do
					avg = avg + v
				end

				print("Avg exec time: "..(avg / #miog.debug.currentAverageExecuteTime))

				print("Debug mode off - Normal search result mode")
				miog.F.IS_IN_DEBUG_MODE = false
			end
		end)

	elseif(command == "debug_sp_perfstop") then
		if(miog.debug.debugTimer) then
			miog.debug.debugTimer:Cancel()

			local avg = 0

			for _,v in ipairs(miog.debug.currentAverageExecuteTime) do
				avg = avg + v
			end

			print("Avg exec time: "..avg / #miog.debug.currentAverageExecuteTime)
		end

		print("Debug mode off - Normal search result mode")
		miog.F.IS_IN_DEBUG_MODE = false

	elseif(command == "favour") then

		local nameTable = miog.simpleSplit(rest, "-")

		if(not nameTable[2]) then
			nameTable[2] = GetNormalizedRealmName()

			rest = nameTable[1] .. "-" .. nameTable[2]

		end

		MIOG_SavedSettings.favouredApplicants.table[rest] = {name = nameTable[1], fullName = rest}
	
	else
		--miog.ApplicationViewer:Show()

	end
end
SlashCmdList["MIOG"] = handler