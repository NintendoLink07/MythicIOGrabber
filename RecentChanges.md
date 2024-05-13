## [2.0.2](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/2.0.2) - 2024-05-13

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