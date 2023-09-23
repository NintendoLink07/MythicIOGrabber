local addonName, miog = ...

miog.getAffixes = function()
	local affixIDs = C_MythicPlus.GetCurrentAffixes()

	local affixString = ""

	if(affixIDs) then
		for k, _ in pairs(affixIDs) do
			local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixIDs[k].id)
			affixString = affixString .. CreateTextureMarkup(filedataid, 64, 64, miog.C._AFFIX_FONT_SIZE, miog.C._AFFIX_FONT_SIZE, 0, 1, 0, 1) .. "\n"
		end

		miog.F.WEEKLY_AFFIX = affixIDs[1].id

		return affixString
	end

	return nil
end

miog.sortTableForRoleAndClass = function(tbl)
	table.sort(tbl, function(a, b)
		if a.role ~= b.role then return b.role < a.role end
		return a.class < b.class
	end)
end

miog.createFrameBorder = function(frame, thickness, r, g, b, a)
	if(not thickness and not r and not g and not b and not a) then
		thickness, r, g, b, a = 1, random(0, 1), random(0, 1), random(0, 1), 1
	end

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness } )
	frame:SetBackdropColor(0.1, 0.1 ,0.1 , 0) -- main area color
	frame:SetBackdropBorderColor(r, g, b, a) -- border color
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

miog.secondsToClock = function(stringSeconds)
	local seconds = tonumber(stringSeconds)

	if seconds <= 0 then
		return "00:00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return 
		hours..":"..
		mins..":"..
		secs
	end
end