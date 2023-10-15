# MythicIOGrabber

This addon replaces the standard application viewer with a much more detailed version.<br>
It shows you the applicants for your group finder listing in a clear but more extensive way.<br>
With the Raider.IO addon it expands the functionality of this addon massively and shows you Raider.IO M+ and raid stats of the applicants.<br>

![Screenshot 2023-10-14 153105](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/ba1e5cab-a7b5-4871-ab37-12f6a18a27ec)

## Addon features
In order from left to right, top to bottom (:star: is different or completely new):

### Settings
- :star: No r.io text: if you have no Raider.IO installed or it is currently disabled it shows you a warning in the title container of the parent frame (Dungeons & Raids)
- :star: Expand: the frame height increases by 50% since I find the standard application viewer way too small when you have more than 10 applicants
- Setting button to access the interface options quickly

### Information Panel
![Screenshot 2023-10-14 153004](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/30286e83-a349-4477-a51a-f27832bf278e)

Information shown while your group is listed:<br>
- Title
- :star: Group composition:
	- Under or at 5 members: current group with specs they're currently in
	- Over 5 members: shows the number of tanks/healers/dps in the standard way: 2/4/14
- :star: Listed for cross faction or just your faction
- Activity name (Dungeon/raid, what difficulty, etc.)
- :star: Description: If too long it's scrollable
- :star: Exclamation mark/point: If your group is set to private it glows
- :star: Voice Chat: always shows an icon, either normal or stricken through, hovering over it shows the info you've added
- :star: Playstyle: Hovering over it shows the current playstyle you've chosen (Completion, Beat timer, standard, etc.)
- :star: Rating threshold: For both PvE or PvP
- :star: Itemlevel threshold
- :star: Current affixes: hovering of the frames shows a tooltip with the affix names
- :star: Queue timer: timer for how long you've been in queue (saves between reloads and relogs for the same group)


### Filtering and sorting:
- :star: Tank/Healer/DPS filter: Filters out the applicant leaders (and their premades!)<br>
![Screenshot 2023-10-14 153615](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/0b1633b8-7820-43b6-89a1-e6bd86109bb6)
- :star: Sort for role, dungeon score / pvp rating / raid progress, highest key done or ilvl: You can have 2 methods active at a time, most useful way is probably sort 1. for role and 2. for score/rating/progress
- You can sort ascending or descending, e.g. if you wanna list the tanks with the lowest key done first you'd do 1. descending role and 2. ascending highest key<br>
![Screenshot 2023-10-14 153621](https://github.com/NintendoLink07/MythicIOGrabber/assets/3246525/6b4e6c70-2286-4d68-8fa4-2c2fed7b4899)
- Manual refresh button


### Applicant information:
#### Standard panel
- :star: Extend (arrow down button): Opens the detailed view
- :star: Name: Class colored, if too long it has a tooltip with full name
- :star: Comment (letter icon): If they have entered a comment with their application
- :star: Role
- :star: Dungeon score / raid progress / PVP rating: colored with the standard Blizzard colors or bright red if they're under the rating threshold you've set.
	- Shows (depending on the category your group is listed in) their dungeon score, raid progress or pvp rating
- :star: Highest key done / pvp tier / raid progress for your listed dungeon, green if in time, red if not in time
	- Shows (depending on the category your group is listed in) their highest key done for your listed dungeon, raid progress of their 2nd highest tier or PVP tier they're in (Combatant II, Rival I, Elite, etc.)
- :star: Item level: White if no ilvl threshold set / over the threshold, red otherwise
- :star: Friend: Only shows up if they're a friend of yours- Accept/Decline buttons
- :star: Turquoise circle: When they're a premade of someone else (they're grouped together anyway but this makes it more clear)


#### Detailed panel:
- :star: Buttons to show either M+ or raid data
- :star: Left side (Raider.IO data):
	- :star: Mythic+
		- All current season dungeons: icons are clickable and open up the journal for that specific dungeon
		- Shows the applicants' individual dungeons highest keys done, green if in time, red otherwise.
		- Keys on the left are always for the current weekly affix (Tyr/Fort), right side is the other one
	- :star: Raid
		- The 2 highest difficulties, where they've completed atleast 1 encounter, Mythic>Heroic>Normal.
	    	- Not displaying LFR data for the moment
 - :star: Current and last tier raid: icons are clickable and open up the journal for that specific raid
 - :star: All raid bosses ordered from left to right, top to bottom and for the "only M+" players: numbered!
 - :star: All bosses icons are clickable and open up the journal for that specific boss
 - :star: Icons have a colored border for the difficulty they've completed the encounter

- :star: Right side (General info):

- :star: Comment: if they've entered a comment it will display here
- :star: (With Raider.IO) Depending on the current view (M+ or Raid) it will show if it's their main char in those areas or if not it will show the score / progress of their main
- :star: Roles: shows their current and alternative roles they can play (if they applied with them too)
- :star: (With Raider.IO) Key count: number of +5, +10, +15 and +20 keys they've done

### Interface option settings:
- :star: Keep the comment you've entered when applying to another group in the group finder
- :star: Keep the settings you've entered when creating your group
