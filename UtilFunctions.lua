local addonName, miog = ...

miog.startTime = function()
	miog.F.START_TIME = GetTimePreciseSec()
end

miog.endTime = function()
	miog.F.END_TIME = GetTimePreciseSec()

	print(miog.F.END_TIME - miog.F.START_TIME)
end

miog.setAffixes = function()
	if(not miog.F.LITE_MODE) then
		local affixIDs = C_MythicPlus.GetCurrentAffixes()

		if(affixIDs and #affixIDs > 0) then
			local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixIDs[1].id)

			miog.MainTab.Information.KeystoneStatusBar.Affix:SetTexture(filedataid)
			miog.MainTab.Information.KeystoneStatusBar.Affix.affixID = affixIDs[1].id

		else
			return nil

		end
	end
end

--[[
    Prints a debug message with a custom prefix
    - `string`: Message to print (defaults to "No message attached")
--]]
miog.printDebug = function(string)
	print("[MIOG]: " .. (string or "No message attached"))
end

--[[
    Checks the player's current group state (raid, party, or solo)
    - Returns a string indicating the group state
--]]
miog.checkLFGState = function()
	return UnitInRaid("player") and "raid" or UnitInParty("player") and "party" or "solo"

end

--[[
    Prints each key-value pair in a given table on a new line
    - `table`: The table to print
--]]
miog.printTableAsLines = function(table)
	for k, v in pairs(table) do
		print(k, v)
		
	end
end

--[[
    Sets a standard backdrop for a given frame
    - `frame`: The frame to apply the backdrop to
--]]
miog.setStandardBackdrop = function(frame)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=false, edgeSize = 1} )
end

--[[
    Creates an invisible frame border with a specified thickness and color
    - `frame`: The frame to apply the border to
    - `thickness`: Thickness of the border
    - `r, g, b, a`: Red, Green, Blue, Alpha values for the border color
--]]
miog.createInvisibleFrameBorder = function(frame, thickness, r, g, b, a)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=20, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = thickness} )
	frame:SetBackdropColor(r or 0, g or 0, b or 0, a or 0) -- main area color
end

--[[
    Sets the backdrop color of a specific frame
    - `frame`: The frame to apply the border to
    - `r, g, b, a`: Red, Green, Blue, Alpha values for the border color
--]]
miog.setBackdropColor = function(frame, r, g, b, a)
	frame:SetBackdropColor(0, 0, 0, 0) -- main area color
	frame:SetBackdropBorderColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 1) -- border color

end

--[[
    Creates a frame border with a specified thickness and color
    - `frame`: The frame to apply the border to
    - `thickness`: Thickness of the border
    - `r, g, b, a`: Red, Green, Blue, Alpha values for the border color
--]]
miog.createFrameBorder = function(frame, thickness, r, g, b, a)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=1, tile=false, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize = thickness} )
	frame:SetBackdropColor(0, 0, 0, 0) -- main area color
	frame:SetBackdropBorderColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 1) -- border color

end

--[[
    Creates a top and bottom border with a specified thickness and color
    - `frame`: The frame to apply the border to
    - `thickness`: Thickness of the border
    - `r, g, b, a`: Red, Green, Blue, Alpha values for the border color
--]]
miog.createTopBottomLines = function(frame, thickness, r, g, b, a)
	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness, insets={left=0, right=0, top=-miog.F.PX_SIZE_1(), bottom=-miog.F.PX_SIZE_1()}} )
	frame:SetBackdropColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 1) -- main area color
	frame:SetBackdropBorderColor(r or random(0, 1), g or random(0, 1), b or random(0, 1), a or 0) -- border color

end


--[[
    Creates a left and right border with a specified thickness and color
    - `frame`: The frame to apply the border to
    - `thickness`: Thickness of the border
    - `r, g, b, a`: Red, Green, Blue, Alpha values for the border color
--]]
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

-- from sam_lie
-- Compatible with Lua 5.0 and 5.1.
-- Disclaimer : use at own risk especially for hedge fund reports :-)

---============================================================
-- add comma to separate thousands
-- 
local function comma_value(amount)
	local formatted, k = amount, 0
	while true do
	  formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	  if (k==0) then
		break
	  end
	end
	return formatted
  end
  
  ---============================================================
  -- rounds a number to the nearest decimal places
  --
 local function round(val, decimal)
	if (decimal) then
	  return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
	  return math.floor(val+0.5)
	end
  end
  
  --===================================================================
  -- given a numeric value formats output with comma to separate thousands
  -- and rounded to given decimal places
  --
  --
miog.format_num = function(amount, decimal, prefix, neg_prefix)
	local str_amount,  formatted, famount, remain
  
	decimal = decimal or 2  -- default 2 decimal places
	neg_prefix = neg_prefix or "-" -- default negative sign
  
	famount = math.abs(round(amount,decimal))
	famount = math.floor(famount)
  
	remain = round(math.abs(amount) - famount, decimal)
  
		  -- comma to separate the thousands
	formatted = comma_value(famount)
  
		  -- attach the decimal portion
	if (decimal > 0) then
	  remain = string.sub(tostring(remain),3)
	  formatted = formatted .. "." .. remain ..
				  string.rep("0", decimal - string.len(remain))
	end
  
		  -- attach prefix string e.g '$' 
	formatted = (prefix or "") .. formatted 
  
		  -- if value is negative then format accordingly
	if (amount<0) then
	  if (neg_prefix=="()") then
		formatted = "("..formatted ..")"
	  else
		formatted = neg_prefix .. formatted 
	  end
	end
  
	return formatted
  end


  miog.tableCopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
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

miog.formatInt = function(number) -- https://stackoverflow.com/questions/10989788/format-integer-in-lua
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
  
	-- reverse the int-string and append a comma to all blocks of 3 digits
	int = int:reverse():gsub("(%d%d%d)", "%1,")
  
	-- reverse the int-string back remove an optional comma and put the 
	-- optional minus and fractional part back
	return minus .. int:reverse():gsub("^,", "") .. fraction
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

--[[miog.secondsToClock = function(stringSeconds)
		startTime = GetTimePreciseSec()


	local seconds = tonumber(stringSeconds)

	if seconds <= 0 then
		return "0:00:00"

	else
		local hours = string.format("%01.f", math.floor(seconds/3600))
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))
		local string = 
		hours..":"..
		mins..":"..
		secs

		endTime = GetTimePreciseSec()

		print("A1", endTime - startTime)


		return string

	end
end]]

miog.secondsToClock = function(seconds)
	if seconds <= 0 then
		return "0:00:00"
	end

	local hours = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = tonumber(string.format("%02.f", seconds % 60))

	local result = hours .. ":"
	if mins < 10 then result = result .. "0" end
	result = result .. mins .. ":"
	if secs < 10 then result = result .. "0" end
	result = result .. secs

	return result
end

miog.retrieveMapIDFromGFID = function(groupFinderID)
	for k, v in pairs(miog.MAP_INFO) do
		if(v.gfID == groupFinderID) then
			return k
		end
	end
end

miog.retrieveMapIDFromChallengeModeMap = function(challengeID)
	for k, v in pairs(miog.CHALLENGE_MODE_INFO) do
		if(k == challengeID) then
			return v.mapID
		end
	end
end

miog.retrieveShortNameFromChallengeModeMap = function(challengeID)
	for k, v in pairs(miog.CHALLENGE_MODE_INFO) do
		if(challengeID == k) then
			return miog.MAP_INFO[v.mapID].shortName
		end
	end
end

miog.findBattlegroundBackgroundByName = function(mapName)
	for bgID, bgEntry in pairs(miog.BATTLEMASTER_INFO) do
		if(mapName == bgEntry.name) then
			return bgEntry.icon ~= 0 and bgEntry.icon or 525915
		end
	end

	return 525915
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
		miog.ApplicationViewer.Delist:Show()
		miog.ApplicationViewer.Edit:Show()

		return true

	else
		miog.ApplicationViewer.Delist:Hide()
		miog.ApplicationViewer.Edit:Hide()

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
				local percentage = (v.breakpoint - score) / 700

				return CreateColor(v.r + (miog.COLOR_BREAKPOINTS[k - 1].r - v.r) * percentage, v.g + (miog.COLOR_BREAKPOINTS[k - 1].g - v.g) * percentage, v.b + (miog.COLOR_BREAKPOINTS[k - 1].b - v.b) * percentage)

			end
		end

		return CreateColor(0.9, 0.8, 0.5)
	else
		return CreateColorFromHexString(miog.CLRSCC.red)

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