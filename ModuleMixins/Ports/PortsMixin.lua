local addonName, miog = ...

local setupDone = false

PortsMixin = {}

local frameTable = {
    [3] = "Left",
    [4] = "Left",
    [5] = "Left",
    [6] = "Left",

    [7] = "Right",
    [8] = "Right",
    [9] = "Right",
    [10] = "Right",
    [11] = "Right",
    [12] = "Right",
}

function PortsMixin:Setup()
    for _, v in ipairs(miog.TELEPORT_FLYOUT_IDS) do
        local targetFrame

        if(v.seasonID) then
            if(v.seasonID == C_MythicPlus.GetCurrentSeason()) then
                targetFrame = self.Topleft.ActiveSeason

            else
                self.Topleft.Name:SetText("No active season")

            end

        else
            targetFrame = self[frameTable[v.expansion]]["Groups" .. v.expansion]

        end

        if(targetFrame) then
            targetFrame:Setup(v.id, v.expansion)
            
        end
    end
end

function PortsMixin:OnShow()
    if(not setupDone) then
        self:Setup()

        setupDone = true
    end
end