## [3.5.4](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.5.4) - 2025-07-12

### Added

- [Ports] TWW Raid teleportation spells have been added to the Ports tab.

- [Ports] Short names for all spells have been added.

### Changed

- [Ports] All dungeons are now sorted by their short name, raids are sorted by their spell id (to mimic the patches when they've been added).

- [Gearing] Gearing data for season 3 has been implemented.

- [Gearing] The fallback season id for gearing data will always be the last season (only applicable between seasons).

- [ApplicationViewer] CTRL+C automatically closes the copybox after copying.

- [ApplicationViewer] Only right clicking the name of the applicant will show the url copybox instead of right clicking in all of the reserved space for the name.

- The "Journal" tab has been renamed to "Drops" to more accurately describe the tab.

- The settings button has been updated with new art.

### Fixed

- [SearchPanel] Group listing's right side background texture should be correctly displayed.

- [SearchPanel] Group listing's backgrounds will now reset back to their original color.

- [ApplicationViewer] Hovering over an applicants name will not hide the tooltip anymore.

- Vault progress bar icons will now correctly be de-/saturated upon unlocking a new vault slot.

- Cleaned up some old code that ran in the background, minor performance increase regarding the addon load times.