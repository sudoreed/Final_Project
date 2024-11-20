-- local collision = {}
-- local map = require("map").gameMap

-- function collision.checkHorizontal(x, y, player)
    
--     local tilewidth = map.tilewidth
--     local tileheight = map.tileheight
--     local tileX1 = math.floor(x / tilewidth) + 1
--     local tileY1 = math.floor(y / tileheight) + 1
--     local tileX2 = math.floor((x + player.frameWidth[player.currentAnimation]) / tilewidth) + 1
--     local tileY2 = math.floor((y + player.frameHeight[player.currentAnimation]) / tileheight) + 1

--     local collisionLayerX = "Walls"
--     for tileX = tileX1, tileX2 do
--         for tileY = tileY1, tileY2 do
--             if map.layers[collisionLayerX].data[tileY][tileX] > 0 then
--                 return true
--             end
--         end
--     end
--     return false
-- end

-- function collision.checkVertical(x, y, player)
--     local tilewidth = map.tilewidth
--     local tileheight = map.tileheight
--     local tileX1 = math.floor(x / tilewidth) + 1
--     local tileY1 = math.floor(y / tileheight) + 1
--     local tileX2 = math.floor((x + player.frameWidth[player.currentAnimation]) / tilewidth) + 1
--     local tileY2 = math.floor((y + player.frameHeight[player.currentAnimation]) / tileheight) + 1

--     local collisionLayerY = "Ground"
--     for tileX = tileX1, tileX2 do
--         for tileY = tileY1, tileY2 do
--             if map.layers[collisionLayerY].data[tileY][tileX] > 0 then
--                 return true, tileY
--             end
--         end
--     end
--     return false, nil
-- end

-- return collision