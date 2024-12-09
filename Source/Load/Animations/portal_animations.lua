local portalAnimations = {}

function portalAnimations.setupPortalAnimations(anim8, portal)
    -- Portal animation
    portal.portal_sheet = love.graphics.newImage(portal.portal_sheet)
    portal.grid = anim8.newGrid(
        portal.portal_FrameWidth,
        portal.portal_FrameHeight,
        portal.portal_sheet:getWidth(),
        portal.portal_sheet:getHeight()
    )
    portal.portal_animations.portal = {
        animation = anim8.newAnimation(portal.grid('1-4', 1), 0.3),
        portal_sheet = portal.portal_sheet
    }
    -- Default animation
    portal.anim = portal.portal_animations.portal
end

return portalAnimations