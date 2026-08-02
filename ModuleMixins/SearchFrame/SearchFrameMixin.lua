local addonName, miog = ...

local dataProvider

local iTable = {}

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
    self.Status:Hide()
    dataProvider = CreateTreeDataProvider()
    local numOfResults, resultList = C_LFGList.GetFilteredSearchResults()

    self.categoryID = LFGListFrame.SearchPanel.categoryID
    self.filters = LFGListFrame.SearchPanel.filters

    local resultTable = {}
    
    for index, resultID in ipairs(resultList) do
        if(resultID and C_LFGList.HasSearchResultInfo(resultID)) then
			local searchResultInfo = miog:GetSecureSearchResultInfo(resultID)

            if(searchResultInfo) then
				local status =  miog.filter.checkIfSearchResultIsEligible(resultID)
				local _, appStatus = C_LFGList.GetApplicationInfo(resultID)
				
				if(appStatus == "applied" or status ~= false) then
                    local activityInfo = miog:GetActivityInfo(searchResultInfo.activityIDs[1])
                    local isDungeon = activityInfo.categoryID == 2
                    local isRaid = activityInfo.categoryID == 3
                    local isPvp = activityInfo.categoryID == 4 or activityInfo.categoryID == 7 or activityInfo.categoryID == 8 or activityInfo.categoryID == 9
                    
                    local template =
                    activityInfo.categoryID == 1 and "MIOG_SearchFrameQuestingResultFrameTemplate" or
                    isDungeon and "MIOG_SearchFrameDungeonResultFrameTemplate" or
                    isRaid and "MIOG_SearchFrameRaidResultFrameTemplate" or
                    activityInfo.categoryID == 121 and "MIOG_SearchFrameDelvesResultFrameTemplate" or
                    activityInfo.categoryID == 4 and "MIOG_SearchFrameArenaResultFrameTemplate" or
                    activityInfo.categoryID == 9 and "MIOG_SearchFrameBattlegroundResultFrameTemplate" or
                    activityInfo.categoryID == 6 and
                    (activityInfo.maxNumPlayers <= 5 and "MIOG_SearchFrameSmallGroupResultFrameTemplate" or "MIOG_SearchFrameBigGroupResultFrameTemplate")

                    local rating, secondaryRating

                    if(isDungeon) then
                        rating = searchResultInfo.leaderOverallDungeonScore or 0
                        secondaryRating = searchResultInfo.leaderDungeonScoreInfo and searchResultInfo.leaderDungeonScoreInfo[1] and searchResultInfo.leaderDungeonScoreInfo[1].bestRunLevel or 0
                    
                    elseif(isRaid) then
                        local nameTable

                        if(searchResultInfo.leaderName) then
                            nameTable = miog.simpleSplit(searchResultInfo.leaderName, "-")

                            if(nameTable and not nameTable[2]) then
                                nameTable[2] = GetNormalizedRealmName()

                            end
                            
                            local progressData = miog.getRaidProgress(nameTable[1], nameTable[2])

                            if(progressData) then
                                rating, secondaryRating = miog.getWeightFromRaidProgress(progressData)

                            else
                                rating, secondaryRating = 0, 0

                            end

                        else
                            rating, secondaryRating = 0, 0

                        end
                    
                    elseif(isPvp) then
                        local pvpDataExists = searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo[1]

                        if(pvpDataExists) then
                            rating = searchResultInfo.leaderPvpRatingInfo[1].rating
                            secondaryRating = searchResultInfo.leaderPvpRatingInfo[1].tier
                            
                        else
                            rating = 0
                            secondaryRating = 0

                        end

                    else
                        rating = 0
                        secondaryRating = 0

                    end

                    tinsert(resultTable, {
                        template = template,
                        resultID = resultID,
                        activityName = activityInfo.abbreviatedName or activityInfo.fullName,
                        rating = rating,
                        secondaryRating = secondaryRating,
                        applied = appStatus == "applied",
                    })
                end
            end
        end
    end

    local spCategory = LFGListFrame.SearchPanel.categoryID

    local disableRatingSort = not (spCategory == 1 or spCategory == 6 or spCategory == 121)

    self.Header.RatingSort:SetEnabled(disableRatingSort)
    self.Header.SecondaryRatingSort:SetEnabled(disableRatingSort)

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
	searchBox:SetPoint("BOTTOMLEFT", self.Header, "BOTTOMLEFT", 7, 0)
	searchBox:SetPoint("TOPRIGHT", self.Header.SearchButton, "TOPLEFT", -2, 0)
    searchBox:SetFrameStrata("HIGH")
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

                if(bossData and #bossData > 10) then
                    return #bossData > 10 and 60

                end

            else
                --return 20 + ceil(searchResultInfo.numMembers / 10) * 20
                return 20 + ceil(max(activityInfo.maxNumPlayers, 1) / 10) * 20

            end
        end

        return 40

    end)

    self.ScrollBox:Init(view)
    self.sortOrder = {}

    self:HookSearchPanelElements()
    self:AddInputBoxesToDialog()

	miog.SearchFrame = self
end