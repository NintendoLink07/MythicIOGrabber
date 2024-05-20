local addonName, miog = ...

miog.ITEM_QUALITY_COLORS = _G["ITEM_QUALITY_COLORS"]

for _, colorElement in pairs(miog.ITEM_QUALITY_COLORS) do
	colorElement.pureHex = colorElement.color:GenerateHexColor()
	colorElement.desaturatedRGB = {colorElement.r * 0.65, colorElement.g * 0.65, colorElement.b * 0.65}
	colorElement.desaturatedHex = CreateColor(unpack(colorElement.desaturatedRGB)):GenerateHexColor()
end

miog.CLRSCC = { -- from clrs.cc
	["navy"] = "FF001F3F",
	["blue"] = "FF0074D9",
	["aqua"] = "FF7FDBFF",
	["teal"] = "FF39CCCC",
	["purple"] = "FFB10DC9",
	["fuchsia"] = "FFF012BE",
	["maroon"] = "FF85144b",
	["red"] = "FFFF4136",
	["orange"] = "FFFF851B",
	["yellow"] = "FFFFDC00",
	["olive"] = "FF3D9970",
	["green"] = "FF2ECC40",
	["lime"] = "FF01FF70",
	["black"] = "FF111111",
	["gray"] = "FFAAAAAA",
	["silver"] = "FFDDDDDD",
	["white"] = "FFFFFFFF",
}

miog.APPLICANT_STATUS_INFO = {
	["applied"] = {statusString = "APPLIED", color = "FF3D9970"},
	["invited"] = {statusString = "INVITED", color = "FFFFFF00"},
	["failed"] = {statusString = "FAILED", color = "FFFF009D"},
	["cancelled"] = {statusString = "CANCELLED", color = "FFFFA600"},
	["timedout"] = {statusString = "TIME OUT", color = "FF8400FF"},
	["inviteaccepted"] = {statusString = "INVITE ACCEPTED", color = "FF39B904"},
	["invitedeclined"] = {statusString = "INVITE DECLINED", color = "FFCF2D1B"},
	["declined"] = {statusString = "DECLINED", color = miog.CLRSCC["red"]},
	["declined_full"] = {statusString = "GROUP IS FULL", color = miog.CLRSCC["red"]},
	["declined_delisted"] = {statusString = "DELISTED", color = miog.CLRSCC["red"]},
	["debug"] = {statusString = "GONE BABY", color = miog.CLRSCC["red"]},
	["none"] = {statusString = "NONE", color = miog.CLRSCC["green"]},
}

 miog.INELIGIBILITY_REASONS = {
	[1] = {"No search result info.", "No result"},
	[2] = {"Incorrect categoryID.", "Incorrect category"},
	[3] = {"You have been hard declined from this group.", "Hard declined"},
	[4] = {"The difficulty ID doesn't not match the one you selected.", "Incorrect difficulty"},
	[5] = {"The bracket ID doesn't not match the one you selected.", "Incorrect bracket"},
	[6] = {"No more slots for your role.", "No slots"},
	[7] = {"If you join there won't be anyone who has a class ress ability.", "No ress"},
	[8] = {"If you join there won't be anyone with a lust effect.", "No lust"},
	[9] = {"If you join there won't be anyone to deal with this weeks affixes.", "No affix coverage"},
	[10] = {"Your class filters do not match with this listing.", "Class filtered"},
	[11] = {"Your spec filters do not match with this listing.", "Spec filtered"},
	[12] = {"Incorrect number of tanks/healers/damagers.", "Incorrect roles"},
	[13] = {"Your role filters do not match with this listing.", "Incorrect roles"},
	[14] = {"Your rating filters do not match with this listing.", "Rating mismatch"},
	[15] = {"Your lowest rating filter do not match with this listing.", "Lowest Rating mismatch"},
	[16] = {"Your highest rating filter do not match with this listing.", "Highest Rating mismatch"},
	[17] = {"Your dungeon selection does not match with this listing.", "Dungeon mismatch"},
	[18] = {"Your raid selection does not match with this listing.", "Raid mismatch"},
	[18] = {"Your boss selection does not match with this listing.", "Boss selection mismatch"},
	[20] = {"Your boss kills filters do not match with this listing.", "Boss kills mismatch"},
	[21] = {"Your lowest boss kills filter do not match with this listing.", "Lowest boss kills mismatch"},
	[22] = {"Your highest boss kills filter do not match with this listing.", "Highest boss kills mismatch"},
 }

miog.DIFFICULTY_ID_TO_COLOR = {
	[DifficultyUtil.ID.DungeonNormal] = miog.ITEM_QUALITY_COLORS[2].color,
	[DifficultyUtil.ID.DungeonHeroic] = miog.ITEM_QUALITY_COLORS[3].color,
	[DifficultyUtil.ID.Raid10Normal] = miog.ITEM_QUALITY_COLORS[2].color,
	[DifficultyUtil.ID.Raid25Normal] = miog.ITEM_QUALITY_COLORS[2].color,
	[DifficultyUtil.ID.Raid10Heroic] = miog.ITEM_QUALITY_COLORS[3].color,
	[DifficultyUtil.ID.Raid25Heroic] = miog.ITEM_QUALITY_COLORS[3].color,
	[DifficultyUtil.ID.RaidLFR] = miog.ITEM_QUALITY_COLORS[1].color,
	[DifficultyUtil.ID.DungeonChallenge] = miog.ITEM_QUALITY_COLORS[4].color,
	--[DifficultyUtil.ID.Raid40] = miog.ITEM_QUALITY_COLORS[0].color,
	[DifficultyUtil.ID.Raid40] = miog.ITEM_QUALITY_COLORS[2].color,
	[DifficultyUtil.ID.PrimaryRaidNormal] = miog.ITEM_QUALITY_COLORS[2].color,
	[DifficultyUtil.ID.PrimaryRaidHeroic] = miog.ITEM_QUALITY_COLORS[3].color,
	[DifficultyUtil.ID.PrimaryRaidMythic] = miog.ITEM_QUALITY_COLORS[5].color,
	[DifficultyUtil.ID.PrimaryRaidLFR] = miog.ITEM_QUALITY_COLORS[1].color,
	[DifficultyUtil.ID.DungeonMythic] = miog.ITEM_QUALITY_COLORS[5].color,
	[DifficultyUtil.ID.DungeonTimewalker] = miog.ITEM_QUALITY_COLORS[3].color,
	[DifficultyUtil.ID.RaidTimewalker] = miog.ITEM_QUALITY_COLORS[3].color,
}

miog.DIFFICULTY_ID_INFO = {}

miog.DIFFICULTY = {
	[4] = {shortName = "M+", description = "Mythic+", color = miog.ITEM_QUALITY_COLORS[5].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[5].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[5].color},
	[3] = {shortName = "M", description = _G["PLAYER_DIFFICULTY6"], color = miog.ITEM_QUALITY_COLORS[4].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[4].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[4].color},
	[2] = {shortName = "H", description = _G["PLAYER_DIFFICULTY2"], color = miog.ITEM_QUALITY_COLORS[3].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[3].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[3].color},
	[1] = {shortName = "N", description = _G["PLAYER_DIFFICULTY1"], color = miog.ITEM_QUALITY_COLORS[2].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[2].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[2].color},
	[0] = {shortName = "LT", description = "Last tier", color = miog.ITEM_QUALITY_COLORS[0].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[0].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[0].color},
	[-1] = {shortName = "NT", description = "No tier", color = "FFFF2222", desaturated = "ffe93838"},
}

for i = 0, 205, 1 do -- max # of difficulties in wago tools Difficulty
	local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID, isLFR, minGroupSize, maxGroupSize = GetDifficultyInfo(i)

	if(name) then
		miog.DIFFICULTY_ID_INFO[i] = {name = i == 8 and "Mythic+" or name, shortName = (i == 1 or i == 3 or i == 4 or i == 9 or i == 14) and "N" or (i == 2 or i == 5 or i == 6 or i == 15 or i == 24 or i == 33) and "H" or i == 8 and "M+" or (i == 7 or i == 17) and "LFR" or (i == 16 or i == 23) and "M",
		type = groupType, isHeroic = isHeroic, isChallengeMode = isChallengeMode, isLFR = isLFR, toggleDifficulty = toggleDifficultyID, color = miog.DIFFICULTY_ID_TO_COLOR[i] and miog.DIFFICULTY_ID_TO_COLOR[i]}

	end
end

miog.DIFFICULTY_ID_INFO[0] = {name = " ", shortName = " ", type="party"}

miog.DUNGEON_DIFFICULTIES = {
	DifficultyUtil.ID.DungeonNormal,
	DifficultyUtil.ID.DungeonHeroic,
	DifficultyUtil.ID.DungeonChallenge,
	DifficultyUtil.ID.DungeonMythic,
}

miog.RAID_DIFFICULTIES = {
	DifficultyUtil.ID.PrimaryRaidNormal,
	DifficultyUtil.ID.PrimaryRaidHeroic,
	DifficultyUtil.ID.PrimaryRaidMythic,
}

--CONSTANTS
miog.C = {
	-- 1.5 seconds seems to be the internal throttle of the inspect function / Blizzard's inspect data provider.
	-- 1.4 locks up the inspects after a maximum of ~15 inspects.
	-- First 6 inspects are not affected by this throttle.
	-- I have played around with many different delays or different request "sets" (e.g. every 3 seconds 2 applicants, every 5 seconds 4 applicants) but nothing seems to work as well as: if number of members < 6 all instantly, otherwise every 1.5 seconds (?????????)
	BLIZZARD_INSPECT_THROTTLE = 1.9,


	PLAYER_GUID = UnitGUID("player"),

    --
    --- FRAME SIZES
    --
    FULL_SIZE = 160,
    APPLICANT_MEMBER_HEIGHT = 20,
    APPLICANT_BUTTON_SIZE = 20,
	INTERFACE_OPTION_BUTTON_SIZE = 20,
	MAIN_WIDTH = 0,

    --
    --- FONT SIZES
    --
	CLASS_PANEL_FONT_SIZE = 16,
	SPEC_PANEL_FONT_SIZE = 14,
	TITLE_FONT_SIZE = 14,
	ACTIVITY_NAME_FONT_SIZE = 13,
	LISTING_COMMENT_FONT_SIZE = 12,
	LISTING_INFO_FONT_SIZE = 14,
	AFFIX_TEXTURE_FONT_SIZE = 12, --always weird, gotta change that
	APPLICANT_MEMBER_FONT_SIZE = 11,
	TEXT_ROW_FONT_SIZE = 11,

	SEARCH_RESULT_FRAME_TEXT_SIZE = 14,
    
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

	REGIONS = {
		[1]	= "us",
		[2]	= "kr",
		[3]	= "eu",
		[4] = "tw",
		[5] = "cn",
		[72] = "eu", --ptr, forcing eu for development
 	},

	STANDARD_PADDING = 4,
	APPLICANT_PADDING = 2,

	--PATH / TEXTURES FILES
	STANDARD_FILE_PATH = "Interface/Addons/MythicIOGrabber/res",
	RIO_STAR_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/star_64.png:8:8|t",
	TANK_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/tankIcon.png:20:20|t",
	HEALER_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/healerIcon.png:20:20|t",
	DPS_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/damagerIcon.png:20:20|t",
	STAR_TEXTURE = "⋆",
	
	AVAILABLE_ROLES = {
		["TANK"] = false,
		["HEALER"] = false,
		["DAMAGER"] = false
	},

	SEASON_AVAILABLE = {
		[12] = {
			sinceEpoch = 1713942000,
			awakened = {
				vaultDate1 = 1713942000,
				aberrusDate1 = 1713942000 + 604800 * 1,
				amirdrassilDate1 = 1713942000 + 604800 * 2,
				vaultDate2 = 1713942000 + 604800 * 3,
				aberrusDate2 = 1713942000 + 604800 * 4,
				amirdrassilDate2 = 1713942000 + 604800 * 5,
				fullRelease = 1713942000 + 604800 * 6,
			}
		}
	},

	

	REGION_DATE_DIFFERENCE = {
		[1] = -86400,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[72] = 0,
	},
}

miog.MPLUS_SEASONS = {
	-- Dragonflight
	[9] = "S1", --8
	[10] = "S2", --8
	[11] = "S3", --8
	[12] = "S4", --8
	[13] = "S1", --8
	[99] = "DUMMY SEASON"
}


--CHANGING VARIABLES
miog.F = {
    WEEKLY_AFFIX = nil,
    SHOW_TANKS = true,
    SHOW_HEALERS = true,
    SHOW_DPS = true,
	LISTED_CATEGORY_ID = 0,
	LOADING_SCREEN_OCCURRED = false,

	NUM_OF_GROUP_MEMBERS = 0,

	REQUIRED_RATING = 0,
	REQUIRED_ILVL = 0,

	IS_RAIDERIO_LOADED = false,
	IS_PGF1_LOADED = false,
	IS_IN_DEBUG_MODE = false,

	MOST_BOSSES = 0,
	
	CURRENTLY_INSPECTING = false,
	ACTIVE_ENTRY_INFO = nil,
	
	CURRENT_DUNGEON_DIFFICULTY = 0,
	CURRENT_RAID_DIFFICULTY = 0,

	CURRENT_REGION = miog.C.REGIONS[GetCurrentRegion()],
	CURRENT_SEASON = nil,
	PREVIOUS_SEASON = nil,

	LFG_STATE = "solo",

	RAID_BOSSES = {},

	LAST_INVITES_COUNTER = 0,
	FAVOURED_APPLICANTS_COUNTER = 0,

	LAST_INVITED_APPLICANTS = {},
	FAVOURED_APPLICANTS = {},

	CAN_INVITE = false,

	CURRENT_SEARCH_RESULT_ID = 0,
	WAITING_FOR_RESULTS = false,

	SEARCH_IS_THROTTLED = false,

	ADDED_DUNGEON_FILTERS = false,

	AFFIX_INFO = {},
}

local color = "FF1eff00"

miog.BLANK_BACKGROUND_INFO = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tileSize = miog.C.APPLICANT_MEMBER_HEIGHT,
	tile = false,
	edgeSize = 1
}

miog.INSTANCE_IDS = {
	
}

miog.BRACKETS = {
	[2] = {shortName = "3's", description = _G["ARENA_3V3"], color = miog.ITEM_QUALITY_COLORS[3].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[3].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[3].color},
	[1] = {shortName = "2's", description = _G["ARENA_2V2"], color = miog.ITEM_QUALITY_COLORS[2].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[2].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[2].color},
	--[0] = {shortName = "LT", description = "Last tier", color = miog.ITEM_QUALITY_COLORS[0].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[0].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[0].color},
	--[-1] = {shortName = "NT", description = "No tier", color = "FFFF2222", desaturated = "ffe93838"},
}

miog.DIFFICULTY_NAMES_TO_ID = {
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

miog.MAP_INFO = {
	[30] = {shortName = "AV", icon = "interface/lfgframe/lfgicon-battleground.blp", fileName = "pvpbattleground"},
	[489] = {shortName = "WSG", icon = "interface/lfgframe/lfgicon-warsonggulch.blp", fileName = "warsonggulch_update"},
	[529] = {shortName = "AB", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasin_update"},
	[559] = {shortName = "NA", icon = "interface/lfgframe/lfgicon-nagrandarena.blp", fileName = "nagrandarenabg"},
	[562] = {shortName = "BEA", icon = "interface/lfgframe/lfgicon-bladesedgearena.blp", fileName = "bladesedgearena"},
	[566] = {shortName = "EOTS", icon = "interface/lfgframe/lfgicon-netherbattlegrounds.blp", fileName = "netherbattleground"},
	[572] = {shortName = "ROL", icon = "interface/lfgframe/lfgicon-ruinsoflordaeron.blp", fileName = "ruinsoflordaeronbg"},
	[607] = {shortName = "SOTA", icon = "interface/lfgframe/lfgicon-strandoftheancients.blp", fileName = "northrendbg"},
	[617] = {shortName = "DS", icon = "interface/lfgframe/lfgicon-dalaransewers.blp", fileName = "dalaransewersarena"},
	[618] = {shortName = "ROV", icon = "interface/lfgframe/lfgicon-ringofvalor.blp", fileName = "orgrimmararena"},
	[628] = {shortName = "IOC", icon = "interface/lfgframe/lfgicon-isleofconquest.blp", fileName = "isleofconquest"},
	[726] = {shortName = "TP", icon = "interface/lfgframe/lfgicon-twinpeaksbg.blp", fileName = "twinpeaksbg"},
	[727] = {shortName = "SSM", icon = "interface/lfgframe/lfgicon-silvershardmines.blp", fileName = "silvershardmines"},
	[761] = {shortName = "BFG", icon = "interface/lfgframe/lfgicon-thebattleforgilneas.blp", fileName = "gilneasbg2"},
	[968] = {shortName = "EOTS", icon = "interface/lfgframe/lfgicon-netherbattlegrounds.blp", fileName = "netherbattleground"},
	[980] = {shortName = "TVA", icon = "interface/lfgframe/lfgicon-tolvirarena.blp", fileName = "tolvirarena"},
	[998] = {shortName = "TOK", icon = "interface/lfgframe/lfgicon-templeofkotmogu.blp", fileName = "templeofkotmogu"},
	[1105] = {shortName = "DWD", icon = "interface/lfgframe/lfgicon-deepwindgorge.blp", fileName = "goldrush"},
	[1134] = {shortName = "TP", icon = "interface/lfgframe/lfgicon-shadopanbg.blp", fileName = "shadowpan_bg"},
	[1191] = {shortName = "ASH", icon = "interface/lfgframe/lfgicon-ashran.blp", fileName = "shadowpan_bg"},
	[1504] = {shortName = "BRH", icon = "interface/lfgframe/lfgicon-blackrookholdarena.blp", fileName = "blackrookholdarena"},
	[1505] = {shortName = "NA", icon = "interface/lfgframe/lfgicon-nagrandarena.blp", fileName = "nagrandarenabg"},
	[1552] = {shortName = "AF", icon = "interface/lfgframe/lfgicon-valsharraharena.blp", fileName = "arenavalsharah"},
	[1672] = {shortName = "BEA", icon = "interface/lfgframe/lfgicon-bladesedgearena.blp", fileName = "bladesedgearena"},
	[1681] = {shortName = "AB-W", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasinwinter"},
	[1715] = {shortName = "BBM", icon = "interface/lfgframe/lfgicon-blackrockdepths.blp", fileName = "blackrockdepths"},
	[1782] = {shortName = "SST", icon = "interface/lfgframe/lfgicon-seethingshore.blp", fileName = "seethingshore"},
	[1803] = {shortName = "SSH", icon = "interface/lfgframe/lfgicon-seethingshore.blp", fileName = "seethingshore"},
	[2106] = {shortName = "WSG", icon = "interface/lfgframe/lfgicon-warsonggulch.blp", fileName = "warsonggulch_update"},
	[2107] = {shortName = "AB", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasin_update"},
	[2118] = {shortName = "BFW", icon = "interface/lfgframe/lfgicon-battleground.blp", fileName = "wintergrasp"},
	[2245] = {shortName = "DWG", icon = "interface/lfgframe/lfgicon-deepwindgorge.blp", fileName = "goldrush"},

	--ASHRAN BACKGROUND=??????Wd0aßwdiawd



	--CATACLYSM
	[643] = {shortName = "TOTT", icon = "interface/lfgframe/lfgicon-throneofthetides", fileName = "throneofthetides"},
	[657] = {shortName = "VP", icon = "interface/lfgframe/lfgicon-thevortexpinnacle", fileName = "vortexpinnacle"},

	--MISTS OF PANDARIA
	[960] = {shortName = "TOJS", icon = "interface/lfgframe/lfgicon-templeofthejadeserpent", fileName = "jadetemple"},

	--WARLORDS OF DRAENOR
	[1176] = {shortName = "SBG", icon = "interface/lfgframe/lfgicon-shadowmoonburialgrounds", fileName = "shadowmoonburialgrounds"},
	[1279] = {shortName = "EB", icon = "interface/lfgframe/lfgicon-everbloom", fileName = "everbloom"},

	--LEGION
	[1458] = {shortName = "NL", icon = "interface/lfgframe/lfgicon-neltharionslair", fileName = "neltharionslair"},
	[1466] = {shortName = "DHT", icon = "interface/lfgframe/lfgicon-darkheartthicket", fileName = "darkheartthicket"},
	[1477] = {shortName = "HoV", icon = "interface/lfgframe/lfgicon-hallsofvalor", fileName = "hallsofvalor"},
	[1571] = {shortName = "CoS", icon = "interface/lfgframe/lfgicon-courtofstars", fileName = "suramarcitydungeon"},
	[1501] = {shortName = "BRH", icon = "interface/lfgframe/lfgicon-blackrookhold", fileName = "blackrookhold"},

	--BATTLE FOR AZEROTH
	[1754] = {shortName = "FH", icon = "interface/lfgframe/lfgicon-freehold", fileName = "freehold"},
	[1763] = {shortName = "AD", icon = "interface/lfgframe/lfgicon-ataldazar", fileName = "ataldazar"},
	[1841] = {shortName = "UR", icon = "interface/lfgframe/lfgicon-theunderrot", fileName = "underrot"},
	[1862] = {shortName = "WM", icon = "interface/lfgframe/lfgicon-waycrestmanor", fileName = "waycrestmanor"},

	--SHADOWLANDS

	--DRAGONFLIGHT
	[2451] = {shortName = "ULOT", icon = "interface/lfgframe/lfgicon-uldaman-legacyoftyr", fileName = "uldamanlegacyoftyr"},
	[2515] = {shortName = "AV", icon = "interface/lfgframe/lfgicon-arcanevaults", fileName = "azurevault"},
	[2516] = {shortName = "NO", icon = "interface/lfgframe/lfgicon-centaurplains", fileName = "nokhudoffensive"},
	[2519] = {shortName = "NELT", icon = "interface/lfgframe/lfgicon-neltharus", fileName = "neltharus"},
	[2520] = {shortName = "BH", icon = "interface/lfgframe/lfgicon-brackenhidehollow", fileName = "brackenhidehollow"},
	[2521] = {shortName = "RLP", icon = "interface/lfgframe/lfgicon-lifepools", fileName = "rubylifepools"},
	[2526] = {shortName = "AA", icon = "interface/lfgframe/lfgicon-theacademy", fileName = "algetharacademy"},
	[2527] = {shortName = "HOI", icon = "interface/lfgframe/lfgicon-hallsofinfusion", fileName = "hallsofinfusion"},
	[2579] = {shortName = "DOTI", icon = "interface/lfgframe/lfgicon-dawnoftheinfinite", fileName = "dawnoftheinfinite"},


	-- RAIDS

	[2444] = {
		shortName = "DF WORLD", icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/dfWorld.png", fileName = "dragonislescontinent",
	},
	[2549] = { --interface/icons/inv_achievement_raidemeralddream
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/gnarlroot.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/igira.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/volcoross.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/council.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/larodar.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/nymue.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/smolderon.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/tindral.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/fyrakk.png"},
		shortName = "ATDH", icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/amirdrassil.png", fileName = "amirdrassil",
	},
	[2569] = { -- interface/icons/inv_achievement_raiddragon
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/kazzara.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/chamber.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/experiment.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/assault.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/rashok.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/zskarn.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/magmorax.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/neltharion.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/sarkareth.png"},
		shortName = "ATSC", icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/aberrus.png", fileName = "aberrus",
	},
	[2522] = { --interface/icons/achievement_raidprimalist
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/eranog.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/terros.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/council.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/sennarth.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/dathea.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/kurog.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/diurna.png"},
		{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/raszageth.png"},
		shortName = "VOTI", icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/vault.png", fileName = "vaultoftheincarnates",
	},

	[1136] = {shortName = "SOO", icon = "interface/lfgframe/lfgicon-orgrimmargates", fileName = "siegeoforgrimmar"},
	[36] = {shortName = "DM", icon = "interface/lfgframe/lfgicon-deadmines.blp", fileName = "deadmines"},
	[1175] = {shortName = "BSM", icon = "interface/lfgframe/lfgicon-bloodmaulslagmines.blp", fileName = "ogrecompound"},
	[1195] = {shortName = "ID", icon = "interface/lfgframe/lfgicon-irondocks.blp", fileName = "irondocks"},
	[1182] = {shortName = "AUCH", icon = "interface/lfgframe/lfgicon-auchindounwod.blp", fileName = "auchindoun_wod"},
	[1209] = {shortName = "SR", icon = "interface/lfgframe/lfgicon-skyreach.blp", fileName = "skyreach"},
	[1208] = {shortName = "GD", icon = "interface/lfgframe/lfgicon-grimraildepot.blp", fileName = "blackrocktraindepot"},
	[1358] = {shortName = "UBRS", icon = "interface/lfgframe/lfgicon-upperblackrockspire.blp", fileName = "upperblackrockspire"},
	[1228] = {shortName = "HM", icon = "interface/lfgframe/lfgicon-highmaul.blp", fileName = "highmaulraid"},
	[1205] = {shortName = "BRF", icon = "interface/lfgframe/lfgicon-blackrockfoundry.blp", fileName = "blackrockfoundry"},

	[409] = {shortName = "MC", fileName = "moltencore"},
	[469] = {shortName = "BWL", fileName = "blackwinglair"},
	[509] = {shortName = "AQ20", fileName = "ahnqiraj20man"},
	[531] = {shortName = "AQ40", icon = "interface/lfgframe/lfgicon-aqtemple.blp", fileName = "ahnqiraj40man"},
	[533] = {shortName = "NAXX", icon = "interface/lfgframe/lfgicon-naxxramas.blp", fileName = "naxxramas"},
	[631] = {shortName = "ICC", icon = "interface/lfgframe/lfgicon-icecrowncitadel.blp", fileName = "icecrowncitadel"},

	[1007] = {shortName = "SCHOLO", icon = "interface/lfgframe/lfgicon-scholomance.blp", fileName = "scholomance2"},
	[33] = {shortName = "SFK", icon = "interface/lfgframe/lfgicon-shadowfangkeep.blp", fileName = "shadowfangkeep"},

	[543] = {shortName = "RAMPS", icon = "interface/lfgframe/lfgicon-hellfirecitadel.blp", fileName = "hellfirecitadel"},
	[542] = {shortName = "BF", icon = "interface/lfgframe/lfgicon-hellfirecitadel.blp", fileName = "hellfirecitadel"},
	[540] = {shortName = "SH", icon = "interface/lfgframe/lfgicon-hellfirecitadel.blp", fileName = "hellfirecitadel"},
	[547] = {shortName = "SP", icon = "interface/lfgframe/lfgicon-coilfang.blp", fileName = "coilfang"},
	[546] = {shortName = "UB", icon = "interface/lfgframe/lfgicon-coilfang.blp", fileName = "coilfang"},
	[545] = {shortName = "SV", icon = "interface/lfgframe/lfgicon-coilfang.blp", fileName = "coilfang"},
	[557] = {shortName = "MT", icon = "interface/lfgframe/lfgicon-auchindoun.blp", fileName = "auchindoun"},
	[558] = {shortName = "CRYPTS", icon = "interface/lfgframe/lfgicon-auchindoun.blp", fileName = "auchindoun"},
	[556] = {shortName = "SETH", icon = "interface/lfgframe/lfgicon-auchindoun.blp", fileName = "auchindoun"},
	[555] = {shortName = "SL", icon = "interface/lfgframe/lfgicon-auchindoun.blp", fileName = "auchindoun"},
	[1001] = {shortName = "SH", icon = "interface/lfgframe/lfgicon-scarlethalls.blp", fileName = "scarlethalls"},
	[1004] = {shortName = "SM", icon = "interface/lfgframe/lfgicon-scarletmonastery.blp", fileName = "scarletmonastery2"},
	[560] = {shortName = "EFD", icon = "interface/lfgframe/lfgicon-cavernsoftime.blp", fileName = "cavernstime"},
	[269] = {shortName = "BM", icon = "interface/lfgframe/lfgicon-cavernsoftime.blp", fileName = "cavernstime"},
	[554] = {shortName = "MECH", icon = "interface/lfgframe/lfgicon-tempestkeep.blp", fileName = "tempestkeep"},
	[553] = {shortName = "BOTA", icon = "interface/lfgframe/lfgicon-tempestkeep.blp", fileName = "tempestkeep"},
	[552] = {shortName = "ARC", icon = "interface/lfgframe/lfgicon-tempestkeep.blp", fileName = "tempestkeep"},
	[585] = {shortName = "MGT", icon = "interface/lfgframe/lfgicon-magistersterrace.blp", fileName = "sunwell5man"},
	
	[532] = {shortName = "KARA", icon = "interface/lfgframe/lfgicon-karazhan.blp", fileName = "karazhan"},
	[544] = {shortName = "ML", icon = "interface/lfgframe/lfgicon-hellfireraid.blp", fileName = "hellfireraid"},
	[548] = {shortName = "SSC", icon = "interface/lfgframe/lfgicon-serpentshrinecavern.blp", fileName = "coilfang"},
	[550] = {shortName = "TK", icon = "interface/lfgframe/lfgicon-tempestkeep.blp", fileName = "tempestkeep"},
	[564] = {shortName = "BT", icon = "interface/lfgframe/lfgicon-blacktemple.blp", fileName = "blacktemple"},
	[565] = {shortName = "GL", icon = "interface/lfgframe/lfgicon-gruulslair.blp", fileName = "gruulslair"},
	[580] = {shortName = "SW", icon = "interface/lfgframe/lfgicon-sunwell.blp", fileName = "sunwell"},

	[574] = {shortName = "UTK", icon = "interface/lfgframe/lfgicon-utgarde.blp", fileName = "utgardekeep"},
	[575] = {shortName = "UTP", icon = "interface/lfgframe/lfgicon-utgardepinnacle.blp", fileName = "utgardepinnacle"},
	[601] = {shortName = "AN", icon = "interface/lfgframe/lfgicon-azjolnerub.blp", fileName = "azjoluppercity"},
	[578] = {shortName = "OCU", icon = "interface/lfgframe/lfgicon-theoculus.blp", fileName = "nexus80"},
	[602] = {shortName = "HOL", icon = "interface/lfgframe/lfgicon-hallsoflightning.blp", fileName = "ulduar80"},
	[599] = {shortName = "HOS", icon = "interface/lfgframe/lfgicon-hallsofstone.blp", fileName = "ulduar70"},
	[595] = {shortName = "CULL", icon = "interface/lfgframe/lfgicon-oldstratholme.blp", fileName = "stratholme"},
	[600] = {shortName = "DTK", icon = "interface/lfgframe/lfgicon-draktharon.blp", fileName = "draktharon"},
	[604] = {shortName = "GUN", icon = "interface/lfgframe/lfgicon-gundrak.blp", fileName = "gundrak"},
	[619] = {shortName = "ATOK", icon = "interface/lfgframe/lfgicon-ahnkalet.blp", fileName = "azjolnerub76"},
	[608] = {shortName = "VH", icon = "interface/lfgframe/lfgicon-theviolethold.blp", fileName = "dalaranprison"},
	[576] = {shortName = "NEX", icon = "interface/lfgframe/lfgicon-thenexus.blp", fileName = "nexus70"},
	[650] = {shortName = "TOTC", icon = "interface/lfgframe/lfgicon-argentdungeon.blp", fileName = "argentdungeon"},
	[632] = {shortName = "FOS", icon = "interface/lfgframe/lfgicon-theforgeofsouls.blp", fileName = "icecrown5man"},
	[658] = {shortName = "PIT", icon = "interface/lfgframe/lfgicon-pitofsaron.blp", fileName = "pitofsaron"},
	[668] = {shortName = "HOR", icon = "interface/lfgframe/lfgicon-hallsofreflection.blp", fileName = "hallsofreflection"},
	[603] = {shortName = "ULD", icon = "interface/lfgframe/lfgicon-ulduar.blp", fileName = "ulduar80"},

	[43] = {shortName = "WC", fileName = "wailingcaverns"},
	[389] = {shortName = "RFC", fileName = "ragefirechasm"},
	[48] = {shortName = "BFD", fileName = "blackfathomdeeps"},
	[34] = {shortName = "SS", fileName = "stormwindstockade"},
	[90] = {shortName = "GR", fileName = "gnomeregan"},
	[47] = {shortName = "RFK", fileName = "razorfenkraul"},
	[129] = {shortName = "RFD", fileName = "razorfendowns"},
	[70] = {shortName = "ULDA", fileName = "uldamanold"},
	[209] = {shortName = "ZF", fileName = "zulfarrak"},
	[349] = {shortName = "MAU", fileName = "maraudon"},
	[109] = {shortName = "ST", fileName = "sunkentemple"},
	[230] = {shortName = "BRD", fileName = "blackrockdepths"},
	[229] = {shortName = "BRS", fileName = "blackrockspire"},
	[429] = {shortName = "DM", fileName = "diremaul"},
	[329] = {shortName = "SH", fileName = "stratholme"},
	[859] = {shortName = "ZG", fileName = "zulgurub"},
	[568] = {shortName = "ZA", fileName = "zulaman2"},
	[938] = {shortName = "ET", fileName = "endoftime"},
	[939] = {shortName = "WOE", fileName = "wellofeternity"},
	[940] = {shortName = "HOT", fileName = "houroftwilight"},

	[645] = {shortName = "BRC", icon = "interface/lfgframe/lfgicon-blackrockcaverns.blp", fileName = "blackrockcaverns"},
	[670] = {shortName = "GB", icon = "interface/lfgframe/lfgicon-grimbatol.blp", fileName = "grimbatol"},
	[644] = {shortName = "HOO", icon = "interface/lfgframe/lfgicon-hallsoforigination.blp", fileName = "hallsoforigination"},
	[725] = {shortName = "SC", icon = "interface/lfgframe/lfgicon-thestonecore.blp", fileName = "deepholmdungeon"},
	[755] = {shortName = "LCT", icon = "interface/lfgframe/lfgicon-lostcityoftolvir.blp", fileName = "lostcityoftolvir"},

	[961] = {shortName = "SSB", icon = "interface/lfgframe/lfgicon-stormstoutbrewery.blp", fileName = "stormstoutbrewery"},
	[959] = {shortName = "SPM", icon = "interface/lfgframe/lfgicon-shadowpanmonastery.blp", fileName = "shadowpanmonastery"},
	[994] = {shortName = "MSP", icon = "interface/lfgframe/lfgicon-mogushanpalace.blp", fileName = "mogushanpalace"},
	[1011] = {shortName = "SNT", icon = "interface/lfgframe/lfgicon-siegeofnizaotemple.blp", fileName = "siegeofnizaotemple"},
	[962] = {shortName = "GOTSS", icon = "interface/lfgframe/lfgicon-gateofthesettingsun.blp", fileName = "gateofthesettingsun"},
	--[] = {shortName = "EB", icon = ""},

	[649] = {shortName = "TOTC", icon = "interface/lfgframe/lfgicon-argentraid.blp", fileName = "argentraid"},
	[724] = {shortName = "RS", icon = "interface/lfgframe/lfgicon-rubysanctum.blp", fileName = "rubysanctum"},

	[669] = {shortName = "BWD", icon = "interface/lfgframe/lfgicon-blackwingdescentraid.blp", fileName = "blackwingdescentraid"},
	[671] = {shortName = "BOT", icon = "interface/lfgframe/lfgicon-grimbatol.blp", fileName = "grimbatolraid"},
	[754] = {shortName = "TOTFW", icon = "interface/lfgframe/lfgicon-throneofthefourwinds.blp", fileName = "throneofthefourwinds"},
	[720] = {shortName = "FL", icon = "interface/lfgframe/lfgicon-firelands.blp", fileName = "firelandsraid"},
	[967] = {shortName = "DS", icon = "interface/lfgframe/lfgicon-dragonsoul.blp", fileName = "deathwingraid"},

	[1008] = {shortName = "MSV", icon = "interface/lfgframe/lfgicon-mogushanvaults.blp", fileName = "mogushanvaults"},
	[1009] = {shortName = "HOF", icon = "interface/lfgframe/lfgicon-heartoffear.blp", fileName = "heartoffear"},
	[996] = {shortName = "TOES", icon = "interface/lfgframe/lfgicon-terraceoftheendlessspring.blp", fileName = "terraceoftheendlessspring"},
	[1098] = {shortName = "TOT", icon = "interface/lfgframe/lfgicon-thunderforgotten.blp", fileName = "throneofthunder"},
	--[870] = {shortName = "RPD", icon = ""}, --RANDOM PANDARIA DUNGEON
	--[1116] = {shortName = "RWD", icon = ""}, --RANDOM WARLORDS DUNGEON
	[1448] = {shortName = "HFC", icon = "interface/lfgframe/lfgicon-hellfireraid.blp", fileName = "hellfireraid"},
	--[1220] = {shortName = "RLD", icon = ""}, --RANDOM LEGION DUNGEON

	[1456] = {shortName = "EOA", icon = "interface/lfgframe/lfgicon-eyeofazshara.blp", fileName = "nagadungeon"},
	[1544] = {shortName = "AOVH", icon = "interface/lfgframe/lfgicon-assaultonviolethold.blp", fileName = "violethold"},
	[1493] = {shortName = "VOTW", icon = "interface/lfgframe/lfgicon-vaultofthewardens.blp", fileName = "vaultofthewardens"},
	[1492] = {shortName = "MOS", icon = "interface/lfgframe/lfgicon-mawofsouls.blp", fileName = "helheimship"},
	[1516] = {shortName = "ARC", icon = "interface/lfgframe/lfgicon-thearcway.blp", fileName = "suramarcatacombs"},

	[1520] = {shortName = "EN", icon = "interface/lfgframe/lfgicon-theemeraldnightmare-riftofaln.blp", fileName = "emeraldnightmareraid"},
	[1530] = {shortName = "NH", icon = "interface/lfgframe/lfgicon-thenighthold.blp", fileName = "suramarraid"},
	[1648] = {shortName = "TOV", icon = "interface/lfgframe/lfgicon-trialofvalor.blp", fileName = "trialsofvalor"},
	--[1651] = {shortName = "", icon = ""},
	[1651] = {shortName = "RTK", icon = "interface/lfgframe/lfgicon-returntokarazhan.blp", fileName = "returntokarazhan"},
	[1677] = {shortName = "COEN", icon = "interface/lfgframe/lfgicon-cathedralofeternalnight.blp", fileName = "tombofsargerasdungeon"},

	[1676] = {shortName = "TOS", icon = "interface/lfgframe/lfgicon-tombofsargeraschamberoftheavatar.blp", fileName = "tombofsargerasraid"},
	[1712] = {shortName = "ATBT", icon = "interface/lfgframe/lfgicon-antorus.blp", fileName = "argusraid"},
	[1753] = {shortName = "SEAT", icon = "interface/lfgframe/lfgicon-seatofthetriumvirate.blp", fileName = "argusdungeon"},

	[1861] = {shortName = "ULDIR", icon = "interface/lfgframe/lfgicon-uldir.blp", fileName = "nazmirraid"},
	--[1642] = {shortName = "RBD", icon = ""}, --RANDOM BFA DUNGEON
	[1877] = {shortName = "TOS", icon = "interface/lfgframe/lfgicon-templeofsethraliss.blp", fileName = "serpentinetunnels"},
	[1594] = {shortName = "ML", icon = "interface/lfgframe/lfgicon-themotherlode.blp", fileName = "goblinmine"},
	[1762] = {shortName = "KR", icon = "interface/lfgframe/lfgicon-kingsrest.blp", fileName = "goldencityinterior----kingsrest"},
	[1864] = {shortName = "SOTS", icon = "interface/lfgframe/lfgicon-shrineofthestorm.blp", fileName = "shrineofthestorm"},
	[1771] = {shortName = "TD", icon = "interface/lfgframe/lfgicon-toldagor.blp", fileName = "toldagor"},
	[1822] = {shortName = "SOB", icon = "interface/lfgframe/lfgicon-siegeofboralus.blp", fileName = "boralusdungeon"},
	[2070] = {shortName = "BOD", icon = "interface/lfgframe/lfgicon-battleofdazaralor.blp", fileName = "zuldazarraid"},
	[2096] = {shortName = "COS", icon = "interface/lfgframe/lfgicon-crucibleofstorms.blp", fileName = "seapriestraid"},
	[2164] = {shortName = "EP", icon = "interface/lfgframe/lfgicon-eternalpalace.blp", fileName = "eternalpalace"},
	[2097] = {shortName = "MECH", icon = "interface/lfgframe/lfgicon-mechagon.blp", fileName = "mechagonzone"},
	[2217] = {shortName = "NYA", icon = "interface/lfgframe/lfgicon-nyalotha.blp", fileName = "nyalotha"},
	
	[2289] = {shortName = "PF", icon = "interface/lfgframe/lfgicon-plaguefall.blp", fileName = "plaguefall"},
	[2291] = {shortName = "DOS", icon = "interface/lfgframe/lfgicon-theotherside.blp", fileName = "theotherside"},
	[2287] = {shortName = "HOA", icon = "interface/lfgframe/lfgicon-hallsofatonement.blp", fileName = "hallsofatonement"},
	[2290] = {shortName = "MOTS", icon = "interface/lfgframe/lfgicon-mistsoftirnascithe.blp", fileName = "mistsoftirnascithe"},
	[2284] = {shortName = "SD", icon = "interface/lfgframe/lfgicon-sanguinedepths.blp", fileName = "sanguinedepths"},
	[2285] = {shortName = "SOA", icon = "interface/lfgframe/lfgicon-spiresofascension.blp", fileName = "spiresofascension"},
	[2286] = {shortName = "NW", icon = "interface/lfgframe/lfgicon-necroticwake.blp", fileName = "necroticwake"},
	[2293] = {shortName = "TOP", icon = "interface/lfgframe/lfgicon-theaterofpain.blp", fileName = "theaterofpain"},
	[2296] = {shortName = "CN", icon = "interface/lfgframe/lfgicon-castlenathria.blp", fileName = "castlenathria"},
	[2450] = {shortName = "SOD", icon = "interface/lfgframe/lfgicon-sanctumofdomination.blp", fileName = "sanctumofdomination"},
	[2441] = {shortName = "TAZA", icon = "interface/lfgframe/lfgicon-tazaveshtheveiledmarket.blp", fileName = "tazavesh"},
	[2481] = {shortName = "SFO", icon = "interface/lfgframe/lfgicon-sepulcherofthefirstones.blp", fileName = "sepulcherofthefirstones"},
	--[2162] = {shortName = "TJG", icon = ""},
}

miog.LFG_ID_INFO = {
	[1453] = { shortName = "TWMOP", icon = "interface/lfgframe/lfgicon-pandaria.blp", fileName = "pandaria"}, --RANDOM PANDARIA DUNGEON
	[1971] = {shortName = "RWD", icon = "interface/lfgframe/lfgicon-draenor.blp", fileName = "draenor"}, --RANDOM WARLORDS DUNGEONi
	[2350] = { shortName = "LFDN", icon = "interface/lfgframe/lfgicon-dragonislescontinent.blp", fileName = "dragonislescontinent"},
	[2351] = { shortName = "LFDH", icon = "interface/lfgframe/lfgicon-dragonislescontinent.blp", fileName = "dragonislescontinent"},
}

miog.MAP_ID_TO_GROUP_ACTIVITY_ID = {

	[1136] = 1,
	--[602] = 2,
	--[599] = 3,
	--[595] = 4,
	[36] = 5,
	[1175] = 6,
	[1195] = 7,
	[1182] = 8,
	[1209] = 9,
	[1208] = 10,

	[1279] = 11,
	[1176] = 12,
	[1358] = 13,
	[1228] = 14,
	[1205] = 15,
	[533] = 16,
	[631] = 17,
	[1007] = 18,
	[33] = 19,
	[543] = 20,

	[542] = 21,
	[540] = 22,
	[547] = 23,
	[546] = 24,
	[545] = 25,
	[557] = 26,
	[558] = 27,
	[556] = 28,
	[555] = 29,
	[1001] = 30,

	[1004] = 31,
	[560] = 32,
	[269] = 33,
	[554] = 34,
	[553] = 35,
	[552] = 36,
	[585] = 37,
	[574] = 38,
	[575] = 39,
	[601] = 40,

	[578] = 41,
	[602] = 42,
	[599] = 43,
	[595] = 44,
	[600] = 45,
	[604] = 46,
	[619] = 47,
	[608] = 48,
	[576] = 49,
	[650] = 50,

	[632] = 51,
	[658] = 52,
	[668] = 53,
	[643] = 54,
	[645] = 55,
	[670] = 56,
	[644] = 57,
	[725] = 58,

	[657] = 59,
	[755] = 60,
	[960] = 61,
	[961] = 62,
	[959] = 63,
	[994] = 64,
	[1011] = 65,

	[962] = 66,
	[649] = 73,
	[724] = 74,
	[669] = 75,
	[671] = 76,
	[754] = 77,
	[720] = 78,

	[967] = 79,
	[1008] = 80,
	[1009] = 81,
	[996] = 82,
	[1098] = 83,
	[1116] = 109,

	[1448] = 110,
	[1220] = 111,
	[1456] = 112,
	[1466] = 113,
	[1477] = 114,
	[1458] = 115,

	[1544] = 116,
	[1493] = 117,
	[1501] = 118,
	[1492] = 119,
	[1571] = 120,
	[1516] = 121,

	[1520] = 122,
	[1530] = 123,
	[1648] = 126,
	--[1651] = 127,
	[1651] = 128,
	[1677] = 129,

	[1676] = 131,
	[1712] = 132,
	[1753] = 133,
	[1861] = 135,
	[1642] = 136,
	[1763] = 137,

	[1841] = 138,
	[1877] = 139,
	[1594] = 140,
	[1762] = 141,
	[1754] = 142,
	[1864] = 143,

	[1771] = 144,
	[1862] = 145,
	[1822] = 146,
	[2070] = 251,
	[2096] = 252,
	[2164] = 254,

	[1804] = 254,
	[2097] = 257,
	[2217] = 258,
	[2289] = 259,
	[2291] = 260,
	
	[2287] = 261,
	[2290] = 262,
	[2284] = 263,
	[2285] = 264,

	[2286] = 265,
	[2293] = 266,
	[2296] = 267,
	[2450] = 271,
	[2441] = 281,
	[2481] = 282,
	[2162] = 283,
}

miog.GROUP_ACTIVITY = {  -- https://wago.tools/db2/GroupFinderActivityGrp
	--[] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[1] = {mapID = 1136, file = miog.C.STANDARD_FILE_PATH .. "siegeoforgrimmar"},
	[2] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "easternkingdoms outdoor"},
	[3] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "kalimdor outdoor"},
	[5] = {mapID = 36, file = miog.C.STANDARD_FILE_PATH .. "deadmines"},
	[6] = {mapID = 1175, file = miog.C.STANDARD_FILE_PATH .. "bloodmaulslagmines"},
	[7] = {mapID = 1195, file = miog.C.STANDARD_FILE_PATH .. "irondocks"},
	[8] = {mapID = 1182, file = miog.C.STANDARD_FILE_PATH .. "auchindoun"},
	[9] = {mapID = 1209, file = miog.C.STANDARD_FILE_PATH .. "skyreach"},
	
	[10] = {mapID = 1208, file = miog.C.STANDARD_FILE_PATH .. "grimraildepot"},
	[11] = {mapID = 1279, challengeModeID = 168, shortName = "EB", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/everbloom.png"},
	[12] = {mapID = 1176, challengeModeID = 165, shortName = "SBG", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/shadowmoonburialgrounds.png"},
	[13] = {mapID = 1358, file = miog.C.STANDARD_FILE_PATH .. "upperblackrockspire"},
	[14] = {mapID = 1228, file = miog.C.STANDARD_FILE_PATH .. "highmaul"},
	[15] = {mapID = 1205, file = miog.C.STANDARD_FILE_PATH .. "blackrockfoundry"},
	[16] = {mapID = 533, file = miog.C.STANDARD_FILE_PATH .. "naxxramas"},
	[17] = {mapID = 631, file = miog.C.STANDARD_FILE_PATH .. "icecrowncitadel"},
	[18] = {mapID = 1007, file = miog.C.STANDARD_FILE_PATH .. "scholomance"},
	[19] = {mapID = 33, file = miog.C.STANDARD_FILE_PATH .. "shadowfangkeep"},
	[20] = {mapID = 543, file = miog.C.STANDARD_FILE_PATH .. "hellfireramparts"},

	[21] = {mapID = 542, file = miog.C.STANDARD_FILE_PATH .. "bloodfurnace"},
	[22] = {mapID = 540, file = miog.C.STANDARD_FILE_PATH .. "shatteredhalls"},
	[23] = {mapID = 547, file = miog.C.STANDARD_FILE_PATH .. "slavepens"},
	[24] = {mapID = 546, file = miog.C.STANDARD_FILE_PATH .. "underbog"},
	[25] = {mapID = 545, file = miog.C.STANDARD_FILE_PATH .. "steamvault"},
	[26] = {mapID = 557, file = miog.C.STANDARD_FILE_PATH .. "manatombs"},
	[27] = {mapID = 558, file = miog.C.STANDARD_FILE_PATH .. "auchenaicrypts"},
	[28] = {mapID = 556, file = miog.C.STANDARD_FILE_PATH .. "sethekkhalls"},
	[29] = {mapID = 555, file = miog.C.STANDARD_FILE_PATH .. "shadowlabyrinth"},

	[30] = {mapID = 1001, file = miog.C.STANDARD_FILE_PATH .. "scarlethalls"},
	[31] = {mapID = 1004, file = miog.C.STANDARD_FILE_PATH .. "scarletmonastery"},
	[32] = {mapID = 560, file = miog.C.STANDARD_FILE_PATH .. "oldhillsbrad"},
	[33] = {mapID = 269, file = miog.C.STANDARD_FILE_PATH .. "blackmorass"},
	[34] = {mapID = 554, file = miog.C.STANDARD_FILE_PATH .. "mechanar"},
	[35] = {mapID = 553, file = miog.C.STANDARD_FILE_PATH .. "botanica"},
	[36] = {mapID = 552, file = miog.C.STANDARD_FILE_PATH .. "arcatraz"},
	[37] = {mapID = 585, file = miog.C.STANDARD_FILE_PATH .. "magistersterrace"},
	[38] = {mapID = 574, file = miog.C.STANDARD_FILE_PATH .. "utgrade keep"},
	[39] = {mapID = 575, file = miog.C.STANDARD_FILE_PATH .. "utgarde pinnacle"},

	[40] = {mapID = 601, file = miog.C.STANDARD_FILE_PATH .. "azjolnerub"},
	[41] = {mapID = 578, file = miog.C.STANDARD_FILE_PATH .. "oculus"},
	[42] = {mapID = 602, file = miog.C.STANDARD_FILE_PATH .. "hallsoflightning"},
	[43] = {mapID = 599, file = miog.C.STANDARD_FILE_PATH .. "hallsofstone"},
	[44] = {mapID = 595, file = miog.C.STANDARD_FILE_PATH .. "cullingofstratholme"},
	[45] = {mapID = 600, file = miog.C.STANDARD_FILE_PATH .. "draktharon"},
	[46] = {mapID = 604, file = miog.C.STANDARD_FILE_PATH .. "gundrak"},
	[47] = {mapID = 619, file = miog.C.STANDARD_FILE_PATH .. "ahnkalet"},
	[48] = {mapID = 608, file = miog.C.STANDARD_FILE_PATH .. "violethold"},
	[49] = {mapID = 576, file = miog.C.STANDARD_FILE_PATH .. "nexus"},

	[50] = {mapID = 650, file = miog.C.STANDARD_FILE_PATH .. "trialofthechampion"},
	[51] = {mapID = 632, file = miog.C.STANDARD_FILE_PATH .. "forgeofsouls"},
	[52] = {mapID = 658, file = miog.C.STANDARD_FILE_PATH .. "pitofsaron"},
	[53] = {mapID = 668, file = miog.C.STANDARD_FILE_PATH .. "hallsofreflection"},
	[54] = {mapID = 643, challengeModeID = 456, shortName = "TOTT", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/throneofthetides.png"},
	[55] = {mapID = 645, file = miog.C.STANDARD_FILE_PATH .. "blackrockcaverns"},
	[56] = {mapID = 670, file = miog.C.STANDARD_FILE_PATH .. "grimbatol"},
	[57] = {mapID = 644, file = miog.C.STANDARD_FILE_PATH .. "hallsoforigination"},
	[58] = {mapID = 725, file = miog.C.STANDARD_FILE_PATH .. "stonecore"},
	[59] = {mapID = 657, challengeModeID = 438, shortName = "VP", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/vortexpinnacle.png"},

	[60] = {mapID = 755, file = miog.C.STANDARD_FILE_PATH .. ""},
	[61] = {mapID = 960, challengeModeID = 2, shortName = "TOTJS", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/templeofthejadeserpent.png"},
	[62] = {mapID = 961, file = miog.C.STANDARD_FILE_PATH .. ""},
	[63] = {mapID = 959, file = miog.C.STANDARD_FILE_PATH .. ""},
	[64] = {mapID = 994, file = miog.C.STANDARD_FILE_PATH .. ""},
	[65] = {mapID = 1011, file = miog.C.STANDARD_FILE_PATH .. ""},
	[66] = {mapID = 962, file = miog.C.STANDARD_FILE_PATH .. ""},
	[67] = {mapID = 1279, challengeModeID = 168, shortName = "EB", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/everbloom.png"},
	[68] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "draenoroutdoor"},
	[69] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "outlandoutdoor"},

	[70] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "northrendoutdoor"},
	[71] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "pandariaoutdoor"},
	--[72] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[73] = {mapID = 649, file = miog.C.STANDARD_FILE_PATH .. "trialofthecrusader"},
	[74] = {mapID = 724, file = miog.C.STANDARD_FILE_PATH .. "rubysanctum"},
	[75] = {mapID = 669, file = miog.C.STANDARD_FILE_PATH .. "blackwingdescent"},
	[76] = {mapID = 671, file = miog.C.STANDARD_FILE_PATH .. "bastionoftwilight"},
	[77] = {mapID = 754, file = miog.C.STANDARD_FILE_PATH .. "throneofthefourwinds"},
	[78] = {mapID = 720, file = miog.C.STANDARD_FILE_PATH .. "firelands"},
	[79] = {mapID = 967, file = miog.C.STANDARD_FILE_PATH .. "dragonsoul"},

	[80] = {mapID = 1008, file = miog.C.STANDARD_FILE_PATH .. "mogushanvaults"},
	[81] = {mapID = 1009, file = miog.C.STANDARD_FILE_PATH .. "heartoffear"},
	[82] = {mapID = 996, file = miog.C.STANDARD_FILE_PATH .. "terraceoftheendlessspring"},
	[83] = {mapID = 1098, file = miog.C.STANDARD_FILE_PATH .. "throneofthunder"},
	[84] = {mapID = 870, file = miog.C.STANDARD_FILE_PATH .. "random pandaria dungeon"},
	--[85] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[86] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "theramoresfall"},
	--[87] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	--[88] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	--[89] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},

	[109] = {mapID = 1116, file = miog.C.STANDARD_FILE_PATH .. "random warlords dungeon"},
	[110] = {mapID = 1448, file = miog.C.STANDARD_FILE_PATH .. "hellfirecitadelraid"},

	[111] = {mapID = 1220, file = miog.C.STANDARD_FILE_PATH .. "random legion dungeon"},
	[112] = {mapID = 1456, file = miog.C.STANDARD_FILE_PATH .. "eyeofazshara"},
	[113] = {mapID = 1466, challengeModeID = 198, shortName = "DHT", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/darkheartthicket.png"},
	[114] = {mapID = 1477, file = miog.C.STANDARD_FILE_PATH .. "hallsofvalor"},
	[115] = {mapID = 1458, challengeModeID = 206, shortName = "NL", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/neltharionslair.png"},
	[116] = {mapID = 1544, file = miog.C.STANDARD_FILE_PATH .. "assaultonviolethold"},
	[117] = {mapID = 1493, file = miog.C.STANDARD_FILE_PATH .. "vaultofthewardens"},
	[118] = {mapID = 1501, challengeModeID = 199, shortName = "BRH", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/blackrookhold.png"},
	[119] = {mapID = 1492, file = miog.C.STANDARD_FILE_PATH .. "mawofsouls"},
	[120] = {mapID = 1571, file = miog.C.STANDARD_FILE_PATH .. "courtofstars"},
	[121] = {mapID = 1516, file = miog.C.STANDARD_FILE_PATH .. "arcway"},
	[122] = {mapID = 1520, file = miog.C.STANDARD_FILE_PATH .. "emeraldnightmare"},
	[123] = {mapID = 1530, file = miog.C.STANDARD_FILE_PATH .. "nighthold"},
	[124] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "legionoutdoor"},
	[125] = {mapID = 1651, file = miog.C.STANDARD_FILE_PATH .. "returntokarazhan"},
	[126] = {mapID = 1648, file = miog.C.STANDARD_FILE_PATH .. "trialofvalor"},
	[127] = {mapID = 1651, file = miog.C.STANDARD_FILE_PATH .. "lowerkarazhan"},
	[128] = {mapID = 1651, file = miog.C.STANDARD_FILE_PATH .. "upperkarazhan"},
	[129] = {mapID = 1677, file = miog.C.STANDARD_FILE_PATH .. "cathedralofeternalnight"},

	--[130] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[131] = {mapID = 1676, file = miog.C.STANDARD_FILE_PATH .. "tombofsargeras"},
	[132] = {mapID = 1712, file = miog.C.STANDARD_FILE_PATH .. "antorus"},
	[133] = {mapID = 1753, file = miog.C.STANDARD_FILE_PATH .. "seatofthetriumvirate"},
	[134] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/argus3.png"},

	[135] = {mapID = 1861, file = miog.C.STANDARD_FILE_PATH .. "uldir"},
	[136] = {mapID = 1642, file = miog.C.STANDARD_FILE_PATH .. "random bfa dungeon"},
	[137] = {mapID = 1763, challengeModeID = 244, shortName = "AD", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/ataldazar.png"},
	[138] = {mapID = 1841, challengeModeID = 251, shortName = "UR", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/underrot.png"},
	[139] = {mapID = 1877, file = miog.C.STANDARD_FILE_PATH .. "templeofsethraliss"},
	[140] = {mapID = 1594, file = miog.C.STANDARD_FILE_PATH .. "motherlode"},
	[141] = {mapID = 1762, file = miog.C.STANDARD_FILE_PATH .. "kingsrest"},
	[142] = {mapID = 1754, challengeModeID = 245, shortName = "FH", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/freehold.png"},
	[143] = {mapID = 1864, file = miog.C.STANDARD_FILE_PATH .. "shrineofthestorm"},
	[144] = {mapID = 1771, file = miog.C.STANDARD_FILE_PATH .. "toldagor"},
	[145] = {mapID = 1862, challengeModeID = 248, shortName = "WM", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/waycrestmanor.png"},
	[146] = {mapID = 1822, file = miog.C.STANDARD_FILE_PATH .. "siegeofboralus"},

	[247] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "kultiras outdoor"},
	[248] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "zandalar outdoor"},
	[249] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "random island expedition"},

	--[250] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[251] = {mapID = 2070, file = miog.C.STANDARD_FILE_PATH .. "battleofdazaralor"},
	[252] = {mapID = 2096, file = miog.C.STANDARD_FILE_PATH .. "crucibleofstorms"},
	[253] = {mapID = 2097, file = miog.C.STANDARD_FILE_PATH .. "operationmechagon"},
	[254] = {mapID = 2164, file = miog.C.STANDARD_FILE_PATH .. "eternalpalace"},
	[255] = {mapID = 1804, file = miog.C.STANDARD_FILE_PATH .. "battleforstromgarde"},
	[256] = {mapID = 2097, file = miog.C.STANDARD_FILE_PATH .. "mechagon junkyard"},
	[257] = {mapID = 2097, file = miog.C.STANDARD_FILE_PATH .. "mechagon workshop"},
	[258] = {mapID = 2217, file = miog.C.STANDARD_FILE_PATH .. "nyalotha"},

	[259] = {mapID = 2289, file = miog.C.STANDARD_FILE_PATH .. "plaguefall"},

	[260] = {mapID = 2291, file = miog.C.STANDARD_FILE_PATH .. "theotherside"},
	[261] = {mapID = 2287, file = miog.C.STANDARD_FILE_PATH .. "hallsofatonement"},
	[262] = {mapID = 2290, file = miog.C.STANDARD_FILE_PATH .. "mistsoftirnascithe"},
	[263] = {mapID = 2284, file = miog.C.STANDARD_FILE_PATH .. "sanguinedepths"},
	[264] = {mapID = 2285, file = miog.C.STANDARD_FILE_PATH .. "spiresofascension"},
	[265] = {mapID = 2286, file = miog.C.STANDARD_FILE_PATH .. "necroticwake"},
	[266] = {mapID = 2293, file = miog.C.STANDARD_FILE_PATH .. "theaterofpain"},
	[267] = {mapID = 2296, file = miog.C.STANDARD_FILE_PATH .. "castlenathria"},

	[268] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[269] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},

	[270] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "shadowlands outdoor"},
	[271] = {mapID = 2450, file = miog.C.STANDARD_FILE_PATH .. "sanctumofdomination"},
	[272] = {mapID = 2441, file = miog.C.STANDARD_FILE_PATH .. "tazaveshtheveiledmarket"},
	[273] = {mapID = 2162, file = miog.C.STANDARD_FILE_PATH .. "twistingcorridors"},
	[274] = {mapID = 2162, file = miog.C.STANDARD_FILE_PATH .. "skoldushall"},
	[275] = {mapID = 2162, file = miog.C.STANDARD_FILE_PATH .. "upperreaches"},
	[276] = {mapID = 2162, file = miog.C.STANDARD_FILE_PATH .. "soulforges"},
	[277] = {mapID = 2162, file = miog.C.STANDARD_FILE_PATH .. "mort'regar"},
	[278] = {mapID = 2162, file = miog.C.STANDARD_FILE_PATH .. "fracturechambers"},
	[279] = {mapID = 2162, file = miog.C.STANDARD_FILE_PATH .. "coldheartinterstitia"},
	[280] = {mapID = 2441, file = miog.C.STANDARD_FILE_PATH .. "tazaveshstreets"},
	[281] = {mapID = 2441, file = miog.C.STANDARD_FILE_PATH .. "tazaveshgambit"},
	[282] = {mapID = 2481, file = miog.C.STANDARD_FILE_PATH .. "sepulcherofthefirstones"},
	[283] = {mapID = 2162, file = miog.C.STANDARD_FILE_PATH .. "jailersgauntlet"},

	[284] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dragonislescontinent.png"},
	[285] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[286] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[287] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[288] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},
	[289] = {mapID = 0, file = miog.C.STANDARD_FILE_PATH .. ""},

	[302] = {mapID = 2526, challengeModeID = 402, shortName = "AA", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/algetharacademy.png"},
	[303] = {mapID = 2520, challengeModeID = 405, shortName = "BH", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/brackenhidehollow.png"},
	[304] = {mapID = 2527, challengeModeID = 406, shortName = "HOI", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/hallsofinfusion.png"},
	[305] = {mapID = 2519, challengeModeID = 404, shortName = "NELT", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/neltharus.png"},
	[306] = {mapID = 2521, challengeModeID = 399, shortName = "RLP", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/rubylifepools.png"},
	[307] = {mapID = 2515, challengeModeID = 401, shortName = "AV", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/azurevault.png"},
	[308] = {mapID = 2516, challengeModeID = 400, shortName = "NO", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/nokhudoffensive.png"},
	[309] = {mapID = 2451, challengeModeID = 403, shortName = "ULOT", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/uldamanlegacyoftyr.png"},
	[310] = {mapID = 2522, shortName = "VOTI", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/vaultoftheincarnates.png"},
	[313] = {mapID = 2569, shortName = "ATSC", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/aberrus.png"},
	[315] = {mapID = 2579, file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dawnoftheinfinite.png"},
	[316] = {mapID = 2579, challengeModeID = 463, shortName = "FALL", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dawnoftheinfinite.png"},
	[317] = {mapID = 2579, challengeModeID = 464, shortName = "RISE", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dawnoftheinfinite.png"},
	[318] = {mapID = 2579, file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/dawnoftheinfinite.png"},
	[319] = {mapID = 2549, shortName = "ATDH", file = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/amirdrassil.png"},
}

miog.GROUP_ID_TO_LFG_ID = {}

miog.ACTIVITY_INFO = {

}

miog.SEASONAL_DUNGEONS = {
	[11] = {184, 1274, 1247, 1248, 502, 463, 460, 530},
	[12] = {1160, 1164, 1168, 1172, 1176, 1180, 1184, 1188},
}

for _, v in pairs(miog.SEASONAL_DUNGEONS) do
	table.sort(v, function(k1, k2)
		local info1 = C_LFGList.GetActivityFullName(k1)
		local info2 = C_LFGList.GetActivityFullName(k2)

		return info1 < info2
	end)
end

miog.JOURNAL_CREATURE_INFO = {

}

miog.DUNGEON_ENCOUNTER_INFO = {

}

miog.CHALLENGE_MODE = {

}

for k, v in ipairs(C_ChallengeMode.GetMapTable()) do
	miog.CHALLENGE_MODE[v] = true

end

miog.LFG_DUNGEONS_INFO = {

}

for k, v in pairs(miog.RAW["LFGDungeons"]) do
	miog.LFG_DUNGEONS_INFO[v[1]] = {
		name = v[2],
		description = v[3],
		typeID = v[4],
		subtypeID = v[5],
		expansionLevel = v[10],
		mapID = v[11],
		difficultyID = v[12]
	}
	
end

miog.BATTLEMASTER_INFO = {

}

for k, v in pairs(miog.RAW["BattlemasterList"]) do
	miog.BATTLEMASTER_INFO[v[1]] = {
		name = v[2],
		icon = v[16],
		possibleBGs = {
			[1] = v[18] ~= -1 and v[18] or nil,
			[2] = v[19] ~= -1 and v[19] or nil,
			[3] = v[20] ~= -1 and v[20] or nil,
			[4] = v[21] ~= -1 and v[21] or nil,
			[5] = v[22] ~= -1 and v[22] or nil,
			[6] = v[23] ~= -1 and v[23] or nil,
			[7] = v[24] ~= -1 and v[24] or nil,
			[8] = v[25] ~= -1 and v[25] or nil,
			[9] = v[26] ~= -1 and v[26] or nil,
			[10] = v[27] ~= -1 and v[27] or nil,
			[11] = v[28] ~= -1 and v[28] or nil,
			[12] = v[29] ~= -1 and v[29] or nil,
			[13] = v[30] ~= -1 and v[30] or nil,
			[14] = v[31] ~= -1 and v[31] or nil,
			[15] = v[32] ~= -1 and v[32] or nil,
			[16] = v[33] ~= -1 and v[33] or nil,
		}
	}
end


local function loadRawData()
	local faction = UnitFactionGroup("player")

	for k, v in pairs(miog.RAW["Map"]) do
		if(miog.MAP_INFO[v[1]]) then
			local mapInfo = miog.MAP_INFO[v[1]]
			mapInfo.name = v[3]
			mapInfo.instanceType = v[5]
			mapInfo.expansionLevel = v[6]
			mapInfo.loadingScreenID = v[8]
			mapInfo.bosses = {}
			mapInfo.exactName = v[2]
		
			if(mapInfo.fileName) then
				mapInfo.horizontal = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/" .. mapInfo.fileName .. ".png"
				mapInfo.vertical = miog.C.STANDARD_FILE_PATH .. "/backgrounds/vertical/" .. mapInfo.fileName .. ".png"
			
			end
		else
			miog.MAP_INFO[v[1]] = {
				name = v[3],
				instanceType = v[5],
				expansionLevel = v[6],
				loadingScreenID = v[8],
				bosses = {},
				exactName = v[2],
			}
		end
	end

	for k, v in pairs(miog.RAW["BattlemasterList"]) do
		if(miog.MAP_INFO[v[18]]) then
			--local isNotNumber = type(miog.MAP_INFO[v[18]].exactName) ~= "number"
			--local subbedString = string.gsub(miog.MAP_INFO[v[18]].name, "%s+", "")

			--miog.MAP_INFO[v[18]].horizontal = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/" .. (isNotNumber and miog.MAP_INFO[v[18]].exactName or subbedString) .. ".png"
			--miog.MAP_INFO[v[18]].vertical = miog.C.STANDARD_FILE_PATH .. "/backgrounds/vertical/" .. (isNotNumber and miog.MAP_INFO[v[18]].exactName or subbedString) .. ".png"
			
		end

	end

	for k, v in pairs(miog.RAW["DungeonEncounter"]) do
		miog.DUNGEON_ENCOUNTER_INFO[v[2]] = {name = v[1], mapID = v[3], difficultyID = v[4], orderIndex = v[5], faction = v[10] > -1 and v[10] or nil}
	end

	for k, v in pairs(miog.RAW["JournalEncounterCreature"]) do
		if(v[6] == 0) then
			miog.JOURNAL_CREATURE_INFO[v[3]] = {name = v[1], id = v[2], creatureDisplayInfoID = v[4], icon = v[5]}

			local bossName, description, journalEncounterID, rootSectionID, bossLink, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfo(v[3])
			local dungeonEncounterInfo = miog.DUNGEON_ENCOUNTER_INFO[dungeonEncounterID]

			if(dungeonEncounterInfo) then
				local mapInfo = miog.MAP_INFO[dungeonEncounterInfo.mapID]
				
				if(mapInfo) then
					if(miog.JOURNAL_CREATURE_INFO[journalEncounterID]) then
						if(dungeonEncounterInfo.faction == nil or dungeonEncounterInfo.faction == 1 and faction == "Alliance" or dungeonEncounterInfo.faction == 0 and faction == "Horde") then
							mapInfo.bosses[#mapInfo.bosses+1] = {
								name = dungeonEncounterInfo.name,
								encounterID = v[2],
								journalInstanceID = journalInstanceID,
								instanceID = instanceID,
								orderIndex = dungeonEncounterInfo.orderIndex,
								creatureDisplayInfoID = miog.JOURNAL_CREATURE_INFO[journalEncounterID].creatureDisplayInfoID,
								icon = miog.JOURNAL_CREATURE_INFO[journalEncounterID].icon,
								achievements = {},
			
							}
						end
					else
						--print("MISSING DATA:", v[2], bossName, journalEncounterID)
					
					end
			
					local name, desc, bgImage, button1, loreImage, button2, areaMapID, link, displayDifficulty, mapID = EJ_GetInstanceInfo(journalInstanceID)
		
					mapInfo.background = loreImage
					mapInfo.icon = button2

					table.sort(mapInfo.bosses, function(k1, k2)
						return k1.orderIndex < k2.orderIndex
					end)
				end
			end
		end
	
	end
	
	for k, v in pairs(miog.RAW["GroupFinderActivity"]) do

		miog.ACTIVITY_INFO[k] = {
			fullName = v[1],
			difficultyName = v[2],
			categoryID = v[3],
	
			groupFinderActivityGroupID = v[5],
	
			mapID = v[9],
			difficultyID = v[10],
	
			maxPlayers = v[12],
		}

		if(miog.GROUP_ACTIVITY[v[5]]) then
			miog.GROUP_ACTIVITY[v[5]].activityID = k
			
		end
		
		if(miog.MAP_INFO[v[9]]) then
			miog.ACTIVITY_INFO[k].instanceType = miog.MAP_INFO[v[9]].instanceType
			miog.ACTIVITY_INFO[k].expansionLevel = miog.MAP_INFO[v[9]].expansionLevel
			miog.ACTIVITY_INFO[k].bosses = miog.MAP_INFO[v[9]].bosses
			miog.ACTIVITY_INFO[k].fileName = miog.MAP_INFO[v[9]].fileName
			miog.ACTIVITY_INFO[k].horizontal = miog.MAP_INFO[v[9]].horizontal
			miog.ACTIVITY_INFO[k].vertical = miog.MAP_INFO[v[9]].vertical
			miog.ACTIVITY_INFO[k].background = miog.MAP_INFO[v[9]].background
			miog.ACTIVITY_INFO[k].icon = miog.MAP_INFO[v[9]].icon
			miog.ACTIVITY_INFO[k].shortName = miog.GROUP_ACTIVITY[v[5]] and miog.GROUP_ACTIVITY[v[5]].shortName or miog.MAP_INFO[v[9]].shortName

			if(miog.MAP_INFO[v[9]].achievementCategory) then
				miog.MAP_INFO[v[9]].achievementTable = {}

				local totalAchievements = GetCategoryNumAchievements(miog.MAP_INFO[v[9]].achievementCategory)

				for i = 1, totalAchievements, 1 do
					local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(miog.MAP_INFO[v[9]].achievementCategory, i)

					if(strfind(name, miog.MAP_INFO[v[9]].name)) then
						table.insert(miog.MAP_INFO[v[9]].achievementTable, id)

						for x, y in ipairs(miog.MAP_INFO[v[9]].bosses) do
							if(strfind(name, y.name)) then
								table.insert(y.achievements, id)
	
							end
	
						end
					end
				end
			end
		else
			miog.ACTIVITY_INFO[k].horizontal = miog.ACTIVITY_BACKGROUNDS[v[3]]
		end
	
	end
	
	for k, v in pairs(miog.ACTIVITY_INFO) do
		for x, y in pairs(miog.RAW["GroupFinderActivityGrp"]) do
			if(y[1] == v.groupFinderActivityGroupID) then
				v.groupFinderActivityName = y[2] or C_LFGList.GetActivityGroupInfo(y[1])

				if(miog.GROUP_ACTIVITY[y[1]].challengeModeID) then
					miog.CHALLENGE_MODE[miog.GROUP_ACTIVITY[y[1]].challengeModeID] = k
				end

			end
		end
	end
end

miog.loadRawData = loadRawData

miog.MAP_INFO[2522].achievementCategory = 15469 --VOTI
miog.MAP_INFO[2522].achievementsAwakened = {19564, 19565, 19566}

miog.MAP_INFO[2549].achievementCategory = 15469 --ATDH
miog.MAP_INFO[2549].achievementsAwakened = {19570, 19571, 19572}

miog.MAP_INFO[2569].achievementCategory = 15469 --ATSC
miog.MAP_INFO[2569].achievementsAwakened = {19567, 19568, 19569}

miog.WEIGHTS_TABLE = {
	[1] = 10000,
	[2] = 100,
	[3] = 1,
}

miog.FONTS = {
	libMono = "Interface\\Addons\\MythicIOGrabber\\res\\fonts\\LiberationMono-Regular.ttf",
}

miog.MAX_GROUP_SIZES = {
	["solo"] = 1,
	["party"] = 5,
	["raid"] = 40
}

miog.CLASSFILE_TO_ID = {
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
	["DUMMY"] = 20,
}


miog.roleRemainingKeyLookup = {
	["TANK"] = "TANK_REMAINING",
	["HEALER"] = "HEALER_REMAINING",
	["DAMAGER"] = "DAMAGER_REMAINING",
}

miog.CLASSES = {
	[1] = 	{name = "WARRIOR", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warrior.png", specs = {71, 72, 73}},
	[2] = 	{name = "PALADIN", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/paladin.png", specs = {65, 66, 70}},
	[3] = 	{name = "HUNTER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/hunter.png", specs = {253, 254, 255}},
	[4] = 	{name = "ROGUE", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/rogue.png", specs = {259, 260, 261}},
	[5] = 	{name = "PRIEST", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/priest.png", specs = {256, 257, 258}},
	[6] = 	{name = "DEATHKNIGHT", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/deathKnight.png", specs = {250, 251, 252}},
	[7] = 	{name = "SHAMAN", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/shaman.png", specs = {262, 263, 264}},
	[8] = 	{name = "MAGE", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/mage.png", specs = {62, 63, 64}},
	[9] =	{name = "WARLOCK", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warlock.png", specs = {265, 266, 267}},
	[10] = 	{name = "MONK", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/monk.png", specs = {268, 270, 269}},
	[11] =	{name = "DRUID", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/druid.png", specs = {102, 103, 104, 105}},
	[12] = 	{name = "DEMONHUNTER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/demonHunter.png", specs = {577, 581}},
	[13] = 	{name = "EVOKER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/evoker.png", specs = {1467, 1468, 1473}},
	[20] = 	{name = "DUMMY", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", specs = {}},
	[21] =	{name = "DUMMY", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", specs = {}},
	[22] =	{name = "DUMMY", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", specs = {}},
	[100] =	{name = "EMPTY", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png", specs = {}},
}

miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID = {}

miog.SPECIALIZATIONS = {
	[0] = {name = "Unknown", class = miog.CLASSES[100], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png"},
	[1] = {name = "Missing Tank", class = miog.CLASSES[20], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/tankIcon.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/tankIcon.png"},
	[2] = {name = "Missing Healer", class = miog.CLASSES[21], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/healerIcon.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/healerIcon.png"},
	[3] = {name = "Missing Damager", class = miog.CLASSES[22], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/damagerIcon.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/damagerIcon.png"},
	[20] = {name = "Empty", class = miog.CLASSES[20], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"},

	[62] = {name = "Arcane", class = miog.CLASSES[8], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/arcane.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/arcane_squared.png"},
	[63] = {name = "Fire", class = miog.CLASSES[8], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/fire.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/fire_squared.png"},
	[64] = {name = "Frost", class = miog.CLASSES[8], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/frostMage.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/frostMage_squared.png"},

	[65] = {name = "Holy", class = miog.CLASSES[2], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/holyPala.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/holyPala_squared.png"},
	[66] = {name = "Protection", class = miog.CLASSES[2], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/protPala.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/protPala_squared.png"},
	[70] = {name = "Retribution", class = miog.CLASSES[2], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/retribution.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/retribution_squared.png"},

	[71] = {name = "Arms", class = miog.CLASSES[1], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/arms.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/arms_squared.png"},
	[72] = {name = "Fury", class = miog.CLASSES[1], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/fury.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/fury_squared.png"},
	[73] = {name = "Protection", class = miog.CLASSES[1], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/protWarr.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/protWarr_squared.png"},

	[102] = {name = "Balance", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/balance.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/balance_squared.png"},
	[103] = {name = "Feral", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/feral.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/feral_squared.png"},
	[104] = {name = "Guardian", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/guardian.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/guardian_squared.png"},
	[105] = {name = "Restoration", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/restoDruid.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/restoDruid_squared.png"},

	[250] = {name = "Blood", class = miog.CLASSES[6], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/blood.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/blood_squared.png"},
	[251] = {name = "Frost", class = miog.CLASSES[6], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/frostDK.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/frostDK_squared.png"},
	[252] = {name = "Unholy", class = miog.CLASSES[6], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/unholy.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/unholy_squared.png"},

	[253] = {name = "Beast Mastery", class = miog.CLASSES[3], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/beastmastery.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/beastmastery_squared.png"},
	[254] = {name = "Marksmanship", class = miog.CLASSES[3], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/marksmanship.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/marksmanship_squared.png"},
	[255] = {name = "Survival", class = miog.CLASSES[3], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/survival.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/survival_squared.png"},

	[256] = {name = "Discipline", class = miog.CLASSES[5], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/discipline.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/discipline_squared.png"},
	[257] = {name = "Holy", class = miog.CLASSES[5], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/holyPriest.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/holyPriest_squared.png"},
	[258] = {name = "Shadow", class = miog.CLASSES[5], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/shadow.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/shadow_squared.png"},

	[259] = {name = "Assassination", class = miog.CLASSES[4], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/assassination.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/assassination_squared.png"},
	[260] = {name = "Outlaw", class = miog.CLASSES[4], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/outlaw.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/outlaw_squared.png"},
	[261] = {name = "Subtlety", class = miog.CLASSES[4], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/subtlety.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/subtlety_squared.png"},

	[262] = {name = "Elemental", class = miog.CLASSES[7], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/elemental.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/elemental_squared.png"},
	[263] = {name = "Enhancement", class = miog.CLASSES[7], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/enhancement.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/enhancement_squared.png"},
	[264] = {name = "Restoration", class = miog.CLASSES[7], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/restoShaman.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/restoShaman_squared.png"},

	[265] = {name = "Affliction", class = miog.CLASSES[9], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/affliction.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/affliction_squared.png"},
	[266] = {name = "Demonology", class = miog.CLASSES[9], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/demonology.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/demonology_squared.png"},
	[267] = {name = "Destruction", class = miog.CLASSES[9], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/destruction.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/destruction_squared.png"},

	[268] = {name = "Brewmaster", class = miog.CLASSES[10], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/brewmaster.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/brewmaster_squared.png"},
	[269] = {name = "Windwalker", class = miog.CLASSES[10], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/windwalker.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/windwalker_squared.png"},
	[270] = {name = "Mistweaver", class = miog.CLASSES[10], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/mistweaver.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/mistweaver_squared.png"},

	[577] = {name = "Havoc", class = miog.CLASSES[12], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/havoc.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/havoc_squared.png"},
	[581] = {name = "Vengeance", class = miog.CLASSES[12], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/vengeance.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/vengeance_squared.png"},

	[1467] = {name = "Devastation", class = miog.CLASSES[13], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/devastation.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/devastation_squared.png"},
	[1468] = {name = "Preservation", class = miog.CLASSES[13], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/preservation.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/preservation_squared.png"},
	[1473] = {name = "Augmentation", class = miog.CLASSES[13], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/augmentation.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/augmentation_squared.png"},

	--- INITIALS

	[1444] = {name = "Shaman Initial", class = miog.CLASSES[7], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/shaman.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/shaman.png"},
	[1446] = {name = "Warrior Initial", class = miog.CLASSES[1], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warrior.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warrior.png"},
	[1447] = {name = "Druid Initial", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/druid.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/druid.png"},
	[1448] = {name = "Hunter Initial", class = miog.CLASSES[3], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/hunter.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/hunter.png"},
	[1449] = {name = "Mage Initial", class = miog.CLASSES[8], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/mage.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/mage.png"},
	[1450] = {name = "Monk Initial", class = miog.CLASSES[10], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/monk.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/monk.png"},
	[1451] = {name = "Paladin Initial", class = miog.CLASSES[2], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/paladin.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/paladin.png"},
	[1452] = {name = "Priest Initial", class = miog.CLASSES[5], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/priest.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/priest.png"},
	[1453] = {name = "Rogue Initial", class = miog.CLASSES[4], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/rogue.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/rogue.png"},
	[1454] = {name = "Warlock Initial", class = miog.CLASSES[9], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warlock.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warlock.png"},
	[1455] = {name = "Death Knight Initial", class = miog.CLASSES[6], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/deathKnight.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/deathKnight.png"},
	[1456] = {name = "Demon Hunter Initial", class = miog.CLASSES[12], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/demonHunter.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/demonHunter.png"},
	[1465] = {name = "Evoker Initial", class = miog.CLASSES[13], icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/evoker.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/evoker.png"},
}

miog.RACES = {
	[1] = "raceicon-human-male",
	[2] = "raceicon-orc-male",
	[3] = "raceicon-dwarf-male",
	[4] = "raceicon-nightelf-male",
	[5] = "raceicon-undead-male",
	[6] = "raceicon-tauren-male",
	[7] = "raceicon-gnome-male",
	[8] = "raceicon-troll-male",
	[9] = "raceicon-goblin-male",
	[10] = "raceicon-bloodelf-male",
	[11] = "raceicon-draenei-male",
	[22] = "raceicon-worgen-male",
	[24] = "raceicon-pandaren-male",
	[25] = "raceicon-pandaren-male",
	[26] = "raceicon-pandaren-male",
	[27] = "raceicon-nightborne-male",
	[28] = "raceicon-highmountain-male",
	[29] = "raceicon-voidelf-male",
	[30] = "raceicon-lightforged-male",
	[31] = "raceicon-zandalari-male",
	[32] = "raceicon-kultiran-male",
	[33] = "raceicon-darkirondwarf-male",
	[34] = "raceicon-darkirondwarf-male",
	[35] = "raceicon-vulpera-male",
	[36] = "raceicon-magharorc-male",
	[37] = "raceicon-mechagnome-male",
	[52] = "raceicon-dracthyr-male",
	[70] = "raceicon-dracthyr-male",

}

miog.CLASS_SPEC_FOR_AFFIXES = {
	[6] = {
		classIDs = {3, 4, 11, 13},
		specs = {},
	},
	[135] = {
		classIDs = {2, 5, 7, 8, 10, 11, 13},
		specs = {},
	},

}

for k, v in pairs(miog.CLASS_SPEC_FOR_AFFIXES) do
	v.classes = {}

	for x, y in pairs(v.classIDs) do
		v.classes[miog.CLASSES[y].name] = true
	end
end

miog.INSTANCE_SHORT_NAME = {


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

miog.COLOR_BREAKPOINTS = {
	[0] = {breakpoint = 0, hex = "ff9d9d9d", r = 0.62, g = 0.62, b = 0.62},
	[1] = {breakpoint = 600, hex = "ffffffff", r = 1, g = 1, b = 1},
	[2] = {breakpoint = 1200, hex = "ff1eff00", r = 0.12, g = 1, b = 0},
	[3] = {breakpoint = 1800, hex = "ff0070dd", r = 0, g = 0.44, b = 0.87},
	[4] = {breakpoint = 2400, hex = "ffa335ee", r = 0.64, g = 0.21, b = 0.93},
	[5] = {breakpoint = 3000, hex = "ffff8000", r = 1, g = 0.5, b = 0},
	[6] = {breakpoint = 3600, hex = "ffe6cc80", r = 0.9, g = 0.8, b = 0.5},
}

miog.PLAYSTYLE_STRINGS = {
	mZero1 = "Standard",
	mZero2 = "Learning/Progression",
	mZero3 = "Quick Clear",

	mPlus1 = "Standard",
	mPlus2 = "Completion",
	mPlus3 = "Beat Timer",

	raid1 = "Standard",
	raid2 = "Learning/Progression",
	raid3 = "Quick Clear",
	
	pvp1 = "Earn Conquest",
	pvp2 = "Learning",
	pvp3 = "Increase Rating"
}

miog.CUSTOM_CATEGORY_ORDER = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 7,
	[6] = 9,
	[7] = 8,
	[8] = 6,
}

miog.ACTIVITY_BACKGROUNDS = {
	[1] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/oldSchoolCool3_1024.png", --QUESTING
	[2] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/oldSchoolCool1_1024.png", --DUNGEONS
	[3] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/2ndGOAT_1024.png", --RAID
	[4] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/arena1_1024.png", --ARENA
	[5] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/wetSandLand_1024.png", --SCENARIO
	[6] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/oldSchoolCool2_1024.png", --CUSTOM GROUPS
	[7] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/arena3_1024.png", --SKIRMISH
	[8] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/arena2_1024.png", --BATTLEGROUNDS
	[9] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/swords_1024.png", --RBG'S
	[10] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/letsNotTalkAboutIt_1024.png",
	[111] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/thisIsTheDayYouWillAlwaysRememberAsTheDayYouAlmostCaughtCaptainJackSparrow_1024.png", --ISLAND EXPEDITIONS
	[113] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/thisDidntHappen_1024.png", --TORGHAST
}

miog.EXPANSION_INFO = {
	[1] = {"Classic", "vanilla-bg-1", GetExpansionDisplayInfo(0).logo},
	[2] = {"The Burning Crusade", "tbc-bg-1", GetExpansionDisplayInfo(1).logo},
	[3] = {"Wrath of the Lich King", "wotlk-bg-1", GetExpansionDisplayInfo(2).logo},
	[4] = {"Cataclysm", "cata-bg-1", GetExpansionDisplayInfo(3).logo},
	[5] = {"Mists of Pandaria", "mop-bg-1", GetExpansionDisplayInfo(4).logo},
	[6] = {"Warlords of Draenor", "wod-bg-1", GetExpansionDisplayInfo(5).logo},
	[7] = {"Legion", "legion-bg-1", GetExpansionDisplayInfo(6).logo},
	[8] = {"Battle for Azeroth", "bfa-bg-1", GetExpansionDisplayInfo(7).logo},
	[9] = {"Shadowlands", "sl-bg-1", GetExpansionDisplayInfo(8).logo},
	[10] = {"Dragonflight", "df-bg-1", GetExpansionDisplayInfo(9).logo},
}

miog.REALM_LOCAL_NAMES = { --Raider IO addon, db_realms
	["Abbendis"] = "abbendis",
	["AbyssalDepths"] = "abyssal-depths",
	["AbyssalMaw"] = "abyssal-maw",
	["Aegwynn"] = "aegwynn",
	["AeriePeak"] = "aerie-peak",
	["Aessina"] = "aessina",
	["Agamaggan"] = "agamaggan",
	["Aggra(Português)"] = "aggra-português",
	["Aggramar"] = "aggramar",
	["Ahn'Qiraj"] = "ahnqiraj",
	["Ahune"] = "ahune",
	["Akama"] = "akama",
	["Akil'zon"] = "akilzon",
	["Al'Akir"] = "alakir",
	["Al'ar"] = "alar",
	["Alexstrasza"] = "alexstrasza",
	["Algalon"] = "algalon",
	["Alleria"] = "alleria",
	["Alonsus"] = "alonsus",
	["AltarofStorms"] = "altar-of-storms",
	["AlteracMountains"] = "alterac-mountains",
	["Aman'thul"] = "amanthul",
	["Aman'Thul"] = "amanthul",
	["Amani"] = "amani",
	["Ambossar"] = "ambossar",
	["Anachronos"] = "anachronos",
	["Anasterian"] = "anasterian",
	["Andorhal"] = "andorhal",
	["Anetheron"] = "anetheron",
	["Angerboda"] = "angerboda",
	["Angrathar"] = "angrathar",
	["Antonidas"] = "antonidas",
	["Anub'arak"] = "anubarak",
	["Anvilmar"] = "anvilmar",
	["Anzu"] = "anzu",
	["Arakarahm"] = "arakarahm",
	["Arathi"] = "arathi",
	["Arathor"] = "arathor",
	["Archaedas"] = "archaedas",
	["Archimonde"] = "archimonde",
	["Area52"] = "area-52",
	["ArgentDawn"] = "argent-dawn",
	["Argus"] = "argus",
	["Arthas"] = "arthas",
	["Arygos"] = "arygos",
	["Ashbringer"] = "ashbringer",
	["Ashenvale"] = "ashenvale",
	["Astalor"] = "astalor",
	["Astranaar"] = "astranaar",
	["Aszune"] = "aszune",
	["Auchindoun"] = "auchindoun",
	["AUMythicDungeons"] = "au-mythic-dungeons",
	["Aviana"] = "aviana",
	["Azgalor"] = "azgalor",
	["AzjolNerub"] = "azjolnerub",
	["Azralon"] = "azralon",
	["Azshara"] = "azshara",
	["Azuregos"] = "azuregos",
	["Azuremyst"] = "azuremyst",
	["Baelgun"] = "baelgun",
	["Balnazzar"] = "balnazzar",
	["Barrens"] = "barrens",
	["Barthilas"] = "barthilas",
	["Benedictus"] = "benedictus",
	["BlackDragonflight"] = "black-dragonflight",
	["Blackhand"] = "blackhand",
	["Blackmoore"] = "blackmoore",
	["Blackrock"] = "blackrock",
	["Blackscar"] = "blackscar",
	["BlackwaterRaiders"] = "blackwater-raiders",
	["BlackwingLair"] = "blackwing-lair",
	["Blade'sEdge"] = "blades-edge",
	["Bladefist"] = "bladefist",
	["Bladespire"] = "bladespire",
	["Blanchard"] = "blanchard",
	["BleedingHollow"] = "bleeding-hollow",
	["Bloodfeather"] = "bloodfeather",
	["BloodFurnace"] = "blood-furnace",
	["Bloodhoof"] = "bloodhoof",
	["Bloodmaul"] = "bloodmaul",
	["Bloodscalp"] = "bloodscalp",
	["BlueDragonflight"] = "blue-dragonflight",
	["Blutkessel"] = "blutkessel",
	["Bonechewer"] = "bonechewer",
	["BoneWastes"] = "bone-wastes",
	["BootyBay"] = "booty-bay",
	["BoreanTundra"] = "borean-tundra",
	["Boulderfist"] = "boulderfist",
	["Brann"] = "brann",
	["Bronzebeard"] = "bronzebeard",
	["BronzeDragonflight"] = "bronze-dragonflight",
	["Broxigar"] = "broxigar",
	["Brutallus"] = "brutallus",
	["BurningBlade"] = "burning-blade",
	["BurningLegion"] = "burning-legion",
	["BurningSteppes"] = "burning-steppes",
	["C'Thun"] = "cthun",
	["Caelestrasz"] = "caelestrasz",
	["Cairne"] = "cairne",
	["Cassandra"] = "cassandra",
	["CavernsofTime"] = "caverns-of-time",
	["CenarionCircle"] = "cenarion-circle",
	["Cenarius"] = "cenarius",
	["ChamberofAspects"] = "chamber-of-aspects",
	["Chantséternels"] = "chants-éternels",
	["ChillwindPoint"] = "chillwind-point",
	["Cho'gall"] = "chogall",
	["Chromaggus"] = "chromaggus",
	["CleftofShadow"] = "cleft-of-shadow",
	["CNMythicDungeons"] = "cn-mythic-dungeons",
	["CN史诗地下城"] = "cn-mythic-dungeons",
	["Coilfang"] = "coilfang",
	["ColinasPardas"] = "colinas-pardas",
	["ConfrérieduThorium"] = "confrérie-du-thorium",
	["ConseildesOmbres"] = "conseil-des-ombres",
	["Crushridge"] = "crushridge",
	["CrystalpineStinger"] = "crystalpine-stinger",
	["CultedelaRivenoire"] = "culte-de-la-rive-noire",
	["Daggerspine"] = "daggerspine",
	["Dalaran"] = "dalaran",
	["Dalvengyr"] = "dalvengyr",
	["DanathTrollbane"] = "danath-trollbane",
	["Dar'Khan"] = "darkhan",
	["DarkIron"] = "dark-iron",
	["DarkmoonFaire"] = "darkmoon-faire",
	["DarkPhantom"] = "dark-phantom",
	["DarkPortal"] = "dark-portal",
	["Darksorrow"] = "darksorrow",
	["Darkspear"] = "darkspear",
	["Darrowmere"] = "darrowmere",
	["DasKonsortium"] = "das-konsortium",
	["DasSyndikat"] = "das-syndikat",
	["Dath'Remar"] = "dathremar",
	["Dawnbringer"] = "dawnbringer",
	["Death'sDoor"] = "deaths-door",
	["Deathforge"] = "deathforge",
	["Deathguard"] = "deathguard",
	["Deathweaver"] = "deathweaver",
	["Deathwhisper"] = "deathwhisper",
	["Deathwing"] = "deathwing",
	["Deepfury"] = "deepfury",
	["Deepholm"] = "deepholm",
	["Deephome"] = "deephome",
	["DefiasBrotherhood"] = "defias-brotherhood",
	["DemonFallCanyon"] = "demon-fall-canyon",
	["Demonslayer"] = "demonslayer",
	["DemonSoul"] = "demon-soul",
	["Dentarg"] = "dentarg",
	["DerAbyssischeRat"] = "der-abyssische-rat",
	["DerMithrilorden"] = "der-mithrilorden",
	["DerRatvonDalaran"] = "der-rat-von-dalaran",
	["Destromath"] = "destromath",
	["Dethecus"] = "dethecus",
	["Detheroc"] = "detheroc",
	["DieAldor"] = "die-aldor",
	["DieArguswacht"] = "die-arguswacht",
	["DieewigeWacht"] = "die-ewige-wacht",
	["DieNachtwache"] = "die-nachtwache",
	["DieSilberneHand"] = "die-silberne-hand",
	["DieTodeskrallen"] = "die-todeskrallen",
	["Dimensius"] = "dimensius",
	["Direwing"] = "direwing",
	["Doom'sVigil"] = "dooms-vigil",
	["Doomhammer"] = "doomhammer",
	["Doomwalker"] = "doomwalker",
	["Dor'Danil"] = "dordanil",
	["Draenor"] = "draenor",
	["Dragonblight"] = "dragonblight",
	["Dragonmaw"] = "dragonmaw",
	["Drak'Tharon"] = "draktharon",
	["Drak'thul"] = "drakthul",
	["Draka"] = "draka",
	["Drakkari"] = "drakkari",
	["Drakkisath"] = "drakkisath",
	["Dreadmaul"] = "dreadmaul",
	["DreadmistPeak"] = "dreadmist-peak",
	["DreamBough"] = "dream-bough",
	["Dreamwalker"] = "dreamwalker",
	["Drek'Thar"] = "drekthar",
	["Drenden"] = "drenden",
	["Dunemaul"] = "dunemaul",
	["DunModr"] = "dun-modr",
	["DunMorogh"] = "dun-morogh",
	["Durotan"] = "durotan",
	["Duskwood"] = "duskwood",
	["Dustbelcher"] = "dustbelcher",
	["DustwindGulch"] = "dustwind-gulch",
	["EarthenRing"] = "earthen-ring",
	["EbonWatch"] = "ebon-watch",
	["EchoIsles"] = "echo-isles",
	["EchoRidge"] = "echo-ridge",
	["Echsenkessel"] = "echsenkessel",
	["Eitrigg"] = "eitrigg",
	["Eldre'Thalas"] = "eldrethalas",
	["Elune"] = "elune",
	["EmeraldDream"] = "emerald-dream",
	["Emeriss"] = "emeriss",
	["Entropius"] = "entropius",
	["Eonar"] = "eonar",
	["Eranikus"] = "eranikus",
	["Eredar"] = "eredar",
	["EUMythicDungeons"] = "eu-mythic-dungeons",
	["Eversong"] = "eversong",
	["Executus"] = "executus",
	["Exodar"] = "exodar",
	["Explorer'sLeague"] = "explorers-league",
	["Falathim"] = "falathim",
	["Farstriders"] = "farstriders",
	["Feathermoon"] = "feathermoon",
	["Felmyst"] = "felmyst",
	["FelRock"] = "fel-rock",
	["Fenris"] = "fenris",
	["Feralas"] = "feralas",
	["FestungderStürme"] = "festung-der-stürme",
	["Firegut"] = "firegut",
	["FirePlumeRidge"] = "fire-plume-ridge",
	["Firetree"] = "firetree",
	["Fizzcrank"] = "fizzcrank",
	["FlameCrest"] = "flame-crest",
	["ForceofElemental"] = "force-of-elemental",
	["Fordragon"] = "fordragon",
	["Forscherliga"] = "forscherliga",
	["FrayIsland"] = "fray-island",
	["Freewind"] = "freewind",
	["Frostmane"] = "frostmane",
	["Frostmourne"] = "frostmourne",
	["Frostwhisper"] = "frostwhisper",
	["Frostwolf"] = "frostwolf",
	["Gadgetzan"] = "gadgetzan",
	["Galakrond"] = "galakrond",
	["Gallywix"] = "gallywix",
	["Garithos"] = "garithos",
	["Garona"] = "garona",
	["Garr"] = "garr",
	["Garrosh"] = "garrosh",
	["Gazlowe"] = "gazlowe",
	["Geddon"] = "geddon",
	["Genjuros"] = "genjuros",
	["Ghostlands"] = "ghostlands",
	["Gilneas"] = "gilneas",
	["Gnomeregan"] = "gnomeregan",
	["Goldrinn"] = "goldrinn",
	["GoldRoad"] = "gold-road",
	["Gordunni"] = "gordunni",
	["Gorefiend"] = "gorefiend",
	["Gorehowl"] = "gorehowl",
	["Gorgonnash"] = "gorgonnash",
	["Gothik"] = "gothik",
	["Greymane"] = "greymane",
	["GrimBatol"] = "grim-batol",
	["Grimtotem"] = "grimtotem",
	["GrizzlyHills"] = "grizzly-hills",
	["Grom"] = "grom",
	["Gruul"] = "gruul",
	["GuardianBlade"] = "guardian-blade",
	["Gul'dan"] = "guldan",
	["Gundrak"] = "gundrak",
	["Gurubashi"] = "gurubashi",
	["Gyth"] = "gyth",
	["Hakkar"] = "hakkar",
	["Halaa"] = "halaa",
	["Haomarush"] = "haomarush",
	["Hearthglen"] = "hearthglen",
	["Hectae"] = "hectae",
	["Hellfire"] = "hellfire",
	["Hellscream"] = "hellscream",
	["Hogger"] = "hogger",
	["HolyChanter"] = "holy-chanter",
	["HowlingFjord"] = "howling-fjord",
	["Hydraxis"] = "hydraxis",
	["Hyjal"] = "hyjal",
	["Icecrown"] = "icecrown",
	["Illidan"] = "illidan",
	["Immol'thar"] = "immolthar",
	["Isillien"] = "isillien",
	["Itharius"] = "itharius",
	["Jaedenar"] = "jaedenar",
	["Jammal'an"] = "jammalan",
	["Jin'do"] = "jindo",
	["Jubei'Thos"] = "jubeithos",
	["Kael'thas"] = "kaelthas",
	["Kalecgos"] = "kalecgos",
	["KaleidoscopeStar"] = "kaleidoscope-star",
	["Karazhan"] = "karazhan",
	["Kargath"] = "kargath",
	["Kazzak"] = "kazzak",
	["Kel'Thuzad"] = "kelthuzad",
	["Khadgar"] = "khadgar",
	["Khardros"] = "khardros",
	["Khaz'goroth"] = "khazgoroth",
	["KhazModan"] = "khaz-modan",
	["Kil'jaeden"] = "kiljaeden",
	["Kilrogg"] = "kilrogg",
	["KirinTor"] = "kirin-tor",
	["Kor'gall"] = "korgall",
	["Koranos"] = "koranos",
	["Korgath"] = "korgath",
	["Korialstrasz"] = "korialstrasz",
	["Krag'jin"] = "kragjin",
	["Krasus"] = "krasus",
	["KRMythicDungeons"] = "kr-mythic-dungeons",
	["KrolBlade"] = "krol-blade",
	["OldBlanchy"] = "old-blanchy",
	["KultderVerdammten"] = "kult-der-verdammten",
	["KulTiras"] = "kul-tiras",
	["Kurdran"] = "kurdran",
	["LaCroisadeécarlate"] = "la-croisade-écarlate",
	["Lana'thel"] = "lanathel",
	["LaughingSkull"] = "laughing-skull",
	["LegionHold"] = "legion-hold",
	["LesClairvoyants"] = "les-clairvoyants",
	["LesSentinelles"] = "les-sentinelles",
	["Lethon"] = "lethon",
	["Liadrin"] = "liadrin",
	["LichKing"] = "lich-king",
	["Light'sHope"] = "lights-hope",
	["Lightbringer"] = "lightbringer",
	["Lightning'sBlade"] = "lightnings-blade",
	["Lightninghoof"] = "lightninghoof",
	["LiLi"] = "li-li",
	["Llane"] = "llane",
	["Loken"] = "loken",
	["Lordaeron"] = "lordaeron",
	["LordKazzak"] = "lord-kazzak",
	["LosErrantes"] = "los-errantes",
	["Lothar"] = "lothar",
	["LushwaterOasis"] = "lushwater-oasis",
	["Lycanthoth"] = "lycanthoth",
	["Madmortem"] = "madmortem",
	["Madoran"] = "madoran",
	["Maelstrom"] = "maelstrom",
	["Magmadar"] = "magmadar",
	["Magtheridon"] = "magtheridon",
	["Maiev"] = "maiev",
	["MaievShadowsong"] = "maiev-shadowsong",
	["Maim"] = "maim",
	["Mal'Ganis"] = "malganis",
	["Malchezaar"] = "malchezaar",
	["Malfurion"] = "malfurion",
	["Malorne"] = "malorne",
	["Malygos"] = "malygos",
	["Mannoroth"] = "mannoroth",
	["MarécagedeZangar"] = "marécage-de-zangar",
	["Marrowgar"] = "marrowgar",
	["Maulgar"] = "maulgar",
	["Mazrigos"] = "mazrigos",
	["Medivh"] = "medivh",
	["Menethil"] = "menethil",
	["MidnightScythe"] = "midnight-scythe",
	["Minahonda"] = "minahonda",
	["Misha"] = "misha",
	["Mogor"] = "mogor",
	["Mograine"] = "mograine",
	["Mok'Nathal"] = "moknathal",
	["MoltenCore"] = "molten-core",
	["Moonglade"] = "moonglade",
	["MoonGuard"] = "moon-guard",
	["Moonrunner"] = "moonrunner",
	["Mord'rethar"] = "mordrethar",
	["Mossflayer"] = "mossflayer",
	["Mug'thol"] = "mugthol",
	["Muradin"] = "muradin",
	["Murmur"] = "murmur",
	["Nagrand"] = "nagrand",
	["Nathrezim"] = "nathrezim",
	["Naxxramas"] = "naxxramas",
	["Nazgrel"] = "nazgrel",
	["Nazjatar"] = "nazjatar",
	["Nefarian"] = "nefarian",
	["Nekros"] = "nekros",
	["Neltharion"] = "neltharion",
	["Nemesis"] = "nemesis",
	["Neptulon"] = "neptulon",
	["Ner'zhul"] = "nerzhul",
	["Nera'thor"] = "nerathor",
	["Nesingwary"] = "nesingwary",
	["Nethersturm"] = "nethersturm",
	["Nighthaven"] = "nighthaven",
	["Nightsong"] = "nightsong",
	["Nobundo"] = "nobundo",
	["Nordrassil"] = "nordrassil",
	["Norgannon"] = "norgannon",
	["Northrend"] = "northrend",
	["Nozdormu"] = "nozdormu",
	["Onyxia"] = "onyxia",
	["OrderoftheCloudSerpent"] = "order-of-the-cloud-serpent",
	["Ossirian"] = "ossirian",
	["Outland"] = "outland",
	["Ozumat"] = "ozumat",
	["Pandaren"] = "pandaren",
	["PeakofSerenity"] = "peak-of-serenity",
	["Perenolde"] = "perenolde",
	["PoisontippedBoneSpear"] = "poisontipped-bone-spear",
	["Pozzodell'Eternità"] = "pozzo-delleternità",
	["Prestor"] = "prestor",
	["Proudmoore"] = "proudmoore",
	["Que'Danas"] = "quedanas",
	["Quel'dorei"] = "queldorei",
	["Quel'Thalas"] = "quelthalas",
	["Ragnaros"] = "ragnaros",
	["Rajaxx"] = "rajaxx",
	["Rangers"] = "rangers",
	["Rashgarroth"] = "rashgarroth",
	["Ravencrest"] = "ravencrest",
	["Ravenholdt"] = "ravenholdt",
	["Razuvious"] = "razuvious",
	["RedCloudMesa"] = "red-cloud-mesa",
	["RedDragonflight"] = "red-dragonflight",
	["Rend"] = "rend",
	["Rexxar"] = "rexxar",
	["Rhonin"] = "rhonin",
	["RingofTrials"] = "ring-of-trials",
	["Rivendare"] = "rivendare",
	["RiverPride"] = "river-pride",
	["Rommath"] = "rommath",
	["Runetotem"] = "runetotem",
	["Sacrolash"] = "sacrolash",
	["Sandfury"] = "sandfury",
	["Sanguino"] = "sanguino",
	["Sapphiron"] = "sapphiron",
	["Sargeras"] = "sargeras",
	["Sartharion"] = "sartharion",
	["Saurfang"] = "saurfang",
	["ScarletCrusade"] = "scarlet-crusade",
	["ScarshieldLegion"] = "scarshield-legion",
	["Scholomance"] = "scholomance",
	["Scilla"] = "scilla",
	["Searinox"] = "searinox",
	["Sen'jin"] = "senjin",
	["Sentinels"] = "sentinels",
	["Sethekk"] = "sethekk",
	["ShadowCouncil"] = "shadow-council",
	["ShadowfangKeep"] = "shadowfang-keep",
	["ShadowLabyrinth"] = "shadow-labyrinth",
	["Shadowmoon"] = "shadowmoon",
	["Shadowmourne"] = "shadowmourne",
	["Shadowsong"] = "shadowsong",
	["Shandris"] = "shandris",
	["ShatteredHalls"] = "shattered-halls",
	["ShatteredHand"] = "shattered-hand",
	["Shattrath"] = "shattrath",
	["Shen'dralar"] = "shendralar",
	["ShrineoftheDormantFlame"] = "shrine-of-the-dormant-flame",
	["Shu'halo"] = "shuhalo",
	["SilverHand"] = "silver-hand",
	["Silvermoon"] = "silvermoon",
	["SilverpineForest"] = "silverpine-forest",
	["SilverwingHold"] = "silverwing-hold",
	["Sindragosa"] = "sindragosa",
	["Sinstralis"] = "sinstralis",
	["SistersofElune"] = "sisters-of-elune",
	["Skettis"] = "skettis",
	["Skullcrusher"] = "skullcrusher",
	["Skywall"] = "skywall",
	["Smolderthorn"] = "smolderthorn",
	["Soulflayer"] = "soulflayer",
	["Spinebreaker"] = "spinebreaker",
	["Spirestone"] = "spirestone",
	["Sporeggar"] = "sporeggar",
	["Staghelm"] = "staghelm",
	["SteamwheedleCartel"] = "steamwheedle-cartel",
	["Stonemaul"] = "stonemaul",
	["StonetalonPeak"] = "stonetalon-peak",
	["StormEye"] = "storm-eye",
	["StormPeaks"] = "storm-peaks",
	["Stormrage"] = "stormrage",
	["Stormreaver"] = "stormreaver",
	["Stormscale"] = "stormscale",
	["StrandoftheAncients"] = "strand-of-the-ancients",
	["Stranglethorn"] = "stranglethorn",
	["Stratholme"] = "stratholme",
	["StromgardeKeep"] = "stromgarde-keep",
	["SundownMarsh"] = "sundown-marsh",
	["Sunstrider"] = "sunstrider",
	["Sunwell"] = "sunwell",
	["Suramar"] = "suramar",
	["Sutarn"] = "sutarn",
	["Swiftwind"] = "swiftwind",
	["Sylvanas"] = "sylvanas",
	["Taerar"] = "taerar",
	["Talnivarr"] = "talnivarr",
	["Tanaris"] = "tanaris",
	["TarrenMill"] = "tarren-mill",
	["Teldrassil"] = "teldrassil",
	["Templenoir"] = "temple-noir",
	["TempleofElune"] = "temple-of-elune",
	["Terenas"] = "terenas",
	["Terokkar"] = "terokkar",
	["Terrordar"] = "terrordar",
	["Thaurissan"] = "thaurissan",
	["TheArcatraz"] = "the-arcatraz",
	["TheBotanica"] = "the-botanica",
	["TheForgottenCoast"] = "the-forgotten-coast",
	["TheGoldenPlains"] = "the-golden-plains",
	["TheGreatSea"] = "the-great-sea",
	["TheMaelstrom"] = "the-maelstrom",
	["TheMaster'sGlaive"] = "the-masters-glaive",
	["TheMechanar"] = "the-mechanar",
	["Theradras"] = "theradras",
	["Theramore"] = "theramore",
	["Therazane"] = "therazane",
	["Thermaplugg"] = "thermaplugg",
	["TheScryers"] = "the-scryers",
	["TheSha'tar"] = "the-shatar",
	["TheSteamvault"] = "the-steamvault",
	["TheUnderbog"] = "the-underbog",
	["TheVentureCo"] = "the-venture-co",
	["Thoradin"] = "thoradin",
	["ThoriumBrotherhood"] = "thorium-brotherhood",
	["ThousandNeedles"] = "thousand-needles",
	["Thrall"] = "thrall",
	["Throk'Feroth"] = "throkferoth",
	["Thunderaan"] = "thunderaan",
	["ThunderAxeFortress"] = "thunder-axe-fortress",
	["ThunderBluff"] = "thunder-bluff",
	["Thunderhorn"] = "thunderhorn",
	["Thunderlord"] = "thunderlord",
	["Tichondrius"] = "tichondrius",
	["Tirion"] = "tirion",
	["TirisfalGlades"] = "tirisfal-glades",
	["Todeswache"] = "todeswache",
	["TolBarad"] = "tol-barad",
	["Tortheldrin"] = "tortheldrin",
	["Trollbane"] = "trollbane",
	["Turalyon"] = "turalyon",
	["Twilight'sHammer"] = "twilights-hammer",
	["TwinPeaks"] = "twin-peaks",
	["TwistingNether"] = "twisting-nether",
	["TWMythicDungeons"] = "tw-mythic-dungeons",
	["Tyr'sHand"] = "tyrs-hand",
	["Tyrande"] = "tyrande",
	["Tyrhold"] = "tyrhold",
	["Uldaman"] = "uldaman",
	["Ulduar"] = "ulduar",
	["Uldum"] = "uldum",
	["Un'Goro"] = "ungoro",
	["Undermine"] = "undermine",
	["Ursin"] = "ursin",
	["USMythicDungeons"] = "us-mythic-dungeons",
	["Uther"] = "uther",
	["Vaelastrasz"] = "vaelastrasz",
	["Valanar"] = "valanar",
	["Valdrakken"] = "valdrakken",
	["ValleyofHeroesAU"] = "valley-of-heroes-au",
	["ValleyofHeroesCN"] = "valley-of-heroes-cn",
	["ValleyofHeroesEU"] = "valley-of-heroes-eu",
	["ValleyofHeroesKR"] = "valley-of-heroes-kr",
	["ValleyofHeroesTW"] = "valley-of-heroes-tw",
	["ValleyofHeroesUS"] = "valley-of-heroes-us",
	["ValleyofKings"] = "valley-of-kings",
	["VanCleef"] = "vancleef",
	["Varian"] = "varian",
	["Varimathras"] = "varimathras",
	["Vashj"] = "vashj",
	["Vek'lor"] = "veklor",
	["Vek'nilash"] = "veknilash",
	["Velen"] = "velen",
	["Vol'jin"] = "voljin",
	["Warsong"] = "warsong",
	["WellofEternity"] = "well-of-eternity",
	["WhisperingShore"] = "whispering-shore",
	["Whisperwind"] = "whisperwind",
	["Wildhammer"] = "wildhammer",
	["Windrunner"] = "windrunner",
	["WindshearCrag"] = "windshear-crag",
	["WingoftheWhelping"] = "wing-of-the-whelping",
	["Winterchill"] = "winterchill",
	["Wintergrasp"] = "wintergrasp",
	["Winterhoof"] = "winterhoof",
	["Winterspring"] = "winterspring",
	["WorldTree"] = "world-tree",
	["Wrathbringer"] = "wrathbringer",
	["WrathGate"] = "wrath-gate",
	["WyrmrestAccord"] = "wyrmrest-accord",
	["Xavian"] = "xavian",
	["Xavius"] = "xavius",
	["Ysera"] = "ysera",
	["Ysondre"] = "ysondre",
	["Zalazane"] = "zalazane",
	["Zangarmarsh"] = "zangarmarsh",
	["ZealotBlade"] = "zealot-blade",
	["Zenedar"] = "zenedar",
	["ZirkeldesCenarius"] = "zirkel-des-cenarius",
	["Zul'Aman"] = "zulaman",
	["Zul'Drak"] = "zuldrak",
	["Zul'jin"] = "zuljin",
	["Zuluhed"] = "zuluhed",
	["Азурегос"] = "azuregos",
	["Борейскаятундра"] = "borean-tundra",
	["ВечнаяПесня"] = "eversong",
	["Галакронд"] = "galakrond",
	["Голдринн"] = "goldrinn",
	["Гордунни"] = "gordunni",
	["Гром"] = "grom",
	["Дракономор"] = "fordragon",
	["Корольлич"] = "lich-king",
	["ПиратскаяБухта"] = "booty-bay",
	["Подземье"] = "deepholm",
	["Разувий"] = "razuvious",
	["Ревущийфьорд"] = "howling-fjord",
	["СвежевательДуш"] = "soulflayer",
	["Седогрив"] = "greymane",
	["СтражСмерти"] = "deathguard",
	["Термоштепсель"] = "thermaplugg",
	["ТкачСмерти"] = "deathweaver",
	["ЧерныйШрам"] = "blackscar",
	["Ясеневыйлес"] = "ashenvale",
	["가로나"] = "garona",
	["굴단"] = "guldan",
	["노르간논"] = "norgannon",
	["달라란"] = "dalaran",
	["데스윙"] = "deathwing",
	["듀로탄"] = "durotan",
	["렉사르"] = "rexxar",
	["말퓨리온"] = "malfurion",
	["불타는군단"] = "burning-legion",
	["세나리우스"] = "cenarius",
	["스톰레이지"] = "stormrage",
	["아즈샤라"] = "azshara",
	["알렉스트라자"] = "alexstrasza",
	["와일드해머"] = "wildhammer",
	["윈드러너"] = "windrunner",
	["줄진"] = "zuljin",
	["하이잘"] = "hyjal",
	["헬스크림"] = "hellscream",
	["万色星辰"] = "kaleidoscope-star",
	["世界之树"] = "world-tree",
	["世界之樹"] = "world-tree",
	["丽丽（四川）"] = "li-li",
	["丹莫德"] = "dun-modr",
	["主宰之剑"] = "the-masters-glaive",
	["亚雷戈斯"] = "arygos",
	["亞雷戈斯"] = "arygos",
	["亡语者"] = "deathwhisper",
	["伊兰尼库斯"] = "eranikus",
	["伊利丹"] = "illidan",
	["伊森利恩"] = "isillien",
	["伊森德雷"] = "ysondre",
	["伊瑟拉"] = "ysera",
	["伊莫塔尔"] = "immolthar",
	["伊萨里奥斯"] = "itharius",
	["元素之力"] = "force-of-elemental",
	["克尔苏加德"] = "kelthuzad",
	["克洛玛古斯"] = "chromaggus",
	["克羅之刃"] = "krol-blade",
	["老馬布蘭契"] = "old-blanchy",
	["克苏恩"] = "cthun",
	["兰娜瑟尔"] = "lanathel",
	["军团要塞"] = "legion-hold",
	["冬寒"] = "winterchill",
	["冬拥湖"] = "wintergrasp",
	["冬泉谷"] = "winterspring",
	["冰川之拳"] = "boulderfist",
	["冰霜之刃"] = "frostmane",
	["冰霜之刺"] = "frostmane",
	["冰風崗哨"] = "chillwind-point",
	["冰风岗"] = "chillwind-point",
	["凤凰之神"] = "alar",
	["凯尔萨斯"] = "kaelthas",
	["凯恩血蹄"] = "bloodhoof",
	["刀塔"] = "bladespire",
	["利刃之拳"] = "bladefist",
	["刺骨利刃"] = "daggerspine",
	["加兹鲁维"] = "gazlowe",
	["加基森"] = "gadgetzan",
	["加尔"] = "garr",
	["加德纳尔"] = "jaedenar",
	["加里索斯"] = "garithos",
	["勇士岛"] = "fray-island",
	["千针石林"] = "thousand-needles",
	["午夜之镰"] = "midnight-scythe",
	["卡德加"] = "khadgar",
	["卡德罗斯"] = "khardros",
	["卡扎克"] = "lord-kazzak",
	["卡拉赞"] = "karazhan",
	["卡珊德拉"] = "cassandra",
	["厄祖玛特"] = "ozumat",
	["双子峰"] = "twin-peaks",
	["古加尔"] = "chogall",
	["古尔丹"] = "guldan",
	["古拉巴什"] = "gurubashi",
	["古达克"] = "gundrak",
	["哈兰"] = "halaa",
	["哈卡"] = "hakkar",
	["噬灵沼泽"] = "mossflayer",
	["嚎风峡湾"] = "howling-fjord",
	["回音山"] = "echo-ridge",
	["国王之谷"] = "valley-of-kings",
	["图拉扬"] = "turalyon",
	["圣火神殿"] = "shrine-of-the-dormant-flame",
	["地狱之石"] = "fel-rock",
	["地狱咆哮"] = "hellscream",
	["地獄吼"] = "hellscream",
	["埃克索图斯"] = "executus",
	["埃加洛尔"] = "azgalor",
	["埃基尔松"] = "akilzon",
	["埃德萨拉"] = "eldrethalas",
	["埃苏雷格"] = "azuregos",
	["埃雷达尔"] = "eredar",
	["埃霍恩"] = "ahune",
	["基尔加丹"] = "kiljaeden",
	["基尔罗格"] = "kilrogg",
	["塔伦米尔"] = "tarren-mill",
	["塔纳利斯"] = "tanaris",
	["塞拉摩"] = "theramore",
	["塞拉赞恩"] = "therazane",
	["塞泰克"] = "sethekk",
	["塞纳里奥"] = "cenarius",
	["壁炉谷"] = "hearthglen",
	["夏维安"] = "xavian",
	["外域"] = "outland",
	["夜空之歌"] = "nightsong",
	["大地之怒"] = "deepfury",
	["大漩涡"] = "maelstrom",
	["天空之墙"] = "skywall",
	["天空之牆"] = "skywall",
	["天谴之门"] = "wrath-gate",
	["太阳之井"] = "sunwell",
	["夺灵者"] = "soulflayer",
	["奈法利安"] = "nefarian",
	["奎尔丹纳斯"] = "quedanas",
	["奎尔萨拉斯"] = "quelthalas",
	["奥妮克希亚"] = "onyxia",
	["奥尔加隆"] = "algalon",
	["奥拉基尔"] = "alakir",
	["奥斯里安"] = "ossirian",
	["奥杜尔"] = "ulduar",
	["奥特兰克"] = "alterac-mountains",
	["奥蕾莉亚"] = "alleria",
	["奥达曼"] = "uldaman",
	["奥金顿"] = "auchindoun",
	["守护之剑"] = "guardian-blade",
	["安东尼达斯"] = "antonidas",
	["安其拉"] = "ahnqiraj",
	["安加萨"] = "angrathar",
	["安多哈尔"] = "andorhal",
	["安威玛尔"] = "anvilmar",
	["安戈洛"] = "ungoro",
	["安格博达"] = "angerboda",
	["安纳塞隆"] = "anetheron",
	["安苏"] = "anzu",
	["密林游侠"] = "rangers",
	["寒冰皇冠"] = "icecrown",
	["尖石"] = "spirestone",
	["尘风峡谷"] = "dustwind-gulch",
	["屠魔山谷"] = "demon-fall-canyon",
	["山丘之王"] = "bronzebeard",
	["岩石巨塔"] = "spirestone",
	["巨龍之喉"] = "dragonmaw",
	["巨龙之吼"] = "dragonmaw",
	["巫妖之王"] = "lich-king",
	["巴尔古恩"] = "baelgun",
	["巴瑟拉斯"] = "barthilas",
	["巴纳扎尔"] = "balnazzar",
	["布兰卡德"] = "blanchard",
	["布莱克摩"] = "blackmoore",
	["布莱恩"] = "brann",
	["布鲁塔卢斯"] = "brutallus",
	["希尔瓦娜斯"] = "sylvanas",
	["希雷诺斯"] = "searinox",
	["幽暗沼泽"] = "the-underbog",
	["库尔提拉斯"] = "kul-tiras",
	["库德兰"] = "kurdran",
	["弗塞雷迦"] = "explorers-league",
	["影之哀伤"] = "shadowmourne",
	["影牙要塞"] = "shadowfang-keep",
	["德拉诺"] = "draenor",
	["恐怖图腾"] = "grimtotem",
	["恶魔之翼"] = "direwing",
	["恶魔之魂"] = "demon-soul",
	["憤怒使者"] = "wrathbringer",
	["戈古纳斯"] = "gorgonnash",
	["戈提克"] = "gothik",
	["戈杜尼"] = "gordunni",
	["战歌"] = "warsong",
	["扎拉赞恩"] = "zalazane",
	["托塞德林"] = "tortheldrin",
	["托尔巴拉德"] = "tol-barad",
	["拉文凯斯"] = "ravencrest",
	["拉文霍德"] = "ravenholdt",
	["拉格纳洛斯"] = "ragnaros",
	["拉贾克斯"] = "rajaxx",
	["提尔之手"] = "tyrs-hand",
	["提瑞斯法"] = "tirisfal-glades",
	["摩摩尔"] = "murmur",
	["斩魔者"] = "demonslayer",
	["斯克提斯"] = "skettis",
	["斯坦索姆"] = "stratholme",
	["无尽之海"] = "the-great-sea",
	["无底海渊"] = "abyssal-depths",
	["日落沼泽"] = "sundown-marsh",
	["日落沼澤"] = "sundown-marsh",
	["时光之穴"] = "caverns-of-time",
	["普瑞斯托"] = "prestor",
	["普罗德摩"] = "proudmoore",
	["晴日峰（江苏）"] = "peak-of-serenity",
	["暗影之月"] = "shadowmoon",
	["暗影裂口"] = "cleft-of-shadow",
	["暗影议会"] = "shadow-council",
	["暗影迷宫"] = "shadow-labyrinth",
	["暮色森林"] = "duskwood",
	["暴风祭坛"] = "altar-of-storms",
	["月光林地"] = "moonglade",
	["月神殿"] = "temple-of-elune",
	["末日祷告祭坛"] = "dooms-vigil",
	["末日行者"] = "doomwalker",
	["朵丹尼尔"] = "dordanil",
	["杜隆坦"] = "durotan",
	["格瑞姆巴托"] = "grim-batol",
	["格雷迈恩"] = "greymane",
	["格鲁尔"] = "gruul",
	["桑德兰"] = "thunderaan",
	["梅尔加尼"] = "malganis",
	["梦境之树"] = "dream-bough",
	["森金"] = "senjin",
	["死亡之翼"] = "deathwing",
	["死亡之门"] = "deaths-door",
	["死亡熔炉"] = "deathforge",
	["毁灭之锤"] = "doomhammer",
	["水晶之刺"] = "crystalpine-stinger",
	["永夜港"] = "nighthaven",
	["永恒之井"] = "well-of-eternity",
	["沃金"] = "voljin",
	["沙怒"] = "sandfury",
	["法拉希姆"] = "falathim",
	["泰兰德"] = "tyrande",
	["泰拉尔"] = "taerar",
	["洛丹伦"] = "lordaeron",
	["洛肯"] = "loken",
	["洛萨"] = "lothar",
	["海克泰尔"] = "hectae",
	["海加尔"] = "hyjal",
	["海达希亚"] = "hydraxis",
	["浸毒之骨"] = "poisontipped-bone-spear",
	["深渊之喉"] = "abyssal-maw",
	["深渊之巢"] = "deephome",
	["激流之傲"] = "river-pride",
	["激流堡"] = "stromgarde-keep",
	["火喉"] = "firegut",
	["火烟之谷"] = "dustbelcher",
	["火焰之树"] = "firetree",
	["火羽山"] = "fire-plume-ridge",
	["灰烬使者"] = "ashbringer",
	["灰谷"] = "ashenvale",
	["烈焰峰"] = "flame-crest",
	["烈焰荆棘"] = "smolderthorn",
	["熊猫酒仙"] = "pandaren",
	["熔火之心"] = "molten-core",
	["蒸汽地窟"] = "the-steamvault",
	["熵魔"] = "entropius",
	["燃烧之刃"] = "burning-blade",
	["燃烧军团"] = "burning-legion",
	["燃烧平原"] = "burning-steppes",
	["爱斯特纳"] = "astranaar",
	["狂热之刃"] = "zealot-blade",
	["狂熱之刃"] = "zealot-blade",
	["狂风峭壁"] = "windshear-crag",
	["玛克扎尔"] = "malchezaar",
	["玛多兰"] = "madoran",
	["玛格曼达"] = "magmadar",
	["玛格索尔"] = "mugthol",
	["玛法里奥"] = "malfurion",
	["玛洛加尔"] = "marrowgar",
	["玛瑟里顿"] = "magtheridon",
	["玛诺洛斯"] = "mannoroth",
	["玛里苟斯"] = "malygos",
	["瑞文戴尔"] = "rivendare",
	["瑟玛普拉格"] = "thermaplugg",
	["瑟莱德丝"] = "theradras",
	["瓦丝琪"] = "vashj",
	["瓦拉斯塔兹"] = "vaelastrasz",
	["瓦拉纳"] = "valanar",
	["瓦里安"] = "varian",
	["瓦里玛萨斯"] = "varimathras",
	["甜水绿洲"] = "lushwater-oasis",
	["生态船"] = "the-botanica",
	["白银之手"] = "silver-hand",
	["白骨荒野"] = "bone-wastes",
	["盖斯"] = "gyth",
	["眾星之子"] = "queldorei",
	["石爪峰"] = "stonetalon-peak",
	["石锤"] = "stonemaul",
	["破碎大厅"] = "shattered-halls",
	["破碎岭"] = "crushridge",
	["祖尔金"] = "zuljin",
	["祖达克"] = "zuldrak",
	["祖阿曼"] = "zulaman",
	["神圣之歌"] = "holy-chanter",
	["禁魔监狱"] = "the-arcatraz",
	["穆戈尔"] = "mogor",
	["符文图腾"] = "runetotem",
	["米奈希尔"] = "menethil",
	["米奈希爾"] = "menethil",
	["索拉丁"] = "thoradin",
	["索瑞森"] = "thaurissan",
	["红云台地"] = "red-cloud-mesa",
	["红龙军团"] = "red-dragonflight",
	["红龙女王"] = "alexstrasza",
	["纳克萨玛斯"] = "naxxramas",
	["纳沙塔尔"] = "nazjatar",
	["织亡者"] = "deathweaver",
	["维克尼拉斯"] = "veknilash",
	["罗宁"] = "rhonin",
	["罗曼斯"] = "rommath",
	["羽月"] = "feathermoon",
	["翡翠梦境"] = "emerald-dream",
	["耐克鲁斯"] = "nekros",
	["耐奥祖"] = "nerzhul",
	["耐普图隆"] = "neptulon",
	["耐萨里奥"] = "neltharion",
	["耳语海岸"] = "whispering-shore",
	["聖光之願"] = "lights-hope",
	["能源舰"] = "the-mechanar",
	["自由之风"] = "freewind",
	["艾森娜"] = "aessina",
	["艾欧纳尔"] = "eonar",
	["艾维娜"] = "aviana",
	["艾苏恩"] = "aszune",
	["艾莫莉丝"] = "emeriss",
	["艾萨拉"] = "azshara",
	["艾露恩"] = "elune",
	["芬里斯"] = "fenris",
	["苏塔恩"] = "sutarn",
	["苏拉玛"] = "suramar",
	["范克里夫"] = "vancleef",
	["范达尔鹿盔"] = "staghelm",
	["荆棘谷"] = "stranglethorn",
	["莉亚德琳"] = "liadrin",
	["莫加尔"] = "maulgar",
	["莫德雷萨"] = "mordrethar",
	["莫格莱尼"] = "mograine",
	["莱索恩"] = "lethon",
	["菲拉斯"] = "feralas",
	["菲米丝"] = "felmyst",
	["萨塔里奥"] = "sartharion",
	["萨尔"] = "thrall",
	["萨格拉斯"] = "sargeras",
	["萨洛拉丝"] = "sacrolash",
	["萨菲隆"] = "sapphiron",
	["蓝龙军团"] = "blue-dragonflight",
	["藏宝海湾"] = "booty-bay",
	["蜘蛛王国"] = "azjolnerub",
	["血之谷"] = "bleeding-hollow",
	["血吼"] = "gorehowl",
	["血槌"] = "bloodmaul",
	["血牙魔王"] = "gorefiend",
	["血环"] = "bleeding-hollow",
	["血羽"] = "bloodfeather",
	["血色十字军"] = "scarlet-crusade",
	["血顶"] = "bloodscalp",
	["語風"] = "whisperwind",
	["试炼之环"] = "ring-of-trials",
	["诺兹多姆"] = "nozdormu",
	["诺森德"] = "northrend",
	["诺莫瑞根"] = "gnomeregan",
	["贫瘠之地"] = "barrens",
	["踏梦者"] = "dreamwalker",
	["轻风之语"] = "whisperwind",
	["辛达苟萨"] = "sindragosa",
	["达克萨隆"] = "draktharon",
	["达基萨斯"] = "drakkisath",
	["达尔坎"] = "darkhan",
	["达文格尔"] = "dalvengyr",
	["达斯雷玛"] = "dathremar",
	["达纳斯"] = "danath-trollbane",
	["达隆米尔"] = "darrowmere",
	["迅捷微风"] = "swiftwind",
	["远古海滩"] = "strand-of-the-ancients",
	["迦拉克隆"] = "galakrond",
	["迦玛兰"] = "jammalan",
	["迦罗娜"] = "garona",
	["迦顿"] = "geddon",
	["迪托马斯"] = "destromath",
	["迪瑟洛克"] = "detheroc",
	["迪门修斯"] = "dimensius",
	["逐日者"] = "sunstrider",
	["通灵学院"] = "scholomance",
	["遗忘海岸"] = "the-forgotten-coast",
	["金度"] = "jindo",
	["金色平原"] = "the-golden-plains",
	["銀翼要塞"] = "silverwing-hold",
	["铜龙军团"] = "bronze-dragonflight",
	["银月"] = "silvermoon",
	["银松森林"] = "silverpine-forest",
	["闪电之刃"] = "lightnings-blade",
	["阿克蒙德"] = "archimonde",
	["阿努巴拉克"] = "anubarak",
	["阿卡玛"] = "akama",
	["阿古斯"] = "argus",
	["阿尔萨斯"] = "arthas",
	["阿扎达斯"] = "archaedas",
	["阿拉希"] = "arathi",
	["阿拉索"] = "arathor",
	["阿斯塔洛"] = "astalor",
	["阿曼尼"] = "amani",
	["阿格拉玛"] = "aggramar",
	["阿比迪斯"] = "abbendis",
	["阿纳克洛斯"] = "anachronos",
	["阿薩斯"] = "arthas",
	["阿迦玛甘"] = "agamaggan",
	["雏龙之翼"] = "wing-of-the-whelping",
	["雲蛟衛"] = "order-of-the-cloud-serpent",
	["雷克萨"] = "rexxar",
	["雷德"] = "rend",
	["雷斧堡垒"] = "thunder-axe-fortress",
	["雷霆之怒"] = "thunder-bluff",
	["雷霆之王"] = "thunderlord",
	["雷霆号角"] = "thunderhorn",
	["雷鱗"] = "stormscale",
	["霍格"] = "hogger",
	["霜之哀伤"] = "frostmourne",
	["霜狼"] = "frostwolf",
	["风暴之怒"] = "stormrage",
	["风暴之眼"] = "storm-eye",
	["风暴之鳞"] = "stormscale",
	["风暴峭壁"] = "storm-peaks",
	["风暴裂隙"] = "stormreaver",
	["风行者"] = "windrunner",
	["鬼雾峰"] = "dreadmist-peak",
	["鲜血熔炉"] = "blood-furnace",
	["鹰巢山"] = "aerie-peak",
	["麦姆"] = "maim",
	["麦维影歌"] = "maiev-shadowsong",
	["麦迪文"] = "medivh",
	["黄金之路"] = "gold-road",
	["黑手军团"] = "blackhand",
	["黑暗之矛"] = "darkspear",
	["黑暗之门"] = "dark-portal",
	["黑暗虚空"] = "twisting-nether",
	["黑暗魅影"] = "dark-phantom",
	["黑石尖塔"] = "blackrock",
	["黑翼之巢"] = "blackwing-lair",
	["黑铁"] = "dark-iron",
	["黑锋哨站"] = "ebon-watch",
	["黑龙军团"] = "black-dragonflight",
	["龙骨平原"] = "dragonblight",
}

---------
-- DEBUG
--------- 

miog.DEBUG_ROLE_TABLE = {
	"TANK",
	"HEALER",
	"DAMAGER"
}

miog.DEBUG_SPEC_TABLE = {
	[1] = {71, 72, 73},
	[2] = {65, 66, 70},
	[3] = {253, 254, 255},
	[4] = {259, 260, 261},
	[5] = {256, 257, 258},
	[6] = {250, 251, 252},
	[7] = {262, 263, 264},
	[8] = {62, 63, 64},
	[9] = {265, 266, 267},
	[10] = {268, 270, 269},
	[11] = {102, 103, 104, 105},
	[12] = {577, 581},
	[13] = {1467, 1468, 1473},
}

miog.DEBUG_APPLICANT_DATA = {}
miog.DEBUG_APPLICANT_MEMBER_INFO = {}

miog.DEBUG_TIER_TABLE = {
	[1] = {0, "N/A",},
	[2] = {1000, "Combatant I",},
	[3] = {1200, "Combatant II",},
	[4] = {1400, "Challenger I",},
	[5] = {1600, "Challenger II",},
	[6] = {1800, "Rival I",},
	[7] = {2000, "Rival II",},
	[8] = {2100, "Duelist",},
	[9] = {2400, "Elite",},
	[10] = {2700, "Legend",},
	[11] = {3000, "Gladiator",},
}

miog.DEBUG_RAIDER_IO_PROFILES = {
	[1] = {"Holyypits", "TwistingNether", "eu"},
	[2] = {"Clydragon", "Blackhand", "eu"},
	[3] = {"Bloo", "Drak'thul", "eu"},
	[4] = {"Mayvoker", "TarrenMill", "eu"},
	[5] = {"Facerollmon", "Draenor", "eu"},
	[6] = {"Celacestial", "TwistingNether", "eu"},
	[7] = {"Gripples", "Blackhand", "eu"},
	[8] = {"Lineal", "Ysondre", "eu"},
	[9] = {"Erloko", "Zul'jin", "eu"},
	[10] = {"Kuszii", "BurningLegion", "eu"},
	[11] = {"Panomanixme", "Suramar", "eu"},
	[12] = {"Dreana", "Ghostlands", "eu"},
	[13] = {"Drjay", "Ragnaros", "eu"},
	[14] = {"Jisoô", "TwistingNether", "eu"},
	[15] = {"Rhany", "Ravencrest", "eu"},
	[16] = {"Amesiella", "Blackrock", "eu"},
	[17] = {"Roftegar", "Kazzak", "eu"},
	[18] = {"Timmý", "Stormscale", "eu"},
	[19] = {"Sáberxx", "Blackrock", "eu"},
	[20] = {"Gorlami", "Blackhand", "eu"},
	[21] = {"Pøggers", "Eredar", "eu"},
	[22] = {"Eroxp", "Kazzak", "eu"},
	[23] = {"Baletea", "TwistingNether", "eu"},
	[24] = {"Minikristus", "Kazzak", "eu"},
	[25] = {"Cyavoker", "Nemesis", "eu"},
	[26] = {"Deathdots", "Kazzak", "eu"},
	[27] = {"Zeptia", "Draenor", "eu"},
	[28] = {"Args", "Blackrock", "eu"},
	[29] = {"Kittaren", "Silvermoon", "eu"},
	[30] = {"Caeladore", "TwistingNether", "eu"},
	[31] = {"Alizka", "Blackhand", "eu"},
	[32] = {"Kattenkurrar", "Ravencrest", "eu"},
	[33] = {"Celestio", "TwistingNether", "eu"},
}

miog.DEBUG_DEV_CHARACTERS = {
	"Rhany-Ravencrest",
	"Gerhanya-Ravencrest",
}