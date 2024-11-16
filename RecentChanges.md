## [3.0.6](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.6) - 2024-11-16

### Changed

- [SearchPanel] There won't be a loading spinner / delay before all search results have been updated with the correct data.
It will now update every group .5 seconds after the first groups have shown up.
Blizzard sends search result data usually twice (except for rated BG's), the first one includes most of the data, the second one usually all of the data.

### Fixed

- [SearchPanel] Improved performance.

- [SearchPanel & ApplicationViewer] The footer bar number that shows applicants/search results should now update correctly and not show applicants in the search panel or vice versa.

- [SearchPanel] The "Enter a key range" help tooltip will not show up anymore.

- [FilterPanel] The reset button will now correctly reset the current category (e.g. dungeon, legacy raid, rated bg's).

- [Statistics] Great vault tracking should now also work if you're exactly at the threshold of the slot, e.g. you've done exactly 1 Dungeon or 2 delves or 4 bosses, etc.

- Improved addon load time (leads to a shorter loading screen when logging in).