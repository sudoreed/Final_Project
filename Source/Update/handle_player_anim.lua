
return function(player, dt)
    -- Determines player animation based on key movement
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