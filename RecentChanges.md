## [1.7](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.7) - 2024-01-25

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
Fixed this case for every UI that rewrites character frames (ElvUI and SUF were not affected since I only used those for testing).