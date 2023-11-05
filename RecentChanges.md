## [1.2.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.0) - 2023-11-02

### Added

- For the users who mainly raid: there's now a class list on the left side of the main window.
Updates on every invited member (between members there's always atleast a 1.5 second delay, otherwise Blizzard hard throttles the inspect data requests).
Classes that are currently in the group are saturated and have a number indicating how many of the class are already in the group.
Hovering over the icon reveals which specs of those classes are in your group.
- Text indicator next to the class panel 
- Added square icons for the new class panel


### Changed

- Logic for requesting party/raid data improved, shouldn't be throttled anymore
- Logic for inviting/declining applicants improved, except for a few edge cases (which I can't test on my own) it should be muuuch better and more reliable


### Fixed

- Fixed spec table for 10.2 <br>