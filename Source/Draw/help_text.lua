
return function(currentMapIndex)
    -- Draws text to help user
    if currentMapIndex == 1 then
        love.graphics.print("PRESS \"A\" and \"D\" TO MOVE LEFT AND RIGHT", 75, 350, 0, 0.5, 0.5)
        love.graphics.print("YOU JUMP WITH \"SPACE\"", 125, 370, 0, 0.5, 0.5)
        love.graphics.print("COLLECT AS MANY ORBS AS YOU CAN!!", 635, 300, 0, 0.55, 0.55)
    end
end