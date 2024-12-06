# Witch Taven

--CITE WORK IN CODE--

### Video Demo:

#### Description: 

"Witch Taven" is a 2D platformer game built in lua using the LOVE2D framework. The player navigates through a series of levels, dodges enemies, collects orbs, all while trying to reach the portal to progress. The game features animations, collision physics, and a dynamic camera method. Alot of the visuals that are not animated were managed through TILED which is a great fit for lua and the LOVE2D framework.

#### Features:
- Side-scrolling gameplay with smooth animations
- Collectable orbs that are displayed on the screen by a counter
- Enemy AI that move around the gameMap damaging the player if they collide
- A dynamic camera method that is follows the player while within the bounds of the tilemap
- "Game over" and "End" screen when player either dies or reaches portal 
- Sound effects
    - Player jumping
    - Player damage taken
    - Orb collection
    - Level change
    - Game over
    - End game
    - Restart

#### Animations:

Anim8 is used as the animation library which helped with the process to create frames then for animations, which those frames would be looped through from a grid in the love.update() function and visually shown in the love.draw() function. The objects that the animations are latched onto are the player, orbs, enemies, and portal. Animations for the player differentiate based off of if the user moves the character around.

- Anim8: https://github.com/kikito/anim8

#### GameMap:

Tiled is used to implement the background visuals of this entire game. Allowing the creation of each level and their tile layers. Object layers are also created from tiled to allow for colliders and animations to latch onto eachother. Simple Tiled Implementation (STI) allows for the loading and rendering of the Tiled map(s) which allows the all the layers in tiled to function properly in the LOVE2D framework.

- Tiled: https://thorbjorn.itch.io/tiled
- Simple Tiled Implementation (STI): https://github.com/karai17/Simple-Tiled-Implementation

#### Colliders:

Windfield was used as the physics module in this game which allowed the better creation of colliders used for collision detection between the player and any collider that interacts with the player. The collision detection in this game accounts for everything the player traverses which allows for different features to work properly.

- Windfield: https://github.com/a327ex/windfield

#### Camera:

Using the camera tool in the HUMP toolbox I was able to accurately attach the camera to the center of the player and follow the player within the bounds of the tileMap in from tiled. It is consitently drawn each frame and updated based off of player location.

- Helper Utilities for Massive Progression (HUMP): https://github.com/vrld/hump

#### love.load():


#### love.update():


#### love.draw():