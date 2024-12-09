# Witch Taven

### Video Demo:

#### __Description:__ 

"Witch Taven" is a 2D platformer game built in lua using the LOVE2D framework. The player navigates through a series of levels, dodges enemies, collects orbs, all while trying to reach the portal to progress. The game features animations, collision physics, and a dynamic camera method. Alot of the visuals that are not animated were managed through TILED which is a great fit for lua and the LOVE2D framework.

#### __Features:__

- Side-scrolling gameplay with smooth animations
- Collectable orbs that are displayed on the screen by a counter
- Enemy AI that move around the gameMap damaging the player if they collide
- A dynamic camera method that is follows the player while within the bounds of the tilemap
- "Game over" and "End" screen when player either dies or reaches portal 

- <ins>Sound effects:</ins>
    - Player jumping
    - Player damage taken
    - Orb collection
    - Level change
    - Game over
    - End game
    - Restart

#### __Animations:__

Anim8 is used as the animation library which helped with the process to create frames then for animations, which those frames would be looped through from a grid in the love.update() function and visually shown in the love.draw() function. The objects that the animations are latched onto are the player, orbs, enemies, and portal. Animations for the player differentiate based off of if the user moves the character around.

- Anim8: https://github.com/kikito/anim8

#### __GameMap:__

Tiled is used to implement the background visuals of this entire game. Allowing the creation of each level and their tile layers. Object layers are also created from tiled to allow for colliders and animations to latch onto eachother. Simple Tiled Implementation (STI) allows for the loading and rendering of the Tiled map(s) which allows the all the layers in tiled to function properly in the LOVE2D framework.

- Tiled: https://thorbjorn.itch.io/tiled
- Simple Tiled Implementation (STI): https://github.com/karai17/Simple-Tiled-Implementation

#### __Colliders:__

Windfield was used as the physics module in this game which allowed the better creation of colliders used for collision detection between the player and any collider that interacts with the player. The collision detection in this game accounts for everything the player traverses which allows for different features to work properly.

- Windfield: https://github.com/a327ex/windfield

#### __Camera:__

Using the camera tool in the HUMP toolbox I was able to accurately attach the camera to the center of the player and follow the player within the bounds of the tileMap in from tiled. It is consitently drawn each frame and updated based off of player location.

- Helper Utilities for Massive Progression (HUMP): https://github.com/vrld/hump

#### __Source Files:__

- <ins>Dictionaries:</ins>
    - hud.lua
    - player.lua
    - portal.lua
    -slime.lua
- <ins>Draw:</ins>
    - animations_draw.lua
    - background_draw.lua
    - help_text.lua
    - hud_draw.lua
    - menu_draw.lua
- <ins>Load/Animations:</ins>
    - orb_animations.lua
    - player_animations.lua
    - portal_animations.lua
    - slime_animations.lua
- <ins>Update:</ins>
    - animations_update.lua
    - camera_update.lua
    - grounded_state.lua
    - handle_player_anim.lua
    - menu_update.lua
    - update_orb_colliders.lua
    - update_player_collider.lua
    - update_slime_colliders.lua

#### __love.load():__

The love.load() function is one of the core functions responsible for loading and rendering all of the assets that get used in the love.update() and love.draw() functions

- <ins>Setup Functions</ins>
    - setupWorld(wf): Generates the physics world and collision classes used.
    - setupHud(): Loads HUD visuals (health, orb counter, and timer)
    - setupPlayerCollider(wf): Generates the player collider
    - setupMap(): Loads the default map and generates colliders for the specific map index, '1-3'
    - setupCamera(): Generates the camera and sets up boundaries on the Camera_Border object layer

- <ins>LoadFiles Called:</ins>
    - player.animations.lua: used for loading player animations
    - orb_animations.lua: used for loading orb animations
    - slime_animations.lua: used for loading the slime animations
    - portal_animations.lua: used for loading the portal animations

#### __love.update():__

The love.update() function is one of the core loops in this LOVE2D game. It updates the games logic, physics and mechanics each frame. Allowing for things to flow smoothly and efficiently.

- portalUpdate(): determines if the player is colliding with the its collider/object layer

- world:update(dt) updates the physics engine based on delta time

- checkLevelEndCollision(): determines whether the player interacts with the level end collider and teleports the player to the next levels starting position and calls all other necessary functions to based on requirements for the next level

- Timer Update: Changed by delta time, if the gamestate is "game", keeps track of the time spent in the level

- <ins>Update Files Called:</ins>

    - handle_player_anim.lua: updates the player animations based off of the player moving the their character around

    - animations_update.lua: function updates the player, orb, slime/enemies based on each frame

    - update_orb_colliders.lua: Determines if there is collisions between the player and its orbs, updates the HUD orb_counter accordingly

    - update_player_colliders.lua: Handles player interactions with other object layers such as the walls,level_end, and enemies and updates accordingly with health and gamestate in mind

    - update_slime_colliders.lua: Determines and updates whether the player makes contact with the slime colliders and adjust health_count accordingly. Also updates based off of slime boundaries which determines its movement/direction

    - menu_update.lua: is responsible for updating the menu logic during game over and game complete states

    - camera_update.lua function updates the camera's position based around the players x and y position while staying within the bounds of the window and tileMap

#### __love.draw():__

The love.draw() function is another core function in LOVE2D that draws information each frame, given by the load function, and changes by what's determined in the update function.

- The cam:attach() and cam:detach() determines what is drawn within the camera's lense which then handles moving across a map with different colliders moving subject to that

- <ins>Draw Files Called:</ins>
    - background_draw.lua: function draws/renders the background map layers from TILED, all stuff that doesn't interact with anything

    - animations_draw.lua: function handles the rendering of the player, orbs, enemies, and portal animations

    - help_text.lua: function displays text on the screen providing information on which keybindings to use and what what the player should try and accomplish

    - menu_draw.lua: handles the "Game Over" and "Game Complete" screens based on the game state. Also displaying the number of orbs collected, time alotted, and restart and quit keys

    - hud_draw.lua: outside of the cam:attach() boundary the hud is drawn showing the number of hearts the player has, a timer showing the time elapsed and a orb counter showing the number of orbs collected by the player