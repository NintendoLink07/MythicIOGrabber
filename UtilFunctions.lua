local addonName, miog = ...

miog.getAffixes = function()
	local affixIDs = C_MythicPlus.GetCurrentAffixes()

	if(affixIDs) then
		local sizeWH = miog.mainFrame.affixes:GetWidth()*miog.F.UI_SCALE

		local affixString = ""

		for _, affix in pairs(affixIDs) do
			local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affix.id)
			affixString = affixString .. CreateTextureMarkup(filedataid, 64, 64, sizeWH, sizeWH, 0, 1, 0, 1) .. "\n"
		end

		miog.F.WEEKLY_AFFIX = affixIDs[1].id

		miog.mainFrame.affixes:SetText(affixString)
	else
		return nil
	end
end

miog.sortTableForRoleAndClass = function(tbl)
	table.sort(tbl, function(a, b)
		if a.role ~= b.role then return b.role < a.role end
		return a.class < b.class
	end)
end

local function checkFrameBorderArguments(thickness, r, g, b, a)
	if(not thickness) then
		thickness = 1
	end

	if(not r) then
		r = random(0, 1)
	end

	if(not g) then
		g = random(0, 1)
	end

	if(not b) then
		b = random(0, 1)
	end

	if(not a) then
		a = 1
	end

	return thickness, r, g, b, a
end

miog.createFrameBorder = function(frame, oThickness, oR, oG, oB, oA)
	local thickness, r, g, b, a = checkFrameBorderArguments(oThickness, oR, oG, oB, oA)

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness+miog.F.PX_SIZE_1()} )
	frame:SetBackdropColor(0.1, 0.1 , 0.1, 0) -- main area color
	frame:SetBackdropBorderColor(r, g, b, a) -- border color
end

miog.createTopBottomLines = function(frame, oThickness, oR, oG, oB, oA)
	local thickness, r, g, b, a = checkFrameBorderArguments(oThickness, oR, oG, oB, oA)

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness, insets={left=0, right=0, top=-miog.F.PX_SIZE_1(), bottom=-miog.F.PX_SIZE_1()}} )
	frame:SetBackdropColor(r, g , b, a) -- main area color
	frame:SetBackdropBorderColor(r, g, b, 0) -- border color
end

miog.createLeftRightLines = function(frame, oThickness, oR, oG, oB, oA)
	local thickness, r, g, b, a = checkFrameBorderArguments(oThickness, oR, oG, oB, oA)

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness, insets={left=-1, right=-miog.F.PX_SIZE_1(), top=0, bottom=0}} )
	frame:SetBackdropColor(r, g , b, a) -- main area color
	frame:SetBackdropBorderColor(r, g, b, 0) -- border color
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