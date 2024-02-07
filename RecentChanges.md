## [1.8](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.8) - 2024-02-07

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