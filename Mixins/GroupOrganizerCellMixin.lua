local addonName, miog = ...

GroupOrganizerStandardMixin = {}

function GroupOrganizerStandardMixin:Init(key)
    self.key = key
end

function GroupOrganizerStandardMixin:Populate(data, columnIndex)
    local orderID = data.index % 2

    if(orderID == 0) then
        self.BackgroundColor:SetColorTexture(0.75, 0.75, 0.75, 0.1)

    else
        self.BackgroundColor:SetColorTexture(0.5, 0.5, 0.5, 0.1)

    end

	if(self.key == "name") then
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
        self.Text:SetText(data.durability and "(" .. data.durability .. "%)" or "-")

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