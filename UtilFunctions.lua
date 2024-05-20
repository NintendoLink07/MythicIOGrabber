local addonName, miog = ...

miog.startTime = function()
	miog.F.START_TIME = GetTimePreciseSec()
end

miog.endTime = function()
	miog.F.END_TIME = GetTimePreciseSec()

	print(miog.F.END_TIME - miog.F.START_TIME)
end

miog.setAffixes = function()
	local affixIDs = C_MythicPlus.GetCurrentAffixes()

	if(affixIDs) then
		local affixString = ""
		miog.ApplicationViewer.CreationSettings.Affixes.tooltipText = affixString

		for index, affix in ipairs(affixIDs) do

			local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affix.id)

			affixString = affixString .. CreateTextureMarkup(filedataid, 64, 64, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT, 0, 1, 0, 1)
			miog.ApplicationViewer.CreationSettings.Affixes.tooltipText = miog.ApplicationViewer.CreationSettings.Affixes.tooltipText .. name .. (index < #affixIDs and ", " or "")

		end

		miog.F.WEEKLY_AFFIX = affixIDs[1].id
		miog.ApplicationViewer.CreationSettings.Affixes:SetText(affixString)

		if(not miog.F.LITE_MODE) then
			miog.MainTab.Information.Affixes:SetText(affixString)
			miog.MainTab.Information.Affixes.text = miog.ApplicationViewer.CreationSettings.Affixes.tooltipText
		end

	else
		return nil

	end
end

miog.printDebug = function(string)
	print("[MIOG]: " .. (string or "No message attached"))
end

miog.checkLFGState = function()
	return UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "solo"

end

miog.printTableAsLines = function(table)
	for k, v in pairs(table) do
		print(k, v)
		
	end
end

miog.setStandardBackdrop = function(frame)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=false, edgeSize = 1} )
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

miog.createFrameWithBackgroundAndBorder = function(frame, thickness, r, g, b, a)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness} )
	frame:SetBackdropColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 1) -- main area color
	frame:SetBackdropBorderColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), 0.3) -- border color

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

	if(dot and decimals > 0) then
		return tonumber(string.sub(number, 1, dot+decimals))

	elseif(dot and decimals == 0) then
		return tonumber(string.sub(number, 1, dot-1))

	else
		return tonumber(number)

	end

end

miog.round2 = function(num, factor)
	num = factor and num / factor or num
	local rounded = num + (2^52 + 2^51) - (2^52 + 2^51)
	return factor and rounded * factor or rounded

end

miog.round3 = function(number, digits)
	return math.floor(number / digits) * digits
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

miog.retrieveMapIDFromGFID = function(groupFinderID)
	for k, v in pairs(miog.MAP_INFO) do
		if(v.gfID == groupFinderID) then
			return k
		end
	end
end

miog.retrieveMapIDFromChallengeModeMap = function(challengeID)
	for k, v in pairs(miog.RAW["MapChallengeMode"]) do
		if(v[2] == challengeID) then
			return v[3]
		end
	end
end

miog.retrieveShortNameFromChallengeModeMap = function(challengeID)
	for k, v in pairs(miog.GROUP_ACTIVITY) do
		if(v.challengeModeID == challengeID) then
			return v.shortName
		end
	end
end


miog.findBattlegroundIconByName = function(mapName)
	for bgID, bgEntry in pairs(miog.BATTLEMASTER_INFO) do
		if(mapName == bgEntry.name) then
			return bgEntry.icon ~= 0 and bgEntry.icon or 525915
		end
	end

	return 525915
end

miog.findBattlegroundMapIDsByName = function(mapName)
	for bgID, bgEntry in pairs(miog.BATTLEMASTER_INFO) do
		if(mapName == bgEntry.name) then
			return bgEntry.possibleBGs
		end
	end

	return nil
end

miog.findBattlegroundIconByID = function(mapID)
	for bgID, bgEntry in pairs(miog.RAW["BattlemasterList"]) do
		if(bgEntry[1] == mapID) then
			return bgEntry[16] ~= 0 and bgEntry[16] or 525915
		end
	end

	return 525915
end

miog.findBattlegroundMapIDsByID = function(battlemasterID)
	return miog.BATTLEMASTER_INFO[battlemasterID].possibleBGs
end

miog.findBrawlIconByName = function(mapName)
	for brawlID, brawlEntry in pairs(miog.RAW["PvpBrawl"]) do
		if(brawlEntry[2] == mapName) then
			return miog.findBattlegroundIconByID(brawlEntry[4])
		end
	end

	return nil
end

miog.findBrawlIconByID = function(mapID)
	for brawlID, brawlEntry in pairs(miog.RAW["PvpBrawl"]) do
		if(brawlEntry[1] == mapID) then
			return miog.findBattlegroundIconByID(brawlEntry[4])
		end
	end

	return nil
end

miog.findBrawlMapIDsByName = function(mapName)
	for brawlID, brawlEntry in pairs(miog.RAW["PvpBrawl"]) do
		if(brawlEntry[2] == mapName) then
			return miog.findBattlegroundMapIDsByID(brawlEntry[4])
		end
	end

	return nil
end


miog.checkIfCanInvite = function()
	if(C_PartyInfo.CanInvite()) then
		miog.ApplicationViewer.BrowseGroupsButton:Show()
		miog.ApplicationViewer.DelistButton:Show()
		miog.ApplicationViewer.EditButton:Show()

		miog.F.CAN_INVITE = true

		return true

	else
		miog.ApplicationViewer.BrowseGroupsButton:Hide()
		miog.ApplicationViewer.DelistButton:Hide()
		miog.ApplicationViewer.EditButton:Hide()

		miog.F.CAN_INVITE = false

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

miog.createCustomColorForRating = function(score)
	if(score > 0) then
		for k, v in ipairs(miog.COLOR_BREAKPOINTS) do
			if(score < v.breakpoint) then
				local percentage = (v.breakpoint - score) / 600

				return CreateColor(v.r + (miog.COLOR_BREAKPOINTS[k - 1].r - v.r) * percentage, v.g + (miog.COLOR_BREAKPOINTS[k - 1].g - v.g) * percentage, v.b + (miog.COLOR_BREAKPOINTS[k - 1].b - v.b) * percentage)

			end
		end

		return CreateColor(0.9, 0.8, 0.5)
	else
		return CreateColorFromHexString(miog.CLRSCC.red)

	end
end

miog.addLastInvitedApplicant = function(currentApplicant)
	local container = miog.LastInvites.Panel.ScrollFrame.Container
	miog.F.LAST_INVITES_COUNTER = miog.F.LAST_INVITES_COUNTER + 1

	local invitedApplicant = miog.createBasicFrame("persistent", "BackdropTemplate", container)
	invitedApplicant.layoutIndex = miog.F.LAST_INVITES_COUNTER
	invitedApplicant:SetSize(container:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT + miog.C.APPLICANT_PADDING)

	miog.createFrameBorder(invitedApplicant, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

	local invitedApplicantBackground = miog.createBasicTexture("persistent", nil, invitedApplicant, invitedApplicant:GetSize())
	invitedApplicantBackground:SetDrawLayer("BACKGROUND")
	invitedApplicantBackground:SetAllPoints(true)
	invitedApplicantBackground:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())

	MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.fullName] = currentApplicant
	MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.fullName].timestamp = MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.fullName].timestamp or time()

	local invitedApplicantNameString = miog.createBasicFontString("persistent", 12, invitedApplicant)
	invitedApplicantNameString:SetText(WrapTextInColorCode(currentApplicant.name, select(4, GetClassColor(currentApplicant.class))))
	invitedApplicantNameString:SetPoint("LEFT", invitedApplicant, "LEFT", 3, 0)

	local invitedApplicantSpec = miog.createBasicTexture("persistent", miog.SPECIALIZATIONS[currentApplicant.specID].icon, invitedApplicant, 15, 15)
	invitedApplicantSpec:SetPoint("LEFT", invitedApplicant, "LEFT", invitedApplicant:GetWidth()*0.45, 0)
	invitedApplicantSpec:SetDrawLayer("ARTWORK")

	local invitedApplicantRole = miog.createBasicTexture("persistent", miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. currentApplicant.role .. "Icon.png", invitedApplicant, 16, 16)
	invitedApplicantRole:SetPoint("LEFT", invitedApplicantSpec, "RIGHT", 3, 0)
	invitedApplicantRole:SetDrawLayer("ARTWORK")

	local invitedApplicantScore = miog.createBasicFontString("persistent", 12, invitedApplicant)
	invitedApplicantScore:SetText(currentApplicant.primary)
	invitedApplicantScore:SetPoint("LEFT", invitedApplicantRole, "RIGHT", 3, 0)

	local deleteButton = miog.createBasicFrame("persistent", "IconButtonTemplate", invitedApplicant, 15, 15)
	deleteButton:SetFrameStrata("DIALOG")
	deleteButton:SetPoint("RIGHT", invitedApplicant, "RIGHT", -3, 0)
	deleteButton:RegisterForClicks("LeftButtonDown")
	deleteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	deleteButton.iconSize = 12
	deleteButton:OnLoad()
	deleteButton:SetScript("OnClick", function(self)
		miog.persistentFontStringPool:Release(invitedApplicantNameString)
		miog.persistentFontStringPool:Release(invitedApplicantScore)
		miog.persistentTexturePool:Release(invitedApplicantBackground)
		miog.persistentTexturePool:Release(invitedApplicantRole)
		miog.persistentTexturePool:Release(invitedApplicantSpec)
		miog.persistentFramePool:Release(invitedApplicant.favourButton)
		miog.persistentFramePool:Release(deleteButton)
		miog.persistentFramePool:Release(invitedApplicant)

		MIOG_SavedSettings.lastInvitedApplicants.table[currentApplicant.fullName] = nil

		container:MarkDirty()
	end)

	local favourButton = Mixin(miog.createBasicFrame("persistent", "UIButtonTemplate", invitedApplicant, 15, 15), MultiStateButtonMixin)
	favourButton:OnLoad()
	favourButton:SetSingleTextureForSpecificState(0, miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", 15)
	favourButton:SetSingleTextureForSpecificState(1, miog.C.STANDARD_FILE_PATH .. "/infoIcons/checkmarkSmallIcon.png", 12)
	favourButton:SetMaxStates(2)
	favourButton:SetState(MIOG_SavedSettings.favouredApplicants.table[currentApplicant.fullName] and true or false)
	favourButton:SetFrameStrata("DIALOG")
	favourButton:SetPoint("RIGHT", deleteButton, "LEFT", -5, 0)
	favourButton:RegisterForClicks("LeftButtonDown")
	favourButton:SetScript("OnClick", function()
		favourButton:AdvanceState()

		if(favourButton:GetActiveState() == 0) then
			miog.deleteFavouredApplicant(currentApplicant.fullName)

		else
			miog.addFavouredApplicant(currentApplicant)

		end


	end)

	invitedApplicant.favourButton = favourButton

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

	miog.F.LAST_INVITED_APPLICANTS[currentApplicant.fullName] = invitedApplicant

	container:MarkDirty()
end

miog.addFavouredApplicant = function(currentApplicant)
	miog.F.FAVOURED_APPLICANTS_COUNTER = miog.F.FAVOURED_APPLICANTS_COUNTER + 1

	local favouredApplicant = miog.createBasicFrame("persistent", "BackdropTemplate", miog.ApplicationViewer.optionPanel.container.favouredApplicantsPanel.scrollFrame.container, miog.ApplicationViewer.optionPanel.container.favouredApplicantsPanel:GetWidth(), miog.C.APPLICANT_MEMBER_HEIGHT + miog.C.APPLICANT_PADDING)
	favouredApplicant.layoutIndex = miog.F.FAVOURED_APPLICANTS_COUNTER

	miog.createFrameBorder(favouredApplicant, 1, CreateColorFromHexString(miog.C.SECONDARY_TEXT_COLOR):GetRGB())

	local FavouredApplicantBackground = miog.createBasicTexture("persistent", nil, favouredApplicant, favouredApplicant:GetSize())
	FavouredApplicantBackground:SetDrawLayer("BACKGROUND")
	FavouredApplicantBackground:SetAllPoints(true)
	FavouredApplicantBackground:SetColorTexture(CreateColorFromHexString(miog.C.BACKGROUND_COLOR_2):GetRGBA())
	favouredApplicant.background = FavouredApplicantBackground

	local FavouredApplicantNameString = miog.createBasicFontString("persistent", 12, favouredApplicant)
	FavouredApplicantNameString:SetText(currentApplicant.class and WrapTextInColorCode(currentApplicant.name, select(4, GetClassColor(currentApplicant.class))) or currentApplicant.name)
	FavouredApplicantNameString:SetPoint("LEFT", favouredApplicant, "LEFT", 3, 0)
	favouredApplicant.nameString = FavouredApplicantNameString

	local FavouredApplicantSpec, FavouredApplicantRole, FavouredApplicantScore

	FavouredApplicantSpec = miog.createBasicTexture("persistent", nil , favouredApplicant, 15, 15)
	FavouredApplicantSpec:SetPoint("LEFT", favouredApplicant, "LEFT", favouredApplicant:GetWidth()*0.50, 0)
	FavouredApplicantSpec:SetDrawLayer("ARTWORK")
	favouredApplicant.specTexture = FavouredApplicantSpec

	if(currentApplicant.specID) then
		FavouredApplicantSpec:SetTexture(miog.SPECIALIZATIONS[currentApplicant.specID].icon)

	end

	FavouredApplicantRole = miog.createBasicTexture("persistent", nil, favouredApplicant, 16, 16)
	FavouredApplicantRole:SetPoint("LEFT", FavouredApplicantSpec, "RIGHT", 3, 0)
	FavouredApplicantRole:SetDrawLayer("ARTWORK")
	favouredApplicant.roleTexture = FavouredApplicantRole

	if(currentApplicant.role) then
		FavouredApplicantRole:SetTexture(miog.C.STANDARD_FILE_PATH .."/infoIcons/" .. currentApplicant.role .. "Icon.png")

	end

	FavouredApplicantScore = miog.createBasicFontString("persistent", 12, favouredApplicant)
	FavouredApplicantScore:SetPoint("LEFT", FavouredApplicantRole, "RIGHT", 3, 0)
	favouredApplicant.scoreString = FavouredApplicantScore

	if(currentApplicant.primary) then
		FavouredApplicantScore:SetText(currentApplicant.primary)

	end

	local deleteButton = miog.createBasicFrame("persistent", "IconButtonTemplate", favouredApplicant, 15, 15)
	deleteButton:SetFrameStrata("DIALOG")
	deleteButton:SetPoint("RIGHT", favouredApplicant, "RIGHT", -3, 0)
	deleteButton:RegisterForClicks("LeftButtonDown")
	deleteButton.icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/xSmallIcon.png"
	deleteButton.iconSize = 12
	deleteButton:OnLoad()
	deleteButton:SetScript("OnClick", function()
		miog.deleteFavouredApplicant(currentApplicant.fullName)

	end)
	favouredApplicant.deleteButton = deleteButton

	miog.F.FAVOURED_APPLICANTS[currentApplicant.fullName] = favouredApplicant

	miog.ApplicationViewer.optionPanel.container.favouredApplicantsPanel.scrollFrame.container:MarkDirty()

	MIOG_SavedSettings.favouredApplicants.table[currentApplicant.fullName] = currentApplicant
end

miog.deleteFavouredApplicant = function(name)
	local favouredApplicant = miog.F.FAVOURED_APPLICANTS[name]
	miog.persistentFontStringPool:Release(favouredApplicant.nameString)
	miog.persistentFontStringPool:Release(favouredApplicant.scoreString)
	miog.persistentTexturePool:Release(favouredApplicant.background)
	miog.persistentTexturePool:Release(favouredApplicant.roleTexture)
	miog.persistentTexturePool:Release(favouredApplicant.specTexture)
	miog.persistentFramePool:Release(favouredApplicant.deleteButton)
	miog.persistentFramePool:Release(favouredApplicant)

	miog.ApplicationViewer.optionPanel.container.favouredApplicantsPanel.scrollFrame.container:MarkDirty()

	MIOG_SavedSettings.favouredApplicants.table[name] = nil

	miog.F.FAVOURED_APPLICANTS[name] = nil

	if(miog.F.LAST_INVITED_APPLICANTS[name]) then
		miog.F.LAST_INVITED_APPLICANTS[name].favourButton:SetState(false)

	end

end

miog.addFavouredButtonsToUnitPopup = function(dropdownMenu, _, _, ...)
	if(UIDROPDOWNMENU_MENU_LEVEL == 1) then
		local dropdownParent =  dropdownMenu:GetParent()

		if(dropdownMenu.unit or dropdownParent and dropdownParent.unit) then
			local unit = dropdownMenu and (dropdownMenu.unit or dropdownMenu:GetParent().unit)
			if(UnitIsPlayer(unit) and dropdownMenu.which ~= "SELF") then --  
				local name = dropdownMenu.name
				local server = dropdownMenu.server or GetRealmName()
				local fullName = name .. "-" .. server

				UIDropDownMenu_AddSeparator()

				local info = UIDropDownMenu_CreateInfo()
				info.notCheckable = true
				info.func = function(self, arg1, arg2, checked)
					if(type(arg1) == "table") then
						miog.addFavouredApplicant(arg1)

					else
						miog.deleteFavouredApplicant(arg1)

					end

				end

				if(miog.F.FAVOURED_APPLICANTS[fullName]) then
					info.text = "[MIOG] Unfavour"
					info.arg1 = fullName

				else
					local profile = miog.F.IS_RAIDERIO_LOADED and RaiderIO.GetProfile(name, server, miog.F.CURRENT_REGION)

					local applicantData = {
						name = name,
						--class = class,
						--spec = spec,
						--role = role,
						primary = profile and profile.mythicKeystoneProfile and profile.mythicKeystoneProfile.currentScore and profile.mythicKeystoneProfile.currentScore > 0 and profile.mythicKeystoneProfile.currentScore or "No score",
						fullName = fullName,
					}

					info.text = "[MIOG] Favour"
					info.arg1 = applicantData

				end

				UIDropDownMenu_AddButton(info, 1)
			end
		end
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