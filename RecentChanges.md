## [2.0.4](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.4) - 2024-05-20

### Added

- [M+ Statistics] Keystone dropdown will now show potential score gains after clicking on your or a party members key from the dropdown.
Everyone who has either this addon or Details will be able to see keys from their party/raid.
After clicking on a key of yourself you will see the score your character could gain.
If you click on a partymember's key you will see the score all of your characters could gain (since you could theoretically team up with this party member and one of your alts).
Score increase's syntax: Score gain when not in time | Score gain with 0.1 seconds left | Score gain with 40% time left (this is the max bonus you can get)
Right under the dropdown there's a new timelimit slider, you can set the time left of the key timer (in %) for calculations.

- PVP queues added to the queue selector.
Since PVP queues have multiple checks in place I can't have you just click on them and queue up.
You'll have to select the type of pvp queue you wanna join and then click "Join Battle."
There is (to my knowledge) no current way of both selecting the button and joining at the same time, let alone programmatically join any commonly played pvp queue.

Arena Skirmish, the normal brawl and the special brawl are exceptions, they can be queued for programatically.

- Calendar events are implemented!
Whenever a special event (timewalking, pvp brawl, etc.) is currently ongoing or going to start in the next 7 days there will be a notification in the main tab.

- [Filter Panel] All expansion dungeons are now included in the dungeon filter options (currently DOTI, RISE and FALL were missing).
Next expansion starting in season two there will be the current season dungeons and right beneath there will be the expansion dungeons (since currently 8 of the DF dungeons are also in the current seasonal dungeon rotation).

- [Filter Panel] For raids you can now filter by killed bosses.
You can set a number range (e.g. 0-3 bosses killed) or when having the raid options enabled you can filter single bosses out (e.g. set Volcoross to "slain (red border)" and only groups that have atleast slain Volcoross will show up or set Gnarlroot to "alive (green border)" to get fresh groups)

- [Filter Panel] Integrated a new filter option for affix checks.
If the current affixes include either raging or incorporeal checking this option will make sure there is atleast 1 person who can deal with the affix.

- [Active Queues] PVP queue frames will now have an appropriate PVP background. Either from th

### Changed

- All queue frames should now have an cancel button in the "Active queues" panel.

- The algorithm to calculate raid progress has been adjusted to better differenciate between awakened and non-awakened raids.

### Fixed

- [Blizzard LFG filter] Rewrote my code so Blizzard will actually recognize MIOG's lfg filters

- [M+ Statistics] The key dropdown is once again visible.

- [Detailed Information Panel] If a player has progress in all 3 awakened raids the progress should now reflect all 3 instead of the 2 highest ones.

- [Detailed Information Panel] The comment should now display text instead of a search result ID, mb.

- [Detailed Information Panel] There shouldn't be any more "TEST" strings in the right panel.

- [Filter Panel] Rating will not be checked if you're not in the dungeon / arena search panel.

- [Filter Panel] MIOG's filters will now be correctly applied to Blizzards dungeon lfg filters.

- [Filter Panel] Some issues with class and role filters have been resolved.

- [Queue Selector] (All?) Event queues will now have an icon if they don't usually have one (like timewalking stuff).
The icon will by default be the one from the expansion it's about.

- [Stock Blizzard Panel] There won't be any error message anymore when switching to the stock UI with the topleft button in the title bar and then directly trying to join any rated pvp queue.

- [Search Panel] After switching to a different category all frames will be refreshed correctly.

- [Search Panel] PVP categories will now have the correct function associated with coloring the rating.

- [Search Panel] Questing and custom categories will now use dungeon score as their go-to sorting value.

- [Interface options] The background image can now be changed again without errors popping up.

### Known issues

- There is currently no good way of showing larger groups like Rated BG groups or custom groups with over 5 members.
Currently figuring out a good / performant way to do that.

- The raid statistics for awakened raids are getting superceded by higher difficulties, e.g. if you have 2/9 normal and 9/9 heroic it shows up as 9/9 normal.
Don't think I can really do something about that, Blizzard's limitation of achievement tracking.

- If you want to queue for specific battlegrounds like Arathi Basin or Seething Shore you will have to go to the stock ui, select the battleground, go to MIOG's queue selector, go to PVP and "Join Battle".
This issue is resolved in the next version (2.0.5).

- [Active Queues] Arathi Basin has no background texture and Ashran has the wrong background texture.