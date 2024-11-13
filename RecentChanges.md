## [3.0.5](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.5) - 2024-11-13

### Fixed

- [SearchPanel] Checks for both class and spec data are now more tight since for some reason there might be some data missing in the first few calls to retrieve data.

- [PartyCheck] There will now be a check if the keystone data contains a character name (usually should but on very rare occassions it doesn't).

- [ReQueue] When logging into a different character the saved groups will now get wiped.

- [PartyCheck] Switching to the PartyCheck tab will now always refresh the class bar at the top of the frame.