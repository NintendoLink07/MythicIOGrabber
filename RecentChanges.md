## [3.2.8](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.8) - 2025-03-19

### Added

- [SearchPanel] A small (togglable) panel has been added on the right side of the application box that pops up when you signup to a group.
There you can set different signup text and manually copy them into the box.

### Fixed

- [SearchPanel] Upon switching search panel categories (e.g. dungeons to raid, raid to questing, etc.) the text field will now get wiped.

- [SearchPanel] The search panel won't try to iterate through the boss frames in any other category other than raid.

- [GroupManager] Gear data from players will now update correctly.

- [Progress] The keystone time calculator algorithm has been adjusted / corrected.

- All elements that are sortable will now correctly transfer their state into the MIOG settings (was previously not the case when > 2 options were active and you disabled one of them).