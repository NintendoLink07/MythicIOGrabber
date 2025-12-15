local framePoolCollection = CreateFramePoolCollection()
local counter = 0

local array = {
   "AccountStoreInsetFrameTemplate",
"AchievementAlertFrameTemplate",
"AchievementFrameAchievementsObjectivesTemplate",
"AchievementFrameSummaryCategoryTemplate",
"AchievementFrameTabButtonTemplate",
"AchievementIconFrameTemplate",
"ActionButtonCastingAnimFrameTemplate",
"ActionButtonTargetReticleFrameTemplate",
"AlertFrameTemplate",
"AlliedRacesModelControlFrameButtonTemplate",
"AnimaDiversionCurrencyCostFrameTemplate",
"AreaLabelFrameTemplate",
"ArenaCastingBarFrameTemplate",
"ArenaEnemyMatchFrameTemplate",
"ArenaEnemyPetFrameTemplate",
"ArenaEnemyPrepFrameTemplate",
"ArenaUnitFrameCastingBarTemplate",
"ArenaUnitFrameCcRemoverTemplate",
"ArenaUnitFrameCooldownTemplate",
"ArenaUnitFrameDebuffTemplate",
"ArtifactFrameTabButtonTemplate",
"AuctionHouseAlignedPriceInputFrameTemplate",
"AuctionHouseAlignedQuantityInputFrameTemplate",
"AuctionHouseAuctionsFrameTabTemplate",
"AuctionHouseAuctionsFrameTemplate",
"AuctionHouseBidFrameTemplate",
"AuctionHouseBrowseResultsFrameTemplate",
"AuctionHouseBuyDialogNotificationFrameTemplate",
"AuctionHouseBuyoutFrameTemplate",
"AuctionHouseCommoditiesBuyFrameTemplate",
"AuctionHouseCommoditiesSellFrameTemplate",
"AuctionHouseFrameDisplayModeTabTemplate",
"AuctionHouseFrameTabTemplate",
"AuctionHouseFrameTopTabTemplate",
"AuctionHouseItemBuyFrameTemplate",
"AuctionHouseItemSellFrameTemplate",
"AuctionHouseRefreshFrameTemplate",
"AuctionHouseSellFrameAlignedControlTemplate",
"AuctionHouseSellFrameOverlayTemplate",
"AuctionHouseSellFrameTemplate",
"AuraFrameTemplate",
"AzeriteEssenceStarsAnimationFrameTemplate",
"AzeriteRankFrameTemplate",
"BackpackTokenFrameTemplate",
"BankPanelAutoDepositFrameTemplate",
"BankPanelHeaderFrameTemplate",
"BankPanelMoneyFrameButtonTemplate",
"BankPanelMoneyFrameTemplate",
"BaseBasicFrameTemplate",
"BaseLayoutFrameTemplate",
"BaseNamePlateUnitFrameTemplate",
"BasicFrameTemplate",
"BasicHybridScrollFrameTemplate",
"BonusRollFrameTemplate",
"BossBannerLootFrameTemplate",
"BossTargetFrameTemplate",
"BuffFramePrivateAuraAnchorTemplate",
"ButtonFrameBaseTemplate",
"ButtonFrameTemplate",
"CastingBarFrameAnimsFXTemplate",
"CastingBarFrameAnimsTemplate",
"CastingBarFrameBaseTemplate",
"CastingBarFrameStagePipFXTemplate",
"CastingBarFrameStagePipTemplate",
"CastingBarFrameStageTierTemplate",
"CastingBarFrameTemplate",
"ChallengesDungeonIconFrameTemplate",
"ChallengesKeystoneFrameAffixTemplate",
"CharacterCreateFrameRacialAbilityTemplate",
"CharacterCreatePreviewFrameTemplate",
"CharacterCustomizationFrameTemplate",
"CharacterFooterFrameTemplate",
"CharacterFrameTabButtonTemplate",
"CharacterFrameTabTemplate",
"CharacterHeaderFrameTemplate",
"CharacterStatFrameCategoryTemplate",
"CharacterStatFrameTemplate",
"ChatFrameEditBoxTemplate",
"ChatFrameTemplate",
"ClassSpecContentFrameTemplate",
"ClassSpecFrameTemplate",
"ClassTalentsFrameTemplate",
"ClickBindingFramePortraitTemplate",
"ClubFinderApplicantListFrameTemplate",
"ClubFinderCommunitiesCardFrameTemplate",
"ClubFinderEditBoxScrollFrameTemplate",
"ClubFinderGuildAndCommunityFrameTemplate",
"ClubFinderGuildCardsFrameTemplate",
"ClubFinderInvitationsFrameTemplate",
"CollapsableUpgradeFrameTemplate",
"CollectionsPagingFrameTemplate",
"CommentatorUnitFrameTemplate",
"CommunitiesControlFrameTemplate",
"CommunitiesFrameMemberListDropdownTemplate",
"CommunitiesFrameTabTemplate",
"CommunitiesGuildFinderFrameTemplate",
"CommunitiesGuildInfoFrameTemplate",
"CommunitiesGuildMemberDetailFrameTemplate",
"CommunitiesGuildNameChangeAlertFrameTemplate",
"CommunitiesGuildNewsFrameTemplate",
"CommunitiesGuildPerksFrameTemplate",
"CommunitiesGuildRewardsFrameTemplate",
"CommunitiesInvitationFrameTemplate",
"CommunitiesListFrameTemplate",
"CommunitiesMemberListFrameTemplate",
"CommunitiesTicketFrameTemplate",
"CommunitiesTicketManagerScrollFrameTemplate",
"CommunityNameChangeFrameTemplate",
"CommunityPostingChangeFrameTemplate",
"CompactArenaFrameTemplate",
"CompactPartyFrameTemplate",
"CompactPartyPetUnitFrameTemplate",
"CompactRaidGroupUnitFrameTemplate",
"CompactUnitFrameTemplate",
"CompactUnitPrivateAuraAnchorTemplate",
"ContainerFrameBackpackTemplate",
"ContainerFrameCurrencyBorderTemplate",
"ContainerFrameExtendedItemButtonTemplate",
"ContainerFrameItemButtonTemplate",
"ContainerFramePortraitButtonRouterTemplate",
"ContainerFramePortraitButtonTemplate",
"ContainerFrameReagentBagTemplate",
"ContainerFrameTemplate",
"ContainerMoneyFrameTemplate",
"CooldownFrameTemplate",
"CovenantListWideFrameTemplate",
"CovenantMissionBaseFrameTemplate",
"CreditsFrameExpansionsButtonTemplate",
"CreditsFrameSwitchButtonTemplate",
"CriteriaAlertFrameTemplate",
"CurrencyHorizontalLayoutFrameTemplate",
"CurrencyLayoutFrameIconTemplate",
"CustomGossipFrameBaseGridTemplate",
"CustomGossipFrameBaseTemplate",
"CustomizationFrameBaseTemplate",
"CustomizationFrameWithTooltipTemplate",
"CustomizationMaskedButtonTemplate",
"DebugIdentifierFrameNoNameTemplate",
"DebugIdentifierFrameTemplate",
"DigsiteCompleteToastFrameTemplate",
"DressUpFrameTransmogSetButtonTemplate",
"DressUpFrameTransmogSetTemplate",
"DressUpOutfitSlotFrameTemplate",
"DungeonCompletionAlertFrameRewardTemplate",
"DungeonCompletionAlertFrameTemplate",
"EasyFrameAnimationsTemplate",
"EditModeArenaUnitFrameSystemTemplate",
"EditModeAuraFrameSystemTemplate",
"EditModeBossUnitFrameSystemTemplate",
"EditModeChatFrameSystemTemplate",
"EditModeChatFrameSystemTemplate",
"EditModeDurabilityFrameSystemTemplate",
"EditModeLootFrameSystemTemplate",
"EditModeManagerFrameButtonTemplate",
"EditModePetFrameSystemTemplate",
"EditModePlayerFrameSystemTemplate",
"EditModeTalkingHeadFrameSystemTemplate",
"EditModeUnitFrameSystemTemplate",
"EntitlementDeliveredAlertFrameBaseTemplate",
"EntitlementDeliveredAlertFrameTemplate",
"EssencePlayerFrameTemplate",
"EtherealFrameTemplate",
"EventSchedulerFrameTemplate",
"FauxScrollFrameTemplate",
"FixedCoinFrameTemplate",
"FloatingChatFrameMinimizedTemplate",
"FloatingChatFrameTemplate",
"FogFrameTemplate",
"FogOfWarFrameTemplate",
"ForbiddenNamePlateUnitFrameTemplate",
"FrameHighlightTemplate",
"FrameStackAnchorHighlightTemplate",
"FriendsFrameBlockedInviteHeaderTemplate",
"FriendsFrameButtonTemplate",
"FriendsFrameFriendDividerTemplate",
"FriendsFrameFriendInviteTemplate",
"FriendsFrameFriendPartyInviteTemplate",
"FriendsFrameHeaderTemplate",
"FriendsFrameIgnoredHeaderTemplate",
"FriendsFrameTabTemplate",
"GameModeFrameTemplate",
"GarrisonBonusAreaTooltipFrameTemplate",
"GarrisonBonusEffectFrameTemplate",
"GarrisonBuildingAlertFrameTemplate",
"GarrisonFollowerAlertFrameTemplate",
"GarrisonFollowerMissionRewardsFrameTemplate",
"GarrisonLargeFollowerXPFrameTemplate",
"GarrisonMissionAlertFrameTemplate",
"GarrisonMissionChanceFrameTemplate",
"GarrisonMissionFollowerDurabilityFrameTemplate",
"GarrisonMissionFrameTabTemplate",
"GarrisonMissionFrameTemplate",
"GarrisonMissionPageCostFrameTemplate",
"GarrisonMissionPartyBuffsFrameTemplate",
"GarrisonRandomMissionAlertFrameTemplate",
"GarrisonShipFollowerAlertFrameTemplate",
"GarrisonShipMissionAlertFrameTemplate",
"GarrisonShipyardBonusAreaFrameTemplate",
"GarrisonShipyardMissionRewardsFrameTemplate",
"GarrisonSmallFollowerXPFrameTemplate",
"GarrisonStandardFollowerAlertFrameTemplate",
"GarrisonStandardMissionAlertFrameTemplate",
"GarrisonTalentAlertFrameTemplate",
"GarrisonThreatCountersFrameTemplate",
"GlueMenuFrameButtonTemplate",
"GoldBorderFrameTemplate",
"GossipFramePanelTemplate",
"GossipSpacerFrameTemplate",
"GridSelectorFrameTemplate",
"GroupLootFrameTemplate",
"GuildBankFrameColumnTemplate",
"GuildBankFrameTabTemplate",
"GuildBenefitsFrameTemplate",
"GuildChallengeAlertFrameTemplate",
"GuildDetailsFrameTemplate",
"GuildNameChangeFrameTemplate",
"GuildPostingChangeFrameTemplate",
"GuildRenamedAlertFrameTemplate",
"HelpFrameContainerFrameTemplate",
"HonorAwardedAlertFrameTemplate",
"HybridScrollFrameTemplate",
"IconSelectorPopupFrameTemplate",
"InlineHyperlinkFrameTemplate",
"InputScrollFrameTemplate",
"InsetFrameTemplate",
"InvasionAlertFrameRewardTemplate",
"IslandsQueueFrameCardFrameTemplate",
"IslandsQueueFrameDifficultyButtonTemplate",
"IslandsQueueFrameIslandCardTemplate",
"IslandsQueueFrameTutorialTemplate",
"IslandsQueueFrameWeeklyQuestFrameTemplate",
"ItemAlertFrameTemplate",
"KeyBindingFrameBindingButtonTemplate",
"KeyBindingFrameBindingTemplate",
"LargeMoneyInputFrameTemplate",
"LegendaryItemAlertFrameTemplate",
"LevelRangeFrameTemplate",
"LFDFrameDungeonChoiceTemplate",
"LFGRewardFrameTemplate",
"ListScrollFrameTemplate",
"LootFrameBaseElementTemplate",
"LootFrameElementTemplate",
"LootFrameItemElementTemplate",
"LootFrameMoneyElementTemplate",
"LootUpgradeFrameTemplate",
"LootWonAlertFrameTemplate",
"MacroFrameScrollFrameTemplate",
"MageArcaneChargesFrameTemplate",
"MainMenuFrameButtonTemplate",
"MainMenuFrameTemplate",
"ManagedHorizontalLayoutFrameTemplate",
"ManagedVerticalLayoutFrameTemplate",
"MapCanvasFrameScrollContainerTemplate",
"MapCanvasFrameTemplate",
"MapLegendFrameTemplate",
"MatchDetailFrameTemplate",
"MatchmakingQueueFrameTemplate",
"MaterialFrameTemplate",
"MaximizeMinimizeButtonFrameTemplate",
"MinimalHybridScrollFrameTemplate",
"MinimalScrollFrameTemplate",
"ModelSceneControlFrameTemplate",
"MoneyDisplayFrameTemplate",
"MoneyFrameButtonTemplate",
"MoneyFrameEditBoxTemplate",
"MoneyFrameTemplate",
"MoneyInputFrameTemplate",
"MoneyWonAlertFrameTemplate",
"MonkHarmonyBarFrameTemplate",
"MonthlyActivitiesFrameTemplate",
"MonthlyActivityFrameTemplate",
"NamePlateUnitFrameTemplate",
"NewCosmeticAlertFrameTemplate",
"NewMountAlertFrameTemplate",
"NewPetAlertFrameTemplate",
"NewRecipeLearnedAlertFrameTemplate",
"NewRuneforgePowerAlertFrameTemplate",
"NewToyAlertFrameTemplate",
"NewWarbandSceneAlertFrameTemplate",
"ObjectiveTrackerRewardFrameTemplate",
"OptionsFrameTabButtonTemplate",
"OrderHallFrameTabButtonTemplate",
"PagedCellSizeGridContentFrameTemplate",
"PagedCondensedVerticalGridContentFrameTemplate",
"PagedContentFrameBaseTemplate",
"PagedHorizontalListContentFrameTemplate",
"PagedNaturalSizeGridContentFrameTemplate",
"PagedVerticalListContentFrameTemplate",
"PaladinPowerBarFrameTemplate",
"PartyAuraFrameTemplate",
"PartyFrameBarSegmentTemplate",
"PartyMemberFrameTemplate",
"PartyMemberFrameTemplate",
"PartyMemberPetFrameTemplate",
"PartyPoseFrameTemplate",
"PartyPoseModelFrameTemplate",
"PerksProgramDetailsFrameTemplate",
"PerksProgramToyDetailsFrameTemplate",
"PetFrameBarSegmentTemplate",
"PingableUnitFrameTemplate",
"PingPinFrameTemplate",
"PingSpotFrameTemplate",
"PlayerChoiceBaseOptionButtonFrameTemplate",
"PlayerChoiceSmallerOptionButtonFrameTemplate",
"PlayerFrameAlternatePowerBarBaseTemplate",
"PlayerFrameBarSegmentTemplate",
"PlayerFrameBottomManagedFrameTemplate",
"PlayerFrameManagedContainerTemplate",
"PlayerTalentFramePanelTemplate",
"PlayerTalentFrameRoleIconTemplate",
"PortraitFrameBaseTemplate",
"PortraitFrameFlatBaseTemplate",
"PortraitFrameFlatTemplate",
"PortraitFrameTemplate",
"PortraitFrameTexturedBaseTemplate",
"PreMatchArenaUnitFrameTemplate",
"ProfessionsCustomerOrdersFrameTabTemplate",
"ProfessionsFrameTabTemplate",
"PVPQueueFrameButtonTemplate",
"QuestFramePanelTemplate",
"QuestInfoHonorFrameScriptTemplate",
"QuestLogBorderFrameTemplate",
"QuestScrollFrameTemplate",
"QueueTypeSettingsFrameTemplate",
"QuickKeybindFrameTemplate",
"RadialWheelFrameTemplate",
"RafRewardDeliveredAlertFrameTemplate",
"RaidAuraFrameTemplate",
"RaidBossEmoteFrameTemplate",
"RaidFramePreviewTemplate",
"RaidPulloutFrameTemplate",
"ReportingFrameMinorCategoryButtonTemplate",
"RewardTrackFrameTemplate",
"RingedFrameWithTooltipTemplate",
"RPEUpgradeInfoSubFrameTemplate",
"RuneforgeCraftingFrameTemplate",
"RuneforgeCreateFrameTemplate",
"RuneforgeModifierFrameTemplate",
"RuneforgeModifierSelectorFrameTemplate",
"RuneforgePowerFrameTemplate",
"RuneFrameTemplate",
"RunforgeFrameTooltipTemplate",
"ScenarioAlertFrameTemplate",
"ScenarioLegionInvasionAlertFrameTemplate",
"ScenarioSpellFrameTemplate",
"ScrollFrameTemplate",
"SeasonRewardFrameTemplate",
"SecureFrameParentPropagationTemplate",
"SecureFrameTemplate",
"SelectionFrameTemplate",
"SettingsFrameTemplate",
"SharedReportFrameTemplate",
"SkillLineSpecsUnlockedAlertFrameTemplate",
"SmallAlternateCurrencyFrameTemplate",
"SmallCastingBarFrameTemplate",
"SmallMoneyFrameTemplate",
"SpecializationFrameTemplate",
"SpellBookFrameTabButtonTemplate",
"SpellBookFrameTemplate",
"SplashFeatureFrameTemplate",
"StealthedArenaUnitFrameTemplate",
"StoreInsetFrameTemplate",
"StoreVASRaceFactionIconFrameTemplate",
"TabardFrameCustomizeTemplate",
"TalentFrameBaseTemplate",
"TalentFrameGateTemplate",
"TalentSelectionChoiceFrameTemplate",
"TargetBuffFrameTemplate",
"TargetDebuffFrameTemplate",
"TargetFrameBarSegmentTemplate",
"TargetFrameTemplate",
"TargetofTargetDebuffFrameTemplate",
"TargetofTargetFrameTemplate",
"TextToSpeechFrameTemplate",
"TimerunningChoiceFrameGlowTemplate",
"TooltipBorderedFrameTemplate",
"TooltipMoneyFrameTemplate",
"TopLevelParentScaleFrameTemplate",
"TrainingLobbyQueueFrameTemplate",
"TranslucentFrameTemplate",
"UIPanelInputScrollFrameTemplate",
"UIPanelScrollFrameCodeTemplate",
"UIPanelScrollFrameTemplate",
"UIPanelSpellButtonFrameTemplate",
"UIParentBottomManagedFrameTemplate",
"UIParentManagedFrameTemplate",
"UIParentRightManagedFrameTemplate",
"UIWidgetFillUpFrameTemplate",
"UnitPositionFrameTemplate",
"UpgradeFrameFeatureLargeTemplate",
"UpgradeFrameFeatureTemplate",
"UserScaledFrameTemplate",
"WardrobeSetsDetailsItemFrameTemplate",
"WardrobeSetsScrollFrameButtonTemplate",
"WarlockPowerFrameTemplate",
"WarModeBonusFrameTemplate",
"WatchFrameAutoQuestPopUpTemplate",
"WatchFrameItemButtonTemplate",
"WatchFrameLineTemplate",
"WatchFrameLinkButtonTemplate",
"WatchFrameScenarioLineTemplate",
"WeeklyRewardActivityItemFrameTemplate",
"WhoFrameColumnHeaderTemplate",
"WoodFrameTemplate",
"WorldMapFloorNavigationFrameTemplate",
"WorldMapFrameTemplate",
"WorldMapThreatFrameTemplate",
"WorldQuestCompleteAlertFrameTemplate",
"WorldQuestFrameRewardTemplate",
"WorldStateScoreFrameTabButtonTemplate",
"WorldStateScoreFrameTabButtonTemplate",
"WoWTokenSellFrameTemplate",
"ZoneAbilityFrameSpellButtonTemplate",
"ZoneAbilityFrameTemplate",
}

local array2 = {
    "AuctionHouseSearchBoxTemplate",

    "AuctionHouseQuantityInputEditBoxTemplate",

    "AuthChallengeEditBoxTemplate",

    "AutoCompleteEditBoxTemplate",

    "CreateChannelPopupEditBoxTemplate",

    "ChatConfigBoxTemplate",

    "ChatConfigBorderBoxTemplate",

    "ChatConfigBoxWithHeaderTemplate",

    "ChatConfigBoxWithHeaderAndClassColorsTemplate",

    "WideChatConfigBoxWithHeaderAndClassColorsTemplate",

    "ChatConfigCheckboxTemplate",

    "ChatConfigCheckboxSmallTemplate",

    "ChatConfigCheckboxWithSwatchTemplate",

    "ChatConfigWideCheckboxWithSwatchTemplate",

    "MovableChatConfigWideCheckboxWithSwatchTemplate",

    "ChatFrameEditBoxTemplate",

    "ClubFinderEditBoxScrollFrameTemplate",

    "ClubFinderBigSpecializationCheckboxTemplate",

    "ClubFinderLittleSpecializationCheckboxTemplate",

    "ClubFinderCheckboxTemplate",

    "CommunitiesChatEditBoxTemplate",

    "NameChangeEditBoxTemplate",

    "EditModeDialogLayoutNameEditBoxTemplate",

    "EditModeSettingCheckboxTemplate",

    "EventTraceScrollBoxButtonTemplate",

    "GarrisonBaseInfoBoxTemplate",

    "GarrisonInfoBoxBigBottomTemplate",

    "GarrisonInfoBoxLittleBottomTemplate",

    "GarrisonInfoBoxFiligreeTemplate",

    "ServerAlertBoxTemplate",

    "CharacterServicesEditBoxBaseTemplate",

    "CharacterServicesEditBoxHorizontalLabelTemplate",

    "CharacterServicesEditBoxWithAutoCompleteTemplate",

    "LFGListEditBoxTemplate",

    "GuildPermissionCheckboxTemplate",

    "GlowBoxArrowTemplate",

    "GlowBoxTemplate",

    "MoneyFrameEditBoxTemplate",

    "LargeMoneyInputBoxTemplate",

    "MovePadCheckboxTemplate",

    "PerksProgramCheckboxTemplate",

    "SettingsCheckboxTemplate",

    "SettingsCheckboxControlTemplate",

    "SettingsCheckboxWithButtonControlTemplate",

    "SettingsCheckboxSliderControlTemplate",

    "SettingsCheckboxDropdownControlTemplate",

    "SettingsAdvancedWideCheckboxSliderTemplate",

    "InputBoxScriptTemplate",

    "LargeInputBoxTemplate",

    "InputBoxVisualTemplate",

    "InputBoxTemplate",

    "MinimalCheckboxArtTemplate",

    "MinimalCheckboxTemplate",

    "InputBoxInstructionsTemplate",

    "SearchBoxTemplate",

    "SharedEditBoxTemplate",

    "NumericInputBoxTemplate",

    "BottomPopupScrollBoxTemplate",

    "SearchBoxListTemplate",

    "SearchBoxListAllButtonTemplate",

    "LevelRangeEditBoxTemplate",

    "ScrollBoxSelectorTemplate",

    "ScrollBoxDragIndicatorTemplate",

    "ScrollBoxDragBoxTemplate",

    "ScrollBoxDragLineTemplate",

    "ScrollBoxBaseTemplate",

    "ScrollingEditBoxTemplate",

    "SpellSearchBoxTemplate",

    "StoreEditBoxBaseTemplate",

    "StoreEditBoxTemplate",

    "StoreEditBoxHorizontalLabelTemplate",

    "StoreEditBoxWithAutoCompleteTemplate",

    "CurrencyTransferAmountInputEditBoxTemplate",

    "BankPanelCheckboxTemplate",

    "BankPanelTabDepositSettingsCheckboxTemplate",

    "BankItemSearchBoxTemplate",

    "QuestLogTrackCheckboxTemplate",

    "BagSearchBoxTemplate"
}

local array3 = {
    "ChatConfigBorderBoxTemplate",

    "GarrisonMissionTopBorderTemplate",

    "GarrisonShipyardTopBorderTemplate",

    "NamePlateFullBorderTemplate",

    "NamePlateSecondaryBarBorderTemplate",

    "MinimalScrollBarWithBorderTemplate",

    "SecureDialogBorderNoCenterTemplate",

    "SecureDialogBorderTemplate",

    "SecureDialogBorderDarkTemplate",

    "SecureDialogBorderOpaqueTemplate",

    "TooltipBorderBackdropTemplate",

    "TooltipBorderedFrameTemplate",

    "DialogBorderNoCenterTemplate",

    "DialogBorderTemplate",

    "DialogBorderDarkTemplate",

    "DialogBorderTranslucentTemplate",

    "DialogBorderOpaqueTemplate",

    "UIGoldBorderButtonTemplate",

    "GoldBorderFrameTemplate",

    "ContainerFrameCurrencyBorderTemplate",

    "QuestLogBorderFrameTemplate",

    "UIPanelBorderedButtonTemplate"

}

local array4 = {
    "MatchmakingQueueFrameTemplate",
    "SettingsFrameTemplate",
    "QuestLogBorderFrameTemplate",
    "DialogBorderNoCenterTemplate",
    "DialogBorderTemplate",
    "DialogBorderDarkTemplate",
    "DialogBorderTranslucentTemplate",
    "QuestLogBorderFrameTemplate",
    "AccountStoreInsetFrameTemplate",
}

local lastFrame, lastPool
local currentArray = array4

local function createNewFrame()
    if(lastPool) then
        lastPool:ReleaseAll()
    end

    lastPool = framePoolCollection:GetOrCreatePool("Frame", UIParent, currentArray[counter])
    lastPool:ReleaseAll()

    print("CREATE", counter, currentArray[counter])

    lastFrame = lastPool:Acquire()
    lastFrame:SetParent(UIParent)

    lastFrame:SetSize(500, 500)

    lastFrame:SetPoint("CENTER")
    lastFrame:Show()
end

local frame = CreateFrame("Frame")
local fontstring

local button = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
button:SetText("<")
button:SetSize(80, 20)
button:SetPoint("TOPLEFT")
button:SetScript("OnClick", function()
    if(counter > 0) then
        counter = counter - 1
        createNewFrame()
        fontstring:SetText(counter)

    end
end)


local button2 = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
button2:SetText(">")
button2:SetSize(80, 20)
button2:SetPoint("LEFT", button, "RIGHT", 5, 0)
button2:SetScript("OnClick", function()
    if(counter < #currentArray) then
        counter = counter + 1
        createNewFrame()
        fontstring:SetText(counter)

    end
end)

fontstring = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
fontstring:SetPoint("LEFT", button2, "RIGHT", 5, 0)