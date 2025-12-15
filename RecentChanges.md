## [3.8](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.8) - 2025-12-15

### Changed

- [ApplicationViewer] The application viewer has been recoded and redesigned.
    - Performance has been improved dramatically.
    - Group applications have now a "header entry" and below this every member is listed.
    - A new sorting system has been implemented which will find it's way into every aspect of the addon where sorting is used / will be used.
    - Multiple hover effect have been added to have a more robust feedback.

### Changed

- A general adjustment of code has been done for Midnight's addon changes.
Luckily only a small number of features are affected by these changes.

### Fixed

- [ApplicationViewer] Invited applicants will now stay visible after being invited and not accepting the invite right away.

- [ApplicationViewer] Applicants, whose status changes (timedout, cancelled, failed, invite declined, invite accepted, declines), will now either 1. stay visible when you can invite people or 2. disappear right away when their application has ended in anyway whatsoever.

- [SearchPanel] The performance of refreshing the search panel in any way has been improved.

- [Mainframe] The scale textbox isn't immune to mouse clicks anymore.

- Every aspect that queries RaiderIO data has been speed up by atleast 8x.

### Known issues

- [ApplicationViewer] The sort buttons do not align with the applicants data (e.g. the item level sort button is a bit to the right of the item level data).
I am currently developing a better way to scale windows in WoW which is deeply incorporated here.
This will be "fixed" in v3.9 or v4, not sure yet.

- The main window can only be resized vertically.
Also related to the scaling system development, will be "fixed" in v3.9 or v4.