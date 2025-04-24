## [3.4.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.0) - 2025-04-24

### Added

- The new [Journal] has been implemented, accessible via the "Journal" tab at the bottomright of the mainframe.
    Here you can select an instance (boss and difficulty optional) and see all the loot that drops.
    - Similar to the normal Adventure Journal you can change slot and class, but in addition you can filter for mounts, recipes, tokens and for specific armor types.
    - You can also just search for items by name! The search is currently limited to current activities only (so everything in the current expansion), due to performance reasons.
    - 

- [Progress] The honor level and the honor level progress have been added to both the main [Progress] tab and the inner PvP frame.

### Changed

- Over the next few versions I'll switch some settings from account to character-specific.
The saved app dialog texts, last used queue and last group are now character-specific.

- [Progress] Whenever weekly progress data updates (after a key, logging into a character after the weekly reset) all data will get updated.

- [Lockouts] All lockout data is now integrated into the [Progress] tab.

### Fixed

- [Progress] The selection border of the currently selected keystone will disappear if you decide to hide a M+ dungeon.

- [Progress] The keystone score calculation should now show the correct score gains.

- [Progress] Current raid progress data in the overview panel won't be overwritten by old data anymore.

- [Progress] Performance fixed when opening the frame on a character for the first time in a WoW session.

- [UpgradeFinder] All items should now instantly load without having to re-click the slot icon.

- [LiteMode] Opening any category won't try to load the UpgradeFinder.

- [LiteMode] The class panel is now attached to the Dungeons & Raids frame.

- [MainFrame] Trying to open the queue dropdown in 11.1.5 won't result in an error message anymore.

### Known issues

- Group itemlevel, durability and enchant data doesn't not get transmitted between players.
This has been the case since 11.1.5.
A fix is in the works, probably coming with v3.4.2 or v3.4.3.