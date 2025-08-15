local addonName, miog = ...

miog.openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

miog.debug = {}

miog.referencePVPButtons = {}

miog.debug.currentAverageExecuteTime = {}
miog.debug.timer = nil

local miogPlayers = {}

local function printMIOGPlayers(...)
	local prefix, text, channel, sender = ...

	if(prefix == "MIOG_DEBUG" and not miogPlayers[sender] and not sender == UnitFullName("player")) then
		print("Found a MIOG player: " .. sender)
		miogPlayers[sender] = true
	end
end

local function mainEvents(_, event, ...)
	if(event == "PLAYER_LOGIN") then
        miog.F.CURRENT_DATE = C_DateAndTime.GetCurrentCalendarTime()

		miog.loadNewSettings()
		miog.loadRawData()
		miog.createFrames()
		
		if(C_LFGList.HasActiveEntryInfo()) then
			miog.setActivePanel(nil, LFGListFrame.ApplicationViewer)

		end

		--LFGListFrame.ApplicationViewer.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, function() GameTooltip:Hide() end)

	elseif(event == "PLAYER_ENTERING_WORLD") then
		miog.addTeleportButtons()
		--miog.recheckJournalInstanceIDs()
		miog.checkAllSeasonalMapIDs()
		
		if(miog.pveFrame2) then
			miog.MainFrame.TitleBar.RaiderIOLoaded:SetShown(not C_AddOns.IsAddOnLoaded("RaiderIO"))

		end

		if(MIOG_NewSettings.raidToDungeonGraphics) then
			if (C_CVar.GetCVar("RAIDsettingsEnabled")) then
				local _, type = GetInstanceInfo()

				if(type == "party") then
					if(GetCurrentGraphicsSetting() == 0) then
						SetCurrentGraphicsSetting(1)

					end

					UIErrorsFrame:AddExternalWarningMessage("[MIOG]: " .. GRAPHICS_SETTING_RAID_NOTICE)
				end
			end

		end
		--[[local isLogin, isReload = ...

		if(isLogin or isReload) then
			local accInfo = C_BattleNet.GetAccountInfoByGUID(UnitGUID("player"))
			if(accInfo and accInfo.battleTag == "Rhany#21903") then
				--miog.AceComm:RegisterComm("MIOG_DEBUG", printMIOGPlayers)

			end
		end]]

    elseif(event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
		C_MythicPlus.GetCurrentAffixes() -- Safety call, so Affixes are 100% available
		miog.setAffixes()
	
	elseif(event == "CURRENCY_DISPLAY_UPDATE") then
		if(miog.MainTab) then
			miog.updateCurrencies()
		end
		
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
		if(C_LFGList.HasActiveEntryInfo()) then
			if(miog.EntryCreation and not miog.EntryCreation:IsVisible()) then
				local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
				local activityInfo = miog.requestActivityInfo(activeEntryInfo.activityIDs[1])

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
		end

	elseif(event == "CHALLENGE_MODE_START") then
		miog.increaseStatistic("CHALLENGE_MODE_START")

	elseif(event == "CHALLENGE_MODE_RESET") then
		miog.increaseStatistic("CHALLENGE_MODE_RESET")

	elseif(event == "CHALLENGE_MODE_COMPLETED") then
		miog.increaseStatistic("CHALLENGE_MODE_COMPLETED")

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

	end
end
SlashCmdList["MIOG"] = handler

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_EventReceiver")
eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
eventReceiver:RegisterEvent("PLAYER_LOGIN")
eventReceiver:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
eventReceiver:RegisterEvent("PLAYER_REGEN_DISABLED")
eventReceiver:RegisterEvent("PLAYER_REGEN_ENABLED")
eventReceiver:RegisterEvent("LFG_LIST_AVAILABILITY_UPDATE")
eventReceiver:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
eventReceiver:RegisterEvent("OPEN_RECIPE_RESPONSE")

eventReceiver:RegisterEvent("CHALLENGE_MODE_START")
eventReceiver:RegisterEvent("CHALLENGE_MODE_RESET")
eventReceiver:RegisterEvent("CHALLENGE_MODE_COMPLETED")

eventReceiver:RegisterEvent("WEEKLY_REWARDS_UPDATE")

eventReceiver:SetScript("OnEvent", mainEvents)