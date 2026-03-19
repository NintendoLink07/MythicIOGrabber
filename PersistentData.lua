local addonName, miog = ...

miog.ITEM_QUALITY_COLORS = _G["ITEM_QUALITY_COLORS"]

for _, colorElement in pairs(miog.ITEM_QUALITY_COLORS) do
	colorElement.pureHex = colorElement.color:GenerateHexColor()
	colorElement.desaturatedRGB = {colorElement.r * 0.65, colorElement.g * 0.65, colorElement.b * 0.65}
	colorElement.desaturatedHex = CreateColor(unpack(colorElement.desaturatedRGB)):GenerateHexColor()
end

miog.COLOR_THEMES = { -- index == expansionIndex
	[10] = {
		{r = 0.08235294117647059, g = 0.06666666666666667, b = 0.058823529411764705},
		{r = 0.12941176470588237, g = 0.07058823529411765, b = 0.054901960784313725},
		{r = 0.10588235294117647, g = 0.09019607843137255, b = 0.08235294117647059},
		{r = 0.21568627450980393, g = 0.1450980392156863, b = 0.10196078431372549},
		{r = 0.3254901960784314, g = 0.19607843137254902, b = 0.10980392156862745},
	},
	[9] = {
		{r = 0.050980392156862744, g = 0.058823529411764705, b = 0.07450980392156863},
		{r = 0.09411764705882353, g = 0.11764705882352941, b = 0.13725490196078433},
		{r = 0.2, g = 0.24313725490196078, b = 0.2823529411764706},
		{r = 0.2549019607843137, g = 0.2627450980392157, b = 0.25882352941176473},
		{r = 0.4392156862745098, g = 0.43529411764705883, b = 0.4392156862745098},
	},
	[8] = {
		{r = 0.011764705882352941, g = 0.023529411764705882, b = 0.047058823529411764},
		{r = 0.06274509803921569, g = 0.058823529411764705, b = 0.07450980392156863},
		{r = 0.12549019607843137, g = 0.12941176470588237, b = 0.16862745098039217},
		{r = 0.027450980392156862, g = 0.18823529411764706, b = 0.35294117647058826},
		{r = 0.2196078431372549, g = 0.33725490196078434, b = 0.3254901960784314},
	},
	[7] = {
		{r = 0.050980392156862744, g = 0.043137254901960784, b = 0.03529411764705882},
		{r = 0.11372549019607843, g = 0.09019607843137255, b = 0.0784313725490196},
		{r = 0.13333333333333333, g = 0.09019607843137255, b = 0.06666666666666667},
		{r = 0.14901960784313725, g = 0.12156862745098039, b = 0.10980392156862745},
		{r = 0.24705882352941178, g = 0.13725490196078433, b = 0.09411764705882353},
	},
	[6] = {
		{r = 0, g = 0.00392156862745098, b = 0},
		{r = 0.0392156862745098, g = 0.06666666666666667, b = 0.0196078431372549},
		{r = 0.0784313725490196, g = 0.14901960784313725, b = 0.047058823529411764},
		{r = 0.047058823529411764, g = 0.20392156862745098, b = 0.058823529411764705},
		{r = 0.1843137254901961, g = 0.6705882352941176, b = 0.24705882352941178},
	},
	[5] = {
		{r = 0.023529411764705882, g = 0.0196078431372549, b = 0.10588235294117647},
		{r = 0.12411764705882353, g = 0.11627450980392157, b = 0.15333333333333333},
		{r = 0.16725490196078433, g = 0.114313725490196, b = 0.14803921568627451},
		{r = 0.23921568627450981, g = 0.11372549019607843, b = 0.16470588235294117},
		{r = 0.30882352941176473, g = 0.15019607843137255, b = 0.15803921568627451},
	},
	[4] = {
		{r = 0.04529411764705882, g = 0.07666666666666667, b = 0.068823529411764705},
		{r = 0.08666666666666667, g = 0.1750980392156863, b = 0.08274509803921569},
		{r = 0.01019607843137255, g = 0.22156862745098039, b = 0.11196078431372549},
		{r = 0.14627450980392157, g = 0.3033333333333333, b = 0.14411764705882353},
		{r = 0.21176470588235294, g = 0.38411764705882354, b = 0.21176470588235294},
	},
	[3] = {
		{r = 0.00392156862745098, g = 0.00784313725490196, b = 0.047058823529411764},
		{r = 0.0784313725490196, g = 0.011764705882352941, b = 0.011764705882352941},
		{r = 0.1411764705882353, g = 0.011764705882352941, b = 0.011764705882352941},
		{r = 0.3333333333333333, g = 0.03529411764705882, b = 0.01568627450980392},
		{r = 0.5882352941176471, g = 0.1568627450980392, b = 0.058823529411764705},
	},
	[2] = {
		{r = 0, g = 0.027450980392156862, b = 0.07058823529411765},
		{r = 0.03137254901960784, g = 0.07450980392156863, b = 0.1411764705882353},
		{r = 0.0784313725490196, g = 0.23921568627450981, b = 0.3411764705882353},
		{r = 0.1450980392156863, g = 0.30980392156862746, b = 0.3254901960784314},
		{r = 0.11372549019607843, g = 0.4117647058823529, b = 0.4745098039215686},
	},
	[1] = {
		{r = 0.027450980392156862, g = 0.047058823529411764, b = 0.03137254901960784},
		{r = 0.06666666666666667, g = 0.03137254901960784, b = 0.07450980392156863},
		{r = 0.06274509803921569, g = 0.16862745098039217, b = 0.011764705882352941},
		{r = 0.23921568627450981, g = 0.26666666666666666, b = 0.050980392156862744},
		{r = 0.5098039215686274, g = 0.40784313725490196, b = 0.03529411764705882},
	},
	[0] = {
		{r = 0.03529411764705882, g = 0.023529411764705882, b = 0.00392156862745098},
		{r = 0.058823529411764705, g = 0.011764705882352941, b = 0.00392156862745098},
		{r = 0.16156862745098039, g = 0.09666666666666667, b = 0.04568627450980392},
		{r = 0.268627450980392, g = 0.21372549019607843, b = 0.13137254901960784},
		{r = 0.5215686274509804, g = 0.3215686274509804, b = 0.0784313725490196},
	},
	standard = {
		{r = 0.3, g = 0.3, b = 0.3},
		{r = 0.5, g = 0.5, b = 0.5},
		{r = 0.7, g = 0.7, b = 0.7},
		{r = 0.85, g = 0.85, b = 0.85},
		{r = 1, g = 1, b = 1},
	}
}

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

do
	for k, v in pairs(miog.COLOR_THEMES) do
		for i = 1, 5 do
			local add = i * 0.05
			v[i].r = v[i].r + add
			v[i].g = v[i].g + add
			v[i].b = v[i].b + add
			
		end
	end

	for k, v in pairs(miog.CLRSCC) do
		if(type(v) == "string") then
			miog.CLRSCC.colors[k] = CreateColorFromHexString(v)

		end
	end

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
	["tank"] = "Changes the minimum and maximum number of tanks a group should have.",
	["healer"] = "Changes the minimum and maximum number of healers a group should have.",
	["damager"] = "Changes the minimum and maximum number of damagers a group should have.",
	["age"] = "Set the minimum and/or maximum amount of minutes the groups have to be listed.",
	["linking"] = "Enabling 2 or 3 links checks if either of the enabled checks have been passed, e.g. if atleast 1 Tank OR 1 Healer is in the group.",
	["rating"] = "Sets the minimum and/or maximum amount of rating points the groups should have to be listed.",
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

miog.BETTER_DIFFICULTY_ORDER = {
	[0] = 0,

	--DUNGEONS
	[24] = 10,
	[1] = 11,
	[2] = 12,
	[23] = 13,
	[8] = 14,

	--OLD RAIDS
	[7] = 20,
	[9] = 21,
	[3] = 22,
	[4] = 23,
	[5] = 24,
	[6] = 25,

	--NEW RAIDS
	[220] = 30,
	[17] = 31,
	[33] = 32,
	[14] = 33,
	[15] = 34,
	[16] = 35,

	--DELVE
	[208] = 40
}

miog.DIFFICULTY_ORDER = {
	[1] = 1,
	[2] = 2,
	[3] = 1,
	[4] = 3,
	[5] = 2,
	[6] = 4,
	[7] = 5,
	[8] = 5,
	[9] = 7,
	[14] = 3,
	[15] = 4,
	[16] = 5,
	[17] = 6,
	[23] = 3,
	[24] = 6,
	[33] = 7,
	[220] = 9,
}

miog.EJ_DIFFICULTIES = {
	DifficultyUtil.ID.DungeonNormal,
	DifficultyUtil.ID.DungeonHeroic,
	DifficultyUtil.ID.DungeonMythic,
	DifficultyUtil.ID.DungeonChallenge,
	DifficultyUtil.ID.DungeonTimewalker,
	DifficultyUtil.ID.RaidLFR,
	DifficultyUtil.ID.Raid10Normal,
	DifficultyUtil.ID.Raid10Heroic,
	DifficultyUtil.ID.Raid25Normal,
	DifficultyUtil.ID.Raid25Heroic,
	DifficultyUtil.ID.PrimaryRaidLFR,
	DifficultyUtil.ID.PrimaryRaidNormal,
	DifficultyUtil.ID.PrimaryRaidHeroic,
	DifficultyUtil.ID.PrimaryRaidMythic,
	DifficultyUtil.ID.RaidTimewalker,
	DifficultyUtil.ID.Raid40,
	DifficultyUtil.ID.RaidStory,
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
}

miog.C.BACKUP_SEASON_ID = 16

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
		{id = 3132, icon = 5929751, spark = true, sparkItem = 230905}, --spark
	},
	[15] = {
		{id = 3284,},
		{id = 3286,},
		{id = 3288,},
		{id = 3290,},
		{id = 3008,}, --valorstones
		{id = 3269,}, --catalyst
		{id = 3141,}, --spark
		{id = 3278, macro=function() 
			GenericTraitUI_LoadUI()
			GenericTraitFrame:SetConfigIDBySystemID(29)
			--GenericTraitFrame:SetSystemID(29)
			GenericTraitFrame:SetTreeID(1115)
			ToggleFrame(GenericTraitFrame)
		end} --strands
	},
	[16] = {
		{id = 3383,},
		{id = 3341,},
		{id = 3343,},
		{id = 3345,},
		{id = 3347,},
		{id = 3378,}, --manaflux
		--{id = 3310,}, --cofferkey shards
		{id = 3212,}, --spark
		{id = 3316,}, --voidlight
	}
}

--CHANGING VARIABLES
miog.F = {
	IS_IN_DEBUG_MODE = false,

	CURRENT_REGION = miog.C.REGIONS[GetCurrentRegion()],

	SEASON_ID = -1
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

miog.GROUP_ACTIVITY_ID_INFO = {
	[280] = {abbreviatedName="STRTS", mapID = "2441", challengeModeID=391, fileName="tazavesh_streets"},
	[281] = {abbreviatedName="GMBT", mapID = "2441", challengeModeID=392, fileName="tazavesh_gambit"},

	[378] = {abbreviatedName="MFO", mapID = 2810,
		bossIcons = {
			{icon = "interface/icons/inv_112_achievement_raid_automaton.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_silkworm.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_binder.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_engineer.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_dhcouncil.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_glasselemental.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_salhadaar.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_dimensius.blp"},
		},
	},	
	
	[362] = {
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
		abbreviatedName = "NP",
		mapID = 2657,
		
	},

	[377] = {
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
		abbreviatedName = "LOU",
		mapID = 2769,
	},
	[402] = {
		abbreviatedName = "VS",
		mapID = 2912,
		bossIcons = {
			{icon = "interface/icons/inv_120_raid_voidspire_hostgeneral.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_kaiju.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_salhadaar.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_dragonduo.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_paladintrio.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_alleria.blp"},
		},
	},
	[404] = {
		abbreviatedName = "DR",
		mapID = 2939,
		bossIcons = {
			{icon = "interface/icons/inv_120_raid_dreamwell_malformedmanifestation.blp"},
		},
	},
}

-- wagotools groupfinderactivity csv, sort by group id and create dataset with mapID, groupID and activityID
miog.GROUP_INFO = {
	[1] = {groupName = "Siege of Orgrimmar", orderIndex = 1},
	[2] = {groupName = "Eastern Kingdoms", 	orderIndex = 0},
	[3] = {groupName = "Kalimdor", orderIndex = 0},
	[5] = {groupName = "Deadmines", orderIndex = 0},
	[6] = {groupName = "Bloodmaul Slag Mines", orderIndex = 0},
	[7] = {groupName = "Iron Docks", orderIndex = 0},
	[8] = {groupName = "Auchindoun", orderIndex = 0},
	[9] = {groupName = "Skyreach", orderIndex = 11},
	[10] = {groupName = "Grimrail Depot", orderIndex = 1},
	[11] = {groupName = "The Everbloom", orderIndex = 0},
	[12] = {groupName = "Shadowmoon Burial Grounds", orderIndex = 10},
	[13] = {groupName = "Upper Blackrock Spire", orderIndex = 0},
	[14] = {groupName = "Highmaul", orderIndex = 0},
	[15] = {groupName = "Blackrock Foundry", orderIndex = 0},
	[16] = {groupName = "Naxxramas", orderIndex = 0},
	[17] = {groupName = "Icecrown Citadel", orderIndex = 0},
	[18] = {groupName = "Scholomance", orderIndex = 0},
	[19] = {groupName = "Shadowfang Keep", orderIndex = 0},
	[20] = {groupName = "Hellfire Ramparts", orderIndex = 0},
	[21] = {groupName = "Blood Furnace", orderIndex = 0},
	[22] = {groupName = "Shattered Halls", orderIndex = 0},
	[23] = {groupName = "Slave Pens", orderIndex = 0},
	[24] = {groupName = "Underbog", orderIndex = 0},
	[25] = {groupName = "The Steamvault", orderIndex = 0},
	[26] = {groupName = "Mana-Tombs", orderIndex = 0},
	[27] = {groupName = "Auchenai Crypts", orderIndex = 0},
	[28] = {groupName = "Sethekk Halls", orderIndex = 0},
	[29] = {groupName = "Shadow Labyrinth", orderIndex = 0},
	[30] = {groupName = "Scarlet Halls", orderIndex = 0},
	[31] = {groupName = "Scarlet Monastery", orderIndex = 0},
	[32] = {groupName = "The Escape from Durnholde", orderIndex = 0},
	[33] = {groupName = "Opening of the Dark Portal", orderIndex = 0},
	[34] = {groupName = "The Mechanar", orderIndex = 0},
	[35] = {groupName = "The Botanica", orderIndex = 0},
	[36] = {groupName = "The Arcatraz", orderIndex = 0},
	[37] = {groupName = "Magisters' Terrace", orderIndex = 0},
	[38] = {groupName = "Utgarde Keep", orderIndex = 0},
	[39] = {groupName = "Utgarde Pinnacle", orderIndex = 0},
	[40] = {groupName = "Azjol-Nerub", orderIndex = 0},
	[41] = {groupName = "The Oculus", orderIndex = 0},
	[42] = {groupName = "Halls of Lightning", orderIndex = 0},
	[43] = {groupName = "Halls of Stone", orderIndex = 0},
	[44] = {groupName = "The Culling of Stratholme", orderIndex = 0},
	[45] = {groupName = "Drak'Tharon Keep", orderIndex = 0},
	[46] = {groupName = "Gundrak", orderIndex = 0},
	[47] = {groupName = "Ahn'kahet: The Old Kingdom", orderIndex = 0},
	[48] = {groupName = "Violet Hold", orderIndex = 0},
	[49] = {groupName = "The Nexus", orderIndex = 0},
	[50] = {groupName = "Trial of the Champion", orderIndex = 0},
	[51] = {groupName = "The Forge of Souls", orderIndex = 0},
	[52] = {groupName = "Pit of Saron", orderIndex = 11},
	[53] = {groupName = "Halls of Reflection", orderIndex = 0},
	[54] = {groupName = "Throne of the Tides", orderIndex = 0},
	[55] = {groupName = "Blackrock Caverns", orderIndex = 0},
	[56] = {groupName = "Grim Batol", orderIndex = 0},
	[57] = {groupName = "Halls of Origination", orderIndex = 0},
	[58] = {groupName = "The Stonecore", orderIndex = 0},
	[59] = {groupName = "The Vortex Pinnacle", orderIndex = 0},
	[60] = {groupName = "Lost City of the Tol'vir", orderIndex = 0},
	[61] = {groupName = "Temple of the Jade Serpent", orderIndex = 10},
	[62] = {groupName = "Stormstout Brewery", orderIndex = 0},
	[63] = {groupName = "Shado-Pan Monastery", orderIndex = 0},
	[64] = {groupName = "Mogu'shan Palace", orderIndex = 0},
	[65] = {groupName = "Siege of Niuzao Temple", orderIndex = 0},
	[66] = {groupName = "Gate of the Setting Sun", orderIndex = 0},
	[67] = {groupName = "The Everbloom", orderIndex = 0},
	[68] = {groupName = "Draenor", orderIndex = 0},
	[69] = {groupName = "Outland", orderIndex = 0},
	[70] = {groupName = "Northrend", orderIndex = 0},
	[71] = {groupName = "Pandaria", orderIndex = 0},
	[73] = {groupName = "Trial of the Crusader", orderIndex = 0},
	[74] = {groupName = "The Ruby Sanctum", orderIndex = 0},
	[75] = {groupName = "Blackwing Descent", orderIndex = 0},
	[76] = {groupName = "The Bastion of Twilight", orderIndex = 0},
	[77] = {groupName = "Throne of the Four Winds", orderIndex = 0},
	[78] = {groupName = "Firelands", orderIndex = 0},
	[79] = {groupName = "Dragon Soul", orderIndex = 0},
	[80] = {groupName = "Mogu'shan Vaults", orderIndex = 5},
	[81] = {groupName = "Heart of Fear", orderIndex = 4},
	[82] = {groupName = "Terrace of Endless Spring", orderIndex = 3},
	[83] = {groupName = "Throne of Thunder", orderIndex = 2},
	[84] = {groupName = "Random Pandaria Dungeon", orderIndex = 0},
	[86] = {groupName = "Theramore's Fall", orderIndex = 0},
	[102] = {groupName = "A Brewing Storm", orderIndex = 0},
	[103] = {groupName = "Battle on the High Seas", orderIndex = 0},
	[104] = {groupName = "Blood in the Snow", orderIndex = 0},
	[105] = {groupName = "Crypt of Forgotten Kings", orderIndex = 0},
	[106] = {groupName = "Dark Heart of Pandaria", orderIndex = 0},
	[107] = {groupName = "Random Pandaria Scenario", orderIndex = 0},
	[108] = {groupName = "The Secrets of Ragefire", orderIndex = 0},
	[109] = {groupName = "Random Draenor Dungeon", orderIndex = 0},
	[110] = {groupName = "Hellfire Citadel", orderIndex = 0},
	[111] = {groupName = "Random Legion Dungeon", orderIndex = 0},
	[112] = {groupName = "Eye of Azshara", orderIndex = 9},
	[113] = {groupName = "Darkheart Thicket", orderIndex = 12},
	[114] = {groupName = "Halls of Valor", orderIndex = 10},
	[115] = {groupName = "Neltharion's Lair", orderIndex = 10},
	[116] = {groupName = "Assault on Violet Hold", orderIndex = 40},
	[117] = {groupName = "Vault of the Wardens", orderIndex = 13},
	[118] = {groupName = "Black Rook Hold", orderIndex = 17},
	[119] = {groupName = "Maw of Souls", orderIndex = 40},
	[120] = {groupName = "Court of Stars", orderIndex = 10},
	[121] = {groupName = "The Arcway", orderIndex = 40},
	[122] = {groupName = "Emerald Nightmare", orderIndex = 40},
	[123] = {groupName = "The Nighthold", orderIndex = 3},
	[124] = {groupName = "Broken Isles", orderIndex = 0},
	[125] = {groupName = "Return to Karazhan", orderIndex = 41},
	[126] = {groupName = "Trial of Valor", orderIndex = 2},
	[127] = {groupName = "Lower Karazhan", orderIndex = 5},
	[128] = {groupName = "Upper Karazhan", orderIndex = 6},
	[129] = {groupName = "Cathedral of Eternal Night", orderIndex = 41},
	[130] = {groupName = "Dreadscar Rift", orderIndex = 0},
	[131] = {groupName = "Tomb of Sargeras", orderIndex = 4},
	[132] = {groupName = "Antorus, the Burning Throne", orderIndex = 5},
	[133] = {groupName = "Seat of the Triumvirate", orderIndex = 11},
	[134] = {groupName = "Argus", orderIndex = 0},
	[135] = {groupName = "Uldir", orderIndex = 0},
	[136] = {groupName = "Random Battle for Azeroth Dungeon", orderIndex = 0},
	[137] = {groupName = "Atal'Dazar", orderIndex = 30},
	[138] = {groupName = "The Underrot", orderIndex = 10},
	[139] = {groupName = "Temple of Sethraliss", orderIndex = 30},
	[140] = {groupName = "THE MOTHERLODE!!", orderIndex = 30},
	[141] = {groupName = "Kings' Rest", orderIndex = 30},
	[142] = {groupName = "Freehold", orderIndex = 10},
	[143] = {groupName = "Shrine of the Storm", orderIndex = 30},
	[144] = {groupName = "Tol Dagor", orderIndex = 30},
	[145] = {groupName = "Waycrest Manor", orderIndex = 30},
	[146] = {groupName = "Siege of Boralus", orderIndex = 30},
	[247] = {groupName = "Kul Tiras", orderIndex = 0},
	[248] = {groupName = "Zandalar", orderIndex = 0},
	[249] = {groupName = "Island Expeditions", orderIndex = 0},
	[251] = {groupName = "Battle of Dazar'alor", orderIndex = 0},
	[252] = {groupName = "Crucible of Storms", orderIndex = 0},
	[253] = {groupName = "Operation: Mechagon", orderIndex = 30},
	[254] = {groupName = "The Eternal Palace", orderIndex = 0},
	[255] = {groupName = "Battle for Stromgarde", orderIndex = 0},
	[256] = {groupName = "Operation: Mechagon - Junkyard", orderIndex = 30},
	[257] = {groupName = "Operation: Mechagon - Workshop", orderIndex = 30},
	[258] = {groupName = "Ny'alotha, the Waking City", orderIndex = 0},
	[259] = {groupName = "Plaguefall", orderIndex = 20},
	[260] = {groupName = "De Other Side", orderIndex = 20},
	[261] = {groupName = "Halls of Atonement", orderIndex = 20},
	[262] = {groupName = "Mists of Tirna Scithe", orderIndex = 20},
	[263] = {groupName = "Sanguine Depths", orderIndex = 20},
	[264] = {groupName = "Spires of Ascension", orderIndex = 20},
	[265] = {groupName = "The Necrotic Wake", orderIndex = 20},
	[266] = {groupName = "Theater of Pain", orderIndex = 20},
	[267] = {groupName = "Castle Nathria", orderIndex = 0},
	[269] = {groupName = "World Bosses", orderIndex = 0},
	[270] = {groupName = "Shadowlands", orderIndex = 0},
	[271] = {groupName = "Sanctum of Domination", orderIndex = 0},
	[272] = {groupName = "Tazavesh, the Veiled Market", orderIndex = 20},
	[273] = {groupName = "Twisting Corridors", orderIndex = 0},
	[274] = {groupName = "Skoldus Hall", orderIndex = 1},
	[275] = {groupName = "Upper Reaches", orderIndex = 1},
	[276] = {groupName = "Soulforges", orderIndex = 0},
	[277] = {groupName = "Mort'regar", orderIndex = 0},
	[278] = {groupName = "Fracture Chambers", orderIndex = 0},
	[279] = {groupName = "Coldheart Interstitia", orderIndex = 0},
	[280] = {groupName = "Tazavesh: Streets of Wonder", orderIndex = 20},
	[281] = {groupName = "Tazavesh: So'leah's Gambit", orderIndex = 20},
	[282] = {groupName = "Sepulcher of the First Ones", orderIndex = 0},
	[283] = {groupName = "The Jailer's Gauntlet", orderIndex = 0},
	[284] = {groupName = "Dragon Isles", orderIndex = 0},
	[302] = {groupName = "Algeth'ar Academy", orderIndex = 11},
	[303] = {groupName = "Brackenhide Hollow", orderIndex = 10},
	[304] = {groupName = "Halls of Infusion", orderIndex = 10},
	[305] = {groupName = "Neltharus", orderIndex = 10},
	[306] = {groupName = "Ruby Life Pools", orderIndex = 10},
	[307] = {groupName = "The Azure Vault", orderIndex = 10},
	[308] = {groupName = "The Nokhud Offensive", orderIndex = 10},
	[309] = {groupName = "Uldaman: Legacy of Tyr", orderIndex = 10},
	[310] = {groupName = "Vault of the Incarnates", orderIndex = 0},
	[313] = {groupName = "Aberrus, the Shadowed Crucible", orderIndex = 0},
	[315] = {groupName = "Dawn of the Infinite", orderIndex = 20},
	[316] = {groupName = "Galakrond's Fall - Dawn of the Infinite", orderIndex = 20},
	[317] = {groupName = "Murozond's Rise - Dawn of the Infinite", orderIndex = 20},
	[318] = {groupName = "Galakrond's Fall - Dawn of the Infinite", orderIndex = 20},
	[319] = {groupName = "Amirdrassil, the Dream's Hope", orderIndex = 0},
	[322] = {groupName = "Darkflame Cleft", orderIndex = 10},
	[323] = {groupName = "Ara-Kara, City of Echoes", orderIndex = 10},
	[324] = {groupName = "Priory of the Sacred Flame", orderIndex = 10},
	[325] = {groupName = "The Rookery", orderIndex = 10},
	[326] = {groupName = "The Dawnbreaker", orderIndex = 10},
	[327] = {groupName = "Cinderbrew Meadery", orderIndex = 10},
	[328] = {groupName = "The Stonevault", orderIndex = 10},
	[329] = {groupName = "City of Threads", orderIndex = 10},
	[331] = {groupName = "Fungal Folly", orderIndex = 0},
	[332] = {groupName = "Kriegval's Rest", orderIndex = 0},
	[333] = {groupName = "Earthcrawl Mines", orderIndex = 0},
	[334] = {groupName = "Zekvir's Lair", orderIndex = 13},
	[335] = {groupName = "The Waterworks", orderIndex = 0},
	[336] = {groupName = "The Dread Pit", orderIndex = 0},
	[337] = {groupName = "Nightfall Sanctum", orderIndex = 0},
	[338] = {groupName = "Mycomancer Cavern", orderIndex = 0},
	[339] = {groupName = "The Sinkhole", orderIndex = 0},
	[340] = {groupName = "Skittering Breach", orderIndex = 0},
	[341] = {groupName = "The Underkeep", orderIndex = 0},
	[342] = {groupName = "Tak-Rethan Abyss", orderIndex = 0},
	[343] = {groupName = "The Spiral Weave", orderIndex = 0},
	[344] = {groupName = "Greenstone Village", orderIndex = 0},
	[346] = {groupName = "Unga Ingoo", orderIndex = 0},
	[347] = {groupName = "Arena of Annihilation", orderIndex = 0},
	[348] = {groupName = "Brewmoon Festival", orderIndex = 0},
	[351] = {groupName = "Assault on Zan'vess", orderIndex = 0},
	[352] = {groupName = "Dagger in the Dark", orderIndex = 0},
	[353] = {groupName = "A Little Patience", orderIndex = 0},
	[354] = {groupName = "Domination Point", orderIndex = 0},
	[355] = {groupName = "Lion's Landing", orderIndex = 0},
	[362] = {groupName = "Nerub-ar Palace", orderIndex = 0},
	[363] = {groupName = "Khaz Algar", orderIndex = 0},
	[370] = {groupName = "Windrunner Spire", orderIndex = 10},
	[371] = {groupName = "Operation: Floodgate", orderIndex = 10},
	[372] = {groupName = "Blackrock Depths", orderIndex = 0},
	[373] = {groupName = "Excavation Site 9", orderIndex = 0},
	[374] = {groupName = "Sidestreet Sluice", orderIndex = 0},
	[375] = {groupName = "Underpin's Demolition Competition", orderIndex = 0},
	[377] = {groupName = "Liberation of Undermine", orderIndex = 0},
	[378] = {groupName = "Manaforge Omega", orderIndex = 0},
	[381] = {groupName = "Eco-Dome Al'dani", orderIndex = 10},
	[382] = {groupName = "The Blinding Vale", orderIndex = 10},
	[392] = {groupName = "Den of Nalorakk", orderIndex = 10},
	[394] = {groupName = "Archival Assault", orderIndex = 0},
	[395] = {groupName = "Voidrazor Sanctuary", orderIndex = 0},
	[396] = {groupName = "Murder Row", orderIndex = 0},
	[397] = {groupName = "Midnight", orderIndex = 0},
	[398] = {groupName = "Voidscar Arena", orderIndex = 10},
	[399] = {groupName = "Magisters' Terrace", orderIndex = 10},
	[400] = {groupName = "Maisara Caverns", orderIndex = 10},
	[401] = {groupName = "Nexus-Point Xenas", orderIndex = 10},
	[402] = {groupName = "Voidspire", orderIndex = 0},
	[403] = {groupName = "March on Quel'Danas", orderIndex = 0},
	[404] = {groupName = "The Dreamrift", orderIndex = 0},
	[405] = {groupName = "Collegiate Calamity", orderIndex = 0},
	[406] = {groupName = "Parhelion Plaza", orderIndex = 0},
	[407] = {groupName = "Sunkiller Sanctum", orderIndex = 0},
	[408] = {groupName = "Torment's Rise", orderIndex = 0},
	[409] = {groupName = "Shadowguard Point", orderIndex = 0},
	[410] = {groupName = "The Grudge Pit", orderIndex = 0},
	[411] = {groupName = "Atal'Aman", orderIndex = 0},
	[412] = {groupName = "The Gulf of Memory", orderIndex = 0},
	[413] = {groupName = "The Shadow Enclave", orderIndex = 0},
	[414] = {groupName = "Twilight Crypts", orderIndex = 0},
	[415] = {groupName = "The Darkway", orderIndex = 0},

}

miog.MAP_INFO = {
	[30] = {abbreviatedName = "AV", icon = "interface/lfgframe/lfgicon-battleground.blp", fileName = "pvpbattleground", toastBG = "PvpBg-AlteracValley-ToastBG", pvp = "true"},
	[489] = {abbreviatedName = "WSG", icon = "interface/lfgframe/lfgicon-warsonggulch.blp", fileName = "warsonggulch_update", toastBG = "PvpBg-WarsongGulch-ToastBG", pvp = "true"},
	[529] = {abbreviatedName = "AB", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasin_update", toastBG = "PvpBg-ArathiBasin-ToastBG", pvp = "true"},
	[559] = {abbreviatedName = "NA", icon = "interface/lfgframe/lfgicon-nagrandarena.blp", fileName = "nagrandarenabg", toastBG = "PvpBg-NagrandArena-ToastBG", pvp = "true"},
	[562] = {abbreviatedName = "BEA", icon = "interface/lfgframe/lfgicon-bladesedgearena.blp", fileName = "bladesedgearena", toastBG = "PvpBg-BladesEdgeArena-ToastBG", pvp = "true"},
	[566] = {abbreviatedName = "EOTS", icon = "interface/lfgframe/lfgicon-netherbattlegrounds.blp", fileName = "netherbattleground", toastBG = "PvpBg-EyeOfTheStorm-ToastBG", pvp = "true"},
	[572] = {abbreviatedName = "ROL", icon = "interface/lfgframe/lfgicon-ruinsoflordaeron.blp", fileName = "ruinsoflordaeronbg", toastBG = "PvpBg-RuinsofLordaeron-ToastBG", pvp = "true"},
	[607] = {abbreviatedName = "SOTA", icon = "interface/lfgframe/lfgicon-strandoftheancients.blp", fileName = "northrendbg", toastBG ="PvpBg-StrandOfTheAncients-ToastBG", pvp = "true"},
	[617] = {abbreviatedName = "DS", icon = "interface/lfgframe/lfgicon-dalaransewers.blp", fileName = "dalaransewersarena", toastBG = "PvpBg-DalaranSewers-ToastBG", pvp = "true"},
	[618] = {abbreviatedName = "ROV", icon = "interface/lfgframe/lfgicon-ringofvalor.blp", fileName = "orgrimmararena", toastBG = "PvpBg-TheRingofValor-ToastBG", pvp = "true"},
	[628] = {abbreviatedName = "IOC", icon = "interface/lfgframe/lfgicon-isleofconquest.blp", fileName = "isleofconquest", toastBG = "PvpBg-IsleOfConquest-ToastBG"}, pvp = "true",
	[726] = {abbreviatedName = "TP", icon = "interface/lfgframe/lfgicon-twinpeaksbg.blp", fileName = "twinpeaksbg", toastBG = "PvpBg-TwinPeaks-ToastBG", pvp = "true"},
	[727] = {abbreviatedName = "SSM", icon = "interface/lfgframe/lfgicon-silvershardmines.blp", fileName = "silvershardmines", pvp = "true"},
	[761] = {abbreviatedName = "BFG", icon = "interface/lfgframe/lfgicon-thebattleforgilneas.blp", fileName = "gilneasbg2", toastBG = "PvpBg-Gilneas-ToastBG", pvp = "true"},
	[968] = {abbreviatedName = "EOTS", icon = "interface/lfgframe/lfgicon-netherbattlegrounds.blp", fileName = "netherbattleground", toastBG = "PvpBg-EyeOfTheStorm-ToastBG", pvp = "true"},
	[980] = {abbreviatedName = "TVA", icon = "interface/lfgframe/lfgicon-tolvirarena.blp", fileName = "tolvirarena", pvp = "true"},
	[998] = {abbreviatedName = "TOK", icon = "interface/lfgframe/lfgicon-templeofkotmogu.blp", fileName = "templeofkotmogu", pvp = "true"},
	[1105] = {abbreviatedName = "DWD", icon = "interface/lfgframe/lfgicon-deepwindgorge.blp", fileName = "goldrush", pvp = "true"},
	[1134] = {abbreviatedName = "TP", icon = "interface/lfgframe/lfgicon-shadopanbg.blp", fileName = "shadowpan_bg", pvp = "true"},
	[1191] = {abbreviatedName = "ASH", icon = "interface/lfgframe/lfgicon-ashran.blp", fileName = "ashran", pvp = "true"},
	[1504] = {abbreviatedName = "BRH", icon = "interface/lfgframe/lfgicon-blackrookholdarena.blp", fileName = "blackrookholdarena", pvp = "true"},
	[1505] = {abbreviatedName = "NA", icon = "interface/lfgframe/lfgicon-nagrandarena.blp", fileName = "nagrandarenabg", toastBG = "PvpBg-NagrandArena-ToastBG", pvp = "true"},
	[1552] = {abbreviatedName = "AF", icon = "interface/lfgframe/lfgicon-valsharraharena.blp", fileName = "arenavalsharah", pvp = "true"},
	[1672] = {abbreviatedName = "BEA", icon = "interface/lfgframe/lfgicon-bladesedgearena.blp", fileName = "bladesedgearena", toastBG = "PvpBg-BladesEdgeArena-ToastBG", pvp = "true"},
	[1681] = {abbreviatedName = "AB-W", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasinwinter", toastBG = "PvpBg-ArathiBasin-ToastBG", pvp = "true"},
	[1715] = {abbreviatedName = "BBM", icon = "interface/lfgframe/lfgicon-blackrockdepths.blp", fileName = "blackrockdepths", pvp = "true"},
	[1782] = {abbreviatedName = "SST", icon = "interface/lfgframe/lfgicon-seethingshore.blp", fileName = "seethingshore", pvp = "true"},
	[1803] = {abbreviatedName = "SSH", icon = "interface/lfgframe/lfgicon-seethingshore.blp", fileName = "seethingshore", pvp = "true"},
	[1804] = {abbreviatedName = "SG", icon="world/expansion07/doodads/fx/8fx_stromgarge_portal.blp", fileName = "stromgarde", pvp="true"},
	[2106] = {abbreviatedName = "WSG", icon = "interface/lfgframe/lfgicon-warsonggulch.blp", fileName = "warsonggulch_update", toastBG = "PvpBg-WarsongGulch-ToastBG", pvp = "true"},
	[2107] = {abbreviatedName = "AB", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasin_update", toastBG = "PvpBg-ArathiBasin-ToastBG", pvp = "true"},
	[2177] = {abbreviatedName = "AB", icon = "interface/lfgframe/lfgicon-arathibasin.blp", fileName = "arathibasin_update", toastBG = "PvpBg-ArathiBasin-ToastBG", pvp = "true"},
	[2118] = {abbreviatedName = "BFW", icon = "interface/lfgframe/lfgicon-battleground.blp", fileName = "wintergrasp", pvp = "true"},
	[2245] = {abbreviatedName = "DWG", icon = "interface/lfgframe/lfgicon-deepwindgorge.blp", fileName = "goldrush", pvp = "true"},
		
	--VANILLA
	[36] = {abbreviatedName = "DM", fileName = "deadmines"},
	[43] = {abbreviatedName = "WC", fileName = "wailingcaverns"},
	[389] = {abbreviatedName = "RFC", fileName = "ragefirechasm"},
	[48] = {abbreviatedName = "BFD", fileName = "blackfathomdeeps"},
	[34] = {abbreviatedName = "SS", fileName = "stormwindstockades"},
	[90] = {abbreviatedName = "GR", fileName = "gnomeregan"},
	[47] = {abbreviatedName = "RFK", fileName = "razorfenkraul"},
	[129] = {abbreviatedName = "RFD", fileName = "razorfendowns"},
	[70] = {abbreviatedName = "ULD", fileName = "uldaman"},
	[209] = {abbreviatedName = "ZF", fileName = "zulfarak"},
	[349] = {abbreviatedName = "MAU", fileName = "maraudon"},
	[109] = {abbreviatedName = "ST", fileName = "sunkentemple"},
	[230] = {abbreviatedName = "BRD", fileName = "blackrockdepths"},
	[229] = {abbreviatedName = "BRS", fileName = "blackrockspire"},
	[429] = {abbreviatedName = "DM", fileName = "diremaul"},
	[329] = {abbreviatedName = "SH", iconName = "oldstratholme", fileName = "stratholme"},
	[1007] = {abbreviatedName = "SCM", fileName = "scholomance"},
	[33] = {abbreviatedName = "SFK", fileName = "shadowfangkeep"},

	[409] = {abbreviatedName = "MC", fileName = "moltencore"},
	[469] = {abbreviatedName = "BWL", fileName = "blackwinglair"},
	[509] = {abbreviatedName = "AQ20", fileName = "aqruins"},
	[531] = {abbreviatedName = "AQ40",  fileName = "aqtemple"},

	--THE BURNING CRUSADE
	[543] = {abbreviatedName = "RAMPS", fileName = "hellfirecitadel"},
	[542] = {abbreviatedName = "BF", fileName = "hellfirecitadel"},
	[540] = {abbreviatedName = "SH", fileName = "hellfirecitadel"},
	[547] = {abbreviatedName = "SP", fileName = "coilfang"},
	[546] = {abbreviatedName = "UB", fileName = "coilfang"},
	[545] = {abbreviatedName = "SV", fileName = "coilfang"},
	[557] = {abbreviatedName = "MT", fileName = "auchindoun"},
	[558] = {abbreviatedName = "CRYPTS", fileName = "auchindoun"},
	[556] = {abbreviatedName = "SETH", fileName = "auchindoun"},
	[555] = {abbreviatedName = "SL", fileName = "auchindoun"},
	[1001] = {abbreviatedName = "SH", fileName = "scarlethalls"},
	[1004] = {abbreviatedName = "SM", fileName = "scarletmonastery"},
	[560] = {abbreviatedName = "EFD", fileName = "cavernsoftime"},
	[269] = {abbreviatedName = "BM", fileName = "cavernsoftime"},
	[554] = {abbreviatedName = "MECH", fileName = "tempestkeep"},
	[553] = {abbreviatedName = "BOTA", fileName = "tempestkeep"},
	[552] = {abbreviatedName = "ARC", fileName = "tempestkeep"},
	[585] = {abbreviatedName = "MGT", fileName = "magistersterrace"},
	
	[534] = {abbreviatedName = "BMH", fileName = "hyjalpast"},
	[565] = {abbreviatedName = "GL", fileName = "gruulslair"},
	[544] = {abbreviatedName = "ML", fileName = "hellfireraid"},
	[548] = {abbreviatedName = "SSC", iconName = "serpentshrinecavern", fileName = "coilfang"},
	[532] = {abbreviatedName = "KARA", fileName = "karazhan"},
	[564] = {abbreviatedName = "BT", fileName = "blacktemple"},
	[550] = {abbreviatedName = "TK", fileName = "tempestkeep"},
	[580] = {abbreviatedName = "SW", fileName = "sunwell"},

	--WRATH OF THE LICH KING
	[574] = {abbreviatedName = "UTK", fileName = "utgarde"},
	[575] = {abbreviatedName = "UTP", fileName = "utgardepinnacle"},
	[601] = {abbreviatedName = "AN", fileName = "azjolnerub"},
	[578] = {abbreviatedName = "OCU", fileName = "theoculus"},
	[602] = {abbreviatedName = "HOL", fileName = "hallsoflightning"},
	[599] = {abbreviatedName = "HOS", fileName = "hallsofstone"},
	[595] = {abbreviatedName = "CULL", fileName = "stratholme"},
	[600] = {abbreviatedName = "DTK", fileName = "draktharon"},
	[604] = {abbreviatedName = "GUN", fileName = "gundrak"},
	[619] = {abbreviatedName = "ATOK", fileName = "ahnkalet"},
	[608] = {abbreviatedName = "VH", fileName = "theviolethold"},
	[576] = {abbreviatedName = "NEX", fileName = "thenexus"},
	[650] = {abbreviatedName = "TOTC", fileName = "argentdungeon"},
	[632] = {abbreviatedName = "FOS", fileName = "theforgeofsouls"},
	[658] = {abbreviatedName = "PIT", fileName = "pitofsaron"},
	[668] = {abbreviatedName = "HOR", fileName = "hallsofreflection"},
	
	[615] = {abbreviatedName = "OS", fileName = "chamberofaspects"},
	[533] = {abbreviatedName = "NAXX", fileName = "naxxramas"},
	[624] = {abbreviatedName = "VOA", fileName = "vaultofarchavon"},
	[603] = {abbreviatedName = "ULD", fileName = "ulduar"},
	[616] = {abbreviatedName = "EOE", fileName = "malygos"},
	[649] = {abbreviatedName = "TOTC", fileName = "argentraid"},
	[631] = {abbreviatedName = "ICC", fileName = "icecrowncitadel"},
	[249] = {abbreviatedName = "ONY", fileName = "onyxiaencounter"},
	[724] = {abbreviatedName = "RS", fileName = "rubysanctum"},

	-- CATACLYSM
	[859] = {abbreviatedName = "ZG", fileName = "zulgurub"},
	[568] = {abbreviatedName = "ZA", fileName = "zulaman"},
	[938] = {abbreviatedName = "ET", fileName = "endtime"},
	[939] = {abbreviatedName = "WOE", fileName = "wellofeternity"},
	[940] = {abbreviatedName = "HOT", fileName = "houroftwilight"},
	[645] = {abbreviatedName = "BRC", fileName = "blackrockcaverns"},
	[670] = {abbreviatedName = "GB", fileName = "grimbatol"},
	[644] = {abbreviatedName = "HOO", fileName = "hallsoforigination"},
	[725] = {abbreviatedName = "SC", fileName = "thestonecore"},
	[755] = {abbreviatedName = "LCT", fileName = "lostcityoftolvir"},
	[643] = {abbreviatedName = "TOTT", fileName = "throneofthetides"},
	[657] = {abbreviatedName = "VP", fileName = "thevortexpinnacle"},
	[669] = {abbreviatedName = "BWD", fileName = "blackwingdescentraid"},
	[671] = {abbreviatedName = "BOT", fileName = "grimbatolraid"},
	[754] = {abbreviatedName = "TOTFW", fileName = "throneofthefourwinds"},
	[757] = {abbreviatedName = "BH", fileName = "baradinhold"},
	[720] = {abbreviatedName = "FL", fileName = "firelands"},
	[967] = {abbreviatedName = "DS", fileName = "dragonsoul"},

	-- MISTS OF PANDARIA
	--[870] = {abbreviatedName = "RPD", icon = ""}, --RANDOM PANDARIA DUNGEON
	[960] = {abbreviatedName = "TOTJS", fileName = "templeofthejadeserpent"},
	[961] = {abbreviatedName = "SSB", fileName = "stormstoutbrewery"},
	[959] = {abbreviatedName = "SPM", fileName = "shadowpanmonastery"},
	[994] = {abbreviatedName = "MSP", fileName = "mogushanpalace"},
	[1011] = {abbreviatedName = "SNT", fileName = "siegeofnizaotemple"},
	[962] = {abbreviatedName = "GATE", fileName = "gateofthesettingsun"},
	[1008] = {abbreviatedName = "MSV",  fileName = "mogushanvaults"},
	[1009] = {abbreviatedName = "HOF", fileName = "heartoffear"},
	[996] = {abbreviatedName = "TOES", fileName = "terraceoftheendlessspring"},
	[1098] = {abbreviatedName = "TOT", fileName = "thunderpinnacle"},
	[1136] = {abbreviatedName = "SOO", fileName = "orgrimmargates"},
	
	-- WARLORDS OF DRAENOR
	--[1116] = {abbreviatedName = "RWD", icon = ""}, --RANDOM WARLORDS DUNGEON
	[1175] = {abbreviatedName = "BSM", fileName = "bloodmaulslagmines"},
	[1195] = {abbreviatedName = "ID", fileName = "irondocks"},
	[1182] = {abbreviatedName = "AUCH", fileName = "auchindounwod"},
	[1209] = {abbreviatedName = "SR", fileName = "skyreach"},
	[1208] = {abbreviatedName = "GD", fileName = "grimraildepot"},
	[1358] = {abbreviatedName = "UBRS", fileName = "upperblackrockspire"},
	[1176] = {abbreviatedName = "SBG", fileName = "shadowmoonburialgrounds"},
	[1279] = {abbreviatedName = "EB", fileName = "everbloom"},
	[1228] = {abbreviatedName = "HM", fileName = "highmaul"},
	[1205] = {abbreviatedName = "BRF", fileName = "blackrockfoundry"},
	[1448] = {abbreviatedName = "HFC", fileName = "hellfireraid"},

	--LEGION
	--[1220] = {abbreviatedName = "RLD", icon = ""}, --RANDOM LEGION DUNGEON
	[1458] = {abbreviatedName = "NL", fileName = "neltharionslair"},
	[1466] = {abbreviatedName = "DHT", fileName = "darkheartthicket"},
	[1477] = {abbreviatedName = "HOV", fileName = "hallsofvalor"},
	[1571] = {abbreviatedName = "COS", fileName = "courtofstars"},
	[1501] = {abbreviatedName = "BRH", fileName = "blackrookhold"},
	[1456] = {abbreviatedName = "EOA", fileName = "eyeofazshara"},
	[1544] = {abbreviatedName = "AOVH", fileName = "assaultonviolethold"},
	[1493] = {abbreviatedName = "VOTW", fileName = "vaultofthewardens"},
	[1492] = {abbreviatedName = "MOS", fileName = "mawofsouls"},
	[1516] = {abbreviatedName = "ARC", fileName = "thearcway"},
	[1753] = {abbreviatedName = "SEAT", fileName = "seatofthetriumvirate"},
	[1651] = {abbreviatedName = "RTK", fileName = "returntokarazhan"},
	[1677] = {abbreviatedName = "COEN", fileName = "cathedralofeternalnight"},

	[1520] = {abbreviatedName = "EN", fileName = "theemeraldnightmare-riftofaln"},
	[1530] = {abbreviatedName = "NH", fileName = "thenighthold"},
	[1648] = {abbreviatedName = "TOV", fileName = "trialofvalor"},
	[1676] = {abbreviatedName = "TOS", iconName = "tombofsargerasdeceiversfall", fileName = "tombofsargeras"},
	[1712] = {abbreviatedName = "ATBT", fileName = "antorus"},

	-- BATTLE FOR AZEROTH
	--[1642] = {abbreviatedName = "RBD", icon = ""}, --RANDOM BFA DUNGEON
	[1861] = {abbreviatedName = "ULDIR", fileName = "uldir"},
	[1754] = {abbreviatedName = "FH", fileName = "freehold"},
	[1763] = {abbreviatedName = "AD", fileName = "ataldazar"},
	[1841] = {abbreviatedName = "UR", fileName = "theunderrot"},
	[1862] = {abbreviatedName = "WM", fileName = "waycrestmanor"},
	[1877] = {abbreviatedName = "TOS", fileName = "templeofsethraliss"},
	[1594] = {abbreviatedName = "ML", fileName = "themotherlode"},
	[1762] = {abbreviatedName = "KR", fileName = "kingsrest"},
	[1864] = {abbreviatedName = "SOTS", fileName = "shrineofthestorm"},
	[1771] = {abbreviatedName = "TD", fileName = "toldagor"},
	[1822] = {abbreviatedName = "SOB", fileName = "siegeofboralus"},
	[2070] = {abbreviatedName = "BOD", fileName = "battleofdazaralor"},
	[2096] = {abbreviatedName = "COS", fileName = "crucibleofstorms"},
	[2164] = {abbreviatedName = "EP", fileName = "eternalpalace"},
	[2097] = {abbreviatedName = "MECH", fileName = "mechagon"},
	[2217] = {abbreviatedName = "NYA", fileName = "nyalotha"},
	
	--SHADOWLANDS
	[2289] = {abbreviatedName = "PF", fileName = "plaguefall"},
	[2291] = {abbreviatedName = "DOS", fileName = "theotherside"},
	[2287] = {abbreviatedName = "HOA", fileName = "hallsofatonement"},
	[2290] = {abbreviatedName = "MOTS", fileName = "mistsoftirnascithe"},
	[2284] = {abbreviatedName = "SD", fileName = "sanguinedepths"},
	[2285] = {abbreviatedName = "SOA", fileName = "spiresofascension"},
	[2286] = {abbreviatedName = "NW", fileName = "necroticwake"},
	[2293] = {abbreviatedName = "TOP", fileName = "theaterofpain"},
	[2296] = {abbreviatedName = "CN", fileName = "castlenathria"},
	[2441] = {abbreviatedName = "TAZA", fileName = "tazaveshtheveiledmarket"},
	[2450] = {abbreviatedName = "SOD", fileName = "sanctumofdomination"},
	[2481] = {abbreviatedName = "SFO", fileName = "sepulcherofthefirstones"},
	[2559] = {abbreviatedName = "WRLD", iconName = "shadowlands", fileName = "shadowlandscontinent",},

	--DRAGONFLIGHT
	[2451] = {abbreviatedName = "ULOT", fileName = "uldaman-legacyoftyr"},
	[2515] = {abbreviatedName = "AV", iconName = "arcanevaults", fileName = "azurevaults"},
	[2516] = {abbreviatedName = "NO", iconName = "centaurplains", fileName = "nokhudoffensive"},
	[2519] = {abbreviatedName = "NELT", fileName = "neltharus"},
	[2520] = {abbreviatedName = "BH", fileName = "brackenhidehollow"},
	[2521] = {abbreviatedName = "RLP", fileName = "lifepools"},
	[2526] = {abbreviatedName = "AA", fileName = "theacademy"},
	[2527] = {abbreviatedName = "HOI", fileName = "hallsofinfusion"},
	[2574] = {abbreviatedName = "WRLD", fileName = "dragonislescontinent",},
	[2579] = {abbreviatedName = "DOTI", fileName = "dawnoftheinfinite"},

	
	[2444] = {
		abbreviatedName = "WRLD", icon = miog.C.STANDARD_FILE_PATH .. "/bossIcons/dragonislescontinent.png", type="exp", fileName = "dragonislescontinent",
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
		abbreviatedName = "ATDH",
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
		abbreviatedName = "ATSC",
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
		abbreviatedName = "VOTI",
		fileName = "vaultoftheincarnates",
	},

	-- THE WAR WITHIN
	[2601] = {abbreviatedName = "KA", iconName = "khazalgar"},
	[2648] = {abbreviatedName = "ROOK", fileName = "therookery"},
	[2649] = {abbreviatedName = "PSF", fileName = "prioryofthesacredflames"},
	[2651] = {abbreviatedName = "DFC", fileName = "darkflamecleft"},
	[2652] = {abbreviatedName = "SV", fileName = "thestonevault"},
	[2660] = {abbreviatedName = "AK", fileName = "arakaracityofechoes"},
	[2661] = {abbreviatedName = "CBM", fileName = "cinderbrewmeadery"},
	[2662] = {abbreviatedName = "DB", fileName = "thedawnbreaker"},
	[2669] = {abbreviatedName = "COT", fileName = "cityofthreads"},
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
		abbreviatedName = "NP",
		iconName = "nerubarpalance",
		fileName = "nerubarpalace",
		achievementIDs = {
			40267,
			40268,
			40269,
			40270,
			40271,
			40272,
			40273,
			40274,
			40275,
			40276,
			40277,
			40278,
			40279,
			40280,
			40281,
			40282,
			40283,
			40284,
			40285,
			40286,
			40287,
			40288,
			40289,
			40290,
			40291,
			40292,
			40293,
			40294,
			40295,
			40296,
			40297,
			40298,
		}
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
		abbreviatedName = "LOU",
		fileName = "casino",
		achievementIDs = {
			41299,
			41300,
			41301,
			41302,
			41303,
			41304,
			41305,
			41306,
			41307,
			41308,
			41309,
			41310,
			41311,
			41312,
			41313,
			41314,
			41315,
			41316,
			41317,
			41318,
			41319,
			41320,
			41321,
			41322,
			41323,
			41324,
			41325,
			41326,
			41327,
			41328,
			41329,
			41330,
		}
	},

	
	--interface/delves/110
	[2664] = {abbreviatedName = "FF", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "fungalfolly",},
	[2679] = {abbreviatedName = "MMC", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "mycomancercavern",},
	[2680] = {abbreviatedName = "ECM", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "earthcrawlmines",},
	[2681] = {abbreviatedName = "KR", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "kriegvalsrest",},
	[2682] = {abbreviatedName = "ZL", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "zekvirslair",},
	[2683] = {abbreviatedName = "WW", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "delve_waterworks",},
	[2684] = {abbreviatedName = "DP", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "dreadpit",},
	[2685] = {abbreviatedName = "SB", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "skitteringbreach",},
	[2686] = {abbreviatedName = "NFS", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "nightfallsanctum",},
	[2687] = {abbreviatedName = "SH", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "sinkhole",},
	[2688] = {abbreviatedName = "SW", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "spiralweave",},
	[2689] = {abbreviatedName = "TRA", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "takrethanabyss",},
	[2690] = {abbreviatedName = "UK", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "underkeep",},
	[2692] = {abbreviatedName = "HOA", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "hallofawakening",},
	[2710] = {abbreviatedName = "ATM", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "awakeningthemachine",},
	[2767] = {abbreviatedName = "SH", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "sinkhole",},
	[2768] = {abbreviatedName = "TRA", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "takrethanabyss",},

	--interface/delves/111
	[2815] = {abbreviatedName = "ES9", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "excavationsite9",},
	[2826] = {abbreviatedName = "SS", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "sidestreetsluice",},
	[2831] = {abbreviatedName = "UDC", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "underpinsdemolitioncompetition",},

	--interface/delves/112
	[2803] = {abbreviatedName = "AA", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "archivalassault",},
	[2951] = {abbreviatedName = "VRS", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/delves.png", fileName = "voidrazorsanctuary",},
	
	[2773] = {abbreviatedName = "OF", fileName = "waterworks"},
	[2774] = {abbreviatedName = "WRLD", fileName = "khazalgar",},
	[2776] = {abbreviatedName = "CODEX", fileName = "kalimdor",},

	[2792] = {abbreviatedName = "BRD", fileName = "blackrockdepths"},

	
	[2810] = {
		bossIcons = {
			{icon = "interface/icons/inv_112_achievement_raid_automaton.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_silkworm.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_binder.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_engineer.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_dhcouncil.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_glasselemental.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_salhadaar.blp"},
			{icon = "interface/icons/inv_112_achievement_raid_dimensius.blp"},
		},
		abbreviatedName = "MFO",
		fileName = "manaforge",
		achievementIDs = {
			41633,
			41634,
			41635,
			41636,
			41637,
			41638,
			41639,
			41640,
			41641,
			41642,
			41643,
			41644,
			41645,
			41646,
			41647,
			41648,
			41649,
			41650,
			41651,
			41652,
			41653,
			41654,
			41655,
			41656,
			41657,
			41658,
			41659,
			41660,
			41661,
			41662,
			41663,
			41664,
		}
	},
	[2827] = {abbreviatedName = "HVS", fileName = "horrificvisionstormwind"},
	[2828] = {abbreviatedName = "HVO", fileName = "horrificvisionorgrimmar"},
	[2830] = {abbreviatedName = "EDA", fileName = "ecodome"},
	[2849] = {abbreviatedName = "DD", fileName = "dastardlydome"},
	[2872] = {abbreviatedName = "UM", fileName = "undermine"},

	[2805] = {abbreviatedName = "WS", fileName = "windrunnerspire"},
	[2811] = {abbreviatedName = "MT", fileName = "magistersterrace"},
	[2813] = {abbreviatedName = "MR", fileName = "murderrow"},
	[2825] = {abbreviatedName = "DON", fileName = "proveyourworth"},
	[2859] = {abbreviatedName = "BV", fileName = "lightbloom"},
	[2874] = {abbreviatedName = "MC", fileName = "maisarahills"},
	[2915] = {abbreviatedName = "NPX", fileName = "nexuspointxenas"},
	[2923] = {abbreviatedName = "VA", fileName = "domanaararena"},

	[2912] = {abbreviatedName = "VS", fileName = "voidspire",
		bossIcons = {
			{icon = "interface/icons/inv_120_raid_voidspire_hostgeneral.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_kaiju.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_salhadaar.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_dragonduo.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_paladintrio.blp"},
			{icon = "interface/icons/inv_120_raid_voidspire_alleria.blp"},
		},
	},
	[2913] = {abbreviatedName = "MQD", fileName = "darkwell"},
	[2930] = {abbreviatedName = "MN", fileName = "midnight"},
	[2939] = {abbreviatedName = "DR", fileName = "riftofaln",
		bossIcons = {
			{icon = "interface/icons/inv_120_raid_dreamwell_malformedmanifestation.blp"},
		},
	},
}

miog.CHALLENGE_MODE_INFO = {
	[2] = {name = "Temple of the Jade Serpent", mapID = 960},
	[56] = {name = "Stormstout Brewery", mapID = 961},
	[57] = {name = "Gate of the Setting Sun", mapID = 962},
	[58] = {name = "Shado-Pan Monastery", mapID = 959},
	[59] = {name = "Siege of Niuzao Temple", mapID = 1011},
	[60] = {name = "Mogu'shan Palace", mapID = 994},
	[76] = {name = "Scholomance", mapID = 1007},
	[77] = {name = "Scarlet Halls", mapID = 1001},
	[78] = {name = "Scarlet Monastery", mapID = 1004},
	[161] = {name = "Skyreach", mapID = 1209},
	[163] = {name = "Bloodmaul Slag Mines", mapID = 1175},
	[164] = {name = "Auchindoun", mapID = 1182},
	[165] = {name = "Shadowmoon Burial Grounds", mapID = 1176},
	[166] = {name = "Grimrail Depot", mapID = 1208},
	[167] = {name = "Upper Blackrock Spire", mapID = 1358},
	[168] = {name = "The Everbloom", mapID = 1279},
	[169] = {name = "Iron Docks", mapID = 1195},
	[197] = {name = "Eye of Azshara", mapID = 1456},
	[198] = {name = "Darkheart Thicket", mapID = 1466},
	[199] = {name = "Black Rook Hold", mapID = 1501},
	[200] = {name = "Halls of Valor", mapID = 1477},
	[206] = {name = "Neltharion's Lair", mapID = 1458},
	[207] = {name = "Vault of the Wardens", mapID = 1493},
	[208] = {name = "Maw of Souls", mapID = 1492},
	[209] = {name = "The Arcway", mapID = 1516},
	[210] = {name = "Court of Stars", mapID = 1571},
	[227] = {name = "Return to Karazhan: Lower", mapID = 1651},
	[233] = {name = "Cathedral of Eternal Night", mapID = 1677},
	[234] = {name = "Return to Karazhan: Upper", mapID = 1651},
	[239] = {name = "Seat of the Triumvirate", mapID = 1753},
	[244] = {name = "Atal'Dazar", mapID = 1763},
	[245] = {name = "Freehold", mapID = 1754},
	[246] = {name = "Tol Dagor", mapID = 1771},
	[247] = {name = "The MOTHERLODE!!", mapID = 1594},
	[248] = {name = "Waycrest Manor", mapID = 1862},
	[249] = {name = "Kings' Rest", mapID = 1762},
	[250] = {name = "Temple of Sethraliss", mapID = 1877},
	[251] = {name = "The Underrot", mapID = 1841},
	[252] = {name = "Shrine of the Storm", mapID = 1864},
	[353] = {name = "Siege of Boralus", mapID = 1822},
	[369] = {name = "Operation: Mechagon - Junkyard", mapID = 2097, abbreviatedName = "JUNK"},
	[370] = {name = "Operation: Mechagon - Workshop", mapID = 2097, abbreviatedName = "SHOP"},
	[375] = {name = "Mists of Tirna Scithe", mapID = 2290},
	[376] = {name = "The Necrotic Wake", mapID = 2286},
	[377] = {name = "De Other Side", mapID = 2291},
	[378] = {name = "Halls of Atonement", mapID = 2287},
	[379] = {name = "Plaguefall", mapID = 2289},
	[380] = {name = "Sanguine Depths", mapID = 2284},
	[381] = {name = "Spires of Ascension", mapID = 2285},
	[382] = {name = "Theater of Pain", mapID = 2293},
	[391] = {name = "Tazavesh: Streets of Wonder", mapID = 2441, abbreviatedName = "STRTS"},
	[392] = {name = "Tazavesh: So'leah's Gambit", mapID = 2441, abbreviatedName = "GMBT"},
	[399] = {name = "Ruby Life Pools", mapID = 2521},
	[400] = {name = "The Nokhud Offensive", mapID = 2516},
	[401] = {name = "The Azure Vault", mapID = 2515},
	[402] = {name = "Algeth'ar Academy", mapID = 2526},
	[403] = {name = "Uldaman: Legacy of Tyr", mapID = 2451},
	[404] = {name = "Neltharus", mapID = 2519},
	[405] = {name = "Brackenhide Hollow", mapID = 2520},
	[406] = {name = "Halls of Infusion", mapID = 2527},
	[438] = {name = "The Vortex Pinnacle", mapID = 657},
	[456] = {name = "Throne of the Tides", mapID = 643},
	[463] = {name = "Dawn of the Infinite: Galakrond's Fall", mapID = 2579, abbreviatedName = "FALL"},
	[464] = {name = "Dawn of the Infinite: Murozond's Rise", mapID = 2579, abbreviatedName = "RISE"},
	[499] = {name = "Priory of the Sacred Flame", mapID = 2649},
	[500] = {name = "The Rookery", mapID = 2648},
	[501] = {name = "The Stonevault", mapID = 2652},
	[502] = {name = "City of Threads", mapID = 2669},
	[503] = {name = "Ara-Kara, City of Echoes", mapID = 2660},
	[504] = {name = "Darkflame Cleft", mapID = 2651},
	[505] = {name = "The Dawnbreaker", mapID = 2662},
	[506] = {name = "Cinderbrew Meadery", mapID = 2661},
	[507] = {name = "Grim Batol", mapID = 670},
	[525] = {name = "Operation: Floodgate", mapID = 2773},
	[541] = {name = "The Stonecore", mapID = 725},
	[542] = {name = "Eco-Dome Al'dani", mapID = 2830},
	[556] = {name = "Pit of Saron", mapID = 658},
	[557] = {name = "Windrunner Spire", mapID = 2805},
	[558] = {name = "Magisters' Terrace", mapID = 2811},
	[559] = {name = "Nexus-Point Xenas", mapID = 2915},
	[560] = {name = "Maisara Caverns", mapID = 2874},
	[583] = {name = "Seat of the Triumvirate", mapID = 1753},
}

miog.LFG_ID_INFO = {
	[1453] = { abbreviatedName = "TWMOP", icon = "interface/lfgframe/lfgicon-pandaria.blp", fileName = "pandaria"}, --RANDOM PANDARIA DUNGEON
	[1971] = {abbreviatedName = "RWD", icon = "interface/lfgframe/lfgicon-draenor.blp", fileName = "draenor"}, --RANDOM WARLORDS DUNGEON
	[2350] = { abbreviatedName = "LFDN", icon = "interface/lfgframe/lfgicon-dragonislescontinent.blp", fileName = "dragonislescontinent"},
	[2351] = { abbreviatedName = "LFDH", icon = "interface/lfgframe/lfgicon-dragonislescontinent.blp", fileName = "dragonislescontinent"},
	[2516] = { abbreviatedName = "LFTN", icon = "interface/lfgframe/lfgicon-khazalgar.blp", fileName = "khazalgar"},
	[2517] = { abbreviatedName = "LFTH", icon = "interface/lfgframe/lfgicon-khazalgar.blp", fileName = "khazalgar"},
	[2723] = { abbreviatedName = "LFTS1", icon = "interface/lfgframe/lfgicon-khazalgar.blp", fileName = "khazalgar"},
}

miog.MAP_ID_TEMPLATES = {
	[2657] = "MIOG_SearchPanelRaidNerubarTemplate",
	[2769] = "MIOG_SearchPanelRaidUndermineTemplate",
	[2810] = "MIOG_SearchPanelRaidManaforgeTemplate",
	
}

for k, v in pairs(miog.LFG_ID_INFO) do
	v.horizontal = miog.C.STANDARD_FILE_PATH .. "/backgrounds/horizontal/" .. v.fileName .. ".png"
end

miog.GROUP_ACTIVITY = {  -- https://wago.tools/db2/GroupFinderActivityGrp
}

miog.ACTIVITY_INFO = {}

miog.PVP_BRACKET_INFO = {
	{id = 7, alias = PVP_RATED_SOLO_SHUFFLE, shortName = "Solo", fileName = "tolvirarena"}, --Solo Arena
	{id = 9, alias = PVP_RATED_BG_BLITZ, shortName = "Solo BG", fileName = "twinpeaksbg"}, --Solo BG
	{id = 1, alias = ARENA_2V2, shortName = ARENA_2V2, fileName = "enigmaarena"}, --2v2
	{id = 2, alias = ARENA_3V3, shortName = ARENA_3V3, fileName = "blackrookholdarena"}, --3v3
	--{id = 3, alias = ARENA_5V5, shortName = ARENA_5V5, fileName = "maldraxxuscoliseum"}, --5v5
	{id = 4, alias = BATTLEGROUND_10V10, shortName = BATTLEGROUND_10V10, fileName = "earthenbattleground"}, --10v10

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

local database = {
	pointers = {
		map = {},
		activity = {},
		unlistedActivities = {},
		groups = {},
		journal = {},
		encounters = {},
		categories = {}
	}
}

--- used usually during prepatch
local manualData = {
	activity = {
		--MIDNIGHT
			--Dungeons
				--The Blinding Vale
				1699, --N
				1700, --H
				1701, --M

				--Voidscar Arena
				1754, --N
				1755, --H
				1756, --M

				--Den of Nalorakk
				1721, --N
				1722, --H
				1723, --M

				--Murder Row
				1749, --N
				1750, --H
				1751, --M

				--Nexus-Point Xenas
				1765, --N
				1766, --H
				1767, --M
				1768, --M+

				--Maisara Caverns
				1761, --N
				1762, --H
				1763, --M
				1764, --M+

				--Windrunner Spire
				1539, --N
				1540, --H
				1541, --M
				1542, --M+

				--Magisters' Terrace
				1757, --N
				1758, --H
				1759, --M
				1760, --M+

			--M+
				--Seat of the Triumvirate
				1622, --M
				486, --M+

				--Pit of Saron
				1769, --M
				1770, --M+

				--Algeth'ar Academy
				1159, --M
				1160, --M+

				--Skyreach
				404, --M
				182, --M+

			--Raids
				--The Voidspire
				1772, --N
				1773, --H
				1774, --M

				--March on Quel'Danas
				1775, --N
				1776, --H
				1777, --M

				--The Dreamrift
				1778, --N
				1779, --H
				1780, --M

	}
}

miog.manualData = manualData
miog.database = database

function miog:GetUnlistedActivities()
	return miog.database.pointers.unlistedActivities
end

function miog:IntegrateMapDataIntoJournal(journalInstanceID, mapID)
	local instanceID = journalInstanceID or C_EncounterJournal.GetInstanceForGameMap(mapID)

	if(instanceID) then
		local journalDB = database.pointers.journal[instanceID] or miog:RetrieveJournalInstanceInfoFromJournalInstanceID(instanceID)

		if(journalDB) then
			local map = mapID or journalDB.mapID
			local mapDB = database.pointers.map[map]
			
			if(mapDB) then
				journalDB.abbreviatedName = miog.MAP_INFO[map].abbreviatedName
				journalDB.horizontal = mapDB.horizontal
				journalDB.vertical = mapDB.vertical

				--journalDB.icon = miog.MAP_INFO[map].icon
				--journalDB.fileName = miog.MAP_INFO[map].fileName
				--journalDB.toastBG = miog.MAP_INFO[map].toastBG
				--journalDB.pvp = miog.MAP_INFO[map].pvp
			end
		end
	end
end

function miog:UpdateJournalDB()
	local journalDB = database.pointers.journal

	for index, journalInstanceInfo in pairs(journalDB) do
		if(not journalInstanceInfo.icon and journalInstanceInfo.mapID) then
			miog:IntegrateMapDataIntoJournal(journalInstanceInfo.journalInstanceID, journalInstanceInfo.mapID)

		end
	end
end

function miog:ConvertInstanceEncounterDataToBossData(journalInstanceID)
	local journalDB = database.pointers.journal[journalInstanceID]

	local bossDB = {}

	for k, v in pairs(journalDB.encounters) do
		tinsert(bossDB, v)

	end

	table.sort(bossDB, function(k1, k2)
		return k1.journalEncounterID < k2.journalEncounterID

	end)

	for k, v in ipairs(bossDB) do
		v.index = k

	end

	journalDB.bosses = bossDB
end

function miog:SaveJournalEncounterDataWithPreData(journalEncounterID, bossName, journalInstanceID, dungeonEncounterID, mapID, bossIndex)
	if(bossName) then
		local journalDB = database.pointers.journal[journalInstanceID]

		local id, altName, _, creatureDisplayInfoID, icon, _ = EJ_GetCreatureInfo(1, journalEncounterID) --always get first creature of encounter (boss)

		local db = {
			name = bossName,
			altName = altName,
			journalEncounterID = journalEncounterID,
			journalInstanceID = journalInstanceID,
			dungeonEncounterID = dungeonEncounterID,
			abbreviatedInstanceName = journalDB.abbreviatedName,
			mapID = mapID,
			achievements = {},
			id = id,
			creatureDisplayInfoID = creatureDisplayInfoID,
			icon = icon,
			index = bossIndex,
		}
		
		database.pointers.encounters[journalEncounterID] = db

		if(not journalDB.encounters) then
			journalDB.encounters = {}

		end

		journalDB.encounters[journalEncounterID] = db

		if(bossIndex) then
			journalDB.bosses[bossIndex] = db

		else
			miog:ConvertInstanceEncounterDataToBossData(journalInstanceID)

		end
	end
end

function miog:GetHighestDifficultyForInstance(journalInstanceID)
    if(journalInstanceID) then
        EJ_SelectInstance(journalInstanceID)

    end

	local highestDiff

	for i, difficultyID in ipairs(miog.EJ_DIFFICULTIES) do
		if EJ_IsValidInstanceDifficulty(difficultyID) then
			if(not highestDiff or miog.DIFFICULTY_ORDER[difficultyID] > highestDiff) then
				highestDiff = difficultyID

			end
		end
	end

	return highestDiff
end

function miog:SaveJournalEncounterData(journalEncounterID)
	local bossName, _, _, _, _, journalInstanceID, dungeonEncounterID, mapID = EJ_GetEncounterInfo(journalEncounterID)

	miog:SaveJournalEncounterDataWithPreData(journalEncounterID, bossName, journalInstanceID, dungeonEncounterID, mapID)
end

function miog:SaveJournalInstanceBossData(journalInstanceID)
	local journalDB = database.pointers.journal[journalInstanceID]

	local bossIndex = 1
	local bossName, _, journalEncounterID, _, _, _, dungeonEncounterID, mapID = EJ_GetEncounterInfoByIndex(bossIndex, journalInstanceID);

	if(bossName) then
		journalDB.bosses = {}

	end

	while bossName do
		miog:SaveJournalEncounterDataWithPreData(journalEncounterID, bossName, journalInstanceID, dungeonEncounterID, mapID, bossIndex)

		bossIndex = bossIndex + 1;

		bossName, _, journalEncounterID, _, _, _, dungeonEncounterID, mapID = EJ_GetEncounterInfoByIndex(bossIndex, journalInstanceID);

	end

	if(journalDB.bosses) then
		journalDB.numOfBosses = #journalDB.bosses

	end
end

function miog:RetrieveJournalInstanceBossData(journalInstanceID)
	miog:SaveJournalInstanceBossData(journalInstanceID)

	return database.pointers.journal[journalInstanceID].bosses
end

function miog:RetrieveJournalInstanceEncounterData(journalInstanceID)
	miog:SaveJournalInstanceBossData(journalInstanceID)

	return database.pointers.journal[journalInstanceID].encounters
end

function miog:RetrieveJournalEncounterData(journalEncounterID)
	miog:SaveJournalEncounterData(journalEncounterID)

	return database.pointers.encounters[journalEncounterID]

end

function miog:GetNumOfBosses(journalInstanceID)
	if(database.pointers.journal[journalInstanceID].numOfBosses == 0) then
		miog:RetrieveJournalInstanceBossData(journalInstanceID)
		
	end

	return database.pointers.journal[journalInstanceID].numOfBosses or 0

end

function miog:GetJournalInstanceBossData(journalInstanceID)
	return database.pointers.journal[journalInstanceID].bosses or miog:RetrieveJournalInstanceBossData(journalInstanceID)

end

function miog:GetJournalInstanceBossDataFromActivity(activityID)
	local activityDB = database.pointers.activity[activityID]
	local journalInstanceID = activityDB.journalInstanceID

	if(journalInstanceID) then
		return miog:GetJournalInstanceBossData(journalInstanceID)

	end
end

function miog:GetEncounterDataFromJournalInstance(journalInstanceID)
	return database.pointers.journal[journalInstanceID].encounters or miog:RetrieveJournalInstanceEncounterData(journalInstanceID)

end

function miog:GetEncounterData(journalEncounterID)
	return database.pointers.encounters[journalEncounterID] or miog:RetrieveJournalEncounterData(journalEncounterID)

end

function miog:GetJournalInstanceIDFromMap(mapID)
	return C_EncounterJournal.GetInstanceForGameMap(mapID)

end

function miog:CreateMapPointer(mapID)
	if(mapID) then
		if(not database.pointers.map[mapID]) then
			database.pointers.map[mapID] = {activities = {}}
			local mapDB = database.pointers.map[mapID]

			if(miog.MAP_INFO[mapID]) then
				local mapInfo = miog.MAP_INFO[mapID]

				mapDB.iconName = mapInfo.iconName
				mapDB.fileName = mapInfo.fileName

				mapDB.abbreviatedName = mapInfo.abbreviatedName
				mapDB.icon = mapInfo.icon

				mapDB.toastBG = mapInfo.toastBG
				mapDB.pvp = mapInfo.pvp
				
			end

			if(mapDB.fileName or mapDB.iconName) then
				if(mapDB.fileName) then
					if(loadHQData) then
						mapDB.horizontal = MythicIO.GetBackgroundImage(mapDB.fileName)
						mapDB.vertical = MythicIO.GetBackgroundImage(mapDB.fileName, true)

					elseif(mapDB.pvp) then
						mapDB.horizontal = "interface/addons/mythiciograbber/res/backgrounds/pvp/horizontal/" .. mapDB.fileName .. ".png"
						mapDB.vertical = "interface/addons/mythiciograbber/res/backgrounds/pvp/vertical/" .. mapDB.fileName .. ".png"
						
					else
						mapDB.horizontal = "interface/lfgframe/ui-lfg-background-" .. mapDB.fileName .. ".blp"
						mapDB.vertical = "interface/lfgframe/ui-lfg-background-" .. mapDB.fileName .. ".blp"

					end
				end
				
				mapDB.icon = "interface/lfgframe/lfgicon-" .. (mapDB.iconName or mapDB.fileName) .. ".blp"
			end


		end
	end
end

function miog:IntegrateJournalDataIntoMap(mapID, journalInstanceID)
	local instanceID = journalInstanceID or C_EncounterJournal.GetInstanceForGameMap(mapID)

	if(instanceID) then
		local journalDB = database.pointers.journal[instanceID]
		local mapDB = database.pointers.map[mapID]

		if(journalDB and mapDB) then
			mapDB.journalInstanceID = instanceID
			mapDB.buttonImage1 = journalDB.buttonImage1
			mapDB.buttonImage2 = journalDB.buttonImage2
			mapDB.bgImage = journalDB.bgImage
			mapDB.loreImage = journalDB.loreImage
			mapDB.instanceName = journalDB.instanceName
			mapDB.tier = journalDB.tier
			mapDB.isRaid = journalDB.isRaid
			mapDB.bosses = journalDB.bosses
			mapDB.numOfBosses = journalDB.numOfBosses
		end
	end
end

function miog:LoadMapData(mapID, overwrite)
	if(mapID) then
		if(mapID > 1 and (overwrite or not database.pointers.map[mapID])) then
			miog:CreateMapPointer(mapID)

		end

		return database.pointers.map[mapID]
	end
end

function miog:GetMapInfo(mapID)
	return database.pointers.map[mapID] or miog:LoadMapData(mapID)

end

function miog:SaveJournalInstanceInfo(journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, isRaid, tier, debug)
	database.pointers.journal[journalInstanceID] = {
		instanceName = instanceName,
		bgImage = bgImage,
		journalInstanceID = journalInstanceID,
		buttonImage1 = buttonImage1,
		loreImage = loreImage,
		buttonImage2 = buttonImage2,
		icon = buttonImage2,
		mapID = mapID,
		isRaid = isRaid,
		tier = tier,
	}

	miog:IntegrateMapDataIntoJournal(journalInstanceID, mapID)
	miog:RetrieveJournalInstanceBossData(journalInstanceID)
	
	--miog:IntegrateJournalDataIntoMap(mapID, journalInstanceID)
end

function miog:RetrieveJournalInstanceInfoFromIndex(index, isRaid)
	local journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, _ = EJ_GetInstanceByIndex(index, isRaid)

	miog:SaveJournalInstanceInfo(journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, isRaid, 2)

	return database.pointers.journal[journalInstanceID]
end

function miog:RetrieveJournalInstanceInfoFromJournalInstanceID(journalInstanceID)
	local instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, isRaid = EJ_GetInstanceInfo(journalInstanceID)

	miog:SaveJournalInstanceInfo(journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, isRaid, 3)

	return database.pointers.journal[journalInstanceID]
end

function miog:CreateJournalDB()
	local startTier = 1

	if(not EncounterJournal) then
		EncounterJournal_LoadUI()

	end

	if(EJ_GetNumTiers() > 0) then
		for tier = startTier, GetNumExpansions() do
			EJ_SelectTier(tier)
			
			for shouldBeRaid = 0, 1 do
				local isRaid = shouldBeRaid == 1

				local index = 1
				local journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, isRaid2 = EJ_GetInstanceByIndex(index, isRaid)

				EJ_SelectInstance(journalInstanceID)

				if(not database.pointers.journal[journalInstanceID]) then
					while instanceName do

						miog:LoadMapData(mapID)
						miog:SaveJournalInstanceInfo(journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, isRaid, tier, 1)

						index = index + 1
						journalInstanceID, instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, isRaid = EJ_GetInstanceByIndex(index, isRaid)

					end
				end
			end
		end
	end
end

function miog:GetJournalInstanceInfo(journalInstanceID)
	if(not database.pointers.journal[journalInstanceID]) then
		miog:RetrieveJournalInstanceInfoFromJournalInstanceID(journalInstanceID)

	end

	return database.pointers.journal[journalInstanceID]

end

function miog:GetJournalDB()
	return miog.database.pointers.journal
end

function miog:GetActivityDB()
	return miog.database.pointers.activity

end

function miog:IntegrateJournalDataIntoGroup(groupID)
	local groupDB = database.pointers.groups[groupID]

	if(groupDB and groupDB.mapID) then

		local journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(groupDB.mapID)

		if(journalInstanceID) then
			local journalDB = miog:GetJournalInstanceInfo(journalInstanceID)

			if(journalDB) then
				groupDB.journalInstanceID = journalInstanceID
				groupDB.buttonImage1 = journalDB.buttonImage1
				groupDB.buttonImage2 = journalDB.buttonImage2
				groupDB.bgImage = journalDB.bgImage
				groupDB.loreImage = journalDB.loreImage
				groupDB.instanceName = journalDB.instanceName
				groupDB.tier = journalDB.tier
				groupDB.isRaid = journalDB.isRaid
				groupDB.bosses = journalDB.bosses
				groupDB.numOfBosses = journalDB.numOfBosses

			end
		end
	end
end

function miog:IntegrateJournalDataIntoActivity(activityID)
	local activityDB = database.pointers.activity[activityID]
	local mapID = activityDB.mapID

	if(mapID) then
		local journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)

		if(journalInstanceID) then
			local journalDB = database.pointers.journal[journalInstanceID]

			if(journalDB) then
				activityDB.journalInstanceID = journalInstanceID
				activityDB.buttonImage1 = journalDB.buttonImage1
				activityDB.buttonImage2 = journalDB.buttonImage2
				activityDB.bgImage = journalDB.bgImage
				activityDB.loreImage = journalDB.loreImage
				activityDB.instanceName = journalDB.instanceName
				activityDB.tier = journalDB.tier
				activityDB.isRaid = journalDB.isRaid
				activityDB.bosses = journalDB.bosses
				activityDB.numOfBosses = journalDB.numOfBosses
			end
		end
	end
end

function miog:IntegrateActivityDataIntoMap(activityID)
	local activityDB = database.pointers.activity[activityID]

	if(activityDB and activityDB.mapID) then
		local mapDB = database.pointers.map[activityDB.mapID]

		tinsert(mapDB.activities, activityDB)
		mapDB.categoryID = activityDB.categoryID

	end
end

function miog:IntegrateMapDataIntoActivity(activityID)
	local activityDB = database.pointers.activity[activityID]
	local mapDB = database.pointers.map[activityDB.mapID]

	if(mapDB) then
		activityDB.abbreviatedName = mapDB.abbreviatedName
		activityDB.icon = mapDB.icon
		activityDB.fileName =mapDB.fileName
		activityDB.toastBG = mapDB.toastBG
		activityDB.pvp = mapDB.pvp
		activityDB.horizontal = mapDB.horizontal
		activityDB.vertical = mapDB.vertical

	end
end

function miog:IntegrateMapDataIntoGroup(groupID, mapID)
	local groupDB = database.pointers.groups[groupID]

	if(groupDB) then
		local mapDB = database.pointers.map[groupDB.mapID or mapID]

		if(mapDB) then
			groupDB.abbreviatedName = mapDB.abbreviatedName
			groupDB.icon = mapDB.icon
			groupDB.fileName = mapDB.fileName
			groupDB.toastBG = mapDB.toastBG
			groupDB.pvp = mapDB.pvp
			groupDB.horizontal = mapDB.horizontal
			groupDB.vertical = mapDB.vertical

		end
	end
end

function miog:IntegrateMapDataIntoActivityParentGroup(activityID)
	local activityDB = database.pointers.activity[activityID]
	miog:IntegrateMapDataIntoGroup(activityDB.groupFinderActivityGroupID, activityDB.mapID)
end

function miog:IntegrateGroupDataIntoChildActivities(groupID)
	local groupDB = database.pointers.groups[groupID]

	if(groupDB) then
		for k, v in ipairs(groupDB.activities) do
			v.groupName = groupDB.name

		end
	end
end

function miog:IntegrateParentGroupDataIntoChildActivity(activityID)
	local activityDB = database.pointers.activity[activityID]

	if(activityDB) then
		activityDB.groupName = C_LFGList.GetActivityGroupInfo(activityDB.groupFinderActivityGroupID)

		return activityDB.groupName

	end
end

function miog:DetermineHighestDifficultyActivityIDForGroup(groupID)
	local groupDB = database.pointers.groups[groupID]

	if(groupDB) then
		for k, v in ipairs(groupDB.activities) do
			local activityInfo = database.pointers.activity[v]

			if(activityInfo) then
				local orderIndex = miog.BETTER_DIFFICULTY_ORDER[activityInfo.redirectedDifficultyID]

				if(not groupDB.highestDifficultyActivityID or miog.BETTER_DIFFICULTY_ORDER[activityInfo.redirectedDifficultyID] > groupDB.highestDifficultyActivityIDOrderIndex) then
					groupDB.highestDifficultyActivityIDOrderIndex = orderIndex
					groupDB.highestDifficultyActivityID = v

				end
			end
		end
	end
end

function miog:CreateGroup(groupID, overwrite)
	if(groupID) then
		if(groupID > 0 and (overwrite or not database.pointers.groups[groupID])) then
			local name, groupOrder = C_LFGList.GetActivityGroupInfo(groupID)

			database.pointers.groups[groupID] = {name = name, groupOrder = groupOrder, categoryID = categoryID, activities = C_LFGList.GetAvailableActivities(_, groupID), bossIcons = miog.GROUP_ACTIVITY_ID_INFO[groupID] and miog.GROUP_ACTIVITY_ID_INFO[groupID].bossIcons}
		end
	end
end

function miog:CreateActivity(activityID, overwrite)
	if(activityID) then
		if(activityID > 0 and (overwrite or not database.pointers.activity[activityID])) then
			local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

			database.pointers.activity[activityID] = activityInfo
			database.pointers.activity[activityID].activityID = activityID
			
			if(miog:LoadMapData(activityInfo.mapID)) then
				miog:IntegrateActivityDataIntoMap(activityID)
				miog:IntegrateMapDataIntoActivity(activityID)

			end

			miog:IntegrateJournalDataIntoActivity(activityID)

		end
	end
end

function miog:AggregateActivityInfoForGroup(groupID)
	local groupDB = database.pointers.groups[groupID]

	if(groupDB) then
		local activities = C_LFGList.GetAvailableActivities(_, groupID)

		for _, activityID in pairs(activities) do
			miog:CreateActivity(activityID)
			miog:IntegrateActivityDataIntoParentGroup(activityID)
			miog:IntegrateParentGroupDataIntoChildActivity(activityID)
		end

		miog:IntegrateMapDataIntoGroup(groupID)
		miog:IntegrateJournalDataIntoGroup(groupID)
		miog:DetermineHighestDifficultyActivityIDForGroup(groupID)

		groupDB.activities = activities
	end
end

function miog:CreateGroupWithActivities(groupID)
	if(groupID) then
		if(groupID > 0 and (overwrite or not database.pointers.groups[groupID])) then
			miog:CreateGroup(groupID)
			miog:AggregateActivityInfoForGroup(groupID)

		end
	end
end

function miog:CreateGroupAndSiblingActivitiesFromActivity(activityID)
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

	miog:CreateGroupWithActivities(activityInfo.groupFinderActivityGroupID)
end

function miog:GetGroupInfo(groupID)
	if(not database.pointers.groups[groupID]) then
		miog:CreateGroupWithActivities(groupID)

	elseif(not database.pointers.groups[groupID].abbreviatedName) then
		miog:AggregateActivityInfoForGroup(groupID)

	elseif(not database.pointers.groups[groupID].bosses) then
		miog:IntegrateJournalDataIntoGroup(groupID)

	end

	return database.pointers.groups[groupID]

end

function miog:IntegrateActivityDataIntoParentGroup(activityID)
	local activityInfo = database.pointers.activity[activityID]
	
	if(activityInfo) then
		local groupDB = database.pointers.groups[activityInfo.groupFinderActivityGroupID]

		if(groupDB) then
			groupDB.journalInstanceID = activityInfo.journalInstanceID
			groupDB.mapID = activityInfo.mapID

		end
	end
end

function miog:GetActivityInfo(activityID)
	if(not database.pointers.activity[activityID]) then
		miog:CreateActivity(activityID)

	end

	return database.pointers.activity[activityID]
end

do
	miog:CreateJournalDB()

	--[[for _, activityID in pairs(manualData.activity) do
		miog:CreateGroupAndSiblingActivitiesFromActivity(activityID, true)

		tinsert(database.pointers.unlistedActivities, database.pointers.activity[activityID])
	end]]

	for _, categoryID in pairs(miog.CUSTOM_CATEGORY_ORDER) do
		for _, activityID in ipairs(C_LFGList.GetAvailableActivities(categoryID)) do
			miog:CreateGroupAndSiblingActivitiesFromActivity(activityID)

		end
	end

	miog:UpdateJournalDB()
end

function miog:HasMapInfo(mapID)
	return database.pointers.map[mapID] ~= nil
end

function miog:HasActivityInfo(activityID)
	return database.pointers.activity[activityID] ~= nil

end

function miog:GetActivityGroupName(activityID)
	return database.pointers.activity[activityID] and database.pointers.activity[activityID].groupName or miog:IntegrateParentGroupDataIntoChildActivity(activityID)

end

function miog:HasGroupInfo(groupID)
	return database.pointers.groups[groupID] ~= nil

end

function miog:HasJournalInstanceInfo(journalInstanceID)
	return database.pointers.journal[journalInstanceID] ~= nil
end

function miog:GetJournalInstanceIDFromMapID(mapID)
	local journalInstanceID

	if(not database.pointers.map[mapID]) then
		journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)

	else
		if(not database.pointers.map[mapID].journalInstanceID) then
			journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)

		else
			journalInstanceID = database.pointers.map[mapID] and database.pointers.map[mapID].journalInstanceID

		end
	end

	return journalInstanceID

end

function miog:GetJournalInstanceIDFromActivityID(activityID)
	local journalInstanceID

	if(not database.pointers.activity[activityID]) then
		

	else
		if(not database.pointers.activity[mapID].journalInstanceID) then

		else
			journalInstanceID = database.pointers.activity[mapID] and database.pointers.activity[mapID].journalInstanceID

		end
	end

	return journalInstanceID
end

function miog:GetJournalDataForMapID(mapID)
	if(mapID) then
		if(not miog:HasMapInfo(mapID)) then
			miog:GetMapInfo(mapID)

		end

		local journalInstanceID = miog:GetJournalInstanceIDFromMapID(mapID)

		if(journalInstanceID) then
			local journalDB = miog:GetJournalInstanceInfo(journalInstanceID)

			return journalDB
		end
	end
end

function miog:GetJournalDataForActivityID(activityID)
	if(activityID) then
		if(not miog:HasActivityInfo(activityID)) then
			miog:GetActivityInfo(activityID)

		end

		local journalInstanceID = miog:GetJournalInstanceIDFromActivityID(activityID)

		if(journalInstanceID) then
			local journalDB = miog:GetJournalInstanceInfo(journalInstanceID)

			return journalDB
		end
	end
end

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

miog.TELEPORT_SPELLS_TO_MAP_DATA = {
	[445424] = {mapID = 670},
	[410080] = {mapID = 657},
	[424142] = {mapID = 643},

	[131225] = {mapID = 962},
	[131222] = {mapID = 1008},
	[131231] = {mapID = 1001},
	[131229] = {mapID = 1004},
	[131232] = {mapID = 1007},
	[131206] = {mapID = 959},
	[131228] = {mapID = 1011},
	[131205] = {mapID = 961},
	[131204] = {mapID = 960},

	[159897] = {mapID = 1182},
	[159895] = {mapID = 1175},
	[159900] = {mapID = 1208},
	[159901] = {mapID = 1279},
	[159896] = {mapID = 1195},
	[159899] = {mapID = 1176},
	[159898] = {mapID = 1209},
	[159902] = {mapID = 1358},

	[424153] = {mapID = 1501},
	[393766] = {mapID = 1571},
	[424163] = {mapID = 1466},
	[393764] = {mapID = 1477},
	[373262] = {mapID = 1651},
	[410078] = {mapID = 1458},

	[424187] = {mapID = 1763},
	[410071] = {mapID = 1754},
	[373274] = {mapID = 2097},
	[464256] = {mapID = 1822},
	[445418] = {mapID = 1822},
	[467555] = {mapID = 1594},
	[467553] = {mapID = 1594},
	[410074] = {mapID = 1841},
	[424167] = {mapID = 1862},

	[354468] = {mapID = 2291},
	[354465] = {mapID = 2287},
	[354464] = {mapID = 2290},
	[354463] = {mapID = 2289},
	[354469] = {mapID = 2284},
	[354466] = {mapID = 2285},
	[367416] = {mapID = 2441},
	[354462] = {mapID = 2286},
	[354467] = {mapID = 2293},
	[373190] = {mapID = 2296},
	[373191] = {mapID = 2450},
	[373192] = {mapID = 2481},

	[393273] = {mapID = 2526},
	[393267] = {mapID = 2520},
	[424197] = {mapID = 2579},
	[393283] = {mapID = 2527},
	[393276] = {mapID = 2519},
	[393256] = {mapID = 2521},
	[393279] = {mapID = 2515},
	[393262] = {mapID = 2516},
	[393222] = {mapID = 2451},
	[432257] = {mapID = 2569},
	[432258] = {mapID = 2549},
	[432254] = {mapID = 2522},

	[445417] = {mapID = 2660},
	[445440] = {mapID = 2661},
	[445416] = {mapID = 2669},
	[445441] = {mapID = 2651},
	[1216786] = {mapID = 2773},
	[445444] = {mapID = 2649},
	[445414] = {mapID = 2662},
	[445443] = {mapID = 2648},
	[445269] = {mapID = 2652},
	[1226482] = {mapID = 2769},
	[1237215] = {mapID = 2830},
	[1239155] = {mapID = 2810},

	[1254400] = {mapID = 2805},
	[1254572] = {mapID = 2811},
	[1254563] = {mapID = 2915},
	[1254559] = {mapID = 2874},
	[1254555] = {mapID = 658},
	[1254551] = {mapID = 1753},
}

local function loadRawData()
	local loadHQData = miog.isMIOGHQLoaded()

	for k, v in pairs(miog.PVP_BRACKET_INFO) do
		if(loadHQData) then
			v.vertical = MythicIO.GetBackgroundImage(v.fileName, true)
		
		else
			v.vertical = miog.C.STANDARD_FILE_PATH .. "/backgrounds/pvp/vertical/" .. v.fileName .. ".png"

		end
	end

	for k, v in pairs(miog.TELEPORT_SPELLS_TO_MAP_DATA) do
		if(miog.MAP_INFO[v.mapID]) then
			v.abbreviatedName = miog.MAP_INFO[v.mapID].abbreviatedName

		end
	end
end

miog.loadRawData = loadRawData

miog.TELEPORT_FLYOUT_IDS = { --https://wago.tools/db2/SpellFlyout
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

	[12] = {id = 244, seasonID = 16, type="dungeon"},
	[13] = {id = 246, expansion = 11, type="dungeon"},
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
		logicList = {},
		trackItemLevelList = {},
		tooltipList = {},

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
			other = {
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
		logicList = {},
		trackItemLevelList = {},
		tooltipList = {},

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
				[1] = {steps = -1, name="Normal"},
				[2] = {steps = 7, vaultOffset = 4, name="HC/TW"},
				[3] = {steps = 12, vaultOffset = 3, name="M0"},
				[4] = {steps = 13, vaultOffset = 3, name="+2"},
				[5] = {steps = 13, vaultOffset = 3, name="+3"},
				[6] = {steps = 14, vaultOffset = 3, name="+4"},
				[7] = {steps = 15, vaultOffset = 2, name="+5"},
				[8] = {steps = 16, vaultOffset = 2, name="+6"},
				[9] = {steps = 16, vaultOffset = 3, name="+7"},
				[10] = {steps = 17, vaultOffset = 2, name="+8"},
				[11] = {steps = 17, vaultOffset = 2, name="+9"},
				[12] = {steps = 18, vaultOffset = 2, name="+10"},
				[13] = {steps = 16, vaultOffset = 4, name="TAZA HM"},
				[14] = {steps = 20, name="TAZA DL"},
			},
			raid = {
				{steps = 8, name="LFR 1"},
				{steps = 9, name="LFR 2-3"},
				{steps = 10, name="LFR 4-6"},
				{steps = 11, name="LFR 7-8"},
				{steps = 12, name="N 1"},
				{steps = 13, name="N 2-3"},
				{steps = 14, name="N 4-6"},
				{steps = 15, name="N 7-8"},
				{steps = 16, name="HC 1"},
				{steps = 17, name="HC 2-3"},
				{steps = 18, name="HC 4-6"},
				{steps = 19, name="HC 7-8"},
				{steps = 20, name="M 1"},
				{steps = 21, name="M 2-3"},
				{steps = 22, name="M 4-6"},
				{steps = 23, name="M 7-8"},

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
				[9] = {steps = 9, name="T4DB"},
				[10] = {steps = 11, name="T5DB"},
				[11] = {steps = 13, name="T6DB"},
				[12] = {steps = 15, name="T7DB"},
				[13] = {steps = 16, name="T8DB+"},
			},
			other = {
				{steps = 10, name="Weather5"},
				{steps = 15, name="Spark5"},
				{steps = 19, name="Runed5"},
				{steps = 24, name="Gilded5"},
			},
		},
	},
	[16] = {
		referenceMinLevel = 207,
		referenceMinLevelStepIndex = 4,
		referenceMaxLevel = 289,
		firstTrackStartLevel = 220,

		itemLevelList = {},
		logicList = {},
		trackItemLevelList = {},
		tooltipList = {},

		tracks = {
			{name = "Adventurer", length = 6},
			{name = "Veteran", length = 6},
			{name = "Champion", length = 6},
			{name = "Hero", length = 6},
			{name = "Myth", length = 6},

		},

		data = {
			dungeon = {
				{steps = 2, name="Normal"},
				{steps = 5, vaultOffset = 6, name="HC"},
				{steps = 7, name="HC Season"},
				{steps = 10, vaultOffset = 3, name="Mythic"},
				{steps = 12, vaultOffset = 3, name="M Season"},
				{steps = 13, vaultOffset = 3, name="+2"},
				{steps = 13, vaultOffset = 3, name="+3"},
				{steps = 14, vaultOffset = 3, name="+4"},
				{steps = 15, vaultOffset = 2, name="+5"},
				{steps = 16, vaultOffset = 2, name="+6"},
				{steps = 16, vaultOffset = 3, name="+7"},
				{steps = 17, vaultOffset = 2, name="+8"},
				{steps = 17, vaultOffset = 2, name="+9"},
				{steps = 18, vaultOffset = 2, name="+10"},
			},
			raid = {
				{steps = 8, name="LFR*", tooltip="Voidspire 1st boss"},
				{steps = 9, name="LFR*", tooltip="Voidspire 2nd & 3rd boss + Dreamrift"},
				{steps = 10, name="LFR*", tooltip="Voidspire 4th & 5th boss + March on Quel'Danas 1st boss"},
				{steps = 11, name="LFR*", tooltip="Voidspire 6th boss + March on Quel'Danas 2nd boss"},
				{steps = 12, name="N*", tooltip="Voidspire 1st boss"},
				{steps = 13, name="N*", tooltip="Voidspire 2nd & 3rd boss + Dreamrift"},
				{steps = 14, name="N*", tooltip="Voidspire 4th & 5th boss + March on Quel'Danas 1st boss"},
				{steps = 15, name="N*", tooltip="Voidspire 6th boss + March on Quel'Danas 2nd boss"},
				{steps = 16, name="HC*", tooltip="Voidspire 1st boss"},
				{steps = 17, name="HC*", tooltip="Voidspire 2nd & 3rd boss + Dreamrift"},
				{steps = 18, name="HC*", tooltip="Voidspire 4th & 5th boss + March on Quel'Danas 1st boss"},
				{steps = 19, name="HC*", tooltip="Voidspire 6th boss + March on Quel'Danas 2nd boss"},
				{steps = 20, name="M*", tooltip="Voidspire 1st boss"},
				{steps = 21, name="M*", tooltip="Voidspire 2nd & 3rd boss + Dreamrift"},
				{steps = 22, name="M*", tooltip="Voidspire 4th & 5th boss + March on Quel'Danas 1st boss"},
				{steps = 23, name="M*", tooltip="Voidspire 6th boss + March on Quel'Danas 2nd boss"},

			},
			
			delves = {
				[1] = {steps = 4, vaultOffset = 4, name="T1"},
				[2] = {steps = 5, vaultOffset = 4, name="T2"},
				[3] = {steps = 6, vaultOffset = 4, name="T3"},
				[4] = {steps = 7, vaultOffset = 4, name="T4"},
				[5] = {steps = 8, vaultOffset = 4, name="T5"},
				[6] = {steps = 9, vaultOffset = 5, name="T6"},
				[7] = {steps = 12, vaultOffset = 3, name="T7"},
				[8] = {steps = 13, vaultOffset = 3, name="T8+"},
				[9] = {steps = 9, name="T4DB"},
				[10] = {steps = 11, name="T5DB"},
				[11] = {steps = 12, name="T6DB"},
				[12] = {steps = 13, name="T7DB"},
				[13] = {steps = 16, name="T8DB+"},
			},
			prey = {
				{steps = 4, name="Normal"},
				{steps = 8, name="Hard"},
				{steps = 12, name="NM?"},
			},
			other = {
				{steps = 9, name="World Vault"},
				{steps = 11, name="Pinnacle"},
				{steps = 14, name="Worldboss"},
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
	local trackItemLevelList = seasonalData.trackItemLevelList

	for trackIndex, data in ipairs(seasonalData.tracks) do
		local length = data.revisedLength or data.length
		local minLevel = (seasonalData.firstTrackStartLevel or seasonalData.referenceMinLevel) + (trackIndex - 1) * getItemLevelForStepCount(4, seasonalData.referenceMinLevelStepIndex)
		local level = getItemLevelForStepCount(length - 1, seasonalData.referenceMinLevelStepIndex)

		data.itemlevels = {}
		data.minLevel = minLevel
		data.maxLevel = minLevel + level

		for i = 1, length, 1 do
			local innerLevel = getItemLevelForStepCount(i - 1, seasonalData.referenceMinLevelStepIndex)

			local separateLevel = minLevel + innerLevel
			data.itemlevels[i] = separateLevel

			if(trackItemLevelList[separateLevel] == nil) then
				local currentTrackEntry = {}
				currentTrackEntry[1] = {trackIndex = trackIndex, index = i, length = length}

				trackItemLevelList[separateLevel] = currentTrackEntry
				
			else
				trackItemLevelList[separateLevel][2] = {trackIndex = trackIndex, index = i, length = length}

			end
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

			if(not seasonalData.logicList[ilvlData.level]) then
				seasonalData.logicList[ilvlData.level] = {}
				seasonalData.tooltipList[ilvlData.level] = {}

			end

			seasonalData.logicList[ilvlData.level][category] = ilvlData.name
			seasonalData.tooltipList[ilvlData.level][category] = ilvlData.tooltip

			if(ilvlData.vaultOffset) then
				ilvlData.vaultLevel = seasonalData.referenceMinLevel + getItemLevelForStepCount(ilvlData.vaultOffset + ilvlData.steps, seasonalData.referenceMinLevelStepIndex)

				if(not usedItemlevels[ilvlData.vaultLevel]) then
					tinsert(seasonalData.itemLevelList, ilvlData.vaultLevel)

				end

				usedItemlevels[ilvlData.vaultLevel] = true

				if(not seasonalData.logicList[ilvlData.vaultLevel]) then
					seasonalData.logicList[ilvlData.vaultLevel] = {}
					seasonalData.tooltipList[ilvlData.vaultLevel] = {}

				end

				seasonalData.logicList[ilvlData.vaultLevel]["vault-" .. category] = ilvlData.name
				seasonalData.tooltipList[ilvlData.vaultLevel]["vault-" .. category] = ilvlData.tooltip
			end
		end

		if(category == "dungeon") then
			local tempCatData = categoryData[#categoryData]
			categoryData.highestItemLevel = tempCatData.vaultLevel or tempCatData.level
			
		elseif(category == "other") then
			categoryData.highestItemLevel = categoryData[#categoryData].level
		end
	end

	table.sort(seasonalData.itemLevelList, function(k1, k2)
		return k1 < k2

	end)
end

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
	[1] = 	{name = "WARRIOR", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warrior.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warrior_round.png", specs = {71, 72, 73}, raidBuff = 6673},
	[2] = 	{name = "PALADIN", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/paladin.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/paladin_round.png", specs = {65, 66, 70}, raidBuff = 0},
	[3] = 	{name = "HUNTER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/hunter.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/hunter_round.png", specs = {253, 254, 255}, raidBuff = 257284},
	[4] = 	{name = "ROGUE", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/rogue.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/rogue_round.png", specs = {259, 260, 261}, raidBuff = 0},
	[5] = 	{name = "PRIEST", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/priest.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/priest_round.png", specs = {256, 257, 258}, raidBuff = 21562},
	[6] = 	{name = "DEATHKNIGHT", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/deathKnight.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/deathKnight_round.png", specs = {250, 251, 252}},
	[7] = 	{name = "SHAMAN", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/shaman.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/shaman_round.png", specs = {262, 263, 264}, raidBuff = 462854},
	[8] = 	{name = "MAGE", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/mage.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/mage_round.png", specs = {62, 63, 64}, raidBuff = 1459},
	[9] =	{name = "WARLOCK", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warlock.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/warlock_round.png", specs = {265, 266, 267}},
	[10] = 	{name = "MONK", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/monk.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/monk_round.png", specs = {268, 270, 269}, raidBuff = 8647},
	[11] =	{name = "DRUID", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/druid.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/druid_round.png", specs = {102, 103, 104, 105}, raidBuff = 1126},
	[12] = 	{name = "DEMONHUNTER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/demonHunter.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/demonHunter_round.png", specs = {577, 581, 1480}, raidBuff = 255260},
	[13] = 	{name = "EVOKER", icon = miog.C.STANDARD_FILE_PATH .. "/classIcons/evoker.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/evoker_round.png", specs = {1467, 1468, 1473}, raidBuff = 364342},
	[14] =	{name = "ADVENTURER", icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png", roundIcon = miog.C.STANDARD_FILE_PATH .. "/classIcons/unknown.png", specs = {}},
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

for i = 1, 13, 1 do
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
	[1480] = {name = "Devourer", class = miog.CLASSES[12], icon = miog.C.STANDARD_FILE_PATH .. "/specIcons/devourer.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/specIcons/devourer_squared.png", stat = "ITEM_MOD_INTELLECT_SHORT"},

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

	[1478] = {name = "Adventurer", class = miog.CLASSES[14], icon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png", squaredIcon = miog.C.STANDARD_FILE_PATH .. "/infoIcons/unknown.png"},
}

miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID = {}

for k, v in pairs(miog.SPECIALIZATIONS) do
	if(k > 25) then
		local _, localizedName, _, icon, _, fileName = GetSpecializationInfoByID(k)

		if(fileName) then
			if(localizedName == "") then
				localizedName = "Initial"
			end

			miog.LOCALIZED_SPECIALIZATION_NAME_TO_ID[localizedName .. "-" .. fileName] = k
		end
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
	[121] = "interface/journeys/journeysframebackground.blp", --DELVES
}

miog.EXPANSIONS = {
	[0] = {name = "Classic", background = "vanilla-bg-1", logo = GetExpansionDisplayInfo(0).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/0.png"},
	[1] = {name = "The Burning Crusade", background = "tbc-bg-1", logo = GetExpansionDisplayInfo(1).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/1.png"},
	[2] = {name = "Wrath of the Lich King", background = "wotlk-bg-1", logo = GetExpansionDisplayInfo(2).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/2.png"},
	[3] = {name = "Cataclysm", background = "cata-bg-1", logo = GetExpansionDisplayInfo(3).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/3.png"},
	[4] = {name = "Mists of Pandaria", background = "mop-bg-1", logo = GetExpansionDisplayInfo(4).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/4.png"},
	[5] = {name = "Warlords of Draenor", background = "wod-bg-1", logo = GetExpansionDisplayInfo(5).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/5.png"},
	[6] = {name = "Legion", background = "legion-bg-1", logo = GetExpansionDisplayInfo(6).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/6.png"},
	[7] = {name = "Battle for Azeroth", background = "bfa-bg-1", logo = GetExpansionDisplayInfo(7).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/7.png"},
	[8] = {name = "Shadowlands", background = "sl-bg-1", logo = GetExpansionDisplayInfo(8).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/8.png"},
	[9] = {name = "Dragonflight", background = "df-bg-1", logo = GetExpansionDisplayInfo(9).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/9.png"},
	[10] = {name = "The War Within", background = "tww-bg-1", logo = GetExpansionDisplayInfo(10).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/10.png"},
	[11] = {name = "Midnight", background = "mn-bg-1", logo = GetExpansionDisplayInfo(11).logo, icon = miog.C.STANDARD_FILE_PATH .. "/expansionIcons/11.png"},
}

miog.TIER_INFO = {
	[1] = miog.EXPANSIONS[0],
	[2] = miog.EXPANSIONS[1],
	[3] = miog.EXPANSIONS[2],
	[4] = miog.EXPANSIONS[3],
	[5] = miog.EXPANSIONS[4],
	[6] = miog.EXPANSIONS[5],
	[7] = miog.EXPANSIONS[6],
	[8] = miog.EXPANSIONS[7],
	[9] = miog.EXPANSIONS[8],
	[10] = miog.EXPANSIONS[9],
	[11] = miog.EXPANSIONS[10],
	[12] = miog.EXPANSIONS[11],
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

miog.REALMS_TO_LANGUAGE = {
	["US-Aegwynn"] = {realmName = "Aegwynn", region = "US", language = "English"},
	["EU-Aegwynn"] = {realmName = "Aegwynn", region = "EU", language = "German"},
	["EU-AeriePeak"] = {realmName = "AeriePeak", region = "EU", language = "English"},
	["US-AeriePeak"] = {realmName = "AeriePeak", region = "US", language = "English"},
	["US-Agamaggan"] = {realmName = "Agamaggan", region = "US", language = "English"},
	["EU-Agamaggan"] = {realmName = "Agamaggan", region = "EU", language = "English"},
	["EU-Aggra(Português)"] = {realmName = "Aggra(Português)", region = "EU", language = "EnglishPortuguese"},
	["US-Aggramar"] = {realmName = "Aggramar", region = "US", language = "English"},
	["EU-Aggramar"] = {realmName = "Aggramar", region = "EU", language = "English"},
	["EU-Ahn'Qiraj"] = {realmName = "Ahn'Qiraj", region = "EU", language = "English"},
	["US-Akama"] = {realmName = "Akama", region = "US", language = "English"},
	["EU-Al'Akir"] = {realmName = "Al'Akir", region = "EU", language = "English"},
	["EU-Alexstrasza"] = {realmName = "Alexstrasza", region = "EU", language = "German"},
	["US-Alexstrasza"] = {realmName = "Alexstrasza", region = "US", language = "English"},
	["US-Alleria"] = {realmName = "Alleria", region = "US", language = "English"},
	["EU-Alleria"] = {realmName = "Alleria", region = "EU", language = "German"},
	["EU-Alonsus"] = {realmName = "Alonsus", region = "EU", language = "English"},
	["US-AltarofStorms"] = {realmName = "AltarofStorms", region = "US", language = "English"},
	["US-AlteracMountains"] = {realmName = "AlteracMountains", region = "US", language = "English"},
	["US-Aman'Thul"] = {realmName = "Aman'Thul", region = "US", language = "English"},
	["EU-Aman'thul"] = {realmName = "Aman'thul", region = "EU", language = "German"},
	["EU-Ambossar"] = {realmName = "Ambossar", region = "EU", language = "German"},
	["EU-Anachronos"] = {realmName = "Anachronos", region = "EU", language = "English"},
	["US-Andorhal"] = {realmName = "Andorhal", region = "US", language = "English"},
	["EU-Anetheron"] = {realmName = "Anetheron", region = "EU", language = "German"},
	["US-Anetheron"] = {realmName = "Anetheron", region = "US", language = "English"},
	["EU-Antonidas"] = {realmName = "Antonidas", region = "EU", language = "German"},
	["US-Antonidas"] = {realmName = "Antonidas", region = "US", language = "English"},
	["US-Anub'arak"] = {realmName = "Anub'arak", region = "US", language = "English"},
	["EU-Anub'arak"] = {realmName = "Anub'arak", region = "EU", language = "German"},
	["US-Anvilmar"] = {realmName = "Anvilmar", region = "US", language = "English"},
	["EU-Arakarahm"] = {realmName = "Arakarahm", region = "EU", language = "French"},
	["EU-Arathi"] = {realmName = "Arathi", region = "EU", language = "French"},
	["EU-Arathor"] = {realmName = "Arathor", region = "EU", language = "English"},
	["US-Arathor"] = {realmName = "Arathor", region = "US", language = "English"},
	["EU-Archimonde"] = {realmName = "Archimonde", region = "EU", language = "French"},
	["US-Archimonde"] = {realmName = "Archimonde", region = "US", language = "English"},
	["US-Area52"] = {realmName = "Area52", region = "US", language = "English"},
	["EU-Area52"] = {realmName = "Area52", region = "EU", language = "German"},
	["EU-ArgentDawn"] = {realmName = "ArgentDawn", region = "EU", language = "English"},
	["US-ArgentDawn"] = {realmName = "ArgentDawn", region = "US", language = "English"},
	["EU-Arthas"] = {realmName = "Arthas", region = "EU", language = "German"},
	["US-Arthas"] = {realmName = "Arthas", region = "US", language = "English"},
	["EU-Arygos"] = {realmName = "Arygos", region = "EU", language = "German"},
	["US-Arygos"] = {realmName = "Arygos", region = "US", language = "English"},
	["EU-Aszune"] = {realmName = "Aszune", region = "EU", language = "English"},
	["EU-Auchindoun"] = {realmName = "Auchindoun", region = "EU", language = "English"},
	["US-Auchindoun"] = {realmName = "Auchindoun", region = "US", language = "English"},
	["US-Azgalor"] = {realmName = "Azgalor", region = "US", language = "English"},
	["US-AzjolNerub"] = {realmName = "AzjolNerub", region = "US", language = "English"},
	["EU-AzjolNerub"] = {realmName = "AzjolNerub", region = "EU", language = "English"},
	["US-Azralon"] = {realmName = "Azralon", region = "US", language = "Portuguese"},
	["US-Azshara"] = {realmName = "Azshara", region = "US", language = "English"},
	["EU-Azshara"] = {realmName = "Azshara", region = "EU", language = "German"},
	["US-Azuremyst"] = {realmName = "Azuremyst", region = "US", language = "English"},
	["EU-Azuremyst"] = {realmName = "Azuremyst", region = "EU", language = "English"},
	["EU-Baelgun"] = {realmName = "Baelgun", region = "EU", language = "German"},
	["US-Baelgun"] = {realmName = "Baelgun", region = "US", language = "English"},
	["US-Balnazzar"] = {realmName = "Balnazzar", region = "US", language = "English"},
	["EU-Balnazzar"] = {realmName = "Balnazzar", region = "EU", language = "English"},
	["US-Barthilas"] = {realmName = "Barthilas", region = "US", language = "English"},
	["US-BlackDragonflight"] = {realmName = "BlackDragonflight", region = "US", language = "English"},
	["EU-Blackhand"] = {realmName = "Blackhand", region = "EU", language = "German"},
	["US-Blackhand"] = {realmName = "Blackhand", region = "US", language = "English"},
	["EU-Blackmoore"] = {realmName = "Blackmoore", region = "EU", language = "German"},
	["EU-Blackrock"] = {realmName = "Blackrock", region = "EU", language = "German"},
	["US-Blackrock"] = {realmName = "Blackrock", region = "US", language = "English"},
	["US-BlackwaterRaiders"] = {realmName = "BlackwaterRaiders", region = "US", language = "English"},
	["US-BlackwingLair"] = {realmName = "BlackwingLair", region = "US", language = "English"},
	["EU-Bladefist"] = {realmName = "Bladefist", region = "EU", language = "English"},
	["US-Bladefist"] = {realmName = "Bladefist", region = "US", language = "English"},
	["US-Blade'sEdge"] = {realmName = "Blade'sEdge", region = "US", language = "English"},
	["EU-Blade'sEdge"] = {realmName = "Blade'sEdge", region = "EU", language = "English"},
	["US-BleedingHollow"] = {realmName = "BleedingHollow", region = "US", language = "English"},
	["EU-Bloodfeather"] = {realmName = "Bloodfeather", region = "EU", language = "English"},
	["US-BloodFurnace"] = {realmName = "BloodFurnace", region = "US", language = "English"},
	["US-Bloodhoof"] = {realmName = "Bloodhoof", region = "US", language = "English"},
	["EU-Bloodhoof"] = {realmName = "Bloodhoof", region = "EU", language = "English"},
	["US-Bloodscalp"] = {realmName = "Bloodscalp", region = "US", language = "English"},
	["EU-Bloodscalp"] = {realmName = "Bloodscalp", region = "EU", language = "English"},
	["EU-Blutkessel"] = {realmName = "Blutkessel", region = "EU", language = "German"},
	["US-Bonechewer"] = {realmName = "Bonechewer", region = "US", language = "English"},
	["US-BoreanTundra"] = {realmName = "BoreanTundra", region = "US", language = "English"},
	["US-Boulderfist"] = {realmName = "Boulderfist", region = "US", language = "English"},
	["EU-Boulderfist"] = {realmName = "Boulderfist", region = "EU", language = "English"},
	["EU-Bronzebeard"] = {realmName = "Bronzebeard", region = "EU", language = "English"},
	["US-Bronzebeard"] = {realmName = "Bronzebeard", region = "US", language = "English"},
	["EU-BronzeDragonflight"] = {realmName = "BronzeDragonflight", region = "EU", language = "English"},
	["EU-BurningBlade"] = {realmName = "BurningBlade", region = "EU", language = "English"},
	["US-BurningBlade"] = {realmName = "BurningBlade", region = "US", language = "English"},
	["EU-BurningLegion"] = {realmName = "BurningLegion", region = "EU", language = "English"},
	["US-BurningLegion"] = {realmName = "BurningLegion", region = "US", language = "English"},
	["EU-BurningSteppes"] = {realmName = "BurningSteppes", region = "EU", language = "English"},
	["US-Caelestrasz"] = {realmName = "Caelestrasz", region = "US", language = "English"},
	["US-Cairne"] = {realmName = "Cairne", region = "US", language = "English"},
	["US-CenarionCircle"] = {realmName = "CenarionCircle", region = "US", language = "English"},
	["US-Cenarius"] = {realmName = "Cenarius", region = "US", language = "English"},
	["EU-ChamberofAspects"] = {realmName = "ChamberofAspects", region = "EU", language = "English"},
	["EU-Chantséternels"] = {realmName = "Chantséternels", region = "EU", language = "French"},
	["EU-Cho'gall"] = {realmName = "Cho'gall", region = "EU", language = "French"},
	["US-Cho'gall"] = {realmName = "Cho'gall", region = "US", language = "English"},
	["US-Chromaggus"] = {realmName = "Chromaggus", region = "US", language = "English"},
	["EU-Chromaggus"] = {realmName = "Chromaggus", region = "EU", language = "English"},
	["US-Coilfang"] = {realmName = "Coilfang", region = "US", language = "English"},
	["EU-ColinasPardas"] = {realmName = "ColinasPardas", region = "EU", language = "Spanish"},
	["EU-ConfrérieduThorium"] = {realmName = "ConfrérieduThorium", region = "EU", language = "French"},
	["EU-ConseildesOmbres"] = {realmName = "ConseildesOmbres", region = "EU", language = "French"},
	["US-Crushridge"] = {realmName = "Crushridge", region = "US", language = "English"},
	["EU-Crushridge"] = {realmName = "Crushridge", region = "EU", language = "English"},
	["EU-C'Thun"] = {realmName = "C'Thun", region = "EU", language = "Spanish"},
	["EU-CultedelaRivenoire"] = {realmName = "CultedelaRivenoire", region = "EU", language = "French"},
	["US-Daggerspine"] = {realmName = "Daggerspine", region = "US", language = "English"},
	["EU-Daggerspine"] = {realmName = "Daggerspine", region = "EU", language = "English"},
	["US-Dalaran"] = {realmName = "Dalaran", region = "US", language = "English"},
	["EU-Dalaran"] = {realmName = "Dalaran", region = "EU", language = "French"},
	["EU-Dalvengyr"] = {realmName = "Dalvengyr", region = "EU", language = "German"},
	["US-Dalvengyr"] = {realmName = "Dalvengyr", region = "US", language = "English"},
	["US-DarkIron"] = {realmName = "DarkIron", region = "US", language = "English"},
	["EU-DarkmoonFaire"] = {realmName = "DarkmoonFaire", region = "EU", language = "English"},
	["EU-Darksorrow"] = {realmName = "Darksorrow", region = "EU", language = "English"},
	["EU-Darkspear"] = {realmName = "Darkspear", region = "EU", language = "English"},
	["US-Darkspear"] = {realmName = "Darkspear", region = "US", language = "English"},
	["US-Darrowmere"] = {realmName = "Darrowmere", region = "US", language = "English"},
	["EU-DasKonsortium"] = {realmName = "DasKonsortium", region = "EU", language = "German"},
	["EU-DasSyndikat"] = {realmName = "DasSyndikat", region = "EU", language = "German"},
	["US-Dath'Remar"] = {realmName = "Dath'Remar", region = "US", language = "English"},
	["US-Dawnbringer"] = {realmName = "Dawnbringer", region = "US", language = "English"},
	["EU-Deathwing"] = {realmName = "Deathwing", region = "EU", language = "English"},
	["US-Deathwing"] = {realmName = "Deathwing", region = "US", language = "English"},
	["EU-DefiasBrotherhood"] = {realmName = "DefiasBrotherhood", region = "EU", language = "English"},
	["US-DemonSoul"] = {realmName = "DemonSoul", region = "US", language = "English"},
	["EU-Dentarg"] = {realmName = "Dentarg", region = "EU", language = "English"},
	["US-Dentarg"] = {realmName = "Dentarg", region = "US", language = "English"},
	["EU-DerAbyssischeRat"] = {realmName = "DerAbyssischeRat", region = "EU", language = "German"},
	["EU-DerMithrilorden"] = {realmName = "DerMithrilorden", region = "EU", language = "German"},
	["EU-DerRatvonDalaran"] = {realmName = "DerRatvonDalaran", region = "EU", language = "German"},
	["US-Destromath"] = {realmName = "Destromath", region = "US", language = "English"},
	["EU-Destromath"] = {realmName = "Destromath", region = "EU", language = "German"},
	["EU-Dethecus"] = {realmName = "Dethecus", region = "EU", language = "German"},
	["US-Dethecus"] = {realmName = "Dethecus", region = "US", language = "English"},
	["US-Detheroc"] = {realmName = "Detheroc", region = "US", language = "English"},
	["EU-DieAldor"] = {realmName = "DieAldor", region = "EU", language = "German"},
	["EU-DieArguswacht"] = {realmName = "DieArguswacht", region = "EU", language = "German"},
	["EU-DieewigeWacht"] = {realmName = "DieewigeWacht", region = "EU", language = "German"},
	["EU-DieNachtwache"] = {realmName = "DieNachtwache", region = "EU", language = "German"},
	["EU-DieSilberneHand"] = {realmName = "DieSilberneHand", region = "EU", language = "German"},
	["EU-DieTodeskrallen"] = {realmName = "DieTodeskrallen", region = "EU", language = "German"},
	["EU-Doomhammer"] = {realmName = "Doomhammer", region = "EU", language = "English"},
	["US-Doomhammer"] = {realmName = "Doomhammer", region = "US", language = "English"},
	["EU-Draenor"] = {realmName = "Draenor", region = "EU", language = "English"},
	["US-Draenor"] = {realmName = "Draenor", region = "US", language = "English"},
	["EU-Dragonblight"] = {realmName = "Dragonblight", region = "EU", language = "English"},
	["US-Dragonblight"] = {realmName = "Dragonblight", region = "US", language = "English"},
	["US-Dragonmaw"] = {realmName = "Dragonmaw", region = "US", language = "English"},
	["EU-Dragonmaw"] = {realmName = "Dragonmaw", region = "EU", language = "English"},
	["US-Draka"] = {realmName = "Draka", region = "US", language = "English"},
	["US-Drakkari"] = {realmName = "Drakkari", region = "US", language = "Spanish"},
	["US-Drak'Tharon"] = {realmName = "Drak'Tharon", region = "US", language = "English"},
	["EU-Drak'thul"] = {realmName = "Drak'thul", region = "EU", language = "English"},
	["US-Drak'thul"] = {realmName = "Drak'thul", region = "US", language = "English"},
	["US-Dreadmaul"] = {realmName = "Dreadmaul", region = "US", language = "English"},
	["EU-Drek'Thar"] = {realmName = "Drek'Thar", region = "EU", language = "French"},
	["US-Drenden"] = {realmName = "Drenden", region = "US", language = "English"},
	["EU-Dunemaul"] = {realmName = "Dunemaul", region = "EU", language = "English"},
	["US-Dunemaul"] = {realmName = "Dunemaul", region = "US", language = "English"},
	["EU-DunModr"] = {realmName = "DunModr", region = "EU", language = "Spanish"},
	["EU-DunMorogh"] = {realmName = "DunMorogh", region = "EU", language = "German"},
	["EU-Durotan"] = {realmName = "Durotan", region = "EU", language = "German"},
	["US-Durotan"] = {realmName = "Durotan", region = "US", language = "English"},
	["US-Duskwood"] = {realmName = "Duskwood", region = "US", language = "English"},
	["EU-EarthenRing"] = {realmName = "EarthenRing", region = "EU", language = "English"},
	["US-EarthenRing"] = {realmName = "EarthenRing", region = "US", language = "English"},
	["US-EchoIsles"] = {realmName = "EchoIsles", region = "US", language = "English"},
	["EU-Echsenkessel"] = {realmName = "Echsenkessel", region = "EU", language = "German"},
	["EU-Eitrigg"] = {realmName = "Eitrigg", region = "EU", language = "French"},
	["US-Eitrigg"] = {realmName = "Eitrigg", region = "US", language = "English"},
	["EU-Eldre'Thalas"] = {realmName = "Eldre'Thalas", region = "EU", language = "French"},
	["US-Eldre'Thalas"] = {realmName = "Eldre'Thalas", region = "US", language = "English"},
	["US-Elune"] = {realmName = "Elune", region = "US", language = "English"},
	["EU-Elune"] = {realmName = "Elune", region = "EU", language = "French"},
	["US-EmeraldDream"] = {realmName = "EmeraldDream", region = "US", language = "English"},
	["EU-EmeraldDream"] = {realmName = "EmeraldDream", region = "EU", language = "English"},
	["EU-Emeriss"] = {realmName = "Emeriss", region = "EU", language = "English"},
	["US-Eonar"] = {realmName = "Eonar", region = "US", language = "English"},
	["EU-Eonar"] = {realmName = "Eonar", region = "EU", language = "English"},
	["EU-Eredar"] = {realmName = "Eredar", region = "EU", language = "German"},
	["US-Eredar"] = {realmName = "Eredar", region = "US", language = "English"},
	["EU-Executus"] = {realmName = "Executus", region = "EU", language = "English"},
	["US-Executus"] = {realmName = "Executus", region = "US", language = "English"},
	["US-Exodar"] = {realmName = "Exodar", region = "US", language = "English"},
	["EU-Exodar"] = {realmName = "Exodar", region = "EU", language = "Spanish"},
	["US-Farstriders"] = {realmName = "Farstriders", region = "US", language = "English"},
	["US-Feathermoon"] = {realmName = "Feathermoon", region = "US", language = "English"},
	["US-Fenris"] = {realmName = "Fenris", region = "US", language = "English"},
	["EU-FestungderStürme"] = {realmName = "FestungderStürme", region = "EU", language = "German"},
	["US-Firetree"] = {realmName = "Firetree", region = "US", language = "English"},
	["US-Fizzcrank"] = {realmName = "Fizzcrank", region = "US", language = "English"},
	["EU-Forscherliga"] = {realmName = "Forscherliga", region = "EU", language = "German"},
	["US-Frostmane"] = {realmName = "Frostmane", region = "US", language = "English"},
	["EU-Frostmane"] = {realmName = "Frostmane", region = "EU", language = "EnglishPortuguese"},
	["US-Frostmourne"] = {realmName = "Frostmourne", region = "US", language = "English"},
	["EU-Frostmourne"] = {realmName = "Frostmourne", region = "EU", language = "German"},
	["EU-Frostwhisper"] = {realmName = "Frostwhisper", region = "EU", language = "English"},
	["US-Frostwolf"] = {realmName = "Frostwolf", region = "US", language = "English"},
	["EU-Frostwolf"] = {realmName = "Frostwolf", region = "EU", language = "German"},
	["US-Galakrond"] = {realmName = "Galakrond", region = "US", language = "English"},
	["US-Gallywix"] = {realmName = "Gallywix", region = "US", language = "Portuguese"},
	["US-Garithos"] = {realmName = "Garithos", region = "US", language = "English"},
	["US-Garona"] = {realmName = "Garona", region = "US", language = "English"},
	["EU-Garona"] = {realmName = "Garona", region = "EU", language = "French"},
	["US-Garrosh"] = {realmName = "Garrosh", region = "US", language = "English"},
	["EU-Garrosh"] = {realmName = "Garrosh", region = "EU", language = "German"},
	["EU-Genjuros"] = {realmName = "Genjuros", region = "EU", language = "English"},
	["US-Ghostlands"] = {realmName = "Ghostlands", region = "US", language = "English"},
	["EU-Ghostlands"] = {realmName = "Ghostlands", region = "EU", language = "English"},
	["US-Gilneas"] = {realmName = "Gilneas", region = "US", language = "English"},
	["EU-Gilneas"] = {realmName = "Gilneas", region = "EU", language = "German"},
	["US-Gnomeregan"] = {realmName = "Gnomeregan", region = "US", language = "English"},
	["US-Goldrinn"] = {realmName = "Goldrinn", region = "US", language = "Portuguese"},
	["US-Gorefiend"] = {realmName = "Gorefiend", region = "US", language = "English"},
	["EU-Gorgonnash"] = {realmName = "Gorgonnash", region = "EU", language = "German"},
	["US-Gorgonnash"] = {realmName = "Gorgonnash", region = "US", language = "English"},
	["US-Greymane"] = {realmName = "Greymane", region = "US", language = "English"},
	["EU-GrimBatol"] = {realmName = "GrimBatol", region = "EU", language = "EnglishPortuguese"},
	["US-GrizzlyHills"] = {realmName = "GrizzlyHills", region = "US", language = "English"},
	["US-Gul'dan"] = {realmName = "Gul'dan", region = "US", language = "English"},
	["EU-Gul'dan"] = {realmName = "Gul'dan", region = "EU", language = "German"},
	["US-Gundrak"] = {realmName = "Gundrak", region = "US", language = "English"},
	["US-Gurubashi"] = {realmName = "Gurubashi", region = "US", language = "English"},
	["US-Hakkar"] = {realmName = "Hakkar", region = "US", language = "English"},
	["EU-Hakkar"] = {realmName = "Hakkar", region = "EU", language = "English"},
	["EU-Haomarush"] = {realmName = "Haomarush", region = "EU", language = "English"},
	["US-Haomarush"] = {realmName = "Haomarush", region = "US", language = "English"},
	["EU-Hellfire"] = {realmName = "Hellfire", region = "EU", language = "English"},
	["US-Hellscream"] = {realmName = "Hellscream", region = "US", language = "English"},
	["EU-Hellscream"] = {realmName = "Hellscream", region = "EU", language = "English"},
	["US-Hydraxis"] = {realmName = "Hydraxis", region = "US", language = "English"},
	["EU-Hyjal"] = {realmName = "Hyjal", region = "EU", language = "French"},
	["US-Hyjal"] = {realmName = "Hyjal", region = "US", language = "English"},
	["US-Icecrown"] = {realmName = "Icecrown", region = "US", language = "English"},
	["US-Illidan"] = {realmName = "Illidan", region = "US", language = "English"},
	["EU-Illidan"] = {realmName = "Illidan", region = "EU", language = "French"},
	["EU-Jaedenar"] = {realmName = "Jaedenar", region = "EU", language = "English"},
	["US-Jaedenar"] = {realmName = "Jaedenar", region = "US", language = "English"},
	["US-Jubei'Thos"] = {realmName = "Jubei'Thos", region = "US", language = "English"},
	["US-Kael'thas"] = {realmName = "Kael'thas", region = "US", language = "English"},
	["EU-Kael'thas"] = {realmName = "Kael'thas", region = "EU", language = "French"},
	["US-Kalecgos"] = {realmName = "Kalecgos", region = "US", language = "English"},
	["EU-Karazhan"] = {realmName = "Karazhan", region = "EU", language = "English"},
	["EU-Kargath"] = {realmName = "Kargath", region = "EU", language = "German"},
	["US-Kargath"] = {realmName = "Kargath", region = "US", language = "English"},
	["EU-Kazzak"] = {realmName = "Kazzak", region = "EU", language = "English"},
	["US-Kel'Thuzad"] = {realmName = "Kel'Thuzad", region = "US", language = "English"},
	["EU-Kel'Thuzad"] = {realmName = "Kel'Thuzad", region = "EU", language = "German"},
	["US-Khadgar"] = {realmName = "Khadgar", region = "US", language = "English"},
	["EU-Khadgar"] = {realmName = "Khadgar", region = "EU", language = "English"},
	["US-Khaz'goroth"] = {realmName = "Khaz'goroth", region = "US", language = "English"},
	["EU-Khaz'goroth"] = {realmName = "Khaz'goroth", region = "EU", language = "German"},
	["US-KhazModan"] = {realmName = "KhazModan", region = "US", language = "English"},
	["EU-KhazModan"] = {realmName = "KhazModan", region = "EU", language = "French"},
	["US-Kil'jaeden"] = {realmName = "Kil'jaeden", region = "US", language = "English"},
	["EU-Kil'jaeden"] = {realmName = "Kil'jaeden", region = "EU", language = "German"},
	["EU-Kilrogg"] = {realmName = "Kilrogg", region = "EU", language = "English"},
	["US-Kilrogg"] = {realmName = "Kilrogg", region = "US", language = "English"},
	["EU-KirinTor"] = {realmName = "KirinTor", region = "EU", language = "French"},
	["US-KirinTor"] = {realmName = "KirinTor", region = "US", language = "English"},
	["EU-Kor'gall"] = {realmName = "Kor'gall", region = "EU", language = "English"},
	["US-Korgath"] = {realmName = "Korgath", region = "US", language = "English"},
	["US-Korialstrasz"] = {realmName = "Korialstrasz", region = "US", language = "English"},
	["EU-Krag'jin"] = {realmName = "Krag'jin", region = "EU", language = "German"},
	["EU-Krasus"] = {realmName = "Krasus", region = "EU", language = "French"},
	["EU-KultderVerdammten"] = {realmName = "KultderVerdammten", region = "EU", language = "German"},
	["EU-KulTiras"] = {realmName = "KulTiras", region = "EU", language = "English"},
	["US-KulTiras"] = {realmName = "KulTiras", region = "US", language = "English"},
	["EU-LaCroisadeécarlate"] = {realmName = "LaCroisadeécarlate", region = "EU", language = "French"},
	["US-LaughingSkull"] = {realmName = "LaughingSkull", region = "US", language = "English"},
	["EU-LaughingSkull"] = {realmName = "LaughingSkull", region = "EU", language = "English"},
	["EU-LesClairvoyants"] = {realmName = "LesClairvoyants", region = "EU", language = "French"},
	["EU-LesSentinelles"] = {realmName = "LesSentinelles", region = "EU", language = "French"},
	["US-Lethon"] = {realmName = "Lethon", region = "US", language = "English"},
	["US-Lightbringer"] = {realmName = "Lightbringer", region = "US", language = "English"},
	["EU-Lightbringer"] = {realmName = "Lightbringer", region = "EU", language = "English"},
	["US-Lightninghoof"] = {realmName = "Lightninghoof", region = "US", language = "English"},
	["US-Lightning'sBlade"] = {realmName = "Lightning'sBlade", region = "US", language = "English"},
	["EU-Lightning'sBlade"] = {realmName = "Lightning'sBlade", region = "EU", language = "English"},
	["US-Llane"] = {realmName = "Llane", region = "US", language = "English"},
	["EU-Lordaeron"] = {realmName = "Lordaeron", region = "EU", language = "German"},
	["EU-LosErrantes"] = {realmName = "LosErrantes", region = "EU", language = "Spanish"},
	["US-Lothar"] = {realmName = "Lothar", region = "US", language = "English"},
	["EU-Lothar"] = {realmName = "Lothar", region = "EU", language = "German"},
	["EU-Madmortem"] = {realmName = "Madmortem", region = "EU", language = "German"},
	["US-Madoran"] = {realmName = "Madoran", region = "US", language = "English"},
	["US-Maelstrom"] = {realmName = "Maelstrom", region = "US", language = "English"},
	["EU-Magtheridon"] = {realmName = "Magtheridon", region = "EU", language = "English"},
	["US-Magtheridon"] = {realmName = "Magtheridon", region = "US", language = "English"},
	["US-Maiev"] = {realmName = "Maiev", region = "US", language = "English"},
	["US-Malfurion"] = {realmName = "Malfurion", region = "US", language = "English"},
	["EU-Malfurion"] = {realmName = "Malfurion", region = "EU", language = "German"},
	["EU-Mal'Ganis"] = {realmName = "Mal'Ganis", region = "EU", language = "German"},
	["US-Mal'Ganis"] = {realmName = "Mal'Ganis", region = "US", language = "English"},
	["US-Malorne"] = {realmName = "Malorne", region = "US", language = "English"},
	["EU-Malorne"] = {realmName = "Malorne", region = "EU", language = "German"},
	["US-Malygos"] = {realmName = "Malygos", region = "US", language = "English"},
	["EU-Malygos"] = {realmName = "Malygos", region = "EU", language = "German"},
	["US-Mannoroth"] = {realmName = "Mannoroth", region = "US", language = "English"},
	["EU-Mannoroth"] = {realmName = "Mannoroth", region = "EU", language = "German"},
	["EU-MarécagedeZangar"] = {realmName = "MarécagedeZangar", region = "EU", language = "French"},
	["EU-Mazrigos"] = {realmName = "Mazrigos", region = "EU", language = "English"},
	["US-Medivh"] = {realmName = "Medivh", region = "US", language = "English"},
	["EU-Medivh"] = {realmName = "Medivh", region = "EU", language = "French"},
	["EU-Minahonda"] = {realmName = "Minahonda", region = "EU", language = "Spanish"},
	["US-Misha"] = {realmName = "Misha", region = "US", language = "English"},
	["US-Mok'Nathal"] = {realmName = "Mok'Nathal", region = "US", language = "English"},
	["EU-Moonglade"] = {realmName = "Moonglade", region = "EU", language = "English"},
	["US-MoonGuard"] = {realmName = "MoonGuard", region = "US", language = "English"},
	["US-Moonrunner"] = {realmName = "Moonrunner", region = "US", language = "English"},
	["US-Mug'thol"] = {realmName = "Mug'thol", region = "US", language = "English"},
	["EU-Mug'thol"] = {realmName = "Mug'thol", region = "EU", language = "German"},
	["US-Muradin"] = {realmName = "Muradin", region = "US", language = "English"},
	["EU-Nagrand"] = {realmName = "Nagrand", region = "EU", language = "English"},
	["US-Nagrand"] = {realmName = "Nagrand", region = "US", language = "English"},
	["US-Nathrezim"] = {realmName = "Nathrezim", region = "US", language = "English"},
	["EU-Nathrezim"] = {realmName = "Nathrezim", region = "EU", language = "German"},
	["EU-Naxxramas"] = {realmName = "Naxxramas", region = "EU", language = "French"},
	["US-Nazgrel"] = {realmName = "Nazgrel", region = "US", language = "English"},
	["US-Nazjatar"] = {realmName = "Nazjatar", region = "US", language = "English"},
	["EU-Nazjatar"] = {realmName = "Nazjatar", region = "EU", language = "German"},
	["EU-Nefarian"] = {realmName = "Nefarian", region = "EU", language = "German"},
	["EU-Nemesis"] = {realmName = "Nemesis", region = "EU", language = "Italian"},
	["US-Nemesis"] = {realmName = "Nemesis", region = "US", language = "Portuguese"},
	["EU-Neptulon"] = {realmName = "Neptulon", region = "EU", language = "English"},
	["EU-Nera'thor"] = {realmName = "Nera'thor", region = "EU", language = "German"},
	["US-Ner'zhul"] = {realmName = "Ner'zhul", region = "US", language = "English"},
	["EU-Ner'zhul"] = {realmName = "Ner'zhul", region = "EU", language = "French"},
	["US-Nesingwary"] = {realmName = "Nesingwary", region = "US", language = "English"},
	["EU-Nethersturm"] = {realmName = "Nethersturm", region = "EU", language = "German"},
	["US-Nordrassil"] = {realmName = "Nordrassil", region = "US", language = "English"},
	["EU-Nordrassil"] = {realmName = "Nordrassil", region = "EU", language = "English"},
	["US-Norgannon"] = {realmName = "Norgannon", region = "US", language = "English"},
	["EU-Norgannon"] = {realmName = "Norgannon", region = "EU", language = "German"},
	["EU-Nozdormu"] = {realmName = "Nozdormu", region = "EU", language = "German"},
	["US-Onyxia"] = {realmName = "Onyxia", region = "US", language = "English"},
	["EU-Onyxia"] = {realmName = "Onyxia", region = "EU", language = "German"},
	["EU-Outland"] = {realmName = "Outland", region = "EU", language = "English"},
	["US-Perenolde"] = {realmName = "Perenolde", region = "US", language = "English"},
	["EU-Perenolde"] = {realmName = "Perenolde", region = "EU", language = "German"},
	["EU-Pozzodell'Eternità"] = {realmName = "Pozzodell'Eternità", region = "EU", language = "Italian"},
	["US-Proudmoore"] = {realmName = "Proudmoore", region = "US", language = "English"},
	["EU-Proudmoore"] = {realmName = "Proudmoore", region = "EU", language = "German"},
	["US-Quel'dorei"] = {realmName = "Quel'dorei", region = "US", language = "English"},
	["US-Quel'Thalas"] = {realmName = "Quel'Thalas", region = "US", language = "Spanish"},
	["EU-Quel'Thalas"] = {realmName = "Quel'Thalas", region = "EU", language = "English"},
	["US-Ragnaros"] = {realmName = "Ragnaros", region = "US", language = "Spanish"},
	["EU-Ragnaros"] = {realmName = "Ragnaros", region = "EU", language = "English"},
	["EU-Rajaxx"] = {realmName = "Rajaxx", region = "EU", language = "German"},
	["EU-Rashgarroth"] = {realmName = "Rashgarroth", region = "EU", language = "French"},
	["EU-Ravencrest"] = {realmName = "Ravencrest", region = "EU", language = "English"},
	["US-Ravencrest"] = {realmName = "Ravencrest", region = "US", language = "English"},
	["EU-Ravenholdt"] = {realmName = "Ravenholdt", region = "EU", language = "English"},
	["US-Ravenholdt"] = {realmName = "Ravenholdt", region = "US", language = "English"},
	["EU-Rexxar"] = {realmName = "Rexxar", region = "EU", language = "German"},
	["US-Rexxar"] = {realmName = "Rexxar", region = "US", language = "English"},
	["US-Rivendare"] = {realmName = "Rivendare", region = "US", language = "English"},
	["EU-Runetotem"] = {realmName = "Runetotem", region = "EU", language = "English"},
	["US-Runetotem"] = {realmName = "Runetotem", region = "US", language = "English"},
	["EU-Sanguino"] = {realmName = "Sanguino", region = "EU", language = "Spanish"},
	["US-Sargeras"] = {realmName = "Sargeras", region = "US", language = "English"},
	["EU-Sargeras"] = {realmName = "Sargeras", region = "EU", language = "French"},
	["US-Saurfang"] = {realmName = "Saurfang", region = "US", language = "English"},
	["EU-Saurfang"] = {realmName = "Saurfang", region = "EU", language = "English"},
	["US-ScarletCrusade"] = {realmName = "ScarletCrusade", region = "US", language = "English"},
	["EU-ScarshieldLegion"] = {realmName = "ScarshieldLegion", region = "EU", language = "English"},
	["US-Scilla"] = {realmName = "Scilla", region = "US", language = "English"},
	["US-Sen'jin"] = {realmName = "Sen'jin", region = "US", language = "English"},
	["EU-Sen'jin"] = {realmName = "Sen'jin", region = "EU", language = "German"},
	["US-Sentinels"] = {realmName = "Sentinels", region = "US", language = "English"},
	["US-ShadowCouncil"] = {realmName = "ShadowCouncil", region = "US", language = "English"},
	["US-Shadowmoon"] = {realmName = "Shadowmoon", region = "US", language = "English"},
	["US-Shadowsong"] = {realmName = "Shadowsong", region = "US", language = "English"},
	["EU-Shadowsong"] = {realmName = "Shadowsong", region = "EU", language = "English"},
	["US-Shandris"] = {realmName = "Shandris", region = "US", language = "English"},
	["EU-ShatteredHalls"] = {realmName = "ShatteredHalls", region = "EU", language = "English"},
	["US-ShatteredHalls"] = {realmName = "ShatteredHalls", region = "US", language = "English"},
	["EU-ShatteredHand"] = {realmName = "ShatteredHand", region = "EU", language = "English"},
	["US-ShatteredHand"] = {realmName = "ShatteredHand", region = "US", language = "English"},
	["EU-Shattrath"] = {realmName = "Shattrath", region = "EU", language = "German"},
	["EU-Shen'dralar"] = {realmName = "Shen'dralar", region = "EU", language = "Spanish"},
	["US-Shu'halo"] = {realmName = "Shu'halo", region = "US", language = "English"},
	["US-SilverHand"] = {realmName = "SilverHand", region = "US", language = "English"},
	["EU-Silvermoon"] = {realmName = "Silvermoon", region = "EU", language = "English"},
	["US-Silvermoon"] = {realmName = "Silvermoon", region = "US", language = "English"},
	["EU-Sinstralis"] = {realmName = "Sinstralis", region = "EU", language = "French"},
	["US-SistersofElune"] = {realmName = "SistersofElune", region = "US", language = "English"},
	["EU-Skullcrusher"] = {realmName = "Skullcrusher", region = "EU", language = "English"},
	["US-Skullcrusher"] = {realmName = "Skullcrusher", region = "US", language = "English"},
	["US-Skywall"] = {realmName = "Skywall", region = "US", language = "English"},
	["US-Smolderthorn"] = {realmName = "Smolderthorn", region = "US", language = "English"},
	["US-Spinebreaker"] = {realmName = "Spinebreaker", region = "US", language = "English"},
	["EU-Spinebreaker"] = {realmName = "Spinebreaker", region = "EU", language = "English"},
	["US-Spirestone"] = {realmName = "Spirestone", region = "US", language = "English"},
	["EU-Sporeggar"] = {realmName = "Sporeggar", region = "EU", language = "English"},
	["US-Staghelm"] = {realmName = "Staghelm", region = "US", language = "English"},
	["EU-SteamwheedleCartel"] = {realmName = "SteamwheedleCartel", region = "EU", language = "English"},
	["US-SteamwheedleCartel"] = {realmName = "SteamwheedleCartel", region = "US", language = "English"},
	["US-Stonemaul"] = {realmName = "Stonemaul", region = "US", language = "English"},
	["US-Stormrage"] = {realmName = "Stormrage", region = "US", language = "English"},
	["EU-Stormrage"] = {realmName = "Stormrage", region = "EU", language = "English"},
	["EU-Stormreaver"] = {realmName = "Stormreaver", region = "EU", language = "English"},
	["US-Stormreaver"] = {realmName = "Stormreaver", region = "US", language = "English"},
	["EU-Stormscale"] = {realmName = "Stormscale", region = "EU", language = "English"},
	["US-Stormscale"] = {realmName = "Stormscale", region = "US", language = "English"},
	["EU-Sunstrider"] = {realmName = "Sunstrider", region = "EU", language = "English"},
	["US-Suramar"] = {realmName = "Suramar", region = "US", language = "English"},
	["EU-Suramar"] = {realmName = "Suramar", region = "EU", language = "French"},
	["EU-Sylvanas"] = {realmName = "Sylvanas", region = "EU", language = "English"},
	["EU-Taerar"] = {realmName = "Taerar", region = "EU", language = "German"},
	["EU-Talnivarr"] = {realmName = "Talnivarr", region = "EU", language = "English"},
	["US-Tanaris"] = {realmName = "Tanaris", region = "US", language = "English"},
	["EU-TarrenMill"] = {realmName = "TarrenMill", region = "EU", language = "English"},
	["EU-Teldrassil"] = {realmName = "Teldrassil", region = "EU", language = "German"},
	["EU-Templenoir"] = {realmName = "Templenoir", region = "EU", language = "French"},
	["US-Terenas"] = {realmName = "Terenas", region = "US", language = "English"},
	["EU-Terenas"] = {realmName = "Terenas", region = "EU", language = "English"},
	["EU-Terokkar"] = {realmName = "Terokkar", region = "EU", language = "English"},
	["US-Terokkar"] = {realmName = "Terokkar", region = "US", language = "English"},
	["EU-Terrordar"] = {realmName = "Terrordar", region = "EU", language = "German"},
	["US-Thaurissan"] = {realmName = "Thaurissan", region = "US", language = "English"},
	["US-TheForgottenCoast"] = {realmName = "TheForgottenCoast", region = "US", language = "English"},
	["EU-TheMaelstrom"] = {realmName = "TheMaelstrom", region = "EU", language = "English"},
	["EU-Theradras"] = {realmName = "Theradras", region = "EU", language = "German"},
	["US-TheScryers"] = {realmName = "TheScryers", region = "US", language = "English"},
	["EU-TheSha'tar"] = {realmName = "TheSha'tar", region = "EU", language = "English"},
	["US-TheUnderbog"] = {realmName = "TheUnderbog", region = "US", language = "English"},
	["EU-TheVentureCo"] = {realmName = "TheVentureCo", region = "EU", language = "English"},
	["US-TheVentureCo"] = {realmName = "TheVentureCo", region = "US", language = "English"},
	["US-ThoriumBrotherhood"] = {realmName = "ThoriumBrotherhood", region = "US", language = "English"},
	["US-Thrall"] = {realmName = "Thrall", region = "US", language = "English"},
	["EU-Thrall"] = {realmName = "Thrall", region = "EU", language = "German"},
	["EU-Throk'Feroth"] = {realmName = "Throk'Feroth", region = "EU", language = "French"},
	["US-Thunderhorn"] = {realmName = "Thunderhorn", region = "US", language = "English"},
	["EU-Thunderhorn"] = {realmName = "Thunderhorn", region = "EU", language = "English"},
	["US-Thunderlord"] = {realmName = "Thunderlord", region = "US", language = "English"},
	["US-Tichondrius"] = {realmName = "Tichondrius", region = "US", language = "English"},
	["EU-Tichondrius"] = {realmName = "Tichondrius", region = "EU", language = "German"},
	["EU-Tirion"] = {realmName = "Tirion", region = "EU", language = "German"},
	["EU-Todeswache"] = {realmName = "Todeswache", region = "EU", language = "German"},
	["US-TolBarad"] = {realmName = "TolBarad", region = "US", language = "Portuguese"},
	["US-Tortheldrin"] = {realmName = "Tortheldrin", region = "US", language = "English"},
	["US-Trollbane"] = {realmName = "Trollbane", region = "US", language = "English"},
	["EU-Trollbane"] = {realmName = "Trollbane", region = "EU", language = "English"},
	["EU-Turalyon"] = {realmName = "Turalyon", region = "EU", language = "English"},
	["US-Turalyon"] = {realmName = "Turalyon", region = "US", language = "English"},
	["EU-Twilight'sHammer"] = {realmName = "Twilight'sHammer", region = "EU", language = "English"},
	["EU-TwistingNether"] = {realmName = "TwistingNether", region = "EU", language = "English"},
	["US-TwistingNether"] = {realmName = "TwistingNether", region = "US", language = "English"},
	["EU-Tyrande"] = {realmName = "Tyrande", region = "EU", language = "Spanish"},
	["EU-Uldaman"] = {realmName = "Uldaman", region = "EU", language = "French"},
	["US-Uldaman"] = {realmName = "Uldaman", region = "US", language = "English"},
	["EU-Ulduar"] = {realmName = "Ulduar", region = "EU", language = "German"},
	["EU-Uldum"] = {realmName = "Uldum", region = "EU", language = "Spanish"},
	["US-Uldum"] = {realmName = "Uldum", region = "US", language = "English"},
	["US-Undermine"] = {realmName = "Undermine", region = "US", language = "English"},
	["EU-Un'Goro"] = {realmName = "Un'Goro", region = "EU", language = "German"},
	["US-Ursin"] = {realmName = "Ursin", region = "US", language = "English"},
	["US-Uther"] = {realmName = "Uther", region = "US", language = "English"},
	["EU-Varimathras"] = {realmName = "Varimathras", region = "EU", language = "French"},
	["US-Vashj"] = {realmName = "Vashj", region = "US", language = "English"},
	["EU-Vashj"] = {realmName = "Vashj", region = "EU", language = "English"},
	["EU-Vek'lor"] = {realmName = "Vek'lor", region = "EU", language = "German"},
	["EU-Vek'nilash"] = {realmName = "Vek'nilash", region = "EU", language = "English"},
	["US-Vek'nilash"] = {realmName = "Vek'nilash", region = "US", language = "English"},
	["US-Velen"] = {realmName = "Velen", region = "US", language = "English"},
	["EU-Vol'jin"] = {realmName = "Vol'jin", region = "EU", language = "French"},
	["US-Warsong"] = {realmName = "Warsong", region = "US", language = "English"},
	["US-Whisperwind"] = {realmName = "Whisperwind", region = "US", language = "English"},
	["US-Wildhammer"] = {realmName = "Wildhammer", region = "US", language = "English"},
	["EU-Wildhammer"] = {realmName = "Wildhammer", region = "EU", language = "English"},
	["US-Windrunner"] = {realmName = "Windrunner", region = "US", language = "English"},
	["US-Winterhoof"] = {realmName = "Winterhoof", region = "US", language = "English"},
	["EU-Wrathbringer"] = {realmName = "Wrathbringer", region = "EU", language = "German"},
	["US-WyrmrestAccord"] = {realmName = "WyrmrestAccord", region = "US", language = "English"},
	["EU-Xavius"] = {realmName = "Xavius", region = "EU", language = "English"},
	["US-Ysera"] = {realmName = "Ysera", region = "US", language = "English"},
	["EU-Ysera"] = {realmName = "Ysera", region = "EU", language = "German"},
	["EU-Ysondre"] = {realmName = "Ysondre", region = "EU", language = "French"},
	["US-Ysondre"] = {realmName = "Ysondre", region = "US", language = "English"},
	["US-Zangarmarsh"] = {realmName = "Zangarmarsh", region = "US", language = "English"},
	["EU-Zenedar"] = {realmName = "Zenedar", region = "EU", language = "English"},
	["EU-ZirkeldesCenarius"] = {realmName = "ZirkeldesCenarius", region = "EU", language = "German"},
	["US-Zul'jin"] = {realmName = "Zul'jin", region = "US", language = "English"},
	["EU-Zul'jin"] = {realmName = "Zul'jin", region = "EU", language = "Spanish"},
	["US-Zuluhed"] = {realmName = "Zuluhed", region = "US", language = "English"},
	["EU-Zuluhed"] = {realmName = "Zuluhed", region = "EU", language = "German"},
	["EU-Азурегос"] = {realmName = "Азурегос", region = "EU", language = "Russian"},
	["EU-Борейскаятундра"] = {realmName = "Борейскаятундра", region = "EU", language = "Russian"},
	["EU-ВечнаяПесня"] = {realmName = "ВечнаяПесня", region = "EU", language = "Russian"},
	["EU-Галакронд"] = {realmName = "Галакронд", region = "EU", language = "Russian"},
	["EU-Голдринн"] = {realmName = "Голдринн", region = "EU", language = "Russian"},
	["EU-Гордунни"] = {realmName = "Гордунни", region = "EU", language = "Russian"},
	["EU-Гром"] = {realmName = "Гром", region = "EU", language = "Russian"},
	["EU-Дракономор"] = {realmName = "Дракономор", region = "EU", language = "Russian"},
	["EU-Корольлич"] = {realmName = "Корольлич", region = "EU", language = "Russian"},
	["EU-ПиратскаяБухта"] = {realmName = "ПиратскаяБухта", region = "EU", language = "Russian"},
	["EU-Подземье"] = {realmName = "Подземье", region = "EU", language = "Russian"},
	["EU-Разувий"] = {realmName = "Разувий", region = "EU", language = "Russian"},
	["EU-Ревущийфьорд"] = {realmName = "Ревущийфьорд", region = "EU", language = "Russian"},
	["EU-СвежевательДуш"] = {realmName = "СвежевательДуш", region = "EU", language = "Russian"},
	["EU-Седогрив"] = {realmName = "Седогрив", region = "EU", language = "Russian"},
	["EU-СтражСмерти"] = {realmName = "СтражСмерти", region = "EU", language = "Russian"},
	["EU-Термоштепсель"] = {realmName = "Термоштепсель", region = "EU", language = "Russian"},
	["EU-ТкачСмерти"] = {realmName = "ТкачСмерти", region = "EU", language = "Russian"},
	["EU-ЧерныйШрам"] = {realmName = "ЧерныйШрам", region = "EU", language = "Russian"},
	["EU-Ясеневыйлес"] = {realmName = "Ясеневыйлес", region = "EU", language = "Russian"},
	["KR-가로나"] = {realmName = "가로나", region = "KR", language = "Korean"},
	["KR-굴단"] = {realmName = "굴단", region = "KR", language = "Korean"},
	["KR-노르간논"] = {realmName = "노르간논", region = "KR", language = "Korean"},
	["KR-달라란"] = {realmName = "달라란", region = "KR", language = "Korean"},
	["KR-데스윙"] = {realmName = "데스윙", region = "KR", language = "Korean"},
	["KR-듀로탄"] = {realmName = "듀로탄", region = "KR", language = "Korean"},
	["KR-렉사르"] = {realmName = "렉사르", region = "KR", language = "Korean"},
	["KR-말퓨리온"] = {realmName = "말퓨리온", region = "KR", language = "Korean"},
	["KR-불타는군단"] = {realmName = "불타는군단", region = "KR", language = "Korean"},
	["KR-세나리우스"] = {realmName = "세나리우스", region = "KR", language = "Korean"},
	["KR-스톰레이지"] = {realmName = "스톰레이지", region = "KR", language = "Korean"},
	["KR-아즈샤라"] = {realmName = "아즈샤라", region = "KR", language = "Korean"},
	["KR-알렉스트라자"] = {realmName = "알렉스트라자", region = "KR", language = "Korean"},
	["KR-와일드해머"] = {realmName = "와일드해머", region = "KR", language = "Korean"},
	["KR-윈드러너"] = {realmName = "윈드러너", region = "KR", language = "Korean"},
	["KR-줄진"] = {realmName = "줄진", region = "KR", language = "Korean"},
	["KR-하이잘"] = {realmName = "하이잘", region = "KR", language = "Korean"},
	["KR-헬스크림"] = {realmName = "헬스크림", region = "KR", language = "Korean"},
	["CN-万色星辰"] = {realmName = "万色星辰", region = "CN", language = "Chinese"},
	["CN-世界之树"] = {realmName = "世界之树", region = "CN", language = "Chinese"},
	["TW-世界之樹"] = {realmName = "世界之樹", region = "TW", language = "Chinese"},
	["CN-丹莫德"] = {realmName = "丹莫德", region = "CN", language = "Chinese"},
	["CN-主宰之剑"] = {realmName = "主宰之剑", region = "CN", language = "Chinese"},
	["CN-丽丽（四川）"] = {realmName = "丽丽（四川）", region = "CN", language = "Chinese"},
	["CN-亚雷戈斯"] = {realmName = "亚雷戈斯", region = "CN", language = "Chinese"},
	["TW-亞雷戈斯"] = {realmName = "亞雷戈斯", region = "TW", language = "Chinese"},
	["CN-亡语者"] = {realmName = "亡语者", region = "CN", language = "Chinese"},
	["CN-伊兰尼库斯"] = {realmName = "伊兰尼库斯", region = "CN", language = "Chinese"},
	["CN-伊利丹"] = {realmName = "伊利丹", region = "CN", language = "Chinese"},
	["CN-伊森利恩"] = {realmName = "伊森利恩", region = "CN", language = "Chinese"},
	["CN-伊森德雷"] = {realmName = "伊森德雷", region = "CN", language = "Chinese"},
	["CN-伊瑟拉"] = {realmName = "伊瑟拉", region = "CN", language = "Chinese"},
	["CN-伊莫塔尔"] = {realmName = "伊莫塔尔", region = "CN", language = "Chinese"},
	["CN-伊萨里奥斯"] = {realmName = "伊萨里奥斯", region = "CN", language = "Chinese"},
	["CN-元素之力"] = {realmName = "元素之力", region = "CN", language = "Chinese"},
	["CN-克尔苏加德"] = {realmName = "克尔苏加德", region = "CN", language = "Chinese"},
	["CN-克洛玛古斯"] = {realmName = "克洛玛古斯", region = "CN", language = "Chinese"},
	["TW-克羅之刃"] = {realmName = "克羅之刃", region = "TW", language = "Chinese"},
	["CN-克苏恩"] = {realmName = "克苏恩", region = "CN", language = "Chinese"},
	["CN-兰娜瑟尔"] = {realmName = "兰娜瑟尔", region = "CN", language = "Chinese"},
	["CN-军团要塞"] = {realmName = "军团要塞", region = "CN", language = "Chinese"},
	["CN-冬寒"] = {realmName = "冬寒", region = "CN", language = "Chinese"},
	["CN-冬拥湖"] = {realmName = "冬拥湖", region = "CN", language = "Chinese"},
	["CN-冬泉谷"] = {realmName = "冬泉谷", region = "CN", language = "Chinese"},
	["CN-冰川之拳"] = {realmName = "冰川之拳", region = "CN", language = "Chinese"},
	["CN-冰霜之刃"] = {realmName = "冰霜之刃", region = "CN", language = "Chinese"},
	["TW-冰霜之刺"] = {realmName = "冰霜之刺", region = "TW", language = "Chinese"},
	["TW-冰風崗哨"] = {realmName = "冰風崗哨", region = "TW", language = "Chinese"},
	["CN-冰风岗"] = {realmName = "冰风岗", region = "CN", language = "Chinese"},
	["CN-凤凰之神"] = {realmName = "凤凰之神", region = "CN", language = "Chinese"},
	["CN-凯尔萨斯"] = {realmName = "凯尔萨斯", region = "CN", language = "Chinese"},
	["CN-凯恩血蹄"] = {realmName = "凯恩血蹄", region = "CN", language = "Chinese"},
	["CN-刀塔"] = {realmName = "刀塔", region = "CN", language = "Chinese"},
	["CN-利刃之拳"] = {realmName = "利刃之拳", region = "CN", language = "Chinese"},
	["CN-刺骨利刃"] = {realmName = "刺骨利刃", region = "CN", language = "Chinese"},
	["CN-加兹鲁维"] = {realmName = "加兹鲁维", region = "CN", language = "Chinese"},
	["CN-加基森"] = {realmName = "加基森", region = "CN", language = "Chinese"},
	["CN-加尔"] = {realmName = "加尔", region = "CN", language = "Chinese"},
	["CN-加里索斯"] = {realmName = "加里索斯", region = "CN", language = "Chinese"},
	["CN-勇士岛"] = {realmName = "勇士岛", region = "CN", language = "Chinese"},
	["CN-千针石林"] = {realmName = "千针石林", region = "CN", language = "Chinese"},
	["CN-卡德加"] = {realmName = "卡德加", region = "CN", language = "Chinese"},
	["CN-卡德罗斯"] = {realmName = "卡德罗斯", region = "CN", language = "Chinese"},
	["CN-卡扎克"] = {realmName = "卡扎克", region = "CN", language = "Chinese"},
	["CN-卡拉赞"] = {realmName = "卡拉赞", region = "CN", language = "Chinese"},
	["CN-卡珊德拉"] = {realmName = "卡珊德拉", region = "CN", language = "Chinese"},
	["CN-厄祖玛特"] = {realmName = "厄祖玛特", region = "CN", language = "Chinese"},
	["CN-双子峰"] = {realmName = "双子峰", region = "CN", language = "Chinese"},
	["CN-古加尔"] = {realmName = "古加尔", region = "CN", language = "Chinese"},
	["CN-古尔丹"] = {realmName = "古尔丹", region = "CN", language = "Chinese"},
	["CN-古拉巴什"] = {realmName = "古拉巴什", region = "CN", language = "Chinese"},
	["CN-古达克"] = {realmName = "古达克", region = "CN", language = "Chinese"},
	["CN-哈兰"] = {realmName = "哈兰", region = "CN", language = "Chinese"},
	["CN-哈卡"] = {realmName = "哈卡", region = "CN", language = "Chinese"},
	["CN-嚎风峡湾"] = {realmName = "嚎风峡湾", region = "CN", language = "Chinese"},
	["CN-回音山"] = {realmName = "回音山", region = "CN", language = "Chinese"},
	["CN-国王之谷"] = {realmName = "国王之谷", region = "CN", language = "Chinese"},
	["CN-图拉扬"] = {realmName = "图拉扬", region = "CN", language = "Chinese"},
	["CN-圣火神殿"] = {realmName = "圣火神殿", region = "CN", language = "Chinese"},
	["CN-地狱之石"] = {realmName = "地狱之石", region = "CN", language = "Chinese"},
	["CN-地狱咆哮"] = {realmName = "地狱咆哮", region = "CN", language = "Chinese"},
	["TW-地獄吼"] = {realmName = "地獄吼", region = "TW", language = "Chinese"},
	["CN-埃克索图斯"] = {realmName = "埃克索图斯", region = "CN", language = "Chinese"},
	["CN-埃加洛尔"] = {realmName = "埃加洛尔", region = "CN", language = "Chinese"},
	["CN-埃基尔松"] = {realmName = "埃基尔松", region = "CN", language = "Chinese"},
	["CN-埃德萨拉"] = {realmName = "埃德萨拉", region = "CN", language = "Chinese"},
	["CN-埃苏雷格"] = {realmName = "埃苏雷格", region = "CN", language = "Chinese"},
	["CN-埃雷达尔"] = {realmName = "埃雷达尔", region = "CN", language = "Chinese"},
	["CN-埃霍恩"] = {realmName = "埃霍恩", region = "CN", language = "Chinese"},
	["CN-基尔加丹"] = {realmName = "基尔加丹", region = "CN", language = "Chinese"},
	["CN-基尔罗格"] = {realmName = "基尔罗格", region = "CN", language = "Chinese"},
	["CN-塔伦米尔"] = {realmName = "塔伦米尔", region = "CN", language = "Chinese"},
	["CN-塔纳利斯"] = {realmName = "塔纳利斯", region = "CN", language = "Chinese"},
	["CN-塞拉摩"] = {realmName = "塞拉摩", region = "CN", language = "Chinese"},
	["CN-塞拉赞恩"] = {realmName = "塞拉赞恩", region = "CN", language = "Chinese"},
	["CN-塞泰克"] = {realmName = "塞泰克", region = "CN", language = "Chinese"},
	["CN-塞纳留斯"] = {realmName = "塞纳留斯", region = "CN", language = "Chinese"},
	["CN-壁炉谷"] = {realmName = "壁炉谷", region = "CN", language = "Chinese"},
	["CN-夏维安"] = {realmName = "夏维安", region = "CN", language = "Chinese"},
	["CN-外域"] = {realmName = "外域", region = "CN", language = "Chinese"},
	["TW-夜空之歌"] = {realmName = "夜空之歌", region = "TW", language = "Chinese"},
	["CN-大地之怒"] = {realmName = "大地之怒", region = "CN", language = "Chinese"},
	["CN-大漩涡"] = {realmName = "大漩涡", region = "CN", language = "Chinese"},
	["CN-天空之墙"] = {realmName = "天空之墙", region = "CN", language = "Chinese"},
	["TW-天空之牆"] = {realmName = "天空之牆", region = "TW", language = "Chinese"},
	["CN-天谴之门"] = {realmName = "天谴之门", region = "CN", language = "Chinese"},
	["CN-太阳之井"] = {realmName = "太阳之井", region = "CN", language = "Chinese"},
	["CN-夺灵者"] = {realmName = "夺灵者", region = "CN", language = "Chinese"},
	["CN-奈法利安"] = {realmName = "奈法利安", region = "CN", language = "Chinese"},
	["CN-奈萨里奥"] = {realmName = "奈萨里奥", region = "CN", language = "Chinese"},
	["CN-奎尔丹纳斯"] = {realmName = "奎尔丹纳斯", region = "CN", language = "Chinese"},
	["CN-奎尔萨拉斯"] = {realmName = "奎尔萨拉斯", region = "CN", language = "Chinese"},
	["CN-奥妮克希亚"] = {realmName = "奥妮克希亚", region = "CN", language = "Chinese"},
	["CN-奥尔加隆"] = {realmName = "奥尔加隆", region = "CN", language = "Chinese"},
	["CN-奥拉基尔"] = {realmName = "奥拉基尔", region = "CN", language = "Chinese"},
	["CN-奥斯里安"] = {realmName = "奥斯里安", region = "CN", language = "Chinese"},
	["CN-奥杜尔"] = {realmName = "奥杜尔", region = "CN", language = "Chinese"},
	["CN-奥特兰克"] = {realmName = "奥特兰克", region = "CN", language = "Chinese"},
	["CN-奥蕾莉亚"] = {realmName = "奥蕾莉亚", region = "CN", language = "Chinese"},
	["CN-奥达曼"] = {realmName = "奥达曼", region = "CN", language = "Chinese"},
	["CN-奥金顿"] = {realmName = "奥金顿", region = "CN", language = "Chinese"},
	["CN-守护之剑"] = {realmName = "守护之剑", region = "CN", language = "Chinese"},
	["CN-安东尼达斯"] = {realmName = "安东尼达斯", region = "CN", language = "Chinese"},
	["CN-安其拉"] = {realmName = "安其拉", region = "CN", language = "Chinese"},
	["CN-安加萨"] = {realmName = "安加萨", region = "CN", language = "Chinese"},
	["CN-安威玛尔"] = {realmName = "安威玛尔", region = "CN", language = "Chinese"},
	["CN-安戈洛"] = {realmName = "安戈洛", region = "CN", language = "Chinese"},
	["CN-安格博达"] = {realmName = "安格博达", region = "CN", language = "Chinese"},
	["CN-安纳塞隆"] = {realmName = "安纳塞隆", region = "CN", language = "Chinese"},
	["CN-安苏"] = {realmName = "安苏", region = "CN", language = "Chinese"},
	["CN-密林游侠"] = {realmName = "密林游侠", region = "CN", language = "Chinese"},
	["TW-寒冰皇冠"] = {realmName = "寒冰皇冠", region = "TW", language = "Chinese"},
	["CN-寒冰皇冠"] = {realmName = "寒冰皇冠", region = "CN", language = "Chinese"},
	["TW-尖石"] = {realmName = "尖石", region = "TW", language = "Chinese"},
	["CN-尘风峡谷"] = {realmName = "尘风峡谷", region = "CN", language = "Chinese"},
	["TW-屠魔山谷"] = {realmName = "屠魔山谷", region = "TW", language = "Chinese"},
	["CN-屠魔山谷"] = {realmName = "屠魔山谷", region = "CN", language = "Chinese"},
	["CN-山丘之王"] = {realmName = "山丘之王", region = "CN", language = "Chinese"},
	["TW-巨龍之喉"] = {realmName = "巨龍之喉", region = "TW", language = "Chinese"},
	["CN-巨龙之吼"] = {realmName = "巨龙之吼", region = "CN", language = "Chinese"},
	["CN-巫妖之王"] = {realmName = "巫妖之王", region = "CN", language = "Chinese"},
	["CN-巴尔古恩"] = {realmName = "巴尔古恩", region = "CN", language = "Chinese"},
	["CN-巴瑟拉斯"] = {realmName = "巴瑟拉斯", region = "CN", language = "Chinese"},
	["CN-巴纳扎尔"] = {realmName = "巴纳扎尔", region = "CN", language = "Chinese"},
	["CN-布兰卡德"] = {realmName = "布兰卡德", region = "CN", language = "Chinese"},
	["CN-布莱克摩"] = {realmName = "布莱克摩", region = "CN", language = "Chinese"},
	["CN-布莱恩"] = {realmName = "布莱恩", region = "CN", language = "Chinese"},
	["CN-布鲁塔卢斯"] = {realmName = "布鲁塔卢斯", region = "CN", language = "Chinese"},
	["CN-希尔瓦娜斯"] = {realmName = "希尔瓦娜斯", region = "CN", language = "Chinese"},
	["CN-希雷诺斯"] = {realmName = "希雷诺斯", region = "CN", language = "Chinese"},
	["CN-幽暗沼泽"] = {realmName = "幽暗沼泽", region = "CN", language = "Chinese"},
	["CN-库尔提拉斯"] = {realmName = "库尔提拉斯", region = "CN", language = "Chinese"},
	["CN-库德兰"] = {realmName = "库德兰", region = "CN", language = "Chinese"},
	["CN-弗塞雷迦"] = {realmName = "弗塞雷迦", region = "CN", language = "Chinese"},
	["CN-影之哀伤"] = {realmName = "影之哀伤", region = "CN", language = "Chinese"},
	["CN-影牙要塞"] = {realmName = "影牙要塞", region = "CN", language = "Chinese"},
	["CN-德拉诺"] = {realmName = "德拉诺", region = "CN", language = "Chinese"},
	["CN-恐怖图腾"] = {realmName = "恐怖图腾", region = "CN", language = "Chinese"},
	["CN-恶魔之翼"] = {realmName = "恶魔之翼", region = "CN", language = "Chinese"},
	["CN-恶魔之魂"] = {realmName = "恶魔之魂", region = "CN", language = "Chinese"},
	["TW-憤怒使者"] = {realmName = "憤怒使者", region = "TW", language = "Chinese"},
	["CN-戈古纳斯"] = {realmName = "戈古纳斯", region = "CN", language = "Chinese"},
	["CN-戈提克"] = {realmName = "戈提克", region = "CN", language = "Chinese"},
	["CN-战歌"] = {realmName = "战歌", region = "CN", language = "Chinese"},
	["CN-扎拉赞恩"] = {realmName = "扎拉赞恩", region = "CN", language = "Chinese"},
	["CN-托塞德林"] = {realmName = "托塞德林", region = "CN", language = "Chinese"},
	["CN-托尔巴拉德"] = {realmName = "托尔巴拉德", region = "CN", language = "Chinese"},
	["CN-拉文凯斯"] = {realmName = "拉文凯斯", region = "CN", language = "Chinese"},
	["CN-拉文霍德"] = {realmName = "拉文霍德", region = "CN", language = "Chinese"},
	["CN-拉格纳罗斯"] = {realmName = "拉格纳罗斯", region = "CN", language = "Chinese"},
	["CN-拉贾克斯"] = {realmName = "拉贾克斯", region = "CN", language = "Chinese"},
	["CN-提尔之手"] = {realmName = "提尔之手", region = "CN", language = "Chinese"},
	["CN-提瑞斯法"] = {realmName = "提瑞斯法", region = "CN", language = "Chinese"},
	["CN-摩摩尔"] = {realmName = "摩摩尔", region = "CN", language = "Chinese"},
	["CN-斩魔者"] = {realmName = "斩魔者", region = "CN", language = "Chinese"},
	["CN-斯克提斯"] = {realmName = "斯克提斯", region = "CN", language = "Chinese"},
	["CN-斯坦索姆"] = {realmName = "斯坦索姆", region = "CN", language = "Chinese"},
	["CN-无尽之海"] = {realmName = "无尽之海", region = "CN", language = "Chinese"},
	["CN-无底海渊"] = {realmName = "无底海渊", region = "CN", language = "Chinese"},
	["CN-日落沼泽"] = {realmName = "日落沼泽", region = "CN", language = "Chinese"},
	["TW-日落沼澤"] = {realmName = "日落沼澤", region = "TW", language = "Chinese"},
	["CN-时光之穴"] = {realmName = "时光之穴", region = "CN", language = "Chinese"},
	["CN-普瑞斯托"] = {realmName = "普瑞斯托", region = "CN", language = "Chinese"},
	["CN-普罗德摩"] = {realmName = "普罗德摩", region = "CN", language = "Chinese"},
	["CN-晴日峰（江苏）"] = {realmName = "晴日峰（江苏）", region = "CN", language = "Chinese"},
	["TW-暗影之月"] = {realmName = "暗影之月", region = "TW", language = "Chinese"},
	["CN-暗影之月"] = {realmName = "暗影之月", region = "CN", language = "Chinese"},
	["CN-暗影裂口"] = {realmName = "暗影裂口", region = "CN", language = "Chinese"},
	["CN-暗影议会"] = {realmName = "暗影议会", region = "CN", language = "Chinese"},
	["CN-暗影迷宫"] = {realmName = "暗影迷宫", region = "CN", language = "Chinese"},
	["CN-暮色森林"] = {realmName = "暮色森林", region = "CN", language = "Chinese"},
	["CN-暴风祭坛"] = {realmName = "暴风祭坛", region = "CN", language = "Chinese"},
	["CN-月光林地"] = {realmName = "月光林地", region = "CN", language = "Chinese"},
	["CN-月神殿"] = {realmName = "月神殿", region = "CN", language = "Chinese"},
	["CN-末日祷告祭坛"] = {realmName = "末日祷告祭坛", region = "CN", language = "Chinese"},
	["CN-末日行者"] = {realmName = "末日行者", region = "CN", language = "Chinese"},
	["CN-朵丹尼尔"] = {realmName = "朵丹尼尔", region = "CN", language = "Chinese"},
	["CN-杜隆坦"] = {realmName = "杜隆坦", region = "CN", language = "Chinese"},
	["CN-格瑞姆巴托"] = {realmName = "格瑞姆巴托", region = "CN", language = "Chinese"},
	["CN-格雷迈恩"] = {realmName = "格雷迈恩", region = "CN", language = "Chinese"},
	["CN-格鲁尔"] = {realmName = "格鲁尔", region = "CN", language = "Chinese"},
	["CN-桑德兰"] = {realmName = "桑德兰", region = "CN", language = "Chinese"},
	["CN-梅尔加尼"] = {realmName = "梅尔加尼", region = "CN", language = "Chinese"},
	["CN-梦境之树"] = {realmName = "梦境之树", region = "CN", language = "Chinese"},
	["CN-森金"] = {realmName = "森金", region = "CN", language = "Chinese"},
	["CN-死亡之翼"] = {realmName = "死亡之翼", region = "CN", language = "Chinese"},
	["CN-死亡熔炉"] = {realmName = "死亡熔炉", region = "CN", language = "Chinese"},
	["CN-毁灭之锤"] = {realmName = "毁灭之锤", region = "CN", language = "Chinese"},
	["TW-水晶之刺"] = {realmName = "水晶之刺", region = "TW", language = "Chinese"},
	["CN-永夜港"] = {realmName = "永夜港", region = "CN", language = "Chinese"},
	["CN-永恒之井"] = {realmName = "永恒之井", region = "CN", language = "Chinese"},
	["CN-沃金"] = {realmName = "沃金", region = "CN", language = "Chinese"},
	["CN-沙怒"] = {realmName = "沙怒", region = "CN", language = "Chinese"},
	["CN-法拉希姆"] = {realmName = "法拉希姆", region = "CN", language = "Chinese"},
	["CN-泰兰德"] = {realmName = "泰兰德", region = "CN", language = "Chinese"},
	["CN-泰拉尔"] = {realmName = "泰拉尔", region = "CN", language = "Chinese"},
	["CN-洛丹伦"] = {realmName = "洛丹伦", region = "CN", language = "Chinese"},
	["CN-洛肯"] = {realmName = "洛肯", region = "CN", language = "Chinese"},
	["CN-洛萨"] = {realmName = "洛萨", region = "CN", language = "Chinese"},
	["CN-海克泰尔"] = {realmName = "海克泰尔", region = "CN", language = "Chinese"},
	["CN-海加尔"] = {realmName = "海加尔", region = "CN", language = "Chinese"},
	["CN-海达希亚"] = {realmName = "海达希亚", region = "CN", language = "Chinese"},
	["CN-深渊之喉"] = {realmName = "深渊之喉", region = "CN", language = "Chinese"},
	["CN-深渊之巢"] = {realmName = "深渊之巢", region = "CN", language = "Chinese"},
	["CN-激流之傲"] = {realmName = "激流之傲", region = "CN", language = "Chinese"},
	["CN-激流堡"] = {realmName = "激流堡", region = "CN", language = "Chinese"},
	["CN-火喉"] = {realmName = "火喉", region = "CN", language = "Chinese"},
	["CN-火烟之谷"] = {realmName = "火烟之谷", region = "CN", language = "Chinese"},
	["CN-火焰之树"] = {realmName = "火焰之树", region = "CN", language = "Chinese"},
	["CN-火羽山"] = {realmName = "火羽山", region = "CN", language = "Chinese"},
	["CN-灰谷"] = {realmName = "灰谷", region = "CN", language = "Chinese"},
	["CN-烈焰峰"] = {realmName = "烈焰峰", region = "CN", language = "Chinese"},
	["CN-烈焰荆棘"] = {realmName = "烈焰荆棘", region = "CN", language = "Chinese"},
	["CN-熊猫酒仙"] = {realmName = "熊猫酒仙", region = "CN", language = "Chinese"},
	["CN-熔火之心"] = {realmName = "熔火之心", region = "CN", language = "Chinese"},
	["CN-熵魔"] = {realmName = "熵魔", region = "CN", language = "Chinese"},
	["CN-燃烧之刃"] = {realmName = "燃烧之刃", region = "CN", language = "Chinese"},
	["CN-燃烧军团"] = {realmName = "燃烧军团", region = "CN", language = "Chinese"},
	["CN-燃烧平原"] = {realmName = "燃烧平原", region = "CN", language = "Chinese"},
	["CN-爱斯特纳"] = {realmName = "爱斯特纳", region = "CN", language = "Chinese"},
	["CN-狂热之刃"] = {realmName = "狂热之刃", region = "CN", language = "Chinese"},
	["TW-狂熱之刃"] = {realmName = "狂熱之刃", region = "TW", language = "Chinese"},
	["CN-狂风峭壁"] = {realmName = "狂风峭壁", region = "CN", language = "Chinese"},
	["CN-玛多兰"] = {realmName = "玛多兰", region = "CN", language = "Chinese"},
	["CN-玛格曼达"] = {realmName = "玛格曼达", region = "CN", language = "Chinese"},
	["CN-玛法里奥"] = {realmName = "玛法里奥", region = "CN", language = "Chinese"},
	["CN-玛洛加尔"] = {realmName = "玛洛加尔", region = "CN", language = "Chinese"},
	["CN-玛瑟里顿"] = {realmName = "玛瑟里顿", region = "CN", language = "Chinese"},
	["CN-玛维·影歌"] = {realmName = "玛维·影歌", region = "CN", language = "Chinese"},
	["CN-玛诺洛斯"] = {realmName = "玛诺洛斯", region = "CN", language = "Chinese"},
	["CN-玛里苟斯"] = {realmName = "玛里苟斯", region = "CN", language = "Chinese"},
	["CN-瑞文戴尔"] = {realmName = "瑞文戴尔", region = "CN", language = "Chinese"},
	["CN-瑟莱德丝"] = {realmName = "瑟莱德丝", region = "CN", language = "Chinese"},
	["CN-瓦丝琪"] = {realmName = "瓦丝琪", region = "CN", language = "Chinese"},
	["CN-瓦拉斯塔兹"] = {realmName = "瓦拉斯塔兹", region = "CN", language = "Chinese"},
	["CN-瓦拉纳"] = {realmName = "瓦拉纳", region = "CN", language = "Chinese"},
	["CN-瓦里安"] = {realmName = "瓦里安", region = "CN", language = "Chinese"},
	["CN-瓦里玛萨斯"] = {realmName = "瓦里玛萨斯", region = "CN", language = "Chinese"},
	["CN-甜水绿洲"] = {realmName = "甜水绿洲", region = "CN", language = "Chinese"},
	["CN-生态船"] = {realmName = "生态船", region = "CN", language = "Chinese"},
	["CN-白银之手"] = {realmName = "白银之手", region = "CN", language = "Chinese"},
	["CN-白骨荒野"] = {realmName = "白骨荒野", region = "CN", language = "Chinese"},
	["CN-盖斯"] = {realmName = "盖斯", region = "CN", language = "Chinese"},
	["TW-眾星之子"] = {realmName = "眾星之子", region = "TW", language = "Chinese"},
	["CN-石爪峰"] = {realmName = "石爪峰", region = "CN", language = "Chinese"},
	["CN-石锤"] = {realmName = "石锤", region = "CN", language = "Chinese"},
	["CN-破碎岭"] = {realmName = "破碎岭", region = "CN", language = "Chinese"},
	["CN-祖尔金"] = {realmName = "祖尔金", region = "CN", language = "Chinese"},
	["CN-祖达克"] = {realmName = "祖达克", region = "CN", language = "Chinese"},
	["CN-祖阿曼"] = {realmName = "祖阿曼", region = "CN", language = "Chinese"},
	["CN-神圣之歌"] = {realmName = "神圣之歌", region = "CN", language = "Chinese"},
	["CN-穆戈尔"] = {realmName = "穆戈尔", region = "CN", language = "Chinese"},
	["CN-符文图腾"] = {realmName = "符文图腾", region = "CN", language = "Chinese"},
	["CN-米奈希尔"] = {realmName = "米奈希尔", region = "CN", language = "Chinese"},
	["TW-米奈希爾"] = {realmName = "米奈希爾", region = "TW", language = "Chinese"},
	["CN-索拉丁"] = {realmName = "索拉丁", region = "CN", language = "Chinese"},
	["CN-索瑞森"] = {realmName = "索瑞森", region = "CN", language = "Chinese"},
	["CN-红云台地"] = {realmName = "红云台地", region = "CN", language = "Chinese"},
	["CN-红龙军团"] = {realmName = "红龙军团", region = "CN", language = "Chinese"},
	["CN-红龙女王"] = {realmName = "红龙女王", region = "CN", language = "Chinese"},
	["CN-纳克萨玛斯"] = {realmName = "纳克萨玛斯", region = "CN", language = "Chinese"},
	["CN-纳沙塔尔"] = {realmName = "纳沙塔尔", region = "CN", language = "Chinese"},
	["CN-织亡者"] = {realmName = "织亡者", region = "CN", language = "Chinese"},
	["CN-罗宁"] = {realmName = "罗宁", region = "CN", language = "Chinese"},
	["CN-罗曼斯"] = {realmName = "罗曼斯", region = "CN", language = "Chinese"},
	["CN-羽月"] = {realmName = "羽月", region = "CN", language = "Chinese"},
	["CN-翡翠梦境"] = {realmName = "翡翠梦境", region = "CN", language = "Chinese"},
	["TW-老馬布蘭契"] = {realmName = "老馬布蘭契", region = "TW", language = "Chinese"},
	["CN-耐奥祖"] = {realmName = "耐奥祖", region = "CN", language = "Chinese"},
	["CN-耐普图隆"] = {realmName = "耐普图隆", region = "CN", language = "Chinese"},
	["CN-耳语海岸"] = {realmName = "耳语海岸", region = "CN", language = "Chinese"},
	["TW-聖光之願"] = {realmName = "聖光之願", region = "TW", language = "Chinese"},
	["CN-能源舰"] = {realmName = "能源舰", region = "CN", language = "Chinese"},
	["CN-自由之风"] = {realmName = "自由之风", region = "CN", language = "Chinese"},
	["CN-艾森娜"] = {realmName = "艾森娜", region = "CN", language = "Chinese"},
	["CN-艾欧娜尔"] = {realmName = "艾欧娜尔", region = "CN", language = "Chinese"},
	["CN-艾维娜"] = {realmName = "艾维娜", region = "CN", language = "Chinese"},
	["CN-艾苏恩"] = {realmName = "艾苏恩", region = "CN", language = "Chinese"},
	["CN-艾莫莉丝"] = {realmName = "艾莫莉丝", region = "CN", language = "Chinese"},
	["CN-艾萨拉"] = {realmName = "艾萨拉", region = "CN", language = "Chinese"},
	["CN-艾露恩"] = {realmName = "艾露恩", region = "CN", language = "Chinese"},
	["CN-芬里斯"] = {realmName = "芬里斯", region = "CN", language = "Chinese"},
	["CN-苏塔恩"] = {realmName = "苏塔恩", region = "CN", language = "Chinese"},
	["CN-苏拉玛"] = {realmName = "苏拉玛", region = "CN", language = "Chinese"},
	["CN-范克里夫"] = {realmName = "范克里夫", region = "CN", language = "Chinese"},
	["CN-范达尔鹿盔"] = {realmName = "范达尔鹿盔", region = "CN", language = "Chinese"},
	["CN-荆棘谷"] = {realmName = "荆棘谷", region = "CN", language = "Chinese"},
	["CN-莉亚德琳"] = {realmName = "莉亚德琳", region = "CN", language = "Chinese"},
	["CN-莱索恩"] = {realmName = "莱索恩", region = "CN", language = "Chinese"},
	["CN-菲拉斯"] = {realmName = "菲拉斯", region = "CN", language = "Chinese"},
	["CN-菲米丝"] = {realmName = "菲米丝", region = "CN", language = "Chinese"},
	["CN-萨尔"] = {realmName = "萨尔", region = "CN", language = "Chinese"},
	["CN-萨格拉斯"] = {realmName = "萨格拉斯", region = "CN", language = "Chinese"},
	["CN-萨洛拉丝"] = {realmName = "萨洛拉丝", region = "CN", language = "Chinese"},
	["CN-萨菲隆"] = {realmName = "萨菲隆", region = "CN", language = "Chinese"},
	["CN-蓝龙军团"] = {realmName = "蓝龙军团", region = "CN", language = "Chinese"},
	["CN-藏宝海湾"] = {realmName = "藏宝海湾", region = "CN", language = "Chinese"},
	["CN-蜘蛛王国"] = {realmName = "蜘蛛王国", region = "CN", language = "Chinese"},
	["TW-血之谷"] = {realmName = "血之谷", region = "TW", language = "Chinese"},
	["CN-血吼"] = {realmName = "血吼", region = "CN", language = "Chinese"},
	["CN-血牙魔王"] = {realmName = "血牙魔王", region = "CN", language = "Chinese"},
	["CN-血环"] = {realmName = "血环", region = "CN", language = "Chinese"},
	["CN-血羽"] = {realmName = "血羽", region = "CN", language = "Chinese"},
	["CN-血色十字军"] = {realmName = "血色十字军", region = "CN", language = "Chinese"},
	["CN-血顶"] = {realmName = "血顶", region = "CN", language = "Chinese"},
	["TW-語風"] = {realmName = "語風", region = "TW", language = "Chinese"},
	["CN-试炼之环"] = {realmName = "试炼之环", region = "CN", language = "Chinese"},
	["CN-诺兹多姆"] = {realmName = "诺兹多姆", region = "CN", language = "Chinese"},
	["CN-诺森德"] = {realmName = "诺森德", region = "CN", language = "Chinese"},
	["CN-诺莫瑞根"] = {realmName = "诺莫瑞根", region = "CN", language = "Chinese"},
	["CN-贫瘠之地"] = {realmName = "贫瘠之地", region = "CN", language = "Chinese"},
	["CN-踏梦者"] = {realmName = "踏梦者", region = "CN", language = "Chinese"},
	["CN-轻风之语"] = {realmName = "轻风之语", region = "CN", language = "Chinese"},
	["CN-辛达苟萨"] = {realmName = "辛达苟萨", region = "CN", language = "Chinese"},
	["CN-达克萨隆"] = {realmName = "达克萨隆", region = "CN", language = "Chinese"},
	["CN-达基萨斯"] = {realmName = "达基萨斯", region = "CN", language = "Chinese"},
	["CN-达尔坎"] = {realmName = "达尔坎", region = "CN", language = "Chinese"},
	["CN-达文格尔"] = {realmName = "达文格尔", region = "CN", language = "Chinese"},
	["CN-达斯雷玛"] = {realmName = "达斯雷玛", region = "CN", language = "Chinese"},
	["CN-达纳斯"] = {realmName = "达纳斯", region = "CN", language = "Chinese"},
	["CN-达隆米尔"] = {realmName = "达隆米尔", region = "CN", language = "Chinese"},
	["CN-迅捷微风"] = {realmName = "迅捷微风", region = "CN", language = "Chinese"},
	["CN-远古海滩"] = {realmName = "远古海滩", region = "CN", language = "Chinese"},
	["CN-迦拉克隆"] = {realmName = "迦拉克隆", region = "CN", language = "Chinese"},
	["CN-迦玛兰"] = {realmName = "迦玛兰", region = "CN", language = "Chinese"},
	["CN-迦罗娜"] = {realmName = "迦罗娜", region = "CN", language = "Chinese"},
	["CN-迦顿"] = {realmName = "迦顿", region = "CN", language = "Chinese"},
	["CN-迪托马斯"] = {realmName = "迪托马斯", region = "CN", language = "Chinese"},
	["CN-迪瑟洛克"] = {realmName = "迪瑟洛克", region = "CN", language = "Chinese"},
	["CN-逐日者"] = {realmName = "逐日者", region = "CN", language = "Chinese"},
	["CN-通灵学院"] = {realmName = "通灵学院", region = "CN", language = "Chinese"},
	["CN-遗忘海岸"] = {realmName = "遗忘海岸", region = "CN", language = "Chinese"},
	["CN-金度"] = {realmName = "金度", region = "CN", language = "Chinese"},
	["CN-金色平原"] = {realmName = "金色平原", region = "CN", language = "Chinese"},
	["TW-銀翼要塞"] = {realmName = "銀翼要塞", region = "TW", language = "Chinese"},
	["CN-铜龙军团"] = {realmName = "铜龙军团", region = "CN", language = "Chinese"},
	["CN-银月"] = {realmName = "银月", region = "CN", language = "Chinese"},
	["CN-银松森林"] = {realmName = "银松森林", region = "CN", language = "Chinese"},
	["CN-闪电之刃"] = {realmName = "闪电之刃", region = "CN", language = "Chinese"},
	["CN-阿克蒙德"] = {realmName = "阿克蒙德", region = "CN", language = "Chinese"},
	["CN-阿努巴拉克"] = {realmName = "阿努巴拉克", region = "CN", language = "Chinese"},
	["CN-阿卡玛"] = {realmName = "阿卡玛", region = "CN", language = "Chinese"},
	["CN-阿古斯"] = {realmName = "阿古斯", region = "CN", language = "Chinese"},
	["CN-阿尔萨斯"] = {realmName = "阿尔萨斯", region = "CN", language = "Chinese"},
	["CN-阿扎达斯"] = {realmName = "阿扎达斯", region = "CN", language = "Chinese"},
	["CN-阿拉希"] = {realmName = "阿拉希", region = "CN", language = "Chinese"},
	["CN-阿拉索"] = {realmName = "阿拉索", region = "CN", language = "Chinese"},
	["CN-阿斯塔洛"] = {realmName = "阿斯塔洛", region = "CN", language = "Chinese"},
	["CN-阿曼尼"] = {realmName = "阿曼尼", region = "CN", language = "Chinese"},
	["CN-阿格拉玛"] = {realmName = "阿格拉玛", region = "CN", language = "Chinese"},
	["CN-阿比迪斯"] = {realmName = "阿比迪斯", region = "CN", language = "Chinese"},
	["CN-阿纳克洛斯"] = {realmName = "阿纳克洛斯", region = "CN", language = "Chinese"},
	["TW-阿薩斯"] = {realmName = "阿薩斯", region = "TW", language = "Chinese"},
	["CN-阿迦玛甘"] = {realmName = "阿迦玛甘", region = "CN", language = "Chinese"},
	["CN-雏龙之翼"] = {realmName = "雏龙之翼", region = "CN", language = "Chinese"},
	["TW-雲蛟衛"] = {realmName = "雲蛟衛", region = "TW", language = "Chinese"},
	["CN-雷克萨"] = {realmName = "雷克萨", region = "CN", language = "Chinese"},
	["CN-雷斧堡垒"] = {realmName = "雷斧堡垒", region = "CN", language = "Chinese"},
	["CN-雷霆之怒"] = {realmName = "雷霆之怒", region = "CN", language = "Chinese"},
	["CN-雷霆之王"] = {realmName = "雷霆之王", region = "CN", language = "Chinese"},
	["CN-雷霆号角"] = {realmName = "雷霆号角", region = "CN", language = "Chinese"},
	["TW-雷鱗"] = {realmName = "雷鱗", region = "TW", language = "Chinese"},
	["CN-霍格"] = {realmName = "霍格", region = "CN", language = "Chinese"},
	["CN-霜之哀伤"] = {realmName = "霜之哀伤", region = "CN", language = "Chinese"},
	["CN-霜狼"] = {realmName = "霜狼", region = "CN", language = "Chinese"},
	["CN-风暴之怒"] = {realmName = "风暴之怒", region = "CN", language = "Chinese"},
	["CN-风暴之眼"] = {realmName = "风暴之眼", region = "CN", language = "Chinese"},
	["CN-风暴之鳞"] = {realmName = "风暴之鳞", region = "CN", language = "Chinese"},
	["CN-风暴峭壁"] = {realmName = "风暴峭壁", region = "CN", language = "Chinese"},
	["CN-风行者"] = {realmName = "风行者", region = "CN", language = "Chinese"},
	["CN-鬼雾峰"] = {realmName = "鬼雾峰", region = "CN", language = "Chinese"},
	["CN-鲜血熔炉"] = {realmName = "鲜血熔炉", region = "CN", language = "Chinese"},
	["CN-鹰巢山"] = {realmName = "鹰巢山", region = "CN", language = "Chinese"},
	["CN-麦姆"] = {realmName = "麦姆", region = "CN", language = "Chinese"},
	["CN-麦迪文"] = {realmName = "麦迪文", region = "CN", language = "Chinese"},
	["CN-黄金之路"] = {realmName = "黄金之路", region = "CN", language = "Chinese"},
	["CN-黑手军团"] = {realmName = "黑手军团", region = "CN", language = "Chinese"},
	["CN-黑暗之矛"] = {realmName = "黑暗之矛", region = "CN", language = "Chinese"},
	["CN-黑暗之门"] = {realmName = "黑暗之门", region = "CN", language = "Chinese"},
	["CN-黑暗虚空"] = {realmName = "黑暗虚空", region = "CN", language = "Chinese"},
	["CN-黑暗魅影"] = {realmName = "黑暗魅影", region = "CN", language = "Chinese"},
	["CN-黑石尖塔"] = {realmName = "黑石尖塔", region = "CN", language = "Chinese"},
	["CN-黑翼之巢"] = {realmName = "黑翼之巢", region = "CN", language = "Chinese"},
	["CN-黑铁"] = {realmName = "黑铁", region = "CN", language = "Chinese"},
	["CN-黑锋哨站"] = {realmName = "黑锋哨站", region = "CN", language = "Chinese"},
	["CN-黑龙军团"] = {realmName = "黑龙军团", region = "CN", language = "Chinese"},
	["CN-龙骨平原"] = {realmName = "龙骨平原", region = "CN", language = "Chinese"},
}

miog.getRealmData = function(realmName, region)
	local actualRegion = strupper(region or miog.F.CURRENT_REGION)
	local fullName = actualRegion .. "-" .. realmName
	local realmData = miog.REALMS_TO_LANGUAGE[fullName]
	
	if(realmData) then
		local countryFlag = miog.C.STANDARD_FILE_PATH .. "/flagIcons/" .. actualRegion .. "-" .. realmData.language .. ".png"

		return countryFlag, realmData.language

	else
		return nil, "N/A"

	end
end

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