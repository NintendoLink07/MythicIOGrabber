# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]


## [1.1.0] - 2023-10-17


### Fixed

- Minor code changes, more a version push since I forgot that I uploaded a 10.2.0 version 2 weeks ago and nobody got any updates of this addon, LOL
- Kinda fixed the "keep creation info" function, still experimental though



## [1.0.9] - 2023-10-17


### Added

- The info panel background will not be generic anymore for anything DF S2 and onwards
All DF raids and S2/S3 dungeons will have their respective loading screen (cropped and upscaled, if needed) shown as the info panel background

### Fixed

- Fixed activity title layer, font should be way brighter now



## [1.0.8] - 2023-10-17

Yes, the weird errors currently popping up with this (and many other) addons are not my fault
More infos: https://github.com/Stanzilla/WoWUIBugs/issues/483


### Added

- Both PVP rating sorting and raid progress sorting is now implemented!
PVP rating functions basically the same like M+ rating.
Raid progress compares first the difficulty of the applicant leaders: Mythic > Heroic > Normal.
If they're the same difficulty it compares the progress itself.
- Interface option added to hide the background image and some background colors (mainly for ElvUI users or players with semi-transparent interface frames).
- Added performance test slash commands, generally just for internal use (not recommend for any normal person).
- The linkbox you can call with right click on the applicant name is now positioned directly over the applicants frame.
- Other languages' (russian, korean, etc.) server names are now supported for the linkbox .
- More color coding for raid progress. In addition to Mythic, Heroic and Normal there are now Last tier and No tier.
- Right click on the sort buttons now resets them to their off state

### Fixed

- Listing of group members in the title bar is now fixed, forgot to change the cap of party members back to 5
- New logic for displaying the raid data, should be much more acurate now.
- Clicking the settings wheel should now open the actual settings
- Multiple layering issues fixed


### Changed

- Improved the logic and code flow, which leads to increased performance
Before (more prominent on slower computer) you'd get a longer freeze after a reload when you had a big applicant list, time to compute the list was cut down by approximately 50-55%.



## [1.0.0 / 1.0.0a] - 2023-10-13

### Added

- Interface options setting: (Experimental) Your message when applying to groups will be saved between multiple applications (but not between reloads, atleast for now).

- Interface options setting: (Experimental) Your settings when forming a group will be saved between reloads (but not between reloads, atleast for now).

- When having fewer than 5 players in your party the specs of your party members will be visible in the title bar.
Will probably do a raid version with an expandable small window or something like that but it's somewhat limited by 1. size constraints and 2. Blizzard only doing 6 inspect requests at a time.
This feature might still be a bit wonky, it's the next item to completely finish over the next two weeks, mostly edges cases though.

- Implemented Dragonflight Season 3 dungeons in advance.

- Implemented Dragonflight The Emerald Dreamway raid in advance.

- New sorting methods: you can sort by role, score, keylevel or ilvl. 
Up to 2 sorting methods can be active at a time, e.g. you sort first by role (indicated by the little number on the bottom left side of the button when you click it) and then for score.

- Many tooltips explaining the new features.

- When you set a rating / ilvl limit and an applicant has a premade that is under the rating threshold the rating / ilvl of that applicant will be colored red for easier visibility.

- Clicking on the dungeon / raid / -boss icon in the detailed panel now takes you to the Encounter Journal page for that dungeon / raid with the currently chosen difficulty (Normal, oldschool 25 HC, M+, etc.)
Not sure if I got all edge cases (probably not). Just shoot me a message somewhere if you find one.


### Changed

- Full UI rewrite, updated to more modern WoW UI code standards.

- Saves settings now properly and doesn't refresh user set options when Addon is updated.

- Updated all the icons for a more modern look.

- AI upscaled all the background images, now there's also a different one for each category(dungeon, raid/raid legacy, arena, arena skirmish, etc.).

- Instead of a wall of text of your group creation setting it now shows icons for each category.

- Instead of 2 seperate detailed panels for M+ and raid both are now a tab button in the detailed window! Standard is M+ in Dungeon category, Raid in raid category and every other category will have M+ as standard.


### Fixed

- Many many UI bugs, shifting text/icons, buttons not visible/clickable, text cut off, etc.


### Removed

- Made the "Show actual specs" and "Order group" options unavailable, since they were resource hogging a lot since Blizzard only renders the groups that are currently visible. So the addon would have to update the specs EACH SCROLL / GROUP UPDATE.
From my testing: going from 300fps to 180fps when you refresh or scroll. Currently not worth it and definitely not what I intended.



## [0.9.3b] - 2023-10-04

### Fixed

- Re-enabled status string (was a bit wonky before)


## [0.9.3] - 2023-10-03

### Added 

- Shows now the number of tanks/heals/dps in group in the title bar (kinda forgot about that)
- When you hide any role it will now show how many applicants are hidden


## [0.9.1] - 2023-10-03

### Added

- Implemented a more functional save function, still needs more work though for edge cases.

### Changed

- Frame can't be hidden by escape key anymore (was just a testing functionality actually)


## [0.8.9b] - 2023-10-01

### Fixed

- Tooltip now always visible (was sometimes not visible on the first few applicants)
- Affixes should always be loaded after login (Blizzard has no real "Get me all the current affixes right now" function, you gotta request and wait and stuff)
- Just general UI stuff, mostly correct layering of stuff


## [0.8.8b] - 2023-10-01

### Changed

- Re-enabled the status string (cancelled, timeout, invite declined, etc.)


## [0.8.8] - 2023-10-01

### Added

- Auto sort function is not a Interface panel option anymore.
Now it's a button besides the "Show Tanks" button.
When it's active it sorts applicants either after you press the refresh button in the title bar or you decline someone.

### Fixed

- Where the fuck are all these UI bugs coming from, patch 1 and 2 appear out of nowhere.
Gonna rewrite my UI code in the next few days, it's always a bit wonky when you have to code around Blizzard UI stuff
- Logic improvements, at some point you couldn't even decline applicants anymore (LOL)


## [0.8.4] - 2023-09-30

### Fixed

- Minor bugs


## [0.8.3] - 2023-09-30

### Added

- Raid data (with the RaiderIO addon installed) now visible: current and previous tier data, RaiderIO has more data about the current tier, so the last tier data is somewhat lacking.
- PVP data is implemented but since RaiderIO has (obviously) no real PVP data I have to pull the small amount of data available from Blizzard directly.
Basically just the rating for the bracket and the tier they're currently in
- Huge logic improvements (if you've experienced slowdowns for 1-2 seconds after you've done a /reload they should be gone now)

### Fixed

- Minor UI bugfixes, so stuff will be bouncing around less


## [0.7.5] - 2023-09-29

### Added

- Addon now remembers who you viewed in detail. Auto expands the person on the next refresh

### Fixed

- Code readability updates / simplifying
- Don't remember the other stuff, it's more gooder now


## [0.7.4] - 2023-09-29

### Fixed

- Finally fixed the textline issue, for good this time (hopefully)
- Logic improvements


## [0.7.3b] - 2023-09-29

### Fixed

- Everything seemed 3-chested


## [0.7.3] - 2023-09-29

### Fixed

- Textlines were jumping all over the place, corrected
- Minor logic improvements, still lots to do though


## [0.7.2] - 2023-09-29

### Fixed

- Code cleanup
- Minor bugfixes


## [0.7.1] - 2023-09-27

### Added

- Public release

### Fixed

- Performance and logic improvements


## [0.6.6] - 2023-09-27

### Added

- Intended release, way too buggy so I took it down, now it rests in peace

## [0.6.0] - 2023-09-25
## [0.5.5] - 2023-09-23
## [0.5.3] - 2023-08-22
## [0.5.0] - 2023-09-22
## [0.4.5] - 2023-09-21
## [0.4.2] - 2023-09-21
## [0.4.0] - 2023-08-18
## [0.3.9] - 2023-09-16
## [0.3.5] - 2023-09-16
## [0.3.4] - 2023-09-10
## [0.3.0] - 2023-08-09
## [0.2.7] - 2023-09-07
## [0.2.4b] - 2023-09-05
## [0.2.4] - 2023-09-04
## [0.2.3] - 2023-09-03
## [0.2.1] - 2023-08-31
## [0.2.0] - 2023-08-31
## [0.1.7] - 2023-08-31
## [0.1.6] - 2023-08-30
## [0.1.5] - 2023-08-27
## [0.1.3] - 2023-08-27
## [0.1.0] - 2023-08-25
## [0.0.9] - 2023-08-25
## [0.0.7] - 2023-08-25
## [0.0.4] - 2023-08-24
## [0.0.1] - 2023-08-24

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->
[unreleased]: https://github.com/NintendoLink07/MythicIOGrabber/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.1.0
[1.0.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.0.9
[1.0.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.0.8
[1.0.0a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.0.0a
[0.9.3b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.9.3b
[0.9.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.9.3
[0.9.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.9.1
[0.8.9b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.9b
[0.8.8b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.8b
[0.8.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.8
[0.8.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.4
[0.8.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.3
[0.7.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.5
[0.7.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.4
[0.7.3b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.3b
[0.7.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.3
[0.7.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.2
[0.7.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.1