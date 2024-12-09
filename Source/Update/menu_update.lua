local soundPlayed = false

function menuUpdate(gameComplete, Hud, player, gameState)
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

return menuUpdate