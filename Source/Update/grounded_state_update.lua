
-- update grounded state

return function(player)
    if player.collider:enter('Ground') then
        player.isGrounded = true
    end
end
