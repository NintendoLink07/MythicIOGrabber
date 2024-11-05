## [3.0.2](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.0.2) - 2024-11-05

### PSA

[ReQueue] You should always be <= 100 results AND use the same for the feature to reliably work.
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