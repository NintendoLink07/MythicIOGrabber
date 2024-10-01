## [2.7.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.7.0) - 2024-10-01

### Added

- If a group does not match your set filters anymore (all dps slots full, tank left and your filter is set to atleast 1 tank, etc.) there will now be a popup where you can cancel the app immediately and switch to the search panel.
There are still some issues with this and the visuals aren't fully fleshed out yet.
For now it is an optional toggle in the settings menu.

- [SearchPanel] Delves now have an icon.

- [SearchPanel] Specific quests and world quests now have an icon.

### Changed

- [FilterPanel] Recoded the entire filter panel to make it easier to implement new filters / change something about current filters.
Also squished alot of bugs where the logic was too convoluted to understand where I went wrong.

- [FilterPanel] All filter options now have a tooltip to explain what the option does.

- [FilterPanel] Boss frames' size in the raid category have been increased to better see what boss setting you are changing.

- [FilterPanel] MIOG's filter now correctly pass over to the Blizzard dungeon filters.

- [ApplicationViewer] Switched over to the new sorting algorithm. Enjoy faster sorting and more than 2 sort methods at once.


### Fixed

- [ClassPanel] Lowered the frame strata so the Blizzard tooltips are visible.

- [SearchPanel] Selecting a different group will now "deselect" the group you've selected before (just a visual change).

- Created a workaround for a bug in Blizzards Search Panel where sometimes the search result list doesn't get populated correctly when you do a /reload and right after the loading screen the search panel tries to update itself.

- Decreased the memory and cpu requirement that comes with computing all group info you get when using the search panel and any active filter.

- The queue selector dropdown will now also show category types that only have a single entry, e.g. only 1 event currently active.


### Known issues

- [M+ Statistics] The keystone dropdown doesn't correctly refresh with party data. This will be fixed in 2.7.1 or 2.7.2.