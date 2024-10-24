local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.createClassPanel = function()
    local classPanel = CreateFrame("Frame", "MythicIOGrabber_ClassPanel", miog.MainFrame, "MIOG_ClassPanel")
	classPanel:SetPoint("BOTTOMRIGHT", classPanel:GetParent(), "TOPRIGHT", 0, 1)
    classPanel:SetPoint("BOTTOMLEFT", classPanel:GetParent(), "TOPLEFT", 0, 1)
	classPanel.LoadingSpinner:SetScript("OnMouseDown", function()
		miog.resetInspectCoroutine()
	end)

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
            specFrame.layoutIndex = specCounter
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

    return classPanel
end