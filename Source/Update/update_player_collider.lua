
return function(player, gameState, Hud, sounds)
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
            if Hud.health_count == 0 then
                player.collider:setType('static')
                player.collider:setPosition(600, 300)
            end
            if Hud.health_count > 0 then
                sounds.damage:play() 
            end
        end
    end

end