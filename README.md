# △ dune
---

You're stranded inside a pyramid with no way out. With 3 minutes on the clock, you **must** find a way out by collecting the power crystals scattered throughout the crypt.

*Dune* is a rougelike dungeon-crawler with procedurally generated maps and rooms. With snaking paths and loot sprawled through the tomb, can **you** escape the maze?

---

### Controls 🎮 

| Action     | Key    | Action     | Key    |
|------------|--------|------------|--------|
| move up    | w / 🡹 | attack     | space  |
| move left  | a / 🡻 | roll       | r      |
| move down  | s / 🡸 | open map   | m      |
| move right | d / 🡺 | quit game  | esc    |

### Design 🔧
The game draws inspiration from *Zelda*'s maze-like dungeons. I really like exploration in games, and it was a fun challenge to make exploration engaging and worthwhile.

#### Exploration 🗺 
The objective of the game is to collect a pre-determined number of crystals scattered in chests throughout the game's map. The snaking paths and corridors give the player lots of room to get lost in.

The map and rooms are randomly generated. This gives the game more replayability, and makes every game different from the last. Since maps and rooms refresh every time the game starts, the player must pay close attention to the current layout of the map.

> ##### _Map_
> The map generator uses a recursive backtracker to trace out a path through a grid of random size. 
> Starting from a random point in the grid, the `Map:mazeRunner` function picks a valid direction to trace into (a valid cell is one that has not been visited before). 
> The `mazeRunner` will keep running as long as there are adjacent cells that have not been visited yet. 
> Once it reaches a cell where there are no valid options to trace into, it returns to the previous cell and tries to pick out a direction to head in. 
> In doing so, the function will eventually visit and connect all cells in the grid recursively. 
> 
> However, I've added a chance for the `mazeRunner` to return even when there are valid adjacent cells, in order to give the maze a more unpredictable shape. 
> There is also a chance for `powerups` / `collectibles` to be generated, with a higher weight when the room is a dead-end.
> 
> The map GUI can be accessed at any time, but the player won't know what each room contains unless a certain powerup has been collected.

> ##### _Rooms_
> The rooms are generated with the wave function collapse algorithm. 
> Each cell in the room is assigned an entropy value, which is based on the number of possible states that it can take up.
> The states that a tile can occupy depends on its neighbours, so when a tile is set, the tiles surrounding it are also affected. 
> Each tile has a certain weight for generation.
> 
> First, the corridors connecting the current room to adjacent rooms are generated.
> Next, the `Room:collapse` function selects tiles with the lowest entropy, and picks one at random.
> `Room:collapse` then fixes the state of the tile by calling `Room:setTile`.
> The surrounding tiles are updated, and the process repeats until `Room:fullyTiled` returns true.
> If the room is invalid (e.g. room cannot be fully tiled, not all tiles are properly connected), then the algorithm is run again
>
> `Room:flood` and `Room:flooded` check if there is a valid path between all air blocks within the room to ensure that all areas of the room are accessible.
> Other functions like `Room:decorate` and `Room:invest` add `collectibles` and obstacles to the room. 
> Destructible boxes, bushes and vases help to give each room a different layout to challenge the player's navigation skills.
> Snake enemies also serve as a dynamic obstacle to the player's exploration, adding an extra element of consideration in pathing.

> ##### _Collectibles_
> There are 3 types of `collectibles`:
> - Crystals 💎
>   - Main objective of the game
>   - Collect all the required crystals to win
> - Powerups ⚡
>   - Speed upgrade
>   - Attack upgrade
>   - Map upgrade (shows which rooms contain gold chests)
> - Gold 🏆
>   - Adds time to the hourglass
>   - Can come in chests and scattered throughout the room
>
> I was very generous in the generation of `collectibles` as I wanted to make exploration more rewarding.
> The scattering of gold throughout the rooms adds an extra layer of nuanace to room navigation
> Force players to think about pathing more deliberately (take a longer path to collect more gold vs running straight through rooms to save time).

#### Time ⏳
The game is put on a 3 minute timer, which can be extended by collecting gold. The race against the clock creates thrill and makes players think on their feet. This adds extra challenge to navigation as players need to plan their route to efficiently comb through the map. They can also take risk by skipping certain rooms to save time, adding additional depth to the gameplay.

> ##### _Movement_
> The player has the option to `roll`, which grants a short window of invincibility and covers a sizeable distance.
> This can help players skip past enemies and get through the room quickly.
> However, the player cannot attack in this state.
> If timed poorly, the player will take damage while trying to `roll` through an enemy.
> The player can choose to either engage in combat (which is more time-consuming, but can yield drops), or to evade (which is riskier) base on their own playstyle

> ##### _Scoring_
> The player's `score` hinges on the amount of time left on the clock as the player collects the final crystal.
> This is to reward players that navigate through rooms quickly and efficiently.
> The player is free to take risks with their health since it does not affect their final `score`.
> However, dying causes the level to reset, losing valuable progress.

#### Graphis & Sounds 📸
I chose to create my own sprites, sounds and music to give a more authentic feel to my project. I'm quite happy with how it turned out since I have no experience in spritework or sound design. It was a tough, but really eye-opening experience.
