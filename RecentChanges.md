## [3.2.9](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.9) - 2025-03-26

### Added

- [Progress] Solo Arena and Solo BG have been added to the PVP progress panel.

- [GroupManager] Leader, main assist, assist and main tank icons are now shown in the standard group list on the left side of the ready check status.

### Changed

- [Gearing] The gearing table has been updated, individual columns can now be enabled/disabled.
Cells now have a background that distinguishes them more from the background.
Gearing item level data has been corrected and bountiful delves and enchanted weathered crests have been added to the table.
Gearing data item level calculation has been improved and simplified for upcoming season data.

- [ClassPanel] The class panel has been slightly redesigned.
Classes that aren't in your group have their icon reduced in size.
The number font size in the class and the spec frames has been increased.

- [Progress] The tier icon that indicates the next tier for the character is now only being shown if the character has atleast a single rating point.

### Fixed

- [Progress] The spec icon of characters on the overview page now gets correctly updated when switching specs.

- [GroupManager] There should be no more system messages when players join or leave the group and a atleast one player in your group is offline.

- An issue has been resolved trying to request bnet account info before the data was loaded.

- A error message is shown when you try to requeue for any PVP queue (since Blizzard doesn't allow queueing up for those queues with just 1 click and without their PVP dropdown frames).

- The event category in the queue dropdown now gets hidden if there are no active event queue available.

### Upcoming

- [Progress] PVP conquest progress bars added to the overview characters.

- [Progress] Hiding specific activities