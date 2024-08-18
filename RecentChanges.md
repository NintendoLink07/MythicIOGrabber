## [2.4.4](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.4) - 2024-08-18

### Added

- A new background option with a TWW background has been implemented.

### Changed

- Backend changes, switched to Blizzard Settings API.
Means less errors when implementing a new filter method, new interface option, etc.
Unfortunately to not fuck up anything settings wise I have to wipe all settings this time.
Unless Blizzard changes something this will be the last settings wipe.

- Switch back to the old display method for the search panel.
While really helpful for the guild frame for example the Blizzard way of handling large amounts of data is just not up to par.
With Blizzard's DataProviders the fps drops down into the 30s with my 7800X3D, with my method it's atleast in the mid 50's.

### Fixed

- Depending on the use case around ~5mb of memory are used less because of some XML reductions which scale with the applicant/search panel/guild frames.

- [Search Panel] The individual group frames shown will now only refresh with their data and not be overwritten by any other group.

- [MainFrame] The background frame should now also be visible in lite mode.

### Upcoming

- Bigger refactoring of code/algorithms, streamlining it more so future updates can be implemented faster.

- A raid sheet feature will be implemented, so you can plan your raid comps without going outside of the game.