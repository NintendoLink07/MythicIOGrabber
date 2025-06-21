## [3.5](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/3.5) - 2025-06-21

### Changed

- The filter panel has been reworked:
    - Filters that get applied after MIOG got the results and filters that get sent with the initial request for the results have been visually split.
    Filters at the top (class/spec filters, party/ress/lust, hide declines and age) are getting applied after the list of results has been received.
    Exception: the class filter of your current class, this is for Blizzard's "needs my class" filter.

    Filters beneath the line separator are being sent with the initial request for results, meaning to get the most groups that you want to join you should always have them configured correctly.
    Especially the "Activities" filter(s) are important, searching for groups with the filter enabled but DFC disabled will not show DFC groups even after re-enabling the filter when you have the results.
    You have to click the search button again with the filter enabled to show DFC groups.
    Exception: Boss filters in the raid category
 
    - When you change a setting that is getting applied by Blizzard interally to pre-filter the results you're getting a "warning" shows up asking you to refresh the search panel.
    
    - Spec filters can only be enabled/disabled when the respective class filter is enabled.

    - Class filters will now change their color when disabled/enabled, spec filters will de-/saturate the respective icon.

    - Bosses will only be visible when their raid activity filter has been enabled.

    - Some logic tweaks which improve performance of both the filter panel and the search panel.

### Fixed

- [SearchPanel] Improved performance a lot upon a category (e.g. dungeons, quest, raids, raids legacy, etc.).

- [SearchPanel] Ordering of results is now correctly taking into account multiple search parameters.

- [SearchPanel] After applying to a group the scroll frame will retain it's current scroll position.

- [SearchPanel] 2v2 arena groups will now correctly show the icon of the player that created the listing.

- [SearchPanel] PVP queues will now correctly show the rating for the respective mode (2v2, rbg, etc.).

- [SearchPanel] Fixed the edge case of opening the "custom" search panel category and showing no search results until about a second later.

- [Progress] Multiple issues regarding the vault status in the overview screen have been resolved.

- [MainFrame] Dastardly Duos won't cause an error while hovering over the card in the "Active queues" panel anymore.

- [ApplicationViewer] Specific pvp categories won't create an error anymore when hovering over the rating.

### Upcoming

- The 3.5 versions will mostly include performance-, logic- and bugfixes.
Versions 3.6 and forward will include new features coming with 11.2.