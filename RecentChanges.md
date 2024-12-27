## [3.0.12](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.12) - 2024-12-27

### Changed

- [MainFrame] Transitioned the queue dropdown to Blizzard's new menus.

- [MainFrame] The requeue button and the cancel buttons on the queue frames have been updated.

- [FilterPanel] When a class/spec filter has been changed the class row will now have a white border to make it visually clear that a filter is active.

- [AdventureJournal] The journal has been disabled temporarily.
The base idea is good, showing you the difference between all difficulties without switching between them and having a M+ keylevel scalar integrated but it currently only works when the text is 100% the same except the number.
This feature will be re-enabled in v3.1.0.

### Fixed

- [ApplicationViewer] M+ applicant entries will now show the correct completed keylevel for your listed dungeon again.

- [FilterPanel] An error regarding spec filtering has been resolved.

- [MainFrame] The activity icons in the queue dropdown will now always be correctly set to the actual file ID.

- [GroupCreation] The dropdown text will not reset to "Classic" anymore when you have already selected an activity.

- [GroupCreation] Dragonflight raids's difficulty can now be changed without having to create a group and edit it right after.

- The addon will now check for less data in the loading process, resulting in a faster loading screen.
Probably only really noticable on slower machines.
