## [2.1.3](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.3) - 2024-06-13

### Added

- [Party Check] Missing enchants and missing gems are now included in the tooltip.

### Changed

- The category selection buttons and the journal button are now located in the title bar, more like in a traditional window.

- Changed all fonts to Blizzard base fonts, since I don't need my own specific font anymore.
This means korean, simplified and traditional chinese and russian characters should now be rendered correctly.

- [Search Panel] All listings will now have their respective activity as a background.

- [Adventure Journal] When you enter a raid the default instance selecting will be the one you're currently in.

### Fixed

- Added an anchor point for the base frame of the search panel, application viewer, entry creation and dungeon journal.

- [Application Viewer] The "ress fit" and "lust fit" options will now consider the players class and spec.

- [Search Panel] Failed applications, e.g. when you have already 5 applications running, will not lead to a "delisted" state anymore.

- [Active Queues] After a /reload and clicking on an active lfg application should now correctly load the search panel.

- [Party Check] The score of your party/raid members will now show their score, not yours.

- Multiple code logic errors fixed.