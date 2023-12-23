local addonName, miog = ...

miog.setAffixes = function()
	local affixIDs = C_MythicPlus.GetCurrentAffixes()

	if(affixIDs) then
		local affixString = ""

		for index, affix in ipairs(affixIDs) do

			local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affix.id)

			affixString = affixString .. CreateTextureMarkup(filedataid, 64, 64, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT, 0, 1, 0, 1)
			miog.mainFrame.infoPanel.affixFrame.tooltipText = miog.mainFrame.infoPanel.affixFrame.tooltipText .. name .. (index < #affixIDs and ", " or "")

			miog.F.WEEKLY_AFFIX = affixIDs[1].id
		end

		miog.mainFrame.infoPanel.affixFrame.FontString:SetText(affixString)

	else
		return nil

	end
end

miog.checkLFGState = function()
	return UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "solo"
	
end

miog.createFrameBorder = function(frame, thickness, r, g, b, a)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = thickness} )
	frame:SetBackdropColor(0, 0, 0, 0) -- main area color
	frame:SetBackdropBorderColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 1) -- border color

end

miog.createTopBottomLines = function(frame, thickness, r, g, b, a)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness, insets={left=0, right=0, top=-miog.F.PX_SIZE_1(), bottom=-miog.F.PX_SIZE_1()}} )
	frame:SetBackdropColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 1) -- main area color
	frame:SetBackdropBorderColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 0) -- border color

end

miog.createLeftRightLines = function(frame, thickness, r, g, b, a)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness, insets={left=-1, right=-miog.F.PX_SIZE_1(), top=0, bottom=0}} )
	frame:SetBackdropColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 1) -- main area color
	frame:SetBackdropBorderColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 0) -- border color

end

miog.simpleSplit = function(tempString, delimiter)
	local resultArray = {}
	for result in string.gmatch(tempString, "[^"..delimiter.."]+") do
		resultArray[#resultArray+1] = result
	end

	return resultArray

end

miog.round = function(number, decimals)
	local dot = string.find(number, "%.")

	if(dot) then
		return string.sub(number, 1, dot+decimals)

	else
		return number

	end

end

miog.round2 = function(num)
	return num + (2^52 + 2^51) - (2^52 + 2^51)

end

miog.deepCopyTable = function(orig, copies)
	copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[miog.deepCopyTable(orig_key, copies)] = miog.deepCopyTable(orig_value, copies)
            end
            setmetatable(copy, miog.deepCopyTable(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

miog.secondsToClock = function(stringSeconds)
	local seconds = tonumber(stringSeconds)

	if seconds <= 0 then
		return "0:00:00"

	else
		local hours = string.format("%01.f", math.floor(seconds/3600))
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
		return
		hours..":"..
		mins..":"..
		secs

	end
end

miog.checkForActiveFilters = function()
	local filtersActive = false

	for _, v in pairs(miog.mainFrame.buttonPanel.filterPanel.classFilterPanel.ClassPanels) do
		if(not v.Button:GetChecked()) then
			filtersActive = true
			break

		end

		for _, y in pairs(v.specFilterPanel.SpecButtons) do
			if(not y:GetChecked()) then
				filtersActive = true
				break

			end

		end
		
	end
	
	for _, v in pairs(miog.mainFrame.buttonPanel.filterPanel.roleFilterPanel.RoleButtons) do
		if(not v:GetChecked()) then
			filtersActive = true
			break

		end

	end

	return filtersActive
end

miog.checkIfCanInvite = function()
	if(C_PartyInfo.CanInvite()) then
		miog.mainFrame.footerBar.browseGroupsButton:Show()
		miog.mainFrame.footerBar.delistButton:Show()
		miog.mainFrame.footerBar.editButton:Show()
		
		return true

	else
		miog.mainFrame.footerBar.browseGroupsButton:Hide()
		miog.mainFrame.footerBar.delistButton:Hide()
		miog.mainFrame.footerBar.editButton:Hide()

		return false

	end

end

miog.changeDrawLayer = function(regionType, oldDrawLayer, newDrawLayer, ...)
	for index = 1, select('#', ...) do
		local region = select(index, ...)

		if region:IsObjectType(regionType) and region:GetDrawLayer() == oldDrawLayer then
			region:SetDrawLayer(newDrawLayer)

		end

	end
end

miog.createCustomColorForScore = function(score)
	if(score > 0) then
		for k, v in ipairs(miog.COLOR_BREAKPOINTS) do
			if(score < v.breakpoint) then
				local percentage = (v.breakpoint - score) / 600
				
				return CreateColor(v.r + (miog.COLOR_BREAKPOINTS[k - 1].r - v.r) * percentage, v.g + (miog.COLOR_BREAKPOINTS[k - 1].g - v.g) * percentage, v.b + (miog.COLOR_BREAKPOINTS[k - 1].b - v.b) * percentage)

			end
		end
		
		return CreateColor(0.9, 0.8, 0.5)
	else
		return miog.CLRSCC["red"]

	end
end

miog.addLastInvitedApplicant = function(currentApplicant)
	miog.F.LAST_INVITES_COUNTER = miog.F.LAST_INVITES_COUNTER + 1

	local invitedApplicant = miog.createBasicFrame("persistent", "BackdropTemplate", miog.mainFrame.lastInvitesPanel.scrollFrame.container)
	invitedApplicant.layoutIndex = miog.F.LAST_INVITES_COUNTER
	invitedApplicant:SetSize(miog.mainFrame.lastInvitesPanel.scrollFrame:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT + miog.C.APPLICANT_PADDING)

	miog.createFrameBorder(invitedApplicant, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

	local invitedApplicantBackground = miog.createBasicTexture("persistent", nil, invitedApplicant, invitedApplicant:GetSize())
	invitedApplicantBackground:SetDrawLayer("BACKGROUND")
	invitedApplicantBackground:SetAllPoints(true)
	invitedApplicantBackground:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.saveData.fullName] = MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.saveData.fullName] or {
		saveData = currentApplicant.saveData
	}

	MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.saveData.fullName].timestamp = MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.saveData.fullName].timestamp or time()

	local invitedApplicantNameString = miog.createBasicFontString("persistent", 12, invitedApplicant)
	invitedApplicantNameString:SetText(WrapTextInColorCode(currentApplicant.saveData.name, select(4, GetClassColor(currentApplicant.saveData.class))))
	invitedApplicantNameString:SetPoint("LEFT", invitedApplicant, "LEFT", 3, 0)

	local invitedApplicantSpec = miog.createBasicTexture("persistent", miog.SPECIALIZATIONS[currentApplicant.saveData.specID].icon, invitedApplicant, 15, 15)
	invitedApplicantSpec:SetPoint("LEFT", invitedApplicant, "LEFT", invitedApplicant:GetWidth()*0.45, 0)
	invitedApplicantSpec:SetDrawLayer("ARTWORK")

	local invitedApplicantRole = miog.createBasicTexture("persistent", miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. currentApplicant.saveData.role .. "Icon.png", invitedApplicant, 16, 16)
	invitedApplicantRole:SetPoint("LEFT", invitedApplicantSpec, "RIGHT", 3, 0)
	invitedApplicantRole:SetDrawLayer("ARTWORK")

	local invitedApplicantScore = miog.createBasicFontString("persistent", 12, invitedApplicant)
	invitedApplicantScore:SetText(currentApplicant.saveData.primary)
	invitedApplicantScore:SetPoint("LEFT", invitedApplicantRole, "RIGHT", 3, 0)

	local deleteButton = miog.createBasicFrame("persistent", "IconButtonTemplate", invitedApplicant, 15, 15)
	deleteButton:SetFrameStrata("DIALOG")
	deleteButton:SetPoint("RIGHT", invitedApplicant, "RIGHT", -3, 0)
	deleteButton:RegisterForClicks("LeftButtonDown")
	deleteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	deleteButton.iconSize = 12
	deleteButton:OnLoad()
	deleteButton:SetScript("OnClick", function()
		miog.persistentFontStringPool:Release(invitedApplicantNameString)
		miog.persistentFontStringPool:Release(invitedApplicantScore)
		miog.persistentTexturePool:Release(invitedApplicantBackground)
		miog.persistentTexturePool:Release(invitedApplicantRole)
		miog.persistentTexturePool:Release(invitedApplicantSpec)
		miog.persistentFramePool:Release(invitedApplicant.preferButton)
		miog.persistentFramePool:Release(deleteButton)
		miog.persistentFramePool:Release(invitedApplicant)

		MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.saveData.fullName] = nil

		miog.mainFrame.lastInvitesPanel.scrollFrame.container:MarkDirty()
	end)
	
	local preferButton = Mixin(miog.createBasicFrame("persistent", "UIButtonTemplate", invitedApplicant, 15, 15), TripleStateButtonMixin)
	preferButton:OnLoad()
	preferButton:SetSingleTextureForSpecificState(0, miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", 15)
	preferButton:SetSingleTextureForSpecificState(1, miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png", 12)
	--preferButton:SetSingleTextureForSpecificState(1, miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png", 12)
	preferButton:SetMaxStates(2)
	preferButton:SetState(MIOG_SavedSettings.preferredApplicants.table[currentApplicant.saveData.fullName] and true or false)
	preferButton:SetFrameStrata("DIALOG")
	preferButton:SetPoint("RIGHT", deleteButton, "LEFT", -5, 0)
	preferButton:RegisterForClicks("LeftButtonDown")
	preferButton:SetScript("OnClick", function()
		preferButton:AdvanceState()

		if(preferButton:GetActiveState() == 0) then
			miog.deletePreferredApplicant(currentApplicant.saveData.fullName)

		else
			miog.addPreferredApplicant(currentApplicant.saveData)
		
		end


	end)

	invitedApplicant.preferButton = preferButton

	--[[

				name = name,
				index = applicantID,
				role = assignedRole,
				class = class,
				specID = specID,
				primary = primarySortAttribute,
				secondary = secondarySortAttribute,
				ilvl = itemLevel

	]]

	miog.F.LAST_INVITED_APPLICANTS[currentApplicant.saveData.fullName] = invitedApplicant

	miog.mainFrame.lastInvitesPanel.scrollFrame.container:MarkDirty()
end

miog.addPreferredApplicant = function(currentApplicant)
	miog.F.PREFERRED_APPLICANTS_COUNTER = miog.F.PREFERRED_APPLICANTS_COUNTER + 1

	local preferredApplicant = miog.createBasicFrame("persistent", "BackdropTemplate", miog.mainFrame.optionPanel.container.preferredApplicantsPanel.scrollFrame.container, miog.mainFrame.optionPanel.container.preferredApplicantsPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT + miog.C.APPLICANT_PADDING)
	preferredApplicant.layoutIndex = miog.F.PREFERRED_APPLICANTS_COUNTER

	miog.createFrameBorder(preferredApplicant, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

	local preferredApplicantBackground = miog.createBasicTexture("persistent", nil, preferredApplicant, preferredApplicant:GetSize())
	preferredApplicantBackground:SetDrawLayer("BACKGROUND")
	preferredApplicantBackground:SetAllPoints(true)
	preferredApplicantBackground:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
	preferredApplicant.background = preferredApplicantBackground

	local preferredApplicantNameString = miog.createBasicFontString("persistent", 12, preferredApplicant)
	preferredApplicantNameString:SetText(WrapTextInColorCode(currentApplicant.name, select(4, GetClassColor(currentApplicant.class))))
	preferredApplicantNameString:SetPoint("LEFT", preferredApplicant, "LEFT", 3, 0)
	preferredApplicant.nameString = preferredApplicantNameString

	local preferredApplicantSpec = miog.createBasicTexture("persistent", miog.SPECIALIZATIONS[currentApplicant.specID].icon, preferredApplicant, 15, 15)
	preferredApplicantSpec:SetPoint("LEFT", preferredApplicant, "LEFT", preferredApplicant:GetWidth()*0.45, 0)
	preferredApplicantSpec:SetDrawLayer("ARTWORK")
	preferredApplicant.specTexture = preferredApplicantSpec

	local preferredApplicantRole = miog.createBasicTexture("persistent", miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. currentApplicant.role .. "Icon.png", preferredApplicant, 16, 16)
	preferredApplicantRole:SetPoint("LEFT", preferredApplicantSpec, "RIGHT", 3, 0)
	preferredApplicantRole:SetDrawLayer("ARTWORK")
	preferredApplicant.roleTexture = preferredApplicantRole

	local preferredApplicantScore = miog.createBasicFontString("persistent", 12, preferredApplicant)
	preferredApplicantScore:SetText(currentApplicant.primary)
	preferredApplicantScore:SetPoint("LEFT", preferredApplicantRole, "RIGHT", 3, 0)
	preferredApplicant.scoreString = preferredApplicantScore

	local deleteButton = miog.createBasicFrame("persistent", "IconButtonTemplate", preferredApplicant, 15, 15)
	deleteButton:SetFrameStrata("DIALOG")
	deleteButton:SetPoint("RIGHT", preferredApplicant, "RIGHT", -3, 0)
	deleteButton:RegisterForClicks("LeftButtonDown")
	deleteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	deleteButton.iconSize = 12
	deleteButton:OnLoad()
	deleteButton:SetScript("OnClick", function()
		miog.deletePreferredApplicant(currentApplicant.fullName)

	end)
	preferredApplicant.deleteButton = deleteButton

	miog.F.PREFERRED_APPLICANTS[currentApplicant.fullName] = preferredApplicant

	miog.mainFrame.optionPanel.container.preferredApplicantsPanel.scrollFrame.container:MarkDirty()

	MIOG_SavedSettings.preferredApplicants.table[currentApplicant.fullName] = currentApplicant
end

miog.deletePreferredApplicant = function(name)
	local preferredApplicant = miog.F.PREFERRED_APPLICANTS[name]
	miog.persistentFontStringPool:Release(preferredApplicant.nameString)
	miog.persistentFontStringPool:Release(preferredApplicant.scoreString)
	miog.persistentTexturePool:Release(preferredApplicant.background)
	miog.persistentTexturePool:Release(preferredApplicant.roleTexture)
	miog.persistentTexturePool:Release(preferredApplicant.specTexture)
	miog.persistentFramePool:Release(preferredApplicant.deleteButton)
	miog.persistentFramePool:Release(preferredApplicant)

	miog.mainFrame.optionPanel.container.preferredApplicantsPanel.scrollFrame.container:MarkDirty()

	MIOG_SavedSettings.preferredApplicants.table[name] = nil

	if(miog.F.LAST_INVITED_APPLICANTS[name]) then
		miog.F.LAST_INVITED_APPLICANTS[name].preferButton:SetState(false)

	end

end

miog.dummyFunction = function()
	-- empty function for overwriting useless Blizzard functions
end

miog.shuffleNumberTable = function(table)
	for i = 1, #table - 1 do
		local j = math.random(i, #table)
		table[i], table[j] = table[j], table[i]
	end
end

miog.handleCoroutineReturn = function(coroutineReturn)
	if(coroutineReturn[1] == false) then
		print("ERROR: " .. coroutineReturn[2])
		print("If you see this, please report the whole error to me on either GitHub or CurseForge. Thank you!")

	end
end

---------
-- DEBUG
--------- 

miog.debugGetTestTier = function(rating)
	local newRank

	for _,v in ipairs(miog.DEBUG_TIER_TABLE) do
		if(rating >= v[1]) then
			newRank = v[2]
		end
	end

	return newRank
end

miog.debug_InviteApplicant = function(applicantID)

end

miog.debug_DeclineApplicant = function(applicantID)
	miog.DEBUG_APPLICANT_DATA[applicantID] = nil
	C_LFGList.RefreshApplicants()

end

miog.debug_GetApplicants = function()
	local allApplicantsTable = {}

	local counter = 1

	for k, _ in pairs(miog.DEBUG_APPLICANT_DATA) do
		allApplicantsTable[counter] = k

		counter = counter + 1

	end

	return allApplicantsTable

end

miog.debug_GetApplicantInfo = function(applicantID)
	return miog.DEBUG_APPLICANT_DATA[applicantID]

end

miog.debug_GetApplicantMemberInfo = function(applicantID, index)
	return unpack(miog.DEBUG_APPLICANT_MEMBER_INFO[applicantID][index])

end