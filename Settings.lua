local addonName, miog = ...

local function compareSettings()
	for index, row in ipairs(miog.defaultOptionSettings) do
		if(row.key ~= SavedOptionSettings[index].key or row.title ~= SavedOptionSettings[index].title) then
			return false
		end
	end

	return true
end

miog.loadSettings = function()
    miog.defaultOptionSettings = {
		{
			key = "showActualSpecIcons",
			type = "checkbox",
			title = "Find a group: Show actual spec icons in the queue simulator.\n(When turned off a /reload will occur.)",
			value = true
		},
		{
			key = "fillUpEmptySpaces",
			type = "checkbox",
			title = "Find a group: Fill up empty spaces in the listed group,\nso it will always be correctly order: 1 Tank, 1 Heal, 3 DPS.\n(When turned off a /reload will occur.)",
			value = false
		},
		{
			key = "enableSortDuringRefresh",
			type = "checkbox",
			title = "Start a group: Enable sorting of applicants when manually refreshed - Tank > Heal > DPS",
			value = true
		},
	}

	if(SavedOptionSettings) then
		if(compareSettings()) then
			miog.defaultOptionSettings = SavedOptionSettings
		else
			SavedOptionSettings = miog.defaultOptionSettings
		end
	else
		SavedOptionSettings = miog.defaultOptionSettings
	end

	return miog.defaultOptionSettings
end