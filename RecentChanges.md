## [3.1](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.1) - 2025-01-22

### Added

- The "Party" tab in the mainframe has been redesigned and the new group manager has been implemented!
You can switch between these views in the topright corner in the "Party" tab.
The standard view is similar to the old one but the new features are:
    - A refresh button has been added near the topright corner to try to refresh and add missing data for players.
    - Character players have a "Ready" box at the end of the line, indicating if they confirmed the ready check or not.
    - In the topright corner a "Ready status" box has been implemented showing if the whole party/raid is ready.

- The new view integrates the raid manager from the social menu ('O' key shortcut).
    - [This feature will be implemented with 3.1.1] You can click on a party/raid member and view detailed infos about their character, M+ and raid related.
    
### Changed

- The [PartyCheck] tab has been renamed to [GroupManager].

### Fixed

- [SearchPanel] The autocomplete frame will now be in the toplayer of the frame so it doesn't get hidden by the "No groups found" overlay anymore.

- [GroupManager] Multiple tooltip layout errors have been fixed.

- Multiple performance issues have been fixed regarding party / raid member updates.
There should be SIGNIFICANTLY less random framedrops when data of players is being requested.

- Updated the OpenRaid library and deleted some old files.