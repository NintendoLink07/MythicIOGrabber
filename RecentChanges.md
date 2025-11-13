## [3.7.1](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.7.1) - 2025-11-14

### Added

- A "Midnight" background option has been added to the background options in the settings panel.

### Changed

- The inspection algorithm now also works perfectly when no other party member has MIOG or Details installed.

- [ClassPanel] The class panel at the top of the addon frame has been updated:
    - A smooth progress bar has been added that shows when the next full group update is coming in (to reduce lag even further).
    - Hovering over a class icon reveals the number of specs in your group.

- [GroupManager] Standard sort algorithm is now by group index.

### Fixed

- [GroupManager] Character frames in the raid view can now be moved around.
    A very slight delay (usually 0.3s but up to 2s) with locked frames will occur until the swap is made on Blizzard's side.
    If the locked frames for some reason don't unlock you can press the "Refresh" button to manually unlock them.
    In version 3.8 a more sophisticated method of moving players around is getting implemented.

- [GroupManager] Players now will be retried for inspection if they're under 5 retries.

- [GroupManager] The character name color is now set to white so it's easier to read.

- [GroupManager] Player spec inspection has been rewritten and it's performance and reliability has been improved.

- [GroupManager] An error has been resolved not updating the player count data when there is no change of the # of player characters in your group.

- [Progress] The amount of completed great vault activities won't exceed the highest threshold anymore.

- Various fixes to improve "loading" times and general performance in groups.

- An error trying to fetch the realm name while in a loading screen has been resolved.