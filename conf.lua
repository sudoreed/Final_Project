_G.love = require("love")

function love.conf(t)
    t.window.title = "WITCH TRIALS"
    t.window.height = 640
    t.window.width = 1200
    t.window.icon = "blue_icon.png"
    t.window.resizeable = false
    t.window.fullscreen = false
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.display = 1

    t.console = true
    

    -- love.window.setMode(2000, 600)
end