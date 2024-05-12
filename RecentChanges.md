## [2.0.1](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.1) - 2024-05-12

### Added

- The new inspect algorithm is implemented, new algorithm should no longer permanently scan the party/raid members and should be twice as fast (depending on other addons also trying to inspect players).
Currently saving spec data per group member for 5 minutes, then it will do a fresh rescan.

- Implemented queueing for multiple dungeons.

- Raid finder queue selection is now separated into each raid and has an Indicator which shows if it's currently awakened.

### Changed

- Updated the queue frame design.

- The currency frame is now in the bottomright corner.

- The dungeon lists in the queue selector are now alphabetically ordered.

### Fixed

- Some filters from Blizzard were applying to my own when they're not supposed to (e.g. dungeon rating being set when looking for a raid).

- Awakened raid statistics are now correctly tracked. They were previously superceded by the higher difficulty (e.g. previoulsy if you had 7 kills on normal and 9 on heroic then the normal statistic would show 9/9)

- Deleted and fixed some old code for my custom dropdowns.

- Deleted some old libraries.

### Known issues

- Specific queues (such as battleground queues) have no background in the "Active queues" panel.
I'll probably put in some placeholders except for the special ones.

- Just like before, sometimes the inspect function doesn't behave correctly / takes too long to get an answer from Blizzard.
Just right click and inspect someone from your party and it should resolve itself.
Workaround is already in development.