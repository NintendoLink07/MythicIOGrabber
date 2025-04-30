local addonName, miog = ...
local wticc = WrapTextInColorCode

MIOG_CharacterSettings = {}

miog.characterSettings = {
    {name = "AppDialog texts", variableName = "MIOG_AppDialogTexts", key="appDialogTexts", default={}},
    {name = "App dialog box extended", variableName = "MIOG_AppDialogBoxExtented", key="appDialogBoxExtented", default=true},
    {name = "Last used queue", variableName = "MIOG_LastUsedQueue", key="lastUsedQueue", default = {}},
    {name = "Last group", variableName = "MIOG_LastGroup", key="lastGroup", default="No group found"},
}