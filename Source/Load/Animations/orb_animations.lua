-- animations/orb_animations.lua
local orbAnimations = {}

function orbAnimations.setupOrbAnimations(anim8, Hud)
    -- Orb animations
    Hud.orb_sheet = love.graphics.newImage(Hud.orb_sheet)
    Hud.grid = anim8.newGrid(
        Hud.orbFrameWidth,
        Hud.orbFrameHeight,
        Hud.orb_sheet:getWidth(),
        Hud.orb_sheet:getHeight()
    )
    Hud.orb_animations.orb = {
        animation = anim8.newAnimation(Hud.grid('1-4', 1), 0.2),
        orbsheet = Hud.orb_sheet
    }
    -- Default animation
    Hud.anim = Hud.orb_animations.orb
end

return orbAnimations