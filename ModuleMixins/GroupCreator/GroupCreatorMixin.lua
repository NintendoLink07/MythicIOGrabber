local addonName, miog = ...

local selectedExpansion
local currentCategoryID

local firstGroup, firstActivity

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
	if(rootDescription and activityData) then
		if(addDivider) then
			rootDescription:CreateDivider();

		end

		if(activityData.title) then
			rootDescription:CreateTitle(activityData.title)

		end

		for _, activityID in ipairs(activityData.activities) do
			if(not firstActivity) then
				firstActivity = activityID

			end

			local activityInfo = miog:GetActivityInfo(activityID)

			local activityButton = rootDescription:CreateRadio(activityInfo.fullName, function(data) return LFGListFrame.EntryCreation.selectedActivity == data.activityID end, function(data)
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, self.selectedFilters, currentCategoryID, data.groupID, data.activityID)

			end, {activityID = activityID, groupID = activityInfo.groupFinderActivityGroupID})

			if(activityData.icons) then
				addIconInitializer(activityButton, activityInfo.icon)

			end
		end
	end
end

function GroupCreatorMixin:AddGroups(rootDescription, groupsData, addDivider)
	if(rootDescription and groupsData) then
		if(addDivider) then
			rootDescription:CreateDivider();

		end

		if(groupsData.title) then
			rootDescription:CreateTitle(groupsData.title)

		end

		for k, v in ipairs(groupsData.groups) do
			if(not firstGroup) then
				firstGroup = v
				
			end

			local groupInfo = miog:GetGroupInfo(v)
			
			local groupButton = rootDescription:CreateRadio(C_LFGList.GetActivityGroupInfo(v), function(data) return LFGListFrame.EntryCreation.selectedGroup == data.groupID end, function(data)
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, self.selectedFilters, currentCategoryID, data.groupID, data.activityID)

			end, {activityID = groupInfo.highestDifficultyActivityID, groupID = v})

			if(groupsData.icons) then
				addIconInitializer(groupButton, groupInfo.icon)

			end
		end
	end
end

function GroupCreatorMixin:AddGroupsAndActivities(rootDescription, groupsData, addDivider)
	if(rootDescription and groupsData) then
		if(addDivider) then
			rootDescription:CreateDivider();

		end

		if(groupsData.title) then
			rootDescription:CreateTitle(groupsData.title)

		end

		for k, v in ipairs(groupsData.groups) do
			if(not firstGroup) then
				firstGroup = v
				
			end

			local activities = C_LFGList.GetAvailableActivities(currentCategoryID, v)

			local groupButton = rootDescription:CreateRadio(C_LFGList.GetActivityGroupInfo(v), function(data) return LFGListFrame.EntryCreation.selectedGroup == data.groupID end, nil, {groupID = v})

			for _, activityID in ipairs(activities) do
				if(not firstActivity) then
					firstActivity = activityID

				end

				local activityInfo = miog:GetActivityInfo(activityID)

				local activityButton = groupButton:CreateRadio(activityInfo.fullName, function(data) return LFGListFrame.EntryCreation.selectedActivity == data.activityID end, function(data)
					LFGListEntryCreation_Select(LFGListFrame.EntryCreation, self.selectedFilters, currentCategoryID, data.groupID, data.activityID)

				end, {activityID = activityID, groupID = v})

				if(groupsData.icons) then
					addIconInitializer(activityButton, activityInfo.icon)

				end
			end
		end
	end
end

function GroupCreatorMixin:GetSimpleDelveGroups()
	return C_LFGList.GetAvailableActivityGroups(currentCategoryID, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.EntryCreation.selectedFilters)

end

function GroupCreatorMixin:GetAdvancedDelveGroups()
	local groups = C_LFGList.GetAvailableActivityGroups(121)

	local activityInfos = {}

	for k, v in ipairs(groups) do
		local groupInfo = miog:GetGroupInfo(v)
		local firstActivity = miog:GetActivityInfo(groupInfo.activities[1])
		
		activityInfos[v] = {orderIndex = firstActivity.filters or 0, name = groupInfo.name}
	end

	table.sort(groups, function(k1, k2)
		if(activityInfos[k1].orderIndex == activityInfos[k2].orderIndex) then
			return activityInfos[k1].name < activityInfos[k2].name
			
		else
			return activityInfos[k1].orderIndex > activityInfos[k2].orderIndex

		end
	end)

	return groups
end

function GroupCreatorMixin:SetupGroups(dropdown, rootDescription)
	currentCategoryID = LFGListFrame.EntryCreation.selectedCategory

	firstActivity = nil
	firstGroup = nil

	if(currentCategoryID) then
		local categoryName = C_LFGList.GetLfgCategoryInfo(currentCategoryID).name

		local groups1, groups2, groups3, ga1, ga2, ga3, activities1, activities2, activities3

		if(currentCategoryID == 1) then
			ga1 = {
				groups = C_LFGList.GetAvailableActivityGroups(currentCategoryID, LFGListFrame.EntryCreation.selectedFilters),
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
			if(LFGListFrame.EntryCreation.selectedFilters ~= Enum.LFGListFilter.NotRecommended) then
				groups1 = {
					groups = C_LFGList.GetAvailableActivityGroups(currentCategoryID, IsPlayerAtEffectiveMaxLevel() and bit.bor(Enum.LFGListFilter.Recommended, Enum.LFGListFilter.PvE) or LFGListFrame.EntryCreation.selectedFilters),
					icons = true
				}

				activities1 = {
					activities = C_LFGList.GetAvailableActivities(currentCategoryID, 0, 5),
					icons = true
				}
			end
		elseif(currentCategoryID == 121) then
			groups1 = {
				groups = self:GetSimpleDelveGroups()
				--groups = self:GetAdvancedDelveGroups()
			}

		elseif(currentCategoryID == 4 or currentCategoryID == 7 or currentCategoryID == 8 or currentCategoryID == 9) then
			activities1 = {
				activities = C_LFGList.GetAvailableActivities(currentCategoryID, 0, LFGListFrame.EntryCreation.selectedFilters),
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

		
		if(rootDescription) then
			if(currentCategoryID == 2 or currentCategoryID == 3 and LFGListFrame.EntryCreation.selectedFilters == Enum.LFGListFilter.NotRecommended) then
				if(currentCategoryID == 2) then
					rootDescription:CreateTitle(BLIZZARD_STORE_VAS_PREVIOUS_ENTRIES)
					rootDescription:CreateSpacer()

				end

				local expansionButtons = {}

				for i = 1, GetNumExpansions() - 1, 1 do
					local expansionInfo = GetExpansionDisplayInfo(i-1)

					if(expansionInfo) then
						expansionButtons[i] = rootDescription:CreateRadio(miog.TIER_INFO[i].name, function(index) return index == selectedExpansion end, nil, i)
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
							local activityButton = expansionButtons[activityInfo.tier]:CreateRadio(name, function(data) return LFGListFrame.EntryCreation.selectedGroup == data.groupID end, function(data)
								selectedExpansion = activityInfo.tier
								LFGListFrame.EntryCreation.selectedActivity = data.activityID
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
				LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, LFGListFrame.EntryCreation.selectedCategory, nil, LFGListFrame.EntryCreation.selectedFilters)

			end)
		end
	end
end

function GroupCreatorMixin:SetupActivities(dropdown, rootDescription)
	if(LFGListFrame.EntryCreation.selectedGroup) then
		local unsortedActivities = C_LFGList.GetAvailableActivities(currentCategoryID, LFGListFrame.EntryCreation.selectedGroup);
		local activities = {}

		local numActivities = #unsortedActivities

		if(#unsortedActivities == 0) then
			unsortedActivities = miog:GetGroupInfo(LFGListFrame.EntryCreation.selectedGroup).activities
			
			numActivities = #unsortedActivities
		end

		if(LFGListFrame.EntryCreation.selectedCategory == 2 or LFGListFrame.EntryCreation.selectedCategory == 3) then
			for k, v in ipairs(unsortedActivities) do
				activities[k] = unsortedActivities[numActivities - k + 1]

			end
		else
			activities = unsortedActivities

		end

		for k, v in ipairs(activities) do
			local activityInfo = miog:GetActivityInfo(v)

			rootDescription:CreateRadio(activityInfo.shortName, function(data) return data.activityID == LFGListFrame.EntryCreation.selectedActivity end, function(data)
				LFGListEntryCreation_Select(LFGListFrame.EntryCreation, self.selectedFilters, LFGListFrame.EntryCreation.selectedCategory, activityInfo.groupFinderActivityGroupID, v)

			end, {activityID = v, groupID = activityInfo.groupFinderActivityGroupID})
		end

		if(not LFGListFrame.EntryCreation.GroupDropdown:IsShown()) then
			rootDescription:CreateRadio("More...", nil, function()
				LFGListEntryCreationActivityFinder_Show(LFGListFrame.EntryCreation.ActivityFinder, LFGListFrame.EntryCreation.selectedCategory, nil, self.selectedFilters)
				
			end)
		end
	end
end

function GroupCreatorMixin:ChooseSuitableActivity()
	local filters, categoryID, groupID, activityID = LFGListUtil_AugmentWithBest(bit.bor(self.baseFilters or 0, filters or 0), categoryID, groupID, activityID);


end

function GroupCreatorMixin:SetBlizzardEntryCreationAsStandard()
	local entryCreation = LFGListFrame.EntryCreation
	entryCreation:ClearAllPoints()
	entryCreation:SetParent(self)
	entryCreation:SetAllPoints()
	entryCreation.Inset:ClearAllPoints()
	entryCreation.Inset:SetAllPoints()
	entryCreation.Inset.CustomBG:ClearAllPoints()
	entryCreation.Inset.CustomBG:SetPoint("TOPLEFT", entryCreation.Inset, "TOPLEFT")
	entryCreation.Inset.CustomBG:SetPoint("BOTTOMRIGHT", entryCreation.Inset, "RIGHT", 0, 56)

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

	entryCreation.MythicPlusRating:ClearAllPoints()
	entryCreation.MythicPlusRating:SetPoint("TOPLEFT", entryCreation.Description, "BOTTOMLEFT", -8, -14)

	entryCreation.PVPRating:ClearAllPoints()
	entryCreation.PVPRating:SetPoint("TOPLEFT", entryCreation.Description, "BOTTOMLEFT", -8, -14)

	entryCreation.CancelButton:SetPoint("BOTTOMLEFT", entryCreation, "BOTTOMLEFT", 2, 2)
	entryCreation.ListGroupButton:SetPoint("BOTTOMRIGHT", entryCreation, "BOTTOMRIGHT", 1, 2)

	self.GroupDropdown = entryCreation.GroupDropdown
	self.ActivityDropdown = entryCreation.ActivityDropdown
	self.PlayStyleDropdown = entryCreation.PlayStyleDropdown

	self.GroupDropdown:SetSelectionText(function(currentSelections)
		-- overrideName assigned when an option is picked from the dialog.
		if(self.GroupDropdown.overrideName) then
			return self.GroupDropdown.overrideName;
		end

		if(LFGListFrame.EntryCreation.selectedCategory == 3 and LFGListFrame.EntryCreation.selectedFilters == Enum.LFGListFilter.NotRecommended) then
			local currentSelection = currentSelections[2] or currentSelections[1];

			if(currentSelection) then
				return MenuUtil.GetElementText(currentSelection);

			end
		end

		return nil;
	end);

	hooksecurefunc("LFGListEntryCreation_Select", function(_, filters, categoryID, groupID, activityID)
		LFGListFrame.EntryCreation.ItemLevel:ClearAllPoints();
		LFGListFrame.EntryCreation.PvpItemLevel:ClearAllPoints();

		if(LFGListFrame.EntryCreation.MythicPlusRating:IsShown()) then
			LFGListFrame.EntryCreation.ItemLevel:SetPoint("TOPLEFT", LFGListFrame.EntryCreation.MythicPlusRating, "BOTTOMLEFT", 0, -3);
			LFGListFrame.EntryCreation.PvpItemLevel:SetPoint("TOPLEFT", LFGListFrame.EntryCreation.MythicPlusRating, "BOTTOMLEFT", 0, -3);

		elseif(LFGListFrame.EntryCreation.PVPRating:IsShown()) then
			LFGListFrame.EntryCreation.ItemLevel:SetPoint("TOPLEFT", LFGListFrame.EntryCreation.PVPRating, "BOTTOMLEFT", 0, -3);
			LFGListFrame.EntryCreation.PvpItemLevel:SetPoint("TOPLEFT", LFGListFrame.EntryCreation.PVPRating, "BOTTOMLEFT", 0, -3);

		else
			LFGListFrame.EntryCreation.ItemLevel:SetPoint("TOPLEFT", LFGListFrame.EntryCreation.Description, "BOTTOMLEFT", -1, -15);
			LFGListFrame.EntryCreation.PvpItemLevel:SetPoint("TOPLEFT", LFGListFrame.EntryCreation.Description, "BOTTOMLEFT", -1, -15);

		end

		LFGListFrame.EntryCreation.NameLabel:ClearAllPoints()
		LFGListFrame.EntryCreation.NameLabel:SetPoint("TOPLEFT", LFGListFrame.EntryCreation.PlayStyleDropdown, "BOTTOMLEFT", 2, -16)

		local activityInfo = miog:GetActivityInfo(LFGListFrame.EntryCreation.selectedActivity)

		if(activityInfo) then
			LFGListFrame.EntryCreation.Inset.CustomBG:SetTexture(activityInfo.horizontal)

			if(activityInfo.tier) then
				selectedExpansion = activityInfo.tier

			end
		end

		if(LFGListFrame.EntryCreation.selectedCategory) then
			local categoryInfo = C_LFGList.GetLfgCategoryInfo(LFGListFrame.EntryCreation.selectedCategory);

			self.CategoryName:SetText(LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, LFGListFrame.EntryCreation.selectedFilters, false))

		end
	end)

	hooksecurefunc("LFGListEntryCreation_SetupGroupDropdown", function()
		self.GroupDropdown:SetupMenu(function(dropdown, rootDescription)
			rootDescription:SetTag("MENU_LFG_FRAME_GROUP");
			self:SetupGroups(dropdown, rootDescription)
		end)
	end)

	self.CategorySelection = LFGListFrame.CategorySelection
	self.ApplicationViewer = LFGListFrame.ApplicationViewer
	self.SearchPanel = LFGListFrame.SearchPanel
end

function GroupCreatorMixin:OnLoad()
	miog.GroupCreator = self
	
	self:SetBlizzardEntryCreationAsStandard()

	--self.GroupDropdown:SetDefaultText("Select a group")
	--self.ActivityDropdown:SetDefaultText("Select an activity")
	--self.PlayStyleDropdown:SetDefaultText("Select a playstyle")

	self:SetScript("OnEnter", function()
	
	end)
end

function GroupCreatorMixin:OnShow()
	--LFGListEntryCreation_SetupGroupDropdown(LFGListFrame.EntryCreation)
	
	--self.ActivityDropdown:SetupMenu(function(dropdown, rootDescription)
		--self:SetupActivities(dropdown, rootDescription)
		
	--end)
	--LFGListEntryCreation_SetupActivityDropdown(LFGListFrame.EntryCreation)

    --LFGListEntryCreation_SetupPlayStyleDropdown(self)
end




function LFGListEntryCreationCancelButton_OnClick(self)
	local panel = self:GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if (LFGListEntryCreation_IsEditMode(panel)) then
		LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.ApplicationViewer);

	else
		LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.CategorySelection);

	end
end