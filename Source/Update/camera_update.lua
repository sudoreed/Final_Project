

return function(cam, player, cameraBounds)
    cam:lookAt(player.x, player.y)
    
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    if cameraBounds then
        local halfScreenWidth = screenWidth / 4
        local halfScreenHeight = screenHeight / 3
        cam.x = math.max(cameraBounds.minX + halfScreenWidth, math.min(cam.x, cameraBounds.maxX - halfScreenWidth))
        cam.y = math.max(cameraBounds.minY + halfScreenHeight, math.min(cam.y, cameraBounds.maxY - halfScreenHeight))
    end
end