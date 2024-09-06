## [2.5.1](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.1) - 2024-09-06

### Added

- A new tab has appeared! [Lockouts] has been added.
Here you can see all the raid & dungeon lockouts of all of your alphabetically sorted characters.
Hovering over the entries shows a tooltip listing the time and date until the lockout expires and which encounters are alive / have been defeated.

### Changed

- Deleted quite a lot of code that I had to put in myself after every Blizzard DB update.
Means more frequent updates and less errors.
Also while not really measurable it shaved ~1 to 1.5 seconds off of the loading time when you first login.

### Fixed

- Characters that don't have any M+ data whatsoever shouldn't cause an error anymore when you look at them in the [ApplicationViewer], [SearchPanel], etc.

- Deleted some debug prints.