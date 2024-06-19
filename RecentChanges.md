## [2.1.5](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.5) - 2024-06-19

### Added

- [Filter Panel] Age filtering has been implemented.
You can set a minimum amount and/or a maximum amount (both in minutes).

### Changed

- Blizzards dungeon filter option "Needs my class" now works correctly, if you're logged into your hunter, you deselect hunters in the filter panel and then log into your warlock, instead of the hunter filters being deselected, the warlock ones will be deselected.

- Updated the Open Raid Library, which is needed for keystone, gear and enchants info (Doesn't update the TOC version of the addon, so it's stuck in 9.2.5 and doesn't get automatically served to players who use the library).

### Fixed

- [Active Queues] Listings in the active queues panel will not switch between 0:00:00 and the actual listing / application time.

- [Filter Panel] Blizzard's lfg filters minimum rating won't turn on MIOG's rating filter anymore, it will only apply the rating to the minimum rating field. 

- [Adventure Journal] Calling the adventure journal while in an open world space will not result in any errors.

- [Party Check] Resetting the sort buttons via right click will not cause any errors anymore.

- [Party Check] Progress from all awakened raids will now show up in the tooltip (previously it was only the top 2).

- [M+ Statistics] There will now be a check if the weekly affix (fort/tyr) has been requested already.

### Upcoming

- Going to create some kind of guild integration into the addon, I have no complete idea of what data to display or how it's gonna look.
It's more like a test of some sort, because I definitely want to create some sort of roster management system.