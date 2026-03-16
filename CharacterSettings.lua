local addonName, miog = ...
local wticc = WrapTextInColorCode

MIOG_CharacterSettings = {}

function miog:SetCharacterSetting(key, value)
    MIOG_CharacterSettings[key] = value

end

function miog:GetCharacterSetting(...)
    local setting = MIOG_CharacterSettings

    for k, v in ipairs({...}) do
        setting = setting[v]

    end

    return setting

end

miog.characterSettings = {
    {name = "AppDialog texts", variableName = "MIOG_AppDialogTexts", key="appDialogTexts", default={}},
    {name = "App dialog box extended", variableName = "MIOG_AppDialogBoxExtented", key="appDialogBoxExtented", default=true},
    {name = "Last used queue", variableName = "MIOG_LastUsedQueue", key="lastUsedQueue", default = {}},
    {name = "Last group", variableName = "MIOG_LastGroup", key="lastGroup", default="No group found"},
    {name = "Last group map", variableName = "MIOG_LastGroupMap", key="lastGroupMap", default=nil},
    {name = "Filters", variableName = "MIOG_Filters", key="filters", default={["SearchPanel"] = {}, ["ApplicationViewer"] = {}}},
}