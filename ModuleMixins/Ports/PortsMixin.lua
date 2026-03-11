local addonName, miog = ...

PortsMixin = {}

function PortsMixin:OnLoad()
    for _, v in ipairs(miog.TELEPORT_FLYOUT_IDS) do
        local targetFrame

        if(v.seasonID == C_MythicPlus.GetCurrentSeason()) then
            targetFrame = self.ActiveSeason

        elseif(not v.seasonID) then
            targetFrame = self["Groups" .. v.expansion]

        end

        if(targetFrame) then
            targetFrame:Setup(v.id, v.expansion)

        end
    end
end