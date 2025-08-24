local addonName, miog = ...
local wticc = WrapTextInColorCode

MIOG_NewSettings = {}

local defaultSortState = {
    currentLayer = 0,
    currentState = 0,
    active = false,
}

local function keepSignUpNote(self, resultID)
    if(C_LFGList.HasSearchResultInfo(resultID)) then
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);
        --if ( searchResultInfo.activityID ~= self.activityID ) then
            --C_LFGList.ClearApplicationTextFields();
        --end

        self.resultID = resultID;
        self.activityID = searchResultInfo.activityIDs[1];
        LFGListApplicationDialog_UpdateRoles(self);
        StaticPopupSpecial_Show(self);
    end
end

LFGListApplicationDialog_Show = keepSignUpNote

--[[LFGListApplicationDialogDescription:Hide()
LFGListApplicationDialogDescription = nil

local customDesc = CreateFrame("ScrollFrame", nil, LFGListApplicationDialog, "InputScrollFrameTemplate")
customDesc:SetParentKey("Description")
customDesc:SetSize(210, 28)
customDesc:SetPoint("BOTTOM", 0, 55)
customDesc.maxLetters = 63
customDesc.instructions = LFG_LIST_NOTE_TO_LEADER
customDesc.hideCharCount = true
InputScrollFrame_OnLoad(customDesc);
customDesc.EditBox:SetText("3.4k last season, Dispell/Purge")

LFGListApplicationDialogDescription = customDesc]]

local defaultFilters = {
    classes = {},
    specs = {},
    partyFit = false,
    ressFit = false,
    lustFit = false,
    affixFit = false,
    filterForTanks = false,
    filterForHealers = false,
    filterForDamager = false,
    linkedTanks = false,
    linkedHealers = false,
    linkedDamager = false,
    filterForDifficulty = false,
    filterForRating = false,
    filterForAge = false,
    filterForBossKills = false,
    filterForActivities = false,
    filterForDungeons = false,
    filterForRaids = false,
    filterForRoles = {
        TANK = true,
        HEALER = true,
        DAMAGER = true,
    },
    filterForClassSpecs = true,
    minTanks = 0,
    maxTanks = 0,
    minHealers = 0,
    maxHealers = 0,
    minDamager = 0,
    maxDamager = 0,
    minRating = 0,
    maxRating = 0,
    minAge = 0,
    maxAge = 0,
    minBossKills = 0,
    maxBossKills = 0,
    difficultyID = 0,
    dungeons = {},
    raids = {
        setting = false,
        bosses = {}
    },
    hardDecline = false,
    softDecline = false,
    needsMyClass = true,
}

miog.defaultFilters = defaultFilters

local defaultSettings = {
    {name = "MainFrame size", variableName = "MIOG_MainFrameSize", key="mainFrameSize", default=nil},
    {name = "Active side panel", variableName = "MIOG_SidePanel", key="activeSidePanel", default="none"},
    {name = "Mythic+ Statistics", variableName = "MIOG_MPlusStats", key="mplusStats", default={}},
    {name = "PVP Statistics", variableName = "MIOG_PVPStats", key="pvpStats", default={}},
    {name = "Raid Statistics", variableName = "MIOG_RaidStats", key="raidStats", default={}},
    {name = "Lite Mode", variableName = "MIOG_LiteMode", key="liteMode", default=false, type="checkbox", tooltip="Enable or disable the lite mode of this addon (use Blizzards \"Dungeons and Raids\" Frame with this addon's frames layered on top", reload=true},
    {name = "Background options", variableName = "MIOG_BackgroundOptions", key="backgroundOptions", default=GetNumExpansions() - 1, type="dropdown", tooltip="Change the default background of the MIOG frames",
    customCallback=function(setting, value)
        miog.changeBackground(value)
    end},
    {name = "Progress data", variableName = "MIOG_ProgressData", key="progressData", default={characters = {}, activities = {}}},
    {name = "LFG Statistics", variableName = "MIOG_LFGStatistics", key="lfgStatistics", default={}},
    {name = "Requeue data", variableName = "MIOG_RequeueData", key="requeueData", default = {guids = {}}},
    {name = "Queue up time", variableName = "MIOG_QueueUpTime", key="queueUpTime", default=0},
    {name = "Last set checkboxes", variableName = "MIOG_LastSetCheckboxes", key="lastSetCheckboxes", default={}},
    {name = "Also apply raid graphics settings in dungeons", variableName = "MIOG_RaidToDungeonGraphics", key="raidToDungeonGraphics", type="checkbox", tooltip="Applies raid graphics setting automatically whenever you enter a dungeon. (Requires a reload)", default=false, customCallback=function() C_UI.Reload() end},
    {name = "Enable Search Panel Class Spec Tooltips", variableName = "MIOG_ClassSpecTooltip", key="classSpecTooltip", default=true},
    {name = "New filter options", variableName = "MIOG_NewFilterOptions", key="newFilterOptions", default={}},
    {name = "Filter options", variableName = "MIOG_FilterOptions", key="filterOptions", default={
        ["LFGListFrame.SearchPanel"] = defaultFilters,
        ["LFGListFrame.ApplicationViewer"] = defaultFilters,}
    },
    {name = "Sort methods", variableName = "MIOG_SortMethods", key="sortMethods", default={
        ["LFGListFrame.SearchPanel"] = {["primary"] = defaultSortState, ["secondary"] = defaultSortState, ["age"] = defaultSortState},
        ["LFGListFrame.ApplicationViewer"] = {["role"] = defaultSortState, ["primary"] = defaultSortState, ["secondary"] = defaultSortState, ["ilvl"] = defaultSortState},
        ["GroupManager"] = {},
        ["Guild"] = {["level"] = defaultSortState, ["rank"] = defaultSortState, ["class"] = defaultSortState, ["keystone"] = defaultSortState, ["keylevel"] = defaultSortState, ["score"] = defaultSortState, ["progressWeight"] = defaultSortState, }}
    },
    {name = "Progress activity visibility", variableName = "MIOG_ProgressActivityVisibility", key="progressActivityVisibility", default={}},
    {name = "Search Panel declined groups", variableName = "MIOG_DeclinedGroups", key="declinedGroups", default={}},
    {name = "Account-wide lockouts", variableName = "MIOG_Lockouts", key="lockoutCheck", default={}},
    {name = "Gearing table", variableName = "MIOG_GearingTable", key="gearingTable", default={headers = {}}},
    {name = "Raid planner settings", variableName = "MIOG_RaidPlannerSettings", key="raidPlanner", default={sheets = {[1] = {name = "RaidSheet1", slots = {}}}}},
    {name = "Statistics for account characters", variableName = "MIOG_AccountStatistics", key="accountStatistics", default={characters = {}, lfgStatistics = {}}, type="custom"},
    {name = "MainFrame scale", variableName = "MIOG_MainFrameScale", key="mainFrameScale", default=1},
}

local category = Settings.RegisterVerticalLayoutCategory(addonName)

local function OnSettingChanged(setting, value)
	-- This callback will be invoked whenever a setting is modified.
	--print("[MIOG] Setting changed:", setting:GetVariable(), value)
end

local function setSettingValue(value)

end

local function createDefaultSettings(overwriteSettings)
    local globalSettings = overwriteSettings and MIOG_CharacterSettings or MIOG_NewSettings

    for k, v in ipairs(overwriteSettings or defaultSettings) do
        local setting = Settings.RegisterAddOnSetting(category, v.variableName, v.key, globalSettings, type(v.default), v.name, v.default)

        if(v.type) then
            if(v.type == "checkbox") then
                Settings.CreateCheckbox(category, setting, v.tooltip)

            elseif(v.type == "dropdown") then
                local GetOptions

                if(v.key == "backgroundOptions") then
                    if(globalSettings.backgroundOptions > #miog.EXPANSION_INFO) then
                        globalSettings.backgroundOptions = v.default
                        
                    end

                    GetOptions = function()
                        local container = Settings.CreateControlTextContainer();
                        for i = 0, #miog.EXPANSION_INFO, 1 do
                            container:Add(i, miog.EXPANSION_INFO[i][1])
                            
                        end
                        return container:GetData();
                    end
                end

                Settings.CreateDropdown(category, setting, GetOptions, v.tooltip);
            elseif(v.type == "custom") then
                if(v.key == "accountStatistics") then
                    local scrollBox = miog.createStatisticsInterfacePanelPage(SettingsPanel)

                    local subcategory, subcategoryLayout = Settings.RegisterCanvasLayoutSubcategory(category, scrollBox, "LFG Statistics");
                    
                    subcategoryLayout:AddAnchorPoint("TOPLEFT", 10, -10);
                    subcategoryLayout:AddAnchorPoint("BOTTOMRIGHT", -10, 10);

                end
            end
        end

        if(v.reload) then
            setting:SetValueChangedCallback(function() C_UI.Reload() end)

        elseif(v.customCallback) then
            setting:SetValueChangedCallback(v.customCallback)

        else
            setting:SetValueChangedCallback(OnSettingChanged)

        end

        if(v.key == "declinedGroups") then
            for x, y in pairs(globalSettings.declinedGroups) do
                if(y.timestamp < time() - 900) then
                    globalSettings.declinedGroups[x] = nil
                    
                end
            end
        end

        if(type(v.default) == "table") then
            for x, y in pairs(v.default) do
                if(not globalSettings[v.key][x]) then
                    globalSettings[v.key][x] = y
                    
                end
            end
        end
    end
end

miog.increaseStatistic = function(name)
    MIOG_NewSettings.accountStatistics.lfgStatistics[name] = MIOG_NewSettings.accountStatistics.lfgStatistics[name] and MIOG_NewSettings.accountStatistics.lfgStatistics[name] + 1 or 1
end

miog.loadNewSettings = function()
    createDefaultSettings()
    createDefaultSettings(miog.characterSettings)

    miog.F.LITE_MODE = MIOG_NewSettings.liteMode

end

function MIOG_OpenInterfaceOptions()
	Settings.OpenToCategory(category:GetID())
end

Settings.RegisterAddOnCategory(category)