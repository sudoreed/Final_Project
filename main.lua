io.stdout:setvbuf("no")
_G.love = require("love")

_G.player = {
    x = 100,
    y = 500,
    speed = 5,
    direction = 1,
    dead = false,
    isGrounded = true,
    sheet_idle = 'Props/Blue_witch/idle.png',
    sheet_run = 'Props/Blue_witch/run.png',
    sheet_take_damage = 'Props/Blue_witch/take_damage.png',
    animations = {},
    sprite_frame_width = 32,
    sprite_frame_height = 48,
    sprite_death_height = 40
}

_G.Hud = {
    health = 'Props/heart_bordered.png', -- H:17 W:17 Total_W:85
    healthWidth = 17,
    healthHeight = 17,
    healthX = 15,
    healthY = 10,
    health_count = 3,
    orb_sheet = 'Props/Orb.png',
    orb_animations = {},
    orbFrameHeight = 100,
    orbFrameWidth = 58,
    orb_count = 0
}

_G.slime = {
    slime_sheet = 'Props/slime.png',
    direction = 1,
    slime_animations = {},
    slime_FrameWidth = 16,
    slime_FrameHeight = 32,
}

_G.portal = {
    portal_sheet = {"Props/portal.png"},
    portal_animations = {},
    portal_FrameWidth = 122,
    portal_FrameHeight = 152,
}



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
    setupAnimations(anim8)
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

function setupAnimations(anim8)
    
    -- Animations Credit 
    -- Player: 9E0 Blue_witch https://9e0.itch.io/witches-pack
    -- Orbs: Harley Modestowicz
    -- Slimes: Diogo Vernier https://diogo-vernier.itch.io/pixel-art-slime
    -- Portal: Harley Modestowicz

    player.animationCooldown = 1.0
    player.animationCooldownTimer = 0

    -- Player animations
    player.sheet_idle = love.graphics.newImage(player.sheet_idle)
    player.sheet_run = love.graphics.newImage(player.sheet_run)
    player.sheet_take_damage = love.graphics.newImage(player.sheet_take_damage)

    player.idle_grid = anim8.newGrid(
        player.sprite_frame_width,
        player.sprite_frame_height,
        player.sheet_idle:getWidth(),
        player.sheet_idle:getHeight()
    )

    player.run_grid = anim8.newGrid(
        player.sprite_frame_width,
        player.sprite_frame_height,
        player.sheet_run:getWidth(),
        player.sheet_run:getHeight()
    )

    player.take_damage_grid = anim8.newGrid(
        player.sprite_frame_width,
        player.sprite_frame_height,
        player.sheet_take_damage:getWidth(),
        player.sheet_take_damage:getHeight()
    )

    player.animations.idle = {
        animation = anim8.newAnimation(player.idle_grid(1, '1-6'), 0.2),
        spritesheet = player.sheet_idle
    }
    player.animations.run = {
        animation = anim8.newAnimation(player.run_grid(1, '1-8'), 0.2),
        spritesheet = player.sheet_run
    }
    -- Default animation
    player.anim = player.animations.idle

    -- Orb animations
    Hud.orb_sheet = love.graphics.newImage(Hud.orb_sheet)
    Hud.grid = anim8.newGrid(
        Hud.orbFrameWidth,
        Hud.orbFrameHeight,
        Hud.orb_sheet:getWidth(),
        Hud.orb_sheet:getHeight()
    )
    Hud.orb_animations.orb = {
        animation = anim8.newAnimation(Hud.grid('1-4', 1), 0.2),
        orbsheet = Hud.orb_sheet
    }
    -- Default animation
    Hud.anim = Hud.orb_animations.orb

    -- Slime animations
    slime.slime_sheet = love.graphics.newImage(slime.slime_sheet)
    slime.grid = anim8.newGrid(
        slime.slime_FrameWidth,
        slime.slime_FrameHeight,
        slime.slime_sheet:getWidth(),
        slime.slime_sheet:getHeight()
    )
    slime.slime_animations.slime = {
        animation = anim8.newAnimation(slime.grid('1-7', 1), 0.3),
        slime_sheet = slime.slime_sheet
    }
    -- Default animation
    slime.anim = slime.slime_animations.slime

    -- Portal animation
    portal.portal_sheet = love.graphics.newImage(portal.portal_sheet)
    portal.grid = anim8.newGrid(
        portal.portal_FrameWidth,
        portal.portal_FrameHeight,
        portal.portal_sheet:getWidth(),
        portal.portal_sheet:getHeight()
    )
    portal.portal_animations.portal = {
        animation = anim8.newAnimation(portal.grid('1-4', 1), 0.3),
        portal_sheet = portal.portal_sheet
    }
    -- Default animation
    portal.anim = portal.portal_animations.portal
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
    handlePlayerAnim()
    
    -- Update grounded state
    updateGroundedState()
    jumpCooldown = math.max(0, jumpCooldown - dt)

    -- Update animations
    animationsUpdate(dt)

    -- Quit game once reach portal layer
    portalUpdate()

    -- Menu update (death/game over)
    menuUpdate()

    -- Update player physics
    updatePlayerColliders()

    -- Update Ghost collider logic
    updateSlimeColliders()

    -- Update orb counter and collider logic
    updateOrbColliders()

    -- Update physics world
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    -- Update camera position
    updateCameraPosition()

    -- Constantly checking end of level
    checkLevelEndCollision()

    -- Increment timer by delta time 
    if gameState == "game" then
        -- Regular game timer update
        elapsedTime = elapsedTime + dt
    end
end

function animationsUpdate(dt)
    -- player animations
    if player.anim then
        player.anim.animation:update(dt)
    end
    -- hud animations
    if Hud.anim then
        Hud.anim.animation:update(dt)
    end
    -- enemy animations
    if slime.anim and slime.anim.animation then
        slime.anim.animation:update(dt)
    end
    -- portal animations
    if portal.anim and portal.anim.animation then
        portal.anim.animation:update(dt)
    end
end

function portalUpdate()
    if player.collider:enter('Portal') then
        Hud.health_count = 0
        gameComplete = true
        sounds.win:play()
    end
end

local sound = false

function menuUpdate()
    if Hud.health_count == 0 then
        if gameComplete == false then
            -- Playing sound once
            if not sound then
                sounds.loose:play()
                sound = true
            end
        end
        -- Moving player/camera to position of "menu"
        gameState = "menu"
        player.collider:setPosition(600, 300)
        player.collider:setType('static')
        -- Quit key
        if love.keyboard.isDown('escape') then
            love.event.quit()
        end
        -- Reset program key
        if love.keyboard.isDown('r') then
            resetGame()
            sound = false
        end
    else
        sound = false
    end
end

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

function handlePlayerAnim(dt)
    -- Determines player animation based
        -- on key movement
    if player.dead == false then
        if love.keyboard.isDown('a') then
            player.anim = player.animations.run
        elseif love.keyboard.isDown('d') then
            player.anim = player.animations.run
        else
            player.anim = player.animations.idle
        end
    end
end

function updateSlimeColliders()
    for i, SlimeData in ipairs(SlimeColliders) do
        local SlimeCollider = SlimeData.collider
        local Direction = SlimeData.direction
        local Neg_Speed = -120
        local Pos_Speed = 120
        local px, py = SlimeCollider:getLinearVelocity()

        -- Apply force based on current direction and velocity
        if Direction == 1 and px > Neg_Speed then
            SlimeCollider:applyForce(-4000, 0)
        elseif Direction == 2 and px < Pos_Speed then
            SlimeCollider:applyForce(4000, 0)
        end

        -- Check if SlimeCollider is inside the bounds
        if SlimeCollider:enter('Slime_Bounds') then 
            if Direction == 1 then
                SlimeData.direction = 2  -- Change direction to right
                slime.direction = 1
            elseif Direction == 2 then
                SlimeData.direction = 1  -- Change direction to left
                slime.direction = -1
            end
        end
    end
end

function updateOrbColliders()
    for i = #OrbColliders, 1, -1 do
        local orbData = OrbColliders[i]
        local orbCollider = orbData.collider

        -- Checks if player collides with orb
        if orbCollider:enter('Player') then
            orbCollider:destroy()
            sounds.orb:play()
            Hud.orb_count = Hud.orb_count + 1
        end
    end
end

function updateGroundedState()
    -- Boolean value for grounded
    if player.collider:enter('Ground') then
        player.isGrounded = true
    elseif player.collider:exit('Ground') then
        player.isGrounded = false
    elseif player.collider:stay('Ground') then
        player.isGrounded = true
    end
end

function updatePlayerColliders()
    local px, py = player.collider:getLinearVelocity()
    if gameState == "game" then    
        if player.dead == false then
            -- Updating player/collider movement
            if love.keyboard.isDown('a') and px > -200 then -- Top speed parameter
                player.x = player.x - player.speed
                player.direction = -1
                player.collider:applyForce(-4000, 0) -- Applied Force parameter
            elseif love.keyboard.isDown('d') and px < 200 then
                player.x = player.x + player.speed
                player.direction = 1
                player.collider:applyForce(4000, 0)
            end
        end
        -- Tracking interaction of player and enemies
        if player.collider:enter('Slimes') then
            Hud.health_count = Hud.health_count - 1
            if Hud.health_count > 0 then
               sounds.damage:play() 
            end
        end
    end
end

function updateCameraPosition()
    cam:lookAt(player.x, player.y)
    
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    if cameraBounds then
        local halfScreenWidth = screenWidth / 4
        local halfScreenHeight = screenHeight / 3
        cam.x = math.max(cameraBounds.minX + halfScreenWidth, math.min(cam.x, cameraBounds.maxX - halfScreenWidth))
        cam.y = math.max(cameraBounds.minY + halfScreenHeight, math.min(cam.y, cameraBounds.maxY - halfScreenHeight))
    end
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
        updateGroundedState()
    end
end

function love.draw()
    cam:attach()

    -- Draw background map layers
    Background_draw()

    -- Draws animations for player,orbs,enemies,portal
    Animation_draw()

    -- Text to help player with keybindings
    Help_text()

    -- Draws gameOver and gameComplete screens
    Menu_draw()

    cam:detach()

    -- Draws Hud/Orb_Counter/Hearts/Time
    Hud_draw()
end

function Background_draw()
    -- Credit to the tileset for the tile/gameMap
    -- GandalfHardcore: https://gandalfhardcore.itch.io/free-pixel-art-male-and-female-character

    gameMap:drawLayer(gameMap.layers["BG_5"])
    gameMap:drawLayer(gameMap.layers["BG_4"])
    gameMap:drawLayer(gameMap.layers["BG_3"])
    gameMap:drawLayer(gameMap.layers["BG_2"])
    gameMap:drawLayer(gameMap.layers["BG_1"])
    gameMap:drawLayer(gameMap.layers["Rocks"])
    gameMap:drawLayer(gameMap.layers["Trees_2"])
    gameMap:drawLayer(gameMap.layers["Trees"])
    gameMap:drawLayer(gameMap.layers["Ground"])
end

function Animation_draw()
        -- Draw the player sprite animation
        if player.anim and player.anim.spritesheet then
            player.anim.animation:draw(
                player.anim.spritesheet,
                player.x, player.y, 0, 
                player.direction * scaleX, scaleY,
                player.sprite_frame_width / 2, player.sprite_frame_height / 2
            )
        end
    
        -- Draw the orb animation at each collider's position
        for _, orbData in ipairs(OrbColliders) do
            local orbCollider = orbData.collider
            if orbCollider and not orbCollider:isDestroyed() then
                -- Get collider's position
                local orbX, orbY = orbCollider:getPosition()
                -- Draw orb animation
                Hud.anim.animation:draw(
                    Hud.anim.orbsheet, orbX, orbY, 0, 0.37, 0.37, 
                    Hud.orbFrameWidth / 2, Hud.orbFrameHeight / 2)
            end
        end
    
        sX, sY = 2, 2
        -- Draw slime animation at each ghosts position
        for _, SlimeData in ipairs(SlimeColliders) do
            local SlimeCollider = SlimeData.collider
            local slimeDirection = SlimeData.direction
            if slime.anim then
                -- Get collider's position
                slime.x, slime.y = SlimeCollider:getPosition()
                -- Draw Ghost Animation
                slime.anim.animation:draw(
                    slime.anim.slime_sheet,
                    slime.x, slime.y, nil,
                    slime.direction * sX, sY,
                    slime.slime_FrameWidth / 2, slime.slime_FrameHeight / 1.2)     
            end
        end
        
        -- Draw portal animations
        if currentMapIndex == 3 then
            if portal.anim and portal.anim.portal_sheet then
                local sX, sY = 0.5, 0.5
                portal.anim.animation:draw(
                    portal.anim.portal_sheet,
                    portal.x, portal.y, 0, 
                    sX, sY,
                    portal.portal_FrameWidth / 2, portal.portal_FrameHeight / 2
                )
            end
        end
end

function Menu_draw()
    if Hud.health_count == 0 then
        -- Draw the menu only when the game is over
        local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()

        -- Draw the black rectangle centered
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle('fill', 0, 0, windowWidth, windowHeight)
        -- Reset color for text
        love.graphics.setColor(1, 1, 1, 1)
        -- Draw the text centered
        love.graphics.print("Press \"Escape\" to Quit", 670, 300, 0, 0.5, 0.5)
        love.graphics.print("Press \"R\" to Restart", 400, 300, 0, 0.5, 0.5)
        if gameComplete == true then
            love.graphics.print("To Be Continued...", 480, 200, 0, 1, 1)
        else
            love.graphics.print("Game Over", 460, 200, 0, 2, 2)
        end
    end
end


function Help_text()
    -- Draws text to help user
    if currentMapIndex == 1 then
        love.graphics.print("PRESS \"A\" and \"D\" TO MOVE LEFT AND RIGHT", 75, 350, 0, 0.5, 0.5)
        love.graphics.print("YOU JUMP WITH \"SPACE\"", 125, 370, 0, 0.5, 0.5)
        love.graphics.print("COLLECT AS MANY ORBS AS YOU CAN!!", 635, 300, 0, 0.55, 0.55)
    end
end

function Hud_draw()
    if gameState == "game" then
        -- Draw the health bar (hearts)
        local heartWidth, heartHeight = heartImage:getWidth() / 5, heartImage:getHeight()
        local scale = 3  -- Scale the hearts to make them bigger
        local x = Hud.healthX
        local y = Hud.healthY
        -- Keeping num of hearts in range of 0-3
        if Hud.health_count > 3 then
            Hud.health_count = 3
        elseif Hud.health_count < 0 then
            Hud.health_count = 0
        end
        -- Loop through the 3 hearts
        for i = 1, 3 do
            -- Determine if the current heart should be full or empty based on health count
            local heartQuad
            if i <= Hud.health_count then
                -- Full heart (left side of the PNG)
                heartQuad = love.graphics.newQuad(0, 0, heartWidth, heartHeight, heartImage:getDimensions())
            else
                -- Empty heart (right side of the PNG)
                heartQuad = love.graphics.newQuad(heartWidth * 4, 0, heartWidth, heartHeight, heartImage:getDimensions())
            end
            -- Draw the heart at the calculated position
            love.graphics.draw(heartImage, heartQuad, x + (i - 1) * (heartWidth * scale + 5), y, 0, scale, scale)
        end

        -- Orb Counter Image
        love.graphics.draw(Hud.orb_sheet, orbQuad, 1060, 0, nil, 3.2)

        --Format the time as MM:SS
        local minutes = math.floor(elapsedTime / 60)
        local seconds = math.floor(elapsedTime % 60)
        local formattedTime = string.format("%02d:%02d", minutes, seconds)
        
        -- Draw the timer
        love.graphics.setColor(0.5,1,0,1) -- Color for timer
        love.graphics.print("Time: " .. formattedTime, 500, 10, 0, 1.3, 1.3)
        -- Draw orb counter
        love.graphics.setColor(0,0.8,0.9) -- Color for orb counter
        love.graphics.print("x" .. Hud.orb_count, 1105, 15, 0, 1.4, 1.4)
        love.graphics.setColor(1,1,1) -- Reset Color

        if Hud.health_count == 0 then
            player.dead = true  
        end
    end
    if gameState == "menu" then
        -- Uses the Hud to draw hud based information in the menu draw screen
        love.graphics.draw(Hud.orb_sheet, orbQuad, 820, 235, nil, 3.2)
        love.graphics.print("X" .. Hud.orb_count, 870, 250, 0, 1.4, 1.4)
        love.graphics.print("Time Elapsed... " .. math.floor(elapsedTime), 250, 260)
    end
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