## [1.2.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.0) - 2023-11-06

### Added

- For the users who mainly raid: a class list on the left side of the main window.
Updates on every invited member (between members there's always atleast a 1.5 second delay, otherwise Blizzard hard throttles the inspect data requests).
Classes that are currently in the group are color saturated and have a number indicating how many of the class are already in the group.
Sorted by number of members of that class (e.g. 3 Warriors > 2 Rogues)
Hovering over the icon reveals which specs of those classes are in your group.

- Implemented Raider.IO previous season scores.
Depending on the data Raider.IO provides instead of just "Main Char" or "Main Score: XXXX" it will show:
This char's previous season's score (or nothing if the data's not available)
If it not the main char it will show the mains current score and the last season's score (again, nothing if the data's not available)

- Changed some visual stuff, added borders to some elements


### Changed

- Logic for requesting party/raid data improved
- Logic for inviting/declining applicants improved, except for a few edge cases (which I can't test on my own) it should be muuuch better and more reliable, will be tested more during Season 3
- Deleted some old background files to lower the addon size

### Fixed

- Fixed spec table for 10.2
- Fixed that some textures where keeping the hover / click events that were on them previously<br>