# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].


## [3.4.5] - 2025-06-16

### Changed

- The filter panel has been reworked:
    - When you change a setting that is getting applied by Blizzard interally to pre-filter the results you're getting a "warning" shows up asking you to refresh the search panel.
    This way you get more accurate results by Blizzard.

    - Some logic tweaks


### Fixed

- [SearchPanel] After applying to a group the scroll frame will retain it's current scroll position.

- [Progress] Multiple issues regarding the vault status in the overview screen have been resolved.



## [3.4.4] - 2025-05-24

### Changed

- [SearchPanel] Your party members will now be taken into account when using the "party fit", "ress fit" and "lust fit" filters.

- [SearchPanel] The "party fit" filter will now also check for the maximum amount of players allowed for the activity.
*This has been changed because you could theoretically have 29 tanks in a raid and Blizzards data would say there are still 30 spots for dps left.
Comparing the activities max players to the listings current members plus the number of your group members fixes this.*

- [SearchPanel] If you have both the "lust fit" and "ress fit" filters enabled: it will now check both filters correctly in succession.

- [MainFrame] The number of applicant will now be shown in brackets in the "Your listing" queue frame.

- [MainFrame] Relogging when you have a group listed will now automatically show the [ApplicationViewer].

- [SearchPanel] The progress panel below the filters is now only visible for max level characters.

- Any lfg data relating to the seasonal / expansion activities (e.g. seasonal dungeons, current raid) will only be shown when the player is at max level.
*This is due to Blizzard only sending partial or no info about those activities when the player isn't max level.
Improves performance and eliminates incorrect data being shown.*

### Fixed

- [SearchPanel] Groups you've applied to will now automatically pin themselves to the top of the list.

- [GroupCreator] An error has been resolved where the group creator tried to use map data that isn't / wasn't available yet.

- [ApplicationViewer] The raider io panel will now be properly be populated with data and not just be a beautiful black box.

- The [SearchPanel], [ApplicationViewer] and [GroupCreator]'s resize button won't cause the frame to get stuck in place anymore.

- Relogging when you have a group listed will not show the [SearchPanel], [ApplicationViewer] and [GroupCreator] at the same time.

- The last group you joined will now also get saved when you're in lite mode.



## [3.4.3a] - 2025-05-14

### Fixed

- [GroupManager] Follower dungeon groups won't create an error anymore trying to use their class data.



## [3.4.3] - 2025-05-13

### Changed

- [Journal] "Current activities" now only includes the most recent raid.

- [Journal] Items now display their appropriate slot, when applicable.

- [Journal] Items now get sorted by more characteristics.

- All Dragonflight boss icons have been removed, lowering the addon's filesize.

- OpenRaid library updated.

### Fixed

- [Journal] Items duplicating by the amount of activities has been corrected.

- [Journal] Items now correctly reload after clearing all filters.

- [Journal] The instance dropdown will now correctly set the index of the main categories.

- [Journal] Performance while loading has been improved, still a bit laggy when requesting loot data from all current activities (e.g. searching for an item or having no filters active).

- [Journal] Toys now get properly recognized.

- [GroupManager] There won't be any errors anymore when players rapidly leave and join the group, e.g. on a world boss.

- [GroupManager] Itemlevels and durability of other players are now retrievable again.

### Known issues

- [Journal] When selecting an instance with a equipment slot pre selected no results will be shown until you either remove the filter or reclick it.
This is fixed in v3.4.4.



## [3.4.2] - 2025-04-30

### Changed

- All upscaled images are now integrated into a separate addon because the addon grows rapidly in size (atm its around 80mb while most addons are in the 1-5mb range).
If you like the upscaled images you can download the following addon: [MythicIO - Resources](https://www.curseforge.com/wow/addons/mythicio-resources)
This decreased the main addon's filesize by 35mb.

- All background image options for the main frame have been resized.
This reduced the addon's filesize by another 18mb.

### Fixed

- [Journal] The journal won't get stuck in an instance anymore by manually updating the selected instance of Blizzard's adventure journal.

- [Journal] You can now change the difficulty when you don't have an instance selected.

- [GroupManager] The itemlevel gets now rounded down and gets displayed without any decimals to preserve the UI spacing.

- [Progress] The honor level now gets updated correctly (was using UnitLevel instead of UnitHonorLevel, lol).

- [Progress] A scrollbar has been implemented for the main view to see more than 5 characters at a time.

- [Progress] Lockouts should now correctly get updated once you log in with a character.

- [SearchPanel] A rare error has been resolved where a dungeon listing's first boss data would stick around when you switched to the raid category and block all the raid listing's first boss data from being applied.

- All raider io dungeon panels (like the progress panels, group manager inspection panel, etc.) are now sorted by the dungeon's abbreviation.

- Load up data collection now correctly recognizes if an instance is a raid or not (important for many different parts of the addon).

- Open Raid library updated.



## [3.4.1] - 2025-04-25

### Fixed

- [UpgradeFinder] Having a shirt equipped won't cause an error anymore.

- [Progress] Raid progress is now properly saved and re-applied on login.

- [SearchPanel] Opening the questing or custom categories won't create an error for specific groups anymore.

- More code changes to split off the custom upscaled images into an own addon to keep the main addons filesize low.



## [3.4.0] - 2025-04-24

### Added

- The new [Journal] has been implemented, accessible via the "Journal" tab at the bottomright of the mainframe.
    Here you can select an instance (boss and difficulty optional) and see all the loot that drops.
    - Similar to the normal Adventure Journal you can change slot and class, but in addition you can filter for mounts, recipes, tokens and for specific armor types.
    - You can also just search for items by name! The search is currently limited to current activities only (so everything in the current expansion), due to performance reasons.

- [Progress] The honor level and the honor level progress have been added to both the main [Progress] tab and the inner PvP frame.

### Changed

- Over the next few versions I'll switch some settings from account to character-specific.
The saved app dialog texts, last used queue and last group are now character-specific.

- [Progress] Whenever weekly progress data updates (after a key, logging into a character after the weekly reset) all data will get updated.

- [Lockouts] All lockout data is now integrated into the [Progress] tab.

### Fixed

- [Progress] The selection border of the currently selected keystone will disappear if you decide to hide a M+ dungeon.

- [Progress] The keystone score calculation should now show the correct score gains.

- [Progress] Current raid progress data in the overview panel won't be overwritten by old data anymore.

- [Progress] Performance fixed when opening the frame on a character for the first time in a WoW session.

- [UpgradeFinder] All items should now instantly load without having to re-click the slot icon.

- [LiteMode] Opening any category won't try to load the UpgradeFinder.

- [LiteMode] The class panel is now attached to the Dungeons & Raids frame.

- [MainFrame] Trying to open the queue dropdown in 11.1.5 won't result in an error message anymore.

### Known issues

- Group itemlevel, durability and enchant data isn't getting transmitted between players.
This has been the case since 11.1.5.
A fix is in the works, probably coming with v3.4.2 or v3.4.3.



## [3.3.0a] - 2025-04-13

### Fixed

- [UpgradeFinder] Clicking on an empty slot won't create an error anymore.

- [UpgradeFinder] Clicking on an offhand slot while you have a mainhand equipped will now show.



## [3.3.0] - 2025-04-13

### Added

- [UpgradeFinder] has been implemented, accessable via the new tab at the bottom of the mainframe!
Find upgrades (itemlevel only) by clicking on the item slot you want to find upgrades for.
Shows the icon, itemlevel, name, difficulty and where to find it.
Currently world bosses, raid and M+ are supported, other sources like crafting are getting implemented with the next update.

- [Progress] All activities in the panels can now be hidden/shown via the dropdown menu in the topleft.
This saves between reloads/relogs.

- [Progress] A new background has been added for both the [MainFrame] and the [Progress] frame world vault background.

- [ClassPanel] Group comp text has been added to the left of the class panel, showing you the # of tanks, healers and damager in your group.

### Fixed

- [Progress] Hovering over the M+ keylevels won't cause a tooltip error anymore.

- [Progress] Itemlevel data will now get updated correctly.

- [GroupManager] The indepth inspection panel won't overwrite your chars data with your mains data.

- [GroupManager] The indepth inspection panel will now correctly use the newest raid id while checking your main's data.

- [MainFrame] The raid finder queues are now sorted first by raid name and then by their wing index.

- [Lockouts] The checkmark icon when you fully cleared an instance will now be on the top layer, not clipping into the underlying frame.

- Hiding the mainframe via the micro menu button or the 'i' (default) hotkey while having the PVP queue selection open won't show the default blizzard reward icons anymore.

### Known issues

- [UpgradeFinder] Depending on the class and spec not all loot gets fully loaded after clicking a slot.
You currently have to re-click the slot one more time.
After that all slots should load all the items right away.
This issue is fixed in v3.3.2.



## [3.2.9] - 2025-03-26

### Added

- [Progress] Solo Arena and Solo BG have been added to the PVP progress panel.

- [GroupManager] Leader, main assist, assist and main tank icons are now shown in the standard group list on the left side of the ready check status.

### Changed

- [Gearing] The gearing table has been updated, individual columns can now be enabled/disabled.
Cells now have a background that distinguishes them more from the background.
Gearing item level data has been corrected and bountiful delves and enchanted weathered crests have been added to the table.
Gearing data item level calculation has been improved and simplified for upcoming season data.

- [ClassPanel] The class panel has been slightly redesigned.
Classes that aren't in your group have their icon reduced in size.
The number font size in the class and the spec frames has been increased.

- [Progress] The tier icon that indicates the next tier for the character is now only being shown if the character has atleast a single rating point.

### Fixed

- [Progress] The spec icon of characters on the overview page now gets correctly updated when switching specs.

- [GroupManager] There should be no more system messages when players join or leave the group and a atleast one player in your group is offline.

- An issue has been resolved trying to request bnet account info before the data was loaded.

- A error message is shown when you try to requeue for any PVP queue (since Blizzard doesn't allow queueing up for those queues with just 1 click and without their PVP dropdown frames).

- The event category in the queue dropdown now gets hidden if there are no active event queue available.

### Upcoming

- [Progress] PVP conquest progress bars added to the overview characters.

- [Progress] Hiding specific activities



## [3.2.8] - 2025-03-19

### Added

- [SearchPanel] A small (togglable) panel has been added on the right side of the application box that pops up when you signup to a group.
There you can set different signup text and manually copy them into the box.

### Fixed

- [SearchPanel] Upon switching search panel categories (e.g. dungeons to raid, raid to questing, etc.) the text field will now get wiped.

- [SearchPanel] The search panel won't try to iterate through the boss frames in any other category other than raid.

- [GroupManager] Gear data from players will now update correctly.

- [Progress] The keystone time calculator algorithm has been adjusted / corrected.

- All elements that are sortable will now correctly transfer their state into the MIOG settings (was previously not the case when > 2 options were active and you disabled one of them).



## [3.2.7a] - 2025-03-16

### Fixed

- Deleted a debug print.



## [3.2.7] - 2025-03-16

### Added

- Fractured Sparks of Fortunes have been added to the currency tracker in the mainframe.

- Added a communication library for future features.

### Changed

- To combat the longer list of currencies all currencies now only display the amount left to earn in parentheses.
Color-coded with red if nothing is left to earn this week or green if you still have some currency left to earn.

### Fixed

- [ApplicationViewer] The progress panel will now correctly be populated with data.

- [GroupManager] Showing indepth data will now correctly use the chosen player's realm instead of your own.

- [Progress] The vault status icon now gets when looking at the PVP overview.



## [3.2.6] - 2025-03-13

### Added

- [Progress] An icon in the center and status bars have been added to each character to see their current vault status.

- [Lockouts] A checkmark icon now shows up when you've fully cleared a dungeon/instance.

### Changed

- Switched out the main font I used for one that's easier on the eyes.

- [GroupManager] The raid manager's groups have been separated more to directly see where the individual groups start and end.

- [Progress] The graph has been disabled for now while I deal with some Blizzard season problems.

### Fixed

- When queueing for multiple dungeons from the queue dropdown the tooltip will now show all dungeons you queued for instead of the one it got the most recent info.

- [GroupManager] More improvements to the inspection algorithm.

- [GroupManager] Players won't be stuck with an incorrect unitID anymore, now their tooltip gets updated correctly.

- [GroupManager] Players' keystone data won't randomly disappear anymore.

- [Progress] The lags that occured when first opening the [Progress] tab has been eliminated.

- [ApplicationViewer] The title of the group listing is no longer clipping into the group composition text.

- [ApplicationViewer] Players with multi chested keys won't cause a LUA error anymore when hovering over them.

- [GroupCreation] Multiple errors have been resolved when trying to queue with a character that is too low level to use premade groups.

- An error has been resolved if the RaiderIO addon isn't active.



## [3.2.5] - 2025-03-11

### Fixed

- RaiderIO raid data retrieval has been optimized. Everything that pulls this data (group manager, search panel, etc.) will see big performance improvements and therefore less lags.

- [SearchPanel/ApplicationViewer] Changed the algorithm for the raid progress calculation, now someone with 4/8H LOU is higher rated than someone with 4/8M NP.

- [GroupManager] Improved the inspection algorithm further, less unnecessary function calls = less lags.

- [MainFrame] Slimmed the individual currency frames down even further so now it shouldn't push them beyond the currency box. Well maybe if you have > 999 of every crest later in the season, idk.

### Known issues

- [GroupManager] The keystone data sometimes gets deleted for no reason / gets assigned to the wrong name.
This is fixed in v3.2.6.




## [3.2.4] - 2025-03-07

### Fixed

- [MainFrame] ReQueue groups are now visible again.

- [Progress] Keystone data for the keystone dropdown now always get properly populated.

- [SearchPanel] Bosses that have been defeated but have also an alternative name (Vexie and the Geargrinders / The Geargrinders) will now be more reliably detected.

- [SearchPanel] All unused boss frames will now be hidden when switching categories from "Raids - Legacy" to "Raids".

- [SearchPanel] By default all bosses are assumed to be alive (in the past groups seemed to be fully cleared without any encounter defeated info).

- [FilterPanel] Bosses that have been defeated but have also an alternative name (Vexie and the Geargrinders / The Geargrinders) can now be more reliably filtered out.



## [3.2.3] - 2025-03-07

### Changed

- [Progress] The character frames in the Overview panel now have a new design to make it more WoW-like.

- Updated the Open Raid library.

### Fixed

- [SearchPanel] Switching between the raid categories and any other categories won't create lag anymore (at the cost of a bit more memory).

- [GroupManager] The raid manager is visible again.

- [GroupManager] Re-enabled checks for missing gems / enchants.

- [GroupManager] Fixed my name retrieval function so the ready checks should be properly recognized now.

- [DropChecker] Liberation of Undermine is now properly implemented and shouldn't cause an error anymore.

- [FilterPanel] The progress panel beneath the filter panel now gets hidden when opening the DropChecker.

### Known issues

- [SearchPanel] Sometimes the first boss "is defeated" data doesn't get sent by Blizzard / doesn't get recognized by MIOG.
This will be fixed in v3.2.4.



## [3.2.2d] - 2025-03-05

### Fixed

- [MainFrame] The addon's frame strata has been changed so it is infront of all other UI elements just like the standard Blizzard frames.

- [SearchPanel] The dungeon's abbreviation has been added to the progress panel frames.

- RaiderIO dungeon data order should now be correct again.



## [3.2.2c] - 2025-03-05

### Fixed

- [MainFrame] The currencies will stay in their frame like I asked them to.

- [GroupManager] There shouldn't be character name retrieval problems anymore when you're fresh out of a loading screen and in a group.

- [GroupManager] There shouldn't be a 3 to 4 line long progress indicator anymore.



## [3.2.2b] - 2025-03-05

### Fixed

- [GroupManager] Progress data will now be visually split between NP and LOU progress.

- [GroupManager] Ready check status will now be correctly updated on all group members.

- [GroupManager] After clicking on a sort button the group manager will correctly update the visual data.

- [ApplicationViewer] Pressing the refresh button will now scroll to the beginning of the list instead of erroring out.

- LOU / NP progress in the [GroupManager] and [SearchPanel] progress panel will now be correctly attributed to the correct raid.



## [3.2.2a] - 2025-03-05

### Fixed

- A few debug prints left in the code have been deleted.

- Liberation of Undermine boss icons in the [GroupManager] and [SearchPanel] progress panel are now not just some red squares.

- [Progress] The achievements for Liberation of Undermine are now properly being tracked.

- [ApplicationViewer] Factions will now be correctly recognized again.

- [GroupManager] ALL raid manager frames will now be correctly be shown instead of only 4 of every group, lol.



## [3.2.2] - 2025-03-04

### Added

- The currencies in the mainframe have been updated to season 2.

- The background images for the season 2 dungeons and raid have been updated.

- The addon is tracking the vault rewards for all characters in the background.
This will be part of a graph in v3.2.3 to track all chars individual progress of all vault categories.

### Changed

- [GroupManager] The raid manager frames have been re-enabled, the performance issues should be resolved.

- [GroupManager] The character's guild line has been removed, because the retrieval of guild info has been flaky at best.

- [GroupManager] All members in the normal list are now visually separated.

### Fixed

- Lite mode has been updated / fixed for 11.1.

- Thanks to the new Blizzard performance meters for addons I switched some things around and MIOG's startup lod times have been reduced by a factor of 3.

- [GroupManager] Altered the inspection algorithm, should be more reliable and less performance intensive.



## [3.2.1] - 2025-02-27

### Fixed

- [GroupManager] Fixed several performance issues. Should be less laggy now when people join your group and you have the group manager open and only small lags when having the group finder not open.

- [Gearing] The gearing itemlevel chart has been updated.



## [3.2.0a] - 2025-02-26

### Fixed

- [SearchPanel] Group listings can now be expanded again.

- [GroupManager] There should be no more error when hovering over Brann in the group manager when you're in a delve.



## [3.2.0] - 2025-02-26

### Added

[Progress] now has an overview panel.
There you'll see your 5 most played characters and their m+/raid stats listed.
The addon saves your weekly progress for m+/raid and you can view the progress via the graph in the bottom left.

Right now it's very barebones but I wanted to update the addon before 11.1 comes out (but I will hotfix everything quickly this week after the patch goes live).

If you sometimes swapped to this page to check your progress while being in the group finder (to check your keys done, boss killed on this char, etc.): a comprehensive list of your current progress will be listed below the filter settings.

### Changed

- [SearchPanel] The "no groups found" overlay now also triggers when your filters filter all available groups.

- [GroupManager] Updates now only occur when the manager is visible and it's performance has been increased by swapping to the new frame gen method.

- Many background changes have been made for upcoming features released before 11.1.

### Fixed

- [Progress] An error preventing RaiderIO progress data loading for first time users has been resolved.

- [Progress] Characters that haven't been logged in for a while will now also populate the dungeon level rows correctly.

- [Progress] Fixed a rare error where sometimes the raid progress data would not load up correctly (because I have to manually parse it since Blizzard doesn't provide ANY progress data for anything but your own char).

- [SearchPanel/ApplicationViewer] When switching to the "Last invites" panel and then /reload'ing or relogging the filter panel won't automatically be open upon opening the SearchPanel/ApplicationViewer.

### Known issues

- [SearchPanel] When opening the "Raid" category and then switching to the "Dungeon" category there is a small lag. This happens because data in the background gets loaded during this moment.
This will be fixed in v3.2.2.

- [GroupManager] The raid manager window does not show any player frames. This is currently disabled because of lags happening when new players join the group.
I have a rough idea how to fix it, this will be fixed in v3.2.2 or v3.2.3.

- [Gearing] The chart will be updated with season 2 data this week.



## [3.1.4] - 2025-02-10

### Changed

- [SearchPanel] Sorting algorithm improved, lag after sorting decreased.

- Anything list that can be sorted (e.g. group finder, application viewer, etc.) now retains its scroll position after sorting (if possible).

### Fixed

- [ApplicationViewer] Decreased the amount of lag sorting a big list of applicant creates.

- [SearchPanel] The number of current listings in the footer bar of the search panel doesn't get updated anymore when switching from the search panel to another tab.

- [Progress] The lag created by switching to the raid progress tab has been eliminated.



## [3.1.3a] - 2025-02-06

### Fixed

- [ApplicationViewer] Changing the group leader won't cause an error anymore.

- [ApplicationViewer] Hovering over an applicant will now correctly show the tooltip.

- [GroupManager] Hovering over the indepth window without having selected a player won't cause a LUA error anymore.

- Recognition of player specs in your group should now work way better.



## [3.1.3] - 2025-02-05

### Changed

- [ApplicationViewer] The application viewer's frame system and much of its core code has been updated to the same one the search panel now uses.
There should be almost no lag even when hundreds of players would apply at the same time.
Before computing 100 applicants created > 1 second of lag, now it takes just around 0.1 to 0.2 seconds, barely noticable.

### Fixed

- [GroupManager] The spec icons of characters should now be updated when the data arrives.

- [SearchPanel & ApplicationViewer] RaiderIO data will now be correctly set, even if they have a corrupt comment, lol.

- [SearchPanel] The leader's best dungeon run level will now be shown again.

- [SearchPanel] The number of listings at the bottom of the search panel should now update correctly again.

- [ClassPanel] The class panel will now correctly work in lite mode.

- [Progress] The progress tab will not try to fetch data from the previous season anymore when a new season has started.

- [Progress] An error has been fixed that tried to update the weekly rewards when the progress tab hasn't loaded all activities yet.

- An error trying to fetch raid data right when the game gets started without any cached data available has been fixed.

### Known issues

- [SearchPanel & ApplicationViewer] The sort buttons create some smaller lags when clicked on.
This comes from the fact that I use the new frame gen code with the old sorting code.
This will be fixed in v3.1.4 or v3.1.5.

- [GroupManager] The name of a character will sometimes get stuck even though MIOG already has the spec data.
This will be fixed in v3.1.4.



## [3.1.2] - 2025-02-02

### Changed

- [SearchPanel] Switched out the old code for the listing frame generation and implemented the new method I use almost everywhere else.
The search panel should now be lagfree.

### Fixed

- [EntryCreation] The "Faction only" checkbox in the group creator doesn't hover over the "Back" button anymore.

- All relevant PTR data has been added for the new dungeon and the new raid.

- The queue dropdown and the dropdown list can't be clicked through anymore to avoid signing up for group when you don't hit the queue "button"

- Updated the Open Raid library.



## [3.1.1] - 2025-01-28

### Added

- [GroupManager] You can now click on any character in your group and view their M+ and raid progress aswell as more general info.

- General data for 11.1 has been implemented.
PTR should now work more reliably with this client.

### Fixed

- [GroupManager] Ready check status now actually works.

- [GroupManager] Player spec should be constantly visible in the raid frames.

- Any raider IO data relating to a player's main character now gets correctly parsed and shown.

- Dungeons and bosses that haven't been completed yet by a character will now be desaturated in all raider IO panels.



## [3.1] - 2025-01-22

### Added

- The "Party" tab in the mainframe has been redesigned and the new group manager has been implemented!
You can switch between these views in the topright corner in the "Party" tab.
The standard view is similar to the old one but the new features are:
    - A refresh button has been added near the topright corner to try to refresh and add missing data for players.
    - Character players have a "Ready" box at the end of the line, indicating if they confirmed the ready check or not.
    - In the topright corner a "Ready status" box has been implemented showing if the whole party/raid is ready.

The new view integrates the raid manager from the social menu ('O' key shortcut).
    - [This feature will be implemented with 3.1.1] You can click on a party/raid member and view detailed infos about their character, M+ and raid related.
    
### Changed

- The [PartyCheck] tab has been renamed to [GroupManager].

### Fixed

- [SearchPanel] The autocomplete frame will now be in the toplayer of the frame so it doesn't get hidden by the "No groups found" overlay anymore.

- [GroupManager] Multiple tooltip layout errors have been fixed.

- Multiple performance issues have been fixed regarding party / raid member updates.
There should be SIGNIFICANTLY less random framedrops when data of players is being requested.

- Updated the OpenRaid library and deleted some old files.



## [3.0.15] - 2025-01-19

### Changed

- The currencies in the mainframe are now located at the bottom of the frame, similar to Blizzards design.

### Fixed

- Currencies that don't have a maximum quantity (e.g. crests) won't be formatted as if they would have a maximum quantity.



## [3.0.14] - 2025-01-15

### Added

- [MainFrame] Plunderstorm queues have been added to the PVP submenu in the queue dropdown.

- Lots of stuff for upcoming features has been added in the background.

### Fixed

- [FilterPanel] Resolved an error where an algorithm tried to access the filter panel before it had been initialized.

- [RaiderIOInfoPanel] The boss frames showing the actual progress are now permantently visible again.

- Small performance improvements.



## [3.0.13] - 2025-01-06

### Fixed

- [Active queues] Decreased the amount of data that gets refreshed, resulting in a small performance bump.

- [Active queues] The cancel button will not disappear anymore when you have had a manually listed group in the group finder.

- [DropChecker] The search for items will now start at a single character entered instead of two.

- [Options] The "Classic" background option is once again available.

- [ApplicationViewer] The app viewer won't jump into the foreground anymore if the leader edited the listing / relisted the group.

- Renamed the "Statistics" tab in the mainframe to "Progress" since there's a lot of change incoming over the next two months and this fits more :).



## [3.0.12] - 2024-12-27

### Changed

- [MainFrame] Transitioned the queue dropdown to Blizzard's new menus.

- [MainFrame] The requeue button and the cancel buttons on the queue frames have been updated.

- [FilterPanel] When a class/spec filter has been changed the class row will now have a white border to make it visually clear that a filter is active.

- [AdventureJournal] The journal has been disabled temporarily.
The base idea is good, showing you the difference between all difficulties without switching between them and having a M+ keylevel scalar integrated but it currently only works when the text is 100% the same except the number.
This feature will be re-enabled in v3.1.0.

### Fixed

- [ApplicationViewer] M+ applicant entries will now show the correct completed keylevel for your listed dungeon again.

- [FilterPanel] An error regarding spec filtering has been resolved.

- [MainFrame] The activity icons in the queue dropdown will now always be correctly set to the actual file ID.

- [GroupCreation] The dropdown text will not reset to "Classic" anymore when you have already selected an activity.

- [GroupCreation] Dragonflight raids's difficulty can now be changed without having to create a group and edit it right after.

- The addon will now check for less data in the loading process, resulting in a faster loading screen.
Probably only really noticable on slower machines.



## [3.0.11] - 2024-12-20

### Fixed

- [MainFrame] Opening and closing the mainframe will not regularly cause huge lags to happen.

- [MainFrame] The PVP queue selections are visible again.

- [SearchPanel] Opening the search panel for the first time in a game session will no longer cause a huge lag to happen.

### Known issues

- Some backgrounds in the [Active queues] part of the mainframe don't show up.
This will be fixed with v3.0.12.



## [3.0.10] - 2024-12-18

### Fixed

- Many problems that 11.0.7 introduced have been fixed already.

### Known issues

- Opening up the group finder for the first time in a session might have some serious lag and subsequent openings have a little bit of lag.
This will be fixed in v3.1.0, haven't investigated what's up with that.



## [3.0.9] - 2024-12-16

### Added

- You can now choose the seasonal dungeons in the "Specific" queue dropdown options.

### Changed

- [MainFrame] The queue dropdown now indicates if any category has options to select via an arrow.

- Updated for 11.0.7.

- Many background code changes have been made to improve performance for v3.1.0 an onward.

### Fixed

- [MainFrame] When trying to change from "Bonus" to "Specific" battlegrounds in the PVP queue dropdown category no more errors should appear.



## [3.0.8] - 2024-12-04

### Added

- [Group creation] The name of the current selected category has been added to the top of the group creation frame.

### Changed

- [Group creation] The dropdowns have been changed to Blizzard's new dropdowns.
Relevant code changes in the background have improved memory management (unless you spam click the dropdowns 5 times a second, then it's worse)

### Fixed

- [Group creation] Amirdrassil should now have the correct background image.

- [MainFrame] An error that happens when an update for WoW has been installed and the client has no cached data yet has been resolved partially.
Will take till the next update for it to be fully resolved (currently rewriting that code for better performance and logic).



## [3.0.7] - 2024-11-24

### Changed

- Updated A LOT of backend code to match Blizzard's file system names and folders.
Means a less bloated and more reliable addon, 100% coverage of backup files (e.g. new dungeons and I haven't finished the photoshop/upscaling of the background images), etc.

### Fixed

- [RaiderIOPanel] Bosses should now always have an icon set.

- [SearchPanel] When MIOG requests member data of a listing right after a /reload the sorting of members should no longer in very rare cases cause an error.

- Increased performance of certain parts of code.

- Updated the open raid library.



## [3.0.6] - 2024-11-16

### Changed

- [SearchPanel] There won't be a loading spinner / delay before all search results have been updated with the correct data.
It will now update every group .5 seconds after the first groups have shown up.
Blizzard sends search result data usually twice (except for rated BG's), the first one includes most of the data, the second one usually all of the data.

### Fixed

- [SearchPanel] Improved performance.

- [SearchPanel & ApplicationViewer] The footer bar number that shows applicants/search results should now update correctly and not show applicants in the search panel or vice versa.

- [SearchPanel] The "Enter a key range" help tooltip will not show up anymore.

- [FilterPanel] The reset button will now correctly reset the current category (e.g. dungeon, legacy raid, rated bg's).

- [Statistics] Great vault tracking should now also work if you're exactly at the threshold of the slot, e.g. you've done exactly 1 Dungeon or 2 delves or 4 bosses, etc.

- Improved addon load time (leads to a shorter loading screen when logging in).



## [3.0.5] - 2024-11-13

### Fixed

- [SearchPanel] Checks for both class and spec data are now more tight since for some reason there might be some data missing in the first few calls to retrieve data.

- [GroupManager] There will now be a check if the keystone data contains a character name (usually should but on very rare occassions it doesn't).

- [ReQueue] When logging into a different character the saved groups will now get wiped.

- [GroupManager] Switching to the GroupManager tab will now always refresh the class bar at the top of the frame.



## [3.0.4] - 2024-11-08

### Fixed

- [Statistics] The great vault "timer" will now use a different timing method to make it usable for all of eternity.
It functioned somewhat correctly for the current vault period but won't work for future ones correctly.

- [FilterPanel] When converting my rating filters to Blizzard's rating filters it will now check if the rating checkbox is checked or not



## [3.0.3] - 2024-11-06

### Fixed

- [ReQueue] Disabled an extra check for search results which kept deleting the saved groups in certain situations.

- [ReQueue] Added a code block that will always delete groups that can't be found anymore if you got the data inbetween you requesting the data and the group disappearing.

- [SearchPanel] Recoded some of the member count algorithm to fail-over to the class icon if for some reason Blizzard doesn't send spec data of the group listing when requesting it.



## [3.0.2] - 2024-11-05

### PSA

- [ReQueue] You should always be <= 100 results AND use the same filters for the feature to reliably work.
E.g. you have a group from the 101-200 result range and now you search for a different key range: the original result might not be in your new results, thus the feature can't check for the saved group ID.

### Changed

- [FilterPanel] Added 2px spacing between all option rows to increase readability.

- [FilterPanel] When a class/spec option has been changed from it's default state it will now glow brighter to increase readability.

- [ReQueue] When the popup is shown after a /reload or quick logout and login it will not ask you to refresh the data, since it bugs out.
You can still try to apply to all the saved groups.
This depends if the groups have been re-listed and on the text you've entered into the searchbox / your filters.
Unfortunately there is no real workaround unless Blizzard removes the security on the SearchBox (you can't manually set text of the searchbox because of the WTS group and stuff).

### Fixed

- [ReQueue] After you try to apply to a group and it gets saved it should instantly update in the "Active queues" panel (since it technically isn't an application it didn't force an update which I now manually do).

- [ReQueue] The buttons at the bottom now actually fill out the whole "row".

- [ReQueue] The popup buttons now give auditory feedback.

- [FilterPanel] The popup buttons now give auditory feedback.

- [FilterPanel] The popup now has the "Dismiss" button in the bottom left and the "Cancel" button in the bottom right

- [SearchPanel] Group listings with 4 people that get a 5th person while you're trying to search for new listings shouldn't cause an error anymore.



## [3.0.1] - 2024-11-03

### Changed

- [ReQueue] The feature will now retrieve the groups you've tried to apply to in order of your signups.

### Fixed

- [Statistics] Raid and PVP panels are accessible again.

- [FilterPanel] Lowered the amount of lag the filter panel produces.
Lags on first open or switching search panel categories and then opening the panel still causes big lags.



## [3.0.0] - 2024-11-03

### Added

- The new [ReQueue] feature has been added!
You can now "apply" to more than 5 groups at a time!

How this works:

When you are at the maximum of 5 applications the addon saves data from the group you've tried to apply to.
Then when one of the 5 groups declines you / gets delisted a popup will show up asking you to refresh the search panel.
Then the addon asks you if you wanna apply to the next group.

The refresh is only required if you applied to a group since the last refresh, so if you apply to 10 groups and then you just play the game after the first refresh you won't have to refresh anymore.
While I would like for this to be simpler I have to go through some hoops to get this to work.
These groups will be saved between /reloads or quick relogs.

There are three new settings in the interface options for this feature:
1. "Apply popups", by default enabled. This setting let's you enable/disable the feature.
2. "Clear fake apps", by default disabled. When an "queued application" has been blocked by a filter it gets cleared automatically since it's not a real lfg application and doesn't break anything on Blizzard's side.
3. "Flash client icon", by default disabled. If you are tabbed out of the game but still want a reminder to queue for the next group you can enable this feature.

Enjoy.

### Fixed

- [RaidSheets] There will be no error anymore trying to access player frames when no frames have been created yet.

- [SidePanel] When trying to open the filter / last invites panel as a new user, it will now actually open the sidepanel instead of producing an error.
 
### Known issues

- [FilterPanel] There is a huge lag / loading of settings happening when opening the panel the first time or after you opened the "Last invites" panel, /reload or relog and then open the panel.
This will be fixed in 3.0.1.



## [2.9.6a] - 2024-11-01

### Fixed

- Enabled checks for a new addon of mine that I forgot to check if the addon is loaded.



## [2.9.6] - 2024-11-01

### Changed

- Updated backend code to lower the amount applications and any queue update the "Active queues" panel.

- Disabled the RaiderIO Checker panel for now, has to be remade completely, I hate it.

### Fixed

- The filter panel's input options (e.g. rating, age) will not overwrite settings in other panels anymore.

- [MainFrame] The mainframe will now be actually hiding and showing itself depending on whether it was open or closed before combat had been initiated.

- [MainFrame] The great vault dungeon bar will now show all completed runs that count for the vault instead of just the ones of the current slot.

- [SearchPanel] There shouldn't be anymore errors while trying to sort the members of a group.

- [RaiderIO InfoPanel] The server data will now be refreshed correctly.



## [2.9.5] - 2024-10-27

### Added

- [Statistics] An icon for each character has been added to indicate:
    1. If they currently have a reward from the great vault waiting for them
    2. If will have a reward from the great vault waiting for them the next week
    3. If they haven't completed any activity for a great vault slot

This data gets refreshed on every login and on a completion of a weekly reward goal.

- [MainFrame] When the mainframe has been hidden due to getting into combat it will be shown again after combat.

### Fixed

- [MainFrame] The great vault bars tooltips have been updated/corrected.



## [2.9.4] - 2024-10-24

### Changed

- The statistic panels (m+, raid and pvp) have been consolidated into a single tab to make room for more tabs.

- The "Lockouts" tab has been re-added to the tabs at the bottom of the frame.

- [SearchPanel] Lowered the "cooldown" of searching too often by 0.5 seconds.

### Fixed

- [FilterPanel] The transparent foreground frame that blocks the filter panel when you are in a non-filter panel frame is now shown again.

- [FilterPanel] The reset button should now work again.

- [InterfaceOptions] There shouldn't be any more errors about groups that haven't been filtered when opening the lfg statistics.



## [2.9.3] - 2024-10-23

### Added

- [DropChecker] Added filters for the loot so you can check for world boss, BRD anniversary and non-seasonal dungeon loot.

### Fixed

- [GroupManager] Being in a party where many members join and leave shouldn't create errors anymore.

- [Active Queues] "The Codex of Chromie" will not cause an error anymore (and for that matter no other coming events that are not yet implemented will).

- [Queue Dropdown] Raid finder wings from different raids will now be listed under the same raid.

- [DropChecker] Current seasonal dungeons will not request the loot twice.



## [2.9.2] - 2024-10-23

### Fixed

- Added the new Blackrock Depths raid to the data.

- [FilterPanel] There shouldn't be any more errors when Blizzard doesn't send all the class/spec data for the group listing.

- [SearchPanel] There shouldn't be any more errors when Blizzard doesn't send all the class/spec data for the group listing.



## [2.9.1] - 2024-10-22

### Fixed

- The new raid sheet feature won't prolong the loading time of the addon anymore.

- [RaidSheet] Dragging a character and releasing it above it's old space will now correctly set it to this space again.

- [GroupManager] Changed the algorithm for detecting the unitID back to my version instead of using Blizzard's, mine is more reliable.



## [2.9.0] - 2024-10-20

### Added

- [RaidSheets] have been added!
You can now plan your raid comp right ingame.
Drag and drop players from your guild into the slots and hover over them to "give" them a spec (and a role by that extension).
Right-click the character frames or drag them out of the spot and drop them anywhere that's not a raidspot and they get reset.

You can create as many presets as you want and the settings get saved everytime you make a change.
They are saved for the whole account but only loaded if you're in the guild where you have created the preset.
This way you can't overwrite data but still have access to it without WoW needing to copy all the data around to every single char you have.

You can search for specific guildmates in the topleft corner.


### Changed

- [SearchPanel] Implemented the new sorting method that was already active for [GroupManager] and [ApplicationViewer]

- [Lockouts] This frame has moved to the "More" dropdown menu in the title bar.

### Fixed

- [ApplicationViewer] Fixed the width of the name of applicants so the friends icon will not be under the accept button anymore.

- [M+ Statistics] Overtime keys that have a higher score than your intime key score will now correctly show up instead of the intime key.

- [Raid Statistics] The number of bosses in the instance should now be shown on characters with valid raider io data.

- [Options] The lfg statistics are now alphabetically ordered and have now subtypes (e.g. "Applied" and "Delisted" refer to the SearchPanel while "Keys aborted" refers to M+ keys)
This will make it way easier to sort and sub-categorize them later on.



## [2.8.0] - 2024-10-13

### Added

- The interface options now have LFG statistics.
Wondering how many times you have been declined from groups? Now you can find out.
For now it's only the app status that gets captured or the filter reason if you manually cancel an application.
But to be honest I can capture basically anything, and I probably will just sneak in additions into most version updates.

- [SearchPanel] Right-clicking the search panel groups now opens a menu just like the normal search panel where you can whisper the leader, report the group, etc.

### Changed

- [Statistics] All statistic panels have now been updated to use the same code foundation to make bugfixing easier and to streamline the UI.

- [Statistics] All statistic panels now request data for each of your characters on your account that has atleast a single currency (note: money, e.g copper, silver, gold does not count for this restriction).
This works retroactively, you do not need to log into each of your characters (which you will probably do anyway but just saying).
Before warbands there was no known method (atleast known to me) to do this.

- [Statistics] The raid and the M+ panels will now update data for all characters except your currently logged in from RaiderIO if you haven't logged into them since the update of this addon.

- [Statistics] The first character in the list will always be the one you are currently logged in.
The following characters will be sorted by score for M+, progress for raid and rating for PVP.

- [Statistics-MythicPlus] The score calculation has now been updated!
Took 2 days to figure out the algorithm but now it should correctly calculate the new score.
Also the slider now goes from -40% to 40%, so you can see how much score you'd get if you got the key done even over time but still within 40% over time.

- [MainFrame] Changed the currency info if the currency has no seasonal maximum you could exceed (e.g. valorstones and catalyst charges have maximums but they're not seasonal maximums).
 
### Fixed

- The raider IO info panel will now correctly show keylevel bracket data, e.g. amount of keys done in 2-3, 4-6, 7-9, etc.
Though right now RaiderIO seems to have a bug that doesn't correctly transfer any keylevel bracket except the 4-6 bracket into the downloadable databases (what you update through CurseForge or the RaiderIO client).

- [FilterPanel] Clicking the checkbutton infront of the Difficulty dropdown will now activate the filter immediately instead of only after a new search.

- [FilterPanel] Legacy raids should now correctly show up again.

- [FilterPanel] Re-implemented right-clicking the bossframes to reset them.

- [GroupManager] The character tooltip now displays the keystone dungeon name aswell as the level.

- [GroupManager] Split up some methods for the spec, keystone and progress detection, should lag less when new people join the group.

- [GroupManager] Fixed the width of certain elements of a character frame, now it shouldn't cut off the text anymore.

- Cleaned up old files and code, should improve load times of the addon on lower end machines a bit (we're talking still sub-seconds of loadtime improvement though)



## [2.7.0] - 2024-10-01

### Added

- If a group does not match your set filters anymore (all dps slots full, tank left and your filter is set to atleast 1 tank, etc.) there will now be a popup where you can cancel the app immediately and switch to the search panel.
There are still some issues with this and the visuals aren't fully fleshed out yet.
For now it is an optional toggle in the settings menu.

- [SearchPanel] Delves now have an icon.

- [SearchPanel] Specific quests and world quests now have an icon.


### Changed

- [FilterPanel] Recoded the entire filter panel to make it easier to implement new filters / change something about current filters.
Also squished alot of bugs where the logic was too convoluted to understand where I went wrong.

- [FilterPanel] All filter options now have a tooltip to explain what the option does.

- [FilterPanel] Boss frames' size in the raid category have been increased to better see what boss setting you are changing.

- [FilterPanel] MIOG's filter now correctly pass over to the Blizzard dungeon filters.

- [ApplicationViewer] Switched over to the new sorting algorithm. Enjoy faster sorting and more than 2 sort methods at once.


### Fixed

- [ClassPanel] Lowered the frame strata so the Blizzard tooltips are visible.

- [SearchPanel] Selecting a different group will now "deselect" the group you've selected before (just a visual change).

- Created a workaround for a bug in Blizzards Search Panel where sometimes the search result list doesn't get populated correctly when you do a /reload and right after the loading screen the search panel tries to update itself.

- Decreased the memory and cpu requirement that comes with computing all group info you get when using the search panel and any active filter.

- The queue selector dropdown will now also show category types that only have a single entry, e.g. only 1 event currently active.


### Known issues

- [M+ Statistics] The keystone dropdown doesn't correctly refresh with party data. This will be fixed in 2.7.1 or 2.7.2.



## [2.6.2] - 2024-09-20

### Added

- [MainFrame] Catalyst charges have been added to the currency information.

- [MainFrame] The queue dropdown now has an extra section just for event queues (like Coren Direbrew and the Random TW dungeons).



## [2.6.1] - 2024-09-19

### Fixed

- Deleted a debug print out.



## [2.6.0] - 2024-09-18

### Added

- Delve background images have now been added.

### Fixed

- [Raid statistics] Changed the raid stat check from awakened raids to regular raids so Nerub'ar Palace's stats show up correctly.

- [M+ statistics] Changed the order of some code so it won't color the keylevel red when you infact have a key of the same or a higher level timed.

- [ApplicationViewer] The role count in the topright corner should now show the correct count again.

- [GroupManager] Keystone info now gets populated correctly.



## [2.5.9] - 2024-09-18

### Added

- Implemented the Delves category. 
Background images for the delves will be implemented with v2.6.0.
Gonna investigate if I can check for delve completion and the level of it to display some "progress data" in the app viewer and search panel.

### Fixed

- [FilterPanel] The filter should now catch if you have set a minimum and maximum amount of damagers and no link with another role is active.

- [MainFrame] Hovering over the "Bosses" great vault bar in the topright will not cause an error anymore when you have killed a story-mode boss.



## [2.5.8b] - 2024-09-18

### Fixed

- [MainFrame] The weekly Xal'atath affix will now be shown in the mainframe.

- [GroupManager] There will be no more errors when joining a group and getting their spec info right away due to Blizzard being a merciful god.



## [2.5.8a] - 2024-09-18

### Fixed

- [SearchPanel] There won't be a check anymore for a mapID in categories that don't have them.

- [SearchPanel] Pressing the signup button accidentaly before selecting a group won't bug out the search panel anymore.



## [2.5.8] - 2024-09-18

### Added

- [MainFrame] A tooltip has been added to the string beside the character panel at the top of the frame for clarification.

### Changed

- [GroupManager] GroupManager (with all the gear/keystone info) has been re-enabled and it's info will now only be updated when the frame is shown.

- [GroupManager] The new sorting algorithm has been implemented, you can now sort for more than 2 things at once.
Keep in mind: the more the addon has to sort a raid group the more it has to compute.

- [M+ Statistics] "Turned off" the score increase calculation, waiting for tomorrow to see the actual formula for it.

### Fixed

- [GroupManager] The character frames with their RaiderIO info expanded will not close on GroupManager getting a group update anymore.

- [Lockouts] The lockouts will now be correctly refreshed when login in with a character and not just when opening the Lockouts frame.

- Logging in with a character will no longer cause a few lags at the beginning of loading into the world.



## [2.5.7a] - 2024-09-11

### Fixed

- Deleted some debug prints.



## [2.5.7] - 2024-09-11

### Changed

- [GroupManager] Disabled the keylevel and gear info for now, they create 4-5 hard lags after combat.
Will be fixed by the end of the week, don't have much time right now.



## [2.5.6] - 2024-09-11

### Changed

- [Gearing] Updated the gearing information.

- [DropChecker] Switched dungeon data to S1 dungeons.

### Fixed

- [GroupManager] Hovering over Brann in a Delve won't cause an error anymore.

- [FilterPanel] Unchecking your class now sets Blizzards "Needs my class" setting correctly and doesn't reset upon reopening the search panel.



## [2.5.5] - 2024-09-11

### Fixed

- [FilterPanel] When no difficulty has been actually selected (new install of the addon and it defaults to normal) it will now check for the base difficulty instead of no difficulty.



## [2.5.4] - 2024-09-11

### Fixed

- [MainFrame] The queue dropdown raidfinder selection should now correctly check if there are any activities found.

- [MainFrame] The new random dungeon tww S1 selection now has the correct icon.

- [MainFrame] There won't be any expansion separators between the different S1 heroic dungeons anymore.

- [SearchPanel&ApplicationViewer] Swapped out the RaiderIO data fortified and tyrannical timers for the new single ones.

- [Lockouts] Lockouts will now be deleted when they're expired.

- [SearchPanel] The raid category will now display "0/0" when there is no last season data.



## [2.5.3] - 2024-09-10

### Changed

- [RaiderIOChecker] Parsed the RaiderIO database addon version so it's easier to know when the DB was last updated.

### Fixed

- [DropChecker] Trying to check loot after selecting a different raid/dungeon in Blizzards Adventure Journal will not result in no loot found anymore.

- [MainFrame] A textline error with the queue dropdown has been resolved.



## [2.5.2] - 2024-09-08

### Changed

- [MainFrame] Switched up the order of the info frames in the top right corner.

- [Queue Dropdown] Changed the dropdown style to something similar to Blizzards new dropdowns.

- [Queue Dropdown] When your character is at the last expansion's max level (e.g. 70 for dragonflight) the queue dropdown dungeon selection will be ordered by expansionlevel and Random Dungeon will always be on top.

- [Queue Dropdown] When there are no options for a category type (e.g. no raid finder options) the button will be greyed out and do nothing.

### Fixed

- [MainFrame] Calendar events are back again with a slightly updated look.

- [ActiveQueues] Hovering over most queue frames should cause a quest ID error anymore.

- Clicking on the dungeon icon in the RaiderIO info panel should now refer to the correct dungeon + difficulty.

- [Queue Dropdown] If you have no heroic dungeons unlocked there won't be a section in the "Specific Dungeons" selection that tells you that you have unlocked them.

- [Queue Dropdown] The button to queue for multiple dungeons should now match the width of the frame.



## [2.5.1] - 2024-09-06

### Added

- A new tab has appeared! [Lockouts] has been added.
Here you can see all the raid & dungeon lockouts of all of your alphabetically sorted characters.
Hovering over the entries shows a tooltip listing the time and date until the lockout expires and which encounters are alive / have been defeated.

### Changed

- Deleted quite a lot of code that I had to put in myself after every Blizzard DB update.
Means more frequent updates and less errors.
Also while not really measurable it shaved ~1 to 1.5 seconds off of the loading time when you first login.

- [ApplicationViewer] Moved the race icon infront of the spec icon.
This has been in effect since 2.5.0.
Round textures with the black background removed will be implemented in 2.5.2.

- In the RaiderIO info panel data of the m+ now included in which season they earned this score.
This has been in effect since 2.5.0.

### Fixed

- Characters that don't have any M+ data whatsoever shouldn't cause an error anymore when you look at them in the [ApplicationViewer], [SearchPanel], etc.

- Deleted some debug prints.



## [2.5.0] - 2024-09-05

### Added

- The War Within World boss data is now implemented.

- [QueueSelector] You can now queue up for multiple follower dungeons at once (realized today that you can do that lol).

### Changed

- The new raider io info panel has been implemented in the application viewer, search panel and party check.

- Updated the raider io checker with season 1 data.

- Removed DF S4 statistic background images.

- [ActiveQueues] Added more data to the tooltips (e.g. tank/healer/dps wait times for dungeon/lfr queues).

### Fixed

- [SearchPanel] Detection of groups that declined you should now work more accurate.

- [ApplicationViewer] Members of a premade group that are not the leader won't have a decline button or an invite button anymore.

- [ApplicationViewer] Old applicants shouldn't show up in a "group" with new applicants anymore.



## [2.4.9] - 2024-09-04

### Changed

- Updated the gearing chart with the info that is currently available.

- Added the 4 non-mythic+ dungeons and removed the 4 m+ dungeons to/from the DropChecker for now, as soon as S1 starts they'll get taken out.

- Disabled the Guild tab for now, not enough time to really work on it and it's hitting performance quite a lot.
Will revisit this in the future.

### Fixed

- [GroupManager] Players that are leaving the group won't be checked for gear anymore.

- [Active Queues] Cinderbrew Meadery now has an background image.



## [2.4.8] - 2024-09-02

### Changed

- "Disabled" the vault check in the mainframe since there is no active season at the moment.

### Fixed

- There shouldn't be any errors anymore when calling the mainframe.

- Requests for affixes should now check if there actually is any affix data before trying to display them in the mainframe.



## [2.4.7] - 2024-08-26

### Changed

### Added

- [MainFrame] A button has been added which lets you requeue your last queued activity.

### Fixed

- Fixed a rare error that could occur if Blizzard sent affix information before the addon fully loaded.

- Random dungeon queues from MOP onward now have the correct icon.

- The roles for all pve/pvp queues shouldn't be sometimes reset anymore when leveling up.



## [2.4.6] - 2024-08-23

### Changed

- The currency information in the mainframe has been switched to the TWW ones.

### Fixed

- [Filter Panel] There shouldn't be any issues when trying to create a group.



## [2.4.5] - 2024-08-20

### Added

- [ApplicationViewer] You will now see if the group is in "Auto accept mode" (the blue exlamation point icon), e.g. in one of those World Boss groups.

- [Statistics] M+ dungeons and raids have been switched out for TWW Season 1 activities.

- [EntryCreation] Added a "The War Within" option in the dungeon dropdown. Currently it's unpopulated but as soon as you're leveling up and the dungeons get unlocked it will auto-populate with them.

### Changed

- Fixed some performance regressions in the filter panel.
While you usually have to wait for the Search Panel results to come in from Blizzards side it should now always detect the correct filter settings.

- [ApplicationViewer] Changed some icons around and deleted the affix information since it's already shown in the main frame.

- [M+ Statistics] Changed the dropdown to Blizzards new dropdowns.

- [M+ Statistics] Changed the layout to work with the new affix system / a single dungeon score.

### Fixed

- The background in the search panel, entry creation, etc. should not be some weird pixel mess anymore.

- [Search Panel] The scrollbar shouldn't overlay the side panels anymore.

- [Filter Panel] The reset button should now reset all filters again.

- [Filter Panel] Checking a specific spec after unchecking the class should now re-check the class so it shows up in the search results.

- [ApplicationViewer] Voice chat is now togglable with a mouse click on the icon (if you set a voice chat beforehand, otherwise Blizzard doesn't allow it.)

- [ApplicationViewer] The input box for changing itemlevel and rating while being queued should now always fit the standard ratings and itemlevels.

- [Active Queues] Creating a group for an old raid (pre-SOO) will now apply the correct background icon to the queue frame.

- [Options] The background can now be switched without a reload inbetween changing settings.


## [2.4.4] - 2024-08-18

### Added

- A new background option with a TWW background has been implemented.

### Changed

- Backend changes, switched to Blizzard Settings API.
Means less errors when implementing a new filter method, new interface option, etc.
Unfortunately to not fuck up anything settings wise I have to wipe all settings this time.
Unless Blizzard changes something this will be the last settings wipe.

- Switch back to the old display method for the search panel.
While really helpful for the guild frame for example the Blizzard way of handling large amounts of data is just not up to par.
With Blizzard's DataProviders the fps drops down into the 30s with my 7800X3D, with my method it's atleast in the mid 50's.

### Fixed

- Depending on the use case around ~5mb of memory are used less because of some XML reductions which scale with the applicant/search panel/guild frames.

- [Search Panel] The individual group frames shown will now only refresh with their data and not be overwritten by any other group.

- [MainFrame] The background frame should now also be visible in lite mode.

### Upcoming

- Bigger refactoring of code/algorithms, streamlining it more so future updates can be implemented faster.

- A raid sheet feature will be implemented, so you can plan your raid comps without going outside of the game.



## [2.4.3] - 2024-08-14

### Fixed

- [Teleports] Various errors have been corrected checking for the tp cooldowns.



## [2.4.2] - 2024-08-13

### Added

- [RaiderIOChecker] The current RaiderIO DB version will now be visible in the topright.

- All horizontal and vertical background images for the TWW and S1 dungeons and the raid have been added.
Old vertical images will be deleted once TWW S1 is active.

### Fixed

- [DropChecker] Switching to the DropChecker subframe won't trigger an table index error anymore.

- [Raid Statistics] ATDH will now be visible again, accidentally deleted the ID. lol



## [2.4.1] - 2024-08-12

### Added

- [DropChecker] You can now select "Mounts", "Recipes" and "Tokens" in the equipment slot dropdown.

- [DropChecker] You can now clear your armor type and class/spec selection separately.

- [DropChecker] An icon for the dungeons/raids has been added.

- [DropChecker] The tooltip line showing which boss drops the hovered item now lists the instance/raid in the beginning of the line, useful if you're currently searching for an item.

- [AdventureJournal] A notification line has been added if no loot is available for a specific slot.

- [AdventureJournal] The slot and armor dropdown menus have been ported over to the adventure journal (both the journal and the new DropChecker will be merged into a single feature around v2.6)

### Changed

- [DropChecker] The search bar now has a fuzzy algorithm type search behind it.
Just like before when you search for "Claw" it will show the items with "Claw" in it's name at the top.
But now items like "**Cla**sp of **W**aning Shadow" will now show up aswell.

- [DropChecker] Items can now be linked in any chat frame.

### Fixed

- [DropChecker] Various errors with the filtering and searching of items have been fixed

- [DropChecker] The full width of the item frame will now be used for the name.



## [2.4] - 2024-08-10

### Added

- In the toolbar there is a new "More" button.
 This button opens a menu for:
 - the Adventure Journal (where some algorithm improvements come with version 2.5)

 - the basically done DropChecker, where you can select either a slot, an armor type (cloth, leather, mail or plate) or a class/spec and see all the available loot for it.
 You can also just straight up search for the name of the item (description searching is coming with 2.4.1).
 The loot is divided by the individual dungeons and raids and further divided by slot.
 It contains all the TWW world boss drops and both the TWW S1 dungeons and the TWW1 S1 raid.

 - the (not even close to being finished) RaiderIOChecker, where you can input a name and realm (not needed if on the same server) and you'll get all the RaiderIO data they have

### Fixed

- All teleports are now really alphabetically sorted, even when starting WoW again after the cache has been cleared.


## [2.3.11] - 2024-08-05

### Added

- Raid teleports / all other dungeon teleports, including the ones from TWW Season 1, have been implemented.

### Changed

- The teleport page now has the logos of every expansion in front of the button row.

- All teleports are now alphabetically sorted. This unfortunately means that e.g. "The Azure Vault" shows up near the end and not near the beginning of the DF teleports.


## [2.3.10] - 2024-08-02

### Changed

- The adventure journal now uses the new display method for many rows of data, basically less laggy, especially when loading loot data.

### Fixed

- [Entry creation] The current Dragonflight raids should now be selectable again.

- [Search Panel] There shouldn't be any more errors when searching for legacy raids and then trying to create a group of any kind.

- Added a lot of TWW map data like boss icons, used in the raid progress info, the journal and the creation of a new group.

- Boss icons in the raid progress info of the raider io panel should be correct icons again and not their encounter journal counterparts.


## [2.3.9] - 2024-08-01

### Fixed

- Players of the opposing faction can now be favoured again.

- The rare items in the gearing chart now have the correct color indicating the respective track they're on.


## [2.3.8] - 2024-07-29

### Fixed

- Favouring a player should be possible again.

- The specific dungeon queue selections should work properly again.


## [2.3.7] - 2024-07-28

### Fixed

- There shouldn't be any more errors when queueing for a PVP match.

- The PVP frames in the queue selector should now be visible again and fit within the base frame.

- All rated queues in the queue selector should work again without any errors.

- Deleted season 3 M+ background images.

### Known issues

- Blizzard introduced new Menus with 11.0 and these broke the way I handled canceling PVP queues (since Blizzard doesn't allow that).
Until I come up with a new way to do that you have to click the "X" on the queue frame and then a menu will pop up.
You will have to select the "Leave queue" button of the queue you wanna leave.
This is ONLY for the PVP queues, all the PVE ones still work how they used to work.


## [2.3.6] - 2024-07-26

### Changed

- Updated the gearing chart tab with all the TWW info that is available.

### Fixed

- Less lag when opening the mainframe.


## [2.3.5] - 2024-07-24

### Changed

- Updated the Open Raid Library.

### Fixed

- [Filter Panel] The raid options will now be populated again (technically the Dragonflight expansion is over so it didn't display any raids).

- [Application Viewer] The number in the bottom right indicating how many applicants you currently have will now be correctly refreshed when displaying the application viewer.


## [2.3.4] - 2024-07-24

### Fixed

- [SearchPanel] There should be no more "reset disallowed" errors.

- [GroupManager] The player should now be "inspectable" both in a group and solo.

- Multiple issues with the library "Open Raid Library" have been fixed.


## [2.3.3] - 2024-07-24

### Changed

- The new display method has now also been implemented into the [GroupManager] tab, less laggy and it won't jump between the M+ and raid tab around anymore

### Fixed

- [Class Panel] The players class is now always visible, instead of just when you're in a group.

- [GroupManager] The players itemlevel and durability should now always be refreshed.

- [GroupManager] Party members itemlevel, durability, keystone and keylevel should now be always refreshed when a group update occurs.

- [GroupManager] The keystone levels should now reflect the level of the keystone, not the players level.


## [2.3.2] - 2024-07-21

### Added

- Flightstones and the equivalent for TWW have been implemented in the currency tracker in the mainframe.

### Changed

- The currencies in the mainframe now have a black semi-transparent background.

### Known problems

- Calendar events are only visible after manually open the calendar frame the usual way (Blizzard changed something in the code so I'll have a look if I can fix that rq).


## [2.3.1] - 2024-07-20

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


## [2.3] - 2024-07-17

### Changed

- Switch to a different method of displaying the groups in the search panel, increasing performance by a shit ton.
There should basically be no more micro stutters and scrolling should be buttery smooth.
Throughout the 2.3 version I'll apply it to the whole addon, making it need way less memory and way more snappy.

### Fixed

- [InspectCoroutine - Lite Mode] Various errors have been fixed for lite mode.

- [Category selection - Lite Mode] When trying to look for a group the category buttons should now be visible again.


## [2.2.9] - 2024-07-13

### Fixed

- [M+ Statistics] The keystone dropdown will not show keys of your last ~~lovers~~ party members

- [M+ Statistics] The keystone dropdown will now be refreshed when you switch to the M+ Statistics.

- [M+ Statistics] The keystone dropdown should now also reliably list all raid members' keystones.

- [Mainframe] Even less lag when opening the main frame the first time after logging in or a /reload.


## [2.2.8] - 2024-07-11

### Changed

- Updated the Curseforge readme to accurately describe the addon.

### Fixed

- Even less lag when opening the mainframe for the first time.

- Some preparations for TWW.


## [2.2.7] - 2024-07-10

### Fixed

- When leaving a group and teleporting away right after there won't be any errors popping up anymore.

- The keystone dropdown in the M+ panel should now be refreshed whenever you switch to the panel.

- Less lag when opening the mainframe for the first time.


## [2.2.6] - 2024-07-09

### Fixed

- When leaving a group and teleporting away right after there won't be any errors popping up anymore.

- Improved filter panel load time and removed redundant checks.

- First pass for TWW, fix most egregious bugs from Beta.


## [2.2.5] - 2024-07-07

### Fixed

- [LastInvites] The player frames should now be placed inside the panel.

- [ApplicationViewer] When you invite a premade group all players will now appear in the [LastInvites] list

- A rare error when checking for heroic dungeons to queue for shouldn't occur anymore.

- A rare error changing the order of the queue finder dungeons shouldn't occur anymore.


## [2.2.4] - 2024-07-06

### Fixed

- Performance update, Application Viewer and Search Panel performance increased by around 25%.

- Pushed more of the memory management to WoW's engine, which should make everything feel a little bit snappier.

- Deleted some now unneccessary files


## [2.2.3] - 2024-07-04

### Added

- Above the currencies there is now a bullion tracker.

### Fixed

- [ApplicationViewer] The applicant's tooltip will now hide correctly after leaving the applicant frame.

- [GroupManager] While in a group the tooltips shouldn't get mixed up anymore.

- [GroupManager] The leader icon isn't floating around the world anymore when you scroll down.

- [GroupManager] There won't be any error anymore when someone leaves the raid/group while it's currently checking for their gear.

- More performance fixes.

- Fixed an error when the leader tries to queue the group while in combat.

- The raider io info's background is now back in business.

- The mainframe won't open anymore when something in the application viewer changes.


## [2.2.2] - 2024-07-04

### Changed

- The detailed raider io information panel has been simplified, resulting in better performance and a lower memory requirement.
Doesn't save alot of memory (around 1-2 megabytes) but it's the first step.

### Fixed

- The detailed information panel will now display the main's highest raid progress in the raid tab.

- [GroupManager] Specs and classes will now be identified more reliably.

- [GroupManager] Weapon enchants will now also be checked.

- [Entry Creation] Setting an mythic plus or pvp rating will not set the other rating to the same value.


## [2.2.1] - 2024-06-28

### Fixed

- [GroupManager] Itemlevel and durability now also always update for players on your realm.

- [Guild] Saved keystone info from guild members will not have priority over new incoming data.

### Upcoming

- Revisiting my old custom "You've got an invite" panel idea, since I've learned quite a lot since October last year.
Probably implementing it over the next few days, base code is already done.

- After the custom invites I'll probably have a full version of performance optimizing shit, especially a better idea for the guild panel.


## [2.2] - 2024-06-26

### Added

- A [Guild Panel] has been added!
Here you can see all guild members basic info, their RaiderIO progress (m+ and raid) and their current key and the level of it.
Of course all of it can be sorted.
Since guilds are usually over a hundred members big it might lag here and there if you try to sort the list.

### Fixed

- [Calendar] Guild events between holiday events should no longer cause the holiday info to be discarded.

- [Gearing Chart] The chart fully fits into the actual window.

- [GroupManager] Reseting a secondary sorting method will not bug out the UI anymore.

- [GroupManager] Keystones of party/raid members only get checked when you actually switch to the GroupManager tab.
Decreases lag when calling the main window.

- [GroupManager] Hands won't be checked for enchants anymore.


## [2.1.5c] - 2024-06-20

### Fixed

- [Gearing Chart] Progress is now visible again and fits into a single line.


## [2.1.5b] - 2024-06-19

### Fixed

- [Party Check] Itemlevel and Durability will now also be correctly refreshed for the player (if the player is in a group).

- Small performance increases, most notably when opening the mainframe for the first time.


## [2.1.5a] - 2024-06-19

### Fixed

- [Party Check] Itemlevel and Durability will now be refreshed again correctly.


## [2.1.5] - 2024-06-19

### Added

- [Filter Panel] Age filtering has been implemented.
You can set a minimum amount and/or a maximum amount (both in minutes).

### Changed

- Blizzards dungeon filter option "Needs my class" now works correctly, if you're logged into your hunter, you deselect hunters in the filter panel and then log into your warlock, instead of the hunter filters being deselected, the warlock ones will be deselected.

- Updated the Open Raid Library, which is needed for keystone, gear and enchants info (The dev doesn't update the TOC version of the addon, so it's stuck in 9.2.5 and doesn't get automatically served to players who use the library).

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


## [2.1.4a] - 2024-06-16

### Fixed

- Gearing Chart was disabled when I was looking for the upgrade item bug, it's re-enabled now.


## [2.1.4] - 2024-06-16

### Fixed

- Finally fixed the weird bug where you sometimes (but not always) couldn't upgrade an item when enabling my addon.
It was the last instance where I was using a Blizzard dropdown, they're famous for their taint issues.
I am so sorry, lol.


## [2.1.3] - 2024-06-13

### Added

- [Party Check] Missing enchants and missing gems are now included in the tooltip.

### Changed

- The category selection buttons and the journal button are now located in the title bar, more like in a traditional window.

- Changed all fonts to Blizzard base fonts, since I don't need my own specific font anymore.
This means korean, simplified and traditional chinese and russian characters should now be rendered correctly.

- [Search Panel] All listings will now have their respective activity as a background.

- [Adventure Journal] When you enter a raid the default instance selecting will be the one you're currently in.

### Fixed

- Added an anchor point for the base frame of the search panel, application viewer, entry creation and dungeon journal.

- [Application Viewer] The "ress fit" and "lust fit" options will now consider the players class and spec.

- [Search Panel] Failed applications, e.g. when you have already 5 applications running, will not lead to a "delisted" state anymore.

- [Active Queues] After a /reload and clicking on an active lfg application should now correctly load the search panel.

- [Party Check] The score of your party/raid members will now show their score, not yours.

- Multiple code logic errors fixed.


## [2.1.2] - 2024-06-09

### Added

- A new tab has appeared!
GroupManager is now available.

Here you will see your group- / raid-members listed in a table, showing info like spec, role, itemlevel, repair%, keystone, score and raid progress.
The table is sortable with 2 active sort methods, e.g. 1. sorted by role and 2. sorted by ilvl.

In version 2.1.3 I'll have missing enchants, missing gems and current talents (not sure what the layout is going to be) for every group member included.

Role and spec are baseline available with WoW.
Ilvl, durability and keystone info are only available if the other player(s) have either MythicIOGrabber or Details installed (or really any addon that used LibOpenRaid).
Score and raid progress are dependant on RaiderIO being installed and them having raider io data.

### Changed

- Changed the Halls of Infusion background image to appear brighter.

### Fixed

- [Main Tab] The "Expand frame" button works again.

- [Search Panel] Adjusted the padding of the group listing frames, since the borders were sometimes wonky.

- [Filter Panel] You can now hide the filter panel when it's currently locked.

- [Adventure Journal] There should be no more errors about the AdventureJournal when lite mode is active.

### Upcoming

- (2.1.3) Condensed Search Panel view: half height versions of the group listings with individual backgrounds (based on the activity).

- (2.1.4) Overhauled main tab layout


## [2.1.1] - 2024-06-06

### Changed

- "Last Group" box is now below the "Active Queues" panel. Makes more sense and the right side got kinda crowded.

### Fixed

- [Adventure Journal] Items from older raids / difficulties now get correctly applied to the frame template.

- [Adventure Journal] Loot data from older raids / dungeons should now gets correctly processed.

- [Adventure Journal] Reduced the lag when switching to a different boss / raid.


## [2.1] - 2024-06-05

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



## [2.0.10] - 2024-06-02

### Fixed

- [Filter Panel] The "hide hard decline" filter option now remembers it's setting.

- [Filter Panel] Blizzard's LFG filters won't reset MIOG's filters anymore.

- [Application Viewer] There shouldn't be any more errors related to the rating setting.

- Deleted debug prints relating to an upcoming feature.


## [2.0.9] - 2024-05-27

### Added

- [Active Queues] Random Battlegrounds now also have a non-rotating background.

- [Active Queues] PVP queues now also have a minimalistic tooltip.

### Fixed

- No more errors should pop up when starting WoW fresh after the cache has been cleared (code checked for an ongoing season but after a cache clear or fresh WoW start after the pc has been shutdown it doesn't have that data right away).


## [2.0.8] - 2024-05-26

### Added

- Implemented a very basic version of the gearing chart.
It's more for me to test how code the algorithms and ideally have it automatically retrieve the item levels for each new raid tier so all the info you need is available day 1 even if this addon is not updated right away.
Still very rudimentary but it's "working" already so here ya go.

### Fixed

- [Options] The show/hide class panel option now actually work.

- [Filter Panel & Active Queues] When the boss kills change on a listing it will show the correct ineligbility reason.

- [Category Selection] When selecting the same category as before (e.g. first trying to search for a dungeon group then creating one yourself) shouldn't cause any more errors.


## [2.0.7] - 2024-05-22

### Added

- World PVP and Open World PVP "queues" have been implemented for Active Queues.

### Changed

- [Active Queues] The current group leader's name will be shown instead of "YOUR LISTING".

### Fixed

- [Last Invites] Restored the functionality to the "Last Invites" function and simplified it code-wise, making it easier to maintain in future.

- [Entry Creation] Added the default backgrounds for all PVP categories and questing/custom.

- [Search Panel & Application Viewer] Adjusted the sort button's position to match in both lite mode and normal mode.

- [Application Viewer] Adjusted button sizes so the number of applicants is more visible.

- [Application Viewer] The filters "Affix fit" and "Rating" are now also present in the application viewer.

- [Filter Panel] Party, ress, lust and affix will now also be checked while loading the settings. 

- [Active Queues] There shouldn't be anymore errors popping up being in a currently listed group and being infight.

- [Filter Panel] When using the "linked" option for healer and tanks MIOG won't set Blizzards stock lfg filter to "hasTank" and "hasHealer", since you wanna see both with either a healer or a tank.

- [Filter Panel] Resetting all boss filters via the "X" button now actually resets the setting instead of just letting the borders disappear.

- [Filter Panel] Raid options now also get saved when selecting/deselecting the respective option.

- [Calendar] Adjusted the month day of the calendar functions so it gets all holidays from the current day and not just from the day I implemented the feature...lol


## [2.0.6] - 2024-05-21

### Added

- Specific battlegrounds have been added to the queue selector!
Due to Blizzard code limitations it has to imitate Blizzards PVP frame:
There will be Blizzards dropdown menu with "Bonus" and "Specific" battlegrounds, choose one and the type of BG appears.
Choose a queue and press the join button.
If I wouldn't have to do it this way I wouldn't, it's part of Blizzard's "let's limit pvp botting" initiative.

### Fixed

- [Active Queues] Ashran and Arathi Basin both have been given the correct background image.

- [Search Panel] No more errors should pop up when no groups have been found and you want to adjust a filter afterwards.

- Deleted all debug prints.


## [2.0.5] - 2024-05-21

### Fixed

- Issues where dungeon filter button and raid filter buttons could not be found have been resolved.

- [Filter Panel] Issues with the tanks, healers and damager filter options have been resolved and should now function correctly again.

- [Search Panel] There won't be any leftover frames when the search has failed for some reason.


## [2.0.4] - 2024-05-20

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
This issue is resolved in an upcoming non hotfix version (2.0.6).

- [Active Queues] Arathi Basin has no background texture and Ashran has the wrong background texture.


## [2.0.3] - 2024-05-14

### Changed

- When a group listing does not match your filters anymore the frame in the queue panel will now list a shortened reason.

### Fixed

- Band-aid solution with addons like "World Quest Tracker" that move the search box of the group finder.
After closing all windows that pop up through the quest addons and pressing the search button the search box will appear again.

- Deleted a debug statement that popped up when checking for Blizzard LFG filters.


## [2.0.2] - 2024-05-13

### Added

- The class panel has now multiple indicators regarding it's inspection process.
On the left side of the panel there will be the current player being inspected along with an indication of (current number of players already inspected, inspectable members and total group members).
Inspectable members are not the same as group members. Depending on weird faction stuff or for example if the person is offline it sometimes bugs out so I check for stuff like that.

If for some reason the inspect process seems to take way too long you can press the loading spinner to reset the inspect process.

### Changed

- The location of the class panel is now at the top of the main frame / the pve frame

### Fixed

- Improved the new inspect algorithm and fixed it's problems.
If 10 seconds have passed since the last request for inspect data a new request will be made (fail-safe if Blizzards data doesn't reach the addon)

- The player will now be correctly included in the inspect process, even though there will be no actual request to Blizzard since we always have player data.
Just for consistency and debugging processes.

- There is no longer an "X" button on the "Your listing" queue frame in the queue panel when you are not the leader of the group (you couldn't do anything anyway).

- It is no longer possible to sign up to a group without being the group leader.
You actually bugged the group with this until the next WoW restart. Listed the group permanently and actually fucked up Blizzard system client side (group would permanently load but nothing would happen). 

- The filter panel will now also overwrite Blizzards "Has Healer / Has Tank" filter option whenever you check/uncheck the box in MIOG's filter panel.

### Known issues

- The raid statistics for awakened raids are getting superceded by higher difficulties, e.g. if you have 2/9 normal and 9/9 heroic it shows up as 9/9 normal.
Don't think I can really do something about that, Blizzard's limitation of achievement tracking.

- Specific queues (such as battleground queues) have no background in the "Active queues" panel.
I'll probably put in some placeholders except for the special ones.


## [2.0.1] - 2024-05-12

### Added

- The new inspect algorithm is implemented, new algorithm should no longer permanently scan the party/raid members and should be twice as fast (depending on other addons also trying to inspect players).
Currently saving spec data per group member for 5 minutes, then it will do a fresh rescan.

- Implemented queueing for multiple dungeons.

- Raid finder queue selection is now separated into each raid and has an Indicator which shows if it's currently awakened.

### Changed

- Updated the queue frame design.

- The currency frame is now in the bottomright corner.

- The dungeon lists in the queue selector are now alphabetically ordered.

### Fixed

- Some filters from Blizzard were applying to my own when they're not supposed to (e.g. dungeon rating being set when looking for a raid).

- Awakened raid statistics are now correctly tracked. They were previously superceded by the higher difficulty (e.g. previoulsy if you had 7 kills on normal and 9 on heroic then the normal statistic would show 9/9)

- Deleted and fixed some old code for my custom dropdowns.

- Deleted some old libraries.

### Known issues

- Specific queues (such as battleground queues) have no background in the "Active queues" panel.
I'll probably put in some placeholders except for the special ones.

- Just like before, sometimes the inspect function doesn't behave correctly / takes too long to get an answer from Blizzard.
Just right click and inspect someone from your party and it should resolve itself.
Workaround is already in development.


## [2.0] - 2024-05-08

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

- The Application Viewer and the Search Panel are now written in XML instead of LUA.
Mostly means huge performance increases across the board while it's way easier for me to update all the old art without breaking shit.
The main frame, class panel and filter frame will be rewritten until 2.0 comes out.

- [Raid tab] Design has been changed, instead of left to right it's now top to bottom for raid order (current to last season).
Readability hasn't been ideal and I wanted to future proof it (if a raid has 11 or 12 bosses I can now display them without issues).

- [Search Panel] Dungeons', raids' and arena's difficulty/bracket dropdown isn't a unified option anymore, e.g. enabling the difficulty filtering for dungeons doesn't activate the filtering for raid or arena.

### Fixed

- [Search Panel] The border of the currently selected group should not disappear anymore when another groups gets any data update.

- [Search Panel] There should be no random groups popping up anymore that got delisted

- [Search Panel] Groups you've applied to should jump to the top of the list immidiately.

- Many UI bugs have been squashed because of the XML UI rewrite (layering, size and position issues).

### Known issues

- [Search Panel] Sometimes after applying to a group the "Delisted" string shows up until you manually search again (just a UI bug)

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

- Adjusted the sort buttons' position in the Search Panel.

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
Much stuff has been fixed / improved since many UI elements and a lot of code is reused with the new Search Panel.

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
[unreleased]: https://github.com/NintendoLink07/MythicIOGrabber/compare/3.4.4..HEAD
[3.4.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.4
[3.4.3a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.3a
[3.4.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.3
[3.4.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.2
[3.4.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.1
[3.4.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.0
[3.3.0a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.3.0a
[3.3.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.3.0
[3.2.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.9
[3.2.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.8
[3.2.7a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.7a
[3.2.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.7
[3.2.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.6
[3.2.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.5
[3.2.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.4
[3.2.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.3
[3.2.2d]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.2d
[3.2.2c]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.2c
[3.2.2b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.2b
[3.2.2a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.2a
[3.2.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.2
[3.2.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.1
[3.2.0a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2.0a
[3.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.2
[3.1.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.1.4
[3.1.3a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.1.3a
[3.1.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.1.3
[3.1.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.1.2
[3.1.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.1.1
[3.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.1
[3.0.14a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.14a
[3.0.14]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.14
[3.0.13]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.13
[3.0.12]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.12
[3.0.11]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.11
[3.0.10]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.10
[3.0.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.9
[3.0.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.8
[3.0.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.7
[3.0.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.6
[3.0.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.5
[3.0.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.4
[3.0.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.3
[3.0.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.2
[3.0.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.1
[3.0.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.0
[2.9.6a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.6a
[2.9.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.6
[2.9.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.5
[2.9.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.4
[2.9.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.3
[2.9.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.2
[2.9.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.1
[2.9.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.9.0
[2.8.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.8.0
[2.7.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.7.0
[2.6.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.6.2
[2.6.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.6.1
[2.6.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.6.0
[2.5.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.9
[2.5.8b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.8b
[2.5.8a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.8a
[2.5.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.8
[2.5.7a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.7a
[2.5.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.7
[2.5.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.6
[2.5.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.5
[2.5.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.4
[2.5.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.3
[2.5.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.2
[2.5.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.1
[2.5.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.5.0
[2.4.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.9
[2.4.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.8
[2.4.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.7
[2.4.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.6
[2.4.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.5
[2.4.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.4
[2.4.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.3
[2.4.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.2
[2.4.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.1
[2.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4
[2.3.11]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.11
[2.3.10]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.10
[2.3.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.9
[2.3.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.8
[2.3.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.7
[2.3.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.6
[2.3.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.5
[2.3.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.4
[2.3.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.3
[2.3.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.2
[2.3.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3.1
[2.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.3
[2.2.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.9
[2.2.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.8
[2.2.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.7
[2.2.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.6
[2.2.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.5
[2.2.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.4
[2.2.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.3
[2.2.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.2
[2.2.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2.1
[2.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.2
[2.1.5c]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.5c
[2.1.5b]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.5b
[2.1.5a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.5a
[2.1.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.5
[2.1.4a]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.4a
[2.1.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.4
[2.1.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.3
[2.1.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.2
[2.1.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1.1
[2.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.1
[2.0.10]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.10
[2.0.9]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.9
[2.0.8]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.8
[2.0.7]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.7
[2.0.6]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.6
[2.0.5]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.5
[2.0.4]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.4
[2.0.3]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.3
[2.0.2]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.2
[2.0.1]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.1
[2.0]: https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0
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