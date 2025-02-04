local addonName, miog = ...
local wticc = WrapTextInColorCode

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

		local hasNoData = true

		for groupIndex = 1, GetNumGroupMembers(), 1 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(groupIndex) --ONLY WORKS WHEN IN GROUP
			
			if(name) then
				if(classCount[miog.CLASSFILE_TO_ID[fileName] ]) then
					classCount[miog.CLASSFILE_TO_ID[fileName] ] = classCount[miog.CLASSFILE_TO_ID[fileName] ] + 1

				end

				hasNoData = false
			end
		end

		if(hasNoData) then
			local _, id = UnitClassBase("player")
			
			if(classCount[id]) then
				classCount[id] = classCount[id] + 1

			end
		end

        for classID, classEntry in ipairs(miog.CLASSES) do
            local numOfClasses = classCount[classID]
            local currentClassFrame = miog.ClassPanel.Container.classFrames[classID]
            currentClassFrame.layoutIndex = classID
            currentClassFrame.Icon:SetDesaturated(numOfClasses < 1)

            if(numOfClasses > 0) then
                --local rPerc, gPerc, bPerc = GetClassColor(miog.CLASSES[classID].name)
                --miog.createFrameBorder(currentClassFrame, 1, rPerc, gPerc, bPerc, 1)
                currentClassFrame.FontString:SetText(numOfClasses)
                currentClassFrame.Border:SetColorTexture(C_ClassColor.GetClassColor(classEntry.name):GetRGBA())
                currentClassFrame.layoutIndex = currentClassFrame.layoutIndex - 100

            else
                currentClassFrame.FontString:SetText("")
                currentClassFrame.Border:SetColorTexture(0, 0, 0, 1)
                --miog.createFrameBorder(currentClassFrame, 1, 0, 0, 0, 1)

            end

            miog.ClassPanel.Container.classFrames[classID].specPanel:MarkDirty()

        end
	end

    miog.updateGroupData()
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

miog.createClassPanel = function()
    local classPanel = CreateFrame("Frame", "MythicIOGrabber_ClassPanel", miog.MainFrame, "MIOG_ClassPanel")
	classPanel:SetPoint("BOTTOMRIGHT", classPanel:GetParent(), "TOPRIGHT", 0, 1)
    classPanel:SetPoint("BOTTOMLEFT", classPanel:GetParent(), "TOPLEFT", 0, 1)

    local container = classPanel.Container

    container:SetHeight(container:GetParent():GetHeight() - 5)
    container.classFrames = {}

    for classID, classEntry in ipairs(miog.CLASSES) do
        local classFrame = CreateFrame("Frame", nil, container, "MIOG_ClassPanelClassFrameTemplate")
        classFrame.layoutIndex = classID
        classFrame:SetSize(container:GetHeight(), container:GetHeight())

        classFrame.Icon:SetTexture(classEntry.icon)
        classFrame.leftPadding = 3
        container.classFrames[classID] = classFrame

        local specPanel = CreateFrame("Frame", nil, classFrame, "VerticalLayoutFrame, BackdropTemplate")
        specPanel:SetPoint("TOP", classFrame, "BOTTOM", 0, -5)
        specPanel.fixedHeight = classFrame:GetHeight() - 3
        specPanel.specFrames = {}
        specPanel:Hide()
        classFrame.specPanel = specPanel

        local specCounter = 1

        for _, specID in ipairs(classEntry.specs) do
            local specFrame = CreateFrame("Frame", nil, specPanel, "MIOG_ClassPanelSpecFrameTemplate")
            specFrame:SetSize(specPanel.fixedHeight, specPanel.fixedHeight)
            specFrame.Icon:SetTexture(miog.SPECIALIZATIONS[specID].squaredIcon)
            specFrame.leftPadding = 0

            specPanel.specFrames[specID] = specFrame

            specCounter = specCounter + 1
        end

        specPanel:MarkDirty()

        classFrame:SetScript("OnEnter", function()
            specPanel:Show()

        end)
        classFrame:SetScript("OnLeave", function()
            specPanel:Hide()

        end)
    end

    container:MarkDirty()

    classPanel:RegisterEvent("PLAYER_ENTERING_WORLD")
    classPanel:RegisterEvent("GROUP_JOINED")
    classPanel:RegisterEvent("GROUP_LEFT")
    classPanel:RegisterEvent("GROUP_ROSTER_UPDATE")
	classPanel:SetScript("OnEvent", classPanelEvents)

    return classPanel
end