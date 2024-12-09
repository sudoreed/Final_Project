
return function(dt, portal, slime, Hud, player)
    -- player animations
    if player.anim then
        player.anim.animation:update(dt)
    end
    -- hud animations
    if Hud.anim then
        Hud.anim.animation:update(dt)
    end
    -- enemy animations
    if slime.anim and slime.anim.animation then
        slime.anim.animation:update(dt)
    end
    -- portal animations
    if portal.anim and portal.anim.animation then
        portal.anim.animation:update(dt)
    end
end