
return function(OrbColliders, Hud, sounds)
    for i = #OrbColliders, 1, -1 do
        local orbData = OrbColliders[i]
        local orbCollider = orbData.collider

        -- Checks if player collides with orb
        if orbCollider:enter('Player') then
            orbCollider:destroy()
            sounds.orb:play()
            Hud.orb_count = Hud.orb_count + 1
        end
    end
end