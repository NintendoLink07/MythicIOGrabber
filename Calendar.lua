local addonName, miog = ...

local wticc = WrapTextInColorCode

local calendarCoroutine = nil

local lastOffset, lastMonthDay, lastIndex
local framePool
local counter = 0

local function resetHolidayFrame(_, frame)
	frame:Hide()
	frame.layoutIndex = nil

	frame.DateBar.Title:SetText()
	--frame.Date:SetText()
	frame.Icon:SetTexture(nil)

---@diagnostic disable-next-line: undefined-field
	miog.MainTab.QueueInformation.Panel.ScrollFrame.Container:MarkDirty()
end

local function requestCalendarEventInfo(offsetMonths, monthDay, numEvents)
	
	for i = 1, numEvents, 1 do
		lastOffset, lastMonthDay, lastIndex = offsetMonths, monthDay, i
		local success = C_Calendar.OpenEvent(offsetMonths, monthDay, i)

	end
end

local function calendarOnEvent(_, event, ...)
    if(event == "CALENDAR_UPDATE_EVENT_LIST") then
        if(framePool) then
            framePool:ReleaseAll()
        end
        
        local numEvents = C_Calendar.GetNumDayEvents(0, 15)

        if(calendarCoroutine) then
            local status = coroutine.status(calendarCoroutine)

            if(status == "dead") then
                calendarCoroutine = coroutine.create(requestCalendarEventInfo)
                coroutine.resume(calendarCoroutine, 0, 15, numEvents)

            end
                
            if(status == "suspended") then
                coroutine.resume(calendarCoroutine, 0, 15, numEvents)

            end
        end

    elseif(event == "CALENDAR_UPDATE_EVENT") then

    elseif(event == "CALENDAR_OPEN_EVENT") then
        if(... == "HOLIDAY") then
            local info = C_Calendar.GetHolidayInfo(lastOffset, lastMonthDay, lastIndex)

            if(info and C_DateAndTime.CompareCalendarTime(C_DateAndTime.GetCurrentCalendarTime(), info.endTime) >= 0) then
                counter = counter + 1
                
                local cFrame = framePool:Acquire()
                cFrame:SetWidth(165)
                cFrame.layoutIndex = counter

                cFrame.Icon:SetTexture(info.texture)
                cFrame.Icon:SetTexCoord(0, 0.70, 0, 0.70)
                cFrame.DateBar.Title:SetText(info.name)
                
                local startTimeSeconds = time({year = info.startTime.year, month = info.startTime.month, day = info.startTime.monthDay, hour = info.startTime.hour, minute = info.startTime.minute})
                local endTimeSeconds = time({year = info.endTime.year, month = info.endTime.month, day = info.endTime.monthDay, hour = info.endTime.hour, minute = info.endTime.minute})
                local totalDuration = endTimeSeconds - startTimeSeconds
                local currentProgress = time() - startTimeSeconds
                local timeTillEnd = endTimeSeconds - time()

                local formatter = CreateFromMixins(SecondsFormatterMixin)
                formatter:SetStripIntervalWhitespace(true)
                formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter)
                
                local timeTillEndPerc = currentProgress / totalDuration

                cFrame.DateBar:SetStatusBarColor(timeTillEndPerc, 1 - timeTillEndPerc, 0, 1)
                cFrame.DateBar:SetMinMaxValues(0, 1)
                cFrame.DateBar:SetValue(timeTillEndPerc)
                --miog.createFrameWithBackgroundAndBorder(currentFrame, 1, unpack(dimColor))i
                --cFrame.Date:SetText(info.startTime.monthDay .. "." .. info.startTime.month .. " - " .. info.endTime.monthDay .. "." .. info.endTime.month)

                cFrame.DateBar.Title:SetText(cFrame.DateBar.Title:GetText() .. ": " .. formatter:Format(timeTillEnd))

                cFrame:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
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
