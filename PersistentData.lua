local addonName, miog = ...

miog.ITEM_QUALITY_COLORS = _G["ITEM_QUALITY_COLORS"]

for _, colorElement in pairs(miog.ITEM_QUALITY_COLORS) do
	colorElement.pureHex = colorElement.color:GenerateHexColor()
	colorElement.desaturatedRGB = {colorElement.r * 0.65, colorElement.g * 0.65, colorElement.b * 0.65}
	colorElement.desaturatedHex = CreateColor(unpack(colorElement.desaturatedRGB)):GenerateHexColor()
end

local testString = ""

miog.STRING_REPLACEMENTS = {
	["NORMALRAIDPROGRESSFULL"] = "Normal: %s",
	["HEROICRAIDPROGRESSFULL"] = "Heroic: %s",
	["MYTHICRAIDPROGRESSFULL"] = "Mythic: %s",
	["NORMALRAIDPROGRESSSHORT"] = "N: %s",
	["HEROICRAIDPROGRESSSHORT"] = "H: %s",
	["MYTHICRAIDPROGRESSSHORT"] = "M: %s",
	["MPLUSRATINGFULL"] = "Mythic+ Rating: %d",
	["MPLUSRATINGSHORT"] = "M+: %d",
	["PVPRATING2V2FULL"] = "2v2 Rating: %d",
	["PVPRATING2V2SHORT"] = "2v2: %d",
	["PVPRATING3V3FULL"] = "3v3 Rating: %d",
	["PVPRATING3V3SHORT"] = "3v3: %d",
	["PVPRATING5V5FULL"] = "5v5 Rating: %d",
	["PVPRATING5V5SHORT"] = "5v5: %d",
	["PVPRATING10V10FULL"] = "10v10 Rating: %d",
	["PVPRATING10V10SHORT"] = "10v10: %d",
	["PVPRATINGSOLOFULL"] = "Solo Shuffle Rating: %d",
	["PVPRATINGSOLOSHORT"] = "Solo: %d",
	["PVPRATINGSOLOBGFULL"] = "Solo BG Rating: %d",
	["PVPRATINGSOLOBGSHORT"] = "Solo BG: %d",
	["ILVLSHORT"] = "I-Lvl: %d",
}

local function addStringReplacementAlternatives()
	miog.STRING_REPLACEMENTS["RAIDPROGRESS1FULL"] = miog.STRING_REPLACEMENTS["NORMALRAIDPROGRESSFULL"]
	miog.STRING_REPLACEMENTS["RAIDPROGRESS2FULL"] = miog.STRING_REPLACEMENTS["HEROICRAIDPROGRESSFULL"]
	miog.STRING_REPLACEMENTS["RAIDPROGRESS3FULL"] = miog.STRING_REPLACEMENTS["MYTHICRAIDPROGRESSFULL"]
	
	miog.STRING_REPLACEMENTS["RAIDPROGRESS1SHORT"] = miog.STRING_REPLACEMENTS["NORMALRAIDPROGRESSSHORT"]
	miog.STRING_REPLACEMENTS["RAIDPROGRESS2SHORT"] = miog.STRING_REPLACEMENTS["HEROICRAIDPROGRESSSHORT"]
	miog.STRING_REPLACEMENTS["RAIDPROGRESS3SHORT"] = miog.STRING_REPLACEMENTS["MYTHICRAIDPROGRESSSHORT"]

	miog.STRING_REPLACEMENTS["PVPRATING1FULL"] = miog.STRING_REPLACEMENTS["PVPRATING2V2FULL"]
	miog.STRING_REPLACEMENTS["PVPRATING1SHORT"] = miog.STRING_REPLACEMENTS["PVPRATING2V2SHORT"]

	miog.STRING_REPLACEMENTS["PVPRATING2FULL"] = miog.STRING_REPLACEMENTS["PVPRATING3V3FULL"]
	miog.STRING_REPLACEMENTS["PVPRATING2SHORT"] = miog.STRING_REPLACEMENTS["PVPRATING3V3SHORT"]

	miog.STRING_REPLACEMENTS["PVPRATING3FULL"] = miog.STRING_REPLACEMENTS["PVPRATING5V5FULL"]
	miog.STRING_REPLACEMENTS["PVPRATING3SHORT"] = miog.STRING_REPLACEMENTS["PVPRATING5V5SHORT"]

	miog.STRING_REPLACEMENTS["PVPRATING4FULL"] = miog.STRING_REPLACEMENTS["PVPRATING10V10FULL"]
	miog.STRING_REPLACEMENTS["PVPRATING4SHORT"] = miog.STRING_REPLACEMENTS["PVPRATING10V10SHORT"]

	miog.STRING_REPLACEMENTS["PVPRATING7FULL"] = miog.STRING_REPLACEMENTS["PVPRATINGSOLOFULL"]
	miog.STRING_REPLACEMENTS["PVPRATING7SHORT"] = miog.STRING_REPLACEMENTS["PVPRATINGSOLOSHORT"]

	miog.STRING_REPLACEMENTS["PVPRATING9FULL"] = miog.STRING_REPLACEMENTS["PVPRATINGSOLOBGFULL"]
	miog.STRING_REPLACEMENTS["PVPRATING9SHORT"] = miog.STRING_REPLACEMENTS["PVPRATINGSOLOBGSHORT"]

end

addStringReplacementAlternatives()

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
	colors = {},
}

for k, v in pairs(miog.CLRSCC) do
	miog.CLRSCC.colors[k] = CreateColorFromHexString(v)

end

miog.SLOT_ID_INFO = {
	[0] = {slotName = "AMMOSLOT", localizedName = nil},
	[1] = {slotName = "HEADSLOT", localizedName = nil},
	[2] = {slotName = "NECKSLOT", localizedName = nil},
	[3] = {slotName = "SHOULDERSLOT", localizedName = nil},
	[4] = {slotName = "SHIRTSLOT", localizedName = nil},
	[5] = {slotName = "CHESTSLOT", localizedName = nil},
	[6] = {slotName = "WAISTSLOT", localizedName = nil},
	[7] = {slotName = "LEGSSLOT", localizedName = nil},
	[8] = {slotName = "FEETSLOT", localizedName = nil},
	[9] = {slotName = "WRISTSLOT", localizedName = nil},
	[10] = {slotName = "HANDSSLOT", localizedName = nil},
	[11] = {slotName = "FINGER0SLOT", localizedName = nil},
	[12] = {slotName = "FINGER1SLOT", localizedName = nil},
	[13] = {slotName = "TRINKET0SLOT", localizedName = nil},
	[14] = {slotName = "TRINKET1SLOT", localizedName = nil},
	[15] = {slotName = "BACKSLOT", localizedName = nil},
	[16] = {slotName = "MAINHANDSLOT", localizedName = nil},
	[17] = {slotName = "SECONDARYHANDSLOT", localizedName = nil},
	[18] = {slotName = "RANGEDSLOT", localizedName = nil},
	[19] = {slotName = "TABARDSLOT", localizedName = nil},
}

for i = 0, #miog.SLOT_ID_INFO, 1 do
	miog.SLOT_ID_INFO[i].localizedName = _G[miog.SLOT_ID_INFO[i].slotName]

end

miog.AJ_CLRSCC = {
	[1] = miog.CLRSCC.blue,
	[2] = miog.CLRSCC.purple,
	[3] = miog.CLRSCC.yellow,
	[4] = miog.CLRSCC.aqua,
	[5] = miog.CLRSCC.lime,
	[6] = miog.CLRSCC.red,
	[7] = miog.CLRSCC.teal,
	[8] = miog.CLRSCC.fuchsia,
	[9] = miog.CLRSCC.orange,
	[10] = miog.CLRSCC.green,
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
	["requeue"] = {statusString = "REQUEUED", color = miog.CLRSCC["blue"]}
}

miog.FILTER_DESCRIPTIONS = {
	["roles"] = "Allows/disallows all groups where a party members has the specific role.",
	["partyfit"] = "Checks if you / the applicant fits the party, e.g. there is a healer missing and you're a healer.",
	["ressfit"] = "Checks if you / the applicant has a battle resurrection.",
	["lustfit"] = "Checks if you / the applicant has a lust/heroism effect.",
	["decline"] = "Checks if the group has actively declined you before, e.g. clicked the X button on your application.",
	["difficulty"] = "Set the difficulty of the groups you wanna see.",
	["tank"] = "Select the number of tanks the groups should have. Clicking the link icon and the link icon of another role filter will check if atleast 1 of them passes (e.g. you wanna have atleast a tank or healer in the group).",
	["healer"] = "Select the number of healers the groups should have. Clicking the link icon and the link icon of another role filter will check if atleast 1 of them passes (e.g. you wanna have atleast a tank or healer in the group).",
	["damager"] = "Select the number of damagers the groups should have. Clicking the link icon and the link icon of another role filter will check if atleast 1 of them passes (e.g. you wanna have atleast a tank or healer in the group).",
	["age"] = "Set the minimum and/or maximum amount of minutes the groups have to be listed.",
	["rating"] = "Set the minimum and/or maximum amount of rating points the groups should have to be listed.",
	["activities"] = "Select specific activities (usually connected to the current seasonal dungeons and raids).",
}

miog.INELIGIBILITY_REASONS = {
	["allGood"] = {"All filters checked and group is okay.", "All good", },
	["noResult"] = {"No search result info.", "No result", },
	["incorrectCategory"] = {"Incorrect categoryID.", "Incorrect category", },
	["hardDeclined"] = {"You have been hard declined from this group.", "Hard declined", },
	["incorrectDifficulty"] = {"The difficulty ID doesn't not match the one you selected.", "Incorrect difficulty", },
	["incorrectBracket"] = {"The bracket ID doesn't not match the one you selected.", "Incorrect bracket", },
	["incorrectTier"] = {"The tier doesn't not match the one you selected.", "Incorrect tier", },
	["partyFit"] = {"No more slots for the roles of the players in your group.", "No slots", },
	["ressFit"] = {"If you join there won't be anyone who has a class ress ability.", "No ress", },
	["lustFit"] = {"If you join there won't be anyone with a lust effect.", "No lust", },
	["affixFit"] = {"If you join there won't be anyone to deal with this weeks affixes.", "No affix coverage", },
	["classFiltered"] = {"Your class filters do not match with this listing.", "Class filtered", },
	["specFiltered"] = {"Your spec filters do not match with this listing.", "Spec filtered", },
	["incorrectNumberOfRoles"] = {"Incorrect number of tanks/healers/damagers.", "Incorrect number of roles", },
	["incorrectRoles"] = {"Your role filters do not match with this listing.", "Incorrect roles"},
	["ratingMismatch"] = {"Your rating filters do not match with this listing.", "Rating mismatch"},
	["ratingLowerMismatch"] = {"Your lowest rating filter do not match with this listing.", "Lowest Rating mismatch"},
	["ratingHigherMismatch"] = {"Your highest rating filter do not match with this listing.", "Highest Rating mismatch"},
	["dungeonMismatch"] = {"Your dungeon selection does not match with this listing.", "Dungeon mismatch"},
	["delveMismatch"] = {"Your delve selection does not match with this listing.", "Delve mismatch"},
	["pvpMismatch"] = {"Your pvp mode selection does not match with this listing.", "PVP mismatch"},
	["raidMismatch"] = {"Your raid selection does not match with this listing.", "Raid mismatch"},
	["bossSelectionMismatch"] = {"Your boss selection does not match with this listing.", "Boss selection mismatch"},
	["bossKillsMismatch"] = {"Your boss kills filters do not match with this listing.", "Boss kills mismatch"},
	["bossKillsLowerMismatch"] = {"Your lowest boss kills filter do not match with this listing.", "Lowest boss kills mismatch"},
	["bossKillsHigherMismatch"] = {"Your highest boss kills filter do not match with this listing.", "Highest boss kills mismatch"},
	["ageMismatch"] = {"Your age filters do not match with this listing.", "Age mismatch"},
	["ageLowerMismatch"] = {"Your lowest age filter do not match with this listing.", "Lowest age mismatch"},
	["ageHigherMismatch"] = {"Your highest rating age do not match with this listing.", "Highest age mismatch"},
	["exceededMaxPlayers"] = {"The number of players in your group plus the number of members in this listings group exceed the maximum allowed number of players for this activity.", "Too many players"}

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
	[DifficultyUtil.ID.RaidStory] = miog.ITEM_QUALITY_COLORS[1].color,
}

miog.DIFFICULTY_ID_TO_SHORT_NAME = {
	[DifficultyUtil.ID.DungeonNormal] = "N",
	[DifficultyUtil.ID.DungeonHeroic] = "H",
	[DifficultyUtil.ID.Raid10Normal] = "10N",
	[DifficultyUtil.ID.Raid25Normal] = "25N",
	[DifficultyUtil.ID.Raid10Heroic] = "10H",
	[DifficultyUtil.ID.Raid25Heroic] = "25H",
	[DifficultyUtil.ID.RaidLFR] = "25RF",
	[DifficultyUtil.ID.DungeonChallenge] = "M+",
	[DifficultyUtil.ID.Raid40] = "40",
	[DifficultyUtil.ID.PrimaryRaidNormal] = "N",
	[DifficultyUtil.ID.PrimaryRaidHeroic] = "H",
	[DifficultyUtil.ID.PrimaryRaidMythic] = "M",
	[DifficultyUtil.ID.PrimaryRaidLFR] = "LFR",
	[DifficultyUtil.ID.DungeonMythic] = "M",
	[DifficultyUtil.ID.DungeonTimewalker] = "TW",
	[DifficultyUtil.ID.RaidTimewalker] = "TW",
	[DifficultyUtil.ID.RaidStory] = "ST",
}

miog.DIFFICULTY_ID_INFO = {}

miog.DIFFICULTY = {
	[4] = {shortName = "M+", description = "Mythic+", color = miog.ITEM_QUALITY_COLORS[5].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[5].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[5].color},
	[3] = {shortName = "M", description = _G["PLAYER_DIFFICULTY6"], color = miog.ITEM_QUALITY_COLORS[4].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[4].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[4].color, baseColor = miog.ITEM_QUALITY_COLORS[4]},
	[2] = {shortName = "H", description = _G["PLAYER_DIFFICULTY2"], color = miog.ITEM_QUALITY_COLORS[3].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[3].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[3].color, baseColor = miog.ITEM_QUALITY_COLORS[3]},
	[1] = {shortName = "N", description = _G["PLAYER_DIFFICULTY1"], color = miog.ITEM_QUALITY_COLORS[2].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[2].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[2].color, baseColor = miog.ITEM_QUALITY_COLORS[2]},
	[0] = {shortName = "LT", description = "Last tier", color = miog.ITEM_QUALITY_COLORS[0].pureHex, desaturated = miog.ITEM_QUALITY_COLORS[0].desaturatedHex, miogColors = miog.ITEM_QUALITY_COLORS[0].color},
	[-1] = {shortName = "NT", description = "No tier", color = "FFFF2222", desaturated = "ffe93838"},
}

miog.CUSTOM_DIFFICULTY_ORDER = {
	["LFR"] = 1,
	["N"] = 2,
	["H"] = 3,
	["M"] = 4,
	["M+"] = 5,
}

for i = 0, 250, 1 do -- https://wago.tools/db2/Difficulty
	local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID, isLFR, minGroupSize, maxGroupSize = GetDifficultyInfo(i)

	if(name) then
		miog.DIFFICULTY_ID_INFO[i] = {
			name = i == 8 and "Mythic+" or name,
			shortName = miog.DIFFICULTY_ID_TO_SHORT_NAME[i],
			type = groupType,
			isHeroic = isHeroic,
			isChallengeMode = isChallengeMode,
			isLFR = isLFR,
			toggleDifficulty = toggleDifficultyID,
			color = miog.DIFFICULTY_ID_TO_COLOR[i] and miog.DIFFICULTY_ID_TO_COLOR[i]}

		if(miog.DIFFICULTY_ID_INFO[i].shortName) then
			miog.DIFFICULTY_ID_INFO[i].customDifficultyOrderIndex = miog.CUSTOM_DIFFICULTY_ORDER[miog.DIFFICULTY_ID_INFO[i].shortName]
			
		end
	end
end

miog.DIFFICULTY_ID_INFO[0] = {name = " ", shortName = " ", type="party"}

miog.DUNGEON_DIFFICULTIES = {
	DifficultyUtil.ID.DungeonNormal,
	DifficultyUtil.ID.DungeonHeroic,
	DifficultyUtil.ID.DungeonMythic,
	DifficultyUtil.ID.DungeonChallenge,
}

miog.RAID_DIFFICULTIES = {
	DifficultyUtil.ID.PrimaryRaidLFR,
	DifficultyUtil.ID.PrimaryRaidNormal,
	DifficultyUtil.ID.PrimaryRaidHeroic,
	DifficultyUtil.ID.PrimaryRaidMythic,
}

miog.DELVE_TIERS = {

}

miog.rpairs = function(t)
	return function(t, i)
		i = i - 1
		if i ~= 0 then
			return i, t[i]
		end
	end, t, #t + 1
end

--CONSTANTS
miog.C = {
	-- 1.5 seconds seems to be the internal throttle of the inspect function / Blizzard's inspect data provider.
	-- 1.4 locks up the inspects after a maximum of ~15 inspects.
	-- First 6 inspects are not affected by this throttle.
	-- I have played around with many different delays or different request "sets" (e.g. every 3 seconds 2 applicants, every 5 seconds 4 applicants) but nothing seems to work as well as: if number of members < 6 all instantly, otherwise every 1.5 seconds (?????????)
	BLIZZARD_INSPECT_THROTTLE = 1.5,
	BLIZZARD_INSPECT_THROTTLE_SAVE = 2,
	BLIZZARD_INSPECT_THROTTLE_ULTRA_SAVE = 3,

	PLAYER_GUID = UnitGUID("player"),
    
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

	--PATH / TEXTURES FILES
	STANDARD_FILE_PATH = "Interface/Addons/MythicIOGrabber/res",
	RIO_STAR_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/star_64.png:8:8|t",
	TANK_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/tankIcon.png:16:16|t",
	HEALER_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/healerIcon.png:16:16|t",
	DPS_TEXTURE = "|TInterface/Addons/MythicIOGrabber/res/infoIcons/damagerIcon.png:16:16|t",
	STAR_TEXTURE = "⋆",
	
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
		},
		[14] = { --patchweek
			year = 2025,
			month = 3,
			day = 3,
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
	[9] = "S1",
	[10] = "S2",
	[11] = "S3",
	[12] = "S4",

	-- The War Within
	[13] = "S1",
	[14] = "S2",
	[15] = "S3",

	[99] = "DUMMY SEASON"
}

miog.CURRENCY_INFO = {
	[12] = {
		{id = 2245,},
		{id = 2806,},
		{id = 2807,},
		{id = 2809,},
		{id = 2812,},
		{id = 3010, icon = "4555657",},
	},
	[13] = {
		{id = 2917,},
		{id = 2916,},
		{id = 2915,},
		{id = 2914,},
		{id = 3008,},
		{id = 2813,}, --catalyst
	},
	[14] = {
		{id = 3107,},
		{id = 3108,},
		{id = 3109,},
		{id = 3110,},
		{id = 3008,}, --valorstones
		{id = 3116,}, --catalyst
		{id = 3132, icon="5929751", spark = true, sparkItem = 230905}, --spark
	}
}


--CHANGING VARIABLES
miog.F = {
	IS_IN_DEBUG_MODE = false,

	CURRENT_REGION = miog.C.REGIONS[GetCurrentRegion()],

	LFG_STATE = "solo",

	CAN_INVITE = false,
}

miog.BLANK_BACKGROUND_INFO = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tileSize = 20,
	tile = false,
	edgeSize = 1
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

miog.KEYSTONE_LEVEL_BASE_VALUES = {
	[2] = 155,
	[3] = 170,
	[4] = 200,
	[5] = 215,
	[6] = 230,
	[7] = 260,
	[8] = 275,
	[9] = 290,
	[10] = 320,
	[11] = 335,
	[12] = 365,
	[13] = 380,
	[14] = 395,
	[15] = 410,
	[16] = 425,
	[17] = 440,
	[18] = 455,
	[19] = 470,
	[20] = 485,
	[21] = 500,
	[22] = 515,
	[23] = 530,
	[24] = 545,
	[25] = 560,
	[26] = 575,
	[27] = 590,
	[28] = 605,
	[29] = 620,
	[30] = 635,
}

miog.KEYSTONE_BASE_SCORE = {}

for k = 2, 30, 1 do
	miog.KEYSTONE_BASE_SCORE[k] = miog.KEYSTONE_LEVEL_BASE_VALUES[k] * 8

end

miog.MAP_INFO = {
	[30] = {shortName = "AV", icon = "interface/lfgframe/lfgicon-battleground.blp", fileName = "pvpbattleground", toastBG = "PvpBg-AlteracValley-ToastBG", pvp = "true"},
	[489] = {shortName = "WSG", icon = "interface/lfgframe/lfgicon-warsonggulch.blp", fileName = "warsonggulch_update", toastBG = "PvpBg-WarsongGulch-ToastBG", pvp = "true"},
	[529] = {shortName = "AB", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasin_update", toastBG = "PvpBg-ArathiBasin-ToastBG", pvp = "true"},
	[559] = {shortName = "NA", icon = "interface/lfgframe/lfgicon-nagrandarena.blp", fileName = "nagrandarenabg", toastBG = "PvpBg-NagrandArena-ToastBG", pvp = "true"},
	[562] = {shortName = "BEA", icon = "interface/lfgframe/lfgicon-bladesedgearena.blp", fileName = "bladesedgearena", toastBG = "PvpBg-BladesEdgeArena-ToastBG", pvp = "true"},
	[566] = {shortName = "EOTS", icon = "interface/lfgframe/lfgicon-netherbattlegrounds.blp", fileName = "netherbattleground", toastBG = "PvpBg-EyeOfTheStorm-ToastBG", pvp = "true"},
	[572] = {shortName = "ROL", icon = "interface/lfgframe/lfgicon-ruinsoflordaeron.blp", fileName = "ruinsoflordaeronbg", toastBG = "PvpBg-RuinsofLordaeron-ToastBG", pvp = "true"},
	[607] = {shortName = "SOTA", icon = "interface/lfgframe/lfgicon-strandoftheancients.blp", fileName = "northrendbg", toastBG ="PvpBg-StrandOfTheAncients-ToastBG", pvp = "true"},
	[617] = {shortName = "DS", icon = "interface/lfgframe/lfgicon-dalaransewers.blp", fileName = "dalaransewersarena", toastBG = "PvpBg-DalaranSewers-ToastBG", pvp = "true"},
	[618] = {shortName = "ROV", icon = "interface/lfgframe/lfgicon-ringofvalor.blp", fileName = "orgrimmararena", toastBG = "PvpBg-TheRingofValor-ToastBG", pvp = "true"},
	[628] = {shortName = "IOC", icon = "interface/lfgframe/lfgicon-isleofconquest.blp", fileName = "isleofconquest", toastBG = "PvpBg-IsleOfConquest-ToastBG"}, pvp = "true",
	[726] = {shortName = "TP", icon = "interface/lfgframe/lfgicon-twinpeaksbg.blp", fileName = "twinpeaksbg", toastBG = "PvpBg-TwinPeaks-ToastBG", pvp = "true"},
	[727] = {shortName = "SSM", icon = "interface/lfgframe/lfgicon-silvershardmines.blp", fileName = "silvershardmines", pvp = "true"},
	[761] = {shortName = "BFG", icon = "interface/lfgframe/lfgicon-thebattleforgilneas.blp", fileName = "gilneasbg2", toastBG = "PvpBg-Gilneas-ToastBG", pvp = "true"},
	[968] = {shortName = "EOTS", icon = "interface/lfgframe/lfgicon-netherbattlegrounds.blp", fileName = "netherbattleground", toastBG = "PvpBg-EyeOfTheStorm-ToastBG", pvp = "true"},
	[980] = {shortName = "TVA", icon = "interface/lfgframe/lfgicon-tolvirarena.blp", fileName = "tolvirarena", pvp = "true"},
	[998] = {shortName = "TOK", icon = "interface/lfgframe/lfgicon-templeofkotmogu.blp", fileName = "templeofkotmogu", pvp = "true"},
	[1105] = {shortName = "DWD", icon = "interface/lfgframe/lfgicon-deepwindgorge.blp", fileName = "goldrush", pvp = "true"},
	[1134] = {shortName = "TP", icon = "interface/lfgframe/lfgicon-shadopanbg.blp", fileName = "shadowpan_bg", pvp = "true"},
	[1191] = {shortName = "ASH", icon = "interface/lfgframe/lfgicon-ashran.blp", fileName = "ashran", pvp = "true"},
	[1504] = {shortName = "BRH", icon = "interface/lfgframe/lfgicon-blackrookholdarena.blp", fileName = "blackrookholdarena", pvp = "true"},
	[1505] = {shortName = "NA", icon = "interface/lfgframe/lfgicon-nagrandarena.blp", fileName = "nagrandarenabg", toastBG = "PvpBg-NagrandArena-ToastBG", pvp = "true"},
	[1552] = {shortName = "AF", icon = "interface/lfgframe/lfgicon-valsharraharena.blp", fileName = "arenavalsharah", pvp = "true"},
	[1672] = {shortName = "BEA", icon = "interface/lfgframe/lfgicon-bladesedgearena.blp", fileName = "bladesedgearena", toastBG = "PvpBg-BladesEdgeArena-ToastBG", pvp = "true"},
	[1681] = {shortName = "AB-W", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasinwinter", toastBG = "PvpBg-ArathiBasin-ToastBG", pvp = "true"},
	[1715] = {shortName = "BBM", icon = "interface/lfgframe/lfgicon-blackrockdepths.blp", fileName = "blackrockdepths", pvp = "true"},
	[1782] = {shortName = "SST", icon = "interface/lfgframe/lfgicon-seethingshore.blp", fileName = "seethingshore", pvp = "true"},
	[1803] = {shortName = "SSH", icon = "interface/lfgframe/lfgicon-seethingshore.blp", fileName = "seethingshore", pvp = "true"},
	[2106] = {shortName = "WSG", icon = "interface/lfgframe/lfgicon-warsonggulch.blp", fileName = "warsonggulch_update", toastBG = "PvpBg-WarsongGulch-ToastBG", pvp = "true"},
	[2107] = {shortName = "AB", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasin_update", toastBG = "PvpBg-ArathiBasin-ToastBG", pvp = "true"},
	[2177] = {shortName = "AB", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasin_update", toastBG = "PvpBg-ArathiBasin-ToastBG", pvp = "true"},
	[2118] = {shortName = "BFW", icon = "interface/lfgframe/lfgicon-battleground.blp", fileName = "wintergrasp", pvp = "true"},
	[2245] = {shortName = "DWG", icon = "interface/lfgframe/lfgicon-deepwindgorge.blp", fileName = "goldrush", pvp = "true"},
		
	--VANILLA
	[36] = {shortName = "DM", fileName = "deadmines"},
	[43] = {shortName = "WC", fileName = "wailingcaverns"},
	[389] = {shortName = "RFC", fileName = "ragefirechasm"},
	[48] = {shortName = "BFD", fileName = "blackfathomdeeps"},
	[34] = {shortName = "SS", fileName = "stormwindstockades"},
	[90] = {shortName = "GR", fileName = "gnomeregan"},
	[47] = {shortName = "RFK", fileName = "razorfenkraul"},
	[129] = {shortName = "RFD", fileName = "razorfendowns"},
	[70] = {shortName = "ULD", fileName = "uldaman"},
	[209] = {shortName = "ZF", fileName = "zulfarak"},
	[349] = {shortName = "MAU", fileName = "maraudon"},
	[109] = {shortName = "ST", fileName = "sunkentemple"},
	[230] = {shortName = "BRD", fileName = "blackrockdepths"},
	[229] = {shortName = "BRS", fileName = "blackrockspire"},
	[429] = {shortName = "DM", fileName = "diremaul"},
	[329] = {shortName = "SH", iconName = "oldstratholme", bgName = "stratholme"},
	[1007] = {shortName = "SCHOLO", fileName = "scholomance"},
	[33] = {shortName = "SFK", fileName = "shadowfangkeep"},

	[409] = {shortName = "MC", fileName = "moltencore"},
	[469] = {shortName = "BWL", fileName = "blackwinglair"},
	[509] = {shortName = "AQ20", fileName = "aqruins"},
	[531] = {shortName = "AQ40",  fileName = "aqtemple"},

	--THE BURNING CRUSADE
	[543] = {shortName = "RAMPS", fileName = "hellfirecitadel"},
	[542] = {shortName = "BF", fileName = "hellfirecitadel"},
	[540] = {shortName = "SH", fileName = "hellfirecitadel"},
	[547] = {shortName = "SP", fileName = "coilfang"},
	[546] = {shortName = "UB", fileName = "coilfang"},
	[545] = {shortName = "SV", fileName = "coilfang"},
	[557] = {shortName = "MT", fileName = "auchindoun"},
	[558] = {shortName = "CRYPTS", fileName = "auchindoun"},
	[556] = {shortName = "SETH", fileName = "auchindoun"},
	[555] = {shortName = "SL", fileName = "auchindoun"},
	[1001] = {shortName = "SH", fileName = "scarlethalls"},
	[1004] = {shortName = "SM", fileName = "scarletmonastery"},
	[560] = {shortName = "EFD", fileName = "cavernsoftime"},
	[269] = {shortName = "BM", fileName = "cavernsoftime"},
	[554] = {shortName = "MECH", fileName = "tempestkeep"},
	[553] = {shortName = "BOTA", fileName = "tempestkeep"},
	[552] = {shortName = "ARC", fileName = "tempestkeep"},
	[585] = {shortName = "MGT", fileName = "magistersterrace"},
	
	[534] = {shortName = "BMH", fileName = "hyjalpast"},
	[565] = {shortName = "GL", fileName = "gruulslair"},
	[544] = {shortName = "ML", fileName = "hellfireraid"},
	[548] = {shortName = "SSC", iconName = "serpentshrinecavern", bgName = "coilfang"},
	[532] = {shortName = "KARA", fileName = "karazhan"},
	[564] = {shortName = "BT", fileName = "blacktemple"},
	[550] = {shortName = "TK", fileName = "tempestkeep"},
	[580] = {shortName = "SW", fileName = "sunwell"},

	--WRATH OF THE LICH KING
	[574] = {shortName = "UTK", fileName = "utgarde"},
	[575] = {shortName = "UTP", fileName = "utgardepinnacle"},
	[601] = {shortName = "AN", fileName = "azjolnerub"},
	[578] = {shortName = "OCU", fileName = "theoculus"},
	[602] = {shortName = "HOL", fileName = "hallsoflightning"},
	[599] = {shortName = "HOS", fileName = "hallsofstone"},
	[595] = {shortName = "CULL", fileName = "stratholme"},
	[600] = {shortName = "DTK", fileName = "draktharon"},
	[604] = {shortName = "GUN", fileName = "gundrak"},
	[619] = {shortName = "ATOK", fileName = "ahnkalet"},
	[608] = {shortName = "VH", fileName = "theviolethold"},
	[576] = {shortName = "NEX", fileName = "thenexus"},
	[650] = {shortName = "TOTC", fileName = "argentdungeon"},
	[632] = {shortName = "FOS", fileName = "theforgeofsouls"},
	[658] = {shortName = "PIT", fileName = "pitofsaron"},
	[668] = {shortName = "HOR", fileName = "hallsofreflection"},
	
	[615] = {shortName = "OS", fileName = "chamberofaspects"},
	[533] = {shortName = "NAXX", fileName = "naxxramas"},
	[624] = {shortName = "VOA", fileName = "vaultofarchavon"},
	[603] = {shortName = "ULD", fileName = "ulduar"},
	[616] = {shortName = "EOE", fileName = "malygos"},
	[649] = {shortName = "TOTC", fileName = "argentraid"},
	[631] = {shortName = "ICC", fileName = "icecrowncitadel"},
	[249] = {shortName = "ONY", fileName = "onyxiaencounter"},
	[724] = {shortName = "RS", fileName = "rubysanctum"},

	-- CATACLYSM
	[859] = {shortName = "ZG", fileName = "zulgurub"},
	[568] = {shortName = "ZA", fileName = "zulaman"},
	[938] = {shortName = "ET", fileName = "endtime"},
	[939] = {shortName = "WOE", fileName = "wellofeternity"},
	[940] = {shortName = "HOT", fileName = "houroftwilight"},
	[645] = {shortName = "BRC", fileName = "blackrockcaverns"},
	[670] = {shortName = "GB", fileName = "grimbatol"},
	[644] = {shortName = "HOO", fileName = "hallsoforigination"},
	[725] = {shortName = "SC", fileName = "thestonecore"},
	[755] = {shortName = "LCT", fileName = "lostcityoftolvir"},
	[643] = {shortName = "TOTT", fileName = "throneofthetides"},
	[657] = {shortName = "VP", fileName = "thevortexpinnacle"},
	[669] = {shortName = "BWD", fileName = "blackwingdescentraid"},
	[671] = {shortName = "BOT", fileName = "grimbatolraid"},
	[754] = {shortName = "TOTFW", fileName = "throneofthefourwinds"},
	[757] = {shortName = "BH", fileName = "baradinhold"},
	[720] = {shortName = "FL", fileName = "firelands"},
	[967] = {shortName = "DS", fileName = "dragonsoul"},

	-- MISTS OF PANDARIA
	--[870] = {shortName = "RPD", icon = ""}, --RANDOM PANDARIA DUNGEON
	[960] = {shortName = "TOTJS", fileName = "templeofthejadeserpent"},
	[961] = {shortName = "SSB", fileName = "stormstoutbrewery"},
	[959] = {shortName = "SPM", fileName = "shadowpanmonastery"},
	[994] = {shortName = "MSP", fileName = "mogushanpalace"},
	[1011] = {shortName = "SNT", fileName = "siegeofnizaotemple"},
	[962] = {shortName = "GOTSS", fileName = "gateofthesettingsun"},
	[1008] = {shortName = "MSV",  fileName = "mogushanvaults"},
	[1009] = {shortName = "HOF", fileName = "heartoffear"},
	[996] = {shortName = "TOES", fileName = "terraceoftheendlessspring"},
	[1098] = {shortName = "TOT", fileName = "thunderpinnacle"},
	[1136] = {shortName = "SOO", fileName = "orgrimmargates"},
	
	-- WARLORDS OF DRAENOR
	--[1116] = {shortName = "RWD", icon = ""}, --RANDOM WARLORDS DUNGEON
	[1175] = {shortName = "BSM", fileName = "bloodmaulslagmines"},
	[1195] = {shortName = "ID", fileName = "irondocks"},
	[1182] = {shortName = "AUCH", fileName = "auchindounwod"},
	[1209] = {shortName = "SR", fileName = "skyreach"},
	[1208] = {shortName = "GD", fileName = "grimraildepot"},
	[1358] = {shortName = "UBRS", fileName = "upperblackrockspire"},
	[1176] = {shortName = "SBG", fileName = "shadowmoonburialgrounds"},
	[1279] = {shortName = "EB", fileName = "everbloom"},
	[1228] = {shortName = "HM", fileName = "highmaul"},
	[1205] = {shortName = "BRF", fileName = "blackrockfoundry"},
	[1448] = {shortName = "HFC", fileName = "hellfireraid"},

	--LEGION
	--[1220] = {shortName = "RLD", icon = ""}, --RANDOM LEGION DUNGEON
	[1458] = {shortName = "NL", fileName = "neltharionslair"},
	[1466] = {shortName = "DHT", fileName = "darkheartthicket"},
	[1477] = {shortName = "HOV", fileName = "hallsofvalor"},
	[1571] = {shortName = "COS", fileName = "courtofstars"},
	[1501] = {shortName = "BRH", fileName = "blackrookhold"},
	[1456] = {shortName = "EOA", fileName = "eyeofazshara"},
	[1544] = {shortName = "AOVH", fileName = "assaultonviolethold"},
	[1493] = {shortName = "VOTW", fileName = "vaultofthewardens"},
	[1492] = {shortName = "MOS", fileName = "mawofsouls"},
	[1516] = {shortName = "ARC", fileName = "thearcway"},
	[1753] = {shortName = "SEAT", fileName = "seatofthetriumvirate"},
	[1651] = {shortName = "RTK", fileName = "returntokarazhan"},
	[1677] = {shortName = "COEN", fileName = "cathedralofeternalnight"},
	[1520] = {shortName = "EN", fileName = "theemeraldnightmare-riftofaln"},
	[1530] = {shortName = "NH", fileName = "thenighthold"},
	[1648] = {shortName = "TOV", fileName = "trialofvalor"},
	--[1651] = {shortName = "", icon = ""},
	[1676] = {shortName = "TOS", iconName = "tombofsargerasdeceiversfall", bgName = "tombofsargeras"},
	[1712] = {shortName = "ATBT", fileName = "antorus"},

	-- BATTLE FOR AZEROTH
	--[1642] = {shortName = "RBD", icon = ""}, --RANDOM BFA DUNGEON
	[1861] = {shortName = "ULDIR", fileName = "uldir"},
	[1754] = {shortName = "FH", fileName = "freehold"},
	[1763] = {shortName = "AD", fileName = "ataldazar"},
	[1841] = {shortName = "UR", fileName = "theunderrot"},
	[1862] = {shortName = "WM", fileName = "waycrestmanor"},
	[1877] = {shortName = "TOS", fileName = "templeofsethraliss"},
	[1594] = {shortName = "ML", fileName = "themotherlode"},
	[1762] = {shortName = "KR", fileName = "kingsrest"},
	[1864] = {shortName = "SOTS", fileName = "shrineofthestorm"},
	[1771] = {shortName = "TD", fileName = "toldagor"},
	[1822] = {shortName = "SOB", fileName = "siegeofboralus"},
	[2070] = {shortName = "BOD", fileName = "battleofdazaralor"},
	[2096] = {shortName = "COS", fileName = "crucibleofstorms"},
	[2164] = {shortName = "EP", fileName = "eternalpalace"},
	[2097] = {shortName = "MECH", fileName = "mechagon"},
	[2217] = {shortName = "NYA", fileName = "nyalotha"},
	
	--SHADOWLANDS
	[2289] = {shortName = "PF", fileName = "plaguefall"},
	[2291] = {shortName = "DOS", fileName = "theotherside"},
	[2287] = {shortName = "HOA", fileName = "hallsofatonement"},
	[2290] = {shortName = "MOTS", fileName = "mistsoftirnascithe"},
	[2284] = {shortName = "SD", fileName = "sanguinedepths"},
	[2285] = {shortName = "SOA", fileName = "spiresofascension"},
	[2286] = {shortName = "NW", fileName = "necroticwake"},
	[2293] = {shortName = "TOP", fileName = "theaterofpain"},
	[2296] = {shortName = "CN", fileName = "castlenathria"},
	[2441] = {shortName = "TAZA", fileName = "tazaveshtheveiledmarket"},
	[2450] = {shortName = "SOD", fileName = "sanctumofdomination"},
	[2481] = {shortName = "SFO", fileName = "sepulcherofthefirstones"},
	[2559] = {shortName = "WORLD", iconName = "shadowlands", bgName = "shadowlandscontinent",},

	--DRAGONFLIGHT
	[2451] = {shortName = "ULOT", fileName = "uldaman-legacyoftyr"},
	[2515] = {shortName = "AV", iconName = "arcanevaults", bgName = "azurevaults"},
	[2516] = {shortName = "NO", iconName = "centaurplains", bgName = "nokhudoffensive"},
	[2519] = {shortName = "NELT", fileName = "neltharus"},
	[2520] = {shortName = "BH", fileName = "brackenhidehollow"},
	[2521] = {shortName = "RLP", fileName = "lifepools"},
	[2526] = {shortName = "AA", fileName = "theacademy"},
	[2527] = {shortName = "HOI", fileName = "hallsofinfusion"},
	[2574] = {shortName = "WORLD", fileName = "dragonislescontinent",},
	[2579] = {shortName = "DOTI", fileName = "dawnoftheinfinite"},

	
	[2444] = {
		shortName = "WORLD", icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/dragonislescontinent.png", fileName = "dragonislescontinent",
	},
	[2549] = {
		bossIcons = {
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/gnarlroot.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/igira.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/volcoross.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/council.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/larodar.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/nymue.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/smolderon.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/tindral.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atdh/fyrakk.png"},
		},
		shortName = "ATDH",
		fileName = "emeralddream",
	},
	[2569] = { -- interface/icons/inv_achievement_raiddragon
		bossIcons = {
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/kazzara.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/chamber.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/experiment.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/assault.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/rashok.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/zskarn.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/magmorax.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/neltharion.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/atsc/sarkareth.png"},
		},
		shortName = "ATSC",
		fileName = "aberrus",
	},
	[2522] = {
		bossIcons = {
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/eranog.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/terros.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/council.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/sennarth.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/dathea.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/kurog.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/diurna.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/voti/raszageth.png"},
		},
		shortName = "VOTI",
		fileName = "vaultoftheincarnates",
	},

	-- THE WAR WITHIN
	[2601] = {shortName = "KA", fileName = "khazalgar"},
	[2648] = {shortName = "ROOK", fileName = "therookery"},
	[2649] = {shortName = "PSF", fileName = "prioryofthesacredflames"},
	[2651] = {shortName = "DFC", fileName = "darkflamecleft"},
	[2652] = {shortName = "SV", fileName = "thestonevault"},
	[2660] = {shortName = "AK", fileName = "arakaracityofechoes"},
	[2661] = {shortName = "CBM", fileName = "cinderbrewmeadery"},
	[2662] = {shortName = "DB", fileName = "thedawnbreaker"},
	[2669] = {shortName = "COT", fileName = "cityofthreads"},
	[2657] = {
		bossIcons = {
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/np/ulgrax.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/np/bloodboundhorror.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/np/sikran.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/np/rashanan.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/np/ovinax.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/np/kyveza.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/np/silkencourt.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/np/queenansurek.png"},
		},
		shortName = "NP",
		iconName = "nerubarpalance",
		bgName = "nerubarpalace",
	},

	[2769] = {
		bossIcons = {
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/lou/vexie.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/lou/carnage.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/lou/rik.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/lou/lockenstock.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/lou/stix.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/lou/bandit.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/lou/mugzee.png"},
			{icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/lou/gallywix.png"},
		},
		shortName = "LOU",
		iconName = "casino",
		bgName = "casino",
	},

	
	--interface/delves/110
	[2664] = {shortName = "FF", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "fungalfolly",},
	[2679] = {shortName = "MMC", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "mycomancercavern",},
	[2680] = {shortName = "ECM", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "earthcrawlmines",},
	[2681] = {shortName = "KR", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "kriegvalsrest",},
	[2682] = {shortName = "ZL", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "zekvirslair",},
	[2683] = {shortName = "WW", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "delve_waterworks",},
	[2684] = {shortName = "DP", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "dreadpit",},
	[2685] = {shortName = "SB", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "skitteringbreach",},
	[2686] = {shortName = "NFS", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "nightfallsanctum",},
	[2687] = {shortName = "SH", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "sinkhole",},
	[2688] = {shortName = "SW", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "spiralweave",},
	[2689] = {shortName = "TRA", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "takrethanabyss",},
	[2690] = {shortName = "UK", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "underkeep",},
	[2692] = {shortName = "HOA", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "hallofawakening",},
	[2710] = {shortName = "ATM", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "awakeningthemachine",},
	[2767] = {shortName = "SH", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "sinkhole",},
	[2768] = {shortName = "TRA", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "takrethanabyss",},

	--interface/delves/111
	[2815] = {shortName = "ES9", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "excavationsite9",},
	[2826] = {shortName = "SS", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "sidestreetsluice",},
	[2831] = {shortName = "UDC", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "underpinsdemolitioncompetition",},
	
	[2773] = {shortName = "OF", fileName = "waterworks"},
	[2774] = {shortName = "WORLD", fileName = "khazalgar",},
	[2776] = {shortName = "CODEX", fileName = "kalimdor",},
	[2792] = {shortName = "BRD", fileName = "blackrockdepths"},

	
	[2810] = {shortName = "MFO", fileName = "manaforgeomega"},
	[2827] = {shortName = "HVS", fileName = "horrificvisionstormwind"},
	[2828] = {shortName = "HVO", fileName = "horrificvisionorgrimmar"},
	[2830] = {shortName = "EDA", fileName = "ecodomealdani"},
	[2849] = {shortName = "DD", fileName = "dastardlydome"},
	[2872] = {shortName = "UM", fileName = "undermine"},
	[2951] = {shortName = "DD", fileName = "voidrazorsanctuary"},
}

miog.LFG_ID_INFO = {
	[1453] = { shortName = "TWMOP", icon = "interface/lfgframe/lfgicon-pandaria.blp", fileName = "pandaria"}, --RANDOM PANDARIA DUNGEON
	[1971] = {shortName = "RWD", icon = "interface/lfgframe/lfgicon-draenor.blp", fileName = "draenor"}, --RANDOM WARLORDS DUNGEON
	[2350] = { shortName = "LFDN", icon = "interface/lfgframe/lfgicon-dragonislescontinent.blp", fileName = "dragonislescontinent"},
	[2351] = { shortName = "LFDH", icon = "interface/lfgframe/lfgicon-dragonislescontinent.blp", fileName = "dragonislescontinent"},
	[2516] = { shortName = "LFTN", icon = "interface/lfgframe/lfgicon-khazalgar.blp", fileName = "khazalgar"},
	[2517] = { shortName = "LFTH", icon = "interface/lfgframe/lfgicon-khazalgar.blp", fileName = "khazalgar"},
	[2723] = { shortName = "LFTS1", icon = "interface/lfgframe/lfgicon-khazalgar.blp", fileName = "khazalgar"},
}

for k, v in pairs(miog.LFG_ID_INFO) do
	v.horizontal = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/" .. v.fileName .. ".png"
end

miog.GROUP_ACTIVITY = {  -- https://wago.tools/db2/GroupFinderActivityGrp
}

miog.ACTIVITY_INFO = {}

miog.SEASONAL_CHALLENGE_MODES = {
	[12] = {399, 400, 401, 402, 403, 404, 405, 406},
	[13] = {353, 375, 376, 501, 502, 503, 505, 507},
}

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

miog.ENCOUNTER_INFO = {
	
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


local function checkForMapAchievements(mapID)
	--[[local achievementCategory = miog.MAP_INFO[mapID].achievementCategory

	if(achievementCategory and not miog.MAP_INFO[mapID].achievementTable) then
		miog.MAP_INFO[mapID].achievementTable = {}

		for i = 1, GetCategoryNumAchievements(achievementCategory), 1 do
			local id, name = GetAchievementInfo(achievementCategory, i)

			if(miog.fzy.has_match(miog.MAP_INFO[mapID].name, name)) then
				table.insert(miog.MAP_INFO[mapID].achievementTable, id)

				for x, y in ipairs(miog.MAP_INFO[mapID].bosses) do
					if(string.find(name, y.name)) then
						table.insert(y.achievements, id)

					end
				end
			end
		end
	end]]

	local mapInfo = miog.MAP_INFO[mapID]
	local achievementCategory = mapInfo.achievementCategory

	if achievementCategory and not mapInfo.achievementTable then
		local achievementTable = {}
		local bosses = mapInfo.bosses
		mapInfo.achievementTable = achievementTable

		local numAchievements = GetCategoryNumAchievements(achievementCategory)

		for i = 1, numAchievements do
			local id, name = GetAchievementInfo(achievementCategory, i)

			if miog.fzy.has_match(mapInfo.name, name) then
				achievementTable[#achievementTable + 1] = id

				for _, boss in ipairs(bosses) do
					if string.find(name, boss.name, 1, true) then
						boss.achievements[#boss.achievements + 1] = id
					end
				end
			end
		end
	end
end

miog.checkForMapAchievements = checkForMapAchievements

local function checkJournalInstanceIDForNewData(journalInstanceID)
	EJ_SelectInstance(journalInstanceID)
    local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(journalInstanceID);

	miog.MAP_INFO[mapID].isRaid = EJ_InstanceIsRaid()

	local counter = 1

	local bossName, _, journalEncounterID, _, _, _, dungeonEncounterID = EJ_GetEncounterInfoByIndex(counter, journalInstanceID);

	while(bossName) do
		local id, name2, _, displayInfo, iconImage, _ = EJ_GetCreatureInfo(1, journalEncounterID) --always get first creature (boss)
		
		miog.MAP_INFO[mapID].bosses[counter] = {
			name = bossName,
			altName = name2,
			journalEncounterID = journalEncounterID,
			journalInstanceID = journalInstanceID,
			dungeonEncounterID = dungeonEncounterID,
			mapID = mapID,
			orderIndex = id,
			achievements = {},
			id = id,
			creatureDisplayInfoID = displayInfo,
			--icon = miog.MAP_INFO[mapID].bossIcons and miog.MAP_INFO[mapID].bossIcons[counter].icon or iconImage
		}

		miog.ENCOUNTER_INFO[journalEncounterID] = {index = counter, creatureDisplayInfoID = displayInfo}

		counter = counter + 1
		bossName, _, journalEncounterID, _ = EJ_GetEncounterInfoByIndex(counter, journalInstanceID);
	end

	return miog.MAP_INFO[mapID]
end

miog.checkJournalInstanceIDForNewData = checkJournalInstanceIDForNewData

local function checkSingleMapIDForNewData(mapID, selectInstance)
	if(mapID and mapID > 0 and miog.MAP_INFO[mapID]) then
		local bossIndex = 1
		local journalInstanceID = miog.MAP_INFO[mapID].journalInstanceID

		local bossName, _, journalEncounterID, _, _, _, dungeonEncounterID, _ = EJ_GetEncounterInfoByIndex(bossIndex, journalInstanceID)

		if(not bossName) then
			if(selectInstance) then
				EJ_SelectInstance(journalInstanceID or C_EncounterJournal.GetInstanceForGameMap(mapID))
				miog.MAP_INFO[mapID].isRaid = EJ_InstanceIsRaid()

			end

			bossName, _, journalEncounterID, _, _, _, dungeonEncounterID, _ = EJ_GetEncounterInfoByIndex(bossIndex);
		end

		if(miog.MAP_INFO[mapID].numOfBosses == 0) then
			while bossName do
				local id, name2, _, displayInfo, iconImage, _ = EJ_GetCreatureInfo(1, journalEncounterID) --always get first creature (boss)
				
				miog.MAP_INFO[mapID].bosses[bossIndex] = {
					name = bossName,
					altName = name2,
					journalEncounterID = journalEncounterID,
					journalInstanceID = journalInstanceID,
					dungeonEncounterID = dungeonEncounterID,
					mapID = mapID,
					orderIndex = id,
					achievements = {},
					id = id,
					creatureDisplayInfoID = displayInfo,
					icon = miog.MAP_INFO[mapID].bossIcons and miog.MAP_INFO[mapID].bossIcons[bossIndex].icon or iconImage
				}

				miog.ENCOUNTER_INFO[journalEncounterID] = {index = bossIndex, creatureDisplayInfoID = displayInfo, bossInfo = miog.MAP_INFO[mapID].bosses[bossIndex]}

				bossIndex = bossIndex + 1;
				bossName, _, journalEncounterID, _, _, journalInstanceID, dungeonEncounterID, _ = EJ_GetEncounterInfoByIndex(bossIndex, journalInstanceID);
			end

			miog.MAP_INFO[mapID].numOfBosses = bossIndex - 1
		end
	end
end

local function checkForNewEncounterInfo(journalEncounterID)
	local _, _, _, _, _, journalInstanceID = EJ_GetEncounterInfo(journalEncounterID)
	local _, _, _, _, _, _, _, _, _, mapID = EJ_GetInstanceInfo(journalInstanceID)

	checkSingleMapIDForNewData(mapID, true)

	return miog.ENCOUNTER_INFO[journalEncounterID]
end

local function getEncounterInfo(journalEncounterID)
	if(journalEncounterID) then
		return miog.ENCOUNTER_INFO[journalEncounterID] or checkForNewEncounterInfo(journalEncounterID)

	end
end

miog.getEncounterInfo = getEncounterInfo

local function requestMapInfo(mapID, selectInstance)
	if(mapID) then
		checkSingleMapIDForNewData(mapID, selectInstance)

		return miog.MAP_INFO[mapID]
	end
end

local function getMapInfo(mapID, selectInstance)
	return not selectInstance and miog.MAP_INFO[mapID] or requestMapInfo(mapID, selectInstance)
end

miog.getMapInfo = getMapInfo

local function getJournalInstanceInfo(journalInstanceID)
	if(journalInstanceID) then
    	local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(journalInstanceID);
		
		return miog.MAP_INFO[mapID] or getMapInfo(mapID, true)
	end
end

miog.getJournalInstanceInfo = getJournalInstanceInfo

miog.CHALLENGE_MODE_INFO = {}

miog.checkSingleMapIDForNewData = checkSingleMapIDForNewData

miog.PVP_BRACKET_INFO = {
	{id = 7, alias = PVP_RATED_SOLO_SHUFFLE, shortName = "Solo", fileName = "tolvirarena", pathName = "Interface/GLUES/LOADINGSCREENS/LoadScreenTolvirArena.blp"}, --Solo Arena
	{id = 9, alias = PVP_RATED_BG_BLITZ, shortName = "Solo BG", fileName = "twinpeaksbg", pathName = "Interface/GLUES/LOADINGSCREENS/LoadScreenTwinPeaksBG.blp"}, --Solo BG
	{id = 1, alias = ARENA_2V2, shortName = ARENA_2V2, fileName = "enigmaarena", pathName = "Interface/GLUES/LOADINGSCREENS/Expansion08/Main/LoadScreen_EnigmaArena.blp"}, --2v2
	{id = 2, alias = ARENA_3V3, shortName = ARENA_3V3, fileName = "blackrookholdarena", pathName = "Interface/GLUES/LOADINGSCREENS/LoadingScreen_BlackrookHoldArena_wide.blp"}, --3v3
	--{id = 3, alias = ARENA_5V5, shortName = ARENA_5V5, fileName = "maldraxxuscoliseum", pathName = "Interface/GLUES/LOADINGSCREENS/Expansion08/Main/LoadScreen_MaldraxxusColiseum.blp"}, --5v5
	{id = 4, alias = BATTLEGROUND_10V10, shortName = BATTLEGROUND_10V10, fileName = "earthenbattleground", pathName = "Interface/GLUES/LOADINGSCREENS/Expansion10/Main/Loadscreen_EarthenBattleground.blp"}, --10v10

}

miog.PVP_BRACKET_IDS_TO_INFO = {}

for k, v in ipairs(miog.PVP_BRACKET_INFO) do
	miog.PVP_BRACKET_IDS_TO_INFO[v.id] = v
end

miog.CUSTOM_CATEGORY_ORDER = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 121,
	[5] = 4,
	[6] = 7,
	[7] = 9,
	[8] = 8,
	[9] = 6,
}

miog.BACKUP_SEASONAL_IDS = {
	[2] = {
		322,
		324,
		325,
		327,
		371,
		266,
		140,
		257,
	},
	[3] = {
		362,
		377,
	}
}


local function addMapDataToGroup(mapID, groupID)
	local mapInfo = miog.MAP_INFO[mapID]

	if(mapInfo) then
		miog.GROUP_ACTIVITY[groupID].icon = mapInfo.icon
		miog.GROUP_ACTIVITY[groupID].bosses = mapInfo.bosses
		miog.GROUP_ACTIVITY[groupID].journalInstanceID = mapInfo.journalInstanceID

		miog.GROUP_ACTIVITY[groupID].mapName = mapInfo.name
		miog.GROUP_ACTIVITY[groupID].expansionLevel = mapInfo.expansionLevel

		miog.GROUP_ACTIVITY[groupID].vertical = mapInfo.vertical
		miog.GROUP_ACTIVITY[groupID].horizontal = mapInfo.horizontal
	end
end

local function addMapDataToActivity(mapID, activityID)
	local mapInfo = miog.MAP_INFO[mapID]

	if(mapInfo) then
		miog.ACTIVITY_INFO[activityID].icon = mapInfo.icon
		miog.ACTIVITY_INFO[activityID].bosses = mapInfo.bosses
		miog.ACTIVITY_INFO[activityID].journalInstanceID = mapInfo.journalInstanceID

		miog.ACTIVITY_INFO[activityID].mapName = mapInfo.name
		miog.ACTIVITY_INFO[activityID].expansionLevel = mapInfo.expansionLevel

		miog.ACTIVITY_INFO[activityID].vertical = mapInfo.vertical
		miog.ACTIVITY_INFO[activityID].horizontal = mapInfo.horizontal
	end
end

local function addActivityInfo(activityID)
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

	if(activityInfo) then
		activityInfo.abbreviatedName = miog.MAP_INFO[activityInfo.mapID] and miog.MAP_INFO[activityInfo.mapID].shortName
		activityInfo.journalInstanceID = miog.MAP_INFO[activityInfo.mapID] and miog.MAP_INFO[activityInfo.mapID].journalInstanceID

		miog.ACTIVITY_INFO[activityID] = activityInfo

		if(activityInfo.groupFinderActivityGroupID and activityInfo.groupFinderActivityGroupID > 0) then
			miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].abbreviatedName = activityInfo.abbreviatedName
			miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].mapID = activityInfo.mapID

		end
		
		if(activityInfo.mapID ~= 0) then
			addMapDataToActivity(activityInfo.mapID, activityID)

		end
	end

	return miog.ACTIVITY_INFO[activityID]
end

local function addGroupInfo(groupID, categoryID)
	miog.GROUP_ACTIVITY[groupID] = {activityIDs = {}}

	local activities = C_LFGList.GetAvailableActivities(categoryID, groupID)

	for k, v in ipairs(activities) do
		tinsert(miog.GROUP_ACTIVITY[groupID].activityIDs, v)

		if(not miog.ACTIVITY_INFO[v]) then
			addActivityInfo(v)

		end
	end

	if(miog.GROUP_ACTIVITY[groupID].mapID) then
		addMapDataToGroup(miog.GROUP_ACTIVITY[groupID].mapID, groupID)

	end

	miog.GROUP_ACTIVITY[groupID].highestDifficultyActivityID = miog.GROUP_ACTIVITY[groupID].activityIDs[#miog.GROUP_ACTIVITY[groupID].activityIDs]

	return miog.GROUP_ACTIVITY[groupID]
end

local function addActivityAndGroupInfo(activityID, groupID, categoryID)
	if(activityID and not miog.ACTIVITY_INFO[activityID]) then
		local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

		if(activityInfo) then
			activityInfo.abbreviatedName = miog.MAP_INFO[activityInfo.mapID] and miog.MAP_INFO[activityInfo.mapID].shortName
			activityInfo.journalInstanceID = miog.MAP_INFO[activityInfo.mapID] and miog.MAP_INFO[activityInfo.mapID].journalInstanceID

			miog.ACTIVITY_INFO[activityID] = activityInfo

			if(activityInfo.groupFinderActivityGroupID and activityInfo.groupFinderActivityGroupID > 0) then
				if(not miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID]) then
					addGroupInfo(activityInfo.groupFinderActivityGroupID)
				end

				miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].abbreviatedName = activityInfo.abbreviatedName
				miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID].mapID = activityInfo.mapID

			end
			
			if(activityInfo.mapID ~= 0) then
				addMapDataToActivity(activityInfo.mapID, activityID)

			end
		end
	end

	if(groupID and not miog.GROUP_ACTIVITY[groupID]) then
		miog.GROUP_ACTIVITY[groupID] = {activityIDs = {}}

		local activities = C_LFGList.GetAvailableActivities(categoryID, groupID)

		for k, v in ipairs(activities) do
			tinsert(miog.GROUP_ACTIVITY[groupID].activityIDs, v)

			if(not miog.ACTIVITY_INFO[v]) then
				addActivityInfo(v)

			end
		end

		if(miog.GROUP_ACTIVITY[groupID].mapID) then
			addMapDataToGroup(miog.GROUP_ACTIVITY[groupID].mapID, groupID)

		end

		miog.GROUP_ACTIVITY[groupID].highestDifficultyActivityID = miog.GROUP_ACTIVITY[groupID].activityIDs[#miog.GROUP_ACTIVITY[groupID].activityIDs]

	end
end

local function requestActivityInfo(activityID)
	if(not miog.ACTIVITY_INFO[activityID]) then
		addActivityAndGroupInfo(activityID)
		
	else
		local activityInfo = miog.ACTIVITY_INFO[activityID]

		if(not miog.GROUP_ACTIVITY[activityInfo.groupFinderActivityGroupID]) then
			addActivityAndGroupInfo(activityID, activityInfo.groupFinderActivityGroupID)

		end
	end

	return miog.ACTIVITY_INFO[activityID]
end

miog.requestActivityInfo = requestActivityInfo

local function requestGroupInfo(groupID)
	return miog.GROUP_ACTIVITY[groupID] or addGroupInfo(groupID)

end

miog.requestGroupInfo = requestGroupInfo

local function loadGroupData()
	for categoryIndex, categoryID in pairs(miog.CUSTOM_CATEGORY_ORDER) do
		for groupIndex, groupID in pairs(C_LFGList.GetAvailableActivityGroups(categoryID)) do
			addGroupInfo(groupID, categoryID)
		end
	end
end

local function loadRawData()
	local loadHQData = miog.isMIOGHQLoaded()

	for k, v in pairs(miog.PVP_BRACKET_INFO) do
		if(loadHQData) then
			v.vertical = MythicIO.GetBackgroundImage(v.fileName, true)
			
		else
			v.vertical = v.pathName
			
		end

	end

	for k, v in pairs(miog.RAW["Map"]) do
		miog.MAP_INFO[v[1]] = miog.MAP_INFO[v[1]] or {}

		local mapInfo = miog.MAP_INFO[v[1]]

		mapInfo.name = v[3]
		mapInfo.expansionLevel = v[12]
		mapInfo.bosses = {}
		mapInfo.numOfBosses = 0
		mapInfo.journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(v[1])

		local background = mapInfo.bgName or mapInfo.fileName
		
		if(background) then
			if(loadHQData) then
				mapInfo.horizontal = MythicIO.GetBackgroundImage(background)
				mapInfo.vertical = MythicIO.GetBackgroundImage(background, true)
				
			elseif(mapInfo.pvp) then
				mapInfo.horizontal = "interface/addons/mythiciograbber/res/backgrounds/pvpbackgrounds/" .. background .. ".png"
				mapInfo.vertical = "interface/addons/mythiciograbber/res/backgrounds/pvpbackgrounds/" .. background .. ".png"
				
			else
				mapInfo.horizontal = "interface/lfgframe/ui-lfg-background-" .. background .. ".blp"
				mapInfo.vertical = "interface/lfgframe/ui-lfg-background-" .. background .. ".blp"

			end

			mapInfo.icon = "interface/lfgframe/lfgicon-" .. (mapInfo.iconName or mapInfo.fileName) .. ".blp"
		end
	end

	for k, v in pairs(miog.RAW["MapChallengeMode"]) do
		if(miog.MAP_INFO[v[3]]) then
			miog.MAP_INFO[v[3]].challengeModeID = v[2]

		end

		miog.CHALLENGE_MODE_INFO[v[2]] = {
			name = v[1],
			mapID = v[3],
			expansionLevel = v[5],
		}
	end
	
	--loadActivitiesData()
	loadGroupData()
end

miog.loadRawData = loadRawData

miog.MAP_INFO[2522].achievementCategory = 15469 --VOTI
miog.MAP_INFO[2522].achievementsAwakened = {19564, 19565, 19566}

miog.MAP_INFO[2549].achievementCategory = 15469 --ATDH
miog.MAP_INFO[2549].achievementsAwakened = {19570, 19571, 19572}

miog.MAP_INFO[2569].achievementCategory = 15469 --ATSC
miog.MAP_INFO[2569].achievementsAwakened = {19567, 19568, 19569}

miog.MAP_INFO[2657].achievementCategory = 15520 --NP

miog.MAP_INFO[2769].achievementCategory = 15520 --LOU

miog.TELEPORT_FLYOUT_IDS = {
	[1] = {id = 230, expansion = 3, type="dungeon"},
	[2] = {id = 84, expansion = 4, type="dungeon"},
	[3] = {id = 96, expansion = 5, type="dungeon"},
	[4] = {id = 224, expansion = 6, type="dungeon"},
	[5] = {id = 223, expansion = 7, type="dungeon"},

	[6] = {id = 220, expansion = 8, type="dungeon"},
	[7] = {id = 222, expansion = 8, type="raid"},

	[8] = {id = 227, expansion = 9, type="dungeon"},
	[9] = {id = 231, expansion = 9, type="raid"},

	[10] = {id = 232, expansion = 10, type="dungeon"},
	[11] = {id = 242, expansion = 10, type="raid"},
}

miog.TELEPORT_SPELLS_TO_MAP = {
	[445424] = 670,
	[410080] = 657,
	[424142] = 643,

	[131225] = 962,
	[131222] = 1008,
	[131231] = 1001,
	[131229] = 1004,
	[131232] = 1007,
	[131206] = 959,
	[131228] = 1011,
	[131205] = 961,
	[131204] = 960,

	[159897] = 1182,
	[159895] = 1175,
	[159900] = 1208,
	[159901] = 1279,
	[159896] = 1195,
	[159899] = 1176,
	[159898] = 1209,
	[159902] = 1358,

	[424153] = 1501,
	[393766] = 1571,
	[424163] = 1466,
	[393764] = 1477,
	[373262] = 1651,
	[410078] = 1458,

	[424187] = 1763,
	[410071] = 1754,
	[373274] = 2097,
	[464256] = 1822,
	[445418] = 1822,
	[467555] = 1594,
	[467553] = 1594,
	[410074] = 1841,
	[424167] = 1862,

	[354468] = 2291,
	[354465] = 2287,
	[354464] = 2290,
	[354463] = 2289,
	[354469] = 2284,
	[354466] = 2285,
	[367416] = 2441,
	[354462] = 2286,
	[354467] = 2293,
	[373190] = 2296,
	[373191] = 2450,
	[373192] = 2481,

	[393273] = 2526,
	[393267] = 2520,
	[424197] = 2579,
	[393283] = 2527,
	[393276] = 2519,
	[393256] = 2521,
	[393279] = 2515,
	[393262] = 2516,
	[393222] = 2451,
	[432257] = 2569,
	[432258] = 2549,
	[432254] = 2522,

	[445417] = 2660,
	[445440] = 2661,
	[445416] = 2669,
	[445441] = 2651,
	[1216786] = 2773,
	[445444] = 2649,
	[445414] = 2662,
	[445443] = 2648,
	[445269] = 2652,
	[1226482] = 2769,
}

miog.WEIGHTS_TABLE = {
	[1] = 10000,
	[2] = 100,
	[3] = 1,
}

miog.ITEM_LEVEL_JUMPS = {
	3, 3, 3, 4
}

miog.BASE_ITEM_TRACK_INFO = {
	[1] = {length = 8},
	[2] = {length = 8},
	[3] = {length = 8},
	[4] = {length = 8},
	[5] = {length = 6},
	[6] = {length = 4},
}

miog.GEARING_CHART = {
	[12] = {
		maxJumps = 0,
		baseItemLevel = 454,
		maxItemLevel = 535,
		dungeon = {
			info = {
				[1] = {jumps = 2, name="Normal"},
				[2] = {jumps = 7, name="Heroic/TW"},
				[3] = {jumps = 12, name="Mythic"},
				[4] = {jumps = 13, name="+2"},
				[5] = {jumps = 14, name="+3"},
				[6] = {jumps = 14, name="+4"},
				[7] = {jumps = 15, name="+5"},
				[8] = {jumps = 15, name="+6"},
				[9] = {jumps = 16, name="+7"},
				[10] = {jumps = 16, name="+8"},
				[11] = {jumps = 17, name="+9"},
				[12] = {jumps = 17, name="+10"},
			},
			itemLevels = {

			},
			vaultJumpsOffset = 4,
			vaultLevels = {

			},
		},
		raid = {
			info = {
				[1] = {jumps = 8, name="LFR"},
				[2] = {jumps = 12, name="Normal"},
				[3] = {jumps = 16, name="Heroic"},
				[4] = {jumps = 20, name="Mythic"},
			},
			itemLevels = {

			},
		},
		other = {
			info = {
				[1] = {jumps = 19, name="Wyrm5"},
				[2] = {jumps = 22, name="Aspect5"},
			},
			itemLevels = {

			},
		},
		awakenedInfo = {
			start = "normal",
			maxLength = 14,
		},
		trackInfo = {
			[1] = {name = "Explorer", length = 8},
			[2] = {name = "Adventurer", length = 8},
			[3] = {name = "Veteran", length = 8},
			[4] = {name = "Champion", length = 8},
			[5] = {name = "Hero", length = 6},
			[6] = {name = "Myth", length = 4},
		},
		itemLevelInfo = {

		}
	},

	
	[13] = {
		maxJumps = 0,
		baseItemLevel = 558,
		maxItemLevel = 639,
		dungeon = {
			info = {
				[1] = {jumps = -1, name="Normal", ignoreForVault=true},
				[2] = {jumps = 4, name="Heroic/TW"},
				[3] = {jumps = 11, vaultOffset = 3, name="Mythic"},
				[4] = {jumps = 12, vaultOffset = 3, name="+2"},
				[5] = {jumps = 12, name="+3"},
				[6] = {jumps = 13, vaultOffset = 3, name="+4"},
				[7] = {jumps = 14, vaultOffset = 3, name="+5"},
				[8] = {jumps = 15, vaultOffset = 2, name="+6"},
				[9] = {jumps = 16, vaultOffset = 2, name="+7"},
				[10] = {jumps = 16, vaultOffset = 3, name="+8"},
				[11] = {jumps = 17, vaultOffset = 2, name="+9"},
				[12] = {jumps = 17, vaultOffset = 3, name="+10"},
			},
			itemLevels = {

			},
			vaultJumpsOffset = 4,
			vaultLevels = {

			},
		},
		raid = {
			info = {
				[1] = {jumps = 8, name="LFR"},
				[2] = {jumps = 12, name="Normal"},
				[3] = {jumps = 16, name="Heroic"},
				[4] = {jumps = 20, name="Mythic"},
			},
			itemLevels = {

			},
			veryRare = {
				info = {
					[1] = {jumps = 13, name="Rare LFR"},
					[2] = {jumps = 17, name="Rare Normal"},
					[3] = {jumps = 21, name="Rare Heroic"},
					[4] = {jumps = 25, name="Rare Mythic"},
				},
				itemLevels = {
	
				},
			}
		},
		delves = {
			info = {
				[1] = {jumps = 1, vaultOffset = 7, name="L1"},
				[2] = {jumps = 2, vaultOffset = 6, name="L2"},
				[3] = {jumps = 4, vaultOffset = 5, name="L3"},
				[4] = {jumps = 6, vaultOffset = 6, name="L4"},
				[5] = {jumps = 8, vaultOffset = 6, name="L5"},
				[6] = {jumps = 10, vaultOffset = 5, name="L6"},
				[7] = {jumps = 12, vaultOffset = 4, name="L7"},
				[8] = {jumps = 14, vaultOffset = 4, name="L8"},
			},
			itemLevels = {

			},
			vaultJumpsOffset = 4,
			vaultLevels = {

			},
		},
		other = {
			info = {
				[1] = {jumps = 12, name="Spark5"},
				[2] = {jumps = 19, name="Runed5"},
				[3] = {jumps = 24, name="Gilded5"},
			},
			itemLevels = {

			},
		},
		trackStartJumpsOffset = 4,
		trackInfo = {
			[1] = {name = "Explorer", length = 8},
			[2] = {name = "Adventurer", length = 8},
			[3] = {name = "Veteran", length = 8},
			[4] = {name = "Champion", length = 8},
			[5] = {name = "Hero", length = 6},
			[6] = {name = "Myth", length = 6},
		},
		itemLevelInfo = {

		}
	},

	[14] = {
		maxJumps = 0,
		baseItemLevel = 597,
		maxItemLevel = 684,
		dungeon = {
			info = {
				[1] = {jumps = -1, name="Normal", ignoreForVault=true},
				[2] = {jumps = 7, name="Heroic/TW"},
				[3] = {jumps = 12, vaultOffset = 3, name="Mythic"},
				[4] = {jumps = 13, vaultOffset = 3, name="+2"},
				[5] = {jumps = 13, vaultOffset = 3, name="+3"},
				[6] = {jumps = 14, vaultOffset = 3, name="+4"},
				[7] = {jumps = 15, vaultOffset = 2, name="+5"},
				[8] = {jumps = 16, vaultOffset = 2, name="+6"},
				[9] = {jumps = 16, vaultOffset = 3, name="+7"},
				[10] = {jumps = 17, vaultOffset = 2, name="+8"},
				[11] = {jumps = 17, vaultOffset = 2, name="+9"},
				[12] = {jumps = 18, vaultOffset = 2, name="+10"},
			},
			itemLevels = {

			},
			vaultJumpsOffset = 4,
			vaultLevels = {

			},
		},
		raid = {
			info = {
				[1] = {jumps = 8, name="LFR"},
				[2] = {jumps = 12, name="Normal"},
				[3] = {jumps = 16, name="Heroic"},
				[4] = {jumps = 20, name="Mythic"},
			},
			itemLevels = {

			},
			veryRare = {
				info = {
					[1] = {jumps = 13, name="Rare LFR"},
					[2] = {jumps = 17, name="Rare Normal"},
					[3] = {jumps = 21, name="Rare Heroic"},
					[4] = {jumps = 25, name="Rare Mythic"},
				},
				itemLevels = {
	
				},
			}
		},
		delves = {
			info = {
				[1] = {jumps = 1, vaultOffset = 7, name="L1"},
				[2] = {jumps = 2, vaultOffset = 6, name="L2"},
				[3] = {jumps = 4, vaultOffset = 5, name="L3"},
				[4] = {jumps = 6, vaultOffset = 6, name="L4"},
				[5] = {jumps = 8, vaultOffset = 6, name="L5"},
				[6] = {jumps = 10, vaultOffset = 5, name="L6"},
				[7] = {jumps = 12, vaultOffset = 4, name="L7"},
			},
			itemLevels = {

			},
			vaultJumpsOffset = 4,
			vaultLevels = {

			},
		},
		other = {
			info = {
				[1] = {jumps = 12, name="Spark5"},
				[2] = {jumps = 19, name="Runed5"},
				[3] = {jumps = 24, name="Gilded5"},
			},
			itemLevels = {

			},
		},
		trackStartJumpsOffset = 4,
		trackInfo = {
			[1] = {name = "Explorer", length = 8},
			[2] = {name = "Adventurer", length = 8},
			[3] = {name = "Veteran", length = 8},
			[4] = {name = "Champion", length = 8},
			[5] = {name = "Hero", length = 6},
			[6] = {name = "Myth", length = 6},
		},
		itemLevelInfo = {

		}
	},
}

local fullStep = 13
local quarterSteps = {
	3, 3, 3, 4
}

miog.ITEM_LEVEL_DATA = {
	[14] = {
		referenceMinLevel = 597,
		referenceMinLevelStepIndex = 1,
		referenceMaxLevel = 678,
		revisedMaxLevel = 684,

		itemLevelList = {},

		tracks = {
			[1] = {name = "Explorer", length = 8},
			[2] = {name = "Adventurer", length = 8},
			[3] = {name = "Veteran", length = 8},
			[4] = {name = "Champion", length = 8},
			[5] = {name = "Hero", length = 6, revisedLength = 8},
			[6] = {name = "Myth", length = 6, revisedLength = 8},

		},

		data = {
			dungeon = {
				[1] = {steps = -1, name="Normal", ignoreForVault=true},
				[2] = {steps = 7, vaultOffset = 4, name="Heroic/TW"},
				[3] = {steps = 12, vaultOffset = 3, name="Mythic"},
				[4] = {steps = 13, vaultOffset = 3, name="+2"},
				[5] = {steps = 13, vaultOffset = 3, name="+3"},
				[6] = {steps = 14, vaultOffset = 3, name="+4"},
				[7] = {steps = 15, vaultOffset = 2, name="+5"},
				[8] = {steps = 16, vaultOffset = 2, name="+6"},
				[9] = {steps = 16, vaultOffset = 3, name="+7"},
				[10] = {steps = 17, vaultOffset = 2, name="+8"},
				[11] = {steps = 17, vaultOffset = 2, name="+9"},
				[12] = {steps = 18, vaultOffset = 2, name="+10"},
			},
			raid = {
				[1] = {steps = 8, name="LFR"},
				[2] = {steps = 12, name="Normal"},
				[3] = {steps = 16, name="Heroic"},
				[4] = {steps = 20, name="Mythic"},

			},
			raidVeryRare = {
				[1] = {steps = 13, name="Rare LFR"},
				[2] = {steps = 17, name="Rare Normal"},
				[3] = {steps = 21, name="Rare Heroic"},
				[4] = {steps = 25, name="Rare Mythic"},
			},
			delves = {
				[1] = {steps = 4, vaultOffset = 4, name="T1"},
				[2] = {steps = 5, vaultOffset = 3, name="T2"},
				[3] = {steps = 6, vaultOffset = 3, name="T3"},
				[4] = {steps = 7, vaultOffset = 5, name="T4"},
				[5] = {steps = 8, vaultOffset = 6, name="T5"},
				[6] = {steps = 9, vaultOffset = 6, name="T6"},
				[7] = {steps = 12, vaultOffset = 4, name="T7+"},
			},
			delvesBountiful = {
				[1] = {steps = 9, name="T4B"},
				[2] = {steps = 11, name="T5B"},
				[3] = {steps = 13, name="T6B"},
				[4] = {steps = 15, name="T7B"},
				[5] = {steps = 16, name="T8B+"},
			},
			crafting = {
				{steps = 10, name="EnchWeather5"},
				{steps = 15, name="Spark5"},
				{steps = 19, name="Runed5"},
				{steps = 21, name="Runed5+Matrix"},
				{steps = 24, name="Gilded5"},
				{steps = 26, name="Gilded5+Matrix"},
			},
		},
	},
	[15] = {
		referenceMinLevel = 642,
		referenceMinLevelStepIndex = 3,
		referenceMaxLevel = 723,

		itemLevelList = {},

		tracks = {
			[1] = {name = "Explorer", length = 8},
			[2] = {name = "Adventurer", length = 8},
			[3] = {name = "Veteran", length = 8},
			[4] = {name = "Champion", length = 8},
			[5] = {name = "Hero", length = 6},
			[6] = {name = "Myth", length = 6},

		},

		data = {
			dungeon = {
				[1] = {steps = -1, name="Normal", ignoreForVault=true},
				[2] = {steps = 7, vaultOffset = 4, name="Heroic/TW"},
				[3] = {steps = 12, vaultOffset = 3, name="Mythic"},
				[4] = {steps = 13, vaultOffset = 3, name="+2"},
				[5] = {steps = 13, vaultOffset = 3, name="+3"},
				[6] = {steps = 14, vaultOffset = 3, name="+4"},
				[7] = {steps = 15, vaultOffset = 2, name="+5"},
				[8] = {steps = 16, vaultOffset = 2, name="+6"},
				[9] = {steps = 16, vaultOffset = 3, name="+7"},
				[10] = {steps = 17, vaultOffset = 2, name="+8"},
				[11] = {steps = 17, vaultOffset = 2, name="+9"},
				[12] = {steps = 18, vaultOffset = 2, name="+10"},
			},
			raid = {
				{steps = 9, name="LFR 1-3"},
				{steps = 10, name="LFR 4-6"},
				{steps = 11, name="LFR 7-8"},
				{steps = 13, name="Normal 1-3"},
				{steps = 14, name="Normal 4-6"},
				{steps = 15, name="Normal 7-8"},
				{steps = 17, name="Heroic 1-3"},
				{steps = 18, name="Heroic 4-6"},
				{steps = 19, name="Heroic 7-8"},
				{steps = 21, name="Mythic 1-3"},
				{steps = 22, name="Mythic 4-6"},
				{steps = 23, name="Mythic 7-8"},

			},
			raidVeryRare = {
				[1] = {steps = 13, name="Rare LFR"},
				[2] = {steps = 17, name="Rare Normal"},
				[3] = {steps = 21, name="Rare Heroic"},
				[4] = {steps = 25, name="Rare Mythic"},
			},
			delves = {
				[1] = {steps = 4, vaultOffset = 4, name="T1"},
				[2] = {steps = 5, vaultOffset = 4, name="T2"},
				[3] = {steps = 6, vaultOffset = 4, name="T3"},
				[4] = {steps = 7, vaultOffset = 4, name="T4"},
				[5] = {steps = 8, vaultOffset = 5, name="T5"},
				[6] = {steps = 9, vaultOffset = 5, name="T6"},
				[7] = {steps = 12, vaultOffset = 4, name="T7"},
				[8] = {steps = 13, vaultOffset = 3, name="T8+"},
			},
			delvesBounty = {
				[1] = {steps = 9, name="T4DB"},
				[2] = {steps = 11, name="T5DB"},
				[3] = {steps = 13, name="T6DB"},
				[4] = {steps = 15, name="T7DB"},
				[5] = {steps = 16, name="T8DB+"},
			},
			crafting = {
				{steps = 10, name="EnchWeather5"},
				{steps = 15, name="Spark5"},
				{steps = 19, name="Runed5"},
				{steps = 24, name="Gilded5"},
			},
		},
	},
}

local function getItemLevelForStepCount(steps, offset)
	local itemLevel = 0
	local isNegative = steps < 0
	local arrayIndex = offset or isNegative and 4 or 1

	if(steps ~= 0) then
		local stepCounter = 0

		if(isNegative) then
			for i = 0, steps + 1, -1 do
				itemLevel = itemLevel - quarterSteps[arrayIndex]

				arrayIndex = arrayIndex - 1
				stepCounter = stepCounter - 1

				if(stepCounter == steps) then
					break

				elseif(arrayIndex < 1) then
					arrayIndex = 4

				end
			end
		else
			for i = 0, steps - 1, 1 do
				itemLevel = itemLevel + quarterSteps[arrayIndex]

				arrayIndex = arrayIndex + 1
				stepCounter = stepCounter + 1

				if(stepCounter == steps) then
					break

				elseif(arrayIndex > 4) then
					arrayIndex = 1

				end
			end
		end
	end

	return itemLevel, arrayIndex
end

local function getItemLevelIncreaseViaSteps(steps, argIndex)
	--[[if(steps >= 4 and steps % 4 == 0) then
		return steps / 4 * fullStep, 0

	else
		local ilvl = 0
		local negative = steps < 0 and true or false
		local index = negative and 4 or 1
		local quarterIndex

		local forLoopLength = steps %

		for i = negative and -1 or argIndex and argIndex > 0 and argIndex or 1, steps, negative and -1 or 1 do
			if(negative) then
				ilvl = ilvl - quarterSteps[index]

				index = index - 1

				if(i == 0) then
					index = 4

				end
			else
				if(i%4 == 0) then
					index = 1
					
				end

				ilvl = ilvl + quarterSteps[index]

				index = index + 1
			end
		end

		return ilvl, index % 4
	end]]
end

for seasonID, seasonalData in pairs(miog.ITEM_LEVEL_DATA) do
	for trackIndex, data in ipairs(seasonalData.tracks) do
		data.itemlevels = {}

		data.minLevel = seasonalData.referenceMinLevel + (trackIndex - 1) * getItemLevelForStepCount(4, seasonalData.referenceMinLevelStepIndex)
		local level = getItemLevelForStepCount((data.revisedLength or data.length) - 1, seasonalData.referenceMinLevelStepIndex)
		data.maxLevel = data.minLevel + level

		for i = 1, data.revisedLength or data.length, 1 do
			local innerLevel = getItemLevelForStepCount(i - 1, seasonalData.referenceMinLevelStepIndex)
			data.itemlevels[i] = data.minLevel + innerLevel

		end
	end

	local usedItemlevels = {}

	for category, categoryData in pairs(seasonalData.data) do
		for index, ilvlData in ipairs(categoryData) do
			local level = getItemLevelForStepCount(ilvlData.steps, seasonalData.referenceMinLevelStepIndex)
			ilvlData.level = seasonalData.referenceMinLevel + level

			if(not usedItemlevels[ilvlData.level]) then
				tinsert(seasonalData.itemLevelList, ilvlData.level)

			end

			usedItemlevels[ilvlData.level] = true

			if(ilvlData.vaultOffset) then
				ilvlData.vaultLevel = seasonalData.referenceMinLevel + getItemLevelForStepCount(ilvlData.vaultOffset + ilvlData.steps, seasonalData.referenceMinLevelStepIndex)

				if(not usedItemlevels[ilvlData.vaultLevel]) then
					tinsert(seasonalData.itemLevelList, ilvlData.vaultLevel)

				end

				usedItemlevels[ilvlData.vaultLevel] = true
			end
		end
	end

	table.sort(seasonalData.itemLevelList, function(k1, k2)
		return k1 < k2

	end)
end

miog.NEW_GEARING_DATA = {
	[14] = {
		baseItemlevel = 597,
		maxItemlevel = 684, --was 678

		tracks = {
			[1] = {name = "Explorer", length = 8},
			[2] = {name = "Adventurer", length = 8},
			[3] = {name = "Veteran", length = 8},
			[4] = {name = "Champion", length = 8},
			[5] = {name = "Hero", length = 8}, --was 6
			[6] = {name = "Myth", length = 8}, --was 6

		},

		allItemlevels = {},
		usedItemlevels = {},

		dungeon = {
			info = {
				[1] = {jumps = -1, name="Normal", ignoreForVault=true},
				[2] = {jumps = 7, name="Heroic/TW"},
				[3] = {jumps = 12, vaultOffset = 3, name="Mythic"},
				[4] = {jumps = 13, vaultOffset = 3, name="+2"},
				[5] = {jumps = 13, vaultOffset = 3, name="+3"},
				[6] = {jumps = 14, vaultOffset = 3, name="+4"},
				[7] = {jumps = 15, vaultOffset = 2, name="+5"},
				[8] = {jumps = 16, vaultOffset = 2, name="+6"},
				[9] = {jumps = 16, vaultOffset = 3, name="+7"},
				[10] = {jumps = 17, vaultOffset = 2, name="+8"},
				[11] = {jumps = 17, vaultOffset = 2, name="+9"},
				[12] = {jumps = 18, vaultOffset = 2, name="+10"},
			},
			usedItemlevels = {

			},
			vault = {
				usedItemlevels = {
	
				},
				offset = 4,

			},
		},
		
		raid = {
			info = {
				[1] = {jumps = 8, name="LFR"},
				[2] = {jumps = 12, name="Normal"},
				[3] = {jumps = 16, name="Heroic"},
				[4] = {jumps = 20, name="Mythic"},
			},
			usedItemlevels = {

			},
			veryRare = {
				info = {
					[1] = {jumps = 13, name="Rare LFR"},
					[2] = {jumps = 17, name="Rare Normal"},
					[3] = {jumps = 21, name="Rare Heroic"},
					[4] = {jumps = 25, name="Rare Mythic"},
				},
				usedItemlevels = {
	
				},
			}
		},

		delves = {
			info = {
				[1] = {jumps = 4, vaultOffset = 4, name="T1"},
				[2] = {jumps = 5, vaultOffset = 3, name="T2"},
				[3] = {jumps = 6, vaultOffset = 3, name="T3"},
				[4] = {jumps = 7, vaultOffset = 5, name="T4"},
				[5] = {jumps = 8, vaultOffset = 6, name="T5"},
				[6] = {jumps = 9, vaultOffset = 6, name="T6"},
				[7] = {jumps = 12, vaultOffset = 4, name="T7+"},
			},
			usedItemlevels = {

			},
			bountiful = {
				info = {
					[1] = {jumps = 9, name="T4B"},
					[2] = {jumps = 11, name="T5B"},
					[3] = {jumps = 13, name="T6B"},
					[4] = {jumps = 15, name="T7B"},
					[5] = {jumps = 16, name="T8B+"},
				},
				usedItemlevels = {
	
				},
			},
			vault = {
				usedItemlevels = {
	
				},
				offset = 4,

			},
		},

		other = {
			info = {
				--{jumps = 6, name="EnchWeather1"},
				--{jumps = 7, name="EnchWeather2"},
				--{jumps = 8, name="EnchWeather3"},
				--{jumps = 9, name="EnchWeather4"},
				{jumps = 10, name="EnchWeather5"},
				--{jumps = 11, name="Spark1"},
				--{jumps = 12, name="Spark2"},
				--{jumps = 13, name="Spark3"},
				--{jumps = 14, name="Spark4"},
				{jumps = 15, name="Spark5"},
				--{jumps = 15, name="Runed1"},
				--{jumps = 16, name="Runed2"},
				--{jumps = 17, name="Runed3"},
				--{jumps = 18, name="Runed4"},
				{jumps = 19, name="Runed5"},
				--{jumps = 20, name="Gilded1"},
				--{jumps = 21, name="Gilded2"},
				--{jumps = 22, name="Gilded3"},
				--{jumps = 23, name="Gilded4"},
				{jumps = 24, name="Gilded5"},
			},
			usedItemlevels = {

			},
		},
	},
	[15] = {
		baseItemlevel = 642,
		baseJumpIndex = 4,
		maxItemlevel = 723,

		tracks = {
			[1] = {name = "Explorer", length = 8},
			[2] = {name = "Adventurer", length = 8},
			[3] = {name = "Veteran", length = 8},
			[4] = {name = "Champion", length = 8},
			[5] = {name = "Hero", length = 6},
			[6] = {name = "Myth", length = 6},

		},

		allItemlevels = {},
		usedItemlevels = {},

		dungeon = {
			info = {
				[1] = {jumps = -1, name="Normal", ignoreForVault=true},
				[2] = {jumps = 7, name="Heroic/TW"},
				[3] = {jumps = 12, vaultOffset = 3, name="Mythic"},
				[4] = {jumps = 13, vaultOffset = 3, name="+2"},
				[5] = {jumps = 13, vaultOffset = 3, name="+3"},
				[6] = {jumps = 14, vaultOffset = 3, name="+4"},
				[7] = {jumps = 15, vaultOffset = 2, name="+5"},
				[8] = {jumps = 16, vaultOffset = 2, name="+6"},
				[9] = {jumps = 16, vaultOffset = 3, name="+7"},
				[10] = {jumps = 17, vaultOffset = 2, name="+8"},
				[11] = {jumps = 17, vaultOffset = 2, name="+9"},
				[12] = {jumps = 18, vaultOffset = 2, name="+10"},
			},
			usedItemlevels = {

			},
			vault = {
				usedItemlevels = {
	
				},
				offset = 4,

			},
		},
		
		raid = {
			info = {
				[1] = {jumps = 8, name="LFR"},
				[2] = {jumps = 12, name="Normal"},
				[3] = {jumps = 16, name="Heroic"},
				[4] = {jumps = 20, name="Mythic"},
			},
			usedItemlevels = {

			},
			veryRare = {
				info = {
					[1] = {jumps = 13, name="Rare LFR"},
					[2] = {jumps = 17, name="Rare Normal"},
					[3] = {jumps = 21, name="Rare Heroic"},
					[4] = {jumps = 25, name="Rare Mythic"},
				},
				usedItemlevels = {
	
				},
			}
		},

		delves = {
			info = {
				[1] = {jumps = 4, vaultOffset = 4, name="T1"},
				[2] = {jumps = 5, vaultOffset = 3, name="T2"},
				[3] = {jumps = 6, vaultOffset = 3, name="T3"},
				[4] = {jumps = 7, vaultOffset = 5, name="T4"},
				[5] = {jumps = 8, vaultOffset = 6, name="T5"},
				[6] = {jumps = 9, vaultOffset = 6, name="T6"},
				[7] = {jumps = 12, vaultOffset = 4, name="T7+"},
			},
			usedItemlevels = {

			},
			bountiful = {
				info = {
					[1] = {jumps = 9, name="T4B"},
					[2] = {jumps = 11, name="T5B"},
					[3] = {jumps = 13, name="T6B"},
					[4] = {jumps = 15, name="T7B"},
					[5] = {jumps = 16, name="T8B+"},
				},
				usedItemlevels = {
	
				},
			},
			vault = {
				usedItemlevels = {
	
				},
				offset = 4,

			},
		},

		other = {
			info = {
				--{jumps = 6, name="EnchWeather1"},
				--{jumps = 7, name="EnchWeather2"},
				--{jumps = 8, name="EnchWeather3"},
				--{jumps = 9, name="EnchWeather4"},
				{jumps = 10, name="EnchWeather5"},
				--{jumps = 11, name="Spark1"},
				--{jumps = 12, name="Spark2"},
				--{jumps = 13, name="Spark3"},
				--{jumps = 14, name="Spark4"},
				{jumps = 15, name="Spark5"},
				--{jumps = 15, name="Runed1"},
				--{jumps = 16, name="Runed2"},
				--{jumps = 17, name="Runed3"},
				--{jumps = 18, name="Runed4"},
				{jumps = 19, name="Runed5"},
				--{jumps = 20, name="Gilded1"},
				--{jumps = 21, name="Gilded2"},
				--{jumps = 22, name="Gilded3"},
				--{jumps = 23, name="Gilded4"},
				{jumps = 24, name="Gilded5"},
			},
			usedItemlevels = {

			},
		},
	}
}

local function getAdjustedItemLevel(seasonID, jumps)
    local jumpsCompleted = 1
    local newItemLevel = miog.NEW_GEARING_DATA[seasonID].baseItemlevel
	local start = jumps < 0 and -1 or 1
	local step = start

    for i = start, jumps, step do
        newItemLevel = newItemLevel + (miog.ITEM_LEVEL_JUMPS[jumps < 0 and #miog.ITEM_LEVEL_JUMPS - (i + 1)  or jumpsCompleted] * start)

        jumpsCompleted = jumpsCompleted + 1

        if(jumpsCompleted == 5) then
            jumpsCompleted = 1
        end
    end

    return newItemLevel
end

miog.getAdjustedItemLevel = getAdjustedItemLevel

local function getJumpsForItemLevel(seasonID, itemLevel, startIndex)
	local totalJumps = 0
	startIndex = startIndex or 1
	local jumpsCompleted = startIndex or 1

	local tempItemLevel = miog.GEARING_CHART[seasonID].baseItemLevel

    while(itemLevel > tempItemLevel) do
        tempItemLevel = tempItemLevel + miog.ITEM_LEVEL_JUMPS[jumpsCompleted]

        jumpsCompleted = jumpsCompleted + 1
		totalJumps = totalJumps + 1

		if(tempItemLevel == itemLevel) then
			return totalJumps

		end

        if(jumpsCompleted == 5) then
            jumpsCompleted = 1
        end
    end

    return nil
end

for k, v in pairs(miog.NEW_GEARING_DATA) do
	for x, y in ipairs(v.tracks) do
		y.data = {}

		for i = 1, y.length, 1 do
			local jumps = (i - 1) + (x - 1) * 4

			y.data[i] = getAdjustedItemLevel(k, jumps)
		end

		y.baseItemLevel = y.data[1]
		y.maxItemLevel = y.data[y.length]

		if(x == #v.tracks) then
			v.maxUpgradeItemLevel = y.maxItemLevel

		end
	end

	for x, y in ipairs(v.dungeon.info) do
		local currentItemlevel = getAdjustedItemLevel(k, y.jumps)

		v.dungeon.usedItemlevels[currentItemlevel] = v.dungeon.usedItemlevels[currentItemlevel] or {}
		tinsert(v.dungeon.usedItemlevels[currentItemlevel], y.name)

		v.usedItemlevels[currentItemlevel] = true

		if(not y.ignoreForVault) then
			local vaultLevel = getAdjustedItemLevel(k, y.jumps + (y.vaultOffset or v.dungeon.vault.offset))
			v.dungeon.vault.usedItemlevels[vaultLevel] = v.dungeon.vault.usedItemlevels[vaultLevel] or {}
			tinsert(v.dungeon.vault.usedItemlevels[vaultLevel], y.name)
			v.usedItemlevels[vaultLevel] = true

		end

		if(y.jumps < 0) then
			tinsert(v.allItemlevels, currentItemlevel)
		end
	end

	for x, y in ipairs(v.raid.info) do
		local currentItemlevel = getAdjustedItemLevel(k, y.jumps)

		v.raid.usedItemlevels[currentItemlevel] = v.raid.usedItemlevels[currentItemlevel] or {}
		tinsert(v.raid.usedItemlevels[currentItemlevel], y.name)

		v.usedItemlevels[currentItemlevel] = true

	end

	if(v.raid.veryRare) then
		for x, y in pairs(v.raid.veryRare.info) do
			local currentItemlevel = getAdjustedItemLevel(k, y.jumps)

			v.raid.usedItemlevels[currentItemlevel] = v.raid.usedItemlevels[currentItemlevel] or {}
			tinsert(v.raid.usedItemlevels[currentItemlevel], y.name)

			v.usedItemlevels[currentItemlevel] = true
			
		end
	end

	for x, y in ipairs(v.delves.info) do
		local currentItemlevel = getAdjustedItemLevel(k, y.jumps)

		v.delves.usedItemlevels[currentItemlevel] = v.delves.usedItemlevels[currentItemlevel] or {}
		tinsert(v.delves.usedItemlevels[currentItemlevel], y.name)

		v.usedItemlevels[currentItemlevel] = true

		if(not y.ignoreForVault) then
			local vaultLevel = getAdjustedItemLevel(k, y.jumps + (y.vaultOffset or v.delves.vault.offset))
			v.delves.vault.usedItemlevels[vaultLevel] = v.delves.vault.usedItemlevels[vaultLevel] or {}
			tinsert(v.delves.vault.usedItemlevels[vaultLevel], y.name)
			v.usedItemlevels[vaultLevel] = true

		end
	end

	if(v.delves.bountiful) then
		for x, y in pairs(v.delves.bountiful.info) do
			local currentItemlevel = getAdjustedItemLevel(k, y.jumps)

			v.delves.usedItemlevels[currentItemlevel] = v.delves.usedItemlevels[currentItemlevel] or {}
			tinsert(v.delves.usedItemlevels[currentItemlevel], y.name)

			v.usedItemlevels[currentItemlevel] = true
			
		end
	end

	for x, y in ipairs(v.other.info) do
		local currentItemlevel = getAdjustedItemLevel(k, y.jumps)

		v.other.usedItemlevels[currentItemlevel] = v.other.usedItemlevels[currentItemlevel] or {}
		tinsert(v.other.usedItemlevels[currentItemlevel], y.name)

		v.usedItemlevels[currentItemlevel] = true
	end

	-- calc all itemlevels
    local currentIlvl = v.baseItemlevel
    local offset = 0

    while(currentIlvl < v.maxItemlevel) do
        if(offset == 0) then
			tinsert(v.allItemlevels, currentIlvl)
            
        else
            currentIlvl = currentIlvl + miog.ITEM_LEVEL_JUMPS[offset]

        end
    
		tinsert(v.allItemlevels, currentIlvl)
    
        if(offset == 4) then
            offset = 1
    
        else
            offset = offset + 1
    
        end
    end
end

--[[for k, v in pairs(miog.GEARING_CHART) do
	for x, y in ipairs(v.trackInfo) do
		y.data = {}

		for i = 1, y.length, 1 do
			local jumps = (i - 1) + (x - 1) * 4

			y.data[i] = miog.getAdjustedItemLevel(k, jumps)
		end

		y.baseItemLevel = y.data[1]

		y.maxItemLevel = y.data[y.length]

		if(x == #v.trackInfo) then
			v.maxUpgradeItemLevel = y.maxItemLevel
		end
	end
	
	for a, b in ipairs(v.dungeon.info) do
		v.dungeon.itemLevels[a] = miog.getAdjustedItemLevel(k, b.jumps)
		v.itemLevelInfo[miog.getAdjustedItemLevel(k, b.jumps)] = true

		if(not b.ignoreForVault) then
			v.dungeon.vaultLevels[a] = miog.getAdjustedItemLevel(k, b.jumps + (b.vaultOffset or v.dungeon.vaultJumpsOffset))
			v.itemLevelInfo[miog.getAdjustedItemLevel(k, b.jumps + (b.vaultOffset or v.dungeon.vaultJumpsOffset))] = true

		end
	end

	for a, b in ipairs(v.raid.info) do
		v.raid.itemLevels[a] = miog.getAdjustedItemLevel(k, b.jumps)
		v.itemLevelInfo[miog.getAdjustedItemLevel(k, b.jumps)] = true
		
	end

	if(v.raid.veryRare) then
		for a, b in pairs(v.raid.veryRare.info) do
			v.raid.veryRare.itemLevels[a] = miog.getAdjustedItemLevel(k, b.jumps)
			v.itemLevelInfo[miog.getAdjustedItemLevel(k, b.jumps)] = true
			
		end
	end

	if(v.delves) then
		for a, b in ipairs(v.delves.info) do
			v.delves.itemLevels[a] = miog.getAdjustedItemLevel(k, b.jumps)
			v.itemLevelInfo[miog.getAdjustedItemLevel(k, b.jumps)] = true

			if(not b.ignoreForVault) then
				v.delves.vaultLevels[a] = miog.getAdjustedItemLevel(k, b.jumps + (b.vaultOffset or v.delves.vaultJumpsOffset))
				v.itemLevelInfo[miog.getAdjustedItemLevel(k, b.jumps + (b.vaultOffset or v.delves.vaultJumpsOffset))] = true

			end
		end
	end

	for a, b in ipairs(v.other.info) do
		v.other.itemLevels[a] = miog.getAdjustedItemLevel(k, b.jumps)
		v.itemLevelInfo[miog.getAdjustedItemLevel(k, b.jumps)] = true
	end

	if(v.awakenedInfo) then
		table.insert(v.trackInfo, {
			name = "Awakened",
			length = v.awakenedInfo.maxLength,
			data = {},
		})

		local awakenedTrackTable = v.trackInfo[#v.trackInfo]

		for i = 1, awakenedTrackTable.length, 1 do
			awakenedTrackTable.data[i] = miog.getAdjustedItemLevel(k, v.raid.info[2].jumps + (i - 1))

		end

		awakenedTrackTable.baseItemLevel = awakenedTrackTable.data[1]
		awakenedTrackTable.maxItemLevel = awakenedTrackTable.data[awakenedTrackTable.length]
	end
end]]--

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

miog.SLOT_FILTER_TO_NAME = {
	[Enum.ItemSlotFilterType.Head] = INVTYPE_HEAD,
	[Enum.ItemSlotFilterType.Neck] = INVTYPE_NECK,
	[Enum.ItemSlotFilterType.Shoulder] = INVTYPE_SHOULDER,
	[Enum.ItemSlotFilterType.Cloak] = INVTYPE_CLOAK,
	[Enum.ItemSlotFilterType.Chest] = INVTYPE_CHEST,
	[Enum.ItemSlotFilterType.Wrist] = INVTYPE_WRIST,
	[Enum.ItemSlotFilterType.Hand] = INVTYPE_HAND,
	[Enum.ItemSlotFilterType.Waist] = INVTYPE_WAIST,
	[Enum.ItemSlotFilterType.Legs] = INVTYPE_LEGS,
	[Enum.ItemSlotFilterType.Feet] = INVTYPE_FEET,
	[Enum.ItemSlotFilterType.MainHand] = INVTYPE_WEAPONMAINHAND,
	[Enum.ItemSlotFilterType.OffHand] = INVTYPE_WEAPONOFFHAND,
	[Enum.ItemSlotFilterType.Finger] = INVTYPE_FINGER,
	[Enum.ItemSlotFilterType.Trinket] = INVTYPE_TRINKET,
	[Enum.ItemSlotFilterType.Other] = EJ_LOOT_SLOT_FILTER_OTHER,
}

miog.roleRemainingKeyLookup = {
	["TANK"] = "TANK_REMAINING",
	["HEALER"] = "HEALER_REMAINING",
	["DAMAGER"] = "DAMAGER_REMAINING",
}

miog.CLASSES = {
	[1] = 	{name = "WARRIOR", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warrior.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warrior_round.png", specs = {71, 72, 73}},
	[2] = 	{name = "PALADIN", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/paladin.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/paladin_round.png", specs = {65, 66, 70}},
	[3] = 	{name = "HUNTER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/hunter.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/hunter_round.png", specs = {253, 254, 255}},
	[4] = 	{name = "ROGUE", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/rogue.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/rogue_round.png", specs = {259, 260, 261}},
	[5] = 	{name = "PRIEST", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/priest.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/priest_round.png", specs = {256, 257, 258}},
	[6] = 	{name = "DEATHKNIGHT", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/deathKnight.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/deathKnight_round.png", specs = {250, 251, 252}},
	[7] = 	{name = "SHAMAN", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/shaman.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/shaman_round.png", specs = {262, 263, 264}},
	[8] = 	{name = "MAGE", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/mage.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/mage_round.png", specs = {62, 63, 64}},
	[9] =	{name = "WARLOCK", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warlock.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warlock_round.png", specs = {265, 266, 267}},
	[10] = 	{name = "MONK", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/monk.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/monk_round.png", specs = {268, 270, 269}},
	[11] =	{name = "DRUID", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/druid.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/druid_round.png", specs = {102, 103, 104, 105}},
	[12] = 	{name = "DEMONHUNTER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/demonHunter.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/demonHunter_round.png", specs = {577, 581}},
	[13] = 	{name = "EVOKER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/evoker.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/evoker_round.png", specs = {1467, 1468, 1473}},
	[20] = 	{name = "DUMMY", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/empty.png", specs = {}},
	[21] =	{name = "DUMMY", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/empty.png", specs = {}},
	[22] =	{name = "DUMMY", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/empty.png", specs = {}},
	[100] =	{name = "EMPTY", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/unknown.png", specs = {}},
}

miog.CLASSFILE_TO_INFO = {}

for k, v in pairs(miog.CLASSES) do
	miog.CLASSFILE_TO_INFO[v.name] = v
end

miog.OFFICIAL_CLASSES = {}

for i = 1, #miog.CLASSES, 1 do
	miog.OFFICIAL_CLASSES[i] = miog.CLASSES[i]
end

miog.SPECIALIZATIONS = {
	[0] = {name = "Unknown", class = miog.CLASSES[100], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png"},
	[1] = {name = "Missing Tank", class = miog.CLASSES[20], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/tankIcon.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/tankIcon.png"},
	[2] = {name = "Missing Healer", class = miog.CLASSES[21], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/healerIcon.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/healerIcon.png"},
	[3] = {name = "Missing Damager", class = miog.CLASSES[22], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/damagerIcon.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/damagerIcon.png"},
	[20] = {name = "Empty", class = miog.CLASSES[20], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/empty.png"},

	[62] = {name = "Arcane", class = miog.CLASSES[8], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/arcane.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/arcane_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[63] = {name = "Fire", class = miog.CLASSES[8], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/fire.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/fire_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[64] = {name = "Frost", class = miog.CLASSES[8], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/frostMage.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/frostMage_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},

	[65] = {name = "Holy", class = miog.CLASSES[2], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/holyPala.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/holyPala_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[66] = {name = "Protection", class = miog.CLASSES[2], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/protPala.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/protPala_squared.png", stat = "ITEM_MOD_STRENGTH_SHORT"},
	[70] = {name = "Retribution", class = miog.CLASSES[2], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/retribution.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/retribution_squared.png", stat = "ITEM_MOD_STRENGTH_SHORT"},

	[71] = {name = "Arms", class = miog.CLASSES[1], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/arms.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/arms_squared.png", stat = "ITEM_MOD_STRENGTH_SHORT"},
	[72] = {name = "Fury", class = miog.CLASSES[1], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/fury.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/fury_squared.png", stat = "ITEM_MOD_STRENGTH_SHORT"},
	[73] = {name = "Protection", class = miog.CLASSES[1], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/protWarr.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/protWarr_squared.png", stat = "ITEM_MOD_STRENGTH_SHORT"},

	[102] = {name = "Balance", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/balance.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/balance_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[103] = {name = "Feral", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/feral.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/feral_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[104] = {name = "Guardian", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/guardian.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/guardian_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[105] = {name = "Restoration", class = miog.CLASSES[11], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/restoDruid.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/restoDruid_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},

	[250] = {name = "Blood", class = miog.CLASSES[6], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/blood.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/blood_squared.png", stat = "ITEM_MOD_STRENGTH_SHORT"},
	[251] = {name = "Frost", class = miog.CLASSES[6], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/frostDK.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/frostDK_squared.png", stat = "ITEM_MOD_STRENGTH_SHORT"},
	[252] = {name = "Unholy", class = miog.CLASSES[6], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/unholy.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/unholy_squared.png", stat = "ITEM_MOD_STRENGTH_SHORT"},

	[253] = {name = "Beast Mastery", class = miog.CLASSES[3], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/beastmastery.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/beastmastery_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[254] = {name = "Marksmanship", class = miog.CLASSES[3], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/marksmanship.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/marksmanship_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[255] = {name = "Survival", class = miog.CLASSES[3], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/survival.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/survival_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},

	[256] = {name = "Discipline", class = miog.CLASSES[5], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/discipline.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/discipline_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[257] = {name = "Holy", class = miog.CLASSES[5], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/holyPriest.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/holyPriest_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[258] = {name = "Shadow", class = miog.CLASSES[5], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/shadow.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/shadow_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},

	[259] = {name = "Assassination", class = miog.CLASSES[4], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/assassination.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/assassination_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[260] = {name = "Outlaw", class = miog.CLASSES[4], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/outlaw.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/outlaw_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[261] = {name = "Subtlety", class = miog.CLASSES[4], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/subtlety.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/subtlety_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},

	[262] = {name = "Elemental", class = miog.CLASSES[7], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/elemental.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/elemental_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[263] = {name = "Enhancement", class = miog.CLASSES[7], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/enhancement.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/enhancement_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[264] = {name = "Restoration", class = miog.CLASSES[7], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/restoShaman.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/restoShaman_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},

	[265] = {name = "Affliction", class = miog.CLASSES[9], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/affliction.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/affliction_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[266] = {name = "Demonology", class = miog.CLASSES[9], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/demonology.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/demonology_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[267] = {name = "Destruction", class = miog.CLASSES[9], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/destruction.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/destruction_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},

	[268] = {name = "Brewmaster", class = miog.CLASSES[10], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/brewmaster.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/brewmaster_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[269] = {name = "Windwalker", class = miog.CLASSES[10], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/windwalker.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/windwalker_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[270] = {name = "Mistweaver", class = miog.CLASSES[10], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/mistweaver.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/mistweaver_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},

	[577] = {name = "Havoc", class = miog.CLASSES[12], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/havoc.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/havoc_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},
	[581] = {name = "Vengeance", class = miog.CLASSES[12], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/vengeance.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/vengeance_squared.png", stat = "ITEM_MOD_AGILITY_SHORT"},

	[1467] = {name = "Devastation", class = miog.CLASSES[13], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/devastation.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/devastation_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[1468] = {name = "Preservation", class = miog.CLASSES[13], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/preservation.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/preservation_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},
	[1473] = {name = "Augmentation", class = miog.CLASSES[13], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/augmentation.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/augmentation_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},

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

miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID = {}

for k, v in pairs(miog.SPECIALIZATIONS) do
	if(k > 25) then
		local _, localizedName, _, _, _, fileName = GetSpecializationInfoByID(k)

		if(localizedName == "") then
			localizedName = "Initial"
		end

		miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[localizedName .. "-" .. fileName] = k
	end
end

miog.RACES = {
	[1] = "raceicon128-human-male",
	[2] = "raceicon128-orc-male",
	[3] = "raceicon128-dwarf-male",
	[4] = "raceicon128-nightelf-male",
	[5] = "raceicon128-undead-male",
	[6] = "raceicon128-tauren-male",
	[7] = "raceicon128-gnome-male",
	[8] = "raceicon128-troll-male",
	[9] = "raceicon128-goblin-male",
	[10] = "raceicon128-bloodelf-male",
	[11] = "raceicon128-draenei-male",
	[22] = "raceicon128-worgen-male",
	[24] = "raceicon128-pandaren-male",
	[25] = "raceicon128-pandaren-male",
	[26] = "raceicon128-pandaren-male",
	[27] = "raceicon128-nightborne-male",
	[28] = "raceicon128-highmountain-male",
	[29] = "raceicon128-voidelf-male",
	[30] = "raceicon128-lightforged-male",
	[31] = "raceicon128-zandalari-male",
	[32] = "raceicon128-kultiran-male",
	[33] = "raceicon128-darkirondwarf-male",
	[34] = "raceicon128-darkirondwarf-male",
	[35] = "raceicon128-vulpera-male",
	[36] = "raceicon128-magharorc-male",
	[37] = "raceicon128-mechagnome-male",
	[52] = "raceicon128-dracthyr-male",
	[70] = "raceicon128-dracthyr-male",

}

miog.SEARCH_LANGUAGES = {
	itIT=true,
	ruRU=true,
	frFR=true,
	esES=true,
	deDE=true,
}

miog.COLOR_BREAKPOINTS = {
	[0] = {breakpoint = 0, hex = "ff9d9d9d", r = 0.62, g = 0.62, b = 0.62},
	[1] = {breakpoint = 700, hex = "ffffffff", r = 1, g = 1, b = 1},
	[2] = {breakpoint = 1400, hex = "ff1eff00", r = 0.12, g = 1, b = 0},
	[3] = {breakpoint = 2100, hex = "ff0070dd", r = 0, g = 0.44, b = 0.87},
	[4] = {breakpoint = 2800, hex = "ffa335ee", r = 0.64, g = 0.21, b = 0.93},
	[5] = {breakpoint = 3500, hex = "ffff8000", r = 1, g = 0.5, b = 0},
	[6] = {breakpoint = 4200, hex = "ffe6cc80", r = 0.9, g = 0.8, b = 0.5},
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
	[121] = miog.C.STANDARD_FILE_PATH .. "/backgrounds/delves.png", --DELVES
}

miog.EXPANSION_INFO = {
	[0] = {"Classic", "vanilla-bg-1", GetExpansionDisplayInfo(0).logo},
	[1] = {"The Burning Crusade", "tbc-bg-1", GetExpansionDisplayInfo(1).logo},
	[2] = {"Wrath of the Lich King", "wotlk-bg-1", GetExpansionDisplayInfo(2).logo},
	[3] = {"Cataclysm", "cata-bg-1", GetExpansionDisplayInfo(3).logo},
	[4] = {"Mists of Pandaria", "mop-bg-1", GetExpansionDisplayInfo(4).logo},
	[5] = {"Warlords of Draenor", "wod-bg-1", GetExpansionDisplayInfo(5).logo},
	[6] = {"Legion", "legion-bg-1", GetExpansionDisplayInfo(6).logo},
	[7] = {"Battle for Azeroth", "bfa-bg-1", GetExpansionDisplayInfo(7).logo},
	[8] = {"Shadowlands", "sl-bg-1", GetExpansionDisplayInfo(8).logo},
	[9] = {"Dragonflight", "df-bg-1", GetExpansionDisplayInfo(9).logo},
	[10] = {"The War Within", "tww-bg-1", GetExpansionDisplayInfo(10).logo},
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
	"Latimeria-Ravencrest",
	"Lyadry-Ravencrest",
}