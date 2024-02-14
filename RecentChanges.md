## [1.9](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.9) - 2024-02-15

### Changed

- Most layout stuff is now written in XML.
Mostly means huge performance increases across the board while it's way easier for me to update all the old art without breaking shit.

- [Raid tab] Design has been changed, instead of left to right it's now top to bottom for raid order (current to last season).
Readability hasn't been ideal and I wanted to future proof it (if a raid has 11 or 12 bosses I can now display them without issues).

- [Search panel] Dungeons', raids' and arena's difficulty/bracket dropdown isn't a unified option anymore, e.g. enabling the difficulty filtering for dungeons doesn't activate the filtering for raid or arena.

### Fixed

- [Search panel] The border of the currently selected group should not disappear anymore when another groups gets any data update.

- [Search panel] There should be no random groups popping up anymore that got delisted

- [Search panel] Groups you've applied to should jump to the top of the list immidiately.

- Many UI bugs have been squashed because of the XML UI rewrite (layering, size and position issues).

### Debug

- Got the suggestion from a reddit thread a few weeks ago: if you create a group (can/should be set to private) from the Premade Groups panel (Keyboard shortcut 'i') and you type /miog debugon_av_self you will see how other people see you in their application viewer.
If you want to check for pvp: type /miog debugon_av_self {bracketID}. 1 for 2v2, 2 for 3v3, 3 for 5v5 or 4 for 10v10. (there won't be any pvp data in the detailed info panel, only the rating and bracket name in the smaller panel. You can only get real data for other players if you can inspect them).
Be sure to either /reload after or type /miog debugoff, otherwise you will not see any applicants to your group.