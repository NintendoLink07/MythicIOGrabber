## [2.1](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1) - 2024-06-05

### Added

- The new adventure journal has been added to MIOG!
While still in "Beta", it's already quite usable.
You can choose a raid/dungeon and see in a condensed way the damage / healing done of enemies.
Right now it scans the adventure journal and through an algorithm it detects the differences between the difficulties (e.g. ability on normal does 5k, heroic 10k, mythic 50k).
For dungeons there is an additional dropdown where you can set the keylevel and see the damage of the M+ value change.
So if you wanna see how much HPS you need for 3rd boss HOI you can just go to Khajin, set the keylevel and see how high the dps of her is.

Items in the loot frame are separated by slot. Mounts and special items are usually at the bottom.

Currently there is still some stuttering, because the loot info comes in asynchronous and since I want to display all difficulty-separated items at the same time there is a bit of lag when changing the raid/dungeon.


### Changed

- Since Blizzard decided to keep rotating the awakened raids I changed my logic so everything in the future (if there ever will be awakened raids again) should check correctly for "awakened" raids.
Also changed the icon in the main tab to the official awakened icon.

### Known issues

- [Adventure Journal] There is some lag when switching the dungeon/raid.

- [Adventure Journal] Items from older raids / difficulties are not correctly applied to the frame template (fixed in 2.1.1)

- [Adventure Journal] When switching the dungeon/raid sometimes loot data is not correctly processed (usually older raids).