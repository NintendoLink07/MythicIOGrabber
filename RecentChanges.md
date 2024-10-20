## [2.9.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.0) - 2024-10-20

### Added

- [RaidSheets] have been added!
You can now plan your raid comp right ingame.
Drag and drop players from your guild into the slots and hover over them to "give" them a spec (and a role by that extension).
Right-click the character frames or drag them out of the spot and drop them anywhere that's not a raidspot and they get reset.

You can create as many presets as you want and the settings get saved everytime you make a change.
They are saved for the whole account but only loaded if you're in the guild where you have created the preset.
This way you can't overwrite data but still have access to it without WoW needing to copy all the data around to every single char you have.

You can search for specific guildmates in the topleft corner.


### Changed

- [SearchPanel] Implemented the new sorting method that was already active for [PartyCheck] and [ApplicationViewer]

- [Lockouts] This frame has moved to the "More" dropdown menu in the title bar.

### Fixed

- [ApplicationViewer] Fixed the width of the name of applicants so the friends icon will not be under the accept button anymore.

- [M+ Statistics] Overtime keys that have a higher score than your intime key score will now correctly show up instead of the intime key.

- [Raid Statistics] The number of bosses in the instance should now be shown on characters with valid raider io data.

- [Options] The lfg statistics are now alphabetically ordered and have now subtypes (e.g. "Applied" and "Delisted" refer to the SearchPanel while "Keys aborted" refers to M+ keys)
This will make it way easier to sort and sub-categorize them later on.