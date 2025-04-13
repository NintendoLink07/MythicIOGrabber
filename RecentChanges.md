## [3.3.0](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.3.0) - 2025-04-13

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
This issue is fixed in v3.3.1.