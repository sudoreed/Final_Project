_G.love = require("love")

_G.player = {
    x = 400,
    y = 200,
    speed = 5,
    direction = 1,
    isGrounded = true,
    sheet_idle = 'Blue_witch/idle.png',
    sheet_run = 'Blue_witch/run.png',
    animations = {},
    sprite_frame_width = 32,
    sprite_frame_height = 48,
}

_G.Hud = {
    health = 'Hearts/heart_bordered.png', -- H:17 W:17 Total_W:85
    -- orb = 'Empty/Empty',
    healthWidth = 17,
    healthHeight = 17,
    healthX = 15,
    healthY = 10,
    health_count = 3,
    orb_count = 0
}


local maps = {"Maps/map.lua", "Maps/map2.lua", "Maps/map3.lua"}

local currentMapIndex = 1
local cameraBounds = {}

local scaleX, scaleY = 1, 1
local gameMap
local jumpCooldown = 0.1

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    local anim8 = require 'Libraries/anim8'
    local wf = require 'Libraries/windfield'
    camera = require 'Libraries/camera'
    sti = require 'Libraries/sti'

    setupWorld(wf)
    setupHUD()
    setupPlayerCollider(wf)
    setupAnimations(anim8)
    setupMap() -- Loads current map
    setupCamera()
end

function setupHUD()
    heartImage = love.graphics.newImage(Hud.health)
    heartWidth = Hud.healthWidth
    heartHeight = Hud.healthHeight
    -- orbImage = love.graphics.newImage(Hud.orb)
end

function setupWorld(wf)
    world = wf.newWorld(0, 0, true)
    world:setGravity(0, 2300)
    world:addCollisionClass('Ground')
    world:addCollisionClass('Player')
    world:addCollisionClass('LevelEnd')
end

function setupPlayerCollider(wf)
    player.collider = world:newBSGRectangleCollider(100, 400, 17, 30, 6)
    player.collider:setCollisionClass('Player')
    player.collider:setFixedRotation(true)
    player.collider:setLinearDamping(5)
end

function setupAnimations(anim8)
    player.sheet_idle = love.graphics.newImage(player.sheet_idle)
    player.sheet_run = love.graphics.newImage(player.sheet_run)

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

    player.animations.idle = {
        animation = anim8.newAnimation(player.idle_grid(1, '1-6'), 0.2),
        spritesheet = player.sheet_idle
    }
    player.animations.run = {
        animation = anim8.newAnimation(player.run_grid(1, '1-8'), 0.2),
        spritesheet = player.sheet_run
    }
    
    player.anim = player.animations.idle
end

-- Tables to hold current level's colliders
local wallColliders = {}
local levelEndColliders = {}

function clearCurrentColliders()
    -- Remove all wall colliders
    for _, collider in ipairs(wallColliders) do
        if collider and collider:isDestroyed() == false then
            collider:destroy()
        end
    end
    wallColliders = {} -- Reset the table

    -- Remove all level-end colliders
    for _, collider in ipairs(levelEndColliders) do
        if collider and collider:isDestroyed() == false then
            collider:destroy()
        end
    end
    levelEndColliders = {} -- Reset the table
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

function love.update(dt)
    local isMoving = false

    -- Handle player movement
    handleMovement()

    -- Handle grounded state
    updateGroundedState()

    -- Update player animation
    if player.anim then
        player.anim.animation:update(dt)
    end

    -- Update player physics
    updateColliders()

    -- Update physics world
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    -- Update camera position
    updateCameraPosition()

    checkLevelEndCollision()

    jumpCooldown = math.max(0, jumpCooldown - dt)
end

function handleMovement()
    if love.keyboard.isDown('a') then
        player.x = player.x - player.speed
        player.direction = -1
        player.anim = player.animations.run
    elseif love.keyboard.isDown('d') then
        player.x = player.x + player.speed
        player.direction = 1
        player.anim = player.animations.run
    else
        player.anim = player.animations.idle
    end
end

function updateGroundedState()
    if player.collider:enter('Ground') then
        player.isGrounded = true
    elseif player.collider:exit('Ground') then
        player.isGrounded = false
    elseif player.collider:stay('Ground') then
        player.isGrounded = true
    end
end

function updateColliders() -- Player collider 
    local px, py = player.collider:getLinearVelocity()
    if love.keyboard.isDown('a') and px > -300 then
        player.collider:applyForce(-5000, 0)
    elseif love.keyboard.isDown('d') and px < 300 then
        player.collider:applyForce(5000, 0)
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
        currentMapIndex = currentMapIndex + 1
        setupMap()
        setupCamera()
        -- Repositions player/collider based on current map
        if currentMapIndex == 2 then
            player.collider:setPosition(10, 400)
        elseif currentMapIndex == 3 then
            player.collider:setPosition(10, 200)
        end

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

    -- Draw background and map layers
    gameMap:drawLayer(gameMap.layers["BG_5"])
    gameMap:drawLayer(gameMap.layers["BG_4"])
    gameMap:drawLayer(gameMap.layers["BG_3"])
    gameMap:drawLayer(gameMap.layers["BG_2"])
    gameMap:drawLayer(gameMap.layers["BG_1"])
    gameMap:drawLayer(gameMap.layers["Rocks"])
    gameMap:drawLayer(gameMap.layers["Trees_2"])
    gameMap:drawLayer(gameMap.layers["Trees"])
    gameMap:drawLayer(gameMap.layers["Ground"])

    -- Draw the player sprite
    if player.anim and player.anim.spritesheet then
        player.anim.animation:draw(
            player.anim.spritesheet,
            player.x, player.y, 0, 
            player.direction * scaleX, scaleY,
            player.sprite_frame_width / 2, player.sprite_frame_height / 2
        )
    end

    cam:detach()

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
end

function love.keypressed(key)
    if key == 'space' and player.isGrounded and jumpCooldown <= 0 then
        player.collider:applyLinearImpulse(0, -800)
        player.isGrounded = false
    end
end

