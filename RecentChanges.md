## [3.0.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.0) - 2024-11-03

### Added

- The new [ReQueue] feature has been added!
You can now "apply" to more than 5 groups at a time!

How this works:

When you are at the maximum of 5 applications the addon saves data from the group you've tried to apply to.
Then when one of the 5 groups declines you / gets delisted a popup will show up asking you to refresh the search panel.
Then the addon asks you if you wanna apply to the next group.

The refresh is only required if you applied to a group since the last refresh, so if you apply to 10 groups and then you just play the game after the first refresh you won't have to refresh anymore.
While I would like for this to be simpler I have to go through some hoops to get this to work.
These groups will be saved between /reloads or quick relogs.

There are three new settings in the interface options for this feature:
1. "Apply popups", by default enabled. This setting let's you enable/disable the feature.
2. "Clear fake apps", by default disabled. When an "queued application" has been blocked by a filter it gets cleared automatically since it's not a real lfg application and doesn't break anything on Blizzard's side.
3. "Flash client icon", by default disabled. If you are tabbed out of the game but still want a reminder to queue for the next group you can enable this feature.

Enjoy.

### Fixed

- [RaidSheets] There will be no error anymore trying to access player frames when no frames have been created yet.