local addonName, miog = ...

miog.debug = {}

miog.referencePVPButtons = {}

miog.debug.currentAverageExecuteTime = {}
miog.debug.timer = nil

miog.OnEvent = function(_, event, ...)
	if(event == "PLAYER_LOGIN") then
        miog.F.CURRENT_DATE = C_DateAndTime.GetCurrentCalendarTime()

		miog.C.AVAILABLE_ROLES["TANK"], miog.C.AVAILABLE_ROLES["HEALER"], miog.C.AVAILABLE_ROLES["DAMAGER"] = UnitGetAvailableRoles("player")

		if(C_AddOns.IsAddOnLoaded("RaiderIO")) then
			miog.F.IS_RAIDERIO_LOADED = true

		end
		miog.loadNewSettings()
		
		miog.loadRawData()

		miog.createFrames()

		miog.loadNewSettingsAfterFrames()
		
		EJ_SetDifficulty(8)
		
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
			miog.insertGearingData()

			if(PVPUIFrame) then
				PVPUIFrame:HookScript("OnShow", function()
					--ConquestFrame.selectedButton = nil
					--ConquestFrame.RatedBG.SelectedTexture:Hide()
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
		end
	elseif(event == "PLAYER_ENTERING_WORLD") then
		C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()

	elseif(event == "CHALLENGE_MODE_MAPS_UPDATE") then
		--[[if(miog.F.MPLUS_SETUP_COMPLETE) then
			miog.gatherMPlusStatistics()
		end]]

    elseif(event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
		C_MythicPlus.GetCurrentAffixes() -- Safety call, so Affixes are 100% available
		miog.setAffixes()
		
	elseif(event == "GROUP_ROSTER_UPDATE") then
		--miog.openRaidLib.RequestKeystoneDataFromParty()
	
	elseif(event == "CURRENCY_DISPLAY_UPDATE") then
		if(miog.MainTab) then
			miog.updateCurrencies()
		end

	elseif(event == "ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED") then
		--miog.getAccountCharacters()
		
	elseif(event == "PLAYER_REGEN_DISABLED") then
		if(miog.MainFrame:IsShown()) then
			miog.F.MAINFRAME_WAS_VISIBLE = true
			miog.MainFrame:Hide()
			
		end
	elseif(event == "PLAYER_REGEN_ENABLED") then
		if(miog.F.MAINFRAME_WAS_VISIBLE) then
			miog.F.MAINFRAME_WAS_VISIBLE = false
			miog.MainFrame:Show()

		end
	elseif(event == "LFG_LIST_AVAILABILITY_UPDATE") then
		if(C_LFGList.HasActiveEntryInfo() and not miog.EntryCreation:IsVisible()) then
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityIDs[1])

			LFGListEntryCreation_ClearAutoCreateMode(LFGListFrame.EntryCreation);

			--local isDifferentCategory = LFGListFrame.CategorySelection.selectedCategory ~= categoryFrame.categoryID
			--local isSeparateCategory = C_LFGList.GetLfgCategoryInfo(categoryFrame.categoryID).separateRecommended

			LFGListFrame.CategorySelection.selectedCategory = activityInfo.categoryID
			LFGListFrame.CategorySelection.selectedFilters = activityInfo.filters

			LFGListSearchPanel_SetCategory(LFGListFrame.SearchPanel, activityInfo.categoryID, activityInfo.filters, LFGListFrame.baseFilters)

			LFGListEntryCreation_SetBaseFilters(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters)
			--LFGListEntryCreation_Select(LFGListFrame.EntryCreation, LFGListFrame.CategorySelection.selectedFilters, LFGListFrame.CategorySelection.selectedCategory);
			
			miog.initializeActivityDropdown()
		end

	elseif(event == "CHALLENGE_MODE_START") then
		miog.increaseStatistic("CHALLENGE_MODE_START")

	elseif(event == "CHALLENGE_MODE_RESET") then
		miog.increaseStatistic("CHALLENGE_MODE_RESET")

	elseif(event == "CHALLENGE_MODE_COMPLETED") then
		miog.increaseStatistic("CHALLENGE_MODE_COMPLETED")

	elseif(event == "WEEKLY_REWARDS_UPDATE") then
		ProgressTabMixin:UpdateAllCharacterStatistics(true, true, true)

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
			miog.fullyUpdateSearchPanel()
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

        local playerName, realm = miog.createSplitName(rest)

		MIOG_NewSettings.favouredApplicants[rest] = {name = playerName, fullName = rest}

	end
end
SlashCmdList["MIOG"] = handler