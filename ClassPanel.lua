local addonName, miog = ...
local wticc = WrapTextInColorCode

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

        local roleCountTank, roleCountHealer, roleCountDamager = roleCount["TANK"], roleCount["HEALER"], roleCount["DAMAGER"]
        local roleCountString = roleCountTank .. "/" .. roleCountHealer .. "/" .. roleCountDamager

		miog.ClassPanel.GroupComp:SetText(roleCountString)
        miog.ClassPanel.GroupComp.tanks = roleCountTank
        miog.ClassPanel.GroupComp.healers = roleCountHealer
        miog.ClassPanel.GroupComp.damager = roleCountDamager

        if(miog.ApplicationViewer) then
		    miog.ApplicationViewer.TitleBar.GroupComposition.Roles:SetText(roleCountString)

        end

		if(miog.GroupManager) then
			miog.GroupManager.Groups.Tank.Text:SetText(roleCountTank)
			miog.GroupManager.Groups.Healer.Text:SetText(roleCountHealer)
			miog.GroupManager.Groups.Damager.Text:SetText(roleCountDamager)

		end

        local height = miog.ClassPanel.Container:GetHeight()

        for classID, classEntry in ipairs(miog.CLASSES) do
            local numOfClasses = classCount[classID]
            local currentClassFrame = miog.ClassPanel.Container.classFrames[classID]
            currentClassFrame.layoutIndex = classID

            local hasNoCharacters = numOfClasses < 1
            currentClassFrame.Icon:SetDesaturated(hasNoCharacters)
            currentClassFrame:SetAlpha(hasNoCharacters and 0.5 or 1)

            if(not hasNoCharacters) then
                currentClassFrame.FontString:SetText(numOfClasses)
                currentClassFrame.layoutIndex = currentClassFrame.layoutIndex - 20
                PixelUtil.SetSize(currentClassFrame, height, height)

            else
                currentClassFrame.FontString:SetText("")
                PixelUtil.SetSize(currentClassFrame, 12, 12)

            end
        end

        miog.ClassPanel.Container:MarkDirty()
	end
end

miog.updateGroupClassData = updateGroupClassData

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

miog.createClassPanel = function()
    local classPanel = CreateFrame("Frame", "MythicIOGrabber_ClassPanel", miog.F.LITE_MODE and PVEFrame or miog.pveFrame2, "MIOG_ClassPanel")
    PixelUtil.SetPoint(classPanel, "BOTTOMRIGHT", classPanel:GetParent(), "TOPRIGHT", 0, 1)
    PixelUtil.SetPoint(classPanel, "BOTTOMLEFT", classPanel:GetParent(), "TOPLEFT", 0, 1)

    local container = classPanel.Container

    PixelUtil.SetHeight(container, container:GetParent():GetHeight() - 5)
    container.classFrames = {}

    for classID, classEntry in ipairs(miog.CLASSES) do
        local classColor = C_ClassColor.GetClassColor(classEntry.name)

        classColors[classID] = classColor

        local classFrame = CreateFrame("Frame", nil, container, "MIOG_ClassPanelMinimalFrameTemplate")
        classFrame.layoutIndex = classID
        PixelUtil.SetSize(classFrame, container:GetHeight(), container:GetHeight())

        classFrame.Icon:SetTexture(classEntry.icon)
        classFrame.Border:SetColorTexture(classColor:GetRGBA())
        container.classFrames[classID] = classFrame

        local specPanel = CreateFrame("Frame", nil, classFrame, "VerticalLayoutFrame, BackdropTemplate")
        PixelUtil.SetPoint(specPanel, "TOP", classFrame, "BOTTOM", 0, -5)
        specPanel.fixedHeight = classFrame:GetHeight() - 3
        specPanel.specFrames = {}
        specPanel:Hide()
        classFrame.specPanel = specPanel

        local specCounter = 1

        for _, specID in ipairs(classEntry.specs) do
            local specFrame = CreateFrame("Frame", nil, specPanel, "MIOG_ClassPanelMinimalFrameTemplate")
            PixelUtil.SetSize(specFrame, specPanel.fixedHeight, specPanel.fixedHeight)
            specFrame.Icon:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
            specFrame.Border:SetColorTexture(classColor:GetRGBA())

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

    classPanel.Status:SetText("[1/1/" .. GetNumGroupMembers() .. "]")
    classPanel.Status:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

        local data = miog.getInspectionTextData()

        if(data) then
            GameTooltip:SetText(data.specs .. " players with spec data.")
            GameTooltip:AddLine(data.members .. " group members that are inspectable (not offline or some weird interaction).")

            GameTooltip:AddLine(data.numGroupMembers .. " total group members.")

            if(data.queue) then
                local headerMissing = true

                for k, v in pairs(data.queue) do
                    if(headerMissing) then
                        GameTooltip_AddBlankLineToTooltip(GameTooltip)
                        GameTooltip:AddLine("Players to be inspected:")

                        headerMissing = false
                    end

                    GameTooltip:AddLine(k)

                end

            end
        end
        
        GameTooltip:Show()
    end)

    classPanel:RegisterEvent("PLAYER_ENTERING_WORLD")
    classPanel:RegisterEvent("GROUP_JOINED")
    classPanel:RegisterEvent("GROUP_LEFT")
    classPanel:RegisterEvent("GROUP_ROSTER_UPDATE")
	classPanel:SetScript("OnEvent", classPanelEvents)

    return classPanel
end