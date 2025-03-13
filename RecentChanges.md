## [3.2.6](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.6) - 2025-03-13

### Added

- [Progress] An icon in the center and status bars have been added to each character to see their current vault status.

- [Lockouts] A checkmark icon now shows up when you've fully cleared a dungeon/instance.

### Changed

- Switched out the main font I used for one that's easier on the eyes.

- [GroupManager] The raid manager's groups have been separated more to directly see where the individual groups start and end.

- [Progress] The graph has been disabled for now while I deal with some Blizzard season problems.

### Fixed

- When queueing for multiple dungeons from the queue dropdown the tooltip will now show all dungeons you queued for instead of the one it got the most recent info.

- [GroupManager] More improvements to the inspection algorithm.

- [GroupManager] Players won't be stuck with an incorrect unitID anymore, now their tooltip gets updated correctly.

- [GroupManager] Players' keystone data won't randomly disappear anymore.

- [Progress] The lags that occured when first opening the [Progress] tab has been eliminated.

- [ApplicationViewer] The title of the group listing is no longer clipping into the group composition text.

- [ApplicationViewer] Players with multi chested keys won't cause a LUA error anymore when hovering over them.

- [GroupCreation] Multiple errors have been resolved when trying to queue with a character that is too low level to use premade groups.

- An error has been resolved if the RaiderIO addon isn't active.