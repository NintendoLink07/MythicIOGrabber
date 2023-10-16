local addonName, miog = ...

--CONSTANTS
miog.C = {
    --
    --- FRAME SIZES
    --
    FULL_SIZE = 160,
    APPLICANT_MEMBER_HEIGHT = 20,
    APPLICANT_BUTTON_SIZE = 20,

    --
    --- FONT SIZES
    --
	TITLE_FONT_SIZE = 14,
	ACTIVITY_NAME_FONT_SIZE = 13,
	LISTING_COMMENT_FONT_SIZE = 12,
	LISTING_INFO_FONT_SIZE = 14,
	AFFIX_TEXTURE_FONT_SIZE = 12, --always weird, gotta change that
	APPLICANT_MEMBER_FONT_SIZE = 11,
	TEXT_ROW_FONT_SIZE = 11,
    
    --
    -- COLORS
    --
    GREEN_COLOR = "FF00FF77",
    GREEN_SECONDARY_COLOR = "9900FF77",
    RED_COLOR = "FFFF2222",
    RED_SECONDARY_COLOR = "99FF2222",

    BACKGROUND_COLOR = "FF18191A",
    BACKGROUND_COLOR_2 = "FF2A2B2C",
    BACKGROUND_COLOR_3 = "FF3C3D4E",
    CARD_COLOR = "FF242526",
    HOVER_COLOR = "FF3A3B3C",
    PRIMARY_TEXT_COLOR = "FFE4E6EB",
    SECONDARY_TEXT_COLOR = "FFB0B3B8",

	DIFFICULTY = {
		[3] = {singleChar = "M", description = _G["PLAYER_DIFFICULTY6"], color = _G["ITEM_QUALITY_COLORS"][4].color},
		[2] = {singleChar = "H", description = _G["PLAYER_DIFFICULTY2"], color = _G["ITEM_QUALITY_COLORS"][3].color},
		[1] = {singleChar = "N", description = _G["PLAYER_DIFFICULTY1"], color = _G["ITEM_QUALITY_COLORS"][2].color},
		[0] = {singleChar = "LFG", description = _G["PLAYER_DIFFICULTY3"], color = _G["ITEM_QUALITY_COLORS"][1].color},
		[-1] = {singleChar = "O", description = "Last tier / No tier", color = _G["ITEM_QUALITY_COLORS"][0].color},
	},

	REGIONS = {
		[1]	= "us",
		[2]	= "kr",
		[3]	= "eu",
		[4] = "tw",
		[5] = "cn",
 	},

	STANDARD_PADDING = 4,

	--PATH / TEXTURES FILES
	STANDARD_FILE_PATH = "Interface/Addons/MythicIOGrabber/res",
	RIO_STAR_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/star_64.png:8:8|t",
	TANK_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/tankSuperSmallIcon.png:20:20|t",
	HEALER_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/healerSuperSmallIcon.png:20:20|t",
	DPS_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/dpsSuperSmallIcon.png:20:20|t",
	STAR_TEXTURE = "⋆",

}


--CHANGING VARIABLES
miog.F = {
	UI_SCALE = C_CVar.GetCVar("uiScale") or UIParent:GetEffectiveScale(),
    FACTION_ICON_SIZE = 0,
    WEEKLY_AFFIX = nil,
    SHOW_TANKS = true,
    SHOW_HEALERS = true,
    SHOW_DPS = true,
	LISTED_CATEGORY_ID = 0,
	AUTO_SORT_ENABLED = nil,

	APPLIED_NUM_OF_TANKS = 0,
	APPLIED_NUM_OF_HEALERS = 0,
	APPLIED_NUM_OF_DPS = 0,
	NUM_OF_GROUP_MEMBERS = 0,

	CURRENT_GROUP_INFO = {},
	IS_RAIDERIO_LOADED = false,
	IS_IN_DEBUG_MODE = false,

	MOST_BOSSES = 0,
	
	INSPECT_QUEUE = {},
	CURRENTLY_INSPECTING = false,

	SORT_METHODS = {
		["role"] = {active = false, currentLayer = 0},
		["primary"] = {active = false, currentLayer = 0},
		["secondary"] = {active = false, currentLayer = 0},
		["ilvl"] = {active = false, currentLayer = 0},
	},

	CURRENTLY_ACTIVE_SORTING_METHODS = 0,

	CURRENT_DIFFICULTY = 0,

	CURRENT_REGION = miog.C.REGIONS[GetCurrentRegion()]
}

miog.BLANK_BACKGROUND_INFO = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tileSize = miog.C.APPLICANT_MEMBER_HEIGHT,
	tile = false,
	edgeSize = 1
}

miog.DIFFICULT_NAMES_TO_ID = {
	--category id to further divide

	[1] = { --QUESTING

	},
	[2] = { --DUNGEON
		["Normal"] = {1, 1, 5,},
		["Heroic"] = {2, 1, 5},
		["Timewalking"] = {24, 1, 5},
		["Mythic"] = {23, 1, 5},
		["Mythic+"] = {8, 1, 5},
		["Event"] = {19, 1, 5},
	},
	[3] = { --RAID
		["World Bosses"] = {172, 0, 40},
		["10 Player"] = {3, 2, 10},
		["10 Player Heroic"] = {5, 2, 10},
		["25 Player"] = {4, 2, 10},
		["25 Player Heroic"] = {6, 2, 10},
		["40 Player"] = {9, 2, 10},
		["Looking For Raid"] = {17, 2, 10},
		["Timewalking"] = {33, 2, 10},
		["Event"] = {18, 2, 40},
		["Normal"] = {14, 2, 30},
		["Heroic"] = {15, 2, 30},
		["Mythic"] = {16, 2, 20},
	},
}

miog.DUNGEON_ICONS = {
	--CATACLYSM
	[643] = "interface/lfgframe/lfgicon-throneofthetides",
	[657] = "interface/lfgframe/lfgicon-thevortexpinnacle",

	--MISTS OF PANDARIA
	[960] = "interface/lfgframe/lfgicon-templeofthejadeserpent",

	--WARLORDS OF DRAENOR
	[1176] = "interface/lfgframe/lfgicon-shadowmoonburialgrounds",
	[1279] = "interface/lfgframe/lfgicon-everbloom",

	--LEGION
	[1458] = "interface/lfgframe/lfgicon-neltharionslair",
	[1466] = "interface/lfgframe/lfgicon-darkheartthicket",
	[1477] = "interface/lfgframe/lfgicon-hallsofvalor",
	[1571] = "interface/lfgframe/lfgicon-courtofstars",
	[1501] = "interface/lfgframe/lfgicon-blackrookhold",

	--BATTLE FOR AZEROTH
	[1754] = "interface/lfgframe/lfgicon-freehold",
	[1763] = "interface/lfgframe/lfgicon-ataldazar",
	[1841] = "interface/lfgframe/lfgicon-theunderrot",
	[1862] = "interface/lfgframe/lfgicon-waycrestmanor",

	--SHADOWLANDS

	--DRAGONFLIGHT
	[2451] = "interface/lfgframe/lfgicon-uldaman-legacyoftyr",
	[2515] = "interface/lfgframe/lfgicon-arcanevaults",
	[2516] = "interface/lfgframe/lfgicon-centaurplains",
	[2519] = "interface/lfgframe/lfgicon-neltharus",
	[2520] = "interface/lfgframe/lfgicon-brackenhidehollow",
	[2521] = "interface/lfgframe/lfgicon-lifepools",
	[2526] = "interface/lfgframe/lfgicon-theacademy",
	[2527] = "interface/lfgframe/lfgicon-hallsofinfusion",
	[2579] = "interface/lfgframe/lfgicon-dawnoftheinfinite",
}

miog.RAID_ICONS = {
	[2549] = { --interface/icons/inv_achievement_raidemeralddream
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/gnarlroot.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/igira.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/volcoross.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/council.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/larodar.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/nymue.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/smolderon.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/tindral.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/fyrakk.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/amirdrassil.png",
	},
	[2569] = { -- interface/icons/inv_achievement_raiddragon
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/kazzara.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/chamber.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/experiment.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/assault.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/rashok.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/zskarn.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/magmorax.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/neltharion.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/sarkareth.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/aberrus.png",
	},
	[2522] = { --interface/icons/achievement_raidprimalist
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/eranog.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/terros.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/council.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/sennarth.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/dathea.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/kurog.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/diurna.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/raszageth.png",
		miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/vault.png",
	},
}

for _, value in pairs(miog.RAID_ICONS) do
	miog.F.MOST_BOSSES = #value-1 > miog.F.MOST_BOSSES and #value-1 or miog.F.MOST_BOSSES
end

miog.FONTS = {
	libMono = "Interface\\Addons\\MythicIOGrabber\\res\\fonts\\LiberationMono-Regular.ttf",
}

miog.CLASSES = {
	["WARRIOR"] = 		{index = 1, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warrior.png"},
	["PALADIN"] = 		{index = 2, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/paladin.png"},
	["HUNTER"] = 		{index = 3, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/hunter.png"},
	["ROGUE"] = 		{index = 4, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/rogue.png"},
	["PRIEST"] = 		{index = 5, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/priest.png"},
	["DEATHKNIGHT"] = 	{index = 6, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/deathKnight.png"},
	["SHAMAN"] = 		{index = 7, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/shaman.png"},
	["MAGE"] = 			{index = 8, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/mage.png"},
	["WARLOCK"] =		{index = 9, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warlock.png"},
	["MONK"] = 			{index = 10, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/monk.png"},
	["DRUID"] =			{index = 11, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/druid.png"},
	["DEMONHUNTER"] = 	{index = 12, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/demonHunter.png"},
	["EVOKER"] = 		{index = 13, icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/evoker.png"},
}

miog.SEARCH_LANGUAGES = {
	itIT=true,
	ruRU=true,
	frFR=true,
	esES=true,
	deDE=true,
}

miog.ICON_COORDINATES = {
    tankCoords = {0.76, 0.8725, 0.255, 0.367},
    healerCoords = {0.13, 0.2425, 0.255, 0.3675},
    dpsCoords = {0.003, 0.1155, 0.381, 0.4935},
}

miog.PLAYSTYLE_STRINGS = {
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

miog.BACKGROUNDS = {
	[1] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/thisIsTheDayYouWillAlwaysRememberAsTheDayYouAlmostCaughtCaptainJackSparrow_1024.png", --ISLAND EXPEDITIONS
	[2] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/2ndGOAT_1024.png", --RAID
	--[3] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/antorus_1024.png",
	[4] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/arena1_1024.png", --ARENA
	[5] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/arena2_1024.png", --BATTLEGROUNDS
	[6] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/arena3_1024.png", --SKIRMISH
	--[7] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/daddyD_1024.png",
	--[8] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/itsOK_1024.png",
	--[9] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/riseMountains_1024.png", 
	[10] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/letsNotTalkAboutIt_1024.png",
	[11] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/oldSchoolCool1_1024.png", --DUNGEONS
	[12] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/oldSchoolCool2_1024.png", --CUSTOM GROUPS
	[13] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/oldSchoolCool3_1024.png", --QUESTING
	[14] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/swords_1024.png", --RBG'S
	[15] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/thisDidntHappen_1024.png", --TORGHAST
	--[16] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/vanilla_1024.png",
	[17] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/wetSandLand_1024.png", --SCENARIO
	[18] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/lfg-background_1024.png" --BASE
}