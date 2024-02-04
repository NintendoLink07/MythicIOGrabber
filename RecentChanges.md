## [1.7.3](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7.3) - 2024-02-04

### Added

- A loading spinner and a status frame when no groups have been found has been added.

- If you have been soft declined (timeout, delisted, group full) or hard declined (actual decline) the title and zone/difficulty text of the search result will be colored orange or red.
This will be saved between /reloads or logouts.

- If you've favoured a player before their group listing will now also show up further up in the list!

### Changed

- I've noticed that the bottom few results (around 15-30) are always unsorted, because there is some data missing which Blizzard sents later than intended.
I can't really do anything about that.
I have added 0.3s delay, which usually covers all the data that gets sent later.
You can turn this delay off in the interface options but I do advise against it.
Otherwise you will have to press "Search" and press "Search" again when all the groups are visible, this should also cover the delay but isn't as elegant as my built-in solution.

- The difficulty dropdown has been changed.
Dungeons go from M+ all the way down to Normal, Raids go from Mythic to Normal and for Arena you can choose to filter out 2's or 3's.
In all other categories the dropdown is not visible (unless I find some use for it there).

### Fixed

- New installs of this addon or fresh starts (after a PC restart or full exit of WoW) don't have to press the search button of each category twice for results to show up.

- The "old settings deleter" has been fixed, now only old settings which aren't user-definable will be deleted (e.g. no more favoured applicants, etc.)

- Information in the raid tab should now always be shown correctly.

- PVP sorting by rating should now be working correctly.

- PVP score filtering should now also be working correctly, was using dungeon score before.

- Adjusted the sort buttons' position in the search panel.

- Improved performance overall and especially when you refresh the search list.

- Corrected boss frame desaturation (in Amirdrassil the encounter journal doesn't go by wings, e.g. Volco -> Larodar. Instead the index goes Volco -> Council -> Larodar -> Nymue. Lol why).

- Party fit, bloodlust fit and battle ress fit will now apply correctly if you're in a category where there technically are no real limits (BG's, custom groups).

- Various errors have been fixed.