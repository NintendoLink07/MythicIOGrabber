## [3.4.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.0) - 2025-04-24

### Added

- The new [Journal] has been implemented, accessible via the "Journal" tab at the bottomright of the mainframe.
    Here you can select an instance (boss and difficulty optional) and see all the loot that drops.
    - [IMPLEMENT BEFORE RELEASE] Similar to the normal Adventure Journal you can change slot and class, but in addition you can filter for mounts, recipes, tokens and for specific armor types.
    - [IMPLEMENT BEFORE RELEASE] You can also just search for items by name! The search is currently limited to current activities only (so everything in the current expansion), due to performance reasons.

- [Progress] The honor level and the honor level progress have been added to both the main [Progress] tab and the inner PvP frame.

### Changed

- Over the next few versions I'll switch some settings from account to character-specific.
The saved app dialog texts, last used queue and last group are now character-specific.

### Fixed

- [Progress] The selection border of the currently selected keystone will disappear if you decide to hide a M+ dungeon.

- [Progress] The keystone score calculation should now show the correct score gains.

- [Progress] Current raid progres data in the overview panel won't be overwritten by old data anymore.

- [UpgradeFinder] All items should now instantly load without having to re-click the slot icon.

- [LiteMode] Opening any category won't try to load the UpgradeFinder.

- [LiteMode] The class panel is now attached to the Dungeons & Raids frame.