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
	miog.RaiderIOChecker = CreateFrame("Frame", "MythicIOGrabber_RaiderIOChecker", miog.Plugin.InsertFrame, "MIOG_RaiderIOChecker")

    miog.RaiderIOChecker.NameSearchBox:SetScript("OnKeyDown", function(self, key)
        if(key == "ENTER") then
            local profile = RaiderIO.GetProfile(self:GetText(), miog.RaiderIOChecker.RealmSearchBox:GetText() or "")

            setRaiderIOInformation(profile)

        elseif(key == "TAB") then
            miog.RaiderIOChecker.RealmSearchBox:SetFocus()
        end
    end)

    miog.RaiderIOChecker.RealmSearchBox:SetScript("OnKeyDown", function(self, key)
        if(key == "ENTER") then
            local profile = RaiderIO.GetProfile(miog.RaiderIOChecker.NameSearchBox:GetText() or "", self:GetText())

            setRaiderIOInformation(profile)

        elseif(key == "TAB") then
            miog.RaiderIOChecker.NameSearchBox:SetFocus()

        end
    end)

	miog.RaiderIOChecker.RIOVersion:SetText(C_AddOns.GetAddOnMetadata("RaiderIO", "Version"))
end