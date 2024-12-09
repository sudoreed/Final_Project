
return function(Hud, gameComplete, gameState)
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