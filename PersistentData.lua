local addonName, miog = ...

--CONSTANTS
miog.C = {
    --
    --- FRAME SIZES
    --
    FULL_SIZE = 160,
    ENTRY_FRAME_SIZE = 20,
    APPLICANT_BUTTON_SIZE = 20,
    PADDING_OFFSET = 3,

    --
    --- FONT SIZES
    --
    TEXT_LINE_FONT_SIZE = 12,
    SETTING_FONT_SIZE = 12,
    AFFIX_FONT_SIZE = 12,
    
    --
    -- COLORS
    --
    GREEN_COLOR = "FF00FF77",
    GREEN_SECONDARY_COLOR = "9900FF77",
    RED_COLOR = "FFFF2222",
    RED_SECONDARY_COLOR = "99FF2222",

    BACKGROUND_COLOR = "FF18191A",
    BACKGROUND_COLOR_2 = "FF2A2B3C",
    BACKGROUND_COLOR_3 = "FF3C3D4E",
    CARD_COLOR = "FF242526",
    HOVER_COLOR = "FF3A3B3C",
    PRIMARY_TEXT_COLOR = "FFE4E6EB",
    SECONDARY_TEXT_COLOR = "FFB0B3B8",

	RIO_STAR_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/star_256.png:8:8|t",
	UTF_STAR_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/starUTF_512.png:8:8|t",
	STAR_TEXTURE = "⋆"
}

miog.F = {
    FACTION_ICON_SIZE = 0,
    UI_SCALE = C_CVar.GetCVar("uiScale"),
	PX_SIZE_1 = function() return PixelUtil.GetNearestPixelSize(1, UIParent:GetEffectiveScale(), 1) end,
    WEEKLY_AFFIX = "",
    IS_LIST_SORTED = false,
    SHOW_TANKS = true,
    SHOW_HEALERS = true,
    SHOW_DPS = true,
	AFFIX_UPDATE_COUNTER = 0
}

miog.dungeonIcons = {
    --DF S1
	rlp = {"Ruby Life Pools", "interface/lfgframe/lfgicon-lifepools"},
	no = {"The Nokhud Offensive", "interface/lfgframe/lfgicon-centaurplains"},
	av = {"The Azure Vault", "interface/lfgframe/lfgicon-arcanevaults"},
	aa = {"Algeth'ar Academy", "interface/lfgframe/lfgicon-theacademy"},
	sbg = {"Shadowmoon Burial Grounds", "interface/lfgframe/lfgicon-shadowmoonburialgrounds"},
	cos = {"Algeth'ar Academy", "interface/lfgframe/lfgicon-courtofstars"},
	totjs = {"Algeth'ar Academy", "interface/lfgframe/lfgicon-templeofthejadeserpent"},
	hov = {"Algeth'ar Academy", "interface/lfgframe/lfgicon-hallsofvalor"},

    --DF S2
	fh = {"Freehold", "interface/lfgframe/lfgicon-freehold"},
	u = {"The Underrot", "interface/lfgframe/lfgicon-theunderrot"},
	hoi = {"Halls of Infusion", "interface/lfgframe/lfgicon-hallsofinfusion"},
	bh = {"Brackenhide Hollow", "interface/lfgframe/lfgicon-brackenhidehollow"},
	vp = {"The Vortex Pinnacle", "interface/lfgframe/lfgicon-thevortexpinnacle"},
	n = {"Neltharus", "interface/lfgframe/lfgicon-neltharus"},
	ulot = {"Uldaman: Legacy of Tyr", "interface/lfgframe/lfgicon-uldaman-legacyoftyr"},
	nl = {"Neltharion's Lair", "interface/lfgframe/lfgicon-neltharionslair"},
}

miog.fonts = {
	libMono = "Interface\\Addons\\MythicIOGrabber\\res\\fonts\\LiberationMono-Regular.ttf",
}

miog.classTable = {
	["WARRIOR"] = 1,
	["PALADIN"] = 2,
	["HUNTER"] = 3,
	["ROGUE"] = 4,
	["PRIEST"] = 5,
	["DEATHKNIGHT"] = 6,
	["SHAMAN"] = 7,
	["MAGE"] = 8,
	["WARLOCK"] = 9,
	["MONK"] = 10,
	["DRUID"] = 11,
	["DEMONHUNTER"] = 12,
	["EVOKER"] = 13,
}

miog.searchLanguages = {
	itIT=true,
	ruRU=true,
	frFR=true,
	esES=true,
	deDE=true,
}

miog.iconCoords = {
    tankCoords = {0.76, 0.8725, 0.255, 0.367},
    healerCoords = {0.13, 0.2425, 0.255, 0.3675},
    dpsCoords = {0.003, 0.1155, 0.381, 0.4935},
}

miog.playStyleStrings = {
	["mZero1"] = "Standard",
	["mZero2"] = "Learning/Progression",
	["mZero3"] = "Quick Clear",

	["mPlus1"] = "Standard",
	["mPlus2"] = "Completion",
	["mPlus3"] = "Beat Timer",

	["raid1"] = "Standard",
	["raid2"] = "Learning/Progression",
	["raid3"] = "Quick Clear",
	
	["pvp1"] = "Earn Conquest",
	["pvp2"] = "Learning",
	["pvp3"] = "Increase Rating"
}