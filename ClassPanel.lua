local addonName, miog = ...
local wticc = WrapTextInColorCode

local currentlyInspectedPlayer, numPlayersWithSpec, numPlayersInspectable = "", 0, 0

local classColors = {}

local function updateGroupClassData()
	if(not InCombatLockdown()) then
		local classCount = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 0,
			[8] = 0,
			[9] = 0,
			[10] = 0,
			[11] = 0,
			[12] = 0,
			[13] = 0,
		}

		local roleCount = {
			["TANK"] = 0,
			["HEALER"] = 0,
			["DAMAGER"] = 0,
			["NONE"] = 0,
		}

        local numGroupMembers = GetNumGroupMembers()

		if(numGroupMembers > 0) then
            for groupIndex = 1, numGroupMembers, 1 do
                local name, _, _, _, _, fileName, _, _, _, _, _, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP
                
                if(name) then
                    if(classCount[miog.CLASSFILE_TO_ID[fileName] ]) then
                        classCount[miog.CLASSFILE_TO_ID[fileName] ] = classCount[miog.CLASSFILE_TO_ID[fileName] ] + 1

                    end

                    if(roleCount[combatRole]) then
                        roleCount[combatRole] = roleCount[combatRole] + 1
        
                    end
                end
            end
        else
			local _, id = UnitClassBase("player")
			
			if(classCount[id]) then
				classCount[id] = classCount[id] + 1

			end
		end

		miog.ApplicationViewer.TitleBar.GroupComposition.Roles:SetText(roleCount["TANK"] .. "/" .. roleCount["HEALER"] .. "/" .. roleCount["DAMAGER"])

		if(miog.GroupManager) then
			miog.GroupManager.Groups.Tank.Text:SetText(roleCount["TANK"])
			miog.GroupManager.Groups.Healer.Text:SetText(roleCount["HEALER"])
			miog.GroupManager.Groups.Damager.Text:SetText(roleCount["DAMAGER"])

		end

        for classID, classEntry in ipairs(miog.CLASSES) do
            local numOfClasses = classCount[classID]
            local currentClassFrame = miog.ClassPanel.Container.classFrames[classID]
            currentClassFrame.layoutIndex = classID
            currentClassFrame.Icon:SetDesaturated(numOfClasses < 1)

            if(numOfClasses > 0) then
                currentClassFrame.FontString:SetText(numOfClasses)
                currentClassFrame.Border:SetColorTexture(classColors[classID]:GetRGBA())
                currentClassFrame.layoutIndex = currentClassFrame.layoutIndex - 20

            else
                currentClassFrame.FontString:SetText("")
                currentClassFrame.Border:SetColorTexture(0, 0, 0, 1)

            end
        end
	end
end

local function classPanelEvents(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        updateGroupClassData()
    
    elseif(event == "GROUP_JOINED") then
        updateGroupClassData()
    
    elseif(event == "GROUP_LEFT") then
        updateGroupClassData()
    
    elseif(event == "GROUP_ROSTER_UPDATE") then
        updateGroupClassData()
    end
end

miog.setInspectionData = function(currentName, playersWithSpec, inspectableMembers)
    currentlyInspectedPlayer = currentName
    numPlayersWithSpec = playersWithSpec
    numPlayersInspectable = inspectableMembers
    
    miog.ClassPanel.StatusString:SetText((currentlyInspectedPlayer or "") .. "\n(" .. numPlayersWithSpec .. "/" .. numPlayersInspectable .. "/" .. GetNumGroupMembers() .. ")")
end

miog.createClassPanel = function()
    local classPanel = CreateFrame("Frame", "MythicIOGrabber_ClassPanel", miog.MainFrame, "MIOG_ClassPanel")
    PixelUtil.SetPoint(classPanel, "BOTTOMRIGHT", classPanel:GetParent(), "TOPRIGHT", 0, 1)
    PixelUtil.SetPoint(classPanel, "BOTTOMLEFT", classPanel:GetParent(), "TOPLEFT", 0, 1)

    local container = classPanel.Container

    PixelUtil.SetHeight(container, container:GetParent():GetHeight() - 5)
    container.classFrames = {}

    for classID, classEntry in ipairs(miog.CLASSES) do
        local classColor = C_ClassColor.GetClassColor(classEntry.name)

        classColors[classID] = classColor

        local classFrame = CreateFrame("Frame", nil, container, "MIOG_ClassPanelClassFrameTemplate")
        classFrame.layoutIndex = classID
        PixelUtil.SetSize(classFrame, container:GetHeight(), container:GetHeight())

        classFrame.Icon:SetTexture(classEntry.icon)
        classFrame.leftPadding = 3
        container.classFrames[classID] = classFrame

        local specPanel = CreateFrame("Frame", nil, classFrame, "VerticalLayoutFrame, BackdropTemplate")
        PixelUtil.SetPoint(specPanel, "TOP", classFrame, "BOTTOM", 0, -5)
        specPanel.fixedHeight = classFrame:GetHeight() - 3
        specPanel.specFrames = {}
        specPanel:Hide()
        classFrame.specPanel = specPanel

        local specCounter = 1

        for _, specID in ipairs(classEntry.specs) do
            local specFrame = CreateFrame("Frame", nil, specPanel, "MIOG_ClassPanelSpecFrameTemplate")
            PixelUtil.SetSize(specFrame, specPanel.fixedHeight, specPanel.fixedHeight)
            specFrame.Icon:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
            specFrame.Border:SetColorTexture(classColor:GetRGBA())
            specFrame.leftPadding = 0

            specPanel.specFrames[specID] = specFrame

            specCounter = specCounter + 1
        end

        classFrame:SetScript("OnEnter", function()
            specPanel:Show()

        end)
        classFrame:SetScript("OnLeave", function()
            specPanel:Hide()

        end)
    end

    container:MarkDirty()

    classPanel.StatusString:SetText((currentlyInspectedPlayer or "") .. "\n(" .. numPlayersWithSpec .. "/" .. numPlayersInspectable .. "/" .. GetNumGroupMembers() .. ")")
    classPanel.StatusString:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(numPlayersWithSpec .. " players with spec data.")
        GameTooltip:AddLine(numPlayersInspectable .. " group members that are inspectable (not offline or some weird faction stuff interaction).")
        GameTooltip:AddLine(GetNumGroupMembers() .. " total group members.")
        GameTooltip:Show()
    end)

    classPanel:RegisterEvent("PLAYER_ENTERING_WORLD")
    classPanel:RegisterEvent("GROUP_JOINED")
    classPanel:RegisterEvent("GROUP_LEFT")
    classPanel:RegisterEvent("GROUP_ROSTER_UPDATE")
	classPanel:SetScript("OnEvent", classPanelEvents)

    return classPanel
end