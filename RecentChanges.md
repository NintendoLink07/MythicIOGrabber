## [1.2.2](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.2) - 2023-11-09

### Fixed

- Changed the order when the affixes for the week are getting requested.
Otherwise there was a veeeery small chance that it would request them before the main addon was initialized, leading to an error.

- Deleted a debug print that I forgot.