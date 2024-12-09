-- animations/slime_animations.lua
local slimeAnimations = {}

function slimeAnimations.setupSlimeAnimations(anim8, slime)
    -- Slime animations
    slime.slime_sheet = love.graphics.newImage(slime.slime_sheet)
    slime.grid = anim8.newGrid(
        slime.slime_FrameWidth,
        slime.slime_FrameHeight,
        slime.slime_sheet:getWidth(),
        slime.slime_sheet:getHeight()
    )
    slime.slime_animations.slime = {
        animation = anim8.newAnimation(slime.grid('1-7', 1), 0.3),
        slime_sheet = slime.slime_sheet
    }
    -- Default animation
    slime.anim = slime.slime_animations.slime
end

return slimeAnimations  -- Ensure this is returned as the module
