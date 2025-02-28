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
    {name = "Frame manually resized", variableName = "MIOG_ManualResize", key="manualResize", default=0},
    {name = "Active side panel", variableName = "MIOG_SidePanel", key="activeSidePanel", default="none"},
    {name = "Mythic+ Statistics", variableName = "MIOG_MPlusStats", key="mplusStats", default={}},
    {name = "PVP Statistics", variableName = "MIOG_PVPStats", key="pvpStats", default={}},
    {name = "Raid Statistics", variableName = "MIOG_RaidStats", key="raidStats", default={}},
    {name = "Lite Mode", variableName = "MIOG_LiteMode", key="liteMode", default=false, type="checkbox", tooltip="Enable or disable the lite mode of this addon (use Blizzards \"Dungeons and Raids\" Frame with this addon's frames layered on top", reload=true},
    {name = "ReQueue", variableName = "MIOG_ReQueue", key="reQueue", default=true, type="checkbox", tooltip="Enable or disable the ReQueue feature.", reload=true},
    {name = "Filter popup", variableName = "MIOG_FilterPopup", key="filterPopup", default=false, type="checkbox", tooltip="Enable or disable popups when your filters don't match anymore with one of the groups you've applied to.", reload=false},
    {name = "Clear ReQueue apps", variableName = "MIOG_ClearFakeApps", key="clearFakeApps", default=false, type="checkbox", tooltip="Clear out applications from the ReQueue feature when they've been blocked by a filter.", reload=false},
    {name = "[ReQueue] Flash client icon", variableName = "MIOG_FlashOnApplyPopup", key="flashOnApplyPopup", default=false, type="checkbox", tooltip="Flash the WoW application in the taskbar when a group has declined you / has been delisted and the Apply Popup shows up.", reload=false},
    {name = "[Filter] Flash client icon", variableName = "MIOG_FlashOnFilterPopup", key="flashOnFilterPopup", default=false, type="checkbox", tooltip="Flash the WoW application in the taskbar when a group has been filtered and the Filter Popup shows up.", reload=false},
    {name = "Background options", variableName = "MIOG_BackgroundOptions", key="backgroundOptions", default=GetNumExpansions() - 1, type="dropdown", tooltip="Change the default background of the MIOG frames",
    customCallback=function(setting, value)
        miog.MainFrame.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. ".png")
        miog.LastInvites.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. "_small.png")
        miog.NewFilterPanel.Background:SetTexture(miog.C.STANDARD_FILE_PATH .. "/backgrounds/" .. miog.EXPANSION_INFO[value][2] .. "_small.png")
    end},
    {name = "LFG Statistics", variableName = "MIOG_LFGStatistics", key="lfgStatistics", default={}},
    {name = "Last invited applicants", variableName = "MIOG_LastInvitedApplicants", key="lastInvitedApplicants", default={}},
    {name = "Requeue data", variableName = "MIOG_RequeueData", key="requeueData", default = {guids = {}}},
    {name = "Last used queue", variableName = "MIOG_LastUsedQueue", key="lastUsedQueue", default = {}},
    {name = "Last group", variableName = "MIOG_LastGroup", key="lastGroup", default="No group found"},
    {name = "Last set checkboxes", variableName = "MIOG_LastSetCheckboxes", key="lastSetCheckboxes", default={}},
    {name = "Enable Search Panel Class Spec Tooltips", variableName = "MIOG_ClassSpecTooltip", key="classSpecTooltip", default=true},
    {name = "Favoured applicants", variableName = "MIOG_FavouredApplicants", key="favouredApplicants", default={}, type="custom"},
    {name = "New filter options", variableName = "MIOG_NewFilterOptions", key="newFilterOptions", default={}},
    {name = "Filter options", variableName = "MIOG_FilterOptions", key="filterOptions", default={
        ["LFGListFrame.SearchPanel"] = defaultFilters,
        ["LFGListFrame.ApplicationViewer"] = defaultFilters,
        ["DropChecker"] = defaultFilters}
    },
    {name = "Sort methods", variableName = "MIOG_SortMethods", key="sortMethods", default={
        ["LFGListFrame.SearchPanel"] = {["primary"] = defaultSortState, ["secondary"] = defaultSortState, ["age"] = defaultSortState},
        ["LFGListFrame.ApplicationViewer"] = {["role"] = defaultSortState, ["primary"] = defaultSortState, ["secondary"] = defaultSortState, ["ilvl"] = defaultSortState},
        ["GroupManager"] = {},
        ["Guild"] = {["level"] = defaultSortState, ["rank"] = defaultSortState, ["class"] = defaultSortState, ["keystone"] = defaultSortState, ["keylevel"] = defaultSortState, ["score"] = defaultSortState, ["progressWeight"] = defaultSortState, }}
    },
    {name = "Search Panel declined groups", variableName = "MIOG_DeclinedGroups", key="declinedGroups", default={}},
    {name = "Account-wide lockouts", variableName = "MIOG_Lockouts", key="lockoutCheck", default={}},
    {name = "Raid planner settings", variableName = "MIOG_RaidPlannerSettings", key="raidPlanner", default={sheets = {[1] = {name = "RaidSheet1", slots = {}}}}},
    {name = "Statistics for account characters", variableName = "MIOG_AccountStatistics", key="accountStatistics", default={characters = {}, lfgStatistics = {}}, type="custom"},
}

local category = Settings.RegisterVerticalLayoutCategory(addonName)

local function OnSettingChanged(setting, value)
	-- This callback will be invoked whenever a setting is modified.
	--print("[MIOG] Setting changed:", setting:GetVariable(), value)
end

local function setSettingValue(value)

end

local function createDefaultSettings()
    for k, v in ipairs(defaultSettings) do
        local setting = Settings.RegisterAddOnSetting(category, v.variableName, v.key, MIOG_NewSettings, type(v.default), v.name, v.default)

        if(v.type) then
            if(v.type == "checkbox") then
                Settings.CreateCheckbox(category, setting, v.tooltip)

            elseif(v.type == "dropdown") then
                local GetOptions

                if(v.key == "backgroundOptions") then
                    if(MIOG_NewSettings.backgroundOptions > #miog.EXPANSION_INFO) then
                        MIOG_NewSettings.backgroundOptions = v.default
                        
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
                if(v.key == "favouredApplicants") then
                    local scrollBox = miog.loadFavouredPlayersPanel(SettingsPanel)

                    local subcategory, subcategoryLayout = Settings.RegisterCanvasLayoutSubcategory(category, scrollBox, "Favour");
                    
                    subcategoryLayout:AddAnchorPoint("TOPLEFT", 10, -10);
                    subcategoryLayout:AddAnchorPoint("BOTTOMRIGHT", -10, 10);

                elseif(v.key == "accountStatistics") then
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
            for x, y in pairs(MIOG_NewSettings.declinedGroups) do
                if(y.timestamp < time() - 900) then
                    MIOG_NewSettings.declinedGroups[x] = nil
                    
                end
            end
        end

        if(type(v.default) == "table") then
            for x, y in pairs(v.default) do
                if(not MIOG_NewSettings[v.key][x]) then
                    MIOG_NewSettings[v.key][x] = y
                    
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

    miog.F.LITE_MODE = MIOG_NewSettings.liteMode

    miog.refreshFavouredPlayers()

end

function MIOG_OpenInterfaceOptions()
	Settings.OpenToCategory(category:GetID())
end

Settings.RegisterAddOnCategory(category)