local addonName, miog = ...
local wticc = WrapTextInColorCode

local db = {
    --LFG
    ["declined"] = "Declined",
    ["declined_full"] = "Delisted (Full)",
    ["declined_delisted"] = "Delisted",
    ["applied"] = "Applied",
    ["timedout"] = "Timed out",
    ["invited"] = LFG_LIST_APP_INVITED,
    ["inviteaccepted"] = LFG_LIST_APP_INVITE_ACCEPTED,
    ["invitedeclined"] = LFG_LIST_APP_INVITE_DECLINED,
    ["cancelled"] = "Cancelled",
    ["failed"] = FAILED,
    
    --Keystones
    ["CHALLENGE_MODE_START"] = "Keys started",
    ["CHALLENGE_MODE_RESET"] = "Keys aborted",
    ["CHALLENGE_MODE_COMPLETED"] = "Keys finished",
}

local function requestTypeOfKey(key)
    return db[key] and "blizzard" or miog.INELIGIBILITY_REASONS[key] and "miog" or "none"
end

local function requestNameOfKey(key)
    return db[key] or miog.INELIGIBILITY_REASONS[key] and miog.INELIGIBILITY_REASONS[key][2] or key
end

local function distinguish(k1, k2)
    if(k1 and k2) then
        if(k1.type ~= k2.type) then
            return k1.type < k2.type

        elseif(k1.header) then
            return true
        elseif(k2.header) then
            return false

        else
            return k1.name < k2.name

        end

    else
        return false

    end
end

local function createListFrame(frame, data)
    frame.Name:SetText(data.name)

    if(data.template == "MIOG_StatisticsPageListEntryTemplate") then
        frame.Value:SetText(data.value)

        if(data.type == "miog") then
            frame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:SetText(miog.INELIGIBILITY_REASONS[data.key][1])
                GameTooltip:Show()
            end)

            frame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

        else
            frame:SetScript("OnEnter", nil)
            frame:SetScript("OnLeave", nil)

        end
    else

    end
end

miog.createStatisticsInterfacePanelPage = function(parent)
    local statisticsPage = CreateFrame("Frame", nil, parent, "MIOG_StatisticsPage")
    statisticsPage:SetScript("OnShow", function(self)
        local provider = CreateDataProvider();
        provider:SetSortComparator(distinguish)

        local typesDone = {}

        for k, v in pairs(MIOG_NewSettings.accountStatistics.lfgStatistics) do
            local keytype = requestTypeOfKey(k)

            if(not typesDone[keytype]) then
                typesDone[keytype] = keytype
			    provider:Insert({template = "MIOG_StatisticsPageListHeaderTemplate", name = keytype == "blizzard" and "Blizzard" or keytype == "miog" and addonName or "Other", type = keytype, header = true});

            end

			provider:Insert({template = "MIOG_StatisticsPageListEntryTemplate", key = k, name = requestNameOfKey(k), value = v, type = keytype});

        end

        self.ScrollBox:SetDataProvider(provider);
    end)
    miog.StatisticsPage = statisticsPage

    local view = CreateScrollBoxListLinearView();
    local function CustomFactory(factory, data)
        --local data = node:GetData()
        local template = data.template
        factory(template, createListFrame)
    end

    view:SetElementFactory(CustomFactory)
    view:SetPadding(1, 1, 1, 1, 2);
    
    ScrollUtil.InitScrollBoxListWithScrollBar(statisticsPage.ScrollBox, statisticsPage.ScrollBar, view);

    return statisticsPage
end