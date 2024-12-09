
return function(Hud, gameState, heartImage, player, elapsedTime)
    if gameState == "game" then
        -- Draw the health bar (hearts)
        local heartWidth, heartHeight = heartImage:getWidth() / 5, heartImage:getHeight()
        local scale = 3  -- Scale the hearts to make them bigger
        local x = Hud.healthX
        local y = Hud.healthY
        if Hud.health_count > 3 then
            Hud.health_count = 3
        elseif Hud.health_count < 0 then
            Hud.health_count = 0
        end
        -- Loop through the 3 hearts
        for i = 1, 3 do
            local heartQuad
            if i <= Hud.health_count then
                heartQuad = love.graphics.newQuad(0, 0, heartWidth, heartHeight, heartImage:getDimensions())
            else
                heartQuad = love.graphics.newQuad(heartWidth * 4, 0, heartWidth, heartHeight, heartImage:getDimensions())
            end
            love.graphics.draw(heartImage, heartQuad, x + (i - 1) * (heartWidth * scale + 5), y, 0, scale, scale)
        end

        -- Orb Counter Image
        love.graphics.draw(Hud.orb_sheet, orbQuad, 1060, 0, nil, 3.2)

        -- Format the time as MM:SS
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
        -- Draw menu-based HUD information
        love.graphics.draw(Hud.orb_sheet, orbQuad, 820, 235, nil, 3.2)
        love.graphics.print("X" .. Hud.orb_count, 870, 250, 0, 1.4, 1.4)
        love.graphics.print("Time Elapsed... " .. math.floor(elapsedTime), 250, 260)
    end
end