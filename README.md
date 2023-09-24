# MythicIOGrabber

MythicIOGrabber is a standalone addon which shows applicants to your group in a organized and extensive way.<br>
Created this addon because I hate to manually look up all applicants on raider.io, having to wait for their site to respond, sift through non condensed information, then tab back into the game.

I also included some stuff I've always wanted to see: 
1. a timer for how long I've been in queue
2. the current affixes
3. the group data, so I know if my min rating or min ilvl are set too low
4. generally just show every option in a visual manner, either via text or icons

The addon SHOULD scale with all UIScales or resolutions but let me know if it doesn't / what exactly doesn't scale how it should.<br>

Curseforge site: <br>
If you have way too much money:<picture>
  <a href="https://www.paypal.com/donate/?hosted_button_id=NZUR27TPC86TE">
  <img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif">
  </a>
</picture>

## General interface
<br>

### Blizzard applicant data
The data Blizzard gives me that I display in the standard view are (in order):
1. Name (hoverable to show the name with realm, e.g. Rhany-Ravencrest)
2. If there's a comment
3. the applicant's role of choice (e.g. if you play a Druid and you set it to dps only)
4. Dungeon Score
5. Highest key for the dungeon you've listed
6. Item level
7. If the applicant is a friend of yours
   
![Screenshot 2023-09-24 191805](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/a92ac146-cff9-4e4b-99ea-6b2427655336)

Also shows if there's no raider.io installed, since it improves the experience immensely.
If raider.io is installed BUT there's no data about the applicant (they've done no keys this season) then it shows the "No raider.io data" string.

![Screenshot 2023-09-24 195747](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/27f02f8e-aaf0-4049-a99b-5ff14c443952)


The tank/healer/dps buttons are for filtering:<br>
You don't wanna see the tanks/dps 'cause you're looking for a heal first? Uncheck tank & dps and check heal!

![FILTERED_OUT_HEALER](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/9828a5ec-95da-4c50-802d-4f7e9789bf46)


## Raider.io integration
If you have Raider.IO installed it even includes all the data about your applicant: their highest keys of both week in the respective dungeons and the amount of +5, +10, +15 or +20's they've done.<br><br>
![Screenshot 2023-09-24 191828](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/333ce2a1-b7ee-49f5-8937-b0c165fd9975)

## Other options

- You can click the downwards arrow in the title bar to extend the applicant viewer (the default one was too small for me)
- If you click the refresh button left from the close button you refresh the current view of the applicants AND enable auto sorting, if it's enable in the interface options.

![SORTING](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/4e098ffc-43ec-4bf6-8baf-4f96670574f3)
  
- In the interface options there are just some general improvements to the LFG frame in general:<br><br>
	![Screenshot 2023-09-24 193413](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/2c0b3fb2-6da2-46f1-a3da-52cb6a5449d4)<br>
	1. Shows the specs of the groups in your group browser so you never have to manually check if there's a Survival Hunter in the group :)
  	2. Always keeps the groups in your group browser in the right order(e.g. there's a group with one Holy Paladin, so it will show: 1. Empty Tank spot, Holy Paladin, Empty DPS spot, Empty DPS spot, Empty DPS spot
  	3. Enables sorting of the applicants after you refresh manually atleast once.
  	   Sorts always start when you've either declined someone or you pressed the refresh buttons. This way it won't sort the moment you wanted to invite someone else and you missclick.
