local addonName, miog = ...

GroupOrganizerStandardMixin = {}

function GroupOrganizerStandardMixin:Init(key)
    self.key = key
end

function GroupOrganizerStandardMixin:Populate(data, columnIndex)
    local isOdd = data.index % 2 == 1

    local theme = miog.C.CURRENT_THEME

    if(isOdd) then
        self.BackgroundColor:SetColorTexture(theme[2].r, theme[2].g, theme[2].b, 0.1)

    else
        self.BackgroundColor:SetColorTexture(theme[3].r, theme[3].g, theme[3].b, 0.1)

    end

    if(self.key == "online") then
        if(data.online) then
            if(UnitIsAFK(data.unitID)) then
                self.Icon:SetTexture("interface/friendsframe/statusicon-away.blp")

            elseif(UnitIsDND(data.unitID)) then
                self.Icon:SetTexture("interface/friendsframe/statusicon-dnd.blp")

            else
                self.Icon:SetTexture("interface/friendsframe/statusicon-online.blp")

            end
        else
            self.Icon:SetTexture("interface/friendsframe/statusicon-offline.blp")

        end

	elseif(self.key == "name") then
        self.Text:SetText(data.fileName and WrapTextInColorCode(data.name, C_ClassColor.GetClassColor(data.fileName):GenerateHexColor()) or data.name)

    elseif(self.key == "class") then
        local classIndex = miog.CLASSFILE_TO_ID[data.fileName]
	    self.Icon:SetTexture(miog.CLASSES[classIndex].icon)
    
    elseif(self.key == "specID") then
	    self.Icon:SetTexture(miog.SPECIALIZATIONS[data.specID].squaredIcon)

    elseif(self.key == "level") then
	    self.Text:SetText(data.level)

    elseif(self.key == "itemLevel") then
        self.Text:SetText(data.itemLevel or "-")

    elseif(self.key == "durability") then
        self.Text:SetText(data.durability and data.durability .. "%" or "-")

    elseif(self.key == "score") then
        self.Text:SetText(data.score or "-")

    elseif(self.key == "progress") then
        self.Text:SetText(data.progress or "-")

    elseif(self.key == "keylevel") then
        self.Text:SetText(data.keystoneAbbreviatedName and ("+" .. data.keylevel .. " " .. data.keystoneAbbreviatedName) or "-")

    elseif(self.key == "combatRole") then
	    self.Icon:SetTexture(miog.C.STANDARD_FILE_PATH .. "/infoIcons/" .. (data.combatRole and data.combatRole .. "Icon.png" or "unknown.png"))

    elseif(self.key == "index") then
	    self.Text:SetText(data.subgroup .. "-" .. data.index)

    end

    if(self.Text) then
        if(data.online) then
            self.Text:SetTextColor(1, 1, 1, 1)
            
        else
            self.Text:SetTextColor(1, 0, 0, 1)

        end
    end
end




GroupOrganizerHeaderMixin = {}

function GroupOrganizerHeaderMixin:Init(headerName, key, onClickFunc)
    self.headerName = headerName
    self.Text:SetText(headerName)

    if(onClickFunc) then
        self:SetScript("OnClick", function(selfFrame)
            onClickFunc(selfFrame, key)
        end)

    else
        self:SetScript("OnClick", nil)

    end
end

function GroupOrganizerHeaderMixin:OnShow()
    local theme = miog.C.CURRENT_THEME
    self.BackgroundColor:SetColorTexture(theme[4].r, theme[4].g, theme[4].b, 0.25)

end