## [3.5.6](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.5.6) - 2025-07-31

### Added

- Currencies for the new season have been added. 

- [Drops] When selecting an instance multiple difficulties will be consolidated into a single expandable entry.

- [SearchPanel] Deserter icons added for the new "isLeaver" flag.
An icon gets added to the group name of the listing and onto each group member(spec) icon.

- [ApplicationViewer] Deserter icons have been added for all applicants.

### Changed

- [ApplicationViewer] The friend icon now shows up infront of the playername.

- [FilterManager] Data for the "Hide declines" filter will now be retrieved from Blizzard's own decline list implementation.

- [SearchPanel] Data for different decline checks will now be retrieved from Blizzard's own decline list implementation.

- [Drops] The slots and armor types filter now also work without selecting an instance.

- [Drops] More checks have been implemented to determine if the character is currently in an instance.

- [ReQueue] The groups are now saved with their id, which lets me sort them by time of application and therefore fill the popup with the group you've first applied to after the 5 apps limit.

- All functions that request map data have been modified to also take into account group info for mega-dungeons.

- Ecodome Al'dani and Manaforge Omega data has been correctly added.

### Fixed

- [Drops] The correct filter settings for equipment slot and class/spec will be applied inbetween /reloads or reloggs.

- [Drops] All items now get included in the extra checks "armor type" and "tokens / mounts / recipes".

- [FilterManager] Filters from other characters won't influence newly leveled characters anymore.

- [Progress] Fixed an error trying to show progress to characters under level 61.

- Fake applications can now also be aborted via the 'X' button in the active queues panel.

- The active queues panel will now remember it's scroll state when being refreshed.

- An error trying to measure the time of the teleport cds has been resolved.

### Known issues

- [Drops] When switching instances the extra items like tokens and recipes might not load correctly.