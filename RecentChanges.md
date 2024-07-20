## [2.3.1](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.1) - 2024-07-20

### Changed

- The new display method has been integrated for the guild panel.
Guild panel is loading much quicker, there is way less lag and when refreshes of the guild members come in there is basically no stuttering at all.

### Fixed

- [Guild Panel] When the detailed raider io panel is currently open and a guild member info update comes in the panels won't close themselves automatically.

- [Search Panel] The flag indicating the leader should be above the actual leader now (Blizzard changed the function for this, before it was always the first player).

- [Application Viewer] Time to iterate through 100 applicants reduced to around 0.03 seconds. Basically less lags when a ton of people apply.

- [Application Viewer] The raider io panel will now be reset correctly so no leftover information is hanging around.

- The position of the raider io panel below search panel frames, applicant frames, etc. has been corrected.

- Memory usage has been lowered by around 2-7 megabytes, depending on how big your guild is and how much raider io information they have.