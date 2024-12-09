
return function(player, OrbColliders, Hud, SlimeColliders, portal, currentMapIndex, scaleX, scaleY, slime)
    -- Draw the player sprite animation
    if player.anim and player.anim.spritesheet then
        player.anim.animation:draw(
            player.anim.spritesheet,
            player.x, player.y, 0, 
            player.direction * scaleX, scaleY,
            player.sprite_frame_width / 2, player.sprite_frame_height / 2
        )
    end

    -- Draw the orb animation at each collider's position
    for _, orbData in ipairs(OrbColliders) do
        local orbCollider = orbData.collider
        if orbCollider and not orbCollider:isDestroyed() then
            local orbX, orbY = orbCollider:getPosition()
            Hud.anim.animation:draw(
                Hud.anim.orbsheet, orbX, orbY, 0, 0.37, 0.37, 
                Hud.orbFrameWidth / 2, Hud.orbFrameHeight / 2)
        end
    end

    -- Draw slime animation at each slime position
    for _, SlimeData in ipairs(SlimeColliders) do
        local SlimeCollider = SlimeData.collider
        local slimeDirection = SlimeData.direction
        if slime.anim then
            slime.x, slime.y = SlimeCollider:getPosition()
            slime.anim.animation:draw(
                slime.anim.slime_sheet,
                slime.x, slime.y, nil,
                slime.direction * 2, 2,
                slime.slime_FrameWidth / 2, slime.slime_FrameHeight / 1.2)     
        end
    end

    -- Draw portal animations for level 3
    if currentMapIndex == 3 then
        if portal.anim and portal.anim.portal_sheet then
            portal.anim.animation:draw(
                portal.anim.portal_sheet,
                portal.x, portal.y, 0, 
                0.5, 0.5,
                portal.portal_FrameWidth / 2, portal.portal_FrameHeight / 2
            )
        end
    end
end