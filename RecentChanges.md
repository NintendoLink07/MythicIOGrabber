## [2.8.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.8.0) - 2024-10-12

### Added

- The interface options now have LFG statistics.
Wondering how many times you have been declined from groups? Now you can find out.
For now it's only the app status that gets captured or the filter reason if you manually cancel an application.
But to be honest I can capture basically anything, and I probably will just sneak in additions into most version updates.

- [SearchPanel] Right-clicking the search panel groups now opens a menu just like the normal search panel where you can whisper the leader, report the group, etc.

### Changed

- [Statistics] All statistic panels have now been updated to use the same code foundation to make bugfixing easier and to streamline the UI.

- [Statistics] All statistic panels now request data for each of your characters on your account that has atleast a single currency (note: money, e.g copper, silver, gold does not count for this restriction).
This works retroactively, you do not need to log into each of your characters (which you will probably do anyway but just saying).
Before warbands there was no known method (atleast known to me) to do this.

- [Statistics] The raid and the M+ panels will now update data for all characters except your currently logged in from RaiderIO if you haven't logged into them since the update of this addon.

- [Statistics] The first character in the list will always be the one you are currently logged in.
The following characters will be sorted by score for M+, progress for raid and rating for PVP.

- [Statistics-MythicPlus] The score calculation has now been updated!
Took 2 days to figure out the algorithm but now it should correctly calculate the new score.
Also the slider now goes from -40% to 40%, so you can see how much score you'd get if you got the key done even over time but still within 40% over time.

- [MainFrame] Changed the currency info if the currency has no seasonal maximum you could exceed (e.g. valorstones and catalyst charges have maximums but they're not seasonal maximums).
 
### Fixed

- The raider IO info panel will now correctly show keylevel bracket data, e.g. amount of keys done in 2-3, 4-6, 7-9, etc.
Though right now RaiderIO seems to have a bug that doesn't correctly transfer any keylevel bracket except the 4-6 bracket into the downloadable databases (what you update through CurseForge or the RaiderIO client).

- [FilterPanel] Clicking the checkbutton infront of the Difficulty dropdown will now activate the filter immediately instead of only after a new search.

- [FilterPanel] Re-implemented right-clicking the bossframes to reset them.

- [PartyCheck] The character tooltip now displays the keystone dungeon name aswell as the level.

- [PartyCheck] Split up some methods for the spec, keystone and progress detection, should lag less when new people join the group.

- [PartyCheck] Fixed the width of certain elements of a character frame, now it shouldn't cut off the text anymore.

- Cleaned up old files and code, should improve load times of the addon on lower end machines a bit (we're talking still sub-seconds of loadtime improvement though)