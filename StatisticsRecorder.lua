local addonName, miog = ...
local wticc = WrapTextInColorCode

local db = {
    --LFG
    ["declined"] = {name = "Declined", subtype = "SearchPanel", hide = false},
    ["declined_full"] = {name = "Delisted (Full)", subtype = "SearchPanel", hide = false},
    ["declined_delisted"] = {name = "Delisted", subtype = "SearchPanel", hide = false},
    ["applied"] = {name = "Applied", subtype = "SearchPanel", hide = false},
    ["timedout"] = {name = "Timed out", subtype = "SearchPanel", hide = false},
    ["invited"] = {name = LFG_LIST_APP_INVITED, subtype = "SearchPanel", hide = false},
    ["inviteaccepted"] = {name = LFG_LIST_APP_INVITE_ACCEPTED, subtype = "SearchPanel", hide = false},
    ["invitedeclined"] = {name = LFG_LIST_APP_INVITE_DECLINED, subtype = "SearchPanel", hide = false},
    ["cancelled"] = {name = "Cancelled", subtype = "SearchPanel", hide = false},
    ["failed"] = {name = FAILED, subtype = "SearchPanel", hide = false},
    
    --Keystones
    ["CHALLENGE_MODE_START"] = {name = "Keys started", subtype="Keys", hide = true},
    ["CHALLENGE_MODE_RESET"] = {name = "Keys aborted", subtype="Keys", hide = false},
    ["CHALLENGE_MODE_COMPLETED"] = {name = "Keys finished", subtype="Keys", hide = false},
}

miog.statisticsDB = db

local function shouldHideKey(key)
    return db[key] and db[key].hide or false
end

local function requestTypeOfKey(key)
    return db[key] and "blizzard" or miog.INELIGIBILITY_REASONS[key] and "miog" or "none"
end

local function requestNameOfKey(key)
    return db[key] and db[key].name or miog.INELIGIBILITY_REASONS[key] and miog.INELIGIBILITY_REASONS[key][2] or key
end

local function distinguish(k1, k2)
    if(k1 and k2) then
        if(k1.type ~= k2.type) then
            return k1.type < k2.type

        elseif(k1.header) then
            return true

        elseif(k2.header) then
            return false

        elseif(k1.subtype ~= k2.subtype) then
            return k1.subtype > k2.subtype

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
            if(not shouldHideKey(k)) then
                local keytype = requestTypeOfKey(k)

                if(not typesDone[keytype]) then
                    typesDone[keytype] = keytype
                    provider:Insert({template = "MIOG_StatisticsPageListHeaderTemplate", name = keytype == "blizzard" and "Blizzard" or keytype == "miog" and addonName or "Other", type = keytype, header = true});

                end

                provider:Insert({template = "MIOG_StatisticsPageListEntryTemplate", key = k, name = requestNameOfKey(k), value = v, type = keytype, subtype = db[k] and db[k].subtype});
            end
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