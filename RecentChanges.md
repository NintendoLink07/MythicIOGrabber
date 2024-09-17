## [2.5.8](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.8) - 2024-09-18

### Added

- [MainFrame] A tooltip has been added to the string beside the character panel at the top of the frame for clarification.

### Changed

- [PartyCheck] PartyCheck (with all the gear/keystone info) has been re-enabled and it's info will now only be updated when the frame is shown.

- [PartyCheck] The new sorting algorithm has been implemented, you can now sort for more than 2 things at once.
Keep in mind: the more the addon has to sort a raid group the more it has to compute.

- [M+ Statistics] "Turned off" the score increase calculation, waiting for tomorrow to see the actual formula for it.

### Fixed

- [PartyCheck] The character frames with their RaiderIO info expanded will not close on PartyCheck getting a group update anymore.

- [Lockouts] The lockouts will now be correctly refreshed when login in with a character and not just when opening the Lockouts frame.

- Logging in with a character will no longer cause a few lags at the beginning of loading into the world.