## [3.4.4](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.4) - 2025-05-24

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
Improves performance and eliminates incorrect data being shown.

### Fixed

- [SearchPanel] Groups you've applied to will now automatically pin themselves to the top of the list.

- [GroupCreator] An error has been resolved where the group creator tried to use map data that isn't / wasn't available yet.

- [ApplicationViewer] The raider io panel will now be properly be populated with data and not just be a beautiful black box.

- The [SearchPanel], [ApplicationViewer] and [GroupCreator]'s resize button won't cause the frame to get stuck in place anymore.

- Relogging when you have a group listed will not show the [SearchPanel], [ApplicationViewer] and [GroupCreator] at the same time.

- The last group you joined will now also get saved when you're in lite mode.