## [1.3](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.3) - 2023-12-08

### Known issues

- A premade group of 2 or more members / sometimes even single applicants won't send correct spec data to the game client.<br>
Instead of a spec icon it will show a question mark for those groups.<br>
Seems to be a Blizzard bug, unless I find a workaround we have to wait for Blizzard to fix it.<br>
I did report it ingame and on the [official/non-official](https://github.com/Stanzilla/WoWUIBugs/issues/502) github issues page, so now we wait.

### Added

- On the left side of the refresh button there's now a number indicating how many applicants you currently have.

### Changed

- M+ dungeons are now always sorted alphabetically

- Many code changes because I noticed when you have 30-40 or more applicants it gets reaaaaaally laggy when a new person applies or you refresh the app list.
It's atleast as fast as before (if all applicants are new) or gets faster down to 0.02 ms (if all applicants are the same as before).

- Standard encounter journal ID is now set to Amirdrassil.

- Performance optimizations, e.g. if you refresh the list it won't compute an applicant that is still there, since the information is already available.
I'm releasing unused frames of old applicant way earlier now so even the memory required for the addon will shrink quite a bit.
Since the addon has a lot of information visible even when the applicant frame is not expanded it can actually rival RaiderIO in terms of ram required lol (~120-200mb).

### Fixed

- Mistweaver and Windwalker monk are now 100% correctly detected, I swear.