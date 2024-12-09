
-- Update/Slime/update_slime_colliders.lua
return function(SlimeColliders)
    for i, SlimeData in ipairs(SlimeColliders) do
        local SlimeCollider = SlimeData.collider
        local Direction = SlimeData.direction
        local Neg_Speed = -120
        local Pos_Speed = 120
        local px, py = SlimeCollider:getLinearVelocity()

        -- Apply force based on current direction and velocity
        if Direction == 1 and px > Neg_Speed then
            SlimeCollider:applyForce(-4000, 0)
        elseif Direction == 2 and px < Pos_Speed then
            SlimeCollider:applyForce(4000, 0)
        end

        -- Check if SlimeCollider is inside the bounds
        if SlimeCollider:enter('Slime_Bounds') then 
            if Direction == 1 then
                SlimeData.direction = 2  -- Change direction to right
            elseif Direction == 2 then
                SlimeData.direction = 1  -- Change direction to left
            end
        end
    end
end
