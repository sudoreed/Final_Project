-- local player = {}

-- -- Player's properties and initial state
-- player.x = 100
-- player.y = 100
-- player.speed = 250
-- player.gravity = 400
-- player.velocityY = 0
-- player.onGround = true
-- player.currentAnimation = "idle"
-- player.frame = 1
-- player.frameTimer = 0
-- player.animations = {}
-- player.quads = {}

-- function player.load()
--     -- Load player animations and quads
--     player.animations = {
--         idle = love.graphics.newImage("Blue_witch/idle.png"),
--         run = love.graphics.newImage("Blue_witch/run.png"),
--         jump = love.graphics.newImage("Blue_witch/jump.png"),
--         attack = love.graphics.newImage("Blue_witch/attack.png"),
--         take_damage = love.graphics.newImage("Blue_witch/take_damage.png"),
--         death = love.graphics.newImage("Blue_witch/death.png")
--     }

--     -- Set up quads for each animation
--     local frameData = {
--         idle = {6, 32, 48},
--         run = {8, 32, 48},
--         jump = {5, 48, 48},
--         attack = {9, 104, 46},
--         take_damage = {3, 32, 48},
--         death = {12, 32, 40}
--     }

--     for anim, data in pairs(frameData) do
--         player.quads[anim] = {}
--         for i = 1, data[1] do
--             player.quads[anim][i] = love.graphics.newQuad(
--                 0, (i-1) * data[3], data[2], data[3],
--                 player.animations[anim]:getDimensions()
--             )
--         end
--     end
-- end

-- function player.update(dt, map, collision)
--     -- Apply gravity
--     if not player.onGround then
--         player.velocityY = player.velocityY + player.gravity * dt
--     end

--     local nextX = player.x
--     local nextY = player.y + player.velocityY * dt
--     local isMoving = false

--     -- Horizontal movement
--     if love.keyboard.isDown("d") then
--         nextX = player.x + player.speed * dt
--         player.currentAnimation = "run"
--         isMoving = true
--     elseif love.keyboard.isDown("a") then
--         nextX = player.x - player.speed * dt
--         player.currentAnimation = "run"
--         isMoving = true
--     elseif love.keyboard.isDown("q") then
--         player.currentAnimation = "attack"
--     end

--     -- Set to idle if not moving
--     if not isMoving and player.onGround then
--         player.currentAnimation = "idle"
--     end

--     -- Handle horizontal collisions
--     if not collision.checkHorizontal(nextX, player.y, player) then
--         player.x = nextX
--     end

--     -- Handle vertical collisions
--     local collisionDetected, tileY = collision.checkVertical(player.x, nextY, player)
--     if collisionDetected then
--         player.velocityY = 0
--         player.onGround = true
--         player.y = (tileY - 1) * map.tileheight - player.frameHeight[player.currentAnimation] -- Use frameHeight
--     else
--         player.y = nextY
--         player.onGround = false
--     end

--     -- Animation frame timing
--     player.frameTimer = player.frameTimer + dt
--     if player.frameTimer >= player.frameTimes[player.currentAnimation] then
--         player.frameTimer = 0
--         player.frame = (player.frame % #player.quads[player.currentAnimation]) + 1
--     end
-- end

-- function player.keypressed(key)
--     if key == "space" and player.onGround then
--         player.velocityY = -400
--         player.onGround = false
--         player.currentAnimation = "jump"
--     end
-- end

-- function player.draw()
--     local anim = player.currentAnimation
--     local frame = player.quads[anim][player.frame]

--     if love.keyboard.isDown("a") then
--         love.graphics.draw(player.animations[anim], frame, player.x, player.y, 0, -1.5, 1.5)
--     else
--         love.graphics.draw(player.animations[anim], frame, player.x, player.y, 0, 1.5, 1.5)
--     end
-- end

-- return player