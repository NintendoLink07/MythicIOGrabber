local addonName, miog = ...

SearchFrameMixin = {}

function SearchFrameMixin:TriggerSort(id)
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

    self:Refresh()
end

function SearchFrameMixin:Refresh()
    local dataProvider = CreateTreeDataProvider()
    local numOfResults, resultList = C_LFGList.GetFilteredSearchResults()

    local resultTable = {}
    
    for index, resultID in ipairs(resultList) do
        if(resultID and C_LFGList.HasSearchResultInfo(resultID)) then
			local searchResultInfo = miog:GetSecureSearchResultInfo(resultID)

            if(searchResultInfo) then
                local activityInfo = miog:GetActivityInfo(searchResultInfo.activityIDs[1])
                local isDungeon = activityInfo.categoryID == 2
                
                local template =
                activityInfo.categoryID == 1 and "MIOG_SearchFrameQuestingResultFrameTemplate" or
                activityInfo.categoryID == 2 and "MIOG_SearchFrameDungeonResultFrameTemplate" or
                activityInfo.categoryID == 3 and "MIOG_SearchFrameRaidResultFrameTemplate" or
                activityInfo.categoryID == 121 and "MIOG_SearchFrameDelvesResultFrameTemplate" or
                activityInfo.categoryID == 4 and "MIOG_SearchFrameArenaResultFrameTemplate" or
                activityInfo.categoryID == 9 and "MIOG_SearchFrameBattlegroundResultFrameTemplate" or
                activityInfo.categoryID == 6 and
                (activityInfo.maxNumPlayers <= 5 and "MIOG_SearchFrameSmallGroupResultFrameTemplate" or "MIOG_SearchFrameBigGroupResultFrameTemplate")

                local rating, secondaryRating

                if(isDungeon) then
                    rating = searchResultInfo.leaderOverallDungeonScore or 0
                    secondaryRating = searchResultInfo.leaderDungeonScoreInfo and searchResultInfo.leaderDungeonScoreInfo[1] and searchResultInfo.leaderDungeonScoreInfo[1].bestRunLevel or 0
                
                else
                    rating = 0
                    secondaryRating = 0

                end

		        local _, appStatus = C_LFGList.GetApplicationInfo(resultID)

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

    local spCategory = LFGListFrame.SearchPanel.categoryID

    local disableRatingSort = not (spCategory == 1 or spCategory == 6 or spCategory == 121)

    self.Header.RatingSort:SetEnabled(disableRatingSort)
    self.Header.SecondaryRatingSort:SetEnabled(disableRatingSort)

    if(self.sortOrder == {}) then
        table.sort(resultTable, function(k1, k2)
            return k1.resultID < k2.resultID
            
        end)
    else
        local iTable = {}
        local numElements = 0

        for k, v in pairs(self.sortOrder) do
            iTable[v.index] = {id = k, state = v.state}
            numElements = numElements + 1
        end

        table.sort(resultTable, function(k1, k2)
            if(k1.applied) then
                return true
                
            elseif(k2.applied) then
                return false

            end

            for index, v in ipairs(iTable) do
                local sortElement = v.state
                local id = v.id

                if(k1[id] ~= k2[id]) then
                    if(sortElement == 1) then
                        return k1[id] < k2[id]

                    elseif(sortElement == 2) then
                        return k1[id] > k2[id]
                        
                    end
                    
                elseif(index == numElements) then
                    return k1.resultID < k2.resultID

                else

                end
            end
        end)

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
        print("NOTHING")

    end

    self.ScrollBox:SetDataProvider(dataProvider)
end

function SearchFrameMixin:FindFrame(resultID)
    return self.ScrollBox:FindFrameByPredicate(function(button, node)
        return node:GetData().resultID == resultID

    end)
end

function SearchFrameMixin:OnEvent(event, ...)
    if(event == "LFG_LIST_SEARCH_RESULTS_RECEIVED") then
        self:Refresh()

    elseif(event == "LFG_LIST_SEARCH_FAILED") then

    elseif(event == "LFG_LIST_SEARCH_RESULT_UPDATED") then
        local resultID = ...

        local frame = self:FindFrame(resultID)

        if(frame) then
            frame:Update()

        end

    elseif(event == "LFG_LIST_APPLICATION_STATUS_UPDATED") then
        local resultID = ...

        local frame = self:FindFrame(resultID)

        if(frame) then
            frame:UpdateApplicationStatus()

        end
    end
end

function SearchFrameMixin:OnLoad()
    BackdropTemplateMixin.OnBackdropLoaded(self)

	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
	self:RegisterEvent("LFG_LIST_SEARCH_FAILED")
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
	self:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

	C_CVar.SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_KEY_RANGE_GROUP_FINDER, true)
    
	local view = CreateScrollBoxListTreeListView(0, 0, 0, 0, 0, 2)

    local function Initializer(frame, node)
		local data = node:GetData()

		if(data.template ~= "MIOG_SearchFrameInfoFrameTemplate") then
            frame:Update()

		end
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
        local searchResultInfo = miog:GetSecureSearchResultInfo(node:GetData().resultID)

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
end