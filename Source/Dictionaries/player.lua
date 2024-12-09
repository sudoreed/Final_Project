
local player = {
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

return player