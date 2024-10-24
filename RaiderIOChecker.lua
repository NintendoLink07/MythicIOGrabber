local addonName, miog = ...
local wticc = WrapTextInColorCode

local setupDone = false

local function setRaiderIOInformation(profile)
    if(profile) then
        miog.resetNewRaiderIOInfoPanel(miog.RaiderIOChecker)
		miog.fillNewRaiderIOPanel(miog.RaiderIOChecker, profile.name, profile.realm)
    end
end

miog.loadRaiderIOChecker = function()
	local raiderIOChecker = CreateFrame("Frame", "MythicIOGrabber_RaiderIOChecker", miog.Plugin.InsertFrame, "MIOG_RaiderIOChecker")

    raiderIOChecker.NameSearchBox:SetScript("OnKeyDown", function(self, key)
        if(key == "ENTER") then
            local profile
            
            if(RaiderIO) then
                profile = RaiderIO.GetProfile(self:GetText(), raiderIOChecker.RealmSearchBox:GetText() or "")

                setRaiderIOInformation(profile)
            end

        elseif(key == "TAB") then
            raiderIOChecker.RealmSearchBox:SetFocus()
        end
    end)

    raiderIOChecker.RealmSearchBox:SetScript("OnKeyDown", function(self, key)
        if(key == "ENTER") then
            local profile
            
            if(RaiderIO) then
                profile = RaiderIO.GetProfile(self:GetText(), raiderIOChecker.RealmSearchBox:GetText() or "")

                setRaiderIOInformation(profile)
            end

        elseif(key == "TAB") then
            raiderIOChecker.NameSearchBox:SetFocus()

        end
    end)

    local splitTable = miog.simpleSplit(C_AddOns.GetAddOnMetadata("RaiderIO", "Version"), "%s")

    local rioVersion = splitTable[1]
    local rioDate = splitTable[2]

    local rioTime = time({year = strsub(rioDate, 3, 6), month = strsub(rioDate, 7, 8), day = strsub(rioDate, 9, 10), hour = strsub(rioDate, 11, 12), min = strsub(rioDate, 13, 14), })
    local rioTimeInDate = date("%x %H:%M", rioTime)

	raiderIOChecker.RIOVersion:SetText(rioVersion .. " - " .. rioTimeInDate)

    return raiderIOChecker
end