## [3.0.3](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.3) - 2024-11-06

### Fixed

- [ReQueue] Disabled an extra check for search results which kept deleting the saved groups in certain situations.

- [ReQueue] Added a code block that will always delete groups that can't be found anymore if you got the data inbetween you requesting the data and the group disappearing.

- [SearchPanel] Recoded some of the member count algorithm to fail-over to the class icon if for some reason Blizzard doesn't send spec data of the group listing when requesting it.