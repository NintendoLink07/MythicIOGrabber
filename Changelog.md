# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].


## [2.0] - 2024-03-03

2.0 is out! Completely overhauled xxx is here!

### Added

- Quick queue from the dropdown in the topleft!
All dungeon queues and raid finder queues are supported.
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

- All categories are visible by default, no more switching between PVE and PVP panels.

- While looking for members for your manually listed group you can edit everything right from the same window by double clicking on what you wanna change. Saves pressing the edit button, though you can still do that if you prefer that.

- Updated all of the background art for the application viewer, mostly dungeon/raids background images.

### Fixed

- You can (once again) switch to the options panel from the settings gear in the top right

- Added all the initial spec id's (when you haven't chosen a spec you still have a spec id for the game to function correctly). No more weird errors because of unknown specs.



## [1.9.1] - 2024-02-16

### Fixed

- Corrected the position of the "Friend in group" icon

- The "Cancel Application" button should now correctly be hidden for subsequent searches if the application fails or gets declined



## [1.9] - 2024-02-15

### Added

- Got the suggestion from a reddit thread a few weeks ago: if you create a group (can/should be set to private) from the Premade Groups panel (Keyboard shortcut 'i') and you type /miog debugon_av_self you will see how other people see you in their application viewer.
If you want to check for pvp: type /miog debugon_av_self {bracketID}. 1 for 2v2, 2 for 3v3, 3 for 5v5 or 4 for 10v10. (there won't be any pvp data in the detailed info panel, only the rating and bracket name in the smaller panel. You can only get real data for other players if you can inspect them).
Be sure to either /reload after or type /miog debugoff, otherwise you will not see any applicants to your group.

### Changed

- The Application Viewer and the search panel are now written in XML instead of LUA.
Mostly means huge performance increases across the board while it's way easier for me to update all the old art without breaking shit.
The main frame, class panel and filter frame will be rewritten until 2.0 comes out.

- [Raid tab] Design has been changed, instead of left to right it's now top to bottom for raid order (current to last season).
Readability hasn't been ideal and I wanted to future proof it (if a raid has 11 or 12 bosses I can now display them without issues).

- [Search panel] Dungeons', raids' and arena's difficulty/bracket dropdown isn't a unified option anymore, e.g. enabling the difficulty filtering for dungeons doesn't activate the filtering for raid or arena.

### Fixed

- [Search panel] The border of the currently selected group should not disappear anymore when another groups gets any data update.

- [Search panel] There should be no random groups popping up anymore that got delisted

- [Search panel] Groups you've applied to should jump to the top of the list immidiately.

- Many UI bugs have been squashed because of the XML UI rewrite (layering, size and position issues).

### Known issues

- [Search panel] Sometimes after applying to a group the "Delisted" string shows up until you manually search again (just a UI bug)

### Upcoming

2.0 is coming soon (second week of march probably, wanna be done before anything Season 4 related comes to live)!
This update completely remodels the standard Blizzard frame for everything group oriented (everything you see when you press 'i'):
    - Everything it does now
    - All queues: dungeon, raids, random bg's, fast queue up and check for killed bosses / requirements for queues (for example if below certain Ilvl)
    - Quick look at the groups you've applied to beneath the title bar
    - Quick look (think sidebar) at current progression of raid, M+ and pvp
    - Current ongoing events: quick queue up, completion state, etc.
    - Great vault completion bar
    - Way better menu-ing than the standard Blizzard frame and better than the addon does it now
    - Updated and upscaled art (all old raids with icons and shit in the group finder)



## [1.8.1] - 2024-02-08

### Fixed

- [Search Panel] Filtering and sorting should now work again.



## [1.8] - 2024-02-07

### Added

- The invite pending dialog box you get when an invite pops has been updated!

To see which "+26 PUMPERS" or "FYRAKK BLAST 485++++" group you've actually got invited to you will see:
    - Icon and name and difficulty / zone of the activity
    - Groups members / group comp numbers / bosses killed
    - Primary and secondary score/progress data
    - Remaining time until the invite times out (always 90 seconds)

Instead of a dialog box it's now a list.
It is not possible to decline an invite by pressing Escape anymore (which was with standard Blizzard frames).

If multiple invites pop at the same time the list will have all invites visible at the same time. In the standard Blizzard way you have to decline one so the next pending invite box pops up.

### Changed

- [Search Panel] When a group has the auto accept option enabled the groups title and difficulty text will be blue.

### Fixed

- [Search Panel] Another big performance increase for the search result list.
Toggling filter options should now be really smooth.

- [Search Panel] The boss order numbers won't show up anymore if there are no bossframes visible.

- [Search Panel] The cancel application button should no longer disappear for no apparent reason.

- [Search Panel] Dungeon filter options should now be visible right from the first login.

- [Search Panel] If a group you've applied to no longer matches up with your filters the group frame will now have a orange border for groups you haven't applied to yet but are in the current list or a red border if are currently applying to the group (doesn't matter if party fit, bloodlust fit, classes or spec, etc.)

- [Search Panel] Search result tooltip now always shows the zone name / difficulty text.

- [Search Panel] Raider.IO data will now be reset for every search result when you refresh the list.

- [Application Viewer] Improved the frame management system with stuff that I learned from the search result list. Faster sorting and refreshes when declining applicants.

- [Application Viewer] The member/spec frames in the titlebar should now always be visible.

- [Application Viewer] In applications with premade groups of two or more members the other applicants frames should now move when one's above get expanded.

- [Application Viewer] When you join a group that delisted with you joining (group size limit for example) there won't be any errors anymore.

### Known issues

- [Application Viewer] When you decline an applicant the frame jumps to the bottom of the list and is still visible for a split-second.
This will be fixed in 1.8.1.



## [1.7.5] - 2024-02-05

### Fixed

- Current M+ dungeons filter options should now always be available.

- Sorting by age should now be possible again.



## [1.7.4] - 2024-02-05

### Fixed

- No more errors when the leader name is not updated yet



## [1.7.3] - 2024-02-04

### Added

- A loading spinner and a status frame when no groups have been found has been added.

- If you have been soft declined (timeout, delisted, group full) or hard declined (actual decline) the title and zone/difficulty text of the search result will be colored orange or red.
This will be saved between /reloads or logouts.

- If you've favoured a player before their group listing will now also show up further up in the list!

### Changed

- I've noticed that the bottom few results (around 15-30) are always unsorted, because there is some data missing which Blizzard sents later than intended.
I can't really do anything about that.
I have added 0.3s delay, which usually covers all the data that gets sent later.
You can turn this delay off in the interface options but I do advise against it.
Otherwise you will have to press "Search" and press "Search" again when all the groups are visible, this should also cover the delay but isn't as elegant as my built-in solution.

- The difficulty dropdown has been changed.
Dungeons go from M+ all the way down to Normal, Raids go from Mythic to Normal and for Arena you can choose to filter out 2's or 3's.
In all other categories the dropdown is not visible (unless I find some use for it there).

### Fixed

- New installs of this addon or fresh starts (after a PC restart or full exit of WoW) don't have to press the search button of each category twice for results to show up.

- The "old settings deleter" has been fixed, now only old settings which aren't user-definable will be deleted (e.g. no more favoured applicants, etc.)

- Information in the raid tab should now always be shown correctly.

- PVP sorting by rating should now be working correctly.

- PVP score filtering should now also be working correctly, was using dungeon score before.

- Adjusted the sort buttons' position in the search panel.

- Improved performance overall and especially when you refresh the search list.

- Corrected boss frame desaturation (in Amirdrassil the encounter journal doesn't go by wings, e.g. Volco -> Larodar. Instead the index goes Volco -> Council -> Larodar -> Nymue. Lol why).

- Party fit, bloodlust fit and battle ress fit will now apply correctly if you're in a category where there technically are no real limits (BG's, custom groups).

- Various errors have been fixed.



## [1.7.2] - 2024-01-31

### Added

- A proper throttle frame (when you search too often) has been implemented

- There are now boss frames when you are looking for a raid.
Encounters that are desaturated have already been defeated.

### Changed

- When you applied to a M+ group and you're currently in the raid panel (or any combination of panels tbh) the groups will now have their m+ score or progress data shown.

- Improved the search result frame system, which leads to almost no micro stutters occuring.
The only "downside" is that the used memory jumps to almost 80mb (equal to having all RaiderIO addon EU data loaded) when currently looking for members and browsing groups at the same time, with no filters active.
This will be improved during this and next week.

- Improved the handling of applications, delisting, etc. behind the scenes, made it less prone to error.

- Fixed some filter edge cases.

### Known issues

- When a category has not a single group listed (e.g. Rated BG's, Skirmishes) the throttle frame doesn't disappear (I currently only refresh the frames when atleast 1 result is available)

- When you install the addon for the first time or you delete the settings you have to press the "Search" button twice in each category to actually see correct results (only for the first login)



## [1.7.1] - 2024-01-29

### Added

- A timeout timer when you apply to a group has been added.

- Dual score checks (min, max) has been added to the filter frame.

### Changed

- Filtering has been made more reliable.

- Lowered the amount of micro stutters.
Already have an idea how to get rid of them completely, will release the new frame system with 1.7.2 at some point this week.

- Decreased the brightness of the color texture of groups you've applied to.
Using a darker green so Monks', Hunters' and Evokers' border doesn't seem to disappear.
 
### Fixed

- Made searching for groups more reliable.

- When you applied to a M+ group and you're currently in the raid panel (or any combination of panel tbh) the group you've applied to will show up (standard Blizzard behaviour, forgot this edge case).

- PVP ordering and displaying of brackets should now work correctly.

- Changing the difficulty with the dropdown should now refresh the result list.

- Improved compatibility with PremadeGroupsFilter.



## [1.7] - 2024-01-25

Thanks for 10000 downloads already!
Happy to see players actually enjoying my work.
Please report any bugs either as a comment on the Curseforge page or on the Github issues page, unfortunately I can't test everything by myself.

### Added

The group finder has now also been updated!

- Visuals of the search list have been updated.
This includes:
    - an icon of the activity has been added to the top left.
    - for groups with <= 5 members: Instead of role icons you will now see the respective spec icons of the group members.
    - for groups with > 5 members: You will see the standard 2/4/14 style of group comp
    - (This is not yet implemented, but will be in the next 2 or 3 updates) for raids specifically you will see the bosses of the raid and the slain ones will be grayed out
    - you can sort the list for (the leader's) M+ score / raid progress / highest key done for listed dungeon and age
    - the detailed information panel from the application viewer has been added aswell (unfortunately you can only look up the leaders data)

- Built-in filters to filter even specific specs out.

- Premade Groups Filter (specifically) is supported (for now).
The currently included filter options do work, however I don't like the positioning/design of them yet, so feel free to not use them for now.
I don't change any Blizzard functions; instead I hook directly into them. So as long as other different addons use official Blizzard functions they should work together (not promising anything)

For now everything from this season, last season and all DF raids has been implemented.
In case you look for legacy raids or dungeons from before DF there will be placeholder images and zone titles.
Those will be implemented over the next few weeks.

Usually new groups come in automatically (if you dont use Premade Groups Filter / any filtering addon at least) but there are still performance issues (micro stutters).
I already know how to fix them but it might take until Sunday, the 28th since I'm really busy with work atm.

### Fixed

- Performance improvements all around!
Much stuff has been fixed / improved since many UI elements and a lot of code is reused with the new search panel.

- Settings improvements: while old settings have reliably been deleted if no longer in use now new settings get automatically imported from the default list.
Should prevent a bunch of errors for new installs.

- Squished some really old bugs like when you pixel- & frame perfect clicked between two applicants you could sometimes invite a different applicant that was in the Blizzard application viewer (...lol)

- [#9](https://github.com/NintendoLink07/MythicIOGrabber/issues/9): "Character Portrait Menu Lua Error Compatability with Ndui" has been fixed.
Fixed this case for every UI that rewrites character frames (ElvUI and SUF were not affected since I used those for testing).


## [1.6.4] - 2024-01-16

### Upcoming

- Application viewer is pretty solid so now I'm gonna go ahead and start dev time for the lfg simulator side.
Lots of stuff can be improved in regards to the process of applying to groups.

### Changed

- TOC push for 10.2.5.

- Added some code to make ptr development easier.

- Code cleanup.

### Fixed

- When creating a new group with no description after the old group had a set description it should now clear the description.



## [1.6.3] - 2024-01-15


### Changed

- Active role / class / spec filters will now also filter correctly if any member of a premade group can fill in that role / class / spec (before it would not show the premade group if the leader wasn't eligible).

- Old saved settings that are no longer used / have been renamed should now be deleted from the save files in the "WTF" folder.

- The interface options should now be alphabetically sorted into the addon list.

### Fixed

- UI elements shouldn't disappear anymore if no manual resizing of the frame has been done and you extend the frame via the extend button.



## [1.6.2] - 2024-01-14

### Fixed

- Manual frame resizes should now be correctly applied when pressing the expand button.



## [1.6.1] - 2024-01-13

### Fixed

- Some errors were popping up if this was the first time you installed the addon.

- Favoured applicants panel and background options weren't showing up in the interface options.



## [1.6] - 2024-01-12

### Added

- You can now right click any player character / players from your party / raid and set them to favoured, so they show up further up in your applicant list next time!
If you've been the leader and you have invited them you can also change them to preferred in the "last invites" panel.
Just click on the black dot and it will change to a checkmark, this means they're saved to your favoured list.
This feature is enabled by default and can be disabled in the inferace options.

- Added a tooltip for the premade texture (in case people don't know what it means).

- The frame can now manually be resized via the button in the bottom left corner above the footer bar (where the browse, delist and edit buttons are).
The manually set height will be the new standard height for the extend button in the "Dungeons & Raids" title bar.

### Fixed

- Some errors were popping up if RaiderIO wasn't installed (which you definitely should have installed).

- Improved the spec detection logic.

- Fixed role ordering in the title bar and readded the borders around the spec frames.



## [1.5.2] - 2024-01-06

### Changed

- The race of the applicant is now shown in the detailed panel.

### Fixed

- All roles an applicant can play will now be shown, due to a code bug it only showed the first available role.



## [1.5.1] - 2023-12-27

### Changed

- The new last invites panel can now also be hidden with another click on the "INVITES" button.



## [1.5] - 2023-12-24

Happy holidays everyone!

### Added

- You can now add members you've recently invited to your group to be preferred!

These players will show up at the top before other applicants.
They have a golden border so they can be identified quickly.
You can select past applicants in the new "Last invites" panel (click on the vertical "INVITES" button, not sure if I'm a fan of the vertical button, maybe I'll change it up in the next couple of updates).
All preferred applicants are listed in the interface options (accessible with the cogwheel, via Addon Compartment button or just manually going into those options).

Last invited applicants stay in the list for 3 days.
Preferred applicants in the interface options stay there until they're manually deleted via the X button there.



## [1.4.5] - 2023-12-20

### Changed

- Minor UI pixel shift for visuals

- Disabled the known issues icon since there are no known issues at the moment

### Fixed

- Affixes should now always be correctly requested



## [1.4.4] - 2023-12-19

### Fixed

- Blizzard seems to have fixed the spec id issue.
Have tested it out a lot this morning and each premade sent the correct spec data 100% of the time.
Hurray!

- New applicants should now no longer jump inbetween applicants already in the list.
This way you won't invite someone who just applied while you wanted to invite someone else.
Downside is now the applicant list only gets refreshed when you either press the refresh button or decline / invite someone.
If you don't have invite privileges it will still auto refresh on every new applicant.

### Changed

- Improved performance again by quite a lot!
From ~0.071s to around 0.021s per 33 applicants.
Or in other words: joining a group with 100 applicants now is faster than joining a group with 33 applicants with the old MIOG version.
Makes the lag when you join a group really short.

For anyone interested why the improvement is so large: the SetBackdrop function is actually quite time expensive.
While it's easier to just use the functions already available than to make a new texture it's (for my use-case) not worth it.
With multiple applicants applying and going through the same loops hundreds to sometimes thousand times per second making a new texture is easier on the CPU (very important for WoW) and actually not that RAM hungry.



## [1.4.3] - 2023-12-18

### Changed

- Further improvements to performance (the new filter options took quite a toll on the performance).
Per 33 applicants from ~0.088s to 0.071s (fastest compute ever even with data before the new filter options).
Mostly matters when you /reload or join a group that is still listed and looking for members and has already a lot of applicants.

- Improved the raid panel visually (made difficulty borders width / height more consistent).



## [1.4.2] - 2023-12-15

### Fixed

- Dungeons are now actually alphabetically sorted.

### Changed

- Edited the info message so people know why there is sometimes no spec data of the applicants.
- Small code changes for performance gains.



## [1.4.1] - 2023-12-13

### Fixed

- An issue where the right click r.io link couldn't be generated has been fixed (if the applicant was from the same server).



## [1.4] - 2023-12-12

### Added

- You can now filter classes and specs!
Instead of the 3 role filter options you have now a filter panel where you can enable or disable what you want to filter.
Obviously if you filter for a healer demon hunter you won't find anything though... probably.

- When there's a player on your ignore list the name is colored in red and the tooltip indicates that the player is on your ignore list.

### Changed

- Number of current applicants is now in the bottom right corner (in the footer bar)

- Disk space requirement increased because I used round class textures for the filters (increased by about 3.5mb)

### Known issues

- A premade group of 2 or more members / sometimes even single ones won't send correct spec data to the game client.
Instead of a spec icon it will show a question mark for those groups.
Seems to be a Blizzard bug, unless I find a workaround we have to wait for Blizzard to fix it.
I did report it ingame and on the [official/non-official](https://github.com/Stanzilla/WoWUIBugs/issues/502) github issues page, so now we wait.



## [1.3] - 2023-12-08

### Known issues

- A premade group of 2 or more members / sometimes even single ones won't send correct spec data to the game client.
Instead of a spec icon it will show a question mark for those groups.
Seems to be a Blizzard bug, unless I find a workaround we have to wait for Blizzard to fix it.
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



## [1.2.12] - 2023-11-23

### Known issues

- A premade group of 2 or more members won't send correct spec data to the game client.
Instead of a spec icon it will show a question mark for those groups.
Seems to be a Blizzard bug, unless I find a workaround we have to wait for Blizzard to fix it.
I did report it ingame and on the [official/non-official](https://github.com/Stanzilla/WoWUIBugs/issues/502) github issues page, so now we wait.


### Fixed

- Windwalker and Mistweaver should now be correctly identified

- Made one more check for specs, even with the current Blizzard bug sometimes hunters would show up as Discipline spec (lol)



## [1.2.11] - 2023-11-20

### Known issues

- A premade group of 2 or more members won't send correct spec data to the game client.
Instead of a spec icon it will show a question mark for those groups.
Seems to be a Blizzard bug, unless I find a workaround we have to wait for Blizzard to fix it.
I did report it ingame and on the [official/non-official](https://github.com/Stanzilla/WoWUIBugs/issues/502) github issues page, so now we wait.


### Fixed

- Applicants should no longer duplicate when you get a loading screen of any kind.



## [1.2.10] - 2023-11-19

### Known issues

- A premade group of 2 or more members won't send correct spec data to the game client.
Instead of a spec icon it will show a question mark for those groups.
Seems to be a Blizzard bug, unless I find a workaround we have to wait for Blizzard to fix it.
I did report it ingame and on the [official/non-official](https://github.com/Stanzilla/WoWUIBugs/issues/502) github issues page, so now we wait.


### Fixed

- There should now only be one interface option panel instead of a new one getting created after every loading screen.



## [1.2.9] - 2023-11-18

### Known issues

- A premade group of 2 or more members won't send correct spec data to the game client.
Instead of a spec icon it will show a question mark for those groups.
Seems to be a Blizzard bug, unless I find a workaround we have to wait for Blizzard to fix it.
I did report it ingame and on the [official/non-official](https://github.com/Stanzilla/WoWUIBugs/issues/502) github issues page, so now we wait.


### Added

- There's an info icon in the topright corner of the info panel when there are any ongoing issues that are not fixed / fixable until Blizzard fixes it.


### Fixed

- All frame borders should now reset correctly.



## [1.2.8] - 2023-11-17

### Known issues

- For some reason a premade group of 2 or more people doesn't send correct spec data to the game client.
So for now it will show a question mark instead of a spec icon 99% of the time.
Will figure this out tomorrow evening.


### Fixed

- (This drives me crazy) Should be no more errors because of the spec id (I really hope so)



## [1.2.7] - 2023-11-16

### Added

- When Blizzard hasn't sent the actual spec the person is applying with it shows a question mark


### Fixed

- All colored borders will now reset and not persist through relistings



## [1.2.6] - 2023-11-16

### Fixed

- Fixed spec id problems for real now (if Blizzard somehow didn't send the actual spec id)



## [1.2.5] - 2023-11-16

### Fixed

- Fixed spec id problems (if Blizzard somehow didn't send the actual spec id)



## [1.2.4] - 2023-11-11

### Fixed

- Fixed some layering issues so the comment icon, role icon and pretty much everything else should not disappear if you requeue a bunch of times.



## [1.2.3] - 2023-11-11

### Fixed

- Fixed some code so previous season score, main score and main's previous season score show up again.
- TOC Version update



## [1.2.2] - 2023-11-09

### Fixed

- Changed the order when the affixes for the week are getting requested.
Otherwise there was a veeeery small chance that it would request them before the main addon was initialized, leading to an error.

- Deleted a debug print that I forgot.



## [1.2.1] - 2023-11-08

### Added

- Added an option in the interface settings panel to show/hide the class panel
- More background options: 1 from every expansion, just for a bit more flavour


### Fixed

- Settings button should now reliably open the settings (updated to Dragonflight functions)
- Title bar group ordering should now be correct
- Fixed "CURRENT_SEASON" bug. First week of a new patch there's is technically no actual season
- Fixed the addon compartment function, should now open the settings reliably



## [1.2.0] - 2023-11-06

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
- Fixed that some textures where keeping the hover / click events that were on them previously


### Known Issues

- 5 man (or less) group: the ordering of the group sometimes bugs out, so it's not Tank>Heal>3DPS but something different (have seen Tank>DPS>Heal>2DPS and Tank>DPS>DPS>Heal>DPS)



## [1.1.7] - 2023-10-28

### Upcoming

- The whole accept/decline thing is still wonky, since I try to keep the applicants in memory so the addon doesnt compute the full list every time shit happens.
This is going to be the next bigger update I guess.
The next update will probably release the first week in November and for that week and the 1st week of 10.2 I'll heavily update the addon.
After that I'm gonna grind M+ for title so expect less updates (will probably code inbetween dungeons and release a new version when enough changes happened)

Also: I changed from a 5800X3D to a 7800X3D, so performance leaks will be less obvious to me.
If you experience anything odd at all just open up an issue or /w me ingame.


### Added

- Desaturated colors for last tier added, makes it more obvious who had 7/8M and who had 7/8N last tier


### Changed

- Compute time down to ~0.11 ms per 33 applicants on the first run, every refresh or re-apply takes now only ~0.08ms
- Invite/decline logic changed, should be more accurate now (some edge cases where you couldn't invite, decline or both)


### Fixed

- Possible roles of the applicant should now show up again in the detailed view
- Edge cases of applicants reappearing from memory, even when already declined



## [1.1.5] - 2023-10-24

### Fixed

- Fixed a problem where the applicant would be declined but still be visible in the application viewer
- Deleted debug print statements



## [1.1.4] - 2023-10-24

### Changed

- Compute time down from ~0.14ms per 33 applicants to ~0.125ms per 33 applicants

### Fixed

- Fixed a problem where the invite / decline buttons where no longer visible after a reload
- Fixed a problem where Ret paladins would bug out the UI



## [1.1.3] - 2023-10-21

### Added

- As soon as 10.2 is out all applicants will have a spec icon right besides their role icon!
The logic is already implemented, as soon as 10.2 is live the addon can request the data.
- M+ score colors now get calculated with a custom function, more colors inbetween instead of just green, blue, purple, orange

### Changed

- Small logic rewrite, now it takes less time to compute the applicant list, from 0.32ms for 33 applicants to 0.14ms for 33 applicants
Really only relevant when /reloading or entering an instance, depending on the size of the applicant list it could take a good 2-3 secs to compute everything (100+ applicants, usually on wednesdays or patch drops)



## [1.1.0] - 2023-10-17

### Fixed

- Minor code changes, more a version push since I forgot that I uploaded a 10.2.0 version 2 weeks ago and nobody got any updates of this addon, LOL
- Kinda fixed the "keep creation info" function, still experimental though



## [1.0.9] - 2023-10-17

### Added

- The info panel background will not be generic anymore for anything DF S2 and onwards
All DF raids and S2/S3 dungeons will have their respective loading screen (cropped and upscaled, if needed) shown as the info panel background

### Fixed

- Fixed activity title layer, font should be way brighter now



## [1.0.8] - 2023-10-17

Yes, the weird errors currently popping up with this (and many other) addons are not my fault
More infos: https://github.com/Stanzilla/WoWUIBugs/issues/483

### Added

- Both PVP rating sorting and raid progress sorting is now implemented!
PVP rating functions basically the same like M+ rating.
Raid progress compares first the difficulty of the applicant leaders: Mythic > Heroic > Normal.
If they're the same difficulty it compares the progress itself.
- Interface option added to hide the background image and some background colors (mainly for ElvUI users or players with semi-transparent interface frames).
- Added performance test slash commands, generally just for internal use (not recommend for any normal person).
- The linkbox you can call with right click on the applicant name is now positioned directly over the applicants frame.
- Other languages' (russian, korean, etc.) server names are now supported for the linkbox .
- More color coding for raid progress. In addition to Mythic, Heroic and Normal there are now Last tier and No tier.
- Right click on the sort buttons now resets them to their off state

### Fixed

- Listing of group members in the title bar is now fixed, forgot to change the cap of party members back to 5
- New logic for displaying the raid data, should be much more acurate now.
- Clicking the settings wheel should now open the actual settings
- Multiple layering issues fixed


### Changed

- Improved the logic and code flow, which leads to increased performance
Before (more prominent on slower computer) you'd get a longer freeze after a reload when you had a big applicant list, time to compute the list was cut down by approximately 50-55%.



## [1.0.0 / 1.0.0a] - 2023-10-13

### Added

- Interface options setting: (Experimental) Your message when applying to groups will be saved between multiple applications (but not between reloads, atleast for now).

- Interface options setting: (Experimental) Your settings when forming a group will be saved between reloads (but not between reloads, atleast for now).

- When having fewer than 5 players in your party the specs of your party members will be visible in the title bar.
Will probably do a raid version with an expandable small window or something like that but it's somewhat limited by 1. size constraints and 2. Blizzard only doing 6 inspect requests at a time.
This feature might still be a bit wonky, it's the next item to completely finish over the next two weeks, mostly edges cases though.

- Implemented Dragonflight Season 3 dungeons in advance.

- Implemented Dragonflight The Emerald Dreamway raid in advance.

- New sorting methods: you can sort by role, score, keylevel or ilvl. 
Up to 2 sorting methods can be active at a time, e.g. you sort first by role (indicated by the little number on the bottom left side of the button when you click it) and then for score.

- Many tooltips explaining the new features.

- When you set a rating / ilvl limit and an applicant has a premade that is under the rating threshold the rating / ilvl of that applicant will be colored red for easier visibility.

- Clicking on the dungeon / raid / -boss icon in the detailed panel now takes you to the Encounter Journal page for that dungeon / raid with the currently chosen difficulty (Normal, oldschool 25 HC, M+, etc.)
Not sure if I got all edge cases (probably not). Just shoot me a message somewhere if you find one.


### Changed

- Full UI rewrite, updated to more modern WoW UI code standards.

- Saves settings now properly and doesn't refresh user set options when Addon is updated.

- Updated all the icons for a more modern look.

- AI upscaled all the background images, now there's also a different one for each category(dungeon, raid/raid legacy, arena, arena skirmish, etc.).

- Instead of a wall of text of your group creation setting it now shows icons for each category.

- Instead of 2 seperate detailed panels for M+ and raid both are now a tab button in the detailed window! Standard is M+ in Dungeon category, Raid in raid category and every other category will have M+ as standard.


### Fixed

- Many many UI bugs, shifting text/icons, buttons not visible/clickable, text cut off, etc.


### Removed

- Made the "Show actual specs" and "Order group" options unavailable, since they were resource hogging a lot since Blizzard only renders the groups that are currently visible. So the addon would have to update the specs EACH SCROLL / GROUP UPDATE.
From my testing: going from 300fps to 180fps when you refresh or scroll. Currently not worth it and definitely not what I intended.



## [0.9.3b] - 2023-10-04

### Fixed

- Re-enabled status string (was a bit wonky before)


## [0.9.3] - 2023-10-03

### Added 

- Shows now the number of tanks/heals/dps in group in the title bar (kinda forgot about that)
- When you hide any role it will now show how many applicants are hidden


## [0.9.1] - 2023-10-03

### Added

- Implemented a more functional save function, still needs more work though for edge cases.

### Changed

- Frame can't be hidden by escape key anymore (was just a testing functionality actually)


## [0.8.9b] - 2023-10-01

### Fixed

- Tooltip now always visible (was sometimes not visible on the first few applicants)
- Affixes should always be loaded after login (Blizzard has no real "Get me all the current affixes right now" function, you gotta request and wait and stuff)
- Just general UI stuff, mostly correct layering of stuff


## [0.8.8b] - 2023-10-01

### Changed

- Re-enabled the status string (cancelled, timeout, invite declined, etc.)


## [0.8.8] - 2023-10-01

### Added

- Auto sort function is not a Interface panel option anymore.
Now it's a button besides the "Show Tanks" button.
When it's active it sorts applicants either after you press the refresh button in the title bar or you decline someone.

### Fixed

- Where the fuck are all these UI bugs coming from, patch 1 and 2 appear out of nowhere.
Gonna rewrite my UI code in the next few days, it's always a bit wonky when you have to code around Blizzard UI stuff
- Logic improvements, at some point you couldn't even decline applicants anymore (LOL)


## [0.8.4] - 2023-09-30

### Fixed

- Minor bugs


## [0.8.3] - 2023-09-30

### Added

- Raid data (with the RaiderIO addon installed) now visible: current and previous tier data, RaiderIO has more data about the current tier, so the last tier data is somewhat lacking.
- PVP data is implemented but since RaiderIO has (obviously) no real PVP data I have to pull the small amount of data available from Blizzard directly.
Basically just the rating for the bracket and the tier they're currently in
- Huge logic improvements (if you've experienced slowdowns for 1-2 seconds after you've done a /reload they should be gone now)

### Fixed

- Minor UI bugfixes, so stuff will be bouncing around less


## [0.7.5] - 2023-09-29

### Added

- Addon now remembers who you viewed in detail. Auto expands the person on the next refresh

### Fixed

- Code readability updates / simplifying
- Don't remember the other stuff, it's more gooder now


## [0.7.4] - 2023-09-29

### Fixed

- Finally fixed the textline issue, for good this time (hopefully)
- Logic improvements


## [0.7.3b] - 2023-09-29

### Fixed

- Everything seemed 3-chested


## [0.7.3] - 2023-09-29

### Fixed

- Textlines were jumping all over the place, corrected
- Minor logic improvements, still lots to do though


## [0.7.2] - 2023-09-29

### Fixed

- Code cleanup
- Minor bugfixes


## [0.7.1] - 2023-09-27

### Added

- Public release

### Fixed

- Performance and logic improvements


## [0.6.6] - 2023-09-27

### Added

- Intended release, way too buggy so I took it down, now it rests in peace

## [0.6.0] - 2023-09-25
## [0.5.5] - 2023-09-23
## [0.5.3] - 2023-08-22
## [0.5.0] - 2023-09-22
## [0.4.5] - 2023-09-21
## [0.4.2] - 2023-09-21
## [0.4.0] - 2023-08-18
## [0.3.9] - 2023-09-16
## [0.3.5] - 2023-09-16
## [0.3.4] - 2023-09-10
## [0.3.0] - 2023-08-09
## [0.2.7] - 2023-09-07
## [0.2.4b] - 2023-09-05
## [0.2.4] - 2023-09-04
## [0.2.3] - 2023-09-03
## [0.2.1] - 2023-08-31
## [0.2.0] - 2023-08-31
## [0.1.7] - 2023-08-31
## [0.1.6] - 2023-08-30
## [0.1.5] - 2023-08-27
## [0.1.3] - 2023-08-27
## [0.1.0] - 2023-08-25
## [0.0.9] - 2023-08-25
## [0.0.7] - 2023-08-25
## [0.0.4] - 2023-08-24
## [0.0.1] - 2023-08-24

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.1.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->
[unreleased]: https://github.com/NintendoLink07/MythicIOGrabber/compare/1.9.1...HEAD
[1.9.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.9.1
[1.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.9
[1.8.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.8.1
[1.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.8
[1.7.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7.5
[1.7.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7.4
[1.7.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7.3
[1.7.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7.2
[1.7.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7.1
[1.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7
[1.6.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.6.4
[1.6.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.6.3
[1.6.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.6.2
[1.6.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.6.1
[1.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.6
[1.5.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.5.2
[1.5.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.5.1
[1.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.5
[1.4.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.4.5
[1.4.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.4.4
[1.4.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.4.3
[1.4.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.4.2
[1.4.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.4.1
[1.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.4
[1.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.3
[1.2.12]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.12
[1.2.11]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.11
[1.2.10]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.10
[1.2.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.9
[1.2.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.8
[1.2.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.7
[1.2.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.6
[1.2.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.5
[1.2.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.4
[1.2.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.3
[1.2.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.2
[1.2.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.1
[1.2.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.2.0
[1.1.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.1.7
[1.1.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.1.5
[1.1.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.1.4
[1.1.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.1.3
[1.1.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.1.0
[1.0.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.0.9
[1.0.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.0.8
[1.0.0a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.0.0a
[0.9.3b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.9.3b
[0.9.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.9.3
[0.9.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.9.1
[0.8.9b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.9b
[0.8.8b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.8b
[0.8.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.8
[0.8.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.4
[0.8.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.8.3
[0.7.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.5
[0.7.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.4
[0.7.3b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.3b
[0.7.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.3
[0.7.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.2
[0.7.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/0.7.1