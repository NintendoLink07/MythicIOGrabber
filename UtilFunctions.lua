local addonName, miog = ...

miog.setAffixes = function()
	local affixIDs = C_MythicPlus.GetCurrentAffixes()

	if(affixIDs) then
		local affixString = ""

		for index, affix in pairs(affixIDs) do
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

local function checkFrameBorderArguments(r, g, b, a)

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

	return r, g, b, a
end

miog.createFrameBorder = function(frame, thickness, oR, oG, oB, oA)
	local r, g, b, a = checkFrameBorderArguments(oR, oG, oB, oA)

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness and thickness} )
	frame:SetBackdropColor(0.1, 0.1 , 0.1, 0) -- main area color
	frame:SetBackdropBorderColor(r, g, b, a) -- border color
end

miog.createTopBottomLines = function(frame, thickness, oR, oG, oB, oA)
	local r, g, b, a = checkFrameBorderArguments(oR, oG, oB, oA)

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness, insets={left=0, right=0, top=-miog.F.PX_SIZE_1(), bottom=-miog.F.PX_SIZE_1()}} )
	frame:SetBackdropColor(r, g , b, a) -- main area color
	frame:SetBackdropBorderColor(r, g, b, 0) -- border color
end

miog.createLeftRightLines = function(frame, thickness, oR, oG, oB, oA)
	local r, g, b, a = checkFrameBorderArguments(oR, oG, oB, oA)

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

miog.addHoverTooltip = function(frame, text)
	frame:SetMouseMotionEnabled(true)
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		print("---"..text)
		GameTooltip:SetText(text)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

miog.dummyFunction = function()
	-- empty function for overwriting useless Blizzard functions
end