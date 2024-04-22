# Tavernlight Screening

Around 20-30 hours were spent to get to this state of the project. Still, the outcome is far from what I would have hoped for. An overwhelming majority of time was spent on setting up the development environment, which includes setting up UniServerZ, TFS, and OTClient, as well as familiarizing myself with the project structures, which calls for reading through large codebases throughout TFS and OTC in both lua and C++, their respective GitHub Wiki pages ([TFS GitHub Wiki](https://github.com/otland/forgottenserver/wiki), [TFS Wiki](https://docs.otland.net/ots-guide), [OTC GitHub Wiki](https://github.com/edubart/otclient/wiki)), and [OTLand](https://otland.net/) forum posts. I was able to get the latest OTClient to compile, but not TFS 1.4, which has an incompilable 1.4 release source code on my system. Actual time spent on the coding problems was a very small proportion, likely in the range of 10-20%.

The largest obstacle in this project was the lack of (updated) documentation. The configuration and setup instructions of TFS and OTC were often times outdated. Documentation of the available scripting APIs were heavily lacking, as in the available lua functions relied on exploring the codebase and making my own collection of helpful functions. This is further exacerbated by my lack of experience in the Open Tibia scene, which meant I spent significant time looking up what .spr and .dat files are, how to do simple things in the game such as moving and getting unstuck from the spider cave, and particularly how to cast spells.

## Q5 - Eternal Winter

### Demo video

https://youtu.be/FMgSeuFQDSU

### Trying the code

Put forever_winter.lua into (your TFS directory)\data\scripts\spells. Say "frigo" (without the double quotations) in game.

### Design

As the video obviously looked like something that resembles a spell, I firstly looked into how spells in Tibia is cast. I looked through OTC in search of something that resembles a skill bar but in vain. After a long search, I finally figured out that casting spells are text-based, after which it just all seems so in-universe and obvious.

Next, I looked for how new spells are created. I landed on RevScript, the relatively newer scripting interface to creating new server-side content on TFS. Through bruteforce testing with the level requirements, class requirements, mana cost, self cast, and other configurations, I successfully made it possible for my new character to cast the spell.

After that, I looked into the necessary skill effect. Some further research tells me that the effect to be recreated is the [Eternal Winter](https://tibia.fandom.com/wiki/Eternal_Winter) spell. This is where an unsolved obstacle in this question lies. On the Wiki page, the skill effect is consistent with the video clip, where the tornadoes are in a checker pattern, and that it checkers in a way that the player is on an empty checker space. However, sending a combat area effect to the spell sends tornado effects in a checker pattern that the player is on a tornado space. Even sending individual magic effects to positions give the same pattern. This leads me to believe that the skill effects have a fixed pattern and that they are fixed to the screen space. Further looks into the codebase tells me that all skill effects are sent without special cases, which means there is no quick fix to the "ice tornado special case". This also means that the only perfect solutions I could try was to either alter the game file's assets directly, or expose a special lua function from the C++ side to draw effects with an offset. If I had more time to look into the interaction between lua and C++, as well as between C++ and game files, I would have attempted the latter. Due to time contraints, I decided to create the script off-center, but flexible enough that whenever such a custom function is available, the script can easily adapt.

Another difference is that the tornadoes in the video clip appears in groups, as opposed to all together. The groups look to be somewhat constant within a single cast. However, since the clip contains a single cast, it is impossible to tell whether the group allocations are random or constant between casts. It is also impossible to infer from a design perspective, as both are viable choices. In the end, I decided that since the groups are constant within a single cast, it is logical that they are constant between casts.

Additionally, I am including a PDF of my notes when I was investigating the intricacies of the spell, in q5\notes.pdf.

### Implementation

My implementation of the script took inspiration from the default combat area implementation, using a grid of encoded integers. First, a max number of groups is defined. Then, in a 2D array of integers, define the visual effect area in different integers. 0 means that no effect is cast on the cell. 1 ~ maxGroups means that the effect should be cast on the cell with group number equal to the integer. 100 means to center the player on that cell. 100 + N means the player is on that cell, and that a magic effect should be cast on that cell also with group number equals N. Each group will have its effect visualized one group after another, with a delay between each group, for a set number of cycles. For example, in the case that there is 2 groups, 250ms delay, and 2 cycles, then group 1 will have their effects sent at t=0ms, group 2 t=250ms, group 1 again at t=500ms, and finally group 2 at t=750ms.

Following the above notes on design, this means that when the custom function to send spell effects offset is realized, the only change required is to modify the area grid to center the player.

## Q6 - Dash

### Demo video

https://youtu.be/vIO1lZocyyg

### Trying the code

Put dash.lua into (your TFS directory)\data\scripts\spells. Say "dash" (without the double quotations) in game.

### Design

One of the first things I found was that shaders are not natively supported in the official repo of OTClient. However, in other forks of OTC, shaders were implemented (e.g. [mehah's repo](https://github.com/mehah/otclient)). For the sake of the test, I did not think forking from other repos to be acceptable. I also lack time and expertise in the C++ framework to interface with shaders myself. Despite knowing some shaders basics, I ultimately decided to implement only the movement part of the skill.

### Implementation

The dash is likely implemented in another system, but since I already have a good idea about the spells system, I created dash as a spell to at least demonstrate the logic.

When the dash is cast, the next N tiles in front of the players are checked one by one. If the tile is walkable, a teleportTo call is scheduled with a slight delay between each call to present an animated effect.

## Q7 - Jump UI

### Demo Video

https://youtu.be/suQywoAWkks

### Trying the code

Put the folder client_jump into (your OTC directory)\mods. In OTC, go to modules manager, and load client_jump module.

### Design

Calling this the "Jump UI" may be a bit confusing considering the possible correlation with in-game vertical jumping, but in the limited scope of this technical screening and considering that the button is labelled with the word "Jump", it will suffice.

This task was the most achievable personally, and the only one I was able to clone perfectly. This is likely due to the self-containedness of the OTC UI modules and my background in web development.

### Implementation

A window is created with a button. Upon the modules's initialization, the button enters a looping callback, scheduling a call to itself with a delay at the end of every execution. In the callback, the button moves to left for some amount. When the button reaches the left edge of the window, or when the button is clicked, the button is repositioned to a random position within the spawnable space in the window.
