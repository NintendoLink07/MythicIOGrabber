local addonName, miog = ...

miog.debug = {}

miog.debug.currentAverageExecuteTime = {}
miog.debug.timer = nil

local wticc = WrapTextInColorCode

local calendarBacklog = {}

miog.OnEvent = function(_, event, ...)
	if(event == "PLAYER_LOGIN") then
		miog.C.AVAILABLE_ROLES["TANK"], miog.C.AVAILABLE_ROLES["HEALER"], miog.C.AVAILABLE_ROLES["DAMAGER"] = UnitGetAvailableRoles("player")
		
		miog.checkForSavedSettings()
		miog.createFrames()
		miog.loadSettings()
		miog.loadRawData()
		
		EJ_SetDifficulty(8)

		--LFGListFrame.ApplicationViewer:HookScript("OnShow", function(self) self:Hide() miog.applicationViewer:Show() end)
		--LFGListFrame.SearchPanel:HookScript("OnShow", function(self) miog.searchPanel:Show() end)

		if(C_AddOns.IsAddOnLoaded("RaiderIO")) then
			miog.F.IS_RAIDERIO_LOADED = true

			miog.pveFrame2.TitleBar.RaiderIOLoaded:Hide()

		end
		
		for k, v in pairs(miog.SPECIALIZATIONS) do
			if(k > 25) then
				local _, localizedName, _, _, _, fileName = GetSpecializationInfoByID(k)

				miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[localizedName .. "-" .. fileName] = k
			end
		end

	--elseif(event == "CALENDAR_UPDATE_EVENT_LIST") then
		--[[print("UPDATE CALENDAR")

		local day = 12

		for i = day, day + 14, 1 do
			local numEvents = C_Calendar.GetNumDayEvents(0, i)

			for k = 1, numEvents, 1 do
				local success = C_Calendar.OpenEvent(0, day, k)

				if(success) then
					tinsert(calendarBacklog, {i, k})
				end
			end
		end

	elseif(event == "CALENDAR_OPEN_EVENT") then
		local info = C_Calendar.GetEventInfo()

		if(info) then
			print(i, k, info.title)


		end


	--IMPLEMENTING CALENDAR EVENTS IN VERSION 2.1


]]
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
		if(not miog.F.WEEKLY_AFFIX) then
			C_MythicPlus.GetCurrentAffixes() -- Safety call, so Affixes are 100% available

			if(miog.applicationViewer and miog.applicationViewer.InfoPanel) then
				miog.setAffixes()

			end

        end
	elseif(event == "GROUP_ROSTER_UPDATE") then
		miog.openRaidLib.RequestKeystoneDataFromParty()

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

			miog.applicationViewer:Show()
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

			miog.applicationViewer:Show()
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
		--miog.applicationViewer:Show()

	end
end
SlashCmdList["MIOG"] = handler