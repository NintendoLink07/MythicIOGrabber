Blizzard_ChallengeModeWeeklyChestMixin = CreateFromMixins(WeeklyRewardMixin);

function Blizzard_ChallengeModeWeeklyChestMixin:Update(bestMapID, dungeonScore)
	local chestState = CHEST_STATE_WALL_OF_TEXT;

	if C_WeeklyRewards.HasAvailableRewards() then
		chestState = CHEST_STATE_COLLECT;

		self.Icon:SetAtlas("mythicplus-dragonflight-greatvault-collect", TextureKitConstants.UseAtlasSize);
		self.Highlight:SetAtlas("mythicplus-dragonflight-greatvault-collect", TextureKitConstants.UseAtlasSize);
		self.RunStatus:SetText(MYTHIC_PLUS_COLLECT_GREAT_VAULT);
		self.AnimTexture:Show();
		self.AnimTexture.Anim:Play();
	elseif self:HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.Activities) then
		chestState = CHEST_STATE_COMPLETE;

		self.Icon:SetAtlas("mythicplus-dragonflight-greatvault-complete", TextureKitConstants.UseAtlasSize);
		self.Highlight:SetAtlas("mythicplus-dragonflight-greatvault-complete", TextureKitConstants.UseAtlasSize);
		self.RunStatus:SetText(MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS);
		self.AnimTexture:Hide();
	elseif C_MythicPlus.GetOwnedKeystoneLevel() or (dungeonScore and dungeonScore > 0) then
		chestState = CHEST_STATE_INCOMPLETE;

		self.Icon:SetAtlas("mythicplus-dragonflight-greatvault-incomplete", TextureKitConstants.UseAtlasSize);
		self.Highlight:SetAtlas("mythicplus-dragonflight-greatvault-incomplete", TextureKitConstants.UseAtlasSize);
		self.RunStatus:SetText(MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS);
		self.AnimTexture:Hide();
	end

	self.state = chestState;
	return chestState;
end

function Blizzard_ChallengeModeWeeklyChestMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);

	-- always direct players to great vault if there are rewards to be claimed
	if self.state == CHEST_STATE_COLLECT then
		GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end

	local lastCompletedActivityInfo, nextActivityInfo = WeeklyRewardsUtil.GetActivitiesProgress();
	if not lastCompletedActivityInfo then
		GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);
	else
		if nextActivityInfo then
			local globalString = (lastCompletedActivityInfo.index == 1) and GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST or GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
			GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivityInfo.threshold - nextActivityInfo.progress));
		else
			GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_THIRD);
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
			local level, count = WeeklyRewardsUtil.GetLowestLevelInTopDungeonRuns(lastCompletedActivityInfo.threshold);
			if level == WeeklyRewardsUtil.HeroicLevel then
				GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_HEROIC_IMPROVE:format(count));
			else
				local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(level);
				GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_IMPROVE:format(count, nextLevel));
			end
		end
	end

	GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);
	GameTooltip:Show();
end