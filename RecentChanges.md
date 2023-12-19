## [1.4.4](https://github.com/NintendoLink07/MythicIOGrabber/releases/tag/1.4.4) - 2023-12-19

### Fixed

- Blizzard seems to have fixed the spec id issue.
Have tested it out a lot this morning and each premade sent the correct spec data 100% of the time.
Hurray!

- New applicants should now no longer jump inbetween applicants already in the list.
This way you won't invite someone who just applied while you wanted to invite someone else.
Downside is now the applicant list only gets refreshed when you either press the refresh button or decline / invite someone.
If you don't have invite privileges it will still auto refresh on every new applicant.

### Changed

- Improved performance again by quite a lot!
From ~0.071s to around 0.021s per 33 applicants.
Or in other words: joining a group with 100 applicants now is faster than joining a group with 33 applicants with the old MIOG version.
Makes the lag when you join a group really short.

For anyone interested why the improvement is so large: the SetBackdrop function is actually quite time expensive.
While it's easier to just use the functions already available than to make a new texture it's (for my use-case) not worth it.
With multiple applicants applying and going through the same loops hundreds to sometimes thousand times per second it's easier on the CPU and actually not that memory hungry.