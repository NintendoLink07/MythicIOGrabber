local addonName, miog = ...
local wticc = WrapTextInColorCode

local guildFrames = {}
miog.guildFrames = guildFrames
miog.guildSystem = {}
miog.guildSystem.memberData = {}
miog.guildSystem.keystoneData = {}

local detailedList = {}

local eventReceiver = CreateFrame("Frame", "MythicIOGrabber_GuildEventReceiver")

local guildPool

local function sortGuildList(k1, k2)
	for key, tableElement in pairs(MIOG_SavedSettings.sortMethods.table.guild) do
		if(tableElement and tableElement.currentLayer == 1) then
			local firstState = tableElement.currentState

			for innerKey, innerTableElement in pairs(MIOG_SavedSettings.sortMethods.table.guild) do
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

	return k1.index < k2.index
end

local function resetGuildFrames(_, frame)
	frame:Hide()
	frame.layoutIndex = nil

	frame.BasicInformation.Status:SetTexture(nil)
	frame.BasicInformation.Name:SetText("")
	frame.BasicInformation.Rank:SetText("")
	frame.BasicInformation.Level:SetText("")
	frame.BasicInformation.Keylevel:SetText("")
	frame.BasicInformation.Keystone:SetTexture(nil)
	frame.BasicInformation.Score:SetText("")
	frame.BasicInformation.Progress:SetText("")
end

local function retrieveGuildMembers()
    guildPool:ReleaseAll()

    local guildTable = {}

	local i = 1

    --for i = 1, GetNumGuildMembers(), 1 do
		local name, rankName, rankIndex, level, _, zone, publicNote, officerNote, isOnline, status, class = "Rhany-Ravencrest", "Mythic1", 1, 70, nil, "Here", nil, nil, true, 0, "WARLOCK"
		--local name, rankName, rankIndex, level, _, zone, publicNote, officerNote, isOnline, status, class, _, _, isMobile, _, repStanding, guid = GetGuildRosterInfo(i)

        local nameTable = miog.simpleSplit(name, "-")

		local rioProfile = RaiderIO.GetProfile(nameTable[1], nameTable[2])

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
					--progressTooltipData = nil
				end
			end
		else
			progress = ""
			score = 0
		
		end

		guildTable[i] = {
            index = name,
            shortName = nameTable[1],
			realm = nameTable[2],
            fullName = name,
            rank = rankIndex,
			rankName = rankName,
            level = level,
            zone = zone,
            isOnline = isOnline,
            status = status,
            class = class,
            keystone = miog.guildSystem.keystoneData[name] and miog.guildSystem.keystoneData[name].challengeMapID or MIOG_SavedSettings.guildKeystoneInfo[name] and MIOG_SavedSettings.guildKeystoneInfo[name].challengeMapID or 0,
            keylevel = miog.guildSystem.keystoneData[name] and miog.guildSystem.keystoneData[name].level or MIOG_SavedSettings.guildKeystoneInfo[name] and MIOG_SavedSettings.guildKeystoneInfo[name].level or 0,
			score = score,
            progressWeight = progressWeight,
            progressText = progress,
        }

	--end
	

    table.sort(guildTable, sortGuildList)

	local includeOffline = miog.Guild.IncludeOffline:GetChecked()

    for k, v in ipairs(guildTable) do
        local currentFrame = guildPool:Acquire()

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

        currentFrame.layoutIndex = includeOffline == false and (k + (not v.isOnline and 10000 or v.status == 0 and 0 or v.status == 1 and 1000 or 5000)) or k
        --currentFrame:SetWidth(miog.Guild:GetWidth())
		currentFrame.fixedWidth = miog.Guild:GetWidth()
        --currentFrame.DetailedInformationPanel:SetWidth(miog.Guild:GetWidth())
        currentFrame.BasicInformation.ExpandFrame:SetScript("OnClick", function(self)
            local categoryID = miog.getCurrentCategoryID()

			local infoData = currentFrame.RaiderIOInformationPanel[categoryID == 3 and "raid" or "mplus"]

			currentFrame.RaiderIOInformationPanel.InfoPanel.Previous:SetText(infoData and infoData.previous or "")
			currentFrame.RaiderIOInformationPanel.InfoPanel.Main:SetText(infoData and infoData.main or "")

			currentFrame.RaiderIOInformationPanel:SetShown(not currentFrame.RaiderIOInformationPanel:IsShown())
			detailedList[v.fullName] = currentFrame.RaiderIOInformationPanel:IsShown()

			self:AdvanceState()
			currentFrame:MarkDirty()
        end)

		currentFrame.RaiderIOInformationPanel:SetShown(detailedList[v.fullName] or false)

        currentFrame:Show()

		miog.retrieveRaiderIOData(v.shortName, v.realm, currentFrame)

        guildFrames[v.fullName] = currentFrame
    end

    miog.Guild.ScrollFrame.Container:MarkDirty()
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
			v.Button.panel = "guild"
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

	guildPool = CreateFramePool("Frame", miog.Guild.ScrollFrame.Container, "MIOG_GuildPlayerTemplate", resetGuildFrames)

	eventReceiver:RegisterEvent("GUILD_ROSTER_UPDATE")
	eventReceiver:SetScript("OnEvent", guildEvents)
	
	retrieveGuildMembers()
end