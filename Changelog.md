# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

## [1.0.0] - 2023-10-??

### Changed

- Full UI rewrite, updated to more modern WoW UI standards


## [0.9.4] - 2023-10-04


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
[unreleased]: https://github.com/NintendoLink07/MythicIOGrabber/compare/v0.9.3b...HEAD
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