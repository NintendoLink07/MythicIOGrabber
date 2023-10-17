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



miog.sortTableForRoleAndClass = function(tbl)
	table.sort(tbl, function(a, b)
		if a.role ~= b.role then
			return b.role < a.role
		end
		
		return a.class < b.class
	end)
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

miog.changeDrawLayer = function(regionType, oldDrawLayer, newDrawLayer, ...)
	for index = 1, select('#', ...) do
		local region = select(index, ...)
		if region:IsObjectType(regionType) and region:GetDrawLayer() == oldDrawLayer then
			region:SetDrawLayer(newDrawLayer)
		end
	end
end

miog.dummyFunction = function()
	-- empty function for overwriting useless Blizzard functions
end

miog.generateRaidWeightsTable = function(bossNumber)
	local table = {
		[3] = (bossNumber - 1) * 10,
		[2] = (bossNumber - 1),
		[1] = bossNumber * 0.1
	}

	return table
end

miog.romanNumeralsDecoder = function(number) -- https://stackoverflow.com/questions/72291577/a-better-way-on-improving-my-roman-numeral-decoder
    local numeralMap = {I = 1, V = 5, X = 10, L = 50, C = 100, D = 500, M = 1000}
    local currentNumber = 0

    for i = 1, #number - 1 do
        local letter = number:sub(i, i)
        local letter_p = number:sub(i + 1, i + 1)

        if (numeralMap[letter] < numeralMap[letter_p]) then
            currentNumber = currentNumber - numeralMap[letter]
			
        else
            currentNumber = currentNumber + numeralMap[letter]

        end
    end

    currentNumber = currentNumber + numeralMap[number:sub(-1)]
	
    return currentNumber
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