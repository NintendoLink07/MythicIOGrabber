local addonName, miog = ...
local longestHoliday

local function sortCalendarDates(k1, k2)
    return k1.timeTillEnd < k2.timeTillEnd
end

local function requestCalendarEventInfo(offsetMonths, monthDay, numEvents)
    local dataProvider = CreateDataProvider()

    longestHoliday = 0

	for i = 1, numEvents, 1 do
        local info = C_Calendar.GetHolidayInfo(offsetMonths, monthDay, i)

        if(info and info.endTime and C_DateAndTime.CompareCalendarTime(C_DateAndTime.GetCurrentCalendarTime(), info.endTime) >= 0 and C_DateAndTime.CompareCalendarTime(C_DateAndTime.GetCurrentCalendarTime(), info.startTime) < 0) then
            local endTimeSeconds = time({year = info.endTime.year, month = info.endTime.month, day = info.endTime.monthDay, hour = info.endTime.hour, minute = info.endTime.minute})
            local timeTillEnd = endTimeSeconds - time()

            info.endTimeSeconds = endTimeSeconds
            info.timeTillEnd = timeTillEnd
            dataProvider:Insert(info)

            longestHoliday = timeTillEnd > longestHoliday and timeTillEnd or longestHoliday
        end
	end
    
    dataProvider:SetSortComparator(sortCalendarDates)
    miog.MainTab.Information.HolidayScrollBox:SetDataProvider(dataProvider)
end

local function calendarOnEvent(_, event, ...)
    if(event == "CALENDAR_UPDATE_EVENT_LIST") then
        local currentTime = miog.F.CURRENT_DATE or C_DateAndTime.GetCurrentCalendarTime()
        local offset = 0

        local monthInfo = C_Calendar.GetMonthInfo(0)

        offset = currentTime.month - monthInfo.month

        local numEvents = C_Calendar.GetNumDayEvents(offset, currentTime.monthDay)

        requestCalendarEventInfo(offset, currentTime.monthDay, numEvents)
    end
end

miog.calendarOnEvent = calendarOnEvent

miog.loadCalendarSystem = function()
    local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_CalendarEventReceiver")
    
    eventReceiver:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    eventReceiver:RegisterEvent("CALENDAR_UPDATE_EVENT")
    eventReceiver:RegisterEvent("CALENDAR_OPEN_EVENT");
	eventReceiver:RegisterEvent("CALENDAR_UPDATE_ERROR");
	eventReceiver:RegisterEvent("CALENDAR_UPDATE_ERROR_WITH_COUNT");
	eventReceiver:RegisterEvent("CALENDAR_UPDATE_ERROR_WITH_PLAYER_NAME");
    
    eventReceiver:SetScript("OnEvent", calendarOnEvent)

    local horizontalView = CreateScrollBoxListLinearView()

    horizontalView:SetElementInitializer("MIOG_HolidayFrameTemplate", function(frame, data)
        frame.DateBar.Title:SetText(data.name)

        local startTimeSeconds = time({year = data.startTime.year, month = data.startTime.month, day = data.startTime.monthDay, hour = data.startTime.hour, minute = data.startTime.minute})
        local totalDurationInSeconds = data.endTimeSeconds - startTimeSeconds
        local currentProgress = time() - startTimeSeconds

        local formatter = CreateFromMixins(SecondsFormatterMixin)
        formatter:SetStripIntervalWhitespace(true)
        formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter)
        
        local timeTillEndPerc = currentProgress / totalDurationInSeconds
        local progressDependingOnLongestHoliday = data.timeTillEnd / longestHoliday

        frame.DateBar:SetStatusBarColor(1 - progressDependingOnLongestHoliday, progressDependingOnLongestHoliday, 0, 1)
        frame.DateBar:SetMinMaxValues(0, 1)
        frame.DateBar:SetValue(data.timeTillEnd / longestHoliday)

        frame.DateBar.Title:SetText(frame.DateBar.Title:GetText() .. ": " .. formatter:Format(data.timeTillEnd))

        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(data.name, nil, nil, nil, nil, true)
            GameTooltip:AddLine(string.format(MONTHLY_ACTIVITIES_DAYS, formatter:Format(data.timeTillEnd)))
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            GameTooltip:AddLine("Start: " .. date("%x - %X", startTimeSeconds))
            GameTooltip:AddLine("End: " .. date("%x - %X", data.endTimeSeconds))

            if(data.description ~= "") then
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                GameTooltip:AddLine(data.description, 1, 1, 1, true)
            end

            GameTooltip:Show()
        end)
    end)
    horizontalView:SetPadding(1, 1, 1, 1, 4)
    miog.MainTab.Information.HolidayScrollBox:Init(horizontalView)
end
