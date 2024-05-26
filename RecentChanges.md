## [2.0.8](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.8) - 2024-05-26

### Added

- Implemented a very basic version of the gearing chart.
It's more for me to test how code the algorithms and ideally have it automatically retrieve the item levels for each new raid tier so all the info you need is available day 1.
1. Ilvl, 2. Track, 3. Raid source, 4. Dungeon, 5. Dungeon vault source, 6. Other source, 7. progress (which ilvls you've reach in each category so R1 at 506 for the first raid vault slot at item level 506)

Still very rudimentary but it's "working" already so here ya go.

### Fixed

- [Options] The show/hide class panel option now actually work.

- [Filter Panel & Active Queues] When the boss kills change on a listing it will show the correct ineligbility reason.

- [Category Selection] When selecting the same category as before (e.g. first trying to search for a dungeon group then creating one yourself) shouldn't cause any more errors.