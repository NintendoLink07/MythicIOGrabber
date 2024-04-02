## [2.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0) - 2024-04-04

2.0 is here!
Took me longer than I wanted but it was worth it (and quite a lot of work tbh)

### Added

- Leader + Role selection in the topleft
- Quick queue dropdown under the role selection.

All dungeon queues, raid finder queues and the pet battle queue are supported.
For PvP queues there are unfortunately some restrictions from Blizzard:
- Due to some code restrictions it is incredibly hard to queue up to most Battleground/Arena stuff (read more here: [Wowhead](https://www.wowhead.com/blue-tracker/topic/cant-leave-bg-queue-with-acceptbattlefieldport-1-0-1999564311))
- For specific battleground maps you will have to click the last option in the dropdown which brings up the standard PvP menu where you then can go to specific battlegrounds.
- For anything else you will have to click on the type of queue you want to join and click again. This is because Blizzard does not allow any 3rd party addons to simulate a click on their buttons, let alone use their functions.
I hate this myself, believe me. But it's still quicker to queue up this way than the Blizzard way.

Exceptions to this are both Brawls and Arena Skirmish, those functions are not restricted and can be accessed by everyone.

- See the status of the current "application" in the panel on the left side!
You'll get a quick overview of the active queues, you can expand the window and see some additional stats like average wait time, what's currently needed, etc.
While both queue applications and manual group applications(think applications to "485+++ Fyrakk" groups) will be visible here, your manual applications will always be at the top by default (order can be changed via the interface option settings).
You can click on the frame of a manual application to switch over to the group finder.

- All categories (questing, dungeon, arena skirmish, etc.) are visible by default, no more switching between PVE and PVP panels.

- Top right shows your current keystone, the current awakened raid as soon as S4 starts and your current vault progress.

- [Application Viewer] While looking for members for your manually listed group you can edit rating and ilvl requirement by double clicking and setting the group private or public by clicking the exclamation mark. Saves pressing the edit button, though you can still do that if you prefer that.

- Updated all of the background art, icons, new images for the M+ statistics, mostly dungeon/raids background images.

- Remade the entry creation:
    - Instead of just a boring list of dungeons/raids I wrote my own dropdown menu so I can create the following:
    - Questing areas are sorted by expansion and usually the newest zone is automatically selected (right now it's the Emerald dream for example)
    - Dungeons are sorted by current M+ season, current expansion dungeons, dungeons sorted by expansion. The dungeon that will be selected is either the dungeon from your keystone or the top one.
    - Raids are sorted by current raids (think current expansion) or legacy raids - these are sorted by expansion which can be expanded with the arrow buttons beside the expansion name.

### Fixed

- You can (once again) switch to the options panel from the settings gear in the top right.

- Added all the initial spec id's (when you haven't chosen a spec you still have a spec id for the game to function correctly). No more weird errors because of unknown specs.

- [Search panel] Split dungeons (like Dawn of the Infinite) will now show up correctly with "RISE", "FALL", etc. instead of "DOTI".