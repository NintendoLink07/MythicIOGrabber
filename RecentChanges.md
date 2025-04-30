## [3.4.2](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.2) - 2025-04-30

### Changed

- All upscaled images are now integrated into a separate addon because the addon grows rapidly in size (atm its around 80mb while most addons are in the 1-5mb range).
[MythicIO - Resources](https://www.curseforge.com/wow/addons/mythicio-resources)
This decreased the main addon's filesize by 35mb.

- All background image options for the main frame have been resized.
This reduced the addon's filesize by another 18mb.

### Fixed

- [Journal] The journal won't get stuck in an instance anymore by manually updating the selected instance of Blizzard's adventure journal.

- [Journal] You can now change the difficulty when you don't have an instance selected.

- [GroupManager] The itemlevel gets now rounded down and gets displayed without any decimals to preserve the UI spacing.

- [Progress] The honor level now gets updated correctly (was using UnitLevel instead of UnitHonorLevel, lol).

- [Progress] A scrollbar has been implemented for the main view to see more than 5 characters at a time.

- [Progress] Lockouts should now correctly get updated once you log in with a character.

- [SearchPanel] A rare error has been resolved where a dungeon listing's first boss data would stick around when you switched to the raid category and block all the raid listing's first boss data from being applied.

- All raider io dungeon panels (like the progress panels, group manager inspection panel, etc.) are now sorted by the dungeon's abbreviation.

- Load up data collection now correctly recognizes if an instance is a raid or not (important for many different parts of the addon).

- Open Raid library updated.