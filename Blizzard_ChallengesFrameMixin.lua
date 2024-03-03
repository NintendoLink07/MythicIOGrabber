Blizzard_ChallengesFrameMixin = {};

function Blizzard_ChallengesFrameMixin:OnLoad()
	-- events
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED");
    self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
	self:RegisterEvent("CHALLENGE_MODE_RESET");

    self.leadersAvailable = false;
	self.maps = C_ChallengeMode.GetMapTable();
end

function Blizzard_ChallengesFrameMixin:OnEvent(event)
	if (event == "CHALLENGE_MODE_RESET") then
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
	else
        if (event == "CHALLENGE_MODE_LEADERS_UPDATE") then
            self.leadersAvailable = true;
        end
        self:Update();
	end
end

function Blizzard_ChallengesFrameMixin:OnShow()
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("WEEKLY_REWARDS_UPDATE");
	self:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE");

    PVEFrame:SetPortraitToAsset("Interface\\Icons\\achievement_bg_wineos_underxminutes");

	self:UpdateTitle();
	PVEFrame_HideLeftInset();

	C_MythicPlus.RequestCurrentAffixes();
	C_MythicPlus.RequestMapInfo();
    for i = 1, #self.maps do
        C_ChallengeMode.RequestLeaders(self.maps[i]);
    end

    self:Update();
end

function Blizzard_ChallengesFrameMixin:OnHide()
    PVEFrame_ShowLeftInset();
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("WEEKLY_REWARDS_UPDATE");
	self:UnregisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE");
end

function Blizzard_ChallengesFrameMixin:Update()
    local sortedMaps = {};

    for i = 1, #self.maps do
		local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.maps[i]);
		local level = 0;
		local dungeonScore = 0;
		if(inTimeInfo and overtimeInfo) then
			local inTimeScoreIsBetter = inTimeInfo.dungeonScore > overtimeInfo.dungeonScore;
			level = inTimeScoreIsBetter and inTimeInfo.level or overtimeInfo.level;
			dungeonScore = inTimeScoreIsBetter and inTimeInfo.dungeonScore or overtimeInfo.dungeonScore;
        elseif(inTimeInfo or overtimeInfo) then
			level = inTimeInfo and inTimeInfo.level or overtimeInfo.level;
			dungeonScore = inTimeInfo and inTimeInfo.dungeonScore or overtimeInfo.dungeonScore;
		end
		local name = C_ChallengeMode.GetMapUIInfo(self.maps[i]);
		tinsert(sortedMaps, { id = self.maps[i], level = level, dungeonScore = dungeonScore, name = name});
    end

    table.sort(sortedMaps,
	function(a, b)
		if(b.dungeonScore ~= a.dungeonScore) then
			return a.dungeonScore > b.dungeonScore;
		else
			return strcmputf8i(a.name, b.name) > 0;
		end
	end);

	local hasWeeklyRun = false;
	local weeklySortedMaps = {};
	 for i = 1, #self.maps do
		local _, weeklyLevel = C_MythicPlus.GetWeeklyBestForMap(self.maps[i])
        if (not weeklyLevel) then
            weeklyLevel = 0;
        else
            hasWeeklyRun = true;
        end
        tinsert(weeklySortedMaps, { id = self.maps[i], weeklyLevel = weeklyLevel});
     end

    table.sort(weeklySortedMaps, function(a, b) return a.weeklyLevel > b.weeklyLevel end);

    local frameWidth = self.WeeklyInfo:GetWidth()

    local num = #sortedMaps;

    --CreateFrames(self, "DungeonIcons", num, "ChallengesDungeonIconFrameTemplate");
    --LineUpFrames(self.DungeonIcons, "BOTTOMLEFT", self, "BOTTOM", frameWidth);

    for i = 1, #sortedMaps do
        local frame = self.DungeonIcons[i];
        frame:SetUp(sortedMaps[i], i == 1);
        frame:Show();

		if (i == 1) then
			self.WeeklyInfo.Child.SeasonBest:ClearAllPoints();
			self.WeeklyInfo.Child.SeasonBest:SetPoint("TOPLEFT", self.DungeonIcons[i], "TOPLEFT", 5, 15);
		end
    end

    local _, _, _, _, backgroundTexture = C_ChallengeMode.GetMapUIInfo(sortedMaps[1].id);
    if (backgroundTexture ~= 0) then
        self.Background:SetTexture(backgroundTexture);
    end

    self.WeeklyInfo:SetUp(hasWeeklyRun, sortedMaps[1]);

	local chestFrame = self.WeeklyInfo.Child.WeeklyChest;
	local bestMapID = weeklySortedMaps[1].id;
	local dungeonScore = C_ChallengeMode.GetOverallDungeonScore();
	local chestState = chestFrame:Update(bestMapID, dungeonScore);
	chestFrame:SetShown(chestState ~= CHEST_STATE_WALL_OF_TEXT);
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore);
	if(color) then
		self.WeeklyInfo.Child.DungeonScoreInfo.Score:SetVertexColor(color.r, color.g, color.b);
	end
	self.WeeklyInfo.Child.DungeonScoreInfo.Score:SetText(dungeonScore);
	self.WeeklyInfo.Child.DungeonScoreInfo:SetShown(chestFrame:IsShown());

	if chestState == CHEST_STATE_COLLECT then
		self.WeeklyInfo.Child.ThisWeekLabel:Hide();
		self.WeeklyInfo.Child.Description:Hide();
	elseif chestState == CHEST_STATE_COMPLETE then
		self.WeeklyInfo.Child.ThisWeekLabel:Show();
		self.WeeklyInfo.Child.Description:Hide();
	elseif chestState == CHEST_STATE_INCOMPLETE then
		self.WeeklyInfo.Child.ThisWeekLabel:Show();
		self.WeeklyInfo.Child.Description:Hide();
	else
		self.WeeklyInfo.Child.ThisWeekLabel:Hide();
		self.WeeklyInfo.Child.Description:Show();
		if sortedMaps[1].level == 0 and not C_MythicPlus.GetOwnedKeystoneLevel() then
			self.WeeklyInfo:HideAffixes();
		end
	end

	local lastSeasonNumber = tonumber(GetCVar("newMythicPlusSeason"));
	local currentSeason = C_MythicPlus.GetCurrentSeason();
	if (currentSeason and lastSeasonNumber < currentSeason) then
		local noticeFrame = self.SeasonChangeNoticeFrame;
		if (currentSeason == SHADOWLANDS_FIRST_SEASON) then
			noticeFrame.SeasonDescription:SetText(MYTHIC_PLUS_FIRST_SEASON);
			noticeFrame.SeasonDescription2:SetText(nil);
			noticeFrame.SeasonDescription3:SetPoint("TOP", noticeFrame.SeasonDescription, "BOTTOM", 0, -14);
		else
			noticeFrame.SeasonDescription:SetText(MYTHIC_PLUS_SEASON_DESC1);
			noticeFrame.SeasonDescription2:SetText(MYTHIC_PLUS_SEASON_DESC2);
			noticeFrame.SeasonDescription3:SetPoint("TOP", noticeFrame.SeasonDescription2, "BOTTOM", 0, -14);
		end
		noticeFrame.Affix:Hide();
		local affixes = C_MythicPlus.GetCurrentAffixes();
		if (affixes) then
			for i, affix in ipairs(affixes) do
				if(affix.seasonID == currentSeason) then
					noticeFrame.Affix:SetUp(affix.id);
					local affixName = C_ChallengeMode.GetAffixInfo(affix.id);
					noticeFrame.SeasonDescription3:SetText(MYTHIC_PLUS_SEASON_DESC3:format(affixName));
					break;
				end
			end
		end
		self.SeasonChangeNoticeFrame:Show();
	end
end

function Blizzard_ChallengesFrameMixin:UpdateTitle()
	local currentDisplaySeason =  C_MythicPlus.GetCurrentUIDisplaySeason();
	if ( not currentDisplaySeason ) then
		PVEFrame:SetTitle(CHALLENGES);
		return;
	end

	local currExpID = GetExpansionLevel();
	local expName = _G["EXPANSION_NAME"..currExpID];
	local title = MYTHIC_DUNGEON_SEASON:format(expName, currentDisplaySeason);
	PVEFrame:SetTitle(title);
end