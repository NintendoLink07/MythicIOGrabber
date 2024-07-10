local addonName, miog = ...

miog.debug = {}

miog.referencePVPButtons = {}

miog.debug.currentAverageExecuteTime = {}
miog.debug.timer = nil

local function createBaseCategoryFrame(categoryID, index, canUseLFG, failureReason)
	local categoryFrame = miog.pveFrame2.categoryFramePool:Acquire()

	categoryFrame.categoryID = categoryID
	categoryFrame:SetFrameStrata("FULLSCREEN")

	categoryFrame:SetSize(140, 20)
	categoryFrame.layoutIndex = index
	categoryFrame.BackgroundImage:SetVertTile(true)
	categoryFrame.BackgroundImage:SetTexture(miog.ACTIVITY_BACKGROUNDS[categoryID], nil, "CLAMPTOBLACKADDITIVE")
	categoryFrame.BackgroundImage:SetDesaturated(not canUseLFG)

	miog.createFrameBorder(categoryFrame, 1, CreateColorFromHexString(miog.C.HOVER_COLOR):GetRGBA())

	categoryFrame:SetScript("OnShow", function(self)
		if(not canUseLFG) then
			self:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(failureReason)
				GameTooltip:Show()
			end)
			self:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
		else
			self:SetScript("OnClick", function()
				self:GetParent().setupFunction(self)
				self:GetParent():Hide()
			end)
		
		end
	end)

	return categoryFrame
end

miog.OnEvent = function(_, event, ...)
	if(event == "PLAYER_LOGIN") then
        miog.F.CURRENT_DATE = C_DateAndTime.GetCurrentCalendarTime()

		miog.C.AVAILABLE_ROLES["TANK"], miog.C.AVAILABLE_ROLES["HEALER"], miog.C.AVAILABLE_ROLES["DAMAGER"] = UnitGetAvailableRoles("player")
		
		miog.checkForSavedSettings()

		miog.F.LITE_MODE = MIOG_SavedSettings.liteMode.value

		if(C_AddOns.IsAddOnLoaded("RaiderIO")) then
			miog.F.IS_RAIDERIO_LOADED = true

		end

		miog.createFrames()

		miog.loadSettings()
		miog.loadRawData()
		--miog.loadRaiderIOChecker()
		
		EJ_SetDifficulty(8)
		
		for k, v in pairs(miog.SPECIALIZATIONS) do
			if(k > 25) then
				local _, localizedName, _, _, _, fileName = GetSpecializationInfoByID(k)

				if(localizedName == "") then
					localizedName = "Initial"
				end

				miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[localizedName .. "-" .. fileName] = k
			end
		end
		
		if(not miog.F.LITE_MODE) then
			miog.insertGearingData()

			if(PVPUIFrame) then
				PVPUIFrame:HookScript("OnShow", function()
					ConquestFrame.selectedButton = nil
					ConquestFrame.RatedBG.SelectedTexture:Hide()
					--ConquestFrame.ratedSoloShuffleEnabled = false
					--ConquestFrame.arenasEnabled = false
				end)
				
				hooksecurefunc("HonorFrame_InitSpecificButton", function(button, elementData)
					button:SetHeight(40)
					button.Bg:Hide()
					button.Border:Hide()
					button.Icon:Hide()
					button.InfoText:Hide()
					--button.SelectedTexture:Hide()

					button:SetNormalAtlas("pvpqueue-button-casual-up")
					button:SetPushedAtlas("pvpqueue-button-casual-down")
					button:SetHighlightAtlas("pvpqueue-button-casual-highlight", "ADD")

					button.SizeText:ClearAllPoints()
					button.SizeText:SetFont("SystemFont_Shadow_Med1", 11, "OUTLINE")
					button.SizeText:SetPoint("LEFT", button, "LEFT", 5, 0)

					button.NameText:ClearAllPoints()
					button.NameText:SetFont("SystemFont_Shadow_Med1", 11, "OUTLINE")
					button.NameText:SetTextColor(1, 1, 1, 1)
					button.NameText:SetPoint("LEFT", button.SizeText, "RIGHT", 5, 0)
				end)
			end
		end

	elseif(event == "CHALLENGE_MODE_MAPS_UPDATE") then
		if(miog.F.MPLUS_SETUP_COMPLETE) then
			miog.gatherMPlusStatistics()
		end

    elseif(event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE") then
		if(miog.F.WEEKLY_AFFIX == nil) then
			C_MythicPlus.GetCurrentAffixes() -- Safety call, so Affixes are 100% available

			miog.F.AFFIX_INFO[9] = {C_ChallengeMode.GetAffixInfo(9)} --TYRA
			miog.F.AFFIX_INFO[10] = {C_ChallengeMode.GetAffixInfo(10)} --FORT
			
			miog.setAffixes()
			
			if(miog.F.MPLUS_SETUP_COMPLETE) then
				miog.gatherMPlusStatistics()
			end
        end
	elseif(event == "GROUP_ROSTER_UPDATE") then
		--miog.openRaidLib.RequestKeystoneDataFromParty()
	
	elseif(event == "CURRENCY_DISPLAY_UPDATE") then
		if(miog.MainTab) then
			local bullionInfo = C_CurrencyInfo.GetCurrencyInfo(3010)
			miog.MainTab.Information.Currency.Bullion.Text:SetText(bullionInfo.quantity .. " (" .. bullionInfo.totalEarned .. "/" .. bullionInfo.maxQuantity .. ")")
			miog.MainTab.Information.Currency.Bullion.Icon:SetTexture(4555657)
			miog.MainTab.Information.Currency.Bullion.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetCurrencyByID(3010)
				GameTooltip:Show()
			end)

			local aspectInfo = C_CurrencyInfo.GetCurrencyInfo(2812)
			miog.MainTab.Information.Currency.Aspect.Text:SetText(aspectInfo.quantity .. " (" .. aspectInfo.totalEarned .. "/" .. aspectInfo.maxQuantity .. ")")
			miog.MainTab.Information.Currency.Aspect.Icon:SetTexture(aspectInfo.iconFileID)
			miog.MainTab.Information.Currency.Aspect.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetCurrencyByID(2812)
				GameTooltip:Show()
			end)

			local wyrmInfo = C_CurrencyInfo.GetCurrencyInfo(2809)
			miog.MainTab.Information.Currency.Wyrm.Text:SetText(wyrmInfo.quantity .. " (" .. wyrmInfo.totalEarned .. "/" .. wyrmInfo.maxQuantity .. ")")
			miog.MainTab.Information.Currency.Wyrm.Icon:SetTexture(wyrmInfo.iconFileID)
			miog.MainTab.Information.Currency.Wyrm.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetCurrencyByID(2809)
				GameTooltip:Show()
			end)

			local drakeInfo = C_CurrencyInfo.GetCurrencyInfo(2807)
			miog.MainTab.Information.Currency.Drake.Text:SetText(drakeInfo.quantity .. " (" .. drakeInfo.totalEarned .. "/" .. drakeInfo.maxQuantity .. ")")
			miog.MainTab.Information.Currency.Drake.Icon:SetTexture(drakeInfo.iconFileID)
			miog.MainTab.Information.Currency.Drake.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetCurrencyByID(2807)
				GameTooltip:Show()
			end)

			local whelplingInfo = C_CurrencyInfo.GetCurrencyInfo(2806)
			miog.MainTab.Information.Currency.Whelpling.Text:SetText(whelplingInfo.quantity .. " (" .. whelplingInfo.totalEarned .. "/" .. whelplingInfo.maxQuantity .. ")")
			miog.MainTab.Information.Currency.Whelpling.Icon:SetTexture(whelplingInfo.iconFileID)
			miog.MainTab.Information.Currency.Whelpling.Icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetCurrencyByID(2806)
				GameTooltip:Show()
			end)
		end
		
	elseif(event == "PLAYER_REGEN_DISABLED") then
		miog.pveFrame2:Hide()

	elseif(event == "LFG_LIST_AVAILABILITY_UPDATE") then
		if(C_LFGList.HasActiveEntryInfo() and not miog.EntryCreation:IsVisible()) then
			local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
			local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
		
			miog.startNewGroup({categoryID = activityInfo.categoryID, filters = activityInfo.filters})
		end

		if(not miog.F.LITE_MODE) then
			if(miog.pveFrame2 and miog.pveFrame2.categoryFramePool) then

				local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();

				local index = 0
				miog.pveFrame2.categoryFramePool:ReleaseAll()

				for _, categoryID in ipairs(miog.CUSTOM_CATEGORY_ORDER) do
					index = index + 1

					local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)

					local categoryFrame = createBaseCategoryFrame(categoryID, index, canUse, failureReason)
					categoryFrame.filters = categoryID == 1 and 4 or Enum.LFGListFilter.Recommended
					categoryFrame.Title:SetText(categoryInfo.name)
					categoryFrame:Show()

					if(categoryInfo.separateRecommended) then
						index = index + 1

						local nonRecommendedFrame = createBaseCategoryFrame(categoryID, index, canUse)
						nonRecommendedFrame.filters = categoryInfo.separateRecommended and Enum.LFGListFilter.NotRecommended
						nonRecommendedFrame.Title:SetText(LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, Enum.LFGListFilter.NotRecommended, true))
						nonRecommendedFrame:Show()
						
					end
				end

				miog.pveFrame2.CategoryHoverFrame:MarkDirty()

			end
		end
	end
end


SLASH_MIOG1 = '/miog'
local function handler(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if(command == "") then

	elseif(command == "options") then
		MIOG_OpenInterfaceOptions()

	elseif(command == "debugon_av") then
		if(IsInGroup()) then
			miog.F.IS_IN_DEBUG_MODE = true
			print("Debug mode on - No standard applicants coming through")

			--PVEFrame:Show()
			--LFGListFrame:Show()
			--LFGListPVEStub:Show()
			--LFGListFrame.ApplicationViewer:Show()

			LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)

			miog.createFullEntries(33)

			miog.ApplicationViewer:Show()
		end
	elseif(command == "debugon_av_self") then
		if(IsInGroup()) then
			miog.F.IS_IN_DEBUG_MODE = true
			print("Debug mode on - No standard applicants coming through")

			--PVEFrame:Show()
			--LFGListFrame:Show()
			--LFGListPVEStub:Show()
			--LFGListFrame.ApplicationViewer:Show()

			LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer)

			miog.createAVSelfEntry(rest)

			miog.ApplicationViewer:Show()
		end
	elseif(command == "debugoff_av") then
		miog.releaseApplicantFrames()
		miog.resetArrays()

	elseif(command == "debugon") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

	elseif(command == "debugoff") then
		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false

	elseif(command == "debug_av_perfstart") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

		local index = 1
		local tickRate = 0.2
		local numberOfEntries = 33
		local testLength = (tonumber(rest) or 10) / tickRate -- in seconds

		miog.debug.currentAverageExecuteTime = {}

		miog.debug.debugTimer = C_Timer.NewTicker(tickRate, function(self)

			miog.createFullEntries(numberOfEntries)

			print(miog.debug.currentAverageExecuteTime[#miog.debug.currentAverageExecuteTime])

			index = index + 1

			if(index == testLength) then
				self:Cancel()

				local avg = 0

				for _, v in ipairs(miog.debug.currentAverageExecuteTime) do
					avg = avg + v
				end

				print("Avg exec time: "..(avg / #miog.debug.currentAverageExecuteTime))

				print("Debug mode off - Normal applicant mode")
				miog.F.IS_IN_DEBUG_MODE = false
				miog.releaseApplicantFrames()
				miog.resetArrays()
			end
		end)

	elseif(command == "debug_av_perfstop") then
		if(miog.debug.debugTimer) then
			miog.debug.debugTimer:Cancel()

			local avg = 0

			for _,v in ipairs(miog.debug.currentAverageExecuteTime) do
				avg = avg + v
			end

			print("Avg exec time: "..avg / #miog.debug.currentAverageExecuteTime)
		end

		print("Debug mode off - Normal applicant mode")
		miog.F.IS_IN_DEBUG_MODE = false
		miog.releaseApplicantFrames()
		miog.resetArrays()

	elseif(command == "debug_sp_perfstart") then
		miog.F.IS_IN_DEBUG_MODE = true
		print("Debug mode on - No standard applicants coming through")

		local index = 1
		local tickRate = 0.2
		local testLength = (tonumber(rest) or 10) / tickRate -- in seconds

		miog.debug.currentAverageExecuteTime = {}

		miog.debug.debugTimer = C_Timer.NewTicker(tickRate, function(self)

			local startTime = GetTimePreciseSec()
			miog.updateSearchResultList(true)
			local endTime = GetTimePreciseSec()
		
			miog.debug.currentAverageExecuteTime[#miog.debug.currentAverageExecuteTime+1] = endTime - startTime

			print(miog.debug.currentAverageExecuteTime[#miog.debug.currentAverageExecuteTime])

			index = index + 1

			if(index == testLength) then
				self:Cancel()

				local avg = 0

				for _, v in ipairs(miog.debug.currentAverageExecuteTime) do
					avg = avg + v
				end

				print("Avg exec time: "..(avg / #miog.debug.currentAverageExecuteTime))

				print("Debug mode off - Normal search result mode")
				miog.F.IS_IN_DEBUG_MODE = false
			end
		end)

	elseif(command == "debug_sp_perfstop") then
		if(miog.debug.debugTimer) then
			miog.debug.debugTimer:Cancel()

			local avg = 0

			for _,v in ipairs(miog.debug.currentAverageExecuteTime) do
				avg = avg + v
			end

			print("Avg exec time: "..avg / #miog.debug.currentAverageExecuteTime)
		end

		print("Debug mode off - Normal search result mode")
		miog.F.IS_IN_DEBUG_MODE = false

	elseif(command == "favour") then

		local nameTable = miog.simpleSplit(rest, "-")

		if(not nameTable[2]) then
			nameTable[2] = GetNormalizedRealmName()

			if(nameTable[2]) then
				rest = nameTable[1] .. "-" .. nameTable[2]

			end

		end

		MIOG_SavedSettings.favouredApplicants.table[rest] = {name = nameTable[1], fullName = rest}

	end
end
SlashCmdList["MIOG"] = handler