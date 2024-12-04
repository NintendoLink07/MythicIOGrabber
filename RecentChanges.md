## [3.0.8](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.8) - 2024-12-04

### Added

- [Group creation] The name of the current selected category has been added to the top of the group creation frame.

### Changed

- [Group creation] The dropdowns have been changed to Blizzard's new dropdowns.
Relevant code changes in the background have improved memory management (unless you spam click the dropdowns 5 times a second, then it's worse)

### Fixed

- [Group creation] Amirdrassil should now have the correct background image.

- [MainFrame] An error that happens when an update for WoW has been installed and the client has no cached data yet has been resolved partially.
Will take till the next update for it to be fully resolved (currently rewriting that code for better performance and logic).