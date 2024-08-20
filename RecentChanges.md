## [2.4.5](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.4.5) - 2024-08-20

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