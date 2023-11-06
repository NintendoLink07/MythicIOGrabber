local addonName, miog = ...

miog.setAffixes = function()
	local affixIDs = C_MythicPlus.GetCurrentAffixes()

	if(affixIDs) then
		local affixString = ""

		for index, affix in ipairs(affixIDs) do

			local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affix.id)

			affixString = affixString .. CreateTextureMarkup(filedataid, 64, 64, miog.C.APPLICANT_MEMBER_HEIGHT, miog.C.APPLICANT_MEMBER_HEIGHT, 0, 1, 0, 1)
			miog.mainFrame.infoPanel.affixFrame.tooltipText = miog.mainFrame.infoPanel.affixFrame.tooltipText .. name .. (index < #affixIDs and ", " or "")
		end

		miog.F.WEEKLY_AFFIX = affixIDs[1].id

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
	frame:SetBackdropColor(0, 0 , 0, 0) -- main area color
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

miog.secondsToClock = function(stringSeconds)
	local seconds = tonumber(stringSeconds)

	if seconds <= 0 then
		return "00:00";
	else
		local hours = string.format("%01.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return
		hours..":"..
		mins..":"..
		secs
	end
end

miog.checkIfCanInvite = function()
	if(UnitIsGroupLeader("player")) then
		miog.mainFrame.footerBar:Show()
		miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame.footerBar, "TOPRIGHT", 0, 0)

	else
		miog.mainFrame.footerBar:Hide()
		miog.mainFrame.applicantPanel:SetPoint("BOTTOMRIGHT", miog.mainFrame, "BOTTOMRIGHT", 0, 0)

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
		print("RETURN RED")
		return miog.CLRSCC["red"]

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
	miog.checkApplicantList(true)

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