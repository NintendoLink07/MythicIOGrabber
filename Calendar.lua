local addonName, miog = ...

local wticc = WrapTextInColorCode

local calendarCoroutine = nil

local framePool
local counter = 0

local function resetHolidayFrame(_, frame)
	frame:Hide()
	frame.layoutIndex = nil

	frame.DateBar.Title:SetText()
	frame.Icon:SetTexture(nil)

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()
end

local function requestCalendarEventInfo(offsetMonths, monthDay, numEvents)
	for i = 1, numEvents, 1 do
        local info = C_Calendar.GetHolidayInfo(offsetMonths, monthDay, i)

        if(info and info.endTime and C_DateAndTime.CompareCalendarTime(C_DateAndTime.GetCurrentCalendarTime(), info.endTime) >= 0 and C_DateAndTime.CompareCalendarTime(C_DateAndTime.GetCurrentCalendarTime(), info.startTime) < 0) then
            counter = counter + 1
            
            local cFrame = framePool:Acquire()
            cFrame:SetWidth(165)
            cFrame.layoutIndex = counter

            cFrame.Icon:SetTexture(info.texture)
            cFrame.Icon:SetTexCoord(0, 0.70, 0, 0.70)
            cFrame.DateBar.Title:SetText(info.name)
            
            local startTimeSeconds = time({year = info.startTime.year, month = info.startTime.month, day = info.startTime.monthDay, hour = info.startTime.hour, minute = info.startTime.minute})
            local endTimeSeconds = time({year = info.endTime.year, month = info.endTime.month, day = info.endTime.monthDay, hour = info.endTime.hour, minute = info.endTime.minute})
            local totalDurationInSeconds = endTimeSeconds - startTimeSeconds
            local currentProgress = time() - startTimeSeconds
            local timeTillEnd = endTimeSeconds - time()

            local formatter = CreateFromMixins(SecondsFormatterMixin)
            formatter:SetStripIntervalWhitespace(true)
            formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter)
            
            local timeTillEndPerc = currentProgress / totalDurationInSeconds

            cFrame.DateBar:SetStatusBarColor(timeTillEndPerc, 1 - timeTillEndPerc, 0, 1)
            cFrame.DateBar:SetMinMaxValues(0, 1)
            cFrame.DateBar:SetValue(timeTillEndPerc)

            cFrame.DateBar.Title:SetText(cFrame.DateBar.Title:GetText() .. ": " .. formatter:Format(timeTillEnd))

            cFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, nil, nil, nil, nil, true)
                GameTooltip:AddLine("Start: " .. CalendarUtil.FormatCalendarTimeWeekday(info.startTime))
                GameTooltip:AddLine("End: " .. CalendarUtil.FormatCalendarTimeWeekday(info.endTime))

                if(info.description ~= "") then
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    GameTooltip:AddLine(info.description, 1, 1, 1, true)
                end

                GameTooltip:Show()
            end)

            cFrame:Show()

            miog.MainTab.Information.Holiday:MarkDirty()
        end
	end
end

local function calendarOnEvent(_, event, ...)
    if(event == "CALENDAR_UPDATE_EVENT_LIST") then
        if(framePool) then
            framePool:ReleaseAll()
        end

        local currentTime = miog.F.CURRENT_DATE or C_DateAndTime.GetCurrentCalendarTime()
        local offset = 0

       --[[ if(CalendarFrame and CalendarFrame.viewedYear) then
            local viewedInSeconds = time({year = CalendarFrame.viewedYear, month = CalendarFrame.viewedMonth, day = 0})
            local currentInSeconds = time({year = currentTime.year, month = currentTime.month, day = 0})

            if(viewedInSeconds > currentInSeconds) then
                offset = - (viewedInSeconds - currentInSeconds) / 2629746
                
            end

            local formatter = CreateFromMixins(SecondsFormatterMixin)
            formatter:SetStripIntervalWhitespace(true)
            formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter)
            --print(offset, viewedInSeconds, currentInSeconds)
        end]]

        local monthInfo = C_Calendar.GetMonthInfo(0)

        offset = currentTime.month - monthInfo.month

        local numEvents = C_Calendar.GetNumDayEvents(offset, currentTime.monthDay)

        if(calendarCoroutine) then
            local status = coroutine.status(calendarCoroutine)

            if(status == "dead") then
                calendarCoroutine = coroutine.create(requestCalendarEventInfo)
                coroutine.resume(calendarCoroutine, offset, currentTime.monthDay, numEvents)

            end
                
            if(status == "suspended") then
                coroutine.resume(calendarCoroutine, offset, currentTime.monthDay, numEvents)

            end
        end
    end
end

miog.loadCalendarSystem = function()
    framePool = CreateFramePool("Frame", miog.MainTab.Information.Holiday, "MIOG_HolidayFrameTemplate", resetHolidayFrame)

    local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_CalendarEventReceiver")
    
    eventReceiver:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    eventReceiver:RegisterEvent("CALENDAR_UPDATE_EVENT")
    eventReceiver:RegisterEvent("CALENDAR_OPEN_EVENT");
    
    eventReceiver:SetScript("OnEvent", calendarOnEvent)

    calendarCoroutine = coroutine.create(requestCalendarEventInfo)
end
