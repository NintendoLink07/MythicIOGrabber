local addonName, miog = ...

miog.debug = {}

miog.debug.currentAverageExecuteTime = {}
miog.debug.timer = nil

local wticc = WrapTextInColorCode

local calendarBacklog = {}
local calendarCoroutine = nil

local lastOffset, lastMonthDay, lastIndex
local framePool
local counter = 0

local function resetHolidayFrame(_, frame)
	frame:Hide()
	frame.layoutIndex = nil

	frame.Title:SetText()
	--frame.Date:SetText()
	frame.Icon:SetTexture(nil)

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()
end

local function requestCalendarEventInfo(offsetMonths, monthDay, numEvents)
	print("REQUEST STARTED")
	
	for i = 1, numEvents, 1 do
		lastOffset, lastMonthDay, lastIndex = offsetMonths, monthDay, i
		local success = C_Calendar.OpenEvent(offsetMonths, monthDay, i)

		--print(i)

		--if(success) then
			--print("YIELD")
			--coroutine.yield()
		--end
	end

	--CHECK FOR RESUME STATUS; DOESN'T WORK
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

		calendarCoroutine = coroutine.create(requestCalendarEventInfo)

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
			framePool = CreateFramePool("Frame", miog.MainTab.Information.Holiday, "MIOG_HolidayFrameTemplate", resetHolidayFrame)
		end

	elseif(event == "CALENDAR_UPDATE_EVENT_LIST") then
		--print("UPDATE CALENDAR")

		framePool:ReleaseAll()
		
		local numEvents = C_Calendar.GetNumDayEvents(0, 15)
		--print(numEvents)

		if(calendarCoroutine) then
			local status = coroutine.status(calendarCoroutine)

			--print(1, status)

			if(status == "dead") then
				calendarCoroutine = coroutine.create(requestCalendarEventInfo)
				coroutine.resume(calendarCoroutine, 0, 15, numEvents)

			end

			--print(2, status)
				
			if(status == "suspended") then
				coroutine.resume(calendarCoroutine, 0, 15, numEvents)

			end
		end

	elseif(event == "CALENDAR_UPDATE_EVENT") then
		print("UPDATE EVENT")

	elseif(event == "CALENDAR_OPEN_EVENT") then
		print("OPEN EVENT", ...)

		if(... == "HOLIDAY") then
			local info = C_Calendar.GetHolidayInfo(lastOffset, lastMonthDay, lastIndex)

			if(info and C_DateAndTime.CompareCalendarTime(C_DateAndTime.GetCurrentCalendarTime(), info.endTime) >= 0) then
				counter = counter + 1
				
				local cFrame = framePool:Acquire()
				cFrame:SetWidth(165)
				cFrame.layoutIndex = counter

				cFrame.Icon:SetTexture(info.texture)
				cFrame.Title:SetText(info.name)
				--cFrame.Date:SetText(info.startTime.monthDay .. "." .. info.startTime.month .. " - " .. info.endTime.monthDay .. "." .. info.endTime.month)

				cFrame:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
					GameTooltip:SetText(info.name, nil, nil, nil, nil, true)
					GameTooltip:AddLine("Start: " .. CalendarUtil.FormatCalendarTimeWeekday(info.startTime))
					GameTooltip:AddLine("End: " .. CalendarUtil.FormatCalendarTimeWeekday(info.endTime))
					GameTooltip:AddLine(info.description, 1, 1, 1, true)
					GameTooltip:Show()
				end)

				cFrame:Show()

				miog.MainTab.Information.Holiday:MarkDirty()
			end
		end

		if(calendarCoroutine) then
			--print("RESUME")
			--coroutine.resume(calendarCoroutine)
		end
		--[[	local numEvents = C_Calendar.GetNumDayEvents(0, 15)
			for i = 1, numEvents, 1 do
				local info = C_Calendar.GetHolidayInfo(0, 15, i)

				if(info) then
					print(info.name)
				
				end
			end
		end]]
		--local info = C_Calendar.GetEventInfo()

		--if(info) then
			--print(i, k, info.title)


		--end


	--IMPLEMENTING CALENDAR EVENTS IN VERSION 2.1


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