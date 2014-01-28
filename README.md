README.md

This is an attempt to write an algorithm that will better identify and group players of equal footing and eliminate the abusive behavior that is ruining low rank (>1500) matches by intentionally downranking. It's also my first time checking out the WoW API, which is pretty extensive.

Problems:
High skill players carrying low gear\skill players
High gear players carrying low gear\skill players
Being able to quickly tank MMR by leaving queue with the goal of earning massive points at lower ranks

Solutions:
Write algorithm to more accurately determine initial team ranking and matchups
System where players can't lose more than x MMR in a single week. Ex: a 1700 rank player cannot lose more than 300 rank points in one week in a single bracket.

 Arena MMR notes:
 1. Identify iLevel, add PvP Power (pvpPower) *2, add Resilience (pvpResilience)
 2. Team rating starts at player rating average, unless there is a discrepancy of 50% of the lowest players rating
    a. Ex: rating 600 and rating 400, discrepancy of 200 points
    b. In this case, the team rating is team average + discrepancy, making for a team rating of 700
    c. Goal here is to keep anyone with kick ass gear from ever sitting at low mmr, and to identify teams that are "carrying" and inch them up in the rankings to compensate for the discrepancy between the team members
    d. These numbers would have to be tested and slightly tweaked but I believe the system leaves room to do so, without major changes

Please let me know if you have comments, questions or suggestions!
lars.j.sommer@gmail.com

