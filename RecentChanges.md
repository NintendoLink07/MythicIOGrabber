## [3.4.3](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.4.3) - 2025-05-13

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