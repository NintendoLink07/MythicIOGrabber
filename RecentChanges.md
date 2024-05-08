## [2.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0) - 2024-05-08

2.0 is here!
Took me longer than I wanted but it was worth it (and quite a lot of work tbh).

If you want the UI from before (just layered over the standard Blizzard frames) you will have to use "Lite Mode", which is a new setting in the interface options.

If there are any UI errors since updating to version 2.0 you will have to reset your settings. There is a new button in the interface options where you can reset everything.


### Added

- Leader + Role selection in the topleft
- Quick queue dropdown under the role selection.

All dungeon queues, raid finder queues and the pet battle queue are supported.
Due to some code restrictions it is incredibly hard to queue up to most Battleground/Arena stuff (read more here: [Wowhead](https://www.wowhead.com/blue-tracker/topic/cant-leave-bg-queue-with-acceptbattlefieldport-1-0-1999564311))
I had all pvp queue buttons working but there always have to be 2 separate clicks for pvp queue up stuff to happen, it just wasn't intuitive
Exception to this are Skirmish and both Brawls, those will be implemented in 2.1.
Not sure if I will re-implement those other buttons, there will always be atleast a queue link to the pvp frame.

- See the status of the current "application" in the panel on the left side!
While both queue applications and manual group applications(think applications to "485+++ Fyrakk" groups) will be visible here, your manual applications will always be at the top by default.
You can click on the frame of a manual application to switch over to the group finder.

- All category buttons (questing, dungeon, arena skirmish, etc.) are visible by default, no more switching between PVE and PVP panels.

- Underneath the category buttons will be the activity name of the last group you have joined, e.g. Algeth'ar Academy (Mythic Keystone). I always forget what group I joined so I found it useful.

- Top right shows your current keystone, the current awakened raid and your current vault progress.

- All current crests, descending from Aspect to Whelpling, with total earned and current max are shown right underneath the vault info.

- Updated all of the background art, icons, new images for the M+ statistics, mostly dungeon/raids background images.

- Remade the entry creation (creating a group):
    - Instead of just a boring list of dungeons/raids I wrote my own dropdown menu so I can create the following:
    - Questing areas are sorted by expansion and usually the newest zone is automatically selected (right now it's the Emerald dream for example)
    - Dungeons are sorted by: current M+ season > current expansion dungeons > dungeons sorted by expansion. The dungeon that will be selected is either the dungeon from your keystone or the top one.
    - Legacy raids are sorted by expansion.

- Bottom tabs on the main window are for statistics:
    - M+ statistics will show your account's character's progress. Each time you log into a character the data gets updated.
    The dropdown in the topleft shows your keystone or the keystones of your party / raid members (if they have Details or any addon that uses LibOpenRaid installed).

    - Raid statistics show Awakened and old raid progress for each character.
    Raid finder "progress" will not be supported.

    - PVP statistics are kind of not done yet (because I'm not playing any pvp at all).
    They show the rating and the current's season highest ranking of the characters.
    Topleft shows the honor bar, hovering over it will show the next reward.
    Honestly I'm up for improving the pvp statistics but I have no clue what people would want to see there otherwise.

    - Teleports are self-explanatory.
    All M+ teleports you have should be listed right there.
    As I have no raid teleports yet they are not officially supported since I can't test it.
    But maybe they'll get auto included when I scan for teleports, I really don't know.

- Already "integrated" Blizzard's 10.2.7 filter panel (sort of, have to look at Blizzards code to know how they exactly use it / where the filters get applied, pretty sure I got most things implemented correctly).
    - If you change something in there it will get applied to MIOG's settings aswell.
    - Also if you change something in the filter panel it gets applied to Blizzards filter panel aswell (if the option is supported, e.g. minimum rating is supported but maximum rating isn't so only minimum rating gets copied to Blizzards settings)

- [Application Viewer] While looking for members for your manually listed group you can edit rating and ilvl requirement by double clicking and setting the group private or public by clicking the exclamation mark. Saves pressing the edit button, though you can still do that if you prefer that.

- [Application Viewer] There is now a loading bar for the group panel at the top. This indicates how many group members have been inspected for their specialization.

- [Search Panel] Added separate icons indicating what type of friend is in a specific listing: for battle net friends orange, character (normal) friends blue or guild mates green

- [Search Panel] When a group gets the orange "does not match your filters anymore" there will be now the first reason why ("class/spec wrong, not the correct amount of tanks, etc.)

- [Filter Panel] All filters are now separated for each category. Filters you apply while looking for a raid group will get saved and reapplied when you, once again, look for a raid.

- [Filter Panel] Added raid options for filtering.

- [Filter Panel] Added an option to hide groups that have hard declined you (actual decline of the application instead of just delisting or full group).

- [Filter Panel] Added role "link" options to filter groups that e.g. either have a tank or a healer or either have already 2 tanks or no healers.

- Sounds have been added to most buttons to get a bit more feedback.


### Fixed

- Way better memory management, lower end hardware will feel this the most, before the addon would use easily 150-200mb if you were listing your own group and looking through the group finder at the same time.
While there is still some stuff to fix (e.g. if you only use the Search Panel for multiple hours straight without any /reloads memory usage will get to ~150mb usage) it's way better than before.

- You can (once again) switch to the options panel from the settings gear in the top right.

- Added all the initial spec id's (when you haven't chosen a spec you still have a spec id for the game to function correctly). No more weird errors because of unknown specs.

- [Search Panel] Split dungeons (like Dawn of the Infinite) will now show up correctly with "RISE", "FALL", etc. instead of "DOTI".

- [Search Panel] Better application status management. It will now also actually show if the group has been filled up instead of delisted.

- [Application Viewer & Search Panel] Awakened raids are now included in the detailed information panel.


### Next release (2.1)

- Calendar events (like Timewalking, Holidays with a dungeon) will be implemented. Some are already included in the queue selector but not all of them. Also gonna include some sort of "Hey, this holiday is currently ongoing", maybe also some progress stuff for mount farming.

- Character statistics will be improved. More data, more useful functions.

- Seasonal gearing charts. How much crests do you need for what, what bosses drop what level of gear, that kind of stuff.

- [Application Viewer] Class panel inspection algorithm improvements, UI wise and better detection at specs and keeping that info between /reloads.

- [M+ Statistics] You can select any keystone in the dropdown to show potential score gains from your key or the ones of your party / raid.


### Future releases (2.2+)

- Implementing my own kind of adventure journal with scaling damage numbers, better loot overview, easier navigation. Will maybe even be it's own addon, not sure how bloated this is gonna get.