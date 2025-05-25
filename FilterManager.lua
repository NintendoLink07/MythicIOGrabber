local addonName, miog = ...

local function checkIfSearchResultIsEligible(resultID)

end

local function checkIfApplicantIsEligible(applicantID)

end

local function setStatus(type)
	if(type == "change") then
		miog.FilterManager.Status:SetText("Refresh panel")

	end
end

local function changeSetting(value, ...)
	local lastSetting = MIOG_CharacterSettings.filters
	local parameterArray = {...}

	print(value, ...)

	for k, v in ipairs(parameterArray) do
		if(lastSetting[v]) then
			lastSetting = lastSetting[v]

		end
	end

	local setting = lastSetting[parameterArray[#parameterArray]]

	if(setting) then
		lastSetting[parameterArray[#parameterArray]] = value

		setStatus("change")
	end
end

-- classes index

--[[
	/tinspect MIOG_CharacterSettings
	/run MIOG_CharacterSettings = nil
			lastSetting[v] = value
			setStatus("change")
]]

local function retrieveSetting(...)
	local lastSetting = MIOG_CharacterSettings.filters
	local parameterArray = {...}

	for k, v in ipairs(parameterArray) do
		if(lastSetting[v]) then
			lastSetting = lastSetting[v]

		elseif(k == #parameterArray) then
			lastSetting = lastSetting[v]

		end
	end

	print(..., type(lastSetting))

	if(type(lastSetting) ~= "table") then
		return lastSetting

	end
end

local function initializeSetting(...)
	local lastSetting = MIOG_CharacterSettings.filters
	local parameterArray = {...}

	for k, v in ipairs(parameterArray) do
		if(not lastSetting[v]) then
			lastSetting[v] = {}

		end

		lastSetting = lastSetting[v]
	end
end

local function loadFilterManager()
	local filterManager = CreateFrame("Frame", "FilterManager", miog.Plugin, "MIOG_FilterManager")
	filterManager:SetPoint("TOPLEFT", miog.NewFilterPanel, "TOPRIGHT", 5, 0)
	filterManager:Show()

	initializeSetting("classes")
	initializeSetting("specs")

	for classIndex, classInfo in ipairs(miog.CLASSES) do
		local r, g, b = GetClassColor(classInfo.name)

		local singleClassFilter = filterManager.ClassFilters["Class" .. classIndex]
		singleClassFilter:SetSize(200 + 5, 20)
		singleClassFilter.Border:SetColorTexture(r, g, b, 0.25)
		singleClassFilter.Background:SetColorTexture(r, g, b, 0.5)
		singleClassFilter.ClassFrame.Icon:SetTexture(classInfo.roundIcon)

		local classSetting = retrieveSetting("classes", classIndex)
		singleClassFilter.ClassFrame.CheckButton:SetChecked(classSetting ~= nil and classSetting or true)
		singleClassFilter.ClassFrame.CheckButton:SetScript("OnClick", function(self)
			changeSetting(self:GetChecked(), "classes", classIndex)
		end)


		for i = 1, #classInfo.specs, 1 do
			local specID = classInfo.specs[i]
			local specInfo = miog.SPECIALIZATIONS[specID]
			local specFrame = singleClassFilter["Spec" .. i]
			specFrame.Icon:SetTexture(specInfo.icon)
			
			local specSetting = retrieveSetting("specs", specID)
			specFrame.CheckButton:SetChecked(specSetting ~= nil and specSetting or true)
			specFrame.CheckButton:SetScript("OnClick", function(self)
				changeSetting(self:GetChecked(), "specs", specID)
			end)
		end
	end

	filterManager.ClassFilters:MarkDirty()

	filterManager:MarkDirty()

	return filterManager
end

miog.loadFilterManager = loadFilterManager