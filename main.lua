io.stdout:setvbuf("no")
_G.love = require("love")

local player = require('Source.Dictionaries.player')
local Hud = require('Source.Dictionaries.hud')
local Slime = require('Source.Dictionaries.slime')
local portal = require('Source.Dictionaries.portal')

local playerAnimations = require 'Source.Load.Animations.player_animations'
local orbAnimations = require 'Source.Load.Animations.orb_animations'
local slimeAnimations = require 'Source.Load.Animations.slime_animations'
local portalAnimations = require 'Source.Load.Animations.portal_animations'

local updateCameraPosition = require 'Source.Update.camera_update'
local updateSlimeColliders = require 'Source.Update.update_slime_colliders'
local updateOrbColliders = require 'Source.Update.update_orb_colliders'
local updateGroundedState = require 'Source.Update.grounded_state_update'
local updatePlayerColliders = require 'Source.Update.update_player_collider'
local animationsUpdate = require 'Source.Update.animations_update'
local handlePlayerAnim = require('Source.Update.handle_player_anim')

local Help_text = require 'Source.Draw.help_text'
local Background_draw = require 'Source.Draw.background_draw'
local Animation_draw = require 'Source.Draw.animations_draw'
local Hud_draw = require 'Source.Draw.hud_draw'
local Menu_draw = require 'Source.Draw.menu_draw'

-- Declared variables used throughout program
local maps = {"Maps/map.lua", "Maps/map2.lua", "Maps/map3.lua"}
local currentMapIndex = 1
local cameraBounds = {}
local scaleX, scaleY = 1, 1
local gameMap
local jumpCooldown = 0.1
local elapsedTime = 0
local gameState = "game"
local gameComplete = false

function love.load()
-- Credit to Challacade for inspiration on the use of all the software modules/libraries used
-- windfield, sti, anim8, HUMP/camera.lua
-- https://www.youtube.com/@Challacade

    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Loads font
    Font = love.graphics.newFont('Libraries/Fonts/YujiMai-Regular.ttf', 24)
    love.graphics.setFont(Font)

    -- Loads helper modules
    local anim8 = require 'Libraries/anim8'
    local wf = require 'Libraries/windfield'
    camera = require 'Libraries/camera'
    sti = require 'Libraries/sti'

    playerAnimations.setupPlayerAnimations(anim8, player)
    orbAnimations.setupOrbAnimations(anim8, Hud)
    slimeAnimations.setupSlimeAnimations(anim8, Slime)
    portalAnimations.setupPortalAnimations(anim8, portal)

    -- Sound effects credit from itch.io: Cyrex studios(UI/Menu Soundpack), 
    -- Jalastram(8-Bit Jumping Sounds), VOiD1 Gaming(HALFTONE Sound Effects)

    -- Loads sounds that are accessed from table
    sounds = {}
    sounds.win = love.audio.newSource('SoundEffects/win.wav', 'static')
    sounds.loose = love.audio.newSource('SoundEffects/loose.wav', 'static')
    sounds.restart = love.audio.newSource('SoundEffects/restart.wav', 'static')
    sounds.orb = love.audio.newSource('SoundEffects/orb.wav', 'static')
    sounds.damage = love.audio.newSource('SoundEffects/damage.wav', 'static')
    sounds.jump = love.audio.newSource('SoundEffects/jump.wav', 'static')
    sounds.level_change = love.audio.newSource('SoundEffects/level_change.wav', 'static')

    -- Loads assets used in program
    setupWorld(wf)
    setupHUD()
    setupPlayerCollider(wf)
    setupMap()
    setupCamera()

end

function setupHUD()
    -- Load Hearts
    heartImage = love.graphics.newImage(Hud.health)
    heartWidth = Hud.healthWidth
    heartHeight = Hud.healthHeight
    
    -- Load Orb Counter Image
    orbQuad = love.graphics.newQuad(0,0, 15.5, Hud.orbFrameHeight, Hud.orbFrameWidth, Hud.orbFrameHeight / 4)
    
end

function setupWorld(wf)
    -- Load world physics
    world = wf.newWorld(0, 0, true)
    world:setGravity(0, 2300)
    world:addCollisionClass('Ground')
    world:addCollisionClass('Player')
    world:addCollisionClass('Orb', {ignores={'Player'}})
    world:addCollisionClass('Slimes', {ignores={'Orb', 'Player', 'Slimes'}})
    world:addCollisionClass('Slime_Bounds', {ignores={'Orb', 'Player'}})
    world:addCollisionClass('LevelEnd')
    world:addCollisionClass('Portal')
end

function setupPlayerCollider(wf)
    -- Setup players colliders with physics
    player.collider = world:newBSGRectangleCollider(player.x, player.y, 17, 30, 3)
    player.collider:setFixedRotation(true)
    player.collider:setLinearDamping(5)
    player.collider:setCollisionClass('Player')
end

-- Tables to hold current level's colliders
local wallColliders = {}
local levelEndColliders = {}
local OrbColliders = {}
local SlimeColliders = {}
local Portal_table = {}
local Slime_Bounds = {}

function clearCurrentColliders()
    -- Function to safely destroy all colliders in a table and reset it
    local function destroyColliders(colliderTable)
        for _, colliderData in ipairs(colliderTable) do
            local collider = colliderData.collider or colliderData -- Handle nested collider tables
            if collider and not collider:isDestroyed() then
                collider:destroy()
            end
        end
        return {} -- Reset table(s)
    end

    -- Clear all collider tables
    wallColliders = destroyColliders(wallColliders)
    levelEndColliders = destroyColliders(levelEndColliders)
    OrbColliders = destroyColliders(OrbColliders)
    SlimeColliders = destroyColliders(SlimeColliders)
    Slime_Bounds = destroyColliders(Slime_Bounds)
    Portal_table = destroyColliders(Portal_table)

end

function GhostDirection()
    -- Random direction for each slime collider
    return math.random(1, 2)
end

function setupMap()
    -- Clear old colliders from previous map
    clearCurrentColliders()

    -- Load the new map
    gameMap = sti(maps[currentMapIndex])

    -- Add colliders for the "Walls" layer
    if gameMap.layers["Walls"] then
        for _, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            wall:setCollisionClass('Ground')
            table.insert(wallColliders, wall) -- Store in wallColliders table
        end
    end

    -- Add colliders for the "Level_End" layer
    if gameMap.layers["Level_End"] then
        for _, obj in pairs(gameMap.layers["Level_End"].objects) do
            local endZone = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            endZone:setType('static')
            endZone:setCollisionClass('LevelEnd')
            table.insert(levelEndColliders, endZone) -- Store in levelEndColliders table
        end
    end

    -- Add colliders for the "Orbs" Layer
    if gameMap.layers["Orb"] then
        for _, obj in pairs(gameMap.layers["Orb"].objects) do
            local Orb = world:newCircleCollider(obj.x, obj.y, 9)
            Orb:setType('static')
            Orb:setCollisionClass('Orb', {ignores = {'Player'}})
            table.insert(OrbColliders, {collider = Orb}) -- Wrap Collider in table
        end
    end

    -- Add colliders for the "Slimes" Layer
    if gameMap.layers["Slimes"] then
        for _, obj in pairs(gameMap.layers["Slimes"].objects) do
            local Slime = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            Slime:setCollisionClass('Slimes')
            local Direction = GhostDirection()
            table.insert(SlimeColliders, {collider = Slime, direction = Direction})
        end
    end

    -- Add colliders for Slimes "Slime_Bounds" Layer
    if gameMap.layers["Slime_Bounds"] then
        for _, obj in pairs(gameMap.layers["Slime_Bounds"].objects) do
            local Slime_Bound = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            Slime_Bound:setType('static')
            Slime_Bound:setCollisionClass('Slime_Bounds')
            table.insert(Slime_Bounds, Slime_Bound)
        end
    end

    -- Add collider for portal
    if gameMap.layers["Portal"] and #gameMap.layers["Portal"].objects > 0 then
        local obj = gameMap.layers["Portal"].objects[1]

        local Portal = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        Portal:setType('static')
        Portal:setCollisionClass('Portal')
        table.insert(Portal_table, Portal)

        portal.x, portal.y = obj.x + obj.width / 2, obj.y + obj.height / 2
    end
end

function setupCamera()
    cam = camera(nil, nil, 2)
    local cameraLayer = gameMap.layers["Camera_Border"]
    -- Resets camera boundaries
    cameraBounds = nil

    -- Set new camera boundaries if the Camera_Border exists
    if cameraLayer then
        local cameraObj = cameraLayer.objects[1]
        cameraBounds = {
            minX = cameraObj.x,
            minY = cameraObj.y,
            maxX = cameraObj.x + cameraObj.width,
            maxY = cameraObj.y + cameraObj.height
        }
    end
end

function love.update(dt) -- dt = delta time (time to complete frame)
    local isMoving = false

    -- Handle player movement
    handlePlayerAnim(player)
    
    -- Update grounded state
    updateGroundedState(player)
    jumpCooldown = math.max(0, jumpCooldown - dt)

    -- Update animations
    animationsUpdate(dt, portal, Slime, player, Hud)

    menuUpdate()

    -- Update player physics
    updatePlayerColliders(player, gameState, Hud, sounds)

    -- Update Ghost collider logic
    updateSlimeColliders(SlimeColliders)

    -- Update orb counter and collider logic
    updateOrbColliders(OrbColliders, Hud, sounds)

    -- Update physics world
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    -- Update camera position
    updateCameraPosition(cam, player, cameraBounds)
    
    -- Constantly checking end of level
    checkLevelEndCollision()

    -- Increment timer by delta time 
    if gameState == "game" then
        -- Regular game timer update
        elapsedTime = elapsedTime + dt
    end

    -- Quit game once reach portal layer
    endUpdate()
end

function endUpdate()
    if player.collider:enter('Portal') then
        Hud.health_count = 0
        gameComplete = true
        sounds.win:play()
    end
end

local soundPlayed = false

function menuUpdate()
    if Hud.health_count == 0 then
        -- Debugging health count
        print("Hud.health_count is 0. Teleporting player...")

        -- Ensure collider exists and is dynamic before moving
        if player.collider then
            player.collider:setType('static')  -- Ensure collider can move
            player.collider:setPosition(600, 300)
            print("Player teleported to menu position.")
        else
            print("Error: Player collider is nil!")
        end

        -- Set player to static to prevent further movement
        player.collider:setType('static')

        -- Play sound if not already played
        if not soundPlayed then
            if not gameComplete then
                sounds.loose:play()
            end
            soundPlayed = true
        end

        -- Update game state to menu
        gameState = "menu"
        print("Game state set to menu.")

        -- Handle user inputs
        if love.keyboard.isDown('escape') then
            love.event.quit()
        elseif love.keyboard.isDown('r') then
            resetGame()
            soundPlayed = false
        end
    else
        soundPlayed = false
    end
end

local sound = false

function resetGame()
    -- Reset player attributes
    player.x = 100
    player.y = 500
    player.speed = 5
    player.direction = 1
    player.dead = false
    player.isGrounded = true
    player.anim = player.animations.idle
    player.collider:setPosition(player.x, player.y)
    player.collider:setType('dynamic')  -- Make sure player can move again
    player.collider:setLinearVelocity(0, 0)

    -- Reset timer
    elapsedTime = 0

    -- Reset HUD elements
    Hud.health_count = 3
    Hud.orb_count = 0

    -- Reset slime state
    for _, slimeData in ipairs(SlimeColliders) do
        slimeData.direction = GhostDirection()  -- Reset ghost direction
    end

    -- Reset portal animation
    portal.anim = portal.portal_animations.portal

    -- Reset map and colliders and camera
    currentMapIndex = 1
    clearCurrentColliders()
    setupMap()
    setupCamera()
    
    -- Play restart sound
    sounds.restart:play()

    -- Reset game state to normal
    gameState = "game"
    gameComplete = false
end

function checkLevelEndCollision()
    -- Check for collision with Level_End object layer
    if player.collider:enter('LevelEnd') then
        clearCurrentColliders()
        currentMapIndex = currentMapIndex + 1
        setupMap()
        setupCamera()
        -- Teleports player/collider based on current map
        Hud.health_count = Hud.health_count + 1
        if currentMapIndex == 2 then
            player.collider:setPosition(10, 400)
        elseif currentMapIndex == 3 then
            player.collider:setPosition(10, 200)
        end

        -- Play level_change sound
        sounds.level_change:play()

        -- Reset grounded state to prevent carryover
        player.isGrounded = false
        jumpCooldown = 0.1
        player.collider:setLinearVelocity(0,0)
        world:update(0)
        
    end
end

function love.draw()
    cam:attach()

    -- Draw background map layers
    Background_draw(gameMap)

    -- Draws animations for player,orbs,enemies,portal
    Animation_draw(player, OrbColliders, Hud, SlimeColliders, portal, currentMapIndex, scaleX, scaleY, Slime)

    -- Text to help player with keybindings
    Help_text(currentMapIndex)

    -- Draws gameOver and gameComplete screens
    Menu_draw(Hud, gameComplete, gameState)

    cam:detach()

    -- Draws Hud/Orb_Counter/Hearts/Time
    Hud_draw(Hud, gameState, heartImage, player, elapsedTime)
end

function love.keypressed(key)
    -- Checks for space pressed
    if Hud.health_count > 0 then
        if key == 'space' and player.isGrounded and jumpCooldown <= 0 then
            player.collider:applyLinearImpulse(0, -900)
            player.isGrounded = false
            sounds.jump:play()
        end
    end
end
