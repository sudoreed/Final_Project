
return function(gameMap)
    -- Credit to the tileset for the tile/gameMap
    -- GandalfHardcore: https://gandalfhardcore.itch.io/free-pixel-art-male-and-female-character

    gameMap:drawLayer(gameMap.layers["BG_5"])
    gameMap:drawLayer(gameMap.layers["BG_4"])
    gameMap:drawLayer(gameMap.layers["BG_3"])
    gameMap:drawLayer(gameMap.layers["BG_2"])
    gameMap:drawLayer(gameMap.layers["BG_1"])
    gameMap:drawLayer(gameMap.layers["Rocks"])
    gameMap:drawLayer(gameMap.layers["Trees_2"])
    gameMap:drawLayer(gameMap.layers["Trees"])
    gameMap:drawLayer(gameMap.layers["Ground"])
end