## [3.2.3](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.3) - 2025-03-07

- [Progress] The character frames in the Overview panel now have a new design to make it more WoW-like.

- Updated the Open Raid library.

### Fixed

- [SearchPanel] Switching between the raid categories and any other categories won't create lag anymore (at the cost of a bit more memory).

- [GroupManager] The raid manager is visible again.

- [GroupManager] Re-enabled checks for missing gems / enchants.

- [GroupManager] Fixed my name retrieval function so the ready checks should be properly recognized now.

- [DropChecker] Liberation of Undermine is now properly implemented and shouldn't cause an error anymore.

- [FilterPanel] The progress panel beneath the filter panel now gets hidden when opening the DropChecker.

### Known issues

- [SearchPanel] Sometimes the first boss "is defeated" data doesn't get sent by Blizzard / doesn't get recognized by MIOG.
This will be fixed in v3.2.4.