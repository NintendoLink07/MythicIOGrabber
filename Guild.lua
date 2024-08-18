local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.guildSystem = {}
miog.guildSystem.memberData = {}
miog.guildSystem.keystoneData = {}


miog.guildSystem.baseFrames = {}
miog.guildSystem.raiderIOPanels = {}

local detailedList = {}

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_GuildEventReceiver")

local includeOffline

local function sortGuildList(k1, k2)
	k1 = k1.data
	k2 = k2.data

	for key, tableElement in pairs(MIOG_NewSettings.sortMethods["Guild"]) do
		if(tableElement and tableElement.currentLayer == 1) then
			local firstState = tableElement.currentState

			for innerKey, innerTableElement in pairs(MIOG_NewSettings.sortMethods["Guild"]) do
				if(innerTableElement and innerTableElement.currentLayer == 2) then
					local secondState = innerTableElement.currentState

					if(k1[key] == k2[key]) then
						return secondState == 1 and k1[innerKey] > k2[innerKey] or secondState == 2 and k1[innerKey] < k2[innerKey]

					elseif(k1[key] ~= k2[key]) then
						return firstState == 1 and k1[key] > k2[key] or firstState == 2 and k1[key] < k2[key]

					end
				end
			end

			if(k1[key] == k2[key]) then
				return firstState == 1 and k1.index > k2.index or firstState == 2 and k1.index < k2.index

			elseif(k1[key] ~= k2[key]) then
				return firstState == 1 and k1[key] > k2[key] or firstState == 2 and k1[key] < k2[key]

			end

		end

	end

	if(not includeOffline) then
		if(k1.isOnline ~= k2.isOnline) then
			if(k1.isOnline) then
				return true
			else
				return false
			
			end
		
		else
			if(k1.status ~= k2.status) then
				return k1.status < k2.status

			end
		end
	end

	return k1.index < k2.index
end

local function createSingleGuildFrame(v)
	local currentFrame = miog.guildSystem.baseFrames[v.fullName]

	currentFrame.BasicInformation.Status:SetTexture("interface/friendsframe/statusicon-" .. (not v.isOnline and "offline" or v.status == 0 and "online" or v.status == 1 and "away" or "dnd"))
	currentFrame.BasicInformation.Name:SetText(WrapTextInColorCode(v.shortName, v.isOnline and C_ClassColor.GetClassColor(v.class):GenerateHexColor() or "FFAAAAAA"))
	currentFrame.BasicInformation.Level:SetText(v.level)
	currentFrame.BasicInformation.Rank:SetText(v.rankName)
	currentFrame.BasicInformation.Keylevel:SetText("+" .. v.keylevel)

	local texture

	if(v.keystone ~= 0) then
		_, _, _, texture = C_ChallengeMode.GetMapUIInfo(v.keystone)
	end

	currentFrame.BasicInformation.Keystone:SetTexture(texture)
	currentFrame.BasicInformation.Score:SetText(v.score)
	currentFrame.BasicInformation.Progress:SetText(v.progressText)

	--currentFrame.layoutIndex = includeOffline == false and (k + (not v.isOnline and 10000 or v.status == 0 and 0 or v.status == 1 and 1000 or 5000)) or k
	currentFrame.BasicInformation.ExpandFrame:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self:AdvanceState()
		currentFrame.node:ToggleCollapsed()
		detailedList[v.fullName] = currentFrame.node:IsCollapsed()
	end)
end

local testTable = {[1] = true, [2] = false}

local function retrieveGuildMembers()	
	includeOffline = miog.Guild.IncludeOffline:GetChecked()

	local DataProvider = CreateTreeDataProvider()
	DataProvider:SetSortComparator(sortGuildList, false)

	miog.Guild.currentDataProvider = DataProvider

    for i = 1, GetNumGuildMembers(), 1 do
    --for i = 1, 40, 1 do
		local name, rankName, rankIndex, level, _, zone, publicNote, officerNote, isOnline, status, class, _, _, isMobile, _, repStanding, guid = GetGuildRosterInfo(i)
		--local name, rankName, rankIndex, level, _, zone, publicNote, officerNote, isOnline, status, class = "Rhany-Ravencrest", "Master", 1, 70, nil, "Here", "PublicNote", "OfficerNote", testTable[random(1, 2)], random(0,2), "WARLOCK"

        local playerName, realm = miog.createSplitName(name)

		local rioProfile = RaiderIO.GetProfile(playerName, realm)

		local score, progress
		local progressWeight = 0

		if(rioProfile) then
			score = rioProfile.mythicKeystoneProfile and rioProfile.mythicKeystoneProfile.currentScore or 0
			
			miog.guildSystem.memberData[name] = miog.guildSystem.memberData[name] or {miog.getRaidSortData(name)}

			if(#miog.guildSystem.memberData[name][3] > 0) then
				progress = ""
				
				for a, b in ipairs(miog.guildSystem.memberData[name][3]) do
					progress = (progress or "") .. wticc(b.parsedString, miog.DIFFICULTY[b.difficulty].color) .. " "
				
					progressWeight = progressWeight + (b.weight or 0)

					if(b.mapId) then

						if(string.find(b.mapId, 10000)) then
							b.mapId = tonumber(strsub(b.mapId, strlen(b.mapId) - 3))
						end
					
						--member.progressTooltipData = member.progressTooltipData .. b.shortName .. ": " .. wticc(miog.DIFFICULTY[b.difficulty].shortName .. ":" .. b.progress .. "/" .. b.bossCount, miog.DIFFICULTY[b.difficulty].color) .. "\r\n"
					end

					if(a == 3) then
						break
					end
				end

				if(progressWeight == 0) then
					progress = ""
				end
			end
		else
			progress = ""
			score = 0
		
		end

		local baseFrameData = DataProvider:Insert({
			template = "MIOG_GuildPlayerTemplate",
            index = name,
            shortName = playerName,
			realm = realm,
            fullName = name,
            rank = rankIndex,
			rankName = rankName,
            level = level,
            zone = zone,
            isOnline = isOnline,
            status = status,
            class = class,
            keystone = miog.guildSystem.keystoneData[name] and miog.guildSystem.keystoneData[name].challengeMapID or MIOG_NewSettings.guildKeystoneInfo[name] and MIOG_NewSettings.guildKeystoneInfo[name].challengeMapID or 0,
            keylevel = miog.guildSystem.keystoneData[name] and miog.guildSystem.keystoneData[name].level or MIOG_NewSettings.guildKeystoneInfo[name] and MIOG_NewSettings.guildKeystoneInfo[name].level or 0,
			score = score,
            progressWeight = progressWeight,
            progressText = progress,
		})

		baseFrameData:Insert({
			template = "MIOG_RaiderIOInformationPanel",
			fullName = name,
		})
	end

	for index, child in ipairs(DataProvider.node.nodes) do
		if(detailedList[child.data.fullName] == false) then
			child:SetCollapsed(false)
			
		else
			child:SetCollapsed(true)
		
		end
	end
	DataProvider:Invalidate();

	miog.Guild.ScrollView:SetDataProvider(DataProvider)
end

local function guildEvents(_, event, ...)
	if(event == "GUILD_ROSTER_UPDATE") then
		if(miog.Guild:IsShown()) then
			retrieveGuildMembers()
			miog.openRaidLib.RequestKeystoneDataFromGuild()
		end
	end
end

miog.loadGuildFrame = function()
    miog.Guild = miog.pveFrame2.TabFramesPanel.Guild
    miog.Guild.sortByCategoryButtons = {}

	for k, v in pairs(miog.Guild) do
		if(type(v) == "table" and v.Button) then
			v.Name:SetText(v:GetParentKey())
			miog.Guild.sortByCategoryButtons[v:GetDebugName()] = v.Button
			v.Button.panel = "Guild"
			v.Button.category = v:GetDebugName()
			v.Button:SetScript("PostClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                
                retrieveGuildMembers()
			end)
		end

	end

	miog.Guild.IncludeOffline:SetScript("OnClick", function(self)
		retrieveGuildMembers()

	end)

	miog.Guild:SetScript("OnShow", function(self)
		retrieveGuildMembers()

	end)

	eventReceiver:RegisterEvent("GUILD_ROSTER_UPDATE")
	eventReceiver:SetScript("OnEvent", guildEvents)

	local ScrollView = CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 2)

	miog.Guild.ScrollView = ScrollView
	
	ScrollUtil.InitScrollBoxListWithScrollBar(miog.Guild.ScrollBox, miog.Guild.ScrollBar, ScrollView)

	local function initializeGuildFrames(frame, node)
		local data = node:GetData()

		if(data.template == "MIOG_GuildPlayerTemplate") then
			frame.node = node
	
			miog.guildSystem.baseFrames[data.fullName] = frame
	
			createSingleGuildFrame(data)
	
		elseif(data.template == "MIOG_RaiderIOInformationPanel") then
			miog.guildSystem.raiderIOPanels[data.fullName] = {RaiderIOInformationPanel = frame}
			
			local playerName, realm = miog.createSplitName(data.fullName)

			miog.retrieveRaiderIOData(playerName, realm, miog.guildSystem.raiderIOPanels[data.fullName])
		end
	end
	
	local function CustomFactory(factory, node)
		local data = node:GetData()
		local template = data.template
		factory(template, initializeGuildFrames)
	end

	ScrollView:SetElementFactory(CustomFactory)

	retrieveGuildMembers()
end