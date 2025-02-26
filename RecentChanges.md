## [3.2](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2) - 2025-02-26

### Added

[Progress] now has an overview panel.
There you'll see your 5 most played characters and their m+/raid stats listed.
The addon saves your weekly progress for m+/raid and you can view the progress via the graph in the bottom left.

Right now it's very barebones but I wanted to update the addon before 11.1 comes out (but I will hotfix everything quickly this week after the patch goes live).

If you sometimes swapped to this page to check your progress while being in the group finder (to check your keys done, boss killed on this char, etc.): a comprehensive list of your current progress will be listed below the filter settings.

### Changed

- [SearchPanel] The "no groups found" overlay now also triggers when your filters filter all available groups.

- [GroupManager] Updates now only occur when the manager is visible and it's performance has been increased by swapping to the new frame gen method.

- Many background changes have been made for upcoming features released before 11.1.

### Fixed

- [Progress] An error preventing RaiderIO progress data loading for first time users has been resolved.

- [Progress] Characters that haven't been logged in for a while will now also populate the dungeon level rows correctly.

- [Progress] Fixed a rare error where sometimes the raid progress data would not load up correctly (because I have to manually parse it since Blizzard doesn't provide ANY progress data for anything but your own char).

- [SearchPanel/ApplicationViewer] When switching to the "Last invites" panel and then /reload'ing or relogging the filter panel won't automatically be open upon opening the SearchPanel/ApplicationViewer.

### Known issues

- [SearchPanel] When opening the "Raid" category and then switching to the "Dungeon" category there is a small lag. This happens because data in the background gets loaded during this moment.
This will be fixed in v3.2.2.

- [GroupManager] The raid manager window does not show any player frames. This is currently disabled because of lags happening when new players join the group.
I have a rough idea how to fix it, this will be fixed in v3.2.2 or v3.2.3.

- [Gearing] The chart will be updated with season 2 data this week.