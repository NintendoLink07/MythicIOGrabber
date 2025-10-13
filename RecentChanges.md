## [3.7](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.7) - 2025-10-13

### Changed

- [GroupManager] Recoded / redesigned the group manager.
    - Online / offline / afk / dnd icons have been implemented.

    - After the addon tried to queue the spec id 5 times it blocks the character. This can be reset by pressing the refresh button.

    - The refresh button now hard forces an update of your group.

    - Inspect management (requesting spec id's) has been improved.

    - Base design has been adjusted to be similar to the [Progress] design.

- [Progress] The great vault icon now also shows when rewards have already been generated for a character but haven't been claimed yet.

### Fixed

- [SearchPanel] Hovering over a group listing won't cause an error anymore.

- Many performance fixes, larger lags when joining groups (especially > 15 man) should be much less frequent.

### Upcoming

- [ApplicationViewer] Complete re-design and re-code.