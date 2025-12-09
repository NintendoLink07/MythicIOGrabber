local addonName, miog = ...

TextureCellMixin = {}

function TextureCellMixin:Init(key)
    self.key = key

    self:SetHeight(22)
end

function TextureCellMixin:Populate(node)
    local data = node:GetData()

    if(data) then
        local name, class, localizedClass, level, itemLevel, honorlevel, tank, healer, damager, assignedRole, relationship, dungeonScore, pvpItemLevel, faction, raceID, specID, isLeaver  = C_LFGList.GetApplicantMemberInfo(data.applicantID, data.applicantIndex)

        if(self.key == "role") then
            self.Texture:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. (assignedRole or "DAMAGER") .. "Icon.png")

        end
    end
end