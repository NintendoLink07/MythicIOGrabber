local addonName, miog = ...

local dataProvider

local iTable = {}
local lastID = nil
local enableRaidComp = false

SearchFrameMixin = {}

function SearchFrameMixin:TriggerSort(button, id)
    local index = 0

    for _ in pairs(self.sortOrder) do
        index = index + 1

    end

    if(self.sortOrder[id]) then
        if(self.sortOrder[id].state == 1) then
            self.sortOrder[id].state = 2

        else
            self.sortOrder[id] = nil

        end
        
    else
        self.sortOrder[id] = {index = index + 1, state = 1}

    end

    if(self.sortOrder[id]) then
        button.SortArrow:SetShown(true)

        if(self.sortOrder[id].state == 1) then
            button.SortArrow:SetTexCoord(0, 1, 0, 1);

        else
            button.SortArrow:SetTexCoord(0, 1, 1, 0);

        end
    else
        button.SortArrow:SetShown(false)

    end

    self:Refresh()
end

local function sortResults(k1, k2)
    if(k1.applied ~= k2.applied) then
        return k1.applied

    end

    for _, v in ipairs(iTable) do
        local sortElement = v.state
        local id = v.id

        local val1 = k1[id]
        local val2 = k2[id]

        if(val1 ~= val2) then
            if(sortElement == 1) then
                return val1 > val2

            elseif(sortElement == 2) then
                return val1 < val2
                
            end
        end
    end

    return k1.resultID < k2.resultID
end

function SearchFrameMixin:RefreshSearchStatus()
    if(dataProvider) then
        dataProvider:Flush()
    end

    self.Status:SetText(LFGListFrame.SearchPanel.searchFailed and LFG_LIST_SEARCH_FAILED or LFG_LIST_NO_RESULTS_FOUND)
    self.Status:Show()
end

function SearchFrameMixin:Refresh()
    enableRaidComp = self.Footer.RaidCompButton:GetChecked()

    self.Status:Hide()
    dataProvider = CreateTreeDataProvider()
    local numOfResults, resultList = C_LFGList.GetFilteredSearchResults()

    self.categoryID = LFGListFrame.SearchPanel.categoryID
    self.filters = LFGListFrame.SearchPanel.filters

    local resultTable = {}
    -- Counter for manual table insertion
    local resultIndex = #resultTable

    -- 2. Use a standard numeric for-loop instead of ipairs
    for i = 1, #resultList do
        local resultID = resultList[i]
        if(resultID and C_LFGList.HasSearchResultInfo(resultID)) then
			local searchResultInfo = miog:GetSecureSearchResultInfo(resultID)

            if(searchResultInfo) then
				local _, appStatus = C_LFGList.GetApplicationInfo(resultID)
                local isApplied = appStatus == "applied"
				
				if(isApplied or miog.filter.checkIfSearchResultIsEligible(resultID) ~= false) then
                    local activityInfo = miog:GetActivityInfo(searchResultInfo.activityIDs[1])
                    local categoryID = activityInfo.categoryID
                    local isDungeon = categoryID == 2
                    local isRaid = categoryID == 3
                    local isPvp = categoryID == 4 or categoryID == 9
                    
                    local template

                    if isDungeon then
                        template = "MIOG_SearchFrameDungeonResultFrameTemplate"
                    elseif isRaid then
                        template = enableRaidComp and "MIOG_SearchFrameRaidResultFrameWithCompositionTemplate" or "MIOG_SearchFrameRaidResultFrameTemplate"
                    elseif categoryID == 121 then
                        template = "MIOG_SearchFrameDelvesResultFrameTemplate"
                    elseif categoryID == 4 then
                        template = "MIOG_SearchFrameArenaResultFrameTemplate"
                    elseif categoryID == 9 then
                        template = "MIOG_SearchFrameBattlegroundResultFrameTemplate"
                    elseif categoryID == 1 then
                        template = activityInfo.maxNumPlayers > 5 and "MIOG_SearchFrameBigGroupResultFrameTemplate" or "MIOG_SearchFrameSmallGroupResultFrameTemplate"
                    elseif categoryID == 6 then
                        template = (activityInfo.maxNumPlayers <= 5 and activityInfo.maxNumPlayers ~= 0) and "MIOG_SearchFrameSmallGroupResultFrameTemplate" or "MIOG_SearchFrameBigGroupResultFrameTemplate"
                    end

                    local rating, secondaryRating

                    if(isDungeon) then
                        rating = searchResultInfo.leaderOverallDungeonScore or 0
                        --secondaryRating = searchResultInfo.leaderDungeonScoreInfo and searchResultInfo.leaderDungeonScoreInfo[1] and searchResultInfo.leaderDungeonScoreInfo[1].bestRunLevel or 0
                    
                    elseif(isRaid) then
                        if(searchResultInfo.leaderName) then
                            local name, realm = strsplit("-", searchResultInfo.leaderName)

                            if not realm then
                                realm = GetNormalizedRealmName()
                                
                            end
                            
                            local raidData = miog:GetRaidTierDataViaRaiderIO(name, realm)
                            
                            if(raidData) then
                                rating = raidData[1] and raidData[1].tierWeight or 0
                                --secondaryRating = raidData[2] and raidData[2].tierWeight or 0

                            else
                                rating = 0
                                --secondaryRating = 0

                            end

                            --[[local progressData = miog.getRaidProgress(nameTable[1], nameTable[2])

                            if(progressData) then
                                rating, secondaryRating = miog.getWeightFromRaidProgress(progressData)

                            else
                                rating, secondaryRating = 0, 0

                            end]]

                        else
                            rating = 0
                            --secondaryRating = 0

                        end
                    
                    elseif(isPvp) then
                        local pvpDataExists = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo[1]

                        if(pvpDataExists) then
                            rating = searchResultInfo.leaderPvpRatingInfo[1].rating
                            --secondaryRating = searchResultInfo.leaderPvpRatingInfo[1].tier
                            
                        else
                            rating = 0
                            --secondaryRating = 0

                        end

                    else
                        rating = 0
                        --secondaryRating = 0

                    end

                    resultIndex = resultIndex + 1
                    resultTable[resultIndex] = {
                        template = template,
                        resultID = resultID,
                        activityName = activityInfo.abbreviatedName or activityInfo.fullName,
                        rating = rating,
                        applied = isApplied,
                    }
                end
            end
        end
    end

    local spCategory = LFGListFrame.SearchPanel.categoryID

    local disableRatingSort = (spCategory == 1 or spCategory == 6 or spCategory == 121)

    self.Header.RatingSort:SetEnabled(not disableRatingSort)

    if(disableRatingSort) then
        self.Header.RatingSort.Text:SetTextColor(GRAY_FONT_COLOR:GetRGBA())

    else
        self.Header.RatingSort.Text:SetTextColor(WHITE_FONT_COLOR:GetRGBA())

    end

    --local sortOrder = miog.FilterSettings:GetSortOrder()

    if(self.sortOrder == {}) then
        table.sort(resultTable, function(k1, k2)
            return k1.resultID < k2.resultID
            
        end)
    else
        iTable = {}
        local numElements = 0

        for k, v in pairs(self.sortOrder) do
            iTable[v.index] = {id = k, state = v.state}
            numElements = numElements + 1

        end

        table.sort(resultTable, sortResults)

    end

    local numOfFinishedResults = #resultTable

    if(numOfFinishedResults > 0) then
        for index = 1, numOfFinishedResults do
            local data = resultTable[index]

            local baseFrame = dataProvider:Insert(data)
            baseFrame:SetCollapsed(true)
            baseFrame:Insert({
                template = "MIOG_SearchFrameInfoFrameTemplate",
                resultID = data.resultID,
            })
        end
    else
        self:RefreshSearchStatus()

    end

    self.ScrollBox:SetDataProvider(dataProvider)
end

function SearchFrameMixin:FindNodeFrame(resultID)
    return self.ScrollBox:FindFrameByPredicate(function(button, node)
        local data = node:GetData()
        return data.resultID == resultID and data.template ~= "MIOG_SearchFrameInfoFrameTemplate"

    end)
end

function SearchFrameMixin:FindInfoFrame(resultID)
    return self.ScrollBox:FindFrameByPredicate(function(button, node)
        local data = node:GetData()
        return data.resultID == resultID and data.template == "MIOG_SearchFrameInfoFrameTemplate"

    end)
end

function SearchFrameMixin:OnEvent(event, ...)
    if(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
        self:Refresh()

    elseif(event == "LFG_LIST_SEARCH_FAILED") then
        self:RefreshSearchStatus()

    elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
        local resultID = ...

        local frame = self:FindNodeFrame(resultID)

        if(frame) then
            frame:Update()

            if(not frame:IsCollapsed()) then
                local infoFrame = self:FindInfoFrame(resultID)

                if(infoFrame) then
                    infoFrame:Update()

                end
            end
        end

        self.Footer.SignUp:SetEnabled(LFGListFrame.SearchPanel.SignUpButton:IsEnabled())

    elseif(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID = ...

        local frame = self:FindNodeFrame(resultID)

        if(frame) then
            frame:UpdateApplicationStatus()

            local infoFrame = self:FindInfoFrame(resultID)
            
            if(infoFrame) then
                infoFrame:Update()

            end
        end
    end
end


function SearchFrameMixin:OnShow()
	local searchBox = LFGListFrame.SearchPanel.SearchBox
	searchBox:ClearAllPoints()
    searchBox:SetParent(self)
	searchBox:SetPoint("TOPLEFT", self.Header, "TOPLEFT", 8, -2)
	searchBox:SetPoint("TOPRIGHT", self.Header.SearchButton, "TOPLEFT", 1, -2)
    searchBox:SetFrameStrata("HIGH")
    searchBox.Left:Hide()
    searchBox.Middle:Hide()
    searchBox.Right:Hide()
    self.SearchBox = searchBox

    C_LFGList.ClearApplicationTextFields = function() end
end

function SearchFrameMixin:HookSearchPanelElements()
    self.SearchingSpinner = LFGListFrame.SearchPanel.SearchingSpinner
    self.ScrollBox.NoResultsFound = LFGListFrame.SearchPanel.ScrollBox.NoResultsFound
    self.ScrollBox.StartGroupButton = LFGListFrame.SearchPanel.ScrollBox.StartGroupButton
    self.SignUpButton = LFGListFrame.SearchPanel.SignUpButton
    self.LeaverBadge = LFGListFrame.SearchPanel.LeaverBadge
    self.BackButton = LFGListFrame.SearchPanel.BackButton
    self.BackToGroupButton = LFGListFrame.SearchPanel.BackToGroupButton
    self.AutoCompleteFrame = LFGListFrame.SearchPanel.AutoCompleteFrame
	self:GetParent().EntryCreation = miog.GroupCreator

end

function SearchFrameMixin:UpdateFooter()
    miog.Plugin.FooterBar.Results:SetText(filteredResultNumber .. "(" .. totalResultNumber .. ")")
	
	miog.Plugin.FooterBar.Results:SetScript("OnEnter", setSearchScript and function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("There might be more groups listed.")
		GameTooltip:AddLine("Try to pre-filter by typing something in the search bar.")
		GameTooltip:Show()
	end or nil)
end

function SearchFrameMixin:AddInputBoxesToDialog()
    local appDialogParentFrame = CreateFrame("Frame", nil, LFGListApplicationDialog, "MIOG_ApplicationDialogParentTemplate")

	local textboxView = CreateScrollBoxListLinearView(4, 2, 1, 1, 2);
	
	local function repopulateAppDialogBox()
		local provider = CreateDataProvider()
		for k, v in ipairs(MIOG_CharacterSettings.appDialogTexts) do
			provider:Insert({index = k, text = v})
	
		end

		if(provider:GetSize() == 0) then
			provider:Insert({index = 1, text = ""})

		end

		textboxView:SetDataProvider(provider, true)
	end

	appDialogParentFrame.Checkbox:SetScript("OnClick", function(selfFrame)
		local currentState = selfFrame:GetChecked()
		selfFrame:GetParent().Textbox:SetShown(currentState)
		MIOG_CharacterSettings.appDialogBoxExtented = currentState
	end)
	appDialogParentFrame.Checkbox:SetChecked(MIOG_CharacterSettings.appDialogBoxExtented)
	appDialogParentFrame.Textbox:SetShown(MIOG_CharacterSettings.appDialogBoxExtented)

	textboxView:SetElementInitializer("MIOG_ApplicationDialogTextboxInputTemplate", function(frame, data)
		frame.InputBox:SetText(data.text)

		MIOG_CharacterSettings.appDialogTexts[data.index] = data.text

		frame.InputBox:SetScript("OnTextChanged", function(selfFrame, userInput)
			if(userInput) then
				MIOG_CharacterSettings.appDialogTexts[data.index] = selfFrame:GetText()

			end
		end)

		if(data.index > 1) then
			frame.DeleteButton:SetScript("OnClick", function(_, button)
				table.remove(MIOG_CharacterSettings.appDialogTexts, data.index)

				repopulateAppDialogBox()
			end)
		else
			frame.DeleteButton:Hide()

		end
	end)
	textboxView:SetElementExtent(48)
	textboxView:SetElementResetter(function(frame, data)
		frame.DeleteButton:Show()

	end)
	ScrollUtil.InitScrollBoxListWithScrollBar(appDialogParentFrame.Textbox.ScrollBox, appDialogParentFrame.Textbox.ScrollBar, textboxView);

	repopulateAppDialogBox()

	appDialogParentFrame.AddInputBoxButton:SetParent(appDialogParentFrame.Textbox)
	appDialogParentFrame.AddInputBoxButton:SetScript("OnClick", function(_, button)
		local provider = textboxView:GetDataProvider()

		provider:Insert({index = provider:GetSize() + 1, text = ""})
		
	end)
end

function SearchFrameMixin:OnLoad()
    local visualTable = {
        edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 2
    }
    local r, g, b, a = GRAY_FONT_COLOR:GetRGBA()
	self:SetBackdrop(visualTable)
	self:SetBackdropBorderColor(r, g, b, a)

	self.Footer:SetBackdrop(visualTable)
	self.Footer:SetBackdropBorderColor(r, g, b, a)

	self.Header.ActivitySort:SetBackdrop(visualTable)
	self.Header.ActivitySort:SetBackdropBorderColor(r, g, b, a)

	self.Header.RatingSort:SetBackdrop(visualTable)
	self.Header.RatingSort:SetBackdropBorderColor(r, g, b, a)

    self.Footer.RaidCompButton.Text:SetText("Enable raid comp")
    self.Footer.RaidCompButton:SetOnClick(function(selfButton)
        self:Refresh()

    end)

    self.Footer.RaidCompButton:SetScript("OnEnter", function(selfFrame)
        GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Toggle showing the raid composition for a raid search result")
        GameTooltip:Show()

    end)

	--self.Header.SecondaryRatingSort:SetBackdrop(visualTable)
	--self.Header.SecondaryRatingSort:SetBackdropBorderColor(r, g, b, a)

	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	self:RegisterEvent("LFG_LIST_SEARCH_FAILED")
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	self:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

	C_CVar.SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_KEY_RANGE_GROUP_FINDER, true)
    
	local view = CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 4)

    local function Initializer(frame, node)
		local data = node:GetData()

        frame:Update()
	end
	
	local function CustomFactory(factory, node)
		local data = node:GetData()
		factory(data.template, Initializer)
	end

	view:SetElementFactory(CustomFactory)
	view:SetElementResetter(function(frame)
        if(frame.Reset) then
            frame:Reset()

        end
	end)
    view:SetElementExtentCalculator(function(dataIndex, node)
        local data = node:GetData()

        if(data.template == "MIOG_SearchFrameInfoFrameTemplate") then
            return 146

        end

        local searchResultInfo = miog:GetSecureSearchResultInfo(data.resultID)

        if(searchResultInfo) then
            local activityID = searchResultInfo.activityIDs[1]
            local activityInfo = miog:GetActivityInfo(activityID)

            if(activityInfo.categoryID == 3) then
                local bossData = activityInfo.bosses
                local offset = enableRaidComp and 18 or 0

                if(bossData and #bossData > 10) then
                    return 58 + offset

                else
                    return 40 + offset

                end
            else
                local maxPlayers = activityInfo.maxNumPlayers ~= 0 and activityInfo.maxNumPlayers or (activityInfo.categoryID ~= 6 and 5 or 40)
                local rows = ceil(maxPlayers / 10)
                return 20 + rows * 20

            end
        end

        return 40
    end)

    ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self:GetParent():GetParent():GetParent().ScrollBarArea.SearchPanelScrollBar, view)
    self.sortOrder = {}

    self:HookSearchPanelElements()
    self:AddInputBoxesToDialog()

	miog.SearchFrame = self

    hooksecurefunc("LFGListSearchPanel_SelectResult", function(searchPanel, resultID)
        if(lastID and miog:GetSecureSearchResultInfo(lastID)) then
            local frame = self:FindNodeFrame(lastID)

            if(frame) then
                frame:Update()

            end
        end
        
        self.Footer.SignUp:SetEnabled(searchPanel.SignUpButton:IsEnabled())

        lastID = resultID
    end)
    
end