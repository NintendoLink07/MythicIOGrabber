## [1.7.2](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7.2) - 2024-01-31

### Added

- A proper throttle frame (when you search too often) has been implemented

- There are now boss frames when you are looking for a raid.
Encounters that are desaturated have already been defeated.

### Changed

- When you applied to a M+ group and you're currently in the raid panel (or any combination of panels tbh) the groups will now have their m+ score or progress data shown.

- Improved the search result frame system, which leads to almost no micro stutters occuring.
The only "downside" is that the used memory jumps to almost 80mb (equal to having all RaiderIO addon EU data loaded) when currently looking for members and browsing groups at the same time, with no filters active.
This will be improved during this and next week.

- Improved the handling of applications, delisting, etc. behind the scenes, made it less prone to error.

- Fixed some filter edge cases.

### Known issues

- When a category has not a single group listed (e.g. Rated BG's, Skirmishes) the throttle frame doesn't disappear (I currently only refresh the frames when atleast 1 result is available)