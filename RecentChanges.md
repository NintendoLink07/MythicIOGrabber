## [3.1.3](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.1.3) - 2025-02-05

### Changed

- [ApplicationViewer] The application viewer's frame system and much of its core code has been updated to the same one the search panel now uses.
There should be almost no lag even when hundreds of players would apply at the same time.
Before computing 100 applicants created > 1 second of lag, now it takes just around 0.1 to 0.2 seconds, barely noticable.

### Fixed

- [GroupManager] The spec icons of characters should now be updated when the data arrives.

- [SearchPanel & ApplicationViewer] RaiderIO data will now be correctly set, even if they have a corrupt comment, lol.

- [SearchPanel] The leader's best dungeon run level will now be shown again.

- [SearchPanel] The number of listings at the bottom of the search panel should now update correctly again.

- [ClassPanel] The class panel will now correctly work in lite mode.

- [Progress] The progress tab will not try to fetch data from the previous season anymore when a new season has started.

- [Progress] An error has been fixed that tried to update the weekly rewards when the progress tab hasn't loaded all activities yet.

- An error trying to fetch raid data right when the game gets started without any cached data available has been fixed.

- Multiple PTR errors have been fixed.

### Known issues

- [SearchPanel & ApplicationViewer] The sort buttons create some smaller lags when clicked on.
This comes from the fact that I use the new frame gen code with the old sorting code.
This will be fixed in v3.1.4 or v3.1.5.

- [GroupManager] The name of a character will sometimes get stuck even though MIOG already has the spec data.
This will be fixed in v3.1.4.