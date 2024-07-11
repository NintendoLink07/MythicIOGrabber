# Mythic IO Grabber
This addon replaces the standard application viewer with a much more detailed version.  
It shows you the applicants for your group finder listing in a clear but more extensive way.  
With the Raider.IO addon it expands the functionality of this addon massively and shows you Raider.IO M+ and raid stats of the applicants.

## Addon features

![Settings#1](https://i.imgur.com/MLyEsHo.png)

1. Class panel: Shows you which class you have in your group right now and after a few seconds the spec of this person (requesting spec data from Blizzard takes time).
2. No r.io text: if you have no Raider.IO installed or it is currently disabled it shows you a warning in the title container of the parent frame (Dungeons & Raids).
3. Expand: the frame height increases by 50% since I find the standard application viewer way too small when you have more than 10 applicants.  
   When you have manually increased the size with the grabber in the bottom right corner it will expand to your set size.
4. Setting button to access the interface options quickly.
###  
****
###  
## Addon settings

### Information shown while your group is listed:

![Settings#2](https://i.imgur.com/1Kz5pLH.png)

1. Title
2. If under or at 5 members: current group with specs they're currently in. Hovering over the icons reveals the person who's playing the spec.
   Over 5 members: shows the number of tanks/healers/dps in the standard way: 2/4/14.
3. Listed for cross faction or just your faction.
4. Activity name (Dungeon/raid, what difficulty, etc.).
5. Description: If too long it's scrollable.
6. Exclamation mark/point: If your group is set to private it glows.
7. Voice Chat: always shows an icon, either normal or stricken through, hovering over it shows the info you've added.
8. Playstyle: Hovering over it shows the current playstyle you've chosen (Completion, Beat timer, standard, etc.).
9. Rating threshold: For both PvE or PvP.
10. Itemlevel threshold.
11. Current affixes: hovering of the frames shows a tooltip with the affix names.
12. Queue timer: timer for how long you've been in queue (saves between reloads and relogs for the same group).
13. Last invites panel: You can check your last invites and set them to favoured, making them show up at the top of your applicant list all the time.
    Last invited applicants stay on the list for 3 days, then they get deleted on your next login / reload.
14. Last invited applicants: Name, Spec, Role, Score or Raid progress
15. Button to switch the applicant between favoured or normal "mode".
16. Delete applicants from the last invites list.
17. Background image changes based on your dungeon (implemented every dungeon/raid DF S2 and forward).
###  
****
###  
### Options for applicant filtering and sorting:

![Settings#3](https://i.imgur.com/SMP4549.png)

1. Role/class/spec filter: Filters out the applicant leaders (and their premades!).
2. Sort for role, score, highest key done or ilvl: You can have 2 methods active at a time, most used way is sort 1. for role and 2. for score. You can sort ascending or descending, e.g. if you wanna list the tanks with the lowest key done first you'd do 1. descending role and 2. ascending highest key.
3. Manual refresh button.
###  
****
###  
### Applicant information:

![Settings#4](https://i.imgur.com/zwVNZmY.png)

1. Extend (arrow down button): Opens the detailed view.
2. Comment (letter icon): If they have entered a comment with their application.
3. Name: Class colored, if too long it has a tooltip with full name.
4. Specialization.
5. Role.
6. Dungeon score / raid progress / PVP rating: colored with the standard Blizzard colors or bright red if they're under the rating threshold you've set. Shows (depending on the category your group is listed in) their dungeon score, raid progress or pvp rating.
7. Highest key done / pvp tier / raid progress for your listed dungeon, green if in time, red if not in time Shows (depending on the category your group is listed in) their highest key done for your listed dungeon, raid progress of their 2nd highest tier or PVP tier they're in (Combatant II, Rival I, Elite, etc.).
8. Item level: White if no ilvl threshold set / over the threshold, red otherwise.
9. Friend: Only shows up if they're a friend of yours- Accept/Decline buttons.
10. Invite / decline buttons.
11. Turquoise circle: When they're a premade of someone else (they're grouped together anyway but this makes it more clear).  
###  
****
###  
### Detailed view -  Buttons to show either M+ or raid data:

### Left side (Raider.IO data):

### Mythic+

![Settings#5](https://i.imgur.com/3yxiaAA.png)

1. All current season dungeons, listed in alphabetical order: icons are clickable and open up the journal for that specific dungeon.
2. Shows the applicants' individual dungeons highest keys done, green if in time, red otherwise.
   Keys on the left are always for the current weekly affix (Tyr/Fort), right side is the other one.
###  
### Raid

![Settings#6](https://i.imgur.com/4caKaQO.png)

1. Current and last tier raid: icons are clickable and open up the journal for that specific raid.
2. The 2 highest difficulties, where they've completed atleast 1 encounter, Mythic > Heroic > Normal.
   Not displaying LFR data for the moment (Raider.IO addon doesn't have the data).
3. All raid bosses ordered from left to right, top to bottom and for the "only M+" players: numbered!
   All bosses icons are clickable and open up the journal for that specific boss.
   Icons have a colored border for the difficulty the applicant has completed the encounter.
###  
### Right side (General info):

![Settings#7](https://i.imgur.com/lkE2I4c.png)

1. Comment: if they've entered a comment it will display here
2. (With Raider.IO) 
2a. M+ tab selected: will show previous season score, main's current score and main's previous season score (depends on RaiderIO data, they might have a main but haven't logged into the char for a while so it doesn't show anything, can't change that).
2b. Raid tab selected: Shows if it's their main char or the main char's progress for the 2 highest difficulties.
3. Roles: shows their current and alternative roles they can play (if they've chosen them while applying).
   Race: Shows an icon with their race, has a tooltip when you hover over it.
4. (With Raider.IO) Key count: number of +5, +10, +15 and +20 keys they've done.
5. Realm.
###  
****
###  
### Footer bar:

![Settings#8](https://i.imgur.com/G9IYY0w.png)

1. If you're the leader of the group you will see the standard "Browse Groups", "Delist" and "Edit" buttons.
2. If Raider.IO is installed their icon, where you can copy the applicants which you can paste on their website, will be shown.
3. How many applicants (a premade group counts as 1) you currently have.
4. Manual frame resizer.
###  
****
###  

### Interface option settings:
1. Background options, if you don't like the default background.
2. Hide the background image completely (mostly for ElvUI users so it works with the semi-transparent style of ElvUI).
3. Show/Hide the class panel, which shows you the class and specs of your current group.
4. (Experimental, might break any time) Keep the comment you've entered when applying to another group in the group finder.
5. (Experimental, might break any time) Keep the settings you've entered when creating your group.
6. Enable(disable the favoured applicant setting.

Created this addon because I hate to manually look up all applicants on raider.io, having to wait for their site to respond, sift through non condensed information, then tab back into the game.
