local playerAnimations = {}

function playerAnimations.setupPlayerAnimations(anim8, player)
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
end

return playerAnimations