local addonName, miog = ...

local selectedExpansion
local currentCategoryID

GroupCreatorMixin = {}

local function addIconInitializer(button, icon)
	if(icon) then
		button:AddInitializer(function(selfButton)
			local leftTexture = selfButton:AttachTexture();
			leftTexture:SetSize(16, 16);
			leftTexture:SetPoint("LEFT", selfButton, "LEFT", 16, 0);
			leftTexture:SetTexture(icon);

			selfButton.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

			return selfButton.fontString:GetUnboundedStringWidth() + 18 + 5
		end)
	end
end

function GroupCreatorMixin:AddActivities(rootDescription, activityData, addDivider)
	if(currentCategoryID and activityData) then
		if(addDivider) then
			rootDescription:CreateDivider();

		end

		if(activityData.title) then
			rootDescription:CreateTitle(activityData.title)

		end

		for _, activityID in ipairs(activityData.activities) do

			local activityInfo = miog:GetActivityInfo(activityID)

			local activityButton = rootDescription:CreateRadio(activityInfo.fullName, function(data) return self.selectedActivity == data.activityID end, function(data)
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, self.selectedFilters, currentCategoryID, data.groupID, data.activityID)

			end, {activityID = activityID, groupID = activityInfo.groupFinderActivityGroupID})

			if(activityData.icons) then
				addIconInitializer(activityButton, activityInfo.icon)

			end
		end
	end
end

function GroupCreatorMixin:AddGroups(rootDescription, groupsData, addDivider)
	if(currentCategoryID and groupsData) then
		if(addDivider) then
			rootDescription:CreateDivider();

		end

		if(groupsData.title) then
			rootDescription:CreateTitle(groupsData.title)

		end

		for k, v in ipairs(groupsData.groups) do
			local groupInfo = miog:GetGroupInfo(v)
			
			local groupButton = rootDescription:CreateRadio(C_LFGList.GetActivityGroupInfo(v), function(data) return self.selectedGroup == data.groupID end, function(data)
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, self.selectedFilters, currentCategoryID, data.groupID, data.activityID)

			end, {activityID = groupInfo.highestDifficultyActivityID, groupID = v})

			if(groupsData.icons) then
				addIconInitializer(groupButton, groupInfo.icon)

			end
		end
	end
end

function GroupCreatorMixin:AddGroupsAndActivities(rootDescription, groupsData, addDivider)
	if(currentCategoryID and groupsData) then
		if(addDivider) then
			rootDescription:CreateDivider();

		end

		if(groupsData.title) then
			rootDescription:CreateTitle(groupsData.title)

		end

		for k, v in ipairs(groupsData.groups) do
			local activities = C_LFGList.GetAvailableActivities(currentCategoryID, v)

			local groupButton = rootDescription:CreateButton(C_LFGList.GetActivityGroupInfo(v))

			for _, activityID in ipairs(activities) do
				local activityInfo = miog:GetActivityInfo(activityID)

				local activityButton = groupButton:CreateRadio(activityInfo.fullName, function(data) return self.selectedActivity == data.activityID end, function(data)
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, self.selectedFilters, currentCategoryID, data.groupID, data.activityID)

				end, {activityID = activityID, groupID = v})

				if(groupsData.icons) then
					addIconInitializer(activityButton, activityInfo.icon)

				end
			end
		end
	end
end

function GroupCreatorMixin:SetupGroups(dropdown, rootDescription)
	currentCategoryID = LFGListFrame.CategorySelection.selectedCategory or 2

	if(currentCategoryID) then
		local categoryName = C_LFGList.GetLfgCategoryInfo(currentCategoryID).name

		local groups1, groups2, groups3, ga1, ga2, ga3, activities1, activities2, activities3

		if(currentCategoryID == 1) then
			ga1 = {
				groups = C_LFGList.GetAvailableActivityGroups(currentCategoryID, LFGListFrame.CategorySelection.selectedFilters),
				title = categoryName
			}
		elseif(currentCategoryID == 6) then
			activities1 = {
				activities = C_LFGList.GetAvailableActivities(currentCategoryID, 0, 1),
				title = categoryName
			}

		elseif(currentCategoryID == 2) then
			groups1 = {
				groups = C_LFGList.GetAvailableActivityGroups(currentCategoryID, Enum.LFGListFilter.CurrentSeason),
				title = "Seasonal Mythic+ Dungeons",
				icons = true
			}

			groups2 = {
				groups = C_LFGList.GetAvailableActivityGroups(currentCategoryID, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE)),
				title = miog.TIER_INFO[GetNumExpansions()].name .. " Dungeons",
				icons = true
			}

		elseif(currentCategoryID == 3) then
			if(LFGListFrame.CategorySelection.selectedFilters ~= Enum.LFGListFilter.NotRecommended) then
				groups1 = {
					groups = C_LFGList.GetAvailableActivityGroups(currentCategoryID, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.CategorySelection.selectedFilters),
					icons = true
				}

				activities1 = {
					activities = C_LFGList.GetAvailableActivities(currentCategoryID, 0, 5),
					icons = true
				}
			end
		elseif(currentCategoryID == 121) then
			groups1 = {
				groups =  C_LFGList.GetAvailableActivityGroups(currentCategoryID, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.CategorySelection.selectedFilters),
				icons = true
			}

		elseif(currentCategoryID == 4 or currentCategoryID == 7 or currentCategoryID == 8 or currentCategoryID == 9) then
			activities1 = {
				activities = C_LFGList.GetAvailableActivities(currentCategoryID, 0, LFGListFrame.CategorySelection.selectedFilters),
			}

		end

		self:AddGroups(rootDescription, groups1)
		self:AddGroups(rootDescription, groups2, true)
		self:AddGroups(rootDescription, groups3, true)

		self:AddGroupsAndActivities(rootDescription, ga1)
		self:AddGroupsAndActivities(rootDescription, ga2, true)
		self:AddGroupsAndActivities(rootDescription, ga3, true)

		self:AddActivities(rootDescription, activities1)
		self:AddActivities(rootDescription, activities2, true)
		self:AddActivities(rootDescription, activities3, true)

		
		if(currentCategoryID == 2 or currentCategoryID == 3 and LFGListFrame.CategorySelection.selectedFilters == Enum.LFGListFilter.NotRecommended) then
			if(currentCategoryID == 2) then
				rootDescription:CreateTitle(BLIZZARD_STORE_VAS_PREVIOUS_ENTRIES)
				rootDescription:CreateSpacer()

			end

			local expansionButtons = {}

			for i = 1, GetNumExpansions() - 1, 1 do
				local expansionInfo = GetExpansionDisplayInfo(i-1)

				if(expansionInfo) then
					expansionButtons[i] = rootDescription:CreateRadio(miog.TIER_INFO[i].name, function(index) return index == selectedExpansion end, function(index) selectedExpansion = index end, i)
					expansionButtons[i]:AddInitializer(function(button, description, menu)
						local leftTexture = button:AttachTexture();
						leftTexture:SetSize(16, 16);
						leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
						leftTexture:SetTexture(expansionInfo.logo);

						button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

						return button.fontString:GetUnboundedStringWidth() + 18 + 5
					end)
				end
			end

			local allExpansionActivities = C_LFGList.GetAvailableActivities(currentCategoryID, nil, Enum.LFGListFilter.PvE)
			local addedActivities = {}

			for _, activityID in ipairs(allExpansionActivities) do
				local activityInfo = miog:GetActivityInfo(activityID)
				local groupID = activityInfo.groupFinderActivityGroupID
				local name

				if(groupID ~= 0) then
					local groupInfo = miog:GetGroupInfo(groupID)
					activityID = groupInfo.highestDifficultyActivityID or activityID
					name = C_LFGList.GetActivityGroupInfo(groupID)

				else
					groupID = nil
					name = activityInfo.instanceName

				end

				if(not addedActivities[activityID]) then
					if(activityInfo.tier and expansionButtons[activityInfo.tier]) then
						local activityButton = expansionButtons[activityInfo.tier]:CreateRadio(name, function(data) return not self.selectedGroup and self.selectedActivity == data.activityID end, function(data)
							self.selectedActivity = data.activityID
							LFGListEntryCreation_Select(LFGListFrame.EntryCreation, activityInfo.isRaid and Enum.LFGListFilter.NotRecommended or self.selectedFilters, currentCategoryID, data.groupID, data.activityID)

						end, {activityID = activityID, groupID = groupID})

						activityButton:AddInitializer(function(button, description, menu)
							local leftTexture = button:AttachTexture();
							leftTexture:SetSize(16, 16);
							leftTexture:SetPoint("LEFT", button, "LEFT", 16, 0);
							leftTexture:SetTexture(activityInfo.icon);

							button.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0);

							return button.fontString:GetUnboundedStringWidth() + 18 + 5
						end)

						addedActivities[activityID] = true
					end
				end
			end
		end

		local activityButton = rootDescription:CreateRadio("More...", function() end, function()
			LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, LFGListFrame.CategorySelection.selectedCategory, nil, LFGListFrame.CategorySelection.selectedFilters)

		end)
	end
end

function GroupCreatorMixin:SetupActivities(dropdown, rootDescription)
	if(self.selectedGroup) then
		local unsortedActivities = C_LFGList.GetAvailableActivities(currentCategoryID, self.selectedGroup);
		local activities = {}

		local numActivities = #unsortedActivities

		if(#unsortedActivities == 0) then
			unsortedActivities = miog:GetGroupInfo(self.selectedGroup).activities
			
			numActivities = #unsortedActivities
		end

		if(self.selectedCategory == 2 or self.selectedCategory == 3) then
			for k, v in ipairs(unsortedActivities) do
				activities[k] = unsortedActivities[numActivities - k + 1]

			end
		else
			activities = unsortedActivities

		end

		for k, v in ipairs(activities) do
			local activityInfo = miog:GetActivityInfo(v)

			rootDescription:CreateRadio(activityInfo.shortName, function(data) return data.activityID == self.selectedActivity end, function(data)
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, self.selectedFilters, LFGListFrame.CategorySelection.selectedCategory, activityInfo.groupFinderActivityGroupID, v)

			end, {activityID = v, groupID = activityInfo.groupFinderActivityGroupID})
		end

		if(not LFGListFrame.EntryCreation.GroupDropdown:IsShown()) then
			rootDescription:CreateRadio("More...", nil, function()
				LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, LFGListFrame.CategorySelection.selectedCategory, nil, self.selectedFilters)
				
			end)
		end
	end
end

function GroupCreatorMixin:AnchorCheckboxes()

end

function GroupCreatorMixin:SetBlizzardEntryCreationAsStandard()
	local entryCreation = LFGListFrame.EntryCreation
	entryCreation:ClearAllPoints()
	entryCreation:SetParent(self)
	entryCreation:SetAllPoints()
	entryCreation.Inset:ClearAllPoints()
	entryCreation.Inset:SetAllPoints()
	entryCreation.Inset.CustomBG:ClearAllPoints()
	entryCreation.Inset.CustomBG:SetAllPoints()

	entryCreation.Label:Hide()
	
	entryCreation.GroupDropdown:ClearAllPoints()
	entryCreation.GroupDropdown:SetPoint("TOPLEFT", entryCreation, "TOPLEFT", 20, -30)
	entryCreation.GroupDropdown:SetPoint("TOPRIGHT", entryCreation, "TOPRIGHT", -20, -30)

	entryCreation.ActivityDropdown:ClearAllPoints()
	entryCreation.ActivityDropdown:SetPoint("TOPLEFT", entryCreation.GroupDropdown, "BOTTOMLEFT", 0, -4)
	entryCreation.ActivityDropdown:SetPoint("TOPRIGHT", entryCreation.GroupDropdown, "BOTTOMRIGHT", 0, -4)

	entryCreation.PlayStyleDropdown:ClearAllPoints()
	entryCreation.PlayStyleDropdown:SetPoint("TOPLEFT", entryCreation.ActivityDropdown, "BOTTOMLEFT", 0, -4)
	entryCreation.PlayStyleDropdown:SetPoint("TOPRIGHT", entryCreation.ActivityDropdown, "BOTTOMRIGHT", 0, -4)

	entryCreation.NameLabel:ClearAllPoints()
	entryCreation.NameLabel:SetPoint("TOPLEFT", entryCreation.PlayStyleDropdown, "BOTTOMLEFT", 2, -6)

	entryCreation.MythicPlusRating:ClearAllPoints()
	entryCreation.MythicPlusRating:SetPoint("TOPLEFT", entryCreation.Description, "BOTTOMLEFT", -8, -14)

	entryCreation.PVPRating:ClearAllPoints()
	entryCreation.PVPRating:SetPoint("TOPLEFT", entryCreation.Description, "BOTTOMLEFT", -8, -14)

	self.GroupDropdown = entryCreation.GroupDropdown
	self.ActivityDropdown = entryCreation.ActivityDropdown
	self.PlayStyleDropdown = entryCreation.PlayStyleDropdown

	hooksecurefunc("LFGListEntryCreation_Select", function(_, filters, categoryID, groupID, activityID)
		entryCreation.ItemLevel:ClearAllPoints();
		entryCreation.PvpItemLevel:ClearAllPoints();

		if (entryCreation.MythicPlusRating:IsShown()) then
			entryCreation.ItemLevel:SetPoint("TOPLEFT", entryCreation.MythicPlusRating, "BOTTOMLEFT", 0, -3);
			entryCreation.PvpItemLevel:SetPoint("TOPLEFT", entryCreation.MythicPlusRating, "BOTTOMLEFT", 0, -3);

		elseif (entryCreation.PVPRating:IsShown()) then
			entryCreation.ItemLevel:SetPoint("TOPLEFT", entryCreation.PVPRating, "BOTTOMLEFT", 0, -3);
			entryCreation.PvpItemLevel:SetPoint("TOPLEFT", entryCreation.PVPRating, "BOTTOMLEFT", 0, -3);

		else
			entryCreation.ItemLevel:SetPoint("TOPLEFT", entryCreation.Description, "BOTTOMLEFT", -1, -15);
			entryCreation.PvpItemLevel:SetPoint("TOPLEFT", entryCreation.Description, "BOTTOMLEFT", -1, -15);

		end
	end)
end

function GroupCreatorMixin:OnLoad()
	miog.GroupCreator = self
	
	self:SetBlizzardEntryCreationAsStandard()

	--self.GroupDropdown:SetDefaultText("Select a group")
	--self.ActivityDropdown:SetDefaultText("Select an activity")
	--self.PlayStyleDropdown:SetDefaultText("Select a playstyle")
end

function GroupCreatorMixin:OnShow()

	--self.GroupDropdown:SetupMenu(function(dropdown, rootDescription)
		--self:SetupGroups(dropdown, rootDescription)

	--end)
	--LFGListEntryCreation_SetupGroupDropdown(LFGListFrame.EntryCreation)
	
	--self.ActivityDropdown:SetupMenu(function(dropdown, rootDescription)
		--self:SetupActivities(dropdown, rootDescription)
		
	--end)
	--LFGListEntryCreation_SetupActivityDropdown(LFGListFrame.EntryCreation)

    --LFGListEntryCreation_SetupPlayStyleDropdown(self)

	if(LFGListFrame.CategorySelection.selectedCategory) then
		local categoryInfo = C_LFGList.GetLfgCategoryInfo(LFGListFrame.CategorySelection.selectedCategory);

		self.CategoryName:SetText(categoryInfo.name)

	end
end

hooksecurefunc("LFGListUtil_AugmentWithBest", function(filters, categoryID, groupID, activityID)
	print(filters, categoryID, groupID, activityID)

	local myNumMembers = math.max(GetNumGroupMembers(LE_PARTY_CATEGORY_HOME), 1);
	local myItemLevel = GetAverageItemLevel();
	if ( not activityID ) then
		--Find the best activity by iLevel and recommended flag
		local activities = C_LFGList.GetAvailableActivities(categoryID, groupID, filters);
		local bestItemLevel, bestRecommended, bestCurrentArea, bestMinLevel, bestMaxPlayers;
		for i=1, #activities do
			local activityInfo = C_LFGList.GetActivityInfoTable(activities[i]);
			local iLevel = activityInfo and activityInfo.ilvlSuggestion or 0;
			local isRecommended = bit.band(filters, Enum.LFGListFilter.Recommended) ~= 0;
			local currentArea = C_LFGList.GetActivityInfoExpensive(activities[i]);

			local usedItemLevel = myItemLevel;
			local isBetter = false;
			if ( not activityID ) then
				isBetter = true;
			elseif ( currentArea ~= bestCurrentArea ) then
				isBetter = currentArea;
			elseif ( bestRecommended ~= isRecommended ) then
				isBetter = isRecommended;
			elseif ( bestMinLevel ~= activityInfo.minLevel ) then
				isBetter = activityInfo.minLevel > bestMinLevel;
			elseif ( iLevel ~= bestItemLevel ) then
				isBetter = (iLevel > bestItemLevel and iLevel <= usedItemLevel) or
							(iLevel <= usedItemLevel and bestItemLevel > usedItemLevel) or
							(iLevel < bestItemLevel and iLevel > usedItemLevel);
			elseif ( (myNumMembers < activityInfo.maxNumPlayers) ~= (myNumMembers < bestMaxPlayers) ) then
				isBetter = myNumMembers < activityInfo.maxNumPlayers;
			end

			if ( isBetter ) then
				activityID = activities[i];
				bestItemLevel = iLevel;
				bestRecommended = isRecommended;
				bestCurrentArea = currentArea;
				bestMinLevel = activityInfo.minLevel;
				bestMaxPlayers = activityInfo.maxNumPlayers;
			end
		end
	end
end)