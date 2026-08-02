local addonName, miog = ...

SearchFrameBaseFrameMixin = {}

function SearchFrameBaseFrameMixin:OnLoad()

end

function SearchFrameBaseFrameMixin:Reset()
	self:SetStatus()

end

local function LFGListAdvancedFiltersActivitiesNoneChecked(enabled)
	return #enabled.activities == 0;
end

local function LFGListAdvancedFiltersActivitiesAllChecked(enabled)
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
	local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE));
	local timerunningGroups = {};
	if PlayerIsTimerunning() then
		timerunningGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.Timerunning, Enum.LFGListFilter.PvE));
	end
	
	return #enabled.activities == (#seasonGroups + #expansionGroups + #timerunningGroups);
end

local function LFGListAdvancedFiltersDifficultyNoneChecked(enabled)
	return not (enabled.difficultyNormal or enabled.difficultyHeroic or enabled.difficultyMythic or enabled.difficultyMythicPlus);
end

local function LFGListAdvancedFiltersDifficultyAllChecked(enabled)
	return enabled.difficultyNormal and enabled.difficultyHeroic and enabled.difficultyMythic and enabled.difficultyMythicPlus;
end

local function LFGListAdvancedFiltersGeneralPlaystyleNoneChecked(enabled)
	return not (enabled.generalPlaystyle1 or enabled.generalPlaystyle2 or enabled.generalPlaystyle3 or enabled.generalPlaystyle4);
end

local function LFGListAdvancedFiltersGeneralPlaystyleAllChecked(enabled)
	return enabled.generalPlaystyle1 and enabled.generalPlaystyle2 and enabled.generalPlaystyle3 and enabled.generalPlaystyle4;
end

--for activities, difficulties and general playstyle, none checked and all checked are equivalent. Although visually we want to show all checked as the default.
local function LFGListAdvancedFiltersIsDefault(enabled)
	return (LFGListAdvancedFiltersActivitiesNoneChecked(enabled) or LFGListAdvancedFiltersActivitiesAllChecked(enabled))
		and (LFGListAdvancedFiltersDifficultyNoneChecked(enabled) or LFGListAdvancedFiltersDifficultyAllChecked(enabled))
		and (LFGListAdvancedFiltersGeneralPlaystyleNoneChecked(enabled) or LFGListAdvancedFiltersGeneralPlaystyleAllChecked(enabled))
		and not (enabled.needsTank or enabled.needsHealer or enabled.needsDamage or enabled.needsMyClass or enabled.hasTank or enabled.hasHealer 
				or (enabled.minimumRating ~= 0));
end

local function LFGListAdvancedFiltersCheckAllDifficulties(enabled)
	enabled.difficultyNormal = true;
	enabled.difficultyHeroic = true;
	enabled.difficultyMythic = true;
	enabled.difficultyMythicPlus = true;
end

local function LFGListAdvancedFiltersCheckAllGeneralPlaystyles(enabled)
	enabled.generalPlaystyle1 = true;
	enabled.generalPlaystyle2 = true;
	enabled.generalPlaystyle3 = true;
	enabled.generalPlaystyle4 = true;
end

local function LFGListAdvancedFiltersCheckAllDungeons(enabled)
	local seasonGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE));
	local expansionGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.CurrentExpansion, Enum.LFGListFilter.NotCurrentSeason, Enum.LFGListFilter.PvE));
	
	local allDungeons = {};

	tAppendAll(allDungeons, seasonGroups);
	tAppendAll(allDungeons, expansionGroups);

	if PlayerIsTimerunning() then
		local timerunningGroups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, bit.bor(Enum.LFGListFilter.Timerunning, Enum.LFGListFilter.PvE));
		tAppendAll(allDungeons, timerunningGroups);
	end

	enabled.activities = allDungeons;
end

local function EntryStillSatisfiesFilters(enabled, displayData, searchResultInfo)
	local _, classFilename = UnitClass("player");
	local infoTable = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1]);

	if enabled.needsTank and displayData["TANK"] ~= 0 then
		return false;
	elseif enabled.needsHealer and displayData["HEALER"] ~= 0 then
		return false;
	elseif enabled.needsDamage and displayData["DAMAGER"] >= 3 then
		return false;
	elseif enabled.needsMyClass and displayData[classFilename] > 0 then
		return false;
	elseif enabled.hasTank and displayData["TANK"] == 0 then
		return false;
	elseif enabled.hasHealer and displayData["HEALER"] == 0 then
		return false;
	elseif enabled.minimumRating > (searchResultInfo.leaderOverallDungeonScore or 0) then
		return false;
	elseif #enabled.activities > 0 then
		local foundActivity = false;
		for _, activityID in ipairs(enabled.activities) do
			if activityID == infoTable.groupFinderActivityGroupID then
				foundActivity = true;
				break;
			end
		end
		if not foundActivity then
			return false;
		end
	end
	if not LFGListAdvancedFiltersDifficultyNoneChecked(enabled) then
		if (infoTable.isNormalActivity and not enabled.difficultyNormal)
			or (infoTable.isHeroicActivity and not enabled.difficultyHeroic) 
			or (infoTable.isMythicActivity and not enabled.difficultyMythic)
			or (infoTable.isMythicPlusActivity and not enabled.difficultyMythicPlus) then
			return false;
		end
	end
	if not LFGListAdvancedFiltersGeneralPlaystyleNoneChecked(enabled) then
		if ((searchResultInfo.generalPlaystyle == Enum.LFGEntryGeneralPlaystyle.Learning) and not enabled.generalPlaystyle1)
			or ((searchResultInfo.generalPlaystyle == Enum.LFGEntryGeneralPlaystyle.FunRelaxed) and not enabled.generalPlaystyle2)
			or ((searchResultInfo.generalPlaystyle == Enum.LFGEntryGeneralPlaystyle.FunSerious) and not enabled.generalPlaystyle3)
			or ((searchResultInfo.generalPlaystyle == Enum.LFGEntryGeneralPlaystyle.Expert) and not enabled.generalPlaystyle4) then
			return false;
		end
	end

	return true;
end

local function IsDeclined(appStatus)
	return appStatus == "declined" or appStatus == "declined_delisted" or appStatus =="declined_full"

end

function SearchFrameBaseFrameMixin:RefreshStatus()
    --implement in children
end

function SearchFrameBaseFrameMixin:UpdateVisuals(searchResultInfo)
    
end

function SearchFrameBaseFrameMixin:SetStatus(searchResultInfo)
	if(searchResultInfo) then
		local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(searchResultInfo.searchResultID);
		local isDeclined = IsDeclined(appStatus);
		if LFGListFrame.declines then
			if not isDeclined and LFGListFrame.declines[searchResultInfo.partyGUID] then
				isDeclined = true;
				appStatus = LFGListFrame.declines[searchResultInfo.partyGUID];
			end
		end

		local isApplication = (appStatus ~= "none" or pendingStatus);
		local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus);
		local enabled = C_LFGList.GetAdvancedFilter();
		local displayData = C_LFGList.GetSearchResultMemberCounts(searchResultInfo.searchResultID);
		
		self.hasInvitation = appStatus == "invited"
		self.isTimedOut = appStatus == "timedout"
		self.isFull = appStatus == "declined_full"
		self.applicationHasBeenCancelled = appStatus == "cancelled"
		self.applicationHasBeenDeclined = appStatus == "declined"
		self.invitationHasBeenDeclined = appStatus == "invitedeclined"

		self.isNowFilteredOut = LFGListFrame.CategorySelection.selectedCategory == GROUP_FINDER_CATEGORY_ID_DUNGEONS and not EntryStillSatisfiesFilters(enabled, displayData, searchResultInfo);
		self.isApplication = isApplication and not isAppFinished;
		self.isSelected = LFGListFrame.SearchPanel.selectedResult == searchResultInfo.searchResultID and not isApplication and not searchResultInfo.isDelisted;
		self.isDelisted = searchResultInfo.isDelisted

		local activityID = searchResultInfo.activityIDs[1]
		local activityInfo = miog:GetActivityInfo(activityID)

		if(activityInfo.horizontal) then
			self.Background:SetTexture(activityInfo.horizontal, "MIRROR", "MIRROR")

		else
			self.Background:SetColorTexture(PANEL_BACKGROUND_COLOR:GetRGBA())

		end
		
		self:RefreshStatus()
	else
		self.hasInvitation = nil
		self.isTimedOut = nil
		self.isFull = nil
		self.applicationHasBeenCancelled = nil
		self.applicationHasBeenDeclined = nil
		self.invitationHasBeenDeclined = nil

		self.isNowFilteredOut = nil
		self.isApplication = nil
		self.isSelected = nil
		self.isDelisted = nil

	end
end