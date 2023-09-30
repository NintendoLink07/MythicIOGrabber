# MythicIOGrabber


This is a companion addon which shows you the applicants for your group finder listing in a clear but expanded view.<br>
With the Raider.IO addon it expands the functionality of this addon massively and shows you additional stats of the applicants.<br><br>
Created this addon because I hate to manually look up all applicants on raider.io, having to wait for their site to respond, sift through non condensed information, then tab back into the game.

I also included some stuff I've always wanted to see: 
1. a timer for how long I've been in queue
2. the current affixes
3. the group data, so I know if my min rating or min ilvl are set too low
4. generally just show every option in a visual manner, either via text or icons

The addon SHOULD scale with all UIScales or resolutions but let me know if it doesn't / what exactly doesn't scale how it should.<br>

CurseForge site: [Mythic IO Grabber on CurseForge](https://legacy.curseforge.com/wow/addons/mythic-io-grabber)<br>
If you have way too much money:<picture>
  <a href="https://www.paypal.com/donate/?hosted_button_id=G3X525EXQGJCE">
  <img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif">
  </a>
</picture>

## General interface
![Screenshot 2023-09-24 190806](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/33d78cd8-90ce-4375-9bd6-04c7aac2bda9)

### Blizzard applicant data
The data Blizzard gives me that I display in the standard view are (in order):
1. Name (hoverable to show the name with realm, e.g. Rhany-Ravencrest)
2. If there's a comment
3. the applicant's role of choice (e.g. if you play a Druid and you set it to dps only)
4. Dungeon Score
5. Highest key for the dungeon you've listed
6. Item level
7. If the applicant is a friend of yours
   
![Screenshot 2023-09-24 191805](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/56112352-aba2-4fd4-b92e-ba27d0e4ed80)

Also shows if there's no raider.io installed, since it improves the experience immensely. <br>
If raider.io is installed BUT there's no data about the applicant (they've done no keys this season) then it shows the "No raider.io data" string.

![Screenshot 2023-09-24 195747](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/ca1e27f3-3c89-441e-abdb-de7857f72c56)

The tank/healer/dps buttons are for filtering:<br>
You don't wanna see the tanks/dps 'cause you're looking for a heal first? Uncheck tank & dps and check heal!

![FILTERED_OUT_HEALER](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/39ddeb48-b7f8-44cc-b507-0de30313da28)

## Raider.io integration
If you have Raider.IO installed it even includes:
- Dungeons:
	- Their highest keys of both week in the respective dungeons
	- The amount of +5, +10, +15 or +20's they've done
 	- If it's their main char or if not: what their main's score is

- Raids:
	- Current tier data: the 2 highest difficulties, e.g. if you've done 1/9 M, 9/9 HC and 9/9 N it would show 1/9M and 9/9HC data
	- Previous tier data: accurate boss kills can only be counted for the highest difficulty done, how many bosses you killed are again depending on your 2 highest difficulties
 	- If it's their main char or if not: what their main's progress is

![Screenshot 2023-09-24 191828](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/41d5f965-2e47-4aad-b5cf-ce5cf5d20b77)
![Screenshot 2023-09-29 225519](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/7bccdb50-b8c8-4097-a98e-6045eb3d16c3)


## Other options

- You can click the downwards arrow in the title bar to extend the applicant viewer (the default one was too small for me)
- If you click the refresh button left from the close button you refresh the current view of the applicants AND enable auto sorting, if it's enable in the interface options.

![SORTING](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/887236e5-d4b8-4e9d-aec6-720c4daad932)
  
- In the interface options there are just some general improvements to the LFG frame in general:<br><br>
	![Screenshot 2023-09-24 193413](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/9ea30f6b-a31b-4149-9eda-32af095d25e5)<br>
	- Shows the specs of the groups in your group browser so you never have to manually check if there's a Survival Hunter in the group :)
	- Always keeps the groups in your group browser in the right order(e.g. there's a group with one Holy Paladin, so it will show: 1. Empty Tank spot, Holy Paladin, Empty DPS spot, Empty DPS spot, Empty DPS spot
	- Enables sorting of the applicants after you refresh manually atleast once.
  	   Sorts always start when you've either declined someone or you pressed the refresh buttons. This way it won't sort the moment you wanted to invite someone else and you missclick.
